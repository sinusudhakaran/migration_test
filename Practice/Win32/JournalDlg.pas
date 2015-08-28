unit JournalDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:     Journal Entries Dlg

  Written:  Sep 1999
  Authors:  Neil, Andy, Matthew

  Purpose:  Allow the user to Enter Journals, validate before allowing
            user to ok the dlg.

  Notes:    Is a Modal Form, triggered by calling the function JournalEntry.
            Journals are stored in a stored TList Object. The pointers in the
            list point to a TWorkJournal_Rec which is used to store the lines
            of the journal is a structue that is used for editing.
            The WorkJournal list is created in the JournalEntry function call.
            The number of items in the list is MAX_DISSECT_DLG.
            The list is destroyed in the form destroy method

            When editing a cell the following events occur

              OnBeginEdit                         Determine if cell can be edited
              OnGetCellData -> ReadCellForEdit    Provide table with data pointer
              OnEndEdit                           Validate the edited value
              OnGetCellData -> ReadCellForSave    Provide table with data pointer
              OnDoneEdit                          Save back data and update any related fields


            Journal lines are entered as a dissection lines in a transaction.  The
            transaction holds ALL journal lines entered for a particular date, ie
            there should only be one transaction per date.

            All journal types MUST balance before they can be ok'ed.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
   Windows, Graphics, Menus, StdCtrls, Buttons, ExtCtrls, Messages,
   OvcTCCBx, OvcTCPic, OvcTCBEF, OvcTCNum, OvcTCEdt, OvcTCmmn,
   OvcTCell, OvcTCStr, OvcTCHdr, OvcBase, OvcTable,
   Controls, ComCtrls, Classes, Forms, BkConst,
   BAObj32, MoneyDef, BKDefs, Globals, ColFmtListObj, OvcEF, OvcPB, OvcPF,
   WorkRecDefs, RzButton,
   OsFont, ovctcbmp, RzTabs;

