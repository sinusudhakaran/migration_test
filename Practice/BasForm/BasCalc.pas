unit BasCalc;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    Business Activity Statement Calculation Unit

  Written:  Feb 2000
  Authors:  Matthew

  Purpose:  Provide the type structures and calculation methods required for
            calculating the fields on the BAS and Calculation sheets.

  Notes:    The gst class totals are provided by GSTUTIL32.PAS.
            This unit takes those totals and adds them into the relevant fields
            in the BAS forms.

            GSTUtil32 return the totals in Money format.  The figures on the
            BAS form are all Integer, so the structure used here uses integer totals.
            GSTUtil32.CalculateGSTTotalsForPeriod takes the date range as parameters and
            fills a TGstInfo record with the totals for each GST type.

            TBasInfo is an object which has all the fields used in the BAS and Calc Sheet

            Assumes the MyClient is assigned and is only being called for an AU client
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   classes,
   bkConst,
   bkDefs,
   MoneyDef,
   bkblio, tsGrid;

const
  colCode = 1; colMin = 1;
  colDesc = 2;
  colType = 3;
  colLitres = 4;
  colUse = 5;
  colPercent = 6;
  colEligible = 7;
  colRate = 8;
  colTotal = 9; colMax = 9;

type
   TBASPeriodType = (p_BAS, P_IAS, P_WAS, P_All);

   TBasInfo = class
   private
      UserFields          : pBalances_Rec;
      QuarterlyFromDate   : integer;
      QuarterlyToDate     : integer;

      Procedure ClearAll;
      function  AutoAddIntoBox( box1 : integer; box2 : integer) : boolean;

      procedure SetDates( FromDate : integer; ToDate : integer);
   protected

   public
      DocumentID          : string;
      ABN                 : string;
      ABN_Extra           : string;
      TFN                 : string;
      BASFromDate         : integer;  //period covered by this statement
      BASToDate           : integer;
      BASPeriod           : integer;  //monthly, quarterly, yearly

      DueDate             : integer;
      PaymentDate         : integer;

      GSTFromDate         : integer;
      GSTToDate           : integer;
      PAYG_W_FromDate     : integer;
      PAYG_W_ToDate       : integer;
      PAYG_I_FromDate     : integer;
      PAYG_I_ToDate       : integer;
      FBT_FromDate        : integer;
      FBT_ToDate          : integer;

      IsQuarterlyStatement : boolean;
      IsAnnualStatement    : boolean;

      BAS_Rule_Setup      : Array[ bfMin..bfMax ] of Boolean;  //used by BasFrm

      BasFormType         : byte;

      //** Calculation Sheet Values
      //Supplies
      iIncome_G1            : integer;
      iExports_G2           : integer;
      iGSTFreeSupplies_G3   : integer;
      iInputTaxedSales_G4   : integer;
      iTotalGSTFree_G5      : integer;
      iTotalTaxableSupp_G6  : integer;
      iIncAdjustments_G7    : integer;
      iTotalTaxSuppAdj_G8   : integer;
      iGSTPayable_G9        : integer;
      //Acquisitions
      iCapitalAcq_G10       : integer;
      iOtherAcq_G11         : integer;
      iTotalAcq_G12         : integer;
      iAcqInputTaxedSales_G13 : integer;
      iAcqNoGST_G14         : integer;
      iEstPrivateUse_G15    : integer;
      iTotalNonCreditAcq_G16: integer;
      iTotalCreditAcq_G17   : integer;
      iAcqAdjustments_G18   : integer;
      iTotalCreditAcqAdj_G19: integer;
      iGSTCredit_G20        : integer;

      //GST
      iGSTOptionUsed        : integer;
      bG1IncludesGST        : boolean;
      iG21_ATOInstalment    : integer;
      iG22_EstimatedNetGST  : integer;
      iG23_VariedAmount     : integer;
      iG24_ReasonVar        : integer;

      //Amounts Withheld
      iTotalSalary_W1       : integer;
      iSalaryWithheld_W2    : integer;
      iInvstmntDist_W3      : integer;
      iInvoicePymt_W4       : integer;
      iW5_TotalAmountsWithheld : integer;

      iPAYGInstalmentOptionUsed  : integer;
      iT7_ATOInstalment     : integer;
      iT8_EstimatedTax      : integer;
      iT9_VariedAmount      : integer;
      iT6_VariedAmount      : integer;
      iT11_T1x_T2orT3       : integer;

      //Income Tax Instalment
      iTaxInstalmIncome_T1  : integer;
      dTaxInstalmRate_T2    : double;
      dTaxVarInstalmRate_T3 : double;
      iTaxReasonVar_T4      : integer;
      //FBT Tax Instalment
      iFBTInstalm_F1        : integer;
      iFBTTotalPayable_F2   : integer;
      iFBTVariedInstalm_F3  : integer;
      iFBTReasonVar_F4      : integer;

      //Simplified Calculation totals
      iGstTotal_Payable     : integer;
      iGstTotal_Credit_C    : integer;
      iGstTotal_Credit_O    : integer;

      //** BAS Sheet Values
      //Debits
      iGSTPayable_1A        : integer;
      iWineEqlPayable_1C    : integer;
      iLuxCarPayable_1E     : integer;
      iTotalDebit_2A        : integer;
      //Credits
      iGSTCredit_1B         : integer;
      iWineEqlRefund_1D     : integer;
      iLuxCarRefund_1F      : integer;
      iSalesTaxCredit_1G    : integer;
      i1H_GSTInstalment     : integer;
      iTotalCredit_2B       : integer;
      //GST Total
      iGSTNetAmount_3      : integer;
      //Tax Instalments
      iTotalWithheld_4      : integer;
      iIncomeTaxInstalm_5A  : integer;
      iFBTInstalm_6A        : integer;
      iDeferredInstalm_7    : integer;
      iFuelOverClaim_7C     : integer;
      iFuelCredit_7D        : integer;
      iTaxPayableTotal_8A   : integer;
      //Tax Credits
      iCrAdjPrevIncome_5B   : integer;
      iVariationCr_6B       : integer;
      iTaxCreditTotal_8B    : integer;
      //Total
      iNetTaxObligation_9   : integer;

      iBAST5                : integer;

      SpecialFormType       : integer;   //set to -1 to dynamically set form type

      IsFuel: Boolean;
      iIsFuelPercentMethod: Boolean;
      //indicators
//         HasUncodes            : Boolean;
//         HasJournals           : Boolean;
//         HasWhichJournals      : Array[btMin..btMax] of Boolean;

      //calculation procedures
      procedure PopulateBAS(d1 : integer; d2 : integer; Fuel: TtsGrid; Silent : Boolean = False);
      procedure Recalculate;
      function  LoadUserFields(Fuel: TtsGrid) : boolean;
      procedure SaveUserFields(Fuel: TtsGrid);
      function DateFrom (const Period :TBASPeriodType)  : Integer;
      function DateTo (const Period :TBASPeriodType)  : Integer;
   end;

//******************************************************************************
implementation

uses
   SysUtils,
   Math,
   glConst,
   Globals,
   GenUtils,
   GSTUtil32,
   BASUtils,
   stDate,
   WarningMoreFrm,
   bkFSio, INISettings;

const
  UnitName = 'BASCALC';

var
  DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TBasInfo }
