unit EditBGLSF360FieldsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ovcbase, ovcef, ovcpb, ovcnf, MoneyDef,
  ovcpf, bkconst, Buttons, cxGraphics, cxControls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, OsFont, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, Globals,
  BGLCapitalGainsFme, BGLFrankingFme, BGLInterestIncomeFme, BGLForeignTaxFme,
  bkMaskUtils;

type

  TdlgEditBGLSF360Fields = class(TForm)
    pnlFooters: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pnlHeaderInfo: TPanel;
    lblDate: TLabel;
    lbldispDate: TLabel;
    lbldispAmount: TLabel;
    lblAmount: TLabel;
    lblNarration: TLabel;
    lbldispNarration: TLabel;
    btnClear: TButton;
    btnBack: TBitBtn;
    btnNext: TBitBtn;
    pnlTransactionInfo: TPanel;
    lblAccount: TLabel;
    cmbxAccount: TcxComboBox;
    btnChart: TSpeedButton;
    lblEntryType: TLabel;
    lbldispEntryType: TLabel;
    lblCashDate: TLabel;
    eCashDate: TOvcPictureField;
    lblAccrualDate: TLabel;
    eAccrualDate: TOvcPictureField;
    lblRecordDate: TLabel;
    eRecordDate: TOvcPictureField;
    pnlDistribution: TPanel;
    pcDistribution: TPageControl;
    tsAustralianIncome: TTabSheet;
    tsCapitalGains: TTabSheet;
    tsForeignIncome: TTabSheet;
    tsNonCashCapitalGains: TTabSheet;
    fmeDistributionFranking: TfmeBGLFranking;
    fmeInterestIncome: TfmeBGLInterestIncome;
    lblLessOtherAllowableTrustDeductions: TLabel;
    nfLessOtherAllowableTrustDeductions: TOvcNumericField;
    lpLessOtherAllowableTrustDeductions: TLabel;
    lblCGTConcession: TLabel;
    nfCGTConcession: TOvcNumericField;
    lpCGTConcession: TLabel;
    lpCGTCapitalLosses: TLabel;
    nfCGTCapitalLosses: TOvcNumericField;
    lblCGTCapitalLosses: TLabel;
    fmeBGLCashCapitalGainsTax: TfmeBGLCapitalGainsTax;
    fmeBGLNonCashCapitalGainsTax: TfmeBGLCapitalGainsTax;
    lblForeignCGT: TLabel;
    lblTaxPaid: TLabel;
    lblBeforeDiscount: TLabel;
    lblIndexationMethod: TLabel;
    lblOtherMethod: TLabel;
    nfForeignCGTBeforeDiscount: TOvcNumericField;
    nfForeignCGTIndexationMethod: TOvcNumericField;
    nfForeignCGTOtherMethod: TOvcNumericField;
    nfTaxPaidBeforeDiscount: TOvcNumericField;
    nfTaxPaidIndexationMethod: TOvcNumericField;
    nfTaxPaidOtherMethod: TOvcNumericField;
    lblAssessableForeignSourceIncome: TLabel;
    nfAssessableForeignSourceIncome: TOvcNumericField;
    lpAssessableForeignSourceIncome: TLabel;
    lblOtherNetForeignSourceIncome: TLabel;
    nfOtherNetForeignSourceIncome: TOvcNumericField;
    lpOtherNetForeignSourceIncome: TLabel;
    lblCashDistribution: TLabel;
    nfCashDistribution: TOvcNumericField;
    lpCashDistribution: TLabel;
    lblTaxExemptedAmounts: TLabel;
    nfTaxExemptedAmounts: TOvcNumericField;
    lpTaxExemptedAmounts: TLabel;
    lblTaxFreeAmounts: TLabel;
    nfTaxFreeAmounts: TOvcNumericField;
    lpTaxFreeAmounts: TLabel;
    nfTaxDeferredAmounts: TOvcNumericField;
    lblTaxDeferredAmounts: TLabel;
    lpTaxDeferredAmounts: TLabel;
    fmeBGLForeignTax1: TfmeBGLForeignTax;
    pnlDividend: TPanel;
    fmeDividendFranking: TfmeBGLFranking;
    fmeBGLForeignTax2: TfmeBGLForeignTax;
    pnlInterest: TPanel;
    lblInterest: TLabel;
    nfInterest: TOvcNumericField;
    lpInterest: TLabel;
    lblOtherIncome: TLabel;
    nfOtherIncome: TOvcNumericField;
    lpOtherIncome: TLabel;
    lblTFNAmountsWithheld: TLabel;
    nfTFNAmountsWithheld: TOvcNumericField;
    lpTFNAmountsWithheld: TLabel;
    lblNonResidentWithholdingTax: TLabel;
    nfNonResidentWithholdingTax: TOvcNumericField;
    lpNonResidentWithholdingTax: TLabel;
    pnlShareTrade: TPanel;
    lblShareBrokerage: TLabel;
    nfShareBrokerage: TOvcNumericField;
    lpShareBrokerage: TLabel;
    lblShareConsideration: TLabel;
    nfShareConsideration: TOvcNumericField;
    lpShareConsideration: TLabel;
    lblShareGSTAmount: TLabel;
    nfShareGSTAmount: TOvcNumericField;
    lpShareGSTAmount: TLabel;
    lblShareGSTRate: TLabel;
    cmbxShareGSTRate: TcxComboBox;
    lpShareTradeUnits: TLabel;
    nfShareTradeUnits: TOvcNumericField;
    lblShareTradeUnits: TLabel;
    lblOtherExpenses: TLabel;
    nfOtherExpenses: TOvcNumericField;
    lpOtherExpenses: TLabel;
    lineTransactionInfo: TShape;
    lineShareTrade: TShape;
    lineFooter: TShape;
    sfEntryType: TOvcPictureField;
    lineInterest: TShape;
    lineDividend: TShape;
    lineDistribution: TShape;
    lineCapitalGainsTab: TShape;
    Label1: TLabel;
    lpForeignIncome: TLabel;
    nfForeignIncome: TOvcNumericField;
    lblForeignIncome: TLabel;
    lblUnits: TLabel;
    nfUnits: TOvcNumericField;
    edtAccount: TEdit;
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
    procedure frameFrankingFrankedChange(Sender: TObject);
    procedure frameFrankingFrankingCreditsChange(Sender: TObject);
    procedure frameFrankingbtnCalcClick(Sender: TObject);
    procedure frameFrankingUnfrankedChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtAccountKeyPress(Sender: TObject; var Key: Char);
    procedure edtAccountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtAccountChange(Sender: TObject);
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
    fTranAccount : string;
    fTransactionType : TTransactionTypes;
    RemovingMask      : boolean;

    procedure SetReadOnly(const Value: boolean);
    procedure SetMoveDirection(const Value: TFundNavigation);
    function GetFrankPercentage : boolean;
    procedure SetFrankPercentage(const Value: boolean);
    procedure SetUpHelp;
    procedure SetRevenuePercentage(const Value: boolean);
    procedure SetMemOnly(const Value: boolean);
    procedure RefreshChartCodeCombo();
    procedure SetTransactionType( const Value : TTransactionTypes );
    procedure SetTranAccount( const Value : string );
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
                         mUnfranked,
                         mInterest,
                         mOtherIncome,
                         mOtherTrustDeductions,
                         mCGTConcessionAmount,
                         mForeignCGTBeforeDiscount,
                         mForeignCGTIndexationMethod,
                         mForeignCGTOtherMethod,
                         mTaxPaidBeforeDiscount,
                         mTaxPaidIndexationMethod,
                         mTaxPaidOtherMethod,
                         mOtherNetForeignSourceIncome,
                         mCashDistribution,
                         mAUFrankingCreditsFromNZCompany,
                         mNonResidentWithholdingTax,
                         mLICDeductions,
                         mNon_Cash_CGT_Discounted_Before_Discount,
                         mNon_Cash_CGT_Indexation,
                         mNon_Cash_CGT_Other,
                         mNon_Cash_CGT_Capital_Losses,
                         mShareBrokerage,
                         mShareConsideration,
                         mShareGSTAmount : Money;
                         dCGTDate: integer;
                         mComponent : byte;
                         mUnits: Money;
                         mAccount,
                         mShareGSTRate: shortstring;
                         dCash_Date,
                         dAccrual_Date,
                         dRecord_Date : integer
                         );

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
                        var mInterest : Money;
                        var mOtherIncome : Money;
                        var mOtherTrustDeductions : Money;
                        var mCGTConcessionAmount : Money;
                        var mForeignCGTBeforeDiscount : Money;
                        var mForeignCGTIndexationMethod : Money;
                        var mForeignCGTOtherMethod : Money;
                        var mTaxPaidBeforeDiscount : Money;
                        var mTaxPaidIndexationMethod : Money;
                        var mTaxPaidOtherMethod : Money;
                        var mOtherNetForeignSourceIncome : Money;
                        var mCashDistribution : Money;
                        var mAUFrankingCreditsFromNZCompany : Money;
                        var mNonResidentWithholdingTax : Money;
                        var mLICDeductions : Money;
                        var mNon_Cash_CGT_Discounted_Before_Discount : Money;
                        var mNon_Cash_CGT_Indexation : Money;
                        var mNon_Cash_CGT_Other : Money;
                        var mNon_Cash_CGT_Capital_Losses : Money;
                        var mShareBrokerage : Money;
                        var mShareConsideration : Money;
                        var mShareGSTAmount : Money;
                        var dCGTDate: integer;
                        var mComponent : byte;
                        var mUnits: Money;
                        var mAccount: shortstring;
                        var mShareGSTRate: shortstring;
                        var dCash_Date : integer;
                        var dAccrual_Date : integer;
                        var dRecord_Date : integer) : boolean;

    property ReadOnly : boolean read FReadOnly write SetReadOnly;
    property MoveDirection : TFundNavigation read FMoveDirection write SetMoveDirection;
    property FormTop: Integer read FTop write FTop;
    property FormLeft: Integer read FLeft write FLeft;
    property FrankPercentage: boolean read GetFrankPercentage write SetFrankPercentage;
    property RevenuePercentage: boolean read FRevenuePercentage write SetRevenuePercentage;
    property MemOnly: boolean read FMemOnly write SetMemOnly;
    property TranAccount : string read fTranAccount write SetTranAccount;
    property TransactionType : TTransactionTypes read fTransactionType write SetTransactionType;
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
  AccountLookupFrm, BKDefs, imagesfrm, bkhelp, SimpleFundX;

