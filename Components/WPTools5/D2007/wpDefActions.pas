unit wpDefActions;
(*******************************************************************************
 * WPTools V5+6 - THE word processing component for VCL
 * Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
 * St. Ingbert Str. 30, 81541 Munich, Germany
 * Tel.: +49-89-49053501, Fax.: 49-89-49053504
 * WEB: http://www.wpcubed.com   mailto: support@wptools.de
 *******************************************************************************
  PREDEFINED ACTIONLIST AND TOOLS
 ******************************************************************************)

  //16.10.2008

interface

{$I WPINC.INC}

uses
  SysUtils, Windows, Classes, Menus, Forms, WPCtrRich,
  {$IFDEF WPXPRN} WPX_Dialogs, {$ELSE} Dialogs, {$ENDIF} 
  WPCtrMemo, WPRTEDefs, WPObj_Image, WPPrvFrm, WpPagPrp, WPCTRStyleCol,
  WP1Style, WPStyles, WPTabdlg, WPBltDlg, WpParBrd, WpParPrp, WPTblDlg,
  WPUtil,
{$IFDEF WP6}
 WPSymDlgEx,
{$ELSE}
 WPSymDlg,
{$ENDIF}
  WPAction, ActnList, ImgList, Controls, wpManHeadFoot
{$IFDEF WPREPORTER}
  , WPRTEReport, WPRepED
{$ENDIF}
{$IFDEF WPPREMIUM}
  , WPOBJ_TextBox
{$ENDIF}
  ;

