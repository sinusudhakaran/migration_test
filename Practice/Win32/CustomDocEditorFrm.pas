unit CustomDocEditorFrm;
//------------------------------------------------------------------------------
//  Title:   Custom Document Editor
//
//  Written: Sep 2009
//
//  Authors: Scott Wilson
//
//  Purpose: Creates and saves RTF documents that can be added to Favorite
//           Reports in the Client File. They can also be used as a header
//           page for scheduled reports.
//
//  Notes:  Uses a singleton to manage the loading and saving to a single file.
//          The file contains XML with the RTF documents embedded as CDATA. The
//          file extention is '.ftr' (Free Text Report).
//------------------------------------------------------------------------------
interface

uses
  FaxParametersObj,
  SchedrepUtils,
  RTFEditFme,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WPRTEPaint, WPRTEDefs, WPCTRMemo, WPCTRRich, WPRuler,
  WPTbar, ExtCtrls, Menus, ActnList, VirtualTrees, VirtualTreeHandler,
  RzGroupBar, ComCtrls, ImagesFrm, ImgList, UBatchBase, OmniXML, ReportDefs,
  clObj32, WPUtil, WpPagPrp, Contnrs, LADEFS, PrintMgrObj, wpManHeadFoot,
  ExtDlgs, CommDlg, Dlgs, OSFont;

const
  CUSTOM_DOC_TITLE = 'Custom Document';
  ReportGUID       = 'ReportGUID';

type

  TfrmCustomDocEditor = class(TForm)
    pnlControls: TPanel;
    btnSave: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    PageControl1: TPageControl;
    tsReportList: TTabSheet;
    tsReportEdit: TTabSheet;
    GBGroupBar: TRzGroupBar;
    ReportGroup: TRzGroup;
    pnlMessage: TPanel;
    ReportTree: TVirtualStringTree;
    ActionList1: TActionList;
    acAddReport: TAction;
    ImageList1: TImageList;
    acRenameReport: TAction;
    acDeleteReport: TAction;
    Splitter1: TSplitter;
    acEditReport: TAction;
    ListPopup: TPopupMenu;
    AddDocument1: TMenuItem;
    RenameDocument1: TMenuItem;
    EditDocument1: TMenuItem;
    DeleteDocument1: TMenuItem;
    Editor: TfmeEditRTF;
    btnsaveAs: TButton;
    Shape1: TShape;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure acAddReportExecute(Sender: TObject);
    procedure tsReportListShow(Sender: TObject);
    procedure tsReportEditShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acRenameReportExecute(Sender: TObject);
    procedure acDeleteReportExecute(Sender: TObject);
    procedure ReportTreeNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure acEditReportExecute(Sender: TObject);
    procedure ReportTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnPreviewClick(Sender: TObject);
    procedure ReportTreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure ReportTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ReportTreeKeyAction(Sender: TBaseVirtualTree; var CharCode: Word;
      var Shift: TShiftState; var DoDefault: Boolean);
    procedure ReportTreeCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure ReportTreeFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure ReportTreeKeyPress(Sender: TObject; var Key: Char);
    procedure ReportTreeDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorERTFKeyPress(Sender: TObject; var Key: Char);
    procedure EditorERTFChange(Sender: TObject);
    procedure btnsaveAsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    FCurrentDoc : TReportBase;
    FIsNewDoc: Boolean;
    procedure LoadMergeFields;
    procedure SetupColumns;
    procedure SetStatus;
    procedure SaveDocument(ForceNew: Boolean = False);
  end;

  //Used to save and load RTF from the Settings XML node
  TCustomDocHelper = class Helper for TReportBase
  private
    function GetRTF: WideString;
    procedure SetRTF(ARTF: Widestring);
    procedure SetDeleted(const Value: Boolean);
    function GetDeleted: Boolean;
  public
    function GetGUID: string;
    property Deleted: Boolean read GetDeleted write SetDeleted;
    property RTF: WideString read GetRTF write SetRTF;
  end;

  //Singleton to provide list of custom documents
  TCustomDocManager = class(TObject)
  private
    FReportList: TTreeBaseList;
    FReportMergeList: TStringList;
    FDocument : IXMLDocument;
    FPrinterSettings : pWindows_Report_Setting_Rec;
    function CustomDocFile: string;
    function UpdateDoc(AToDoc, AWithDoc: TReportBase): Boolean;
    function DoPrinterSetup(AReport: TReportBase; ARTFDoc: TWPRichText): TModalResult;
    procedure DoPrinterPrint(AReport: TReportBase; ARTFDoc: TWPRichText; StartPage: Integer=0; EndPage: Integer = 0);
    procedure LoadFromFile(AObjectList: TObjectList);
    procedure SaveToFile;
    procedure DoMergeText(Sender: TObject; const InspName: string;
                          Contents: TWPMMInsertTextContents);
    procedure PreviewPDF(AFileName: string = ''; APDFStream: TMemoryStream = nil);
    procedure PrintCustomDoc(AReport: TReportBase; Destination: TReportDest);
    function FaxScheduledCustomDoc(SchedulePRS: TPrintManagerObj;
                                   srOptions: TSchReportOptions;
                                   FaxParams: TFaxParameters ): boolean;
    procedure PreviewPDFFromMemStream(ARTFString: WideString);
  public
    constructor Create;
    destructor Destroy; override;
    function GetReportByGUID(AGUID: string): TReportBase;
    function GetReportByName(AName: string): TReportBase;
    function AddCustomDoc(AGUID: TGUID; AName: string; ARTF: WideString;
                          ACreatedBy: string; ACreatedOn: TDateTime): TReportBase;
    procedure SetVirtualStringTree(AReportTree: TVirtualStringTree);
    procedure SaveReports;
    procedure Refresh;
    procedure ClearReportListMergeField;
    procedure AddToReportListMergeField(AReportName: string);
    procedure DeleteReport(AReport: TReportBase);
    procedure DoOnPrint(const Destination: TReportDest);

    procedure DoCustomDoc(const AClient: TClientObj;
                                AReport: TReportBase;
                                Destination: TReportDest = rdScreen);

    function DoScheduledCustomDoc(Destination: TReportDest;
                                  SchedulePRS: TPrintManagerObj;
                                  var srOptions: TSchReportOptions;
                                  FaxParams: TFaxParameters = nil ): Boolean;

    property ReportList: TTreeBaseList read FReportList;
  end;

  function CustomDocManager: TCustomDocManager;
  procedure AddCustomDocument;

implementation

uses
  SaveReportToDlg,
  BKHelp,
  GlobalMergeFields,
  GenUtils,
  SSRenderFax,
  ShellAPI,
  Globals,
  bkConst,
  SYDEFS,
  bkXPThemes,
  bkBranding,
  ErrorMoreFrm,
  OmniXMLUtils,
  MailFrm,
  PDFViewerFrm,
  PDFViewCommands,
  WPPDFR2,
  WPPDFR1,
  WPViewPDF1,
  YesNoDlg,
  LockUtils,
  UpdateMF,
  WinUtils,
  UserReportSettings,
  Printers,
  RptParams,
  PrDiag,
  PrntInfo,
  LogUtil,
  ReportFileFormat,
  ReportTypes;

