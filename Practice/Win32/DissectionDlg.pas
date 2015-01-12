unit DissectionDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:     Dissect Entries Dlg

  Written:  Sep 1999
  Authors:  Neil, Andy

  Purpose:  Allow the user to dissect a transaction, validate before allowing
            user to ok the dlg.

  Notes:    Is a Modal Form, triggered by calling the function DissectEntry.
            Dissections are stored in a stored TList Object. The pointers in the
            list point to a TWorkDissect_Rec which is used to store the lines
            of the dissection is a structue that is used for editing.
            The WorkDissect list is created in the DissectEntry function call.
            The number of items in the list is MAX_DISSECT_DLG.
            The list is destroyed in the form destroy method

            When editing a cell the following events occur

              OnBeginEdit                         Determine if cell can be edited
              OnGetCellData -> ReadCellForEdit    Provide table with data pointer
              OnEndEdit                           Validate the edited value
              OnGetCellData -> ReadCellForSave    Provide table with data pointer
              OnDoneEdit                          Save back data and update any related fields
}
//- - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - -
interface

uses
   CodingFormConst,
   Windows, Graphics, Menus, StdCtrls, Buttons, ExtCtrls, Messages,
   OvcTCCBx, OvcTCPic, OvcTCBEF, OvcTCNum, OvcTCEdt, OvcTCmmn,
   OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
   Controls, ComCtrls, Classes, Forms, BkConst,
   BAObj32, MoneyDef, BKDefs, Globals, ColFmtListObj, OvcEF, OvcPB, OvcPF,
  RzBmpBtn, RzPanel, RzSplit, StdActns, ActnList, OvcTCBmp, WorkRecDefs,
  RzButton, ovcislb, OsFont, ovctcgly, ovctcbox;

