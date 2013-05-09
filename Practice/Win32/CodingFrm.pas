unit CodingFrm;

{.$DEFINE PLAYSOUNDS} // Uncomment this to include the sound code.

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcTCmmn, OvcTable, OvcTCHdr, OvcTCPic, OvcTCBEF, OvcTCNum,
  OvcTCStr, OvcTCEdt, OvcTCell, OvcTCBmp, ComCtrls, ExtCtrls, StdCtrls, Inifiles,

  baObj32,
  bkDefs,
  CodingFormCommands,
  MaintainGroupsFrm, ovctcgly, ovctcbox, StdActns, ActnList, Menus, RzPanel,
  RzBmpBtn, RzSplit, ovcef, ovcpb, ovcpf,ovcDate,
  txsl,
  ueList32,
  ColFmtListObj,

  jpeg, ExtDlgs, ovctccbx,osfont, RzButton;

const
   WM_DoNewJournal = WM_User + 601;
type
   TCodingCommands = (CC_RestrictedEditMode, CC_FullEditMode, CC_GotoFirstUncoded);
   TCodingOptions = set of TCodingCommands;

  TfrmCoding = class(TForm)
    barCodingStatus: TStatusBar;
    cntController: TOvcController;
    celStatus: TOvcTCBitMap;
    celDate: TOvcTCString;
    celRef: TOvcTCString;
    celAnalysis: TOvcTCString;
    celAmount: TOvcTCString;
    celEntryType: TOvcTCString;
    celBSDate: TOvcTCString;
    celCoded: TOvcTCString;
    celPayee: TOvcTCNumericField;
    celGstAmt: TOvcTCNumericField;
    celQuantity: TOvcTCNumericField;
    celPart: TOvcTCString;
    celNarration: TOvcTCString;
    celOther: TOvcTCString;
    celAccount: TOvcTCString;
    hdrColumnHeadings: TOvcTCColHead;
    tblCoding: TOvcTable;
    popGST: TPopupMenu;
    mniRecalcGST: TMenuItem;
    popTransfer: TPopupMenu;
    mniSetTransferFlags: TMenuItem;
    mniClearTransferFlags: TMenuItem;
    popCoding: TPopupMenu;
    celGSTCode: TOvcTCString;
    pfHiddenAmount: TOvcPictureField;
    RzSizePanel1: TRzSizePanel;
    pnlNotes: TPanel;
    Panel2: TPanel;
    memImportNotes: TMemo;
    memNotes: TMemo;
    pnlNotesTitle: TPanel;
    rzPinBtn: TRzBmpButton;
    rzXBtn: TRzBmpButton;
    popNotes: TPopupMenu;
    pmiNotesVisible: TMenuItem;
    N100: TMenuItem;
    pmiGotoGrid: TMenuItem;
    ActionList1: TActionList;
    pmiNotesUndo: TMenuItem;
    pmiNotesCut: TMenuItem;
    pmiNotesCopy: TMenuItem;
    pmiNotesPaste: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    pmiNotesSelectAll: TMenuItem;
    N3: TMenuItem;
    mniReset: TMenuItem;
    celStatementDetails: TOvcTCString;
    celTaxInv: TOvcTCCheckBox;
    celBalance: TOvcTCString;
    dlgSaveCLS: TSaveDialog;
    dlgLoadCLS: TOpenDialog;
    celDescription: TOvcTCString;
    popReference: TPopupMenu;
    SortbyReference1: TMenuItem;
    SortbyChequeNumber1: TMenuItem;
    celPayeeName: TOvcTCString;
    celDocument: TOvcTCString;
    celEditDate: TOvcTCPictureField;
    pnlExtraTitleBar: TRzPanel;
    lblAcctDetails: TLabel;
    lblTransRange: TLabel;
    lblFinalised: TLabel;
    imgRight: TImage;
    tmrPayee: TTimer;
    CelJob: TOvcTCString;
    CelJobName: TOvcTCString;
    CelAction: TOvcTCString;
    celForexAmount: TOvcTCString;
    celForexRate: TOvcTCNumericField;
    celLocalCurrencyAmount: TOvcTCNumericField;
    pnlSearch: TPanel;
    EBFind: TEdit;
    Label1: TLabel;
    btnFind: TButton;
    SearchTimer: TTimer;
    lblCount: TLabel;
    CelAltCode: TOvcTCString;
    popFind: TPopupMenu;
    miFind: TMenuItem;
    miSearch: TMenuItem;
    tbtnClose: TRzToolButton;
    celTransferedToOnline: TOvcTCCheckBox;
    celCoreTransactionId: TOvcTCString;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure WMMDIActivate(var Msg: TWMMDIActivate); message WM_MDIACTIVATE;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;

    procedure WMVScroll(var Msg : TWMScroll); message WM_VSCROLL;

    procedure WMDoNewJournal (var message: TMessage); message WM_DoNewJournal;
    procedure hdrColumnHeadingsClick(Sender: TObject);
    procedure tblCodingGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblCodingColumnsChanged(Sender: TObject; ColNum1,
      ColNum2: Integer; Action: TOvcTblActions);
    procedure tblCodingEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblCodingDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblCodingBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblCodingGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblCodingActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblCodingEnteringRow(Sender: TObject; RowNum: Integer);
    procedure FormResize(Sender: TObject);
    procedure barCodingStatusMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tblCodingUserCommand(Sender: TObject; Command: Word);
    procedure tblCodingActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure celAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountKeyPress(Sender: TObject; var Key: Char);
    procedure tblCodingLockedCellClick(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblCodingMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mniRecalcGSTClick(Sender: TObject);
    procedure mniSetTransferFlagsClick(Sender: TObject);
    procedure mniClearTransferFlagsClick(Sender: TObject);
    procedure tblCodingMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DissectionClick(Sender: TObject);
    procedure SuperClick(Sender: TObject);
    procedure FTClick(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure ColConfigureClick(Sender: TObject);
    procedure ColRestoreClick(Sender: TObject);
    procedure ZoomClick( Sender: TObject );
    procedure GotoNextClick(Sender: TObject);
    procedure GotoNextNoteClick(Sender: TObject);
    procedure AccountLookupClick(Sender: TObject);
    procedure PayeeLookupClick(Sender: TObject);
    procedure JobLookupClick(Sender: TObject);
    procedure GSTLookupClick(Sender: TObject);
    procedure MemoriseClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure SaveFileClick(Sender: TObject);
    procedure ToggleModeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tblCodingTopLeftCellChanging(Sender: TObject; var RowNum,
      ColNum: Integer);
    procedure tblCodingVSThumbChanged( Sender: TObject; RowNum : TRowNum );
    procedure BkMouseWheelHandler(Sender: TObject; Shift: TShiftState; Delta, XPos, YPos: Word);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure celAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure celGstAmtKeyPress(Sender: TObject; var Key: Char);
    procedure celGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celQuantityChange(Sender: TObject);
    procedure celGstAmtChange(Sender: TObject);
    procedure celRefOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure barCodingStatusClick(Sender: TObject);
    procedure memNotesExit(Sender: TObject);
    procedure memNotesChange(Sender: TObject);
    procedure pnlNotesEnter(Sender: TObject);
    procedure pnlNotesExit(Sender: TObject);
    procedure rzXBtnClick(Sender: TObject);
    procedure rzPinBtnClick(Sender: TObject);
    procedure pmiNotesVisibleClick(Sender: TObject);
    procedure pmiGotoGridClick(Sender: TObject);
    procedure pmiGridGotoNotes(Sender: TObject);
    procedure pmiDoDitto(Sender: TObject);
    procedure pmiDoCopySDToNarration(Sender: TObject);
    procedure pmiDoAppendSDToNarration(Sender: TObject);
    procedure pmiDoCopyNotesToNarration(Sender: TObject);
    procedure pmiDoAppendNotesToNarration(Sender: TObject);
    procedure pmiDoDeleteNote(Sender: TObject);
    procedure pmiDoNewAmount(Sender: TObject);
    procedure pmiDoMarkNote(Sender: TObject);
    procedure pmiDoMarkAllNotes(Sender: TObject);

    procedure tblCodingEnter(Sender: TObject);
    procedure tblCodingExit(Sender: TObject);
    procedure tblCodingDblClick(Sender: TObject);
    procedure RzSizePanel1Resize(Sender: TObject);
    procedure mniResetClick(Sender: TObject);
    procedure celPayeeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celBalanceOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure tblCodingTopLeftCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure celPayeeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celGSTCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SortbyChequeNumber1Click(Sender: TObject);
    procedure SortbyReference1Click(Sender: TObject);
    procedure celAmountExit(Sender: TObject);
    procedure celQuantityExit(Sender: TObject);
    procedure tblCodingMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celPayeeNameOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure tblCodingKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure memImportNotesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountExit(Sender: TObject);
    procedure celDocumentOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure tblCodingKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celTaxInvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celTaxInvKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrPayeeTimer(Sender: TObject);
    procedure CelJobKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CelJobOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure popCodingPopup(Sender: TObject);
    procedure celEditDateOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure celForexAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure celLocalCurrencyAmountOwnerDraw(Sender: TObject;
      TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure celLocalCurrencyAmountChange(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure EBFindKeyPress(Sender: TObject; var Key: Char);
    procedure btnFindClick(Sender: TObject);
    procedure EBFindChange(Sender: TObject);
    procedure miFindClick(Sender: TObject);
    procedure miSearchClick(Sender: TObject);
    procedure tbtnCloseClick(Sender: TObject);
    procedure tblCodingKeyPress(Sender: TObject; var Key: Char);
    procedure ConvertVATAmount(Sender: TObject);
    procedure celAnalysisChange(Sender: TObject);

  private
    { Private declarations }
    Temp_Column_Order             : Array[ 0..32 ] of Byte;
    Temp_Column_Width             : Array[ 0..32 ] of Integer;
    Temp_Column_is_Hidden         : Array[ 0..32 ] of Boolean;
    Temp_Column_Is_Not_Editable   : Array[ 0..32 ] of Boolean;
    FHint                         : THintWindow;
    HintShowing                   : boolean;
    BankAccount                   : TBank_Account;
    BankPrefix                    : string[2];
    TranDateFrom                  : TStDate;
    TranDateTo                    : TStDate;
    WorkTranList                  : TSorted_Transaction_List;
    UEList                        : tUEList;
    ColumnFmtList                 : TColFmtList;
    EditAcctColOnly               : boolean;
    ShowAllTran                   : Byte;
    RemovingMask                  : boolean;
    TranSortOrder                 : integer;
    AutoPressMinus                : boolean;  //used by quantity
    MouseDownInAmountCol          : boolean;

    clStdLineLight                : integer;
    clStdLineDark                 : integer;

    Zoomed                        : Boolean;

    DefaultEditColumn             : Integer;
    DefaultEditableCols           : set of byte;
    NeverEditableCols             : set of byte;

    //temporary variables for data pointer to point to, used in GetCellData
    tmpShortStr                   : ShortString;
    tmpDouble                     : double;
    tmpInteger                    : Integer;
    tmpBool                       : Boolean;
    tmpBuffer                     : Array of Char;

    //temporary variables for data pointer to point to, used in ReadCellForPaint

    tmpPaintString                : String;
    tmpPaintShortStr              : ShortString;
    tmpPaintDouble                : double;
    tmpPaintInteger               : Integer;

    FIsClosing, FIsReloading, StartFocus, Undo: boolean;
    FsuperTop, FSuperLeft: Integer;
    tmpJob: shortString;
    tmpPayee,
    tmpDate,
    TmrRow: Integer;

    FCountry : Byte;
    FIsForex : Boolean;
    FSearchText: string;

    procedure SetUpHelp;
    procedure LoadWorkTranList;
    procedure InitController;
    procedure SetColDefPosition(aBankPrefix : string);
    procedure SetupColumnFmtList(var ColFmt: TColFmtList);
    procedure BuildTableColumns;

    procedure LoadLayoutForThisAcct;
    procedure SaveLayoutForThisAcct;
    procedure LoadTempLayoutForThisAcct;
    procedure SaveTempLayoutForThisAcct;
    procedure SetupColDefaultSets;

    function  ValidDataRow(RowNum: integer): boolean;
    procedure SetTableAccess;
    procedure ReadCellForPaint(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellForEdit(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
    procedure LoadWTLMaintainPos;
    procedure LoadWTLNewSort( NewSortOrder : integer; AlwaysSet: Boolean = False; ForceSort: Boolean = False);
    function RepositionOn(pT : pTransaction_Rec): Boolean;

    procedure AccountEdited(pT: pTransaction_Rec);
    procedure GSTClassEdited(pT : pTransaction_Rec);
    function  PayeeEdited(pT : pTransaction_Rec): Boolean;
    function  JobEdited(pT : pTransaction_Rec): Boolean;
    procedure SetTranUPCStatus(pT : pTransaction_Rec);
    procedure SetSortOrder( NewSortOrder : integer; AlwaysSet: Boolean = False );

    procedure UpdateCodedCount;
    procedure SetEditAllCol;
    procedure ClearEditAllCol;
    procedure ToggleColEditMode;
    procedure ClearShowUncodedOnly;
    procedure SetShowUncodedOnly;
    procedure SetShowUnReadNotesOnly;
    procedure SetShowNotesOnly;
    procedure SetShowNoNotesOnly;
    procedure DoAccountLookup;
    procedure DoPayeeLookup;
//    procedure DoRateLookup;
    procedure DoGSTLookup;
    procedure DoDissection(JA: Integer = -1);
    procedure DoMemorise;
    procedure DoEditSuperFields;
    procedure DoFind(Find: Boolean = False);
    procedure DoMatchUPC;
    procedure DoClearTransferDate;
    procedure DoSetTransferDate;
    procedure SetOrClearTransferDate(SetDate: boolean);
    procedure DoDitto;
    procedure DoAddOutstandingCheques;
    procedure DoAddOutstandingDeposits;
    procedure DoAddOutstandingWithdrawals;
    procedure DoAddInitialCheques;
    procedure DoAddInitialDeposits;
    procedure DoAddInitialWithdrawals;
    procedure DoRecalculateGST;
    procedure DoNewAmount;
    procedure DoDeleteTrans;
    procedure DoDeleteCell;
    procedure DoLookupJob;
    procedure DoGotoNextUncoded(Silent: Boolean = False; IncludeCurrent: Boolean = False);
    procedure DoGotoNextNote;
    procedure DoCopySDToNarration( Append: boolean);
    procedure DoCopyNotesToNarration( Append : boolean);
    procedure DoDeleteNote;
    procedure DoMarkNote;
    procedure DoMarkAllNotes;
    procedure DoReCodeEntries;
    function  FindUncoded(const TheCurrentRow: Integer; IncludeCurrent: Boolean = False): Integer;
    function  FindNote(const TheCurrentRow: Integer): Integer;
    procedure CreateCodingPopup(Journal: Boolean);
    procedure HideCustomHint;
    procedure ShowCodingHint( Const RowNum, ColNum : Integer; HintMsg : String );
//    function  GetHintPosition( Const RowNum, ColNum : Integer ): TPoint;
    procedure DoReloadEntries;
    procedure DoRecombineEntries;
    procedure DoGotoNotes;
    procedure DoNewJournal(Sender: Tobject = nil);
    function  ValidCheque(Num: string; This : pTransaction_Rec; var msg: string ): boolean;
{$IFDEF SmartLink}
    procedure DoLaunchFingertips;
{$ENDIF}
    procedure ConfigureColumns;
    procedure RestoreColumnDefaults;
    procedure UpdateStatusForActiveRow(RowNum: integer);
    procedure DoZoom;
    Procedure WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;

    procedure UpdateNotesPanel(RowNum: integer);
    procedure ToggleAlwaysShowNotes;
    procedure UpdatePopups;

    procedure DoGotoGrid;
    function GetCellRect(const RowNum, ColNum: Integer): TRect;
    procedure ShowHintForCell(const RowNum, ColNum: integer);
    procedure DoDeleteDissection(pT: pTransaction_Rec);
    procedure DoDeleteJournal(pT: pTransaction_Rec);
    procedure SetIsClosing(const Value: boolean);
    procedure EmptyTmpBuffer;
    procedure SetQuantitySign(QuantityChanged : Boolean);

    function  CanUseSuperFields : boolean;
    //function MDEDateChange(var Tran: pTransaction_Rec): Boolean;

    procedure WMSysCommand(var msg: TWMSyscommand); message WM_SYSCOMMAND;

    function CodingMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    procedure QueryUncoded;
    procedure DeleteDissection(Sender: TObject);
    procedure ClearSuperfields(Sender: TObject);
    procedure DeleteJournal(Sender: TObject);
    procedure RedrawRow(Row: Integer = 0);
    function GetIsJournal: Boolean;
    procedure DrawNotesIcon(RowNum: Integer; R: TRect; TableCanvas: TCanvas);
    function RejectJournalDate(Value: TStDate): Boolean;
    function RejectHistoricalDate(Value: TSTDate): Boolean;
    function AdjustDateRange(Value: TStDate): Boolean;
    procedure SetSearchText(const Value: string);
    procedure SetSearchVisible(const Value: Boolean);
    function GetSearchVisible: Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure ProcessExternalCmd(Command : TExternalCmd);

    class function CreateAndSetup( aOwner              : Forms.TForm;
                                   aBankAccount        : TBank_Account;
                                   const aTranDateFrom : TStDate;
                                   const aTranDateTo   : TStDate;
                                         CodingOptions: TCodingOptions) : TfrmCoding;
    //provides access to bank account from form.
    property Bank_Account : TBank_Account read BankAccount;
    property CurrentSortOrder : Integer read TranSortOrder;
    property ShowingAllTran   : Byte read ShowAllTran;
    property RestrictedMode   : Boolean read EditAcctColOnly;
    property ColumnList       : TColFmtList read ColumnFmtList;
    property IsClosing        : boolean read FIsClosing write SetIsClosing;
    property IsJournal : Boolean read GetIsJournal;
    function FormIsInEditMode : boolean;
    procedure Reload;
    property StartDate: TStDate read TranDateFrom;
    property EndDate: TStDate read TranDateTo;
    property SearchText: string read FSearchText write SetSearchText;
    property SearchVisible: Boolean read GetSearchVisible write SetSearchVisible;
  end;

  procedure DoCoding(CodingOptions: TCodingOptions = []);
  procedure CodeTheseEntries(DateFrom, DateTo : TStDate; BA: TBank_Account = nil; CodingOptions: TCodingOptions = []);
  procedure GetCodingDateRange(var dateFrom,dateTo : TStDate);
//******************************************************************************
implementation
{$R *.DFM}
uses
   selectJournalDlg,
   AutoSaveUtils,
   OvcConst,
   OvcTbCls,
   OvcNF,       //for TOvcNumericField
   StDateSt,
   bkBranding,
   BKConst,
   bkhelp,
   bkdsio,
   bktxio,
   bkUtil32,
   bkdateutils,
   //Journals,
   JNLUTILS32,
   JournalDlg,
   bkXPThemes,
   CodingFormConst,
   DecimalRounding_JH1,
   GenUtils,
   glConst,
   globals,
   GSTCalc32,
   ImagesFrm,
   updatemf,
   winUtils,
   MoneyDef,
   trxList32,
   Files,
   ForexHelpers,
   AccountLookupFrm,
   bkMaskUtils,
   PayeeLookupFrm,
   DissectionDlg,
   MemoriseDlg,
   AutoCode32,
   GSTLookupFrm,
   GSTUtil32,
   InfoMoreFrm,
   ErrorMoreFrm,
   WarningMoreFrm,
   AccsDlg,
   ContraDlg,
   Math,
   Matches,
   FindDlg,
   Finalise32,
   Outstand,
   MatchDlg,
   YesNoDlg,
   NewAmountDlg,
   MoneyUtils,
   EnterPwdDlg,
   bkdbexcept,
   bk5Except,
   DelChequeDlg,
   DelUnCheqDlg,
   CodeDateDlg,
   ColOrderFrm,
   ConfigColumnsFrm,
   NewHints,
   StStrS,
   Progress,
   Software,
   //ColRestrictedFrm,
   ReversingEntryDetailsFrm,
   LogUtil,
   SuperFieldsUtils,
   TransactionUtils,
   mxUtils,
   ClientHomePagefrm,
   RecombineEntriesFrm,
   PayeeRecodeDlg,
{$IFDEF SmartLink}
   FingerTipsInterface,
{$ENDIF}
{$IFDEF PLAYSOUNDS}
   sounds,
{$ENDIF PLAYSOUNDS}
   SwapUtils, clObj32, pyList32, ECollect, mainfrm,
   PayeeObj, UsageUtils, QueryTx, NewReportUtils,
   CountryUtils, SetClearTransferFlags, ExchangeRateList, AuditMgr,
   BankLinkOnlineServices,
   dxList32,
   CAUtils;

const
   UnitName = 'CODINGFRM';

   {status panel constants}
   PANELMODE = 0;
   PANELLINE = 1;
   PANELCODEDCOUNT = 2;
   PANELTEXT = 3;
   GSTTEXT   = 4;
   PANELBAL = 5;

   {table command const}
   tcLookup            = ccUserFirst + 1;
   tcEditAll           = ccUserFirst + 2;
   tcNextUncoded       = ccUserFirst + 3;
   tcSort              = ccUserFirst + 4;
   tcView              = ccUserFirst + 5;
   tcMore              = ccUserFirst + 6;
   tcMemorise          = ccUserFirst + 7;
   tcAcctLookup        = ccUserFirst + 8;
   tcPayeeLookup       = ccUserFirst + 9;
   tcDissect           = ccUserFirst + 10;
   tcFind              = ccUserFirst + 11;
   tcDitto             = ccUserFirst + 12;
   tcAmount            = ccUserFirst + 13;
   tcMatch             = ccUserFirst + 14;
   tcDeleteTrans       = ccUserFirst + 15;
   tcInsertUPC         = ccUserFirst + 16;
   tcDeleteCell        = ccUserFirst + 17;
   tcUnpresentedItems  = ccUserFirst + 18;
   tcSetFlags          = ccUserFirst + 19;
   tcRecalc            = ccUserFirst + 20;
   tcGSTLookup         = ccUserFirst + 21;
   tcRecombine         = ccUserFirst + 22;
   tcGotoNotes         = ccUserFirst + 23;
   tcCopySDToNarration = ccUserFirst + 24;
   tcCopyNotesToNarration = ccUserFirst + 25;
   tcAppendNotesToNarr = ccUserFirst + 26;
   tcAppendSDToNarr    = ccUserFirst + 27;
   tcEditSuperFields   = ccUserFirst + 28;
{$IFDEF SmartLink}
   tcLaunchFingertips  = ccUserFirst + 29;
{$ENDIF}
   tcNextNote       = ccUserFirst + 30;
   tcMarkNote       = ccUserFirst + 31;
   tcMarkAllNotes   = ccUserFirst + 32;
   tcDeleteNote     = ccUserFirst + 33;
   tcQueryUncoded   = ccUserFirst + 34;
   tcJobs           = ccUserFirst + 35;
   tcInsertTrans    = ccUserFirst + 36;
   tcRateLookup     = ccUserFirst + 37;


   SectionNameTemplate = 'Coding Layout - Bank %s';
   DefaultBankPrefix   = '00';
   //NewZealand
   ANZPrefix           = '01';
   BNZPrefix           = '02';
   WPCPrefix           = '03';
   NATPrefix           = '06';
   ASBPrefix           = '12';
   //Australia - EldersPrefix moved to BKConst

   // Menu names, so they can be found..
   mniDelDissection  = 'mniDelDissection';
   mniEJCaption      = 'Edit Journal                                           /';
   mniVJCaption      = 'View Journal                                           /';
   mniEditJournal    = 'mniEditJournal';

   mniSuperClear     = 'mniSuperClear';
   mniSuper          = 'mniSuper';
   mniFingertips     = 'mniFingertips';
   mniSep1           = 'Sep1';
   mniEditUPCAmount  = 'mniEditUPCAmount';
   mniSep3           = 'Sep3';

var
   DefaultPositions : array[0..ceMax] of integer;


// Redraw main form on minimize
procedure TfrmCoding.WMSysCommand(var msg: TWMSyscommand);
begin
  if ((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE) then
    exit
  else
    inherited;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.CreateCodingPopup(Journal: Boolean);
// This routine fills the Popup with the appropriate MenuItems
const
   maxPopCodingItems = 26;
var
   i : Integer;
   poiCoding: array[0..maxPopCodingItems] of TMenuItem;
   CurrentIndex, NarrationIndex, NoteIndex : byte;
begin
   with popCoding do begin
      Images := AppImages.Coding
   end;
   //BankLink Coding Popup

   CurrentIndex := 0;
   if Journal  then begin
      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mniEditJournal;
         Caption := mniEJCaption;
         ImageIndex := -1;
         onClick := DissectionClick;
      end;
      Inc( CurrentIndex);
      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniNewJournal';
         Caption := 'New Journal                                       Shift Ins';
         ImageIndex := -1;
         onClick := DoNewJournal;
      end;
      Inc( CurrentIndex);
      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mnidelDissection;
         Caption := 'Delete Journal                                    Shift Del';
         ImageIndex := -1;
         onClick := DeleteJournal;
      end;

      Inc( CurrentIndex);
   end else begin

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniLookupChart';
         Caption := '&Lookup Chart                                          F2';
         ImageIndex := 0;
         onClick := AccountLookupClick;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniLookupPayee';
         Caption := 'Lookup &Payee                                         F3';
         ImageIndex := 1;
         onClick := PayeeLookupClick;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniLookupJob';
         Caption := 'Lookup &Job                                              F5';
         ImageIndex := 19;
         onClick := JobLookupClick;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniLookupGST';
         Caption := Localise( FCountry, 'Loo&kup GST Class                                   F7' );
         onClick := GSTLookupClick;
      end;
      Inc( CurrentIndex);

      if Assigned(AdminSystem)
      or (not  MyClient.clExtra.ceBlock_Client_Edit_Mems) then begin

         poiCoding[CurrentIndex] := TMenuItem.Create(Self);
         with poiCoding[CurrentIndex] do begin
            Name := 'mniMemorise';
            Caption := '&Memorise Entry                                       F4';
            ImageIndex := 2;
            onClick := MemoriseClick;
         end;
         Inc( CurrentIndex);
      end;

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniDissect';
         Caption := '&Dissect Entry                                           /';
         ImageIndex := 3;
         onClick := DissectionClick;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mniSuper;
         Caption := '&Edit Superfund Details                            F11';
         ImageIndex := CODING_SUPER_BMP;
         onClick := SuperClick;
         Visible := CanUseSuperFields;
      end;
      Inc( CurrentIndex);


      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mniFingertips;
         Caption := 'Launch Fingertips                                Ctrl+Shift+F';
         ImageIndex := -1;
{$IFDEF SmartLink}
         onClick := ftClick;
         Visible := true;
{$ELSE}
         onClick := nil;
         Visible := false;
{$ENDIF}
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin //Separator
         Name := mniSep1;
         Caption := '-';
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mniSuperClear;
         Caption := 'Clear Superfund Details';
         ImageIndex := -1;
         onClick := ClearSuperFields;
         Visible := False;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mnidelDissection;
         Caption := 'Delete D&issection                                    Del';
         ImageIndex := -1;
         onClick := DeleteDissection;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin //Separator
         Name := 'Sep2';
         Caption := '-';
      end;
      Inc( CurrentIndex);


      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniFind';
         Caption := '&Find                                                          Ctrl+F';
         ImageIndex := 7;
         onClick := FindClick;
      end;
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniGotoNext';
         Caption := '&Goto Next Uncoded                                F8';
         ImageIndex := 5;
         onClick := GotoNextClick;
      end;
      Inc( CurrentIndex);
   end;


   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin //Separator
      Name := mniSep3;
      Caption := '-';
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniGotoNextNote';
      Caption := 'Goto Ne&xt Note                                       F12';
      ImageIndex := -1;
      onClick := GotoNextNoteClick;
   end;
   Inc( CurrentIndex);

   if not journal then begin
      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := mniEditUPCAmount;
         ImageIndex := -1;
         Caption := '&Edit Amount                                            =';
         OnClick := pmiDoNewAmount;
      end;
      Inc(CurrentIndex);
   end;

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniGotoNotes';
      Caption := 'Edit &Notes                                               Ctrl+B';
      ImageIndex := 13;
      OnClick := pmiGridGotoNotes;
   end;
   Inc(CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniNotes';
      Caption := 'Notes';
   end;
   NoteIndex := CurrentIndex;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin //Separator
      Name := 'Sep4';
      Caption := '-';
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniOrder';
      Caption := 'C&onfigure Columns';
      ImageIndex := -1;
      onClick := ColConfigureClick;
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniRestore';
      Caption := '&Restore Column Defaults';
      ImageIndex := -1;
      onClick := ColRestoreClick;
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin //Separator
      Name := 'Sep5';
      Caption := '-';
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniCopyCeontent';
      Caption := 'Cop&y Contents of the Cell Above              +';
      ImageIndex := 6;
      OnClick := pmiDoDitto;
      ShortCut := TextToShortCut('+');
   end;
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniNarrations';
      Caption := 'Narrations';
      Visible := not Journal;
   end;
   NarrationIndex := CurrentIndex;
   Inc( CurrentIndex);

   if (MyClient.clFields.clCountry = whUK) and  (BankAccount.IsAForexAccount) then begin
     poiCoding[CurrentIndex] := TMenuItem.Create(Self);
     with poiCoding[CurrentIndex] do begin
        Name := 'mniConvertAmount';
        Caption := 'Con&vert Amount';
        onClick := ConvertVATAmount;
     end;
     Inc( CurrentIndex);
   end;

   with popCoding do begin
      for i := 0 to CurrentIndex -1 do begin
         Items.Add( poiCoding[i]);
      end;
   end;

   CurrentIndex := 0;
   if not Journal then begin

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniNarrationReplaceDetails';
         Caption := 'Replace with &Statement Details       Ctrl+H';
         OnClick := pmiDoCopySDToNarration;
      end;
      popCoding.Items[NarrationIndex].Add(poiCoding[CurrentIndex]);
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniNarrationAppendDetails';
         Caption := 'Appen&d Statement Details               Shift+Ctrl+H';
         OnClick := pmiDoAppendSDToNarration;
      end;
      popCoding.Items[NarrationIndex].Add(poiCoding[CurrentIndex]);
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniNarrationReplaceNotes';
         Caption := 'Replace with N&otes                          Ctrl+J';
         OnClick := pmiDoCopyNotesToNarration;
      end;
      popCoding.Items[NarrationIndex].Add(poiCoding[CurrentIndex]);
      Inc( CurrentIndex);

      poiCoding[CurrentIndex] := TMenuItem.Create(Self);
      with poiCoding[CurrentIndex] do begin
         Name := 'mniNarrationAppendNotess';
         Caption := 'Append Notes                                  Shift+Ctrl+J';
         OnClick := pmiDoAppendNotesToNarration;
      end;
      popCoding.Items[NarrationIndex].Add(poiCoding[CurrentIndex]);
   end;
   CurrentIndex := 0;

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniNoteMark';
      ImageIndex := 15;
      Caption := '&Mark Note as Read/Unread    Shift+Ctrl+M';
      OnClick := pmiDoMarkNote;
   end;
   popCoding.Items[NoteIndex].Add(poiCoding[CurrentIndex]);
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniNoteMarkAll';
      Caption := 'Mark &All Notes as Read           Shift+Ctrl+A';
      OnClick := pmiDoMarkAllNotes;
   end;
   popCoding.Items[NoteIndex].Add(poiCoding[CurrentIndex]);
   Inc( CurrentIndex);

   poiCoding[CurrentIndex] := TMenuItem.Create(Self);
   with poiCoding[CurrentIndex] do begin
      Name := 'mniNoteDelete';
      ImageIndex := 16;
      Caption := '&Delete Note                             Shift+Ctrl+X';
      OnClick := pmiDoDeleteNote;
   end;
   popCoding.Items[NoteIndex].Add(poiCoding[CurrentIndex]);
   Inc( CurrentIndex);

end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormCreate(Sender: TObject);

begin
  bkXPThemes.ThemeForm( Self);
  SetLength( tmpBuffer, MaxNarrationEditLength + 1);
  FCountry := MyClient.clFields.clCountry;

  if FCountry = whUK then
  Begin
    mniRecalcGST.Caption := '&Recalculate VAT';
  End;
  lblAcctDetails.Font.Name := Font.Name;
  lblTransRange.Font.Name := Font.Name;
  lblFinalised.Font.Name := Font.Name;

  pnlSearch.Height := Abs(Self.Font.Height * 15 div 8) + 4;
  

  pnlExtraTitleBar.GradientColorStart := bkBranding.TobBarStartColor;
  pnlExtraTitleBar.GradientColorStop  := bkBranding.TopBarStopColor;


  imgRight.Picture := bkBranding.CodingBanner;
  pnlExtraTitleBar.Height := imgRight.Picture.Height;

  lblAcctDetails.Font.Color := bkBranding.TopTitleColor;
  //lblTransRange.Font.Color := bkBranding.TopTitleColor;
  //lblFinalised.Font.Color := bkBranding.TopTitleColor;


  //imgGraphic.Picture := AppImages.imgLogo.Picture;
  SetUpHelp;
  bkHelpSetup( Self, BKH_Using_the_Code_Entries_Screen);

  FHint := THintWindow.Create( Self );
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Font <> '') then
     StrToFont(AdminSystem.fdFields.fdCoding_Font,FHint.Canvas.Font)
  else if (not Assigned(AdminSystem)) and (INI_Coding_Font <> '') then
     StrToFont(INI_Coding_Font,FHint.Canvas.Font)
  else begin
     FHint.Canvas.Font.Name := 'Courier';
     FHint.Canvas.Font.Size := 5;
  end;

  celForexRate.PictureMask := MoneyUtils.ForexPictureMask;

  IsClosing := false;
  FIsReloading := False;
  MouseDownInAmountCol := False;
  StartFocus := True;
  Undo := False;
  FSuperTop := -999;
  FSuperLeft := -999;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ProcessExternalCmd(Command : TExternalCmd);
begin
   AutoSaveUtils.DisableAutoSave;
   try
     case command of
        ecChart :
           DoAccountLookup;
        ecDissect:
           DoDissection;
        ecSuper:
           DoEditSuperFields;
        ecPayee:
           DoPayeeLookup;
        ecMemorise:
           DoMemorise;
        ecSortDate:
           LoadWTLNewSort( csDateEffective );
        ecSortChq:
           LoadWTLNewSort( csChequeNumber );
        ecSortRef:
           LoadWTLNewSort( csReference );
        ecSortAcct:
          begin
            if ( MyClient.clFields.clCountry = whAustralia) and
              ( MyClient.clFields.clAccounting_System_Used = saXlon) and
              ( Globals.PRACINI_UseXLonChartOrder) then
              LoadWTLNewSort( csAccountCodeXLON )
            else
              LoadWTLNewSort( csAccountCode );
          end;
        ecSortValue:
           LoadWTLNewSort( csByValue);
        ecSortNarr:
           LoadWTLNewSort( csByNarration);
        ecSortOther:
           LoadWTLNewSort( csByOtherParty);
        ecSortParticulars:
           LoadWTLNewSort( csByParticulars);
        ecSortStatementDetails:
           LoadWTLNewSort( csByStatementDetails);
        ecSortEntryType:
           LoadWTLNewSort( csByEntryType);
        ecSortAnalysis:
           LoadWTLNewSort( csByAnalysis);
        ecSortCodedBy:
           LoadWTLNewSort( csByCodedBy);
        ecSortPayee:
           LoadWTLNewSort( csByPayee);
        ecSortPayeeName :
           LoadWTLNewSort( csByPayeeName);
        ecSortAccountDesc :
           LoadWTLNewSort( csByAccountDesc);
        ecSortGSTClass :
           LoadWTLNewSort( csByGSTClass);
        ecSortGSTAmount :
           LoadWTLNewSort( csByGSTAmount);
        ecSortQuantity :
           LoadWTLNewSort( csByQuantity);
        ecSortForexAmount:
           LoadWTLNewSort( csByForexAmount);
        ecSortForexRate:
           LoadWTLNewSort( csByForexRate);
        ecSortAltChartCode:
           LoadWTLNewSort( csByAltChartCode);
        ecGoto:
           DoGotoNextUncoded;
        ecGotoNote:
           DoGotoNextNote;
        ecRepeat:
           DoDitto;
        ecFind:
           DoFind;
        ecViewAll:
           ClearShowUncodedOnly;
        ecViewUncoded:
           SetShowUncodedOnly;
        ecViewUnreadNotes:
           SetShowUnReadNotesOnly;
        ecViewNotes:
           SetShowNotesOnly;
        ecViewNoNotes:
           SetShowNoNotesOnly;
        ecEditAllCol:
           SetEditAllCol;
        ecEditAcctCol:
           ClearEditAllCol;
        ecAddOutChq:
           DoAddOutstandingCheques;
        ecAddOutDep:
           DoAddOutstandingDeposits;
        ecAddOutWith:
           DoAddOutstandingWithdrawals;
        ecMatch:
           DoMatchUPC;
        ecAddInitChq:
           DoAddInitialCheques;
        ecAddInitWith:
           DoAddInitialwithdrawals;
        ecAddInitDep:
           DoAddInitialDeposits;
        ecSetFlags:
           DosetTransferDate;
        ecClearFlags:
           DoClearTransferDate;
        ecRecalcGST:
           DoRecalculateGst;
        ecSortPres:
           LoadWTLNewSort( csDatePresented);
        ecReloadTrans:
           DoReloadEntries;
        ecReCodeTrans:
           DoRecodeEntries;
        ecRefreshTable:
           tblCoding.Refresh;
        ecConfigureCols:
           ConfigureColumns;
        ecRestoreCols:
          RestoreColumnDefaults;
        ecQuit:
          Close;
        ecRecombine:
          DoRecombineEntries;
        ecUpdatePopups:
          UpdatePopups;
        ecQueryUncoded:
          QueryUncoded;
        ecSortDocumentTitle:
          LoadWTLNewSort( csByDocumentTitle);
        ecLookupJobs:DoLookupJob;
        ecSortJobs:
           LoadWTLNewSort( csByJob);
        ecSortJobName:
           LoadWTLNewSort( csByJobName);
        ecNewJournal:
           DoNewJournal;
        ecSortTransId:
           LoadWTLNewSort( csByTransId);
        ecSortSentToAndAcc:
           LoadWTLNewSort( csBySentToAndAcc);
     end;
   finally
     EnableAutoSave;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingUserCommand(Sender: TObject;
  Command: Word);
var
   pT : pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   pT   := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);

   AutoSaveUtils.DisableAutoSave;
   try
     case Command of
       tcLookup :  //Fired by F2
         begin
           if pT.txFirst_Dissection = NIL then
             DoAccountLookup
           else
             DoDissection;
         end;
       tcEditAll:
          ToggleColEditMode;
       tcNextUncoded:
          DoGotoNextUncoded;
       tcNextNote:
          DoGotoNextNote;
       tcAppendSDToNarr :
          DoCopySDToNarration( true);
       tcCopySDToNarration:
          DoCopySDToNarration( false);
       tcCopyNotesToNarration :
          DoCopyNotesToNarration( false);
       tcAppendNotesToNarr :
          DoCopyNotesToNarration( true);
       tcView:
          MFViewClick;
       tcSort:
          MFSortClick;
       tcUnpresentedItems:
          MFUnpresentedClick;
       tcMemorise:
          DoMemorise;
       tcAcctLookup:
          DoAccountLookup;
       tcPayeeLookup:
          DoPayeeLookup;
       tcGSTLookup:
          DoGSTLookup;
       tcDissect:
          DoDissection;
       tcFind:
          DoFind(True);
       tcDitto:
          DoDitto;
       tcAmount:
          DoNewAmount;
       tcMatch:
          DoMatchUPC;
       tcDeleteTrans:
          DoDeleteTrans;
       tcInsertUPC:
          DoAddOutstandingCheques;
       tcDeleteCell:
          DoDeleteCell;
       tcRecalc:
          PopGst.Popup(Self.width div 3, Self.height div 2);
       tcSetFlags:
          PopTransfer.Popup(Self.width div 3, Self.height div 2);
       tcRecombine:
          DoRecombineEntries;
       tcGotoNotes:
          DoGotoNotes;
       tcEditSuperFields :
          DoEditSuperFields;
       tcMarkNote:
          DoMarkNote;
       tcMarkAllNotes:
          DoMarkAllNotes;
       tcDeleteNote:
          DoDeleteNote;
       tcQueryUncoded:
          QueryUncoded;
       tcJobs:
          DoLookupJob;
       tcInsertTrans: if Isjournal then
          DoNewJournal;
{$IFDEF SmartLink}
       tcLaunchFingertips :
          DoLaunchFingerTips;
{$ENDIF}
     end;
   finally
     EnableAutoSave;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAccountLookup;
{
Assists the user in coding by allowing selection of Account Codes from
Chart Lookup

The function PickAccount(Code) accepts a Code or partial Code or blank
and attempts to position the Chart on that Code.
It returns True if the user selects an Account Code and puts the Code
in the Var Parameter, if no Code is chosen it returns False.

This method can be called from
   ToolBar,
   Popup Menu,
   F2 key or Ctrl-L if the user is positioned on the Account column.

We do not know the position or the Edit State of the Active Cell when
this method is called.  We therefore end any existing edit and move to
the Account column.
}
var
  Code : string;
  InEditOnEntry : boolean;
  pT            : pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   pT   := WorkTranList.Transaction_At( tblCoding.ActiveRow - 1);
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

   with tblCoding do begin
      //test if we are in the correct col, if not end any edit and move to
      //correct col
      if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceAccount ) then begin
         if not StopEditingState(True) then Exit;
         ActiveCol := ColumnFmtList.GetColNumOfField(ceAccount);
      end;

      InEditOnEntry := InEditingState;
      if not InEditOnEntry then begin
         if not StartEditingState then Exit;   //returns true if alreading in edit state
      end;

      Code := TEdit(celAccount.CellEditor).Text;

      if PickAccount(Code) then begin
          //if get here then have a code which can be posted to from picklist
          TEdit(celAccount.CellEditor).Text := Code;
          //no need to do any more because will be handled by
          //celAccount.OnChange
      end
      else begin
          if not InEditOnEntry then begin
             StopEditingState(true);  //end edit don't save change
          end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoGSTLookup;
//can be called from F7 Key
//if we can edit gst class col then move to that col and do lookup
//if we are in account col only then end existing the transaction directly
var
  GSTCode       : string;
  InEditOnEntry : boolean;
  Msg           : TWMKey;
  GSTClassNotEditable : boolean;
  pT                  : pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   pT   := WorkTranList.Transaction_At( tblCoding.ActiveRow - 1);
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

    //never allow gst lookup if using elite
   If not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then exit;

   //check to see that gst col is editable
   GSTClassNotEditable := not ColumnFmtList.FieldIsEditable( ceGSTClass);

   if not ( EditAcctColOnly or GSTClassNotEditable) then
   begin
      with tblCoding do begin
         //test if we are in the correct col, if not end any edit and move to
         //correct col
         if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceGSTClass ) then begin
            if not StopEditingState(True) then Exit;
            ActiveCol := ColumnFmtList.GetColNumOfField(ceGSTClass);
         end;

         InEditOnEntry := InEditingState;
         if not InEditOnEntry then begin
            if not StartEditingState then Exit;   //returns true if alreading in edit state
         end;

         GSTCode := TEdit(celGSTCode.CellEditor).Text;
         if PickGSTClass(GSTCode, true) then begin
             //if get here then have a valid char from the picklist
             TEdit(celGSTCode.CellEditor).Text := GSTCode;
             Msg.CharCode := VK_RIGHT;
             celGSTCode.SendKeyToTable(Msg);
         end
         else begin
             if not InEditOnEntry then begin
                StopEditingState(true);  //end edit don't save change
             end;
         end;
      end;
   end
   else
   begin
      with tblCoding do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pT   := WorkTranList.Transaction_At(ActiveRow-1);
         GSTCode := GSTCALC32.GetGSTClassCode( MyClient, pT^.txGST_Class);
         if PickGSTClass( GSTCode, true) then begin
            //if get here then have a valid gst class from the picklist, so edit
            //the fields in the transaction
            pT^.txGST_Class := GSTCALC32.GetGSTClassNo( MyClient, GSTCode);
            GSTClassEdited( pT);
            //check if gst edited
            if GSTDifferentToDefault( MyClient, pT ) then begin
               pT^.txHas_Been_Edited     := true;
               pT^.txGST_Has_Been_Edited := true;
            end
            else
               pT^.txGST_Has_Been_Edited := false;
            RedrawRow;

            Msg.CharCode := VK_RIGHT;
            celPayee.SendKeyToTable(Msg);
         end;
      end;
   end;
end;
procedure TfrmCoding.DoLookupJob;
var
   pT                : pTransaction_Rec;
   pD                : pDissection_Rec;
   InEditOnEntry     : boolean;
   JobCode           : string;
   Msg               : TWMKey;
   JobNotEditable  : Boolean;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then
      exit;
   pT := WorkTranList.Transaction_At( tblCoding.ActiveRow - 1);
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

   pD := pT^.txFirst_Dissection;
   while Assigned(pd) do begin
      if pD.dsJob_Code > '' then
         Exit;
      pD := pD.dsNext;
   end;

   //Check to see if a Job col exists and is editable
   JobNotEditable :=  not ColumnFmtList.FieldIsEditable(ceJob);

   if not ( EditAcctColOnly or JobNotEditable) then begin
      with tblCoding do begin
         //test if we are in the correct col, if not end any edit and move to
         //correct col
         if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceJob ) then begin
            if not StopEditingState(True) then
               Exit;
            ActiveCol := ColumnFmtList.GetColNumOfField(ceJob);
         end;
         //In correct column and is visible so begin the edit
         InEditOnEntry := InEditingState;
         if not InEditOnEntry then begin
            if not StartEditingState then
               Exit;   //returns true if alreading in edit state
         end;

         JobCode := TEdit(celJob.CellEditor).Text;

         if PickJob(JobCode) then begin
             //if get here then have a code which can be posted to from picklist
             TEdit(celJob.CellEditor).Text := JobCode;
             Msg.CharCode := VK_RIGHT;
             celJob.SendKeyToTable(Msg);
         end else begin
             if not InEditOnEntry then begin
                StopEditingState( True);  //end edit
             end;
         end;
      end;
   end else begin  //Edit Account Col Only, or PayeeCol has been hidden
      with tblCoding do begin
         //End edit of Account if any
         if not StopEditingState(True) then
            Exit;
         pT   := WorkTranList.Transaction_At(ActiveRow-1);
         //user can edit payee so proceed
         JobCode := pT.txJob_Code  ;
         //OldPayeeNo := pT^.txPayee_Number;
         if PickJob(JobCode) then begin
            //if get here then have a valid payee from the picklist, so edit
            //the fields in the transaction
            pT.txJob_Code := JobCode;

            pT.txTransfered_To_Online := False;

            {if not PayeeEdited(pT) then
               pT^.txPayee_Number := OldPayeeNo;}
            RedrawRow;
            Msg.CharCode := VK_RIGHT;
            celJob.SendKeyToTable(Msg);
         end;
      end;
   end;
end; //DoPayeeLookup;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoPayeeLookup;
{
Assists the user in coding by allowing selection of Payee Codes from
Payee Lookup

The function PickPayee(IntCode) accepts a Code and attempts to position the
List on that Code.  It returns True if the user selects an Payee Code and puts
the Code in the Var Parameter, if no Code is chosen it returns False.

This method can be called from the ToolBar, Popup Menu, F2 key if the
user is positioned on the Payee column, and F3 key if the user is positioned
on the Account column.

If we can edit Payee column, We do not know the position
or the Edit State of the Active Cell when this method is called.  We therefore
end any existing edit and move to the Payee column.

If only Account column is editable, we end any existing edit and find the
current transaction the user is working on.  The routine then edits the
transaction directly.

If the payee column has been hidden the only way to call this will be from F3 on
the Account Column if this is the case then call Payee Edited directly.  Do not
try to edit the payee cell because it is hidden and editing will cause an AV.
}
var
   pT                : pTransaction_Rec;
   pD                : pDissection_Rec;
   InEditOnEntry     : boolean;
   intCode           : integer;
   Msg               : TWMKey;
   PayeeNotEditable  : Boolean;
   OldPayeeNo        : integer;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   pT   := WorkTranList.Transaction_At( tblCoding.ActiveRow - 1);
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

   //check to see if payee has been assigned to the dissection lines.  if so
   //do nothing;
   //first see if entry is dissected, if so make sure payee not assigned
   //to dissect lines
   pD := pT^.txFirst_Dissection;
   while ( pd <> nil) do begin
      if pD^.dsPayee_Number <> 0 then exit;
      pD := pD^.dsNext;
   end;

   //Check to see if a payee col exists and is editable
   PayeeNotEditable :=  not ColumnFmtList.FieldIsEditable( cePayee);

   if not ( EditAcctColOnly or PayeeNotEditable) then begin
      with tblCoding do begin
         //test if we are in the correct col, if not end any edit and move to
         //correct col
         if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = cePayee ) then begin
            if not StopEditingState(True) then Exit;
            ActiveCol := ColumnFmtList.GetColNumOfField(cePayee);
         end;
         //In correct column and is visible so begin the edit
         InEditOnEntry := InEditingState;
         if not InEditOnEntry then begin
            if not StartEditingState then Exit;   //returns true if alreading in edit state
         end;

         IntCode := TOvcNumericField(celPayee.CellEditor).AsInteger;

         if PickPayee(IntCode) then begin
           if BankAccount.ValidPayeeCode(IntCode) then begin
             //if get here then have a code which can be posted to from picklist
             TOvcNumericField(celPayee.CellEditor).AsInteger := IntCode;
             Msg.CharCode := VK_RIGHT;
             celPayee.SendKeyToTable(Msg);
           end;
         end
         else begin
             if not InEditOnEntry then begin
                StopEditingState( True);  //end edit
             end;
         end;
      end;
   end
   else begin  //Edit Account Col Only, or PayeeCol has been hidden
      with tblCoding do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pT   := WorkTranList.Transaction_At(ActiveRow-1);
         //user can edit payee so proceed
         IntCode := pT^.txPayee_Number;
         OldPayeeNo := pT^.txPayee_Number;
         if PickPayee(IntCode) then begin
            if BankAccount.ValidPayeeCode(IntCode) then begin
              //if get here then have a valid payee from the picklist, so edit
              //the fields in the transaction
              pT^.txPayee_Number := IntCode;
              if not PayeeEdited(pT) then
                 pT^.txPayee_Number := OldPayeeNo;

              RedrawRow;

              Msg.CharCode := VK_RIGHT;
              celPayee.SendKeyToTable(Msg);
            end;
         end;
      end;
   end;
end; //DoPayeeLookup;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoDissection(JA: Integer = -1);
//cannot dissect an entry that is dissected or transferred and not already dissected
var
   pT : pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then
      Exit;
   if not tblCoding.StopEditingState(True) then
      Exit;

   with tblCoding do begin
      pT := WorkTranList.Transaction_At(ActiveRow-1);

      if IsJournal then begin
         tblcoding.AllowRedraw := false;
         try
            EditJournalEntry(BankAccount, Pt, BankAccount.baFields.baAccount_Type, 0,JA);
            LoadWTLMaintainPos;
         finally
            tblcoding.AllowRedraw := True;
         end;
      end else begin
         if  ((pT^.txLocked) or (pT^.txDate_Transferred <> 0)) //Locked-Transferd
         and (pT^.txFirst_Dissection = nil) then  //is not already dissected
            Exit;

         if DissectEntry(pT, BankAccount.baFields.baNotes_Always_Visible, True, BankAccount) then
         begin
            Refresh;

            // Replaces the Kepressed Message to the Table with a Cell command since when the Shift state was set,
            // i.e. Alt Shift Ctrl was pressed this did not work
            tblCoding.MoveActiveCell(ccRight);

            //Audit journal add for UK
            if (JA > 0) and (MyClient.clFields.clCountry = whUK) then
              SaveClient(false);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoMemorise;
var
   pT           : pTransaction_Rec;
   Msg          : TWMKey;
   IsAMasterMem : boolean;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   if not tblCoding.StopEditingState(True) then Exit;
   IncUsage('Memorised Entries');
   with tblCoding do begin
      pT   := WorkTranList.Transaction_At(ActiveRow-1);
      if MemoriseEntry(BankAccount,pT, IsAMasterMem) then
      begin
         //the memorisation may have been a master mem, so recode everything
         if IsAMasterMem then
           SendCmdToAllCodingWindows( ecRecodeTrans)
         else
         begin
           AutoCodeEntries( MyClient, BankAccount, pT^.txType, TranDateFrom, TranDateTo);
           LoadWTLMaintainPos;
           Refresh;
         end;
         Msg.CharCode := VK_RIGHT;
         if ShowAllTran <> SHOW_UNCODED_TX then
           celAccount.SendKeyToTable(Msg);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(* Removed
procedure TfrmCoding.DoFind;
//Finds transaction matching the criteria entered into the FindDlg

   function IsMatch( const pT : pTransaction_Rec; const FindDate : Integer; const FindRefce : string;
                     const FindAmount : double) : Boolean;
   var
      FindMoney   : Money;
   begin
      Result := False;
      with pT^ do begin
         FindMoney := Double2Money(FindAmount);
         if (FindMoney <> 0) and (FindDate <> 0) and (FindRefce <> '') then begin
            if ( txAmount <> FindMoney ) or ( txAmount <> (-FindMoney) ) then
               Exit;
            if ( txDate_Effective <> FindDate ) then
               Exit;
            if not WildCardMatch( UpperCase( Trim(FindRefce )), UpperCase( Trim( GetFormattedReference( pT)))) then
               Exit;
            Result := True;
         end
         else begin
            if FindMoney <> 0 then begin
               if ( txAmount = FindMoney ) or ( txAmount = (-FindMoney) ) then
                  Result := True;
            end;
            if FindDate <> 0 then begin
               if ( txDate_Effective = FindDate ) then
                  Result := True;
            end;
            if FindRefce <> '' then begin
               if WildCardMatch( UpperCase( Trim(FindRefce )), UpperCase( Trim( GetFormattedReference( pT)))) then
                  Result := True;
            end;
         end;
      end;
   end;

var
   i : integer;
   FoundAt : integer;
   FindDate    : integer;
   FindRefce   : String[12];
   FindAmount  : Double;
   pT          : pTransaction_Rec;
begin
   FoundAt := -1;
   if ( WorkTranList.ItemCount = 0 ) then exit;
   if FindParameters(FindDate,FindRefce,FindAmount) then begin
      for i := 0 to Pred( WorkTranList.ItemCount ) do begin
         pT := WorkTranList.Transaction_At( i );
         If IsMatch( pT, FindDate, FindRefce, FindAmount ) then begin
            FoundAt := i;
            Break;
         end;
      end;
      if FoundAt = -1 then
        HelpfulInfoMsg( 'No matching transaction found', 0 )
      else
        {found transaction so reposition}
        tblCoding.ActiveRow := FoundAt + 1;
   end;
end;
*)

procedure TfrmCoding.DoFind(Find: Boolean = False);
begin
   SearchVisible := (not SearchVisible)
                 or (Find)

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.WMDoNewJournal(var message: TMessage);
begin
   DoNewJournal;
end;

Procedure TfrmCoding.WMGetMinMaxInfo(Var msg: TWMGetMinMaxInfo);
Begin
   inherited;
   { Maximize MDI Child ...
   With msg.MinMaxInfo^.ptMaxTrackSize Do Begin
      X := GetDeviceCaps( Canvas.handle, HORZRES ) + (Width - ClientWidth);
      Y := GetDeviceCaps( Canvas.handle, VERTRES ) + (Height - ClientHeight );
   End;
   }
End;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.DoZoom;

Const
   Rect : TRect = (Left:0; Top:0; Right:0; Bottom:0);
begin
   try
      LockWindowUpdate( Application.MainForm.Handle );
      Zoomed := not Zoomed;
      If Zoomed Then Begin
        pnlExtraTitleBar.Visible := False;
        imgRight.Visible := False;
        BorderStyle := bsNone;
        Rect := BoundsRect;
        SetBounds( Left - ClientOrigin.X, Top - ClientOrigin.Y,
           GetDeviceCaps( Canvas.handle, HORZRES ) + (Width - ClientWidth),
           GetDeviceCaps( Canvas.handle, VERTRES ) + (Height - ClientHeight ));
        WindowState := wsMaximized;
        FormStyle   := fsStayOnTop;
      end
      Else Begin
        BoundsRect  := Rect;
        BorderStyle := bsSizeable;
        FormStyle   := fsMDIChild;
        pnlExtraTitleBar.Visible := True;
        imgRight.Visible := True;
      end;
   finally
      LockWindowUpdate(0);
   end;
end;

procedure TfrmCoding.DrawNotesIcon(RowNum: Integer; R: TRect; TableCanvas: TCanvas);

//custom draw allows us to add the notes icon to the
//column, and to display account code in red if it is invalid
Type
  TNotesIcon = ( niNone, niTNotes, niTImportNotes, niDNotes, niDImportNotes, niTReadNotes, niDReadNotes );

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Function GetNotesIcon( Const T : pTransaction_Rec ): TNotesIcon;
  Var
    pD : pDissection_Rec;
  Begin
    Result := niNone;

    //check dissection notes first
    if T^.txFirst_Dissection <> nil then
    begin
      //see if notes on dissection lines
      pD := T^.txFirst_Dissection;
      while ( pD <> nil) and (( Result = niNone) or (Result = niDReadNotes)) do
      begin
        if ( pD^.dsECoding_Import_Notes <> '') and (not pD^.dsImport_Notes_Read) then
           result := niDImportNotes
        else
        if ( pD^.dsNotes <> '') and (not pD^.dsNotes_Read) then
           result := niDNotes
        else if (pD^.dsImport_Notes_Read and (pD^.dsECoding_Import_Notes <> '')) or
                (pD^.dsNotes_Read and (pD^.dsNotes <> '')) then
          result := niDReadNotes;
        pD := pD^.dsNext;
      end;
    end;

    //check transaction notes if icon not set already
    if Result = niNone then
    begin
      if ( T^.txECoding_Import_Notes <> '') and (not T^.txImport_Notes_Read) then
        result := niTImportNotes
      else
      if ( T^.txNotes <> '') and (not T^.txNotes_Read)  then
        result := niTNotes
      else if (T^.txImport_Notes_Read and (T^.txECoding_Import_Notes <> '')) or
              (T^.txNotes_Read and (T^.txNotes <> '')) then
        result := niTReadNotes;
    end;
  end;

var pt: pTransaction_Rec;
    NotesIcon: TNotesIcon;
begin

  // Draw the Notes icon
  If ValidDataRow( RowNum ) then
  begin
    pT   := WorkTranList.Transaction_At( RowNum-1 );
    NotesIcon := GetNotesIcon( pT );
    if NotesIcon <> niNone then
    begin
      R.Left := R.Right - ( R.Bottom - R.Top ); { Square at RH End }
      InflateRect( R, -6, -6 ); { Make it Smaller }
      OffsetRect( R, 3, 0 ); { Move it Right a bit }
      Case NotesIcon of
        niTNotes       : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgNotes.Picture.Bitmap );
        niTImportNotes : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgImportNotes.Picture.Bitmap );
        niDNotes       : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgDissectNotes.Picture.Bitmap );
        niDImportNotes : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgDissectImportNotes.Picture.Bitmap );
        niTReadNotes   : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgReadNotes.Picture.Bitmap );
        niDReadNotes   : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgDissectReadNotes.Picture.Bitmap );
      end;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoMatchUPC;