procedure TBasInfo.ClearAll;
begin
   BASFromDate           := 0;
   BASToDate             := 0;
   GSTFromDate           := 0;
   GSTToDate             := 0;
   PAYG_I_FromDate       := 0;
   PAYG_I_ToDate         := 0;
   PAYG_W_FromDate       := 0;
   PAYG_W_ToDate         := 0;
   FBT_FromDate          := 0;
   FBT_ToDate            := 0;

   QuarterlyFromDate     := 0;
   QuarterlyToDate       := 0;

   DueDate               := 0;
   PaymentDate           := 0;

   BasFormType           := 0;

   FillChar( BAS_Rule_Setup, Sizeof( BAS_Rule_Setup ), 0 );

   //** Calculation Sheet Values
   //Supplies
   iIncome_G1            := 0;
   iExports_G2           := 0;
   iGSTFreeSupplies_G3   := 0;
   iInputTaxedSales_G4   := 0;
   iTotalGSTFree_G5      := 0;
   iTotalTaxableSupp_G6  := 0;
   iIncAdjustments_G7    := 0;
   iTotalTaxSuppAdj_G8   := 0;
   iGSTPayable_G9        := 0;
   //Acquisitions
   iCapitalAcq_G10       := 0;
   iOtherAcq_G11         := 0;
   iTotalAcq_G12         := 0;
   iAcqInputTaxedSales_G13 := 0;
   iAcqNoGST_G14         := 0;
   iEstPrivateUse_G15    := 0;
   iTotalNonCreditAcq_G16:= 0;
   iTotalCreditAcq_G17   := 0;
   iAcqAdjustments_G18   := 0;
   iTotalCreditAcqAdj_G19:= 0;
   iGSTCredit_G20        := 0;
   //gst values
   iGSTOptionUsed        := 0;
   bG1IncludesGST        := false;
   iG22_EstimatedNetGST  := 0;
   iG23_VariedAmount     := 0;
   iG24_ReasonVar        := 0;


   //Amounts Withheld
   iTotalSalary_W1       := 0;
   iSalaryWithheld_W2    := 0;
   iInvstmntDist_W3      := 0;
   iInvoicePymt_W4       := 0;

   iW5_TotalAmountsWithheld := 0;
   //Income Tax Instalment
   iTaxInstalmIncome_T1  := 0;
   dTaxInstalmRate_T2    := 0;
   dTaxVarInstalmRate_T3 := 0;
   iTaxReasonVar_T4      := 0;

   iPAYGInstalmentOptionUsed := 0;
   iT7_ATOInstalment       := 0;
   iT8_EstimatedTax        := 0;
   iT9_VariedAmount        := 0;
   iT6_VariedAmount        := 0;
   iT11_T1x_T2orT3         := 0;

   //FBT Tax Instalment
   iFBTInstalm_F1        := 0;
   iFBTTotalPayable_F2   := 0;
   iFBTVariedInstalm_F3  := 0;
   iFBTReasonVar_F4      := 0;
   //** BAS Sheet Values
   //Debits
   iGSTPayable_1A        := 0;
   iWineEqlPayable_1C    := 0;
   iLuxCarPayable_1E     := 0;
   iTotalDebit_2A        := 0;
   //Credits
   iGSTCredit_1B         := 0;
   iWineEqlRefund_1D     := 0;
   iLuxCarRefund_1F      := 0;
   iSalesTaxCredit_1G    := 0;
   iTotalCredit_2B       := 0;

   i1H_GSTInstalment     := 0;
   //GST Total
   iGSTNetAmount_3       := 0;
   //Tax Instalments
   iTotalWithheld_4      := 0;
   iIncomeTaxInstalm_5A  := 0;
   iFBTInstalm_6A        := 0;
   iDeferredInstalm_7    := 0;
   iFuelOverClaim_7C     := 0;
   iFuelCredit_7D        := 0;
   iTaxPayableTotal_8A   := 0;
   //Tax Credits
   iCrAdjPrevIncome_5B   := 0;
   iVariationCr_6B       := 0;
   iTaxCreditTotal_8B    := 0;
   //Total
   iNetTaxObligation_9   := 0;
   iBAST5                := 0;

   //Simplified Totals
   iGstTotal_Payable     := 0;
   iGstTotal_Credit_C    := 0;
   iGstTotal_Credit_O    := 0;

   iIsFuelPercentMethod := False;
end;


function TBasInfo.DateFrom(const Period: TBASPeriodType): Integer;
begin
  Result := 0;
  case Period of
     p_BAS: Result := GSTFromDate;
     P_IAS: Result := PAYG_I_FromDate;
     P_WAS: Result := PAYG_W_FromDate;
     P_All: Result := GSTFromDate;
  end;
end;

function TBasInfo.DateTo(const Period: TBASPeriodType): Integer;
begin
   Result := 0;
   case Period of
     p_BAS: Result := GSTToDate;
     P_IAS: Result := PAYG_I_ToDate;
     P_WAS: Result := PAYG_W_ToDate;
     P_All: Result := GSTToDate;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasInfo.PopulateBAS(d1 : integer; d2 : integer; Fuel: TtsGrid; Silent :boolean = False );
//retrieve all the gst totals for this period and total into correct bas fields
var
   Temp_BAS_Figures    : Array[ bfMin..bfMax ] of Money;
   mGstTotal_Payable   : Money;
   mGstTotal_Credit_C  : Money;
   mGstTotal_Credit_O  : Money;

   procedure GetBASFiguresForPeriod( pFrom: integer; pTo: integer; ShowWarning : Boolean);
   //get GST/BAS totals for the period
   var
      GSTInfo : TGstInfo;
      i       : Integer;
      Account : pAccount_Rec;
      fNo     : Integer;
      fSource : Byte;
      fCode   : Bk5CodeStr;
      fBalance: Byte;
      fdPercent : Double;
   begin
      //clear current values
      FillChar( Temp_BAS_Figures, Sizeof( Temp_BAS_Figures ), 0 );
      mGstTotal_Payable     := 0;
      mGstTotal_Credit_C    := 0;
      mGstTotal_Credit_O    := 0;

      //Add up GST values
      GSTUTIL32.CalculateGSTTotalsForPeriod( pFrom, pTo, GSTInfo, -1);

      if (GSTInfo.guHasUncodes) and (ShowWarning) then
        HelpfulWarningMsg('There are uncoded entries in this period which will affect the GST calculation',0);

      with MyClient.clFields, MyClient.clChart do begin
         For i := MIN_SLOT to MAX_SLOT do begin
            fNo     := clBAS_Field_Number         [ i ];
            fSource := clBAS_Field_Source         [ i ];
            fCode   := clBAS_Field_Account_Code   [ i ];
            fBalance:= clBAS_Field_Balance_Type   [ i ];
            fdPercent := Percent2Double( clBas_Field_Percent[ i]);
            If fNo in [ bfMin..bfMax ] then begin
               If fSource = BASUtils.bsFrom_Chart then begin
                  //accumulate totals using the values stored in the chart
                  Account := FindCode( fCode );
                  If Assigned( Account ) then With Account^ do
                  Begin
                     Case fBalance of
                        blGross : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( chGross * (fdPercent/100));
                        blNet   : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( chNet * (fdPercent/100));
                        blTax   : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( chTax * (fdPercent/100));
                     end;
                     //store figures for simplified gst calculation, store the gst component only
                     //for the following boxes.  The gross value in these boxes will be overriden later
                     case fNo of
                        bfG1 : begin
                           mGstTotal_Payable := mGstTotal_Payable + chTax;
                        end;
                        bfG10 : begin
                           mGstTotal_Credit_C  := mGstTotal_Credit_C + chTax;
                        end;
                        bfG11 : begin
                           mGstTotal_Credit_O  := mGstTotal_Credit_O + chTax;
                        end;
                     end;

                  end;
               end
               else
               Begin
                  //accumulate totals using the values stored in the gst class totals
                  If fSource in [ 0..MAX_GST_CLASS ] then
                  Begin
                     Case fBalance of
                        blGross : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( GSTInfo.guGross_Totals[ fSource ] * (fdPercent/100));
                        blNet   : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( GSTInfo.guNet_Totals[ fSource ] * (fdPercent/100));
                        blTax   : Temp_BAS_Figures[ fNo ] := Temp_BAS_Figures[ fNo ] + ( GSTInfo.guGST_Totals[ fSource ] * (fdPercent/100));
                     end;
                     //store figures for simplified gst calculation, store the gst component only
                     //for the following boxes.  The gross value in these boxes will be overriden later
                     case fNo of
                        bfG1 : begin
                           mGstTotal_Payable := mGstTotal_Payable + GSTInfo.guGST_Totals[ fSource ];
                        end;
                        bfG10 : begin
                           mGstTotal_Credit_C  := mGstTotal_Credit_C + GSTInfo.guGST_Totals[ fSource ];
                        end;
                        bfG11 : begin
                           mGstTotal_Credit_O  := mGstTotal_Credit_O + GSTInfo.guGST_Totals[ fSource ];
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;
   end;