type
  TControlTotals = Record
    ctCount             : Integer;
    ctAmount            : Money;
    ctLocal_Amount      : Money;
    ctRemainder         : Money;
    ctLocal_Remainder   : Money;
    ctGST               : Money;
    ctPercent           : Double;
    ctSpecified_Amount  : Money;
    ctLocal_Specified_Amount : Money;
  end;

  TdlgDissection = class(Tform)
    stbDissect: TStatusBar;
    tblDissect: TOvcTable;
    DissectController: TOvcController;
    hdrColumnHeadings: TOvcTCColHead;
    celAccount: TOvcTCString;
    celAmount: TOvcTCNumericField;
    celGstAmt: TOvcTCNumericField;
    celQuantity: TOvcTCNumericField;
    celNarration: TOvcTCString;
    btnOK: TButton;
    btnCancel: TButton;
    pnlTotals: TPanel;
    lblForBSTotal: TLabel;
    lblBSTotal: TLabel;
    lblForBSRemaining: TLabel;
    lblBSRemaining: TLabel;
    pnlTranDetails: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    lblForBSAmount: TLabel;
    lblAnalysis: TLabel;
    popGST: TPopupMenu;
    mniRecalcGST: TMenuItem;
    celMoneyIn: TOvcTCNumericField;
    celMoneyOut: TOvcTCNumericField;
    celGSTCode: TOvcTCString;
    pfHiddenAmount: TOvcPictureField;
    celPayee: TOvcTCNumericField;
    lblNarration: TLabel;
    Label7: TLabel;
    Shape1: TShape;
    lblDate: TLabel;
    lblRef: TLabel;
    lblAnalysisField: TLabel;
    lblBSAmount: TLabel;
    lblNarrationField: TLabel;
    lblPayee: TLabel;
    ActionList1: TActionList;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    popNotes: TPopupMenu;
    pmiNotesUndo: TMenuItem;
    N1: TMenuItem;
    pmiNotesCut: TMenuItem;
    pmiNotesCopy: TMenuItem;
    pmiNotesPaste: TMenuItem;
    N3: TMenuItem;
    pmiNotesSelectAll: TMenuItem;
    N2: TMenuItem;
    pmiNotesVisible: TMenuItem;
    N100: TMenuItem;
    pmiGotoGrid: TMenuItem;
    pNotes: TRzSizePanel;
    pnlNotes: TPanel;
    Panel2: TPanel;
    memImportNotes: TMemo;
    memNotes: TMemo;
    pnlNotesTitle: TPanel;
    rzPinBtn: TRzBmpButton;
    rzXBtn: TRzBmpButton;
    popDissect: TPopupMenu;
    LookupChart1: TMenuItem;
    LookupPayee1: TMenuItem;
    Sep1: TMenuItem;
    GotoNextUncoded1: TMenuItem;
    GotoNotes1: TMenuItem;
    mniReset: TMenuItem;
    imgStatus: TImage;
    Label2: TLabel;
    lblGSTAmt: TLabel;
    lbltxECodingNotes: TLabel;
    lbltxNotes: TLabel;
    pnlHeaderButtons: TPanel;
    btnChart: TSpeedButton;
    btnPayee: TSpeedButton;
    lblStatus: TLabel;
    sbtnSuper: TSpeedButton;
    EditSuperFields1: TMenuItem;
    LookupGST1: TMenuItem;
    Sep2: TMenuItem;
    AmountGrossupfromGSTAmount1: TMenuItem;
    AmountGrossupfromNetAmount1: TMenuItem;
    AmountFixed: TMenuItem;
    AmountApplyRemainingAmount1: TMenuItem;
    NarrationReplacewithNotes1: TMenuItem;
    NarrationAppendNotes1: TMenuItem;
    CopyContentoftheCellAbove1: TMenuItem;
    AmountPercentage: TMenuItem;
    Amount1: TMenuItem;
    Narration1: TMenuItem;
    Gotonextnote1: TMenuItem;
    Notes1: TMenuItem;
    mniNoteMark: TMenuItem;
    mniNoteMarkAll: TMenuItem;
    mniNoteDelete: TMenuItem;
    btnView: TRzToolButton;
    popView: TPopupMenu;
    mniConfigureCols: TMenuItem;
    mniRestoreCols: TMenuItem;
    N4: TMenuItem;
    Configurecolumns1: TMenuItem;
    Restorecolumndefaults1: TMenuItem;
    actConfigure: TAction;
    actRestore: TAction;
    celPercent: TOvcTCNumericField;
    Label8: TLabel;
    lblPercentTotal: TLabel;
    Label10: TLabel;
    lblPercentRemain: TLabel;
    celAmountType: TOvcTCString;
    celDescription: TOvcTCString;
    celPayeeName: TOvcTCString;
    Insertanewline1: TMenuItem;
    tmrPayee: TTimer;
    N5: TMenuItem;
    EditAccountOnly1: TMenuItem;
    EditAllColumns1: TMenuItem;
    CelJob: TOvcTCString;
    CelJobName: TOvcTCString;
    btnJob: TSpeedButton;
    LookupJobF51: TMenuItem;
    ClearSuperfundDetails1: TMenuItem;
    celTaxInv: TOvcTCCheckBox;
    celForexRate: TOvcTCNumericField;
    celLocalAmount: TOvcTCNumericField;
    lblLCTotalField: TLabel;
    lblLCTotal: TLabel;
    lblLocalCurrencyAmount: TLabel;
    lblForLocalCurrencyAmount: TLabel;
    lblRate: TLabel;
    lblForRate: TLabel;
    lblLCRemaining: TLabel;
    lblLCRemainingField: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    CelAltChartCode: TOvcTCString;
    ConvertAmount1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tblDissectGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblDissectColumnsChanged(Sender: TObject; ColNum1,
      ColNum2: Integer; Action: TOvcTblActions);
    procedure tblDissectGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblDissectActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblDissectUserCommand(Sender: TObject; Command: Word);
    procedure tblDissectEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblDissectDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblDissectEnteringRow(Sender: TObject; RowNum: Integer);
    procedure tblDissectBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure celQuantityChange(Sender: TObject);
    procedure tblDissectActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnChartClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure celAccountKeyPress(Sender: TObject; var Key: Char);
    procedure celAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure stbDissectMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celAmountKeyPress(Sender: TObject; var Key: Char);
    procedure celGstAmtKeyPress(Sender: TObject; var Key: Char);
    procedure mniRecalcGSTClick(Sender: TObject);
    procedure tblDissectMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celGstAmtOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtChange(Sender: TObject);
    procedure btnPayeeClick(Sender: TObject);
    procedure pNotesResize(Sender: TObject);
    procedure memNotesChange(Sender: TObject);
    procedure pnlNotesEnter(Sender: TObject);
    procedure pnlNotesExit(Sender: TObject);
    procedure rzXBtnClick(Sender: TObject);
    procedure rzPinBtnClick(Sender: TObject);
    procedure pmiGotoGridClick(Sender: TObject);
    procedure pmiGridGotoNotes(Sender: TObject);
    procedure pmiNotesVisibleClick(Sender: TObject);
    procedure tblDissectDblClick(Sender: TObject);
    procedure tblDissectEnter(Sender: TObject);
    procedure tblDissectExit(Sender: TObject);
    procedure LookupChart1Click(Sender: TObject);
    procedure LookupPayee1Click(Sender: TObject);
    procedure GotoNextUncoded1Click(Sender: TObject);
    procedure GotoNotes1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniResetClick(Sender: TObject);
    procedure pnlTranDetailsResize(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormDeactivate(Sender: TObject);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure WMVScroll(var Msg : TWMScroll); message WM_VSCROLL;
    procedure tblDissectTopLeftCellChanging(Sender: TObject; var RowNum,
      ColNum: Integer);
    procedure tblDissectKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountExit(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure celPayeeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celGSTCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celQuantityExit(Sender: TObject);
    procedure celAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure sbtnSuperClick(Sender: TObject);
    procedure EditSuperFields1Click(Sender: TObject);
    procedure tblDissectMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LookupGST1Click(Sender: TObject);
    procedure CopyContentoftheCellAbove1Click(Sender: TObject);
    procedure NarrationReplacewithNotes1Click(Sender: TObject);
    procedure NarrationAppendNotes1Click(Sender: TObject);
    procedure AmountGrossupfromGSTAmount1Click(Sender: TObject);
    procedure AmountGrossupfromNetAmount1Click(Sender: TObject);
    procedure AmountFixedClick(Sender: TObject);
    procedure AmountApplyRemainingAmount1Click(Sender: TObject);
    procedure AmountPercentageClick(Sender: TObject);
    procedure celAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mniNoteMarkClick(Sender: TObject);
    procedure mniNoteMarkAllClick(Sender: TObject);
    procedure mniNoteDeleteClick(Sender: TObject);
    procedure Gotonextnote1Click(Sender: TObject);
    procedure celAmountChange(Sender: TObject);
    procedure actConfigureExecute(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure Insertanewline1Click(Sender: TObject);
    procedure tmrPayeeTimer(Sender: TObject);
    procedure EditAccountOnly1Click(Sender: TObject);
    procedure EditAllColumns1Click(Sender: TObject);
    procedure popViewPopup(Sender: TObject);
    procedure CelJobChange(Sender: TObject);
    procedure btnJobClick(Sender: TObject);
    procedure popDissectPopup(Sender: TObject);
    procedure ClearSuperfundDetails1Click(Sender: TObject);
    procedure celLocalAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure celLocalAmountKeyPress(Sender: TObject; var Key: Char);
    procedure celPercentKeyPress(Sender: TObject; var Key: Char);
    procedure ConvertAmount1Click(Sender: TObject);
  private
    FHint              : tHintWindow;
    FStartedEdit       : boolean;
    HintShowing        : boolean;
    ColumnFmtList      : TColFmtList;
    WorkDissect        : TList;  //List of Pointers to Entered Dissection Data
    pTran              : pTransaction_Rec;
    fIsForex           : Boolean;

    AllowAddMinus      : Boolean;  //Auto Add minus in Amount/Qty. Set true on BeginEdit
    AutoPressMinus     : boolean;  //auto add minus for gst amt, qty so that matches sign of amount
    RemovingMask       : boolean;
    PayeeEditable      : boolean;

    dsNotesAlwaysVisible : boolean;

    // Coding Table Line Colors
    clStdLineLight      : integer;
    clStdLineDark       : integer;

    //Temporary variables for data pointer to point to, used in GetCellData
    tmpShortStr        : ShortString;
    tmpDouble          : double;
    tmpBool            : Boolean;
    //tmpInteger         : Integer;
    tmpPayee,
    PayeeRow           : Integer;

    tmpPaintShortStr   : ShortString;
    tmpPaintDouble     : double;
    tmpPaintInteger    : integer;
    FCanUseSuperFundFields, FDontRecalculatePercentages : boolean;
    FSuperTop, FSuperLeft: Integer;
    Undo: Boolean;
    FBankAcct: TBank_Account;
    DefaultEditableCols, AlwaysEditableCols, AlwaysVisibleCols : set of byte;
    Temp_Column_Order             : Array[ 0..32 ] of Byte;
    Temp_Column_Width             : Array[ 0..32 ] of Integer;
    Temp_Column_is_Hidden         : Array[ 0..32 ] of Boolean;
    Temp_Column_Is_Not_Editable   : Array[ 0..32 ] of Boolean;
    FCountry : Byte;
    FControlTotals : TControlTotals;
    BCode : String[3];
    CCode : String[3];
    procedure InitController;
    procedure BuildTableColumns;
    procedure CalcControlTotals( var Count : Integer; var Total, Remainder, GSTAmt, Percent : Double; DollarLinesOnly: Boolean = False );
    procedure UpdateControlTotals;
    function HasPercentLines: Boolean;
    function HasSingle100PercentLine: Boolean;
    procedure SetupColumnFmtList;
    procedure UpdateDisplayTotals(AmountChanged: boolean = false);
    function  GSTDifferentToDefault( pD : pWorkDissect_Rec) : boolean;
    procedure ReadCellforEdit(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
    procedure DoDeleteCell;
    procedure DoAccountLookup;
    procedure DoGSTLookup;
    procedure DoPayeeLookup;
    procedure DoJobLookup;
    procedure UpdateStatusBar;
    procedure AccountEdited(pD: pWorkDissect_Rec);
    procedure AmountEdited(pD: pWorkDissect_Rec);
    procedure PercentEdited(pD: pWorkDissect_Rec );
    function  PayeeEdited(pD: pWorkDissect_Rec; RowNo: Integer) : boolean;
    procedure GSTClassEdited(pD: pWorkDissect_Rec);
    function  ValidDataRow(RowNum: integer): boolean;
    procedure SetColEditMode(EditMode: TEditMode);
    procedure ToggleColEditMode;
    procedure DoCompleteAmount;
    procedure DoDeleteLine;
    procedure DoDitto;
    procedure DoGotoNextUnCode;
    procedure DoGotoNextNote;
    function  FindUnCoded(const TheCurrentRow: integer): integer;
    function  FindNote(const TheCurrentRow: integer): integer;
    procedure RemoveBlanks;
    procedure SetupHelp;
    procedure DoRecalcGST;
    procedure ShowPopUp(x, y: Integer; PopMenu: TPopUpMenu);
    procedure InsertRowsAfter(Row : integer; NewRows : integer);
    procedure DoGotoGrid;
    procedure DoGotoNotes;
    procedure ToggleAlwaysShowNotes;
    procedure UpdateNotesPanel(RowNum: integer);
    procedure SetFormPositionFromINI( DefaultWidth, DefaultHeight : integer);
    function GetCellRect(const RowNum, ColNum: Integer): TRect;
    procedure HideCustomHint;
    procedure ShowCodingHint(const RowNum, ColNum: Integer;
      HintMsg: String);
    procedure ShowHintForCell(const RowNum, ColNum: integer);
    procedure DoCopyNotesToNarration(Append: boolean);
    procedure SetQuantitySign(QuantityChanged : Boolean);
    procedure DoEditSuperFields;
    procedure ApplyAmountShortcut(Key: Char);
    procedure DoCelAmountKeyPress(Sender: TObject; var Key: Char; Move: Boolean = True);
    procedure DoDeleteNote;
    procedure DoMarkNote;
    procedure DoMarkAllNotes;
    procedure ConfigureColumns;
    procedure SaveLayoutForThisAcct;
    procedure LoadLayoutForThisAcct;
    procedure SetupColDefaultSets;
    procedure ResetColumns;
    procedure SaveTempLayout;
    procedure LoadTempLayout;
    procedure ReCalcPercentAmounts;
    procedure DoInsertLine;
    function  CanInsertRowsAfter( Row : integer; NewRows : integer) : boolean;
    procedure UpdateBaseAmounts(pD : pWorkDissect_Rec);
  public
    { Public declarations }
    property BankAcct: TBank_Account read FBankAcct write FBankAcct;
  end;

  function DissectEntry( pT : pTransaction_rec; const NotesVisible : boolean; const SuperVisible: Boolean; BA: TBank_Account; AmountChanged: Boolean = false) : boolean;
//******************************************************************************
implementation
{$R *.DFM}

uses
   WinUtils,
   SysUtils,
   ovcData,
   OvcConst,
   OvcTbCls,
   OvcNf,
   DecimalRounding_JH1,
   bkBranding,
   Malloc,
   BK5Except,
   BKDSIO,
   bkDateUtils,
   bkXPThemes,
   MaintainGroupsfrm,
   bkhelp,
   WarningMoreFrm,
   GenUtils,
   trxList32,
   GSTCalc32,
   LogUtil,
   MoneyUtils,
   InfoMoreFrm,
   AccountLookupFrm,
   GSTLookupFrm,
   clObj32,
   ErrorMoreFrm,
   bkMaskUtils,
   imagesfrm,
   StdHints,
   Software,
{$IFNDEF SmartBooks}
   CAUtils,
{$ENDIF}
   Math,
   NewHints,
   CanvasUtils,
   PayeeLookupFrm,
   PayeeRecodeDlg,
   SuperFieldsUtils,
   TransactionUtils,
   glConst,
   mxUtils,
   PayeeObj, ECollect,
   stStrs, ConfigColumnsFrm, NewReportUtils,
   ForexHelpers,
   CountryUtils,
   MainFrm;
   {,TransactionNotesFrm;}

const
   //**** ALWAYS ADD NEW COLUMNS ONTO THE END BECAUSE ID IS STORED FOR CONFIG COLUMNS
   ceAccount        = 0;    ceMin = 0;
   ceAmount         = 1;
   ceGSTClass       = 2;
   ceGSTAmount      = 3;
   ceQuantity       = 4;
   ceNarration      = 5;
   ceMoneyIn        = 6;                //smartbooks
   ceMoneyOut       = 7;                //smartbooks
   cePayee          = 8;
   cePercent        = 9;
   ceAmountType     = 10;
   ceDescription    = 11;
   cePayeeName      = 12;
   ceJob            = 13;
   ceJobName        = 14;
   ceTaxInvoice     = 15;
   ceForexRate      = 16;
   ceLocalAmount    = 17;
   ceAltChartCode   = 18;

   ceMax = 19;

   UnitName = 'DISSECTIONDLG';

   //Ttable command const
   tcLookup         = ccUserFirst + 1;
   tcEditAll        = ccUserFirst + 2;
   tcPayeeLookup    = ccUserFirst + 3;
   tcComplete       = ccUserFirst + 4;
   tcDeleteCell     = ccUserFirst + 5;
   tcDeleteLine     = ccUserFirst + 6;
   tcDitto          = ccUserFirst + 7;
   tcNextUncoded    = ccUserFirst + 8;
   tcRecalc         = ccUserFirst + 9;
   tcGSTLookup      = ccUserFirst + 10;
   tcGotoNotes      = ccUserFirst + 11;
   tcCopyNotesToNarration = ccUserFirst + 12;
   tcAppendNotesToNarr    = ccUserFirst + 13;
   tcEditSuperFields   = ccUserFirst + 14;
   tcMarkNote       = ccUserFirst + 15;
   tcMarkAllNotes   = ccUserFirst + 16;
   tcDeleteNote     = ccUserFirst + 17;
   tcNextNote       = ccUserFirst + 18;
   tcView           = ccUserFirst + 19;
   tcInsertLine     = ccUserFirst + 20;
   tcJobLookup      = ccUserFirst + 21;
   tcRateLookup     = ccUserFirst + 22;

   tcDummyCommand   = ccUserFirst + 99;

   //Status Panel Constants
   PANELMODE     = 0;
   PANELPROGRESS = 1;
   PANELTEXT     = 2;
   PANELTOTAL    = 3;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.SetupColumnFmtList;
// Setup the table columns
var
   AllowGSTAmtEditing : Boolean;
   AllowGSTClassEditing : boolean;
begin
   with ColumnFmtList do begin
      FreeAll;
      InsColDefnRec( 'Account',    ceAccount,    celAccount,  CalcAcctColWidth( tblDissect.Canvas, tblDissect.Font, 65) + 20, true, true, true, -1 );
      InsColDefnRec( 'A/c Desc',   ceDescription,  celDescription, 150, false, false, false, -1);
{$IFDEF SmartBooks}
      InsColDefnRec( 'Money Out',  ceMoneyOut,   celMoneyOut,  105, true,true, true, -1 );
      InsColDefnRec( 'Money In',   ceMoneyIn,    celMoneyIn,   105, true, true, true, -1 );


{$ELSE}

      if MyClient.HasForeignCurrencyAccounts then begin
        if fIsForex then begin
          InsColDefnRec( 'Amount (' + BCode + ')', ceAmount, celAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, True, CE_AMOUNT_DEF_EDITABLE, csByValue );
          InsColDefnRec( 'Amount (' + CCode + ')', ceLocalAmount, celLocalAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, true, true, csByValue );
        end else
          InsColDefnRec( 'Amount (' + CCode + ')', ceAmount, celAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, True, CE_AMOUNT_DEF_EDITABLE, csByValue );
      end else
        InsColDefnRec( 'Amount',   ceAmount, celAmount, CE_AMOUNT_DEF_WIDTH, CE_AMOUNT_DEF_VISIBLE, True, CE_AMOUNT_DEF_EDITABLE, csByValue );

      InsColDefnRec( 'Percent',    cePercent,    celPercent,   105, false, false, true, -1 );
      InsColDefnRec( Localise(MyClient.clFields.clCountry, '%/$'),        ceAmountType, celAmountType, 35, false, false, false, -1 );
      InsColDefnRec( 'Payee',      cePayee,      celPayee,      50, true, false, PayeeEditable, -1);
      InsColDefnRec( 'Payee Name', cePayeeName,  celPayeeName, 100, false, false, false, -1);
      InsColDefnRec( 'Job',        ceJob,        celJob,        50, CE_JOB_DEF_VISIBLE, false, true, -1);
      InsColDefnRec( 'Job Name',   ceJobName,    celJobName,   100, False, false, false, -1);

      AllowGSTClassEditing := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

      case MyClient.clFields.clCountry of
         whNewZealand : begin
            InsColDefnRec( 'GST',        ceGSTClass,   celGSTCode,    35, true, false, true, -1 );
            InsColDefnRec( 'GST Amount', ceGSTAmount,  celGstAmt,    105, true, false, true, -1 );
         end;

         whAustralia  : begin
            //Ledger Elite doesn't support editing of the GST class
            InsColDefnRec( 'GST',        ceGSTClass,   celGSTCode,    35, true, false, AllowGSTClassEditing, -1, 'GST Class ID' );

            AllowGSTAmtEditing := ( Myclient.clFields.clBAS_Calculation_Method <> bmFull);
            InsColDefnRec( 'GST Amount', ceGSTAmount,  celGstAmt,    105, true, false, AllowGSTAmtEditing, -1 );
         end;

         whUK : begin
            InsColDefnRec( 'VAT',        ceGSTClass,   celGSTCode,    35, true, false, true, -1 );
            InsColDefnRec( 'VAT Amount', ceGSTAmount,  celGstAmt,    105, true, false, true, -1 );
         end;
      end;
      InsColDefnRec( 'Quantity',   ceQuantity, celQuantity,   95, true, false, true, -1 );
      InsColDefnRec( 'Tax Inv', ceTaxInvoice, celTaxInv, CE_TAXINVOICE_DEF_WIDTH, false, false, true, -1);

      if HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then begin
         csNames[csByAltChartCode] := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
         InsColDefnRec( csNames[csByAltChartCode]
                        , ceAltChartcode, CelAltChartCode, 80, false, false, false, csByAltChartCode );

      end;

{$ENDIF}
      if Screen.WorkAreaWidth < 800 then
         InsColDefnRec( 'Narration',  ceNarration,  celNarration, 115, true, false, true, -1 )
      else
         InsColDefnRec( 'Narration',  ceNarration,  celNarration, 295, true, false, true, -1 );

   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.BuildTableColumns;
//Build the table columns with the column settings set up in ColumnFmtList
var
   i : integer;
   Col : TOvcTableColumn;
   ColDefn : pColumnDefn;
begin
   with tblDissect do begin
      //Lock table update
      AllowRedraw := false;
      //Set correct number of columns
      ColCount := ColumnFmtList.ItemCount;
      //Clear headings
      hdrColumnHeadings.Headings.Clear;
      //Iterate thru column format list setting correct columns attributes
      for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
         ColDefn := ColumnFmtList.ColumnDefn_At(i);
         with ColDefn^ do begin
            hdrColumnHeadings.Headings.Add( cdHeading );
            Col := Columns[i];
            with Col do begin
               DefaultCell := cdTableCell;
               Width       := cdWidth;
               Hidden      := cdHidden;
            end;
         end;
      end;
      //Unlock table update
      AllowRedraw := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.InitController;
const
   KeyMapName = 'Grid';
begin
   with tblDissect.Controller.EntryCommands do begin
     {remove F2 functionallity}
     DeleteCommand(KeyMapName,VK_F2,0,0,0);
     DeleteCommand(KeyMapName,VK_DELETE,0,0,0);
     DeleteCommand(KeyMapName,72,ss_Ctrl,0,0);  {CTRL+H acting as delete}
     DeleteCommand(KeyMapName,72,ss_Ctrl or ss_Shift,0,0);  {CTRL+SHIFT+H acting as delete}

     {add our commands}
     AddCommand(KeyMapName,VK_F2,0,0,0,tcLookup);
     AddCommand(KeyMapName,VK_F3,0,0,0,tcPayeeLookup);
     AddCommand(KeyMapName,VK_F5,0,0,0,tcJobLookup);
     AddCommand(KeyMapName,VK_F6,0,0,0,ccTableEdit);
     AddCommand(KeyMapName,VK_F7,0,0,0,tcGSTLookup);
     AddCommand(KeyMapName,VK_F8,0,0,0,tcNextUncoded);
     AddCommand(KeyMapName,VK_F11,0,0,0,tcEditSuperFields);
     AddCommand(KeyMapName,VK_F12,0,0,0,tcNextNote);

     AddCommand(KeyMapName,VK_MULTIPLY,0,0,0,tcEditAll);
     AddCommand(KeyMapName,56,$02,0,0,tcEditAll);
     AddCommand(KeyMapName,65,ss_Ctrl,0,0,tcEditAll);         {ctrl+A}
     AddCommand(KeyMapName,66,ss_Ctrl,0,0,tcGotoNotes);       {ctrl+b}
     AddCommand(KeyMapName,69,ss_Ctrl,0,0,tcEditAll);         {ctrl+E}
     AddCommand(KeyMapName,71,ss_Ctrl,0,0,tcNextUncoded);      {ctrl+G}
     AddCommand(KeyMapName,72,ss_Ctrl,0,0,tcDummyCommand);    {ctrl+H}
     AddCommand(KeyMapName,72,ss_Ctrl or ss_Shift,0,0,tcDummyCommand);  {ctrl + shift + H}
     AddCommand(KeyMapName,74,ss_Ctrl,0,0,tcCopyNotesToNarration); {ctrl+J}
     AddCommand(KeyMapName,74,ss_Ctrl or ss_Shift, 0,0, tcAppendNotesToNarr); {ctrl + shift J}
     AddCommand(KeyMapName,76,ss_Ctrl,0,0,tcLookup);          {ctrl+L}
     AddCommand(KeyMapName,80,ss_Ctrl,0,0,tcPayeeLookup);     {ctrl+P}
     AddCommand(KeyMapName,81,ss_Ctrl,0,0,tcRecalc);          {ctrl+Q}
     AddCommand(KeyMapName,89,ss_Ctrl,0,0,tcDeleteLine);      {ctrl+Y}
     AddCommand(KeyMapName,$2E,ss_Ctrl,0,0,tcDeleteLine);     {ctrl+delete}
     Addcommand(KeyMapName,187,0,0,0,tcComplete);         {'=' to complete amount}
     AddCommand(KeyMapName,VK_ADD,0,0,0,tcDitto);         {+ - NumPad}
     AddCommand(KeyMapName,VK_DELETE,0,0,0,tcDeleteCell);
     AddCommand(KeyMapName,87,ss_Ctrl,0,0,tcView);             {ctrl+W}
     AddCommand(KeyMapName,77,ss_Ctrl or ss_Shift, 0,0, tcMarkNote); {ctrl + shift M}
     AddCommand(KeyMapName,65,ss_Ctrl or ss_Shift, 0,0, tcMarkAllNotes); {ctrl + shift A}
     AddCommand(KeyMapName,88,ss_Ctrl or ss_Shift, 0,0, tcDeleteNote); {ctrl + shift X}
     AddCommand(KeyMapName,VK_INSERT,ss_Shift,0,0,tcInsertLine);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.FormCreate(Sender: TObject);
//Add the bitmap to button Glyph, and apply the caption in the case of
//SmartBooks or BK5

begin
  bkXPThemes.ThemeForm( Self);
  Undo := False;
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_PAYEE_BMP,btnPayee.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_SUPER_BMP,sbtnSuper.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(18,btnJob.Glyph);

{$IFDEF SmartBooks}
  btnChart.Caption := 'Code';
{$ENDIF}
  SetupHelp;
  FHint := THintWindow.Create( Self );
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Font <> '') then
     StrToFont(AdminSystem.fdFields.fdCoding_Font,FHint.Canvas.Font)
  else if (not Assigned(AdminSystem)) and (INI_Coding_Font <> '') then
     StrToFont(INI_Coding_Font,FHint.Canvas.Font)
  else begin
     FHint.Canvas.Font.Name := 'Courier';
     FHint.Canvas.Font.Size := 5;
  end;


  FStartedEdit := False;
  FDontRecalculatePercentages := False;
  celNarration.MaxLength := MaxNarrationEditLength;
  FSuperTop := -999;
  FSuperLeft := -999;
  with MyClient, clFields do begin
    FCanUseSuperFundFields := Software.CanUseSuperFundFields( clCountry, clAccounting_System_Used);
    FCountry := clCountry;
  end;

  With mniRecalcGST do Caption := Localise( FCountry, Caption );
  With LookupGST1 do Caption := Localise( FCountry, Caption );
  With AmountGrossUpFromGSTAmount1 do Caption := Localise( FCountry, Caption );
  With AmountFixed do Caption := Localise( FCountry, Caption );
  With Label2 do Caption := Localise( FCountry, Caption );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.FormDestroy(Sender: TObject);
var
   i : Integer;
   p : pWorkDissect_Rec;
begin
   //free hint window
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then FHint.ReleaseHandle;
      FHint.Free;
      FHint := nil;
   end;
   // Free the memory assigned to the work records
   for i := 0 to Pred( WorkDissect.Count ) do
   Begin
      p := pWorkDissect_Rec( WorkDissect.Items[ i ] );
      p.dtImportNotes := '';
      p.dtNotes := '';
      FreeMem( p, SizeOf(TWorkDissect_Rec) );
   end;
   WorkDissect.Free;
   ColumnFmtList.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.SetupHelp;
begin
   Self.ShowHint    := INI_ShowformHints;
   Self.HelpContext := 0;

   //Components
   btnChart.Hint   := STDHINTS.ChartLookupHint;
   btnPayee.Hint   := STDHINTS.PAYEELOOKUPHINT;
   sbtnSuper.Hint  := STDHINTS.SUPERFIELDSHINT;
   btnJob.Hint     := 'Lookup the Job list|'+
                      'Lookup the Job list';
   btnView.Hint  :=
                'Change View|'
                +'Configure columns or restore the default column settings';

   BKHelpSetUp( Self, BKH_Chapter_4_Dissecting);
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblDissect.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgDissection.ValidDataRow(RowNum : integer): boolean;
// Row 0 is heading row
begin
   Result := ( (RowNum > 0) and ( RowNum <= GLCONST.Max_tx_Lines ) );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectGetCellAttributes(Sender: TObject;
  RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
   //check that the current cell color is the default color so that
   //dont change color if the cell is highlighted ie. active cell
   if (CellAttr.caColor = tblDissect.Color) then begin
      if Odd(RowNum) then
         CellAttr.caColor := clStdLineLight
      else
         CellAttr.caColor := clStdLineDark;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectActiveCellMoving(Sender: TObject;
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
   if not Assigned(ColumnFmtList) then
      Exit;

   with tblDissect, ColumnFmtList do begin
      //calculate direction of movement
      if ( ColNum < ActiveCol ) then
         Direction := diLeft
      else if ( ColNum > ActiveCol) then
         Direction := diRight
      else if ( command = ccRight ) then
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
      if ( ColNum <> ActiveCol ) and ColIsEditable(ColNum) then
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
   end; //with tblDissect
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectActiveCellChanged(Sender: TObject;
  RowNum, ColNum: Integer);
var
   FieldID    : integer;
   HintText   : string;
begin
   HideCustomHint; // Changing cells, so Hide the Hint window
   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   case FieldID of
      ceAccount : begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Enter an Account Code   (F2) Lookup Chart';
      end;
      ceAmount, ceMoneyIn, ceMoneyOut : begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Enter an Amount';
      end;
      cePercent: begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Enter a Percentage Split';
      end;
      ceAmountType: begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Choose if this line is a dollar amount or a percentage split';
      end;
      ceGSTClass : begin
         HintText := Localise( FCountry, 'Enter the GST Code if applicable   (F7) Lookup GST' );
      end;
      ceGSTAmount : begin
         HintText := Localise( FCountry, 'Enter the GST Amount if applicable ' );
      end;
      ceQuantity : begin
         HintText := 'Enter the Quantity value';
      end;
      cePayee : begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Enter a Payee number';
      end;
      ceJob : begin
         ShowHintForCell(RowNum, ColNum);
         HintText := 'Enter the Job Code this Dissection should be allocated to';
      end;
      ceNarration : begin
         HintText := 'Enter a Narration';
      end;
      ceForexRate : Begin
        ShowHintForCell( RowNum, ColNum);
        HintText   := '';
      End;

      ceTaxInvoice : begin
        HintText := 'Tax Invoice';
      end;
   end;
   tblDissect.Hint := HintText;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectColumnsChanged(Sender: TObject; ColNum1,
  ColNum2: Integer; Action: TOvcTblActions);
var
   pCD1,
   pCD2 : pColumnDefn;
begin
   case Action of
      taSingle : begin
           //update column width in ColumnFmtList
           pCD1 := ColumnFmtList.ColumnDefn_At(ColNum1);
           pCD1^.cdWidth := tblDissect.Columns[ColNum1].Width;
      end;
      taExchange : with ColumnFmtList do begin
           //swap cols, the table takes care of restructing itself, so all
           //we need to do is update the ColumnFmtList and ColConfigList.
           pCD1 := ColumnDefn_At(ColNum1);
           pCD2 := ColumnDefn_At(ColNum2);
           Items[ColNum1] := pCD2;
           Items[ColNum2] := pCD1;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectEnteringRow(Sender: TObject; RowNum: Integer);
begin
   UpdateStatusBar;
   UpdateNotesPanel( RowNum);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.UpdateNotesPanel( RowNum : integer);
var
   pD   : pWorkDissect_Rec;
begin
   //load notes panel details
   if (tblDissect.ActiveRow <> RowNum ) then exit;

   if not ValidDataRow( tblDissect.ActiveRow ) then begin
      pnlNotes.Enabled := false;
      memNotes.Text    := '';
      memImportNotes.Text := '';
   end
   else begin
      pnlNotes.Enabled := true;
      pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
      memNotes.Text := pD.dtNotes;
      memImportNotes.Text := pD.dtImportNotes;
   end;

   memImportNotes.Visible := memImportNotes.Text <> '';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.UpdateStatusBar;
//Update Status Bar Panels with new values
var
   Code : String;
   pA   : pAccount_Rec;
   pD   : pWorkDissect_Rec;
begin
   if not ValidDataRow( tblDissect.ActiveRow ) then
      Exit;

   pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
   with stbDissect do begin
      Panels[PANELPROGRESS].Text := Format( '%d of %d', [ tblDissect.ActiveRow, GLCONST.Max_tx_Lines ] );
      // Account Desc
      Code := pD^.dtAccount;
      if ( Code='' ) then begin
         Panels[PANELTEXT].Text := '';
         Exit;
      end;
      pA := MyClient.clChart.FindCode( Code );
      if ( pA = Nil ) then begin
         Panels[PANELTEXT].Text := Format( '<%s> INVALID CODE!', [Code] );
         Exit;
      end;
      if pA^.chPosting_Allowed then begin
         Panels[PANELTEXT].Text := Format( '<%s> %s', [ Code, pA^.chAccount_Description ] );
      end
      else begin
         Panels[PANELTEXT].Text := Format( '<%s> %s INVALID!', [ Code, Copy( pA^.chAccount_Description, 1, 16 ) ] );
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
//occurs before ReadCellForEdit
//allows us to decide whether or not a cell is allowed to be edited
var
   FieldID : integer;
   pD      : pWorkDissect_Rec;
begin
   AllowIt := false;
   if not ValidDataRow(  RowNum ) then
      Exit;
   if pTran.txLocked then  // No Edit if Parent transaction Locked
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;
   if not ColumnFmtList.ColIsEditable( ColNum ) then
      Exit;

   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   pD := WorkDissect.items[ RowNum-1];
   if ( FieldId = ceGSTAmount) and ( MyClient.clFields.clCountry = whAustralia) and
      ( MyClient.clFields.clBAS_Calculation_Method = bmSimplified) then begin
         //this field cannot be edited if we are using the simplified method and
         //the current gst class assigned has a zero percentage rate
         if ( GetGSTClassRate( MyClient, pTran^.txDate_Effective, pD^.dtGST_Class) = 0) then exit;
   end;

   AllowAddMinus := True;  //Allow 1 minus to be added per edit (see Qty/Amount Changed Events)
   AllowIt := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
//Occurs before ReadCellForSave
var
   pD       : pWorkDissect_Rec;
   FieldID  : integer;
   Account  : string;
   GSTClass : byte;
   GSTAmount: double;
   Payee    : integer;
   IsActive : boolean;
begin
   IsActive := True;

   //verify values
   if not ValidDataRow(RowNum) then exit;

   pD := WorkDissect.Items[ RowNum-1 ];
   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   case FieldID of
      ceAccount: begin
         Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
         if (Account <> '') then begin
            if not MyClient.clChart.CanCodeTo( Account, IsActive ) then begin
               ErrorSound;
{$IFDEF SmartBooks}
               AllowIt := false;  //smartbooks requires a valid account code
               HelpfulWarningMsg( 'You have entered an invalid code!'#13+
                                  'Use the Code Button to select a vaild code', 0 );
{$ENDIF}
            end;
         end;
      end;
      ceGSTClass : begin
         GSTClass := GetGSTClassNo( MyClient, Trim(TEdit( TOvcTCString( Cell ).CellEditor).Text));
         if not ( GSTClass = 0) then begin
            if not ( GSTClass in GST_CLASS_RANGE )
               or  ( MyClient.clFields.clGST_Class_Names[ GSTClass ] = '' ) then begin
                  AllowIt := false;
                  ErrorSound;
            end;
         end;
      end;
      ceGSTAmount : begin
         GSTAmount := TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat;
         if ( pD^.dtGST_Class =0 ) and (GSTAmount <>0) then begin
            ErrorSound;
            TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat := 0;
            AllowIt := false;
         end
         else begin
            if (( pD^.dtLocal_Amount < 0 ) and ( Double2Money(GSTAmount) < pD^.dtLocal_Amount )) or
               (( pD^.dtLocal_Amount > 0 ) and ( Double2Money(GSTAmount) > pD^.dtLocal_Amount )) then begin
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
            TEdit( TOvcTCString(Cell).CellEditor).Text := pd.dtJob;
         end else begin

            Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
            if (Account <> '') then
               if not assigned  (MyClient.clJobs.FindCode(Account)) then begin
                  ErrorSound;
                  AllowIt := false;
               end;
         end;



   end; //case
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgDissection.GSTDifferentToDefault( pD : pWorkDissect_Rec) : boolean;
//calculate default gst amount and class and see if current values are
//different
var
   DefaultGSTClass :  byte;
   DefaultGSTAmount   : money;
begin
   CalculateGST( myClient, pTran^.txDate_Effective, pD^.dtAccount, pD^.dtLocal_Amount,
                 DefaultGSTClass, DefaultGSTAmount);

   Result := ( pD^.dtGST_Class <> DefaultGSTClass) or ( pD^.dtGST_Amount <> DefaultGSTAmount);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change
//
var
   pD  : pWorkDissect_Rec;
   FieldID : integer;
   B       : Byte;
   M       : Money;
   Count : Integer;
   Total : Double;
   Remainder : Double;
   GSTTotal   : Double;
   Percent: Double;
begin
   FStartedEdit := False;
   if not ValidDataRow(RowNum) then exit;

   pD := WorkDissect.Items[ RowNum-1 ];
   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

   case FieldID of
      //the following fields affect other fields
      ceAccount: begin
         tmpShortStr := Trim( tmpShortStr);
         if ( pD^.dtAccount <> tmpShortStr ) then
         begin
            // Edited flag not set if when coded from Blank
            if ( pD^.dtAccount <> '' ) then
               pD^.dtHas_Been_Edited := true;
            pD^.dtAccount   := tmpShortStr;
            AccountEdited(pD);

            pTran.txTransfered_To_Online := False;
         end;
      end;

      ceGSTClass : begin
         tmpShortStr := Trim( tmpShortStr);
         B := GetGSTClassNo( MyClient, tmpShortStr);
         //update if the gst class is different
         if pD^.dtGST_Class <> B then
         begin
            pD^.dtGST_Class    := B;
            GSTClassEdited(pD);
            //see if edited
            if GSTDifferentToDefault( pD ) then begin
               pD^.dtHas_Been_Edited := true;
               pD^.dtGST_Has_Been_Edited := true;
            end
            else
               pD^.dtGST_Has_Been_Edited := false;

            pTran.txTransfered_To_Online := False;
         end;
      end;

      ceAmount, ceMoneyIn, ceMoneyOut : begin
         M := Double2Money(tmpDouble);
         if FieldID = ceMoneyIn then
            M := -M;
         if ( pD^.dtAmount <> M ) then begin
            pD^.dtHas_Been_Edited := true;
         end;
         if pD.dtAmount <> M then // ESC
         begin
           CalcControlTotals( Count, Total, Remainder, GSTTotal, Percent );
           if HasPercentLines and (M = Double2Money(Remainder)) and (M <> 0) then
           begin
            pD^.dtAmount   := M;
            AmountEdited(pD);
            pD^.dtPercent_Amount := 1000000 - Percent;
            pD^.dtAmount_Type_Is_Percent := True;
            UpdateDisplayTotals;
           end
           else
           begin
            pD^.dtAmount   := M;
            AmountEdited(pD);
            ReCalcPercentAmounts;
           end;

           pTran.txTransfered_To_Online := False;
         end;
      end;

      cePercent : begin
         M := Double2Percent(tmpDouble);
         if ( pD^.dtPercent_Amount <> M ) then begin
            pD^.dtHas_Been_Edited := true;
         end;
         if pD.dtPercent_Amount <> M then // ESC
         begin
           pD^.dtPercent_Amount   := M;
           PercentEdited(pD);
           ReCalcPercentAmounts;

           pTran.txTransfered_To_Online := False;
         end;
      end;

      //the following fields do not affect any other fields
      ceGSTAmount : begin
         M := Double2Money(tmpDouble);
         if pD^.dtGST_Amount <> M then begin
            pD^.dtGST_Amount   := M;
            if GSTDifferentToDefault( pD ) then begin
               pD^.dtHas_Been_Edited := true;
               pD^.dtGST_Has_Been_Edited := true;

               pTran.txTransfered_To_Online := False;
            end
            else
               pD^.dtGST_Has_Been_Edited := false;
         end;
         UpdateDisplayTotals;
      end;

      ceNarration : begin
        if (pD^.dtNarration <> tmpShortStr ) then begin
           pD^.dtHas_Been_Edited := true;
           pD^.dtNarration    := tmpShortStr;

           pTran.txTransfered_To_Online := False;
        end;
      end;

      ceTaxInvoice : begin
        if pD.dtTax_Invoice <> tmpBool then
        begin
          pTran.txTransfered_To_Online := False;
        end;

        pD^.dtTax_Invoice := tmpBool;
      end;

      ceQuantity : begin
        if pD.dtQuantity <> tmpDouble * 10000 then
        begin
          pTran.txTransfered_To_Online := False;
        end;

         //doesn't set txHas_Been_Edited because not used or affected by AutoCode
         pD^.dtQuantity    := (tmpDouble * 10000);
      end;

      cePayee : begin
        // can't popup a dialog in here - case 7255
         
        if pD.dtPayee_Number <> tmpPayee then
        begin
         pTran.txTransfered_To_Online := False;
        end;
      end;
      ceJob : begin
          if (pD^.dtJob <> tmpShortStr ) then
          begin
           pD^.dtHas_Been_Edited := true;
           pD^.dtJob    := tmpShortStr;
           pTran.txTransfered_To_Online := False;
        end;
      end;
      ceForexRate:
      begin
        if tmpDouble <> pD.dtForex_Conversion_Rate then
        begin
          pTran.txTransfered_To_Online := False;
        end;
      end;
   end;

   with tblDissect do begin
      AllowRedraw := false;
      InvalidateTable;
      AllowRedraw := true;
   end;
   if FieldId = cePayee then begin
     tmrPayee.Enabled := True;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.AccountEdited( pD : pWorkDissect_Rec );
//update other fields that change when account changes
var
  NewClass   : byte;
  NewGST     : money;
  IsActive   : boolean;
begin
  IsActive := True;

  UpdateBaseAmounts(pD);
  with pD^ do begin
     if MyClient.clChart.CanCodeTo( dtAccount, IsActive) then begin
        CalculateGST( MyClient, pTran^.txDate_Effective, dtAccount, dtLocal_Amount, NewClass, NewGST);
        dtGST_Class  := NewClass;
        dtGST_Amount := NewGST;
        dtGST_Has_Been_Edited := false;
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        //      however it should be cleared if the account code has been deleted
        if ( dtAccount = '' ) then begin
           dtGST_Class := 0;
           dtGST_Amount := 0;
           dtHas_Been_Edited := false;
           dtGST_Has_Been_Edited := false;
        end;
     end;
  end;
  UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.ReCalcPercentAmounts;
var
  i, Count: Integer;
  Total, Remain, GSTAmt, Percent: Double;
  pD : pWorkDissect_Rec;
begin
  if FDontRecalculatePercentages then exit;
  // Recalculate all percentage columns
  CalcControlTotals(Count, Total, Remain, GSTAmt, Percent, True);
  for i := 0 to Pred( GLCONST.Max_tx_Lines ) do
  begin
    pD := WorkDissect.Items[i];
    if pD.dtPercent_Amount <> 0 then
      PercentEdited(pD);
  end;
  tblDissect.InvalidateTable;
end;

procedure TdlgDissection.AmountEdited( pD : pWorkDissect_Rec );
//update other fields that change when amount changes
var
  IsActive: boolean;
begin
  IsActive := True;

  UpdateBaseAmounts(pD);
  with pD^ do begin
     dtPercent_Amount := 0;
     dtAmount_Type_Is_Percent := False;
     if MyClient.clChart.CanCodeTo( dtAccount, IsActive) then begin
        //recalculate the gst using the current class.  No need to change the GST has been edited flag
        //because its status will stay the same.
        dtGST_Amount := CalculateGSTForClass( MyClient, pTran^.txDate_Effective, dtLocal_Amount, dtGST_Class);
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        if ( dtAccount = '' ) then begin
           dtHas_Been_Edited := false;
        end;
     end;
  end;
  SetQuantitySign(False);
  with tblDissect do begin
    AllowRedraw := false;
    Invalidate; // need to repaint all percentage lines also
    AllowRedraw := true;
  end;
  UpdateDisplayTotals;
end;

// ----------------------------------------------------------------------------

procedure TdlgDissection.PercentEdited( pD : pWorkDissect_Rec );
//update other fields that change when percent changes
var
  Remainder: Money;
  IsActive: boolean;
begin
  IsActive := True;

  UpdateBaseAmounts(pD);
  with pD^ do
  begin
    dtAmount := 0;
    UpdateControlTotals;
    Remainder := pTran.txAmount - fControlTotals.ctLocal_Specified_Amount;
    dtAmount := Remainder * ( dtPercent_Amount / 1000000.0 );
    UpdateBaseAmounts(pD);
    dtHas_Been_Edited := True;
    dtAmount_Type_Is_Percent := True;
    if MyClient.clChart.CanCodeTo( dtAccount, IsActive) then
      dtGST_Amount := CalculateGSTForClass( MyClient, pTran^.txDate_Effective, dtLocal_Amount, dtGST_Class)
    else
      if ( dtAccount = '' ) then dtHas_Been_Edited := false;
  end;
  SetQuantitySign( False );
  with tblDissect do
  begin
    AllowRedraw := false;
    Invalidate; // need to repaint all percentage lines also
    AllowRedraw := true;
  end;
  UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.GSTClassEdited( pD: pWorkDissect_Rec );
begin
  UpdateBaseAmounts(pD);
  with pD^ do begin
     if dtGST_Class = 0 then
        dtGST_Amount := 0
     else
        dtGST_Amount := ( CalculateGSTForClass( MyClient,  pTran^.txDate_Effective, dtLocal_Amount, dtGST_Class ) );
  end;
  UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectUserCommand(Sender: TObject;
  Command: Word);
var
  ClientP, ScreenP : TPoint;
  Column : Integer;
begin
   Column := ColumnFmtList.ColumnDefn_At( tblDissect.ActiveCol).cdFieldID;

   case Command of
      tcDummyCommand : ; //ignore
      tcLookup:
        DoAccountLookup;
      tcGSTLookup :
        DoGSTLookup;
      tcEditAll:
        ToggleColEditMode;
      tcComplete:
        DoCompleteAmount;
      tcDeleteCell :
        DoDeleteCell;
      tcDeleteLine :
        DoDeleteLine;
      tcDitto:
        DoDitto;
      tcNextUncoded:
        DoGotoNextUnCode;
      tcRecalc:
{$IFNDEF SmartBooks}
        ShowPopup( tblDissect.width div 3, tblDissect.height div 3, PopGST)
{$ENDIF};
      tcPayeeLookup:
        DoPayeeLookup;
      tcJobLookup:
        DoJobLookup;
      tcGotoNotes:
        DoGotoNotes;
     tcCopyNotesToNarration :
        DoCopyNotesToNarration( false);
     tcAppendNotesToNarr :
        DoCopyNotesToNarration( true);
     tcEditSuperFields :
        DoEditSuperFields;
     tcMarkNote:
        DoMarkNote;
     tcMarkAllNotes:
        DoMarkAllNotes;
     tcDeleteNote:
        DoDeleteNote;
     tcNextNote:
        DoGotoNextNote;
     tcView          : begin
        ClientP.x := 0;
        ClientP.y := btnView.Height;
        ScreenP   := btnView.ClientToScreen(ClientP);
        popView.Popup(ScreenP.x, ScreenP.y);
     end;
     tcInsertLine:
       DoInsertLine;
   end;
end;
procedure TdlgDissection.tmrPayeeTimer(Sender: TObject);
var
   pD  : pWorkDissect_Rec;
   OldPayeeNo: Integer;
   MaintainMemScanStatus: boolean;
begin
   tmrPayee.Enabled := False;

   if PayeeRow = 0 then
      Exit;

   pD := WorkDissect.Items[PayeeRow-1 ];
   if ( pD^.dtPayee_Number <> tmpPayee ) then
   begin
      //tblDissect.ActiveCol := ColumnFmtList.GetColNumOfField(cePayee);
      OldPayeeNo := pD^.dtPayee_Number;
      pD^.dtPayee_Number  := tmpPayee;

      if PayeeEdited(pD,PayeeRow) then
         pD^.dtHas_Been_Edited := true
      else
         pD^.dtPayee_Number := OldPayeeNo;
      OldPayeeNo := PayeeRow;
      PayeeRow := -1; // So we know not to exit...
   end
   else
      OldPayeeNo := PayeeRow;

   with tblDissect do
   begin
      AllowRedraw := false;
      InvalidateRow(OldPayeeNo);
      AllowRedraw := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
   data := nil;
   case Purpose of
      cdpForPaint:
         ReadCellForPaint(RowNum,ColNum,Data);
      cdpForEdit: begin
         btnCancel.Cancel := false;  //turn off esc = cancel function once we start editing
         ReadCellForEdit(RowNum,ColNum,Data);
      end;
      cdpForSave :
         ReadCellForSave(RowNum,ColNum,Data);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID: integer;
   pD: pWorkDissect_Rec;
   pA: pAccount_Rec;
   APayee: TPayee;
begin
   Data := nil;
   if RowNum = 0 then exit;

   pD := WorkDissect.items[ RowNum-1];
   with pD^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of
         ceAccount : begin
            tmpPaintShortStr := dtAccount;
            Data := @tmpPaintShortStr;
         end;
        ceDescription,
        ceAltChartcode:
           begin
              pA := MyClient.clChart.FindCode( pD^.dtAccount );
              if Assigned( pA ) then
                 if FieldID = ceDescription then
                    tmpPaintShortStr := pA.chAccount_Description
                 else
                    tmpPaintShortStr := pA.chAlternative_Code
              else
                 tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;

        ceForexRate :
          Begin
            tmpPaintDouble := pD^.dtForex_Conversion_Rate;
            data := @tmpPaintDouble;
          End;

         ceAmount : begin
            if FIsForex then begin
              tmpPaintShortStr := BankAcct.MoneyStrBrackets( dtAmount );
              Data := @(tmpPaintShortStr);
            end else begin
              tmpPaintDouble := Money2Double( dtAmount );
              Data := @tmpPaintDouble;
            end;
         end;

        ceLocalAmount :
          begin
            tmpPaintShortStr := MyClient.MoneyStrBrackets( pD.dtLocal_Amount );
            Data := @tmpPaintShortStr;
           end;

         cePercent : begin
            tmpPaintDouble := Percent2Double( dtPercent_Amount );
            Data := @tmpPaintDouble;
         end;
         ceAmountType : begin
            if (dtPercent_Amount <> 0) or (dtAmount_Type_Is_Percent) then
              tmpPaintShortStr := '%'
            else
              tmpPaintShortStr := MyClient.CurrencySymbol;
            Data := @tmpPaintShortStr;
         end;
         ceMoneyIn : begin
            tmpPaintDouble := Money2Double( -dtAmount );
            if ( dtAmount < 0 ) then begin
               Data := @tmpPaintDouble;
            end
            else begin
               Data := nil; //Blank
            end;
         end;
         ceMoneyOut : begin
            tmpPaintDouble := Money2Double( dtAmount );
            if ( dtAmount > 0 ) then begin
               Data := @tmpPaintDouble;
            end
            else begin
               Data := nil; //Blank
            end;
         end;
         ceGSTClass : begin
            tmpPaintShortStr := Trim(GetGstClassCode( MyClient, dtGST_Class));
            Data := @tmpPaintShortStr;
         end;     
         ceGSTAmount : begin
            tmpPaintDouble := Money2Double( dtGst_Amount);
            Data := @tmpPaintDouble;
         end;
         cePayee : begin
            if dtPayee_Number <> 0 then
            begin
              tmpPaintInteger := dtPayee_Number;
              Data := @tmpPaintInteger;
            end;
         end;
         cePayeeName:
           begin
             if pD^.dtPayee_Number <> 0 then
             begin
                APayee := MyClient.clPayee_List.Find_Payee_Number(pD^.dtPayee_Number);
                if Assigned( aPayee ) then
                   tmpPaintShortStr := aPayee.pdName
                else
                   tmpPaintShortStr := 'Unknown';
             end else
                tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;
         ceJob: begin
            tmpPaintShortStr := dtJob;
            Data := @tmpPaintShortStr;
         end;
         ceJobName : begin
            if dtJob > '' then
                tmpPaintShortStr := MyClient.clJobs.JobName(dtJob)
            else
                tmpPaintShortStr := '';
            data := @(tmpPaintShortStr);
         end;

         ceQuantity : begin
            tmpPaintDouble := dtQuantity / 10000;
            Data := @tmpPaintDouble;
         end;

         ceNarration : begin
            tmpPaintShortStr := dtNarration;
            Data := @tmpPaintShortStr;
         end;
         ceTaxInvoice : begin
           Data := @dtTax_Invoice;
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.ReadCellforEdit(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID : integer;
   pD      : pWorkDissect_Rec;
begin
   Data := nil;
   pD := WorkDissect.Items[ RowNum-1 ];
   with pD^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of
         ceAccount : begin
            tmpShortStr := Trim(dtAccount);
            Data := @tmpShortStr;
         end;

         ceAmount : begin
            tmpDouble := Money2Double( dtAmount );
            Data := @tmpDouble;
         end;

         ceForexRate : begin
            tmpDouble := dtForex_Conversion_Rate;
            Data := @tmpDouble;
         end;

         ceLocalAmount : begin
            tmpDouble := Money2Double( dtLocal_Amount );
            Data := @tmpDouble;
         end;

         cePercent : begin
            tmpDouble := Percent2Double( dtPercent_Amount );
            Data := @tmpDouble;
         end;
         ceMoneyIn : begin
            tmpDouble := Money2Double( -dtAmount );
            Data := @tmpDouble;
         end;
         ceMoneyOut : begin
            tmpDouble := Money2Double( dtAmount );
            Data := @tmpDouble;
         end;
         ceGSTClass : begin
            tmpShortStr := GetGstClassCode( MyClient, dtGST_Class);
            Data := @tmpShortStr;
         end;
         ceGSTAmount : begin
            tmpDouble := Money2Double( dtGst_Amount);
            Data := @tmpDouble;
            AutoPressMinus := ( dtAmount < 0);
         end;
         cePayee : begin
            tmpPayee := dtPayee_Number;
            Data     := @tmpPayee;
         end;
         ceQuantity : begin
            tmpDouble := dtQuantity / 10000;
            Data := @tmpDouble;
         end;

         ceJob : begin
            tmpShortStr := Trim(dtJob);
            Data := @tmpShortStr;
         end;
         ceNarration : begin
            tmpShortStr := dtNarration;
            Data := @tmpShortStr;
         end;
         ceTaxInvoice: begin
            tmpBool  := dtTax_Invoice;
            data := @tmpBool;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID : integer;
   pD      : pWorkDissect_Rec;
begin
   Data := nil;
   pD := WorkDissect.Items[ RowNum-1 ];
   with pD^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of
         ceAccount, ceNarration, ceJob : begin
            Data := @tmpShortStr;
         end;
         ceAmount, cePercent, ceMoneyIn, ceMoneyOut, ceGSTAmount, ceQuantity, ceForexRate, ceLocalAmount : begin
            Data := @tmpDouble;
         end;
         ceGSTClass : begin
            tmpShortStr := Chr( dtGST_Class );
            Data := @tmpShortStr;
         end;
         cePayee : begin
            Data := @tmpPayee;
            PayeeRow := RowNum;
         end;
         ceTaxInvoice : begin
           data := @tmpBool;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.celQuantityChange(Sender: TObject);
var
   pD : pWorkDissect_Rec;
begin
   pD := WorkDissect.Items[tblDissect.ActiveRow-1];
   if not AllowAddMinus then
      Exit;
   if ( pD^.dtAmount < 0 ) and
      ( pD^.dtQuantity = 0 ) then
      Keybd_Event(vk_subtract,0,0,0);
   AllowAddMinus := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.btnOKClick(Sender: TObject);
begin
  //make sure not editing
  if tblDissect.InEditingState then
    if not tblDissect.StopEditingState(true) then begin
      tblDissect.SetFocus;
      Exit;
    end;
  // Now gets a bit tricky...
  if TmrPayee.Enabled then
  begin
    tmrPayeeTimer(nil);
    if PayeeRow = -1 then begin
      tblDissect.SetFocus;
      Exit; // had a dialog up..
    end;
  end;

  UpdateControlTotals;

  if fIsForex then
  Begin
    if ( fControlTotals.ctRemainder <> 0 ) then
    Begin
      HelpfulErrorMsg( 'The (' + BCode + ') remaining balance is not zero!', 0 );
      tblDissect.SetFocus;
      Exit;
    End;
    if ( fControlTotals.ctLocal_Remainder <> 0 ) then
    Begin
      HelpfulErrorMsg( 'The (' + CCode + ') remaining balance is not zero!', 0 );
      tblDissect.SetFocus;
      Exit;
    End;
  End
  else
  Begin
    if ( fControlTotals.ctRemainder <> 0 ) then
    Begin
      HelpfulErrorMsg( 'The remaining balance is not zero!', 0 );
      tblDissect.SetFocus;
      Exit;
    End;
  End;
  ModalResult := mrOK;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
begin
   with tblDissect do begin
      if not ValidDataRow(ActiveRow) then exit;
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

procedure TdlgDissection.DoRecalcGST;
Var
   i : Integer;
   pD : pWorkDissect_Rec;
   OldGSTAmount: Money;
Begin
   if not tblDissect.StopEditingState(True) then Exit;

   if pTran.txLocked then begin
     HelpfulInfoMsg( Localise( FCountry, 'All Entries have been finalised.  You cannot recalculate GST for finalised transactions.' ),0);
     exit;
   end;
   if pTran.txDate_Transferred <> 0  then begin
     HelpfulInfoMsg( Localise( FCountry, 'This dissection has been transferred to your accouting system.  You cannot recalculate GST for transferred transactions.') ,0);
     exit;
   end;

   for i := 0 to Pred( WorkDissect.Count) do
   begin
      pD := WorkDissect.Items[ i];

      OldGSTAmount := pD.dtGST_Amount;

      with pD^ do
      begin
         CalculateGST( MyClient, pTran.txDate_Effective, dtAccount, dtLocal_Amount, dtGST_Class, dtGST_Amount);
         dtGST_Has_Been_Edited := false;

         if OldGSTAmount <> pD.dtGST_Amount then
         begin
           pTran.txTransfered_To_Online := False;
         end;
      end;
   end;
   //force a redraw
   with tblDissect do begin
      AllowRedraw := false;
      InvalidateTable;
      AllowRedraw := true;
   end;
   LogUtil.LogMsg(lmInfo,UnitName,'DoRecalcGST Completed');
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.ToggleColEditMode;
//Toggle the Column Edit Mode
begin
   case ColumnFmtList.EditMode of
      emRestrict :
         SetColEditMode( emGeneral );
      emGeneral  :
         SetColEditMode( emRestrict );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.SetColEditMode( EditMode : TEditMode );
//Setup the column Edit Mode and update the indicator on the Status Bar
begin
   tblDissect.ActiveCol := ColumnFmtList.SetColEditMode( EditMode, tblDissect.ActiveCol );
   case ColumnFmtList.EditMode of
      emRestrict :
         stbDissect.Panels[PANELMODE].text := RESTRICTED_MODE_STRING;
      emGeneral  :
         stbDissect.Panels[PANELMODE].text := ALL_MODE_STRING;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.celAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);

//custom draw for accounts screen, allows us to add the notes icon to the
//column, and to display account code in red if it is invalid
Type
  TNotesIcon = ( niNone, niTNotes, niTImportNotes, niTReadNotes);

Const
  DTOpts = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
var
  R         : TRect;
  S         : String;
  NotesIcon : TNotesIcon;
  pD        : pWorkDissect_Rec;
  IsActive  : boolean;
begin
  If ( data = nil ) then
    exit;

  IsActive := True;

  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;

  S := ShortString( Data^ );
  If not ( ( S='' ) or ( S=BKCONST.DISSECT_DESC ) or MyClient.clChart.CanCodeTo( S, IsActive ) or
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

  // Draw the Notes icon
  if ValidDataRow( RowNum ) then
  begin
    pD   := WorkDissect.Items[ RowNum -1];
    //figure out icon
    NotesIcon := niNone;
    if ( pD^.dtImportNotes <> '') and (not pD^.dtImport_Notes_Read) then
      NotesIcon := niTImportNotes
    else
    if ( pD^.dtNotes <> '') and (not pD^.dtNotes_Read) then
      NotesIcon := niTNotes
    else if (pD^.dtImport_Notes_Read and (pD^.dtImportNotes <> '')) or
            (pD^.dtNotes_Read and (pD^.dtNotes <> '')) then
      NotesIcon := niTReadNotes;
    //draw icon
    if NotesIcon <> niNone then
    begin
      R := CellRect;
      R.Left := R.Right - ( R.Bottom - R.Top ); { Square at RH End }
      InflateRect( R, -4, -4 ); { Make it Smaller }
      OffsetRect( R, 2, 0 ); { Move it Right a bit }
      case NotesIcon of
        niTNotes       : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgNotes.Picture.Bitmap );
        niTImportNotes : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgImportNotes.Picture.Bitmap );
        niTReadNotes   : TableCanvas.StretchDraw( R, ImagesFrm.AppImages.imgReadNotes.Picture.Bitmap );
      end;
    end;
  end;
  DoneIt := True;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.celGstAmtOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//paint blue if GST has been edited
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pD  : pWorkDissect_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow( RowNum ) then begin
     pD   := WorkDissect.Items[ RowNum -1];
     if not pD^.dtGST_Has_Been_Edited then
        exit;
     R := CellRect;
     C := TableCanvas;
     pfHiddenAmount.SetValue( Data^ );
     S := PChar( pfHiddenAmount.AsString);
     {paint background}
     c.Brush.Color := CellAttr.caColor;
     c.FillRect(R);
     {draw data}
     InflateRect( R, -2, -2 );
     C.Font.Color := bkGSTEditedColor;
     DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
     DoneIt := true;
  end;
end;

//------------------------------------------------------------------------------

procedure TdlgDissection.celGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pD  : pWorkDissect_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow( RowNum ) then begin
     pD   := WorkDissect.Items[ RowNum -1];
     if not pD^.dtGST_Has_Been_Edited then
        exit;
     R := CellRect;
     C := TableCanvas;
     S := ShortString( Data^);
     {paint background}
     c.Brush.Color := CellAttr.caColor;
     c.FillRect(R);
     {draw data}
     InflateRect( R, -2, -2 );
     C.Font.Color := bkGSTEditedColor;
     DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
     DoneIt := true;
  end;
end;

procedure TdlgDissection.CelJobChange(Sender: TObject);
begin
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoAccountLookup;
{
Assists the user in coding by allowing selection of Account Codes from
Chart Lookup

The function PickAccount(Code) accepts a Code or partial Code or blank
and attempts to position the Chart on that Code.
It returns True if the user selects an Account Code and puts the Code
in the Var Parameter, if no Code is chosen it returns False.

This method can be called from
   Chart Button,
   Popup Menu,
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
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;
   with tblDissect do begin
      //test if we are in the correct col, if not end any edit and move to
      //correct col
      if not ( ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceAccount ) then begin
         if not StopEditingState(True) then Exit;
         ActiveCol := ColumnFmtList.GetColNumOfField(ceAccount);
      end;

      InEditOnEntry := InEditingState;
      if not InEditOnEntry then begin
         if not StartEditingState then Exit;   //returns true if already in edit state
      end;

      Code := TEdit(celAccount.CellEditor).Text;

      if PickAccount(Code, HasChartBeenRefreshed) then
      begin
        //if get here then have a code which can be posted to from picklist
        TEdit(celAccount.CellEditor).Text := Code;
        //no need to do any more because will be handled by celAccount.OnChange
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoGSTLookup;
{
Assists the user in entering GST code by allowing selection of GST Codes from
GSt Lookup

The function PickGSTClass(GSTCode) accepts a GST Code.
It returns True if the user selects a GST Class and puts it
in the Var Parameter, if no GST Class is chosen it returns False.

This method can be called from
   Popup Menu,
   F2 key or Ctrl-L if the user is positioned on the GST Class column.
   F7 key if edit all col

We do not know the position or the Edit State of the Active Cell when
this method is called.  We therefore end any existing edit and move to
the GST Class column.
}
var
  GSTCode        : String;
  InEditOnEntry  : boolean;
  GSTNotEditable : Boolean;
  pD             : pWorkDissect_Rec;
  Msg            : TWMKey;
begin
   // If Parent Locked then no lookup allowed
   if (pTran.txLocked) then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   if not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then exit;

   //Check to see if a payee col exists
   GSTNotEditable :=  not ColumnFmtList.FieldIsEditable( cePayee);

   if not ( GSTNotEditable) then begin
     with tblDissect do begin
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
               StopEditingState(true);  //end edit
            end;
        end;
     end;
   end else
   begin  //Edit Account Col Only, or PayeeCol has been hidden
      with tblDissect do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
         GSTCode := GSTCALC32.GetGSTClassCode( MyClient, pD^.dtGST_Class);
         if PickGSTClass( GSTCode, True) then begin
            //if get here then have a valid gst class from the picklist, so edit
            //the fields in the transaction
            pD^.dtGST_Class := GSTCALC32.GetGSTClassNo( MyClient, GSTCode);
            GSTClassEdited( pD);
            //check if gst edited
            if GSTDifferentToDefault(pD) then begin
               pD^.dtHas_Been_Edited     := true;
               pD^.dtGST_Has_Been_Edited := true;
            end
            else
               pD^.dtGST_Has_Been_Edited := false;
            //force repaint of row
            AllowRedraw := false;
            try
               InvalidateRow(ActiveRow);
            finally
               AllowRedraw := true;
            end;
            Msg.CharCode := VK_RIGHT;
            celGSTCode.SendKeyToTable(Msg);
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.DoCompleteAmount;
// Replaces the amount in the current dissection line with the unallocated
// Remainder.
var
   pD : pWorkDissect_Rec;
   RowAmount : Double;
   Count : Integer;
   Total : Double;
   Remainder  : Double;
   GSTTotal   : Double;
   GSTAmount  : Money;
   Percent: Double;
begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   //Must Stop Editing State to ensure that the table cell amount is the same
   //as the record amount so can calc remainder correctly
   if tblDissect.InEditingState and (not tblDissect.StopEditingState(True)) then exit;

   pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];

   CalcControlTotals( Count, Total, Remainder, GSTTotal, Percent );
   if (Percent = 1000000) or (Remainder = 0) then exit;
   if Percent = 0 then // as previously, based on amount
   begin
     RowAmount :=  pD^.dtAmount;
     // Calc the new RowAmount
     RowAmount := RowAmount + (Remainder*100);
     pD^.dtAmount := RowAmount;
   end
   else // based on percents
   begin
     pD.dtPercent_Amount := pD.dtPercent_Amount + (1000000 - Percent);
     PercentEdited( pD );
     CalcControlTotals( Count, Total, Remainder, GSTTotal, Percent );
     if Remainder <> 0 then
     begin
       pD.dtAmount := pD.dtAmount + Double2Money(Remainder);
     end;
   end;
   UpdateBaseAmounts(pD);

   // Calc the new GST and put in Column
   GSTAmount := CalculateGSTForClass( myClient, pTran^.txDate_Effective, pD^.dtLocal_Amount, pD^.dtGST_Class);
   pD^.dtGST_Amount := GSTAmount;

   with tblDissect do begin
      AllowRedraw := false;
      InvalidateRow( ActiveRow );
      AllowRedraw := true;
   end;
   SetQuantitySign(False);
   with tblDissect do begin
     AllowRedraw := false;
     InvalidateRow(ActiveRow);
     AllowRedraw := true;
   end;
   UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.DoDeleteLine;
//Delete the whole line of dissection record by pressing Ctrl+Y
var
   pD : pWorkDissect_Rec;
begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;
   if tblDissect.InEditingState then  //This should never happen
      Exit;

   // Get the Pointer and clear the dissection line
   pD  := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
   ClearWorkRecDetails(PD);


   UpdateDisplayTotals;
   ReCalcPercentAmounts;   
   with tblDissect do begin
      AllowRedraw := false;
      Invalidate; // redraw all cos percentage values may have changed
      AllowRedraw := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.DoDitto;
// Pressing the + key repeats the contents of the field in the row above
// provided the field in the current row is blank.
// GST Amount cannot be repeated

var
   pDPrev, pD: pWorkDissect_Rec;
   Msg     : TWMKey;
   FieldId : integer;
   DittoOK : boolean;
Begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   with tblDissect do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if already in edit state

      pDPrev := WorkDissect.Items[ ActiveRow-2 ];

      DittoOK := false;

      FieldID := ColumnFmtList.ColumnDefn_At( ActiveCol )^.cdFieldID;
      //verify field ok to edit
      case FieldID of
         ceAccount: begin
            if (Trim(TEdit(celAccount.CellEditor).Text) = '') then begin
               TEdit(celAccount.CellEditor).Text := Trim(pDPrev^.dtAccount);
               DittoOK := true;
            end;
         end;

         ceAmount : begin
            if (TOvcNumericField(celAmount.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celAmount.CellEditor).AsFloat := Money2Double( pDPrev^.dtAmount );
               if pDPrev.dtPercent_Amount <> 0 then
               begin
                 pD := WorkDissect.Items[ActiveRow - 1];
                 pD.dtPercent_Amount := pDPrev.dtPercent_Amount;
                 PercentEdited(pD);
               end
               else
                 AmountEdited(WorkDissect.Items[ ActiveRow-1 ]);
               DittoOK := true;
            end;
         end;

         cePercent : begin
            if (TOvcNumericField(celPercent.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celPercent.CellEditor).AsFloat := Percent2Double( pDPrev^.dtPercent_Amount );
               PercentEdited(WorkDissect.Items[ ActiveRow-1 ]);
               DittoOK := true;
            end;
         end;

         ceAmountType : begin
            if (Trim(TEdit(celAmountType.CellEditor).Text) = '') then begin
               if (pDPrev^.dtPercent_Amount <> 0) or (pDPrev^.dtAmount_Type_Is_Percent) then
                 TEdit(celNarration.CellEditor).Text := '%'
               else
                 TEdit(celNarration.CellEditor).Text := MyClient.CurrencySymbol;
               DittoOK := true;
            end;
         end;

         ceMoneyIn : begin
            if (TOvcNumericField(celMoneyIn.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celMoneyIn.CellEditor).AsFloat := Money2Double( pDPrev^.dtAmount );
               DittoOK := true;
            end;
         end;

         ceMoneyOut : begin
            if (TOvcNumericField(celMoneyOut.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celMoneyOut.CellEditor).AsFloat := Money2Double( pDPrev^.dtAmount );
               DittoOK := true;
            end;
         end;

         ceGSTClass : begin
            if ( Trim(TEdit(celGSTCode.CellEditor).Text) = '') then begin
               TEdit(celGSTCode.CellEditor).Text := GetGSTClassCode( MyClient, pDPrev^.dtGST_Class );
               DittoOK := true;
            end;
         end;

         cePayee : begin
            if ( TOvcNumericField(celPayee.CellEditor).AsInteger = 0 ) then begin
               TOvcNumericField(celPayee.CellEditor).AsInteger := pDPrev^.dtPayee_Number;
               DittoOK := true;
            end;
         end;

         ceJob : begin
            if (Trim(TEdit(celJob.CellEditor).Text) = '') then begin
               TEdit(celJob.CellEditor).Text := Trim(pDPrev^.dtJob);
               DittoOK := true;
            end;
         end;


         ceQuantity : begin
            if (TOvcNumericField(celQuantity.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celQuantity.CellEditor).AsFloat := ( pDPrev^.dtQuantity / 10000 );
               DittoOK := true;
            end;
         end;

         ceNarration : begin
            if (Trim(TEdit(celNarration.CellEditor).Text) = '') then begin
               TEdit(celNarration.CellEditor).Text := Trim(pDPrev^.dtNarration);
               DittoOK := true;
            end;
         end;



      end;

      if DittoOK then begin
         //if field was updated the save the edit and move right
         if FieldID = ceAmount then
           FDontRecalculatePercentages := True;
         try
           if not StopEditingState(True) then exit;
           if(FieldID in [ ceAccount, ceAmount, cePercent, ceAmountType, ceMoneyIn,
                         ceMoneyOut, ceGSTClass, ceQuantity, ceJob, ceNarration ] ) then begin
              Msg.CharCode := VK_RIGHT;
              celAccount.SendKeyToTable(Msg);
           end;
           tblDissect.InvalidateTable;
         finally
          FDontRecalculatePercentages := False;
         end;
      end
      else begin
         //field not updated, abandon edit and don't move off current cell
         StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgDissection.RemoveBlanks;
//Sort the Dissection records in the WorkDissect list by checking the Account Code
//and the Amount.  The valid line has Acct Code <> '' or Amount <> 0.  Then move
//all the blanks to the end of the list.

//This is done by spliting the current list into two lists.  Blank and not blank.
//The items in the Blank list can be free'd, the non blank line is then expanded
//so that is has the required number of items.  The new list is then referenced
//by the existing work tran list.
var
   NewDissectList : TList;
   BlankDissectList : TList;
   pD             : pWorkDissect_Rec;
   i              : integer;
   aMsg           : String;

   NonBlankLines  : integer;
begin
   if pTran.txLocked then
      exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   tblDissect.AllowRedraw := false;
   try
      NewDissectList := TList.Create;
      BlankDissectList := TList.Create;
      try
         //look thru list, only add non-blank records into new list
         for i := 0 to Pred( WorkDissect.Count ) do begin
            pD := pWorkDissect_Rec(WorkDissect.Items[ i ]);
            if (pD^.dtAccount <> '')
            or (pD^.dtAmount <> 0) then
               NewDissectList.Add( pD)
            else
               BlankDissectList.Add( pD);
         end;

         //empty existing list and free
         for i := 0 to Pred( BlankDissectList.Count ) do begin
            FreeMem( pWorkDissect_Rec(BlankDissectList.Items[ i ]), SizeOf(TWorkDissect_Rec));
         end;

         //point work list to new list
         WorkDissect.Free;
         WorkDissect := NewDissectList;

         NonBlankLines := WorkDissect.Count;

         //pad out new list to correct size
         for i := NonBlankLines to Pred( GLCONST.Max_tx_Lines ) do begin
            GetMem( pD, SizeOf(TWorkDissect_Rec) );
            ClearWorkRecDetails(Pd);

            WorkDissect.Add( pD );
            if not Assigned( WorkDissect.Items[i] ) then begin
               aMsg := Format( '%s : Memory Allocation Failed', [ UnitName ] );
               LogUtil.LogMsg( lmError, UnitName, aMsg );
               Raise ENoMemoryLeft.Create( aMsg );
            end;
         end;

      finally
         BlankDissectList.Free;
         //no need to free newDissect list because this is now referenced to by workdissect
      end;
   finally
      tblDissect.InvalidateTable;
      tblDissect.AllowRedraw := true;
   end;
   tblDissect.Refresh;
   tblDissect.ActiveRow := 1;  {reposition to top of table first}
   tblDissect.ActiveCol := ceAccount;
end;
//------------------------------------------------------------------------------
procedure TdlgDissection.DoGotoNextUnCode;
//Move the cursor to the next uncoded line from the current position by pressing F8
var
  NextPos : integer;
  SaveRow : integer;
begin
  if tblDissect.InEditingState then exit;

  //Sort the list and remove all the blank lines in between, store current row
  //so that can start from there
  SaveRow := tblDissect.ActiveRow;
  RemoveBlanks;
  tblDissect.ActiveRow := SaveRow;

  NextPos := FindUncoded( tblDissect.ActiveRow );  //ActiveRow?
  if NextPos < 0 then
     HelpfulInfoMsg( 'All lines have been coded', 0)
  else
  begin
    tblDissect.ActiveRow := NextPos;
    tblDissect.ActiveCol := ColumnFmtList.GetColNumOfField(ceAccount);
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgDissection.DoGotoNextNote;
var
  NextPos : integer;
  SaveRow : integer;  
begin
  if tblDissect.InEditingState then exit;

  //Sort the list and remove all the blank lines in between, store current row
  //so that can start from there
  SaveRow := tblDissect.ActiveRow;
  RemoveBlanks;
  tblDissect.ActiveRow := SaveRow;

  NextPos := FindNote( tblDissect.ActiveRow );  //ActiveRow?
  if NextPos < 0 then
     HelpfulInfoMsg( 'There are no transactions with notes', 0)
  else
  begin
    tblDissect.ActiveRow := NextPos;
    tblDissect.ActiveCol := ColumnFmtList.GetColNumOfField(ceAccount);
  end;
end;
//------------------------------------------------------------------------------
function TdlgDissection.FindUnCoded(const TheCurrentRow: integer): integer;
// Search Transaction list for Uncoded Entries.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = FTranList Row + 1

   function DissectLineUncoded(pD : pWorkDissect_Rec) : boolean;
   var
     Coded : boolean;
     IsActive : boolean;
   begin
     IsActive := True;
     Coded := MyClient.clChart.CanCodeTo(pD^.dtAccount, IsActive);
{$IFNDEF SmartBooks}
     //check CA systems GST Range
     if IsCASystems and (not CASystemsGSTOK(GetGSTClassNo( MyClient, Chr( pD^.dtGST_Class )))) then coded := false;
{$ENDIF}
     result := not Coded;
   end;

   procedure IncEntry( var Entry : Integer );
   //Increments List Entry number in circular fashion
   begin
      Inc( Entry );
      if ( Entry > GLCONST.Max_tx_Lines ) then
        Entry := 1;
   end;

var
   CurrentEntry : Integer;
   i            : Integer;
   FoundUnCoded : boolean;
   pD           : pWorkDissect_Rec;
begin
   foundUnCoded := false;

   CurrentEntry := TheCurrentRow;
   i := CurrentEntry;
   IncEntry( i );
   Repeat
      pD := WorkDissect.Items[Pred( i )];
      with pD^ do begin
         if (dtAccount <> '') or (dtAmount <> 0) then begin //valid line
           if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
             foundUnCoded := DissectLineUncoded(pD)
           else
             foundUnCoded := (pD^.dtAccount = '');
           if FoundUnCoded then begin
             Result := i;
             Exit;
           end;
         end;
      end;
      IncEntry( i );
   Until ( i = CurrentEntry );

   //have checked all other lines now check current line, if it is valid
   pD := WorkDissect.Items[Pred( CurrentEntry )];
   if (pD^.dtAccount <> '') or (pd^.dtAmount <> 0) then begin //valid line
      if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
           foundUnCoded := DissectLineUncoded(pD)
         else
           foundUnCoded := (pD^.dtAccount = '');
   end;

   if FoundUnCoded then
      Result := i
   else
      result := -1;
end;
//------------------------------------------------------------------------------
function TdlgDissection.FindNote(const TheCurrentRow: integer): integer;
// Search Transaction list for notes.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = FTranList Row + 1

   procedure IncEntry( var Entry : Integer );
   //Increments List Entry number in circular fashion
   begin
      Inc( Entry );
      if ( Entry > GLCONST.Max_tx_Lines ) then
        Entry := 1;
   end;

var
   CurrentEntry : Integer;
   i            : Integer;
   FoundNote    : boolean;
   pD           : pWorkDissect_Rec;
begin
   CurrentEntry := TheCurrentRow;
   i := CurrentEntry;
   IncEntry( i );
   Repeat
      pD := WorkDissect.Items[Pred( i )];
      with pD^ do begin
        foundNote := (dtNotes <> '') or (dtImportNotes <> '');
        if FoundNote then begin
           Result := i;
           Exit;
         end;
      end;
      IncEntry( i );
   Until ( i = CurrentEntry );

   //have checked all other lines now check current line
   pD := WorkDissect.Items[Pred( CurrentEntry )];
   foundNote := (pD^.dtNotes <> '') or (pD^.dtImportNotes <> '');

   if FoundNote then
      Result := i
   else
      result := -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.celAccountKeyPress(Sender: TObject;
  var Key: Char);
begin
   //ignore * press if editing
   if (key = '*')  or ((key = '-') and MyClient.clFields.clUse_Minus_As_Lookup_Key) then key := #0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.celAccountKeyDown(Sender: TObject; var Key: Word;
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
procedure TdlgDissection.CalcControlTotals( var Count : Integer; var Total, Remainder, GSTAmt, Percent : Double; DollarLinesOnly: Boolean = False );
//Calculate the total amount in the tblDissection, number of valid dissections, and the remaining
//amount
//NOTE:   Total is returned as if it were a money amount, ie. amount * 100.
//        Remainder is returned as a double ( money / 100)
var
   i       : integer;
   pD      : pWorkDissect_Rec;
begin
   Count := 0;
   Total := 0;
   GSTAmt := 0;
   Percent := 0;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pD := WorkDissect.Items[i];
      with pD^ do begin
         if (dtAccount <> '') or (dtAmount <> 0.0) then
            Inc( Count );
         if (not DollarLinesOnly) or
            (DollarLinesOnly and (dtPercent_Amount = 0)) then
         begin
           Total := Total + dtAmount;
           GSTAmt := GSTAmt + dtGST_Amount;
         end;
         if dtPercent_Amount <> 0 then
          Percent := Percent + dtPercent_Amount;
      end;
   end;
   Remainder   := GenUtils.Money2Double( pTran^.txAmount ) - ( Total/100 );
end;

function TdlgDissection.HasSingle100PercentLine: Boolean;
var
   i, c    : integer;
   pD      : pWorkDissect_Rec;
   Has100  : Boolean;
begin
   Has100 := False;
   c := 0;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pD := WorkDissect.Items[i];
      with pD^ do begin
         if dtPercent_Amount = 1000000 then
          Has100 := True
         else if dtPercent_Amount <> 0 then
          Inc(c);
      end;
   end;
   Result := Has100 and (c = 0);
end;

function TdlgDissection.HasPercentLines: Boolean;
var
   i       : integer;
   pD      : pWorkDissect_Rec;
begin
   Result := False;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pD := WorkDissect.Items[i];
      with pD^ do begin
         if dtPercent_Amount <> 0 then
         begin
          Result := True;
          exit;
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.UpdateControlTotals;
var
   i       : integer;
   pD      : pWorkDissect_Rec;
begin
  fControlTotals.ctCount             := 0;
  fControlTotals.ctAmount            := 0;
  fControlTotals.ctLocal_Amount      := 0;
  fControlTotals.ctRemainder         := 0;
  fControlTotals.ctLocal_Remainder   := 0;
  fControlTotals.ctGST               := 0;
  fControlTotals.ctPercent           := 0;
  fControlTotals.ctSpecified_Amount  := 0;
  fControlTotals.ctLocal_Specified_Amount := 0;

  with fControlTotals do
  begin
    for i := 0 to Pred( GLCONST.Max_tx_Lines ) do
    begin
      pD := WorkDissect.Items[i];
      with pD^ do
      begin
        if (dtAccount <> '') or ( dtAmount <> 0.0 ) then
        Begin
          Inc( ctCount );
          ctAmount := ctAmount + dtAmount;
          ctLocal_Amount   := ctLocal_Amount + dtLocal_Amount;
          ctGST            := ctGST + dtGST_Amount;
          ctPercent := ctPercent + dtPercent_Amount;
          if dtPercent_Amount = 0 then
          begin
            ctSpecified_Amount := ctSpecified_Amount + dtLocal_Amount;
            ctLocal_Specified_Amount   := ctLocal_Specified_Amount   + dtAmount;
          end;
        end;
      end;
    end;
    ctRemainder := pTran.txAmount - ctAmount;
    ctLocal_Remainder := 0;
    if (pTran.Default_Forex_Rate <> 0) then
      ctLocal_Remainder := pTran.Local_Amount - ctLocal_Amount;
  end;
end;

procedure TdlgDissection.UpdateDisplayTotals(AmountChanged: boolean = false);
begin
  UpdateControlTotals;

  lblBSTotal.Caption  := BankAcct.MoneyStr( FControlTotals.ctAmount );
  lblBSRemaining.Caption := BankAcct.MoneyStr( FControlTotals.ctRemainder );
  if fIsForex then
  begin
    lblLCTotalField.Caption := MyClient.MoneyStr( FControlTotals.ctLocal_Amount );
    lblLCRemainingField.Caption := MyClient.MoneyStr( FControlTotals.ctLocal_Remainder );
  end;

  lblGSTAmt.Caption := MyClient.MoneyStr( FControlTotals.ctGST );

  if ( FControlTotals.ctRemainder = 0 ) then
  begin
    lblPercentTotal.Caption  := '100.0000';
    lblPercentRemain.Caption := '0.0000';
  end
  else if AmountChanged and (FControlTotals.ctRemainder <> 0) then
  begin
    lblPercentTotal.Caption  := '0.0000';
    lblPercentRemain.Caption := '100.0000';
  end else
  begin
    lblPercentTotal.Caption := Format( '%0.4f', [FControlTotals.ctPercent/10000] );
    lblPercentRemain.Caption := Format( '%0.4f', [100 - (FControlTotals.ctPercent/10000)] );
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.stbDissectMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (X < stbDissect.Panels[PANELMODE].Width) {and (not EditMode)} then begin
    ToggleColEditMode;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.btnChartClick(Sender: TObject);
begin
   DoAccountLookup;
end;

procedure TdlgDissection.btnJobClick(Sender: TObject);
begin
   DoJobLookup;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.celAmountKeyPress(Sender: TObject; var Key: Char);
var
   pD: pWorkDissect_Rec;
begin
  pD := WorkDissect.items[ tblDissect.ActiveRow-1 ];
  if ( key in ['$', '£' ] ) and FStartedEdit then
  begin
    Key := #0;
    exit;
  end
  else if (key in ['$', '£']) and (not pD.dtAmount_Type_Is_Percent) and (not FStartedEdit) then
  begin
    tblDissect.OnDoneEdit := nil;
    tblDissect.OnEndEdit := nil;
    tblDissect.StopEditingState(False);
    tblDissect.OnDoneEdit := tblDissectDoneEdit;
    tblDissect.OnEndEdit := tblDissectEndEdit;
    Key := #0;
    exit;
  end
  else
    DoCelAmountKeyPress(Sender, Key);
end;

procedure TdlgDissection.DoCelAmountKeyPress(Sender: TObject; var Key: Char; Move: Boolean = True);
//note:  Total is returned * 100 ie. as a money???
var
   Percentage    : Double;
   pD            : pWorkDissect_Rec;
   pDissectRec   : pWorkDissect_Rec;
   Msg           : TWMKey;
   LineNo        : integer;
   NotEnoughLines: boolean;
   GSTOnTotal    : Money;
   GSTOnPercent  : Money;
   GSTRate       : double;
   TempClassNo   : byte;
   S             : string;
   GrossUpFactor : double;
   mNewAmount: Money;
   UseSavedAmount: Boolean;
   SavedAmount: Money;
   Count : Integer;
   Total : Double;
   Remainder: Double;
   GSTTotal   : Double;
   Percent: Double;
   IsActive: boolean;
begin
  IsActive := True;
  SavedAmount := 0;
  UseSavedAmount := False;
  {treat value as percentage}
  if key in ['%','/'] then begin
     pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
     if ColumnFmtList.ColumnDefn_At(tblDissect.ActiveCol)^.cdFieldID = cePercent then
     begin
       // Percent has to become amount
       UseSavedAmount := True;
       Savedamount := pD.dtAmount;
     end;
     //stop any further processing of key
     Key := #0;
     if tblDissect.StopEditingState( True ) and Move then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
     if UseSavedAmount then
        pD.dtPercent_Amount := SavedAmount * 100
     else
        pD.dtPercent_Amount := abs(pD.dtAmount * 100);
     //Percentage := Abs( TOvcNumericField( celAmount.CellEditor).AsFloat);
     //pD.dtPercent_Amount := Percentage * 10000;
     PercentEdited(pD);
     ReCalcPercentAmounts;
  end
  else if key in ['$', '£'] then begin
     pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
     if ColumnFmtList.ColumnDefn_At(tblDissect.ActiveCol)^.cdFieldID = ceAmount then
     begin
       // Percent has to become amount
       UseSavedAmount := True;
       Savedamount := pD.dtPercent_Amount;
     end;
     //stop any further processing of key
     Key := #0;
     CalcControlTotals( Count, Total, Remainder, GSTTotal, Percent );
     if tblDissect.StopEditingState( True ) and Move then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
     if UseSavedAmount then
       pD.dtAmount := SavedAmount / 100
     else
       pD.dtAmount := pD.dtPercent_Amount / 100;
     AmountEdited(pD);
     if HasPercentLines and (pD.dtAmount = Double2Money(Remainder)) then
     begin
       pD^.dtPercent_Amount := 1000000 - Percent;
       pD^.dtAmount_Type_Is_Percent := True;
       UpdateDisplayTotals;
     end
     else
     begin
       pD.dtPercent_Amount := 0;
       ReCalcPercentAmounts;
     end;
  end
  else if ( Key in ['*', '@']) then
    begin
      //use gst rate for class if known, otherwise use default
      pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
      // #740 - if no GST class then skip this
      if pD^.dtGST_Class <> 0 then
      begin
        GSTRate := GetGSTClassRate( MyClient, pTran^.txDate_Effective, pD^.dtGST_Class);

        if Key = '*' then
          begin
            if GSTRate <> 0 then
              begin
                GrossUpFactor := 1 + ( 1 / GSTRate);
                TOvcNumericField( celAmount.CellEditor).AsFloat := TOvcNumericField( celAmount.CellEditor).AsFloat * GrossUpFactor;
              end;
          end
        else
          //calculate gross from net
          begin
            TOvcNumericField( celAmount.CellEditor).AsFloat := TOvcNumericField( celAmount.CellEditor).AsFloat * ( 1 + GSTRate);
          end;
      end;

      Key := #0;

      if tblDissect.StopEditingState( True ) and Move then
      begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
      end;
    end
  else if ( MyClient.clFields.clCountry = whAustralia)  and (Key in ['#']) then begin
     {
       This provides the client with a way to easy way calculate the private use
       adjustment.

       The client enters a percentage value and presses '^'
       The amount for the current line is taken as x % of the total.
       The gst amount for the current line is taken as the gst on x% of the total
       A new line is inserted with 0 gst and the amount is calculated as

       ((GST on Total) - ( GST on X% of total)) x  percentage
     }
     Key := #0;
     //see if account code is valid, if not exit
     pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
     if not ( MyClient.clChart.CanCodeTo( pD^.dtAccount, IsActive)) then exit;
     //see if we can insert a row
     //count valid lines below this line
     LineNo := tblDissect.ActiveRow;
     //see if there are blank lines at the bottom of the table so can more
     //all subsequent rows down.
     NotEnoughLines := false;
     if ( LineNo + 1) > ( tblDissect.RowLimit -1) then
        NotEnoughLines := true
     else begin
        pDissectRec := WorkDissect.Items[ (tblDissect.RowLimit) -2];
        if ( pDissectRec^.dtAccount <> '') or ( pDissectRec^.dtAmount <> 0) then begin
           NotEnoughLines := true;
        end;
     end;

     if NotEnoughLines then begin
        S := 'There are not enough empty dissection lines to expand this entry.';
        HelpfulWarningMsg( S,0);
        exit;
     end;

     //get percentage
     Percentage := TOvcNumericField( celAmount.CellEditor).AsFloat;
     //find the rounded money value for the amount
     mNewAmount  := Double2Money( Money2Double( pTran^.txAmount ) * ( Percentage/100.0 ));
     //insert new amount
     TOvcNumericField( celAmount.CellEditor).AsFloat := Money2Double( mNewAmount);
     if tblDissect.StopEditingState( True ) then begin
        //calc gst on total
//        GSTCalc32.CalculateGST( MyClient, pTran^.txDate_Effective, pD^.dtAccount, pTran^.txAmount, TempClassNo, GSTOnTotal);
        GSTCalc32.CalculateGST( MyClient, pTran^.txDate_Effective, pD^.dtAccount, pTran^.Local_Amount, TempClassNo, GSTOnTotal);
        GSTOnPercent := pD^.dtGST_Amount;
        //calc new amount for new line
        mNewAmount := ( GSTOnTotal - GSTOnPercent) * (Percentage/100.0);
        //shuffle existing lines down x rows
        InsertRowsAfter( LineNo, 1);
        //move to new line;
        Inc( LineNo);
        //insert lines
        tblDissect.AllowRedraw := false;
        try
           //edit next line
           pDissectRec := WorkDissect.Items[ LineNo -1];
           pDissectRec^.dtAccount := pD^.dtAccount;
           pDissectRec^.dtAmount  := mNewAmount;
           pDissectRec^.dtGST_Class := 0;
           pDissectRec^.dtGST_Amount := 0;
           pDissectRec^.dtGST_Has_Been_Edited := true;
        finally
           tblDissect.InvalidateTable;
           tblDissect.AllowRedraw := true;
        end;
        UpdateDisplayTotals;
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end
  else if Key in ['0'..'9','-','.'] then
    FStartedEdit := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.celGstAmtKeyPress(Sender: TObject; var Key: Char);
var
   Percentage    : Double;
   NewAmount     : Double;
   pD            : pWorkDissect_Rec;
   Msg           : TWMKey;
   InclusiveAmt  : Double;
   ExchangeRate  : Double;
begin
  if not ValidDataRow( tblDissect.ActiveRow ) then exit;

  {treat value as percentage}
  if key in ['%','/'] then begin
     //stop any further processing of key
     Key := #0;
     Percentage := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     //check that the percentage value make sense
     if ( Percentage < 0.0 ) or ( Percentage > 100.0) then exit;

     pD         := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
     //find the new GST Amount
     InclusiveAmt := Money2Double( pD^.dtLocal_Amount);
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
     NewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));

     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblDissect.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end else if key = '£' then begin
     //stop any further processing of key
     Key := #0;
     NewAmount := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     if FBankAcct.IsAForexAccount then begin
       //Convert amount to base currency
       ExchangeRate := pTran.Default_Forex_Rate;
       if ExchangeRate > 0 then
         NewAmount := NewAmount / ExchangeRate
       else
         NewAmount := 0;
     end;
     TOvcNumericField(celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblDissect.StopEditingState(True) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.mniRecalcGSTClick(Sender: TObject);
begin
  DoRecalcGST;
  UpdateDisplayTotals;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.tblDissectMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Catch Right Click and decide which PopUp to display
var
  ColEstimate, RowEstimate : integer;
begin
{$IFNDEF SmartBooks}
  ConvertAmount1.Visible := False;
  if (Button = mbRight) then begin
     //estimate where click happened
     if tblDissect.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;
     // Get Column Type from Column
     case ColumnFmtList.ColumnDefn_At( ColEstimate )^.cdFieldID of
        ceGSTClass, ceGSTAmount : begin
           if ( RowEstimate = 0 ) then begin  //Show when Right click on heading only
              ShowPopup( x,y,popGST)
           end
           else
           begin
             tblDissect.ActiveRow := RowEstimate;
             if ColumnFmtList.ColumnDefn_At( ColEstimate )^.cdFieldID = ceGSTAmount then
                ConvertAmount1.Visible := (MyClient.clFields.clCountry = whUK) and
                             (BankAcct.IsAForexAccount);
             ShowPopup( x,y,popDissect);
           end;
        end;
        else begin
          tblDissect.ActiveRow := RowEstimate;
          ShowPopup( x,y,popDissect);
        end;
     end;
  end;
{$ENDIF}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   Undo := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DissectEntry( pT : pTransaction_rec; const NotesVisible : boolean; const SuperVisible : Boolean;
  BA: TBank_Account; AmountChanged: Boolean = false) : boolean;
{
Calling function to create the dialog, setup, build columns and populate data into
the columns.

When the OK button is pressed, if the total dissection amount is equal to the
transaction amount, the dissections in WorkDissect list are written back to Transaction
Dissection list to be saved to file when exiting the application.
}
var
   pDissection : pDissection_Rec;
   pD, pA, pB  : pWorkDissect_Rec;
   HasBlank, Has100 : boolean;
   Msg         :  String;
   i, j        : Integer;
   Count       : Integer;
   Total,
   Remain,
   Percent,
   GST         : Double;
   vsbWidth    : integer; //width of vertical scroll bar
   lDlg: TdlgDissection;
   W : Integer;
   AuditIDList: TList;
   MaintainMemScanStatus: boolean;
begin
   Result := false;
   if not Assigned(pT) then
      Exit;
   lDlg := TdlgDissection.Create(Application.MainForm);
   with lDlg do
     try
       MyClient.clRecommended_Mems.UpdateCandidateMems(pT, True);
       BankAcct := BA;
       fIsForex := BA.IsAForexAccount;
       CCode := MyClient.clExtra.ceLocal_Currency_Code;
       BCode := BA.baFields.baCurrency_Code;


       pTran := pT;  //Store pointer to transaction record

       //allocate memory for dissection list records
       WorkDissect := TList.Create;
       for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
          GetMem( pD, SizeOf(TWorkDissect_Rec) );
          ClearWorkRecDetails(pd);

          WorkDissect.Add( pD );
          if not Assigned( WorkDissect.Items[i] ) then begin
             Msg := Format( '%s : Memory Allocation Failed', [ UnitName ] );
             LogUtil.LogMsg( lmError, UnitName, Msg );
             Raise ENoMemoryLeft.Create( Msg );
          end;
       end;
       //determine if payee col can be edited.  Dont allow editing if
       //the payee has been set at the transaction level
       PayeeEditable := pTran^.txPayee_Number = 0;
       with pTran^ do begin
          //Fill Work Dissect records with real Dissection Record Values
          i := 0;
          pDissection := txFirst_Dissection;
          while pDissection <> nil do begin
             with pDissection^ do begin
                pD := WorkDissect.Items[i];
                with pD^ do begin
                   dtAccount         := dsAccount;
                   dtAmount          := dsAmount;
                   dtLocal_Amount    := Local_Amount;
                   dtDate            := pTran.txDate_Effective;
                   dtGST_Class       := dsGST_Class;
                   dtGST_Amount      := dsGST_Amount;
                   dtTax_Invoice     := dsTax_Invoice;
                   dtPayee_Number    := dsPayee_Number;
                   dtQuantity        := dsQuantity;
                   dtNarration       := dsGL_Narration;
                   dtJob             := dsJob_Code;
                   dtHas_Been_Edited := dsHas_Been_Edited;
                   dtGST_Has_Been_Edited := dsGST_Has_Been_Edited;
                   dtNotes           := dsNotes;
                   dtImportNotes     := dsECoding_Import_Notes;
                   dtSF_Imputed_Credit      := dsSF_Imputed_Credit;
                   dtSF_Tax_Free_Dist       := dsSF_Tax_Free_Dist;
                   dtSF_Tax_Exempt_Dist     := dsSF_Tax_Exempt_Dist;
                   dtSF_Tax_Deferred_Dist   := dsSF_Tax_Deferred_Dist;
                   dtSF_TFN_Credits         := dsSF_TFN_Credits;
                   dtSF_Foreign_Income      := dsSF_Foreign_Income;
                   dtSF_Foreign_Tax_Credits := dsSF_Foreign_Tax_Credits;
                   dtSF_Capital_Gains_Indexed := dsSF_Capital_Gains_Indexed;
                   dtSF_Capital_Gains_Disc := dsSF_Capital_Gains_Disc;
                   dtSF_Capital_Gains_Other := dsSF_Capital_Gains_Other;
                   dtSF_Other_Expenses      := dsSF_Other_Expenses;
                   dtSF_CGT_Date            := dsSF_CGT_Date;
                   dtSF_Franked             := dsSF_Franked;
                   dtSF_Unfranked           := dsSF_Unfranked;
                   dtSF_Interest            := dsSF_Interest;
                   dtSF_Capital_Gains_Foreign_Disc := dsSF_Capital_Gains_Foreign_Disc;
                   dtSF_Rent                := dsSF_Rent;
                   dtSF_Special_Income      := dsSF_Special_Income;
                   dtSF_Other_Tax_Credit    := dsSF_Other_Tax_Credit;
                   dtSF_Non_Resident_Tax    := dsSF_Non_Resident_Tax;
                   dtSF_Foreign_Capital_Gains_Credit := dsSF_Foreign_Capital_Gains_Credit;
                   dtSF_Member_ID           := dsSF_Member_ID;
                   dtSF_Member_Component    := dsSF_Member_Component;
                   dtSF_Member_Account_ID   := dsSF_Member_Account_ID;
                   dtSF_Fund_ID             := dsSF_Fund_ID;
                   dtSF_Fund_Code           := dsSF_Fund_Code;
                   dtSF_Member_Account_Code := dsSF_Member_Account_Code;
                   dtSF_Transaction_Type_ID := dsSF_Transaction_ID;
                   dtSF_Transaction_Type_Code := dsSF_Transaction_Code;
                   dtSF_Capital_Gains_Fraction_Half := dsSF_Capital_Gains_Fraction_Half;
                   dtSuper_Fields_Edited := dsSF_Super_Fields_Edited ;
                   dtDocument_Title      := dsDocument_Title;
                   dtDocument_Status_Update_Required := dsDocument_Status_Update_Required;
                   dtExternal_GUID       := dsExternal_GUID;
                   dtNotes_Read          := dsNotes_Read;
                   dtImport_Notes_Read   := dsImport_Notes_Read;
                   dtPercent_Amount      := dsPercent_Amount;
                   dtAmount_Type_Is_Percent := dsAmount_Type_Is_Percent;
                   dtForex_Conversion_Rate   := dsForex_Conversion_Rate   ;
                end;
                pDissection := dsNext;
                Inc( i );
             end;
          end;
       end;
       //set max gst id length
       celGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
       celAccount.MaxLength := MaxBK5CodeLen;
       //set up payee col
       if not PayeeEditable then begin
          celPayee.Font.Color := clGrayText;
          celPayee.Access     := otxReadOnly;
          btnPayee.enabled    := false;
       end;
       // Set up Orpheus table
       tblDissect.AllowRedraw := false;
       ColumnFmtList := TColFmtList.Create;
       SetupColumnFmtList;
       LoadLayoutForThisAcct;
       BuildTableColumns;
       InitController;
       with tblDissect do begin
          RowLimit := Succ( GLCONST.Max_tx_Lines );
          CommandOnEnter := ccRight;
          // This method pointer will fire during BuildTableColumns so nil until now
          OnColumnsChanged    := tblDissectColumnsChanged;
          OnActiveCellChanged := tblDissectActiveCellChanged;
          OnActiveCellMoving  := tblDissectActiveCellMoving;
          OnBeginEdit         := tblDissectBeginEdit;
          OnDoneEdit          := tblDissectDoneEdit;
          OnEndEdit           := tblDissectEndEdit;
          OnEnteringRow       := tblDissectEnteringRow;
          OnGetCellData       := tblDissectGetCellData;
          OnGetCellAttributes := tblDissectGetCellAttributes;
          OnUserCommand       := tblDissectUserCommand;
       end;
       //Set form size - set default width to the total of col widths
       vsbWidth := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
       ClientWidth := Min(ColumnFmtList.SumAdjColumnWidth + vsbWidth, Application.Mainform.Monitor.Width -20);

       //the form will currently be in the default position, load the
       //values from the ini setting to reposition to users last position and
       //state
       SetFormPositionFromINI(Width, Height);

{$IFDEF SmartBooks}
       SetColEditMode( emGeneral );  //SmartBooks does not use Restricted Mode
{$ELSE}
      if not MyClient.clFields.clAll_EditMode_DIS then
        SetColEditMode( emRestrict )
      else
        SetColEditMode( emGeneral );
{$ENDIF}
       //Set color for alternate lines in the table
       clStdLineLight   := clWindow;
       clStdLineDark    := bkbranding.AlternateCodingLineColor;

       // Control formatting
       // Finalised label and Chart button are mutually exclusive
       with btnChart do begin
          Left    := imgStatus.left;
          Visible := false;
       end;
       with btnPayee do begin
          Left    := btnChart.Left + btnChart.Width + 5;
          Visible := false;
       end;
       with btnJob do begin
          Left    := btnPayee.Left + btnChart.Width + 5;
          Visible := false;
       end;
       with sbtnSuper do
         begin
           Left    := btnJob.Left + sbtnSuper.Width + 5;
           Visible := false;
         end;
       with btnView do
           Left    := sbtnSuper.Left + btnView.Width + 5;
       with lblStatus do begin
          Left    := btnView.left + 50;
          Visible := false;
       end;
       // Analysis not shown for OZ or UK
       if MyClient.clFields.clCountry in [whAustralia, whUK] then begin
          lblAnalysis.Visible      := false;
          lblAnalysisField.Visible := false;
       end;

       //Display Transaction Details
       with pTran^ do begin
          lblDate.Caption                 := bkDate2Str( txDate_Effective );
          lblRef.Caption                  := GetFormattedReference( pTran);
          lblAnalysisField.Caption        := txAnalysis;

          If fIsForex then
          Begin
            lblForBSAmount.Caption            := 'Amount (' + BCode + ')';
            lblBSAmount.Caption               := BankAcct.MoneyStr( Statement_Amount );
            lblForLocalCurrencyAmount.Caption := 'Amount (' + CCode + ')';
            lblLocalCurrencyAmount.Caption    := MyClient.MoneyStr( Local_Amount );
            lblRate.Caption                   := ForexRate2Str( Default_Forex_Rate );
            lblForBSTotal.Caption             := 'Total (' + BCode + ') :';
            lblForBSRemaining.Caption         := 'Remaining (' + BCode + ') :';
            lblLCTotal.Caption                := 'Total (' + CCode + ') :';
            lblLCRemaining.Caption            := 'Remaining (' + CCode + ') :';
            lblLCTotalField.Visible := True;
            lblLCRemainingField.Visible := True;
            lblLCTotal.Visible := True;
            lblLCRemaining.Visible := True;
          end
          else
          Begin
            lblForLocalCurrencyAmount.Visible := False;
            lblLocalCurrencyAmount.Visible    := False;
            lblForRate.Visible                := False;
            lblRate.Visible                   := False;
            W := ( lblRate.Left - lblNarration.Left );
            lblNarration.Left := lblRate.Left; lblNarration.Width := lblNarration.Width + W;
            lblBSAmount.Caption               := BankAcct.MoneyStr( Statement_Amount );
            lblForBSAmount.Caption            := 'Amount';

            lblLCTotalField.Visible := False;
            lblLCRemainingField.Visible := False;
            lblLCTotal.Visible := False;
            lblLCRemaining.Visible := False;
          End;

          if txPayee_Number <> 0 then
             lblPayee.Caption                := inttostr( txPayee_Number)
          else
             lblPayee.caption := '';

          lblNarration.caption      := 'Narration';
          lblNarrationField.caption := txGL_Narration;

          lblNarrationField.Hint := lblNarrationField.caption;
          lblRef.Hint            := lblRef.caption;
          lblAnalysisField.Hint  := lblAnalysisField.caption;
          //Set control visibility
          lblStatus.Visible      := txLocked or (txDate_Transferred <> 0);
          btnChart.Visible     := not ( txLocked or (txDate_Transferred <> 0));
          btnPayee.Visible     := not ( txLocked or (txDate_Transferred <> 0));
          btnJob.Visible       := not ( txLocked or (txDate_Transferred <> 0));
          sBtnSuper.Visible    := FCanUseSuperFundFields and SuperVisible;
          EditSuperFields1.Visible := sBtnSuper.Visible;
          ClearSuperfundDetails1.Visible := sBtnSuper.Visible;
          if not btnChart.Visible then
          begin
            sBtnSuper.Left := btnChart.Left;
            if sBtnSuper.Visible then
              btnView.Left := btnPayee.Left
            else
              btnView.Left := btnChart.Left;
            lblStatus.Left := btnView.Left + btnView.Width + 50;
          end
          else if not sBtnSuper.Visible then
            btnView.Left := sBtnSuper.Left;

          if txLocked then begin
             //see if transferred as well
             if ( txDate_Transferred <> 0) then begin
                imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgTickLock.Picture.Bitmap;
                lblStatus.caption := ' This Transaction has been Transferred and Finalised ';
             end
             else begin
                //is only locked
                imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgLock.Picture.Bitmap;
                lblStatus.caption := ' This Transaction has been Finalised ';
             end;
          end
          else
          if ( txDate_Transferred <> 0) then begin
             imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgTick.Picture.Bitmap;
             lblStatus.caption := ' This Transaction has been Transferred ';
          end;
       end;

       UpdateBaseAmounts(pD);
       UpdateDisplayTotals(AmountChanged);

       //setup notes panel
       dsNotesAlwaysVisible    := NotesVisible;

       pmiNotesVisible.Checked := dsNotesAlwaysVisible;
       rzXBtn.Visible          := dsNotesAlwaysVisible;
       rzPinBtn.Visible        := not dsNotesAlwaysVisible;

       if dsNotesAlwaysVisible then
          PNotes.RestoreHotSpot
       else
          PNotes.CloseHotSpot;

       lbltxECodingNotes.Caption := GenUtils.StripReturnCharsFromString( Trim(pT^.txECoding_Import_Notes), '|');
       lbltxECodingNotes.Hint    := pT^.txECoding_Import_Notes;

       lbltxNotes.Caption        := GenUtils.StripReturnCharsFromString( Trim(pT^.txNotes), '|');
       lbltxNotes.Hint           := pT^.txNotes;

       if lbltxECodingNotes.Caption = '' then
       begin
         pnlTranDetails.Height := pnlTranDetails.Height - lbltxECodingNotes.Height;
         lbltxNotes.Top        := lbltxECodingNotes.Top;
       end;

       if lbltxNotes.Caption = '' then
       begin
         pnlTranDetails.Height := pnlTranDetails.Height - lbltxNotes.Height;
       end;

       // *******************
       ShowModal;
       // *******************

       if ModalResult <> mrOk then
          Exit;

       //Check if there is blank record within records.  This is to prevent
       //the changing of order of entries, but this only works when there is
       //no blank entry within entries.
       HasBlank := False;
       for i := 0 to ( GLCONST.Max_tx_Lines - 2 ) do begin
          pA := WorkDissect.Items[ i ];
          pB := WorkDissect.Items[ i+1 ];
          if (( pA^.dtAccount = '') and ( pB^.dtAccount <> '' )) or
             (( pA^.dtAmount  = 0 ) and ( pB^.dtAmount  <> 0   )) then begin
             HasBlank := True;
             Break;
          end;
       end;
       If HasBlank then //Remove blank record in between records
          RemoveBlanks;
       CalcControlTotals( Count, Total, Remain, GST, Percent );

       AuditIDList := TList.Create;
       try
         //Save audit ID's for reuse
         Dump_Dissections( pTran, AuditIDList); //Clear current dissection lines

         //if there is only 1 line in the dissection then
         //remove dissection and treat like normal transaction
         if (Count = 1) then
         begin
           pD := WorkDissect.Items[0];
           with pTran^, pD^ do
           begin
              txAccount    := dtAccount;
              txGST_Class  := dtGST_Class;       //GetGSTClassNo( MyClient, Chr( dtGST_Class ));
              txGST_Amount := dtGST_Amount;      //GenUtils.Double2Money(dtGST_Amount);
              txGL_Narration := dtNarration;
              txTax_Invoice_Available := dtTax_Invoice;
              txHas_Been_Edited := dtHas_Been_Edited;
              txGST_Has_Been_Edited := dtGST_Has_Been_Edited;
              txQuantity     := dtQuantity;
              txPayee_Number := dtPayee_Number;
              txJob_Code     := dtJob;
              //move dissection line amounts into transaction
              txSF_Imputed_Credit      := dtSF_Imputed_Credit;
              txSF_Tax_Free_Dist       := dtSF_Tax_Free_Dist;
              txSF_Tax_Exempt_Dist     := dtSF_Tax_Exempt_Dist;
              txSF_Tax_Deferred_Dist   := dtSF_Tax_Deferred_Dist;
              txSF_TFN_Credits         := dtSF_TFN_Credits;
              txSF_Foreign_Income      := dtSF_Foreign_Income;
              txSF_Foreign_Tax_Credits := dtSF_Foreign_Tax_Credits;
              txSF_Capital_Gains_Indexed := dtSF_Capital_Gains_Indexed;
              txSF_Capital_Gains_Other := dtSF_Capital_Gains_Other;
              txSF_Other_Expenses      := dtSF_Other_Expenses;
              txSF_CGT_Date            := dtSF_CGT_Date;
              txSF_Capital_Gains_Disc  := dtSF_Capital_Gains_Disc;
              txSF_Franked             := dtSF_Franked;
              txSF_Unfranked           := dtSF_Unfranked;
              txSF_Interest            := dtSF_Interest;
              txSF_Capital_Gains_Foreign_Disc := dtSF_Capital_Gains_Foreign_Disc;
              txSF_Rent                := dtSF_Rent;
              txSF_Special_Income      := dtSF_Special_Income;
              txSF_Other_Tax_Credit    := dtSF_Other_Tax_Credit;
              txSF_Non_Resident_Tax    := dtSF_Non_Resident_Tax;
              txSF_Member_ID           := dtSF_Member_ID;
              txSF_Foreign_Capital_Gains_Credit := dtSF_Foreign_Capital_Gains_Credit;
              txSF_Member_Component    := dtSF_Member_Component;
              txSF_Member_Account_ID   := dtSF_Member_Account_ID;
              txSF_Fund_ID             := dtSF_Fund_ID;
              txSF_Fund_Code           := dtSF_Fund_Code;
              txSF_Member_Account_Code := dtSF_Member_Account_Code;
              txSF_Transaction_ID      := dtSF_Transaction_Type_ID;
              txSF_Transaction_Code    := dtSF_Transaction_Type_Code;
              txSF_Capital_Gains_Fraction_Half := dtSF_Capital_Gains_Fraction_Half;
              txSF_Super_Fields_Edited := dtSuper_Fields_Edited ;

              txNotes_Read := dtNotes_Read;
              txImport_Notes_Read := dtImport_Notes_Read;

              txCoded_By     := cbManual;

              if pD.dtHas_Been_Edited or pD.dtGST_Has_Been_Edited then
              begin
                pT^.txTransfered_To_Online := False;
              end;
           end;
         end
         else
         begin
            // Store dissection lines
            // re-sort - store $ lines first followed by % lines
            Has100 := HasSingle100PercentLine;
            for j := 0 to 1 do
            begin
              for i := 0 to Pred( Count ) do
              begin
                pD := WorkDissect.Items[i];
                if ((j = 0) and (pD.dtPercent_Amount <> 0))
                  or ((j = 1) and (pD.dtPercent_Amount = 0)) then
                   Continue;
                pDissection := New_Dissection_Rec;
                with pDissection^, pD^ do
                begin
                   dsTransaction     := pTran;
                   dsAccount         := dtAccount;
                   dsAmount          := dtAmount;
                   dsGST_Class       := dtGST_Class;
                   dsGST_Amount      := dtGST_Amount;
                   dsQuantity        := dtQuantity;
                   dsPayee_Number    := dtPayee_Number;
                   dsJob_Code         := dtJob;
                   if dsJob_Code <> pT.txJob_Code then
                   begin
                      //  pT.txJob_LRN can only be the same as ALL disections
                      pT.txJob_Code := '';
                   end;

                   dsForex_Conversion_Rate    := dtForex_Conversion_Rate    ;

                   dsGL_Narration             := dtNarration;
                   dsTax_Invoice := dtTax_Invoice;
                   dsHas_Been_Edited := dtHas_Been_Edited;
                   dsGST_Has_Been_Edited  := dtGST_Has_Been_Edited;
                   dsNotes                := dtNotes;
                   dsECoding_Import_Notes := dtImportNotes;

                   //smartlink
                   dsDocument_Title       := dtDocument_Title;
                   dsDocument_Status_Update_Required := dtDocument_Status_Update_Required;
                   dsExternal_GUID := dtExternal_GUID;

                   //super fields
                   dsSF_Imputed_Credit      := dtSF_Imputed_Credit;
                   dsSF_Tax_Free_Dist       := dtSF_Tax_Free_Dist;
                   dsSF_Tax_Exempt_Dist     := dtSF_Tax_Exempt_Dist;
                   dsSF_Tax_Deferred_Dist   := dtSF_Tax_Deferred_Dist;
                   dsSF_TFN_Credits         := dtSF_TFN_Credits;
                   dsSF_Foreign_Income      := dtSF_Foreign_Income;
                   dsSF_Foreign_Tax_Credits := dtSF_Foreign_Tax_Credits;
                   dsSF_Capital_Gains_Indexed  := dtSF_Capital_Gains_Indexed;
                   dsSF_Capital_Gains_Disc  := dtSF_Capital_Gains_Disc;
                   dsSF_Capital_Gains_Other := dtSF_Capital_Gains_Other;
                   dsSF_Other_Expenses      := dtSF_Other_Expenses;
                   dsSF_CGT_Date            := dtSF_CGT_Date;
                   dsSF_Franked             := dtSF_Franked;
                   dsSF_Unfranked           := dtSF_Unfranked;
                   dsSF_Interest            := dtSF_Interest;
                   dsSF_Capital_Gains_Foreign_Disc := dtSF_Capital_Gains_Foreign_Disc;
                   dsSF_Rent                := dtSF_Rent;
                   dsSF_Special_Income      := dtSF_Special_Income;
                   dsSF_Other_Tax_Credit    := dtSF_Other_Tax_Credit;
                   dsSF_Non_Resident_Tax    := dtSF_Non_Resident_Tax;
                   dsSF_Foreign_Capital_Gains_Credit := dtSF_Foreign_Capital_Gains_Credit;
                   dsSF_Member_ID           := dtSF_Member_ID;
                   dsSF_Member_Component    := dtSF_Member_Component;
                   dsSF_Member_Account_ID   := dtSF_Member_Account_ID;
                   dsSF_Fund_ID             := dtSF_Fund_ID;
                   dsSF_Fund_Code           := dtSF_Fund_Code;
                   dsSF_Member_Account_Code := dtSF_Member_Account_Code;
                   dsSF_Transaction_ID      := dtSF_Transaction_Type_ID;
                   dsSF_Transaction_Code    := dtSF_Transaction_Type_Code;
                   dsSF_Capital_Gains_Fraction_Half := dtSF_Capital_Gains_Fraction_Half;
                   dsSF_Super_Fields_Edited := dtSuper_Fields_Edited ;

                   dsNotes_Read := dtNotes_Read;
                   dsImport_Notes_Read := dtImport_Notes_Read;

                   if not Has100 then
                   begin
                     dsPercent_Amount         := dtPercent_Amount;
                     dsAmount_Type_Is_Percent := dtPercent_Amount <> 0;
                   end
                   else
                   begin
                     dsAmount_Type_Is_Percent := False;
                     dsPercent_Amount := 0;
                   end;

                   if AuditIDList.Count > 0 then
                   begin
                     pDissection.dsAudit_Record_ID := integer(AuditIDList.Items[0]);
                     TrxList32.AppendDissection( pTran, pDissection, nil );
                     AuditIDList.Delete(0);
                   end else
                     TrxList32.AppendDissection( pTran, pDissection, MyClient.ClientAuditMgr );
                end; {with}
              end; {for i}
            end; {for j}

            pTran^.txCoded_By    := cbManual;
            pTran^.txAccount     := DISSECT_DESC;
            //clean up any gst amounts that are left on the transaction
            ClearGSTFields( pTran);
            ClearSuperFundFields( pTran);

            if pD.dtHas_Been_Edited or pD.dtGST_Has_Been_Edited then
            begin
              pT^.txTransfered_To_Online := False;
            end;

            Result := True;
         end;
       finally
         AuditIDList.Free;
       end;
      finally
        Free;
      end;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.celGstAmtChange(Sender: TObject);
begin
   //test to see if need to automatically put minus sign
   if AutoPressMinus then
       keybd_event(vk_subtract,0,0,0);
   AutoPressMinus := false;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.DoPayeeLookup;
{
Assists the user in coding by allowing selection of Payee Codes from
Payee Lookup

The function PickPayee(IntCode) accepts a Code and attempts to position the
List on that Code.  It returns True if the user selects an Payee Code and puts
the Code in the Var Parameter, if no Code is chosen it returns False.

If we can edit Payee column, We do not know the position
or the Edit State of the Active Cell when this method is called.  We therefore
end any existing edit and move to the Payee column.

If only Account column is editable, we end any existing edit and find the
current transaction the user is working on.  The routine then edits the
transaction directly.
}
var
   pD               : pWorkDissect_Rec;
   InEditOnEntry    : boolean;
   intCode          : integer;
   Msg              : TWMKey;
   PayeeNotEditable : Boolean;
   OldPayeeNo       : integer;
begin
   //check if payee has been set at transaction level
   if pTran^.txPayee_Number <> 0 then exit;

   //Check to see if a payee col exists
   PayeeNotEditable :=  not ColumnFmtList.FieldIsEditable( cePayee);

   if not ( PayeeNotEditable) then begin
      with tblDissect do begin
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
           if BankAcct.ValidPayeeCode(IntCode) then begin
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
      with tblDissect do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
         IntCode := pD^.dtPayee_Number;
         OldPayeeNo := pD^.dtPayee_Number;
         if PickPayee(IntCode) then begin
           if BankAcct.ValidPayeeCode(IntCode) then begin
             //if get here then have a valid payee from the picklist, so edit
             //the fields in the transaction
             pD^.dtPayee_Number := IntCode;
             if not PayeeEdited(pD,ActiveRow) then
               pD^.dtPayee_Number := OldPayeeNo;

             pTran.txTransfered_To_Online := False;
             
             InvalidateRow(ActiveRow);  //forces repaint of row
             Msg.CharCode := VK_RIGHT;
             celPayee.SendKeyToTable(Msg);
           end;
         end;
      end;
   end;
end;
//------------------------------------------------------------------------------

function TdlgDissection.PayeeEdited(pD: pWorkDissect_Rec; RowNo: Integer) : boolean;
var
   APayee       : TPayee;
   isPayeeDissected : boolean;
   DissectAmt   : PayeeSplitTotals;  //dynamic array
   DissectPct   : PayeeSplitPercentages;
   i            : integer;
   S            : string;
   RecodeRequired : Boolean;
   lineNo         : integer;
   LinesRequired  : integer;
   pDissectRec    : pWorkDissect_Rec;
   NotEnoughLines : Boolean;
   PayeeLine      : pPayee_Line_Rec;

   function DoSuperFund: Boolean;
   begin
      if PayeeLine.plSF_Edited
      and CanUseSuperFundFields (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used ) then begin

         Result := (not (MyClient.clFields.clAccounting_System_Used in [saBGLSimpleFund, saBGLSimpleLedger, saBGL360]))
                or (pTran.txDate_Effective >= mcSwitchDate); // cannot do new and Old list

      end else
         Result := False
   end;


begin
  result := true;

  if pD^.dtPayee_Number = 0 then exit;  //don't need to do anything

  if (not BankAcct.ValidPayeeCode(pD^.dtPayee_Number)) then begin
    Result := False;
    Exit;
  end;

  UpdateBaseAmounts(pD);

  APayee := MyClient.clPayee_List.Find_Payee_Number(pD^.dtPayee_Number);
  with pD^, APayee do begin
     //Payee is dissected if more than one line with Account Code
     isPayeeDissected := APayee.IsDissected;
     //see if user want to override existing fields.  Don't ask if nothing would
     //be changed.
     if (dtAccount <> '') then begin
        RecodeRequired := false;
        //account code must be there already
        PayeeLine := APayee.FirstLine;
        if ( PayeeLine <> nil) then
        begin                               
          //compare with payee details
          if IsPayeeDissected
          or ( dtAccount <> PayeeLine.plAccount)
          or (( dtNarration <> PayeeLine.plGL_Narration) and ( PayeeLine.plGL_Narration <> '')) then
             RecodeRequired := true;
        end;

        if RecodeRequired then begin
           case PayeeRecodeDlg.AskRecodeOnPayeeChange of
              prCancel : begin
                 result := false;
                 exit;
              end;
              prNarrationOnly : begin  //edit narration
                //if payee is dissected then
                //use payee name, otherwise use narration from first line
                if ( IsPayeeDissected) then
                  dtNarration := pdName
                else
                begin
                  if (APayee.pdLines.ItemCount > 0) then
                  begin
                    PayeeLine := APayee.FirstLine;
                    if ( PayeeLine.plGL_Narration <> '') then
                      dtNarration := PayeeLine.plGL_Narration;
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

     //code the entry with the details from the payee
     if not (isPayeeDissected) then
     begin
       //payee is a single line so alter existing transaction
       PayeeLine := APayee.FirstLine;
       if ( PayeeLine <> nil) then
       begin
         dtAccount := PayeeLine.plAccount;
         if ( PayeeLine.plGL_Narration <> '') then
           dtNarration   := PayeeLine.plGL_Narration
         else
           dtNarration := pTran^.txGL_Narration;

         if (PayeeLine.plGST_Has_Been_Edited) then begin
            dtGST_Class    := PayeeLine.plGST_Class;
            dtGST_Amount   := CalculateGSTForClass( MyClient, pTran^.txDate_Effective, dtLocal_Amount, dtGST_Class);
            dtGST_Has_Been_Edited := true;
         end
         else begin
            CalculateGST( MyClient, pTran^.txDate_Effective, dtAccount, dtLocal_Amount, dtGST_Class, dtGST_Amount);
            dtGST_Has_Been_Edited := false;
         end;

         if DoSuperFund then begin
            if PayeeLine.plSF_PCFranked <> 0 then begin
                dtSF_Franked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCFranked) * Money2Double(dtAmount)/100));
                dtSF_Imputed_Credit := FrankingCredit(dtSF_Franked,pTran.txDate_Effective);
             end;
             if PayeeLine.plSF_PCUnFranked <> 0 then begin
                if (PayeeLine.plSF_PCUnFranked + PayeeLine.plSF_PCFranked) = 1000000 then
                   dtSF_UnFranked := Abs(dtAmount) - dtSF_Franked  // No Rounding Isues
                else
                   dtSF_UnFranked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCUnFranked) * Money2Double(dtAmount)/100));
             end;
             dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
             dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
             dtSF_Fund_ID              := PayeeLine.plSF_Fund_ID;
             dtSF_Fund_Code            := PayeeLine.plSF_Fund_Code;
             dtSF_Member_ID            := PayeeLine.plSF_Member_ID;
             dtSF_Transaction_type_ID  := PayeeLine.plSF_Trans_ID;
             dtSF_Transaction_Type_Code := PayeeLine.plSF_Trans_Code;
             dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
             dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
             dtSF_Member_Component     := PayeeLine.plSF_Member_Component;

             if PayeeLine.plQuantity <> 0 then
                dtQuantity := PayeeLine.plQuantity;

             if PayeeLine.plSF_GDT_Date <> 0 then
                dtSF_CGT_Date := PayeeLine.plSF_GDT_Date;

             dtSF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

             SplitRevenue(dtAmount,
                          dtSF_Tax_Free_Dist,
                          dtSF_Tax_Exempt_Dist,
                          dtSF_Tax_Deferred_Dist,
                          dtSF_Foreign_Income,
                          dtSF_Capital_Gains_Indexed,
                          dtSF_Capital_Gains_Disc,
                          dtSF_Capital_Gains_Other,
                          dtSF_Capital_Gains_Foreign_Disc,
                          dtSF_Other_Expenses,
                          dtSF_Interest,
                          dtSF_Rent,
                          dtSF_Special_Income,
                          PayeeLine);

             dtSuper_Fields_Edited  := True;
          end else begin
             WorkRecDefs.ClearSuperfundDetails(pD);
          end;

       end;
     end
     else begin
        //payee is dissected, so dissect the transaction
        LinesRequired := APayee.pdLines.ItemCount;
        //check something to do
        if LinesRequired = 0 then exit;

        //can reduce by 1 because will use current line.
        Dec( LinesRequired);

        //check if we can insert this required no on lines.
        //count valid lines below this line
        LineNo := RowNo;
        //see if there are blank lines at the bottom of the table so can more
        //all subsequent rows down.
        NotEnoughLines := false;
        if ( LineNo + LinesRequired) > ( tblDissect.RowLimit -1) then
           NotEnoughLines := true
        else begin
           for i := 0 to Pred( LinesRequired) do begin
              pDissectRec := WorkDissect.Items[ (tblDissect.RowLimit - i) -2];
              if ( pDissectRec^.dtAccount <> '') or ( pDissectRec^.dtAmount <> 0) then begin
                 NotEnoughLines := true;
                 Break;
              end;
           end;
        end;
        if NotEnoughLines then begin
           S := 'There are not enough empty dissection lines to expand this entry.';
           HelpfulWarningMsg( S,0);
           Result := False;
           exit;
        end;
        //shuffle existing lines down x rows
        InsertRowsAfter( LineNo, LinesRequired);
        //insert lines
        tblDissect.AllowRedraw := false;
        try
           //split value
           PayeePercentageSplit( dtAmount, aPayee, DissectAmt, DissectPct);

           for i := aPayee.pdLines.First to aPayee.pdLines.Last do
           begin
             PayeeLine := aPayee.pdLines.PayeeLine_At(i);
             pDissectRec := WorkDissect.Items[ LineNo -1];

             pDissectRec.dtPayee_Number := pdNumber;
             pDissectRec.dtDate := PTran.txDate_Effective;
             if PayeeLine.plGL_Narration <> '' then
               pDissectRec.dtNarration := PayeeLine.plGL_Narration
             else
               pDissectRec.dtNarration := pTran^.txGL_Narration;

             pDissectRec.dtAccount := PayeeLine.plAccount;
             pDissectRec.dtAmount  := DissectAmt[i];
             pDissectRec.dtPercent_Amount := 0;
             pDissectRec.dtAmount_Type_Is_Percent := False;

             UpdateBaseAmounts(pDissectRec);

             //dtNarration :=   ...already changed
             if (PayeeLine.plGST_Has_Been_Edited) then begin
                pDissectRec.dtGST_Class    := PayeeLine.plGST_Class;
                pDissectRec.dtGST_Amount   := CalculateGSTForClass( MyClient,
                                                                    pTran^.txDate_Effective,
                                                                    pDissectRec^.dtLocal_Amount,
                                                                    pDissectRec^.dtGST_Class);
                pDissectRec.dtGST_Has_Been_Edited := true;
             end
             else begin
                CalculateGST( MyClient,
                              pTran^.txDate_Effective,
                              pDissectRec^.dtAccount,
                              pDissectRec^.dtLocal_Amount,
                              pDissectRec^.dtGST_Class,
                              pDissectRec^.dtGST_Amount);
                pDissectRec^.dtGST_Has_Been_Edited := false;
             end;

             if DoSuperFund then begin
                if PayeeLine.plSF_PCFranked <> 0 then begin
                   pDissectRec.dtSF_Franked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCFranked) * Money2Double(pDissectRec.dtAmount)/100));
                   pDissectRec.dtSF_Imputed_Credit := FrankingCredit(pDissectRec.dtSF_Franked,pTran.txDate_Effective);
                end;
                if PayeeLine.plSF_PCUnFranked <> 0 then begin
                   if (PayeeLine.plSF_PCUnFranked + PayeeLine.plSF_PCFranked) = 1000000 then
                      pDissectRec.dtSF_UnFranked := Abs(pDissectRec.dtAmount) - pDissectRec.dtSF_Franked  // No Rounding Isues
                   else
                       pDissectRec.dtSF_UnFranked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCUnFranked) * Money2Double(pDissectRec.dtAmount)/100));
                end;
                pDissectRec.dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                pDissectRec.dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                pDissectRec.dtSF_Fund_ID              := PayeeLine.plSF_Fund_ID;
                pDissectRec.dtSF_Fund_Code            := PayeeLine.plSF_Fund_Code;
                pDissectRec.dtSF_Member_ID            := PayeeLine.plSF_Member_ID;
                pDissectRec.dtSF_Transaction_type_ID  := PayeeLine.plSF_Trans_ID;
                pDissectRec.dtSF_Transaction_Type_Code := PayeeLine.plSF_Trans_Code;
                pDissectRec.dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                pDissectRec.dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                pDissectRec.dtSF_Member_Component     := PayeeLine.plSF_Member_Component;

                if PayeeLine.plQuantity <> 0 then
                    pDissectRec.dtQuantity := PayeeLine.plQuantity;

                if PayeeLine.plSF_GDT_Date <> 0 then
                   pDissectRec.dtSF_CGT_Date := PayeeLine.plSF_GDT_Date;

                pDissectRec.dtSF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

                SplitRevenue(pDissectRec.dtAmount,
                          pDissectRec.dtSF_Tax_Free_Dist,
                          pDissectRec.dtSF_Tax_Exempt_Dist,
                          pDissectRec.dtSF_Tax_Deferred_Dist,
                          pDissectRec.dtSF_Foreign_Income,
                          pDissectRec.dtSF_Capital_Gains_Indexed,
                          pDissectRec.dtSF_Capital_Gains_Disc,
                          pDissectRec.dtSF_Capital_Gains_Other,
                          pDissectRec.dtSF_Capital_Gains_Foreign_Disc,
                          pDissectRec.dtSF_Other_Expenses,
                          pDissectRec.dtSF_Interest,
                          pDissectRec.dtSF_Rent,
                          pDissectRec.dtSF_Special_Income,
                          PayeeLine);

                pDissectRec.dtSuper_Fields_Edited  := True;
             end else begin
                WorkRecDefs.ClearSuperfundDetails(pDissectRec);
             end;

              //move to next line
             Inc( LineNo);
           end;
        finally
           tblDissect.InvalidateTable;
           tblDissect.AllowRedraw := true;
        end;
     end;
  end;  {with payee^, pd^}

   with tblDissect do begin
      AllowRedraw := false;
      InvalidateTable;
      AllowRedraw := true;
   end;

  UpdateDisplayTotals;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.btnPayeeClick(Sender: TObject);
