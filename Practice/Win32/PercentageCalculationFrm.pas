unit PercentageCalculationFrm;

interface

uses
  BKConst,
  Buttons,
  Classes,
  Controls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  ImagesFrm,
  Messages,
  ovcbase,
  ovcef,
  ovcnf,
  ovcpb,
  StdCtrls,
  SysUtils,
  Variants,
  Windows;

type
  TfrmPercentageCalculation = class(TForm)
    edtAccountCode: TEdit;
    lblAccountCode: TLabel;
    lblPercentage: TLabel;
    lblPercent: TLabel;
    btnClear: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnChart: TBitBtn;
    nPercent: TOvcNumericField;
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure nPercentKeyPress(Sender: TObject; var Key: Char);
    procedure btnChartClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtAccountCodeChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    fCurrentRow: BK5CodeStr;
    function CheckAccountCodeValidity(var ErrorMsg: string): boolean;
    procedure SetCurrentRow(Value: BK5CodeStr);
    { Private declarations }
  public
    Property CurrentRow: BK5CodeStr read fCurrentRow write SetCurrentRow;
  end;

var
  frmPercentageCalculation: TfrmPercentageCalculation;

implementation

{$R *.dfm}

uses
  AccountLookupFrm,
  BKDefs,
  Globals;

procedure TfrmPercentageCalculation.btnChartClick(Sender: TObject);
var
  s: string;
begin
  s := edtAccountCode.Text;
  if PickAccount(s) then
    edtAccountCode.Text := s;
  edtAccountCode.Refresh;
end;

procedure TfrmPercentageCalculation.btnClearClick(Sender: TObject);
begin
  edtAccountCode.Text := '';
  nPercent.AsFloat := 0;
end;

procedure TfrmPercentageCalculation.btnOKClick(Sender: TObject);
var
  ValidAccountCode: boolean;
  ErrorStrings: TStringList;
  ErrorMsg: string;
begin
  ErrorMsg := '';
  ValidAccountCode := CheckAccountCodeValidity(ErrorMsg);
  ErrorStrings := TStringList.Create;
  if not ValidAccountCode then
    ErrorStrings.Add(ErrorMsg)
  else if (Trim(edtAccountCode.Text) = '') and (Trim(nPercent.Text) <> '0.00') then
    ErrorStrings.Add('Please enter an Account Code');
  if (Trim(edtAccountCode.Text) <> '') and (Trim(nPercent.Text) = '0.00') then
    ErrorStrings.Add('Please enter a Percentage figure')
  else
    ModalResult := mrOK;

  if (ErrorStrings.Count > 0) then
  begin
    ShowMessage(ErrorStrings.Text);
    ModalResult := mrNone;
  end;
end;

function CheckCodesMatch(Code1, Code2: BK5CodeStr): boolean;
begin
  Result := (Code1 = Code2);
end;

function TfrmPercentageCalculation.CheckAccountCodeValidity(var ErrorMsg: string): boolean;
var
  CodesMatch  : boolean;
  IsValid     : boolean;
  pAcct       : pAccount_Rec;
  s           : string;
begin
  // Check validity of account code
  s       := Trim(edtAccountCode.Text);
  if (s = '') then
    Result := True // blank account codes do not count as 'invalid' for our purposes
  else
  begin
    pAcct   := MyClient.clChart.FindCode( S);
    CodesMatch := CheckCodesMatch(CurrentRow, s);

    if not Assigned(pAcct) then
    begin
      IsValid := False;
      ErrorMsg := 'The code you have picked is not in the Chart of Accounts';
    end else
    if CodesMatch then
    begin
      IsValid   := False;
      ErrorMsg  := 'Please pick a row other than the current row';
    end else
    if not pAcct.chPosting_Allowed then
    begin
      IsValid   := False;
      ErrorMsg  := 'You cannot pick a non-posting code';
    end else
      IsValid := True;

    if IsValid or (s = '') then
      edtAccountCode.Color := clWindow
    else
      edtAccountCode.Color := clRed;
    Result := IsValid;
  end;
end;

procedure TfrmPercentageCalculation.edtAccountCodeChange(Sender: TObject);
var
  DummyStr: string; // won't actually need this string
begin
  CheckAccountCodeValidity(DummyStr);
end;

procedure TfrmPercentageCalculation.FormCreate(Sender: TObject);
begin
  // imgAccountCode.Picture := ImagesFrm.AppImages.Coding.GetBitmap()
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);
end;

procedure TfrmPercentageCalculation.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    btnCancel.Click;
  if (Key = VK_F2) then
    btnChart.Click;  
end;

procedure TfrmPercentageCalculation.nPercentKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = '-' then
    key := #0;
end;

procedure TfrmPercentageCalculation.SetCurrentRow(Value: BK5CodeStr);
begin
  fCurrentRow := Value;
end;

end.