var
   i       : Integer;
   j       : integer;
   fNo     : Integer;
   UserFieldsLoaded : boolean;
begin
   //clear everything
   ClearAll;
   //set dates
   SetDates( d1,d2);

   //set up header
   with MyClient.clFields do begin
      DocumentID  := '';
      j := Pos( '-' , clGST_Number);
      if j > 0 then begin
         ABN       := Copy( clGST_Number, 1, j -1);
         ABN_Extra := Copy( clGST_Number, j + 1, length( clGST_Number));
      end
      else begin
         ABN       := clGST_Number;
         ABN_Extra := '';
      end;
      TFN := clTFN;
   end;

   //Set flag to show which bas boxes have a rule setup, this is used by LoadUserFields
   FillChar( BAS_Rule_Setup, Sizeof( BAS_Rule_Setup), 0);
   with MyClient.clFields do begin
      for i := MIN_SLOT to MAX_SLOT do begin
         fNo := clBAS_Field_Number[ i];
         if fNo in [ bfMin..bfMax] then
            BAS_Rule_Setup[ fNo] := True;
      end;
   end;

   //load GST values if BAS Period Matches or GST Period is monthly.  The ensures
   //that on a quarterly statement the gst values will only be monthly
   if ( BASPeriod = MyClient.clFields.clGST_Period)
   or ( MyClient.clFields.clGST_Period = gpMonthly)
   or ( SpecialFormType in [ bsH, bsBasZ, bsK])
   then begin
      //Load figures for GST
      GetBASFiguresForPeriod( GSTFromDate, GSTToDate, not Silent);

      //alter sign on the boxes, sales will appear as -ve so sign needs reversing
      iIncome_G1                 := -Money2IntTrunc( Temp_BAS_Figures[ bfG1 ] );
      iExports_G2                := -Money2IntTrunc( Temp_BAS_Figures[ bfG2 ] );
      iGSTFreeSupplies_G3        := -Money2IntTrunc( Temp_BAS_Figures[ bfG3 ] );
      iInputTaxedSales_G4        := -Money2IntTrunc( Temp_BAS_Figures[ bfG4 ] );
      iGstTotal_Payable          := -Money2IntTrunc( mGstTotal_Payable);

      iCapitalAcq_G10            := Money2IntTrunc( Temp_BAS_Figures[ bfG10 ] );
      iOtherAcq_G11              := Money2IntTrunc( Temp_BAS_Figures[ bfG11 ] );

      iAcqInputTaxedSales_G13    := Money2IntTrunc( Temp_BAS_Figures[ bfG13 ] );
      iAcqNoGST_G14              := Money2IntTrunc( Temp_BAS_Figures[ bfG14 ] );
      iEstPrivateUse_G15         := Money2IntTrunc( Temp_BAS_Figures[ bfG15 ] );

      iGstTotal_Credit_C         := Money2IntTrunc( mGstTotal_Credit_C);
      iGstTotal_Credit_O         := Money2IntTrunc( mGstTotal_Credit_O);

      iSalesTaxCredit_1G         := Money2IntTrunc( Temp_BAS_Figures[ bf1G ] );

      iCrAdjPrevIncome_5B        := Money2IntTrunc( Temp_Bas_Figures[ bf5b]);
      iVariationCr_6B            := Money2IntTrunc( Temp_Bas_Figures[ bf6b]);
      iDeferredInstalm_7         := -Money2IntTrunc( Temp_Bas_Figures[ bf7]);
      iFuelOverClaim_7C          := Money2IntTrunc( Temp_Bas_Figures[ bf7c]);
      //dont think we need to load the next line anymore as the bas rules are
      //being used in a completely different way for 7D fields.  The rule is
      //used to prefill the fuel worksheet rather than calculate a total
      iFuelCredit_7D             := Money2IntTrunc( Temp_Bas_Figures[ bf7d]);

      iBAST5                     := Money2IntTrunc( Temp_Bas_Figures[ bft5]);


      //special boxes - it is possible to setup these boxes so that the amount is
      //automatically placed in the appropriate box depending on the sign.
      //to do this both boxes must be set up identically
      if AutoAddIntoBox( bfG7, bfG18) then begin
         if Temp_BAS_Figures[ bfG7] <= 0 then
            iIncAdjustments_G7      := -Money2IntTrunc( Temp_BAS_Figures[ bfG7 ] )
         else
            iAcqAdjustments_G18     := Money2IntTrunc( Temp_BAS_Figures[ bfG18 ] );
      end
      else begin
         iIncAdjustments_G7         := -Money2IntTrunc( Temp_BAS_Figures[ bfG7 ] );
         iAcqAdjustments_G18        := Money2IntTrunc( Temp_BAS_Figures[ bfG18 ] );
      end;

      if AutoAddIntoBox( bf1C, bf1D) then begin
         if Temp_BAS_Figures[ bf1C] <= 0 then
            iWineEqlPayable_1C      := -Money2IntTrunc( Temp_BAS_Figures[ bf1C ] )
         else
            iWineEqlRefund_1D       := Money2IntTrunc( Temp_BAS_Figures[ bf1D ] );
      end
      else begin
         iWineEqlPayable_1C         := -Money2IntTrunc( Temp_BAS_Figures[ bf1C ] );
         iWineEqlRefund_1D          := Money2IntTrunc( Temp_BAS_Figures[ bf1D ] );
      end;

      if AutoAddIntoBox( bf1E, bf1F) then begin
         if Temp_BAS_Figures[ bf1E] <= 0 then
            iLuxCarPayable_1E       := -Money2IntTrunc( Temp_BAS_Figures[ bf1E ] )
         else
            iLuxCarRefund_1F        := Money2IntTrunc( Temp_BAS_Figures[ bf1F ] );
      end
      else begin
         iLuxCarPayable_1E          := -Money2IntTrunc( Temp_BAS_Figures[ bf1E ] );
         iLuxCarRefund_1F           := Money2IntTrunc( Temp_BAS_Figures[ bf1F ] );
      end;
   end;

   if ( BASPeriod = MyClient.clFields.clBAS_PAYG_Withheld_Period)
   or ( MyClient.clFields.clBAS_PAYG_Withheld_Period = gpMonthly)then begin
      //Load figures for PAYG period
      GetBASFiguresForPeriod( PAYG_W_FromDate, PAYG_W_ToDate, False);

      iTotalSalary_W1            := Money2IntTrunc( Temp_BAS_Figures[ bfW1 ] );
      iSalaryWithheld_W2         := Money2IntTrunc( Temp_BAS_Figures[ bfW2 ] );
      iInvstmntDist_W3           := Money2IntTrunc( Temp_BAS_Figures[ bfW3 ] );
      iInvoicePymt_W4            := Money2IntTrunc( Temp_BAS_Figures[ bfW4 ] );
   end;

   if ( BASPeriod = MyClient.clFields.clBAS_PAYG_Instalment_Period )
   or ( MyClient.clFields.clBAS_PAYG_Instalment_Period = gpMonthly)then begin
      GetBASFiguresForPeriod( PAYG_I_FromDate, PAYG_I_ToDate, False);
      iTaxInstalmIncome_T1       := - Money2IntTrunc( Temp_Bas_Figures[ bft1]);
   end;
   //load stored values
   UserFieldsLoaded := LoadUserFields(Fuel);

   //set form type
   if SpecialFormType = -1 then begin
      if ( BasToDate <= 146643) then  //30/06/2001
         BasFormType := bs2000
      else
         BasFormType := BASUtils.BasIasFormType( MyClient, IsQuarterlyStatement, d2);
   end
   else
      BasFormType := specialFormType;

   //now set defaults for new form based on the form type
   if not UserFieldsLoaded then begin
      //no stored values found so must load defaults
      //load defaults if applicable
      if BasFormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasD, bsBasW, bsBasF, bsBasX] then
         iGSTOptionused := MyClient.clFields.clBAS_Last_GST_Option;

      if ( BasFormType in [ bsBasA, bsBasU, bsBasC, bsBasV, bsBasG, bsBasY, bsIasI, bsIasJ]) and
         ( MyClient.clFields.clBAS_PAYG_Instalment_Period <> gpNone)
      then
         iPAYGInstalmentOptionUsed := MyClient.clFields.clBAS_Last_PAYG_Instalment_Option;

      if iPAYGInstalmentOptionUsed = 0 then
        iPAYGInstalmentOptionUsed := 1; // Default value is set
        
      //option 1 always selected if Bas G
      if BasFormType in [bsBasG, bsBasY] then begin
         iGSTOptionUsed := 1;
      end;
      //always default to includes GST
      bG1IncludesGST := true;
   end;

   //set defaults for pre Jul 2001 forms
   if ( BasFormType = bs2000) then begin
      iGSTOptionUsed := 1;
      iPAYGInstalmentOptionUsed := 2;
      bG1IncludesGST := true;
   end;

   if ( BasFormType in [ bsH, bsBasZ, bsK]) then begin
      iGSTOptionUsed := 1;
   end;

   if ( BasFormType in [ bsBasG, bsBasY]) and ( iGSTOptionUsed = 0) then begin
      //this is incase sites have filed in the figures before upgrading to the
      //latest version
      iGSTOptionUsed := 1;
   end;

   //call recalculate routine to fill in all of the calculated fields
   Recalculate;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasInfo.Recalculate;