//Attempts to match current transaction with an entry in the UEList
var
  pT          : pTransaction_Rec; //Points to transaction to match
  pUPI        : pTransaction_Rec; //Points to UPI transaction
  pU          : pUE;              //Points to entry in UEList
  Diff        : Money;
  sMsg        : String;
  DeletedTrans: pDeleted_Transaction_Rec;
begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not StopEditingState(True) then exit;
    pT := WorkTranList.Transaction_At(ActiveRow-1);
  end;

  if pT^.txLocked then
    exit;
  //check to see if there are any ue items
  if not Assigned( UEList) then
    exit;

  with pT^ do
  begin
    if ( txDate_Transferred <> 0 ) then
    begin
      HelpfulInfoMsg( 'You cannot match an entry once it has been transferred into your accounting system', 0 );
      exit;
    end;

    if ( txDate_Presented = 0 ) or ( txUPI_State in [ upUPC, upUPD, upUPW]) then
    begin
      HelpfulInfoMsg( 'You cannot match an unpresented entry against another one!', 0 );
      exit;
    end;

    if ( txUPI_State in [ upMatchedUPC, upMatchedUPD, upMatchedUPW, upReversedUPC, upReversedUPD, upReversedUPW]) then
    begin
      HelpfulInfoMsg( 'You cannot match an entry that has already been matched or cancelled.', 0);
      exit;
    end;

    if ( txUPI_State in [ upReversalOfUPC, upReversalOfUPD, upReversalOfUPW]) then
    begin
      HelpfulInfoMsg( 'You cannot match an unpresented entry against a reversing entry.', 0);
      exit;
    end;

    if ( txFirst_Dissection <> nil ) then
       HelpfulInfoMsg( 'If you match this entry, any dissections you have entered will be removed', 0 );

    if ( not ( pT^.txUPI_State in [ upNone, upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW])) then
    begin
      raise EInvalidCall.CreateFmt( UnitName + ': Bad Transaction UPI State %d during match', [ pT^.txUPI_State]);
    end;

    //show dialog with matchable entries in it.  ( ie UPC's)
    pU := MatchUnpEntry(pT, UEList ); //Gets pointer to matching entry in UEList if one exists
    If not Assigned( pU ) then
      exit;

    pUPI := pU^.Ptr;

    if ( not (pUPI^.txUPI_State in [ upUPC, upUPD, upUPW])) then
    begin
      raise EInvalidCall.CreateFmt( UnitName + ': Bad UPI State %d during match', [ pUPI^.txUPI_State]);
    end;

    //check to see if there is a difference in the amounts
    Diff := pT^.Statement_Amount - pUPI^.Statement_Amount;
    if ( Diff = 0 ) then
    begin
       //confirmation question will be asked in MatchDlg

       //The amounts match, so we can flag the Unpresented Entry as being
       //presented and delete the entry we are sitting on...
       pUPI^.txDate_Presented := pT^.txDate_Presented;
       case pUPI^.txUPI_State of
         upUPC : pUPI^.txUPI_State := upMatchedUPC;
         upUPD : pUPI^.txUPI_State := upMatchedUPD;
         upUPW : pUPI^.txUPI_State := upMatchedUPW;
       end;
       //see if the original transaction has been matched with anything else
       if pT^.txMatched_Item_ID <> 0 then
       begin
          pUPI^.txOriginal_Reference                := pT^.txOriginal_Reference;
          pUPI^.txOriginal_Source                   := pT^.txOriginal_Source;
          pUPI^.txOriginal_Type                     := pT^.txOriginal_Type;
          pUPI^.txOriginal_Cheque_Number            := pT^.txOriginal_Cheque_Number;
          pUPI^.txOriginal_Amount                   := pT^.txOriginal_Amount;
          pUPI^.txMatched_Item_ID                   := pT^.txMatched_Item_ID;
          pUPI^.txOriginal_Forex_Conversion_Rate    := pT^.txOriginal_Forex_Conversion_Rate    ;
  //            pUPI^.txOriginal_Foreign_Currency_Amount  := pT^.txOriginal_Foreign_Currency_Amount  ;
          pUPI^.txCore_Transaction_ID := pT^.txCore_Transaction_ID;
          pUPI^.txCore_Transaction_ID_High := pT^.txCore_Transaction_ID_High;
       end
       else begin
          //this is the original transaction so store details
          pUPI^.txOriginal_Reference                := pT^.txReference;
          pUPI^.txOriginal_Source                   := pT^.txSource;
          pUPI^.txOriginal_Type                     := pT^.txType;
          pUPI^.txOriginal_Cheque_Number            := pT^.txCheque_Number;
          pUPI^.txOriginal_Amount                   := pT^.txAmount;
          pUPI^.txOriginal_Forex_Conversion_Rate    := pT^.txForex_Conversion_Rate    ;
  //            pUPI^.txOriginal_Foreign_Currency_Amount  := pT^.txForeign_Currency_Amount  ;
          pUPI^.txCore_Transaction_ID := pT^.txCore_Transaction_ID;
          pUPI^.txCore_Transaction_ID_High := pT^.txCore_Transaction_ID_High;
       end;

       pUPI^.txTransfered_To_Online := False;

       //log info the manual match done
       sMsg := 'Matched ref ' + GetFormattedReference( pT) +
               ' ' + MakeAmount( pT.Statement_Amount) +
               ' on ' + bkDate2Str( pT^.txDate_Effective) +
               ' with ' + GetFormattedReference( pUPI) +
               ' on ' + bkDate2Str( pT^.txDate_Effective);
       LogUtil.LogMsg( lmInfo, UnitName, sMsg);

       //*** Flag Audit ***
       sMsg := Format('%s (AuditID=%d)',[sMsg, pT.txAudit_Record_ID ]);
       MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                         pUPI^.txAudit_Record_ID,
                                         aaNone,
                                         sMsg);

       //Details from matched transaction have been transfered to the UE Transaction
       //Now we delete the matched transaction and call LoadWTLMaintainPos to reload
       //the WorkTranList and reload the UEList
       tblCoding.AllowRedraw := False; //Prevent paint from accessing deleted item
       //move off current transaction as it will be deleted
       with tblCoding do begin
          if ActiveRow > 1 then
             ActiveRow := ActiveRow - 1;
       end;

       //Delete original transaction
         if RecordDeletedTransactionData(BankAccount, pT) then
         begin
           DeletedTrans := Create_Deleted_Transaction_Rec(pT, CurrUser.Code);

           try
             BankAccount.baTransaction_List.Delete(pT);

             BankAccount.baDeleted_Transaction_List.Insert(DeletedTrans);
           except
             Dispose_Deleted_Transaction_Rec(DeletedTrans);

             raise;
           end;
         end
         else
         begin
           BankAccount.baTransaction_List.Delete(pT);
         end;
       //reload transaction
       LoadWTLMaintainPos;
       tblCoding.AllowRedraw := True;
       tblCoding.Refresh;
       RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
    end
    else begin
       //Amount of original entry and upc being matched against are different
       //Confirm will have been asked in MatchDlg

       //The amounts don't match, so we will put the difference into the
       //current entry and flag the original as being presented

       //update unpresented item
       pUPI^.txDate_Presented := pT^.txDate_Presented;
       //update upi states
       case pUPI^.txUPI_State of
          upUPC : begin
             pUPI^.txUPI_State := upMatchedUPC;
             pT^.txUPI_State   := upBalanceOfUPC;
          end;
          upUPD : begin
             pUPI^.txUPI_State := upMatchedUPD;
             pT^.txUPI_State   := upBalanceOfUPD;
          end;
          upUPW : begin
             pUPI^.txUPI_State := upMatchedUPW;
             pT^.txUPI_State   := upBalanceOfUPW;
          end;
       end;

       //see if the original transaction has been matched with anything else
       if pT^.txMatched_Item_ID <> 0 then begin
          pUPI^.txOriginal_Reference                := pT^.txOriginal_Reference;
          pUPI^.txOriginal_Source                   := pT^.txOriginal_Source;
          pUPI^.txOriginal_Type                     := pT^.txOriginal_Type;
          pUPI^.txOriginal_Cheque_Number            := pT^.txOriginal_Cheque_Number;
          pUPI^.txOriginal_Amount                   := pT^.txOriginal_Amount;
          pUPI^.txMatched_Item_ID                   := pT^.txMatched_Item_ID;
          pUPI^.txOriginal_Forex_Conversion_Rate    := pT^.txOriginal_Forex_Conversion_Rate;
  //            pUPI^.txOriginal_Foreign_Currency_Amount  := pT^.txOriginal_Foreign_Currency_Amount  ;
          pUPI^.txCore_Transaction_ID               := pT^.txCore_Transaction_ID;
          pUPI^.txCore_Transaction_ID_High          := pT^.txCore_Transaction_ID_High;
       end
       else begin
          //get new matched item id
          Inc( BankAccount.baFields.baHighest_Matched_Item_ID);
          pT^.txMatched_Item_ID   := BankAccount.baFields.baHighest_Matched_Item_ID;
          pUPI^.txMatched_Item_ID := pT^.txMatched_Item_ID;

          //this is the original transaction so store details
          pUPI^.txOriginal_Reference                := pT^.txReference;
          pUPI^.txOriginal_Source                   := pT^.txSource;
          pUPI^.txOriginal_Type                     := pT^.txType;
          pUPI^.txOriginal_Cheque_Number            := pT^.txCheque_Number;
          pUPI^.txOriginal_Amount                   := pT^.txAmount;
          pUPI^.txOriginal_Forex_Conversion_Rate    := pT^.txForex_Conversion_Rate    ;
  //            pUPI^.txOriginal_Foreign_Currency_Amount  := pT^.txForeign_Currency_Amount  ;
          pUPI^.txCore_Transaction_ID               := pT^.txCore_Transaction_ID;
          pUPI^.txCore_Transaction_ID_High          := pT^.txCore_Transaction_ID_High;

          // -----------------------------------------------------------------

          pT^.txOriginal_Reference                  := pT^.txReference;
          pT^.txOriginal_Source                     := pT^.txSource;
          pT^.txOriginal_Type                       := pT^.txType;
          pT^.txOriginal_Cheque_Number              := pT^.txCheque_Number;
          pT^.txOriginal_Amount                     := pT^.txAmount;
          pT^.txOriginal_Forex_Conversion_Rate      := pT^.txForex_Conversion_Rate;

  //            pT^.txOriginal_Foreign_Currency_Amount    := pT^.txForeign_Currency_Amount  ;
       end;
       //log info the manual match done and original entry adjusted
       sMsg := 'Matched ref ' + GetFormattedReference( pT) +
               ' ' +  MakeAmount( pT.Statement_Amount) +
               ' on ' + bkDate2Str( pT^.txDate_Effective) +
               ' with ' + GetFormattedReference( pUPI) +
               ' ' + MakeAmount( pUPI.Statement_Amount) +
               ' on ' + bkDate2Str( pUPI^.txDate_Effective)+
               ' Original Entry adjusted to ' + BankAccount.CurrencySymbol + MakeAmount( Diff);
       LogUtil.LogMsg( lmInfo, UnitName, sMsg);

       //*** Flag Audit ***
       sMsg := Format('%s (AuditID=%d)',[sMsg, pT.txAudit_Record_ID ]);
       MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                         pUPI^.txAudit_Record_ID,
                                         aaNone,
                                         sMsg);

       //update the original transaction
       //Removes any dissection in transaction
       Dump_Dissections( pT );
       //remove any coding information
       pT^.txAccount    := '';
       //Adjust amount of matched transaction
       pT.Statement_Amount := Diff;
       pT^.txGST_Class  := 0;
       pT^.txGST_Amount := 0;


       pUPI^.txTransfered_To_Online := False;
       pT^.txTransfered_To_Online := False;

       //Details from matched transaction have been transfered to the UE Transaction
       //Amount has been adjusted on matched transaction and call LoadWTLMaintainPos to reload
       //the WorkTranList and reload the UEList
       LoadWTLMaintainPos;
       tblCoding.Refresh;
       RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TfrmCoding.DoRecombineEntries;
var
  pT          : pTransaction_Rec;
  NewTrans    : pTransaction_Rec;
begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not StopEditingState(True) then exit;
    pT := WorkTranList.Transaction_At(ActiveRow-1);
  end;

  if ( pT^.txLocked) then
  begin
    HelpfulInfoMsg( 'You cannot recombine a finalised entry.',0);
    exit;
  end;

  if ( pt^.txDate_Transferred <> 0) then
  begin
    HelpfulInfoMsg( 'You cannot recombine an entry which has been transferred.', 0);
    exit;
  end;

  if not( pT^.txUPI_State in [ upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW]) then
  begin
    HelpfulInfoMsg( 'This is not a valid entry to recombine.  You can only '+
                     'recombine balancing entries.', 0);
    exit;
  end;

  if pT^.txDate_Presented = 0 then
    raise EInvalidCall.Create(Unitname + ': Trying to recombine entry with pres date = 0');

  NewTrans := RecombineEntriesFrm.RecombineEntry( BankAccount, pT);
  if Assigned( NewTrans) then
  begin
    LoadWorkTranList;
    RepositionOn( NewTrans);
    //application updates will have been locked by Recombine
    LockWindowUpdate( 0);
    tblCoding.AllowRedraw := True;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetOrClearTransferDate(SetDate : boolean);
//Sets or clears the Transfer Date according to the SetDate parameter.
//A non-zero Transfer Date indicates the transaction has been transfered.
var
   i : Integer;
   PeriodList: TDateList;
   Index: Integer;
begin
   //Show warning if ForEx account
   if Assigned(AdminSystem) or (MyClient.clFields.clDownload_From <> dlAdminSystem) then
     if BankAccount.IsAForexAccount and (not SetDate) and (not UpdateExchangeRates) then exit;

   for i := 0 to Pred( WorkTranList.ItemCount ) do
   begin
     with WorkTranList.Transaction_At( i )^ do
     begin
       if SetDate then
       begin
         if ( txDate_Transferred = 0 ) then
         begin
           txDate_Transferred := CurrentDate;
           txForex_Conversion_Rate := BankAccount.Default_Forex_Conversion_Rate(txDate_Effective);
         end;
       end
       else
       begin //Clears date
         txDate_Transferred := 0;
         txForex_Conversion_Rate := 0
       end;
     end;
   end;

   PeriodList := GetPeriodsBetween(TranDateFrom, TranDateTo, True);

   for Index := 0 to Length(PeriodList) -1 do
   begin
     BankAccount.baFinalized_Exchange_Rate_List.AddExchangeRate(PeriodList[Index], BankAccount.Default_Forex_Conversion_Rate(PeriodList[Index]));
   end;

   If not SetDate then AutoCodeEntries( MyClient, BankAccount, AllEntries, TranDateFrom, TranDateTo );
   tblCoding.Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TfrmCoding.DoClearTransferDate;
//Clears Transfer flags
begin
   if ( WorkTranList.ItemCount = 0 ) then
     exit;

   SetOrClearTransferDate( False );
   //re apply default GST when flags cleared
   ApplyDefaultGST( false);
   LogUtil.LogMsg(lmInfo,UnitName,'Transfer Flags Cleared');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TfrmCoding.DoSetTransferDate;
//Sets the transfer flags
begin
   if ( WorkTranList.ItemCount = 0 ) then
     exit;

   SetOrClearTransferDate( True );
   LogUtil.LogMsg(lmInfo,UnitName,'Transfer Flags Set to ' + bkDate2Str( CurrentDate));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddOutstandingCheques;
//Adds Outstanding Cheques
begin
  if IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome] then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add outstanding cheques.',0);
    exit;
  end;
  if AddUnpresentedCheques(BankAccount, TranDateFrom, TranDateTo) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddOutstandingDeposits;
//Adds Outstanding Deposits
begin
  if IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome] then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add outstanding deposits.',0);
    exit;
  end;
  if AddOutstandingDeposits(BankAccount, TranDateFrom, TranDateTo) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddOutstandingWithdrawals;
//Adds Outstanding Withdrawals
begin
  if IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome] then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add outstanding withdrawals.',0);
    exit;
  end;
  if AddOutstandingWithdrawals(BankAccount, TranDateFrom, TranDateTo) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddInitialCheques;
