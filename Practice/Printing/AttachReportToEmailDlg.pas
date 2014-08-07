unit AttachReportToEmailDlg;

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
  Buttons,
  ReportDefs,
  OSFont,
  CustomFileFormats;

type
  TAttachReportToEmailFrm = class(TForm)
    lblSaveTo: TLabel;
    edtReportName: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    cmbFormat: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
  public
  end;

//------------------------------------------------------------------------------
  function  ShowAttachReportToEmailFrm(const aOwner: TComponent;
              var sReportName: string; var aReportFormat: integer): boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
  bkXPThemes,
  Globals,
  ImagesFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  WarningMoreFrm,
  YesNoDlg,
  GenUtils,
  bkConst,
  WinUtils,
  ComboUtils,
  glConst,
  strutils;

//------------------------------------------------------------------------------
function ShowAttachReportToEmailFrm(const aOwner: TComponent;
  var sReportName: string; var aReportFormat: integer): boolean;
var
  Form: TAttachReportToEmailFrm;
  mrResult: integer;
begin
  ASSERT((rfMin <= aReportFormat) and (aReportFormat <= rfMax));

  Form := TAttachReportToEmailFrm.Create(aOwner);
  try
    // Data to display
    Form.edtReportName.Text := sReportName;
    Form.cmbFormat.ItemIndex := aReportFormat;

    // Show dialog
    mrResult := Form.ShowModal;

    // User cancel?
    result := (mrResult = mrOK);
    if not result then
      exit;

    // Display to data
    sReportName := Form.edtReportName.Text;
    ASSERT(sReportName <> '');
    aReportFormat := Form.cmbFormat.ItemIndex;
    ASSERT((rfMin <= aReportFormat) and (aReportFormat <= rfMax));
  finally
    FreeAndNil(Form);
  end;
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  bkXPThemes.ThemeForm(self);

  for i := rfMin to rfMax do
  begin
    cmbFormat.AddItem(rfNames[i], nil);
  end;

  // Default
  cmbFormat.ItemIndex := rfPDF;
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.btnOkClick(Sender: TObject);
var
  sReportName: string;
  sExtn: string;
begin
  sReportName := Trim(edtReportName.Text);
  if (sReportName = '') then
  begin
    edtReportName.SetFocus;
    HelpfulWarningMsg('You must specify the report name.', 0);
    exit;
  end;

  sExtn := ExtractFileExt(sReportName);
  if (sExtn <> '') then
  begin
    edtReportName.SetFocus;
    HelpfulWarningMsg('It is not necessary to specify the file extension in the report name.', 0);
    exit;
  end;

  ModalResult := mrOk;
end;


end.
