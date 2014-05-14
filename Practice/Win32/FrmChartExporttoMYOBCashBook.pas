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
  Buttons;

type
  //----------------------------------------------------------------------------
  TExportChartFrmProperties = class
  private
    fExportBasicChart : boolean;
    fIncludeClosingBalances : boolean;
    fClosingBalanceDate: TDateTime;
    fFilePath : string;
    fClientCode : string;
  public
    property ExportBasicChart : boolean read fExportBasicChart write fExportBasicChart;
    property IncludeClosingBalances : boolean read fIncludeClosingBalances write fIncludeClosingBalances;
    property ClosingBalanceDate: TDateTime read fClosingBalanceDate write fClosingBalanceDate;
    property FilePath : string read fFilePath write fFilePath;
    property ClientCode : string read fClientCode write fClientCode;
  end;

  //------------------------------------------------------------------------------
  TFrmChartExportToMYOBCashBook = class(TForm)
    grpMain: TGroupBox;
    lblSaveEntriesTo: TLabel;
    btnToFolder: TSpeedButton;
    edtSaveEntriesTo: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    dteClosingBalanceDate: TOvcPictureField;
    lblExportText: TLabel;
    radExportFullChart: TRadioButton;
    radExportBasicChart: TRadioButton;
    chkIncludeClosingBalances: TCheckBox;
    lblClosingBalanceDate: TLabel;
    SaveDialog: TSaveDialog;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkIncludeClosingBalancesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fExportChartFrmProperties : TExportChartFrmProperties;
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
  BKConst;

//------------------------------------------------------------------------------
function ShowChartExport(w_PopupParent: Forms.TForm; aExportChartFrmProperties : TExportChartFrmProperties) : boolean;
var
  MyDlg : TFrmChartExportToMYOBCashBook;
begin
  result := false;

  MyDlg := TFrmChartExportToMYOBCashBook.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.ExportChartFrmProperties := aExportChartFrmProperties;

    //BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    Result := MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TFrmChartExportToMYOBCashBook }
//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ValidateForm();
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.chkIncludeClosingBalancesClick(Sender: TObject);
begin
  dteClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
  lblClosingBalanceDate.Visible := chkIncludeClosingBalances.Checked;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.FormActivate(Sender: TObject);
begin
  chkIncludeClosingBalancesClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportToMYOBCashBook.btnToFolderClick(Sender: TObject);
begin
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
  edtSaveEntriesTo.Text := 'Export ' + BRAND_FULL_PRACTICE + ' chart of accounts to .CSV file for';
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.ValidateForm: boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TFrmChartExportToMYOBCashBook.Execute: boolean;
begin
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);

  // Load Default Properties
  if Assigned(ExportChartFrmProperties) then
  begin
    Self.Caption := 'Export {' + ExportChartFrmProperties.ClientCode + '}''s Chart of Accounts to Cashbook';

    if ExportChartFrmProperties.ExportBasicChart then
      radExportBasicChart.Checked := true
    else
      radExportFullChart.Checked := true;

    chkIncludeClosingBalances.Checked := ExportChartFrmProperties.IncludeClosingBalances;
    dteClosingBalanceDate.AsDateTime := ExportChartFrmProperties.fClosingBalanceDate;
    edtSaveEntriesTo.Text := ExportChartFrmProperties.FilePath;
  end;

  Result := (ShowModal = mrOK);

  // if ok Save Properties
  if Result then
  begin
    if Assigned(ExportChartFrmProperties) then
    begin
      ExportChartFrmProperties.ExportBasicChart := (radExportBasicChart.Checked);
      ExportChartFrmProperties.IncludeClosingBalances := chkIncludeClosingBalances.Checked;
      ExportChartFrmProperties.fClosingBalanceDate := dteClosingBalanceDate.AsDateTime;
      ExportChartFrmProperties.FilePath := edtSaveEntriesTo.Text;
    end;
  end;
end;

end.
