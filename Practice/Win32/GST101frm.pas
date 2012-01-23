unit GST101frm;
//------------------------------------------------------------------------------
{
   Title:

   Description: displays and prints the gST 101 report

   Author:

   Remarks:

   Last Reviewed :

}
//------------------------------------------------------------------------------

interface

uses
  Printers,
  rptParams,
  gstWorkRec,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcEF, OvcPB, OvcNF, ExtCtrls, StdCtrls, MoneyDef, bkConst, bkdefs,
  ComCtrls, WPRTEDefs, WPRTEPaint, WPCTRLabel,
  OsFont;

//------------------------------------------------------------------------------
const
  WM_AFTERSHOW = WM_USER + 900;



type
  TfrmGST101 = class(TForm)
    OvcController1: TOvcController;
    Label21: TLabel;
    Panel1: TPanel;
    chkDraft: TCheckBox;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnIR372: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    LblSubmit: TLabel;
    pgForm: TPageControl;
    TSPart1: TTabSheet;
    TsPart2: TTabSheet;
    TSPart3: TTabSheet;
    sbGST: TScrollBox;
    GBGST: TGroupBox;
    lMain1: TLabel;
    Image15: TImage;
    Label50: TLabel;
    Label52: TLabel;
    Label55: TLabel;
    Label24: TLabel;
    Label11: TLabel;
    Image16: TImage;
    LSmall1: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    lblBasis: TLabel;
    lblPeriod: TStaticText;
    lblDateFrom: TStaticText;
    lblDateTo: TStaticText;
    lblDueDate: TStaticText;
    lblGSTno: TStaticText;
    pnlDebtors: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    lblIncome: TStaticText;
    nClosingDebt: TOvcNumericField;
    nOpeningDebt: TOvcNumericField;
    pnlCreditors: TGroupBox;
    Label6: TLabel;
    Label8: TLabel;
    Label14: TLabel;
    lblPurchases: TStaticText;
    nClosingCR: TOvcNumericField;
    nOpeningCR: TOvcNumericField;
    pnlSales: TGroupBox;
    Image5: TImage;
    imgFBT: TImage;
    Image3: TImage;
    Image2: TImage;
    Image1: TImage;
    L6: TLabel;
    L5: TLabel;
    L7: TLabel;
    lblFringeBenefits: TLabel;
    L8: TLabel;
    LI5: TLabel;
    LI6: TLabel;
    LI7: TLabel;
    LI8: TLabel;
    Label42: TLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    lblTotalSalesInc: TStaticText;
    lblZeroRated: TStaticText;
    lblSubtract6: TStaticText;
    lblDivide7: TStaticText;
    nFringe: TOvcNumericField;
    pnlTotalGST: TPanel;
    I372: TImage;
    L9: TLabel;
    LI9: TLabel;
    Image6: TImage;
    LI10: TLabel;
    L10: TLabel;
    Bevel5: TBevel;
    lblTotalGSTCollected: TStaticText;
    nDrAdjust: TOvcNumericField;
    pnlPurchases: TGroupBox;
    L12: TLabel;
    L11: TLabel;
    L13: TLabel;
    L14: TLabel;
    Image8: TImage;
    I372C: TImage;
    Image10: TImage;
    Image11: TImage;
    LI11: TLabel;
    LI12: TLabel;
    LI13: TLabel;
    LI14: TLabel;
    Label43: TLabel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    lblTotalPurch: TStaticText;
    lblDivide12: TStaticText;
    lblTotalGSTCredit: TStaticText;
    nCRAdjust: TOvcNumericField;
    GBAddress: TGroupBox;
    lblName: TLabel;
    lblAddr1: TLabel;
    lblAddr2: TLabel;
    lblAddr3: TLabel;
    SBProvisional: TScrollBox;
    GbProvisional: TGroupBox;
    lMain2: TLabel;
    LSmall2: TLabel;
    GroupBox4: TGroupBox;
    SBPayment: TScrollBox;
    gbPayment: TGroupBox;
    LMain3: TLabel;
    Label56: TLabel;
    LSmall3: TLabel;
    Label61: TLabel;
    GroupBox3: TGroupBox;
    Image23: TImage;
    Image24: TImage;
    Image25: TImage;
    Bevel16: TBevel;
    Bevel17: TBevel;
    Bevel18: TBevel;
    Image27: TImage;
    Image29: TImage;
    Label73: TLabel;
    Label74: TLabel;
    Label75: TLabel;
    WPRichTextLabel1: TWPRichTextLabel;
    WPRichTextLabel3: TWPRichTextLabel;
    Bevel12: TBevel;
    WPRichTextLabel5: TWPRichTextLabel;
    WPRichTextLabel7: TWPRichTextLabel;
    Label23: TLabel;
    Label25: TLabel;
    lbl27: TStaticText;
    lbl26: TStaticText;
    lbTaxToPay: TStaticText;
    E25: TOvcNumericField;
    E24: TOvcNumericField;
    TsPart1B: TTabSheet;
    GroupBox1: TGroupBox;
    lMain1B: TLabel;
    LSmall1B: TLabel;
    lblBasisB: TLabel;
    pnlDebtorsB: TGroupBox;
    Label60: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    lblIncomeB: TStaticText;
    nClosingDebtB: TOvcNumericField;
    nOpeningDebtB: TOvcNumericField;
    pnlCreditorsB: TGroupBox;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    lblPurchasesB: TStaticText;
    nClosingCRB: TOvcNumericField;
    nOpeningCRB: TOvcNumericField;
    pnlSalesB: TGroupBox;
    Image28: TImage;
    imgFBTB: TImage;
    Image31: TImage;
    Image32: TImage;
    Image33: TImage;
    L6B: TLabel;
    L5B: TLabel;
    L7B: TLabel;
    lblFringeBenefitsB: TLabel;
    L8B: TLabel;
    LI5B: TLabel;
    LI6B: TLabel;
    LI7B: TLabel;
    LI8B: TLabel;
    Label79: TLabel;
    Bevel15: TBevel;
    Bevel19: TBevel;
    lblTotalSalesIncB: TStaticText;
    lblZeroRatedB: TStaticText;
    lblSubtract6B: TStaticText;
    lblDivide7B: TStaticText;
    nFringeB: TOvcNumericField;
    pnlTotalGSTB: TPanel;
    I372B: TImage;
    L9B: TLabel;
    LI9B: TLabel;
    Image35: TImage;
    LI10B: TLabel;
    L10B: TLabel;
    Bevel20: TBevel;
    lblTotalGSTCollectedB: TStaticText;
    nDrAdjustB: TOvcNumericField;
    pnlPurchasesB: TGroupBox;
    L12B: TLabel;
    L11B: TLabel;
    L13B: TLabel;
    L15B: TLabel;
    L14B: TLabel;
    Image36: TImage;
    I372DB: TImage;
    Image38: TImage;
    Image39: TImage;
    Image40: TImage;
    LI11B: TLabel;
    LI12B: TLabel;
    LI13B: TLabel;
    LI14B: TLabel;
    LI15B: TLabel;
    Label94: TLabel;
    Bevel21: TBevel;
    Bevel22: TBevel;
    Bevel23: TBevel;
    lblRefundB: TLabel;
    Label96: TLabel;
    Shape3: TShape;
    Shape4: TShape;
    cirRefundB: TShape;
    cirGSTtoPayB: TShape;
    lblTotalPurchB: TStaticText;
    lblDivide12B: TStaticText;
    lblTotalGSTCreditB: TStaticText;
    lblGSTCollected: TStaticText;
    nCRAdjustB: TOvcNumericField;
    lblGSTCredit: TStaticText;
    lblDifferenceB: TStaticText;
    L16B: TLabel;
    L17B: TLabel;
    p15A: TPanel;
    L15: TLabel;
    lblDifference: TStaticText;
    I15: TImage;
    LI15: TLabel;
    cirGSTtoPay: TShape;
    Shape2: TShape;
    lblToPay: TLabel;
    Shape1: TShape;
    cirRefund: TShape;
    lblRefund: TLabel;
    Image7: TImage;
    Image9: TImage;
    LI16B: TLabel;
    LI17B: TLabel;
    PLeft: TPanel;
    WPRichTextLabel6: TWPRichTextLabel;
    ERatio: TOvcNumericField;
    PRight: TPanel;
    P16: TPanel;
    I16: TImage;
    LI16: TLabel;
    lbl16: TStaticText;
    Bevel24: TBevel;
    P17: TPanel;
    LR17: TWPRichTextLabel;
    E17: TOvcNumericField;
    I17: TImage;
    LI17: TLabel;
    P18: TPanel;
    LR18: TWPRichTextLabel;
    Bevel9: TBevel;
    I18: TImage;
    LI18: TLabel;
    lbl18: TStaticText;
    P19: TPanel;
    LR19: TWPRichTextLabel;
    E19: TOvcNumericField;
    I19: TImage;
    LI19: TLabel;
    L16: TLabel;
    Label29: TLabel;
    Bevel1: TBevel;
    p20: TPanel;
    Image21: TImage;
    L20: TLabel;
    LR20: TWPRichTextLabel;
    Bevel10: TBevel;
    lbl20: TStaticText;
    LR21: TWPRichTextLabel;
    Bevel13: TBevel;
    Image19: TImage;
    LI21: TLabel;
    E21: TOvcNumericField;
    Bevel14: TBevel;
    LR22: TWPRichTextLabel;
    I22: TImage;
    LI22: TLabel;
    LR23: TWPRichTextLabel;
    lbl22: TStaticText;
    I23: TImage;
    LI23: TLabel;
    lbProvTax: TStaticText;
    Bevel2: TBevel;
    L25: TLabel;
    L27: TLabel;
    lPart2Total: TLabel;
    lblLinkToGST105: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormDestroy(Sender: TObject);
    procedure nFringeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure nClosingDebtKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbRefundEnter(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure GST372Action(Sender: TObject);
    procedure LblSubmitClick(Sender: TObject);
    procedure nDrAdjustChange(Sender: TObject);
    procedure Image23Click(Sender: TObject);
    procedure E25Change(Sender: TObject);
    procedure nClosingDebtChange(Sender: TObject);
    procedure nOpeningDebtBChange(Sender: TObject);
    procedure lblLinkToGST105Click(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    d1, d2: integer;
    DueDate: integer;

    Balances,This,Prev,Next : pBalances_Rec;
    FGST_PaymentBasis: Boolean;
    CustomFormHeight : integer;
    FRptParams: TrptParameters;
    FDoPart3: Boolean;
    FDoPart2: Boolean;
    FFormType: TFormType;
    E25Manual: Boolean;
    FFormPeriod: TFormPeriod;
    FormBOpeningCreditChanged,
    FormBOpeningDebitChanged : Boolean;
    procedure CalculateGST;
    procedure DisplayFigures;
    procedure Save;
    procedure SetGST_PaymentBasis(const Value: Boolean);
    procedure SetRptParams(const Value: TrptParameters);
    procedure SetDoPart2(const Value: Boolean);
    procedure SetDoPart3(const Value: Boolean);
    procedure SetFormType(const Value: TFormType);
    procedure Open372(FormA:Boolean; Close101OnCancel: Boolean = False);
    procedure SetFormPeriod(const Value: TFormPeriod);
    property GST_PaymentBasis : Boolean read FGST_PaymentBasis write SetGST_PaymentBasis;
    function EnableAdjustmentEdit(Form: TGSTForm): Boolean;
    procedure CheckAdjustments;
    function EncodeHTML(s: string): string;
    property DoPart2: Boolean read FDoPart2 write SetDoPart2;
    property DoPart3: Boolean read FDoPart3 write SetDoPart3;
    property FormType: TFormType read FFormType write SetFormType;

    function GetGSTRate(ForDate: Integer): Double;
  protected
    procedure WMAfterShow(var Message: TMessage); message WM_AFTERSHOW;
    procedure UpdateActions; override;
  public
    { Public declarations }
    Figures: pGSTWorkRec;
    function Execute : boolean;
    property RptParams: TrptParameters read FRptParams write SetRptParams;
    property FormPeriod: TFormPeriod read FFormPeriod write SetFormPeriod;
  end;


procedure ShowGST101Form ( Fromdate: Integer = 0;
                           ToDate: integer = 0;
                           Params: TrptParameters = nil);




//******************************************************************************
implementation

uses
  Math,
  ShellApi,
  bkXPThemes,
  bkhelp,
  glConst,
  Globals,
  ErrorMoreFrm,
  InfoMoreFrm,
  EditGSTDlg,
  WarningMoreFrm,
  pddates32,
  SelectGSTPeriodDlg,
  baobj32,
  BKBLIO,
  gstUtil32,
  YesnoDlg,
  finalise32,
  bkutil32,
  GenUtils,
  bkDateUtils,
  ReportDefs,
  RptGST101,
  StdHints,
  stDate,
  stDateSt,
  TravUtils,
  UBatchBase,
  GST372frm,
  MonitorUtils;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmGST101.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  GetMem(Figures,Sizeof(rGSTWorkRec));
  Panel1.Font := Application.MainForm.Font;
  SetHyperlinkFont(LBLSubmit.Font);
   SetHyperlinkFont(lblLinkToGST105.Font);
  
                      //800
  CustomFormHeight := 800;  //done leave this to windows or it will mess it up

  This := nil;
  Prev := nil;
  Next := nil;

  if Assigned( AdminSystem) then
  begin
    if ( not CurrUser.HasRestrictedAccess) then
      lblSubmit.Caption := PRACINI_GST101Link
    else
      //users with restricted access should not be able to launch the browser
      lblSubmit.Caption := '';
  end
  else
    lblSubmit.Caption := PRACINI_GST101Link;

  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   BKHelpSetUp( Self, BKH_GST_Return_GST_101);
   //Components
   nClosingDebt.Hint   :=
                       'Enter the closing debtors figure|' +
                       'Enter the closing debtors figure';
   nClosingDebtB.Hint  := nClosingDebt.Hint;

   nOpeningDebt.Hint   :=
                       'Enter the opening debtors figure|' +
                       'Enter the opening debtors figure';
   nOpeningDebtB.Hint   := nOpeningDebt.Hint;

   nFringe.Hint        :=
                       'Enter any adjustment for fringe benefits|' +
                       'Enter any adjustment for fringe benefits';
   nFringeB.Hint       := nFringe.Hint;

   nDrAdjust.Hint      :=
                       'Enter any adjustments from the calculation sheet|' +
                       'Enter any adjustments from the calculation sheet';
   nDrAdjustB.Hint     := nDrAdjust.Hint;

   nClosingCR.Hint     :=
                       'Enter the closing creditors figure|' +
                       'Enter the closing creditors figure';
   nClosingCRB.Hint    := nClosingCR.Hint;

   nOpeningCR.Hint     :=
                       'Enter the opening creditors figure|' +
                       'Enter the opening creditors figure';
   nOpeningCRB.Hint    := nOpeningCR.Hint;

   nCRAdjust.Hint      :=
                       'Enter any credit adjustments|' +
                       'Enter any credit adjustments';
   nCRAdjustB.Hint     := nCRAdjust.Hint;

   btnPreview.Hint     :=
                       STDHINTS.PreviewHint;
   btnPrint.Hint       :=
                       STDHINTS.PrintHint;
end;
procedure TfrmGST101.UpdateActions;
begin
  inherited;
  btnIR372.Enabled := (FormPeriod <> transitional)
                   or (PgForm.ActivePage = tsPart1)
                   or (PgForm.ActivePage = tsPart1B);

end;

procedure TfrmGST101.WMAfterShow(var Message: TMessage);
begin
    ShowMessage('The calculated IR372 adjustment amounts do not match the GST Return adjustment amounts. The GST Return amounts have been moved to the IR372.');
    case Message.WParam of
    1: begin
         pgForm.ActivePage := TsPart1;
         Open372(True, true);
       end;
    2: begin
         pgForm.ActivePage := TsPart1B;
         Open372(False, true);
       end;
    end;

end;

//------------------------------------------------------------------------------
procedure TfrmGST101.FormDestroy(Sender: TObject);
begin
   FreeMem(Figures,Sizeof(rGSTWorkRec));
end;
//------------------------------------------------------------------------------
Procedure R2M( R : TGSTForm; Var M : mGSTWorkRec );
Begin
   With R, M do
   Begin
      mI_Ledger       := Double2money(rIncome_Ledger);
      mC_Debtors      := Double2money(rClosing_Debtors);
      mO_Debtors      := Double2money(rOpening_Debtors);
      mBox_5          := Double2money(rBox_5);
      mZ_Rated_Sup    := Double2money(rZ_Rated_Sup);
      mBox_7          := Double2money(rBox_7);
      mBox_8          := Double2money(rBox_8);
      mFBT_Adjust     := Double2money(rFBT_Adjust);
      mOther_Adjust   := Double2money(rOther_Adjust);
      mGST_Collected  := Double2money(rGST_Collected);
      mE_Ledger       := Double2money(rExendature_Ledger);
      mC_Creditors    := Double2money(rClosing_Creditors);
      mO_Creditors    := Double2money(rOpening_Creditors);

      mTotal_Purch    := Double2money(rTotal_Purch);
      mTotal_Purch_Div_9   := Double2money(rTotal_Purch_GST);
      mCredit_Adjust  := Double2money(rCredit_Adjust );
      mGST_Credit     := Double2money(rGST_Credit);

      //mGST_To_Pay     := Double2money( rGST_To_Pay    );
   end;
end;
//------------------------------------------------------------------------------
Procedure M2R( M : mGSTWorkRec; Var R : TGSTForm );
Begin
   With R, M do
   Begin
      rIncome_Ledger  := Money2Double( mI_Ledger       );
      rClosing_Debtors  := Money2Double( mC_Debtors      );
      rOpening_Debtors  := Money2Double( mO_Debtors      );
      rBox_5         := Money2Double( mBox_5          );
      rZ_Rated_Sup   := Money2Double( mZ_Rated_Sup    );
      rBox_7         := Money2Double( mBox_7          );
      rBox_8         := Money2Double( mBox_8          );
      rFBT_Adjust    := Money2Double( mFBT_Adjust     );
      rOther_Adjust  := Money2Double( mOther_Adjust   );
      rGST_Collected := Money2Double( mGST_Collected  );
      rExendature_Ledger      := Money2Double( mE_Ledger       );
      rClosing_Creditors   := Money2Double( mC_Creditors    );
      rOpening_Creditors   := Money2Double( mO_Creditors    );
      rTotal_Purch        := Money2Double( mTotal_Purch         );
      rTotal_Purch_GST        := Money2Double( mTotal_Purch_Div_9         );
      rCredit_Adjust := Money2Double( mCredit_Adjust  );
      rGST_Credit    := Money2Double( mGST_Credit     );
      
      //rGST_To_Pay    := Money2Double( mGST_To_Pay     );
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.btnOKClick(Sender: TObject);
begin
  okPressed := true;
  Close;
end;
//------------------------------------------------------------------------------
(* *)
procedure TfrmGST101.btnPrintClick(Sender: TObject);
begin

  //save the figures
  Save;

  Figures.rDraftModePrinting := chkDraft.Checked;

  if DoGST101Report(rdPrinter,self,RptParams) then
{$IFNDEF SmartBooks}
    if (not Figures.rDraftModePrinting) and (IsLocked(Figures.rFromDate,Figures.rToDate) <> ltAll) then begin
       if (AskYesNo('Finalise Accounting Period','You have printed the GST Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str(Figures.rFromDate)+' - '+bkDate2Str(figures.rToDate)+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod(Figures.rFromDate,Figures.rToDate);
       end;
    end;
{$ENDIF}

end;




//------------------------------------------------------------------------------
procedure TfrmGST101.btnPreviewClick(Sender: TObject);
begin
  //save the figures
  Save;

  Figures.rDraftModePrinting := chkDraft.Checked;
  if DoGST101Report(rdScreen,self) then
{$IFNDEF SmartBooks}
    if (not Figures.rDraftModePrinting) and (IsLocked(Figures.rFromDate,Figures.rToDate) <> ltAll) then begin
       if (AskYesNo('Finalise Accounting Period','You have printed the GST Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str(Figures.rFromDate)+' - '+bkDate2Str(figures.rToDate)+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod(Figures.rFromDate,Figures.rToDate);
       end;
    end;
{$ENDIF}
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.btnCancelClick(Sender: TObject);
begin
  close;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.DisplayFigures;
var tD: Double;
begin

  with Figures^ do
  begin
    //read current figures
    with FormA do begin
       rClosing_Debtors := nClosingDebt.asfloat;
       rOpening_Debtors := nOpeningDebt.asFloat;
       rFBT_Adjust := nFringe.AsFloat;
       rOther_Adjust := nDrAdjust.AsFloat;
       rClosing_Creditors := nClosingCr.asfloat;
       rOpening_Creditors := nOpeningCR.AsFloat;
       rCredit_Adjust := nCRAdjust.asfloat;
    end;
    with FormB do begin
       rClosing_Debtors := nClosingDebtB.asfloat;
       rOpening_Debtors := nOpeningDebtB.asFloat;
       rFBT_Adjust := nFringeB.AsFloat;
       rOther_Adjust := nDrAdjustB.AsFloat;
       rClosing_Creditors := nClosingCrB.asfloat;
       rOpening_Creditors := nOpeningCRB.AsFloat;
       rCredit_Adjust := nCRAdjustB.asfloat;
    end;

    //Provisional tax
    rpt_LastMonthIncome := E17.AsFloat;
    rpt_BranchIncome    := E19.AsFloat;
    rpt_Assets          := E21.AsFloat;
    rpt_Ratio           := ERatio.AsFloat;
    rpt_RefundUsed      := E25.AsFloat;

    //Work out the rest..
    CalculateGST;

    // Fill them in.
    with FormA do begin
        //sales
       lblTotalSalesInc.Caption     := FormatFloat('#,##0.00',rBox_5);
       lblZeroRated.caption         := FormatFloat('#,##0.00',rZ_Rated_Sup);
       lblSubtract6.caption         := FormatFloat('#,##0.00',rBox_7);
       lblDivide7.caption           := FormatFloat('#,##0.00',rBox_8);
       lblTotalGSTCollected.caption := FormatFloat('#,##0.00',rGST_Collected);
       //purchases
       lblTotalPurch.Caption        := FormatFloat('#,##0.00',rTotal_Purch);
       lblDivide12.caption          := FormatFloat('#,##0.00',rTotal_Purch_GST);
       lblTotalGSTCredit.caption    := FormatFloat('#,##0.00',rGST_Credit);

    end;
    if FormPeriod = Transitional then with FormB do begin
       lblTotalSalesIncB.Caption     := FormatFloat('#,##0.00',rBox_5);
       lblZeroRatedB.caption         := FormatFloat('#,##0.00',rZ_Rated_Sup);
       lblSubtract6B.caption         := FormatFloat('#,##0.00',rBox_7);
       lblDivide7B.caption           := FormatFloat('#,##0.00',rBox_8);
       lblTotalGSTCollectedB.caption := FormatFloat('#,##0.00',rGST_Collected);

       //purchases
       lblTotalPurchB.Caption        := FormatFloat('#,##0.00',rTotal_Purch);
       lblDivide12B.caption          := FormatFloat('#,##0.00',rTotal_Purch_GST);
       lblTotalGSTCreditB.caption    := FormatFloat('#,##0.00',rGST_Credit);

       // Total on page 2..
       //difference

       lblGSTCollected.Caption := FormatFloat('#,##0.00',rGST_Collected + FormA.rGST_Collected);
       lblGSTCredit.Caption := FormatFloat('#,##0.00',rGST_Credit + FormA.rGST_Credit);
       lblDifferenceB.caption  := FormatFloat('#,##0.00',rGST_To_Pay);

       if rGST_to_Pay > 0 then begin
          cirGSTToPayB.Visible  := true;
          cirRefundB.Visible    := false;
       end else begin
          cirGSTToPayB.Visible  := false;
          cirRefundB.Visible    := true;
       end;

    end else begin
       // Totals on page 1

       //difference
       lblDifference.caption        := FormatFloat('#,##0.00',rGST_To_Pay);

       if rGST_to_Pay > 0 then begin
          cirGSTToPay.Visible  := true;
          cirRefund.Visible    := false;
       end else begin
          cirGSTToPay.Visible  := false;
          cirRefund.Visible    := true;
       end;
    end;

    //Provisional tax
    if DoPart2 then begin
       // Have a ratio and its a compulsory period
       td := FormA.rBox_5;
       if (LSmall1B.Caption <> 'GST 103B') then
         td := td + FormB.rBox_5;
       lbl16.Caption := FormatFloat('#,##0.00',td);
       td := td + rpt_LastMonthIncome;
       lbl18.Caption := FormatFloat('#,##0.00',td);
       td := td + rpt_BranchIncome;
       lbl20.Caption := FormatFloat('#,##0.00',td);
       td := td - rpt_Assets;
       lbl22.Caption := FormatFloat('#,##0.00',td);
       td := td * rpt_Ratio / 100; // %
       lbProvtax.Caption := FormatFloat('#,##0.00',td);

       e24.AsFloat := td; // Forced..
       rpt_Tax := td;
    end else begin
       rpt_Tax := e24.AsFloat; // Use what was typed
    end;

    if DoPart3 then begin
       if rGST_to_Pay < 0  then begin
          if E25Manual then begin
             // Has been manually modified
             td := rpt_Tax - rpt_RefundUsed;
             if td < 0 then
                td := 0;
          end else begin
             rpt_RefundUsed := min(- rGST_to_Pay, rpt_Tax);
             E25.AsFloat := rpt_RefundUsed;
             td := rpt_Tax - rpt_RefundUsed;
          end;
          lbl26.Caption := FormatFloat('#,##0.00',td);
          lbl27.Caption := FormatFloat('#,##0.00',0);
          lbTaxToPay.Caption := FormatFloat('#,##0.00',td);
       end else begin
          // GST to pay
          E25.AsFloat := 0; // Has to be...
          E25Manual := False;
          rpt_RefundUsed := 0;
          lbl26.Caption := FormatFloat('#,##0.00',rpt_Tax);
          lbl27.Caption := FormatFloat('#,##0.00',rGST_to_Pay );
          lbTaxToPay.Caption := FormatFloat('#,##0.00',rGST_to_Pay + rpt_Tax );
       end;
    end;
  end;//Figures
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.nFringeChange(Sender: TObject);
begin
   DisplayFigures;
end;

procedure TfrmGST101.nOpeningDebtBChange(Sender: TObject);
begin
   if Sender = nOpeningDebtB then
      FormBOpeningDebitChanged := true
   else if sender = nOpeningCRB then
      FormBOpeningCreditChanged := true;

   nFringeChange(nil);   
end;

//------------------------------------------------------------------------------
procedure TfrmGST101.FormShow(Sender: TObject);
begin

   if (Self.Monitor.WorkareaRect.Bottom - Self.Monitor.WorkareaRect.Top) < CustomFormHeight then begin
     Self.Top := Self.Monitor.WorkareaRect.Top;
     Self.Height := Self.Monitor.WorkareaRect.Bottom - Self.Monitor.WorkareaRect.Top;
     Self.Left := Self.Monitor.WorkareaRect.Left
                + ((Self.Monitor.WorkareaRect.Right - Self.Monitor.WorkareaRect.Left) - Self.Width) div 2;
  end else begin
     Self.Height := CustomFormHeight;
     Self.Left := Self.Monitor.WorkareaRect.Left
                + ((Self.Monitor.WorkareaRect.Right - Self.Monitor.WorkareaRect.Left) - Self.Width) div 2;
     Self.Top := Self.Monitor.WorkareaRect.Top
                + ((Self.Monitor.WorkareaRect.Bottom - Self.Monitor.WorkareaRect.Top) - CustomFormHeight) div 2;
  end;

  nClosingDebt.SelectAll;
  LockWindowUpdate(0);
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.nClosingDebtChange(Sender: TObject);
begin
    // could do them independant
    // but this way its more obvious what is happening...
    if sender = nClosingDebt then begin
       if not FormBOpeningDebitChanged then
          nOpeningDebtB.AsFloat := nClosingDebt.AsFloat;
    end else if sender = nClosingCR then begin
       if not FormBOpeningCreditChanged then
          nOpeningCRB.AsFloat := nClosingCR.AsFloat;
    end;


   nFringeChange(nil);
end;

procedure TfrmGST101.nClosingDebtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 {translate enter to tab}
  if Key = 13 then
  begin
    Key := 9;
    PostMessage(TOvcNumericField(Sender).Handle,WM_KeyDown,9,1);
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.rbRefundEnter(Sender: TObject);
begin
   nCRAdjust.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.CalculateGST;
Var
   M : mGSTWorkRec;

   procedure DoCalc(ForDate: TStDate);
   begin
      With M do Begin { Do the calculation }
         mBox_5              := mI_Ledger + mC_Debtors - mO_Debtors;
         mBox_7              := mBox_5 - mZ_Rated_Sup;
         mBox_8              := Round( mBox_7 * GetGSTRate(ForDate) );
         mGST_Collected      := mBox_8 + mFBT_Adjust + mOther_Adjust;
         mTotal_Purch        := mE_Ledger + mC_Creditors - mO_Creditors;
         mTotal_Purch_Div_9  := Round( mTotal_Purch * GetGSTRate(ForDate) );
         mGST_Credit         := mTotal_Purch_Div_9 + mCredit_Adjust;

      end;
   end;
Begin
   R2M(Figures.FormA, M);
   DoCalc(D1);
   M2R(M, Figures.FormA);

   R2M(Figures.FormB, M);
   DoCalc(D2);
   M2R(M, Figures.FormB);

  //  mGST_To_Pay         := mGST_Collected - mGST_Credit;
   Figures.rGST_To_Pay := Figures.FormA.rGST_Collected - Figures.FormA.rGST_Credit;

   //TFS 4031 Only use the FormB figures if this is a transitional GST return
   //because the Closing Creditors and Closing Debtors balances are carried
   //forward to from FormA and they will negate each other in the GST calculation.
   if FormPeriod = Transitional then
     Figures.rGST_To_Pay := Figures.rGST_To_Pay + Figures.FormB.rGST_Collected -
                            Figures.FormB.rGST_Credit;
end;
//------------------------------------------------------------------------------
function TfrmGST101.Execute: boolean;
var
  l1,l2,n1,n2 : integer;

  IncomeA,ExpenditureA,ZeroRatedA,
  IncomeB,ExpenditureB,ZeroRatedB : money;
  GST_EA, GST_IA, GST_CA,
  GST_EB, GST_IB, GST_CB : money;

  b : integer;
  j : integer;
  GSTInfoA,
  GSTInfoB : TGSTInfo;
  d, m, y : integer;

  function ComplusoryPeriod: Boolean;
  var I: Integer;
  begin
     Result := False;
     // Check which month..
     StDateToDmy(d2, d, m, y);
     y := MyClient.clFields.clGST_Start_Month;
     for I := 1 to 6 do begin
       if m = y then
          Exit;
       y := (y + 2);
       if y > 12 then
         y := y - 12;
     end;
     // Should realy confirm the period length
     Result := True;
  end;

  procedure FillGSTInfo(D1,D2: Integer;
            var GSTInfo: TGSTInfo;
            var Income, Expenditure, ZeroRated, GST_Custom: money;
            var GST_E, GST_I: money);
  var gstClass: Integer;
  begin
     GSTUTIL32.CalculateGSTTotalsForPeriod(D1,D2,GSTInfo, -1);
     with GSTInfo do begin
        ZeroRated := 0;
        GST_Custom := 0;
        GST_I := 0;
        GST_E := 0;

        //back calculate the GST values - makes sure that the GST Income div 9 comes up with the actual gst calculated
        //                              - same for GST Expense.
        //                              - this is common practice amongst our clients

        for gstClass := 1 to MAX_GST_CLASS do
           case MyClient.clFields.clGST_Class_Types[ gstClass ] of
            gtIncomeGST      : {I}  GST_I := GST_I + guGST_Totals[gstClass];   // I := I + guAmount_Totals[ gstClass ];
            gtExpenditureGST : {E}  GST_E := GST_E + guGST_Totals[gstClass];   // E := E + guAmount_Totals[ gstClass ];
            gtExempt         : {X}  ;
            gtZeroRated      : {Z}  ZeroRated := ZeroRated + guGross_Totals[ gstClass ];
            gtCustoms        : {C}  GST_Custom := GST_Custom + guGST_Totals[gstClass];
           end;

         //have gst so sort out what income and expense values should be...
         Income := GST_I / GetGSTRate(D1);
         Expenditure := GST_E / GetGSTRate(D1);
      end;
  end;

  procedure GetLastMonth(D1,D2: Integer);
  var  GSTInfo : TGSTInfo;
       i,e,z,c : money;
       GST_E, GST_I : money;
  begin
     if not assigned(Prev) then
        Exit;
     if MyClient.clFields.clGST_Period <> gpMonthly then
        Exit;
     // Only If Monthly ?
     FillGSTInfo(D1,D2,GSTInfo,i,e,z,c,GST_E, GST_I);
     if GSTInfo.guHasUncodes then
        Exit; // No Point
     // make sure we have the same rounding...
     Figures.rpt_LastMonthIncome :=
          Money2Double( -I )
        + Money2Double( -Z )
        + Money2Double(Prev.blClosing_Debtors_Balance)
        - Money2Double(Prev.blOpening_Debtors_Balance);

  end;

  function CalculatedCreditAdjustment(AGstWorkRec: TGSTForm): Double;
  var
    TempVal: Money;
  begin
    TempVal := Double2Money(AGstWorkRec.rAcrt_Use + AGstWorkRec.rAcrt_Private +
                            AGstWorkRec.rAcrt_Change + AGstWorkRec.rAcrt_Customs +
                            AGstWorkRec.rAcrt_Other);
    Result := Money2Double(TempVal);
  end;

  function HasManualCreditAdjustment(AGstWorkRec: TGSTForm): boolean;
  begin
    Result := (AGstWorkRec.rAcrt_Use + AGstWorkRec.rAcrt_Private +
               AGstWorkRec.rAcrt_Change + AGstWorkRec.rAcrt_Other) <> 0;
  end;

begin
   Result := false;
   with MyClient, MyClient.clFields do begin
      // Address and other common bits
      lblName.Caption     := clName;
      lblAddr1.caption    := clAddress_L1;
      lblAddr2.caption    := clAddress_L2;
      lblAddr3.caption    := clAddress_L3;

      lblGSTno.caption := clGST_Number;

      // Case #7725 introduced custom periods...
      case GetPeriodMonths(d1,d2) of
      1 : lblPeriod.Caption := gpNames[gpMonthly];
      2 : lblPeriod.Caption := gpNames[gp2Monthly];
      6 : lblPeriod.Caption := gpNames[gp6Monthly];
      else lblPeriod.Caption := '';
      end;

      lblBasis.caption := Uppercase( gbNames[clGST_Basis]) + ' BASIS';
      lblBasisB.caption := lblBasis.caption;

      lblDateFrom.Caption := bkDate2Str(d1);
      lblDateTo.caption   := bkDate2Str(d2);

      // Work out the Return / Payment date
      StDateToDmy(d2, d, m, y);
      Inc (m);
      if m > 12 then begin
         m := 1;
         Inc( y);
      end;
      if d1 >= DMYToStDate(1, 3, 2007, BKDATEEPOCH) then begin
         // returns after 01/04/07 always 28th of the following month
         // except if due in Dec it becomes 15 Jan
         // except if due in Mar it becomes 7 May
         // for earlier dates returns are due on the last business day of the following month
         if m = 12 then
            DueDate := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(15, 1, y + 1, BKDATEEPOCH))
         else if m = 4 then
            DueDate := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(7, m + 1, y, BKDATEEPOCH))
         else
            DueDate := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(28, m, y, BKDATEEPOCH));
      end else begin
         if m = 12 then
            DueDate := bkDateUtils.NextBusinessDay_NZ( DmyToStDate( 15, 1, y + 1, BKDATEEPOCH))
         else
            DueDate := bkDateUtils.LastBusinessDayInMth_NZ( m, y);
      end;
      lblDueDate.caption := StDateToDateString( 'dd NNN yyyy', DueDate, true);


      FillChar(GSTInfoA, Sizeof(GSTInfoA),0);
      FillChar(GSTInfoB, Sizeof(GSTInfoB),0);
      FormBOpeningCreditChanged := False;
      FormBOpeningDebitChanged := False;
        // Work out Form Period
      if d2 < GSTRateChangeDate then begin
         FormPeriod := PreOct2010;
         FillGSTInfo(D1,D2,GSTInfoA,IncomeA ,ExpenditureA,ZeroRatedA, GST_CA ,GST_EA, GST_IA);
      end else if d1 >= GSTRateChangeDate then begin
         FormPeriod := PostOct2010;
         FillGSTInfo(D1,D2,GSTInfoA,IncomeA ,ExpenditureA,ZeroRatedA, GST_CA ,GST_EA, GST_IA);
      end else begin
         FormPeriod := Transitional;
         FillGSTInfo(D1,GSTRateChangeDate -1,GSTInfoA, IncomeA ,ExpenditureA, ZeroRatedA, GST_CA ,GST_EA, GST_IA);
         FillGSTInfo(GSTRateChangeDate, D2,  GSTInfoB, IncomeB ,ExpenditureB, ZeroRatedB, GST_CB ,GST_EB, GST_IB);
      end;

      //get initial calculated figures

      if GSTInfoA.guHasUncodes
      or GSTInfoB.guHasUncodes then
         HelpfulWarningMsg('There are uncoded entries in this period which will affect the GST calculation',0);

      //get balances for this gst period if available
      This := NIL;
      Prev := NIL;
      Next := NIL;

      L1 := Get_Previous_PSDate_GST( D1, clGST_Period );
      L2 := Get_PEDate_GST( L1, clGST_Period );

      N1 := Get_Next_PSDate_GST( D1, clGST_Period );
      N2 := Get_PEDate_GST( N1, clGST_Period );

      with clBalances_List do
        for B := First to Last do Begin
           Balances := Balances_At( B );
           With Balances^ do Begin
              if ( blGST_Period_Starts = L1 )
              and( blGST_Period_Ends   = L2 ) then
                 Prev := Balances;

              If  (blGST_Period_Starts = D1)
              and (blGST_Period_Ends   = D2) then
                 This := Balances;

              If  ( blGST_Period_Starts = N1 )
              and ( blGST_Period_Ends   = N2 ) then
                 Next := Balances;
           end;
        end;

      // Fill the WorkRec
      FillChar( Figures^, Sizeof( rGSTWorkRec ), 0 );
      With Figures^ do begin
         // Fill in the defaults

         //Check the form type
         if d1 < DMYToStDate(1, MyClient.clFields.clGST_Start_Month , 2008, BKDATEEPOCH) then begin
            // GST 101
            rFormType := GST101;
         end else if clBAS_Field_Source[bfGSTProvisional] = GSTprovisional then begin
            // GST 103B
            if clBAS_Field_Number[bfGSTProvisional] = GSTRatio then begin
               rpt_Ratio := clBAS_Field_Percent[bfGSTProvisional] / 10;
               if ComplusoryPeriod then begin
                  rFormType := GST103Bc;
                  // While we are here see if we can get the Prev month..
                  GetLastMonth(L1,L2);
               end else
                  rFormType := GST103Bv;
            end else // Must be volentary
               rFormType := GST103Bv;

         end else begin
            // GST 101A
            rFormType := GST101A;
         end;


         if This<>NIL then With This^ do Begin
            // Have a saved balance
            with Forma do begin

               rOpening_Creditors := Money2Double( blOpening_Creditors_Balance);
               rOpening_Debtors := Money2Double( blOpening_Debtors_Balance);

               rFBT_Adjust := Money2Double( blFBT_Adjustments);
               rOther_Adjust := Money2Double( blOther_Adjustments);
               rCredit_Adjust := Money2Double( blCredit_Adjustments);

               rAdj_Private    := Money2Double( blGST_Adj_PrivUse );
               rAdj_Bassets    := Money2Double( blGST_Adj_BAssets );
               rAdj_Assets     := Money2Double( blGST_Adj_Assets );
               rAdj_Entertain  := Money2Double( blGST_Adj_Entertain );
               rAdj_Change     := Money2Double( blGST_Adj_Change );
               rAdj_Exempt     := Money2Double( blGST_Adj_Exempt );
               rAdj_Other      := Money2Double( blGST_Adj_Other );

               rAcrt_Use       := Money2Double( blGST_Cdj_BusUse );
               rAcrt_Private   := Money2Double( blGST_Cdj_PAssets );
               rAcrt_Change    := Money2Double( blGST_Cdj_Change );
               rAcrt_Other     := Money2Double( blGST_Cdj_Other );
               rAcrt_Customs   := Money2Double( blGST_Cdj_Customs );
            end;

            if FormPeriod = Transitional then begin
               FormA.rClosing_Creditors := Money2Double(blBAS_G21_GST_Closing_Creditors_BalanceA);
               FormA.rClosing_Debtors := Money2Double(blBAS_F1_GST_Closing_Debtors_BalanceA );

               FormB.rClosing_Creditors := Money2Double(blClosing_Creditors_Balance);
               FormB.rClosing_Debtors := Money2Double(blClosing_Debtors_Balance);

               //This field should be renamed blBAS_G23_Other_Adjustments
               FormB.rOther_Adjust := Money2Double(blBAS_G23);
               //This field should be renamed blBAS_T7_VAT7_Customs
               FormB.rAcrt_Customs := Money2Double(blBAS_T7_VAT7);
               //This field should be renamed blBAS_T8_VAT8_rCredit_Adjust
               FormB.rCredit_Adjust := Money2Double(blBAS_T8_VAT8);

               FormB.rAdj_Private := Money2Double(blBAS_6B_GST_Adj_PrivUse);
               FormB.rAdj_Bassets := Money2Double(blBAS_7_VAT4_GST_Adj_BAssets);
               FormB.rAdj_Assets := Money2Double(blBAS_G7_GST_Adj_Assets );
               FormB.rAdj_Entertain := Money2Double(blBAS_G18_GST_Adj_Entertain);
               FormB.rAdj_Change := Money2Double(blBAS_W1_GST_Adj_Change);
               FormB.rAdj_Exempt := Money2Double(blBAS_W2_GST_Adj_Exempt);
               FormB.rAdj_Other := Money2Double(blBAS_W3_GST_Adj_Other);
               FormB.rAcrt_Use := Money2Double(blBAS_W4_GST_Cdj_BusUse);
               FormB.rAcrt_Private := Money2Double(blBAS_T1_VAT1_GST_Cdj_PAssets);
               FormB.rAcrt_Change := Money2Double(blBAS_T2_VAT2_GST_Cdj_Change);
               FormB.rAcrt_Other := Money2Double(blBAS_T3_VAT3_GST_Cdj_Other);

               FormB.rOpening_Debtors := Money2Double(blBAS_F2_GST_Opening_Debtors_BalanceB);
               FormBOpeningDebitChanged := blBAS_F2_GST_Opening_Debtors_BalanceB <> 0;
               FormB.rOpening_Creditors := Money2Double(blBAS_G22_GST_Opening_Creditors_BalanceB);
               FormBOpeningCreditChanged := blBAS_G22_GST_Opening_Creditors_BalanceB <> 0;
            end else begin
               FormA.rClosing_Creditors := Money2Double(blClosing_Creditors_Balance);
               FormA.rClosing_Debtors := Money2Double(blClosing_Debtors_Balance);
            end;

            rpt_LastMonthIncome := Money2Double(blBAS_1C_PT_Last_Months_Income);
            rpt_BranchIncome    := Money2Double(blBAS_1D_PT_Branch_Income);
            rpt_Assets          := Money2Double(blBAS_1E_PT_Assets);
            rpt_Ratio           := blBAS_5B_PT_Ratio /10;
            rpt_Tax             := Money2Double(blBAS_1F_PT_Tax);
            rpt_RefundUsed      := Money2Double(blBAS_1G_PT_Refund_Used);
            rFormType           := TFormType(blPT_Form_Type);
         end else begin
            // Get the Opening Bal from Prev
            if ( Prev<>NIL ) then with Prev^ do begin
               Forma.rOpening_Debtors      := Money2Double(blClosing_Debtors_Balance);
               Forma.rOpening_Creditors    := Money2Double(blClosing_Creditors_Balance);
            end;
            // Get the Closing Bal from Next
            if ( Next<>NIL ) then with Next^ do begin
               if FormPeriod = Transitional then with FormB do begin
                  rClosing_Debtors := Money2Double(blOpening_Debtors_Balance);
                  rClosing_Creditors := Money2Double(blOpening_Creditors_Balance);
               end else with FormA do begin
                  rClosing_Debtors := Money2Double(blOpening_Debtors_Balance);
                  rClosing_Creditors := Money2Double(blOpening_Creditors_Balance);
               end
            end;
        end;
        // Add the Calculated bits
        FormA.rIncome_Ledger := Money2Double( -IncomeA  ) + Money2Double( -ZeroRatedA);
        FormA.rZ_Rated_Sup := Money2Double( -ZeroRatedA);
        FormA.rExendature_Ledger  := Money2Double( ExpenditureA  );

        //Case 11771 - Recalculate the Customs GST
        if (GST_CA <> Double2Money(FormA.rAcrt_Customs)) then begin
          //Display a warning dialog if the customs GST amount has changed.
          //We need to tell the user about it and then display the IR372.
          //however we want to do this after the 101 form is displayed
          //So post a message that is handled after the form has been shown.
          PostMessage(Handle, WM_AFTERSHOW, 1, 0);
          //move the credit ajustment amouint into 'Other' IR372 if there are
          //no existing IR372 credit adjustments and the Customs amount has changed from 0
          if not HasManualCreditAdjustment(FormA) and (Double2Money(FormA.rAcrt_Customs) = 0) then
            FormA.rAcrt_Other := FormA.rCredit_Adjust;
          //Set the IR372 customs amount
          FormA.rAcrt_Customs := Money2Double(GST_CA);
        end else begin
          //If nothing has changed on the IR372 then re-calculate and save to Box 13
          if HasManualCreditAdjustment(FormA) then
            FormA.rCredit_Adjust := CalculatedCreditAdjustment(FormA)
          else if (FormA.rAcrt_Customs <> 0) then
            FormA.rCredit_Adjust := FormA.rAcrt_Customs; //Customs ajustment only
        end;

        if FormPeriod = Transitional then begin
          FormB.rIncome_Ledger := Money2Double( -IncomeB  ) + Money2Double( -ZeroRatedB);
          FormB.rZ_Rated_Sup := Money2Double( -ZeroRatedB);
          FormB.rExendature_Ledger  := Money2Double( ExpenditureB  );

          //Case 11771 - Recalculate the Customs GST
          if (GST_CB <> Double2Money(FormB.rAcrt_Customs)) then begin
            //Display a warning dialog if the customs GST amount has changed.
            //We need to tell the user about it and then display the IR372.
            //however we want to do this after the 101 form is displayed
            //So post a message that is handled after the form has been shown.
            PostMessage(Handle, WM_AFTERSHOW, 2, 0);
            //move the credit ajustment amouint into 'Other' IR372 if there are
            //no existing IR372 credit adjustments and the Customs amount has changed from 0
            if not HasManualCreditAdjustment(FormB) and (Double2Money(FormB.rAcrt_Customs) = 0) then
              FormB.rAcrt_Other := FormB.rCredit_Adjust;
            //Set the IR372 customs amount
            FormB.rAcrt_Customs := Money2Double(GST_CB);
          end else begin
            //If nothing has changed on the IR372 then re-calculate and save to Box 13
            if HasManualCreditAdjustment(FormB) then
              FormB.rCredit_Adjust := CalculatedCreditAdjustment(FormB)
            else if (FormB.rAcrt_Customs <> 0) then
              FormB.rCredit_Adjust := FormB.rAcrt_Customs; //Customs ajustment only
          end;
        end;

        //TFS 3582 link to GST105 for any GST return that covers Sep 2010
        if (FormPeriod = Transitional) or
           (CompareDates(d1,bkStr2Date('01/09/10'),bkStr2Date('30/09/10')) = Within) or
           (CompareDates(d2,bkStr2Date('01/09/10'),bkStr2Date('30/09/10')) = Within) then begin
          if (FormPeriod <> Transitional) then begin
            lblLinkToGST105.Parent := p15A;
            lblLinkToGST105.Left := L15.Left;
            lblLinkToGST105.Top := lblRefund.Top;
          end;
          lblLinkToGST105.Visible := True;
        end;

        //check to see if the client using payments basis for gst, if so then
        //the debtors and creditors values are irrelevant
        GST_PaymentBasis := (clGST_Basis = gbPayments);
     end; // Figures
  end; //with myclient

  {calculate and display figures for the first time}
  with Figures^ do begin
     with FormA do begin
        lblIncome.Caption            := FormatFloat('#,##0.00',rIncome_Ledger);
        nClosingDebt.AsFloat         := rClosing_Debtors;
        nOpeningDebt.AsFloat         := rOpening_Debtors;
        nFringe.AsFloat              := rFBT_Adjust;
        nDrAdjust.AsFloat            := rOther_Adjust;

        lblPurchases.caption         := FormatFloat('#,##0.00',rExendature_Ledger);
        nClosingCr.asfloat           := rClosing_Creditors;
        nOpeningCR.AsFloat           := rOpening_Creditors;
        nCRAdjust.asfloat            := rCredit_Adjust;
     end;
     with FormB do begin
        lblIncomeB.Caption            := FormatFloat('#,##0.00',rIncome_Ledger);
        nClosingDebtB.AsFloat         := rClosing_Debtors;
        nOpeningDebtB.AsFloat         := rOpening_Debtors;
        nFringeB.AsFloat              := rFBT_Adjust;
        nDrAdjustB.AsFloat            := rOther_Adjust;

        lblPurchasesB.caption         := FormatFloat('#,##0.00',rExendature_Ledger);
        nClosingCrB.asfloat           := rClosing_Creditors;
        nOpeningCRB.AsFloat           := rOpening_Creditors;
        nCRAdjustB.asfloat            := rCredit_Adjust;
     end;

     E17.AsFloat                  := rpt_LastMonthIncome;
     E19.AsFloat                  := figures.rpt_BranchIncome;
     E21.AsFloat                  := figures.rpt_Assets;
     ERatio.AsFloat               := rpt_Ratio;

     Figures^.HasJournals         := GSTInfoA.guHasJournals or GSTInfoB.guHasJournals;
     Figures^.HasUncodes          := GSTInfoA.guHasUncodes or GSTInfoB.guHasUncodes;
     for j := btMin to btMax do
       Figures^.HasWhichJournals[j] := GSTInfoA.guWhichJournals[j] or GSTInfoB.guWhichJournals[j] ;

     Figures^.rFromDate           := D1;
     Figures^.rToDate             := D2;
     Figures^.rDueDate            := DueDate;

  end;
  // Set the FormType
  FormType := Figures.rFormType;
  //MH Apr 02.  GST 101 form has changed, only show FBT if amount is non zero
  if ( Figures.FormA.rFBT_Adjust <> 0) then begin
     lblFringeBenefits.Visible := true;
     imgFBT.Visible := true;
     nFringe.Visible := true;
  end else begin
     pnlTotalGST.Top := lblFringeBenefits.Top;
  end;
  // Should Never need this for FormB, but keeps it the same
  if ( Figures.FormB.rFBT_Adjust <> 0) then begin
     lblFringeBenefitsB.Visible := true;
     imgFBTB.Visible := true;
     nFringeB.Visible := true;
  end else begin
     pnlTotalGSTB.Top := lblFringeBenefitsB.Top;
  end;

  DisplayFigures;
  CheckAdjustments;

  //Setup Screen
 
  {$B-}
  if Assigned(RptParams)
  and (RptParams.BatchRunMode = R_Batch) then begin
     btnPrintClick(nil);
  end else begin

     LockWindowUpdate(Self.Handle);

     //***************
     Self.ShowModal;
     //***************
  end;

  if okPressed then
    Save;
end;
//------------------------------------------------------------------------------
procedure ShowGST101Form;

   //----------------------------------
   function GSTTypesOK( d1, d2 :integer ) : boolean;

     //-----------------------------
     function RateNotZero(ClassNo : integer) : boolean;
     var j : integer;
     begin
        result := false;
        for j := 1 to MAX_GST_CLASS_RATES do
           result := result and ( MyClient.clFields.clGST_Rates[ ClassNo, j ] <> 0 );
     end;

   var
     i : integer;
     typesOK : boolean;
   begin //GSTTypesOK
     typesOK := true;

     with MyClient, MyClient.clFields do begin
        //do quick check first, if all are types are set then no need to
        //test if gst class is used
        for i := 1 to MAX_GST_CLASS do
          if (( clGST_Class_Names[i] <> '' ) or ( RateNotZero(i) ))
             and ( clGST_Class_Types[i]= gtUndefined ) then
                typesOK := false;

        if typesOK then begin
           result := true;
           exit;
        end;

        //not all the types have been set for gst classes.  now check to
        //set if class is used before warning user.
        //need to check transactions for every bank account
        for i := 0 to Pred( clBank_Account_List.itemCount ) do begin
           TypesOK := TravUtils.HasRequiredGSTTypes(clBank_Account_List.Bank_Account_At(i),d1,d2);
           if not TypesOK then break;
        end;

        result := TypesOK;
     end; //with
   end;

   //-------------------------------------
   function OKtoProceed : boolean;
   begin
     with MyClient, MyClient.clFields do begin
       result := not((clGST_Period = gpNone) or (clGST_Start_Month = 0)); //and typesOK;
     end;
   end;

var
  myFrm : TfrmGST101;
  NoRepeat : Boolean;
begin
  if not HasEntries then exit;
  NoRepeat := (Fromdate <> 0);
  repeat;
  myFrm := TfrmGST101.Create(Application.MainForm);
  try
    {check we have all of the required values}
    with MyClient, MyClient.clFields, myFrm do begin
       if not OKtoProceed then begin
         HelpfulInfoMsg('Before you can do this you must setup the GST Period and Start Month.',0);
         EditGSTDetails(BKH_Set_up_GST);
         {if still not set then exit}
         if not OKtoProceed then
            exit;
       end;

       //select GST Period to work with
       if NoRepeat then begin
         d1 := FromDate;
         d2 := Todate;
       end else begin
         if Fromdate <> 0 then
            d1 := fromdate;
         if not SelectGSTPeriod( d1, d2, Params) then
            exit;
         Fromdate := d1; // Keep it for the loop
       end;

       if Assigned(Params) then begin
          if Params.BatchSave then begin
             Params.SaveNodeSettings;
             { #6993
             if Params.WasNewBatch then
                Continue
             else
             }
                Exit;
          end;
          if Params.BatchRunMode = R_batch then
             NoRepeat := True;
       end;
       myFrm.RptParams := Params;
       //test that all gst classes have the gst type set
       if not GSTTypesOK( d1, d2 ) then begin
          HelpfulWarningMsg( 'One or more GST Classes have not been assigned a GST Type.  '+
                             'Entries coded to these classes will not be included in the GST calculation.',0);
       end;



{$IFDEF SmartBooks}
       RecalcGST_SB_Only;
{$ENDIF}
    end;
    MyFrm.Execute;

  finally
    MyFrm.Free;
  end;
  until NoRepeat;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.Save;
begin
  with MyClient do
  begin
    {save back the balances that have been used}
    if not assigned(This) then begin
       This := New_Balances_Rec;
       This^.blGST_Period_Starts := D1;
       This^.blGST_Period_Ends   := D2;
       clBalances_List.Insert( This );
    end;

    with This^, Figures^ do begin
       with formA do begin
          blOpening_Debtors_Balance       := Double2Money( rOpening_Debtors);
          blFBT_Adjustments               := Double2Money( rFBT_Adjust);
          blOther_Adjustments             := Double2Money( rOther_Adjust);

          blOpening_Creditors_Balance     := Double2Money( rOpening_Creditors);
          blCredit_Adjustments            := Double2Money( rCredit_Adjust);

          blGST_Adj_PrivUse               := Double2Money( rAdj_Private);
          blGST_Adj_BAssets               := Double2Money( rAdj_Bassets);
          blGST_Adj_Assets                := Double2Money( rAdj_Assets);
          blGST_Adj_Entertain             := Double2Money( rAdj_Entertain);
          blGST_Adj_Change                := Double2Money( rAdj_Change);
          blGST_Adj_Exempt                := Double2Money( rAdj_Exempt);
          blGST_Adj_Other                 := Double2Money( rAdj_Other);

          blGST_Cdj_BusUse                := Double2Money( rAcrt_Use);
          blGST_Cdj_PAssets               := Double2Money( rAcrt_Private);
          blGST_Cdj_Change                := Double2Money( rAcrt_Change);
          blGST_Cdj_Other                 := Double2Money( rAcrt_Other);
          blGST_Cdj_Customs               := Double2Money( rAcrt_Customs);
       end;

       blPT_Form_Type                  := ord(rFormType);
       // Provisional
       blBAS_1C_PT_Last_Months_Income  := Double2Money( rpt_LastMonthIncome );
       blBAS_1D_PT_Branch_Income       := Double2Money( rpt_BranchIncome    );
       blBAS_1E_PT_Assets              := Double2Money( rpt_Assets  );
       blBAS_5B_PT_Ratio               := round( rpt_Ratio * 10);
       blBAS_1F_PT_Tax                 := Double2Money( rpt_Tax );
       blBAS_1G_PT_Refund_Used         := Double2Money( rpt_RefundUsed );
       if (FormPeriod = transitional) then with FormB do begin
          // The 'closing balance' is just from the second period..
          blClosing_Creditors_Balance := Double2Money( rClosing_Creditors);
          blClosing_Debtors_Balance := Double2Money( rClosing_Debtors);

          //This field should be renamed blBAS_G23_Other_Adjustments
          blBAS_G23                     := Double2Money( rOther_Adjust);
          //This field should be renamed blBAS_T7_VAT7_Customs
          blBAS_T7_VAT7                 := Double2Money( rAcrt_Customs);
          //This field should be renamed blBAS_T8_VAT8_Customs
          blBAS_T8_VAT8                 := Double2Money( rCredit_Adjust);

          blBAS_6B_GST_Adj_PrivUse      := Double2Money( rAdj_Private);
          blBAS_7_VAT4_GST_Adj_BAssets  := Double2Money( rAdj_Bassets);
          blBAS_G7_GST_Adj_Assets       := Double2Money( rAdj_Assets);
          blBAS_G18_GST_Adj_Entertain   := Double2Money( rAdj_Entertain);
          blBAS_W1_GST_Adj_Change       := Double2Money( rAdj_Change);
          blBAS_W2_GST_Adj_Exempt       := Double2Money( rAdj_Exempt);
          blBAS_W3_GST_Adj_Other        := Double2Money( rAdj_Other);
          blBAS_W4_GST_Cdj_BusUse       := Double2Money( rAcrt_Use);
          blBAS_T1_VAT1_GST_Cdj_PAssets := Double2Money( rAcrt_Private);
          blBAS_T2_VAT2_GST_Cdj_Change  := Double2Money( rAcrt_Change);
          blBAS_T3_VAT3_GST_Cdj_Other   := Double2Money( rAcrt_Other);


          blBAS_F2_GST_Opening_Debtors_BalanceB :=  Double2Money(rOpening_Debtors);
          blBAS_G22_GST_Opening_Creditors_BalanceB := Double2Money(rOpening_Creditors);

          blBAS_F1_GST_Closing_Debtors_BalanceA := Double2Money(FormA.rClosing_Debtors);
          blBAS_G21_GST_Closing_Creditors_BalanceA := Double2Money( FormA.rClosing_Creditors);
       end else with FormA do begin
          blClosing_Creditors_Balance := Double2Money( rClosing_Creditors);
          blClosing_Debtors_Balance := Double2Money( rClosing_Debtors);

          // While we are here Clear the rest..
          FillChar(FormB, Sizeof(FormB), 0);
          blBAS_F1_GST_Closing_Debtors_BalanceA := 0;
          blBAS_F2_GST_Opening_Debtors_BalanceB := 0;

          blBAS_G21_GST_Closing_Creditors_BalanceA := 0;
          blBAS_G22_GST_Opening_Creditors_BalanceB := 0;
       end;
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmGST101.btnFileClick(Sender: TObject);
begin
  //save the figures
  Save;

  Figures.rDraftModePrinting := chkDraft.Checked;

  if DoGST101Report( rdFile, self) then
{$IFNDEF SmartBooks}
    if (not Figures.rDraftModePrinting) and (IsLocked(Figures.rFromDate,Figures.rToDate) <> ltAll) then begin
       if (AskYesNo('Finalise Accounting Period','You have produced a PDF of the GST Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str(Figures.rFromDate)+' - '+bkDate2Str(figures.rToDate)+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod(Figures.rFromDate,Figures.rToDate);
       end;
    end;
{$ENDIF}
end;

function TfrmGST101.GetGSTRate(ForDate: Integer): Double;
begin
   begin
      if ForDate < GSTRateChangeDate then
         Result := 1.0 /9.0
      else
         Result :=  3.0 / 23.0
   end;
end;

procedure TfrmGST101.GST372Action(Sender: TObject);
begin
   if sender = btnIR372 then begin
      if FormPeriod = transitional then begin
         if PgForm.ActivePage = tsPart1 then
            Open372(True)
         else if PgForm.ActivePage = tsPart1B then
            Open372(False)
      end else
        Open372(True)
   end else
      Open372(  (Sender = LI9)
             or (Sender = i372)
             or (Sender = LI13)
             or (Sender = i372C)
             )
end;

procedure TfrmGST101.Open372(FormA:Boolean; Close101OnCancel: Boolean = False);
var TotalAdjustment,
    CreditAdjustment : Double;
    LRange: tDateRange;
    

begin
   if FormA then begin
      if FormPeriod = Transitional then
         lRange := MakeDateRange(d1, GSTRateChangeDate -1)
      else
         lRange := MakeDateRange(d1,d2);

      TotalAdjustment := nDrAdjust.AsFloat;
      CreditAdjustment := nCRAdjust.AsFloat;
      if RunGST372 (Self,INI_ShowFormHints,UserPrintSettings ,MyClient,LRange, Figures.FormA, Prev, TotalAdjustment, CreditAdjustment) = mrok then begin
         nDrAdjust.AsFloat := TotalAdjustment;
         nCRAdjust.AsFloat := CreditAdjustment;
         CheckAdjustments;
         DisplayFigures;
      end else
         if Close101OnCancel then
            Close;
   end else begin
      lRange := MakeDateRange(GSTRateChangeDate, d2);
      TotalAdjustment := nDrAdjustB.AsFloat;
      CreditAdjustment := nCRAdjustB.AsFloat;
      if RunGST372 (Self,INI_ShowFormHints,UserPrintSettings ,MyClient,lRange,Figures.FormB, Nil, TotalAdjustment, CreditAdjustment) = mrok then begin
         nDrAdjustB.AsFloat := TotalAdjustment;
         nCRAdjustB.AsFloat := CreditAdjustment;
         CheckAdjustments;
         DisplayFigures;
      end else
         if Close101OnCancel then
            Close;
   end;
end;

procedure TfrmGST101.Image23Click(Sender: TObject);
begin
   // See if there is a refund...
   E25manual := False;
   DisplayFigures;
end;

procedure TfrmGST101.lblLinkToGST105Click(Sender: TObject);
const
  GST105_LINK = 'http://www.ird.govt.nz/resources/6/c/6cfd0080439f6fa39eec9e4e9c145ab7/gst105.pdf';
begin
  ShellExecute(0, 'open', PChar(GST105_LINK), nil, nil, SW_NORMAL);
end;

procedure TfrmGST101.SetDoPart2(const Value: Boolean);
begin
   FDoPart2 := Value;
   e24.Enabled := not FDoPart2;
end;

procedure TfrmGST101.SetDoPart3(const Value: Boolean);
begin
   FDoPart3 := Value;
end;

procedure TfrmGST101.SetFormPeriod(const Value: TFormPeriod);

const
  Form6 = 'Zero rated supplies in Box %s';
  Form7 = 'Subtract Box %s from Box %s';
  form8 = 'Divide Box %s by nine';
  Form16 = 'Enter total sales and income from Box %s';
  Form25 = 'If Box %s is a refund, enter the amount you would like to transfer to provisional tax, otherwise enter zero (0)';
  Form27 = 'If Box %s is GST to pay, enter the amount here, otherwise enter zero (0)';

begin
  FFormPeriod := Value;
  case FFormPeriod of

     PreOct2010: begin
             TsPart1B.TabVisible := False;
         end;

     Transitional: begin
           tsPart1.Caption := 'Part 1 - GST ending 30/09/10';
           // Update form1
           p15A.Visible := False;
           LI5.Caption := '5A';
           LI6.Caption := '6A';
           LI7.Caption := '7A';
           LI8.Caption := '8A';
           LI9.Caption := '9A';
           LI10.Caption := '10A';
           LI11.Caption := '11A';
           LI12.Caption := '12A';
           LI13.Caption := '13A';
           LI14.Caption := '14A';

           l6.Caption := Format(Form6,[LI5.Caption]);
           l7.Caption := Format(Form7,[LI6.Caption,LI5.Caption]);
           l8.Caption  := format(Form8,[LI7.Caption]);
           l12.Caption := format(Form8,[LI11.caption]);

           // Provisional Tax
           L16.Caption := Format(Form16,['5A and Box 5B']);
           L25.Caption := Format(Form25,['17']);
           L27.Caption := Format(Form27,['17']);

           LI16.Caption := '18';
           P17.Visible := False;
           P18.Visible := False;

           BKHelpSetUp(Self,BKH_GST_Return_Transitional);
           lblSubmit.Visible := False;
        end;

     PostOct2010: begin
           TsPart1B.TabVisible := False;
           // Update the formulas
           l8.Caption := format(NewGSTRateText,[LI7.Caption]);
           l12.Caption := format(NewGSTRateText,[LI11.caption]);
        end;
  end;

end;

procedure TfrmGST101.SetFormType(const Value: TFormType);

  procedure SetLabletext(const Main, Small : string);
  begin
     LSmall1.Caption := Small;
     LSmall1B.Caption := Small;
     LSmall2.Caption := Small;
     LSmall3.Caption := Small;
     LMain1.Caption := Main;
     LMain1B.Caption := Main;
     LMain2.Caption := Main;
     LMain3.Caption := Main;
     Self.Caption := Main;
  end;

begin
  FFormType := Value;

  case FFormType of
     GST101: begin
          TSPart2.TabVisible := False;
          TSPart3.TabVisible := False;
          TSPart1.TabVisible := TSPart1B.TabVisible;
          // Cannot be transitional ??
          SetLabletext('Goods and services tax return', 'GST 101');
          pnlsales.Color := $00DBEEFF;
          pnlPurchases.Color := $00DBEEFF;
          pnlTotalGST.Color := $00DBEEFF;
        end;

     GST101A: begin

          case Formperiod of
          PreOct2010 : SetLabletext('Goods and services tax return', 'GST 101A');
          Transitional : SetLabletext('GST transitional return', 'GST 104A');
          PostOct2010 :  SetLabletext('Goods and services tax return', 'GST 101A');
          end;

          TSPart2.TabVisible := False;
          TSPart3.TabVisible := False;
          TSPart1.TabVisible := TSPart1B.TabVisible;
        end;

     GST103Bc: begin
          case Formperiod of
          PreOct2010 : SetLabletext('GST and provisional tax return', 'GST 103B');
          Transitional : SetLabletext('GST transitional and provisional return', 'GST 104B');
          PostOct2010 :  SetLabletext('GST and provisional return', 'GST 103B');
          end;

          DoPart2 := True;
          DoPart3 := True;
        end;

     GST103Bv: begin
          case Formperiod of
          PreOct2010 : SetLabletext('GST and provisional tax return', 'GST 103B');
          Transitional : SetLabletext('GST transitional and provisional return', 'GST 104B');
          PostOct2010 :  SetLabletext('GST and provisional return', 'GST 103B');
          end;

          DoPart3 := True;
          DoPart2 := False;
          TSPart2.TabVisible := False;
          // Provisional Tax was/is enterd manualy
          e24.AsFloat :=   Figures.rpt_Tax;
        end;
  end;

  PGForm.ActivePage := TSPart1;
end;

procedure TfrmGST101.SetGST_PaymentBasis(const Value: Boolean);

   procedure ResetBal(var Value: TGSTForm);
   begin with Value do begin
      rOpening_Debtors      := 0;
      rOpening_Creditors    := 0;

      rClosing_Debtors      := 0;
      rClosing_Creditors    := 0;
   end;end;

begin
   FGST_PaymentBasis := Value;
   if FGST_PaymentBasis then with Figures^ do begin
       ResetBal(FormA);
       ResetBal(FormB);

       //also turn off the debtors and creditors panels in the worksheet...
       pnlDebtors.Visible := false;
       pnlCreditors.Visible := false;

       pnlDebtorsB.Visible := false;
       pnlCreditorsB.Visible := false;

       chkDraft.Visible := false;

       //... and move everything up
       with lblBasis do
          top := top - pnlDebtors.height;
       with pnlSales do
          top := top - pnlDebtors.height;
       with pnlPurchases do
          top := top - (pnlDebtors.height + pnlCreditors.height) + 2;

       with lblBasisB do
          top := top - pnlDebtorsB.height;
       with pnlSalesB do
          top := top - pnlDebtorsB.height;
       with pnlPurchasesB do
          top := top - (pnlDebtorsB.height + pnlCreditorsB.height) + 2;


       with gbGST do
          height := height - (pnlDebtors.height + pnlCreditors.height) + 2;

       //shrink form if necessary
       CustomFormHeight := CustomFormHeight - (pnlDebtors.height + pnlCreditors.height);
   end;
end;

procedure TfrmGST101.SetRptParams(const Value: TrptParameters);
begin
  FRptParams := Value;
end;

// note can't use HTTPApp.HTMLEncode because the <input> tag doesn't recognise &amp;
// we need out function to convert & to its ASCII hex %26
function TfrmGST101.EncodeHTML(s: string): string;
var
  i: Integer;
begin
  i := 1;
  while i <= Length(s) do
  begin
    if s[i] = '&' then
    begin
      Delete(s, i, 1);
      Insert('%26', s, i);
    end;
    Inc(i);
  end;
  result := s;
end;

procedure TfrmGST101.LblSubmitClick(Sender: TObject);
var link : String;
begin
 //if ShellCommand_Web <> '' then
    link := LblSubmit.Caption;
    if length(link) = 0 then exit;
    { See what we can fill in..}
    link := link + '&name=' + EncodeHTML(lblName.Caption) +
                   '&irdnum=' + lblGSTno.Caption +
                   '&gstperiodstarting_day=' + Date2Str( D1, 'dd' ) +
                   '&gstperiodstarting_month=' + Date2Str( D1, 'mm' ) +
                   '&gstperiodstarting_year=' + Date2Str( D1, 'yyyy' ) +
                   '&gstperiodending_day=' + Date2Str( D2, 'dd' ) +
                   '&gstperiodending_month=' + Date2Str( D2, 'mm' ) +
                   '&gstperiodending_year=' + Date2Str( D2, 'yyyy' ) +
                   '&duedate_day=' + Date2Str( DueDate, 'dd' ) +
                   '&duedate_month=' + Date2Str( DueDate, 'mm' ) +
                   '&duedate_year=' + Date2Str( DueDate, 'yyyy' );

    {}
    ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

procedure TfrmGST101.E25Change(Sender: TObject);
begin
   if E25.Modified then
      E25Manual := True;
   nFringeChange(Sender);
end;

function TfrmGST101.EnableAdjustmentEdit(Form: TGSTForm): Boolean;
begin
   with Form do begin
      Result := False;
      if rAdj_Private <> 0 then exit;
      if rAdj_Bassets <> 0 then exit;
      if rAdj_Assets <> 0 then exit;
      if rAdj_Entertain <> 0 then exit;
      if rAdj_Change <> 0 then exit;
      if rAdj_Exempt <> 0 then exit;
      if rAdj_Other <> 0 then exit;

      if rAcrt_Use <> 0 then exit;
      if rAcrt_Private <> 0 then exit;
      if rAcrt_Change <> 0 then exit;
      if rAcrt_Customs <> 0 then exit;
      if rAcrt_Other <> 0 then exit;
      // All zero...
      Result := True;
   end;
end;

procedure TfrmGST101.CheckAdjustments;
  procedure EnableAdjustA (Enable : Boolean);
  begin
     nDrAdjust.Enabled := Enable;
     nCRAdjust.Enabled := Enable;
  end;
  procedure EnableAdjustB (Enable : Boolean);
  begin
     nDrAdjustB.Enabled := Enable;
     nCRAdjustB.Enabled := Enable;
  end;
begin
   EnableAdjustA(EnableAdjustmentEdit(Figures.FormA));
   EnableAdjustB(EnableAdjustmentEdit(Figures.FormB));
end;

procedure TfrmGST101.nDrAdjustChange(Sender: TObject);
begin
   DeNegativeOvcNumericField(Sender);
   nFringeChange(Sender);
end;

end.

