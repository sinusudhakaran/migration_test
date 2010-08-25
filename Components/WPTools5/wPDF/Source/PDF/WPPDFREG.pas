unit WPPDFREG;
// ------------------------------------------------------------------
// WPTools PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 1.2, 2000 Copyright (C) by Julian Ziersch, Berlin
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.wptools.de - wpCubed GmbH
// ------------------------------------------------------------------

// If you have WPTools please do not install this unit!
// Activate symbol WPPDFEX in file WPINC.INC and recompile the wptools package

{$I wpdf_inc.inc}
{$IFDEF WPDF_SOURCE} {$UNDEF PDFIMPORT} {$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,
  {$IFDEF WPDF_SOURCE} WPPDFR1_src, {$ELSE} WPPDFR1, {$ENDIF}  
  WPPDFPRP, WPPDFR2 {$IFDEF WPTOOLSPDF}, WPPDFWP{$ENDIF}
  {$IFDEF WPDF_QR} ,wppdfQR {$ENDIF} ;

procedure Register;

implementation

{$R WPPDFREG.RES}

procedure Register;
begin
 RegisterComponents('wPDF',[TWPPDFPrinter,TWPPDFProperties]);
 {$IFDEF PDFIMPORT}
 RegisterComponents('wPDF',[TWPDFPagesImport]);
 {$ENDIF}
 {$IFDEF WPDF_QR}
  RegisterComponents('wPDF',[TQRwPDFFilter]);
 {$ENDIF}
end;

end.

