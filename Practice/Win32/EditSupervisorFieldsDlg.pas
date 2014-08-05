{ Note: fields are mapped onto existing superfund fields as follows:

  Member ID:                        SF_Member_ID [NEW]
  Franked:                          SF_Franked
  Unfranked:                        SF_Unfranked
  Interest:                         SF_Interest [NEW]
  Foreign:                          SF_Foreign_Income
  Foreign Capital Gains:            SF_Capital_Gains_Other
  Foreign Discount Capital Gains:   SF_Capital_Gains_Foreign_Disc [NEW]
  Rent:                             SF_Rent [NEW]
  Capital Gain:                     SF_Capital_Gains_Indexed
  Discount Capital Gain:            SF_Capital_Gains_Disc
  Other Taxable:                    SF_Other_Expenses
  Tax Deferred:                     SF_Tax_Defered_Dist
  Tax Free Trust:                   SF_Tax_Free_Dist
  Non-Taxable:                      SF_Tax_Exempt_Dist
  Special Income:                   SF_Special_Income [NEW]
  Imputation Credit:                SF_Imputed_Credits
  Foreign Credit:                   SF_Foreign_Tax_Credits
  Foreign Capital Gains Credit:     SF_Foreign_Capital_Gains_Credit
  Witholding Credit:                SF_TFN_Credits
  Other Tax Credit:                 SF_Other_Tax_Credit [NEW]
  Non-resident Tax:                 SF_Non_Resident_Tax [NEW]
}


/// Used for   saSupervisor         :  'Supercorp Supervisor II'
///            saSolution6SuperFund :  'MYOB SuperFund'

unit EditSupervisorFieldsDlg;

interface

uses
  Contnrs,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ovcpf, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls, ExtCtrls, MoneyDef,
  bkconst, Buttons, cxGraphics, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit,
  OsFont, cxLookAndFeels, cxLookAndFeelPainters;

type
  Tmember = class(TObject)
     MemberID: string;
     MemberName: string;
     constructor Create(AnID,AName: string);
  end;