//Adds Initial Cheques
begin
  if (IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add initial cheques.',0);
    exit;
  end;
  if (IsLocked(TranDateFrom - 1, TranDateFrom -1) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('You have locked the first accounting period.  You cannot add initial cheques.',0);
    exit;
  end;
  if AddInitialCheques(BankAccount, TranDateFrom, TranDateTo) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddInitialDeposits;
//Adds Initial Cheques
begin
  if (IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add initial deposits.',0);
    exit;
  end;
  if (IsLocked(TranDateFrom - 1, TranDateFrom -1) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('You have locked the first accounting period.  You cannot add initial deposits.',0);
    exit;
  end;
  if AddOutstandingDeposits(BankAccount, TranDateFrom, TranDateTo, True) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoAddInitialWithdrawals;
//Adds Initial Cheques
begin
  if (IsLocked(TranDateFrom, TranDateTo) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('This Coding Period contains locked entries.  You cannot add initial withdrawals.',0);
    exit;
  end;
  if (IsLocked(TranDateFrom - 1, TranDateFrom -1) in [ltAll, ltSome]) then
  begin
    HelpfulInfoMsg('You have locked the first accounting period.  You cannot add initial withdrawals.',0);
    exit;
  end;
  if AddOutstandingWithdrawals(BankAccount, TranDateFrom, TranDateTo, True) then
  begin
    LoadWorkTranList;
    tblCoding.ActiveRow := WorkTranList.ItemCount;
    tblCoding.Refresh;
    RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(*
procedure TfrmCoding.DoRateLookup;
Var
  pT : pTransaction_Rec;
  FCode, LCode : String[ 3 ];
  F : TExchangeRateLookupForm;
begin
  LCode := MyClient.clExtra.ceLocal_Currency_Code;
  FCode := BankAccount.baFields.baCurrency_Code;

  if ( LCode = FCode ) then exit;

  if not ValidDataRow(tblCoding.ActiveRow) then exit;
  pT   := WorkTranList.Transaction_At( tblCoding.ActiveRow - 1);
  if pT.txLocked then
    Exit;
  if pT.txDate_Transferred <> 0 then
    Exit;

  F := TExchangeRateLookupForm.Create( Application );
  Try
    { Public declarations }
    F.LocalCurrency           := LCode                        ;
    F.ForeignCurrency         := FCode                        ;
    F.AsAt                    := pT.txDate_Effective          ;
    F.Forex_Source            := pT.txForex_Source            ;
    F.Forex_Description       := pT.txForex_Description       ;
    F.Forex_Conversion_Rate   := pT.txForex_Conversion_Rate   ;
    F.Foreign_Currency_Amount := pT.txForeign_Currency_Amount;
    F.DocumentDate            := pT.Forex_Document_Date;
    F.Date_Button_Visible     := True;
    F.Forex_Info              := BankAccount.baForex_Info;

    if F.ShowModal = mrOK then
    Begin { Apply Selection }
      pT.Forex_Source          := F.Forex_Source          ;
      pT.Forex_Description     := F.Forex_Description     ;
      pT.Forex_Conversion_Rate := F.Forex_Conversion_Rate ;
      pT.Forex_Document_Date   := F.DocumentDate;
      pT.Forex_Edited          := False;
    End;
    RedrawRow;
  Finally
    F.Free;
  End;
end;
*)

procedure TfrmCoding.DoRecalculateGST;
//Iterate through transactions recalculating GST where transaction not locked.
//Lock set by GST Finalised

//The gst will also be set to the default for the chart for memorisations
var
  i : Integer;
  Dissection : pDissection_Rec;
  sMsg       : string;
  AllTransferred : boolean;
begin
   if IsLocked(TranDateFrom, TranDateTo) = ltAll then begin
     HelpfulInfoMsg( Localise( FCountry, 'All Entries have been finalised.  You cannot recalculate GST for finalised entries.' ), 0 );
     Exit;
   end;

   AllTransferred := true;
   for i := 0 to Pred(WorkTranList.ItemCount ) do begin
      With WorkTranList.Transaction_At( i )^ do begin
         if txDate_Transferred = 0 then begin
            AllTransferred := false;
            Break;
         end;
      end;
   end;
   if AllTransferred then begin
     HelpfulInfoMsg( Localise( FCountry, 'All Entries have been transferred.  You cannot recalculate GST for transferred entries.' ), 0 );
      Exit;
   end;

   for i := 0 to Pred(WorkTranList.ItemCount ) do begin
      With WorkTranList.Transaction_At( i )^ do begin

         if txLocked then continue;
         if ( txDate_Transferred <> 0) then continue;

         //if transaction is memorised override gst anyway.  If entry not edited then autocode
         //will correct to memorisation anyway.

         //is transaction a dissection
         If ( txFirst_Dissection = NIL ) then begin
//            CalculateGST( MyClient, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount );
            CalculateGST( MyClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
            txGST_Has_Been_Edited := false;
         end
         else begin
            Dissection := txFirst_Dissection;
            while Dissection <> nil do begin
               with Dissection^ do begin
//                 CalculateGST( MyClient, txDate_Effective, dsAccount, dsAmount, dsGST_Class, dsGST_Amount );
                 CalculateGST( MyClient, txDate_Effective, dsAccount, Local_Amount, dsGST_Class, dsGST_Amount );
                 dsGST_Has_Been_Edited := false;
                 Dissection := dsNext;
               end;
            end;
         end;
      end;
   end;
   //now run autocode for these entries
   AutoCodeEntries( MyClient, BankAccount, AllEntries, TranDateFrom, TranDateTo);
   LoadWTLMaintainPos;
   tblCoding.Refresh;
   //Info Msg for user
   sMsg := Localise( FCountry, 'Recalculate GST Completed.' );
   HelpfulInfoMsg( sMsg ,0);
   LogUtil.LogMsg(lmInfo,UnitName,sMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoNewAmount;
var
   pT          : pTransaction_Rec;
   pU          : pUE;
   Amount      : Double;
   OldAmount   : Money;
   OldForexAmount : Money;
   NeedPassword : boolean;
begin
   with tblCoding do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not StopEditingState(True) then Exit;
      pT := WorkTranList.Transaction_At(ActiveRow-1);
   end;
   if pT^.txLocked then exit;  //GST Finalised
   if pT^.txDate_Transferred <> 0 then begin
     HelpfulInfoMsg('You cannot edit an entry once it has been transferred to your accounting system', 0);
     Exit;
   end;
   with pT^ do begin
      //need a password by default
      NeedPassword := true;
      //dont need if unpresented item
      if ( txDate_Presented = 0) then NeedPassword := false;
      //test historical entries
      if ( txSource in [ orHistorical, orMDE]) then begin
         case txUPI_State of
            //dont need if is a historical entry that is not matched, balancing, or reversing
            upNone : NeedPassword := false;
         end;
      end;
      //This needs a password, unless it is unpresented or was entered via HDE
      if ( NeedPassword) then begin
         if not ((AskYesNo('Change Amount?','Are you sure you want to alter the amount of this entry?',DLG_NO,0) = DLG_YES)
                  and (EnterPassword('Change Amount','AM0UNT',0, true, false))) then
            Exit;
      end;
      //get new amount
//      OldAmount      := txAmount;
//      OldForexAmount := txForeign_Currency_Amount;
      OldForexAmount := txAmount;

      Amount := Money2Double( pT.Statement_Amount );

      with TdlgNewAmount.Create(Application.MainForm) do begin
         try
           AllowNegativeValues := not (pT^.txUPI_State in [ upUPC, upUPD, upUPW]);
           IsCr := (pT^.txUPI_State in [upUPD]);

           if not Execute(Amount) then
             Exit;
         finally
            Free;
         end;
      end;

      pT.Statement_Amount := Double2Money( Amount );

      pT.txTransfered_To_Online := False;

      if pT.IsDissected then
      begin
        if not DissectEntry( pT, BankAccount.baFields.baNotes_Always_Visible, True, BankAccount,
                             (Money2Double(OldForexAmount) <> Amount) ) then
        begin
//          txForeign_Currency_Amount := OldForexAmount;
//          txAmount := OldAmount;
          txAmount := OldForexAmount;
          HelpfulInfoMsg('The transaction amount has been changed back.',0);
          Exit;
        end;
      end;
      SetQuantitySign(False);
      //Log change
      if fIsForex then
      begin
//        LogUtil.LogMsg( lmInfo, UnitName, 'Foreign Currency Amount Changed from '+ MakeAmount( OldForexAmount)+' to '+ MakeAmount( txForeign_Currency_Amount )+
        LogUtil.LogMsg( lmInfo, UnitName, 'Foreign Currency Amount Changed from '+ MakeAmount( OldForexAmount)+' to '+ MakeAmount( txAmount )+
                                        ' for trans '+ bkDate2Str(txDate_Effective)+' '+ GetFormattedReference( pT));
      end
      else
      begin
        LogUtil.LogMsg( lmInfo, UnitName, 'Amount Changed from '+ MakeAmount( OldForexAmount)+' to '+ MakeAmount( txAmount)+
                                        ' for trans '+ bkDate2Str(txDate_Effective)+' '+ GetFormattedReference( pT));
      end;
      
      // Update UE List with new amount
      if Assigned( UEList) then
      begin
        pU := UEList.FindUEByPtr( pT );
        if Assigned(pU) then pU.Amount := pT.Statement_Amount;
      end;
      LoadWTLMaintainPos;
   end;

   tblCoding.Refresh;
   RefreshHomepage([HPR_ExchangeGainLoss_Message]);
end;

procedure TfrmCoding.DoNewJournal;
var pt: pTransaction_Rec;
    EffDate: TStDate;
    h: Integer;
    jA: Integer;
begin
   with tblCoding do begin

      if not StopEditingState(True) then
         Exit;

      EffDate := TranDateTo;

      case Bank_Account.baFields.baAccount_Type of
         btCashJournals :  h := BKH_Cash_journals;
         btAccrualJournals :  h := BKH_Accrual_journals;
         btGSTJournals : h := BKH_GST_journals;
         btStockJournals :  h := BKH_Stock_Adjustment_Journals;
         btYearEndAdjustments : h := BKH_Year_end_adjustment_journals;
         else h := 0;
      end;
      pt := nil;
      if SelectJournal(Bank_Account.baFields.baAccount_Type, Bank_Account, EffDate, pt,jA, h, true) <> mrok then
         Exit;

      //if RejectJournalDate(EffDate) then
      //   Exit;

      AdjustDateRange(EffDate);
      LoadWorkTranList;

      if RepositionOn(pt) then
         DoDissection(jA);

   end;
end;

//------------------------------------------------------------------------------
procedure TFrmCoding.DoDeleteTrans;
var
   pT             : pTransaction_Rec;
   pCancelled     : pTransaction_Rec;
   pCurrTran      : pTransaction_Rec;
   pNewTrans      : pTransaction_Rec;
   TransRef       : string;
   TransAmt       : Money;
   NeedsPassword  : Boolean;
   S              : string;
   DelRange       : Word;
   DeleteList     : TSeqList;
   RevDate        : integer;
   DeleteConfirmed: boolean;
   d, m, y, BOM, EOM : integer;
   i              : integer;
   NewState       : byte;
   sMsg: string;
   AuditId: integer;
   AuditType: TAuditType;
   DeletedTrans: pDeleted_Transaction_Rec;
begin
   with tblCoding do
   begin
     if not ValidDataRow(ActiveRow) then exit;
     if not StopEditingState(True) then exit;
     pT := WorkTranList.Transaction_At(ActiveRow-1);
   end;

   if isJournal then
   begin
     DoDeleteJournal(PT);
     Exit;
   end;


   with pT^ do
   begin
      //store ref and amount so can use when pT disposed of
      TransRef        := GetFormattedReference( pT);
      TransAmt        := txAmount;
      NeedsPassword   := false;

      //see if transaction is locked or transferred, if it is a UPC/UPD ask user
      //if the want to cancel it.
      if txLocked or ( txDate_Transferred <> 0) then
      begin
         S := 'You cannot delete this transaction because:'#13#13;
         if ( pT^.txDate_Transferred <> 0) then
            S := S + 'It has been transferred to your main accounting system.'#13;
         if ( pT^.txLocked) then
            S := S + 'It belongs to a finalised period.';

         case txUPI_State of
            upUPC, upUPD, upUPW :
            begin
               //deleting a locked unpresented item
               //Ask if want to create a balancing transaction
               S := S + #13#13 + 'Do you want to create a reversing entry and '+
                                 'mark the existing unpresented item as cancelled?';
               if not (AskYesNo( 'Cancel Unpresented Item', S, DLG_NO, 0) = DLG_YES) then
                  exit;

               tblCoding.AllowRedraw := false;
               //create a balancing transaction, ask user for date
               RevDate := ReversingEntryDetailsFrm.GetReversingEntryDate( BankAccount, pT);
               if ( RevDate > 0) then begin
                  //get new match id
                  Inc( BankAccount.baFields.baHighest_Matched_Item_ID);
                  //mark existing UPI as matched
                  txMatched_Item_ID := BankAccount.baFields.baHighest_Matched_Item_ID;
                  txDate_Presented  := RevDate;
                  case txUPI_State of
                     upUPC : txUPI_State := upReversedUPC;
                     upUPD : txUPI_State := upReversedUPD;
                     upUPW : txUPI_State := upReversedUPW;
                  end;

                  //create reversing transaction

                  pNewTrans                    := BankAccount.baTransaction_List.New_Transaction;

                  pNewTrans^.txType            := txType;
                  pNewTrans^.txSource          := orGeneratedRev;
                  case txUPI_State of
                     upReversedUPC : pNewTrans^.txUPI_State := upReversalOfUPC;
                     upReversedUPD : pNewTrans^.txUPI_State := upReversalOfUPD;
                     upReversedUPW : pNewTrans^.txUPI_State := upReversalOfUPW;
                  end;
                  pNewTrans^.txDate_Effective  := RevDate;
                  pNewTrans^.txDate_Presented  := RevDate;
                  pNewTrans^.txCheque_Number   := txCheque_Number;
                  pNewTrans^.txReference       := txReference;
                  pNewTrans^.txAmount          := -1 * txAmount;

                  pNewTrans^.txForex_Conversion_Rate   := txOriginal_Forex_Conversion_Rate       ;
//                  pNewTrans^.txForeign_Currency_Amount := -1 * txOriginal_Foreign_Currency_Amount     ;

                  pNewTrans^.txBank_Seq        := BankAccount.baFields.baNumber;
                  pNewTrans^.txMatched_Item_ID := txMatched_Item_ID;
                  pNewTrans^.txSF_Member_Account_ID:= -1;
                  pNewTrans^.txSF_Fund_ID          := -1;

                  pNewTrans^.txCore_Transaction_ID := txCore_Transaction_ID;
                  pNewTrans^.txCore_Transaction_ID_High := txCore_Transaction_ID_High;

                  txCore_Transaction_ID := 0;
                  txCore_Transaction_ID_High := 0;

                  txTransfered_To_Online := False;

                  BankAccount.baTransaction_List.Insert_Transaction_Rec( pNewTrans);
                  sMsg := 'Cancelled UPC Transaction ' + TransRef;
                  LogUtil.LogMsg(lmInfo,UnitName, sMsg);

                  //*** Flag Audit ***
                  sMsg := Format('%s (AuditID=%d)',[sMsg, pT.txAudit_Record_ID ]);
                  MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                                    pNewTrans^.txAudit_Record_ID,
                                                    aaNone,
                                                    sMsg);
               end;
               //reload and reposition
               LoadWTLMaintainPos;
               tblCoding.AllowRedraw := True;
               tblCoding.Refresh;
               RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
               exit;
            end;

            upMatchedUPC, upMatchedUPD, upMatchedUPW :
            begin
               //item can be handled by normal unmatched code below so do nothing
               ;
            end;
         else
           HelpfulInfoMsg( S, 0);
           exit;
         end;
      end;  //transferred or locked

      //see what state of transaction is
      Case txUPI_State of
         upNone : begin
            NeedsPassword  := ( txDate_Presented <> 0) and ( txSource = orBank);
         end;

         upUPC : begin
            //If the item is an unpresented cheque it can be deleted.  There are two methods
            //   1.  Delete individual transaction
            //   2.  Delete as part of a range.  (Only UPC's will be deleted)
            //
            //Ask User if they want to delete a range or one entry
            with TdlgDelCheque.Create(Application.MainForm) do begin
               try
                  DelRange := Execute;
               finally
                  Free;
               end;
            end;

            Case DelRange of
               DLG_CANCEL :  exit;
               DLG_ENTRY     : begin
                  // Change Active Row to transaction above
                  // Changing Active Row triggers table redraw irrespective of
                  // setting of AllowRedraw
                  // If we do this after DelFreeItem ReadCellForPaint will crash
                  with tblCoding do
                  begin
                    if ActiveRow > 1 then
                      ActiveRow := ActiveRow - 1;
                  end;
                  tblCoding.AllowRedraw := False;
                  AuditId := pT^.txAudit_Record_ID;

                  if RecordDeletedTransactionData(BankAccount, pT) then
                  begin
                    DeletedTrans := Create_Deleted_Transaction_Rec(pT, CurrUser.Code);

                    try
                      BankAccount.baTransaction_List.DelFreeItem( pT );

                      BankAccount.baDeleted_Transaction_List.Insert(DeletedTrans); 
                    except
                      Dispose_Deleted_Transaction_Rec(DeletedTrans);
          
                      raise;
                    end;
                  end
                  else
                  begin
                    BankAccount.baTransaction_List.DelFreeItem( pT );
                  end;

                  LoadWTLMaintainPos;
                  tblCoding.AllowRedraw := True;
                  sMsg := 'Deleted UPC Transaction ' + TransRef;
                  LogUtil.LogMsg(lmInfo,UnitName,sMsg);

                  //*** Flag Audit ***
                  sMsg := Format('%s (AuditID=%d)',[sMsg, AuditId]);
                  MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                                    AuditId,
                                                    aaNone,
                                                    sMsg);
                  RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
                  exit;
               end;
               DLG_RANGE :  begin
                  DeleteList := TSeqList.Create;
                  try
                     //Ask user for range of cheque numbers
                     //The deleting will occur within OUTSTAND.PAS
                     if EnterChequeRangeToDelete( BankAccount,
                                                  TranDateFrom,
                                                  TranDateTo,
                                                  DeleteList ) then begin
                        Application.ProcessMessages;
                        tblCoding.AllowRedraw := False;
                        try
                           If DeleteChequeRange( BankAccount , DeleteList, TranDateFrom, TranDateTo ) then begin
                              LoadWTLMaintainPos;
                           end;
                        finally
                           tblCoding.AllowRedraw := True;
                           tblCoding.Refresh;
                           RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
                        end;
                     end;
                  finally
                     DeleteList.Free;
                  end;
                  exit;
               end;
            end;
         end;

         upUPD, upUPW : begin
            NeedsPassword := false;
         end;

         upMatchedUPC, upMatchedUPD, upMatchedUPW : begin
            //the may be a moved cheque or a matched generated transaction
            if txUPI_State = upMatchedUPC then
               NewState := upUPC
            else if txUPI_State = upMatchedUPW then
               NewState := upUPW
            else
               NewState := upUPD;

            if not (AskYesNo( 'Un-match Entry?',
                              'Un-match this entry and reinstate the bank statement entry on '+
                              bkDate2Str(txDate_Presented) +
                              ' with reference ' + MakeCodingRef( txOriginal_Reference) +
                              '?'#13#13+

                              'The unpresented item will be reinstated on ' +
                              bkDate2str( txDate_Effective) +
                              ' with reference ' + upNames[ NewState] + MakeCodingRef( txReference)
                              , DLG_NO,
                              0 )=DLG_YES) then
            exit;
            //make sure that the original effective date is not inside a finalised month
            StDateToDMY( txDate_Presented, d, m, y);
            BOM := DMYToStDate(1,m,y,bkDateEpoch);
            EOM := DMYToStDate( DaysInMonth( m,y, BKDateEpoch), m, y, BKDateEpoch);
            if FINALISE32.IsLocked( BOM, EOM) in [ltAll, ltSome] then begin
               HelpfulInfoMsg( 'The entry cannot be reinstated on '+
                                  bkDate2Str(txDate_Presented)+ ' because finalised entries '+
                                  'exist in the same month.',0);
               exit;
            end;

            //reinstating transaction
            tblCoding.AllowRedraw := False;
            AuditId := pT^.txAudit_Record_ID;

           //Delete original transaction
            if RecordDeletedTransactionData(BankAccount, pT) then
            begin
              DeletedTrans := Create_Deleted_Transaction_Rec(pT, CurrUser.Code);

              try
                BankAccount.baTransaction_List.Delete( pT );

                BankAccount.baDeleted_Transaction_List.Insert(DeletedTrans);
              except
                Dispose_Deleted_Transaction_Rec(DeletedTrans);

                raise;
              end;
            end
            else
            begin
              BankAccount.baTransaction_List.Delete( pT );
            end;

            //*** Flag Audit ***
            MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                              AuditId,
                                              aaNone,
                                              sMsg);
            //recreate the bank entry

            pNewTrans := BankAccount.baTransaction_List.New_Transaction;
            pNewTrans^.txType           := txOriginal_Type;
            pNewTrans^.txSource         := txOriginal_Source;
            pNewTrans^.txDate_Effective := txDate_Presented;
            pNewTrans^.txDate_Presented := txDate_Presented;
            pNewTrans^.txReference      := txOriginal_Reference;
            pNewTrans^.txCheque_Number  := txOriginal_Cheque_Number;
            pNewTrans^.txAmount         := txAmount;

            pNewTrans^.txForex_Conversion_Rate   := txOriginal_Forex_Conversion_Rate       ;
//            pNewTrans^.txForeign_Currency_Amount := txOriginal_Foreign_Currency_Amount     ;

            pNewTrans^.txBank_Seq       := BankAccount.baFields.baNumber;
            pNewTrans^.txStatement_Details := txStatement_Details;
            pNewTrans^.txGL_Narration   := txStatement_Details; // case 529, original Naration..
            pNewTrans^.txSF_Member_Account_ID:= -1;
            pNewTrans^.txSF_Fund_ID          := -1;
            if ( txMatched_Item_Id <> 0) then begin
               //is not the original entry so store original details
               pNewTrans^.txOriginal_Type          := txOriginal_Type;
               pNewTrans^.txOriginal_Source        := txOriginal_Source;
               pNewTrans^.txOriginal_Reference     := txOriginal_Reference;
               pNewTrans^.txOriginal_Amount        := txOriginal_Amount;
               pNewTrans^.txOriginal_Cheque_Number := txOriginal_Cheque_Number;
               pNewTrans^.txOriginal_Forex_Conversion_Rate   := txOriginal_Forex_Conversion_Rate       ;
//               pNewTrans^.txOriginal_Foreign_Currency_Amount := txOriginal_Foreign_Currency_Amount     ;
               pNewTrans^.txMatched_Item_Id        := txMatched_Item_Id;
            end;

            pNewTrans^.txCore_Transaction_ID := txCore_Transaction_ID;
            pNewTrans^.txCore_Transaction_ID_High := txCore_Transaction_ID_High;

            txCore_Transaction_ID := 0;
            txCore_Transaction_ID_High := 0;

            //update items specific to upc/upd
            if txUPI_State = upMatchedUPC then begin
               //set upi states
               if txMatched_Item_Id = 0 then
                  pNewTrans^.txUPI_State := upNone
               else
                  pNewTrans^.txUPI_State := upBalanceOfUPC;
               pT^.txUPI_State        := upUPC;
               //set upc entry type
               pT^.txType             := MyClient.ChequeEntryType;
            end
            else if txUPI_State = upMatchedUPW then begin
               //set upi states
               if txMatched_Item_Id = 0 then
                  pNewTrans^.txUPI_State := upNone
               else
                  pNewTrans^.txUPI_State := upBalanceOfUPW;
               pT^.txUPI_State := upUPW;
               //set upw entry type
               pT^.txType := MyClient.WithdrawalEntryType;
            end
            else begin
               //set upi states
               if txMatched_Item_Id = 0 then
                  pNewTrans^.txUPI_State := upNone
               else
                  pNewTrans^.txUPI_State := upBalanceOfUPD;
               pT^.txUPI_State := upUPD;
               //set upd entry type
               pT^.txType      := MyClient.DepositEntryType;
            end;
            //mark the UPC as being unpresented, may have originally been
            //a moved cheque so need to set source and type
            pT^.txDate_Presented         := 0;
            pT^.txSource                 := orGenerated;
            pT^.txOriginal_Type          := 0;
            pT^.txOriginal_Source        := 0;
            pT^.txOriginal_Reference     := '';
            pT^.txOriginal_Cheque_Number := 0;
            pT^.txMatched_Item_ID        := 0;

            
            txTransfered_To_Online := False;
            pT^.txTransfered_To_Online := False;

            //Insert transactions
            BankAccount.baTransaction_List.Insert_Transaction_Rec( pNewTrans);
            BankAccount.baTransaction_List.Insert_Transaction_Rec( pT );

            LoadWTLMaintainPos;  //reload and reposition
            //position on new transaction
            RepositionOn( pT);
            tblCoding.AllowRedraw := True;
            tblCoding.Refresh;
            sMsg := 'Unmatched Transaction ' + TransRef +
                    bkDate2Str( pT^.txDate_Effective) +
                    '  Original Ref ' + GetFormattedReference( pNewTrans) +
                    bkDate2str( pNewTrans^.txDate_Effective);
            LogUtil.LogMsg( lmInfo, UnitName, sMsg);

            //*** Flag Audit ***
            sMsg := Format('%s (AuditID=%d)',[sMsg, pNewTrans.txAudit_Record_ID]);
            MyClient.ClientAuditMgr.FlagAudit(arUnpresentedItems,
                                              pT.txAudit_Record_ID,
                                              aaNone,
                                              sMsg);
            RefreshHomepage ([HPR_ExchangeGainLoss_Message]);

            exit;
         end;

         upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW : begin
            NeedsPassword := true;
         end;

         upReversedUPC, upReversedUPD, upReversedUPW : begin
            S := 'You must delete the reversing entry (on ' + bkDate2Str( pT^.txDate_Presented) +
                 ') before you can delete this entry.';
            HelpfulInfoMsg( S,0);
            exit;
         end;

         upReversalOfUPC, upReversalOfUPD, upReversalOfUPW : begin
            //can delete this entry and mark the cancelled item as unpresented
            S := 'Delete this reversing entry and mark the cancelled item as '+
                 'unpresented?';
            if not( AskYesNo( 'Delete Entry?', S, DLG_NO, 0) = DLG_YES) then exit;

            //Find the reversing entry. Search bank account for transaction
            //with same txMatched_id that is not the current entry
            pCancelled := nil;
            with BankAccount.baTransaction_List do begin
               for i := 0 to Pred( itemCount) do begin
                  pCurrTran := Transaction_At( i);
                  if ( pCurrTran^.txMatched_Item_ID = pT^.txMatched_Item_ID) and
                     ( pCurrTran <> pT) then begin
                     pCancelled := pCurrTran;
                     break;
                  end;
               end;
            end;
            if not Assigned( pCancelled) then begin
               HelpfulErrorMsg( 'Could not find the cancelled item. ' + ShortAppName +
                                'cannot proceed.' , 0);
               exit;
            end;
            tblCoding.AllowRedraw := false;
            //set type
            case pCancelled^.txUPI_State of
               upReversedUPC : pCancelled^.txUPI_State := upUPC;
               upReversedUPD : pCancelled^.txUPI_State := upUPD;
               upReversedUPW : pCancelled^.txUPI_State := upUPW;
            else
               raise EInvalidCall.CreateFmt( UnitName + ': Bad UPI State %d during delete reversing entry', [ pT^.txUPI_State]);
            end;
            //Clear presentation date
            pCancelled^.txDate_Presented := 0;
            //remove link
            pCancelled^.txMatched_Item_ID := 0;
            //Remove reversing entry from bank account
            AuditId := pT^.txAudit_Record_ID;
            AuditType := MyClient.ClientAuditMgr.GetTransactionAuditType(pT^.txSource,
                                                                         BankAccount.baFields.baAccount_Type);

            if RecordDeletedTransactionData(BankAccount, pT) then
            begin
              DeletedTrans := Create_Deleted_Transaction_Rec(pT, CurrUser.Code);

              try
                BankAccount.baTransaction_List.DelFreeItem( pT);

                BankAccount.baDeleted_Transaction_List.Insert(DeletedTrans); 
              except
                Dispose_Deleted_Transaction_Rec(DeletedTrans);
          
                raise;
              end;
            end
            else
            begin
              BankAccount.baTransaction_List.DelFreeItem( pT);
            end;

            //reload and reposition
            LoadWTLMaintainPos;
            tblCoding.AllowRedraw := True;
            tblCoding.Refresh;
            //log event
            sMsg := 'Deleted Cancelled UPI ' + TransRef;
            LogUtil.LogMsg(lmInfo,UnitName, sMsg);

            //*** Flag Audit ***
            MyClient.ClientAuditMgr.FlagAudit(AuditType,
                                              AuditId,
                                              aaNone,
                                              sMsg);
            RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
            exit;
         end;
      else
         //unknown upi state, raise an exception
         raise EInvalidCall.CreateFmt( UnitName + ': Unknown UPI State %d', [ txUPI_State]);
      end;

      //Ready to delete entry, see if need password from user
      if NeedsPassword then begin
         DeleteConfirmed := (AskYesNo( 'Delete Entry?', 'Are you sure you want to delete this entry?',
                      DLG_No,0 )=DLG_YES)
                  and EnterPassword('Delete Entry', 'D3L3T3', 0, true ,false);
      end
      else begin
         DeleteConfirmed := (AskYesNo( 'Delete Entry?', 'Are you sure you want to delete this entry?',
                      DLG_NO,0 )=DLG_YES);
      end;
      if not DeleteConfirmed then exit;
      //OK, the user really wants to remove this entry

      tblCoding.AllowRedraw := False;
      AuditId := pT^.txAudit_Record_ID;
      AuditType := MyClient.ClientAuditMgr.GetTransactionAuditType(pT^.txSource,
                                                                   BankAccount.baFields.baAccount_Type);

      if RecordDeletedTransactionData(BankAccount, pT) then
      begin
        DeletedTrans := Create_Deleted_Transaction_Rec(pT, CurrUser.Code);

        try
          BankAccount.baTransaction_List.DelFreeItem( pT );

          BankAccount.baDeleted_Transaction_List.Insert(DeletedTrans); 
        except
          Dispose_Deleted_Transaction_Rec(DeletedTrans);
          
          raise;
        end;
      end
      else
      begin
        BankAccount.baTransaction_List.DelFreeItem( pT );
      end;

      sMsg := 'Deleted Transaction '+ TransRef+' ' + MakeAmount( TransAmt);
      LogUtil.LogMsg(lmInfo,UnitName, sMsg);

      //*** Flag Audit ***
      MyClient.ClientAuditMgr.FlagAudit(AuditType,
                                        AuditId,
                                        aaNone,
                                        sMsg);

      LoadWTLMaintainPos;  //reload and reposition
      tblCoding.AllowRedraw := True;
      tblCoding.Refresh;
      RefreshHomepage ([HPR_ExchangeGainLoss_Message]);
   end;  //with pT^
end;

//------------------------------------------------------------------------------
procedure TfrmCoding.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell

//this routine is also used to pick up a delete on a dissection
var
  pT : pTransaction_Rec;
  FieldID : integer;
begin
   with tblCoding do begin
      if not ValidDataRow(ActiveRow) then exit;

      pT   := WorkTranList.Transaction_At(ActiveRow-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
      //see if this transaction is a dissected entry
      if ( FieldID = ceAccount) and ( pT^.txFirst_Dissection <> nil) then
      begin
        DoDeleteDissection( pT);
        Exit;
      end else


      if not StartEditingState then Exit;
      with ColumnFmtList.ColumnDefn_At(ActiveCol)^ do begin
         if (cdTableCell is TOvcTCString) then begin
            TEdit(cdTableCell.CellEditor).Text := '';
         end;
         if cdTableCell is TOvcTCPictureField then begin
            TOvcTCPictureFieldEdit( cdTableCell.CellEditor).AsString := '';
         end;
         if cdTableCell is TOvcTCNumericField then begin
           //setting by variant no longer seems to work in orpheus 4
           if TOvcNumericField( cdTableCell.CellEditor).DataType = nftDouble then
             TOvcNumericField( cdTableCell.CellEditor).AsFloat := 0.0
           else if TOvcNumericField( cdTableCell.CellEditor).DataType = nftLongInt then
             TOvcNumericField( cdTableCell.CellEditor).AsInteger := 0
           else
             TOvcNumericField( cdTableCell.CellEditor).AsVariant := 0;
         end;
      end;
      StopEditingState( True );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoDeleteDissection( pT : pTransaction_Rec);
//allows the user to delete all lines from a dissection without using the
//dissect dlg
begin
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

   if YesNoDlg.AskYesNo( 'Remove Dissection',
                         'Do you want to remove all of the dissection lines for this entry?',
                         dlg_no, 0) <> DLG_Yes then
     Exit;

   //dispose of all dissection lines
   Dump_Dissections( pT);
   //clear transaction details
   pT^.txCoded_By        := cbNotcoded;
   pT^.txGST_Class       := 0;
   pT^.txGST_Amount      := 0;
   pT^.txHas_Been_Edited := False;
   pT^.txGST_Has_Been_Edited := False;
   ClearSuperFundFields(pT);

   RedrawRow;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoDeleteJournal(pT: pTransaction_Rec);
var
  i: Integer;
begin
   if not assigned(pt) then
      Exit;
   if pT^.txLocked then
      Exit;
   if pT^.txDate_Transferred <> 0 then
      Exit;

   if YesNoDlg.AskYesNo( 'Delete Journal',
                         'Do you want to delete this Journal entry?',
                         dlg_no, 0) <> DLG_Yes then
      Exit;

   I := WorkTranList.IndexOf(pt);
   tblCoding.AllowRedraw := False;

   BankAccount.baTransaction_List.DelFreeItem( pT );

   LoadWorkTranList;
   tblCoding.AllowRedraw := True;
   tblCoding.Refresh;
   if (I < 0)
   or (I > WorkTranList.Last) then
     I := WorkTranList.Last;
   if ValidDataRow(I) then
      tblCoding.ActiveRow := Succ(I);

   //Audit journal delete for UK
   if (MyClient.clFields.clCountry = whUK) then
     SaveClient(false);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.LoadWorkTranList;
var
   pT  : pTransaction_Rec;
   i   : integer;
   bal : Money;
   Amount : Money;

   function IncludeTrans: Boolean;

      function FindText: Boolean;
      var I: Integer;
          APayee: TPayee;
          Job: PJob_Heading_Rec;
          pA: pAccount_Rec;

          function TestText(const Value: string):Boolean;
          begin
             Result := False;
             if Value = '' then
                Exit;
             Result := Pos(FSearchText, Uppercase(Value)) > 0;
          end;

          function TestInteger(const Value: Integer): Boolean;
          begin
             Result := False;
             if Value = 0 then
                Exit;
             Result := Pos(FSearchText, IntToStr(Value)) > 0;
          end;

          function TestMoney(const Value: Money): Boolean;
          begin
             Result := False;
             if Value = 0 then
                Exit;
             Result := Pos(FSearchText, MakeAmount(Value)) > 0;
          end;

          function TestDate(const Value: TstDate): Boolean;
          begin
             Result := False;
             if Value = 0 then
                Exit;
             Result := Pos(FSearchText, BKDate2Str(Value)) > 0;
          end;


      begin
          Result := true;
          for I := 0 to ColumnFmtList.ItemCount - 1 do begin

            if not ColumnFmtList.ColumnDefn_At(i).cdHidden then // Only do the columns that show..

            case ColumnFmtList.ColumnDefn_At(i).cdFieldID of
            //ceStatus :; Icon
            //ceNotesIcon      :; Not used
            //ceTaxInvoice     :; Tickbox
            //ceDocument :; Smarty Books ???

            ceEffDate : if TestDate(pT.txDate_Effective) then
               Exit;

            ceReference : if TestText(GetFormattedReference(pT)) then
               Exit;

            ceAnalysis : if TestText(pT.txAnalysis) then
               Exit;

            ceAccount : if TestText(pT.txAccount) then
               Exit;

            ceAmount : if TestMoney(pT.txAmount) then
               Exit;

            ceNarration : if TestText(pT.txGL_Narration) then
               Exit;

            ceOtherParty : if TestText(pT.txOther_Party) then
               Exit;

            ceParticulars : if TestText(pT.txParticulars) then
               Exit;

            cePayee : if TestInteger(pT.txPayee_Number)  then
               Exit;

            ceGSTClass : if TestText( GSTCALC32.GetGSTClassCode( MyClient, pT.txGST_Class)) then
               Exit;

            ceGSTAmount : if pT.txFirst_Dissection = nil then begin
                   if TestMoney(pT.txGST_Amount) then
                      Exit;
                end else begin
                   if TestMoney(GSTCalc32.GetGSTTotalForDissection(pT)) then
                      Exit;
                end;

            ceQuantity : if TestText( Quantity2Str(pT.txQuantity)) then
                Exit;

            ceEntryType : if TestText(GetFormattedEntryType(pT)) then
                Exit;

            cePresDate : if TestDate(pT.txDate_Presented) then
               Exit;

            ceCodedBy : if TestText(cbNames[pT.txCoded_By]) then
               Exit;

            ceStatementDetails :if TestText(pT.txStatement_Details) then
               Exit;

            ceBalance : if TestMoney(pT.txTemp_Balance ) then
               Exit;

            ceDescription,
            ceAltChartCode : if pT.txFirst_Dissection = nil then begin
                pA := MyClient.clChart.FindCode(pT.txAccount);
                if Assigned(pA) then case ColumnFmtList.ColumnDefn_At(i).cdFieldID of
                  ceDescription: if TestText(pA.chAccount_Description) then
                     Exit;
                   ceAltChartCode: if TestText(pA.chAlternative_Code) then
                     Exit;
                end;
            end;

            cePayeeName : if pT.txPayee_Number <> 0 then begin
                  APayee := MyClient.clPayee_List.Find_Payee_Number(pT.txPayee_Number);
                  if Assigned(APayee) then
                     if TestText(APayee.pdName) then
                        Exit;
               end;

            ceJob :if TestText(pt.txJob_Code ) then
               Exit;

            ceJobName : if (pT.txJob_code > '') then begin
                 Job := MyClient.clJobs.FindCode (pT.txJob_code);
                 if Assigned(Job) then
                   if TestText(Job.jhHeading) then
                        Exit;
              end;

            ceAction :if TestText(GetFormattedAction(pT)) then
               Exit;

            ceForexAmount: if TestMoney(pT.txAmount) then
               Exit;

            ceForexRate : if testText( FloatToStr(PT.Default_Forex_Rate)) then
               Exit;

            ceLocalCurrencyAmount : if TestMoney(pT.Local_Amount) then
               Exit;

            ceCoreTransactionId : if TestInteger(BKUTIL32.GetTransCoreID(pT)) then
               Exit;

            end;
          end;

           // Still here
          Result := false
      end;
   begin
      Result := False;
      case ShowAllTran of
      SHOW_ALL_TX :; // Cool
      SHOW_UNCODED_TX : if not IsUnCoded(pT) then
          Exit;
      SHOW_NOTES_TX : if not HasNotes(pT) then
          Exit;
      SHOW_UnreadNOTES_TX : if not HasUnreadNotes(pT) then
         Exit;
      SHOW_NoNOTES_TX : if HasNotes(pT) then
         Exit;
      end;
      if FSearchText > '' then
         if not Findtext then
            Exit;

      // Still Here...
      Result := true
   end;

begin
   MsgBar('Loading Transactions',true);
   try
     tblCoding.AllowRedraw := false;

     //destroy current list and recreate
     if Assigned(WorkTranList) then begin
        WorkTranList.DeleteAll;
        WorkTranList.Free;
     end;

     //assign a balance to all transactions, this field is not persistent
     bal := bankaccount.baFields.baCurrent_Balance;
     //Alter the balance to remove UPC and UPD values.
     //-ve = IF
     //+ve = OD
     for i := bankaccount.baTransaction_List.Last downto bankaccount.baTransaction_List.First do
     begin
       pT := bankaccount.baTransaction_List.Transaction_At( i );
//       if fIsForex then
//         Amount := pT.txForeign_Currency_Amount
//       else
         Amount := pT.txAmount;
       //dont update the balance if it is unknown
       if (bal <> Unknown) then
       begin
         if (pT^.txUPI_State in [upUPC,upReversedUPC,upReversalOfUPC, upUPD,upReversedUPD,upReversalOfUPD, upUPW,upReversedUPW,upReversalOfUPW]) then
           bal := bal + Amount;
       end;
     end;

     for i := bankaccount.baTransaction_List.Last downto bankaccount.baTransaction_List.First do
     begin
       pT := bankaccount.baTransaction_List.Transaction_At( i );
//       if fIsForex then
//         Amount := pT.txForeign_Currency_Amount
//       else
         Amount := pT.txAmount;

       pT.txTemp_Balance := bal;
       //dont update the balance if it is unknown
       if (bal <> Unknown) then
         bal := bal - Amount
     end;

    WorkTranList := TSorted_Transaction_List.Create(TranSortOrder);

     with BankAccount.baTransaction_List do begin
        for i := 0 to Pred( ItemCount ) do begin
           pT := Transaction_At(i);
           if ( pT^.txDate_Effective > TranDateTo ) then
              break;  //Date ordered so Won't faind any more

           if (pT^.txDate_Effective >= TranDateFrom)
           and (pT^.txDate_Effective <= TranDateTo) then begin
              //store balance so that we can determine the balance of the last transaction
              bal := pT^.txTemp_Balance;
              pT.txDate_Change := False; // make sure we trap the right one

              if IncludeTrans then
                WorkTranList.Insert(pT);
           end;
        end;
     end;
     if IsJournal then
        barCodingStatus.Panels[PANELBAL].Text := ''
     else
     if bal <> Unknown then
        barCodingStatus.Panels[PANELBAL].Text := 'Closing Balance ' + BankAccount.BalanceStr( Bal )
     else
        barCodingStatus.Panels[PANELBAL].Text := 'Closing Balance Unknown';

     //now that we have the transactions in the correct order recalculate the
     //balances based on the balance of the last transaction.  the balance is
     //meaningless if sorted by anything other than effective date, however
     //this looks better
     if ShowAllTran = SHOW_ALL_TX then begin
       //bal now holds the balance of the last transaction to be inserted
       for i := Pred( WorkTranList.ItemCount) downto 0 do
       begin
          pT := WorkTranList.transaction_at( i);
          pT.txTemp_Balance := bal;
//          if fIsForex then
//            Amount := pT.txForeign_Currency_Amount
//          else
            Amount := pT.txAmount;

          if (bal <> Unknown) then
            bal := bal - Amount;
       end;
     end;

     //Reload the unpresented entries list
     UEList.Free;
     UEList := nil;

//     if fIsForex then
//       UEList := MakeForeignCurrencyUEList(BankAccount)
//     else
       UEList := MakeUEList(BankAccount);

     tblCoding.RowLimit := Max( WorkTranList.ItemCount + 1, 2);
     SetTableAccess;
   finally
     tblCoding.AllowRedraw := true;
     Msgbar('',false);
     UpdateCodedCount;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.LoadWTLMaintainPos;
var
   pT : pTransaction_Rec;
   NewIndex,
   OldIndex : integer;
begin
   if ( WorkTranList.ItemCount > 0 ) then begin
      //save current trans pointer and reload then reposition
      //ActiveRow transaction pointer may not be valid due to
      //deletion of underlying transaction. eg UPC match
      NewIndex := -1;
      OldIndex := tblCoding.ActiveRow;
      try
         pT := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);
      except
         on ECorruptData do pT := nil;
         on EAccessViolation do pT := nil;
      end;

      LoadWorkTranList;

      if Assigned(pt) then
         NewIndex := WorkTranList.IndexOf(pT);

      if NewIndex = -1 then
         tblCoding.ActiveRow :=  Min(OldIndex, WorkTranList.ItemCount + 1)
      else
         tblCoding.ActiveRow := NewIndex+1;
   end else begin
       //no trans in current list, reload the transaction list
       LoadWorkTranList;
       tblCoding.ActiveRow := 1
   end;

end;
//------------------------------------------------------------------------------

function TfrmCoding.RepositionOn(pT: pTransaction_Rec): Boolean;
var
   NewIndex : integer;
begin
   Result := False;
   if not Assigned(pT) then
      Exit;
   NewIndex := WorkTranList.IndexOf(pT);
   if NewIndex = -1 then
      tblCoding.ActiveRow := 1
   else begin
      tblCoding.ActiveRow := NewIndex+1;
      Result := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormDestroy(Sender: TObject);
begin
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then FHint.ReleaseHandle;
      FHint.Free;
      FHint := nil;
   end;
   WorkTranList.Free;
   ColumnFmtList.Free;
   UEList.Free;
   SetLength( tmpBuffer, 0);   //free memory associated with temp buffer of char
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.InitController;
const
   KeyMapName = 'Grid';

begin
   with cntController.EntryCommands do begin
     {remove existing defaults which conflict}
     DeleteCommand(KeyMapName,VK_F2,0,0,0);
     DeleteCommand(KeyMapName,vk_delete,0,0,0);
     DeleteCommand(KeyMapName,72,$04,0,0);  {CTRL+H acting as delete}
     DeleteCommand(KeyMapName,72,$04 or $02, 0,0); {CTRL + SHIFT + H}
     DeleteCommand(KeyMapName,vk_Insert,0,0,0);
     {add our commands}
     if IsJournal then begin
        AddCommand(KeyMapName,$2E,$02,0,0,tcDeleteTrans);     {ctrl+delete}
     end else begin
        AddCommand(KeyMapName,VK_F3,0,0,0,tcPayeeLookup);
        AddCommand(KeyMapName,80,$04,0,0,tcPayeeLookup);      {ctrl+P}
        if Assigned(AdminSystem)
        or (not  MyClient.clExtra.ceBlock_Client_Edit_Mems) then begin
           AddCommand(KeyMapName,VK_F4,0,0,0,tcMemorise);
           AddCommand(KeyMapName,77,$04,0,0,tcMemorise);         {ctrl+M}
        end;

        AddCommand(KeyMapName,VK_F5,0,0,0,tcJobs);
        AddCommand(KeyMapName,VK_F7,0,0,0,tcGSTLookup);
        AddCommand(KeyMapName,$2E,$04,0,0,tcDeleteTrans);     {ctrl+delete}
        AddCommand(KeyMapName,73,$04,0,0,tcUnpresentedItems); {ctrl+I}
        AddCommand(KeyMapName,$2D,$04,0,0,tcInsertUPC);       {ctrl+insert}
     end;

     AddCommand(KeyMapName,VK_F2,0,0,0,tcLookup);
     AddCommand(KeyMapName,VK_F6,0,0,0,ccTableEdit);
     AddCommand(KeyMapName,VK_F8,0,0,0,tcNextUncoded);
     AddCommand(KeyMapName,VK_F9,0,0,0,tcSort);
     AddCommand(KeyMapName,VK_F11,0,0,0,tcEditSuperFields);
     AddCommand(KeyMapName,VK_F12,0,0,0,tcNextNote);
     Addcommand(KeyMapName,VK_DELETE,0,0,0,tcDeleteCell);

     AddCommand(KeyMapName,VK_MULTIPLY,0,0,0,tcEditAll);   {* - NumPad}
     AddCommand(KeyMapName,VK_DIVIDE,0,0,0,tcDissect);     {/ - NumPad}
     AddCommand(KeyMapName,VK_ADD,0,0,0,tcDitto);          {+ - NumPad}
     AddCommand(KeyMapName,56,$02,0,0,tcEditAll);          {Shift+8}
     AddCommand(KeyMapName,191,0,0,0,tcDissect);           {/}
     Addcommand(KeyMapName,187,0,0,0,tcAmount);            {=}

     AddCommand(KeyMapName,65,$04,0,0,tcEditAll);          {ctrl+A}
     AddCommand(KeyMapName,66,$04,0,0,tcGotoNotes);        {ctrl+B}
     //Windows Key                                         //windows copy CTRL+C
     AddCommand(KeyMapName,68,$04,0,0,tcDissect);          {ctrl+D}
     AddCommand(KeyMapName,69,$04,0,0,tcEditAll);          {ctrl+E}
     AddCommand(KeyMapName,70,$04,0,0,tcFind);             {ctrl+f}
     //AddCommand(KeyMapName,70,$04 or $02,0,0,tcEditSuperFields);    {ctrl + shift + f}
     AddCommand(KeyMapName,71,$04,0,0,tcNextUncoded);      {ctrl+G}
     AddCommand(KeyMapName,72,$04,0,0,tcCopySDToNarration);{ctrl+H}
     AddCommand(KeyMapName,72,$04 or $02, 0,0, tcAppendSDToNarr);   {ctrl + shift + H}
     AddCommand(KeyMapName,74,$04,0,0,tcCopyNotesToNarration); {ctrl+J}
     AddCommand(KeyMapName,74,$04 or $02, 0,0, tcAppendNotesToNarr); {ctrl + shift J}
     AddCommand(KeyMapName,75,$04,0,0,tcRecombine);        {ctrl+K}
     AddCommand(KeyMapName,76,$04,0,0,tcLookup);           {ctrl+L}

     AddCommand(KeyMapName,78,$04,0,0,tcSetFlags);         {ctrl+N}
     AddCommand(KeyMapName,79,$04,0,0,tcMore);             {ctrl+0}

     AddCommand(KeyMapName,81,$04,0,0,tcRecalc);           {ctrl+Q}
     AddCommand(KeyMapName,82,$04,0,0,tcDitto);            {ctrl+R}
     //File Save                                           //s  file save
     AddCommand(KeyMapName,84,$04,0,0,tcSort);             {ctrl+T}
     AddCommand(KeyMapName,85,$04,0,0,tcMatch);            {ctrl+U}
     //Windows Key                                         //v  windows paste
     AddCommand(KeyMapName,87,$04,0,0,tcView);             {ctrl+W}
     //Windows Key                                         //x  windows cut
     AddCommand(KeyMapName,89,$04,0,0,tcQueryUncoded);     //y
     //Windows Key                                         //z  windows undo


     AddCommand(KeyMapName,$2D,$02,0,0,tcInsertTrans);     {Shift+insert}


     AddCommand(KeyMapName,77,$04 or $02, 0,0, tcMarkNote); {ctrl + shift M}
     AddCommand(KeyMapName,65,$04 or $02, 0,0, tcMarkAllNotes); {ctrl + shift A}
     AddCommand(KeyMapName,88,$04 or $02, 0,0, tcDeleteNote); {ctrl + shift X}

{$IFDEF SmartLink}
     AddCommand(KeyMapName,70,$02 or $04,0,0,tcLaunchFingertips);    {ctrl+shift+D}
{$ENDIF}
   end;
end;

function TfrmCoding.JobEdited(pT: pTransaction_Rec): Boolean;
var pD : pDissection_Rec;
begin
   with pT^ do
      if txJob_Code <> '' then begin
         Result :=  MyClient.clJobs.FindCode( txJob_Code) <> nil;
         Pd := txFirst_Dissection;
         while assigned(PD) do begin
            pd.dsJob_Code := '';
            pd :=pd.dsNext;
         end;
      end else
         Result := true;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.JobLookupClick(Sender: TObject);
begin
  DoLookupJob;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.hdrColumnHeadingsClick(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SearchTimerTimer(Sender: TObject);
begin
   SearchTimer.Enabled := False;
   SearchText := EBFind.Text;
end;

procedure TfrmCoding.SetColDefPosition(aBankPrefix : string);
//Set up the Column default positions for each bank.  The Coding form
//will be using these default values when there isn't a setting for a column

   function DefaultPosForCol( ColID : byte) : integer;
   //result will be 0..MaxXXColumns-1
   var
      i : integer;
   begin
      result := -1;
      case MyClient.clFields.clCountry of
        whNewZealand : begin
          for i := 1 to MaxNZColumns do
             if DefaultColumnOrderNZ[ i] = ColID then
                result := i-1;
        end;

        whAustralia : begin
          for i := 1 to MaxOZColumns do
             if DefaultColumnOrderOZ[ i] = ColID then
                result := i-1;
        end;

        whUK : begin
          for i := 1 to MaxUKColumns do
             if DefaultColumnOrderUK[ i] = ColID then
                result := i-1;
        end;

      end; //case
   end;

var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //default positions are taken from the const array defined above
   //skip cols that are not used
   // !!! ASSUMES that all columns for a country are loaded !!!

   for i := 0 to ceMax do begin
      DefaultPositions[ i ] :=  DefaultPosForCol( i);
   end;

   //check to see if should reverse positions of other party, particulars for NDC accounts
   //Assumes bankAccount has been set
   if ( MyClient.clFields.clCountry = whNewZealand ) and
     ( GenUtils.ReverseFields( BankAccount.baFields.baBank_Account_Number )) then
     { Swap the Other Party and Particulars Columns Around }
      SwapUtils.SwapIntegers( DefaultPositions[ ceParticulars ], DefaultPositions[ ceOtherParty ] );

   //DefaultPositions array has now been setup, now load the positions into the ColumnFmtList
   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
   begin
     ColDefn := ColumnFmtList.ColumnDefn_At(i);
     with ColDefn^ do cdDefPosition := DefaultPositions[ cdFieldID ];
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetupColumnFmtList(var ColFmt: TColFmtList);
// Note that TColFmtList allows for 2 edit modes Restricted and General
// The Restricted mode is not used in the Coding form as only one column is
// available and this has other ramifications
// EditAccountCodeOnly flag used instead
var
   AllowGSTAmtEditing : Boolean;
   AllowGSTClassEditing : Boolean;
   DefNarrationWidth  : integer;
   BCode, CCode : String[3];
begin
   BCode := BankAccount.baFields.baCurrency_Code;
   CCode := MyClient.clExtra.ceLocal_Currency_Code;

   ColFmt.FreeAll;
   with ColFmt do begin
      //BankLink Columns
      InsColDefnRec( 'S', ceStatus, celStatus, CE_STATUS_DEF_WIDTH, CE_STATUS_DEF_VISIBLE, false, CE_STATUS_DEF_EDITABLE, -1, 'Status' );

      DefNarrationWidth := CE_EFFDATE_DEF_WIDTH; //Temp use of..
      if BankAccount.IsAJournalAccount then
         Inc(DefNarrationWidth, 10); //allow for the Notes image

      InsColDefnRec( 'Date', ceEffDate, celEditDate,DefNarrationWidth , CE_EFFDATE_DEF_VISIBLE, false, True, csDateEffective, 'Effective Date' );

      if BankAccount.IsAJournalAccount then begin
         InsColDefnRec( 'Reference', ceReference, celRef, CE_REFERENCE_DEF_WIDTH, CE_REFERENCE_DEF_VISIBLE, false, BankAccount.CanEditTransactions, csReference );
         bkHelpSetup( Self, BKH_Using_the_Journal_Entries_Screen );
      end else Begin
         bkHelpSetup( Self, BKH_Using_the_Code_Entries_Screen);
         InsColDefnRec( 'Reference', ceReference, celRef, CE_REFERENCE_DEF_WIDTH, CE_REFERENCE_DEF_VISIBLE, false, BankAccount.CanEditTransactions, csChequeNumber );

         case MyClient.clFields.clCountry of
            whNewZealand : begin
               InsColDefnRec( 'Analysis', ceAnalysis, celAnalysis, CE_ANALYSIS_DEF_WIDTH, CE_ANALYSIS_DEF_VISIBLE, false, CE_ANALYSIS_DEF_EDITABLE, csByAnalysis );
            end;
         end;

         InsColDefnRec( 'Account', ceAccount, celAccount, CE_ACCOUNT_DEF_WIDTH, CE_ACCOUNT_DEF_VISIBLE, false, CE_ACCOUNT_DEF_EDITABLE, csAccountCode  );
         InsColDefnRec( 'A/c Desc', ceDescription, celDescription, CE_DESCRIPTION_DEF_WIDTH, CE_DESCRIPTION_DEF_VISIBLE, false, CE_DESCRIPTION_DEF_EDITABLE, csByAccountDesc);

         if fIsForex then
         Begin
           InsColDefnRec( 'Amount (' + BCode + ')', ceForexAmount, celForexAmount, CE_FOREX_AMOUNT_DEF_WIDTH, CE_FOREX_AMOUNT_DEF_VISIBLE, false, CE_FOREX_AMOUNT_DEF_EDITABLE, csByForexAmount );
           InsColDefnRec( 'Rate', ceForexRate, celForexRate, CE_FOREX_RATE_DEF_WIDTH, CE_FOREX_RATE_DEF_VISIBLE, false, True, csByForexRate );
           InsColDefnRec( 'Amount (' + CCode + ')', ceLocalCurrencyAmount, celLocalCurrencyAmount, CE_LOCAL_CURRENCY_AMOUNT_DEF_WIDTH, CE_LOCAL_CURRENCY_AMOUNT_DEF_VISIBLE, false, True, csByValue );
         End
         else
         if MyClient.HasForeignCurrencyAccounts then
           InsColDefnRec( 'Amount (' + CCode + ')', ceAmount, celAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, false, CE_AMOUNT_DEF_EDITABLE, csByValue )
         else
           InsColDefnRec( 'Amount',   ceAmount, celAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, false, CE_AMOUNT_DEF_EDITABLE, csByValue );

         InsColDefnRec( 'Statement Details', ceStatementDetails, celStatementDetails, CE_STATEMENT_DEF_WIDTH, CE_STATEMENT_DEF_VISIBLE, false, CE_STATEMENT_DEF_EDITABLE, csByStatementDetails);

         case MyClient.clFields.clCountry of
            whNewZealand : begin
               InsColDefnRec( 'Other Party', ceOtherParty,  celOther, CE_OTHERPARTY_DEF_WIDTH, CE_OTHERPARTY_DEF_VISIBLE, false, CE_OTHERPARTY_DEF_EDITABLE, csByOtherParty  );
               InsColDefnRec( 'Particulars', ceParticulars, celPart,  CE_PARTICULARS_DEF_WIDTH, CE_PARTICULARS_DEF_VISIBLE, false, CE_PARTICULARS_DEF_EDITABLE, csByParticulars );
            end;
         end;
      end;

      if MyClient.clFields.clCountry = whNewZealand then
        DefNarrationWidth := CE_NARRATION_DEF_NZ_WIDTH
      else
        DefNarrationWidth := CE_NARRATION_DEF_OZ_WIDTH;

      InsColDefnRec( 'Narration', ceNarration, celNarration, DefNarrationWidth, CE_NARRATION_DEF_VISIBLE, false, CE_NARRATION_DEF_EDITABLE, csByNarration );

{$IFDEF SmartLink}
      InsColDefnRec( 'Attachment', ceDocument, celDocument, CE_DOCUMENT_DEF_WIDTH, CE_DOCUMENT_DEF_VISIBLE, false, CE_DOCUMENT_DEF_EDITABLE, csByDocumentTitle);
{$ENDIF}

      if BankAccount.IsAJournalAccount then begin


         InsColDefnRec( Localise( FCountry, 'GST Amount'), ceGSTAmount, celGstAmt, CE_GSTAMOUNT_DEF_WIDTH, CE_GSTAMOUNT_DEF_VISIBLE, False, False, csByGSTAmount );
         InsColDefnRec( 'Action', ceAction, celAction, 190, true, false, false, 0 );
      end else begin
         InsColDefnRec( 'Payee', cePayee,    celPayee,   CE_PAYEE_DEF_WIDTH, CE_PAYEE_DEF_VISIBLE, false, CE_PAYEE_DEF_EDITABLE, csByPayee  );
         InsColDefnRec( 'Payee Name', cePayeeName, celPayeeName, CE_PAYEENAME_DEF_WIDTH, CE_PAYEENAME_DEF_VISIBLE, false, CE_PAYEENAME_DEF_EDITABLE, csByPayeeName);
         InsColDefnRec( 'Job', ceJob, celJob, CE_JOB_DEF_WIDTH, CE_JOB_DEF_VISIBLE, false, CE_JOB_DEF_EDITABLE, csByJob );
         InsColDefnRec( 'Job Name', ceJobName, celJobName, CE_PAYEENAME_DEF_WIDTH, CE_PAYEENAME_DEF_VISIBLE, false, False, csByJobName);

         AllowGSTClassEditing := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );
         case MyClient.clFields.clCountry of
            whNewZealand : begin
               InsColDefnRec( 'GST',   ceGSTClass, celGSTCode, CE_GSTCLASS_DEF_WIDTH, CE_GSTCLASS_DEF_VISIBLE, false, CE_GSTCLASS_DEF_EDITABLE, csByGSTClass , 'GST Class ID' );
               InsColDefnRec( 'GST Amount', ceGSTAmount, celGstAmt, CE_GSTAMOUNT_DEF_WIDTH, CE_GSTAMOUNT_DEF_VISIBLE, false, CE_GSTAMOUNT_DEF_EDITABLE, csByGSTAmount );
            end;
            whAustralia  : begin
               //Ledger Elite doesn't support editing of the GST class
               InsColDefnRec( 'GST',   ceGSTClass, celGSTCode, CE_GSTCLASS_DEF_WIDTH, CE_GSTCLASS_DEF_VISIBLE, false, AllowGSTClassEditing, csByGSTClass , 'GST Class ID' );

               //restrict editing of the gst amount col only if calc method is full
               AllowGSTAmtEditing := ( MyClient.clFields.clBAS_Calculation_Method <> bmFull);
               InsColDefnRec( 'GST Amount', ceGSTAmount, celGstAmt, CE_GSTAMOUNT_DEF_WIDTH, CE_GSTAMOUNT_DEF_VISIBLE, false , AllowGSTAmtEditing, csByGSTAmount );
            end;
	        whUK : begin
	           InsColDefnRec( 'VAT',   ceGSTClass, celGSTCode, CE_GSTCLASS_DEF_WIDTH, CE_GSTCLASS_DEF_VISIBLE, false, CE_GSTCLASS_DEF_EDITABLE, csByGSTClass , 'VAT Class ID' );
	           InsColDefnRec( 'VAT Amount', ceGSTAmount, celGstAmt, CE_GSTAMOUNT_DEF_WIDTH, CE_GSTAMOUNT_DEF_VISIBLE, false, CE_GSTAMOUNT_DEF_EDITABLE, csByGSTAmount );
	        end;
	     end;

        InsColDefnRec( 'Tax Inv', ceTaxInvoice, celTaxInv, CE_TAXINVOICE_DEF_WIDTH, CE_TAXINVOICE_DEF_VISIBLE, false, CE_TAXINVOICE_DEF_EDITABLE, -1);
        InsColDefnRec( 'Quantity',   ceQuantity,  celQuantity, CE_QUANTITY_DEF_WIDTH, CE_QUANTITY_DEF_VISIBLE, false, CE_QUANTITY_DEF_EDITABLE, csByQuantity  );
        InsColDefnRec( 'Entry Type', ceEntryType, celEntryType, CE_ENTRYTYPE_DEF_WIDTH, CE_ENTRYTYPE_DEF_VISIBLE, false, CE_ENTRYTYPE_DEF_EDITABLE, csByEntryType );
        InsColDefnRec( 'Date Presented', cePresDate, celBSDate, CE_PRESDATE_DEF_WIDTH, CE_PRESDATE_DEF_VISIBLE, false, CE_PRESDATE_DEF_EDITABLE, csDatePresented , 'Presentation Date');
        InsColDefnRec( 'Coded By', ceCodedBy, celCoded, CE_CODEDBY_DEF_WIDTH, CE_CODEDBY_DEF_VISIBLE, false, CE_CODEDBY_DEF_EDITABLE, csByCodedBy );

        if HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then begin
           csNames[csByAltChartCode] := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
           InsColDefnRec( csNames[csByAltChartCode]
                        , ceAltChartcode, CelAltCode, CE_AltChartCode_DEF_WIDTH, CE_AltChartCode_DEF_VISIBLE, false, CE_AltChartCode_DEF_EDITABLE, csByAltChartCode );

        end;



        if fIsForex then
           InsColDefnRec( 'Balance ('+BCode+')', ceBalance, celBalance, CE_BALANCE_DEF_WIDTH, CE_BALANCE_DEF_VISIBLE, false, CE_BALANCE_DEF_EDITABLE, csDateEffective)
        else
           InsColDefnRec( 'Balance', ceBalance, celBalance, CE_BALANCE_DEF_WIDTH, CE_BALANCE_DEF_VISIBLE, false, CE_BALANCE_DEF_EDITABLE, csDateEffective)

      end;

      if (ProductConfigService.OnLine and ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False)) then
      begin
        InsColDefnRec('Transaction ID', ceCoreTransactionId, celCoreTransactionId, 90, false, true, false, csByTransId);
        InsColDefnRec('Sent to BankLink Online', ceTransferedToOnline, celTransferedToOnline, 142, false, true, false, csBySentToAndAcc);
      end;

      EditMode := emGeneral; //Never changed here
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.BuildTableColumns;
var
  i : integer;
  Col : TOvcTableColumn;
  ColDefn : pColumnDefn;
begin
   with tblCoding do begin
      //Lock table update
      AllowRedraw := false;
      //Set correct number of columns
      ColCount := ColumnFmtList.ItemCount;
      //Clear headings
      hdrColumnHeadings.Headings.Clear;
      //Iterate thru column format list setting correct columns attributes
      for i := 0 to Pred( ColumnFmtList.ItemCount ) do
        begin
           ColDefn := ColumnFmtList.ColumnDefn_At(i);

           hdrColumnHeadings.Headings.Add( ColDefn^.cdHeading );
           Col := Columns[i];
           Col.DefaultCell := ColDefn^.cdTableCell;
           Col.Width := ColDefn^.cdWidth;
           Col.Hidden := ColDefn^.cdHidden;
        end;
      //Unlock table update
      AllowRedraw := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  IsClosing := True;
  if not tblCoding.StopEditingState(True) then begin// Save what we can

     tblCoding.StopEditingState(False); // if not Just roll back
  end;
  if tmrPayee.Enabled then begin
      tmrPayeeTimer(nil); // execute the prompts
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.UpdateCodedCount;
var
  i, Coded : integer;
begin
  Coded := 0;
  for i := 0 to Pred(WorkTranList.ItemCount) do
    if IsCoded( WorkTranList.Transaction_At(i) ) then Inc( Coded );

  barCodingStatus.Panels[PANELCODEDCOUNT].Text := Inttostr(Coded);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.AccountEdited(pT : pTransaction_Rec);
//update other fields that change when account changes
//special case:  If account is elders account ( AU only) then override the gst to
//blank by default.
Var
  IsEldersAccount : boolean;
Begin
   With pT^ do
   Begin
      If (txAccount = '') then begin
         if (txCoded_By <> cbManualSuper) then
            txCoded_By := cbNotcoded;
         { The user has deleted the account code, so uncode the transaction }
         txGST_Class := 0;
         txGST_Amount := 0;
         txHas_Been_Edited := False;
         txGST_Has_Been_Edited := False;
         exit;
      end;

      { The user has entered an Account Code }
      If not MyClient.clChart.CanCodeTo( txAccount ) then
      Begin { If they have entered an invalid account code, flag the entry as manually coded so
              that the AutoCode doesn't try to recode it. }
         if (txCoded_By <> cbManualSuper) then //Won't recode so keep
            txCoded_By := cbManual;
         exit;
      end;

      { The user has entered a valid Account Code }

      IsEldersAccount := ( MyClient.clFields.clCountry = whAustralia ) and ( BankPrefix = EldersPrefix );
      If IsEldersAccount and ( txType in [9,10] ) then
      Begin
         // special case - elders accounts receive transaction is strange way so
         //                GST needs to be blank by default
         //                !! Only if Misc Dr or Cr,  GST should still be calced
         //                on cheques.
         txGST_Class := 0;
         txGST_Amount := 0;
         if (txCoded_By <> cbManualSuper) then //keep
            txCoded_By := cbManual;
         txHas_Been_Edited := False;
         txGST_Has_Been_Edited := True;

         exit;
      end;

      { Normal post account code processing - calculate the GST class and amount and flag the transaction as manually coded }
//      CalculateGST( MyClient, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount );
      CalculateGST( MyClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
      if (txCoded_By <> cbManualSuper) then //keep
         txCoded_By := cbManual;
      txGST_Has_Been_Edited := False;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.GSTClassEdited(pT: pTransaction_Rec);
begin
   with pT^ do begin
      if txGST_Class = 0 then
         txGST_Amount := 0
      else
//         txGST_Amount := ( CalculateGSTForClass( MyClient,  txDate_Effective, txAmount, txGST_Class ) );
         txGST_Amount := ( CalculateGSTForClass( MyClient,  txDate_Effective, Local_Amount, txGST_Class ) );
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.PayeeEdited(pT: pTransaction_Rec): boolean;
var
   APayee       : TPayee;
   isPayeeDissected : boolean;
   DissectAmt   : PayeeSplitTotals;
   DissectPct   : PayeeSplitPercentages;
   i : integer;
   Dissection   : pDissection_Rec;
   RecodeRequired : Boolean;
   PayeeLine    : pPayee_Line_Rec;
   Amount       : Money;

   function DoSuperFund: Boolean;
   begin
      if PayeeLine.plSF_Edited
      and CanUseSuperFundFields (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used ) then begin

         Result := (not (MyClient.clFields.clAccounting_System_Used in [saBGLSimpleFund, saBGLSimpleLedger]))
                or (pT.txDate_Effective >= mcSwitchDate); // cannot do new and Old list

      end else
         Result := False
   end;

begin
  result := true;  //assume success

  if pT^.txPayee_Number = 0 then exit;  //don't need to do anything

  if (not BankAccount.ValidPayeeCode(pT^.txPayee_Number)) then begin
    Result := False;
    Exit;
  end;

  APayee := MyClient.clPayee_List.Find_Payee_Number(pT^.txPayee_Number);
  with pT^, APayee do begin
     //Payee is dissected if more than one line with Account Code
     isPayeeDissected := APayee.IsDissected;
     //see if user want to override existing fields.  Don't ask if nothing would
     //be changed.
     if ( txFirst_Dissection <> nil )
     or (txAccount <> '') then
     begin
        RecodeRequired := false;
        //prompt user to override details with detail of payee, or just alter the narration
        if txFirst_Dissection <> nil then begin
           //current entry is dissected, see if is different to payee dissection
           //compare account codes
           if IsPayeeDissected then
               RecodeRequired := not DissectionMatchesPayee( aPayee, pT)
           else
               RecodeRequired := true; //payee is not dissected so coding is different
        end else begin
           //account code must be there already
           PayeeLine := APayee.FirstLine;
           if ( PayeeLine <> nil) then begin
              //compare with payee details
              if IsPayeeDissected
              or ( txAccount <> PayeeLine.plAccount)
              or (( txGL_Narration <> PayeeLine.plGL_Narration) and ( PayeeLine.plGL_Narration <> ''))  then begin
                 RecodeRequired := true;
              end;
           end;
        end;

        if RecodeRequired then begin
           case PayeeRecodeDlg.AskRecodeOnPayeeChange of
              prCancel : begin
                 result := false;
                 exit;
              end;
              prNarrationOnly : begin  //update narration
                 //only update the narration if the transaction is not dissected
                 //and the payee is not dissected, otherwise just see the payee
                 //number - the name will appear in the payee name box
                 if ( txFirst_Dissection = nil) and ( not IsPayeeDissected) then
                 begin
                   PayeeLine := APayee.FirstLine;
                   if ( PayeeLine <> nil) and ( PayeeLine.plGL_Narration <> '') then
                   begin
                     txGL_Narration := PayeeLine.plGL_Narration;
                   end;
                 end;
                 exit;
              end;
              prRecode : ;  //proceed as normal
           end; //case
        end
        else
          //nothing needs to change so just exit.
          exit;
     end;

     //clear any existing dissection
     Dump_Dissections( pT);

     //code the entry with the details from the payee
     if not (isPayeeDissected) then
     begin
        //payee is a single line so alter existing transaction
        if (APayee.pdLines.ItemCount > 0) then
        begin
          PayeeLine := APayee.FirstLine;
          txAccount := PayeeLine.plAccount;
          if PayeeLine.plGL_Narration <> '' then
            txGL_Narration := PayeeLine.plGL_Narration;

          if (PayeeLine.plGST_Has_Been_Edited) then begin
             txGST_Class    := PayeeLine.plGST_Class;
//             txGST_Amount   := CalculateGSTForClass( MyClient, txDate_Effective, txAmount, txGST_Class);
             txGST_Amount   := CalculateGSTForClass( MyClient, txDate_Effective, Local_Amount, txGST_Class);
             txGST_Has_Been_Edited := true;
          end
          else begin
//             CalculateGST( MyClient, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount);
             CalculateGST( MyClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount);
             txGST_Has_Been_Edited := false;
          end;
          txCoded_by := cbManualPayee;

          if DoSuperFund then begin
             if PayeeLine.plSF_PCFranked <> 0 then begin
                txSF_Franked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCFranked) * Money2Double(txAmount)/100));
                txSF_Imputed_Credit := FrankingCredit(txSF_Franked, txDate_Effective);
             end;
             if PayeeLine.plSF_PCUnFranked <> 0 then begin
                if (PayeeLine.plSF_PCUnFranked + PayeeLine.plSF_PCFranked) = 1000000 then
                   txSF_UnFranked := Abs(txAmount) - txSF_Franked  // No Rounding Isues
                else
                   txSF_UnFranked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCUnFranked) * Money2Double(txAmount)/100));
             end;
             txSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
             txSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
             txSF_Fund_ID              := PayeeLine.plSF_Fund_ID;
             txSF_Fund_Code            := PayeeLine.plSF_Fund_Code;
             txSF_Member_ID            := PayeeLine.plSF_Member_ID;
             txSF_Transaction_ID       := PayeeLine.plSF_Trans_ID;
             txSF_Transaction_Code     := PayeeLine.plSF_Trans_Code;
             txSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
             txSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
             txSF_Member_Component     := PayeeLine.plSF_Member_Component;

             if PayeeLine.plQuantity <> 0 then
                txQuantity := PayeeLine.plQuantity;

             if PayeeLine.plSF_GDT_Date <> 0 then
                txSF_CGT_Date := PayeeLine.plSF_GDT_Date;

             txSF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

             SplitRevenue(txAmount,
                          txSF_Tax_Free_Dist,
                          txSF_Tax_Exempt_Dist,
                          txSF_Tax_Deferred_Dist,
                          txSF_Foreign_Income,
                          txSF_Capital_Gains_Indexed,
                          txSF_Capital_Gains_Disc,
                          txSF_Capital_Gains_Other,
                          txSF_Capital_Gains_Foreign_Disc,
                          txSF_Other_Expenses,
                          txSF_Interest,
                          txSF_Rent,
                          txSF_Special_Income,
                          PayeeLine);

             txSF_Super_Fields_Edited  := True;
          end else begin
             ClearSuperFundFields(Pt);
          end;

        end;
     end
     else
     begin
        Amount := txAmount;

        //payee is dissected, so dissect the transaction
        mxUtils.PayeePercentageSplit( Amount, aPayee, DissectAmt, DissectPct);

        txCoded_by       := cbManualPayee;
        txAccount        := DISSECT_DESC;

        ClearGSTFields(pT);
        ClearSuperFundFields(pT);

        for i := aPayee.pdLines.First to aPayee.pdLines.Last do
        begin
            PayeeLine := aPayee.pdLines.PayeeLine_At(i);
            Dissection := New_Dissection_Rec;
            Dissection.dsBank_Account := pT^.txBank_Account;
            ClearSuperFundFields(Dissection);
            with Dissection^ do begin
               dsTransaction := pT;
               dsAccount := PayeeLine.plAccount;
               if PayeeLine.plGL_Narration <> '' then
                  dsGL_Narration := PayeeLine.plGL_Narration
               else
                  dsGL_Narration := pT^.txGL_Narration;

               dsAmount := DissectAmt[i];
               dsPercent_Amount := DissectPct[i];
               dsAmount_Type_Is_Percent := DissectPct[i] <> 0;

               dsGST_Has_Been_Edited := false;
               if (PayeeLine.plGST_Has_Been_Edited) then begin
                  dsGST_Has_Been_Edited := true;
                  dsGST_Class := PayeeLine.plGST_Class;
               end;
                  
               dsHas_Been_Edited := FALSE;

               if DoSuperFund then begin
                  if PayeeLine.plSF_PCFranked <> 0 then begin
                     dsSF_Franked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCFranked) * Money2Double(dsAmount)/100));
                     dsSF_Imputed_Credit := FrankingCredit(dsSF_Franked, txDate_Effective);
                  end;

                  if PayeeLine.plSF_PCUnFranked <> 0 then begin

                     if (PayeeLine.plSF_PCUnFranked + PayeeLine.plSF_PCFranked) = 1000000 then
                        dsSF_UnFranked := Abs(dsAmount) - dsSF_Franked  // No Rounding Isues
                     else
                        dsSF_UnFranked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCUnFranked) * Money2Double(dsAmount)/100));
                  end;

                  dsSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                  dsSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                  dsSF_Fund_ID              := PayeeLine.plSF_Fund_ID;
                  dsSF_Fund_Code            := PayeeLine.plSF_Fund_Code;
                  dsSF_Member_ID            := PayeeLine.plSF_Member_ID;
                  dsSF_Transaction_ID       := PayeeLine.plSF_Trans_ID;
                  dsSF_Transaction_Code     := PayeeLine.plSF_Trans_Code;
                  dsSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                  dsSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                  dsSF_Member_Component     := PayeeLine.plSF_Member_Component;

                  if PayeeLine.plQuantity <> 0 then
                     dsQuantity := PayeeLine.plQuantity;
                  if PayeeLine.plSF_GDT_Date <> 0 then
                     dsSF_CGT_Date := PayeeLine.plSF_GDT_Date;

                  dsSF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

                  SplitRevenue(dsAmount,
                               dsSF_Tax_Free_Dist,
                               dsSF_Tax_Exempt_Dist,
                               dsSF_Tax_Deferred_Dist,
                               dsSF_Foreign_Income,
                               dsSF_Capital_Gains_Indexed,
                               dsSF_Capital_Gains_Disc,
                               dsSF_Capital_Gains_Other,
                               dsSF_Capital_Gains_Foreign_Disc,
                               dsSF_Other_Expenses,
                               dsSF_Interest,
                               dsSF_Rent,
                               dsSF_Special_Income,
                               PayeeLine);
                  dsSF_Super_Fields_Edited  := True;
               end;



               AppendDissection( pT, Dissection, MyClient.ClientAuditMgr );
            end;
        end;

        //Calculate the GST for dissections
        Dissection := pT.txFirst_Dissection;
        while (Dissection <> nil) do begin
          if Dissection.dsGST_Has_Been_Edited then
            Dissection.dsGST_Amount := CalculateGSTForClass(MyClient, txDate_Effective, Dissection.Local_Amount, Dissection.dsGST_Class)
          else
            CalculateGST(MyClient, txDate_Effective, Dissection.dsAccount, Dissection.Local_Amount, Dissection.dsGST_Class, Dissection.dsGST_Amount);
          Dissection := Dissection.dsNext;
        end;

        if Assigned(AdminSystem)
        and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
          txGL_Narration   := pdName;
     end;
  end;  {with payee^}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.ValidDataRow(RowNum : integer): boolean;
