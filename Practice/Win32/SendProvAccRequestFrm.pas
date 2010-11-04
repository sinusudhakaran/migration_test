unit SendProvAccRequestFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ADODB, DB;

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
    conUTILITY: TADOConnection;
    cbxInstitution: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblTermsClick(Sender: TObject);
    procedure btnSubmitClick(Sender: TObject);
    function ValidateDetails: boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  bkConst, Globals, ShellAPI;

procedure TfrmSendProvAccRequest.btnSubmitClick(Sender: TObject);
begin
  if not ValidateDetails then
    ModalResult := mrNone;
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

  if (cbxCurrency.Visible) and ((cbxCurrency.Text = '') or (cbxCurrency.Text = 'Select')) then
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
  i, C, RowNum, NumRows: integer;
  Query: TADOQuery;
  Institution: string;
//  Institutions: TStringList;
begin
  for I := 0 to High(mtNames) do
    cbxAccountType.AddItem(mtNames[I], nil);

  AdminSystem.SyncCurrenciesToSystemAccounts;
  for C := low(AdminSystem.fCurrencyList .ehISO_Codes) to high(AdminSystem.fCurrencyList.ehISO_Codes) do
    if AdminSystem.fCurrencyList.ehISO_Codes[C] > '' then
    begin
      cbxCurrency.AddItem(AdminSystem.fCurrencyList.ehISO_Codes[C], nil);
    end;

  if (AdminSystem.fdFields.fdCountry = whUK) then
  begin
    lblCurrency.Visible := true;
    cbxCurrency.Visible := true;
    lblCurrencyWarning.Visible := true;
  end;

  {
  Query := TADOQuery.Create(nil);
  try
    Query.Connection := conUTILITY;
    Query.SQL.Text := 'SELECT * FROM BK_T_INSTITUTION ORDER BY in_Name';
    Query.Open;
//    Institutions := TStringList.Create;
    RowNum := 0;
    NumRows := Query.RecordCount;
    while (RowNum < NumRows) do
    begin
      try
        Institution := Query.Recordset.Fields['in_Name'].Value;
//        Institutions.Add(Institution);
        cbxInstitution.Items.Add(Institution);
        Query.Recordset.MoveNext;
        inc(RowNum);
      except
        ShowMessage('RowNum = ' + IntToStr(RowNum));
      end;
    end;
  finally

  end;
  }
end;

procedure TfrmSendProvAccRequest.FormShow(Sender: TObject);
begin
//
end;

procedure TfrmSendProvAccRequest.lblTermsClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('OPEN'), PChar('http://www.banklink.co.nz'), nil, nil, 0);
end;

end.
