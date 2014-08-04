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
  private
  public
  end;

//------------------------------------------------------------------------------
  function  ShowAttachReportToEmailFrm(const aOwner: TComponent;
              var aReportFormat: integer; var sReportName: string): boolean;

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
  var aReportFormat: integer; var sReportName: string): boolean;
var
  Form: TAttachReportToEmailFrm;
  mrResult: integer;
begin
  Form := TAttachReportToEmailFrm.Create(aOwner);
  try
    mrResult := Form.ShowModal;

    result := (mrResult = mrOK);
    if not result then
      exit;

    aReportFormat := Form.cmbFormat.ItemIndex;
    sReportName := Form.edtReportName.Text;
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


end.
