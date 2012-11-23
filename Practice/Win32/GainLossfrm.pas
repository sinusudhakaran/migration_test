unit GainLossfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzButton, Grids_ts, TSGrid, DateUtils, ExchangeGainLoss,
  clObj32, OSFont, ExtCtrls;

type
  TfrmGainLoss = class(TForm)
    tgGainLoss: TtsGrid;
    lblMonthEndDate1: TLabel;
    tbPrevious: TRzToolButton;
    tbNext: TRzToolButton;
    lblEntriesCreatedDate: TLabel;
    btnClose: TButton;
    lblMonthEndDate2: TLabel;
    pnlBottom: TPanel;
    procedure FormShow(Sender: TObject);
    procedure tbPreviousClick(Sender: TObject);
    procedure tbNextClick(Sender: TObject);
    procedure tgGainLossCellLoaded(Sender: TObject; DataCol, DataRow: Integer;
      var Value: Variant);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fMonths: TMonthEndings;
    fClient: TClientObj;
    procedure UpdateGridMonth;
  public
    { public declarations }
  protected
    FPeriodEndDate: TDateTime;
    FSelectedMonthIndex: integer;
    procedure UpdatePeriodEndDate;
    procedure PopulateGrid;
  end;

  function RunGainLoss(aClient : TClientObj; DT: TDateTime) : boolean;

implementation

uses
  baObj32, bkHelp, StDate, StDateSt, bkXPThemes;

{$R *.dfm}

function RunGainLoss(aClient : TClientObj; DT: TDateTime) : boolean;
var
  frmGainLoss: TfrmGainLoss;
begin
  frmGainLoss := TfrmGainLoss.Create(Application.MainForm);
  try
    frmGainLoss.fClient := aClient;
    frmGainLoss.FPeriodEndDate := DT;

    BKHelpSetup(frmGainLoss, BKH_Calculate_exchange_gain_or_loss);

    // Create here because in the constructor/FormCreate there's no fClient yet
    if not Assigned(frmGainLoss.fMonths) then    
      frmGainLoss.fMonths := TMonthEndings.Create(frmGainLoss.fClient);
    frmGainLoss.fMonths.Options := [meoCullFirstMonths];
    frmGainLoss.fMonths.Refresh;
    frmGainLoss.UpdateGridMonth;
    frmGainLoss.PopulateGrid;

    // Cancelled?
    result := (frmGainLoss.ShowModal = mrOK);
    if not result then
      exit;
  finally
    FreeAndNil(frmGainLoss.fMonths);
    FreeAndNil(frmGainLoss);
  end;
end;

procedure TfrmGainLoss.UpdateGridMonth;
var
  i: integer;
  Y1, Y2, M1, M2, D1, D2: Word;
  MonthFound: boolean;
begin
  MonthFound := False;
  for i := 0 to fMonths.Count - 1 do
  begin
    DecodeDate(FPeriodEndDate, Y1, M1, D1);
    DecodeDate(fMonths[i].Date, Y2, M2, D2);
    if (CompareDate(StartOfAMonth(Y1, M1), StartOfAMonth(Y2, M2)) = 0) then // DT >= Date (comparing months only)
    begin
      FSelectedMonthIndex := i;
      MonthFound := True;
      break;
    end;
  end;
  if not MonthFound then
    FSelectedMonthIndex := -1;
  PopulateGrid;
end;

procedure TfrmGainLoss.UpdatePeriodEndDate;
begin
  lblMonthEndDate2.Caption := DateToStr(FPeriodEndDate);
end;

procedure TfrmGainLoss.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  lblMonthEndDate2.Font.Style := [fsBold];
  lblMonthEndDate2.Left := lblMonthEndDate1.Left + lblMonthEndDate1.Width + 5;
  lblMonthEndDate2.Top := lblMonthEndDate1.Top + 1;
  lblMonthEndDate2.Font.Size := lblMonthEndDate1.Font.Size;
end;

procedure TfrmGainLoss.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMonths);
end;

procedure TfrmGainLoss.FormShow(Sender: TObject);
begin
  UpdatePeriodEndDate;
end;

procedure TfrmGainLoss.PopulateGrid;
var
  PostedDate: TStDate;

  procedure ClearRows;
  begin
   tgGainLoss.DeleteRows(0, tgGainLoss.Rows);
   lblEntriesCreatedDate.Caption := '';
  end;
begin
  tgGainLoss.BeginUpdate;
  try
    if (FSelectedMonthIndex = -1) then
      ClearRows
    else if not fMonths[FSelectedMonthIndex].BankAccounts[0].PostedEntry.Valid then
      ClearRows
    else
    begin
      tgGainLoss.Rows := Length(fMonths[FSelectedMonthIndex].BankAccounts);
      PostedDate := fMonths[FSelectedMonthIndex].BankAccounts[0].PostedEntry.Date;
      lblEntriesCreatedDate.Caption := 'The above entries were created ' +
                                       DateToStr(StDateToDateTime(PostedDate));
    end;
  finally
    tgGainLoss.EndUpdate;
  end;
  tgGainLoss.Refresh;
end;

procedure TfrmGainLoss.tgGainLossCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  MonthEnding: TMonthEnding;
  MonthEndingBankAccount: TMonthEndingBankAccount;
  BankAccount: TBank_Account;
begin
  // NOTE: DataCol and DataRow are 1-based
  MonthEnding := fMonths[FSelectedMonthIndex];
  MonthEndingBankAccount := MonthEnding.BankAccounts[DataRow-1];
  BankAccount := MonthEndingBankAccount.BankAccount;

  case DataCol of
    1: Value := BankAccount.baFields.baBank_Account_Number;
    2: Value := MonthEndingBankAccount.GetAccountNameCurrency;
    3: Value := BankAccount.baFields.baExchange_Gain_Loss_Code;
    4: Value := MonthEndingBankAccount.PostedEntry.GainLossCurrency;
    5: Value := MonthEndingBankAccount.PostedEntry.GainLossCrDr;
    else
      ASSERT(false);
  end;
end;

procedure TfrmGainLoss.tbPreviousClick(Sender: TObject);
begin
  // Simply decreasing the month by one wouldn't work, because months have varying lengths eg. 28 Feb -> 28 Jan
  FPeriodEndDate := IncDay(FPeriodEndDate, 1);
  FPeriodEndDate := IncMonth(FPeriodEndDate, -1);
  FPeriodEndDate := IncDay(FPeriodEndDate, -1);
  UpdatePeriodEndDate;
  UpdateGridMonth;
end;

procedure TfrmGainLoss.tbNextClick(Sender: TObject);
begin
  // Simply increasing the month by one wouldn't work, because months have varying lengths eg. 28 Feb -> 28 Mar
  FPeriodEndDate := IncDay(FPeriodEndDate, 1);
  FPeriodEndDate := IncMonth(FPeriodEndDate, 1);
  FPeriodEndDate := IncDay(FPeriodEndDate, -1);
  UpdatePeriodEndDate;
  UpdateGridMonth;
end;

end.
