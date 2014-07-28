unit EditSuperFieldsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ovcbase, ovcef, ovcpb, ovcnf, MoneyDef,
  ovcpf, bkconst, Buttons, cxGraphics, cxControls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, OsFont, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TdlgEditSuperFields = class(TForm)
    pnlFooters: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    Label10: TLabel;
    lblDate: TLabel;
    lblAmount: TLabel;
    lblamountlbl: TLabel;
    Label12: TLabel;
    lblNarration: TLabel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    nfImputedCredit: TOvcNumericField;
    nfTaxFreeDist: TOvcNumericField;
    nfTaxExemptDist: TOvcNumericField;
    nfTaxDeferredDist: TOvcNumericField;
    nfTFNCredits: TOvcNumericField;
    nfForeignIncome: TOvcNumericField;
    nfForeignTaxCredits: TOvcNumericField;
    nfCapitalGains: TOvcNumericField;
    nfDiscountedCapitalGains: TOvcNumericField;
    Label13: TLabel;
    nfCapitalGainsOther: TOvcNumericField;
    Label14: TLabel;
    nfOtherExpenses: TOvcNumericField;
    Label15: TLabel;
    eCGTDate: TOvcPictureField;
    btnClear: TButton;
    lblFranked: TLabel;
    lblUnfranked: TLabel;
    nfFranked: TOvcNumericField;
    nfUnfranked: TOvcNumericField;
    Label18: TLabel;
    cmbMember: TComboBox;
    Label26: TLabel;
    btnChart: TSpeedButton;
    Label27: TLabel;
    nfUnits: TOvcNumericField;
    cmbxAccount: TcxComboBox;
    btnCalc: TSpeedButton;
    lP1: TLabel;
    lp2: TLabel;
    btnBack: TBitBtn;
    btnNext: TBitBtn;
    lp4: TLabel;
    lp5: TLabel;
    lp6: TLabel;
    lp8: TLabel;
    lp9: TLabel;
    lp10: TLabel;
    lp11: TLabel;
    lp12: TLabel;
    lp13: TLabel;
    lp14: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure nfTFNCreditsKeyPress(Sender: TObject; var Key: Char);
    procedure btnBackClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnChartClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmbxAccountPropertiesChange(Sender: TObject);
    procedure cmbxAccountPropertiesDrawItem(AControl: TcxCustomComboBox;
      ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState);
    procedure cmbxAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nfUnitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nfFrankedChange(Sender: TObject);
    procedure nfImputedCreditChange(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure nfUnfrankedChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FReadOnly, FAutoPresSMinus: boolean;
    FMoveDirection: TFundNavigation;
    FTop, FLeft, FCurrentAccountIndex, FSkip: Integer;
    Glyph: TBitMap;
    FActualAmount: Money;
    FDate: Integer;
    FFrankPercentage: Boolean;
    crModified: Boolean;
    UFModified: Boolean;
    FRevenuePercentage: Boolean;
    FMemOnly: Boolean;
    procedure SetReadOnly(const Value: boolean);
    procedure SetMoveDirection(const Value: TFundNavigation);
    procedure SetFrankPercentage(const Value: Boolean);
    procedure SetUpHelp;
    procedure SetRevenuePercentage(const Value: Boolean);
    procedure SetMemOnly(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    procedure SetFields( mImputedCredit,
                         mTaxFreeDist,
                         mTaxExemptDist,
                         mTaxDeferredDist,
                         mTFNCredits,
                         mForeignIncome,
                         mForeignTaxCredits,
                         mCapitalGains,
                         mDiscountedCapitalGains,
                         mOtherExpenses,
                         mCapitalGainsOther,
                         mFranked,
                         mUnfranked : Money;
                         dCGTDate : integer;
                         mComponent : byte;
                         mUnits: Money;
                         mAccount: string);

   { procedure SetMEMFields(mFranked: Money;
                           mUnFranked: Money;
                           mAccount: string;
                           mComponent: Byte);  }
    procedure SetInfo(iDate : integer; sNarration: string; mAmount : Money);

    function GetFields( var mImputedCredit : Money;
                         var mTaxFreeDist : Money;
                         var mTaxExemptDist : Money;
                         var mTaxDeferredDist : Money;
                         var mTFNCredits : Money;
                         var mForeignIncome : Money;
                         var mForeignTaxCredits : Money;
                         var mCapitalGains : Money;
                         var mDiscountedCapitalGains : Money;
                         var mOtherExpenses : Money;
                         var mCapitalGainsOther : Money;
                         var mFranked : Money;
                         var mUnfranked : Money;
                         var dCGTDate : integer;
                         var mComponent: byte;
                         var mAccount: Shortstring;
                         var mUnits: Money) : boolean;

    {function GetMEMFields(var mFranked, mUnFranked: Money;
                          var mAccount: Shortstring;
                          var mComponent: Byte): Boolean;}

    property ReadOnly : boolean read FReadOnly write SetReadOnly;
    property MoveDirection : TFundNavigation read FMoveDirection write SetMoveDirection;
    property FormTop: Integer read FTop write FTop;
    property FormLeft: Integer read FLeft write FLeft;
    property FrankPercentage: Boolean read FFrankPercentage write SetFrankPercentage;
    property RevenuePercentage: Boolean read FRevenuePercentage write SetRevenuePercentage;
    property MemOnly: Boolean read FMemOnly write SetMemOnly;
  end;

//******************************************************************************
implementation
uses
  glConst,
  bkDateUtils,
  GenUtils,
  bkXPThemes,
  SelectDate,
  WarningMoreFrm,
  SuperFieldsutils,
  AccountLookupFrm, BKDefs, Globals, imagesfrm, bkhelp;

{$R *.dfm}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgEditSuperFields.GetFields(var mImputedCredit, mTaxFreeDist,
  mTaxExemptDist, mTaxDeferredDist, mTFNCredits, mForeignIncome,
  mForeignTaxCredits, mCapitalGains, mDiscountedCapitalGains,
  mOtherExpenses, mCapitalGainsOther, mFranked, mUnfranked : Money;
  var dCGTDate : integer; var mComponent: Byte; var mAccount: Shortstring;
  var mUnits: Money ) : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     take the values from the form and return into vars
//
// Parameters:
//
// Result:      Returns true if any of the fields are no zero
//- - - - - - - - - - - - - - - - - - - -
begin
  mTaxFreeDist := GetNumericValue(nfTaxFreeDist, RevenuePercentage);
  mTaxExemptDist := GetNumericValue(nfTaxExemptDist, RevenuePercentage);
  mTaxDeferredDist := GetNumericValue(nfTaxDeferredDist, RevenuePercentage);
  mTFNCredits := GetNumericValue(nfTFNCredits, RevenuePercentage);
  mForeignIncome := GetNumericValue(nfForeignIncome, RevenuePercentage);
  mForeignTaxCredits := GetNumericValue(nfForeignTaxCredits, RevenuePercentage);
  mCapitalGains := GetNumericValue(nfCapitalGains, RevenuePercentage);
  mDiscountedCapitalGains := GetNumericValue(nfDiscountedCapitalGains, RevenuePercentage);
  mOtherExpenses := GetNumericValue(nfOtherExpenses, RevenuePercentage);
  mCapitalGainsOther := GetNumericValue(nfCapitalGainsOther, RevenuePercentage);

  dCGTDate := stNull2Bk(eCGTDate.AsStDate);

  mFranked := GetNumericValue(nfFranked, FrankPercentage);
  mUnfranked := GetNumericValue(nfUnfranked, FrankPercentage);

  mImputedCredit := Double2Money(nfImputedCredit.AsFloat);

  mComponent := cmbMember.ItemIndex;
  if cmbxAccount.ItemIndex > 0 then
     mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
  else
     mAccount := '';

  mUnits := nfUnits.AsFloat * 10000;

  if ((FActualAmount < 0) and (mUnits > 0)) or
     ((FActualAmount > 0) and (mUnits < 0)) then
    mUnits := -mUnits;

  Result := ( mImputedCredit <> 0) or
            ( mTaxFreeDist <> 0) or
            ( mTaxExemptDist <> 0) or
            ( mTaxDeferredDist <> 0) or
            ( mTFNCredits <> 0) or
            ( mForeignIncome <> 0) or
            ( mForeignTaxCredits <> 0) or
            ( mCapitalGains <> 0) or
            ( mDiscountedCapitalGains <> 0) or
            ( mCapitalGainsOther <> 0) or
            ( mOtherExpenses <> 0) or
            ( mFranked <> 0) or
            ( mUnfranked <> 0) or
            ( dCGTDate <> 0) or
            ( mComponent <> 0);
end;

{
function TdlgEditSuperFields.GetMEMFields(var mFranked, mUnFranked: Money; var mAccount: Shortstring; var mComponent: Byte): Boolean;
begin
    mFranked := Double2Percent(nfFranked.AsFloat);
    mUnFranked := Double2Percent(nfUnFranked.AsFloat);
    if cmbxAccount.ItemIndex > 0 then
       mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
    else
       mAccount := '';
    mComponent := cmbMember.ItemIndex;
    Result := (mFranked <> 0)
           or (mUnFranked <> 0)
           or (mComponent <> 0);
end;
 }
 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSuperFields.SetFields(mImputedCredit, mTaxFreeDist,
  mTaxExemptDist, mTaxDeferredDist, mTFNCredits, mForeignIncome,
  mForeignTaxCredits, mCapitalGains, mDiscountedCapitalGains,
  mOtherExpenses, mCapitalGainsOther, mFranked, mUnfranked : Money;
  dCGTDate: integer; mComponent : byte; mUnits: Money; mAccount: string);
var
  i: Integer;
  p: pAccount_Rec;
begin

  SetNumericValue(nfTaxFreeDist, mTaxFreeDist, RevenuePercentage);
  SetNumericValue(nfTaxExemptDist, mTaxExemptDist, RevenuePercentage);
  SetNumericValue(nfTaxDeferredDist, mTaxDeferredDist, RevenuePercentage);

  SetNumericValue(nfForeignIncome, mForeignIncome, RevenuePercentage);

  SetNumericValue(nfCapitalGains, mCapitalGains, RevenuePercentage);
  SetNumericValue(nfDiscountedCapitalGains, mDiscountedCapitalGains, RevenuePercentage);
  SetNumericValue(nfCapitalGainsOther, mCapitalGainsOther, RevenuePercentage);
  SetNumericValue(nfOtherExpenses, mOtherExpenses, RevenuePercentage);

  SetNumericValue(nfFranked, mFranked, FrankPercentage);
  SetNumericValue(nfUnfranked, mUnfranked, FrankPercentage);

  UFModified := ((mFranked <> 0) or (mUnfranked <> 0))
             and ((mFranked + mUnfranked) <> abs(FActualAmount));


  if not MemOnly then  begin
     SetNumericValue(nfImputedCredit, mImputedCredit, False);
     nfImputedCreditChange(nfImputedCredit);
     SetNumericValue(nfTFNCredits, mTFNCredits, False);
     SetNumericValue(nfForeignTaxCredits, mForeignTaxCredits, False);
  end;


  cmbMember.ItemIndex := mComponent;

  eCGTDate.AsStDate := BkNull2St(dCGTDate);

  nfUnits.AsFloat := mUnits / 10000;

  cmbxAccount.Properties.Items.Add('');
  for i := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    p := MyClient.clChart.Account_At(i);
    cmbxAccount.Properties.Items.Add(p.chAccount_Code);
    if mAccount = p.chAccount_Code then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
  FCurrentAccountIndex := cmbxAccount.ItemIndex;
  FAutoPressMinus := (FActualAmount < 0) and (mUnits = 0);
end;

procedure TdlgEditSuperFields.SetFrankPercentage(const Value: Boolean);
begin
   FFrankPercentage := Value;
   SetPercentLabel(lp1, FFrankPercentage);
   SetPercentLabel(lp2, FFrankPercentage);

   btnCalc.Visible := not FFrankPercentage;

   if FFrankPercentage then begin
      lblFranked.Caption := 'Percentage Franked';
      lblUnFranked.Caption := 'Percentage Unfranked';

   end else begin
      lblFranked.Caption := 'Franked Amount';
      lblUnFranked.Caption := 'Unfranked Amount';
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSuperFields.FormCreate(Sender: TObject);
begin
  ThemeForm( Self);
  Self.HelpContext := BKH_Coding_transactions_for_BGL_Simple_Ledger;

  if MyClient.clFields.clAccounting_System_Used in [saBGLSimpleFund, saBGL360] then
     BKHelpSetUp(Self, BKH_Coding_transactions_for_BGL_Simple_Fund)
  else
     BKHelpSetUp(Self, BKH_Coding_transactions_for_BGL_Simple_Ledger );
  SetUpHelp;
  FReadOnly := false;
  Self.KeyPreview := True;
  eCGTDate.Epoch       := BKDATEEPOCH;
  eCGTDate.PictureMask := BKDATEFORMAT;
  FMoveDirection := fnNothing;
  FormTop := -999;
  FormLeft := -999;
  UFModified := False;
  FSkip := 0;
  Glyph := TBitMap.Create;
  ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
  // showmember component options
  cmbMember.Items.Clear;
end;

procedure TdlgEditSuperFields.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Glyph);
end;

procedure TdlgEditSuperFields.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F2) or ((Key = Ord('L')) and (Shift = [ssCtrl])) then
    btnChartClick(Sender);
