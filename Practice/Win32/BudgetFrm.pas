unit BudgetFrm;
{--------------------------------------------------}
{  provide editing functionality for a budget      }
{  one budget per form                             }
{--------------------------------------------------}
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
  OvcTCmmn,
  OvcTCell,
  OvcTCHdr,
  StdCtrls,
  OvcBase,
  OvcTable,
  BkConst,
  ExtCtrls,
  ComCtrls,
  OvcTCNum,
  OvcTCEdt,
  BKDEFS,
  RzButton,
  budobj32,
  Menus,
  RzPanel,
  OSfont,
  ActnList,
  chList32,
  ovctcbef,
  ovctcstr,
  MoneyDef,
  BudgetImportExport,
  PercentageCalculationFrm,
  BroadcastSystem,
  GstCalc32,
  clObj32;
  
type
  TfrmBudget = class(TForm)
    stsDissect: TStatusBar;
    tblBudget: TOvcTable;
    DissectController: TOvcController;
    tblHeader: TOvcTCColHead;
    ColAccount: TOvcTCString;
    ColMonth1: TOvcTCNumericField;
    ColMonth5: TOvcTCNumericField;
    ColMonth12: TOvcTCNumericField;
    ColMonth9: TOvcTCNumericField;
    ColMonth10: TOvcTCNumericField;
    ColMonth11: TOvcTCNumericField;
    ColMonth3: TOvcTCNumericField;
    ColMonth4: TOvcTCNumericField;
    ColMonth6: TOvcTCNumericField;
    ColMonth8: TOvcTCNumericField;
    ColMonth7: TOvcTCNumericField;
    ColMonth2: TOvcTCNumericField;
    ColDesc: TOvcTCString;
    popBudget: TPopupMenu;
    mniGenerate: TMenuItem;
    mniCopy: TMenuItem;
    mniSplit: TMenuItem;
    mniAverage: TMenuItem;
    mniSmooth: TMenuItem;
    mniClearAll: TMenuItem;
    N2: TMenuItem;
    mniEnterBalance: TMenuItem;
    N3: TMenuItem;
    mniLockLeftmost: TMenuItem;
    mniIncreaseDecrease: TMenuItem;
    ExtraTitleBar: TRzPanel;
    lblDetails: TLabel;
    lblStart: TLabel;
    edtName: TEdit;
    lblAllExclude: TLabel;
    lblReminderNote: TLabel;
    lblname: TLabel;
    Restoredefaultcolumnwidths1: TMenuItem;
    ColTotal: TOvcTCNumericField;
    ALBudget: TActionList;
    ActClearAll: TAction;
    ActClearColumn: TAction;
    ActClearRow: TAction;
    popClearItems: TPopupMenu;
    miClearColumn: TMenuItem;
    miClearRow: TMenuItem;
    miClearAll: TMenuItem;
    mniHideUnused: TMenuItem;
    N1: TMenuItem;
    mniShowAll: TMenuItem;
    mniChartLookup: TMenuItem;
    mniClear: TMenuItem;
    mniClearRow: TMenuItem;
    mniEnterQuantity: TMenuItem;
    N4: TMenuItem;
    mniImport: TMenuItem;
    mniExport: TMenuItem;
    mniClearColumn: TMenuItem;
    actAutoCalculateGST: TAction;
    AutocalculateGST1: TMenuItem;
    mniEnterPercentage: TMenuItem;
    rgGST: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure tblBudgetGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblBudgetActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure tblBudgetGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblBudgetUserCommand(Sender: TObject; Command: Word);
    procedure tblBudgetBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblBudgetEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblBudgetDoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure tblBudgetEnteringRow(Sender: TObject; RowNum: Integer);
    procedure FormShow(Sender: TObject);
    procedure tblBudgetActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblBudgetExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure mniGenerateClick(Sender: TObject);
    procedure mniCopyClick(Sender: TObject);
    procedure mniSplitClick(Sender: TObject);
    procedure mniAverageClick(Sender: TObject);
    procedure mniSmoothClick(Sender: TObject);
    procedure BkMouseWheelHandler(Sender : TObject; Shift : TShiftState; Delta, XPos, YPos : Word );
    procedure mnuCloseClick(Sender: TObject);
    procedure edtNameEnter(Sender: TObject);
    procedure edtNameExit(Sender: TObject);
    procedure edtNameKeyPress(Sender: TObject; var Key: Char);
    procedure edtNameChange(Sender: TObject);
    procedure mniEnterBalanceClick(Sender: TObject);
    procedure mniLockLeftmostClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mniIncreaseDecreaseClick(Sender: TObject);
    procedure tblBudgetMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblnameClick(Sender: TObject);
    procedure Restoredefaultcolumnwidths1Click(Sender: TObject);
    procedure ActClearRowExecute(Sender: TObject);
    procedure ActClearColumnExecute(Sender: TObject);
    procedure ActClearAllExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniHideUnusedClick(Sender: TObject);
    procedure mniShowAllClick(Sender: TObject);
    procedure mniChartLookupClick(Sender: TObject);
    procedure mniClearClick(Sender: TObject);
    procedure mniClearRowClick(Sender: TObject);
    procedure ColMonthOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure mniEnterQuantityClick(Sender: TObject);
    procedure mniImportClick(Sender: TObject);
    procedure mniExportClick(Sender: TObject);
    procedure mniClearColumnClick(Sender: TObject);
    procedure mniEnterPercentageClick(Sender: TObject);
    procedure actAutoCalculateGSTUpdate(Sender: TObject);
    procedure actAutoCalculateGSTExecute(Sender: TObject);
    procedure rgGSTClick(Sender: TObject);
  private
    { Private declarations }
    FHint            : THintWindow;
    HintShowing      : boolean;
    EditMode         : boolean;
    FData            : TBudgetData; {this array is used to hold the data for the grid}
    DataAssigned     : Boolean;

    CurrentRow       : integer;
    AltLineColor     : integer;
    FBudget          : TBudget;
    fShowZeros       : boolean;

    eAmounts         : Array[1..12] of integer;
    FIsClosing: Boolean; {current edit values for record}
    FChart: TCustomSortChart;
    frmPercentageCalculation: TfrmPercentageCalculation;

    procedure InitTable;
    function  RowNumOK(RowNum : integer): boolean;
    function  RowDataOK(RowNum : integer;Routine:string): boolean;
    procedure ReadCellforPaint(RowNum,ColNum : integer;var Data : pointer);
    procedure ReadCellforEdit(RowNum,ColNum: integer; var Data : pointer);
    procedure WriteCell(RowNum,ColNum : integer; var Data : pointer);
    procedure ReadRow(RowNum : integer);
    procedure EndEditRow(RowNum, ColNum : integer; var AllowIt : boolean);

    procedure SetBudget(const Value: TBudget);
    procedure UpdateLine(index : integer; CopyPercentages: boolean = true);
    procedure UpdateAllLines;

    procedure CheckEditMode;
    procedure DoCopy;
    procedure DoClearValues(clrClearType: EClearType);
    procedure DoSmooth;
    procedure DoSplit;
    procedure DoAverage;
    procedure DoGenerate;
    procedure DoPercentageChange;
    procedure DoEnterBalance;
    procedure DoHideUnused;
    procedure DoShowAll;
    procedure DoChartLookup;
    procedure DoUnitPriceEntry;
    procedure DoPercentageCalculation(DataRow: integer = -1; OnlyUpdateThisColumn: integer = -1);
    procedure DoImport;
    procedure DoExport;

    procedure DoDeleteLine;

    procedure SetupHelp;
    procedure SetIsClosing(const Value: Boolean);

    procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );

    procedure WMSysCommand(var msg: TWMSyscommand); message WM_SYSCOMMAND;
    procedure tblBudgetVSThumbChanged(Sender: TObject; RowNum: TRowNum);
    procedure HideCustomHint;
    function GetTotalForRow(RowNum: Integer; IncludeGST: boolean): Integer;
    procedure RefreshFData(ShowZeros: Boolean; var aDataIndex : integer; KeepPercentages: boolean = false);
    procedure RefreshTableWithData(ShowZeros: Boolean; aRefreshFdata : Boolean = true;
                                   KeepPercentages: boolean = false);
    procedure UpdateShowHideEnabledState;
    function UnusedRowsShowing: boolean;
    function AllRowsShowing: boolean;
    procedure AddChartCodeToTable(NewCode: String; SetActive: Boolean);
    function CompareCodes(CodeA, CodeB: string): Integer;
    function HasQuantityFormula(RowIndex, ColumnIndex: Integer): Boolean;
    procedure ClearCell(RowIndex, ColumnIndex: Integer);
    function AmountMatchesQuantityFormula(RowIndex, ColIndex: Integer): boolean;
    function BudgetContainsFormulas(): boolean;
    function RowContainsFormulas(RowIndex: Integer): boolean;
    procedure IncreaseCellBy(RowIndex, ColumnIndex: Integer; Percent: double; var ValueTooLarge: Boolean);
    function IncreaseAmount(aAmount: integer; perc: double; var ValueTooLarge: Boolean): integer;

    function HasPercentageFormula(RowIndex: Integer): Boolean;
    procedure UpdatePercentageRows(RefreshTable: boolean);
    procedure DoInvalidateTable;
    procedure DoInvalidateRow(RowNum: integer);
    procedure DoInvalidateColumn(ColNum: integer);

    function  GetAutoCalculateGST: boolean;
    procedure SetAutoCalculateGST(const aValue: boolean);
    procedure RefreshGST;
    procedure UMMainFormModalCommand(var aMsg: TMessage); message UM_MAINFORM_MODALCOMMAND;
    procedure CreateDetailLine(RowNum: integer);
    function ShowFiguresGSTInclusive: boolean;
    procedure EnableOrDisablePercentageInvalidControls(Value: boolean);
    function CalculateGSTFromNetAmount( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte): double;

  public
    { Public declarations }
    property Budget  : TBudget read FBudget write SetBudget;
    property IsClosing : Boolean read FIsClosing write SetIsClosing;
    function FormIsInEditMode: boolean;

    property  AutoCalculateGST: boolean read GetAutoCalculateGST
                write SetAutoCalculateGST;

    procedure ProcessExternalCmd(command: TExternalCmdBudget);
  end;

var
  FClearButton : TRzToolButton;

//------------------------------------------------------------------------------
procedure DoBudgets(tbClear: TRzToolButton = nil);

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
   AccountInfoObj,
   AutoSaveUtils,
   CalculateAccountTotals,
   CodingFormCommands,
   bkDateUtils,
   LogUtil,
   ovcDate,
   OvcConst,
   InfoMoreFrm,
   bkBranding,
   bkHelp,
   CanvasUtils,
   ErrorMoreFrm,
   BKBDIO,
   yesNoDlg,
   GenBudgetDlg,
   WarningMorefrm,
   SignUtils,
   UpdateMF,
   BudgetLookup,
   BudgetPercentageChangeDlg,
   EditBudgetBalanceDlg,
   ClientHomePageFrm,
   bkXPThemes,
   CountryUtils,
   GenUtils,
   Globals,
   stDateSt,
   DateSelectorFme,
   MainFrm,
   AccountLookupFrm,
   StStrS,
   BudgetUnitPriceEntry,
   Math,
   Dialogs,
   ExchangeGainLoss,
   baObj32,
   ExportBudgetDlg,
   ImportBudgetDlg,
   ShellAPI,
   ImportBudgetResultsDlg,
   usageutils,
   BudgetAutoGST,
   glConst;

const
   {status panel constants}
   PANELPROGRESS = 0;
   PANELTEXT     = 1;
   PANELTOTAL    = 2;

   {column constants}
   AccountCol    = 0;
   DescCol       = 1;
   TotalCol      = 2;
   MonthBase     = 2;
   MonthMin      = 3;
   MonthMax      = 14;


   {user commands}
   tcDeleteCell  = ccUserFirst + 1;
   tcCopy        = ccUserFirst + 2;
   tcSplit       = ccUserFirst + 3;
   tcAverage     = ccUserFirst + 4;
   tcSmooth      = ccUserFirst + 5;
   tcZero        = ccUserFirst + 6;
   tcGenerate    = ccUserFirst + 7;
   tcDeleteLine  = ccUserFirst + 8;
   tcIncDec      = ccUserFirst + 9;
   tcEnterBal    = ccUserFirst + 10;

