unit FrequencyRequestFrm;
//------------------------------------------------------------------------------
//  Title:   Data Frequency Change Request Form
//
//  Written: Apr 2010
//
//  Authors: Scott Wilson
//
//  Description: Allows the user to request a change to the data supply
//               frequency for system bank accounts. An email is created
//               from the info supplied in this dialog and sent to BankLink
//               for processing.
//
//               The frequency can only be changed if:
//                 - The current frequency <> unspecified
//                 - The account is not marked as deleted
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, OsFont, SYDEFS;

type
  TfrmFrequencyRequest = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    gbDaily: TGroupBox;
    gbWeekly: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblInstitutionListLink: TLabel;
    memoDaily: TMemo;
    memoWeekly: TMemo;
    pBottom: TPanel;
    pnlDaily: TPanel;
    pnlMonthly: TPanel;
    pnlWeekly: TPanel;
    rbDayToMonth: TRadioButton;
    rbDayToWeek: TRadioButton;
    rbWeekToDay: TRadioButton;
    rbWeekToMonth: TRadioButton;
    pnlNotify: TPanel;
    cbNotifyEmail: TCheckBox;
    gbMonthly: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    rbMonthToWeek: TRadioButton;
    rbMonthToDay: TRadioButton;
    memoMonthly: TMemo;
    Label7: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblInstitutionListLinkClick(Sender: TObject);
    procedure lblInstitutionListLinkMouseEnter(Sender: TObject);
    procedure lblInstitutionListLinkMouseLeave(Sender: TObject);
    procedure rbDailyClick(Sender: TObject);
  private
    FBankAccounts: TStringList;
    FWebSite: string;
    FPanelCount: integer;
    function GetBankAccount(index: integer): string;
    function GetBankAccountCount: integer;
    function GetHasDaily: boolean;
    function GetHasMonthly: boolean;
    function GetHasWeekly: boolean;
    function Validate: Boolean;
    procedure FillMemo(ACurrentFrequency: byte; var AMemo: TMemo);
    procedure SetWebSite(const Value: string);
    procedure ArrangeRequestPanels;
  public
    function GetBodyText(AClientCode: string): string;
    procedure AddBankAccount(ABankAccount: PSystem_Bank_Account_Rec);
    property BankAccountCount: integer read GetBankAccountCount;
    property BankAccounts[index: integer]: string read GetBankAccount;
    property HasDaily: boolean read GetHasDaily;
    property HasMonthly: boolean read GetHasMonthly;
    property HasWeekly: boolean read GetHasWeekly;
    property WebSite: string read FWebSite write SetWebSite;
  end;

const
  FREQUENCY_CHANGE_REQUEST = 'Frequency Change Request';
  LF = #13;
  RULE_LINE = '----------------------------------------' +
              '----------------------------------------' + LF;

implementation

uses
  ShellAPI, bkconst, ErrorMoreFrm, bkHelp;

const
  FIXED_LINES = 0;

{$R *.dfm}

procedure TfrmFrequencyRequest.AddBankAccount(ABankAccount: PSystem_Bank_Account_Rec);
begin
  if ABankAccount.sbFrequency in [difMonthly, difWeekly, difDaily] then begin
    FBankAccounts.AddObject(Format('%s%s%s', [ABankAccount^.sbAccount_Number, #9,
                                              ABankAccount^.sbAccount_Name]),
                            Pointer(ABankAccount^.sbFrequency));
  end;
end;

procedure TfrmFrequencyRequest.ArrangeRequestPanels;
var
  PanelHeight: integer;