// Row 0 is heading row
begin
   result := (Assigned(WorkTranList)) and
             ((RowNum > 0) and (RowNum <=  WorkTranList.ItemCount ));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
//occurs before ReadCellForEdit
//allows us to decide whether or not a cell is allowed to be edited
var
   FieldID : integer;
   isDissection : boolean;
   pT      : pTransaction_Rec;
   pD      : pDissection_Rec;
begin
   AllowIt := false;
   if not ValidDataRow(RowNum) then
      exit;

   if not ColumnFmtList.ColIsEditable(ColNum) then
      exit;

   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   pT := WorkTranList.Transaction_At(RowNum-1);

   with pT^ do begin
      if txLocked then
         exit;   //can't edit a locked transaction
      if ( txDate_Transferred <> 0) then
         exit;  //can't edit a transferred transaction
      isDissection := (txFirst_Dissection <> nil);
   end;

   if EditAcctColOnly then begin
      if (FieldID <> defaulteditColumn )
      or (isDissection) then
         exit;
   end else begin  //multi col edit mode
      if isDissection
      and (FieldId in [ceAccount, ceGSTClass, ceGSTAmount, ceQuantity, ceForexRate, ceLocalCurrencyAmount ]) then
         //these fields not available if the transaction is a dissection
         exit;

      if not IsJournal then begin
        if ((FieldId = ceEffDate) or (FieldId = ceReference))
        and (pT.txUPI_State <> upNone) then
           Exit; // Do not allow UPIs date or ref to be edited even if it is MDE

        if (FieldId = ceEffDate)
        and (pt.txSource in [orBank]) then
           Exit;
      end;

      if ( FieldId = cePayee ) then begin
          //check if payee has been set in dissection lines, if so dont allow to set
          //at transaction level
          pD := pT^.txFirst_Dissection;
          while ( pd <> nil) do begin
             if pD^.dsPayee_Number <> 0 then exit;
             pD := pD^.dsNext;
          end;
      end;

      if (FieldId = ceGSTAmount)
      and (MyClient.clFields.clCountry = whAustralia)
      and (MyClient.clFields.clBAS_Calculation_Method = bmSimplified) then begin
         //this field cannot be edited if we are using the simplified method and
         //the current gst class assigned has a zero percentage rate
         if ( GetGSTClassRate( MyClient, pT^.txDate_Effective, pT^.txGST_Class) = 0) then
            exit;
      end;

   end;

   //is ok to edit this field
   AllowIt := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
   data := nil;
   case Purpose of
      cdpForPaint:
         ReadCellForPaint(RowNum,ColNum,Data);
      cdpForEdit:
         ReadCellForEdit(RowNum,ColNum,Data);
      cdpForSave :
         ReadCellForSave(RowNum,ColNum,Data);
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
var
   pT: pTransaction_Rec;
   FieldID : integer;
   pA: pAccount_Rec;
   APayee : TPayee;
   Job: PJob_Heading_Rec;
   CoreTransID : Int64;