type
  TdlgJournal = class(Tform)
    stbJournal: TStatusBar;
    tblJournal: TOvcTable;
    JournalController: TOvcController;
    hdrColumnHeadings: TOvcTCColHead;
    celAccount: TOvcTCString;
    celAmount: TOvcTCNumericField;
    celGstAmt: TOvcTCNumericField;
    celQuantity: TOvcTCNumericField;
    celNarration: TOvcTCString;
    celJnlLineType: TOvcTCComboBox;
    pnlTranDetails: TPanel;
    Label1: TLabel;
    lbJournalType: TLabel;
    btnChart: TSpeedButton;
    lblStatus: TLabel;
    popGST: TPopupMenu;
    mniRecalcGST: TMenuItem;
    celMoneyIn: TOvcTCNumericField;
    celMoneyOut: TOvcTCNumericField;
    celGSTCode: TOvcTCString;
    pfHiddenAmount: TOvcPictureField;
    btnPayee: TSpeedButton;
    celPayee: TOvcTCNumericField;
    imgStatus: TImage;
    Shape1: TShape;
    lblDate: TLabel;
    lblJournalType: TLabel;
    popPrevious: TPopupMenu;
    Previousjournal1: TMenuItem;
    Back1month1: TMenuItem;
    Back2months1: TMenuItem;
    Back3months1: TMenuItem;
    Back6months1: TMenuItem;
    popNext: TPopupMenu;
    Nextjournal1: TMenuItem;
    Forward1month1: TMenuItem;
    Forward2months1: TMenuItem;
    Forward3months1: TMenuItem;
    Forward6months1: TMenuItem;
    Panel2: TPanel;

    sbtnSuper: TSpeedButton;
    popJournal: TPopupMenu;
    LookupChart1: TMenuItem;
    LookupPayee1: TMenuItem;
    EditSuperFields1: TMenuItem;
    Sep1: TMenuItem;
    GotoNextUncoded1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    tbPrevious: TRzToolButton;
    tbNext: TRzToolButton;
    LookupGSTClass1: TMenuItem;
    CopyContentoftheCellAbove1: TMenuItem;
    AmountApplyRemainingAmount1: TMenuItem;
    Sep2: TMenuItem;
    AmountGrossupfromGSTAmount1: TMenuItem;
    AmountGrossupfromNetAmount1: TMenuItem;
    Amount1: TMenuItem;
    Forward5months1: TMenuItem;
    Forward11months1: TMenuItem;
    Back5months1: TMenuItem;
    Back11months1: TMenuItem;
    CelReference: TOvcTCString;
    btnView: TRzToolButton;
    popView: TPopupMenu;
    mniConfigureCols: TMenuItem;
    mniRestoreCols: TMenuItem;
    N3: TMenuItem;
    Configurecoulmns1: TMenuItem;
    Restorecolumndefaultas1: TMenuItem;
    celDescription: TOvcTCString;
    celPayeeName: TOvcTCString;
    Insertanewline1: TMenuItem;
    tmrPayee: TTimer;
    EditCodesOnly1: TMenuItem;
    N4: TMenuItem;
    EditAllColumns1: TMenuItem;
    celJob: TOvcTCString;
    CelJobName: TOvcTCString;
    BtnJob: TSpeedButton;
    LookupJobF51: TMenuItem;
    ClearSuperfundDetails1: TMenuItem;
    pBottom: TPanel;
    lblTotalLabel: TLabel;
    lblTotal: TLabel;
    chkProcessOnExit: TCheckBox;
    cbRepeat: TCheckBox;
    cmbReverseWhen: TComboBox;
    eDateUntil: TOvcPictureField;
    lblTaxSystem: TLabel;
    lblGST: TLabel;
    btnClear: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    BtnCal: TButton;
    CelAltChartCode: TOvcTCString;
    pnlLine: TPanel;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    Shape10: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tblJournalGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblJournalColumnsChanged(Sender: TObject; ColNum1,
      ColNum2: Integer; Action: TOvcTblActions);
    procedure tblJournalGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblJournalActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblJournalUserCommand(Sender: TObject; Command: Word);
    procedure tblJournalEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblJournalDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblJournalEnteringRow(Sender: TObject; RowNum: Integer);
    procedure tblJournalBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure celQuantityChange(Sender: TObject);
    procedure tblJournalActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnChartClick(Sender: TObject);
    procedure celAccountKeyPress(Sender: TObject; var Key: Char);
    procedure celAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure stbJournalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celAccountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtKeyPress(Sender: TObject; var Key: Char);
    procedure mniRecalcGSTClick(Sender: TObject);
    procedure tblJournalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure celGSTCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure celGstAmtChange(Sender: TObject);
    procedure celAmountKeyPress(Sender: TObject; var Key: Char);
    procedure btnPayeeClick(Sender: TObject);
    procedure celJnlLineTypeOwnerDraw(Sender: TObject;
      TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure chkProcessOnExitClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure tblJournalKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbPreviousClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure Back1month1Click(Sender: TObject);
    procedure Back2months1Click(Sender: TObject);
    procedure Back3months1Click(Sender: TObject);
    procedure Back6months1Click(Sender: TObject);
    procedure tbNextClick(Sender: TObject);
    procedure Forward1month1Click(Sender: TObject);
    procedure Forward2months1Click(Sender: TObject);
    procedure Forward3months1Click(Sender: TObject);
    procedure Forward6months1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure celQuantityExit(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormDeactivate(Sender: TObject);
    procedure tblJournalTopLeftCellChanging(Sender: TObject; var RowNum,
      ColNum: Integer);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure WMVScroll(var Msg : TWMScroll); message WM_VSCROLL;
    procedure celAmountOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer;
      var DoneIt: Boolean);
    procedure tblJournalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbtnSuperClick(Sender: TObject);
    procedure LookupChart1Click(Sender: TObject);
    procedure LookupPayee1Click(Sender: TObject);
    procedure EditSuperFields1Click(Sender: TObject);
    procedure GotoNextUncoded1Click(Sender: TObject);
    procedure LookupGSTClass1Click(Sender: TObject);
    procedure CopyContentoftheCellAbove1Click(Sender: TObject);
    procedure AmountApplyRemainingAmount1Click(Sender: TObject);
    procedure AmountGrossupfromGSTAmount1Click(Sender: TObject);
    procedure AmountGrossupfromNetAmount1Click(Sender: TObject);
    procedure Forward5months1Click(Sender: TObject);
    procedure Forward11months1Click(Sender: TObject);
    procedure Back5months1Click(Sender: TObject);
    procedure Back11months1Click(Sender: TObject);
    procedure celAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure celAccountExit(Sender: TObject);
    procedure mniConfigureColsClick(Sender: TObject);
    procedure mniRestoreColsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Insertanewline1Click(Sender: TObject);
    procedure tmrPayeeTimer(Sender: TObject);
    procedure EditCodesOnly1Click(Sender: TObject);
    procedure EditAllColumns1Click(Sender: TObject);
    procedure popViewPopup(Sender: TObject);
    procedure BtnJobClick(Sender: TObject);
    procedure eDateUntilAfterEnter(Sender: TObject);
    procedure eDateUntilKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbRepeatClick(Sender: TObject);
    procedure ClearSuperfundDetails1Click(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure eDateUntilDblClick(Sender: TObject);
    procedure BtnCalClick(Sender: TObject);
  private
    AltLineColor : integer;
    FHint              : tHintWindow;
    FStartedEdit       : boolean;
    FDefAction         : Integer;
    HintShowing        : boolean;
    FCanUseSuperFundFields : boolean;

    Bank_Account        : TBank_Account;

    ColumnFmtList       : TColFmtList;
    WorkJournal         : TList;  //List of Pointers to Entered Journals Data
    pTran               : pTransaction_Rec;
    JournalType         : integer;

    AllowAddMinus       : Boolean;  //Auto Add minus in Amount/Qty. Set true on BeginEdit
    AutoPressMinus      : boolean;
    RemovingMask        : boolean;
    AllowNonZeroBalance : boolean;

    PayeeEditable      : boolean;

    // Coding Table Line Colors
    clStdLineLight      : integer;
    clStdLineDark       : integer;

    //Temporary variables for data pointer to point to, used in GetCellData
    tmpShortStr         : ShortString;
    tmpDouble           : double;
    tmpInteger          : Integer;

    tmpPaintShortStr   : ShortString;
    tmpPaintDouble     : double;
    tmpPaintInteger    : integer;
    tmpPayee,
    PayeeRow           : Integer;
    Undo               : Boolean;

    SetFormSize: Boolean;
    FSuperTop, FSuperLeft: Integer;

    DefaultEditableCols : set of byte;
    Temp_Column_Order             : Array[ 0..32 ] of Byte;
    Temp_Column_Width             : Array[ 0..32 ] of Integer;
    Temp_Column_is_Hidden         : Array[ 0..32 ] of Boolean;
    Temp_Column_Is_Not_Editable   : Array[ 0..32 ] of Boolean;
    FOlddate: Integer;
    // Keep last edited reference
    //LastReference : string;
    procedure InitController;
    procedure SetUpForm;
    procedure BuildTableColumns;
    procedure CalcControlTotals( var Count : Integer; var Total,GST, Remainder : Double ); overload;
    procedure CalcControlTotals( var Count : Integer; var Total,GST, Remainder : Double; const ForStatus : byte); overload;
    procedure SetupColumnFmtList;
    procedure UpdateDisplayTotals;
    procedure ReadCellforEdit(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
    procedure ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
    procedure DoDeleteCell;
    procedure DoAccountLookup;
    procedure DoGSTLookup;
    procedure DoPayeeLookup;
    procedure DoJobLookup;
    procedure UpdateStatusBar;
    procedure AccountEdited(pJ: pWorkJournal_Rec);
    procedure AmountEdited(pJ: pWorkJournal_Rec);
    procedure GSTClassEdited(pJ: pWorkJournal_Rec);
    function  PayeeEdited(pJ : pWorkJournal_Rec; OnRow: Integer) : boolean;
    function  ValidDataRow(RowNum: integer): boolean;
    procedure SetColEditMode(EditMode: TEditMode);
    procedure ToggleColEditMode;
    procedure DoCompleteAmount(Move: Boolean);
    procedure DoDeleteLine;
    procedure DoDitto;
    function  FindUnCoded(const TheCurrentRow: integer): integer;
    procedure RemoveBlanks;
    procedure LoadTypeCombo;
    procedure LoadReverseWhenCombo;
    procedure DoInsertLine;

    procedure SetupHelp;
    procedure DoRecalcGST;
    procedure ShowPopUp(x, y: Integer; PopMenu: TPopUpMenu);
    procedure InsertRowsAfter(Row : integer; NewRows : integer);
    function  CanInsertRowsAfter( Row : integer; NewRows : integer) : boolean;

    function  MapStatusToCmbIndex( Status : integer) : integer;
    function  MapCmbIndexToStatus( Index  : integer) : integer;

    function  GetMonthsToAddFromCombo : integer;
    function  GetWeeksToAddFromCombo : integer;

    function GSTDifferentToDefault(pJ: pWorkJournal_Rec): boolean;
    function OKToPost : Boolean;

    procedure FreeCurrentTransactionIfEmpty;
    function GetEOMDate(Months : Integer) : Integer;
    procedure ShowJournal(Months : Integer);
    procedure ClearJournalLines;
    procedure SetQuantitySign(QuantityChanged : Boolean);

    procedure HideCustomHint;
    procedure ShowCodingHint(const RowNum, ColNum: Integer;
      HintMsg: String);
    procedure ShowHintForCell(const RowNum, ColNum: integer);
    function GetCellRect(const RowNum, ColNum: Integer): TRect;
    procedure DoEditSuperFields;
    procedure DoGotoNextUnCode;
    procedure ApplyAmountShortcut(Key: Char);
    procedure DoCelAmountKeyPress(Sender: TObject; var Key: Char; Move: Boolean = True);
    procedure ConfigureColumns;
    procedure SaveLayoutForThisAcct;
    procedure LoadLayoutForThisAcct;
    procedure SetupColDefaultSets;
    procedure ResetColumns;
    procedure SaveTempLayout;
    procedure LoadTempLayout;
    procedure SetFormPositionFromINI( DefaultWidth, DefaultHeight : integer);
    procedure UpdateGenerateOptionsStatus;
    procedure CopyActionType(pJ : pWorkJournal_Rec);
    procedure RedrawRow(Row: integer = 0);
  public
  end;

  function EditJournalEntry(const BA: TBank_Account; const pT: pTransaction_rec; aJournalType: integer; HelpCtx: integer; defAction: Integer) : boolean;
//******************************************************************************
implementation

uses
   CodingFormConst,
   AccountLookupFrm,
   BK5Except,
   BKHelp,
   BKDSIO,
   MaintainGroupsfrm,
   ClientHomepagefrm,
   CanvasUtils,
   CaUtils,
   clObj32,
   ComboUtils,
   bkBranding,
   bkDateUtils,
   bkMaskUtils,
   bkXPThemes,
   ErrorMoreFrm,
   Finalise32,
   GenUtils,
   glConst,
   GSTCalc32,
   GSTLookupFrm,
   imagesfrm,
   InfoMoreFrm,
   JnlUtils32,
   LogUtil,
   Malloc,
   mxUtils,
   Math,
   NewHints,
   OvcData,
   OvcConst,
   OvcNf,
   OvcTbCls,
   PayeeLookupFrm,
   PayeeObj,
   PayeeRecodeDlg,
   StDate,
   StdHints,
   Software,
   SuperFieldsUtils,
   SysUtils,
   trxList32,
   WarningMoreFrm,
   WinUtils,
   YesNoDlg,
   ConfigColumnsFrm,
   NewReportUtils,
   CountryUtils,
   Files,
   BudgetFrm,
   CodingFrm,
   SuggestedMems,
   MAINFRM;

{$R *.DFM}

const
   //**** ALWAYS ADD NEW COLUMNS ONTO THE END BECAUSE ID IS STORED FOR CONFIG COLUMNS
   ceAccount        = 0;    ceMin = 0;
   ceReference      = 1;
   ceAmount         = 2;
   ceGSTClass       = 3;
   ceGSTAmount      = 4;
   ceQuantity       = 5;
   ceNarration      = 6;
   ceMoneyIn        = 7;                //smartbooks
   ceMoneyOut       = 8;                //smartbooks
   ceJnlLineType    = 9;
   cePayee          = 10;
   ceDescription    = 11;
   cePayeeName      = 12;
   ceJob            = 13;
   ceJobName        = 14;
   ceAltChartCode   = 15;
   ceMax = 15;

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
   tcInsertLine     = ccUserFirst + 11;
   tcEditSuperFields = ccUserFirst + 12;
   tcView           = ccUserFirst + 13;
   tcJobLookup      = ccUserFirst + 14;

   //Status Panel Constants
   PANELMODE     = 0;
   PANELPROGRESS = 1;
   PANELTEXT     = 2;
   PANELREVDATE  = 3;
   UnitName = 'JOURNALDLG';

var
  DebugMe       : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.FormCreate(Sender: TObject);
//Add the bitmap to button Glyph, and apply the caption in the case of
//SmartBooks or BK5

begin
  bkXPThemes.ThemeForm( Self);

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_PAYEE_BMP,btnPayee.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_SUPER_BMP,sbtnSuper.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(18,btnJob.Glyph);
  eDateUntil.Epoch       := BKDATEEPOCH;
  eDateuntil.PictureMask := BKDATEFORMAT;

  bkBranding.StyleOvcTableGrid(tblJournal);
  bkBranding.StyleTableHeading(hdrColumnHeadings);
  bkBranding.StyleAltRowColor(AltLineColor);

{$IFDEF SmartBooks}
  btnChart.Caption := 'Code';
  //turn process off by default
  chkProcessOnExit.Checked := False;
{$ENDIF}
  SetupHelp;
  celNarration.MaxLength := MaxNarrationEditLength;
  celreference.MaxLength := MaxRefLength;
  cmbReverseWhen.Enabled := chkProcessOnExit.Checked;
  cmbReverseWhen.ItemIndex := 0; // next month
  EDateUntil.Enabled := cmbReverseWhen.Enabled;
  BtnCal.Enabled := EDateUntil.Enabled;
  //cmbDuration.ItemIndex := 0; // n/a

  FHint := THintWindow.Create( Self );
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Font <> '') then
     StrToFont(AdminSystem.fdFields.fdCoding_Font,FHint.Canvas.Font)
  else if (not Assigned(AdminSystem)) and (INI_Coding_Font <> '') then
     StrToFont(INI_Coding_Font,FHint.Canvas.Font)
  else begin
     FHint.Canvas.Font.Name := 'Courier';
     FHint.Canvas.Font.Size := 9; //??
  end;
  FStartedEdit := False;
  FSuperTop := -999;
  FSuperLeft := -999;
  with MyClient, clFields do begin
     FCanUseSuperFundFields := Software.CanUseSuperFundFields( clCountry, clAccounting_System_Used);
     //Localise menu items and captions
     lblTaxSystem.Caption := Localise(clCountry, lblTaxSystem.Caption);
     mniRecalcGST.Caption := Localise(clCountry, mniRecalcGST.Caption);
     LookupGSTClass1.Caption := Localise(clCountry, LookupGSTClass1.Caption);
     AmountGrossupfromGSTAmount1.Caption := Localise(clCountry, AmountGrossupfromGSTAmount1.Caption);
  end;
  SetFormSize := False;
  Undo := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.SetupHelp;
begin
   Self.ShowHint    := INI_ShowformHints;
   Self.HelpContext := BKH_Using_the_Enter_Journal_window;

   //Components
   btnChart.Hint   := STDHINTS.ChartLookupHint;
   sbtnSuper.Hint  := STDHINTS.SUPERFIELDSHINT;
   btnPayee.Hint   := STDHINTS.PAYEELOOKUPHINT;
   btnJob.Hint     := 'Lookup the Job list|'+
                      'Lookup the Job list';
   btnView.Hint  :=
                'Change View|'
                +'Configure columns or restore the default column settings';

   chkProcessOnExit.Hint :=
                    'Generate Standing or Reversing Journals in the following month';
end;
//------------------------------------------------------------------------------

procedure TdlgJournal.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblJournal.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.FormDestroy(Sender: TObject);
var
   i : Integer;
begin
   //free hint window
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then FHint.ReleaseHandle;
      FHint.Free;
      FHint := nil;
   end;

   // Free the memory assigned to the work records
   for i := 0 to Pred( WorkJournal.Count ) do
      FreeMem( pWorkJournal_Rec(WorkJournal.Items[ i ]), SizeOf(TWorkJournal_Rec));
   WorkJournal.Free;
   ColumnFmtList.Free;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
      VK_ESCAPE :
         if eDateUntil.Focused then begin
            eDateUntil.AsStDate := FOlddate;
            Key := 0;
         end else if tblJournal.InEditingState then begin
            Undo := True;
            tblJournal.StopEditingState(False);
            Key := 0;
         end else
           // Close;

        // Once you have used the grid it removes the Esc funtionality from the Cancel button
        // To keep that consistancy Close will not be activated here...

    end;
   
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.FormClose(Sender: TObject; var Action: TCloseAction);
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
   MyClient.clFields.clAll_EditMode_Journals[JournalType] := ColumnFmtList.EditMode = emGeneral;
end;

procedure TdlgJournal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   Undo := True;
   if (ModalResult = mrOK) then begin
      with tblJournal do begin
         if InEditingState then
            StopEditingState( True );
      end;
   end;
   CanClose := True;
   SaveLayoutForThisAcct;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.SetupColumnFmtList;
// Setup the table columns
var
   AllowGSTAmtEditing : boolean;
   AllowGSTClassEditing : boolean;
begin
   with ColumnFmtList do begin
      FreeAll;
      InsColDefnRec( 'Account',    ceAccount,    celAccount, CalcAcctColWidth( tblJournal.Canvas, tblJournal.Font, 65), true, true, true, -1 );
      InsColDefnRec( 'A/c Desc',   ceDescription,  celDescription, 150, false, false, false, -1);
      InsColDefnRec( 'Reference',  ceReference,  celreference,    88, true, false, true, -1 );
{$IFDEF SmartBooks}
      InsColDefnRec( 'Money Out',  ceMoneyOut,   celMoneyOut,  105, true, true, true, -1 );
      InsColDefnRec( 'Money In',   ceMoneyIn,    celMoneyIn,   105, true, true, true, -1 );
{$ELSE}
      InsColDefnRec( 'Amount',     ceAmount,     celAmount,    105, true, true, true, -1 );
      InsColDefnRec( 'Payee',      cePayee,      celPayee,      50, true, false, PayeeEditable, -1);
      InsColDefnRec( 'Payee Name', cePayeeName,  celPayeeName, 100, false, false, false, -1);

      InsColDefnRec( 'Job',        ceJob,        celJob,        50, false, false, true, -1);
      InsColDefnRec( 'Job Name',   ceJobName,    celJobName,    100,false, false, False, -1);

      //dont allow GST editing if the account type is opening bal, or year end
      AllowGSTAmtEditing := not (Bank_Account.baFields.baAccount_Type in JournalsWithNoGSTSet);

      AllowGSTClassEditing := Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used );

      //dont allow GST editing is using full BAS method (au only)
      if ( MyClient.clFields.clCountry = whAustralia) then
      begin
        AllowGSTAmtEditing := AllowGSTAmtEditing and ( Myclient.clFields.clBAS_Calculation_Method <> bmFull);
      end;

      case MyClient.clFields.clCountry  of
        whNewZealand :
          Begin
            InsColDefnRec( 'GST',        ceGSTClass,   celGSTCode,    35, true, false, AllowGSTClassEditing, -1, 'GST Class ID' );
            InsColDefnRec( 'GST Amount', ceGSTAmount,  celGstAmt,     95, true, false, AllowGSTAmtEditing, -1 );
          End;
        whAustralia  :
          Begin
            InsColDefnRec( 'GST',        ceGSTClass,   celGSTCode,    35, true, false, AllowGSTClassEditing, -1, 'GST Class ID' );
            InsColDefnRec( 'GST Amount', ceGSTAmount,  celGstAmt,     95, true, false, AllowGSTAmtEditing, -1 );
          End;
        whUK         :
          Begin
            InsColDefnRec( 'VAT',        ceGSTClass,   celGSTCode,    35, true, false, AllowGSTClassEditing, -1, 'VAT Class ID' );
            InsColDefnRec( 'VAT Amount', ceGSTAmount,  celGstAmt,     95, true, false, AllowGSTAmtEditing, -1 );
          End;
      end;
      InsColDefnRec( 'Quantity',   ceQuantity,   celQuantity,   95, true, false, true, -1 );
{$ENDIF}
      if Screen.WorkAreaWidth <= 800 then
         InsColDefnRec( 'Narration',  ceNarration,  celNarration, 105, true, false, true, -1 )
      else
         InsColDefnRec( 'Narration',  ceNarration,  celNarration, 190, true, false, true, -1 );

      InsColDefnRec( 'Action',     ceJnlLineType,celJnlLineType, 90, true, false, true, -1 );

      if HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then begin
         csNames[csByAltChartCode] := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
         InsColDefnRec( csNames[csByAltChartCode]
                        , ceAltChartcode, CelAltChartCode, 80, false, false, false, -1 );

      end;

   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.SetUpForm;
var
   pDissection : pDissection_Rec;
   pJ          : pWorkJournal_Rec;
   i           : Integer;
   Count       : Integer;
   Total, GST, Remain : Double;
   vsbWidth    : integer;  //width of vertical scroll bar
   PrevDate    : integer;
   NextDate    : integer;
   pT          : pTransaction_Rec;
   pTPrevious  : pTransaction_Rec;
   pTNext      : pTransaction_Rec;
   PrevEOMDate, NextEOMDate : integer;
   nd, nm, ny  : integer;

   procedure SetUnLocked(Value : Boolean);
   begin
       //Set control visibility
     lblStatus.Visible    := not Value;
     btnChart.Visible     := Value;
     LookupChart1.Visible := Value;

     btnPayee.Visible     := Value;
     LookupPayee1.Visible := Value;

     btnJob.Visible       := Value;
     LookupJobF51.Visible := Value;

     btnClear.Visible     := Value;
     
     LookupGSTClass1.Visible := Value;
     Sep1.Visible := Value;

     Sep2.Visible := Value;
     Insertanewline1.Visible := Value;
     CopyContentoftheCellAbove1.Visible := Value;
     Amount1.Visible := Value;

   end;

begin
  //determine if payee col can be edited.  Dont allow editing if
  //the payee has been set at the transaction level, should never happen
  //for journals
  PayeeEditable := pTran^.txPayee_Number = 0;

  with pTran^ do begin
     //Fill the combo with states from BKCONST, also create the mapping
     //arrays which allow us to map from a journal line type to a combo index
     LoadTypeCombo;
     //Fill Work Dissect records with real Dissection Record Values
     i := 0;
     pDissection := txFirst_Dissection;
     while pDissection <> nil do begin
        with pDissection^ do begin
           pJ := WorkJournal.Items[i];
           with pJ^ do begin
              dtAccount         := dsAccount;
              dtReference       := dsReference;
              dtAmount          := dsAmount;
              dtDate            := txDate_Effective;
              dtPayee_Number    := dsPayee_Number;
              dtGST_Class       := dsGST_Class;
              dtGST_Amount      := dsGST_Amount;
              dtQuantity        := dsQuantity;
              dtNarration       := dsGL_Narration;
              dtHas_Been_Edited := dsHas_Been_Edited;
              dtGST_Has_Been_Edited := dsGST_Has_Been_Edited;
              dtStatus          := dsJournal_Type;
              dtLinkedJnlDate   := dsLinked_Journal_Date;
              dtJob             := dsJob_Code;

              dtSF_Imputed_Credit      := dsSF_Imputed_Credit;
              dtSF_Tax_Free_Dist       := dsSF_Tax_Free_Dist;
              dtSF_Tax_Exempt_Dist     := dsSF_Tax_Exempt_Dist;
              dtSF_Tax_Deferred_Dist   := dsSF_Tax_Deferred_Dist;
              dtSF_TFN_Credits         := dsSF_TFN_Credits;
              dtSF_Foreign_Income      := dsSF_Foreign_Income;
              dtSF_Foreign_Tax_Credits := dsSF_Foreign_Tax_Credits;
              dtSF_Capital_Gains_Indexed  := dsSF_Capital_Gains_Indexed;
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
              dtSF_Super_Fields_Edited := dsSF_Super_Fields_Edited ;
              dtDocument_Title      := dsDocument_Title;
              dtDocument_Status_Update_Required := dsDocument_Status_Update_Required;
              dtExternal_GUID       := dsExternal_GUID;
           end;
           pDissection := dsNext;
           Inc( i );
        end;
     end;
  end;

  // Set up Orpheus table
  tblJournal.AllowRedraw := false;
  ColumnFmtList := TColFmtList.Create;
  SetupColumnFmtList;
  LoadLayoutForThisAcct;
  BuildTableColumns;
  //InitController;
  //set max gst id length
  celGSTCode.MaxLength := GST_CLASS_CODE_LENGTH;
  celAccount.MaxLength := MaxBK5CodeLen;
  //set up payee col
  if not PayeeEditable then begin
     celPayee.Font.Color := clGrayText;
     celPayee.Access     := otxReadOnly;
     btnPayee.enabled    := false;
  end;

  with tblJournal do begin
     RowLimit := GLCONST.Max_tx_Lines + 1;
     CommandOnEnter := ccRight;
     //These method pointers will fire during BuildTableColumns so nil until now
     //this stops column events occuring during the columns setup
     OnColumnsChanged    := tblJournalColumnsChanged;
     OnActiveCellChanged := tblJournalActiveCellChanged;
     OnActiveCellMoving  := tblJournalActiveCellMoving;
     OnBeginEdit         := tblJournalBeginEdit;
     OnDoneEdit          := tblJournalDoneEdit;
     OnEndEdit           := tblJournalEndEdit;
     OnEnteringRow       := tblJournalEnteringRow;
     OnGetCellData       := tblJournalGetCellData;
     OnGetCellAttributes := tblJournalGetCellAttributes;
     OnUserCommand       := tblJournalUserCommand;
  end;
  if MyClient.clFields.clAll_EditMode_Journals[JournalType] then
    SetColEditMode( emGeneral )
  else
    SetColEditMode( emRestrict );
  //Set form size - set default width to the total of col widths
  // Only do this once, the first time we setup, because after the user
  // has resized the form we shouldnt reset it
  if not SetFormSize then
  begin
    vsbWidth := GetSystemMetrics( SM_CXVSCROLL ); //Get Width Vertical Scroll Bar
    ClientWidth := Min(ColumnFmtList.SumAdjColumnWidth + vsbWidth, Screen.WorkAreaWidth-10);
    SetFormSize := True;
  end;
  //Set color for alternate lines in the table
  clStdLineLight := clWindow;
  clStdLineDark := bkBranding.AlternateCodingLineColor;

  // Control formatting
  // Finalised label and Chart button are mutually exclusive
  lblStatus.Visible  := false;
  lblStatus.Left     := Label1.Left;
  btnChart.Visible   := false;
  with btnPayee do begin
    Left    := btnChart.Left + btnChart.Width + 5;
    Visible := false;
  end;
  with btnJob do begin
    Left    := btnPayee.left + btnPayee.Width + 5;
    Visible := false;
  end;
  with lblStatus do begin
    Left    := btnJob.left + 50;
    Visible := false;
  end;
  with sbtnSuper do
    begin
      Left    := btnJob.Left + btnPayee.Width + 5;
      Visible := false;
    end;
  with btnView do
      Left    := sbtnSuper.Left + btnPayee.Width + 5;

  tblJournal.AllowRedraw := True;
  //Display Transaction Details
  with pTran^ do begin
     lblDate.Caption        := bkDate2Str( txDate_Effective );
     lblJournalType.caption := Localise(MyClient.clFields.clCountry, btNames[JournalType]);

     SetUnLocked(not ( txLocked or (txDate_Transferred <> 0)));

     sBtnSuper.Visible    := FCanUseSuperFundFields
                          and (not ( txLocked or (txDate_Transferred <> 0))); 
     EditSuperFields1.Visible := sBtnSuper.Visible;
     ClearSuperfundDetails1.Visible:= sBtnSuper.Visible;

     if not btnChart.Visible then
     begin
       if sbtnSuper.Visible then
       begin
         sbtnSuper.Left := btnChart.Left;
         btnView.Left := sbtnSuper.Left + sbtnSuper.Width + 5;
       end
       else
        btnView.Left := btnChart.Left;
     end
     else if not sbtnSuper.Visible then
      btnView.Left := sbtnSuper.Left;
      
     if sbtnSuper.Visible then
      lblStatus.Left := lblStatus.Left + sbtnSuper.Width;

     if txLocked then begin
        //see if transferred as well
        if ( txDate_Transferred <> 0) then begin
           imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgTickLock.Picture.Bitmap;
           lblStatus.caption := ' This Journal has been Transferred and Finalised ';
        end
        else begin
           //is only locked
           imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgLock.Picture.Bitmap;
           lblStatus.caption := ' This Journal has been Finalised ';
        end;
     end
     else
     if ( txDate_Transferred <> 0) then begin
        imgStatus.Picture.Bitmap := imagesfrm.AppImages.imgTick.Picture.Bitmap;
        lblStatus.caption := ' This Journal has been Transferred ';
     end
     else
      imgStatus.Picture := nil;
  end;

  AllowNonZeroBalance := false;

  UpdateDisplayTotals;

  //All journals from v5.0.0.25 onwards must balance, this includes Cash journal which
  //did not have to balance originally.  This flag tells us to allow a non zero balance
  //and is used to handle old cash journals which did not balance.  Without this you
  //would never be able to leave a cash journal that did not balance, even though it
  //was entered prior to 5.0.0.25.  If we forced them to balance the journal it would change
  //transaction totals.
{$IFNDEF SmartBooks}
  //added up current lines calculate total and remaining values
  CalcControlTotals( Count, Total, GST, Remain );
  AllowNonZeroBalance :=  ( Remain <> 0) and (Bank_Account.baFields.baAccount_Type = btCashJournals);
{$ENDIF}
  tblJournal.ActiveRow := tblJournal.LockedRows;
  tblJournal.ActiveCol := tblJournal.LockedCols;


  // - - - - - - - - - - - - - - - - - - - - - - -
  //find dates for previous and next journals
  // - - - - - - - - - - - - - - - - - - - - - - -
  PrevEOMDate := GetEOMDate(-1); //end of date for the previous month
  NextEOMDate := GetEOMDate(1); //end of date for the next month
  pTPrevious := nil;
  pTNext := nil;

  if (Assigned(Bank_Account)) then
  begin
    //find the previous transaction
    for i := 0 to Bank_Account.baTransaction_List.ItemCount-1 do
    begin
       pT := Bank_Account.baTransaction_List.Transaction_At( i);

       //search for previous journal
       if (pT^.txDate_Effective < pTran^.txDate_Effective) then
       begin
         //transaction is earlier
         if (Assigned(pTPrevious)) then
         begin
           //check to see if this transation is closer than the previous transaction
           if (pT^.txDate_Effective > pTPrevious^.txDate_Effective) then
             pTPrevious := pT;
         end
         else
           pTPrevious := pT;
       end;

       //search for next journal
       if (pT^.txDate_Effective > pTran^.txDate_Effective) then
       begin
         //transaction is later
         if (Assigned(pTNext)) then
         begin
           //check to see if this transation is closer than the previous transaction
           if (pT^.txDate_Effective < ptNext^.txDate_Effective) then
             pTNext := pT;
         end
         else
           pTNext := pT;
       end;
    end;
  end;

  PrevDate := PrevEOMDate;
  NextDate := NextEOMDate;

  if (Assigned(pTPrevious)) then
  begin
    if (pTPrevious^.txDate_Effective >= PrevEOMDate) then
    begin
      //the date of the next transaction is before the end of the month date
      //check to see if the date difference is 1 month or less
      DateDiff(pTPrevious^.txDate_Effective, pTran^.txDate_Effective, nd, nm, ny);
      if (ny = 0) and (nm <= 1) then
      begin
        PrevDate := pTPrevious^.txDate_Effective;
      end
    end;
  end;

  if (Assigned(pTNext)) then
    begin
      if (pTNext^.txDate_Effective <= NextEOMDate) then
      begin
        //the date of the next transaction is before the end of the month date
        //check to see if the date difference is 1 month or less
        DateDiff(pTran^.txDate_Effective, pTNext^.txDate_Effective, nd, nm, ny);
        if (ny = 0) and (nm <= 1) then
        begin
          NextDate := pTNext^.txDate_Effective;
        end;
      end
    end;

  //set captions for dropdown
  PreviousJournal1.Caption := 'Back   (' + bkDate2Str( PrevDate) + ')';
  NextJournal1.Caption := 'Forward   (' + bkDate2Str( NextDate) + ')';

  tbPrevious.Hint := 'Back to Journal dated ' + bkDate2Str( PrevDate);
  tbNext.Hint := 'Forward to Journal dated ' + bkDate2Str( NextDate);

  UpdateGenerateOptionsStatus;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.BuildTableColumns;
//Build the table columns with the column settings set up in ColumnFmtList
var
   i : integer;
   Col : TOvcTableColumn;
   ColDefn : pColumnDefn;
begin
   with tblJournal do begin
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
procedure TdlgJournal.btnClearClick(Sender: TObject);
begin
   if not tblJournal.StopEditingState(true) then
      exit;
      
   if AskYesNo( 'Delete All Journal Lines',
         'Please confirm you want to delete all Journal lines.',
         DLG_No,
         0) <> DLG_YES then
            Exit;
   ClearJournalLines;
   tblJournal.Invalidate;
   UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.InitController;
const
   KeyMapName = 'Grid';
begin
   with tblJournal.Controller.EntryCommands do begin
     {remove F2 functionallity}
     DeleteCommand(KeyMapName,VK_F2,0,0,0);
     DeleteCommand(KeyMapName,VK_DELETE,0,0,0);
     //DeleteCommand(KeyMapName,VK_ESCAPE,0,0,0);

     {add our commands}
     AddCommand(KeyMapName,VK_F2,0,0,0,tcLookup);
     AddCommand(KeyMapName,VK_F3,0,0,0,tcPayeeLookup);
     AddCommand(KeyMapName,VK_F5,0,0,0,tcJobLookup);
     AddCommand(KeyMapName,VK_F6,0,0,0,ccTableEdit);
     AddCommand(KeyMapName,VK_F7,0,0,0,tcGSTLookup);
     AddCommand(KeyMapName,VK_F8,0,0,0,tcNextUncoded);
     AddCommand(KeyMapName,VK_F11,0,0,0,tcEditSuperFields);

     AddCommand(KeyMapName,VK_MULTIPLY,0,0,0,tcEditAll);
     AddCommand(KeyMapName,56,ss_Shift,0,0,tcEditAll);
     AddCommand(KeyMapName,65,ss_Ctrl,0,0,tcEditAll);         {ctrl+A}
     AddCommand(KeyMapName,69,ss_Ctrl,0,0,tcEditAll);         {ctrl+E}
     AddCommand(KeyMapName,71,ss_Ctrl,0,0,tcNextUncoded);      {ctrl+G}
     AddCommand(KeyMapName,76,ss_Ctrl,0,0,tcLookup);          {ctrl+L}
     AddCommand(KeyMapName,80,ss_Ctrl,0,0,tcPayeeLookup);     {ctrl+P}
     AddCommand(KeyMapName,81,ss_Ctrl,0,0,tcRecalc);          {ctrl+Q}
     AddCommand(KeyMapName,89,ss_Ctrl,0,0,tcDeleteLine);      {ctrl+Y}
     AddCommand(KeyMapName,$2E,ss_Ctrl,0,0,tcDeleteLine);     {ctrl+delete}
     Addcommand(KeyMapName,187,0,0,0,tcComplete);         {'=' to complete amount}
     AddCommand(KeyMapName,VK_ADD,0,0,0,tcDitto);         {+ - NumPad}
     AddCommand(KeyMapName,VK_DELETE,0,0,0,tcDeleteCell);
     AddCommand(KeyMapName,VK_INSERT,ss_Shift,0,0,tcInsertLine);
     AddCommand(KeyMapName,87,ss_Ctrl,0,0,tcView);             {ctrl+W}
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.LoadTypeCombo;
var
   I : integer;
begin
   //load LineType combo from BKCONST values
   celJnlLineType.Items.Clear;
   //Add lines from BKCONST definition
   for i := jtMin to jtMax do begin
      if i in EditableTypesSet then
         celJnlLineType.Items.Add(jtNames[i]);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.ValidDataRow(RowNum : integer): boolean;
// Row 0 is heading row
begin
   Result := ((RowNum > 0) and ( RowNum <= GLCONST.Max_tx_Lines ));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalGetCellAttributes(Sender: TObject;
  RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
   //check that the current cell color is the default color so that
   //dont change color if the cell is highlighted ie. active cell
   if (CellAttr.caColor = tblJournal.Color) then begin
      if Odd(RowNum) then
         CellAttr.caColor := clStdLineLight
      else
         CellAttr.caColor := AltLineColor;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalActiveCellMoving(Sender: TObject;
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

   with tblJournal, ColumnFmtList do begin
      //calculate direction of movement
      if ( ColNum < ActiveCol ) then
         Direction := diLeft
      else if ( ColNum > ActiveCol) then
         Direction := diRight
      else if ( command = ccRight ) then
         Direction := diRight
      else
         Exit;

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
   end; //with tblJournal
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalActiveCellChanged(Sender: TObject;
  RowNum, ColNum: Integer);
var
   HintText : string;
   FieldID : integer;
begin
   HideCustomHint;
   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
   case FieldID of
      ceAccount : begin
         HintText := 'Enter an Account Code   (F2) Lookup Chart';
         ShowHintForCell( RowNum, ColNum);
      end;
      cereference : begin
         HintText := 'Enter a Reference';
         ShowHintForCell( RowNum, ColNum);
      end;
      ceAmount, ceMoneyIn, ceMoneyOut : begin
         HintText := 'Enter an Amount';
         ShowHintForCell( RowNum, ColNum);
      end;
      ceGSTClass : begin
         HintText := Localise(MyClient.clFields.clCountry, 'Enter the GST Code if applicable   (F7) Lookup GST');
      end;
      ceGSTAmount : begin
         HintText := Localise(MyClient.clFields.clCountry, 'Enter the GST Amount if applicable ');
      end;
      ceQuantity : begin
         HintText := 'Enter the Quantity value';
      end;
      ceNarration : begin
         HintText := 'Enter a Narration';
      end;
      cePayee : begin
         ShowHintForCell( RowNum, ColNum);
         HintText := 'Enter a Payee number';
      end;
      ceJnlLineType : begin
         HintText := 'Select an Action for this line|'+
                     'Select an Action for this line  [N = Normal  R=Reversing  S=Standing]';
      end;
      ceJob : begin
         ShowHintForCell(RowNum, ColNum);
         HintText := 'Enter the Job Code this Line should be allocated to';
      end;

   end;
   tblJournal.Hint := HintText;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalColumnsChanged(Sender: TObject; ColNum1,
  ColNum2: Integer; Action: TOvcTblActions);
var
   pCD1,
   pCD2 : pColumnDefn;
begin
   case Action of
      taSingle : begin
           //update column width in ColumnFmtList
           pCD1 := ColumnFmtList.ColumnDefn_At(ColNum1);
           pCD1^.cdWidth := tblJournal.Columns[ColNum1].Width;
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
procedure TdlgJournal.tblJournalEnteringRow(Sender: TObject; RowNum: Integer);
begin
   UpdateStatusBar;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.UpdateStatusBar;
//Update Status Bar Panels with new values
var
   Code : String;
   pA   : pAccount_Rec;
   pJ   : pWorkJournal_Rec;
   aMsg : string;
begin
   if not ValidDataRow( tblJournal.ActiveRow ) then
      Exit;

   pJ   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
   with stbJournal do begin
      //set process
      Panels[PANELPROGRESS].Text := Format( '%d of %d', [ tblJournal.ActiveRow, GLCONST.Max_tx_Lines ] );
      //set journal date if available
      aMsg := '';
      if pJ^.dtLinkedJnlDate > 0 then
      begin
        case pJ^.dtStatus of
          jtReversed : aMsg := '  Reversal entry ' + bkDate2Str( pJ^.dtLinkedJnlDate);
          jtReversal : aMsg := '  Original entry ' + bkDate2Str( pJ^.dtLinkedJnlDate);

          jtProcessed : aMSg := ' Next entry ' + bkDate2Str( pJ^.dtLinkedJnlDate);
        end;
      end;
      Panels[ PanelRevDate].Text := aMsg;

      // Account Desc
      Code := ( pJ^.dtAccount );
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
procedure TdlgJournal.tblJournalBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
//occurs before ReadCellForEdit
//allows us to decide whether or not a cell is allowed to be edited
var
   FieldID : integer;
   pJ      : pWorkJournal_Rec;
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
   pJ := WorkJournal.items[ RowNum-1];

   //not editing is allowed if the current line has a type of reversed or reversal
   if pJ^.dtStatus in [ jtReversed, jtReversal, jtProcessed] then
      Exit;

   if ( FieldId = ceGSTAmount) and ( MyClient.clFields.clCountry = whAustralia) and
      ( MyClient.clFields.clBAS_Calculation_Method = bmSimplified) then begin
         //this field cannot be edited if we are using the simplified method and
         //the current gst class assigned has a zero percentage rate
         if ( GetGSTClassRate( MyClient, pTran^.txDate_Effective, pJ^.dtGST_Class) = 0) then exit;
   end;
   if ( FieldId = ceJnlLineType) and ( pJ^.dtStatus in [ jtReversed, jtReversal, jtProcessed]) then
      //can't change journal status for automatic types
      Exit;

   AllowAddMinus := True;  //Allow 1 minus to be added per edit (see Qty/Amount Changed Events)
   AllowIt := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
//Occurs before ReadCellForSave
var
   pJ       : pWorkJournal_Rec;
   FieldID  : integer;
   Account  : string;
   GSTClass : byte;
   GSTAmt   : double;
   Payee    : integer;
   IsActive : boolean;
begin
   //verify values
   if not ValidDataRow(RowNum) then exit;

   IsActive := True;
   pJ := WorkJournal.Items[ RowNum-1 ];
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
         if ( pJ^.dtGST_Class =0 ) and (GSTAmt <>0) then begin
            ErrorSound;
            TOvcNumericField( TOvcTCNumericField( Cell ).CellEditor).AsFloat := 0;
            AllowIt := false;
         end
         else begin
                     if (( pJ^.dtAmount < 0 ) and ( Double2Money(GSTAmt) < pJ^.dtAmount )) or
               (( pJ^.dtAmount > 0 ) and ( Double2Money(GSTAmt) > pJ^.dtAmount )) then begin
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
      ceJob: if Undo then begin
            Undo := False;
            TEdit( TOvcTCString(Cell).CellEditor).Text := pj.dtJob;
         end else begin
            Account := Trim( TEdit( TOvcTCString(Cell).CellEditor ).Text );
            if (Account <> '') then begin
               if not assigned(MyClient.clJobs.FindCode(Account)) then begin
                  ErrorSound;
                  AllowIt := false;
               end;
            end;
         end;
   end; //case
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.GSTDifferentToDefault( pJ : pWorkJournal_Rec) : boolean;
//calculate default gst amount and class and see if current values are
//different
var
  DefaultGSTClass :  byte;
  DefaultGSTAmt   : money;
begin
  CalculateGST( myClient, pTran^.txDate_Effective, pJ^.dtAccount, pJ^.dtAmount,
                DefaultGSTClass, DefaultGSTAmt);

  Result := ( pJ^.dtGST_Class <> DefaultGSTClass) or ( pJ^.dtGST_Amount <> DefaultGSTAmt);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change
//Occurs after ReadCellForSave
//Save the current edited field and update and fields affected by this change
//
var
   pJ  : pWorkJournal_Rec;
   FieldID : integer;
   B       : Byte;
   M       : Money;

begin
   FStartedEdit := False;
   if not ValidDataRow(RowNum) then
      exit;

   pJ := WorkJournal.Items[ RowNum-1 ];
   FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

   case FieldID of
      //the following fields affect other fields
      ceAccount: begin
         tmpShortStr := Trim( tmpShortStr);
         if ( pJ^.dtAccount <> tmpShortStr ) then begin
            // Edited flag not set if when coded from Blank
            if ( pJ^.dtAccount <> '' ) then
               pJ^.dtHas_Been_Edited := true
            {else
               checkfornewRef(true)};

            pJ^.dtAccount   := tmpShortStr;
            AccountEdited(pJ);
         end;
      end;

      ceReference: begin
         if (pJ^.dtReference <> tmpShortStr ) then begin
            pJ^.dtHas_Been_Edited := true;
            pJ^.dtReference  := tmpShortStr;
            //LastReference := tmpShortStr;
         end;
      end;

      ceGSTClass : begin
         B := GetGSTClassNo( MyClient, Trim(tmpShortStr));
         if pJ^.dtGST_Class <> B then begin
            pJ^.dtGST_Class    := B;
            GSTClassEdited(pJ);
            //test for diff
            if GSTDifferentToDefault( pJ ) then begin
               pJ^.dtHas_Been_Edited := true;
               pJ^.dtGST_Has_Been_Edited := true;
            end
            else
              pJ^.dtGST_Has_Been_Edited := false;
         end;
      end;

      ceAmount, ceMoneyIn, ceMoneyOut : begin
         M := Double2Money(tmpDouble);
         if FieldID = ceMoneyIn then
            M := -M;
         if ( pJ^.dtAmount <> M ) then begin
            pJ^.dtHas_Been_Edited := true;
         end;
         if pJ.dtAmount <> M then // ESC
         begin
            pJ^.dtAmount := M;
            AmountEdited(pJ);
            UpdateDisplayTotals;
         end;
      end;

      //the following fields do not affect any other fields
      ceGSTAmount : begin
         M := Double2Money(tmpDouble);
         if pJ^.dtGST_Amount <> M then begin
            pJ^.dtGST_Amount   := M;
            if GSTDifferentToDefault( pJ ) then begin
               pJ^.dtHas_Been_Edited := true;
               pJ^.dtGST_Has_Been_Edited := true;
            end
            else
              pJ^.dtGST_Has_Been_Edited := false;
            UpdateDisplayTotals;
         end;
      end;

      ceNarration : begin
        if (pJ^.dtNarration <> tmpShortStr ) then begin
           pJ^.dtHas_Been_Edited := true;
           pJ^.dtNarration    := tmpShortStr;
        end;
      end;

      ceQuantity : begin
         //doesn't set txHas_Been_Edited because not used or affected by AutoCode
         pJ^.dtQuantity    := (tmpDouble * 10000);
      end;

      ceJnlLineType : begin
         pJ^.dtStatus := MapCmbIndexToStatus( tmpInteger);
         UpdateGenerateOptionsStatus;
      end;

      cePayee: begin
         // can't popup a dialog in here - case 7255

      end;

      ceJob : begin
        if (pJ^.dtJob <> tmpShortStr ) then begin
           pJ^.dtHas_Been_Edited := true;
           pJ^.dtJob  := tmpShortStr;
        end;
      end;
   end;

   {CheckForNewRef(pJ^.dtHas_Been_Edited);}
   RedrawRow(RowNum);

   if FieldId = cePayee then
     tmrPayee.Enabled := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.AccountEdited( pJ : pWorkJournal_Rec );
//update other fields that change when account changes
var
  NewClass   : byte;
  NewGST     : money;
  IsActive   : boolean;
begin
  IsActive := True;
  with pJ^ do begin
     if MyClient.clChart.CanCodeTo( dtAccount, IsActive) then begin
        CalculateGST( MyClient, pTran^.txDate_Effective, dtAccount, dtAmount, NewClass, NewGST);
        dtGST_Class  := NewClass;

        if Bank_Account.baFields.baAccount_Type in BKConst.JournalsWithNoGSTSet then begin
          dtGST_Amount := 0;
        end
        else begin
          dtGST_Amount := NewGST;
        end;
        dtGST_Has_Been_Edited := dtGST_Amount <> NewGST;

        CopyActionType(PJ);
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
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

//copy Action Type from previous line if valid and current Action Type is blank
procedure TdlgJournal.CopyActionType(pJ : pWorkJournal_Rec);
var pJPrev : pWorkJournal_Rec;
    FillNarration: Boolean;
begin
  if (pTran^.txLocked) then
     Exit;
  if Pj.dtStatus = -1 then begin // Not Set..
    if fDefAction in EditableTypesSet then
       Pj.dtStatus := fDefAction
    else //default setting is normal
       Pj.dtStatus := jtNormal;


    if Assigned(AdminSystem)
    and (AdminSystem.fdFields.fdMagic_Number = MyClient.clFields.clMagic_Number) then
       FillNarration := PRACINI_CopyNarrationDissection
    else
       FillNarration := MyClient.clFields.clCopy_Narration_Dissection;

    //check to see what value of prev line is
    if (tblJournal.ActiveRow > 1) then begin
       pJPrev := WorkJournal.Items[ tblJournal.ActiveRow-2 ];
       //check that previous line has a valid type
       if pJPrev^.dtStatus in  EditableTypesSet then //override the default with the value of the prev line
          Pj.dtStatus := pJPrev^.dtStatus;
    end;

    if (tblJournal.ActiveRow = 1) // Frist line always
    or FillNarration then begin   // Or Turned on.
       if Pj.dtReference = '' then
         if pTran.txReference > '' then
            Pj.dtReference := pTran.txReference;
       if Pj.dtNarration = '' then
         if pTran.txGL_Narration > '' then
            Pj.dtNarration := pTran.txGL_Narration;
    end;
    UpdateGenerateOptionsStatus;
  end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.AmountEdited( pJ : pWorkJournal_Rec );
//update other fields that change when amount changes
var
  IsActive: boolean;
begin
  IsActive := True;
  with pJ^ do begin
     if MyClient.clChart.CanCodeTo( dtAccount, IsActive) then begin
        //recalculate the gst using the current class.  No need to change the GST has been edited flag
        //because its status will stay the same.
        dtGST_Amount := CalculateGSTForClass( MyClient, pTran^.txDate_Effective, dtAmount, dtGST_Class);

        if Bank_Account.baFields.baAccount_Type in BKConst.JournalsWithNoGSTSet then begin
          dtGST_Has_Been_Edited := dtGST_Amount <> 0;
          dtGST_Amount          := 0;
        end
        else
        begin
          //check gst class if the default otherwise set flag
          if ( not dtGST_Has_Been_Edited) then
            if GSTDifferentToDefault( pJ) then
              dtGST_Has_Been_Edited := true;
        end;
     end
     else begin
        //note: Gst not cleared by an invalid account to allow independant editing of gst
        if ( dtAccount = '' ) then begin
           dtHas_Been_Edited := false;
        end;
     end;
  end;
  SetQuantitySign(False);
  RedrawRow;

  UpdateDisplayTotals;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.GSTClassEdited( pJ: pWorkJournal_Rec );
begin
   with pJ^ do begin
      if dtGST_Class = 0 then
         dtGST_Amount := 0
      else begin
         dtGST_Amount := ( CalculateGSTForClass( MyClient,  pTran^.txDate_Effective, dtAmount, dtGST_Class ) );
         if Bank_Account.baFields.baAccount_Type in BKConst.JournalsWithNoGSTSet then begin
            dtGST_Has_Been_Edited := dtGST_Amount <> 0;
            dtGST_Amount          := 0;
         end;
      end;
   end;
   UpdateDisplayTotals;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalUserCommand(Sender: TObject;
  Command: Word);
var
   ClientP, ScreenP : TPoint;
begin
   case Command of
      tcLookup:
        DoAccountLookup;
      tcGSTLookup:
        DoGSTLookup;
      tcEditAll:
        ToggleColEditMode;
      tcComplete:
        DoCompleteAmount(False);
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
        ShowPopup( tblJournal.width div 3, tblJournal.height div 3, PopGST)
{$ENDIF};
      tcPayeeLookup:
        DoPayeeLookup;
      tcJobLookup:
        DoJobLookup;
      tcInsertLine:
        DoInsertLine;
      tcEditSuperFields:
        DoEditSuperFields;
     tcView          : begin
        ClientP.x := 0;
        ClientP.y := btnView.Height;
        ScreenP   := btnView.ClientToScreen(ClientP);
        popView.Popup(ScreenP.x, ScreenP.y);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.tblJournalGetCellData(Sender: TObject; RowNum,
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
procedure TdlgJournal.ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID : integer;
   pJ: pWorkJournal_Rec;
   pA: pAccount_Rec;
   APayee: TPayee;
begin
   Data := nil;
   if RowNum = 0 then exit;

   pJ := WorkJournal.items[ RowNum-1];
   with pJ^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of


         ceAccount : begin
            tmpPaintShortStr := dtAccount;
            Data := @tmpPaintShortStr;
         end;

         ceDescription,
         ceAltChartcode:
           begin
              pA := MyClient.clChart.FindCode( pJ^.dtAccount );
              if Assigned( pA ) then
                 if FieldID = ceDescription then
                    tmpPaintShortStr := pA.chAccount_Description
                 else
                    tmpPaintShortStr := pA.chAlternative_Code
              else
                 tmpPaintShortStr := '';
             data := @(tmpPaintShortStr);
           end;



         ceReference : begin
            tmpPaintShortStr := dtReference;
            Data := @tmpPaintShortStr;
         end;
         ceAmount : begin
            tmpPaintDouble := Money2Double( dtAmount );
            Data := @tmpPaintDouble;
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
            tmpPaintShortStr := GetGstClassCode( MyClient, dtGST_Class);
            Data := @tmpPaintShortStr;
         end;
         ceGSTAmount : begin
            tmpPaintDouble := Money2Double( dtGst_Amount);
            Data := @tmpPaintDouble;
         end;
         ceQuantity : begin
            tmpPaintDouble := dtQuantity / 10000;
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
             if pJ^.dtPayee_Number <> 0 then
             begin
                APayee := MyClient.clPayee_List.Find_Payee_Number(pJ^.dtPayee_Number);
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
         ceJobName: begin
            if dtJob > '' then
                tmpPaintShortStr := MyClient.clJobs.JobName(dtJob)
            else
                tmpPaintShortStr := '';
            data := @(tmpPaintShortStr);
         end;
         ceNarration : begin
            tmpPaintShortStr := dtNarration;
            Data := @tmpPaintShortStr;
         end;
         ceJnlLineType : begin
            //this is tricky because the range of options to display is different
            //to the num of items in the combo
            tmpPaintInteger := dtStatus;
            Data := @tmpPaintInteger;
         end;

      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.ReadCellforEdit(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID : integer;
   pJ      : pWorkJournal_Rec;
begin
   Data := nil;
   pJ := WorkJournal.Items[ RowNum-1 ];
   with pJ^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of
         ceAccount : begin
            tmpShortStr := Trim(dtAccount);
            Data := @tmpShortStr;
         end;
         ceReference : begin
            tmpShortStr := dtreference;
            Data := @tmpShortStr;
         end;
         ceAmount : begin
            tmpDouble := Money2Double( dtAmount );
            Data := @tmpDouble;
         end;
         ceMoneyIn : begin
            tmpDouble := Money2Double( dtAmount );
            Data := @tmpDouble;
         end;
         ceMoneyOut : begin
            tmpDouble := Money2Double( -dtAmount );
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
            tmppayee := dtPayee_Number;
            Data     := @tmppayee;
            PayeeRow := Rownum;
         end;
         ceJob : begin
            tmpShortStr := dtJob;
            Data := @tmpShortStr;
         end;
         ceQuantity : begin
            tmpDouble := dtQuantity / 10000;
            Data := @tmpDouble;
         end;
         ceNarration : begin
            tmpShortStr := dtNarration;
            Data := @tmpShortStr;
         end;
         ceJnlLineType : begin
            tmpInteger := MapStatusToCmbIndex( dtStatus);
            Data := @tmpInteger;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.ReadCellForSave(RowNum, ColNum: Integer; var Data: Pointer);
var
   FieldID : integer;
   pJ      : pWorkJournal_Rec;
begin
   Data := nil;
   pJ := WorkJournal.Items[ RowNum-1 ];
   with pJ^ do begin
      FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;
      case FieldID of
         ceAccount, ceNarration, ceJob : begin
            Data := @tmpShortStr;
         end;
         ceReference : begin
            Data := @tmpShortStr;
         end;
         ceAmount, ceMoneyIn, ceMoneyOut, ceGSTAmount, ceQuantity : begin
            Data := @tmpDouble;
         end;
         ceGSTClass : begin
            tmpShortStr := Chr( dtGST_Class );
            Data := @tmpShortStr;
         end;
         ceJnlLineType : begin
            Data := @tmpInteger;
         end;
         cePayee : begin
            Data := @tmppayee;
            payeeRow := RowNum;
         end;

      end;
   end;
end;

procedure TdlgJournal.RedrawRow(Row: integer);
begin
   with tblJournal do begin
      if Row = 0 then
         Row := ActiveRow;

      if not ValidDataRow(Row) then
         Exit;

      AllowRedraw := false;
      try
         InvalidateRow(Row);
      finally
         AllowRedraw := true;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.celQuantityChange(Sender: TObject);
var
   pJ : pWorkJournal_Rec;
begin
   pJ := WorkJournal.Items[tblJournal.ActiveRow-1];
   if not AllowAddMinus then
      Exit;
   if ( pJ^.dtAmount < 0 ) and
      ( pJ^.dtQuantity = 0 ) then
      Keybd_Event(vk_subtract,0,0,0);
   AllowAddMinus := False;
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.btnOKClick(Sender: TObject);
begin
  if OKToPost then
  begin
    (*
    FreeCurrentTransactionIfEmpty;
    //clean up account if no transactions
    JnlUtils32.RemoveJnlAccountIfEmpty( MyClient, Bank_Account);
    *)
  end else
    ModalResult := mrNone;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoDeleteCell;
//Pressing Delete key while not in Editing mode should delete the content of the
//current cell.  Note that this routine can't be called while Edit mode is selected
//as key stroke will be processed by the cell
begin
   with tblJournal do begin
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
         if cdTableCell is TOvcTCComboBox then begin
            TComboBox( cdTableCell.CellEditor).ItemIndex := -1;
         end;
      end;
      StopEditingState( True );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoRecalcGST;
var
  i : Integer;
  pJ : pWorkJournal_Rec;
  sMsg : String;
Begin
   if not tblJournal.StopEditingState(True) then Exit;
   if pTran.txLocked then begin
     HelpfulInfoMsg(Localise(MyClient.clFields.clCountry, 'All Entries have been finalised.  You cannot recalculate GST.'),0);
     exit;
   end;
   if pTran.txDate_Transferred <> 0  then begin
     HelpfulInfoMsg('This journal has been transferred to your accouting system.  You cannot recalculate.',0);
     exit;
   end;

   for i := 0 to Pred( WorkJournal.Count) do begin
      pJ := WorkJournal.Items[ i];
      with pJ^ do begin
        if not (dtStatus in [ jtReversed, jtReversal, jtProcessed]) then
        begin
          //only recalculate GST if it is not reversed or processed
          CalculateGST( MyClient, pTran.txDate_Effective, dtAccount, dtAmount, dtGST_Class, dtGST_Amount);
          if Bank_Account.baFields.baAccount_Type in BKConst.JournalsWithNoGSTSet then begin
            dtGST_Has_Been_Edited := dtGST_Amount <> 0;
            dtGST_Amount          := 0;
          end else
            dtGST_Has_Been_Edited := false;
        end;
      end;
   end;
   //force a redraw
   with tblJournal do begin
      AllowRedraw := false;
      InvalidateTable;
      AllowRedraw := true;
   end;
   //Info Msg for user
   sMsg := Localise(MyClient.clFields.clCountry, 'Recalculate GST Completed.');
   HelpfulInfoMsg( sMsg ,0);
   LogUtil.LogMsg(lmInfo,UnitName,sMsg);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.eDateUntilAfterEnter(Sender: TObject);
begin
  FOlddate := eDateUntil.AsStDate;
end;

procedure TdlgJournal.eDateUntilDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;


procedure TdlgJournal.eDateUntilKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.ToggleColEditMode;
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
procedure TdlgJournal.SetColEditMode( EditMode : TEditMode );
//Setup the column Edit Mode and update the indicator on the Status Bar
begin
   tblJournal.ActiveCol := ColumnFmtList.SetColEditMode( EditMode, tblJournal.ActiveCol );
   case ColumnFmtList.EditMode of
      emRestrict :
         stbJournal.Panels[PANELMODE].text := RESTRICTED_MODE_STRING;
      emGeneral  :
         stbJournal.Panels[PANELMODE].text := ALL_MODE_STRING;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.celAccountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
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
  If ( S='' ) or ( S=BKCONST.DISSECT_DESC ) or MyClient.clChart.CanCodeTo( S, IsActive ) then exit;
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
//------------------------------------------------------------------------------

procedure TdlgJournal.celGSTCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//If gst has been edited show amount in blue
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pJ  : pWorkJournal_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow( RowNum ) then begin
     pJ   := WorkJournal.Items[ RowNum -1];
     if not pJ^.dtGST_Has_Been_Edited then
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

//------------------------------------------------------------------------------

procedure TdlgJournal.celGstAmtOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
//paint blue if GST has been edited
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pJ  : pWorkJournal_Rec;
begin
  If ( data = nil ) then exit;
  //if selected dont do anything
  if CellAttr.caColor = clHighlight then exit;
  //check is a data row
  if ValidDataRow( RowNum ) then begin
     pJ   := WorkJournal.Items[ RowNum -1];
     if not pJ^.dtGST_Has_Been_Edited then
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoAccountLookup;
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
   with tblJournal do begin
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
procedure TdlgJournal.DoGSTLookup;
{
Assists the user in entering GST code by allowing selection of GST Codes from
GSt Lookup

The function PickGSTClass(GSTChar) accepts a GST Code.
It returns True if the user selects a GST Class and puts it
in the Var Parameter, if no GST Class is chosen it returns False.

This method can be called from
   Popup Menu,
   F2 key or Ctrl-L if the user is positioned on the GST Class column.

We do not know the position or the Edit State of the Active Cell when
this method is called.  We therefore end any existing edit and move to
the GST Class column.
}
var
  GSTCode       : String;
  InEditOnEntry : boolean;
  Msg           : TWMKey;
  pJ               : pWorkJournal_Rec;
begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   if not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then exit;

   if ( ColumnFmtList.FieldIsEditable( ceGSTClass)) then
   begin
     with tblJournal do begin
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

        GSTCode := trim(TEdit(celGSTCode.CellEditor).text);
        if PickGSTClass(GSTCode, True) then begin
            //if get here then have a valid char from the picklist
            TEdit(celGSTCode.CellEditor).text := GSTCode;
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
   else begin
      with tblJournal do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         //pT   := WorkTranList.Transaction_At(ActiveRow-1);
         pJ   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
         GSTCode := GSTCALC32.GetGSTClassCode( MyClient, pJ^.dtGST_Class);
         if PickGSTClass( GSTCode, True) then begin
            //if get here then have a valid gst class from the picklist, so edit
            //the fields in the transaction
            pJ^.dtGST_Class := GSTCALC32.GetGSTClassNo( MyClient, GSTCode);
            GSTClassEdited( pJ);
            //check if gst edited
            if GSTDifferentToDefault(pJ) then begin
               pJ^.dtHas_Been_Edited     := true;
               pJ^.dtGST_Has_Been_Edited := true;
            end
            else
               pJ^.dtGST_Has_Been_Edited := false;
            //force repaint of row
            RedrawRow;
            Msg.CharCode := VK_RIGHT;
            celGSTCode.SendKeyToTable(Msg);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoCompleteAmount(Move: Boolean);
// Replaces the amount in the current dissection line with the unallocated
// Remainder.
var
   pJ : pWorkJournal_Rec;
   RowAmount : Double;
   Count : Integer;
   Total : Double;
   GST : Double;
   Remainder  : Double;
   GSTAmount  : Money;
begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   pJ   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
   //Must Stop Editing State to ensure that the table cell amount is the same
   //as the record amount so can calc remainder correctly
   if tblJournal.InEditingState and (not tblJournal.StopEditingState(True)) then exit;

   CalcControlTotals( Count, Total, GST, Remainder );
   RowAmount :=  pJ^.dtAmount;
   // Calc the new RowAmount
   RowAmount := RowAmount + (Remainder*100);
   pJ^.dtAmount := RowAmount;
   // Calc the new GST and put in Column
   GSTAmount := CalculateGSTForClass( myClient, pTran^.txDate_Effective, pJ^.dtAmount, pJ^.dtGST_Class);

   //GST amount should be zero if journal does not have GST
   if (Bank_Account.baFields.baAccount_Type in JournalsWithNoGSTSet) and ( GSTAmount <> 0) then
     begin
       GSTAmount                 := 0;
       pJ^.dtGST_Has_Been_Edited := true;
     end;

   pJ^.dtGST_Amount := GSTAmount;

   RedrawRow;

   SetQuantitySign(False);
   RedrawRow;

   UpdateDisplayTotals;
   if Move then
   begin
    // skip to next column
    if tblJournal.ActiveCol + 1 >= tblJournal.Columns.Count then
      tblJournal.ActiveCol := 0
    else
      tblJournal.ActiveCol := tblJournal.ActiveCol + 1;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoDeleteLine;
//Delete the whole line of dissection record by pressing Ctrl+Y
var
   pJ : pWorkJournal_Rec;
   aMsg : string;
begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;
   if tblJournal.InEditingState then  //This should never happen
      Exit;

   // Get the Pointer
   pJ   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];

   if pJ^.dtStatus in [ jtReversed, jtReversal {, jtProcessed}] then begin
      aMsg := '';

      if pJ^.dtLinkedJnlDate > 0 then
      begin
        //a linked date is store to indicate to the user when the reversal happened
        case pJ^.dtStatus of
           jtReversed : aMsg := 'You are about to delete a journal line that has been ' +
                                'reversed. You should also delete ' +
                                'the reversal line in the journal dated ' +
                                bkDate2Str( pJ^.dtLinkedJnlDate) + '.';

           jtReversal : aMsg := 'You are about to delete a journal line that was automatically '+
                                'created. ' +
                                'You should also delete the reversed line in the journal dated ' +
                                bkDate2Str( pJ^.dtLinkedJnlDate) + '.';
        end;
      end
      else
      begin
        //older journals (pre 5.2) did not store the linked journal date
        case pJ^.dtStatus of
           jtReversed : aMsg := 'You are about to delete a journal line that has been ' +
                                'reversed. You should also delete ' +
                                'the reversal line in the following month.';

           jtReversal : aMsg := 'You are about to delete a journal line that was automatically '+
                                'created. ' +
                                'You should also delete the reversed line in the previous month.';
        end;
      end;

      if AskYesNo( 'Delete Journal Line',
                   aMsg + #13#13 + 'Please confirm you want to delete this line.',
                   DLG_No,
                   0) <> DLG_YES then exit;
   end;

   //clear the dissection line
   ClearWorkRecDetails(PJ);

   //Blank the type combo
   pJ^.dtStatus := -1;

   UpdateDisplayTotals;
   RedrawRow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoDitto;
// Pressing the + key repeats the contents of the field in the row above
// provided the field in the current row is blank.
// GST Amount cannot be repeated

var
   pJPrev  : pWorkJournal_Rec;
   Msg     : TWMKey;
   FieldId : integer;
   DittoOK : boolean;
Begin
   // If Parent Locked then no lookup allowed
   if pTran.txLocked then
      Exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   with tblJournal do begin
      if not ValidDataRow(ActiveRow) then exit;
      if not (ActiveRow > 1) then exit; //Must have line above to copy from
      if not StartEditingState then Exit;   //returns true if already in edit state

      pJPrev := WorkJournal.Items[ ActiveRow-2 ];

      DittoOK := false;

      FieldID := ColumnFmtList.ColumnDefn_At( ActiveCol )^.cdFieldID;
      //verify field ok to edit
      case FieldID of
         ceAccount: begin
            if (Trim(TEdit(celAccount.CellEditor).Text) = '') then begin
               TEdit(celAccount.CellEditor).Text := Trim(pJPrev^.dtAccount);
               DittoOK := true;
            end;
         end;

         ceReference: begin
            if (Trim(TEdit(celReference.CellEditor).Text) = '') then begin
               TEdit(celReference.CellEditor).Text := Trim(pJPrev^.dtReference);
               DittoOK := true;
            end;
         end;

         ceAmount : begin
            if (TOvcNumericField(celAmount.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celAmount.CellEditor).AsFloat := Money2Double( pJPrev^.dtAmount );
               AmountEdited(WorkJournal.Items[ ActiveRow-1 ]);
               DittoOK := true;
            end;
         end;

         ceGSTClass : begin
            if ( TEdit(celGSTCode.CellEditor).text = '') then begin
               TEdit(celGSTCode.CellEditor).Text := GetGSTClassCode( MyClient, pJPrev^.dtGST_Class );
               DittoOK := true;
            end;
         end;

         ceQuantity : begin
            if (TOvcNumericField(celQuantity.CellEditor).AsFloat = 0) then begin
               TOvcNumericField(celQuantity.CellEditor).AsFloat := ( pJPrev^.dtQuantity / 10000 );
               DittoOK := true;
            end;
         end;

         ceNarration : begin
            if (Trim(TEdit(celNarration.CellEditor).Text) = '') then begin
               TEdit(celNarration.CellEditor).Text := Trim(pJPrev^.dtNarration);
               DittoOK := true;
            end;
         end;

         cePayee : begin
            if ( TOvcNumericField(celPayee.CellEditor).AsInteger = 0 ) then begin
               TOvcNumericField(celPayee.CellEditor).AsInteger := pJPrev^.dtPayee_Number;
               DittoOK := true;
            end;
         end;
         ceJob : begin
            if (Trim(TEdit(celJob.CellEditor).Text) = '') then begin
               TEdit(celJob.CellEditor).Text := Trim(pJPrev^.dtJob);
               DittoOK := true;
            end;
         end;
         ceJnlLineType : begin
            //no ditto on type line
         end;
      end;

      if DittoOK then begin
         //if field was updated the save the edit and move right
         if not StopEditingState(True) then exit;
         Msg.CharCode := VK_RIGHT;
         celAccount.SendKeyToTable(Msg);
      end
      else begin
         //field not updated, abandon edit and don't move off current cell
         StopEditingState(true); //SaveData = false doesnt seem to work, message posted on turbopower news group
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.RemoveBlanks;
//Sort the Dissection records in the WorkJournal list by checking the Account Code
//and the Amount.  The valid line has Acct Code <> '' or Amount <> 0.  Then move
//all the blanks to the end of the list.

//This is done by spliting the current list into two lists.  Blank and not blank.
//The items in the Blank list can be free'd, the non blank line is then expanded
//so that is has the required number of items.  The new list is then referenced
//by the existing work tran list.
var
   NewJournalList : TList;
   BlankJournalList : TList;
   pJ             : pWorkJournal_Rec;
   i              : integer;
   aMsg           : String;
   NonBlankLines  : integer;
begin
   if pTran.txLocked then
      exit;
   if pTran.txDate_Transferred <> 0 then
      Exit;

   tblJournal.AllowRedraw := false;
   try
      NewJournalList := TList.Create;
      BlankJournalList := TList.Create;
      try
         //look thru list, only add non-blank records into new list
         for i := 0 to Pred( WorkJournal.Count ) do begin
            pJ := pWorkJournal_Rec(WorkJournal.Items[ i ]);
            if ( pJ^.dtAccount <> '') or ( pJ^.dtAmount <> 0) then
               NewJournalList.Add( pJ)
            else
               BlankJournalList.Add( pJ);
         end;

         //empty existing list and free
         for i := 0 to Pred( BlankJournalList.Count ) do begin
            FreeMem( pWorkJournal_Rec(BlankJournalList.Items[ i ]), SizeOf(TWorkJournal_Rec));
         end;

         //point work list to new list
         WorkJournal.Free;
         WorkJournal := NewJournalList;

         NonBlankLines := WorkJournal.Count;

         //pad out new list to correct size
         for i := NonBlankLines to Pred( GLCONST.Max_tx_Lines ) do begin
            GetMem( pJ, SizeOf(TWorkJournal_Rec) );
            ClearWorkrecDetails(PJ);

            WorkJournal.Add( pJ );
            if not Assigned( WorkJournal.Items[i] ) then begin
               aMsg := Format( '%s : Memory Allocation Failed', [ UnitName ] );
               LogUtil.LogMsg( lmError, UnitName, aMsg );
               Raise ENoMemoryLeft.Create( aMsg );
            end;
         end;
      finally
         BlankJournalList.Free;
         //no need to free newDissect list because this is now referenced to by WorkJournal
      end;
   finally
      tblJournal.InvalidateTable;
      tblJournal.AllowRedraw := true;
   end;
   tblJournal.Refresh;
   tblJournal.ActiveRow := 1;  {reposition to top of table first}
   tblJournal.ActiveCol := ceAccount;
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.DoGotoNextUnCode;
//Move the cursor to the next uncoded line from the current position by pressing F8
var
  NextPos : integer;
  SaveRow : integer;
begin
  if tblJournal.InEditingState then exit;

  //Sort the list and remove all the blank lines in between, store current row
  //so that can start from there
  SaveRow := tblJournal.ActiveRow;
  RemoveBlanks;
  tblJournal.ActiveRow := SaveRow;

  NextPos := FindUncoded( tblJournal.ActiveRow );  //ActiveRow?
  if NextPos < 0 then
     HelpfulInfoMsg( 'All lines have been coded', 0)
  else
  begin
    tblJournal.ActiveRow := NextPos;
    tblJournal.ActiveCol := ColumnFmtList.GetColNumOfField(ceAccount);
  end;
end;
//------------------------------------------------------------------------------
function TdlgJournal.FindUnCoded(const TheCurrentRow: integer): integer;
// Search Transaction list for Uncoded Entries.
// Search from ( current row + 1 ) back round to current row.
// Return Row Number of Uncoded Entry or -1.
// Note that this routine accepts and returns Grid Row which = FTranList Row + 1

   function DissectLineUncoded(pJ : pWorkJournal_Rec) : boolean;
   var
     Coded    : boolean;
     IsActive : boolean;
   begin
     IsActive := True;
     Coded := MyClient.clChart.CanCodeTo(pJ^.dtAccount, IsActive);
{$IFNDEF SmartBooks}
     //check CA systems GST Range
     if IsCASystems and (not CASystemsGSTOK(pJ^.dtGST_Class)) then coded := false;
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
   pJ           : pWorkJournal_Rec;
begin
   foundUnCoded := false;

   CurrentEntry := TheCurrentRow;
   i := CurrentEntry;
   IncEntry( i );
   Repeat
      pJ := WorkJournal.Items[Pred( i )];
      with pJ^ do begin
         if (dtAccount <> '') or (dtAmount <> 0) then begin //valid line
           if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
             foundUnCoded := DissectLineUncoded(pJ)
           else
             foundUnCoded := (pJ^.dtAccount = '');
           if FoundUnCoded then begin
             Result := i;
             Exit;
           end;
         end;
      end;
      IncEntry( i );
   Until ( i = CurrentEntry );

   //have checked all other lines now check current line, if it is valid
   pJ := WorkJournal.Items[Pred( CurrentEntry )];
   if (pJ^.dtAccount <> '') or (pJ^.dtAmount <> 0) then begin //valid line
      if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
           foundUnCoded := DissectLineUncoded(pJ)
         else
           foundUnCoded := (pJ^.dtAccount = '');
   end;

   if FoundUnCoded then
      Result := i
   else
      result := -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.celAccountKeyPress(Sender: TObject;
  var Key: Char);
var
  Msg : TWMKey;
begin
   //ignore * press if editing
   if key = '*' then key := #0;

   if key = '-' then begin
      if ( MyClient.clFields.clUse_Minus_As_Lookup_Key ) then begin
         key := #0;
         Msg.CharCode := VK_F2;
         // #1782 - take it out of edit if we are using '-' as a lookup key
         if tblJournal.InEditingState and
            ((celAccount.CellEditor <> nil) and (TEdit(celAccount.CellEditor).SelStart = 0)) then
          tblJournal.StopEditingState(True);
         CelAccount.SendKeyToTable(Msg);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.celAccountKeyDown(Sender: TObject; var Key: Word;
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
procedure TdlgJournal.celGstAmtKeyPress(Sender: TObject; var Key: Char);
var
   Percentage    : Double;
   NewAmount     : Double;
   pD            : pWorkJournal_Rec;
   Msg           : TWMKey;
   InclusiveAmt  : Double;
begin
  if not ValidDataRow( tblJournal.ActiveRow ) then exit;

  {treat value as percentage}
  if key in ['%','/'] then begin
     //stop any further processing of key
     Key := #0;
     Percentage := TOvcNumericField( celGstAmt.CellEditor).AsFloat;
     //check that the percentage value make sense
     if ( Percentage < 0.0 ) or ( Percentage > 100.0) then exit;

     pD           := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
     //find the new GST Amount
     InclusiveAmt := Money2Double( pD^.dtAmount);
        // Gst = Inclusive *      1
        //                    --------
        //                     1
        //              --------------
        //             ((Rate / 100) + 1 )
     NewAmount := InclusiveAmt * ( 1 / ( 1/( Percentage/100) +1));

     TOvcNumericField( celGstAmt.CellEditor).AsFloat := NewAmount;
     if tblJournal.StopEditingState( True ) then begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.CalcControlTotals( var Count : Integer; var Total, GST, Remainder : Double);
//Calculate the total amount in the tblJournalion, number of valid dissections, and the remaining
//amount
var
   i       : integer;
   pJ      : pWorkJournal_Rec;
begin
   Count := 0;
   Total := 0;
   GST := 0;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pJ := WorkJournal.Items[i];
      with pJ^ do begin
         if (dtAccount <> '') or (dtAmount <> 0.0) then
            Inc( Count );
         Total := Total + dtAmount;
         GST := GST + dtGST_Amount;
      end;
   end;
   Remainder   := GenUtils.Money2Double( pTran^.txAmount ) - ( Total/100 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.UpdateDisplayTotals;
//Calculate the Total, dissection count, remaining then updates the displays
//with new values
var
   Count : Integer;
   Remain, GST, Total : Double;
begin
   //added up current lines calculate total and remaining values
   CalcControlTotals( Count, Total, GST, Remain );
   lblTotal.Caption  := MyClient.MoneyStr( Total );
   lblGST.Caption  := MyClient.MoneyStr( GST );
   // While we are here...
   btnClear.Enabled := Count > 0;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.btnChartClick(Sender: TObject);
begin
   DoAccountLookup;
end;

procedure TdlgJournal.BtnJobClick(Sender: TObject);
begin
  DoJobLookup;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.stbJournalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (X < stbJournal.Panels[PANELMODE].Width) {and (not EditMode)} then begin
    ToggleColEditMode;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.mniConfigureColsClick(Sender: TObject);
begin
  ConfigureColumns;
end;

procedure TdlgJournal.mniRecalcGSTClick(Sender: TObject);
begin
   DoRecalcGST;
end;
procedure TdlgJournal.mniRestoreColsClick(Sender: TObject);
var
   i : integer;
begin
   //make sure not editing
   if not tblJournal.StopEditingState(True) then Exit;

   //RestoreColumns
   with tblJournal do begin
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
            Begin
              if Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
                ColumnFmtList.ColumnDefn_At( i)^.cdEditMode[ emGeneral] := true
              else
               ColumnFmtList.ColumnDefn_At( i)^.cdEditMode[ emGeneral] := false
            End;
         end;
         ResetColumns;
         ResetColumns;
      finally
         AllowRedraw := true;
      end;
   end;
end;

//------------------------------------------------------------------------------

procedure TdlgJournal.tblJournalMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ColEstimate, RowEstimate : integer;
begin
{$IFNDEF SmartBooks}
  if (Button = mbRight) then
  begin
    //estimate where click happened
    if tblJournal.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then
      exit;
    // Get Column Type from Column
    case ColumnFmtList.ColumnDefn_At( ColEstimate )^.cdFieldID of
      ceGSTClass, ceGSTAmount :
        begin
           if ( RowEstimate = 0 ) then //Show when Right click on heading only
              ShowPopup( x,y,popGST)
           else
           begin
             tblJournal.ActiveRow := RowEstimate;
             ShowPopup( x,y,popJournal)
           end;
        end
      else
      begin
        tblJournal.ActiveRow := RowEstimate;
        ShowPopup( x,y,popJournal);
      end;
    end;
  end;
{$ENDIF}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditJournalEntry(const BA : TBank_Account; const pT : pTransaction_rec; aJournalType: Integer;
                                HelpCtx: Integer; DefAction: Integer ) : boolean;
//Calling function to create the dialog, setup, build columns and populate data into
//the columns.
var
   Journal : TdlgJournal;
   pJ          : pWorkJournal_Rec;
   Msg         : String;
   i           : Integer;
begin
   Result := false;
   if not Assigned( pT ) then
      Exit;

   Journal := TdlgJournal.Create(Application.MainForm);
   with Journal do begin
      try
         BKHelpSetup(Journal, HelpCtx);
         //Store pointer to bank account
         Bank_Account := BA;
         //Store pointer to transaction record
         pTran := pT;
         //Store type of journal
         JournalType := aJournalType;
         fDefAction := DefAction;
         //allocate memory for dissection list records
         WorkJournal := TList.Create;
         for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
            GetMem( pJ, SizeOf(TWorkJournal_Rec) );
            ClearWorkRecDetails(PJ);

            WorkJournal.Add( pJ );
            if not Assigned( WorkJournal.Items[i] ) then begin
               Msg := Format( '%s : Memory Allocation Failed', [ UnitName ] );
               LogUtil.LogMsg( lmError, UnitName, Msg );
               Raise ENoMemoryLeft.Create( Msg );
            end;
         end;

         //Load Reverse When combo with periods that journals can be reversed
         //into.  Note: this combo is also used to set the periods for standing
         //journals
         LoadReverseWhenCombo;
         //set default period from user setting
         ComboUtils.SetComboIndexByIntObject( MyClient.clFields.clJournal_Processing_Period, cmbReverseWhen);
         if cmbReverseWhen.ItemIndex = -1 then
         begin
           //user setting was not found, set a default
           ComboUtils.SetComboIndexByIntObject( BKCONST.jpsNextMonth, cmbReverseWhen);
         end;
         //set default duration from user setting

         {ComboUtils.SetComboIndexByIntObject( MyClient.clMoreFields.mcJournal_Processing_Duration , cmbDuration);
         if cmbDuration.ItemIndex = -1 then
         begin
           //user setting was not found, set a default
           ComboUtils.SetComboIndexByIntObject( BKCONST.jpdNA, cmbDuration);
         end;}

         InitController;
         SetUpForm;
         SetFormPositionFromINI( Width, Height);

         // *******************
         ShowModal;
         // *******************

         FreeCurrentTransactionIfEmpty;
         //JnlUtils32.RemoveJnlAccountIfEmpty( MyClient, Bank_Account);

         RefreshHomepage([HPR_Coding]);
         Result := True;

         //Audit journal edit for UK
         if (MyClient.clFields.clCountry = whUK) then
           SaveClient(false);
      finally
         if ModalResult in [mrOK, mrCancel, mrYes] then
            Free;
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.celGstAmtChange(Sender: TObject);
begin
   //test to see if need to automatically put minus sign
   if AutoPressMinus then
       keybd_event(vk_subtract,0,0,0);
   AutoPressMinus := false;
end;
//------------------------------------------------------------------------------



procedure TdlgJournal.celAmountKeyPress(Sender: TObject; var Key: Char);
begin
  if ((key in ['$', '£']) and (ColumnFmtList.ColumnDefn_At(tblJournal.ActiveCol)^.cdFieldID = ceAmount)) and FStartedEdit then
  begin
    Key := #0;
    exit;
  end
  else if (key in ['$', '£' ]) and (not FStartedEdit) then
  begin
    tblJournal.OnDoneEdit := nil;
    tblJournal.OnEndEdit := nil;
    tblJournal.StopEditingState(False);
    tblJournal.OnDoneEdit := tblJournalDoneEdit;
    tblJournal.OnEndEdit := tblJournalEndEdit;
    Key := #0;
    exit;
  end
  else
    DoCelAmountKeyPress(Sender, Key);
end;

procedure TdlgJournal.DoCelAmountKeyPress(Sender: TObject; var Key: Char; Move: Boolean = True);
var
  GrossUpFactor : double;
  GSTRate : double;
  pJ : pWorkJournal_Rec;
  Msg : TWMKey;
begin
  if ( Key in ['*', '@']) then
  begin
    //use gst rate for class if known, otherwise use default
    pJ := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
    // #740 - if no GST class then skip this
    if pJ^.dtGST_Class <> 0 then
    begin
        GSTRate := GetGSTClassRate( MyClient, pTran^.txDate_Effective, pJ^.dtGST_Class);

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

    if tblJournal.StopEditingState( True ) and Move then
      begin
        Msg.CharCode := VK_RIGHT;
        celAmount.SendKeyToTable(Msg);
      end;
  end
  else if Key in ['0'..'9','-','.'] then
    FStartedEdit := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoPayeeLookup;
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
   pJ               : pWorkJournal_Rec;
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
      with tblJournal do begin
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
             //if get here then have a code which can be posted to from picklist
             TOvcNumericField(celPayee.CellEditor).AsInteger := IntCode;
             InvalidateRow(ActiveRow);
             Msg.CharCode := VK_RIGHT;
             celPayee.SendKeyToTable(Msg);
         end else begin
             if not InEditOnEntry then begin
                StopEditingState( True);  //end edit
             end;
         end;
      end;
   end else begin
      //Edit Account Col Only, or PayeeCol has been hidden
      with tblJournal do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pJ   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
         IntCode := pJ^.dtPayee_Number;
         OldPayeeNo := pJ^.dtPayee_Number;
         if PickPayee(IntCode) then begin
            //if get here then have a valid payee from the picklist, so edit
            //the fields in the transaction
            pJ^.dtPayee_Number := IntCode;
            if not PayeeEdited(pJ, ActiveRow) then
               pJ^.dtPayee_Number := OldPayeeNo;

            InvalidateRow(ActiveRow);  //forces repaint of row
            Msg.CharCode := VK_RIGHT;
            celPayee.SendKeyToTable(Msg);
         end;
      end;
   end;
end;
//------------------------------------------------------------------------------
function TdlgJournal.PayeeEdited(pJ: pWorkJournal_Rec; OnRow: Integer) : boolean;
var
   APayee         : TPayee;
   isPayeeDissected : boolean;
   DissectAmt     : PayeeSplitTotals;  //dynamic array
   DissectPct     : PayeeSplitPercentages;
   i              : integer;
   S              : string;
   RecodeRequired : Boolean;
   lineNo         : integer;
   LinesRequired  : integer;
   pJournalRec    : pWorkJournal_Rec;
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

  if pJ^.dtPayee_Number = 0 then exit;  //don't need to do anything

  if (not Bank_Account.ValidPayeeCode(pj^.dtPayee_Number)) then begin
    Result := False;
    Exit;
  end;

  APayee := MyClient.clPayee_List.Find_Payee_Number(pJ^.dtPayee_Number);
  with pJ^, APayee do begin
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
       if (PayeeLine <> nil) then
       begin
         dtAccount     := PayeeLine.plAccount;
         if ( PayeeLine.plGL_Narration <> '') then
           dtNarration   := PayeeLine.plGL_Narration;

         //set gst
         if ( PayeeLine.plGST_Has_Been_Edited) then begin
            dtGST_Class    := PayeeLine.plGST_Class;
            dtGST_Amount   := CalculateGSTForClass( MyClient, pTran^.txDate_Effective, dtAmount, dtGST_Class);
            dtGST_Has_Been_Edited := true;
         end
         else begin
            CalculateGST( MyClient, pTran^.txDate_Effective, dtAccount, dtAmount, dtGST_Class, dtGST_Amount);
            dtGST_Has_Been_Edited := false;
         end;

         if Bank_Account.baFields.baAccount_Type in Bkconst.JournalsWithNoGSTSet then begin
           dtGST_Has_Been_Edited := dtGST_Amount <> 0;
           dtGST_Amount          := 0;
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

             dtSF_Super_Fields_Edited := True;
         end else begin
            WorkRecDefs.ClearSuperfundDetails(pJ);
         end;

         CopyActionType(pj);
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
        LineNo := OnRow;
        //see if there are blank lines at the bottom of the table so can more
        //all subsequent rows down.
        if not CanInsertRowsAfter( LineNo, LinesRequired) then begin
           S := 'The are not enough empty journal lines to expand this entry.';
           HelpfulWarningMsg( S,0);
           exit;
        end;
        //shuffle existing lines down x rows
        InsertRowsAfter( LineNo, LinesRequired);
        //insert lines
        tblJournal.AllowRedraw := false;
        try
           //split value
           PayeePercentageSplit( dtAmount, aPayee, DissectAmt, DissectPct);

           for i := aPayee.pdLines.First to aPayee.pdLines.Last do
           begin
             PayeeLine := aPayee.pdLines.PayeeLine_At(i);
             pJournalRec := WorkJournal.Items[ LineNo -1];

             pJournalRec^.dtPayee_Number := pdNumber;
             pJournalRec^.dtNarration    := PayeeLine.plGL_Narration;
             pJournalRec^.dtAccount      := PayeeLine.plAccount;
             pJournalRec^.dtAmount       := DissectAmt[ i];
             //dtNarration :=   ...already changed
             if (PayeeLine.plGST_Has_Been_Edited) then begin
                pJournalRec^.dtGST_Class    := PayeeLine.plGST_Class;
                pJournalRec^.dtGST_Amount   := CalculateGSTForClass( MyClient,
                                                                     pTran^.txDate_Effective,
                                                                     pJournalRec^.dtAmount,
                                                                     pJournalRec^.dtGST_Class);
                pJournalRec^.dtGST_Has_Been_Edited := true;
             end
             else begin
                CalculateGST( MyClient,
                              pTran^.txDate_Effective,
                              pJournalRec^.dtAccount,
                              pJournalRec^.dtAmount,
                              pJournalRec^.dtGST_Class,
                              pJournalRec^.dtGST_Amount);
                pJournalRec^.dtGST_Has_Been_Edited := false;
             end;

             if Bank_Account.baFields.baAccount_Type in Bkconst.JournalsWithNoGSTSet then begin
               pJournalRec^.dtGST_Has_Been_Edited := pJournalRec^.dtGST_Amount <> 0;
               pJournalRec^.dtGST_Amount          := 0;
             end;

             if DoSuperFund then begin
                if PayeeLine.plSF_PCFranked <> 0 then begin
                   pJournalRec^.dtSF_Franked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCFranked) * Money2Double(pJournalRec^.dtAmount)/100));
                   pJournalRec^.dtSF_Imputed_Credit := FrankingCredit(pJournalRec^.dtSF_Franked,pTran.txDate_Effective);
                end;
                if PayeeLine.plSF_PCUnFranked <> 0 then begin
                   if (PayeeLine.plSF_PCUnFranked + PayeeLine.plSF_PCFranked) = 1000000 then
                      pJournalRec^.dtSF_UnFranked := Abs(pJournalRec^.dtAmount) - pJournalRec^.dtSF_Franked  // No Rounding Isues
                   else
                       pJournalRec^.dtSF_UnFranked := abs(Double2Money (Percent2Double(PayeeLine.plSF_PCUnFranked) * Money2Double(pJournalRec^.dtAmount)/100));
                end;
                pJournalRec^.dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                pJournalRec^.dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                pJournalRec^.dtSF_Fund_ID              := PayeeLine.plSF_Fund_ID;
                pJournalRec^.dtSF_Fund_Code            := PayeeLine.plSF_Fund_Code;
                pJournalRec^.dtSF_Member_ID            := PayeeLine.plSF_Member_ID;
                pJournalRec^.dtSF_Transaction_type_ID  := PayeeLine.plSF_Trans_ID;
                pJournalRec^.dtSF_Transaction_Type_Code := PayeeLine.plSF_Trans_Code;
                pJournalRec^.dtSF_Member_Account_ID    := PayeeLine.plSF_Member_Account_ID;
                pJournalRec^.dtSF_Member_Account_Code  := PayeeLine.plSF_Member_Account_Code;
                pJournalRec^.dtSF_Member_Component     := PayeeLine.plSF_Member_Component;

                if PayeeLine.plQuantity <> 0 then
                    pJournalRec^.dtQuantity := PayeeLine.plQuantity;

                if PayeeLine.plSF_GDT_Date <> 0 then
                   pJournalRec^.dtSF_CGT_Date := PayeeLine.plSF_GDT_Date;

                pJournalRec^.dtSF_Capital_Gains_Fraction_Half := PayeeLine.plSF_Capital_Gains_Fraction_Half;

                SplitRevenue(pJournalRec^.dtAmount,
                          pJournalRec^.dtSF_Tax_Free_Dist,
                          pJournalRec^.dtSF_Tax_Exempt_Dist,
                          pJournalRec^.dtSF_Tax_Deferred_Dist,
                          pJournalRec^.dtSF_Foreign_Income,
                          pJournalRec^.dtSF_Capital_Gains_Indexed,
                          pJournalRec^.dtSF_Capital_Gains_Disc,
                          pJournalRec^.dtSF_Capital_Gains_Other,
                          pJournalRec^.dtSF_Capital_Gains_Foreign_Disc,
                          pJournalRec^.dtSF_Other_Expenses,
                          pJournalRec^.dtSF_Interest,
                          pJournalRec^.dtSF_Rent,
                          pJournalRec^.dtSF_Special_Income,
                          PayeeLine);

                pJournalRec^.dtSF_Super_Fields_Edited  := True;
             end else begin
                WorkRecDefs.ClearSuperfundDetails(pJournalRec);
             end;

             CopyActionType(pJournalRec);
             //move to next line
             Inc( LineNo);
           end;
        finally
           tblJournal.InvalidateTable;
           tblJournal.AllowRedraw := true;
        end;
     end;
  end;  {with payee^, pJ^}
  UpdateDisplayTotals;
end;
procedure TdlgJournal.popViewPopup(Sender: TObject);
begin
  EditCodesOnly1.checked := ColumnFmtList.EditMode = emRestrict;
  EditAllColumns1.checked := ColumnFmtList.EditMode = emGeneral;
end;

//------------------------------------------------------------------------------

procedure TdlgJournal.btnPayeeClick(Sender: TObject);
begin
   DoPayeeLookup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.CanInsertRowsAfter(Row, NewRows: integer) : boolean;
var
   i : integer;
   pJournalRec : pWorkJournal_Rec;
begin
   result := false;
   if ( Row + NewRows) > ( tblJournal.RowLimit -1) then
      exit
   else begin
      for i := 0 to Pred( NewRows) do begin
         pJournalRec := WorkJournal.Items[ (tblJournal.RowLimit - i) -2];
         if ( pJournalRec^.dtAccount <> '') or ( pJournalRec^.dtAmount <> 0) then begin
            Exit;
         end;
      end;
   end;
   Result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.Insertanewline1Click(Sender: TObject);
begin
  DoInsertLine;
end;

procedure TdlgJournal.InsertRowsAfter(Row, NewRows: integer);
//insert x newrows after the current row num
var
   FromRowNum : integer;
   ToRowNum   : integer;
   pDFrom     : pWorkJournal_Rec;
   pDTo       : pWorkJournal_Rec;
begin
   tblJournal.AllowRedraw := false;
   try
      //move rows down, starting from bottom of list
      ToRowNum := tblJournal.RowLimit - 1;
      FromRowNum := ToRowNum - NewRows;

      while FromRowNum > Row do begin
         pDFrom := WorkJournal.Items[ FromRowNum -1];
         pDTo   := WorkJournal.Items[ ToRowNum -1];
         pdTo^ := pDFrom^;
         //copy fields
         (*
         pDTo^.dtAccount              := pDFrom^.dtAccount;
         pDTo^.dtAmount               := pDFrom^.dtAmount ;
         pDTo^.dtDate                 := Ptran.txDate_Effective;
         pDTo^.dtGST_Class            := pDFrom^.dtGST_Class;
         pDTo^.dtGST_Amount           := pDFrom^.dtGST_Amount;
         pDTo^.dtQuantity             := pDFrom^.dtQuantity;
         pDTo^.dtNarration            := pDFrom^.dtNarration;
         pDTo^.dtReference            := pDFrom^.dtReference;
         pDTo^.dtPayee_Number         := pDFrom^.dtPayee_Number;
         pDTo^.dtHas_Been_Edited      := pDFrom^.dtHas_Been_Edited;
         pDTo^.dtGST_Has_Been_Edited  := pDFrom^.dtGST_Has_Been_Edited;
         pDTo^.dtStatus               := pDFrom^.dtStatus;
         pDTo^.dtLinkedJnlDate        := pdFrom^.dtLinkedJnlDate;
         pDTo^.dtJob                  := pdFrom^.dtJob;

         pDTo.dtSF_Imputed_Credit       := pDFrom.dtSF_Imputed_Credit;
         pDTo.dtSF_Tax_Free_Dist        := pDFrom.dtSF_Tax_Free_Dist;
         pDTo.dtSF_Tax_Exempt_Dist      := pDFrom.dtSF_Tax_Exempt_Dist;
         pDTo.dtSF_Tax_Deferred_Dist    := pDFrom.dtSF_Tax_Deferred_Dist;
         pDTo.dtSF_TFN_Credits          := pDFrom.dtSF_TFN_Credits;
         pDTo.dtSF_Foreign_Income       := pDFrom.dtSF_Foreign_Income;
         pDTo.dtSF_Foreign_Tax_Credits  := pDFrom.dtSF_Foreign_Tax_Credits;
         pDTo.dtSF_Capital_Gains_Indexed        := pDFrom.dtSF_Capital_Gains_Indexed;
         pDTo.dtSF_Capital_Gains_Disc := pDFrom.dtSF_Capital_Gains_Disc;
         pdTo.dtSF_Capital_Gains_Other := pdFrom.dtSF_Capital_Gains_Other;
         pdTo.dtSF_Other_Expenses       := pDFrom.dtSF_Other_Expenses;
         pdTo.dtSF_CGT_Date             := pdFrom.dtSF_CGT_Date;
         pDTo.dtSF_Franked              := pdFrom.dtSF_Franked;
         pDTo.dtSF_Unfranked            := pdFrom.dtSF_Unfranked;
         pDTo.dtSF_Interest            := pDFrom.dtSF_Interest;
         pDTo.dtSF_Capital_Gains_Foreign_Disc := pDFrom.dtSF_Capital_Gains_Foreign_Disc;
         pDTo.dtSF_Rent                := pDFrom.dtSF_Rent;
         pDTo.dtSF_Special_Income      := pDFrom.dtSF_Special_Income;
         pDTo.dtSF_Other_Tax_Credit    := pDFrom.dtSF_Other_Tax_Credit;
         pDTo.dtSF_Non_Resident_Tax    := pDFrom.dtSF_Non_Resident_Tax;
         pDTo.dtSF_Foreign_Capital_Gains_Credit := pDFrom.dtSF_Foreign_Capital_Gains_Credit;
         pDTo.dtSF_Member_ID           := pDFrom.dtSF_Member_ID;
         pDTo.dtSF_Member_Component    := pDFrom.dtSF_Member_Component;
         pDTo.dtSF_Super_Fields_Edited  := pDFrom.dtSF_Super_Fields_Edited;
         pDTo.dtExternal_GUID        := pDFrom.dtExternal_GUID;
         pDTo.dtDocument_Title       := pDFrom.dtDocument_Title;
         pDTo.dtDocument_Status_Update_Required := pDFrom.dtDocument_Status_Update_Required;
         *)
         //blank from rec
         ClearWorkRecdetails(pDFrom);

         Dec( ToRowNum);
         FromRowNum := ToRowNum - NewRows;
      end;
   finally
      tblJournal.AllowRedraw := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.DoInsertLine;
var
   LineNo : integer;
   S      : string;
begin
  if lblStatus.Visible then // Locked...
     Exit;

  LineNo := tblJournal.ActiveRow -1;
  //see if there are blank lines at the bottom of the table so can more
  //all subsequent rows down.
  if not CanInsertRowsAfter( LineNo, 1) then begin
     S := 'Cannot insert a new line at this location.';
     HelpfulWarningMsg( S,0);
     exit;
  end;
  //shuffle existing lines down x rows
  InsertRowsAfter( LineNo, 1);
  tblJournal.ActiveRow := LineNo + 1;
  tblJournal.Invalidate;
end;

procedure TdlgJournal.DoJobLookup;
var
   pJ               : pWorkJournal_Rec;
   InEditOnEntry    : boolean;
   JobCode          : String;
   Msg              : TWMKey;
   JobNotEditable : Boolean;

begin


   //Check to see if a payee col exists
   JobNotEditable :=  not ColumnFmtList.FieldIsEditable( ceJob);

   if not (JobNotEditable) then begin
      with tblJournal do begin
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
      with tblJournal do begin
         //End edit of Account if any
         if not StopEditingState(True) then Exit;
         pJ  := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
         JobCode := pJ^.dtJob;
         if PickJob(JobCode) then begin
            //if get here then have a valid payee from the picklist, so edit
            //the fields in the transaction
            pJ^.dtJob := JobCode;
            InvalidateRow(ActiveRow);  //forces repaint of row
            Msg.CharCode := VK_RIGHT;
            celPayee.SendKeyToTable(Msg);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgJournal.celJnlLineTypeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
// If the code is invalid, show it in red
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  I   : integer;
begin
  If ( data = nil ) then exit;

  i := Integer( Data^);
  if not ( I in [ jtMin..jtMax]) then exit;

  //data in this case is an integer which reflects the status index
  S := ShortString( BKConst.jtNames[ i]);
  R := CellRect;
  C := TableCanvas;
  //paint background
  C.Brush.Color := CellAttr.caColor;
  C.FillRect( R );
  //paint border
  C.Pen.Color := CellAttr.caColor;
  C.Polyline( [ Point( R.Left, R.Bottom-1), Point( R.Right, R.Bottom-1) ]);
  //draw data in color
  if CellAttr.caColor = tblJournal.Colors.Selected then
     C.Font.Color := tblJournal.Colors.SelectedText
  else begin
     if i in [ jtProcessed, jtReversed, jtReversal] then
        C.Font.Color := clGreen
     else if i in [ jtStanding, jtReversing] then
        C.Font.Color := clBlue
     else
        C.Font.Color := CellAttr.caFontColor;
  end;
  InflateRect( R, -2, -2 );
  DrawText(C.Handle, PChar( S ), StrLen( PChar( S ) ), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  DoneIt := True;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.MapCmbIndexToStatus(Index: integer): integer;
//called by DoneEdit, returns the status value from the combo item index
begin
   Assert( (Index >= -1) and ( Index <= 2), 'MapCmbIndexToStatus');

   case Index of
      0 : result := jtNormal;
      1 : result := jtReversing;
      2 : result := jtStanding;
   else
      result := -1;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.MapStatusToCmbIndex(Status: integer): integer;
//called by ReadCellForEdit, returns the combo item index for this status
//should only be called when the status is editable
begin
   Assert( ( Status = -1) or (Status in EditableTypesSet), 'MapStatusToCmbIndex');

   case Status of
      jtNormal    : result := 0;
      jtReversing : result := 1;
      jtStanding  : result := 2;
   else
       result := -1;  //nothing selected yet
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.CalcControlTotals( var Count : Integer;
                                         var Total, GST, Remainder : Double;
                                         const ForStatus : byte);
//Calculate the total amount in the tblJournal, number of valid dissections, and the remaining
//amount
//This version of the procedure only calculates for a particular type
var
   i       : integer;
   pJ      : pWorkJournal_Rec;
begin
   Count := 0;
   Total := 0;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pJ := WorkJournal.Items[i];
      with pJ^ do begin
         if ForStatus = pJ^.dtStatus then begin
            if (dtAccount <> '') or (dtAmount <> 0.0) then
               Inc( Count );
            Total := Total + dtAmount;
            GST := GST + dtGST_Amount;
         end;
      end;
   end;
   Remainder   := GenUtils.Money2Double( pTran^.txAmount ) - ( Total/100 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.chkProcessOnExitClick(Sender: TObject);
begin
  cmbReverseWhen.Enabled := chkProcessOnExit.Checked;
  EDateUntil.Enabled := cmbReverseWhen.Enabled;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgJournal.GetMonthsToAddFromCombo: integer;
begin
  result := 1;

  case ComboUtils.GetComboCurrentIntObject( cmbReverseWhen) of
    jpsNextMonth   : result := 1;   //next month
    jpsTwoMonths   : result := 2;   //2mths
    jpsThreeMonths : result := 3;   //3mths
    jpsFiveMonths  : result := 5;   //5mths
    jpsSixMonths   : result := 6;   //6mths
    jpsElevenMonths: result := 11;  //11mths
    jpsNextYear    : result := 12;  //next year
  end;
end;

function TdlgJournal.GetWeeksToAddFromCombo: integer;
begin
  result := 1;

  case ComboUtils.GetComboCurrentIntObject( cmbReverseWhen) of
    jpsNextWeek    : result := 1;   //next week
    jpsTwoWeeks    : result := 2;   //2wks
    jpsThreeWeeks  : result := 3;   //3wks
    jpsFourWeeks   : result := 4;   //4wks
  end;
end;



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.FormResize(Sender: TObject);
const
   MinSize = 250;
var
   PanelW : integer;
begin
  with stbJournal do begin
    PanelW := stbJournal.Width - Panels[PANELMODE].Width - Panels[PANELPROGRESS].Width - Panels[PANELREVDATE].Width;
    if PanelW < MinSize then
       Panels[PANELTEXT].Width := MinSize
    else
      Panels[PANELTEXT].Width := PanelW;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgJournal.LoadReverseWhenCombo;
var
  i : integer;
begin
  cmbReverseWhen.Clear;
  for i := BKCONST.jpsMin to BKCONST.jpsMax do
  begin
    if (JournalType <> btCashJournals)
    and (i >= jpsWeekly) then begin
       if (JournalType = btAccrualJournals) then  //acrural has Daily
          cmbReverseWhen.Items.AddObject( jpsNames[jpsNextDay], TObject(jpsComboBoxOrder[jpsNextDay]));
       Break; // Only show weekly for cash journals
    end;
    cmbReverseWhen.Items.AddObject( jpsNames[i], TObject( jpsComboBoxOrder[i]));
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgJournal.tblJournalKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Index : Integer;
  pJ : pWorkJournal_Rec;
begin
  case Key of
     VK_ESCAPE :
      if (ColumnFmtList.ColumnDefn_At(tblJournal.ActiveCol)^.cdFieldID in [ceJob]) then begin
         Undo := True;
         Key := 0;
      end;
    VK_END,
    VK_DOWN :
      begin
        if (Shift = [ssCtrl]) then
        begin
          //look thru list from the bottom until a valid line is found
          Index := WorkJournal.Count - 1;
          pJ := pWorkJournal_Rec(WorkJournal.Items[ Index ]);
          while (Index > 0) and ((pJ^.dtAccount = '') and (pJ^.dtAmount = 0)) do
          begin
            Dec(Index);
            pJ := pWorkJournal_Rec(WorkJournal.Items[ Index ]);
          end;
          //move the row pointer to the last valid row
          TOvcTable(Sender).ActiveRow := Index + 1;
          Key := 0;
        end;
      end;
  end;
end;
//------------------------------------------------------------------------------
//Check if the Total Amount in the Dissection table is equal to the Transaction
//Amount.
//
//The form stays open if the journal does not balance to zero
//
function TdlgJournal.OKToPost : Boolean;
var
   Count         : integer;
   Total, GST, Remain : double;
   i, j          : integer;
   pJ, pA, pB    : pWorkJournal_Rec;
   AutoDate, FinalDate : integer;

   HasReversing  : Boolean;
   HasStanding   : Boolean;
   HasLinesToProcess : boolean;
   Period: PeriodType;

   d, m, y       : integer;
   BOM, EOM      : integer;

   NextJnl       : pTransaction_Rec;

   PeriodsToAdd, NumberOfPeriods: integer;

   pDissection : pDissection_Rec;
   HasBlank    : boolean;
   JournalCount : Integer;
   msg: string;
   AuditIDList: TList;
begin
   Result := False;
   //make sure not editing
   if not tblJournal.StopEditingState(true) then
      exit;

   if tmrPayee.Enabled then begin
      tmrPayeeTimer(nil);
      if PayeeRow = -1 then
         Exit;
   end;



   if EDateUntil.Enabled then begin
      // Check the date..
      if EDateUntil.AsStDate <= pTran^.txDate_Effective then begin
         HelpfulErrorMsg('Please select a date, after the date of the Journal.', 0 );
         EDateUntil.SetFocus;
         Result := False;
         Exit;
      end;

      if EDateUntil.AsStDate >  MaxValidDate then begin
         HelpfulErrorMsg('Please enter a valid date.', 0 );
         EDateUntil.SetFocus;
         Result := False;
         Exit;
      end;

   end else
      EDateUntil.AsStDate :=  -1;

   Period := Monthly;
   if chkProcessOnExit.Checked then begin
      if (ComboUtils.GetComboCurrentIntObject(cmbReverseWhen) >= jpsNextDay) then
         Period := Dayly
      else if (ComboUtils.GetComboCurrentIntObject(cmbReverseWhen) >= jpsNextWeek) then
         Period := Weekly
   end;




   //Calculate the total and remaining amounts
   CalcControlTotals( Count, Total, GST, Remain );
   //See note in EditJournal about AllowNonZeroBalance
   if ( Total <> 0) and ( not AllowNonZeroBalance) then begin
      HelpfulErrorMsg( 'The Journal is out of balance by ' + MyClient.MoneyStr( Total ), 0 );
      tblJournal.SetFocus;
      Result := False;
      Exit;
   end;

   //Check to see if any lines are reversing/standing.
   HasReversing := false;
   HasStanding  := false;
   JournalCount := 0;

   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
      pJ := WorkJournal.Items[i];
      with pJ^ do begin
         //only test valid entries. Others will be removed after hitting ok.
         if pJ^.dtStatus = jtReversing then begin
            if (pJ^.dtAccount <> '')
            and (pJ^.dtAmount <> 0) then begin
               HasReversing := true;
            end else if chkProcessOnExit.Checked then begin
               if (pJ^.dtAmount <> 0)
               and (pJ^.dtAccount = '') then begin // Keep the Account Only
                  //
                  HelpfulErrorMsg('All Reversing entries must have an Account and Amount.', 0 );
                  tblJournal.SetFocus;
                  Result := False;
                  tblJournal.ActiveRow :=  i + 1;
                  Exit;
               end;
             end;
         end else if pJ^.dtStatus = jtStanding then begin
            if (pJ^.dtAccount <> '')
            and (pJ^.dtAmount <> 0) then begin
               HasStanding := true;
            end else if chkProcessOnExit.Checked then begin
               if (pJ^.dtAmount <> 0)
               or (pJ^.dtAccount <> '') then begin
                  HelpfulErrorMsg('All Standing entries must have an Account and Amount.', 0 );
                  tblJournal.SetFocus;
                  Result := False;
                  tblJournal.ActiveRow :=  i + 1;
                  Exit;
               end;
            end;
         end;


      end;
   end;

   HasLinesToProcess := HasStanding
                     or HasReversing;

   if HasLinesToProcess
   and (chkProcessOnExit.Checked) then begin
      //If so make sure they will not be created in a finalised period
      if JournalType in [btCashJournals, btAccrualJournals, btGSTJournals] then begin

         case period of
         Weekly: begin
            // Weekly Journals
            PeriodsToAdd := GetWeeksToAddFromCombo;

            if EDateUntil.AsStDate > pTran^.txDate_Effective then
               FinalDate := EDateUntil.AsStDate
            else
               FinalDate := IncDate(pTran^.txDate_Effective, PeriodsToAdd * 7, 0, 0);

            j := PeriodsToAdd;
            AutoDate := IncDate(pTran^.txDate_Effective, j*7, 0, 0);
            while AutoDate <= FinalDate do begin
               Inc(j, PeriodsToAdd);
               StDateToDMY( AutoDate, d, m, y);
               BOM := DMYtoSTDate( 1, m, y, BKDATEEPOCH);
               EOM := DMYtoSTDate( DaysInMonth( m, y, BKDATEEPOCH), m, y, BKDATEEPOCH);

               if (Finalise32.IsLocked(BOM, EOM) in [ltAll, ltSome]) then begin
                  HelpfulErrorMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                   'the week for the new journal (' +
                                   inttostr(d) + inttostr(m) + '/' + inttostr(y) +
                                   ') contains Finalised Entries.' , 0);
                  tblJournal.SetFocus;
                  Exit;
               end;
               AutoDate := IncDate(pTran^.txDate_Effective, j*7, 0, 0);
            end;
         end;
         Dayly: begin
            // Weekly Journals
            PeriodsToAdd := 1;

            if EDateUntil.AsStDate > pTran^.txDate_Effective then
               FinalDate := EDateUntil.AsStDate
            else
               FinalDate := IncDate(pTran^.txDate_Effective, PeriodsToAdd, 0, 0);

            j := PeriodsToAdd;
            AutoDate := IncDate(pTran^.txDate_Effective, PeriodsToAdd, 0, 0);
            while AutoDate <= FinalDate do begin
               Inc(j, PeriodsToAdd);
               StDateToDMY( AutoDate, d, m, y);
               BOM := DMYtoSTDate( 1, m, y, BKDATEEPOCH);
               EOM := DMYtoSTDate( DaysInMonth( m, y, BKDATEEPOCH), m, y, BKDATEEPOCH);

               if (Finalise32.IsLocked(BOM, EOM) in [ltAll, ltSome]) then begin
                  HelpfulInfoMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                   'the day for the new journal (' +
                                   inttostr(d) + inttostr(m) + '/' + inttostr(y) +
                                   ') contains Finalised Entries.' , 0);
                  tblJournal.SetFocus;
                  Exit;
               end;
               AutoDate := IncDate(AutoDate, j, 0, 0);
            end;
         end;

         Monthly: begin
            //Monthly Journals
            PeriodsToAdd := GetMonthsToAddFromCombo;

            if EDateUntil.AsStDate > pTran^.txDate_Effective then
               FinalDate := EDateUntil.AsStDate
            else
               FinalDate := IncDate(pTran^.txDate_Effective, 0, PeriodsToAdd, 0);

            j := PeriodsToAdd;
            AutoDate := JnlUtils32.GetCorrespondingDayInNMonths( pTran^.txDate_Effective, j);
            while AutoDate <= FinalDate do begin
               Inc(j, PeriodsToAdd);
               StDateToDMY( AutoDate, d, m, y);
               BOM := DMYtoSTDate( 1, m, y, BKDATEEPOCH);
               EOM := DMYtoSTDate( DaysInMonth( m, y, BKDATEEPOCH), m, y, BKDATEEPOCH);

               if ( Finalise32.IsLocked( BOM, EOM) in [ ltAll, ltSome]) then begin
                  HelpfulInfoMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                   'the month for the new journal (' +
                                   inttostr(m) + '/' + inttostr(y) +
                                   ') contains Finalised Entries.' , 0);
                  tblJournal.SetFocus;
                  Exit;
               end;
               AutoDate := JnlUtils32.GetCorrespondingDayInNMonths( pTran^.txDate_Effective, j);
            end;
         end;
      end;

      //check that the automatic journals will not be created in a journal
      //that has already been transferred
      case period of
      Dayly : begin // Dayly journal
         PeriodsToAdd := 1;

         if EDateUntil.AsStDate > pTran^.txDate_Effective then
            FinalDate := EDateUntil.AsStDate
         else
            Finaldate := 0;

         FinalDate := max(FinalDate, IncDate(pTran^.txDate_Effective, PeriodsToAdd, 0, 0));


         j := PeriodsToAdd;
         AutoDate := IncDate(pTran^.txDate_Effective, j, 0, 0);
         while AutoDate <= FinalDate do begin
           Inc(j, PeriodsToAdd);
           //see if a journal already exists for this date
           NextJnl := GetJournalFor( Bank_Account, AutoDate );
           if NextJnl <> nil then begin
              if NextJnl.txDate_Transferred <> 0 then begin
                 HelpfulErrorMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                 'a Journal already exists on ' + bkDate2Str(AutoDate) +
                                 ' that has been transferred to your accounting system.' , 0);
                 tblJournal.SetFocus;
                 Exit;
              end;
           end;
           Inc(JournalCount);
           AutoDate := IncDate(pTran^.txDate_Effective, j, 0, 0);
         end;
      end;

      Weekly :
      begin // Weekly journals
        PeriodsToAdd := GetWeeksToAddFromCombo;

        if EDateUntil.AsStDate > pTran^.txDate_Effective then
           FinalDate := EDateUntil.AsStDate
        else
           Finaldate := 0;

        FinalDate := max(FinalDate, IncDate(pTran^.txDate_Effective, PeriodsToAdd * 7, 0, 0));

        j := PeriodsToAdd;
        AutoDate := IncDate(pTran^.txDate_Effective, j*7, 0, 0);
        while AutoDate <= FinalDate do
        begin
          Inc(j, PeriodsToAdd);
          //see if a journal already exists for this date
          NextJnl := GetJournalFor( Bank_Account, AutoDate );
          if NextJnl <> nil then begin
             if NextJnl.txDate_Transferred <> 0 then begin
                HelpfulErrorMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                 'a Journal already exists on ' + bkDate2Str(AutoDate) +
                                 ' that has been transferred to your accounting system.' , 0);
                tblJournal.SetFocus;
                Result := False;
                Exit;
             end;
          end;
          Inc(JournalCount);
          AutoDate := IncDate(pTran^.txDate_Effective, j*7, 0, 0);
        end;
      end;
      Monthly:
      begin
        PeriodsToAdd := GetMonthsToAddFromCombo;

        if EDateUntil.AsStDate > pTran^.txDate_Effective then
           FinalDate := EDateUntil.AsStDate
        else
           Finaldate := 0;
        FinalDate := Max(FinalDate, IncDate(pTran^.txDate_Effective, 0, PeriodsToAdd, 0));

        j := PeriodsToAdd;
        AutoDate := JnlUtils32.GetCorrespondingDayInNMonths( pTran^.txDate_Effective, j);
        while AutoDate <= FinalDate do
        begin
          Inc(j, PeriodsToAdd);
          //see if a journal already exists for this date
          NextJnl := GetJournalFor( Bank_Account, AutoDate );
          if NextJnl <> nil then begin
             if NextJnl.txDate_Transferred <> 0 then begin
                HelpfulErrorMsg( 'You cannot create Standing and/or Reversing Journals because ' +
                                 'a Journal already exists on ' + bkDate2Str(AutoDate) +
                                 ' that has been transferred to your accounting system.' , 0);
                tblJournal.SetFocus;
                Result := False;
                Exit;
             end;
          end;
          Inc(JournalCount);
          AutoDate := JnlUtils32.GetCorrespondingDayInNMonths( pTran^.txDate_Effective, j);
        end;
      end;
       end;
      end;
      //Now check that reversing and standing journals will create journals that
      //balance next month
      //Reversing
      CalcControlTotals( Count, Total, GST, Remain, jtReversing);
      if ( Total <> 0) then begin
         HelpfulErrorMsg( 'The sum of the reversing Journal lines is out of balance by ' + MyClient.MoneyStr( Total ), 0 );
         tblJournal.SetFocus;
         Result := False;
         Exit;
      end;

      //Now check that reversing and standing journals will create journals that
      //balance next month
      //Reversing
      CalcControlTotals( Count, Total, GST, Remain, jtStanding);
      if ( Total <> 0) then begin
         HelpfulErrorMsg( 'The sum of the standing Journal lines is out of balance by ' + MyClient.MoneyStr( Total ), 0 );
         tblJournal.SetFocus;
         Result := False;
         Exit;
      end;

      //all checks are ok, prompt the user the to confirm that the want to create
      //journals in the period selected
      if HasLinesToProcess then
      begin
        msg := 'Please confirm that you want ' + ShortAppName + ' ' +
               'to automatically generate Standing and/or Reversing Journals ' + cmbReverseWhen.Items[cmbReverseWhen.ItemIndex];
        if (EDateUntil.AsStDate > pTran^.txDate_Effective)
        and (JournalCount > 1) then begin
           msg := msg + ','#13'with Standing Journals repeated ' +IntToStr(JournalCount)
             + ' times, until ' + EDateUntil.AsString
        end;
        msg := msg + '.';

        if YesNoDlg.AskYesNo('Generate Automatic Journals', msg, DLG_YES, 0) <> DLG_YES then
        begin
          Result := False;
          Exit;
        end;
      end;
   end;

   // OK From here, Just process..
   Result := true;

   //Check if there is blank record within records.  This is to prevent
   //the changing of order of entries, but this only works when there is
   //no blank entry within entries.
   HasBlank := False;
   for i := 0 to GLCONST.Max_tx_Lines-2  do begin
      pA := WorkJournal.Items[ i ];
      pB := WorkJournal.Items[ i+1 ];
      if (( pA^.dtAccount = '') and ( pB^.dtAccount <> '' )) // Not Blank, After blank..
      or (( pA^.dtAmount  = 0 ) and ( pB^.dtAmount  <> 0  )) then begin
         HasBlank := True;
         Break;
      end;
   end;
   if HasBlank then //Remove blank record(s) in between records
      RemoveBlanks;

   CalcControlTotals( Count, Total, GST, Remain );
   AuditIDList := TList.Create;
   try
     Dump_Dissections( pTran, AuditIDList ); //Clear current dissection lines

     // Store dissection lines
     for i := 0 to Pred( Count ) do begin
       pDissection := New_Dissection_Rec;
       pJ := WorkJournal.Items[i];
       with pDissection^, pJ^ do begin
          dsTransaction     := pTran;
          dsAccount         := dtAccount;
          dsReference       := dtReference;
          dsAmount          := dtAmount;
          dsPayee_Number    := dtPayee_Number;
          dsGST_Class       := dtGST_Class;
          dsGST_Amount      := dtGST_Amount;
          dsQuantity        := dtQuantity;
          dsGL_Narration       := dtNarration;
          dsHas_Been_Edited := dtHas_Been_Edited;
          dsGST_Has_Been_Edited := dtGST_Has_Been_Edited;
          dsLinked_Journal_Date := dtLinkedJnlDate;
          dsJob_Code            := dtJob;

          //super fields
          dsSF_Imputed_Credit      := dtSF_Imputed_Credit;
          dsSF_Tax_Free_Dist       := dtSF_Tax_Free_Dist;
          dsSF_Tax_Exempt_Dist     := dtSF_Tax_Exempt_Dist;
          dsSF_Tax_Deferred_Dist   := dtSF_Tax_Deferred_Dist;
          dsSF_TFN_Credits         := dtSF_TFN_Credits;
          dsSF_Foreign_Income      := dtSF_Foreign_Income;
          dsSF_Foreign_Tax_Credits := dtSF_Foreign_Tax_Credits;
          dsSF_Capital_Gains_Indexed  := dtSF_Capital_Gains_Indexed;
          dsSF_Capital_Gains_Disc := dtSF_Capital_Gains_Disc;
          dsSF_Capital_Gains_Other   := dtSF_Capital_Gains_Other;
          dsSF_Other_Expenses        := dtSF_Other_Expenses;
          dsSF_CGT_Date              := dtSF_CGT_Date;
          dsSF_Franked               := dtSF_Franked;
          dsSF_Unfranked             := dtSF_Unfranked;
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
          dsSF_Super_Fields_Edited := dtSF_Super_Fields_Edited ;

          dsDocument_Title       := dtDocument_Title;
          dsDocument_Status_Update_Required := dtDocument_Status_Update_Required;
          dsExternal_GUID := dtExternal_GUID;

          //make sure that a valid type is used.  If it is undefined (-1) use jtNormal
          if ( not (dtStatus in [jtMin..jtMax])) then
             dsJournal_Type := jtNormal
          else
             dsJournal_Type := dtStatus;

          if AuditIDList.Count > 0 then begin
            pDissection.dsAudit_Record_ID := integer(AuditIDList.Items[0]);
            TrxList32.AppendDissection( pTran, pDissection, nil );
            AuditIDList.Delete(0);
          end else
            TrxList32.AppendDissection( pTran, pDissection, MyClient.ClientAuditMgr );
       end;
     end;
   finally
     AuditIDList.Free;
   end;
   pTran^.txCoded_By := cbManual;
   pTran^.txAccount  := DISSECT_DESC;

   //Process Journal if option selected
   if ( chkProcessOnExit.Checked ) then begin
     FinalDate := 0;
     case period of
     Dayly : begin

        PeriodsToAdd := 1;
        if EDateUntil.AsStDate > pTran^.txDate_Effective then
           FinalDate := EDateUntil.AsStDate;
        FinalDate := Max(FinalDate,IncDate(pTran^.txDate_Effective, PeriodsToAdd, 0, 0));

     end;
     Weekly : begin //Weekly

        PeriodsToAdd := GetWeeksToAddFromCombo;
        if EDateUntil.AsStDate > pTran^.txDate_Effective then
           FinalDate := EDateUntil.AsStDate;
        FinalDate := Max(FinalDate,IncDate(pTran^.txDate_Effective, PeriodsToAdd * 7, 0, 0));

     end;
     else begin  // Monthly
        PeriodsToAdd := GetMonthsToAddFromCombo;
        if EDateUntil.AsStDate > pTran^.txDate_Effective then
           FinalDate := EDateUntil.AsStDate;

        Finaldate := Max(Finaldate,GetCorrespondingDayInNMonths(pTran.txDate_Effective, PeriodsToAdd));

     end;
     end;
     ProcessJournal( MyClient, Bank_Account, pTran, period, PeriodsToAdd, 0, Finaldate);
   end;

   //save back reversing/standing period setting
   MyClient.clFields.clJournal_Processing_Period := ComboUtils.GetComboCurrentIntObject(cmbReverseWhen);
end;

//------------------------------------------------------------------------------
// Check to see what was entered.  The transaction amount becomes the
// sum of the lines in the dissection.
// If there are no dissection lines then the transaction is deleted
procedure TdlgJournal.FreeCurrentTransactionIfEmpty;
var
  Dissection   : pDissection_Rec;
  SomeThere    : boolean;
begin
   With pTran^ do
   Begin
      Dissection := txFirst_Dissection;
      txAmount    := 0;
      SomeThere   := FALSE;

      While Dissection<>NIL do With Dissection^ do
      Begin
         txAmount := txAmount + dsAmount;
         SomeThere := TRUE;
         Dissection := dsNext;
      end;

      If not SomeThere then
      begin
        Bank_Account.baTransaction_List.DelFreeItem(pTran); {delete if empty}
      end;
   end;
end;
//------------------------------------------------------------------------------
function TdlgJournal.GetEOMDate(Months : Integer) : Integer;
//if the current journal is dated on an EOM this function will return a date
//that is x 'months' from the current journal date.
//if the current journal is not an EOM date then the first move will be to
//the end of the current month
var
  d, m, y : Integer;
begin
  if Months = 0 then
    begin
      result := pTran^.txDate_Effective;
      exit;
    end;

  StDateToDMY(pTran^.txDate_Effective, d, m, y);

  if ( Months > 0) then
    //moving forwards, see if we are current at a month end
    begin
      if (d  <> DaysInMonth(m,y,BKDATEEPOCH)) then
        begin
          d := DaysInMonth(m,y,BKDATEEPOCH);
          Months := Months - 1;
        end;
    end;


  //shift current month
  m := m + Months;
  while (m < 1) do begin
     Dec(y);
     m := m + 12;
  end;

  while (m > 12) do begin
     Inc(y);
     m := m - 12;
  end;

  //construct new date
  d := DaysInMonth(m,y,BKDATEEPOCH);
  Result := DMYtoStDate(d,m,y,BKDATEEPOCH);
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.ShowJournal(Months : Integer);
var
  i  : Integer;
  EOMDate : Integer;
  pT, pTNext : pTransaction_Rec;
begin
  SaveLayoutForThisAcct;
  EOMDate := GetEOMDate(Months);
  //check date range previous
  if (EOMDate < MinValidDate) then
    Exit;

  //check date range next
  if (EOMDate > MaxValidDate) then
    Exit;

  pTNext := nil;
  if Assigned(Bank_Account) then
  begin
    //find the journal for the specified End of Month date
    for i := 0 to Bank_Account.baTransaction_List.ItemCount-1 do begin
      pT := Bank_Account.baTransaction_List.Transaction_At( i);
      if (pT^.txDate_Effective = EOMDate) then
         pTNext := pT;
    end;
  end;

  if (not Assigned(pTNext)) then begin
     //no journal found so create one
     if JournalType in [ btCashJournals, btAccrualJournals, btGSTJournals] then begin

         if ( Finalise32.IsMonthLocked(EOMDate) in [ ltAll, ltSome]) then begin
            HelpfulWarningMsg( 'Finalised entries exist in the month you have selected.  You ' +
                               'cannot create a new journal in a finalised period.', 0);
            Exit;
         end;
     end;
     pTNext := NewJournalFor( MyClient, Bank_Account, EOMDate);
  end;



  if (Assigned(pTNext)) then
  begin
    FreeCurrentTransactionIfEmpty;
    pTran := pTNext;
    ClearJournalLines;
    SetUpForm;
    tblJournal.Refresh;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.tbPreviousClick(Sender: TObject);
var
  i : Integer;
  EOMDate : Integer;
  pTPrevious : pTransaction_Rec;
  nd, nm, ny : Integer;
begin
  SaveLayoutForThisAcct;
  if (OKToPost) then
  begin
    EOMDate := GetEOMDate(-1); //end of date date for the previous month
    pTPrevious := nil;
    if (Assigned(Bank_Account)) then
    begin
      //find the previous transaction
      i := Bank_Account.baTransaction_List.IndexOf(pTran);
      if i > 0 then
         pTPrevious := Bank_Account.baTransaction_List.Transaction_At(pred(i));
    end;

    if (Assigned(pTPrevious)) then
    begin
      if (pTPrevious^.txDate_Effective >= EOMDate) then
      begin
        //the date of the Prev transaction is after the previous month end date
        //check to see if the date difference is 1 month or less
        DateDiff(pTPrevious^.txDate_Effective, pTran^.txDate_Effective, nd, nm, ny);
        if (ny = 0) and (nm <= 1) then
        begin
          FreeCurrentTransactionIfEmpty;
          pTran := pTPrevious;
          ClearJournalLines;
          SetUpForm;
          tblJournal.Refresh;
        end
        else
          ShowJournal(-1);
      end
      else
        //previous journal is more back further than end of month, just move
        //back to eom
        ShowJournal(-1);
    end
    else
      //could not find a journal, move back one month
      ShowJournal(-1);
  end;
end;

procedure TdlgJournal.tmrPayeeTimer(Sender: TObject);
var
  pJ  : pWorkJournal_Rec;
  OldPayeeNo: Integer;
begin
   tmrPayee.Enabled := False;
   if PayeeRow <= 0 then
      Exit;
   pJ := WorkJournal.Items[PayeeRow-1];
   if ( pJ^.dtPayee_Number <> tmpPayee ) then
   begin
      //tblJournal.ActiveCol := ColumnFmtList.GetColNumOfField(cePayee);
      OldPayeeNo := pJ^.dtPayee_Number;
      pJ^.dtPayee_Number  := tmpPayee;
      if PayeeEdited(pJ,PayeeRow) then
         pJ^.dtHas_Been_Edited := true
      else
         pJ^.dtPayee_Number := OldPayeeNo;
      RedrawRow(PayeeRow);
      PayeeRow := -1;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgJournal.Back1month1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-1);
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.Back2months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-2);
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.Back3months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-3);
end;
//------------------------------------------------------------------------------
procedure TdlgJournal.Back6months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-6);
end;
procedure TdlgJournal.BtnCalClick(Sender: TObject);
begin
    eDateUntilDblClick(eDateUntil);
