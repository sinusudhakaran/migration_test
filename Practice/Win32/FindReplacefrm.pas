unit FindReplacefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateSelectorFme, StdCtrls, Buttons, AccountSelectorFme, ComCtrls,
  ExtCtrls,
  OsFont;

type
  TFindReplaceDlg = class(TForm)
    pBtn: TPanel;
    btnCancel: TButton;
    BtnOK: TButton;
    PCMain: TPageControl;
    tsOptions: TTabSheet;
    tsAdvanced: TTabSheet;
    AccountSelector: TfmeAccountSelector;
    Label1: TLabel;
    Label2: TLabel;
    EFind: TEdit;
    EReplace: TEdit;
    btnFindChart: TBitBtn;
    btnReplaceChart: TBitBtn;
    GroupBox1: TGroupBox;
    rbSel: TRadioButton;
    rbAll: TRadioButton;
    DateSelector: TfmeDateSelector;
    procedure FormCreate(Sender: TObject);
    procedure btnFindChartClick(Sender: TObject);
    procedure btnReplaceChartClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FAllDates: Boolean;
    function Validate(const Prompt : Boolean = False): Boolean;
    function FindReplace: Boolean;
    procedure SetAllDates(const Value: Boolean);
    property AllDates: Boolean read FAllDates write SetAllDates;
    { Private declarations }
  protected
     procedure UpdateActions; override;  
  public
    { Public declarations }
  end;

procedure FindAndReplace;

implementation

{$R *.dfm}

uses
   bkHelp,
   GSTCALC32,
   UpdateMF,
   ClientHomePagefrm,
   AutoCode32,
   bkConst,
   bkDefs,
   baObj32,
   YesNoDlg,
   InfoMoreFrm,
   ErrorMoreFrm,
   AccountLookupFrm,
   ImagesFrm,
   bkXPThemes,
   SelectDate,
   bkdateutils,
   Globals,
   cldateutils,
   ForexHelpers,
   MainFrm;


procedure FindAndReplace;
var Ldlg: TFindReplaceDlg;
begin
   Ldlg := TFindReplaceDlg.Create( Application.MainForm);
   try
      if lDlg.ShowModal = mrOK then begin
         RefreshHomepage;
         ReloadCodingScreens(false);
      end;
   finally
      ldlg.Free;
   end;
end;


procedure TFindReplaceDlg.btnFindChartClick(Sender: TObject);
begin
   EFind.Text :=  LookUpChart(EFind.Text);
end;

procedure TFindReplaceDlg.BtnOKClick(Sender: TObject);
begin
   if Validate(True) then
      if FindReplace then
         ModalResult := mrOK;
end;

procedure TFindReplaceDlg.btnReplaceChartClick(Sender: TObject);
begin
   EReplace.Text :=  LookUpChart(EReplace.Text);
end;

function TFindReplaceDlg.FindReplace: Boolean;
var A,T: Integer;
    ba: TBank_Account;
    tx: pTransaction_Rec;
    ds: pDissection_Rec;
    D1, D2: Integer;
    cFound,
    cGStSkipped: Integer;
    sFind,sReplace: string;
    MaintainMemScanStatus: boolean;
type
    AccCode = string[20];

    function ReplaceText(var Value:AccCode ): Boolean;
    begin
       if SameText(Value,sFind) then begin
          Result := True;
          Value := sReplace;
          inc(cFound);
          // While we are here..
          tx.txCoded_By := cbManual;
       end else
          Result := False;
    end;

