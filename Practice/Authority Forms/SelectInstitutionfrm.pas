unit SelectInstitutionfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmSelectInstitution = class(TForm)
    Label1: TLabel;
    cmbInstitution: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSelectInstitution: TfrmSelectInstitution;

implementation

uses NewCAFfrm, Globals;

{$R *.dfm}

procedure TfrmSelectInstitution.btnOKClick(Sender: TObject);
var
  CAFForm: TfrmNewCAF;
begin
  CAFForm := TfrmNewCAF.Create(Application.MainForm);

  try
    if Screen.DesktopHeight < 635 then
      CAFForm.Height := Screen.DesktopHeight
    else
      CAFForm.Height := 635;

    if Screen.DesktopWidth < 560 then
      CAFForm.Width := Screen.DesktopWidth
    else
      CAFForm.Width := 560;

    if (cmbInstitution.ItemIndex > 0) then // Anything except 'Other', in which case we expect the user to enter the bank themselves
    begin
      CAFForm.edtBank.Text := cmbInstitution.Items[cmbInstitution.ItemIndex];
      CAFForm.edtBank.Enabled := False;
    end;

    if (CAFForm.edtBank.Text = 'HSBC') then
    begin
      // Show extra HSBC stuff
      CAFForm.edtAccountSignatory1.Visible := True;
      CAFForm.edtAccountSignatory2.Visible := True;
      CAFForm.lblAccountSignatories.Visible := True;
      CAFForm.edtAddressLine1.Visible := True;
      CAFForm.edtAddressLine2.Visible := True;
      CAFForm.edtAddressLine3.Visible := True;
      CAFForm.edtAddressLine4.Visible := True;
      CAFForm.lblAddressLine1.Visible := True;
      CAFForm.lblAddressLine2.Visible := True;
      CAFForm.lblAddressLine3.Visible := True;
      CAFForm.lblAddressLine4.Visible := True;
      CAFForm.edtPostalCode.Visible := True;
      CAFForm.lblPostalCode.Visible := True;
    end else
    begin
      CAFForm.chkSupplyAccount.Top := CAFForm.edtBank.Top + 50;
      CAFForm.lblServiceFrequency.Top := CAFForm.chkSupplyAccount.Top + 29;
      CAFForm.pnlServiceFrequency.Top := CAFForm.chkSupplyAccount.Top + 28;
      CAFForm.pnlBottom.Top := CAFForm.pnlServiceFrequency.Top + 22;
      CAFForm.Height := CAFForm.Height - 275;
    end;

    CAFForm.edtPracticeName.Text := AdminSystem.fdFields.fdPractice_Name_for_Reports;
    CAFForm.edtPracticeCode.Text := AdminSystem.fdFields.fdBankLink_Code;

    CAFForm.ShowModal;
  finally
    Free;
  end;

end;

procedure TfrmSelectInstitution.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      btnOK.Click;
    VK_ESCAPE:
      btnCancel.Click;
  end;
end;

end.
