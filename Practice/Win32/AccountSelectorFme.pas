unit AccountSelectorFme;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, clObj32, RptParams, bkConst;


type
  TAccountSet = set of byte;

  TfmeAccountSelector = class(TFrame)
    lblSelectAccounts: TLabel;
    chkAccounts: TCheckListBox;
    btnSelectAllAccounts: TButton;
    btnClearAllAccounts: TButton;
    procedure btnSelectAllAccountsClick(Sender: TObject);
    procedure btnClearAllAccountsClick(Sender: TObject);
  private
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    { Private declarations }
  public
    procedure LoadAccounts(aClient: TClientObj; aAccountSet: TAccountSet =
                           [btBank, btCashJournals, btAccrualJournals,
                            btStockJournals, btOpeningBalances, btYearEndAdjustments];
                           CheckExcludeFromScheduledReports: Boolean = False);
    procedure SaveAccounts(aClient: TClientObj; aParams: TRptParameters);
    procedure UpdateSelectedAccounts(aParams: TRptParameters);
    property AccountCheckBox : TCheckListBox read chkAccounts;
    { Public declarations }
  end;

implementation

uses
  baObj32;


{$R *.dfm}

procedure TfmeAccountSelector.btnSelectAllAccountsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to ( chkAccounts.items.count - 1) do
    chkAccounts.checked[ i] := true;
end;

procedure TfmeAccountSelector.CMShowingChanged(var M: TMessage);
begin
   inherited;
   TabStop := False;
end;

procedure TfmeAccountSelector.LoadAccounts(aClient: TClientObj;
  aAccountSet: TAccountSet; CheckExcludeFromScheduledReports: Boolean);
var
  i: integer;
  ba: TBank_Account;
  baStr: string;
  AccntIdx: integer;
begin
  chkAccounts.Items.Clear;
  for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
    ba := aClient.clBank_Account_List.Bank_Account_At(i);
    if Assigned(ba) then begin
      if (aAccountSet = []) // Filter Empty, Do all...
      or (ba.baFields.baAccount_Type in aAccountSet) //In the Filter
      or ((btForeign in aAccountSet) and ba.IsAForexAccount) then begin
         AccntIdx := AccountCheckBox.Items.AddObject(ba.Title, TObject( ba));
         //Exclude from scheduled reports
         if CheckExcludeFromScheduledReports then
            AccountCheckBox.Checked[AccntIdx] :=
              (Pos(ba.baFields.baBank_Account_Number + ',',
                 aClient.clFields.clExclude_From_Scheduled_Reports) = 0);
      end;
    end;
  end;
end;

procedure TfmeAccountSelector.SaveAccounts(aClient: TClientObj;
  aParams: TRptParameters);
var
  i: integer;
  ba: TBank_Account;
begin                       
  for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
    ba := aClient.clBank_Account_List.Bank_Account_At(i);
    ba.baFields.baTemp_Include_In_Report := false;
  end;
  aParams.AccountList.Clear;
  //now turn back on accounts which are selected
  for i := 0 to Pred(AccountCheckBox.Items.Count) do begin
    ba := TBank_Account(AccountCheckBox.Items.Objects[ i]);
    ba.baFields.baTemp_Include_In_Report := AccountCheckBox.Checked[ i];
    if AccountCheckBox.Checked[ i] then
      aParams.AccountList.Add(ba);
  end;
end;

procedure TfmeAccountSelector.UpdateSelectedAccounts(
  aParams: TRptParameters);
var
  i: integer;
  AccountIdx: integer;
begin
  if aparams.AccountList.Count <> 0 then
    for i := 0 to Pred( aparams.AccountList.Count) do begin
      // Over time could get out of step...
      AccountIdx := AccountCheckBox.Items.IndexOfObject(aparams.AccountList[i]);
      if AccountIdx >= 0 then
        AccountCheckBox.checked[AccountIdx]:= True
    end
  else
    btnSelectAllAccounts.Click;
end;

procedure TfmeAccountSelector.btnClearAllAccountsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to ( chkAccounts.items.count - 1) do
    chkAccounts.checked[ i] := false;
end;

end.
