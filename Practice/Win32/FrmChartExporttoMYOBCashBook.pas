unit FrmChartExportToMYOBCashBook;

//------------------------------------------------------------------------------
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
  OSFont,
  StdCtrls,
  ovcbase,
  ovcef,
  ovcpb,
  ovcpf,
  Buttons,
  ExtCtrls,
  stDate;

type
  TCalcOpeningBalanceEvent = procedure(aOpeningBalanceDate : TstDate;
                                       var aNonBasicCodesHaveBalances : boolean;
                                       var aNonBasicCodes : TStringList) of object;

  //----------------------------------------------------------------------------
  TExportChartFrmProperties = class
  private
    fExportBasicChart : boolean;
    fIncludeOpeningBalances : boolean;
    fOpeningBalanceDate: TStDate;
    fClientCode : string;
    fExportFileLocation : string;
    fAreGSTAccountSetup : boolean;
    fAreOpeningBalancesSetup : boolean;
    fNonBasicCodesHaveBalances : boolean;
    fIsTransactionsUncodedorInvalidlyCoded : boolean;
    fCalcOpeningBalanceEvent : TCalcOpeningBalanceEvent;
  public
    NonBasicCodes : TStringList;

    constructor Create;
    destructor Destroy; override;

    procedure CalcOpeningBalance(aOpeningBalanceDate : TstDate);

    property ExportBasicChart : boolean read fExportBasicChart write fExportBasicChart;
    property IncludeOpeningBalances : boolean read fIncludeOpeningBalances write fIncludeOpeningBalances;
    property OpeningBalanceDate: TStDate read fOpeningBalanceDate write fOpeningBalanceDate;
    property ClientCode : string read fClientCode write fClientCode;
    property ExportFileLocation : string read fExportFileLocation write fExportFileLocation;
    property AreGSTAccountSetup : boolean read fAreGSTAccountSetup write fAreGSTAccountSetup;
    property AreOpeningBalancesSetup : boolean read fAreOpeningBalancesSetup write fAreOpeningBalancesSetup;
    property NonBasicCodesHaveBalances : boolean read fNonBasicCodesHaveBalances write fNonBasicCodesHaveBalances;
    property IsTransactionsUncodedorInvalidlyCoded : boolean read  fIsTransactionsUncodedorInvalidlyCoded
                                                             write fIsTransactionsUncodedorInvalidlyCoded;
    property CalcOpeningBalanceEvent : TCalcOpeningBalanceEvent read fCalcOpeningBalanceEvent write fCalcOpeningBalanceEvent;
  end;

  //------------------------------------------------------------------------------
  TFrmChartExportToMYOBCashBook = class(TForm)
    SaveDialog: TSaveDialog;
    pnlMain: TPanel;
    lblExportText: TLabel;
    radExportFullChart: TRadioButton;
    radExportBasicChart: TRadioButton;
    chkIncludeClosingBalances: TCheckBox;
    lblClosingBalanceDate: TLabel;
    lblSaveEntriesTo: TLabel;
    edtSaveEntriesTo: TEdit;
    btnToFolder: TSpeedButton;
    OvcController: TOvcController;
    dteClosingBalanceDate: TOvcPictureField;
    pnlControls: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    ShapeBorder: TShape;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkIncludeClosingBalancesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure dteClosingBalanceDateDblClick(Sender: TObject);
  private
    fOkPressed : boolean;
    fExportChartFrmProperties : TExportChartFrmProperties;
    fLoading : boolean;
  protected
    procedure DoRebranding();
    function ValidateForm : boolean;
  public
    function Execute : boolean;

    property ExportChartFrmProperties : TExportChartFrmProperties read fExportChartFrmProperties write fExportChartFrmProperties;
  end;

  //----------------------------------------------------------------------------
  function ShowChartExport(w_PopupParent: Forms.TForm; aExportChartFrmProperties : TExportChartFrmProperties) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ImagesFrm,
  BKConst,
  YesNoDlg,
  glConst,
  BKHelp,
  GenUtils,
  stDatest,
  ErrorMoreFrm;

//------------------------------------------------------------------------------
function ShowChartExport(w_PopupParent: Forms.TForm; aExportChartFrmProperties : TExportChartFrmProperties) : boolean;
var
  MyDlg : TFrmChartExportToMYOBCashBook;
begin
  MyDlg := TFrmChartExportToMYOBCashBook.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.ExportChartFrmProperties := aExportChartFrmProperties;

    BKHelpSetUp(MyDlg, BKH_Export_chart_to_COMPANY_NAME1_Essentials_Cashbook);
    Result := MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TExportChartFrmProperties }
//------------------------------------------------------------------------------
procedure TExportChartFrmProperties.CalcOpeningBalance(aOpeningBalanceDate: TstDate);
var
  NonBasicCodesHaveBal: boolean;
begin
  if Assigned(fCalcOpeningBalanceEvent) then
  begin
    fCalcOpeningBalanceEvent(aOpeningBalanceDate, NonBasicCodesHaveBal, NonBasicCodes);
    NonBasicCodesHaveBalances := NonBasicCodesHaveBal;
  end;
end;

