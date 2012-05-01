unit TransactionsToBankLinkOnlineFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcpf, Buttons, ModalProgressFrm,
  BanklinkOnlineTaggingServices, OSFont, Menus, StrUtils;

type
  TfrmTransactionsToBankLinkOnline = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblTransactionsExportableTo: TLabel;
    Label3: TLabel;
    btnNext: TSpeedButton;
    btnQuik: TSpeedButton;
    btnPrev: TSpeedButton;
    edtTransactionsToDate: TOvcPictureField;
    chkExportChartOfAccounts: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    pmDates: TPopupMenu;
    LastMonth1: TMenuItem;
    Last2Months1: TMenuItem;
    LastQuarter1: TMenuItem;
    Last6months1: TMenuItem;
    ThisYear1: TMenuItem;
    LastYear1: TMenuItem;
    AllData1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnQuikClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ExportTaggedAccounts(ProgressForm: TfrmModalProgress);
  public
    class procedure ShowDialog(Owner: TComponent; PopupParent: TCustomForm); static;
  end;

var
  frmTransactionsToBankLinkOnline: TfrmTransactionsToBankLinkOnline;

implementation

uses
  OvcDate, ImagesFrm, Globals, StDateSt;

{$R *.dfm}

procedure TfrmTransactionsToBankLinkOnline.btnNextClick(Sender: TObject);
begin
  edtTransactionsToDate.asStDate := IncDate(edtTransactionsToDate.asStDate, 1, 0, 0);
end;

procedure TfrmTransactionsToBankLinkOnline.btnPrevClick(Sender: TObject);
begin
  edtTransactionsToDate.asStDate := IncDate(edtTransactionsToDate.asStDate, -1, 0, 0);
end;

procedure TfrmTransactionsToBankLinkOnline.btnQuikClick(Sender: TObject);
var
   ClientP, ScreenP : TPoint;
begin
   ClientP.x := btnQuik.left + btnQuik.width; ClientP.y := btnQuik.top;

   ScreenP   := Self.ClientToScreen(clientP);

   pmDates.Popup(Screenp.x,ScreenP.y);
end;

procedure TfrmTransactionsToBankLinkOnline.Button1Click(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to send all unsent client transactions to Banklink Online?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    TfrmModalProgress.ShowProgress(Self, 'Please wait...', ExportTaggedAccounts);

    Close;
  end;
end;

procedure TfrmTransactionsToBankLinkOnline.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmTransactionsToBankLinkOnline.ExportTaggedAccounts(ProgressForm: TfrmModalProgress);
begin
  TBankLinkOnlineTaggingServices.ExportTaggedAccounts(edtTransactionsToDate.AsStDate, chkExportChartOfAccounts.Checked, ProgressForm);
end;

procedure TfrmTransactionsToBankLinkOnline.FormCreate(Sender: TObject);
var
  MaxExportableDate: TStDate;
begin
  edtTransactionsToDate.Epoch       := BKDATEEPOCH;
  edtTransactionsToDate.PictureMask := BKDATEFORMAT;

  with ImagesFrm.AppImages.Misc do
  begin
    GetBitmap(MISC_ARROWLEFT_BMP, btnPrev.Glyph);
    GetBitmap(MISC_ARROWRIGHT_BMP, btnNext.Glyph);
    GetBitmap(MISC_CALENDAR_BMP, btnQuik.Glyph);
  end;

  MaxExportableDate := TBankLinkOnlineTaggingServices.GetMaxExportableTransactionDate;

  if MaxExportableDate > 0 then
  begin
    lblTransactionsExportableTo.Caption := ReplaceText(lblTransactionsExportableTo.Caption, '<exportable>', StDateToDateString(BKDATEFORMAT, MaxExportableDate, False));
  end;

  edtTransactionsToDate.AsStDate := OvcDate.CurrentDate;
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

end.
