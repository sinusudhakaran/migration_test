// Export charges wizard
unit ExportChargesFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Buttons,
  StdCtrls,
  ExtCtrls,
  Grids_ts,
  TSGrid,
  ReportDefs,
  TSMask,
  ComCtrls,
  ovcbase,
  ovcef,
  ovcpb,
  ovcnf,
  ovcpf,
  RzDTP,
  Math,
  SyDefs,
  OSFont,
  Menus,
  bkConst;
  {TsGridReport}

type

  TfrmExportCharges = class(TForm)
    pnlOptions: TPanel;
    lblSaveTo: TLabel;
    eTo: TEdit;
    cmbMonths: TComboBox;
    lblMonth: TLabel;
    pnlInstructions: TPanel;
    btnToFolder: TSpeedButton;
    lblTitle: TLabel;
    btnBack: TButton;
    pnlGrid: TPanel;
    btnReport: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    pnlHide: TPanel;
    chkHide: TCheckBox;
    tgCharges: TtsGrid;
    tsMaskDefs1: TtsMaskDefs;
    //osGridReport1: TosGridReport;
    pnlButtons: TPanel;
    SaveDialog1: TSaveDialog;
    pnlProgress: TPanel;
    pnlCentre: TPanel;
    Label1: TLabel;
    pbGrid: TProgressBar;
    btnStore: TButton;
    tmrAPS: TTimer;
    pnlAdjust: TPanel;
    chkFixed: TCheckBox;
    gbFixed: TGroupBox;
    gbPercent: TGroupBox;
    chkPercent: TCheckBox;
    rbAddFixed: TRadioButton;
    rbDistribute: TRadioButton;
    lblPercent: TLabel;
    eAddFixed: TOvcNumericField;
    eDistribute: TOvcNumericField;
    ePercent: TOvcNumericField;
    lblView: TLabel;
    lblDate: TLabel;
    {$WARNINGS OFF}
    eDate: TRzDateTimePicker;
    {$WARNINGS ON}
    lblRemarks: TLabel;
    eRemarks: TEdit;
    edtFind: TEdit;
    Label2: TLabel;
    pnlSearch: TPanel;
    btnNext: TBitBtn;
    btnLast: TBitBtn;
    lblHeading: TLabel;
    rbSetFixed: TRadioButton;
    eSetFixed: TOvcNumericField;
    pmGrid: TPopupMenu;
    FlagAccountasNoCharge1: TMenuItem;
    RemoveNoChargeFlag1: TMenuItem;
    Shape1: TShape;
    Shape2: TShape;
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure tgChargesComboDropDown(Sender: TObject; Combo: TtsComboGrid;
      DataCol, DataRow: Integer);
    procedure tgChargesComboCellLoaded(Sender: TObject;
      Combo: TtsComboGrid; DataCol, DataRow: Integer; var Value: Variant);
    procedure FormDestroy(Sender: TObject);
    procedure tgChargesComboGetValue(Sender: TObject; Combo: TtsComboGrid;
      GridDataCol, GridDataRow, ComboDataRow: Integer; var Value: Variant);
    procedure FormShow(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
    procedure tgChargesCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      ByUser: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkHideClick(Sender: TObject);
    procedure tgChargesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tgChargesEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure btnStoreClick(Sender: TObject);
    procedure tmrAPSTimer(Sender: TObject);
    procedure tgChargesCellChanged(Sender: TObject; OldCol, NewCol, OldRow,
      NewRow: Integer);
    procedure chkFixedClick(Sender: TObject);
    procedure chkPercentClick(Sender: TObject);
    procedure rbAddFixedClick(Sender: TObject);
    procedure rbDistributeClick(Sender: TObject);
    procedure lblViewClick(Sender: TObject);
    procedure cmbMonthsChange(Sender: TObject);
    procedure eDateChange(Sender: TObject);
    procedure btnFindNextClick(Sender: TObject);
    procedure btnFindLastClick(Sender: TObject);
    procedure edtFindChange(Sender: TObject);
    procedure tgChargesColChanged(Sender: TObject; OldCol, NewCol: Integer);
    procedure tgChargesRowChanged(Sender: TObject; OldRow, NewRow: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtFindKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tgChargesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SortGrid();
    procedure rbSetFixedClick(Sender: TObject);
    procedure tgChargesColResized(Sender: TObject; RowColnr: Integer);
    procedure FlagAccountasNoCharge1Click(Sender: TObject);
    procedure pmGridPopup(Sender: TObject);
    procedure RemoveNoChargeFlag1Click(Sender: TObject);
  private
    { Private declarations }
    FExportType: Byte;

    FSortListIndx: Integer;
    FSortColumnIndx: Integer;
    FResizing: Boolean;
    FLineValues: TStringList;
    FCharges : TStringList;
    CurrentPage, DC, DR, LastFoundRow, LastFoundCol: Integer;
    APSResults: TStringList;
    ManualControl, Closing, UserEditedDate, AdjustedWidth,
    GridHasBeenDisplayed, UnsavedData: Boolean;
    FMaintainOnly: Boolean;
    procedure MyCommaText(List: TStringList; Line: string);
    procedure SetExportType(Value: Byte);
    procedure RefreshGrid(Reload: Boolean = True);
    procedure RefreshCharges;
    procedure LoadSysRec(pS: pSystem_Bank_Account_Rec; Row: Integer);
    procedure LoadFileRec(Line: TStringList;pS: pSystem_Bank_Account_Rec; Row: Integer);
    procedure GoToPage(PN: Integer);
    procedure PageChange(Step: Integer);
    procedure WriteExportFile;
    function ValidatePage(PN: Integer; Storing: Boolean = False): Boolean;
    function CurrentMonthWorkFileExists(var Filename: string): Boolean;
    procedure AskAPS(filter: string; apsType: Byte; client: string = '-1');
    function GetAPSId(search: string; apsType: Byte; client: string = '-1'): Integer;
    function ExportToCSVFile(toFile : string): Boolean;
    function ExportToMYOBAOFile(toFile : string; var NumExcludedRows: integer): Boolean;
    function ExportToMYOBFile(toFile : string; var NumExcludedRows: integer): Boolean;
    function CheckChargeIsZero(RowNum: integer): Boolean;
    function GetCSVRowData(forRow : Longint; var IncludeRow: boolean) : String;
    procedure SetButtons(Status: Boolean);
    procedure ActivateCell(c, r: Integer);
    procedure StoreData;
    function NeedtoIncreaseCharges: Boolean;
    function RemarkMatchesMonth(s: string): Boolean;
    procedure SetImportDate;
    function FindNextText(var FoundRow, FoundCol: Integer): Boolean;
    function FindLastText(var FoundRow, FoundCol: Integer): Boolean;
    procedure CheckSearchKey(Key: Word; Shift: TShiftState);
    function ConvertToHandiNumber(s: string; maxVal, maxWidth: Integer): string;
    procedure LoadFromFile(FileName: String);
    procedure DoRebranding();
  public
    { Public declarations }
    property ExportType: Byte read FExportType write SetExportType;
  end;

  procedure DoExportCharges(XType: Byte);
  procedure DoMaintainCharges(PracticeMgmtSys: byte);

const
  MAXPAGES = 3;
  UnitName = 'EXPORTCHARGESFRM';
{$IFDEF TESTAPS}
  TestResult: Array[0..3, 0..1] of string =
  (( 'aperson, xavier', '1000'),
  ( 'aclient', '2'),
  ( 'tester', '3'),
  ( 'abc', '4'));
{$ENDIF}

  colPractice = 1;
  colAcctNo = 2;
  colAcctName = 3;
  colFileCode = 4;
  colCostCode = 5;
  colClientID = 6;
  colMatterID = 7;
  colAssignment = 8;
  colDisbursement = 9;
  colOriginalCharge = 10;
  colIncreasedCharge = 11;

  CHARGES_COLUMN_NAME = 'Charges';
  REMARKS = BRAND_FULL_NAME + ' Charges ';

var
  frmExportCharges: TfrmExportCharges;
  DebugMe: Boolean = false;

implementation

uses
  ReportImages,
  ImagesFrm,
  Globals,
  YesNoDlg,
  WarningMoreFrm,
  ErrorMoreFrm,
  ComObj,
  InfoMoreFrm,
  WinUtils,
  GenUtils,
  bkXPThemes,
  ShellUtils,
  Admin32,
  NewReportUtils,
  NewReportObj,
  RepCols,
  LogUtil,
  sysbio,
  RptAdmin,
  bkHelp,
  BillingdocReaderFrm,
  bkDateUtils,
  StDate,
  EnterPwdDlg,
  glConst,
  ReportFileFormat,
  bkProduct;

{$R *.dfm}

function CustomStringSort(List: TStringList; Index1, Index2: Integer): Integer;
var Value1,Value2: String;
    num1, num2: Double;
begin
  with frmExportCharges do begin
    case (FSortColumnIndx) of
      1..9:
      begin
        FLineValues.Clear;
        FLineValues.CommaText := List[Index1];
        if FLineValues.Count>FSortListIndx then
          Value1 := FLineValues[FSortListIndx];

        FLineValues.Clear;
        FLineValues.CommaText := List[Index2];
        if FLineValues.Count>FSortListIndx then
          Value2 := FLineValues[FSortListIndx];

        result := StrComp( pChar(Value1), pChar(Value2));

      end;

      10..11:
      begin
        num1 := 0;
        num2 := 0;

        FLineValues.Clear;
        FLineValues.CommaText := List[Index1];
        if FLineValues.Count>Ord(FSortListIndx) then
          num1 := StrToFloatDef(FLineValues[FSortListIndx], 0);

        FLineValues.Clear;
        FLineValues.CommaText := List[Index2];
        if FLineValues.Count>FSortListIndx then
          num2 := StrToFloatDef(FLineValues[FSortListIndx], 0);

        if num1 < num2 then
         Result := -1
        else if num1 > num2 then
         Result := 1
        else
         Result := 0;

      end;
      else Result := 0;
    end;
  end;

end;



function IsAPSAvailable: Boolean;
var
  aiObj: OleVariant;
begin
  Result := True;
  {$IFDEF TESTAPS}
  {$Else}
  try
    aiObj := CreateOleObject('aIObject.advData');
  except
    aiObj := Unassigned;
    Result := False;
  end;
  {$EndIf}
end;

// Start the wizard for the given practice management system
procedure DoExportCharges(XType: Byte);
begin
  if (XType <> xcAPS) or IsAPSAvailable then
    with TfrmExportCharges.Create(Application.MainForm) do
      try
        ExportType := XType;
        ShowModal;
      finally
        Free;
      end
  else
    HelpfulErrorMsg('Unable to connect to APS Advance at this time.'#13#13 +
      'Please make sure that APS Advance is installed on this computer.', 0);
end;

procedure DoMaintainCharges(PracticeMgmtSys: byte);
var
  ChargesFrm: TfrmExportCharges;
  FileName: string;
begin
  ChargesFrm := TfrmExportCharges.Create(Application.MainForm);
  try
    ChargesFrm.ExportType := PracticeMgmtSys;
    ChargesFrm.FMaintainOnly := True;
    ChargesFrm.tgCharges.PopupMenu := nil;
    ChargesFrm.RefreshGrid();
    if ChargesFrm.cmbMonths.Items.Count = 0 then
      HelpfulErrorMsg('There is no charges information available.', 0)
    else if not ChargesFrm.CurrentMonthWorkFileExists(Filename) then
      HelpfulErrorMsg(Format('The charges file does not exist (%s).',
                             [ExtractFileName(Filename)]), 0)
    else begin
      ChargesFrm.CurrentPage := 3;
      ChargesFrm.GoToPage(ChargesFrm.CurrentPage);
      ChargesFrm.tgCharges.Col[colOriginalCharge].Visible := False;
      ChargesFrm.tgCharges.Col[colIncreasedCharge].Visible := False;
      ChargesFrm.btnReport.Visible := False;
      ChargesFrm.btnBack.Visible := False;
      ChargesFrm.btnOk.Visible := False;
      ChargesFrm.btnOk.Default := False;
      ChargesFrm.pnlInstructions.Visible := False;
      ChargesFrm.btnStore.Caption := '&OK';
      ChargesFrm.btnStore.Left := ChargesFrm.btnOk.Left;
//      ChargesFrm.btnStore.Default := True; BugzID: 11905
      ChargesFrm.Caption := Format('Maintain File and Cost Codes for %s',
                                   [xcNames[PracticeMgmtSys]]);
      ChargesFrm.pnlHide.Visible := False;
      ChargesFrm.pnlSearch.Parent := ChargesFrm.pnlGrid;
      ChargesFrm.pnlSearch.Align := alTop;
      ChargesFrm.pnlSearch.Height := 35;
      ChargesFrm.pnlSearch.BevelOuter := bvRaised;
      ChargesFrm.ShowModal;
    end;
  finally
    ChargesFrm.Release;
  end
end;

// Set system-specific settings
procedure TfrmExportCharges.SetExportType(Value: Byte);
var
  sBrandFileName: string;
begin
  FExportType := Value;
  Caption := 'Export Charges to ' + xcNames[Value];
  if xcHasFixedFilename[Value] then
  begin
    btnToFolder.Hint := 'Click to Select a Folder';
    eTo.Text := ExtractFilePath(eTo.Text);
  end
  else
    btnToFolder.Hint := 'Click to Select a File';
  eDate.Visible := False;
  lblDate.Visible := False;
  eRemarks.Visible := False;
  lblRemarks.Visible := False;
  sBrandFileName := StringReplace(TProduct.BrandName, ' ', '_', []);
  case Value of
    xcAPS:
      begin
        BKHelpSetup(Self, BKH_Exporting_charges_to_APS_Advance);
        tgCharges.Col[colAssignment].Visible := False;
        tgCharges.Col[colDisbursement].Visible := False;
      end;
    xcMYOB:
      begin
        BKHelpSetup(Self, BKH_Exporting_charges_to_MYOB_AE_Practice_Manager);
        tgCharges.Col[colClientID].Visible := False;
        tgCharges.Col[colMatterID].Visible := False;
        tgCharges.Col[colAcctNo].Width := tgCharges.Col[colAcctNo].Width - 15;
        tgCharges.Col[colDisbursement].Width := tgCharges.Col[colDisbursement].Width - 15;
        tgCharges.Col[colAssignment].Width := tgCharges.Col[colAssignment].Width - 15;
        if ExtractFileName(AdminSystem.fdFields.fdLast_Export_Charges_Saved_To) = '' then
          eTo.Text := eTo.Text + Lowercase(sBrandFileName);
        eTo.Text := ChangeFileExt(eTo.Text, xcFilenames[Value]);
      end;
    xcOther:
      begin
        BKHelpSetup(Self, BKH_Exporting_charges_to_other_practice_management_systems);
        tgCharges.Col[colClientID].Visible := False;
        tgCharges.Col[colMatterID].Visible := False;
        tgCharges.Col[colAssignment].Visible := False;
        tgCharges.Col[colDisbursement].Visible := False;
        tgCharges.Col[colAcctNo].Width := tgCharges.Col[colAcctNo].Width + 25;
        tgCharges.Col[colAcctName].Width := tgCharges.Col[colAcctName].Width + 100;
        if ExtractFileName(AdminSystem.fdFields.fdLast_Export_Charges_Saved_To) = '' then
          eTo.Text := eTo.Text + Lowercase(sBrandFileName);
        eTo.Text := ChangeFileExt(eTo.Text, xcFilenames[Value]);
      end;
    xcMYOBAO:
      begin
        BKHelpSetup(Self, BKH_Exporting_charges_to_MYOB_Accountants_Office);
        tgCharges.Col[colClientID].Visible := False;
        tgCharges.Col[colMatterID].Visible := False;
        tgCharges.Col[colDisbursement].Visible := False;
        tgCharges.Col[colAcctName].Width := tgCharges.Col[colAcctName].Width + 25;
        tgCharges.Col[colFileCode].Heading := 'Client ID';
        tgCharges.Col[colFileCode].MaxLength := 10;
        tgCharges.Col[colCostCode].Heading := 'Work Code';
        tgCharges.Col[colCostCode].MaxLength := 7;
        tgCharges.Col[colAssignment].Heading := 'Job Code';
        tgCharges.Col[colAssignment].MaxLength := 8;
        tgCharges.Col[colAssignment].MaskName := 'sysConvertUpper';
        eDate.Visible := True;
        lblDate.Visible := True;
        eRemarks.Visible := True;
        lblRemarks.Visible := True;
        if ExtractFileName(AdminSystem.fdFields.fdLast_Export_Charges_Saved_To) = '' then
          eTo.Text := eTo.Text + Lowercase(sBrandFileName);
        eTo.Text := ChangeFileExt(eTo.Text, xcFilenames[Value]);
      end;
    xcHandi:
      begin
        BKHelpSetup(Self, BKH_Exporting_charges_to_HandiSoft_Time_and_Billing);
        tgCharges.Col[colClientID].Visible := False;
        tgCharges.Col[colMatterID].Visible := False;
        tgCharges.Col[colDisbursement].Visible := False;
        tgCharges.Col[colAcctName].Width := tgCharges.Col[colAcctName].Width + 25;
        tgCharges.Col[colFileCode].Heading := 'Entity Code';
        tgCharges.Col[colFileCode].MaxLength := 8;
        tgCharges.Col[colCostCode].Heading := 'Activity Code';
        tgCharges.Col[colCostCode].MaxLength := 2;
        tgCharges.Col[colCostCode].MaskName := 'sysShortInteger';
        tgCharges.Col[colAssignment].Heading := 'Cost Code';
        tgCharges.Col[colAssignment].MaxLength := 3;
        tgCharges.Col[colAssignment].MaskName := 'sysShortInteger';
        eDate.Visible := True;
        lblDate.Visible := True;
        eRemarks.Visible := True;
        lblRemarks.Visible := True;
        lblRemarks.Caption := 'Desc&ription';
        if ExtractFileName(AdminSystem.fdFields.fdLast_Export_Charges_Saved_To) = '' then
          eTo.Text := eTo.Text + Lowercase(sBrandFileName);
        eTo.Text := ChangeFileExt(eTo.Text, xcFilenames[Value]);
      end;
    end;
end;

procedure TfrmExportCharges.FormCreate(Sender: TObject);
const
  MAX_MONTHS_TO_SHOW = 15;
  MAX_MONTHS_TO_SEARCH = 36;
var
  D: TDate;
  m, s: Integer;
  Filename: string;
begin
  frmExportCharges := self;

  FCharges := TStringList.Create;
  FLineValues := TStringList.Create;
  FMaintainOnly := False;
  bkXPThemes.ThemeForm( Self);
  lblHeading.Font.Name := Font.Name;
  SetHyperlinkFont(lblView.font);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

  APSResults := TStringList.Create;
  ManualControl := False;
  Closing := False;
  tgCharges.Combo.Grid.RowBarOn := False;
  tgCharges.Col[1].Heading := BCONNECTShort + ' Code';
  DC := -1;
  DR := -1;
  UserEditedDate := False;
  LastFoundRow := 1;
  LastFoundCol := 1;
  AdjustedWidth := False;
  GridHasBeenDisplayed := False;
  UnsavedData := False;

  // List last 15 months and select this month
  cmbMonths.Items.Clear;
  D := Date;
  m := 0;
  s := 0;
  while (m < MAX_MONTHS_TO_SHOW) and (s < MAX_MONTHS_TO_SEARCH) do
  begin
    Filename := DownloadWorkDir + FormatDateTime('mmmyyyy', D) + RptFileFormat.Extensions[rfCSV];
    if BKFileExists(Filename) then
    begin
      cmbMonths.Items.AddObject(FormatDateTime('mmmm', D) + ' ' + FormatDateTime('yy', D), TObject(s));
      Inc(m);
    end;
    Inc(s);
    D := IncMonth(D, -1);
  end;
  cmbMonths.ItemIndex := 0;
  SetImportDate;
  if (AdminSystem.fdFields.fdExport_Charges_Remarks = '') or RemarkMatchesMonth(AdminSystem.fdFields.fdExport_Charges_Remarks) then
    eRemarks.Text := REMARKS + cmbMonths.Text
  else
    eRemarks.Text := AdminSystem.fdFields.fdExport_Charges_Remarks;

  // Remembers last export path/file - strip file if this system doesnt need it
  eTo.Text := AdminSystem.fdFields.fdLast_Export_Charges_Saved_To;
  // Remember increase charges options
  chkFixed.Checked := AdminSystem.fdFields.fdFixed_Charge_Increase;
  chkPercent.Checked := AdminSystem.fdFields.fdPercentage_Charge_Increase;
  ePercent.AsFloat := Money2Double(AdminSystem.fdFields.fdPercentage_Increase_Amount);
  eAddFixed.AsFloat := Money2Double(AdminSystem.fdFields.fdFixed_Dollar_Amount);
  rbAddFixed.Checked := eAddFixed.AsFloat <> 0.0;
  eDistribute.AsFloat :=  Money2Double(AdminSystem.fdFields.fdDistributed_Dollar_Amount);
  rbDistribute.Checked := eDistribute.AsFloat <> 0.0;
  eSetFixed.AsFloat := Money2Double(AdminSystem.fdFields.fdSet_Fixed_Dollar_Amount);
  rbSetFixed.Checked := eSetFixed.AsFloat <> 0.0;
  chkFixed.Checked := (eDistribute.AsFloat <> 0.0) or (eAddFixed.AsFloat <> 0.0) or (eSetFixed.AsFloat <> 0.0);

  DoRebranding();
end;

procedure TfrmExportCharges.FormDestroy(Sender: TObject);
begin
  FLineValues.Free;
  FCharges.Free;
  APSResults.Free;
end;

procedure TfrmExportCharges.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CheckSearchKey(Key, Shift);
end;

// Move to a page in the wizard
procedure TfrmExportCharges.GoToPage(PN: Integer);
var
  m: Integer;
begin
  case PN of
    1:
      begin
        btnReport.Visible := False;
        btnStore.Visible := False;
        btnBack.Enabled := False;
        btnOk.Caption := '&Next >>';
        btnOk.Default := True;        
        pnlOptions.Visible := True;
        pnlAdjust.Visible := False;
        pnlProgress.Visible := False;
        pnlGrid.Visible := False;
        lblHeading.Caption := 'Export Charges Options';
        if xcHasFixedFilename[ExportType] then
          lblTitle.Caption := 'Please select the month to export and the folder to save to. The charges will be exported to the file ' + Lowercase(TProduct.BrandName) + '.csv in the selected folder.'
        else
          lblTitle.Caption := 'Please select the month to export and the file to save to.';
        if FexportType in [xcMYOBAO, xcHandi] then
          lblTitle.Caption := lblTitle.Caption + ' You may also change the import date and ' + Lowercase(StringReplace(lblRemarks.Caption, '&', '', [rfReplaceAll])) + '.';
      end;
    2:
      begin
        btnReport.Visible := False;
        btnStore.Visible := False;
        btnBack.Enabled := True;
        btnOk.Caption := '&Next >>';
        btnOk.Default := True;
        pnlOptions.Visible := False;
        pnlAdjust.Visible := True;
        pnlProgress.Visible := False;
        pnlGrid.Visible := False;
        lblHeading.Caption := 'Increase Charges';
        lblTitle.Caption := 'You may now apply a fixed amount and/or percentage increase to each charge. Note that if you apply both a fixed and percentage amount, the fixed amount is applied first, followed by the percentage increase.';
        lblView.Caption := 'View Statement and Download Documents for ' + cmbMonths.Text;
        lblView.Left := (pnlAdjust.Width - lblView.Width) div 2;
        with TfrmBillingDocReader.Create(Application.MainForm) do
        try
          m := Integer(cmbMonths.Items.Objects[cmbMonths.ItemIndex]);
          lblView.Visible := IsStatementAvailable(GetLastDayOfMonth(IncDate(StDate.CurrentDate, 0, -m, 0)));
        finally
          Free;
        end;
      end;
    3:
      begin
        btnReport.Visible := True;
        btnStore.Visible := True;
        btnBack.Enabled := True;
        btnOk.Caption := '&Finish';
        btnOk.Default := False;
        pnlOptions.Visible := False;
        pnlAdjust.Visible := False;
        pnlProgress.Visible := False;
        pnlGrid.Visible := True;
        lblHeading.Caption := 'Edit Charge Details';
        lblTitle.Caption := 'Edit the client and cost details for ' + cmbMonths.Text + '.';
        //if NeedtoIncreaseCharges then
        begin
          if not AdjustedWidth then
          begin
            tgCharges.Col[colAcctNo].Width := tgCharges.Col[colAcctNo].Width - 10;
            tgCharges.Col[colAcctName].Width := tgCharges.Col[colAcctName].Width - 10;
            AdjustedWidth := True;
          end;
        end;
        if GridHasBeenDisplayed then
          RefreshCharges
        else
          RefreshGrid;
        chkHideClick(Self);
        FResizing := False;
      end;
  end;
end;

procedure TfrmExportCharges.lblViewClick(Sender: TObject);
var
  m: Integer;
begin
  if (AdminSystem.fdFields.fdSystem_Report_Password <> '') and
     (not EnterPwdDlg.EnterPassword( 'Statements and Download Documents',
                                   AdminSystem.fdFields.fdSystem_Report_Password,
                                   0,
                                   pwdNormal,
                                   pwdHidePassword )) then
  begin
    HelpfulErrorMsg( 'A valid password is required to view this report.', 0);
    Exit;
  end;
  try
    with TfrmBillingDocReader.Create(Application.MainForm) do
    try
      m := Integer(cmbMonths.Items.Objects[cmbMonths.ItemIndex]);
      ShowStatement(GetLastDayOfMonth(IncDate(StDate.CurrentDate, 0, -m, 0)));
    finally
      Free;
    end;
  except
  end;
end;

procedure TfrmExportCharges.ActivateCell(c, r: Integer);
begin
  with tgCharges do
  begin
    SetFocus;
    CurrentDataCol := c;
    CurrentDataRow := r;
    PutCellInView(CurrentDataCol, CurrentDataRow);
  end;
end;

// Validate a wizard page
function TfrmExportCharges.ValidatePage(PN: Integer; Storing: Boolean = False): Boolean;
var
  DirPath, Filename, s: string;
  i, x: Integer;
begin
  Result := False;
  case PN of
    1:
      begin
        if cmbMonths.Items.Count = 0 then
        begin
          HelpfulErrorMsg('There are no charges files available to export.', 0);
          cmbMonths.SetFocus;
          Exit;
        end;
        if not CurrentMonthWorkFileExists(Filename) then
        begin
          HelpfulErrorMsg('The charges file for the selected month does not exist.', 0);
          cmbMonths.SetFocus;
          Exit;
        end;
        Filename := '';
        eTo.Text := Trim( eTo.Text);
        if xcHasFixedFilename[FExportType] then // folder expected
        begin
          eTo.Text := AddSlash(eTo.Text);
          DirPath := eTo.Text;
          Filename := DirPath + xcFilenames[ExportType];
        end
        else // file expected
        begin
          if (ExtractFileName(eTo.Text) = '') then
          begin
            HelpfulWarningMsg('You must specify a file name for the extracted charges.', 0);
            eTo.SetFocus;
            exit;
          end;
          DirPath := AddSlash(eTo.Text);
          if DirectoryExists(DirPath) then
          begin
            HelpfulWarningMsg('You can''t use this filename because a directory called ' + DirPath + ' already exists.', 0);
            eTo.SetFocus;
            exit;
          end;
          if ExtractFileExt(eTo.Text) = '.BK5' then
          Begin
            HelpfulWarningMsg('You can''t use this filename because the .BK5 extension is used by ' + TProduct.BrandName + '.', 0);
            eTo.SetFocus;
            exit;
          end;
          // do not allow overwrite of Authority PDFs
          if (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(TPA_FILENAME)) or
             (Lowercase(ExtractFileName( eTo.Text )) = Lowercase(CAF_FILENAME)) then
          begin
             HelpfulWarningMsg('You can''t use this file name because it is reserved for use by '+ShortAppName, 0 );
             eTo.SetFocus;
             exit;
          end;
          DirPath := ExtractFilePath(eTo.Text);
          Filename := eTo.Text;
        end;

        if DirPath = '' then
          DirPath := DATADIR;

        if Lowercase(DirPath) = Lowercase(DownloadWorkDir) then
        begin
          HelpfulWarningMsg('You cannot save to the BK5 Work folder because it is reserved for use by ' + TProduct.BrandName + '.', 0);
          eTo.SetFocus;
          exit;
        end;

        if not DirectoryExists(DirPath) then
        begin
          if AskYesNo('Create Directory',
                      'The folder ' + DirPath + ' does not exist. Do you want to Create it?',
                       DLG_YES,0) <> DLG_YES then begin
            Exit;
          end;

          if not CreateDir(DirPath) then
          begin
            HelpfulErrorMsg('Unable to create directory ' + DirPath + '.', 0);
            eTo.SetFocus;
            Exit;
          end;
        end;

        if (eTo.Text <> '') and BKFileExists(Filename) then
        begin
          if AskYesNo('Overwrite File', 'The file ' + ExtractFileName(Filename) + ' already exists. Overwrite?',
              DLG_YES, 0) <> DLG_YES then
          begin
            eTo.SetFocus;
            exit;
          end;
        end;
        Result := True;
      end;
    2:
      begin
        if chkFixed.Checked then
        begin
          if (rbAddFixed.Checked and (eAddFixed.AsFloat = 0.0)) or
             (rbDistribute.Checked and (eDistribute.AsFloat = 0.0)) or
             (rbSetFixed.Checked and (eSetFixed.AsFloat = 0.0)) then
            chkFixed.Checked := False;
        end;
        if (chkPercent.Checked) and (ePercent.AsFloat = 0.0) then
          chkPercent.Checked := False;

        if chkFixed.Checked then
        begin
          if rbAddFixed.Checked and (eAddFixed.AsFloat < 0) then
          begin
            HelpfulErrorMsg('The fixed dollar amount must be between 0 and 99,999.99',0);
            eAddFixed.SetFocus;
            exit;
          end;
          if rbDistribute.Checked and (eDistribute.AsFloat < 0) then
          begin
            HelpfulErrorMsg('The distributed dollar amount must be between 0 and 99,999.99',0);
            eDistribute.SetFocus;
            exit;
          end;
          if rbSetFixed.Checked and (eSetFixed.AsFloat < 0) then
          begin
            HelpfulErrorMsg('The set fixed dollar amount must be between 0 and 99,999.99',0);
            eSetFixed.SetFocus;
            exit;
          end;

        end;

        if chkPercent.Checked and (ePercent.AsFloat < 0) then
        begin
          HelpfulErrorMsg('The percentage must be between 0 and 9999.99',0);
          ePercent.SetFocus;
          exit;
        end;
        Result := True;
      end;
    3:
      begin
        if NeedToIncreaseCharges then
        begin
          for i := 1 to tgCharges.Rows do
          begin
            s := tgCharges.Cell[colIncreasedCharge, i];

            if s = '' then
              tgCharges.Cell[colIncreasedCharge, i] := '0.00'
            else
            begin
              x := Pos('.', s);
              if x = 0 then
                tgCharges.Cell[colIncreasedCharge, i] := tgCharges.Cell[colIncreasedCharge, i] + '.00'
              else if x = Length(s) then
                tgCharges.Cell[colIncreasedCharge, i] := tgCharges.Cell[colIncreasedCharge, i] + '00'
              else if x = Length(s)-1 then
                tgCharges.Cell[colIncreasedCharge, i] := tgCharges.Cell[colIncreasedCharge, i] + '0';
            end;
          end;
        end;
        if FExportType = xcAPS then // client ID is mandatory
        begin
          for i := 1 to tgCharges.Rows do
          begin
            if (tgCharges.CellTag[colClientID, i] = -1) and (tgCharges.Cell[colClientID, i] <> '') then
              tgCharges.CellTag[colClientID, i] := GetAPSId(tgCharges.Cell[colClientID, i], apsClient);
            if (not Storing) and (tgCharges.CellTag[colClientID, i] = -1) then
            begin
              HelpfulErrorMsg('You must choose a valid Client for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colClientID, i);
              exit;
            end;
            // Matter ID is optional
            if (tgCharges.CellTag[colMatterID, i] = -1) and (tgCharges.Cell[colMatterID, i] <> '') then
            begin
              tgCharges.CellTag[colMatterID, i] := GetAPSId(tgCharges.Cell[colMatterID, i], apsMatter);
              if tgCharges.CellTag[colMatterID, i] = -1 then
              begin
                HelpfulErrorMsg('The Matter you have selected is invalid at charge line ' + IntToStr(i) + '.', 0);
                ActivateCell(colMatterID, i);
                exit;
              end;
            end;
          end;
        end
        else if (not Storing) and (FExportType = xcMYOB) then // assignment and disbursement are mandatory
        begin
          for i := 1 to tgCharges.Rows do
          begin
            x := Pos('/', tgCharges.Cell[colAssignment, i]);
            if x = 0 then
            begin
              HelpfulErrorMsg('The Assignment Code must be in the format CLIENT-CODE/ASSIGNMENT-CODE for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colAssignment, i);
              exit;
            end;
            if tgCharges.Cell[colAssignment, i] = ''  then
            begin
              HelpfulErrorMsg('You must enter an Assignment Code for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colAssignment, i);
              exit;
            end
            else if tgCharges.Cell[colDisbursement, i] = '' then
            begin
              HelpfulErrorMsg('You must enter a Disbursement Code Type for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colDisbursement, i);
              exit;
            end;
          end;
        end
        else if (not Storing) and (FExportType = xcMYOBAO) then
        begin
          for i := 1 to tgCharges.Rows do
          begin
            if Length(tgCharges.Cell[colFileCode, i]) > 10 then
            begin
              HelpfulErrorMsg('The Client ID must not be greater than 10 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colFileCode, i);
              exit;
            end;
            if Trim(tgCharges.Cell[colFileCode, i]) = '' then
            begin
              HelpfulErrorMsg('You must enter a Client ID for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colFileCode, i);
              exit;
            end;
            if Length(tgCharges.Cell[colCostCode, i]) > 7 then
            begin
              HelpfulErrorMsg('The Work Code must not be greater than 7 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colCostCode, i);
              exit;
            end;
            if Trim(tgCharges.Cell[colCostCode, i]) = '' then
            begin
              HelpfulErrorMsg('You must enter a Work Code for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colCostCode, i);
              exit;
            end;
            if Length(tgCharges.Cell[colAssignment, i]) > 8 then
            begin
              HelpfulErrorMsg('The Job Code must not be greater than 8 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colAssignment, i);
              exit;
            end;
          end;
        end
        else if (not Storing) and (FExportType = xcHandi) then
        begin
          for i := 1 to tgCharges.Rows do
          begin
            if Length(tgCharges.Cell[colFileCode, i]) > 8 then
            begin
              HelpfulErrorMsg('The Entity Code must not be greater than 8 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colFileCode, i);
              exit;
            end;
            if Trim(tgCharges.Cell[colFileCode, i]) = '' then
            begin
              HelpfulErrorMsg('You must enter an Entity Code for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colFileCode, i);
              exit;
            end;
            if Length(tgCharges.Cell[colCostCode, i]) > 2 then
            begin
              HelpfulErrorMsg('The Activity Code must not be greater than 2 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colCostCode, i);
              exit;
            end;
            if Trim(tgCharges.Cell[colCostCode, i]) = '' then
            begin
              HelpfulErrorMsg('You must enter an Activity Code for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colCostCode, i);
              exit;
            end;
            if Length(tgCharges.Cell[colAssignment, i]) > 3 then
            begin
              HelpfulErrorMsg('The Cost Code must not be greater than 3 characters for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colAssignment, i);
              exit;
            end;
            if Trim(tgCharges.Cell[colAssignment, i]) = '' then
            begin
              HelpfulErrorMsg('You must enter a Cost Code for charge line ' + IntToStr(i) + '.', 0);
              ActivateCell(colAssignment, i);
              exit;
            end;
          end;
        end;
        Result := True;
      end;
  end;
end;

// New page requested
procedure TfrmExportCharges.PageChange(Step: Integer);
begin
  CurrentPage := CurrentPage + Step;
  if CurrentPage <=1 then
    GoToPage(1)
  else if CurrentPage > MAXPAGES then
    WriteExportFile
  else
    GoToPage(CurrentPage);
end;

procedure TfrmExportCharges.pmGridPopup(Sender: TObject);
var SysAccRec: pSystem_Bank_Account_Rec;
begin
   SysAccRec := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo,tgCharges.CurrentDataRow ]);
   if not Assigned(SysAccRec) then  begin
      FlagAccountasNoCharge1.Enabled := False;
      RemoveNoChargeFlag1.Enabled := False;

   end else begin
      FlagAccountasNoCharge1.Enabled := not SysAccRec.sbNo_Charge_Account;
      RemoveNoChargeFlag1.Enabled := SysAccRec.sbNo_Charge_Account;
   end;
end;

procedure TfrmExportCharges.rbDistributeClick(Sender: TObject);
begin
  eDistribute.Enabled := rbDistribute.Checked;
  eAddFixed.Enabled := not rbDistribute.Checked;
  eSetFixed.Enabled := not rbDistribute.Checked;
end;

procedure TfrmExportCharges.rbSetFixedClick(Sender: TObject);
begin
  eSetFixed.Enabled := rbSetFixed.Checked;
  eDistribute.Enabled := not rbSetFixed.Checked;
  eAddFixed.Enabled := not rbSetFixed.Checked;
end;

procedure TfrmExportCharges.rbAddFixedClick(Sender: TObject);
begin
  eAddFixed.Enabled := rbAddFixed.Checked;
  eDistribute.Enabled := not rbAddFixed.Checked;
  eSetFixed.Enabled := not(rbAddFixed.Checked);
end;

// Write the exported file
procedure TfrmExportCharges.WriteExportFile;
var
  Filename: string;
  OK: Boolean;
  NumExcludedRows: integer;
  NumExportedCharges: integer;
begin
  OK := True;
  NumExcludedRows := 0;
  if xcHasFixedFilename[ExportType] then
  begin
    if eTo.Text = '' then
      Filename := DATADIR + xcFilenames[ExportType]
    else
      Filename := eTo.Text + xcFilenames[ExportType];
  end
  else
  begin
    if ExtractFilePath(eTo.Text) = '' then
      Filename := DATADIR + eTo.Text
    else
      Filename := eTo.Text;
  end;
  StoreData;
  case ExportType of
    xcAPS:   OK := ExportToCSVFile(Filename);
    xcMYOB:  OK := ExportToMYOBFile(FileName, NumExcludedRows);
    xcMYOBAO:OK := ExportToMYOBAOFile(FileName, NumExcludedRows);
    xcHandi: OK := ExportToMYOBAOFile(FileName, NumExcludedRows);
    xcOther: OK := ExportToCSVFile(Filename);
  end;
  if OK then
  begin
    NumExportedCharges := tgCharges.Rows - NumExcludedRows;
    if NumExportedCharges < 0 then // this should never be true
      NumExportedCharges := 0;
    HelpfulInfoMsg('Exported ' + IntToStr(NumExportedCharges) + ' charges to '#13 + Filename + '.', 0);
    Closing := True;
    Close;
  end;
end;

procedure TfrmExportCharges.btnBackClick(Sender: TObject);
begin
  PageChange(-1);
end;

procedure TfrmExportCharges.btnOKClick(Sender: TObject);
begin
  if ValidatePage(CurrentPage) then
    PageChange(1);
end;

procedure TfrmExportCharges.btnCancelClick(Sender: TObject);
begin
  Close;
end;

// Does the expected work file exist
function TfrmExportCharges.CurrentMonthWorkFileExists(var Filename: string): Boolean;
var
  Month: Integer;
begin
  if cmbMonths.Items.Count = 0 then begin
    Result := False;
    Exit;
  end;

  Month := Integer(cmbMonths.Items.Objects[cmbMonths.ItemIndex]);
  Filename := DownloadWorkDir + FormatDateTime('mmmyyyy', IncMonth(Date, -Month)) + RptFileFormat.Extensions[rfCSV];
  Result := BKFileExists(Filename);
end;

procedure TfrmExportCharges.DoRebranding;
begin
  tgCharges.Col[colOriginalCharge].Heading := BRAND_SHORT_NAME + ' Charges';
end;

procedure TfrmExportCharges.eDateChange(Sender: TObject);
begin
  UserEditedDate := True;
end;

procedure TfrmExportCharges.edtFindChange(Sender: TObject);
begin
//  LastFoundRow := 1;
//  LastFoundCol := 1;
end;

procedure TfrmExportCharges.edtFindKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnFindNextClick(Self);
end;

function TfrmExportCharges.ConvertToHandiNumber(s: string; maxVal, maxWidth: Integer): string;
var
  x: Integer;
begin
  if (s = StringOfChar('0', Length(s))) and (s <> '') then
  begin
    if (Length(s) > maxWidth) then
      s := Copy(s, 1, maxWidth)
    else if (Length(s) < maxWidth) then
      s := StringOfChar('0', maxWidth - Length(s)) + s;
    Result := s;
  end else
  begin
    x := StrToIntDef(s, -1);
    if (x <= 0) or (x > maxVal) then
      Result := ''
    else if Length(s) = maxWidth-2 then
      Result := '00' + s
    else if Length(s) = maxwidth-1 then
      Result := '0' + s
    else
      Result := Copy(s, 1, maxWidth)
  end;
end;

procedure TfrmExportCharges.MyCommaText(List: TStringList; Line: string);
  var P: Integer;
      Lookfor: string;
      procedure Add(Value: string);
      begin
         while (Length(Value) > 0)
         and (value[1] in ['"',',',#1..' ']) do
            Value := Copy(Value,2,Length(Value));
         while (Length(Value) > 0)
         and (Value[Length(Value)] in [',','"',#1..' ']) do
            Value := Copy(Value,1,Length(Value)-1);

         List.Add(Value);
      end;
  begin
     List.BeginUpdate;
     try
        List.Clear;
        repeat
           if (Line > '')
           and (Line[1] = '"') then
              Lookfor := '",'
           else
              Lookfor := ',';

           P := Pos(LookFor,Line);
           if P > 0 then begin
              add(Copy(Line,1,P));
              Line := Copy(Line,P + Length(LookFor),Length(Line));
           end else begin
              add(Line); // Last one
              Line := '';
           end;{end;}
        until line = '';

     finally
        List.EndUpdate;
     end;
end;


procedure TfrmExportCharges.LoadFileRec(Line: TStringList;pS: pSystem_Bank_Account_Rec; Row: Integer);
var j: Integer;
begin
    if Assigned(pS) then // copy previous values
        begin
          if pS.sbFile_Code <> '' then
            Line[colFileCode-1] := pS.sbFile_Code;
          if pS.sbCost_Code <> '' then
          begin
            if FExportType = xcMYOBAO then
              Line[colCostCode-1] := Copy(pS.sbCost_Code, 1, 7)
            else if FExportType = xcHandi then
              Line[colCostCode-1] := ConvertToHandiNumber(pS.sbCost_Code, 999, 3)
            else
              Line[colCostCode-1] := pS.sbCost_Code;
          end;
    end;

    if (Line.Count < 6) then // allow more than 6 for future expansion of the work file
       Exit;
    for j := 1 to 6 do
        begin
          if j = 6 then begin

            tgCharges.Cell[colOriginalCharge, Row] := Line[j-1];

          end
          else if (FExportType = xcHandi) and (j = 5) then
            tgCharges.Cell[colAssignment, Row] := Line[j-1]
          else
            tgCharges.Cell[j, Row] := Line[j-1];
        end;

    // Must trim for MYOB AO
     if FExportType = xcMYOBAO then begin

          if Length(tgcharges.Cell[colCostCode, Row]) > 7 then
            tgCharges.Cell[colCostCode, Row] := Copy(tgCharges.Cell[colCostCode, Row], 1, 7);


     end else
     if FExportType = xcHandi then  // Must trim for HandiSoft
        begin
          if Length(tgcharges.Cell[colFileCode, Row]) > 8 then
            tgCharges.Cell[colFileCode, Row] := Copy(tgCharges.Cell[colFileCode, Row], 1, 8);
          tgCharges.Cell[colCostCode, Row] := ConvertToHandiNumber(tgCharges.Cell[colCostCode, Row], 99, 2);
          tgCharges.Cell[colAssignment, Row] := ConvertToHandiNumber(tgCharges.Cell[colAssignment, Row], 999, 3);
        end;

end;

procedure TfrmExportCharges.LoadFromFile(FileName: String);
begin
  FCharges.Clear;
  try
    FCharges.LoadFromFile(Filename);
  except on E: Exception do
    begin
      HelpfulErrorMsg('The file '#13#13 + Filename + #13#13' cannot be accessed.'#13#13 +
        'If you have this file open in another application, such as Microsoft Excel, please close it.', 0);
      PageChange(-1);
      exit;
    end;
  end;
  FCharges.Delete(0); // remove headers before sorting
end;


procedure TfrmExportCharges.LoadSysRec(pS: pSystem_Bank_Account_Rec; Row: Integer);
var x: Integer;
    ID, Description: string;
begin

   if Assigned(pS) then begin
      case FExportType of
      xcAPS: begin
                x := Pos(' ', pS.sbClient_ID);
                if x > 0 then
                begin
                  ID := Copy(pS.sbClient_ID, 1, x - 1);
                  Description := Copy(pS.sbClient_ID, x + 1, Length(pS.sbClient_ID));
                end
                else
                begin
                  ID := '-1';
                  Description := '';
                end;
                tgCharges.CellTag[colClientID, Row] := StrToIntDef(Id, -1);
                tgCharges.Cell[colClientID, Row] := Description;
                x := Pos(' ', pS.sbMatter_ID);
                if x > 0 then
                begin
                  ID := Copy(pS.sbMatter_ID, 1, x - 1);
                  Description := Copy(pS.sbMatter_ID, x + 1, Length(pS.sbMatter_ID));
                end
                else
                begin
                  ID := '-1';
                  Description := '';
                end;
                tgCharges.CellTag[colMatterID, Row] := StrToIntDef(Id, -1);
                tgCharges.Cell[colMatterID, Row] := Description;
              end;
      xcMYOB:
              begin
                tgCharges.Cell[colAssignment, Row] := pS.sbAssignment_ID;
                tgCharges.Cell[colDisbursement, Row] := pS.sbDisbursement_ID;
              end;
      xcMYOBAO:
              begin
                tgCharges.Cell[colAssignment, Row] := pS.sbJob_Code;
              end;
      xcHandi:
              begin
                tgCharges.Cell[colCostCode, Row] := pS.sbActivity_Code;
              end;
      end;
   end else begin
      tgCharges.CellTag[colClientID, Row] := -1;
      tgCharges.CellTag[colMatterID, Row] := -1;
   end;

end;

// Update the main grid with the requested work file
procedure TfrmExportCharges.RefreshGrid(Reload: Boolean = True);
var
  Line: TStringList;
  Filename: string;
  i: Integer;
  pS: pSystem_Bank_Account_Rec;
begin
  if not CurrentMonthWorkFileExists(Filename) then exit;
  Line := TStringList.Create;
  try
    LoadFromFile(FileName);
    try
      FCharges.Sort;
      tgCharges.Rows := FCharges.Count;
      for i := 1 to FCharges.Count do
      begin
        //Line.CommaText := FCharges[i-1];
        MyCommaText(Line, FCharges[i-1]);
        // Now overwrite with system info
        pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(Line[colAcctNo-1]);


        LoadFileRec(Line,ps,I);


        // Now fill additional fields
        LoadSysRec(pS,  i);

      end;

      GridHasBeenDisplayed := True;
      RefreshCharges;
    except
      on E: Exception do
      begin
        HelpfulErrorMsg('The file '#13#13 + Filename + #13#13' is not a valid ' + SHORTAPPNAME + ' charges file.'#13#13 +
                        'Error: ' + E.Message + #13' in line ' + IntToStr(FCharges.Count)
                        +#13+ Line.CommaText, 0);
        PageChange(-1);
      end;
    end;
  finally
    Line.Free;
  end;
end;

// Update the main grid with the requested charge increases
procedure TfrmExportCharges.RefreshCharges;
var
  Filename: string;
  Charge: Double;
  i: Integer;
  pBankAccount: pSystem_Bank_Account_Rec;

  fChargingAccountsCount: integer;

  function ChargingAccountsCount: integer;
  var i: integer;
      pBankAccount: pSystem_Bank_Account_Rec;
  begin
     if fChargingAccountsCount = 0 then begin
        for i := 1 to tgCharges.Rows do begin
           pBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo,i]);
           if tgCharges.Cell[colOriginalCharge, i] <> 0 then begin
             if Assigned(pBankAccount) then begin
               if not pBankAccount.sbNo_Charge_Account then
                  inc(fChargingAccountsCount);
             end else
               inc(fChargingAccountsCount);
           end;
        end;
     end;
     result := fChargingAccountsCount;
  end;

begin
  if not tgCharges.Col[colIncreasedCharge].Visible then exit;
  fChargingAccountsCount := 0;
  for i := 1 to tgCharges.Rows do
  begin
    pBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo,i]);
    Charge := StrToFloatDef(tgCharges.Cell[colOriginalCharge, i],0);

    {$B-}
    if (Assigned(pBankAccount) and pBankAccount.sbNo_Charge_Account)
    or (Charge = 0) then
       tgCharges.Cell[colIncreasedCharge,i] := '0.00'
    else begin
      if chkFixed.Checked and rbAddFixed.Checked then
         tgCharges.Cell[colIncreasedCharge, i] := Charge + eAddFixed.AsFloat
      else if chkFixed.Checked and rbDistribute.Checked then begin
        if (ChargingAccountsCount > 0) then
           tgCharges.Cell[colIncreasedCharge, i] := RoundTo(Charge + (eDistribute.AsFloat / ChargingAccountsCount), -2)
        else
           tgCharges.Cell[colIncreasedCharge, i] := Charge;
      end else if chkFixed.Checked and rbSetFixed.Checked then
        tgCharges.Cell[colIncreasedCharge, i] := eSetFixed.AsFloat
      else
        tgCharges.Cell[colIncreasedCharge, i] := Charge;

      if chkPercent.Checked then
         try
           tgCharges.Cell[colIncreasedCharge, i] := MyRoundTo(tgCharges.Cell[colIncreasedCharge, i] + ((tgCharges.Cell[colIncreasedCharge, i] / 100) * ePercent.AsFloat), 2);
         except
           begin
             CurrentMonthWorkFileExists(Filename);
             HelpfulErrorMsg('The file '#13#13 + Filename + #13#13' is not a valid ' + SHORTAPPNAME + ' charges file.', 0);
             PageChange(-1);
           end;
        end;
    end;//Have Charge
  end;//Row
end;

procedure TfrmExportCharges.btnReportClick(Sender: TObject);
var lDest : TReportDest;
begin
  lDest := rdAsk;
  CreateReportImageList;
  try
     DoListAdminCharges(lDest, tgCharges, FExportType, cmbMonths.Text, NeedtoIncreaseCharges);
  finally
     DestroyReportImageList;
  end;
end;

// Set up the drop-down grid
procedure TfrmExportCharges.tgChargesComboDropDown(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer);
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesComboDropDown Begins' );
  if DataCol = colClientID then
  begin
    if not ManualControl then
      AskAPS(tgCharges.Cell[DataCol, DataRow], apsClient);
    Combo.Grid.Rows := APSResults.Count;
  end
  else if DataCol = colMatterID then
  begin
    if not ManualControl then
    begin
      if (tgCharges.CellTag[colClientID, DataRow] = -1) and (tgCharges.Cell[colClientID, DataRow] <> '') then
        tgCharges.CellTag[colClientID, DataRow] := GetAPSId(tgCharges.Cell[colClientID, DataRow], apsClient);
      AskAPS('', apsMatter, IntToStr(tgCharges.CellTag[colClientID, DataRow]));
    end;
    Combo.Grid.Rows := APSResults.Count;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesComboDropDown ASPResults.Count=' + IntToStr(APSResults.Count) + ' for filtyer=' + tgCharges.Cell[DataCol, DataRow]);
end;

// Set data in drop-down grid
procedure TfrmExportCharges.tgChargesColChanged(Sender: TObject; OldCol,
  NewCol: Integer);
begin
  LastFoundCol := NewCol;
end;

procedure TfrmExportCharges.tgChargesColResized(Sender: TObject;
  RowColnr: Integer);
begin
  FResizing := True;
end;

procedure TfrmExportCharges.tgChargesComboCellLoaded(Sender: TObject;
  Combo: TtsComboGrid; DataCol, DataRow: Integer; var Value: Variant);
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesComboCellLoaded Begins loading DataCol ' + IntToStr(DataCol) +  '  DataRow ' + IntToStr(DataRow));
  if (APSResults.Count >= DataRow) and (tgCharges.CurrentDataCol in [colClientID, colMatterID]) then
  begin
    if DataCol = 1 then
      Value := APSResults[DataRow - 1]
    else
      Value := IntToStr(Integer(APSResults.Objects[DataRow - 1]));
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesComboCellLoaded Ends with Value=' + Value);
  end;
end;

function TfrmExportCharges.GetAPSId(search: string; apsType: Byte; client: string = '-1'): Integer;
var
  i: Integer;
begin
  AskAPS(search, apsType, client);
  i := APSResults.IndexOf(search);
  if i = -1 then
    Result := -1
  else
    Result := Integer(APSResults.Objects[i]);
end;

// Request client or matter list from APS
procedure TfrmExportCharges.AskAPS(filter: string; apsType: Byte; client: string = '-1');
var
  aiObj, varData, varCntx: OleVariant;
  i, j, ID: Integer;
begin
  APSResults.Clear;
{$IFDEF TESTAPS}
  // Testing on machine without APS Advance installed
  if apsType = apsMatter then
  begin
    APSResults.AddObject('My Matter', TObject(2000));
    exit;
  end;
  for i := 0 to 3 do begin
    if (Pos(filter, TestResult[i, 0]) = 1) then
      APSResults.AddObject(TestResult[i, 0], TObject(StrToInt(TestResult[i, 1])));
  end;
  exit;
{$ENDIF}

  if (apsType = apsMatter) and (client = '-1') then
  begin
    HelpfulWarningMsg('Please choose a client ID before selecting the matter.', 0);
    exit;
  end;

  // do not allow lookup of ALL clients in system - APS users are used to this way of working
  if (filter = '') and (apsType = apsClient) then exit;

  // Fill context array for APS-Advance
  varCntx := VarArrayCreate([0, 1, 0, 3], varVariant);
  varCntx[0, 0] := 'ObjectID';
  varCntx[0, 1] := 'ClientID';
  varCntx[0, 2] := 'DisplayFilter';
  varCntx[0, 3] := 'AdditionalDisplayFilter';
  varCntx[1, 0] := apsType;
  varCntx[1, 1] := client;
  varCntx[1, 2] := filter;
  varCntx[1, 3] := '';

  // Call COM object
  try
    aiObj := CreateOleObject('aIObject.advData');
  except
    aiObj := Unassigned;
  end;
  if VarIsEmpty(aiObj) then
    HelpfulErrorMsg('Unable to connect to APS Advance at this time.', 0)
  else
  begin
    try
      i := aiObj.ObjectValues(varData, varCntx);
    finally
      aiObj := Unassigned;
    end;

    // Get results
    if i > 0 then
    begin
      for j := VarArrayLowBound(varData, 2) to VarArrayHighBound(varData, 2) do
      begin
        if (not VarIsEmpty(varData[0, j])) and (not VarIsEmpty(varData[1, j])) then
        begin
          ID := varData[0, j];
          APSResults.AddObject(varData[1, j], TObject(ID));
        end;
      end;
    end;
  end;
end;

// Floating point values may be slightly different from zero
function TfrmExportCharges.CheckChargeIsZero(RowNum: integer): Boolean;
begin
  Result := (Abs(StrToFloat(tgCharges.Cell[colIncreasedCharge, RowNum])) < 0.00000001);
end;

// Get data for a row
function TfrmExportCharges.GetCSVRowData(forRow : Longint; var IncludeRow: boolean) : String;
var
  i: Integer;
  s: string;
begin
  with tgCharges do
  begin
    if CheckChargeIsZero(forRow) and (FExportType in [xcMYOB, xcMYOBAO]) then
    begin
      // No rows with empty charges for MYOB AO/MYOB AE exports
      IncludeRow := False;
      Exit;
    end;
    IncludeRow := True;

    if (FExportType = xcMYOBAO) or (FExportType = xcHandi) then
      Result := FormatDateTime('dd/mm/yy', eDate.Date) + ExportDelimiter
    else
      Result := '';
    for i := 1 to Cols do
    begin
      if (i = colOriginalCharge) then Continue; // Never export direct
      if (FExportType = xcMYOBAO) and (not (i in [colFileCode, colCostCode, colAssignment, colOriginalCharge, colIncreasedCharge])) then Continue;
      if (FExportType = xcHandi) and (not (i in [colFileCode, colCostCode, colAssignment, colOriginalCharge, colIncreasedCharge])) then Continue;
      if (Col[i].ControlType <> ctPicture) and
         (Col[i].Visible) then
      begin
        if i in [colClientID, colMatterID] then
          s := IntToStr(CellTag[i, forRow])
        else
          s := Cell[i, forRow];
        if Pos(ExportDelimiter, s) > 0 then
          Result := Result + AnsiQuotedStr(s, '"')
        else
          Result := Result + s;
       if i < Cols then
          Result := Result + ExportDelimiter;
      end;
    end;
    if (FExportType = xcMYOBAO) or (FExportType = xcHandi) then
      Result := Result + ',' + eRemarks.Text;
  end;
end;

// Export current grid to CSV file
function TfrmExportCharges.ExportToCSVFile(toFile : string): Boolean;
var
  exportFile: TStringList;
  iRow, i: Integer;
  sRowText: String;
  RowData: string;
  IncludeRow: boolean;
begin
  Result := True;
  with tgCharges do
  begin
    EnableRedraw := False;
    exportFile := TStringList.Create;
    try
      sRowText := '';
      for i := 1 to Cols do
      begin
        if (i = colOriginalCharge) then Continue; // Never export direct
        if (Col[i].Visible) and
           (Col[i].ControlType <> ctPicture) then
        begin
          if NeedtoIncreaseCharges and (i = colIncreasedCharge) then
            sRowText := sRowText + CHARGES_COLUMN_NAME
          else
            sRowText := sRowText + Col[i].Heading;
          if I < Cols then
            sRowText := sRowText + ExportDelimiter;
        end;
      end;
      exportFile.Add(sRowText);
      iRow := 1;
      while (iRow <= Rows) do
      begin
        RowData := GetCSVRowData(iRow, IncludeRow);
        if IncludeRow then
          exportFile.Add(RowData);
        Inc(iRow);
      end;
      try
        exportFile.SaveToFile(toFile);
      except on E: Exception do
        begin
          HelpfulErrorMsg('The file '#13#13 + toFile + #13#13' cannot be accessed.'#13#13 +
            'If you have this file open in another application, such as Microsoft Excel, please close it.', 0);
          Result := False;
          PageChange(-1);
          exit;
        end;
      end;
    finally
      exportFile.Free;
      EnableRedraw := True;
    end;
  end;
end;

// Export current grid to MYOB AO file
function TfrmExportCharges.ExportToMYOBAOFile(toFile : string; var NumExcludedRows: integer): Boolean;
var
  exportFile: TStringList;
  iRow, i: Integer;
  sRowText: String;
  RowData: string;
  IncludeRow: boolean;
begin
  Result := True;
  NumExcludedRows := 0;
  with tgCharges do
  begin
    EnableRedraw := False;
    exportFile := TStringList.Create;
    try
      sRowText := 'Date,';
      for i := 1 to Cols do
      begin
        if (i = colOriginalCharge) then Continue;
        if (FExportType = xcMYOBAO) and (not (i in [colFileCode, colCostCode, colAssignment, colOriginalCharge, colIncreasedCharge])) then Continue;
        if (FExportType = xcHandi) and (not (i in [colFileCode, colCostCode, colAssignment, colOriginalCharge, colIncreasedCharge])) then Continue;
        if (Col[i].Visible) and
           (Col[i].ControlType <> ctPicture) then
        begin
          if (i = colIncreasedCharge) or (i = colOriginalCharge) then
            sRowText := sRowText + 'Total'
          else
            sRowText := sRowText + Col[i].Heading;
          if i < Cols then
            sRowText := sRowText + ExportDelimiter;
        end;
      end;
      srowText := sRowText + ',Remarks';
      if FExportType = xcMYOBAO then
        exportFile.Add(sRowText);
      iRow := 1;
      while (iRow <= Rows) do
      begin
        RowData := GetCSVRowData(iRow, IncludeRow);
        if IncludeRow then
          exportFile.Add(RowData)
        else
          Inc(NumExcludedRows);
        Inc(iRow);
      end;
      try
        exportFile.SaveToFile(toFile);
      except on E: Exception do
        begin
          HelpfulErrorMsg('The file '#13#13 + toFile + #13#13' cannot be accessed.'#13#13 +
            'If you have this file open in another application, such as Microsoft Excel, please close it.', 0);
          Result := False;
          PageChange(-1);
          exit;
        end;
      end;
    finally
      exportFile.Free;
      EnableRedraw := True;
    end;
  end;
end;

// Export current grid to MYOB file
{ Tab-delimited:
Date (DD/MM/YYYY)
Assignment Code (20 uppercase chars max) (This is simply a combination of the client code + the appropriate assignment code - e.g. Accounting Assignment = ACC)
Disbursement Code Type (10 chars max) (This would be the code used to on charge Banklink fees )
Per Unit Cost (optional, use 0 if not using)
Number of Units (optional, use 0 if not using)
Charge to client (GST excluded monetary value)
Narration (256 chars max), can be blank}
function TfrmExportCharges.ExportToMYOBFile(toFile : string; var NumExcludedRows: integer): Boolean;
var
  exportFile: TStringList;
  iRow: Integer;
  sRowText: String;
begin
  Result := True;
  NumExcludedRows := 0;
  with tgCharges do
  begin
    EnableRedraw := False;
    exportFile := TStringList.Create;
    try
      iRow := 1;
      while (iRow <= Rows) do
      begin
        if CheckChargeIsZero(iRow) and (FExportType in [xcMYOB, xcMYOBAO]) then
        begin
          inc(NumExcludedRows);
          Inc(iRow);
          Continue; // don't add this row to the export
        end;
{        // strip GST 12.5% in NZ, 10% in AU
        gross := Cell[colCharge, iRow];
        if AdminSystem.fdFields.fdCountry = whAustralia then
          net := gross - (gross / 11)
        else // nz
          net := gross / 1.125;}
        sRowText := FormatDateTime('dd/mm/yyyy', Date) + #9 +
          Uppercase(Cell[colAssignment, iRow]) + #9 +
          Cell[colDisbursement, iRow] + #9 +
          '0' + #9 +
          '0' + #9 +
          FloatToStr(RoundTo(Cell[colIncreasedCharge, iRow], -2)) + #9 +
          '"Imported ' + TProduct.BrandName + ' Charge, File Code=' + Cell[colFileCode, iRow] + ', Cost Code=' + Cell[colCostCode, iRow] + '"';
        exportFile.Add(sRowText);
        Inc(iRow);
      end;
      exportFile.Add(''); // must have blank record at the end
      try
        exportFile.SaveToFile(toFile);
      except on E: Exception do
        begin
          HelpfulErrorMsg('The file '#13#13 + toFile + #13#13' cannot be accessed.'#13#13 +
            'If you have this file open in another application, such as Microsoft Excel, please close it.', 0);
          Result := False;
          PageChange(-1);
          exit;
        end;
      end;
    finally
      exportFile.Free;
      EnableRedraw := True;
    end;
  end;
end;

// Set tag values to store IDs
procedure TfrmExportCharges.tgChargesComboGetValue(Sender: TObject;
  Combo: TtsComboGrid; GridDataCol, GridDataRow, ComboDataRow: Integer;
  var Value: Variant);
begin
  tgCharges.CellTag[GridDataCol, GridDataRow] := Combo.Cell[2, ComboDataRow];
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesComboDropDown Sets GridDataColumn ' + IntToStr(GridDataCol) +
    '  DataGridRow ' + IntToStr(GridDataRow) + ' to value ' + Combo.Cell[2, ComboDataRow]);
end;

procedure TfrmExportCharges.FormShow(Sender: TObject);
begin
  if not FMaintainOnly then begin
    CurrentPage := 1;
    chkFixed.Top := gbFixed.Top - (chkFixed.Height div 2);
    chkPercent.Top := gbPercent.Top - (chkPercent.Height div 2);
    GoToPage(CurrentPage);
  end;
end;

procedure TfrmExportCharges.btnToFolderClick(Sender: TObject);
var
  Test : string;
begin
  if not xcHasFixedFilename[ExportType] then // file needed
  begin
    with SaveDialog1 do
    begin
      FileName := ExtractFileName(eTo.text);
      InitialDir := ExtractFilePath(eTo.text);
      Filter := xcSaveFilters[FExportType];
      if InitialDir = '' then
        InitialDir := DATADIR;
      if Execute then
        eTo.text := Filename;
    end;
  end
  else // folder needed
  begin
    Test := ExtractFilePath(eTo.text);
    if BrowseFolder( test, 'Select the Folder to extract Charges to' ) then
      eTo.text := Test;
  end;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir( Globals.DataDir);
end;

function TfrmExportCharges.FindNextText(var FoundRow, FoundCol: Integer): Boolean;
var
  i, j, StartCol: Integer;
  s: string;
begin
  Result := False;
  FoundRow := LastFoundRow;
  FoundCol := LastFoundCol;
  StartCol := LastFoundCol;
  s := Lowercase(edtFind.Text);
  for i := LastFoundRow to tgCharges.Rows do
  begin
    if i > LastFoundRow then
      StartCol := 1;
    for j := StartCol to tgCharges.Cols do
    begin
      if Pos(s, Lowercase(tgCharges.Cell[j, i])) > 0 then
      begin
        FoundRow := i;
        FoundCol := j;
        Result := True;
        exit;
      end;
    end;
  end;
end;

procedure TfrmExportCharges.FlagAccountasNoCharge1Click(Sender: TObject);
var SysAccRec: pSystem_Bank_Account_Rec;
    Row: Integer;
begin
   Row := tgCharges.CurrentDataRow;
   if Row < 0  then
      Exit;

   if LoadAdminSystem(true, 'TfrmExportCharges.WriteNoCharge' ) then try
      SysAccRec := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo,Row]);

      if not Assigned(SysAccRec) then // offsite account need to add it to sba list
      begin
         SysAccRec := AdminSystem.NewSystemAccount(tgCharges.Cell[colAcctNo, Row], False);
         SysAccRec.sbAccount_Name := tgCharges.Cell[colAcctName, Row];
         SysAccRec.sbBankLink_Code := tgCharges.Cell[colPractice, Row];
      end;

      if SysAccRec.sbNo_Charge_Account then
          Exit; //Already done..

      SysAccRec.sbNo_Charge_Account := True;

   finally
      SaveAdminSystem;
   end;
   if chkHide.Checked then begin
      // just Hide it from the list.
      tgCharges.DeleteRows(tgCharges.CurrentDataRow, Row);
   end else begin
      tgCharges.Cell[colIncreasedCharge,Row] := '0.00';
      RefreshCharges;
   end;
end;


function TfrmExportCharges.FindLastText(var FoundRow, FoundCol: Integer): Boolean;
var
  i, j, StartCol: Integer;
  s: string;
begin
  Result := False;
  FoundRow := LastFoundRow;
  FoundCol := LastFoundCol;
  StartCol := LastFoundCol;
  s := Lowercase(edtFind.Text);
  for i := LastFoundRow downto 1 do
  begin
    if i < LastFoundRow then
      StartCol := 1;
    for j := tgCharges.Cols downto StartCol do
    begin
      if Pos(s, Lowercase(tgCharges.Cell[j, i])) > 0 then
      begin
        FoundRow := i;
        FoundCol := j;
        Result := True;
        exit;
      end;
    end;
  end;
end;

procedure TfrmExportCharges.btnFindLastClick(Sender: TObject);
var
  Row, Col: Integer;
begin
  if edtFind.Text = '' then
  begin
    HelpfulInfoMsg('Please enter the text you would like to search for.', 0);
    edtFind.SetFocus;
    exit;
  end;
  if FindLastText(Row, Col) then
  begin
    ActivateCell(Col, Row);
    LastFoundRow := Row;
    LastFoundCol := Col+1;
  end
  else
    if AskYesno('Find', '"' + edtFind.Text + '" could not be found.'#13#13'Would you like to search again from the end of the grid?',
       DLG_YES,0) = DLG_YES then
    begin
      LastFoundRow := tgCharges.Rows;
      LastFoundCol := 1;
      if FindLastText(Row, Col) then
      begin
        ActivateCell(Col, Row);
        LastFoundRow := Row;
        LastFoundCol := Col+1;
      end
      else
        HelpfulInfoMsg('"' + edtFind.Text + '" was not found.', 0);
    end;
end;

procedure TfrmExportCharges.btnFindNextClick(Sender: TObject);
var
  Row, Col: Integer;
begin
  if edtFind.Text = '' then
  begin
    HelpfulInfoMsg('Please enter the text you would like to search for.', 0);
    edtFind.SetFocus;
    exit;
  end;
  if FindNextText(Row, Col) then
  begin
    ActivateCell(Col, Row);
    LastFoundRow := Row;
    LastFoundCol := Col+1;
  end
  else
    if AskYesno('Find', '"' + edtFind.Text + '" could not be found.'#13#13'Would you like to search again from the start of the grid?',
       DLG_YES,0) = DLG_YES then
    begin
      LastFoundRow := 1;
      LastFoundCol := 1;
      if FindNextText(Row, Col) then
      begin
        ActivateCell(Col, Row);
        LastFoundRow := Row;
        LastFoundCol := Col+1;
      end
      else
        HelpfulInfoMsg('"' + edtFind.Text + '" was not found.', 0);
    end;
end;

// Lookup valid clients/matters in APS
procedure TfrmExportCharges.tgChargesCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
begin
  if FExportType <> xcAPS then exit;
  tmrAPS.Enabled := False;
  DC := -1;
  DR := -1;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'tgChargesCellEdit Begins with cell=' + tgCharges.Cell[DataCol, DataRow]);
  with tgCharges do
  begin
    if not (DataCol in [colClientID, colMatterID]) then exit;
    if APSResults.IndexOf(Cell[DataCol, DataRow]) > -1 then exit; // selected from combo
    // (re)start timer
    DC := DataCol;
    DR := DataRow;
    tmrAPS.Enabled := True;
  end;
end;

procedure TfrmExportCharges.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  result : integer;
begin
  if FMaintainOnly then begin
    if ValidatePage(3, True) then
      CanClose := True;
  end else begin
    if (not Closing) and UnsavedData then
    begin
      result := AskYesNo('Save Changes', 'You have edited the export charges grid but have not yet saved the changes.'#13#13 +
         'Closing the Export Charges Wizard will lose any changes unless you save them.'#13#13 +
         'Save changes now?', DLG_YES, 0, True);
      if result = DLG_YES then
      begin
        if ValidatePage(3, True) then
        begin
          StoreData;
          HelpfulInfoMsg('The charges data has been saved.', 0);
        end
        else
        begin
          HelpfulInfoMsg('The charges data has NOT been saved.', 0);
          exit;
        end;
        CanClose := True;
      end
      else if result = DLG_NO then
        CanClose := True
      else
        CanClose := False;
    end
    else
      CanClose := Closing or (AskYesNo('Extract Charges', 'You have not completed the charges extract.'#13#13 +
        'Are you sure you want to close the Extract Charges Wizard?', DLG_YES, 0) = DLG_YES);
  end;

  if CanClose then
    tmrAPS.Enabled := False;
end;

procedure TfrmExportCharges.SetButtons(Status: Boolean);
begin
  chkHide.Enabled := Status;
  btnReport.Enabled := Status;
  btnBack.Enabled := Status;
  btnOK.Enabled := Status;
  btnCancel.Enabled := Status;
  btnStore.Enabled := Status;
  btnLast.Enabled := Status;
  btnNext.Enabled := Status;
  edtFind.Enabled := Status;
end;

procedure TfrmExportCharges.chkFixedClick(Sender: TObject);
begin
  if chkFixed.Checked and ((not rbAddFixed.Checked) and (not rbDistribute.Checked) and (not rbSetFixed.Checked)) then
    rbAddFixed.Checked := True;
  rbAddFixed.Enabled := chkFixed.Checked;
  rbDistribute.Enabled := chkFixed.Checked;
  rbSetFixed.Enabled := chkFixed.Checked; 
  eAddFixed.Enabled := chkFixed.Checked and rbAddFixed.Checked;
  eDistribute.Enabled := chkFixed.Checked and rbDistribute.Checked;
  eSetFixed.Enabled := chkFixed.Checked and rbSetFixed.Checked;
end;

procedure TfrmExportCharges.chkHideClick(Sender: TObject);
const
  THRESHOLD = 250;
var
  i, j: Integer;
  pS: pSystem_Bank_Account_Rec;
  IsInGrid: Boolean;
  Line : TStringList;
begin
  if chkHide.Checked then // remove all rows with 0 charges
  begin
    i := 1;
    if tgCharges.Rows > THRESHOLD then // show progress
    begin
      pnlProgress.Visible := True;
      SetButtons(False);
      tgCharges.Visible := False;
      pbGrid.Position := 0;
      pbGrid.Step := 1;
      pbGrid.Max := tgCharges.Rows;
    end;
    try
      while i <= tgCharges.Rows do
      begin

        if tgCharges.Cell[colIncreasedCharge, i] = '0.00' then
        begin
          pbGrid.StepIt;
          Application.ProcessMessages;
          tgCharges.DeleteRows(i, i)
        end
        else
          Inc(i);
      end;
    finally
      tgCharges.Visible := True;
      pnlProgress.Visible := False;
      SetButtons(True);
    end;
  end
  else // add all system accounts
  begin
    if AdminSystem.fdSystem_Bank_Account_List.Last > THRESHOLD then // show progress
    begin
      pnlProgress.Visible := True;
      SetButtons(False);
      tgCharges.Visible := False;
      pbGrid.Position := 0;
      pbGrid.Step := 1;
      pbGrid.Max := AdminSystem.fdSystem_Bank_Account_List.Last;
    end;

    Line := TStringList.Create;

    tgCharges.BeginUpdate;
    try
      for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
      begin
        pS := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
        IsInGrid := False;
        for j := 1 to tgCharges.Rows do // is it already in grid
        begin
          if tgCharges.Cell[colAcctNo, j] = pS.sbAccount_Number then
          begin
            IsInGrid := True;
            Break;
          end;
        end;
        pbGrid.StepIt;
        Application.ProcessMessages;
        if not IsInGrid then
        begin
          tgCharges.Rows := tgCharges.Rows + 1;
          tgCharges.Cell[colPractice, tgCharges.Rows] := pS.sbBankLink_Code;
          tgCharges.Cell[colAcctNo, tgCharges.Rows] := pS.sbAccount_Number;
          tgCharges.Cell[colAcctName, tgCharges.Rows] := pS.sbAccount_Name;
          tgCharges.Cell[colFileCode, tgCharges.Rows] := pS.sbFile_Code;
          if FExportType = xcHandi then
            tgCharges.Cell[colAssignment, tgCharges.Rows] := pS.sbCost_Code
          else
            tgCharges.Cell[colCostCode, tgCharges.Rows] := pS.sbCost_Code;
          tgCharges.Cell[colOriginalCharge, tgCharges.Rows] := '0.00';
          tgCharges.Cell[colIncreasedCharge, tgCharges.Rows] := '0.00';

          for j := 0 to FCharges.Count - 1 do begin
             MyCommaText(Line, FCharges[j]);
             if Sametext(Line[1],pS.sbAccount_Number) then begin
                loadFilerec(Line,ps,tgCharges.Rows);
             end;
          end;


          LoadSysRec(ps,tgCharges.Rows);

        end;

      end;
       SortGrid;
    finally
      Line.Free;
      tgCharges.EndUpdate;
      tgCharges.Visible := True;
      pnlProgress.Visible := False;
      SetButtons(True);
    end;
  end;
end;

procedure TfrmExportCharges.chkPercentClick(Sender: TObject);
begin
  ePercent.Enabled := chkPercent.Checked;
  lblPercent.Enabled := chkPercent.Checked;
end;

function TfrmExportCharges.RemarkMatchesMonth(s: string): Boolean;
var
  i: Integer;
  iPos: integer;
begin
  for i := 0 to Pred(cmbMonths.Items.Count) do
  begin
    iPos := Pos(cmbMonths.Items[i], s);
    if (iPos <> 0) then
    begin
      Result := True;
      exit;
    end;
  end;

  Result := False;
end;

procedure TfrmExportCharges.RemoveNoChargeFlag1Click(Sender: TObject);
var SysAccRec: pSystem_Bank_Account_Rec;
    Row: Integer;
begin
   Row := tgCharges.CurrentDataRow;
   if Row < 0 then
      Exit;
   if LoadAdminSystem(true, 'TfrmExportCharges.WriteNoCharge' ) then try
      SysAccRec := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo,Row]);

      if not Assigned(SysAccRec) then // offsite account need to add it to sba list
      begin
         SysAccRec := AdminSystem.NewSystemAccount(tgCharges.Cell[colAcctNo, Row], False);
         SysAccRec.sbAccount_Name := tgCharges.Cell[colAcctName, Row];
         SysAccRec.sbBankLink_Code := tgCharges.Cell[colPractice, Row];
      end;

      if not SysAccRec.sbNo_Charge_Account then
         Exit; //Already done..
      SysAccRec.sbNo_Charge_Account := False;
   finally
      SaveAdminSystem;
   end;


   RefreshCharges;
end;


procedure TfrmExportCharges.SetImportDate;
var
  yy, mm, dd: Word;
  m: Integer;  
begin
  if cmbMonths.ItemIndex > -1 then
  begin
    m := Integer(cmbMonths.Items.Objects[cmbMonths.ItemIndex]);
    DecodeDate(IncMonth(Date, -m), yy, mm, dd);
    eDate.Date := EncodeDate(yy, mm, MonthDays[IsLeapYear(yy), mm]);
  end
  else
    eDate.Date := Date;
end;

procedure TfrmExportCharges.cmbMonthsChange(Sender: TObject);
begin
  if UnsavedData and (AskYesNo('Save Changes', 'You have edited the export charges grid but have not yet saved the changes.'#13#13 +
       'Changing the export month will lose any changes unless you save them.'#13#13 +
       'Save changes now?', DLG_YES, 0) = DLG_YES) then
  begin
    if ValidatePage(3, True) then
    begin
      StoreData;
      HelpfulInfoMsg('The charges data has been saved.', 0);
    end
    else
    begin
      HelpfulInfoMsg('The charges data has NOT been saved.', 0);
      exit;
    end;
  end;
  GridHasBeenDisplayed := False;
  if RemarkMatchesMonth(eRemarks.Text) then
    eRemarks.Text := REMARKS + cmbMonths.Text;
  if (not UserEditedDate) then
    SetImportDate;
end;

procedure TfrmExportCharges.tgChargesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Key = VK_DELETE) or (Key = VK_BACK)) and (tgCharges.CurrentDataCol = colMatterID) then
  begin
    tgCharges.CellTag[colMatterID, tgCharges.CurrentDataRow] := -1;
    tgCharges.Cell[colMatterID, tgCharges.CurrentDataRow] := '';
  end;
  if (Chr(Key) in ['0'..'9','a'..'z','A'..'Z','/','\', Chr(VK_DELETE), Chr(VK_BACK)]) then
    UnsavedData := True;
  CheckSearchKey(Key, Shift);
end;

//Using this because grid does not fire other click events on editable columns
procedure TfrmExportCharges.tgChargesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DisplayCol,DisplayRow: Integer;
  ActualCol: Integer;
  i: integer;
begin
  tgCharges.CellFromXY(X,Y,DisplayCol,DisplayRow);
  if (DisplayCol = -1) then Exit;

  ActualCol := tgCharges.DataColnr[DisplayCol];
  if Y<=tgCharges.HeadingHeight then
  begin
    if NOT(FResizing) and (FSortColumnIndx <> DisplayCol) then
    begin
      Self.FSortColumnIndx := DisplayCol;
      SortGrid();

      //Set sort indicator
      for i := 1 to tgCharges.Cols do
      begin
        tgCharges.Col[i].SortPicture := TSGrid.spNone;
      end;
      tgCharges.Col[ActualCol].SortPicture := TSGrid.spDown;

    end;
    FResizing := False;
  end;
end;

//Gets all Values in grid and resorts
procedure TfrmExportCharges.SortGrid();
var FGridRows,FValues : TStringList;
    i,Indx: Integer;
    j: Integer;
begin
  FGridRows := TStringList.Create;
  FValues   := TStringList.Create;
  tgCharges.BeginUpdate;
  try

    //Load Grid Values into String List
    for i := 1 to tgCharges.Rows do
    begin
      FValues.Clear;
      Indx := 0;
      for j := 1 to tgCharges.Cols do
      begin
        if tgCharges.Col[j].Visible then begin
           Indx := Indx+1;
           if j=FSortColumnIndx then
             FSortListIndx := Indx-1;
           FValues.Add(tgCharges.Cell[j,i]);
        end;
        if j in [colClientID, colMatterID] then begin
           Indx := Indx+1;
           FValues.Add(intToStr(tgCharges.CellTag[j,i]));
        end;
      end;
      FGridRows.Add(FValues.CommaText);
    end;
    //Sort Values
    FGridRows.CustomSort(CustomStringSort);

    //Clear Grid Values
    for i := 1 to tgCharges.Rows do
    begin
      for j := 1 to tgCharges.Cols do begin
         if j in [colClientID, colMatterID] then
            tgCharges.CellTag[j,i]:= -1;
         if tgCharges.Col[j].Visible then
            tgCharges.Cell[j,i] := '';
      end;
    end;

    //Reload Grid Values
    tgCharges.Rows := FGridRows.Count;
    for i := 1 to FGridRows.Count do
    begin
      Indx := 0;
      FValues.Commatext := FGridRows[i-1];
      for j := 1 to tgCharges.Cols do begin
        if tgCharges.Col[j].Visible then begin
           tgCharges.Cell[j,i] := FValues[Indx];
           Indx := Indx+1;
        end;
        if j in [colClientID, colMatterID] then begin
           tgCharges.CellTag[j,i] := StrToIntDef(FValues[Indx], -1);
           Indx := Indx+1;
        end;
      end;

    end;

  finally
    FGridRows.Free;
    FValues.Free;
    tgCharges.EndUpdate;
  end;
end;

procedure TfrmExportCharges.tgChargesRowChanged(Sender: TObject; OldRow,
  NewRow: Integer);
begin
  LastFoundRow := NewRow;
end;

procedure TfrmExportCharges.tgChargesEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
begin
  if DataCol in [colFileCode, colCostCode, colAssignment, colDisbursement] then // trim spaces
    tgCharges.Cell[DataCol, DataRow] := Trim(tgCharges.Cell[DataCol, DataRow]);
  if FExportType = xcHandi then
  begin
    if DataCol = colCostCode then
      tgCharges.Cell[DataCol, DataRow] := ConvertToHandiNumber(tgCharges.Cell[DataCol, DataRow], 99, 2)
    else if DataCol = colAssignment then
      tgCharges.Cell[DataCol, DataRow] := ConvertToHandiNumber(tgCharges.Cell[DataCol, DataRow], 999, 3);
  end;
  tgCharges.Invalidate; // Case 10929
end;

procedure TfrmExportCharges.btnStoreClick(Sender: TObject);
begin
  if ValidatePage(CurrentPage, True) then
  begin
    StoreData;
    if FMaintainOnly then
      Close
    else
      HelpfulInfoMsg('The charges data has been saved.', 0);
  end;
end;

procedure TfrmExportCharges.StoreData;
var
  i: Integer;
  pS: pSystem_Bank_Account_Rec;
begin
  if LoadAdminSystem(true, 'TfrmExportCharges.WriteExportFile' ) then
  begin
    AdminSystem.fdFields.fdLast_Export_Charges_Saved_To := eTo.Text;
    AdminSystem.fdFields.fdExport_Charges_Remarks := eRemarks.Text;
    AdminSystem.fdFields.fdFixed_Charge_Increase := chkFixed.Checked;
    AdminSystem.fdFields.fdPercentage_Charge_Increase := chkPercent.Checked;
    if chkPercent.Checked then
      AdminSystem.fdFields.fdPercentage_Increase_Amount := Double2Money(ePercent.AsFloat)
    else
      AdminSystem.fdFields.fdPercentage_Increase_Amount := 0.0;
    if chkFixed.Checked and rbAddFixed.Checked then
      AdminSystem.fdFields.fdFixed_Dollar_Amount := Double2Money(eAddFixed.AsFloat)
    else
      AdminSystem.fdFields.fdFixed_Dollar_Amount := 0.0;
    if chkFixed.Checked and rbDistribute.Checked then
      AdminSystem.fdFields.fdDistributed_Dollar_Amount := Double2Money(eDistribute.AsFloat)
    else
      AdminSystem.fdFields.fdDistributed_Dollar_Amount := 0.0;
    if chkFixed.Checked and rbSetFixed.Checked then
      AdminSystem.fdFields.fdSet_Fixed_Dollar_Amount := Double2Money(eSetFixed.AsFloat)
    else
      AdminSystem.fdFields.fdSet_Fixed_Dollar_Amount := 0.0;


    // Update all system bank account records
    for i := 1 to tgCharges.Rows do
    begin
      pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(tgCharges.Cell[colAcctNo, i]);
      if not Assigned(ps) then // offsite account need to add it to sba list
      begin
        pS := AdminSystem.NewSystemAccount(tgCharges.Cell[colAcctNo, i], False);
        pS.sbAccount_Name := tgCharges.Cell[colAcctName, i];
        pS.sbBankLink_Code := tgCharges.Cell[colPractice, i];
      end;

      if Assigned(pS) then
      begin
        if FExportType = xcHandi then
          pS.sbCost_Code := tgCharges.Cell[colAssignment, i]
        else
          pS.sbCost_Code := tgCharges.Cell[colCostCode, i];
        pS.sbFile_Code := tgCharges.Cell[colFileCode, i];
        if FExportType = xcAPS then
        begin
          pS.sbClient_ID := IntToStr(tgCharges.CellTag[colClientID, i]) + ' ' + tgCharges.Cell[colClientID, i];
          pS.sbMatter_ID := IntToStr(tgCharges.CellTag[colMatterID, i]) + ' ' + tgCharges.Cell[colMatterID, i];
        end
        else if FExportType = xcMYOB then
        begin
          pS.sbAssignment_ID := tgCharges.Cell[colAssignment, i];
          pS.sbDisbursement_ID := tgCharges.Cell[colDisbursement, i];
        end
        else if FExportType = xcMYOBAO then
          pS.sbJob_Code := tgCharges.Cell[colAssignment, i]
        else if FExportType = xcHandi then
          pS.sbActivity_Code := tgCharges.Cell[colCostCode, i];
      end;
    end;
    SaveAdminSystem;
    UnsavedData := False;
  end
  else
    HelpfulWarningMsg('Could not update admin system at this time. Admin System unavailable.',0);  
end;

procedure TfrmExportCharges.tmrAPSTimer(Sender: TObject);
begin
  tmrAPS.Enabled := False;
  with tgCharges do
  begin
    ManualControl := True;
    HideCombo;
    CellTag[DC, DR] := -1;
    if DC = colClientID then
    begin
      AskAPS(Cell[colClientID, DR], apsClient);
      CellTag[colMatterID, DR] := -1;
      Cell[colMatterID, DR] := '';
    end
    else if DC = colMatterID then
      AskAPS('', apsMatter, IntToStr(CellTag[colClientID, DR]));
    Combo.Grid.Rows := APSResults.Count;
    if APSResults.Count > 0 then
      ShowCombo;
    Combo.Grid.RefreshData(roBoth, rpNone);
    ManualControl := False;
  end;
end;

procedure TfrmExportCharges.tgChargesCellChanged(Sender: TObject; OldCol,
  NewCol, OldRow, NewRow: Integer);
var
  x: Integer;
  Client, Assignment: string;
begin
  tmrAPS.Enabled := False;
  if (FExportType = xcMYOB) and (OldCol = colAssignment) and (tgCharges.Cell[colAssignment, OldRow] <> '') then
  begin
    x := Pos('/', tgCharges.Cell[colAssignment, OldRow]);
    if x = 0 then
    begin
      HelpfulErrorMsg('The Assignment Code must be in the format CLIENT-CODE/ASSIGNMENT-CODE for charge line ' + IntToStr(OldRow) + '.', 0);
      tgCharges.OnCellChanged := nil;
      ActivateCell(colAssignment, OldRow);
      tgCharges.OnCellChanged := tgChargesCellChanged;
    end
    else // check client and assignment are not blank
    begin
      Client := Copy(tgCharges.Cell[colAssignment, OldRow], 1, x-1);
      Assignment := Copy(tgCharges.Cell[colAssignment, OldRow], x+1, Length(tgCharges.Cell[colAssignment, OldRow]));
      if (Client = '') or (Assignment = '') then
      begin
        HelpfulErrorMsg('You must enter a client code and an assignment code in the format CLIENT-CODE/ASSIGNMENT-CODE for charge line ' + IntToStr(OldRow) + '.', 0);
        tgCharges.OnCellChanged := nil;
        ActivateCell(colAssignment, OldRow);
        tgCharges.OnCellChanged := tgChargesCellChanged;
      end;
    end;
  end;
end;

function TfrmExportCharges.NeedtoIncreaseCharges: Boolean;
begin
  Result := chkFixed.Checked or chkPercent.Checked;
end;

procedure TfrmExportCharges.CheckSearchKey(Key: Word; Shift: TShiftState);
begin
  if (ssShift in Shift) and (Key = VK_F3) then
    btnFindLastClick(Self)
  else if Key = VK_F3 then
    btnFindNextClick(Self);
end;

initialization
   DebugMe := DebugUnit( UnitName );

end.

