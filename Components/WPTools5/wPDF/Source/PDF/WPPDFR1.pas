unit WPPDFR1;
// ------------------------------------------------------------------
// wPDF PDF Support Component. Utilizes PDF Engine DLL
// ------------------------------------------------------------------
// Version 2, 2003 Copyright (C) by Julian Ziersch
// -------------------------------- wpCubed GmbH --------------------
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.wptools.de
// ------------------------------------------------------------------

{$I wpdf_inc.inc}

{$IFDEF WPDF_SOURCE}
   ERROR
   // Please remember to update the unit name WPPDFR1
   // with 'WPPDFR1_src' in all the forms
{$ENDIF}

{$IFDEF WPDFDEMOV}
{$D-}{$S-}
{$ENDIF}

{$DEFINE NEWLOADLIB} {Don't use global DLL Handle }

{--$DEFINE USECompatibleDC} // OFF, does not work on Windows 9.x
{--$DEFINE WPBITREF} // OFF!!!
{--$DEFINE DONT_MOD_LOGRES} // If active the logical resolution of the 'canvas' will not be updated
// It will be the printer or screen resolution (depending on property CanvasReference)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ShellAPI, Dialogs, FileCtrl, Printers
  {$IFNDEF INTWPSWITCH}, WPT2PDFDLL
  {$IFDEF PDFIMPORT}, WPDFRead{$ENDIF}{$ENDIF}
  {$IFDEF JPEGDATA}, Jpeg{$ENDIF};

{$IFDEF INTWPSWITCH}
{$I wPDFDefines.inc} // defines
{$ENDIF}


type
  TWPCustomPDFExport = class;
  TWPDFSecurity = (wpp40bit, wpp128bit);
  TWPDevModes = set of (wpNoBITBLTFillRect, wpNeverFill, wpWhiteBrushIsTransparent, wpExactTextPositioning,
    wpNoTextRectClipping, wpClipRectSupport, wpDontStackWorldModifications, wpDontAdjustTextSpacing,
    wpDontCropBitmaps,wpAllowTransparentBit,wpAlwaysHighResPDF, wpNeverHighResPDF,
    wpUseFontWidthArgument, wpNoTextScaling);

  PDFException = Exception;
  TWPDFOptions = set of (wpCreateAutoLinks);
    TWPPDFFontMode = (wpUseTrueTypeFonts, wpEmbedTrueTypeFonts,
    wpEmbedSymbolTrueTypeFonts, wpUseBase14Type1Fonts, wpEmbedSubsetTrueType_Charsets, wpEmbedSubsetTrueType_UsedChar);
  TWPCompressStreamMethod = (wpCompressNone, wpCompressFlate, wpCompressRunlength, wpCompressFastFlate);
  TWPEncodeStreamMethod = (wpEncodeNone, wpASCII85Encode, wpASCIIHexEncode);
  TWPPDFPageModes = (pwUseNone, wpUseOutlines, wpUseThumbs, wpFullScreen);


  TWPExtraMessages = set of (wpOnEmbedFonts);

  TWPPDFZoomModes = (pwZoomDefault, pwZoomFitPage, pwZoomFitVertical, pwZoomFitHorizontal);

  TWPPDFCanvasReference = (wprefScreen, wprefPrinter);
  TWPPDFInputfileMode = (pwIgnoreInput, pwAppendToInput, wpConvertInputToWatermark,
    wpUseInputAsWatermark);
  TWPPDFReadMode = (wpdfStandard, wpdfRetrieveASCII, wpdfRetrieveEMF, wpdfRetrieveBMP);

  TWPDFEncryption = set of
    (wpEncryptFile, wpEnablePrinting, wpEnableChanging, wpEnableCopying, wpEnableForms
    ,wpLowQualityPrintOnly
    {,wpEnableDocAssembly,wpEnableFormFieldFillIn,wpEnableAccessibilityOp
       - not possible in PDF security 1 and 2, 3 is unpublished } );

  TWPJPEGQuality = (wpNoJPEG, wpJPEG_10, wpJPEG_25, wpJPEG_50, wpJPEG_75, wpJPEG_100);
  TWPCCITTMode = (wpCCITT_31D, wpCCITT_32D, wpCCITT_42D);

  TWPJPEGColorMode = (wpRGBjpeg, wpGrayjpeg, wpCMYKjpeg);

  TWPPDFUpdateGaugeEvent = procedure(Sender: TObject; position: Integer) of object;
  TWPDFErrorEvent = procedure(Sender: TObject; num: Integer; text: string) of object;

  TWPDFMergeTextEvent = procedure(Sender: TObject; var Text: string) of object;

  TWPDFInternalEvent = procedure(Sender: TObject; p: Pointer) of object;
  TWPDFReadInputPDF = procedure(Sender: TObject; page_num: Integer; const text: string;
    var obj: TObject) of object;
  TWPDFReadWatermarkMeta =
    procedure(Sender: TObject; PageNumber: Integer;
    var MetaHandle: DWORD; var MetaFile: string) of object;

  {:: This event (global reference WPAfterPDFCreation) is triggered
  after the EndDoc procedure of any PDFExport component. This makes it
  possible to start the PDFViewer with that file. The variable
  StartViewer is set according to the value of the property
  'AutoLaunch'. If you display the PDF file in this event please
  set the variable StartViewer to FALSE }
  TWPAfterPDFCreationEvent = procedure(
    Sender   : TWPCustomPDFExport;
    FileName : String;
    var StartViewer : Boolean) of Object;


  TWPPDFExportInfo = class(TPersistent)
  private
    FAuthor: string;
    FDate: TDateTime;
    FModDate: TDateTime;
    // FCreator : String; always 'WPTools'
    FProducer: string;
    FTitle: string;
    FSubject: string;
    FKeywords: string;
    FAdditionalStrings : TStringList;
    function GetAdditionalStrings : TStrings;
    procedure SetAdditionalStrings(x :TStrings);
  published
    property Author: string read FAuthor write FAuthor;
    property Producer: string read FProducer write FProducer;
    property Title: string read FTitle write FTitle;
    property Subject: string read FSubject write FSubject;
    property Keywords: string read FKeywords write FKeywords;
    property Strings : TStrings read GetAdditionalStrings write SetAdditionalStrings;
  public
    constructor Create;
    destructor  Destroy; override;
    // not published. May be changed at runtime
    property Date: TDateTime read FDate write FDate;
    property ModDate: TDateTime read FModDate write FModDate;
    procedure Assign(Source: TPersistent); override;
  end;

  TWPCustomPDFExport = class(TComponent)
  protected
    DLLOK: Boolean;
    FDLLInUSE: Integer;
  {$IFDEF INTWPSWITCH}
    DLLHandle: Integer;
    procedure UnLoadDLL;
    function LoadDLL(fname: string): Boolean;
    {$ENDIF}
  protected
    wpdf_canvas: TCanvas;
    FAbort: boolean;
    pdf_env: Pointer; // PDF Creation Enviroment
    FFilename: TFilename;
    FCanvasReference: TWPPDFCanvasReference;
    FReferenceDC: HDC;
    FBitmap : TBitmap;
    FPrinting: Boolean;
    FMergeStart : String;
    FInfo: TWPPDFExportInfo;
    FStream: TStream; // alternative to Filename
    FEncodeStreamMethod: TWPEncodeStreamMethod;
    FCompressStreamMethod: TWPCompressStreamMethod;
    FInputfileMode: TWPPDFInputfileMode;
    FOnReadWatermarkMeta: TWPDFReadWatermarkMeta;
    FInputPageCount: Integer;
    FPageIsOpen: boolean;
    FInputFile: string;
    FDefaultXRes, FDefaultYRes: Integer;
    FEncryption: TWPDFEncryption;
    FSecurity: TWPDFSecurity;
    FModes: TWPDevModes;
    FOptions: TWPDFOptions;
    FUserPassword: string;
    FOwnerPassword: string;
    FPageMode: TWPPDFPageModes;
    FZoomMode: TWPPDFZoomModes;
    FFontMode: TWPPDFFontMode;
    FCreateThumbnails: Boolean;
    FCreateOutlines: Boolean;
    FDrawCanvasMeta: Boolean;
    FConvertJPEGData: Boolean;
    FStartPageAtOnce: Boolean;
    FAutoLaunch: Boolean;
    FLastError: Integer;
    FDebugMode: Boolean;
    FDebugWMFPath: string;
    FOnUpdateGauge: TWPPDFUpdateGaugeEvent;
    FPDFReadMode: TWPPDFReadMode;
    FOnReadInputPDF: TWPDFReadInputPDF;
    FJPEGQuality: TWPJPEGQuality;
    // if you 'print' multiple documents set FPageCount to the count
    // of all pages in all documents
    // the export will automatically create the correct page numbers
    FPageCount: Integer;
    FInMemoryMode: Boolean;
    FHeaderFooterColor: TColor;
    // page number which is currently printed
    FInternPageNumber: Integer;
    FBeforeBeginDoc, FAfterBeginDoc, FBeforeEndDoc, FAfterEndDoc: TNotifyEvent;
    FOnError: TWPDFErrorEvent;
    FOnMerge : TWPDFMergeTextEvent;
    FOnExtraI: TWPDFInternalEvent;
    FExcludedFonts: TStringList;
    FExtraMessages: TWPExtraMessages;
    FInternPageCount: Integer;
    FCanvas: TCanvas;
    FMetafile: TMetafile;
    Finit: TWPPDF_InitRec;
    FKeepInitValues: Boolean;
    FWatermarks: TStringList;
    FSizeAttr, FSizeParagraph, FSizeLine: Integer;
    FLastWidth, FLastHeight: Integer;
    Fpage_xres, Fpage_yres: Integer;
    FReadPageWidth: Integer;
    FReadPageHeight: Integer;
    FPDFReadBitmapRes: Integer;
    function GetExcludedFonts: TStrings;
    procedure SetFilename(x : TFileName);
    function GetCanvas: TCanvas;
    procedure SetExcludedFonts(x: TStrings);
    procedure SetMergeStart(x : string);
    procedure SetJPEGQuality(x: TWPJPEGQuality);
    procedure SetModes(x: TWPDevModes);
    procedure SetOptions(x: TWPDFOptions);
    procedure SetInfo(x: TWPPDFExportInfo);
    procedure SetPrinting(x : Boolean);
    procedure SetDLLName(x: string);
    function GetDLLName: string;
    procedure PreparePage(pageno: Integer; var init: TWPPDF_InitRec; ResX, ResY: Integer); virtual;
    procedure InternStartPage(aPage: Boolean; const aName: string; pagew, pageh, xres, yres,
      options: Integer);
    { Properties not in used without WPTools}
    property HeaderFooterColor: TColor read FHeaderFooterColor write FHeaderFooterColor;
    function InternDrawBitmap(x, y, w, h: Integer; var bitdef: TWPGraphicDef): Integer;
    function PrepareWatermark(pagew, pageh, xres, yres: Integer): string;
    procedure UpdateReferenceCanvas(start: Boolean);
  public
    property ConvertJPEGData: Boolean read FConvertJPEGData write FConvertJPEGData;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source : TPersistent); override;
    procedure BeginDoc; virtual;
    procedure CloseCanvas; virtual;
    procedure EndPage; virtual;
    procedure StartPage(pagew, pageh, xres, yres, rotation: Integer); virtual;
    function  InternEngineCommand(ID : Integer; const Command : String) : Integer;
    procedure Abort; virtual;
    procedure EndDoc; virtual;
    property ReferenceDC : HDC read FReferenceDC;
    property Printing: Boolean read FPrinting write SetPrinting;
    property Stream: TStream read FStream write FStream;
    property PageCount: Integer read FPageCount write FPageCount;
    property PageNumber: Integer read FInternPageNumber;
    property DLLName: string read GetDLLName write SetDLLName;
    property Aborted: Boolean read FAbort;
    property LastError: Integer read FLastError;
    property InputPageCount: Integer read FInputPageCount;
    { --- Engine Procedures --- }
    procedure SetBookmark(const BookMarkName: string; x, y: Integer);
    procedure SetLinkArea(const BookMarkName: string; r: TRect);
    procedure SetOutlineCharset(CharSet: Integer);
    function  SetOutlineXY(const Caption: string; X, Y: Integer; aPrevious, aParent: Integer): Integer;
    function  SetOutline(const Caption, BookMarkName: string; aPrevious, aParent: Integer): Integer;
  {$IFNDEF VER90}  // not in Delphi 2
    function  SetOutlineXYW(const pCaption: PWideString; x, y: Integer; aPrevious, aParent: Integer): Integer;
    function  SetOutlineW(const Caption, BookMarkName: WideString; aPrevious, aParent: Integer): Integer;
  {$ENDIF}
    procedure StartWatermark(const Name: string; pagew, pageh, xres, yres: Integer);
    procedure EndWatermark;
    procedure UseWatermark(const Name: string);
    procedure UseWatermarkEx(const Name: string; Width, Height: Integer; Angle: Integer);
    procedure UsePDFWatermark(InputPageNo: Integer);
    procedure UseXForm(const Name: string; x, y, w, h: Integer);
    procedure UseXFormEx(const Name: string; x, y, w, h, angle: Integer);
    { --- Render Procedures --- }
    procedure InitDC;
    procedure DrawRotatedText(const Text : String;
      Angle, Left, Top, Width, Height : Integer;
      Alignment : TAlignment;
      const Font  : TFont);
    function DrawTGraphic(x, y, w, h: Integer; Graphic: TGraphic): Integer;
    function DrawGraphicFile(x, y, w, h: Integer; const FileName: string): Integer;
    function DrawJPEG(x, y, w, h, SourceW, SourceH: Integer;
      Buffer: PChar; BufLen: Integer;
      ColorMode : TWPJPEGColorMode = wpRGBjpeg): Integer;
    function DrawCCITT(x, y, w, h, SourceColumns, SourceRows: Integer; mode : TWPCCITTMode; Buffer: PChar; BufLen: Integer): Integer;
    procedure DrawMetafile(x, y: Integer; meta: HENHMETAFILE);
    procedure DrawMetafileEx(x, y, w, h: Integer; meta: HENHMETAFILE; DrawCanvasMetaXRes, DrawCanvasMetaYRes: Integer);
    function DrawBitmap(x, y, w, h: Integer; handle: HBITMAP): Integer;
    function DrawDIBBitmap(x, y, w, h: Integer; BitmapInfo: PBitmapInfo; BitmapBits: Pointer): Integer;
    function DrawBitmapClone(x, y, w, h: Integer; LastBitmapID: Integer): Integer;
    procedure EnlargeFontWidth(percent: Integer);
    procedure Command(const s: string; val: DWORD);
    property Canvas: TCanvas read GetCanvas;
    property DebugMode: Boolean read FDebugMode write FDebugMode;
    property DebugMetafilePath: string read FDebugWMFPath write FDebugWMFPath;
    property OnExtraInfo: TWPDFInternalEvent read FOnExtraI write FOnExtraI;
    property XPixelsPerInch: Integer read Fpage_xres;
    property YPixelsPerInch: Integer read Fpage_yres;
    property dll_pdf_env: Pointer read pdf_env;
  public
    // Not published -use TWPDFPagesImport
    property ReadPageWidth: Integer read FReadPageWidth write FReadPageWidth;
    property ReadPageHeight: Integer read FReadPageHeight write FReadPageHeight;
    property PDFReadBitmapRes: Integer read FPDFReadBitmapRes write FPDFReadBitmapRes;
    property OnReadInputPDF: TWPDFReadInputPDF read FOnReadInputPDF write FOnReadInputPDF; // Obsolete
    property OnReadWatermarkMeta: TWPDFReadWatermarkMeta read FOnReadWatermarkMeta write FOnReadWatermarkMeta; // Obsolete
  published
    property PDFReadMode: TWPPDFReadMode read FPDFReadMode write FPDFReadMode;
    property CanvasReference: TWPPDFCanvasReference read FCanvasReference write FCanvasReference;
    property Filename: TFilename read FFilename write SetFilename;
    property AutoLaunch: Boolean read FAutoLaunch write FAutoLaunch;
    property EncodeStreamMethod: TWPEncodeStreamMethod
      read FEncodeStreamMethod write FEncodeStreamMethod;
    property CompressStreamMethod: TWPCompressStreamMethod
      read FCompressStreamMethod write FCompressStreamMethod;
    property Info: TWPPDFExportInfo read FInfo write SetInfo;
    property CreateThumbnails: Boolean read FCreateThumbnails write FCreateThumbnails;
    property CreateOutlines: Boolean read FCreateOutlines write FCreateOutlines;
    property Modes: TWPDevModes read FModes write SetModes;
    property Options: TWPDFOptions read FOptions write SetOptions;
    property ExcludedFonts: TStrings read GetExcludedFonts write SetExcludedFonts;
    property PageMode: TWPPDFPageModes read FPageMode write FPageMode;
    property ZoomMode: TWPPDFZoomModes read FZoomMode write FZoomMode;
    property FontMode: TWPPDFFontMode read FFontMode write FFontMode;
    property Encryption: TWPDFEncryption read FEncryption write FEncryption;
    property Security: TWPDFSecurity read FSecurity write FSecurity;
    property UserPassword: string read FUserPassword write FUserPassword;
    property OwnerPassword: string read FOwnerPassword write FOwnerPassword;
    property MergeStart : string read FMergeStart write SetMergeStart;
    property InMemoryMode: Boolean read FInMemoryMode write FInMemoryMode;
    property JPEGQuality: TWPJPEGQuality read FJPEGQuality write SetJPEGQuality;
    property ExtraMessages: TWPExtraMessages read FExtraMessages write FExtraMessages;
    property InputfileMode: TWPPDFInputfileMode read FInputfileMode write FInputfileMode;
    property InputFile: string read FInputFile write FInputFile;
    property BeforeBeginDoc: TNotifyEvent read FBeforeBeginDoc write FBeforeBeginDoc;
    property AfterBeginDoc: TNotifyEvent read FAfterBeginDoc write FAfterBeginDoc;
    property BeforeEndDoc: TNotifyEvent read FBeforeEndDoc write FBeforeEndDoc;
    property AfterEndDoc: TNotifyEvent read FAfterEndDoc write FAfterEndDoc;
    property OnError: TWPDFErrorEvent read FOnError write FOnError;
    property OnMergeText: TWPDFMergeTextEvent read FOnMerge write FOnMerge;
    property OnUpdateGauge: TWPPDFUpdateGaugeEvent read FOnUpdateGauge write FOnUpdateGauge;
  end;

  {$IFDEF PDFIMPORT}
  TWPDFPagesImportMode = (wpdfReadASCII, wpdfReadBitmap, wpdfReadMetafile);

  TWPDFImportedPage = class(TObject)
  private
    FGraphic: TGraphic;
    FWidth: Integer;
    FHeight: Integer;
    FText: string;
    FNumber: Integer;
  public
    destructor Destroy; override;
    property Graphic: TGraphic read FGraphic;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Number: Integer read FNumber;
    property Text: string read FText;
    function GetGraphicAndNil: TGraphic;
  end;

  TWPDFPagesImportEvent = procedure(
    Sender: TObject;
    PageNumber: Integer;
    var Abort, Import: Boolean) of object;

  TWPDFPagesImport = class(TComponent)
  private
    FEngine: TWPCustomPDFExport;
    FMode: TWPDFPagesImportMode;
    FPDFFile: string;
    FPageNumber: Integer;
    FPages: TList; // Of type TWPDFImportedPage
    FFromPage: Integer;
    FToPage: Integer;
    FBitmapResolution: Integer;
    FMaxPageWidth: Integer;
    FMaxPageHeight: Integer;
    FBeforeReadPage: TWPDFPagesImportEvent;
    function GetPageCount: Integer;
    function GetPage(index: Integer): TWPDFImportedPage;
    procedure ExtractPDFPage(Sender: TObject;
      page_num: Integer; const text: string; var obj: TObject);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function Execute: Boolean;
    procedure SetDLLName(const x: string);
    property PageCount: Integer read GetPageCount;
    property Pages[index: Integer]: TWPDFImportedPage read GetPage;
    property MaxPageWidth: Integer read FMaxPageWidth;
    property MaxPageHeight: Integer read FMaxPageHeight;
  published
    property Mode: TWPDFPagesImportMode read FMode write FMode;
    property BitmapResolution: Integer read FBitmapResolution write FBitmapResolution;
    property PDFFile: string read FPDFFile write FPDFFile;
    property FromPage: Integer read FFromPage write FFromPage;
    property ToPage: Integer read FToPage write FToPage;
    property BeforeReadPage: TWPDFPagesImportEvent read FBeforeReadPage write FBeforeReadPage;
  end;
  {$ENDIF}

