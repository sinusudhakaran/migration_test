unit GainLossfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzButton, Grids_ts, TSGrid, DateUtils, ExchangeGainLoss,
  clObj32, OSFont, ExtCtrls, baObj32;

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
    procedure FormResize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    fMonths: TMonthEndings;
    fClient: TClientObj;
    FGridMonthEndingBankAccounts:  array of TMonthEndingBankAccount;

    procedure AddGridMonthEndingBankAccount(MonthEndingBankAccount: TMonthEndingBankAccount);
    procedure ClearGridMonthEndingBankAccount;

    function UpdateGridMonth(LeaveGridOpen: boolean): boolean;
    function CheckGainLossDates(BankAccount: TBank_Account; MonthEnding: TMonthEnding): boolean;
  public
    { public declarations }
  protected
    FPeriodEndDate: TDateTime;
    FSelectedMonthIndex: integer;
    procedure UpdatePeriodEndDate;
    function PopulateGrid: boolean;
  end;

  function RunGainLoss(aClient : TClientObj; DT: TDateTime) : boolean;

implementation

uses
  bkHelp, StDate, StDateSt, bkXPThemes, ForexHelpers, glObj32, bkDateUtils;

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
    frmGainLoss.fMonths.Refresh;
    frmGainLoss.UpdateGridMonth(False);
    Result := False;
    if frmGainLoss.PopulateGrid then // Only bring up the grid if there are entries
    begin
      // Cancelled?
      result := (frmGainLoss.ShowModal = mrOK);
      if not result then
        exit;
    end;
  finally
    FreeAndNil(frmGainLoss.fMonths);
    FreeAndNil(frmGainLoss);
  end;
end;

function TfrmGainLoss.UpdateGridMonth(LeaveGridOpen: boolean): boolean;
var
  i: integer;
  Y1, Y2, M1, M2, D1, D2: Word;
  MonthFound: boolean;
begin
  Result := True;
  MonthFound := False;
  // We only want to populate the grid if we find a MonthEnding which matches the current month
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
  if not (PopulateGrid or LeaveGridOpen) then
  begin
    Result := False;
    Self.Close;
  end;
end;

procedure TfrmGainLoss.UpdatePeriodEndDate;
var
  Caption: string;
begin
  Caption := lblMonthEndDate2.Caption;
  SysUtils.DateTimeToString(Caption, 'dd/mm/yy', FPeriodEndDate);
  lblMonthEndDate2.Caption := Caption;

end;

procedure TfrmGainLoss.FormCreate(Sender: TObject);
begin
  ClearGridMonthEndingBankAccount;
  
  bkXPThemes.ThemeForm(Self);
  lblMonthEndDate2.Font.Style := [fsBold];
  lblMonthEndDate2.Left := lblMonthEndDate1.Left + lblMonthEndDate1.Width + 5;
  lblMonthEndDate2.Top := lblMonthEndDate1.Top + 1;
  lblMonthEndDate2.Font.Size := lblMonthEndDate1.Font.Size;
end;

procedure TfrmGainLoss.FormDestroy(Sender: TObject);
begin
  ClearGridMonthEndingBankAccount;

  FreeAndNil(fMonths);
end;

procedure TfrmGainLoss.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    Char(VK_ESCAPE):
      begin
        Key := #0;
        ModalResult := mrCancel;
      end;
  end;
  // Not that there's any difference between cancel and ok for this form anyway...
end;

procedure TfrmGainLoss.FormResize(Sender: TObject);
begin
  self.btnClose.Left := self.Width - self.btnClose.Width - 35;
end;

procedure TfrmGainLoss.FormShow(Sender: TObject);
begin
  UpdatePeriodEndDate;
end;

function TfrmGainLoss.PopulateGrid: boolean;
var
  PostedDate: TStDate;
  EntriesCreatedDateStr: string;
  BankAccount: TBank_Account;
  PostedEntry: TExchange_Gain_Loss;
  RowsCleared: boolean;
  i, NumAccountsGainLossNotRun: integer;
  Index: Integer;
  MonthEndingBankAccount: TMonthEndingBankAccount;

  procedure ClearRows;
  begin
   tgGainLoss.DeleteRows(0, tgGainLoss.Rows);
   lblEntriesCreatedDate.Caption := '';
  end;