type
  TWPDefaultActions = class;
  TWPGetCurrentEditor =
    procedure(Sender: TObject; var wp: TWPCustomRichText) of object;

  TWPGlobalProcedure = procedure; // GLOBAL! not 'of object' !

  TWPDefAct = class(TDataModule)
  {$IFNDEF T2H}
    MainMenu: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    CloseFile1: TMenuItem;
    N1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Export1: TMenuItem;
    N2: TMenuItem;
    PageLayout1: TMenuItem;
    PrintPreview1: TMenuItem;
    Print1: TMenuItem;
    N3: TMenuItem;
    MailTo1: TMenuItem;
    Properties1: TMenuItem;
    N4: TMenuItem;
    CloseApp1: TMenuItem;
    Edit1: TMenuItem;
    Redo1: TMenuItem;
    Undo1: TMenuItem;
    N5: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N6: TMenuItem;
    Delete1: TMenuItem;
    ParagraphFormat1: TMenuItem;
    CharacterFormat1: TMenuItem;
    ext1: TMenuItem;
    SelectAll1: TMenuItem;
    All1: TMenuItem;
    able1: TMenuItem;
    N7: TMenuItem;
    Search1: TMenuItem;
    Replace1: TMenuItem;
    View1: TMenuItem;
    Normal1: TMenuItem;
    PageLayout2: TMenuItem;
    Zoom1: TMenuItem;
    PageWidth1: TMenuItem;
    FullPage1: TMenuItem;
    DoublePage1: TMenuItem;
    N10: TMenuItem;
    N4001: TMenuItem;
    N2001: TMenuItem;
    N1001: TMenuItem;
    N751: TMenuItem;
    N501: TMenuItem;
    N251: TMenuItem;
    N11: TMenuItem;
    humbNails1: TMenuItem;
    N9: TMenuItem;
    ManageHeaderFooter1: TMenuItem;
    N8: TMenuItem;
    ShowVertRuler1: TMenuItem;
    ShowThumbNails1: TMenuItem;
    Insert1: TMenuItem;
    PageBreak1: TMenuItem;
    SectionBreak1: TMenuItem;
    N12: TMenuItem;
    Graphic1: TMenuItem;
    PageNumbers1: TMenuItem;
    Format1: TMenuItem;
    Font1: TMenuItem;
    Paragraph1: TMenuItem;
    Numbers1: TMenuItem;
    Border1: TMenuItem;
    ColumnsMenu1: TMenuItem;
    abstops1: TMenuItem;
    N14: TMenuItem;
    Capitalisation1: TMenuItem;
    ExtrasMenu: TMenuItem;
    Spellcheck1: TMenuItem;
    SpellAsYouGo1: TMenuItem;
    hesaurus1: TMenuItem;
    able2: TMenuItem;
    NewTable1: TMenuItem;
    Insert2: TMenuItem;
    Rows1: TMenuItem;
    Columns2: TMenuItem;
    Delete2: TMenuItem;
    Row1: TMenuItem;
    Column1: TMenuItem;
    Select1: TMenuItem;
    able4: TMenuItem;
    Row2: TMenuItem;
    Column2: TMenuItem;
    N15: TMenuItem;
    SplitCell1: TMenuItem;
    SplitTable1: TMenuItem;
    N17: TMenuItem;
    Info1: TMenuItem;
    Info2: TMenuItem;
    InsNumberIcons: TImageList;
    StdIcons: TImageList;
    StdActions: TActionList;
    WPABBottom1: TWPABBottom;
    WPAInsertField1: TWPAInsertField;
    WPAEditHyperlink1: TWPAEditHyperlink;
    WPAInsertNextPage: TWPAInsertNumber;
    WPABLeft1: TWPABLeft;
    WPABTop1: TWPABTop;
    WPABAllOff1: TWPABAllOff;
    WPADelRow1: TWPADelRow;
    WPABInner1: TWPABInner;
    WPABOuter1: TWPABOuter;
    WPACreateTable1: TWPACreateTable;
    WPACombineCell1: TWPACombineCell;
    WPASplitCells1: TWPASplitCells;
    WPAInsRow1: TWPAInsRow;
    WPASelectColumn1: TWPASelectColumn;
    WPASelectRow1: TWPASelectRow;
    WPAZoomOut1: TWPAZoomOut;
    WPAZoomIn1: TWPAZoomIn;
    WPAFitHeight1: TWPAFitHeight;
    WPAFitWidth1: TWPAFitWidth;
    WPAPrint1: TWPAPrint;
    WPAPrinterSetup1: TWPAPrinterSetup;
    WPAPriorPage1: TWPAPriorPage;
    WPANextPage1: TWPANextPage;
    WPALeft1: TWPALeft;
    WPACenter1: TWPACenter;
    WPARight1: TWPARight;
    WPAJustified1: TWPAJustified;
    WPABullets1: TWPABullets;
    WPANumbers1: TWPANumbers;
    WPADecIndent1: TWPADecIndent;
    WPAIncIndent1: TWPAIncIndent;
    WPAOpen1: TWPAOpen;
    WPASave1: TWPASave;
    WPAExit1: TWPAExit;
    WPAClose1: TWPAClose;
    WPANew1: TWPANew;
    WPAUndo1: TWPAUndo;
    WPACopy1: TWPACopy;
    WPACut1: TWPACut;
    WPAPaste1: TWPAPaste;
    WPASearch1: TWPASearch;
    WPAReplace1: TWPAReplace;
    WPASellAll1: TWPASellAll;
    WPAHideSelection1: TWPAHideSelection;
    WPASpellcheck1: TWPASpellcheck;
    WPACancel1: TWPACancel;
    WPADelete1: TWPADelete;
    WPAAdd1: TWPAAdd;
    WPAEdit1: TWPAEdit;
    WPANext1: TWPANext;
    WPABack1: TWPABack;
    WPAOK1: TWPAOK;
    WPAToEnd1: TWPAToEnd;
    WPAToStart1: TWPAToStart;
    WPANorm1: TWPANorm;
    WPABold1: TWPABold;
    WPAItalic1: TWPAItalic;
    WPAProtected1: TWPAProtected;
    WPAHidden1: TWPAHidden;
    WPARTFCode1: TWPARTFCode;
    WPAUnderline1: TWPAUnderline;
    WPAStrikeout1: TWPAStrikeout;
    WPASubscript1: TWPASubscript;
    WPASuperscript1: TWPASuperscript;
    WPAInsCol1: TWPAInsCol;
    WPADelCol1: TWPADelCol;
    WPARedo1: TWPARedo;
    WPADeleteText1: TWPADeleteText;
    WPAInsertPagNo: TWPAInsertNumber;
    WPAIsOutlineMode1: TWPAIsOutlineMode;
    WPAInOutlineUp1: TWPAInOutlineUp;
    WPAInOutlineDown1: TWPAInOutlineDown;
    WPAInsertPriorPage: TWPAInsertNumber;
    WPAInsertPageCount: TWPAInsertNumber;
    WPAInsertDate: TWPAInsertNumber;
    WPASpellAsYouGo1: TWPASpellAsYouGo;
    WPAStartThesaurus1: TWPAStartThesaurus;
    WPTableDlg1: TWPTableDlg;
    WPParagraphPropDlg1: TWPParagraphPropDlg;
    WPParagraphBorderDlg1: TWPParagraphBorderDlg;
    WPBulletDlg1: TWPBulletDlg;
    WPTabDlg1: TWPTabDlg;
    WPStyleDlg1: TWPStyleDlg;
    WPOneStyleDlg1: TWPOneStyleDlg;
    WPStyleCollection1: TWPStyleCollection;
    WPPagePropDlg1: TWPPagePropDlg;
    WPPreviewDlg1: TWPPreviewDlg;
    DemoIcons: TImageList;
    Print2: TMenuItem;
    XA_Close: TAction;
    XA_DocProp: TAction;
    XA_MailTo: TAction;
    XA_Print: TAction;
    XA_PrintDialog: TAction;
    XA_DiaPreview: TAction;
    XA_DiaPageSetup: TAction;
    XA_ExportFile: TAction;
    XA_New: TAction;
    XA_DelParFormat: TAction;
    XA_DelCharFormat: TAction;
    XA_SelectTable: TAction;
    XA_ViewNormal: TAction;
    XA_ViewPageLayout: TAction;
    XA_ViewPageWidth: TAction;
    XA_ViewFullPage: TAction;
    XA_ViewDoublePage: TAction;
    XA_View500: TAction;
    XA_View200: TAction;
    XA_View100: TAction;
    XA_View75: TAction;
    XA_View50: TAction;
    XA_View25: TAction;
    XA_ViewThumbnails: TAction;
    XA_ManageHeaderFooter: TAction;
    XA_ShowHorzRuler: TAction;
    XA_ShowVertRuler: TAction;
    XA_ShowThumbnails: TAction;
    ShowHorzRuler1: TMenuItem;
    XA_InsPageBreak: TAction;
    XA_InsColumnBreak: TAction;
    XA_InsSectionBreak: TAction;
    XA_InsGraphic: TAction;
    XA_InsSymbol: TAction;
    XA_FInsPage: TAction;
    Symbol1: TMenuItem;
    XA_FInsNumPages: TAction;
    XA_FInsNextPage: TAction;
    XA_FInsPriorPage: TAction;
    XA_FInsDate: TAction;
    XA_FInsTime: TAction;
    XA_InsNamedField: TAction;
    Page: TMenuItem;
    NextPage1: TMenuItem;
    PriorPage1: TMenuItem;
    NumPages1: TMenuItem;
    Fields1: TMenuItem;
    Date1: TMenuItem;
    ime1: TMenuItem;
    Named1: TMenuItem;
    N19: TMenuItem;
    MailmergeField1: TMenuItem;
    XA_InsMailmergeField: TAction;
    XA_FrmFontDialog: TAction;
    XA_FrmIndentSpacing: TAction;
    XA_FrmBorder: TAction;
    XA_FrmNumbers: TAction;
    N21: TMenuItem;
    ColumnsOff: TMenuItem;
    Col21: TMenuItem;
    Col31: TMenuItem;
    Col41: TMenuItem;
    XA_Col_Off: TAction;
    XA_Col_2: TAction;
    XA_Col_3: TAction;
    XA_Col_4: TAction;
    ColumnBreak1: TMenuItem;
    XA_FrmCap_Lowercase: TAction;
    XA_FrmCap_Uppercase: TAction;
    Lowercase: TMenuItem;
    Uppercase: TMenuItem;
    XA_FrmCap_Off: TAction;
    XA_FrmTabStops: TAction;
    XA_SpellCheck: TAction;
    XA_SpellAsYouGo: TAction;
    XA_SpellThesaurus: TAction;
    XA_CreateTable: TAction;
    XA_SplitTable: TAction;
    XA_InsHyperlink: TAction;
    XA_InsBookmark: TAction;
    Hyperlink1: TMenuItem;
    N22: TMenuItem;
    Bookmark1: TMenuItem;
    XA_Info: TAction;
    ReportingMenu: TMenuItem;
    InsertField1: TMenuItem;
    PropertyDialog1: TMenuItem;
    CreateReport1: TMenuItem;
    XA_ShowRepBand: TAction;
    XA_CreateReport: TAction;
    WPPreviewDlg2: TWPPreviewDlg;
    GraphicPopupMenu: TPopupMenu;
    ascharacter1: TMenuItem;
    reltoparautowrap1: TMenuItem;
    reltoparwrapleftandright1: TMenuItem;
    reltopagenowrappng1: TMenuItem;
    reltopagewrapleftandright1: TMenuItem;
    GraphicOptions1: TMenuItem;
    ascharacter2: TMenuItem;
    reltoparautowrapleftorright1: TMenuItem;
    reltoparwrapleftandright2: TMenuItem;
    reltopagenowrappng2: TMenuItem;
    reltopagewrapleftandright2: TMenuItem;
    ShowGutter1: TMenuItem;
    InsTextBox: TMenuItem;
    ShowMailMergeFields: TMenuItem;
    ShowSpecialChars: TMenuItem;
    XA_Load: TAction;
    XA_Save: TAction;
    XA_SaveAs: TAction;
    XA_CloseFile: TAction;
    SelectLanguage1: TMenuItem;
    SpellCheckOptions1: TMenuItem;
    underovertext1: TMenuItem;
    InsertFormField1: TMenuItem;
    procedure XA_CloseExecute(Sender: TObject);
    procedure XA_DocPropExecute(Sender: TObject);
    procedure XA_MailToExecute(Sender: TObject);
    procedure XA_PrintExecute(Sender: TObject);
    procedure XA_PrintDialogExecute(Sender: TObject);
    procedure XA_DiaPreviewExecute(Sender: TObject);
    procedure XA_DiaPageSetupExecute(Sender: TObject);
    procedure XA_ExportFileExecute(Sender: TObject);
    procedure XA_NewExecute(Sender: TObject);
    procedure XA_DelParFormatExecute(Sender: TObject);
    procedure XA_DelCharFormatExecute(Sender: TObject);
    procedure XA_SelectTableExecute(Sender: TObject);
    procedure XA_AllViewExecute(Sender: TObject);
    procedure XA_ManageHeaderFooterExecute(Sender: TObject);
    procedure XA_ShowHorzRulerExecute(Sender: TObject);
    procedure XA_ShowVertRulerExecute(Sender: TObject);
    procedure XA_ShowThumbnailsExecute(Sender: TObject);
    procedure XA_InsPageBreakExecute(Sender: TObject);
    procedure XA_InsColumnBreakExecute(Sender: TObject);
    procedure XA_InsSectionBreakExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure XA_InsSymbolExecute(Sender: TObject);
    procedure XA_FInsPageExecute(Sender: TObject);
    procedure XA_InsNamedFieldExecute(Sender: TObject);
    procedure XA_InsMailmergeFieldExecute(Sender: TObject);
    procedure XA_FrmFontDialogExecute(Sender: TObject);
    procedure XA_FrmBorderExecute(Sender: TObject);
    procedure XA_FrmIndentSpacingExecute(Sender: TObject);
    procedure XA_FrmNumbersExecute(Sender: TObject);
    procedure XA_Col_OffExecute(Sender: TObject);
    procedure XA_FrmCap_LowercaseExecute(Sender: TObject);
    procedure XA_FrmCap_UppercaseExecute(Sender: TObject);
    procedure XA_FrmCap_OffExecute(Sender: TObject);
    procedure XA_FrmTabStopsExecute(Sender: TObject);
    procedure XA_SpellCheckExecute(Sender: TObject);
    procedure XA_SpellAsYouGoExecute(Sender: TObject);
    procedure XA_SpellThesaurusExecute(Sender: TObject);
    procedure XA_CreateTableExecute(Sender: TObject);
    procedure XA_InsHyperlinkExecute(Sender: TObject);
    procedure XA_InsBookmarkExecute(Sender: TObject);
    procedure XA_SplitTableExecute(Sender: TObject);
    procedure Info1Click(Sender: TObject);
    procedure XA_InfoExecute(Sender: TObject);
    procedure XA_ShowRepBandExecute(Sender: TObject);
    procedure XA_CreateReportExecute(Sender: TObject);
    procedure XA_InsGraphicExecute(Sender: TObject);
    procedure GraphicOptionsClick(Sender: TObject);
    procedure InsTextBoxClick(Sender: TObject);
    procedure ShowGutter1Click(Sender: TObject);
    procedure ShowMailMergeFieldsClick(Sender: TObject);
    procedure ShowSpecialCharsClick(Sender: TObject);
    procedure XA_LoadExecute(Sender: TObject);
    procedure XA_SaveExecute(Sender: TObject);
    procedure XA_SaveAsExecute(Sender: TObject);
    procedure XA_CloseFileExecute(Sender: TObject);
    procedure MDIActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure SpellCheckOptions1Click(Sender: TObject);
    procedure GraphicPopupMenuPopup(Sender: TObject);
    procedure InsertFormField1Click(Sender: TObject);
  private
    FOwnerComp: TWPDefaultActions;
    FGetWPRichText: TWPGetCurrentEditor;
    FWPManageHeaderFooter: TWPManageHeaderFooter;
    FBookCount, FFieldCount: Integer;
    FOnInfo, FOnInfo2: TWPGlobalProcedure;
    function GetTheWPRichText: TWPCustomRichText;
  {$ENDIF}
  public
{$IFDEF WPREPORTER}
    SuperMerge: TWPSuperMerge;
    BandDialog: TWPReportBandsDialog;
    ReportDest: TWPRichText;
{$ENDIF}

    {$IFDEF WP6}
    WPSymbolDlg1: TWPSymbolDlgEx;
    {$ELSE}
    WPSymbolDlg1: TWPSymbolDlg;
    {$ENDIF}

    //:: Loads the strings from the localisation interface
    procedure LoadStrings;
    //:: Saves the strings to the localisation interface
    procedure SaveStrings;
    property OnInfo: TWPGlobalProcedure read FOnInfo write FOnInfo;
    property OnGetWPRichText: TWPGetCurrentEditor read FGetWPRichText write FGetWPRichText;
    property WPRichText1: TWPCustomRichText read GetTheWPRichText;
  end;

  TWPInitializeActions = procedure(
    ActionModule: TWPDefAct) of object;

  TWPRichTextAction = procedure(
    Sender: TObject;
    ActionModule: TWPDefAct;
    WPRichText: TWPCustomRichText) of object;

  { The component TWPDefaultActions make it easy to use the default actions.
      You can place it on your form, add an item for the controlled TWPRichText object
      and start the application. }
  TWPDefaultActions = class(TComponent)
  private
{$IFNDEF T2H}
    FWPDefAct: TWPDefAct;
    FLastEditor: TWPCustomRichText;
    FAssignMenu: Boolean;
    FOwnerForm: TForm;
    FControlledMemos: TWPEditBoxLinkCollection;
    FOnInfo2: TNotifyEvent;
    FOnInfo1: TNotifyEvent;
    FOnInit: TWPInitializeActions;
    FOnExport: TWPRichTextAction;
    FOnMailTo: TWPRichTextAction;
    FOnClose: TWPRichTextAction;
    FOnCloseFile: TWPRichTextAction;
    FOnNew: TWPRichTextAction;
    FOnLoad: TWPRichTextAction;
    FOnSave: TWPRichTextAction;
    FOnSaveAs: TWPRichTextAction;
    FOnShowHorzRuler: TWPRichTextAction;
    FOnShowVertRuler: TWPRichTextAction;
    FOnShowGutter: TWPRichTextAction;
    FOnShowThumbnails: TWPRichTextAction;
    procedure SetLinks(x: TWPEditBoxLinkCollection);
  protected
    procedure EditBoxStateMsg(Sender: TPersistent; EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg); virtual;
    procedure GetToolsEditor(Sender: TObject; var wp: TWPCustomRichText); virtual;
    procedure Loaded; override;
{$ENDIF}
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    property WPDefAct: TWPDefAct read FWPDefAct;
  published
    property ControlledMemos: TWPEditBoxLinkCollection read
      FControlledMemos write SetLinks;
    property AssignMenu: Boolean read FAssignMenu write FAssignMenu;
    property OnInfo2: TNotifyEvent read FOnInfo2 write FOnInfo2;
    property OnInfo1: TNotifyEvent read FOnInfo1 write FOnInfo1;
    property OnInit: TWPInitializeActions read FOnInit write FOnInit;
    property OnExport: TWPRichTextAction read FOnExport write FOnExport;
    property OnMailTo: TWPRichTextAction read FOnMailTo write FOnMailTo;
    {:: This event is triggered when the user selectes the 'Close Application' menu item. }
    property OnClose: TWPRichTextAction read FOnClose write FOnClose;
    property OnCloseFile: TWPRichTextAction read FOnCloseFile write FOnCloseFile;
    property OnNew: TWPRichTextAction read FOnNew write FOnNew;
    property OnLoad: TWPRichTextAction read FOnLoad write FOnLoad;
    property OnSave: TWPRichTextAction read FOnSave write FOnSave;
    property OnSaveAs: TWPRichTextAction read FOnSaveAs write FOnSaveAs;
    property OnShowHorzRuler: TWPRichTextAction read FOnShowHorzRuler write FOnShowHorzRuler;
    property OnShowVertRuler: TWPRichTextAction read FOnShowVertRuler write FOnShowVertRuler;
    property OnShowGutter: TWPRichTextAction read FOnShowGutter write FOnShowGutter;
    property OnShowThumbnails: TWPRichTextAction read FOnShowThumbnails write FOnShowThumbnails;


  end;