//recalculate all fields.  This should be called if one of the user input fields changes
//added up all of the sum fields and copies values from Calculation sheet to BAS
begin
   //---------------- Calculation Sheet -----------------
   case MyClient.clFields.clBAS_Calculation_Method of
      bmFull : begin
         //                    FULL METHOD
         //GST
         iTotalGSTFree_G5       := iExports_G2 + iGSTFreeSupplies_G3 + iInputTaxedSales_G4;
         iTotalTaxableSupp_G6   := iIncome_G1 - iTotalGstFree_G5;
         //G7
         iTotalTaxSuppAdj_G8    := iTotalTaxableSupp_G6 + iIncAdjustments_G7;
         iGSTPayable_G9         := ( iTotalTaxSuppAdj_G8 div 11 );

         iTotalAcq_G12          := iCapitalAcq_G10 + iOtherAcq_G11;
         iTotalNonCreditAcq_G16 := iAcqInputTaxedSales_G13 + iAcqNoGst_G14 + iEstPrivateUse_G15;
         iTotalCreditAcq_G17    := iTotalAcq_G12 - iTotalNonCreditAcq_G16;
         //G18
         iTotalCreditAcqAdj_G19 := iTotalCreditAcq_G17 + iAcqAdjustments_G18;
         iGSTCredit_G20         := ( iTotalCreditAcqAdj_G19 div 11);
      end;
      bmSimplified : begin
         //                    SIMPLIFIED METHOD
         //This method calculates the values for G1, G10 and G11 from the GST amounts,
         //Rather than using the gross totals.
         //Supplies
         iTotalGSTFree_G5       := iExports_G2 + iGSTFreeSupplies_G3 + iInputTaxedSales_G4;
{!!}     iTotalTaxableSupp_G6   := iGstTotal_Payable * 11;
{!!}     iIncome_G1             := iTotalGstFree_G5 + iTotalTaxableSupp_G6;
         //G7
         iTotalTaxSuppAdj_G8    := iTotalTaxableSupp_G6 + iIncAdjustments_G7;
         iGSTPayable_G9         := ( iTotalTaxSuppAdj_G8 div 11 );

         //Acquisitions
         iTotalNonCreditAcq_G16 := iAcqInputTaxedSales_G13 + iAcqNoGst_G14 + iEstPrivateUse_G15;
{!!}     iTotalCreditAcq_G17    := ( iGstTotal_Credit_C * 11) + ( iGstTotal_Credit_O * 11);