begin
   MaintainMemScanStatus := false;
   try
     if Assigned(frmMain) then
     begin
       MaintainMemScanStatus := frmMain.MemScanIsBusy;
       frmMain.MemScanIsBusy := True;
       MyClient.clRecommended_Mems.RemoveAccountsFromMems(false);
     end;
     Result := False;
     // Get the dates...
     if AllDates then begin
        D1 := 0;
        D2 := MaxInt;
     end else begin
        D1 := stNull2Bk(DateSelector.eDateFrom.AsStDate);
        D2 := stNull2Bk(DateSelector.eDateTo.AsStDate);
     end;
     // Get the Text
     sFind := Trim(EFind.Text);
     sReplace := Trim(EReplace.Text);

     // Reset the counters;
     cFound := 0;
     cGStSkipped := 0;

     for A := 0 to Pred(AccountSelector.AccountCheckBox.Items.Count) do
        if AccountSelector.AccountCheckBox.Checked[A] then begin
           ba := TBank_Account(AccountSelector.AccountCheckBox.Items.Objects[A]);

           AutoCodeEntries(MyClient, ba, AllEntries, D1, D2, false);

           //Transactions
           for T := 0 to ba.baTransaction_List.Last do begin
              tx := ba.baTransaction_List.Transaction_At(T);

              if (tx.txLocked)
              or (tx.txDate_Transferred <> 0) then
                 Continue;

              if (tx.txDate_Effective < D1)
              or (tx.txDate_Effective > D2) then
                 Continue;

              ds := tx.txFirst_Dissection;
              if ds = nil then begin
                 // Do the Transaction...
                 if ReplaceText(tx.txAccount) then begin
                    tx.txHas_Been_Edited := True;
                    if tx.txGST_Has_Been_Edited then
                       Inc(cGStSkipped)
                    else
  //                     CalculateGST( MyClient, tx.txDate_Effective, tx.txAccount, tx.txAmount, tx.txGST_Class, tx.txGST_Amount);
                       CalculateGST( MyClient, tx.txDate_Effective, tx.txAccount, tx.Local_Amount, tx.txGST_Class, tx.txGST_Amount);
                 end;
              end else begin
                 // Do the Dissections
                 while Assigned(ds) do begin
                    if ReplaceText(ds.dsAccount) then begin
                       ds.dsHas_Been_Edited := True;
                       if ds.dsGST_Has_Been_Edited then
                          Inc(cGStSkipped)
                       else
  //                        CalculateGST( MyClient, tx.txDate_Effective, ds.dsAccount, ds.dsAmount, ds.dsGST_Class, ds.dsGST_Amount);
                          CalculateGST( MyClient, tx.txDate_Effective, ds.dsAccount, ds.Local_Amount, ds.dsGST_Class, ds.dsGST_Amount);
                    end;
                    ds := ds.dsNext;
                 end;
              end;
           end;
        end;

     if cFound > 0 then begin
        sFind := Format('%d Chart code(s) updated',[cFound]);
        if cGStSkipped > 0 then begin
           sFind := sFind + Format(#13'The %1:s content of %0:d transactions with the %1:s edited,'#13 +
                'have not been updated.'#13 +
                'These transactions can be viewed in the %1:s override report.',[cGStSkipped, MyClient.TaxSystemNameUC]);
        end;

        HelpfulInfoMsg(sFind,0);
        Result := True;
     end else begin
        if AskYesNo('Find and Replace','No codes found'#13#13'Try again?', DLG_NO, 0 ) <> DLG_NO then begin
           pcMain.ActivePage := tsOptions;
           EFind.SetFocus;
        end else
           Result := True;
     end;
   finally
     if Assigned(frmMain) then
     begin
      MyClient.clRecommended_Mems.PopulateUnscannedListAllAccounts(false);
      if not MaintainMemScanStatus then
        frmMain.MemScanIsBusy := False;
     end;
   end;
end;

procedure TFindReplaceDlg.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  // Any Help Index??
  Self.HelpContext := BKH_Find_and_replace_a_chart_of_accounts_code;
  Self.Caption := 'Find and Replace in Coding';

  //Bitmap
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnFindChart.Glyph);
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnReplaceChart.Glyph);

  // Set the date selector details
  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( BAllData( MyClient ), EAllData( MyClient ), btnOk);
  // Don't need this but looks much better...
  gCodingDateFrom := MyClient.clFields.clPeriod_Start_Date;
  gCodingDateTo   := Myclient.clFields.clPeriod_End_Date;
  DateSelector.eDateFrom.asStDate := BkNull2St(gCodingDateFrom);
  DateSelector.eDateTo.asStDate   := BkNull2St(gCodingDateTo);

  // Fill the Account selector
  AccountSelector.LoadAccounts(MyClient);
  AccountSelector.btnSelectAllAccountsClick(nil);