end;

//------------------------------------------------------------------------------
procedure TdlgJournal.Back5months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-5);
end;

procedure TdlgJournal.Back11months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(-11);
end;

procedure TdlgJournal.tbNextClick(Sender: TObject);
var
  i : Integer;
  EOMDate : Integer;
  pTNext : pTransaction_Rec;
  nd, nm, ny : Integer;
begin
  SaveLayoutForThisAcct;
  if (OKToPost) then
  begin
    EOMDate := GetEOMDate(1);
    pTNext := nil;
    if (Assigned(Bank_Account)) then
    begin
      //find the previous transaction
      i := Bank_Account.baTransaction_List.IndexOf(pTran);
      if i < Bank_Account.baTransaction_List.Last then
         pTNext := Bank_Account.baTransaction_List.Transaction_At(succ(i));
    end;

    if (Assigned(pTNext)) then
    begin
      if (pTNext^.txDate_Effective <= EOMDate) then
      begin
        //the date of the next transaction is before the end of the month date
        //check to see if the date difference is 1 month or less
        DateDiff(pTran^.txDate_Effective, pTNext^.txDate_Effective, nd, nm, ny);
        if (ny = 0) and (nm <= 1) then
        begin
          //next journal is within the month
          FreeCurrentTransactionIfEmpty;
          //reassign current transaction
          pTran := pTNext;

          ClearJournalLines;
          SetUpForm;
          tblJournal.Refresh;
        end
        else
          ShowJournal(1);
      end
      else
        ShowJournal(1);
    end
    else
      ShowJournal(1);
  end;
