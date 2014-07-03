{ Note: fields are mapped onto existing superfund fields as follows:
  Undeducted contrib                SF_Special_Income
  Franked:                          SF_Franked
  Unfranked:                        SF_Unfranked
  Foreign Income:                   SF_Foreign_Income
  Other Taxable:                    SF_Other_Expenses
  Capital Gain Other:               SF_Capital_Gains_Other
  Discount Capital Gain:            SF_Capital_Gains_Disc
  Capital Gain Conc:                SF_Capital_Gains_Indexed
  Tax Deferred:                     SF_Tax_Defered_Dist
  Tax Free Trust:                   SF_Tax_Free_Dist
  Non-Taxable:                      SF_Tax_Exempt_Dist
  Imputation Credit:                SF_Imputed_Credits
  TFN Credits:                      SF_TFN_Credits
  Foreign Tax Credits:              SF_Foreign_Capital_Gains_Credit
  Witholding Credit:                SF_Other_Tax_Credit [NEW]

  Transaction Type                  SF_Transaction_ID (IN/OUT), SF_Transaction_Code (OUT)
  Investment code                   SF_Fund_ID(IN/OUT)  , SF_Fund_Code (OUT),
  Member account                    SF_Member_Account_ID (IN/OUT) SFMember_Account_CODE
  Account

}
unit EditDesktopFieldsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ovcpf, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls, ExtCtrls, MoneyDef,
  bkconst, software, Buttons, cxGraphics, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxSkinsCore,
  OsFont, cxLookAndFeels, cxLookAndFeelPainters;

type
  TDS_Rec = record
    cl_ID: integer;
    cl_Code : string;
    cl_Description : string;
  end;

  TDSArray = array of TDS_Rec;