begin
  if not ValidDataRow(RowNum) then exit;

  with WorkTranList do begin
      CoreTransID := GetTransCoreID_At(RowNum-1);
      pT   := Transaction_At(RowNum-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
        ceStatus :
           begin
              data := nil;
              if (pT^.txDate_Transferred > 0) and (pT^.txLocked) then
               data := pointer(ImagesFrm.AppImages.imgTickLock.Picture.Bitmap)
              else if pT^.txDate_Transferred > 0 then
                data := pointer(ImagesFrm.AppImages.imgTick.Picture.Bitmap)
              else if pT^.txLocked then
                data := pointer(ImagesFrm.AppImages.imgLock.Picture.Bitmap);
           end;

        ceEffDate: begin
              tmpPaintInteger := pT^.txDate_Effective;
              data := @tmpPaintInteger;
           end;

        ceReference:
           begin
             tmpPaintString := GetFormattedReference( pT);
             data := PChar(tmpPaintString);
           end;

        ceAnalysis:
           data := @pT^.txAnalysis;

        ceAccount:
           begin
             if pT^.txFirst_Dissection = nil then
                tmpPaintShortStr := Trim(pT^.txAccount)
             else
                tmpPaintShortStr := DISSECT_DESC;
             data := @(tmpPaintShortStr);
           end;

        ceDescription,
        ceAltChartCode:
           begin
             if pT^.txFirst_Dissection = nil then
             begin
                pA := MyClient.clChart.FindCode( pT^.txAccount );
                if Assigned( pA ) then
                   case FieldID of
                     ceDescription : tmpPaintShortStr := pA^.chAccount_Description;
                     ceAltChartCode : tmpPaintShortStr := pA^.chAlternative_Code;
                   end
                else
                   tmpPaintShortStr := '';
             end else
                tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;

        ceForexAmount :
          begin
//             tmpPaintString := BankAccount.MoneyStrBrackets( pT^.txForeign_Currency_Amount );
             tmpPaintString := BankAccount.MoneyStrBrackets( pT^.txAmount );
             data := PChar(tmpPaintString);
           end;

        ceForexRate :
          Begin
//            tmpPaintDouble := pT^.txForex_Conversion_Rate;
            tmpPaintDouble := pT^.Default_Forex_Rate;
            data := @tmpPaintDouble;
          End;

        ceAmount:
           begin
//             tmpPaintString := MakeAmount( pT^.txAmount );
             tmpPaintString := MakeAmount( pT^.Local_Amount );
             data := PChar(tmpPaintString);
           end;

        ceLocalCurrencyAmount:
           begin
//             tmpPaintString := MyClient.MoneyStrBrackets( pT^.txAmount );
             tmpPaintString := MyClient.MoneyStrBrackets( pT^.Local_Amount );
             data := PChar(tmpPaintString);
           end;

        ceBalance: begin
           begin
             if pT^.txTemp_Balance = UNKNOWN then
                tmpPaintString := ''
             else
                tmpPaintString := BankAccount.BalanceStr( pT.txTemp_Balance );
             data := PChar(tmpPaintString);
           end;
        end;

        ceNarration: begin
           tmpPaintString := pT^.txGL_Narration;
           data := PChar( tmpPaintString);
        end;

        ceStatementDetails: begin
           tmpPaintString := pT^.txStatement_Details;
           data := PChar( tmpPaintString);
        end;

        ceOtherParty:
           data := @pT^.txOther_Party;

        ceParticulars:
           data := @pT^.txParticulars;

        ceGSTClass:
          begin
            if pT^.txFirst_Dissection = nil then
              tmpPaintShortStr := GetGstClassCode( MyClient, pT^.txGST_Class)
            else
              tmpPaintShortStr := ' ';
            data := @(tmpPaintShortStr);
          end;

        ceGSTAmount:
           begin
             if pT^.txFirst_Dissection = nil then
               tmpPaintDouble := Money2Double(pT^.txGst_Amount)
             else
               tmpPaintDouble := Money2Double( GSTCalc32.GetGSTTotalForDissection( pT));
             data := @tmpPaintDouble;
           end;

        ceTaxInvoice:
           data := @pT^.txTax_Invoice_Available;

        ceQuantity:
           if pT^.txFirst_Dissection = nil then begin
              tmpPaintDouble := pT^.txQuantity / 10000;
              data := @tmpPaintDouble;
           end else
              Data := nil;

        cePayee:
            if (pT^.txPayee_Number <> 0)
            or (pT^.txFirst_Dissection <> nil) then
               Data := @(pT^.txPayee_Number)
            else
               Data := nil;

        cePayeeName: begin
             if pT^.txPayee_Number <> 0 then
             begin
                APayee := MyClient.clPayee_List.Find_Payee_Number(pT^.txPayee_Number);
                if Assigned( aPayee ) then
                   tmpPaintShortStr := aPayee.pdName
                else
                   tmpPaintShortStr := 'Unknown';
             end else
                tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;

        ceJob:  begin
             // Owner drawn would

             tmpPaintShortStr := pT^.txJob_code;
             Data := @tmpPaintShortStr;
          end;
        ceJobName: begin
             Data := nil;

             if (pT^.txJob_code > '') then begin
                Job := MyClient.clJobs.FindCode (pT^.txJob_code);
                if Assigned(Job) then
                   tmpPaintShortStr := Job.jhHeading
                else
                   tmpPaintShortStr := 'Unknown';
             end else
                tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;
        ceEntryType:
           begin
              tmpPaintString := GetFormattedEntryType(pT);
              data := PChar(tmpPaintString);
           end;

        cePresDate:
           begin
              if pT^.txDate_Presented > 0 then
                tmpPaintString := StDateToDateString(BKDATEFORMAT,pT^.txDate_Presented,false)
              else
                tmpPaintString := ' ';
              data := PChar(tmpPaintString);
           end;

        ceCodedBy:
           data := @(cbNames[pT^.txCoded_By]);

        ceDocument: begin
           tmpPaintString := ' ';  //no longer show the doc title in CES however if this is left
                                   //blank the cell will not trigger the custom draw
                                   //pT^.txDocument_Title;
           data := PChar( tmpPaintString);
        end;

        ceAction : begin
           tmpPaintShortStr := GetFormattedAction(pT);
           data := @tmpPaintShortStr;
        end;

        ceCoreTransactionId :
        begin
           tmpPaintString := ' ' + IntToStr(CoreTransID);

           data := PChar(tmpPaintString);
        end;

        ceTransferedToOnline :
        begin
          data := @pT^.txTransfered_To_Online;
        end

      else
         data := nil;
      end;{case}
  end  ; { with do}

end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.ReadCellForEdit(RowNum, ColNum: Integer; var Data: Pointer);
//occurs after OnBeginEdit
var
   pT : pTransaction_Rec;
   FieldID : integer;
   S: string;
begin
   Data := nil;
   if not ValidDataRow(RowNum) then exit;

   with WorkTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         ceAccount: begin
            tmpShortStr := Trim(pT.txAccount);
            data := @tmpShortStr;
         end;

         ceEffDate: begin
            tmpInteger := pT.txDate_Effective;
            data := @tmpInteger;
         end;

         ceReference: begin
           EmptyTmpBuffer;
           S := pt^.txReference;
           StrCopy( PChar(tmpBuffer), PChar(S));
           data := tmpBuffer;
         end;

         ceNarration: begin
           EmptyTmpBuffer;
           StrCopy( PChar(tmpBuffer), PChar( pt^.txGL_Narration));
           data := tmpBuffer;
         end;

         ceGSTClass : begin
            tmpShortStr := GetGSTClassCode( MyClient, pT^.txGST_Class );
            data := @tmpShortStr;
         end;

         ceForexRate : begin
            tmpDouble := pT.txForex_Conversion_Rate;
            data := @tmpDouble;
         end;

         ceForexAmount : Begin
//            tmpDouble := Money2Double( pT.txForeign_Currency_Amount );
            tmpDouble := Money2Double( pT.txAmount );
            data := @tmpDouble;
         End;

         ceLocalCurrencyAmount : Begin
//            tmpDouble := Money2Double( pT.txAmount );
            tmpDouble := Money2Double( pT.Local_Amount );
            data := @tmpDouble;
//            AutoPressMinus := ( pT^.txForeign_Currency_Amount < 0 );
            AutoPressMinus := ( pT^.txAmount < 0 );
         End;

         ceGSTAmount : begin
            tmpDouble := Money2Double(pT.txGst_Amount);
            data := @tmpDouble;
            AutoPressMinus := ( pT^.txAmount < 0);
         end;

         ceTaxInvoice : begin
            tmpBool  := pT^.txTax_Invoice_Available;
            data := @tmpBool;
         end;

         ceQuantity: begin
            tmpDouble := ( pT.txQuantity / 10000 );
            data := @tmpDouble;
            //set autoPressMinus.  This will sent a minus key press when the user starts editing the amount
            AutoPressMinus := ( pT^.txAmount < 0) and ( pT^.txQuantity = 0);
         end;

         cePayee : begin
            tmpPayee := pT^.txPayee_Number;
            data := @tmpPayee;
         end;

         ceJob : begin
            tmpJob := Trim(pT.txJob_Code);
            data := @tmpJob;
         end;

      end; //case
   end; //with
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
//Occurs after OnEndEdit
var
   FieldID : integer;
begin
   Data := nil;
   if not ValidDataRow(RowNum) then
      Exit;

   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

   case FieldID of
      ceAccount, ceOtherParty, ceParticulars,
      ceGSTClass : begin
         data := @tmpShortStr;
      end;

      ceGSTAmount, ceQuantity : begin
         data := @tmpDouble;
      end;

      ceLocalCurrencyAmount : data := @tmpDouble;

      ceForexRate : data := @tmpDouble;

      ceTaxInvoice : begin
         data := @tmpBool;
      end;

      cePayee : begin
         data := @tmpPayee;
         TmrRow := RowNum;
      end;

      ceJob : begin
         Data := @tmpJob;
         TmrRow := RowNum;
      end;

      ceNarration, ceReference : begin
         data := tmpBuffer;
      end;

      ceEffDate : begin
         Data := @tmpDate;
         TmrRow := RowNum;
      end;
   end;
end;
procedure TfrmCoding.RedrawRow(Row: Integer = 0);
begin
   //redraw row
   tblCoding.AllowRedraw := false;
   try
      if Row = 0 then
          Row := tblCoding.ActiveRow;
      tblCoding.InvalidateRow(Row);
   finally
      tblCoding.AllowRedraw := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
//Occurs before ReadCellForSave
var
   pT : pTransaction_Rec;
   FieldID : integer;

   Account, msg : string;
   GSTClass : byte;
   GSTAmt   : double;
   Payee, aDate : integer;

begin
   //verify values
   if not ValidDataRow(RowNum) then exit;

   with WorkTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         ceAccount: begin
            Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
            if (Account <> '') then begin
               if not MyClient.clChart.CanCodeTo( Account ) then begin
                  ErrorSound;
               end;
            end;
         end;

         ceGSTClass : begin
            GSTClass := GetGSTClassNo( MyClient, Trim(TEdit( TOvcTCString(Cell).CellEditor ).Text));
            if not ( GSTClass = 0) then begin
               if not ( GSTClass in GST_CLASS_RANGE )
               or  ( MyClient.clFields.clGST_Class_Names[ GSTClass ] = '' ) then begin
                  AllowIt := false;
                  ErrorSound;
               end;
            end;
         end;

         ceGSTAmount : begin
            GSTAmt := TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat;
            if ( pT^.txGST_Class =0 )
            and (GSTAmt <>0) then begin
               ErrorSound;
               TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat := 0;
               AllowIt := false;
            end
            else begin
//               if (( pT^.txAmount < 0 ) and ( Double2Money(GSTAmt) < pT^.txAmount ))
//               or (( pT^.txAmount > 0 ) and ( Double2Money(GSTAmt) > pT^.txAmount )) then begin
               if (( pT^.Local_Amount < 0 ) and ( Double2Money(GSTAmt) < pT^.Local_Amount ))
               or (( pT^.Local_Amount > 0 ) and ( Double2Money(GSTAmt) > pT^.Local_Amount )) then begin
                  ErrorSound;
                  TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat := 0;
                  AllowIt := false;
               end;
            end;
         end;

         cePayee : begin
            Payee := TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsInteger;
            if not( Payee = 0 ) then begin
               if ( MyClient.clPayee_List.Find_Payee_Number(Payee)= nil ) then begin
                  ErrorSound;
                  Allowit := false;
               end
            end;
         end;

         ceJob :
           if Undo then begin
               Undo := False;
               TEdit( TOvcTCString(Cell).CellEditor).Text := pT.txJob_Code;
           end else begin
               Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
               if (Account <> '') then
                  if MyClient.clJobs.FindCode(Account) = nil then begin
                     ErrorSound;
                     AllowIt := false;
                  end;
           end;

         ceEffDate:
         begin
           aDate := TOvcTCPictureFieldEdit(celEditDate.CellEditor).AsStDate;
           if ( aDate < MinValidDate)
           or ( aDate > MaxValidDate) then begin
              ErrorSound;
              Allowit := False;
           end;
           if not IsJournal then begin
              case pt.txSource of
                 orBank : begin
                    ErrorSound; //savety net..
                    Allowit := False;
                 end;
              end;
           end;
         end;

         ceReference:
         begin
          if Undo then
          begin
            Undo := False;
            TEdit( TOvcTCString(Cell).CellEditor).Text := pT.txReference;
          end
          else
          begin
            Allowit := ValidCheque(Trim(TEdit( TOvcTCString(Cell).CellEditor).Text), pT, msg);
            if not Allowit then
            begin
              ErrorSound;
              HelpfulErrorMsg(msg, 0);
            end;
          end;
        end;
      end; //case
   end; //with
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change

var
   pT: pTransaction_Rec;
   FieldID : integer;
   UE      : pUE;
   B       : Byte;
   M       : Money;
   S       : String;
begin
   //write values back to worktranlist
   if not ValidDataRow(RowNum) then exit;

   with WorkTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         //the following fields affect other fields
         ceAccount: begin
            tmpShortStr := Trim( tmpShortStr);
            if ( pT^.txAccount <> tmpShortStr ) then begin
               // Edited flag not set if when coded from Blank
               if ( pT^.txAccount <> '' ) then
               begin
                  pT^.txHas_Been_Edited := true;
               end;
               pT^.txAccount :=tmpShortStr;
               AccountEdited(pT);

               pT.txTransfered_To_Online := False;
            end;
         end;

         cePayee : begin
            // can't popup a dialog in here - case 7255
            if pT.txPayee_Number <> tmpPayee  then
            begin
              pT.txTransfered_To_Online := False;
            end;
         end;

         ceJob : begin
           // can't popup a dialog in here - case 7255

           if pT.txJob_Code <> tmpJob then
           begin
             pT.txTransfered_To_Online := False;
           end;
         end;

         ceGSTClass : begin
            B := GetGSTClassNo( MyClient, Trim( tmpShortStr));
            if ( pT^.txGST_Class <> B ) then begin
               pT^.txGST_Class := B;
               GSTClassEdited(pT);
               //check if gst edited
               if GSTDifferentToDefault( MyClient, pT ) then
               begin
                  pT^.txHas_Been_Edited     := true;
                  pT^.txGST_Has_Been_Edited := true;
                  pT^.txTransfered_To_Online := False;
               end
               else
                  pT^.txGST_Has_Been_Edited := false;
            end;
         end;

         //the following fields do not affect any other fields
         ceGSTAmount : begin
            M := Double2Money(tmpDouble);
            if ( pT^.txGST_Amount <> M ) then begin
               pT^.txGST_Amount   := M;
               //check if gst edited
               if GSTDifferentToDefault( MyClient, pT ) then
               begin
                  pT^.txHas_Been_Edited     := true;
                  pT^.txGST_Has_Been_Edited := true;
                  pT^.txTransfered_To_Online := False;
               end
               else
                  pT^.txGST_Has_Been_Edited := false;
            end;
         end;

         ceTaxInvoice : begin
           if pT^.txTax_Invoice_Available <> tmpBool then
           begin
             pT.txTransfered_To_Online := False;
           end;
           
           pT^.txTax_Invoice_Available := tmpBool;
         end;

         ceNarration : begin
           S := PChar( tmpBuffer);  //will have been filled by ReadCellForSave
           if (pT^.txGL_Narration <> S) then
           begin
              pT^.txGL_Narration    := S;
              pT^.txHas_Been_Edited := true;
              pT^.txTransfered_To_Online := False;
           end;
         end;

         ceQuantity : begin
            if pT^.txQuantity <> tmpDouble then
            begin
              pT.txTransfered_To_Online := False;
            end;
            
            //doesn't set txHas_Been_Edited because not used or affected by AutoCode
            pT^.txQuantity    := (tmpDouble * 10000);
         end;

         // manual accounts and journal Only:
         ceEffDate: begin
           if pT.txDate_Effective <> tmpInteger then
           begin
             pT.txTransfered_To_Online := False;
           end;
         end;

         ceReference:
         begin
           if pT.txReference <> PChar(tmpBuffer) then
           begin
             pT.txTransfered_To_Online := False;
           end;

          pT^.txReference := PChar( tmpBuffer);

          if ((pT^.txType = 0) and (MyClient.clFields.clCountry = whNewZealand)) or
             ((pT^.txType = 1) and (MyClient.clFields.clCountry = whAustralia)) or
             ((pT^.txType = 1) and (MyClient.clFields.clCountry = whUK)) then
            pT^.txCheque_Number := StrToInt( PChar(tmpBuffer));
         end;

         ceAmount:
         begin
           if Double2Money(tmpDouble)<> pT^.txAmount then
           begin
             pT.txTransfered_To_Online := False;
           end;
         end;

         ceEntryType:
         begin
           pT.txTransfered_To_Online := False;
         end;

         ceForexRate:
         begin
           if pT.txForex_Conversion_Rate <> tmpDouble then
           begin
             pT.txTransfered_To_Online := False;
           end;
         end;
      end;

      //what does this do??????????????? see steve for verbal documentation
      if Assigned(UEList) then begin
         UE := UEList.FindUEByPtr( pT);
         If Assigned( UE ) then UE^.Code := pT^.txAccount;
      end;
   end;

   RedrawRow;

   if FieldId in [cePayee, ceJob, ceEffDate] then begin
      tmrpayee.Tag := FieldId;
      tmrPayee.Enabled := True;
   end;
        
   UpdateCodedCount;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingColumnsChanged(Sender: TObject; ColNum1,
  ColNum2: Integer; Action: TOvcTblActions);
var
   pCD1,
   pCD2 : pColumnDefn;
begin
   case Action of
      taSingle :
        begin
          //make sure the column width is not larger than the grid width
          if (tblCoding.Columns[ColNum1].Width >= tblCoding.ClientWidth) then
            tblCoding.Columns[ColNum1].Width := tblCoding.ClientWidth - 2;
          if not CurrUser.HasRestrictedAccess then
          begin
            //update column width in ColumnFmtList
            pCD1 := ColumnFmtList.ColumnDefn_At(ColNum1);
            pCD1^.cdWidth := tblCoding.Columns[ColNum1].Width;
          end;
        end;

      taExchange : with ColumnFmtList do begin
        if not CurrUser.HasRestrictedAccess then
          begin
            //swap cols, the table takes care of restructing itself, so all
            //we need to do is update the ColumnFmtList and ColConfigList.
            pCD1 := ColumnDefn_At(ColNum1);
            pCD2 := ColumnDefn_At(ColNum2);
            Items[ColNum1] := pCD2;
            Items[ColNum2] := pCD1;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetTableAccess;
//the table should be read only if there are no transactions in the worktranlist
//InvalidateTable required for correct repaint when all rows deleted
begin
   if WorkTranList.ItemCount > 0 then begin
      tblCoding.Access   := otxNormal;
   end
   else begin
      tblCoding.Access   := otxReadOnly;
   end;
   tblCoding.InvalidateTable;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TfrmCoding.tblCodingGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
   if not ValidDataRow(RowNum) then exit;

   //check that the current cell color is the default color so that
   //dont change color if the cell is highlighted ie. active cell
   if (CellAttr.caColor = tblCoding.Color) then begin
      begin
         if Odd(RowNum) then
            CellAttr.caColor := clStdLineLight
         else
            CellAttr.caColor := clStdLineDark;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
var
   HintText : string;
   pT : pTransaction_Rec;
   FieldID   : Integer;
begin
   HideCustomHint; // Changing cells, so Hide the Hint window
   if not ValidDataRow(RowNum) then exit;

   //show hints, only long hints appear
   with WorkTranList do begin
     pT   := Transaction_At(RowNum-1);
     FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
     case FieldID of
        ceAccount : begin
           ShowHintForCell( RowNum, ColNum);
           HintText      := Localise( FCountry, 'Enter an Account Code    (F2) Lookup Chart    (F3) Lookup Payee  (F5) Lookup Job  (F7) Lookup GST' );

           if pT^.txFirst_Dissection <> nil then
              HintText   := 'Press ''/'' to edit the Dissection';
           // If UPC Status then overwrite hint with appropriate text
           case pT^.txUPC_Status of
              ucNone : begin
                 // No Action - Hint remains as set above
              end;
              ucUnpresented : begin
                 HintText   := 'Press ''='' if you wish to edit the amount of this Transaction';
              end;
              ucMatchingRef : begin
                 HintText   := 'There is a matching Unpresented Cheque.  Press (Ctrl-U) to match it';
              end;
              ucMatchingAmount  : begin
                 HintText   := 'There is an Unpresented Item with this amount. Press (Ctrl-U) to match it';
              end;
           end;

           if pT^.txUPC_Status in [ucMatchingRef, ucMatchingAmount] then
              MessageBeep( $FFFFFFFF) ; //Documenation says default sound will be played.  If default cant be played
                                        //windows will try to use the system speaker.
        end;
        ceEffDate,
        ceAction:  ShowHintForCell( RowNum, ColNum);
        ceNarration :
           HintText   := 'Enter a Narration or press (F3) to select a Payee';
        ceStatementDetails :
           HintText   := 'The original details from the institution that provided this Transaction';
        ceOtherParty :
           HintText   := 'Enter the Other Party details for this Transaction';
        ceParticulars :
           HintText   := 'Enter the Particulars for this Transaction';
        ceGSTClass :
           HintText      := Localise( FCountry, 'Enter the GST Code if applicable   (F7) Lookup GST' );
        ceGSTAmount :
           HintText      := Localise( FCountry, 'Enter the GST Amount if applicable' );
        ceQuantity :
           HintText   := 'Enter the Quantity value';
        cePayee    : begin
           ShowHintForCell(RowNum, ColNum);
           HintText   := 'Enter the Payee Number    (F3) Lookup Payee';
        end;
        ceJob : begin
           ShowHintForCell(RowNum, ColNum);
           HintText   := 'Enter the Job Code for this Transaction    (F5) Lookup Job Code';
        end;
        ceForexRate :
          Begin
           ShowHintForCell( RowNum, ColNum);
           HintText   := 'Enter the exchange rate for this Transaction    (F2) Lookup Rates';
          End;

{$IFDEF SmartLink}
        ceDocument :
           HintText := 'Link to attachment stored in ' + DocumentManagementSystemName;
{$ENDIF}
     end; {case}
  end;

  tblCoding.Hint := HintText;
  MsgBar(HintText,false);
  tblCoding.Invalidate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingEnteringRow(Sender: TObject;
   RowNum: Integer);
begin
   UpdateStatusForActiveRow( RowNum);
   UpdateNotesPanel( RowNum);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.UpdateNotesPanel( RowNum : integer);
var
   pT : pTransaction_Rec;
begin
   //load notes panel details
   with tblCoding do begin
      if ( ActiveRow <> RowNum ) then exit;
   end;
   if not ValidDataRow(RowNum) then begin
      pnlNotes.Enabled := false;
      memNotes.Text    := '';
      memImportNotes.Text := '';
   end
   else begin
      pnlNotes.Enabled := true;
      pT   := WorkTranList.Transaction_At(RowNum-1);
      memNotes.Text := pT^.txNotes;
      memImportNotes.Text := pT^.txECoding_Import_Notes;
   end;

   memImportNotes.Visible := memImportNotes.Text <> '';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.UpdateStatusForActiveRow( RowNum : integer);
var
   pAcc          : pAccount_Rec;
   pT, p         : pTransaction_Rec;
   AcctStatusStr : string;
   GSTStatusStr  : string;
   UPIStatusStr  : string;
   TranStatusStr : string;
begin
   AcctStatusStr := '';
   GSTStatusStr  := '';
   UPIStatusStr    := '';

   with tblCoding do begin
      if ( ActiveRow <> RowNum ) then exit;
   end;


   if BankAccount.IsAJournalAccount then begin
      AcctStatusStr := 'Journal';
   end else begin
      if not ValidDataRow(RowNum) then begin
         AcctStatusStr := '';
         GSTStatusStr  := '';
      end else begin
         pT   := WorkTranList.Transaction_At(RowNum-1);
         SetTranUPCStatus(pT);

         with pT^ do begin
         Case txCoded_By of
            cbMemorisedC               : AcctStatusStr := 'M';
            cbMemorisedM               : AcctStatusStr := 'MM';
            cbAnalysis                 : AcctStatusStr := 'A';
            cbManualPayee, cbAutoPayee : AcctStatusStr := 'P';    {not currently used}

            cbECodingManual            : AcctStatusStr := 'B';
            cbECodingManualPayee       : AcctStatusStr := 'BP';
            cbCodeIT                   : AcctStatusStr := 'W';
            cbmanualsuper              : AcctStatusStr := 'S';
         end;

         case txSource of
            orHistorical   : AcctStatusStr := 'H' + AcctStatusStr;
            orGenerated    : AcctStatusStr := 'G' + AcctStatusStr;
            orGeneratedRev : AcctStatusStr := 'R' + AcctStatusStr;
            orProvisional  : AcctStatusStr := 'PROV' + AcctStatusStr;
            orMDE          : AcctStatusStr := 'L' + AcctStatusStr;
         end;

         //see if there is extra upi information
         case txUPI_State of
            upMatchedUPC, upMatchedUPD, upMatchedUPW, upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW: begin
               UPIStatusStr := ' Original Entry   ' + bkDate2Str( txDate_Presented) +
                             '     '  + MakeCodingRef( txOriginal_Reference) +
                             '     ' + BankAccount.CurrencySymbol + MakeAmount( Original_Statement_Amount);
               case txOriginal_Source of
                  orHistorical   : UPIStatusStr := UPIStatusStr + ' H';
                  orGenerated    : UPIStatusStr := UPIStatusStr + ' G';
                  orGeneratedRev : UPIStatusStr := UPIStatusStr + ' R';
                  orProvisional  : UPIStatusStr := UPIStatusStr + ' PROV';
                  orMDE          : UPIStatusStr := UPIStatusStr + ' L';
               end;
            end;

            upReversedUPC, upReversedUPD, upReversedUPW: begin
               UPIStatusStr := ' Cancelled     ' + bkDate2str( txDate_Presented);
            end;
            upReversalOfUPC, upReversalOfUPD, upReversalOfUPW: begin
               if txMatched_Item_Id <> 0 then
               begin
                 p := BankAccount.baTransaction_List.FindTransactionFromMatchID(txMatched_Item_Id);
                 if Assigned(p) then
                   UPIStatusStr := ' Original     ' + bkDate2str( p.txDate_Effective);
               end;
            end;
         end;


         //set the Account status string
         if (txFirst_Dissection = nil) then begin
            if ( txAccount <> '' ) then begin
               pAcc := MyClient.clChart.FindCode( txAccount );
               if ( pAcc <> nil ) then with pAcc^ do begin
                  if chPosting_Allowed then
                     AcctStatusStr := Format('%s <%s> %s', [ AcctStatusStr,
                                                             txAccount,
                                                             chAccount_Description ])
                  else
                     AcctStatusStr := Format('%s <%s> %s INVALID', [ AcctStatusStr,
                                                                     txAccount,
                                                                     chAccount_Description ])
               end
               else
                  AcctStatusStr := Format('%s <%s> INVALID CODE!', [ AcctStatusStr,
                                                                     txAccount ]);
               //set the GST status string

               GSTStatusStr := Format('%s %s | %s',[
                 whTaxSystemNames[ MyClient.clFields.clCountry ],
                 GetGSTClassCode( MyClient, txGST_Class),
                 MyClient.MoneyStr( txGST_Amount ) ] );
            end;
         end
         else begin
           AcctStatusStr := Format('%s <%s> DISSECTED ENTRY', [ AcctStatusStr,
                                                                Dissect_Desc ]);
           GSTStatusStr  := '';
         end;

         //update the status to show whether this enter matches a UPC
         if txUPC_Status in [ ucMatchingRef, ucMatchingAmount] then
            AcctStatusStr := Format('%s  [%s]', [ AcctStatusStr, ucNames[ txUPC_Status ]]);

         //update status to show if trx is finalised
         if txLocked then AcctStatusStr := AcctStatusStr+ '  [FINALISED]';
      end;
   end;
   end;
   //update status info
   barCodingStatus.Panels[PANELLINE].Text := Format('%d of %d', [ tblCoding.ActiveRow,
                                                                 (tblCoding.Rowlimit-1)]);;

   if (AcctStatusStr <> '') and ( UPIStatusStr <> '') then
      TranStatusStr := AcctStatusStr + '  -  ' + UPIStatusStr
   else
      TranStatusStr := AcctStatusStr + UPIStatusStr;

   barCodingStatus.Panels[PANELTEXT].text := TranStatusStr;
   barCodingStatus.Panels[GSTTEXT]  .text := GSTStatusStr;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormShow(Sender: TObject);
begin

   SearchVisible := UserINI_CES_Show_Find;
   tblCoding.Setfocus;
   //pnlExtraTitleBar.Color := bkBranding.HeaderBackgroundColor;
   //imgGraphic.Picture := bkBranding.CodingBanner;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormResize(Sender: TObject);
const
   MinSize = 150;
var
   PanelW : integer;
begin
   with barCodingStatus do begin
      PanelW := Self.Width - Panels[PANELMODE].Width - Panels[PANELLINE].Width - Panels[PANELCODEDCOUNT].Width - Panels[GSTTEXT].Width - Panels[PANELBAL].Width;
      if PanelW < MinSize then
         Panels[PANELTEXT].Width := MinSize
      else
         Panels[PANELTEXT].Width := PanelW;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
   HideCustomHint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetTranUPCStatus(pT: pTransaction_Rec);
var
   UPI     : pUE;
   Amount : Money;
begin
   pT^.txUPC_Status := ucNone;

   if not ( pT^.txUPI_State in [ upNone, upBalanceOfUPC, upBalanceOfUPD, upBalanceOfUPW]) then
      exit;

   if ( pT^.txLocked) or (  pT^.txDate_Transferred <> 0) then exit;

   if ( pT^.txDate_Presented = 0 ) then begin
      pT^.txUPC_Status := ucUnpresented
   end
   else begin
      if Assigned( UEList ) then begin
         //see if cheque number matched and trans not presented before upi
         if ( pT^.txCheque_Number > 0) then begin
            UPI := UEList.FindUEByNumber( pT^.txCheque_Number);
            if Assigned( UPI) then
               if ( UPI^.Ptr^.txDate_Effective < pT^.txDate_Presented) then begin
                  pT^.txUPC_Status := ucMatchingRef;
                  exit;
               end;
         end;
         Amount := pT.Statement_Amount;
         //see if amount matched and trans not presented before upi
         if ( Amount <> 0) then begin
            UPI := UEList.FindUEByAmount( Amount );
            if Assigned( UPI) then
               if ( UPI^.Ptr^.txDate_Effective < pT^.txDate_Presented) then
                  pT^.txUPC_Status := ucMatchingAmount;

            UPI := UEList.FindUEByPtr( pT );
            if Assigned( UPI) then UPI^.Code := pT^.txAccount;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.barCodingStatusMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not IsJournal then

  if (X < barCodingStatus.Panels[PANELMODE].Width) {and (not EditMode)} then begin
    ToggleColEditMode;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingActiveCellMoving(Sender: TObject;
   Command: Word; var RowNum, ColNum: Integer);
// Behaviour is as follows
//
// Moving Left:  move to next editable col left, if none found stay where we are
// Moving Right: move to next editable col right, if none move down a row and left most col
//                  if no more rows stay where we are
//
// Mouse Click Left: move to next editable col left, if none found stay where we are
//                   change row if different
// Mouse Click Right: move to next editable col right, if none found stay where we are
//                   change row if different
var
   Direction : TDirection;
   NewCol    : integer;
begin
   if EditAcctColOnly then begin
      if (ColNum <> tblCoding.ActiveCol) then begin
         ColNum := ColumnFmtList.GetColNumOfField(ceAccount);
         //right arrow moves down in this mode
         with tblCoding do begin
            if Command = ccRight then begin
               if (ActiveRow < Pred(RowLimit)) then
                  Inc(RowNum)
               else begin
                  //on last line, cannot move so test if in editing state and stop
                  if InEditingState then
                     StopEditingState( true);
                  exit;
               end;
            end;
         end;
         exit;
      end
      else
         exit;  // no change
   end;

   if not Assigned(ColumnFmtList) then exit;

   with tblCoding, ColumnFmtList do begin

      //do nothing if click in amount col, this is to prevent the editable cell
      //going into edit mode
      if MouseDownInAmountCol and (ColumnFmtList.ColumnDefn_At( ColNum).cdFieldID in [ ceAmount, ceForexAmount ]) then
        begin
          ColNum := ActiveCol;
          Exit;
        end;

      //calculate direction of movement
      if ( ColNum < ActiveCol ) then
         Direction := diLeft
      else if ( ColNum > ActiveCol) then
         Direction := diRight
      else if ( command = ccRight ) and ( ActiveCol = GetRightMostEditCol) then //Pred ( ColCount ) ) then //on right most col trying to move further right
         Direction := diRight
      else
         exit; //col has not been changed, don't need to do anything

      //check for specific command
      case Command of
         ccPageRight, ccBotRightCell : begin //goto right most col
            ColNum  := GetRightMostEditCol;
            LeftCol := ColNum;  //make last col visible
            exit;
         end;

         ccPageLeft, ccTopLeftCell : begin  //goto left most col
            ColNum  := GetLeftMostEditCol;
            LeftCol := 0;  //make first col visible
            exit;
         end;
      end;

      //check is destination cell is editable, if so don't need to do anything
      if (ColNum <> ActiveCol)
      and ColIsEditable(ColNum) then
         exit;

      if Command in [ccLeft, ccRight] then begin
         NewCol := GetNextEditCol( ActiveCol, Direction );
         if ( NewCol = -1 ) then begin

            case Direction of
               diLeft : begin
                  ColNum  := GetLeftMostEditCol;
                  LeftCol := 0;
               end;
               diRight: begin
                  if (ActiveRow < Pred(RowLimit)) then begin
                     Inc(RowNum);
                     ColNum  := GetLeftMostEditCol;
                     LeftCol := 0;
                  end
                  else begin
                     ColNum := GetRightMostEditCol;
                     LeftCol := ColNum;
                  end;
               end;
            end;
         end
         else begin
            ColNum := NewCol;
         end;
      end
      else begin
         //can't move onto selected cell, find closest one to where we want to go
         NewCol := GetClosestEditCol( ActiveCol, ColNum);
         if (NewCol = ActiveCol ) then begin
            //could not find a column to move to in the current row
            case Direction of
               diLeft: begin
                  ColNum  := GetLeftMostEditCol;
                  LeftCol := 0;  //make 0th col visible
               end;
               diRight: begin
                  if Command = ccMouse then begin
                     ColNum := ActiveCol;  //mouse move stick on current col
                  end
                  else begin
                     ColNum  := GetRightMostEditCol;
                     LeftCol := ColNum;
                  end;
               end; //case Direction
            end;
         end
         else begin
            ColNum := NewCol;
         end;
      end;
   end; //with tblCoding
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ToggleColEditMode;
begin
    if EditAcctColOnly then
       SetEditAllCol
    else
       ClearEditAllCol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetEditAllCol;
var I: Integer;
begin
   barCodingStatus.Panels[PANELMODE].text := ALL_MODE_STRING;
   EditAcctColOnly := false;
   I := tblCoding.ActiveCol;
   if I >= 0 then
      if not ColumnFmtList.ColIsEditable(I) then begin
         I := ColumnFmtList.GetColNumOfField(DefaultEditColumn);
         if I >=0  then
            tblCoding.ActiveCol := I;
      end;

   //Moved from ToggleColEdit so it works from the toolbar as well
   if IsJournal then
      // Don't care
   else
      MyClient.clFields.clAll_EditMode_CES := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.RejectHistoricalDate(Value: TSTDate): Boolean;
var lr: tDateRange;
begin
   Result := True;
   lr.ToDate := BankAccount.MaxHistoricalDate;
   if Value > lr.ToDate then begin
       HelpfulInfoMsg( 'Please enter a date on or before '+bkDate2Str(lr.ToDate) + '.', 0);
       Exit;
   end;
   if BankAccount.IsAForexAccount then begin
      lr := BankAccount.Default_Forex_Concersion_DateRange;

      if (Value < lr.FromDate)
      or (Value > lr.ToDate) then begin
         HelpfulInfoMsg('Exchange rate only available between '#13 + bkDate2Str(lr.FromDate) + ' and ' + bkDate2Str(lr.ToDate) + '.', 0);
         Exit;
      end;
   end;
   Result := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.RejectJournalDate(Value: TStDate): Boolean;
begin
  Result := True;
  if ( Finalise32.IsMonthLocked(Value) in [ltAll, ltSome]) then begin
     HelpfulInfoMsg( 'Finalised entries exist in the month you have selected.'#13 +
                        'You cannot add a journal to a finalised period.', 0);
     Exit;
  end;
  {if ( Finalise32.IsMonthTransferred(Value) in [ ltAll, ltSome]) then begin
     if AskYesNo( 'Transferred Period',
                  'Transferred entries exist in the month you have selected.'#13 +
                  'Are you sure you want to add a journal to a period that has been tranferred.',DLG_YES, 0) <> DLG_YES then begin
             Exit;
     end;

  end;}
  // Still Here, must be ok
  Result := False;
end;

procedure TfrmCoding.ClearEditAllCol;
var I: Integer;
//only allows the account column to be edited
begin
   //set the active col to the account column
   I := ColumnFmtList.GetColNumOfField(DefaultEditColumn);
   if I >=0  then
      tblCoding.ActiveCol := I;

   //this must be set after the active col has been changed
   EditAcctColOnly := true;
   barCodingStatus.Panels[PANELMODE].text := RESTRICTED_MODE_STRING_CES;  //restricted

   //Moved from ToggleColEdit so it works from the toolbar as well
   if IsJournal then
      // Don't care
   else
      MyClient.clFields.clAll_EditMode_CES := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  msg : TWMKey;
begin
   //check for lookup key
   if ( Key = VK_F2 ) then begin
      Msg.CharCode := VK_F2;
      celAccount.SendKeyToTable(Msg);
   end
   else if (MyClient.clFields.clUse_Minus_As_Lookup_Key and ((Key = 189) or (Key = 109))) then
   begin
      key := 0;
      Msg.CharCode := VK_F2;
      celAccount.SendKeyToTable(Msg);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celAccountKeyPress(Sender: TObject; var Key: Char);
begin
   //ignore * press if editing
   if (key = '*')  or ((key = '-') and MyClient.clFields.clUse_Minus_As_Lookup_Key) then key := #0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
  DTOpts = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
var
  R         : TRect;
  S         : String;
begin
  If ( data = nil ) then exit;

  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;

  S := ShortString( Data^ );
  If not ( ( S='' ) or ( S= BKCONST.DISSECT_DESC ) or MyClient.clChart.CanCodeTo( S ) or
    ( CellAttr.CaColor = clHighLight ) ) then
  Begin
    TableCanvas.Brush.Color := clRed;
    TableCanvas.Font.Color  := clWhite;
  end;

  TableCanvas.FillRect( CellRect );

  // Draw the cell Border
  R := CellRect;
  TableCanvas.Pen.Color := CellAttr.caColor;
  TableCanvas.Polyline( [ Point( R.Left, R.Bottom-1 ), Point( R.Right, R.Bottom-1 )] );

  // Draw the Code
  R := CellRect;
  InflateRect( R, -2, -2 );
  DrawText( TableCanvas.Handle, PChar( S ), StrLen( PChar( S ) ), R, DTOpts );

  DrawNotesIcon(RowNum, CellRect, TableCanvas);

  DoneIt := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celPayeeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
var
  R   : TRect;
  C   : TCanvas;
  i   : integer;
  S   : String;
  pT  : pTransaction_Rec;

  AllLinesHaveSamePayee : boolean;
  FirstPayeeNo          : integer;

  PayeesInDissection : Boolean;
begin
   If ( data = nil ) then exit;
   i := Integer( Data^);
   if i <> 0 then  //payee is assigned at transaction level so paint normally
      Exit;

   //no payee assigned so check to see if is assigned inside dissection
   if ValidDataRow(RowNum) then
   begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     if pT^.txFirst_Dissection = nil then
       Exit;

     //transaction is dissected, look for payees
     GetPayeeInfoForDissection( pT, PayeesInDissection, AllLinesHaveSamePayee, FirstPayeeNo);
   end
   else
     exit;

   //use default drawing methods if no payees
   if PayeesInDissection then
   begin
     if AllLinesHaveSamePayee then
     begin
       S := PChar( inttoStr( FirstPayeeNo));
     end
     else
       S := PChar( 'split');
   end
   else
     S := '';

   //paint
   R := CellRect;
   C := TableCanvas;
   //paint background
   C.Brush.Color := CellAttr.caColor;
   C.FillRect(R);
   //draw data
   InflateRect( R, -2, -2 );
   if CellAttr.caColor <> clHighLight then
     C.Font.Color := clGrayText
   else
     C.Font.Color := CellAttr.caFontColor;
   DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   DoneIt := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If item matches a upc show as green
const
  margin = 4;
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pT : pTransaction_Rec;
  pD : pDissection_Rec;
  ShowCommentIndicator : boolean;
  CommentColor : TColor;
begin
  if data = nil then exit;
  DoneIt := True;
  R := CellRect;
  C := TableCanvas;
  S := StrPas(PChar(Data));
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  ShowCommentIndicator := False;
  CommentColor := clRed;
  //check is a data row
  if ValidDataRow(RowNum) then begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     SetTranUPCStatus( pT);
     if pT^.txUPC_Status in [ucMatchingAmount] then begin
        C.Brush.Color := clGreen;
        C.Font.Color  := clWhite;
     end else if ( pT^.txUPI_State in [ upUPC, upUPD, upUPW]) and ( pT^.txAmount = 0) then begin
        C.Font.Color := clRed;
     end;

     if CanUseSuperFields then begin
        if pT^.txFirst_Dissection = nil then begin
           ShowCommentIndicator := pT^.txSF_Super_Fields_Edited;
        end else begin
           pD := pT^.txFirst_Dissection;
           CommentColor := clGray;
           while (pD <> nil)
           and ( not ShowCommentIndicator) do begin
              ShowCommentIndicator := pD^.dsSF_Super_Fields_Edited;
              pD := pD^.dsNext;
           end;
        end;
     end;
  end;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect(R, -Margin div 2, -Margin div 2);

  if ( pos( '(', S ) > 0 ) or ( pos( '-', S ) > 0 ) then
    R.Right := round(R.Left+(R.Right-R.Left)*0.95)
  else
    R.Right := round(R.Left+(R.Right-R.Left)*0.75);

  DrawText(C.Handle, Data, StrLen(Data), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);

  if ShowCommentIndicator then
    begin
      //draw a red triangle in the top right
      C.Brush.Color := CommentColor;
      C.Pen.Color := CommentColor;
      R := CellRect;
      C.Polygon( [Point( R.Right - (Margin+ 1), R.Top),
                        Point( R.Right -1, R.Top),
                        Point( R.Right -1, R.Top + Margin)]);
    end;
end;
procedure TfrmCoding.celAnalysisChange(Sender: TObject);
begin
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R                     : TRect;
  C                     : TCanvas;
  S                     : String;
  pT                    : pTransaction_Rec;
  Dissection            : pDissection_Rec;
  i                     : integer;
  InvalidGSTClassFound  : boolean;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow(RowNum) then begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     // if not pT^.txGST_Has_Been_Edited then exit;  Removed this, need to check for invalid GST chart codes
     R := CellRect;
     C := TableCanvas;
     S := ShortString( Data^);
     if S = '' then exit;
     {paint background}
     c.Brush.Color := CellAttr.caColor;
     C.Font.Color  := CellAttr.caFontColor;
     
     if IsCASystems(MyClient) then
     begin
       InvalidGSTClassFound := False;
       Dissection := pT.txFirst_Dissection;
       if Dissection = nil then
       begin
         if not CASystemsGSTOK(MyClient, pT^.txGST_Class) then
           InvalidGSTClassFound := True;
       end else
       begin
         repeat
           // Check the dissections instead
           if not CASystemsGSTOK(MyClient, Dissection.dsGST_Class) then
           begin
             InvalidGSTClassFound := True;
             break;
           end;
           Dissection := Dissection.dsNext;
         until Dissection = nil;
       end;

       if InvalidGSTClassFound then
       begin
         c.Brush.Color := clRed;
         C.Font.Color := clWhite;
       end;

     end;
     c.FillRect(R);
     InflateRect( R, -2, -2 );
     {draw data}
     InflateRect( R, -1, -1 );
     if pT^.txGST_Has_Been_Edited then
       C.Font.Color := bkGSTEditedColor;
     DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
     DoneIt := true;
  end;
end;


procedure TfrmCoding.CelJobKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F5 ) then begin
    Msg.CharCode := VK_F5;
    celJob.SendKeyToTable(Msg);
  end;
end;

procedure TfrmCoding.CelJobOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
  const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
var pt: pTransaction_Rec;
    pd: pDissection_Rec;
    C: TCanvas;
    R: TRect;
    Job: PJob_Heading_Rec;
begin
   if IsClosing then
      Exit; //things may start to disapear..

   if ValidDataRow(RowNum) then begin
      pT := WorkTranList.Transaction_At(RowNum-1);
      //see if Job assigned at trx level
      if pT^.txJob_Code > '' then
         Exit; // Paint Normal

      if pT^.txFirst_Dissection = nil then
         Exit; // Paint Normal

      pd := pT^.txFirst_Dissection;
      TmpPaintString := '';
      while assigned(pd) do begin
         if pd.dsJob_Code <> pT^.txJob_code then begin
           if TmpPaintString > '' then begin // Have Dissection Job
              if (TmpPaintString <> pd.dsJob_Code)
              and (pd.dsJob_Code > '') then begin
                 //Disections not the same
                 TmpPaintString := 'Split';
                 Break; // Split is split...
              end;
           end else if pd.dsJob_Code > '' then
              // First Dissection with a job
              TmpPaintString := pd.dsJob_Code;
        end;
        pd := pd.dsNext;
     end;
     if Sender = CelJob then begin
        // After Job Code
        if TmpPaintString = '' then //No Disection Jobs
           TmpPaintString := pT^.txJob_code;


     end else begin
        // After Job Name
        if (TmpPaintString <> 'Split') then begin
           // Find the Job name instead
           if (TmpPaintString > '') then begin
              Job := MyClient.clJobs.FindCode (TmpPaintString);
              if Assigned(Job) then
                 TmpPaintString := Job.jhHeading
              else
                 TmpPaintString := 'Unknown';
           end else
              TmpPaintString := '';
        end;
     end;
   end else // Row invalid..
      Exit;

   R := CellRect;
   C := TableCanvas;
   C.Brush.Color := CellAttr.caColor;
   C.FillRect(R);
   //draw data
   if CellAttr.caColor <> clHighLight then
      C.Font.Color := clGrayText
   else
      C.Font.Color := CellAttr.caFontColor;
   InflateRect( R, -2, -2 );
   DrawText(C.Handle, PChar( TmpPaintString ), -1 , R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   DoneIt := true;

end;

//------------------------------------------------------------------------------

procedure TfrmCoding.celGstAmtOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//paint blue if GST has been edited
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pT  : pTransaction_Rec;
begin
  If ( data = nil ) then exit;
  if CellAttr.caColor = clHighlight then exit;

  if ValidDataRow(RowNum) then begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     R := CellRect;
     C := TableCanvas;
     pfHiddenAmount.SetValue( Data^ );
     S := PChar( pfHiddenAmount.AsString);

     if (pT^.txFirst_Dissection = nil)
     and (not IsJournal) then begin
        //check is a data row
        if not pT^.txGST_Has_Been_Edited then exit;
        {paint background}
        c.Brush.Color := CellAttr.caColor;
        c.FillRect(R);
        {draw data}
        InflateRect( R, -2, -2 );
        C.Font.Color := bkGSTEditedColor;
        DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
        DoneIt := true;
     end
     else begin
        //transaction is dissected, show total GST amount
        //paint background
        C.Brush.Color := CellAttr.caColor;
        c.FillRect(R);
        //draw data
        C.Font.Color  := clGrayText;
        InflateRect( R, -2, -2 );
        DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
        DoneIt := true;
     end;
  end;
end;
//------------------------------------------------------------------------------

procedure TfrmCoding.celRefOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
  const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If item matches a upc show as green
var
   R   : TRect;
   C   : TCanvas;
   S   : String;
   pT : pTransaction_Rec;
begin
   If ( data = nil ) then exit;
   //check is a data row
   if ValidDataRow(RowNum) then begin
      pT   := WorkTranList.Transaction_At(RowNum-1);
      SetTranUPCStatus( pT);
      if not (( pT^.txUPC_Status in [ucMatchingRef]) or ( pT^.txMatched_Item_ID <> 0)) then
         exit;

      R := CellRect;
      C := TableCanvas;
      C.Brush.Color := CellAttr.caColor;
      C.Font.Color  := CellAttr.caFontColor;
      //highlight if reference matches
      if ( pT^.txUPC_Status in [ucMatchingRef]) then begin
         C.Brush.Color := clGreen;
         C.Font.Color  := clWhite;
      end;
      //paint background
      C.FillRect( R );
      //paint border
      C.Pen.Color := CellAttr.caColor;
      C.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);
      InflateRect( R, -2, -2 );
      //draw data
      S := GetFormattedReference( pT);
      DrawText(C.Handle, PChar( S ), StrLen( PChar( S )), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
      DoneIt := True;
   end;
end;

procedure TfrmCoding.celTaxInvKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg: TWMKey;
begin
  if Key = VK_SPACE then
  begin
    Msg.CharCode := VK_RIGHT;
    celTaxInv.SendKeyToTable(Msg);
  end;
end;

procedure TfrmCoding.celTaxInvMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Msg: TWMKey;
  Swapped: Boolean;
  pT: pTransaction_Rec;
begin
  Swapped := CodingMouseUp(Sender, Button, Shift, X, Y);
  if (X > 20) and (X < 33) and (Y > 6) and (Y < 19) then
  begin
    if (not Swapped) and (ColumnFmtList.ColIsEditable(ColumnFmtList.GetColNumOfField( ceTaxInvoice ))) and
        (not RestrictedMode) then
    begin
      if tblCoding.InEditingState then
        tblCoding.StopEditingState(true)
      else
        tblCoding.StartEditingState;      
      pT := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);
      pT.txTax_Invoice_Available := not pT.txTax_Invoice_Available;
    end;
    Msg.CharCode := VK_RIGHT;
    celTaxInv.SendKeyToTable(Msg);
  end
  else
    tblCoding.StopEditingState(true);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetSortOrder(NewSortOrder: integer; AlwaysSet: Boolean = False);
var
  i : integer;
  SortOrder : Integer;
begin
  TranSortOrder  := NewSortOrder;

  case NewSortOrder of
    csAccountCodeXLON : SortOrder := csAccountCode;
    csReference : if IsJournal then
                     SortOrder  := csReference
                  else
                     SortOrder := csChequeNumber;
  else
    SortOrder  := NewSortOrder;
  end;
  //update sort column in the table
  with ColumnFmtList do begin
    for i := 0 to Pred( ItemCount ) do begin
      if  (ColumnDefn_At(i)^.cdSortOrder = SortOrder)
      and (AlwaysSet or (not ColumnDefn_At(i)^.cdHidden)) then begin
         tblCoding.SortedCol := i;
         if (NewSortOrder = csDateEffective)
         and (ColumnDefn_At(i)^.cdFieldID = ceBalance) then
            Continue;
        Break;
      end;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.LoadWTLNewSort(NewSortOrder: integer; AlwaysSet: Boolean = False; ForceSort: Boolean = False);
begin
   if AlwaysSet or ( TranSortOrder <> NewSortOrder ) then
     SetSortOrder(NewSortOrder, ForceSort);
   LoadWTLMaintainPos;
   tblCoding.Refresh;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.tblCodingLockedCellClick(Sender: TObject; RowNum,
  ColNum: Integer);
var
   NewSortOrder : integer;
begin
   NewSortOrder := ColumnFmtList.ColumnDefn_At(ColNum)^.cdSortOrder;
   if NewSortOrder = -1 then exit;
   if (NewSortOrder = csAccountCode) then
   begin
     //special processing for Account Code XLON
     if ( MyClient.clFields.clCountry = whAustralia) and
       ( MyClient.clFields.clAccounting_System_Used = saXlon) and
       ( Globals.PRACINI_UseXLonChartOrder) then
       NewSortOrder := csAccountCodeXLON;
   end;
   LoadWTLNewSort(NewSortOrder);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   RowEstimate, ColEstimate : integer;
begin
   if not ( tblCoding.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrInLocked] ) then
   begin
      tblCoding.Cursor := crDefault;
   end
   else begin
      if ( ColumnFmtList.ColumnDefn_At( ColEstimate ).cdSortOrder <> -1) then
         tblCoding.Cursor := crHandPoint
      else
         tblCoding.Cursor := crDefault;
   end;
   if StartFocus then
   begin
    tblCoding.SetFocus;
    Self.BringToFront;
    StartFocus := False;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Catch Right Click and decide which PopUp to display
   procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
   var
      ClientPt, ScreenPt : TPoint;
   begin
      ClientPt.x := x;
      ClientPt.y := y;
      ScreenPt   := tblCoding.ClientToScreen(ClientPt);
      PopMenu.Popup(ScreenPt.x, ScreenPt.y);
   end;