begin
   DoPayeeLookup;
end;
//------------------------------------------------------------------------------

procedure TdlgDissection.Insertanewline1Click(Sender: TObject);
begin
  DoInsertLine;
end;

procedure TdlgDissection.InsertRowsAfter(Row, NewRows: integer);
//insert x newrows after the current row num
var
   FromRowNum : integer;
   ToRowNum   : integer;
   pDFrom     : pWorkDissect_Rec;
   pDTo       : pWorkDissect_Rec;
begin
   tblDissect.AllowRedraw := false;
   try
      //move rows down, starting from bottom of list
      ToRowNum := tblDissect.RowLimit - 1;
      FromRowNum := ToRowNum - NewRows;

      while FromRowNum > Row do
      begin
         pDFrom := WorkDissect.Items[ FromRowNum -1];
         pDTo   := WorkDissect.Items[ ToRowNum -1];
         //copy fields
         pDTo^ := pdFrom^;
         //blank from rec
         ClearWorkRecDetails(PdFrom);
         Dec( ToRowNum);
         FromRowNum := ToRowNum - NewRows;
      end;
   finally
      tblDissect.AllowRedraw := true;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgDissection.pNotesResize(Sender: TObject);
begin
   pnlNotes.Enabled := ( not pNotes.HotSpotClosed);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.memNotesChange(Sender: TObject);