type
  TdlgEditDesktopFields = class(TForm)
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
    Label19: TLabel;
    nfForeignCGCredit: TOvcNumericField;
    nfTFNCredits: TOvcNumericField;
    Label25: TLabel;
    nfOtherTaxCredit: TOvcNumericField;
    gbRevenue: TGroupBox;
    lblFranked: TLabel;
    nfFranked: TOvcNumericField;
    lblUnFranked: TLabel;
    nfUnfranked: TOvcNumericField;
    Label4: TLabel;
    nfForeignIncome: TOvcNumericField;
    Label16: TLabel;
    nfCapitalGainsOther: TOvcNumericField;
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
    Label24: TLabel;
    Label3: TLabel;
    eCGTDate: TOvcPictureField;
    Label8: TLabel;
    nfContrib: TOvcNumericField;
    Label13: TLabel;
    cmbFund: TComboBox;
    cmbMember: TComboBox;
    lblLedgerID: TLabel;
    Label18: TLabel;
    cmbTrans: TComboBox;
    Label26: TLabel;
    Label27: TLabel;
    nfUnits: TOvcNumericField;
    lblLedger: TLabel;
    btnChart: TSpeedButton;
    GroupBox1: TGroupBox;
    lblGrosstext: TLabel;
    Label9: TLabel;
    nfImputedCredit: TOvcNumericField;
    lblGross: TLabel;
    btnThird: TButton;
    cmbxAccount: TcxComboBox;
    lp1: TLabel;
    lp2: TLabel;
    btnCalc: TSpeedButton;
    btnBack: TBitBtn;
    btnNext: TBitBtn;
    lblRemain: TLabel;
    Label23: TLabel;
    lp4: TLabel;
    lp5: TLabel;
    lp6: TLabel;
    lp7: TLabel;
    lp8: TLabel;
    lp9: TLabel;
    lp10: TLabel;
    lp11: TLabel;
    cmbSelectedFund: TComboBox;
    cmbClassSuperFund: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure nfExit(Sender: TObject);
    procedure nfKeyPress(Sender: TObject; var Key: Char);
    procedure cmbFundDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure cmbMemberDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbMemberDropDown(Sender: TObject);
    procedure cmbTransDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbTransDropDown(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnChartClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnThirdClick(Sender: TObject);
    procedure cmbxAccountPropertiesDrawItem(AControl: TcxCustomComboBox;
      ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState);
    procedure cmbxAccountPropertiesChange(Sender: TObject);
    procedure cmbxAccountKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nfUnitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCalcClick(Sender: TObject);
    procedure nfImputedCreditChange(Sender: TObject);
    procedure nfFrankedChange(Sender: TObject);
    procedure nfGeneralChange(Sender: TObject);
    procedure nfImputedCreditKeyPress(Sender: TObject; var Key: Char);
    procedure nfUnfrankedChange(Sender: TObject);
    procedure cmbFundCloseUp(Sender: TObject);
    procedure cmbSelectedFundDropDown(Sender: TObject);
    procedure cmbSelectedFundChange(Sender: TObject);
    procedure cmbClassSuperFundChange(Sender: TObject);
    procedure cmbClassSuperFundDropDown(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
    FReadOnly, FAutoPresSMinus: boolean;
    FTranAmount, FActualAmount: Double;
    FundArray, MemberArray, TransArray : TDSArray;
    FDepositStartIndex, FCurrentAccountIndex: Integer;
    FLedgerCode: ShortString;
    FMoveDirection: TFundNavigation;
    FTop, FLeft, FSkip: Integer;
    Glyph: TBitMap;
    FFrankPercentage: boolean;
    FDate: Integer;
    crModified: Boolean;
    UFModified: Boolean;
    FRevenuePercentage: boolean;
    FSDMode: TSuperDialogMode;
    SuperSystem: Byte;
    FClassSuperFundList: TStringList;
    function IsAllCleared(DoClear: boolean = False): boolean;
    function GetClassSuperFundCode(ClassSuperFundID: integer; AClassSuperFundName: string): string;
    Function ValidFundCode(AFundCode: string): boolean;
    procedure FillArray(var GLArray: TDSArray; List: string);
    procedure FillTransArray(var GLArray: TDSArray; List: string);
    procedure SetReadOnly(const Value: boolean);
    procedure SetMoveDirection(const Value: TFundNavigation);
    procedure CalcControlTotals( var Count : Integer; var Total : Currency; gb: TGroupBox );
    procedure UpdateDisplayTotals;
    procedure SetFrankPercentage(const Value: boolean);
    procedure SetupHelp;
    procedure SetRevenuePercentage(const Value: boolean);
    procedure SetSDMode(const Value: TSuperDialogMode);
  public
    { Public declarations }
    procedure SetFields( mContrib,
                         mFranked,
                         mUnfranked,
                         mForeignIncome,
                         mOtherExpenses,
                         mCapitalGainsOther,
                         mCapitalGainsDisc,
                         mCapitalGainsConc,
                         mTaxDeferredDist,
                         mTaxFreeDist,
                         mTaxExemptDist,
                         mImputedCredit,
                         mTFNCredits,
                         mForeignCGCredit,
                         mOtherTaxCredit: Money;
                         dCGTDate, mMemberID, mFundID: Integer;
                         mAccount: Shortstring;
                         mFundCode: ShortString;
                         mMemberCode: ShortString;
                         mUnits: Money;
                         mTransID: Integer;
                         mFraction: Boolean);

   {procedure SetMemFields(mTransID: Integer;
                          mFranked: Money;
                          mUnFranked: Money;
                          mMemberID: Integer;
                          mMemberCode: shortstring;

                          mFundID: Integer;
                          mFundCode: shortstring;
                          mAccount: shortstring);}

    procedure SetInfo( iDate : integer; sNarration: string; mAmount, mQty : Money; LedgerID: ShortString; aSuperSystem: byte; aSDMode: TSuperDialogMode );

    function GetFields(  var mContrib : Money;
                         var mFranked : Money;
                         var mUnfranked : Money;
                         var mForeignIncome : Money;
                         var mOtherExpenses : Money;
                         var mCapitalGainsOther : Money;
                         var mCapitalGainsDisc : Money;
                         var mCapitalGainsConc : Money;
                         var mTaxDeferredDist : Money;
                         var mTaxFreeDist : Money;
                         var mTaxExemptDist : Money;
                         var mImputedCredit : Money;
                         var mTFNCredits : Money;
                         var mForeignCGCredit : Money;
                         var mOtherTaxCredit: Money;
                         var dCGTDate : integer;
                         var mMemberID: integer;
                         var mFundID: integer;
                         var mFundCode: ShortString;
                         var mMemberCode: ShortString;
                         var mAccount: Shortstring;
                         var mUnits: Money;
                         var mTransID: Integer;
                         var mTransCode: string;
                         var mFraction: Boolean
                         ) : boolean;

    {function GetMemFields(var mTransID: Integer;
                          var mTransCode: Ansistring;
                          var mFranked, mUnFranked: Money;
                          var mmemberID: integer;
                          var mmemberCode: Shortstring;
                          var mAccount: Shortstring;
                          var mFundID: Integer;
                          var mFundCode: Shortstring): boolean;}
    procedure AddFund(AFundID: string; aSuperSystem: byte);

    property ReadOnly : boolean read FReadOnly write SetReadOnly;
    property MoveDirection : TFundNavigation read FMoveDirection write SetMoveDirection;
    property FormTop: Integer read FTop write FTop;
    property FormLeft: Integer read FLeft write FLeft;
    property FrankPercentage: boolean read FFrankPercentage write SetFrankPercentage;
    property RevenuePercentage: boolean read FRevenuePercentage write SetRevenuePercentage;
    property SDMode: TSuperDialogMode read FSDMode write SetSDMode;
    property LedgerCode: ShortString read FLedgerCode;
  end;

//******************************************************************************
implementation

uses
  ClassSuperIP,
  glConst,
  bkDateUtils,
  GenUtils,
  bkXPThemes,
  SelectDate,
  WarningMoreFrm,
  ErrorMoreFrm,
  Globals,
  DesktopSuper_Utils,
  SuperFieldsUtils,
  StStrS, ovcdate, bkdefs, AccountLookupFrm, imagesfrm, bkhelp;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgEditDesktopFields.GetClassSuperFundCode(ClassSuperFundID: integer;
  AClassSuperFundName: string): string;
begin
  Result := '';
  if (FClassSuperFundList.ValueFromIndex[ClassSuperFundID] = AClassSuperFundName) then
    Result := FClassSuperFundList.Names[ClassSuperFundID];
end;

function TdlgEditDesktopFields.GetFields( var mContrib: Money;
                         var mFranked : Money;
                         var mUnfranked : Money;
                         var mForeignIncome : Money;
                         var mOtherExpenses : Money;
                         var mCapitalGainsOther : Money;
                         var mCapitalGainsDisc : Money;
                         var mCapitalGainsConc : Money;
                         var mTaxDeferredDist : Money;
                         var mTaxFreeDist : Money;
                         var mTaxExemptDist : Money;
                         var mImputedCredit : Money;
                         var mTFNCredits : Money;
                         var mForeignCGCredit : Money;
                         var mOtherTaxCredit: Money;
                         var dCGTDate : integer;
                         var mMemberID: integer;
                         var mFundID: integer;
                         var mFundCode: ShortString;
                         var mMemberCode: ShortString;
                         var mAccount: ShortString;
                         var mUnits: Money;
                         var mTransID: Integer;
                         var mTransCode: string;
                         var mFraction: Boolean) : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     take the values from the form and return into vars
//
// Parameters:
//
// Result:      Returns true if any of the fields are no zero
//- - - - - - - - - - - - - - - - - - - -
begin
  // Franked
  mFranked := GetNumericValue(nfFranked, FrankPercentage);
  mUnfranked := GetNumericValue(nfUnfranked, FrankPercentage);

  //revenue
  mContrib := GetNumericValue(nfContrib, RevenuePercentage);
  mForeignIncome := GetNumericValue(nfForeignIncome, RevenuePercentage);
  mOtherExpenses := GetNumericValue(nfOtherExpenses, RevenuePercentage);
  mCapitalGainsOther := GetNumericValue(nfCapitalGainsOther, RevenuePercentage);
  mCapitalGainsDisc := GetNumericValue(nfDiscountedCapitalGains, RevenuePercentage);
  mCapitalGainsConc := GetNumericValue(nfCapitalGains, RevenuePercentage);
  mTaxDeferredDist := GetNumericValue(nfTaxDeferredDist, RevenuePercentage);
  mTaxFreeDist := GetNumericValue(nfTaxFreeDist, RevenuePercentage);
  mTaxExemptDist := GetNumericValue(nfTaxExemptDist, RevenuePercentage);

  //Tax
  mImputedCredit := GetNumericValue(nfImputedCredit, False);
  mTFNCredits := GetNumericValue(nfTFNCredits, False);
  mForeignCGCredit := GetNumericValue(nfForeignCGCredit, False);
  mOtherTaxCredit := GetNumericValue(nfOtherTaxCredit, False);

  dCGTDate := stNull2Bk(eCGTDate.AsStDate);

  if cmbMember.ItemIndex > 0 then
  begin
     case SuperSystem of
       saDesktopSuper: mMemberID := MemberArray[cmbMember.itemindex-1].cl_ID;
       saClassSuperIP: mMemberID := -1;
     end;
     mMemberCode := MemberArray[cmbMember.itemindex-1].cl_Code;
  end else begin
     mMemberID := -1;
     mMemberCode := '';
  end;

  if cmbFund.ItemIndex > 0 then begin
     case SuperSystem of
       saDesktopSuper: mFundID := FundArray[cmbFund.itemindex-1].cl_ID;
       saClassSuperIP: mFundID :=  -1;
     end;
     mFundCode := FundArray[cmbFund.itemindex-1].cl_Code;
  end else if cmbFund.ItemIndex = 0 then begin
     mFundID := -1;
     mFundCode := '';
  end else begin
     mFundID := -1;
     mFundCode := cmbFund.Text;
  end;

  case SuperSystem of
  saDesktopSuper: begin
     if (cmbTrans.ItemIndex > 0) and (cmbTrans.ItemIndex <> FDepositStartIndex) then begin
        if cmbTrans.ItemIndex > FDepositStartIndex then begin
           mTransID := TransArray[cmbTrans.itemindex-2].cl_ID;
           mTransCode := TransArray[cmbTrans.itemindex-2].cl_Description;
        end else begin
           mTransID := TransArray[cmbTrans.itemindex-1].cl_ID;
           mTransCode := TransArray[cmbTrans.itemindex-1].cl_Description;
        end;
     end else begin
       mTransID := -1;
       mTransCode := '';
     end;
  end;
  saClassSuperIP : begin
      mTransID := -1;
      mTransCode := '';
  end;
  end;

  if cmbxAccount.ItemIndex > 0 then
    mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
  else
    mAccount := '';

  mUnits := nfUnits.AsFloat * 10000;
  if ((FActualAmount < 0) and (mUnits > 0)) or
     ((FActualAmount > 0) and (mUnits < 0)) then
    mUnits := -mUnits;

  mFraction := btnThird.Caption = '1/2';

  result := ( mContrib <> 0) or
            ( mImputedCredit <> 0) or
            ( mTaxFreeDist <> 0) or
            ( mTaxExemptDist <> 0) or
            ( mTaxDeferredDist <> 0) or
            ( mTFNCredits <> 0) or
            ( mForeignIncome <> 0) or
            ( mCapitalGainsConc <> 0) or
            ( mCapitalGainsDisc <> 0) or
            ( mCapitalGainsOther <> 0) or
            ( mOtherExpenses <> 0) or
            ( mFranked <> 0) or
            ( mUnfranked <> 0) or
            ( mOtherTaxCredit <> 0) or
            ( mOtherTaxCredit <> 0) or
            ( mForeignCGCredit <> 0) or
            ( dCGTDate <> 0) or
            ( mMemberID <> -1) or
            ( mFundID <> -1) or
            ( mFundCode <> '') or
            ( mMemberCode <> '') or
            ( mTransID <> -1) or
            ( mTransCode <> '');
end;

function TdlgEditDesktopFields.IsAllCleared(DoClear: boolean): boolean;
begin
  Result := False;
  if DoClear then begin
    nfContrib.AsFloat := 0;
    nfImputedCredit.AsFloat := 0;
    nfTaxFreeDist.AsFloat := 0;
    nfTaxExemptDist.AsFloat := 0;
    nfTaxDeferredDist.AsFloat := 0;
    nfTFNCredits.AsFloat := 0;
    nfForeignIncome.AsFloat := 0;
    nfCapitalGains.AsFloat := 0;
    nfDiscountedCapitalGains.AsFloat := 0;
    nfCapitalGainsOther.AsFloat := 0;
    nfOtherExpenses.AsFloat := 0;
    nfFranked.AsFloat := 0;
    nfUnfranked.AsFloat := 0;
    nfDiscountedCapitalGains.AsFloat := 0;
    nfOtherTaxCredit.AsFloat := 0;
    nfForeignCGCredit.AsFloat := 0;
    eCGTDate.AsString := '';
    cmbMember.ItemIndex := -1;
    cmbFund.ItemIndex := -1;
    cmbFund.Text := '';
    cmbTrans.ItemIndex := -1;
    btnThird.Caption := '2/3';
    UFModified := False;
    FLedgerCode := IntToStr(-1);
    case SuperSystem of
      saDesktopSuper:
        begin
          cmbSelectedFund.ItemIndex := -1;
          cmbSelectedFundChange(nil);
        end;
      saClassSuperIP:
        begin
          cmbClassSuperFund.ItemIndex := -1;
          cmbClassSuperFundChange(nil);
        end;
    end;
    Result := True;
  end else begin
    Result := (nfContrib.AsFloat = 0);
    Result := Result and (nfImputedCredit.AsFloat = 0);
    Result := Result and (nfTaxFreeDist.AsFloat = 0);
    Result := Result and (nfTaxExemptDist.AsFloat = 0);
    Result := Result and (nfTaxDeferredDist.AsFloat = 0);
    Result := Result and (nfTFNCredits.AsFloat = 0);
    Result := Result and (nfForeignIncome.AsFloat = 0);
    Result := Result and (nfCapitalGains.AsFloat = 0);
    Result := Result and (nfDiscountedCapitalGains.AsFloat = 0);
    Result := Result and (nfCapitalGainsOther.AsFloat = 0);
    Result := Result and (nfOtherExpenses.AsFloat = 0);
    Result := Result and (nfFranked.AsFloat = 0);
    Result := Result and (nfUnfranked.AsFloat = 0);
    Result := Result and (nfDiscountedCapitalGains.AsFloat = 0);
    Result := Result and (nfOtherTaxCredit.AsFloat = 0);
    Result := Result and (nfForeignCGCredit.AsFloat = 0);
    Result := Result and (eCGTDate.AsDateTime = 0);
    Result := Result and (cmbMember.ItemIndex = -1);
    Result := Result and (cmbFund.ItemIndex = -1);
    Result := Result and (cmbFund.Text = '');
    Result := Result and (cmbTrans.ItemIndex = -1);
    Result := Result and (cmbSelectedFund.ItemIndex = -1);
    Result := Result and (btnThird.Caption = '2/3');
    Result := Result and ((StrToIntDef(FLedgerCode,-1) = -1) or (FLedgerCode = ''));
  end;
end;

(*
function TdlgEditDesktopFields.GetMemFields(
                          var mTransID: Integer;
                          var mTransCode: Ansistring;
                          var mFranked, mUnFranked: Money;
                          var mmemberID: integer;
                          var mmemberCode: Shortstring;
                          var mAccount: Shortstring;
                          var mFundID: Integer;
                          var mFundCode: Shortstring): boolean;
begin

   mFranked := Double2Percent(nfFranked.AsFloat);
   mUnFranked := Double2Percent(nfUnFranked.AsFloat);

   if cmbFund.Enabled
   and (cmbFund.ItemIndex > 0) then begin
      mFundID := FundArray[cmbFund.itemindex-1].cl_ID;
      mFundCode := FundArray[cmbFund.itemindex-1].cl_Code;
   end else begin
      mFundID := -1;
      mFundCode := '';
   end;

   if (cmbTrans.ItemIndex > 0)
   and (cmbTrans.ItemIndex <> FDepositStartIndex) then begin
      if cmbTrans.ItemIndex > FDepositStartIndex then begin
         mTransID := TransArray[cmbTrans.itemindex-2].cl_ID;
         mTransCode := TransArray[cmbTrans.itemindex-2].cl_Description;
      end else begin
         mTransID := TransArray[cmbTrans.itemindex-1].cl_ID;
         mTransCode := TransArray[cmbTrans.itemindex-1].cl_Description;
      end;
   end else begin
      mTransID := -1;
      mTransCode := '';
   end;

   if cmbxAccount.ItemIndex > 0 then
      mAccount := (MyClient.clChart.Account_At(cmbxAccount.ItemIndex-1)).chAccount_Code
   else
      mAccount := '';


   if cmbMember.Enabled
   and (cmbMember.ItemIndex > 0) then begin
      mMemberID := MemberArray[cmbMember.itemindex-1].cl_ID;
      mMemberCode := MemberArray[cmbMember.itemindex-1].cl_Code;
   end else begin
      mMemberID := -1;
      mMemberCode := '';
   end;

   Result :=
            ( mFranked <> 0) or
            ( mUnFranked <> 0) or
            ( mFundID <> -1) or
            ( mFundCode <> '') or
            ( mMemberCode <> '') or
            ( mTransID <> -1) or
            ( mMemberID <> -1) or
            ( mTransCode <> '');
end;
 *)

procedure TdlgEditDesktopFields.nfExit(Sender: TObject);
begin
  UpdateDisplayTotals;
end;

procedure TdlgEditDesktopFields.nfGeneralChange(Sender: TObject);
begin
   UpdateDisplayTotals;
end;

procedure TdlgEditDesktopFields.nfFrankedChange(Sender: TObject);
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

procedure TdlgEditDesktopFields.nfImputedCreditChange(Sender: TObject);
begin
   crModified := CheckFrankingCredit( nfFranked.asFloat,fDate,nfImputedCredit, not((Sender = nfImputedCredit) or crModified));
end;


procedure TdlgEditDesktopFields.nfImputedCreditKeyPress(Sender: TObject;
  var Key: Char);
begin
  //ignore minus key
  if Key = '-' then
    Key := #0;
end;

procedure TdlgEditDesktopFields.nfKeyPress(Sender: TObject;
  var Key: Char);
var
  Count : Integer;
  Total, TaxTotal : Currency;
  nf: TOvcNumericField;
begin

  if Key = '=' then begin
    Key := #0;
    {if FrankPercentage then
       Exit;}
    nf := Sender as TOvcNumericField;
    CalcControlTotals( Count, Total, gbRevenue );
    CalcControlTotals( Count, TaxTotal, gbTax );
    if nf.Parent = gbRevenue then begin
       if FTranAmount - Total + TaxTotal <> 0 then begin
          nf.AsFloat := nf.AsFloat + FTranAmount - Total + TaxTotal;
          if nf = nfFranked then
             nfImputedCreditChange(Sender);
       end;
    end else if nf.Parent = gbTax then begin
       if FTranAmount - Total + TaxTotal <> 0 then begin
          nf.AsFloat := nf.AsFloat - (FTranAmount - Total + TaxTotal);

       end;
    end;
    UpdateDisplayTotals;
  end;
end;

procedure TdlgEditDesktopFields.nfUnfrankedChange(Sender: TObject);
begin
   {if FrankPercentage then
      nffrankedChange(nfUnfranked)
   else }

   UFModified := True;
end;

procedure TdlgEditDesktopFields.nfUnitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FAutoPressMinus then
    keybd_event(vk_subtract,0,0,0);
  FAutoPresSMinus := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditDesktopFields.SetFields(mContrib,
                         mFranked,
                         mUnfranked,
                         mForeignIncome,
                         mOtherExpenses,
                         mCapitalGainsOther,
                         mCapitalGainsDisc,
                         mCapitalGainsConc,
                         mTaxDeferredDist,
                         mTaxFreeDist,
                         mTaxExemptDist,
                         mImputedCredit,
                         mTFNCredits,
                         mForeignCGCredit,
                         mOtherTaxCredit: Money;
                         dCGTDate, mMemberID, mFundID: Integer;
                         mAccount: Shortstring;
                         mFundCode: ShortString;
                         mMemberCode: ShortString;
                         mUnits: Money;
                         mTransID: Integer;
                         mFraction: Boolean);
var
  i: Integer;
  p: pAccount_Rec;
  D: Boolean;
begin
  SetNumericValue(nfContrib, mContrib, RevenuePercentage);
  SetNumericValue(nfTaxFreeDist, mTaxFreeDist, RevenuePercentage);
  SetNumericValue(nfTaxExemptDist, mTaxExemptDist, RevenuePercentage);
  SetNumericValue(nfTaxDeferredDist, mTaxDeferredDist, RevenuePercentage);

  SetNumericValue(nfForeignIncome, mForeignIncome, RevenuePercentage);
  SetNumericValue(nfCapitalGains, mCapitalGainsConc, RevenuePercentage);
  SetNumericValue(nfDiscountedCapitalGains, mCapitalGainsDisc, RevenuePercentage);
  SetNumericValue(nfCapitalGainsOther, mCapitalGainsOther, RevenuePercentage);
  SetNumericValue(nfOtherExpenses, mOtherExpenses, RevenuePercentage);

  SetNumericValue(nfFranked, mFranked, FrankPercentage);
  SetNumericValue(nfUnfranked, mUnfranked, FrankPercentage);

  UFModified := ((mFranked <> 0) or (mUnfranked <> 0))
             and ((mFranked + mUnfranked) <> abs(FActualAmount));

  eCGTDate.AsStDate := BkNull2St(dCGTDate);
  nfUnits.AsFloat := mUnits / 10000;

  cmbFund.ItemIndex := -1;
  cmbFund.Text := '';
  cmbMember.ItemIndex := -1;
  cmbTrans.ItemIndex := -1;

  if mFraction then
    btnThird.Caption := '1/2'
  else
    btnThird.Caption := '2/3';

  
  cmbxAccount.Properties.Items.Add('');
  for i := MyClient.clChart.First to MyClient.clChart.Last do
  begin
    p := MyClient.clChart.Account_At(i);
    cmbxAccount.Properties.Items.Add(p.chAccount_Code);
    if mAccount = p.chAccount_Code then
      cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
  end;
  FCurrentAccountIndex := cmbxAccount.ItemIndex;


  case SDMode of
     sfTrans : begin
        SetNumericValue(nfImputedCredit, mImputedCredit, False);
        nfImputedCreditChange(nfImputedCredit);


        SetNumericValue(nfOtherTaxCredit, mOtherTaxCredit, False);
        SetNumericValue(nfForeignCGCredit, mForeignCGCredit, False);
        SetNumericValue(nfTFNCredits, mTFNCredits, False);
     end;
  end;


  cmbFund.Items.Add('');
  for i := Low(FundArray) to High(FundArray) do begin
    if FundArray[i].cl_ID <> -1 then
      cmbFund.Items.Add(Format ('%s : (%s)', [FundArray[i].cl_Code,   FundArray[i].cl_Description]));

    case SuperSystem of
    saDesktopSuper: if FundArray[i].cl_ID = mFundID then
                      cmbFund.ItemIndex := i+1;
    saClassSuperIp : if sametext(FundArray[i].cl_Code,mFundCode) then
                       cmbFund.ItemIndex := i+1;
    end;
  end;
  if cmbFund.ItemIndex <=0 then
     cmbFund.Text := mFundCode;


  cmbMember.Items.Add('');
  for i := Low(MemberArray) to High(MemberArray) do
  begin
    if MemberArray[i].cl_ID <> -1 then
      cmbMember.Items.Add(MemberArray[i].cl_Description);
    case SuperSystem of
    saDesktopSuper: if MemberArray[i].cl_ID = mMemberID then
                      cmbMember.ItemIndex := i+1;
    saClassSuperIp : if sametext(MemberArray[i].cl_Code,mMemberCode) then
                       cmbMember.ItemIndex := i+1;
    end;

  end;



  cmbTrans.Items.Add('');
  D := False;
  for i := Low(TransArray) to High(TransArray) do
  begin
    if (TransArray[i].cl_ID > 100) and (not D) then
    begin
      FDepositStartIndex := i+1;
      D := True;
      cmbTrans.Items.Add('');
    end;
    if TransArray[i].cl_ID <> -1 then
      cmbTrans.Items.Add(TransArray[i].cl_Description);
    if TransArray[i].cl_ID = mTransID then
    begin
      if (i >= FDepositStartIndex-1) and D then
        cmbTrans.ItemIndex := i+2
      else
        cmbTrans.ItemIndex := i+1;
    end;
  end;



  UpdateDisplayTotals;

  FAutoPressMinus := (FActualAmount < 0) and (mUnits = 0);
end;

procedure TdlgEditDesktopFields.SetFrankPercentage(const Value: boolean);
begin
   FFrankPercentage := Value;
   SetPercentLabel(lp1, FFrankPercentage);
   SetPercentLabel(lp2, FFrankPercentage);


   btnCalc.Visible := not FFrankPercentage;

   if FFrankPercentage then begin
      lblFranked.Caption := 'Percentage Franked';
      lblUnFranked.Caption := 'Percentage Unfranked';

      lblGrosstext.Caption := 'Gross';
      FTranAmount := 100;
   end else begin
      lblFranked.Caption := 'Franked';
      lblUnFranked.Caption := 'Unfranked';
      lblGrosstext.Caption := 'Gross Amount';
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditDesktopFields.FillArray(var GLArray: TDSArray; List: string);
var
   Fields: array[ 1..4 ] of string;
   S: TStringList;
   i, j, RecNo: Integer;
begin
  if Trim(List) = '' then exit;
  RecNo := 0;
  S := TStringList.Create;
  try
    S.Text := List;
    // Note start at '1' to skip headers
    SetLength( GLArray, S.Count - 1);
    for i := 1 to Pred(S.Count) do
    begin
      For j := 1 to 4 do Fields[ j ] := TrimSpacesAndQuotes( ExtractAsciiS( j, S[i], ',', '"' ) );
      if sametext(Fields[2],FLedgerCode) then
      begin
        GLArray[RecNo].cl_ID := StrToIntDef(Fields[1], -1);
        GLArray[RecNo].cl_Code := Fields[3];
        GLArray[Recno].cl_Description := Fields[4];
        Inc(RecNo);
      end;
    end;
  finally
    SetLength( GLArray, RecNo);
    S.Free;
  end;
end;

procedure TdlgEditDesktopFields.FillTransArray(var GLArray: TDSArray; List: string);
var
   Fields: array[ 1..2 ] of string;
   S: TStringList;
   id, i, j, RecNo: Integer;
   R, D: TStringList;
begin
  if Trim(List) = '' then exit;
  RecNo := 0;
  S := TStringList.Create;
  R := TStringList.Create;
  D := TStringList.Create;
  try
    S.Text := List;
    // Note start at '1' to skip headers
    SetLength( GLArray, S.Count - 1);
    for i := 1 to Pred(S.Count) do
    begin
      For j := 1 to 2 do Fields[ j ] := TrimSpacesAndQuotes( ExtractAsciiS( j, S[i], ',', '"' ) );
      id := StrToIntDef(Fields[1], -1);
      if id < 100 then
        R.AddObject(Fields[2], TObject(id)) // receipt
      else
        D.AddObject(Fields[2], TObject(id)); // deposit
    end;
    R.Sort;
    D.Sort;
    for i := 0 to Pred(R.Count) do
    begin
      GLArray[RecNo].cl_ID := Integer(R.Objects[i]);
      GLArray[Recno].cl_Description := R[i];
      Inc(RecNo);
    end;
    for i := 0 to Pred(D.Count) do
    begin
      GLArray[RecNo].cl_ID := Integer(D.Objects[i]);
      GLArray[Recno].cl_Description := D[i];
      Inc(RecNo);
    end;
  finally
    SetLength( GLArray, RecNo);
    S.Free;
    R.Free;
    D.Free;
  end;
end;

procedure TdlgEditDesktopFields.FormCreate(Sender: TObject);
begin
  ThemeForm(Self);
  SetupHelp;
  FReadOnly := false;
  eCGTDate.Epoch       := BKDATEEPOCH;
  eCGTDate.PictureMask := BKDATEFORMAT;
  Self.KeyPreview := True;
  FMoveDirection := fnNothing;
  FormTop := -999;
  FormLeft := -999;
  UFModified := False;
  Glyph := TBitMap.Create;
  ImagesFrm.AppImages.Maintain.GetBitmap( MAINTAIN_LOCK_BMP, Glyph );
  FDepositStartIndex := 0;

  FSkip := 0;

  //Temporary list to store ClassSuper Fund codes
  FClassSuperFundList := TStringList.Create;  
end;

procedure TdlgEditDesktopFields.FormDestroy(Sender: TObject);
begin
  FClassSuperFundList.Free;
end;

procedure TdlgEditDesktopFields.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F2) or ((Key = Ord('L')) and (Shift = [ssCtrl])) then
    btnChartClick(Sender);
end;

procedure TdlgEditDesktopFields.FormShow(Sender: TObject);
var
  LedgerName: string;
begin
  if FTop > -999 then
  begin
    Top := FTop;
    Left := FLeft;
  end;

  case SuperSystem of
    saDesktopSuper:
      if (cmbSelectedFund.Items.Count > 1) then begin
        lblLedger.Visible := False;
        cmbClassSuperFund.Visible := False;
        cmbSelectedFund.Left := cmbTrans.Left;
        cmbSelectedFund.Visible := True;
        LedgerName := DesktopSuper_Utils.GetLedgerName(StrToIntDef(FLedgerCode,-1));
        cmbSelectedFund.ItemIndex := cmbSelectedFund.Items.IndexOf(LedgerName);
      end;
    saClassSuperIP:
      if (cmbClassSuperFund.Items.Count > 1) then begin
        lblLedger.Visible := False;
        cmbSelectedFund.Visible := False;
        cmbClassSuperFund.Top := cmbxAccount.Top;
        cmbClassSuperFund.Left := cmbTrans.Left;
        cmbClassSuperFund.Visible := True;
        LedgerName := ClassSuperIP.GetLedgerName(FLedgerCode);
        cmbClassSuperFund.ItemIndex := cmbClassSuperFund.Items.IndexOf(LedgerName);
      end;
  end;

  UpdateDisplayTotals;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type
   wincontolhelper = class helper for TControl
      procedure MoveTo(atop, aleft: integer); overload;
      procedure MoveTo(control: TControl); overload;
   end;

   procedure wincontolhelper.MoveTo(atop, aleft: integer);
   begin
      left := aLeft;
      Top := aTop;
   end;
   procedure wincontolhelper.MoveTo(control: TControl);
   begin
      MoveTo( Control.Top, Control.Left);
   end;

procedure TdlgEditDesktopFields.SetInfo( iDate : integer; sNarration: string; mAmount, mQty : Money; LedgerID: ShortString; aSuperSystem: byte; aSDMode: TSuperDialogMode);
begin
  lblDate.Caption := BkDate2Str( iDate);

  if RevenuePercentage then begin
     lblAmount.Caption := '100%';
     lblamountlbl.Caption := 'Total';
  end else

  if mAmount <> 0 then
     lblAmount.Caption := Money2Str( abs(mAmount))
  else
     lblAmount.Caption := '';

  FActualAmount := mAmount;
  FTranAmount := Abs(mAmount/100.0);
  lblNarration.Caption := sNarration;
  FLedgerCode := LedgerID;
  fDate := iDate;

  SDMode := asdMode;

  SuperSystem := aSuperSystem;


  case SuperSystem of
    saDesktopSuper:
       begin
          FillArray(FundArray, ImportDesktopCSV(DESKTOP_SUPER_INVESTMENT_FILENAME, 'Investment Code List'));
          FillArray(MemberArray, ImportDesktopCSV(DESKTOP_SUPER_MEMBER_FILENAME, 'Member Account List'));
          lblLedger.Caption := DesktopSuper_Utils.GetLedgerName(StrToIntDef(FLedgerCode,-1));
          if lblLedger.Caption = '' then
             lblLedger.Caption := '<none>';

          FillTransArray(TransArray, ImportDesktopCSV(DESKTOP_SUPER_TRANS_FILENAME, 'Transaction Types List'));
       end;
    saClassSuperIP:
       begin
          FillArray(FundArray, ImportClassSuperList(fLedgerCode,cs_Investments));
          FillArray(MemberArray, ImportClassSuperList(fLedgerCode,cs_Members));
          lblLedger.Caption := ClassSuperIP.GetLedgerName(FLedgerCode);
          if lblLedger.Caption = '' then
             lblLedger.Caption := '<none>';
          Label18.Visible := False;
          cmbTrans.Visible := False;
       end;
  end;

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditDesktopFields.AddFund(AFundID: string; aSuperSystem: byte);
var
  DesktopFundID: integer;
  ClassSuperFundName: string;
begin
  if (AFundID <> '') then begin
    case aSuperSystem of
      saDesktopSuper:
        begin
          DesktopFundID := StrToIntDef(AFundID, -1);
          if (DesktopFundID <> -1) and (cmbSelectedFund.Items.IndexOf(DesktopSuper_Utils.GetLedgerName(DesktopFundID)) = -1) then
            cmbSelectedFund.Items.AddObject(DesktopSuper_Utils.GetLedgerName(DesktopFundID), TObject(DesktopFundID));
        end;
      saClassSuperIP:
        begin
          ClassSuperFundName := ClassSuperIP.GetLedgerName(AFundID);
          if cmbClassSuperFund.Items.IndexOf(ClassSuperFundName) = -1 then begin
            cmbClassSuperFund.Items.Add(ClassSuperFundName);
            FClassSuperFundList.Add(AFundID + '=' + ClassSuperFundName);
          end;
        end;
    end;
  end;
end;

procedure TdlgEditDesktopFields.btnBackClick(Sender: TObject);
begin
  FMoveDirection := fnGoBack;
  ModalResult := mrOk;
end;

procedure TdlgEditDesktopFields.btnCalcClick(Sender: TObject);
begin
    crModified := False;
    nfImputedCreditChange(nil);
end;

procedure TdlgEditDesktopFields.btnChartClick(Sender: TObject);
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

procedure TdlgEditDesktopFields.btnClearClick(Sender: TObject);
begin
  if IsAllCleared(True) then begin
    nfImputedCreditChange(nfImputedCredit);
    UpdateDisplayTotals;
  end;
end;

procedure TdlgEditDesktopFields.btnNextClick(Sender: TObject);
begin
  FMoveDirection := fnGoForward;
  ModalResult := mrOk;
end;

procedure TdlgEditDesktopFields.btnThirdClick(Sender: TObject);
begin
  if btnThird.Caption = '2/3' then
    btnThird.Caption := '1/2'
  else
    btnThird.Caption := '2/3';
end;

(*
procedure TdlgEditDesktopFields.SetMemFields(
                          mTransID: Integer;
                          mFranked,mUnFranked: Money;
                          mMemberID: Integer;
                          mMemberCode: shortstring;

                          mFundID: Integer;
                          mFundCode: shortstring;
                          mAccount: shortstring);

var
  i: Integer;
  p: pAccount_Rec;
  D: Boolean;
begin
   lblFranked.Caption := 'Percentage Franked';
   lblUnFranked.Caption := 'Percentage Unfranked';

   lblAmount.Caption := '';
   lp1.Visible := true;
   lp2.Visible := true;
   lp3.Visible := true;
   btnCalc.Visible := False;

   FrankPercentage := True;

   //lblTotal.Caption := '100.0000%';

   nfContrib.Enabled := False;
   nfTaxFreeDist.Enabled := False;
   nfTaxExemptDist.Enabled := False;
   nfTaxDeferredDist.Enabled := False;
   nfTFNCredits.Enabled := False;
   nfForeignIncome.Enabled := False;
   nfCapitalGains.Enabled := False;
   nfDiscountedCapitalGains.Enabled := False;
   nfCapitalGainsOther.Enabled := False;
   nfOtherExpenses.Enabled := False;

   nfFranked.AsFloat := Percent2Double(mFranked);
   nfUnfranked.AsFloat := Percent2Double(mUnFranked);
   nfImputedCredit.Enabled := False;
   nfImputedCreditChange(nil);

   nfOtherTaxCredit.Enabled := False;
   nfForeignCGCredit.Enabled := False;
   eCGTDate.Enabled := False;


   if FLedgerID >= 0 then begin // Not a Mastermem
      // FundID
      cmbFund.ItemIndex := -1;
      cmbFund.Items.Add('');
      for i := Low(FundArray) to High(FundArray) do begin
         if FundArray[i].cl_ID <> -1 then
           cmbFund.Items.Add(FundArray[i].cl_Description);
         if FundArray[i].cl_ID = mFundID then
            cmbFund.ItemIndex := i+1;
      end;

      // MemberSD
      cmbMember.ItemIndex := -1;
      cmbMember.Items.Add('');
      for i := Low(MemberArray) to High(MemberArray) do begin
         if MemberArray[i].cl_ID <> -1 then
            cmbMember.Items.Add(MemberArray[i].cl_Description);
         if MemberArray[i].cl_ID = mMemberID then
            cmbMember.ItemIndex := i+1;
      end;

   end else begin
      cmbFund.Enabled := False;
      cmbMember.Enabled := False;
   end;


   // TransID
   cmbTrans.ItemIndex := -1;
   cmbTrans.Items.Add('');
   D := False;
   for i := Low(TransArray) to High(TransArray) do begin
     if (TransArray[i].cl_ID > 100) and (not D) then begin
        FDepositStartIndex := i+1;
        D := True;
        cmbTrans.Items.Add('');
     end;
     if TransArray[i].cl_ID <> -1 then
        cmbTrans.Items.Add(TransArray[i].cl_Description);
     if TransArray[i].cl_ID = mTransID then begin
        if (i >= FDepositStartIndex-1) and D then
           cmbTrans.ItemIndex := i+2
        else
           cmbTrans.ItemIndex := i+1;
     end;
   end;

   nfUnits.Enabled := False;

   // Acount
   cmbxAccount.Properties.Items.Add('');
   for i := MyClient.clChart.First to MyClient.clChart.Last do begin
      p := MyClient.clChart.Account_At(i);
      cmbxAccount.Properties.Items.Add(p.chAccount_Code);
      if mAccount = p.chAccount_Code then
        cmbxAccount.ItemIndex := Pred(cmbxAccount.Properties.Items.Count);
   end;
   FCurrentAccountIndex := cmbxAccount.ItemIndex;

   btnThird.Caption := '1/2';
   UpdateDisplayTotals;

end;
*)

procedure TdlgEditDesktopFields.SetSDMode(const Value: TSuperDialogMode);
begin
   FSDMode := Value;

   nfTFNCredits.Enabled := (FSDMode in [sftrans]) and  (not FReadOnly);
   nfForeignCGCredit.Enabled := (FSDMode in [sftrans]) and  (not FReadOnly);
   nfOtherTaxCredit.Enabled := (FSDMode in [sftrans]) and  (not FReadOnly);
   nfImputedCredit.Enabled := (FSDMode in [sftrans]) and  (not FReadOnly);

   nfContrib.Enabled := (FSDMode in [sftrans]) and  (not FReadOnly);

   cmbTrans.Enabled := (FSDMode in [sftrans, sfMem, sfPayee]) and  (not FReadOnly);
   cmbfund.Enabled := (FSDMode in [sftrans, sfMem, sfPayee]) and  (not FReadOnly);
   cmbMember.Enabled := (FSDMode in [sftrans, sfMem, sfPayee]) and  (not FReadOnly);
end;

procedure TdlgEditDesktopFields.SetMoveDirection(const Value: TFundNavigation);
begin

  btnBack.Enabled := not (Value in [fnNoMove,fnIsFirst]);
  btnNext.Enabled := not (Value in [fnNoMove,fnIsLast]);
  FMoveDirection := Value;
end;

procedure TdlgEditDesktopFields.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;

  nfContrib.Enabled := not Value;
  nfTaxFreeDist.Enabled := not Value;
  nfTaxExemptDist.Enabled := not Value;
  nfTaxDeferredDist.Enabled := not Value;
  nfTFNCredits.Enabled := not Value;
  nfForeignIncome.Enabled := not Value;
  nfCapitalGains.Enabled := not Value;
  nfDiscountedCapitalGains.Enabled := not Value;
  nfCapitalGainsOther.Enabled := not Value;
  nfOtherExpenses.Enabled := not Value;
  nfFranked.Enabled := not Value;
  nfUnfranked.Enabled := not Value;
  nfDiscountedCapitalGains.Enabled := not Value;
  eCGTDate.Enabled := not Value;
  cmbMember.Enabled := not Value;
  cmbFund.Enabled := not Value;
  cmbxAccount.Enabled := not Value;
  cmbTrans.Enabled := not Value;
  btnThird.Enabled := not Value;
  btnChart.Enabled := not Value;
  nfUnits.Enabled := not Value;

  btnClear.Enabled := not Value;

  // set the others fields
  SetSDMode(FSDMode);


end;

procedure TdlgEditDesktopFields.SetRevenuePercentage(const Value: boolean);
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

end;

procedure TdlgEditDesktopFields.SetupHelp;
begin
  Self.ShowHint    := INI_ShowFormHints;
  btnBack.Hint := 'Goto previous line|' +
                  'Goto previous line';

  btnNext.Hint := 'Goto next line|' +
                  'Goto next line';

  btnCalc.Hint := 'Calculate the Franking Credits|' +
                  'Calculate the Franking Credits';

  btnChart.Hint :=  '(F2) Lookup Chart|(F2) Lookup Chart';

  cmbxAccount.Hint := 'Select Chart code|Select Chart code';

  btnThird.Hint := 'Change Capital Gains fraction|Change Capital Gains fraction';

  if MyClient.clFields.clAccounting_System_Used = saClassSuperIP then
    Self.HelpContext := BKH_Coding_transactions_for_Class_Super
  else
    Self.HelpContext := BKH_Coding_transactions_for_Desktop_Super
end;

procedure TdlgEditDesktopFields.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  CGTDate : integer;
  HasValues: Boolean;
  ADate : TStDate;
begin
  UpdateDisplayTotals;
  CanClose := True;
  CGTDate := stNull2Bk( eCGTDate.AsStDate);
  ADate := bkDateUtils.bkStr2Date( eCGTDate.AsString );
  if FReadOnly
  and (FMoveDirection = fnNothing) then
     ModalResult := mrCancel;

  HasValues :=
    (nfFranked.AsFloat <> 0) or
    (nfUnfranked.AsFloat <> 0) or
    (nfForeignIncome.AsFloat <> 0) or
    (nfOtherExpenses.AsFloat <> 0) or
    (nfCapitalGainsOther.AsFloat <> 0) or
    (nfDiscountedCapitalGains.AsFloat <> 0) or
    (nfCapitalGains.AsFloat <> 0) or
    (nfTaxDeferredDist.AsFloat <> 0) or
    (nfTaxFreeDist.AsFloat <> 0) or
    (nfTaxExemptDist.AsFloat <> 0) or
    (nfTFNCredits.AsFloat <> 0) or
    (nfForeignCGCredit.AsFloat <> 0) or
    (nfOtherTaxCredit.AsFloat <> 0);


  {if (ModalResult = mrOK)
  and FrankPercentage then begin
     CanClose := true;
     Exit;
  end; }

  if (ModalResult = mrOK)
  and (lblRemain.Caption <> '-')
  and HasValues then begin
      HelpfulErrorMsg(format( 'There is %s remaining to be allocated.', [lblRemain.Caption]) , 0);
      CanClose := False;
  end
  else if (ModalResult = mrOk)
         and (((ADate=BadDate) and (CGTDate <> 0)) or ((CGTDate = 0) and HasValues)) and
            (eCGTDate.AsString <> '  /  /  ') then
  begin
    HelpfulWarningMSg( 'Please enter a valid CGT/Tax date.', 0);
    CanClose := False;
  end
  else if (ModalResult = mrOk) and HasValues and ((CGTDate <> 0) and ((CGTDate < MinValidDate) or (CGTDate > MaxValidDate))) and
    (eCGTDate.AsString <> '  /  /  ') then
  begin
    HelpfulWarningMsg( 'Please enter a valid CGT/Tax date.', 0);
    CanClose := False;
  end
  else if (ModalResult = mrOk)
       and (not ValidFundCode(FLedgerCode))
       and (not IsAllCleared)
       and (SDMode = sfPayee) then begin
    HelpfulWarningMsg( 'You cannot save this Payee as you have added Superfund ' +
                       'coding details, but you have not selected a Fund.  ' +
                       'Please select a Fund, or remove the Superfund details ' +
                       'if you want to save this Payee.', 0);
    CanClose := False;
  end;
end;

procedure TdlgEditDesktopFields.CalcControlTotals( var Count : Integer; var Total : Currency;
  gb: TGroupBox );
var
  i: integer;
  c: TOvcNumericField;
  m: Double;
begin
  Count := 0;
  Total := 0.0;
  for i := 0 to Pred(gb.ControlCount) do
  begin
    if gb.Controls[i] is TOvcNumericField then
    begin
      c := gb.Controls[i] as TOvcNumericField;
      m := c.AsFloat;
      if m <> 0 then
      begin
        Inc(Count);
        Total := Total + m;
      end;
    end;
  end;
end;

procedure TdlgEditDesktopFields.cmbClassSuperFundChange(Sender: TObject);
var
  i: integer;
begin
  FLedgerCode := '';
  if cmbClassSuperFund.ItemIndex <> -1 then
    FLedgerCode := GetClassSuperFundCode(cmbClassSuperFund.ItemIndex,
                                         cmbClassSuperFund.Items[cmbClassSuperFund.ItemIndex]);

  //Fill arrays
  FillArray(FundArray, ImportClassSuperList(fLedgerCode, cs_Investments));
  FillArray(MemberArray, ImportClassSuperList(fLedgerCode, cs_Members));

  //Reload combo boxes
  cmbFund.Clear;
  cmbMember.Clear;

  //Reload Funds
  cmbFund.Items.Add('');
  for i := Low(FundArray) to High(FundArray) do begin
    if FundArray[i].cl_ID <> -1 then
      cmbFund.Items.Add(Format ('%s : (%s)', [FundArray[i].cl_Code,   FundArray[i].cl_Description]));
  end;
  cmbFund.ItemIndex := -1;

  //reload member
  cmbMember.Items.Add('');
  for i := Low(MemberArray) to High(MemberArray) do
  begin
    if MemberArray[i].cl_ID <> -1 then
      cmbMember.Items.Add(MemberArray[i].cl_Description);
  end;
  cmbMember.ItemIndex := -1;
end;

procedure TdlgEditDesktopFields.cmbClassSuperFundDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbClassSuperFund.Width + 100, 0);
end;

