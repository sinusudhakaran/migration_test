// ------------------------------------------------------------------
// wPDF PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 1, 2000 Copyright (C) by Julian Ziersch, Berlin
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.pdfcontrol.com
// ------------------------------------------------------------------

const
  WPOut_SameLevel = 0;
  WPOut_NextLevel = 1;
  WPOut_PreviousLevel = 2;
  WPOut_SetLevel = 3;
  WPOut_SetAsChild = 4;
  WPOut_SetAsNext  = 5;

  // Destmodes
  WPDM_XYZ  = 0; // If left, top,orzoom is null, the current value of that parameter is retained.
  WPDM_FIT  = 1; // Fit the page to the window
  WPDM_FITV = 2; // Fit the height of the page to the window.
                 // left specifies the x-coordinate of the left edge of the window.
  WPDM_FitH = 3; // Fit the width of the page to the window. top specifies the y-coordinate
  WPDM_FITR = 4; // Fit the rectangle specified by left bottom right top in the window
  WPDM_FitB = 5; // Fit the page’s bounding box to the window
  WPDM_FitBV= 6; // Fit the height of the page’s bounding box to the window.
  WPDM_FitBH= 7; // "
// Callback function
  WPPDF_CALL_ERROR = 1; // Error !!!
  WPPDF_CALL_INFO_IMPORT = 2; // Information about imported page count
  WPPDF_CALL_EXTRA_INFO_IMPORT = 3; // For intern use
  WPPDF_CALL_MERGE = 4; // Merge Event

type
  // used to initialize a page with WPPDF_StartWPTPage
  PWPPDF_InitRec = ^TWPPDF_InitRec;
  TWPPDF_InitRec =  packed
  record
     pagew, pageh : Integer; // in twips !!!
     xres, yres   : Integer;
     rotation      : Integer; // bit1=90, bit2=270
     specialcolor : TColor; // Header, Footer Color
     left_offset  : Integer;
     top_offset   : Integer;
     thumbnails   : Boolean;
     fontmul      : Single;
  end;

  // Parameters to create names, links and outlines
  PWPPDF_LinkDef= ^TWPPDF_LinkDef;
  TWPPDF_LinkDef = packed
  record
  {$IFNDEF VERSION1COMPAT}
      action     : Integer; // (currently!) not used for action links
      actionmode : Integer; // (currently!) not used for action links
  {$ENDIF}
  {$IFDEF WPDFDEMOV}
      caption    : array[0..255] of Char; // (currently!) not used for links
      destname   : array[0..255] of Char; // (currently!) not used for outlines
  {$ENDIF}
      x,y        : Integer;
      w,h        : Integer;               // not used for outlines and names
      destmode   : Integer;
      destzoom   : Integer;               // only for
  {$IFNDEF WPDFDEMOV}
      caption    : array[0..255] of Char; // (currently!) not used for links
      destname   : array[0..255] of Char; // (currently!) not used for outlines
  {$ENDIF}
      levelmode, level : Integer;         // only used for outlines
      Mode : Integer;                     // If Bit 1 then read the custom action
                                          // If Bit 2 then custom_action is actually a Caption as PWideChar
      custom_action_type : Integer;
      custom_action : PChar;
      embedded_file : PChar;
      embedded_file_len : Integer;
      reserved : Integer; // Must be 0
  end;

  TWPGraphicDef = packed
  record
     x,y,w,h : Integer;       // Rectangle to draw to
     BitmapID  : Integer;     // Must be 0, will be set to the handle of the object
     BitmapHandle : HBITMAP;  // If <>0 than a bitmap handle is expected
     BitmapInfo: PBitmapInfo; // if <>nil then DIB Information !
     BitmapBits: Pointer;     // DibBits
     StreamData: PChar;       // if <>buk then streamed data (JPEG)
     StreamLen : Integer;     // Use embedded Data
     StreamMode: Integer;     // Must be 2 for JPEG Data !
     StreamW, StreamH : Integer; // Actual Scanline width and bitmap height of StreamData
     Filename  : PChar;       // or a filename .... ?
     reserved  : Integer;     // Must be 0
  end;
  PWPGraphicDef = ^TWPGraphicDef;


  TWPDFFieldDef = packed
  record
     x,y,w,h : Integer;       // Rectangle to draw to
     typ     : Integer;
     mode    : Integer;
     value   : Integer;
     init    : PChar;
     defaultvalue : PChar;
     hint    : PChar;
     text    : PChar;
  end;
  PWPDFFieldDef = ^TWPDFFieldDef;


const
  {$IFNDEF VERSION1COMPAT}
      WPPDF_Base0 = 4532;
  {$ELSE}
      WPPDF_Base0 = 0;
  {$ENDIF}
  {$IFDEF WPDFDEMOV} WPPDF_Base=WPPDF_Base0+1025;
  {$ELSE} WPPDF_Base = WPPDF_Base0+0;
  {$ENDIF}

// WPPDF_SetSProp IDs
  WPPDF_Author  = 1;
  WPPDF_Date    = 2;
  WPPDF_ModDate = 3;
  WPPDF_Producer= 4;
  WPPDF_Title   = 5;
  WPPDF_Subject = 6;
  WPPDF_Keywords= 7;
  WPPDF_Creator = 8;
  WPPDF_ExcludedFonts = 9;
  WPPDF_OwnerPassword = 10;
  WPPDF_UserPassword  = 11;
  WPPDF_InputFile     = 12;
  WPPDF_IncludedFonts =13;
  WPPDF_MERGESTARTTEXT  = 14;
  WPPDF_MERGETEXTRESULT = 15;
  WPPDF_OtherInfoTexts  = 16;
