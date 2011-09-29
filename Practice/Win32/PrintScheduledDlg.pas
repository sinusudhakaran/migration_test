unit PrintScheduledDlg;
//------------------------------------------------------------------------------
{
   Title:       Scheduled Reporting Options Dialog

   Description: Dialog to select options for printing scheduled reports

   Remarks:     Modified Aug 2000 to allow filtering of clients with incomplete accounts

   Author:      Matthew

   Last Reviewed: 20 May 2003 by MH
}
//------------------------------------------------------------------------------

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkOKCancelDlg, StdCtrls, OvcBase, OvcEF, OvcPB, OvcPF, ExtCtrls, ComCtrls,
  Scheduled, RzCmboBx, Buttons, NewReportObj, PrintMgrObj, ReportDefs, SchedrepUtils;

type
  TLookupOption = (ltUser, ltGroup, ltClientType);
  TdlgPrintScheduled = class(TbkOKCancelDlgForm)
    btnPreview: TButton;
    OvcController1: TOvcController;
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    tbsReportSetup: TTabSheet;
    grpSettings: TGroupBox;
    rbStaffMember: TRadioButton;
    rbClient: TRadioButton;
    grpRange: TGroupBox;
    Bevel1: TBevel;
    GroupBox2: TGroupBox;
    btnCoding: TButton;
    btnPayee: TButton;
    btnChart: TButton;
    btnSort: TButton;
    btnClient: TButton;
    btnPrint: TButton;
    Label3: TLabel;
    rcbReportsEnding: TRzComboBox;
    btnSummary: TButton;
    TabSheet1: TTabSheet;
    GroupBox3: TGroupBox;
    btnFaxCoding: TButton;
    btnFaxPayees: TButton;
    btnFaxChart: TButton;
    GroupBox4: TGroupBox;
    Label6: TLabel;
    btnOpenDialog: TSpeedButton;
    edtCoverPageFilename: TEdit;
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    btnTestFax: TButton;
    cmbFaxTransport: TComboBox;
    pnlOffpeak: TPanel;
    Label2: TLabel;
    rbSendImmediate: TRadioButton;
    rbSendOffPeak: TRadioButton;
    Button1: TButton;
    Label4: TLabel;
    cmbPrinter: TComboBox;
    tsMessages: TTabSheet;
    gbInclude: TGroupBox;
    cbToPrinter: TCheckBox;
    cbToFax: TCheckBox;
    cbToEMail: TCheckBox;
    cbToECoding: TCheckBox;
    cbToWebX: TCheckBox;
    cbCheckOut: TCheckBox;
    cbToBusinessProducts: TCheckBox;
    GroupBox6: TGroupBox;
    chkClientHeader: TCheckBox;
    chkStaffHeader: TCheckBox;
    btnHeaderMsg: TButton;
    lblFrom: TLabel;
    edtFromCode: TEdit;
    lblTo: TLabel;
    edtToCode: TEdit;
    Label5: TLabel;
    GroupBox7: TGroupBox;
    rbNew: TRadioButton;
    rbAll: TRadioButton;
    btnListReportsDue: TButton;
    btnFromLookup: TSpeedButton;
    btnToLookup: TSpeedButton;
    Panel1: TPanel;
    rbRange: TRadioButton;
    rbSelection: TRadioButton;
    lblSelection: TLabel;
    btnSelect: TSpeedButton;
    edtSelection: TEdit;
    rbSelectAll: TRadioButton;
    rbGroup: TRadioButton;
    rbClientType: TRadioButton;
    chkGroupHeader: TCheckBox;
    chkClientTypeHeader: TCheckBox;
    ckCDPrint: TCheckBox;
    cbCDPrint: TComboBox;
    gbFaxed: TGroupBox;
    btnCoverPageMsg: TButton;
    ckCDFax: TCheckBox;
    cbCDFax: TComboBox;
    gbEmail: TGroupBox;
    gbNotes: TGroupBox;
    btnEmailMsg: TButton;
    cbCDEmail: TComboBox;
    ckCDEmail: TCheckBox;
    btnBNotesMsg: TButton;
    ckCDNotes: TCheckBox;
    cbCDNotes: TComboBox;
    gbBooks: TGroupBox;
    btnCheckOutMsg: TButton;
    cbCDBooks: TComboBox;
    ckCDBooks: TCheckBox;
    gbwebNotes: TGroupBox;
    btnWebNotesMsg: TButton;
    ckCDwebNotes: TCheckBox;
    cbCDwebNotes: TComboBox;
    btnFaxJobs: TButton;
    btnJobs: TButton;
    GroupBox5: TGroupBox;
    btnOnlineMsg: TButton;
    cbCDOnline: TComboBox;
    ckCDOnline: TCheckBox;
    cbOnline: TCheckBox;

    procedure rbStaffMemberClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCodingClick(Sender: TObject);
    procedure btnChartClick(Sender: TObject);
    procedure btnPayeeClick(Sender: TObject);
    procedure btnClientClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
    procedure btnEmailMsgClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnListReportsDueClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnSummaryClick(Sender: TObject);
    procedure btnCoverPageMsgClick(Sender: TObject);
    procedure btnOpenDialogClick(Sender: TObject);
    procedure btnFaxCodingClick(Sender: TObject);
    procedure btnFaxPayeesClick(Sender: TObject);
    procedure btnFaxChartClick(Sender: TObject);
    procedure btnHeaderMsgClick(Sender: TObject);
    procedure btnBNotesMsgClick(Sender: TObject);
    procedure cmbFaxTransportChange(Sender: TObject);
    procedure btnTestFaxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCheckOutMsgClick(Sender: TObject);
    procedure btnBusinessProductsMsgClick(Sender: TObject);
    procedure btnFromLookupClick(Sender: TObject);
    procedure btnToLookupClick(Sender: TObject);
    procedure rbRangeClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtSelectionExit(Sender: TObject);
    procedure chkClientHeaderClick(Sender: TObject);
    procedure chkUseCustomDocClick(Sender: TObject);
    procedure ckCDClick(Sender: TObject);
    procedure btnWebNotesMsgClick(Sender: TObject);
    procedure btnFaxJobsClick(Sender: TObject);
    procedure btnJobsClick(Sender: TObject);
    procedure btnOnlineMsgClick(Sender: TObject);
  private
    { Private declarations }
    ButtonPressed : integer;
    DownloadedDataAvailable : boolean;

    EmailSubject  : string;
    EmailBody     : string;
    CoverPageSubject : string;
    CoverPageMessage : string;
    HeaderMessage : String;
    BNotesSubject : String;
    BNotesMessage : String;
    CheckOutSubject : String;
    CheckOutMessage : String;
    OnlineSubject : String;
    OnlineMessage : String;

    BusinessProductSubject : String;
    BusinessProductMessage : String;
    WebNotesSubject : String;
    WebNotesMessage : String;
    CodeSelectionList: TStringList;
    FaxPrinter: string;

    procedure SetUpHelp;
    function OkToPost : boolean;

    function TestForWinFax : boolean;
    function TestForWindowsFaxService : boolean;
    procedure NothingToDoMsg;

    procedure DisableForm;
    procedure EnableForm;
    procedure UpdateFaxOptionsUI(Toggle: Boolean = False);
    function GetFaxSetupMsg(FaxTransportType: byte): string;
    procedure LoadPrinters;
    procedure LoadCustomDocuments;
    procedure SavePrinter(PName: string);
    procedure SetPrinterForJob(PRS: TPrintManagerObj; Job: TBKReport; PName: string; ReportIdx: REPORT_LIST_TYPE);
    function SelectPrinter(PName: string; PNameDefault: string): Boolean;
    procedure LoadLookupBitmaps;
    procedure DoClientLookup(edt: TEdit; Op: string; Multiple: Boolean);
    procedure DoUserLookup(edt: TEdit; Op: string; Multiple: Boolean);
    procedure DoGroupLookup(edt: TEdit; Op: string; Multiple: Boolean);
    procedure DoClientTypeLookup(edt: TEdit; Op: string; Multiple: Boolean);
    function DoLookup(LookupType: TLookupOption; Caption: string;
      Multiple: Boolean; AlreadySelectedText: string; var Selection: string): boolean;
    function ValidateRange: boolean;
{    function TestForWindowsFaxServiceViaCOM: boolean;}
  public
    function GetSortByValue: integer;
  end;

  function GetScheduleOptions( var ReportOptions :TSchReportOptions; var btn : integer) : boolean;