const
   UnitName = 'BUDGETFRM';
var
   DebugMe       : boolean = false;


// Redraw main form on minimize
//------------------------------------------------------------------------------
procedure TfrmBudget.WMSysCommand(var msg: TWMSyscommand);
begin
  if ((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE) then
    exit
  else
    inherited;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormCreate(Sender: TObject);
var
  i: Integer;
begin
   //Use a copy of the client chart that can be sorted
   fShowZeros := true;
   FChart := TCustomSortChart.Create(nil);
   FChart.CopyChart(MyClient.clChart);
   if UseXlonSort then
      FChart.Sort(XlonCompare);

   lblDetails.Font.Name := Font.Name;
   EdtName.Font.Name := Font.Name;
   lblName.Font.Name := Font.Name;
   lblStart.Font.Name := Font.Name;
   lblAllexclude.Font.Name := Font.Name;
   lblReminderNote.Font.Name := Font.Name;

   bkBranding.StyleBudgetStartText(lblStart);
   bkBranding.StyleBudgetAllExclusiveText(lblAllExclude);
   bkBranding.StyleBudgetReminderNote(lblReminderNote);

   bkXPThemes.ThemeForm( Self);
   DataAssigned := false;
   InitTable;
   SetupHelp;
   With lblAllExclude do Caption := Localise( MyClient.clFields.clCountry, Caption );

   ColAccount.MaxLength := MaxBk5CodeLen;
   //resize the account col so that longest account code fits
   tblBudget.Columns[ AccountCol ].Width := CalcAcctColWidth( tblBudget.Canvas, tblBudget.Font, 80);
   // load col widths
   for i := 0 to Pred(tblBudget.ColCount) do
   begin
     if MyClient.clFields.clBudget_Column_Width[i] <> 0 then
       tblBudget.Columns[i].Width := MyClient.clFields.clBudget_Column_Width[i];
   end;
   //scrolling btwn budgets
   tblBudget.OnMouseWheel := BkMouseWheelHandler;
   tblBudget.OnVSThumbChanged := tblBudgetVSThumbChanged;
   FIsClosing := false;

  FHint := THintWindow.Create( Self );
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Font <> '') then
     StrToFont(AdminSystem.fdFields.fdCoding_Font,FHint.Canvas.Font)
  else if (not Assigned(AdminSystem)) and (INI_Coding_Font <> '') then
     StrToFont(INI_Coding_Font,FHint.Canvas.Font)
  else begin
     FHint.Canvas.Font.Name := 'Courier';
     FHint.Canvas.Font.Size := 5;
  end;

  // Removing the border from rgGST
  SetWindowRgn(rgGST.Handle, CreateREctRgn(7, 14, rgGST.Width - 2, rgGST.Height - 2), True);

  EnableOrDisablePercentageInvalidControls(True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.SetupHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Chapter_9_Budgets;

   //Components
   lblName.Hint :=
   //edtName.Hint :=
      'Click to edit the Budget Name|'+
      'Click here to edit the name of this Budget';
end;

//------------------------------------------------------------------------------
function TfrmBudget.RowNumOK(RowNum : integer): boolean;
begin
   result := (1 <= RowNum)
          and (RowNum <= tblBudget.RowLimit-1)
          and DataAssigned;
end;

//------------------------------------------------------------------------------
function TfrmBudget.RowDataOK(RowNum:integer;Routine:string):boolean;
{important routine - verifies that the rownum is a valid row        }
{then verifies that the currently loaded row is the same as this row}
{
{this is to ensure that we are editing that data the we think we are}
{especially important for any routine that writes data              }
var
  NumberMatch: boolean;
  Msg: string;
begin
  result      := false;
  if RowNumOK(RowNum) then begin
     NumberMatch := (CurrentRow = RowNum);
     if NumberMatch then
        result := true
     else begin
        Msg := Routine+' RowDataOK Failure:  ';
        if not NumberMatch then
           msg := msg + 'RowNum = '+inttostr(RowNum)+' CurrentRow= '+inttostr(CurrentRow)+' ';
        HelpfulErrorMsg(msg,0);
     end;
  end else begin
     Msg := Format('RowNumOK failure: RowNum = %d',[RowNum]);
     HelpfulErrorMsg(msg,0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ReadCellforPaint(RowNum, ColNum: Integer; var Data: Pointer);
var
  ShowGST: boolean;
begin
  Data := nil;

  {validate}
  if RowNumOK(RowNum) then begin
    {get data}
    case ColNum of
      AccountCol : Data := @FData[RowNum-1].bAccount;

      DescCol :    Data := @FData[RowNum-1].bDesc;

      MonthMin..MonthMax :
        begin
           if FData[RowNum-1].bIsPosting then
              Data := @FData[RowNum-1].bAmounts[ColNum-MonthBase]
           else if FData[RowNum-1].bAmounts[ColNum-MonthBase] <> 0 then
              Data := @FData[RowNum-1].bAmounts[ColNum-MonthBase];
        end;
      TotalCol :
        begin
          if ShowFiguresGSTInclusive then
            ShowGST := not FData[RowNum-1].bIsGSTAccountCode
          else
            ShowGST := FData[RowNum-1].bIsGSTAccountCode;
          FData[RowNum-1].bTotal := GetTotalForRow(RowNum, False);
          if ShowGST then          
            FData[RowNum-1].bTotalWithGST := GetTotalForRow(RowNum, True);
          if FData[RowNum-1].bIsPosting then
          begin
            if ShowGST then            
              Data := @FData[RowNum-1].bTotalWithGST
            else
              Data := @FData[RowNum-1].bTotal;
          end else
            Data := nil;
        end;
    end;{case}
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.GetTotalForRow(RowNum: Integer; IncludeGST: boolean): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := MonthMin to MonthMax do
  begin
    if IncludeGST then
    begin
      Result := Result + FData[RowNum - 1].bGstAmounts[i-MonthBase];
    end else
      Result := Result + FData[RowNum - 1].bAmounts[i-MonthBase];
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ReadCellforEdit(RowNum, ColNum: Integer; var Data: Pointer);
{read the data for an editable cell into the current record variables}
begin
 Data := nil;

 {validate}
 if RowDataOK(RowNum,'DReadForEdit') then
 begin  {get data}
    case ColNum of
      MonthMin..MonthMax :
      begin
         if ShowFiguresGSTInclusive then
           eAmounts[ColNum-MonthBase] := FData[RowNum-1].bGSTAmounts[ColNum-MonthBase]
         else
           eAmounts[ColNum-MonthBase] := FData[RowNum-1].bAmounts[ColNum-MonthBase];
         data := @eAmounts[ColNum-MonthBase];
      end;
    else
      begin
         HelpfulErrorMsg('ReadCellForEdit - invalid cell',0);
         data := nil;
      end;
    end;{case}
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.WriteCell(RowNum, ColNum: Integer; var Data: Pointer);
{data is pointed to the variables which hold info for the current record}
begin
  data := nil;

 {validate}
 if RowDataOK(RowNum,'DWriteCell') then
 begin  {get data}
    case ColNum of
           MonthMin..MonthMax :
              data := @eAmounts[colNum-MonthBase];
    end;{case}
   end  ;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  data := nil;
  if not DataAssigned then exit;

  case Purpose of
    cdpForPaint:
            ReadCellforPaint(RowNum,ColNum,Data);

    cdpForEdit:
            ReadCellforEdit(RowNum,ColNum,Data);

    cdpForSave :
            WriteCell(RowNum,ColNum,Data);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
  if ColNum <= TotalCol then ColNum := TotalCol+1;

  //see if we are currently at left most col and press cc left
  if ( tblBudget.ActiveCol = MonthMin) and ( Command = ccLeft) then begin
     tblBudget.LeftCol := 0;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetGetCellAttributes(Sender: TObject;
  RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if ( ColNum < tblBudget.LockedCols) and
     ( CellAttr.caColor = tblBudget.Colors.Locked) and
     ( RowNum > 0) then
  begin
    CellAttr.caColor := tblBudget.Color;
  end;

  if (CellAttr.caColor = tblBudget.Color) then
    if (RowNum >= tblBudget.LockedRows) and (Odd(Rownum)) then CellAttr.caColor := AltLineColor;

  if DataAssigned and RowNumOK(RowNum) and (not (FData[RowNum-1].bIsPosting)) then
     CellAttr.caFont.Style := [fsBold];
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.InitTable;
begin
   with tblBudget.Controller.EntryCommands do begin
     {remove F2 functionallity}
     DeleteCommand('Grid',VK_F2,0,0,0);
     DeleteCommand('Grid',VK_DELETE,0,0,0);

     {add our commands}
     AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
     AddCommand('Grid',VK_DELETE,0,0,0,tcDeleteCell);

     AddCommand('Grid',71,$04,0,0,tcGenerate);   {CTRL+G}
     AddCommand('Grid',75,$04,0,0,tcCopy);       {CTRL+K}
     AddCommand('Grid',84,$04,0,0,tcSplit);      {CTRL+T}
     AddCommand('Grid',65,$04,0,0,tcAverage);    {CTRL+A}
     AddCommand('Grid',77,$04,0,0,tcSmooth);     {CTRL+M}
     AddCommand('Grid',79,$04,0,0,tcZero);       {CTRL+O}
     AddCommand('Grid',VK_MULTIPLY,0,0,0,tcIncDec);   {* - NumPad}
     AddCommand('Grid',66,$04,0,0,tcEnterBal);    {CTRL+B}

     AddCommand('Grid',$2E,$04,0,0,tcDeleteLine); {ctrl+delete}
  end;

   tblBudget.RowLimit := 5;
   tblBudget.CommandOnEnter := ccRight;

   AltLineColor := BKCOLOR_CREAM
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.lblnameClick(Sender: TObject);
begin
   EdtName.Height := lblName.ClientHeight;
   lblname.Hide;
   EdtName.Show;
   EdtName.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetUserCommand(Sender: TObject;
  Command: Word);
begin
   case Command of

      tcDeleteCell: begin
                      if EditMode then exit;
                      Keybd_event(VK_SPACE,0,0,0);
                      Keybd_event(VK_BACK ,0,0,0);
                      Keybd_event(VK_F6   ,0,0,0);
                    end;

      tcCopy :
         DoCopy;
      tcZero :
         DoClearValues(clrAll);
      tcSmooth :
         DoSmooth;
      tcSplit  :
         DoSplit;
      tcAverage :
         DoAverage;
      tcGenerate :
         DoGenerate;
      tcDeleteLine :
         DoDeleteLine;
      tcIncDec :
         DoPercentageChange;
      tcEnterBal :
         DoEnterBalance;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  EditMode := true;

  if not RowDataOK(RowNum,'BBeginEdit')then
     exit;

  AllowIt := FData[RowNum-1].bIsPosting and (FData[RowNum-1].PercentAccount = '');

  // Allow editing of GST, only when we're not automatically calculating it
  if AutoCalculateGST and FData[RowNum-1].bIsGSTAccountCode then
    AllowIt := false;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
   EditMode := false;

   if RowDataOK(RowNum,'BEndEdit') then
        EndEditRow(RowNum,ColNum, AllowIt);
end;

//------------------------------------------------------------------------------
function TfrmBudget.AmountMatchesQuantityFormula(RowIndex, ColIndex: Integer): boolean;
var
  Quantity: Money;
  UnitPrice: Money;
  CalculatedAmount : Money;
  Amount: Integer;
begin
  Quantity := FData[RowIndex].bQuantitys[ColIndex];
  UnitPrice := FData[RowIndex].bUnitPrices[ColIndex];
  CalculatedAmount := TfrmBudgetUnitPriceEntry.CalculateTotal(UnitPrice, Quantity);
  Amount := FData[RowIndex].bAmounts[ColIndex];
  Result := CalculatedAmount = Amount;
end;

// Updating rows with percentages for cases where the
// rows they derive their values from may have changed
procedure TfrmBudget.UpdatePercentageRows(RefreshTable: boolean);
var
  i       : integer;
  AtLeastOneRowUpdated: boolean;
begin
  AtLeastOneRowUpdated := False;
  for i := 0 to High(FData) do
  begin
    if HasPercentageFormula(i) then
    begin
      DoPercentageCalculation(i);
      AtLeastOneRowUpdated := True;
    end;
  end;
  if AtLeastOneRowUpdated and RefreshTable then
    RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
{data for the record has been saved into the variables.  should now save into database}
{note this will be triggered for each cell save}

{for edits that affect other cells those cells will be updated from here also}
{saves direct edits!}
var
  GSTAmount: double;
  dtMonth: TStDate;
  MoAmount: Money;
  RawAmount: Money;
  pAccount: pAccount_Rec;
  GST_Class: byte;
begin
  if RowDataOK(RowNum,'BDoneEdit') then
    begin
       if Assigned(FData[RowNum - 1].bDetailLine) then
       begin
         FData[RowNum - 1].bDetailLine.bdPercent_Account := FData[RowNum - 1].PercentAccount;
         FData[RowNum - 1].bDetailLine.bdPercentage := FData[RowNum - 1].Percentage;
       end;
       case ColNum of
         MonthMin..MonthMax :
         begin
            {write this cell to data structure, also update the associated}
            {budget line for this cell}
            if ShowFiguresGSTInclusive then
            begin
              dtMonth := FBudget.buFields.buStart_Date;
              moAmount := eAmounts[ColNum-MonthBase];
              pAccount := MyClient.clChart.FindCode(FData[RowNum-1].bAccount);
              if not assigned(pAccount) then
                exit;
              GST_Class := pAccount.chGST_Class;
              GSTAmount := CalculateGSTFromNetAmount(MyClient, dtMonth, moAmount, GST_Class);
              FData[RowNum-1].bAmounts[ColNum-MonthBase] := Round(moAmount - GSTAmount);
              // Need to recalculate the shown GST inclusive amount so that it's the stored raw amount + GST, which may
              // differ slightly from the GST inclusive amount entered by the user
              RawAmount := FData[RowNum-1].bAmounts[ColNum-MonthBase];
              FData[RowNum-1].bGSTAmounts[ColNum-MonthBase] :=
                DoRoundUp(RawAmount + CalculateGSTFromNett(MyClient, dtMonth, RawAmount, GST_Class));
            end else
              FData[RowNum-1].bAmounts[ColNum-MonthBase] := eAmounts[ColNum-MonthBase];
            if (eAmounts[ColNum - MonthBase] = 0)
               or not AmountMatchesQuantityFormula(RowNum - 1, ColNum - MonthBase)
               or HasPercentageFormula(RowNum - 1) then
            begin
              FData[RowNum - 1].bQuantitys[ColNum - MonthBase] := 0;
              FData[RowNum - 1].bUnitPrices[ColNum - MonthBase] := 0;
            end;
            CreateDetailLine(RowNum-1);
            FData[RowNum-1].bDetailLine.bdBudget[ColNum-MonthBase] := FData[RowNum-1].bAmounts[ColNum-MonthBase];
            FData[RowNum-1].bDetailLine.bdQty_Budget[ColNum - MonthBase] := FData[RowNum - 1].bQuantitys[ColNum - MonthBase];
            FData[RowNum-1].bDetailLine.bdEach_Budget[ColNum - MonthBase] := FData[RowNum - 1].bUnitPrices[ColNum - MonthBase];
         end;
       end;

       // Refresh the GST cells
       RefreshGST;
       RefreshTableWithData(fShowZeros, True, True);
       UpdatePercentageRows(True);
  end; {if row ok}
  UpdateShowHideEnabledState;
end;

function TfrmBudget.CalculateGSTFromNetAmount( aClient : TClientObj; ADate : LongInt; Amount : Money; ClassNo : Byte): double;
const
   ThisMethodName = 'CalculateGSTFromNetAmount';
VAR
   TaxAmtExt     : Extended;
   TaxRate       : Extended;
   WhichRate     : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := 0;
   WhichRate := WhichGSTRateApplies( aClient, ADate );
   If ( ClassNo in [ 1..MAX_GST_CLASS ] ) and ( WhichRate in [ 1..MAX_GST_CLASS_RATES ] ) then
   Begin
      If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 1000000 ) then
      Begin { Special Case - ALL GST }
         Result := Amount;
         exit;
      end;
      If ( aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] = 0 ) then exit;

      TaxRate     := aClient.clFields.clGST_Rates[ ClassNo, WhichRate ] / 1000000.0; { 1250 -> 0.1250 }
      // We have passed in the amount including tax, this gives us the tax component of that
      // amount. Eg. if you have 15% tax and you pass in $115, this should return $100,
      // because $100 + 15% tax = $115
      TaxAmtExt   := Amount - (Amount / (1 + TaxRate));
      Result := TaxAmtExt;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetEnteringRow(Sender: TObject;
  RowNum: Integer);
var
  Code : string;
begin
  if not dataAssigned then exit;

  {get current values for active row}
  if (tblBudget.activeRow = RowNum) then
     ReadRow(RowNum);

  {update status info}
  stsDissect.Panels[PANELPROGRESS].Text := inttostr(tblBudget.ActiveRow) +' of ' + inttostr(tblBudget.Rowlimit-1);

  {update account info}
  Code := '<'+ trim(FData[CurrentRow-1].bAccount)+'> '+FData[CurrentRow-1].bDesc;
  stsDissect.Panels[PANELTEXT].text := Code;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ReadRow(RowNum : integer);
var
 i : integer;
begin
  CurrentRow := RowNum;
  if RowNumOK(RowNum) then
     for i := 1 to 12 do
       eAmounts[i] := FData[RowNum-1].bAmounts[i];
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.Restoredefaultcolumnwidths1Click(Sender: TObject);
var
  i: Integer;
begin
  tblBudget.Columns[ AccountCol ].Width := CalcAcctColWidth( tblBudget.Canvas, tblBudget.Font, 80);
  tblBudget.Columns[ DescCol ].Width := 179;
  tblBudget.Columns[ TotalCol ].Width := 90;
  for i := MonthMin to MonthMax do
    tblBudget.Columns[i].Width := 90;
end;

procedure TfrmBudget.rgGSTClick(Sender: TObject);
begin
  if ShowFiguresGSTInclusive then
    lblAllExclude.Caption := 'All figures include GST'
  else
    lblAllExclude.Caption := 'All figures exclude GST';

  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormShow(Sender: TObject);
begin
   tblBudget.setfocus;
   tblBudget.ActiveRow := 1;
   tblBudget.ActiveCol := TotalCol + 1;
   ExtraTitleBar.GradientColorStart := bkbranding.TobBarStartColor;
   ExtraTitleBar.GradientColorStop  := bkbranding.TopBarStopColor;
   lblDetails.Font.Color := bkBranding.TopTitleColor;
   lblName.Font.Color := bkBranding.TopTitleColor;

   mniLockLeftmostClick(Sender);

   //ExtraTitleBar.Color    := bkBranding.HeaderBackgroundColor;
   //edtName.Color          := bkBranding.HeaderBackgroundColor;
end;

// When the currently selected cell is on a row which is a percentage of
// another row, we want to disable some functions
procedure TfrmBudget.EnableOrDisablePercentageInvalidControls(Value: boolean);
begin
  frmMain.tbAverage.Enabled := Value;
  frmMain.tbCopy.Enabled    := Value;
  frmMain.tbSplit.Enabled   := Value;
  mniAverage.Enabled        := Value;
  mniCopy.Enabled           := Value;
  mniSplit.Enabled          := Value;
  mniEnterQuantity.Enabled  := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetActiveCellChanged(Sender: TObject;
  RowNum, ColNum: Integer);
var
  HasPercentage: boolean;
begin
  if Assigned(FData) then
  begin
    HasPercentage             := HasPercentageFormula(RowNum-1);
    EnableOrDisablePercentageInvalidControls(not HasPercentage);
  end;

  HideCustomHint; // Changing cells, so Hide the Hint window
   //ensure that current row data is correct
   if (RowNum <> CurrentRow) then
      ReadRow(RowNum);

   //Hint Msgs
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      ColMonth1.SendKeyToTable(Msg);
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  EnableOrDisablePercentageInvalidControls(True);
  Budget.buFields.buIs_Inclusive := ShowFiguresGSTInclusive;

  UpdateAllLines;

  FIsClosing := true;

  // save col widths
  for i := 0 to Pred(tblBudget.ColCount) do
    MyClient.clFields.clBudget_Column_Width[i] := tblBudget.Columns[i].Width;

  Action := caFree;
  DoClosingBudgetform;
  RefreshHomepage ([HPR_Coding], Caption);
end;

//------------------------------------------------------------------------------
procedure TFrmBudget.RefreshFData(ShowZeros: boolean; var aDataIndex : integer; KeepPercentages: boolean);
var
  Account : pAccount_Rec;
  AccountIndex : Integer;
  pBudgetRec: pBudget_Detail_Rec;
  MonthIndex: Integer;
  HasData: Boolean;
  OldData: TBudgetData;
  i: integer;
begin
  if KeepPercentages then
    // In this case, the user has toggled the GST Inclusive/Exclusive radio buttons or pressed Hide Unused.
    // We haven't yet saved any new or modified percentages, so these will be kept safe in OldData and
    // copied back in rather than getting the percentages from the saved budget
    OldData := FData;
  {now load all the data values}
  FData := nil;
  DataAssigned := false;
  SetLength(FData, FChart.ItemCount);   //allocate enough for current chart

  aDataIndex := 0;
  for AccountIndex := 0 to FChart.ITemCount-1 do with FChart do
  begin
    Account := Account_At(AccountIndex);
    pBudgetRec := Budget.buDetail.FindLineByCode(Account.chAccount_Code);
    if not ShowZeros and not Assigned(pBudgetRec) then
    begin
      // GST control rows need to stay visible
      if AutoCalculateGST and IsGSTAccountCode(MyClient, Account.chAccount_Code) then
        // Continue with the for loop
      else
        Continue;
    end;

    //see if the item has data
    if Assigned(pBudgetRec) and not ShowZeros then
    begin
      HasData := false;
      for MonthIndex := 1 to 12 do
      begin
        if (pBudgetRec.bdBudget[MonthIndex] <> 0) or (pBudgetRec.bdPercent_Account <> '') then
        begin
          HasData := true;
          break;
        end;
      end;
      // GST control rows need to stay visible
      if AutoCalculateGST and IsGSTAccountCode(MyClient, Account.chAccount_Code) then
        HasData := true;
      if not HasData then
        Continue;
    end;

    FData[aDataIndex].bAccount := Account.chAccount_Code;
    FData[aDataIndex].bDesc    := Account.chAccount_Description;
    FData[aDataIndex].bIsPosting := Account.chPosting_Allowed;

    if Assigned(pBudgetRec) then
    begin
      if KeepPercentages then
      begin
        for i := Low(OldData) to High(OldData) do
        begin
          if (FData[aDataIndex].bAccount = OldData[i].bAccount) then
          begin
            FData[aDataIndex].PercentAccount := OldData[i].PercentAccount;
            FData[aDataIndex].Percentage := OldData[i].Percentage;
            break;
          end;
        end;
      end else
      begin
        FData[aDataIndex].PercentAccount := pBudgetRec.bdPercent_Account;
        FData[aDataIndex].Percentage := pBudgetRec.bdPercentage;
      end;
    end;
    FData[aDataIndex].bIsGSTAccountCode := IsGSTAccountCode(MyClient, FData[aDataIndex].bAccount);
    FData[aDataIndex].bDetailLine := pBudgetRec;

    for MonthIndex := 1 to 12 do
    begin
      if Assigned(pBudgetRec) and not FData[aDataIndex].bIsGSTAccountCode then
      begin
        FData[aDataIndex].bAmounts[MonthIndex] := Round(FData[aDataIndex].bDetailLine.bdBudget[MonthIndex]);
        FData[aDataIndex].bQuantitys[MonthIndex] := FData[aDataIndex].bDetailLine.bdQty_Budget[MonthIndex];
        FData[aDataIndex].bUnitPrices[MonthIndex] := FData[aDataIndex].bDetailLine.bdEach_Budget[MonthIndex];
      end
      else
      begin
        FData[aDataIndex].bAmounts[MonthIndex] := 0;
        FData[aDataIndex].bQuantitys[MonthIndex] := 0;
        FData[aDataIndex].bUnitPrices[MonthIndex] := 0;
      end;
    end;        
    Inc(aDataIndex);
  end;

  RefreshGST;

  if (aDataIndex = 0) and not ShowZeros then
  begin
    HelpfulInfoMsg('There are no used entries. '+SHORTAPPNAME+ ' will display all entries.', 0);
    RefreshTableWithData(true);
    Exit;
  end;

  SetLength(FData, aDataIndex);
end;

//------------------------------------------------------------------------------
procedure TFrmBudget.RefreshTableWithData(ShowZeros: Boolean; aRefreshFdata : Boolean; KeepPercentages: boolean);
var
  DataIndex : integer;
begin
  fShowZeros := ShowZeros;

  if aRefreshFdata then
    RefreshFData(ShowZeros, DataIndex, KeepPercentages);

  tblBudget.RowLimit := DataIndex + 1;
  DataAssigned := true;

  tblBudget.AllowRedraw := false;
  DoInvalidateTable;
  tblBudget.AllowRedraw := true;

  UpdateShowHideEnabledState;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.SetBudget(const Value: TBudget);
var
  i : integer;
  ColDate : integer;
begin
  FBudget := Value;

  if FChart.ItemCount = 0 then
  begin
    HelpfulWarningMsg('There are no chart codes allocated for this client.  Cannot edit a budget.',0);
    FBudget := nil;
    exit;
  end;

  RefreshTableWithData(true);
  {update column lables}
  for i := 0 to 11 do
  begin
     ColDate := IncDate(Budget.buFields.buStart_Date,0,i,0);
     tblHeader.Headings[MonthMin+i] := StDateToDateString('nnn yy',ColDate,true);
  end;

  {update form header}
  caption := 'Edit Budget '+Budget.buFields.buName;
  edtName.text := Budget.buFields.buName;
  lblName.Caption := Budget.buFields.buName;
  lblStart.caption   := 'Starts '+bkDate2Str(Budget.buFields.buStart_Date);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.UpdateLine(index: integer; CopyPercentages: boolean);
{syncronizes the editor lines and the lines stored in the budget}
{adds, edits or deletes budget line where necessary}
var
  DetailLine    : pBudget_Detail_Rec;
  HasData       : boolean;
  i             : integer;
begin
  if not DataAssigned then exit;
  if not ((index >= Low(FData)) and (index <= High(Fdata))) then exit;

  {check if any of the values are non zero, or if they are valued as a % of another account code }
  HasData := false;
  for i := 1 to 12 do
    if (FData[index].bAmounts[i] <> 0) or HasPercentageFormula(index) then
    begin
      HasData := true;
      break;
    end;

  if HasData then
  begin
    {see if there is a current budget line attached, if not create one}
    if not Assigned(FData[index].bDetailLine) then
    begin
       DetailLine := New_Budget_Detail_Rec;
       DetailLine.bdAccount_Code := FData[index].bAccount;
       Budget.buDetail.Insert(DetailLine);
       FData[index].bDetailLine := DetailLine;
    end;

    {update data into budget line}
    if CopyPercentages then
    begin
      FData[index].bDetailLine.bdPercent_Account := FData[index].PercentAccount;
      FData[index].bDetailLine.bdPercentage := FData[index].Percentage;
    end else
    begin
      FData[index].bDetailLine.bdPercent_Account := '';
      FData[index].bDetailLine.bdPercentage := 0;
    end;

    for i := 1 to 12 do
    begin
      FData[index].bDetailLine.bdBudget[i] := FData[index].bAmounts[i];
      FData[index].bDetailLine.bdQty_Budget[i] := FData[index].bQuantitys[i];
      FData[index].bDetailLine.bdEach_Budget[i] := FData[index].bUnitPrices[i];
    end;
  end
  else
  begin
    {all values are zero, so remove the budget line if there is one}
    DetailLine := FData[index].bDetailLine;

    if Assigned(DetailLine) then
    begin
       Budget.buDetail.DelFreeItem(DetailLine);
       FData[index].bDetailLine := nil;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.UpdateShowHideEnabledState;
var
  ShowEnabled: boolean;
  HideEnabled: boolean;
begin
  ShowEnabled := not AllRowsShowing;
  frmMain.tbBudgetShow.Enabled := ShowEnabled;
  mniShowAll.Enabled := ShowEnabled;

  HideEnabled := UnusedRowsShowing;
  frmMain.tbBudgetHide.Enabled := HideEnabled;
  mniHideUnused.Enabled := HideEnabled;
end;

//------------------------------------------------------------------------------
function TfrmBudget.AllRowsShowing: boolean;
begin
  Result := Length(FData) = FChart.ItemCount;
end;

//------------------------------------------------------------------------------
function TfrmBudget.UnusedRowsShowing: boolean;
var
  I: Integer;
  j: Integer;
  DataFound: Boolean;
begin
  //returns true if there are any rows with only zeros
  Result := false;
  for I := 0 to High(FData) do
  begin
    DataFound := false;
    for j := 1 to 12 do
    begin
      if FData[I].bAmounts[j] <> 0 then
      begin
        DataFound := true;
        Break;
      end;
    end;
    if not DataFound then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.UpdateAllLines;
var i : integer;
begin
  for i := Low(FData) to High(FData) do
     UpdateLine(i);
  UpdateShowHideEnabledState;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
{interupts quickkeys for table so that cell can be switched out of editmode}

  //----------------------------------------------------------------------------
  Procedure SetVKeyState( vkey: Byte; down: Boolean );
  Var
    keys: TKeyboardState;
  Begin
    getKeyboardstate( keys );
    If down then
      keys[vkey] := keys[vkey] or $80
    Else
      keys[vkey] := keys[vkey] and $7F;
    setKeyboardState( keys );
  End;

begin
   if EditMode and (GetKeyState(VK_CONTROL) < 0) then
   begin
      if msg.CharCode in [65,66,71,75,77,79,84] then
      begin
         handled := true;
         SetVKeyState(VK_CONTROL,false);  {clear the control key}
      end;

      case msg.CharCode of
         65 : DoAverage;                  //A
         66 : DoEnterBalance;             //B
         71 : DoGenerate;                 //G
         75 : DoCopy;                     //K
         77 : DoSmooth;                   //M
         79 : DoClearValues(clrALL);      //O
         84 : DoSplit;                    //T
      end; {case}
   end
   else if GetKeyState(VK_MENU) < 0 then //alt
   begin
     if msg.CharCode in [65, 90] then
     begin
       handled := true;
       SetVKeyState(VK_MENU, false);
     end;

     case msg.CharCode of 
        65: DoShowAll;
        90: DoHideUnused;
     end;
   end
   else if msg.CharCode = VK_F2 then
      DoChartLookup
   else if msg.CharCode in [VK_MULTIPLY,VK_OEM_PLUS,VK_ADD] then
   begin
     handled := true;
     case msg.CharCode of
       VK_MULTIPLY: DoPercentageChange;
       VK_OEM_PLUS: DoUnitPriceEntry;  // =
       VK_ADD:
       begin
         DoPercentageCalculation;  // +
         RefreshTableWithData(fShowZeros, True, True);
       end;
     end;
   end;
end;

//------------------------------------------------------------------------------
// Popup Clicks
procedure TfrmBudget.mniChartLookupClick(Sender: TObject);
begin
  DoChartLookup;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniClearClick(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniClearColumnClick(Sender: TObject);
begin
  DoClearValues(clrColumn);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniClearRowClick(Sender: TObject);
begin
  DoClearValues(clrRow);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniCopyClick(Sender: TObject);
begin
   DoCopy;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBudget.mniSplitClick(Sender: TObject);
begin
   DoSplit;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniAverageClick(Sender: TObject);
begin
   DoAverage;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniGenerateClick(Sender: TObject);
begin
   DoGenerate;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniHideUnusedClick(Sender: TObject);
begin
  DoHideUnused;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniShowAllClick(Sender: TObject);
begin
  DoShowAll;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniSmoothClick(Sender: TObject);
begin
   DoSmooth;
end;

//------------------------------------------------------------------------------
Procedure TfrmBudget.DoCopy;
{updates current line}
Var
  i           : Word;
  currField   : integer;
  Amount      : integer;
  Quantity    : Money;
  UnitPrice   : Money;
Begin
  if not DataAssigned then
     exit;

  if HasPercentageFormula(CurrentRow - 1) then         
  begin
    HelpfulErrorMsg('You cannot use copy on a row which derives its values as a percentage ' +
                    'of another row. You must first clear the percentage.', 0);
    exit;
  end;

  currField := tblBudget.ActiveCol;
  if not (CurrField in  [MonthMin .. MonthMax]) then
     exit;

  CheckEditMode;

  {copy current value accross all remaining cols for this line}
  Amount := eAmounts[CurrField-MonthBase];
  Quantity := FData[CurrentRow - 1].bQuantitys[CurrField - MonthBase];
  UnitPrice := FData[CurrentRow - 1].bUnitPrices[CurrField - MonthBase];

  for i := Succ(CurrField-MonthBase) to (MonthMax-MonthBase) do   {start from next cell}
  begin
     FData[CurrentRow - 1].bAmounts[i] := Amount;
     FData[CurrentRow - 1].bQuantitys[i] := Quantity;
     FData[CurrentRow - 1].bUnitPrices[i] := UnitPrice;
  end;

  ReadRow(currentRow);  {reload current edit values}
  Updateline(CurrentRow - 1);

  RefreshTableWithData(fShowZeros, True, True);
  {redraw line}
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoChartLookup;
var
  Code: String;
  I: Integer;
begin
  Code := FData[tblBudget.ActiveRow - 1].bAccount;
  if PickAccount(Code) then
  begin
    //see if it's already shown on the grid
    for I := 0 to High(FData) do
    begin
      if FData[I].bAccount = Code then
      begin
        //found it, scroll down
        tblBudget.SetActiveCell(I + 1, tblBudget.ActiveCol);
        Exit;
      end;
    end;
    //not found, add it
    AddChartCodeToTable(Code, True);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.AddChartCodeToTable(NewCode: String; SetActive: Boolean);
var
  I: Integer;
  RowCode: String;
  AccountRec: pAccount_Rec;
  pBudgetRec: pBudget_Detail_Rec;
  MonthIndex: Integer;
  CorrectRow: Boolean;
begin
  //need to add it to the right position, so can't just add it to the end
  //so increase length of FData, move all data that should be after it down one
  //insert new data and then refresh table
  SetLength(FData, Length(FData) + 1);
  I := Length(FData) - 1;
  //Start from the bottom
  while I >= 0 do
  begin
    //see if the row above this row should be after the NewCode (if it should be we're in the right place)
    if I > 0 then
    begin
      RowCode := FData[I-1].bAccount;
      CorrectRow :=  CompareCodes(RowCode, NewCode) < 0;
    end
    else
      CorrectRow := True; //first row, so it must fit here
      
    if CorrectRow then
    begin
      //insert new code here
      //Find Account
      AccountRec := FChart.FindCode(NewCode);
      if AccountRec = nil then
        Exit; //invalid account code selected somehow
      FData[i].bAccount := NewCode;
      FData[i].bDesc := AccountRec.chAccount_Description;
      FData[i].bIsPosting := AccountRec.chPosting_Allowed;
      FData[i].bIsGSTAccountCode :=
        IsGSTAccountCode(MyClient, FData[i].bAccount);

      pBudgetRec := Budget.buDetail.FindLineByCode(AccountRec.chAccount_Code);
      FData[i].bDetailLine := pBudgetRec;
      if Assigned(pBudgetRec) then
      begin
        FData[i].PercentAccount := pBudgetRec.bdPercent_Account;
        FData[i].Percentage := pBudgetRec.bdPercentage;
      end;
      for MonthIndex := 1 to 12 do
      begin
        if Assigned(pBudgetRec) then
        begin
          FData[I].bAmounts[MonthIndex] := Round(FData[I].bDetailLine.bdBudget[MonthIndex]);
          FData[I].bQuantitys[MonthIndex] := FData[I].bDetailLine.bdQty_Budget[MonthIndex];
          FData[I].bUnitPrices[MonthIndex] := FData[I].bDetailLine.bdEach_Budget[MonthIndex];
        end
        else
        begin
          FData[I].bAmounts[MonthIndex] := 0;
          FData[I].bQuantitys[MonthIndex] := 0;
          FData[I].bUnitPrices[MonthIndex] := 0;
        end;
      end;
      Break;
    end
    else
    begin
      FData[I] := FData[I-1];
      Dec(I);
    end;
  end;

  tblBudget.RowLimit := Length(FData) + 1;
  DoInvalidateTable;  {will force reload of current line}
  tblBudget.AllowRedraw := true;
  if SetActive then
    tblBudget.SetActiveCell(I + 1, tblBudget.ActiveCol);
  UpdateShowHideEnabledState;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ColMonthOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
  const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
const
  margin = 4;
var
  D: Double;
  HasPercentage: boolean;
  IsGSTControlGroup: boolean;
  R: TRect;
  s : String;

  procedure DrawTriangle(TriColor: integer);
  begin
    TableCanvas.Brush.Color := TriColor;
    TableCanvas.Pen.Color := TriColor;
    // Draw a triangle in the top right
    TableCanvas.Polygon( [Point( CellRect.Right - Margin, CellRect.Top),
                      Point( CellRect.Right, CellRect.Top),
                      Point( CellRect.Right, CellRect.Top + Margin)]);
  end;
begin
  if not assigned(FData) then Exit;

  HasPercentage := HasPercentageFormula(RowNum - 1);
  IsGSTControlGroup := IsGSTAccountCode(MyClient, FData[RowNum-1].bAccount);

  DoneIt := true;
  //draw text
  R := CellRect;
  if not FData[RowNum-1].bIsPosting then
    S := ''
  else
  begin
    if FData[RowNum - 1].ShowGstAmounts or ShowFiguresGSTInclusive then
      D := FData[RowNum - 1].bGstAmounts[ColNum - 2]
    else
      D := FData[RowNum - 1].bAmounts[ColNum - 2];

    S := Format('%.0n',[D]);
  end;

  TableCanvas.Font := CellAttr.caFont;
  if HasPercentage or (IsGSTControlGroup and (ShowFiguresGSTInclusive or AutoCalculateGST)) then
    // Gray to show that this row is disabled because:
    // * Users may not directly modify cells which derive their value as a % of another row,
    //   they must first clear the % that has been set.
    // or
    // * The account code for this row is a GST Control Group, and the table is showing GST
    //   inclusive figures. There is no need to show a separate GST total when the figures
    //   are already GST inclusive.
    TableCanvas.Brush.Color := clSilver
  else
    TableCanvas.Brush.Color := CellAttr.caColor;
  TableCanvas.Font.Color  := CellAttr.caFontColor;
  TableCanvas.FillRect(R);
  if IsGSTControlGroup and ShowFiguresGSTInclusive then
    S := '0'; // Don't print values for GST control groups if the GST is already included in the other figures
  DrawText(TableCanvas.Handle, PChar(S), StrLen(PChar(S)), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);

  if HasQuantityFormula(RowNum - 1, ColNum - 2) then
    DrawTriangle(clBlue); // Draw a blue triangle in the top right of the current cell

  if HasPercentage then
  begin
    // Draw a red triangle in the top right of every cell in the current row, should
    // supercede any blue triangles from quantities as assigning a percentage will
    // remove any quantities for that row
    DrawTriangle(clRed);
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.HasQuantityFormula(RowIndex, ColumnIndex: Integer): Boolean;
begin
  //Quantity must be greater than one (stored as 10000)
  Result := (FData[RowIndex].bQuantitys[ColumnIndex] > 10000) and (FData[RowIndex].bUnitPrices[ColumnIndex] > 0)
end;

function TfrmBudget.HasPercentageFormula(RowIndex: Integer): Boolean;
begin
  Result := (FData[RowIndex].PercentAccount <> '');
end;

//------------------------------------------------------------------------------
function TfrmBudget.CompareCodes(CodeA, CodeB: string): Integer;
begin
  if UseXlonSort then
  begin
    Result := XlonSort(CodeA, CodeB);
    if Result = 0 then
       Result := StStrS.CompStringS( CodeA, CodeB);
  end
  else
    Result := StStrS.CompStringS( CodeA, CodeB);
end;

procedure TfrmBudget.CreateDetailLine(RowNum: integer);
var
  NewLine : pBudget_Detail_Rec;
begin
  if FData[RowNum].bDetailLine = nil then
  begin
    NewLine := New_Budget_Detail_Rec;
    NewLine.bdAccount_Code := fData[RowNum].bAccount;
    Budget.buDetail.Insert(NewLine);
    FData[RowNum].bDetailLine := NewLine;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoClearValues(clrClearType: EClearType);
var
 i,j : integer;
begin
  if not DataAssigned then exit;
  CheckEditMode;

  with tblBudget do begin
    AllowRedraw := false;
    try
      case clrClearType of
        clrAll:
        begin
          if AskYesNo('Clear All Budget Figures?',
          'Are you sure you want to clear ALL fields in this budget?', DLG_NO,0 ) <> DLG_YES then exit;
          for i := Low(Fdata) to High(FData) do
          begin
            for j := 1 to 12 do
               ClearCell(i,j);

            ReadRow(currentRow);  {reload current edit values}
            UpdateLine(i);
          end;
        end;

        clrColumn:
        begin
          for i := Low(Fdata) to High(FData) do
          begin
            ClearCell(i, tblBudget.ActiveCol-2);
            ReadRow(currentRow);  {reload current edit values}
            UpdateLine(i);
          end;
        end;

        clrRow:
        begin
          // Clear percentage data for this row
          FData[tblBudget.ActiveRow - 1].PercentAccount := '';
          FData[tblBudget.ActiveRow - 1].Percentage := 0;
          
          for i := Low(FData[tblBudget.ActiveRow - 1].bAmounts) to High(Low(FData[tblBudget.ActiveRow - 1].bAmounts)) do
          begin
            ClearCell(tblBudget.ActiveRow - 1, i);
            ReadRow(currentRow);  {reload current edit values}
            UpdateLine(tblBudget.ActiveRow-1);
          end;
        end;
      end;
      UpdateShowHideEnabledState;
    finally
      DoInvalidateTable;  {will force reload of current line}
      AllowRedraw := true;
    end;
  end;
end;

// There are enough possible actions that can muck up the percentages that it makes
// sense to simply update any percentage based rows whenever a column is invalidated
procedure TfrmBudget.DoInvalidateColumn(ColNum: integer);
begin
  UpdatePercentageRows(True);
  tblBudget.InvalidateColumn(ColNum);
end;

// There are enough possible actions that can muck up the percentages that it makes
// sense to simply update any percentage based rows whenever a row is invalidated
procedure TfrmBudget.DoInvalidateRow(RowNum: integer);
begin
  UpdatePercentageRows(True);
  tblBudget.InvalidateRow(RowNum);
end;

// There are enough possible actions that can muck up the percentages that it makes
// sense to simply update any percentage based rows whenever the table is invalidated
procedure TfrmBudget.DoInvalidateTable;
begin
  UpdatePercentageRows(false);
  tblBudget.InvalidateTable;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ClearCell(RowIndex, ColumnIndex: Integer);
begin
  FData[RowIndex].bAmounts[ColumnIndex] := 0;
  FData[RowIndex].bUnitPrices[ColumnIndex] := 0;
  FData[RowIndex].bQuantitys[ColumnIndex] := 0;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoShowAll;
begin
  RefreshTableWithData(true, true, true);
end;

//------------------------------------------------------------------------------
Procedure TfrmBudget.DoSmooth;
{updates entire table}
Var
  i,j : integer;
  T           : integer;
  By          : LongInt;
Begin
  if not DataAssigned then exit;

  checkEditMode;

  if BudgetContainsFormulas() then
  begin
    if MessageDlg('This budget contains formulas that will be cleared if you continue. Do you wish to continue?',
      mtWarning, [mbYes, mbNo], 0, mbNo) <> mrYes then
        Exit;
  end;

  with tblBudget do begin
    try
      for i := Low(Fdata) to High(FData) do
      begin
        t := 0;
        for j := 1 to 12 do
           t := t + FData[i].bAmounts[j];

        t := abs(t);

        if T<=100 then By := 1 else
        if T<=1000 then By := 10 else
        if T<=50000 then By := 50 else
        if T<=100000 then By := 100 else
        By := 500;

        for j := 1 to 12 do
        begin
          FData[i].bAmounts[j] := By * Round( FData[i].bAmounts[j] / By );
          FData[i].bQuantitys[j] := 0;
          FData[i].bUnitPrices[j] := 0;
        end;

        ReadRow(currentRow);  {reload current edit values}
        UpdateLine(i);
      end;
    finally
      RefreshTableWithData(fShowZeros, True, True);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoAverage;
{updates current edit line}
Var
  i           : integer;
  t,t1,b      : integer;
Begin
  if not DataAssigned then exit;

  CheckEditMode;

  if not (tblBudget.ActiveCol in [MonthMin .. MonthMax]) then
     exit;

  if RowContainsFormulas(CurrentRow - 1) then
  begin
    if MessageDlg('This row contains formulas that will be cleared if you continue. Do you wish to continue?',
      mtWarning, [mbYes, mbNo], 0, mbNo) <> mrYes then
        Exit;
  end;

  t := 0; t1:=0;

  For i := 1 to 12 do t := t + eAmounts[i];
  B := T div 12;

  for i:= 2 to 12 do
  Begin
     fData[currentRow-1].bAmounts[i] :=b;
     fData[CurrentRow-1].bQuantitys[i] := 0;
     fData[CurrentRow-1].bUnitPrices[i] := 0;
     T1:=T1+B;
  end;
  fData[currentRow-1].bAmounts[1] := t-t1;
  fData[CurrentRow-1].bQuantitys[1] := 0;
  fData[CurrentRow-1].bUnitPrices[1] := 0;

  ReadRow(currentRow);  {reload current edit values}
  Updateline(CurrentRow-1);

  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoSplit;
{updates current edit line}
Var
  i           : integer;
  InitialValue: integer;
  RunningValue: integer;
  MonthlyValue: integer;
Begin
  if not DataAssigned then exit;

  if HasPercentageFormula(CurrentRow - 1) then
  begin
    HelpfulErrorMsg('You cannot use split in a row which derives its values as a percentage ' +
                    'of another row. You must first clear the percentage.', 0);
    Exit;
  end;

  CheckEditMode;

  If ( tblBudget.ActiveCol = MonthMin) then
  Begin
    InitialValue := eAmounts[tblBudget.ActiveCol-MonthBase];
    MonthlyValue := InitialValue div 12;
    RunningValue := 0;

    for i := 2 to 12 do
    begin
      fData[CurrentRow - 1].bAmounts[i] := MonthlyValue;
      fData[CurrentRow - 1].bUnitPrices[i] := 0;
      fData[CurrentRow - 1].bQuantitys[i] := 0;
      RunningValue := RunningValue+MonthlyValue;
    end;

    fData[CurrentRow - 1].bUnitPrices[1] := 0;
    fData[CurrentRow - 1].bQuantitys[1] := 0;
    fData[currentRow-1].bAmounts[1] := InitialValue-RunningValue;

    ReadRow(currentRow);  {reload current edit values}
    Updateline(CurrentRow-1);

    RefreshTableWithData(fShowZeros, True, True);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoUnitPriceEntry;
var
  RowIndex, ColumnIndex: Integer;
  UnitPrice: Money;
  Quantity: Money;
  Total: Integer;
begin
  CheckEditMode;
  RowIndex := tblBudget.ActiveRow - 1;
  if HasPercentageFormula(RowIndex) then                
  begin
    HelpfulErrorMsg('Quantities cannot be entered for cells in a row which is a percentage ' +
                    'of another row. You must first remove the percentage for this row ' +
                    'before setting a quantity.', 0);
    Exit;
  end;
  ColumnIndex := tblBudget.ActiveCol - 2;
  //get stored unit price and quantity
  UnitPrice := FData[RowIndex].bUnitPrices[ColumnIndex];
  Quantity := FData[RowIndex].bQuantitys[ColumnIndex];
  //if no unit price and quantity stored, then must be Amount x 1
  if (UnitPrice = 0) and (Quantity = 0) then
  begin
    UnitPrice := FData[RowIndex].bAmounts[ColumnIndex]; // UnitPrice is mere Integer
    UnitPrice := UnitPrice * 10000;
    Quantity := 10000;
  end;
  
  if GetUnitPriceEntry(self, UnitPrice, Quantity, Total) then
  begin
    //Anything with a UnitPrice of 1 is not really a formula, so store as zero
    if Quantity > 10000 then
    begin
      FData[RowIndex].bUnitPrices[ColumnIndex] := UnitPrice;
      FData[RowIndex].bQuantitys[ColumnIndex]  := Quantity;
      FData[RowIndex].bAmounts[ColumnIndex]    := Total;
    end
    else
    begin
      FData[RowIndex].bUnitPrices[ColumnIndex] := 0;
      FData[RowIndex].bQuantitys[ColumnIndex]  := 0;
      FData[RowIndex].bAmounts[ColumnIndex]    := Total;
    end;
  end;
  ReadRow( tblBudget.ActiveRow);
  tblBudget.AllowRedraw := false;
  UpdateLine(RowIndex);
  DoInvalidateRow(CurrentRow);
  RefreshTableWithData(fShowZeros, True, True);
  tblBudget.AllowRedraw := true;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoGenerate;
{updates complete table}
var
  i,j,k,l : integer;
  AccountInfo : TAccountInformation;
  Account   : pAccount_Rec;
  Amount    : Money;
  Year, BudgetType : byte;

  WasInclusive : boolean;
  WasRepYearStart : integer;
  HideRowsAfter : boolean;
  FMonthEndings: TMonthEndings;
  b: TBank_Account;
  GainLossCode: string;
  GainLossCodes: TStringList;
  YearStartDate, StartDate, EndDate: TStDate;
  D1,D2,M1,M2,Y1,Y2: integer; 
begin
  if not DataAssigned then exit;

  CheckEditMode;

  if not GetGenerateBudgetOptions( MyClient.clFields.clCountry, Year, BudgetType) then
    Exit;

  {load this year and last year figures into chart, force to be calculated GST exclusive}
  WasInclusive    := MyClient.clFields.clGST_Inclusive_Cashflow;
  WasRepYearStart := MyClient.clFields.clReporting_Year_Starts;
  try
    MyClient.clFields.clGST_Inclusive_Cashflow             := false;
    MyClient.clFields.clFRS_Reporting_Period_Type          := frpMonthly;
    MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only  := ( BudgetType = GenBudgetDlg.btCashflow);
    MyClient.clFields.clTemp_FRS_Division_To_Use           := 0;  //all divisions
    MyClient.clFields.clTemp_FRS_Budget_To_Use             := ''; //no budget
    Myclient.clFields.clTemp_FRS_Budget_To_Use_Date        := -1;
    MyClient.clFields.clReporting_Year_Starts              := TfmeDateSelector.GetCurrentFinancialYear(MyClient);

    CalculateAccountTotals.FlagAllAccountsForUse( MyClient);
    //dont added contra amounts into the total
    CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, False, nil, -1, False, False, True);
  finally
    MyClient.clFields.clGST_Inclusive_Cashflow := WasInclusive;
    MyClient.clFields.clReporting_Year_Starts  := WasRepYearStart;
  end;

  {go thru table and add in chart values for each line}
  if ( BudgetType = GenBudgetDlg.btProfit) then
    AccountInfo := TProfitAndLossAccountInfo.Create( MyClient)
  else
    AccountInfo := TAccountInformation.Create( MyClient);

  try
    AccountInfo.UseBudgetIfNoActualData     := False;

    HideRowsAfter := not AllRowsShowing;
    DoShowAll;

    FMonthEndings := TMonthEndings.Create(MyClient);
    FMonthEndings.Refresh;

    // Get list of exchange gain/loss codes
    GainLossCodes := TStringList.Create;
    for i := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
    begin
      b := MyClient.clBank_Account_List.Bank_Account_At(i);
      GainLossCode := b.baFields.baExchange_Gain_Loss_Code;
      if (GainLossCodes.IndexOf(GainLossCode) = -1) and (GainLossCode <> '') then
        GainLossCodes.Add(GainLossCode);
    end;

    // Getting the start of the financial year
    YearStartDate := MyClient.clFields.clReporting_Year_Starts;
    StDateToDMY(YearStartDate, D1, M1, Y1);
    StDateToDMY(CurrentDate, D2, M2, Y2);
    YearStartDate := DMYToStDate(D1, M1, Y2, BKDATEEPOCH);
    if (YearStartDate > CurrentDate) then
      YearStartDate := IncDate(YearStartDate, 0, 0, -1);

    if Year = ytLastYear then
      YearStartDate := IncDate(YearStartDate, 0, 0, -1);

    with tblBudget do begin
      AllowRedraw := false;
      try
        for i := low(FData) to High(FData) do begin
          //Clear Values
          for j := 1 to 12 do
            ClearCell(i,j);

          //Attempt to fill values
          Account := FChart.FindCode(FData[i].bAccount);
          if Assigned(Account) then begin
            //set up account info obj
            AccountInfo.AccountCode := Account.chAccount_Code;
            AccountInfo.LastPeriodOfActualDataToUse := AccountInfo.HighestPeriod;

            //add data
            if (BudgetType = GenBudgetDlg.btCashflow) or
               ((BudgetType = GenBudgetDlg.btProfit) and (Account.chAccount_Type in ProfitAndLossReportGroupsSet)) then
            begin
              for j := 1 to 12 do begin
                if (GainLossCodes.IndexOf(AccountInfo.AccountCode) <> -1) then // Is this an exchange gain/loss code?
                begin
                  // Assign exchange gain/loss amount
                  StartDate := IncDate(YearStartDate, 0, j - 1, 0);
                  EndDate := IncDate(StartDate, -1, 1, 0);
                  Amount := 0;
                  for k := 0 to FMonthEndings.Count - 1 do
                  begin
                    for l := 0 to Length(FMonthEndings.Items[k].BankAccounts) - 1 do
                    begin
                      if (DateTimeToStDate(FMonthEndings.Items[k].Date) >= StartDate) and
                         (DateTimeToStDate(FMonthEndings.Items[k].Date) <= EndDate) and
                         (FMonthEndings.Items[k].BankAccounts[l].PostedEntry.FExchangeGainLossCode = AccountInfo.AccountCode) then
                        Amount := Amount + FMonthEndings.Items[k].BankAccounts[l].PostedEntry.GainLoss;
                    end;
                  end;
                end else
                if Year = ytLastYear then
                  Amount := AccountInfo.LastYear( j)
                else
                  Amount := AccountInfo.ActualOrBudget( j);

                //check to see what the expected sign if for this account.  If the sign
                //is the same represent the amount as a +ve number, otherwise represent it
                //as -ve
                if SignOf( Amount ) = ExpectedSign( Account.chAccount_Type ) then
                   Amount := Abs( Amount/100 )
                else
                   Amount := Abs( Amount/100 ) * -1;

                FData[i].bAmounts[j] := Round( Amount );
              end;
            end;
          end;
          ReadRow(currentRow);  {reload current edit values}
          UpdateLine(i, false);
        end;
        if HideRowsAfter then
          DoHideUnused;
      finally
        RefreshTableWithData(AllRowsShowing);
        DoInvalidateTable;
        AllowRedraw := true;
      end;
    end; {with}
  finally
    AccountInfo.Free;
  end;

end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoHideUnused;
begin
  RefreshTableWithData(false, true, true);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.CheckEditMode;
var
  key2 : TWMKey;
begin
  if EditMode then
  begin
    key2.charcode := vk_f6;
    ColMonth1.SendKeyToTable(key2);
    Application.ProcessMessages;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormActivate(Sender: TObject);
begin
  DoActivateBudgetForm;
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MINIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_RESTORE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MAXIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
  if FClearButton<>nil then
      FClearButton.DropDownMenu := popClearItems;
  Repaint;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormDeactivate(Sender: TObject);
begin
   DoDeactivateBudgetForm;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormDestroy(Sender: TObject);
begin
   FreeAndNil(FChart);
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then FHint.ReleaseHandle;
      FHint.Free;
      FHint := nil;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ProcessExternalCmd(command: TExternalCmdBudget);
begin
   AutoSaveUtils.DisableAutoSave;
   try
     case command of
       ecbGenerate : DoGenerate;
       ecbCopy     : DoCopy;
       ecbSplit    : DoSplit;
       ecbAverage  : DoAverage;
       ecbSmooth   : DoSmooth;
     //  ecbZero     : DoClearALL;
       ecbPercentageChange : DoPercentageChange;
       ecbHideUnused: DoHideUnused;
       ecbShowAll  : DoShowAll;
       ecbChart    : DoChartLookup;
       ecbQuit     : Close;
       ecbImport   : DoImport;
       ecbExport   : DoExport;
     end;
   finally
     EnableAutoSave;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.actAutoCalculateGSTExecute(Sender: TObject);
begin
  // Toggle the flag
  AutoCalculateGST := not AutoCalculateGST;

  // Validate the GST Setup when auto-calculate is turned on
  if AutoCalculateGST then
    ValidateGSTSetup(MyClient);

  RefreshGST;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.actAutoCalculateGSTUpdate(Sender: TObject);
begin
  actAutoCalculateGST.Checked := AutoCalculateGST;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ActClearAllExecute(Sender: TObject);
begin
  DoClearValues(clrAll);
  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ActClearColumnExecute(Sender: TObject);
begin
  DoClearValues(clrColumn);
  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ActClearRowExecute(Sender: TObject);
begin
  DoClearValues(clrRow);
  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.BkMouseWheelHandler(Sender: TObject; Shift: TShiftState;
  Delta, XPos, YPos: Word );
begin
  if ( ssShift in Shift )then begin
     if SmallInt(Delta) < 0 then    //need to type cast as a small int so that
       UPDATEMF.SelectNextMDI       //the sign can be tested.  OvcBase.pas should
     else                           //really declare this as SmallInt.
       UPDATEMF.SelectPreviousMDI;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mnuCloseClick(Sender: TObject);
begin
   Close;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.edtNameEnter(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmBudget.edtNameExit(Sender: TObject);
begin
  edtName.Hide;
  lblname.Show;
  lblName.Caption := Trim(EdtName.Text);;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.edtNameKeyPress(Sender: TObject; var Key: Char);
begin
   if key = #13 then begin
      tblBudget.setFocus;
      Key := #0;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.edtNameChange(Sender: TObject);
begin
   Self.caption := 'Edit Budget '+edtName.text;
end;

//------------------------------------------------------------------------------
procedure DoBudgets(tbClear: TRzToolButton = nil);
var
  SelectedList : TstringList;
  Budget       : TBudget;
  i,j          : integer;
  found        : boolean;

     {------------------------------------------------}
     procedure CreateBudgetScreen(aBudget : TBudget);
     var
       BudgetScreen : TfrmBudget;
     begin
       if not Assigned(aBudget) then exit;
       BudgetScreen := TfrmBudget.Create( MDIParentForm);
       FClearButton := tbClear;
       BudgetScreen.Caption := 'Edit Budget '+ aBudget.buFields.buName;
       BudgetScreen.Budget  := aBudget;
       BudgetScreen.rgGST.ItemIndex := ord(aBudget.buFields.buIs_Inclusive);
       BudgetScreen.ActiveControl := BudgetScreen.tblBudget;

       if not Assigned(BudgetScreen.Budget) then  {could not be assigned to form}
         BudgetScreen.Close;
     end;

var
  UserSelectedBudgets : boolean;
begin
  if not Assigned( MyClient) then exit;
  SelectedList  := TStringList.Create;
  try
    with MyClient do for i := 0 to clBudget_List.ItemCount -1 do
    if BudgetVisible( tBudget(clBudget_List.Budget_At(i)))then
    begin
      Budget := clBudget_List.Budget_At(i);
      SelectedList.AddObject(Budget.buFields.buName,Budget);
    end;

    //simple UI only allows one budget to be loaded
    UserSelectedBudgets := false;
    if Globals.Active_UI_Style in [UIS_Simple] then
    begin
      Budget := SelectBudget('Selected Budget to Edit',0, true);
      if Assigned( Budget) then
      begin
        SelectedList.Clear;
        SelectedList.AddObject(Budget.buFields.buName,Budget);
        UserSelectedBudgets := true;
      end;
    end
    else
      UserSelectedBudgets := SelectBudgets('Select Budgets to Edit',SelectedList);


    if UserSelectedBudgets then
    begin
      try
        {cycle thru bank accounts to see if should be loaded}
        with MyClient do for i := 0 to clBudget_List.ItemCount -1 do
        begin
          Budget := clBudget_List.Budget_At(i);
          found := false;

          for j := 0 to SelectedList.Count-1 do  {run thru selected list to see if included}
          begin
            if Budget = TBudget(SelectedList.Objects[j]) then
            begin
              found := true;
              break;
            end;
          end;

          if found then begin
             if not BudgetVisible( Budget) then
             begin
              CreateBudgetScreen(Budget);
             end;
          end
          else begin
             if BudgetVisible( Budget) then  CloseBudgetScreen(Budget);
          end;
        end; {with}
      finally
        LockWindowUpdate(0);
        RefreshHomepage ([HPR_Coding]);
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniEnterBalanceClick(Sender: TObject);
begin
  DoEnterBalance;
end;

procedure TfrmBudget.mniEnterPercentageClick(Sender: TObject);
begin
  DoPercentageCalculation;
  RefreshTableWithData(fShowZeros, True, True);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniEnterQuantityClick(Sender: TObject);
begin
  DoUnitPriceEntry;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoEnterBalance;
var
  NewBalance : Money;
begin
  NewBalance := Budget.buFields.buEstimated_Opening_Bank_Balance;
  if EditBudgetOpeningBalance( Budget.buFields.buStart_Date, NewBalance) then
  begin
    Budget.buFields.buEstimated_Opening_Bank_Balance := NewBalance;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoImport;
const
  ThisMethodName = 'DoImport';
var
  BudgetFilePath : string;
  BudgetErrorFile : string;
  BudgetImportExport : TBudgetImportExport;
  MsgStr : string;
  DataIndex : integer;
  BudgetCopy : TBudgetData;
  RowsImported : integer;
  RowsNotImported : integer;
  GSTInclusive: boolean;
begin
  BudgetErrorFile := UserDir + MyClient.clFields.clCode + ' ' +
                     RemoveInvalidCharacters(Budget.buFields.buName) + ' ' +
                     FormatDateTime('yyyy-mm-dd hh-mm-ss', Now) + '.log';

  BudgetImportExport := TBudgetImportExport.Create;
  try
    BudgetImportExport.BudgetDefaultFile := '';

    GSTInclusive := ShowFiguresGSTInclusive;
    if DoImportBudget(BudgetFilePath, FBudget.buFields.buName, GSTInclusive) then
    begin
      if not fShowZeros then
        RefreshFData(true, DataIndex);

      try
        BudgetImportExport.ClearWasUpdated(FData);
        BudgetCopy := BudgetImportExport.CopyBudgetData(FData, false, Budget.buFields.buStart_Date);

        if not BudgetImportExport.ImportBudget(BudgetFilePath,
                                               BudgetErrorFile,
                                               RowsImported,
                                               RowsNotImported,
                                               BudgetCopy,
                                               MsgStr,
                                               AutoCalculateGST) then
        begin
          tblBudget.AllowRedraw := false;
          try
            HelpfulErrorMsg(MsgStr, 0);
          finally
            tblBudget.AllowRedraw := true;
          end;
        end
        else
        begin
          tblBudget.AllowRedraw := false;
          try
            if VerifyBudgetImport(BudgetFilePath,
                                  BudgetErrorFile,
                                  RowsImported,
                                  RowsNotImported,
                                  ShowFiguresGSTInclusive) then
            begin
              rgGST.ItemIndex := ord(GSTInclusive);
              GSTInclusive := ShowFiguresGSTInclusive;
              FData := BudgetImportExport.CopyBudgetData(BudgetCopy, GSTInclusive, Budget.buFields.buStart_Date);
              BudgetImportExport.UpdateBudgetDetailRows(FData, FBudget);
              incusage('Import Budgets');
              ActiveControl := tblBudget;

              LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ' : ' +
                              'From File : ' + ExtractFileName(BudgetFilePath) + ', ' +
                              InttoStr(RowsImported) + ' Account(s) updated, ' +
                              InttoStr(RowsNotImported) + ' Account(s) rejected' );

              UpdatePercentageRows(True);
            end;
          finally
            tblBudget.AllowRedraw := true;
          end;
        end;

        if FileExists(BudgetErrorFile) then
        begin
          try
            DeleteFile(BudgetErrorFile);
          except
            // try delete log file if there is an error just ignore
          end;
        end;
      finally
        RefreshTableWithData(fShowZeros);
      end;
    end;
  finally
    FreeAndNil(BudgetImportExport);
  end;
end;

procedure TfrmBudget.DoExport;
var
  BudgetFilePath : string;
  IncludeUnusedChartCodes : boolean;
  IncludeNonPostingChartCodes : boolean;
  BudgetImportExport : TBudgetImportExport;
  MsgStr : string;
  DataIndex : integer;
  bPrefixAccountCode: boolean;
begin
  BudgetImportExport := TBudgetImportExport.Create;
  try
    BudgetImportExport.BudgetDefaultFile := UserDir + BUDGET_DEFAULT_FILENAME;
    BudgetFilePath := BudgetImportExport.GetDefaultFileLocation(MyClient.clFields.clCode, RemoveInvalidCharacters(Budget.buFields.buName));

    if BudgetFilePath = '' then
      BudgetFilePath := UserDir + MyClient.clFields.clCode + ' ' +
                        RemoveInvalidCharacters(edtName.Text) + '.csv'
    else if RemoveInvalidCharacters(Budget.buFields.buName) <> RemoveInvalidCharacters(edtName.Text) then
      BudgetFilePath := ExtractFilePath(BudgetFilePath) +
                        RemoveInvalidCharacters(edtName.Text) + '.csv';

    // Has the prefix default not been initialized yet?
    if (MyClient.clExtra.ceAdd_Prefix_For_Account_Code = prfxInit) then
    begin
      if DoAccountCodesNeedToBePrefixed(FData) then
        MyClient.clExtra.ceAdd_Prefix_For_Account_Code := prfxOn
      else
        MyClient.clExtra.ceAdd_Prefix_For_Account_Code := prfxOff;
    end;
    ASSERT(MyClient.clExtra.ceAdd_Prefix_For_Account_Code <> prfxInit);

    if DoExportBudget(BudgetFilePath, IncludeUnusedChartCodes, IncludeNonPostingChartCodes) then
    begin
      if not fShowZeros then
        RefreshFData(true, DataIndex);

      try
        // Do this after DoExportBudget dialog
        bPrefixAccountCode :=
          (MyClient.clExtra.ceAdd_Prefix_For_Account_Code = prfxOn);

        if BudgetImportExport.ExportBudget(BudgetFilePath, IncludeUnusedChartCodes, FData,
                                           Budget.buFields.buStart_Date, MsgStr,
                                           IncludeNonPostingChartCodes,
                                           bPrefixAccountCode,
                                           ShowFiguresGSTInclusive) then
        begin
          BudgetImportExport.SetDefaultFileLocation(MyClient.clFields.clCode, RemoveInvalidCharacters(edtName.Text{Budget.buFields.buName}) , BudgetFilePath);

          MsgStr := Format('Budget saved to "%s".%s%sDo you want to view it now?', [BudgetFilePath, #13#10, #13#10]);
          incusage('Export Budgets');

          tblBudget.AllowRedraw := false;
          try
            if (AskYesNo(rfNames[rfCSV], MsgStr, DLG_YES, 0) = DLG_YES) then
              ShellExecute(0, 'open', PChar(BudgetFilePath), nil, nil, SW_SHOWMAXIMIZED);
          finally
            tblBudget.AllowRedraw := true;
          end;
        end
        else
          HelpfulErrorMsg(MsgStr, 0);
      finally
        if not fShowZeros then
          RefreshTableWithData(fShowZeros);
      end;
    end;
  finally
    FreeAndNil(BudgetImportExport);
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.RowContainsFormulas(RowIndex:Integer): boolean;
var
  I: Integer;
begin
  Result := false;
  for I := Low(FData[RowIndex].bQuantitys) to High(FData[RowIndex].bQuantitys) do
  begin
    if HasQuantityFormula(RowIndex, I) then
    begin
      Result := true;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.BudgetContainsFormulas: boolean;
var
  I: Integer;
begin
  Result := false;
  for I := Low(FData) to High(FData) do
  begin
    if RowContainsFormulas(I) then
    begin
      Result := true;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoDeleteLine;
var
   j : integer;
begin
  if not tblBudget.StopEditingState( true) then exit;
  if not RowNumOK( tblBudget.ActiveRow) then exit;

  with tblBudget do begin
    AllowRedraw := false;
    try
      for j := 1 to 12 do
        ClearCell(ActiveRow - 1, j);
      ReadRow(currentRow);  {reload current edit values}
      UpdateLine( ActiveRow - 1);
     finally
      DoInvalidateTable;  {will force reload of current line}
      AllowRedraw := true;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniLockLeftmostClick(Sender: TObject);
begin
   mniLockLeftMost.Checked := not mniLockLeftmost.Checked;
   tblBudget.AllowRedraw;
   try
      if mniLockLeftmost.checked then begin
         tblBudget.LockedCols := 3;
      end
      else begin
         tblBudget.LockedCols := 0;
         tblBudget.LeftCol    := 0;
      end;
   finally
      tblBudget.InvalidateTable;
      tblBudget.AllowRedraw := true;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.SetIsClosing(const Value: Boolean);
begin
  FIsClosing := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  NewName : string;
  DateFrom : Integer;
  BudgetObj : TBudget;
  tempBudget : TBudget;
  i : integer;
begin
  if not tblBudget.StopEditingState(True) then
    //date is invalid, ignore the edit and allow form to close
    tblBudget.StopEditingState( False);

  if Assigned(FBudget) then
  begin
    NewName := Trim( edtName.Text);
    //only update the name if it is not blank
    if NewName <> '' then
    begin
      //check if a budget with the same name and date already exists
      DateFrom := FBudget.buFields.buStart_Date;
      tempBudget := NIL;
      i := 0;
      with MyClient.clBudget_List do
      begin
        while (i < ItemCount) and (tempBudget = NIL) do
        begin
          BudgetObj := Budget_At( I );
          if (BudgetObj <> Self.Budget) then
            with BudgetObj.buFields do
              if ( buName = NewName ) and
                 ( buStart_Date = DateFrom ) then
                tempBudget := BudgetObj;
          Inc(i);
        end;
      end;
      If tempBudget<>NIL then
      Begin
        CanClose := False;
        HelpfulErrorMsg( 'A Budget with this name and start date already exists', 0 );
        exit;
      end;

      FBudget.buFields.buName := edtName.text;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.FormIsInEditMode: boolean;
begin
  result := tblBudget.InEditingState;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniIncreaseDecreaseClick(Sender: TObject);
begin
  DoPercentageChange;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniImportClick(Sender: TObject);
begin
  DoImport;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.mniExportClick(Sender: TObject);
begin
  DoExport;
end;

//------------------------------------------------------------------------------
function TfrmBudget.IncreaseAmount( aAmount : Integer; perc : double; var ValueTooLarge: boolean) : integer;
var
 NewAmount : Int64;
begin
 NewAmount := Round( aAmount * perc);
 if ( NewAmount > High(aAmount)) or ( NewAmount < Low(aAmount)) then
 begin
   result := aAmount;
   ValueTooLarge := true;
 end
 else
   result := NewAmount;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.IncreaseCellBy(RowIndex, ColumnIndex: Integer; Percent: double; var ValueTooLarge: Boolean);
var
  UnitPrice: Money;
  Quantity: Money;
  Amount: Integer;
begin
  if HasQuantityFormula(RowIndex, ColumnIndex) then
  begin
    //increase UnitPrice and recalculate amount
    UnitPrice := FData[RowIndex].bUnitPrices[ColumnIndex];
    UnitPrice := UnitPrice * Percent;
    if (UnitPrice > High(Amount)) or (UnitPrice < Low(Amount)) then
    begin
      ValueTooLarge := True;
      Exit;
    end;
    Quantity := FData[RowIndex].bQuantitys[ColumnIndex];
    Amount := TfrmBudgetUnitPriceEntry.CalculateTotal(UnitPrice, Quantity);
    if Amount >= 1000000000 then
    begin
      ValueTooLarge := true;
      Exit;
    end;
    FData[RowIndex].bAmounts[ColumnIndex] := Amount;
    FData[RowIndex].bUnitPrices[ColumnIndex] := UnitPrice;
  end
  else
    FData[RowIndex].bAmounts[ColumnIndex] := IncreaseAmount(FData[RowIndex].bAmounts[ColumnIndex], Percent, ValueTooLarge);

  UpdateLine(RowIndex);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoPercentageCalculation(DataRow: integer = -1; OnlyUpdateThisColumn: integer = -1);
var
  AccountCodeRow: integer;
  ColNum: integer;

  function GetAccountCodeRow(AccountCode: string): integer;
  var
    i: integer;
  begin
    Result := -1;
    for i := 0 to High(FData) do
    begin
      if (FData[i].bAccount = AccountCode) then
      begin
        Result := i;
        break;
      end;
    end;
  end;

begin
  // If a row has been passed in, this means the user has changed a value in a row from
  // which another row derives its value.
  //
  // If no row has been passed in, this means that the user has just added or modified
  // a percentage value for a row, in which case we want to use the currently selected
  // row, and will need to bring up the form for the user to enter the account code
  // and percentage that they're basing this row off
  //
  // If a column has been passed in, then we only need to update that column, as the
  // user has modified a value in one cell of another row from which this row is derived,
  // so the other values in this row should remain the same and thus won't require updating
  if DataRow = -1 then
  begin
    DataRow := tblBudget.ActiveRow - 1;

    frmPercentageCalculation := TfrmPercentageCalculation.Create(self);
    try
      frmPercentageCalculation.Position := poMainFormCenter;
      frmPercentageCalculation.edtAccountCode.Text := FData[DataRow].PercentAccount;
      frmPercentageCalculation.nPercent.Text := FloatToStr(FData[DataRow].Percentage);
      frmPercentageCalculation.CurrentRow := FData[DataRow].bAccount;
      frmPercentageCalculation.ShowModal;

      if frmPercentageCalculation.ModalResult = mrOK then
      begin
        if (FData[DataRow].PercentAccount = '') and
           (Trim(frmPercentageCalculation.edtAccountCode.Text) = '') then
          Exit; // There was no percentage and there isn't now, so nothing has changed, don't do anything
        FData[DataRow].PercentAccount := Trim(frmPercentageCalculation.edtAccountCode.Text);
        FData[DataRow].Percentage := StrToFloat(Trim(frmPercentageCalculation.nPercent.Text));
      end else
        Exit;
    finally
      FreeAndNil(frmPercentageCalculation);
    end;
  end;
  AccountCodeRow := GetAccountCodeRow(FData[DataRow].PercentAccount);

  for ColNum := 1 to 12 do
  begin
    if (OnlyUpdateThisColumn = -1) or (OnlyUpdateThisColumn = ColNum) then
    begin
      if (AccountCodeRow = -1) then
        // In this case, the chart code row our percentages are based off has been deleted, so we
        // want to zero out the data but keep the formulas in place. The user is responsible for
        // updating or removing the percentage code and amount
        FData[DataRow].bAmounts[ColNum] := 0
      else if not FData[AccountCodeRow].bIsPosting then
        // In this case, the chart code row our percentages are based off has been set to
        // non-posting, so we want to zero out the data but keep the formulas in place. The
        // user is responsible for updating or removing the percentage code and amount
        FData[DataRow].bAmounts[ColNum] := 0
      else
        FData[DataRow].bAmounts[ColNum] :=
          Round(FData[AccountCodeRow].bAmounts[ColNum] * (FData[DataRow].Percentage / 100));

      CreateDetailLine(DataRow);
      FData[DataRow].bDetailLine.bdBudget[ColNum] := FData[DataRow].bAmounts[ColNum];

      // Assigning a percentage to a row removes any quantities in the same row
      FData[DataRow].bQuantitys[ColNum] := 0;
      FData[DataRow].bUnitPrices[ColNum] := 0;
      if (OnlyUpdateThisColumn <> -1) then
        break;
    end;
  end;

  // Redraw row
  with tblBudget do
  begin
    AllowRedraw := false;
    // Here we do not call 'DoInvalidateRow' or 'DoInvalidateColumn' as it is
    // redundant and would cause an infinite loop back to this procedure
    InvalidateRow(DataRow + 1);
    InvalidateColumn(TotalCol);
    AllowRedraw := true;
  end;
end;

procedure TfrmBudget.DoPercentageChange;
const
  CellsHavePercentWarning : string = 'You cannot change the value of cells which are ' +
                                     'deriving their value as a percentage of another ' +
                                     'cell. You must first clear the percentage for ' +
                                     'this row.';
var
  ValueTooLarge : boolean;
  Percent : double;
  CellsToChange :  BudgetPercentageChangeDlg.TCellTypes;
  DataRow : integer;
  DataCol : integer;
  i,j : integer;
  aMsg : string;
begin
  if not DataAssigned then exit;

  CheckEditMode;
  ValueTooLarge := false;

  if not (tblBudget.ActiveCol in [MonthMin..MonthMax]) then
     exit;

  DataRow := currentRow - 1;
  DataCol := tblBudget.ActiveCol - 2;

  //get parameters
  if BudgetPercentageChangeDlg.GetPercentage( Percent, CellsToChange) then
  begin
    //user is asked for the percent to vary by, so 10% means we need to
    //multiple values by 1.10
    Percent := (100 + Percent) / 100;

    tblBudget.AllowRedraw := false;
    try
      case CellsToChange of
        ctCell : begin
          if HasPercentageFormula(DataRow) then                 
          begin
            HelpfulErrorMsg(CellsHavePercentWarning, 0);
          end else
          begin
            IncreaseCellBy(DataRow, DataCol, Percent, ValueTooLarge);
            DoInvalidateRow(CurrentRow);
          end;
        end;

        ctColumn : begin
          for i := Low(Fdata) to High(FData) do
            IncreaseCellBy(i, DataCol, Percent, ValueTooLarge);

          ReadRow(currentRow);  {reload current edit values}
          DoInvalidateColumn( tblBudget.ActiveCol);
        end;

        ctRow : begin
          if HasPercentageFormula(DataRow) then
          begin
            HelpfulErrorMsg(CellsHavePercentWarning, 0);
          end else
          begin
            for i := 1 to 12 do
              IncreaseCellBy(DataRow, i, Percent, ValueTooLarge);
            Updateline( DataRow);
            DoInvalidateRow(CurrentRow);
          end;
        end;

        ctAll : begin
          for i := Low(Fdata) to High(FData) do
          begin
            for j := 1 to 12 do
            begin
              IncreaseCellBy(i,j,Percent, ValueTooLarge);
            end;
          end;
          ReadRow(currentRow);  {reload current edit values}
          DoInvalidateTable;
        end;
      end;

    finally
      tblBudget.AllowRedraw := true;
    end;

    if ValueTooLarge then
    begin
      if ( CellsToChange = ctCell) then
        aMsg := 'The value in this cell count not be changed because the resulting amount would be invalid.'
      else
        aMsg := 'The values in some cells could not be changed because the resulting amounts would be invalid.';

      HelpfulInfoMsg( aMsg, 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Catch Right Click and decide which PopUp to display
var
  ColEstimate, RowEstimate : integer;
begin
  if (Button = mbRight) then begin
    //estimate where click happened
    if tblBudget.CalcRowColFromXY(x,y,RowEstimate,ColEstimate) in [ otrOutside, otrInUnused ] then
      exit;
    // Select row
    tblBudget.SetFocus;
    tblBudget.ActiveRow := RowEstimate;
    ShowPopup( x,y,popBudget);
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.ShowFiguresGSTInclusive: boolean;
begin
  Result := (rgGST.ItemIndex = 1);
end;

procedure TfrmBudget.ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );
var
   ClientPt, ScreenPt : TPoint;
begin
   ClientPt.x := x;
   ClientPt.y := y;
   ScreenPt   := tblBudget.ClientToScreen(ClientPt);
   PopMenu.Popup(ScreenPt.x, ScreenPt.y);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetVSThumbChanged(Sender: TObject;
  RowNum: TRowNum);
Var
   CR     : TPoint;
   MP     : TPoint;
   HR     : TRect;
   Msg    : String;
begin
   if RowNum<0 then exit;

   Msg := FData[RowNum].bAccount + ': ' + FData[RowNum].bDesc;

   if Msg <> '' then begin
      CR := ClientToScreen( ClientRect.BottomRight );
      MP := Mouse.CursorPos;
      HR := FHint.CalcHintRect(Screen.Width, Msg, NIL );
      Inc( HR.Bottom, 2 );
      Inc( HR.Right, 6 );
      OffsetRect( HR, CR.X - GetSystemMetrics( SM_CXVSCROLL ) - HR.Right, MP.Y );
      FHint.Color := Application.HintColor;
      FHint.ActivateHint( HR, Msg );
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.HideCustomHint;
var
   R: TRect;
begin
   if Assigned( FHint ) then begin
      if FHint.HandleAllocated then begin // Find where the Hint is, so we can redraw the cells beneath it.
         GetWindowRect( FHint.Handle, R );
         R.TopLeft      := tblBudget.ScreenToClient(R.TopLeft);
         R.BottomRight  := tblBudget.ScreenToClient(R.BottomRight);
         FHint.ReleaseHandle;
         HintShowing    := false;
         tblBudget.AllowRedraw := False;
         tblBudget.InvalidateCellsInRect( R );
         tblBudget.AllowRedraw := True;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.EndEditRow(RowNum, ColNum : integer; var AllowIt : boolean);
begin

end;

//------------------------------------------------------------------------------
function TfrmBudget.GetAutoCalculateGST: boolean;
begin
  result := fBudget.buFields.buAutomatically_Calculate_GST;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.SetAutoCalculateGST(const aValue: boolean);
begin
  fBudget.buFields.buAutomatically_Calculate_GST := aValue;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.RefreshGST;
begin
  // Do the calculations on the budget lines
  CalculateGSTtoGSTAmount(MyClient, fBudget, fData, AutoCalculateGST);

  // Update all the values in the grid control
  tblBudget.Refresh;
end;

procedure TfrmBudget.UMMainFormModalCommand(var aMsg: TMessage);
begin
  case aMsg.WParam of
    mf_mcGSTDetails:
      RefreshGST;
  end;
end;

//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);

end.