var
   pD : pWorkDissect_Rec;
begin
   if not ValidDataRow(tblDissect.ActiveRow) then exit;
   with tblDissect do begin
      pD   := WorkDissect.Items[ tblDissect.ActiveRow - 1];
      pD.dtNotes := memNotes.Text;
      if pD.dtNotes = '' then
        pD.dtNotes_Read := False;
      tblDissect.InvalidateColumn( ceAccount);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.pnlNotesEnter(Sender: TObject);
begin
  pnlNotesTitle.color := bkBranding.HeaderBackgroundColor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.pnlNotesExit(Sender: TObject);
begin
  pnlNotesTitle.Color          := clBtnFace;

  if not dsNotesAlwaysVisible then
    PNotes.CloseHotSpot;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.rzXBtnClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
   DoGotoGrid;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.rzPinBtnClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoGotoNotes;
begin
   if not tblDissect.StopEditingState(True) then Exit;

   PNotes.RestoreHotSpot;

   if pnlNotes.enabled then
      SetFocusSafe( memNotes);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.ToggleAlwaysShowNotes;
begin
   if not dsNotesAlwaysVisible then begin
      dsNotesAlwaysVisible := true;
      pmiNotesVisible.Checked := true;
      rzPinBtn.visible := false;
      rzXBtn.visible := true;
   end
   else begin
      dsNotesAlwaysVisible := false;
      rzXBtn.visible := false;
      rzPinBtn.visible := true;
      pmiNotesVisible.Checked := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.pmiNotesVisibleClick(Sender: TObject);