type
  TdlgEditSupervisorFields = class(TForm)
    pnlFooters: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnClear: TButton;
    Panel1: TPanel;
    Label10: TLabel;
    lblDate: TLabel;
    lblAmount: TLabel;
    lblAmountlbl: TLabel;
    Label12: TLabel;
    lblNarration: TLabel;
    Panel2: TPanel;
    Label15: TLabel;
    gbTax: TGroupBox;
    Label9: TLabel;
    nfImputedCredit: TOvcNumericField;
    Label13: TLabel;
    nfForeignTaxCredits: TOvcNumericField;
    Label19: TLabel;
    nfForeignCGCredit: TOvcNumericField;
    Label24: TLabel;
    nfTFNCredits: TOvcNumericField;
    Label25: TLabel;
    nfOtherTaxCredit: TOvcNumericField;
    Label26: TLabel;
    nfNonResidentTax: TOvcNumericField;
    gbRevenue: TGroupBox;
    lblFranked: TLabel;
    nfFranked: TOvcNumericField;
    lblUnfranked: TLabel;
    nfUnfranked: TOvcNumericField;
    Label3: TLabel;
    nfInterest: TOvcNumericField;
    Label4: TLabel;
    nfForeignIncome: TOvcNumericField;
    Label16: TLabel;
    nfCapitalGainsOther: TOvcNumericField;
    Label17: TLabel;
    nfCapitalGainsForeignDisc: TOvcNumericField;
    Label18: TLabel;
    nfRent: TOvcNumericField;
    Label21: TLabel;
    nfCapitalGains: TOvcNumericField;
    Label22: TLabel;
    nfDiscountedCapitalGains: TOvcNumericField;
    Label5: TLabel;
    nfOtherExpenses: TOvcNumericField;
    Label6: TLabel;
    nfTaxDeferredDist: TOvcNumericField;
    Label7: TLabel;
    nfTaxFreeDist: TOvcNumericField;
    Label14: TLabel;
    nfTaxExemptDist: TOvcNumericField;
    Label8: TLabel;
    nfSpecialIncome: TOvcNumericField;
    Label27: TLabel;
    btnChart: TSpeedButton;
    Label28: TLabel;
    nfUnits: TOvcNumericField;
    cmbxAccount: TcxComboBox;
    lP1: TLabel;
    lp2: TLabel;
    btnCalc: TSpeedButton;
    btnBack: TBitBtn;
    btnNext: TBitBtn;
    Label23: TLabel;
    lblRemain: TLabel;
    cmbMembers: TcxComboBox;
    lMember: TLabel;
    lp4: TLabel;
    lp5: TLabel;
    lp6: TLabel;
    lp7: TLabel;
    lp8: TLabel;
    lp9: TLabel;
    lp10: TLabel;
    lp11: TLabel;
    lp12: TLabel;
    lp13: TLabel;
    lp14: TLabel;
    lp15: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure nfExit(Sender: TObject);
    procedure nfKeyPress(Sender: TObject; var Key: Char);
    procedure btnBackClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnChartClick(Sender: TObject);
    procedure cmbxAccountPropertiesDrawItem(AControl: TcxCustomComboBox;
      ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState);
    procedure cmbxAccountPropertiesChange(Sender: TObject);
    procedure cmbxAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nfUnitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nfFrankedChange(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure nfImputedCreditChange(Sender: TObject);
    procedure nfGeneralChange(Sender: TObject);
    procedure nfUnfrankedChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbMembersPropertiesChange(Sender: TObject);
    procedure cmbMembersPropertiesDrawItem(AControl: TcxCustomComboBox;
      ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState);
  private
    { Private declarations }
    FReadOnly, FAutoPresSMinus: boolean;
    FTranAmount, FActualAmount: Double;
    FMoveDirection: TFundNavigation;
    FTop, FLeft, FCurrentAccountIndex, FSkip: Integer;
    Glyph: TBitMap;
    FFrankPercentage: Boolean;
    fDate: Integer;
    crModified: Boolean;
    UFModified: Boolean;
    MembersList: TObjectList;
    FRevenuePercentage: Boolean;
    FMemOnly: Boolean;
    procedure SetReadOnly(const Value: boolean);
    procedure SetMoveDirection(const Value: TFundNavigation);
    procedure CalcControlTotals( var Count : Integer; var Total, Remainder : Currency );
    procedure UpdateDisplayTotals;
    function ValidForm: Boolean;
    function HasNegativeNumbers: Boolean;
    procedure SetFrankPercentage(const Value: Boolean);
    procedure SetupHelp;
    procedure GetMembers;
    procedure SetRevenuePercentage(const Value: Boolean);
    procedure SetMemOnly(const Value: Boolean);
    procedure RefreshChartCodeCombo(aAccount : string = '');
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
                         mFranked, mUnfranked, mInterest, mCapitalGainsForeignDisc,
                         mRent, mSpecialIncome, mOtherTaxCredit, mNonResidentTax, mForeignCGCredit: Money;
                         mMemberID: string; mUnits: Money; mAccount: string);

    {procedure SetMemFields(
                         mFranked, mUnFranked: Money;
                         mAccount: string;
                         mMemberID: string
                         ); }

    procedure SetInfo( iDate : integer; sNarration: string; mAmount : Money);

    function GetFields(  var mImputedCredit : Money;
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
                         var mFranked: Money;
                         var mUnfranked: Money;
                         var mInterest: Money;
                         var mCapitalGainsForeignDisc: Money;
                         var mRent: Money;
                         var mSpecialIncome: Money;
                         var mOtherTaxCredit: Money;
                         var mNonResidentTax: Money;
                         var mForeignCGCredit: Money;
                         var mMemberID: ShortString;
                         var mAccount: Shortstring;
                         var mUnits: Money) : boolean;

   { function GetMemFields(var mFranked, mUnFranked: Money;
                         var mAccount: Shortstring;
                         var mMemberID: Shortstring
                         ): boolean;}

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
  WinUtils,
  glConst,
  bkDateUtils,
  GenUtils,
  bkXPThemes,
  SelectDate,
  WarningMoreFrm,
  ErrorMoreFrm,
  SuperFieldsUtils,
  AccountLookupFrm, BKDefs, Globals, imagesfrm, bkhelp;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgEditSupervisorFields.GetFields(var mImputedCredit, mTaxFreeDist,
  mTaxExemptDist, mTaxDeferredDist, mTFNCredits, mForeignIncome,
  mForeignTaxCredits, mCapitalGains, mDiscountedCapitalGains,
  mOtherExpenses, mCapitalGainsOther, mFranked, mUnfranked, mInterest,
  mCapitalGainsForeignDisc, mRent, mSpecialIncome, mOtherTaxCredit, mNonResidentTax,
  mForeignCGCredit: Money;
  var mMemberID: ShortString; var mAccount: Shortstring; var mUnits: Money) : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     take the values from the form and return into vars