//******************************************************************************
implementation

uses
  ReportTypes,
  ComObj,
  globals,
  glConst,
  Admin32,
  BKHelp,
  ErrorMoreFrm,
  InfoMoreFrm,
  Reports,
  ovcDate,
  stDatest,
  WarningMoreFrm,
  bkDateUtils,
  ReportImages,
  SchedRepEmailDlg,
  RptAdmin,
  BkConst,
  ImagesFrm,
  NNWFax,
  dlgFaxDetails,
  ssFaxSupport, SYDEFS,
  {FaxComLib_TLB,}
  WinUtils,
  Printers,
  PrntInfo,
  LADEFS, UserReportSettings, NewReportUtils, UsageUtils, CheckInOutFrm,
  SelectListDlg, bkXPThemes, UsrList32, grpList32, ctypelist32,
  CustomDocEditorFrm, UBatchBase;

{$R *.DFM}

var
  sNoTransactions: string;

const
  WinfaxCoverPageExtn = 'cvp';
  WindowsCoverPageExtn = 'cov';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.FormCreate(Sender: TObject);
begin
  inherited;
  //bkXPThemes.ThemeForm( Self);
  CodeSelectionList := TStringList.Create;
  sNoTransactions := 'Transactions have yet to be downloaded into ' + ShortAppName + '.';
  ButtonPressed := btn_none;
  FaxPrinter := '';

  cbToECoding.caption := '&' + glConst.ECODING_APP_NAME + ' Files';

  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnOpenDialog.Glyph);
  btnBNotesMsg.Caption := '&' + glConst.ECoding_App_Name + ' Message';

  gbNotes.Caption := format('Send %s files',[glConst.ECODING_APP_NAME]);

  gbWebNotes.Caption := format('Send %s transactions',[bkconst.WebNotesName]);
  btnWebNotesMsg.Caption := format('&%s Message',[bkconst.WebNotesName]);

  LoadLookupBitmaps;
  SetUpHelp;
end;
procedure TdlgPrintScheduled.FormDestroy(Sender: TObject);
begin
  inherited;
  CodeSelectionList.Free;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   rbStaffMember.Hint  :=
      'Select to produce the reports in Staff Member order|'+
      'Select to produce the reports in Staff Member order';
   rbClient.Hint       :=
      'Select to produce the reports in Client order|'+
      'Select to produce the reports in Client order';
   chkStaffHeader.Hint  :=
      'Check to include a header page for each Staff Member|'+
      'Check to include a header page for each Staff Member';
   chkClientHeader.Hint :=
      'Check to include a header page for each Client|'+
      'Check to include a header page for each Client';
   chkGroupHeader.Hint  :=
      'Check to include a header page for each Group|' +
      'Check to include a header page for each Group';
   chkClientTypeHeader.Hint :=
      'Check to include a header page for each Client Type|' +
      'Check to include a header page for each Client Type';
   btnCoding.Hint      :=
      'Edit the Reports Settings for the Coding Report|'+
      'Edit the Reports Settings for the Coding Report';
   btnChart.Hint       :=
      'Edit the Reports Settings for the List Chart of Accounts Report|'+
      'Edit the Reports Settings for the List Chart of Accounts Report';
   btnPayee.Hint       :=
      'Edit the Reports Settings for the List Payees Report|'+
      'Edit the Reports Settings for the List Payees Report';
   btnClient.Hint      :=
      'Edit the Reports Settings for the Client Header Report|'+
      'Edit the Reports Settings for the Client Header Report';
   btnSort.Hint       :=
      'Edit the Reports Settings for the Sort Collation Header Report|'+
      'Edit the Reports Settings for the Sort Collation Header Report';
   btnSummary.Hint       :=
      'Edit the Reports Settings for the Summary Report|'+
      'Edit the Reports Settings for the Summary Report';
   edtFromCode.Hint    :=
      'Include codes from this code|'+
      'Include codes from this code';
   edtToCode.Hint      :=
      'Include codes up to this code|'+
      'Include codes up to this code';
   btnEmailMsg.Hint :=
      'Setup the E-mail message that the Reports will be attached to';
   btnBNotesMsg.Hint :=
      'Setup the ' + glConst.ECoding_App_Name + ' E-mail message that the Reports will be attached to';
   btnCheckOutMsg.Hint :=
      'Setup the BankLink Books E-mail message that the Reports will be attached to';
   {btnBusinessProductsMsg.Hint :=
      'Setup the Business Products E-mail message that the Reports will be attached to';}
   rbNew.Hint := 'Transactions received in selected month which have not been sent yet|' +
                 'Transactions received in selected month which have not been sent yet';
   rbAll.Hint := 'All transactions received in selected month|' +
                 'All transactions received in selected month';
   cbToECoding.Hint := 'Include reports to be sent via a ' + glConst.ECoding_App_Name + ' file';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.rbRangeClick(Sender: TObject);
begin
  edtSelection.Enabled := rbSelection.Checked;
  btnSelect.Enabled := rbSelection.Checked;
  lblSelection.Enabled := rbSelection.Checked;
  edtFromCode.Enabled := rbRange.Checked;
  edtToCode.Enabled := rbRange.Checked;
  btnFromLookup.Enabled := rbRange.Checked;
  btnToLookup.Enabled := rbRange.Checked;
  lblFrom.Enabled := rbRange.Checked;
  lblTo.Enabled := rbRange.Checked;
end;

procedure TdlgPrintScheduled.rbStaffMemberClick(Sender: TObject);
begin
  if rbClient.checked then
  begin
    lblFrom.caption := '&From Client Code';
    lblTo.caption   := 'T&o Client Code';

    edtFromCode.Hint    :=
       'Include Clients from this code|'+
       'Include Clients from this code';
    edtToCode.Hint      :=
       'Include Clients up to this code|'+
       'Include Clients up to this code';
    grpSettings.Caption := 'Select Clients';
    lblSelection.Caption := 'Selected Clients';
    rbSelectAll.Caption := 'All Clients';
    edtSelection.Left := edtFromCode.Left;
    edtSelection.Width := 322;
  end
  else if rbStaffMember.Checked then
  begin
    lblFrom.caption := '&From Staff Member';
    lblTo.caption   := 'T&o Staff Member';

    edtFromCode.Hint    :=
       'Include Staff Members from this Staff Member|'+
       'Include Staff Members from this Staff Member';
    edtToCode.Hint      :=
       'Include Staff Members up to this Staff Member|'+
       'Include Staff Members up to this Staff Member';
    grpSettings.caption := ' Select Staff Members';
    lblSelection.Caption := 'Selected Staff Members';
    rbSelectAll.Caption := 'All Staff Members';
    edtSelection.Left := 297;
    edtSelection.Width := 293;
  end
  else if rbGroup.Checked then
  begin
    lblFrom.caption := '&From Group';
    lblTo.caption   := 'T&o Group';

    edtFromCode.Hint    :=
       'Include Clients from this group|'+
       'Include Clients from this group';
    edtToCode.Hint      :=
       'Include Clients up to this group|'+
       'Include Clients up to this group';
    grpSettings.Caption := 'Select Groups';
    lblSelection.Caption := 'Selected Groups';
    rbSelectAll.Caption := 'All Groups';
    edtSelection.Left := edtFromCode.Left;
    edtSelection.Width := 322;
  end
  else if rbClientType.Checked then
  begin
    lblFrom.caption := '&From Client Type';
    lblTo.caption   := 'T&o Client Type';

    edtFromCode.Hint    :=
       'Include Clients from this Client Type|'+
       'Include Clients from this Client Type';
    edtToCode.Hint      :=
       'Include Clients up to this Client Type|'+
       'Include Clients up to this Client Type';
    grpSettings.Caption := 'Select Client Type';
    lblSelection.Caption := 'Selected Client Types';
    rbSelectAll.Caption := 'All Client Types';
    edtSelection.Left := 297;
    edtSelection.Width := 293;
  end;
       
  LoadLookupBitmaps;
  chkStaffHeader.Enabled := rbStaffMember.checked;
  chkGroupHeader.Enabled := rbGroup.Checked;
  chkClientTypeHeader.Enabled := rbClientType.Checked;
  PageControl1.ActivePageIndex := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnPreviewClick(Sender: TObject);