begin
   ToggleAlwaysShowNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.pmiGotoGridClick(Sender: TObject);
begin
   DoGotoGrid;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoGotoGrid;
begin
   SetFocusSafe( tblDissect);
   if not dsNotesAlwaysVisible then
      PNotes.CloseHotSpot;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.pmiGridGotoNotes(Sender: TObject);
begin
   DoGotoNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectEnter(Sender: TObject);
begin
   tblDissect.Colors.Locked     := clGray;
   tblDissect.Colors.LockedText := clWhite;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectExit(Sender: TObject);
begin
   tblDissect.Colors.Locked     := clBtnFace;
   tblDissect.Colors.LockedText := clBtnShadow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectDblClick(Sender: TObject);
{var
  ColEstimate, RowEstimate : integer;
  MousePos : TPoint;
begin
  //get x,y
   GetCursorPos( MousePos);
   MousePos := tblDissect.ScreenToClient( MousePos);

  //estimate where click happened
  if tblDissect.CalcRowColFromXY(MousePos.x, MousePos.Y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ]
  then
     exit;
end;}
begin
   //
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.LookupChart1Click(Sender: TObject);
begin
   btnChart.Click;
end;

procedure TdlgDissection.LookupPayee1Click(Sender: TObject);
begin
   btnPayee.Click;