{$R *.dfm}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgEditBGLSF360Fields.GetFields( var mImputedCredit : Money;
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
                        var mInterest : Money;
                        var mOtherIncome : Money;
                        var mOtherTrustDeductions : Money;
                        var mCGTConcessionAmount : Money;
                        var mForeignCGTBeforeDiscount : Money;
                        var mForeignCGTIndexationMethod : Money;
                        var mForeignCGTOtherMethod : Money;
                        var mTaxPaidBeforeDiscount : Money;
                        var mTaxPaidIndexationMethod : Money;
                        var mTaxPaidOtherMethod : Money;
                         (* mCapitalGainsForeignDisc, *)
                        var mOtherNetForeignSourceIncome : Money;
                        var mCashDistribution : Money;
                        var mAUFrankingCreditsFromNZCompany : Money;
                        var mNonResidentWithholdingTax : Money;
                        var mLICDeductions : Money;
                        var mNon_Cash_CGT_Discounted_Before_Discount : Money;
                        var mNon_Cash_CGT_Indexation : Money;
                        var mNon_Cash_CGT_Other : Money;
                        var mNon_Cash_CGT_Capital_Losses : Money;
                        var mShareBrokerage : Money;
                        var mShareConsideration : Money;
                        var mShareGSTAmount : Money;
                        var dCGTDate: integer;
                        var mComponent : byte;
                        var mUnits: Money;
                        var mAccount: shortstring;
                        var mShareGSTRate: shortstring;
                        var dCash_Date : integer;
                        var dAccrual_Date : integer;
                        var dRecord_Date : integer) : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     take the values from the form and return into vars
//
// Parameters:
//
// Result:      Returns true if any of the fields are no zero
//- - - - - - - - - - - - - - - - - - - -
var
  ChartIndex : integer;
