unit SendProvAccRequestFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OSFont;

type
  TfrmSendProvAccRequest = class(TForm)
    lblAccountNumber: TLabel;
    edtAccountNumber: TEdit;
    btnSubmit: TButton;
    Button1: TButton;
    lblAccountName: TLabel;
    lblInstitution: TLabel;
    lblAccountType: TLabel;
    lblCurrency: TLabel;
    edtAccountName: TEdit;
    cbxAccountType: TComboBox;
    cbxCurrency: TComboBox;
    lblCurrencyWarning: TLabel;
    chkReadTerms: TCheckBox;
    lblTerms: TLabel;
    cbxInstitution: TComboBox;
    lblP: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblTermsClick(Sender: TObject);
    procedure btnSubmitClick(Sender: TObject);
    function ValidateDetails: boolean;
  private
    function GetAccountName: string;
    function GetAccountNumber: string;
    function GetCurrency: string;
    function GetInstitution: string;
    { Private declarations }
  public
    property AccountNumber: string read GetAccountNumber;
    property AccountName: string read GetAccountName;
    property Institution: string read GetInstitution;
    property Currency: string read GetCurrency;
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  bkConst, Globals, ShellAPI, bkBranding;

procedure TfrmSendProvAccRequest.btnSubmitClick(Sender: TObject);
begin
  if not ValidateDetails then
    ModalResult := mrOk;
end;

function TfrmSendProvAccRequest.ValidateDetails: boolean;
begin
  Result := false;

  if (edtAccountNumber.Text = '') then
  begin
    ShowMessage('You must enter an Account number. Please try again');
    Exit;
  end;

  if (edtAccountName.Text = '') then
  begin
    ShowMessage('You must enter an Account name. Please try again');
    Exit;
  end;

  if (cbxInstitution.Text = '') then
  begin
    ShowMessage('You must enter an Institution. Please try again');
    Exit;
  end;

  if (cbxAccountType.Text = '') or (cbxAccountType.Text = 'Select') then
  begin
    ShowMessage('You must select an Account type. Please try again');
    Exit;
  end;

  if (cbxCurrency.Visible)
  and ((cbxCurrency.Text = '')
  or (cbxCurrency.Text = 'Select')) then
  begin
    ShowMessage('You must select a Currency. Please try again');
    Exit;
  end;

  if not chkReadTerms.Checked then
  begin
    ShowMessage('You must agree to BankLink''s Terms and conditions to successfully submit your request. ' +
                'Please enable the checkbox and click Submit to continue, or click Cancel to exit');
    Exit;
  end;

  Result := true;
end;

procedure TfrmSendProvAccRequest.FormCreate(Sender: TObject);
var
  I: integer;
begin
  for I := 0 to High(mtNames) do
    cbxAccountType.AddItem(mtNames[I], nil);

  AdminSystem.SyncCurrenciesToSystemAccounts;
  for I := low(AdminSystem.fCurrencyList .ehISO_Codes) to high(AdminSystem.fCurrencyList.ehISO_Codes) do
    if AdminSystem.fCurrencyList.ehISO_Codes[I] > '' then begin
       cbxCurrency.AddItem(AdminSystem.fCurrencyList.ehISO_Codes[I],nil);
    end;
  cbxCurrency.ItemIndex := cbxCurrency.Items.IndexOf( AdminSystem.CurrencyCode);

  if (AdminSystem.fdFields.fdCountry = whUK) then
  begin
    lblCurrency.Visible := true;
    cbxCurrency.Visible := true;
    lblCurrencyWarning.Visible := true;
  end;

  chkReadTerms.Caption := bkBranding.Rebrand(chkReadTerms.Caption);
end;

procedure TfrmSendProvAccRequest.FormShow(Sender: TObject);
begin
//
end;

function TfrmSendProvAccRequest.GetAccountName: string;
begin
   Result := edtAccountName.Text;
end;

function TfrmSendProvAccRequest.GetAccountNumber: string;
begin
   Result := lblP.Caption + edtAccountNumber.Text;
end;

function TfrmSendProvAccRequest.GetCurrency: string;
begin
   Result := self.cbxCurrency.Text;
end;

function TfrmSendProvAccRequest.GetInstitution: string;
begin
   Result := cbxInstitution.Text;
end;

procedure TfrmSendProvAccRequest.lblTermsClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('OPEN'), PChar('http://www.banklink.co.nz'), nil, nil, 0);
end;

end.