{!!}     iTotalAcq_G12          := iTotalNonCreditAcq_G16 + iTotalCreditAcq_G17;
{!!}     iOtherAcq_G11          := iTotalAcq_G12 - ( iGstTotal_Credit_C * 11);
{!!}     iCapitalAcq_G10        := ( iGstTotal_Credit_C * 11);
         //G18
         iTotalCreditAcqAdj_G19 := iTotalCreditAcq_G17 + iAcqAdjustments_G18;
         iGSTCredit_G20         := ( iTotalCreditAcqAdj_G19 div 11);
      end;
   end;

   //Only need G boxes for annual gst info report
   if SpecialFormType in [ bsK] then exit;

   //------- PAYG Tax Withheld ---------------
   iW5_TotalAmountsWithheld   := iSalaryWithheld_W2 + iInvstmntDist_W3 + iInvoicePymt_W4;

   //------- PAYG Tax Instalment -------------
   case iPAYGInstalmentOptionUsed of
      2: begin
         if (dTaxVarInstalmRate_T3 <> 0) or (iTaxReasonVar_T4 > 0) then
            iT11_T1x_T2orT3  := Trunc ( iTaxInstalmIncome_T1 * ( dTaxVarInstalmRate_T3 /100))
         else
            iT11_T1x_T2orT3  := Trunc ( iTaxInstalmIncome_T1 * ( dTaxInstalmRate_T2 /100));
      end;
      else
         iT11_T1x_T2orT3 := 0;
   end;

   //----------------- BAS Form -------------------------
   case iGSTOptionUsed of
      1,2 : begin
         iGSTPayable_1A      := iGSTPayable_G9;
         iGSTCredit_1B       := iGSTCredit_G20;
      end;
      3 : begin
          if iG23_VariedAmount <> 0 then
             iGSTPayable_1A  := iG23_VariedAmount
          else
             iGSTPayable_1A  := iG21_ATOInstalment;

          iGSTCredit_1B      := 0;
      end;
      else begin
         iGSTPayable_1A      := 0;
         iGSTCredit_1B       := 0;
      end;
   end;

   iTotalDebit_2A         := iGSTPayable_1A + iWineEqlPayable_1C + iLuxCarPayable_1E;
   iTotalCredit_2B        := iGSTCredit_1B + iWineEqlRefund_1D +
                             iLuxCarRefund_1F + iSalesTaxCredit_1G +
                             i1H_GSTInstalment;

   iGSTNetAmount_3        := iTotalDebit_2A - iTotalCredit_2B;

   //Amounts Withheld
   iTotalWithheld_4       := iW5_TotalAmountsWithheld;

   //PAYG Instalment
   case iPAYGInstalmentOptionUsed of
      1 : begin
         if iT9_VariedAmount <> 0 then
            iIncomeTaxInstalm_5A := iT9_VariedAmount
         else
            iIncomeTaxInstalm_5A := iT7_ATOInstalment;
      end;

      2 : begin
          iIncomeTaxInstalm_5A := iT11_T1x_T2orT3;
      end;

      3 : begin
         if iT6_VariedAmount <> 0 then
            iIncomeTaxInstalm_5A := iT6_VariedAmount
         else
            iIncomeTaxInstalm_5A := 0;
      end;
      else
         iIncomeTaxInstalm_5a := 0;
   end;

   //Fringe Benefits tax instalment
   if (iFBTVariedInstalm_F3 <> 0) or (iFBTReasonVar_F4 > 0) then
     iFBTInstalm_6A := iFBTVariedInstalm_F3
   else
     iFBTInstalm_6A := iFBTInstalm_F1;

   //Totals
   iTaxPayableTotal_8A    := iTotalDebit_2A
                             + iTotalWithheld_4
                             + iIncomeTaxInstalm_5A
                             + iFBTInstalm_6A
                             + iDeferredInstalm_7;

   if IsFuel then
     iTaxPayableTotal_8A := iTaxPayableTotal_8A + iFuelOverClaim_7C;

   iTaxCreditTotal_8B     := iTotalCredit_2B
                             + iCrAdjPrevIncome_5B
                             + iVariationCr_6B;

   if IsFuel then
     iTaxCreditTotal_8B := iTaxCreditTotal_8B + iFuelCredit_7D;

   iNetTaxObligation_9    := iTaxPayableTotal_8A - iTaxCreditTotal_8B;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasInfo.LoadUserFields(Fuel: TtsGrid) : boolean;
//try to find a matching period in the balance list
//and load the figures that were input when last edited
//if no balance record exists then we have never saved a GST
//return for this period

//Returns true if user values have been loaded, returns false if no balances rec exists
var
   Balances : pBalances_Rec;
   B        : integer;
   f        : pFuel_Sheet_Rec;
   Account  : pAccount_Rec;
   E: TtsCellChangedEvent;
begin
   //get balances for this gst period if available
   UserFields := NIL;
   with MyClient.clBalances_List do for B := 0 to Pred( itemCount ) do begin
      Balances := Balances_At( B );
      with Balances^ do begin
         If ( blGST_Period_Starts = BasFromDate ) and
            ( blGST_Period_Ends   = BasToDate ) then UserFields := Balances;
         end;
   end;

   if not Assigned( UserFields) then begin
      //if BAS_Rule_Setup[ bf7d ] then Case 8575
      begin
       // reset
       E := Fuel.OnCellChanged;
       Fuel.OnCellChanged := nil;
       Fuel.Rows := 0;
       Fuel.Rows := 50;
       Fuel.OnCellChanged := E;
      end;
      result := false;
      exit;
   end;

   //user values loaded
   result := true;
   //now load values into bas obj
   with UserFields^ do begin
      DocumentID            := blBAS_Document_ID;

      BasFormType           := blBAS_Form_Used;  //will be reset each time

      iGSTOptionUsed        := blBAS_GST_Option;
      bG1IncludesGST        := blBAS_GST_Included;
      iG21_ATOInstalment    := Money2IntTrunc( blBAS_G21_GST_Closing_Creditors_BalanceA );
      iG22_EstimatedNetGST  := Money2IntTrunc( blBAS_G22_GST_Opening_Creditors_BalanceB);
      iG23_VariedAmount     := Money2IntTrunc( blBAS_G23);
      iG24_ReasonVar        := blBAS_G24;

      //** Calculation Sheet Values

      //Adjustments

      If not BAS_Rule_Setup[ bfG7 ]  then iIncAdjustments_G7    := Money2IntTrunc( blBAS_G7_GST_Adj_Assets);
      If not BAS_Rule_Setup[ bfG18 ] then iAcqAdjustments_G18   := Money2IntTrunc( blBAS_G18_GST_Adj_Entertain);

      //Amounts Withheld

      If not BAS_Rule_Setup[ bfW1 ] then iTotalSalary_W1       := Money2IntTrunc( blBAS_W1_GST_Adj_Change);
      If not BAS_Rule_Setup[ bfW2 ] then iSalaryWithheld_W2    := Money2IntTrunc( blBAS_W2_GST_Adj_Exempt);
      If not BAS_Rule_Setup[ bfW3 ] then iInvstmntDist_W3      := Money2IntTrunc( blBAS_W3_GST_Adj_Other);
      If not BAS_Rule_Setup[ bfW4 ] then iInvoicePymt_W4       := Money2IntTrunc( blBAS_W4_GST_Cdj_BusUse);

      //Income Tax Instalment
      iPAYGInstalmentOptionUsed := blBAS_PAYG_Instalment_Option;

      If not BAS_Rule_Setup[ bfT1 ] then iTaxInstalmIncome_T1  := Money2IntTrunc( blBAS_T1_VAT1_GST_Cdj_PAssets);
      dTaxInstalmRate_T2    := Money2Double( blBAS_T2_VAT2_GST_Cdj_Change);
      dTaxVarInstalmRate_T3 := Money2Double( blBAS_T3_VAT3_GST_Cdj_Other);
      iTaxReasonVar_T4      := blBAS_T4;

      iT7_ATOInstalment     := Money2intTrunc( blBAS_T7_VAT7);
      iT8_EstimatedTax      := Money2intTrunc( blBAS_T8_VAT8);
      iT9_VariedAmount      := Money2intTrunc( blBAS_T9_VAT9);
      iT6_VariedAmount      := Money2intTrunc( blBAS_T6_VAT6);
      //FBT Tax Instalment
      iFBTInstalm_F1        := Money2IntTrunc( blBAS_F1_GST_Closing_Debtors_BalanceA);
      iFBTTotalPayable_F2   := Money2IntTrunc( blBAS_F2_GST_Opening_Debtors_BalanceB);
      iFBTVariedInstalm_F3  := Money2IntTrunc( blBAS_F3);
      iFBTReasonVar_F4      := blBAS_F4;
      //** BAS Sheet Values


      //Debits
      If not BAS_Rule_Setup[ bf1C ] then iWineEqlPayable_1C    := Money2IntTrunc( blBAS_1C_PT_Last_Months_Income);
      If not BAS_Rule_Setup[ bf1E ] then iLuxCarPayable_1E     := Money2IntTrunc( blBAS_1E_PT_Assets);
      //Credits
      If not BAS_Rule_Setup[ bf1D ] then iWineEqlRefund_1D     := Money2IntTrunc( blBAS_1D_PT_Branch_Income);
      If not BAS_Rule_Setup[ bf1F ] then iLuxCarRefund_1F      := Money2IntTrunc( blBAS_1F_PT_Tax);
      If not BAS_Rule_Setup[ bf1G ] then iSalesTaxCredit_1G    := Money2IntTrunc( blBAS_1G_PT_Refund_Used);
      //Instalments
      if not BAS_Rule_Setup[ bf7  ] then iDeferredInstalm_7    := Money2IntTrunc( blBAS_7_VAT4_GST_Adj_BAssets);
      if not BAS_Rule_Setup[ bf7c ] then iFuelOverClaim_7C     := Money2IntTrunc( blBAS_7c);
      if not BAS_Rule_Setup[ bf7d ] then iFuelCredit_7D        := Money2IntTrunc( blBAS_7d);
      if not BAS_Rule_Setup[ bft5 ] then iBAST5                := Money2IntTrunc( blBAS_T5_VAT5);
      if not BAS_Rule_Setup[ bf5B ] then iCrAdjPrevIncome_5B   := Money2IntTrunc( blBAS_5B_PT_Ratio);
      if not BAS_Rule_Setup[ bf6B ] then iVariationCr_6B       := Money2IntTrunc( blBAS_6B_GST_Adj_PrivUse);

      // load fuel sheet recs
      E := Fuel.OnCellChanged;
      Fuel.OnCellChanged := nil;
      Fuel.Rows := 0;
      Fuel.Rows := 50;
      Fuel.OnCellChanged := E;
      iIsFuelPercentMethod := blUsing_Fuel_Percent_Method;
      B := 1;
      f := blFirst_Fuel_Sheet;
      while Assigned(f) do
      begin
        Fuel.Cell[colCode, B] := f.fsAccount;
        Account := MyClient.clChart.FindCode( f.fsAccount );
        if Assigned(Account) then
          Fuel.Cell[ColDesc, B] := Account.chAccount_Description
        else if f.fsAccount <> '' then
         Fuel.Cell[ColDesc, B] := 'INVALID ACCOUNT';
        Fuel.Cell[colType, B] := f.fsFuel_Type;
        Fuel.Cell[colLitres, B] := Percent2Double(f.fsFuel_Litres);
        Fuel.Cell[colUse, B] := f.fsFuel_Use;
        Fuel.Cell[colPercent, B] := Percent2Double(f.fsPercentage);
        Fuel.Cell[colEligible, B] := Percent2Double(f.fsFuel_Eligible);
        Fuel.Cell[colRate, B] := CreditRate2Double(f.fsCredit_Rate);
        Fuel.Cell[colTotal, B] := MyRoundTo(Fuel.Cell[colEligible, B] * (Fuel.Cell[colRate, B] / 100), 2);
        f := f.fsNext;
        Inc(B);
      end;

      i1H_GSTInstalment       := Money2IntTrunc( blBAS_1H);
   end;
