unit WPViewPDF_reg;
{ ------------------------------------------------------------------------------
  TWPViewPDF - PDF Viewer and Print Class by WPCubed GmbH
  -----------------------------------------------------------------------------
  Load PDFViewer DLL and create controls for the window class

  Copyright (C) 2003 - WPCubed GmbH - www.wptools.de
  ------------------------------------------------------------------------------ }

interface

uses Classes, WPViewPDF1;

procedure Register;

implementation

{$R wpViewPDF.res}

procedure Register;
begin
  RegisterComponents('wPDF', [TWPViewPDF]);
end;


end.