begin

  case TransactionType of
    ttDistribution : begin
    // ** Panel Distribution Panel **
      // Australian Income Tab
      if assigned( fmeDistributionFranking ) then begin
        mFranked := GetNumericValue(fmeDistributionFranking.nfFranked,              RevenuePercentage);
        mUnfranked := GetNumericValue(fmeDistributionFranking.nfUnfranked,            RevenuePercentage);
        mImputedCredit := GetNumericValue(fmeDistributionFranking.nfFrankingCredits,      RevenuePercentage);
      end;

      if assigned( fmeInterestIncome ) then begin
        mInterest := GetNumericValue(fmeInterestIncome.nfInterest,       RevenuePercentage);
        mOtherIncome := GetNumericValue(fmeInterestIncome.nfOtherIncome,    RevenuePercentage);
      end;
      mOtherTrustDeductions := GetNumericValue(nfLessOtherAllowableTrustDeductions,  RevenuePercentage);
      // Capital Gains Tab
      mCapitalGains := GetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTIndexation, RevenuePercentage);
      mDiscountedCapitalGains := GetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTDiscounted, RevenuePercentage);
      mCapitalGainsOther := GetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTOther, RevenuePercentage);
      mCGTConcessionAmount := GetNumericValue(nfCGTConcession,                      RevenuePercentage);

      mForeignCGTBeforeDiscount := GetNumericValue(nfForeignCGTBeforeDiscount,           RevenuePercentage);
      mForeignCGTIndexationMethod := GetNumericValue(nfForeignCGTIndexationMethod,         RevenuePercentage);
      mForeignCGTOtherMethod := GetNumericValue(nfForeignCGTOtherMethod,              RevenuePercentage);

      mTaxPaidBeforeDiscount := GetNumericValue(nfTaxPaidBeforeDiscount,              RevenuePercentage);
      mTaxPaidIndexationMethod := GetNumericValue(nfTaxPaidIndexationMethod,            RevenuePercentage);
      mTaxPaidOtherMethod := GetNumericValue(nfTaxPaidOtherMethod,                 RevenuePercentage);

      //Foreign Income Tab
      mForeignIncome := GetNumericValue(nfAssessableForeignSourceIncome,      RevenuePercentage);
      mOtherNetForeignSourceIncome := GetNumericValue(nfOtherNetForeignSourceIncome,        RevenuePercentage);
      mCashDistribution := GetNumericValue(nfCashDistribution,                   RevenuePercentage);

      if assigned( fmeBGLForeignTax1 ) then begin
        mForeignTaxCredits := GetNumericValue(fmeBGLForeignTax1.nfForeignIncomeTaxOffset, RevenuePercentage);
        mAUFrankingCreditsFromNZCompany := GetNumericValue(fmeBGLForeignTax1.nfAUFrankingCreditsFromNZCompany, RevenuePercentage);
        mTFNCredits := GetNumericValue(fmeBGLForeignTax1.nfTFNAmountsWithheld, RevenuePercentage);

        mNonResidentWithholdingTax := GetNumericValue(fmeBGLForeignTax1.nfNonResidentWithholdingTax, RevenuePercentage);

        mLICDeductions := GetNumericValue(fmeBGLForeignTax1.nfLICDeductions, RevenuePercentage);

      end;

      mTaxFreeDist := GetNumericValue(nfTaxFreeAmounts,                     RevenuePercentage);
      mTaxExemptDist := GetNumericValue(nfTaxExemptedAmounts,                 RevenuePercentage);
      mTaxDeferredDist := GetNumericValue(nfTaxDeferredAmounts,                 RevenuePercentage);
      mOtherExpenses := GetNumericValue(nfOtherExpenses,                      RevenuePercentage);

      //Non-Cash Capital Gains/Loses
      if assigned( fmeBGLNonCashCapitalGainsTax ) then begin
        mNon_Cash_CGT_Discounted_Before_Discount := GetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTDiscounted, RevenuePercentage);
        mNon_Cash_CGT_Indexation := GetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTIndexation, RevenuePercentage);
        mNon_Cash_CGT_Other := GetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTOther, RevenuePercentage);
      end;
      mNon_Cash_CGT_Capital_Losses := GetNumericValue(nfCGTCapitalLosses, RevenuePercentage);
    end;
    ttShareTrade : begin
    // ** Panel Share Trade Panel **
      mShareBrokerage := GetNumericValue(nfShareBrokerage,     RevenuePercentage);
      mShareConsideration := GetNumericValue(nfShareConsideration, RevenuePercentage);
      mShareGSTAmount := GetNumericValue(nfShareGSTAmount,     RevenuePercentage);

      mShareGSTRate := cmbxShareGSTRate.Properties.Items[ cmbxShareGSTRate.ItemIndex ];
    end;
    ttInterest : begin
    // ** Panel Interest Panel **
      mInterest := GetNumericValue(nfInterest,                  RevenuePercentage);
      mOtherIncome := GetNumericValue(nfOtherIncome,               RevenuePercentage);
      mTFNCredits := GetNumericValue(nfTFNAmountsWithheld,        RevenuePercentage);
      mNonResidentWithholdingTax := GetNumericValue(nfNonResidentWithholdingTax, RevenuePercentage);
    end;
    ttDividend : begin
    // ** Panel Dividend Panel **
      if assigned( fmeDividendFranking ) then begin
        mFranked := GetNumericValue(fmeDividendFranking.nfFranked,         RevenuePercentage);
        mUnfranked := GetNumericValue(fmeDividendFranking.nfUnfranked,       RevenuePercentage);
        mImputedCredit := GetNumericValue(fmeDividendFranking.nfFrankingCredits, RevenuePercentage);
      end;
      mForeignIncome := GetNumericValue(nfForeignIncome,                       RevenuePercentage);
      if assigned( fmeBGLForeignTax2 ) then begin
        mForeignTaxCredits := GetNumericValue(fmeBGLForeignTax2.nfForeignIncomeTaxOffset,         RevenuePercentage);
        mAUFrankingCreditsFromNZCompany := GetNumericValue(fmeBGLForeignTax2.nfAUFrankingCreditsFromNZCompany, RevenuePercentage);
        mTFNCredits := GetNumericValue(fmeBGLForeignTax2.nfTFNAmountsWithheld,             RevenuePercentage);
        mNonResidentWithholdingTax := GetNumericValue(fmeBGLForeignTax2.nfNonResidentWithholdingTax,      RevenuePercentage);
        mLICDeductions := GetNumericValue(fmeBGLForeignTax2.nfLICDeductions,                  RevenuePercentage);
      end;
    end;
  end;
