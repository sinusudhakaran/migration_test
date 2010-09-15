unit MainFrm;
//------------------------------------------------------------------------------
{
   Title:       Main Form

   Description: Main form for ecoding

   Remarks:

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------
interface


uses                                           
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  BaseFrm, Menus, StdCtrls, ecObj, ExtCtrls, RzBckgnd, RzCommon,
  RzCmboBx, Grids_ts, TSGrid, Mask, RzEdit, ComCtrls,
  TSMask, ecSortedTransListObj, ecBankAccountObj, ImgList,
  ECDEFS, AppEvnts, RzLabel, RzBorder, NotesFrm, StdActns, ActnList,
  RzButton, RzRadChk, HTMLHelpViewer, Buttons;

type
  TfrmMain = class(TfrmBase)
    MainMenu1: TMainMenu;
    mnsFile: TMenuItem;
    mnsHelp: TMenuItem;
    mniExit: TMenuItem;
    mniOpen: TMenuItem;
    mruStart: TMenuItem;
    mniDebug: TMenuItem;
    mniNewFile: TMenuItem;
    OpenDialog1: TOpenDialog;
    FileInformation1: TMenuItem;
    RzFrameController1: TRzFrameController;
    pnlCoding: TPanel;
    MaskSet: TtsMaskDefs;
    mniClose: TMenuItem;
    mruEnd: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    N1: TMenuItem;
    mniSave: TMenuItem;
    mniSaveAs: TMenuItem;
    SaveDialog1: TSaveDialog;
    MenuImages: TImageList;
    N2: TMenuItem;
    mniSend: TMenuItem;
    GridPopup: TPopupMenu;
    pmiAddUPC: TMenuItem;
    pmiAddUPD: TMenuItem;
    pmiDissect: TMenuItem;
    N3: TMenuItem;
    pmiDelete: TMenuItem;
    N4: TMenuItem;
    mnsReports: TMenuItem;
    mniReportChart: TMenuItem;
    mniReportPayees: TMenuItem;
    mniReportTransactions: TMenuItem;
    mniTransWithNotes: TMenuItem;
    mniAbandon: TMenuItem;
    pnlBackground: TPanel;
    imgBankLinkB: TImage;
    mniPassword: TMenuItem;
    N6: TMenuItem;
    mniHelp: TMenuItem;
    mniAbout: TMenuItem;
    tgTrans: TtsGrid;
    mniViewEmailLog: TMenuItem;
    NEmailSep: TMenuItem;
    N7: TMenuItem;
    pnlHeader: TPanel;
    lblMyBankAccounts: TLabel;
    Bevel1: TBevel;
    cmbBankAccounts: TRzComboBox;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlPanel: TPanel;
    Label3: TLabel;
    lblAccount: TLabel;
    lblAccountName: TLabel;
    lblGST: TLabel;
    lblPayee: TLabel;
    Label9: TLabel;
    Label5: TLabel;
    lblNarration: TLabel;
    Label2: TLabel;
    lblQuantity: TLabel;
    rzDate: TRzEdit;
    tgAccountLookup: TtsGrid;
    rzQuantity: TRzNumericEdit;
    chkTaxInv: TCheckBox;
    rzGSTAmount: TRzNumericEdit;
    rzReference: TRzEdit;
    rzAmount: TRzNumericEdit;
    rzNarration: TRzEdit;
    rzNotes: TRzMemo;
    lblClientName: TLabel;
    lblTransactions: TLabel;
    imgLogo: TImage;
    lblContactName: TLabel;
    lblContactNumber: TLabel;
    lblContactWebSite: TLabel;
    mnsView: TMenuItem;
    mniPanel: TMenuItem;
    lblOpenFile: TLabel;
    rbtnPrev: TButton;
    rbtnNext: TButton;
    rbtAddUPC: TButton;
    btnSuper: TButton;
    rbtDissect: TButton;
    mniTheme: TMenuItem;
    mnidefault: TMenuItem;
    mnisky: TMenuItem;
    mnidesert: TMenuItem;
    rzFakeAccountBorder: TRzEdit;
    rzFakePayeeBorder: TRzEdit;
    tgPayeeLookup: TtsGrid;
    imgCoded: TImage;
    tmrHideHint: TTimer;
    rbtAddUPW: TButton;
    pmiAddUPW: TMenuItem;
    nUpdates: TMenuItem;
    mniCheckForUpdates: TMenuItem;
    imgPicture: TImage;
    N5: TMenuItem;
    WindowsCalculator1: TMenuItem;
    N8: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Copycontentsofthecellabove1: TMenuItem;
    pnlButtons: TPanel;
    btnSend: TButton;
    btnSave: TButton;
    btnClose: TButton;
    rbtAddUPD: TButton;
    chkShowPanel: TRzCheckBox;
    EditSuperFields1: TMenuItem;
    imgSuper: TImage;
    ImgSuperCoded: TImage;
    mniReportJobList: TMenuItem;
    lblJob: TLabel;
    rzFakeJobBorder: TRzEdit;
    tgJobLookup: TtsGrid;
    lblJobName: TLabel;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;

    procedure FormCreate(Sender: TObject);
    procedure mniExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniOpenClick(Sender: TObject);
    procedure mniNewFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileInformation1Click(Sender: TObject);
    procedure cmbBankAccountsChange(Sender: TObject);
    procedure tgTransCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure tgTransRowLoaded(Sender: TObject; DataRow: Integer);
    procedure tgTransCellChanged(Sender: TObject; OldCol, NewCol, OldRow,
      NewRow: Integer);
    procedure tgTransComboInit(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgTransStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgTransButtonClick(Sender: TObject; DataCol,
      DataRow: Integer);
    procedure tgTransEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgTransCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      ByUser: Boolean);
    procedure tgTransComboRollUp(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgTransComboDropDown(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tgTransRowChanged(Sender: TObject; OldRow, NewRow: Integer);
    procedure FormShow(Sender: TObject);

    procedure pfEnter( Sender : TObject);
    procedure pfEdited( Sender : TObject);
    procedure pfExit( Sender : TObject);
    procedure pfBeginEdit( DataCol : integer);
    procedure pfEndEdit( DataCol : integer);
    procedure pfEndPanelEdit( Undo : boolean);

    procedure chkTaxInvKeyPress(Sender: TObject; var Key: Char);
    procedure rbtnNextClick(Sender: TObject);
    procedure ChartLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
    procedure tgAccountLookupCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgAccountLookupButtonClick(Sender: TObject; DataCol,
      DataRow: Integer);
    procedure tgAccountLookupEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgAccountLookupKeyPress(Sender: TObject; var Key: Char);
    procedure tgAccountLookupCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; ByUser: Boolean);
    procedure mniCloseClick(Sender: TObject);
    procedure tgTransHeadingClick(Sender: TObject; DataCol: Integer);
    procedure rbtAddUPCClick(Sender: TObject);
    procedure tgAccountLookupStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure rbtDissectClick(Sender: TObject);
    procedure tgTransKeyPress(Sender: TObject; var Key: Char);
    procedure mruStartClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure btnCrashClick(Sender: TObject);
    procedure mniSaveClick(Sender: TObject);
    procedure mniSaveAsClick(Sender: TObject);
    procedure mniSendClick(Sender: TObject);
    procedure btnSuperClick(Sender: TObject);
    procedure tgTransKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pmiAddUPCClick(Sender: TObject);
    procedure pmiAddUPDClick(Sender: TObject);
    procedure pmiDissectClick(Sender: TObject);
    procedure pmiDeleteClick(Sender: TObject);
    procedure tgTransMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridPopupPopup(Sender: TObject);
    procedure mniReportTransactionsClick(Sender: TObject);
    procedure mniReportPayeesClick(Sender: TObject);
    procedure mniReportChartClick(Sender: TObject);
    procedure mniTransWithNotesClick(Sender: TObject);
    procedure mniAbandonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure pnlBackgroundClick(Sender: TObject);
    procedure mniPasswordClick(Sender: TObject);
    procedure mniAboutClick(Sender: TObject);
    procedure mniHelpClick(Sender: TObject);
    procedure tgTransEnter(Sender: TObject);
    procedure tgTransExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tgTransMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure rbtnPrevClick(Sender: TObject);
    procedure tgAccountLookupEnter(Sender: TObject);
    procedure tgAccountLookupExit(Sender: TObject);
    procedure tgTransInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure rzGSTAmountKeyPress(Sender: TObject; var Key: Char);
    procedure tgTransColMoved(Sender: TObject; ToDisplayCol,
      Count: Integer; ByUser: Boolean);
    procedure mniViewEmailLogClick(Sender: TObject);
    procedure chkShowPanelClick(Sender: TObject);
    procedure lblContactWebSiteClick(Sender: TObject);
    procedure lblContactNameClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure tgTransMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure mniCommentsClick(Sender: TObject);
    procedure mniPanelClick(Sender: TObject);
    procedure tgPayeeLookupButtonClick(Sender: TObject; DataCol,
      DataRow: Integer);
    procedure tgPayeeLookupCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgPayeeLookupEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgPayeeLookupEnter(Sender: TObject);
    procedure tgPayeeLookupExit(Sender: TObject);
    procedure tgPayeeLookupKeyPress(Sender: TObject; var Key: Char);
    procedure tgPayeeLookupStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgTransClickCell(Sender: TObject; DataColDown, DataRowDown,
      DataColUp, DataRowUp: Integer; DownPos, UpPos: TtsClickPosition);
    procedure mniThemeClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure rzQuantityKeyPress(Sender: TObject; var Key: Char);
    procedure rzAmountKeyPress(Sender: TObject; var Key: Char);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tgTransKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrHideHintTimer(Sender: TObject);
    procedure tgAccountLookupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbtAddUPWClick(Sender: TObject);
    procedure pmiAddUPWClick(Sender: TObject);
    procedure mniCheckForUpdatesClick(Sender: TObject);
    procedure WindowsCalculator1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Copycontentsofthecellabove1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure rbtAddUPDClick(Sender: TObject);
    procedure mniReportJobListClick(Sender: TObject);
    procedure tgJobLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure tgJobLookupEndCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      var Cancel: Boolean);
    procedure tgJobLookupEnter(Sender: TObject);
    procedure tgJobLookupExit(Sender: TObject);
    procedure tgJobLookupKeyPress(Sender: TObject; var Key: Char);
    procedure tgJobLookupStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    //procedure TmrFirstRunTimer(Sender: TObject); Case 8908
  private
    { Private declarations }
    FHint                 : THintWindow;
    FHintShowing          : Boolean;
    LastHintRow           : integer;
    LastHintCol           : integer;
    DisableHints          : boolean;
    FocusedControl        : TWinControl;
    AccountComboDown      : boolean;
    AccountCellChanged    : boolean;
    PayeeCellChanged      : boolean;
    JobCellChanged        : boolean;
    ActiveBankAccountIndex : integer;
    CurrentPanelField     : integer;
    DefaultDir            : string;
    FirstActivateDone     : boolean;
    MouseRightClickPoint  : TPoint;
    MyClientFile          : TEcClient;
    PayeeComboDown        : boolean;
    JobComboDown          : boolean;
    PanelFieldEdited      : boolean;
    ReloadingPanel        : boolean;
    RowColor              : TColor;
    RowSelectedColor      : TColor;
    TranSortOrder         : integer;
    WorkTranList          : tSorted_Transaction_List;
    FormClosing           : Boolean; //flag to indicate if a form close has already been issued
    RemovingMask          : Boolean;
    KeyIsDown             : boolean;
    KeyIsCopy             : boolean;
    BasicChartMap         : TStringList;

    procedure CMFocusChanged(var Msg: TCMFocusChanged); message CM_FocusChanged;

    procedure BuildGrid;
    procedure BuildPanel;

    procedure DoOpenFromDialog;
    procedure DoOpenFromMRUList( Filename : string);
    procedure DoOpenFromCmdLine;

    procedure DoAddUPC;
    procedure DoAddUPI(upi: Byte);
    function  DoDeleteCurrentTransaction : boolean;
    procedure DoGotoNextUncoded;
    function  FindUncoded(const TheCurrentRow: Integer): Integer;
    procedure OpenAndWorkOnFile( const Filename : string; ShowError : Boolean);
    function  CloseAndSaveCurrentFile(MessageType : Integer) : boolean;
    procedure AbandonCurrentFile;
    function  SaveCurrentFile : boolean; overload;
    function  SaveCurrentFile( Filename : string): boolean; overload;
    function  GetNewFilename( var NewFilename : string) : boolean;

    procedure ShowFileInformation;
    procedure ReloadDesktopScheme;

    procedure LoadWorkTranList;
    procedure LoadWTLMaintainPos;
    procedure LoadWTLNewSort(NewSortOrder: integer);
    procedure RepositionOnTransaction( pT : pTransaction_Rec);
    procedure RepositionOnRow( NewDataRow : integer);
    procedure SetSortOrder(NewSortOrder: integer);

    procedure LoadBankAccount( Index : integer);
    procedure CloseActiveBankAccount;

    function  GetTransactionAtRow( DataRow : integer) : pTransaction_Rec;
    function  GetCellData( const DataCol : integer; const DataRow : integer) : variant;

    procedure PayeeLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
    procedure PayeeLookupKeyPress(Sender: TObject; var Key: Char);
    procedure AccountEdited( NewValue : string; pT : pTransaction_Rec);
    procedure GSTAmountEdited( NewValue : double; pT : pTransaction_Rec; ValueEmpty : Boolean);
    procedure PayeeEdited( NewValue : string; pT : pTransaction_Rec);
    procedure AmountEdited( NewValue : double; pT : pTransaction_Rec);

    function  NextEditableCellRight : integer;
    function  NextEditableCellLeft : integer;
    procedure ReloadPanel( pT : pTransaction_Rec);
    procedure DisableToolbar;
    procedure EnableToolbar;

    function  DissectThisEntry( pT : pTransaction_Rec) : boolean;
    function  DoDissection : boolean;

    procedure UpdateMenuItems;
    procedure DoSendFile;
    function  CalcGSTAmountFromPercentStr(sPercent: string; pT : pTransaction_Rec): string;
    procedure EndAllEdits(undo: boolean);

    function IsCoded( CONST T : pTransaction_Rec ): Boolean; overload;
    function IsCoded( aClient : TEcClient; CONST T : pTransaction_Rec ): Boolean; overload;
    function IsUncoded( CONST T : pTransaction_Rec ): Boolean; overload;
    //function IsUncoded( aClient : TClientObj; CONST T : pTransaction_Rec ): Boolean; overload;
    procedure HideCustomHint;
    procedure ShowHintForCell(const RowNum, ColNum: integer);
    function NumberIsValid( aControl : TCustomEdit; const LeftDigits, RightDigits: integer): boolean;
    function GetCodeEntriesHint(const T: pTransaction_Rec): string;
    procedure BuildInitChartMap;
    function HasPayee: Boolean;
    function HasQuantity: Boolean;
    procedure DoDeleteDissection( pT : pTransaction_Rec);
    procedure Dump_Dissections(var p : pTransaction_Rec);
    procedure Dispose_Dissection_Rec(p : PDissection_Rec);
    procedure BtnShow(Value: TButton);
    procedure BtnHide(Value: TButton);
    function SuperfundDissection(pT  : pTransaction_Rec): Boolean;
    procedure JobLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure JobLookupKeyPress(Sender: TObject; var Key: Char);
    procedure JobEdited(NewValue: string; pT: pTransaction_Rec);
  public
    { Public declarations }
    Is256Color : Boolean;
    property BasicChart: TStringList read BasicChartMap;
  end;

var
  frmMain: TfrmMain;

//******************************************************************************

implementation

{$R *.DFM}

uses
  Files,
  WinUtils,
  ShellAPI,
  bkdbExcept,
  ecdsio,
  ecExcept,
  ecGlobalConst,
  ecGlobalVars,
  ecTransactionListObj,
  ectxio,
  INISettings,
  bkconst,
  genutils,
  gstutils,
  moneydef,
  mxUtils,
  Syslog,
  DissectionFrm,
  SendFrm,
  StStrS,
  glConst,
  MruListUtils,
  UpcRangeFrm,
  ChequeListObj,
  ecReports,
  PasswordFrm,
  ecColors,
  AboutFrm,
  ecMessageBoxUtils,
  SentItems,
  ImagesFrm,
  EditSuperFrm,
  ecPayeeListObj, ECollect, ECpyIO, DIMimeStreams, jpeg, MimeUtils, FormUtils,
  ecPayeeObj, ecJobObj, ecUpgradeHelper, MonitorUtils, NotesHelp, Malloc, ClipBrd;

const
  LOGOWIDTH = 256;
  LOGOHEIGHT = 85;
  btnW = 160;
type
  EInvalidTransRequest = class( EEcodingException);

const
  UnitName = 'MainFrm';

  SAVE_NOMSG = 0;
  SAVE_AUTOMSG = 1;
  SAVE_BEFOREMSG = 2;

  AutoSaveMsg = ecGlobalConst.APP_NAME + ' will now automatically save this file for you.'+#13#10;
  SaveBeforeMsg = ecGlobalConst.APP_NAME + ' will need to automatically save this file before you can work on another.'+#13#10;
  FirstSaveMsg = 'Because this is the first time the file has been saved you ' +
                 'will now be prompted for a filename.';

const
  //column constants. order is
  //Date, Reference, Narration, Amount, GST*, Tax Invoice*, Qty*, Account*, Payee*,Job*, Notes
  //* indicates optional fields

  ccMin = 1;

  ccCoded       = 1;
  ccDateEff     = 2;
  ccReference   = 3;
  ccNarration   = 4;
  ccAccount     = 5;
  ccAmount      = 6;
  ccGSTAmount   = 7;
  ccTaxInv      = 8;
  ccQuantity    = 9;
  ccPayee       = 10;
  ccJob         = 11;
  ccNotes       = 12;

  ccMax = 12;

var
  ccNames : Array[ ccMin..ccMax] of string =
    ( '',
      'Date',
      'Reference',
      'Narration',
      'Account',
      'Amount',
      'GST',
      'Tax Inv',
      'Quantity',
      'Payee',
      'Job',
      'Notes');

  ccDefaultWidth : Array[ ccMin..ccMax] of integer =
    (26,            //ccCoded
     70,            //ccDateEff
     100,           //ccReference
     150,           //ccNarration
     80,            //ccAccount
     140,           //ccAmount
     70,            //ccGSTAmount
     50,            //ccTaxInv
     70,            //ccQuantity
     90,            //ccPayee
     90,            //ccJob
     130);          //ccNotes

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetFocusSafe( Control : TWinControl);
begin
   try
      Control.SetFocus;
   except
      On E : EInvalidOperation do ;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TransHasPayeesInDissection(pT : pTransaction_Rec) : boolean;
var
   pD: pDissection_Rec;
begin
   result := false;
   pD := pT.txFirst_Dissection;
   while ( pd <> nil) do begin
      if pD.dsPayee_Number <> 0 then begin
         result := true;
         exit;
      end;
      pD := pD.dsNext;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormCreate(Sender: TObject);
begin
   inherited;

   //lblVersion.Caption        := ecGlobalConst.APP_NAME + ' ' + WinUtils.GetAppVersionStr;
   Self.Caption              := ecGlobalConst.APP_NAME;
   Application.Title         := ecGlobalConst.APP_NAME;
   FirstActivateDone         := false;
   ActiveBankAccountIndex    := -1;
   DefaultDir                := ExtractFilePath( Application.ExeName);
   if BKFileExists(DefaultDir + 'Notes_Guide.CHM') then
     Application.HelpFile      := DefaultDir + 'Notes_Guide.CHM';
   KeyIsDown                 := false;
   KeyIsCopy                 := false;
   BasicChartMap             := TStringList.Create;
   
   FHint := THintWindow.Create( Self );
   FHint.Canvas.Font.Name := 'Courier';
   FHint.Canvas.Font.Size := 5;
   FHintShowing := false;
   DisableHints := false;

   DisplayMRU( mnsFile, mruStart, mruEnd, mruStartClick);

   MyClientFile := nil;

   //set defaults
   mnsFile.Enabled := false;

   mniHelp.Caption := ecGlobalConst.APP_TITLE + ' &Help';
   mniAbout.caption := 'About ' + ecGlobalConst.APP_TITLE;
   mniViewEmailLog.Visible := ( INI_MAIL_TYPE = mtSMTP );
   NEmailSep.Visible       := mniViewEmailLog.Visible;

   UpdateMenuItems;
   pnlCoding.Visible := false;
   pnlCoding.Align := alClient;
   pnlPanel.visible  := false;

   DisableToolbar;

   TranSortOrder     := csDateEffective;
   AccountComboDown  := false;
   PayeeComboDown    := false;
   JobComboDown      := false;

   lblClientName.Caption := '';
   lblTransactions.Caption := '';
   lblContactName.Caption := '';
   lblContactNumber.Caption := '';
   lblContactWebSite.Caption := '';

   BKHelpSetUp(Self, BKH_Chapter_2_BankLink_Notes_basics);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.CMFocusChanged(var Msg: TCMFocusChanged);
begin
  if not (Msg.Sender is TButton) then
    FocusedControl := Msg.Sender;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniExitClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   inherited;
   //Update window state into INI values
   case WindowState of
      wsNormal: begin
        INI_mfStatus := 1; // Normal
        //save position and size
        INI_mfTop    := Top;
        INI_mfLeft   := Left;
        INI_mfWidth  := Width;
        INI_mfHeight := Height;
      end;
      wsMinimized:
         INI_mfStatus := 2;  {useless: this value is never set by VCL!!}
      wsMaximized:
         INI_mfStatus := 3;
   end;
   INI_mfShowPanel := chkShowPanel.Checked;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOpenClick(Sender: TObject);
begin
   DoOpenFromDialog;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniNewFileClick(Sender: TObject);
var
   NewEC : TEcClient;
begin
   NewEC := TEcClient.Create;
   NewEC.ecFields.ecCode := 'TEST';
   NewEC.ecFields.ecName := 'Test Client';
   NewEC.SaveToFile( 'TEST.TRF');
   NewEC.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  BasicChartMap.Free;
  tgPayeeLookup.DestroyDefaultCombo;
  tgAccountLookup.DestroyDefaultCombo;
  tgJobLookup.DestroyDefaultCombo;

  if Assigned( FHint ) then begin
    if FHint.HandleAllocated then FHint.ReleaseHandle;
    FHint.Free;
    FHint := nil;
  end;

  WorkTranList.Free;
  MyClientFile.Free;
  MyClientFile := nil;
  inherited;
end;

procedure TfrmMain.FileInformation1Click(Sender: TObject);
begin
   ShowFileInformation;
end;

procedure TfrmMain.DoOpenFromDialog;
begin
  //close existing file
  if Assigned( MyClientFile) then begin
    if not CloseAndSaveCurrentFile(SAVE_BEFOREMSG) then exit;
  end;

  //load open dialog filter
  OpenDialog1.Filter := ecGlobalConst.APP_NAME + ' file ( *.' +  ecGlobalConst.Default_File_Extn + ')|'+
                        '*.' + ecGlobalConst.Default_File_Extn  + '|' +
                        'Any file (*.*)|*.*';
  OpenDialog1.DefaultExt :=  ecGlobalConst.Default_File_Extn;
  //set initial dir from ini stored value
  if (INISettings.INI_DefaultFileLocation = '') then
    OpenDialog1.InitialDir := DefaultDir
  else
    OpenDialog1.InitialDir := INISettings.INI_DefaultFileLocation;
  //set title
  OpenDialog1.Title      := 'Open ' + ecGlobalConst.APP_NAME + ' file...';

  //select a file using open dialog
  if not OpenDialog1.Execute then exit;

  OpenAndWorkOnFile( OpenDialog1.FileName, true);
end;

procedure TfrmMain.ShowFileInformation;
var
   s : string;
   b : integer;
begin
   if not Assigned( MyClientFile) then begin
      S := 'No file open';
   end
   else begin
      S := MyClientFile.ecFields.ecName + '  [' + MyClientFile.ecFields.ecCode + '] '#13#13;
      S := S + inttostr( MyClientFile.ecBankAccounts.ItemCount) + ' Bank Account(s)'#13;
      for b := 0 to Pred( MyClientFile.ecBankAccounts.ItemCount) do begin
         S := S + '   ' + MyClientFile.ecBankAccounts.Bank_Account_At( b).baFields.baBank_Account_Number + ' ' +
                  MyClientFile.ecBankAccounts.Bank_Account_At( b).baFields.baBank_Account_Name + #13;
         S := S + '   ' + inttostr( MyClientFile.ecBankAccounts.Bank_Account_At( b).baTransaction_List.ItemCount) +
                  ' transactions'#13;
      end;
      S := S + #13 + inttostr( MyClientFile.ecChart.CountBasicItems) + ' Chart Code(s)'#13;
      S := S + inttostr( MyClientFile.ecPayees.ItemCount) + ' Payee(s)'#13;
      S := S + inttostr( MyClientFile.ecJobs.NonCompletedJobCount) + ' Job(s)'#13;
   end;
   InfoMessage( S);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.OpenAndWorkOnFile(const Filename: string; ShowError : Boolean);
var
  i : integer;
  ba : TECBank_Account;
  eMsg : string;
begin
  Assert( MyClientFile = nil, 'OpenAndWorkOnFile called with File <> nil');

  lblOpenFile.Caption := 'Opening file ' + Filename + '...';
  mnsFile.Enabled := false;
  mnsHelp.Enabled := false;
  try
    Files.OpenFile( filename, MyClientFile, eMsg, Self.Handle);
    if ApplicationMustShutdownForUpdate then
    begin
      Application.Terminate;
      exit;
    end;
  finally
    mnsHelp.Enabled := true;
    mnsFile.Enabled := true;
    lblOpenFile.Caption := 'Click here to open a ' + APP_NAME + ' file';
  end;
  LockWindowUpdate(Handle);
  try
  if not Assigned( MyClientFile) then begin
     if ShowError then
        ErrorMessage( 'Cannot open file. '#13#13 + eMsg);

     INI_LastFileOpened      := '';
     //INI_DefaultFileLocation := ExtractFilePath( ParamStr( 0));
     exit;
  end;
  //check password
  if MyClientFile.ecFields.ecFile_Password <> '' then begin
     if not EnterPassword( MyClientFile.ecFields.ecFile_Password) then begin
        Files.CloseFile( MyClientFile);
        exit;
     end;
  end;

  INI_LastFileOpened := Filename;
  if (MyClientFile.ecFields.ecFirst_Save_Done) then
    INI_DefaultFileLocation := ExtractFilePath( Filename);

  //file opened successfully
  if MyClientFile.ecFields.ecFile_Opened_Read_Only then
     Self.Caption := ExtractFileName( MyClientFile.ecFields.ecFilename) + '(Read-Only) - ' + ecGlobalConst.APP_NAME
  else
     Self.Caption :=  ExtractFileName( MyClientFile.ecFields.ecFilename) + ' - ' + ecGlobalConst.APP_NAME;

  Application.Title := Self.Caption;

  lblClientName.Caption := MyClientFile.ecFields.ecName;

  if (MyClientFile.ecBankAccounts.ItemCount > 1) then
    eMsg := 's'
  else
    eMsg := '';

  lblTransactions.Caption :=
    IntToStr(MyClientFile.ecBankAccounts.ItemCount) +
    ' account' + eMsg + ' from ' + bkDate2Str(MyClientFile.ecfields.ecDate_Range_From) +
    ' - ' + bkDate2Str( MyClientFile.ecFields.ecDate_Range_To);

  //add to mru list
  AddToMRU(filename);
  DisplayMRU(mnsFile, mruStart, mruEnd, mruStartClick);

  //load bank account drop down
  cmbBankAccounts.Items.Clear;
  with MyClientFile do begin
    for i := 0 to Pred( ecBankAccounts.ItemCount) do begin
      ba := ecBankAccounts.Bank_Account_At( i);
      cmbBankAccounts.Add(GetAccountDetails(ba, ecFields.ecCountry));
    end;
  end;
  cmbBankAccounts.ItemIndex := 0;

  UpdateMenuItems;
  BuildInitChartMap;

  //load the custom graphic
  if (MyClientFile.ecFields.ecPractice_Logo = '') then
    AppImages.imgLogo.Picture := nil
  else
  begin
    try
      DecodePictureFromString(MyClientFile.ecFields.ecPractice_Logo, AppImages.imgLogo.Picture);
    except
      on E: EInvalidGraphic do
        //ErrorMessage(E.Message);
        AppImages.imgLogo.Picture := nil;
    end;
  end;

  ReloadDesktopScheme;

  //code transactions for first bank account


  pnlHeader.enabled         := true;
  lblMyBankAccounts.Enabled := true;
  cmbBankAccounts.enabled   := true;

//  if Assigned(MyClientFile) then
//    if (MyClientFile.ecFields.ecShow_Notes_On_Open) and (MyClientFile.ecFields.ecNotes <> '') then
//      ShowNotes(MyClientFile);

  //ReloadDesktopScheme;
  {Case 8908
  if not AttemptedReportBack then
     TmrFirstRun.Enabled := true;
  }
  BKHelpSetUp(Self, BKH_Chapter_3_Processing_transactions);
  LoadBankAccount(0);
  finally
     LockWindowUpdate(0);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ReloadDesktopScheme;
var
  WidthAspect, HeightAspect : Double;
begin
  ApplyStandards(Self);

  //set border colors
  RzFrameController1.FrameColor := clBorderColor;
  pnlTop.Color := clBorderColor;
  pnlLeft.Color := clBorderColor;
  pnlBottom.Color := clBorderColor;
  pnlButtons.Color := clBtnFace;
  pnlRight.Color := clBorderColor;

  //display logo
  if Assigned(MyClientFile)
  and (MyClientFile.ecFields.ecPractice_Logo <> '')
  and (ImagesFrm.AppImages.imgLogo.Picture.Width > 0)
  and (ImagesFrm.AppImages.imgLogo.Picture.Height > 0)
     then begin
        //set default width and height
        imgLogo.Top := 3;
        imgLogo.Left := ClientWidth - LOGOWIDTH - 2;
        imgLogo.Width := LOGOWIDTH;
        imgLogo.Height := LOGOHEIGHT;
        imgLogo.Picture := ImagesFrm.AppImages.imgLogo.Picture;

        WidthAspect := (imgLogo.Width / imgLogo.Picture.Width);
        HeightAspect := (imgLogo.Height / imgLogo.Picture.Height);
        if (WidthAspect < HeightAspect) then begin
           imgLogo.Width := Trunc(imgLogo.Picture.Width * WidthAspect);
           imgLogo.Height := Trunc(imgLogo.Picture.Height * WidthAspect);
        end else begin
           imgLogo.Width := Trunc(imgLogo.Picture.Width * HeightAspect);
           imgLogo.Height := Trunc(imgLogo.Picture.Height * HeightAspect);
        end;
        //imgLogo.Left := ClientWidth - imgLogo.Width - 2;
        imgLogo.Visible := True;
     end else
        imgLogo.Visible := False;

  //contact details
  if Assigned(MyClientFile) then
  begin
     if MyClientFile.ecFields.ecSuper_Fund_System > 0 then
       BtnShow(btnSuper)
    else
       BtnHide(btnSuper);

    if (MyClientFile.ecFields.ecRestrict_UPIs) then
    begin
      BtnHide(rbtAddUPC);
      BtnHide(rbtAddUPD);
      BtnHide(rbtAddUPW);
      pmiAddUPC.Enabled := False;
      pmiAddUPD.Enabled := False;
      pmiAddUPW.Enabled := False;
    end else
    begin
      BtnShow(rbtAddUPC);
      BtnShow(rbtAddUPD);
      BtnShow(rbtAddUPW);
      pmiAddUPC.Enabled := True;
      pmiAddUPD.Enabled := True;
      pmiAddUPW.Enabled := True;
    end;

    //contact name
    if (MyClientFile.ecFields.ecContact_Person <> '') then
      lblContactName.Caption := MyClientFile.ecFields.ecContact_Person
    else
      lblContactName.Caption := MyClientFile.ecFields.ecContact_EMail_Address;
    if (MyClientFile.ecFields.ecContact_EMail_Address = '') then
    begin
      lblContactName.Font.Color := clWindowText;
      lblContactName.Font.Style := [];
      lblContactName.Cursor := crDefault;
    end else
    begin
      lblContactName.Font.Color := clBlue;
      lblContactName.Font.Style := [fsUnderline];
      lblContactName.Cursor := crHandPoint;
    end;
    //contact number and website
    lblContactNumber.Caption := MyClientFile.ecFields.ecContact_Phone_Number;
    lblContactWebSite.Caption := MyClientFile.ecFields.ecPractice_Web_Site;
  end else
  begin
    BtnHide(btnSuper);
    lblContactName.Caption := '';
    lblContactNumber.Caption := '';
    lblContactWebSite.Caption := '';
  end;

  //reposition contact details


  RowColor           := ecColors.clAltLine;
  RowSelectedColor   := ecColors.clSelectedRow;
  pnlHeader.Invalidate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.cmbBankAccountsChange(Sender: TObject);
begin
   if cmbBankAccounts.ItemIndex <> -1 then
   begin
     if (tgTrans.Col[ccAccount].Visible) then
       cmbBankAccounts.Hint := cmbBankAccounts.Items[cmbBankAccounts.ItemIndex];
     //see if index has changed
     if ActiveBankAccountIndex = cmbBankAccounts.ItemIndex then
        exit;
     //load selected bank account
     LoadBankAccount(cmbBankAccounts.ItemIndex);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.LoadWorkTranList;
//load transactions from the transaction list into a sorted transaction list
var
   pT : pTransaction_Rec;
   i  : integer;
begin
   //end any edits
   tgTrans.EndEdit( false);
   pfEndPanelEdit( false);
   tgTrans.Rows := 0;

   if Assigned( WorkTranList) then begin
      WorkTranList.DeleteAll;  //delete all pointers
      WorkTranList.Free;
      WorkTranList := nil;
   end;
   //now reload
   WorkTranList := tSorted_Transaction_List.Create( MyClientFile.ecFields.ecCountry,
                                                    TranSortOrder);
   with MyClientFile.ActiveBankAccount.baTransaction_List do begin
      for i := 0 to Pred( ItemCount) do begin
         pT := Transaction_At( i);
         WorkTranList.Insert( pT);
      end;
   end;
   tgTrans.Rows := WorkTranList.ItemCount;
   tgTrans.Invalidate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.BuildGrid;
var
  i : integer;
begin
  tgTrans.Cols  := ccMax;
  tgTrans.CheckBoxStyle := stCheck;
  ccNames[7]:=MyClientFile.SalesTaxNameFromCountry(MyClientFile.ecFields.ecCountry);

  for i := ccMin to ccMax do
  begin
    tgTrans.Col[ i].Heading        := ccNames[ i];
    tgTrans.Col[ i].ControlType    := tsGrid.ctText;
    tgTrans.Col[ i].Width          := ccDefaultWidth[ i];
    if (i in [ ccGSTAmount, ccTaxInv, ccNotes, ccQuantity]) then
      //these fields are always editable
      tgTrans.Col[ i].ReadOnly := False
    else
      tgTrans.Col[ i].ReadOnly := True;
  end;

  //if we set the read only property for the cell the dissect button
 //is never shown, control using StartCellEdit()
  tgTrans.Col[ ccAmount].ReadOnly := False;

  //set picture col
  tgTrans.Col[ ccCoded].ControlType := ctPicture;

  //set max length
  tgTrans.Col[ ccAccount].MaxLength   := MaxBK5CodeLen;
  tgTrans.Col[ ccNarration].MaxLength := 200;
  tgTrans.Col[ ccPayee].MaxLength     := 40;
  tgTrans.Col[ ccJob].MaxLength       := 60;

  //set data masks
  tgTrans.Col[ ccAccount ].MaskName     := '';
  tgTrans.Col[ ccDateEff ].MaskName     := 'DateMask';
  tgTrans.Col[ ccAmount ].MaskName      := 'MoneyMask';
  tgTrans.Col[ ccGSTAmount ].MaskName   := 'MoneyMask';
  tgTrans.Col[ ccQuantity ].MaskName    := 'QtyMask';

  //set word wrap
  tgTrans.Col[ ccNarration ].WordWrap   := wwOn;
  tgTrans.Col[ ccPayee ].WordWrap       := wwOn;
  tgTrans.Col[ ccJob].WordWrap          := wwOn;

  //set alignment
  tgTrans.Col[ ccAmount].Alignment      := taRightJustify;
  tgTrans.Col[ ccGSTAmount].Alignment   := taRightJustify;
  tgTrans.Col[ ccQuantity].Alignment    := taRightJustify;

  //set trans type
  tgTrans.Col[ ccTaxInv].ControlType    := ctCheck;
  tgTrans.Col[ ccTaxInv].CheckBoxValues := 'Y|N';

  tgTrans.Col[ ccAccount].DropDownStyle := ddDropDownList;
  tgTrans.Col[ ccPayee].DropDownStyle   := ddDropDownList;
  tgTrans.Col[ ccJob].DropDownStyle     := ddDropDownList;

  //client specific fields
  if Assigned( MyClientFile) then
  begin
    //account col editable if chart exists by default
    if MyClientFile.ecChart.CountBasicItems = 0 then
    begin
      tgTrans.Col[ ccAccount].ReadOnly   := true;
      tgTrans.Col[ ccAccount].ParentFont := false;
      tgTrans.Col[ ccAccount].Font.Color := clNavy; //clGray;
    end else
    begin
      tgTrans.Col[ ccAccount].ReadOnly   := false;
      tgTrans.Col[ ccAccount].ParentFont := true;
    end;

    //payee col editable by default, will be made invisible if not allowed
    tgTrans.Col[ ccPayee].ReadOnly   := false;
    tgTrans.Col[ ccPayee].ParentFont := true;

    tgTrans.Col[ ccJob].ReadOnly     := false;
    tgTrans.Col[ ccJob].ParentFont   := true;

    //visible fields
    tgTrans.Col[ccGSTAmount].Visible := (not MyClientFile.ecFields.ecHide_GST_Col);
    tgTrans.Col[ccTaxInv].Visible := (not MyClientFile.ecFields.ecHide_Tax_Invoice_Col);
    tgTrans.Col[ccQuantity].Visible := (not MyClientFile.ecFields.ecHide_Quantity_Col);
    tgTrans.Col[ccAccount].Visible := (not MyClientFile.ecFields.ecHide_Account_Col);
    tgTrans.Col[ccPayee].Visible := (not MyClientFile.ecFields.ecHide_Payee_Col);
    tgTrans.Col[ccJob].Visible := not MyClientFile.ecFields.ecHide_Job_Col;

    {for i := 1 to tgTrans.Cols do
    begin
      tgTrans.Col[i].HeadingFont := tgTrans.HeadingFont;
      if (tgTrans.Col[i].Visible) and (tgTrans.Col[i].ReadOnly) then
        tgTrans.Col[i].HeadingFont.Color := clWhite
      else
        tgTrans.Col[i].HeadingFont.Color := clSelectedRow;
    end;}

    for i := ccMin to ccMax do
    begin
      if not (i in [ccAccount, ccAmount, ccGSTAmount, ccPayee, ccJob]) then
      begin
        if (tgTrans.Col[i].ReadOnly) then
        begin
          tgTrans.Col[i].ParentFont := False;
          tgTrans.Col[i].Font.Color := clNavy; //clGray;
        end;
      end;
    end;

    tgTrans.CurrentDataCol := ccAccount;
    if not tgTrans.Col[ccAccount].Visible then
      tgTrans.CurrentDataCol := NextEditableCellRight;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.LoadBankAccount(Index: integer);
begin
  if not Assigned( MyClientFile) then
     exit;
  LockWindowUpdate(Handle);
  try
  //close currently active bank account
  CloseActiveBankAccount;

  //load new bank account
  try
    // ActiveBankAccount := MyClientFile.ecBankAccounts.Bank_Account_At( Index);
    MyClientFile.ActiveBankAccount := MyClientFile.ecBankAccounts.Bank_Account_At( Index);
  except
    on E: CollException do
    begin
      AbandonCurrentFile;
      DisableToolBar;
      exit;
    end;
  end;
  ActiveBankAccountIndex := Index;
  TranSortOrder     := csDateEffective;
  LoadWorkTranList;
  BuildGrid;
  BuildPanel;

  if WorkTranList.ItemCount > 0 then begin
     tgTrans.CurrentDataRow := 1;
     ReloadPanel( GetTransactionAtRow( 1));
     tgTrans.RowColor[ 1] := RowSelectedColor;
  end;

  tgTrans.Invalidate;
  pnlCoding.Visible := true;
  SetFocusSafe( tgTrans);

  EnableToolbar;

  FormResize(Self);
  finally
     LockWindowUpdate(0);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
begin
   if ( DataRow > 0) and ( DataCol > 0) then begin
      Value := GetCellData( DataCol, DataRow);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.GetCellData(const DataCol, DataRow: integer): variant;
var
   pT  : pTransaction_Rec;
   pPY : TECPayee;
begin
   result := '';
   if ( tgTrans.Rows < 1) then exit;  //no transactions in account

   pT := GetTransactionAtRow( DataRow);
   if assigned( pT) then begin
      case dataCol of
         ccCoded       :  begin
          if (pT^.txCode_Locked) then begin

            if pt^.txSF_Edited or SuperfundDissection(PT) then
               Result := BitmapToVariant( imgSuperCoded.Picture.Bitmap)
            else
               Result := BitmapToVariant( ImgCoded.Picture.Bitmap);
          end else
             if pt^.txSF_Edited or SuperfundDissection(PT) then
                Result := BitmapToVariant( imgSuper.Picture.Bitmap)

         end;
         ccDateEff     :  result := bkDate2Str( pT^.txDate_Effective);
         ccReference    : result := GetFormattedReference( pT);
         ccAccount      : begin
            result := pT^.txAccount;

            if pT^.txCode_Locked then begin
               //tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roOn;   mjch: Wont show ellipse if read only
               //                                                                control using startcelledit()
               tgTrans.CellParentFont[ DataCol, DataRow] := false;
               tgTrans.CellColor[ DataCol, DataRow]      := clNone;
               tgTrans.CellFont[ DataCol, DataRow].color := clNavy; //clGray;
            end
            else begin
               //code is not locked
               if not (( pT^.txAccount='' ) or
                       ( pT^.txFirst_Dissection <> nil) or
                       ( MyClientFile.ecChart.CanCodeTo( pT^.txAccount ))
                       ) then
               begin
                  //code is invalid
                  tgTrans.CellParentFont[ DataCol, DataRow] := false;
                  tgTrans.CellFont[ DataCol, DataRow].color := clWhite;
                  tgTrans.CellColor[ DataCol, DataRow]      := clRed;
               end
               else begin
                  //set to normal access and color
                  tgTrans.CellParentFont[ DataCol, DataRow] := true;
                  tgTrans.CellColor[ DataCol, DataRow]      := clNone;
               end;
            end

         end;
         ccAmount       : begin
            if pT^.txAmount > 0 then
              result := MakeAmountStr( pT^.txAmount)+ '  '
            else
              result := MakeAmountStr( pT^.txAmount);

            if pT^.txUPI_State in [upUPC, upUPD, upUPW] then
            begin
              //set color to red if amount is required
              if pT^.txAmount = 0 then
              begin
                tgTrans.CellParentFont[ DataCol, DataRow] := false;
                tgTrans.CellFont[ DataCol, DataRow].color := clRed; //clWhite;
              end
              else
                tgTrans.CellParentFont[ DataCol, DataRow] := true;

              //allow editing of the amount
              //if we set the read only property for the cell the dissect button
              //is never shown, control using StartCellEdit()
              //tgTrans.CellReadOnly[ DataCol, DataRow]   := tsGrid.roOff;

            end else  begin
              //set to normal access and color
              tgTrans.CellParentFont[ DataCol, DataRow] := False;
              tgTrans.CellColor[ DataCol, DataRow]      := clNone;
              tgTrans.CellFont[ DataCol, DataRow].Color := clNavy;
              //tgTrans.CellReadOnly[ DataCol, DataRow]   := tsGrid.roOff; //Default;
            end;

            //set button type depending on whether transaction is dissected or not
            if (pT^.txFirst_Dissection <> nil) and (not tgTrans.Col[ccAccount].Visible) then
               tgTrans.CellButtonType[ DataCol, DataRow] := btNormal
            {else if pt^.txSF_Edited  then
               tgTrans.CellButtonType[ DataCol, DataRow] := btNormal}
            else
               tgTrans.CellButtonType[ DataCol, DataRow] := btNone;


         end;
         ccGSTAmount    : begin
            if (pT^.txFirst_Dissection <> nil) then
            begin
              //disable gst amount if dissected
              tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roOn;
              tgTrans.CellParentFont[ DataCol, DataRow] := false;
              tgTrans.CellFont[ DataCol, DataRow].color := clNavy; //clGray;
            end else
            begin
              tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roDefault;
              tgTrans.CellParentFont[ DataCol, DataRow] := true;
            end;
            if (pT^.txGST_Amount = 0.00) and (not pT^.txGST_Has_Been_Edited) then
              Result := ''
            else
              result := MakeAmountStr( pT^.txGST_Amount);
            {
            if pT^.txGST_Has_Been_Edited then begin
               tgTrans.CellParentFont[ DataCol, DataRow] := false;
               tgTrans.CellFont[ DataCol, DataRow].color := clBlue
            end
            else begin
               tgTrans.CellParentFont[ DataCol, DataRow] := true;
            end;
            }
         end;
         ccTaxInv       : begin
           if pT^.txTax_Invoice_Available then
             result := 'Y' //cbChecked
           else
             result := 'N'; //cbUnchecked;
         end;
         ccNarration    : begin
           result := pT^.txNarration;
         end;

         ccPayee        : begin
            if (pT^.txCode_Locked) then
            begin
              tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roOn;
              tgTrans.CellParentFont[ DataCol, DataRow] := false;
              tgTrans.CellFont[ DataCol, DataRow].color := clNavy; //clGray;
            end
            else begin
               tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roDefault;
               tgTrans.CellParentFont[ DataCol, DataRow] := true;
            end;

            pPY := MyClientFile.ecPayees.Find_Payee_Number( pT^.txPayee_Number);
            if Assigned( pPY) then result := pPY.pdName;
         end;
         ccJob:
          begin
            if (pT^.txCode_Locked) then
            begin
              tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roOn;
              tgTrans.CellParentFont[ DataCol, DataRow] := false;
              tgTrans.CellFont[ DataCol, DataRow].color := clNavy; //clGray;
            end
            else
            begin
               tgTrans.CellReadOnly[ DataCol, DataRow] := tsGrid.roDefault;
               tgTrans.CellParentFont[ DataCol, DataRow] := true;
            end;
            result := pT^.txJob_Code;
          end;
         ccQuantity     : result := MakeQuantityStr( pT^.txQuantity);
         ccNotes        : result := pT^.txNotes;
      end; //case
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransRowLoaded(Sender: TObject; DataRow: Integer);
var
   mTH, cTH : Integer;
   i : Integer;
begin
   //set row height for cols with word wrap
   mTH := 0;
   For i := ccMin to ccMax do begin
      If ( tgTrans.Col[ i ].Visible) and ( tgTrans.Col[ i].WordWrap = wwOn) then begin
         cTH := tgTrans.CellTextHeight[ i, DataRow ];
         If cTH > mTH then mTH := cTH;
      end;
   end;
   if ( mth + 1) < ( tgTrans.DefaultRowHeight) then
      mth := tgTrans.defaultrowheight - 1;
   //make sure no more than 3 rows high
   if ( mth + 1) > ( 2 * tgTrans.DefaultRowHeight) then
      mth := ( 2 * tgTrans.DefaultRowHeight) -1;

   tgTrans.RowHeight[ DataRow ] := mTH + 1;
   //make sure correct row color is set
   if Odd( DataRow) and ( DataRow <> tgTrans.CurrentDataRow) then
      tgTrans.RowColor[ DataRow ] := RowColor;

{   //set access
   for i := ccMin to ccMax do begin
      tgTrans.CellReadOnly[ i, DataRow] := tsGrid.roDefault;
   end;

   pT := GetTransactionAtRow( DataRow);
   if pT^.txCode_Locked then begin

   end;
}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransCellChanged(Sender: TObject; OldCol, NewCol,
  OldRow, NewRow: Integer);
var
  pT : pTransaction_Rec;
  i  : integer;
  ManualMoveRow: Boolean;
begin
   tgTrans.OnCellChanged := nil;
   try
     if (( OldRow >= 1) and ( OldRow <= tgTrans.Rows)) and
        (( NewRow >= 1) and ( NewRow <= tgTrans.Rows)) then
     begin
       HideCustomHint;
       if OldCol in [ ccAccount, ccPayee, ccJob] then begin
          tgTrans.CellButtonType[ OldCol, OldRow] := btDefault;
          tgTrans.CellReadOnly[ NewCol, NewRow]   := roDefault;
       end;

       pT := nil;
       ManualMoveRow := False;

       {tgTrans.CellButtonType[ccAmount, OldRow] := btDefault;
       if NewCol in [ccAmount] then begin
          pT := GetTransactionAtRow(NewRow);

          if (MyClientFile.ecFields.ecSuper_Fund_System > 0)
          and (Pt.txFirst_Dissection = nil)  then
             tgTrans.CellButtonType[ NewCol, NewRow] := btNormal
          else
             tgTrans.CellButtonType[ NewCol, NewRow] := btDefault;
       end;}


       if NewCol in [ ccAccount] then
       begin
         //set button type depending on whether transaction is dissected or not
         pT := GetTransactionAtRow( NewRow);

         if pT^.txFirst_Dissection <> nil then begin
            tgTrans.CellButtonType[ NewCol, NewRow] := btNormal;
         end else
         begin
           if pT^.txCode_Locked or ( MyClientFile.ecChart.CountBasicItems = 0) then begin
             tgTrans.CellButtonType[ NewCol, NewRow] := tsGrid.btDefault;
           end
           else begin
             tgTrans.CellButtonType[ NewCol, NewRow] := btCombo;
             tgTrans.CellParentCombo[ NewCol, NewRow] := False;
           end;
         end;
       end;

       if NewCol in [ ccPayee, ccJob] then
       begin
         //set button type depending on whether transaction is dissected or not
         pT := GetTransactionAtRow( NewRow);

         if pT^.txCode_Locked then
         begin
           tgTrans.CellButtonType[ NewCol, NewRow] := tsGrid.btDefault;
         end
         else
         begin
           tgTrans.CellButtonType[ NewCol, NewRow] := btCombo;
           tgTrans.CellParentCombo[ NewCol, NewRow] := False;
         end;
       end;

       if (NewRow = (OldRow - 1)) then
       begin
         if (OldCol < NewCol) then
           //make sure right most col is made visible first
           for i := ccMax downto ccMin do
             if tgTrans.DisplayColnr[ i] = 12 then
             begin
               tgTrans.PutCellInView( i, NewRow);
               break;
               ManualMoveRow := True;
             end;
       end
       else
       if (NewRow = OldRow + 1) then
       begin
         if (NewCol < OldCol) then
           //make sure left most col is made visible first
           for i := ccMin to ccMax do
             if tgTrans.DisplayColnr[ i] = 1 then begin
               tgTrans.PutCellInView( i, NewRow);
               ManualMoveRow := True;
               break;
             end;
       end;

       if (NewCol < ccAccount) or ((NewCol = ccAmount) and (Assigned(pT) and (not (pT^.txUPI_State in [upUPC, upUPD, upUPW])))) then
       begin
         if (not ManualMoveRow) and (NewCol < OldCol) then
         begin
           tgTrans.CurrentDataCol := OldCol;
           tgTrans.CurrentDataCol := NextEditableCellLeft;
         end
         else
           tgTrans.CurrentDataCol := NextEditableCellRight;
         for i := ccMin to ccMax do
           if tgTrans.DisplayColnr[ i] = 1 then begin
             tgTrans.PutCellInView( i, NewRow);
             break;
           end;
       end;

       ShowHintForCell(NewRow, NewCol);
     end;
    
   finally
    tgTrans.OnCellChanged := tgTransCellChanged;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.BuildInitChartMap;
var
  i: Integer;
  Account : pAccount_Rec;
begin
  BasicChartMap.Clear;
  i := 0;
  while i < MyClientFile.ecChart.ItemCount do
  begin
    Account := MyClientFile.ecChart.Account_At(i);
    if Assigned(Account) and (not Account.chHide_In_Basic_Chart) then
      BasicChartMap.Add(IntToStr(i))
    else
    begin
      while Assigned(Account) and Account.chHide_In_Basic_Chart and (i < MyClientFile.ecChart.ItemCount) do
      begin
        Inc(i);
        if i = MyClientFile.ecChart.ItemCount then
          Break;
        Account := MyClientFile.ecChart.Account_At(i);
      end;
      if i < MyClientFile.ecChart.ItemCount then
        BasicChartMap.Add(IntToStr(i));
    end;
    Inc(i);
  end;
end;

procedure TfrmMain.tgTransComboInit(Sender: TObject; Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
   if not Assigned( MyClientFile) then exit;

   //detect if a combobox from the panel is selected
   if (TtsComboGrid(Sender).Name = tgAccountLookup.Name) then
     DataCol := ccAccount
   else if (TtsComboGrid(Sender).Name = tgPayeeLookup.Name) then
     DataCol := ccPayee
   else if (TtsComboGrid(Sender).Name = tgJobLookup.Name) then
     DataCol := ccJob;

   case DataCol of
      ccAccount : begin
          HideCustomHint;
          Combo.DropDownRows  := 10;
          Combo.DropDownCols  := 2;
          Combo.Grid.Rows     := MyClientFile.ecChart.CountBasicItems;
          Combo.Grid.Cols     := 2;
          Combo.Grid.Width    := 275;
          Combo.Grid.Font.Size        := 8;
          Combo.Grid.Col[ 1].Width    := 75;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 1;
          Combo.Grid.ValueColSorted   := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.AutoFill         := False;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;
          Combo.Grid.OnCellLoaded     := ChartLookupCellLoaded;
          Combo.Grid.OnKeyPress       := nil;
          BuildInitChartMap;
      end;

      ccPayee : begin
          HideCustomHint;
          Combo.DropDownRows  := 10;
          Combo.DropDownCols  := 2;
          Combo.Grid.Rows     := MyClientFile.ecPayees.ItemCount;
          Combo.Grid.Cols     := 2;
          Combo.Grid.Width    := 250;
          Combo.Grid.Font.Size        := 8;
          Combo.Grid.Col[ 1].Width    := 50;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 2;
          Combo.Grid.ValueColSorted   := True;
          Combo.AutoLookup            := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.AutoFill         := True;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;

          Combo.Grid.OnCellLoaded     := PayeeLookupCellLoaded;
          Combo.Grid.OnKeyPress       := PayeeLookupKeyPress;
      end;

      ccJob:
        begin
          HideCustomHint;
          Combo.DropDownRows := 10;
          Combo.DropDownCols := 2;
          Combo.Grid.Rows    := MyClientFile.ecJobs.NonCompletedJobCount;
          Combo.Grid.Cols    := 2;
          Combo.Grid.Width   := 300;
          Combo.Grid.Font.Size     := 8;
          Combo.Grid.Col[1].Width  := 100;
          Combo.Grid.Col[ 2].Width    := 200;
          Combo.Grid.ValueCol         := 1;
          Combo.Grid.ValueColSorted   := True;
          Combo.AutoLookup            := True;
          Combo.Grid.AutoSearch       := asCenter;
          Combo.Grid.AutoFill         := True;
          Combo.Grid.DefaultRowHeight := 22;
          Combo.Grid.GridLines        := tsgrid.glHorzLines;          

          Combo.Grid.OnCellLoaded     := JobLookupCellLoaded;
          Combo.Grid.OnKeyPress       := JobLookupKeyPress;
        end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ChartLookupCellLoaded(Sender: TObject; DataCol, DataRow: Integer; var Value: Variant);
var
   Account : pAccount_Rec;
   Combo   : TTsComboGrid;
   i       : Integer;
begin
  if not Assigned( MyClientFile) then exit;
  i := StrToInt(BasicChartMap[DataRow-1]);
  Account := MyClientFile.ecChart.Account_At(i);
  if Assigned( Account) then
  begin
    // find next basic acct
    while Assigned(Account) and Account.chHide_In_Basic_Chart and (i < MyClientFile.ecChart.ItemCount) do
    begin
      Inc(i);
      Account := MyClientFile.ecChart.Account_At(i);
    end;
    if (i = MyClientFile.ecChart.ItemCount) then
      exit;
    case DataCol of
       1: value := Account.chAccount_Code;
       2: value := Account.chAccount_Description;
    end;
    //gray out if no posting allowed
    Combo := TTsComboGrid( Sender);
    if Account.chPosting_Allowed then
      Combo.RowParentFont[ DataRow] := true
    else
    begin
      Combo.RowParentFont[ DataRow] := false;
      Combo.RowFont[ DataRow].Color := clNavy; //clGray;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.PayeeLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
   Payee : TECPayee;
begin
   if not Assigned( MyClientFile) then exit;

   Payee := MyClientFile.ecPayees.Payee_At( Pred( DataRow));
   if Assigned( Payee) then begin
      case DataCol of
         1 : Value := IntToStr(Payee.pdNumber);
         2 : value := Payee.pdName;
      end;
   end;                                      
end;

procedure TFrmMain.JobLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  Job: TECJob;
begin
  if not Assigned(MyClientFile) then Exit;

  Job := MyClientFile.ecJobs.NonCompletedJobAt(Pred(DataRow));
  if Assigned(Job) then
  begin
    case DataCol of
      1: Value := Job.jhFields.jhCode;
      2: Value := Job.jhFields.jhHeading;
    end;
  end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransStartCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
{
The OnStartCellEdit event occurs when a cell is about to be edited and
allows you to cancel the editing if it is not valid.
}
var
   pT : pTransaction_Rec;
begin
   if ( tgTrans.Rows < 1) then begin
      Cancel := true;
      exit;  //no transactions in account
   end;

   pT := GetTransactionAtRow( DataRow);
   if not Assigned( pT) then begin
      Cancel := true;
   end
   else begin
      //the amount col can only be edited if the transaction is a UPC, UPW or UPD
      if ( DataCol = ccAmount) and ( not(pT^.txUPI_State in [upUPC, upUPD, upUPW])) then
      begin
        Cancel := true;
        Exit;
      end;

      if ( Datacol = ccAccount) and ( pT^.txCode_Locked) then
      begin
        Cancel :=true;
        Exit;
      end;

      if ( pT^.txFirst_Dissection <> nil) then begin
         if DataCol in [ ccAccount, ccGSTAmount, ccQuantity] then begin
            Cancel := true;
            exit;
         end;
      end;
   end;
   AccountCellChanged := false;
   PayeeCellChanged := false;
   JobCellChanged := false;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(* Case 8908
procedure TfrmMain.TmrFirstRunTimer(Sender: TObject);
begin
   TmrFirstRun.Enabled := False;
   ReportFirstRun(Handle,MyClientFile);
end;
*)

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.GetTransactionAtRow(DataRow: integer): pTransaction_Rec;
var
   TransIndex : integer;
   aMsg       : string;
begin
   //if valid row for table
   if not ( ( DataRow >= 1) and ( DataRow <= tgTrans.Rows)) then begin
      aMsg := 'Invalid Data Row ' + inttostr( DataRow) + '  [1..' + inttostr( tgTrans.Rows) + ']';
      raise EInvalidTransRequest.Create( aMsg);
   end;
   //is valid index in list
   TransIndex := Pred( DataRow);
   if ( TransIndex < 0) or ( TransIndex > WorkTranList.ItemCount) then begin
      aMsg := 'Invalid TransIndex' + inttostr( transIndex) + '  [0..' + inttostr( WorkTranList.ItemCount) + ']';
      raise EInvalidTransRequest.create( aMsg);
   end;
   //return transaction
   result := WorkTranList.Transaction_At( TransIndex);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransButtonClick(Sender: TObject; DataCol,
  DataRow: Integer);
var
  pT : pTransaction_Rec;
begin
  if ( tgTrans.Rows < 1) then exit;  //no transactions in account

  pT := GetTransactionAtRow( DataRow);
  case DataCol of
    ccAccount: begin
      if pT^.txFirst_Dissection <> nil then
        if DissectThisEntry( pT) then begin
          tgTrans.CurrentDataCol := NextEditableCellRight;
        end;
      end;
    ccAmount : begin
          if pT^.txFirst_Dissection = nil then begin
             {if (MyClientFile.ecFields.ecSuper_Fund_System > 0) then
                btnSuperClick(nil); }
          end else if DissectThisEntry( pT) then begin
             tgTrans.CurrentDataCol := NextEditableCellRight;
          end;
       end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
{
   The OnEndCellEdit event occurs at the end of a cell edit operation either
   when the user leaves the current cell, when the grid loses the focus or when
   the EndEdit method is called.
}
var
  sValue : string;
  CheckBoxState : TCheckboxState;
  pT     : pTransaction_Rec;
  dValue : double;
begin
  sValue := '';
  dValue := 0;
  CheckboxState := cbUnchecked;

  //convert variant to string
  if DataCol in [ ccAccount,
                  ccNarration,
                  ccPayee,
                  ccJob,
                  ccNotes ] then
     sValue := tgTrans.CurrentCell.Value;
  //convert variant to double
  if DataCol in [ ccAmount,
                  ccGSTAmount,
                  ccQuantity ] then begin
     sValue := tgTrans.CurrentCell.Value;
     try
        if sValue = '' then sValue := '0.00';

        dValue := StrToFloat( sValue);
     except
        on E : EConvertError do begin
           exit;
        end;
     end;
  end;
  //convert variant to check box value
  if DataCol in [ ccTaxInv] then
    if (tgTrans.CurrentCell.Value = 'Y') then
      CheckboxState := cbChecked
    else
      CheckboxState := cbUnchecked;

  //update the transaction
  pT := GetTransactionAtRow( DataRow);
  case DataCol of
     ccDateEff :;
     ccReference :;
     ccAccount : begin
        AccountEdited( sValue, pT);
     end;
     ccAmount : begin
        AmountEdited( dValue, pT);
     end;
     ccGSTAmount : begin
       if (tgTrans.CurrentCell.Value = '') then
         GSTAmountEdited( dValue, pT, True)
       else
         GSTAmountEdited( dValue, pT, False);
     end;
     ccTaxInv: begin
        pT^.txTax_Invoice_Available := (CheckboxState = cbChecked);
     end;
     ccNarration : begin
        pT^.txNarration    := sValue;
     end;
     ccQuantity : begin
        pT^.txQuantity     :=  dValue * 10000;
     end;
     ccNotes : begin
        pT^.txNotes        := sValue;
     end;
     ccPayee : begin
        PayeeEdited( sValue, pT);
     end;
     ccJob : begin
       JobEdited(sValue, pT);
     end;
  end; //case

  ReloadPanel( pT);
  tgTrans.RowInvalidate( tgTrans.DisplayRownr[ DataRow]);  //required to update other fields.
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AccountEdited(NewValue: string; pT : pTransaction_Rec);
var
   NewClass : byte;
   NewGST   : Money;
begin
   pT^.txAccount := Trim( NewValue);

   //update GST
   with pT^ do begin
      if MyClientFile.ecChart.CanCodeTo( txAccount) then begin
         CalculateGST( MyClientFile, txDate_Effective, txAccount, txAmount, NewClass, NewGST);
         txGST_Class  := NewClass;
         txGST_Amount := NewGST;
         txCoded_By   := cbManual;
         pT^.txGST_Has_Been_Edited := false;
      end
      else begin
         if ( pT^.txAccount = '' ) then begin
            pT^.txCoded_By        := cbNotcoded;
            pT^.txGST_Class       := 0;
            pT^.txGST_Amount      := 0;
            txHas_Been_Edited := false;
            pT^.txGST_Has_Been_Edited := false;
         end
         else begin
            //is an invalid code, just mark as manually coded so autocode doesnt
            //set to blank
            pT^.txCoded_By        := cbManual;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
//occurs with every keystroke
var
  sValue : string;
  MaskChar : Char;
  APayee : TECPayee;
  AJob: TECJob;
begin
  if DataCol in [ ccAccount] then
    sValue := tgTrans.CurrentCell.Value;
  BtnSave.Enabled := True;
  case DataCol of
    ccAccount : begin
      AccountCellChanged := true;
      if AccountComboDown then exit;

      if (tgTrans.CellEditing) then
      begin
        sValue := tgTrans.CurrentCell.Value;
        if (not RemovingMask) and MyClientFile.ecChart.AddMaskCharToCode(sValue,
           MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
        begin
          sValue := sValue + MaskChar;
          tgTrans.CurrentCell.Value := sValue;
          //move cursor to the last character
          tgTrans.CurrentCell.SelStart := Length(sValue);
        end;
      end;

      //check to see if is a valid code
      if MyClientFile.ecChart.CanPressEnterNow( sValue) then
      begin
        //move to next editable display col
        tgTrans.EndEdit( false);
        tgTrans.CurrentDataCol := NextEditableCellRight;
      end;
    end;

    ccPayee : begin
      PayeeCellChanged := true;
      if PayeeComboDown then exit;
      //check to see if is a valid code
      APayee := MyClientFile.ecPayees.Find_Payee_Name( sValue);
      if Assigned(APayee) then
      begin
        //move to next editable display col
        tgTrans.EndEdit( false);
        tgTrans.CurrentDataCol := NextEditableCellRight;
      end;
    end;
    ccJob:
      begin
        JobCellChanged := true;
        if JobComboDown then exit;
        AJob := MyClientFile.ecJobs.Job_Search(sValue);
        if Assigned(AJob) then
        begin
          tgTrans.EndEdit(false);
          tgTrans.CurrentDataCol := NextEditableCellRight;
        end;
    end;
  end; //case
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.NextEditableCellRight: integer;
var
  dspCol : integer; //display col
  newDataCol : integer;
  CanEdit: Boolean;
  pT : pTransaction_Rec;
begin
   result := tgTrans.currentDataCol;

   dspCol := tgTrans.DisplayColnr[ tgTrans.CurrentDataCol];
   while dspCol < tgTrans.Cols do begin
      Inc( dspCol);
      NewDataCol := tgTrans.DataColnr[ dspCol];
      CanEdit := True;
      if NewDataCol = ccAmount then
      begin
        pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
        if Assigned( pT) and ( not (pT^.txUPI_State in [upUPC, upUPD, upUPW])) then
          CanEdit := False;
      end;
      if ( tgTrans.Col[ NewDataCol].Visible) and ( NewDataCol >= ccAccount) and CanEdit then begin
         result := NewDataCol;
         exit;
      end;
   end;
end;
function TfrmMain.NextEditableCellLeft: integer;
var
  dspCol : integer; //display col
  newDataCol : integer;
  CanEdit: Boolean;
  pT : pTransaction_Rec;
begin
   result := tgTrans.currentDataCol;

   dspCol := tgTrans.DisplayColnr[ tgTrans.CurrentDataCol];
   while dspCol > 1 do begin
      Dec( dspCol);
      NewDataCol := tgTrans.DataColnr[ dspCol];
      CanEdit := True;
      if NewDataCol = ccAmount then
      begin
        pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
        if Assigned( pT) and ( not (pT^.txUPI_State in [upUPC, upUPD, upUPW])) then
          CanEdit := False;
      end;
      if ( tgTrans.Col[ NewDataCol].Visible) and ( NewDataCol >= ccAccount) and CanEdit then begin
         result := NewDataCol;
         exit;
      end;
   end;
   if (dspCol = 1) and (tgTrans.CurrentDataRow > 1) then
   begin
    tgTrans.CurrentDataRow := tgTrans.CurrentDataRow - 1;
    Result := ccNotes;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransComboRollUp(Sender: TObject; Combo: TtsComboGrid;
  DataCol, DataRow: Integer);
begin
   case DataCol of
      ccAccount : begin
         AccountComboDown := false;
         //now auto move if correct
         tgTransCellEdit( Sender, DataCol, DataRow, false);
      end;
      ccPayee : begin
         PayeeComboDown := false;
         //now auto move if correct
         tgTransCellEdit( Sender, DataCol, DataRow, false);
      end;
      ccJob : begin
        JobComboDown := false;
        //now auto move if correct
        tgTransCellEdit(Sender, DataCol, DataRow, false);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransComboDropDown(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
   case DataCol of
      ccAccount : AccountComboDown := true;
      ccPayee : PayeeComboDown := true;
      ccJob: JobComboDown := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if Assigned( MyClientFile) then
   begin
     //FormClosing is to stop BNotes crashing if more close requests are received
     //while CloseAndSaveCurrentFile is being performed.
     if (FormClosing) then
       CanClose := False
     else
     begin
       FormClosing := True;
       if not CloseAndSaveCurrentFile(SAVE_AUTOMSG) then
       begin
         FormClosing := False;
         CanClose := False;
       end;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.CloseActiveBankAccount;
begin
   if not Assigned( MyClientFile.ActiveBankAccount) then exit;
   //finish up any edits
   tgTrans.EndEdit( false);
   pfEndPanelEdit( false);
   DisableToolbar;
   if (tgTrans.CellEditing) then
     tgTrans.EndEdit(True);
   pnlCoding.Visible := false;
   pnlPanel.Visible  := false;

   tgTrans.Rows      := 0;
   //empty work tran list
   WorkTranList.DeleteAll;
   WorkTranList.Free;
   WorkTranList := nil;

   MyClientFile.ActiveBankAccount := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.GSTAmountEdited(NewValue: double; pT: pTransaction_Rec; ValueEmpty : Boolean);
var
   TestGSTAmount : Money;
begin
   //correct amount, should always be the same as sign of trans
   if ( pT^.txAmount < 0) and ( NewValue > 0) or
      ( pT^.txAmount > 0) and ( NewValue < 0) then
      NewValue := -1 * NewValue;

   //should be zero if trans amount zero
   TestGSTAmount := Double2Money( NewValue);
   if ( pT^.txAmount = 0) or ( Abs(pT^.txAmount) < Abs(TestGSTAmount)) then begin
      NewValue := 0;
      ErrorSound;
   end;

   pT^.txGST_Amount := Double2Money( NewValue);

   //check if gst edited
   if (ValueEmpty) then
     pT^.txGST_Has_Been_Edited := False
   else
   begin
     if (pT^.txGST_Amount = 0.00) then
     begin
        pT^.txHas_Been_Edited     := true;
        pT^.txGST_Has_Been_Edited := true;
     end else
     begin
       if GSTDifferentToDefault( MyClientFile, pT ) then begin
          pT^.txHas_Been_Edited     := true;
          pT^.txGST_Has_Been_Edited := true;
       end else
         pT^.txGST_Has_Been_Edited := false;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ReloadPanel(pT: pTransaction_Rec);
var
  APayee : TECPayee;
  pAccount : pAccount_Rec;
  AJob: TECJob;
  pJob: TECJob;
begin
  if pT = nil then exit;

  //pnlPanel.Visible := true;
  ReloadingPanel := true;
  try
    if btnSuper.Width > 0 then
       btnSuper.Enabled := (pT^.txFirst_Dissection = nil);
    rzDate.Text          := bkDate2Str( pT^.txDate_Effective);
    rzReference.Text     := GetFormattedReference( pT);
    tgAccountLookup.Invalidate;
    tgPayeeLookup.Invalidate;
    tgJobLookup.Invalidate;
    rzAmount.Text        := MakeAmountStr( pT^.txAmount);
    if (pT^.txGST_Amount = 0) and (not pt^.txGST_Has_Been_Edited) then
      rzGSTAmount.Text   := ''
    else
      rzGSTAmount.Text   := MakeAmountStr( pT^.txGST_Amount);
    chkTaxInv.Checked    := pT^.txTax_Invoice_Available;
    rzNarration.Text     := pT^.txNarration;
    rzQuantity.Text      := MakeQuantityStr( pT^.txQuantity);
    rzNotes.Text         := pT^.txNotes;

    //set description label
    pAccount := MyClientFile.ecChart.FindCode( pT^.txAccount);
    if Assigned( pAccount) then
      lblAccountName.caption := pAccount.chAccount_Description
    else
      lblAccountName.caption := '';

    //set appearance

    //account
    if ( pT^.txCode_Locked) or ( MyClientFile.ecChart.CountBasicItems = 0) then
    begin
      tgAccountLookup.CellReadOnly[ 1, 1] := tsGrid.roOn;
      tgAccountLookup.CellParentFont[ 1, 1] := false;
      tgAccountLookup.CellFont[ 1, 1].color := clNavy; //clGray;
      tgAccountLookup.CellButtonType[ 1, 1] := tsGrid.btDefault;
      tgAccountLookup.CellColor[ 1, 1]      := clNone;
    end else
    begin
      tgAccountLookup.CellReadOnly[ 1, 1] := tsGrid.roDefault;
      if ( pT^.txAccount='' ) or
         ( pT^.txFirst_Dissection <> nil) or
         ( MyClientFile.ecChart.CanCodeTo( pT^.txAccount )) then begin
        tgAccountLookup.CellParentFont[ 1, 1] := true;
        tgAccountLookup.CellColor[ 1, 1]      := clNone;
      end
      else begin
        tgAccountLookup.CellParentFont[ 1, 1] := false;
        tgAccountLookup.CellColor[ 1, 1]      := clRed;
        tgAccountLookup.CellFont[ 1, 1].color := clWhite;
      end;
      tgAccountLookup.CellButtonType[ 1, 1] := btCombo;
      tgAccountLookup.CellParentCombo[ 1, 1] := False;
    end;

    //payee
    if ( pT^.txCode_Locked) or (MyClientFile.ecPayees.ItemCount = 0)  then
    begin
      tgPayeeLookup.CellReadOnly[ 1, 1] := tsGrid.roOn;
      tgPayeeLookup.CellParentFont[ 1, 1] := false;
      tgPayeeLookup.CellFont[ 1, 1].color := clNavy; //clGray;
      tgPayeeLookup.CellButtonType[ 1, 1] := tsGrid.btDefault;
    end else
    begin
      tgPayeeLookup.CellReadOnly[ 1, 1] := tsGrid.roDefault;
      //value will be the payee name, convert back to payee no for storage
      APayee := MyClientFile.ecPayees.Find_Payee_Number( pT^.txPayee_Number);
      if ( pT^.txPayee_Number = 0 ) or
         ( pT^.txFirst_Dissection <> nil) or
         ( Assigned( APayee)) then begin
        tgPayeeLookup.CellParentFont[ 1, 1] := true;
        tgPayeeLookup.CellColor[ 1, 1]      := clNone;
      end
      else begin
        tgPayeeLookup.CellParentFont[ 1, 1] := false;
        tgPayeeLookup.CellColor[ 1, 1]      := clRed;
        tgPayeeLookup.CellFont[ 1, 1].color := clWhite;

        tgPayeeLookup.CellButtonType[ 1, 1] := btCombo;
        tgPayeeLookup.CellParentCombo[ 1, 1] := False;
      end;
    end;

    //Job
    if (pT^.txCode_Locked) or (MyClientFile.ecJobs.NonCompletedJobCount = 0) then
    begin
      tgJobLookup.CellReadOnly[1, 1] := TSGrid.roOn;
      tgJobLookup.CellParentFont[1, 1] := false;
      tgJobLookup.CellFont[1, 1].Color := clNavy;
      tgJobLookup.CellButtonType[1, 1] := TSGrid.btDefault;
      tgJobLookup.CellColor[1, 1] := clNone;
    end
    else
    begin
      tgJobLookup.CellReadOnly[1, 1] := TSGrid.roDefault;
      AJob := MyClientFile.ecJobs.Find_Job_Code(pT^.txJob_Code);
      if (pT^.txJob_Code = '') or Assigned(AJob) then
      begin
        tgJobLookup.CellParentFont[1, 1] := true;
        tgJobLookup.CellColor[1, 1] := clNone;
      end
      else
      begin
        tgJobLookup.CellParentFont[1, 1] := false;
        tgJobLookup.CellColor[1, 1] := clRed;
        tgJobLookup.CellFont[1, 1].Color := clWhite;

        tgJobLookup.CellButtonType[1, 1] := btCombo;
        tgPayeeLookup.CellParentCombo[1, 1] := False;
      end;
    end;

    //set job Name label
    pJob := MyClientFile.ecJobs.Find_Job_Code(pT^.txJob_Code);
    if Assigned( pJob) then
      lblJobName.caption := pJob.jhFields.jhHeading
    else
      lblJobName.caption := '';

    SetEditState(rzDate, False);
    SetEditState(rzReference, False);
    SetEditState(rzAmount, (pT^.txUPI_State in [upUPC, upUPD, upUPW]));
    if (pT^.txAmount = 0) then
      rzAmount.Font.Color := clRed;

    SetEditState(rzGSTAmount, (pT^.txFirst_Dissection = nil));
    SetEditState(rzQuantity, (pT^.txFirst_Dissection = nil));
    SetEditState(rzNarration, False);

    //enable or disable the dissect button
    if ( pT^.txCode_Locked) and ( pT^.txFirst_Dissection = nil) then
      rbtDissect.Enabled := False
    else
      rbtDissect.Enabled := True;

  finally
    ReloadingPanel := false;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//it is necessary to test if the row values are in range because changing the row
//count will force this event to be called
//
procedure TfrmMain.tgTransRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
begin
  HideCustomHint;
  if ( tgTrans.Rows < 1) then
    //no transactions loaded
    exit;

  if (( OldRow >= 1) and ( OldRow <= tgTrans.Rows)) then
  begin
    //reset normal color
    if Odd( OldRow) then
      tgTrans.RowColor[ OldRow ] := RowColor
    else
      tgTrans.RowColor[ OldRow] := tgTrans.Color;

    tgTrans.RowInvalidate( tgTrans.DisplayRownr[ OldRow]);  //required to update other fields.
  end;

  if (( NewRow >= 1) and ( NewRow <= tgTrans.Rows)) then
  begin
    //set row selected color
    tgTrans.RowColor[ NewRow] :=  RowSelectedColor;
    //reload current transaction
    ReloadPanel( GetTransactionAtRow( NewRow));

    tgTrans.RowInvalidate( tgTrans.DisplayRownr[ NewRow]);  //required to update other fields.
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.BuildPanel;
var
  STax: string;
begin
  //setup tags
  rzDate.Tag            := ccDateEff;
  rzReference.Tag       := ccReference;
  rzAmount.Tag          := ccAmount;
  rzGSTAmount.Tag       := ccGSTAmount;
  chkTaxInv.Tag         := ccTaxInv;
  rzQuantity.Tag        := ccQuantity;
  rzNarration.Tag       := ccNarration;
  rzNotes.Tag           := ccNotes;

  //set max length
  tgAccountLookup.Col[ 1].MaxLength := MaxBK5CodeLen;
  tgPayeeLookup.Col[ 1].MaxLength   := MaxBK5CodeLen;

  if Assigned( MyClientFile) then
  begin
    //account col editable if chart exists by default
    tgAccountLookup.Col[ 1].ReadOnly := ( MyClientFile.ecChart.CountBasicItems = 0);
    //payee and job cols editable by default, will be hidden below if necessary
    tgPayeeLookup.Col[ 1].ReadOnly := False;
    tgJobLookup.Col[1].ReadOnly := False;


    with MyClientFile.ecFields do
    begin
      tgAccountLookup.Visible := (not ecHide_Account_Col);
      lblAccount.Visible := tgAccountLookup.Visible;
      rzFakeAccountBorder.Visible := tgAccountLookup.Visible;
      lblAccountName.Visible := tgAccountLookup.Visible;

      tgPayeeLookup.Visible := (not ecHide_Payee_Col);
      lblPayee.Visible := tgPayeeLookup.Visible;
      rzFakePayeeBorder.Visible := tgPayeeLookup.Visible;

      tgJobLookup.Visible := not ecHide_Job_Col;
      lblJob.Visible := tgJobLookup.Visible;
      rzFakeJobBorder.Visible := tgJobLookup.Visible;
      lblJobName.Visible := tgJobLookup.Visible;

      lblGST.Visible := (not ecHide_GST_Col);
      rzGSTAmount.Visible := (not ecHide_GST_Col);
      chkTaxInv.Visible := (not ecHide_Tax_Invoice_Col);
      lblQuantity.Visible := (not ecHide_Quantity_Col);
      rzQuantity.Visible  := (not ecHide_Quantity_Col);

      STax:=MyClientFile.SalesTaxNameFromCountry(ecCountry);
      lblGST.Caption := STax;
    end;

    chkShowPanelClick(chkShowPanel);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormShow(Sender: TObject);
var
  i : Integer;
  CaptionText : String;
   WorkArea : TRect;
   MonitorHeight : integer;
begin
  FormClosing := False;
  FocusedControl := nil;

  RemovingMask := False;
  
  //set the global constant for color depth
  Is256Color := (WinUtils.GetScreenColors( Self.Canvas.Handle) <= 256);
  ecColors.SetDefaultColors(Is256Color);

  //set theme menu
  i := 0;
  repeat
    CaptionText := RemoveCharsFromString(mniTheme.Items[i].Caption, ['&']);
    if (CaptionText = INI_Theme) then
      mniTheme.Items[i].Checked := True
    else
      Inc(i);
  until (i >= mniTheme.Count) or (CaptionText = INI_Theme);
  if (i >= mniTheme.Count) then
    mnidefault.Checked := True;

  pnlbackground.Align := alClient;
  chkShowPanel.Checked := True;

  //display correct graphic
  if (Is256Color) then
  begin
    pnlBackGround.Color := BKCOLOR_TEAL;
    imgBankLinkB.Picture := AppImages.imgBankLinkLogo256.Picture;
    imgPicture.Visible := False;
  end
  else
  begin
    imgBankLinkB.Picture := AppImages.imgBankLinkLogoHiColor.Picture;
    WorkArea := GetDesktopWorkArea;
    MonitorHeight := WorkArea.Bottom - WorkArea.Top;
    if MonitorHeight > 480 then
      imgPicture.Picture := AppImages.imgPictureLogo.Picture
    else
      imgPicture.Visible := False;
  end;

  if INI_mfStatus <> 0 then
  begin
    if INI_mfTop = -1 then Top := 0 else Top := INI_mfTop;
    if INI_mfLeft = -1 then Left := 0 else Left := INI_mfLeft;
    if INI_mfWidth = -1 then Width := 640 else Width := INI_mfWidth;
    if INI_mfHeight = -1 then Height := 480 else Height := INI_mfHeight;
  end;
  chkShowPanel.Checked := INI_mfShowPanel;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.chkTaxInvKeyPress(Sender: TObject; var Key: Char);
//reinterpret enter as tab,
//can't use raise check box because exit event does not seem to work
begin
  if ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end else
    inherited KeyPress( Key );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfEnter(Sender: TObject);
//called when a panel field gets focus
begin
  CurrentPanelField := TComponent( Sender).Tag;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfBeginEdit(DataCol: integer);
begin
  panelFieldEdited := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfEndEdit(DataCol: integer);
var
  pT     : pTransaction_Rec;
  dValue : double;
  sValue : String;
  lOK    : Boolean;
  Index  : Integer;
begin
  if panelFieldEdited then
  begin
    lOK := True;
    panelFieldEdited := false;
    pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
    //save new value
    case DataCol of
       ccDateEff :;
       ccReference :;
       //ccAccount :  handled by tgAccountLookup grid
       ccAmount : begin
         sValue := RemoveCharsFromString(rzAmount.Text,[',']);
         if (sValue <> '') and (sValue[1] = '(') then
         begin
           //negative value
           sValue[1] := '-';
           Index := Pos(')', sValue);
           if (Index > 0) then
             sValue := Copy(sValue,1,Index-1);
         end;
         lOK := MaskSet.Masks.Items[tgTrans.Col[ccAmount].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
           dValue := StrToFloatDef( rzAmount.Text, 0);
           AmountEdited( dValue, pT);
         end else
         begin
           pfEnter(rzAmount);
           SetFocusSafe( rzAmount);
         end;
       end;
       ccGSTAmount : begin
         sValue := RemoveCharsFromString(rzGSTAmount.Text,[',']);
         if (sValue <> '') and (sValue[1] = '(') then
         begin
           //negative value
           sValue[1] := '-';
           Index := Pos(')', sValue);
           if (Index > 0) then
             sValue := Copy(sValue,1,Index-1);
         end;
         lOK := MaskSet.Mask[tgTrans.Col[ccGSTAmount].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
           if (rzGSTAmount.Text = '') then
           begin
             dValue := 0.00;
             GSTAmountEdited(dValue, pT, True);
           end else
           begin
             dValue := StrToFloatDef( rzGSTAmount.Text, 0);
             GSTAmountEdited(dValue, pT, False);
           end;
         end else
         begin
           pfEnter(rzGSTAmount);
           SetFocusSafe( rzGSTAmount);
         end;
       end;
       ccTaxInv : begin
          pT^.txTax_Invoice_Available := chkTaxInv.Checked;
       end;
       ccNarration : begin
          pT^.txNarration := rzNarration.Text;
       end;
       ccQuantity : begin
         sValue := RemoveCharsFromString(rzQuantity.Text,[',']);
         lOK := MaskSet.Masks.Items[tgTrans.Col[ccQuantity].MaskName].ValidText(sValue, True);
         if (lOK) then
         begin
           dValue := StrToFloatDef( rzQuantity.Text, 0);
           pT^.txQuantity :=  dValue * 10000;
         end else
         begin
           pfEnter(rzQuantity);
           SetFocusSafe( rzQuantity);
         end;
       end;
       ccNotes : begin
          pT^.txNotes := rzNotes.Text;
       end;
    end; //case
    if (lOK) then
    begin
      tgTrans.RowInvalidate( tgTrans.DisplayRownr[ tgTrans.CurrentDataRow]);;
      ReloadPanel( pT);
    end else
      ErrorMessage('The entered amount is too large. Please divide the value into smaller amounts.');
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfEdited(Sender: TObject);
begin
   if ReloadingPanel then exit;

   if CurrentPanelField <> 0 then begin
      Assert( CurrentPanelField = TComponent( Sender).Tag, 'pfEdited.  Wrong Tag');
      pfBeginEdit( CurrentPanelField);

      if CurrentPanelField = ccNotes then
         rzNotes.TabOnEnter := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfExit(Sender: TObject);
var
  PanelField : Integer;
begin
   Assert( CurrentPanelField = TComponent( Sender).Tag, 'pfExit.  Wrong Tag');

   if CurrentPanelField <> 0 then
   begin
     //value is copied in case there is an error in the pfEndEdit procedure
     PanelField := CurrentPanelField;
     CurrentPanelField := 0;
     pfEndEdit(PanelField);

     if (PanelField = ccNotes) then
        rzNotes.TabOnEnter := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pfEndPanelEdit(Undo: boolean);
begin
  pfEndEdit( CurrentPanelField);
  tgAccountLookup.EndEdit( Undo);
  tgPayeeLookup.EndEdit( Undo);
  tgJobLookup.EndEdit(Undo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.rbtnNextClick(Sender: TObject);
var
  NewRow : integer;
begin
  //set focus
  if (FocusedControl <> nil) then
  begin
    if (FocusedControl <> rbtnPrev) and (FocusedControl <> rbtnNext) and
       (FocusedControl.Parent = pnlPanel) then
      begin
        //pressing alt+n does not cause the exit/enter events because the
        //focus has not changed. CurrentPanelField <> 0 indicates that we are
        //current in a field
        if CurrentPanelField <> 0 then
          begin
            pfExit(FocusedControl);
            pfEnter(FocusedControl);
          end;
      end;
    SetFocusSafe(FocusedControl);
  end;

  NewRow := ( tgTrans.CurrentDataRow + 1);
  RepositionOnRow( NewRow);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.PayeeLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key in ['0'..'9']) then
    Key := '0'
  else
    Key := 'A';
end;

procedure TfrmMain.JobLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9'] then
    Key := '0'
  else
    Key := 'A';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DisableToolbar;
begin
  lblMyBankAccounts.enabled    := false;
  cmbBankAccounts.enabled      := false;

  rbtDissect.Width := 0;
  rbtAddUPC.Width := 0;
  rbtAddUPD.Width := 0;
  rbtAddUPW.Width := 0;
  chkShowPanel.Visible         := False;

  pnlTop.Visible := False;
  pnlHeader.Visible := False;
  pnlLeft.Visible := False;
  pnlRight.Visible := False;
  pnlBottom.Height := 33;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.EnableToolbar;
begin
  lblMyBankAccounts.enabled    := true;
  cmbBankAccounts.enabled      := true;

  btnShow(rbtDissect);
  if (Assigned(MyClientFile)) then begin

     if MyClientFile.ecFields.ecSuper_Fund_System > 0 then
        BtnShow(btnSuper)
     else
        BtnHide(btnSuper);

     if (MyClientFile.ecFields.ecRestrict_UPIs) then begin
        btnHide(rbtAddUPC);
        btnHide(rbtAddUPD);
        btnHide(rbtAddUPW);
        pmiAddUPC.Enabled := False;
        pmiAddUPD.Enabled := False;
        pmiAddUPW.Enabled := False;
     end else begin
        btnShow(rbtAddUPC);
        btnShow(rbtAddUPD);
        btnShow(rbtAddUPW);
        pmiAddUPC.Enabled := True;
        pmiAddUPD.Enabled := True;
        pmiAddUPW.Enabled := True;
     end;


        
  end else begin
     btnShow(rbtAddUPC);
     btnShow(rbtAddUPD);
     btnShow(rbtAddUPW);
     BtnHide(btnSuper);
  end;
  chkShowPanel.Visible := True;

  pnlTop.Visible := True;
  pnlHeader.Visible := True;
  pnlLeft.Visible := True;
  pnlRight.Visible := True;
  pnlBottom.Visible := True;
   pnlBottom.Height := 42;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
   pT : pTransaction_Rec;
begin
   if ( tgTrans.Rows < 1) then exit;  //no transactions in account

   Value := GetCellData( ccAccount, tgTrans.CurrentDataRow);
   pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
   if pT^.txCode_Locked or ( MyClientFile.ecChart.CountBasicItems = 0) then
      tgAccountLookup.CellButtonType[ 1, 1] := btNone
   else
   if pT^.txFirst_Dissection <> nil then begin
      tgAccountLookup.CellButtonType[ 1, 1] := btNormal;
   end
   else begin
      tgAccountLookup.CellButtonType[ 1, 1] := btCombo;
      tgAccountLookup.CellParentCombo[ 1, 1] := False;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupButtonClick(Sender: TObject; DataCol,
  DataRow: Integer);
var
   pT : pTransaction_Rec;
begin
   pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
   if ( pT^.txFirst_Dissection <> nil) then
      if DissectThisEntry( pT) then begin
         PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
  pT     : pTransaction_Rec;
begin
  //convert variant to string
  sValue := tgAccountLookup.CurrentCell.Value;
  //update the transaction
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  AccountEdited( sValue, pT);
  tgTrans.Invalidate;
  ReloadPanel( pT);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if AccountComboDown then exit;
  if tgAccountLookup.CellEditing then exit;

  //dissect entry
  if Key = '/' then
  begin
    Key := #0;
    DoDissection;
  end else if ( Ord( Key ) = vk_Return ) then
  begin
    //interpret return as tab
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end else
    inherited KeyPress( Key );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
var
  sValue : string;
  MaskChar : Char;
begin
  if AccountComboDown then
    exit;

  sValue := tgAccountLookup.CurrentCell.Value;

  if (tgAccountLookup.CellEditing) then
  begin
    if (not RemovingMask) and MyClientFile.ecChart.AddMaskCharToCode(sValue,
       MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
    begin
      sValue := sValue + MaskChar;
      tgAccountLookup.CurrentCell.Value := sValue;
      //move cursor to the last character
      tgAccountLookup.CurrentCell.SelStart := Length(sValue);
    end;
  end;

  //check to see if is a valid code
  if MyClientFile.ecChart.CanPressEnterNow( sValue) then
  begin
    //press enter
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCloseClick(Sender: TObject);
begin
  CloseAndSaveCurrentFile(SAVE_AUTOMSG);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.SetSortOrder( NewSortOrder : integer);
begin
   TranSortOrder  := NewSortOrder;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.LoadWTLNewSort(NewSortOrder: integer);
begin
   //if ( TranSortOrder = NewSortOrder ) then exit;
   SetSortOrder(NewSortOrder);
   LoadWTLMaintainPos;
   tgTrans.Invalidate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.LoadWTLMaintainPos;
//reload the working transactions list but maintain the current row
var
   pT : pTransaction_Rec;
begin
   if ( WorkTranList.ItemCount > 0 ) then
   begin
      //save current trans pointer and reload then reposition
      //ActiveRow transaction pointer may not be valid due to
      //deletion of underlying transaction. eg UPC match
      try
        pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
      except
        on ECorruptData do pT := nil;
        on EAccessViolation do pT := nil;
        on EInvalidTransRequest do pT := nil;
      end;
      LoadWorkTranList;

      if pT = nil then begin
         tgTrans.CurrentDataRow  := 1;
         exit;
      end;

      RepositionOnTransaction( pT);
   end
   else begin
      //no trans in current list, reload the transaction list
      LoadWorkTranList;
      tgTrans.CurrentDataRow := 1
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransHeadingClick(Sender: TObject; DataCol: Integer);
var
   NewSortOrder : integer;
   i            : integer;
begin
   case DataCol of
     ccDateEff: NewSortOrder := csDateEffective;
     ccAmount : NewSortOrder := csByValue;
     ccAccount: NewSortOrder := csAccountCode;
     ccNarration : NewSortOrder := csByNarration;
     ccReference: NewSortOrder := csChequeNumber;
   else
     NewSortOrder := -1;
   end;

   if NewSortOrder <> -1 then
   begin
      tgTrans.BeginUpdate;
      try
        DisableHints := true;
        //clear sort col indicator
        for i := ccMin to ccMax do
           tgTrans.Col[ i].SortPicture := tsGrid.spNone;
        LoadWTLNewSort( NewSortOrder);
        tgTrans.Col[ DataCol].SortPicture := tsGrid.spDown;
      finally
        DisableHints := false;
        tgTrans.EndUpdate;
      end;

      ShowHintForCell(tgTrans.CurrentDataRow,tgTrans.CurrentDataCol);
   end;
end;

procedure TfrmMain.rbtAddUPCClick(Sender: TObject);
begin
  DoAddUPC;
end;
procedure TfrmMain.rbtAddUPDClick(Sender: TObject);
begin
   DoAddUPI(upUPD);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgAccountLookupStartCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
   pT : pTransaction_Rec;
begin
   pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
   if not Assigned( pT) then begin
      Cancel := true;
   end
   else begin
      if ( pT^.txFirst_Dissection <> nil) then begin
         Cancel := true;
         exit;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.DissectThisEntry(pT : pTransaction_Rec) : boolean;
begin
  result := false;
  if ( pT^.txCode_Locked) and ( pT^.txFirst_Dissection = nil) then exit;

  if DissectEntry( MyClientFile, pT) then begin
     ReloadPanel( pT);
     Result := true;
     btnSave.Enabled := True;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.rbtDissectClick(Sender: TObject);
begin
  DoDissection;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.DoDissection : boolean;
var
  pT  : pTransaction_Rec;
begin
  result := false;
  if ( tgTrans.Rows < 1) then exit;  //no transactions in account

  //don't allow dissections if amount is 0
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if pT^.txAmount = 0.00 then
    Exit;

  //finish any edits
  tgTrans.EndEdit( false);
  pfEndPanelEdit( false);
  Result := DissectThisEntry( GetTransactionAtRow( tgTRans.CurrentDataRow));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransKeyPress(Sender: TObject; var Key: Char);
var
   DataCol : integer;
   sValue  : string;
   pT      : pTransaction_Rec;
begin
   if ( tgTrans.Rows < 1) then exit;  //no transactions in account

   if tgTrans.CellEditing then begin
      DataCol := tgTrans.CurrentDataCol;
      case DataCol of
        ccAccount : begin
           if ( Key = '/') and ( not AccountCellChanged) then begin
              //undo change and end edit, then show dissect
              tgTrans.EndEdit( true);
              tgTrans.HideEditor;
              Key := #0;
              DoDissection;
           end;
        end;

        ccPayee : begin
           if ( Key = '/') and ( not PayeeCellChanged) then begin
              //undo change and end edit, then show dissect
              tgTrans.EndEdit( true);
              tgTrans.HideEditor;
              Key := #0;
              DoDissection;
           end;
        end;

        ccJob: begin
          if (Key = '/') and not JobCellChanged then
          begin
            tgTrans.EndEdit(true);
            tgTrans.HideEditor;
            Key := #0;
            DoDissection;
          end;
        end;

        ccGSTAmount : begin
          if (Key = '%') then
          begin
            Key := #0;
            sValue := tgTrans.CurrentCell.Value;
            if (sValue <> '') then
            begin
              pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
              tgTrans.CurrentCell.Value := CalcGSTAmountFromPercentStr( sValue, pT);
              tgTrans.EndEdit( false);
              tgTrans.CurrentDataCol := NextEditableCellRight;
            end;
          end else if (Key = '/') then
          begin
            //undo change and end edit, then show dissect
            tgTrans.EndEdit( true);
            tgTrans.HideEditor;
            Key := #0;
            DoDissection;
          end;
        end;
      else
        begin
          if not (DataCol in [ccNarration, ccNotes]) then
          begin
            if (Key = '/') then begin
              //undo change and end edit, then show dissect
              tgTrans.EndEdit( true);
              tgTrans.HideEditor;
              Key := #0;
              DoDissection;
            end;
          end;
        end;
      end;
   end
   else begin
      //not in edit state
      DataCol := tgTrans.CurrentDataCol;
      case DataCol of
         ccAccount : begin
            //this will only happen if the cell,col is read only
            if ( Key = '/') then begin
               Key := #0;
               DoDissection;
            end;
         end;
      else
        begin
          if not (DataCol in [ccNarration, ccNotes]) then
          begin
            if (Key = '/') then begin
              //undo change and end edit, then show dissect
              tgTrans.EndEdit( true);
              tgTrans.HideEditor;
              Key := #0;
              DoDissection;
            end;
          end;
        end;
      end; //case
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.CalcGSTAmountFromPercentStr(sPercent: string; pT : pTransaction_Rec): string;
//accepts a text string and converts it to a percentage
//returns a text string which is the new amount
var
   mNewAmount : Money;
   InclusiveAmt : Money;
   Percentage: Double;
begin
   Percentage := StrToFloatDef( sPercent, 0);
   //check that the percentage value make sense
   if ( Percentage <= 0.0 ) or ( Percentage > 100.0) then exit;
   //find the new GST Amount
   InclusiveAmt :=  pt^.txAmount;
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
   mNewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));
   //find the rounded money value for the amount
   result := FormatFloat( '0.00', mNewAmount / 100 );
end;//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.JobEdited(NewValue: string; pT: pTransaction_Rec);
var
  Job: TECJob;
  Msg: String;
  NewCode: string[8];
begin
  if NewValue = '' then
  begin
    pT^.txJob_Code := '';
    Exit;
  end;

  //see if they've entered in code or name
  Job := MyClientFile.ecJobs.Job_Search(NewValue);

  if not Assigned(Job) then
  begin
     //need to check if a job already exists with the new job code
     NewCode := NewValue;
     if Assigned(MyClientFile.ecJobs.Find_Job_Code(NewCode)) then
     begin
       WarningMessage('This job already exists');
       Exit;
     end;

     Msg := 'This job does not currently exist.' + #13#10 +
       'Would you like to add ' + NewValue + ' as a new job?';
     if Application.MessageBox(PChar(Msg), 'Add new job',
                           MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES then
     begin
       Job := TECJob.Create;
       Job.jhFields.jhLRN := MyClientFile.ecJobs.Get_New_Job_Number;
       if (Job.jhFields.jhLRN = -1) then
         Job.jhFields.jhLRN := 1;
       Job.jhFields.jhCode := NewValue;
       Job.jhFields.jhHeading := NewValue;
       Job.jhFields.jhAdded_By_ECoding := true;
       MyClientFile.ecJobs.Insert(Job);
       pT^.txJob_Code :=Job.jhFields.jhCode;

       //refresh the combo boxes
       if (tgTrans.CurrentDataCol = ccJob) then
         tgTrans.ResetCombo;
       tgJobLookup.ResetCombo;
     end;
    Exit;
  end;

  if Job.jhFields.jhIsCompleted then
  begin
    WarningMessage('This job is completed and cannot be selected');
    exit;
  end;

  PT^.txJob_Code := Job.jhFields.jhCode;
end;

procedure TfrmMain.PayeeEdited(NewValue: string; pT: pTransaction_Rec);
var
  APayee           : TECPayee;
  isPayeeDissected : boolean;
  i                : integer;
  Dissection       : pDissection_Rec;
  DissectAmt       : PayeeSplitTotals;  //dynamic array
  Msg              : String;
  Value, Code      : Integer;
  PayeeLine        : pPayee_Line_Rec;
begin
   if pT^.txAmount = 0 then begin
      WarningMessage( 'You must assign an amount to this transaction before selecting a payee');
      exit;
   end;

   //value will be the payee name, convert back to payee no for storage
   NewValue := Trim( NewValue);
   if NewValue <> '' then begin
     Val(NewValue, Value, Code);
     if (Code = 0) then
       //try to find payee by code
       APayee := MyClientFile.ecPayees.Find_Payee_Number(Value)
     else
       //try to find payee by name
       APayee := MyClientFile.ecPayees.Find_Payee_Name( NewValue);
     if Assigned(APayee) then
       pT^.txPayee_Number := APayee.pdNumber
     else
     begin
       if (Code <> 0) then
       begin
         //new entry is not numeric
         Msg := 'This payee does not currently exist.' + #13#10 +
           'Would you like to add ' + NewValue + ' as a new payee?';
         if Application.MessageBox(PChar(Msg), 'Add new payee',
                               MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES then
         begin
           aPayee := TECPayee.Create;
           aPayee.pdFields.pdNumber := MyClientFile.ecPayees.Get_New_Payee_Number;
           if (aPayee.pdFields.pdNumber = -1) then
             aPayee.pdFields.pdNumber := 1;
           aPayee.pdFields.pdName := NewValue;
           aPayee.pdFields.pdAdded_By_ECoding := True;
           MyClientFile.ecPayees.Insert(aPayee);
           pT^.txPayee_Number := aPayee.pdNumber;

           //refresh the combo boxes
           if (tgTrans.CurrentDataCol = ccPayee) then
             tgTrans.ResetCombo;
           tgPayeeLookup.ResetCombo;
         end;
       end else
         pT^.txPayee_Number := 0;
     end;
   end
   else begin
      //blank payee entered, see if user is deleting payee
      if pT^.txPayee_Number <> 0 then begin
         //payee has been deleted, clear coding or dissection
         if pT.txFirst_Dissection <> nil then begin
            pT^.txPayee_Number := 0;
            //only change payee if code locked
            if pT^.txCode_Locked then exit;

            ecTransactionListObj.Dump_Dissections( pT);
         end
         else begin
            //clear coding
            pT^.txPayee_Number := 0;
            //only change payee if code locked
            if pT^.txCode_Locked then exit;

            pT^.txAccount      := '';
            pT^.txGST_Class    := 0;
            pT^.txGST_Amount   := 0;
            pT^.txNarration    := pT^.txOld_Narration;
            pT^.txGST_Has_Been_Edited := false;
            pT^.txHas_Been_Edited     := false;
         end;
      end;
      exit;
   end;

  if ( pT^.txPayee_Number = 0) then exit;

  if pT^.txCode_Locked then exit;

  APayee := MyClientFile.ecPayees.Find_Payee_Number(pT^.txPayee_Number);
  //Payee is dissected if more than one line with Account Code
  isPayeeDissected := APayee.IsDissected;
  with pT^, APayee do begin
     //check if can change account/dissection.  If not just change payee no

     //clear any existing dissection
     ecTransactionListObj.Dump_Dissections( pT);

     //code the entry with the details from the payee
     if not (isPayeeDissected) then begin
       if (APayee.pdLines.ItemCount > 0) then
       begin
         //payee is a single line so alter existing transaction
         PayeeLine := APayee.FirstLine;
         txAccount     := PayeeLine.plAccount;
         if PayeeLine.plGL_Narration <> '' then         
           txNarration := PayeeLine.plGL_Narration
         else
           txNarration := txOld_Narration;
         if (PayeeLine.plGST_Has_Been_Edited) then
         begin
            txGST_Class    := PayeeLine.plGST_Class;
            txGST_Amount   := CalculateGSTForClass( MyClientFile, txDate_Effective, txAmount, txGST_Class);
            txGST_Has_Been_Edited := true;
         end
         else
         begin
            //must check to see if a chart is available, if not use the gst class in the payee
            if MyClientFile.ecChart.ItemCount > 0 then
               CalculateGST( MyClientFile, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount)
            else begin
               txGST_Class    := PayeeLine.plGST_Class;  //this will be the same as the default
               txGST_Amount   := CalculateGSTForClass( MyClientFile, txDate_Effective, txAmount, txGST_Class);
            end;
            txGST_Has_Been_Edited := false;
         end;
         txCoded_by := cbManualPayee;
       end
       else
       begin
         //no lines so it's a new payee that has been created. Don't have a narration, so set transaction back
         //to it's old narration
         txNarration := txOld_Narration;
       end;
     end
     else
     begin
        //payee is dissected, so dissect the transaction
        txCoded_by       := cbManualPayee;
        txAccount        := DISSECT_DESC;
        txGST_Class      := 0;
        txGST_Amount     := 0.0;
        txGST_Has_Been_Edited := false;
        //set narration back to the original narration
        //this is needed in case the transaction was set to a non-disected Payee, which changes the narration
        txNarration      := txOld_Narration;

        //split value
        PayeePercentageSplit( txAmount, aPayee, DissectAmt);

        for i := aPayee.pdLines.First to aPayee.pdLines.Last do
        begin
          PayeeLine := aPayee.pdLines.PayeeLine_At(i);
          Dissection := New_Dissection_Rec;
          with Dissection^ do begin
             dsTransaction         := pT;
             dsAccount             := PayeeLine.plAccount;
             dsNarration           := PayeeLine.plGL_Narration;  //APayee.pdName;
             dsQuantity            := 0;
             dsAmount              := DissectAmt[i];
             //calculate GST
             if (PayeeLine.plGST_Has_Been_Edited) then begin
                dsGST_Class    := PayeeLine.plGST_Class;
                dsGST_Amount   := CalculateGSTForClass( MyClientFile, txDate_Effective, dsAmount, dsGST_Class);
                dsGST_Has_Been_Edited := true;
             end
             else begin
                //must check to see if a chart is available, if not use the gst class in the payee
                if MyClientFile.ecChart.ItemCount > 0 then
                   CalculateGST( MyClientFile, txDate_Effective, dsAccount, dsAmount, dsGST_Class, dsGST_Amount)
                else begin
                   dsGST_Class    := PayeeLine.plGST_Class;
                   dsGST_Amount   := CalculateGSTForClass( MyClientFile, txDate_Effective, dsAmount, dsGST_Class);
                end;
                dsGST_Has_Been_Edited := false;
             end;
             dsHas_Been_Edited     := FALSE;
             AppendDissection( pT, Dissection );
          end;
        end;
     end;
  end;  {with payee^}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mruStartClick(Sender: TObject);
var
   caption : string;

begin
   Caption := TMenuItem( Sender).Caption;
   //remove number
   caption := Trim( Copy( caption, 3, length( caption)));

   DoOpenFromMRUList( caption);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoOpenFromMRUList( Filename : string);
begin
   //close existing file
   if Assigned( MyClientFile) then begin
      if not CloseAndSaveCurrentFile(SAVE_AUTOMSG) then
         exit;
   end;
   OpenAndWorkOnFile( FileName, true);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
var
   S : String;
begin
   LockWindowUpdate( Application.Mainform.Handle);

   S := 'An Unexpected exception occured [ Class = ' + E.ClassName + ']'+ #13#13 + E.Message + #13#13;
   Application.MessageBox( PChar(S), APP_NAME + ' Exception', MB_ICONSTOP );

   S := 'CRITICAL ERROR [ Class = ' + E.ClassName + '] Message : '+ E.Message;
   SysLog.ApplicationLog.LogError( S);

   Application.Terminate;  //disable for testing
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
   if Assigned(Myclientfile) then
      if not CloseAndSaveCurrentFile(SAVE_AUTOMSG) then
         Exit; // Canceled

   Close;
end;

procedure TfrmMain.btnCrashClick(Sender: TObject);
begin
   raise Exception.Create( 'Crash Generated');
end;

procedure TfrmMain.BtnHide(Value: TButton);
begin
   Value.Width := 0;
   Value.Enabled := False;
   Value.AlignWithMargins := False;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  SaveCurrentFile;
end;

procedure TfrmMain.BtnShow(Value: TButton);
begin
   Value.Width := btnW;
   Value.Enabled := True;
   Value.AlignWithMargins := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSaveClick(Sender: TObject);
begin
   SaveCurrentFile;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.UpdateMenuItems;
var
   FileIsOpen : boolean;
begin
   FileIsOpen := Assigned(Myclientfile);

   mniClose.Enabled        := FileIsOpen;
   mniSave.Enabled         := FileIsOpen;
   mniSaveAs.Enabled       := FileIsOpen;
   mniSend.Enabled         := FileIsOpen;
   mniAbandon.Enabled      := FileIsOpen;
   mniPassword.Enabled     := FileIsOpen;
   mniCheckForUpdates.Visible := FileIsOpen;
   nUpdates.Visible := FileIsOpen;

   mnsView.Enabled     := FileIsOpen;
   mniPanel.Enabled    := FileIsOpen;
   //mniComments.Enabled := FileIsOpen;

   mnsReports.Enabled      := FileIsOpen;
   {$B-}
   mniReportChart.Visible  := FileIsOpen
                           and (MyClientFile.ecChart.CountBasicItems > 0);
   mniReportPayees.Visible := FileIsOpen
                           and (MyClientFile.ecPayees.ItemCount > 0);
   mniReportJobList.Visible := FileIsOpen
                            and (MyClientFile.ecJobs.NonCompletedJobCount > 0);

   btnSave.Enabled := False;
   btnSend.Enabled := FileIsOpen;

end;
procedure TfrmMain.WindowsCalculator1Click(Sender: TObject);
begin
  inherited;
  ShellExecute(Handle, 'open', 'calc.exe', nil, nil, SW_SHOWNORMAL) ;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSaveAsClick(Sender: TObject);
var
   fname :string;
begin
   if GetNewFilename( fName) then
      SaveCurrentFile( fName);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSendClick(Sender: TObject);
begin
   DoSendFile;
   mniViewEmailLog.Visible := ( INI_MAIL_TYPE = mtSMTP );
   NEmailSep.Visible       := mniViewEmailLog.Visible;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoSendFile;
var
  Subject: string;
begin
  if (tgTrans.CellEditing) then
    tgTrans.EndEdit(False);
  if FileHasChanged( MyClientFile) then begin
     if ( not MyClientFile.ecFields.ecFirst_Save_Done) then begin
        InfoMessage( 'This file must be saved before it can be sent. ' +
                     'Because this is the first time the file has been saved you ' +
                     'will now be prompted for a filename.');
     end;
     if not SaveCurrentFile then exit;
  end;
  Subject := Format('BankLink Notes File for %s (%s to %s)',
                    [MyClientFile.ecFields.ecCode,
                     bkDate2Str(MyClientFile.ecFields.ecDate_Range_From),
                     bkDate2Str(MyClientFile.ecFields.ecDate_Range_To)]);
  SendFrm.SendMail( MyClientFile, Subject); //, imgBackground.Picture.Bitmap);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoAddUPC;
var
   ChqNoFrom : integer;
   ChqNoTo   : integer;
   ChqList   : TChequeList;
   i         : integer;
   NewCheque : pChequeInfo;
   AddCount  : integer;
   Number    : integer;
   Transaction : pTransaction_Rec;
begin
   //get upc range
   if not GetUPCRange( MyClientFile.ActiveBankAccount,
                       MyClientFile.ecFields.ecDate_Range_From,
                       MyClientFile.ecFields.ecDate_Range_To,
                       ChqNoFrom,
                       ChqNoTo) then exit;

   //check to see if any cheques to add
   ChqList := TChequeList.Create;
   try
     //add selected cheques to a cheque list
     for i := ChqNoFrom to ChqNoTo do begin
        NewCheque := NewChequeInfo( i);
        if assigned( NewCheque) then
           ChqList.Insert( NewCheque);
     end;
     //search for matches with existing cheques
     ChequeListObj.FindMatchingCheques( MyClientFile.ActiveBankAccount, ChqList);

      //if not cheque no then inc count
      AddCount := 0;
      for i := 0 to pred(ChqList.ItemCount) do begin
         if ( ChqList.ChequeInfo_At(i)^.psPtr = nil) then begin
            inc(AddCount)      {cheque not found}
          end;
      end;

      if AddCount = 0 then begin
         InfoMessage('There are no cheques to add');
         exit;
      end
      else begin
         if Application.MessageBox( PChar( inttostr( AddCount) + ' cheque(s) will be added to this account.'#13#13 +
                                    'Please confirm that you want to do this.'),
                                    'Add Unpresented Cheques',
                                    MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) <> IDYES then exit;
      end;

      //create new transactions
      for i := pred(ChqList.ItemCount) downto 0 do with ChqList.ChequeInfo_At(i)^ do begin
         number := psNo;
         if ( psPtr = nil) then begin
            //not there at all, so !! ADD !! the missing Cheques}
            Transaction := ECTXIO.New_Transaction_Rec;
            with Transaction^ do begin
               case MyClientFile.ecFields.ecCountry of
                  whNewZealand : txType := 0;
                  whAustralia  : txType := 1;
               end;
               txSource         := orGenerated;
               txDate_Effective := MyClientFile.ecFields.ecDate_Range_To;
               txCheque_Number  := number;
               txReference      := inttostr( number);
               txBank_Seq       := MyClientFile.ActiveBankAccount.baFields.baNumber;
               txUPI_State      := upUPC;
               txUPI_Can_Delete := True;
            end;    // with
            MyClientFile.ActiveBankAccount.baTransaction_List.Insert_Transaction_Rec(Transaction);
         end
      end;
   finally
      ChqList.Free;
   end;
   //reload transaction list position in first upc
   LoadWorkTranList;
   RepositionOnTransaction( Transaction);

   SetFocusSafe( tgTrans);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoAddUPI(upi: Byte);
var
   Transaction : pTransaction_Rec;
   s: string;
begin
   HideCustomHint;
   case upi of
    upUPD: s := 'Deposit'
   else
    s := 'Withdrawal';
   end;
   if Application.MessageBox( PChar('An unpresented ' + Lowercase(s) + ' will be added to this account.'#13#13 +
                              'Please confirm that you want to do this.'),
                              PChar('Add Unpresented ' + s),
                              MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) <> IDYES then
   begin
     ShowHintForCell(tgTrans.CurrentDataRow,tgTrans.CurrentDataCol);
     Exit;
   end;

   //create new transaction
   Transaction := ECTXIO.New_Transaction_Rec;
   with Transaction^ do begin
      if upi = upUPD then
      begin
        case MyClientFile.ecFields.ecCountry of
           whNewZealand : txType := 50;
           whAustralia  : txType := 10;
        end;    // case
      end
      else // upw
      begin
        case MyClientFile.ecFields.ecCountry of
           whNewZealand : txType := 49;
           whAustralia  : txType := 9;
        end;
      end;
      txSource           := orGenerated;
      txDate_Effective   := MyClientFile.ecFields.ecDate_Range_To;
      txBank_Seq         := MyClientFile.ActiveBankAccount.baFields.baNumber;
      txUPI_State        := upi;
      txUPI_Can_Delete   := True;
   end;    // with
   MyClientFile.ActiveBankAccount.baTransaction_List.Insert_Transaction_Rec(Transaction);

   //reload transaction list
   LoadWorkTranList;                         

   SetFocusSafe( tgTrans);   

   RepositionOnTransaction( Transaction);
   tgTrans.CurrentDataCol := ccAmount;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.btnSuperClick(Sender: TObject);
var SuperDlg: TfrmEditSuper;
begin
   SuperDlg := TfrmEditSuper.Create(Self);
   try
      SuperDlg.ClientFile := MyClientFile;
      SuperDlg.Transaction := GetTransactionAtRow(tgTrans.CurrentDataRow);
      SuperDlg.ShowModal;
      tgTrans.Invalidate;
   finally
      SuperDlg.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AmountEdited(NewValue: double; pT: pTransaction_Rec);
var
   OldAmount : Money;
begin
   OldAmount := pT^.txAmount;

   //correct sign for unpresented items
   if pT^.txUPI_State = upUPD then
      NewValue := -1 * Abs( NewValue);

   if pT^.txUPI_State = upUPW then
      NewValue := Abs( NewValue);

   if pT^.txUPI_State = upUPC then
      NewValue := Abs( NewValue);

   pT^.txAmount := Double2money( NewValue);

   if pT^.txFirst_Dissection <> nil then begin
      //entry is dissect, the user must recode the entry in the dissection
      InfoMessage('You must now redisect this transaction');
      if not DissectThisEntry( pT) then begin
        pT^.txAmount := OldAmount;
        WarningMessage('The amount will now be changed back');
      end;
   end
   else begin
      //entry is not dissected so just update amount and GST
      with pT^ do begin
         if MyClientFile.ecChart.CanCodeTo( txAccount) then begin
            //recalculate the gst using the current class.  No need to change the GST has been edited flag
            //because its status will stay the same.
            txGST_Amount   := CalculateGSTForClass( MyClientFile, txDate_Effective,
                                                      txAmount, txGST_Class);
         end
         else begin
            //note: Gst not cleared by an invalid account to allow independant editing of gst
            if ( txAccount = '' ) then begin
               txHas_Been_Edited := false;
            end;

            if txAmount = 0 then begin
               txGST_Amount := 0;
            end;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sValue : String;
  MaskChar : Char;
  pT: pTransaction_Rec;
begin
  KeyIsDown := true;

  if (Key = VK_BACK) then
  begin
    if (tgTrans.CurrentDataCol = ccAccount) then
    begin
      sValue := tgTrans.CurrentCell.Value;
      sValue := Copy(sValue, 1, Length(sValue) - 1);
      if MyClientFile.ecChart.AddMaskCharToCode(sValue,
         MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
      begin
        RemovingMask := True;
        try
          tgTrans.CurrentCell.Value := sValue;
          //move cursor to the last character
          tgTrans.CurrentCell.SelStart := Length(sValue);
        finally
          RemovingMask := False;
        end;
      end;
    end;
  end;

  if tgTrans.CellEditing then exit;

  case Key of
    Ord('D'):
      begin
        if Shift = [ssCtrl] then
          DoDissection;
      end;
    107, 43: // +
      begin
        if tgTrans.EditorActive then exit;
        Key := 0;
        KeyIsCopy := True;
      end;
    vk_insert :
      begin
        if (Shift = [ ssCtrl]) and (not MyClientFile.ecFields.ecRestrict_UPIs) then
        begin
          Key := 0;
          DoAddUPC;
          exit;
        end;
      end;
    vk_delete :
      begin
        if (Shift = [ ssCtrl]) then
        begin
          Key := 0;
          DoDeleteCurrentTransaction;
          exit;
        end;
        if (tgTrans.CurrentDataCol <> ccTaxInv) then begin
          //test if cell is read only

          if ( tgTrans.CellReadOnly[ tgTrans.CurrentDataCol, tgTrans.CurrentDataRow] = roOn) or
             ( tgTrans.Col[ tgTrans.CurrentDataCol].ReadOnly) then exit;

          Key := 0;
          if tgTrans.CurrentDataCol = ccAccount then
          begin
            pT := GetTransactionAtRow( tgTrans.CurrentdataRow);
            if pT.txFirst_Dissection <> nil then
              DoDeleteDissection(pT)
          end;
          tgTrans.ShowEditor;
          tgTrans.CurrentCell.Value := '';
          tgTrans.HideEditor;

          {if (tgTrans.CurrentDataCol = ccGSTAmount) then
          begin
            pT := GetTransactionAtRow(CurrentDataRow);
            if (Assigned(pT) then
              pT^.txGST_Has_Been_Edited := False;
          end;}
        end;
      end;
    VK_F8 :
      begin
        DoGotoNextUncoded;
      end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.RepositionOnTransaction(pT: pTransaction_Rec);
var
   NewIndex     : integer;
   NewDataRow   : integer;
begin
   NewIndex := WorkTranList.IndexOf( pT);
   if NewIndex = -1 then
      NewDataRow := 1
   else
      NewDataRow := NewIndex + 1;

   RepositionOnRow( NewDataRow);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.DoDeleteCurrentTransaction: boolean;
var
   pT : pTransaction_Rec;
   NewDataRow : integer;
begin
   result := false;
   if ( tgTrans.Rows < 1) then exit;  //no transactions in account

   pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
   if not (pT^.txUPI_State in [ upUPC, upUPD, upUPW]) then exit;
   if not pT^.txUPI_Can_Delete then exit;
   
   if pT^.txAmount <> 0 then begin
      if Application.MessageBox( 'Are you sure you want to delete this entry?',
                                 'Delete Entry',
                                 MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) <> IDYES then exit;
   end;

   LockWindowUpdate( Application.Mainform.Handle );
   try
      NewDataRow := tgTrans.CurrentDataRow;

      MyClientFile.ActiveBankAccount.baTransaction_List.DelFreeItem( pT);

      LoadWorkTranList;
      RepositionOnRow( NewDataRow);
      result := true;
   finally
      LockWindowUpdate( 0 );
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.DoGotoNextUncoded;
var
  NextPos : integer;
begin
  if ( WorkTranList.ItemCount > 0 ) then begin
    NextPos := FindUncoded( tgTrans.CurrentDataRow);
    if NextPos < 0 then
      InfoMessage( 'All the entries have been coded')
    else
      tgTrans.CurrentDataRow := NextPos;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Search Transaction list for Uncoded Entries.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = WorkTranList Row + 1
function TfrmMain.FindUncoded( const TheCurrentRow : Integer ) : Integer;

   procedure IncEntry( var Entry : Integer );
   //Increments WorkTranList Entry number in circular fashion
   begin
      Inc( Entry );
      if ( Entry >= WorkTranList.ItemCount ) then
         Entry := 0;
   end;
var
   CurrentEntry : Integer;
   i : Integer;
   FoundUnCoded : boolean;
   pT           : pTransaction_Rec;
begin
   result := -1;
   if ( WorkTranList.ItemCount = 0 ) then Exit;

   CurrentEntry := TheCurrentRow - 1; //Adjust to WorkTranList Entry No

   i := CurrentEntry;
   IncEntry( i );
   repeat
     pT := WorkTranList.Transaction_At( i );
     //check to see if a chart exists
     if MyClientFile.ecChart.CountBasicItems > 0 then
     begin
       foundUnCoded := IsUncoded( pT) and ( pT^.txPayee_Number = 0); //need to allow for blank payee
     end
     else
     begin
       //no chart, check for account, payee or notes
       foundUnCoded := (
                         ( pT^.txAccount = '') and
                         ( pT^.txNotes = '') and
                         ( pT^.txPayee_Number = 0)
                        );
     end;

     if FoundUnCoded then
     begin
       Result := (i + 1); //Adjust to Grid Row No
       Exit;
     end;

     IncEntry( i );
   until ( i = CurrentEntry );

   //if everything else is coded then check current entry also
   if MyClientFile.ecChart.CountBasicItems > 0 then //check to see if a chart exists
     foundUnCoded := IsUncoded( WorkTranList.Transaction_At( i ))
   else
     foundUnCoded := ((WorkTranList.Transaction_At(i).txAccount = '') and
                     (WorkTranList.Transaction_At(i).txNotes = ''));

   if FoundUnCoded then Result := (i + 1);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.RepositionOnRow(NewDataRow: integer);
const
   RowsDown = 4;
begin
   if NewDataRow > tgTrans.Rows then
      NewDataRow := tgTrans.Rows;

   if NewDataRow < 1 then
      NewDataRow := 1;

   tgTrans.CurrentDataRow := NewDataRow;
   if ( NewDataRow > RowsDown) then
      tgTrans.TopRow := NewDataRow - RowsDown
   else begin
      tgTrans.TopRow := 1;
   end;

   //there seems to be a problem scrolling to the last row
   if ( tgTrans.CurrentDataRow = tgTrans.Rows) then begin
      PostMessage( tgTrans.Handle, wm_KeyDown, VK_UP, 0 );
      PostMessage( tgTrans.Handle, wm_KeyDown, VK_DOWN, 0 );
   end;
end;

procedure TfrmMain.pmiAddUPCClick(Sender: TObject);
begin
  if (not MyClientFile.ecFields.ecRestrict_UPIs) then
    DoAddUPC;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pmiAddUPDClick(Sender: TObject);
begin
  if (not MyClientFile.ecFields.ecRestrict_UPIs) then
    DoAddUPI(upUPD);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pmiDissectClick(Sender: TObject);
begin
  //DoDissection;
  rbtDissect.click;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pmiDeleteClick(Sender: TObject);
begin
   DoDeleteCurrentTransaction;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then begin
     MouseRightClickPoint.X := X;
     MouseRightClickPoint.Y := Y;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.GridPopupPopup(Sender: TObject);
var
   CurrRow : integer;
   CurrCol : integer;
   pT      : pTransaction_Rec;
begin
   inherited;
   EditSuperFields1.Visible := (MyClientFile.ecFields.ecSuper_Fund_System > 0);

   if ( tgTrans.Rows < 1) then begin //no transactions in account
      pmiDissect.enabled := false;
      pmiDelete.enabled  := false;
      exit;
   end;

   //get display col,row coordinates
   tgTrans.CellFromXY( MouseRightClickPoint.X, MouseRightClickPoint.Y,
                       CurrCol, CurrRow);
   //get data row
   CurrRow := tgTrans.DataRownr[ CurrRow];
   if not (( CurrRow >= 1) and ( CurrRow <= tgTrans.Rows)) then
      CurrRow := tgTrans.CurrentDataRow;

   pT := GetTransactionAtRow( CurrRow);

   //set row specific options
   pmiDissect.enabled := not(( pT^.txCode_Locked) and ( pT^.txFirst_Dissection = nil));
   pmiDelete.enabled  := ( pT^.txUPI_State in [ upUPC, upUPD, upUPW]);

   EditSuperFields1.Enabled :=  pT^.txFirst_Dissection = nil;
   //clear mouse coordinates
   MouseRightClickPoint.X := 0;
   MouseRightClickPoint.Y := 0;
end;

function TfrmMain.HasPayee: Boolean;
var
  i: Integer;
  p: pTransaction_Rec;
  pD : pDissection_Rec;
begin
   // are there any payees?
   HasPayee := False;
   for i := WorkTranList.First to WorkTranList.Last do
   begin
     p := WorkTranList.Transaction_At(i);
     if p.txPayee_Number <> 0 then
     begin
      HasPayee := True;
      exit;
     end;
     pD := p.txFirst_Dissection;
     while ( pD <> nil) do
     begin
       if pD.dsPayee_Number <> 0 then
       begin
         HasPayee := True;
         exit;
       end;
       pD := pD.dsNext;
     end;
   end;
end;

function TfrmMain.HasQuantity: Boolean;
var
  i: Integer;
  p: pTransaction_Rec;
  pD : pDissection_Rec;
begin
   // are there any quantities?
   HasQuantity := False;
   for i := WorkTranList.First to WorkTranList.Last do
   begin
     p := WorkTranList.Transaction_At(i);
     if p.txQuantity <> 0 then
     begin
      HasQuantity := True;
      exit;
     end;
     pD := p.txFirst_Dissection;
     while ( pD <> nil) do
     begin
       if pD.dsQuantity <> 0 then
       begin
         HasQuantity := True;
         exit;
       end;
       pD := pD.dsNext;
     end;
   end;
end;

procedure TfrmMain.mniReportTransactionsClick(Sender: TObject);
begin
   ecReports.DoTransactionsReport( MyClientFile, TranSortOrder, false, HasPayee, HasQuantity);
end;

procedure TfrmMain.mniReportPayeesClick(Sender: TObject);
begin
   ecReports.DoPayeesReport( MyClientFile);
end;

procedure TfrmMain.mniReportChartClick(Sender: TObject);
begin
   ecReports.DoChartReport( MyClientFile);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniTransWithNotesClick(Sender: TObject);
begin
   ecReports.DoTransactionsReport( MyClientFile, TranSortOrder, true, HasPayee, HasQuantity);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniAbandonClick(Sender: TObject);
begin
   AbandonCurrentFile;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.EndAllEdits( undo : boolean);
begin
   tgTrans.EndEdit( Undo);
   tgTrans.HideEditor;

   pfEndPanelEdit( Undo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.CloseAndSaveCurrentFile(MessageType : Integer) : boolean;
//returns false if the file requires saving and could not be saved
begin
  result := false;

  //finish all edits
  EndAllEdits( false);

  if FileHasChanged( MyClientFile) then begin
    if (not MyClientFile.ecFields.ecFirst_Save_Done) then
      case (MessageType) of
        SAVE_AUTOMSG:
          InfoMessage(AutoSaveMsg+FirstSaveMsg);
        SAVE_BEFOREMSG:
          InfoMessage(SaveBeforeMsg+FirstSaveMsg);
      end;

    if not SaveCurrentFile then
       exit;
  end;
  //close can proceed
  result := true;
  //finish all edits
  CloseActiveBankAccount;
  //delete bank account list
  cmbBankAccounts.Items.Clear;
  //close the file
  Files.CloseFile( MyClientFile);

  if Assigned(frmNotes) then
  begin
    frmNotes.Close;
    FreeAndNil(frmNotes);
  end;

  AppImages.imgLogo.Picture := nil;
  ReloadDesktopScheme;

  //clear app and file names
  lblClientName.Caption := '';
  lblTransactions.Caption := '';
  rbtDissect.Enabled := False;

  Self.Caption          := ecGlobalConst.APP_NAME;
  Application.Title     := ecGlobalConst.APP_NAME;
  UpdateMenuItems;
  BKHelpSetUp(Self, BKH_Chapter_2_BankLink_Notes_basics);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AbandonCurrentFile;
begin
  if FileHasChanged( MyClientFile) then begin
    if Application.MessageBox( 'You will lose any changes you have made to this file. Please '+
                               'confirm you wish to do this.',
                               'Abandon Changes',
                               MB_OKCANCEL + MB_DEFBUTTON2) <> IDOK then exit;
  end;
  //log to file
  ApplicationLog.LogInfo( 'Abandoning changes to ' + MyClientFile.ecFields.ecFilename);
  //finish all edits
  CloseActiveBankAccount;
  //delete bank account list
  cmbBankAccounts.Items.Clear;
  //abandon file
  Files.CloseFile( MyClientFile);

  if Assigned(frmNotes) then
  begin
    frmNotes.Close;
    FreeAndNil(frmNotes);
  end;

  AppImages.imgLogo.Picture := nil;
  ReloadDesktopScheme;

  //clear app and file names
  lblClientName.Caption := '';
  lblTransactions.Caption := '';
  rbtDissect.Enabled := False;

  Self.Caption          := ecGlobalConst.APP_NAME;
  Application.Title     := ecGlobalConst.APP_NAME;
  UpdateMenuItems;
  BKHelpSetUp(Self, BKH_Chapter_2_BankLink_Notes_basics);  
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.SaveCurrentFile : boolean;
var
   fName : string;
begin
   Result := false;

   if (not MyClientFile.ecFields.ecFirst_Save_Done)
   or (MyClientFile.ecFields.ecFile_Opened_Read_Only) then begin
      if not GetNewFilename(fName) then
         exit;
   end else
      fName := MyClientFile.ecFields.ecFilename;

   Result := SaveCurrentFile(fName);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.SaveCurrentFile( Filename: string) : boolean;
begin
   Assert( filename <> '', 'SaveCurrentFile called with blank filename');

   EndAllEdits( false);
   result := Files.SaveFile( Filename, MyClientFile);
   if Result then
      btnSave.Enabled := False;
   INISettings.INI_DefaultFileLocation := ExtractFilePath( Filename);
   INISettings.INI_LastFileOpened := Filename;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.GetNewFilename( var NewFilename : string): boolean;
begin
   result := false;
   //set save dialog filer
   SaveDialog1.Filter := ecGlobalConst.APP_NAME + ' file ( *.' +  ecGlobalConst.Default_File_Extn + ')|'+
                         '*.' + ecGlobalConst.Default_File_Extn  + '|' +
                         'Any file (*.*)|*.*';
   SaveDialog1.DefaultExt :=  ecGlobalConst.Default_File_Extn;

   //set title
   SaveDialog1.Title      := 'Save ' + ecGlobalConst.APP_NAME + ' file...';

   if ( not MyClientFile.ecFields.ecFirst_Save_Done) and
      ( not MyClientFile.ecFields.ecFile_Opened_Read_Only) then
   begin
     SaveDialog1.InitialDir := DefaultDir;
     SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly,ofEnableSizing, ofPathMustExist ]
   end else
   begin
     //set initial dir from ini stored value
     SaveDialog1.InitialDir := INISettings.INI_DefaultFileLocation;
     SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly,ofEnableSizing, ofPathMustExist];
   end;

   SaveDialog1.FileName := ExtractFileName( MyClientFile.ecFields.ecFilename);

   if SaveDialog1.Execute then
   begin
     INISettings.INI_DefaultFileLocation := SaveDialog1.InitialDir;
     NewFilename := SaveDialog1.Filename;
     Result := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoOpenFromCmdLine;
var
  filename : string;
begin
  filename := ParamStr(1);
  OpenAndWorkOnFile( filename, true);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormActivate(Sender: TObject);
var
  IsNow256Color : Boolean;
begin
  if FirstActivateDone then
  begin
    //check to see if the color depth has changed.
    IsNow256Color := (WinUtils.GetScreenColors( Self.Canvas.Handle) <= 256);
    if (IsNow256Color <> Is256Color) then
    begin
      //set the global constant for color depth
      Is256Color := IsNow256Color;
      ecColors.SetDefaultColors(Is256Color);
    end;
    Exit;
  end;

  case INI_mfStatus of
    {1: WindowState := wsNormal; //this is already the default}
    3: WindowState := wsMaximized;
  end;

  try
    if not Assigned(MyClientFile) then
    begin
      //check for command line parameter
      if ParamCount > 0 then
      begin
        DoOpenFromCmdLine;
      end else if (INI_LastFileOpened <> '') then
      begin
        //open last file worked on
        OpenAndWorkOnFile(INI_LastFileOpened, false);
      end;
    end;
  finally
    mnsFile.Enabled := true;
  end;

  FirstActivateDone := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.pnlBackgroundClick(Sender: TObject);
begin
  DoOpenFromDialog;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPasswordClick(Sender: TObject);
var
  pwd : string;
begin
  if EnterNewPassword( pwd) then
    MyClientFile.ecFields.ecFile_Password := Pwd;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniAboutClick(Sender: TObject);
begin
  AboutFrm.ShowAbout(MyClientFile);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniHelpClick(Sender: TObject);
begin
  Application.HelpShowTableOfContents;
end;
procedure TfrmMain.mniReportJobListClick(Sender: TObject);
begin
  ecReports.DoJobsReport(MyClientFile);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransEnter(Sender: TObject);
begin
  //tgTrans.HeadingColor := clBtnFace; //black;
  tgTrans.FocusBorder  := tsGrid.fbDouble;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransExit(Sender: TObject);
begin
  tgTrans.HideEditor;
  HideCustomHint;

  tgTrans.FocusBorder  := tsGrid.fbNone;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    Ord('W'):
        if ( Shift = [ ssCtrl]) and (not MyClientFile.ecFields.ecRestrict_UPIs) then
        begin
          Key := 0;
          rbtAddUPW.Click;
          exit;
        end;
    VK_Insert :
      begin
        if ( Shift = [ ssCtrl]) and (not MyClientFile.ecFields.ecRestrict_UPIs) then
        begin
          Key := 0;
          rbtAddUPC.Click;
          exit;
        end else if ( Shift = [ ssShift]) and (not MyClientFile.ecFields.ecRestrict_UPIs) then
        begin
          Key := 0;
          rbtAddUPD.Click;
          exit;
        end;
      end;
    VK_Return :
      begin
        //allows the enter key to perform a button click
        if (ActiveControl is TButton) then
        begin
          TButton(ActiveControl).Click;
          Key := 0;
        end;
      end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   MousePos : TPoint;
   aCol, aRow : integer;
begin
   if KeyIsDown then
     exit;

   GetCursorPos( MousePos);
   MousePos := tgTrans.ScreenToClient( MousePos);
   tgTrans.CellFromXY( MousePos.x, MousePos.Y, aCol, aRow);
   aCol := tgTrans.DataColnr[ aCol];
   if ( aRow = 0) then
   begin
     if ( aCol in [ ccDateEff, ccAmount, ccAccount, ccNarration, ccReference]) then
        tgTrans.Cursor := crHandPoint;
   end
   else
   begin
      tgTrans.Cursor := crDefault;
      if ( aCol = ccCoded) then
      begin
        //aRow := tgTrans.CurrentDataRow;
        if ( aRow >= 1) and ( aRow <= tgTrans.Rows)  then
        begin
          //test last hint pos to avoid flicker
          if ( aRow <> LastHintRow) or ( aCol <> LastHintCol) then
            ShowHintForCell( aRow, aCol);
        end;
      end
      else
      begin
        aRow := tgTrans.CurrentDataRow;
        aCol := tgTrans.CurrentDataCol;

        if ( aRow <> LastHintRow) or ( aCol <> LastHintCol) then
          ShowHintForCell( aRow, aCol);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.rbtnPrevClick(Sender: TObject);
var
  NewRow : integer;
begin
  //set focus
  if (FocusedControl <> nil) then
  begin
    if (FocusedControl <> rbtnPrev) and (FocusedControl <> rbtnNext) and
       (FocusedControl.Parent = pnlPanel) then
    begin
      //pressing alt+n does not cause the exit/enter events because the
      //focus has not changed. CurrentPanelField <> 0 indicates that we are
      //current in a field
      if CurrentPanelField <> 0 then
        begin
          pfExit(FocusedControl);
          pfEnter(FocusedControl);
        end;
    end;
    SetFocusSafe(FocusedControl);
  end;

  NewRow := ( tgTrans.CurrentDataRow - 1);
  RepositionOnRow( NewRow);
end;

procedure TfrmMain.tgAccountLookupEnter(Sender: TObject);
begin
  inherited;
  tgAccountLookup.AlwaysShowFocus := true;
end;

procedure TfrmMain.tgAccountLookupExit(Sender: TObject);
begin
  inherited;
  tgAccountLookup.AlwaysShowFocus := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransInvalidMaskValue(Sender: TObject; DataCol,
  DataRow: Integer; var Accept: Boolean);
begin
   if DataCol in [ ccAmount, ccGSTAmount, ccQuantity] then begin
      //assume that invalid characters will have been filtered out
      //StrToFloatDef will handle the rest
      Accept := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.rzGSTAmountKeyPress(Sender: TObject; var Key: Char);
var
  pT : pTransaction_Rec;
  NextControl : TWinControl;
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzGSTAmount, 9,2) then
    begin
      Key := #0;
      exit;
    end;
  end;

  if PanelFieldEdited then begin
    //calculate amount based on percentage
    if Key in ['%','/'] then begin
      Key := #0;

      pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
      rzGSTAmount.Text := CalcGSTAmountFromPercentStr( rzGSTAmount.Text, pT);
      NextControl := FindNextControl(TWinControl(Sender), True, True, False);
      NextControl.SetFocus;
    end;
  end
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tgTransColMoved(Sender: TObject; ToDisplayCol,
  Count: Integer; ByUser: Boolean);
var
   i : integer;
begin
  //unselect cols
  if ByUser then begin
    for i := 1 to tgTrans.cols do
      tgTrans.Col[ i].Selected := false;
  end;
end;

procedure TfrmMain.mniViewEmailLogClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar( SentItems.SendLogFilename),nil ,nil, SW_SHOWNORMAL);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TfrmMain.IsCoded( aClient : TEcClient; CONST T : pTransaction_Rec ): Boolean;
Const
  ThisMethodName = 'IsCoded';
Var
  OK    : Boolean;
  DS    : pDissection_Rec;
  Msg : String;
Begin
  If not Assigned( aClient) Then
  Begin
    Msg := 'aClient is NIL';
    //LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
    raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName, Msg]);
  end;

  with aClient, T^ do
  begin
    if txFirst_Dissection<>NIL then
    begin
      OK := TRUE;
      DS := txFirst_Dissection;
      while ( DS<>NIL ) and OK do
        with DS^, aClient.ecFields do
        begin
          OK := aClient.ecChart.CanCodeTo( dsAccount ) or (dsNotes <> '') or ( dsPayee_Number <> 0);
          DS := dsNext;
        end;
    end
    else
      with aClient.ecfields do
      begin
        OK := aClient.ecChart.CanCodeTo( txAccount ) or (txNotes <> '') or ( txPayee_Number <> 0);
      end;
    Result := OK;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.IsCoded( CONST T : pTransaction_Rec ): Boolean;
begin
  //if no client is specified then use the myclient object
  result := IsCoded( MyClientFile, T);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.IsUncoded( CONST T : pTransaction_Rec ): Boolean;
Begin
  //if no client is specified then use the myclient object
  result := Not( IsCoded( T ) );
end;

procedure TfrmMain.chkShowPanelClick(Sender: TObject);
begin
  pnlPanel.Visible := chkShowPanel.Checked;
  mniPanel.Checked := chkShowPanel.Checked;
  if (tgTrans.Cols > 0) and (tgTrans.Rows > 0) then
    tgTrans.PutCellInView(tgTrans.CurrentDataCol,tgTrans.CurrentDataRow);
end;

procedure TfrmMain.lblContactNameClick(Sender: TObject);
var
  Command : String;
begin
  if MyClientFile.ecFields.ecContact_EMail_Address <> '' then
  begin
    Command := 'mailto:' + MyClientFile.ecFields.ecContact_EMail_Address;
    ShellExecute(0, 'open', PChar( Command), nil, nil, SW_NORMAL);
  end;
end;

procedure TfrmMain.lblContactWebSiteClick(Sender: TObject);
begin
  if (lblContactWebSite.Caption <> '') then
    ShellExecute(0, 'open', PChar(lblContactWebSite.Caption), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
  i, Value : Integer;
begin
  HideCustomHint;
  //reposition the background graphic
  lblOpenFile.Width := pnlBackground.Width;
  if imgPicture.Visible then
  begin
    lblOpenFile.Top := imgPicture.Top + imgPicture.Height + 10;
    imgPicture.Left := ((pnlBackground.Width - imgPicture.Width) div 2);
    imgPicture.Top := imgBankLinkB.Top + imgBankLinkB.Height + 10;
  end
  else
    lblOpenFile.Top := imgBankLinkB.Top + imgBankLinkB.Height + 10;

  //hide the contact name if the client name extends into the same area
  if ((lblClientName.Left + lblClientName.Width) > (lblContactName.Left - 8)) then
    lblContactName.Visible := False
  else
    lblContactName.Visible := True;

  if (imgLogo.Visible) then begin
     imgLogo.Left := ClientWidth - imgLogo.Width - 2;
     if lblContactName.Visible then
        lblContactName.Left := imgLogo.Left - lblContactName.Width - 8;
     lblContactNumber.Left := imgLogo.Left - lblContactNumber.Width - 8;
     lblContactWebSite.Left := imgLogo.Left - lblContactWebSite.Width - 8;
  end else begin
     if lblContactName.Visible then
        lblContactName.Left := Self.ClientWidth - lblContactName.Width - 8;
     lblContactNumber.Left := Self.ClientWidth - lblContactNumber.Width - 8;
     lblContactWebSite.Left := Self.ClientWidth - lblContactWebSite.Width - 8;
  end;
  // See what we can do with the cbbank accounts.
  Value := (lblContactWebSite.Left - cmbBankAccounts.Left) -20;

  cmbBankAccounts.Width := Min(Value, 576);
  
  //hide the contact number if the client name extends into the same area
  if ((lblTransactions.Left + lblContactNumber.Width) > (lblContactNumber.Left - 8)) then
    lblContactNumber.Visible := False
  else
    lblContactNumber.Visible := True;

  //hide the show panel checkbox if the Add Unpresented Withdrawal button extends into the same area

     if ((rbtAddUPW.Left + rbtAddUPW.Width) > (chkShowPanel.Left - 8)) then
        chkShowPanel.Visible := False
     else
        chkShowPanel.Visible := True;

  //resize the notes column
  if (tgTrans.Cols = ccNotes) then begin
    Value := 0;
    for i := 1 to tgTrans.Cols - 1 do
      if (i <> ccNotes) and (tgTrans.Col[i].Visible) then
        Value := Value + tgTrans.Col[i].Width;

    //test for minimum size
    if ((tgTrans.Width - Value) <= 64) then
      tgTrans.Col[ccNotes].Width := ccDefaultWidth[ccNotes]
    else
      tgTrans.Col[ccNotes].Width := (tgTrans.ClientWidth - Value);
  end;
end;

procedure TfrmMain.tgTransMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  //don't scroll the main grid if a comobo box is showing
  if (AccountComboDown) or (PayeeComboDown) or JobComboDown then
    Handled := True;

  HideCustomHint;
end;

const
  margin = 4;
  CommentColor = clRed;
procedure TfrmMain.mniCommentsClick(Sender: TObject);
begin
//  if (Assigned(MyClientFile)) then
//    ShowNotes(MyClientFile);
end;

procedure TfrmMain.mniPanelClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked := (not TMenuItem(Sender).Checked);
  chkShowPanel.Checked := TMenuItem(Sender).Checked;
end;

procedure TfrmMain.tgPayeeLookupButtonClick(Sender: TObject; DataCol,
  DataRow: Integer);
var
   pT : pTransaction_Rec;
begin
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if ( pT^.txFirst_Dissection <> nil) then
    if DissectThisEntry( pT) then begin
      PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
    end;
end;

procedure TfrmMain.tgPayeeLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  pT : pTransaction_Rec;
begin
  if ( tgTrans.Rows < 1) then exit;  //no transactions in account

  Value := GetCellData( ccPayee, tgTrans.CurrentDataRow);
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if (pT^.txCode_Locked) or (MyClientFile.ecPayees.ItemCount = 0) then
    tgPayeeLookup.CellButtonType[ 1, 1] := btNone
  //else
  //if pT^.txFirst_Dissection <> nil then begin
  //  tgPayeeLookup.CellButtonType[ 1, 1] := btNormal;
  //end
  else begin
    tgPayeeLookup.CellButtonType[ 1, 1] := btCombo;
    tgPayeeLookup.CellParentCombo[ 1, 1] := False;
  end;
end;

procedure TfrmMain.tgJobLookupCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  pT : pTransaction_Rec;
begin
  if ( tgTrans.Rows < 1) then exit;  //no transactions in account

  Value := GetCellData( ccJob, tgTrans.CurrentDataRow);
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if (pT^.txCode_Locked) or (MyClientFile.ecJobs.NonCompletedJobCount = 0) then
    tgPayeeLookup.CellButtonType[ 1, 1] := btNone
  else begin
    tgPayeeLookup.CellButtonType[ 1, 1] := btCombo;
    tgPayeeLookup.CellParentCombo[ 1, 1] := False;
  end;
end;

procedure TfrmMain.tgJobLookupEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
  pT     : pTransaction_Rec;
begin
  //convert variant to string
  sValue := tgJobLookup.CurrentCell.Value;
  //update the transaction
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  JobEdited( sValue, pT);
  tgTrans.Invalidate;
  ReloadPanel( pT);
end;

procedure TfrmMain.tgPayeeLookupEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
  pT     : pTransaction_Rec;
begin
  //convert variant to string
  sValue := tgPayeeLookup.CurrentCell.Value;
  //update the transaction
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  PayeeEdited( sValue, pT);
  tgTrans.Invalidate;
  ReloadPanel( pT);
end;

procedure TfrmMain.tgPayeeLookupEnter(Sender: TObject);
begin
  inherited;
  tgPayeeLookup.AlwaysShowFocus := true;
end;

procedure TfrmMain.tgJobLookupEnter(Sender: TObject);
begin
  inherited;
  tgJobLookup.AlwaysShowFocus := true;
end;

procedure TfrmMain.tgJobLookupExit(Sender: TObject);
begin
  inherited;
  tgJobLookup.AlwaysShowFocus := false;
end;

procedure TfrmMain.tgPayeeLookupExit(Sender: TObject);
begin
  inherited;
  tgPayeeLookup.AlwaysShowFocus := false;
end;

procedure TfrmMain.tgJobLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if (JobComboDown or tgJobLookup.CellEditing) then exit;

  //dissect entry
  if Key = '/' then
  begin
    Key := #0;
    DoDissection;
  end else if ( Ord( Key ) = vk_Return ) then
  begin
    //interpret return as tab
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end else
    inherited KeyPress( Key );
end;

procedure TfrmMain.tgPayeeLookupKeyPress(Sender: TObject; var Key: Char);
begin
  if (PayeeComboDown or tgPayeeLookup.CellEditing) then exit;

  //dissect entry
  if Key = '/' then
  begin
    Key := #0;
    DoDissection;
  end else if ( Ord( Key ) = vk_Return ) then
  begin
    //interpret return as tab
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end else
    inherited KeyPress( Key );
end;

procedure TfrmMain.tgJobLookupStartCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  pT : pTransaction_Rec;
begin
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if not Assigned( pT) then
  begin
    Cancel := true;
    exit;
  end;
end;

procedure TfrmMain.tgPayeeLookupStartCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  pT : pTransaction_Rec;
begin
  pT := GetTransactionAtRow( tgTrans.CurrentDataRow);
  if not Assigned( pT) then
  begin
    Cancel := true;
    exit;
  end;
end;

procedure TfrmMain.tgTransClickCell(Sender: TObject; DataColDown,
  DataRowDown, DataColUp, DataRowUp: Integer; DownPos,
  UpPos: TtsClickPosition);
var
  CellRect : TRect;
begin
  if ((DataColDown = ccAmount) or (DataColDown = ccAccount)) and (DownPos = cpCell) then
  begin
    //check to see if the mouse has been clicked at the right hand side of the
    //cell so the dissection screen can be displayed.
    if (TTSGrid(Sender).CellButtonType[ DataColDown, DataRowDown] = btNormal) then
    begin
      CellRect := TTSGrid(Sender).CellRect(DataColDown, DataRowDown);
      if (Mouse.CursorPos.X > (Self.Left + pnlLeft.Width + CellRect.Right - 15)) then
        tgTransButtonClick(Sender, DataColDown, DataRowDown);
    end;
  end;
end;

procedure TfrmMain.mniThemeClick(Sender: TObject);
var
  CaptionText : String;
begin
  inherited;
  TMenuItem(Sender).Checked := True;
  CaptionText := RemoveCharsFromString(TMenuItem(Sender).Caption, ['&']);
  if (CaptionText <> INI_Theme) then
  begin
    INI_Theme := CaptionText;
    ecColors.SetDefaultColors(Is256Color);
    if (CaptionText = 'Desert') then
      tgTrans.GridLines := glBoth
    else if (CaptionText = 'Sky') then
      tgTrans.GridLines := glVertLines
    else
      //default
      tgTrans.GridLines := glVertLines;
    ReloadDesktopScheme;
    FormResize(nil);
    tgTransRowChanged(tgTrans, tgTrans.CurrentDataRow, tgTrans.CurrentDataRow);
    tgTrans.invalidate;
  end;
end;

function TfrmMain.GetCodeEntriesHint( const T : pTransaction_Rec) : string ;
//returns a hint message for use in the coding screen
//
//  T = pointer to transaction to generate hint for
//
//  OptionalHintsOn = show the following for a normal transaction
//                         description, upi status, gst amount,
//                         source of transaction, coded by, notes
//
//                    show the following for a dissection
//                         code, description, amount, notes
CONST
   MaxLinesToShow = 20;
var
  D             : pDissection_Rec ;
  A             : pAccount_Rec ;
  No            : Integer ;
  MaxCLen       : Integer ;
  MaxDLen       : Integer ;
  MaxVLen       : Integer ;
  CS            : Bk5CodeStr ;
  DS            : string[ 80 ] ;
  VS            : string[ 15 ] ;
  Commas        : Boolean ;
  HintSL        : TStringList;
begin
  Result    := '' ;
  if not Assigned( T ) then
    exit ;

  HintSL := TStringList.Create;
  Try
    //show coding information
    With T^ do if ( txFirst_Dissection = nil ) then
    begin
      if ( txAccount <> '' ) then
      begin
        if MyClientFile.ecChart.ItemCount > 0 then
        begin
          A := MyClientFile.ecChart.FindCode( txAccount ) ;
          if not Assigned( A ) then
          begin
            HintSL.Add( 'INVALID CODE!' );
          end
          else
          begin
            //show chart code description
            DS := A^.chAccount_Description ;
            HintSL.Add( DS );
          end;
        end;
      end;
      if txSF_Edited then begin
          MaxVLen := Length(TrimSpacesS(Format( '%15.2n', [ Abs( txAmount ) / 100 ] ))) + 1;
          if txSF_Franked <> 0  then
             HintSL.Add( '         Franked ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(txSF_Franked) / 100 ])),MaxVLen));
          if txSF_UnFranked <> 0  then
             HintSL.Add( '       Unfranked ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(txSF_UnFranked) / 100 ])),MaxVLen));
          if txSF_Franking_Credit <> 0  then
             HintSL.Add( 'Franking Credits ' +  LeftPadS(TrimSpacesS(Format('%15.2n', [Abs(txSF_Franking_Credit) / 100 ])),MaxVLen));
      end;
    end
    else
    begin
      //show details for a dissected entry
      MaxCLen := 0 ;
      MaxDLen := 0 ;
      MaxVLen := 8 ;
      Commas := False ;
      D := txFirst_Dissection ;
      while D <> nil do with D^ do
      begin
        A := MyClientFile.ecChart.FindCode( dsAccount ) ;
        if MyClientFile.ecChart.ItemCount > 0 then
        begin
          if Assigned( A ) then
            DS := A^.chAccount_Description
          else
            DS := '<Unknown Code>';
        end
        else
          DS := '';
        if Length( dsAccount ) > MaxCLen then MaxCLen := Length( dsAccount ) ;
        if Length( DS ) > MaxDLen then MaxDLen := Length( DS ) ;
        VS := TrimSpacesS( Format( '%15.2n', [ Abs( dsAmount ) / 100 ] ) ) ;
        if dsAmount < 0 then
        begin
          VS := '(' + VS + ')' ;
          Commas := True ;
        end ;
        if Length( VS ) > MaxVLen then MaxVLen := Length( VS ) ;
        D := dsNext ;
      end ;

      D := txFirst_Dissection ;
      While D <> nil do with D^ do
      begin
        CS := PadS( dsAccount, MaxCLen ) ;
        A := MyClientFile.ecChart.FindCode( dsAccount ) ;

        if MyClientFile.ecChart.ItemCount > 0 then
        begin
          if Assigned( A ) then
            DS := A^.chAccount_Description
          else
            DS := '<Unknown Code>';
        end
        else
          DS := '';

        DS := PadS( DS, MaxDLen ) ;
        VS := TrimSpacesS( Format( '%15.2n', [ Abs( dsAmount ) / 100 ] ) ) ;
        if dsAmount < 0 then
          VS := '(' + VS + ')'
        else
          if Commas then VS := VS + ' ' ;
        VS := LeftPadS( VS, MaxVLen ) ;
        HintSL.Add( CS + ' ' + DS + ' ' + VS );
        D := D.dsNext ;
      end;

    end;

    //see if hint is too long
    if HintSL.Count > MaxLinesToShow then
    begin
      For No := Pred( HintSL.Count ) downto MaxLinesToShow do HintSL.Delete( No );
      HintSL.Add( '... more lines ...' );
    end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;

    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end ;

procedure TfrmMain.HideCustomHint;
var
  R : TRect;
begin
  if Assigned( FHint ) then begin
    if FHint.HandleAllocated then
    begin
      //find where the Hint is, so we can redraw the cells beneath it.
      GetWindowRect( FHint.Handle, R );
      R.TopLeft      := tgTrans.ScreenToClient(R.TopLeft);
      R.BottomRight  := tgTrans.ScreenToClient(R.BottomRight);
      FHint.ReleaseHandle;
      FHintShowing   := False;
      tmrHideHint.Enabled := false;
    end;
  end;
end;

procedure TfrmMain.ShowHintForCell(const RowNum, ColNum: integer);
var
  pT  : pTransaction_Rec;
  HR, CR : TRect;
  MP     : TPoint;
  Msg : String;
  pJob: TECJob;
begin
  if DisableHints then
    Exit;

  if not PtInRect( pnlCoding.BoundsRect, Self.ScreenToClient( Mouse.CursorPos ) ) then
  begin
    HideCustomHint;
    Exit;
  end;

  //anything to display?
  if (tgTrans.Rows < 1) then
    Exit;

  pT := GetTransactionAtRow(RowNum);

  Msg := '';
  if Assigned( pT) then
  begin
    tmrHideHint.Enabled := false;

    case ColNum of
      ccAccount,ccAmount : begin
        if tgTrans.Col[ccAccount].Visible then
        begin
          Msg := GetCodeEntriesHint( pT);
          if pT^.txCode_Locked then
            if Msg <> '' then
              Msg := 'Coded by Accountant:'#13 + Msg
            else
              Msg := 'Coded by Accountant';
        end;
      end;

      ccPayee : begin
        if tgTrans.Col[ccPayee].Visible then
        begin
          if pT^.txCode_Locked then
            Msg := 'Coded by Accountant';
        end;
      end;

      ccJob:
        begin
          if tgTrans.Col[ccJob].Visible then
          begin
            if pT^.txJob_Code <> '' then
            begin
              pJob := MyClientFile.ecJobs.Find_Job_Code(pT^.txJob_Code);
              if Assigned(pJob) then
                Msg := pJob.jhFields.jhHeading;
            end;
          end;
        end;

      ccCoded : begin
        if pT^.txCode_Locked then  begin
           Msg := 'Coded by Accountant';
           if pt^.txSF_Edited or SuperfundDissection(PT) then
             MSG := MSG + #13'And Superfund details added'
        end else
          if pt^.txSF_Edited or SuperfundDissection(PT) then
             MSG := MSG + 'Superfund details added'
      end;
    end;

    CR := tgTrans.CellRect(ColNum, RowNum);

    //see if there is a message to display
    if (Msg <> '') and not (( CR.Top = 0) and ( CR.Left = 0)) then
    begin
      //set description label
      HR := FHint.CalcHintRect( Screen.Width, Msg, NIL );
      Inc( HR.Bottom, 2 );
      Inc( HR.Right, 6 );
      MP.X := CR.Right;
      MP.Y := CR.Bottom;
      MP := tgTrans.ClientToScreen(MP);
      OffsetRect( HR, MP.X, MP.Y);

      //now show hint
      if Msg = 'INVALID CODE!' then
         FHint.Color := clRed
      else
         FHint.Color := Application.HintColor;

      FHint.ActivateHint(HR, Msg);
      FHintShowing := true;

      tmrHideHint.Enabled := true;
    end
    else
    begin
      HideCustomHint;
    end;
  end;

  LastHintRow := RowNum;
  LastHintCol := ColNum;
end;

function TfrmMain.SuperfundDissection(pT: pTransaction_Rec): Boolean;
   var pD : pDissection_Rec;
   begin
      Result := True; //Assume success
      pD := pT.txFirst_Dissection;
      while assigned(pD) do begin
         if pD.dsSF_Edited then
            Exit; // Found one
         pD := pD.dsNext;
      end;
      Result := False;//Nothing found..
   end;

procedure TfrmMain.FormDeactivate(Sender: TObject);
begin
  HideCustomHint;
end;

procedure TfrmMain.CMMouseLeave(var Message: TMessage);
begin
  HideCustomHint;
end;

procedure TfrmMain.Copy1Click(Sender: TObject);
begin
  inherited;
  keybd_event( 17, 1, 0, 0 );   // Ctrl key down
  keybd_event( 67, 1, 0, 0 );   // C key
  keybd_event( 17, 1, 2, 0 );   // Ctrl key up
end;

procedure TfrmMain.Copycontentsofthecellabove1Click(Sender: TObject);
var
  pT, pPrev: pTransaction_Rec;
  Copied: Boolean;
begin
  Copied := False;
  if tgTrans.CurrentDataRow > 1 then
  begin
    pT := GetTransactionAtRow( tgTrans.CurrentdataRow);
    pPrev := GetTransactionAtRow( tgTrans.CurrentdataRow - 1);
    if Assigned(pT) and (pT.txLocked or pT.txCode_Locked) and (tgTrans.CurrentDataCol <> ccNotes) then exit;
    case tgTrans.CurrentDataCol of
      ccAccount:
        begin
          if (not Assigned(pPrev.txFirst_Dissection)) and (tgTrans.CurrentCell.Value = '') then
          begin
            Copied := True;
            AccountEdited(pPrev.txAccount, pT);
          end;
        end;
      ccAmount:
        begin
          if tgTrans.CurrentCell.Value = 0 then
          begin
            Copied := True;
            AmountEdited(Money2Double(pPrev.txAmount), pT);
          end;
        end;
      ccGSTAmount:
        begin
          try
            if (not Assigned(pPrev.txFirst_Dissection)) and (tgTrans.CurrentCell.Value = '') then
            begin
              Copied := True;
              pT.txGST_Amount := pPrev.txGST_Amount;
            end;
          except
          end;
        end;
      ccTaxInv:
        begin
          Copied := True;
          pT.txTax_Invoice_Available := pPrev.txTax_Invoice_Available;
        end;
      ccQuantity:
        begin
          if tgTrans.CurrentCell.Value = 0 then
          begin
            Copied := True;
            pT.txQuantity := pPrev.txQuantity;
          end;
        end;
      ccPayee:
        begin
          if tgTrans.CurrentCell.Value = '' then
          begin
            Copied := True;
            PayeeEdited(tgTrans.Cell[tgTrans.CurrentDataCol, tgTrans.CurrentDataRow-1], pT);
          end;
        end;
      ccJob:
        begin
          if tgTrans.CurrentCell.Value = '' then
          begin
            Copied := true;
            JobEdited(tgTrans.Cell[tgTrans.CurrentDataCol, tgTrans.CurrentDataRow - 1], pT);
          end;
        end;
      ccNotes:
        begin
          if tgTrans.CurrentCell.Value = '' then
          begin
            Copied := True;
            pT.txNotes := pPrev.txNotes;
          end;
        end;
    end;
    if Copied then
    begin
      tgTrans.Invalidate;
      keybd_event(vk_right, 1 ,0 ,0);
    end;
  end;
end;

procedure TfrmMain.Paste1Click(Sender: TObject);
begin
  inherited;
  keybd_event( 17, 1, 0, 0 );   // Ctrl key down
  keybd_event( 86, 1, 0, 0 );   // V key
  keybd_event( 17, 1, 2, 0 );   // Ctrl key up
end;

procedure TfrmMain.CMMouseEnter(var Message: TMessage);
var
  pt: TPoint;
begin
  if GetActiveWindow <> Self.Handle then
    Exit;

  if FHintShowing then
    Exit;

  try
    if tgTrans.Visible and GetCursorPos(pt) then
    begin
      pt := pnlCoding.ScreenToClient(pt);
      if (pt.X > tgTrans.Left) and (pt.X <= (tgTrans.Left + tgTrans.Width)) and
         (pt.Y > tgTrans.Top) and (pt.Y <= (tgTrans.Top + tgTrans.Height)) then
          ShowHintForCell(tgTrans.CurrentDataRow,tgTrans.CurrentDataCol);
    end;
  except
  end;
end;

procedure TfrmMain.ApplicationEvents1Deactivate(Sender: TObject);
begin
  //hide the hint when we swap to another window or application
  if GetActiveWindow <> Self.Handle then
    Exit;

  HideCustomHint;
end;

procedure TfrmMain.rzQuantityKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzQuantity, 8, 4) then
    begin
      Key := #0;
      exit;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.NumberIsValid( aControl : TCustomEdit; const LeftDigits, RightDigits: integer): boolean;
//make sure the user can't key in incorrect number of digits
var
  StrippedNumber : string;
  CurrLeftDigits : integer;
  CurrRightDigits: integer;
  dpPos          : integer;
  RawLength      : integer;
  StrippedLength : integer;
  CurrPos        : integer;
begin
  Result := true;

  RawLength := Length( aControl.Text);
  if ( RawLength = 0) or ( aControl.SelLength = RawLength) then
    exit;

  StrippedNumber := RemoveCharsFromString( aControl.Text, ['(',')','-', ',']);
  StrippedLength := Length( StrippedNumber);

  DpPos := Pos( '.', StrippedNumber);
  if DpPos = 0 then
  begin
    CurrLeftDigits  := StrippedLength;
    CurrRightDigits := 0;
  end
  else
  begin
    CurrLeftDigits  := DpPos - 1;
    CurrRightDigits := StrippedLength - DpPos;
  end;

  //whether we accept another key depends on where the cursor is sitting
  CurrPos := aControl.SelStart;
  if ( DpPos = 0) or (CurrPos < DpPos) then
  begin
    //we are to the left of the dp
    result := ( CurrLeftDigits < LeftDigits);
  end
  else
  begin
    //we are to the right of the dp
    result := ( CurrRightDigits < RightDigits);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.rzAmountKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key >= '0') and ( Key <= '9') then
  begin
    if not NumberIsValid( rzAmount, 9, 2) then
    begin
      Key := #0;
      exit;
    end;
  end;
end;

procedure TfrmMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  HideCustomHint;
end;

procedure TfrmMain.tgTransKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyIsDown := false;
  if KeyIsCopy then
  begin
    KeyIsCopy := False;
    tgTrans.EndEdit(True);
    Copycontentsofthecellabove1Click(Sender);
  end;
end;

procedure TfrmMain.tmrHideHintTimer(Sender: TObject);
begin
  HideCustomHint;
end;

procedure TfrmMain.tgAccountLookupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sValue : String;
  MaskChar : Char;
begin
  if (Key = VK_BACK) then
  begin
    sValue := tgAccountLookup.CurrentCell.Value;
    sValue := Copy(sValue, 1, Length(sValue) - 1);
    if MyClientFile.ecChart.AddMaskCharToCode(sValue,
       MyClientFile.ecFields.ecAccount_Code_Mask, MaskChar) Then
    begin
      RemovingMask := True;
      try
        tgAccountLookup.CurrentCell.Value := sValue;
        //move cursor to the last character
        tgAccountLookup.CurrentCell.SelStart := Length(sValue);
      finally
        RemovingMask := False;
      end;
    end;
  end;
end;

procedure TfrmMain.rbtAddUPWClick(Sender: TObject);
begin
  DoAddUPI(upUPW);
end;

procedure TfrmMain.pmiAddUPWClick(Sender: TObject);
begin
  if (not MyClientFile.ecFields.ecRestrict_UPIs) then
    DoAddUPI(upUPW);
end;

procedure TfrmMain.mniCheckForUpdatesClick(Sender: TObject);
begin
  if ecUpgradeHelper.CheckForUpgrade_BNotes( '', MyClientFile.ecFields.ecCountry, Self.Handle) = upShutdown then
    Close;
end;

procedure TfrmMain.DoDeleteDissection( pT : pTransaction_Rec);
//allows the user to delete all lines from a dissection without using the
//dissect dlg
begin
   if pT^.txLocked or pT.txCode_Locked then
      Exit;

   if Application.MessageBox('Do you want to remove all of the dissection lines for this entry?', 'Remove Dissection',
                               MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDNO then
     Exit;

   //dispose of all dissection lines
   Dump_Dissections( pT);
   //clear transaction details
   pT^.txCoded_By        := cbNotcoded;
   pT^.txGST_Class       := 0;
   pT^.txGST_Amount      := 0;
   pT^.txHas_Been_Edited := False;
   pT^.txGST_Has_Been_Edited := False;
   tgTrans.CellButtonType[ tgTrans.CurrentDataCol, tgTrans.CurrentDataRow] := btNone;
end;

procedure TfrmMain.Dump_Dissections(var p : pTransaction_Rec);
Var
   This : pDissection_Rec;
   Next : pDissection_Rec;
Begin
   if ( ECTXIO.IsATransaction_Rec( P ) )  then With P^ do
   Begin
      This := pDissection_Rec( txFirst_Dissection );
      While ( This<>NIL ) do
      Begin
         Next := pDissection_Rec( This^.dsNext );
         Dispose_Dissection_Rec( This );
         This := Next;
      end;
      P^.txFirst_Dissection := NIL;
      P^.txLast_Dissection := NIL;
      P^.txAccount := '';
   end;
end;

procedure TfrmMain.Dispose_Dissection_Rec(p : PDissection_Rec);
begin
   If (ECDSIO.IsADissection_Rec( P ) )  then begin
      ECDSIO.Free_Dissection_Rec_Dynamic_Fields( p^);
      MALLOC.SafeFreeMem( P, Dissection_Rec_Size );
   end;
end;

end.
