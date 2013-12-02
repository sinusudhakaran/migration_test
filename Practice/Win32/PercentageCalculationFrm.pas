unit PercentageCalculationFrm;

interface

uses
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
    procedure FormShow(Sender: TObject);
  private
    function CheckAccountCodeValidity: boolean;
    { Private declarations }
  public
    pubAccountCode: string;
    pubPercentage: double;
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
begin
  ValidAccountCode := CheckAccountCodeValidity;
  ErrorStrings := TStringList.Create;
  if not ValidAccountCode then
    ErrorStrings.Add('Account code is invalid')
  else if (Trim(edtAccountCode.Text) = '') and (Trim(nPercent.Text) <> '0.00') then
    ErrorStrings.Add('Please enter an Account Code');
  if (Trim(edtAccountCode.Text) <> '') and (Trim(nPercent.Text) = '0.00') then
    ErrorStrings.Add('Please enter a Percentage figure')
  else
  begin
    pubAccountCode := Trim(edtAccountCode.Text);
    pubPercentage := StrToFloat(Trim(nPercent.Text));
    ModalResult := mrOK;
  end;

  if (ErrorStrings.Count > 0) then
  begin
    ShowMessage(ErrorStrings.Text);
    ModalResult := mrNone;
  end;
end;

function TfrmPercentageCalculation.CheckAccountCodeValidity: boolean;
var
  s: string;
  IsValid: boolean;
  pAcct: pAccount_Rec;
begin
  // Check validity of account code
  s       := Trim(edtAccountCode.Text);
  if (s = '') then
    Result := True // blank account codes do not count as 'invalid' for our purposes
  else
  begin
    pAcct   := MyClient.clChart.FindCode( S);
    IsValid := Assigned(pAcct) and pAcct.chPosting_Allowed;
    if IsValid or (s = '') then
      edtAccountCode.Color := clWindow
    else
      edtAccountCode.Color := clRed;
    Result := IsValid;
  end;
end;

procedure TfrmPercentageCalculation.edtAccountCodeChange(Sender: TObject);
begin
  CheckAccountCodeValidity;
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

procedure TfrmPercentageCalculation.FormShow(Sender: TObject);
begin
  pubAccountCode := '';
  pubPercentage := 0;
end;

procedure TfrmPercentageCalculation.nPercentKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = '-' then
    key := #0;
end;

end.
