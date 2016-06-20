unit MemoriseDlg;
//------------------------------------------------------------------------------
{
  Title:   Memorise Entry Dlg

  Written:
  Authors:

  Purpose: Allows the user to memorise the current entry

  Notes:

     Recalculate GST Problem:

     GST cannot be recalculated in memorisations because we have no way of knowing if the
     memorisation has been setup using the default GST class, or if the class has been changed.

     There is also no way to edit a memorisation to change the gst class at a later date.

     Solution : Will need to add a flag to memorisations that tells us if the gst has been edited.
                If it has not been edited then we can update it during a recalc.

     Sort Term solution for AU is not to allow editing of the GST Class.  Therefore the default will
     always be used.  AutoCode will also be changed to use the current gst default for the chart code.

}
//------------------------------------------------------------------------------

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  OvcTCmmn,
  OvcTCell,
  OvcTCStr,
  OvcTCHdr,
  OvcBase,
  OvcTable,
  bkdefs,
  baObj32,
  OvcTCEdt,
  OvcTCBEF,
  OvcTCNum,
  OvcTCCBx,
  ExtCtrls,
  BKConst,
  OvcTCBmp,
  OvcTCGly,
  OvcEF,
  OvcPB,
  OvcNF,
  Buttons,
  OvcABtn,
  globals,
  ImgList,
  ComCtrls,
  ToolWin,
  OvcTCPic,
  moneydef,
  OvcTCSim,
  glConst,
  MemorisationsObj,
  Menus,
  SuperFieldsutils,
  OsFont,
  MemTranSortedList,
  SpinnerFrm,
  Contnrs,
  clObj32,
  ovcpf;

type
  TSplitArray = Array[ 1 .. GLCONST.Max_mx_Lines ] of TmemSplitRec;
  TDlgEditMode = (
    demCreate,
    demEdit,
    demCopy,
    demMasterCreate,
    demMasterEdit,
    demMasterCopy
  );

const
  ALL_EDIT = [demEdit, demMasterEdit];
  ALL_CREATE = [demCreate, demMasterCreate, demCopy, demMasterCopy];
  ALL_MASTER = [demMasterEdit, demMasterCreate, demMasterCopy];
  ALL_NO_MASTER = [demEdit, demCreate, demCopy];
  ALL_COPY = [demMasterCopy, demCopy];