end;

procedure TdlgJournal.Forward1month1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(1);
end;

procedure TdlgJournal.Forward2months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(2);
end;

procedure TdlgJournal.Forward3months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(3);
end;

procedure TdlgJournal.Forward6months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(6);
end;

procedure TdlgJournal.Forward5months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(5);
end;

procedure TdlgJournal.Forward11months1Click(Sender: TObject);
begin
  if (OKToPost) then
    ShowJournal(11);
end;

procedure TdlgJournal.FormShow(Sender: TObject);
begin
  //turn Transparency off because ThemeManager turns it on
  lblStatus.Transparent := False;
  // Font is set at runtime
  lblStatus.Font.Color := clHighlightText;
end;

procedure TdlgJournal.ClearJournalLines;
var
  i : Integer;
  pJ : pWorkJournal_Rec;
begin
  //blank all entries
  for i := 0 to Pred( GLCONST.Max_tx_Lines ) do begin
    pJ := WorkJournal.Items[i];
    ClearWorkRecDetails(PJ);
  end;
end;

procedure TdlgJournal.ClearSuperfundDetails1Click(Sender: TObject);
var
  pJ: pWorkJournal_Rec;
begin
  with tblJournal do begin
     if not ValidDataRow(ActiveRow) then
        exit;
     pJ := WorkJournal.Items[tblJournal.ActiveRow-1];
     if Assigned(Pj) then begin
        ClearSuperFunddetails(Pj);
        RedrawRow;
     end;
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
procedure TdlgJournal.SetQuantitySign(QuantityChanged : Boolean);
var
  pJ : pWorkJournal_Rec;
  fQValue : Double;