(*DN Redundant Code  if cmbxAccount.ItemIndex > 0 then
  begin
    ChartIndex := Integer(cmbxAccount.Properties.Items.Objects[cmbxAccount.ItemIndex]);
    mAccount := MyClient.clChart.Account_At(ChartIndex).chAccount_Code;
  end
  else
    mAccount := ''; (*DN Redundant Code *)

  mAccount := edtAccount.Text;

(*DN Redundant Code *)

  mUnits := nfUnits.AsFloat * 10000;

  dCash_Date    := eCashDate.AsStDate;
  dAccrual_Date := eAccrualDate.AsStDate;
  dRecord_Date  := eRecordDate.AsStDate;

  Result := ( mImputedCredit <> 0) or
            ( mTaxFreeDist <> 0) or
            ( mTaxExemptDist <> 0) or
            ( mTaxDeferredDist <> 0) or
            ( mTFNCredits <> 0) or
            ( mForeignIncome <> 0) or
            ( mForeignTaxCredits <> 0) or
            ( mCapitalGains <> 0) or
            ( mDiscountedCapitalGains <> 0) or
            ( mOtherExpenses <> 0) or
            ( mCapitalGainsOther <> 0) or
            ( mFranked <> 0) or
            ( mUnfranked <> 0) or
            ( mInterest <> 0) or
            ( mOtherIncome <> 0) or
            ( mOtherTrustDeductions <> 0) or
            ( mCGTConcessionAmount <> 0) or
            ( mForeignCGTBeforeDiscount <> 0) or
            ( mForeignCGTIndexationMethod <> 0) or
            ( mForeignCGTOtherMethod <> 0) or
            ( mTaxPaidBeforeDiscount <> 0) or
            ( mTaxPaidIndexationMethod <> 0) or
            ( mTaxPaidOtherMethod <> 0) or
            {mCapitalGainsForeignDisc,}
            ( mOtherNetForeignSourceIncome <> 0) or
            ( mCashDistribution <> 0) or
            ( mAUFrankingCreditsFromNZCompany <> 0) or
            ( mNonResidentWithholdingTax <> 0) or
            ( mLICDeductions <> 0) or
            ( mNon_Cash_CGT_Discounted_Before_Discount <> 0) or
            ( mNon_Cash_CGT_Indexation <> 0) or
            ( mNon_Cash_CGT_Other <> 0) or
            ( mNon_Cash_CGT_Capital_Losses <> 0) or
            ( mShareBrokerage <> 0) or
            ( mShareConsideration <> 0) or
            ( mShareGSTAmount <> 0) or
            ( dCGTDate <> 0) or
            ( mComponent <> 0) or
            ( mUnits <> 0) or
            ( mAccount <>  '' ) or
            ( mShareGSTRate <> '' ) or
            ( dCash_Date <> 0) or
            ( dAccrual_Date <> 0) or
            ( dRecord_Date <> 0);
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditBGLSF360Fields.SetFields(
            mImputedCredit,
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
            mUnfranked,
            mInterest,
            mOtherIncome,
            mOtherTrustDeductions,
            mCGTConcessionAmount,
            mForeignCGTBeforeDiscount,
            mForeignCGTIndexationMethod,
            mForeignCGTOtherMethod,
            mTaxPaidBeforeDiscount,
            mTaxPaidIndexationMethod,
            mTaxPaidOtherMethod,
            (* mCapitalGainsForeignDisc, *)
            mOtherNetForeignSourceIncome,
            mCashDistribution,
            mAUFrankingCreditsFromNZCompany,
            mNonResidentWithholdingTax,
            mLICDeductions,
            mNon_Cash_CGT_Discounted_Before_Discount,
            mNon_Cash_CGT_Indexation,
            mNon_Cash_CGT_Other,
            mNon_Cash_CGT_Capital_Losses,
            mShareBrokerage,
            mShareConsideration,
            mShareGSTAmount: Money;
            dCGTDate: integer;
            mComponent : byte;
            mUnits: Money;
            mAccount,
            mShareGSTRate: shortstring;
            dCash_Date,
            dAccrual_Date,
            dRecord_Date : integer
            );
begin

// ** Panel Distribution Panel **
  // Australian Income Tab
  if assigned( fmeDistributionFranking ) then begin
    SetNumericValue(fmeDistributionFranking.nfFranked,              mFranked, RevenuePercentage);
    SetNumericValue(fmeDistributionFranking.nfUnfranked,            mUnfranked, RevenuePercentage);
    SetNumericValue(fmeDistributionFranking.nfFrankingCredits,      mImputedCredit, RevenuePercentage);
  end;

  if assigned( fmeInterestIncome ) then begin
    SetNumericValue(fmeInterestIncome.nfInterest,       mInterest, RevenuePercentage);
    SetNumericValue(fmeInterestIncome.nfOtherIncome,    mOtherIncome, RevenuePercentage);
  end;
  SetNumericValue(nfLessOtherAllowableTrustDeductions,  mOtherTrustDeductions, RevenuePercentage);

  // Capital Gains Tab
  SetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTIndexation,
    mCapitalGains, RevenuePercentage);
  SetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTDiscounted,
    mDiscountedCapitalGains, RevenuePercentage);
  SetNumericValue(fmeBGLCashCapitalGainsTax.nfCGTOther,
    mCapitalGainsOther, RevenuePercentage);
  SetNumericValue(nfCGTConcession,                      mCGTConcessionAmount, RevenuePercentage);

  SetNumericValue(nfForeignCGTBeforeDiscount,           mForeignCGTBeforeDiscount, RevenuePercentage);
  SetNumericValue(nfForeignCGTIndexationMethod,         mForeignCGTIndexationMethod, RevenuePercentage);
  SetNumericValue(nfForeignCGTOtherMethod,              mForeignCGTOtherMethod, RevenuePercentage);

  SetNumericValue(nfTaxPaidBeforeDiscount,              mTaxPaidBeforeDiscount, RevenuePercentage);
  SetNumericValue(nfTaxPaidIndexationMethod,            mTaxPaidIndexationMethod, RevenuePercentage);
  SetNumericValue(nfTaxPaidOtherMethod,                 mTaxPaidOtherMethod, RevenuePercentage);

  //Foreign Income Tab
  SetNumericValue(nfAssessableForeignSourceIncome,      mForeignIncome, RevenuePercentage);
  SetNumericValue(nfOtherNetForeignSourceIncome,        mOtherNetForeignSourceIncome, RevenuePercentage);
  SetNumericValue(nfCashDistribution,                   mCashDistribution, RevenuePercentage);

  if assigned( fmeBGLForeignTax1 ) then begin
    SetNumericValue(fmeBGLForeignTax1.nfForeignIncomeTaxOffset,
      mForeignTaxCredits, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax1.nfAUFrankingCreditsFromNZCompany,
      mAUFrankingCreditsFromNZCompany, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax1.nfTFNAmountsWithheld,
      mTFNCredits, RevenuePercentage);

    SetNumericValue(fmeBGLForeignTax1.nfNonResidentWithholdingTax,
      mNonResidentWithholdingTax, RevenuePercentage);

    SetNumericValue(fmeBGLForeignTax1.nfLICDeductions,
      mLICDeductions, RevenuePercentage);

  end;

  SetNumericValue(nfTaxFreeAmounts,                     mTaxFreeDist, RevenuePercentage);
  SetNumericValue(nfTaxExemptedAmounts,                 mTaxExemptDist, RevenuePercentage);
  SetNumericValue(nfTaxDeferredAmounts,                 mTaxDeferredDist, RevenuePercentage);
  SetNumericValue(nfOtherExpenses,                      mOtherExpenses, RevenuePercentage);

  //Non-Cash Capital Gains/Loses
  if assigned( fmeBGLNonCashCapitalGainsTax ) then begin
    SetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTDiscounted,
      mNon_Cash_CGT_Discounted_Before_Discount, RevenuePercentage);
    SetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTIndexation,
      mNon_Cash_CGT_Indexation, RevenuePercentage);
    SetNumericValue(fmeBGLNonCashCapitalGainsTax.nfCGTOther,
      mNon_Cash_CGT_Other, RevenuePercentage);
  end;
  SetNumericValue(nfCGTCapitalLosses, mNon_Cash_CGT_Capital_Losses, RevenuePercentage);

// ** Panel Share Trade Panel **
  SetNumericValue(nfShareBrokerage,     mShareBrokerage, RevenuePercentage);
  SetNumericValue(nfShareConsideration, mShareConsideration, RevenuePercentage);
  SetNumericValue(nfShareGSTAmount,     mShareGSTAmount, RevenuePercentage);
  cmbxShareGSTRate.ItemIndex := cmbxShareGSTRate.Properties.Items.IndexOf(mShareGSTRate);

// ** Panel Interest Panel **
  SetNumericValue(nfInterest,                  mInterest, RevenuePercentage);
  SetNumericValue(nfOtherIncome,               mOtherIncome, RevenuePercentage);
  SetNumericValue(nfTFNAmountsWithheld,        mTFNCredits, RevenuePercentage);
  SetNumericValue(nfNonResidentWithholdingTax, mNonResidentWithholdingTax, RevenuePercentage);

// ** Panel Dividend Panel **
  if assigned( fmeDividendFranking ) then begin
    SetNumericValue(fmeDividendFranking.nfFranked,         mFranked, RevenuePercentage);
    SetNumericValue(fmeDividendFranking.nfUnfranked,       mUnfranked, RevenuePercentage);
    SetNumericValue(fmeDividendFranking.nfFrankingCredits, mImputedCredit, RevenuePercentage);
  end;
  SetNumericValue(nfForeignIncome,                       mForeignIncome, RevenuePercentage);
  if assigned( fmeBGLForeignTax2 ) then begin
    SetNumericValue(fmeBGLForeignTax2.nfForeignIncomeTaxOffset,         mForeignTaxCredits, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax2.nfAUFrankingCreditsFromNZCompany, mAUFrankingCreditsFromNZCompany, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax2.nfTFNAmountsWithheld,             mTFNCredits, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax2.nfNonResidentWithholdingTax,      mNonResidentWithholdingTax, RevenuePercentage);
    SetNumericValue(fmeBGLForeignTax2.nfLICDeductions,                  mLICDeductions, RevenuePercentage);
  end;

  TranAccount := mAccount;

  edtAccount.Text := mAccount;
  edtAccount.Hint := MyClient.clChart.FindDesc( mAccount );


  UFModified := ((mFranked <> 0) or (mUnfranked <> 0))
             and ((mFranked + mUnfranked) <> abs(FActualAmount));


  if not MemOnly then  begin
     SetNumericValue(fmeDistributionFranking.nfFrankingCredits, mImputedCredit, False);
     frameFrankingFrankingCreditsChange(fmeDistributionFranking.nfFrankingCredits);
     SetNumericValue(nfTFNAmountsWithheld,        mTFNCredits, false);
     if assigned( fmeBGLForeignTax1 ) then begin