var lsel: Integer;
begin
  if not ( cbToPrinter.Checked  or
           cbToFax.Checked or
           cbToEMail.Checked or
           cbToECoding.Checked or
           cbCheckOut.Checked or
           cbOnline.Checked or
           cbToBusinessProducts.Checked or
           cbToWebX.Checked) then
  begin
    NothingToDoMsg;
    exit;
  end;

  if OkToPost then
  begin
    lsel := cmbPrinter.ItemIndex;
    if Lsel >= 0 then // May have no printers
       SavePrinter(cmbPrinter.Items[Lsel]);
    ButtonPressed := btn_preview;
    Close;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgPrintScheduled.btnPrintClick(Sender: TObject);
begin
   if not ( cbToPrinter.Checked  or
            cbToFax.Checked or
            cbToEMail.Checked or
            cbToECoding.Checked or
            cbCheckOut.Checked or
            cbOnline.Checked or
            cbToBusinessProducts.Checked or
            cbToWebX.Checked) then
   begin
     NothingToDoMsg;
     exit;
   end;

   if OkToPost then begin
      SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
      ButtonPressed := btn_print;
      Close;
   end;
end;
//------------------------------------------------------------------------------

procedure TdlgPrintScheduled.btnOKClick(Sender: TObject);
begin
   if OkToPost then begin
      SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
      ButtonPressed := btn_ok;
      Close;
   end;
end;

procedure TdlgPrintScheduled.btnOnlineMsgClick(Sender: TObject);
begin
  EditScheduledReportsMessage( 'BankLink Books Message',
                               'Type a subject and a message which will be added to all ' +
                               BKBOOKSNAME + ' files sent via ' + BANKLINK_ONLINE_NAME +
                               ' when Scheduled Reports are generated.',
                               OnlineSubject,
                               OnlineMessage);
end;

//------------------------------------------------------------------------------
procedure TdlgPrintScheduled.btnCancelClick(Sender: TObject);
begin
  Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnCodingClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_CODING);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnChartClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_LIST_CHART);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnPayeeClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_LIST_PAYEE);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnClientClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_CLIENT_HEADER);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnSelectClick(Sender: TObject);
begin
  if rbClient.Checked then
    DoClientLookup(edtSelection, 'Select Client Codes', True)
  else if rbStaffMember.Checked then
    DoUserLookup(edtSelection, 'Select Staff Members', True)
  else if rbGroup.Checked then
    DoGroupLookup(edtSelection, 'Select Groups', True)
  else if rbClientType.Checked then
    DoClientTypeLookup(edtSelection, 'Select Client Types', True);
end;

procedure TdlgPrintScheduled.btnSortClick(Sender: TObject);
begin
  //Just Use Staff Member Header settings for all sorting options
  SetupScheduledReport(Report_Sort_Header);
end;
//------------------------------------------------------------------------------

procedure TdlgPrintScheduled.btnSummaryClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_SCHD_REP_SUMMARY);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.chkClientHeaderClick(Sender: TObject);
begin
  {chkUseCustomDoc.Enabled := chkClientHeader.Checked;
  cmbCustomDocList.Enabled := chkUseCustomDoc.Checked
                           and chkClientHeader.Checked;}
end;

procedure TdlgPrintScheduled.chkUseCustomDocClick(Sender: TObject);
begin
  {cmbCustomDocList.Enabled := chkUseCustomDoc.Checked
                           and chkClientHeader.Checked;}
end;

procedure TdlgPrintScheduled.ckCDClick(Sender: TObject);
begin
   cbCDPrint.Enabled := ckCDPrint.Checked;
   cbCDFax.Enabled   := ckCDFax.Checked;
   cbCDEmail.Enabled := ckCDEmail.Checked;
   cbCDBooks.Enabled := ckCDBooks.Checked;
   cbCDNotes.Enabled := ckCDNotes.Checked;
   cbCDWebNotes.Enabled := ckCDwebNotes.Checked;
   cbCDOnline.Enabled := ckCDOnline.Checked;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  TdlgPrintScheduled.GetFaxSetupMsg( FaxTransportType : byte) : string;
var
  Extn : string;
begin
  result := '';
  //make sure that fax transport is available
  case FaxTransportType of
    fxtWinFax : if not TestForWinFax then
      result := 'Faxed reports cannot be included because WinFax is not available';
    fxtWindowsFaxService : if not TestForWindowsFaxService then
      result := 'Faxed reports cannot be included because the Windows Fax Service is not available';
  else
    result := 'You must set up faxing before including faxed reports';
  end;

  if (result = '') then
  begin
    if ( edtCoverPageFilename.Text <> '') then
    begin
      //check coverpage exists
      if not BKFileExists( edtCoverPageFilename.Text) then
      begin
        result := 'Coverpage file cannot be found.';
        exit;
      end;
      //file exists, check extension is correct
      Extn := lowercase( ExtractFileExt( edtCoverPageFilename.Text));
      case FaxTransportType of
      fxtWinFax : if not( Extn = '.' + WinfaxCoverPageExtn) then
        result := 'Cover page format is invalid.  WinFax cannot use the selected file.';
      fxtWindowsFaxService : if not( Extn = '.' + WindowsCoverPageExtn) then
        result := 'Cover page format is invalid.  The Windows Fax Service cannot use the selected file.';
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgPrintScheduled.OkToPost: boolean;
//change to validate fields
var
  sFaxTransport : string;
begin
  result := false;
  if not DownloadedDataAvailable then
  begin
    HelpfulErrorMsg( sNoTransactions, 0);
    Exit;
  end;

  if cbToFax.Checked then
  begin
    sFaxTransport := GetFaxSetupMsg( cmbFaxTransport.ItemIndex);

    if sFaxTransport <> '' then
    begin
      HelpfulErrorMsg( sFaxTransport, 0);
      Exit;
    end;
  end;
  
  if not ValidateRange then
    Exit;

  //all ok
  result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgPrintScheduled.btnEmailMsgClick(Sender: TObject);
begin
   EditScheduledReportsMessage( 'E-Mail Message',
                                'Type a subject and a message which will be added to all E-Mails sent when Scheduled Reports are generated.',
                                EMailSubject,
                                EMailBody);
end;
//------------------------------------------------------------------------------

procedure TdlgPrintScheduled.btnListReportsDueClick(Sender: TObject);
//generate the list reports due report
const
   ThisMethodName = 'btnListReportsDueClick';
var
   ReportOptions     :TSchReportOptions;
   DT                : integer;
begin
  if not ( cbToPrinter.Checked  or
           cbToFax.Checked or
           cbToEMail.Checked or
           cbToECoding.Checked or
           cbCheckOut.Checked or
           cbOnline.Checked or
           cbToBusinessProducts.Checked or
           cbToWebX.Checked) then
  begin
    NothingToDoMsg;
    exit;
  end;

  // validate range
  if not ValidateRange then
    Exit;

   ReportOptions.srCodeSelection := TStringList.Create;
   try
     with ReportOptions do
     begin
        //Get User settings
        if rbRange.Checked then
        begin
          srFromCode := edtFromCode.Text;
          srToCode   := edtToCode.Text;
        end
        else
        begin
          srFromCode := '';
          srToCode   := '';
        end;
        if rbSelection.Checked then
          srCodeSelection.Assign(CodeSelectionList)
        else
          srCodeSelection.Clear;
        if not DownloadedDataAvailable then
        begin
          HelpfulErrorMsg( sNoTransactions, 0);
          Exit;
        end;
        //use the report up to combo to get a valid date
        DT := Integer( rcbReportsEnding.Items.Objects[ rcbReportsEnding.ItemIndex ] );
        //Store selected Print Reports Up To Date
        if LoadAdminSystem(true, ThisMethodName ) then
        begin
          with AdminSystem.fdFields do
          begin
            // Set Print Reports Up to Date
            fdPrint_Reports_Up_To := StNull2BK( DT );
            fdPrint_Reports_From := 0;
            fdSched_Rep_Include_Printer      := cbToPrinter.Checked;
            fdSched_Rep_Include_Email        := cbToEMail.Checked;
            fdSched_Rep_Include_Fax          := cbToFax.Checked;
            fdSched_Rep_Include_ECoding      := cbToECoding.Checked;
            fdSched_Rep_Include_CSV_Export   := false;
            fdSched_Rep_Include_CheckOut     := cbCheckOut.Checked;
            fdSched_Rep_Include_Online       := cbOnline.Checked;
            fdSched_Rep_Include_Business_Products := cbToBusinessProducts.Checked;
            fdSort_Reports_By := GetSortByValue;
            
            if rbSelectAll.Checked then
              fdSort_Reports_Option := srslAll
            else if rbRange.Checked then
              fdSort_Reports_Option := srslRange
            else // selection
              fdSort_Reports_Option := srslSelection;
            fdSched_Rep_Include_WebX         := cbToWebX.Checked;
          end; //with
          SaveAdminSystem;
         end
         else
         begin
           HelpfulErrorMsg('Unable to update Admin Settings.  Cannot Print report.',0);
           exit;
         end;
        srPrintAll := rbAll.Checked;
        //never update last printed date during List Reports Due report
        srUpdateAdmin    := false;
        srUserLRN        := 0;
        srSummaryInfoList:= nil;
     end;

     DisableForm;
     CreateReportImagelist;
     try
       //call the report directly, does not go thru scheduled reports

       DoScheduledReport(REPORT_WHATSDUE, rdAsk, ReportOptions);
     finally
       EnableForm;
       BringToFront;
       DestroyReportImagelist;
     end;
   finally
     FreeAndNil(ReportOptions.srCodeSelection);
   end;