begin
  pJ := WorkJournal.Items[tblJournal.ActiveRow-1];

  //user can have whatever sign they like if the amount is zero
  if pJ^.dtAmount = 0 then
    Exit;

  if (QuantityChanged) then
  begin
    //the quantity value was changed
    fQValue := TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat;

    if (pJ^.dtAmount > 0) then
    begin
      //amount is positive
      if (fQValue < 0) then
        //make the quantity positive
        TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat := (-fQValue);
    end
    else
    begin
      //amount is negative
      if (fQValue > 0) then
        //make the quantity negative
        TOvcNumericField(TOvcTCNumericField(celQuantity).CellEditor).AsFloat := (-fQValue);
    end;
  end else
  begin
    //the amount value was changed
    fQValue := pJ^.dtQuantity;
    if (pJ^.dtAmount > 0) then
    begin
      //amount is positive
      if (fQValue < 0) then
        //make the quantity positive
        pJ^.dtQuantity := (-fQValue);
    end else
    begin
      //amount is negative
      if (fQValue > 0) then
        //make the quantity negative
        pJ^.dtQuantity := (-fQValue);
    end;
  end;
end;

procedure TdlgJournal.celQuantityExit(Sender: TObject);
begin
  SetQuantitySign(True);
end;


procedure TdlgJournal.HideCustomHint;
var
  R : TRect;
