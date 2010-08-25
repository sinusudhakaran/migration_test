unit WPPDFR2;
// ------------------------------------------------------------------
// wPDF PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 1, 2000 Copyright (C) by Julian Ziersch, Berlin
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.pdfcontrol.com
// ------------------------------------------------------------------
{$I wpdf_inc.inc}   

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
  {$IFDEF WPDF_SOURCE} ,WPPDFR1_src {$ELSE} ,WPPDFR1 {$ENDIF}
  {$IFNDEF INTWPSWITCH} ,WPT2PDFDLL {$ENDIF};

{$D-} {$S-}

type
  TWPPDFPrinter = class(TWPCustomPDFExport)
  PUBLISHED
  {$IFNDEF T2H}
    property Filename;
    property EncodeStreamMethod;
    property CompressStreamMethod;
    property ConvertJPEGData;
    property Info;
    property CreateThumbnails;
    property CreateOutlines;
    property ExcludedFonts;
    property BeforeBeginDoc;
    property PageMode;
    property FontMode;
    property Encryption;
    property UserPassword;
    property OwnerPassword;
    property InMemoryMode;
    property ExtraMessages;
    property OnUpdateGauge;
    property OnError;
    property DebugMode;
    property DebugMetafilePath;
    property MergeStart;
    property OnMergeText;
   {$ENDIF}
  end;

implementation


end.