// DN Not sure if these on fmeBGLForeignTax1 and fmeBGLForeignTax2 map?
       SetNumericValue(fmeBGLForeignTax1.nfTFNAmountsWithheld,      mTFNCredits, RevenuePercentage);
       SetNumericValue(fmeBGLForeignTax1.nfForeignIncomeTaxOffset,  mForeignTaxCredits, RevenuePercentage);
     end;
     if assigned( fmeBGLForeignTax2 ) then begin
// DN Not sure if these on fmeBGLForeignTax2 and fmeBGLForeignTax1 map?
       SetNumericValue(fmeBGLForeignTax2.nfTFNAmountsWithheld,      mTFNCredits, RevenuePercentage);
       SetNumericValue(fmeBGLForeignTax2.nfForeignIncomeTaxOffset,  mForeignTaxCredits, RevenuePercentage);
     end;
  end;


// DN Not sure about whether these map?
  eCashDate.AsStDate    := BkNull2St(dCash_Date);
  eAccrualDate.AsStDate := BkNull2St(dAccrual_Date);
  eRecordDate.AsStDate  := BkNull2St(dRecord_Date);


  nfUnits.AsFloat := mUnits / 10000;

  TranAccount := mAccount;
//DN Redundant Code  RefreshChartCodeCombo();
//DN Redundant Code  FCurrentAccountIndex := cmbxAccount.ItemIndex;

  FAutoPressMinus := (FActualAmount < 0) and (mUnits = 0);
end;

function TdlgEditBGLSF360Fields.GetFrankPercentage: boolean;
begin
  result := false;
  if assigned( fmeDistributionFranking ) then begin
    result := fmeDistributionFranking.FrankPercentage;
    if assigned( fmeDividendFranking ) then
      result := result and fmeDividendFranking.FrankPercentage;
  end;
end;

procedure TdlgEditBGLSF360Fields.SetFrankPercentage(const Value: boolean);
begin
  FFrankPercentage := Value;
  if assigned( fmeDistributionFranking ) then
    fmeDistributionFranking.FrankPercentage := Value;
  if assigned( fmeDividendFranking ) then
    fmeDividendFranking.FrankPercentage := Value;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditBGLSF360Fields.FormCreate(Sender: TObject);
{///////////////////////////////////////////////////////////////////////////////
!!!!  NB!! Active panel must NOT be set to Distribution, as it causes an AV !!!!
///////////////////////////////////////////////////////////////////////////////}
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

  FMoveDirection := fnNothing;
  FormTop := -999;
  FormLeft := -999;
  UFModified := False;
  FSkip := 0;
  Glyph := TBitMap.Create;
  ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
end;

procedure TdlgEditBGLSF360Fields.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Glyph);
end;

procedure TdlgEditBGLSF360Fields.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F2) or ((Key = Ord('L')) and (Shift = [ssCtrl])) then
    btnChartClick(Sender);
end;

procedure TdlgEditBGLSF360Fields.FormShow(Sender: TObject);
begin
  if FTop > -999 then begin
     Top := FTop;
     Left := FLeft;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditBGLSF360Fields.SetInfo( iDate : integer; sNarration: string; mAmount : Money);
var i: Integer;
begin
  lbldispDate.Caption := BkDate2Str( iDate);
  if RevenuePercentage then begin
     lbldispAmount.Caption := '100%';
     lblAmount.Caption := 'Total';
  end
  else begin
    lbldispAmount.Caption := Money2Str( mAmount);
    lblAmount.Caption := 'Amount';
  end;
  lbldispNarration.Caption := sNarration;
  FActualAmount := mAmount;
  FDate := iDate;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditBGLSF360Fields.btnBackClick(Sender: TObject);
begin
  FMoveDirection := fnGoBack;
  ModalResult := mrOk;
end;

function BGL360AccountsFilter(const pAcct : pAccount_Rec) : boolean;
begin
  result := ( pos( intToStr( cttanDistribution ), pAcct.chAccount_Code ) <> 0 ) or
            ( pos( intToStr( cttanDividend ), pAcct.chAccount_Code ) <> 0  ) or
            ( pos( intToStr( cttanInterest ), pAcct.chAccount_Code ) <> 0  ) or
            ( IsStringNumberInIntegerRange(
                cttanShareTradeRangeStart,
                cttanShareTradeRangeEnd,
                pAcct.chAccount_Code )
            );
end;


procedure TdlgEditBGLSF360Fields.btnChartClick(Sender: TObject);
var
  i: Integer;
  SelectedCode: string;
  HasChartBeenRefreshed : boolean;
begin
(*DN Redundant Code*) //  SelectedCode := cmbxAccount.Text;
  SelectedCode := edtAccount.Text;
(*DN Redundant Code*)

  if PickAccount(SelectedCode, HasChartBeenRefreshed, BGL360AccountsFilter, true, true, [ doShowInactive ]) then
  begin
    edtAccount.Text := SelectedCode;
    edtAccount.Hint := MyClient.clChart.FindDesc( SelectedCode );
    TranAccount := SelectedCode;

(*DN Redundant Code    if HasChartBeenRefreshed then
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
    end; (*DN Redundant Code*)
  end;
end;

procedure TdlgEditBGLSF360Fields.btnClearClick(Sender: TObject);
begin
  SetFields ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 0, 0, 0 );

  UFModified := False;
end;

procedure TdlgEditBGLSF360Fields.btnNextClick(Sender: TObject);
begin
  FMoveDirection := fnGoForward;
  ModalResult := mrOk;
end;

procedure TdlgEditBGLSF360Fields.edtAccountChange(Sender: TObject);
var
  Edit: TEdit;
  pAcct: pAccount_Rec;
begin
  CheckforMaskChar( TEdit( Sender),RemovingMask);
(*DN Redundant Code*)//DN Redundant  UpdateLinkedAccounts;

  // Set background color
  Edit := (Sender as TEdit);
  pAcct := MyClient.clChart.FindCode(Edit.Text);
  if assigned(pAcct) and pAcct.chInactive then
    Edit.Color := clYellow
  else
    Edit.Color := clWindow;
end;

procedure TdlgEditBGLSF360Fields.edtAccountKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = vk_back then CheckRemoveMaskChar( TEdit(Sender),RemovingMask);
end;

procedure TdlgEditBGLSF360Fields.edtAccountKeyPress(Sender: TObject;
  var Key: Char);
var
  aType : Integer;
begin
  if ((key='-') and (myClient.clFields.clUse_Minus_As_Lookup_Key)) then
  begin
    key := #0;
(*DN Redundant Code    aType := GetCurrentlySelectedGroup;
    case aType of
      atOpeningStock : PickCodeForEdit(Sender, ClosingStockFilter, False);
      atClosingStock : PickCodeForEdit(Sender, OpeningStockFilter, False);
      atStockOnHand  : PickCodeForEdit(Sender, OpeningStockFilter, False);
    end; DN*)
  end;
end;

procedure TdlgEditBGLSF360Fields.edtAccountKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  aType : Integer;
begin
  if (key = VK_F2) or ((key=40) and (Shift = [ssAlt])) then
  begin
(*DN Redundant Code    aType := GetCurrentlySelectedGroup;
    case aType of
      atOpeningStock : PickCodeForEdit(Sender, ClosingStockFilter, False);
      atClosingStock : PickCodeForEdit(Sender, OpeningStockFilter, False);
      atStockOnHand  : PickCodeForEdit(Sender, OpeningStockFilter, False);
    end; DN*)
  end;
end;


