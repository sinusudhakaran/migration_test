unit AuditReportOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ReportDefs, ComCtrls, AuditMgr, DateSelectorFme,
  OSFont, ClientSelectFme, SYDEFS, ExtCtrls;

type
  TAuditReportType = (artSystem, artClient, artExchangeRates);
  TAuditSelection = (byAll, byClient, byTransactionType, byTransactionID);

  TAuditReportOptions = class(TObject)
  private
    FDateTo: integer;
    FDateFrom: integer;
    FDestination: TReportDest;
    FAuditReportType: TAuditReportType;
    FTransactionID: integer;
    FTransactionType: Byte;
    FAuditSelection: TAuditSelection;
    FClientCode: string;
    FIncludeChild: Boolean;
    procedure SetDateFrom(const Value: integer);
    procedure SetDateTo(const Value: integer);
    procedure SetDestination(const Value: TReportDest);
    procedure SetAuditReportType(const Value: TAuditReportType);
    procedure SetTransactionID(const Value: integer);
    procedure SetTransactionType(const Value: Byte);
    procedure SetAuditSelection(const Value: TAuditSelection);
    procedure SetIncludeChild(const Value: Boolean);
  public
    function AuditRecordInSelection(AAuditRecord: TAudit_Trail_Rec): Boolean;
    property ClientCode: string read FClientCode;
    property DateFrom : integer read FDateFrom write SetDateFrom;
    property DateTo   : integer read FDateTo write SetDateTo;
    property Destination: TReportDest read FDestination write SetDestination;
    property AuditReportType: TAuditReportType read FAuditReportType write SetAuditReportType;
    property TransactionType: Byte read FTransactionType write SetTransactionType;
    property TransactionID: integer read FTransactionID write SetTransactionID;
    property AuditSelection: TAuditSelection read FAuditSelection write SetAuditSelection;
    property IncludeChild: Boolean read FIncludeChild write SetIncludeChild;
  end;

  TfrmAuditReportOption = class(TForm)
    pnlSelectClient: TPanel;
    GroupBox6: TGroupBox;
    rbSystem: TRadioButton;
    rbClient: TRadioButton;
    cbClientFileCodes: TComboBox;
    pnlSelectDate: TPanel;
    gbxReportPeriod: TGroupBox;
    DateSelector: TfmeDateSelector;
    pnlSelectTransaction: TPanel;
    GroupBox1: TGroupBox;
    rbSystemTransactionType: TRadioButton;
    rbSystemTransactionID: TRadioButton;
    cbTransactionType: TComboBox;
    eTransactionID: TEdit;
    cbIncludeChildren: TCheckBox;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnPrint: TButton;
    btnFile: TButton;
    btnPreview: TButton;
    rbExchangeRates: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbSystemTransactionTypeClick(Sender: TObject);
    procedure rbSystemTransactionIdClick(Sender: TObject);
    procedure TransactionRBSelected;
    procedure btnCancelClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure eTransactionIDKeyPress(Sender: TObject; var Key: Char);
    procedure rbSystemClick(Sender: TObject);
  private
    { Private declarations }
    FBtnPressed : integer;
    function Validate: Boolean;
    procedure LoadAuditTypes(AAuditReportType: TAuditReportType);
    procedure LoadClientFileCodes;
  public
    { Public declarations }
  end;

  function GetAuditReportOptions(var AuditReportOptions: TAuditReportOptions): boolean;

implementation

uses
  Globals,
  bkXPThemes,
  WarningMoreFrm,
  Files,
  BKHelp;

{$R *.dfm}

function GetAuditReportOptions(var AuditReportOptions: TAuditReportOptions): boolean;
var
  frmAuditReportOption: TfrmAuditReportOption;
  Margin: integer;