end;

procedure TdlgDissection.GotoNextUncoded1Click(Sender: TObject);
begin
   DoGotoNextUnCode;
end;

procedure TdlgDissection.GotoNotes1Click(Sender: TObject);
begin
   DoGotoNotes;
end;

procedure TdlgDissection.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   case WindowState of
      wsNormal: begin
         INI_dsStatus := 1; // Normal
         //save position and size
         INI_dsTop := Top;
         INI_dsLeft := Left;
         INI_dsWidth := Width;
         INI_dsHeight := Height;
      end;
      wsMinimized:
         INI_dsStatus := 2;  {useless: this value is never set by VCL!!}
      wsMaximized:
         INI_dsStatus := 3;
   end;
   // Remember edit status
   MyClient.clFields.clAll_EditMode_DIS := ColumnFmtList.EditMode = emGeneral;
   SaveLayoutForThisAcct;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.mniResetClick(Sender: TObject);
begin
   PNotes.Height := 90;
   PNotes.ResetHotSpot;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.pnlTranDetailsResize(Sender: TObject);
begin
  lbltxECodingNotes.Width := pnlTranDetails.Width - 20;
  lbltxNotes.Width        := pnlTranDetails.Width - 20;
end;

procedure TdlgDissection.popDissectPopup(Sender: TObject);
var pD: pWorkDissect_Rec;
begin
    with tblDissect do begin
      if not ValidDataRow(ActiveRow) then
         Exit;
      if not tblDissect.StopEditingState(True) then
         Exit;

       pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];

       if ClearSuperfundDetails1.Visible then
          ClearSuperfundDetails1.Enabled := pD.dtSuper_Fields_Edited
                                         and (not pTran^.txLocked)
                                         and (pTran^.txDate_Transferred = 0)
   end;
