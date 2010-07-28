unit WPViewPDF1;
{ ------------------------------------------------------------------------------
  TWPViewPDF - PDF Viewer and Print Class by WPCubed GmbH
  -----------------------------------------------------------------------------
  Load PDFViewer DLL and create controls for the window class

  Copyright (C) 2004-2007 - WPCubed GmbH - www.wptools.de
  ------------------------------------------------------------------------------

  Update the global variable WPDFVIEWDLLNAME to change the name
  of the DLL to be loaded

  Version 2.0
  ------------------------------------------------------------------------------
}

// Attention: The DLLs use different window classnames
{-$DEFINE WPVIEWDEMO}
{$DEFINE VIEWPLUS}// for WPViewPDF PLUS

{$DEFINE USEPRINTER}
{$DEFINE VIEWPDF2}



interface

uses Classes, Controls, Forms, Graphics, Windows, Messages, SysUtils
{$IFDEF USECOMSTREAMS}, ActiveX{$ENDIF}
{$IFDEF USEPRINTER}, Printers{$ENDIF}, Dialogs, PDFViewCommands, Registry
{$IFDEF USEINOCX}, ViewPDF01_TLB, WPAutoComponent{$ENDIF};
{$R-}

const
  wpNoSecurity = 0;
  wp40bit = 1;
  wp128bit = 2;

type
  TWPViewPDF = class;

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
    wpDisableZoomHint,
    wpDisableBookmarkView // Only V2
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
  THyperlinkWWWEvent = procedure(Sender: TObject; const Url: string) of object;

{$IFDEF T2H}TNotifyEvent = procedure(Sender: TObject) of object; {$ENDIF}

