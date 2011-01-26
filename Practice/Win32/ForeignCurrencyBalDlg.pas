unit ForeignCurrencyBalDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf,
  MONEYDEF, BKDEFS, osfont;

type
  pExchangeRec = ^TExchangeRec;
  TExchangeRec = record
    ExchangeRate: double;
  end;

  TfrmForeignCurrencyBal = class(TForm)
    cmbCurrency: TComboBox;
    nForeignOpeningBal: TOvcNumericField;
    lblOpeningBalance: TLabel;
    nBaseOpeningBal: TOvcNumericField;
    Label1: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    InfoBmp: TImage;
    Label5: TLabel;
    procedure nForeignOpeningBalChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbCurrencyChange(Sender: TObject);
  private
    FAsAtDate: integer;
    FExchangeRate: double;
    { Private declarations }
    procedure FillCurrencies;
    procedure SetAsAtDate(const Value: integer);
    procedure CalculateBaseAmount;
    procedure CalculateForeignAmount;
  public
    { Public declarations }
    property AsAtDate: integer read FAsAtDate write SetAsAtDate;
    property ExchangeRate: double read FExchangeRate;
  end;

  function EnterForeignCurrencyBalance(const pAccount: pAccount_Rec; AsAtDate: integer): boolean;

implementation

uses
  GenUtils, Globals, ExchangeRateList, stDateSt, ErrorMoreFrm;

function EnterForeignCurrencyBalance(const pAccount: pAccount_Rec; AsAtDate: integer): boolean;
var
  frmForeignCurrencyBal: TfrmForeignCurrencyBal;
  S: string;
begin
  frmForeignCurrencyBal := TfrmForeignCurrencyBal.Create(Application.MainForm);
  try
    frmForeignCurrencyBal.AsAtDate := AsAtDate;

    frmForeignCurrencyBal.FillCurrencies;
    if pAccount.chTemp_Opening_Balance_Currency = '' then
       pAccount.chTemp_Opening_Balance_Currency := MyClient.clExtra.ceLocal_Currency_Code;
    frmForeignCurrencyBal.cmbCurrency.ItemIndex :=
      frmForeignCurrencyBal.cmbCurrency.Items.IndexOf(pAccount.chTemp_Opening_Balance_Currency);

    //Currency not found
    if frmForeignCurrencyBal.cmbCurrency.ItemIndex = -1 then begin
      if frmForeignCurrencyBal.cmbCurrency.Items.Count > 0 then
        frmForeignCurrencyBal.cmbCurrency.ItemIndex := 0
      else begin
        S := StDateToDateString( 'dd nnn yyyy', AsAtDate , true);
        HelpfulErrorMsg(Format('There are no currencies with exchange rates ' +
                               'available for %s',[S]), 0 );
        Exit;
      end;
    end;

    //Conver base to foreign
    frmForeignCurrencyBal.nBaseOpeningBal.AsFloat := Money2Double(pAccount.chTemp_Money_Value);
    frmForeignCurrencyBal.CalculateForeignAmount;

    //Set date
    S := StDateToDateString( 'dd nnn yyyy', AsAtDate , true);
    frmForeignCurrencyBal.lblOpeningBalance.Caption := Format('Opening Balance (as at %s)', [S]);

    if frmForeignCurrencyBal.ShowModal = mrOk then begin
      pAccount.chTemp_Money_Value := Double2Money(frmForeignCurrencyBal.nBaseOpeningBal.asFloat);
      pAccount.chTemp_Opening_Balance_Currency := frmForeignCurrencyBal.cmbCurrency.Items[frmForeignCurrencyBal.cmbCurrency.ItemIndex];
    end;
  finally
    frmForeignCurrencyBal.Free;
  end;
end;


{$R *.dfm}

{ TfrmForeignCurrencyBal }

procedure TfrmForeignCurrencyBal.CalculateBaseAmount;
var
  ExchangeRate: Double;
begin
  ExchangeRate := pExchangeRec(cmbCurrency.Items.Objects[cmbCurrency.ItemIndex])^.ExchangeRate;
  nBaseOpeningBal.AsFloat := 0;
  if ExchangeRate > 0 then
    nBaseOpeningBal.AsFloat := nForeignOpeningBal.AsFloat / ExchangeRate;
end;

procedure TfrmForeignCurrencyBal.CalculateForeignAmount;
var
  ExchangeRate: Double;
begin
  ExchangeRate := pExchangeRec(cmbCurrency.Items.Objects[cmbCurrency.ItemIndex])^.ExchangeRate;
  nForeignOpeningBal.AsFloat := 0;
  if ExchangeRate > 0 then
    nForeignOpeningBal.AsFloat := nBaseOpeningBal.AsFloat * ExchangeRate;
end;

procedure TfrmForeignCurrencyBal.cmbCurrencyChange(Sender: TObject);
begin
  CalculateBaseAmount;
end;

procedure TfrmForeignCurrencyBal.FillCurrencies;
var
  Cursor: TCursor;
  i: Integer;
  ExchangeRecord: TExchangeRecord;

  procedure AddExchangeRate(RateIdx: integer);
  var
    ExchangeRec: pExchangeRec;
  begin
    ExchangeRecord := MyClient.ExchangeSource.GetDateRates(AsAtDate);
    if Assigned(ExchangeRecord) then
      if (ExchangeRecord.Rates[RateIdx] > 0) then begin
        New(ExchangeRec);
        ExchangeRec.ExchangeRate := ExchangeRecord.Rates[RateIdx];
        cmbCurrency.Items.AddObject(MyClient.ExchangeSource.Header.ehISO_Codes[RateIdx], Pointer(ExchangeRec));
      end;
  end;

begin
  Cursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  cmbCurrency.Items.BeginUpdate;
  try
    cmbCurrency.Clear;
    if Assigned(AdminSystem) then begin
      AdminSystem.SyncCurrenciesToSystemAccounts;
      for i := low(AdminSystem.fCurrencyList.ehISO_Codes) to high(AdminSystem.fCurrencyList.ehISO_Codes) do
        if (AdminSystem.fCurrencyList.ehISO_Codes[i] > '') then
          AddExchangeRate(i);
    end else begin
      for i := low(MyClient.ExchangeSource.Header.ehISO_Codes) to high(MyClient.ExchangeSource.Header.ehISO_Codes) do
        if (MyClient.ExchangeSource.Header.ehISO_Codes[i] > '') then
          AddExchangeRate(i);
    end;
  finally
    cmbCurrency.Items.EndUpdate;
    Screen.Cursor := Cursor;
  end;
end;

procedure TfrmForeignCurrencyBal.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to cmbCurrency.Items.Count - 1 do
    if Assigned(cmbCurrency.Items.Objects[i]) then
      Dispose(pExchangeRec(cmbCurrency.Items.Objects[i]));
end;

procedure TfrmForeignCurrencyBal.nForeignOpeningBalChange(Sender: TObject);
begin
  CalculateBaseAmount;
end;

procedure TfrmForeignCurrencyBal.SetAsAtDate(const Value: integer);
begin
  FAsAtDate := Value;
end;


end.
