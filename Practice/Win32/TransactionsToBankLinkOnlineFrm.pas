unit TransactionsToBankLinkOnlineFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcpf, Buttons,
  BanklinkOnlineTaggingServices, OSFont, Menus, StrUtils, Progress,
  StDate;

type
  TfrmTransactionsToBankLinkOnline = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblTransactionsExportableTo: TLabel;
    Label3: TLabel;
    edtTransactionsToDate: TOvcPictureField;
    chkExportChartOfAccounts: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    BtnCal: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnCalClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FMaxExportableDate: TStDate;
    
    FExportStatistics: TExportStatistics;
    FDataExportError: Boolean;
    FErrorDetails: TFatalErrorDetails;

    function ValidateFields: Boolean;
    procedure ExportTaggedAccounts(ProgressForm: IDualProgressForm; CallbackParams: Pointer);
    procedure GetMaxExportableDate(ProgressForm: ISingleProgressForm);
  public
    class procedure ShowDialog(Owner: TComponent; PopupParent: TCustomForm); static;
  end;

var
  frmTransactionsToBankLinkOnline: TfrmTransactionsToBankLinkOnline;

implementation

uses
  OvcDate, ImagesFrm, Globals, StDateSt, GenUtils, RzPopups, WarningMoreFrm, YesNoDlg, ModalProgressFrm, ModalDualProgressFrm, BanklinkOnlineServices, InfoMoreFrm, ErrorMoreFrm,
  LOGUTIL, bkBranding;

{$R *.dfm}

procedure TfrmTransactionsToBankLinkOnline.BtnCalClick(Sender: TObject);
var
  PopupPanel: TRzPopupPanel;
  Calendar: TRzCalendar;
begin
  PopupPanel := TRzPopupPanel.Create(Owner);

  try
    Calendar := TRzCalendar.Create(PopupPanel);
    Calendar.Font := edtTransactionsToDate.Font;
    Calendar.Parent := PopupPanel;
    PopupPanel.Parent := edtTransactionsToDate;

    Calendar.IsPopup := True;
    Calendar.Color := edtTransactionsToDate.Color;
    Calendar.Elements := [ceYear,ceMonth,ceArrows,ceDaysOfWeek,ceFillDays,ceTodayButton,ceClearButton];
    Calendar.FirstDayOfWeek := fdowLocale;
    Calendar.Handle; // Creates the handle

    if edtTransactionsToDate.AsStDate <> 0 then
    begin
      Calendar.Date := StDate.StDateToDateTime(edtTransactionsToDate.AsStDate);
    end;

    //Calendar.BorderOuter := fsFlat;
    Calendar.Visible := True;
    Calendar.OnClick := PopupPanel.Close;

    if PopupPanel.Popup(edtTransactionsToDate) then
    begin
       if ( Calendar.Date <> 0 ) then
       begin
         edtTransactionsToDate.AsStDate := StDate.DateTimeToStDate(Calendar.Date);
       end
       else
       begin
         edtTransactionsToDate.AsStDate := 0;
       end;
    end;
  finally
    PopupPanel.Free;
  end;
end;

procedure TfrmTransactionsToBankLinkOnline.Button1Click(Sender: TObject);
var
  ProgressData: TProgressData;
begin
  if ValidateFields then
  begin
    if AskYesNo('Export data to BankLink Online', 'Are you sure you want to send unsent client transactions to Banklink Online?', Dlg_Yes, 0) = DLG_YES then
    begin
      if Assigned(ProductConfigService.Clients) then
      begin
        FDataExportError := False;

        TfrmModalDualProgress.ShowProgress(Self, 'Please wait...', 'Export data to BankLink Online', ExportTaggedAccounts, ProgressData);

        if not FDataExportError then
        begin
          if not ProgressData.ExceptionRaised then
          begin
            if FExportStatistics.TransactionsExported > 0 then
            begin
              HelpfulInfoMsg('BankLink Practice successfully exported data to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, edtTransactionsToDate.AsStDate, False) + #10#13 +
                              IntToStr(FExportStatistics.TransactionsExported) + ' Transaction(s) exported' + #10#13 +
                              IntToStr(FExportStatistics.AccountsExported) + ' Account(s) exported' + #10#13 +
                              IntToStr(FExportStatistics.ClientFilesProcessed ) + ' Client files(s) Processed', 0);
            end
            else
            begin
              HelpfulInfoMsg('BankLink Practice did not find any transactions up to ' + StDateToDateString(BKDATEFORMAT, edtTransactionsToDate.AsStDate, False) + ' to export to BankLink Online.', 0);
            end;
          end
          else
          begin
            HelpfulErrorMsg(Format('Due to the following error, BankLink Practice was unable to complete the transaction export to BankLink Online. - %s.', [ProgressData.Exception.Message]), 0);
            
            LogUtil.LogMsg(lmError, 'TransactionsToBankLinkOnlineFrm', 'Exception exporting account transactions, Error Message : ' + ProgressData.Exception.Message);
          end;
        end
        else
        begin
          if FExportStatistics.TransactionsExported > 0 then
          begin
            HelpfulInfoMsg('BankLink Practice successfully exported data to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, edtTransactionsToDate.AsStDate, False) + #10#13 +
                            IntToStr(FExportStatistics.TransactionsExported) + ' Transaction(s) exported' + #10#13 +
                            IntToStr(FExportStatistics.AccountsExported) + ' Account(s) exported' + #10#13 +
                            IntToStr(FExportStatistics.ClientFilesProcessed ) + ' Client files(s) Processed' + #10#13#10#13 +
                            'Due to an error that has occurred, BankLink Practice may not have exported all transactions to BankLink Online.', 0);
          end
          else
          begin
            HelpfulInfoMsg('Due to an error that has occurred, BankLink Practice was unable to export transactions to BankLink Online.', 0);
          end;

          Close;
        end;
      end
      else
      begin
        LogUtil.LogMsg(lmError, 'ExportTaggedAccounts', 'Error getting client list from BankLink Online');
      end;
    end;
  end;