//
// Parameters:
//
// Result:      Returns true if any of the fields are no zero
//- - - - - - - - - - - - - - - - - - - -
begin

  mFranked := GetNumericValue(nfFranked, FrankPercentage);
  mUnfranked := GetNumericValue(nfUnfranked, FrankPercentage);

  // Revenue Items
  mInterest := GetNumericValue(nfInterest, RevenuePercentage);
  mForeignIncome := GetNumericValue(nfForeignIncome, RevenuePercentage);
  mCapitalGainsOther := GetNumericValue(nfCapitalGainsOther, RevenuePercentage);
  mCapitalGainsForeignDisc := GetNumericValue(nfCapitalGainsForeignDisc, RevenuePercentage);
  mRent := GetNumericValue(nfRent, RevenuePercentage);
  mCapitalGains := GetNumericValue(nfCapitalGains, RevenuePercentage);
  mDiscountedCapitalGains := GetNumericValue(nfDiscountedCapitalGains, RevenuePercentage);
  mOtherExpenses := GetNumericValue(nfOtherExpenses, RevenuePercentage);
  mTaxDeferredDist := GetNumericValue(nfTaxDeferredDist, RevenuePercentage);
  mTaxFreeDist := GetNumericValue(nfTaxFreeDist, RevenuePercentage);
  mTaxExemptDist := GetNumericValue(nfTaxExemptDist, RevenuePercentage);
  mSpecialIncome := GetNumericValue(nfSpecialIncome, RevenuePercentage);

  // Tax Items
  mTFNCredits := GetNumericValue(nfTFNCredits, False);
  mOtherTaxCredit := GetNumericValue(nfOtherTaxCredit, False);
  mNonResidentTax := GetNumericValue(nfNonResidentTax, False);
  mForeignCGCredit := GetNumericValue(nfForeignCGCredit, False);
  mForeignTaxCredits := GetNumericValue(nfForeignTaxCredits, False);
  mImputedCredit := GetNumericValue(nfImputedCredit, False);

  mMemberID := Trim(cmbMembers.Text);

  if cmbxAccount.ItemIndex > 0 then
     mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
  else
     mAccount := '';

  mUnits := nfUnits.AsFloat * 10000;
  if ((FActualAmount < 0) and (mUnits > 0))
  or ((FActualAmount > 0) and (mUnits < 0)) then
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
            ( mInterest <> 0) or
            ( mCapitalGainsForeignDisc <> 0) or
            ( mRent <> 0) or
            ( mSpecialIncome <> 0) or
            ( mOtherTaxCredit <> 0) or
            ( mNonResidentTax <> 0) or
            ( mOtherTaxCredit <> 0) or
            ( mForeignCGCredit <> 0) or
            ( mMemberID <> '');
end;

procedure TdlgEditSupervisorFields.GetMembers;
var MemberFilename: string;
    lLine,
    LFile: TStringlist;
    I: Integer;
    NewMember: TMember;
begin
   cmbMembers.Clear;
   MembersList.Clear;
   with MyClient.clFields do begin
      MemberFilename := ChangeFileExt( clLoad_Client_Files_From, '.mbr');
      if bkFileExists(MemberFilename) then begin
           lFile := TStringlist.Create;
           try
              lFile.LoadFromFile(MemberFilename);
              // Now clean it up..
              if lfile.Count < 2 then
                 Exit;
              lLine := TStringlist.Create;
              try
                 lLine.Delimiter := ',';
                 lLine.StrictDelimiter := True;
                 lFile.Delete(0);// Get rid of the header
                 for I := 0 to lFile.Count - 1 do begin
                     LLine.DelimitedText := LFile[I];
                     if LLine.Count < 2 then
                        Continue;
                     NewMember := TMember.Create(LLine[0],LLine[1]);
                     MembersList.Add(NewMember);
                     cmbMembers.Properties.Items.AddObject(NewMember.MemberID, NewMember);
                 end;
              finally
                 lLine.Free;
              end;
           finally
              lFile.free;
           end;
      end;
   end;