end;

procedure TdlgEditSuperFields.FormShow(Sender: TObject);
begin
  if FTop > -999 then begin
     Top := FTop;
     Left := FLeft;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSuperFields.SetInfo( iDate : integer; sNarration: string; mAmount : Money);
var i: Integer;
begin
  lblDate.Caption := BkDate2Str( iDate);
  if RevenuePercentage then begin
     lblAmount.Caption := '100%';
     lblamountlbl.Caption := 'Total';
  end else
    lblAmount.Caption := Money2Str( mAmount);
    
  lblNarration.Caption := sNarration;
  FActualAmount := mAmount;
  FDate := iDate;
  cmbMember.Items.Clear;
  if (fdate = 0)
  or (FDate >= mcSwitchDate) then
    for i := mcnewMin to mcnewMax do
      cmbMember.Items.AddObject(mcNewNames[i], TObject(i))
  else
    for i := mcOldMin to mcOldMax do
      cmbMember.Items.AddObject(mcOldNames[i], TObject(i))

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSuperFields.btnBackClick(Sender: TObject);
begin
  FMoveDirection := fnGoBack;
  ModalResult := mrOk;
end;

procedure TdlgEditSuperFields.btnChartClick(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  s := cmbxAccount.Text;
  if PickAccount(s) then
  begin
    for i := 0 to (cmbxAccount.Properties.Items.Count) do
      if cmbxAccount.Properties.Items[i] = s then
      begin
        cmbxAccount.ItemIndex := i;
        Break;
      end;
  end;
end;

procedure TdlgEditSuperFields.btnClearClick(Sender: TObject);
begin
  nfImputedCredit.AsFloat := 0;
  nfTaxFreeDist.AsFloat := 0;
  nfTaxExemptDist.AsFloat := 0;
  nfTaxDeferredDist.AsFloat := 0;
  nfTFNCredits.AsFloat := 0;
  nfForeignIncome.AsFloat := 0;
  nfForeignTaxCredits.AsFloat := 0;
  nfCapitalGains.AsFloat := 0;
  nfDiscountedCapitalGains.AsFloat := 0;
  nfCapitalGainsOther.AsFloat := 0;
  nfOtherExpenses.AsFloat := 0;
  nfFranked.AsFloat := 0;
  nfUnfranked.AsFloat := 0;
  cmbMember.ItemIndex := 0;
  eCGTDate.AsString := '';
  UFModified := False;
  nfImputedCreditChange(nfImputedCredit);
end;

procedure TdlgEditSuperFields.btnNextClick(Sender: TObject);
begin
  FMoveDirection := fnGoForward;
  ModalResult := mrOk;
end;

procedure TdlgEditSuperFields.cmbxAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DOWN) or (Key = VK_NEXT) then
    FSkip := 1
  else if (Key = VK_UP) or (Key = VK_PRIOR) then
    FSkip := -1
  else
    FSkip := 0;