begin
  //Email notification checkbox
  pnlNotify.Visible := HasMonthly or HasWeekly;
  //Height
  if pnlNotify.Visible then
    PanelHeight := (ClientHeight - (pBottom.Height + pnlNotify.Height))
  else
    PanelHeight := (ClientHeight - pBottom.Height);
  if FPanelCount > 1 then
    PanelHeight := (PanelHeight div FPanelCount);
  pnlMonthly.Height := PanelHeight;
  pnlWeekly.Height := PanelHeight;
  pnlDaily.Height := PanelHeight;
  //Align
  if pnlMonthly.Visible and (pnlWeekly.Visible or pnlDaily.Visible) then begin
    pnlMonthly.Align := alTop;
    if pnlWeekly.Visible then begin
      if pnlWeekly.Visible and pnlDaily.Visible then begin
        pnlWeekly.Align := altop;
        pnlDaily.Align := alClient;
      end else
        pnlWeekly.Align := alClient;
    end else
      pnlDaily.Align := alClient;
  end else if pnlWeekly.Visible and pnlDaily.Visible then begin
    pnlWeekly.Align := altop;
    pnlDaily.Align := alClient;
  end else if pnlWeekly.Visible then
    pnlWeekly.Align := alClient
  else if pnlDaily.visible then
    pnlDaily.Align := alClient
  else if pnlMonthly.Visible then
    pnlMonthly.Align := alClient;
end;

procedure TfrmFrequencyRequest.btnOKClick(Sender: TObject);
begin
  if Validate then
    ModalResult := mrOK;
end;

procedure TfrmFrequencyRequest.FillMemo(ACurrentFrequency: byte; var AMemo: TMemo);
var
  i, lFreq: integer;
begin
  AMemo.Lines.clear;

  for i := 0 to FBankAccounts.Count - 1 do begin
    lFreq := Integer(FBankAccounts.Objects[i]);
    if lFreq = ACurrentFrequency then
      AMemo.Lines.Add(FBankAccounts[i]);
  end;

  case ACurrentFrequency of
    difMonthly: rbMonthToDay.Checked := True;
    difWeekly : rbWeekToDay.Checked := True;
    difDaily  : rbDayToMonth.Checked := True;
  end;
end;

procedure TfrmFrequencyRequest.FormCreate(Sender: TObject);
begin
  FPanelCount := 0 ;

  FBankAccounts := TStringList.Create;
  FBankAccounts.NameValueSeparator := #9;

  Label2.Font.Style := [fsBold];
  Label3.Font.Style := [fsBold];
  Label1.Font.Style := [fsBold];
  gbMonthly.Font.Style := [fsBold];
  gbDaily.Font.Style := [fsBold];

  OSFont.SetHyperlinkFont(lblInstitutionListLink.Font);
  lblInstitutionListLink.Font.Style := [];

  BKHelpSetUp(Self, BKH_Sending_a_frequency_change_request_from_BankLink_Practice);
end;

procedure TfrmFrequencyRequest.FormDestroy(Sender: TObject);
begin
  FBankAccounts.Free;
end;

procedure TfrmFrequencyRequest.FormShow(Sender: TObject);
begin
  //Fill memos
  FBankAccounts.Sort;
  FillMemo(difMonthly, memoMonthly);
  FillMemo(difWeekly, memoWeekly);
  FillMemo(difDaily, memoDaily);

  //Visible
  pnlMonthly.Visible := HasMonthly;
  pnlWeekly.Visible := HasWeekly;
  pnlDaily.Visible := HasDaily;
  FPanelCount := 0;
  if pnlMonthly.Visible then Inc(FPanelCount);
  if pnlWeekly.Visible then Inc(FPanelCount);
  if pnlDaily.Visible then Inc(FPanelCount);

  if FPanelCount = 0 then begin
    ModalResult := mrCancel;
    Close;
  end;

  //Arrange panels
  ArrangeRequestPanels;
end;

function TfrmFrequencyRequest.GetBankAccount(
  index: integer): string;
begin
  Result := FbankAccounts.Names[Index];
end;

function TfrmFrequencyRequest.GetBankAccountCount: integer;
begin
  Result := FBankAccounts.Count;
end;

function TfrmFrequencyRequest.GetBodyText(AClientCode: string): string;
const
  DAILY_DATA_NOTIFY = 'Notify practice by email when Daily Data is available';
var
  Frequency, DateStr: string;