end;
//------------------------------------------------------------------------------
function TdlgPrintScheduled.GetSortByValue: integer;
begin
  if rbStaffMember.Checked then
    Result := srsoStaffMember
  else if rbGroup.Checked then
    Result := srsoGroup
  else if rbClientType.Checked then
    Result := srsoClientType
  else
    Result := srsoClientCode; //default
end;

function TdlgPrintScheduled.ValidateRange: boolean;
var
  ItemName: string;
begin
  // validate range
  if rbRange.Checked and (edtFromCode.Text > edtToCode.Text) and (Trim(edtToCode.Text) <> '') then
  begin
    if rbClient.Checked then
      ItemName := 'Client Code'
    else if rbStaffMember.Checked then
      ItemName := 'Staff Code'
    else if rbGroup.Checked then
      ItemName := 'Group Name'
    else if rbClientType.Checked then
      ItemName := 'Client Type Name'
    else
      ItemName := 'Code';
    HelpfulErrorMsg(Format('You have chosen to use a Range, but the FROM %s is greater than the TO %s. Please select a valid range.', [ItemName, ItemName]), 0);
    Result := false;
  end
  else
    Result := true;
end;


function GetScheduleOptions( var ReportOptions :TSchReportOptions; var btn : integer)  :boolean;
const
   ThisMethodName = 'GetScheduleOptions';
var
  myDlg : TdlgPrintScheduled;
  d1, d2,
  m1, m2,
  y1, y2 : integer;
  i     : integer;

  CurrIndex : integer;

  DT    : tStDate;
  S     : string;

  function GetCDGuid(Value: TComboBox): string;
  begin
    if Value.ItemIndex <> -1 then
       Result :=  TReportBase(Value.Items.Objects[Value.ItemIndex]).GetGUID
    else
       Result := '';
  end;