end;

procedure TdlgEditSuperFields.cmbxAccountPropertiesChange(Sender: TObject);
var
  p: pAccount_Rec;
begin
  if cmbxAccount.ItemIndex < 1 then exit;
  p := MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1);
  if not p.chPosting_Allowed then
  begin
    if FSkip = 1 then
    begin
      if cmbxAccount.Properties.Items.Count > FCurrentAccountIndex then
        cmbxAccount.ItemIndex := cmbxAccount.ItemIndex + 1
      else
        cmbxAccount.ItemIndex := FCurrentAccountIndex;
    end
    else if FSkip = -1 then
      cmbxAccount.ItemIndex := cmbxAccount.ItemIndex - 1
    else
      cmbxAccount.ItemIndex := FCurrentAccountIndex
  end
  else
    FCurrentAccountIndex := cmbxAccount.ItemIndex;
  FSkip := 0;
end;

procedure TdlgEditSuperFields.cmbxAccountPropertiesDrawItem(
  AControl: TcxCustomComboBox; ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState);
var
  p: pAccount_Rec;
  l: Integer;
  R: TRect;
begin
  if AIndex = 0 then exit;
  R := ARect;
  p := MyClient.clChart.Account_At(AIndex-1);
  ACanvas.fillrect(ARect);
  l := 2;
  if not p.chPosting_Allowed then
  begin
    ACanvas.DrawGlyph(R.Left, R.Top, Glyph);
    l := 15;
  end;
  R.Left := R.Left + l;
  R.Right := R.Right + l;
  ACanvas.DrawText(p.chAccount_Code, R, 0, p.chPosting_Allowed);
  R.Left := R.Left + 135 - l;
  R.Right := R.Right + 135 - l;
  ACanvas.DrawText('(' + p.chAccount_Description + ')', R, 0, p.chPosting_Allowed);