begin
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then begin // Find where the Hint is, so we can redraw the cells beneath it.
         GetWindowRect( FHint.Handle, R );
         R.TopLeft      := tblJournal.ScreenToClient(R.TopLeft);
         R.BottomRight  := tblJournal.ScreenToClient(R.BottomRight);
         FHint.ReleaseHandle;
         HintShowing    := false;
         tblJournal.AllowRedraw := False;
         tblJournal.InvalidateCellsInRect( R );
         tblJournal.AllowRedraw := True;
      end;
   end;
end;


function TdlgJournal.GetCellRect(const RowNum, ColNum: Integer): TRect;
begin
  Result.Top    := tblJournal.Top  + tblJournal.RowOffset[ RowNum ];
  Result.Left   := tblJournal.Left + tblJournal.ColOffset[ ColNum ];
  Result.Bottom := tblJournal.Top  + tblJournal.RowOffset[ RowNum ] + tblJournal.Rows[ RowNum ].Height;
  Result.Right  := tblJournal.Left + tblJournal.ColOffset[ ColNum ] + tblJournal.Columns[ ColNum ].Width;

  Result.TopLeft := ClientToScreen( Result.TopLeft );
  Result.BottomRight := ClientToScreen( Result.BottomRight );
end;

procedure TdlgJournal.ShowCodingHint(const RowNum, ColNum: Integer;
  HintMsg: String);
