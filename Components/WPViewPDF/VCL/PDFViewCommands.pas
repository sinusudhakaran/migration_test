unit PDFViewCommands;
// PDFViewCommands.INC
// ---------------------------------
// PDF View Commands
// ---------------------------------

// The following commands are also available through menu items / buttons and sendmessage

interface       

const
  // Menu/Popup 1
  COMPDF_DocumentProperties = 1;  // Show document property window
  COMPDF_SecurityProperties = 2;  // Show document security property window (RESERVED)
  COMPDF_RightProperties    = 3;  // Show rights property window (only edit mode!)
  COMPDF_FontProperties     = 4;  // Show font property window (RESERVED)
  COMPDF_ViewPreferences    = 5;  // Show Viewer Preferences
  COMPDF_ShowAbout          = 6;  // Show Viewer/Editor About Dialog
  COMPDF_EditPreferences    = 7;  // Show Editor Preferences  (RESERVED)

  // Window Popup
  COMPDF_GotoFirst          = 20; // Goto first page
  COMPDF_GotoPrev           = 21; // Goto Previous page
  COMPDF_GotoPage           = 22; // Goto Page Nr in parameter
  COMPDF_GotoNext           = 23; // Goto next page
  COMPDF_GotoLast           = 24; // Goto last page
  COMPDF_ShowGotoPage       = 25; // Show page nr editfield (RESERVED)
  COMPDF_ShowGotoBookmark   = 26; // Show bookmark edit (RESERVED)
  COMPDF_GotoYPos           = 27; // Goto 'B' as y in 72 dpi (also see GetYpos!)
  COMPDF_GotoXPos           = 28; // Goto 'B' as x in 72 dpi
  COMPDF_ScrollXY           = 29; // Bit 1: Horz, Bit 2: Large, Bit 3=Next

  // Print
  COMPDF_PrinterSetup       = 30; // Setup Printer Dialog
  COMPDF_Print              = 31; // Print Document (string=range or Low(B)=from, High(B)=to)
  COMPDF_PrintDialog        = 32; // Show Print Dialog
  COMPDF_GetPrinter         = 33; // par=256 byte buffer for Printername

  COMPDF_SelectDuplexMode   = 34; // par = duplex mode integer value
  COMPDF_SelectPrinter      = 35; // par=printer name
  COMPDF_BeginPrint         = 36; // Start Print Job
  COMPDF_EndPrint           = 37; // End Print Job
  COMPDF_SelectPrinterBin0  = 38; // PrinterBin Def for default
  COMPDF_SelectPrinterBin1  = 39; // PrinterBin Def for primary
  COMPDF_SelectPrinterBin2  = 40; // PrinterBin Def for secondary


  // Zoom Commands
  COMPDF_Zoom100            = 41; // 100 % Zoom
  COMPDF_ZoomIn             = 42; //  + 10%
  COMPDF_Zoom               = 43; // Zoom to StrPar/IntPar - if IntPar=0 retrieve zoom! If StrPar<>'' the set to zooming mode
  COMPDF_ZoomOut            = 44; //  - 10%
  COMPDF_ZoomFullWidth      = 45; // Page Width
  COMPDF_ZoomFullPage       = 46; // Page Width
  COMPDF_ZoomTwoPages       = 47; // Toggle 2 Pages Display


  // Customization
  COMPDF_SelectControls       = 50; // Select which buttons to see: 1=VScroll, 2=HScroll, 4=ViewPanel, 8=SearchPanel, 16=OptionButton
  COMPDF_SelectOptions        = 51; // 1= wpDontUseHyperlinks, 2= wpDontHighlightLinks,
                                    // 4=wpDontAskPassword, 8=wpSelectClickedPage, 16=wpShowCurrentPage
  COMPDF_SetPaintMode = 52; // Bit 1: DEFINE COLOR_LARGE_PENWIDTH
                            // Bit 2:  HIDE_LARGE_PENWIDTH}  Big circles on the page ?
                            // Bit 3:  extract - do not use distances to create spaces


  COMPDF_SETDESKCOLOR = 53; // Color for background
  COMPDF_SETPAPERCOLOR = 54; // Color for paper

  // Modify Strings in menu
  COMPDF_SetDocumentProperties = 61;  // Str param = new text, "" to switch off
  COMPDF_SetSecurityProperties = 62;  //(RESERVED)
  COMPDF_SetRightProperties    = 63;  //(RESERVED)
  COMPDF_SetFontProperties     = 64;  //(RESERVED)
  COMPDF_SetViewPreferences    = 65;  //(RESERVED)
  COMPDF_SetShowAbout          = 66;
  COMPDF_SetEditPreferences    = 67;  //(RESERVED)
  COMPDF_SetPrintSetup         = 68;
  COMPDF_SetPrint              = 69;

  // File Commands
  COMPDF_Clear              = 100; // Clears the viewer
  COMPDF_Load               = 101; // Load PDF file par
  COMPDF_Append             = 102; // Append PDF file par
  COMPDF_AppendHGlobal      = 103; // par = HGLOBAL
  COMPDF_AppendIStream      = 104; // par = IStream interface pointer (for use with COM)
  COMPDF_AppendEStream      = 105; // par =  EventStream Record Ptr - create copy
  COMPDF_AppendEPStream     = 106; // par =  EventStream Record Ptr - use that (attach!)

  // Security Commands
  COMPDF_SetLoadPassword    = 120; // Sets master load password (also in NeedPassword event!)
  COMPDF_ClearPasswords     = 121; // Clears the list of passwords
  COMPDF_AddPassword        = 122; // Adds a password to the list

  // Disable Functionality (once sent to the control it cannot be changed anymore)
  COMPDF_DisablePrint       = 123; // Disable print - it is not possible to enable again!
  COMPDF_DisableHQPrint     = 124; // Disable high quality print - if print, only low quality!
  COMPDF_DisableSelectPrinter=125; // Disable Select Printer or PrintDialog (print at once!)
  COMPDF_DisablePrintHDC    = 126; // Disable print to HDC - it is not possible to enable again!
  // functionality reserved for future - but automatically executed by present version
  COMPDF_DisableSave        = 127; // Disable saving of the PDF file - it is not possible to enable again!
  COMPDF_DisableCopy        = 128; // Disable copy to clipboard - it is not possible to enable again!
  COMPDF_DisableForms       = 129; // Disable form editing - it is not possible to enable again!
  COMPDF_DisableEdit        = 130; // Disable editing - it is not possible to enable again!
  COMPDF_DisableSecurityOverride = 131; // By standard the viewer does not respect the P flag. With this setting it does

  // Print HDC Commands
  COMPDF_PrintHDC            = 150; // -- DO NOT USE ANYMORE !!! disabled in DEMO! B=PageNO
  COMPDF_PrintHDCSetHDC      = 151; // -- DO NOT USE ANYMORE !!! Set HDC for the next COMPDF_PrintHDC
  COMPDF_PrintHDCSetXRes     = 152; // Set X Resolution for the next COMPDF_PrintHDC, call this BEFORE the creation of DC (windows DLL problem)
  COMPDF_PrintHDCSetYRes     = 153; // Set Y Resolution for the next COMPDF_PrintHDC, call this BEFORE the creation of DC (windows DLL problem)
  COMPDF_PrintHDCUseCurves   = 154; // if par<>0 print all text is printed as curves

  COMPDF_PrintUseScaling     = 155; // Scale the page to the paper size
  // 0=off, 1=shrink if required, 2=shrink and enlarge
  COMPDF_PrintSetDEVMODE     = 156; // buf=DEVMODE structure, B=size. The printer DEVMODE will be
                                    // Overwritten with this data. To clear pass NULL pointer
  COMPDF_PrintUSEROTATE      = 157; // Rotate the drawing as on screen!
  COMPDF_DONTSETDEVMODE      = 158; // 1/0: dont update the printer devmode
  COMPDF_PrintGetDEVMODE     = 159; // Result is HGLOBAL of Printer DEVMODE record
  // Problem: DC does not survive one call to DLL ???!!!!
  COMPDF_PrintHDC_SelectPage   = 160; // Select page - before you created DC
  COMPDF_PrintHDC_SelectedPage = 161; // and print this pahe on the passed DC

  COMPDF_MakeEMF = 162; // strparm=  "nr=filename", example "1=c:\pageone.emf"
  COMPDF_MakePrinterEMF = 163; // Like  COMPDF_MakeEMF but uses the printer to create the reference DC

  // Read Commands
  COMPDF_GetPageCount       = 201; // get count of loaded pages
  COMPDF_GetViewPage        = 202; // get current page
  COMPDF_GetPageWidth       = 203; // IntPar = pageno
  COMPDF_GetPageHeight      = 204; // IntPar = pageno
  COMPDF_GetPageRotation    = 205; // IntPar = pageno
  COMPDF_GetYPos            = 210; // Get Scroll Y Pos in 72 dpi
  COMPDF_GetXPos            = 211; // Get Scroll x Pos in 72 dpi
  COMPDF_GetWidth           = 212; // Get Window width in 72 dpi
  COMPDF_GetHeight          = 213; // Get Window height in 72 dpi
  COMPDF_GetPageUnderMouse  = 214; // Page under current Mouse position (for popup menues!)

  // Set Page Info (UpdatePageDimension)
  COMPDF_SetPageWidth       = 230; // Set Width of selected pages in 72 dpi
  COMPDF_SetPageHeight      = 231; // Set Height of selected pages  in 72 dpi
  COMPDF_SetPageRotation    = 233; // Absolute: 1..4 or relative +-90
  COMPDF_SetPagePaperBin    = 234; // Sets Paperbin for selected pages
  COMPDF_SetIgnoreRotation  = 235; // Switch off the use of rotation property
  // Page Selection
  COMPDF_PageSelectionClear = 248; // Removes previous selection
  COMPDF_PageSelectionAdd   = 249; // Select one additional page
  COMPDF_PageSelectionDel   = 250; // Removes Selection from Page
  COMPDF_PageSelectionInvert= 251; // Inverts Selection

  // Find Text
  COMPDF_FindAltText        = 252; // Pass the wide string which should be found alternatively
  COMPDF_FindGotoPage       = 253; // Mode: 1-> Goto Page (default), 1 don't go
  COMPDF_FindCaseInsitive   = 254; // Mode: 1-> Case sensitive (default), 1 insensitive(use COMPDF_FindAltText!!!)
  COMPDF_FindText           = 255; // Finds from page 0
  COMPDF_FindNext           = 256; // Finds from corrent page +1
  COMPDF_HighlightText      = 257; // Highlights the text

  // GetText
  COMPDF_GetTextLen         = 260; // Result = buffer len
  COMPDF_GetTextBuf         = 261; // Copy to PChar (must be correct len!)

  COMPDF_GetTextLenW         = 262; // Result = buffer len
  COMPDF_GetTextBufW         = 263; // Copy to PWideChar (must be correct len!)

  COMPDF_SETLICENSE_STR     = 290; // Set License Name


  // Field Commands
  COMPDF_Field_InputChar    = 301; // Insert Char into active Field
  COMPDF_Field_InputKey     = 302; // use VKCode for active Field. High = ShiftCode
  COMPDF_Field_Set          = 303; // Set the active field to StrPar
  COMPDF_Field_MoveNext     = 304; // Move to next field
  COMPDF_Field_MovePrevious = 305; // Move to previous field
  COMPDF_Field_Move         = 306; // Move to field with name 'StrParam' or IntPar=Nr-1

  COMPDF_SETLICENSE_INT     = 1290; // Set License Code

  // EVENT - SET RESULT (Can be used to modify result in VAR events)
  COMPDF_SetResultA        = 2001; // IntPar = Value A
  COMPDF_SetResultB        = 2002; // IntPar = Value B
  COMPDF_DisableAbout      = 2003; // Deactivate Splash - may only be used if you put
  // credit in About Dialog of your application. Ask WPCubed for parameter when you agree.