end;

procedure TdlgEditSuperFields.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;

  nfTaxFreeDist.Enabled := not Value;
  nfTaxExemptDist.Enabled := not Value;
  nfTaxDeferredDist.Enabled := not Value;
  nfForeignIncome.Enabled := not Value;

  nfCapitalGains.Enabled := not Value;
  nfDiscountedCapitalGains.Enabled := not Value;
  nfCapitalGainsOther.Enabled := not Value;
  nfOtherExpenses.Enabled := not Value;
  nfFranked.Enabled := not Value;
  nfUnfranked.Enabled := not Value;
  eCGTDate.Enabled := not Value;
  cmbMember.Enabled := not Value;
  cmbxAccount.Enabled := not Value;
  btnChart.Enabled := not Value;
  nfUnits.Enabled := not Value;

  nfImputedCredit.Enabled := not (FReadOnly or MemOnly);
  nfTFNCredits.Enabled := not (FReadOnly or MemOnly);
  nfForeignTaxCredits.Enabled := not (FReadOnly or MemOnly);

  btnClear.Enabled := not Value;
end;

procedure TdlgEditSuperFields.SetRevenuePercentage(const Value: Boolean);
begin
   FRevenuePercentage := Value;

   SetPercentLabel(lp4, FRevenuePercentage);
   SetPercentLabel(lp5, FRevenuePercentage);
   SetPercentLabel(lp6, FRevenuePercentage);

   SetPercentLabel(lp9, FRevenuePercentage);

   SetPercentLabel(lp11, FRevenuePercentage);
   SetPercentLabel(lp12, FRevenuePercentage);
   SetPercentLabel(lp13, FRevenuePercentage);
   SetPercentLabel(lp14, FRevenuePercentage);