procedure TdlgEditDesktopFields.cmbFundCloseUp(Sender: TObject);
begin
   cmbFund.SelStart := 0;
   cmbFund.SelLength := 0;
end;

procedure TdlgEditDesktopFields.cmbFundDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  cmbFund.canvas.Font := self.Font;

  cmbFund.canvas.fillrect(rect);
  if Index < 0 then begin
      if(odComboBoxEdit in State) then
        cmbFund.canvas.textout( rect.left + 2, rect.top, 'Ok then' );
  end else if Index > 0 then begin // if 0 test = ''
     cmbFund.canvas.textout( rect.left + 2, rect.top,  FundArray[index-1].cl_Code);
     if not (odComboBoxEdit in State) then
         cmbFund.canvas.textout( rect.left + cmbFund.Width ,rect.top, '(' + FundArray[ index-1].cl_Description + ')');
  end;
end;



procedure TdlgEditDesktopFields.cmbMemberDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  if Index = 0 then exit;
  cmbMember.canvas.fillrect(rect);
  cmbMember.canvas.textout( rect.left + 2, rect.top,  MemberArray[index-1].cl_Code);
  cmbMember.canvas.textout( rect.left + cmbMember.Width ,rect.top, '(' + MemberArray[ index-1].cl_Description + ')');