// Message ID to send data to PDF Viewer
  WM_PDF_COMMANDSTR = $0400 + 77; // wparam = command, lparam = PChar,
  WM_PDF_EVENT      = $0400 + 78; // wParam = nr, lparam = par
  WM_PDF_COMMAND    = $0400 + 79; // wparam = command, lparam = B
  WM_PDF_ENABLE     = $0400 + 80; // switches control into active mode
  WM_PDF_COMMANDSTRU= $0400 + 81; // wparam = command, lparam = PWideChar,
  WM_PDF_INTERNEVENT= $0400 + 82; // used by viewer
  WM_PDF_HYPERLINK  = $0400 + 83;  // user clicked on hyperlink. (wparam=pagenr, lparam = hi(x) + y)
  WM_PDF_HYPERLINK_URL = $0400 + 84;  // user clicked on WWW hyperlink. (wparam=-1, lparam = PChar(url))

// Event IDS
  MSGPDF_NEEDPASSWORD     = 100; // Set a new password!
  MSGPDF_PROBLEMONLOAD    = 101; // We have a probelm while loading the file
  MSGPDF_PROBLEMONDISPLAY = 102; // We have a probelm while displaying the file
  MSGPDF_INITCOMMANDS     = 103; // Set the command offsets (lparam)
  MSGPDF_CHANGEVIEWPAGE   = 104; // Moved to different page (=wparam)
  MSGPDF_SETVERSION       = 105; // lparam = version * 1000
  MSGPDF_INITMASTERKEY    = 106; // Set RSA Masterkey (NOTIMPL)
  MSGPDF_INTERNEXCEPTION  = 107; // Send exception string
  MSGPDF_CHANGESELPAGE    = 108; // Moved to different page (=wparam)

//GUI Events
  MSGPDF_KEYDOWN           = 201; // l Param = Key, SetResult with
  MSGPDF_KEYPRESS          = 202; // l Param = Key
  MSGPDF_KEYUP             = 203; // l Param = Key



implementation
end.