procedure WPDF_Start(const name, code: string);

{$IFDEF INTWPSWITCH}
var WPPDF_Action: TWPPDF_Action;
    _WPPDF_WPTEXEC: TWPPDF_WPTEXEC;
    WPPDF_SetIProp: TWPPDF_SetIProp;
{$ENDIF}
var WPAfterPDFCreation : TWPAfterPDFCreationEvent;

implementation

const
  {$IFNDEF WPDFDEMOV}
  DEFAULT_DLL_NAME = 'wPDF200A.DLL';
  {$ELSE}
  DEFAULT_DLL_NAME = 'wPDF200DEMO.DLL';
  {$ENDIF}
  CANNOTLOADDLLERR = 'DLL "%s" was not found. PDF Export is not possible.';
  INCORRECTDLLERR = 'DLL "%s" is not compatible. PDF Export is not possible.';

  {$IFNDEF PDFIMPORT}
  PDF_IMP_NOT = 'PDF Import is not supported';
  {$ENDIF}

  // Flags for StartPage(..., Options)
  WPDF_PAGE_LANDSCAPE = 1; // Rotated by 90 degree
  WPDF_PAGE_LANDSCAPE_L = 3; // Rotated by 270 degree

  // DLL Initialisation Code is below --------------------------------------------
var
  {$IFNDEF WPDFDEMOV}
  FLicCode, FLicName: string;
  {$ENDIF}
  FGLDLLName: string;