end;

function AsFloatSort(List: TStringList; Index1, Index2: Integer): Integer;
var
   num1, num2: Double;
begin
   num1 := StrToFloatDef(List[Index1], 0);
   num2 := StrToFloatDef(List[Index2], 0);


   if num1 < num2 then
     Result := -1
   else if num1 > num2 then
     Result := 1
   else
     Result := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasInfo.SaveUserFields(Fuel: TtsGrid);
//save back the balances that have been used
var
  f: pFuel_Sheet_Rec;
  i, j: Integer;
  s: TStringList;
  SaveRow : Boolean;
begin
    //if no balance record has been saved for this period then
    //create one.
    If UserFields=NIL then Begin
       UserFields := New_Balances_Rec;
       UserFields^.blGST_Period_Starts := BasFromDate;
       UserFields^.blGST_Period_Ends   := BasToDate;
       MyClient.clBalances_List.Insert( UserFields );
    end;

    With UserFields^ do Begin
       blBAS_Document_ID := DocumentID;
       blBAS_Form_Used   := BasFormType;

       blBAS_G7_GST_Adj_Assets := Int2Money( iIncAdjustments_G7);
       blBAS_G18_GST_Adj_Entertain := Int2Money( iAcqAdjustments_G18);

       blBAS_GST_Option    := iGSTOptionUsed;
       blBAS_GST_Included  := bG1IncludesGST;

       if blBas_GST_Option = 3 then begin
          blBAS_G21_GST_Closing_Creditors_BalanceA := Int2Money( iG21_ATOInstalment);
          blBAS_G22_GST_Opening_Creditors_BalanceB := Int2Money( iG22_EstimatedNetGST);
          blBAS_G23         := Int2Money( iG23_VariedAmount);
          blBAS_G24         := iG24_ReasonVar;
       end else begin
          blBAS_G21_GST_Closing_Creditors_BalanceA  := 0;
          blBAS_G22_GST_Opening_Creditors_BalanceB  := 0;
          blBAS_G23         := 0;
          blBAS_G24         := 0;
       end;

       blBAS_W1_GST_Adj_Change := Int2Money( iTotalSalary_W1);
       blBAS_W2_GST_Adj_Exempt := Int2Money( iSalaryWithheld_W2);
       blBAS_W3_GST_Adj_Other  := Int2Money( iInvstmntDist_W3);
       blBAS_W4_GST_Cdj_BusUse := Int2Money( iInvoicePymt_W4);

       blBAS_T4          := 0;
       blBAS_PAYG_Instalment_Option := iPAYGInstalmentOptionUsed;
       if blBas_Payg_Instalment_Option = 3 then begin
          blBAS_T6_VAT6     := Int2Money( iT6_VariedAmount);
          blBAS_T4          := iTaxReasonVar_T4;
       end else
          blBAS_T6_VAT6 := 0;

       if blBas_Payg_Instalment_Option = 2 then begin
          blBAS_T1_VAT1_GST_Cdj_PAssets := Int2Money( iTaxInstalmIncome_T1);
          blBAS_T2_VAT2_GST_Cdj_Change := Double2Money( dTaxInstalmRate_T2);
          blBAS_T3_VAT3_GST_Cdj_Other := Double2Money( dTaxVarInstalmRate_T3);

          blBAS_T4          := iTaxReasonVar_T4;
       end else begin
          blBAS_T1_VAT1_GST_Cdj_PAssets := 0;
          blBAS_T2_VAT2_GST_Cdj_Change := 0;
          blBAS_T3_VAT3_GST_Cdj_Other := 0;
       end;

       if blBAS_PAYG_Instalment_Option = 1 then begin
          blBAS_T7_VAT7     := Int2Money( iT7_ATOInstalment);
          blBAS_T8_VAT8     := Int2Money( iT8_EstimatedTax);
          blBAS_T9_VAT9     := Int2Money( iT9_VariedAmount);

          blBAS_T4          := iTaxReasonVar_T4;
       end else begin
          blBAS_T7_VAT7     := 0;
          blBAS_T8_VAT8     := 0;
          blBAS_T9_VAT9     := 0;
       end;


       blBAS_F1_GST_Closing_Debtors_BalanceA := Int2Money( iFBTInstalm_F1);
       blBAS_F2_GST_Opening_Debtors_BalanceB := Int2Money( iFBTTotalPayable_F2 );
       blBAS_F3          := Int2Money( iFBTVariedInstalm_F3);
       blBAS_F4          := iFBTReasonVar_F4;


       blBAS_1C_PT_Last_Months_Income  := Int2Money( iWineEqlPayable_1C);
       blBAS_1E_PT_Assets              := Int2Money( iLuxCarPayable_1E );
       blBAS_1D_PT_Branch_Income       := Int2Money( iWineEqlRefund_1D);
       blBAS_1F_PT_Tax                 := Int2Money( iLuxCarRefund_1F);
       blBAS_1G_PT_Refund_Used         := Int2Money( iSalesTaxCredit_1G);
       blBAS_1H                        := Int2Money( i1H_GSTInstalment);
       blBAS_5B_PT_Ratio               := Int2Money( iCrAdjPrevIncome_5B);
       blBAS_6B_GST_Adj_PrivUse        := Int2Money( iVariationCr_6B);
       blBAS_7_VAT4_GST_Adj_BAssets    := Int2Money( iDeferredInstalm_7);
       blBAS_7C          := Int2Money( iFuelOverClaim_7C);
       blBAS_7D          := Int2Money( iFuelCredit_7D);
       blBAS_T5_VAT5     := Int2Money( iBAST5 );
       // save fuel sheet recs
       blUsing_Fuel_Percent_Method := iIsFuelPercentMethod;
       blFirst_Fuel_Sheet := nil;
       s := TStringList.Create;
       try
         s.CommaText := PRACINI_FuelCreditRates;
         for i := 1 to Fuel.Rows do
         begin
           // see if it has any values to store
           SaveRow := False;
           for j := colMin to colMax do
           begin
             case j of
               colCode, colDesc, colType, colUse:
                 begin
                   if Fuel.Cell[j, i] <> '' then
                   begin
                     SaveRow := True;
                     Break;
                   end;
                 end;
               colLitres, colPercent, colEligible, colRate, colTotal:
                 begin
                   if StrToFloatDef(Fuel.Cell[j, i], 0) <> 0 then
                   begin
                     SaveRow := True;
                     Break;
                   end;
                 end;
             end;
           end;
           if not SaveRow then Continue;
           f := New_Fuel_Sheet_Rec;
           f.fsNext := nil;
           f.fsAccount := Fuel.Cell[colCode, i];
           f.fsFuel_Type := Fuel.Cell[colType, i];
           f.fsFuel_Litres := Double2Percent(StrToFloatDef(Fuel.Cell[colLitres, i], 0));
           f.fsFuel_Use := Fuel.Cell[colUse, i];
           f.fsPercentage := Double2Percent(StrToFloatDef(Fuel.Cell[colPercent, i], 0));
           f.fsFuel_Eligible := Double2Percent(StrToFloatDef(Fuel.Cell[colEligible, i], 0));
           f.fsCredit_Rate := Double2CreditRate(StrToFloatDef(Fuel.Cell[colRate, i], 0));
           if (s.IndexOf(Fuel.Cell[colRate, i]) = -1) and (StrToFloatDef(Fuel.Cell[colRate, i], 0) <> 0) then
             s.Add(Fuel.Cell[colRate, i]);
           if not Assigned(blFirst_Fuel_Sheet) then
             blFirst_Fuel_Sheet := f
           else
             blLast_Fuel_Sheet.fsNext := f;
           blLast_Fuel_Sheet := f;
         end;
       finally
        s.CustomSort(AsFloatSort);
        PRACINI_FuelCreditRates := s.CommaText;
        WritePracticeINI_WithLock;
        s.Free;
       end;
    end;

    //store default value so can use next time
    MyClient.clFields.clBAS_Last_GST_Option := iGSTOptionUsed;
    MyClient.clFields.clBAS_Last_PAYG_Instalment_Option := iPAYGInstalmentOptionUsed;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasInfo.AutoAddIntoBox(box1, box2: integer): boolean;