end;

procedure TdlgEditSuperFields.SetUpHelp;
begin
  Self.ShowHint    := INI_ShowFormHints;
  btnBack.Hint := 'Goto previous line|' +
                  'Goto previous line';

  btnNext.Hint := 'Goto next line|' +
                  'Goto next line';

  btnCalc.Hint := 'Calculate the Imputed Credit|' +
                  'Calculate the Imputed Credit';

  btnChart.Hint :=  '(F2) Lookup Chart|(F2) Lookup Chart';

  cmbxAccount.Hint := 'Select Chart code|Select Chart code';
end;

procedure TdlgEditSuperFields.btnCalcClick(Sender: TObject);
begin
    crModified := False;
    nfImputedCreditChange(nil);
end;

procedure TdlgEditSuperFields.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);

  function ValueIsValid( aNFControl : TOvcNumericField) : boolean;
  begin
    result := aNFControl.AsFloat >= 0;
    if not result then
    begin
      HelpfulWarningMsg( 'Value cannot be negative.', 0);
      aNFControl.SetFocus;
    end;
  end;

var
  CGTDate : integer;
begin
  if FReadOnly and (FMoveDirection = fnNothing) then
    ModalResult := mrCancel;


  if ModalResult = mrOK then
  begin
    CanClose := false;

    //verify fields
    CGTDate := stNull2Bk( eCGTDate.AsStDate);

    if not ( DateIsValid( eCGTDate.AsString) or (CGTDate = 0)) then
    begin
      HelpfulWarningMSg( 'Please enter a valid CGT date.', 0);
      Exit;
    end;

    if (CGTDate <> 0) and ((CGTDate < MinValidDate) or (CGTDate > MaxValidDate)) then
    begin
      HelpfulWarningMsg( 'Please enter a valid CGT date.', 0);
      Exit;
    end;

    if not ValueIsValid( nfImputedCredit) then
      Exit;
    if not ValueIsValid( nfTFNCredits) then
      Exit;
    if not ValueIsValid( nfOtherExpenses) then
      Exit;
    if not ValueIsValid( nfForeignTaxCredits) then
      Exit;
    if not ValueIsValid( nfCapitalGains) then
      Exit;
    if not ValueIsValid( nfDiscountedCapitalGains) then
      Exit;
    if not ValueIsValid( nfCapitalGainsOther) then
      Exit;
    if not ValueIsValid( nfFranked) then
      Exit;
    if not ValueIsValid( nfUnfranked) then
      Exit;

    //no problems, allow close
    CanClose := true;
  end;