{$IFDEF INTWPSWITCH}
// We load the DLL one and then simply uset. We unlod it in 'finalization' !
var
{$IFNDEF NEWLOADLIB}
    glDLLHandle   : Integer;
    glDLLUseCount : Integer;
{$ENDIF}

    WPPDF_Initialize: TWPPDF_Initialize;
    WPPDF_ProcessPDF: TWPPDF_ProcessIt;
    WPPDF_Finalize: TWPPDF_Finalize;
    WPPDF_SetSProp: TWPPDF_SetSProp;
    {$IFNDEF VERSION1COMPAT}
    WPPDF_InitializePage: TWPPDF_InitializePage;
    {$ELSE}
    WPPDF_StartWPTPage: TWPPDF_StartWPTPage;
    {$ENDIF}


procedure TWPCustomPDFExport.UnLoadDLL;
begin
  if DLLHandle>0 then
  begin
    {$IFDEF NEWLOADLIB}
      FreeLibrary(DLLHandle);
    {$ELSE}
    dec(glDLLUseCount);
    {$ENDIF}
    DLLHandle := 0;
  end;
end;

function TWPCustomPDFExport.LoadDLL(fname: string): Boolean;
{$IFDEF NEWLOADLIB} var glDLLHandle : Integer; {$ENDIF}
begin
  {$IFDEF NEWLOADLIB}
  glDLLHandle := DLLHandle;
  {$ENDIF}
  if glDLLHandle <= 0 then
  begin
    glDLLHandle := LoadLibrary(PChar(fname));
    if glDLLHandle <= 0 then
      raise PDFException.CreateFmt(CANNOTLOADDLLERR, [fname]);
    @WPPDF_Initialize := GetProcAddress(glDLLHandle, 'WPPDF_Initialize');
    @WPPDF_Finalize := GetProcAddress(glDLLHandle, 'WPPDF_Finalize');
    @WPPDF_ProcessPDF := GetProcAddress(glDLLHandle, 'WPPDF_ProcessPDF'); // can be nil!
    @WPPDF_SetSProp := GetProcAddress(glDLLHandle, 'WPPDF_SetSProp');
    @WPPDF_SetIProp := GetProcAddress(glDLLHandle, 'WPPDF_SetIProp');
    {$IFDEF WPDFDEMOV} // Force incompatible Demo DLL
    @WPPDF_Action := GetProcAddress(glDLLHandle, 'WPPDF_Do');
    {$ELSE}
    @WPPDF_Action := GetProcAddress(glDLLHandle, 'WPPDF_Action');
    {$ENDIF}
    {$IFNDEF VERSION1COMPAT}@WPPDF_InitializePage{$ELSE}@WPPDF_StartWPTPage{$ENDIF}
    := GetProcAddress(glDLLHandle, {$IFNDEF VERSION1COMPAT} 'WPPDF_InitializePage'{$ELSE} 'WPPDF_StartWPTPage'{$ENDIF});
    @_WPPDF_WPTEXEC := GetProcAddress(glDLLHandle, '_WPPDF_WPTEXEC');
    if (@WPPDF_Initialize = nil) or (@WPPDF_Finalize = nil) or (@WPPDF_SetSProp = nil)
      or (@WPPDF_SetIProp = nil) or (@WPPDF_Action = nil) or
      ({$IFNDEF VERSION1COMPAT}@WPPDF_InitializePage{$ELSE}@WPPDF_StartWPTPage{$ENDIF} = nil)
      or (@_WPPDF_WPTEXEC = nil) then
    begin
      FreeLibrary(glDLLHandle);
      {$IFNDEF NEWLOADLIB} glDLLHandle := 0; {$ENDIF}
      raise PDFException.CreateFmt(INCORRECTDLLERR, [fname]);
    end;
  end;

  if DLLHandle=0 then
  begin
    {$IFNDEF NEWLOADLIB} inc(glDLLUseCount); {$ENDIF}
    DLLHandle := glDLLHandle;
    @WPPDF_Initialize := GetProcAddress(DLLHandle, 'WPPDF_Initialize');
    @WPPDF_Finalize := GetProcAddress(DLLHandle, 'WPPDF_Finalize');
    @WPPDF_ProcessPDF := GetProcAddress(DLLHandle, 'WPPDF_ProcessPDF'); // can be nil!
    @WPPDF_SetSProp := GetProcAddress(DLLHandle, 'WPPDF_SetSProp');
    @WPPDF_SetIProp := GetProcAddress(DLLHandle, 'WPPDF_SetIProp');
    {$IFDEF WPDFDEMOV} // Force incompatible Demo DLL
    @WPPDF_Action := GetProcAddress(DLLHandle, 'WPPDF_Do');
    {$ELSE}
    @WPPDF_Action := GetProcAddress(DLLHandle, 'WPPDF_Action');
    {$ENDIF}
    {$IFNDEF VERSION1COMPAT}@WPPDF_InitializePage{$ELSE}@WPPDF_StartWPTPage{$ENDIF}
    := GetProcAddress(DLLHandle, {$IFNDEF VERSION1COMPAT} 'WPPDF_InitializePage'{$ELSE} 'WPPDF_StartWPTPage'{$ENDIF});
    @_WPPDF_WPTEXEC := GetProcAddress(DLLHandle, '_WPPDF_WPTEXEC');
    if (@WPPDF_Initialize = nil) or (@WPPDF_Finalize = nil) or (@WPPDF_SetSProp = nil)
      or (@WPPDF_SetIProp = nil) or (@WPPDF_Action = nil) or
      ({$IFNDEF VERSION1COMPAT}@WPPDF_InitializePage{$ELSE}@WPPDF_StartWPTPage{$ENDIF} = nil)
      or (@_WPPDF_WPTEXEC = nil) then
    begin
      UnloadDLL;
      raise PDFException.CreateFmt(INCORRECTDLLERR, [fname]);
    end
    else
    begin
      Result := TRUE;
      DLLOK := TRUE;
      FDLLInUSE := 0;
    end;
  end
  else
    Result := TRUE;
end;
{$ENDIF} // --------------------------------------------------------------------

procedure WPDF_Start(const name, code: string);
begin
  {$IFNDEF WPDFDEMOV}
  FLicCode := code;
  FLicName := name;
  {$ENDIF}
end;

procedure WPPDF_CallBack(parent: Pointer; msgid: Integer; value: Integer; p: PChar); stdcall;
type
  TWPDFPageDes = packed record size: Integer; pageno: Integer; abort: Integer;
    id, d1: Integer;
    d2, d3, w, h: Single;
  end;
  PWPDFPageDes = ^TWPDFPageDes;
var
  s: string;
  {$IFDEF PDFIMPORT}
  obj: TObject;
  can: TMetafileCanvas;
  {$ENDIF}
begin
  {$IFDEF PDFIMPORT}
  obj := nil;
  can := nil;
  {$ENDIF}
  s := '';
  if parent <> nil then
  begin
    case msgid of
      WPPDF_CALL_ERROR:
        begin
          if assigned(TWPCustomPDFExport(TObject(parent)).FOnError) then
            TWPCustomPDFExport(TObject(parent)).FOnError(TObject(parent),
              value, StrPas(p));
        end;
      WPPDF_CALL_MERGE:
        begin
          if assigned(TWPCustomPDFExport(TObject(parent)).FOnMerge) then
          begin
             s := StrPas(p);
             TWPCustomPDFExport(TObject(parent)).FOnMerge(TObject(parent),s);
             WPPDF_SetSProp(TWPCustomPDFExport(TObject(parent)).pdf_env,
                WPPDF_MERGETEXTRESULT, PChar(s));
          end;
        end;
      WPPDF_CALL_INFO_IMPORT:
        begin
          TWPCustomPDFExport(TObject(parent)).FInputPageCount := value;
        end;
      WPPDF_CALL_EXTRA_INFO_IMPORT:
        begin
          // For intern use only!!!! -------------------------------------------
          if assigned(TWPCustomPDFExport(TObject(parent)).FOnExtraI) then
            TWPCustomPDFExport(TObject(parent)).FOnExtraI(TObject(parent), p)
              // -------------------------------------------------------------------
          else if assigned(TWPCustomPDFExport(TObject(parent)).FOnReadInputPDF) then
          begin
            if (TWPCustomPDFExport(TObject(parent)).FPDFReadMode = wpdfRetrieveASCII)
              {$IFDEF INTWPSWITCH}
            and Assigned(WPPDF_ProcessPDF)
              {$ENDIF} then
            begin
              {$IFNDEF PDFIMPORT}
              raise PDFException.Create(PDF_IMP_NOT);
              {$ELSE}
              SetLength(s, PWPDFPageDes(p)^.size);
              SetLength(s, WPPDF_ProcessPDF(p, PChar(s), Length(s), 0, 0));
              TWPCustomPDFExport(TObject(parent)).ReadPageWidth := 0;
              TWPCustomPDFExport(TObject(parent)).ReadPageHeight := 0;
              TWPCustomPDFExport(TObject(parent)).FOnReadInputPDF(TObject(parent),
                PWPDFPageDes(p)^.pageno + 1, s, obj); // first page is 0 !
              {$ENDIF}
            end
            else if (TWPCustomPDFExport(TObject(parent)).FPDFReadMode = wpdfRetrieveEMF)
              {$IFDEF INTWPSWITCH}
            and Assigned(WPPDF_ProcessPDF){$ENDIF}
            then
              {$IFNDEF PDFIMPORT}
              raise PDFException.Create(PDF_IMP_NOT)
                {$ELSE}
            try
              obj := TMetafile.Create;
              TMetafile(obj).Enhanced := TRUE;
              TMetafile(obj).Width := Round(PWPDFPageDes(p)^.w * Screen.PixelsPerInch / 72);
              TMetafile(obj).Height := Round(PWPDFPageDes(p)^.h * Screen.PixelsPerInch / 72);

             // TMetafile(obj).MMWidth := Round(PWPDFPageDes(p)^.w * 2540 / 72);
             // TMetafile(obj).MMHeight := Round(PWPDFPageDes(p)^.h * 2540 / 72);

              // TMetafile(obj).Inch := 96;

              can := TMetafileCanvas.Create(TMetafile(obj), 0);
              WPPDF_ProcessPDF(p, nil, 0, can.Handle, Screen.PixelsPerInch);
              can.Free;
              can := nil;
              // TMetafile(obj).MMWidth := Round(PWPDFPageDes(p)^.w/72 * 254);
              // TMetafile(obj).MMHeight := Round(PWPDFPageDes(p)^.h/72 * 254);
              TWPCustomPDFExport(TObject(parent)).ReadPageWidth := Round(PWPDFPageDes(p)^.w * 20);
              TWPCustomPDFExport(TObject(parent)).ReadPageHeight := Round(PWPDFPageDes(p)^.h * 20);
              TWPCustomPDFExport(TObject(parent)).FOnReadInputPDF(TObject(parent),
                PWPDFPageDes(p)^.pageno, '', obj);
            finally
              if can <> nil then can.Free;
              if obj <> nil then obj.Free;
            end // -------------------------------------------------------------
              {$ENDIF}
            else if TWPCustomPDFExport(TObject(parent)).FPDFReadMode = wpdfRetrieveBMP then
              {$IFNDEF PDFIMPORT}
              raise PDFException.Create(PDF_IMP_NOT);
            {$ELSE}
            try
              obj := TBitmap.Create;
              TBitmap(obj).Monochrome := TRUE;
              TBitmap(obj).Width := Round(PWPDFPageDes(p)^.w * TWPCustomPDFExport(TObject(parent)).PDFReadBitmapRes / 72);
              TBitmap(obj).Height := Round(PWPDFPageDes(p)^.h * TWPCustomPDFExport(TObject(parent)).PDFReadBitmapRes / 72);
              WPPDF_ProcessPDF(p, nil, 0, TBitmap(obj).Canvas.Handle, TWPCustomPDFExport(TObject(parent)).PDFReadBitmapRes);
              TWPCustomPDFExport(TObject(parent)).ReadPageWidth := Round(PWPDFPageDes(p)^.w * 20);
              TWPCustomPDFExport(TObject(parent)).ReadPageHeight := Round(PWPDFPageDes(p)^.h * 20);
              TWPCustomPDFExport(TObject(parent)).FOnReadInputPDF(TObject(parent),
                PWPDFPageDes(p)^.pageno, '', obj);
            finally
              if obj <> nil then obj.Free;
            end;
            {$ENDIF}
            if TWPCustomPDFExport(TObject(parent)).FAbort then
              PWPDFPageDes(p)^.Abort := 1;
          end;
          // -------------------------------------------------------------------
        end;
    end;
  end;