const
  CUSTOM_DOC_EXT = '.ftr';
  CUSTOM_DOCS_NODE = 'CustomDocs';
  CUSTOM_DOC_NODE = 'CustomDoc';
  DOC_NAME_COLUMN = 0;
  DOC_NAME_COLUMN_TEXT = 'Document Name';
  DOC_NAME_COLUMN_LEN = 80;
  CREATED_BY_TEXT = 'Created by';
  CREATED_ON_TEXT = 'On';
  FORM_TITLE = 'Custom Documents';
  NEW_DOC_NAME = 'New Custom Document';

  unitname =  'CustomDocEditorFrm';

var
  _CustomDocManager: TCustomDocManager;

{$R *.dfm}

function CustomDocManager: TCustomDocManager;
begin
  if not Assigned(_CustomDocManager) then
    _CustomDocManager := TCustomDocManager.Create;
  Result := _CustomDocManager;
end;

function CustomDocDir: string;
begin
  Result := DataDir + 'CustomDocs\';
  CreateDir(Result);
end;

procedure AddCustomDocument;
var
  frmCustomDocEditor: TfrmCustomDocEditor;
begin
  frmCustomDocEditor := TfrmCustomDocEditor.Create(Application.MainForm);
  try
    frmCustomDocEditor.Caption := FORM_TITLE;
    frmCustomDocEditor.SetupColumns;
    frmCustomDocEditor.SetStatus;
    frmCustomDocEditor.ShowModal;
  finally
    frmCustomDocEditor.Free;
  end;
end;

procedure SetRTFDefaults(ARichText: TWPRichText);
begin
  ARichText.ClearEx(False,False,True);
  ARichText.TextLoadFormat := 'RTF';
  ARichText.TextSaveFormat := 'RTF';
  ARichText.Header.UsedUnit := UnitIn;
  ARichText.Header.PageSize := wp_DinA4;
  ARichText.Header.UsedUnit := UnitIn;
  ARichText.LayoutMode := wplayFullLayout;
  ARichText.AutoZoom := wpAutoZoomOff;
  ARichText.Columns := 1;
  ARichText.Zooming := 100;
  ARichText.Header.LeftMargin := 1880;
  ARichText.Header.RightMargin := 1880;
  ARichText.Header.TopMargin := 1440;
  ARichText.Header.BottomMargin := 1440;
  ARichText.WritingAttr.SetFontName('Arial');
  ARichText.WritingAttr.SetFontSize(12.0);
end;

procedure CreatePDF(ARTFString: string; AFileName: string = '';
  AMemoryStream: TMemoryStream = nil);
var
  i, w, h, n: Integer;
  PDFPrinter: TWPPDFPrinter;
  WPRichText: TWPRichText;
  Rotation: integer;
begin
  WPRichText := TWPRichText.Create(Application.MainForm);
  try
    WPRichText.OnMailMergeGetText := CustomDocManager.DoMergeText;
    WPDF_Start('BankLink','A1h7afT4526dra7h77hb');
    SetRTFDefaults(WPRichText);
    //Load RTF file
    WPRichText.AsString := ARTFString;
    WPRichText.InsertPointAttr.Hidden := True;
    WPRichText.MergeText('', True);
    WPRichText.Refresh;
    //Print to PDF
    PDFPrinter := TWPPDFPrinter.Create(nil);
    try
      if AFileName <> '' then
        PDFPrinter.Filename := AFilename
      else if Assigned(AMemoryStream) then begin
        PDFPrinter.Stream := AMemoryStream;
        PDFPrinter.InMemoryMode := True;
      end else
        Exit;
      PDFPrinter.CompressStreamMethod := wpCompressFastFlate;
      PDFPrinter.FontMode := wpEmbedSymbolTrueTypeFonts;
      PDFPrinter.BeginDoc;
      try
        i := 0;
        n := WPRichText.CountPages;
        while i < n do begin
          w := WPRichText.Memo.PaintPageWidth[i];
          h := WPRichText.Memo.PaintPageHeight[i];
          Rotation := 0;
          if WPRichText.Header.Landscape then
            Rotation := 90;
          PDFPrinter.StartPage(w, h, Screen.PixelsPerInch,
                               Screen.PixelsPerInch, Rotation);
          try
            WPRichText.Memo.PaintRTFPage( i, 0, 0, 0, 0, PDFPrinter.Canvas, []);
          finally
            PDFPrinter.EndPage;
          end;
          Inc( i );
        end;
      finally
        PDFPrinter.EndDoc;
      end;
    finally
       PDFPrinter.Free;
    end;
  finally
    WPRichText.Free;
  end;
end;

procedure TCustomDocManager.PreviewPDF(AFileName: string; APDFStream: TMemoryStream);
var
  PDFViewerFrm: TPDFViewFrm;
begin
  try
    //Preview
    PDFViewerFrm := TPDFViewFrm.Create(Application.MainForm);
    try
      //Load pdf
      if (AFileName <> '') and FileExists(AFileName) then
        PDFViewerFrm.FileList.Add(ExpandFileName(AFileName))
      else
        PDFViewerFrm.PDFMemoryStream := APDFStream;

      PDFViewerFrm.Caption := 'Report Viewer';
      PDFViewerFrm.OnPrint := DoOnPrint;
      PDFViewerFrm.ShowModal;
    finally
      PDFViewerFrm.Free;
    end;
  finally
    if (AFileName > '') and FileExists(AFileName) then
      DeleteFile(AFileName);
  end;
end;

procedure TCustomDocManager.PreviewPDFFromMemStream(ARTFString: WideString);
var
  MemStream: TMemoryStream;
begin
  MemStream := TMemoryStream.Create;
  try
    CreatePDF(ARTFString, '', MemStream);
    PreviewPDF('', MemStream);
  finally
    MemStream.Free;
  end;
end;

procedure TCustomDocManager.DoPrinterPrint(AReport: TReportBase; ARTFDoc: TWPRichText; StartPage: Integer=0; EndPage: Integer = 0);
begin
   ARTFDoc.ReformatAll;
   //Print
   if (StartPage <> 0) and (EndPage <> 0) then
      ARTFDoc.Print(IntToStr(StartPage) + '-' + IntToStr(EndPage)) //Range
   else
      ARTFDoc.Print; //All pages
end;

function TCustomDocManager.DoPrinterSetup(AReport: TReportBase; ARTFDoc: TWPRichText): TModalResult;
//------------------------------------------------------------------------------
// Use the same print dialog as standard BK5 reports
//------------------------------------------------------------------------------
var
  PrnDialog : TPrnDialog;
  wasOrient, wasPaperSize, wasPrinterIndex: integer;
  StartPage, EndPage: integer;
  PaperInfo: TPaperInfo;
