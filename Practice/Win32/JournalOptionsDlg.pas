unit JournalOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CodeDateDlg, Buttons, StdCtrls, ExtCtrls, AccountSelectorFme,
  DateSelectorFme, ComCtrls, RptJournalList;

type
  TDlgJournalOptions = class(TdlgCodeDate)
    chkGroupBy: TCheckBox;
    lblFormat: TLabel;
    rbSummary: TRadioButton;
    rbDetailed: TRadioButton;
    lblSortOrder: TLabel;
    cmbSortOrder: TComboBox;
    procedure rbSummaryClick(Sender: TObject);
    procedure rbDetailedClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure SetNextControl;
  public
    { Public declarations }
  end;

var
  DlgJournalOptions: TDlgJournalOptions;

  function EnterJournalOptions(Caption : string;
                           Text :string;
                           var Params: TListJournalsParam): boolean;


implementation

uses
  bkhelp,
  bkConst,
  StdHints,
  Globals;

{$R *.dfm}

function EnterJournalOptions(Caption : string;
                         Text :string;
                         var Params: TListJournalsParam): boolean;
var
  JournalOptDlg: TDlgJournalOptions;
  AccountSet: TAccountSet;
begin
  Result := False;
  if not (Assigned(Params) and
          Assigned(Params.Client) and
          Assigned(MyClient)) then
    Exit;

  JournalOptDlg:= TDlgJournalOptions.Create(Application.MainForm);
  try
    BKHelpSetUp(JournalOptDlg, BKH_List_journals);
    AccountSet := [btCashJournals..btStockBalances];
    with JournalOptDlg do
    begin
      Label1.caption := text;
      AllowBlank := True;
      Caption := Caption;
      chkWrapNarration.Visible := True;
      chkWrapNarration.Checked := Params.WrapNarration;
      chkNonBaseCurrency.Visible := False;
      rbSummary.Checked := Params.ShowSummary;
      rbDetailed.Checked := not Params.ShowSummary;
      chkGroupBy.Checked := Params.GroupByJournalType;
      case Params.SortBy of
        csDateAndReference : JournalOptDlg.cmbSortOrder.ItemIndex := 0;
        csDateEffective : JournalOptDlg.cmbSortOrder.ItemIndex := 1;
        csReference : JournalOptDlg.cmbSortOrder.ItemIndex := 2;
      end;

      if AccountSet = [] then
      begin
         tsAdvanced.TabVisible := False;
         tsoptions.TabVisible := False;
         pcoptions.ActivePage := tsOptions;
      end else begin
         fmeAccountSelector1.LoadAccounts(Params.Client,AccountSet);
         fmeAccountSelector1.UpdateSelectedAccounts(Params);
      end;

      btnpreview.Visible := true;
      btnPreview.default := true;
      btnPreview.Hint    := STDHINTS.PreviewHint;

      btnFile.Visible    := true;
      btnFile.Hint       := STDHINTS.PrintToFileHint;

      btnEmail.Visible   := true;

      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      btnOK.Hint         := STDHINTS.PrintHint;

      RptParams := Params;

      SetNextControl;

      dlgDateFrom := Params.FromDate;
      dlgDateTo   := Params.ToDate;
    end;

    if JournalOptDlg.Execute then
    begin
       {store updates in globals}
       Params.FromDate := JournalOptDlg.dlgDateFrom;
       Params.ToDate   := JournalOptDlg.dlgDateTo;
       Params.WrapNarration := JournalOptDlg.chkWrapNarration.Checked;

       case JournalOptDlg.cmbSortOrder.ItemIndex of
        0 : Params.SortBy := csDateAndReference;
        1 : Params.SortBy := csDateEffective;
        2 : Params.SortBy := csReference;
       end;
       Params.ShowSummary := JournalOptDlg.rbSummary.Checked;
       Params.GroupByJournalType := JournalOptDlg.chkGroupBy.Checked;
       
       if not JournalOptDlg.AllowBlank then
       begin
          MyClient.clFields.clPeriod_Start_Date := Params.FromDate;
          Myclient.clFields.clPeriod_End_Date   := Params.ToDate;
       end;
       Result := Params.DlgResult(JournalOptDlg.Pressed);
    end;
  finally
    FreeAndNil(JournalOptDlg);
  end;
end;

procedure TDlgJournalOptions.FormShow(Sender: TObject);
begin
  inherited;
  {Inherited from base class but not required for journal report}
  radButton1.Visible := False;
  radButton2.Visible := False;
end;

procedure TDlgJournalOptions.rbDetailedClick(Sender: TObject);
begin
  inherited;
  rbSummary.Checked := False;
end;

procedure TDlgJournalOptions.rbSummaryClick(Sender: TObject);
begin
  inherited;
  rbDetailed.Checked := False;
end;

procedure TDlgJournalOptions.SetNextControl;
begin
  DateSelector.NextControl := chkWrapNarration;
end;

end.