procedure TdlgEditBGLSF360Fields.cmbxAccountKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DOWN) or (Key = VK_NEXT) then
    FSkip := 1
  else if (Key = VK_UP) or (Key = VK_PRIOR) then
    FSkip := -1
  else
    FSkip := 0;
end;

procedure TdlgEditBGLSF360Fields.cmbxAccountPropertiesChange(Sender: TObject);
var
  p: pAccount_Rec;
  ChartIndex : integer;
begin
  if cmbxAccount.ItemIndex < 1 then
    if cmbxAccount.ItemIndex = 0 then begin
      TranAccount := '';
    end
    else
      exit;

  ChartIndex := Integer(cmbxAccount.Properties.Items.Objects[cmbxAccount.ItemIndex]);

  p := MyClient.clChart.Account_At(ChartIndex);
  if not p^.chPosting_Allowed then
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
  else begin
    FCurrentAccountIndex := cmbxAccount.ItemIndex;
    TranAccount := p^.chAccount_Code; //DN Set the TranAccount code so that the screen will refresh;
  end;
  FSkip := 0;
end;

procedure TdlgEditBGLSF360Fields.cmbxAccountPropertiesDrawItem(
  AControl: TcxCustomComboBox; ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState);
var
  p: pAccount_Rec;
  l: Integer;
  R: TRect;
  ChartIndex : integer;
begin
  if AIndex = 0 then exit;
  R := ARect;

  ChartIndex := Integer(cmbxAccount.Properties.Items.Objects[AIndex]);
  p := MyClient.clChart.Account_At(ChartIndex);
  ACanvas.fillrect(ARect);
  l := 2;
  if not p.chPosting_Allowed then
  begin
    ACanvas.DrawGlyph(R.Left, R.Top, Glyph);
    l := 15;
  end;
  R.Left := R.Left + l;
  R.Right := R.Right - l;
  ACanvas.DrawText(p.chAccount_Code, R, 0, p.chPosting_Allowed);
//  R.Left := R.Left + 135 - l;
//  R.Right := R.Right + 135 - l;
  R.Left := R.Left + 135 - l;
  R.Right := R.Right - l;
  ACanvas.DrawText('(' + p.chAccount_Description + ')', R, 0, p.chPosting_Allowed);
end;

procedure TdlgEditBGLSF360Fields.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;

  if assigned( fmeDistributionFranking ) then begin
    fmeDistributionFranking.nfFranked.Enabled := not Value;
    fmeDistributionFranking.nfUnfranked.Enabled := not Value;
    fmeDistributionFranking.nfFrankingCredits.Enabled := not (FReadOnly or MemOnly);
    fmeDistributionFranking.btnFrankingCredits.Enabled := not Value;
  end;

  if assigned( fmeInterestIncome ) then begin
    fmeInterestIncome.nfInterest.Enabled := not Value;
    fmeInterestIncome.nfOtherIncome.Enabled := not Value;
  end;
  nfLessOtherAllowableTrustDeductions.Enabled := not Value;

  // Capital Gains Tab
  fmeBGLCashCapitalGainsTax.nfCGTIndexation.Enabled := not Value;
  fmeBGLCashCapitalGainsTax.nfCGTDiscounted.Enabled := not Value;
  fmeBGLCashCapitalGainsTax.nfCGTOther.Enabled := not Value;
  nfCGTConcession.Enabled := not Value;

  nfForeignCGTBeforeDiscount.Enabled := not Value;
  nfForeignCGTIndexationMethod.Enabled := not Value;
  nfForeignCGTOtherMethod.Enabled := not Value;

  nfTaxPaidBeforeDiscount.Enabled := not Value;
  nfTaxPaidIndexationMethod.Enabled := not Value;
  nfTaxPaidOtherMethod.Enabled := not Value;

  //Foreign Income Tab
  nfAssessableForeignSourceIncome.Enabled := not Value;
  nfOtherNetForeignSourceIncome.Enabled := not Value;
  nfCashDistribution.Enabled := not Value;

  if assigned( fmeBGLForeignTax1 ) then begin
    fmeBGLForeignTax1.nfForeignIncomeTaxOffset.Enabled := not Value;
    fmeBGLForeignTax1.nfAUFrankingCreditsFromNZCompany.Enabled := not Value;
    fmeBGLForeignTax1.nfTFNAmountsWithheld.Enabled := not Value;

    fmeBGLForeignTax1.nfNonResidentWithholdingTax.Enabled := not Value;

    fmeBGLForeignTax1.nfLICDeductions.Enabled := not Value;
  end;

  nfTaxFreeAmounts.Enabled := not Value;
  nfTaxExemptedAmounts.Enabled := not Value;
  nfTaxDeferredAmounts.Enabled := not Value;
  nfOtherExpenses.Enabled := not Value;

  //Non-Cash Capital Gains/Loses
  if assigned( fmeBGLNonCashCapitalGainsTax ) then begin
    fmeBGLNonCashCapitalGainsTax.nfCGTDiscounted.Enabled := not Value;
    fmeBGLNonCashCapitalGainsTax.nfCGTIndexation.Enabled := not Value;
    fmeBGLNonCashCapitalGainsTax.nfCGTOther.Enabled := not Value;
  end;
  nfCGTCapitalLosses.Enabled := not Value;

// ** Panel Share Trade Panel **
  nfShareBrokerage.Enabled := not Value;
  nfShareConsideration.Enabled := not Value;
  nfShareGSTAmount.Enabled := not Value;
  cmbxShareGSTRate.Enabled := not Value;

// ** Panel Interest Panel **
  nfInterest.Enabled := not Value;
  nfOtherIncome.Enabled := not Value;
  nfTFNAmountsWithheld.Enabled := not Value;
  nfNonResidentWithholdingTax.Enabled := not Value;

// ** Panel Dividend Panel **
  if assigned( fmeDividendFranking ) then begin
    fmeDividendFranking.nfFranked.Enabled := not Value;
    fmeDividendFranking.nfUnfranked.Enabled := not Value;
    fmeDividendFranking.nfFrankingCredits.Enabled := not Value;
    fmeDividendFranking.btnFrankingCredits.Enabled := not Value;
  end;
  nfForeignIncome.Enabled := not Value;
  if assigned( fmeBGLForeignTax2 ) then begin
    fmeBGLForeignTax2.nfForeignIncomeTaxOffset.Enabled := not Value;
    fmeBGLForeignTax2.nfAUFrankingCreditsFromNZCompany.Enabled := not Value;
    fmeBGLForeignTax2.nfTFNAmountsWithheld.Enabled := not Value;
    fmeBGLForeignTax2.nfNonResidentWithholdingTax.Enabled := not Value;
    fmeBGLForeignTax2.nfLICDeductions.Enabled := not Value;
  end;


  if not MemOnly then  begin
     fmeDistributionFranking.nfFrankingCredits.Enabled := not Value;
     nfTFNAmountsWithheld.Enabled := not Value;
     if assigned( fmeBGLForeignTax1 ) then begin
// DN Not sure if these on fmeBGLForeignTax1 and fmeBGLForeignTax2 map?
       fmeBGLForeignTax1.nfTFNAmountsWithheld.Enabled := not Value;
       fmeBGLForeignTax1.nfForeignIncomeTaxOffset.Enabled := not Value;
     end;
     if assigned( fmeBGLForeignTax2 ) then begin
// DN Not sure if these on fmeBGLForeignTax2 and fmeBGLForeignTax1 map?
       fmeBGLForeignTax2.nfTFNAmountsWithheld.Enabled := not Value;
       fmeBGLForeignTax2.nfForeignIncomeTaxOffset.Enabled := not Value;
     end;
  end;