begin
  Result := False;
  frmAuditReportOption := TfrmAuditReportOption.Create(Application.MainForm);
  try
    BKHelpSetUp(frmAuditReportOption, BKH_Audit_Report);
    with frmAuditReportOption do begin
      Caption := 'Audit Report';
      pnlSelectClient.Visible := True;
      Margin :=  frmAuditReportOption.Left + frmAuditReportOption.Margins.Left + gbxReportPeriod.Left;
      Width := Margin + gbxReportPeriod.Width + Margin;
      Height := (Height - ClientHeight) + pnlButtons.Top +
                pnlButtons.Height + Margin;

      //Set audit report options
      DateSelector.eDateFrom.AsStDate := AuditReportOptions.DateFrom;
      DateSelector.eDateTo.AsStDate := AuditReportOptions.DateTo;
      case AuditReportOptions.AuditReportType of
        artSystem: rbSystem.Checked := True;
        artClient: rbClient.Checked := True;
        artExchangeRates: rbExchangeRates.Checked := True;
      end;
      cbClientFileCodes.ItemIndex := cbClientFileCodes.Items.IndexOf(AuditReportOptions.ClientCode);
      rbSystemClick(frmAuditReportOption);
      rbSystemTransactionTypeClick(frmAuditReportOption);

      ShowModal;
      if FBtnPressed in [BTN_PREVIEW, BTN_PRINT, BTN_FILE] then begin
          with AuditReportOptions do begin
            //Set report type
            if rbSystem.Checked then
              AuditReportType := artSystem
            else if rbExchangeRates.Checked then
              AuditReportType := artExchangeRates
            else if rbClient.Checked then
              AuditReportType := artClient;

            DateFrom  := DateSelector.eDateFrom.AsStDate;
            DateTo    := DateSelector.eDateTo.AsStDate;
            AuditReportOptions.AuditSelection := byTransactionType;
            AuditReportOptions.TransactionType := byte(cbTransactionType.Items.Objects[cbTransactionType.ItemIndex]);
            if rbSystemTransactionID.Checked then
              AuditReportOptions.AuditSelection := byTransactionID;

            if cbTransactionType.ItemIndex > 0 then
              AuditReportOptions.TransactionType := TAuditType(cbTransactionType.Items.Objects[cbTransactionType.ItemIndex]);
            if eTransactionID.Text <> '' then
              AuditReportOptions.TransactionID := StrToInt(eTransactionID.Text);

            if AuditReportOptions.AuditReportType = artClient then begin
              AuditReportOptions.FClientCode := cbClientFileCodes.Items[cbClientFileCodes.ItemIndex];
            end;
            IncludeChild := cbIncludeChildren.Checked;

            case FBtnPressed of
              BTN_PREVIEW :  Destination := rdScreen;
              BTN_PRINT   :  Destination := rdPrinter;
              BTN_FILE    :  Destination := rdFile;
            else
              Destination := rdNone;
            end;
          end;
          Result := True;
      end;
    end;
  finally
    frmAuditReportOption.Free;
  end;
end;

{ TfrmAuditReportOption }

