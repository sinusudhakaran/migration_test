unit EditSageHandisoftSuperFieldsDlg;

{ Note: fields are mapped onto existing superfund fields as follows:
  Type                              SF_Transaction_ID
  Transaction                       SF_Transaction_Code
  Nuber Issued                      Quantity
  Franked:                          SF_Franked
  Unfranked:                        SF_Unfranked
  Imputation Credit:                SF_Imputed_Credits
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxSpinEdit, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, ovcbase, ovcef, ovcpb, ovcnf, Buttons, StdCtrls,
  ExtCtrls, bkConst, bkDefs, MoneyDef, OSFont, SageHandisoftSuperConst,
  cxLookAndFeels, cxLookAndFeelPainters;

type
  TdlgEditSageHandisoftSuperFields = class(TForm)
    Panel1: TPanel;
    Label10: TLabel;
    lblDate: TLabel;
    lblAmount: TLabel;
    lbAmountlbl: TLabel;
    Label12: TLabel;
    lblNarration: TLabel;
    pnlFooters: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnClear: TButton;
    btnBack: TBitBtn;
    btnNext: TBitBtn;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblNumberIssued: TLabel;
    lblUnfrankedAmount: TLabel;
    lblFrankedAmount: TLabel;
    lblFrankingCredit: TLabel;
    btnCalc: TSpeedButton;
    nfImputedCredit: TOvcNumericField;
    nfFranked: TOvcNumericField;
    nfUnfranked: TOvcNumericField;
    cxComboBox1: TcxComboBox;
    cxComboBox2: TcxComboBox;
    nfNumberIssued: TOvcNumericField;
    lp1: TLabel;
    lp2: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cxComboBox1PropertiesChange(Sender: TObject);
    procedure nfFrankedChange(Sender: TObject);
    procedure nfUnfrankedChange(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnNextClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure nfUnfrankedKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FReadOnly: boolean;
    FTranAmount, FActualAmount: Double;
    FMoveDirection: TFundNavigation;
    FTop, FLeft, FSkip: Integer;
    Glyph: TBitMap;
    FDate: Integer;
    crModified: Boolean;
    UFModified: Boolean;
    FFrankPercentage: boolean;
    function ValidForm: boolean;
    function ListedCompanyDividend: boolean;
    procedure LoadTypes;
    procedure SetupHelp;
    procedure SetMoveDirection(const Value: TFundNavigation);
    procedure SetReadOnly(const Value: boolean);
    procedure SetFrankPercentage(const Value: boolean);
  public
    { Public declarations }
    function GetFields(var AType: integer; var ATransaction: string; var ANumberIssued,
                       AFrankedAmount, AUnfrankedAmount, AFrankingCredit: Money): Boolean;
    procedure SetInfo( iDate : integer; sNarration: string; mAmount : Money);
    procedure SetFields(AType: integer; ATransaction: string; ANumberIssued,
                        AFrankedAmount, AUnfrankedAmount, AFrankingCredit: Money);
    property MoveDirection : TFundNavigation read FMoveDirection write SetMoveDirection;
    property FormTop: Integer read FTop write FTop;
    property FormLeft: Integer read FLeft write FLeft;
    property ReadOnly : boolean read FReadOnly write SetReadOnly;
    property FrankPercentage: boolean read FFrankPercentage write SetFrankPercentage;
  end;

var
  dlgEditSageHandisoftSuperFields: TdlgEditSageHandisoftSuperFields;

implementation

uses
  bkHelp,
  Globals, bkXPThemes, ImagesFrm, bkDateUtils, GenUtils, SuperFieldsUtils,
  WarningMoreFrm;

{$R *.dfm}

function ValueIsValid( aNFControl : TOvcNumericField; s: string) : boolean;
begin
  Result := aNFControl.AsFloat >= 0;
  if not Result then
  begin
    HelpfulWarningMsg( S + ' cannot be negative.', 0);
    aNFControl.SetFocus;
  end;
end;

procedure TdlgEditSageHandisoftSuperFields.btnBackClick(Sender: TObject);
begin
  FMoveDirection := fnGoBack;
  ModalResult := mrOk;
end;

procedure TdlgEditSageHandisoftSuperFields.btnCalcClick(Sender: TObject);
var
  Frank: Double;
begin
  if FFrankPercentage then
    Frank := 0
  else
    Frank := nfFranked.asFloat;
  crModified := CheckFrankingCredit(Frank, fDate, nfImputedCredit,
                                    not((Sender = nfImputedCredit) or crModified));
end;

procedure TdlgEditSageHandisoftSuperFields.btnClearClick(Sender: TObject);
begin
  cxComboBox1.ItemIndex := -1;
  cxComboBox2.ItemIndex := -1;  
  nfNumberIssued.AsInteger := 0;
  nfImputedCredit.AsFloat := 0;
  nfFranked.AsFloat := 0;
  nfUnfranked.AsFloat := 0;
end;

procedure TdlgEditSageHandisoftSuperFields.btnNextClick(Sender: TObject);
begin
  FMoveDirection := fnGoForward;
  ModalResult := mrOk;
end;

procedure TdlgEditSageHandisoftSuperFields.cxComboBox1PropertiesChange(
  Sender: TObject);
var
  i: integer;
begin
  cxComboBox2.Properties.Items.Clear;
  cxComboBox2.ItemIndex := -1;
  case TTxnTypes(cxComboBox1.ItemIndex) of
    ttGeneralExpenses:
      for i := 0 to Integer(High(TGeneralExpenses)) do
        cxComboBox2.Properties.Items.Add(GeneralExpensesArray[TGeneralExpenses(i)]);
    ttIncome:
      for i := 0 to Integer(High(TIncome)) do
        cxComboBox2.Properties.Items.Add(IncomeArray[TIncome(i)]);
    ttExpenses:
      for i := 0 to Integer(High(TExpenses)) do
        cxComboBox2.Properties.Items.Add(ExpensesArray[TExpenses(i)]);
    ttPurchases:
      for i := 0 to Integer(High(TPurchases)) do
        cxComboBox2.Properties.Items.Add(PurchasesArray[TPurchases(i)]);
    ttDisposal:
      for i := 0 to Integer(High(TDisposals)) do
        cxComboBox2.Properties.Items.Add(DisposalsArray[TDisposals(i)]);
    ttTransfer:
      for i := 0 to Integer(High(TTransfers)) do
        cxComboBox2.Properties.Items.Add(TransfersArray[TTransfers(i)]);
  end;
end;

procedure TdlgEditSageHandisoftSuperFields.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if FReadOnly and (FMoveDirection = fnNothing) then
    ModalResult := mrCancel;

  if (ModalResult = mrOK) and (not ValidForm) then
    CanClose := False;
end;

procedure TdlgEditSageHandisoftSuperFields.FormCreate(Sender: TObject);
begin
  ThemeForm( Self);
  SetupHelp;
  Self.KeyPreview := True;
  FReadOnly := false;
  FMoveDirection := fnNothing;
  UFModified := False;
  FormTop := -999;
  FormLeft := -999;
  FSkip := 0;
  Glyph := TBitMap.Create;
  ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
  LoadTypes;
end;

procedure TdlgEditSageHandisoftSuperFields.FormDestroy(Sender: TObject);
begin
  Glyph.Free;
end;

procedure TdlgEditSageHandisoftSuperFields.FormShow(Sender: TObject);
begin
  if FTop > -999 then
  begin
    Top := FTop;
    Left := FLeft;
  end;
end;

function TdlgEditSageHandisoftSuperFields.GetFields(var AType: integer;
  var ATransaction: string; var ANumberIssued, AFrankedAmount, AUnfrankedAmount,
  AFrankingCredit: Money): Boolean;
var
  TempInt64: int64;
begin
  AType := cxComboBox1.ItemIndex;
  ATransaction := cxComboBox2.Text;
  TempInt64 := nfNumberIssued.AsInteger;
  ANumberIssued := (TempInt64 * 10000);

//  AFrankedAmount := Double2Money(nfFranked.AsFloat);
  AFrankedAmount := GetNumericValue(nfFranked, FFrankPercentage);
//  AUnfrankedAmount := Double2Money(nfUnFranked.AsFloat);
  AUnfrankedAmount := GetNumericValue(nfUnFranked, FFrankPercentage);

  AFrankingCredit := Double2Money(nfImputedCredit.AsFloat);

  Result := ((cxComboBox1.ItemIndex <> -1) or
             (nfNumberIssued.Asinteger <> 0) or
             (nfFranked.AsFloat <> 0) or
             (nfUnFranked.AsFloat <> 0) or
             (nfImputedCredit.AsFloat <> 0));
end;

function TdlgEditSageHandisoftSuperFields.ListedCompanyDividend: boolean;
begin
  Result := (cxComboBox1.ItemIndex = Integer(ttIncome)) and
            (cxComboBox2.ItemIndex = Integer(inListedCompanyDividend));
end;

procedure TdlgEditSageHandisoftSuperFields.LoadTypes;
var
  i: integer;
begin
  cxComboBox1.Properties.Items.Clear;
  for i := 0 to Integer(High(TTxnTypes)) do
    cxComboBox1.Properties.Items.Add(TypesArray[TTxnTypes(i)])
end;

procedure TdlgEditSageHandisoftSuperFields.nfFrankedChange(Sender: TObject);
begin
  if (nfFranked.AsFloat <> 0) and (FActualAmount < 0) then begin
    //Validate franked amount
    if nfFranked.asFloat > FTranAmount then
      nfFranked.asFloat := FTranAmount;
    nfUnFranked.AsFloat := (FTranAmount - nfFranked.AsFloat);
  end else if FFrankPercentage then begin
    //Validate franked percentage
    if nfFranked.asFloat > 100 then
      nfFranked.asFloat := 100;
    nfUnFranked.AsFloat := (FTranAmount - nfFranked.AsFloat);
  end;
  btnCalcClick(Sender);
end;

procedure TdlgEditSageHandisoftSuperFields.nfUnfrankedChange(Sender: TObject);
begin
  if (nfUnFranked.AsFloat <> 0) and (FActualAmount < 0) then begin
    //Validate unfranked amount
    if nfUnfranked.asFloat > FTranAmount then
      nfUnfranked.asFloat := FTranAmount;
    nfFranked.AsFloat := (FTranAmount - nfUnfranked.AsFloat);
  end else if FFrankPercentage then begin
    //Validate unfranked percentage
    if nfUnfranked.asFloat > 100 then
      nfUnfranked.asFloat := 100;
    nfFranked.AsFloat := (FTranAmount - nfUnfranked.AsFloat);
  end;
  btnCalcClick(Sender);
end;

procedure TdlgEditSageHandisoftSuperFields.nfUnfrankedKeyPress(Sender: TObject;
  var Key: Char);
var
  nf: TOvcNumericField;
begin
  if Key = '=' then
  begin
    Key := #0;
    nf := Sender as TOvcNumericField;
    if nf = nfFranked then
      nfFranked.asFloat := (FTranAmount - nfUnFranked.asFloat)
    else if nf = nfUnFranked then
      nfUnFranked.asFloat := (FTranAmount - nfFranked.asFloat);
    btnCalcClick(Sender);
  end;
end;

procedure TdlgEditSageHandisoftSuperFields.SetFields(AType: integer;
  ATransaction: string; ANumberIssued, AFrankedAmount, AUnfrankedAmount, AFrankingCredit: Money);
begin
  cxComboBox1.ItemIndex := AType;
  cxComboBox2.ItemIndex := cxComboBox2.Properties.Items.IndexOf(ATransaction);
  nfNumberIssued.AsInteger := Trunc(ANumberIssued / 10000);

  SetNumericValue(nfFranked, AFrankedAmount, FrankPercentage);
  SetNumericValue(nfUnfranked, AUnfrankedAmount, FrankPercentage);

  nfImputedCredit.AsFloat := Money2Double(AFrankingCredit);
end;

procedure TdlgEditSageHandisoftSuperFields.SetFrankPercentage(
  const Value: boolean);
begin
   FFrankPercentage := Value;
   SetPercentLabel(lp1, FFrankPercentage);
   SetPercentLabel(lp2, FFrankPercentage);


   btnCalc.Visible := not FFrankPercentage;

   if FFrankPercentage then begin
      lblfrankedAmount.Caption := 'Percentage Franked';
      lblUnFrankedAmount.Caption := 'Percentage Unfranked';

      FTranAmount := 100;
      nfImputedCredit.Enabled := False;

      lblAmount.Caption := '100%'
   end else begin
      lblfrankedAmount.Caption := 'Franked';
      lblUnFrankedAmount.Caption := 'Unfranked';
      nfImputedCredit.Enabled := (not FReadOnly);
      lblAmount.Caption := Money2Str(FActualAmount);
   end;

end;

procedure TdlgEditSageHandisoftSuperFields.SetInfo(iDate: integer;
  sNarration: string; mAmount: Money);
begin
  FDate := iDate;

  FActualAmount := mAmount;
  FTranAmount := Abs(mAmount/100.0);

  lblDate.Caption := BkDate2Str(FDate);
  lblNarration.Caption := sNarration;
end;

procedure TdlgEditSageHandisoftSuperFields.SetMoveDirection(
  const Value: TFundNavigation);
begin
  btnBack.Enabled := not (Value in [fnNoMove,fnIsFirst]);
  btnNext.Enabled := not (Value in [fnNoMove,fnIsLast]);
  FMoveDirection := Value;
end;

procedure TdlgEditSageHandisoftSuperFields.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;

  nfImputedCredit.Enabled := not Value;
  nfFranked.Enabled := not Value;
  nfUnfranked.Enabled := not Value;

  btnClear.Enabled := not Value;
end;

procedure TdlgEditSageHandisoftSuperFields.SetupHelp;
begin
  Self.ShowHint := INI_ShowFormHints;
  btnBack.Hint := 'Goto previous line|' +
                  'Goto previous line';

  btnNext.Hint := 'Goto next line|' +
                  'Goto next line';

  btnCalc.Hint := 'Calculate the Franking Credit|' +
                  'Calculate the Franking Credit';

  BKHelpSetUp(Self, BKH_Coding_transactions_for_Handisoft_Superfund);
end;

function TdlgEditSageHandisoftSuperFields.ValidForm: boolean;
var
  ValidTransaction: Boolean;
begin
  Result := True;
  //Transaction - must be in list for current type (should never happen)
  if (cxComboBox2.ItemIndex <> -1) then begin
    ValidTransaction := True;
    case TTxnTypes(cxComboBox1.ItemIndex) of
      ttGeneralExpenses: ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TGeneralExpenses))) and
                                             (cxComboBox2.Text = GeneralExpensesArray[TGeneralExpenses(cxComboBox2.ItemIndex)]);
      ttIncome         : ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TIncome))) and
                                             (cxComboBox2.Text = IncomeArray[TIncome(cxComboBox2.ItemIndex)]);
      ttExpenses       : ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TExpenses))) and
                                             (cxComboBox2.Text = ExpensesArray[TExpenses(cxComboBox2.ItemIndex)]);
      ttPurchases      : ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TPurchases))) and
                                             (cxComboBox2.Text = PurchasesArray[TPurchases(cxComboBox2.ItemIndex)]);
      ttDisposal       : ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TDisposals))) and
                                             (cxComboBox2.Text = DisposalsArray[TDisposals(cxComboBox2.ItemIndex)]);
      ttTransfer       : ValidTransaction := (cxComboBox2.ItemIndex <= Integer(High(TTransfers))) and
                                             (cxComboBox2.Text = TransfersArray[TTransfers(cxComboBox2.ItemIndex)]);
    end;
    if not ValidTransaction then
    begin
      HelpfulWarningMsg( Format('%s is not a valid transaction for "%s".',[cxComboBox2.Text, cxComboBox1.Text]), 0);
      cxComboBox2.SetFocus;
      Result := False;
      Exit;
    end;
  end;

  //Number Issued
  if not ValueIsValid( nfNumberIssued, 'Number issued') then begin
    Result := False;
    Exit;
  end;
  //Franked
  if not ValueIsValid( nfFranked, 'Franked amount') then begin
    Result := False;
    Exit;
  end;
  //Unfranked
  if not ValueIsValid( nfUnfranked, 'Unfranked amount') then begin
    Result := False;
    Exit;
  end;
  //Franking Credit
  if not ValueIsValid( nfImputedCredit, 'Franking credit') then begin
    Result := False;
    Exit;
  end;
end;

end.