// DN Not sure about whether these map?
  eCashDate.Enabled := not Value;
  eAccrualDate.Enabled := not Value;
  eRecordDate.Enabled := not Value;


  nfUnits.Enabled := not Value;

  cmbxAccount.Enabled := not Value;

  btnChart.Enabled           := not Value;
  btnClear.Enabled           := not Value;
end;

procedure TdlgEditBGLSF360Fields.SetRevenuePercentage(const Value: boolean);
begin
   FRevenuePercentage := Value;

   SetPercentLabel(lpLessOtherAllowableTrustDeductions, FRevenuePercentage);
   SetPercentLabel(lpCGTConcession, FRevenuePercentage);
   SetPercentLabel(lpCGTCapitalLosses, FRevenuePercentage);
   SetPercentLabel(lpAssessableForeignSourceIncome, FRevenuePercentage);
   SetPercentLabel(lpOtherNetForeignSourceIncome, FRevenuePercentage);
   SetPercentLabel(lpCashDistribution, FRevenuePercentage);
   SetPercentLabel(lpTaxExemptedAmounts, FRevenuePercentage);
   SetPercentLabel(lpTaxFreeAmounts, FRevenuePercentage);
   SetPercentLabel(lpTaxDeferredAmounts, FRevenuePercentage);
   SetPercentLabel(lpForeignIncome, FRevenuePercentage);
   SetPercentLabel(lpInterest, FRevenuePercentage);
   SetPercentLabel(lpOtherIncome, FRevenuePercentage);
   SetPercentLabel(lpTFNAmountsWithheld, FRevenuePercentage);
   SetPercentLabel(lpNonResidentWithholdingTax, FRevenuePercentage);
   SetPercentLabel(lpShareBrokerage, FRevenuePercentage);
   SetPercentLabel(lpShareConsideration, FRevenuePercentage);
   SetPercentLabel(lpShareGSTAmount, FRevenuePercentage);
   SetPercentLabel(lpShareTradeUnits, FRevenuePercentage);
   SetPercentLabel(lpOtherExpenses, FRevenuePercentage);

   SetPercentLabel(fmeDistributionFranking.lpFranked, FRevenuePercentage);
   SetPercentLabel(fmeDistributionFranking.lpUnfranked, FRevenuePercentage);

   SetPercentLabel(fmeInterestIncome.lpInterest, FRevenuePercentage);
   SetPercentLabel(fmeInterestIncome.lpOtherIncome, FRevenuePercentage);

   SetPercentLabel(fmeBGLCashCapitalGainsTax.lpCGTDiscounted, FRevenuePercentage);
   SetPercentLabel(fmeBGLCashCapitalGainsTax.lpCGTIndexation, FRevenuePercentage);
   SetPercentLabel(fmeBGLCashCapitalGainsTax.lpCGTOther, FRevenuePercentage);


   SetPercentLabel(fmeBGLNonCashCapitalGainsTax.lpCGTDiscounted, FRevenuePercentage);
   SetPercentLabel(fmeBGLNonCashCapitalGainsTax.lpCGTIndexation, FRevenuePercentage);
   SetPercentLabel(fmeBGLNonCashCapitalGainsTax.lpCGTOther, FRevenuePercentage);

   SetPercentLabel(fmeBGLForeignTax1.lpForeignIncomeTaxOffset, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax1.lpAUFrankingCreditsFromNZCompany, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax1.lpTFNAmountsWithheld, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax1.lpNonResidentWithholdingTax, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax1.lpLICDeductions, FRevenuePercentage);

   SetPercentLabel(fmeBGLForeignTax2.lpForeignIncomeTaxOffset, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax2.lpAUFrankingCreditsFromNZCompany, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax2.lpTFNAmountsWithheld, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax2.lpNonResidentWithholdingTax, FRevenuePercentage);
   SetPercentLabel(fmeBGLForeignTax2.lpLICDeductions, FRevenuePercentage);

   SetPercentLabel(fmeDividendFranking.lpFranked, FRevenuePercentage);
   SetPercentLabel(fmeDividendFranking.lpUnfranked, FRevenuePercentage);
end;

procedure TdlgEditBGLSF360Fields.SetTranAccount(const Value: string);
var
  liControlCode : integer;
begin
  fTranAccount := Value;
  try
    if trim( Value ) <> '' then
      liControlCode := StripBGL360ControlAccountCode( fTranAccount )
    else
      liControlCode := -1;
    case liControlCode of
      cttanDistribution      : TransactionType := ttDistribution;
      cttanDividend          : TransactionType := ttDividend;
      cttanInterest          : TransactionType := ttInterest;
      cttanShareTradeRangeStart..cttanShareTradeRangeEnd : TransactionType := ttShareTrade;
      else
        TransactionType := ttOtherTx;
    end;
  except
    on e:Exception do
      raise Exception.Create( 'Invalid Account Code: '  + fTranAccount );
  end;
end;

procedure TdlgEditBGLSF360Fields.SetTransactionType(
  const Value: TTransactionTypes);

  procedure SetFields( aFields : array of TControl; aVisible : boolean );
  var
    i : integer;
  begin
    for i := 0 to high( aFields ) do
      aFields[ i ].Visible := aVisible;
  end;

  procedure ShowAllHeaderFields;
  begin
    SetFields( [ lblCashDate, eCashDate,
      lblAccrualDate, eAccrualDate, lblRecordDate, eRecordDate, lblEntryType,
      sfEntryType ], true );
  end;

  procedure HideAllHeaderFields;
  begin
    SetFields( [ lblCashDate, eCashDate,
      lblAccrualDate, eAccrualDate, lblRecordDate, eRecordDate, lblEntryType,
      sfEntryType ], false );
  end;

  procedure Configure_Distribution;
  begin
    pnlDistribution.Visible := true;
    pnlDividend.Visible     := false;
    pnlInterest.Visible     := false;
    pnlShareTrade.Visible   := false;
  end;

  procedure Configure_Dividend;
  begin
    pnlDistribution.Visible := false;
    pnlDividend.Visible     := true;
    pnlInterest.Visible     := false;
    pnlShareTrade.Visible   := false;
  end;

  procedure Configure_Interest;
  begin
    pnlDistribution.Visible := false;
    pnlDividend.Visible     := false;
    pnlInterest.Visible     := true;
    pnlShareTrade.Visible   := false;
  end;

  procedure Configure_ShareTrade;
  begin
    pnlDistribution.Visible := false;
    pnlDividend.Visible     := false;
    pnlInterest.Visible     := false;
    pnlShareTrade.Visible   := true;
  end;

  procedure Configure_OtherTX;
  begin
    pnlDistribution.Visible := false;
    pnlDividend.Visible     := false;
    pnlInterest.Visible     := false;
    pnlShareTrade.Visible   := false;
  end;

  procedure SetupFields( const Value: TTransactionTypes );
  begin
    ShowAllHeaderFields;
    lblCashDate.Caption   := 'Cash Date';
    lblRecordDate.Caption := 'Record Date';
    lblCashDate.Left      := 510;
    lblRecordDate.Left    := 510;
    case Value of
      ttDistribution : begin
        sfEntryType.Text        := 'Distribution';
        Configure_Distribution;
      end;
      ttDividend     : begin
        sfEntryType.Text        := 'Dividend';
        Configure_Dividend;
      end;
      ttInterest     : begin
        sfEntryType.Text      := 'Interest';
        SetFields( [ lblCashDate, eCashDate, lblAccrualDate, eAccrualDate,
          lblRecordDate, eRecordDate ], false );
        Configure_Interest;
      end;
      ttShareTrade   : begin
        sfEntryType.Text      := 'Share Trade';
        lblCashDate.Caption   := 'Contract Date';
        lblRecordDate.Caption := 'Settlement Date';
        lblCashDate.Left      := 490;
        lblRecordDate.Left    := 490;
        SetFields( [ lblAccrualDate, eAccrualDate ], false );
        Configure_ShareTrade;
      end;
      ttOtherTx      : begin
        sfEntryType.Text        := 'Other';
        HideAllHeaderFields;
        Configure_OtherTX;
      end;
      else begin
      end;
    end;
  end;