procedure TfrmAuditReportOption.btnFileClick(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_FILE;
  Close;
end;

procedure TfrmAuditReportOption.btnPreviewClick(Sender: TObject);
begin
  if not Validate then
     Exit;
  FBtnPressed := BTN_PREVIEW;
  Close;
end;

procedure TfrmAuditReportOption.btnCancelClick(Sender: TObject);
begin
  FBtnPressed := BTN_NONE;
end;

procedure TfrmAuditReportOption.eTransactionIDKeyPress(Sender: TObject; var Key: Char);
begin
  // #8 is Backspace
  if not (Key in [#8, '0'..'9']) then begin
    // Discard the key
    Key := #0;
  end;
end;

procedure TfrmAuditReportOption.FormCreate(Sender: TObject);
var
  i: integer;
begin
  bkXPThemes.ThemeForm( Self);

  LoadClientFileCodes;

  //set date bounds
  DateSelector.InitDateSelect( MinValidDate, MaxValidDate, btnPreview);
  DateSelector.eDateFrom.asStDate := -1;
  DateSelector.eDateTo.asStDate   := -1;
  DateSelector.Last2Months1.Visible := False;
  DateSelector.btnQuik.Visible := true;
end;

procedure TfrmAuditReportOption.FormShow(Sender: TObject);
begin
  if DateSelector.eDateFrom.CanFocus then
    DateSelector.eDateFrom.SetFocus;
  rbSystemClick(Self);
end;

procedure TfrmAuditReportOption.LoadAuditTypes(AAuditReportType: TAuditReportType);
var
  i: integer;
begin
  //Load audit types
  cbTransactionType.Clear;
  cbTransactionType.Items.AddObject('<All>', TObject(arAll));
  case AAuditReportType of
    artSystem: for i := arMin to arMax do
                if SystemAuditMgr.AuditTypeToDBStr(i) = 'SY' then
                  cbTransactionType.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
    artClient: for i := arMin to arMax do
                if SystemAuditMgr.AuditTypeToDBStr(i) = 'BK' then
                  cbTransactionType.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
    artExchangeRates: for i := arMin to arMax do
                if SystemAuditMgr.AuditTypeToDBStr(i) = 'MC' then
                  cbTransactionType.Items.AddObject(SystemAuditMgr.AuditTypeToStr(i), TObject(i));
  end;
  cbTransactionType.ItemIndex := 0;
end;

procedure TfrmAuditReportOption.LoadClientFileCodes;
var
  i: integer;
begin
  cbClientFileCodes.Clear;
  if Assigned(AdminSystem) then
    for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
      cbClientFileCodes.Items.Add(AdminSystem.fdSystem_Client_File_List.Client_File_At(i).cfFile_Code);
  if cbClientFileCodes.Items.Count > 0 then
    cbClientFileCodes.ItemIndex := 0; 
end;

procedure TfrmAuditReportOption.rbSystemClick(Sender: TObject);
begin
  cbClientFileCodes.Enabled := rbClient.Checked;
  //Load audit types
  if rbClient.Checked then
    LoadAuditTypes(artClient)
  else if rbExchangeRates.Checked then
    LoadAuditTypes(artExchangeRates)
  else
    LoadAuditTypes(artSystem)
end;

procedure TfrmAuditReportOption.rbSystemTransactionIdClick(Sender: TObject);
begin
  TransactionRBSelected;
  if Self.Visible then
    eTransactionID.SetFocus;
end;

procedure TfrmAuditReportOption.rbSystemTransactionTypeClick(Sender: TObject);
begin
  TransactionRBSelected;
  if Self.Visible then
    cbTransactionType.SetFocus;
end;

procedure TfrmAuditReportOption.TransactionRBSelected;
begin
  cbTransactionType.Enabled := rbSystemTransactionType.Checked;
  eTransactionID.Enabled := rbSystemTransactionID.Checked;
end;

function TfrmAuditReportOption.Validate: Boolean;
begin
  Result := False;

  //Dates
  if not DateSelector.ValidateDates(true) then
    Exit;

  //Client File
  if rbClient.Checked then begin
    if (cbClientFileCodes.ItemIndex = -1) then begin
      HelpfulWarningMsg('Please select a client file.', 0);
      if cbClientFileCodes.CanFocus then
        cbClientFileCodes.SetFocus;
      Exit;
    end else if not ClientFileExists(cbClientFileCodes.Items[cbClientFileCodes.ItemIndex]) then begin
      HelpfulWarningMsg('The client file does not exist.', 0);
      if cbClientFileCodes.CanFocus then
        cbClientFileCodes.SetFocus;
      Exit;
    end;
  end;

  Result := True;
end;

{ TAuditReportOptions }

function TAuditReportOptions.AuditRecordInSelection(
  AAuditRecord: TAudit_Trail_Rec): Boolean;
begin
  Result := False;
end;

procedure TAuditReportOptions.SetAuditReportType(const Value: TAuditReportType);
begin
  FAuditReportType := Value;
end;

procedure TAuditReportOptions.SetAuditSelection(const Value: TAuditSelection);
begin
  FAuditSelection := Value;
end;

procedure TAuditReportOptions.SetDateFrom(const Value: integer);
begin
  FDateFrom := Value;
end;

procedure TAuditReportOptions.SetDateTo(const Value: integer);
begin
  FDateTo := Value;
end;

procedure TAuditReportOptions.SetDestination(const Value: TReportDest);
begin
  FDestination := Value;
end;

procedure TAuditReportOptions.SetIncludeChild(const Value: Boolean);
begin
  FIncludeChild := Value;
end;

procedure TAuditReportOptions.SetTransactionID(const Value: integer);
begin
  FTransactionID := Value;
end;

procedure TAuditReportOptions.SetTransactionType(const Value: Byte);
begin
  FTransactionType := Value;
end;

end.