end;

procedure TdlgDissection.popViewPopup(Sender: TObject);
begin
  EditAccountOnly1.checked := ColumnFmtList.EditMode = emRestrict;
  EditAllColumns1.checked := ColumnFmtList.EditMode = emGeneral;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.SetFormPositionFromINI( DefaultWidth, DefaultHeight : integer);
//reads the form position information from the ini settings
//checks to see that the form position is logical if the form window state
//is changed back to normal, from maximised
var
  ResetToDefaultPos : boolean;
begin
  //validate current ini settings for normal position
  ResetToDefaultPos := ( ini_dsTop < 0) or
                       ( ini_dsLeft < 0) or
                       ( ini_dsTop + ini_dsHeight > Screen.DesktopHeight) or
                       ( ini_dsLeft + ini_dsWidth > Screen.DesktopWidth);

  if ResetToDefaultPos then
  begin
    ini_dsWidth    := DefaultWidth;
    ini_dsHeight   := DefaultHeight;

    ini_dsTop      := ( Application.Mainform.Monitor.Height - ini_dsHeight ) div 2;
    ini_dsLeft     := ( Application.Mainform.Monitor.Width - ini_dsWidth) div 2;
  end;

  //Setup Form size status etc from INI settings
  //default of -1 indicates value not present
  if INI_dsStatus <> 0 then
  begin
    Position := poDesigned;

    if INI_dsTop <> -1 then Top := INI_dsTop;
    if INI_dsLeft <> -1 then Left := INI_dsLeft;
    if INI_dsWidth <> -1 then Width := INI_dsWidth;
    if INI_dsHeight <> -1 then Height := INI_dsHeight;
  end;

  case INI_dsStatus of
    {1: WindowState := wsNormal; //this is already the default}
    3: WindowState := wsMaximized;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.HideCustomHint;
var
  R : TRect;
begin
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then begin // Find where the Hint is, so we can redraw the cells beneath it.
         GetWindowRect( FHint.Handle, R );
         R.TopLeft      := tblDissect.ScreenToClient(R.TopLeft);
         R.BottomRight  := tblDissect.ScreenToClient(R.BottomRight);
         FHint.ReleaseHandle;
         HintShowing    := false;
         tblDissect.AllowRedraw := False;
         tblDissect.InvalidateCellsInRect( R );
         tblDissect.AllowRedraw := True;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TdlgDissection.GetCellRect(const RowNum, ColNum: Integer): TRect;
begin
  Result.Top    := tblDissect.Top  + tblDissect.RowOffset[ RowNum ];
  Result.Bottom := tblDissect.Top  + tblDissect.RowOffset[ RowNum ] + tblDissect.Rows[ RowNum ].Height;
  Result.Left   := tblDissect.Left + tblDissect.ColOffset[ ColNum ];
  Result.Right  := tblDissect.Left + tblDissect.ColOffset[ ColNum ] + tblDissect.Columns[ ColNum ].Width;
  Result.TopLeft := ClientToScreen( Result.TopLeft );
  Result.BottomRight := ClientToScreen( Result.BottomRight );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgDissection.ShowCodingHint(const RowNum, ColNum: Integer;
  HintMsg: String);
var
   R : TRect;
begin
   HideCustomHint; // Hide any existing hint
   If INI_ShowCodeHints and ( HintMsg<>'' ) then
   begin
     // Make sure the mouse is on the form
     if PtInRect( tblDissect.BoundsRect, ScreenToClient( Mouse.CursorPos ) ) then
     begin
       R := GetCellRect( RowNum, ColNum );
       NewHints.ShowCustomHint( FHint, R, HintMsg );
       HintShowing := true;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.FormDeactivate(Sender: TObject);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.CMMouseLeave(var Message: TMessage);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.WMVScroll(var Msg: TWMScroll);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectTopLeftCellChanging(Sender: TObject;
  var RowNum, ColNum: Integer);
begin
  HideCustomHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.ClearSuperfundDetails1Click(Sender: TObject);
var pD: pWorkDissect_Rec;
begin
   with tblDissect do begin
      if not ValidDataRow(ActiveRow) then
         Exit;
      if not tblDissect.StopEditingState(True) then
         Exit;

       pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
       if pTran^.txLocked then
          Exit;
       if pTran^.txDate_Transferred <> 0 then
         exit;
       ClearSuperFunddetails(pD);
       AllowRedraw := false;
       try
          InvalidateRow(ActiveRow);
       finally
          AllowRedraw := true;
       end;
   end;
end;

procedure TdlgDissection.CMMouseEnter(var Message: TMessage);
var
  RowNum, ColNum : integer;
begin
  if not tblDissect.Focused then
    exit; 

  if HintShowing then
    exit;

  //see if active row is off screen, if so dont show the hint
  RowNum := tblDissect.ActiveRow;
  if ( RowNum < tblDissect.TopRow) or ( RowNum > ( tblDissect.TopRow + tblDissect.VisibleRows - tblDissect.LockedRows)) then
    Exit;

  //only show the hint if the current cell is not being edited
  if not tblDissect.InEditingState then
  begin
    ColNum := tblDissect.ActiveCol;
    ShowHintForCell( RowNum, ColNum);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.ShowHintForCell( const RowNum, ColNum : integer);
var
  pD : pWorkDissect_Rec;
  FieldID : integer;
  CustomHint : string;
begin
  if not ValidDataRow(RowNum) then
     exit;

  //show hints, only long hints appear
  pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
  FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

  CustomHint := '';
  if Assigned( pD) then begin
     pD.dtDate := PTran.txDate_Effective;
     case FieldID of
        ceAccount : CustomHint := GetDissectionHint( pD, INI_ShowCodeHints );
        ceAmount : if sBtnSuper.Visible then
            CustomHint := GetSuperHint( pD, INI_ShowCodeHints );
        cePayee : CustomHint := GetPayeeHint( pD^.dtPayee_Number, INI_ShowCodeHints);
        ceJob : CustomHint := GetJobHint( pD^.dtJob, INI_ShowCodeHints);
     end;
  end;

  if CustomHint <> '' then
      ShowCodingHint( RowNum, ColNum, CustomHint );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.DoCopyNotesToNarration( Append : boolean);
var
  pD : pWorkDissect_Rec;
  NewNarration : string;
begin
  with tblDissect do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not tblDissect.StopEditingState(True) then Exit;

    pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
    if pTran^.txLocked then
      exit;
    if pTran^.txDate_Transferred <> 0 then
      exit;

    if Append then
      NewNarration := pD^.dtNarration + ' : ' + pD^.dtNotes
    else
      NewNarration := pD^.dtNotes;

    //strip OD OA characters
    NewNarration := StripReturnCharsFromString( Trim(NewNarration), ' ');

    pD^.dtNarration := Copy( NewNarration, 1, MaxNarrationEditLength);

    //force repaint of row
    AllowRedraw := false;
    try
       InvalidateRow(ActiveRow);
    finally
       AllowRedraw := true;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDissection.tblDissectKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Index : Integer;
  pD : pWorkDissect_Rec;
begin
  case Key of

    VK_ESCAPE : if (ColumnFmtList.ColumnDefn_At(tblDissect.ActiveCol)^.cdFieldID
        in [ceJob]) then
             Undo := True;

    VK_END,
    VK_DOWN :
      begin
        if (Shift = [ssCtrl]) then
        begin
          //look thru list from the bottom until a valid line is found
          Index := WorkDissect.Count - 1;
          pD := pWorkDissect_Rec(WorkDissect.Items[ Index ]);
          while (Index > 0) and ((pD^.dtAccount = '') and (pD^.dtAmount = 0)) do
          begin
            Dec(Index);
            pD := pWorkDissect_Rec(WorkDissect.Items[ Index ]);
          end;
          //move the row pointer to the last valid row
          TOvcTable(Sender).ActiveRow := Index + 1;
          Key := 0;
        end;
      end;
  end;
end;

procedure TdlgDissection.celAccountExit(Sender: TObject);
var
  pD : pWorkDissect_Rec;
  FillNarration : boolean;

begin
  if not MyClient.clChart.CodeIsThere(TEdit(celAccount.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask);
  
  if Assigned( AdminSystem) and ( AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number) then
    FillNarration := PRACINI_CopyNarrationDissection
  else
    FillNarration := MyClient.clFields.clCopy_Narration_Dissection;

  if (pTran^.txLocked) then
    Exit;

  if FillNarration then
  begin
    with tblDissect do
    begin
      if not ValidDataRow(ActiveRow) then exit;

      //update the narration column with transaction narration if dissect narr is empty
      pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
      if (pD^.dtNarration = '') then
      begin
        pD^.dtNarration := pTran^.txGL_Narration;
        //force repaint of row
        AllowRedraw := false;
        try
           InvalidateRow(ActiveRow);
        finally
           AllowRedraw := true;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//
// FormResize
//
// Calculates the total width of all the visible columns and stretches the end
// column so that it fills the grid area completely
//
procedure TdlgDissection.FormResize(Sender: TObject);
var
  ColNum, ColWidth, LastColNum : Integer;
begin
  ColWidth := 1; //width of divider between columns
  LastColNum := 0;
  for ColNum := 0 to tblDissect.ColCount - 1 do begin
     if (not tblDissect.Columns.Hidden[ColNum]) then
     begin
       ColWidth := ColWidth + tblDissect.Columns.Width[ColNum];
       LastColNum := ColNum;
     end;
  end;
  if (ColWidth < tblDissect.ClientWidth) then
    tblDissect.Columns.Width[LastColNum] := tblDissect.Columns.Width[LastColNum] +
      (tblDissect.ClientWidth - ColWidth);
  btnOK.Left := Width - 177;
  btnCancel.Left := Width - 96;    
end;

procedure TdlgDissection.FormShow(Sender: TObject);
begin
  //turn Transparency back on because ThemeManager turns it off
  lblStatus.Transparent := False;
end;



procedure TdlgDissection.celLocalAmountKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TdlgDissection.celLocalAmountOwnerDraw(Sender: TObject;
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
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  C.Font.Size   := CellAttr.caFont.Size;

  S := ShortString( Data^ );
  //check is a data row
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect( R, -2, -2 );
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := true;
end;

procedure TdlgDissection.celPayeeKeyDown(Sender: TObject; var Key: Word;
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

// ----------------------------------------------------------------------------

procedure TdlgDissection.celPercentKeyPress(Sender: TObject; var Key: Char);
var
   pD: pWorkDissect_Rec;
begin
  pD := WorkDissect.items[tblDissect.ActiveRow-1];
  if FStartedEdit and ( key in ['%','/'] ) then
  begin
    Key := #0;
    exit;
  end
  else if (key in ['$', '£']) and (not pD.dtAmount_Type_Is_Percent) and (not FStartedEdit) then
  begin
    tblDissect.OnDoneEdit := nil;
    tblDissect.OnEndEdit := nil;
    tblDissect.StopEditingState(False);
    tblDissect.OnDoneEdit := tblDissectDoneEdit;
    tblDissect.OnEndEdit := tblDissectEndEdit;
    Key := #0;
    exit;
  end
  else
    DoCelAmountKeyPress(Sender, Key);
end;

// ----------------------------------------------------------------------------

procedure TdlgDissection.celGSTCodeKeyDown(Sender: TObject; var Key: Word;
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
// Zero amount transactions can be assigned either sign for quantities (+ or -).
// They are not transactions but notes on a financial statement and therefore do not
// fall under the Dr, Cr rules assigned to quantites in BankLink.
//
procedure TdlgDissection.SetQuantitySign(QuantityChanged : Boolean);
var
  pD : pWorkDissect_Rec;
  fQValue : Double;
begin
  pD := WorkDissect.Items[tblDissect.ActiveRow-1];

  //user can have whatever sign they like if the amount is zero
  if pD^.dtAmount = 0 then
    Exit;

  if (QuantityChanged) then
  begin
    //the quantity value was changed
    fQValue := TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat;

    if (pD^.dtAmount > 0) then
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
    fQValue := pD^.dtQuantity;

    if (pD^.dtAmount > 0) then
    begin
      //amount is positive
      if (fQValue < 0) then
        //make the quantity positive
        pD^.dtQuantity := (-fQValue);
    end else
    begin
      //amount is negative
      if (fQValue > 0) then
        //make the quantity negative
        pD^.dtQuantity := (-fQValue);
    end;
  end;
end;

procedure TdlgDissection.celQuantityExit(Sender: TObject);
begin
  SetQuantitySign(True);
end;

procedure TdlgDissection.DoEditSuperFields;
var
  pD : pWorkDissect_Rec;
  Move: TFundNavigation;
  OldAccount: BK5CodeStr;
begin
  if (not FCanUseSuperFundFields) or (not sbtnSuper.Visible) then
    Exit;

  if not ValidDataRow( tblDissect.ActiveRow ) then
     Exit;
  if not tblDissect.StopEditingState(True) then
    Exit;

  //get current dissection line
  pD   := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
  if WorkDissect.Count = tblDissect.ActiveRow then
    Move := fnIsLast
  else if tblDissect.ActiveRow - 1 = 0 then
    Move := fnIsFirst
  else
    Move := fnNothing;

  OldAccount := pD.dtAccount;
  if SuperFieldsUtils.EditSuperFields( pTran, pD, Move, FSuperTop, FSuperLeft, FBankAcct) then
    begin
      if pD.dtAccount <> OldAccount then
        AccountEdited(pD);
      tblDissect.InvalidateRow( tblDissect.ActiveRow);
      tblDissect.Refresh;

      pD^.dtHas_Been_Edited := true;

      if Move = fnGoForward then
      begin
        tblDissect.ActiveRow := tblDissect.ActiveRow + 1;
        DoEditsuperFields;
      end
      else if Move = fnGoBack then
      begin
        tblDissect.ActiveRow := tblDissect.ActiveRow - 1;
        DoEditsuperFields;
      end
      else
      begin
        FSuperTop := -999;
        FSuperLeft := -999;
      end;
    end;
end;

procedure TdlgDissection.celAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
const
  margin = 4;
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pD : pWorkDissect_Rec;
  ShowCommentIndicator : boolean;
begin
  if data = nil then exit;
  DoneIt := True;
  R := CellRect;
  C := TableCanvas;
  c.Brush.Color := CellAttr.caColor;
  C.Font.Color  := CellAttr.caFontColor;
  C.Font.Size   := CellAttr.caFont.Size;

  ShowCommentIndicator := False;
  //get string
  pfHiddenAmount.SetValue( Data^ );

  if FIsForex then
    S := ShortString( Data^ )
  else
    S := PChar( pfHiddenAmount.AsString);

  //check is a data row
  if ValidDataRow( RowNum ) then
  begin
     pD   := WorkDissect.Items[ RowNum -1 ];
     if pD^.dtSuper_Fields_Edited
     and FCanUseSuperFundFields then
        ShowCommentIndicator := True;

  end;
  {paint background}
  C.FillRect(R);
  {draw data}
  InflateRect( R, -2, -2 );
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);

  if ShowCommentIndicator then
    begin
      //draw a red triangle in the top right
      C.Brush.Color := clRed;
      C.Pen.Color := clRed;
      R := CellRect;
      C.Polygon( [Point( R.Right - (Margin+ 1), R.Top),
                        Point( R.Right -1, R.Top),
                        Point( R.Right -1, R.Top + Margin)]);
    end;

  DoneIt := true;
end;

procedure TdlgDissection.sbtnSuperClick(Sender: TObject);
begin
  DoEditSuperFields;
end;

procedure TdlgDissection.EditAccountOnly1Click(Sender: TObject);
begin
  SetColEditMode( emRestrict );
end;

procedure TdlgDissection.EditAllColumns1Click(Sender: TObject);
begin
  SetColEditMode( emGeneral );
end;

procedure TdlgDissection.EditSuperFields1Click(Sender: TObject);
begin
  sBtnSuper.Click;
end;

procedure TdlgDissection.tblDissectMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ColEstimate, RowEstimate : integer;
  R : TRect;
begin
  //estimate where click happened
  if tblDissect.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;

  //see if in account col and has super fund fields
  if FCanUseSuperFundFields and (ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID = ceAmount) then
    begin
      //get row estimate
      if not ValidDataRow(RowEstimate) then
        exit;

      R := GetCellRect( RowEstimate, ColEstimate );
      R.Left := R.Right - 5;
      R.Bottom := R.Top + 5;

      if PtInRect( R, tblDissect.ClientToScreen( Point( x,y))) then
        begin
          DoEditSuperFields;
        end;
    end;
end;


// #1727 - add more shortcuts to the right-click menu

procedure TdlgDissection.LookupGST1Click(Sender: TObject);
begin
  Self.DoGSTLookup;
end;

procedure TdlgDissection.CopyContentoftheCellAbove1Click(Sender: TObject);
begin
  Self.DoDitto;
end;

procedure TdlgDissection.NarrationReplacewithNotes1Click(Sender: TObject);
begin
  Self.DoCopyNotesToNarration(False);
end;

procedure TdlgDissection.NarrationAppendNotes1Click(Sender: TObject);
begin
  Self.DoCopyNotesToNarration(True);
end;

procedure TdlgDissection.AmountGrossupfromGSTAmount1Click(Sender: TObject);
begin
  ApplyAmountShortcut('*');
end;

procedure TdlgDissection.AmountGrossupfromNetAmount1Click(Sender: TObject);
begin
  ApplyAmountShortcut('@');
end;

procedure TdlgDissection.AmountFixedClick(Sender: TObject);
var
   pD: pWorkDissect_Rec;
begin
  pD := WorkDissect.items[tblDissect.ActiveRow-1];
  if pD.dtAmount_Type_Is_Percent then
    ApplyAmountShortcut('$');
end;

procedure TdlgDissection.actConfigureExecute(Sender: TObject);
begin
  ConfigureColumns;
end;

procedure TdlgDissection.actRestoreExecute(Sender: TObject);
var
   i : integer;
begin
   //make sure not editing
   if not tblDissect.StopEditingState(True) then Exit;

   //RestoreColumns
   with tblDissect do begin
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
         end;
         ResetColumns;
         ResetColumns;
      finally
         AllowRedraw := true;
      end;
   end;
end;

procedure TdlgDissection.AmountPercentageClick(
  Sender: TObject);
//var
   //pD: pWorkDissect_Rec;
begin
  //pD := WorkDissect.items[tblDissect.ActiveRow-1];
  //if not pD.dtAmount_Type_Is_Percent then
    ApplyAmountShortcut('%');
end;

procedure TdlgDissection.AmountApplyRemainingAmount1Click(Sender: TObject);
begin
  Self.DoCompleteAmount;
end;

procedure TdlgDissection.ApplyAmountShortcut(Key: Char);
// Applies a shortcut key press to the amount field
// Test if we are in the correct col, if not end any edit and move to
// correct col - *, % and @ only work within amount field. Simulate the key press
// then reset the active col to wherever the user was before
var
  Col: Integer;
  Move: Boolean;
begin
  Col := -1;
  with tblDissect do
  begin
    if (not (ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceAmount)) and
       (not (ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = cePercent)) then
    begin
      Col := ActiveCol;
      if not StopEditingState(True) then Exit;
      ActiveCol := ColumnFmtList.GetColNumOfField(ceAmount);
      Move := False;
    end
    else
      Move := True;
    if not StartEditingState then Exit;

    DoCelAmountKeyPress(tblDissect, Key, Move);
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgDissection.celAccountKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Msg : TWMKey;
  lCode: ShortString;
begin
   if ( Key = VK_BACK ) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask)
  else
    bkMaskUtils.CheckForMaskChar(TEdit(celAccount.CellEditor),RemovingMask);

  //if the current text value of the edit cell is a valid account code
  //then automatically press right arrow
  //if not a valid code test to see if a mask should be added
  //case #5053-moved this from OnChange into here
  lCode := TEdit(celAccount.CellEditor).text;
  if MyClient.clChart.CanPressEnterNow(lCode) then
  begin
     TEdit(celAccount.CellEditor).text := lCode;
     Msg.CharCode := VK_RIGHT;
     celAccount.SendKeyToTable(Msg);
  end;
end;

procedure TdlgDissection.mniNoteMarkClick(Sender: TObject);
begin
  DoMarkNote;
end;

procedure TdlgDissection.mniNoteMarkAllClick(Sender: TObject);
begin
  DoMarkAllNotes;
end;

procedure TdlgDissection.mniNoteDeleteClick(Sender: TObject);
begin
  DoDeleteNote;
end;

procedure TdlgDissection.DoMarkNote;
var
  pD : pWorkDissect_Rec;

  
  Procedure LToggle(Value : boolean);
  Begin // have to check both but Import is more important..
     if pD.dtImportNotes <> '' then
        pD.dtImport_Notes_Read := Value;

     if pD^.dtNotes <> '' then
       pD.dtNotes_Read := Value;
  end;


begin
  with tblDissect do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not StopEditingState(True) then Exit;

    pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
    if pTran.txLocked or (pTran.txDate_Transferred <> 0) then exit;

    if (pD.dtNotes <> '')
    or (pD.dtImportNotes <> '') then
      LToggle ( NOT  (pD.dtImport_Notes_Read or pD.dtNotes_Read));

    //force repaint of row
    AllowRedraw := false;
    try
       InvalidateRow(ActiveRow);
    finally
       AllowRedraw := true;
    end;
  end;
end;

procedure TdlgDissection.DoMarkAllNotes;
var
  pD : pWorkDissect_Rec;
  i: Integer;
begin
  with tblDissect do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not StopEditingState(True) then Exit;

    for i := 0 to Pred(WorkDissect.Count) do
    begin
      pD := WorkDissect.Items[ i ];
      if pTran.txLocked or (pTran.txDate_Transferred <> 0) then Continue;
      pD.dtNotes_Read := pD.dtNotes <> '';
      pD.dtImport_Notes_Read := pD.dtImportNotes <> '';
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

procedure TdlgDissection.DoDeleteNote;
var
  pD : pWorkDissect_Rec;
begin
  with tblDissect do
  begin
    if not ValidDataRow(ActiveRow) then exit;
    if not StopEditingState(True) then Exit;

    pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
    if pTran.txLocked or (pTran.txDate_Transferred <> 0 ) then exit;

    pD.dtNotes := '';
    pD.dtNotes_Read := False;

    //force repaint of row
    AllowRedraw := false;
    try
       InvalidateRow(ActiveRow);
    finally
       AllowRedraw := true;
    end;
  end;
end;

procedure TdlgDissection.Gotonextnote1Click(Sender: TObject);
begin
   DoGotoNextNote;
end;

procedure TdlgDissection.celAmountChange(Sender: TObject);
// See if we should insert a minus for the user
var
   pD : pWorkDissect_Rec;
begin
   if not AllowAddMinus then
      Exit;
   if tblDissect.ActiveRow = 1 then // get sign from mainline for first line only
   begin
     pD := WorkDissect.Items[tblDissect.ActiveRow-1];
     if ( pTran^.txAmount < 0 ) and ( pD^.dtAmount = 0 ) then
        Keybd_Event(vk_subtract,0,0,0);
   end
   else if tblDissect.ActiveRow > 1 then // get sign from previous line
   begin
     pD := WorkDissect.Items[tblDissect.ActiveRow-2];
     if ( pD^.dtAmount < 0 ) then
        Keybd_Event(vk_subtract,0,0,0);
   end;
  AllowAddMinus := False;
end;

procedure TdlgDissection.UpdateBaseAmounts(pD : pWorkDissect_Rec);
var
  i: integer;
  pWorkRec: pWorkDissect_Rec;
  TotalAmt, TotalAmtBase, Remainder, RemainderBase: double;
  TransAmt, TransAmtBase: double;
  DissecAmt, DissecAmtBase: Money;
  Rate: double;
begin
  if FIsForex then begin
    //Calculate base amount for Forex bank accounts
    Rate := pTran.Default_Forex_Rate;
    if (Rate = 0.0) then begin
      //Set all base amounts to 0 if exchange rate = 0
      for i := 0 to Pred( GLCONST.Max_tx_Lines ) do
        pWorkDissect_Rec(WorkDissect.Items[i])^.dtLocal_Amount := 0;
    end else begin
      TotalAmt := 0;
      TotalAmtBase := 0;
      TransAmt := GenUtils.Money2Double( pTran^.txAmount );
      TransAmtBase := GenUtils.Money2Double( pTran^.Local_Amount );
      for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
        pWorkRec := WorkDissect.Items[i];
        pWorkRec^.dtLocal_Amount := 0;
        if pWorkRec^.dtAmount <> 0 then begin
          DissecAmt := pWorkRec^.dtAmount;
          DissecAmtBase :=  Double2Money((Money2Double(DissecAmt) / Rate));
          TotalAmt := TotalAmt + Money2Double(DissecAmt);
          TotalAmtBase := TotalAmtBase + Money2Double(DissecAmtBase);
          //Set dissection base amount
          pWorkRec^.dtLocal_Amount := DissecAmtBase;
          Remainder   := TransAmt - TotalAmt;
          RemainderBase := TransAmtBase - TotalAmtBase;
          if (Remainder = 0)  then
            pWorkRec^.dtLocal_Amount := pWorkRec^.dtLocal_Amount + Double2Money(RemainderBase);
        end;
      end;
    end;
  end else if Assigned(pD) then
    pD^.dtLocal_Amount := pD^.dtAmount;
end;

procedure TdlgDissection.ConfigureColumns;
var
   i              : integer;
   cRec, StickyRec: pColumnDefn;
   CurrentFieldID : integer;
   ColumnConfig   : TColumnConfigInfo;
begin
   //make sure not editing
   if not tblDissect.StopEditingState(True) then Exit;

   with TfrmConfigure.Create(Self) do begin
      try
         ShowTemplates := False;
         ConfigBankAccount := FBankAcct;
         SortColumn := -1;
         CodingScreen := DISSECTION_SCREEN;
         ColumnFormatList := ColumnFmtList;
         NeverEditable := [ceForexRate, ceLocalAmount];
         SetUpColDefaultsets;
         DefaultEditable := DefaultEditableCols;
         AlwaysEditable := AlwaysEditableCols;
         AlwaysVisible := AlwaysVisibleCols;
         //setup appearance for CES
         lblEditModeDesc.Caption := 'Column can be edited';
         //Assign Values to ListBox
         lbColumns.Clear;
         //Build TColumnConfigInfo for the column that can be manipulated in dlg
         StickyRec := nil;
         for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
            cRec := ColumnFmtList.ColumnDefn_At(i);
            if cRec.cdFieldID = ceAmountType then
            begin  // sticky column
              StickyRec := cRec;
              Continue;
            end;
            ColumnConfig := TColumnConfigInfo.Create;
            with ColumnConfig do begin
               //set editable state
               if cRec.cdFieldID in [ ceAmount, ceAccount ] then
                  EditState := esAlwaysEditable
               else if (( cRec.cdFieldID in [ ceGSTAmount]) and ( MyClient.clFields.clCountry = whAustralia )
                                                        and ( MyClient.clFields.clBAS_Calculation_Method = bmFull)) then
                  EditState := esNeverEditable
               else if ( cRec.cdFieldID in [ ceGSTClass]) then
               begin
                 If not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
                   EditState := esNeverEditable;
               end
               else if cRec.cdFieldId in [ceDescription, cePayeeName, ceJobName, ceForexRate, ceAltChartCode ] then
                  EditState := esNeverEditable
               else
               if cRec.cdEditMode[ emGeneral] then
                  EditState := esEditable
               else
                  EditState := esNotEditable;
               //set visible state
               if cRec.cdFieldID in [ ceAmount, ceAccount, ceNarration ] then
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
         lbColumns.ItemIndex := tblDissect.ActiveCol;
         //Show Form
         SaveTempLayout;
         ShowModal;
         //Reorder the columns if OK pressed
         if ModalResult = mrOK then begin
            with tblDissect do begin
               AllowRedraw := false;
               OnColumnsChanged := nil;
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
                  if Assigned(StickyRec) and (cRec.cdFieldID = cePercent) then // add sticky column
                  begin
                    StickyRec.cdHidden := cRec.cdHidden;
                    StickyRec.cdEditMode[emGeneral] := False;
                    StickyRec.cdEditMode[emRestrict] := False;
                    ColumnFmtList.Insert(StickyRec);
                  end;
               end;
               //Rebuild the table
               BuildTableColumns;
               //Reset the active col in case the col was moved
               if ColumnFmtList.FieldIsEditable( CurrentFieldID) then
                  ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID)
               else
                  ActiveCol := ColumnFmtList.GetColNumOfField( ceAccount);
               OnColumnsChanged := tblDissectColumnsChanged;
               AllowRedraw := true;
            end;
         end
         else
         begin
           LoadTempLayout;
           tblDissect.Refresh;
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

procedure TdlgDissection.ConvertAmount1Click(Sender: TObject);
var
  Key: Char;
begin
  //Conver VAT amount to base currency
  Key := '£';
  if tblDissect.StartEditingState then
    celGstAmtKeyPress(tblDissect, Key);
end;

procedure TdlgDissection.SaveLayoutForThisAcct;
var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;

   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);

       BankAcct.baFields.baDIS_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
       BankAcct.baFields.baDIS_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
       BankAcct.baFields.baDIS_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
       if ColDefn^.cdFieldId in DefaultEditableCols then
         BankAcct.baFields.baDIS_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
     end;
end;


procedure TdlgDissection.LoadLayoutForThisAcct;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
   i, PosPercent, PosDesc, PosPN : integer;
   ColDefn : pColumnDefn;
   FirstPercent, FirstDesc, FirstPN: Boolean;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;
   FirstPercent := False;
   FirstDesc := False;
   FirstPN := False;
   PosPercent := 2;
   PosDesc := 1;
   PosPN := 6;
   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
   begin
      ColDefn := ColumnFmtList.ColumnDefn_At(i);
      with ColDefn^, BankAcct.baFields do
      begin
         if (cdFieldId = cePercent) and (baDIS_Column_Width[ cdFieldID] = 0) then // first time
           FirstPercent := True
         else if (cdFieldId = ceDescription) and (baDIS_Column_Width[ cdFieldID] = 0) then // first time
           FirstDesc := True
         else if (cdFieldId = cePayeeName) and (baDIS_Column_Width[ cdFieldID] = 0) then // first time
           FirstPN := True;
         if baDIS_Column_Width[ cdFieldID] <> 0 then
         begin
           cdWidth            := baDIS_Column_Width[ cdFieldID];
           cdRequiredPosition := baDIS_Column_Order[ cdFieldID];
           cdHidden           := baDIS_Column_Is_Hidden[ cdFieldID];
           //set status of columns that are editable by default
           if cdFieldId in DefaultEditableCols then
             cdEditMode[ emGeneral] := not baDIS_Column_Is_Not_Editable[ cdFieldID]
           else
             cdEditMode[ emGeneral] := False;
         end
         else
         begin
           //defaults will be used
           cdWidth            := cdDefWidth;
           cdRequiredPosition := cdDefPosition;
           cdHidden           := cdDefHidden;
           cdEditMode[ emGeneral] := (cdFieldId in DefaultEditableCols);
         end;
         if cdFieldId = ceAmount then
          PosPercent := cdRequiredPosition+1
         else if cdFieldId = ceAccount then
          PosDesc := cdRequiredPosition+1
         else if cdFieldId = cePayee then
          PosPN := cdRequiredPosition+1;
      end; // with
   end; // for
   if FirstPercent then
     for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = cePercent then
        ColDefn.cdRequiredPosition := PosPercent
       else if ColDefn.cdFieldId = ceAmountType then
        ColDefn.cdRequiredPosition := PosPercent+1
       else if ColDefn.cdRequiredPosition >= PosPercent then
       begin
        if FirstDesc and (ColDefn.cdFieldId = ceAccount) then
          PosDesc := PosDesc + 1;
        if FirstPN and (ColDefn.cdFieldId = cePayee) then
          PosPN := PosPN + 1;
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
       end;
     end;
   if FirstDesc then
     for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = ceDescription then
          ColDefn.cdRequiredPosition := PosDesc
       else if ColDefn.cdRequiredPosition >= PosDesc then
       begin
        if FirstPN and (ColDefn.cdFieldId = cePayee) then
          PosPN := PosPN + 1;
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
       end;
     end;
   if FirstPN then
     for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       if ColDefn.cdFieldId = cePayeeName then
        ColDefn.cdRequiredPosition := PosPN
       else if ColDefn.cdRequiredPosition >= PosPN then
        ColDefn.cdRequiredPosition := ColDefn.cdRequiredPosition + 1;
     end;
   //now resort list into correct order
   ColumnFmtList.ReOrder;
   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
   begin
     ColDefn := ColumnFmtList.ColumnDefn_At(i);
     ColDefn.cdRequiredPosition := i;
   end;
end;

procedure TdlgDissection.SetupColDefaultSets;
begin
   DefaultEditableCols := [ceAccount, ceAmount, cePercent, ceQuantity, ceNarration, ceMoneyIn, ceMoneyOut, cePayee, ceJob, ceTaxInvoice];

   if Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
     DefaultEditableCols := DefaultEditableCols + [ceGSTClass];

   if (MyClient.clFields.clCountry in [whNewZealand, whUK] ) or ((MyClient.clFields.clCountry = whAustralia ) and ( MyClient.clFields.clBAS_Calculation_Method <> bmFull)) then
     DefaultEditableCols := DefaultEditableCols + [ceGSTAmount];

   AlwaysEditableCols := [ceAccount, ceAmount];

   AlwaysVisibleCols := [ceAccount, ceAmount, ceNarration];
end;

procedure TdlgDissection.ResetColumns;
var
   i, CurrentFieldID : integer;
   Col: pColumnDefn;
begin
  with tblDissect do
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
    ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID);
    AllowRedraw := true;
  end;
  FormResize(Self);