{ TFrmChartExportToMYOBCashBook }
//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if fOkPressed then
  begin
    fOkPressed := false;

    CanClose := ValidateForm();
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.chkIncludeClosingBalancesClick(Sender: TObject);
  //----------------------------------------------------------------------------
  function AddSpaceAfterComma(aInstring : string) : string;
  var
    Index : integer;
  begin
    Result := '';
    for Index := 1 to length(aInstring) do
    begin
      Result := Result + aInstring[Index];

      if aInstring[Index] = ',' then
        Result := Result + ' ';
    end;
  end;  

begin
  if (chkIncludeClosingBalances.Checked) and
     (not fLoading) then
  begin

    if not ExportChartFrmProperties.AreOpeningBalancesSetup then
    begin
      if not (AskYesNo('Opening balances not been set',
                       'Opening balances have not been set under Data Entry | ' +
                       'Opening Balances. Would you like to continue?', dlg_yes, 0) = DLG_YES) then
      begin
        chkIncludeClosingBalances.Checked := false;
        Exit;
      end;
    end;

    ExportChartFrmProperties.CalcOpeningBalance(dteClosingBalanceDate.AsStDate);
    if (ExportChartFrmProperties.NonBasicCodesHaveBalances) and
       (radExportBasicChart.Checked) then
    begin
      HelpfulErrorMsg('The following account codes contain balances and are not flagged as basic: ' + #13#10#13#10 +
                      '      ' + AddSpaceAfterComma(ExportChartFrmProperties.NonBasicCodes.DelimitedText) + #13#10#13#10 +
                      'Please flag these account codes as basic codes under Other Functions | Chart of Accounts | Maintain Chart.',0);
      chkIncludeClosingBalances.Checked := false;
      Exit;
    end;

    if ExportChartFrmProperties.IsTransactionsUncodedorInvalidlyCoded then
    begin
      HelpfulErrorMsg('There are uncoded or invalidly coded transactions for the period. The closing balance cannot be calculated.',0);
      chkIncludeClosingBalances.Checked := false;
      Exit;
    end;
  end;

  dteClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
  lblClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormActivate(Sender: TObject);
begin
  chkIncludeClosingBalancesClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.btnOkClick(Sender: TObject);
begin
  fOkPressed := true;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.btnToFolderClick(Sender: TObject);
begin
  SaveDialog.FileName := ExtractFileName(edtSaveEntriesTo.text);
  SaveDialog.InitialDir := ExtractFilePath(edtSaveEntriesTo.text);

  if SaveDialog.Execute then
    edtSaveEntriesTo.Text := SaveDialog.FileName;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.DoRebranding;
begin
  lblExportText.Caption := 'Export ' + BRAND_FULL_PRACTICE +
                           ' chart of accounts to .CSV file for import into MYOB Essentials Cashbook.';
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.dteClosingBalanceDateDblClick(
  Sender: TObject);
var
  ld: Integer;
begin
  if sender is TOVcPictureField then
  begin
    ld := TOVcPictureField(Sender).AsStDate;
    PopUpCalendar(TEdit(Sender),ld);
    TOVcPictureField(Sender).AsStDate := ld;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.ValidateForm: boolean;
begin
  if FileExists(edtSaveEntriesTo.Text) then
  begin
    if not (AskYesNo('Overwrite File','The file ' +
                    ExtractFileName(edtSaveEntriesTo.Text) +
                    ' already exists. Overwrite?', dlg_yes, 0) = DLG_YES) then
    begin
      Result := false;
      Exit;
    end;
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.Execute: boolean;
begin
  fLoading := true;
  fOkPressed := false;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

  // Load Default Properties
  if Assigned(ExportChartFrmProperties) then
  begin
    Self.Caption := 'Export ' + ExportChartFrmProperties.ClientCode + '''s Chart of Accounts to MYOB Essentials Cashbook';

    if ExportChartFrmProperties.ExportBasicChart then
      radExportBasicChart.Checked := true
    else
      radExportFullChart.Checked := true;

    chkIncludeClosingBalances.Checked := ExportChartFrmProperties.IncludeOpeningBalances;
    dteClosingBalanceDate.AsStDate := ExportChartFrmProperties.OpeningBalanceDate;
    edtSaveEntriesTo.Text := ExportChartFrmProperties.ExportFileLocation;
  end;

  fLoading := false;
  Result := (ShowModal = mrOK);

  // if ok Save Properties
  if Result then
  begin
    if Assigned(ExportChartFrmProperties) then
    begin
      ExportChartFrmProperties.ExportBasicChart := (radExportBasicChart.Checked);
      ExportChartFrmProperties.IncludeOpeningBalances := chkIncludeClosingBalances.Checked;
      ExportChartFrmProperties.OpeningBalanceDate := dteClosingBalanceDate.AsStDate;
      ExportChartFrmProperties.ExportFileLocation := edtSaveEntriesTo.Text;

      if ExportChartFrmProperties.IncludeOpeningBalances then
      begin
        ExportChartFrmProperties.CalcOpeningBalance(ExportChartFrmProperties.OpeningBalanceDate);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TExportChartFrmProperties.Create;
begin
  NonBasicCodes := TStringList.create;
  NonBasicCodes.Delimiter := ',';
  NonBasicCodes.StrictDelimiter := True;
end;

//------------------------------------------------------------------------------
destructor TExportChartFrmProperties.Destroy;
begin
  FreeAndNil(NonBasicCodes);

  inherited;
end;

end.
