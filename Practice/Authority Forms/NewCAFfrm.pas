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
    procedure btnCancelClick(Sender: TObject);
  private
    function ValidateForm: Boolean;
  public
    { Public declarations }
  end;

var
  frmNewCAF: TfrmNewCAF;

implementation

{$R *.dfm}

procedure TfrmNewCAF.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmNewCAF.ValidateForm: Boolean;
begin
  // TODO
  Result := True;
end;

end.