end;

constructor TWPCustomPDFExport.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FWatermarks := TStringList.Create;
  FInfo := TWPPDFExportInfo.Create;
  FInfo.FProducer := 'wPDF - http://www.wptools.de';
  FInfo.FDate := Now;
  FInfo.FModDate := Now;
  FPDFReadBitmapRes := 100;

  HeaderFooterColor := clBtnShadow;
  FExcludedFonts := TStringList.Create;
  FDefaultXRes := 72;
  FDefaultYRes := 72;
  {$IFNDEF INTWPSWITCH}DLLOK := TRUE;
  {$ELSE}
  DLLHandle := 0;
  {$ENDIF}
  FModes := [wpClipRectSupport];
end;

// Copy all relevant information except for
// FileName, Stream and 'InMemoryMode'
procedure TWPCustomPDFExport.Assign(Source : TPersistent);
begin
  if Source is TWPCustomPDFExport then
  begin
    // FFilename := TWPCustomPDFExport(Source).FFilename  ;
    // Stream:= TWPCustomPDFExport(Source).FStream  ;
    // FInMemoryMode:= TWPCustomPDFExport(Source).FInMemoryMode  ;
    FInfo.Assign( TWPCustomPDFExport(Source).FInfo)  ;
    FExcludedFonts.Assign( TWPCustomPDFExport(Source).FExcludedFonts ) ;
    FCanvasReference:= TWPCustomPDFExport(Source).FCanvasReference  ;
    FEncodeStreamMethod:= TWPCustomPDFExport(Source). FEncodeStreamMethod ;
    FCompressStreamMethod:= TWPCustomPDFExport(Source).FCompressStreamMethod  ;
    FInputfileMode:= TWPCustomPDFExport(Source).FInputfileMode  ;
    FOnReadWatermarkMeta:= TWPCustomPDFExport(Source).FOnReadWatermarkMeta  ;
    FInputFile:= TWPCustomPDFExport(Source).FInputFile  ;
    FDefaultXRes:= TWPCustomPDFExport(Source).FDefaultXRes  ;
    FDefaultYRes:= TWPCustomPDFExport(Source).FDefaultYRes  ;
    FEncryption:= TWPCustomPDFExport(Source).FEncryption  ;
    FSecurity:= TWPCustomPDFExport(Source).FSecurity  ;
    FModes:= TWPCustomPDFExport(Source).FModes  ;
    FOptions:= TWPCustomPDFExport(Source).FOptions  ;
    FUserPassword:= TWPCustomPDFExport(Source).FUserPassword  ;
    FOwnerPassword:= TWPCustomPDFExport(Source).FOwnerPassword  ;
    FPageMode:= TWPCustomPDFExport(Source).FPageMode  ;
    FZoomMode:= TWPCustomPDFExport(Source).FZoomMode  ;
    FFontMode:= TWPCustomPDFExport(Source).FFontMode  ;
    FCreateThumbnails:= TWPCustomPDFExport(Source).FCreateThumbnails  ;
    FCreateOutlines:= TWPCustomPDFExport(Source).FCreateOutlines  ;
    FAutoLaunch:= TWPCustomPDFExport(Source).FAutoLaunch  ;
    FDebugMode:= TWPCustomPDFExport(Source).FDebugMode  ;
    FDebugWMFPath:= TWPCustomPDFExport(Source).FDebugWMFPath  ;
    FPDFReadMode:= TWPCustomPDFExport(Source).FPDFReadMode  ;
    FJPEGQuality:= TWPCustomPDFExport(Source).FJPEGQuality  ;
    FHeaderFooterColor:= TWPCustomPDFExport(Source).FHeaderFooterColor  ;
    FBeforeBeginDoc := TWPCustomPDFExport(Source).FBeforeBeginDoc  ;
    FAfterBeginDoc:= TWPCustomPDFExport(Source).FAfterBeginDoc  ;
    FBeforeEndDoc:= TWPCustomPDFExport(Source).FBeforeEndDoc  ;
    FAfterEndDoc:= TWPCustomPDFExport(Source).FAfterEndDoc  ;
    FOnError:= TWPCustomPDFExport(Source).FOnError  ;
    FExtraMessages:= TWPCustomPDFExport(Source).FExtraMessages  ;
    FMergeStart := TWPCustomPDFExport(Source).FMergeStart  ;
    FOnMerge := TWPCustomPDFExport(Source).FOnMerge  ;
  end else inherited Assign(Source);
end;

function TWPCustomPDFExport.GetExcludedFonts: TStrings;
begin
  Result := FExcludedFonts;
end;

procedure TWPCustomPDFExport.SetFilename(x : TFileName);
begin
  FFilename := x;
end;

function TWPCustomPDFExport.GetCanvas: TCanvas;
var
  currX, currY: Integer;
  DC: HDC;
begin
  if FCanvas = nil then
  begin
    FMetafile := TMetafile.Create;
    FMetafile.MMWidth := Round(FLastWidth / Fpage_xres * 2540); // 1/100 mm !
    FMetafile.MMHeight := Round(FLastHeight / Fpage_yres * 2540);

   {if FReferenceDC=0 then
    begin
      FMetafile.Width := Round(FLastWidth / Fpage_xres * Screen.PixelsPerInch); // 1/100 mm !
      FMetafile.Height := Round(FLastHeight / Fpage_yres * Screen.PixelsPerInch);
    end else
    begin
      FMetafile.Width := Round(FLastWidth / Fpage_xres *
          GetDeviceCaps(FReferenceDC, LOGPIXELSX)); 
      FMetafile.Height := Round(FLastHeight / Fpage_yres *
          GetDeviceCaps(FReferenceDC, LOGPIXELSY));
    end;  }


    FMetafile.Enhanced := TRUE;
    {$IFDEF WPBITREF}
        if FReferenceDC=0 then
        begin
              if FBitmap=nil then
              begin
               FBitmap := TBitmap.Create;
               FBitmap.Width  := Round(FLastWidth * Screen.PixelsPerInch / Fpage_xres);
               FBitmap.Height := Round(FLastHeight * Screen.PixelsPerInch / Fpage_yres);
              end;
              FCanvas := TMetafileCanvas.Create(FMetafile, FBitmap.Canvas.Handle);
        end else
        FCanvas := TMetafileCanvas.Create(FMetafile, FReferenceDC);
    {$ELSE}
        FCanvas := TMetafileCanvas.Create(FMetafile, FReferenceDC);
    {$ENDIF}

    FCanvas.Font.PixelsPerInch := Fpage_yres;
    FCanvas.Brush.Style := bsClear;
    {$IFNDEF DONT_MOD_LOGRES}
    DC := FCanvas.Handle;
    currX := GetDeviceCaps(DC, LOGPIXELSX);
    currY := GetDeviceCaps(DC, LOGPIXELSY);
    SetMapMode(DC, MM_ANISOTROPIC);
    SetWindowExtEx(DC, Fpage_xres, Fpage_yres, nil);
    SetViewPortExtEx(DC, currX, currY, nil);
    SetViewPortOrgEx(DC, 0, 0, nil);
    SetWindowOrgEx(DC, 0, 0, nil);
    {$ENDIF}
  end;
  Result := FCanvas;
end;

procedure TWPCustomPDFExport.SetExcludedFonts(x: TStrings);
begin
  FExcludedFonts.Assign(x);
end;

procedure TWPCustomPDFExport.SetMergeStart(x : string);
begin
  FMergeStart := x;
  if pdf_env <> nil then
    WPPDF_SetSProp(pdf_env, WPPDF_MERGESTARTTEXT, PChar(FMergeStart));
end;

procedure TWPCustomPDFExport.SetJPEGQuality(x: TWPJPEGQuality);
begin
  FJPEGQuality := x;
  if pdf_env <> nil then
    WPPDF_SetIProp(pdf_env, WPPDF_JPEGCompress, Integer(FJPEGQuality));
end;

procedure TWPCustomPDFExport.SetModes(x: TWPDevModes);
begin
  if (wpNeverHighResPDF in x) and not (wpNeverHighResPDF in FModes) then
     exclude(x, wpAlwaysHighResPDF);
  if wpAlwaysHighResPDF in x then exclude(x, wpNeverHighResPDF);
  FModes := x;
  if pdf_env <> nil then
  begin
    WPPDF_SetIProp(pdf_env, WPPDF_DevModes, Integer(PInteger(@x)^));
  end;
end;

procedure TWPCustomPDFExport.SetOptions(x: TWPDFOptions);
begin
  FOptions := x;
  if pdf_env <> nil then
  begin
    WPPDF_SetIProp(pdf_env, WPPDF_PDFOptions, Integer(PInteger(@x)^));
  end;
