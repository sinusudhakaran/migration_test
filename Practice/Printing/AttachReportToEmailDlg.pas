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
    procedure cmbFormatChange(Sender: TObject);
  private
  public
    procedure Init(const aFileFormats: TFileFormatSet; const aDefault: integer);
  end;

//------------------------------------------------------------------------------
  function  ShowAttachReportToEmailFrm(const aOwner: TComponent;
              const aFileFormats: TFileFormatSet; var sReportName: string;
              var aReportFormat: integer): boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
  bkXPThemes,
  ReportFileFormat,
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
  const aFileFormats: TFileFormatSet; var sReportName: string;
  var aReportFormat: integer): boolean;
var
  Form: TAttachReportToEmailFrm;
  mrResult: integer;
begin
  ASSERT((rfMin <= aReportFormat) and (aReportFormat <= rfMax));

  Form := TAttachReportToEmailFrm.Create(aOwner);
  try
    with Form do
    begin
      // Populate file formats (with default)
      Init(aFileFormats, aReportFormat);

      // Data to display
      edtReportName.Text := sReportName;
      cmbFormat.ItemIndex := aReportFormat;

      // Show dialog
      mrResult := ShowModal;

      // User cancel?
      result := (mrResult = mrOK);
      if not result then
        exit;

      // Display to data
      sReportName := edtReportName.Text;
      ASSERT(sReportName <> '');
      aReportFormat := Integer(cmbFormat.Items.Objects[cmbFormat.ItemIndex]);
      ASSERT((rfMin <= aReportFormat) and (aReportFormat <= rfMax));
    end;
  finally
    FreeAndNil(Form);
  end;
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(self);
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.Init(const aFileFormats: TFileFormatSet;
  const aDefault: integer);
var
  i: integer;
  FileFormats: TFileFormatSet;
begin
  // WORKAROUND: FileFormats needs to be local for "in" to work.
  FileFormats := aFileFormats;

  for i := rfMin to rfMax do
  begin
    // Always exclude this
    if (i = rfAcclipse) then
      continue;

    // Accepted file format?
    if (FileFormats = []) or (TFileFormats(i) in FileFormats) then
    begin
      // Add item and actual file format
      cmbFormat.AddItem(RptFileFormat.Names[i], TObject(i));

      // Default entry?
      if (i = aDefault) then
        cmbFormat.ItemIndex := cmbFormat.Items.Count-1;
    end;
  end;
  ASSERT(cmbFormat.Items.Count <> 0);
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.btnOkClick(Sender: TObject);
var
  sReportName: string;
begin
  sReportName := Trim(edtReportName.Text);
  if (sReportName = '') then
  begin
    edtReportName.SetFocus;
    HelpfulWarningMsg('You must specify the report name.', 0);
    exit;
  end;

  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------
procedure TAttachReportToEmailFrm.cmbFormatChange(Sender: TObject);
var
  rfIndex: integer;
  sOldExtn: string;
  sNewExtn: string;
begin
  if (cmbFormat.ItemIndex = -1) then
    exit;

  rfIndex := Integer(cmbFormat.Items.Objects[cmbFormat.ItemIndex]);
  ASSERT((rfMin <= rfIndex) and (rfIndex <= rfMax));

  sOldExtn := ExtractFileExt(edtReportName.Text);
  sNewExtn := RptFileFormat.Extensions[rfIndex];

  edtReportName.Text := StringReplace(edtReportName.Text, sOldExtn, sNewExtn, []);
end;


end.