end;

(*
function TdlgEditSupervisorFields.GetMemFields(var mFranked, mUnFranked: Money;
  var mAccount, mMemberID: shortstring): boolean;
begin
    mFranked := Double2Percent( nfFranked.AsFloat);
    mUnFranked := Double2Percent( nfUnFranked.AsFloat);
    if cmbxAccount.ItemIndex > 0 then
       mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
    else
       mAccount := '';
    mMemberID := Trim(cmbMembers.Text);

    Result := ( mFranked <> 0)
           or ( mUnFranked <> 0)
           or ( mMemberID <> '')
end;
 *)

procedure TdlgEditSupervisorFields.nfExit(Sender: TObject);
begin
  UpdateDisplayTotals;
end;

procedure TdlgEditSupervisorFields.nfFrankedChange(Sender: TObject);
var Actual: Double;

begin
    if (not UFModified) then begin
       if FFrankPercentage then
          Actual := 100.0
       else
          Actual := Money2Double(FActualAmount);

       if Sender = nfUnfranked then
          CalcFrankAmount(Actual,nfUnfranked,nffranked)
       else
          CalcFrankAmount(Actual,nffranked,nfUnfranked);
   end;
   nfImputedCreditChange(Sender);
   UpdateDisplayTotals;
end;

procedure TdlgEditSupervisorFields.nfImputedCreditChange(Sender: TObject);
begin
   crModified := CheckFrankingCredit(nfFranked.asFloat, fDate, nfImputedCredit, not((Sender = nfImputedCredit) or crModified));
end;


procedure TdlgEditSupervisorFields.nfGeneralChange(Sender: TObject);
begin
  UpdateDisplayTotals;
end;

procedure TdlgEditSupervisorFields.nfKeyPress(Sender: TObject;
  var Key: Char);
var
  Count : Integer;
  Total, Remain : Currency;
  nf: TOvcNumericField;
begin
  if Key = '-' then
    Key := #0;
  if Key = '=' then
  begin
    Key := #0;
    if not UFModified then
       Exit;
    nf := Sender as TOvcNumericField;
    if nf.Parent = gbRevenue then
    begin
      CalcControlTotals( Count, Total, Remain );
      if Remain > 0 then
      begin
        nf.AsFloat := nf.AsFloat + Remain;
        if nf = nfFranked then
            nfImputedCreditChange(Sender);
        UpdateDisplayTotals;
      end;
    end;
  end;
end;

procedure TdlgEditSupervisorFields.nfUnfrankedChange(Sender: TObject);
begin
   UFModified := True;
end;

procedure TdlgEditSupervisorFields.nfUnitsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if FAutoPressMinus then
    keybd_event(vk_subtract,0,0,0);
  FAutoPresSMinus := False;
end;

procedure TdlgEditSupervisorFields.RefreshChartCodeCombo(aAccount: string);
var
  ChartIndex: Integer;
  pChartAcc : pAccount_Rec;
begin
  cmbxAccount.Properties.Items.Add('');
  for ChartIndex := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    pChartAcc := MyClient.clChart.Account_At(ChartIndex);
    cmbxAccount.Properties.Items.Add(pChartAcc.chAccount_Code);
    if (aAccount <> '') and (aAccount = pChartAcc.chAccount_Code) then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSupervisorFields.SetFields(mImputedCredit, mTaxFreeDist,
  mTaxExemptDist, mTaxDeferredDist, mTFNCredits, mForeignIncome,
  mForeignTaxCredits, mCapitalGains, mDiscountedCapitalGains,
  mOtherExpenses, mCapitalGainsOther, mFranked, mUnfranked, mInterest,
  mCapitalGainsForeignDisc, mRent, mSpecialIncome, mOtherTaxCredit, mNonResidentTax,
  mForeignCGCredit: Money;
  mMemberID: string; mUnits: Money; mAccount: string);