{ must be created by main form !
  var WPDefAct: TWPDefAct;  }


implementation

uses WPDocPropDlg;

{$R *.dfm}

procedure TWPDefAct.DataModuleCreate(Sender: TObject);
begin
{$IFDEF WP6}
WPSymbolDlg1:= TWPSymbolDlgEx.Create(self);
{$ELSE}
WPSymbolDlg1:= TWPSymbolDlg.Create(Self);
{$ENDIF}
{$IFNDEF WPPREMIUM}
{$IFNDEF SHOW_WPPREMIUM}
  ColumnBreak1.Visible := FALSE;
  ColumnsMenu1.Visible := FALSE;
  InsTextBox.Visible := FALSE;
{$ENDIF}
  XA_InsColumnBreak.Enabled := FALSE;
  XA_Col_Off.Enabled := FALSE;
  XA_Col_2.Enabled := FALSE;
  XA_Col_3.Enabled := FALSE;
  XA_Col_4.Enabled := FALSE;
  InsTextBox.Enabled := FALSE;
{$ELSE} // for WPTools Premium
  InsTextBox.Visible := TRUE;
  ColumnBreak1.Visible := TRUE;
  ColumnsMenu1.Visible := TRUE;
{$ENDIF}
  ExtrasMenu.Visible := FALSE;
{$IFDEF WPREPORTER}
  BandDialog := TWPReportBandsDialog.Create(Self);
{$ELSE}
  ReportingMenu.Visible := FALSE;
{$ENDIF}
end;