var
   R : TRect;
begin
   HideCustomHint; // Hide any existing hint
   If INI_ShowCodeHints and ( HintMsg<>'' ) then
   begin
     // Make sure the mouse is on the form
     if PtInRect( tblJournal.BoundsRect, ScreenToClient( Mouse.CursorPos ) ) then
     begin
       R := GetCellRect( RowNum, ColNum );
       NewHints.ShowCustomHint( FHint, R, HintMsg );
       HintShowing := true;
     end;
   end;
end;

procedure TdlgJournal.ShowHintForCell(const RowNum, ColNum: integer);
var
  pJ : pWorkJournal_Rec;
  FieldID : integer;
  CustomHint : string;
begin
  if not ValidDataRow(RowNum) then
     exit;

  //show hints, only long hints appear
  pJ := WorkJournal.Items[tblJournal.ActiveRow-1];

  FieldID := ColumnFmtList.ColumnDefn_At(ColNum)^.cdFieldID;

  CustomHint := '';
  if Assigned( pJ) then begin
     PJ.dtDate := PTran.txDate_Effective;
     case FieldID of
        ceAccount : CustomHint := GetDissectionHint( pJ, INI_ShowCodeHints );
        ceAmount : if sBtnSuper.Visible then
                     CustomHint := GetSuperHint( pJ, INI_ShowCodeHints );
        cePayee : CustomHint := GetPayeeHint( pJ^.dtPayee_Number, INI_ShowCodeHints);
        ceJob : CustomHint := GetJobHint( pJ^.dtJob, INI_ShowCodeHints);
     end;
  end;

  if CustomHint <> '' then
      ShowCodingHint( RowNum, ColNum, CustomHint );