begin

   SetNumericValue(nfTaxFreeDist, mTaxFreeDist, RevenuePercentage);
   SetNumericValue(nfTaxExemptDist, mTaxExemptDist, RevenuePercentage);
   SetNumericValue(nfTaxDeferredDist, mTaxDeferredDist, RevenuePercentage);
   SetNumericValue(nfTFNCredits, mTFNCredits, RevenuePercentage);
   SetNumericValue(nfForeignIncome, mForeignIncome, RevenuePercentage);

   SetNumericValue(nfCapitalGains, mCapitalGains, RevenuePercentage);
   SetNumericValue(nfDiscountedCapitalGains, mDiscountedCapitalGains, RevenuePercentage);
   SetNumericValue(nfCapitalGainsOther, mCapitalGainsOther, RevenuePercentage);
   SetNumericValue(nfOtherExpenses, mOtherExpenses, RevenuePercentage);
   SetNumericValue(nfSpecialIncome, mSpecialIncome, RevenuePercentage);

   SetNumericValue(nfFranked, mFranked, FrankPercentage);
   SetNumericValue(nfUnfranked, mUnfranked, FrankPercentage);

   UFModified := ((mFranked <> 0) or (mUnfranked <> 0))
             and ((mFranked + mUnfranked) <> abs(FActualAmount));



   SetNumericValue(nfInterest, mInterest, RevenuePercentage);
   SetNumericValue(nfCapitalGainsForeignDisc, mCapitalGainsForeignDisc, RevenuePercentage);
   SetNumericValue(nfRent, mRent, RevenuePercentage);

   if not Memonly then  begin
      SetNumericValue(nfOtherTaxCredit, mOtherTaxCredit, False);
      SetNumericValue(nfNonResidentTax, mNonResidentTax, False);
      SetNumericValue(nfForeignCGCredit, mForeignCGCredit, False);
      SetNumericValue(nfForeignTaxCredits, mForeignTaxCredits, False);
      SetNumericValue(nfImputedCredit, mImputedCredit, False);
      nfImputedCreditChange(nfImputedCredit);

   end;

  cmbMembers.ItemIndex := cmbMembers.Properties.Items.IndexOf (mMemberID);
  if (cmbMembers.ItemIndex < 0)
  and (mMemberID > '') then
     cmbMembers.Text := mMemberID;

  nfUnits.AsFloat := mUnits / 10000;

  RefreshChartCodeCombo(mAccount);
  FCurrentAccountIndex := cmbxAccount.ItemIndex;

  UpdateDisplayTotals;

  FAutoPressMinus := (FActualAmount < 0)
                  and (mUnits = 0);
end;

procedure TdlgEditSupervisorFields.SetFrankPercentage(const Value: Boolean);
begin
   FFrankPercentage := Value;

   SetPercentLabel(lp1, FFrankPercentage);
   SetPercentLabel(lp2, FFrankPercentage);

   btnCalc.Visible := not FFrankPercentage;

   if FFrankPercentage then begin
      lblFranked.Caption := 'Percentage Franked';
      lblUnFranked.Caption := 'Percentage Unfranked';
   end else begin
      lblFranked.Caption := 'Franked';
      lblUnFranked.Caption := 'Unfranked';
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSupervisorFields.FormCreate(Sender: TObject);
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
  MembersList := TObjectList.Create(True);
  ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
end;

procedure TdlgEditSupervisorFields.FormDestroy(Sender: TObject);
begin
   MembersList.Free;
   Glyph.Free;
end;

procedure TdlgEditSupervisorFields.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F2) or ((Key = Ord('L')) and (Shift = [ssCtrl])) then
    btnChartClick(Sender);
end;

procedure TdlgEditSupervisorFields.FormShow(Sender: TObject);
begin
  if FTop > -999 then
  begin
    Top := FTop;
    Left := FLeft;
  end;
  UpdateDisplayTotals;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSupervisorFields.SetInfo( iDate : integer; sNarration: string; mAmount : Money);
begin
  lblDate.Caption := BkDate2Str(iDate);
  FDate := iDate;
  FActualAmount := mAmount;

  if RevenuePercentage then begin
     lblAmount.Caption := '100%';
     lblamountlbl.Caption := 'Total';
  end else
  if mAmount <> 0 then
     lblAmount.Caption := Money2Str( abs(mAmount))
  else
     lblAmount.Caption := '';
  FTranAmount := Abs(mAmount/100.0);
  lblNarration.Caption := sNarration;
  GetMembers;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditSupervisorFields.btnBackClick(Sender: TObject);
