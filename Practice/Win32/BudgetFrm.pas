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
  BudgetImportExport;

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
    imgGraphic: TImage;
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

    eAmounts         : Array[1..12] of integer;
    FIsClosing: Boolean; {current edit values for record}
    FChart: TCustomSortChart;

    procedure InitTable;
    function  RowNumOK(RowNum : integer): boolean;
    function  RowDataOK(RowNum : integer;Routine:string): boolean;
    procedure ReadCellforPaint(RowNum,ColNum : integer;var Data : pointer);
    procedure ReadCellforEdit(RowNum,ColNum: integer; var Data : pointer);
    procedure WriteCell(RowNum,ColNum : integer; var Data : pointer);
    procedure ReadRow(RowNum : integer);
    procedure EndEditRow(RowNum, ColNum : integer; var AllowIt : boolean);

    procedure SetBudget(const Value: TBudget);
    procedure UpdateLine(index : integer);
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
    procedure DoImport;
    procedure DoExport;

    procedure DoDeleteLine;

    procedure SetupHelp;
    procedure SetIsClosing(const Value: Boolean);

    procedure ShowPopUp( x, y : Integer; PopMenu :TPopUpMenu );

    procedure WMSysCommand(var msg: TWMSyscommand); message WM_SYSCOMMAND;
    procedure tblBudgetVSThumbChanged(Sender: TObject; RowNum: TRowNum);
    procedure HideCustomHint;
    function GetTotalForRow(RowNum: Integer): Integer;
    procedure RefreshTableWithData(ShowZeros: Boolean);
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
  public
    { Public declarations }
    property Budget  : TBudget read FBudget write SetBudget;
    property IsClosing : Boolean read FIsClosing write SetIsClosing;
    function FormIsInEditMode: boolean;

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
   clObj32,
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
   ShellAPI;

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
begin
 Data := nil;
 {validate}
 if RowNumOK(RowNum) then begin
    {get data}
    case ColNum of
      AccountCol : Data := @FData[RowNum-1].bAccount;

      DescCol :    Data := @FData[RowNum-1].bDesc;

      MonthMin..MonthMax :
           if FData[RowNum-1].bIsPosting then
              Data := @FData[RowNum-1].bAmounts[ColNum-MonthBase]
           else begin
              if FData[RowNum-1].bAmounts[ColNum-MonthBase] <> 0 then
                 Data := @FData[RowNum-1].bAmounts[ColNum-MonthBase];
           end;
      TotalCol :
        begin
          FData[RowNum-1].bTotal := GetTotalForRow(RowNum);
          Data := @FData[RowNum-1].bTotal;
        end;
    end;{case}
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.GetTotalForRow(RowNum: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := MonthMin to MonthMax do
    Result := Result + FData[RowNum - 1].bAmounts[i-MonthBase];
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

  AllowIt := FData[RowNum-1].bIsPosting;
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

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetDoneEdit(Sender: TObject; RowNum,
  ColNum: Integer);
{data for the record has been saved into the variables.  should now save into database}
{note this will be triggered for each cell save}

{for edits that affect other cells those cells will be updated from here also}
{saves direct edits!}
var
  NewLine : pBudget_Detail_Rec;

begin
  if RowDataOK(RowNum,'BDoneEdit') then
    begin
       case ColNum of
         MonthMin..MonthMax :
         begin
            {write this cell to data structure, also update the associated}
            {budget line for this cell}

            FData[RowNum-1].bAmounts[ColNum-MonthBase] := eAmounts[ColNum-MonthBase];
            if (eAmounts[ColNum - MonthBase] = 0) or not AmountMatchesQuantityFormula(RowNum - 1, ColNum - MonthBase)  then
            begin
              FData[RowNum - 1].bQuantitys[ColNum - MonthBase] := 0;
              FData[RowNum - 1].bUnitPrices[ColNum - MonthBase] := 0;
            end;

            if FData[RowNum-1].bDetailLine = nil then
            begin
               NewLine := New_Budget_Detail_Rec;
               NewLine.bdAccount_Code := fData[Rownum-1].bAccount;
               Budget.buDetail.Insert(NewLine);

               FData[RowNum-1].bDetailLine := NewLine;
            end;

            FData[RowNum-1].bDetailLine.bdBudget[ColNum-MonthBase] := eAmounts[ColNum-MonthBase];
            FData[RowNum-1].bDetailLine.bdQty_Budget[ColNum - MonthBase] := FData[RowNum - 1].bQuantitys[ColNum - MonthBase];
            FData[RowNum-1].bDetailLine.bdEach_Budget[ColNum - MonthBase] := FData[RowNum - 1].bUnitPrices[ColNum - MonthBase];
         end;
       end;

       {redraw row}
       with tblBudget do begin
          AllowRedraw := false;
          InvalidateRow(RowNum);
          InvalidateColumn(TotalCol);
          AllowRedraw := true;
       end;
  end; {if row ok}
  UpdateShowHideEnabledState;
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

   bkBranding.StyleTopBannerRightImage(imgGraphic);
   
   mniLockLeftmostClick(Sender);

   //ExtraTitleBar.Color    := bkBranding.HeaderBackgroundColor;
   //edtName.Color          := bkBranding.HeaderBackgroundColor;
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.tblBudgetActiveCellChanged(Sender: TObject;
  RowNum, ColNum: Integer);
begin
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
procedure TFrmBudget.RefreshTableWithData(ShowZeros: Boolean);
var
  Account : pAccount_Rec;
  AccountIndex, DataIndex: Integer;
  pBudgetRec: pBudget_Detail_Rec;
  MonthIndex: Integer;
  HasData: Boolean;
begin
  {now load all the data values}
  FData := nil;
  DataAssigned := false;
  SetLength(FData, FChart.ItemCount);   //allocate enough for current chart

  DataIndex := 0;
  for AccountIndex := 0 to FChart.ITemCount-1 do with FChart do
  begin
    Account := Account_At(AccountIndex);
    pBudgetRec := Budget.buDetail.FindLineByCode(Account.chAccount_Code);
    if not ShowZeros and not Assigned(pBudgetRec) then
      Continue;

    //see if the item has data
    if Assigned(pBudgetRec) and not ShowZeros then
    begin
      HasData := false;
      for MonthIndex := 1 to 12 do
      begin
        if pBudgetRec.bdBudget[MonthIndex] <> 0 then
        begin
          HasData := true;
          break;
        end;
      end;
      if not HasData then
        Continue;
    end;

    FData[DataIndex].bAccount := Account.chAccount_Code;
    FData[DataIndex].bDesc    := Account.chAccount_Description;
    FData[DataIndex].bIsPosting := Account.chPosting_Allowed;
    FData[DataIndex].bDetailLine := pBudgetRec;
    for MonthIndex := 1 to 12 do
    begin
      if Assigned(pBudgetRec) then
      begin
        FData[DataIndex].bAmounts[MonthIndex] := Round(FData[DataIndex].bDetailLine.bdBudget[MonthIndex]);
        FData[DataIndex].bQuantitys[MonthIndex] := FData[DataIndex].bDetailLine.bdQty_Budget[MonthIndex];
        FData[DataIndex].bUnitPrices[MonthIndex] := FData[DataIndex].bDetailLine.bdEach_Budget[MonthIndex];
      end
      else
      begin
        FData[DataIndex].bAmounts[MonthIndex] := 0;
        FData[DataIndex].bQuantitys[MonthIndex] := 0;
        FData[DataIndex].bUnitPrices[MonthIndex] := 0;
      end;
    end;
    Inc(DataIndex);
  end;

  if (DataIndex = 0) and not ShowZeros then
  begin
    HelpfulInfoMsg('There are no used entries. '+SHORTAPPNAME+ ' will display all entries.', 0);
    RefreshTableWithData(true);
    Exit;
  end;
  

  SetLength(FData, DataIndex);
  tblBudget.RowLimit := DataIndex + 1;
  DataAssigned := true;

  tblBudget.InvalidateTable;
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
procedure TfrmBudget.UpdateLine(index: integer);
{syncronizes the editor lines and the lines stored in the budget}
{adds, edits or deletes budget line where necessary}
var
  i : integer;
  DetailLine : pBudget_Detail_Rec;
  HasData : boolean;
begin
  if not DataAssigned then exit;
  if not ((index >= Low(FData)) and (index <= High(Fdata))) then exit;

  {check if any of the values are non zero}
  HasData := false;
  for i := 1 to 12 do
    if FData[index].bAmounts[i] <> 0 then
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
   else if msg.CharCode in [VK_MULTIPLY,VK_OEM_PLUS] then
   begin
     handled := true;
     case msg.CharCode of
       VK_MULTIPLY: DoPercentageChange;
       VK_OEM_PLUS: DoUnitPriceEntry;  // =
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

  {redraw line}
  with tblBudget do begin
    AllowRedraw := false;
    InvalidateRow(CurrentRow);
    AllowRedraw := true;
  end;
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

      pBudgetRec := Budget.buDetail.FindLineByCode(AccountRec.chAccount_Code);
      FData[i].bDetailLine := pBudgetRec;
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
  tblBudget.InvalidateTable;  {will force reload of current line}
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
  R: TRect;
  s : String;
  D: Double;
begin
  if not assigned(FData) then Exit;
  
  DoneIt := true;
  //draw text
  R := CellRect;
  D := FData[RowNum - 1].bAmounts[ColNum - 2];
  S := Format('%.0n',[D]);
  TableCanvas.Font := CellAttr.caFont;
  TableCanvas.Brush.Color := CellAttr.caColor;
  TableCanvas.Font.Color  := CellAttr.caFontColor;
  TableCanvas.FillRect(R);  
  DrawText(TableCanvas.Handle, PChar(S), StrLen(PChar(S)), R, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);


  if HasQuantityFormula(RowNum - 1, ColNum - 2) then
  begin
    TableCanvas.Brush.Color := clBlue;
    TableCanvas.Pen.Color := clBlue;
    //draw a blue triangle in the top right
    TableCanvas.Polygon( [Point( CellRect.Right - Margin, CellRect.Top),
                      Point( CellRect.Right, CellRect.Top),
                      Point( CellRect.Right, CellRect.Top + Margin)]);
  end;
end;

//------------------------------------------------------------------------------
function TfrmBudget.HasQuantityFormula(RowIndex, ColumnIndex: Integer): Boolean;
begin
  //Quantatiy must be greater than one (stored as 10000)
  Result := (FData[RowIndex].bQuantitys[ColumnIndex] > 10000) and (FData[RowIndex].bUnitPrices[ColumnIndex] > 0)
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
      InvalidateTable;  {will force reload of current line}
      AllowRedraw := true;
    end;
  end;
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
  RefreshTableWithData(true);
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
    AllowRedraw := false;
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
      InvalidateTable;  {will force reload of current line}
      AllowRedraw := true;
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

  {redraw line}
  with tblBudget do begin
    AllowRedraw := false;
    InvalidateRow(CurrentRow);
    AllowRedraw := true;
  end;
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

  CheckEditMode;

  If ( tblBudget.ActiveCol = MonthMin) then
  Begin
    InitialValue := eAmounts[tblBudget.ActiveCol-MonthBase];;
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

    {redraw line}
    with tblBudget do begin
      AllowRedraw := false;
      InvalidateRow(CurrentRow);
      AllowRedraw := true;
    end;
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
  tblBudget.InvalidateRow(CurrentRow);
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
          UpdateLine(i);
        end;
        if HideRowsAfter then
          DoHideUnused;
      finally
        RefreshTableWithData(AllRowsShowing);
        InvalidateTable;
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
  RefreshTableWithData(false);
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
procedure TfrmBudget.ActClearAllExecute(Sender: TObject);
begin
  DoClearValues(clrAll);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ActClearColumnExecute(Sender: TObject);
begin
  DoClearValues(clrColumn);
end;

//------------------------------------------------------------------------------
procedure TfrmBudget.ActClearRowExecute(Sender: TObject);
begin
  DoClearValues(clrRow);
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
  //edtName.Color := ExtraTitleBar.Color;
  //edtName.Font.Color := clCaptionText;
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
begin

end;

//------------------------------------------------------------------------------
procedure TfrmBudget.DoExport;
var
  BudgetFilePath : string;
  IncludeUnusedChartCodes : boolean;
  BudgetImportExport : TBudgetImportExport;
  MsgStr : string;
begin
  BudgetImportExport := TBudgetImportExport.Create;
  try
    BudgetImportExport.BudgetDefaultFile := UserDir + BUDGET_DEFAULT_FILENAME;

    BudgetFilePath := BudgetImportExport.GetDefaultFileLocation(MyClient.clFields.clCode);

    if DoExportBudget(BudgetFilePath, IncludeUnusedChartCodes) then
    begin
      if BudgetImportExport.ExportBudget(BudgetFilePath, IncludeUnusedChartCodes, FData, Budget.buFields.buStart_Date, MsgStr) then
      begin
        BudgetImportExport.SetDefaultFileLocation(MyClient.clFields.clCode, BudgetFilePath);

        MsgStr := Format('Budget saved to "%s".%s%sDo you want to view it now?', [BudgetFilePath, #13#10, #13#10]);
        if (AskYesNo(rfNames[rfPDF], MsgStr, DLG_YES, 0) = DLG_YES) then
          ShellExecute(0, 'open', PChar(BudgetFilePath), nil, nil, SW_SHOWMAXIMIZED);
      end
      else
        HelpfulErrorMsg(MsgStr, 0);
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
      InvalidateTable;  {will force reload of current line}
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
procedure TfrmBudget.DoPercentageChange;
var
  ValueTooLarge : boolean;
var
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
          IncreaseCellBy(DataRow, DataCol, Percent, ValueTooLarge);
          tblBudget.InvalidateRow(CurrentRow);
        end;

        ctColumn : begin
          for i := Low(Fdata) to High(FData) do
            IncreaseCellBy(i, DataCol, Percent, ValueTooLarge);

          ReadRow(currentRow);  {reload current edit values}
          tblBudget.InvalidateColumn( tblBudget.ActiveCol);
        end;

        ctRow : begin
          for i := 1 to 12 do
            IncreaseCellBy(DataRow, i, Percent, ValueTooLarge);
          Updateline( DataRow);
          tblBudget.InvalidateRow(CurrentRow);
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
          tblBudget.InvalidateTable;
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
initialization
   DebugMe := DebugUnit(UnitName);

end.
