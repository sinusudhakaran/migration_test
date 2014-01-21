unit ExchangeGainLossCodeEntryfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls, Buttons, StrUtils;

type
  TfrmExchangeGainLossCodeEntry = class(TForm)
    lblMessage: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    edtExchangeGainLossCode: TEdit;
    sbtnChart: TSpeedButton;
    lblExchangeGainLossDesc: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sbtnChartClick(Sender: TObject);
    procedure edtExchangeGainLossCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtExchangeGainLossCodeChange(Sender: TObject);
    procedure edtExchangeGainLossCodeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtExchangeGainLossCodeExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    FBankAccountName: String;
    FRemovingMask : boolean;
    FCurrencyCode: String;

    procedure LookupExchangeGainLossCode;
    function GetExchangeGainLossCode: String;
    function GetBankAccountName: String;
    procedure SetBankAccountName(const Value: String);
    procedure SetExchangeGainLossCode(const Value: String);
    procedure SetCurrencyCode(const Value: String);

    procedure DoRebranding();
  public
    class function EnterExchangeGainLossCode(const BankAccountName, CurrencyCode: String; var ExchangeGainLossCode: string): Boolean; overload; static;
    class function EnterExchangeGainLossCode(const bankAccountName, CurrencyCode: String; PopupParent: TCustomForm; var ExchangeGainLossCode: string): Boolean; overload; static;
    class function ValidateExchangeGainLossCode(const Code: String): Boolean;

    property BankAccountName: String read GetBankAccountName write SetBankAccountName;
    property CurrencyCode: String read FCurrencyCode write SetCurrencyCode;
    property ExchangeGainLossCode: String read GetExchangeGainLossCode write SetExchangeGainLossCode;
  end;

var                                                    
  frmExchangeGainLossCodeEntry: TfrmExchangeGainLossCodeEntry;

implementation

uses
  AccountLookupFrm, imagesfrm, STDHINTS, bkConst, Globals, BKDEFS, bkMaskUtils, ForexHelpers, WarningMoreFrm,
  bkProduct;
  
{$R *.dfm}

class function TfrmExchangeGainLossCodeEntry.EnterExchangeGainLossCode(const BankAccountName, CurrencyCode: String; PopupParent: TCustomForm; var ExchangeGainLossCode: string): Boolean;
var
  EntryForm: TfrmExchangeGainLossCodeEntry;
begin
  EntryForm := TfrmExchangeGainLossCodeEntry.Create(nil);

  try
    EntryForm.PopupParent := PopupParent;
    EntryForm.PopupMode := pmExplicit;
    
    EntryForm.BankAccountName := BankAccountName;
    EntryForm.ExchangeGainLossCode := ExchangeGainLossCode;
    EntryForm.CurrencyCode := CurrencyCode;

    if EntryForm.ShowModal = mrOk then
    begin
      ExchangeGainLossCode := EntryForm.ExchangeGainLossCode;

      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    EntryForm.Free;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.FormCreate(Sender: TObject);
begin
  ActiveControl := edtExchangeGainLossCode;
  
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP, sbtnChart.Glyph);

  edtExchangeGainLossCode.MaxLength := MaxBk5CodeLen;
  edtExchangeGainLossCode.Hint :=
                    'Enter the Exchange Gain/Loss Code to use for this Bank Account|' +
                    'Enter the Exchange Gain/Loss Code from the Chart of Accounts which corresponds to this Bank Account';

  sbtnChart.Hint := ChartLookupHint;

  FRemovingMask := False;

  DoRebranding();
end;

procedure TfrmExchangeGainLossCodeEntry.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.FormShow(Sender: TObject);
begin
  lblMessage.Caption := Format(lblMessage.Caption, [ReplaceStr(FBankAccountName, '&', '&&'), FCurrencyCode]);
end;

function TfrmExchangeGainLossCodeEntry.GetBankAccountName: String;
begin
  Result := FBankAccountName;
end;

function TfrmExchangeGainLossCodeEntry.GetExchangeGainLossCode: String;
begin
  Result := edtExchangeGainLossCode.Text;
end;

procedure TfrmExchangeGainLossCodeEntry.LookupExchangeGainLossCode;
var
  ExchangeGainLossCode: String;
begin
  ExchangeGainLossCode := edtExchangeGainLossCode.Text;
  
  if PickAccount(ExchangeGainLossCode) then
  begin
    edtExchangeGainLossCode.Text := ExchangeGainLossCode;

    edtExchangeGainLossCode.SelectAll;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.sbtnChartClick(Sender: TObject);
begin
  LookupExchangeGainLossCode;
end;

procedure TfrmExchangeGainLossCodeEntry.SetBankAccountName(const Value: String);
begin
  FBankAccountName := Value;
end;