begin
  FMoveDirection := fnGoBack;
  ModalResult := mrOk;
end;

procedure TdlgEditSupervisorFields.btnChartClick(Sender: TObject);
var
  i: Integer;
  SelectedCode : string;
  HasChartBeenRefreshed : boolean;
begin
  SelectedCode := cmbxAccount.Text;
  if PickAccount(SelectedCode, HasChartBeenRefreshed) then
  begin
    if HasChartBeenRefreshed then
    begin
      cmbxAccount.Properties.Items.Clear;
      RefreshChartCodeCombo();
    end;

    for i := 0 to cmbxAccount.Properties.Items.Count-1 do
    begin
      if cmbxAccount.Properties.Items[i] = SelectedCode then
      begin
        cmbxAccount.ItemIndex := i;
        Break;
      end;
    end;
  end;
end;

procedure TdlgEditSupervisorFields.btnCalcClick(Sender: TObject);
begin
   crModified := False;
   nfImputedCreditChange(nil);
end;

procedure TdlgEditSupervisorFields.btnClearClick(Sender: TObject);
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
  nfInterest.AsFloat := 0;
  nfCapitalGainsForeignDisc.AsFloat := 0;
  nfRent.AsFloat := 0;
  nfSpecialIncome.AsFloat := 0;
  nfOtherTaxCredit.AsFloat := 0;
  nfNonResidentTax.AsFloat := 0;
  nfForeignCGCredit.AsFloat := 0;
  cmbMembers.ItemIndex := -1;
  UFModified := False;
  nfImputedCreditChange(nfImputedCredit);
  UpdateDisplayTotals;
end;

procedure TdlgEditSupervisorFields.btnNextClick(Sender: TObject);
begin
  FMoveDirection := fnGoForward;
  ModalResult := mrOk;
end;

procedure TdlgEditSupervisorFields.SetReadOnly(const Value: boolean);
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
  nfInterest.Enabled := not Value;
  nfDiscountedCapitalGains.Enabled := not Value;
  nfRent.Enabled := not Value;
  nfSpecialIncome.Enabled := not Value;

  nfCapitalGainsForeignDisc.Enabled := not Value;
  cmbMembers.Enabled := not Value;
  cmbxAccount.Enabled := not Value;
  btnChart.Enabled := not Value;
  nfUnits.Enabled := not Value;

  nfImputedCredit.Enabled := not (FMemOnly or FReadOnly);
  nfForeignTaxCredits.Enabled := not (FMemOnly or FReadOnly);
  nfTFNCredits.Enabled := not (FMemOnly or FReadOnly);
  nfOtherTaxCredit.Enabled := not (FMemOnly or FReadOnly);
  nfNonResidentTax.Enabled := not (FMemOnly or FReadOnly);
  nfForeignCGCredit.Enabled := not (FMemOnly or FReadOnly);

  btnClear.Enabled := not Value;
end;

procedure TdlgEditSupervisorFields.SetRevenuePercentage(const Value: Boolean);
begin
   FRevenuePercentage := Value;

   SetPercentLabel(lp4, FRevenuePercentage);
   SetPercentLabel(lp5, FRevenuePercentage);
   SetPercentLabel(lp6, FRevenuePercentage);
   SetPercentLabel(lp7, FRevenuePercentage);
   SetPercentLabel(lp8, FRevenuePercentage);
   SetPercentLabel(lp9, FRevenuePercentage);

   SetPercentLabel(lp10, FRevenuePercentage);
   SetPercentLabel(lp11, FRevenuePercentage);
   SetPercentLabel(lp12, FRevenuePercentage);
   SetPercentLabel(lp13, FRevenuePercentage);
   SetPercentLabel(lp14, FRevenuePercentage);
   SetPercentLabel(lp15, FRevenuePercentage);
end;