begin
  result := false;
  if not RefreshAdmin then exit;


  Reports.CheckDefaultFaxSettings;

  MyDlg := TdlgPrintScheduled.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Chapter_A8_Scheduled_reports);
    with MyDlg, AdminSystem.fdFields do begin     //load settings
      case fdSort_Reports_By of
        srsoStaffMember: rbStaffMember.Checked := true;
        srsoGroup: rbGroup.Checked := true;
        srsoClientType: rbClientType.Checked := true;
        else
          rbClient.Checked := true;
      end;

      if fdSort_Reports_Option = 0 then
        rbSelectAll.Checked := true
      else if fdSort_Reports_Option = 1 then
        rbRange.Checked := true
      else
        rbSelection.Checked := true;
      rbRangeClick(MyDlg);

      MyDlg.rbStaffMemberClick(nil); //make sure that correct values are displayed

      LoadPrinters;
      LoadCustomDocuments;

      chkStaffHeader.checked  := fdPrint_Staff_Member_Header_Page;
      chkClientHeader.Checked := fdPrint_Client_Header_Page;
      ckCDPrint.Checked := Boolean(fdSched_Rep_Print_Custom_Doc);
      cbCDPrint.ItemIndex :=
          cbCDPrint.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Print_Custom_Doc_GUID));

      ckCDFax.Checked := Boolean(fdSched_Rep_Fax_Custom_Doc);
      cbCDFax.ItemIndex :=
          cbCDFax.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Fax_Custom_Doc_GUID));

      ckCDEmail.Checked := Boolean(fdSched_Rep_Email_Custom_Doc);
      cbCDEmail.ItemIndex :=
          cbCDEmail.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Email_Custom_Doc_GUID));

      ckCDBooks.Checked := Boolean(fdSched_Rep_Books_Custom_Doc);
      cbCDBooks.ItemIndex :=
          cbCDBooks.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Books_Custom_Doc_GUID));

      ckCDOnline.Checked := Boolean(fdSched_Rep_Online_Custom_Doc);
      cbCDOnline.ItemIndex :=
          cbCDOnline.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Online_Custom_Doc_GUID));

      ckCDNotes.Checked := Boolean(fdSched_Rep_Notes_Custom_Doc);
      cbCDNotes.ItemIndex :=
          cbCDNotes.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_Notes_Custom_Doc_GUID));

      ckCDwebNotes.Checked := Boolean(fdSched_Rep_WebNotes_Custom_Doc);
      cbCDwebNotes.ItemIndex :=
          cbCDwebNotes.Items.IndexOfObject(CustomDocManager.GetReportByGUID(fdSched_Rep_WebNotes_Custom_Doc_GUID));

      chkGroupHeader.Checked  := fdPrint_Group_Header_Page;
      chkClientTypeHeader.Checked := fdPrint_Client_Type_Header_Page;

      cbToPrinter.Checked     := fdSched_Rep_Include_Printer;
      cbToEMail.Checked       := fdSched_Rep_Include_Email;
      cbToFax.Checked         := fdSched_Rep_Include_Fax;
      cbToECoding.Checked     := fdSched_Rep_Include_ECoding;
      cbToWebX.Checked        := fdSched_Rep_Include_WebX;
      cbCheckOut.Checked      := fdSched_Rep_Include_CheckOut;
      cbOnline.Checked        := fdSched_Rep_Include_Online;
      cbToBusinessProducts.Checked := fdSched_Rep_Include_Business_Products;

      if fdSched_Rep_Send_Fax_Off_Peak then begin
         rbSendOffPeak.checked := true;
         rbSendImmediate.Checked := false;
      end
      else begin
         rbSendImmediate.Checked := true;
         rbSendOffPeak.checked := false;
      end;

      if fdSched_Rep_Fax_Transport in [fxtMin..fxtMax] then
        cmbFaxTransport.ItemIndex := fdSched_Rep_Fax_Transport
      else
        cmbFaxTransport.ItemIndex := 0;

      //Case 10220 Remove WinFox Pro as an option unless already selected.
      if PRACINI_HideWinFaxPro AND (cmbFaxTransport.ItemIndex <> 2) then
        cmbFaxTransport.Items.Delete(2);

      edtCoverpageFilename.Text := fdSched_Rep_Cover_Page_Name;

      UpdateFaxOptionsUI;

      EmailSubject     := fdSched_Rep_Email_Subject;
      EmailBody        := fdSched_Rep_Email_Message;
      CoverPageSubject := fdSched_Rep_Cover_Page_Subject;
      CoverPageMessage := fdSched_Rep_Cover_Page_Message;
      HeaderMessage    := fdSched_Rep_Header_Message;
      BNotesSubject    := fdSched_Rep_BNotes_Subject;
      BNotesMessage    := fdSched_Rep_BNotes_Message;
      WebNotesSubject  := fdSched_Rep_WebNotes_Subject;
      WebNotesMessage  := fdSched_Rep_WebNotes_Message;
      CheckOutSubject  := fdSched_Rep_CheckOut_Subject;
      CheckOutMessage  := fdSched_Rep_CheckOut_Message;
      OnlineSubject    := fdSched_Rep_Online_Subject;
      OnlineMessage    := fdSched_Rep_Online_Message;

      BusinessProductSubject  := fdSched_Rep_Business_Products_Subject;
      BusinessProductMessage  := fdSched_Rep_Business_Products_Message;

      // load month end combo box
      rcbReportsEnding.Items.Clear;

      DownloadedDataAvailable :=  fdPrint_Reports_Up_To > 0;

      if DownloadedDataAvailable then
      begin
        // make sure fdPrint_Reports_UpTo is a month end date;
        if (fdHighest_Date_Ever_Downloaded = 0) then
        begin
          if (fdDate_of_Last_Entry_Received = 0) then
            StDatetoDMY( BKNull2St( fdPrint_Reports_Up_To ), d1, m1, y1 )
          else
            StDatetoDMY( BKNull2St( fdDate_of_Last_Entry_Received ), d1, m1, y1 );
        end
        else
          StDatetoDMY( BKNull2St( fdHighest_Date_Ever_Downloaded ), d1, m1, y1 );

        d1 := DaysInMonth( m1, y1, bkDateUtils.Epoch );
        fdPrint_Reports_Up_To := DMYToStDate( d1, m1, y1, bkDateUtils.Epoch );

        if fdHighest_Date_Ever_Downloaded = 0 then
          StDatetoDMY( BKNull2St( fdDate_of_Last_Entry_Received ), d1, m1, y1 )
        else
          StDateToDMY( fdHighest_Date_Ever_Downloaded, d1, m1, y1 );
        StDateToDMY( fdDate_of_Last_Entry_Received, d2, m2, y2 );
        CurrIndex := 0;
        For i := 0 to 11 do
        begin
           d1 := DaysInMonth( m1, y1, bkDateUtils.Epoch );
           DT := DMYToStDate( d1, m1, y1, bkDateUtils.Epoch );
           S  := Date2Str( DT, 'nnn yy' );
           rcbReportsEnding.Items.AddObject( S, Pointer( DT ) );

           // selection is based on last download, not highest
           d2 := DaysInMonth( m2, y2, bkDateUtils.Epoch );
           DT := DMYToStDate( d2, m2, y2, bkDateUtils.Epoch );
           if DT = fdPrint_Reports_Up_To then
              CurrIndex := i;
           { Move the month back }
           DecMY( m1, y1 );
           DecMY( m2, y2 );
        end;
        rcbReportsEnding.ItemIndex := CurrIndex;
      end;

      edtFromCode.text      := '';
      edtToCode.text        := '';
      edtSelection.Text     := '';
      btn                   := BTN_NONE;

      ShowModal;
    end;  //with

    if MyDlg.ButtonPressed in [ btn_preview, btn_print, btn_ok] then begin
       //save settings - update Admin
       if LoadAdminSystem(true, ThisMethodName ) then begin
          with AdminSystem.fdFields do begin
             fdSort_Reports_By                := MyDlg.GetSortByValue;
             fdPrint_Staff_Member_Header_Page := MyDlg.chkStaffHeader.checked;
             fdPrint_Client_Header_Page       := MyDlg.chkClientHeader.Checked;

             fdSched_Rep_Print_Custom_Doc   := Byte(MyDlg.ckCDPrint.Checked);
             fdSched_Rep_Print_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDPrint);

             fdSched_Rep_Fax_Custom_Doc   := Byte(MyDlg.ckCDFax.Checked);
             fdSched_Rep_Fax_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDFax);

             fdSched_Rep_Email_Custom_Doc   := Byte(MyDlg.ckCDEMail.Checked);
             fdSched_Rep_Email_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDEmail);

             fdSched_Rep_Books_Custom_Doc   := Byte(MyDlg.ckCDBooks.Checked);
             fdSched_Rep_Books_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDBooks);

             fdSched_Rep_Online_Custom_Doc   := Byte(MyDlg.ckCDOnline.Checked);
             fdSched_Rep_Online_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDOnline);

             fdSched_Rep_Notes_Custom_Doc   := Byte(MyDlg.ckCDNotes.Checked);
             fdSched_Rep_Notes_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDNotes);

             fdSched_Rep_WebNotes_Custom_Doc   := Byte(MyDlg.ckCDWebNotes.Checked);
             fdSched_Rep_WebNotes_Custom_Doc_GUID := GetCDGuid(MyDlg.cbCDWebNotes);

             fdPrint_Group_Header_Page        := MyDlg.chkGroupHeader.Checked;
             fdPrint_Client_Type_Header_Page  := MyDlg.chkClientTypeHeader.Checked;
             fdSched_Rep_Include_Printer      := MyDlg.cbToPrinter.Checked;
             fdSched_Rep_Include_Email        := MyDlg.cbToEMail.Checked;
             fdSched_Rep_Include_Fax          := MyDlg.cbToFax.Checked;
             fdSched_Rep_Include_ECoding      := MyDlg.cbToECoding.Checked;
             fdSched_Rep_Include_WebX         := MyDlg.cbToWebX.Checked;
             fdSched_Rep_Include_CSV_Export   := False;
             fdSched_Rep_Include_CheckOut     := MyDlg.cbCheckOut.Checked;
             fdSched_Rep_Include_Online       := MyDlg.cbOnline.Checked;
             fdSched_Rep_Include_Business_Products := MyDlg.cbToBusinessProducts.Checked;
             if MyDlg.rbSelectAll.Checked then             
               fdSort_Reports_Option := 0
             else if MyDlg.rbRange.Checked then
               fdSort_Reports_Option := 1
             else // selection
               fdSort_Reports_Option := 2;

             if MyDlg.ButtonPressed = btn_print then // record what was used
             begin
               if MyDlg.cbToPrinter.Checked then
                  IncUsage('Sched Rep - Printed');
               if MyDlg.cbToEMail.Checked then
                  IncUsage('Sched Rep - Emailed');
               if MyDlg.cbToFax.Checked then
                  IncUsage('Sched Rep - Faxed');
               if MyDlg.cbToECoding.Checked then
                  IncUsage('Sched Rep - Notes');
               if MyDlg.cbToWebX.Checked then
                  IncUsage('Sched Rep - Web');
               if MyDlg.cbCheckOut.Checked then
                  IncUsage('Sched Rep - Checked Out');
               if MyDlg.cbOnline.Checked then
                  IncUsage('Sched Rep - ' + BANKLINK_ONLINE_NAME);
             end;

             fdSched_Rep_Send_Fax_Off_Peak    := MyDlg.rbSendOffPeak.checked;
             fdSched_Rep_Cover_Page_Name      := MyDlg.edtCoverPageFilename.Text;

             fdSched_Rep_Email_Subject        := MyDlg.EmailSubject;
             fdSched_Rep_Email_Message        := MyDlg.EmailBody;
             fdSched_Rep_Cover_Page_Subject   := MyDlg.CoverPageSubject;
             fdSched_Rep_Cover_Page_Message   := MyDlg.CoverPageMessage;
             fdSched_Rep_Header_Message       := MyDlg.HeaderMessage;
             fdSched_Rep_BNotes_Subject       := MyDlg.BNotesSubject;
             fdSched_Rep_BNotes_Message       := MyDlg.BNotesMessage;
             fdSched_Rep_WebNotes_Subject     := MyDlg.WebNotesSubject;
             fdSched_Rep_WebNotes_Message     := MyDlg.webNotesMessage;
             fdSched_Rep_CheckOut_Subject     := MyDlg.CheckOutSubject;
             fdSched_Rep_CheckOut_Message     := MyDlg.CheckOutMessage;
             fdSched_Rep_Online_Subject       := MyDlg.OnlineSubject;
             fdSched_Rep_Online_Message       := MyDlg.OnlineMessage;
             fdSched_Rep_Business_Products_Subject     := MyDlg.BusinessProductSubject;
             fdSched_Rep_Business_Products_Message     := MyDlg.BusinessProductMessage;

             fdSched_Rep_Fax_Transport := myDlg.cmbFaxTransport.ItemIndex;

             // Set Print Reports Up to Date - Make sure date is end of month
             DT := Integer( MyDlg.rcbReportsEnding.Items.Objects[ MyDlg.rcbReportsEnding.ItemIndex ] );
             fdPrint_Reports_Up_To := StNull2BK( DT );
             fdPrint_Reports_From := 0;
          end; //with
          SaveAdminSystem;
       end
       else begin
          HelpfulErrorMsg('Unable to update Admin Settings.  Cannot Print reports.',0);
          exit;
       end;
       //store report options
       with MyDlg do begin
          btn := ButtonPressed;
          with ReportOptions do begin
             if rbRange.Checked then
             begin
               srFromCode := edtFromCode.Text;
               srToCode   := edtToCode.Text;
             end
             else
             begin
               srFromCode := '';
               srToCode   := '';
             end      ;
             if rbSelection.Checked then           
               srCodeSelection.Assign(CodeSelectionList)
             else
               srCodeSelection.Clear; //case 8265
             srPrintAll    := rbAll.Checked;
             srUpdateAdmin := true;
             srUserLRN        := 0;
             srSummaryInfoList:= nil;
          end;
       end;
       result := true;
    end;
  finally
    MyDlg.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnCoverPageMsgClick(Sender: TObject);