{$IFDEF USEINOCX}
  TWPViewPDFPLUS = class(TWPComComponent, IWPViewPLUS)
{$ELSE}
  TWPViewPDFPLUS = class(TComponent)
{$ENDIF}
  private
    View: TWPViewPDF;
  public
    function Enable(Code: Integer): WordBool; {$IFDEF USEINOCX} safecall; {$ENDIF}
    function SaveToFile(const filename: WideString): WordBool; {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure InfoSetString(const Name, Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure InfoSetTitle(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure InfoSetSubject(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure InfoSetAuthor(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure InfoSetKeywords(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetSecurityMode(Security: Integer); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetSecurityPFlags(P: Integer); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetSecurityUserPW(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetSecurityOwnerPW(const Text: WideString); {$IFDEF USEINOCX} safecall; {$ENDIF}
    // Version 2
    function SaveSelectionToFile(const filename: WideString): WordBool; {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetStampMeta(const PageList: WideString; MetaHandle: Integer); {$IFDEF USEINOCX} safecall; {$ENDIF}
    procedure SetStampMetaUnder(const PageList: WideString; MetaHandle: Integer); {$IFDEF USEINOCX} safecall; {$ENDIF}
    function GetInfoStrings: WideString; {$IFDEF USEINOCX} safecall; {$ENDIF}
  end;

  TWPViewPDF = class(TWinControl)
{$IFDEF USEINOCX}
  public
    IPlus: IWPViewPLUS;
{$ENDIF}
  private
    FCO: Integer;
    FPlus: TWPViewPDFPLUS;
    FHyperlinkHandled: Boolean;
    FOnNeedPassword: TNotifyEvent;
    FOnChangeViewPage: TChangeViewPageEvent;
    FOnHyperlinkPage: THyperlinkPageEvent;
    FOnHyperlinkWWW: THyperlinkWWWEvent;
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
    FInfoItems: TStringList;

    function GetInfoItems: TStrings;
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
    function CommandStrEx(command: Integer; str: string; Param: Cardinal): Integer;
{$ENDIF}
    procedure ViewerStart(DLLNameAndPath, licensename, licensekey: string; licensecode: Integer);
    function DeletePage(N: Integer): Boolean;
    function SelectPage(Mode, Nr: Integer): Integer;
    function UnDeletePage(N: Integer): Boolean;
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
    function WriteJPEG(const Filename: string; PageNo,
      Resolution, Compression: Integer): Boolean;
    function BeginPrint(Printername: string): Boolean;
    procedure EndPrint;
    function PrintPages(StartPage, EndPage: Word): Integer;
    procedure Clear;
    property Page: Integer read GetViewPage write SetViewPage;
    property PageCount: Integer read GetPageCount;
    property DLLName: string read GetDLLName write SetDLLName;
    property Plus: TWPViewPDFPLUS read FPlus;
    property HyperlinkHandled: Boolean read FHyperlinkHandled write FHyperlinkHandled;
    property InfoItems: TStrings read GetInfoItems;
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
    property PopupMenu;
    property BorderStyle: Forms.TBorderStyle read FBorderStyle write SetBorderStyle default Forms.bsNone;
{$ENDIF}
  end;

const
{$IFDEF VIEWPDF2}
  VIEWDLLNAME_DEMO = 'wPDFViewDemo02.dll';
{$IFDEF VIEWPLUS}
  VIEWDLLNAME_FULL = 'wPDFViewPlus02.dll';
{$ELSE}
  VIEWDLLNAME_FULL = 'wPDFView02.dll';
{$ENDIF}
{$ELSE}
  VIEWDLLNAME_DEMO = 'wPDFViewDemo01.dll';
{$IFDEF VIEWPLUS}
  VIEWDLLNAME_FULL = 'wPDFViewPlus01.dll';
{$ELSE}
  VIEWDLLNAME_FULL = 'wPDFView01.dll';
{$ENDIF}
{$ENDIF}

{$IFDEF USEDUMMYCL}VIEW_DUMMY_CLASSNAME = 'wPDFView_by_WPCubed_GmbH'; {$ENDIF}

procedure WPPDFViewerStart(licensename, licensekey: string; licensecode: Integer);
function WPViewPDFLoadDLL(dllname: string): Boolean;

type
  fktpdfPrint = function(filename: PChar; password: PChar;
    licname, lickey: PChar; liccode: Cardinal;
    options: PChar): Integer; stdcall;

  fktpdfMerge = function(filename: PChar; newfile: PChar;
    password: PChar;
    licname, lickey: PChar; liccode: Cardinal; licpluscode: Cardinal;
    options: PChar): Integer; stdcall;

var
{$IFDEF USEINOCX}
  WPViewPDFDLLNAME: string = 'AUTO';
{$ELSE}
{$IFNDEF WPVIEWDEMO}
  WPViewPDFDLLNAME: string = VIEWDLLNAME_FULL;
{$ELSE}
  WPViewPDFDLLNAME: string = VIEWDLLNAME_DEMO;
{$ENDIF}
{$ENDIF}
  WPLoadedViewerOK: Boolean;
  WPViewPDFDLLHandle: Cardinal;
  WPViewPDFDLLLoadedName : string;

  wpview_pdfMerge: fktpdfMerge;
  wpview_pdfPrint: fktpdfPrint;

implementation

var
  WPViewPDFClassNAME: string; // Set in CreateParams depending on WPViewPDFDLLNAME

// -----------------------------------------------------------------------------
// Requires PLUS License
// -----------------------------------------------------------------------------

function TWPViewPDFPLUS.Enable(Code: Integer): WordBool;
begin
  Result := View.CommandEx(COMPDF_EnablePLUS, Code) <> 0;
end;

function TWPViewPDFPLUS.SaveToFile(const filename: WideString): WordBool;
begin
  Result := View.CommandStr(COMPDF_SaveToFile, filename) <> 0;
end;

function TWPViewPDFPLUS.SaveSelectionToFile(const filename: WideString): WordBool;
begin
  Result := View.CommandStr(COMPDF_SaveSelectionToFile, filename) <> 0;
end;

procedure TWPViewPDFPLUS.InfoSetString(const Name, Text: WideString);
begin
  View.CommandStr(COMPDF_SetString, Name + '=' + Text);
end;

procedure TWPViewPDFPLUS.InfoSetTitle(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetTitle, Text);
end;

procedure TWPViewPDFPLUS.InfoSetSubject(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetSubject, Text);
end;

procedure TWPViewPDFPLUS.InfoSetAuthor(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetAuthor, Text);
end;

procedure TWPViewPDFPLUS.InfoSetKeywords(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetKeywords, Text);
end;

procedure TWPViewPDFPLUS.SetSecurityMode(Security: Integer);
begin
  View.CommandEx(COMPDF_SetSecurityMode, Security);
end;

procedure TWPViewPDFPLUS.SetSecurityPFlags(P: Integer);
begin
  View.CommandEx(COMPDF_SetSecurityFlags, P);
end;

procedure TWPViewPDFPLUS.SetSecurityUserPW(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetSecurityUser, Text);
end;

procedure TWPViewPDFPLUS.SetSecurityOwnerPW(const Text: WideString);
begin
  View.CommandStr(COMPDF_SetSecurityOwner, Text);
end;

procedure TWPViewPDFPLUS.SetStampMeta(const PageList: WideString; MetaHandle: Integer);
begin
  View.CommandStrEx(COMPDF_StampMetafile, PageList, MetaHandle);
end;


procedure TWPViewPDFPLUS.SetStampMetaUnder(const PageList: WideString; MetaHandle: Integer);
begin
  View.CommandStrEx(COMPDF_StampMetafileUnder, PageList, MetaHandle);
end;

function TWPViewPDFPLUS.GetInfoStrings: WideString;
var l: Integer;
begin
  l := View.Command(COMPDF_GetInfoItemsLenW);
  if l<=0 then Result := '' else
  begin
    SetLength(Result, l);
    View.CommandEx(COMPDF_GetTextBufW, Cardinal(@Result[1]));
  end;
end;

// Properties -----------------------------------------------

function TWPViewPDF.GetInfoItems: TStrings;
var l: Integer;
  s: string;
begin
  l := Command(COMPDF_GetInfoItemsLen);
  if l <= 0 then FInfoItems.Clear else
  begin
    SetLength(s, l);
    CommandEx(COMPDF_GetTextBuf, Cardinal(PChar(s)));
    FInfoItems.Text := s;
    s := '';
  end;
  Result := FInfoItems;
end;


procedure TWPViewPDF.SetLoadPassword(const x: string);
begin
  FLoadPassword := x;
  CommandStr(COMPDF_SetLoadPassword, x);
end;

function TWPViewPDF.DeletePage(N: Integer): Boolean;
begin
  Result := CommandEx(COMPDF_DeletePage, N) <> 0;
end;

function TWPViewPDF.SelectPage(Mode, Nr: Integer): Integer;
begin
  if Mode = -1 then Result := CommandEx(COMPDF_PageSelectionDel, Nr)
  else if Mode = 1 then Result := CommandEx(COMPDF_PageSelectionAdd, Nr)
  else if (Mode = 0) and (nr = -1) then Result := CommandEx(COMPDF_PageSelectionInvert, 0)
  else if Mode = 0 then Result := CommandEx(COMPDF_PageSelectionClear, 0);
end;

function TWPViewPDF.UnDeletePage(N: Integer): Boolean;
begin
  Result := CommandEx(COMPDF_UnDeletePage, N) <> 0;
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

function WPViewPDFLoadDLL(dllname: string): Boolean;
var
  i: Integer; s: string;
  procedure CheckReg(aName : string = 'Path');
  var Registry: TRegistry;
  begin
    Registry := TRegistry.Create(KEY_READ);
        Registry.RootKey := HKEY_CURRENT_USER;
        Registry.OpenKey('Software\WPCubed\WPViewPDF', true);
        s := Registry.ReadString(aName);
        Registry.Free;
        if s <> '' then dllname := s else
        begin
          Registry := TRegistry.Create(KEY_READ);
          Registry.RootKey := HKEY_LOCAL_MACHINE;
          Registry.OpenKey('Software\WPCubed\WPViewPDF', true);
          s := Registry.ReadString(aName);
          Registry.Free;
          if s <> '' then dllname := s else
          begin
            dllname := 'wPDFView02.dll';
          end;
        end;
  end;
  var Registry: TRegistry;
begin
  Result := FALSE;
  if dllname <> '' then
  begin
    // The demo first checks the registry
    if dllname = 'AUTODEMO' then
         CheckReg('Demo');
    // Automatic Engine loanding - first look for registred DLLs, then check registry
    if (dllname = 'AUTO') or (dllname = 'AUTODEMO') then
    begin
      { This reads the name of the OCX
        SetLength(s, 256);
        SetLength(s, GetModuleFileName(HInstance, PChar(s), Length(s))); }

      // Look for DLL in same directory as application

      s := ExtractFilePath(Application.ExeName);
      if FileExists(s + 'wPDFViewPlus02.dll') then
        dllname := s + 'wPDFViewPlus02.dll'
      else if FileExists(s + 'wPDFView02.dll') then
        dllname := s + 'wPDFView02.dll'
      else if FileExists(s + 'wPDFViewDemo02.dll') then
        dllname := s + 'wPDFViewDemo02.dll'
      else if FileExists(s + 'wPDFViewPlus01.dll') then
        dllname := s + 'wPDFViewPlus01.dll'
      else if FileExists(s + 'wPDFView01.dll') then
        dllname := s + 'wPDFView01.dll'
      else if FileExists(s + 'wPDFViewDemo01.dll') then
        dllname := s + 'wPDFViewDemo01.dll'
      else
      begin
        CheckReg;
      end;
    end;

    if pos('{hkcu}', lowercase(dllname)) = 1 then
    begin
      i := Length(dllname);
      while (i > 0) and (dllname[i] <> '\') do dec(i);
      Registry := TRegistry.Create(KEY_READ);
      Registry.RootKey := HKEY_CURRENT_USER;
      s := Copy(dllname, 7, i - 7);
      Registry.OpenKey(s, true);
      s := Copy(dllname, i + 1, 255);
      dllname := Registry.ReadString(s);
      Registry.Free;
    end
    else if pos('{hklm}', lowercase(dllname)) = 1 then
    begin
      i := Length(dllname);
      while (i > 0) and (dllname[i] <> '\') do dec(i);
      Registry := TRegistry.Create(KEY_READ);
      Registry.RootKey := HKEY_LOCAL_MACHINE;
      Registry.OpenKey(Copy(dllname, 7, i - 7), true);
      dllname := Registry.ReadString(Copy(dllname, i + 1, 255));
      Registry.Free;
    end;


    WPViewPDFDLLHandle := LoadLibrary(PChar(dllname));
    if WPViewPDFDLLHandle <= 0 then
    begin
{$IFNDEF QUIET}
      ShowMessage('Cannot load DLL ' + dllname);
{$ENDIF}
      WPViewPDFDLLHandle := 0;
      wpview_pdfMerge := nil;
      wpview_pdfPrint := nil;
    end else
    begin
      WPViewPDFDLLLoadedName := dllname;
      f_set_lic := GetProcAddress(WPViewPDFDLLHandle, 'wpdfSetLicense');
      if not assigned(f_set_lic) then
      begin ShowMessage('Wrong DLL!');
        FreeLibrary(WPViewPDFDLLHandle);
        WPViewPDFDLLHandle := 0;
        f_set_lic := nil;
      end else
      begin
        f_set_lic(PChar(lickey), liccode);
        wpview_pdfMerge := GetProcAddress(WPViewPDFDLLHandle, 'pdfMerge');
        wpview_pdfPrint := GetProcAddress(WPViewPDFDLLHandle, 'pdfPrint');
      end;
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
    if WPViewPDFDLLHandle <> 0 then
    begin
      FreeLibrary(WPViewPDFDLLHandle);
      WPViewPDFDLLHandle := 0;
      f_set_lic := nil;
      wpview_pdfMerge := nil;
      wpview_pdfPrint := nil;
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
      if bHasHandle and (WPViewPDFDLLHandle <= 0) then
        WPViewPDFDLLNAME := '';
    end;
    if bWasFocused and HandleAllocated then Windows.SetFocus(Handle);
  end;
end;

procedure TWPViewPDF.CreateParams(var Params: TCreateParams);
var dummy: WNDCLASS;
begin
  if not (csDesigning in ComponentState) and
    (WPViewPDFDLLHandle <= 0) then
    WPViewPDFLoadDLL(WPViewPDFDLLNAME);
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_TABSTOP;
  if WPViewPDFDLLHandle > 0 then
  begin
    // ------------------------------------------------------------------------
    if Pos('DEMO', Uppercase(ExtractFileName(WPViewPDFDLLLoadedName))) > 0 then
      WPViewPDFClassNAME := 'WPCubed_PDFVIEW_Demo_01'
    else WPViewPDFClassNAME := 'WPCubed_PDFVIEW_01';
    // ------------------------------------------------------------------------

    if not GetClassInfo(HInstance, PChar(WPViewPDFClassNAME), dummy) then
    begin
      ShowMessage('Windowclass ' + WPViewPDFClassNAME + ' cannot be found!');
      FreeLibrary(WPViewPDFDLLHandle);
      f_set_lic := nil;
      wpview_pdfMerge := nil;
      wpview_pdfPrint := nil;
      WPViewPDFDLLHandle := 0;
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

  if FBorderStyle = Forms.bsSingle then
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
var page, x, y: Integer;
begin
  FHyperlinkHandled := FALSE;
  if assigned(FOnHyperlinkPage) then
  begin
    page := Message.WParam;
    x := Message.LParam shr 16;
    y := Message.LParam and $FFFF;
    FOnHyperlinkPage(Self, Page, x, y);
    if FHyperlinkHandled then
      Message.Result := 7777; // Magic to flag "true"
  end;
end;

procedure TWPViewPDF.WMViewerHyperlinkURL(var Message: TMessage);
var url: string;
begin
  FHyperlinkHandled := FALSE;
  if assigned(FOnHyperlinkWWW) then
  begin
    if Message.LParam <> 0 then
    begin
      url := StrPas(PChar(Message.LParam));
      FOnHyperlinkWWW(Self, url);
      if FHyperlinkHandled then
        Message.Result := 7777;
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
  if (csDesigning in ComponentState) or (WPViewPDFDLLHandle <= 0) then
  begin
    dc := GetDC(Handle);
    Canvas := TCanvas.Create;
    Canvas.Handle := dc;
    try
      Canvas.Rectangle(0, 0, Width, Height);
      Canvas.Font.Name := 'Verdana';
      Canvas.Font.Size := 11;
      y := 6;
{$IFDEF VIEWPDF2}
      Canvas.TextOut(4, y, 'WPViewPDF V2.0');
{$ELSE}
      Canvas.TextOut(4, y, 'WPViewPDF V1.0');
{$ENDIF}
      inc(y, Canvas.TextHeight('Ag'));
      Canvas.TextOut(4, y, 'by WPCubed GmbH');
{$IFDEF VIEWPDF2}
      Canvas.Pen.Color := clRed;
{$ENDIF}
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
  FPlus := TWPViewPDFPLUS.Create(Self);
  FPlus.View := Self;
  FInfoItems := TStringList.Create;

{$IFDEF USEINOCX}
  FPlus._PtrPtr := @FPlus;
  FPlus.InitCOM(IWPViewPLUS);
  FPlus.QueryInterface(IID_IWPViewPLUS, IPlus);
  //IPlus := FPlus as IWPViewPLUS;
{$ENDIF}


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
{$IFDEF USEINOCX}
  IPlus := nil;
{$ENDIF}
  FPlus.Free;
  FInfoItems.Free;
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

function TWPViewPDF.CommandStrEx(command: Integer; str: string; Param: Cardinal): Integer;
var com: TWPComRecStruct;
begin
  FillChar(com, SizeOf(com), 0);
  com.StrParam := PChar(str);
  com.Param := Param;
  Result := SendMessage(Handle, WM_PDF_EXCOMMAND, command + FCO, Cardinal(@com));
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
  DC: HDC;
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
    acanvas.Rectangle(0, 0, Round(w * res / 72), Round(h * res / 72));
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
    else FReferenceDC := CreateDC(ADriver, nil, nil, nil);
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
    acanvas.Rectangle(0, 0, Round(xres * xres / 72), Round(yres * yres / 72));
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

function TWPViewPDF.WriteJPEG(const Filename: string; PageNo,
  Resolution, Compression: Integer): Boolean;
var a, b: Integer; s: string;
begin
  if Resolution = 0 then Resolution := 96;
  a := CommandEx(COMPDF_MakeJPEGSetRes, Resolution);
  b := CommandEx(COMPDF_MakeJPEGSetCompression, Resolution);
  s := Filename;
  Result := CommandStr(COMPDF_MakeJPEG, IntToStr(PageNo) + '=' + s) > 0;
  CommandEx(COMPDF_MakeJPEGSetRes, a);
  CommandEx(COMPDF_MakeJPEGSetCompression, b);
end;

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

  WPViewPDFDLLHandle := 0;

finalization

  lickey := '';

  if WPViewPDFDLLHandle <> 0 then
  begin
    FreeLibrary(WPViewPDFDLLHandle);
    f_set_lic := nil;
    WPViewPDFDLLHandle := 0;
  end;

end.