end;

procedure TfrmTransactionsToBankLinkOnline.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmTransactionsToBankLinkOnline.ExportTaggedAccounts(ProgressForm: IDualProgressForm; CallbackParams: Pointer);
var
  ExportOptions: TExportOptions;
begin
  ExportOptions.MaxTransactionDate := edtTransactionsToDate.AsStDate;
  ExportOptions.ExportChartOfAccounts := chkExportChartOfAccounts.Checked;

  TBankLinkOnlineTaggingServices.ExportTaggedAccounts(ProductConfigService.CachedPractice, ExportOptions, ProgressForm, FExportStatistics, FDataExportError, FErrorDetails);
end;

procedure TfrmTransactionsToBankLinkOnline.FormCreate(Sender: TObject);
begin
  Caption := bkBranding.Rebrand(Caption);
  Label1.Caption := bkBranding.Rebrand(Label1.Caption);
end;

procedure TfrmTransactionsToBankLinkOnline.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    ModalResult := mrCancel;
  end;
end;

procedure TfrmTransactionsToBankLinkOnline.FormShow(Sender: TObject);
begin
  ProductConfigService.LoadClientList;

  edtTransactionsToDate.Epoch       := BKDATEEPOCH;
  edtTransactionsToDate.PictureMask := BKDATEFORMAT;

  edtTransactionsToDate.AsStDate := OvcDate.CurrentDate;

  chkExportChartOfAccounts.Checked := True;

  TfrmModalProgress.ShowProgress(Self, 'Please wait...', 'Export data to BankLink Online', GetMaxExportableDate);

  if FMaxExportableDate > 0 then
  begin
    lblTransactionsExportableTo.Caption := ReplaceText(lblTransactionsExportableTo.Caption, '<exportable>', StDateToDateString(BKDATEFORMAT, FMaxExportableDate, False));
  end
  else
  if FMaxExportableDate = -1 then
  begin
    lblTransactionsExportableTo.Caption := 'There are no exportable transactions available.';
  end
  else
  begin
    PostMessage(Handle, WM_CLOSE, 0, 0);
  end;
end;

procedure TfrmTransactionsToBankLinkOnline.GetMaxExportableDate(ProgressForm: ISingleProgressForm);
begin
  FMaxExportableDate := TBankLinkOnlineTaggingServices.GetMaxExportableTransactionDate(ProgressForm);
end;

class procedure TfrmTransactionsToBankLinkOnline.ShowDialog(Owner: TComponent; PopupParent: TCustomForm);
var
  Dialog: TfrmTransactionsToBankLinkOnline;
begin
  Dialog := TfrmTransactionsToBankLinkOnline.Create(Owner);

  try
    Dialog.PopupParent := PopupParent;
    Dialog.PopupMode := pmExplicit;

    Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

function TfrmTransactionsToBankLinkOnline.ValidateFields: Boolean;
begin
  Result := False;

  if edtTransactionsToDate.AsStDate <= 0 then
  begin
    HelpfulWarningMsg('Invalid date entered.', 0);

    edtTransactionsToDate.SetFocus;
  end
  else if edtTransactionsToDate.AsStDate > CurrentDate then
  begin
    HelpfulWarningMsg('Invalid date entered.', 0);

    edtTransactionsToDate.SetFocus;
  end
  else
  begin
    Result := True;
  end;
end;

end.