end;



procedure TWPCustomPDFExport.SetInfo(x: TWPPDFExportInfo);
begin
  FInfo.Assign(x);
end;

procedure TWPCustomPDFExport.SetDLLName(x: string);
begin
  if FGLDLLName <> x then
  begin
    {$IFDEF INTWPSWITCH}
    if FDLLInUSE > 0 then raise PDFException.Create('DLL is in use. Cannot unload it');
    if DLLOK then UnloadDLL;
    {$ENDIF}
    FGLDLLName := x;
  end;
end;

function TWPCustomPDFExport.GetDLLName: string;
begin
  Result := FGLDLLName;
end;

procedure  TWPCustomPDFExport.SetPrinting(x : Boolean);
begin
  if x<>FPrinting then
  begin
     if X THEN BeginDoc else EndDoc;
  end;
end;

destructor TWPCustomPDFExport.Destroy;
begin
  UpdateReferenceCanvas(false);
  FWatermarks.Free;
  FExcludedFonts.Free;
  FInfo.Free;
  if DLLOK and (pdf_env <> nil) then
  begin
    WPPDF_Finalize(pdf_env);
  end;
  if FCanvas <> nil then FCanvas.Free;
  if FMetafile <> nil then FMetafile.Free;
  if FBitmap<>nil then FBitmap.Free;
  FBitmap := nil;
  FCanvas := nil;
  FMetafile := nil;
  {$IFDEF INTWPSWITCH}UnLoadDLL; {$ENDIF}
  inherited Destroy;
end;

procedure TWPCustomPDFExport.PreparePage(pageno: Integer; var init: TWPPDF_InitRec; ResX, ResY: Integer);
begin
  FStartPageAtOnce := FALSE;
end;

// -----------------------------------------------------------------------------

procedure TWPCustomPDFExport.BeginDoc;
var
  only_to_file: PChar;
  init: TWPPDF_InitRec;
  function PDFDate(val: TDateTime): string;
  var
    Year, Month, Day: Word;
    Hour, Min, Sec, MSec: Word;
  begin
    DecodeDate(val, Year, Month, Day);
    DecodeTime(val, Hour, Min, Sec, MSec);
    Result := Format('D:%d%.2d%.2d%.2d%.2d%.2d', [Year, Month, Day, Hour, Min, Sec]);
  end;
begin
  FLastError := 0;
  FInputPageCount := 0;
  Fpage_xres := FDefaultXRes;
  Fpage_yres := FDefaultYRes;
  // Check parameters
  if (FFilename = '') and not InMemoryMode and (PDFReadMode = wpdfStandard) then
    raise PDFException.Create('No filename or InMemoryMode was specified!');
  // ok, now start printing
  if not FPrinting then
  begin
    {$IFDEF INTWPSWITCH}
    LoadDLL(FGLDLLName);
    {$ENDIF}
    if DLLOK and (pdf_env <> nil) then
    begin
      try
        WPPDF_Finalize(pdf_env);
      finally
        pdf_env := nil;
      end;
    end;

    if DLLOK and (pdf_env = nil) then
    begin
      pdf_env := WPPDF_Initialize(FSizeAttr, FSizeParagraph, FSizeLine, 1, WPPDF_CallBack,
        Pointer(Self));
      if pdf_env = nil then raise PDFException.Create('Initialization of PDF Engine failed');
    end;

    // Update Gauge
    if FPageCount <> 0 then FInternPageCount := FPageCount;
    FInternPageNumber := 0;
    FWatermarks.Clear;
    if assigned(FOnUpdateGauge) then
      FOnUpdateGauge(Self, 0);
    // Open Stream ....
    if (FStream = nil) and not FInMemoryMode then
      only_to_file := PChar(FFilename)
    else
      only_to_file := nil;
    // Last chance to set properties
    if assigned(FBeforeBeginDoc) then FBeforeBeginDoc(Self);
    // Transfer the integer properties to the Engine
    WPPDF_SetIProp(pdf_env, WPPDF_ENCODE, Integer(FEncodeStreamMethod));
    WPPDF_SetIProp(pdf_env, WPPDF_COMPRESSION, Integer(FCompressStreamMethod));
    WPPDF_SetIProp(pdf_env, WPPDF_PAGEMODE, Integer(FPageMode));
    WPPDF_SetIProp(pdf_env, WPPDF_ZOOMMODE, Integer(FZoomMode));
    WPPDF_SetIProp(pdf_env, WPPDF_USEFONTMODE, Integer(FFontMode));
    WPPDF_SetIProp(pdf_env, WPPDF_ConvertJPEGData, Integer(FConvertJPEGData));
    WPPDF_SetIProp(pdf_env, WPPDF_Encryption, PByte(@FEncryption)^);
    WPPDF_SetIProp(pdf_env, WPPDF_Security, PByte(@FSecurity)^);
    WPPDF_SetIProp(pdf_env, WPPDF_JPEGCompress, Integer(FJPEGQuality));
    WPPDF_SetIProp(pdf_env, WPPDF_UseThumbNails, Integer(FCreateThumbnails));
    WPPDF_SetIProp(pdf_env, WPPDF_DevModes, Integer(PInteger(@FModes)^));
    WPPDF_SetIProp(pdf_env, WPPDF_PDFOptions, Integer(PInteger(@FOptions)^));

    WPPDF_SetIProp(pdf_env, WPPDF_ReadPDFMode, Integer(FPDFReadMode)); // obsolete!
    if FPDFReadMode <> wpdfStandard then // We don't write PDF anyway!
      WPPDF_SetIProp(pdf_env, WPPDF_InputFileMode, Integer(wpConvertInputToWatermark))
    else
      WPPDF_SetIProp(pdf_env, WPPDF_InputFileMode, Integer(FInputFileMode));

    // extra messages
    WPPDF_SetIProp(pdf_env, WPPDF_MsgEmbedFont, Integer(wpOnEmbedFonts in FExtraMessages));
    // Transfer the string properties to the Engine
    WPPDF_SetSProp(pdf_env, WPPDF_Author, PChar(FInfo.FAuthor));
    WPPDF_SetSProp(pdf_env, WPPDF_Date, PChar(PDFDate(FInfo.FDate)));
    WPPDF_SetSProp(pdf_env, WPPDF_ModDate, PChar(PDFDate(FInfo.FModDate)));
    WPPDF_SetSProp(pdf_env, WPPDF_Producer, PChar(FInfo.FProducer));
    WPPDF_SetSProp(pdf_env, WPPDF_Title, PChar(FInfo.FTitle));
    WPPDF_SetSProp(pdf_env, WPPDF_Subject, PChar(FInfo.FSubject));
    WPPDF_SetSProp(pdf_env, WPPDF_Keywords, PChar(FInfo.FKeywords));
    WPPDF_SetSProp(pdf_env, WPPDF_ExcludedFonts, PChar(FExcludedFonts.CommaText));
    WPPDF_SetSProp(pdf_env, WPPDF_UserPassword, PChar(FUserPassword));
    WPPDF_SetSProp(pdf_env, WPPDF_OwnerPassword, PChar(FOwnerPassword));
    WPPDF_SetSProp(pdf_env, WPPDF_InputFile, PChar(FInputFile));
    WPPDF_SetSProp(pdf_env, WPPDF_MERGESTARTTEXT, PChar(FMergeStart));

    if FInfo.FAdditionalStrings.Count>0 then
       WPPDF_SetSProp(pdf_env, WPPDF_OtherInfoTexts, PChar(FInfo.FAdditionalStrings.Text));

    // -------------------------------------------------------------------------
    {$IFNDEF WPDFDEMOV}
    WPPDF_SetSProp(pdf_env, 1000, PChar(FLicName));
    WPPDF_SetSProp(pdf_env, 1001, PChar(FLicCode));
    {$ENDIF}
    // StartDOC ! --------------------------------------------------------------
    WPPDF_SetIProp(pdf_env, WPPDF_EngineVersion, 200); // Version 200
    if WPPDF_Action(pdf_env, WPPDF_BEGINDOC, 0, only_to_file) = 0 then
    begin
      FAbort := FALSE;
      fillchar(init, SizeOf(init), 0);
      PreparePage(-1, init, FDefaultXRes, FDefaultYRes);
      init.specialcolor := FHeaderFooterColor;
      init.thumbnails := CreateThumbnails;
      FPrinting := TRUE;
      inc(FDLLInUSE);
      // Create Reference DC
      UpdateReferenceCanvas(true);
      // --------- first chance to modify the file -----------------------------
      if assigned(FAfterBeginDoc) then
      begin
          FAfterBeginDoc(Self);
      end;
      // -----------------------------------------------------------------------
      if FStartPageAtOnce then
        {$IFNDEF VERSION1COMPAT}WPPDF_InitializePage(pdf_env, 0, @init)
        {$ELSE}WPPDF_StartWPTPage(pdf_env, 0, @init){$ENDIF};
    end
    else
    begin
      FLastError := 1;
      raise PDFException.Create('Error in BeginDoc!');
    end;
  end;
end;

function TWPCustomPDFExport.InternEngineCommand(ID : Integer; const Command : String) : Integer;
begin
  Result := -1;
  if (pdf_env<>nil) {$IFDEF INTWPSWITCH} and assigned(WPPDF_Action) {$ENDIF} then
  begin
     Result := WPPDF_Action(pdf_env, ID, 0, PChar(Command));
  end;
end;


procedure TWPCustomPDFExport.UpdateReferenceCanvas(start: Boolean);
var
  ADevice, ADriver, APort: array[0..128] of char;
  ADeviceMode: THandle;
  {$IFDEF USECompatibleDC} ScreenDC : HDC; {$ENDIF}
begin
  // Release DC ------------------------------------------------------------
  if FReferenceDC <> 0 then
  begin
      DeleteDC(FReferenceDC);
      FReferenceDC := 0;
  end;

  // Open DC ---------------------------------------------------------------
  if start then
  try
    if FReferenceDC <> 0 then
    begin
      DeleteDC(FReferenceDC);
      FReferenceDC := 0;
    end;
    if (FCanvasReference = wprefPrinter) and (Printer.Printers.Count > 0) then
    begin
      Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
      if ADevice <> '' then
        FReferenceDC := CreateDC(ADriver, ADevice, nil, nil)
      else
        FReferenceDC := CreateDC(ADriver, nil, nil, nil);
    end
    {$IFDEF WPAPPLICATIONREF}
    else
    begin
       FReferenceDC := GetDC(Application.Handle);
       SelectClipRgn(FReferenceDC,0);
    end;
    {$ENDIF}
    {$IFDEF USECompatibleDC}
    else
    try
      ScreenDC := GetDC(0);
      FReferenceDC := CreateCompatibleDC(ScreenDC);
    finally
      ReleaseDC(0,ScreenDC);
    end {$ENDIF};
  except
    // Printer error
  end;