begin
   EditScheduledReportsMessage( 'Cover Page Message',
                                'The following subject and message will be ' +
                                'added to the cover pages of all faxed reports '+
                                'if a cover page has been selected.'#13#13,
                                CoverPageSubject,
                                CoverPageMessage);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnOpenDialogClick(Sender: TObject);
begin
   if cmbFaxTransport.ItemIndex = fxtWinFax then
   begin
     OpenDialog1.Filter := 'Winfax Pro cover pages (*.' + WinfaxCoverPageExtn + ')|*.' + WinfaxCoverPageExtn + '|All files (*.*)|*.*';
     OpenDialog1.DefaultExt := WinfaxCoverPageExtn;
   end
   else
   begin
     OpenDialog1.Filter := 'Windows cover pages (*.' + WindowsCoverPageExtn + ')|*.' + WindowsCoverPageExtn + '|All files (*.*)|*.*';
     OpenDialog1.DefaultExt := WindowsCoverPageExtn;
   end;

   if edtCoverPageFilename.Text = '' then
   begin
     if cmbFaxTransport.ItemIndex = fxtWinFax then
       OpenDialog1.InitialDir := Globals.DataDir
     else
       OpenDialog1.InitialDir := 'C:\Documents and Settings\All Users\Application Data\Microsoft\Windows NT\MSFax\Common Coverpages';
   end
   else
     OpenDialog1.InitialDir := ExtractFileDir(edtCoverpageFilename.Text);

   if OpenDialog1.Execute then
      edtCoverPageFilename.Text := OpenDialog1.FileName;

   //make sure all relative paths are relative to data dir after browse
   SysUtils.SetCurrentDir( Globals.DataDir);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnFaxCodingClick(Sender: TObject);
begin
  SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
  try
    SetupScheduledFax( REPORT_CODING);
  finally
    SavePrinter(FaxPrinter);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnFaxPayeesClick(Sender: TObject);
begin
  SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
  try
    SetupScheduledFax( REPORT_LIST_PAYEE);
  finally
    SavePrinter(FaxPrinter);
  end;
end;
procedure TdlgPrintScheduled.btnFromLookupClick(Sender: TObject);
begin
  if rbClient.Checked then
    DoClientLookup(edtFromCode, 'Select Client Code From Range', False)
  else if rbStaffMember.Checked then
    DoUserLookup(edtFromCode, 'Select Staff Member From Range', False)
  else if rbGroup.Checked then
    DoGroupLookup(edtFromCode, 'Select Group From Range', False)
  else if rbClientType.Checked then
    DoClientTypeLookup(edtFromCode, 'Select Client Type From Range', False);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnFaxChartClick(Sender: TObject);
begin
  SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
  try
    SetupScheduledFax( REPORT_LIST_CHART);
  finally
    SavePrinter(FaxPrinter);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgPrintScheduled.TestForWinFax: boolean;
var
  SDKSendObject : Variant;
begin
   result := true;
   try
      VarClear(SDKSendObject);
      SDKSendObject := CreateOleObject('WinFax.SDKSend8.0');
   except
      on E : Exception do begin
         result := false;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgPrintScheduled.btnHeaderMsgClick(Sender: TObject);
var
  HeaderSubject : String;
begin
  HeaderSubject := #$FF; //no header
  EditScheduledReportsMessage( 'Header Message',
                               'The following message will be ' +
                               'added to the header of all printed reports'#13#13,
                               HeaderSubject,
                               HeaderMessage);
end;

procedure TdlgPrintScheduled.btnBNotesMsgClick(Sender: TObject);
begin
  EditScheduledReportsMessage( glConst.ECODING_APP_NAME + ' Message',
                               'Type a subject and a message which will be added to all ' +
                               glConst.ECODING_APP_NAME + ' files sent when Scheduled Reports are generated.',
                               BNotesSubject,
                               BNotesMessage);

end;

procedure TdlgPrintScheduled.btnCheckOutMsgClick(Sender: TObject);
begin
  EditScheduledReportsMessage( 'BankLink Books Message',
                               'Type a subject and a message which will be added to all ' +
                               'BankLink Books files sent when Scheduled Reports are generated.',
                               CheckOutSubject,
                               CheckOutMessage)
end;

procedure TdlgPrintScheduled.NothingToDoMsg;
var
  msg: string;
begin
  msg := 'You have not specified one of the following options :'+#13#10 +
    'Include Printed Reports, Include Faxed Reports, Send E-Mailed Reports,' +
    ' Send ' + glConst.ECODING_APP_NAME + ' Files, Send Checked Out Files';

  if cbToWebX.Visible then
    msg := msg + ', Send ' + glConst.WEBX_GENERIC_APP_NAME + ' Files';

  HelpfulInfoMsg(msg, 0);
end;

procedure TdlgPrintScheduled.DisableForm;
begin
  PageControl1.Enabled := False;
  btnPreview.Enabled := False;
  btnPrint.Enabled := False;
  btnOK.Enabled := False;
  btnCancel.Enabled := False;
  Self.Enabled := False;
end;

procedure TdlgPrintScheduled.EnableForm;
begin
  btnCancel.Enabled := True;
  btnOK.Enabled := True;
  btnPrint.Enabled := True;
  btnPreview.Enabled := True;
  PageControl1.Enabled := True;
  Self.Enabled := True;  
end;

procedure TdlgPrintScheduled.cmbFaxTransportChange(Sender: TObject);
begin
  UpdateFaxOptionsUI(True);
end;

procedure TdlgPrintScheduled.UpdateFaxOptionsUI(Toggle: Boolean = False);
var
  ft : byte;
  TransportAvailable : boolean;
begin
  ft := cmbFaxTransport.ItemIndex;

  case ft of
    fxtWinFax : begin
      pnlOffpeak.Visible := true;
      edtCoverpageFilename.enabled := true;
      cmbPrinter.Visible := true;
      btnTestFax.Enabled := true;
      TransportAvailable := TestForWinFax;
      // If current transport is selected then choose the current fax printer
      if AdminSystem.fdFields.fdSched_Rep_Fax_Transport = fxtWinFax then
      begin
        if Toggle then
          SelectPrinter('WinFax', FaxPrinter)
        else
          SelectPrinter(FaxPrinter, 'WinFax');
      end
      else // Otherwise use 'WinFax' as default
        SelectPrinter('WinFax', 'WinFax');
    end;
    fxtWindowsFaxService : begin
      pnlOffpeak.Visible := false;
      edtCoverpageFilename.enabled := true;
      cmbPrinter.Visible := true;
      btnTestFax.Enabled := true;
      TransportAvailable := TestForWindowsFaxService;
      if AdminSystem.fdFields.fdSched_Rep_Fax_Transport = fxtWindowsFaxService then
      begin
        if Toggle then
          SelectPrinter('Fax', FaxPrinter)
        else
          SelectPrinter(FaxPrinter, 'Fax');
      end
      else
        SelectPrinter('Fax', 'Fax');
    end;
  else
    begin
      pnlOffpeak.Visible := false;
      edtCoverpageFilename.enabled := false;
      cmbPrinter.Visible := false;
      TransportAvailable := false;
      btnTestFax.Enabled := false;      
    end;
  end;

  //set availablity of the generate to fax box
  if not TransportAvailable then
  begin
    cbToFax.Checked := false;
    cbToFax.Enabled := false;
  end
  else
    cbToFax.Enabled := true;
end;

{function TdlgPrintScheduled.TestForWindowsFaxServiceViaCOM: boolean;
var
  FaxServer : TFaxServer;
begin
  result := false;
  if IsWin9x then
    exit;

  //see if can connect to a fax server
  FaxServer := TFaxServer.Create( Application);
  try
    try
      FaxServer.Connect1(''); //null = default fax server
      FaxServer.Disconnect;
      result := true;
    except
      On E : Exception do
      begin
        result := false;
        exit;
      end;
    end;
  finally
    FaxServer.Free;
  end;
end;
}
procedure TdlgPrintScheduled.btnTestFaxClick(Sender: TObject);
var
  DummyOptions : TSchReportOptions;
  s : string;
  Recip : string;
  FaxNo : string;
  ExistingTx: Byte;