end;

procedure TdlgEditDesktopFields.cmbMemberDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbMember.Width + 350, 0);
end;

procedure TdlgEditDesktopFields.cmbSelectedFundChange(Sender: TObject);
var
  i: integer;
  D: boolean;
begin
  FLedgerCode := IntToStr(-1);
  if cmbSelectedFund.ItemIndex <> -1 then
    FLedgerCode := IntToStr(Integer(cmbSelectedFund.Items.Objects[cmbSelectedFund.ItemIndex]));

  //Fill arrays
  FillArray(FundArray, ImportDesktopCSV(DESKTOP_SUPER_INVESTMENT_FILENAME, 'Investment Code List'));
  FillArray(MemberArray, ImportDesktopCSV(DESKTOP_SUPER_MEMBER_FILENAME, 'Member Account List'));
  FillTransArray(TransArray, ImportDesktopCSV(DESKTOP_SUPER_TRANS_FILENAME, 'Transaction Types List'));

  //Reload combo boxes
  cmbFund.Clear;
  cmbMember.Clear;
  cmbTrans.Clear;
  //Reload trans
  cmbFund.Items.Add('');
  for i := Low(FundArray) to High(FundArray) do begin
    if FundArray[i].cl_ID <> -1 then
      cmbFund.Items.Add(Format ('%s : (%s)', [FundArray[i].cl_Code,   FundArray[i].cl_Description]));
  end;
  cmbFund.ItemIndex := -1;
  //reload invest
  cmbMember.Items.Add('');
  for i := Low(MemberArray) to High(MemberArray) do
  begin
    if MemberArray[i].cl_ID <> -1 then
      cmbMember.Items.Add(MemberArray[i].cl_Description);
  end;
  cmbMember.ItemIndex := -1;
  //Reload member
  cmbTrans.Items.Add('');
  D := False;
  for i := Low(TransArray) to High(TransArray) do
  begin
    if (TransArray[i].cl_ID > 100) and (not D) then
    begin
      FDepositStartIndex := i+1;
      D := True;
      cmbTrans.Items.Add('');
    end;
    if TransArray[i].cl_ID <> -1 then
      cmbTrans.Items.Add(TransArray[i].cl_Description);
  end;
  cmbTrans.ItemIndex := -1;