procedure TWPDefAct.DataModuleDestroy(Sender: TObject);
var i : Integer;
begin
  for i:=StdActions.ActionCount - 1 downto 0 do
      StdActions.Actions[i].Free;
  FreeAndnil(WPSymbolDlg1);
  FreeAndNil(FWPManageHeaderFooter);
end;

function TWPDefAct.GetTheWPRichText: TWPCustomRichText;
begin
  if Assigned(FGetWPRichText) then
  begin
    Result := nil;
    FGetWPRichText(Self, Result);
{$IFDEF WPREPORTER}
    if ReportingMenu.Visible <> (SuperMerge <> nil) then
      ReportingMenu.Visible := SuperMerge <> nil;
{$ENDIF}
  end
  else raise Exception.Create('Please assign event TWPDefAct.OnGetWPRichText');
end;

procedure TWPDefAct.MDIActionsUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action <> XA_Load) and (Action <> XA_New) and (Action <> XA_Info) and (Action <> XA_Close) then
  begin
    if GetTheWPRichText = nil then
    begin
      Handled := TRUE;
      (Action as TAction).Enabled := FALSE;
    end else (Action as TAction).Enabled := TRUE;
  end;
end;

// -------------------------
// -------- File Menu
// -------------------------


procedure TWPDefAct.XA_CloseExecute(Sender: TObject);
begin
     // TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnClose) then
    FOwnerComp.FOnClose(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_DocPropExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
    with TWPDocProperties.Create(WPRichText1) do
    try
      Source := Self.WPRichText1;
      ShowModal;
    finally
      Free;
    end;
end;

procedure TWPDefAct.XA_MailToExecute(Sender: TObject);
begin
   // TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnMailTo) then
    FOwnerComp.FOnMailTo(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_PrintExecute(Sender: TObject);
var b: Boolean;
begin
  if WPRichText1 <> nil then
  begin
    b := WPRichText1.InsertPointAttr.Hidden;
    try
      WPRichText1.InsertPointAttr.Hidden := TRUE;
      WPRichText1.Print;
    finally
      WPRichText1.InsertPointAttr.Hidden := b;
    end;
  end;
end;

procedure TWPDefAct.XA_PrintDialogExecute(Sender: TObject);
var b: Boolean;
begin
  if WPRichText1 <> nil then
  begin
    b := WPRichText1.InsertPointAttr.Hidden;
    try
      WPRichText1.InsertPointAttr.Hidden := TRUE;
      WPRichText1.PrintDialog;
    finally
      WPRichText1.InsertPointAttr.Hidden := b;
    end;
  end;
end;

procedure TWPDefAct.XA_DiaPreviewExecute(Sender: TObject);
begin
  WPPreviewDlg1.EditBox := WPRichText1;
  {$IFDEF PREVIEW_FULL50}
  WPPreviewDlg1.WindowState := wsMaximized;
  WPPreviewDlg1.ZoomMode := wpPvFullPage; // wp50Percent;
  {$ENDIF}
  WPPreviewDlg1.Execute;
end;

procedure TWPDefAct.XA_DiaPageSetupExecute(Sender: TObject);
begin
  WPPagePropDlg1.EditBox := WPRichText1;
  WPPagePropDlg1.Execute;
end;

procedure TWPDefAct.XA_ExportFileExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) and (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnExport) then
    FOwnerComp.FOnExport(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_NewExecute(Sender: TObject);
begin
  //TODO: Load Template ?
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnNew) then
    FOwnerComp.FOnNew(Sender, Self, WPRichText1)
  else if WPRichText1 <> nil then
  begin
    if WPRichText1.CanClose then
      WPRichText1.Clear;
    WPRichText1.CheckHasBody;
  end;
end;

procedure TWPDefAct.XA_LoadExecute(Sender: TObject);
begin
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnLoad) then
    FOwnerComp.FOnLoad(Sender, Self, WPRichText1)
  else if WPRichText1 <> nil then WPRichText1.Load;