begin
  Result := False;
  tgGainLoss.BeginUpdate;
  try
    ClearGridMonthEndingBankAccount;

    if (FSelectedMonthIndex = -1) or (fMonths[FSelectedMonthIndex].NrTransactions = 0) then
    begin
      ClearRows;
    end
    else if Assigned(fMonths[FSelectedMonthIndex].BankAccounts) then
    begin
      RowsCleared := True;

      for Index := 0 to Length(FMonths[FSelectedMonthindex].BankAccounts) - 1 do
      begin
        if fMonths[FSelectedMonthIndex].BankAccounts[Index].PostedEntry.Valid then
        begin
          RowsCleared := False;

          Break;
        end;
      end;

      if RowsCleared then
      begin
        ClearRows;
      end;
      if (fMonths[FSelectedMonthIndex].NrAlreadyRun > 0) then // Check if Calculate Ex. Gain/Loss has been run for this month
      begin
        Result := True;
        if not RowsCleared then
        begin
          for i := 0 to High(fMonths[FSelectedMonthIndex].BankAccounts) do
          begin
            BankAccount := fMonths[FSelectedMonthIndex].BankAccounts[i].BankAccount;

            if (BankAccount.baExchange_Gain_Loss_List.ItemCount <> 0) then
            begin
              if CheckGainLossDates(BankAccount, fMonths[FSelectedMonthIndex]) then
              begin
                AddGridMonthEndingBankAccount(fMonths[FSelectedMonthIndex].BankAccounts[i]);
              end;
            end;
          end;

          if Length(FGridMonthEndingBankAccounts) > 0 then
          begin
            tgGainLoss.Rows := Length(FGridMonthEndingBankAccounts);

            MonthEndingBankAccount := FGridMonthEndingBankAccounts[0];
            
            PostedDate := MonthEndingBankAccount.PostedEntry.Date;
            BankAccount := MonthEndingBankAccount.BankAccount;

            PostedEntry := BankAccount.baExchange_Gain_Loss_List.GetPostedEntry(PostedDate);

            EntriesCreatedDateStr := bkDate2Str(PostedEntry.glFields.glPosted_Date);

            lblEntriesCreatedDate.Caption := 'The above entries were created ' + EntriesCreatedDateStr;
          end;
        end
        else
        begin
          tgGainLoss.Rows := 0;
        end;
      end;
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
  ShowRow: boolean;
begin
  // NOTE: DataCol and DataRow are 1-based
  MonthEndingBankAccount := FGridMonthEndingBankAccounts[DataRow-1];
  BankAccount := MonthEndingBankAccount.BankAccount;
  // Check that the account has at least one exchange gain/loss entry
  (*  We don't need this because the accounts in the list are already known to contain gain/loss entries
  if BankAccount.baExchange_Gain_Loss_List.ItemCount = 0 then
    ShowRow := False
  else
    // Check that the account has at least one exchange gain/loss entry in the current period
    ShowRow := CheckGainLossDates(BankAccount, Mont hEnding);

  if not ShowRow then
    Exit; // Don't add rows for accounts lacking exchange gain loss entries for this period
  *)
  
  case DataCol of
    1: Value := BankAccount.baFields.baBank_Account_Number;
    2: Value := MonthEndingBankAccount.GetAccountNameCurrency;
    3:
      begin
        Value := MonthEndingBankAccount.PostedEntry.ExchangeGainLossCode;
        tgGainLoss.CellFont[DataCol,DataRow] := tgGainLoss.Font;
        if IsValidGainLossCode(Value) then
        begin
          tgGainLoss.CellColor[DataCol,DataRow] := clWindow;
          tgGainLoss.CellFont[DataCol,DataRow].Color := clBlack;
        end else
        begin
          tgGainLoss.CellColor[DataCol,DataRow] := clRed;
          tgGainLoss.CellFont[DataCol,DataRow].Color := clWhite;
        end;
      end;                                               
    4: Value := MonthEndingBankAccount.PostedEntry.GainLossCurrency;
    5: Value := MonthEndingBankAccount.PostedEntry.GainLossCrDr;
    else
      ASSERT(false);
  end;
end;

// Check that the account has at least one exchange gain/loss entry in the current period
procedure TfrmGainLoss.AddGridMonthEndingBankAccount(MonthEndingBankAccount: TMonthEndingBankAccount);
var
  Count: Integer;
begin
  Count := Length(FGridMonthEndingBankAccounts);

  SetLength(FGridMonthEndingBankAccounts, Count + 1);
  
  FGridMonthEndingBankAccounts[Count] := MonthEndingBankAccount;
end;

function TfrmGainLoss.CheckGainLossDates(BankAccount: TBank_Account; MonthEnding: TMonthEnding): boolean;
var
  i: integer;
  GainLossDate: TDateTime;
begin
  Result := False;
  for i := 0 to BankAccount.baExchange_Gain_Loss_List.ItemCount - 1 do
  begin
    GainLossDate :=
      StDate.StDateToDateTime(BankAccount.baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(i).glFields.glDate);
    Result := IsSameDay(StartOfTheMonth(GainLossDate), StartOfTheMonth(MonthEnding.Date));
    if Result then
      break; // Only need to check that there's at least one valid entry
  end;
end;

procedure TfrmGainLoss.ClearGridMonthEndingBankAccount;
begin
  SetLength(FGridMonthEndingBankAccounts, 0);
end;

// Back (previous month)
procedure TfrmGainLoss.tbPreviousClick(Sender: TObject);
var
  LastDay: TStDate;
begin
  LastDay := GetLastDayOfLastMonth(DateTimeToStDate(FPeriodEndDate));
  FPeriodEndDate := StDateToDateTime(LastDay);
  if UpdateGridMonth(True) then
    UpdatePeriodEndDate;
end;

// Forward (next month)
procedure TfrmGainLoss.tbNextClick(Sender: TObject);
var
  LastDay: TStDate;
begin
  LastDay := GetLastDayOfMonth(DateTimeToStDate(IncMonth(FPeriodEndDate, 1)));
  FPeriodEndDate := StDateToDateTime(LastDay);
  if UpdateGridMonth(True) then
    UpdatePeriodEndDate;
end;

end.
