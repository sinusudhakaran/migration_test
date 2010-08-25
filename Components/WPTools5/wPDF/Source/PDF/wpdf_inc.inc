// ------------------------------------------------------------------
// wPDF
// ------------------------------------------------------------------
// Version 2.50 - CopyRight (C) 2003 by wpCubed GmbH
// You may integrate this component into your EXE but never distribute
// it's source or object files.
// ------------------------------------------------------------------
// Info: www.pdfcontrol.com,  www.wptools.de
// ------------------------------------------------------------------

// This define MUST be enabled. It switches the use of the wPDF DLL on
{$DEFINE INTWPSWITCH} // Default: Enable

// This switch converts wPDF into a Demo version
{.$DEFINE WPDFDEMOV}

// Also creates the PDF export component for WPTools. Normally
// you will include wPDF with WPTools by defined WPDFEX in the
// wptools file WPINC.INC and recompile the wptools package
// the avoids dependencies between the packages.
{.$DEFINE WPTOOLSPDF}

// Install the QR Filter
{$IFNDEF VER170}
{$IFNDEF VER100}
{$DEFINE WPDF_QR}
{$ENDIF}
{$ENDIF}

// Install the TWPPagesImport (not any longer supported officially)
{$DEFINE PDFIMPORT}

// Allow loading of JPEG using DrawTGraphic
{$DEFINE JPEGDATA}

// ------------ Use the wPDF Source License
// Please remember to update the unit name WPPDFR1 with WPPDFR1_src in
// all the projects, too.
{.$DEFINE WPDF_SOURCE}

{$IFDEF VER150}
{$WARNINGS OFF}
{$ENDIF}

{$IFDEF VER180}
{$WARNINGS OFF}
{$ENDIF}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
{$IFDEF WPDF_SOURCE}
{$DEFINE INTWPSWITCH}
{$UNDEF PDFIMPORT}
{$ENDIF}

{$IFDEF BCB}
{$UNDEF JPEGDATA}
{$ENDIF}

{$IFDEF WPDFDEMOV}
{$UNDEF JPEGDATA}
{$ENDIF}


