unit StatusReportRangeDlg;
//------------------------------------------------------------------------------
{
   Title:       StatusReportRangeDlg

   Description: Dialog for user to select date and client files to be shown
                on the status report

   Remarks:     A maximum of 12 months can be selected.

   Author:      Matthew Hopkins Feb 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DateSelectorFme, Menus,
  OSFont;

type
   TStatusRepOptions = record
      soDateFrom : integer;
      soDateTo   : integer;
      soByStaffMember : boolean;
      soFromCode : string;
      soToCode   : string;
   end;

type
  TdlgStatusReportRange = class(TForm)
    edtToCode: TEdit;
    edtFromCode: TEdit;
    lblFrom: TLabel;
    lblTo: TLabel;
    rbClient: TRadioButton;
    rbStaffMember: TRadioButton;
    Label1: TLabel;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    Label2: TLabel;
    DateSelector: TfmeDateSelector;

    procedure rbClientClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
    BtnPressed : integer;
    LastMonthEOMDate : integer;
  public
    { Public declarations }
  end;

  function GetStatusReportRange(var StatusRepRange : TStatusRepOptions; var Btn : integer) : boolean;

//******************************************************************************
implementation

uses
   bkDateUtils,
   BKHelp,
   bkXPThemes,
   warningMoreFrm,
   globals,
   stDate;
{$R *.DFM}

//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.rbClientClick(Sender: TObject);
begin
  if rbClient.checked then begin
    lblFrom.caption := 'F&rom Client Code';
    lblTo.caption   := 'T&o Client Code';

    edtFromCode.Hint    :=
       'Include Clients from this code|'+
       'Include Clients from this code';
    edtToCode.Hint      :=
       'Include Clients up to this code|'+
       'Include Clients up to this code';
  end
  else begin
    lblFrom.caption := 'F&rom Staff Member';
    lblTo.caption   := 'T&o Staff Member';

    edtFromCode.Hint    :=
       'Include Staff Members from this code|'+
       'Include Staff Members from this code';
    edtToCode.Hint      :=
       'Include Staff Members up to this code|'+
       'Include Staff Members up to this code';
  end;
  lblTo.left            := lblFrom.left;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);

   with DateSelector do begin
      //set date bounds to first and last trx date
      InitDateSelect( MinValidDate, MaxValidDate, btnPreview);
      eDateFrom.asStDate := -1;
      eDateTo.asStDate   := -1;

      Last2Months1.Visible := False; //

      btnQuik.Visible := true;
   end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function GetStatusReportRange(var StatusRepRange : TStatusRepOptions; var Btn : integer) : boolean;
var
   StatusReportRange : TdlgStatusReportRange;

begin
   result := false;
   StatusReportRange := TdlgStatusReportRange.Create(Application.MainForm);
   with StatusReportRange do begin
      try
         BKHelpSetUp(StatusReportRange, BKH_Client_Status_Report);
         BtnPressed := BTN_NONE;
         //set initial date range to 12 mths from end of last month
         DateSelector.eDateFrom.AsStDate := StatusRepRange.soDateFrom;
         DateSelector.eDateTo.AsStDate   := StatusRepRange.soDateTo;
         LastMonthEOMDate                := StatusRepRange.soDateTo;

         edtFromCode.Text := StatusRepRange.soFromCode;
         edtToCode.Text   := StatusRepRange.soToCode; 

         //-------------
         ShowModal;
         //-------------
         if BtnPressed in [ btn_preview, btn_print, BTN_FILE] then begin
            StatusRepRange.soDateFrom      := DateSelector.eDateFrom.AsStDate;
            StatusRepRange.soDateTo        := DateSelector.eDateTo.AsStDate;
            StatusRepRange.soByStaffMember := rbStaffMember.Checked;
            StatusRepRange.soFromCode      := edtFromCode.Text;
            StatusRepRange.soToCode        := edtToCode.Text;
            Btn    := BtnPressed;
            result := true;
         end;
      finally
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.btnPreviewClick(Sender: TObject);
begin
   BtnPressed := BTN_PREVIEW;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.btnFileClick(Sender: TObject);
begin
   BtnPressed := BTN_FILE;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.btnPrintClick(Sender: TObject);
begin
   BtnPressed := BTN_PRINT;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.btnCancelClick(Sender: TObject);
begin
   BtnPressed := BTN_NONE;
   Close;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   d,m,y : integer;
begin
  if BtnPressed in [ BTN_PRINT, BTN_PREVIEW, BTN_FILE] then begin
      //validate form
      if (not DateSelector.ValidateDates) then
      begin
        DateSelector.eDateFrom.SetFocus;
        CanClose := false;
        Exit;
      end;

      if (DateSelector.eDateFrom.AsStDate > DateSelector.eDateTo.AsStDate) then
      begin
        HelpfulWarningMsg('The From date must be before the To date.',0);
        DateSelector.eDateTo.SetFocus;
        CanClose := false;
        exit;
      end;
      //check that dates are less than 12 mths apart.
      with DateSelector do
         DateDiff( eDateFrom.AsStDate, eDateTo.AsStDate, d, m, y);
      if ( y > 0) then begin
         HelpfulWarningMsg( 'You cannot select a date range that is larger than 12 mths!' ,0);
         DateSelector.eDateTo.SetFocus;
         CanClose := false;
         exit;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure TdlgStatusReportRange.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           DateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           DateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           DateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;

end.