end;

procedure TWPCustomPDFExport.StartWatermark(const Name: string; pagew, pageh, xres, yres: Integer);
var
  o: Boolean;
begin
  if FPrinting then
  begin
    o := FStartPageAtOnce;
    FStartPageAtOnce := FALSE;
    try
      InternStartPage(false, Name, pagew, pageh, xres, yres, 0);
    finally
      FStartPageAtOnce := o;
    end;
  end;
end;

procedure TWPCustomPDFExport.EndWatermark;
begin
  if FPrinting then
  begin
    if FCanvas <> nil then
    begin
      FCanvas.Free;
      FCanvas := nil;
      if FMetafile <> nil then
      try
        DrawMetafile(0, 0, FMetafile.Handle);
      except
      end;
    end;
    FMetafile.Free;
    FMetafile := nil;
    WPPDF_Action(pdf_env, WPPDF_ENDXFORM, 0, nil);
  end;
end;

procedure TWPCustomPDFExport.UsePDFWatermark(InputPageNo: Integer);
begin
  if (InputPageNo > 0) and (InputPageNo <= InputPageCount) then
    UseWatermark('inpage' + IntToStr(InputPageNo));
end;

procedure TWPCustomPDFExport.UseWatermark(const Name: string);
begin
  UseXForm(Name, 0, 0, FLastWidth, FLastHeight);
end;

procedure TWPCustomPDFExport.UseWatermarkEx(const Name: string;
  Width, Height: Integer; Angle: Integer);
begin
  if Width = 0 then Width := FLastWidth;
  if Height = 0 then Height := FLastHeight;
  UseXFormEx(Name, 0, 0, Width, Height, Angle);
end;

procedure TWPCustomPDFExport.UseXForm(const Name: string; x, y, w, h: Integer);
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
    link.x := x;
    link.y := y;
    link.w := w;
    link.h := h;
    StrPLCopy(link.caption, Name, 255);
    WPPDF_Action(pdf_env, WPPDF_USEXFORM, 0, @link);
  end;
end;

procedure TWPCustomPDFExport.UseXFormEx(const Name: string; x, y, w, h, angle: Integer);
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
    link.x := x;
    link.y := y;
    link.w := w;
    link.h := h;
    link.destmode := angle;
    StrPLCopy(link.caption, Name, 255);
    WPPDF_Action(pdf_env, WPPDF_USEXFORM, 0, @link);
  end;
end;

procedure TWPCustomPDFExport.StartPage(pagew, pageh, xres, yres, rotation: Integer);
var
  b: Boolean;
begin
  b := FStartPageAtOnce;
  try
    FStartPageAtOnce := FALSE;
    FLastWidth := pagew;
    FLastHeight := pageh;
    Fpage_xres := xres;
    Fpage_yres := yres;
    // if rotation=1 we use it as 90 degree
    InternStartPage(true, '', pagew, pageh, xres, yres, rotation);
  finally
    FStartPageAtOnce := b;
  end;
end;

function TWPCustomPDFExport.PrepareWatermark(pagew, pageh, xres, yres: Integer): string;
var
  meta: DWORD;
  metaname: string;
  n: Integer;
  ometa: TMetafile;
begin
  metaname := '';
  Result := '';
  if assigned(FOnReadWatermarkMeta) then
  begin
    meta := 0;
    FOnReadWatermarkMeta(Self, FInternPageNumber + 1, meta, metaname);
    if (meta <> 0) then
      n := FWatermarks.IndexOf(IntToStr(meta))
    else if metaname <> '' then
      n := FWatermarks.IndexOf(metaname)
    else
      n := -2;
    if n >= 0 then
      Result := 'XWPT' + IntToStr(n)
    else if n = -1 then
    begin
      Result := 'XWPT' + IntToStr(FWatermarks.Count);
      try
        StartWatermark(Result, pagew, pageh, xres, yres);
        if meta <> 0 then
        begin
          DrawMetafile(0, 0, meta);
          FWatermarks.Add(IntToStr(meta));
        end
        else
        begin
          ometa := TMetafile.Create;
          try
            ometa.LoadFromFile(metaname);
            // Canvas.StretchDraw(Rect(0,0,ometa.Width,ometa.Height),ometa);
            DrawMetafile(0, 0, ometa.Handle);
            FWatermarks.Add(metaname);
            ometa.Free;
          except
            ometa.Free;
            Result := '';
          end;
        end;
      finally
        EndWatermark;
      end;
    end;
  end;
end;

procedure TWPCustomPDFExport.InternStartPage(aPage: Boolean; const aName: string; pagew, pageh,
  xres, yres, options: Integer);
var
  link: TWPPDF_LinkDef;
  usewater: string;
begin
  if not FPrinting then
    raise PDFException.Create('StartPage is only allowed within StartDoc and EndDoc!');
  // ------------- PrepareWatermark ----------------------------------------------
  if aPage then
    usewater := PrepareWatermark(pagew, pageh, xres, yres)
  else
    usewater := '';
  // -----------------------------------------------------------------------------
  FPageIsOpen := TRUE;
  if xres = 0 then xres := 72;
  if yres = 0 then yres := 72;
  Fpage_xres := xres;
  Fpage_yres := yres;

  if not FStartPageAtOnce then
  begin
    if not FKeepInitValues then
    begin
      FillChar(Finit, SizeOf(Finit), 0);
      Finit.pagew := pagew; // NO!!!  MulDiv(pagew, 1440, xres); // Convert into TWIPS !
      Finit.pageh := pageh; // MulDiv(pageh, 1440, yres); // Convert into TWIPS !
      Finit.xres := xres;
      Finit.yres := yres;
      Finit.rotation := options;
      Finit.specialcolor := FHeaderFooterColor;
      Finit.thumbnails := CreateThumbnails;
    end;
    {$IFNDEF VERSION1COMPAT}WPPDF_InitializePage{$ELSE}WPPDF_StartWPTPage{$ENDIF}(pdf_env, 0, @Finit);
    if aPage then
    begin
      inc(FInternPageNumber);
      WPPDF_Action(pdf_env, WPPDF_STARTPAGE, 0, nil);
      // Automatic used as watermark (super for letterheads!)
      if (InputPageCount > 0) and (FInputFileMode = wpUseInputAsWatermark) then
      begin
        if FInternPageNumber < InputPageCount then
          UseWatermark('inpage' + IntToStr(FInternPageNumber))
        else
          UseWatermark('inpage' + IntToStr(InputPageCount));
      end;
    end
    else
    begin
      FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
      link.w := pagew;
      link.h := pageh;
      StrPLCopy(link.caption, aName, 255);
      WPPDF_Action(pdf_env, WPPDF_STARTXFORM, 0, @link);
    end;
  end;
  if FCanvas <> nil then FCanvas.Free;
  FCanvas := nil;
  if FMetafile <> nil then FMetafile.Free;
  FMetafile := nil;
  if usewater <> '' then
    UseWatermark(usewater);
end;

// Writes the Canvas to the PDF file

procedure TWPCustomPDFExport.CloseCanvas;
var
  DrawCanvasMetaXRes, DrawCanvasMetaYRes: Integer;
begin
  if FCanvas <> nil then
  begin
    // DrawCanvasMetaXRes := 0;
    // DrawCanvasMetaYRes := 0;
    DrawCanvasMetaXRes := GetDeviceCaps(FCanvas.Handle, LOGPIXELSX);
    DrawCanvasMetaYRes := GetDeviceCaps(FCanvas.Handle, LOGPIXELSY);
    FCanvas.Free;
    FCanvas := nil;
    if FMetafile <> nil then
    try
      FDrawCanvasMeta := TRUE;
      DrawMetafileEX(0, 0, 0, 0, FMetafile.Handle, DrawCanvasMetaXRes, DrawCanvasMetaYRes);
    finally
      FDrawCanvasMeta := FALSE;
    end;
  end;
  FMetafile.Free;
  FMetafile := nil;
end;

procedure TWPCustomPDFExport.EndPage;
begin
  try
    CloseCanvas;
  finally
    FPageIsOpen := FALSE;
    WPPDF_Action(pdf_env, WPPDF_ENDPAGE, 0, nil);
  end;
end;

// -----------------------------------------------------------------------------

procedure TWPCustomPDFExport.EndDoc;
var
  FAllOK, showfile: Boolean;
  size: Integer;
  mem: PChar;
begin
  FAllOK := FALSE;
  if FPrinting and (pdf_env <> nil) then
  try
    // Last Chance to modify the PDF file --------------------------------------
    if assigned(FBeforeEndDoc) then
    begin
        FBeforeEndDoc(Self);
    end;
    // -------------------------------------------------------------------------
    WPPDF_Action(pdf_env, WPPDF_ENDDOC, 0, nil);
    // -------------------------------------------------------------------------
    UpdateReferenceCanvas(false);
    // -------------------------------------------------------------------------
    if (FStream <> nil) and (FPDFReadMode = wpdfStandard) then
    begin
      size := WPPDF_Action(pdf_env, WPPDF_GETBUF, 0, nil);
      if FStream is TMemoryStream then
      begin
        TMemoryStream(FStream).Clear;
        TMemoryStream(FStream).SetSize(size);
        WPPDF_Action(pdf_env, WPPDF_GETBUF, TMemoryStream(FStream).Size, TMemoryStream(FStream).Memory);
      end
      else
      begin
        GetMem(mem, size);
        try
          WPPDF_Action(pdf_env, WPPDF_GETBUF, size, mem);
          FStream.Write(mem^, size);
        finally
          FreeMem(mem);
        end;
      end;
    end;
    if (FFileName <> '') and (FPDFReadMode = wpdfStandard) then
    begin
      WPPDF_Action(pdf_env, WPPDF_WRITEFILE, 0, PChar(FFileName))
    end;
    FAllOK := TRUE;
  finally
    WPPDF_Action(pdf_env, WPPDF_FINISH, 0, nil);
    FPrinting := FALSE;
    dec(FDLLInUSE);
    if FCanvas <> nil then FCanvas.Free;
    if FMetafile <> nil then FMetafile.Free;
    if FBitmap<>nil then
    begin
      FBitmap.Free;
      FBitmap := nil;
    end;
    FCanvas := nil;
    FMetafile := nil;
    if DLLOK and (pdf_env <> nil) then
    begin
      try
        WPPDF_Finalize(pdf_env);
      finally
        pdf_env := nil;
      end;
    end;
    // Set to default again
    FDefaultXRes := 72;
    FDefaultYRes := 72;
    // -------------------------------------------------------------------------
    if assigned(FAfterEndDoc) and (pdf_env <> nil) then
    begin
      // It is too late to modify the PDF file !
      FAfterEndDoc(Self);
    end;
    // -------------------------------------------------------------------------
    if FAllOK and (FPDFReadMode = wpdfStandard) then
    begin
      showfile := FAutoLaunch;
      // ------------------------------------------------------------------------
      if Assigned(WPAfterPDFCreation) then
         WPAfterPDFCreation(Self,FileName,showfile);
      // ------------------------------------------------------------------------
      if showfile and (FFileName <> '') then
         ShellExecute(0, 'open', PChar(FFileName), nil, nil, SW_SHOWNORMAL);
      // ------------------------------------------------------------------------
    end;
  end;
