unit WPDF_FRep;
{ -----------------------------------------------
  FastReport 2.4 and 3.11 PDF Export Filter
  -----------------------------------------------
  written by Julian Ziersch, 30.1.2003
  Part of wPDF Version 2
  Info: www.wptools.de
  -----------------------------------------------
  14.3.2005 - modifications to support FastReport 3
  ----------------------------------------------- }

{ To use it place a TWPDF_FrPDFExport on the form and attach a
  TWPPDFPrinter. If you want to select different properties you can
  set the property 'OnShowDialog' to show a properties dialog before
  the output is started. }

{$DEFINE FASTREP3} // Define this symbol to support FastReport 3

interface

uses
  SysUtils, Forms, Windows, Messages, Classes, Graphics, WPPDFR1
    {$IFDEF FASTREP3} ,Controls, frxClass, frxEngine,  frxUtils, frxRes, frxrcExports
    {$ELSE}, FR_Class {$ENDIF};

type

 TWPDF_FrPDFExportShowDialog = procedure(Sender : TObject; PDFPrinter : TWPCustomPDFExport; var Abort : Boolean) of Object;

 {$IFDEF FASTREP3}
 TWPDF_FrPDFExport = class(TfrxCustomExportFilter)
 {$ELSE}
 TWPDF_FrPDFExport = class(TfrExportFilter)
 {$ENDIF}
  private
    FPDFPrinter : TWPCustomPDFExport;
    FOldInMemoryMode : Boolean;
    FOnShowDialog : TWPDF_FrPDFExportShowDialog;
    FPageNumber : Integer;
    procedure SetPDFPrinter(x :TWPCustomPDFExport);
  public
  {$IFDEF FASTREP3}
    class function GetDescription: String; override;
  {$ENDIF}
    destructor  Destroy; override;
    procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
  {$IFDEF FASTREP3}
    function    ShowModal: TModalResult; override;
    function    Start: Boolean; override;
    procedure   ExportObject(Obj: TfrxComponent); override;
    procedure   StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure   Finish; override;
  {$ELSE}
    function    ShowModal: Word; override;
    procedure   OnBeginPage; override;
    procedure   OnEndPage; override;
    procedure   OnData(x, y: Integer; View: TfrView); override;
    procedure   OnBeginDoc; override;
    procedure   OnEndDoc; override;
  {$ENDIF}
  published
    property PDFPrinter : TWPCustomPDFExport read FPDFPrinter write SetPDFPrinter;
    property OnShowDialog : TWPDF_FrPDFExportShowDialog read FOnShowDialog write FOnShowDialog;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('wPDF', [TWPDF_FrPDFExport]);
end;

{$IFDEF FASTREP3}
class function TWPDF_FrPDFExport.GetDescription: String;
begin
   Result := 'Portable Document Format (PDF)';
end;
{$ENDIF}

destructor TWPDF_FrPDFExport.Destroy;
begin
  PDFPrinter := nil;
  inherited Destroy;
end;

// PDFPrinter must be assigned, otherwise we do no export
procedure TWPDF_FrPDFExport.SetPDFPrinter(x :TWPCustomPDFExport);
begin
   FPDFPrinter := x;
   if x<>nil then
   begin
     x.FreeNotification(Self);
     {$IFNDEF FASTREP3}
     frRegisterExportFilter(Self, 'Portable Document Format (*.PDF)', '*.PDF');
     {$ENDIF}
   end
   {$IFNDEF FASTREP3}
   else frUnRegisterExportFilter(Self)
   {$ENDIF};
end;

procedure TWPDF_FrPDFExport.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FPDFPrinter <> nil) and (AComponent = FPDFPrinter) then PDFPrinter := nil;
  end;
end;

{$IFDEF FASTREP3}
function TWPDF_FrPDFExport.ShowModal: TModalResult;
var Abort : Boolean;
begin
  Abort := FALSE;
  if assigned(FOnShowDialog) then FOnShowDialog(Self,FPDFPrinter,Abort);
  if Abort then Result := mrCancel
  else Result := mrOk;
end;
{$ELSE}
function TWPDF_FrPDFExport.ShowModal: Word;
var Abort : Boolean;
begin
  Abort := FALSE;
  if assigned(FOnShowDialog) then FOnShowDialog(Self,FPDFPrinter,Abort);
  if Abort then Result := idCancel
  else Result := idOK;
end;
{$ENDIF}

{$IFDEF FASTREP3}
function TWPDF_FrPDFExport.Start: Boolean;
{$ELSE}
procedure TWPDF_FrPDFExport.OnBeginDoc;
{$ENDIF}
begin
  if FPDFPrinter<>nil then // should be always true!
  begin
    FOldInMemoryMode := FPDFPrinter.InMemoryMode;
    FPDFPrinter.InMemoryMode := TRUE;
    FPDFPrinter.Stream := Stream;
    if Self.FileName<>'' then
    FPDFPrinter.FileName := Self.FileName;   
    {$IFDEF FASTREP3} Result := TRUE;{$ENDIF}
    FPDFPrinter.BeginDoc;
  end
  {$IFDEF FASTREP3} else Result := FALSE; {$ENDIF};
  FPageNumber := -1; // start with 0
end;

{$IFDEF FASTREP3}
procedure TWPDF_FrPDFExport.Finish;
{$ELSE}
procedure TWPDF_FrPDFExport.OnEndDoc;
{$ENDIF}
var aStream : TStream;
begin
  if FPDFPrinter<>nil then // should be always true!
  begin
    {$IFDEF FASTREP3}
    if FPageNumber>=0 then
       FPDFPrinter.EndPage;
    {$ENDIF}
    FPDFPrinter.EndDoc;
    FPDFPrinter.InMemoryMode := FOldInMemoryMode;
  end;
end;

{$IFDEF FASTREP3}
procedure TWPDF_FrPDFExport.StartPage(Page: TfrxReportPage; Index: Integer);
var res : Integer;
begin
  inc(FPageNumber);
  if FPDFPrinter<>nil then
  begin
    if FPageNumber>0 then
       FPDFPrinter.EndPage;
    res := Screen.PixelsPerInch;
    FPDFPrinter.StartPage(
       Round(Page.Width), // apparently pixels coordinates!
       Round(Page.Height),
       res,
       res,0);
  end;
end;
{$ELSE}
procedure TWPDF_FrPDFExport.OnBeginPage;
begin
  inc(FPageNumber);
  if FPDFPrinter<>nil then
  begin
    FPDFPrinter.StartPage(
    CurReport.EMFPages[FPageNumber].PrnInfo.Pgw,
    CurReport.EMFPages[FPageNumber].PrnInfo.Pgh,
      Screen.PixelsPerInch,
      Screen.PixelsPerInch,0);
  end;
end;
{$ENDIF}

{$IFDEF FASTREP3}
procedure TWPDF_FrPDFExport.ExportObject(Obj: TfrxComponent);
begin
  if FPDFPrinter<>nil then TfrxView(Obj).Draw(
   FPDFPrinter.Canvas,
   1,1,0,0 ); // ScaleX, ScaleY, OffX, OffY
end;
{$ELSE}
procedure TWPDF_FrPDFExport.OnData(x, y: Integer; View: TfrView);
begin
  if FPDFPrinter<>nil then View.Draw(FPDFPrinter.Canvas);
end;
{$ENDIF}

{$IFNDEF FASTREP3}
procedure TWPDF_FrPDFExport.EndPage;
begin
  if FPDFPrinter<>nil then FPDFPrinter.EndPage;
end;
{$ENDIF}

end.
