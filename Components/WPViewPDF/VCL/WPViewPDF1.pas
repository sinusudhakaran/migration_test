unit WPViewPDF1;
{ ------------------------------------------------------------------------------
  TWPViewPDF - PDF Viewer and Print Class by WPCubed GmbH
  -----------------------------------------------------------------------------
  Load PDFViewer DLL and create controls for the window class

  Copyright (C) 2003 - WPCubed GmbH - www.wptools.de
  ------------------------------------------------------------------------------

  Update the global variable WPDFVIEWDLLNAME to change the name
  of the DLL to be loaded

  Version 1.0
}

{xxx$DEFINE USECOMSTREAMS}// Should be OFF

// Attention: The DLLs use different window classnames
{-$DEFINE WPVIEWDEMO}

{$DEFINE USEPRINTER}


interface

uses Classes, Controls, Forms, Graphics, Windows, Messages, SysUtils
{$IFDEF USECOMSTREAMS}, ActiveX{$ENDIF}
{$IFDEF USEPRINTER}, Printers{$ENDIF}, Dialogs, PDFViewCommands;
{$R-}

type
  TWPPDFViewControl = (
    wpHorzScrollBar,
    wpVertScrollBar,
    wpPropertyPanel,
    wpNavigationPanel,
    wpViewPanel);
  TWPPDFViewControls = set of TWPPDFViewControl;


  TWPPDFViewOption =
    (
    wpDontUseHyperlinks,
    wpDontHighlightLinks,
    wpDontAskForPassword,
    wpSelectClickedPage,
    wpShowPageSelection,
    wpShowPageMultiSelection,
    wpEnableSmartThumbs,
    wpAllowFormEdit, // - not 100% ready yet
    wpDisablePagenrHint,
    wpDisableZoomHint
    );
  TWPPDFViewOptions = set of TWPPDFViewOption;

  TWPPDFSecurityOption =
    (wpDisablePrint,
    wpDisableHQPrint,
    wpDisableSelectPrinter,
    wpDisablePrintHDC,
    wpDisableSave,
    wpDisableCopy,
    wpDisableForms,
    wpDisableEdit,
    wpDisablePDFSecurityOverride);
  TWPPDFSecurityOptions = set of TWPPDFSecurityOption;

  TWPDFErrorEvent = procedure(Sender: TObject; const Msg: string) of object;

  TChangeViewPageEvent = procedure(Sender: TObject; const PageNr: Integer) of object;

  THyperlinkPageEvent = procedure(Sender: TObject; const PageNr, X, Y: Integer) of object;
  THyperlinkWWWEvent = procedure(Sender: TObject; const Url : String) of object;

