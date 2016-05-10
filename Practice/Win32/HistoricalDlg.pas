unit HistoricalDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  Historical Data Entry

  Written: Oct 1999
  Authors: Matthew, Neil, Andy, Michael

  Purpose: Allow the user to enter transactions that happened BEFORE they
     started receiving BankLink data.

  Notes:
     This action can only be performed once a bank account has been attached to the
     client file,  consequently it is required that a download of data for this bank
     account has already been done.

     The max date for a historical transaction is the earliest date of the downloaded
     transactions.  The max date will be the date prior to the first transaction downloaded

     If no transactions have been downloaded there is the option to allow entries to be
     entered anyway.  In this case the clients file is blocked from importing any bank
     transactions within the date range of the HDE entries.

     A range of cheques can be added, however any cheques no's that can be found in the
     Bank Accounts Transactions list will be skipped.  This is to stop duplicate cheque nos being
     added.

     ** The transactions are stored in a TUnsorted transaction list.  This allows
        transactions to be inserted before they have been given a valid date.  The
        list can be sorted by clicking on the column headings

     ** During the editing of the transaction pT^.txEdited is used to store the
        item index in the EntryType combo box, rather than a real txType

     Transaction sources

     orManual         Journal
     orGenerated      UPC or UPL
     orHistorical     Entered thru historical data entry
     orBank           Received from Bank
     orMDE            Entered thru manual data entry


}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
 syDefs,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcTCmmn, OvcTable, ComCtrls, StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF,
  ExtCtrls, OvcTCHdr, OvcTCPic, OvcTCBEF, OvcTCNum, OvcTCell, OvcTCStr,
  OvcTCEdt,
  ColFmtListObj, baObj32, BKOvcTable, TxUl, BkDefs,
  Menus, OvcTCCBx, OvcPF, ActnList, CheqCollectionObj,
  jpeg, RzPanel, RzButton, MoneyDef, ovctcbmp, ovctcgly, ovctcbox,
  OsFont,
  BankLinkOnlineServices, DateUtils;

const
    //Entry type indentifiers
  etChequeNZ      = 0;
  etAutoPaymentNZ = 15;
  etBankChargesNZ = 13;
  etWithdrawlNZ   = 49;
  etDepositNZ     = 50;

  etChequeOZ      = 1;
  etAutoPaymentOZ = 3;
  etBankChargesOZ = 8;
  etWithdrawlOZ   = 9;
  etDepositOZ     = 10;

  etChequeUK      = 1;
  etWithdrawlUK   = 9;
  etDepositUK     = 10;

    // Profile Keys
  kFile = 'FileName';
  kSkipLines = 'SkipLines';
  kHeaderLine = 'HeaderLine';
  kDelimiter = 'Delimiter';
  kDateCol = 'DateCol';
  kAmountType = 'AmountType';
    vSingle = 'Single';
    vDouble = 'Double';
    vSign = 'Sign';
  kCredidCol = 'CreditCol';
  kDebidCol = 'DebitCol';
  kSignCol = 'SignCol';
  kReverseSign = 'ReverseSign';
  kDebitReverseSign = 'DebitReverseSign';
  kCreditReverseSign = 'CreditReverseSign';
  kRefCol = 'ReferenceCol';
    kHasCheques = 'HasCheques';
  kAnalCol = 'AnalysisCol';
  kNar1Col = 'Narration1Col';
  kNar2Col = 'Narration2Col';
  kNar3Col = 'Narration3Col';

  IMPORT_INIFILE = 'Import.ini';