end;

procedure TdlgDissection.LoadTempLayout;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblDissect do
  begin
    for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       with ColDefn^ do begin
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

procedure TdlgDissection.SaveTempLayout;
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblDissect do
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

function TdlgDissection.CanInsertRowsAfter(Row, NewRows: integer) : boolean;
var
   i : integer;
   pDissectRec : pWorkDissect_Rec;
begin
   result := false;
   if ( Row + NewRows) > ( tblDissect.RowLimit -1) then
      exit
   else begin
      for i := 0 to Pred( NewRows) do begin
         pDissectRec := WorkDissect.Items[ (tblDissect.RowLimit - i) -2];
         if ( pDissectRec^.dtAccount <> '') or ( pDissectRec^.dtAmount <> 0) then begin
            Exit;
         end;
      end;
   end;
   Result := true;
end;

procedure TdlgDissection.DoInsertLine;
var
   LineNo : integer;
   S      : string;
begin
  LineNo := tblDissect.ActiveRow -1;
  //see if there are blank lines at the bottom of the table so can more
  //all subsequent rows down.
  if not CanInsertRowsAfter( LineNo, 1) then begin
     S := 'Cannot insert a new line at this location.';
     HelpfulWarningMsg( S,0);
     exit;
  end;
  //shuffle existing lines down x rows
  InsertRowsAfter( LineNo, 1);
  tblDissect.ActiveRow := LineNo + 1;
  tblDissect.Invalidate;
end;

procedure TdlgDissection.DoJobLookup;
var
   pD               : PWorkDissect_Rec;
   InEditOnEntry    : boolean;
   JobCode          : String;
   Msg              : TWMKey;
   JobNotEditable : Boolean;

begin
   //Check to see if a Job col exists
   JobNotEditable :=  not ColumnFmtList.FieldIsEditable( ceJob);
   if not (JobNotEditable) then begin
      with tblDissect do begin
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
   end else begin  //Edit Account Col Only, or PayeeCol has been hidden
      with tblDissect do begin
         //End edit of Account if any
         if not StopEditingState(True) then
            Exit;
         pD := WorkDissect.Items[ tblDissect.ActiveRow-1 ];
         JobCode := pD^.dtJob;
         if PickJob(JobCode) then begin
            //if get here then have a valid payee from the picklist, so edit
            //the fields in the transaction
            pD^.dtJob := JobCode;
            InvalidateRow(ActiveRow);  //forces repaint of row
            Msg.CharCode := VK_RIGHT;
            celJob.SendKeyToTable(Msg);
         end;
      end;
   end;
end;

end.