end;

procedure TFindReplaceDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
  Char(vk_Escape) : begin
          Key := #0;
          ModalResult := mrCancel;
      end;
  end;
end;

procedure TFindReplaceDlg.SetAllDates(const Value: Boolean);
var I: Integer;
begin
  if FAllDates <> Value then begin
     FAllDates := Value;
     DateSelector.Enabled := not FAllDates;
     //Above works, but the controls don't 'gray' so..
     for I := 0 to Dateselector.ControlCount -1 do
        Dateselector.Controls[I].Enabled := not FAllDates;
  end;
end;

procedure TFindReplaceDlg.UpdateActions;
begin
   inherited;
   AllDates := rbAll.Checked;
end;

function TFindReplaceDlg.Validate(const Prompt : Boolean = False): Boolean;
var D1, D2, I: Integer;
    FindStr,
    ReplaceStr,
    PMsg: string;

    procedure HandleError(Sheet: tTabSheet; Control: TWinControl; Msg: string);
    begin
       if not Prompt then
          Exit;
       PCMain.ActivePage := Sheet;
       HelpfulErrorMsg(Msg,0);
       Control.SetFocus;
    end;

begin
  Result := False;
  FindStr := Trim(EFind.Text);
  if FindStr = '' then begin
     HandleError(tsOptions,EFind,'Please enter text to find.');
     Exit;
  end;

  ReplaceStr := Trim(EReplace.Text);
  if  ReplaceStr = '' then begin
     HandleError(tsOptions,EReplace,'Please enter replacement text.');
     Exit;
  end;

  if FindStr = ReplaceStr then  begin
     HandleError(tsOptions,EReplace,'Find and replace texts are the same.');
     Exit;
  end;

  if not MyClient.clChart.CanCodeTo(ReplaceStr) then begin
     if AskYesNo(
          format('Cannot Post to "%s".',[ReplaceStr]),
          format('Cannot post to "%s".'#13'Do you want to continue?',[ReplaceStr]),
          DLG_YES, 0
                ) <> DLG_YES then begin
                   PCMain.ActivePage := tsOptions;
                   EReplace.SetFocus;
                   Exit;
          end;
  end;

  if AllDates then begin
      if Prompt then
          PMsg := 'in all transactions';
  end else begin
     // Need to check the dates...

     if (not DateSelector.ValidateDates) then begin
        HandleError(tsOptions,DateSelector.eDateFrom,'Please select valid dates.');
        Exit;
     end;

     D1 := stNull2Bk(DateSelector.eDateFrom.AsStDate);
     D2 := stNull2Bk(DateSelector.eDateTo.AsStDate);

     if D1 > D2 then begin
        HandleError(tsOptions,DateSelector.eDateTo,'"From" Date is later than "To" Date.  Please select valid dates.');
        Exit;
     end;
     // Anything else...
     if Prompt then
        PMsg := format('in all transactions from %s',[GetDateRangeS(D1,D2)]);
  end;


  // Accounts..
  D1 := 0;
  D2 := 0;
  for I := 0 to Pred(AccountSelector.AccountCheckBox.Items.Count) do
     if AccountSelector.AccountCheckBox.Checked[I] then
        inc(D1) //Selected
     else
        inc(D2);//Not selected

  if D1 = 0 then begin
     HandleError(tsAdvanced,AccountSelector.chkAccounts,'Please select at least one account.');
     Exit;
  end;


  if Prompt then begin
     // Build the rest of the prompt
     if D2 > 0 then begin  // not all selected..
        Pmsg := Pmsg + ','#13'in selected accounts.'
     end else
        Pmsg := Pmsg + '.';

     PMsg :=  Format('Replace "%s" with "%s"'#13'%s'#13#13'This operation cannot be undone. Do you wish to continue?',
          [Trim(EFind.Text), Trim(EReplace.Text), PMsg]);

     if AskYesNo('Find and Replace',Pmsg, DLG_YES, 0 ) <> DLG_YES then
        Exit;
  end;

  // Good to go..
  Result := True;
end;

end.