procedure TfrmExchangeGainLossCodeEntry.SetCurrencyCode(const Value: String);
begin
  FCurrencyCode := Value;
end;

procedure TfrmExchangeGainLossCodeEntry.SetExchangeGainLossCode(const Value: String);
begin
  edtExchangeGainLossCode.Text := Value;
end;

class function TfrmExchangeGainLossCodeEntry.ValidateExchangeGainLossCode(const Code: String): Boolean;
var
  pAcct: pAccount_Rec;
begin
  pAcct:= MyClient.clChart.FindCode(Code);

  if Assigned( pAcct) then
  begin
    Result := pAcct^.chPosting_Allowed and IsValidGainLossCode(Code);
  end
  else
  begin
    Result := False;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.btnOkClick(Sender: TObject);
begin
  if ValidateExchangeGainLossCode(Trim(edtExchangeGainLossCode.Text)) then
  begin
    ModalResult := mrOk;
  end
  else
  begin
    HelpfulWarningMsg(
      'The Exchange Gain/Loss Code must be a chart code that has a report group '+
      'set to ''Income'', ''Expense'', ''Other Income'' or ''Other Expense''.',
      0);
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.DoRebranding;
begin
  lblMessage.Caption := BRAND_SHORT_NAME + ' needs to know the exchange gain/loss ' +
                       'code in your client''s chart for this bank account %s (%s).';
end;

procedure TfrmExchangeGainLossCodeEntry.edtExchangeGainLossCodeChange(Sender: TObject);
var
  pAcct: pAccount_Rec;
  ExchangeGainLossCode: string;
  IsValid: boolean;
begin
  if MyClient.clChart.ItemCount = 0 then
  begin
    Exit;
  end;

  ExchangeGainLossCode := Trim(edtExchangeGainLossCode.Text);

  pAcct:= MyClient.clChart.FindCode(ExchangeGainLossCode);

  if Assigned( pAcct) then
  begin
    IsValid := pAcct^.chPosting_Allowed and IsValidGainLossCode(ExchangeGainLossCode);
    
    lblExchangeGainLossDesc.Caption := ReplaceStr(pAcct^.chAccount_Description, '&', '&&');
    lblExchangeGainLossDesc.Visible := True;
  end
  else
  begin
    IsValid := False;
    
    lblExchangeGainLossDesc.Visible := False;
  end;

  if (ExchangeGainLossCode = '') or (IsValid) then
  begin
    edtExchangeGainLossCode.Font.Color := clWindowText;
    edtExchangeGainLossCode.Color := clWindow;
    ExchangeGainLossCode := edtExchangeGainLossCode.Text;

    edtExchangeGainLossCode.BorderStyle := bsNone;
    edtExchangeGainLossCode.BorderStyle := bsSingle;

    edtExchangeGainLossCode.Text := ExchangeGainLossCode;
  end
  else
  begin
    edtExchangeGainLossCode.Font.Color := clWhite;
    edtExchangeGainLossCode.Color      := clRed;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.edtExchangeGainLossCodeExit(Sender: TObject);
begin
  if not MyClient.clChart.CodeIsThere(edtExchangeGainLossCode.Text) then
  begin
    bkMaskUtils.CheckRemoveMaskChar(edtExchangeGainLossCode, FRemovingMask);
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.edtExchangeGainLossCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key='-') and (myClient.clFields.clUse_Minus_As_Lookup_Key)) then
  begin
    Key := #0;

    LookupExchangeGainLossCode;
  end;
end;

procedure TfrmExchangeGainLossCodeEntry.edtExchangeGainLossCodeKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (key = VK_F2) or ((key = VK_DOWN) and (Shift = [ssAlt])) then
  begin
    LookupExchangeGainLossCode;
  end
  else if (Key = VK_BACK) then
  begin
    bkMaskUtils.CheckRemoveMaskChar(edtExchangeGainLossCode, FRemovingMask);
  end
  else
  begin
    bkMaskUtils.CheckForMaskChar(edtExchangeGainLossCode, FRemovingMask);
  end;
end;

class function TfrmExchangeGainLossCodeEntry.EnterExchangeGainLossCode(const BankAccountName, CurrencyCode: String; var ExchangeGainLossCode: string): Boolean;
var
  EntryForm: TfrmExchangeGainLossCodeEntry;
begin
  EntryForm := TfrmExchangeGainLossCodeEntry.Create(nil);

  try
    EntryForm.BankAccountName := BankAccountName;
    EntryForm.ExchangeGainLossCode := ExchangeGainLossCode;
    EntryForm.CurrencyCode := CurrencyCode;
    
    if EntryForm.ShowModal = mrOk then
    begin
      ExchangeGainLossCode := EntryForm.ExchangeGainLossCode;

      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    EntryForm.Free;
  end;
end;
end.
