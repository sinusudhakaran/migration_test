unit VATReturn;
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcEF, OvcPB, OvcNF, ExtCtrls, StdCtrls, MoneyDef, bkConst, bkdefs,
  ComCtrls, GSTUtil32, RzLine, OSFont;

//------------------------------------------------------------------------------

Type
  TVat_Details = Class
    Public
      From_Date : Integer;
      To_Date : Integer;
      VAT1 : Money;
      VAT2 : Money;
      VAT3 : Money;
      VAT4 : Money;
      VAT5 : Money;
      VAT6 : Money;
      VAT7 : Money;
      VAT8 : Money;
      VAT9 : Money;
      CD17 : Money;
      CD13 : Money;
      CD5 : Money;
      CD0 : Money;
      OD17 : Money;
      OD13 : Money;
      OD5 : Money;
      OD0 : Money;
      CC17 : Money;
      CC13 : Money;
      CC5 : Money;
      CC0 : Money;
      OC17 : Money;
      OC13 : Money;
      OC5 : Money;
      OC0 : Money;
      VAT1_Adj : Money;
      VAT4_Adj : Money;
      VAT6_Adj : Money;
      VAT7_Adj : Money;
      Refund : Boolean;
      HasUnCodes: Boolean;
  End;

type
  TfrmVAT = class(TForm)
    OvcController1: TOvcController;
    Panel1: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    pgForm: TPageControl;
    tsVATCalculation: TTabSheet;
    sbGST: TScrollBox;
    GBGST: TGroupBox;
    lMain1: TLabel;
    Label50: TLabel;
    Label55: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    lblPeriod: TLabel;
    lblGSTno: TLabel;
    pnlVAT: TGroupBox;
    Box1: TStaticText;
    GBAddress: TGroupBox;
    lblName: TLabel;
    lblAddr1: TLabel;
    lblAddr2: TLabel;
    lblAddr3: TLabel;
    lblBox2: TLabel;
    lblBox3: TLabel;
    lblBox4: TLabel;
    lblBox5: TLabel;
    lblBox6: TLabel;
    lblBox7: TLabel;
    lblBox8: TLabel;
    lblBox9: TLabel;
    Label12: TLabel;
    Box2: TStaticText;
    Box3: TStaticText;
    Box4: TStaticText;
    Box5: TStaticText;
    Box6: TStaticText;
    Box7: TStaticText;
    Box8: TStaticText;
    Box9: TStaticText;
    tsAdjustments: TTabSheet;
    gbDebtors: TGroupBox;
    gbCreditors: TGroupBox;
    cdTotal: TOvcNumericField;
    cd17: TOvcNumericField;
    cd13: TOvcNumericField;
    cd5: TOvcNumericField;
    cd0: TOvcNumericField;
    odTotal: TOvcNumericField;
    od17: TOvcNumericField;
    od13: TOvcNumericField;
    od5: TOvcNumericField;
    od0: TOvcNumericField;
    RzLine1: TRzLine;
    nddTotal: TOvcNumericField;
    ndd17: TOvcNumericField;
    ndd13: TOvcNumericField;
    ndd5: TOvcNumericField;
    ndd0: TOvcNumericField;
    RzLine2: TRzLine;
    ndvtotal: TOvcNumericField;
    ndv17: TOvcNumericField;
    ndv13: TOvcNumericField;
    ndv5: TOvcNumericField;
    ndv0: TOvcNumericField;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ccTotal: TOvcNumericField;
    cc17: TOvcNumericField;
    cc13: TOvcNumericField;
    cc5: TOvcNumericField;
    cc0: TOvcNumericField;
    ocTotal: TOvcNumericField;
    oc17: TOvcNumericField;
    oc13: TOvcNumericField;
    oc5: TOvcNumericField;
    oc0: TOvcNumericField;
    ndctotal: TOvcNumericField;
    RzLine3: TRzLine;
    ndc17: TOvcNumericField;
    ndc13: TOvcNumericField;
    ndc5: TOvcNumericField;
    ndc0: TOvcNumericField;
    RzLine4: TRzLine;
    ncvtotal: TOvcNumericField;
    ncv17: TOvcNumericField;
    ncv13: TOvcNumericField;
    ncv5: TOvcNumericField;
    ncv0: TOvcNumericField;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Shape1: TShape;
    lblBox1: TLabel;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    Label14: TLabel;
    Label18: TLabel;
    Label22: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    lblFinalise: TLabel;
    btnFile: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure CalculateWorksheet(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    d1, d2 : integer;
    FRptParams: TrptParameters;
    FVat_Details : TVat_Details;
    FVat_Class_Totals : TGSTInfo;
    FCalculated : Boolean;
    procedure CalculateVAT;
    procedure SetRptParams(const Value: TrptParameters);
    Procedure Save;
    function GetBalancesRec(D1, D2: integer): pBalances_Rec;
  public
    { Public declarations }
    function Execute : boolean;
    property RptParams: TrptParameters read FRptParams write SetRptParams;
  end;

procedure ShowVATReturn( Fromdate: Integer = 0; ToDate: integer = 0; Params: TrptParameters = nil);

//******************************************************************************
implementation

uses
  Math,
  ShellApi,
  bkXPThemes,
  bkhelp,
  glConst,
  Globals,
  InfoMoreFrm,
  EditGSTDlg,
  WarningMoreFrm,
  pddates32,
  SelectGSTPeriodDlg,
  baobj32,
  BKBLIO,
  YesnoDlg,
  finalise32,
  bkutil32,
  GenUtils,
  bkDateUtils,
  ReportDefs,
  RptVATReturn,
  StdHints,
  stDate,
  stDateSt,
  TravUtils,
  UBatchBase,
  MonitorUtils,
  VATConst;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmVAT.FormCreate(Sender: TObject);
Var
  i : Integer;
  function ReFont(Contrl : TLabel): TFont;
  begin
     Contrl.Font := self.Font;
     Contrl.Font.Style := [fsBold];
     Result := Contrl.Font;
  end;

begin
  bkXPThemes.ThemeForm(Self);

  for i := 0 to ComponentCount -1 do
  Begin
    if Components[i] is TOvcNumericField then
    Begin
       With TOvcNumericField( Components[i] ) do
       Begin
         if efoReadOnly in Options then
         Begin
           BorderStyle := bsNone;
           Ctl3D       := False;
         End;
       End;
    end;
  End;
  ReFont(lblName);
  ReFont(lblGSTno);
  ReFont(lblPeriod);
  ReFont(lblBox3);
  ReFont(lblBox5);
  ReFont(lMain1).Size := 11;


  FVAT_Details := TVAT_Details.Create;
  SetUpHelp;
  FCalculated := False;
  pgForm.ActivePage := tsVATCalculation;
  tsAdjustments.TabVisible := ( MyClient.clFields.clGST_Basis = gbuAccrual );
end;
//------------------------------------------------------------------------------
procedure TfrmVAT.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_VAT_return;
   //Components
   btnPreview.Hint     :=
                       STDHINTS.PreviewHint;
   btnPrint.Hint       :=
                       STDHINTS.PrintHint;
end;
//------------------------------------------------------------------------------

procedure TfrmVAT.FormDestroy(Sender: TObject);
begin
  FVAT_Details.Free;
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.btnOKClick(Sender: TObject);
begin
  okPressed := true;
  Close;
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.btnPrintClick(Sender: TObject);
begin
  Save;
  if DoVATReturn( rdPrinter, FVAT_Details, RptParams) then

{$IFNDEF SmartBooks}
    if (IsLocked( D1, D2 ) <> ltAll) then begin
       //Check that all transactions are coded for the UK (before anything else)
       if not CheckAutoLockGSTPeriod(D1, D2) then
         Exit;

       if (AskYesNo('Finalise Accounting Period','You have printed the VAT Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str( D1 )+' - '+bkDate2Str( D2 )+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod( D1, D2 );
       end;
    end;
{$ENDIF}

end;

procedure TfrmVAT.btnFileClick(Sender: TObject);
begin
  Save;
  if DoVATReturn( rdFile, FVAT_Details, RptParams) then

{$IFNDEF SmartBooks}
    if (IsLocked( D1, D2 ) <> ltAll) then begin
       //Check that all transactions are coded for the UK (before anything else)
       if not CheckAutoLockGSTPeriod(D1, D2) then
         Exit;

       if (AskYesNo('Finalise Accounting Period','You have produced a PDF of the VAT Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str( D1 )+' - '+bkDate2Str( D2 )+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod( D1, D2 );
       end;
    end;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.btnPreviewClick(Sender: TObject);
begin
  Save;
//  Figures.rDraftModePrinting := chkDraft.Checked;
  if DoVATReturn( rdScreen, FVAT_Details ) then

{$IFNDEF SmartBooks}
    if (IsLocked( D1, D2 ) <> ltAll) then begin
       //Check that all transactions are coded for the UK (before anything else)
       if not CheckAutoLockGSTPeriod(D1, D2) then
         Exit;

       if (AskYesNo('Finalise Accounting Period','You have printed the VAT Return.  Do you want to Finalise this Accounting Period?'+#13+#13+
           '('+bkdate2Str( D1 )+' - '+bkDate2Str( D2 )+')'
           ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
       begin
         AutoLockGSTPeriod( D1, D2 );
       end;
    end;
{$ENDIF}

end;
//------------------------------------------------------------------------------
procedure TfrmVAT.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.FormShow(Sender: TObject);
begin
  lblBox1.Caption := SBox1;
  lblBox2.Caption := SBox2;
  lblBox3.Caption := SBox3;
  lblBox4.Caption := SBox4;
  lblBox5.Caption := SBox5;
  lblBox6.Caption := SBox6;
  lblBox7.Caption := SBox7;
  lblBox8.Caption := SBox8;
  lblBox9.Caption := SBox9;


  lblFinalise.Caption := SFinalise;
  lblFinalise.Visible := FVAT_Class_totals.guHasUncodes;
  FVat_Details.HasUnCodes := FVat_Class_Totals.guHasUncodes;
end;

function TfrmVAT.GetBalancesRec(D1, D2: integer): pBalances_Rec;
var
  i: integer;
  Balances: pBalances_Rec;
begin
  Result := nil;
  for i := MyClient.clBalances_List.First to MyClient.clBalances_List.Last do begin
    Balances := MyClient.clBalances_List.Balances_At(i);
    if Assigned(Balances) then begin
      if (Balances.blGST_Period_Starts = D1) and
         (Balances.blGST_Period_Ends = D2) then
        Result := Balances;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.CalculateVAT;

Var
  i : Integer;
  Tax : Money;
  Excl : Money;
Begin
  if not FCalculated then
  Begin
    FillChar( FVat_Class_Totals, Sizeof( FVAT_Class_Totals ), 0 );
    GSTUTIL32.CalculateGSTTotalsForPeriod( D1, D2, FVAT_Class_Totals, -1);
    FCalculated := True;
  End;

  With FVAT_Details do
  Begin
    VAT1 := 0;
    VAT2 := 0;
    VAT3 := 0;
    VAT4 := 0;
    VAT5 := 0;
    VAT6 := 0;
    VAT7 := 0;
    VAT8 := 0;
    VAT9 := 0;
    From_Date := D1;
    To_Date := D2;
    for i := 1 to MAX_GST_Class do
    Begin
      Tax := FVat_Class_Totals.guGST_Totals[ i ];
      case MyClient.clFields.clGST_Class_Types[ i ] of
        vtNoVAT                 : ;
        // This is a bit odd, but just for consitancy; The Zerorated and Exempt ones should not Have any TAX
        // But This way all 16 Classes are used
        vtSalesStandard, vtSalesReduced, vtSalesZeroRated, vtSalesExempt,
        vtSalesECStandard, vtSalesECReduced, vtSalesECZeroRated,vtSalesECExempt : VAT1 := VAT1 - Tax; // ALL sales TAX

        vtPurchasesStandard, vtPurchasesReduced, vtPurchasesZeroRated,vtPurchasesExempt          : VAT4 := VAT4 + Tax; //All UK Purchases TAX
        vtPurchasesECStandard, vtPurchasesECReduced, vtPurchasesECZeroRated,vtPurchasesECExempt : VAT2 := VAT2 + Tax; //ALL EC Purchases TAX
      end;

      Excl := FVat_Class_Totals.guNet_Totals[ i ];
      case MyClient.clFields.clGST_Class_Types[ i ] of
        vtNoVAT                 : ;
        vtSalesStandard, vtSalesReduced,
        vtSalesZeroRated, vtSalesExempt     : VAT6 := VAT6 - Excl; //All UK Sales

        vtSalesECStandard, vtSalesECReduced,
        vtSalesECZeroRated, vtSalesECExempt : VAT8 := VAT8 - Excl; //All EC Purchases

        vtPurchasesStandard, vtPurchasesReduced,
        vtPurchasesZeroRated, vtPurchasesExempt      : VAT7 := VAT7 + Excl;  //ALL UK Purchases

        vtPurchasesECStandard, vtPurchasesECReduced,
        vtPurchasesECZeroRated, vtPurchasesECExempt   : VAT9 := VAT9 + Excl; //ALL EC Purchases
      end;
    End;

    // Debtors and Creditors Adjustments
    VAT1 := VAT1 + VAT1_Adj;
    VAT4 := VAT4 + VAT4_Adj;
    VAT6 := VAT6 + VAT6_Adj;
    VAT7 := VAT7 + VAT7_Adj;

    VAT4 := VAT4 + VAT2; //VAT4 Includes the EC Purchases TAX

    VAT3 := VAT1 + VAT2; //VAT3 is just the sum of VAT1 and VAT2

    VAT5 := VAT3 - VAT4; //VAT5 is the VAT3 - VAT4  (Absolute ??)

    VAT6 := VAT6 + VAT8; //VAT6 Includes the EC Sales
    VAT7 := VAT7 + VAT9; //VAT7 Includes the EC Purchases

    lblPeriod.Caption := Date2Str( D1, 'dd nnn YYYY' ) +  ' to ' + Date2Str( D2, 'dd nnn YYYY' );

    Box1.Caption := MyClient.MoneyStrNoSymbol( VAT1 );
    Box2.Caption := MyClient.MoneyStrNoSymbol( VAT2 );
    Box3.Caption := MyClient.MoneyStrNoSymbol( VAT3 );
    Box4.Caption := MyClient.MoneyStrNoSymbol( VAT4 );
    Box5.Caption := MyClient.MoneyStrNoSymbol( VAT5 );
    Box6.Caption := MyClient.MoneyStrNoSymbol( VAT6 );
    Box7.Caption := MyClient.MoneyStrNoSymbol( VAT7 );
    Box8.Caption := MyClient.MoneyStrNoSymbol( VAT8 );
    Box9.Caption := MyClient.MoneyStrNoSymbol( VAT9 );
  End;
end;

procedure TfrmVAT.CalculateWorksheet(Sender: TObject);
begin
  //
  // Debtors Worksheet
  //
  cdTotal.AsFloat  := Money2Double( Double2Money( cd17.AsFloat ) + Double2Money( cd13.AsFloat ) + Double2Money( cd5.AsFloat ) + Double2Money( cd0.AsFloat ) );
  odTotal.AsFloat  := Money2Double( Double2Money( od17.AsFloat ) + Double2Money( od13.AsFloat ) + Double2Money( od5.AsFloat ) + Double2Money( od0.AsFloat ) );
  //
  ndd17.AsFloat    := Money2Double( Double2Money( cd17.AsFloat ) - Double2Money( od17.AsFloat ) );
  ndd13.AsFloat    := Money2Double( Double2Money( cd13.AsFloat ) - Double2Money( od13.AsFloat ) );
  ndd5.AsFloat     := Money2Double( Double2Money( cd5.AsFloat ) - Double2Money( od5.AsFloat ) );
  ndd0.AsFloat     := Money2Double( Double2Money( cd0.AsFloat ) - Double2Money( od0.AsFloat ) );
  nddTotal.AsFloat := Money2Double( Double2Money( ndd17.AsFloat ) + Double2Money( ndd13.AsFloat ) + Double2Money( ndd5.AsFloat ) + Double2Money( ndd0.AsFloat ) );
  //
  ndv17.AsFloat    := Money2Double( Double2Money( ndd17.AsFloat * 0.175 ) );
  ndv13.AsFloat    := Money2Double( Double2Money( ndd13.AsFloat * 0.13 ) );
  ndv5.AsFloat     := Money2Double( Double2Money( ndd5.AsFloat * 0.05 ) );
  ndv0.AsFloat     := 0.0;
  ndvTotal.AsFloat := Money2Double( Double2Money( ndv17.AsFloat ) + Double2Money( ndv13.AsFloat ) + Double2Money( ndv5.AsFloat ) + Double2Money( ndv0.AsFloat ) );
  //
  // Creditors Worksheet
  //
  //
  ccTotal.AsFloat  := Money2Double( Double2Money( cc17.AsFloat ) + Double2Money( cc13.AsFloat ) + Double2Money( cc5.AsFloat ) + Double2Money( cc0.AsFloat ) );
  ocTotal.AsFloat  := Money2Double( Double2Money( oc17.AsFloat ) + Double2Money( oc13.AsFloat ) + Double2Money( oc5.AsFloat ) + Double2Money( oc0.AsFloat ) );
  //
  ndc17.AsFloat    := Money2Double( Double2Money( cc17.AsFloat ) - Double2Money( oc17.AsFloat ) );
  ndc13.AsFloat    := Money2Double( Double2Money( cc13.AsFloat ) - Double2Money( oc13.AsFloat ) );
  ndc5.AsFloat     := Money2Double( Double2Money( cc5.AsFloat ) - Double2Money( oc5.AsFloat ) );
  ndc0.AsFloat     := Money2Double( Double2Money( cc0.AsFloat ) - Double2Money( oc0.AsFloat ) );
  ndcTotal.AsFloat := Money2Double( Double2Money( ndc17.AsFloat ) + Double2Money( ndc13.AsFloat ) + Double2Money( ndc5.AsFloat ) + Double2Money( ndc0.AsFloat ) );
  //
  ncv17.AsFloat    := Money2Double( Double2Money( ndc17.AsFloat * 0.175 ) );
  ncv13.AsFloat    := Money2Double( Double2Money( ndc13.AsFloat * 0.13 ) );
  ncv5.AsFloat     := Money2Double( Double2Money( ndc5.AsFloat * 0.05 ) );
  ncv0.AsFloat     := 0.0;
  ncvTotal.AsFloat := Money2Double( Double2Money( ncv17.AsFloat ) + Double2Money( ncv13.AsFloat ) + Double2Money( ncv5.AsFloat ) + Double2Money( ncv0.AsFloat ) );

  FVat_Details.CD17 := Double2Money( cd17.AsFloat );
  FVat_Details.CD13 := Double2Money( cd13.AsFloat );
  FVat_Details.CD5  := Double2Money( cd5.AsFloat );
  FVat_Details.CD0  := Double2Money( cd0.AsFloat );

  FVat_Details.OD17 := Double2Money( od17.AsFloat );
  FVat_Details.OD13 := Double2Money( od13.AsFloat );
  FVat_Details.OD5  := Double2Money( od5.AsFloat );
  FVat_Details.OD0  := Double2Money( od0.AsFloat );

  FVat_Details.CC17 := Double2Money( cc17.AsFloat );
  FVat_Details.CC13 := Double2Money( cc13.AsFloat );
  FVat_Details.CC5  := Double2Money( cc5.AsFloat );
  FVat_Details.CC0  := Double2Money( cc0.AsFloat );

  FVat_Details.OC17 := Double2Money( oc17.AsFloat );
  FVat_Details.OC13 := Double2Money( oc13.AsFloat );
  FVat_Details.OC5  := Double2Money( oc5.AsFloat );
  FVat_Details.OC0  := Double2Money( oc0.AsFloat );

  FVat_Details.VAT1_Adj := Double2Money( ndvTotal.AsFloat );
  FVat_Details.VAT4_Adj := Double2Money( ncvTotal.AsFloat );
  FVat_Details.VAT6_Adj := Double2Money( nddTotal.AsFloat );
  FVat_Details.VAT7_Adj := Double2Money( ndcTotal.AsFloat );

  CalculateVAT;
end;

//------------------------------------------------------------------------------

function TfrmVAT.Execute: boolean;
var
  P: pBalances_Rec;
begin
   Result := false;
   with MyClient, MyClient.clFields do
   begin
      // Address and other common bits
      lblName.Caption     := clName;
      lblAddr1.caption    := clAddress_L1;
      lblAddr2.caption    := clAddress_L2;
      lblAddr3.caption    := clAddress_L3;

      lblGSTno.caption := clGST_Number;

      //Load adjustments
      P := GetBalancesRec(D1, D2);
      if Assigned(P) then begin
        cd17.AsFloat := Money2Double(P.blVAT_Adjustments[0]);
        cd13.AsFloat := Money2Double(P.blVAT_Adjustments[1]);
        cd5.AsFloat  := Money2Double(P.blVAT_Adjustments[2]);
        cd0.AsFloat  := Money2Double(P.blVAT_Adjustments[3]);
        od17.AsFloat := Money2Double(P.blVAT_Adjustments[4]);
        od13.AsFloat := Money2Double(P.blVAT_Adjustments[5]);
        od5.AsFloat  := Money2Double(P.blVAT_Adjustments[6]);
        od0.AsFloat  := Money2Double(P.blVAT_Adjustments[7]);
        cc17.AsFloat := Money2Double(P.blVAT_Adjustments[8]);
        cc13.AsFloat := Money2Double(P.blVAT_Adjustments[9]);
        cc5.AsFloat  := Money2Double(P.blVAT_Adjustments[10]);
        cc0.AsFloat  := Money2Double(P.blVAT_Adjustments[11]);
        oc17.AsFloat := Money2Double(P.blVAT_Adjustments[12]);
        oc13.AsFloat := Money2Double(P.blVAT_Adjustments[13]);
        oc5.AsFloat  := Money2Double(P.blVAT_Adjustments[14]);
        oc0.AsFloat  := Money2Double(P.blVAT_Adjustments[15]);
        CalculateWorksheet(Self);
      end;

      CalculateVAT;

      if FVAT_Class_totals.guHasUncodes then
         HelpfulWarningMsg('There are uncoded entries in this period which affect the VAT calculation',0);
  end;

  {$B-}
  if Assigned(RptParams)
  and (RptParams.BatchRunMode = R_Batch) then
  begin
     btnPrintClick(nil);
  end
  else
     Self.ShowModal;

  if okPressed then
    Save;
end;

//------------------------------------------------------------------------------

procedure ShowVATReturn( Fromdate: Integer = 0; ToDate: integer = 0; Params: TrptParameters = nil);

  function TaxPeriodSetUp : boolean;
  begin
    with MyClient, MyClient.clFields do begin
      result := ( clGST_Period <> gpNone) and ( clGST_Start_Month <> 0 );
    end;
  end;

var
  myFrm : TfrmVAT;
  NoRepeat : Boolean;
begin
  if not HasEntries then exit;
  NoRepeat := (Fromdate <> 0);
  repeat;
    myFrm := TfrmVAT.Create(Application);
    try
      {check we have all of the required values}
      with MyClient, MyClient.clFields, myFrm do
      begin
        if not TaxPeriodSetUp then begin
          HelpfulInfoMsg('Before you can do this you must setup the VAT Period and Start Month.',0);
          EditGSTDetails(BKH_Set_up_GST);
          {if still not set then exit}
          if not TaxPeriodSetUp then exit;
        end;

        //select GST Period to work with
        if NoRepeat then begin
          d1 := FromDate;
          d2 := Todate;
        end else begin
          if Fromdate <> 0 then
             d1 := fromdate;
          if not SelectVATPeriod( d1, d2, Params) then exit;
          Fromdate := d1; // Keep it for the loop
        end;
        if Assigned(Params) then
        begin
          if Params.BatchSave then
          begin
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
      end;
      MyFrm.Execute;
    finally
      MyFrm.Free;
    end;
  until NoRepeat;
end;

//------------------------------------------------------------------------------

procedure TfrmVAT.Save;
Var
  P : pBalances_Rec;
begin
  P := GetBalancesRec(D1, D2);
  if P = NIL then
  Begin
    P := New_Balances_Rec;
    P.blGST_Period_Starts := D1;
    P.blGST_Period_Ends   := D2;
    MyClient.clBalances_List.Insert( P );
  end;

  With FVat_Details do
  Begin
    P.blBAS_T1_VAT1_GST_Cdj_PAssets := VAT1;
    P.blBAS_T2_VAT2_GST_Cdj_Change := VAT2;
    P.blBAS_T3_VAT3_GST_Cdj_Other  := VAT3;
    P.blBAS_7_VAT4_GST_Adj_BAssets := VAT4;
    P.blBAS_T5_VAT5 := VAT5;
    P.blBAS_T6_VAT6 := VAT6;
    P.blBAS_T7_VAT7 := VAT7;
    P.blBAS_T8_VAT8 := VAT8;
    P.blBAS_T9_VAT9 := VAT9;
    //Adjustments
    P.blVAT_Adjustments[0] := CD17;
    P.blVAT_Adjustments[1] := CD13;
    P.blVAT_Adjustments[2] := CD5;
    P.blVAT_Adjustments[3] := CD0;
    P.blVAT_Adjustments[4] := OD17;
    P.blVAT_Adjustments[5] := OD13;
    P.blVAT_Adjustments[6] := OD5;
    P.blVAT_Adjustments[7] := OD0;
    P.blVAT_Adjustments[8] := CC17;
    P.blVAT_Adjustments[9] := CC13;
    P.blVAT_Adjustments[10] := CC5;
    P.blVAT_Adjustments[11] := CC0;
    P.blVAT_Adjustments[12] := OC17;
    P.blVAT_Adjustments[13] := OC13;
    P.blVAT_Adjustments[14] := OC5;
    P.blVAT_Adjustments[15] := OC0;
  end;

end;

procedure TfrmVAT.SetRptParams(const Value: TrptParameters);
begin
  FRptParams := Value;
end;


end.