var
  ColEstimate, RowEstimate : integer;
begin
  //estimate where click happened
  if tblCoding.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;

  if (Button = mbRight) then begin
     // Get Column Type from Column
     case ColumnFmtList.ColumnDefn_At( ColEstimate )^.cdFieldID of
        ceStatus : begin
           if ( RowEstimate = 0 ) then
           begin  //Show when Right click on heading only
            //Only show popup in Books if the user is allowed
              if Assigned(AdminSystem) or MyClient.clExtra.ceAllow_Client_Unlock_Entries then
                ShowPopup( x,y,popTransfer);  //popTransfer
           end
           else
           begin
              tblCoding.ActiveRow := RowEstimate;
              ShowPopup( x,y,popCoding);
           end;
        end;
        ceReference : begin
          if ( RowEstimate = 0 ) then
            begin  //Show when Right click on heading only
               if Isjournal then
                  ShowPopup( x,y,popCoding)
               else
                  ShowPopup( x,y,popReference);
            end
           else
           begin
              tblCoding.ActiveRow := RowEstimate;
              ShowPopup( x,y,popCoding);
           end;
        end;
        ceGSTClass, ceGSTAmount : begin
           if ( RowEstimate = 0 ) then
           begin  //Show when Right click on heading only
              ShowPopup( x,y,popGST);
           end
           else
           begin
              tblCoding.ActiveRow := RowEstimate;
              ShowPopup( x,y,popCoding);
           end;
        end;
        else begin
          if (RowEstimate > 0) then
          begin
            //don't move activerow if right click is on the header
            tblCoding.ActiveRow := RowEstimate;
          end;
          ShowPopup( x,y,popCoding);
        end;
     end;
  end;

  if (Button = mbLeft) then begin
     //try to detect a left click on the column header row.  End editing state so
     //that the column sort can fire.
     if ( RowEstimate = 0) then begin
        tblCoding.StopEditingState( true);
        exit;
     end;

     if ColumnFmtList.ColumnDefn_At( ColEstimate )^.cdFieldID in [ ceAmount, ceForexAmount ] then
       MouseDownInAmountCol := true
     else
       MouseDownInAmountCol := false;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CodingMouseUp(Sender, Button, Shift, X, Y);
end;


function TfrmCoding.CodingMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ColEstimate, RowEstimate : integer;
  R : TRect;
  Msg: TWMKey;
  pT: pTransaction_Rec;
begin
  Result := False;
  MouseDownInAmountCol := false;

  //estimate where click happened
  if tblCoding.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;

  if (Button = mbLeft) then
    begin
      //see if in account col and has super fund fields
      if CanUseSuperFields and ( ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID in [ ceAmount, ceForexAmount ] ) then
        begin
          //get row estimate
          if not ValidDataRow(RowEstimate) then
            exit;

          R := GetCellRect( RowEstimate, ColEstimate );
          R.Left := R.Right - 5;
          R.Bottom := R.Top + 5;

          if PtInRect( R, tblCoding.ClientToScreen( Point( x,y))) then
            begin
              DoEditSuperFields;
            end;
        end;

      if ( ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID = ceTaxInvoice) and
         ColumnFmtList.ColIsEditable(ColEstimate) and (not RestrictedMode) then
        begin
          //get row estimate
          if not ValidDataRow(RowEstimate) then
            exit;

          R := GetCellRect( RowEstimate, ColEstimate );
          R.Left := R.Left + 20;
          R.Right := R.Right - 22;
          R.Bottom := R.Bottom - 7;
          R.Top := R.Top + 7;

          if PtInRect( R, tblCoding.ClientToScreen( Point( x,y))) then
          begin
            pT := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);
            pT.txTax_Invoice_Available := not pT.txTax_Invoice_Available;
            Result := True;
            tblCoding.StartEditingState;
            Msg.CharCode := VK_RIGHT;
            celTaxInv.SendKeyToTable(Msg);
          end
          else
            tblCoding.StopEditingState(true);
        end;

{$IFDEF SmartLink}
      if ( ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID = ceDocument) then
      begin
        //see if an icon has been clicked on
        //get row estimate
        if not ValidDataRow(RowEstimate) then
          exit;

        if PtInRect( GetCellRect( RowEstimate, ColEstimate ), tblCoding.ClientToScreen( Point( x,y))) then
        begin
          DoLaunchFingertips;
        end;
      end;
{$ENDIF}
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.FindUncoded( const TheCurrentRow : Integer; IncludeCurrent: Boolean = False ) : Integer;
// Search Transaction list for Uncoded Entries.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = WorkTranList Row + 1

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
begin
   result := -1;
   if ( WorkTranList.ItemCount = 0 ) then Exit;

   CurrentEntry := TheCurrentRow - 1; //Adjust to WorkTranList Entry No

   i := CurrentEntry;
   if not IncludeCurrent then
     IncEntry( i );
   Repeat
      if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
        foundUnCoded := IsUncoded( WorkTranList.Transaction_At( i ))
      else
        foundUnCoded := (WorkTranList.Transaction_At(i).txAccount = '');

      if FoundUnCoded then
      begin
        Result := (i + 1); //Adjust to Grid Row No
        Exit;
      end;

      IncEntry( i );
   Until ( i = CurrentEntry );

   //if everything else is coded then check current entry also
   if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
     foundUnCoded := IsUncoded( WorkTranList.Transaction_At( i ))
   else
     foundUnCoded := (WorkTranList.Transaction_At(i).txAccount = '');

   if FoundUnCoded then Result := (i + 1);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.FindNote( const TheCurrentRow : Integer ) : Integer;
// Search Transaction list for notes
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Note Entry or -1.
// Note that this routine accepts and returns Grid Row which = WorkTranList Row + 1

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
   FoundNote : boolean;
   pD: pDissection_Rec;
begin
   result := -1;
   if ( WorkTranList.ItemCount = 0 ) then Exit;

   CurrentEntry := TheCurrentRow - 1; //Adjust to WorkTranList Entry No

   i := CurrentEntry;
   IncEntry( i );
   Repeat
      FoundNote := False;
      if (WorkTranList.Transaction_At(i).txNotes <> '') or
         (WorkTranList.Transaction_At(i).txECoding_Import_Notes <> '') then
         foundNote := True
      else if WorkTranList.Transaction_At(i).txFirst_Dissection <> nil then
      begin
       pD := WorkTranList.Transaction_At(i).txFirst_Dissection;
       while ( pd <> nil) do begin
          if (pD^.dsNotes <> '') or (pD^.dsECoding_Import_Notes <> '') then
          begin
            foundNote := True;
            Break;
          end;
          pD := pD^.dsNext;
       end;
      end;

      if FoundNote then
      begin
        Result := (i + 1); //Adjust to Grid Row No
        Exit;
      end;

      IncEntry( i );
   Until ( i = CurrentEntry );

   //if everything else is coded then check current entry also
  if (WorkTranList.Transaction_At(i).txNotes <> '') or
     (WorkTranList.Transaction_At(i).txECoding_Import_Notes <> '') then
     foundNote := True
  else if WorkTranList.Transaction_At(i).txFirst_Dissection <> nil then
  begin
   pD := WorkTranList.Transaction_At(i).txFirst_Dissection;
   while ( pd <> nil) do begin
      if (pD^.dsNotes <> '') or (pD^.dsECoding_Import_Notes <> '') then
      begin
        foundNote := True;
        Break;
      end;
      pD := pD^.dsNext;
   end;
  end;

   if FoundNote then Result := (i + 1);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoGotoNextNote;
var
  NextPos : integer;
begin
  if ( WorkTranList.ItemCount > 0 ) then begin
     NextPos := FindNote( tblCoding.ActiveRow );
     if NextPos < 0 then
        HelpfulInfoMsg( 'There are no transactions with notes', 0 )
     else
        tblCoding.ActiveRow := NextPos;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoGotoNextUncoded(Silent: Boolean = False; IncludeCurrent: Boolean = False);
var
  NextPos : integer;
begin
  if ( WorkTranList.ItemCount > 0 ) then begin
     NextPos := FindUncoded( tblCoding.ActiveRow, IncludeCurrent );
     if NextPos < 0 then
     begin
        if not Silent then
          HelpfulInfoMsg( 'All the entries have been coded', 0 );
     end
     else
        tblCoding.ActiveRow := NextPos;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoDitto;
Var
   pT             : pTransaction_Rec;
   pPrev          : pTransaction_Rec;
   Msg            : TWMKey;
   FieldId        : integer;
   DittoOK        : boolean;
Begin
   with tblCoding do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if alreading in edit state

      pT := WorkTranList.Transaction_At(ActiveRow-1);

      if pT^.txLocked then exit;
      if pT^.txDate_Transferred <> 0 then exit;

      pPrev := WorkTranList.Transaction_At(ActiveRow-2);

      DittoOK := false;

      FieldID := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
      //verify field ok to edit
      case FieldID of
         ceAccount: begin
            //make sure current cell is blank and that previous trx is not dissected
            if (Trim(TEdit(celAccount.CellEditor).Text) = '') and (pPrev^.txFirst_Dissection = nil)  then begin
               TEdit(celAccount.CellEditor).Text := Trim(pPrev^.txAccount);
               DittoOK := true;
            end;
         end;

         ceNarration: begin
            if (Trim(TEdit(celNarration.CellEditor).Text) = '') then begin
               TEdit(celNarration.CellEditor).Text := Trim(pPrev^.txGL_Narration);
               DittoOK := true;
            end;
         end;

         ceGSTClass : begin
            if ( Trim(TEdit(celGSTCode.CellEditor).Text) = '') then begin
               TEdit(celGSTCode.CellEditor).Text := GetGSTClassCode( MyClient, pPrev^.txGST_Class );
               DittoOK := true;
            end;
         end;

         ceQuantity: begin
            if (TOvcNumericField(celQuantity.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celQuantity.CellEditor).AsFloat := ( pPrev^.txQuantity / 10000 );
               DittoOK := true;
            end;
         end;

         ceForexRate: begin
            if (TOvcNumericField(celForexRate.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celForexRate.CellEditor).AsFloat := ( pPrev^.txForex_Conversion_Rate );
               DittoOK := true;
            end;
         end;

         cePayee : begin
            if ( TOvcNumericField(celPayee.CellEditor).AsInteger = 0 ) then begin
               TOvcNumericField(celPayee.CellEditor).AsInteger := pPrev^.txPayee_Number;
               DittoOK := true;
            end;
         end;

         ceJob : begin
             if (Trim(TEdit(celJob.CellEditor).Text) = '') then begin
               TEdit(celJob.CellEditor).Text := Trim(pPrev^.txJob_Code);
               DittoOK := true;
            end;
         end;
      end;

      if DittoOK then begin
         //if field was updated the save the edit and move right
         if not StopEditingState(True) then exit;
         if(FieldID in [ ceAccount, ceNarration, ceOtherParty, ceParticulars, ceGSTClass,
                                   ceGSTAmount, ceQuantity, cePayee, ceJob]) then begin
            Msg.CharCode := VK_RIGHT;
            celAccount.SendKeyToTable(Msg);
         end;
      end
      else begin
         //field not updated, abandon edit and don't move off current cell
         StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ClearShowUncodedOnly;
begin
   if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);
   ShowAllTran := SHOW_ALL_TX;
   LoadWTLMaintainPos;
   tblCoding.Refresh;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ClearSuperfields(Sender: TObject);
var pt: pTransaction_Rec;
begin
   if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);

   if not ValidDataRow(tblCoding.ActiveRow) then
      Exit;

   if not CanUseSuperFields then
     Exit;

   with tblCoding do
      pT := WorkTranList.Transaction_At(ActiveRow-1);
   if not Assigned(Pt) then
      Exit;
   if pt.txLocked then
      Exit;
   if pt.txDate_Transferred <> 0 then
      Exit;

   if YesNoDlg.AskYesNo( 'Clear Superfund Details',
                         'Do you want to remove all Superfund details for this entry?',
                         dlg_no, 0) <> DLG_Yes then
     Exit;

   ClearSuperFundFields(pt);
   pT.txCoded_By := cbManual;//So it gets cleaned up below..
   AccountEdited(pT);

   RedrawRow;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetSearchText(const Value: string);
begin
  btnFind.Enabled := Value > '';
  if not SameText (FSearchText, Value) then begin
     FSearchText := uppercase(Value);
     LoadWTLMaintainPos;
  end;
end;

procedure TfrmCoding.SetSearchVisible(const Value: Boolean);
begin
   pnlSearch.Visible := Value;
   miSearch.Checked :=  Value;

   UserINI_CES_Show_Find := Value;

   if Value
   and EBFind.Visible then
      EBFind.SetFocus
   else
      if tblCoding.Visible then
         tblCoding.SetFocus;

   UpdateSortByMenu;
end;

procedure TfrmCoding.SetShowNoNotesOnly;
begin
  if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);
   ShowAllTran := SHOW_NoNOTES_TX;
   LoadWTLMaintainPos;


   if WorkTranList.ItemCount = 0 then begin
      tblCoding.Refresh;
      HelpfulInfoMsg( 'There are no entries without notes. '+SHORTAPPNAME+ ' will display all entries.', 0);
      ClearShowUncodedOnly;
   end;
end;

procedure TfrmCoding.SetShowNotesOnly;
begin
  if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);
   ShowAllTran := SHOW_NOTES_TX;
   LoadWTLMaintainPos;

   if WorkTranList.ItemCount = 0 then begin
      tblCoding.Refresh;
      HelpfulInfoMsg( 'There are no entries with notes. '+SHORTAPPNAME+ ' will display all entries.', 0);
      ClearShowUncodedOnly;
   end;
end;

procedure TfrmCoding.SetShowUncodedOnly;
begin
   if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);
   ShowAllTran := SHOW_UNCODED_TX;
   LoadWTLMaintainPos;

   if WorkTranList.ItemCount = 0 then begin
      tblCoding.Refresh;
      HelpfulInfoMsg( 'There are no uncoded entries remaining. '+SHORTAPPNAME+ ' will display all entries.', 0);
      ClearShowUncodedOnly;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetShowUnReadNotesOnly;
begin
   if tblCoding.InEditingState then
     tblCoding.StopEditingState(True);
   ShowAllTran := SHOW_UnreadNOTES_TX;
   LoadWTLMaintainPos;

   if WorkTranList.ItemCount = 0 then begin
      tblCoding.Refresh;
      HelpfulInfoMsg( 'There are no entries with unread notes. '+SHORTAPPNAME+ ' will display all entries.', 0);
      ClearShowUncodedOnly;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Menu Clicks
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.mniRecalcGSTClick(Sender: TObject);
begin
   DoRecalculateGST;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.mniSetTransferFlagsClick(Sender: TObject);
begin
   DoSetTransferDate; //Date <> 0 is Transfer True
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.miFindClick(Sender: TObject);
begin
   DoFind;
end;

procedure TfrmCoding.miSearchClick(Sender: TObject);
begin
  SearchVisible := not SearchVisible;
end;

procedure TfrmCoding.mniClearTransferFlagsClick(Sender: TObject);
begin
   DoClearTransferDate; //Date = 0 is Transfer False
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.MemoriseClick(Sender: TObject);
begin
   DoMemorise;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DeleteDissection(Sender: TObject);
var pt: pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   with tblCoding do
      pT := WorkTranList.Transaction_At(ActiveRow-1);
   if Assigned(Pt) then
      DoDeleteDissection(pt);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DeleteJournal(Sender: TObject);
var pt: pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   with tblCoding do
      pT := WorkTranList.Transaction_At(ActiveRow-1);
   if Assigned(Pt) then
      DoDeleteJournal(pt);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DissectionClick(Sender: TObject);
begin
   DoDissection;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SuperClick(Sender : TObject);
begin
  DoEditSuperFields;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ftClick(Sender : TObject);
begin
{$IFDEF SmartLink}
  DoLaunchFingertips;
{$ENDIF}  
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.AccountLookupClick(Sender: TObject);
begin
   DoAccountLookup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.PayeeLookupClick(Sender: TObject);
begin
   DoPayeeLookup;
end;

procedure TfrmCoding.GSTLookupClick(Sender: TObject);
begin
   DoGSTLookup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.GotoNextClick(Sender: TObject);
begin
   DoGotoNextUncoded;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.GotoNextNoteClick(Sender: TObject);
begin
   DoGotoNextNote;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FindClick(Sender: TObject);
begin
   DoFind;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.CloseClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SaveFileClick(Sender: TObject);
begin
   SaveClient(false);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ToggleModeClick(Sender: TObject);
begin
   ToggleColEditMode;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ColConfigureClick(Sender: TObject);
begin
   ConfigureColumns;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ZoomClick(Sender: TObject);
begin
   DoZoom;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ColRestoreClick(Sender: TObject);
begin
   RestoreColumnDefaults;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormActivate(Sender: TObject);
begin
   DoActivateCodingForm;
//   pnlExtraTitleBar.Color := clActiveCaption;
   EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MINIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
   EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_RESTORE,
                  MF_BYCOMMAND or MFS_GRAYED );
   EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MAXIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
   Repaint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormDeactivate(Sender: TObject);
begin
   with tblCoding do begin
      if InEditingState then
         StopEditingState(True);
   end;
   HideCustomHint; // Deactivating the form, so hide the hint window.
   DoDeactivateCodingForm;
//   pnlExtraTitleBar.Color := clInActiveCaption;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.LoadLayoutForThisAcct;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;

   for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
      ColDefn := ColumnFmtList.ColumnDefn_At(i);
      with ColDefn^, BankAccount.baFields do begin
         if baColumn_Width[ cdFieldID] <> 0 then begin
            cdWidth            := BankAccount.baFields.baColumn_Width[ cdFieldID];
            cdRequiredPosition := BankAccount.baFields.baColumn_Order[ cdFieldID];
            cdHidden           := BankAccount.baFields.baColumn_Is_Hidden[ cdFieldID];
            //set status of columns that are editable by default
            if cdFieldId in DefaultEditableCols then
               cdEditMode[ emGeneral] := not baColumn_Is_Not_Editable[ cdFieldID]
            else
               cdEditMode[ emGeneral] := False;
         end
         else begin
            //defaults will be used
            cdWidth            := cdDefWidth;
            cdRequiredPosition := cdDefPosition;
            cdHidden           := cdDefHidden;
            cdEditMode[ emGeneral] := (cdFieldId in DefaultEditableCols);
         end;
      end;
   end;
   //now resort list into correct order
   ColumnFmtList.ReOrder;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SaveLayoutForThisAcct;
var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;

   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);

       BankAccount.baFields.baColumn_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
       BankAccount.baFields.baColumn_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
       BankAccount.baFields.baColumn_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions

       if ColDefn^.cdFieldId in DefaultEditableCols then
         BankAccount.baFields.baColumn_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
     end;

     BankAccount.baFields.baCoding_Sort_Order := CurrentSortOrder;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.LoadTempLayoutForThisAcct;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  //build set of columns that are editable by default
  SetupColDefaultSets;

  for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
     ColDefn := ColumnFmtList.ColumnDefn_At(i);
     with ColDefn^ do begin
        if Temp_Column_Width[ cdFieldID] <> 0 then begin
           cdWidth            := Temp_Column_Width[ cdFieldID];
           cdRequiredPosition := Temp_Column_Order[ cdFieldID];
           cdHidden           := Temp_Column_Is_Hidden[ cdFieldID];
           //set status of columns that are editable by default
           if cdFieldId in DefaultEditableCols then
              cdEditMode[ emGeneral] := not Temp_Column_Is_Not_Editable[ cdFieldID]
           else
              cdEditMode[ emGeneral] := False;
        end
        else begin
           //defaults will be used
           cdWidth            := cdDefWidth;
           cdRequiredPosition := cdDefPosition;
           cdHidden           := cdDefHidden;
           cdEditMode[ emGeneral] := (cdFieldId in DefaultEditableCols);
        end;
     end;
  end;
  //now resort list into correct order
  ColumnFmtList.ReOrder;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SaveTempLayoutForThisAcct;
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  //build set of columns that are editable by default
  SetupColDefaultSets;

  for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
     ColDefn := ColumnFmtList.ColumnDefn_At(i);
     with ColDefn^ do begin
        Temp_Column_Width[ cdFieldID ]     := cdWidth;
        Temp_Column_Is_Hidden[ cdFieldID ] := cdHidden;
        Temp_Column_Order[ cdFieldID ]     := i;    //use the list index position for the current positions
        if cdFieldId in DefaultEditableCols then
           Temp_Column_Is_Not_Editable[ cdFieldID] := not cdEditMode[ emGeneral];
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.CMMouseLeave(var Message: TMessage);
begin
   HideCustomHint; // The mouse has moved outside the form, so hide the hint window
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingTopLeftCellChanging(Sender: TObject;
  var RowNum, ColNum: Integer);
begin
   HideCustomHint; // Hide the hint window if the user is scrolling the entries.
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.BkMouseWheelHandler(Sender: TObject; Shift: TShiftState;
  Delta, XPos, YPos: Word);