begin
  s := GetFaxSetupMsg( cmbFaxTransport.ItemIndex);
  if s <> '' then
    HelpfulErrorMsg( s, 0)
  else
  begin
    if GetFaxDetails( Recip, faxNo) then
    begin
      DisableForm;
      try
        DummyOptions.srTestFaxRecip := Recip;
        DummyOptions.srTestFaxNumber := FaxNo;
        DummyOptions.srTestCoverpageFilename := edtCoverpageFilename.Text;
        // We don't save the saved fax transport until OK is clicked
        // So if doing a test fax we need to temporarily set it while we generate the report
        // Same for printer
        ExistingTx := AdminSystem.fdFields.fdSched_Rep_Fax_Transport;
        AdminSystem.fdFields.fdSched_Rep_Fax_Transport := cmbFaxTransport.ItemIndex;
        SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
        try
          //now reload the fax printer settings
          Globals.FaxPrintSettings := TPrintManagerObj.Create;
          try
            FaxPrintSettings.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;
            FaxPrintSettings.Open;

            if Reports.DoScheduledFax( REPORT_TEST_FAX, rdFax, DummyOptions) then
              HelpfulInfoMsg( 'Fax created successfully' ,0)
            else
              HelpfulErrorMsg('Could not create test fax. See log for details.', 0);
          finally
            Globals.FaxPrintSettings.Free;
            Globals.FaxPrintSettings := nil;
          end;
        finally
          AdminSystem.fdFields.fdSched_Rep_Fax_Transport := ExistingTx;
          SavePrinter(FaxPrinter);
        end;
      finally
        EnableForm;
      end;
    end;
  end;
end;

procedure TdlgPrintScheduled.btnToLookupClick(Sender: TObject);
begin
  if rbClient.Checked then  
    DoClientLookup(edtToCode, 'Select Client Code To Range', False)
  else if rbStaffMember.Checked then
    DoUserLookup(edtToCode, 'Select Staff Member To Range', False)
  else if rbGroup.Checked then
    DoGroupLookup(edtToCode, 'Select Group To Range', False)
  else if rbClientType.Checked then
    DoClientTypeLookup(edtToCode, 'Select Client Type To Range', False);
end;

procedure TdlgPrintScheduled.Button1Click(Sender: TObject);
begin
  SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
  try
    SetupScheduledFax( REPORT_TEST_FAX);
  finally
    SavePrinter(FaxPrinter);
  end;
end;

procedure TdlgPrintScheduled.btnJobsClick(Sender: TObject);
begin
  SetupScheduledReport(REPORT_LIST_JOBS);
end;

procedure TdlgPrintScheduled.btnFaxJobsClick(Sender: TObject);
begin
  SavePrinter(cmbPrinter.Items[cmbPrinter.ItemIndex]);
  try
    SetupScheduledFax( REPORT_LIST_JOBS);
  finally
    SavePrinter(FaxPrinter);
  end;
end;

procedure TdlgPrintScheduled.btnWebNotesMsgClick(Sender: TObject);
begin
    EditScheduledReportsMessage( Format ('%s Message', [bkconst.WebNotesName] ),
       Format ('Type a subject and a message which will be added to all %s notifications sent when Scheduled Reports are generated.',[bkconst.WebNotesName]),
                               webNotesSubject,
                               WebNotesMessage);
end;

function TdlgPrintScheduled.TestForWindowsFaxService: boolean;
begin
  result := ( not IsWin9x) and (DLLFound( 'Winfax.dll'));
end;

// Populate the printers combo and select the current fax printer
procedure TdlgPrintScheduled.LoadPrinters;
var
  Job: TBKReport;
  FaxSchedulePRS: TPrintManagerObj;
  i: Integer;
  PrinterOK: Boolean;
begin
  Printer.Refresh;
  FaxSchedulePRS := TPrintManagerObj.Create;
  try
    FaxSchedulePRS.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;
    FaxSchedulePRS.Open;
    Job := TBKReport.Create(ReportTypes.rptOther);
    try
      Job.LoadReportSettings(FaxSchedulePRS,Report_List_Names[REPORT_CODING]);
      cmbPrinter.Items.Clear;
      for i := 0 to Pred(Printer.Printers.Count) do
        cmbPrinter.Items.Add(GetPrinterName(i));
      if AdminSystem.fdFields.fdSched_Rep_Fax_Transport = fxtWinFax then
        PrinterOK := SelectPrinter(Job.UserReportSettings.s7Printer_Name, 'WinFax')
      else if AdminSystem.fdFields.fdSched_Rep_Fax_Transport = fxtWindowsFaxService then
        PrinterOK := SelectPrinter(Job.UserReportSettings.s7Printer_Name, 'Fax')
      else
        PrinterOK := SelectPrinter(Job.UserReportSettings.s7Printer_Name, '');
      if (not PrinterOK) and (AdminSystem.fdFields.fdSched_Rep_Fax_Transport <> fxtNone) then
        HelpfulInfoMsg('The Fax Printer selected for use in Scheduled Reports is not available from this computer.'#13#13 +
          'A default Fax Printer has been selected.', 0);
      // Remember the fax printer that was originally selected
      FaxPrinter := Job.UserReportSettings.s7Printer_Name;
    finally
      Job.Free;
    end;
    FaxSchedulePRS.Save;
  finally
    FaxSchedulePRS.Free;
  end;
end;

// Set the report options to the current selected fax printer
procedure TdlgPrintScheduled.SetPrinterForJob(PRS: TPrintManagerObj; Job: TBKReport;
  PName: string; ReportIdx: REPORT_LIST_TYPE);
begin
    Job.LoadReportSettings(PRS,Report_List_Names[ReportIdx]);
    Job.UserReportSettings.s7Printer_Name := PName;
    Job.UserReportSettings.s7Is_Default := false;
    Job.SaveReportSettings;
end;

// Save the Fax printer setting
procedure TdlgPrintScheduled.SavePrinter(PName: string);
var
  Job: TBKReport;
  FaxSchedulePRS: TPrintManagerObj;
begin
  FaxSchedulePRS := TPrintManagerObj.Create;
  try
    FaxSchedulePRS.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;
    Job := TBKReport.Create(ReportTypes.rptOther);
    try
      // All reports use the same fax printer
      SetPrinterForJob(FaxSchedulePRS, Job, PName, REPORT_CODING);
      SetPrinterForJob(FaxSchedulePRS, Job, PName, REPORT_LIST_PAYEE);
      SetPrinterForJob(FaxSchedulePRS, Job, PName, REPORT_LIST_JOBS);
      SetPrinterForJob(FaxSchedulePRS, Job, PName, REPORT_LIST_CHART);
      SetPrinterForJob(FaxSchedulePRS, Job, PName, REPORT_TEST_FAX);
      SetPrinterForJob(FaxSchedulePRS, Job, PName, Report_Custom_Document);
    finally
      Job.Free;
    end;
    FaxSchedulePRS.Save;
  finally
    FaxSchedulePRS.Free;
  end;
end;

