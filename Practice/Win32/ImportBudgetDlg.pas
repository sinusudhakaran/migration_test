unit ImportBudgetDlg;

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
  StdCtrls,
  Buttons,
  ExtDlgs,
  ExtCtrls;

type
  TfrmImportBudget = class(TForm)
    edtBudgetFile: TEdit;
    lblFilename: TLabel;
    btnToFile: TSpeedButton;
    btnOk: TButton;
    btnCancel: TButton;
    OpenTextFileDialog: TOpenTextFileDialog;
    rgGST: TRadioGroup;
    lblImportedFiguresAre: TLabel;
    procedure btnToFileClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fBudgetFilePath : string;
    fBudgetName: string;
    procedure SetBudgetFilePath(const Value: string);
  public
    property BudgetFilePath : string read fBudgetFilePath write SetBudgetFilePath;
    property BudgetName : string read fBudgetName write fBudgetName;
  end;

var
  frmImportBudget: TfrmImportBudget;

//------------------------------------------------------------------------------
function DoImportBudget(var aBudgetFilePath : string; aBudgetName : string; var IsGSTInclusive: boolean) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ImagesFrm,
  bkXPThemes,
  YesNoDlg,
  Globals,
  ErrorMoreFrm;

//------------------------------------------------------------------------------
function DoImportBudget(var aBudgetFilePath : string; aBudgetName : string; var IsGSTInclusive: boolean) : boolean;
var
  frmImportBudget : TfrmImportBudget;
begin
  frmImportBudget := TfrmImportBudget.Create( Application.Mainform);

  try
    frmImportBudget.BudgetFilePath  := aBudgetFilePath;
    frmImportBudget.BudgetName      := aBudgetName;
    frmImportBudget.rgGST.ItemIndex := Ord(IsGSTInclusive);

    Result := IsPositiveResult(frmImportBudget.showmodal);
    if Result then
      IsGSTInclusive := (frmImportBudget.rgGST.ItemIndex = 1);

    if Result then
      aBudgetFilePath := frmImportBudget.BudgetFilePath;
  finally
    FreeAndNil(frmImportBudget);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP, btnToFile.Glyph);
  // Removing the border from rgGST
  SetWindowRgn(rgGST.Handle, CreateREctRgn(7, 14, rgGST.Width - 2, rgGST.Height - 2), True);
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.SetBudgetFilePath(const Value: string);
begin
  fBudgetFilePath := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.btnToFileClick(Sender: TObject);
begin
  OpenTextFileDialog.InitialDir := ExtractFilePath(edtBudgetFile.Text);
  OpenTextFileDialog.Filename := ExtractFilename(edtBudgetFile.Text);
  if OpenTextFileDialog.Execute then
    edtBudgetFile.Text := OpenTextFileDialog.Filename;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.btnOkClick(Sender: TObject);
begin
  if not fileexists(edtBudgetFile.Text) then
  begin
    HelpfulErrorMsg('The specified file does not exist.' + #13#10 + #13#10 + 'Filename : ' + edtBudgetFile.Text, 0);
    edtBudgetFile.SetFocus;
    exit;
  end;

  {if AskYesNo('Import Budget', 'All figures in budget ' + fBudgetName +
                               ' will be replaced by those in the selected file.' +
                               #13#10 + #13#10 + 'Are you sure you want to continue?',
              DLG_YES, 0) <> DLG_YES then
  begin
    exit;
  end;}

  fBudgetFilePath := edtBudgetFile.Text;

  ModalResult := mrOK;
end;

end.
