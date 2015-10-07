unit OutDepositDlg;
//------------------------------------------------------------------------------
{
   Title:       OutStandingDepositDlg

   Description: Dialog for adding outstanding deposits

   Remarks:     Unlike the Add UPC and Add Initial dialogs the actually adding
                of the UPD is performs by dialog rather than in OUTSTAND.PAS

   Author:

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcPF, OvcBase, OvcEF, OvcPB, OvcNF, baobj32, Buttons, OvcABtn,
  OSFont, ExtCtrls;

type
  TUPType = (utDeposit, utWithdrawal);

  TdlgDeposit = class(TForm)
    lblDate: TLabel;
    Label2: TLabel;
    OvcController1: TOvcController;
    eAmount: TOvcNumericField;
    eDate: TOvcPictureField;
    lblType: TLabel;
    Label4: TLabel;
    lblPeriod: TLabel;
    eReference: TEdit;
    lblUPDPrefix: TLabel;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ShapeBorder: TShape;

    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure eDateError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure FormCreate(Sender: TObject);
    procedure eAmountKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
    okPressed : boolean;
    FFromDate,
    FToDate   : integer;
    FType: Byte;
    FIsInitial: Boolean;
    function OKtoPost : boolean;
    procedure SetupHelp;
  public
    { Public declarations }
    function Execute( BA : tBank_Account; FromDate, ToDate : LongInt; UType: Byte; IsInitial: Boolean = False ): Boolean;
  end;

//******************************************************************************
implementation

uses
  ovcDate,
  bkDateUtils,
  BKHelp,
  bkXPThemes,
  infoMoreFrm,
  quikDate,
  globals,
  bkdefs,
  bktxio,
  bkconst,
  ForexHelpers,
  warningMoreFrm,
  GenUtils, YesNoDlg;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  lblPeriod.Font.Style := [fsBold];
  eDate.Epoch          := BKDATEEPOCH;
  eDate.PictureMask    := BKDATEFORMAT;
  FType := upUPD;
  FIsInitial := False;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.SetupHelp;
var
  S: string;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   if FTYpe = upUPW then
      S := 'Withdrawal'
   else
      S := 'Deposit';
   //Components
   eDate.Hint       :=
                    'Enter the Effective Date for the Unpresented ' + S + ', normally the last day of the month|'+
                    'Enter the Effective Date for the Unpresented ' + S + ', this is normally the last day of the month';
   eAmount.Hint     :=
                    'Enter the amount of the Unpresented ' + S + '|'+
                    'Enter the amount of the Unpresented ' + S;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.btnOKClick(Sender: TObject);
begin
  if OKtoPost then
  begin
    okPressed := true;
    Close;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDlgDeposit.OKtoPost: boolean;
var
  S: string;
begin
  result := false;
  if FType = upUPW then
    S := 'withdrawal'
  else
    S := 'deposit';
  if Double2Money(eAmount.AsFloat) = 0 then
  begin
    HelpfulInfoMsg('The ' + S + ' amount cannot be zero',0);
    eAmount.SetFocus;
    exit;
  end;

  if (not FIsInitial) and ((StNull2Bk(eDate.asStDate) < FFromDate) or ( StNull2Bk(eDate.asStDate) > FToDate)) then
  begin
    HelpfulInfoMsg('The ' + S + ' date must be in the current coding period',0);
    eDate.SetFocus;
    exit;
  end;
  result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.eDateError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
  HelpfulWarningMsg('Invalid Date Entered',0);
  Edate.AsString := '';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgDeposit.Execute( BA : tBank_Account; FromDate, ToDate : LongInt; UType: Byte; IsInitial: Boolean = False ): Boolean;
var
   Transaction : pTransaction_Rec;
begin
  result            := false;
  okPRessed         := false;
  FFromDate         := FromDate;
  FToDate           := ToDate;
  eDate.AsStDate    := BkNull2St(ToDate);
  lblPeriod.caption := bkDate2Str(FromDate) + ' - ' + bkDate2Str(ToDate);

  if BA.IsAForexAccount then
    label2.Caption := '&Amount in ' + BA.baFields.baCurrency_Code;
    
  FType := UType;
  Assert( UType in [ upUPW, upUPD ] );

  FIsInitial := IsInitial;
  if IsInitial then
  begin
    if FromDate - 1 < MinValidDate then
      FromDate := FromDate + 1;
    if FType = upUPW then
      lblPeriod.Caption := 'Withdrawals will be dated ' + bkDate2Str(FromDate - 1)
    else
      lblPeriod.Caption := 'Deposits will be dated ' + bkDate2Str(FromDate - 1);
    eDate.AsStDate := FromDate - 1;
    eDate.Visible := False;
    lblDate.Visible := False;
  end;
  SetupHelp;
  lblUPDPrefix.caption := BKCONST.upNames[ FType];
  if FType = upUPW then
  begin
    if IsInitial then
    begin
      BKHelpSetUp(Self, BKH_Adding_initial_unpresented_withdrawals);
      Caption := 'Add Initial Withdrawals';
      lblType.Caption := 'Enter the withdrawal details.';
    end
    else
    begin
      BKHelpSetUp(Self, BKH_Adding_unpresented_withdrawals);
      Caption := 'Add Unpresented Withdrawals';
      lblType.Caption := 'Enter the withdrawal details.  The withdrawal must be dated.';
    end;
  end
  else
  begin
    BKHelpSetUp(Self, BKH_Adding_initial_unpresented_deposits);
    if IsInitial then
    begin
      Caption := 'Add Initial Deposits';
      lblType.Caption := 'Enter the deposit details.';
    end
    else
    begin
      BKHelpSetUp(Self, BKH_Adding_unpresented_deposits);
      Caption := 'Add Unpresented Deposits';
      lblType.Caption := 'Enter the deposit details.  The deposit must be dated.';
    end;
  end;
  //---------------------
  ShowModal;
  //---------------------
  if OKPressed then begin
    if FIsInitial then
    begin
      if FType = upUPW then
      begin
        if AskYesNo('Add Initial Withdrawals', 'An unpresented withdrawal will be added to the prior period.'#13 +
              #13'Please confirm that you want to do this.', DLG_NO, 0) = DLG_NO then
          exit;
      end
      else
      begin
        if AskYesNo('Add Initial Deposits', 'An unpresented deposit will be added to the prior period.'#13 +
              #13'Please confirm that you want to do this.', DLG_NO, 0) = DLG_NO then
          exit;
      end;
    end;
    {post data}
    with BA do begin
       Transaction := baTransaction_List.Setup_New_Transaction;
       with Transaction^ do
       begin
          If FType = upUPW then
            txType := BKConst.whWithdrawalEntryType[ MyClient.clFields.clCountry ]
          else
            txType := BKConst.whDepositEntryType[ MyClient.clFields.clCountry ];
          txSource                := orGenerated;
          txDate_Effective        := StNull2Bk(eDate.AsStDate );
          txReference             := eReference.Text;
          txBank_Seq              := baFields.baNumber;
          txUPI_State             := FType;
          txSF_Member_Account_ID  := -1;
          txSF_Fund_ID            := -1;

          if FType = upUPW then
            txAmount := Abs( GenUtils.Double2Money(eAmount.AsFloat))
          else
            txAmount := -1 * Abs( GenUtils.Double2Money(eAmount.AsFloat));

       end;
       baTransaction_List.Insert_Transaction_Rec(transaction);
    end;
    result := okPressed;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDeposit.eAmountKeyPress(Sender: TObject; var Key: Char);
begin
   //swallow minus key
   if Key = '-' then Key := #0;
end;

end.