end;

const
  WPDEFRES = 300;

  // -----------------------------------------------------------------------------

procedure TWPCustomPDFExport.DrawMetafile(x, y: Integer; meta: HENHMETAFILE);
begin
  DrawMetafileEx(x, y, 0, 0, meta, 0, 0);
end;

procedure TWPCustomPDFExport.DrawMetafileEx(x, y, w, h: Integer; meta: HENHMETAFILE; DrawCanvasMetaXRes, DrawCanvasMetaYRes: Integer);
var
  link: TWPPDF_LinkDef;
  s: string;
  emf : HMETAFILE;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
    link.x := x;
    link.y := y;
    link.w := w;
    link.h := h;
    link.destmode := DrawCanvasMetaXRes; // XRES
    link.destzoom := DrawCanvasMetaYRes; // YRES
    WPPDF_Action(pdf_env, WPPDF_ENHMETAFILE, meta, @link);
    // ----------- create a metafile to avoid problem
   { s := FileName + '.EMF' + IntToStr(FInternPageNumber);
    try
        emf := CopyEnhMetaFile(meta, PChar(s));
        // DeleteEnhMetaFile(emf);
    finally
        DeleteFile(s);
    end;  }
    // ----------- Just debug code ---------------------------------------------
    if FDebugMode then
    begin
      if FDebugWMFPath <> '' then
        s := FDebugWMFPath
      else
        s := ExtractFilePath(Application.EXEName) + '\Debug';
      ForceDirectories(s);
      s := s + '\Page' + IntToStr(FInternPageNumber) + '.EMF';
      try
        emf := CopyEnhMetaFile(meta, PChar(s));
        if assigned(FOnError) then
          FOnError(Self, 0, 'Wrote debug file:' + s);
        DeleteEnhMetaFile(emf);
      except
        if assigned(FOnError) then
          FOnError(Self, 0, 'Problem while writing debug file:' + s);
      end;
    end;
  end;
end;
// -----------------------------------------------------------------------------

// Uses the current resolution

function TWPCustomPDFExport.InternDrawBitmap(x, y, w, h: Integer; var bitdef: TWPGraphicDef): Integer;
begin
  if FPrinting then
  begin
    bitdef.x := x;
    bitdef.y := y;
    bitdef.w := w;
    bitdef.h := h;
    WPPDF_Action(pdf_env, WPPDF_EXBITMAP, 0, @bitdef);
  end;
  Result := bitdef.BitmapID;
end;

function TWPCustomPDFExport.DrawBitmap(x, y, w, h: Integer; handle: HBITMAP): Integer;
var
  bitdef: TWPGraphicDef;
begin
  FillChar(bitdef, SizeOf(TWPGraphicDef), 0);
  bitdef.BitmapHandle := handle;
  Result := InternDrawBitmap(x, y, w, h, bitdef);
end;

function TWPCustomPDFExport.DrawDIBBitmap(x, y, w, h: Integer; BitmapInfo: PBitmapInfo; BitmapBits: Pointer): Integer;
var
  bitdef: TWPGraphicDef;
begin
  FillChar(bitdef, SizeOf(TWPGraphicDef), 0);
  bitdef.BitmapInfo := BitmapInfo;
  bitdef.BitmapBits := BitmapBits;
  Result := InternDrawBitmap(x, y, w, h, bitdef)
end;

function TWPCustomPDFExport.DrawBitmapClone(x, y, w, h: Integer; LastBitmapID: Integer): Integer;
var
  bitdef: TWPGraphicDef;
begin
  FillChar(bitdef, SizeOf(TWPGraphicDef), 0);
  bitdef.BitmapID := LastBitmapID;
  WPPDF_Action(pdf_env, WPPDF_EXBITMAP, 0, @bitdef);
  Result := InternDrawBitmap(x, y, w, h, bitdef);
end;

procedure TWPCustomPDFExport.EnlargeFontWidth(percent: Integer);
begin
  WPPDF_SetIProp(pdf_env, WPPDF_FontWidthMult, percent);
end;

// -----------------------------------------------------------------------------


procedure TWPCustomPDFExport.InitDC;
begin
  WPPDF_Action(pdf_env, WPPDF_InitDC, 0, nil);
end;

procedure TWPCustomPDFExport.DrawRotatedText(const Text : String;
      Angle, Left, Top, Width, Height : Integer;
      Alignment : TAlignment;
      const Font  : TFont);
var
  FCanvas : TCanvas;
  oldfont, newfont : HFONT;
  siz : TSize;
  x,y : Integer;
  a, w, h, radius : Double;
begin
  FCanvas := Canvas;
  newfont := CreateFont(Font.Height,0,Angle*10,0,
    Ord(fsBold in Font.Style),
    Ord(fsItalic in Font.Style),
    Ord(fsUnderline in Font.Style),
    Ord(fsStrikeOut in Font.Style),
    Font.Charset,
    0,0,0,0,
    PChar(Font.Name) );
  if newfont<>0 then
  begin
    oldfont := SelectObject(FCanvas.Handle,newfont);
    GetTextExtentPoint(FCanvas.Handle,PChar(Text),Length(Text),siz);
    if (Alignment<>taLeftJustify) and (Width<>0) and (Height<>0) then
    begin
      w := Width - siz.cx;
      if Height>0 then
           h := (Height - siz.cy) / 2
      else h := 0;
      if Alignment=taCenter then  w := w / 2;
      a  := Angle / 180 * pi;
      radius := sqrt(w*w + h*h);
      x := Round(cos(a) * radius);
      y := Round(sin(a) * radius);
    end else
    begin
      x := 0;
      if Height>0 then y := (Height - siz.cy) div 2
      else y := 0;
    end;
    TextOut(FCanvas.Handle,Left+x,Top+y,PChar(Text),Length(Text));
    SelectObject(FCanvas.Handle,oldfont);
    DeleteObject(newfont);
  end;
end;

function TWPCustomPDFExport.DrawJPEG(x, y, w, h, SourceW,
  SourceH: Integer; Buffer: PChar; BufLen: Integer;
  ColorMode : TWPJPEGColorMode = wpRGBjpeg): Integer;
var
  bitdef: TWPGraphicDef;
begin
  if BufLen > 0 then
  begin
    FillChar(bitdef, SizeOf(TWPGraphicDef), 0);
    bitdef.StreamData := Buffer;
    bitdef.StreamLen := BufLen;
    case ColorMode of
       wpRGBjpeg:   bitdef.StreamMode := 2;
       wpGrayjpeg:  bitdef.StreamMode := 7;
       wpCMYKjpeg:   bitdef.StreamMode := 6;
    end;
    bitdef.x := x; // print size
    bitdef.y := y;
    bitdef.w := w;
    bitdef.h := h;
    bitdef.StreamW := SourceW; // source size
    bitdef.StreamH := SourceH;
    WPPDF_Action(pdf_env, WPPDF_EXBITMAP, 0, @bitdef);
    Result := bitdef.BitmapID;
  end
  else
    Result := -1;
end;

function TWPCustomPDFExport.DrawCCITT(x, y, w, h, SourceColumns, SourceRows: Integer; mode : TWPCCITTMode; Buffer: PChar; BufLen: Integer): Integer;
var
  bitdef: TWPGraphicDef;
begin
  if BufLen > 0 then
  begin
    FillChar(bitdef, SizeOf(TWPGraphicDef), 0);
    bitdef.StreamData := Buffer;
    bitdef.StreamLen := BufLen;
    bitdef.StreamMode := 3 + Integer(mode); // CCITT Mode
    bitdef.x := x; // print size
    bitdef.y := y;
    bitdef.w := w;
    bitdef.h := h;
    bitdef.StreamW := SourceColumns; // source size
    bitdef.StreamH := SourceRows;
    WPPDF_Action(pdf_env, WPPDF_EXBITMAP, 0, @bitdef);
    Result := bitdef.BitmapID;
  end
  else
    Result := -1;
end;

function TWPCustomPDFExport.DrawTGraphic(x, y, w, h: Integer; Graphic: TGraphic): Integer;

{$IFDEF JPEGDATA}
var temp: TMemoryStream;
 {$ENDIF}
 var
  inch : Integer;
{ meta : TMetafile;
 res : Integer;
 metacanvas : TMetafileCanvas;  }
begin
  Result := -1;
  if Graphic <> nil then
  begin
    if Graphic is TMetafile then
    begin
      // Enhanced = false but still converted to EMF!
      if (TMetafile(Graphic).Enhanced = false) and (w=0) and (h=0) then
      begin
      {   meta := TMetafile.Create;
         meta.Enhanced := TRUE;
         meta.MMWidth := TMetafile(Graphic).MMWidth;
         meta.MMHeight := TMetafile(Graphic).MMHeight;
         metacanvas := TMetafileCanvas.Create(meta,0);
         res := Screen.PixelsPerInch;
         metacanvas.StretchDraw( Rect(0,0,MulDiv(TMetafile(Graphic).MMWidth,res,2540),
            MulDiv(TMetafile(Graphic).MMHeight,res,2540)),  TMetafile(Graphic));
         metacanvas.Free;
         try
            DrawMetafileEx(x,y,w,h,meta.Handle,res,res);
         finally
            meta.Free;
         end;}
         inch := 0; //NO TMetafile(Graphic).Inch;
         DrawMetafileEx(x, y,
            MulDiv(TMetafile(Graphic).MMWidth,Fpage_xres,2540),
            MulDiv(TMetafile(Graphic).MMHeight,Fpage_yres,2540),
            TMetafile(Graphic).Handle, inch,inch);
      end
      else
         DrawMetafileEx(x, y, w, h, TMetafile(Graphic).Handle, 0, 0);
    end
    else if Graphic is TBitmap then
      Result := DrawBitmap(x, y, w, h, TBitmap(Graphic).Handle)
        {$IFDEF JPEGDATA}
    else if Graphic is TJPEGImage then
    begin
      if not TJPEGImage(Graphic).Empty then
      begin
        temp := TMemoryStream.Create;
        try
          TJPEGImage(Graphic).SaveToStream(temp);
          Result := DrawJPEG(x, y, w, h, TJPEGImage(Graphic).Width, TJPEGImage(Graphic).Height, temp.Memory, temp.Size);
        finally
          temp.Free;
        end;
      end;
    end
      {$ENDIF}
    else
      raise PDFException.Create('Cannot convert ' + Graphic.ClassName);
  end;
end;

function TWPCustomPDFExport.DrawGraphicFile(x, y, w, h: Integer; const FileName: string): Integer;
var
  Picture : TPicture;
begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(FileName);
    Result := DrawTGraphic(x, y, w, h, Picture.Graphic);
  finally
    Picture.Free;
  end;
end;

// Not enabled in all versions !

procedure TWPCustomPDFExport.Command(const s: string; val: DWORD);
begin
  if FPrinting then
  begin
    WPPDF_Action(pdf_env, WPPDF_COMMAND, val, PChar(s));
  end;
end;

procedure TWPCustomPDFExport.SetBookmark(const BookMarkName: string; x, y: Integer);
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
    link.x := x; // WPPDF_XPOS(wpdf_current_env, x);
    link.y := y; // WPPDF_YPOS(wpdf_current_env, y);
    StrPLCopy(link.destname, BookMarkName, 255);
    WPPDF_Action(pdf_env, WPPDF_SETNAME, 0, @link);
  end;
end;

procedure TWPCustomPDFExport.SetLinkArea(const BookMarkName: string; r: TRect);
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
    link.x := r.Left; // WPPDF_XPOS(wpdf_current_env, r.Left);
    link.y := r.Top; // WPPDF_YPOS(wpdf_current_env, r.Top);
    link.w := r.Right - r.Left; // WPPDF_XPOS(wpdf_current_env, r.Right) - link.x;
    link.h := r.Bottom - r.Top; // WPPDF_YPOS(wpdf_current_env, r.Bottom) - link.y;
    StrPLCopy(link.destname, BookMarkName, 255);
    WPPDF_Action(pdf_env, WPPDF_SETLINK, 0, @link);
  end;
end;

procedure TWPCustomPDFExport.SetOutlineCharset(CharSet: Integer);
begin
  WPPDF_SetIProp(pdf_env, WPPDF_OutlineCharset, Integer(CharSet));
end;

function TWPCustomPDFExport.SetOutlineXY(const Caption: string; x, y: Integer; aPrevious, aParent:
  Integer): Integer;
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(link), 0);
    link.x := x; // WPPDF_XPOS(wpdf_current_env, x);
    link.y := y; // WPPDF_YPOS(wpdf_current_env, y);
    if aParent = 0 then
    begin
      link.levelmode := WPOut_SetAsNext;
      link.level := aPrevious;
    end
    else
    begin
      link.levelmode := WPOut_SetAsChild;
      link.level := aParent;
    end;
    StrPLCopy(link.Caption, Caption, 255);
    Result := WPPDF_Action(pdf_env, WPPDF_SETOUTLINE, 0, @link);
  end
  else
    Result := 0;
end;

function TWPCustomPDFExport.SetOutline(const Caption, BookMarkName: string; aPrevious, aParent:
  Integer): Integer;
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(link), 0);
    link.x := 0;
    link.y := 0;
    if aPrevious <> 0 then
    begin
      link.levelmode := WPOut_SetAsNext;
      link.level := aPrevious;
    end
    else
    begin
      link.levelmode := WPOut_SetAsChild;
      link.level := aParent;
    end;
    StrPLCopy(link.Caption, Caption, 255);
    StrPLCopy(link.destname, BookMarkName, 255);
    Result := WPPDF_Action(pdf_env, WPPDF_SETOUTLINE, 0, @link);
  end
  else
    Result := 0;
end;

{$IFNDEF VER90}
function TWPCustomPDFExport.SetOutlineXYW(const pCaption: PWideString; x, y: Integer; aPrevious, aParent:
  Integer): Integer;
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(link), 0);
    link.x := x; // WPPDF_XPOS(wpdf_current_env, x);
    link.y := y; // WPPDF_YPOS(wpdf_current_env, y);
    if aParent = 0 then
    begin
      link.levelmode := WPOut_SetAsNext;
      link.level := aPrevious;
    end
    else
    begin
      link.levelmode := WPOut_SetAsChild;
      link.level := aParent;
    end;
    // StrPLCopy(link.Caption, StrPas(pCaption), 255); // For compatibility to wPDF <V1.31
    link.custom_action := Pointer(pCaption);
    link.Mode := 2;
    Result := WPPDF_Action(pdf_env, WPPDF_SETOUTLINE, 0, @link);
  end
  else
    Result := 0;
end;

function TWPCustomPDFExport.SetOutlineW(const Caption, BookMarkName: WideString; aPrevious, aParent:
  Integer): Integer;
var
  link: TWPPDF_LinkDef;
begin
  if FPrinting then
  begin
    FillChar(link, SizeOf(link), 0);
    link.x := 0;
    link.y := 0;
    if aPrevious <> 0 then
    begin
      link.levelmode := WPOut_SetAsNext;
      link.level := aPrevious;
    end
    else
    begin
      link.levelmode := WPOut_SetAsChild;
      link.level := aParent;
    end;
    StrPLCopy(link.Caption, Caption, 255); // For compatibility to wPDF <V1.31
    link.custom_action := Pointer(PWideChar(Caption));
    link.Mode := 2;
    StrPLCopy(link.destname, BookMarkName, 255);
    Result := WPPDF_Action(pdf_env, WPPDF_SETOUTLINE, 0, @link);
  end
  else
    Result := 0;
end;
{$ENDIF}

// -----------------------------------------------------------------------------

procedure TWPCustomPDFExport.Abort;
begin
  FAbort := TRUE;
end;

{$IFDEF PDFIMPORT}
// -----------------------------------------------------------------------------
// TWPDFPagesImport  - will be removed from Version 2
// -----------------------------------------------------------------------------

constructor TWPDFPagesImport.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FPages := TList.Create;
  FBitmapResolution := 200;
end;

destructor TWPDFPagesImport.Destroy;
begin
  Clear;
  FPages.Free;
  if FEngine <> nil then FEngine.Free;
  inherited Destroy;
end;

procedure TWPDFPagesImport.SetDLLName(const x: string);
begin
  if FGLDLLName <> x then
  begin
    {$IFDEF INTWPSWITCH}
    if FEngine.FDLLInUSE > 0 then raise PDFException.Create('DLL is in use. Cannot unload it');
    if FEngine.DLLOK then FEngine.UnloadDLL;
    {$ENDIF}
    FGLDLLName := x;
  end;
end;

procedure TWPDFPagesImport.Clear;
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
    TWPDFImportedPage(FPages[i]).Free;
  FPages.Clear;
  FMaxPageWidth := 0;
  FMaxPageHeight := 0;
end;

function TWPDFPagesImport.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

function TWPDFPagesImport.GetPage(index: Integer): TWPDFImportedPage;
begin
  Result := TWPDFImportedPage(FPages[index]);
end;

procedure TWPDFPagesImport.ExtractPDFPage(Sender: TObject;
  page_num: Integer; const text: string; var obj: TObject);
var
  Abort, Import: Boolean; pagedata: TWPDFImportedPage;
begin
  Import := (FPageNumber >= FFromPage) and
    ((FPageNumber <= FToPage) or (FToPage <= 0));
  Abort := (FToPage > 0) and (FPageNumber > FToPage);
  if assigned(FBeforeReadPage) then
    FBeforeReadPage(Self, FPageNumber, Abort, Import);
  if Abort then
    FEngine.Abort
  else if Import then
  begin
    pagedata := TWPDFImportedPage.Create;
    try
      pagedata.FWidth := FEngine.ReadPageWidth;
      pagedata.FHeight := FEngine.ReadPageHeight;
      if pagedata.FWidth > FMaxPageWidth then FMaxPageWidth := pagedata.FWidth;
      if pagedata.FHeight > FMaxPageHeight then FMaxPageHeight := pagedata.FHeight;
      if (obj <> nil) and (obj is TGraphic) then
      begin
        pagedata.FGraphic := TGraphic(obj);
        obj := nil;
      end;
      pagedata.FText := text;
      pagedata.FNumber := FPageNumber;
      FPages.Add(pagedata);
      pagedata := nil;
    finally
      if pagedata <> nil then pagedata.Free;
    end;
  end;
  inc(FPageNumber);
end;

function TWPDFPagesImport.Execute: Boolean;
begin
  if FEngine = nil then
    FEngine := TWPCustomPDFExport.Create(Self);
  try
    Clear;
    FEngine.OnReadInputPDF := ExtractPDFPage;
    FEngine.InputFile := PDFFile;
    FEngine.FPDFReadBitmapRes := FBitmapResolution;
    case FMode of
      wpdfReadASCII: FEngine.PDFReadMode := wpdfRetrieveASCII;
      wpdfReadBitmap: FEngine.PDFReadMode := wpdfRetrieveBMP;
      wpdfReadMetafile: FEngine.PDFReadMode := wpdfRetrieveEMF;
    end;
    FPageNumber := 1;
    FEngine.BeginDoc;
  finally
    FEngine.EndDoc;
    FEngine.Free;
    FEngine := nil;
    Result := FPages.Count > 0;
  end;
end;

destructor TWPDFImportedPage.Destroy;
begin
  if FGraphic <> nil then FGraphic.Free;
  FText := '';
  inherited Destroy;
end;

function TWPDFImportedPage.GetGraphicAndNil: TGraphic;
begin
  Result := FGraphic;
  FGraphic := nil;
end;

{$ENDIF} // IFDEF PDFIMPORT


// -----------------------------------------------------------------------------
// PDF Info Block
// -----------------------------------------------------------------------------

procedure TWPPDFExportInfo.Assign(Source: TPersistent);
begin
  if Source is TWPPDFExportInfo then
  begin
    FAuthor := TWPPDFExportInfo(Source).FAuthor;
    FDate := TWPPDFExportInfo(Source).FDate;
    FModDate := TWPPDFExportInfo(Source).FModDate;
    FProducer := TWPPDFExportInfo(Source).FProducer;
    FTitle := TWPPDFExportInfo(Source).FTitle;
    FSubject := TWPPDFExportInfo(Source).FSubject;
    FKeywords := TWPPDFExportInfo(Source).FKeywords;
    FAdditionalStrings.Assign(TWPPDFExportInfo(Source).FAdditionalStrings);
  end;
end;

    constructor TWPPDFExportInfo.Create;
    begin
      inherited Create;
      FAdditionalStrings := TStringList.Create
    end;

    destructor TWPPDFExportInfo.Destroy;
    begin
       FAdditionalStrings.Free;
       inherited Destroy;
    end;

    function TWPPDFExportInfo.GetAdditionalStrings : TStrings;
    begin
       Result := FAdditionalStrings;
    end;

    procedure TWPPDFExportInfo.SetAdditionalStrings(x :TStrings);
    begin
       FAdditionalStrings.Assign(x);
    end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
initialization
  FGLDLLName := DEFAULT_DLL_NAME;

finalization
{$IFDEF INTWPSWITCH}
{$IFNDEF NEWLOADLIB}
 if (glDLLHandle>0) then
 begin
    FreeLibrary(glDLLHandle);
    glDLLHandle := 0;
 end;
{$ENDIF}
{$ENDIF}

end.