type
  TdlgHistorical = class(TForm)
    stbHistorical: TStatusBar;
    cntController: TOvcController;
    celRef: TOvcTCString;
    celAnalysis: TOvcTCString;
    celPayee: TOvcTCNumericField;
    celGstAmt: TOvcTCNumericField;
    celQuantity: TOvcTCNumericField;
    celNarration: TOvcTCString;
    celAccount: TOvcTCString;
    hdrColumnHeadings: TOvcTCColHead;
    pmTable: TPopupMenu;
    tblHist: TBKOvcTable;
    celDate: TOvcTCPictureField;
    celEntryType: TOvcTCComboBox;
    celAmount: TOvcTCNumericField;
    pfHiddenAmount: TOvcPictureField;
    mniLookupChart: TMenuItem;
    mniLookupPayee: TMenuItem;
    mniDissect: TMenuItem;
    alHistorical: TActionList;
    actChart: TAction;
    actPayees: TAction;
    actDissect: TAction;
    popView: TPopupMenu;
    popSortBy: TPopupMenu;
    mniSortByDate: TMenuItem;
    mniSortByChequeNumber: TMenuItem;
    mniSortByAccountCode: TMenuItem;
    mniSortByValue: TMenuItem;
    mniSortByNarration: TMenuItem;
    celGSTCode: TOvcTCString;
    mniConfigureCols: TMenuItem;
    N1: TMenuItem;
    ConfigureColumns1: TMenuItem;
    actConfigure: TAction;
    mniRestoreCols: TMenuItem;
    actRestore: TAction;
    RestoreColumns1: TMenuItem;
    mniSortByReference: TMenuItem;
    pnlToolbar: TPanel;
    rztHistorical: TRzToolbar;
    tbChart: TRzToolButton;
    tbPayee: TRzToolButton;
    tbDissect: TRzToolButton;
    tbSort: TRzToolButton;
    tbRepeat: TRzToolButton;
    tbView: TRzToolButton;
    tbAddCheques: TRzToolButton;
    tbHelpSep: TRzSpacer;
    tbHelp: TRzToolButton;
    LookupGSTClass1: TMenuItem;
    actGST: TAction;
    tbCopyLine: TRzToolButton;
    Copycontentsofthelineabove1: TMenuItem;
    celBalance: TOvcTCString;
    pnlExtraTitleBar: TRzPanel;
    lblAcctDetails: TLabel;
    lblTransRange: TLabel;
    imgGraphic: TImage;
    celPayeeName: TOvcTCString;
    celDescription: TOvcTCString;
    celTaxInv: TOvcTCCheckBox;
    Insertanewline1: TMenuItem;
    tmrPayee: TTimer;
    actJob: TAction;
    tbJob: TRzToolButton;
    CelJob: TOvcTCString;
    CelJobName: TOvcTCString;
    Jobs1: TMenuItem;
    tbImportTrans: TRzToolButton;
    celForexRate: TOvcTCNumericField;
    celLocalAmount: TOvcTCNumericField;
    CelAltChartCode: TOvcTCString;
    mniSortByAltCode: TMenuItem;
    ConvertAmount1: TMenuItem;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    pnlBottom: TPanel;
    Shape9: TShape;
    btnOK: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    lblOpen: TLabel;
    lblClose: TLabel;
    nfOpeningBal: TOvcNumericField;
    stClosingBal: TStaticText;
    cmbSign: TComboBox;
    Shape11: TShape;
    Shape12: TShape;
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure tblHistMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure tblHistLockedCellClick(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblHistActiveCellMoving(Sender: TObject; Command: Word; var RowNum, ColNum: Integer);
    procedure tblHistGetCellAttributes(Sender: TObject; RowNum,  ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblHistEnteringRow(Sender: TObject; RowNum: Integer);
    procedure tblHistActiveCellChanged(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblHistUserCommand(Sender: TObject; Command: Word);

    procedure tblHistBeginEdit(Sender: TObject; RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblHistGetCellData(Sender: TObject; RowNum, ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblHistEndEdit(Sender: TObject; Cell: TOvcTableCellAncestor;  RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblHistDoneEdit(Sender: TObject; RowNum, ColNum: Integer);

    procedure celAccountKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure celAccountKeyPress(Sender: TObject; var Key: Char);
    procedure celAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);

    procedure nfOpeningBalKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure nfOpeningBalChange(Sender: TObject);
    procedure cmbSignChange(Sender: TObject);

    procedure mniLookupChartClick(Sender: TObject);
    procedure mniLookupPayeeClick(Sender: TObject);
    procedure mniDissectClick(Sender: TObject);
    procedure celDateEnter(Sender: TObject);
    procedure celDateExit(Sender: TObject);
    procedure tbRepeatClick(Sender: TObject);
    procedure tbAddChequesClick(Sender: TObject);
    procedure actChartExecute(Sender: TObject);
    procedure actPayeesExecute(Sender: TObject);
    procedure actDissectExecute(Sender: TObject);
    procedure mniSortByDateClick(Sender: TObject);
    procedure mniSortByChequeNumberClick(Sender: TObject);
    procedure mniSortByAccountCodeClick(Sender: TObject);
    procedure mniSortByValueClick(Sender: TObject);
    procedure mniSortByNarrationClick(Sender: TObject);
    procedure popSortByPopup(Sender: TObject);
    procedure tblHistEnter(Sender: TObject);
    procedure tblHistExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure celAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtKeyPress(Sender: TObject; var Key: Char);
    procedure actConfigureExecute(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure celGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celQuantityChange(Sender: TObject);
    procedure tblHistMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure mniSortByReferenceClick(Sender: TObject);
    procedure celPayeeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celGSTCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celQuantityExit(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure actGSTExecute(Sender: TObject);
    procedure celAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountExit(Sender: TObject);
    procedure tbCopyLineClick(Sender: TObject);
    procedure celBalanceOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celPayeeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure celTaxInvKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celTaxInvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tblHistMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Insertanewline1Click(Sender: TObject);
    procedure tmrPayeeTimer(Sender: TObject);
    procedure actJobExecute(Sender: TObject);
    procedure CelJobOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure tblHistKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbImportTransClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure celForexAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure celLocalAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure mniSortByAltCodeClick(Sender: TObject);
    procedure ConvertAmount1Click(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure celDateError(Sender: TObject; ErrorCode: Word; ErrorMsg: string);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    AltLineColor                  : integer;
    BankAccount                   : TBank_Account;
    RemovingMask                  : boolean;
    TranSortOrder                 : integer;
    HistTranList                  : TUnsorted_Transaction_List;
    ExistingCheques               : TChequesList;
    MaxHistTranDate               : integer;
    clStdLineLight                : integer;
    clStdLineDark                 : integer;
    FirstActivate                 : boolean;
    LastReminderAt                : integer;
    ChequeTypeCmbIndex            : integer;
    DepositTypeCmbIndex           : integer;
    AutoPressMinus                : boolean;
    IsManual                      : boolean;
    CopyingLine                   : boolean;
    DefaultEditableCols           : set of byte;
    //temporary variables for data pointer to point to, used in GetCellData
    tmpShortStr                   : ShortString;
    tmpDouble                     : double;
    tmpInteger                    : Integer;
    tmpPayee,
    tmpDate,
    TimerRow                      : Integer;
    tmpBuffer                     : Array of Char;
    tmpBool                       : Boolean;

    //temporary variables for data pointer to point to, used in ReadCellForPaint
    tmpPaintString                : String;
    tmpPaintShortStr              : ShortString;
    tmpPaintDouble                : double;
    tmpPaintInteger               : Integer;

    Temp_Column_Order             : Array[ 0..32 ] of Byte;
    Temp_Column_Width             : Array[ 0..32 ] of Integer;
    Temp_Column_is_Hidden         : Array[ 0..32 ] of Boolean;
    Temp_Column_Is_Not_Editable   : Array[ 0..32 ] of Boolean;
    Undo                          : Boolean;
    FCountry                      : Byte;

    fIsForex                      : Boolean;
    BCode                         : String[3];
    CCode                         : String[3];
    FProvisional: Boolean;
    DittoLineInProgress: Boolean;
    fHasCheques                   : Boolean;

    procedure InitController;
    procedure SetupColumnFmtList;
    procedure SetTableAccess;
    procedure SetSortOrder(NewSortOrder: integer);
    procedure SortHTLMaintainPos( ASortOrder : byte );
    function  InsertNewRow(InsertWhere: byte): boolean;
    function  ValidDataRow(RowNum: integer): boolean;
    function  ValidDate(aDate: Integer; msg: pstring = nil): Boolean;
    function  ValidChequeNo(aChequeNo : Integer; pExcludeTrx : pTransaction_Rec ) : boolean;
    function  ValidateActiveTrans( pT : pTransaction_Rec; var RowNum, ColNum : integer) : boolean;
    function  ValidateChequeNumber(var RowNum, ColNum: Integer; pT: pTransaction_Rec): Boolean;
    function  IsACheque( pT : pTransaction_Rec) : boolean;
    procedure SetupEntryTypeList(Country: Byte);
    function  FindETInCombo( aEntryType : byte ) : byte;
    procedure SetUpHelp;

    procedure ConfigureColumns;
    procedure RemindUserToSave(Imported: Boolean = False);


    procedure AccountEdited(pT: pTransaction_Rec);
    procedure GSTClassEdited(pT: pTransaction_Rec);
    procedure EntryTypeEdited(pT : pTransaction_Rec);
    procedure ReadCellForEdit(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
    procedure DoAccountLookup;
    procedure DoDissection;
    procedure DoGSTLookup;
    procedure DoJobLookup;
    procedure DeleteCurrentLine(InsertIfEmpty : boolean = true);
    procedure DoDeleteCell;
    procedure CalcClosingBal;
    function CalcClosingBalAt(D: Integer; Seq: Integer = -1): Money;
    function CalcClosingBalSortOrder(Row: Integer): Money;
    function  PayeeEdited(pT: pTransaction_Rec) : boolean;
    procedure DoPayeeLookup;
    procedure DoDitto(CopyLine: Boolean = False);
    procedure DoDittoLine;
    procedure DoAddCheques;
    procedure ShowPopUp(x, y: Integer; PopMenu: TPopUpMenu);
    procedure EmptyTmpBuffer;

    procedure InsertTranIntoBankAccount;
    procedure SetCaptionState( TBar : TRzToolbar; CaptionOn: boolean);

    procedure DoDeleteDissection( pT: pTransaction_Rec);
    procedure SetQuantitySign(QuantityChanged : Boolean);
    procedure SaveTempLayout;
    procedure LoadTempLayout;
    procedure CopyDissection(pTo, pFrom: pTransaction_Rec);
    procedure CalculateBalanceColumn;
    procedure SaveLayoutForThisAcct;
    procedure LoadLayoutForThisAcct(Manual: Boolean);
    procedure SetupColDefaultSets;
    procedure ResetColumns;
    function CodingMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    function GetCellRect(const RowNum, ColNum: Integer): TRect;
    procedure Setup;
    procedure SetProvisional(const Value: Boolean);
    function AccountType: string;
    procedure UpdatePanelWidth;
    function GetIniFile() : string;
  public
    class function CreateAndSetup(aBankAccount: TBank_Account;
                                  AProvisional: Boolean = false): TdlgHistorical;
    property CurrentSortOrder : Integer read TranSortOrder;
    function GetComboIndexForEntryType(EntryType: Integer): Byte;
    procedure AmountEdited(pT: pTransaction_Rec; Doupdate: Boolean = true);
    procedure UpdateChequeNo(pT: pTransaction_Rec);
    property Provisional: Boolean read FProvisional write SetProvisional;
    property IniFile : string read GetIniFile;
    property HasCheques : boolean read fHasCheques write fHasCheques;
  end;

function AddHistoricalData : boolean;
function AddManualData : boolean;
function AddProvisionalData(ForAccount: string) : boolean;

//******************************************************************************
implementation

uses
  ClientHomepagefrm,
  ArchUtil32,
  clobj32,
  ForexHelpers,
  UsageUtils,
  MainTainGroupsFrm,
  OvcConst,
  bkBranding,
  BkConst,
  BKHelp,
  BKUtil32,
  bkXPThemes,
  glConst,
  Globals,
  OvcTbCls,
  Math,
  Bk5Except,
  bkDateUtils,
  bktxio,
  bkdsio,
  WarningMoreFrm,
  InfoMoreFrm,
  YesNoDlg,
  PayeeRecodeDlg,
  LogUtil,
  GstCalc32,
  WinUtils,
  GenUtils,
  bkMaskUtils,
  CanvasUtils,
  AccountLookupFrm,
  GSTLookupFrm,
  PayeeLookupFrm,
  DissectionDlg,
  trxList32,
  ImagesFrm,
  AccsDlg,
  MoneyUtils, 
  //ColRestrictedFrm,
  ConfigColumnsFrm,
  HistChequesDlg,
  MonitorUtils,
  ueList32,
  admin32,
  StDate,
  mxUtils,
  ECollect,
  Software,
  CountryUtils,
  PayeeObj,
  baUtils,
  EditBankDlg,
  TransactionUtils,
  ImportHistDlg,
  Finalise32,
  AuditMgr,
  SYPEIO,
  SuggestedMems,
  RegistryUtils,
  MAINFRM;

{$R *.DFM}

var DebugMe: boolean = false;

const
  UnitName = 'HISTORICALDLG';

const
  //**** ALWAYS ADD NEW COLUMNS ONTO THE END BECAUSE ID IS STORED FOR CONFIG COLUMNS
  ceEffDate        = 1;
  ceReference      = 2;
  ceAnalysis       = 3;
  ceAccount        = 4;
  ceAmount         = 5;
  ceNarration      = 6;    {oz}
  ceOtherParty     = 7;    {nz}
  ceParticulars    = 8;    {nz}
  cePayee          = 9;
  ceGSTClass       = 10;   {nz}
  ceGSTAmount      = 11;   {nz}
  ceQuantity       = 12;
  ceEntryType      = 13;
  ceCodedBy        = 15;
  ceBalance        = 16;
  ceDescription    = 17;
  cePayeeName      = 18;
  ceTaxInvoice     = 19;
  ceJob            = 20;
  ceJobName        = 21;
  ceForexRate      = 22;
//  ceForexAmount    = 23;
  ceLocalAmount    = 23;
  ceAltChartCode   = 24;

  {status panel constants}
  PANELLINE = 0;
  PANELTEXT = 1;
  GSTTEXT   = 2;

  {table command const}
  tcLookup            = ccUserFirst + 1;
  tcNextUncoded       = ccUserFirst + 3;
  tcSort              = ccUserFirst + 4;
  tcView              = ccUserFirst + 5;
  tcMore              = ccUserFirst + 6;
  tcPayeeLookup       = ccUserFirst + 7;
  tcAcctLookup        = ccUserFirst + 8;
  tcDissect           = ccUserFirst + 10;
  tcDitto             = ccUserFirst + 12;
  tcDittoLine         = ccUserFirst + 13;
  tcDeleteTrans       = ccUserFirst + 15;
  tcDeleteCell        = ccUserFirst + 17;
  tcInsertTrans       = ccUserFirst + 18;
  tcInsertCheques     = ccUserFirst + 19;
  tcGSTLookup         = ccUserFirst + 20;
  tcJobLookup         = ccUserFirst + 21;

  //constants to tell where to insert a new line
  InsertAbove = 0;
  InsertBelow = 1;
  InsertAtEnd = 2;

  //constants for balance indicators
  BAL_INFUNDS   = 0;
  BAL_OVERDRAWN = 1;
  BAL_UNKNOWN   = 2;

const
  ToolBarButtonGlyphOnlyWidth = 26;
  ToolBarButtonWithTextWidth  = 32;
  ToolbarButtonDropArrowWidth = 12;
  ToolbarFontSize             = 4;

const
  NoEntriesBeforeReminder = 100;
  MinSize = 350;

resourcestring
  rsMsgWrongAffectiveDate = 'Please enter a date on or before %s.';

type
  TMyPanel = class( TPanel)
    public
      property Canvas;
  end;


procedure TdlgHistorical.Setup;
begin
  fHasCheques := PrivateProfileTextToBoolean(GetPrivateProfileText(IniFile, BankAccount.baFields.baBank_Account_Number, kHasCheques));

  with tblHist do
  begin
     AllowRedraw := false;
      celForexRate.PictureMask := MoneyUtils.ForexPictureMask;

    MoneyUtils.BalanceStr( 0, BCode );
    SetupColumnFmtList;

    LoadLayoutForThisAcct(BankAccount.IsManual);

    BuildTableColumns;


    //enter key will end edit and move right
    CommandOnEnter := ccRight;
    // Now set tblHist Events
    OnLockedCellClick          := tblHistLockedCellClick;
    OnMouseMove                := tblHistMouseMove;
    OnActiveCellMoving         := tblHistActiveCellMoving;
    OnGetCellAttributes        := tblHistGetCellAttributes;
    OnEnteringRow              := tblHistEnteringRow;
    OnActiveCellChanged        := tblHistActiveCellChanged;
    OnUserCommand              := tblHistUserCommand;
    //Data Events
    OnBeginEdit                := tblHistBeginEdit;
    OnGetCellData              := tblHistGetCellData;
    OnEndEdit                  := tblHistEndEdit;
    OnDoneEdit                 := tblHistDoneEdit;

     //setup sort arrow
    with hdrColumnHeadings do begin
       ShowSortArrow      := true;
       SortArrowColor     := clBtnShadow;
       SortArrowFillColor := clBtnFace;
    end;
    //setup date parameters
    with celDate do begin
       Epoch := BKDATEEPOCH;
       PictureMask := BKDATEFORMAT;
       MaxLength := Length(BKDATEFORMAT);
    end;
    //Set color for alternate lines in the table
    clStdLineLight := clWindow;
    clStdLineDark := bkBranding.AlternateCodingLineColor;

    mniSortByNarration.Caption := 'By &Narration';


    SetupHelp;
      //add the first row
    InsertNewRow( InsertAtEnd ); // Insert a blank row
    FirstActivate := true;
    AllowRedraw := true;
    LastReminderAt := 0;
  end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
class function TdlgHistorical.CreateAndSetup(aBankAccount: TBank_Account; AProvisional: Boolean = false): TdlgHistorical;
var
  i              : integer;
  FirstPDate     : integer;
  FirstBankDate  : integer;
  ED, TD, CD: Integer;
begin
   //create the form
   Result := TdlgHistorical.Create(Application.MainForm);
   with Result, tblHist do begin

      BankAccount := aBankAccount;

      fIsForex := BankAccount.IsAForexAccount;
      Provisional := AProvisional;

      CCode := MyClient.clExtra.ceLocal_Currency_Code;
      BCode := BankAccount.baFields.baCurrency_Code;
      FCountry := MyClient.clFields.clCountry;

      Result.Caption := format ('Add %s Entries',[AccountType]);
      tblHist.Hint:= Format(
                    'Enter the details for each %0:s Entry|'+
                    'Enter the details for each %0:s Entry',[AccountType]);

      LoadLayoutForThisAcct(BankAccount.IsManual);

      SetupEntryTypeList(MyClient.clFields.clCountry);

      InitController;
      //set max gst id length
      celGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
      celAccount.MaxLength := MaxBk5CodeLen;
      celNarration.MaxLength := MaxNarrationEditLength;

      if BankAccount.IsManual then
        SetSortOrder( BankAccount.baFields.baMDE_Sort_Order )
      else
        SetSortOrder( BankAccount.baFields.baHDE_Sort_Order );


      if HasAlternativeChartCode(FCountry,MyClient.clFields.clAccounting_System_Used) then begin
        mniSortByAltCode.Caption := Format ('By %s',[AlternativeChartCodeName(FCountry,MyClient.clFields.clAccounting_System_Used)]);
      end else
        mniSortByAltCode.Visible := False;

      //setup bank account details

      with lblAcctDetails do begin
         Caption := Format('A/C  %s',[ BankAccount.Title ]);
         Hint := Caption;  //set so user can see the full details even if form width small
      end;

      HistTranList := TUnSorted_Transaction_List.Create;
      ExistingCheques := TChequesList.Create;
      //Find the date of the first non historical entry
      FirstBankDate := 0;
      FirstPDate    := 0;

      //Should never be able to enter historical txns into a provisional account
//      if BankAccount.IsProvisional then begin
//         MaxHistTranDate := 0; // unlimited
//         lblTransRange.Caption := 'You may enter transactions for any date.';
//      end else if BankAccount.IsManual then begin

      if BankAccount.IsManual then begin
         MaxHistTranDate := 0; // unlimited
         ED := GetMDEExpiryDate(MyClient.clBank_Account_List);
         TD := GetLatestTransDate(MyClient.clBank_Account_List);
         // if latest tx date is more than 4 months from expiry date then tell user account will expire
         CD := IncDate(ED, 0, -4, 0);
         if (TD < CD) and (not BankAccount.baFields.baExtend_Expiry_Date) then
            lblTransRange.Caption := Format('You may enter transactions for any date, but Manual Accounts expire on %s.',[bkDate2Str(ED)])
         else
            lblTransRange.Caption := 'You may enter transactions for any date.';
      end else begin
         // Must be Historical...
         with BankAccount.baTransaction_List do begin
            for i := 0 to Pred( itemCount ) do
               with Transaction_At( i )^ do begin
                  //look for the first bank entry on historical entry
                  if (txSource = orBank) then begin
                     if (FirstBankDate=0)
                     or ((FirstBankDate > 0) and (txDate_Presented < FirstBankDate) and (txDate_Presented > 0)) then
                          FirstBankDate := txDate_Presented;
                  end;

                  //store date of first presented transaction
                  if (FirstPDate = 0)
                  or ((FirstPDate > 0) and (txDate_Presented < FirstPDate) and (txDate_Presented > 0)) then
                     FirstPDate := txDate_Presented;

                  //Populate the List with all the ChequeNos, for cheques that have been
                  //presented, from the transactions list.
                  if (txCheque_Number <> 0)
                  and (txDate_Presented <> 0) then
                     with ExistingCheques do
                        if not ChequeIsThere(txCheque_Number) then
                           InsChequeRec(txCheque_Number);
               end; // transaction
            MaxHistTranDate := FirstBankDate -1;
            lblTransRange.caption := 'Enter Transactions up to and including ' +
                                     bkDate2Str(MaxHistTranDate) + '.';
         end;

      end;// Historical

      // Sets the closing balance to 0.00 with the right currency symbol in
      // front of it.
      stClosingBal.Caption := BankAccount.BalanceStr(0);

      // Setup events and help text
      Setup;
   end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  Handled := False;
  if Msg.CharCode = VK_ESCAPE then
    ModalResult := mrCancel;
end;

procedure TdlgHistorical.FormShow(Sender: TObject);
//note: needs the form position parameter to be poDesigned to get this to work,
//otherwise the controls were not automatical positioned correctly

//The reason for using this method, rather that poDesktopCentre and setting the
//width & height, is so that we get the maximum area without overlapping the
//taskbar or any other toolbars.  Automatically centering the form uses the
//whole screen.
const
   HMargin = 40;
   VMargin = 80;
var
   vsbWidth  : integer;
   dskWidth,
   dskHeight : integer;
   WorkArea  : TRect;
begin
   //Get Width Vertical Scroll Bar, Size of desktop (excludes taskbar)
   vsbWidth    := GetSystemMetrics( SM_CXVSCROLL );
   //Find out what area we have to work with
   WorkArea := GetDesktopWorkArea;
   dskWidth    := WorkArea.Right - WorkArea.Left;
   dskHeight   := WorkArea.Bottom - WorkArea.Top;
   //Set Size and Position, Center in Desktop area
   ClientWidth := Min(tblHist.ColumnFmtList.SumAdjColumnWidth + vsbWidth, dskWidth- HMargin);
   Height      := (dskHeight - VMargin);
   Top         := WorkArea.Top + (dskHeight - Height) div 2;
   Left        := WorkArea.Left +(dskWidth - Width) div 2;
   //Determine if captions should be shown on toolbar
   SetCaptionState( rztHistorical, INI_ShowToolbarCaptions);
   //set panel color
   pnlExtraTitleBar.GradientColorStart  := bkBranding.TobBarStartColor;
   pnlExtraTitleBar.GradientColorStop   := bkBranding.TopBarStopColor;
   lblAcctDetails.Font.Color := bkBranding.TopTitleColor;

   bkBranding.StyleTransRangeText(lblTransRange); 

   bkBranding.StyleTopBannerRightImage(imgGraphic);
   if Assigned(MyClient) and MyClient.clFields.clFile_Read_Only then
   begin
     lblAcctDetails.Font.Color :=  clRed;
     lblTransRange.Font.Color := clRed;
   end;
   DittoLineInProgress := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.FormResize(Sender: TObject);
begin
  UpdatePanelWidth;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  FCountry := MyClient.clFields.clCountry;

  bkBranding.StyleAltRowColor(AltLineColor);

  lblAcctDetails.Font.Name := Font.Name;
  lblTransRange.Font.Name := Font.Name;
  SetLength( tmpBuffer, MaxNarrationEditLength + 1);
  Undo := false;

  With LookupGSTClass1 do Caption := Localise( FCountry, Caption );

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.FormDestroy(Sender: TObject);
begin
   HistTranList.Free;
   ExistingCheques.Free;
   SetLength( tmpBuffer, 0);   //free memory associated with temp buffer of char   
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbSign.Hint     :=
                    'Select whether the account is In Funds (IF) or Overdrawn (OD)|' +
                    'Select whether the account is In Funds (IF) or Overdrawn (OD)';
   nfOpeningBal.Hint:=
                    'Enter the opening balance|'+
                    'Enter the opening balance as at the begining of the first entry';
   //Coding toolbar
   tbView.Hint  :=
                    'Change View|'
                   +'Edit All Columns or Select Columns only, Change Column Settings';
   tbSort.Hint  :=
                    'Sort the transactions|'
                   +'Sort the transactions into a different order';
   actChart.Hint  :=
                    'Look up the Chart of Accounts|'+
                    'Look up the client''s Chart of Accounts';
   tbCopyLine.Hint  :=
                    'Copy line|'+
                    'Copy the information from the row above';
   tbRepeat.Hint  :=
                    'Copy field|'+
                    'Copy the information from the cell above';
   actDissect.Hint :=
                    'Dissect a transaction|'+
                    'Dissect the transaction total over multiple chart codes';
   actPayees.Hint  :=
                    'Look up the Payee List|'+
                    'Look up the client''s Payee List';
   actJob.Hint  :=
                    'Look up the Job List|'+
                    'Look up the client''s Job List';
   tbAddCheques.Hint  :=
                    'Enter Cheques|'+
                    'Enter a range of Cheques';

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetupColumnFmtList;
// Note that TColFmtList allows for 2 edit modes Restricted and General
// The Restricted mode is not used in the Coding form as only one column is
// available and this has other ramifications
// EditAccountCodeOnly flag used instead
var
   AllowGSTAmtEditing : boolean;
   AllowGSTClassEditing : boolean;
begin
   with tblHist.ColumnFmtList do begin
      FreeAll;
      //BankLink Columns
      InsColDefnRec( 'Date', ceEffDate, celDate,  70, true, true, true, csDateEffective, 'Effective Date' );
      InsColDefnRec( 'Reference', ceReference, celRef, 100, true, true, true, csReference );

      case MyClient.clFields.clCountry of
         whNewZealand : begin
               InsColDefnRec( 'Analysis', ceAnalysis, celAnalysis, 100, true, true, true, -1 );
         end;
      end;

      if not Provisional then begin
         InsColDefnRec( 'Account', ceAccount, celAccount, CalcAcctColWidth( tblHist.Canvas, tblHist.Font, 70), true, true, true, csAccountCode  );
         InsColDefnRec( 'A/c Desc',   ceDescription, celDescription, 150, false, false, false, -1);
      end;

      if MyClient.HasForeignCurrencyAccounts then begin
            if fIsForex then begin
               InsColDefnRec( 'Amount (' + BCode + ')', ceAmount, celAmount, 120, True, True, True, csByValue );
               InsColDefnRec( 'Rate', ceForexRate, celForexRate, 100, true, false, False, csByForexRate );
               InsColDefnRec( 'Amount (' + CCode + ')', ceLocalAmount, celLocalAmount, 120, True, false, False, csByValue );
            end else
               InsColDefnRec( 'Amount (' + CCode + ')', ceAmount, celAmount, 120, True, True, True, csByValue );
      end else
            InsColDefnRec( 'Amount',   ceAmount, celAmount, 120, True, True, True, csByValue );




      InsColDefnRec( 'Narration', ceNarration, celNarration, 200, true, true, true, csByNarration );

      if not Provisional then begin
         InsColDefnRec( 'Payee', cePayee,    celPayee,   70, true, true, true, -1  );
         InsColDefnRec( 'Payee Name', cePayeeName,  celPayeeName, 100, false, false, false, -1);
         InsColDefnRec( 'Job', ceJob,  celJob, 50, false, false, true, -1);
         InsColDefnRec( 'Job Name', ceJobName,  celJobName, 100, false, false, False, -1);

         AllowGSTClassEditing := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

         case MyClient.clFields.clCountry of
         whNewZealand : begin
            InsColDefnRec( 'GST',   ceGSTClass, celGSTCode, 50, true, true, true, -1, 'GST Class ID'  );
            InsColDefnRec( 'GST Amount', ceGSTAmount, celGstAmt, 70, true, true, true, -1  );
         end;
         whAustralia  : begin
            //Ledger Elite doesn't support editing of the GST class
            InsColDefnRec( 'GST',   ceGSTClass, celGSTCode, 50, true, AllowGSTClassEditing, AllowGSTClassEditing, -1, 'GST Class ID'  );
            AllowGSTAmtEditing := ( MyClient.clFields.clBAS_Calculation_Method <> bmFull);
            InsColDefnRec( 'GST Amount', ceGSTAmount, celGstAmt, 70, true, AllowGSTAmtEditing, AllowGSTAmtEditing, -1  );
         end;
         whUK : begin
            InsColDefnRec( 'VAT',   ceGSTClass, celGSTCode, 50, true, true, true, -1, 'VAT Class ID'  );
            InsColDefnRec( 'VAT Amount', ceGSTAmount, celGstAmt, 70, true, true, true, -1  );
         end;
         end;
         InsColDefnRec( 'Tax Inv', ceTaxInvoice, celTaxInv, 55, false, true, true, -1);
      end;

      InsColDefnRec( 'Quantity',   ceQuantity,  celQuantity, 50, true, true, true, -1  );
      InsColDefnRec( 'Entry Type', ceEntryType, celEntryType, 70, true, true, true, -1 );

      if not Provisional then begin
         if HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
           InsColDefnRec(AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used)
                        , ceAltChartcode, CelAltChartCode, 80, false, false, false, csByAltChartCode );
      end;


      InsColDefnRec( 'Balance',    ceBalance,   celBalance, 120, true, false, false, csDateEffective);


      EditMode := emGeneral; //Never changed here
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.InitController;
const
   KeyMapName = 'Grid';

begin
   with cntController.EntryCommands do begin
     {remove existing defaults which conflict}
     DeleteCommand(KeyMapName,VK_F2,0,0,0);
     DeleteCommand(KeyMapName,vk_delete,0,0,0);
     DeleteCommand(KeyMapName,72,$04,0,0);  {CTRL+H acting as delete}

     {add our commands}
     AddCommand(KeyMapName,VK_F2,0,0,0,tcLookup);
     AddCommand(KeyMapName,VK_F3,0,0,0,tcPayeeLookup);
     AddCommand(KeyMapName,VK_F5,0,0,0,tcJobLookup);
     AddCommand(KeyMapName,VK_F6,0,0,0,ccTableEdit);
     AddCommand(KeyMapName,VK_F7,0,0,0,tcGSTLookup);
     AddCommand(KeyMapName,VK_F9,0,0,0,tcSort);
     Addcommand(KeyMapName,VK_DELETE,0,0,0,tcDeleteCell);
     AddCommand(KeyMapName,VK_DIVIDE,0,0,0,tcDissect);     {/ - NumPad}
     AddCommand(KeyMapName,VK_ADD,0,0,0,tcDitto);          {+ - NumPad}
     AddCommand(KeyMapName,191,0,0,0,tcDissect);           {/}

     AddCommand(KeyMapName,68,$04,0,0,tcDissect);          {ctrl+D}
     AddCommand(KeyMapName,76,$04,0,0,tcLookup);           {ctrl+L}
     AddCommand(KeyMapName,78,$04,0,0,tcDittoLine);        {ctrl+N}     
     AddCommand(KeyMapName,80,$04,0,0,tcPayeeLookup);      {ctrl+P}
     AddCommand(KeyMapName,82,$04,0,0,tcDitto);            {ctrl+R}
     AddCommand(KeyMapName,84,$04,0,0,tcSort);             {ctrl+T}
     AddCommand(KeyMapName,87,$04,0,0,tcView);             {ctrl+W}
     AddCommand(KeyMapName,89,$04,0,0,tcDeleteTrans);      {ctrl+Y}
     AddCommand(KeyMapName,$2E,$04,0,0,tcDeleteTrans);     {ctrl+delete}
     AddCommand(KeyMapName,$2D,$04,0,0,tcInsertCheques);   {ctrl+insert}
     AddCommand(KeyMapName,$2D,$02,0,0,tcInsertTrans);     {shift+insert}
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetTableAccess;
//the table should be read only if there are no transactions in the worktranlist
//InvalidateTable required for correct repaint when all rows deleted
begin
   if HistTranList.ItemCount > 0 then begin
      tblHist.Access   := otxNormal;
   end
   else begin
      tblHist.Access   := otxReadOnly;
   end;
   tblHist.InvalidateTable;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetSortOrder(NewSortOrder: integer);
var
   i : integer;
begin
   TranSortOrder  := NewSortOrder;
   //update sort column in the table
   with tblHist, ColumnFmtList do begin
      for i := 0 to Pred( ItemCount ) do begin
         if ColumnDefn_At(i)^.cdSortOrder = NewSortOrder then begin
            SortedCol := i;
            Break;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.Insertanewline1Click(Sender: TObject);
begin
  tblHistUserCommand(Sender, tcInsertTrans);
end;

function TdlgHistorical.InsertNewRow(InsertWhere : byte) : boolean;
var
   pT       : pTransaction_Rec;
   NewIndex : integer;
begin
   //look at the current line and insert new line above the curr line
   //create a new HistTranRec
   //increment the row limit for the table
   //then position active row on the new line
   result := false;
   NewIndex := -1;
   if not tblHist.StopEditingState(true) then exit;

   tblHist.AllowRedraw := false;
   try
      pT := Create_New_Transaction;
      pT.txBank_Account := TObject( BankAccount );
      pT.txClient := TObject( MyClient );
      with tblHist do begin
         if HistTranList.ItemCount = 0 then begin
            HistTranList.Insert(pT);
         end
         else begin
            //NewIndex is the position of the new item in the list
            case InsertWhere of
               InsertAbove : begin
                  HistTranList.AtInsert(ActiveRow-1, pT);
                  NewIndex := ActiveRow-1;
               end;
               InsertBelow : begin
                  HistTranList.AtInsert(ActiveRow, pT);
                  NewIndex := ActiveRow;
               end;
               InsertAtEnd : begin
                  NewIndex := HistTranList.Insert(pT);
               end;
            end;
         end;
         //get a pointer to the previous transaction (if there is one)
         Dec(NewIndex);
         if (NewIndex >= 0) and (NewIndex <= HistTranList.ItemCount) then
         begin
            pT^.txDate_Effective := HistTranList.Transaction_At(NewIndex).txDate_Effective;
            pT^.txTemp_Balance := HistTranList.Transaction_At(NewIndex).txTemp_Balance;
            if fIsForex then
               pT^.txForex_Conversion_Rate := BankAccount.Default_Forex_Conversion_Rate( pT.txDate_Effective );
         end
         else
         begin
            //set to -1 so that no date is displayed
            pT^.txDate_Effective := -1;
            pT^.txTemp_Balance := 0;
         end;
         //set to 255, to indicate that has not been set
         pT^.txType := 255;
         //update table
         RowLimit := Max( HistTranList.ItemCount + 1, 2 );
         SetTableAccess;
      end;
      result := true;
   finally
      tblHist.AllowRedraw := true;
   end;
   Refresh;
   //Reminder the user that they should not enter too many before saving
   RemindUserToSave;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SortHTLMaintainPos(ASortOrder: byte);
var
   pT : pTransaction_Rec;
   NewIndex : integer;
begin
   with tblHist do begin
      AllowRedraw := false;
      SetSortOrder(ASortOrder);

      if ( HistTranList.ItemCount > 0 ) then begin
         //save current trans pointer and reload then reposition
         pT := HistTranList.Transaction_At(tblHist.ActiveRow-1);
         //sort current list
         HistTranList.Sort( ASortOrder );
         //reposition
         NewIndex := HistTranList.IndexOf(pT);
         if NewIndex = -1 then
            tblHist.ActiveRow := 1
         else
            tblHist.ActiveRow := NewIndex+1;
      end
      else begin
         //no trans in current list, position at top
         tblHist.ActiveRow := 1
      end;
      CalculateBalanceColumn;
      InvalidateTable;
      AllowRedraw := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniLookupChartClick(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniLookupPayeeClick(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniDissectClick(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.ValidDataRow(RowNum : integer): boolean;
// Row 0 is heading row
begin
   result := (Assigned(HistTranList)) and
             ((RowNum > 0) and (RowNum <=  HistTranList.ItemCount ));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.ValidDate(aDate: Integer; msg: pstring = nil) : Boolean;
    procedure SetMessage(const Value: string);
    begin
       if assigned(msg) then
          msg^ := Value;
    end;
begin
   Result := False;
   if (aDate <= 0) then begin// No date entered
      SetMessage('You must enter a date for the current transaction.');
      Exit;
   end;

   if (MaxHistTranDate <> 0)
   and (aDate > MaxHistTranDate) then begin//Date later than max allowed
      SetMessage(Format('Please enter a date on or before %s.',[bkDate2Str(MaxHistTranDate)]));
      Exit;
   end;

   //check date is within banklink allowable range
   if (aDate < MinValidDate)
   or (aDate > MaxValidDate) then begin
      SetMessage(Format('Please enter a date between '#13'%s and %s.',[bkDate2Str(MinValidDate),bkDate2Str(MaxValidDate)]) );
      Exit;
   end;

   //Check if the date is in a finalised (locked) month
   if (IsMonthLocked(aDate) = ltAll) then begin
     SetMessage('Finalised entries exist in this month. Entries may not be added to finalised periods.');
     Exit;
   end;

   // Still here Must be OK
   Result := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.ValidChequeNo(aChequeNo: Integer; pExcludeTrx : pTransaction_Rec ): boolean;
//checks that cheque number is not already entered
//the exclude transaction pointer is used to make sure that we skip the transaction
//that we are actually testing.  Otherwise the function would always return false
//because it would match against the transaction we are trying to add

//### expects that IsaCheque has been called before calling this routine
var
   pT : pTransaction_Rec;
   i  : integer;
begin
   result := false;
   //must specify a cheque no
   if (aChequeNo <= 0) then begin
      exit;
   end;
   //see if cheque no is no bank account transactions
   if ExistingCheques.ChequeIsThere( aChequeNo) then exit;
   //test for duplicate in current historical transactions
   for i := 0 to Pred( HistTranList.ItemCount) do begin
      //test for exclude transaction
      pT := HistTranList.Transaction_At( i);
      if ( pExcludeTrx <> nil) and ( pT = pExcludeTrx) then continue;
      //test to see if this cheque number has already been entered
      if ( pT^.txCheque_Number = aChequeNo) then begin
         //Duplicate found
         exit;
      end;
   end;
   result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.ValidateChequeNumber(var RowNum, ColNum: Integer; pT: pTransaction_Rec): Boolean;
var
  aMsg: string;
begin
   Result := True;
   if IsACheque( pT) then begin
      if not ValidChequeNo( pT^.txCheque_Number, pT) then begin
         ColNum := tblHist.ColumnFmtList.GetColNumOfField( ceReference );
         RowNum := tblHist.ActiveRow;
         //Report reasons
         if pT^.txCheque_Number <= 0 then
            aMsg := 'You must enter a valid cheque number.'
         else
            aMsg := 'This cheque number is already in the existing entries.  Please enter '+
                    'a different cheque number.';
         HelpfulWarningMsg( aMsg, 0);
         Result := False;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.ValidateActiveTrans(pT: pTransaction_Rec;
  var RowNum, ColNum: integer): boolean;
//if the validation fails then the Row and Col values will contain the location
//of the cell that needs to be edited
var
   aMsg : string;
begin
   result := false;
   //check that a date has been entered for the current row first
   if not ValidDate( pT^.txDate_Effective, @amsg) then begin
      ColNum := tblHist.ColumnFmtList.GetColNumOfField( ceEffDate );
      RowNum := tblHist.ActiveRow;

      HelpfulWarningMsg( aMsg,0);

      Exit;
   end;
   if not ValidateChequeNumber(RowNum, ColNum, pT) then
      Exit;
   result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   RowEstimate, ColEstimate : integer;
begin
   with tblHist do begin
      if not ( CalcRowColFromXY(x, y, RowEstimate, ColEstimate) = otrInLocked ) then begin
         Cursor := crDefault;
         Exit;
      end;
      if ( ColumnFmtList.ColumnDefn_At( ColEstimate ).cdSortOrder <> -1) then
         Cursor := crHandPoint
      else
         Cursor := crDefault;
   end;
end;
procedure TdlgHistorical.tblHistMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CodingMouseUp(Sender, Button, Shift, X, Y);
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistLockedCellClick(Sender: TObject; RowNum,
  ColNum: Integer);
var
   NewSortOrder : integer;
begin
   NewSortOrder := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdSortOrder;
   if NewSortOrder = -1 then exit;
   SortHTLMaintainPos( NewSortOrder );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
// Note - When attempting to leave last row, RowNum is same as active row
var
   pT         : pTransaction_Rec;
   NewRowReqd : Boolean;
   MovingToNextLine  : Boolean;
begin
   if not ValidDataRow( tblHist.ActiveRow ) then
      exit;

   //Force a save of the edited data now.  This is so that EndEdit and DoneEdit are
   //called before the validation is done.  If there was a better place to do the line
   //validation then this would not be necessary.
   if tblHist.InEditingState then begin
      if tblHist.StopEditingState( true) then
         //Editing successfully stopped.  This means that DoneEdit has been called so
         //we can proceed validating the line
      else begin
         //unable to end the edit state, so set the row num and col num to the active cell
         //exit now because there is no need to do validation
         RowNum := tblHist.ActiveRow;
         ColNum := tblHist.ActiveCol;
         exit;
      end;
   end;

   //now do validation and test for needing a new line
   with tblHist do begin
      //Do we need a new line??
      NewRowReqd := False;
      //See if at end of line and moving right
      MovingToNextLine  := ((Command = ccRight) and (ActiveCol = ColumnFmtList.GetRightMostEditCol));
      //Test to see if the current col is the last row
      if (ActiveRow = Pred(RowLimit)) then begin
         //If we are in the right most column then move down
         if MovingToNextLine or ( (Command = ccDown ) ) then begin
            NewRowReqd := True;
         end;
      end;
      //get current transaction
      pT := HistTranList.Transaction_At( ActiveRow - 1 );

      //Check to see if leaving current row which has not been edited
      if (ActiveRow <> RowNum) and (not NewRowReqd) then
         if not pT^.txHas_Been_Edited then begin
            DeleteCurrentLine;
            exit;
         end;

      //validate current transaction
      if (ActiveRow <> RowNum) or MovingToNextLine or NewRowReqd then begin
         if not ValidateActiveTrans( pT, RowNum, ColNum) then
            //ValidateActiveTrans will change RowNum and ColNum if it fails
            exit;
      end;

      //insert a new row
      if NewRowReqd then begin
         if not InsertNewRow( InsertAtEnd ) then
           exit;
         Inc(RowNum);
         ColNum := 0;
      end;
   end;
end;

function TdlgHistorical.GetComboIndexForEntryType(EntryType: Integer): Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to celEntryType.Items.Count - 1 do
  begin
    if Integer(celEntryType.Items.Objects[I]) = EntryType then
    begin
      Result := I;
      Break;
    end;
  end;
end;
function TdlgHistorical.GetIniFile: string;
begin
  Result := Globals.DataDir + IMPORT_INIFILE;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetupEntryTypeList(Country: Byte);
//Used to fill the Entry Type col combo box, the actual entry type values are
//stored in the object field of the item
begin
   with celEntryType do begin
      Items.Clear;


         case Country of
            whNewZealand : begin
               Items.AddObject('Cheque',    TObject(etChequeNZ));
               Items.AddObject('Withdrawal', TObject(etWithdrawlNZ));
               Items.AddObject('Deposit',   TObject(etDepositNZ));
//               Items.AddObject('Auto Pymt', TObject(etAutoPaymentNZ));
            end;
            whAustralia : begin
               Items.AddObject('Cheque',    TObject(etChequeOZ));
               Items.AddObject('Withdrawal', TObject(etWithdrawlOZ));
               Items.AddObject('Deposit',   TObject(etDepositOZ));
//               Items.AddObject('Auto Pymt', TObject(etAutoPaymentOZ));
            end;
            whUK : Begin
               Items.AddObject('Cheque',    TObject(etChequeUK));
               Items.AddObject('Withdrawal', TObject(etWithdrawlUK));
               Items.AddObject('Deposit',   TObject(etDepositUK));
            end;
         end;

      //update ChequeTypeCmbIndex which provides a quick test to see if
      //transaction is a cheque
      ChequeTypeCmbIndex := 0;
      //update DepositTypeCmbIndex
      DepositTypeCmbIndex := 2;
   end;
end;
//-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveLayoutForThisAcct;
end;


procedure TdlgHistorical.SetupColDefaultSets;
begin
   DefaultEditableCols := [ceEffDate, ceReference, ceAnalysis, ceAccount, ceAmount, ceNarration, ceOtherParty,
                           ceParticulars, cePayee, ceQuantity, ceEntryType, ceTaxInvoice, cejob];

//  if fIsForex then
//  Begin
//    DefaultEditableCols := DefaultEditableCols - [ ceAmount ];
//    DefaultEditableCols := DefaultEditableCols + [ ceForexAmount ];
//  End;

   If Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
      DefaultEditableCols := DefaultEditableCols + [ceGSTClass];

   if (MyClient.clFields.clCountry = whNewZealand )
   or ((MyClient.clFields.clCountry = whAustralia ) and ( MyClient.clFields.clBAS_Calculation_Method <> bmFull)) then
      DefaultEditableCols := DefaultEditableCols + [ceGSTAmount];
end;

procedure TdlgHistorical.SaveLayoutForThisAcct;
var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;

   for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
     begin
       ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);

       if IsManual then
       begin
         BankAccount.baFields.baMDE_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
         BankAccount.baFields.baMDE_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
         BankAccount.baFields.baMDE_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
         if ColDefn^.cdFieldId in DefaultEditableCols then
           BankAccount.baFields.baMDE_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
       end
       else
       begin
         BankAccount.baFields.baHDE_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
         BankAccount.baFields.baHDE_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
         BankAccount.baFields.baHDE_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
         if ColDefn^.cdFieldId in DefaultEditableCols then
           BankAccount.baFields.baHDE_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
       end;
     end;
     if IsManual then
       BankAccount.baFields.baMDE_Sort_Order := CurrentSortOrder
     else
       BankAccount.baFields.baHDE_Sort_Order := CurrentSortOrder;
end;


procedure TdlgHistorical.LoadLayoutForThisAcct(Manual: Boolean);
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
   i, PosDesc, PosPN, PosTI : integer;
   ColDefn : pColumnDefn;
   UseDefault: Boolean;
   FirstDesc, FirstPN, FirstTI: Boolean;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;
   FirstDesc := False;
   FirstPN := False;
   FirstTI := False;
   PosDesc := 3;
   PosPN := 8;
   PosTI := 10;
   if MyClient.clFields.clCountry  = whNewZealand then
   begin
     PosDesc := PosDesc + 1;
     PosPN := PosPN + 1;
     PosTI := PosTI + 1;
   end;
   for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
   begin
      UseDefault := False;
      ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);
      with ColDefn^, BankAccount.baFields do
      begin
         if Manual then
         begin
           if (cdFieldId = ceDescription) and (baMDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstDesc := True
           else if (cdFieldId = cePayeeName) and (baMDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstPN := True
           else if (cdFieldId = ceTaxInvoice) and (baMDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstTI := True;
           if baMDE_Column_Width[ cdFieldID] <> 0 then
           begin
             cdWidth            := baMDE_Column_Width[ cdFieldID];
             cdRequiredPosition := baMDE_Column_Order[ cdFieldID];
             cdHidden           := baMDE_Column_Is_Hidden[ cdFieldID];
             //set status of columns that are editable by default
             if cdFieldId in DefaultEditableCols then
               cdEditMode[ emGeneral] := not baMDE_Column_Is_Not_Editable[ cdFieldID]
             else
               cdEditMode[ emGeneral] := False;
           end
           else
             UseDefault := True;
         end
         else // historical
         begin
           if (cdFieldId = ceDescription) and (baHDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstDesc := True
           else if (cdFieldId = cePayeeName) and (baHDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstPN := True
           else if (cdFieldId = ceTaxInvoice) and (baHDE_Column_Width[ cdFieldID] = 0) then // first time
             FirstTI := True;
           if baHDE_Column_Width[ cdFieldID] <> 0 then
           begin
             cdWidth            := baHDE_Column_Width[ cdFieldID];
             cdRequiredPosition := baHDE_Column_Order[ cdFieldID];
             cdHidden           := baHDE_Column_Is_Hidden[ cdFieldID];
             //set status of columns that are editable by default
             if cdFieldId in DefaultEditableCols then
               cdEditMode[ emGeneral] := not baHDE_Column_Is_Not_Editable[ cdFieldID]
             else
               cdEditMode[ emGeneral] := False;
           end
           else
             UseDefault := True;
         end; // if manual
         if UseDefault then
         begin
           //defaults will be used
           cdWidth            := cdDefWidth;
           cdRequiredPosition := cdDefPosition;
           cdHidden           := cdDefHidden;
           cdEditMode[ emGeneral] := (cdFieldId in DefaultEditableCols);
         end;
         if cdFieldId = ceAccount then
          PosDesc := cdRequiredPosition+1
         else if cdFieldId = cePayee then
          PosPN := cdRequiredPosition+1
         else if cdFieldId = ceGSTAmount then
          PosTI := cdRequiredPosition+1;
      end; // with
   end; // for
   if FirstDesc then
     for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
     begin
       ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = ceDescription then
         ColDefn.cdRequiredPosition := PosDesc
       else if ColDefn.cdRequiredPosition >= PosDesc then
       begin
        if FirstPN and (ColDefn.cdFieldId = cePayee) then
          PosPN := PosPN + 1;
        if FirstTI and (ColDefn.cdFieldId = ceGSTAmount) then
          PosTI := PosTI + 1;
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
       end;
     end;
   if FirstPN then
     for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
     begin
       ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = cePayeeName then
        ColDefn.cdRequiredPosition := PosPN
       else if ColDefn.cdRequiredPosition >= PosPN then
       begin
        if FirstPN and (ColDefn.cdFieldId = cePayee) then
          PosPN := PosPN + 1;
        if FirstTI and (ColDefn.cdFieldId = ceGSTAmount) then
          PosTI := PosTI + 1;
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
       end;
     end;
   if FirstTI then
     for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
     begin
       ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = ceTaxInvoice then
        ColDefn.cdRequiredPosition := PosTI
       else if ColDefn.cdRequiredPosition >= PosTI then
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
     end;
   //now resort list into correct order
   tblHist.ColumnFmtList.ReOrder;
   for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do
   begin
     ColDefn := tblHist.ColumnFmtList.ColumnDefn_At(i);
     ColDefn.cdRequiredPosition := i;
   end;
end;

procedure TdlgHistorical.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//a valid entry is    Date within 0 - MaxHistTransDate
//                    has been edited
//                    has a valid cheque no (if is a cheq)
//                    cheque number is not duplicated
//if an invalid entry is found do what?
//                    if not edited then ignore it
//                    if date invalid then prompt user to fix
//                    if cheq no invalid the prompt user to fix
var
   pT              : pTransaction_Rec;
   i               : integer;
   InvalidRow      : integer;
   InvalidCol      : integer;
   //Title, Msg, Msg1: string;
begin
   CanClose := False;
   Undo := True;
   //finish editing current cell
   if not tblHist.StopEditingState(true) then
      exit;
   //if there is nothing there just exit, dont care which button
   if HistTranList.ItemCount = 0 then begin
      CanClose := true;
      exit;
   end;
   //if there is only one entry then see if it has been edited.  This is a special
   //case because it may just be the default entry that is in the box when it was created
   //if it has not been edited then allow ok, allow cancel regardless of editing
   if HistTranList.ItemCount = 1 then begin
      pT := HistTranList.Transaction_At(0);
      if ( not pT^.txHas_Been_Edited) then begin
         CanClose := true;
         exit;
      end;
   end;
   //if cancel pressed, or form closed then ask before doing anything.  This will mean that can cancel out
   //even if current transaction is invalid
   if ( ModalResult = mrCancel ) then begin
      if AskYesNo( Format('Cancel %s Data Entry',[AccountType]),
                   Format('If you cancel, the %s Transactions you have entered will be LOST!'#13#13+
                   'Are you sure you want to cancel and lose these transactions?',[AccountType]), DLG_NO, 0 ) = DLG_YES then begin
          CanClose := True;
          exit;
      end
      else begin
         tblHist.SetFocus;
         Exit;
      end;
   end;

   //ok pressed so valid active line, remove any lines that are not edited and see what is left
   if ModalResult = mrOK then begin
      //validate active line
      if ValidDataRow(tblHist.ActiveRow) then begin
         pT   := HistTranList.Transaction_At(tblHist.ActiveRow-1);
         InvalidRow  := 0;
         InvalidCol  := 0;
         if not ValidateActiveTrans( pT, InvalidRow, InvalidCol) then begin
            //reposition on invalid cell
            tblHist.SetFocus;
            tblHist.ActiveRow   := InvalidRow;
            tblHist.ActiveCol   := InvalidCol;
            exit;
         end;
      end;
      //delete any lines that have not been edited , probably means that have arrowed down
      //and created a number of blank links with automatic dates.
      tblHist.AllowRedraw := false;  //stop any redraws because we may be deleting transactions
      i := 0;
      While (i <= Pred(HistTranList.ItemCount)) do
      begin
        pT := HistTranList.Transaction_At(i);
        if not (pT^.txHas_Been_Edited ) then
        begin
          HistTranList.DelFreeItem(pT);
        end
        else
          Inc(i);  //try next one
      end;
      tblHist.RowLimit := Max( HistTranList.ItemCount + 1, 2);
      SetTableAccess;
      tblHist.AllowRedraw := true;
      tblHist.Refresh;
      //the date validation and cheque number validation for all other entries
      //will have been done by either ActiveCellMoving, or before inserting a new line
      //if ok then try to add entries
      if  HistTranList.ItemCount = 0 then begin
         //no valid entries
         HelpfulWarningMsg(format('There are no %s entries to add.',[AccountType]),0 );
         CanClose := false;
         Exit;
      end;

      //Confirm addition

      if AskYesNo(
           Format('Confirm Add %s Entries', [ AccountType]),
           Format('The %s Transactions you have entered will now be added to Bank Account:'#13#13'%s'#13#13'Is it OK to Post these entries now?',
                     [AccountType,BankAccount.Title ]),
                   DLG_YES,0
                 ) <> DLG_YES then
           begin
              tblHist.SetFocus;
              Exit;
           end;

      //Merge new transactions into the bank account

      incUsage(Format('%s Transactions',[AccountType]));

      InsertTranIntoBankAccount;
      //Close form is ok
      CanClose := True;
   end else
      //if we get here then modal result is not mrOK or mrCancel so close form
      CanClose := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistGetCellAttributes(Sender: TObject;
  RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
var
  dtDate : Integer;
begin
  if (CellAttr.caColor = tblHist.Color) and (RowNum >= tblHist.LockedRows) then begin
    if Odd(RowNum) then
       CellAttr.caColor := clStdLineLight
    else
       CellAttr.caColor := AltLineColor;

    if (Provisional and (HistTranList.ItemCount > 1) and (RowNum > 0)) then
    begin
      dtDate := HistTranList.Transaction_At(RowNum-1).txDate_Effective;//TOvcNumericField(tblHist.Cells.Cell[RowNum, 1].CellEditor).AsDateTime;
      CellAttr.caFontColor := clBlack;
      if (Provisional and  not (CheckEffectiveDate(dtDate))) then
        CellAttr.caFontColor := clRed;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistEnteringRow(Sender: TObject; RowNum: Integer);
var
   pAcc          : pAccount_Rec;
   pT            : pTransaction_Rec;
   AcctStatusStr : string;
   GSTStatusStr  : string;
   TransactionPos: String;
begin
   AcctStatusStr := '';
   GSTStatusStr  := '';

   with tblHist do begin
      if ( ActiveRow <> RowNum ) then exit;
   end;

   if not ValidDataRow(RowNum) then begin
      AcctStatusStr := '';
      GSTStatusStr  := '';
   end
   else begin
      pT   := HistTranList.Transaction_At(RowNum-1);
      with pT^ do begin
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
      end;
   end;

   //update status info
   TransactionPos := Format('%d of %d', [ tblHist.ActiveRow, (tblHist.Rowlimit-1)]);
   
   stbHistorical.Panels[PANELLINE].Width := Max(50, Canvas.TextWidth(TransactionPos) + 1);

   UpdatePanelWidth;

   stbHistorical.Panels[PANELLINE].Text := TransactionPos;
   stbHistorical.Panels[PANELTEXT].text := AcctStatusStr;
   stbHistorical.Panels[GSTTEXT]  .text := GSTStatusStr;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistActiveCellChanged(Sender: TObject; RowNum, ColNum: Integer);
var
   HintText : string;
   pT : pTransaction_Rec;
   FieldID   : Integer;
begin
   if not ValidDataRow(RowNum) then exit;

  //show hints, only long hints appear
  with HistTranList do begin
     pT   := Transaction_At(RowNum-1);
     FieldID := tblHist.ActiveFieldID;
     case FieldID of
        ceAccount : begin
           HintText      := Localise( FCountry, 'Enter an Account Code    (F2) Lookup Chart    (F3) Lookup Payee   (F7) Lookup GST' );

           if pT^.txFirst_Dissection <> nil then
              HintText   := 'Press ''/'' to edit the Dissection';
        end;

        ceNarration :
           HintText   := 'Enter a Narration';
        ceGSTClass :
           HintText   := Localise( FCountry, 'Enter the GST Code if applicable   (F7) Lookup GST' );
        ceGSTAmount :
           HintText   := Localise( FCountry, 'Enter the GST Amount if applicable ' );
        ceQuantity :
           HintText   := 'Enter the Quantity value';
        cePayee    :
           HintText   := 'Enter the Payee Number    (F3) Lookup Payee';
        ceJob      :
           HintText   := 'Enter the Job Code if applicable   (F5) Lookup Job';
     end; {case}
  end;
  tblHist.Hint := HintText;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistUserCommand(Sender: TObject;
  Command: Word);
var
   pT : pTransaction_Rec;
   InvalidRow, InvalidCol : integer;
   ClientP, ScreenP : TPoint;
begin
   if not ValidDataRow(tblHist.ActiveRow) then exit;
   pT   := HistTranList.Transaction_At(tblHist.ActiveRow-1);
   case Command of
     tcLookup :  //Fired by F2
       begin
         if pT^.txFirst_Dissection = nil then
            DoAccountLookup
         else
            DoDissection;
       end;
     tcGSTLookup   : DoGSTLookup;
     tcPayeeLookup : DoPayeeLookup;
     tcJobLookup   : DoJobLookup;
     tcAcctLookup  : DoAccountLookup;
     tcDissect     : DoDissection;
     tcDitto       : DoDitto;
     tcDittoLine   : DoDittoLine;
     tcDeleteTrans : DeleteCurrentLine;
     tcDeleteCell  : DoDeleteCell;
     tcInsertTrans : begin
        //must validate transaction here because row will not change in ActiveCellMoving
        //ActiveRow, ActiveCol will be changed by ValidateActiveTrans if it fails
        InvalidRow  := 0;
        InvalidCol  := 0;
        if ValidateActiveTrans( pT, InvalidRow, InvalidCol) then begin
           InsertNewRow( InsertAbove );
           tblHist.ActiveCol := tblHist.ColumnFmtList.GetColNumOfField( ceEffDate );
        end
        else begin
           //reposition on invalid cell
           tblHist.ActiveRow   := InvalidRow;
           tblHist.ActiveCol   := InvalidCol;
        end;
     end;
     tcInsertCheques : DoAddCheques;
     tcView          : begin
        ClientP.x := 0;
        ClientP.y := tbView.Height;
        ScreenP   := tbView.ClientToScreen(ClientP);
        popView.Popup(ScreenP.x, ScreenP.y);
     end;
     tcSort          : begin
        ClientP.x := 0;
        ClientP.y := tbSort.Height;
        ScreenP   := tbSort.ClientToScreen(ClientP);
        popSortBy.Popup(ScreenP.x, ScreenP.y);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.AccountEdited(pT : pTransaction_Rec);
//update other fields that change when account changes
var
  NewClass   : byte;
  NewGST     : money;
  IsActive   : boolean;
begin
  IsActive := True;
  with pT^ do begin
     if MyClient.clChart.CanCodeTo( txAccount, IsActive) then begin
//        CalculateGST( MyClient, txDate_Effective, txAccount, txAmount, NewClass, NewGST);
        CalculateGST( MyClient, txDate_Effective, txAccount, Local_Amount, NewClass, NewGST);
        txGST_Class  := NewClass;
        txGST_Amount := NewGST;
        txCoded_By   := cbManual;
        txGST_Has_Been_Edited := false;
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        //      however it should be cleared if the account code has been deleted
        if ( txAccount = '' ) then begin
           txGST_Class       := 0;
           txGST_Amount      := 0;
           txCoded_By        := cbNotcoded;
           txGST_Has_Been_Edited := false;
        end
        else // invalid code - we dont care! case 5978
           txCoded_By        := cbManual;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.GSTClassEdited(pT: pTransaction_Rec);
begin
   with pT^ do begin
      if txGST_Class = 0 then
         txGST_Amount := 0
      else
//         txGST_Amount := ( CalculateGSTForClass( MyClient,  txDate_Effective, txAmount, txGST_Class ) );
         txGST_Amount := ( CalculateGSTForClass( MyClient,  txDate_Effective, Local_Amount, txGST_Class ) );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.AmountEdited(pT : pTransaction_Rec; Doupdate: Boolean = true);
var
   ChequeNo : integer;
   DefaultGSTClass :  byte;
   DefaultGSTAmt   : money;
begin
   //Force Recalc of GST if not dissected
   if pT^.txFirst_Dissection = nil then begin
      GSTClassEdited( pT );
      //see if gst matches default now
      with pT^ do begin
//         CalculateGST( myClient, txDate_Effective, txAccount, txAmount, DefaultGSTClass, DefaultGSTAmt);
         CalculateGST( myClient, txDate_Effective, txAccount, Local_Amount, DefaultGSTClass, DefaultGSTAmt);
         txGST_Has_Been_Edited := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
      end;
   end;
   //update entry type if not set
   ChequeNo := StrToIntDef(pT^.txReference,0);
   case MyClient.clFields.clCountry of
      whNewZealand : begin
         if pT^.txAmount < 0 then
            //set entry type to deposit
            pT^.txType := FindETInCombo(etDepositNZ)
         else begin
            //could be either a cheque or a withdrawl, if reference contains
            //a valid cheque no the set type of cheque
            if (fHasCheques) and (ChequeNo > 0) then
               pT^.txType := FindETInCombo(etChequeNZ)
            else
               pT^.txType := FindETInCombo(etWithdrawlNZ);
         end;
      end;
      whAustralia  : begin
         if pT^.txAmount < 0 then
            //set entry type to deposit
            pT^.txType := FindETInCombo(etDepositOZ)
         else begin
            //could be either a cheque or a withdrawl, if reference contains
            //a valid cheque no the set type of cheque
            if (fHasCheques) and (ChequeNo > 0) then
               pT^.txType := FindETInCombo(etChequeOZ)
            else
               pT^.txType := FindETInCombo(etWithdrawlOZ);
         end;
      end;
      whUK  : begin
         if pT^.txAmount < 0 then
            //set entry type to deposit
            pT^.txType := FindETInCombo(etDepositUK)
         else begin
            //could be either a cheque or a withdrawl, if reference contains
            //a valid cheque no the set type of cheque
            if ChequeNo > 0 then
               pT^.txType := FindETInCombo(etChequeUK)
            else
               pT^.txType := FindETInCombo(etWithdrawlUK);
         end;
      end;
   end;
   SetQuantitySign(False);
   //update estimated balance
   if DoUpdate then begin

      CalculateBalanceColumn;
      CalcClosingBal;
   end;
end;
procedure TdlgHistorical.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgHistorical.btnOKClick(Sender: TObject);
  //inline function to be called only for provisional data to check any future date is available
  function IsNoFutureTransactionsAvailable : Boolean;
  var
    i: integer;
  begin
    Result := True;
    for i := HistTranList.First to HistTranList.Last do
    begin
      with HistTranList.Transaction_At( i)^ do
      begin
        if txDate_Effective > GetLastDayOfMonth(CurrentDate) then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;

begin
  if Provisional and (not IsNoFutureTransactionsAvailable) then
  begin
    HelpfulWarningMsg('Transaction(s) have future dates. Please amend the dates before proceeding.',0);
    Exit;
  end
  else
    ModalResult := mrOk;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TdlgHistorical.PayeeEdited(pT: pTransaction_Rec): boolean;
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
begin
  result := true;  //assume success

  if pT^.txPayee_Number = 0 then
     exit;  //don't need to do anything

  APayee := MyClient.clPayee_List.Find_Payee_Number(pT^.txPayee_Number);
  if not assigned(APayee) then begin
     Result := False;
     Exit;
  end;
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
        end;
     end
     else
     begin
//        if fIsForex then
//          Amount := txForeign_Currency_Amount
//        else
          Amount := txAmount;

        //payee is dissected, so dissect the transaction
        mxUtils.PayeePercentageSplit( Amount, aPayee, DissectAmt, DissectPct);

        txCoded_by       := cbManualPayee;
        txAccount        := DISSECT_DESC;

        ClearGSTFields(pT);
        ClearSuperFundFields( pT);

        for i := aPayee.pdLines.First to aPayee.pdLines.Last do
        begin
            PayeeLine := aPayee.pdLines.PayeeLine_At(i);
            Dissection := Create_New_Dissection;
            with Dissection^ do
              begin
                 dsTransaction         := pT;
                 dsAccount             := PayeeLine.plAccount;
                 if PayeeLine.plGL_Narration <> '' then
                   dsGL_Narration      := PayeeLine.plGL_Narration
                 else
                   dsGL_Narration      := pT^.txGL_Narration;
                 dsQuantity            := 0;

//                 if fIsForex then
//                   pT.SetForeignCurrencyAmountOnDissection( Dissection, DissectAmt[ i ] )
//                 else
                   dsAmount              := DissectAmt[i];

                 dsPercent_Amount      := DissectPct[i];
                 dsAmount_Type_Is_Percent := DissectPct[i] <> 0;
                 //calculate GST
                 if (PayeeLine.plGST_Has_Been_Edited) then begin
                    dsGST_Class    := PayeeLine.plGST_Class;
//                    dsGST_Amount   := CalculateGSTForClass( MyClient, txDate_Effective, dsAmount, dsGST_Class);
                    dsGST_Amount   := CalculateGSTForClass( MyClient, txDate_Effective, Local_Amount, dsGST_Class);
                    dsGST_Has_Been_Edited := true;
                 end
                 else begin
//                    CalculateGST( MyClient, txDate_Effective, dsAccount, dsAmount, dsGST_Class, dsGST_Amount);
                    CalculateGST( MyClient, txDate_Effective, dsAccount, Local_Amount, dsGST_Class, dsGST_Amount);
                    dsGST_Has_Been_Edited := false;
                 end;
                 dsHas_Been_Edited     := FALSE;
                 dsSF_Member_Account_ID:= -1;
                 dsSF_Fund_ID          := -1;
                 AppendDissection( pT, Dissection, MyClient.ClientAuditMgr );
              end;
        end;
        if fIsForex then pT.ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
        if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
          txGL_Narration   := pdName;
     end;
  end;  {with payee^}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistBeginEdit(Sender: TObject; RowNum, ColNum: Integer; var AllowIt: Boolean);
//occurs before ReadCellForEdit
//allows us to decide whether or not a cell is allowed to be edited
var
   FieldID : integer;
   isDissection : boolean;
   pT : pTransaction_Rec;
   pD : pDissection_Rec;
begin
   AllowIt := false;
   if not ValidDataRow(RowNum) then exit;

   if not tblHist.ColumnFmtList.ColIsEditable(ColNum) then
      exit;

   FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   pT := HistTranList.Transaction_At(RowNum-1);
   with pT^ do begin
      isDissection := (txFirst_Dissection <> nil);
   end;
   if isDissection and ( FieldId in [ ceAccount, ceGSTClass, ceGSTAmount, ceQuantity ]) then begin
      //these fields not available if the transaction is a dissection
      exit;
   end;

   if ( FieldID = cePayee) then begin
      //check if payee has been set in dissection lines, if so dont allow to set
      //at transaction level
      pD := pT^.txFirst_Dissection;
      while ( pd <> nil) do begin
         if pD^.dsPayee_Number <> 0 then exit;
         pD := pD^.dsNext;
      end;
   end;

   if ( FieldId = ceGSTAmount)
   and ( MyClient.clFields.clCountry = whAustralia)
   and ( MyClient.clFields.clBAS_Calculation_Method = bmSimplified) then begin
         //this field cannot be edited if we are using the simplified method and
         //the current gst class assigned has a zero percentage rate
         if ( GetGSTClassRate( MyClient, pT^.txDate_Effective, pT^.txGST_Class) = 0) then exit;
   end;   
   AllowIt := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
   data := nil;
   case Purpose of
      cdpForPaint:
         ReadCellForPaint(RowNum,ColNum,Data);
      cdpForEdit: begin
           btnCancel.Cancel := false;   //turn off esc = cancel function once we start editing
           ReadCellForEdit(RowNum,ColNum,Data);
         end;
      cdpForSave :
         ReadCellForSave(RowNum,ColNum,Data);
   end;
end;
procedure TdlgHistorical.tblHistKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_ESCAPE)
   and (tblHist.ColumnFmtList.ColumnDefn_At(tblHist.ActiveCol)^.cdFieldID
   in [ceJob]) then
     Undo := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
var
   pT: pTransaction_Rec;
   FieldID : integer;
   pA : pAccount_Rec;
   APayee : TPayee;
begin
  if not ValidDataRow(RowNum) then exit;

  with HistTranList do begin
      pT   := Transaction_At(RowNum-1);
      FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
        ceEffDate:
           data := @pT^.txDate_Effective;

        ceReference:
           data := @pT^.txReference;

        ceAnalysis:
           data := @pT^.txAnalysis;

        ceAccount: begin
           if pT^.txFirst_Dissection = nil then
              tmpPaintShortStr := Trim(pT^.txAccount)
           else
              tmpPaintShortStr := DISSECT_DESC;
           data := @(tmpPaintShortStr);
        end;

        ceDescription,
        ceAltChartCode:
           begin
              pA := MyClient.clChart.FindCode( pT^.txAccount );
              if Assigned( pA ) then
                 if FieldID = ceDescription then
                    tmpPaintShortStr := pA.chAccount_Description
                 else
                    tmpPaintShortStr := pA.chAlternative_Code
              else
                 tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;

{        ceForexAmount :
          begin
             tmpPaintString := BankAccount.MoneyStrBrackets( pT.txAmount );
             data := PChar( tmpPaintString );
           end;}

        ceForexRate :
          Begin
            tmpPaintDouble := pT^.txForex_Conversion_Rate;
            data := @tmpPaintDouble;
          End;

        ceLocalAmount :
          begin
            tmpPaintString := MyClient.MoneyStrBrackets( pT.Local_Amount );
            Data := PChar( tmpPaintString );
           end;

        ceAmount: begin
//           tmpPaintDouble := Money2Double( pT^.Local_Amount );
           tmpPaintDouble := Money2Double( pT^.txAmount );
           data := @tmpPaintDouble;
        end;

        ceNarration: begin
           tmpPaintString := pT^.txGL_Narration;
           data := PChar( tmpPaintString);
        end;

        cePayee:
          if (pT^.txPayee_Number <> 0)
          or (pT^.txFirst_Dissection <> nil) then
             data := @(pT^.txPayee_Number);

        ceJob: begin
             tmpPaintShortStr := pT^.txJob_Code;
             data := @tmpPaintShortStr;
           end;

        ceJobName: begin
            if pT^.txJob_Code > '' then
               tmpPaintShortStr := MyClient.clJobs.JobName(pT^.txJob_Code)
            else
               tmpPaintShortStr := '';
            data := @tmpPaintShortStr;
           end;
           
        cePayeeName:
           begin
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

        ceGSTClass: begin
           if pT^.txFirst_Dissection = nil then
             tmpPaintShortStr := GetGstClassCode( MyClient, pT^.txGST_Class)
           else
             tmpPaintShortStr := '';
           data := @(tmpPaintShortStr);
        end;

        ceGSTAmount: begin
           if pT^.txFirst_Dissection = nil then begin
              tmpPaintDouble := Money2Double(pT^.txGst_Amount);
              data := @tmpPaintDouble;
           end
           else
              tmpPaintDouble := GSTCalc32.GetGSTTotalForDissection( pT) / 100;
              data := @tmpPaintDouble;
        end;

        ceTaxInvoice:
           data := @pT^.txTax_Invoice_Available;

        ceQuantity:
           if pT^.txFirst_Dissection = nil then
           begin
              tmpPaintDouble := pT^.txQuantity / 10000;
              data := @tmpPaintDouble;
           end
           else
              data := nil;

        ceEntryType : begin
           //store the cmb index in the entry type, until actually import
           if pT^.txType = 255 then
              tmpPaintInteger := -1
           else
              tmpPaintInteger := pT^.txType;
           data := @tmpPaintInteger;
        end;

        ceBalance: begin
           begin
             if pT^.txTemp_Balance = UNKNOWN then
                tmpPaintString := ''
             else begin
                if assigned(BankAccount) then
                   tmpPaintString := BankAccount.BalanceStr( pT^.txTemp_Balance )
                else
                   tmpPaintString := '';   
             end;

             data := PChar(tmpPaintString);
           end;
        end;
      else
         data := nil;
      end;{case}
  end  ; { with do}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgHistorical.ReadCellForEdit(RowNum, ColNum: Integer; var Data: Pointer);
//occurs after OnBeginEdit
var
   pT : pTransaction_Rec;
   FieldID : integer;
begin
   Data := nil;
   if not ValidDataRow(RowNum) then exit;

   with HistTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         ceEffDate: begin
            tmpInteger := pT^.txDate_Effective;
            data := @tmpInteger;
         end;

         ceReference: begin
            tmpShortStr := pT^.txReference;
            data := @tmpShortStr;
         end;

         ceAnalysis: begin
            tmpShortStr := pT^.txAnalysis;
            data := @tmpShortStr;
         end;

         ceAccount: begin
            tmpShortStr := Trim(pT.txAccount);
            data := @tmpShortStr;
         end;

         ceNarration: begin
            EmptyTmpBuffer;
            StrCopy( PChar(tmpBuffer), PChar( pt^.txGL_Narration));
            data := tmpBuffer;
         end;

         cePayee : begin
            tmppayee := pT^.txPayee_Number;
            data := @tmppayee;
         end;

         ceJob : begin
            tmpShortStr := Trim(pT.txJob_Code);
            data := @tmpShortStr;
         end;

         ceGSTClass : begin
            tmpShortStr := GetGSTClassCode( MyClient, pT^.txGST_Class );
            data := @tmpShortStr;
         end;

         ceForexRate : begin
            tmpDouble := pT.txForex_Conversion_Rate;
            Data := @tmpDouble;
         end;

{         ceForexAmount : begin
//            tmpDouble := Money2Double( pT.txForeign_Currency_Amount );
            tmpDouble := Money2Double( pT.txAmount );
            Data := @tmpDouble;
         end; }

{         ceLocalAmount : begin
//            tmpDouble := Money2Double( pT.txAmount );
            tmpDouble := Money2Double( pT.Local_Amount );
            Data := @tmpDouble;
         end; }

         ceGSTAmount : begin
            tmpDouble := Money2Double(pT.txGst_Amount);
            data := @tmpDouble;
         end;

         ceTaxInvoice : begin
            tmpBool  := pT^.txTax_Invoice_Available;
            data := @tmpBool;
         end;

         ceQuantity: begin
            tmpDouble := ( pT.txQuantity / 10000 );
            data := @tmpDouble;
            //set auto press to determine if minus key press should be sent when start editing
            AutoPressMinus := ( pT^.txAmount < 0) and ( pT^.txQuantity = 0);
         end;

         ceAmount : begin
            tmpDouble := Money2Double( pT^.txAmount );
            data := @tmpDouble;
         end;

         ceEntryType : begin
            //store the cmb index in the entry type, until actually import
            if pT^.txType = 255 then
               tmpInteger := -1
            else
               tmpInteger := pT^.txType;
            data := @tmpInteger;
         end;
      end; //case
   end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
//Occurs after OnEndEdit
var
   FieldID : integer;
begin
   Data := nil;
   if not ValidDataRow(RowNum) then exit;

   FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

   case FieldID of
      ceAccount, ceReference,
      ceAnalysis, ceJob, ceGSTClass :
      begin
        data := @tmpShortStr;
      end;

      ceGSTAmount, ceQuantity, ceAmount, ceForexRate, ceLocalAmount :
      begin
        data := @tmpDouble;
      end;

      ceEffDate, ceEntryType, cePayee :
      begin
        data := @tmpInteger;
      end;

      ceTaxInvoice :
      begin
        data := @tmpBool;
      end;

      ceNarration :
      begin
        data := tmpBuffer;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistEndEdit(Sender: TObject;  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer; var AllowIt: Boolean);
//Occurs before ReadCellForSave
var
   pT : pTransaction_Rec;
   FieldID : integer;

   Account  : string;
   GSTClass : byte;
   GSTAmt   : double;
   Payee    : integer;
   IsActive : boolean;
   dtEffectiveDate : TDateTime;
   Day, Month, Year : Integer;
   LastDay : TDate;
//   ChequeNo : longint;
//   S        : string;
//   l        : integer;
begin
   //verify values
   if not ValidDataRow(RowNum) then exit;

   IsActive := True;

   with HistTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         ceAccount: begin
            Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
            if (Account <> '') then begin
               if not MyClient.clChart.CanCodeTo( Account, IsActive ) then begin
                  ErrorSound;
{$IFDEF SmartBooks}
                  AllowIt := false;  //smartbooks requires a valid account code
{$ENDIF}
               end;
            end;
         end;

         ceEffDate :
         begin
           dtEffectiveDate := TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsDateTime;
           if (((not IsManual) or Provisional) and (not CheckEffectiveDate(dtEffectiveDate))) then
           begin
             ErrorSound;
             StDateToDMY(GetLastDayOfMonth(CurrentDate), Day, Month, Year);
             LastDay :=   EncodeDate(Year, Month, Day);
             HelpfulWarningMsg(Format(rsMsgWrongAffectiveDate,
                    [FormatDateTime('dd/mm/yy',LastDay)]), 0);
             TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).ClearContents;
             TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).SetFocus;
             AllowIt := False;
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
            if ( pT^.txGST_Class =0 ) and (GSTAmt <>0) then begin
               ErrorSound;
               TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat := 0;
               AllowIt := false;
            end
            else begin
//               if (( pT^.txAmount < 0 ) and ( Double2Money(GSTAmt) < pT^.txAmount )) or
//                  (( pT^.txAmount > 0 ) and ( Double2Money(GSTAmt) > pT^.txAmount )) then begin
               if (( pT^.Local_Amount < 0 ) and ( Double2Money(GSTAmt) < pT^.Local_Amount )) or
                  (( pT^.Local_Amount > 0 ) and ( Double2Money(GSTAmt) > pT^.Local_Amount )) then begin
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

         ceJob : if Undo then begin
             Undo := False;
             TEdit( TOvcTCString(Cell).CellEditor).Text := pT.txJob_Code;
           end else begin
             Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
             if (Account <> '') then begin
                if not assigned( MyClient.clJobs.FindCode(Account)) then begin
                   ErrorSound;
                   AllowIt := false;  //smartbooks requires a valid account code
                end;
             end;
           end;

      end; //case
   end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change

   function GSTDifferentToDefault( pT : pTransaction_Rec) : boolean;
   //calculate default gst amount and class and see if current values are
   //different
   var
      DefaultGSTClass :  byte;
      DefaultGSTAmt   : money;
   begin
      with pT^ do begin
//         CalculateGST( myClient, txDate_Effective, txAccount, txAmount,
//                       DefaultGSTClass, DefaultGSTAmt);
         CalculateGST( myClient, txDate_Effective, txAccount, Local_Amount,
                       DefaultGSTClass, DefaultGSTAmt);

         result := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
      end;
   end;

   procedure MoneyChanged;
   begin

   end;

var
   pT: pTransaction_Rec;
   FieldID,
   OD: Integer;
   OER: Double;
   B: Byte;
   M,OM: Money;
   S: string;
   pD: pDissection_Rec;
begin
   //write values back to worktranlist
   if not ValidDataRow(RowNum) then exit;

   with HistTranList do begin
      pT := Transaction_At(RowNum-1);
      FieldID := tblHist.ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

      case FieldID of
         //the following fields affect other fields
         ceAccount: begin
            if ( pT^.txAccount <> tmpShortStr ) then begin
               // Edited flag not set if when coded from Blank
               pT^.txAccount         :=tmpShortStr;
               AccountEdited(pT);
            end;
         end;

         ceGSTClass : begin
            B := GetGSTClassNo( MyClient, Trim( tmpShortStr));
            if ( pT^.txGST_Class <> B ) then begin
               pT^.txGST_Class    := B;
               GSTClassEdited(pT);
               pT^.txGST_Has_Been_Edited := GSTDifferentToDefault( pT);
            end;
         end;

         ceAmount : begin
            M  := Double2Money(tmpDouble);
            OM := pT^.txAmount;
            if ( pT^.txAmount  <>  M ) then begin
               pT^.txAmount := M;
               //if the amount is changed then and the transaction is a dissection
               //then the dissection must be redone so that it balances to the  new
               //amount
               if pT^.txFirst_Dissection <> nil then
                  if (not CopyingLine) and (not DissectEntry( pT, false, false, BankAccount )) then begin
                     pT^.txAmount := OM;
                     tblHist.InvalidateTable;
                     HelpfulInfoMsg('The transaction amount has been changed back.',0);
                     exit;
                  end;
               AmountEdited(pT);
               //the entry type may have changed which will affect the cheq no, call update
               UpdateChequeNo( pT);
            end;
         end;


         cePayee : begin
            // can't popup a dialog in here - case 7255
         end;

         ceJob : begin
            pT^.txJob_Code := tmpShortStr;
            if pT^.txJob_Code > '' then begin
               // Make sure dissections are cleared
               Pd := pT.txFirst_Dissection;
               while assigned(PD) do begin
                  pd.dsJob_Code := '';
                  pd := pd.dsNext;
               end;
            end;
         end;

         ceEffDate : if tmpInteger <>  pT^.txDate_Effective then begin

            if not ValidDate(tmpInteger) then begin
               tmpDate := TmpInteger;
               TimerRow := RowNum;
               tmrPayee.Tag := ceEffDate;
               tmrPayee.Enabled := True;
               Exit;
            end;

            OD := pT^.txDate_Effective;
            pT^.txDate_Effective := tmpInteger;
            if fIsForex then begin
               OER := pT^.txForex_Conversion_Rate;
               pT^.txForex_Conversion_Rate := BankAccount.Default_Forex_Conversion_Rate(tmpInteger);
               if OER <> pT^.txForex_Conversion_Rate then begin
                  OM :=   pT.txAmount;
//                  If pT.txForex_Conversion_Rate <> 0.0 then
//                     pT.txAmount := Round( pT.txForeign_Currency_Amount / pT.txForex_Conversion_Rate )
//                  else
                     pT.txAmount := 0;
                  if pT.txAmount <> OM then begin
                     if pT^.txFirst_Dissection <> nil then begin
                        if (not CopyingLine)
                        and (not DissectEntry(pT, false, false, BankAccount)) then begin
                           pT.txAmount := OM;
                           pT^.txForex_Conversion_Rate := OER;
                           pT^.txDate_Effective := OD;
                           tblHist.InvalidateTable;
                           HelpfulInfoMsg('The tranaction date has been changed back.',0);
                           exit;
                        end;
                     end;
                  end;
                  AmountEdited(pT);
               end;
            end;
            //
            CalculateBalanceColumn;
         end;

          //the following fields do not affect any other fields
         ceGSTAmount : begin
            M := Double2Money(tmpDouble);
            if ( pT^.txGST_Amount <> M ) then begin
               pT^.txGST_Amount   := M;
            end;
            pT^.txGST_Has_Been_Edited := GSTDifferentToDefault( pT);
         end;

         ceReference : begin
            pT^.txReference    := tmpShortStr;
            UpdateChequeNo( pT);
         end;

         ceAnalysis : begin
            pT^.txAnalysis    := tmpShortStr;
         end;

         ceNarration : begin
           S := PChar( tmpBuffer);  //will have been filled by ReadCellForSave
           if (pT^.txGL_Narration <> S) then begin
              pT^.txGL_Narration    := S;
           end;
         end;

         ceTaxInvoice : begin
           pT^.txTax_Invoice_Available := tmpBool;
         end;

         ceQuantity : begin
            pT^.txQuantity    := (tmpDouble * 10000);
         end;

         ceEntryType : begin
            //store the cmb index until actually import
            //cant store -1 because txType is a byte
            if tmpInteger = -1 then
               pT^.txType := 255
            else
               pT^.txType := tmpInteger;
            //call routine to update the txCheque_Number field

            EntryTypeEdited( pT);
         end;
      end;
      pT^.txHas_Been_Edited := true;
   end;

   with tblHist do begin
      AllowRedraw := false;
      InvalidateRow(RowNum);
      AllowRedraw := true;
   end;
   if FieldId = cePayee then begin
      tmpPayee := TmpInteger;
      TimerRow := RowNum;
      tmrPayee.Tag := cePayee;
      tmrPayee.Enabled := True;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoAccountLookup;
{
Assists the user in coding by allowing selection of Account Codes from
Chart Lookup

The function PickAccount(Code) accepts a Code or partial Code or blank
and attempts to position the Chart on that Code.
It returns True if the user selects an Account Code and puts the Code
in the Var Parameter, if no Code is chosen it returns False.

This method can be called from
   F2 key or Ctrl-L if the user is positioned on the Account column.

We do not know the position or the Edit State of the Active Cell when
this method is called.  We therefore end any existing edit and move to
the Account column.
}
var
  Code : string;
  InEditOnEntry : boolean;
  HasChartBeenRefreshed : boolean;
begin
   with tblHist do begin
      if not ( ColumnFmtList.FieldIsEditable( ceAccount )) then exit;

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

      if PickAccount(Code, HasChartBeenRefreshed) then
      begin
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
procedure TdlgHistorical.DoPayeeLookup;
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
}
var
  InEditOnEntry : boolean;
  intCode : integer;
  Msg : TWMKey;
  pT : pTransaction_Rec;
  OldPayeeNo : integer;  
begin
  if not ValidDataRow( tblHist.ActiveRow ) then
    exit;

   with tblHist do begin
      //check to see that payee col is editable
      if not ColumnFmtList.FieldIsEditable( cePayee) then
      begin
        with tblHist do begin
           //End edit of Account if any
           if not StopEditingState(True) then Exit;
           pT   := HistTranList.Transaction_At(ActiveRow-1);
           //user can edit payee so proceed
           IntCode := pT^.txPayee_Number;
           OldPayeeNo := pT^.txPayee_Number;
           if PickPayee(IntCode) then begin
              //if get here then have a valid payee from the picklist, so edit
              //the fields in the transaction
              pT^.txPayee_Number := IntCode;
              if not PayeeEdited(pT) then
                 pT^.txPayee_Number := OldPayeeNo;
              //force repaint of row
              AllowRedraw := false;
              try
                 InvalidateRow(ActiveRow);
              finally
                 AllowRedraw := true;
              end;
              Msg.CharCode := VK_RIGHT;
              celPayee.SendKeyToTable(Msg);
           end;
        end;
      end
      else
      begin
       //can edit payee so use cell editor
       if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = cePayee ) then begin
         if not StopEditingState(True) then
           Exit;
         if ( ColumnFmtList.GetColNumOfField(cePayee) = -1 ) then
           Exit;
         ActiveCol := ColumnFmtList.GetColNumOfField(cePayee);
       end;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if alreading in edit state
       end;

       IntCode := TOvcNumericField(celPayee.CellEditor).AsInteger;

       if PickPayee(IntCode) then begin
           //if get here then have a code which can be posted to from picklist
           TOvcNumericField(celPayee.CellEditor).AsInteger := IntCode;
           Msg.CharCode := VK_RIGHT;
           celPayee.SendKeyToTable(Msg);
       end
       else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoGSTLookup;
var
  GSTCode       : string;
  InEditOnEntry : boolean;
  Msg           : TWMKey;
  pT : pTransaction_Rec;
begin
   with tblHist do begin
      if not ColumnFmtList.FieldIsEditable( ceGSTClass) then
      begin
        with tblHist do begin
           //End edit of Account if any
           if not StopEditingState(True) then Exit;
           pT   := HistTranList.Transaction_At(ActiveRow-1);
           GSTCode := GSTCALC32.GetGSTClassCode( MyClient, pT^.txGST_Class);
           if PickGSTClass( GSTCode, True) then begin
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
              //force repaint of row
              AllowRedraw := false;
              try
                 InvalidateRow(ActiveRow);
              finally
                 AllowRedraw := true;
              end;
              Msg.CharCode := VK_RIGHT;
              celPayee.SendKeyToTable(Msg);
           end;
        end;
      end
      else
      begin
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
        if PickGSTClass(GSTCode, True) then begin
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
   end;
end;

procedure TdlgHistorical.DoJobLookup;
var
   pT : pTransaction_Rec;
   InEditOnEntry    : boolean;
   JobCode          : String;
   Msg              : TWMKey;
   JobNotEditable : Boolean;

begin
   //Check to see if a payee col exists
   JobNotEditable :=  not tblHist.ColumnFmtList.FieldIsEditable( ceJob);
   if not (JobNotEditable) then begin
      with tblHist do begin
         //test if we are in the correct col, if not end any edit and move to
         //correct col
         if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceJob ) then begin
            if not StopEditingState(True) then Exit;
            ActiveCol := ColumnFmtList.GetColNumOfField(ceJob);
         end;
         //In correct column and is visible so begin the edit
         InEditOnEntry := InEditingState;
         if not InEditOnEntry then begin
            if not StartEditingState then Exit;   //returns true if alreading in edit state
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
   end
   else begin  //Edit Account Col Only, or PayeeCol has been hidden
      with tblHist do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;

         pT   := HistTranList.Transaction_At(ActiveRow-1);
         JobCode := pt.txJob_Code;
         if PickJob(JobCode) then begin
            //if get here then have a valid payee from the picklist, so edit
            //the fields in the transaction
            pt.txJob_Code := JobCode;
            InvalidateRow(ActiveRow);  //forces repaint of row
            Msg.CharCode := VK_RIGHT;
            celJob.SendKeyToTable(Msg);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoDissection;
var
   pT : pTransaction_Rec;
begin
   if not ValidDataRow(tblHist.ActiveRow) then exit;
   if not ( tblHist.ColumnFmtList.FieldIsEditable( ceAccount )) then exit;
   with tblHist do begin
      pT   := HistTranList.Transaction_At(ActiveRow-1);
      if DissectEntry( pT, false, false, BankAccount ) then
         Refresh;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  msg : TWMKey;
begin
   //check for lookup key
   if ( Key = VK_F2 ) then begin
      Msg.CharCode := VK_F2;
      celAccount.SendKeyToTable(Msg);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celAccountKeyPress(Sender: TObject; var Key: Char);
var
   Msg : TWMKey;
begin
   //ignore * press if editing
   if key = '*' then key := #0;

   //check if the minus key should bring up the picklist
   if key = '-' then begin
       if (MyClient.clFields.clUse_Minus_As_Lookup_Key) then begin
         key := #0;
         Msg.CharCode := VK_F2;
         // #1782 - take it out of edit if we are using '-' as a lookup key
         if tblHist.InEditingState and
            ((celAccount.CellEditor <> nil) and (TEdit(celAccount.CellEditor).SelStart = 0)) then
          tblHist.StopEditingState(True);
         celAccount.SendKeyToTable(Msg);
       end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celGstAmtKeyPress(Sender: TObject; var Key: Char);
var
   Percentage    : Double;
   NewAmount     : Double;
   pT            : pTransaction_Rec;
   Msg           : TWMKey;
   InclusiveAmt  : Double;
   ExchangeRate  : Double;
begin
  if not ValidDataRow( tblHist.ActiveRow ) then exit;

  {treat value as percentage}
  if key in ['%','/'] then begin
     //stop any further processing of key
     Key := #0;
     Percentage := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     //check that the percentage value make sense
     if ( Percentage < 0.0 ) or ( Percentage > 100.0) then exit;
     pT   := HistTranList.Transaction_At(tblHist.ActiveRow-1);
     //find the new GST Amount
     InclusiveAmt := Money2Double( pT^.txAmount);
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
     NewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));

     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblHist.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end else if key = '£' then begin
     //stop any further processing of key
     Key := #0;
     NewAmount := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     if fIsForex then begin
       //Convert amount to base currency
       pT := HistTranList.Transaction_At(tblHist.ActiveRow-1);
       ExchangeRate := pT.Default_Forex_Rate;
       if ExchangeRate > 0 then
         NewAmount := NewAmount / ExchangeRate
       else
         NewAmount := 0;
     end;
     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblHist.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
  //use a hidden TOvcPictureField to get the double value from the data pointer
  //The normal tcPaint method for a TOvcTCPictureField uses an internal
  //TOvcBaseEntryField(FEditDisplay) to get the display string from.
  //Have used a PictureField from the form so dont have to create and destroy
  //each time this is called.

  //Reason for this is so that can display the deposits as indented amounts
  //just like the coding screen.
const
  margin = 4;
var
  NewCellRect   : TRect;
  S             : PChar;
begin
  if data = nil then exit;
  DoneIt := True;
  //use a hidden TOvcPictureField to get the double value from the data pointer
  pfHiddenAmount.SetValue( Data^ );
  S := PChar(FormatFloat('#,##0.00;(#,##0.00)',pfHiddenAmount.AsFloat));
  NewCellRect := CellRect;  //need to have a var to change, cellrect is a const
  with TableCanvas do begin
     Brush.Color := CellAttr.caColor;
     FillRect(NewCellRect);
     InflateRect(NewCellRect, -Margin div 2, -Margin div 2);
     Font.Color := cellAttr.caFontColor;
     with NewCellRect do begin
        if pfHiddenAmount.AsFloat < 0 then
           Right := round(Left+(Right-Left)*0.75)
        else
           Right := round(Left+(Right-Left)*0.95);
     end;
  end;
  DrawText( TableCanvas.Handle,
            S, StrLen(S),
            NewCellRect,
            DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.FindETInCombo(aEntryType: byte): byte;
var
   i : integer;
begin
   result := 255;  //default to this so that appear blank, when displayed
   with celEntryType do begin
      for i := 0 to Pred(Items.Count) do
        if Byte(Items.Objects[i]) = aEntryType then begin
           result := i;
           exit;
        end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DeleteCurrentLine(InsertIfEmpty : boolean = true);
begin
   if not ValidDataRow(tblHist.ActiveRow) then exit;
   if not tblHist.StopEditingState(true) then exit;

   tblHist.AllowRedraw := false;
   try
      with HistTranList do begin
         HistTranList.DelFreeItem(Transaction_At(tblHist.ActiveRow-1));
      end;
      //If no lines are left then reinsert (unless we don't want to, importing data for example)
      if (HistTranList.ItemCount = 0) and InsertIfEmpty then
         InsertNewRow( InsertAtEnd )
      else begin
         tblHist.RowLimit := Max( HistTranList.ItemCount + 1, 2);
         SetTableAccess;
      end;
   finally
      tblHist.AllowRedraw := true;
   end;
   Refresh;
   CalculateBalanceColumn;
   CalcClosingBal;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
//
//this routine is also used to pick up a delete on a dissection
var
  pT : pTransaction_Rec;
  FieldID : integer;
begin
   with tblHist do begin
      if not ValidDataRow(ActiveRow) then exit;

      pT   := HistTranList.Transaction_At(ActiveRow-1);
      FieldID := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
      //see if this transaction is a dissected entry
      if ( FieldID = ceAccount) and ( pT^.txFirst_Dissection <> nil) then
      begin
        DoDeleteDissection( pT);
        Exit;
      end;

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
         if cdTableCell is TOvcTCComboBox then begin
            TComboBox( cdTableCell.CellEditor).ItemIndex := -1;
         end;
      end;
      StopEditingState( True );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.CalcClosingBalAt(D: Integer; Seq: Integer = -1): Money;
//calculate the closing balance given the opening balance and the amounts of each
//transaction
//overdrawn is +ve,    infund is -ve
var
   ClosingBal : Money;
   i : integer;
   Txn: pTransaction_Rec;
begin
   ClosingBal := Double2Money(abs(nfOpeningBal.AsFloat));
   if cmbSign.ItemIndex = BAL_INFUNDS then
      ClosingBal := -ClosingBal;

   for i := 0 to Pred(HistTranList.ItemCount) do begin
      Txn := HistTranList.Transaction_At(i);
      if (Txn^.txDate_Effective < D) or (D = 0) or // earlier or
         // if same date then based on seq no
         ((Txn^.txDate_Effective = D) and ((Seq = -1) or (Txn^.txSequence_No <= Seq))) then
            ClosingBal := ClosingBal + Txn^.Statement_Amount;
   end;
   Result := ClosingBal;
end;

function TdlgHistorical.CalcClosingBalSortOrder(Row: Integer): Money;
//calculate the closing balance given the opening balance and the amounts of each
//transaction
//overdrawn is +ve,    infund is -ve
var
   ClosingBal : Money;
   i : integer;
begin
   ClosingBal := Double2Money(abs(nfOpeningBal.AsFloat));
   if cmbSign.ItemIndex = BAL_INFUNDS then
      ClosingBal := -ClosingBal;

   with HistTranList do begin
      for i := 0 to Row do with Transaction_At( i )^ do begin
         ClosingBal := ClosingBal + Statement_Amount;
      end;
   end;
   Result := ClosingBal;
end;

procedure TdlgHistorical.CalcClosingBal;
Var
  Bal : Money;
begin
  Bal := CalcClosingBalAt( MaxHistTranDate );
  stClosingBal.Caption := BankAccount.BalanceStr( Bal );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.nfOpeningBalKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (key = vk_subtract) or (key = 189) then key := 0;  {ignore minus key}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.nfOpeningBalChange(Sender: TObject);
begin
   CalculateBalanceColumn;
   CalcClosingBal;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.cmbSignChange(Sender: TObject);
begin
   CalculateBalanceColumn;
   CalcClosingBal;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celDateEnter(Sender: TObject);
begin
   cntController.EntryOptions := cntController.EntryOptions - [efoAutoSelect];
end;
procedure TdlgHistorical.celDateError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: string);
var
  Msg : string;
begin
  ValidDate(-1,@Msg);
  HelpfulWarningMsg(Msg,0);
  ErrorCode := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celDateExit(Sender: TObject);
begin
  cntController.EntryOptions := cntController.EntryOptions + [efoAutoSelect];
end;

procedure TdlgHistorical.celForexAmountOwnerDraw(Sender: TObject;
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
  DoneIt := True;
  R := CellRect;
  C := TableCanvas;
  S := StrPas( PChar( Data ) );
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect(R, -Margin div 2, -Margin div 2);

  if ( pos( '(', S ) > 0 ) or ( pos( '-', S ) > 0 ) then
    R.Right := round(R.Left+(R.Right-R.Left)*0.95)
  else
    R.Right := round(R.Left+(R.Right-R.Left)*0.75);

  DrawText(C.Handle, Data, StrLen(Data), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.CopyDissection(pTo, pFrom: pTransaction_Rec);
var
  pD, pDC: pDissection_Rec;
begin
  pD := pFrom.txFirst_Dissection;
  while Assigned(pD) do
  begin
    pDC := Create_New_Dissection;
    pDC.dsRecord_Type := pD.dsRecord_Type;
    pDC.dsSequence_No := pD.dsSequence_No;
    pDC.dsAccount := pD.dsAccount;
    pDC.dsAmount := pD.dsAmount;
    pDC.dsGST_Class := pD.dsGST_Class;
    pDC.dsGST_Amount := pD.dsGST_Amount;
    pDC.dsQuantity := pD.dsQuantity;
    pDC.dsPayee_Number := pD.dsPayee_Number;
    pDC.dsNotes := pD.dsNotes;
    pDC.dsGL_Narration := pD.dsGL_Narration;
    trxlist32.AppendDissection(pTo, pDC );
    pD := pD.dsNext;
  end;
  pTo.txAmount := pFrom.txAmount;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoDitto(CopyLine: Boolean = False);
Var
   pT             : pTransaction_Rec;
   pPrev          : pTransaction_Rec;
   Msg            : TWMKey;
   FieldId        : integer;
   DittoOK        : boolean;
Begin
   with tblHist do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if alreading in edit state

      pT := HistTranList.Transaction_At(ActiveRow-1);
      if pT^.txLocked then exit;
      pPrev := HistTranList.Transaction_At(ActiveRow-2);

      DittoOK := false;

      FieldID := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
      //verify field ok to edit
      case FieldID of
         ceAccount: begin
            if (Trim(TEdit(celAccount.CellEditor).Text) = '') then
            begin
              if (pPrev^.txAccount <> DISSECT_DESC) then
              begin
                TEdit(celAccount.CellEditor).Text := Trim(pPrev^.txAccount);
                DittoOK := true;
              end
              else
              begin
                CopyDissection(pT, pPrev);
                TEdit(celAccount.CellEditor).Text := Trim(pPrev^.txAccount);
                TOvcNumericField(celAmount.CellEditor).AsFloat := Money2Double( pPrev^.txAmount );
                AmountEdited(pT);                
                DittoOK := true;
              end;
            end;
         end;

         ceNarration: begin
            if (Trim(TEdit(celNarration.CellEditor).Text) = '') then begin
               TEdit(celNarration.CellEditor).Text := Trim(pPrev^.txGL_Narration);
               DittoOK := true;
            end;
         end;

         ceReference: begin
            if (Trim(TEdit(celRef.CellEditor).Text) = '') then begin
               TEdit(celRef.CellEditor).Text := Trim(pPrev^.txReference);
               DittoOK := true;
            end;
         end;

         ceAnalysis: begin
            if (Trim(TEdit(celAnalysis.CellEditor).Text) = '') then begin
               TEdit(celAnalysis.CellEditor).Text := Trim(pPrev^.txAnalysis);
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

         ceAmount : begin
            if (TOvcNumericField(celAmount.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celAmount.CellEditor).AsFloat := Money2Double( pPrev^.txAmount );
               DittoOK := true;
            end;
         end;

{         ceForexAmount : begin
            if (TOvcNumericField(celForexAmount.CellEditor).AsFloat = 0) then begin
//               TOvcNumericField(celForexAmount.CellEditor).AsFloat := Money2Double( pPrev^.txForeign_Currency_Amount );
               TOvcNumericField(celForexAmount.CellEditor).AsFloat := Money2Double( pPrev^.txAmount );
               DittoOK := true;
            end;
         end; }

         ceEffDate : begin
            if (TOvcTCPictureFieldEdit(celDate.CellEditor).AsStDate <=0) then begin
               TOvcTCPictureFieldEdit(celDate.CellEditor).AsStDate := pPrev^.txDate_Effective;
               DittoOk := true;
            end;
         end;

         ceEntryType : begin
            if ((TComboBox( celEntryType.CellEditor).ItemIndex = -1) and (pPrev^.txType <> 255)) or CopyLine then begin
               TComboBox( celEntryType.CellEditor).ItemIndex := pPrev^.txType;
               DittoOk := true;
            end;
         end;
      end;
      if not CopyLine then
        if DittoOK then begin
           //if field was updated then save the edit and move right
           if not StopEditingState(True) then exit;
           Msg.CharCode := VK_RIGHT;
           celAccount.SendKeyToTable(Msg);
           CalculateBalanceColumn;
        end
        else begin
           //field not updated, abandon edit and don't move off current cell
           StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
        end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoDittoLine;
var
  i: Integer;
  pT: pTransaction_Rec;
  Row, Col: Integer;
const
  ThisMethodName = 'DoDittoLine';
Begin
  CopyingLine := True;
  try
    for i := 0 to Pred(tblHist.Columns.Count) do
    begin
      tblHist.ActiveCol := i;
      DoDitto(True);
      while tmrPayee.Enabled do
         Application.ProcessMessages;
    end;
  finally
    CalculateBalanceColumn;
    CopyingLine := False;
    pT := HistTranList.Transaction_At( tblHist.ActiveRow - 1 );
    if not ValidateChequeNumber(Row, Col, pT) then
      tblHist.ActiveCol := Col
    else if InsertNewRow( InsertAtEnd ) then
    begin
       tblHist.ActiveRow := tblHist.ActiveRow + 1;
       tblHist.ActiveCol := tblHist.ColumnFmtList.GetColNumOfField( ceEffDate );
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.InsertTranIntoBankAccount;
//take the unsorted list and insert the entries into the bank account
var
   i       : integer;
   pT      : pTransaction_Rec;
   S       : string;
   Count   : integer;
   UEList  : tUEList;
   UE      : pUE;
   kc: TCursor;
begin
   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
   Count := 0;
   //create a unpresented items list to check new transactions against
//   if fIsForex then
//     UEList := MakeForeignCurrencyUEList(BankAccount)
//   else
     UEList := MakeUEList(BankAccount);

   try
      i := 0;
      While (i <= Pred(HistTranList.ItemCount)) do begin
         //set any fields that are not set by the user then insert into trans list
         //update the txType value with a real type id rather than the cmb index
         //lookup the combo value and set the type to the value stored in the object
         pT := HistTranList.Transaction_At(i);
         if (pT^.txType < 255) then
            //txType has been set to valid item so get value from combo
            pT^.txType := Byte(celEntryType.Items.Objects[pT^.txType])
         else begin
            //txType has not been set so workout a value, would normally be set
            //by user or automatically when amount entered
            if pT^.txAmount < 0 then begin
               case MyClient.clFields.clCountry of
                  whNewZealand : pT.txType := etDepositNZ;
                  whAustralia  : pT.txType := etDepositOZ;
                  whUK         : pT.txType := etDepositUK;
               end;
            end
            else begin
               case MyClient.clFields.clCountry of
                  whNewZealand : pT.txType := etWithdrawlNZ;
                  whAustralia  : pT.txType := etWithdrawlOZ;
                  whUK         : pT.txType := etWithdrawlUK;
               end;
            end;
         end;
         //set the balance sheet date
         pT.txDate_Presented := pT.txDate_Effective;
         // set the statement details same as narration so mems work
         pT.txStatement_Details := pT.txGL_Narration;
         //update the has been edited field
         //set to true if validly coded, otherwise set to false
         pT.txHas_Been_Edited := (pT.txCoded_By <> cbNotcoded);

         //set source
         if Provisional then
            pT.txSource := orProvisional
         else if BankAccount.IsManual then
            pT.txSource  := orMDE
         else
            pT.txSource := orHistorical;

         //set cheque number
         with MyClient.clFields, pT^ do begin
            if ((txType = etChequeNZ) and (clCountry = whNewZealand)) or
               ((txType = etChequeOZ) and (clCountry = whAustralia)) or
               ((txType = etChequeUK) and (clCountry = whUK))then begin
                 S := Trim( txReference );
                 While Length( S ) > 6 do System.Delete( S, 1, 1 );
                 txCheque_number := Str2Long( S );
            end;
         end;
         //set the bank seq no for sorting
         pT^.txBank_Seq        := BankAccount.baFields.baNumber;
         // set superfund fields
         pT^.txSF_Member_Account_ID:= -1;
         pT^.txSF_Fund_ID          := -1;

         //transaction is now ready for inserting.  Test to see if in Unpresented List
         //try to match upi against new transaction, if no match found then
         //import into the bank accounts transaction list.
         with pT^ do begin
            UE := NIL;

//            if fIsForex then
//            Begin
//              If (Assigned(UEList) and ( txCheque_Number <> 0 ) and ( txForeign_Currency_Amount <> 0 )) then
//                 UE := UEList.FindUEByNumberAndAmount( txCheque_Number, txForeign_Currency_Amount );
//            End
//            else
            Begin
              If (Assigned(UEList) and ( txCheque_Number <> 0 ) and ( txAmount <> 0 )) then
                 UE := UEList.FindUEByNumberAndAmount( txCheque_Number, txAmount );
            end;
            //check that UPC hasnt been matched since UEList built
            if Assigned( UE) then begin
               if ( UE^.Presented <> 0) or
                  ( UE^.Issued > pT^.txDate_Presented) then UE := nil;
            end;
         end;

         If Assigned( UE ) then With UE^ do begin
            //an unpresented cheque has been found that matches
            //both the amount and the cheque number.
            //update UPC to show that has been matched
            ptr^.txUPI_State          := upMatchedUPC;
            ptr^.txDate_Presented     := pT^.txDate_Effective;
            UE^.Presented             := pT^.txDate_Effective;
            ptr^.txOriginal_Reference := pT^.txReference;
            ptr^.txOriginal_Source    := pT^.txSource;
            ptr^.txOriginal_Type      := pT^.txType;
            ptr^.txOriginal_Amount    := pT^.txAmount;
            ptr^.txOriginal_Forex_Conversion_Rate    := pT^.txForex_Conversion_Rate   ;
//            ptr^.txOriginal_Foreign_Currency_Amount  := pT^.txForeign_Currency_Amount ;
            ptr^.txOriginal_Cheque_Number := pT^.txCheque_Number;
            //pointer does not need to be inserted so remove from list
            HistTranList.DelFreeItem( pT);
         end
         else
         begin
            // update balance if this tx is after latest tx
            if IsManual {and (pT.txDate_Presented >= BankAccount.baTransaction_List.LastPresDate)} then
            begin
              if BankAccount.baFields.baCurrent_Balance = unknown then
                BankAccount.baFields.baCurrent_Balance := pT.txAmount
              else
                BankAccount.baFields.baCurrent_Balance := BankAccount.baFields.baCurrent_Balance + pT.txAmount;
            end;

            BankAccount.baTransaction_List.Insert_Transaction_Rec(pT);

            //Flag Audit for bank account
            MyClient.ClientAuditMgr.FlagAudit(arClientBankAccounts);

            Inc(i); //move onto next transaction is while loop
         end;
         Inc(Count);
      end; //while
   finally
     UEList.Free;
   end;
   //DON'T FREE !!!, transactions are now part of BankAccount, however must
   //delete from list otherwise will be free'd when HistTranList is destroyed
   HistTranList.DeleteAll;

   finally
     Screen.Cursor := kc;
   end;
   S := Format( 'Add %s Entries complete.'#13#13'Added %d new entries.',[AccountType, Count ]);
   LogMsg(lmInfo,UnitName, S);
   HelpfulInfoMsg(S, 0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.SetCaptionState( TBar : TRzToolbar; CaptionOn: boolean);
var
  pS : PChar;
  TextExt : TSize;
  i : Integer;
  BarWidth : integer;
begin
  BarWidth := 0;

  with TBar do begin
    Tbar.AutoSize := false;
    for i := 0 to Pred( ControlCount ) do
    begin
       if Controls[i] is TRzToolButton then
       begin
          with TRzToolButton( Controls[i] ) do
          begin
             UseToolbarButtonSize := false;

             if CaptionOn then
             begin
                //find the width of the text
                pS := PChar(Caption);
                GetTextExtentPoint32( TMyPanel(pnlToolbar).Canvas.Handle, pS, Length(pS), TextExt );
                if Assigned(DropDownMenu)then
                begin
                    Width := ToolBarButtonWithTextWidth +
                       ToolbarButtonDropArrowWidth + TextExt.CX;
                end
                else
                begin
                    Width := ToolBarButtonWithTextWidth + TextExt.CX;
                end;
             end
             else
             begin
               if Assigned(DropDownMenu)then
                 Width := ToolBarButtonGlyphOnlyWidth + ToolbarButtonDropArrowWidth
               else
                 Width := ToolBarButtonGlyphOnlyWidth;
             end;
             ShowCaption := CaptionOn;
          end;
       end;

       BarWidth := BarWidth + Controls[i].Width;
    end;
    Tbar.Width := BarWidth;
  end;
end;

procedure TdlgHistorical.SetProvisional(const Value: Boolean);
begin
  FProvisional := Value;
  HelpContext := BKH_Adding_provisional_data;
  if FProvisional then begin
      lblTransRange.Caption := 'You may enter transactions for this provisional account.';
      tbChart.Visible := false;
      tbPayee.Visible := false;
      tbJob.Visible := false;
      tbDissect.Visible := false;
      tbAddCheques.Visible := false;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tbAddChequesClick(Sender: TObject);
begin
   DoAddCheques;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tbRepeatClick(Sender: TObject);
begin
   DoDitto;
end;
procedure TdlgHistorical.tmrPayeeTimer(Sender: TObject);
var
  pT : pTransaction_Rec;
  OldPayeeNo: Integer;
  msg: string;
begin
   tmrPayee.Enabled := False;
   if TimerRow = 0 then
      exit;
   pT := HistTranList.Transaction_At(TimerRow-1);
   if not assigned(pt) then
      Exit;  // Not Much I Can do...

   case tmrPayee.Tag of
   cePayee : if ( pT^.txPayee_Number <> tmpInteger ) then begin
        //tblHist.ActiveCol := tblHist.ColumnFmtList.GetColNumOfField(cePayee);
        OldPayeeNo := pT^.txPayee_Number;
        pT^.txPayee_Number  := tmpPayee;
        if PayeeEdited(pT) then
        begin
          pT^.txHas_Been_Edited := true;
        end
        else
          //restore original value
          pT^.txPayee_Number := OldPayeeNo;
      end;
   ceEffDate : begin // Date has already failed;
          if not ValidDate(tmpDate,@msg) then
             HelpfulWarningMsg(msg,0);
      end;
   end;


   with tblHist do begin
      AllowRedraw := false;
      InvalidateRow(TimerRow);
      AllowRedraw := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.AccountType: string;
begin

   if Provisional then
     Result := 'Provisional'
   else if BankAccount.IsManual then
      Result := 'Manual'
   else
      Result := 'Historical'
end;

procedure TdlgHistorical.actChartExecute(Sender: TObject);
begin
   DoAccountLookup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.actPayeesExecute(Sender: TObject);
begin
   DoPayeeLookup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.actDissectExecute(Sender: TObject);
begin
   DoDissection;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.actConfigureExecute(Sender: TObject);
begin
   ConfigureColumns;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.DoAddCheques;
{
  Allows a range of cheques to be added at the same time.  Each transactions is given
  a default date and a cheq no.  Any cheque no's that exist in the bank accounts
  transaction list, or the current historical trans list, will be skipped.
}
   //----------------------------------------------------
   function MakeRef( c : integer ) : string;
   var
      s : string;
   begin
      s := IntTostr( c );
      //Pad the reference out to 6 char with leading zero's
      while length( s ) < 6 do s := '0'+ s;
      result := s;
   end;

var
   CheqNumberFrom,
   CheqNumberTo    : integer;
   DefDate         : integer;
   DefRate         : Extended;
   ChequeNo        : integer;
   i               : integer;
   pT              : pTransaction_Rec;
   sMsg            : string;
   sCheques        : string;
   NumCheques      : integer;
   HistCheques     : TChequesList;

begin
   //Stop Editing Mode first
   if not tblHist.StopEditingState(true) then exit;
   //Request a cheque range and default date from the user
   if not GetAddChequesRange( MaxHistTranDate,
                              CheqNumberFrom,
                              CheqNumberTo,
                              DefDate ) then exit;

   if fIsForex then
     DefRate := BankAccount.Default_Forex_Conversion_Rate( DefDate )
   else
     DefRate := 0;
   //valid result from the dlg, so start adding the cheques
   Numcheques  := 0;
   HistCheques := TChequesList.Create;
   try
      //Already have a list of the cheque no in the transaction list
      //Build a list of cheques in the current historical transactions list
      for i := 0 to Pred( HistTranList.ItemCount ) do begin
         pT := HistTranList.Transaction_At(i);
         if IsACheque( pT) and ( pT^.txCheque_Number >= CheqNumberFrom) and ( pT^.txCheque_Number <= CheqNumberTo)  then begin
            //Have found a cheque number which already exists in the historical transactions, add to list of no's to skip
            HistCheques.InsChequeRec( pT^.txCheque_Number);
         end;
      end;
      //loop thru adding cheques to historical transactions, skip if currently in list, or in bank accounts transactions
      tblHist.AllowRedraw := false;
      try
         for ChequeNo := CheqNumberFrom to CheqNumberTo do begin
            if not ( ExistingCheques.ChequeIsThere( ChequeNo) or HistCheques.ChequeIsThere( ChequeNo)) then begin
               pT := Create_New_Transaction;
               pT.txBank_Account := TObject( BankAccount );
               pT.txClient := TObject( MyClient );

               HistTranList.Insert( pT );
               pT^.txDate_Effective := DefDate;
               if fIsForex then pT.txForex_Conversion_Rate := DefRate;
               pT^.txCheque_Number  := ChequeNo;
               //Store cmb index in the txType field, rather than the actual txType,
               //see note in the header of this unit
               case MyClient.clFields.clCountry of
                  whNewZealand : pT^.txType := FindETInCombo(etChequeNZ);
                  whAustralia  : pT^.txType := FindETInCombo(etChequeOZ);
                  whUK         : pT^.txType := FindETInCombo(etChequeUK);
               end;
               pT^.txReference := MakeRef( ChequeNo );
               //set has been edited so that is not automatically deleted when cursor moves off line
               pT^.txHas_Been_Edited := true;
               Inc( NumCheques );
            end
            else
               sCheques := sCheques + MakeRef( ChequeNo ) + '  ';
         end;
         //update table
         tblHist.RowLimit := Max( HistTranList.ItemCount + 1, 2 );
         SetTableAccess;
      finally
         tblHist.AllowRedraw := true;
      end;
   finally
      HistCheques.Free;
   end;
   //If cheques were added then
   //   Check to see if current line ( active row ) has been edited, if not delete it
   if ValidDataRow( tblHist.ActiveRow ) then begin
      pT := HistTranList.Transaction_At( tblHist.ActiveRow - 1 );
      if not pT^.txHas_Been_Edited then
         DeleteCurrentLine;
   end;
   //   move active row to the first new cheque
   if NumCheques > 0 then begin
      tblHist.ActiveRow := tblHist.RowLimit - NumCheques;
   end;
   //Now report any cheques that we skipped because they were found in the transactions
   if sCheques <> '' then begin
      sMsg :=  'The following Cheques were not added because their cheque numbers were found '+
               'in the existing Transactions for this Bank Account : '+#13+#13;
      sMsg := sMsg + sCheques;
      HelpfulInfoMsg( sMsg, 0);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniSortByDateClick(Sender: TObject);
begin
   SortHTLMaintainPos( csDateEffective );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniSortByChequeNumberClick(Sender: TObject);
begin
   SortHTLMaintainPos( csChequeNumber );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniSortByAccountCodeClick(Sender: TObject);
begin
   SortHTLMaintainPos( csAccountCode );
end;

procedure TdlgHistorical.mniSortByAltCodeClick(Sender: TObject);
begin
   SortHTLMaintainPos( csByAltChartCode );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniSortByValueClick(Sender: TObject);
begin
   SortHTLMaintainPos( csByValue);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.mniSortByNarrationClick(Sender: TObject);
begin
   SortHTLMaintainPos( csbyNarration );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.popSortByPopup(Sender: TObject);
begin
//   tbSort.Down := false;
   mniSortbyDate.Checked               :=false;
   mniSortbyChequenumber.Checked       :=false;
   mniSortbyReference.Checked          :=false;
   mniSortbyAccountCode.Checked        :=false;
   mniSortbyValue.Checked              :=false;
   mniSortbyNarration.Checked          :=false;
   mniSortbyAltCode.Checked            :=false;

   case TranSortOrder of
      csAccountCode:
         mniSortbyAccountCode.Checked := true;
      csByNarration:
         mniSortbyNarration.Checked := true;
      csByValue:
         mniSortbyValue.Checked := true;
      csDateEffective:
         mniSortbyDate.checked := true;
      csChequeNumber:
         mniSortbyChequeNumber.Checked := true;
      csReference:
         mniSortbyReference.Checked := true;
      csByAltChartCode:
         mniSortbyAltCode.Checked := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgHistorical.FormActivate(Sender: TObject);
begin
   //Set Esc = cancel back on for first activate, will have been turned off by the
   //onEnter event of the table, however we would like to user to be able to hit ESC
   //and leave the form if they have not done anything.  will be turned off by get data
   //as soon as a cell is read for editing
   if FirstActivate then begin
      btnCancel.Cancel := true;
      FirstActivate := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistExit(Sender: TObject);
begin
 if not tblHist.StopEditingState(true) then
    Exit;
  btnOk.Default    := true;
  btnCancel.Cancel := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.RemindUserToSave(Imported: Boolean = False);
//Remind the user to accept the current session and save the client file.
var
  Msg: string;
  HowEntered: string;
  NumberEntered: Integer;
begin
   HowEntered := 'entered';
   if Imported then
     HowEntered := 'imported';

   if Imported then
   begin
     NumberEntered := HistTranList.ItemCount;
   end
   else
   begin
     NumberEntered := Pred(HistTranList.ItemCount);
   end;

   if ( HistTranList.ItemCount - LastReminderAt) > NoEntriesBeforeReminder then begin
      Msg := Format('You have %s %d %s Transactions.'#13+
                    'It is recommended that you now leave %2:s Data Entry and Save the Client File. (Click File|Save from the menu)',
                    [HowEntered, NumberEntered, AccountType]);
      if Provisional then
         Msg := Format('You have %s %d %s Transactions.',
                       [HowEntered, NumberEntered, AccountType]);
      HelpfulInfoMsg(Msg, 0);
      LastReminderAt := HistTranList.ItemCount-1;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgHistorical.IsACheque(pT: pTransaction_Rec): boolean;
//pT^.txType holds the cmb index no the actual transaction type
//The actual txType is held in the Objects property of the cmb items
//ChequeTypeCmbIndex is set building the combo
begin
   result := ( pT^.txType = ChequeTypeCmbIndex );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.EntryTypeEdited(pT: pTransaction_Rec);
//called if the entry type has changed
//need to update the txCheque_No depending on the entry type
//calls procedure AmountEdited
var
   OldAmount  : Money;
   Dissection : pDissection_Rec;
begin
   UpdateChequeNo( pT);
   //check that the amount field is the correct sign ( +ve normall, otherwise -ve for deposits)
   OldAmount := pT^.txAmount;
   if pT^.txType = DepositTypeCmbIndex then
      pT^.txAmount := Abs( pT^.txAmount ) * -1
   else
      pT^.txAmount := Abs( pT^.txAmount);
   //Call amount edited if amount changed
   if ( OldAmount <> pT^.txAmount) then begin
      //if the amount is a dissection then reverse the sign of the lines in the dissection.
      //if we dont do this the transaction will fail the integrity check when the file is saved
      //causing a Critical Application Error
      Dissection := pT^.txFirst_Dissection;
      while Dissection <> nil do begin
         with Dissection^ do begin
            //flip the sign of the amount and gst amount
            dsAmount := -dsAmount;
            dsGST_Amount := -dsGST_Amount;
            dsQuantity := -dsQuantity;
            Dissection := dsNext;
         end;
      end;
      pT^.txQuantity := - pT^.txQuantity;
      //call amount edited to force gst change
      AmountEdited(pT);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgHistorical.UpdateChequeNo( pT : pTransaction_Rec);
//uses the ChequeTypeCmbIndex to quickly decide if this is a cheque (see SetupEntryTypeList)
//the txCheque_Number field is changed accordingly
var
   S      : string;
begin
   if pT^.txType = ChequeTypeCmbIndex then begin
      //is a cheque so update cheque no from reference
      S := Trim( pT^.txReference );
      While Length( S ) > 6 do System.Delete( S, 1, 1 );
      pT^.txCheque_Number := StrToIntDef( S, 0);
      //now replace the reference with a six digit reference
      pT^.txReference := S;
   end
   else begin
      //is not a cheque no cheqno should be 0
      pT^.txCheque_Number := 0;
   end;
end;
procedure TdlgHistorical.UpdatePanelWidth;
var
  PanelW: Integer;
begin
  with stbHistorical do
  begin
    PanelW := Self.Width - Panels[PANELLINE].Width - Panels[GSTTEXT].Width;

    if PanelW < MinSize then
    begin
       Panels[PANELTEXT].Width := MinSize
    end
    else
    begin
       Panels[PANELTEXT].Width := PanelW;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the account code is invalid, show it in read
var
  R       : TRect;
  C       : TCanvas;
  S       : String;
  IsActive: boolean;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  IsActive := True;
  S := ShortString( Data^ );
  If ( S='' ) or ( S=DISSECT_DESC ) or MyClient.clChart.CanCodeTo( S, IsActive ) then exit;
  R := CellRect;
  C := TableCanvas;
  //paint background
  C.Brush.Color := clRed;
  C.FillRect( R );
  //paint border
  C.Pen.Color := CellAttr.caColor;
  //  C.Polyline( [ R.TopLeft, Point( R.Right, R.Top)]);
  C.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);
  {draw data}
  InflateRect( R, -2, -2 );
  C.Font.Color := clWhite;
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.ConfigureColumns;
var
   i              : integer;
   cRec           : pColumnDefn;
   CurrentFieldID : integer;
   ColumnConfig   : TColumnConfigInfo;
begin
   //make sure not editing
   if not tblHist.StopEditingState(True) then Exit;

   with TfrmConfigure.Create(Self) do begin
      try
         ShowTemplates := False;
         ConfigBankAccount := BankAccount;
         SortColumn := CurrentSortOrder;
         if IsManual then
           CodingScreen := MDE_SCREEN
         else
           CodingScreen := HDE_SCREEN;
         ColumnFormatList := tblHist.ColumnFmtList;
         NeverEditable := [];
         AlwaysEditable := [ceEffDate, ceAccount, ceAmount, ceEntryType];
         AlwaysVisible := [ceEffDate, ceAccount, ceAmount, ceEntryType, ceNarration];
         SetUpColDefaultSets;
         DefaultEditable := DefaultEditableCols;
         //setup appearance for CES
         lblEditModeDesc.Caption := 'Column can be edited';
         //Assign Values to ListBox
         lbColumns.Clear;
         //Build TColumnConfigInfo for the column that can be manipulated in dlg
         for i := 0 to Pred( tblHist.ColumnFmtList.ItemCount ) do begin
            cRec := tblHist.ColumnFmtList.ColumnDefn_At(i);
            ColumnConfig := TColumnConfigInfo.Create;
            with ColumnConfig do begin
               //set editable state
               if cRec.cdFieldID in [ ceEffDate, ceAccount, ceAmount{, ceEntryType Case 9528}] then
                  EditState := esAlwaysEditable
               else
               if (( cRec.cdFieldID in [ ceGSTAmount]) and ( MyClient.clFields.clCountry = whAustralia )
                                                        and ( MyClient.clFields.clBAS_Calculation_Method = bmFull)) or
                  (cRec.cdFieldID = ceBalance) then
                  EditState := esNeverEditable
               else
               if ( cRec.cdFieldID in [ ceGSTClass]) then
               begin
                 If not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
                   EditState := esNeverEditable
               end
               else if cRec.cdFieldId in [ceDescription, cePayeeName, ceJobName, ceForexRate, ceLocalAmount, ceAltChartCode] then
                  EditState := esNeverEditable
               else
               if cRec.cdEditMode[ emGeneral] then
                  EditState := esEditable
               else
                  EditState := esNotEditable;
               //set visible state
               if cRec.cdFieldID in [ ceEffDate, ceAmount, ceAccount, ceNarration{, ceEntryType Case 9528}] then
                  VisibleState := vsAlwaysVisible
               else
               if cRec.cdHidden then
               begin
                  VisibleState := vsNotVisible;
                  if EditState = esEditable then
                    Editstate := esNotEditable;
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
         lbColumns.ItemIndex := tblHist.ActiveCol;
         //Show Form
         SaveTempLayout;
         ShowModal;
         //Reorder the columns if OK pressed
         if ModalResult = mrOK then begin
            with tblHist do begin
               AllowRedraw := false;
               //store the active col field id for later use
               CurrentFieldId := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
               //Remove all cols from list and reinsert
               ColumnFmtList.DeleteAll;
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
                  ActiveCol := ColumnFmtList.GetColNumOfField( ceEffDate);

               AllowRedraw := true;
            end;
         end
         else
         begin
           LoadTempLayout;
           tblHist.Refresh;
         end;
      finally
         //free the ColumnConfig settings objects for each string
         for i := 0 to Pred( lbColumns.Items.Count) do begin
            if Assigned( lbColumns.Items.Objects[ i]) then
               TColumnConfigInfo( lbColumns.Items.Objects[ i]).Free;
         end;
         Free;
      end;
   end;
end;
procedure TdlgHistorical.ConvertAmount1Click(Sender: TObject);
var
  Key: Char;
begin
  //Conver VAT amount to base currency
  Key := '£';
  if tblHist.StartEditingState then
    celGstAmtKeyPress(tblHist, Key);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.ResetColumns;
var
   i, CurrentFieldID : integer;
   Col: pColumnDefn;
begin
  with tblHist do
  begin
    AllowRedraw := false;
    //store the active col field id for later use
    CurrentFieldId := ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID;
    ColumnFmtList.SetToDefault;
    // and reset visiblity
    for i := 0 to Pred( ColumnFmtList.ItemCount) do begin
     Col := ColumnFmtList.ColumnDefn_At( i);
     Col.cdHidden := Col.cdDefHidden;
     if Col.cdHidden and (Col.cdFieldID = CurrentFieldId) then
      CurrentFieldId := 0;
    end;
    //Rebuild the table
    BuildTableColumns;
    //Reset the active col in case the col was moved
    if (CurrentFieldID > 0) then
      ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID)
    else
      ActiveCol := 0;
    AllowRedraw := true;
  end;
end;

procedure TdlgHistorical.actRestoreExecute(Sender: TObject);
var
   i : integer;
begin
   //make sure not editing
   if not tblHist.StopEditingState(True) then Exit;

   //RestoreColumns
   with tblHist do begin
      try
         AllowRedraw := false;
         for i := 0 to Pred( ColumnFmtList.ItemCount) do begin
            //special behaviour for gst amount, gst class
            if ( ColumnFmtList.ColumnDefn_At(i).cdFieldID = ceGSTAmount) and
               ( MyClient.clFields.clCountry = whAustralia) and
               ( MyClient.clFields.clBAS_Calculation_Method = bmFull)
            then
               ColumnFmtList.ColumnDefn_At( i)^.cdEditMode[ emGeneral] := false
            else
            if ( ColumnFmtList.ColumnDefn_At(i).cdFieldID = ceGSTClass) then
            begin
              If Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
                ColumnFmtList.ColumnDefn_At( i)^.cdEditMode[ emGeneral] := true
              else
                ColumnFmtList.ColumnDefn_At( i)^.cdEditMode[ emGeneral] := false;
            end;
            if ( ColumnFmtList.ColumnDefn_At(i).cdFieldID in [ceJob, ceJobName, cePayeeName, ceDescription, ceTaxInvoice, ceAltChartCode]) then
               ColumnFmtList.ColumnDefn_At(i).cdDefHidden := True;
         end;
         Self.ResetColumns;
      finally
         AllowRedraw := true;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pT  : pTransaction_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow(RowNum) then begin
     pT   := HistTranList.Transaction_At(RowNum-1);
     if not pT^.txGST_Has_Been_Edited then
        exit;

     R := CellRect;
     C := TableCanvas;
     S := ShortString( Data^);
     {paint background}
     c.Brush.Color := CellAttr.caColor;
     c.FillRect(R);
     {draw data}
     InflateRect( R, -2, -2 );
     C.Font.Color := bkGSTEditedColor; // cellAttr.caFontColor;
     DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
     DoneIt := true;
  end;
end;

procedure TdlgHistorical.CelJobOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
  const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
var pt: pTransaction_Rec;
    pd: pDissection_Rec;
    C: TCanvas;
    R: TRect;
    Job: PJob_Heading_Rec;
begin
   if ValidDataRow(RowNum) then begin
      pT := HistTranList.Transaction_At(RowNum-1);

      if pT^.txJob_Code > '' then // Set in the Trans
         Exit; //Paint Normal

      if pT^.txFirst_Dissection = nil then
         Exit; //Paint Normal

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
   DoneIt := True;

end;

//------------------------------------------------------------------------------

procedure TdlgHistorical.celGstAmtOwnerDraw(Sender: TObject;
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
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow(RowNum) then begin
     pT   := HistTranList.Transaction_At(RowNum-1);
     R := CellRect;
     C := TableCanvas;
     pfHiddenAmount.SetValue( Data^ );
     S := PChar( pfHiddenAmount.AsString);
     if pT^.txFirst_Dissection = nil then begin
       {paint background}
       c.Brush.Color := CellAttr.caColor;
       c.FillRect(R);
       {draw data}
       InflateRect( R, -2, -2 );
       C.Font.Color := cellAttr.caFontColor;
       DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
       DoneIt := true;
     end
     else
     begin
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
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.ShowPopUp(x, y: Integer; PopMenu: TPopUpMenu);
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblHist.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.tblHistMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ColEstimate, RowEstimate : integer;
begin
  if (Button = mbRight) then begin
     //estimate where click happened
     if tblHist.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;
     //select correct row
     tblHist.ActiveRow := RowEstimate;

     ConvertAmount1.Visible := False;
     if (FCountry = whUK) and
        (tblHist.ActiveCol = tblHist.ColumnFmtList.GetColNumOfField(ceGSTAmount)) and
        (BankAccount.IsAForexAccount) then
       ConvertAmount1.Visible := True;

     ShowPopup( x,y,pmTable);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.celQuantityChange(Sender: TObject);
begin
   //test to see if need to automatically put minus sign
   if AutoPressMinus then
       keybd_event(vk_subtract,0,0,0);
   AutoPressMinus := false;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddHistoricalData : boolean;
//this function is called from outside this unit and starts the add historical data process
//returns true if transactions were added
var
  SelectedBA : TBank_Account;
  Historical : TdlgHistorical;
begin
  result := false;
  AssignGlobalRedrawForeign(True);

  //See if client file has any bank accounts attached to it
  if BKUTIL32.CountDeliveredBankAccounts = 0 then
  begin
    HelpfulInfoMsg( 'You cannot add historical entries to this client file ' +
                    'until you have attached a delivered bank account.',0);
    exit;
  end;

  //Select a bank account to add historical data to
  if SelectBankAccount( 'Select Account to add Historical Transactions to',
                       SelectDeliveredTrx, 0,0, false,
                       BKH_Adding_historical_data,
                       SelectedBA) = mrCancel then
  begin
    exit;
  end;

  if not Assigned(SelectedBA) then
  begin
    HelpfulInfoMsg( 'You cannot add historical entries to this client file ' +
                    'until you have attached a bank account with delivered transactions.',0);
    exit;
  end;

  //Create form and show modally
  Historical := TdlgHistorical.CreateAndSetup( SelectedBA );
  with Historical do
  begin
    try
      IsManual := False;
      HelpContext := BKH_Adding_historical_data;
      tbImportTrans.Visible := Assigned(AdminSystem)
                            or PRACINI_AllowHistoricalImport;

      // Run the dialog
      Result := ShowModal = mrOK;

    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddManualData : boolean;
//this function is called from outside this unit and starts the add manual data process
//returns true if transactions were added
var
  SelectedBA: TBank_Account;
  R: Boolean;
  DummyAccVendor : TAccountVendors;
begin
   Result := false;
   AssignGlobalRedrawForeign(True);

   //See if client file has any bank accounts attached to it
   if BKUTIL32.CountManualBankAccounts = 0 then begin
      HelpfulInfoMsg( 'You cannot add manual entries to this client file ' +
                      'until you have added a manual bank account.',0);
      exit;
   end;

   if Assigned(AdminSystem) and MDEExpired(MyClient.clBank_Account_List, MyClient.clFields.clLast_Use_Date) then
   begin
      HelpfulWarningMsg( 'You cannot add manual entries to this client file ' +
                      'because your manual bank accounts have expired.',0);
      exit;
   end;

   //Select a bank account to add historical data to
   SelectBankAccount( 'Select Account to add Manual Transactions to',
                      SelectManual, 0,0, false,
                      BKH_Adding_manual_data,
                      SelectedBA);

   if not Assigned(SelectedBA) then
      exit;

   if (not Assigned(AdminSystem))
   and Assigned(SelectedBA)
   and (not SelectedBA.baFields.baExtend_Expiry_Date)
   and MDEExpired(MyClient.clBank_Account_List, MyClient.clFields.clLast_Use_Date) then begin
      HelpfulWarningMsg( 'You cannot add manual entries to this client file ' +
                      'because your manual bank accounts have expired.',0);
      exit;
   end;


   // must have institution and type
   if (SelectedBA.baFields.baManual_Account_Institution = '')
   or (SelectedBA.baFields.baManual_Account_Type = -1) then
   begin
     if AskYesNo('Temporary Account Upgrade', 'The Temporary Account "' + SelectedBA.AccountName + ' : ' +
       SelectedBA.baFields.baBank_Account_Number + '" has been upgraded to a Manual Account.'#13#13 +
       'The manual account type and institution are required.'#13#13 +
       'Would you like to enter this information now?', DLG_YES, 0) <> DLG_YES then
          exit;

     MyClient.clBank_Account_List.Delete(SelectedBA);
     R := EditBankAccount(SelectedBA, DummyAccVendor, '');
     //Must be a manual bank account so that the Audit ID is not overwritten
     //when it's inserted into the list.
     SelectedBA.baFields.baIs_A_Manual_Account := True;
     MyClient.clBank_Account_List.Insert(SelectedBA);
     if not R then
        exit;
   end;

   //Create form and show modally
   with TdlgHistorical.CreateAndSetup(SelectedBA) do try
      IsManual := True;
      HelpContext := BKH_Adding_manual_data;
      tbImportTrans.Visible := False;

      Result := ShowModal = mroK;

   finally
      Free;
   end;
end;







function AddProvisionalData(ForAccount: string) : boolean;
//this function is called from outside this unit and starts the add provisional data process
//returns true if transactions were added
var
  SelectedBA: pSystem_Bank_Account_Rec;
  //ProvisionalDlg: TdlgHistorical;

  TempAccount: TBank_Account;
  TempClient, KeepClient: TClientObj;
  PE: pProvisional_Entries_Log_Rec;

  function SaveToArchives: Boolean;
  const ThisMethodName = 'ProvisionalToArchive';
  var
     eFileName: string;
     eFile: file of tArchived_Transaction;
     Entry: tArchived_Transaction;
     I: integer;
     ClientAccountMap: pClient_Account_Map_Rec;
     FirstProvisionalLRN, LastProvisionalLRN: integer;
  begin
     Result := False;
     AssignGlobalRedrawForeign(True);
     LoadAdminSystem(True,'Save Provisional');

     SelectedBA := Adminsystem.fdSystem_Bank_Account_List.FindCode(ForAccount);
     if not Assigned(SelectedBA) then
        Exit;

     eFileName := ArchiveFileName( SelectedBA.sbLRN );

     Assign(eFile, eFileName);
     if BKFileExists(eFileName) then begin
        if DebugMe then
           LogUtil.LogMsg(lmDebug, UnitName, format('%s - Opening %s.', [ThisMethodName, eFileName]));

        Reset(eFile);

        if DebugMe then
           LogUtil.LogMsg(lmDebug, UnitName, format('%s - Find end %s.', [ThisMethodName, eFileName]));

        Seek(eFile, FileSize(eFile));
     end else Begin
        if DebugMe then
           LogUtil.LogMsg(lmDebug, UnitName, format('%s - Creating %s.', [ThisMethodName, eFileName]));

        Assign(eFile, eFileName);
        Rewrite(eFile);
     end;

     // These are all reset on the actual download ??
     // SelectedBA.sbNew_This_Month := True;
     // sbWas_On_Latest_Disk        := false;
     SelectedBA.sbNo_of_Entries_This_Month:= 0;
     SelectedBA.sbFrom_Date_This_Month:= maxint;
     SelectedBA.sbTo_Date_This_Month:= 0;
     //SelectedBA.sbCharges_This_Month:= 0;

     try
        FirstProvisionalLRN := 0;
        LastProvisionalLRN  := 0;
        for I := TempAccount.baTransaction_List.First to TempAccount.baTransaction_List.Last do
        with TempAccount.baTransaction_List.Transaction_At(I)^ do begin
           FillChar(Entry, Sizeof(Entry), 0);
           Entry.aRecord_End_Marker := ArchUtil32.ARCHIVE_REC_END_MARKER;

           Entry.aType              := txType;
           Entry.aSource            := BKCONST.orProvisional;
           Entry.aDate_Presented    := txDate_Presented;
           Entry.aReference         := txReference;
           Entry.aCheque_Number     := txCheque_Number;
           Entry.aStatement_Details := txGL_Narration;
           Entry.aAmount            := txAmount;
           Entry.aQuantity          := abs(txQuantity);
           Entry.aOther_Party       := txOther_Party;
           Entry.aAnalysis          := txAnalysis;

           //allocate new lrn for this transaction and write to txn file
           Inc(AdminSystem.fdFields.fdTransaction_LRN_Counter);
           Entry.aLRN := AdminSystem.fdFields.fdTransaction_LRN_Counter;
           //Save LRN range for auditing
           if i = TempAccount.baTransaction_List.First then
             FirstProvisionalLRN := Entry.aLRN;
           if i = TempAccount.baTransaction_List.Last then
             LastProvisionalLRN := Entry.aLRN;

           //transaction has been constructed
           Write(eFile, Entry);
           Inc(SelectedBA.sbNo_of_Entries_This_Month);

           // Update the account record
           SelectedBA.sbLast_Transaction_LRN := Entry.aLRN;

           //update date range for this account
           SelectedBA.sbFrom_Date_This_Month := min(SelectedBA.sbFrom_Date_This_Month,Entry.aDate_Presented);
           SelectedBA.sbTo_Date_This_Month := max(SelectedBA.sbTo_Date_This_Month, Entry.aDate_Presented);

           SelectedBA.sbLast_Entry_Date := max(SelectedBA.sbLast_Entry_Date, Entry.aDate_Presented);
           if (SelectedBA.sbFirst_Available_Date = 0)
           or (Entry.aDate_Presented < SelectedBA.sbFirst_Available_Date) then
              SelectedBA.sbFirst_Available_Date := Entry.aDate_Presented;


           //add transaction amount to current balance
           //for AU the current balance will have been set to the opening balance
           //for NZ the current balance will be whatever the user has set up
           if SelectedBA.sbCurrent_Balance <> Unknown then
              SelectedBA.sbCurrent_Balance := SelectedBA.sbCurrent_Balance + Entry.aAmount;

           // Update the admin system
           AdminSystem.fdFields.fdPrint_Reports_Up_To :=
              Max(AdminSystem.fdFields.fdPrint_Reports_Up_To, Entry.aDate_Presented);

           AdminSystem.fdFields.fdHighest_Date_Ever_Downloaded :=
              Max(AdminSystem.fdFields.fdHighest_Date_Ever_Downloaded, Entry.aDate_Presented);

        end;// Trans Loop

        //Save username, datetime, and LRN range to System DB for auditing
        PE := SYPEIO.New_Provisional_Entries_Log_Rec;
        PE.peDate_Time := Now;
        PE.peUser_Code := Globals.CurrUser.Code;
        PE.peFirst_LRN := FirstProvisionalLRN;
        PE.peLast_LRN := LastProvisionalLRN;
        AdminSystem.fSystem_Provisional_List.Insert(PE);

        //update the Earliest Download Date to the Client Account Maps
        for I := AdminSystem.fdSystem_Client_Account_Map.First to AdminSystem.fdSystem_Client_Account_Map.Last do begin
           ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(I);
           if ClientAccountMap.amAccount_LRN = SelectedBA.sbLRN then begin
              // Matching Client account
              if (ClientAccountMap.amEarliest_Download_Date = 0) then // savety net only, should be maxint if 'reset'
                 ClientAccountMap.amEarliest_Download_Date := SelectedBA.sbFrom_Date_This_Month
              else
                 ClientAccountMap.amEarliest_Download_Date :=
                               Min(SelectedBA.sbFrom_Date_This_Month,ClientAccountMap.amEarliest_Download_Date);
           end;
        end;

     finally
        CloseFile(eFile);
     end;
      //*** Flag Audit ***
     SystemAuditMgr.FlagAudit(arSystemBankAccounts);
     //The following may need to be audited at a later date?
     //SystemAuditMgr.FlagAudit(arPracticeSetup);
     //SystemAuditMgr.FlagAudit(arAttachBankAccounts);

     SaveAdminSystem;
     AdminSystem.DownloadSave;
     Result := True;
  end;

begin
   Result := false;

   RefreshAdmin;
   SelectedBA := Adminsystem.fdSystem_Bank_Account_List.FindCode(ForAccount);
   if not Assigned(SelectedBA) then
      Exit; // nothing to do...

   TempClient := nil;
   TempAccount := nil;
   KeepClient := MyClient;
   try
      // Create a temp Client for the Temp Banmk account
      TempClient := TClientObj.Create;
      TempClient.clFields.clCode := 'Code';
      TempClient.clFields.clName := 'Name';
      // Set the default country bits
      TempClient.clFields.clCountry := Adminsystem.fdFields.fdCountry;
      TempClient.clExtra.ceLocal_Currency_Code := Adminsystem.CurrencyCode;

      TempAccount := TBank_Account.Create(TempClient);
      with TempAccount.baFields do begin
          baCurrent_Balance := SelectedBA.sbCurrent_Balance;
          baAccount_Type := btBank;
          baIs_A_Provisional_Account := true;
          baDesktop_Super_Ledger_ID := -1;
          baBank_Account_Number := SelectedBA.sbAccount_Number;
          baBank_Account_Name := SelectedBA.sbAccount_Name;
          baCurrency_Code := SelectedBA.sbCurrency_Code;
          // savety net...
          if baCurrency_Code = '' then
             baCurrency_Code := Adminsystem.fCurrencyCode;
      end;
      TempClient.clBank_Account_List.Insert(TempAccount);
      TempClient.RefreshExchangeSource(False); //Don't apply default GST for provisional

      MyClient := TempClient;
      //Create form and show modally
      with TdlgHistorical.CreateAndSetup(TempAccount, True) do
      try
         Provisional := True;
         IsManual := True;
         MaxHistTranDate := MaxValidDate;

         if  ShowModal = mrOK then begin
            // Now try and copy tans to
            SaveToArchives;
            Result := True;
         end;
      finally
         Free;
      end;


   finally
      FreeAndNil(TempClient);

      MyClient := KeepClient;
      RefreshHomepage([HPR_Coding]);
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgHistorical.EmptyTmpBuffer;
var
  i : integer;
begin
  for i := Low(tmpBuffer) to High(tmpBuffer) do
    tmpBuffer[i] := #0;
end;

procedure TdlgHistorical.DoDeleteDissection(pT: pTransaction_Rec);
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
   //redraw row
   tblHist.AllowRedraw := false;
   try
     tblHist.InvalidateRow(tblHist.ActiveRow);
   finally
     tblHist.AllowRedraw := true;
   end;
end;

procedure TdlgHistorical.mniSortByReferenceClick(Sender: TObject);
begin
  SortHTLMaintainPos( csReference );
end;

procedure TdlgHistorical.celLocalAmountOwnerDraw(Sender: TObject;
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
  DoneIt := True;
  R := CellRect;
  C := TableCanvas;
  S := StrPas( PChar( Data ) );
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect(R, -Margin div 2, -Margin div 2);

  if ( pos( '(', S ) > 0 ) or ( pos( '-', S ) > 0 ) then
    R.Right := round(R.Left+(R.Right-R.Left)*0.95)
  else
    R.Right := round(R.Left+(R.Right-R.Left)*0.75);

  DrawText(C.Handle, Data, StrLen(Data), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
end;

procedure TdlgHistorical.celPayeeKeyDown(Sender: TObject; var Key: Word;
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

procedure TdlgHistorical.celPayeeOwnerDraw(Sender: TObject;
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
     pT   := HistTranList.Transaction_At(RowNum-1);
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

procedure TdlgHistorical.celGSTCodeKeyDown(Sender: TObject; var Key: Word;
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

//------------------------------------------------------------------------------
//
// SetQuantitySign
//
// Sets the sign (+/-) of the quantity based on the amount entered.
// a positive amount will make a positive quantity.
// a negative amount will make a negative quantity.
//
procedure TdlgHistorical.SetQuantitySign(QuantityChanged : Boolean);
var
  pT : pTransaction_Rec;
  fQValue : Double;
begin
  pT := HistTranList.Transaction_At(tblHist.ActiveRow-1);

  //user can have whatever sign they like if the amount is zero
  if pT^.txAmount = 0 then
    Exit;

  if (QuantityChanged) then
  begin
    //the quantity value was changed
    fQValue := TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat;
    if (pT^.txAmount >= 0) then
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
    //the amount value was changed
    fQValue := pT^.txQuantity;
    if (pT^.txAmount >= 0) then
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

procedure TdlgHistorical.celQuantityExit(Sender: TObject);
begin
  SetQuantitySign(True);
end;

procedure TdlgHistorical.celTaxInvKeyUp(Sender: TObject; var Key: Word;
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

function TdlgHistorical.CodingMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ColEstimate, RowEstimate : integer;
  R : TRect;
  Msg: TWMKey;
  pT: pTransaction_Rec;
begin
  Result := False;

  //estimate where click happened
  if tblHist.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;

  if (Button = mbLeft) then
    begin
      if ( tblHist.ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID = ceTaxInvoice) and
         tblHist.ColumnFmtList.ColIsEditable(ColEstimate) then
        begin
          //get row estimate
          if not ValidDataRow(RowEstimate) then
            exit;

          R := GetCellRect( RowEstimate, ColEstimate );
          R.Left := R.Left + 20;
          R.Right := R.Right - 22;
          R.Bottom := R.Bottom - 7;
          R.Top := R.Top + 7;

          if PtInRect( R, tblHist.ClientToScreen( Point( x,y))) then
          begin
            pT := HistTranList.Transaction_At(tblHist.ActiveRow-1);
            pT.txTax_Invoice_Available := not pT.txTax_Invoice_Available;
            Result := True;
            tblHist.StartEditingState;
            Msg.CharCode := VK_RIGHT;
            celTaxInv.SendKeyToTable(Msg);
          end
          else
            tblHist.StopEditingState(true);
        end;
    end;
end;


function TdlgHistorical.GetCellRect(const RowNum, ColNum: Integer): TRect;
begin
  Result.Top    := tblHist.Top  + tblHist.RowOffset[ RowNum ];
  Result.Bottom := tblHist.Top  + tblHist.RowOffset[ RowNum ] + tblHist.Rows[ RowNum ].Height;
  Result.Left   := tblHist.Left + tblHist.ColOffset[ ColNum ];
  Result.Right  := tblHist.Left + tblHist.ColOffset[ ColNum ] + tblHist.Columns[ ColNum ].Width;
  Result.TopLeft := ClientToScreen( Result.TopLeft );
  Result.BottomRight := ClientToScreen( Result.BottomRight );
end;

procedure TdlgHistorical.celTaxInvMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Msg: TWMKey;
  Swapped: Boolean;
  pT: pTransaction_Rec;
begin
  Swapped := CodingMouseUp(Sender, Button, Shift, X, Y);
  if (X > 20) and (X < 33) and (Y > 6) and (Y < 19) then
  begin
    if (not Swapped) and (tblHist.ColumnFmtList.ColIsEditable(tblHist.ColumnFmtList.GetColNumOfField( ceTaxInvoice ))) then
    begin
      if tblHist.InEditingState then
        tblHist.StopEditingState(true)
      else
        tblHist.StartEditingState;
      pT := HistTranList.Transaction_At(tblHist.ActiveRow-1);
      pT.txTax_Invoice_Available := not pT.txTax_Invoice_Available;
    end;
    Msg.CharCode := VK_RIGHT;
    celTaxInv.SendKeyToTable(Msg);
  end
  else
    tblHist.StopEditingState(true);
end;

procedure TdlgHistorical.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Forms.TForm(Self));
end;

procedure TdlgHistorical.tbImportTransClick(Sender: TObject);
var
  pT: pTransaction_Rec;
begin
   pT := HistTranList.Transaction_At( tblHist.ActiveRow - 1 );
   //Check to see if leaving current row which has not been edited
   if not pT^.txHas_Been_Edited then
      DeleteCurrentLine(false);

   ImportHist(HistTranList, BankAccount, self);
   //if nothing got imported, we need to add an entry back in if the list is blank
   if (HistTranList.ItemCount = 0) then
      InsertNewRow(InsertAtEnd);

   tblHist.RowLimit := HistTranList.ItemCount + 1;
   SetTableAccess;
   CalculateBalanceColumn;
   CalcClosingBal;

   fHasCheques := PrivateProfileTextToBoolean(GetPrivateProfileText(IniFile, BankAccount.baFields.baBank_Account_Number, kHasCheques));
   Refresh;

   //Reminder the user that they should not enter too many before saving
   RemindUserToSave(True);
end;

procedure TdlgHistorical.SaveTempLayout;
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblHist do
    for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       with ColDefn^ do begin
          Temp_Column_Width[ cdFieldID ]     := cdWidth;
          Temp_Column_Is_Hidden[ cdFieldID ] := cdHidden;
          Temp_Column_Order[ cdFieldID ]     := i;    //use the list index position for the current positions
          Temp_Column_Is_Not_Editable[ cdFieldID] := not cdEditMode[ emGeneral];
       end;
    end;
end;

procedure TdlgHistorical.LoadTempLayout;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblHist do
  begin
    for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       with ColDefn^, BankAccount.baFields do begin
          if Temp_Column_Width[ cdFieldID] <> 0 then begin
             cdWidth            := Temp_Column_Width[ cdFieldID];
             cdRequiredPosition := Temp_Column_Order[ cdFieldID];
             cdHidden           := Temp_Column_Is_Hidden[ cdFieldID];
              cdEditMode[ emGeneral] := not Temp_Column_Is_Not_Editable[ cdFieldID]
          end
          else begin
             //defaults will be used
             cdWidth            := cdDefWidth;
             cdRequiredPosition := cdDefPosition;
             cdHidden           := cdDefHidden;
             cdEditMode[ emGeneral] := True;
          end;
       end;
    end;
    //now resort list into correct order
    ColumnFmtList.ReOrder;
  end;
end;

procedure TdlgHistorical.actGSTExecute(Sender: TObject);
begin
  DoGSTLookup;
end;

procedure TdlgHistorical.actJobExecute(Sender: TObject);
begin
  DoJobLookup;
end;

procedure TdlgHistorical.celAccountKeyUp(Sender: TObject; var Key: Word;
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
  LCode := TEdit(celAccount.CellEditor).text;
  if MyClient.clChart.CanPressEnterNow(LCode) then
  begin
     TEdit(celAccount.CellEditor).text := LCode;
     Msg.CharCode := VK_RIGHT;
     celAccount.SendKeyToTable(Msg);
  end;        
end;

procedure TdlgHistorical.celAccountExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(celAccount.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask);
end;

procedure TdlgHistorical.tbCopyLineClick(Sender: TObject);
begin
  if DittoLineInProgress then
    Exit; // prevents a race condition if the user decides to press Copy Line really fast for shits and giggles
  DittoLineInProgress := True;
  DoDittoLine;
  DittoLineInProgress := False;
end;

procedure TdlgHistorical.celBalanceOwnerDraw(Sender: TObject;
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

procedure TdlgHistorical.CalculateBalanceColumn;
var
  i: Integer;
  pT: pTransaction_Rec;
begin
   // recalculate all balances after every edit
   for i := HistTranList.First to HistTranList.Last do
   begin
     pT := HistTranList.Transaction_At( i);
     pT.txTemp_Balance := CalcClosingBalSortOrder(i);
   end;
   with tblHist do begin
      AllowRedraw := false;
      InvalidateColumn(ColumnFmtList.GetColNumOfField(ceBalance));
      AllowRedraw := true;
   end;
end;




end.