// WPPDF_SetIProp
  WPPDF_ENCODE = 1;
  WPPDF_COMPRESSION = 2;
  WPPDF_PAGEMODE = 3;
  WPPDF_USEFONTMODE = 4;
  WPPDF_FastCompress = 5; // <>0 = fast !
  WPPDF_ConvertJPEGData = 6; // <>0 = TRUE
  WPPDF_Encryption = 7; // set
  WPPDF_InputFileMode  = 8;
  WPPDF_ReadPDFMode = 9;
  WPPDF_EngineVersion = 10;
  WPPDF_MonochromeThumbnail = 11;
  WPPDF_JPEGCompress = 12;  // 0=off, else Quality
  WPPDF_XCOMPRESSION = 13;  // wpCompressNone, wpCompressFlate, wpCompressRunlength, wpCompressFastRunlength
  WPPDF_ZOOMMODE = 14;      // wpDefaultZoom, wpFitPage, wpFitVertical, wpFitHorizontal
  WPPDF_Security = 15;      // wpp40bit, wpp128bit (, wpp56bit, wpp80bit, wpp96bit)

  WPPDF_MsgEmbedFont =21; // Message for embedded fonts
  WPPDF_FontWidthMult=22; // Enlarge Fonts horz (by x/100) !
  WPPDF_EnhancedOptions = 23; // obsolete
  WPPDF_OutlineCharset = 24;
  WPPDF_UseThumbNails = 25;
  WPPDF_DevModes = 26;
  WPPDF_PDFOptions = 27;

// WPPDF_Action
  WPPDF_BEGINDOC     = WPPDF_Base+1; // param = pchar to filename, otherwise memory!
  WPPDF_ENDDOC       = WPPDF_Base+2;
  WPPDF_STARTPAGE    = WPPDF_Base+3;
  WPPDF_ENDPAGE      = WPPDF_Base+4;
  WPPDF_GETBUF       = WPPDF_Base+5; // Get memory. Returns length
  WPPDF_WRITEFILE    = WPPDF_Base+6; // param = pchar to filename
  WPPDF_FINISH       = WPPDF_Base+7; // free the memory
  WPPDF_SETPAGETHUMB = WPPDF_Base+8; // val = bitmap handle
  WPPDF_SETLINK      = WPPDF_Base+9; // param = PWPPDF_LinkDef
  WPPDF_SETNAME      = WPPDF_Base+10;// param = PWPPDF_LinkDef
  WPPDF_SETOUTLINE   = WPPDF_Base+11;// param = PWPPDF_LinkDef
  WPPDF_ENHMETAFILE  = WPPDF_Base+12;// val =  HENHMETAFILE
  WPPDF_STARTXFORM   = WPPDF_Base+13;// param = PWPPDF_LinkDef w,h, caption
  WPPDF_ENDXFORM     = WPPDF_Base+14;
  WPPDF_USEXFORM     = WPPDF_Base+15;// param = PWPPDF_LinkDef x,y,w,h caption
  WPPDF_COMMAND      = WPPDF_Base+16;// param = pchar
  WPPDF_EXBITMAP     = WPPDF_Base+17;// val = HBITMAP
  WPPDF_FIELD        = WPPDF_Base+18; // param = PWPDFFieldDef
  WPPDF_InitDC       = WPPDF_Base+19;
  WPPDF_AddAction    = WPPDF_Base+20; // param = PChar: name=javacode
  WPPDF_UseAction    = WPPDF_Base+21; // param = PChar: command=name (command=OPENACTION)
// Exported Function pointer declarations
type

TWPPDF_CallBack = procedure(parent : Pointer; msgid : Integer; value : Integer; p : PChar); stdcall;
TWPPDF_Initialize = function(asiz, psiz, lsiz: Integer;
  wp_version: Integer;callback: TWPPDF_CallBack;parent: Pointer): Pointer; stdcall;
TWPPDF_Finalize = procedure(env: Pointer); stdcall;
TWPPDF_SetSProp = function(env: Pointer; id: Integer; value: pchar): Boolean; stdcall;
TWPPDF_SetIProp = function(env: Pointer; id: Integer; value: Integer): Boolean; stdcall;
TWPPDF_Action = function(env: Pointer; id: Integer; val: DWORD; param: Pointer): Integer; stdcall;
{$IFNDEF VERSION1COMPAT}
TWPPDF_InitializePage = function(env: Pointer; id: Integer; param: PWPPDF_InitRec): Boolean; stdcall;
{$ELSE}
TWPPDF_StartWPTPage = function(env: Pointer; id: Integer; param: PWPPDF_InitRec): Boolean; stdcall;
{$ENDIF}
TWPPDF_XPOS = function(env: Pointer; X : Integer): Integer; stdcall;
TWPPDF_YPOS = function(env: Pointer; Y : Integer): Integer; stdcall;
TWPPDF_ProcessIt = function(DataP:Pointer;dest:PChar;destmax:Integer;toDC:HDC;mode:Integer):Integer; stdcall;
TWPPDF_WPTEXEC = function(env: Pointer; pp, pr, s: Pointer; c: Integer; pi: Pointer): Boolean; stdcall;