end;

procedure TdlgJournal.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  HideCustomHint;
end;

procedure TdlgJournal.FormDeactivate(Sender: TObject);
begin
  HideCustomHint;
end;

procedure TdlgJournal.CMMouseLeave(var Message: TMessage);
begin
  HideCustomHint;
end;

procedure TdlgJournal.WMVScroll(var Msg: TWMScroll);
begin
  HideCustomHint;
end;

procedure TdlgJournal.tblJournalTopLeftCellChanging(Sender: TObject;
  var RowNum, ColNum: Integer);
begin
  HideCustomHint;
end;

procedure TDlgJournal.CMMouseEnter(var Message: TMessage);
var
  RowNum, ColNum : integer;
begin
  if not tblJournal.Focused then
    exit; 

  if HintShowing then
    exit;

  //see if active row is off screen, if so dont show the hint
  RowNum := tblJournal.ActiveRow;
  if ( RowNum < tblJournal.TopRow) or ( RowNum > ( tblJournal.TopRow + tblJournal.VisibleRows - tblJournal.LockedRows)) then
    Exit;

  //only show the hint if the current cell is not being edited
  if not tblJournal.InEditingState then
  begin
    ColNum := tblJournal.ActiveCol;
    ShowHintForCell( RowNum, ColNum);
  end;
end;

procedure TdlgJournal.DoEditSuperFields;
var
  pD : pWorkJournal_Rec;
  Move: TFundNavigation;
  OldAccount: BK5CODESTR;
begin
  if not FCanUseSuperFundFields then
    Exit;

  if not ValidDataRow( tblJournal.ActiveRow ) then
     Exit;
  if not tblJournal.StopEditingState(True) then
    Exit;

  //get current dissection line
  pD   := WorkJournal.Items[ tblJournal.ActiveRow-1 ];
  if WorkJournal.Count = tblJournal.ActiveRow then
    Move := fnIsLast
  else if tblJournal.ActiveRow - 1 = 0 then
    Move := fnIsFirst
  else
    Move := fnNothing;

  OldAccount := pD.dtAccount;
  if SuperFieldsUtils.EditSuperFields( pTran, pD, Move, FSuperTop, FSuperLeft, Bank_Account) then
    begin
      if pD.dtAccount <> OldAccount then
        AccountEdited(pD);
      tblJournal.InvalidateRow( tblJournal.ActiveRow);
      tblJournal.Refresh;

      pD^.dtHas_Been_Edited := true;

      if Move = fnGoForward then
      begin
        tblJournal.ActiveRow := tblJournal.ActiveRow + 1;
        DoEditsuperFields;
      end
      else if Move = fnGoBack then
      begin
        tblJournal.ActiveRow := tblJournal.ActiveRow - 1;
        DoEditsuperFields;
      end
      else
      begin
        FSuperTop := -999;
        FSuperLeft := -999;
      end;
    end;
end;

procedure TdlgJournal.celAmountOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
const
  margin = 4;
var
  R   : TRect;
  C   : TCanvas;
  S   : String;
  pD : pWorkJournal_Rec;
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
  S := PChar( pfHiddenAmount.AsString);
  //check is a data row
  if ValidDataRow( RowNum ) then
  begin
     pD   := WorkJournal.Items[ RowNum -1 ];
     if pD^.dtSF_Super_Fields_Edited
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

procedure TdlgJournal.tblJournalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ColEstimate, RowEstimate : integer;
  R : TRect;
begin
  //estimate where click happened
  if tblJournal.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then exit;

  //see if in account col and has super fund fields
  if FCanUseSuperFundFields and (ColumnFmtList.ColumnDefn_At( ColEstimate ).cdFieldID = ceAmount) then
    begin
      //get row estimate
      if not ValidDataRow(RowEstimate) then
        exit;

      R := GetCellRect( RowEstimate, ColEstimate );
      R.Left := R.Right - 5;
      R.Bottom := R.Top + 5;

      if PtInRect( R, tblJournal.ClientToScreen( Point( x,y))) then
        begin
          DoEditSuperFields;
        end;
    end;
end;



procedure TdlgJournal.sbtnSuperClick(Sender: TObject);
begin
  DoEditSuperFields;
end;

procedure TdlgJournal.LookupChart1Click(Sender: TObject);
begin
   btnChart.Click;
end;

procedure TdlgJournal.LookupPayee1Click(Sender: TObject);
begin
   btnPayee.Click;
end;

procedure TdlgJournal.EditAllColumns1Click(Sender: TObject);
begin
  SetColEditMode( emGeneral );
end;

procedure TdlgJournal.EditCodesOnly1Click(Sender: TObject);
begin
  SetColEditMode( emRestrict );
end;

procedure TdlgJournal.EditSuperFields1Click(Sender: TObject);
begin
  sBtnSuper.Click;
end;

procedure TdlgJournal.GotoNextUncoded1Click(Sender: TObject);
begin
   DoGotoNextUnCode;
end;

// #1727 - add more shortcuts to the right-click menu

procedure TdlgJournal.LookupGSTClass1Click(Sender: TObject);
begin
  Self.DoGSTLookup;
end;

procedure TdlgJournal.CopyContentoftheCellAbove1Click(Sender: TObject);
begin
  Self.DoDitto;
end;

procedure TdlgJournal.AmountApplyRemainingAmount1Click(Sender: TObject);
begin
  Self.DoCompleteAmount(False);
end;


procedure TdlgJournal.AmountGrossupfromGSTAmount1Click(Sender: TObject);
begin
  ApplyAmountShortcut('*');
end;

procedure TdlgJournal.AmountGrossupfromNetAmount1Click(Sender: TObject);
begin
  ApplyAmountShortcut('@');
end;

// Applies a shortcut key press to the amount field
// Test if we are in the correct col, if not end any edit and move to
// correct col - *, % and @ only work within amount field. Simulate the key press
// then reset the active col to wherever the user was before
procedure TdlgJournal.ApplyAmountShortcut(Key: Char);
var
  Col: Integer;
  Move: Boolean;
begin
  Col := -1;
  with tblJournal do
  begin
    if not (ColumnFmtList.ColumnDefn_At(ActiveCol)^.cdFieldID = ceAmount) then
    begin
      Col := ActiveCol;
      if not StopEditingState(True) then Exit;
      ActiveCol := ColumnFmtList.GetColNumOfField(ceAmount);
      Move := True;
    end
    else
      Move := False;
    if not StartEditingState then Exit;
    DoCelAmountKeyPress(tblJournal, Key, Move);
    if Col > -1 then
      ActiveCol := Col;
  end;
end;

procedure TdlgJournal.celAccountKeyUp(Sender: TObject; var Key: Word;
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

procedure TdlgJournal.cbRepeatClick(Sender: TObject);
begin
   UpdateGenerateOptionsStatus;
end;

procedure TdlgJournal.celAccountExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(TEdit(celAccount.CellEditor).Text) then
    bkMaskUtils.CheckRemoveMaskChar(TEdit(celAccount.CellEditor),RemovingMask);
end;

procedure TdlgJournal.ConfigureColumns;
var
   i              : integer;
   cRec           : pColumnDefn;
   CurrentFieldID : integer;
   ColumnConfig   : TColumnConfigInfo;
begin
   //make sure not editing
   if not tblJournal.StopEditingState(True) then Exit;

   with TfrmConfigure.Create(Self) do begin
      try
         ShowTemplates := False;
         SortColumn := -1;
         CodingScreen := DISSECTION_SCREEN;
         ColumnFormatList := ColumnFmtList;
         NeverEditable := [];
         SetUpColDefaultsets;
         DefaultEditable := DefaultEditableCols;
         //setup appearance for CES
         lblEditModeDesc.Caption := 'Column can be edited';
         //Assign Values to ListBox
         lbColumns.Clear;
         //Build TColumnConfigInfo for the column that can be manipulated in dlg
         for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
            cRec := ColumnFmtList.ColumnDefn_At(i);
            ColumnConfig := TColumnConfigInfo.Create;
            with ColumnConfig do begin
               //set editable state
               if cRec.cdFieldID in [ ceAmount, ceAccount ] then
                  eDITState := EsAlwaysEditable
               ELSE if (( cRec.cdFieldID in [ ceGSTAmount]) and ( MyClient.clFields.clCountry = whAustralia )
                                                        and ( MyClient.clFields.clBAS_Calculation_Method = bmFull)) then
                  EditState := esNeverEditable
               else
               if ( cRec.cdFieldID in [ ceGSTClass] ) then
               Begin
                 If not Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
                   EditState := esNeverEditable
               End
               else if cRec.cdFieldId in [ceDescription, cePayeeName, ceJobName, ceAltChartCode] then
                  EditState := esNeverEditable
               else
               if cRec.cdEditMode[ emGeneral] then
                  EditState := esEditable
               else
                  EditState := esNotEditable;
               //set visible state
               if cRec.cdFieldID in [ ceAmount, ceAccount, ceNarration, ceJnlLineType ] then
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
         lbColumns.ItemIndex := tblJournal.ActiveCol;
         //Show Form
         SaveTempLayout;
         ShowModal;
         //Reorder the columns if OK pressed
         if ModalResult = mrOK then begin
            with tblJournal do begin
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
               end;
               //Rebuild the table
               BuildTableColumns;
               //Reset the active col in case the col was moved
               if ColumnFmtList.FieldIsEditable( CurrentFieldID) then
                  ActiveCol := ColumnFmtList.GetColNumOfField(CurrentFieldID)
               else
                  ActiveCol := ColumnFmtList.GetColNumOfField( ceAccount);
               OnColumnsChanged := tblJournalColumnsChanged;
               AllowRedraw := true;
            end;
         end
         else
         begin
           LoadTempLayout;
           tblJournal.Refresh;
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

procedure TdlgJournal.SaveLayoutForThisAcct;
var
   i : integer;
   ColDefn : pColumnDefn;
begin
   //build set of columns that are editable by default
   SetupColDefaultSets;

   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
     begin
       ColDefn := ColumnFmtList.ColumnDefn_At(i);
       case JournalType of
         btCashJournals:
           begin
             MyClient.clFields.clCashJ_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
             MyClient.clFields.clCashJ_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
             MyClient.clFields.clCashJ_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
             MyClient.clFields.clCashJ_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
           end;
         btAccrualJournals:
           begin
             MyClient.clFields.clAcrlJ_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
             MyClient.clFields.clAcrlJ_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
             MyClient.clFields.clAcrlJ_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
             MyClient.clFields.clAcrlJ_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
           end;
         btGSTJournals:
           begin
             MyClient.clFields.clgstJ_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
             MyClient.clFields.clgstJ_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
             MyClient.clFields.clgstJ_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
             MyClient.clFields.clgstJ_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
           end;
         btStockJournals, btStockBalances:
           begin
             MyClient.clFields.clStockJ_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
             MyClient.clFields.clStockJ_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
             MyClient.clFields.clStockJ_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
             MyClient.clFields.clStockJ_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
           end;
         btYearEndAdjustments:
           begin
             MyClient.clFields.clYrEJ_Column_Width[ ColDefn^.cdFieldID ]     := ColDefn^.cdWidth;
             MyClient.clFields.clYrEJ_Column_Is_Hidden[ ColDefn^.cdFieldID ] := ColDefn^.cdHidden;
             MyClient.clFields.clYrEJ_Column_Order[ ColDefn^.cdFieldID ]     := i;    //use the list index position for the current positions
             MyClient.clFields.clYrEJ_Column_Is_Not_Editable[ ColDefn^.cdFieldID] := not ColDefn^.cdEditMode[ emGeneral];
           end;
       end;
     end;
end;

procedure TdlgJournal.LoadLayoutForThisAcct;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
   i, PosDesc, PosPN : integer;
   ColDefn : pColumnDefn;
   UseDefaults: Boolean;
   FirstDesc, FirstPN : Boolean;

   procedure SetFirst(FieldId : Integer; cl_Column_Order: Array of Integer);
   begin
      if (FieldId = ceDescription) and (cl_Column_Order[FieldID] = 0) then // first time
         FirstDesc := True
      else if (FieldId = cePayeeName) and (cl_Column_Order[FieldID] = 0) then // first time
         FirstPN := True;

   end;

begin
   //build set of columns that are editable by default
   SetupColDefaultSets;
   FirstDesc := False;
   FirstPN := False;
   PosDesc := 2;
   PosPN := 8;
   for i := 0 to Pred( ColumnFmtList.ItemCount ) do
   begin
      UseDefaults := False;
      ColDefn := ColumnFmtList.ColumnDefn_At(i);
      with ColDefn^, MyClient.clFields do
      begin

        case JournalType of
          btCashJournals:
            begin
              SetFirst(cdFieldID,clCashJ_Column_Width);
              if clCashJ_Column_Width[ cdFieldID] <> 0 then
              begin
                cdWidth            := clCashJ_Column_Width[ cdFieldID];
                cdRequiredPosition := clCashJ_Column_Order[ cdFieldID];
                cdHidden           := clCashJ_Column_Is_Hidden[ cdFieldID];
                //set status of columns that are editable by default
                if cdFieldId in DefaultEditableCols then
                   cdEditMode[ emGeneral] := not clCashJ_Column_Is_Not_Editable[ cdFieldID]
                else
                    cdEditMode[ emGeneral] := False;
              end
              else
                UseDefaults := True;
            end;
          btAccrualJournals:
            begin
              SetFirst(cdFieldID,clAcrlJ_Column_Width);
              if clAcrlJ_Column_Width[ cdFieldID] <> 0 then
              begin
                cdWidth            := clAcrlJ_Column_Width[ cdFieldID];
                cdRequiredPosition := clAcrlJ_Column_Order[ cdFieldID];
                cdHidden           := clAcrlJ_Column_Is_Hidden[ cdFieldID];
                //set status of columns that are editable by default
                if cdFieldId in DefaultEditableCols then
                   cdEditMode[ emGeneral] := not clAcrlJ_Column_Is_Not_Editable[ cdFieldID]
                else
                    cdEditMode[ emGeneral] := False;
              end
              else
                UseDefaults := True;
            end;
          btGSTJournals:
            begin
              SetFirst(cdFieldID,clgstJ_Column_Width);
              if clgstJ_Column_Width[ cdFieldID] <> 0 then
              begin
                cdWidth            := clgstJ_Column_Width[ cdFieldID];
                cdRequiredPosition := clgstJ_Column_Order[ cdFieldID];
                cdHidden           := clgstJ_Column_Is_Hidden[ cdFieldID];
                //set status of columns that are editable by default
                if cdFieldId in DefaultEditableCols then
                   cdEditMode[ emGeneral] := not clgstJ_Column_Is_Not_Editable[ cdFieldID]
                else
                    cdEditMode[ emGeneral] := False;
              end
              else
                UseDefaults := True;
            end;
          btStockJournals, btStockBalances:
            begin
              SetFirst(cdFieldID,clStockJ_Column_Width);
              if clStockJ_Column_Width[ cdFieldID] <> 0 then
              begin
                cdWidth            := clStockJ_Column_Width[ cdFieldID];
                cdRequiredPosition := clStockJ_Column_Order[ cdFieldID];
                cdHidden           := clStockJ_Column_Is_Hidden[ cdFieldID];
                //set status of columns that are editable by default
                if cdFieldId in DefaultEditableCols then
                   cdEditMode[ emGeneral] := not clStockJ_Column_Is_Not_Editable[ cdFieldID]
                else
                    cdEditMode[ emGeneral] := False;

              end
              else
                UseDefaults := True;
            end;
          btYearEndAdjustments:
            begin
              SetFirst(cdFieldID,clYrEJ_Column_Width);

              if clYrEJ_Column_Width[ cdFieldID] <> 0 then
              begin
                cdWidth            := clYrEJ_Column_Width[ cdFieldID];
                cdRequiredPosition := clYrEJ_Column_Order[ cdFieldID];
                cdHidden           := clYrEJ_Column_Is_Hidden[ cdFieldID];
                //set status of columns that are editable by default
                if cdFieldId in DefaultEditableCols then
                   cdEditMode[ emGeneral] := not clYrEJ_Column_Is_Not_Editable[ cdFieldID]
                else
                    cdEditMode[ emGeneral] := False;

              end
              else
                UseDefaults := True;
            end;
        end;
        if UseDefaults then
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
          PosPN := cdRequiredPosition+1;
      end; // with
   end; // for
   

   if FirstDesc then
     for i := 0 to Pred( ColumnFmtList.ItemCount ) do begin
        ColDefn := ColumnFmtList.ColumnDefn_At(i);
        if ColDefn.cdFieldId = ceDescription then
           ColDefn.cdRequiredPosition := PosDesc
        else if ColDefn.cdRequiredPosition >= PosDesc then begin
           if FirstPN
           and (ColDefn.cdFieldId = cePayee) then
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

procedure TdlgJournal.SetupColDefaultSets;
begin
   DefaultEditableCols := [ceAccount, ceReference,  ceAmount, ceQuantity,
                          ceNarration, ceMoneyIn, ceMoneyOut, ceJnlLineType, cePayee, ceJob];

   If Software.CanAlterGSTClass( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
      DefaultEditableCols := DefaultEditableCols + [ceGSTClass];

   if (MyClient.clFields.clCountry = whAustralia )
   and (MyClient.clFields.clBAS_Calculation_Method <> bmFull) then
      DefaultEditableCols := DefaultEditableCols + [ceGSTAmount];

   if (MyClient.clFields.clCountry <> whAustralia ) then
      DefaultEditableCols := DefaultEditableCols + [ceGSTClass, ceGSTAmount];
end;

procedure TdlgJournal.ResetColumns;
var
   i, CurrentFieldID : integer;
   Col: pColumnDefn;
begin
  with tblJournal do
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
end;

procedure TdlgJournal.LoadTempLayout;
//load the layout, position and hidden state for each column from the bank account details
//if no width information is provide assume that no settings have been saved for this
//column and use the defaults
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblJournal do
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

procedure TdlgJournal.SaveTempLayout;
var
  i : integer;
  ColDefn : pColumnDefn;
begin
  with tblJournal do
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

procedure TdlgJournal.SetFormPositionFromINI( DefaultWidth, DefaultHeight : integer);
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
                       ( ini_dsLeft + ini_dsWidth > Screen.DesktopWidth );

  if ResetToDefaultPos then
  begin
    ini_dsWidth    := DefaultWidth;
    ini_dsHeight   := DefaultHeight;

    ini_dsTop      := ( Application.MainForm.Monitor.Height - ini_dsHeight ) div 2;
    ini_dsLeft     := ( Application.MainForm.Monitor.Width - ini_dsWidth) div 2;
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

procedure TdlgJournal.UpdateGenerateOptionsStatus;
var
  Standing: Boolean;
  Reversing: Boolean;
  i: Integer;
  pJ: pWorkJournal_Rec;
begin
   Standing := False;
   Reversing := false;
   for i := 0 to Pred( GLCONST.Max_tx_Lines ) do
   begin
      pJ := WorkJournal.Items[i];
      with pJ^ do
         case dtStatus of
         jtStanding : begin
           Standing := True;
           if Reversing then
              Break;
         end;
         jtreversing : begin
           Reversing := True;
           if Standing then
              Break;
         end;
         end;
   end;

   chkProcessOnExit.Enabled := (Reversing or Standing);
   cmbReverseWhen.Enabled := (Reversing or Standing);
   EDateUntil.Enabled := Standing
                     and cbRepeat.Checked;
   cbRepeat.Enabled := Standing;

end;

//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);

end.