begin
  Result := '';
  //Date
  DateTimeToString(DateStr, 'dd mmm yyyy', Now);
  Result := Format('%s%s%s', [DateStr, LF, LF]);
  //Title
  Result := Format('%s%s %s%s', [Result,
                                 AClientCode,
                                 FREQUENCY_CHANGE_REQUEST, LF]);
  //Email notification note
  if cbNotifyEmail.Checked then
    Result := Format('%s%s%sNOTE: %s%s%s',
                     [Result, LF, RULE_LINE, DAILY_DATA_NOTIFY, LF, RULE_LINE]);

  //Monthly
  if HasMonthly then begin
    Frequency := difFrequencyNames[difDaily];
    if rbMonthToWeek.Checked then
      Frequency := difFrequencyNames[difWeekly];
    //Title
    Result := Format('%s%s%sMonthly to %s%s%s',
                     [Result, LF, LF, Frequency, LF,
                      RULE_LINE]);
    //Accounts
    Result := Format('%s%s%s',
                     [Result,
                      memoMonthly.Lines.Text, RULE_LINE]);
  end;

  //Weekly
  if HasWeekly then begin
    Frequency := difFrequencyNames[difDaily];
    if rbWeekToMonth.Checked then
      Frequency := difFrequencyNames[difMonthly];
    //Title
    Result := Format('%s%s%sWeekly to %s%s%s',
                     [Result, LF, LF, Frequency, LF,
                      RULE_LINE]);
    //Accounts
    Result := Format('%s%s%s',
                     [Result,
                      memoWeekly.Lines.Text, RULE_LINE]);
  end;

  //Daily
  if HasDaily then begin
    Frequency := difFrequencyNames[difMonthly];
    if rbDayToWeek.Checked then
      Frequency := difFrequencyNames[difWeekly];
    Result := Format('%s%s%sDaily to %s%s%s%s%s',
                     [Result, LF, LF, Frequency, LF, RULE_LINE,
                      memoDaily.Lines.Text,
                      RULE_LINE]);
  end;
  //Extra lines
  Result := Result + LF + LF;
end;

function TfrmFrequencyRequest.GetHasDaily: boolean;
begin
  Result := (memoDaily.Lines.Count > 0);
end;

function TfrmFrequencyRequest.GetHasMonthly: boolean;
begin
  Result := (memoMonthly.Lines.Count > 0);
end;

function TfrmFrequencyRequest.GetHasWeekly: boolean;
begin
  Result := (memoWeekly.Lines.Count > 0); 
end;

procedure TfrmFrequencyRequest.lblInstitutionListLinkClick(Sender: TObject);
const
  INSTITUTIONS_PAGE = '/about_institutions.html';
var
  Link: string;
  ReturnVal: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    Link := Format('%s%s', [WebSite, INSTITUTIONS_PAGE]);
    ReturnVal := ShellExecute(0, PChar('open'), PChar(Link), nil, nil, SW_SHOW);
    if ReturnVal < 32 then
      HelpfulErrorMsg('Could not open the following link: ' + Link, 0);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmFrequencyRequest.lblInstitutionListLinkMouseEnter(Sender: TObject);
begin
  lblInstitutionListLink.Font.Style := [fsUnderline];
end;

procedure TfrmFrequencyRequest.lblInstitutionListLinkMouseLeave(Sender: TObject);
begin
  lblInstitutionListLink.Font.Style := [];
end;

procedure TfrmFrequencyRequest.rbDailyClick(Sender: TObject);
begin
  cbNotifyEmail.Enabled := (HasMonthly and rbMonthToDay.Checked) or
                                (HasWeekly and rbWeekToDay.Checked);
  if not cbNotifyEmail.Enabled then
    cbNotifyEmail.Checked := False;
end;

procedure TfrmFrequencyRequest.SetWebSite(const Value: string);
begin
  FWebSite := Value;
end;

function TfrmFrequencyRequest.Validate: Boolean;
begin
  Result := True;
end;

end.