procedure TdlgEditSupervisorFields.SetupHelp;
begin
    Self.ShowHint    := INI_ShowFormHints;
    btnBack.Hint := 'Goto previous line|' +
                    'Goto previous line';

    btnNext.Hint := 'Goto next line|' +
                    'Goto next line';

    btnCalc.Hint := 'Calculate the Imputation Credit|' +
                    'Calculate the Imputation Credit';

    btnChart.Hint :=  '(F2) Lookup Chart|(F2) Lookup Chart';

    cmbxAccount.Hint := 'Select Chart code|Select Chart code';

  case MyClient.clFields.clAccounting_System_Used of
    saSolution6SuperFund: BKHelpSetUp(Self, BKH_Coding_transactions_for_MYOB_Superfund);
    saSupervisor: BKHelpSetUp(Self, BKH_Coding_transactions_for_Supercorp_SuperVisor_II);
    saSuperMate: BKHelpSetUp(Self, BKH_Coding_transactions_for_superMate);
  end;
end;


function TdlgEditSupervisorFields.ValidForm: Boolean;
var
  Count : Integer;
  Total, Remain : Currency;
begin
  CalcControlTotals( Count, Total, Remain );
  ValidForm := (Count = 0)
            or (Remain = 0);
end;

function TdlgEditSupervisorFields.HasNegativeNumbers: Boolean;

  function ValueIsValid( aNFControl : TOvcNumericField; s: string) : boolean;
  begin
    result := aNFControl.AsFloat >= 0;
    if not result then
    begin
      HelpfulWarningMsg( S + ' cannot be negative.', 0);
      aNFControl.SetFocus;
    end;
  end;

begin
  Result := True;
  if not ValueIsValid( nfFranked, 'Franked') then
    Exit;
  if not ValueIsValid( nfUnfranked, 'Unfranked') then
    Exit;
  if not ValueIsValid( nfInterest, 'Interest') then
    Exit;
  if not ValueIsValid( nfForeignIncome, 'Foreign') then
    Exit;
  if not ValueIsValid( nfCapitalGainsOther, 'Foreign CG') then
    Exit;
  if not ValueIsValid( nfCapitalGainsForeignDisc, 'Foregin Discount CG') then
    Exit;
  if not ValueIsValid( nfRent, 'Rent') then
    Exit;
  if not ValueIsValid( nfCapitalGains, 'Capital Gain') then
    Exit;
  if not ValueIsValid( nfDiscountedCapitalGains, 'Discount CG') then
    Exit;
  if not ValueIsValid( nfOtherExpenses, 'Other Taxable') then
    Exit;
  if not ValueIsValid( nfTaxDeferredDist, 'Tax Deferred') then
    Exit;
  if not ValueIsValid( nfTaxFreeDist, 'Tax Free Trust') then
    Exit;
  if not ValueIsValid( nfTaxExemptDist, 'Non-Taxable') then
    Exit;
  if not ValueIsValid( nfSpecialIncome, 'Special Income') then
    Exit;
  Result := False;
end;

procedure TdlgEditSupervisorFields.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  UpdateDisplayTotals;
  CanClose := True;

  if FReadOnly
  and (FMoveDirection = fnNothing) then
     ModalResult := mrCancel;

  if (ModalResult = mrOK)
  and (not ValidForm) then
  begin
     HelpfulErrorMsg( 'There is ' + lblRemain.Caption + ' remaining to be allocated to Revenue Items.', 0);
     CanClose := False;
  end
  else if (ModalResult = mrOK)
  and (HasNegativeNumbers) then
     CanClose := False;
end;

procedure TdlgEditSupervisorFields.CalcControlTotals( var Count : Integer; var Total, Remainder : Currency );
var
  i: integer;
  c: TOvcNumericField;
  m: Currency;
begin
  Count := 0;
  Total := 0.0;
  Remainder := 0.0;
  for i := 0 to Pred(gbRevenue.ControlCount) do begin
     if gbRevenue.Controls[i] is TOvcNumericField then begin
        c := gbRevenue.Controls[i] as TOvcNumericField;
        m := c.AsFloat;
        if m <> 0 then begin
           Inc(Count);
           Total := Total + m;
        end;
     end;
  end;

  if FrankPercentage then
     Remainder := 100.0 - Total // 100 %
  else
     Remainder := FTranAmount - Total;
end;

procedure TdlgEditSupervisorFields.cmbMembersPropertiesChange(Sender: TObject);
var LM:TMember;
begin
   lm := TMember(cmbMembers.ItemObject);
   if Assigned(lm) then
      lMember.Caption := lm.MemberName
   else
      lMember.Caption := '-'