// Select a specified printer in the printers combo
function TdlgPrintScheduled.SelectPrinter(PName: string; PNameDefault: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  // If no printers then dont crash!
  if not AreThereAnyPrinters then exit;
  i := cmbPrinter.Items.IndexOf(PName);
  // Select existing fax printer if its there
  if i > -1 then
    cmbPrinter.ItemIndex := i
  else
  begin
    if PName <> '' then // Chosen fax printer has gone!
      Result := False;
    i := cmbPrinter.Items.IndexOf(PNameDefault);
    // Choose an appropriate default
    if i > -1 then
      cmbPrinter.ItemIndex := i
    else // Use windows default printer
    begin
      Printer.PrinterIndex := -1;
      cmbPrinter.ItemIndex := Printer.PrinterIndex;
    end;
  end;
end;

procedure TdlgPrintScheduled.btnBusinessProductsMsgClick(Sender: TObject);
begin
  EditScheduledReportsMessage( 'Business Products Message',
                               'Type a subject and a message which will be added to all ' +
                               'Business Product files sent when Scheduled Reports are generated.',
                               BusinessProductSubject,
                               BusinessProductMessage);
end;

procedure TdlgPrintScheduled.LoadCustomDocuments;
var
  i: integer;
  CustomDoc: TReportBase;
begin
  cbCDPrint.Clear;
  cbCDFax.Clear;
  cbCDEmail.Clear;
  cbCDBooks.Clear;
  cbCDOnline.Clear;
  cbCDNotes.Clear;
  cbCDWebNotes.Clear;
  for i := 0 to Pred(CustomDocManager.ReportList.Count) do begin
     CustomDoc := TReportBase(CustomDocManager.ReportList.Items[i]);
     cbCDPrint.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDFax.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDEmail.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDBooks.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDOnline.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDNotes.Items.AddObject(CustomDoc.Name, CustomDoc);
     cbCDWebNotes.Items.AddObject(CustomDoc.Name, CustomDoc);
  end;
end;

procedure TdlgPrintScheduled.LoadLookupBitmaps;
begin
    if rbClient.Checked then
    begin
      btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
      btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
      btnSelect.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
    end
    else if rbStaffMember.Checked then
    begin
      btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
      btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
      btnSelect.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
    end
    else if rbGroup.Checked then
    begin
      btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
      btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
      btnSelect.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
    end
    else if rbClientType.Checked then
    begin
      btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
      btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
      btnSelect.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
    end;
end;

procedure TdlgPrintScheduled.DoClientLookup(edt: TEdit; Op: string; Multiple: Boolean);
var
  CodeList : TStringList;
  I: Integer;
begin
  CodeList := TStringList.Create;
  try
    CodeList.Delimiter :=  ClientCodeDelimiter;
    CodeList.StrictDelimiter := true;
    for i := 0 to CodeSelectionList.Count - 1 do
      CodeList.Add(CodeSelectionList[i]);
    CodeList.DelimitedText := SelectCodeToLookup( Op, CodeList.DelimitedText, Multiple);
    CodeSelectionList.Clear;
    edt.Text := '';
    if Multiple then
    begin
      for I := 0 to Pred(CodeList.Count) do
      begin
        if edt.Text <> '' then
          edt.Text := edt.Text + ',';
        edt.Text := edt.Text + CodeList[i];
        CodeSelectionList.Add(CodeList[i]);
      end;
    end
    else if CodeList.Count > 0 then
      edt.Text := CodeList[0];
  finally
    CodeList.Free;
  end;
end;

procedure TdlgPrintScheduled.DoClientTypeLookup(edt: TEdit; Op: string;
  Multiple: Boolean);
var
  Selection: String;
begin
  if DoLookup(ltClientType, Op, Multiple, edt.Text, Selection) then
    edt.Text := Selection;
end;

procedure TdlgPrintScheduled.DoUserLookup(edt: TEdit; Op: string; Multiple: Boolean);
var
  Selection: String;
begin
  if DoLookup(ltUser, Op, Multiple, edt.Text, Selection) then
    edt.Text := Selection;
end;

procedure TdlgPrintScheduled.DoGroupLookup(edt: TEdit; Op: string; Multiple: Boolean);
var
  Selection: String;
begin
  if DoLookup(ltGroup, Op, Multiple, edt.Text, Selection) then
    edt.Text := Selection;
end;

function TdlgPrintScheduled.DoLookup(LookupType: TLookupOption; Caption: string; Multiple: Boolean; AlreadySelectedText: string; var Selection: string): boolean;
var
  dlgSelectList : TdlgSelectList;
  NewItem       : TListItem;
  i             : integer;
  StoredIndex   : integer;
  User          : pUser_Rec;
  UserList      : TSystem_User_List;
  GroupList     : tSystem_Group_List;
  Group         : pGroup_Rec;
  ClientTypeList: TSystem_Client_Type_List;
  ClientType    : pClient_Type_Rec;
  Item          : TListItem;
  ItemName      : string;
begin
  StoredIndex := -1;
  dlgSelectList := TdlgSelectList.Create( Application);
  try
    //set up the dialog
    dlgSelectList.Caption := Caption;
    dlgSelectList.lvList.Columns.Clear;
    dlgSelectList.lvList.Columns.Add;
    //Groups, 1 column
    //Client Types, 1 column
    //Users, 2 columns
    if (LookupType = ltUser) then
      dlgSelectList.lvList.Columns.Add;
    dlgSelectList.lvList.Clear;
    dlgSelectList.lvList.MultiSelect := Multiple;
    //Do this based on Lookup Type
    case LookupType of
      ltUser:
        begin
          UserList := AdminSystem.fdSystem_User_List;
          for i := 0 to Pred(UserList.itemCount) do
          begin
            User := UserList.User_At(i);
            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := User^.usCode;
            NewItem.SubItems.Add(User^.usName);
            NewItem.ImageIndex := -1;
            if (User^.usCode = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := CodeSelectionList.IndexOf(User^.usCode) > -1;
          end;
        end;
      ltGroup:
        begin
          //load admin group with full names
          GroupList := AdminSystem.fdSystem_Group_List;
          for i := 0 to Pred(GroupList.itemCount) do
          begin
            Group := GroupList.Group_At(i);

            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := Group^.grName;
            NewItem.ImageIndex := -1;

            if (Group^.grName = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := CodeSelectionList.IndexOf(Group^.grName) > -1;
          end;
        end;
      ltClientType:
        begin
          ClientTypeList := AdminSystem.fdSystem_Client_Type_List;
          //load admin group with full names
          for i := 0 to Pred(ClientTypeList.itemCount) do
          begin
            ClientType := ClientTypeList.Client_Type_At(i);

            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := ClientType^.ctName;
            NewItem.ImageIndex := -1;

            if (ClientType^.ctName = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := CodeSelectionList.IndexOf(ClientType^.ctName) > -1;
          end;
        end;
    end;
    NewItem := dlgSelectList.lvList.Items.Add;
    if LookupType = ltUser then
    begin
      NewItem.Caption := ' ';
      NewItem.SubItems.Add('Not Allocated');
    end
    else
    begin
      NewItem.Caption := 'Not Allocated';
    end;

    NewItem.ImageIndex := -1;
    NewItem.Selected := CodeSelectionList.IndexOf(' ') > -1;
    case LookupType of
      ltUser:
        begin
          dlgSelectList.lvList.Column[0].Width := 100;
          dlgSelectList.lvList.Column[1].Width := dlgSelectList.lvList.ClientWidth - 100;
          dlgSelectList.lvList.Column[0].Caption := 'Staff Code';
          dlgSelectList.lvList.Column[1].Caption := 'Staff Member';
        end;
      ltGroup:
        begin
          dlgSelectList.lvList.Column[0].Width := dlgSelectList.lvList.ClientWidth;
          dlgSelectList.lvList.Column[0].Caption := 'Group Name';
        end;
      ltClientType:
        begin
          dlgSelectList.lvList.Column[0].Width := dlgSelectList.lvList.ClientWidth;
          dlgSelectList.lvList.Column[0].Caption := 'Client Type Name';
        end;
    end;


    if StoredIndex <> - 1 then
      dlgSelectList.lvList.ItemIndex := StoredIndex;
    if (dlgSelectList.ShowModal = mrOK) then
    begin
      CodeSelectionList.Clear;
      Selection := '';
      if Multiple then
      begin
        for i := 0 to Pred(dlgSelectList.lvList.Items.Count) do
        begin
          Item := dlgSelectList.lvList.Items[i];
          ItemName := Item.Caption;
          if ItemName = 'Not Allocated' then
            ItemName := ' ';
          
          if Item.Selected then
          begin
            CodeSelectionList.Add(ItemName);
            if Selection <> '' then
              Selection := Selection + ',';
            Selection := Selection + ItemName;
          end;
        end;
      end
      else if dlgSelectList.lvList.SelCount > 0 then
      begin
        NewItem := dlgSelectList.lvList.Selected;
        ItemName := NewItem.Caption;
        if ItemName = 'Not Allocated' then
          ItemName := ' ';
        Selection := ItemName;
      end;
      Result := true;
    end
    else
      Result := false;
  finally
    dlgSelectList.Free;
  end;
end;

procedure TdlgPrintScheduled.edtSelectionExit(Sender: TObject);
begin
  // update list if user manually typed a selection
  if CodeSelectionList.CommaText <> edtSelection.Text then
    CodeSelectionList.CommaText := edtSelection.Text;
end;

end.