begin
  try
    SetupFields( Value );
  finally
    fTransactionType := Value;
  end;
end;

procedure TdlgEditBGLSF360Fields.SetUpHelp;
begin
  Self.ShowHint    := INI_ShowFormHints;
  btnBack.Hint := 'Goto previous line|' +
                  'Goto previous line';

  btnNext.Hint := 'Goto next line|' +
                  'Goto next line';

  if assigned( fmeDividendFranking ) then
    fmeDividendFranking.btnFrankingCredits.Hint := 'Calculate the Imputed Credit|' +
       'Calculate the Imputed Credit';

  btnChart.Hint :=  '(F2) Lookup Chart|(F2) Lookup Chart';

  cmbxAccount.Hint := 'Select Chart code|Select Chart code';
  edtAccount.Hint := 'Select Chart code|Select Chart code';
end;

procedure TdlgEditBGLSF360Fields.frameFrankingbtnCalcClick(Sender: TObject);
begin
    crModified := False;
    frameFrankingFrankingCreditsChange( Sender );
end;

procedure TdlgEditBGLSF360Fields.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);

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

    CGTDate := stNull2Bk( eAccrualDate.AsStDate);

    if not ( DateIsValid( eAccrualDate.AsString) or (CGTDate = 0)) then
    begin
      HelpfulWarningMSg( 'Please enter a valid Accrual date.', 0);
      Exit;
    end;

    if (CGTDate <> 0) and ((CGTDate < MinValidDate) or (CGTDate > MaxValidDate)) then
    begin
      HelpfulWarningMsg( 'Please enter a valid Accrual date.', 0);
      Exit;
    end;

    if not ValueIsValid( fmeDistributionFranking.nfFrankingCredits) then
      Exit;
    if not ValueIsValid( nfTFNAmountsWithheld) then
      Exit;
    if not ValueIsValid( nfOtherExpenses) then
      Exit;

    if (TransactionType = ttDistribution) and
         not ValueIsValid( fmeBGLForeignTax1.nfForeignIncomeTaxOffset) then
      Exit;
    if (TransactionType = ttDividend) and
         not ValueIsValid( fmeBGLForeignTax2.nfForeignIncomeTaxOffset) then
      Exit;

    if not ValueIsValid( fmeBGLCashCapitalGainsTax.nfCGTDiscounted ) then
      Exit;
    if not ValueIsValid( fmeBGLCashCapitalGainsTax.nfCGTOther) then
      Exit;
    if not ValueIsValid( fmeBGLCashCapitalGainsTax.nfCGTIndexation) then
      Exit;
    if not ValueIsValid( fmeDistributionFranking.nfFranked) then
      Exit;
    if not ValueIsValid( fmeDistributionFranking.nfUnFranked) then
      Exit;

    //no problems, allow close
    CanClose := true;
  end;
end;

procedure TdlgEditBGLSF360Fields.frameFrankingFrankingCreditsChange(Sender: TObject);
var
  Frank: Double;
  FrankingFrame : TfmeBGLFranking;
begin
  if ( Sender is TComponent ) then
    if ( ( Sender as TComponent ).Owner is TfmeBGLFranking ) then begin
      FrankingFrame := ( ( Sender as TComponent ).Owner as TfmeBGLFranking );

      if FrankPercentage then
        Frank := FrankingFrame.nfFranked.asFloat{ * Money2Double(FActualAmount) / 100}
      else
        Frank := FrankingFrame.nfFranked.asFloat;

      crModified := CheckFrankingCredit( Frank, fDate, FrankingFrame.nfFrankingCredits,
                      not((Sender = FrankingFrame.nfFrankingCredits) or crModified));
    end;
end;

procedure TdlgEditBGLSF360Fields.nfTFNCreditsKeyPress(Sender: TObject;
  var Key: Char);
begin
  //ignore minus key
  if Key = '-' then
    Key := #0;
end;

procedure TdlgEditBGLSF360Fields.frameFrankingFrankedChange(Sender: TObject);
var
  Actual: Double;
  FrankingFrame : TfmeBGLFranking;
begin
//DN BGL360 Extended Fields
//  Add checks for other Franking Frame
//DN BGL360 Extended Fields

  if ( Sender is TComponent ) then
    if ( ( Sender as TComponent ).Owner is TfmeBGLFranking ) then begin
      FrankingFrame := ( ( Sender as TComponent ).Owner as TfmeBGLFranking );
      if not UFModified then begin
        if FrankPercentage then
          Actual := 100.0
        else
          Actual := Money2Double(FActualAmount);
        if sender = FrankingFrame.nfFranked then
          CalcFrankAmount(Actual,FrankingFrame.nfFranked,FrankingFrame.nfUnFranked)
        else
          CalcFrankAmount(Actual,FrankingFrame.nfUnFranked,FrankingFrame.nfFranked)
      end;
      frameFrankingFrankingCreditsChange(Sender);
    end;
end;

procedure TdlgEditBGLSF360Fields.frameFrankingUnfrankedChange(Sender: TObject);
begin
  UFModified := True;
end;

procedure TdlgEditBGLSF360Fields.nfUnitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FAutoPressMinus then
    keybd_event(vk_subtract,0,0,0);
  FAutoPresSMinus := False;
end;


procedure TdlgEditBGLSF360Fields.RefreshChartCodeCombo();
var
  ChartIndex : integer;
  pChartAcc : pAccount_Rec;
begin
  cmbxAccount.Properties.Items.Add('');
  for ChartIndex := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    pChartAcc := MyClient.clChart.Account_At(ChartIndex);

    if (pChartAcc.chInactive) and                     // Check the account is not inactive
       (TranAccount <> pChartAcc.chAccount_Code) or   // Check that this account is not the currently selected account
       ( not BGL360AccountsFilter( pChartAcc ) ) then // Check if this Account is not supposed to be shown??
      Continue;

    cmbxAccount.Properties.Items.AddObject(pChartAcc.chAccount_Code, TObject(ChartIndex));
    if (TranAccount <> '') and (TranAccount = pChartAcc.chAccount_Code) then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
end;

procedure TdlgEditBGLSF360Fields.SetMemOnly(const Value: boolean);
begin
  FMemOnly := Value;
// Set the FrankingFme MemorisationsOnly property rather
  if assigned( fmeDistributionFranking ) then
    fmeDistributionFranking.nfFrankingCredits.Enabled := not FMemOnly;
// Set the FrankingFme MemorisationsOnly property rather
end;

procedure TdlgEditBGLSF360Fields.SetMoveDirection(const Value: TFundNavigation);
begin
  btnBack.Enabled := not (Value in [fnNoMove,fnIsFirst]);
  btnNext.Enabled := not (Value in [fnNoMove,fnIsLast]);
  FMoveDirection := Value;
end;

end.
