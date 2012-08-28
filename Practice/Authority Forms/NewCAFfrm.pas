unit NewCAFfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmNewCAF = class(TForm)
    lblCompleteTheDetailsBelow: TLabel;
    lbl20: TLabel;
    lblAccountName: TLabel;
    lblServiceStartMonthAndYear: TLabel;
    edtAccountName: TEdit;
    cmbServiceStartMonth: TComboBox;
    edtServiceStartYear: TEdit;
    edtSortCode: TEdit;
    edtAccountNumber: TEdit;
    edtClientCode: TEdit;
    edtCostCode: TEdit;
    lblSortCode: TLabel;
    lblAccountNumber: TLabel;
    lblClientCode: TLabel;
    lblCodeCode: TLabel;
    edtBank: TEdit;
    edtBranch: TEdit;
    lblBank: TLabel;
    lblBranch: TLabel;
    edtAccountSignatory1: TEdit;
    lblAccountSignatories: TLabel;
    edtAccountSignatory2: TEdit;
    chkSupplyAccount: TCheckBox;
    lblServiceFrequency: TLabel;
    pnlServiceFrequency: TPanel;
    rbMonthly: TRadioButton;
    rbWeekly: TRadioButton;
    rbDaily: TRadioButton;
    edtAddressLine1: TEdit;
    lblAddressLine1: TLabel;
    edtAddressLine2: TEdit;
    edtAddressLine3: TEdit;
    edtAddressLine4: TEdit;
    lblAddressLine2: TLabel;
    lblAddressLine3: TLabel;
    lblAddressLine4: TLabel;
    edtPostalCode: TEdit;
    lblPostalCode: TLabel;
    bevel1: TBevel;
    edtPracticeName: TEdit;
    lblPracticeName: TLabel;
    lblPracticeCode: TLabel;
    btnFile: TButton;
    btnEmail: TButton;
    btnPrint: TButton;
    btnResetForm: TButton;
    btnCancel: TButton;
    edtPracticeCode: TEdit;
    pnlBottom: TPanel;
    procedure edtClientCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtServiceStartYearKeyPress(Sender: TObject; var Key: Char);
    procedure edtCostCodeKeyPress(Sender: TObject; var Key: Char);
    procedure cmbServiceStartMonthChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnResetFormKeyPress(Sender: TObject; var Key: Char);
  private
    FButton: Byte;
    function ValidateForm: Boolean;
  public
    property ButtonPressed: Byte read FButton;
  end;

var
  frmNewCAF: TfrmNewCAF;

implementation

{$R *.dfm}

procedure TfrmNewCAF.btnResetFormKeyPress(Sender: TObject; var Key: Char);
begin
  // TODO
end;

procedure TfrmNewCAF.cmbServiceStartMonthChange(Sender: TObject);
begin
  edtServiceStartYear.Enabled := (cmbServiceStartMonth.Text <> 'ASAP');
end;

procedure TfrmNewCAF.edtClientCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['a'..'z','A'..'Z','0'..'9',Chr(vk_Back)]) then
    Key := #0 // Discard the key
  else
    Key := UpCase(Key); // Upper case
end;

procedure TfrmNewCAF.edtCostCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['a'..'z','A'..'Z','0'..'9',Chr(vk_Back)]) then
    Key := #0 // Discard the key
  else
    Key := UpCase(Key); // Upper case
end;

procedure TfrmNewCAF.edtServiceStartYearKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9']) then
    Key := #0; // Discard the key
end;

procedure TfrmNewCAF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in Shift) then
  begin
    case Key of
      69: btnEmail.Click; // Alt + E
      70: btnFile.Click; // Alt + F
      80: btnPrint.Click; // Alt + P
    end;
  end;
  if (Key = VK_ESCAPE) then
    btnCancel.Click;  
end;

procedure TfrmNewCAF.FormShow(Sender: TObject);
begin
  edtAccountName.SetFocus;
end;

function TfrmNewCAF.ValidateForm: Boolean;
begin
  // TODO
  Result := True;
end;

end.