begin
  if ( ssShift in Shift )then begin
     if SmallInt(Delta) < 0 then    //need to type cast as a small int so that
       UPDATEMF.SelectNextMDI       //the sign can be tested.  OvcBase.pas should
     else                           //really declare this as SmallInt.
       UPDATEMF.SelectPreviousMDI;
  end
end;
procedure TfrmCoding.btnFindClick(Sender: TObject);
begin
   EBFind.Text := '';
   SearchTimerTimer(nil);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingVSThumbChanged(Sender: TObject;
  RowNum: TRowNum);
Var
   CR     : TPoint;
   MP     : TPoint;
   HR     : TRect;
   Msg    : String;
   SortBy : Integer;
   pT     : pTransaction_Rec;
   A      : pAccount_Rec;
   P     : TPayee;
   ARef   : String[12];
   Code   : Bk5CodeStr;
   Desc   : String[80];
begin
   if not ValidDataRow(RowNum) then exit;

   with WorkTranList do begin
     pT   := Transaction_At(RowNum-1);
     SortBy := TranSortOrder;
     case SortBy of
        csAccountCode,
        csAccountCodeXLON : begin
           Code := pT^.txAccount;
           If Code = '' then
              Msg := '<Uncoded>'
           else if pT^.txFirst_Dissection <> nil then
              Msg := '<Dissected>'
           else begin
              A := MyClient.clChart.FindCode( Code );
              if Assigned( A ) then
                 Msg := Code + ' ' + A^.chAccount_Description
              else
                 Msg := Code + ' <Invalid Code>';
           end;
        end;
        csByOtherParty : begin
           Desc := pT^.txOther_Party;
           if TrimSpacesS( Desc ) = '' then
              Msg := ''
           else
              Msg := Desc;
        end;
        csByParticulars : begin
           Desc := pT^.txParticulars;
           if TrimSpacesS( Desc ) = '' then
              Msg := ''
           else
              Msg := Desc;
        end;
        csByStatementDetails : begin
           Desc := pT^.txStatement_Details;
           if TrimSpacesS( Desc ) = '' then
              Msg := ''
           else
              Msg := Desc;
        end;
        csByEntryType : begin
           Msg := IntToStr(pT^.txType)+ ':' + MyClient.clFields.clShort_Name[pT^.txType];
        end;
        csbyNarration : begin
           Desc := pT^.txGL_Narration;
           if TrimSpacesS( Desc ) = '' then
              Msg := ''
           else
              Msg := Desc;
        end;
        csbyValue         : Msg := MakeAmount( pT^.txAmount );
        csDateEffective   : Msg := BkDate2Str( pT^.txDate_Effective );
        csReference,
        csChequeNumber : begin
           ARef := GetFormattedReference( pT);
           ZTrim( ARef );
           Msg := ARef;
        end;
        csDatePresented : Msg := 'Pres: '+BkDate2Str( pT^.txDate_Presented );
        csByAnalysis : begin
           Desc := pT^.txAnalysis;
           if TrimSpacesS( Desc ) = '' then
              Msg := ''
           else
              Msg := Desc;
        end;
        csByPayee : begin
           if pT^.txPayee_Number <> 0 then begin
              Msg := inttostr( pT^.txPayee_Number);
              P := MyClient.clPayee_List.Find_Payee_Number( pT^.txPayee_Number);
              if Assigned( P) then
                 Msg := Msg + ' ' + P.pdName
              else
                 Msg := Msg + ' <Unknown Payee>';
           end
           else
              Msg := '0';
        end;
        csByPayeeName : begin
           if pT^.txPayee_Number <> 0 then begin
              P := MyClient.clPayee_List.Find_Payee_Number( pT^.txPayee_Number);
              if Assigned( P) then
                 Msg := P.pdName
              else
                 Msg := 'Unknown Payee';
           end
           else
              Msg := '';
        end;
        csByAccountDesc : begin
           Code := pT^.txAccount;
           If Code = '' then
              Msg := '<Uncoded>'
           else if pT^.txFirst_Dissection <> nil then
              Msg := '<Dissected>'
           else begin
              A := MyClient.clChart.FindCode( Code );
              if Assigned( A ) then
                 Msg := A^.chAccount_Description + ' ' + Code
              else
                 Msg := '<Invalid Code>';
           end;
        end;
        csByGSTClass: begin
          Msg := GetGSTClassCode(MyClient, pT^.txGST_Class);
        end;
        csByGSTAmount: begin
          Msg := MakeAmount(pT^.txGST_Amount);
        end;
        csByQuantity: begin
          Msg := MakeAmount(pT^.txQuantity);
        end;
        csByDocumentTitle : begin
          if pT^.txDocument_Title <> '' then
            Msg := 'Manage'
          else
            Msg := 'Add';
        end;

        csByCodedBy : Msg := cbNames[ pT^.txCoded_By];
     end;
     HideCustomHint;
     if Msg <> '' then begin
        CR := ClientToScreen( ClientRect.BottomRight );
        MP := Mouse.CursorPos;
        HR := FHint.CalcHintRect( Screen.Width, Msg, NIL );
        Inc( HR.Bottom, 2 );
        Inc( HR.Right, 6 );
        OffsetRect( HR, CR.X - GetSystemMetrics( SM_CXVSCROLL ) - HR.Right, MP.Y );
        FHint.Color := Application.HintColor;
        FHint.ActivateHint( HR, Msg );
     end;
  end;
end;

procedure TfrmCoding.tbtnCloseClick(Sender: TObject);
begin
  SearchVisible := False;
end;

procedure TfrmCoding.tmrPayeeTimer(Sender: TObject);
var
   pT, pNew: pTransaction_Rec;
   OldPayeeNo: Integer;
   OldJob: string;
   OD: tstDate;
   OM: Money;
   OER: Double;
   DefaultGSTClass:  byte;
   DefaultGSTAmt: money;
begin
   if tmrPayee.Enabled then
      tmrPayee.Enabled := False// So I Don't  do it agian
   else
      Exit; // might be handeled in CloseQuery
   if Assigned(Sender) //From Timer
   and isClosing then //Too late
      Exit;

   if ValidDataRow(TmrRow) then begin
      pT := WorkTranList.Transaction_At(TmrRow-1);

      case tmrPayee.Tag of
      cepayee : if ( pT^.txPayee_Number <> tmpPayee ) then begin
           OldPayeeNo := pT^.txPayee_Number;
           pT^.txPayee_Number := tmpPayee;
           if PayeeEdited(pT) then
           begin
              pT^.txHas_Been_Edited := true;
           end
           else
              pT^.txPayee_Number := OldPayeeNo;
        end;
      ceJob : if not Sametext( pT^.txJob_Code, tmpJob) then begin
           OldJob  := pT^.txJob_Code;

           pT^.txJob_Code := tmpJob;
           if JobEdited(pT) then
           begin
              pT^.txHas_Been_Edited := true;
              if pt^.txCoded_By in [cbMemorisedC,cbMemorisedM] then
                 pT^.txCoded_By := cbManual;
           end
           else
              pT^.txJob_Code := OldJob;
        end;
      ceEffDate : if (PT.txDate_Effective <> TmpDate) then begin
              if TmpDate = 0 then
                 Exit; // Invalid date entered, but forced through (Case 11022)

              if IsJournal then begin
                 if RejectJournalDate(TmpDate) then
                    Exit;
              end else begin
                 if RejectHistoricalDate(TmpDate) then
                    Exit;
                 OD := pT^.txDate_Effective;
                 pT^.txDate_Effective := tmpInteger;
                 if BankAccount.IsAForexAccount then begin

                   OER := pT^.txForex_Conversion_Rate;
                   pT^.txForex_Conversion_Rate := BankAccount.Default_Forex_Conversion_Rate(tmpInteger);
                   if OER <> pT^.txForex_Conversion_Rate then begin
//                      OM := pT.txAmount;
                      OM := pT.Local_Amount;
//                      if pT.txForex_Conversion_Rate <> 0.0 then
//                         pT.txAmount := Round( pT.txForeign_Currency_Amount / pT.txForex_Conversion_Rate )
//                      else
//                         pT.txAmount := 0;
//                      if pT.txAmount <> OM then begin
                         if pT^.txFirst_Dissection <> nil then begin
                            if (not DissectEntry(pT, false, false, BankAccount)) then begin
                               pT.txDate_Effective := OD;
                               pT.txAmount := OM;
                               pT^.txForex_Conversion_Rate := OER;
                               HelpfulInfoMsg('The tranaction date has been changed back.',0);
                               Exit;
                            end;
                         end;
                         //Force Recalc of GST if not dissected
                         if pT^.txFirst_Dissection = nil then begin
                            GSTClassEdited(pT);
                            //see if gst matches default now
                            with pT^ do begin
//                               CalculateGST( myClient, txDate_Effective, txAccount, txAmount, DefaultGSTClass, DefaultGSTAmt);
                               CalculateGST( myClient, txDate_Effective, txAccount, Local_Amount, DefaultGSTClass, DefaultGSTAmt);
                               txGST_Has_Been_Edited := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
                            end;
                         end;
//                      end;
                   end;
                 end;
              end;
              // If date has changed we must remove and re-insert into the tx list
              tblCoding.AllowRedraw := False;
              try
                 pNew := BankAccount.baTransaction_List.New_Transaction;
                 Move( pT^, pNew^, SizeOf( TTransaction_Rec));
                 WorkTranList.DelFreeItem(WorkTranList.Transaction_At(tblCoding.ActiveRow-1));

                 BankAccount.baTransaction_List.Delete(pT);

                 pNew^.txDate_Effective := TmpDate;
                 if not IsJournal then
                    pNew^.txDate_Presented := TmpDate;
                 BankAccount.baTransaction_List.Insert_Transaction_Rec(pNew, False);

                 AdjustDateRange(TmpDate);
                 LoadWorkTranList;
                 RepositionOn(pNew);

              finally
                tblCoding.InvalidateTable;
                tblCoding.AllowRedraw := True;
              end;
        end;

      end;

      RedrawRow(TmrRow);

   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//function TfrmCoding.GetHintPosition(const RowNum, ColNum: Integer): TPoint;
//var
//   Where   : TPoint;
//begin
//   Where.X := tblCoding.Left + tblCoding.ColOffset[ Succ( ColNum ) ];
//   Where.Y := tblCoding.Top + tblCoding.RowOffset[ RowNum ] + tblCoding.Rows.Height[ RowNum ];
//   Result  := ClientToScreen( Where );
//end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.HideCustomHint;
var
   R : TRect;
begin
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then begin // Find where the Hint is, so we can redraw the cells beneath it.
         GetWindowRect( FHint.Handle, R );
         R.TopLeft      := tblCoding.ScreenToClient(R.TopLeft);
         R.BottomRight  := tblCoding.ScreenToClient(R.BottomRight);
         FHint.ReleaseHandle;
         HintShowing    := false;
         tblCoding.AllowRedraw := False;
         tblCoding.InvalidateCellsInRect( R );
         tblCoding.AllowRedraw := True;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.GetCellRect(const RowNum, ColNum: Integer): TRect;
begin
  Result.Top    := tblCoding.Top  + tblCoding.RowOffset[ RowNum ];
  Result.Bottom := tblCoding.Top  + tblCoding.RowOffset[ RowNum ] + tblCoding.Rows[ RowNum ].Height;
  Result.Left   := tblCoding.Left + tblCoding.ColOffset[ ColNum ];
  Result.Right  := tblCoding.Left + tblCoding.ColOffset[ ColNum ] + tblCoding.Columns[ ColNum ].Width;
  Result.TopLeft := ClientToScreen( Result.TopLeft );
  Result.BottomRight := ClientToScreen( Result.BottomRight );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.GetIsJournal: Boolean;
begin
   if Assigned(BankAccount) then
      Result := BankAccount.IsAJournalAccount
   else
      Result := False;
end;
function TfrmCoding.GetSearchVisible: Boolean;
begin
   result := PnlSearch.Visible;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ShowCodingHint(const RowNum, ColNum: Integer;
  HintMsg: String);
var
   R : TRect;
begin
   HideCustomHint; // Hide any existing hint
   If INI_ShowCodeHints and ( HintMsg<>'' ) then
   begin
     // Make sure the mouse is on the form
     if PtInRect( tblCoding.BoundsRect, ScreenToClient( Mouse.CursorPos ) ) then
     begin
       R := GetCellRect( RowNum, ColNum );
       NewHints.ShowCustomHint( FHint, R, HintMsg );
       HintShowing := true;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmCoding.ShowHintForCell( const RowNum, ColNum : integer);
var
  pT         : pTransaction_Rec;
  FieldID    : integer;
  CustomHint : string;

begin
  if not ValidDataRow(RowNum) then
     exit;

  //show hints, only long hints appear
  pT   := WorkTranList.Transaction_At(RowNum-1);
  FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
  CustomHint := '';

  case FieldID of
    ceAccount : CustomHint := GetCodeEntriesHint( Bank_Account, pT, INI_ShowCodeHints );
    ceEffDate,
    ceAction : if isjournal then
                  CustomHint := GetCodeEntriesHint( Bank_Account, pT, INI_ShowCodeHints );

    cePayee : CustomHint := GetPayeeHint(pT, INI_ShowCodeHints);
    ceJob : CustomHint := GetJobHint(PT, INI_ShowCodeHints);
  end;

  if CustomHint <> '' then
    ShowCodingHint( RowNum, ColNum, CustomHint );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.WMVScroll(var Msg: TWMScroll);
begin
   HideCustomHint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
class function TfrmCoding.CreateAndSetup( aOwner        : Forms.TForm;
                                          aBankAccount  : TBank_Account;
                                    const aTranDateFrom : TStDate;
                                    const aTranDateTo   : TStDate;
                                          CodingOptions: TCodingOptions) : TfrmCoding;
var
  ThisForm    : TfrmCoding;
  SectionName : string;
begin
   //create the form
   ThisForm := TfrmCoding.Create( aOwner);
   with ThisForm do begin
      BankAccount := aBankAccount;
      BankPrefix  := copy(BankAccount.baFields.baBank_Account_Number, 1, 2);
      SectionName := Format( SectionNameTemplate, [ BankPrefix ] );
      fIsForex := Bank_Account.IsAForexAccount;

      tblCoding.AllowRedraw := false;

      //build set of columns that are editable/not editable by default
      SetupColDefaultSets;

      ColumnFmtList := TColFmtList.Create;
      SetupColumnFmtList(ColumnFmtList);
      SetColDefPosition(BankPrefix);

      //Load Settings from Bank Accounts fields
      LoadLayoutForThisAcct;
      SaveTempLayoutForThisAcct;

      BuildTableColumns;
      // Now set tblCoding Events
      with tblCoding do begin
         OnColumnsChanged           := tblCodingColumnsChanged;
         OnActiveCellChanged        := tblCodingActiveCellChanged;
         OnActiveCellMoving         := tblCodingActiveCellMoving;
         OnBeginEdit                := tblCodingBeginEdit;
         OnDoneEdit                 := tblCodingDoneEdit;
         OnEndEdit                  := tblCodingEndEdit;
         OnEnteringRow              := tblCodingEnteringRow;
         OnGetCellData              := tblCodingGetCellData;
         OnGetCellAttributes        := tblCodingGetCellAttributes;
         OnLockedCellClick          := tblCodingLockedCellClick;
         OnMouseDown                := tblCodingMouseDown;
         OnMouseMove                := tblCodingMouseMove;
         OnUserCommand              := tblCodingUserCommand;
      end;

      CreateCodingPopup(BankAccount.IsAJournalAccount);
      TranDateFrom  := aTranDateFrom;
      TranDateTo    := aTranDateTo;
      ShowAllTran   := SHOW_ALL_TX;  //start off showing all transactions
      SetSortOrder( BankAccount.baFields.baCoding_Sort_Order );

      //Setup EditDate defaults
      with celEditDate do begin
        Epoch := BKDATEEPOCH;
        PictureMask := BKDATEFORMAT;
        MaxLength := Length(BKDATEFORMAT);
      end;
      celRef.Access := otxReadOnly;

      // Allow date editing for manual accounts and journals
      if (BankAccount.CanEditTransactions)
      or BankAccount.IsAJournalAccount then
         celRef.Access := otxDefault;

      LoadWorkTranList;

      InitController;

      //set max lengths for cells
      celGSTCode.MaxLength   := GST_CLASS_CODE_LENGTH;
      celAccount.MaxLength   := MaxBk5CodeLen;
      celNarration.MaxLength := MaxNarrationEditLength;

      with tblCoding do begin
         OnMouseWheel := BkMouseWheelHandler; // Use Shifted wheel to move thru forms
         tblCoding.OnVSThumbChanged := tblCodingVSThumbChanged;
         hdrColumnHeadings.ShowSortArrow := true;

         if INI_CODING_FONT_NAME  <> '' then
            Font.Name          := INI_CODING_FONT_NAME;
         if INI_CODING_FONT_SIZE  <> 0  then
            Font.Size          := INI_CODING_FONT_SIZE;
         if INI_CODING_ROW_HEIGHT <> 0  then
            Rows.DefaultHeight := INI_CODING_ROW_HEIGHT;
         CommandOnEnter := ccRight;   //enter key will end edit and move right
      end;

      if CC_RestrictedEditMode in CodingOptions then
        ClearEditAllCol
      else if CC_FullEditMode in CodingOptions then
        SetEditAllCol
      else // use client settings
      begin
        if IsJournal then
           SetEditAllCol
        else
        if not MyClient.clFields.clAll_EditMode_CES then
          ClearEditAllCol
        else
          SetEditAllCol;
      end;

      //Set color for alternate lines in the table
      clStdLineLight := clWindow;
      clStdLineDark := bkBranding.AlternateCodingLineColor;

      with BankAccount, baFields do begin
         if IsAJournalAccount then
           Caption  := 'Journal Entries ' + BankAccount.Title
         else
           Caption  := 'Code Entries '+ BankAccount.Title;

         with lblAcctDetails do
         begin
           if IsAJournalAccount then
             Caption := baBank_Account_Name
           else
             Caption := 'A/C ' + BankAccount.Title;
           Hint    := Caption;  //set so user can see the full details even if form width small
         end;
         if IsAJournalAccount then
            lblTransRange.Caption  := Format('Date Range %s to %s' , [ bkDate2Str( TranDateFrom ),
                                                                  bkDate2Str( TranDateTo )])
         else
            lblTransRange.Caption  := Format('Coding Range %s to %s' , [ bkDate2Str( TranDateFrom ),
                                                                  bkDate2Str( TranDateTo )]);
         //reposition the finalised label so that comes after range label
         lblFinalised.left := lblTransRange.left + lblTransRange.width;
      end;

      UpdateCodedCount;
      //ClearEditAllCol;
      tblCoding.AllowRedraw := true;

      //setup notes panel
      pmiNotesVisible.Checked := BankAccount.baFields.baNotes_Always_Visible;
      rzXBtn.Visible          := BankAccount.baFields.baNotes_Always_Visible;
      rzPinBtn.Visible        := not BankAccount.baFields.baNotes_Always_Visible;

      if BankAccount.baFields.baNotes_Height > ( RzSizePanel1.SizeBarWidth + 1) then begin
         rzSizePanel1.Height := BankAccount.baFields.baNotes_Height;
         rzSizePanel1.ResetHotSpot;
      end;

      if BankAccount.baFields.baNotes_Always_Visible then
         RzSizePanel1.RestoreHotSpot
      else
         RzSizePanel1.CloseHotSpot;

      if CC_GotoFirstUncoded in CodingOptions then
        DoGotoNextUncoded(True, True);

      (* Too much going on..
      if IsJournal then
         if Assigned(WorkTranList) then
           if WorkTranList.ItemCount = 0 then begin
              //PostMessage(ThisForm.Handle,WM_DoNewJournal,0,0);

           end;
      *)
   end;
   result := ThisForm;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveLayoutForThisAcct;
  IsClosing := true;
  if not FIsReloading then begin
     // If it is reloading. this will be taken care of..
     if isjournal then
        JnlUtils32.RemoveJnlAccountIfEmpty(MyClient, BankAccount);
     UpdateMF.DoClosingCodingForm;
     RefreshHomepage ([HPR_Coding], Caption);
  end;
  //MDI Child free on close rather than minimise
  Action := caFree;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmCoding.AdjustDateRange(Value: TStDate): Boolean;
begin
  if (Value > TranDateTo)
  or (Value < TranDateFrom) then begin

     HelpfulInfoMsg( 'This date is outside the current date range,'#13#13 +
                 'The date range will be expanded to include it',0);

     if Value > TranDateTo then
        TranDateTo := Value
     else
        TranDateFrom := Value;

      if IsJournal then
         lblTransRange.Caption  := Format('Date Range %s to %s' , [ bkDate2Str( TranDateFrom ),
                                                                  bkDate2Str( TranDateTo )])
      else
         lblTransRange.Caption  := Format('Coding Range %s to %s' , [ bkDate2Str( TranDateFrom ),
                                                                  bkDate2Str( TranDateTo )]);

     Result := True;
  end else
     Result := False;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoReCodeEntries;
//calls autocodeEntries to update auto coding of entries.  Can be caused by
//changes to client or master memorisations which may be triggered by changing the
//finalised flag or editing memorisations.
//reload the transaction list, maintaining the current position
begin
   AutoCodeEntries( MyClient, BankAccount, AllEntries, TranDateFrom, TranDateTo);
   LoadWTLMaintainPos;
   Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoReloadEntries;
//reloads entries and calls refresh.  Called thru ProcessExternalCmd
begin
   LoadWTLMaintainPos;
   Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CountNotJournal : integer;
var
  i,j : integer;
  tempBank : TBank_Account;
begin
  i := 0;
  with MyClient.clBank_Account_List do
  for j := 0 to Pred( itemCount ) do begin
     tempBank := Bank_Account_At( j );
     if not (tempBank.IsAJournalAccount) then
        Inc(i);
  end;
  result := i;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetCodingDateRange(var dateFrom,dateTo : TStDate);
begin
  DateFrom := 0;
  DateTo   := 0;
  if not (EnterCodingDateRange('Select Coding Dates',
                         'Enter the starting and finishing dates for the period you wish to code.',
                         DateFrom,
                         DateTo,
                         BKH_Selecting_the_client_and_date_range,
                         false,
                         true)) then begin
      DateFrom := 0;
      DateTo   := 0;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CodeTheseEntries(DateFrom, DateTo : TStDate; BA: TBank_Account = nil; CodingOptions: TCodingOptions = []);
{load the coding screens.  Also selected from a list on possible bank accounts
 ignoring journal bankaccounts}
var
   CodeScreen : TfrmCoding;
   i,j        : integer;
   cLoaded    : boolean;
   BankAccount : TBank_Account;
   SelectedList : TStringList;

  procedure CreateCodingScreen(d1,d2 : TStDate; Account : TBank_Account);
  var
    Contra_Account_Code : string;
  begin
     {check has entries}
     with myClient do
     begin
       {check contra account is specified}
       if ContraCodeRequired(clFields.clCountry, clFields.clAccounting_System_Used)
       and (Account.baFields.baContra_Account_Code='')
       and (not  Account.IsAJournalAccount ) then
       begin
          Contra_Account_Code := '';
          if GetContra('Enter Bank Account Contra Code'
                  ,SHORTAPPNAME + ' needs to know the account code in your client''s chart for this bank account '
                  + Account.AccountName + '.'+#13+#13
                  +'This account code will be used when the bank account contra entry is generated.'
                  , Contra_Account_Code) then
            Account.baFields.baContra_Account_Code := Contra_Account_Code;
       end;

       AutoCodeEntries(MyClient, Account, AllEntries, d1,d2);

       LockMainForm;
       try
         CodeScreen :=  TfrmCoding.CreateAndSetup( MDIParentForm, Account, d1, d2, CodingOptions);
       finally
         UnlockMainForm;
       end;
     end; {with}
  end;

  var
    found : boolean;
    UserSelectedAccounts : boolean;
begin
  cLoaded   := CodingWindowLoaded;

  if (dateFrom = 0) or (dateTo = 0) then
    exit;  {double check}

  //ask user to select bank accounts to show.  If only one exists it will be
  //selected automatically.
  SelectedList  := TStringList.Create;
  try
    if Assigned(BA) then
    begin
      SelectedList.AddObject(BA.baFields.baBank_Account_Number, BA);
      MyClient.RefreshExchangeSource;
      CreateCodingScreen(dateFrom, DateTo, BA);
    end
    else
    begin
      for i := 0 to MyClient.clBank_Account_List.ItemCount -1 do
      begin
        //if not accounts are loaded then auto select all
        if AccountVisible(TBank_Account(MyClient.clBank_Account_List.Bank_Account_At(i))) or (not cLoaded) then
        begin
          BankAccount := MyClient.clBank_Account_List.Bank_Account_At(i);
          SelectedList.AddObject(BankAccount.baFields.baBank_Account_Number,BankAccount);
        end;
      end;

      //select accounts to show, current account will be selected automatically
      //if it is the only account
      UserSelectedAccounts := false;
      if Globals.Active_UI_Style in [UIS_Simple] then
      begin
        //simple UI only allows the selection of one account at a time
        SelectBankAccount( 'Select Bank Account for Coding',
                           SelectWithTrx,
                           DateFrom, DateTo,
                           False, //no jnls
                           BKH_Selecting_from_multiple_bank_accounts,
                           BankAccount);
        if Assigned( BankAccount) then
        begin
          SelectedList.Clear;
          SelectedList.AddObject( BankAccount.baFields.baBank_Account_Number,BankAccount);
          UserSelectedAccounts := true;
        end;
      end
      else
      begin
        UserSelectedAccounts := SelectBankAccounts('Select Bank Accounts for Coding',SelectedList,selectWithTrx,DateFrom, DateTo,false,
                            BKH_Selecting_from_multiple_bank_accounts );
      end;

      if UserSelectedAccounts then
      begin
        //close all existing coding forms
        UPDATEMF.CloseAllCodingForms;

        {cycle thru bank accounts to see if should be loaded}
        with MyClient do for i := 0 to clBank_Account_List.ItemCount -1 do
        begin
          BankAccount := clBank_Account_List.Bank_Account_At(i);
          found := false;

          for j := 0 to SelectedList.Count-1 do  {run thru selected list to see if included}
          begin
            if BankAccount = TBank_Account(SelectedList.Objects[j]) then
            begin
              found := true;
              break;
            end;
          end;

          if found then begin
              MyClient.RefreshExchangeSource;
              CreateCodingScreen(dateFrom, DateTo, BankAccount);
          end;
        end; {with}
      end;
    end;
  finally
    SelectedList.Free;
  end;

  {turn on/off relevant parts of the form}
  UpdateMenus;
  RefreshHomepage ([HPR_Coding]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCoding(CodingOptions: TCodingOptions = []);
//Allow the user to select a date range for coding, verify that transactions exist
//in that date range.  If ok then call routine to select bank accounts and create
//the coding windows
var
  i,e        : integer;
  DateFrom,
  DateTo     : TSTDAte;
  d,m,y      : integer;
  M1,M2      : TStDate;
  tempBank   : TBank_Account;
  HasTransferredEntries,
  HasUntransferredEntries : boolean;
  HasSomeEntries : boolean;
begin
  if not Assigned( MyClient) then exit;

  {check for accounts}
  if not HasAccounts then exit;
  {check for entries}
  if not HasEntries then exit;

  dateFrom := 0;
  dateTo   := 0;

  GetCodingDateRange(DateFrom, DateTo);
  if (DateFrom = 0) or (DateTo = 0) then exit;

  if DateFrom > 0 then begin
     M2 := DateFrom -1;
     StDateToDMY(M2,d,m,y);
     M1 := DMYToStDate(1,m,y,bkDateEpoch);
     HasTransferredEntries := false;
     HasUnTransferredEntries := false;
     HasSomeEntries := false;
     with myClient.clBank_Account_List do for i := 0 to Pred(itemCount) do begin
        tempBank := Bank_Account_At(i);
        //check to see if untransferred entries in account
        //dont check non-transferable journals
        if ( TempBank.baFields.baAccount_Type in [ btBank,
                                                   btCashJournals,
                                                   btAccrualJournals]) then begin
           with tempBank, baTransaction_List do
              for e := 0 to pred(itemCount) do begin
                with Transaction_At(E)^ do begin
                  if (txDate_Effective >= M1) and
                     (txDate_Effective <= M2) then
                       if txDate_Transferred > 0 then
                          HasTransferredEntries := true
                       else
                          HasUntransferredEntries := true;

                  if (txDate_Effective >= DateFrom) and (txDate_Effective <= DateTo) then
                    HasSomeEntries := true;
                end;
              end;
        end;
     end;
     //check for entries
     if not HasSomeEntries then begin
        HelpfulWarningMsg('There are no Entries for this client in the current '
                         +'date range , '+bkDate2Str(DateFrom)+' to '+bkDate2Str(DateTo)+'.',0);
        exit;
     end;
     if (HasTransferredEntries and HasUnTransferredEntries) then
        HelpfulWarningMsg('This Client has some untransferred entries from the previous month', 0);

    //Everything was OK so ask user for bank accounts , then create windows
    CodeTheseEntries(dateFrom, dateTo, nil, CodingOptions);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celGstAmtKeyPress(Sender: TObject; var Key: Char);
var
   Percentage    : Double;
   NewAmount     : Double;
   pT            : pTransaction_Rec;
   Msg           : TWMKey;
   InclusiveAmt  : Double;
   ExchangeRate  : Double;
begin
  if not ValidDataRow( tblCoding.ActiveRow ) then exit;

  {treat value as percentage}
  if key in ['%','/'] then begin
     //stop any further processing of key
     Key := #0;
     Percentage := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     //check that the percentage value make sense
     if ( Percentage < 0.0 ) or ( Percentage > 100.0) then exit;
     pT  := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);
     //find the new GST Amount
//     InclusiveAmt := Money2Double( pT^.txAmount);
     InclusiveAmt := Money2Double( pT^.Local_Amount);
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
     NewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));

     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblCoding.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end else if key = '£' then begin
     //stop any further processing of key
     Key := #0;
     NewAmount := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     if fIsForex then begin
       //Convert amount to base currency
       pT := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);
       ExchangeRate := pT.Default_Forex_Rate;
       if ExchangeRate > 0 then
         NewAmount := NewAmount / ExchangeRate
       else
         NewAmount := 0;
     end;
     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblCoding.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ConfigureColumns;
var
  i              : integer;
  cRec           : pColumnDefn;
  CurrentFieldID : integer;
  ColumnConfig   : TColumnConfigInfo;
  DefHidden      : Integer;
  ColConfigList  : TColFmtList;
begin
   //make sure not editing
   if not tblCoding.StopEditingState(True) then
      Exit;

   //store current setup so it can be reverted back to
   SaveTempLayoutForThisAcct;
   ColConfigList  := TColFmtList.create;
   with TfrmConfigure.Create(Self) do begin
      try
         ShowTemplates := not IsJournal;
         ConfigBankAccount := BankAccount;
         CodingScreen := CODING_SCREEN;
         SortColumn := CurrentSortOrder;
         // Need to make a copy so it doesnt break the current grid
         ColConfigList.DeleteAll;
         for i := 0 to Pred(ColumnFmtList.ItemCount) do
         begin
          cRec := ColumnFmtList.ColumnDefn_At(i);
          if cRec.cdDefHidden then
            DefHidden := 1
          else
            DefHidden := 0;
          ColConfigList.InsColDefnRec(cRec.cdHeading, cRec.cdFieldID,
            cRec.cdTableCell, cRec.cdWidth, not cRec.cdHidden, cRec.cdEditMode[emRestrict],
            cRec.cdEditMode[emGeneral], cRec.cdSortOrder, cRec.cdDescriptiveName,
            cRec.cdDefPosition, cRec.cdDefWidth, DefHidden);
         end;
         ColumnFormatList := ColConfigList;
         NeverEditable := NeverEditableCols;
         DefaultEditable := DefaultEditableCols;
         AlwaysEditable := [DefaultEditColumn];
         AlwaysVisible := [ceEffDate, ceAmount, ceAccount, ceReference];
         //setup appearance for CES
         lblEditModeDesc.Caption := 'Column can be edited in Edit All Mode';
         //Assign Values to ListBox
         lbColumns.Clear;
         //Build TColumnConfigInfo for the column that can be manipulated in dlg
         for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
            cRec := ColumnFmtList.ColumnDefn_At(i);
            ColumnConfig := TColumnConfigInfo.Create;
            with ColumnConfig do begin
               //set editable state
               if (cRec.cdFieldID in [ ceAccount])
               or (Isjournal and (cRec.cdFieldID in [ ceNarration])) then
                  EditState := esAlwaysEditable
               else
               if cRec.cdFieldID in NeverEditableCols then
                  EditState := esNeverEditable
               else
               if cRec.cdEditMode[ emGeneral] then
                  EditState := esEditable
               else
                  EditState := esNotEditable;
               //set visible state
               if (cRec.cdFieldID in [ ceEffDate, ceAmount, ceAccount, ceReference ])
               or (Isjournal and (cRec.cdFieldID in [ ceNarration]))then
                  VisibleState := vsAlwaysVisible
               else
               if cRec.cdHidden then
               begin
                  VisibleState := vsNotVisible;
                  if EditState = esEditable then
                    EditState := esNotEditable;
               end
               else
                  VisibleState := vsVisible;
               //set default width
               DefaultOrder    := cRec.cdDefPosition;
               ColWidth        := cRec.cdWidth;
               //set default col order
               DefaultWidth    := cRec.cdDefWidth;
               //set default visibility
               DefaultVisible := not cRec.cdDefHidden;
               //set pointer to cRec, used when rebuilding the column list
               Ptr             := cRec;
            end;
            lbColumns.Items.AddObject(cRec^.cdDescriptiveName, ColumnConfig);
         end;
         //set the selected col to the current active col
         lbColumns.ItemIndex := tblCoding.ActiveCol;
         //Show Form************************************************************
         SaveTempLayoutForThisAcct;
         ShowModal;
         //Reorder the columns if OK pressed ***********************************
         if ModalResult = mrOK then begin
            with tblCoding do begin
               AllowRedraw := false;
               OnColumnsChanged := nil;
               //store the active col field id for later use
               CurrentFieldId := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
               //Remove all cols from list and reinsert
               if ColumnListSwapped then begin
                  // lbColumns points to the ColConfigList items
                  ColumnFmtList.FreeAll;
                  ColConfigList.DeleteAll;
               end else begin
                  // lbColumns points to the ColumnFmtList items
                  ColumnFmtList.DeleteAll;
                  ColConfigList.FreeAll;
               end;

               for i := 0 to Pred(lbColumns.Items.Count) do begin
                  ColumnConfig := TColumnConfigInfo(lbColumns.Items.Objects[i]);
                  cRec := ColumnConfig.Ptr;
                  //update column settings
                  cRec.cdHidden := ColumnConfig.VisibleState in [ vsNotVisible ];
                  cRec.cdWidth  := ColumnConfig.ColWidth;
                  cRec.cdEditMode[ emGeneral] := ColumnConfig.EditState in [ esAlwaysEditable, esEditable];
                  ColumnFmtList.Insert( cRec);
               end;
               //Rebuild the table
               BuildTableColumns;
               //Reset the active col in case the col was moved
               if ColumnFmtList.FieldIsEditable( CurrentFieldID) then
                  ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID)
               else
                  ActiveCol := ColumnFmtList.GetColNumOfField( DefaultEditColumn);
               //Reset the sorted col in case the col was moved
               LoadWTLNewSort(SortColumn, True, True);

               OnColumnsChanged := tblCodingColumnsChanged;

               UpdateMF.UpdateSortByMenu;

               AllowRedraw := true;
               //refresh table so is repainted
               Refresh;
            end;
         end
         else
         begin
           LoadTempLayoutForThisAcct;
           tblCoding.Refresh;
         end;
      finally
         //free the ColumnConfig settings objects for each string
         for i := 0 to Pred( lbColumns.Items.Count) do begin
            if Assigned( lbColumns.Items.Objects[ i]) then
               TColumnConfigInfo( lbColumns.Items.Objects[ i]).Free;
         end;
         Release;
         ColConfigList.Free;
      end;
   end;
end;
procedure TfrmCoding.ConvertVATAmount(Sender: TObject);
var
  Key: Char;
begin
  //Conver VAT amount to base currency
  Key := '£';
  if tblCoding.StartEditingState then
    celGstAmtKeyPress(tblCoding, Key);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.RestoreColumnDefaults;
//Sets the column order, visibility, editability, width back to the default settings
var
   CurrentFieldID : integer;
   i              : integer;
   Col            : pColumnDefn;
begin
   //make sure not editing
   if not tblCoding.StopEditingState(True) then
      Exit;

   SaveTempLayoutForThisAcct;

   //build set of columns that can be edited by default
   SetupColDefaultSets;

   with tblCoding do begin
      AllowRedraw := false;
      OnColumnsChanged := nil;
      //store the active col field id for later use
      CurrentFieldId := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
      ColumnFmtList.SetToDefault;
      //reset editability in general mode
      for i := 0 to Pred( ColumnFmtList.ItemCount) do begin
         with ColumnFmtList.ColumnDefn_At( i)^ do begin
            cdEditMode[ emGeneral] := cdFieldID in DefaultEditableCols;
         end;
      end;
      //reset the visibiility
      for i := 0 to Pred( ColumnFmtList.ItemCount) do begin
        Col := ColumnFmtList.ColumnDefn_At( i);
        Col.cdHidden := Col.cdDefHidden;
      end;
      //Rebuild the table
      BuildTableColumns;
      //Reset the active col in case the col was moved
      ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID);
      OnColumnsChanged := tblCodingColumnsChanged;
      // Reset default sort order
      LoadWTLNewSort(csDateEffective, True);

      UpdateMF.UpdateSortByMenu;

      AllowRedraw := true;
   end;
end;
//------------------------------------------------------------------------------

procedure TfrmCoding.celQuantityChange(Sender: TObject);
begin
   //test to see if need to automatically put minus sign
   if AutoPressMinus then
       keybd_event(vk_subtract,0,0,0);
   AutoPressMinus := false;
end;
//------------------------------------------------------------------------------

procedure TfrmCoding.celGstAmtChange(Sender: TObject);
begin
   //test to see if need to automatically put minus sign
  if AutoPressMinus then
      keybd_event(vk_subtract,0,0,0);
  AutoPressMinus := false;
end;

//------------------------------------------------------------------------------
type
   TMatchingItemsInfo = record
      miLockedStr        : string;
      miDate_Effective   : integer;
      miReference        : string[12];
      miAmount           : Money;
      miAccount          : bk5CodeStr;
      miAccountDesc      : string;
   end;
//------------------------------------------------------------------------------

procedure TfrmCoding.barCodingStatusClick(Sender: TObject);
const
   MaxLinesToShow = 20;
   MaxAmountWidth = 12;