end;

procedure TWPDefAct.XA_CloseFileExecute(Sender: TObject);
begin
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnCloseFile) then
    FOwnerComp.FOnCloseFile(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_SaveExecute(Sender: TObject);
begin
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnSave) then
    FOwnerComp.FOnSave(Sender, Self, WPRichText1)
  else if WPRichText1 <> nil then WPRichText1.Save;
end;

procedure TWPDefAct.XA_SaveAsExecute(Sender: TObject);
begin
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnSaveAs) then
    FOwnerComp.FOnSaveAs(Sender, Self, WPRichText1)
  else if WPRichText1 <> nil then WPRichText1.SaveAs;
end;

// -------------------------
// -------- EDIT Menu
// -------------------------

procedure TWPDefAct.XA_DelParFormatExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then WPRichText1.TextCursor.CurrAttribute.ClearAttr(true, false);
end;

procedure TWPDefAct.XA_DelCharFormatExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then WPRichText1.TextCursor.CurrAttribute.ClearAttr(false, true);
end;

procedure TWPDefAct.XA_SelectTableExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) and WPRichText1.InTable then
    WPRichText1.SelectThisTable;
end;

procedure TWPDefAct.XA_AllViewExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
    WPRichText1.SetZoomMode((Sender as TAction).Tag);
end;

procedure TWPDefAct.XA_ManageHeaderFooterExecute(Sender: TObject);
begin
  if FWPManageHeaderFooter = nil then
    FWPManageHeaderFooter := TWPManageHeaderFooter.Create(Self);
  FWPManageHeaderFooter.WPRichText := WPRichText1;
  FWPManageHeaderFooter.Show;
end;


procedure TWPDefAct.ShowMailMergeFieldsClick(Sender: TObject);
begin
  WPRichText1.InsertPointAttr.Hidden :=
    not WPRichText1.InsertPointAttr.Hidden;
end;

procedure TWPDefAct.ShowSpecialCharsClick(Sender: TObject);
begin
  if wpShowCR in WPRichText1.ViewOptions then
    WPRichText1.ViewOptions := WPRichText1.ViewOptions -
      [wpShowCR, wpShowFF, wpShowNL, wpShowSPC,
      wpShowHardSPC, wpShowTAB] else
    WPRichText1.ViewOptions := WPRichText1.ViewOptions +
      [wpShowCR, wpShowFF, wpShowNL, wpShowSPC, wpShowHardSPC, wpShowTAB];
end;