begin
  PrnDialog := TPrnDialog.Create(Application.MainForm);
  try
    PrnDialog.DlgPrinter := Printers.Printer;
    PrnDialog.caption     := 'Print ' + AReport.Title;
    PrnDialog.SetupOnly := (AReport.BatchRunMode = r_Setup);
    PrnDialog.btnSetMargins.Visible := False;
    PrnDialog.PageMin     := 1;
    PrnDialog.PageMax     := ARTFDoc.PageCount;
    PrnDialog.cmbSize.Enabled := True;
    PrnDialog.PaperSize := FPrinterSettings.s7Paper;
    PrnDialog.btnSetMargins.Enabled := False;
    PrnDialog.DisablePrinterChange := False;
    PrnDialog.UseDefPrinter := FPrinterSettings.s7Is_Default;
    PrnDialog.PrePrintSetup := False;
    if FPrinterSettings.s7Orientation = BK_PORTRAIT then
      PrnDialog.Orientation := DMORIENT_PORTRAIT
    else
      PrnDialog.Orientation := DMORIENT_LANDSCAPE;

    wasOrient := FPrinterSettings.s7Orientation;
    wasPaperSize := FPrinterSettings.s7Paper;
    wasPrinterIndex := Printers.Printer.PrinterIndex;

    //****************************
    Result := PrnDialog.Execute;
    //****************************

    if (Result in [mrOK, mrPrint, mrPreview]) then begin
      //Set values
      //Printer - automatic
      //Copies - automatic
      //Page range
      if PrnDialog.rbFrom.Checked then
      begin
        //Start page
        if  (PrnDialog.opFrom.AsInteger >= 1) and
            (PrnDialog.opFrom.AsInteger <= ARTFDoc.PageCount) then
          StartPage := PrnDialog.opFrom.AsInteger
        else
          StartPage := 1;
        //End page
        if (PrnDialog.opTo.AsInteger >= 1) and
           (PrnDialog.opTo.AsInteger <= ARTFDoc.PageCount) then
          EndPage := PrnDialog.opTo.AsInteger
        else
          EndPage := ARTFDoc.PageCount;
      end else begin
        StartPage := 0;
        EndPage := 0;
      end;
      //Paper size
      if (PrnDialog.PaperSize <> wasPaperSize) then begin
        PaperInfo := TPaperInfo(PrnDialog.cmbSize.Items.Objects[PrnDialog.cmbSize.ItemIndex]);
        if Assigned(PaperInfo) then begin
          ARTFDoc.Header.PageHeight := PaperInfo.Size.Y;
          ARTFDoc.Header.PageWidth := PaperInfo.Size.X;
        end;
      end;
      //Paper source - automatic
      //Orientation
      if (ARTFDoc.Header.Landscape <> (PrnDialog.Orientation = DMORIENT_LANDSCAPE)) then begin
        ARTFDoc.Header.Landscape := (PrnDialog.Orientation = DMORIENT_LANDSCAPE);
      end;

      //Save settings
      if PrnDialog.SaveClicked then begin
        //Printer
        FPrinterSettings.s7Printer_Name := FindPrinterDeviceName(-1); //Default
        if not PrnDialog.UseDefPrinter then
          FPrinterSettings.s7Printer_Name := PrnDialog.cmbPrinter.Items[PrnDialog.cmbPrinter.ItemIndex];
        //Paper size
        FPrinterSettings.s7Paper := PrnDialog.PaperSize;
        //Paper source
        FPrinterSettings.s7Bin := PrnDialog.Bin;
        //Orientation
        if ARTFDoc.Header.Landscape then
          FPrinterSettings.s7Orientation := BK_LANDSCAPE
        else
          FPrinterSettings.s7Orientation := BK_PORTRAIT;

        if FPrinterSettings.s7Is_Default then begin
          //The default settings were used and a save has been requested.
          //Need to add the report settings to the list of user settings.
          FPrinterSettings.s7Is_Default    := false;
          InsertNewUserReportSettings(UserPrintSettings, FPrinterSettings);
        end;
      end;

      //Print
      case Result of
        mrPrint: DoPrinterPrint(AReport, ARTFDoc, StartPage, EndPage);
        mrPreview: PreviewPDFFromMemStream(AReport.GetRTF);
      end;
    end;
  finally
    PrnDialog.Free;
  end;
end;

procedure TCustomDocManager.PrintCustomDoc(AReport: TReportBase; Destination: TReportDest);
var
  WPRichText: TWPRichText;
begin
  WPRichText := TWPRichText.Create(Application.MainForm);
  try
    WPRichText.OnMailMergeGetText := CustomDocManager.DoMergeText;
    SetRTFDefaults(WPRichText);
    //Load RTF file
    WPRichText.AsString := AReport.GetRTF;
    WPRichText.InsertPointAttr.Hidden := True;
    WPRichText.MergeText('', True);
    WPRichText.Refresh;
    //Load user printer settings
    FPrinterSettings := GetBKUserReportSettings(UserPrintSettings, AReport.GetGUID);
    if not Assigned(FPrinterSettings) then begin
       FPrinterSettings := GetDefaultReportSettings(AReport.GetGUID);
       //Override with RTF doc default settings?
       if WPRichText.Header.Landscape then
          FPrinterSettings.s7Orientation := BK_LANDSCAPE
       else
         FPrinterSettings.s7Orientation := BK_PORTRAIT;
    end;
    //Apply document printer properties to windows printer setup
    WPRichText.UpdatePrinterProperties(Printer, 0);
    //Display custom print dialog
    case Destination of
      rdSetup :   DoPrinterSetup(AReport, WPRichText);
      rdPrinter : DoPrinterPrint(AReport, WPRichText);
    end;
  finally
    WPRichText.Free;
  end;
end;


function CompareReports(Item1, Item2: Pointer): Integer;
begin
   Result := CompareText(TReportBase(Item1).Name,TReportBase(Item2).Name);
end;

procedure TCustomDocManager.Refresh;
begin
   LoadFromFile(FReportList);
   FReportList.Sort(CompareReports);
end;

procedure TCustomDocManager.DoCustomDoc(const AClient: TClientObj;
  AReport: TReportBase; Destination: TReportDest);
var
  LocalReport: TReportBase;
  MsgStr: string;
  tmpFilename: string;
  dummy: Integer;
  FileExt: String;
  FileInc: Integer;

  function GetUserName : string;
  begin
    if Assigned(CurrUser) then begin
      if CurrUser.FullName > '' then
        Result := CurrUser.FullName
      else if CurrUser.Code > '' then
        Result := CurrUser.Code
      else
        Result := 'ID: ' + IntTostr(CurrUser.LRN)
    end else
      Result := '';
  end;