var
   R        : TRect;
   ClientPt : TPoint;
   ScreenPt : TPoint;
   pT       : pTransaction_Rec;
   HintStr  : string;
   i        : integer;
   T        : pTransaction_Rec;
   S        : string;
   Code     : bk5CodeStr;
   A        : pAccount_Rec;
   miArray  : Array[ 1..MaxLinesToShow] of TMatchingItemsInfo;
   LineNo   : integer;
begin
   HintStr := '';
   LineNo  := 0;

   if not ValidDataRow(tblCoding.ActiveRow) then exit;

   with WorkTranList do begin
     pT   := Transaction_At(tblCoding.ActiveRow-1);

     if pT^.txUPI_State in [ upNone, upUPC, upUPD, upUPW] then exit;

     //find entries which are matched against same original transaction
     if pT^.txMatched_Item_ID <> 0 then begin
        for i := 0 to Pred( BankAccount.baTransaction_List.ItemCount) do begin
           T := BankAccount.baTransaction_List.Transaction_At( i);
           if ( T^.txMatched_Item_ID = pT^.txMatched_Item_ID) then begin
              Inc( LineNo);
              if ( LineNo <= MaxLinesToShow) then begin
                 //get locked or transferred details
                 S := '';
                 if T^.txLocked then S := S + 'F';
                 if T^.txDate_Transferred <> 0 then S := S + 'T';
                 while (length( S) < 2) do S := S + ' ';
                 miArray[ LineNo].miLockedStr := S;
                 miArray[ LineNo].miAccount   := T^.txAccount;
                 miArray[ LineNo].miAmount    := T^.txAmount;
                 miArray[ LineNo].miReference := GetFormattedReference( T);
                 miArray[ LineNo].miDate_Effective := T^.txDate_effective;
                 //get coding details
                 Code := T^.txAccount;
                 if Code = '' then begin
                    miArray[ LineNo].miAccountDesc := '<Uncoded>';
                 end
                 else if T^.txFirst_Dissection <> nil then begin
                    miArray[ LineNo].miAccountDesc := '<Dissected>'
                 end
                 else begin
                    A := MyClient.clChart.FindCode( Code );
                    if Assigned( A ) then
                       miArray[ LineNo].miAccountDesc := A^.chAccount_Description
                    else
                       miArray[ LineNo].miAccountDesc := '<Invalid Code>';
                 end;
              end;
           end;
        end;
     end;
   end; //with pT^

   //construct hint msg
   for i := 1 to LineNo do with miArray[i] do begin
      S := miLockedStr + '  ' +
           bkDate2Str( miDate_Effective) + '  ' +
           PadS( miReference, 12) + '  ' +
           LeftPadS( Money2Str( miAmount), 12) + '  ' +
           PadS( miAccount, 12) + ' ' +
           miAccountDesc;
      if i > 1 then
         S := #13 + S;
      HintStr := HintStr + S;
   end;
   if LineNo > MaxLinesToShow then
      HintStr := #13 + '... more lines ...';

   //show line if nothing else linked to this item
   if LineNo = 0 then
      HintStr := 'no other entries are linked to this transaction...';

   //display the hint above the status line
   if HintStr <> '' then begin
      HideCustomHint;
      R := FHint.CalcHintRect( Screen.Width, HintStr, nil);
      with barCodingStatus do begin
         ClientPt.x := Panels[PANELMODE].Width + Panels[PANELLINE].Width + Panels[PANELCODEDCOUNT].Width + 2;
         ClientPt.y := 0 - R.Bottom - 3;
      end;
      ScreenPt   := barCodingStatus.ClientToScreen( ClientPt);
      OffsetRect( R, ScreenPt.X, ScreenPt.Y );
      FHint.Color := Application.HintColor;
      FHint.ActivateHint( R, HintStr);
   end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfrmCoding.memNotesExit(Sender: TObject);
var
  pT : pTransaction_Rec;
  Len, i : Integer;
begin
  tblCoding.AllowRedraw := false;
  try
    //check to see if the notes field actually contains useful notes
    Len := Length(memNotes.Text);
    i := 1;
    //look for text characters
    while (i <= Len) and (memNotes.Text[i] in [#32, #13, #10]) do
      Inc(i);
    with tblCoding do begin
      if ValidDataRow( ActiveRow) then
      begin
        pT := WorkTranList.Transaction_At(ActiveRow-1);
        //if the notes field has useful notes
        if (i <= Len) then
          //store them
          pT^.txNotes := memNotes.Text
        else
          //reset them
        begin
          pT^.txNotes := '';
          pT^.txNotes_Read := False;
        end;
        InvalidateColumn( ColumnFmtList.GetColNumOfField( ceAccount));
      end;
    end;
  finally
    tblCoding.AllowRedraw := true;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.memNotesChange(Sender: TObject);
var
   pT : pTransaction_Rec;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then exit;
   with tblCoding do begin
      pT   := WorkTranList.Transaction_At(ActiveRow-1);
      pT^.txNotes := memNotes.Text;
      tblCoding.InvalidateColumn( ColumnFmtList.GetColNumOfField( ceAccount));
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pnlNotesEnter(Sender: TObject);
begin
  pnlNotesTitle.Color := bkBranding.HeaderBackgroundColor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pnlNotesExit(Sender: TObject);
begin
   pnlNotesTitle.Color       := clBtnFace;
   DoGotoGrid;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.popCodingPopup(Sender: TObject);
var pT: pTransaction_Rec;

    function ShowMenuItem(Name: string; Show: Boolean): boolean;
    var I: Integer;
    begin
        for I := 0 to pred(popCoding.Items.Count) do
           if popCoding.Items[I].Name = Name then
              popCoding.Items[I].Visible := Show;
        Result := Show;
    end;

    procedure SetCaption(Name, Caption: string);
    var I: Integer;
    begin
        for I := 0 to pred(popCoding.Items.Count) do
           if popCoding.Items[I].Name = Name then
              popCoding.Items[I].Caption := Caption;
    end;
begin
   if not ValidDataRow(tblCoding.ActiveRow) then
      Exit;
   with tblCoding do begin
      pT := WorkTranList.Transaction_At(ActiveRow-1);
      //Hide Edit UPC Amount Menu Item if not an Unpresented Item
      if IsJournal then begin
         if (pT^.txLocked)
         or (pT^.txDate_Transferred <> 0) then begin
             setCaption( mniEditJournal, mniVJCaption);
             ShowMenuItem(mniDelDissection, false);
             ShowMenuItem(mniSep3,false);
         end else begin
             setCaption(mniEditJournal, mniEJCaption);
             ShowMenuItem(mniDelDissection, True);
             ShowMenuItem(mniSep3,true);
         end;

      end else begin
         ShowMenuItem(mniEditUPCAmount, pT^.txDate_Presented=0);
         ShowMenuItem('mniConvertAmount', ColumnFmtList.ColumnDefn_At(tblCoding.ActiveCol)^.cdFieldID = ceGSTAmount);
         if (pT^.txLocked)
         or (pT^.txDate_Transferred <> 0) then begin
            // Remove them regardless
            ShowMenuItem(mniDelDissection, false);
            ShowMenuItem(mniSep1, false);
            ShowMenuItem(mniSuperClear, false);
         end else begin
            // Check if we can have them
            {$B+}
            ShowMenuItem(mniSep1,
               ShowMenuItem(mniDelDissection,Assigned(pT.txFirst_Dissection))
               or ShowMenuItem(mniSuperClear, (pT.txSF_Super_Fields_Edited or (pt.txCoded_By = cbManualSuper)) and CanUseSuperFields)
             );
            {$B-} // set it back
         end;
      end;
   end;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoGotoNotes;
begin
   if not tblCoding.StopEditingState(True) then Exit;

   rzSizePanel1.RestoreHotSpot;

   if pnlNotes.enabled then
      SetFocusSafe( memNotes);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.rzXBtnClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
   DoGotoGrid;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.rzPinBtnClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.ToggleAlwaysShowNotes;
begin
   if not BankAccount.baFields.baNotes_Always_Visible then begin
      BankAccount.baFields.baNotes_Always_Visible := true;
      pmiNotesVisible.Checked := true;
      rzPinBtn.visible := false;
      rzXBtn.visible := true;
   end
   else begin
      BankAccount.baFields.baNotes_Always_Visible := false;
      rzXBtn.visible := false;
      rzPinBtn.visible := true;
      pmiNotesVisible.Checked := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiNotesVisibleClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiGotoGridClick(Sender: TObject);
begin
   DoGotoGrid;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoGotoGrid;
begin
   SetFocusSafe( tblCoding);
   if not BankAccount.baFields.baNotes_Always_Visible then
      rzSizePanel1.CloseHotSpot;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiGridGotoNotes(Sender: TObject);
begin
   DoGotoNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoDitto(Sender: TObject);
begin
   DoDitto;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoCopySDToNarration(Sender: TObject);
begin
   DoCopySDToNarration(False);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoAppendSDToNarration(Sender: TObject);
begin
   DoCopySDToNarration(True);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoCopyNotesToNarration(Sender: TObject);
begin
   DoCopyNotesToNarration(False);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoAppendNotesToNarration(Sender: TObject);
begin
   DoCopyNotesToNarration(True);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoNewAmount(Sender: TObject);
begin
  DoNewAmount;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoDeleteNote(Sender: TObject);
begin
  DoDeleteNote;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoMarkNote(Sender: TObject);
begin
  DoMarkNote;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.pmiDoMarkAllNotes(Sender: TObject);
begin
  DoMarkAllNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingEnter(Sender: TObject);
begin
   tblCoding.Colors.Locked := clGray;
   tblCoding.Colors.LockedText := clWhite;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingExit(Sender: TObject);
begin
   tblCoding.Colors.Locked := clBtnFace;
   tblCoding.Colors.LockedText := clBtnShadow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.tblCodingDblClick(Sender: TObject);
var
  ColEstimate,
  RowEstimate : integer;
  MousePos    : TPoint;
  pT          : pTransaction_Rec;
  FieldID     : integer;
begin
  //get x,y
  GetCursorPos( MousePos);
  MousePos := tblCoding.ScreenToClient( MousePos);

  //estimate where click happened
  if tblCoding.CalcRowColFromXY(MousePos.x, MousePos.Y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ]
  then
     exit;

  //if dbl click was on account cell and dissected then do dissection
  if not ValidDataRow(RowEstimate) then
     exit;
  pT   := WorkTranList.Transaction_At(RowEstimate-1);
  FieldID := ColumnFmtList.ColumnDefn_At(ColEstimate)^.cdFieldID;

  if FieldID = ceAccount then
  begin
    if pT^.txFirst_Dissection <> nil then
     DoDissection;
  end else
  if (FieldID = ceEffDate)
  and IsJournal then
      DoDissection;
  if (FieldID in [ ceAmount, ceForexAmount ] ) and (pT^.txDate_Presented=0) then
    DoNewAmount;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.RzSizePanel1Resize(Sender: TObject);
begin
   if rzSizePanel1.Height > ( rzSizePanel1.SizeBarWidth + 1) then begin
      if Assigned( BankAccount) then
         BankAccount.baFields.baNotes_Height := rzSizePanel1.Height;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.mniResetClick(Sender: TObject);
begin
   rzSizePanel1.Height := 90;
   rzSizePanel1.ResetHotSpot;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.SetupColDefaultSets;
//sets up the NeverEditable and DefaultEditable sets used in RestoreColumnDefaults
//and ConfigureColumns
begin
   if BankAccount.IsAJournalAccount then begin

      NeverEditableCols := [ ceStatus,
                             ceAccount,
                             ceAnalysis,
                             ceDescription,
                             cePresDate,
                             ceOtherParty,
                             ceParticulars,
                             ceStatementDetails,
                             ceDocument,
                             ceAction,
                             ceGSTAmount,
                             ceAltChartCode,
                             ceCoreTransactionId,
                             ceTransferedToOnline ];
      DefaultEditColumn := ceReference;
   end else begin
      NeverEditableCols := [ ceStatus,
                             ceReference,
                             ceAnalysis,
                             ceDescription,
                             ceEntryType,
                             cePresDate,
                             ceCodedBy,
                             ceOtherParty,
                             ceParticulars,
                             ceStatementDetails,
                             ceBalance,
                             cePayeeName,
                             ceJobName,
                             ceDocument,
                             ceAction,
                             ceAltChartCode,
                             ceCoreTransactionId,
                             ceTransferedToOnline ];
     DefaultEditColumn := ceAccount;

     if fIsForex then
       NeverEditableCols := NeverEditableCols + [ ceForexAmount, ceForexRate, ceLocalCurrencyAmount ]
     else
       NeverEditableCols := NeverEditableCols + [ ceAmount ];
   end;

   //add gst col if australia and bas calc method is full, ie not editing of amount allowed
   with MyClient.clFields do begin
      if ( clCountry = whAustralia)
      and ( clBAS_Calculation_Method = bmFull) then
         NeverEditableCols := NeverEditableCols + [ ceGSTAmount ];

      If not Software.CanAlterGSTClass( clCountry, clAccounting_System_Used ) then
         NeverEditableCols := NeverEditableCols + [ ceGSTClass ];
   end;

   DefaultEditableCols := [ ceAccount,
                            ceEffDate,
                            ceNarration,
                            cePayee,
                            ceGSTClass,
                            ceGSTAmount,
                            ceQuantity,
                            ceTaxInvoice,
                            ceJob ];

(*
   if fIsForex then
      DefaultEditableCols := DefaultEditableCols + [ ceLocalCurrencyAmount, ceForexRate ];
*)

   If Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
      DefaultEditableCols := DefaultEditableCols + [ ceGSTClass ];

   //gst amount not editable if AU
   with MyClient.clFields do
   begin
      if ( clCountry = whAustralia) and ( clBAS_Calculation_Method = bmFull) then
         DefaultEditableCols := DefaultEditableCols - [ ceGSTAmount];
   end;


   if (BankAccount.CanEditTransactions)
   or IsJournal then begin
      Exclude(NeverEditableCols, ceReference);
      Include(DefaultEditableCols, ceReference);
      //Include(DefaultEditableCols, ceEffdate);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.celBalanceOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
const
  margin = 4;
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
begin
  if data = nil then exit;
  R := CellRect;
  C := TableCanvas;
  S := StrPas(PChar(Data));
  if (Length(S) = 0) then exit;

  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect(R, -Margin div 2, -Margin div 2);
  if not ( S[ length( S)] = 'F') then begin
     R.Right := round(R.Left+(R.Right-R.Left)*0.85)
  end
  else begin
     R.Right := round(R.Left+(R.Right-R.Left)*0.95);
  end;
  DrawText(C.Handle, Data, StrLen(Data), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoCopyNotesToNarration( Append : boolean);
var
  pT : pTransaction_Rec;
  NewNarration : string;
begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not tblCoding.StopEditingState(True) then Exit;

    pT := WorkTranList.Transaction_At(ActiveRow-1);
    if pT^.txLocked then exit;
    if pT^.txDate_Transferred <> 0 then exit;

    if Append then
      NewNarration := pT^.txGL_Narration + ' : ' + pT^.txNotes
    else
      NewNarration := pT^.txNotes;

    //strip OD OA characters
    NewNarration := StripReturnCharsFromString( Trim(NewNarration), ' ');

    pT^.txHas_Been_Edited := true;
    pT^.txGL_Narration := Copy( NewNarration, 1, MaxNarrationEditLength);
    pT.txTransfered_To_Online := False;

    RedrawRow;

  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoCopySDToNarration( Append : boolean);
var
  pT : pTransaction_Rec;
  NewNarration : string;
begin
   with tblCoding do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not tblCoding.StopEditingState(True) then Exit;

      pT := WorkTranList.Transaction_At(ActiveRow-1);
      if pT^.txLocked then exit;
      if pT^.txDate_Transferred <> 0 then exit;

      if Append then
        NewNarration := pT^.txGL_Narration + ' : ' + pT^.txStatement_Details
      else
        NewNarration := pT^.txStatement_Details;

      pT^.txHas_Been_Edited := true;
      pT^.txGL_Narration := Copy( NewNarration, 1, MaxNarrationEditLength);
      pT.txTransfered_To_Online := False;

      RedrawRow;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoMarkNote;
var
  pT : pTransaction_Rec;

  Procedure LToggle(Value : boolean);
  Begin // have to check both but Import is more important..
     if pT.txECoding_Import_Notes <> '' then
        pT.txImport_Notes_Read := Value;

     if pT^.txNotes <> '' then
       pT.txNotes_Read := Value;
  end;


begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not tblCoding.StopEditingState(True) then Exit;

    pT := WorkTranList.Transaction_At(ActiveRow-1);
    if pT^.txLocked or (pT^.txDate_Transferred <> 0) then exit;
    // Make sure both Get / stay in step
    if (pT^.txNotes <> '')
    or (pT.txECoding_Import_Notes <> '') then
       LToggle ( NOT  (pT.txImport_Notes_Read or pT.txNotes_Read));

    RedrawRow;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoMarkAllNotes;
var
  pT : pTransaction_Rec;
  pD : pDissection_Rec;
  i: Integer;
begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not tblCoding.StopEditingState(True) then Exit;

    for i := WorkTranList.First to WorkTranList.Last do
    begin
      pT := WorkTranList.Transaction_At(i);
      if pT.txLocked or (pT.txDate_Transferred <> 0) then Continue;
      pT.txNotes_Read := pT.txNotes <> '';
      pT.txImport_Notes_Read := pT.txECoding_Import_Notes <> '';
      if pT.txFirst_Dissection <> nil then
      begin
        pD := pT.txFirst_Dissection;
        while (pD <> nil) do
        begin
          pD.dsNotes_Read := pD.dsNotes <> '';
          pD.dsImport_Notes_Read := pD.dsECoding_Import_Notes <> '';
          pD := pD^.dsNext;
        end;
      end;
    end;

    //force repaint of row
    AllowRedraw := false;
    try
      InvalidateTable;
    finally
       AllowRedraw := true;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.DoDeleteNote;
var
  pT : pTransaction_Rec;
begin
  with tblCoding do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not tblCoding.StopEditingState(True) then Exit;

    pT := WorkTranList.Transaction_At(ActiveRow-1);
    //if pT^.txLocked or (pT^.txDate_Transferred <> 0 ) then exit;
    // notes are ok to change
    pT^.txNotes := '';
    pT^.txNotes_Read := False;

    RedrawRow;
    UpdateNotesPanel(ActiveRow);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.CMMouseEnter(var Message: TMessage);
//capture mouse enter message and show hint
var
  RowNum, ColNum : integer;
begin
  if not tblCoding.Focused then
    exit;

  if HintShowing then
    exit;

  //see if active row is off screen, if so dont show the hint
  RowNum := tblCoding.ActiveRow;
  if ( RowNum < tblCoding.TopRow) or ( RowNum > ( tblCoding.TopRow + tblCoding.VisibleRows - tblCoding.LockedRows)) then
    Exit;

  //only show the hint if the current cell is not being edited
  if not tblCoding.InEditingState then
  begin
    ColNum := tblCoding.ActiveCol;
    ShowHintForCell( RowNum, ColNum);
  end;
end;

//------------------------------------------------------------------------------
//
// tblCodingTopLeftCellChanged
//
procedure TfrmCoding.tblCodingTopLeftCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
begin
  //decide if active row is visible
  if (tblCoding.ActiveRow < RowNum) or
     (tblCoding.ActiveRow > ( RowNum + tblCoding.VisibleRows - tblCoding.LockedRows)) then
    HideCustomHint
  else
    ShowHintForCell( RowNum, ColNum);
end;

procedure TfrmCoding.SetIsClosing(const Value: boolean);
begin
  FIsClosing := Value;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// WMMDIActivate
//
// This is primarily to show and hide the hint window when the MDI form changes.
// MDI child forms only activate the methods FormActivate and FormDeactivate
// when the form is being shown or closed.
//
procedure TfrmCoding.WMMDIActivate(var Msg: TWMMDIActivate);
begin
  if (Msg.ActiveWnd = Handle) then
  begin
    //activate
    FormActivate(Self);
  end;
  if (Msg.DeactiveWnd = Handle) then
  begin
    //deactivate
    FormDeactivate(Self);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TfrmCoding.FormIsInEditMode: boolean;
begin
  result := tblCoding.InEditingState;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCoding.EBFindChange(Sender: TObject);
begin
   // restart the search timer..
   SearchTimer.Enabled := False;
   SearchTimer.Enabled := True;
end;

procedure TfrmCoding.EBFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key)=VK_RETURN then
      SearchTimerTimer(nil);
end;

procedure TfrmCoding.EmptyTmpBuffer;
var
  i : integer;
begin
  for i := Low(tmpBuffer) to High(tmpBuffer) do
    tmpBuffer[i] := #0;
end;

procedure TfrmCoding.celLocalCurrencyAmountChange(Sender: TObject);
begin
  //test to see if need to automatically put minus sign
  if AutoPressMinus then
     keybd_event(vk_subtract,0,0,0);
   AutoPressMinus := false;
end;

procedure TfrmCoding.celLocalCurrencyAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  celAmountOwnerDraw( Sender, TableCanvas, CellRect, RowNum, ColNum, CellAttr, Data, DoneIt );
end;

procedure TfrmCoding.celPayeeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F3 ) then begin
    Msg.CharCode := VK_F3;
    celPayee.SendKeyToTable(Msg);
  end;
end;

procedure TfrmCoding.celGSTCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F7 ) then begin
    Msg.CharCode := VK_F7;
    celGSTCode.SendKeyToTable(Msg);
  end;
end;

procedure TfrmCoding.SortbyChequeNumber1Click(Sender: TObject);
begin
  ProcessExternalCmd( ecSortChq);
end;

procedure TfrmCoding.SortbyReference1Click(Sender: TObject);
begin
  ProcessExternalCmd( ecSortRef);
end;

//------------------------------------------------------------------------------
//
// SetQuantitySign
//
// Sets the sign (+/-) of the quantity based on the amount entered.
// a positive amount will make a positive quantity.
// a negative amount will make a negative quantity.
//
// Zero amount transactions can be assigned either sign for quantities (+ or -).
// They are not transactions but notes on a financial statement and therefore do not
// fall under the Dr, Cr rules assigned to quantites in BankLink.
//
procedure TfrmCoding.SetQuantitySign(QuantityChanged : Boolean);
var
  pT : pTransaction_Rec;
  fQValue : Double;
begin
  pT := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);

  //user can have whatever sign they like if the amount is zero
  if pT^.txAmount = 0 then
    Exit;

  if (QuantityChanged) then
  begin
    //the quantity value was changed, correct it to match the sign of the amount
    fQValue := TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat;

    if (pT^.txAmount > 0) then
    begin
      //amount is positive
      if (fQValue < 0) then
        //make the quantity positive
        TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat := (-fQValue);
    end else
    begin
      //amount is negative
      if (fQValue > 0) then
        //make the quantity negative
        TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat := (-fQValue);
    end;
  end else
  begin
    //the amount value was changed, make sure the quantity sign is changed to
    //match
    fQValue := pT^.txQuantity;

    if (pT^.txAmount > 0) then
    begin
      //amount is positive
      if (fQValue < 0) then
        //make the quantity positive
        pT^.txQuantity := (-fQValue);
    end else
    begin
      //amount is negative
      if (fQValue > 0) then
        //make the quantity negative
        pT^.txQuantity := (-fQValue);
    end;
  end;
end;

procedure TfrmCoding.celAmountExit(Sender: TObject);
begin
  SetQuantitySign(False);
end;

procedure TfrmCoding.celQuantityExit(Sender: TObject);
begin
  SetQuantitySign(True);
end;

procedure TfrmCoding.DoEditSuperFields;
var
  pT : pTransaction_Rec;
  Move: TFundNavigation;
  OldAccount: string[20];
begin
  if not CanUseSuperFields then
    Exit;

  if not ValidDataRow(tblCoding.ActiveRow) then
    Exit;
  if not tblCoding.StopEditingState(True) then
    Exit;

  //ge transaction for current row
  pT   := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);

  //see if interface supports super fund fields
  if CanUseSuperFields then begin
      if pT^.txFirst_Dissection <> nil then
        Exit;
      if WorkTranList.ItemCount = tblCoding.ActiveRow then
        Move := fnIsLast
      else if tblCoding.ActiveRow - 1 = 0 then
        Move := fnIsFirst
      else
        Move := fnNothing;
      OldAccount := pT.txAccount;
      if SuperFieldsUtils.EditSuperFields( pT, Move, FSuperTop, FSuperLeft, BankAccount) then begin

          AccountEdited(pT); // Cleanup any changes

          RedrawRow;

          case Move  of
             fnGoBack: begin
                  tblCoding.ActiveRow := tblCoding.ActiveRow - 1;
                  DoEditSuperFields;
               end;
             fnGoForward: begin
                  tblCoding.ActiveRow := tblCoding.ActiveRow + 1;
                  DoEditSuperFields;
               end
          end;
      end;
  end;
  FSuperTop := -999;
  FSuperLeft := -999;
end;
                                                       

function TfrmCoding.CanUseSuperFields: boolean;
//added as a function because the result may change during the life of the
//coding form.  This may happen when the accounting system is changed
begin
  result := Software.CanUseSuperFundFields( MyClient.clFields.clCountry,
                                            MyClient.clFields.clAccounting_System_Used);
end;

procedure TfrmCoding.UpdatePopups;
var
  O : TMenuItem;
  I: Integer;
begin
  for i := 0 to PopCoding.Items.Count - 1 do
    begin
      O := PopCoding.Items[i];
      if O.Name = mniSuper then
        O.Visible := CanUseSuperFields;

      if O.Name = mniFingertips then
      begin
{$IFDEF Smartlink}
        O.Visible := true;
{$ELSE}
        O.Visible := false;
{$ENDIF}
      end;
    end;
end;

procedure TfrmCoding.celPayeeNameOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  PayeeName : string;
  pT  : pTransaction_Rec;

  AllLinesHaveSamePayee : boolean;
  FirstPayeeNo          : integer;
  PayeesInDissection : Boolean;
begin
   If ( data = nil ) then exit;

   //no payee assigned so check to see if is assigned inside dissection
   if ValidDataRow(RowNum) then
   begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     //see if payee assigned at trx level
     if pT^.txPayee_Number <> 0 then
       Exit;

     //see if trx is dissected
     if pT^.txFirst_Dissection = nil then
       Exit;

     //transaction is dissected, look for payees
     GetPayeeInfoForDissection( pT, PayeesInDissection, AllLinesHaveSamePayee, FirstPayeeNo);
   end
   else
     exit;

   //use default drawing methods if no payees
   if not PayeesInDissection then exit;

   if AllLinesHaveSamePayee then
   begin
     PayeeName := NewHints.GetPayeeHint( FirstPayeeNo, true);
     S := PChar( PayeeName);
   end
   else
     S := PChar( 'Split');

   //paint
   R := CellRect;
   C := TableCanvas;
   //paint background
   C.Brush.Color := CellAttr.caColor;
   C.FillRect(R);
   //draw data
   InflateRect( R, -2, -2 );
   if CellAttr.caColor <> clHighLight then
     C.Font.Color := clGrayText
   else
     C.Font.Color := CellAttr.caFontColor;
   DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   DoneIt := true;
end;

// #2516 - Shift+F10 standard shortcut for right-click menus
// Display at 0,0 position as per internet explorer

procedure TfrmCoding.tblCodingKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  S, P: TPoint;
begin
  if (ssShift in Shift) and (Key = VK_F10) then
  begin
    S.X := 0;
    S.Y := 0;
    P := tblCoding.ClientToScreen(S);
    popCoding.Popup(P.X, P.Y);
  end;
end;

procedure TfrmCoding.memImportNotesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  S, P: TPoint;
begin
  if (ssShift in Shift) and (Key = VK_F10) then
  begin
    S.X := 0;
    S.Y := 0;
    P := memNotes.ClientToScreen(S);
    popNotes.Popup(P.X, P.Y);
  end;
end;

procedure TfrmCoding.celAccountKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
  LCode: ShortString;
begin
   if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(TEdit(celAccount.CellEditor),RemovingMask);

  //if the current text value of the edit cell is a valid account code
  //then automatically press right arrow
  //if not a valid code test to see if a mask should be added
  //case #5053-moved this from OnChange into here
  LCode :=  TEdit(celAccount.CellEditor).text;
  if MyClient.clChart.CanPressEnterNow(LCode) then
  begin
     TEdit(celAccount.CellEditor).text := LCode;
     Msg.CharCode := VK_RIGHT;
     celAccount.SendKeyToTable(Msg);
  end;
end;

procedure TfrmCoding.celAccountExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(celAccount.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask);
end;

procedure TfrmCoding.celEditDateOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
  const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);

const
  DTOpts = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
var R: TRect;
    S: string;
begin
  If ( data = nil ) then exit;

  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;


  S :=  bkDate2Str( integer( Data^ ));
  TableCanvas.FillRect( CellRect );

  // Draw the cell Border
  R := CellRect;
  TableCanvas.Pen.Color := CellAttr.caColor;
  TableCanvas.Polyline( [ Point( R.Left, R.Bottom-1 ), Point( R.Right, R.Bottom-1 )] );

  // Draw the Text
  R := CellRect;
  InflateRect( R, -2, -2 );
  DrawText( TableCanvas.Handle, PChar( S ), StrLen( PChar( S ) ), R, DTOpts );

  if IsJournal then
     DrawNotesIcon(RowNum, CellRect, TableCanvas);

  DoneIt := True;
end;

procedure TfrmCoding.celForexAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
const
  margin = 4;
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pT : pTransaction_Rec;
  pD : pDissection_Rec;
  ShowCommentIndicator : boolean;
  CommentColor : TColor;
begin
  if data = nil then exit;
  DoneIt := True;
  R := CellRect;
  C := TableCanvas;
  S := StrPas(PChar(Data));
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  ShowCommentIndicator := False;
  CommentColor := clRed;
  //check is a data row
  if ValidDataRow(RowNum) then begin
     pT   := WorkTranList.Transaction_At(RowNum-1);
     SetTranUPCStatus( pT);
     if pT^.txUPC_Status in [ucMatchingAmount] then begin
        C.Brush.Color := clGreen;
        C.Font.Color  := clWhite;
     end else if ( pT^.txUPI_State in [ upUPC, upUPD, upUPW]) and ( pT^.txAmount = 0) then begin
        C.Font.Color := clRed;
     end;

     if CanUseSuperFields then begin
        if pT^.txFirst_Dissection = nil then begin
           ShowCommentIndicator := pT^.txSF_Super_Fields_Edited;
        end else begin
           pD := pT^.txFirst_Dissection;
           CommentColor := clGray;
           while (pD <> nil)
           and ( not ShowCommentIndicator) do begin
              ShowCommentIndicator := pD^.dsSF_Super_Fields_Edited;
              pD := pD^.dsNext;
           end;
        end;
     end;
  end;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect(R, -Margin div 2, -Margin div 2);

  if ( pos( '(', S ) > 0 ) or ( pos( '-', S ) > 0 ) then
    R.Right := round(R.Left+(R.Right-R.Left)*0.95)
  else
    R.Right := round(R.Left+(R.Right-R.Left)*0.75);

  DrawText(C.Handle, Data, StrLen(Data), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);

  if ShowCommentIndicator then
    begin
      //draw a red triangle in the top right
      C.Brush.Color := CommentColor;
      C.Pen.Color := CommentColor;
      R := CellRect;
      C.Polygon( [Point( R.Right - (Margin+ 1), R.Top),
                        Point( R.Right -1, R.Top),
                        Point( R.Right -1, R.Top + Margin)]);
    end;
 //
end;

procedure TfrmCoding.celDocumentOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
{$IFDEF SmartLink}
//custom draw for document col, allows us to add the icons for fingertips
const
  DTOpts = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
  DefaultIconSize = 20;
var
  R         : TRect;
  SourceRect : TRect;
  imageWidth : integer;
  S         : String;
  pT        : pTransaction_Rec;
  WasFontSize : integer;
  WasFontColor : TColor;
begin
  if ( data = nil ) then exit;

  if not ValidDataRow( RowNum ) then
    exit;

  pT   := WorkTranList.Transaction_At( RowNum-1 );
  s := pT^.txDocument_Title;

  WasFontSize := TableCanvas.Font.Size;
  WasFontColor := TableCanvas.Font.Color;

  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;
  TableCanvas.FillRect( CellRect );

  // Draw the cell Border
  R := CellRect;
  TableCanvas.Pen.Color := CellAttr.caColor;
  TableCanvas.Polyline( [ Point( R.Left, R.Bottom-1 ), Point( R.Right, R.Bottom-1 )] );

  // Draw the relevant document icon
  if (pT^.txDocument_Title = '') then
  begin
      //no doc there, show add icon
      R := CellRect;
      InflateRect( R, -6, -6 ); { Make it Smaller }
      OffsetRect( R, -3, 0 ); { Move it Right a bit }

      //figure out graphic width needed
      if (CellRect.Right - R.Left) > DefaultIconSize then
        ImageWidth := DefaultIconSize
      else
      begin
        ImageWidth := (CellRect.Right - R.Left);
      end;
      R.Right := R.Left + ImageWidth;
      R.Bottom := R.Top + DefaultIconSize;
      SourceRect.Top := 0;
      SourceRect.Left := 0;
      SourceRect.Right := ImageWidth;
      SourceRect.Bottom := DefaultIconSize;
      TableCanvas.CopyRect( R, ImagesFrm.AppImages.imgAddDoc.Canvas, SourceRect);

      //draw text
      R := CellRect;
      InflateRect( R, -6, -6 );
      R.Left := R.Left + DefaultIconSize + 2;
      TableCanvas.Font.Color := clNavy;
      TableCanvas.Font.Style := [fsUnderline];
      S := 'Add';
      DrawText( TableCanvas.Handle, PChar(S), StrLen( PChar( S ) ), R, DTOpts );
  end
  else
  begin
      //no doc there, show add icon
      R := CellRect;
      InflateRect( R, -6, -6 ); { Make it Smaller }
      OffsetRect( R, -3, 0 ); { Move it Right a bit }

      //figure out graphic width needed
      if (CellRect.Right - R.Left) > DefaultIconSize then
        ImageWidth := DefaultIconSize
      else
      begin
        ImageWidth := (CellRect.Right - R.Left);
      end;
      R.Right := R.Left + ImageWidth;
      R.Bottom := R.Top + DefaultIconSize;
      SourceRect.Top := 0;
      SourceRect.Left := 0;
      SourceRect.Right := ImageWidth;
      SourceRect.Bottom := DefaultIconSize;
      TableCanvas.CopyRect( R, ImagesFrm.AppImages.imgViewDoc.Canvas, SourceRect);

      //draw text
      R := CellRect;
      InflateRect( R, -6, -6 );
      R.Left := R.Left + DefaultIconSize + 2;
      TableCanvas.Font.Color := clNavy;
      TableCanvas.Font.Style := [fsUnderline];
      //TableCanvas.Font.Size  := 8;
      S := 'Manage';
      DrawText( TableCanvas.Handle, PChar(S), StrLen( PChar( S ) ), R, DTOpts );
  end;

  TableCanvas.Font.Size := WasFontSize;
  TableCanvas.Font.Color := WasFontColor;
  TableCanvas.Font.Style := [];

  DoneIt := True;
end;
{$ELSE}
begin
  //do nothing as this wont be shown
end;
{$ENDIF}

{$IFDEF SmartLink}
procedure TfrmCoding.DoLaunchFingertips;
var
  pT : pTransaction_Rec;
begin
  if not ValidDataRow(tblCoding.ActiveRow) then
    exit;
  if not tblCoding.StopEditingState(True) then
    Exit;

  //get transaction for current row
  pT   := WorkTranList.Transaction_At(tblCoding.ActiveRow-1);

  if FingerTipsInterface.LaunchFingertips( pT, MyClient) then
  begin
    tblCoding.InvalidateRow( tblCoding.ActiveRow);
    tblCoding.Refresh;
  end;
end;
{$ENDIF}

function TfrmCoding.ValidCheque(Num: string; This : pTransaction_Rec; var msg: string ): boolean;
var
   pT : pTransaction_Rec;
   i, CN  : integer;
begin
  Result := True;
  msg := '';
  if ((This^.txType = 0) and (MyClient.clFields.clCountry = whNewZealand)) or
     ((This^.txType = 1) and (MyClient.clFields.clCountry = whAustralia)) or
     ((This^.txType = 1) and (MyClient.clFields.clCountry = whUK)) then
  begin
    try
      CN := StrToInt(Num);
    except
      Result := False;
      msg := 'You must enter a valid cheque number.';
      exit;
    end;
    if (CN <= 0) then
    begin
      Result := False;
      msg := 'You must enter a valid cheque number.';
      exit;
    end;
    for i := 0 to Pred(BankAccount.baTransaction_List.Last) do
    begin
       pT := BankAccount.baTransaction_List.Transaction_At(i);
       if pT = This then Continue;
       if PT^.txUPI_State = upUPC then Continue; // allow use of a UPC cheque number
       If pT^.txCheque_Number = CN then
       begin
         Result := False;
         msg := 'This cheque number has already been used. Please enter a different cheque number.';
         Break;
       end;
    end;
  end;
end;

(*
function TfrmCoding.MDEDateChange(var Tran: pTransaction_Rec): Boolean;
var
  pT: pTransaction_Rec;
  i: Integer;
begin
  Result := False;
  for i := 0 to Pred(WorkTranList.ItemCount) do
  begin // Finds the first Trans where the date has chnged
    pT := WorkTranList.Transaction_At(i);
    if pT.txDate_Change then
    begin
      Tran := pT;
      Result := True;
      Break;
    end;
  end;
end;
*)

procedure TfrmCoding.tblCodingKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE)
  and (ColumnFmtList.ColumnDefn_At(tblCoding.ActiveCol)^.cdFieldID in [ceJob, ceReference]) then
     Undo := True;


end;

procedure TfrmCoding.tblCodingKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '/') then
    Key := #0;
end;

// Reload form if gst calculation method changes - to reload columns
procedure TfrmCoding.Reload;
var
   i: Integer;
   ColDefn : pColumnDefn;
   CodingOptions: TCodingOptions;
begin
  for i := 0 to Pred( ColumnFmtList.ItemCount ) do
  begin
    ColDefn := ColumnFmtList.ColumnDefn_At(i);
    if ColDefn.cdFieldID = ceGSTAmount then
    begin
      ColDefn.cdEditMode[emGeneral] := MyClient.clFields.clBAS_Calculation_Method = bmSimplified;
      Break;
    end;
  end;
  tblCoding.AllowRedraw := False;
  if EditAcctColOnly then
    CodingOptions := [CC_RestrictedEditMode]
  else
    CodingOptions := [CC_FullEditMode];
  OpenCodingScreen(TranDateFrom, TranDateTo, BankAccount, CodingOptions);
  FIsReloading := True;
  Close;
end;

procedure TfrmCoding.QueryUncoded;
begin
  SendUncodedTransactions;
  tblCoding.InvalidateTable; // repaint notes icons
  tblCoding.Repaint;
end;

end.