end;

procedure TdlgEditSuperFields.nfImputedCreditChange(Sender: TObject);
var Frank: Double;
begin
   if FrankPercentage then
      Frank := nfFranked.asFloat{ * Money2Double(FActualAmount) / 100}
   else
      Frank := nfFranked.asFloat;

   crModified := CheckFrankingCredit(Frank,fDate,nfImputedCredit, not((Sender = nfImputedCredit) or crModified));
end;

procedure TdlgEditSuperFields.nfTFNCreditsKeyPress(Sender: TObject;
  var Key: Char);
begin
  //ignore minus key
  if Key = '-' then
    Key := #0;
end;

procedure TdlgEditSuperFields.nfFrankedChange(Sender: TObject);
var Actual: Double;

begin
   if not UFModified then begin
      if FFrankPercentage then
         Actual := 100.0
      else
         Actual := Money2Double(FActualAmount);

      if sender = nffranked then
         CalcFrankAmount(Actual,nffranked,nfUnfranked)
      else
         CalcFrankAmount(Actual,nfUnfranked,nffranked)
   end;
   nfImputedCreditChange(Sender);
end;

procedure TdlgEditSuperFields.nfUnfrankedChange(Sender: TObject);
begin

   UFModified := True;
end;

procedure TdlgEditSuperFields.nfUnitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FAutoPressMinus then
    keybd_event(vk_subtract,0,0,0);
  FAutoPresSMinus := False;
end;


(*
procedure TdlgEditSuperFields.SetMEMFields(mFranked: Money;
                                           mUnFranked: Money;
                                           mAccount: string;
                                           mComponent: Byte);
var I: Integer;
    p: pAccount_Rec;
begin
  FrankPercentage := true;


  nfTaxFreeDist.Enabled := false;
  nfTaxExemptDist.Enabled := false;
  nfTaxDeferredDist.Enabled := false;
  nfTFNCredits.Enabled := false;
  nfForeignIncome.Enabled := false;
  nfForeignTaxCredits.Enabled := false;
  nfCapitalGains.Enabled := false;
  nfDiscountedCapitalGains.Enabled := false;
  nfCapitalGainsOther.Enabled := false;
  nfOtherExpenses.Enabled := false;
  nfImputedCredit.Enabled := false;
  eCGTDate.Enabled := false;
  nfUnits.Enabled := false;




  nfUnfranked.AsFloat := Percent2Double(mUnfranked);
  nfFranked.AsFloat := Percent2Double(mfranked);

  nfImputedCreditChange(nil);

  cmbMember.ItemIndex := mComponent;





  cmbxAccount.Properties.Items.Add('');
  for i := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    p := MyClient.clChart.Account_At(i);
    cmbxAccount.Properties.Items.Add(p.chAccount_Code);
    if mAccount = p.chAccount_Code then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
  FCurrentAccountIndex := cmbxAccount.ItemIndex;
  //FAutoPressMinus := (FActualAmount < 0) and (mUnits = 0);
end;
*)

procedure TdlgEditSuperFields.SetMemOnly(const Value: Boolean);
begin
  FMemOnly := Value;
  nfImputedCredit.Enabled := not FMemOnly;
  nfTFNCredits.Enabled := not FMemOnly;
  nfForeignTaxCredits.Enabled := not FMemOnly;
end;

procedure TdlgEditSuperFields.SetMoveDirection(const Value: TFundNavigation);
begin
  btnBack.Enabled := not (Value in [fnNoMove,fnIsFirst]);
  btnNext.Enabled := not (Value in [fnNoMove,fnIsLast]);
  FMoveDirection := Value;
end;

end.