end;

procedure TdlgEditSupervisorFields.cmbMembersPropertiesDrawItem(
  AControl: TcxCustomComboBox; ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState);
var
  Member: Tmember;
  R: TRect;
begin
  if AIndex < 0 then
     exit;
  R := ARect;
  Member := Tmember(AControl.Properties.Items.Objects[AIndex]);
  ACanvas.fillrect(ARect);

  R.Left := R.Left + 2;
  if assigned(Member) then begin
     ACanvas.DrawText(Member.MemberID, R, 0, True);
     R.Left := R.Left + 135;
     ACanvas.DrawText(Member.MemberName, R, 0, True);
  end else
     ACanvas.DrawText(AControl.Properties.Items[AIndex] , R, 0, True);

end;

procedure TdlgEditSupervisorFields.cmbxAccountKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DOWN) or (Key = VK_NEXT) then
    FSkip := 1
  else if (Key = VK_UP) or (Key = VK_PRIOR) then
    FSkip := -1
  else
    FSkip := 0;
end;

procedure TdlgEditSupervisorFields.cmbxAccountPropertiesChange(Sender: TObject);
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

procedure TdlgEditSupervisorFields.cmbxAccountPropertiesDrawItem(
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
  if not p.chPosting_Allowed then begin
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

procedure TdlgEditSupervisorFields.UpdateDisplayTotals;
var
  Count : Integer;
  Total, Remain : Currency;
begin
  CalcControlTotals( Count, Total, Remain );
  if FrankPercentage then begin
     lblRemain.Caption := Format( '%0.4f', [Remain] ) + '%';
  end else begin
     lblRemain.Caption := Format( '%0.2m', [Remain] );
  end;
end;


(*
procedure TdlgEditSupervisorFields.SetMemFields(
                      mFranked, mUnFranked: Money; mAccount,
                      mMemberID: string);
var
  i: Integer;
  p: pAccount_Rec;
begin
 




  FrankPercentage := True;

  nfImputedCredit.Enabled := false;
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

  nfFranked.AsFloat := Percent2Double( mFranked);
  nfUnFranked.AsFloat := Percent2Double( mUnFranked);

  nfImputedCreditChange(nil);

  nfInterest.Enabled := false;
  nfCapitalGainsForeignDisc.Enabled := false;
  nfRent.Enabled := false;
  nfSpecialIncome.Enabled := false;
  nfOtherTaxCredit.Enabled := false;
  nfNonResidentTax.Enabled := false;
  nfForeignCGCredit.Enabled := false;
  cmbMembers.ItemIndex := cmbMembers.Properties.Items.IndexOf (mMemberID);
  if (cmbMembers.ItemIndex < 0)
  and (mMemberID > '') then
     cmbMembers.Text := mMemberID;

  nfUnits.Enabled := false;
  cmbxAccount.Properties.Items.Add('');
  for i := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    p := MyClient.clChart.Account_At(i);
    cmbxAccount.Properties.Items.Add(p.chAccount_Code);
    if mAccount = p.chAccount_Code then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
  FCurrentAccountIndex := cmbxAccount.ItemIndex;
  UpdateDisplayTotals;
  //FAutoPressMinus := (FActualAmount < 0) and (mUnits = 0);
end;
*)

procedure TdlgEditSupervisorFields.SetMemOnly(const Value: Boolean);
begin
   FMemOnly := Value;

   nfImputedCredit.Enabled := not FMemOnly;
   nfForeignTaxCredits.Enabled := not FMemOnly;
   nfTFNCredits.Enabled := not FMemOnly;
   nfOtherTaxCredit.Enabled := not FMemOnly;
   nfNonResidentTax.Enabled := not FMemOnly;
   nfForeignCGCredit.Enabled := not FMemOnly;
end;

procedure TdlgEditSupervisorFields.SetMoveDirection(const Value: TFundNavigation);
begin
  btnBack.Enabled := not (Value in [fnNoMove,fnIsFirst]);
  btnNext.Enabled := not (Value in [fnNoMove,fnIsLast]);
  FMoveDirection := Value;
end;

{ Tmember }

constructor Tmember.Create(AnID, AName: string);
begin
   inherited Create;
   MemberiD := AnID;
   MemberName := AName;
end;

end.