{$IFDEF T2H}TNotifyEvent = procedure(Sender: TObject) of object; {$ENDIF}

  TWPViewPDF = class(TWinControl)
  private
    FCO: Integer;
    FOnNeedPassword: TNotifyEvent;
    FOnChangeViewPage: TChangeViewPageEvent;
    FOnHyperlinkPage : THyperlinkPageEvent;
    FOnHyperlinkWWW : THyperlinkWWWEvent;
    FVersion: Integer;
    FOnError: TWPDFErrorEvent;
    FLoadPassword: string;
    FFileName, FLoadedFile: string;
    FViewControls: TWPPDFViewControls;
    FViewOptions: TWPPDFViewOptions;
    FSecurityOptions: TWPPDFSecurityOptions;
    FBorderStyle: TBorderStyle;
    FFreeMemList: TList; // holds event stream references
    FOnKeyDown: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyUp: TKeyEvent;
    procedure SetLoadPassword(const x: string);
    procedure SetViewControls(x: TWPPDFViewControls);
    procedure SetViewOptions(x: TWPPDFViewOptions);
    procedure SetFileName(x: string);
    procedure SetSecurityOptions(x: TWPPDFSecurityOptions);
    procedure SetViewPage(x: Integer);
    function GetViewPage: Integer;
    function GetPageCount: Integer;
    procedure SetBorderStyle(x: TBorderStyle);
    function GetDLLName: string;
    procedure SetDLLName(x: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMViewerMessage(var Message: TMessage); message WM_PDF_EVENT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    // New, V1.21
    procedure WMViewerHyperlink(var Message: TMessage); message WM_PDF_HYPERLINK; // $0400 + 83
    procedure WMViewerHyperlinkURL(var Message: TMessage); message WM_PDF_HYPERLINK_URL; // $0400 + 84
  public
{$IFNDEF T2H}
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    function CommandEx(command: Integer; Param: Cardinal): Integer;
    function CommandStr(command: Integer; str: string): Integer;
{$ENDIF}
    procedure ViewerStart(DLLNameAndPath, licensename, licensekey: string; licensecode: Integer);

    function FindText(Text: string; HighLight, FindNext: Boolean;
      CaseInsensitive: Boolean = false;
      DontGoToPage: Boolean = false): Boolean;
    function GetPageText(PageNo: Integer): string;
    function GetPageTextW(PageNo: Integer): WideString;
    function Command(command: Integer): Integer;
    function LoadFromFile(const filename: string): Boolean;
    function AppendFromFile(const filename: string): Boolean;
    function LoadFromStream(stream: TStream): Boolean;
    function AttachStream(stream: TStream): Boolean;
    function PrintHDC(PageNO: Integer; DC: HDC; ResX, ResY: Integer): Boolean;
    function GetMetafile(PageNO: Integer): TMetafile;
{$IFDEF USEPRINTER}
    function GetMetafilePrn(PageNO: Integer): TMetafile;
{$ENDIF}
    function BeginPrint(Printername: string): Boolean;
    procedure EndPrint;
    function PrintPages(StartPage, EndPage: Word): Integer;
    procedure Clear;
    property Page: Integer read GetViewPage write SetViewPage;
    property PageCount: Integer read GetPageCount;
    property DLLName: string read GetDLLName write SetDLLName;
  published
    //: This property contains the version * 1000 once the DLL has been loaded
    property Version: Integer read FVersion;
    //: This property lets you select if you need scrollbars or other controls.
    property ViewControls: TWPPDFViewControls read FViewControls write SetViewControls;
    //: Here you can switch on and off the display and use of hyperlinks
    property ViewOptions: TWPPDFViewOptions read FViewOptions write SetViewOptions;
    //: Using the security options you can switch off functionality.
    //: Please note that once a featiure is switched off it cannot be activated agaian
    property SecurityOptions: TWPPDFSecurityOptions read FSecurityOptions write SetSecurityOptions;
    //: This file will be inititally loaded
    property FileName: string read FFileName write SetFilename;
    //: Modify this property to change the password for loading a PDF file
    //: the password has to be added at the latest time once the event
    //: OnNeedPassword had been triggered. If no password is set in the event
    //: the PDF file cannot be loaded
    property LoadPassword: string read FLoadPassword write SetLoadPassword;
    //: This event is triggered when a file with an unkonwn password is beeing loaded
    //: Please provide the password in property 'LoadPassword'
    {:@event}
    property OnNeedPassword: TNotifyEvent read FOnNeedPassword write FOnNeedPassword;
    {:@event}
    property OnChangeViewPage: TChangeViewPageEvent read FOnChangeViewPage write FOnChangeViewPage;
    // This event is executed when the user clicks on a WWW link
    property OnHyperlinkWWW: THyperlinkWWWEvent read FOnHyperlinkWWW write FOnHyperlinkWWW;
    // This event is executed when the user clicks on a link to a page or bookmark
    property OnHyperlinkPage: THyperlinkPageEvent read FOnHyperlinkPage write FOnHyperlinkPage;

    {:@event}
    property OnError: TWPDFErrorEvent read FOnError write FOnError;
    {:@event}
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    {:@event}
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    {:@event}
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
{$IFNDEF T2H}
    property Anchors;
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
{$ENDIF}
  end;

const
{$IFDEF WPVIEWDEMO}
  VIEWDLLNAME = 'wPDFViewDemo01.dll';
{$ELSE}
  VIEWDLLNAME = 'wPDFView01.dll';
{$ENDIF}

{$IFDEF USEDUMMYCL}VIEW_DUMMY_CLASSNAME = 'wPDFView_by_WPCubed_GmbH'; {$ENDIF}

var
{$IFNDEF QUIET}
  WPViewPDFDLLNAME: string = VIEWDLLNAME;
{$ELSE}
  WPViewPDFDLLNAME: string = VIEWDLLNAME;
{$ENDIF}
  WPLoadedViewerOK: Boolean;

procedure WPPDFViewerStart(licensename, licensekey: string; licensecode: Integer);

implementation

var
  WPViewPDFClassNAME: string; // Set in CreateParams depending on WPViewPDFDLLNAME
  DLLHandle: Cardinal;

// Properties -----------------------------------------------

procedure TWPViewPDF.SetLoadPassword(const x: string);
begin
  FLoadPassword := x;
  CommandStr(COMPDF_SetLoadPassword, x);
end;

procedure TWPViewPDF.SetViewControls(x: TWPPDFViewControls);
var a: Integer;
begin
  a := 0;
  if wpVertScrollBar in x then inc(a, 1);
  if wpHorzScrollBar in x then inc(a, 2);
  if wpViewPanel in x then inc(a, 4);
  if wpNavigationPanel in x then inc(a, 8);
  if wpPropertyPanel in x then inc(a, 16);
  FViewControls := x;
  CommandEx(COMPDF_SelectControls, a);
end;

procedure TWPViewPDF.SetViewOptions(x: TWPPDFViewOptions);
var a: Integer;
begin
  a := 0;
  if wpDontUseHyperlinks in x then inc(a, 1);
  if wpDontHighlightLinks in x then inc(a, 2);
  if wpDontAskForPassword in x then inc(a, 4);
  if wpSelectClickedPage in x then inc(a, 8);
  if wpShowPageSelection in x then inc(a, 16);
  if wpShowPageMultiSelection in x then inc(a, 32);
  if wpAllowFormEdit in x then inc(a, 64);
  if wpDisablePagenrHint in x then inc(a, 128);
  if wpDisableZoomHint in x then inc(a, 256);
  if wpEnableSmartThumbs in x then inc(a, 512);
  FViewOptions := x;
  CommandEx(COMPDF_SelectOptions, a);
end;

procedure TWPViewPDF.SetFileName(x: string);
begin
  FFileName := x;
  if (x <> '') and (x <> FLoadedFile) then LoadFromFile(FFileName);
end;

procedure TWPViewPDF.SetSecurityOptions(x: TWPPDFSecurityOptions);
begin
  FSecurityOptions := x;
  if wpDisablePrint in FSecurityOptions then Command(COMPDF_DisablePrint);
  if wpDisableHQPrint in FSecurityOptions then Command(COMPDF_DisableHQPrint);
  if wpDisableSelectPrinter in FSecurityOptions then Command(COMPDF_DisableSelectPrinter);
  if wpDisablePrintHDC in FSecurityOptions then Command(COMPDF_DisablePrintHDC);
  if wpDisableSave in FSecurityOptions then Command(COMPDF_DisableSave);
  if wpDisableCopy in FSecurityOptions then Command(COMPDF_DisableCopy);
  if wpDisableForms in FSecurityOptions then Command(COMPDF_DisableForms);
  if wpDisableEdit in FSecurityOptions then Command(COMPDF_DisableEdit);
  if wpDisablePDFSecurityOverride in FSecurityOptions then Command(COMPDF_DisableSecurityOverride);
end;

procedure TWPViewPDF.SetViewPage(x: Integer);
begin
  CommandEx(COMPDF_GotoPage, x);
end;

procedure TWPViewPDF.SetBorderStyle(x: TBorderStyle);
begin
  if FBorderStyle <> x then
  begin
    FBorderStyle := x;
    RecreateWnd;
  end;
end;

function TWPViewPDF.GetViewPage: Integer;
begin
  Result := Command(COMPDF_GetViewPage);
end;

function TWPViewPDF.GetPageCount: Integer;
begin
  Result := Command(COMPDF_GetPageCount);
end;

// Creation

var lickey: string;
  liccode: Integer;

type fkt_wpdfSetLicense = function(licensename: PChar; licensecode: Cardinal): Cardinal; stdcall;
var f_set_lic: fkt_wpdfSetLicense;

function LoadDLL(dllname: string): Boolean;
begin
  Result := FALSE;
  if dllname <> '' then
  begin
    DLLHandle := LoadLibrary(PChar(dllname));
    if DLLHandle <= 0 then
    begin
{$IFNDEF QUIET}
      ShowMessage('Cannot load DLL ' + dllname);
{$ENDIF}
      DLLHandle := 0;
    end else
    begin
      f_set_lic := GetProcAddress(DLLHandle, 'wpdfSetLicense');
      if not assigned(f_set_lic) then
      begin ShowMessage('Wrong DLL!');
        FreeLibrary(DLLHandle);
        DLLHandle := 0;
        f_set_lic := nil;
      end else f_set_lic(PChar(lickey), liccode);
    end;
  end;
end;

function TWPViewPDF.GetDLLName: string;
begin
  Result := WPViewPDFDLLNAME;
end;

procedure TWPViewPDF.SetDLLName(x: string);
var bHasHandle, bWasFocused: Boolean;
begin
  if x <> WPViewPDFDLLNAME then
  begin
    bHasHandle := HandleAllocated;
    bWasFocused := Focused;
    DestroyHandle;
    if DLLHandle <> 0 then
    begin
      FreeLibrary(DLLHandle);
      DLLHandle := 0;
      f_set_lic := nil;
      WPLoadedViewerOK := FALSE;
    end;

    if (x = '') or (x = 'UNLOAD') then
    begin
      WPViewPDFDLLNAME := '';
      if bHasHandle then
      begin
        UpdateControlState; // CreateHandle;
          // ShowWindow(Handle, SW_SHOWNORMAL);
      end;
    end
    else
    begin
      WPViewPDFDLLNAME := x;
      if bHasHandle then
      begin
        UpdateControlState; // CreateHandle;
        ShowWindow(Handle, SW_SHOW);
        MoveWindow(Handle, Left, Top, Width, Height, true);
        SendMessage(Handle, WM_SIZE, 0, Width + Height shl 16);
      end;
      if bHasHandle and (DLLHandle <= 0) then
        WPViewPDFDLLNAME := '';
    end;
    if bWasFocused and HandleAllocated then Windows.SetFocus(Handle);
  end;
end;

procedure TWPViewPDF.CreateParams(var Params: TCreateParams);
var dummy: WNDCLASS;
begin
  if not (csDesigning in ComponentState) and
    (DLLHandle <= 0) then
    LoadDLL(WPViewPDFDLLNAME);
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_TABSTOP;
  if DLLHandle > 0 then
  begin
    // ------------------------------------------------------------------------
    if Pos('DEMO', Uppercase(ExtractFileName(WPViewPDFDLLNAME))) > 0 then
      WPViewPDFClassNAME := 'WPCubed_PDFVIEW_Demo_01'
    else WPViewPDFClassNAME := 'WPCubed_PDFVIEW_01';
    // ------------------------------------------------------------------------

    if not GetClassInfo(HInstance, PChar(WPViewPDFClassNAME), dummy) then
    begin
      ShowMessage('Windowclass ' + WPViewPDFClassNAME + ' cannot be found!');
      FreeLibrary(DLLHandle);
      f_set_lic := nil;
      DLLHandle := 0;
    end
    else
    begin
      CreateSubClass(Params, PChar(WPViewPDFClassNAME));
      WPLoadedViewerOK := TRUE;
    end;
    with Params do
    begin
      // ExStyle := ExStyle or WS_EX_TRANSPARENT;
    end;
  end{$IFDEF USEDUMMYCL} else if GetClassInfo(HInstance, PChar(VIEW_DUMMY_CLASSNAME), dummy) then
  begin
    CreateSubClass(Params, PChar(VIEW_DUMMY_CLASSNAME));
    WPLoadedViewerOK := TRUE;
  end{$ENDIF};

  if FBorderStyle = bsSingle then
    Params.Style := Params.Style or WS_BORDER
  else Params.Style := Params.Style and not WS_BORDER
end;

procedure TWPViewPDF.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS + DLGC_WANTALLKEYS;
  // if WantTabs then Message.Result := Message.Result + DLGC_WANTTAB;
end;

procedure TWPViewPDF.WMViewerMessage(var Message: TMessage);
var Key, oKey: Word;
  cKey, ocKey: Char;
  function Shift: TShiftState;
  begin
    Result := [];
    if (Message.LParam and 1) = 1 then include(Result, ssShift);
    if (Message.LParam and 2) = 2 then include(Result, ssAlt);
    if (Message.LParam and 4) = 4 then include(Result, ssCtrl);
    if (Message.LParam and 8) = 8 then include(Result, ssLeft);
    if (Message.LParam and 16) = 16 then include(Result, ssRight);
    if (Message.LParam and 32) = 32 then include(Result, ssMiddle);
    if (Message.LParam and 64) = 64 then include(Result, ssDouble);
  end;
begin
  inherited;
  case Message.WParam of
    MSGPDF_NEEDPASSWORD:
      if assigned(FOnNeedPassword) then FOnNeedPassword(Self);
    MSGPDF_CHANGEVIEWPAGE:
      if assigned(FOnChangeViewPage) then FOnChangeViewPage(Self, Message.LParam + 1);
    MSGPDF_INITCOMMANDS: FCO := Message.LParam;
    MSGPDF_SETVERSION: FVersion := Message.LParam;
    MSGPDF_INITMASTERKEY: begin end;
    MSGPDF_INTERNEXCEPTION:
      if assigned(FOnError) then
        FOnError(Self, StrPas(PChar(Message.LParam)));
    MSGPDF_KEYDOWN:
      if assigned(FOnKeyDown) then
      begin
        Key := Message.LParam shr 16;
        oKey := Key;
        FOnKeyDown(Self, Key, Shift);
        if Key <> oKey then
          CommandEx(COMPDF_SetResultA, Key);
      end;
    MSGPDF_KEYUP:
      if assigned(FOnKeyUp) then
      begin
        Key := Message.LParam shr 16;
        oKey := Key;
        FOnKeyUp(Self, Key, Shift);
        if Key <> oKey then
          CommandEx(COMPDF_SetResultA, Key);
      end;
    MSGPDF_KEYPRESS:
      if assigned(FOnKeyPress) then
      begin
        cKey := Char(Message.LParam shr 16);
        ocKey := cKey;
        FOnKeyPress(Self, cKey);
        if cKey <> ocKey then
          CommandEx(COMPDF_SetResultA, Cardinal(ocKey));
      end;
  end;
end;

procedure TWPViewPDF.WMViewerHyperlink(var Message: TMessage);
var page, x, y : Integer;
begin
  if assigned(FOnHyperlinkPage) then
  begin
     page := Message.WParam;
     x := Message.LParam shr 16;
     y := Message.LParam and $FFFF;
     FOnHyperlinkPage(Self, Page, x, y);
  end;
end;

procedure TWPViewPDF.WMViewerHyperlinkURL(var Message: TMessage);
var url : string;
begin
  if assigned(FOnHyperlinkWWW) then
  begin
     if Message.LParam<>0 then
     begin
        url := StrPas(PChar(Message.LParam));
        FOnHyperlinkWWW(Self, url);
     end;
  end;
end;


procedure TWPViewPDF.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
   // inherited;
end;

procedure TWPViewPDF.WMPaint(var Message: TWMPaint);
var
  dc: HDC;
  Canvas: TCanvas;
  y: Integer;
begin
  Message.Result := -1;
  inherited;
  if (csDesigning in ComponentState) or (DLLHandle <= 0) then
  begin
    dc := GetDC(Handle);
    Canvas := TCanvas.Create;
    Canvas.Handle := dc;
    try
      Canvas.Rectangle(0, 0, Width, Height);
      Canvas.Font.Name := 'Verdana';
      Canvas.Font.Size := 11;
      y := 6;
      Canvas.TextOut(4, y, 'wpViewPDF V1.0');
      inc(y, Canvas.TextHeight('Ag'));
      Canvas.TextOut(4, y, 'by WPCubed GmbH');

      Canvas.MoveTo(0, Height - 15);
      Canvas.LineTo(Width, Height - 15);
      Canvas.MoveTo(Width - 15, 0);
      Canvas.LineTo(Width - 15, Height);
    finally
      Canvas.Handle := 0;
      Canvas.Free;
      ReleaseDC(Handle, dc)
    end;
  end;

end;

constructor TWPViewPDF.Create(aOwner: TComponent);
// var f : string;
begin
  inherited Create(aOwner);
  ControlStyle := ControlStyle
{$IFDEF VER150} - [csParentBackground]
{$ENDIF} + [csOpaque];
  FFreeMemList := TList.Create;
  FViewControls := [wpHorzScrollBar, wpVertScrollBar, wpPropertyPanel, wpNavigationPanel, wpViewPanel];
  FSecurityOptions := [wpDisableSave, wpDisableCopy, wpDisableForms, wpDisableEdit, wpDisablePDFSecurityOverride];

{  f := ExtractFilePath(Application.EXEName) + WPViewPDFDLLNAME;
  if FileExists(f) then
      WPViewPDFDLLNAME := f;  }
end;

destructor TWPViewPDF.Destroy;
var i: Integer;
begin
  for i := 0 to FFreeMemList.Count - 1 do
    FreeMem(FFreeMemList[i]);
  FFreeMemList.Free;
  inherited Destroy;
end;

function TWPViewPDF.FindText(Text: string; HighLight, FindNext: Boolean;
  CaseInsensitive: Boolean = false;
  DontGoToPage: Boolean = false): Boolean;
begin
  CommandEx(COMPDF_FindGotoPage, Integer(DontGoToPage));
  CommandEx(COMPDF_FindCaseInsitive, Integer(CaseInsensitive));

  // If we search case insensitive we simply search 2 versions of the same string
  // This allows the support of charsets
  if CaseInsensitive then
  begin
    CommandStr(COMPDF_FindAltText, AnsiUpperCase(Text));
    Text := AnsiLowerCase(Text);
  end;

  if FindNext then
    Result := CommandStr(COMPDF_FindNext, Text) >= 0
  else Result := CommandStr(COMPDF_FindText, Text) >= 0;

  if HighLight and (Result or FindNext) then
    CommandStr(COMPDF_HighlightText, Text)
  else CommandStr(COMPDF_HighlightText, '');
end;

{:: This function retrieves the ANSI text of a certain page }

function TWPViewPDF.GetPageText(PageNo: Integer): string;
var len: Integer;
begin
  len := CommandEx(COMPDF_GetTextLen, PageNo);
  SetLength(Result, len);
  if len > 0 then CommandEx(COMPDF_GetTextBuf, Cardinal(PChar(Result)));
end;

function TWPViewPDF.GetPageTextW(PageNo: Integer): WideString;
var len: Integer;
begin
  len := CommandEx(COMPDF_GetTextLenW, PageNo);
  SetLength(Result, len);
  if len > 0 then CommandEx(COMPDF_GetTextBufW, Cardinal(PWideChar(Result)));
end;

function TWPViewPDF.Command(command: Integer): Integer;
begin
  Result := SendMessage(Handle, WM_PDF_COMMAND, command + FCO, 0);
end;

// for non overload-able compiler

function TWPViewPDF.CommandEx(command: Integer; Param: Cardinal): Integer;
begin
  Result := SendMessage(Handle, WM_PDF_COMMAND, command + FCO, Param);
end;

function TWPViewPDF.CommandStr(command: Integer; str: string): Integer;
begin
  Result := SendMessage(Handle, WM_PDF_COMMANDSTR, command + FCO, Cardinal(PChar(str)));
end;

function TWPViewPDF.LoadFromFile(const filename: string): Boolean;
begin
  Result := CommandStr(COMPDF_Load, filename) >= 0;
  if Result then FLoadedFile := filename;
end;


function TWPViewPDF.AppendFromFile(const filename: string): Boolean;
begin
  Result := CommandStr(COMPDF_Append, filename) >= 0;
end;

procedure TWPViewPDF.Clear;
var i: Integer;
begin
  Command(COMPDF_Clear);
  for i := 0 to FFreeMemList.Count - 1 do FreeMem(FFreeMemList[i]);
  FFreeMemList.Clear;
  FLoadedFile := '';
end;

// --------------------------------------------------------------------

type
  PEventStreamFkt = ^TEventStreamFkt;
  TEventStreamFkt = packed
    record
    OnStreamRead: function(data: Pointer; buffer: Pointer; len: Integer): Integer; stdcall;
    OnStreamWrite: function(data: Pointer; buffer: Pointer; len: Integer): Integer; stdcall;
    OnStreamSeek: function(data: Pointer; Offset: Integer; Origin: Integer): Integer; stdcall;
    Stream: TStream;
  end;

function ReadEvent(data: Pointer; buffer: Pointer; len: Integer): Integer; stdcall;
begin
  Result := PEventStreamFkt(data).Stream.Read(PChar(buffer)^, len);
end;

function WriteEvent(data: Pointer; buffer: Pointer; len: Integer): Integer; stdcall;
begin
  Result := PEventStreamFkt(data).Stream.Write(PChar(buffer)^, len);
end;

function SeekEvent(data: Pointer; Offset: Integer; Origin: Integer): Integer; stdcall;
begin
  Result := PEventStreamFkt(data).Stream.Seek(Offset, Origin);
end;

// --------------------------------------------------------------------

function TWPViewPDF.AttachStream(stream: TStream): Boolean;
var events: PEventStreamFkt;
begin
  GetMem(events, SizeOf(TEventStreamFkt));
  FFreeMemList.Add(events);
  events.Stream := stream;
  events.OnStreamRead := Addr(ReadEvent);
  events.OnStreamWrite := Addr(WriteEvent);
  events.OnStreamSeek := Addr(SeekEvent);
  try
    Result := CommandEx(COMPDF_AppendEPStream, Cardinal(events)) = 0;
  except
    Result := false;
  end;
end;

// --------------------------------------------------------------------

// This function is not available in the demo version!

function TWPViewPDF.PrintHDC(PageNO: Integer; DC: HDC; ResX, ResY: Integer): Boolean;
begin
  // if GetDeviceCaps(DC, LOGPIXELSX)<> ResX then
  CommandEx(COMPDF_PrintHDCSetXRes, ResX);
  // if GetDeviceCaps(DC, LOGPIXELSY)<> ResY then
  CommandEx(COMPDF_PrintHDCSetYRes, ResY);
  // 1. Set Pagenumber
  CommandEx(160, PageNO);
  //2. Print using this page number - requires DLL after 1.10.2005!
  Result := CommandEx(161, DC) >= 0;
end;

function TWPViewPDF.GetMetafile(PageNO: Integer): TMetafile;
var acanvas: TMetafileCanvas;
  w, h, res: Integer;
  DC : HDC;
begin
  res := Screen.PixelsPerInch;
  if (PageNO < 0) or (PageNO > PageCount) then
    raise Exception.Create('Page not available')
  else
  begin
    Result := TMetafile.Create();
    w := Command(COMPDF_GetPageWidth);
    h := Command(COMPDF_GetPageHeight);
    // Result.MMWidth := Round((w+1) / 72 * 2540);
    // Result.MMHeight := Round((h+1) / 72 * 2540);
    Result.Width := Round(w * res / 72);
    Result.Height := Round(h * res / 72);
    acanvas := TMetafileCanvas.CreateWithComment(Result, 0,
      'Created by WPViewPDF - www.wptools.de',
      'PDF Metafile - Page ' + IntToStr(PageNo));
    acanvas.Pen.Style := psClear;
    acanvas.Rectangle(0,0, Round(w * res / 72),  Round(h * res / 72));
    DC := acanvas.Handle;
    SetMapMode(DC, MM_ANISOTROPIC);
    SetWindowExtEx(DC, res, res, nil);
    SetViewPortExtEx(DC, res, res, nil);
    SetViewPortOrgEx(DC, 0, 0, nil);
    SetWindowOrgEx(DC, 0, 0, nil);
    try
      PrintHDC(PageNO, DC, res, res);
    finally
      acanvas.Free;
    end;
  end;
end;

{$IFDEF USEPRINTER}

function TWPViewPDF.GetMetafilePrn(PageNO: Integer): TMetafile;
var acanvas: TMetafileCanvas;
  w, h, xres, yres: Integer;
  ADevice, ADriver, APort: array[0..128] of char;
  ADeviceMode: THandle;
  FReferenceDC, DC: HDC;
begin
  if (PageNO < 0) or (PageNO > PageCount) then
    raise Exception.Create('Page not available')
  else
  begin
    Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
    if ADevice <> '' then FReferenceDC := CreateDC(ADriver, ADevice, nil, nil)
    else  FReferenceDC := CreateDC(ADriver, nil, nil, nil);
    xres := GetDeviceCaps(FReferenceDC, LOGPIXELSX);
    yres := GetDeviceCaps(FReferenceDC, LOGPIXELSY);
    Result := TMetafile.Create();
    w := Command(COMPDF_GetPageWidth);
    h := Command(COMPDF_GetPageHeight);
    // Result.MMWidth := Round(w / 72 * 2540);
    // Result.MMHeight := Round(h / 72 * 2540);
    Result.Width := Round(w * xres / 72);
    Result.Height := Round(h * yres / 72);
    acanvas := TMetafileCanvas.CreateWithComment(Result, FReferenceDC,
      'Created by WPViewPDF - www.wptools.de',
      'PDF Metafile - Page ' + IntToStr(PageNo));
    DC := acanvas.Handle;
    acanvas.Pen.Style := psClear;
    acanvas.Rectangle(0,0, Round(xres * xres / 72),  Round(yres * yres / 72));
    SetMapMode(DC, MM_ANISOTROPIC);
    SetWindowExtEx(DC, xres, yres, nil);
    SetViewPortExtEx(DC, xres, yres, nil);
    SetViewPortOrgEx(DC, 0, 0, nil);
    SetWindowOrgEx(DC, 0, 0, nil);
    try
      PrintHDC(PageNO, DC, xres, yres);
    finally
      acanvas.Free;
      if FReferenceDC <> 0 then DeleteDC(FReferenceDC);
    end;
  end;
end;
{$ENDIF}

// --------------------------------------------------------------------

function TWPViewPDF.BeginPrint(Printername: string): Boolean;
begin
  if Printername <> '' then
    CommandStr(COMPDF_SelectPrinter, Printername);
  Result := Command(COMPDF_BeginPrint) > 0;
end;

procedure TWPViewPDF.EndPrint;
begin
  Command(COMPDF_EndPrint);
end;

function TWPViewPDF.PrintPages(StartPage, EndPage: Word): Integer;
begin
  Result := CommandEx(COMPDF_Print, StartPage + (EndPage shl 16));
end;


{$IFDEF USECOMSTREAMS}
// Implementation of 'LoadFromStream using COM Streams ...

function TWPViewPDF.LoadFromStream(stream: TStream): Boolean;
var adapter: TStreamAdapter;
begin
  adapter := TStreamAdapter.Create(stream, soReference);
  try
    Result := CommandEx(COMPDF_AppendIStream, Longint(IStream(adapter))) = 0;
  finally
    // adapter.Free;  causes AV ???
  end;
end;

{$ELSE}
// For Delphi we prefer the "EventStream" Implementation
// since it has no COM overhead and does not require any allocation

function TWPViewPDF.LoadFromStream(stream: TStream): Boolean;
var events: TEventStreamFkt;
begin
  events.Stream := stream;
  events.OnStreamRead := Addr(ReadEvent);
  events.OnStreamWrite := Addr(WriteEvent);
  events.OnStreamSeek := Addr(SeekEvent);
  try                                        
    Result := CommandEx(COMPDF_AppendEStream, Cardinal(@events)) = 0;
  except
    Result := false;
  end;
end;
{$ENDIF USECOMSTREAMS}
// --------------------------------------------------------------------

procedure TWPViewPDF.Loaded;
begin
  inherited Loaded;
  ViewOptions := FViewOptions;
  ViewControls := FViewControls;
  LoadPassword := FLoadPassword;
  FileName := FFileName;
end;

procedure TWPViewPDF.ViewerStart(DLLNameAndPath, licensename, licensekey: string; licensecode: Integer);
begin
  lickey := licensename + '=' + licensekey;
  liccode := licensecode;
  if DLLNameAndPath <> '' then
  begin
    SetDLLName(DLLNameAndPath);
  end;
  if assigned(f_set_lic) then f_set_lic(PChar(lickey), liccode);
  if HandleAllocated then CommandStr(COMPDF_SETLICENSE_STR, lickey);
  if HandleAllocated then CommandEx(COMPDF_SETLICENSE_INT, licensecode);
end;


procedure WPPDFViewerStart(licensename, licensekey: string; licensecode: Integer);
begin
  lickey := licensename + '=' + licensekey;
  liccode := licensecode;
  if assigned(f_set_lic) then f_set_lic(PChar(lickey), liccode);
end;

initialization

  DLLHandle := 0;

finalization

  if DLLHandle <> 0 then
  begin
    FreeLibrary(DLLHandle);
    f_set_lic := nil;
    DLLHandle := 0;
  end;

end.