//If the setup for box1 and box2 is the same return true.
//This tells the calc routine to take the total from one of the boxes and use the
//sign to decide which box it should go into.
var
   i,
   j         : integer;
   Box1Count,
   Box2Count : integer;
   Matched_Already : Array[ Min_Slot..Max_Slot] of Boolean;  //tell if already matched this slot
                                                  //helps with duplicate lines
   MatchFound : boolean;
begin
   result := false;
   Box1Count := 0;
   Box2Count := 0;
   //look thru array and count all slots which apply to each box
   //if difference no this exit
   with MyClient.clFields do begin
      for i := MIN_SLOT to MAX_SLOT do begin
         if clBAS_Field_Number[ i] = box1 then Inc( Box1Count);
         if clBas_Field_Number[ i] = box2 then Inc( Box2Count);
      end;

      if ( Box1Count <> Box2Count) then exit;
      if ( Box1Count = 0) then exit;

      //find box 1 slot, search for a matching box 2 slot
      //keep searching if match found, exit if fails
      FillChar( Matched_Already, SizeOf( Matched_Already), #0);
      for i := MIN_SLOT to MAX_SLOT do begin
         if clBAS_Field_Number[ i] = Box1 then begin
            MatchFound := false;
            for j := MIN_SLOT to MAX_SLOT do begin
               if ( clBAS_Field_Number[ j] = Box2) and ( not Matched_Already[ j]) then begin
                  //compare the BAS Fields for these 2 slots
                  if clBAS_Field_Source[ i] <> clBAS_Field_Source[ j] then exit;
                  if clBAS_Field_Account_Code[ i] <> clBAS_Field_Account_Code[ j] then exit;
                  if clBAS_Field_Balance_Type[ i] <> clBAS_Field_Balance_Type[ j] then exit;
                  if clBAS_Field_Percent[ i] <> clBAS_Field_Percent[ j] then exit;
                  //matched ok
                  Matched_Already[ j] := true;
                  MatchFound := true;
                  //Match found so dont continue in loop
                  Break;
               end;
            end;
            //Box 2 not found
            if not MatchFound then exit;
         end;
      end;
   end;
   result := true;
end;
//------------------------------------------------------------------------------

procedure TBasInfo.SetDates( FromDate : integer; ToDate : integer);
//only business with annual turnover of $20 million + are required to submit a montly
//statement.  below that only quarterly statements are required.
//if monthly basis has been selected then each quarter the income tax and fbt tax
//instalment sections should also be completed.
//this function returns true if these fields should be made visible.

var
   d, diffmth, m, y   : integer;
   startDate          : integer;
   SmallestPeriod     : integer;
   GSTPeriodType      : integer;
   PAYGInstalmentType : integer;
   PAYGWithheldType   : integer;

begin
   if FromDate = 0 then exit;

   isQuarterlyStatement := false;
   isAnnualStatement    := false;

   if SpecialFormType in [ bsH, bsBasZ, bsK, bsIasN] then begin
      IsAnnualStatement := true;
   end
   else begin
      //test to see if this is a quarterly statement
      with MyClient.clFields do begin
         StartDate := DMYTostDate( 1, clGST_Start_Month, DefaultYear, BKDATEEPOCH );

         //Check the smallest period selected, if the is a month we need to compare the
         //from dates to see if it starts in the last month of the quarter
         GSTPeriodType      := 99;
         PAYGInstalmentType := 99;
         PAYGWithheldType   := 99;
         //get the real type out of the objects property
         if ( clGST_Period > 0) then                 GSTPeriodType := clGST_Period;
         if ( clBAS_PAYG_Withheld_Period > 0) then   PAYGWithheldType := clBAS_PAYG_Withheld_Period;
         if ( clBAS_PAYG_Instalment_Period > 0) then PAYGInstalmentType := clBAS_PAYG_Instalment_Period;

         SmallestPeriod := Min( PAYGWithheldType, Min( GSTPeriodType, PAYGInstalmentType));

         if ( SmallestPeriod = gpQuarterly) then begin
            IsQuarterlyStatement := true;
         end
         else begin
            //one period must now be monthly.  Figure out if this is a quarter month
            //calc months between first month specified in clgst_starts and from date.  if mod 3 = 0 then
            //this is a quarter.
            DateDiff( StartDate, FromDate, d, diffmth, y );

            if ( FromDate < StartDate) then
               //need to sub one because begin of current mth to end of prev is 0 mths
               IsQuarterlyStatement := (( diffMth - 1) mod 3 = 0)
            else
               //need to add one because begin of current mth to end is 1 mth
               IsQuarterlyStatement := (( diffMth + 1) mod 3 = 0);
         end;
      end;
   end;

   //set date ranges for different sections of bas form
   If IsQuarterlyStatement then begin
      QuarterlyFromDate := IncDate( ToDate + 1, 0, -3, 0);
      QuarterlyToDate   := ToDate;

      //set the date range for GST calculation
      if ( MyClient.clFields.clGST_Period in [ gpQuarterly, gpNone]) then begin
         GSTFromDate    := QuarterlyFromDate;
         GSTToDate      := QuarterlyToDate;
      end
      else begin
         GSTFromDate    := FromDate;
         GSTToDate      := ToDate;
      end;

      //set the date ranges for PAYG Witholding
      if ( MyClient.clFields.clBAS_PAYG_Withheld_Period  in [ gpQuarterly, gpNone]) then begin
         PAYG_W_FromDate   := QuarterlyFromDate;
         PAYG_W_ToDate     := QuarterlyToDate;
      end else begin
         PAYG_W_FromDate   := FromDate;
         PAYG_W_ToDate     := ToDate;
      end;

      //set the date ranges for PAYG Instalment
      if ( MyClient.clFields.clBAS_PAYG_Instalment_Period  in [ gpQuarterly, gpNone]) then begin
         PAYG_I_FromDate   := QuarterlyFromDate;
         PAYG_I_ToDate     := QuarterlyToDate;
      end else begin
         PAYG_I_FromDate   := FromDate;
         PAYG_I_ToDate     := ToDate;
      end;

      FBT_FromDate      := QuarterlyFromDate;
      FBT_ToDate        := QuarterlyToDate;

      BasFromDate       := QuarterlyFromDate;
      BasToDate         := QuarterlyToDate;
      BasPeriod         := gpQuarterly
   end else if IsAnnualStatement then begin
      //is an annual statement
      GSTFromDate       := FromDate;
      GSTToDate         := ToDate;
      PAYG_W_FromDate   := FromDate;
      PAYG_W_ToDate     := ToDate;
      PAYG_I_FromDate   := FromDate;
      PAYG_I_ToDate     := ToDate;
      FBT_FromDate      := FromDate;
      FBT_ToDate        := ToDate;


      BasFromDate       := FromDate;
      BasToDate         := ToDate;
      BasPeriod         := gpAnnually;

      //calculate the quarterly from date given the monthly from date
      //may not be needed
      QuarterlyFromDate := 0;
      QuarterlyToDate   := 0;
   end else begin
      //calculate the quarterly from date given the monthly from date
      StartDate := DMYTostDate( 1, MyClient.clFields.clGST_Start_Month, DefaultYear, BKDATEEPOCH );
      DateDiff( StartDate, FromDate, d, diffmth, y );
      if ( FromDate < StartDate) and ((diffmth mod 3) <> 0) then
          //need to sub one because begin of current mth to end of prev is 0 mths
          QuarterlyFromDate := IncDate( FromDate, 0, -( (diffMth - 1) mod 3) ,0)
      else
          //need to add one because begin of current mth to end is 1 mth
          QuarterlyFromDate := IncDate( FromDate, 0, -( diffMth mod 3) ,0);
      //add 3 mths to get to quarterly date
      QuarterlyToDate   := IncDate( QuarterlyFromDate, 0, 3, 0) -1;

      //is a monthly statement so determine which quarter we are in
      if ( MyClient.clFields.clGST_Period  in [ gpQuarterly, gpNone]) then begin
         GSTFromDate       := QuarterlyFromDate;
         GSTToDate         := QuarterlyToDate;
      end
      else begin
         GSTFromDate       := FromDate;
         GSTToDate         := ToDate;
      end;

      if ( MyClient.clFields.clBAS_PAYG_Withheld_Period  in [ gpQuarterly, gpNone]) then begin
         PAYG_W_FromDate   := QuarterlyFromDate;
         PAYG_W_ToDate     := QuarterlyToDate;
      end
      else begin
         PAYG_W_FromDate   := FromDate;
         PAYG_W_ToDate     := ToDate;
      end;

      if ( MyClient.clFields.clBAS_PAYG_Instalment_Period  in [ gpQuarterly, gpNone]) then begin
         PAYG_I_FromDate   := QuarterlyFromDate;
         PAYG_I_ToDate     := QuarterlyToDate;
      end
      else begin
         PAYG_I_FromDate   := FromDate;
         PAYG_I_ToDate     := ToDate;
      end;

      FBT_FromDate      := QuarterlyFromDate;
      FBT_ToDate        := QuarterlyToDate;

      BasFromDate       := FromDate;
      BasToDate         := ToDate;
      BasPeriod         := gpMonthly;
   end;

  //Returns are due on the 28th of the next month after the end of the period
  //if quarterly.
  //Assume that ToDate is an EOM date, so add 28 days
  //The except is return which are due in jan.  These have an extra month.
  //NOTE: Annual statements are due 28 Feb the following year
  //      Is setup for monthly GST then amounts are always due 21st of next mth

  DueDate := IncDate(BasToDate, 21, 0, 0);

  if isAnnualStatement then
  begin
    StDateToDMY(BasToDate, d, m, y);
    DueDate := DMYtoStDate(28, 2, y+1, BKDATEEPOCH);
  end
  else if (MyClient.clFields.clGST_Period = gpQuarterly) then
  begin
    if (MyClient.clFields.clBAS_PAYG_Withheld_Period = gpMonthly) then
    begin
      StDateToDMY(DueDate, d, m, y);
      if m in [4, 7, 10, 1] then
        DueDate := IncDate(BasToDate, 28, 0, 0);
    end
    else
    begin
      //if GST is annually then form is due on 28th
      DueDate := IncDate(BasToDate, 28, 0, 0);
      StDateToDMY(DueDate, d, m, y);
      if (m = 1) then
      begin
        m := 2;
        DueDate := DMYtoSTDate(d, m, y, BKDATEEPOCH);
      end;
    end;
  end;

  PaymentDate := DueDate;
end;
//------------------------------------------------------------------------------

end.