end;

procedure TdlgEditDesktopFields.cmbSelectedFundDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbSelectedFund.Width + 100, 0);
end;

procedure TdlgEditDesktopFields.cmbTransDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  if Index = 0 then exit;
  cmbTrans.canvas.fillrect(rect);
  if index = FDepositStartIndex then
    cmbTrans.canvas.textout( rect.left + 2, rect.top, '------------------------------------')
  else if index > FDepositStartIndex then
    cmbTrans.canvas.textout( rect.left + 2, rect.top,  TransArray[index-2].cl_Description)
  else
    cmbTrans.canvas.textout( rect.left + 2, rect.top,  TransArray[index-1].cl_Description);
end;

procedure TdlgEditDesktopFields.cmbTransDropDown(Sender: TObject);
begin
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbTrans.Width + 50, 0);
end;

procedure TdlgEditDesktopFields.cmbxAccountKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DOWN) or (Key = VK_NEXT) then
    FSkip := 1
  else if (Key = VK_UP) or (Key = VK_PRIOR) then
    FSkip := -1
  else
    FSkip := 0;
end;

procedure TdlgEditDesktopFields.cmbxAccountPropertiesChange(Sender: TObject);
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

procedure TdlgEditDesktopFields.cmbxAccountPropertiesDrawItem(
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

procedure TdlgEditDesktopFields.UpdateDisplayTotals;
var
  Count : Integer;
  Total, Taxtotal : Currency;
begin
  CalcControlTotals(Count, Total, gbRevenue);

  if FrankPercentage then begin
     lblGross.Caption  := Format( '%0.4f', [Total]  ) + '%';
     Total := 100 - Total;
     if Total = 0 then
        lblRemain.Caption := '-'
     else
        lblRemain.Caption := Format( '%0.4f', [100 - Total] ) + '%';
  end else begin
     CalcControlTotals(Count, TaxTotal, gbTax);
     lblGross.Caption  := Format( '%0.2m', [Total]);
     Total := FTranAmount - Total + TaxTotal;
     if Total = 0 then
        lblRemain.Caption := '-'
     else
        lblRemain.Caption := Format( '%0.2m', [Total] );
  end;
end;

function TdlgEditDesktopFields.ValidFundCode(AFundCode: string): boolean;
begin
  Result := False;
  case SuperSystem of
    saDesktopSuper: Result := (StrToIntDef(AFundCode,-1) <> -1);
    saClassSuperIP: Result := (FClassSuperFundList.Count = 0) or
                              (FClassSuperFundList.IndexOfName(AFundCode) <> -1);
  end;
end;

end.