begin
  if not Assigned(AReport) then
    Exit;


  //Make sure that we have the latest version of the custom doc's
  Refresh;

  // Set the last run details..
  AReport.LastRun := Now;
  AReport.User := GetUserName;
  AReport.RunDestination := Get_DestinationText (Destination);

  LocalReport := CustomDocManager.GetReportByGUID(AReport.GetGUID);
  if Assigned(LocalReport) then begin
    LocalReport.RunFileName := Globals.DataDir + LocalReport.Name + '.pdf';
    case Destination of
      rdScreen : PreviewPDFFromMemStream(TReportBase(LocalReport).GetRTF);
      rdFile   : begin
                   tmpFilename := LocalReport.RunFileName;
                   if GenerateReportTo(tmpFilename, dummy, [ffPDF], MsgStr,
                                       MsgStr, dummy, dummy, True) then begin
                     LocalReport.RunFileName := tmpFilename;
                     CreatePDF(TReportBase(LocalReport).GetRTF, LocalReport.RunFileName);
                     MsgStr := Format('Report saved to "%s".%s%sDo you want to view it now?',
                                      [LocalReport.RunFileName, #13#10, #13#10]);
                     if (AskYesNo(RptFileFormat.Names[rfPDF], MsgStr, DLG_YES, 0) = DLG_YES) then
                       ShellExecute(0, 'open', PChar(LocalReport.RunFileName), nil, nil, SW_SHOWMAXIMIZED);
                   end;
                 end;
      rdPrinter,
      rdSetup:  begin
                  if Destination = rdPrinter then
                  begin
                    tmpFileName := LocalReport.RunFilename;
                         
                    FileExt := ExtractFileExt(tmpFileName);

                    FileInc := 1;
                    
                    while FileExists(tmpFileName) do
                    begin
                      tmpFileName := Format('%s(%s)%s',[Copy(LocalReport.RunFilename, 0, Pos(FileExt, LocalReport.RunFilename) -1), IntToStr(FileInc), FileExt]);

                      Inc(FileInc);
                    end;

                    LocalReport.RunFileName := tmpFileName;
                    
                    CreatePDF(TReportBase(LocalReport).GetRTF, LocalReport.RunFileName);
                  end;

                  //may need to keep the file
                  AReport.RunFileName := LocalReport.RunFileName;
                  AReport.RunBtn := Btn_Print;
                  case AReport.BatchRunMode of
                    R_Setup : Destination := rdSetup;
                    R_Batch : Exit;
                  end;
                  PrintCustomDoc(LocalReport, Destination);
                end;
    end; //Case
  end;
end;

procedure TfrmCustomDocEditor.acAddReportExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    FCurrentDoc := nil;
    FIsNewDoc := True;
    SetRTFDefaults(Editor.ERTF);
    PageControl1.ActivePage := tsReportEdit;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmCustomDocEditor.acDeleteReportExecute(Sender: TObject);
var
  Node : PVirtualNode;
  Report: TReportBase;
begin
  Node := ReportTree.FocusedNode;
  if Assigned(Node) then begin
    Report := TReportBase(CustomDocManager.ReportList.GetNodeItem(Node));
    if Assigned(Report) then
      if MessageDlg('Do you want to delete this custom document?' +
                    #13+#10+#13+#10+ Report.Name, mtConfirmation,
                    [mbYes, mbNo], 0) = mrYes then begin
        ReportTree.DeleteNode(Node);
        CustomDocManager.DeleteReport(Report);
      end;
  end;
end;

procedure TfrmCustomDocEditor.acEditReportExecute(Sender: TObject);
var
  Node : PVirtualNode;
begin
  Screen.Cursor := crHourGlass;
  try
    Node := ReportTree.FocusedNode;
    if Assigned(Node) then begin
      FCurrentDoc := TReportBase(CustomDocManager.ReportList.GetNodeItem(Node));
      FIsNewDoc := False;
      if Assigned(FCurrentDoc) then begin
         SetRTFDefaults(Editor.ERTF);
         Editor.ERTF.AsString := FCurrentDoc.GetRTF;
         PageControl1.ActivePage := tsReportEdit;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmCustomDocEditor.acRenameReportExecute(Sender: TObject);
var
  Node: PVirtualNode;
begin
  Node := ReportTree.FocusedNode;
  if not Assigned(Node) then Exit;
  ReportTree.EditNode(Node, DOC_NAME_COLUMN);
end;

procedure TfrmCustomDocEditor.btnCancelClick(Sender: TObject);
begin
  if (PageControl1.ActivePage = tsReportEdit) then begin
     Editor.DoClose;
     PageControl1.ActivePage := tsReportList
  end else
    Close;
end;

procedure TfrmCustomDocEditor.btnPreviewClick(Sender: TObject);
begin
  CustomDocManager.PreviewPDFFromMemStream(Editor.ERTF.AsString);
end;

procedure TfrmCustomDocEditor.btnsaveAsClick(Sender: TObject);
begin
  SaveDocument(True);
  acRenameReportExecute(nil);
  Editor.DoClose;
  PageControl1.ActivePage := tsReportList;
end;

procedure TfrmCustomDocEditor.btnSaveClick(Sender: TObject);
begin
  SaveDocument;
  if FIsNewDoc then
    acRenameReportExecute(nil);
  Editor.DoClose;

  PageControl1.ActivePage := tsReportList;
end;



procedure TfrmCustomDocEditor.EditorERTFChange(Sender: TObject);
begin
   btnsave.Enabled := Editor.ERTF.Modified;
end;

procedure TfrmCustomDocEditor.EditorERTFKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(Integer('S') - 64) then // Ctrl + S
  begin
    SaveDocument;
    Key := #0;
  end;

  Editor.ERTFKeyPress(Sender, Key);
end;



procedure TfrmCustomDocEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);

  function Title: string;
  begin
     if Assigned(FCurrentDoc) then
        Result := FCurrentDoc.Name
     else
        result := NEW_DOC_NAME;
  end;
begin
    if PageControl1.ActivePage <> tsReportList then begin
        Editor.DoClose;
        if Editor.ERTF.Modified then
           case AskYesNo('Save Changes', Format('Save Changes to: '#13'%s',[Title]), DLG_YES, 0, True) of
              DLG_yes : btnSaveClick(nil);
              DLG_No  : PageControl1.ActivePage := tsReportList;  // Just move back
              //else do nothing...
           end
        else
           PageControl1.ActivePage := tsReportList;

        // in anny case don't close the whole dialog
        CanClose := False;
    end;
end;

procedure TfrmCustomDocEditor.FormCreate(Sender: TObject);
var
  i: integer;
begin
  bkXPThemes.ThemeForm(Self);
  BKHelpSetUp(Self, BKH_Custom_Documents);
  ReportTree.Header.Font := Font;
  ReportTree.Header.Height := Abs(ReportTree.Header.Font.height) * 10 div 6;
  ReportTree.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8); //So the editor fits

  bkbranding.StyleSelectionColor(ReportTree);
  bkBranding.StyleGroupBar(GBGroupBar);

  if UserINI_CD_GroupWidth > 0 then
     GBGroupBar.Width := UserINI_CD_GroupWidth;
  //Load reports
  CustomDocManager.SetVirtualStringTree(ReportTree);
  ReportTree.OnDblClick := ReportTreeDblClick;
  //PageControl
  for i := 0 to Pred(PageControl1.PageCount) do
    PageControl1.Pages[i].TabVisible := False;
  PageControl1.ActivePage := tsReportList;
  Editor.EditMode := True;
  Editor.FullPageMode := True;
  //Merge fields
  LoadMergeFields;
  //RTF Editor
  SetRTFDefaults(Editor.ERTF);
end;

procedure TfrmCustomDocEditor.FormDestroy(Sender: TObject);
begin
   UserINI_CD_GroupWidth := GBGroupBar.Width;
   CustomDocManager.SaveReports;
end;

procedure TfrmCustomDocEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case Key of
   VK_ESCAPE : begin
          Key := 0;
          Close;
       end;
 end;
end;

procedure TfrmCustomDocEditor.FormShow(Sender: TObject);
begin
  //Select first document
  ReportTree.FocusedNode :=
  ReportTree.GetFirstVisible;
  if Assigned(ReportTree.FocusedNode) then
    ReportTree.Selected[ReportTree.FocusedNode] := True;
  if ReportTree.CanFocus then
    ReportTree.SetFocus;
  SetStatus;
end;

procedure TfrmCustomDocEditor.LoadMergeFields;
begin
  //Report list field
  Editor.AddMergeMenuItem ('Report List', ord(mf_ReportList));
  // Add the normal ones...
  Editor.LoadGlobalMergeMenues;
end;

procedure TfrmCustomDocEditor.ReportTreeCreateEditor(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  out EditLink: IVTEditLink);
var
  StringEditLink: TStringEditLink;
begin
  if (Column = DOC_NAME_COLUMN) then begin
    StringEditLink := TStringEditLink.Create;
    StringEditLink.Edit.MaxLength := DOC_NAME_COLUMN_LEN;
    EditLink := StringEditLink;
  end;
end;

procedure TfrmCustomDocEditor.ReportTreeDblClick(Sender: TObject);
begin
  acEditReportExecute(Sender);
end;

procedure TfrmCustomDocEditor.ReportTreeEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := false;
  if (Column = DOC_NAME_COLUMN) then
    Allowed := True;
end;

procedure TfrmCustomDocEditor.ReportTreeFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  SetStatus;
end;

procedure TfrmCustomDocEditor.ReportTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  OldCol: TColumnIndex;
begin
  if Button = mbRight then Exit; // will show popup menu

  OldCol := ReportTree.Header.SortColumn;
  ReportTree.BeginUpdate;
  try
    if Column <> OldCol then begin
      ReportTree.Header.SortColumn := Column;
      ReportTree.Header.SortDirection := sdAscending;
      ReportTree.SortTree(ReportTree.Header.SortColumn,
      ReportTree.Header.SortDirection);
    end else begin
      //Reverse the direction as col hasn't changed
      if ReportTree.Header.SortDirection = sdAscending then
        ReportTree.Header.SortDirection := sdDescending
      else
        ReportTree.Header.SortDirection := sdAscending;
      ReportTree.SortTree(ReportTree.Header.SortColumn,
                          ReportTree.Header.SortDirection);
    end;
  finally
    ReportTree.EndUpdate;
  end;
end;

procedure TfrmCustomDocEditor.ReportTreeKeyAction(Sender: TBaseVirtualTree;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
begin
  DoDefault := false;
  case CharCode of
    VK_Insert : acAddReportExecute(nil);
    VK_Delete : acDeleteReportExecute(nil);
    VK_F6, VK_F2 : acEditReportExecute(nil);
  else
    Dodefault := True;
  end;
end;

procedure TfrmCustomDocEditor.ReportTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  Report: TReportBase;
  Node: PVirtualNode;
begin
  Report := nil;
  Node := ReportTree.FocusedNode;
  if Assigned(Node) then
    Report := TReportBase(CustomDocManager.ReportList.GetNodeItem(Node));

  case ord(key) of
    VK_ESCAPE :
      begin
        Key := 0;
        Close;
      end;
    VK_RETURN :
       begin
         if not Assigned(ReportTree.EditLink) then
           if Assigned(Report) then begin
             Key := 0;
             acEditReportExecute(nil);
           end;
       end;
    VK_SPACE :
      begin
        if not assigned(ReportTree.EditLink) then
          if Assigned(Report) then begin
            Key := 0;
            ReportTree.Selected[Node] := (not ReportTree.Selected[Node]);
            ReportTree.Invalidate;
            SetStatus;
          end;
      end;
  end;
end;

procedure TfrmCustomDocEditor.ReportTreeKeyPress(Sender: TObject;
  var Key: Char);
begin
 //
end;

procedure TfrmCustomDocEditor.ReportTreeNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
var
  Report, TempReport: TReportBase;
  Msg: string;
begin
  Report :=  TReportBase(CustomDocManager.ReportList.GetNodeItem(Node));

  if not Assigned(Report) then Exit; // Nowhere to go..

  if CustomDocManager.ReportList.GetColumnTag(Column) = gt_Name then begin
    NewText := Trim(NewText);
    if NewText < ' ' then begin
      HelpfulErrorMsg('Please enter valid name.', 0, False);
      Exit;
    end;
    TempReport := CustomDocManager.GetReportByName(NewText);
    if (TempReport <> nil) and(TempReport <> Report) then begin
      ReportTree.CancelEditNode;
      Msg := Format('A document named "%s" already exists.%s' +
                    'Please enter a different name.',[NewText, #10]);
      HelpfulErrorMsg(Msg, 0, False);
      Exit;
    end;
    if (Report.Name <> NewText) then begin
      Report.Name := NewText;
      Report.Changed := True;
      CustomDocManager.SaveReports;
    end;
  end;
end;

procedure TfrmCustomDocEditor.SaveDocument(ForceNew: Boolean = False);
var
  i: integer;
  NewReport: TReportBase;
  Node: PVirtualNode;
  ReportName: string;
  GUID: TGUID;
begin
  //Add to ReportTree
  Node := ReportTree.RootNode;
  if Assigned(FCurrentDoc)
  and (not ForceNew) then begin
     NewReport := FCurrentDoc;
     NewReport.Lock;
     try
        NewReport.Title := CUSTOM_DOC_TITLE;
        if (Newreport.GetRTF <> Editor.ERTF.AsString) then begin
           NewReport.SetRTF(Editor.ERTF.AsString);
           Newreport.Changed := True;
        end;
    finally
      NewReport.UnLock
    end;
  end else begin
    //Create Doc
    CreateGUID(GUID);

    i := 0;
    ReportName := NEW_DOC_NAME;
    while CustomDocManager.GetReportByName(ReportName) <> nil do begin
      Inc(i);
      ReportName := Format('%s (%d)', [NEW_DOC_NAME, i]);
    end;

    NewReport := CustomDocManager.AddCustomDoc(GUID, ReportName,
                                               Editor.ERTF.AsString,
                                               Globals.CurrUser.Code, Now);
    //Add to Tree
    ReportTree.Expanded[Node] := True;
    Node := CustomDocManager.ReportList.AddNodeItem(node, NewReport);
    ReportTree.Selected[Node] := True;
    ReportTree.FocusedNode := Node;
    FCurrentDoc := NewReport;
  end;
  Editor.ERTF.Modified := False;
  EditorERTFChange(nil);
  SetStatus;

  CustomDocManager.SaveReports;
end;

procedure TfrmCustomDocEditor.SetStatus;
var
  Enabled: Boolean;
begin
  Enabled := (ReportTree.SelectedCount > 0) and
             (ReportTree.ChildCount[ReportTree.RootNode] > 0);
  acRenameReport.Enabled := Enabled;
  acEditReport.Enabled   := Enabled;
  acDeleteReport.Enabled := Enabled;
end;

procedure TfrmCustomDocEditor.SetupColumns;
var
  Column: TVirtualTreeColumn;
begin
  ReportTree.Header.Columns.Clear;
  Column := ReportTree.Header.Columns.Add;
  Column.Text := DOC_NAME_COLUMN_TEXT;
  Column.Tag := gt_Name;
  Column.Width := 250;
  Column := ReportTree.Header.Columns.Add;
  Column.Text := CREATED_BY_TEXT;
  Column.Tag := gt_CreatedBy;
  Column.Width := 200;
  Column := ReportTree.Header.Columns.Add;
  Column.Text := CREATED_ON_TEXT;
  Column.Tag := gt_CreatedOn;
  Column.Width := 200;
end;

procedure TfrmCustomDocEditor.tsReportEditShow(Sender: TObject);
begin
  btnPreview.Visible := True;
  btnSave.Visible := True;
  btnSaveAs.Visible := True;
  btnCancel.Caption := '&Cancel';
  if Editor.ERTF.CanFocus then
    Editor.ERTF.SetFocus;
  if Assigned(FCurrentDoc) then
    Self.Caption := Format('%s - %s', [FORM_TITLE, FCurrentDoc.Name])
  else
    Self.Caption := Format('%s - %s', [FORM_TITLE, NEW_DOC_NAME]);
  Editor.ERTF.Modified := False;
  btnsave.Enabled := False;
end;

procedure TfrmCustomDocEditor.tsReportListShow(Sender: TObject);
begin
  btnPreview.Visible := False;
  btnSave.Visible := False;
  btnSaveAs.Visible := False;
  btnCancel.Caption := '&Close';
  Self.Caption := FORM_TITLE;
end;


{ TCustomDocManager }

function TCustomDocManager.AddCustomDoc(AGUID: TGUID; AName: string;
  ARTF: WideString; ACreatedBy: string; ACreatedOn: TDateTime): TReportBase;
begin
  Result := TReportBase.Create;
  Result.Lock;
  try
    Result.Settings := CustomDocManager.FDocument.CreateElement('Settings');
    SetNodeTextStr(Result.Settings, ReportGUID, GuidToString(AGUID));
    //RTF
    Result.SetRTF(ARTF);
    //Fields
    Result.Title := CUSTOM_DOC_TITLE;
    Result.CreatedBy := ACreatedBy;
    Result.CreatedOn := ACreatedOn;
    Result.Changed := True;
    Result.Name := AName;
  finally
    Result.Unlock;
  end;
end;

procedure TCustomDocManager.AddToReportListMergeField(AReportName: string);
begin
  FReportMergeList.Add(AReportName);
end;

procedure TCustomDocManager.ClearReportListMergeField;
begin
  FReportMergeList.Clear;
end;


constructor TCustomDocManager.Create;
begin
  inherited;

  FDocument := CreateXMLDoc;
  FReportMergeList := TStringList.Create;
  FReportList := TTreeBaseList.Create(nil);
  FReportList.OnCurBaseItemChange := nil;
  Refresh;
end;

function TCustomDocManager.CustomDocFile: string;
begin
  Result := CustomDocDir + 'CustomDocs' + CUSTOM_DOC_EXT;
end;

procedure TCustomDocManager.SetVirtualStringTree(
  AReportTree: TVirtualStringTree);
var
  i: integer;
  Node: PVirtualNode;
  Item: TTreeBaseItem;
begin
  //Normally objects would be added using FReportList.AddNodeItem, but this
  //ties them to a VirtualStringTree, which may not exist when the
  //CustomDocManager is created. Therefore this procedure needs to be
  //called when the VirtualStringTree is created.
  FReportList.Tree := AReportTree;
  for i := 0 to Pred(FReportList.Count) do begin
    Item := TTreeBaseItem(FReportList.Items[i]);
    if Assigned(Item) then begin
      Item.ParentList := FReportList;
      Node := AReportTree.AddChild(AReportTree.RootNode);
      FReportList.SetNodeItem(Node, Item);
    end;
  end;
end;

function TCustomDocManager.UpdateDoc(AToDoc, AWithDoc: TReportBase): Boolean;
var
  Match: Boolean;
begin
  Result := False;
  if AToDoc.Changed then Exit; //Reports has been edited so will overwrite
  if AToDoc.Deleted then Exit; //No need to update
  if (AToDoc.GetGUID <> AWithDoc.GetGUID) then Exit; //GIUD's must match

  Match := (AToDoc.Name = AWithDoc.Name);
  Match := Match and (AToDoc.GetRTF = AWithDoc.GetRTF);

  if not Match then begin
    AToDoc.Name := AWithDoc.Name;
    AToDoc.SetRTF(AWithDoc.GetRTF);
    AToDoc.Changed := True;
    Result := True;
  end;
end;

procedure TCustomDocManager.DeleteReport(AReport: TReportBase);
var
  Index: integer;
begin
  Index := FReportList.IndexOf(AReport);
  if Index >= 0 then
    if Assigned(FReportList.Items[Index]) then begin
      AReport.Deleted := True;
      SaveReports;
    end;
end;

destructor TCustomDocManager.Destroy;
begin
  FReportMergeList.Free;
  if Assigned(FReportList) then
    FReportList.Free;
  FDocument := nil;

  inherited;
end;

procedure TCustomDocManager.DoMergeText(Sender: TObject;
  const InspName: string; Contents: TWPMMInsertTextContents);

begin
  Contents.StringValue := '';
  //Report list field
  if InspName = MergeFieldNames[mf_ReportList] then
     Contents.StringValue := FReportMergeList.Text
  else
     Contents.StringValue := GetGlobalMergeText(InspName);
end;

procedure TCustomDocManager.DoOnPrint(const Destination: TReportDest);
begin
  //
end;

function TCustomDocManager.DoScheduledCustomDoc (Destination: TReportDest;
  SchedulePRS: TPrintManagerObj; var srOptions: TSchReportOptions;
  FaxParams: TFaxParameters = nil ): Boolean;
var
  LocalReport: TReportBase;
  HeaderRptName: string;

  function GetPDFFilename: string;
  var
    I: integer;
  begin
    if Destination = rdEmail then begin
      I := 0;
      repeat
        Result := Format('%s[%s]%s.pdf',[EmailOutboxDir, padLeft(IntToStr(I),4,'0') , LocalReport.Name]);
        Inc(i);
      until not bkFileexists(Result);
    end else
      // Does not matter much..
      Result := Globals.DataDir + LocalReport.Name + '.pdf';
  end;

begin
  Result := False;
  LocalReport := CustomDocManager.GetReportByGUID(srOptions.srCustomDocGUID);
  if not Assigned(LocalReport) then
    Exit;

  LocalReport.RunFileName := GetPDFFilename;
  case Destination of
    //Fax
    rdFax       : Result := FaxScheduledCustomDoc(SchedulePRS,srOptions,FaxParams);
    //Preview
    rdScreen    : begin
                    PreviewPDFFromMemStream(TReportBase(LocalReport).GetRTF);
                    Result := True;
                  end;
    //Email or File
    rdEmail,
    rdECoding,
    rdWebX,
    rdCSVExport,
    rdCheckOut  : begin
                    CreatePDF(TReportBase(LocalReport).GetRTF, LocalReport.RunFileName);
                    srOptions.srAttachment := LocalReport.RunFileName;
                    Result := True;
                  end;
    //Printer
    rdPrinter   : begin
                    //Select same printer as header message
                    HeaderRptName := Report_List_Names[Report_Client_Header];
                    FPrinterSettings := GetBKUserReportSettings(SchedulePRS, HeaderRptName);
                    if Assigned(FPrinterSettings) then
                      Printer.PrinterIndex := FindPrinterIndex(FPrinterSettings.s7Printer_Name)
                    else begin
                      FPrinterSettings := GetDefaultReportSettings(HeaderRptName);
                      try
                        if Assigned(FPrinterSettings) then
                          Printer.PrinterIndex := FindPrinterIndex(FPrinterSettings.s7Printer_Name);
                      finally
                        FreeMem(FPrinterSettings, Windows_Report_Setting_Rec_Size);
                      end;
                    end;
                    PrintCustomDoc(LocalReport, rdPrinter);
                    Result := True;
                  end;
  end; //Case
end;

function TCustomDocManager.FaxScheduledCustomDoc(
                                   SchedulePRS: TPrintManagerObj;
                                   srOptions: TSchReportOptions;
                                   FaxParams: TFaxParameters ): Boolean;
var lDoc: TReportBase;
    WPRichText: TWPRichText;
    FaxPrinter: TSSRenderFax;
    HasBanner: Boolean;
    PageNumber: Integer;
    SavedOrient: Integer;
    FaxPrinterName: string;

    function GetFaxPrinterName: string;
    var LSetting : pWindows_Report_Setting_Rec;
    begin
       //SchedulePRS is the global Faxprinter setting
       LSetting := GetBKUserReportSettings(SchedulePRS,Report_List_Names[Report_Custom_Document]);
       if Assigned(LSetting) then
          FaxPrinterName := LSetting.s7Printer_Name
       else
          FaxPrinterName := 'Fax'; // Just a stab in the dark...
       Result := FaxPrinterName;
    end;
begin
   Result := False;
   lDoc := GetReportByGUID(srOptions.srCustomDocGUID);
   if not assigned(LDoc) then
       Exit;

   if not assigned(FaxParams) then
      raise ESSRenderFaxError.Create( 'No fax details passed');


   WPRichText := TWPRichText.Create(Application.MainForm);
   try
       WPRichText.OnMailMergeGetText := CustomDocManager.DoMergeText;
       WPDF_Start('BankLink','A1h7afT4526dra7h77hb');
       SetRTFDefaults(WPRichText);
       //Load RTF file
       WPRichText.AsString := LDoc.GetRTF;
       WPRichText.InsertPointAttr.Hidden := True;
       WPRichText.MergeText('', True);
       WPRichText.Refresh;

       // Set the orientation beforhand
       if WPRichText.Header.Landscape  then
          SavedOrient := SetFaxOrientation(GetFaxPrinterName,poLandscape)
       else
          SavedOrient := SetFaxOrientation(GetFaxPrinterName,poPortrait);

       // Set the FaxPrinter
       HasBanner := True;
       FaxPrinter := TssRenderFax.Create(Application.MainForm);
       try
          // Prep the fax printer
          FaxPrinter.FaxPrinterName := FaxPrinterName;
          FaxPrinter.ConnectFax;
          HasBanner := FaxPrinter.IsBanner;
          if Globals.PRACINI_SuppressBanner then // Force no banner
              FaxPrinter.SetFaxBanner(False);
          FaxPrinter.PagesToPrint := WPRichText.CountPages;
          FaxParams.AssignTo(FaxPrinter);

          // Paint the RTF to the Fax printer
          FaxPrinter.DocBegin;
          try
             FaxPrinter.DoCoverPage(FaxPrinter.PagesToPrint);

             for PageNumber := 0 to WPRichText.CountPages -1 do begin
                FaxPrinter.PageBegin;
                  WPRichText.Memo.PaintRTFPage( PageNumber, 0, 0, 0, 0, FaxPrinter.GetCanvas, []);
                FaxPrinter.PageEnd;
             end;
             Result := true;
          finally
             FaxPrinter.DocEnd;
          end;

       finally
          // Re-instate original banner setting
          if Globals.PRACINI_SuppressBanner then
             FaxPrinter.SetFaxBanner(HasBanner);
          FaxPrinter.Free;
          // Reset the orientation afterwards
          if SavedOrient = DMORIENT_LANDSCAPE then begin
             SetFaxOrientation(FaxPrinterName,poLandscape);
          end else if SavedOrient = DMORIENT_PORTRAIT then begin
             SetFaxOrientation(FaxPrinterName,poPortrait);
          end;
       end;

   finally
     WPRichText.Free;
   end;
end;

function TCustomDocManager.GetReportByGUID(AGUID: string): TReportBase;
var
  i: integer;
  Report: TReportBase;
begin
  Result := nil;
  if AGUID = '' then
     Exit;
  for i := 0 to Pred(FReportList.Count) do begin
    Report := TReportBase(FReportList.Items[i]);
    if Assigned(Report) then begin
      if Report.GetGUID = AGUID then begin
        Result := Report;
        Exit;
      end;
    end;
  end;
end;

function TCustomDocManager.GetReportByName(AName: string): TReportBase;
var
  i: integer;
  Report: TReportBase;
begin
  Result := nil;
  for i := 0 to Pred(FReportList.Count) do begin
    Report := TReportBase(FReportList.Items[i]);
    if Assigned(Report) then begin
      if Report.Name = AName then begin
        Result := Report;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomDocManager.LoadFromFile(AObjectList: TObjectList);
var
  NodeList: IXMLNodeList;
  ReportNode: IXMLNode;
  Report: TReportBase;
  SettingsXML: IXMLNode;
  Node: IXMLNode;
begin
  //Load custom documents
  if not FileExists(CustomDocFile) then Exit;
  if not Assigned(AdminSystem) then Exit;

  FDocument.PreserveWhiteSpace := False;
  FDocument.Load(CustomDocFile);
  AObjectList.Clear;
  
  NodeList := FDocument.GetElementsByTagName(CUSTOM_DOC_NODE);
  ReportNode := NodeList.NextNode;
  while (ReportNode <> nil) do begin
    Report := TReportBase.Create;
    Report.Lock;
    try
      Report.ReadFromNode(ReportNode);
      Report.Title := CUSTOM_DOC_TITLE;
      if Assigned(Report.Settings) then begin
        ReportNode.SelectSingleNode('Settings', SettingsXML);
        if Assigned(SettingsXML) then begin
          //GUID
          SettingsXML.SelectSingleNode(ReportGUID, Node);
          if Assigned(Node) then
            SetNodeTextStr(Report.Settings, ReportGUID, Node.Text);
          //CData
          SettingsXML.SelectSingleNode('ReportRTF', Node);
          if Assigned(Node) then
            SetNodeTextStr(Report.Settings, 'ReportRTF', Node.Text);
        end;
      end;
      Report.OnReportStatus := nil;
      AObjectList.Add(Report);
    finally
      Report.Unlock;
    end;
    ReportNode := NodeList.NextNode;
  end;
end;


procedure TCustomDocManager.SaveReports;
var
  i: integer;
  TempDocList: TObjectList;
  DoSave: Boolean;
  MemDoc, FileDoc: TReportBase;
begin
  FileLocking.ObtainLock(ltCustomDocument, PRACINI_TicksToWaitForAdmin div 1000);
  try
    DoSave := False;
    TempDocList := TObjectList.Create(True);
    try
      LoadFromFile(TempDocList);
      //Save changes
      for i := 0 to Pred(FreportList.Count) do begin
        MemDoc := TReportBase(FreportList.Items[i]);
        if Assigned(MemDoc) then begin
          //Changed
          if MemDoc.Changed then begin
            DoSave := True;
            Break;
          end;
        end;
      end;
      //Updates from file
      for i := 0 to Pred(TempDocList.Count) do begin
        FileDoc := TReportBase(TempDocList.Items[i]);
        if Assigned(FileDoc) then begin
          MemDoc := GetReportByGUID(FileDoc.GetGUID);
          if Assigned(MemDoc) then begin
            //Update
            if UpdateDoc(MemDoc, FileDoc) then
              DoSave := True;
          end else begin
            //Add
            MemDoc := CustomDocManager.AddCustomDoc(StringToGUID(FileDoc.GetGUID),
                                                    FileDoc.Name,
                                                    FileDoc.GetRTF,
                                                    FileDoc.Createdby,
                                                    FileDoc.CreatedOn);
            FreportList.AddNodeItem(FreportList.Tree.RootNode, MemDoc);
          end;
        end;
      end;
      //Deletes
      for i := Pred(FreportList.Count) downto 0 do begin
        MemDoc := TReportBase(FreportList.Items[i]);
        if Assigned(MemDoc) then begin
          if MemDoc.Deleted then begin
            //Delete
            FReportList.Delete(i);
            DoSave := True;
          end;
        end;
      end;
    finally
      TempDocList.Free;
    end;
    if DoSave then begin
      SaveToFile;
      UpdateMenus;
    end;
  finally
    FileLocking.ReleaseLock(ltCustomDocument);
  end;

end;

procedure TCustomDocManager.SaveToFile;
var
  i: integer;
  Report: TReportBase;
  RootXmlNode, ReportXmlNode: IXMLElement;
  BakFileName: string;
begin
  if Assigned(FReportList) then begin
    FReportList.Sort(CompareReports);
    if FileExists(CustomDocFile) then begin
      //Backup
      BakFileName := ChangeFileExt(CustomDocFile, '.bak');
      if FileExists(BakFileName) then
        RemoveFile(BakFileName);
      RenameFileEx(CustomDocFile, BakFileName);
    end;

    FDocument.ChildNodes.Clear;
    RootXmlNode := FDocument.CreateElement(CUSTOM_DOCS_NODE);
    FDocument.DocumentElement := RootXmlNode;

    for i := 0 to Pred(FReportList.Count) do begin
      Report :=  TReportBase(FReportList.Items[i]);
      if Assigned(Report) then begin
        ReportXmlNode := FDocument.CreateElement(CUSTOM_DOC_NODE);
        RootXMLNode.AppendChild(ReportXmlNode);
        Report.SaveToNode(ReportXmlNode);
        Report.Changed := False;
      end;
    end;

    FDocument.Save(CustomDocFile, ofIndent);
  end;
end;

{ TCustomDocHelper }

function TCustomDocHelper.GetDeleted: Boolean;
var
  Node: IXMLNode;
begin
  Result := False;
  Settings.SelectSingleNode('DocDeleted', Node);
  if Assigned(Node) then
    Result := StrToBool(Node.Text);
end;

function TCustomDocHelper.GetGUID: string;
var
  Node: IXMLNode;
begin
  Result := '';
  Settings.SelectSingleNode(ReportGUID, Node);
  if Assigned(Node) then
    Result := Node.Text;
end;

function TCustomDocHelper.GetRTF: WideString;
begin
  //Check if raw RTF is saved as CDATA (old version)
  Result := GetNodeCData(Settings, 'ReportRTF', '');
  if Result <> '' then begin
    //Delete CDATA node and save as Base64 encoded text
    DeleteNode(Settings, 'ReportRTF');
    SetRTF(Result);
  end;

  Result := ReadRTFData(Settings, 'ReportRTF');
end;

procedure TCustomDocHelper.SetDeleted(const Value: Boolean);
begin
  SetNodeTextStr(Settings, 'DocDeleted', BoolToStr(Value));
end;

procedure TCustomDocHelper.SetRTF(ARTF: Widestring);
begin
  SaveRTFData(Settings, 'ReportRTF', ARTF);
end;


initialization
  _CustomDocManager := nil;
finalization
  if Assigned(_CustomDocManager) then
    _CustomDocManager.Free;
end.