type
  TdlgMemorise = class;

  TDoneThreadEvent = procedure() of object;

  TMasterMemItem = class(TObject)
  private
    fLevel : integer;
    fName  : string;
  public
    property Level : integer read fLevel write fLevel;
    property Name  : string read fName write fName;
  end;

  TMasterMemProcessStage = (msgInstitution, msgMasterList, msgFinished);
  TMasterMemProcessStep = (mstInitilize, mstProcessClient, mstProcessAccount, mstFinished);

  //----------------------------------------------------------------------------
  // Thread used to populate the affected accounts of a master mem that is will be created
  // by the current setup.
  // The work done in the thread is split into 2 stages and each stage and 3 Steps
  // Stage 1 - Institution
  //    Step 1 - Initilize
  //    Step 2 - Client Process
  //    Step 3 - Account Process
  // Stage 2 - Master Mems List
  //    Step 1 - Initilize
  //    Step 2 - Client Process
  //    Step 3 - Account Process
  TMasterTreeThread = class(TThread)
  private
    fMasterMemList : TObjectList;
    fWorkerMem : TMemorisation;
    fNumOfSplitLines : integer;

    fSourceBankAccount : TBank_Account;
    fSourceTransaction : pTransaction_Rec;
    fBankPrefix : string;
    fDoneThreadEvent : TDoneThreadEvent;
    fApplyToAccSystem : boolean;
    fAccountSystemAppliedto : byte;

    fProcessStage : TMasterMemProcessStage;
    fProcessStep : TMasterMemProcessStep;
    fClientCount: integer;
    fClientIndex : integer;
    fCltClient : TClientObj;
    fAccountCount: integer;
    fAccountIndex : integer;
    fInstitutionList : TStringList;
    fFoundFirstClientAccount : boolean;
    fFoundFirstAccount : boolean;
    fAccountInstitutions : string;

    procedure AddToMasterMemList(aLevel : integer; aName : string);

    procedure InitlizeVars();
    procedure ClientInitilizeStep();
    procedure ClientProcessStep();
    procedure AccountProcessStep();
    procedure FinishedEvent();
  public
    procedure Execute; override;

    property MasterMemList : TObjectList read fMasterMemList write fMasterMemList;
    property WorkerMem : TMemorisation read fWorkerMem write fWorkerMem;
    property NumOfSplitLines : integer read fNumOfSplitLines write fNumOfSplitLines;

    property SourceBankAccount : TBank_Account read fSourceBankAccount write fSourceBankAccount;
    property SourceTransaction : pTransaction_Rec read fSourceTransaction write fSourceTransaction;
    property BankPrefix : string read fBankPrefix write fBankPrefix;
    property DoneThreadEvent : TDoneThreadEvent read fDoneThreadEvent write fDoneThreadEvent;
    property ApplyToAccSystem : boolean read fApplyToAccSystem write fApplyToAccSystem;
    property AccountSystemAppliedto : byte read fAccountSystemAppliedto write fAccountSystemAppliedto;
  end;

  //----------------------------------------------------------------------------
  TdlgMemorise = class(TForm)
    memController: TOvcController;
    ColAmount: TOvcTCNumericField;
    ColDesc: TOvcTCString;
    ColAcct: TOvcTCString;
    ColGSTCode: TOvcTCString;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Header: TOvcTCColHead;
    colNarration: TOvcTCString;
    colLineType: TOvcTCComboBox;
    popMem: TPopupMenu;
    LookupChart1: TMenuItem;
    LookupGSTClass1: TMenuItem;
    LookupPayee1: TMenuItem;
    Sep1: TMenuItem;
    FixedAmount1: TMenuItem;
    PercentageofTotal1: TMenuItem;
    Sep2: TMenuItem;
    CopyContentoftheCellAbove1: TMenuItem;
    AmountApplyRemainingAmount1: TMenuItem;
    ColPayee: TOvcTCNumericField;
    ColPercent: TOvcTCNumericField;
    EditSuperfundDetails1: TMenuItem;
    ClearSuperfundDetails1: TMenuItem;
    colJob: TOvcTCString;
    btnCopy: TButton;
    LookupJob1: TMenuItem;
    Rowtmr: TTimer;
    tmrPayee: TTimer;
    pnlMain: TPanel;
    pnlAllocateTo: TPanel;
    ToolBar: TPanel;
    sbtnPayee: TSpeedButton;
    sbtnChart: TSpeedButton;
    sbtnJob: TSpeedButton;
    sbtnSuper: TSpeedButton;
    chkMaster: TCheckBox;
    chkAccountSystem: TCheckBox;
    cbAccounting: TComboBox;
    tblSplit: TOvcTable;
    tranController: TOvcController;
    Panel4: TPanel;
    pnlDetails: TPanel;
    cEntry: TCheckBox;
    cmbType: TComboBox;
    chkStatementDetails: TCheckBox;
    cRef: TCheckBox;
    eRef: TEdit;
    eOther: TEdit;
    cOther: TCheckBox;
    cCode: TCheckBox;
    eCode: TEdit;
    cNotes: TCheckBox;
    cPart: TCheckBox;
    cValue: TCheckBox;
    cbTo: TCheckBox;
    cbFrom: TCheckBox;
    eDateFrom: TOvcPictureField;
    eDateTo: TOvcPictureField;
    cmbValue: TComboBox;
    nValue: TOvcNumericField;
    cbMinus: TComboBox;
    btnShowMoreOptions: TButton;
    ePart: TEdit;
    eNotes: TEdit;
    lblMatchOn: TLabel;
    Splitter1: TSplitter;
    lblAllocateTo: TLabel;
    pnlAllocateToLine: TPanel;
    pnlMatchingTransactions: TPanel;
    lblTotalPerc: TLabel;
    lblRemPerc: TLabel;
    lblRemPercHdr: TLabel;
    lblTotalPercHdr: TLabel;
    lblAmount: TLabel;
    lblAmountHdr: TLabel;
    lblFixed: TLabel;
    lblFixedHdr: TLabel;
    lblRemDollar: TLabel;
    lblRemDollarHdr: TLabel;
    tblTran: TOvcTable;
    lblMatchingTransactions: TLabel;
    pnlChartLine: TPanel;
    btnDelete: TButton;
    tranHeader: TOvcTCColHead;
    colTranDate: TOvcTCString;
    colTranAccount: TOvcTCString;
    colTranStatementDetails: TOvcTCString;
    colTranCodedBy: TOvcTCString;
    colTranAmount: TOvcTCNumericField;
    treView: TTreeView;
    pnlMessage: TPanel;
    colReference: TOvcTCString;
    colAnalysis: TOvcTCString;
    popMatchTran: TPopupMenu;
    mnuMatchStatementDetails: TMenuItem;
    eStatementDetails: TMemo;
    lblMatchingTranNote: TLabel;

    procedure cRefClick(Sender: TObject);
    procedure cPartClick(Sender: TObject);
    procedure cOtherClick(Sender: TObject);
    procedure cCodeClick(Sender: TObject);
    procedure tblSplitActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tblSplitEnter(Sender: TObject);
    procedure tblSplitExit(Sender: TObject);
    procedure tblSplitGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblSplitBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblSplitEndEdit(Sender: TObject; Cell: TOvcTableCellAncestor;
      RowNum, ColNum: Integer; var AllowIt: Boolean);
    procedure tblSplitUserCommand(Sender: TObject; Command: Word);
    procedure tblSplitDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure ColAcctKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbValueChange(Sender: TObject);
    procedure tblSplitGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblSplitActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure sbtnChartClick(Sender: TObject);
    procedure sbtnPayeeClick(Sender: TObject);
    procedure ColAcctKeyPress(Sender: TObject; var Key: Char);
    procedure ColGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure chkMasterClick(Sender: TObject);
    procedure ColAcctOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure cNotesClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chkStatementDetailsClick(Sender: TObject);
    procedure cValueClick(Sender: TObject);
    procedure nValueChange(Sender: TObject);
    procedure nValueKeyPress(Sender: TObject; var Key: Char);
    procedure ColAmountKeyPress(Sender: TObject; var Key: Char);
    procedure ColGSTCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tblSplitEnteringRow(Sender: TObject; RowNum: Integer);
    procedure LookupGSTClass1Click(Sender: TObject);
    procedure CopyContentoftheCellAbove1Click(Sender: TObject);
    procedure AmountApplyRemainingAmount1Click(Sender: TObject);
    procedure FixedAmount1Click(Sender: TObject);
    procedure PercentageofTotal1Click(Sender: TObject);
    procedure tblSplitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColAcctKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ColAcctExit(Sender: TObject);
    procedure ColPayeeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure ColPayeeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnSuperClick(Sender: TObject);
    procedure chkAccountSystemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure popMemPopup(Sender: TObject);
    procedure ClearSuperfundDetails1Click(Sender: TObject);
    procedure cbFromClick(Sender: TObject);
    procedure cbToClick(Sender: TObject);
    procedure sbtnJobClick(Sender: TObject);
    procedure eDateFromDblClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure RowtmrTimer(Sender: TObject);
    procedure cbMinusChange(Sender: TObject);
    procedure tmrPayeeTimer(Sender: TObject);
    procedure btnShowMoreOptionsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure colTranDateOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colTranAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colTranStatementDetailsOwnerDraw(Sender: TObject;
      TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colTranCodedByOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure tblTranGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblTranActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblTranGetCellAttributes(Sender: TObject; RowNum, ColNum: Integer;
      var CellAttr: TOvcCellAttributes);
    procedure cCodeExit(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure cEntryClick(Sender: TObject);
    procedure eStatementDetailsChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure tblTranMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuMatchStatementDetailsClick(Sender: TObject);
    procedure cbAccountingChange(Sender: TObject);
    procedure tblSplitKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    PopulatePayee : boolean;
    AltLineColor : integer;
    tblSplitInEdit : boolean;
    SplitData : TSplitArray;
    RemovingMask : boolean;
    ExistingCode: string;
    Loading : boolean; //set to true when loading values into form.  Stop onClick events being fired
    GSTClassEditable       : Boolean;
    fCalledFromRecommendedMems: boolean;
    PayeeUsed: boolean;

    AmountToMatch : Money;
    AmountMultiplier : integer;
    SourceTransaction : pTransaction_Rec;
    FTaxName : String;
    FCountry : Byte;
    FsuperTop, FSuperLeft: Integer;
    AllowMasterMemorised: boolean;
    EditMem :TMemorisation;
    EditMemorisedList: TMemorisations_List;
    WasAmount: Double;
    WasType: Byte;
    tmrRow: Integer;
    tmrCol: Integer;
    fDlgEditMode: TDlgEditMode;
    fShowMoreOptions : boolean;
    fMemTranSortedList : TMemTranSortedList;

    fBankAccount : TBank_Account;
    fBankPrefix : string;

    fTempString : string;
    fTempAmount : double;
    fTempSuggMem : pMemTranSortedListRec;

    fMasterTreeThread : TMasterTreeThread;
    fMasterMemList : TObjectList;
    fWorkerMem : TMemorisation;

    fDirty : boolean;
    ffrmSpinner : TfrmSpinner;
    FIssueHint : THintWindow;
    fAllowRefreshTran : boolean;
    fCopied : boolean;

    function GetCellRect(const RowNum, ColNum: Integer): TRect;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMVScroll(var Msg : TWMScroll); message WM_VSCROLL;

    procedure UpdateFields(RowNum : integer);
    procedure UpdateTotal;
    function  OKtoPost() : boolean;
    procedure RemoveBlankLines;
    procedure CompleteAmount;
    procedure CalcRemaining(var Fixed, TotalPerc, RemainingPerc, RemainingDollar : Money;
                            var HasDollarLines, HasPercentLines : boolean);
    procedure DoGSTLookup;
    procedure DoPayeeLookup;
    procedure DoJobLookup;

    procedure SetFirstLineDefaultAmount;

    procedure DoDeleteCell;
    procedure DoDitto;
    procedure DoSuperEdit;
    procedure DoSuperClear;
    function SplitLineIsValid(LineNo: integer): boolean;
    procedure ApplyAmountShortcut(Key: Char);
    procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
    procedure ShowTranPopUp( x, y : Integer; PopMenu :TPopUpMenu );
    function HasPayees: Boolean;
    function HasJobs: Boolean;
    procedure SetAccountingSystem(const Value: Integer);
    function GetAccountingSystem: Integer;
    procedure LocaliseForm;
    procedure PopulateDataFromPayee(PayeeCode: integer; ChangeActiveCol: boolean = True);
    procedure PopulateCmbType(BA: TBank_Account; EntryType: byte);
    function GetTxTypeFromCmbType(ItemIndex: integer = -1): byte;

    procedure ReadCellforPaint(RowNum, ColNum : integer; var Data : pointer);
    procedure DrawtAccountOnTranCell(TableCanvas: TCanvas;
                                     const CellRect: TRect;
                                     RowNum, ColNum: Integer;
                                     const CellAttr: TOvcCellAttributes;
                                     aValue : pMemTranSortedListRec;
                                     var DoneIt: Boolean);
    procedure DrawTextOnTranCell(TableCanvas: TCanvas;
                                 const CellRect: TRect;
                                 RowNum, ColNum: Integer;
                                 const CellAttr: TOvcCellAttributes;
                                 aValue : string;
                                 var DoneIt: Boolean;
                                 aHasPotentialIssue : boolean = false);
  protected
    procedure SetShowMoreOptions(aValue : Boolean);
    procedure RefreshAccTranControls();

    procedure SetDlgEditMode(aValue : TDlgEditMode);
    procedure UpdateMoreOptions();
    procedure UpdateControls();
    procedure RefreshMemTransactions();
    procedure RefreshMasterMemTree();
    procedure AfterFillMasterMemEvent();
    procedure TerminateMasterThread();

    procedure ShowIssueHint(const RowNum, ColNum: Integer);
    procedure HideIssueHint();

    procedure SetAccount(aAccount : TBank_Account);
  public
    procedure FillData(aMem : TMemorisation);
    procedure FillSplitData(aMem : TMemorisation);
    procedure SaveToMemRec(var pM : TMemorisation; pT : pTransaction_Rec; IsMaster: Boolean; var aNunOfSplitLines : integer; ATempMem: boolean = false);

    property AccountingSystem: Integer read GetAccountingSystem write SetAccountingSystem;
    property DlgEditMode: TDlgEditMode read fDlgEditMode write SetDlgEditMode;
    property BankPrefix : string read fBankPrefix write fBankPrefix;
    property CalledFromRecommendedMems: boolean read fCalledFromRecommendedMems write fCalledFromRecommendedMems;

    property BankAccount : TBank_Account read fBankAccount write SetAccount;
    property Copied : boolean read fCopied write fCopied;
    property ShowMoreOptions : boolean read fShowMoreOptions write SetShowMoreOptions;
  end;

  function CreateMemorisation(BA : TBank_Account;
                              pM : TMemorisation;
                              FromRecommendedMems: boolean = false;
                              aCopied : boolean = false;
                              aShowMoreOptions : boolean = false;
                              aPrefix : string = ''): boolean;
  function MemoriseEntry(aBankAccount: TBank_Account;
                         aTrans: pTransaction_Rec;
                         var aIsAMasterMem: boolean;
                         aMem: TMemorisation = nil;
                         aFromRecommendedMems: boolean = false;
                         aCopied : boolean = false;
                         aShowMoreOptions : boolean = false;
                         aPrefix : string = ''): boolean;
  function EditMemorisation(aBankAccount: TBank_Account;
                            aMemorisedList: TMemorisations_List;
                            var aMem: TMemorisation;
                            var aDeleteSelectedMem: boolean;
                            aIsCopy: Boolean = False;
                            aCopySaveSeq: integer = -1;
                            aPrefix : string = ''): boolean;
  function AsFloatSort(List: TStringList; Index1, Index2: Integer): Integer;

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  Software,
  bkdateutils,
  ovcConst,
  MaintainGroupsFrm,
  AccountLookupFrm,
  BKHelp,
  bkXPThemes,
  BKMLIO,
  ComboUtils,
  ErrorMoreFrm,
  PayeeLookupFrm,
  updateMF,
  GstLookupFrm,
  WarningMoreFrm,
  InfoMoreFrm,
  Malloc,
  LogUtil,
  ImagesFrm,
  GstCalc32,
  Math,
  mxFiles32,
  mxUtils,
  admin32,
  bkMaskUtils,
  CanvasUtils,
  GenUtils,
  WinUtils,
  StdHints,
  YesNoDlg,
  ECollect,
  MemUtils,
  CountryUtils,
  SystemMemorisationList,
  SYDEFS,
  AuditMgr,
  BKtxIO,
  PayeeObj,
  PayeeRecodeDlg,
  SuggestedMems,
  Files,
  bkBranding,
  NewHints,
  trxList32;

CONST
  {table command const}
  tcLookup         = ccUserFirst + 1;
  tcDeleteCell     = ccUserFirst + 2;
  tcComplete       = ccUserFirst + 3;
  tcGSTLookup      = ccUserFirst + 4;
  tcDitto          = ccUserFirst + 5;
  tcPayeeLookup    = ccUserFirst + 6;
  tcSuperEdit      = ccUserFirst + 7;
  tcSuperClear     = ccUserFirst + 8;
  tcJobLookup      = ccUserFirst + 9;

  {Mem Tran Table Consts}
  mtDate             = 0;
  mtReference        = 1;
  mtAnalysis         = 2;
  mtAccount          = 3;
  mtAmount           = 4;
  mtStatementDetails = 5;
  mtCodedBy          = 6;

  //Column Nos
  AcctCol      = 0;
  DescCol      = 1;
  NarrationCol = 2;
  PayeeCol     = 3;
  JobCol       = 4;
  GSTCodeCol   = 5;
  AmountCol    = 6;
  PercentCol   = 7;
  TypeCol      = 8;

  mrCopy   = mrRetry;
  mrDelete = mrYes;

  DT_OPTIONS_STR = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
  DT_OPTIONS_INT = DT_RIGHT or DT_VCENTER or DT_SINGLELINE;

const
  UnitName = 'MEMORISEDLG';

var
  DebugMe  : boolean = false;
  sDOLLAR  : string[1] = '$';
  sPERCENT : string[1] = '%';

//------------------------------------------------------------------------------
function CreateMemorisation(BA : TBank_Account;
                            pM : TMemorisation;
                            FromRecommendedMems : boolean;
                            aCopied : boolean;
                            aShowMoreOptions : boolean;
                            aPrefix : string): boolean;
var
  tr : pTransaction_Rec;
  IsAMasterMem : boolean;
begin
  // Create new transaction from provided details, which we will pass into EditMemorisation, which
  // has been designed expecting a transaction to provide it with details
  tr := Create_New_Transaction;

  try
    tr.txStatement_Details  := pM.mdFields.mdStatement_Details;
    tr.txType               := pM.mdFields.mdType;

    IsAMasterMem := pM.mdFields.mdFrom_Master_List; // this value is not used

    result := MemoriseEntry(BA, tr, IsAMasterMem, pM, FromRecommendedMems, aCopied, aShowMoreOptions, aPrefix);
  finally
    Dispose_Transaction_Rec( tr );
  end;
end;

//------------------------------------------------------------------------------
function MemoriseEntry(aBankAccount: TBank_Account;
                       aTrans: pTransaction_Rec;
                       var aIsAMasterMem: boolean;
                       aMem: TMemorisation;
                       aFromRecommendedMems: boolean;
                       aCopied : boolean;
                       aShowMoreOptions : boolean;
                       aPrefix : string) : boolean;
var
  MemDlg : TdlgMemorise;
  Memorised_Trans : TMemorisation;
  MasterMemList : TMemorisations_List;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  NunOfSplitLines : integer;
begin
  result := false;
  aIsAMasterMem := false;

  if not Assigned(aTrans) then
    exit;

  MemDlg := TdlgMemorise.Create(Application.MainForm);
  try
    MemDlg.Loading := true;
    MemDlg.ShowMoreOptions := aShowMoreOptions;

    if aCopied then
    begin
      if aMem.mdFields.mdFrom_Master_List then
        MemDlg.DlgEditMode := demMasterCopy
      else
        MemDlg.DlgEditMode := demCopy;
    end
    else
      MemDlg.DlgEditMode := demCreate;

    MemDlg.CalledFromRecommendedMems := aFromRecommendedMems;

    MemDlg.PopulateCmbType(aBankAccount, aTrans.txType);

    BKHelpSetUp(MemDlg, BKH_Chapter_5_Memorisations);

    if Assigned(aBankAccount) then
      MemDlg.BankAccount := aBankAccount;

    MemDlg.EditMem := nil;
    MemDlg.EditMemorisedList := nil;

    if Assigned(aBankAccount) and ((aBankAccount.IsManual and MemDlg.chkMaster.Enabled) or MemDlg.BankAccount.IsAForexAccount) then
    begin
      MemDlg.chkMaster.Enabled := False;
      MemDlg.AllowMasterMemorised := False;
    end;

    MemDlg.LocaliseForm;

    if MemDlg.chkMaster.Enabled then
    begin
      MemDlg.AccountingSystem := MyClient.clFields.clAccounting_System_Used;
    end;

    MemDlg.GSTClassEditable := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

    MemDlg.cmbType.ItemIndex := MemDlg.cmbType.Items.IndexOfObject(TObject(aTrans^.txType));

    MemDlg.eRef.text      := aTrans^.txReference;

    //only use first line
    if Pos( #13, aTrans^.txNotes) > 0 then
      MemDlg.eNotes.Text := Copy( aTrans^.txNotes, 1, Pos( #13, aTrans^.txNOtes) -1)
    else
      MemDlg.eNotes.text := aTrans^.txNotes;

    MemDlg.AmountToMatch := aTrans^.txAmount;

    if MemDlg.AmountToMatch < 0 then
    begin
      MemDlg.AmountMultiplier := -1;
      MemDlg.cbMinus.ItemIndex := 0;
    end
    else
    begin
      MemDlg.AmountMultiplier := 1;
      MemDlg.cbMinus.ItemIndex := 1;
    end;

    MemDlg.nValue.AsFloat := GenUtils.Money2Double( MemDlg.AmountToMatch) * MemDlg.AmountMultiplier;

    case MyClient.clFields.clCountry of
      whNewZealand : begin
        MemDlg.eOther.Text   := aTrans^.txOther_Party;
        MemDlg.eCode.Text    := aTrans^.txAnalysis;
        MemDlg.ePart.text    := aTrans^.txParticulars;
        MemDlg.eStatementDetails.Text := StringReplace(aTrans^.txStatement_Details, '&&', '&', [rfReplaceAll]);
      end;
      whAustralia, whUK : begin
        MemDlg.eCode.Text    := aTrans^.txParticulars; { Shows the Bank Type Information }
        MemDlg.eOther.Text   := '';
        MemDlg.ePart.Text    := '';
        MemDlg.eStatementDetails.Text := StringReplace(aTrans^.txStatement_Details, '&&', '&', [rfReplaceAll]);
      end;
    end;

    //initialise form
    MemDlg.tblSplitInEdit  := false;

    //init data, Filled in Create
    MemDlg.SplitData[1].Amount := 100.0;

    //set init values
    MemDlg.cmbValue.ItemIndex := -1;
    MemDlg.UpdateTotal;

    MemDlg.SourceTransaction := aTrans;

    MemDlg.Copied := aCopied;
    if MemDlg.Copied then
    begin
      MemDlg.BankPrefix := aPrefix;
      MemDlg.FillData(aMem);
    end;

    if Assigned(aMem) then
      MemDlg.FillSplitData(aMem);

    MemDlg.Loading := false;

    //**************************
    if MemDlg.ShowModal = mrOK then
    begin
    //**************************
      //{have enough data to create a memorised entry record

       //have details of the new master memorisation, now need to update to relevant location
      if (MemDlg.DlgEditMode in ALL_MASTER) and Assigned(AdminSystem) then
      begin
        Memorised_Trans := TMemorisation.Create(SystemAuditMgr);
        //memorise to relevant master file then reload to get new global list
        if Assigned(aBankAccount) then
          MemDlg.BankPrefix := mxFiles32.GetBankPrefix( aBankAccount.baFields.baBank_Account_Number);

        //--ADD MASTER MEM---
        if LoadAdminSystem(true, 'MemoriseEntry') then
        begin
          MemDlg.SaveToMemRec(Memorised_Trans, aTrans, True, NunOfSplitLines);
          SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(MemDlg.BankPrefix);
          if not Assigned(SystemMemorisation) then
          begin
            MasterMemList := TMemorisations_List.Create(SystemAuditMgr);
            try
              SystemMemorisation := AdminSystem.SystemMemorisationList.AddMemorisation(MemDlg.BankPrefix, MasterMemList);
            finally
              MasterMemList.Free;
            end;
          end;
          MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);
          //insert into list
          Memorised_Trans.mdFields.mdFrom_Master_List := true;
          Memorised_Trans.mdFields.mdAmount := abs(Memorised_Trans.mdFields.mdAmount) * MemDlg.AmountMultiplier;
          MasterMemList.Insert_Memorisation(Memorised_Trans);
          aIsAMasterMem := True;
          //*** Flag Audit ***
          SystemAuditMgr.FlagAudit(arMasterMemorisations);
          SaveAdminSystem;
        end
        else
          HelpfulErrorMsg('Could not add master memorisation at this time. Admin System unavailable.', 0);
      end
      else
      begin
        Memorised_Trans := TMemorisation.Create(MyClient.ClientAuditMgr);
        MemDlg.SaveToMemRec(Memorised_Trans, aTrans, False, NunOfSplitLines);
        Memorised_Trans.mdFields.mdAmount := abs(Memorised_Trans.mdFields.mdAmount) * MemDlg.AmountMultiplier;
        aBankAccount.baMemorisations_List.Insert_Memorisation(Memorised_Trans);
      end;

      if aTrans^.txDate_Transferred <> 0 then
        HelpfulInfoMsg('The transaction was memorised OK.' + #13+#13+
                       'The transaction had already been transferred '+
                       'into your accounting software so the code won''t change '+
                       'when you close this dialog.  All future transactions that match the cr'+
                       'iteria you entered will be coded automatically.',0);

      Result := true;
    end; {execute}
  finally
    FreeAndNil(MemDlg);
  end;
end;

//------------------------------------------------------------------------------
function EditMemorisation(aBankAccount: TBank_Account;
                          aMemorisedList: TMemorisations_List;
                          var aMem: TMemorisation;
                          var aDeleteSelectedMem: boolean;
                          aIsCopy: Boolean;
                          aCopySaveSeq: integer;
                          aPrefix : string): boolean;
const
  ThisMethodName = 'EditMemorisation';

var
  SystemMemorisation : pSystem_Memorisation_List_Rec;
  MemDlg : TdlgMemorise;
  i : integer;
  MemLine : pMemorisation_Line_Rec;
  Memorised_Trans : TMemorisation;
  SaveSeq : integer;
  pM_SequenceNo : integer;
  FormResult : Integer;
  pMCopy : TMemorisation;
  LineIndex : integer;
  CodedTo   : string;
  MemDesc   : string;
  CodeType  : string;
  NunOfSplitLines : integer;

  //----------------------------------------------------------------------------
  procedure ReplaceMem(var aMem: TMemorisation; const aMemSequenceNo: integer);
  var
    MemList : TMemorisations_List;
    MemIndex : integer;
    Mem : TMemorisation;
  begin
    MemList := TMemorisations_List(SystemMemorisation.smMemorisations);
    for MemIndex := MemList.First to MemList.Last do
    begin
      Mem := MemList.Memorisation_At(MemIndex);
      if not assigned(Mem) then
        continue;
      if (Mem.mdFields.mdSequence_No <> aMemSequenceNo) then
        continue;
      aMem := Mem;
    end;
  end;

begin
  Result := false;
  if not Assigned(aMem) then
    Exit;

  MemDlg := TdlgMemorise.Create(Application.MainForm);
  try
    MemDlg.Loading := true;
    MemDlg.EditMem := aMem;
    if aMem.mdFields.mdFrom_Master_List then
      MemDlg.DlgEditMode := demMasterEdit
    else
      MemDlg.DlgEditMode := demEdit;

    MemDlg.PopulateCmbType(aBankAccount, aMem.mdFields.mdType);
    BKHelpSetUp(MemDlg, BKH_Chapter_5_Memorisations);

    MemDlg.EditMemorisedList := aMemorisedList;
    MemDlg.ExistingCode := '';
    //Controls will be initialise in the FormCreate method
    //load memorisation into form

    if (aBankAccount = nil) then
      MemDlg.BankPrefix := aPrefix
    else
      MemDlg.BankAccount := aBankAccount;

    MemDlg.LocaliseForm;

    MemDlg.FillData(aMem);

    MemDlg.UpdateControls();

    //fill detail
    MemDlg.FillSplitData(aMem);

    //Show Total Line
    MemDlg.UpdateTotal;

    MemDlg.AllowMasterMemorised := False; // Sounds wrong, but also used for 'Can I Change MasterMem'.. You Cannot ...
    // Don't show 'Copy to New' if we've come from recommended mems
    //turn off editing of gst col if master
    //or if using Ledger Elite

    MemDlg.GSTClassEditable := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

    if MemDlg.DlgEditMode in ALL_MASTER then
      MemDlg.GSTClassEditable := False;

    if not MemDlg.GSTClassEditable then
      MemDlg.ColGSTCode.Font.Color := clGrayText;

    MemDlg.SourceTransaction := nil;

    MemDlg.Loading := false;
    //**********************
    FormResult := MemDlg.ShowModal();

    case FormResult of
      mrok : begin
        //save new values back
        if (MemDlg.DlgEditMode in ALL_MASTER) and Assigned(AdminSystem) then
        begin
          //---EDIT MASTER MEM---
          if aCopySaveSeq = -1 then
            SaveSeq := aMem.mdFields.mdSequence_No
          else
            SaveSeq := aCopySaveSeq;

          // WORKAROUND:
          pM_SequenceNo := aMem.mdFields.mdSequence_No;

          if LoadAdminSystem(true, ThisMethodName) then
          begin
            SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(MemDlg.BankPrefix);
            if not Assigned(SystemMemorisation) then
            begin
              UnlockAdmin;
              HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
              Exit;
            end
            else if not Assigned(SystemMemorisation.smMemorisations) then
            begin
              UnlockAdmin;
              HelpfulErrorMsg('The master memorisation can no longer be found in the Admin System.', 0);
              Exit;
            end
            else
            begin
              // WORKAROUND:
              ReplaceMem(aMem, pM_SequenceNo);

              MemDlg.EditMemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
              //Find and save memorisation
              for i := MemDlg.EditMemorisedList.First to MemDlg.EditMemorisedList.Last do
              begin
                Memorised_Trans := MemDlg.EditMemorisedList.Memorisation_At(i);
                if Assigned(Memorised_Trans) then
                begin
                  if (Memorised_Trans.mdFields.mdSequence_No = SaveSeq) then
                  begin
                    MemDlg.SaveToMemRec(Memorised_Trans, nil, MemDlg.DlgEditMode in ALL_MASTER, NunOfSplitLines);
                    Break;
                  end;
                end;
              end;
              //*** Flag Audit ***
              SystemAuditMgr.FlagAudit(arMasterMemorisations);
              SaveAdminSystem;
            end;
          end
          else
            HelpfulErrorMsg('Could not update master memorisation at this time. Admin System unavailable.', 0);
        end
        else
        begin
          MemDlg.SaveToMemRec(aMem, nil, MemDlg.DlgEditMode in ALL_MASTER, NunOfSplitLines);
        end;

        Result := true;
      end;

      mrCopy : begin
        // Create memorisation
        pMCopy := TMemorisation.Create(MyClient.ClientAuditMgr);
        try
          MemDlg.SaveToMemRec(pMCopy, nil, ((MemDlg.DlgEditMode in ALL_MASTER) and (Assigned(AdminSystem))), NunOfSplitLines);

          if ((MemDlg.DlgEditMode in ALL_MASTER) and (Assigned(AdminSystem))) then
            pMCopy.mdFields.mdFrom_Master_List := true;

          MemDlg.FillSplitData(pMCopy);

          // OK pressed, and insert mem?
          Result := CreateMemorisation(aBankAccount, pMCopy, false, true, MemDlg.ShowMoreOptions, MemDlg.BankPrefix);
        finally
          FreeAndNil(pMCopy);
        end;
      end;

      mrDelete : begin
        CodedTo := '';
        for LineIndex := aMem.mdLines.First to aMem.mdLines.Last do
        begin
          MemLine := aMem.mdLines.MemorisationLine_At(LineIndex);
          if MemLine^.mlAccount <> '' then
            CodedTo := CodedTo + MemLine^.mlaccount+ ' ';
        end;
        CodeType := MyClient.clFields.clShort_Name[aMem.mdFields.mdType];
        MemDesc := #13 +'Coded To '+CodedTo + #13 + 'Entry Type is '+IntToStr(aMem.mdFields.mdType) + ':' + CodeType;

        if aMem.mdFields.mdFrom_Master_List then
          LogUtil.LogMsg(lmInfo, UnitName, 'User Deleted Master Memorisation '+ MemDesc)
        else
          LogUtil.LogMsg(lmInfo, UnitName, 'User Deleted Memorisation '+ MemDesc);

        if aMem.mdFields.mdFrom_Master_List then
          aDeleteSelectedMem := True
        else
          aBankAccount.baMemorisations_List.DelFreeItem(aMem);

        Result := True;
      end
      else if aIsCopy then
      begin
        //need to remove the copy..
        if aMem.mdFields.mdFrom_Master_List then
        begin
          aMemorisedList.DelFreeItem(aMem);
          if (MemDlg.ModalResult <> mrCancel) then
            aDeleteSelectedMem := True;
        end
        else
        begin
          aBankAccount.baMemorisations_List.DelFreeItem(aMem);
        end;
        Result := True;
      end;
    end;

  finally
    FreeAndNil(MemDlg);
  end;
end;

//------------------------------------------------------------------------------
{ TMasterTreeThread }
procedure TMasterTreeThread.AddToMasterMemList(aLevel : integer; aName : string);
var
  NewMasterMemItem : TMasterMemItem;
begin
  NewMasterMemItem := TMasterMemItem.Create();
  NewMasterMemItem.Level := aLevel;
  NewMasterMemItem.Name  := aName;

  fMasterMemList.Add(NewMasterMemItem);
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.InitlizeVars;
begin
  fProcessStage := msgInstitution;
  fProcessStep  := mstInitilize;

  fClientCount := 0;
  fClientIndex := 0;
  fAccountCount := 0;
  fAccountIndex := 0;
  fAccountInstitutions := '';
  fFoundFirstClientAccount := false;
  fFoundFirstAccount := false;
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.ClientInitilizeStep();
begin
  // Sets up the client Count and Index for the next steps
  fClientIndex := -1;
  fClientCount := AdminSystem.fdSystem_Client_File_List.ItemCount;
  if fClientCount = 0 then
  begin
    fProcessStage := msgFinished;
    fProcessStep := mstFinished;
  end
  else
  begin
    fProcessStep := mstProcessClient;
    if fProcessStage = msgMasterList then
    begin
      fAccountInstitutions := StringReplace(fInstitutionList.CommaText, ',', ', ', [rfReplaceAll]);
      fAccountInstitutions := BankPrefix + ' (' + StringReplace(fAccountInstitutions, '"', '', [rfReplaceAll]) + ')';
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.ClientProcessStep();
var
  ClientFileRec : pClient_File_Rec;
begin
  // does 1 itteration through the Client Loop

  if Assigned(fCltClient) then
    FreeAndNil(fCltClient);

  inc(fClientIndex);
  if fClientIndex > (fClientCount-1) then
  begin
    if fProcessStage = msgInstitution then
    begin
      fProcessStage := msgMasterList;
      fProcessStep := mstInitilize;
    end
    else if fProcessStage = msgMasterList then
    begin
      fProcessStage := msgFinished;
      fProcessStep := mstFinished;
    end;

    Exit;
  end;

  ClientFileRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(fClientIndex);

  if ClientFileRec^.cfForeign_File then
    Exit;

  OpenAClientForRead( ClientFileRec^.cfFile_Code, fCltClient );

  if not Assigned(fCltClient) then
    Exit;

  if fCltClient.clExtra.ceBlock_Client_Edit_Mems then
    Exit;

  if (ApplyToAccSystem) and
     (AccountSystemAppliedto <> fCltClient.clFields.clAccounting_System_Used) then
    Exit;

  fAccountCount := fCltClient.clBank_Account_List.ItemCount;
  if fAccountCount > 0 then
  begin
    fAccountIndex := -1;
    fFoundFirstClientAccount := false;
    fProcessStep := mstProcessAccount;
  end;
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.AccountProcessStep();
var
  BankAcc : TBank_Account;
  SearchPrefix : string;
  AccountRec : pSystem_Bank_Account_Rec;
  Institution : string;
begin
  // does 1 itteration through the Account Loop
  inc(fAccountIndex);
  if fAccountIndex > (fAccountCount-1) then
  begin
    fProcessStep := mstProcessClient;
    Exit;
  end;

  BankAcc := fCltClient.clBank_Account_List.Bank_Account_At(fAccountIndex);

  if not BankAcc.baFields.baApply_Master_Memorised_Entries then
    Exit;

  SearchPrefix := mxFiles32.GetBankPrefix(BankAcc.baFields.baBank_Account_Number);

  if BankPrefix <> SearchPrefix then
    Exit;

  if fProcessStage = msgInstitution then
  begin
    // Builds up a list of institutions
    AccountRec := AdminSystem.fdSystem_Bank_Account_List.FindCode(BankAcc.baFields.baBank_Account_Number);
    if assigned(AccountRec) then
    begin
      Institution := AccountRec^.sbInstitution;
      if trim(Institution) = '' then
        Exit;

      if fInstitutionList.IndexOf( Institution) = - 1 then
        fInstitutionList.Add( Institution);
    end;
  end
  else if fProcessStage = msgMasterList then
  begin
    // builds up a tree list of Institutions -> Clients -> Accounts
    if (not fFoundFirstClientAccount) or (not fFoundFirstAccount) then
    begin
      if (not fFoundFirstAccount) then
      begin
        AddToMasterMemList(1, fAccountInstitutions);
        fFoundFirstAccount := true;
      end;

      if (not fFoundFirstClientAccount) then
        AddToMasterMemList(2, fCltClient.clFields.clCode);

      fFoundFirstClientAccount := true;
    end;

    if (fFoundFirstAccount and fFoundFirstClientAccount) then
      AddToMasterMemList(3, BankAcc.baFields.baBank_Account_Number);
  end;
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.FinishedEvent;
begin
  fDoneThreadEvent();
end;

//------------------------------------------------------------------------------
procedure TMasterTreeThread.Execute;
var
  Finished : boolean;
begin
  inherited;

  FreeOnTerminate := True;
  Finished := false;
  InitlizeVars();

  // Most of the code being called is external to the thread and that is the reason
  // for all the Synchronise calls
  fInstitutionList := TStringList.Create;
  try
    while (not Terminated) and (not Finished) do
    begin
      if Assigned(fMasterMemList) then
      begin
        case fProcessStep of
          mstInitilize : Synchronize(Self, ClientInitilizeStep);
          mstProcessClient : Synchronize(Self, ClientProcessStep);
          mstProcessAccount : Synchronize(Self, AccountProcessStep);
          mstFinished : begin
            try
              if Assigned(fDoneThreadEvent) then
                Synchronize(Self, FinishedEvent);
            finally
              Finished := true;
            end;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(fInstitutionList);
  end;

  Terminate;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.FormCreate(Sender: TObject);
var
  i : Integer;
  W : Integer;
begin
  fAllowRefreshTran := false;
  fMemTranSortedList := TMemTranSortedList.Create();
  fCalledFromRecommendedMems := False;
  PayeeUsed := False;
  bkXPThemes.ThemeForm(Self);

  for i := Low(SplitData) to High(SplitData) do
  begin
    ClearWorkRecDetails(@SplitData[i]);
  end;

  bkBranding.StyleOvcTableGrid(tblSplit);
  bkBranding.StyleTableHeading(header);
  bkBranding.StyleAltRowColor(AltLineColor);

  bkBranding.StyleOvcTableGrid(tblTran);
  bkBranding.StyleTableHeading(tranHeader);

  fBankAccount := nil;

  with MyClient, clFields do
  begin
    if Assigned(AdminSystem) then
    begin
      if AdminSystem.DualAccountingSystem then
      begin
        // fill the Accounting System dropdown ( Only used in Dual system}
        // Make sure they are both there;
        AccountingSystem := AdminSystem.fdFields.fdAccounting_System_Used;
        AccountingSystem := AdminSystem.fdFields.fdSuperfund_System;
        AccountingSystem := MyClient.clFields.clAccounting_System_Used;
      end;
    end;

    case clCountry of
      whNewZealand :
      Begin
        sbtnSuper.Visible := False;
      end;
      whAustralia, whUK :
      Begin
        tblTran.Columns.List[mtAnalysis].Hidden := true;
        cCode.Caption    := '&Bank Type';
        eCode.MaxLength  := 12;

        cPart.Visible    := false;
        ePart.Visible    := false;
        cOther.Visible   := false;
        eOther.Visible   := false;

        cNotes.Top       := cPart.Top;
        eNotes.Top       := ePart.Top;
        cCode.Top        := cOther.Top;
        eCode.Top        := eOther.Top;

        sbtnSuper.Visible :=  CanUseSuperFundFields(MyClient.clFields.clCountry,  MyClient.clFields.clAccounting_System_Used, sfMem);
      end;
    end;
    fShowMoreOptions := false;
    UpdateMoreOptions();
  end;

  if not sbtnSuper.Visible then
  begin
    EditSuperfundDetails1.Visible := False;
    ClearSuperfundDetails1.Visible := False;
  end;

  //Resize for
  Width  := Max( 630, Round( (application.MainForm.Monitor.WorkareaRect.Right - application.MainForm.Monitor.WorkareaRect.Left) * 0.8));
  Height := Max( 450, Round( (application.MainForm.Monitor.WorkareaRect.Bottom - application.MainForm.Monitor.WorkareaRect.Top) * 0.8));



  // Resize the Desc Column to fit the table size
  with tblSplit do begin
     // Now resize the Desc Column to fit the table width
     W := 0;
     for i := 0 to Pred( Columns.Count ) do begin
        if not Columns[i].Hidden then
           W := W + Columns.Width[i];
     end;
     i := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
     W := W + i + 2;
     Columns[ NarrationCol ].Width := Columns[ NarrationCol ].Width + ( Width - W );
  end;
  tblSplitInEdit := false;
  RemovingMask := false;

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_PAYEE_BMP,sBtnPayee.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_SUPER_BMP,sBtnSuper.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_JOB_BMP,sbtnJob.Glyph);

  tblSplit.CommandOnEnter := ccRight;
  tblSplit.RowLimit := GLCONST.Max_mx_Lines +1;

  //set up value grid
  cmbValue.Items.AddObject( mxNames[ mxAmtEqual], TObject( mxAmtEqual));
  cmbValue.Items.AddObject( mxNames[ mxAmtLessThan], TObject( mxAmtLessThan));
  cmbValue.Items.AddObject( mxNames[ mxAmtGreaterThan], TObject( mxAmtGreaterThan));
  cmbValue.Items.AddObject( mxNames[ mxAmtLessOrEqual], TObject( mxAmtLessOrEqual));
  cmbValue.Items.AddObject( mxNames[ mxAmtGreaterOrEqual], TObject( mxAmtGreaterOrEqual));

  with tblSplit.Controller.EntryCommands do
  begin
    {remove F2 functionallity}
    DeleteCommand('Grid',VK_F2,0,0,0);
    DeleteCommand('Grid',VK_F3,0,0,0);
    DeleteCommand('Grid',VK_DELETE,0,0,0);

    {add our commands}
    AddCommand('Grid',VK_F2,0,0,0,tcLookup);
    AddCommand('Grid',VK_F3,0,0,0,tcPayeeLookup);
    AddCommand('Grid',VK_F5,0,0,0,tcJobLookup);
    AddCommand('Grid',VK_F7,0,0,0,tcGSTLookup);
    AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
    AddCommand('Grid',VK_F11,0,0,0,tcSuperEdit);
    AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);
    AddCommand('Grid',VK_ADD,0,0,0,tcDitto);          {+ - NumPad}
    Addcommand('Grid',187,0,0,0,tcComplete);         {'=' to complete amount}
  end;
  SetUpHelp;

  //setup max length of gst-id
  ColGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
  ColAcct.MaxLength    := MaxBk5CodeLen;
  //resize the account col so that longest account code fits
  tblSplit.Columns[ AcctCol ].Width := CalcAcctColWidth( tblSplit.Canvas, tblSplit.Font, 100);

  eDateFrom.Epoch       := BKDATEEPOCH;
  eDateFrom.PictureMask := BKDATEFORMAT;
  eDateTo.Epoch         := BKDATEEPOCH;
  eDateTo.PictureMask   := BKDATEFORMAT;

  FsuperTop := -999;
  FSuperLeft := -999;

  ffrmSpinner := TfrmSpinner.Create(self);

  FIssueHint := THintWindow.Create( Self );
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Font <> '') then
    StrToFont(AdminSystem.fdFields.fdCoding_Font, FIssueHint.Canvas.Font)
  else if (not Assigned(AdminSystem)) and (INI_Coding_Font <> '') then
    StrToFont(INI_Coding_Font, FIssueHint.Canvas.Font)
  else
  begin
    FIssueHint.Canvas.Font.Name := 'Courier';
    FIssueHint.Canvas.Font.Size := 5;
  end;

  fMasterMemList := TObjectList.Create;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.FormDestroy(Sender: TObject);
begin
  if Assigned( FIssueHint ) then
  begin
    if FIssueHint.HandleAllocated then
      FIssueHint.ReleaseHandle;

    FreeAndNil(FIssueHint);
  end;

  treView.Items.Clear;

  FreeAndNil(fMemTranSortedList);
  FreeAndNil(ffrmSpinner);

  if Assigned(fWorkerMem) then
    FreeAndNil(fWorkerMem);

  fMasterMemList.Clear();
  FreeAndNil(fMasterMemList);
  fMasterTreeThread := nil;

  inherited;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
const
  VK_R = 82;
  VK_T = 84;
  VK_A = 65;
  VK_P = 80;
  VK_N = 78;
  VK_B = 66;
begin
  if fShowMoreOptions then
    Exit;

  if (ssAlt in Shift) then
  begin
    if Key = VK_R then
    begin
      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cRefClick(Sender);
    end
    else if Key = VK_T then
    begin
      if MyClient.clFields.clCountry = whAustralia then
        Exit;

      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cOtherClick(Sender);
    end
    else if (Key = VK_B) and (MyClient.clFields.clCountry = whAustralia) then
    begin
      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cCodeClick(Sender);
    end
    else if (Key = VK_A) and (MyClient.clFields.clCountry = whNewZealand) then
    begin
      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cCodeClick(Sender);
    end
    else if Key = VK_P then
    begin
      if MyClient.clFields.clCountry = whAustralia then
        Exit;

      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cPartClick(Sender);
    end
    else if Key = VK_N then
    begin
      fShowMoreOptions := not fShowMoreOptions;
      UpdateMoreOptions();
      cNotesClick(Sender);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eRef.Hint        :=
                    'Change the text or add wild card characters if needed|' +
                    'Change the text or add wild card characters if needed';
   eNotes.Hint      :=
                    'Change the text or add wild card characters if needed|' +
                    'Change the text or add wild card characters if needed.  Max 40 characters|';

   ePart.Hint       := eRef.Hint;

   eOther.Hint      := eRef.Hint;

   eCode.Hint       := eRef.Hint;

   nValue.Hint      :=
                    'Enter the amount to memorise on|'+
                    'Enter the amount to memorise on';
   cRef.Hint        :=
                    'Check to memorise on the contents of the Reference field|' +
                    'Check to memorise on the contents of the Reference field';
   cPart.Hint       :=
                    'Check to memorise on the contents of the Particulars field|' +
                    'Check to memorise on the contents of the Particulars field';
   cOther.Hint      :=
                    'Check to memorise on the contents of the Other Party field|' +
                    'Check to memorise on the contents of the Other Party field';

   case MyClient.clFields.clCountry of
     whNewZealand :
     begin
       cCode.Hint := 'Check to memorise on the contents of the Analysis Code field|' +
                     'Check to memorise on the contents of the Analysis Code field';
     end;
     whAustralia, whUK :
     begin
       cCode.Hint := 'Check to memorise on the contents of the Bank Type field|' +
                     'Check to memorise on the contents of the Bank Type field';
     end;
   end;

   cNotes.Hint      :=
                    'Check to memorise on the contents of the Notes field|';
   cmbValue.Hint    :=
                    'Select to memorise by Value, Percentage or both|' +
                    'Select to memorise by Value, Percentage or both';
   tblSplit.Hint    :=
                    'Enter the details for coding this Memorisation|' +
                    'Enter the details for automatically coding this Memorisation';
   sbtnPayee.Hint   :=
                    STDHINTS.PayeeLookupHint;
   sbtnChart.Hint   :=
                    STDHINTS.ChartLookupHint;
   sbtnJob.Hint     :=
                    STDHINTS.JOBLOOKUPHINT;

   chkMaster.Hint   :=
                    'Check to make this a Master Memorisation|' +
                    'Check to make this a Master Memorisation';

   chkStatementDetails.Hint :=
                    'Check to memorise on the contents of the Statement Details field|' +
                    'Check to memorise on the contents of the Statement Details field';

   cbFrom.Hint   :=
                    'Check to enable a Tranaction date, from which this Memorisation will apply|' +
                    'Check to enable a Tranaction date, from which this Memorisation will apply';
   cbTo.Hint   :=
                    'Check to enable a Tranaction date, until which this Memorisation will apply|' +
                    'Check to enable a Tranaction date, until which this Memorisation will apply';
end;

//------------------------------------------------------------------------------
procedure ToggleEdit(Sender : TObjecT);
begin
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cRefClick(Sender: TObject);
begin
  eRef.enabled := cRef.Checked;

  if not Loading then
  begin
    fDirty := true;
    if eRef.enabled then
      eRef.SetFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cPartClick(Sender: TObject);
begin
  ePart.enabled := cPart.Checked;

  if not Loading then
  begin
    fDirty := true;
    if ePart.enabled then
      ePart.setFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cOtherClick(Sender: TObject);
begin
  eOther.Enabled := cOther.Checked;

  if not Loading then
  begin
    fDirty := true;
    if eOther.enabled then
      eOther.setFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.chkAccountSystemClick(Sender: TObject);
begin
  cbAccounting.Enabled := chkAccountSystem.Checked;

  if not Loading then
  begin
    fDirty := true;
    RefreshAccTranControls();
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cbAccountingChange(Sender: TObject);
begin
  if not Loading then
  begin
    fDirty := true;
    RefreshAccTranControls();
  end;
end;

procedure TdlgMemorise.cbFromClick(Sender: TObject);
begin
  if not Loading then
    fDirty := true;

  eDateFrom.Enabled := cbFrom.Checked;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cbMinusChange(Sender: TObject);
begin
  if not Loading then
    fDirty := true;

  case cbMinus.ItemIndex of
    0: AmountMultiplier := -1;
    1: AmountMultiplier := 1;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cbToClick(Sender: TObject);
begin
  if not Loading then
    fDirty := true;

  eDateTo.Enabled := cbTo.Checked;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cCodeClick(Sender: TObject);
begin
  eCode.Enabled := cCode.Checked;

  if not Loading then
  begin
    fDirty := true;
    if eCode.enabled then
      eCode.setFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cCodeExit(Sender: TObject);
begin
  if fDlgEditMode in ALL_NO_MASTER then
    RefreshMemTransactions();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cEntryClick(Sender: TObject);
begin
  if not Loading then
    fDirty := true;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
var
  Code : string;
begin
  Code := '';

  case ColNum of
    DescCol: case Command of
      ccLeft, ccPageLeft   : ColNum := AcctCol;
      ccRight, ccPageRight : ColNum := NarrationCol;
      ccMouse              : ColNum := AcctCol;
    end;

    PayeeCol, JobCol: begin
      if fDlgEditMode in ALL_MASTER then
      begin
        case Command of
          ccLeft, ccPageLeft   : ColNum := NarrationCol;
          ccRight, ccPageRight : if GSTClassEditable then
                                   ColNum := GSTCodeCol
                                 else
                                   ColNum := AmountCol;
          ccMouse              : ColNum := NarrationCol;
        end;
      end;
    end;

    GSTCodeCol : begin
       if not GSTClassEditable then begin
          case Command of
             ccRight, ccPageRight :  ColNum := AmountCol;
          else
             ColNum := NarrationCol;
          end;
       end;
    end;

    TypeCol :
     case Command of
        ccRight, ccPageRight :
          if RowNum < tblSplit.RowLimit then
          begin
            Inc(RowNum);
            ColNum := AcctCol;
          end;
     else
        ColNum := PercentCol;
     end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.btnOKClick(Sender: TObject);
var
  BA: string;
begin      
  if OKtoPost then
  begin
    // If there is a recommended memorisation
    if fDlgEditMode in ALL_MASTER then
      BA := ''
    else
      BA := fBankAccount.baFields.baBank_Account_Number;

    TerminateMasterThread();

    Modalresult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.btnShowMoreOptionsClick(Sender: TObject);
begin
  fShowMoreOptions := not fShowMoreOptions;
  UpdateMoreOptions();
end;

// The entry type is not stored globally, so the simplest way for us to get
// it is to take it from cmbType, after stripping out the colon and short name.
// If no integer is passed to this method, it will return the currently selected
// item
//------------------------------------------------------------------------------
function TdlgMemorise.GetTxTypeFromCmbType(ItemIndex: integer = -1): byte;
begin
  if (ItemIndex = -1) or (ItemIndex >= cmbType.Items.Count) then
    Result := byte(cmbType.Items.Objects[cmbType.ItemIndex])
  else
    Result := byte(cmbType.Items.Objects[ItemIndex]);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.btnCopyClick(Sender: TObject);
begin
  if fDirty then
  begin
    if AskYesNo('Confirm Copy', 'Any changes to the current memorisation will not be saved.' + #13 +
                'They will be copied across to the new memorisation.' + #13#13 +
                'Please confirm you want to do this.', DLG_NO, 0) = DLG_NO then
    begin
      Exit;
    end;
  end;

  if Assigned(AdminSystem) then
    TerminateMasterThread();

  Modalresult := mrCopy;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.btnDeleteClick(Sender: TObject);
var
  Msg : string;
begin
  if fDlgEditMode in ALL_MASTER then
  begin
    if Assigned(AdminSystem) then
    begin
      Msg := 'Deleting this MASTER Memorisation will remove all coding' +
             ' for entries that match the criteria, which are yet to be' +
             ' transferred or finalised, for ALL clients.';
    end
    else
    begin
      Msg := 'Deleting this MASTER Memorisation will only remove it TEMPORARILY.' +
             ' To delete it permanently it must be deleted at the PRACTICE.';
    end;
  end
  else
    Msg := 'Deleting this Memorisation will remove all coding for entries that match the criteria,' +
           ' which are yet to be transferred or finalised.';

  if AskYesNo('Confirm Delete',
              Msg + #13#13 +
              'Please confirm you wish to delete.', DLG_NO, 0) = DLG_YES then
  begin
    TerminateMasterThread();

    modalresult := mrDelete;  // toDelete
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.btnCancelClick(Sender: TObject);
begin
  TerminateMasterThread();
      
  modalresult := mrCancel;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitEnter(Sender: TObject);
begin
  btnOk.Default := false;
  btnCancel.Cancel := false;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if tblSplitInEdit then
   begin
      Msg.CharCode := vk_f6;
      ColAcct.SendKeyToTable(Msg);
   end;

   btnOK.Default := true;
   btnCancel.Cancel := true;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  zero: Double;
begin
  data := nil;
  zero := 0.0;
  if Purpose = cdpForEdit then btnCancel.cancel := false;

  if (RowNum > 0) and (RowNum <= GLCONST.Max_mx_Lines) then
  Case ColNum of
    AcctCol :
      data := @SplitData[RowNum].AcctCode;

    DescCol:
      data := @SplitData[RowNum].desc;

    NarrationCol:
      data := @SplitData[RowNum].Narration;

    JobCol:
      data := @SplitData[RowNum].JobCode;

    GSTCodeCol:
      data := @SplitData[RowNum].GSTClassCode;

    AmountCol: begin
      if SplitData[RowNum].LineType = mltPercentage then
        data := @zero
      else
        data := @SplitData[RowNum].Amount;
      if Purpose = cdpForEdit then
         WasAmount := SplitData[RowNum].Amount;
    end;

    PercentCol: begin
      if SplitData[RowNum].LineType = mltPercentage then
        data := @SplitData[RowNum].Amount
      else
        data := @zero;
      if Purpose = cdpForEdit then
         WasAmount := SplitData[RowNum].Amount ;
     end;
    TypeCol:
      data := @SplitData[RowNum].LineType;

    PayeeCol:
      data := @SplitData[RowNum].Payee;
  end;
end;

procedure TdlgMemorise.tblSplitKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  if ColNum = GSTCodeCol then
  begin
    if chkMaster.Checked then
    begin
      HelpfulInfoMsg( 'GST cannot be overridden for a memorisation at MASTER level. MASTER memorised entries always apply GST at the default rate for the account in the client''s chart.', 0 );
      AllowIt := False;
      Exit;
    end;
  end;

  if ColNum <> 1 then
    tblSplitInEdit := true;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
var
  tempNo   : integer;
  tempID   : string;
begin
  if not Loading then
    fDirty := true;

  btnCancel.Cancel := false;

  tblSplitInEdit := false;
  WasType :=  SplitData[RowNum].LineType;
  case ColNum of
     GSTCodeCol : begin
        {find the gst class no and the replace the given gst class code to make sure
         that only valid codes are allowed}
        tempId   := Trim(TEdit(ColGSTCode.CellEditor).Text);
        tempNo   := GetGSTClassNo( MyClient, tempId);
        if (trim(tempID) <> '') and (tempNo = 0) then begin
           WinUtils.ErrorSound;
           AllowIt := false;
           tblSplitInEdit := true;  //still editing
        end
        else
          TEdit(ColGSTCode.CellEditor).Text:= GetGSTClassCode( MyClient, tempNo);
     end;
     PayeeCol : begin
        {find the gst class no and the replace the given gst class code to make sure
         that only valid codes are allowed}
        tempNo   := TOvcNumericField( ColPayee.CellEditor).AsInteger;
        if (tempNo <> 0) then
        begin
          if Assigned(MyClient.clPayee_List.Find_Payee_Number(tempNo)) then begin
            if PopulatePayee then            
              PopulateDataFromPayee(tempNo, false);
          end else
          begin
            WinUtils.ErrorSound;
            AllowIt := false;
            tblSplitInEdit := true;  //still editing
          end;
        end;
     end;

     AmountCol: SplitData[RowNum].LineType := pltDollarAmt;
     PercentCol: SplitData[RowNum].LineType := pltPercentage;

  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.DoGSTLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   GSTCode : string;
begin
  if chkMaster.Checked then
  begin
    HelpfulInfoMsg( 'GST cannot be overridden for a memorisation at MASTER level. MASTER memorised entries always apply GST at the default rate for the account in the client''s chart.', 0 );
    Exit;
  end;

  if not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
    exit;

  with tblSplit do
  begin
    if not StopEditingState(True) then
      Exit;

    if (ActiveCol <> GSTCodeCol) then
       ActiveCol := GSTCodeCol;

    InEditOnEntry := InEditingState;
    if not InEditOnEntry then
    begin
      if not StartEditingState then
        Exit;   //returns true if already in edit state
    end;

    GSTCode := TEdit(colGSTCode.CellEditor).Text;
    if PickGSTClass(GSTCode, True) then
    begin
      //if get here then have a valid char from the picklist
      TEdit(colGSTCode.CellEditor).Text := GSTCode;
      Msg.CharCode := VK_RIGHT;
      colGSTCode.SendKeyToTable(Msg);
    end
    else
    begin
      if not InEditOnEntry then
      begin
        StopEditingState(true);  //end edit
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.DoJobLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   JobCode : string;
begin
    with tblSplit do begin
       if not StopEditingState(True) then
          Exit;
       if (ActiveCol <> JobCol) then
          ActiveCol := JobCol;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if already in edit state
       end;

       JobCode := Tedit(colJob.CellEditor).Text;
       if PickJob (JobCode) then begin
           //if get here then have a valid char from the picklist
           Tedit(colJob.CellEditor).Text := JobCode;
           Msg.CharCode := VK_RIGHT;
           colPayee.SendKeyToTable(Msg);
       end else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
    end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
var
  ColNum : integer;
begin
   with tblSplit do begin
      if not StartEditingState then Exit;
      ColNum := ActiveCol;
      case ColNum of
        AcctCol :      TEdit(ColAcct.CellEditor).Text := '';
        NarrationCol : TEdit(ColNarration.CellEditor).Text := '';
        GSTCodeCol :   TEdit(ColGSTCode.CellEditor).Text := '';
        JobCol :       TEdit(ColJob.CellEditor).Text := '';
        AmountCol :    TOvcNumericField( ColAmount.CellEditor).AsFloat := 0.0;
        PercentCol :   TOvcNumericField( ColPercent.CellEditor).AsFloat := 0.0;
        PayeeCol :     TOvcNumericField( ColPayee.CellEditor).AsInteger := 0;
      end;
      StopEditingState( True );
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitUserCommand(Sender: TObject; Command: Word);
var
  Msg   : TWMKey;
  Code  : string;
  HasChartBeenRefreshed : boolean;
begin
  Code := '';

  case Command of
    tcLookup :
      begin
        if not tblSplit.StopEditingState(True) then
           Exit;
        if tblSplitInEdit then
           Code := TEdit(ColAcct.CellEditor).Text
        else
           Code := SplitData[tblSplit.ActiveRow].AcctCode;

        if PickAccount(Code, HasChartBeenRefreshed, nil, true, not ((fDlgEditMode in ALL_MASTER) and Assigned(AdminSystem))) then
        begin
           // got a Code
           if (ExistingCode = '') // new row started and previous row had a payee
           and (tblSplit.ActiveRow > 1)
           and (SplitData[tblSplit.ActiveRow-1].Payee <> 0) then
           begin
             SplitData[tblSplit.ActiveRow].Payee := SplitData[tblSplit.ActiveRow-1].Payee;
             tblSplit.InvalidateCell(tblSplit.ActiveRow, PayeeCol);
           end;
           ExistingCode := Code;
           if tblSplitInEdit then
               TEdit(ColAcct.CellEditor).Text := Code
           else begin
              SplitData[tblSplit.ActiveRow].AcctCode := Code;
              UpdateFields(tblSplit.ActiveRow);
              Msg.CharCode := VK_RIGHT;
              ColAcct.SendKeyToTable(Msg);
           end;
           tblSplit.InvalidateCell(tblSplit.ActiveRow,AcctCol);
           tblSplit.InvalidateCell(tblSplit.ActiveRow,DescCol);
        end;
      end;
    tcGSTLookup : DoGSTLookup;

    tcDeleteCell : DoDeleteCell;

    tcComplete : CompleteAmount;

    tcDitto :
      DoDitto;

    tcPayeeLookup : DoPayeeLookup;
    tcSuperEdit : DoSuperEdit;
    tcJobLookup : DoJobLookup;

    tcSuperClear : DoSuperClear;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblTranActiveCellChanged(Sender: TObject; RowNum, ColNum: Integer);
begin
  HideIssueHint();
  tblTran.Invalidate;

  if (ColNum = mtAccount) then
  begin
    if (RowNum > fMemTranSortedList.ItemCount) then
      Exit;

    if fMemTranSortedList.GetPRec(RowNum-1)^.HasPotentialIssue then
      ShowIssueHint(RowNum, ColNum);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblTranGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (RowNum = tblSplit.LockedRows) then
    Exit;

  if (CellAttr.caColor = tblSplit.Color) then
  begin
    if Odd(RowNum) then
      CellAttr.caColor := clwhite
    else
      CellAttr.caColor := AltLineColor;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblTranGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  if RowNum = 0 then
    Exit;

  ReadCellforPaint(RowNum, ColNum, Data);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblTranMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ColEstimate, RowEstimate : integer;
begin
  if (Button = mbRight) then
  begin
    if tblTran.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then
      exit;

    tblTran.SetFocus;
    tblTran.ActiveRow := RowEstimate;
    tblTran.ActiveCol := ColEstimate;
    ShowTranPopUp( x, y, popMatchTran);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.TerminateMasterThread;
begin
  if Assigned(fMasterTreeThread) then
    if not fMasterTreeThread.Terminated then
      fMasterTreeThread.Terminate;

  fMasterTreeThread := nil;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.ShowIssueHint(const RowNum, ColNum: Integer);
var
  R : TRect;
begin
  HideIssueHint(); // Hide any existing hint

  R := tblTran.BoundsRect;
  R.Top := R.Top + pnlMain.Top + pnlMatchingTransactions.Top;;
  R.Bottom := R.Bottom + pnlMain.Top + pnlMatchingTransactions.Top;;

  // Make sure the mouse is on the form
  if PtInRect( R, ScreenToClient( Mouse.CursorPos ) ) then
  begin
    R := GetCellRect( RowNum, ColNum );
    NewHints.ShowCustomHint( FIssueHint, R, 'Potentially invalid match' );
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.HideIssueHint;
var
  R : TRect;
begin
  if Assigned( FIssueHint ) then
  begin
    if FIssueHint.HandleAllocated then
    begin // Find where the Hint is, so we can redraw the cells beneath it.
      GetWindowRect( FIssueHint.Handle, R );
      R.TopLeft      := tblTran.ScreenToClient(R.TopLeft);
      R.BottomRight  := tblTran.ScreenToClient(R.BottomRight);
      FIssueHint.ReleaseHandle;
      tblTran.AllowRedraw := False;
      tblTran.InvalidateCellsInRect( R );
      tblTran.AllowRedraw := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tmrPayeeTimer(Sender: TObject);
begin
  PopulatePayee := True;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.RowtmrTimer(Sender: TObject);

type
  ChangeMode = (Amount, ToAmount, ToPercent);

 //-----------------------------------------------------------------------------
 function TestAmount: boolean;

     //-------------------------------------------------------------------------
     function HasSFRevenuSplit: Boolean;
     begin
        Result := True;
        if SplitData[tmrRow].SF_Tax_Free_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Tax_Exempt_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Tax_Deferred_Dist <> 0 then Exit;
        if SplitData[tmrRow].SF_Foreign_Income <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Indexed <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Disc <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Other <> 0 then Exit;
        if SplitData[tmrRow].SF_Other_Expenses <> 0 then Exit;
        if SplitData[tmrRow].SF_Interest <> 0 then Exit;
        if SplitData[tmrRow].SF_Capital_Gains_Foreign_Disc <> 0 then Exit;
        if SplitData[tmrRow].SF_Rent <> 0 then Exit;
        if SplitData[tmrRow].SF_Special_Income <> 0 then Exit;
        if SplitData[tmrRow].SF_Foreign_Capital_Gains_Credit <> 0 then Exit;
        // Nothing found
        Result := false;
     end;

     //-------------------------------------------------------------------------
     function EditSuperfund(Mode:ChangeMode): Boolean;
     var Move: TFundNavigation;
         BA: TBank_Account;
         ldata: TmemSplitRec;

         procedure DoToAmount(NewAmount:Money);
         var TotalRate, Remainder: Money;
            procedure MakeAmount(var Value: Money);
            begin
               if Value <> 0 then begin
                  TotalRate := TotalRate + Value;
                  if TotalRate = 1000000 then begin
                     Value := Remainder; // 100% just copy the leftover, stop rounding errors
                  end else begin
                     Value := abs(Double2Money (Percent2Double(Value) * Money2Double(NewAmount)/100));
                  end;
               end;
               Remainder := Remainder - Value;
            end;
         begin
            TotalRate := 0;
            Remainder := abs(NewAmount);
            MakeAmount(ldata.SF_Tax_Free_Dist);
            MakeAmount(ldata.SF_Tax_Exempt_Dist);
            MakeAmount(ldata.SF_Tax_Deferred_Dist);
            MakeAmount(ldata.SF_Foreign_Income);
            MakeAmount(ldata.SF_Capital_Gains_Indexed);
            MakeAmount(ldata.SF_Capital_Gains_Disc);
            MakeAmount(ldata.SF_Capital_Gains_Other);
            MakeAmount(ldata.SF_Capital_Gains_Foreign_Disc);
            MakeAmount(ldata.SF_Other_Expenses);
            MakeAmount(ldata.SF_Interest);
            MakeAmount(ldata.SF_Rent);
            MakeAmount(ldata.SF_Special_Income);
         end;

         //---------------------------------------------------------------------
         procedure DoToPercent(OldAmount:Money);
         var TotalAmount, Remainder: Money;
            procedure MakeAmount(var Value: Money);
            begin
               if Value <> 0 then begin
                  TotalAmount := TotalAmount + Value;
                  if TotalAmount = OldAmount then begin
                     Value := Remainder; // Full amount just copy the leftover, stop rounding errors
                  end else begin
                     Value := Money2Double(Value) / Money2Double(OldAmount) * 1000000;
                  end;
               end;
               Remainder := Remainder - Value;
            end;
         begin
            TotalAmount := 0;
            Remainder := 1000000;
            MakeAmount(ldata.SF_Tax_Free_Dist);
            MakeAmount(ldata.SF_Tax_Exempt_Dist);
            MakeAmount(ldata.SF_Tax_Deferred_Dist);
            MakeAmount(ldata.SF_Foreign_Income);
            MakeAmount(ldata.SF_Capital_Gains_Indexed);
            MakeAmount(ldata.SF_Capital_Gains_Disc);
            MakeAmount(ldata.SF_Capital_Gains_Other);
            MakeAmount(ldata.SF_Capital_Gains_Foreign_Disc);
            MakeAmount(ldata.SF_Other_Expenses);
            MakeAmount(ldata.SF_Interest);
            MakeAmount(ldata.SF_Rent);
            MakeAmount(ldata.SF_Special_Income);
         end;

     begin //EditSuperfund
        Result := false;
        Move := fnNoMove;

        if fDlgEditMode in ALL_MASTER then
           BA := nil
        else
           BA := fBankAccount;

        // Make a temp Copy
        ldata := SplitData[tmrRow];
        // Apply any changes if we can...
        case Mode of
           Amount: ; // fine..
           ToAmount: DoToAmount(Double2Money(SplitData[tmrRow].Amount));
           ToPercent: DoToPercent(Double2Money(WasAmount));
        end;

        if SuperFieldsUtils.EditSuperFields(SourceTransaction,ldata, Move, FSuperTop, FSuperLeft,sfMem, BA) then begin
           // Use the tempdata..
           SplitData[tmrRow] := ldata;
           Result := True;
        end;
     end; //EditSuperfund

  begin //TestAmount
     Result := True;
     if not sbtnSuper.Visible then
        Exit; // No superfund so I don't care...

     if not SplitData[tmrRow].SF_Edited then
        Exit; //No Superfund data ...

     if not HasSFRevenuSplit then
        Exit; // No split .. so I don't care

     case tmrCol of
        AmountCol: if wasType <> pltDollarAmt then begin
               // Mode change to Amount
               if AskYesNo('Confirm Line Type Change',
                  'This line has superfund percentages,'#13'which you are about to changed to amounts'#13#13+
                  'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
               begin
                  Result := EditSuperfund(ToAmount);
               end else begin
                  // Set it back..
                  Result := False;
               end;

            end else begin
               // Was and is amount.. Test for change
               if SplitData[tmrRow].Amount <> WasAmount then begin
                  if AskYesNo('Confirm Line Amount Change',
                        'This line has superfund amounts that should balance.'#13#13+
                        'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
                  begin
                     // Just let the user do it..
                    Result := EditSuperfund(Amount);
                  end else begin
                     // Set it back..
                     Result := False;
                  end;
               end;
            end;
        PercentCol: if Wastype <> pltPercentage then begin
               // Mode change to Percentage
               if AskYesNo('Confirm Line Type Change',
                  'This line has superfund amounts,'#13'which you are about to changed to percentages'#13#13+
                  'Please confirm you want to continue.', DLG_NO, 0) = DLG_YES then
               begin
                  // Convert it first
                  Result := EditSuperfund(ToPercent);
               end else begin
                  // Set it back..
                  Result := False;
               end;
        end;
     end;
  end; //TestAmount

begin //RowtmrTimer
   if RowTmr.Enabled then
      RowTmr.Enabled := False// So I Don't  do it agian
   else
      Exit; // might be handeled in CloseQuery

   if TestAmount then
      // all done..
   else begin
      // Set it back..
      SplitData[tmrRow].Amount := WasAmount;
      SplitData[tmrRow].LineType := WasType;
   end;

   tblSplit.AllowRedraw := false;
   try
      tblSplit.InvalidateRow(tmrRow);
   finally
      tblSplit.AllowRedraw := true;
   end;

   UpdateTotal;
end;//RowtmrTimer

//------------------------------------------------------------------------------
procedure TdlgMemorise.UpdateControls;

  //----------------------------------------------------------------------------
  procedure SetJobPayee(Value: Boolean);
  begin
    sbtnPayee.Enabled := Value;
    sbtnJob.Enabled := Value;
    LookupJob1.Enabled := Value;
    LookupPayee1.Enabled := Value;

    if value then
    begin
      colPayee.Access := otxDefault;
      colJob.Access := otxDefault;
    end
    else
    begin
      colPayee.Access := otxReadOnly;
      colJob.Access := otxReadOnly;
    end;
  end;

begin
  case fDlgEditMode of
    demCreate, demCopy : begin
      Caption := 'Memorisation';
      btnCopy.Visible := false;
      btnDelete.Visible := false;
      btnOk.Caption := 'Cr&eate';
    end;
    demEdit : begin
      Caption := 'Memorisation';
      btnCopy.Visible := true;
      btnDelete.Visible := true;
      btnOk.Caption := 'Updat&e';
    end;
    demMasterCreate, demMasterCopy : begin
      Caption := 'MASTER Memorisation';
      btnCopy.Visible := false;
      btnDelete.Visible := false;
      btnOk.Caption := 'Cr&eate';
    end;
    demMasterEdit : begin
      Caption := 'MASTER Memorisation';
      btnCopy.Visible := true;
      btnDelete.Visible := true;
      btnOk.Caption := 'Updat&e';
    end;
  end;

  if DlgEditMode in ALL_MASTER then
  begin
    if Assigned(AdminSystem) then
    begin
      chkAccountSystem.Visible := AdminSystem.DualAccountingSystem;
      cbAccounting.Visible := chkAccountSystem.Visible;
    end
    else
    begin
      chkAccountSystem.Visible := False;
      cbAccounting.Visible := False;
    end;
    SetJobPayee(False);
  end
  else
  begin
    chkAccountSystem.Visible := False;
    cbAccounting.Visible := False;
    SetJobPayee(True);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.UpdateFields(RowNum: integer);
var
   Acct : pAccount_Rec;
begin
   if not Assigned(myClient) then exit;
   Acct := MyClient.clChart.FindCode(SplitData[RowNum].AcctCode);
   if Assigned(Acct) then
   begin
     SplitData[RowNum].GSTClassCode := GetGSTClassCode( MyClient, Acct^.chGST_Class);
     SplitData[RowNum].Desc         := Acct^.chAccount_Description;
     SplitData[RowNum].GST_Has_Been_Edited := false;
   end
   else
   begin
     SplitData[RowNum].GSTClassCode := '';
     SplitData[RowNum].Desc         := '';
     SplitData[RowNum].GST_Has_Been_Edited := false;
   end;

   if ( SplitData[ RowNum].AcctCode <> '') then
   begin
     if ( SplitData[ RowNum].LineType = -1) then
     begin
       if (RowNum > 1) and ( SplitData[RowNum - 1].LineType <> -1) then
         SplitData[ RowNum].LineType := SplitData[ RowNum - 1].LineType
       else
       begin
         if GetComboCurrentIntObject(cmbValue) = mxAmtEqual then
           SplitData[ RowNum].LineType := mltDollarAmt
         else
           SplitData[ RowNum].LineType := mltPercentage;
       end;
       UpdateTotal;
     end;
   end
   else
   begin
     //blank code, blank type
     SplitData[ RowNum].LineType := mltPercentage;
     UpdateTotal;
   end;

   tblSplit.InvalidateCell(RowNum,GSTCodeCol);  {gst class}
   tblSplit.InvalidateCell(RowNum,DescCol);  {desc}
   tblSplit.InvalidateCell(RowNum,TypeCol);  {type}
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
var
   DefaultClass  : integer;
   SelectedClass : integer;
   APayee        : TPayee;
   PayeeCode     : integer;
   i             : integer;
begin
   Case ColNum of
      AcctCol : begin
        if (ExistingCode = '') and // new row started and previous row had a payee
           (RowNum > 1) and (SplitData[RowNum-1].Payee <> 0) then
        begin
           SplitData[tblSplit.ActiveRow].Payee := SplitData[RowNum-1].Payee;
           tblSplit.InvalidateCell(RowNum, PayeeCol);
        end;
        SplitData[RowNum].AcctCode := Trim(SplitData[RowNum].AcctCode);
        ExistingCode := SplitData[RowNum].AcctCode;

        if fDlgEditMode in ALL_NO_MASTER then
          RefreshMemTransactions();

        UpdateFields(RowNum);
      end;
      AmountCol, PercentCol : begin
         tmrRow := RowNum;
         tmrCol := ColNum;

         RowTmr.Enabled := true;
      end;
      GSTCodeCol : begin
         //see if different to default for chart
         DefaultClass := MyClient.clChart.GSTClass( SplitData[RowNum].AcctCode);
         SelectedClass := GetGSTClassNo( MyClient, SplitData[RowNum].GSTClassCode);
         SplitData[RowNum].GST_Has_Been_Edited := ( DefaultClass <> SelectedClass);
      end;
      TypeCol : begin
         UpdateTotal;
      end;
   end;

   if PayeeUsed then
   begin
     // GST must always be handled if a payee has been used, in case it overrides the default GST class
     PayeeCode := SplitData[RowNum].Payee;
     APayee := MyClient.clPayee_List.Find_Payee_Number(PayeeCode);
     if Assigned(APayee) then
       for i := 0 to APayee.pdLines.ItemCount - 1 do
         SplitData[RowNum+i].GST_Has_Been_Edited := APayee.pdLines.PayeeLine_At(i).plGST_Has_Been_Edited;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.ColAcctKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
   if key = vk_f2 then
   begin
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.SetAccount(aAccount: TBank_Account);
begin
  fBankPrefix := mxFiles32.GetBankPrefix( aAccount.baFields.baBank_Account_Number);
  fBankAccount := aAccount;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.SetAccountingSystem(const Value: Integer);
begin
   if Value = asNone then
      Exit; // Don't care
   SetComboIndexByIntObject(Value,cbAccounting,True);
   if cbAccounting.ItemIndex < 0 then begin
      // Just add it..  Check Country in future?
      cbAccounting.Items.AddObject(saNames[Value], TObject(Value));
      SetComboIndexByIntObject(Value,cbAccounting);
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.SetDlgEditMode(aValue: TDlgEditMode);
begin
  if aValue <> fDlgEditMode then
    fDlgEditMode := aValue;

  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.SetFirstLineDefaultAmount;
begin
  if ( SplitData[1].AcctCode = '') then
  begin
    if  ( GetComboCurrentIntObject(cmbValue) = mxAmtEqual) then
    begin
      SplitData[1].Amount := AmountToMatch/100;
      SplitData[1].LineType := mltDollarAmt;
    end
    else
    begin
      SplitData[1].Amount := 100.0;
      SplitData[1].LineType := mltPercentage;
    end;

    tblSplit.AllowRedraw := false;
    try
      tblSplit.InvalidateRow(1);
    finally
      tblSplit.AllowRedraw := true;
    end;
  end;
  UpdateTotal;
end;

procedure TdlgMemorise.SetShowMoreOptions(aValue: Boolean);
begin
  fShowMoreOptions := aValue;
  UpdateMoreOptions();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.cmbValueChange(Sender: TObject);
begin
  SetFirstLineDefaultAmount;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.CMMouseLeave(var Message: TMessage);
begin
  HideIssueHint();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.WMVScroll(var Msg: TWMScroll);
begin
  HideIssueHint();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.CalcRemaining(var Fixed, TotalPerc, RemainingPerc, RemainingDollar : Money;
                                     var HasDollarLines, HasPercentLines : boolean);
var
  i : integer;
begin
  Fixed := 0;
  TotalPerc := 0;
  RemainingPerc := 0;
  RemainingDollar := 0;

  HasPercentLines := false;
  HasDollarLines  := false;
  for i := 1 to GLCONST.Max_mx_Lines do
  begin
    if (SplitData[i].LineType = pltPercentage) and (SplitData[i].Amount <> 0) then
      HasPercentLines := true;

    if (SplitData[i].LineType = pltDollarAmt) and (SplitData[i].Amount <> 0) then
      HasDollarLines := true;
  end;

  for i := 1 to GLCONST.Max_mx_Lines do
  begin
    if HasDollarLines and ( not HasPercentLines) then
    begin
      //all lines are dollar amount, add values to both fixed and total
      if SplitData[i].LineType = mltDollarAmt then
      begin
        Fixed := Fixed + Double2Money( SplitData[i].Amount);
      end;
    end
    else
    begin
      //add dollar amounts to fixed, percentage amounts to total
      if SplitData[i].LineType = mltDollarAmt then
        Fixed := Fixed + Double2Money( SplitData[i].Amount);

      if SplitData[i].LineType = mltPercentage then
        TotalPerc := TotalPerc + Double2Percent( SplitData[i].Amount);
    end;
  end;

  if HasDollarLines and (not HasPercentLines) and ( GetComboCurrentIntObject(cmbValue) = mxAmtEqual) then
  begin
    RemainingPerc   := 0;
    RemainingDollar := AmountToMatch - Fixed;
  end
  else
  begin
    RemainingPerc   := Double2Percent(100.0) - TotalPerc;
    RemainingDollar := AmountToMatch - Fixed;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.UpdateTotal;
Const
  LINE1_HEIGHT = 0;
  LINE2_HEIGHT = 20;
var
  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc, RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;
  MatchOnEquals : boolean;
begin
  CalcRemaining(Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
  if Assigned(fBankAccount)  then begin
     lblAmount.Caption := fBankAccount.MoneyStr( AmountToMatch );
     lblFixed.Caption  := fBankAccount.MoneyStr( Fixed );
     lblRemDollar.Caption := fBankAccount.MoneyStr( RemainingDollar );
  end else if Assigned(MyClient) then begin
     lblAmount.Caption := MyClient.MoneyStr( AmountToMatch );
     lblFixed.Caption  := MyClient.MoneyStr( Fixed );
     lblRemDollar.Caption := MyClient.MoneyStr( RemainingDollar );
  end else if assigned(AdminSystem) then  begin
     lblAmount.Caption := AdminSystem.MoneyStr( AmountToMatch );
     lblFixed.Caption  := AdminSystem.MoneyStr( Fixed );
     lblRemDollar.Caption := AdminSystem.MoneyStr( RemainingDollar );
  end;

  lblTotalPerc.Caption := Format( '%0.4f%%', [TotalPerc/ 10000]);
  lblRemPerc.Caption := Format( '%0.4f%%', [RemainingPerc/ 10000]);

  MatchOnEquals := GetComboCurrentIntObject(cmbValue) = mxAmtEqual;

  lblTotalPerc.Visible := ( not MatchOnEquals) or HasPercentLines;
  lblTotalPercHdr.Visible := lblTotalPerc.Visible;

  lblFixed.Visible := MatchOnEquals or HasDollarLines;
  lblFixedHdr.Visible := lblFixed.Visible;

  if (lblFixed.Visible and not lblTotalPerc.Visible) then
  begin
    lblFixed.Top := LINE1_HEIGHT;
    lblFixedHdr.Top := LINE1_HEIGHT;
  end
  else
  begin
    lblFixed.Top := LINE2_HEIGHT;
    lblFixedHdr.Top := LINE2_HEIGHT;
  end;

  lblRemPerc.Visible   := ( not MatchOnEquals) or HasPercentLines;
  lblRemPercHdr.Visible := lblRemPerc.Visible;

  lblRemDollar.Visible := MatchOnEquals;
  lblRemDollarHdr.Visible := lblRemDollar.Visible;

  if (lblRemDollar.Visible and not lblRemPerc.Visible) then
  begin
    lblRemDollar.Top := LINE1_HEIGHT;
    lblRemDollarHdr.Top := LINE1_HEIGHT;
  end
  else
  begin
    lblRemDollar.Top := LINE2_HEIGHT;
    lblRemDollarHdr.Top := LINE2_HEIGHT;
  end;

  if RemainingPerc = 0 then
    lblRemPerc.Font.Color := clGreen
  else
    lblRemPerc.Font.Color := clRed;

  if ( not lblRemPerc.Visible) then
  begin
    if RemainingDollar = 0 then
      lblRemDollar.Font.Color := clGreen
    else
      lblRemDollar.Font.Color := clRed;
  end
  else
    lblRemDollar.Font.Color := clWindowText;
end;

//------------------------------------------------------------------------------
function TdlgMemorise.OKtoPost() : boolean;
var
  i,j : integer;
  ExtraMsg : string;
  aMsg : string;

  Fixed  : Money;
  TotalPerc  : Money;
  RemainingPerc : Money;
  RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;

  AmountMatchType : integer;
  TempMem : TMemorisation;
  FMemorisationsList : TMemorisations_List; //list of other memorisations to check for duplicates
  BankPrefix : string;
  ValidLineFound : boolean;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  MemLine : pMemorisation_Line_Rec;
  IsActive: boolean;
  DoInvalidWarning: boolean;
  DoInactiveWarning: boolean;
  InvalidCodes: TStringList;
  InactiveCodes: TStringList;
  WarningMsg: string;
  NunOfSplitLines : integer;

const
  ThisMethodName = 'OKtoPost';
  ShowInactiveWarnings = false;
  ShowInvalidWarnings = false;
begin
   IsActive := True;
   Result := false;
   FMemorisationsList := nil;

   if Rowtmr.Enabled then begin
      RowtmrTimer(nil); // execute the prompts
   end;

   RemoveBlankLines;
   tblSplit.ActiveRow := 1;

   //check at least one valid line exists
   ValidLineFound := false;
   for i := 1 to GLCONST.Max_mx_Lines do
   begin
     if SplitLineIsValid( i) then
     begin
       ValidLineFound := true;
       Break;
     end;
   end;

   if not ValidLineFound then
   begin
     HelpfulErrorMsg( 'The Memorisation must have at least one line.', 0);
     Exit;
   end;

   i := 0;
   j := 0;
   if cbFrom.Checked then begin
      i := EDateFrom.AsStDate;
      if (I < MinValidDate)
      or (I > MaxValidDate) then begin
         HelpfulErrorMsg( 'Please enter a valid Applies from date.', 0);
         EDateFrom.SetFocus;
         Exit;
      end;
   end;
   if cbTo.Checked then begin
      j := EDateTo.AsStDate;
      if (j < MinValidDate)
      or (j > MaxValidDate) then begin
         HelpfulErrorMsg( 'Please enter a valid Applies to date.', 0);
         EDateTo.SetFocus;
         Exit;
      end;
   end;
   if (i <> 0)
   and (J <> 0) then
      if J < I then begin
         HelpfulErrorMsg( 'Please enter a Applies to date, later than the Applies from date.', 0);
      end;

   //check that all of memorisation is allocated
   CalcRemaining(Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
   AmountMatchType := GetComboCurrentIntObject(cmbValue);

   //special case if matching by amount, no percentage split is required
   if AmountMatchType = mxAmtEqual then
   begin
     //if only have dollar lines then check that full amount has been allocated
     if ( HasDollarLines and not( HasPercentLines)) then
     begin
       if ( RemainingDollar <> 0) then
       begin
         HelpfulErrorMsg( 'The full amount of the transaction has not been allocated.  Remaining dollar amount is ' +
           MyClient.MoneyStr( RemainingDollar ) + '.', 0 );
         Exit;
       end;
     end;
   end;

   if RemainingPerc <> 0 then
   begin
     HelpfulErrorMsg( 'The remaining percentage is not zero.  You must allocate 100% of the variable component for this Memorisation.',0);
     Exit;
   end;

   //make sure each line has an account code
   for i := 1 to GLCONST.Max_mx_Lines do with SplitData[i] do
     If (double2Money(Amount) <> 0) and (Trim(AcctCode)='') then
     begin
        HelpfulErrorMsg( 'You must enter an account code!', 0 );
        exit;
     end;



   //if not InEditMemorisationMode then
   begin
     //warn user if the only criteria is entry type
     if not ( cRef.Checked or
              cCode.Checked or
              chkStatementDetails.Checked or
              cOther.Checked or
              cPart.Checked or
              cNotes.Checked or
              cValue.Checked) then
       begin
         if AskYesNo( 'Confirm Criteria',
                      'You have not selected any criteria to match on!'#13 +
                      'This Memorisation will be applied to ALL transactions with Entry Type ' +
                      cmbType.Text + #13#13+
                      'Please confirm you want to do this.',
                      DLG_NO, 0) <> DLG_YES then
                        Exit;
       end;

     //check that this transaction will be coded
     TempMem := TMemorisation.Create(nil);
     try
       SaveToMemRec( TempMem, SourceTransaction, fDlgEditMode in ALL_MASTER, NunOfSplitLines, True);

       if Assigned( fBankAccount) then begin
          if (fDlgEditMode in ALL_MASTER) and Assigned(AdminSystem) then
             begin
               //memorise to relevant master file then reload to get new global list
               BankPrefix := mxFiles32.GetBankPrefix( fBankAccount.baFields.baBank_Account_Number);

//               Master_Mem_Lists_Collection.ReloadSystemMXList( BankPrefix);
//               FMemorisationsList := Master_Mem_Lists_Collection.FindPrefix( BankPrefix);
               SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
               if Assigned(SystemMemorisation) then
                 FMemorisationsList := TMemorisations_List(SystemMemorisation.smMemorisations);

               // TempMem.mdFields.mdFrom_Master_List := true;
             end
          else
             FMemorisationsList := fBankAccount.baMemorisations_List;
       end else begin
          FMemorisationsList := EditMemorisedList;
       end;
       TempMem.mdFields.mdFrom_Master_List := fDlgEditMode in ALL_MASTER;

       if Assigned( FMemorisationsList) {and Assigned(EditMem)} then
         if (HasDuplicateMem(TempMem, FMemorisationsList, EditMem)) then begin
           if TempMem.mdFields.mdFrom_Master_List then
             aMsg := 'A Master Memorisation already exists that uses the same Match-On criteria. '+
                                'You cannot add duplicate Master Memorisations.'
           else
             aMsg := 'A Memorisation already exists that uses the same Match-On criteria. '+
                                'You cannot add duplicate Memorisations.';

           HelpfulErrorMsg( aMsg, 0);
           Exit;
         end;

       //Warn the user if the selected transaction does not match the criteria
       if (assigned(SourceTransaction)) and
          (not CalledFromRecommendedMems) and
          (not mxUtils.CanMemorise( SourceTransaction, TempMem)) and
          (not copied) then
       begin
         if AskYesNo( 'Confirm Criteria',
                      'The currently selected transaction will NOT be memorised because the "Match On" criteria does not match it. Any other transactions that match the criteria WILL be memorised.'#13#13+
                      'Please confirm you want to continue.', DLG_NO, 0) <> DLG_YES then
           Exit;
       end;

     finally
       //free the memory associated with this memorisation
       TempMem.Free;
     end;

   end;

   if (DlgEditMode in ALL_EDIT) then
   begin
      //check to see if this is a master memorisation and add an extra warning
      ExtraMsg := '';
      if fDlgEditMode in ALL_MASTER then begin
         if not Assigned( AdminSystem) then
            //the memorisation is marked as a MASTER, however there is no valid admin system.
            //therefore we are dealing with a memorisation which has been saving into the client file
            ExtraMsg := #13+#13+'NOTE: This will only change the MASTER Memorisation TEMPORARILY. '+
                        'To change it permanently it must be altered at the PRACTICE.'
         else
            ExtraMsg := #13+#13+'NOTE: This will apply to ALL clients in your practice that have '+
                        'accounts with this bank and use MASTER Memorisations.';
      end;

      // Only ask this in Edit mode?
      if (DlgEditMode = demEdit) then
      begin
        if AskYesNo( 'Confirm Edit',
                     'Saving the changes to this Memorisation will re-code all Entries'+
                     ', which match this criteria, '+
                     'that are yet to be transferred or finalised. '#13#13+
                     'Please confirm you want to do this.' + ExtraMsg,
                     DLG_YES, 0) <> DLG_YES then exit;
      end;
   end;

   DoInvalidWarning := False;
   DoInactiveWarning := False;
   InvalidCodes := TStringList.Create;
   InvalidCodes.Sorted := True;
   InvalidCodes.Duplicates := dupIgnore;
   InactiveCodes := TStringList.Create;
   InactiveCodes.Sorted := True;
   InactiveCodes.Duplicates := dupIgnore;
   try
     for i := 1 to GLCONST.Max_mx_Lines do
     begin
       if SplitLineIsValid(i) then
       begin
         MemLine := BKMLIO.New_Memorisation_Line_Rec;
         try
           with MemLine^ do
           begin
             mlAccount := SplitData[i].AcctCode;
             if not MyClient.clChart.CanCodeto(mlAccount, IsActive, HasAlternativeChartCode (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then
             begin
               if ShowInvalidWarnings then
               begin
                 DoInvalidWarning := True;
                 InvalidCodes.Add(mlAccount);
               end;
             end else
             if not IsActive then
             begin
               if ShowInactiveWarnings then
               begin
                 DoInactiveWarning := True;
                 InactiveCodes.Add(mlAccount);
               end;
             end;
           end;
         finally
           Free_Memorisation_Line_Rec_Dynamic_Fields(MemLine^);
           SafeFreeMem(MemLine, Memorisation_Line_Rec_Size);
         end;
       end;
     end;

     if DoInvalidWarning and not DoInactiveWarning then
     begin
       if (InvalidCodes.Count > 1) then
       begin
         WarningMsg := 'Several account codes are invalid:' + #13;
         for i := 0 to InvalidCodes.Count - 1 do
           WarningMsg := WarningMsg + InvalidCodes.Strings[i] + #13;
         WarningMsg := WarningMsg + #13 +
                       'Do you want to continue?';
       end else
         WarningMsg := 'Account code ' + InvalidCodes.Strings[0] + ' is invalid, do you want to continue?';
     end else
     if DoInactiveWarning and not DoInvalidWarning then
     begin
       if (InactiveCodes.Count > 1) then
       begin
         WarningMsg := 'Several account codes are inactive:' + #13;
         for i := 0 to InactiveCodes.Count - 1 do
           WarningMsg := WarningMsg + InactiveCodes.Strings[i] + #13;
         WarningMsg := WarningMsg + #13 +
                       'Do you want to continue?';
       end else
         WarningMsg := 'Account code ' + InactiveCodes.Strings[0] + ' is inactive, do you want to continue?';
     end else
     if DoInvalidWarning and DoInactiveWarning then
     begin
       WarningMsg := 'Several account codes are invalid or inactive:' + #13;
       for i := 0 to InactiveCodes.Count - 1 do
           WarningMsg := WarningMsg + InactiveCodes.Strings[i] + #13;
       for i := 0 to InvalidCodes.Count - 1 do
           WarningMsg := WarningMsg + InvalidCodes.Strings[i] + #13;
       WarningMsg := WarningMsg + #13 +
                     'Do you want to continue?';
     end;   

     if DoInvalidWarning or DoInactiveWarning then     
       if (AskYesNo('Warning', WarningMsg, DLG_YES, 0, false) = DLG_NO) then
         exit;

   finally
     FreeAndNil(InvalidCodes);
     FreeAndNil(InactiveCodes);
   end;

   result := true;
end;

//------------------------------------------------------------------------------
function TdlgMemorise.SplitLineIsValid( LineNo : integer) : boolean;
begin
   Result := (Trim(SplitData[LineNo].AcctCode)<>'')
          or (SplitData[LineNo].Amount <>0)
          or (SplitData[LineNo].SF_Edited);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  if (pnlMain.height - NewSize) < 100 then
    Accept := false
  else
    Accept := true;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.ReadCellforPaint(RowNum, ColNum: integer; var Data: pointer);
begin
  if (RowNum > fMemTranSortedList.ItemCount) then
    Exit;

  case ColNum of
    mtDate : begin
      fTempString := bkDate2Str(fMemTranSortedList.GetPRec(RowNum-1)^.DateEffective);
      Data := @fTempString;
    end;
    mtReference : begin
      fTempString := fMemTranSortedList.GetPRec(RowNum-1)^.Reference;
      Data := @fTempString;
    end;
    mtAnalysis : begin
      fTempString := fMemTranSortedList.GetPRec(RowNum-1)^.Analysis;
      Data := @fTempString;
    end;
    mtAccount : begin
      fTempSuggMem := fMemTranSortedList.GetPRec(RowNum-1);
      Data := fTempSuggMem;
    end;
    mtAmount : begin
      fTempAmount := fMemTranSortedList.GetPRec(RowNum-1)^.Amount/100;
      Data := @fTempAmount;
    end;
    mtStatementDetails : begin
      fTempString := fMemTranSortedList.GetPRec(RowNum-1)^.Statement_Details;
      Data := @fTempString;
    end;
    mtCodedBy : begin
      fTempString := cbNames[fMemTranSortedList.GetPRec(RowNum-1)^.CodedBy];
      Data := @fTempString;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.RefreshMemTransactions;
var
  TempMem : TMemorisation;
  NunOfSplitLines : integer;
begin
  if not fAllowRefreshTran then
    Exit;

  tblTran.AllowRedraw := false;
  TempMem := TMemorisation.Create(nil);
  try
    SaveToMemRec(TempMem, SourceTransaction, fDlgEditMode in ALL_MASTER, NunOfSplitLines, true);

    fMemTranSortedList.FreeAll;
    SuggestedMem.GetTransactionListMatchingMemPhrase(fBankAccount, TempMem, fMemTranSortedList, (NunOfSplitLines > 1));

    if fMemTranSortedList.ItemCount = 0 then
    begin
      tblTran.RowLimit := 1;
      pnlMessage.Visible := true;
    end
    else
    begin
      tblTran.RowLimit := fMemTranSortedList.ItemCount + 1;
      pnlMessage.Visible := false;
    end;

    tblTran.invalidateTable;
    tblTran.refresh;

  finally
    FreeAndNil(TempMem);
    tblTran.AllowRedraw := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.RefreshAccTranControls();
begin
  if (fDlgEditMode in ALL_NO_MASTER) or (not Assigned(AdminSystem)) then
  begin
    fAllowRefreshTran := true;
    RefreshMemTransactions();
    fAllowRefreshTran := false;
    treView.Visible := false;
    tblTran.Visible := true;
    lblMatchingTransactions.Caption := 'Matching Transactions';
    lblMatchingTranNote.Visible := true;
  end
  else
  begin
    SuggestedMem.StopMemScan(true);
    try
      treView.Visible := true;
      tblTran.Visible := false;
      lblMatchingTransactions.Caption := 'Matching Accounts';
      lblMatchingTranNote.Visible := false;
      RefreshMasterMemTree();
    finally
      SuggestedMem.StartMemScan();
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.RefreshMasterMemTree;
var
  NumOfSplitLines : integer;
begin
  // if the Thread is already running stop it
  if Assigned(fMasterTreeThread) then
  begin
    if not fMasterTreeThread.Terminated  then
      fMasterTreeThread.Terminate;

    fMasterTreeThread := nil;
  end;

  pnlMessage.Visible := false;
  ffrmSpinner.ShowSpinner('Calculating',
                          pnlMain.Top + pnlMatchingTransactions.Top +
                          (pnlMatchingTransactions.Height div 2) - (ffrmSpinner.Height div 2),
                          (Self.Width div 2) - (ffrmSpinner.Width div 2));

  Setfocus();

  treView.Items.Clear;

  if Assigned(fWorkerMem) then
    FreeAndNil(fWorkerMem);

  fMasterMemList.Clear();

  // The SaveToMemRec is a function on this Dialog and it has alot of call to controls
  // this really should be moved to another utils unit. When this mems form is rewriten,
  // this should be done as part of that.
  fWorkerMem := TMemorisation.Create(nil);
  SaveToMemRec(fWorkerMem, SourceTransaction, true, NumOfSplitLines, true);

  fMasterTreeThread := TMasterTreeThread.Create(true);
  fMasterTreeThread.MasterMemList          := fMasterMemList;
  fMasterTreeThread.WorkerMem              := fWorkerMem;
  fMasterTreeThread.NumOfSplitLines        := NumOfSplitLines;
  fMasterTreeThread.SourceBankAccount      := BankAccount;
  fMasterTreeThread.SourceTransaction      := SourceTransaction;
  fMasterTreeThread.BankPrefix             := BankPrefix;
  fMasterTreeThread.DoneThreadEvent        := AfterFillMasterMemEvent;
  fMasterTreeThread.ApplyToAccSystem       := chkAccountsystem.Checked;
  fMasterTreeThread.AccountSystemAppliedto := GetAccountingSystem;

  fMasterTreeThread.Resume;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.AfterFillMasterMemEvent;
var
  MasterMemIndex : integer;
  MasterMemItem : TMasterMemItem;
  RootNode : TTreeNode;
  ClientNode : TTreeNode;
begin
  // using the Object list that was filled by the thread, populated the Tree list
  RootNode := nil;
  ClientNode := nil;
  treView.Items.BeginUpdate;
  try
    for MasterMemIndex := 0 to fMasterMemList.Count-1 do
    begin
      MasterMemItem := TMasterMemItem(fMasterMemList.Items[MasterMemIndex]);

      case MasterMemItem.Level of
        1 : RootNode := treView.Items.Add(NIL, MasterMemItem.Name);
        2 : begin
          if Assigned(RootNode) then
            ClientNode := treView.Items.AddChild(RootNode, MasterMemItem.Name);
        end;
        3 : begin
          if Assigned(ClientNode) then
            treView.Items.AddChild(ClientNode, MasterMemItem.Name);
        end;
      end;
    end;

    treView.FullExpand;
    if Assigned(RootNode) then
    begin
      RootNode.Selected := true;
      RootNode.Focused := true;
    end;
  finally
    treView.Items.EndUpdate;
  end;

  if (Assigned(ffrmSpinner)) and
     (ffrmSpinner.HandleAllocated) then
    ffrmSpinner.CloseSpinner;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.RemoveBlankLines;
var
   NewData : TSplitArray;
   i       : integer;
   NewC    : integer;

   procedure CopyLine( LineNo : integer);
   begin
      Inc(NewC);
      NewData[NewC] := SplitData[LineNo];
   end;

begin
   if not tblSplit.StopEditingState(True) then Exit;

   {initialise temp Array}
   NewC := 0;
   for i := Low(NewData) to High(NewData) do begin
      ClearWorkrecdetails(@NewData[i]);
   end;

   //copy valid lines to new array
   //copy $ amounts first
   for i := 1 to GLCONST.Max_mx_Lines do
     if SplitData[i].LineType = mltDollarAmt then
       if SplitLineIsValid(i) then
          CopyLine(i);

   //copy % amounts
   for i := 1 to GLCONST.Max_mx_Lines do
     if SplitData[i].LineType = mltPercentage then
       if SplitLineIsValid( i) then
         CopyLine( i);

   //now replace Splitdata
   if NewC > 0 then begin
      SplitData := NewData;
      tblSplit.Refresh;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (RowNum = tblSplit.LockedRows) then
    Exit;

  if (CellAttr.caColor = tblSplit.Color) then
  begin
    if Odd(RowNum) then
      CellAttr.caColor := clwhite
    else
      CellAttr.caColor := AltLineColor;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.tblSplitActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
{var
   HelpCtx : integer;}
begin
{  HelpCtx := 0;

  case ColNum of
  AcctCol :
    HelpCtx := hcMemorisecode;
  GSTCodeCol :
    HelpCtx := hcMemoriseGSTClass;
  PercentCol:
    HelpCtx := hcMemoriseAmount;
  end;

  tblSplit.HelpContext := HelpCtx;
  MsgBar(HintMsg(HelpCtx),false);}
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnChartClick(Sender: TObject);
begin
  if not tblSplitInEdit then
     tblSplit.SetFocus;
//  keybd_event(vk_f2,0,0,0); seems to be unreliable when called from the pop-up menu
  tblSplitUserCommand(Self, tcLookup);
end;

procedure TdlgMemorise.sbtnJobClick(Sender: TObject);
begin
  if not tblSplitInEdit then
     tblSplit.SetFocus;
  tblSplitUserCommand(Self, tcJobLookup);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnPayeeClick(Sender: TObject);
begin
  if not tblSplitInEdit then
     tblSplit.SetFocus;
  tblSplitUserCommand(Self, tcPayeeLookup);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.sbtnSuperClick(Sender: TObject);
begin
   if not tblSplitInEdit then
      tblSplit.SetFocus;
   tblSplitUserCommand(Self, tcSuperEdit);
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.CompleteAmount;
var
  MoneyAmt : Money;
  RowNum   : integer;
  Fixed, TotalPerc : Money;
  RemainingPerc, RemainingDollar : Money;
  HasPercentLines : boolean;
  HasDollarLines  : boolean;

  MatchOnEquals : boolean;
begin
   if ((tblSplit.ActiveCol <> PercentCol) and (tblSplit.ActiveCol <> AmountCol)) or (tblSplitInEdit) then exit;
   RowNum := tblSplit.ActiveRow;

   if not ( SplitData[ RowNum].LineType in [ mltPercentage, mltDollarAmt]) then
     Exit;

   //figure out remaining amount
   CalcRemaining( Fixed, TotalPerc, RemainingPerc, RemainingDollar, HasDollarLines, HasPercentLines);
   MatchOnEquals := GetComboCurrentIntObject(cmbValue) = mxAmtEqual;

   if MatchOnEquals and ( not HasPercentLines) then
   begin
     MoneyAmt := Double2Money(RemainingDollar + Double2Money(SplitData[RowNum].Amount));
     if MoneyAmt <> 0 then
       SplitData[ RowNum].LineType := mltDollarAmt;
   end
   else
   begin
     if SplitData[RowNum].LineType = mltPercentage then
         MoneyAmt := RemainingPerc + Double2Percent(SplitData[RowNum].Amount)
     else
     begin
       MoneyAmt := RemainingPerc;
       if MoneyAmt <> 0 then
         SplitData[ RowNum].LineType := mltPercentage;
     end;
   end;

   if (MoneyAmt <> 0) then
   begin
     SplitData[Rownum].Amount := Percent2Double(MoneyAmt);
     tblSplit.AllowRedraw := false;
     try
       Keybd_event(VK_LEFT   ,0,0,0);
       Keybd_event(VK_RIGHT   ,0,0,0);
       tblSplit.InvalidateRow( RowNum);
     finally
       tblSplit.AllowRedraw := true;
     end;
     UpdateTotal;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgMemorise.ColAcctKeyPress(Sender: TObject; var Key: Char);
var
  Msg : TWMKey;
begin
  if key = '-' then begin
    if Assigned(myClient) and (myClient.clFields.clUse_Minus_As_Lookup_Key) then begin
      key := #0;
      Msg.CharCode := VK_F2;
      ColAcct.SendKeyToTable(Msg);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.ColGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = bkBranding.SelectionColor then exit;
  //check is a data row
  if not( (RowNum > 0) and (RowNum <= GLCONST.Max_mx_Lines)) then exit;
  //see if edited
  if not SplitData[ RowNum].GST_Has_Been_Edited then
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

//------------------------------------------------------------------------------
function TdlgMemorise.HasJobs: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to GLCONST.Max_mx_Lines do
    if SplitData[i].JobCode > '' then
    begin
      Result := True;
      exit;
    end;
end;

function TdlgMemorise.HasPayees: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to GLCONST.Max_mx_Lines do
    if SplitData[i].Payee <> 0 then
    begin
      Result := True;
      exit;
    end;
end;

procedure TdlgMemorise.chkMasterClick(Sender: TObject);
var
   i          : integer;
   GSTEdited  : Boolean;
begin
  if loading then
    Exit;

  fDirty := true;
  if chkMaster.Checked then
  begin
    if (DlgEditMode in ALL_COPY) then
      DlgEditMode := demMasterCopy
    else if (DlgEditMode in ALL_EDIT) then
      DlgEditMode := demMasterEdit
    else
      DlgEditMode := demMasterCreate;
  end
  else
  begin
    if (DlgEditMode in ALL_COPY) then
      DlgEditMode := demCopy
    else if (DlgEditMode in ALL_EDIT) then
      DlgEditMode := demEdit
    else
      DlgEditMode := demCreate;
  end;

  UpdateControls();

  cbAccounting.Enabled := chkAccountSystem.Checked;

  if (DlgEditMode in ALL_EDIT) then
    Exit;
  //must be in create mode
  //if checked then make sure we have default GST Classes.

  if chkMaster.Checked then
  begin
    GSTEdited := False;
    for i := 1 to GLCONST.Max_mx_Lines do
    begin
      if SplitData[i].GST_Has_Been_Edited then
      begin
        GSTEdited := true;
        Break;
      end;
    end;

    if GSTEdited then
    begin
      chkMaster.Checked := False;
      HelpfulInfoMsg( 'GST cannot be overridden for a memorisation at MASTER level. MASTER memorised entries always apply GST at the default rate for the account in the client''s chart.', 0 );
      Exit;
    end;

    for i := 1 to GLCONST.Max_mx_Lines do
    begin
      if SplitData[i].SF_Edited and
         ((SplitData[i].SF_Fund_ID > -1) or (SplitData[i].SF_Member_Account_ID > -1)) then
      begin
        GSTEdited := true;
        Break;
      end;
    end;

    if GSTEdited then
    begin
      chkMaster.Checked := False;
      HelpfulInfoMsg( 'You cannot memorise at a MASTER level if you have fund specific selections in the memorisation.', 0 );
      Exit;
    end;

    if HasPayees
    or HasJobs then
      HelpfulInfoMsg('Payees or Jobs cannot be used in Master Memorisations.'#13'The Payees or Jobs you have used in this memorisation will not be saved.', 0);
  end;

  RefreshAccTranControls();
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.ColAcctOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the code is invalid, show it in red
var
  R: TRect;
  S: String;
  CodeIsActive: boolean;
const
  margin = 4;
  procedure PaintCommentIndicator(CommentColor: TColor);
  begin
      //draw a red triangle in the top right
      TableCanvas.Brush.Color := CommentColor;
      TableCanvas.Pen.Color := CommentColor;

      TableCanvas.Polygon( [Point( CellRect.Right - (Margin+ 1), CellRect.Top),
                            Point( CellRect.Right -1, CellRect.Top),
                            Point( CellRect.Right -1, CellRect.Top + Margin)]);
  end;

begin
   CodeIsActive := True;

   If (data = nil) then
      exit;

   S := ShortString(Data^);

   R := CellRect;

   if CellAttr.caColor <> bkBranding.SelectionColor then begin
      if (S = '')
      or (S = BKCONST.DISSECT_DESC)
      or MyClient.clChart.CanCodeTo(S,CodeIsActive,HasAlternativeChartCode (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then begin
         // Ok.
         if CodeIsActive then
           TableCanvas.Brush.Color := CellAttr.caColor
         else
           TableCanvas.Brush.Color := clYellow;
         TableCanvas.FillRect(R);
         TableCanvas.Font.Color := clWindowtext;
      end else begin
         TableCanvas.Brush.Color := clRed;
         TableCanvas.Font.Color := clWhite;
         TableCanvas.FillRect(R);
         //paint border
         TableCanvas.Pen.Color := CellAttr.caColor;
         TableCanvas.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);

      end;
   end else begin
     TableCanvas.Brush.Color := bkBranding.SelectionColor;
     TableCanvas.Font.Color := clWhite;
     TableCanvas.FillRect(R);
   end;


   //paint background


   InflateRect( R, -2, -2 );

   DrawText(TableCanvas.Handle, PChar( S ), -1 , R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

   if SplitData[RowNum].SF_Edited
   and sbtnSuper.Visible then
      PaintCommentIndicator(clRed);

   DoneIt := True;
end;
//------------------------------------------------------------------------------

procedure TdlgMemorise.cNotesClick(Sender: TObject);
begin
  eNotes.Enabled := cNOtes.Checked;

  if not Loading then
  begin
    fDirty := true;
    if eNOtes.enabled then
      eNotes.setFocus;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.FormResize(Sender: TObject);
var
   i : integer;
   W : integer;
begin
   with tblSplit do begin
      // Now resize the Desc Column to fit the table width
      W := 0;
      for i := 0 to Pred( Columns.Count ) do begin
         if not Columns[i].Hidden then
            W := W + Columns.Width[i];
      end;
      i := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
      W := W + i + 4;
      Columns[ NarrationCol ].Width := Columns[ NarrationCol ].Width + ( Width - W );
      if Columns[NarrationCol ].Width <= 0 then
      begin
        Columns[NarrationCol].Width := 100;
        Columns[PercentCol].Width := Columns[PercentCol].Width - 25;
        Columns[DescCol].Width := Columns[DescCol].Width - 75;
      end;
   end;

  if (Assigned(ffrmSpinner)) and
     (ffrmSpinner.HandleAllocated) then
    ffrmSpinner.UpdateSpinner(pnlMain.Top + pnlMatchingTransactions.Top +
                              (pnlMatchingTransactions.Height div 2) - (ffrmSpinner.Height div 2),
                              (Self.Width div 2) - (ffrmSpinner.Width div 2));
end;

procedure TdlgMemorise.FormShow(Sender: TObject);
var
  MovedValue : integer;
  ClientFileRec : pClient_File_Rec;

  procedure AutoSize(value: tCheckBox);
  begin
    Value.Width := Canvas.TextWidth(Value.caption) + 15;
  end;
begin
  if not ( Assigned( AdminSystem) and Assigned( CurrUser )) then
    AllowMasterMemorised := false
  else
  begin
    ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(MyClient.clFields.clCode);
    if not Assigned(ClientFileRec) then
      AllowMasterMemorised := false
    else
      AllowMasterMemorised := ( CurrUser.CanMemoriseToMaster ) and
                              ( AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number) and
                              ( MyClient.clFields.clDownload_From = dlAdminSystem ) and
                              ( (DlgEditMode in ALL_CREATE)) and
                              ( (not Assigned(fBankAccount)) or (Assigned(fBankAccount) and not fBankAccount.baFields.baIs_A_Manual_Account) ) and
                              ( not ClientFileRec^.cfForeign_File );
  end;
  chkMaster.Enabled := AllowMasterMemorised;

  PopulatePayee := True;
  AutoSize(chkMaster);
  AutoSize(chkAccountSystem);

  if (not (eStatementDetails.Text = '')) and
    (not fCopied) and
    (DlgEditMode in ALL_CREATE) then
    chkStatementDetails.checked := true;

  RefreshAccTranControls();
  if fDlgEditMode in ALL_MASTER then
    chkMaster.Checked := true;

  if (Assigned(AdminSystem)) or (not (fDlgEditMode = demMasterEdit)) then
  begin
    btnOk.SetFocus;
  end
  else
  begin
    btnOk.enabled := false;
    btnCancel.SetFocus;
  end;

  MovedValue := (chkAccountSystem.Left + chkAccountSystem.Width + 16) - cbAccounting.Left;
  cbAccounting.Left := chkAccountSystem.Left + chkAccountSystem.Width + 16;
  cbAccounting.Width := cbAccounting.Width - MovedValue;
  eStatementDetails.Enabled := chkStatementDetails.Checked;

  fAllowRefreshTran := true;
  fDirty := false;
end;

function TdlgMemorise.GetAccountingSystem: Integer;
begin
   Result := GetComboCurrentIntObject(cbAccounting, snother);
end;

function TdlgMemorise.GetCellRect(const RowNum, ColNum: Integer): TRect;
begin
  Result.Top    := pnlMain.Top + pnlMatchingTransactions.Top +
                   tblTran.Top + tblTran.RowOffset[ RowNum ];
  Result.Bottom := pnlMain.Top + pnlMatchingTransactions.Top +
                   tblTran.Top + tblTran.RowOffset[ RowNum ] + tblTran.Rows[ RowNum ].Height;
  Result.Left   := tblTran.Left + tblTran.ColOffset[ ColNum ];
  Result.Right  := tblTran.Left + tblTran.ColOffset[ ColNum ] + tblTran.Columns[ ColNum ].Width;
  Result.TopLeft := ClientToScreen( Result.TopLeft );
  Result.BottomRight := ClientToScreen( Result.BottomRight );
end;

procedure TdlgMemorise.chkStatementDetailsClick(Sender: TObject);
begin
  eStatementDetails.Enabled := chkStatementDetails.Checked;

  if not Loading then
  begin
    fDirty := true;
    if eStatementDetails.enabled then
      eStatementDetails.setFocus;
  end;
end;

procedure TdlgMemorise.ClearSuperfundDetails1Click(Sender: TObject);
begin
   if not tblSplitInEdit then
      tblSplit.SetFocus;
   tblSplitUserCommand(Self, tcSuperClear);
end;

procedure TdlgMemorise.cValueClick(Sender: TObject);
begin
  cmbValue.Enabled := cValue.Checked;
  nValue.Enabled   := cValue.Checked;
  cbMinus.Enabled  := cValue.Checked;

  //set default value
  if not cValue.Checked then
    cmbValue.ItemIndex := -1
  else
    if cmbValue.ItemIndex = -1 then
      SetComboIndexByIntObject( mxAmtEqual, cmbValue);

  //set first line
  SetFirstLineDefaultAmount;

  if not Loading then
  begin
    fDirty := true;
    if cmbValue.enabled then
      cmbValue.setFocus;
  end;
end;

procedure TdlgMemorise.nValueChange(Sender: TObject);
begin
  if not Loading then
    fDirty := true;

  AmountToMatch := Double2Money( nValue.AsFloat) * AmountMultiplier;
  UpdateTotal;
end;

procedure TdlgMemorise.nValueKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '-' then
    Key := #0;
end;

procedure TdlgMemorise.SaveToMemRec(var pM: TMemorisation; pT: pTransaction_Rec;
  IsMaster: Boolean; var aNunOfSplitLines : integer; ATempMem: boolean = false);
var
  i : integer;
  MemLine : pMemorisation_Line_Rec;
  AuditIDList: TList;
begin
  aNunOfSplitLines := 0;
  with pM do begin
     mdFields.mdType := GetTxTypeFromCmbType;
     //see if this is a new memorisation
     if Assigned(pT) then
       mdFields.mdSequence_No := 0;

     mdFields.mdAmount    := abs(AmountToMatch) * AmountMultiplier;
     mdFields.mdReference := eRef.text;
     mdFields.mdNotes     := eNOtes.text;

     if cbFrom.Checked then
        mdFields.mdFrom_Date := StNull2BK( EDateFrom.AsStDate)
     else
        mdFields.mdFrom_Date := 0;

     if cbTo.Checked then
        mdFields.mdUntil_Date := StNull2BK( EDateTo.AsStDate)
     else
        mdFields.mdUntil_Date := 0;

     //save amount match type
     if cValue.Checked then
     begin
       mdFields.mdMatch_on_Amount        := GetComboCurrentIntObject(cmbValue);

       if AmountMultiplier = -1 then
       begin
         //need to reverse the match type because real value is -ve
         case mdFields.mdMatch_on_Amount of
           mxAmtGreaterThan    : mdFields.mdMatch_on_Amount := mxAmtLessThan;
           mxAmtGreaterOrEqual : mdFields.mdMatch_on_Amount := mxAmtLessOrEqual;
           mxAmtLessThan       : mdFields.mdMatch_on_Amount := mxAmtGreaterThan;
           mxAmtLessOrEqual    : mdFields.mdMatch_on_Amount := mxAmtGreaterOrEqual;
         end;
       end;
     end
     else
       mdFields.mdMatch_on_Amount  := mxNo;

     mdFields.mdMatch_on_Refce     := (cRef.Checked);
     mdFields.mdMatch_On_Notes     := (cNotes.Checked);

     //save country specific fields
     case MyClient.clFields.clCountry of
        whNewZealand :
           Begin
              mdFields.mdAnalysis               := eCode.text;
              mdFields.mdParticulars            := ePart.text;
              mdFields.mdOther_Party            := eOther.text;
              mdFields.mdStatement_Details      := eStatementDetails.text;

              mdFields.mdMatch_on_other_party   := (cOther.Checked);
              mdFields.mdMatch_on_Particulars   := (cPart.Checked);
              mdFields.mdMatch_on_Analysis      := (cCode.Checked);
              mdFields.mdMatch_On_Statement_Details := ( chkStatementDetails.checked);
           end;
        whAustralia, whUK :
           Begin
              mdFields.mdParticulars                := eCode.text;
              mdFields.mdStatement_Details          := eStatementDetails.text;

              mdFields.mdMatch_on_Particulars       := cCode.Checked;
              mdFields.mdMatch_On_Statement_Details := chkStatementDetails.checked;
           end;
     end;

     if IsMaster then begin
        mdFields.mdUse_Accounting_System := chkAccountSystem.Checked;
        mdFields.mdAccounting_System := AccountingSystem; // Only When checked..
     end else begin
        mdFields.mdUse_Accounting_System := False;
        mdFields.mdAccounting_System := 0; // -1 ??
     end;

     AuditIDList := TList.Create;
     try
       //Save audit ID's for reuse
       if ModalResult <> mrCopy then
         for i := 0 to Pred(pM.mdLines.ItemCount) do
           AuditIDList.Add(Pointer(pM.mdLines.MemorisationLine_At(i).mlAudit_Record_ID));

       pM.mdLines.FreeAll;
       for i := 1 to GLCONST.Max_mx_Lines do
       begin
         if SplitLineIsValid( i) then
         begin
           MemLine := BKMLIO.New_Memorisation_Line_Rec;
           with MemLine^ do
           begin
             if SplitData[i].AcctCode > '' then
               inc(aNunOfSplitLines);

             mlAccount := SplitData[i].AcctCode;
             if SplitData[i].LineType = mltPercentage then
                mlPercentage := Double2Percent(SplitData[i].Amount)
             else
                mlPercentage := Double2Money(SplitData[i].Amount);
             mlGst_Class := GetGSTClassNo( MyClient, SplitData[i].GSTClassCode);
             mlGST_Has_Been_Edited := SplitData[i].GST_Has_Been_Edited;
             mlGL_Narration  := SplitData[i].Narration;


             if SplitData[i].LineType = -1 then
                mlLine_Type := 0
             else
                mlLine_Type := SplitData[i].LineType;
             // No payees or Jobs for master mems
             if IsMaster then begin
                mlPayee := 0;
                mlJob_Code := '';
             end else begin
                mlPayee := SplitData[i].Payee;
                mlJob_Code := SplitData[i].JobCode;
             end;
             mlSF_PCFranked := SplitData[i].SF_PCFranked;
             mlSF_PCUnFranked := SplitData[i].SF_PCUnFranked;
             mlSF_Member_ID := SplitData[i].SF_Member_ID;
             mlSF_Fund_ID := SplitData[i].SF_Fund_ID;
             mlSF_Fund_Code := SplitData[i].SF_Fund_Code;
             mlSF_Trans_ID := SplitData[i].SF_Trans_ID;
             mlSF_Trans_Code := SplitData[i].SF_Trans_Code;

             mlSF_Member_Account_ID := SplitData[i].SF_Member_Account_ID;
             mlSF_Member_Account_Code := SplitData[i].SF_Member_Account_Code;
             mlSF_Member_Component := SplitData[i].SF_Member_Component;

             mlQuantity := SplitData[i].Quantity;

             mlSF_GDT_Date := SplitData[i].SF_GDT_Date;
             mlSF_Tax_Free_Dist := SplitData[i].SF_Tax_Free_Dist;
             mlSF_Tax_Exempt_Dist := SplitData[i].SF_Tax_Exempt_Dist;
             mlSF_Tax_Deferred_Dist := SplitData[i].SF_Tax_Deferred_Dist;
             mlSF_TFN_Credits := SplitData[i].SF_TFN_Credits;
             mlSF_Foreign_Income := SplitData[i].SF_Foreign_Income;
             mlSF_Foreign_Tax_Credits := SplitData[i].SF_Foreign_Tax_Credits;
             mlSF_Capital_Gains_Indexed := SplitData[i].SF_Capital_Gains_Indexed;
             mlSF_Capital_Gains_Disc := SplitData[i].SF_Capital_Gains_Disc;
             mlSF_Capital_Gains_Other := SplitData[i].SF_Capital_Gains_Other;
             mlSF_Other_Expenses := SplitData[i].SF_Other_Expenses;
             mlSF_Interest := SplitData[i].SF_Interest;
             mlSF_Capital_Gains_Foreign_Disc := SplitData[i].SF_Capital_Gains_Foreign_Disc;
             mlSF_Rent := SplitData[i].SF_Rent;
             mlSF_Special_Income := SplitData[i].SF_Special_Income;
             mlSF_Other_Tax_Credit := SplitData[i].SF_Other_Tax_Credit;
             mlSF_Non_Resident_Tax := SplitData[i].SF_Non_Resident_Tax;
             mlSF_Foreign_Capital_Gains_Credit := SplitData[i].SF_Foreign_Capital_Gains_Credit;
             mlSF_Capital_Gains_Fraction_Half := SplitData[i].SF_Capital_Gains_Fraction_Half;

             //DN BGL360 Extended fields
             mlSF_Other_Income                            := SplitData[ i ].SF_Other_Income;
             mlSF_Other_Trust_Deductions                  := SplitData[ i ].SF_Other_Trust_Deductions;
             mlSF_CGT_Concession_Amount                   := SplitData[ i ].SF_CGT_Concession_Amount;
             mlSF_CGT_ForeignCGT_Before_Disc              := SplitData[ i ].SF_CGT_ForeignCGT_Before_Disc;
             mlSF_CGT_ForeignCGT_Indexation               := SplitData[ i ].SF_CGT_ForeignCGT_Indexation;
             mlSF_CGT_ForeignCGT_Other_Method             := SplitData[ i ].SF_CGT_ForeignCGT_Other_Method;
             mlSF_CGT_TaxPaid_Indexation                  := SplitData[ i ].SF_CGT_TaxPaid_Indexation;
             mlSF_CGT_TaxPaid_Other_Method                := SplitData[ i ].SF_CGT_TaxPaid_Other_Method;
             mlSF_Other_Net_Foreign_Income                := SplitData[ i ].SF_Other_Net_Foreign_Income;
             mlSF_Cash_Distribution                       := SplitData[ i ].SF_Cash_Distribution;
             mlSF_AU_Franking_Credits_NZ_Co               := SplitData[ i ].SF_AU_Franking_Credits_NZ_Co;
             mlSF_Non_Res_Witholding_Tax                  := SplitData[ i ].SF_Non_Res_Witholding_Tax;
             mlSF_LIC_Deductions                          := SplitData[ i ].SF_LIC_Deductions;
             mlSF_Non_Cash_CGT_Discounted_Before_Discount := SplitData[ i ].SF_Non_Cash_CGT_Discounted_Before_Discount;
             mlSF_Non_Cash_CGT_Indexation                 := SplitData[ i ].SF_Non_Cash_CGT_Indexation;
             mlSF_Non_Cash_CGT_Other_Method               := SplitData[ i ].SF_Non_Cash_CGT_Other_Method;
             mlSF_Non_Cash_CGT_Capital_Losses             := SplitData[ i ].SF_Non_Cash_CGT_Capital_Losses;
             mlSF_Share_Brokerage                         := SplitData[ i ].SF_Share_Brokerage;
             mlSF_Share_Consideration                     := SplitData[ i ].SF_Share_Consideration;
             mlSF_Share_GST_Amount                        := SplitData[ i ].SF_Share_GST_Amount;
             mlSF_Share_GST_Rate                          := SplitData[ i ].SF_Share_GST_Rate;
             mlSF_Cash_Date                               := SplitData[ i ].SF_Cash_Date;
             mlSF_Accrual_Date                            := SplitData[ i ].SF_Accrual_Date;
             mlSF_Record_Date                             := SplitData[ i ].SF_Record_Date;
             mlSF_Contract_Date                           := SplitData[ i ].SF_Contract_Date;
             mlSF_Settlement_Date                         := SplitData[ i ].SF_Settlement_Date;
             //DN BGL360 Extended fields

             mlSF_edited := SplitData[i].SF_edited;
           end;

           if AuditIDList.Count > 0 then begin
             MemLine^.mlAudit_Record_ID := integer(AuditIDList.Items[0]);
             pM.mdLines.Insert(MemLine);
             AuditIDList.Delete(0);
           end else if ATempMem then
             pM.mdLines.Insert(MemLine)
           else begin
             if IsMaster and Assigned(AdminSystem) then
               MemLine^.mlAudit_Record_ID := SystemAuditMgr.NextAuditRecordID;
             pM.mdLines.Insert(MemLine)
           end;
         end;
       end;
     finally
       AuditIDList.Free;
     end;

     Assert( pM.mdLines.ItemCount > 0, 'Memorisation is empty');
   end;
end;

procedure TdlgMemorise.ColAmountKeyPress(Sender: TObject; var Key: Char);
var
  RowNum, ColNum : integer;
  V: Double;
begin
  RowNum := tblSplit.ActiveRow;
  ColNum := tblSplit.ActiveCol;

  {treat value as percentage}
  if key in [ '$', '£', '%', '€' ] then
  begin
    V := SplitData[tblSplit.ActiveRow].Amount;

    tblSplit.StopEditingState( true);

    if ((Key = '%') and (ColNum = PercentCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((Key in [ '$', '£', '€' ]) and (ColNum = AmountCol) and (SplitData[tblSplit.ActiveRow].Amount = 0)) or
       ((SplitData[tblSplit.ActiveRow].Amount = 0) and (V <> 0)) then
      SplitData[tblSplit.ActiveRow].Amount := V;

    if key = '%' then
      SplitData[ RowNum].LineType := mltPercentage;

    if key in [ '$', '£', '€' ] then
      SplitData[ RowNum].LineType := mltDollarAmt;

    Key := #0;

    tblSplit.AllowRedraw := false;
    try
      tblSplit.InvalidateCell(RowNum,TypeCol);
      tblSplit.InvalidateCell(RowNum,AmountCol);
      tblSplit.InvalidateCell(RowNum,PercentCol);
    finally
      tblSplit.AllowRedraw := true;
      UpdateTotal;
    end;

  end;
end;

procedure TdlgMemorise.ColGSTCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F7 ) then begin
    Msg.CharCode := VK_F7;
    ColGSTCode.SendKeyToTable(Msg);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgMemorise.DoDitto;
var
  Msg            : TWMKey;
  FieldId        : integer;
  DittoOK        : boolean;
Begin
   with tblSplit do begin
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if alreading in edit state

      DittoOK := false;
      FieldID := tblSplit.ActiveCol;
      case FieldID of
         AcctCol: begin
            //make sure current cell is blank and that previous trx is not dissected
            if (Trim(TEdit(ColAcct.CellEditor).Text) = '') then
            begin
              TEdit(ColAcct.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].AcctCode;
              DittoOK := true;
            end;
         end;

         DescCol:
           begin
            if (Trim(TEdit(ColDesc.CellEditor).Text) = '') then begin
              TEdit(ColDesc.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].Desc;
              DittoOK := true;
            end;
           end;

         JobCol:
           begin
            if (Trim(TEdit(ColJob.CellEditor).Text) = '') then begin
              TEdit(ColJob.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].JobCode;
              DittoOK := true;
            end;
           end;

         NarrationCol: begin
            if (Trim(TEdit(ColNarration.CellEditor).Text) = '') then begin
              TEdit(ColNarration.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].Narration;
              DittoOK := true;
            end;
         end;

         GSTCodeCol : begin
            if (Trim(TEdit(ColGSTCode.CellEditor).Text) = '') then begin
               TEdit(ColGSTCode.CellEditor).Text := SplitData[tblSplit.ActiveRow-1].GSTClassCode;
               DittoOK := true;
            end;
         end;

         AmountCol: begin
            if (TOvcNumericField(ColPercent.CellEditor).AsFloat = 0) then begin
               if SplitData[tblSplit.ActiveRow-1].Linetype = mltPercentage then
                 TOvcNumericField(ColAmount.CellEditor).AsFloat := 0.0
               else
               begin
                 SplitData[tblSplit.ActiveRow].LineType := mltDollarAmt;
                 TOvcNumericField(ColAmount.CellEditor).AsFloat := SplitData[tblSplit.ActiveRow-1].Amount;
                 InvalidateRow(ActiveRow);
               end;
               DittoOK := true;
            end;
         end;

         PercentCol: begin
            if (TOvcNumericField(ColPercent.CellEditor).AsFloat = 0) then begin
               if SplitData[tblSplit.ActiveRow-1].Linetype = mltPercentage then
               begin
                 SplitData[tblSplit.ActiveRow].LineType := mltPercentage;
                 TOvcNumericField(ColPercent.CellEditor).AsFloat := SplitData[tblSplit.ActiveRow-1].Amount;
                 InvalidateRow(ActiveRow);                 
               end
               else
                 TOvcNumericField(ColPercent.CellEditor).AsFloat := 0.0;
               DittoOK := true;
            end;
         end;

         PayeeCol: begin
            if (TOvcNumericField(ColPayee.CellEditor).AsInteger = 0) then begin
               TOvcNumericField(ColPayee.CellEditor).AsInteger := SplitData[tblSplit.ActiveRow-1].Payee;
               DittoOK := true;
            end;
         end;
      end;

      if DittoOK then begin
         //if field was updated then save the edit and move right
         if not StopEditingState(True) then exit;
         if (FieldID in [AcctCol, DescCol, NarrationCol, GSTCodeCol,
            AmountCol, PercentCol, TypeCol, PayeeCol]) then
         begin
           Msg.CharCode := VK_RIGHT;
           ColAcct.SendKeyToTable(Msg);
         end;
      end
      else begin
         //field not updated, abandon edit and don't move off current cell
         StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
      end;
   end;
end;

procedure TdlgMemorise.tblSplitEnteringRow(Sender: TObject;
  RowNum: Integer);
begin
  //sBar.Panels[0].Text := Format( '%d of %d', [ tblSplit.ActiveRow, GLCONST.Max_mx_Lines ] );
  ExistingCode := SplitData[tblSplit.ActiveRow].AcctCode;
end;

// #1727 - add more shortcuts to the right-click menu

procedure TdlgMemorise.LocaliseForm;
var LCur: string[5];
begin
  if Assigned( fBankAccount)  then
     LCur := fBankAccount.CurrencySymbol
  else
     LCur := MyClient.CurrencySymbol;

  colLineType.Items.Clear;
  colLineType.Items.Add( '%' );
  colLineType.Items.Add( LCur );

  FCountry := MyClient.clFields.clCountry;
  FTaxName := MyClient.TaxSystemNameUC;
  Header.Headings[ GSTCodeCol ] := FTaxName;
  Header.Headings[ TypeCol ] := '%' + '/' + LCur;

  With FixedAmount1 do
      Caption := 'Apply &fixed amount                             ' + LCur;
      
  With LookupGSTClass1 do
     Caption := Localise( FCountry, Caption );
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.LookupGSTClass1Click(Sender: TObject);
begin
  Self.DoGSTLookup;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.mnuMatchStatementDetailsClick(Sender: TObject);
begin
  chkStatementDetails.Checked := true;

  eStatementDetails.Text := StringReplace(fMemTranSortedList.GetPRec(tblTran.ActiveRow-1)^.Statement_Details, '&&', '&', [rfReplaceAll]);
  eStatementDetails.SetFocus;
  RefreshMemTransactions();
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.CopyContentoftheCellAbove1Click(Sender: TObject);
begin
  Self.DoDitto;
end;

procedure TdlgMemorise.AmountApplyRemainingAmount1Click(Sender: TObject);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if (ActiveCol <> PercentCol) and (ActiveCol <> AmountCol) then
    begin
      if not StopEditingState(True) then Exit;
      Col := ActiveCol;
      ActiveCol := PercentCol;
    end;
    Self.CompleteAmount;
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgMemorise.FillData(aMem: TMemorisation);
var
  AmountMatchType : byte;
  I : integer;
begin
  cmbType.Text := inttostr(aMem.mdFields.mdType) + ':' + MyClient.clFields.clShort_Name[aMem.mdFields.mdType];
  eRef.Text := aMem.mdFields.mdReference;

  case MyClient.clFields.clCountry of
    whNewZealand : begin
      eCode.Text             := aMem.mdFields.mdAnalysis;
      eStatementDetails.Text := StringReplace(aMem.mdFields.mdStatement_Details, '&&', '&', [rfReplaceAll]);
      ePart.Text             := aMem.mdFields.mdParticulars;
      eOther.Text            := aMem.mdFields.mdOther_Party;
    end;
    whAustralia, whUK : begin
      eCode.Text             := aMem.mdFields.mdParticulars;
      eStatementDetails.Text := StringReplace(aMem.mdFields.mdStatement_Details, '&&', '&', [rfReplaceAll]);
      ePart.Text             := '';
      eOther.Text            := '';
    end;
  end;

  if aMem.mdFields.mdFrom_Date > 0 then
  begin
    cbFrom.Checked := True;
    EdateFrom.AsStDate :=  BKNull2St(aMem.mdFields.mdFrom_Date);
  end
  else
    EdateFrom.AsStDate := -1;

  if aMem.mdFields.mdUntil_Date > 0 then
  begin
    cbTo.Checked := True;
    EdateTo.AsStDate :=  BKNull2St(aMem.mdFields.mdUntil_Date);
  end
  else
    EdateTo.AsStDate := -1;

  eNotes.Text := aMem.mdFields.mdNOtes;
  //set amount and combo
  AmountToMatch := aMem.mdFields.mdAmount;

  if AmountToMatch < 0 then
  begin
    AmountMultiplier := -1;
    cbMinus.ItemIndex := 0;
  end
  else
  begin
    AmountMultiplier := 1;
    cbMinus.ItemIndex := 1;
  end;

  nValue.AsFloat := Money2Double( AmountToMatch) * AmountMultiplier;
  //set check boxes, set loading so click events dont fire

  cRef.Checked := aMem.mdFields.mdMatch_on_Refce;
  case MyClient.clFields.clCountry of
    whNewZealand : begin
      cCode.Checked  := aMem.mdFields.mdMatch_on_Analysis;
      chkStatementDetails.Checked := aMem.mdFields.mdMatch_On_Statement_Details;
      cPart.Checked  := aMem.mdFields.mdMatch_on_Particulars;
      cOther.Checked := aMem.mdFields.mdMatch_on_Other_Party;
    end;
    whAustralia, whUK : begin
      cCode.Checked  := aMem.mdFields.mdMatch_on_Particulars;
      chkStatementDetails.Checked := aMem.mdFields.mdMatch_On_Statement_Details;
      cPart.Checked  := false;
      cOther.Checked := false;
    end;
  end;

  cNotes.Checked  := aMem.mdFields.mdMatch_on_Notes;

  cValue.Checked  := aMem.mdFields.mdMatch_on_Amount <> mxNo;
  AmountMatchType := aMem.mdFields.mdMatch_on_Amount;
  if AmountMultiplier = -1 then
  begin
    //need to reverse the match type because real value is -ve
    case AmountMatchType of
      mxAmtGreaterThan    : AmountMatchType := mxAmtLessThan;
      mxAmtGreaterOrEqual : AmountMatchType := mxAmtLessOrEqual;
      mxAmtLessThan       : AmountMatchType := mxAmtGreaterThan;
      mxAmtLessOrEqual    : AmountMatchType := mxAmtGreaterOrEqual;
    end;
  end;
  SetComboIndexByIntObject( AmountMatchType, cmbValue);

  if aMem.mdFields.mdUse_Accounting_System then
  begin
    chkAccountSystem.Checked := True;
    if not assigned(adminSystem) then
    begin
      // Better have something...
      // Can be Au only
      cbAccounting.items.Clear;

      for i := saMin to saMax do
      begin
        if ((not Software.ExcludeFromAccSysList(MyClient.clFields.clCountry, i)) or
           ( i = MyClient.clFields.claccounting_system_used)) then
          cbAccounting.items.AddObject(saNames[i], TObject( i ) );
      end;
    end;
    AccountingSystem := aMem.mdFields.mdAccounting_System;

    // Better see them...
    chkAccountSystem.Visible := True;
    cbAccounting.Visible := True;
  end
  else
  begin
    chkAccountSystem.Checked := False;
    AccountingSystem := MyClient.clFields.clAccounting_System_Used;
  end;
end;

procedure TdlgMemorise.FillSplitData(aMem : TMemorisation);
var
  I : integer;
  MemLine : pMemorisation_Line_Rec;
  pAcct : pAccount_Rec;
begin
  for i := aMem.mdLines.First to aMem.mdLines.Last do
  begin
    MemLine := aMem.mdLines.MemorisationLine_At(i);
    SplitData[ i+1].AcctCode            := MemLine^.mlAccount;
    SplitData[ i+1].GST_Has_Been_Edited := MemLine^.mlGST_Has_Been_Edited;
    pAcct := MyClient.clChart.FindCode( MemLine^.mlAccount);
    if Assigned( pAcct) then begin
      SplitData[ i+1].Desc   := pAcct^.chAccount_Description;
    end
    else begin
      SplitData[ i+1].Desc  := '';
    end;
    SplitData[ i+1].JobCode  := MemLine^.mlJob_Code;
    //load in the gst class code.  If this is master memorisation and the gst
    //has not been edited then load in the current default for the account code
    //There is no need to do this for client memorisations because they will be
    //updated when the chart is changed
    if aMem.mdFields.mdFrom_Master_List and ( not MemLine^.mlGST_Has_Been_Edited) then begin
      //load default for chart
      SplitData[ i+1].GSTClassCode  := GetGSTClassCode( MyClient, MyClient.clChart.GSTClass( MemLine^.mlAccount));
    end
    else begin
      //memorisation stores class no so load in class id
      SplitData[ i+1].GSTClassCode     := GetGSTClassCode( MyClient, MemLine^.mlGST_Class);
    end;
    if MemLine^.mlLine_Type = mltPercentage then
      SplitData[ i+1].Amount := Percent2Double( MemLine^.mlPercentage)
    else
      SplitData[ i+1].Amount := Money2Double( MemLine^.mlPercentage);
    SplitData[ i+1].Narration := MemLine^.mlGL_Narration;

    if MemLine^.mlAccount <> '' then
      SplitData[ i+1].LineType := MemLine^.mlLine_Type
    else
      SplitData[ i+1].LineType := pltPercentage;

    SplitData[ i+1].Payee := MemLine^.mlPayee;

    SplitData[ i+1].SF_PCFranked := MemLine^.mlSF_PCFranked;
    SplitData[ i+1].SF_PCUnFranked := MemLine^.mlSF_PCUnFranked;

    SplitData[ i+1].SF_Member_ID := MemLine^.mlSF_Member_ID;
    SplitData[ i+1].SF_Fund_ID   := MemLine^.mlSF_Fund_ID;
    SplitData[ i+1].SF_Fund_Code := MemLine^.mlSF_Fund_Code;
    SplitData[ i+1].SF_Trans_ID  := MemLine^.mlSF_Trans_ID;
    SplitData[ i+1].SF_Trans_Code  := MemLine^.mlSF_Trans_Code;
    SplitData[ i+1].SF_Member_Account_ID := MemLine^.mlSF_Member_Account_ID;
    SplitData[ i+1].SF_Member_Account_Code := MemLine^.mlSF_Member_Account_Code;
    SplitData[ i+1].SF_Member_Component := MemLine^.mlSF_Member_Component;

    SplitData[ i+1].Quantity := MemLine^.mlQuantity;

    SplitData[ i+1].SF_GDT_Date := MemLine^.mlSF_GDT_Date;
    SplitData[ i+1].SF_Tax_Free_Dist := MemLine^.mlSF_Tax_Free_Dist;
    SplitData[ i+1].SF_Tax_Exempt_Dist := MemLine^.mlSF_Tax_Exempt_Dist;
    SplitData[ i+1].SF_Tax_Deferred_Dist := MemLine^.mlSF_Tax_Deferred_Dist;
    SplitData[ i+1].SF_TFN_Credits := MemLine^.mlSF_TFN_Credits;
    SplitData[ i+1].SF_Foreign_Income := MemLine^.mlSF_Foreign_Income;
    SplitData[ i+1].SF_Foreign_Tax_Credits := MemLine^.mlSF_Foreign_Tax_Credits;
    SplitData[ i+1].SF_Capital_Gains_Indexed := MemLine^.mlSF_Capital_Gains_Indexed;
    SplitData[ i+1].SF_Capital_Gains_Disc := MemLine^.mlSF_Capital_Gains_Disc;
    SplitData[ i+1].SF_Capital_Gains_Other := MemLine^.mlSF_Capital_Gains_Other;
    SplitData[ i+1].SF_Other_Expenses := MemLine^.mlSF_Other_Expenses;
    SplitData[ i+1].SF_Interest := MemLine^.mlSF_Interest;
    SplitData[ i+1].SF_Capital_Gains_Foreign_Disc := MemLine^.mlSF_Capital_Gains_Foreign_Disc;
    SplitData[ i+1].SF_Rent := MemLine^.mlSF_Rent;
    SplitData[ i+1].SF_Special_Income := MemLine^.mlSF_Special_Income;
    SplitData[ i+1].SF_Other_Tax_Credit := MemLine^.mlSF_Other_Tax_Credit;
    SplitData[ i+1].SF_Non_Resident_Tax := MemLine^.mlSF_Non_Resident_Tax;
    SplitData[ i+1].SF_Foreign_Capital_Gains_Credit := MemLine^.mlSF_Foreign_Capital_Gains_Credit;
    SplitData[ i+1].SF_Capital_Gains_Fraction_Half := MemLine^.mlSF_Capital_Gains_Fraction_Half;
    SplitData[ i+1].SF_Edited := MemLine^.mlSF_Edited;

    //DN BGL360 Extended fields
    SplitData[ i+1 ].SF_Other_Income                            := MemLine^.mlSF_Other_Income;
    SplitData[ i+1 ].SF_Other_Trust_Deductions                  := MemLine^.mlSF_Other_Trust_Deductions;
    SplitData[ i+1 ].SF_CGT_Concession_Amount                   := MemLine^.mlSF_CGT_Concession_Amount;
    SplitData[ i+1 ].SF_CGT_ForeignCGT_Before_Disc              := MemLine^.mlSF_CGT_ForeignCGT_Before_Disc;
    SplitData[ i+1 ].SF_CGT_ForeignCGT_Indexation               := MemLine^.mlSF_CGT_ForeignCGT_Indexation;
    SplitData[ i+1 ].SF_CGT_ForeignCGT_Other_Method             := MemLine^.mlSF_CGT_ForeignCGT_Other_Method;
    SplitData[ i+1 ].SF_CGT_TaxPaid_Indexation                  := MemLine^.mlSF_CGT_TaxPaid_Indexation;
    SplitData[ i+1 ].SF_CGT_TaxPaid_Other_Method                := MemLine^.mlSF_CGT_TaxPaid_Other_Method;
    SplitData[ i+1 ].SF_Other_Net_Foreign_Income                := MemLine^.mlSF_Other_Net_Foreign_Income;
    SplitData[ i+1 ].SF_Cash_Distribution                       := MemLine^.mlSF_Cash_Distribution;
    SplitData[ i+1 ].SF_AU_Franking_Credits_NZ_Co               := MemLine^.mlSF_AU_Franking_Credits_NZ_Co;
    SplitData[ i+1 ].SF_Non_Res_Witholding_Tax                  := MemLine^.mlSF_Non_Res_Witholding_Tax;
    SplitData[ i+1 ].SF_LIC_Deductions                          := MemLine^.mlSF_LIC_Deductions;
    SplitData[ i+1 ].SF_Non_Cash_CGT_Discounted_Before_Discount := MemLine^.mlSF_Non_Cash_CGT_Discounted_Before_Discount;
    SplitData[ i+1 ].SF_Non_Cash_CGT_Indexation                 := MemLine^.mlSF_Non_Cash_CGT_Indexation;
    SplitData[ i+1 ].SF_Non_Cash_CGT_Other_Method               := MemLine^.mlSF_Non_Cash_CGT_Other_Method;
    SplitData[ i+1 ].SF_Non_Cash_CGT_Capital_Losses             := MemLine^.mlSF_Non_Cash_CGT_Capital_Losses;
    SplitData[ i+1 ].SF_Share_Brokerage                         := MemLine^.mlSF_Share_Brokerage;
    SplitData[ i+1 ].SF_Share_Consideration                     := MemLine^.mlSF_Share_Consideration;
    SplitData[ i+1 ].SF_Share_GST_Amount                        := MemLine^.mlSF_Share_GST_Amount;
    SplitData[ i+1 ].SF_Share_GST_Rate                          := MemLine^.mlSF_Share_GST_Rate;
    SplitData[ i+1 ].SF_Cash_Date                               := MemLine^.mlSF_Cash_Date;
    SplitData[ i+1 ].SF_Accrual_Date                            := MemLine^.mlSF_Accrual_Date;
    SplitData[ i+1 ].SF_Record_Date                             := MemLine^.mlSF_Record_Date;
    SplitData[ i+1 ].SF_Contract_Date                           := MemLine^.mlSF_Contract_Date;
    SplitData[ i+1 ].SF_Settlement_Date                         := MemLine^.mlSF_Settlement_Date;
  end;
end;

procedure TdlgMemorise.FixedAmount1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltDollarAmt then exit;
  ApplyAmountShortcut('$');
end;

procedure TdlgMemorise.PercentageofTotal1Click(Sender: TObject);
begin
  if SplitData[tblSplit.ActiveRow].LineType = mltPercentage then exit;
  ApplyAmountShortcut('%');
end;

procedure TdlgMemorise.popMemPopup(Sender: TObject);
begin
   if sbtnSuper.Visible then begin
       ClearSuperfundDetails1.Visible := SplitData[tblSplit.ActiveRow].SF_Edited;
   end;
end;

procedure TdlgMemorise.ApplyAmountShortcut(Key: Char);
var
  Col: Integer;
begin
  Col := -1;
  with tblSplit do
  begin
    if (ActiveCol <> PercentCol) and (ActiveCol <> AmountCol) then
    begin
      if not StopEditingState(True) then Exit;
      Col := ActiveCol;
      ActiveCol := PercentCol;
    end;
    StartEditingState;
    Self.ColAmountKeyPress(tblSplit, Key);
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgMemorise.tblSplitMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Catch Right Click and decide which PopUp to display
var
  ColEstimate, RowEstimate : integer;
begin
{$IFNDEF SmartBooks}
  if (Button = mbRight) then begin
    //estimate where click happened
    if tblSplit.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then
      exit;
    // Select row
    tblSplit.SetFocus;
    tblSplit.ActiveRow := RowEstimate;
    ShowPopup( x,y,popMem);
  end;
{$ENDIF}
end;

procedure TdlgMemorise.UpdateMoreOptions();
begin
  if fShowMoreOptions then
  begin
    btnShowMoreOptions.Caption := 'Hide more &options';

    cRef.Visible   := true;
    eRef.Visible   := true;
    cCode.Visible  := true;
    eCode.Visible  := true;
    cNotes.Visible := true;
    eNotes.Visible := true;

    case MyClient.clFields.clCountry of
      whNewZealand : begin
        pnlDetails.Height := 207;

        cPart.Visible    := true;
        ePart.Visible    := true;
        cOther.Visible   := true;
        eOther.Visible   := true;
      end;
      whAustralia, whUK : begin
        pnlDetails.Height := 177;
      end;
    end;
  end
  else
  begin
    btnShowMoreOptions.Caption := 'Show more &options';
    pnlDetails.Height := 117;

    cRef.Visible   := false;
    eRef.Visible   := false;
    cCode.Visible  := false;
    eCode.Visible  := false;
    cNotes.Visible := false;
    eNotes.Visible := false;

    if MyClient.clFields.clCountry = whNewZealand then
    begin
      cPart.Visible    := false;
      ePart.Visible    := false;
      cOther.Visible   := false;
      eOther.Visible   := false;
    end;
  end;
end;

procedure TdlgMemorise.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblSplit.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;

procedure TdlgMemorise.ShowTranPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblTran.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;

procedure TdlgMemorise.ColAcctKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Account : ShortString;
  Msg     : TWMKey;
begin
  if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAcct.CellEditor),RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(TEdit(colAcct.CellEditor),RemovingMask);

  if not Assigned(MyClient) then exit;

  Account := TEdit(ColAcct.CellEditor).text;
  if MyClient.clChart.CanPressEnterNow(Account,True) then
  begin
     TEdit(ColAcct.CellEditor).text := Account;
     if (ExistingCode = '') and // new row started and previous row had a payee
        (tblSplit.ActiveRow > 1) and (SplitData[tblSplit.ActiveRow-1].Payee <> 0) then
     begin
        SplitData[tblSplit.ActiveRow].Payee := SplitData[tblSplit.ActiveRow-1].Payee;
        tblSplit.InvalidateCell(tblSplit.ActiveRow, PayeeCol);
     end;
     SplitData[tblSplit.ActiveRow].AcctCode := Account;
     ExistingCode := Account;
     Msg.CharCode := VK_RIGHT;
     ColAcct.SendKeyToTable(Msg);
  end;
end;

procedure TdlgMemorise.ColAcctExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(colAcct.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(colAcct.CellEditor),RemovingMask);
end;

procedure TdlgMemorise.ColPayeeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the payee is invalid, show it in red
var
  R   : TRect;
  C   : TCanvas;
  S   : Integer;
begin
   If ( data = nil ) then exit;
   //if selected dont do anything
   S := Integer( Data^ );
   If Assigned(MyClient.clPayee_List.Find_Payee_Number(S)) then exit;
   R := CellRect;
   C := TableCanvas;
   //paint background
   if (S <> 0) then
     C.Brush.Color := clRed
   else
     C.Brush.Color := CellAttr.caColor;

   C.FillRect( R );
   DrawText(C.Handle, '', 0, R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   //paint border
   C.Pen.Color := CellAttr.caColor;
   C.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);
   {draw data}
   InflateRect( R, -2, -2 );

   if Odd(RowNum) then
     C.Font.Color := clwhite
   else
     C.Font.Color := AltLineColor;

   if (CellAttr.caColor <> bkBranding.SelectionColor) then
     DrawText(C.Handle, PChar( IntToStr(S) ), StrLen( PChar( IntToStr(S) ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
   DoneIt := True;
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.colTranDateOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawTextOnTranCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.colTranAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawtAccountOnTranCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Data, DoneIt);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.colTranStatementDetailsOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawTextOnTranCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.colTranCodedByOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawTextOnTranCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TdlgMemorise.ColPayeeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
begin
  //check for lookup key
  if ( Key = VK_F3 ) then begin
    Msg.CharCode := VK_F3;
    ColGSTCode.SendKeyToTable(Msg);
  end;
end;

procedure TdlgMemorise.DoPayeeLookup;
var
   Msg           : TWMKey;
   InEditOnEntry : boolean;
   PayeeCode : Integer;
begin
    with tblSplit do begin
       if not StopEditingState(True) then
          Exit;
       if (ActiveCol <> PayeeCol) then
          ActiveCol := PayeeCol;

       InEditOnEntry := InEditingState;
       if not InEditOnEntry then begin
          if not StartEditingState then Exit;   //returns true if already in edit state
       end;

       PayeeCode := TOvcNumericField(colPayee.CellEditor).AsInteger;
       if PickPayee(PayeeCode) then begin
           //if get here then have a valid char from the picklist
           TOvcNumericField(colPayee.CellEditor).AsInteger := PayeeCode;
           PopulateDataFromPayee(PayeeCode);
           Msg.CharCode := VK_RIGHT;
           colPayee.SendKeyToTable(Msg);
       end
       else begin
           if not InEditOnEntry then begin
              StopEditingState(true);  //end edit
           end;
       end;
    end;
end;

procedure TdlgMemorise.PopulateDataFromPayee(PayeeCode: integer; ChangeActiveCol: boolean = True);
var
  AcctCode              : string;
  APayee                : TPayee;
  isPayeeDissected      : boolean;
  LinesRequired         : integer;
  Narration             : string;
  PayeeLine             : pPayee_Line_Rec;
  ActiveRow             : integer;
  PayeeSplit            : PayeeSplitTotals;
  PayeeSplitPct         : PayeeSplitPercentages;
  PayeeFractionOfAmount : extended;
  GSTClass              : integer;
  RecodeRequired        : boolean;
  OriginalPayee         : integer;
  SplitDataPercent      : double;

  function GetRemainingAmount: extended;
  var
    i: integer;
    SplitDataTotal: extended;
  begin
    SplitDataTotal := 0;
    for i := Low(SplitData) to High(SplitData) do
    begin
      if (i >= tblSplit.ActiveRow) and (i < tblSplit.ActiveRow + APayee.pdLines.ItemCount) then
        Continue; // skip the lines that the payee is going to overwrite anyway
      if (SplitData[i].LineType = 0) then
        // Percentage
        SplitDataTotal := SplitDataTotal + (SourceTransaction.txAmount * SplitData[i].Amount / 100);
    end;
    Result := SourceTransaction.txAmount - SplitDataTotal;
  end;

  function IsRowBlank(RowNum: integer): boolean;
  begin
    Result := not ((SplitData[RowNum].AcctCode     <> '') or
                   (SplitData[RowNum].Desc         <> '') or
                   (SplitData[RowNum].GSTClassCode <> '') or
                   (SplitData[RowNum].Amount       <> 0) or
                   (SplitData[RowNum].Narration    <> '') or
                   (SplitData[RowNum].Payee        <> 0));
  end;

  // If we insert a payee before existing data, we need to move that
  // data so that it doesn't get overwritten
  procedure MoveSplitDataLines(NumLines: integer);
  var
    RowNum           : integer;
    AdjustBy         : integer;
    i                : integer;
    FirstNonBlankRow : integer;
  begin
    if NumLines < 1 then
      Exit;
    RowNum := tblSplit.ActiveRow + 1;
    AdjustBy := 0;
    FirstNonBlankRow := -1;
    for i := 0 to NumLines - 1 do
    begin
      if not IsRowBlank(RowNum + i) then
      begin
        AdjustBy := NumLines - i;
        FirstNonBlankRow := RowNum + i;
        break;
      end;
    end;

    if FirstNonBlankRow > -1 then    
      for i := High(SplitData) downto FirstNonBlankRow do
        SplitData[i] := SplitData[i - AdjustBy];

    tblSplit.Refresh;
  end;

  procedure CreatePayeeLines;
  var
    i: integer;
    AccountCode: pAccount_Rec;
  begin
    if ChangeActiveCol then
      tblSplit.ActiveCol := AcctCol;
    if not Assigned(SourceTransaction) then
    begin
      SplitDataPercent := 0;
      // The percentages in the payee should only take up what's left over after the %'s for
      // the existing rows, excluding those which will be replaced by the payee (if any)
      for i := Low(SplitData) to High(SplitData) do
        if (SplitData[i].LineType = 0) then
          if (i < tblSplit.ActiveRow) or (i > tblSplit.ActiveRow + aPayee.pdLines.ItemCount - 1) then
            SplitDataPercent := SplitDataPercent + SplitData[i].Amount;
      PayeeFractionOfAmount := (100 - SplitDataPercent) / 100;
    end
    else
    begin
      PayeePercentageSplit(SourceTransaction.txAmount, APayee, PayeeSplit, PayeeSplitPct);
      if (SourceTransaction.txAmount = 0) then
        PayeeFractionOfAmount := 1
      else
        PayeeFractionOfAmount := GetRemainingAmount / SourceTransaction.txAmount;
    end;
    MoveSplitDataLines(APayee.pdLines.ItemCount - 1);
    for i := 0 to APayee.pdLines.ItemCount - 1 do
    begin
      ActiveRow := tblSplit.ActiveRow;
      PayeeLine := APayee.pdLines.PayeeLine_At(i);
      GSTClass := PayeeLine.plGST_Class;
      SplitData[i+ActiveRow].AcctCode     := PayeeLine.plAccount;
      if (PayeeLine.plAccount <> '') then
      begin
        AccountCode := MyClient.clChart.FindCode(PayeeLine.plAccount);
        if Assigned(AccountCode) then        
          SplitData[i+ActiveRow].Desc     := AccountCode.chAccount_Description;
      end;
      SplitData[i+ActiveRow].Narration    := PayeeLine.plGL_Narration;
      SplitData[i+ActiveRow].Payee        := PayeeCode;
      if (GSTClass <> 0) then
        SplitData[i+ActiveRow].GSTClassCode := MyClient.clFields.clGST_Class_Codes[GSTClass];
      // LineType of 0 = percentage, 1 = fixed amount
      if not Assigned(PayeeSplitPct) then
      begin
        if APayee.pdLines.PayeeLine_At(i)^.plLine_Type = 0 then
          SplitData[i+ActiveRow].Amount := (APayee.pdLines.PayeeLine_At(i)^.plPercentage / 10000) *
                                           PayeeFractionOfAmount
        else
          SplitData[i+ActiveRow].Amount := APayee.pdLines.PayeeLine_At(0)^.plPercentage / 100;
      end
      else
      begin
        if APayee.pdLines.PayeeLine_At(i)^.plLine_Type = 0 then
          SplitData[i+ActiveRow].Amount   := (PayeeSplitPct[i] / 10000) * PayeeFractionOfAmount
        else
          SplitData[i+ActiveRow].Amount   := APayee.pdLines.PayeeLine_At(0)^.plPercentage / 100;
      end;
      SplitData[i+ActiveRow].LineType := APayee.pdLines.PayeeLine_At(i)^.plLine_Type;
    end;
    UpdateTotal;
  end;

begin
  PopulatePayee := False;
  PayeeUsed := True;
  tmrPayee.Enabled := False;
  OriginalPayee := SplitData[tblSplit.ActiveRow].Payee;
  APayee := MyClient.clPayee_List.Find_Payee_Number(PayeeCode);
  isPayeeDissected := APayee.IsDissected;
  if isPayeeDissected then
    LinesRequired := APayee.pdLines.ItemCount
  else
    LinesRequired := 1;
  if LinesRequired = 0 then
    exit;
  if (SplitData[tblSplit.ActiveRow].AcctCode <> '') then
  begin
    RecodeRequired := false;
    //account code must be there already
    PayeeLine := APayee.FirstLine;
    if ( PayeeLine <> nil) then
    begin
      AcctCode := SplitData[tblSplit.ActiveRow].AcctCode;
      Narration := SplitData[tblSplit.ActiveRow].Narration;
      //compare with payee details
      if IsPayeeDissected
      or (AcctCode <> PayeeLine.plAccount)
      or (( Narration <> PayeeLine.plGL_Narration) and ( PayeeLine.plGL_Narration <> '')) then
         RecodeRequired := true;
      if RecodeRequired then
      begin
        case PayeeRecodeDlg.AskRecodeOnPayeeChange of
          prCancel :
          begin
            with tblSplit do
              TOvcNumericField(ColPayee.CellEditor).AsInteger := OriginalPayee;
          end;
          prNarrationOnly :
          begin
            SplitData[tblSplit.ActiveRow].Narration := PayeeLine.plGL_Narration;
            SplitData[tblSplit.ActiveRow].Payee := PayeeCode;
          end;
          else
          begin
            CreatePayeeLines;
          end;
        end;
      end else
        CreatePayeeLines;
    end;
  end else
    CreatePayeeLines;

  tblSplit.Refresh;
  PayeeUsed := False;
  tmrPayee.Enabled := True;
end;

procedure TdlgMemorise.DoSuperClear;
begin
    with tblSplit do begin
      if not StopEditingState(True) then
         Exit;
      if ActiveRow <= 0 then
         Exit;

      ClearSuperfundDetails(@SplitData[ActiveRow]);

      tblSplit.AllowRedraw := false;
      try
         tblSplit.InvalidateRow(ActiveRow);
      finally
         tblSplit.AllowRedraw := true;
      end;

    end;
end;

procedure TdlgMemorise.DoSuperEdit;
var Move: TFundNavigation;
    BA: TBank_Account;
begin
   with tblSplit do begin
      if not StopEditingState(True) then
         Exit;
       // Check the row ??

       if High(SplitData) = ActiveRow then
          Move := fnIsLast
       else if ActiveRow = 1 then
          Move := fnIsFirst
       else
          Move := fnNothing;

       if fDlgEditMode in ALL_MASTER then
          BA := nil
       else
          BA := fBankAccount;

       if SuperFieldsUtils.EditSuperFields( SourceTransaction,SplitData[ActiveRow] , Move, FSuperTop, FSuperLeft,sfMem, BA) then
       begin
          tblSplit.AllowRedraw := false;
          try
             UpdateFields(tblSplit.ActiveRow);
             tblSplit.InvalidateRow(ActiveRow);
          finally
             tblSplit.AllowRedraw := true;
          end;
          tblSplit.Refresh;

          if Move = fnGoForward then
          begin
            ActiveRow := ActiveRow + 1;
            DoSuperEdit;
          end
          else if Move = fnGoBack then
          begin
            ActiveRow := ActiveRow - 1;
            DoSuperEdit;
          end;
        end;


   end;
end;

procedure TdlgMemorise.DrawtAccountOnTranCell(TableCanvas: TCanvas;
                                              const CellRect: TRect;
                                              RowNum, ColNum: Integer;
                                              const CellAttr: TOvcCellAttributes;
                                              aValue: pMemTranSortedListRec;
                                              var DoneIt: Boolean);
begin
  DrawTextOnTranCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr,
                     aValue^.Account, DoneIt, aValue^.HasPotentialIssue);
end;

procedure TdlgMemorise.DrawTextOnTranCell(TableCanvas: TCanvas;
                                          const CellRect: TRect;
                                          RowNum, ColNum: Integer;
                                          const CellAttr: TOvcCellAttributes;
                                          aValue: string;
                                          var DoneIt: Boolean;
                                          aHasPotentialIssue : boolean);
var
  DataRect : TRect;
begin
  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;

  if aHasPotentialIssue then
  begin
    if (RowNum <> TblTran.ActiveRow) or
       (ColNum <> TblTran.ActiveCol) then
      TableCanvas.Brush.Color := clYellow;
  end;

  TableCanvas.FillRect( CellRect );

  DataRect := CellRect;
  InflateRect( DataRect, -2, -2 );

  DrawText( TableCanvas.Handle, PChar( aValue ), StrLen( PChar( aValue ) ), DataRect, DT_OPTIONS_STR );

  DoneIt := true;
end;

procedure TdlgMemorise.eDateFromDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;

procedure TdlgMemorise.eStatementDetailsChange(Sender: TObject);
begin
  fDirty := true;
end;

function AsFloatSort(List: TStringList; Index1, Index2: Integer): Integer;
var
   num1, num2: Double;
begin
   num1 := StrToFloatDef(List[Index1], 0);
   num2 := StrToFloatDef(List[Index2], 0); 

   if num1 < num2 then
     Result := -1
   else if num1 > num2 then
     Result := 1
   else
     Result := 0;
end;

// Fills the cmbType combobox with the relevant entry types, see comments below
procedure TdlgMemorise.PopulateCmbType(BA: TBank_Account; EntryType: byte);
var
  TypeList: TStringList;
  baNum: integer;
  i: integer;
  EntryTypeItemIndex: integer;

  // When the form is first opened, cmbType should show whichever EntryType has
  // been passed into PopulateCmbType, which is the entry type of the transaction
  // this memorisation is being based from, or the entry type of the memorisation
  // which is being edited
  procedure ChooseDefaultEntryType;
  var
    cmbTypeIndex: integer;
  begin
    for cmbTypeIndex := 0 to cmbType.Items.Count - 1 do
    begin
      if (GetTxTypeFromCmbType(cmbTypeIndex) = EntryType) then
      begin
        EntryTypeItemIndex := cmbTypeIndex;
        break;
      end;
    end;
  end;

  // Scans through all the transactions in the account, adds their entry types
  // to TypeList, which will later be used to populate cmbType. Duplicates are ignored.
  procedure AddTxTypes;
  var
    i: integer;
    txType: byte;
  begin
    for i := BA.baTransaction_List.First to BA.baTransaction_List.Last do
    begin
      txType := BA.baTransaction_List.Transaction_At(i).txType;
      TypeList.AddObject(IntToStr(txType), TObject(txType));
    end;
  end;

begin
  if not Assigned(MyClient) then
    Exit;

  TypeList := TStringList.Create;
  try
    TypeList.CustomSort(AsFloatSort);
    TypeList.Sorted := True; // need Sorted = True for ignoring duplicates apparently
    TypeList.Duplicates := dupIgnore;
    if Assigned(BA) then
    begin
      // We have a bank account, so populate the entry type combobox with the entry types from this account
      AddTxTypes;
    end else
    if (MyClient.clBank_Account_List.ItemCount > 0) then
    begin
      // We don't have a bank account, so instead let's fill the entry type combobox with all the
      // entry types from all the accounts in this client. This should only happen for master mems
      for baNum := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
      begin
        BA := MyClient.clBank_Account_List.Bank_Account_At(baNum);
        AddTxTypes;
      end;
    end else
    begin
      // We don't have a bank account, and the client doesn't have any either, so let's fill the
      // entry type combobox with all possible entry types. This should only happen for master mems,
      // and only when the selected client doesn't have any accounts.
      for i := Low(MyClient.clFields.clShort_Name) to High(MyClient.clFields.clShort_Name) do
        if (MyClient.clFields.clShort_Name[i] <> '') then
          TypeList.AddObject(IntToStr(i), TObject(i));
    end;
    // We also need to add whatever the current entry type is, this will usually already be in the list,
    // but won't be if a memorisation is copied from a bank account that contains that entry type to
    // one that doesn't (which it won't if none of the transactions in the account have that entry type).
    // TypeList has the Duplicates property set to dupIgnore so we won't end up with a duplicate
    // in the combobox
    TypeList.AddObject(IntToStr(EntryType), TObject(EntryType));

    TypeList.Sorted := False; // Need sorted = false for CustomSort apparently
    TypeList.CustomSort(AsFloatSort);
    for i := 0 to TypeList.Count - 1 do
      cmbType.Items.AddObject(TypeList.Strings[i] + ': ' + MyClient.clFields.clshort_name[Integer(TypeList.Objects[i])],
                              TypeList.Objects[i]);
    ChooseDefaultEntryType;
    cmbType.ItemIndex := EntryTypeItemIndex;
  finally
    TypeList.Free;
  end;
end;

//------------------------------------------------------------------------------
initialization
   debugMe := debugUnit(UnitName);

end.