procedure TWPDefAct.XA_ShowHorzRulerExecute(Sender: TObject);
begin
  //TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnShowHorzRuler) then
    FOwnerComp.FOnShowHorzRuler(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_ShowVertRulerExecute(Sender: TObject);
begin
  //TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnShowVertRuler) then
    FOwnerComp.FOnShowVertRuler(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.XA_ShowThumbnailsExecute(Sender: TObject);
begin
   // TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnShowThumbnails) then
    FOwnerComp.FOnShowThumbnails(Sender, Self, WPRichText1);
end;

procedure TWPDefAct.ShowGutter1Click(Sender: TObject);
begin
   // TODO
  if (FOwnerComp <> nil) and
    assigned(FOwnerComp.FOnShowGutter) then
    FOwnerComp.FOnShowGutter(Sender, Self, WPRichText1);
end;


// -------------------------
// -------- Insert Menu
// -------------------------

procedure TWPDefAct.XA_InsGraphicExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) then WPRichText1.InsertGraphicDialog;
end;

procedure TWPDefAct.InsTextBoxClick(Sender: TObject);
{$IFDEF WPPREMIUM}
var obj: TWPORTFTextBox;
  txtobj: TWPTextObj;
begin
  if (WPRichText1 <> nil) then
  begin
    if WPRichText1.CursorOnText.Kind <> wpIsBody then
      ShowMessage(WPLoadStr(wpCannotInsObject)) else
    begin
      obj := TWPORTFTextBox.Create(WPRichText1);
      obj.WidthTW := 3000;
      obj.HeightTW := 1000;
      obj.MakeUniqueName;
      obj.AsString := '';
      txtobj := WPRichText1.TextObjects.InsertMovableImage(obj);
      if txtobj <> nil then
      begin
        txtobj.Mode := txtobj.Mode + [wpobjCreateAutoName];
        txtobj.RelX := 1440;
        txtobj.RelY := 0;
        txtobj.Frame := [wpframe1pt, wpframeShadow];
        WPRichText1.ReformatAll;
        obj.Edit;
        WPRichText1.SetFocus;
      end;
    end;
  end;
end;
{$ELSE}
begin end;
{$ENDIF}


procedure TWPDefAct.XA_InsPageBreakExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) then WPRichText1.InputString(#12);
end;

procedure TWPDefAct.XA_InsColumnBreakExecute(Sender: TObject);
begin
{$IFDEF WPPREMIUM}
  if (WPRichText1 <> nil) then
  begin
    include(WPRichText1.ActiveParagraph.prop, paprNewColumn);
    WPRichText1.ReformatAll(false, true);
  end;
{$ENDIF}
end;

procedure TWPDefAct.XA_InsSectionBreakExecute(Sender: TObject);
var FNewSectionID: Integer;
begin
  if (WPRichText1 <> nil) then
  begin
    WPRichText1.InputString(#12);
    FNewSectionID := WPRichText1.HeaderFooter.LastSectionID + 1;
    WPRichText1.HeaderFooter.LastSectionID := FNewSectionID;
    include(WPRichText1.ActiveParagraph.prop, paprNewSection);
    WPRichText1.ActiveParagraph.SectionID := FNewSectionID;
  end;
end;

procedure TWPDefAct.XA_InsSymbolExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPSymbolDlg1.EditBox := WPRichText1;
    WPSymbolDlg1.Execute;
  end;
end;

procedure TWPDefAct.XA_FInsPageExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPRichText1.InputTextField(TWPTextFieldType((Sender as TAction).Tag));
  end;
end;

procedure TWPDefAct.XA_InsNamedFieldExecute(Sender: TObject);
var s: string;
begin
  if WPRichText1 <> nil then
  begin
    s := 'PAGE';
    if InputQuery(WPLoadStr(wpInsertTextField), WPLoadStr(wpInsertTextField_Name), s) then
      WPRichText1.InputTextFieldName(s);
  end;
end;

procedure TWPDefAct.XA_InsMailmergeFieldExecute(Sender: TObject);
var s: string;
begin
  inc(FFieldCount);
  s := 'FIELD' + IntToStr(FFieldCount);
  if (WPRichText1 <> nil) and
    InputQuery(WPLoadStr(wpInsertMailmergeField), WPLoadStr(wpInsertMailmergeField_Name), s) then
    WPRichText1.InputMergeField(s, s);
end;

procedure TWPDefAct.XA_InsHyperlinkExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) then WPRichText1.EditHyperlink;
end;

procedure TWPDefAct.XA_InsBookmarkExecute(Sender: TObject);
var s: string;
begin
  inc(FBookCount);
  s := 'BOOKM' + IntToStr(FBookCount);
  if (WPRichText1 <> nil) and InputQuery(WPLoadStr(wpInsertBookmark), WPLoadStr(wpInsertBookmark_Name), s) then
    WPRichText1.BookmarkInput(s, false);
end;

procedure TWPDefAct.InsertFormField1Click(Sender: TObject);
var s: string;
begin
  inc(FFieldCount);
  s := 'FIELD' + IntToStr(FFieldCount);
  if (WPRichText1 <> nil) and
    InputQuery(WPLoadStr(wpInsertEditField), WPLoadStr(wpInsertEditField_Name), s) then
    WPRichText1.InputEditField(s, s);
end;

// -------------------------
// -------- Format Menu
// -------------------------

procedure TWPDefAct.XA_FrmFontDialogExecute(Sender: TObject);
begin
  if (WPRichText1 <> nil) then WPRichText1.FontSelect;
end;

procedure TWPDefAct.XA_FrmIndentSpacingExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPParagraphPropDlg1.EditBox := WPRichText1;
    WPParagraphPropDlg1.Execute;
  end;
end;

procedure TWPDefAct.XA_FrmBorderExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPParagraphBorderDlg1.EditBox := WPRichText1;
    WPParagraphBorderDlg1.Execute;
  end;
end;

procedure TWPDefAct.XA_FrmNumbersExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPBulletDlg1.EditBox := WPRichText1;
    WPBulletDlg1.Execute;
  end;
end;

procedure TWPDefAct.XA_FrmTabStopsExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    WPTabDlg1.EditBox := WPRichText1;
    WPTabDlg1.Execute;
  end;
end;

procedure TWPDefAct.XA_Col_OffExecute(Sender: TObject);
begin
{$IFDEF WPPREMIUM}
  if WPRichText1 <> nil then
  begin
    WPRichText1.ActiveParagraph.ASet(WPAT_COLUMNS, (Sender as TAction).Tag);
    if (Sender as TAction).Tag > 0 then
      WPRichText1.ActiveParagraph.ASet(WPAT_COLUMNS_X, 144); // 14 Twips space
    WPRichText1.ReformatAll(false, true);
  end;
{$ENDIF}
end;

procedure TWPDefAct.XA_FrmCap_LowercaseExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    with WPRichText1.TextCursor.CurrAttribute do
    begin
      BeginUpdate;
      ExcludeStyle(afsUppercaseStyle);
      IncludeStyle(afsLowercaseStyle);
      EndUpdate;
    end;
    WPRichText1.Refresh;
  end;
end;

procedure TWPDefAct.XA_FrmCap_UppercaseExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    with WPRichText1.TextCursor.CurrAttribute do
    begin
      BeginUpdate;
      ExcludeStyle(afsLowercaseStyle);
      IncludeStyle(afsUppercaseStyle);
      EndUpdate;
    end;
    WPRichText1.Refresh;
  end;
end;

procedure TWPDefAct.XA_FrmCap_OffExecute(Sender: TObject);
begin
  if WPRichText1 <> nil then
  begin
    with WPRichText1.TextCursor.CurrAttribute do
    begin
      BeginUpdate;
      ExcludeStyle(afsLowercaseStyle);
      ExcludeStyle(afsUppercaseStyle);
      EndUpdate;
    end;
    WPRichText1.Refresh;
  end;
end;

// -------------------------
// -------- Extras Menu
// -------------------------


procedure TWPDefAct.XA_SpellCheckExecute(Sender: TObject);
begin
   // TODO
  WPRichText1.StartSpellCheck(wpStartSpellCheck);
end;

procedure TWPDefAct.XA_SpellAsYouGoExecute(Sender: TObject);
begin
   // TODO
  XA_SpellAsYouGo.Checked := not XA_SpellAsYouGo.Checked;
  if XA_SpellAsYouGo.Checked then
    WPRichText1.StartSpellCheck(wpStartSpellAsYouGo)
  else WPRichText1.StartSpellCheck(wpStopSpellAsYouGo);
end;

procedure TWPDefAct.XA_SpellThesaurusExecute(Sender: TObject);
begin
  // TODO
  WPRichText1.StartSpellCheck(wpStartThesuarus);
end;

procedure TWPDefAct.SpellCheckOptions1Click(Sender: TObject);
begin
  WPRichText1.StartSpellCheck(wpShowSpellCheckSetup);
end;


// -------------------------
// -------- Table Menu
// -------------------------

procedure TWPDefAct.XA_CreateTableExecute(Sender: TObject);
begin
  WPTableDlg1.EditBox := WPRichText1;
  WPTableDlg1.Execute;
end;

procedure TWPDefAct.XA_SplitTableExecute(Sender: TObject);
begin
  WPRichText1.SplitTable;
end;

procedure TWPDefAct.Info1Click(Sender: TObject);
var s: string;
begin
  if (FOwnerComp <> nil) and Assigned(FOwnerComp.FOnInfo1) then
    FOwnerComp.FOnInfo1(Sender) else
    if Assigned(FOnInfo) then FOnInfo else
    begin
      s := '';
      if WPTools_IsPremiumVersion then s := ' PREMIUM';
{$IFDEF WPREPORTER}
{$IFDEF WPREPORTDEMO}
      s := s + ' + WPReporter Demo';
{$ELSE}
      s := s + ' + WPReporter';
{$ENDIF}
{$ENDIF}
      ShowMessage(
        'WPTools, the word processing component suite by WPCubed GmbH' + #13 +
        'Info: http://www.wpcubed.com' + #13 +
        'Version ' + WPToolsVersion + s);
    end;
end;

procedure TWPDefAct.XA_InfoExecute(Sender: TObject);
begin
  if (FOwnerComp <> nil) and Assigned(FOwnerComp.FOnInfo2) then
    FOwnerComp.FOnInfo2(Sender) else
    if Assigned(FOnInfo2) then FOnInfo2;
end;

procedure TWPDefAct.XA_ShowRepBandExecute(Sender: TObject);
begin
{$IFDEF WPREPORTER}
  if SuperMerge <> nil then
  begin
    BandDialog.SuperMerge := SuperMerge;
    BandDialog.EditBox := WPRichText1;
    BandDialog.StayOnTop := TRUE;
    BandDialog.DataBases.CommaText := SuperMerge.DataBases;
    BandDialog.ShowAddDeleteButton := TRUE;
    BandDialog.Show;
  end;
{$ENDIF}
end;

procedure TWPDefAct.XA_CreateReportExecute(Sender: TObject);
begin
{$IFDEF WPREPORTER}
  if (SuperMerge <> nil) and (ReportDest <> nil) then
  begin
    SuperMerge.Execute;
    WPPreviewDlg2.EditBox := ReportDest;
    WPPreviewDlg2.Modal := TRUE;
    WPPreviewDlg2.Show;
    ReportDest.Clear;
  end;
{$ENDIF}

end;



procedure TWPDefAct.GraphicOptionsClick(Sender: TObject);
var obj: TWPTextObj;
begin
  if (WPRichText1 <> nil) and (WPRichText1.SelectedObject <> nil) then
  begin
    obj := WPRichText1.SelectedObject;
    case (Sender as TComponent).Tag of
      1: obj.PositionMode := wpotChar;
      2:
        begin
          obj.Wrap := wpwrAutomatic;
          obj.PositionMode := wpotPar;
        end;
      3:
        begin
          obj.Wrap := wpwrBoth;
          obj.PositionMode := wpotPar;
        end;
      4:
        begin
          obj.Wrap := wpwrNone;
          obj.PositionMode := wpotPage;
        end;
      5:
        begin
          obj.Wrap := wpwrBoth;
          obj.PositionMode := wpotPage;
        end;
      6: // Image under Text !
        begin
          if wpobjObjectUnderText in obj.Mode then
            obj.Mode := obj.Mode - [wpobjObjectUnderText]
          else
            obj.Mode := obj.Mode + [wpobjObjectUnderText];
          WPRichText1.ReformatAll(false, true);
        end;
    end;
  end;
end;

procedure TWPDefAct.GraphicPopupMenuPopup(Sender: TObject);
var obj: TWPTextObj;
begin
  if (WPRichText1 <> nil) and (WPRichText1.SelectedObject <> nil) then
  begin
    obj := WPRichText1.SelectedObject;
    underovertext1.Enabled := (obj.Mode * [wpobjRelativeToParagraph, wpobjRelativeToPage]) <> [];
    underovertext1.Checked := wpobjObjectUnderText in obj.Mode;
    ascharacter1.Checked := not underovertext1.Enabled;
    reltoparautowrap1.Checked :=
      (wpobjRelativeToParagraph in obj.Mode) and
      (obj.Wrap = wpwrAutomatic);
    reltoparwrapleftandright1.Checked :=
      (wpobjRelativeToParagraph in obj.Mode) and
      (obj.Wrap = wpwrBoth);
    reltopagenowrappng1.Checked :=
      (wpobjRelativeToPage in obj.Mode) and
      (obj.Wrap = wpwrNone);
    reltopagewrapleftandright1.Checked :=
      (wpobjRelativeToPage in obj.Mode) and
      (obj.Wrap = wpwrBoth);
  end;
end;

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// --------------------------------------------------------------------

constructor TWPDefaultActions.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  if aOwner is TForm then
    FOwnerForm := aOwner as TForm;
  FWPDefAct := TWPDefAct.Create(nil);
  FWPDefAct.FOwnerComp := Self;
  FControlledMemos := TWPEditBoxLinkCollection.Create(Self);
  FControlledMemos.OnOnUpdateState := EditBoxStateMsg;
end;

destructor TWPDefaultActions.Destroy;
begin
  FWPDefAct.Free;
  FControlledMemos.Free;
  inherited Destroy;
end;

procedure TWPDefaultActions.SetLinks(x: TWPEditBoxLinkCollection);
begin
  FControlledMemos.Assign(x);
end;

procedure TWPDefaultActions.Loaded;
var i: Integer;
begin
  inherited Loaded;
  if not assigned(FWPDefAct.OnGetWPRichText) then
    FWPDefAct.OnGetWPRichText := GetToolsEditor;
  if FAssignMenu and
    (FOwnerForm <> nil) and
    (FOwnerForm.Menu = nil) and not (csDesigning in ComponentState)
    then
    FOwnerForm.Menu := FWPDefAct.MainMenu;
  for i := 0 to FControlledMemos.Count - 1 do
    if (FControlledMemos.Items[0].EditBox <> nil) then
    begin
      FControlledMemos.Items[0].EditBox.GraphicPopupMenu := FWPDefAct.GraphicPopupMenu;
      (FControlledMemos.Items[0].EditBox as TWPCustomRichText).ActionList :=
        FWPDefAct.StdActions;
    end;

     // Show Menus
  FWPDefAct.Export1.Visible := assigned(FOnExport);
  FWPDefAct.CloseFile1.Visible := assigned(FOnCloseFile);
  FWPDefAct.CloseApp1.Visible := assigned(FOnClose);
  FWPDefAct.MailTo1.Visible := assigned(FOnMailTo);
  FWPDefAct.ShowHorzRuler1.Visible := assigned(FOnShowHorzRuler);
  FWPDefAct.ShowVertRuler1.Visible := assigned(FOnShowVertRuler);
  FWPDefAct.ShowGutter1.Visible := assigned(FOnShowGutter);
  FWPDefAct.ShowThumbNails1.Visible := assigned(FOnShowThumbnails);

  if assigned(FOnInit) then
    FOnInit(FWPDefAct);
end;

procedure TWPDefaultActions.GetToolsEditor(Sender: TObject; var wp: TWPCustomRichText);
var i: Integer;
begin
  if FControlledMemos.Count = 1 then
    wp := FControlledMemos.Items[0].EditBox as TWPCustomRichText
  else
  begin
    for i := 0 to FControlledMemos.Count - 1 do
      if (FControlledMemos.Items[i].EditBox <> nil) and
        (FControlledMemos.Items[i].EditBox.Focused) then
        wp := FControlledMemos.Items[i].EditBox as TWPCustomRichText;
    if wp = nil then
      for i := 0 to FControlledMemos.Count - 1 do
        if (FControlledMemos.Items[i].EditBox = FLastEditor) then
          wp := FLastEditor;
  end;
  FLastEditor := wp;
end;

procedure TWPDefaultActions.EditBoxStateMsg(Sender: TPersistent;
  EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg);
begin
  if (State = wpAfterGetFocus) and (EditBox is TWPRichtext) then
  begin
    FLastEditor := TWPRichtext(EditBox);
    TWPRichtext(EditBox).ActionList := FWPDefAct.StdActions;
  end;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure TWPDefAct.SaveStrings;
var
  lst: TStringList;
  procedure SaveMenu(Menu: TMenuItem);
  var i: Integer;
  begin  
    for i := 0 to Menu.Count - 1 do
      if (Menu.Items[i].Caption <> '-') and
        (Menu.Items[i].Name <> '') then
      begin
        lst.Add('c_' + Menu.Items[i].Name + '=' + Menu.Items[i].Caption);
        if Menu.Items[i].Hint <> '' then
          lst.Add('h_' + Menu.Items[i].Name + '=' + Menu.Items[i].Hint);
        SaveMenu(Menu.Items[i]);
      end;
  end;
begin
  if Assigned(WPLangInterface) then
  begin
    lst := TStringList.Create;
    try
      SaveMenu(MainMenu.Items);
      WPLangInterface.SaveStrings('DefaultActions_MainMenu', lst, 0);
      lst.Clear;
      SaveMenu(GraphicPopupMenu.Items);
      WPLangInterface.SaveStrings('DefaultActions_GraphicPopupMenu', lst, 0);
    finally
      lst.Free;
    end;
  end;
end;

procedure TWPDefAct.LoadStrings;
var
  lst: TStringList;
  a: Integer;
  procedure LoadMenu(Menu: TMenu);
  var i, j: Integer;
    s: string;
    cmp: TComponent;
  begin
    for i := 0 to lst.Count - 1 do
    begin
      s := lst[i];
      j := Pos('=', s);
      if (j > 2) then
      begin
        cmp := {was: Menu.}FindComponent(Copy(s, 3, j - 3));
        if (cmp <> nil) and (cmp is TMenuItem) then
        begin
          if s[1] = 'c' then
            TMenuItem(cmp).Caption := Copy(s, j + 1, Length(s) - j)
          else if s[1] = 'h' then
            TMenuItem(cmp).Hint := Copy(s, j + 1, Length(s) - j);
        end;
      end;
    end;
  end;
begin
  if Assigned(WPLangInterface) then
  begin
    lst := TStringList.Create;
    try
      lst.Clear;
      if WPLangInterface.LoadStrings('DefaultActions_MainMenu', lst, a) then
      begin
        LoadMenu(MainMenu);
      end;
      lst.Clear;
      if WPLangInterface.LoadStrings('DefaultActions_GraphicPopupMenu', lst, a) then
      begin
        LoadMenu(GraphicPopupMenu);
      end;
    finally
      lst.Free;
    end;
  end;
end;



end.

