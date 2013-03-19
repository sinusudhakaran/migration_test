unit CalculateAccountTotals;
//------------------------------------------------------------------------------
{
   Title:       Calculate Account Totals

   Description: This unit is used to fill the accumulators for each account in
                the chart.  These figures form them basis of the financial
                reports in banklink.

   Author:      Matthew Hopkins  May 2002

   Remarks:     Much of the code is based on Steve Agnews research

                The following variables are used by the Calculate... routine

                   clGST_Inclusive_Cashflow
                   clReporting_Year_Starts
                   clFRS_Reporting_Period_Type

                   clTemp_FRS_From_Date
                   clTemp_FRS_To_Date
                   clTemp_FRS_Division_To_Use
                   clTemp_FRS_Budget_To_Use
                   clTemp_FRS_Budget_To_Use_Date

                   clTemp_FRS_Account_Totals_Cash_Only
                   clTemp_FRS_Last_Actual_Period_To_Use
                   clTemp_Last_Period_Of_Actual_Data

                A temporary Tag variable was added to the chart record in
                v5.2 to make it easier to manage contra accounts that are
                automatically added and removed.  The tag can take the following
                values

                0 = Do nothing

                1 = Temp GST Contra            set if no contra specified for gst id
                                               this account will be deleted in the remove call
                                               the contra in the gst class will be set back to blank

                2 = Invalid GST Contra         set if invalid contra for gst id
                                               this account will be deleted in the remove call

                3 = Temp Bank Contra           set if no contra specific for account
                                               this account will be deleted in the remove call
                                               the contra in the bank account will be set back to blank
                                               an estimated opening balance will be added for cashflow

                4 = Invalid Bank Contra        set if invalid contra specified
                                               this account will be deleted in the remove call

                5 = Uncoded Account Contra

                6 = Rounding Account Contra

                7 = Retained P&L Account

                8 = Movement from Budget Account   Added so that the cash book movement is automatically
                                                   calculated for budgets

                Chart codes that have a tag <> 0 will be removed in the remove contras routine

}
//------------------------------------------------------------------------------
interface
uses
   Classes, clObj32;

const
  Tag_Temp_GST_Contra     = 1;
  Tag_Invalid_GST_Contra  = 2;
  Tag_Temp_Bank_Contra    = 3;
  Tag_Invalid_Bank_Contra = 4;
  Tag_Uncoded_Contra      = 5;
  Tag_Rounding_Contra     = 6;
  Tag_Retained_PL         = 7;
  Tag_Budget_Movement     = 8;


procedure CalculateAccountTotalsForClient( aClient : TClientObj; AddContras : boolean = true; AccountList: TList = nil; MaxDate: integer = -1; UseMaxDate: Boolean = False; IncludeExchangeGainLoss: Boolean = False; UseLocalAmountAsBase: Boolean = False; ExcludeGainLossFromBudget: Boolean = False);

procedure AddAutoContraCodes( aClient : TClientObj);
procedure RemoveAutoContraCodes( aClient : TClientObj);

procedure FlagAllAccountsForUse( aClient : TClientObj);

procedure CalculateCurrentEarnings( aClient : TClientObj);

procedure EstimateOpeningBalancesForBankAccountContras( aClient : TClientObj);

procedure CalcYearStartEndDates( const aClient : TClientObj;
                                 var This_Year_Starts  : integer;
                                 var This_Year_Ends    : integer;
                                 var Last_Year_Starts  : integer;
                                 var Last_Year_Ends    : integer);

//******************************************************************************
implementation
uses
  AccountInfoObj,
  baObj32,
  bkchio,
  BKCONST,
  bkDateUtils,
  BKDEFS,
  budObj32,
  chList32,
  GlConst,
  GSTCalc32,
  MoneyDef,
  PeriodUtils,
  signUtils,
  sysUtils,
  stDate,
  ForexHelpers,
  GenUtils,
  glObj32;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddTo( var TheSum : Money; AnAmount : Money );
begin
  if AnAmount = Unknown then
    TheSum := UnKnown
  else
    if TheSum <> Unknown then
      TheSum := TheSum + AnAmount;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DivisionInReport(const aClient : TClientObj; aAccountRec: TAccount_Rec): Boolean;
//******************************************************************************
//* Length(DivisionArray) = 0 : All divisions are selected
//* DivisionArray[0] = True   : All divisions with no division assigned to the
//*                             current chart code (i.e 'No Division Allocated')
//*
//* Division = 0              : Allow any division in the report
//* Division > 0              : Only allow a specific division in the report
//*
//* Gets confusing because all divisions can be printed in a single report
//* or split into separate reports.
//******************************************************************************
var
  i: integer;
  Division: integer;
  DivisionArray: DynamicBooleanArray;

  function NoDivisionAllocated: Boolean;
  var
    j: integer;
  begin
    Result := True;
    for j := 1 to Length(aAccountRec.chPrint_In_Division) do
      if aAccountRec.chPrint_In_Division[j] then begin
        Result := False;
        Break;
      end;
  end;

begin
  Result := False;
  Division := aClient.clFields.clTemp_FRS_Division_To_Use;
  DivisionArray := aClient.clFields.clTemp_FRS_Divisions;

  //All divisions
  if (Length(DivisionArray) = 0) then begin
    //Split by division
    if (aClient.clFields.clTemp_FRS_Split_By_Division) then begin
      if (Division = 0) then begin
        //Return true if no division allocated to code
        Result := NoDivisionAllocated;
      end else
        //Return true if division allocated to code
        Result := aAccountRec.chPrint_In_Division[Division];
    end else begin
      //All divisions
      if (Division = 0) then
        Result := True
      //Single division
      else if aAccountRec.chPrint_In_Division[Division] then
        Result := True;
    end;
  //Selected division(s)
  end else begin
    //Split by division
    if (aClient.clFields.clTemp_FRS_Split_By_Division) then begin
      if (Division = 0) then begin
        //'No division allocated' selected
        if DivisionArray[0] then
          //Return true if no division allocated to code
          Result := NoDivisionAllocated;
      end else
        //Return true if division is selected and division allocated to code
        Result := DivisionArray[Division] and aAccountRec.chPrint_In_Division[Division];
    end else begin
      //All selected divisions in one report
      for i := 0 to Length(DivisionArray) - 1 do begin
        if (i = 0) and DivisionArray[i] then
          //Return true 'No division allocated' selected and no division allocated to code
          Result := NoDivisionAllocated
        else if DivisionArray[i] and aAccountRec.chPrint_In_Division[i] then begin
          //Return true if division selected and division allocated to code
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CalcYearStartEndDates( const aClient : TClientObj;
                                 var This_Year_Starts  : integer;
                                 var This_Year_Ends    : integer;
                                 var Last_Year_Starts  : integer;
                                 var Last_Year_Ends    : integer);
var
  d, m, y : integer;
begin
  //set year start and end dates
  if aClient.clFields.clFRS_Reporting_Period_Type = frpCustom then begin
    This_Year_Starts := aClient.clFields.clTemp_FRS_From_Date;
    This_Year_Ends   := aClient.clFields.clTemp_FRS_To_Date;

    //Need to check that we dont create invalid dates
    StDateToDmy( This_Year_Starts, d, m, y);
    Dec( y);
    if d > DaysInMonth( m, y, BKDATEEPOCH) then
      d := DaysInMonth( m, y, BKDATEEPOCH);
    Last_Year_Starts := DmyToStDate( d, m, y, BKDATEEPOCH);

    StDateToDmy( This_Year_Ends, d, m, y);
    Dec( y);
    if d > DaysInMonth( m, y, BKDATEEPOCH) then
      d := DaysInMonth( m, y, BKDATEEPOCH);
    Last_Year_Ends := DmyToStDate( d, m, y, BKDATEEPOCH);

    Assert( This_Year_Starts <= This_Year_Ends, 'This_Year_Starts (' +
                                                bkDate2Str(This_Year_Starts ) +
                                                ' ) <= This_Year_Ends (' +
                                                bkDate2STr(This_Year_Ends) + ')');
  end
  else begin
    //all of the other report periods are based on this financial year
    This_Year_Starts := aClient.clFields.clReporting_Year_Starts;
    This_Year_Ends   := bkDateUtils.GetYearEndDate( This_Year_Starts);
    Last_Year_Starts := bkDateUtils.GetPrevYearStartDate( This_Year_Starts);
    Last_Year_Ends   := This_Year_Starts - 1;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CalculateAccountTotalsForClient( aClient : TClientObj; AddContras : boolean = true; AccountList: TList = nil; MaxDate: integer = -1; UseMaxDate: Boolean = False; IncludeExchangeGainLoss: Boolean = False; UseLocalAmountAsBase: Boolean = False; ExcludeGainLossFromBudget: Boolean = False);
//note add contras will only be false for when generating budget figures
type
   TWhichYear = ( wyThisYear, wyLastYear);
{
   Assumes that all GST classes have a contra code and that all bank accounts
   have a contra code
}
var
   This_Year_Starts         : integer;
   This_Year_Ends           : integer;
   Last_Year_Starts         : integer;
   Last_Year_Ends           : integer;

   Uncoded_DR_Posting_Account : pAccount_Rec;
   Uncoded_CR_Posting_Account : pAccount_Rec;
   GST_Posting_Accounts       : Array[ 1..MAX_GST_CLASS] of pAccount_Rec;
   Budget_Movement_Account    : pAccount_Rec;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure CheckGSTFields( var P : pTransaction_Rec );
   //makes sure that we don't have any stray gst classes
   var
     dThis : pDissection_Rec;
   begin
     with P^ do
     begin
       if not txGST_Class in [ 1..MAX_GST_CLASS ] then
       begin
         txGST_Class := 0;
         txGST_Amount := 0;
       end;

       dThis := txFirst_Dissection;
       while dThis <> nil do with dThis^ do
         begin
           if not dsGST_Class in [ 1..MAX_GST_CLASS ] then
           begin
             dsGST_Class := 0;
             dsGST_Amount := 0;
           end;
           dThis := dsNext;
         end;
     end;
   end;   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure AddOpeningBalanceItem( WhichYear  : TWhichYear;
                                    Code       : string;
                                    Amount     : Money;
                                    Amount_Base: Money;
                                    GST_Class  : Byte;
                                    GST_Amount : Money );
   var
     P : pAccount_Rec;
     G : pAccount_Rec;
     PostToGSTContra : boolean;
   begin
     with AClient, AClient.clFields do begin
       P := clChart.FindCode( Code );
       if Assigned( P ) then with P^ do begin
          //check that this is an 'atCashOnHand' account type if only doing cash
          if ( clTemp_FRS_Account_Totals_Cash_Only and (not(p^.chAccount_Type = atBankAccount))) then
             Exit;
          //check that this is in the correct division
          if DivisionInReport(AClient, P^) then begin
             Inc( chHits );
             PostToGSTContra := ( not clGST_Inclusive_Cashflow) and
                                ( GST_Class in [ 1..MAX_GST_CLASS ] ) and
                                ( GST_Amount <> 0 ) and AddContras;
             G := nil;
             if PostToGSTContra then begin
                G := GST_Posting_Accounts[ GST_Class];
                if Assigned( G) then
                   Inc( G^.chHits);
             end;

             if ( WhichYear = wyThisYear ) then begin
               if clGST_Inclusive_Cashflow then begin
                 AddTo( chTemp_Amount.This_Year[ 0 ], Amount );
                 AddTo( chTemp_Base_Amount.This_Year[ 0 ], Amount_Base );
               end else begin
                 //post net and gst amounts separately
                 AddTo( chTemp_Amount.This_Year[ 0 ], Amount - GST_Amount );
                 AddTo( chTemp_Base_Amount.This_Year[ 0 ], Amount_Base - GST_Amount);
                 if PostToGSTContra and ( Assigned( G)) then begin
                    AddTo( G^.chTemp_Amount.This_Year[0], GST_Amount);
                    AddTo( G^.chTemp_Base_Amount.This_Year[0], GST_Amount);
                 end;
               end;
             end
             else begin //last year
               if clGST_Inclusive_Cashflow then begin
                 AddTo( chTemp_Amount.Last_Year[ 0 ], Amount );
                 AddTo( chTemp_Base_Amount.Last_Year[ 0 ], Amount_Base);
               end else begin
                 //post net and gst amounts separately
                 AddTo( chTemp_Amount.Last_Year[ 0 ], Amount - GST_Amount );
                 AddTo( chTemp_Base_Amount.Last_Year[ 0 ], Amount_Base - GST_Amount);
                 if PostToGSTContra and ( Assigned( G)) then begin
                    AddTo( G^.chTemp_Amount.This_Year[0], GST_Amount);
                    AddTo( G^.chTemp_Base_Amount.This_Year[0], GST_Amount);
                 end;
               end;
             end;
          end;
       end;
     end; //with aClient, clFields...
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure AddItem( WhichYear : TWhichYear; Period : Byte;  Code : string;
                      Amount : Money;  GST_Class : Byte; GST_Amount : Money;
                      Quantity : Money );

   var
     P : pAccount_Rec;
     G : pAccount_Rec;
     PostToGSTContra : boolean;
   begin
     with AClient, AClient.clFields do begin
       P := clChart.FindCode( Code );
       if ( P = nil ) then begin { The entry is uncoded }
          if ( Amount < 0 ) then { Credit or Deposit }
            P := Uncoded_CR_Posting_Account
          else
            P := Uncoded_DR_Posting_Account;
       end;

       if P = nil then exit;

       with P^ do begin
         if DivisionInReport(AClient, P^) then begin
         
           Inc( chHits );

           PostToGSTContra := ( not clGST_Inclusive_Cashflow) and
                              ( GST_Class in [ 1..MAX_GST_CLASS ] ) and
                              ( GST_Amount <> 0 ) and AddContras;
           G := nil;
           if PostToGSTContra then begin
              G := GST_Posting_Accounts[ GST_Class];
              if Assigned( G) then
                 Inc( G^.chHits);
           end;

           if ( WhichYear = wyThisYear ) then begin
             AddTo( chTemp_Quantity.This_Year[ Period ], Quantity );
             if clGST_Inclusive_Cashflow then begin
               AddTo( chTotal, Amount );
               AddTo( chTemp_Amount.This_Year[ Period ], Amount );
             end
             else begin
               AddTo( chTotal, Amount - GST_Amount );
               AddTo( chTemp_Amount.This_Year[ Period ], Amount - GST_Amount );
               if PostToGSTContra and Assigned( G) then begin
                   AddTo( G^.chTemp_Amount.This_Year[ Period ], GST_Amount );
                   AddTo( G^.chTemp_Base_Amount.This_Year[ Period ], GST_Amount );
               end;
             end;
             //Set base amount
             P^.chTemp_Base_Amount.This_Year[ Period ] := chTemp_Amount.This_Year[ Period ];
           end
           else begin { Last Year }
             AddTo( chTemp_Quantity.Last_Year[ Period ], Quantity );
             if clGST_Inclusive_Cashflow then begin
               AddTo( chTemp_Amount.Last_Year[ Period ], Amount );
             end
             else begin
               AddTo( chTemp_Amount.Last_Year[ Period ], Amount - GST_Amount );
               if PostToGSTContra and Assigned( G) then begin
                  AddTo( G^.chTemp_Amount.Last_Year[ Period ], GST_Amount );
                  AddTo( G^.chTemp_Base_Amount.Last_Year[ Period ], GST_Amount );
               end;
             end;
             //Set base amount
             chTemp_Base_Amount.Last_Year[ Period ] := chTemp_Amount.Last_Year[ Period ];
           end;

         end;
       end; //with p^
     end;
   end;
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   procedure AddOpeningBalances;
   //if the calculation should be cash only then we only need the opening balances
   //for the atCashOnHand type accounts
   var
      ba         : TBank_Account;
      i          : integer;
      t          : integer;
      pT         : pTransaction_Rec;
      pD         : pDissection_Rec;
      WhichYear  : TWhichYear;
      ExchangeRate: Double;
      OpenBalAmt: Money;
      TestStr: string;

      Index, PeriodNo: integer;
      GainLossEntry: TExchange_Gain_Loss;
      Contra: pAccount_Rec;
   begin
      with aClient.clBank_Account_List do
         for i := 0 to Pred( ItemCount) do begin
            Ba := Bank_Account_At(i);
            if ( Ba.baFields.baAccount_Type = btOpeningBalances) then begin
               for t := 0 to Pred(ba.baTransaction_List.ItemCount) do begin
                  pT := ba.baTransaction_List.Transaction_At(t);
                  if ( pT^.txDate_Effective = This_Year_Starts) or ( pT^.txDate_Effective = Last_Year_Starts) then begin
                     if ( pT^.txDate_Effective = This_Year_Starts) then
                        WhichYear := wyThisYear
                     else
                        WhichYear := wyLastYear;

                     CheckGSTFields( pT);

                     if pT^.txFirst_Dissection = nil then begin
                        //Just add
                        if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                        or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pt^.txJob_Code) then
                           AddOpeningBalanceItem( WhichYear, pT.txAccount, pT^.txAmount, pT^.txTemp_Base_Amount, pT.txGST_Class, pT.txGST_Amount);
                     end else begin
                        //iterate disections
                        pD := pT.txFirst_Dissection;
                        while (pD <> nil) do begin
                           if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                           or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pd.dsJob_Code) then begin
                              OpenBalAmt := pD^.dsAmount;
                              if pD^.dsOpening_Balance_Currency <> '' then
                                OpenBalAmt := pD^.dsForeign_Currency_Amount
                              else begin
                                //If an opening balance has not been entered as a forex amount then
                                //it needs to be converted to get the forex amount.
                                ba.baFields.baCurrency_Code := aClient.GetForexISOCodeForContra(pD^.dsAccount);
                                if ba.baFields.baCurrency_Code <> '' then begin
                                  ExchangeRate := ba.Default_Forex_Conversion_Rate(pT^.txDate_Effective);
                                  OpenBalAmt := Double2Money(Money2Double(pD^.dsAmount) * ExchangeRate);
                                  TestStr := '';
                                end;
                              end;
                              AddOpeningBalanceItem( WhichYear, pD^.dsAccount, OpenBalAmt, pD^.dsAmount, pD^.dsGST_Class, pD^.dsGST_Amount);
                              ba.baFields.baCurrency_Code := aClient.clExtra.ceLocal_Currency_Code;
                           end;
                           pD := pD^.dsNext;
                        end;
                     end;
                     //no need to record contras in this case because they are
                     //not specified for an opening balance account
                  end;
               end; //for t
            end;
         end;
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure AddMovement;
   var
      ba         : TBank_Account;
      Contra     : pAccount_Rec;
      i          : integer;
      t          : integer;
      pT         : pTransaction_Rec;
      pD         : pDissection_Rec;
      WhichYear  : TWhichYear;
      PeriodNo   : integer;
      SkipAccount : boolean;
      IsForex     : boolean;
      GainLossEntry: TExchange_Gain_Loss;
      Index: Integer;
   begin
      with aClient.clBank_Account_List do
         for i := 0 to Pred( ItemCount) do begin
            Ba := Bank_Account_At(i);
            //make sure we have the correct account type
            SkipAccount := ( Ba.baFields.baAccount_Type = btOpeningBalances) or
                           ( Ba.baFields.baAccount_Type = btGSTJournals) or
                           ( aClient.clFields.clTemp_FRS_Account_Totals_Cash_Only and
                              (
                                not ( Ba.baFields.baAccount_Type in BKCONST.CashAccountsSet)
                              )
                            ) or
                           (not Ba.baFields.baTemp_Include_In_Report);
            // Make sure we want to include this bank account, but always include year end adjustments
            // For ledger, we always want an opening balance based on ALL accounts so no need for this code
{            if Assigned(AccountList) and (Ba.baFields.baAccount_Type <> btYearEndAdjustments) then
            begin
              IncludeBank := False;
              for j := 0 to Pred(AccountList.Count) do
              begin
                if aClient.clBank_Account_List.Bank_Account_At(Integer(AccountList[j])).baFields.baBank_Account_Number =
                       Ba.baFields.baBank_Account_Number then
                begin
                  IncludeBank := True;
                  Break;
                end;
              end;
              if not IncludeBank then
                SkipAccount := True;
            end;}

            if not( SkipAccount) then begin
               if AddContras then
                 Contra := aClient.clChart.FindCode( ba.baFields.baContra_Account_Code)
               else
                 Contra := nil;

               IsForex := BA.IsAForexAccount;

               for t := 0 to Pred(ba.baTransaction_List.ItemCount) do begin
                  pT := ba.baTransaction_List.Transaction_At(t);
                  if ( pT^.txDate_Effective >= Last_Year_Starts) and ( pT^.txDate_Effective <= This_Year_Ends) and ((pT^.txDate_Effective <= MaxDate) or not UseMaxDate) then begin
                     if CompareDates( pT^.txDate_Effective, This_Year_Starts, This_Year_Ends) = Within then
                        WhichYear := wyThisYear
                     else
                        WhichYear := wyLastYear;

                     CheckGSTFields( pT);

                     //determine period for report, make sure that is in range
                     if WhichYear = wyThisYear then begin
                        PeriodNo := GetPeriodNo( pT^.txDate_Effective, aClient.clFields.clTemp_Period_Details_This_Year);

                        if (PeriodNo <> -1)
                        and Assigned(Contra) then begin
                           if (pT^.txFirst_Dissection = nil) then begin
                              if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                              or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pt^.txJob_Code) then
                              begin
                                  AddTo(Contra^.chTemp_Amount.This_Year[ PeriodNo], -pt^.txAmount);

                                  if IsForex and UseLocalAmountAsBase then
                                  begin
                                    AddTo(Contra^.chTemp_Base_Amount.This_Year[ PeriodNo], -pt^.Local_Amount);
                                  end
                                  else
                                  begin
                                    AddTo(Contra^.chTemp_Base_Amount.This_Year[ PeriodNo], -pt^.txTemp_Base_Amount);
                                  end;
                              end;
                            end else begin
                              pD := pT^.txFirst_Dissection;
                              while ( pD <> nil) do begin
                                 if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                                 or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pd.dsJob_Code) then
                                 begin
                                    AddTo(Contra^.chTemp_Amount.This_Year[ PeriodNo], -pD^.dsAmount);

                                    if IsForex and UseLocalAmountAsBase then
                                    begin
                                      AddTo(Contra^.chTemp_Base_Amount.This_Year[ PeriodNo], -pD^.Local_Amount);
                                    end
                                    else
                                    begin
                                      AddTo(Contra^.chTemp_Base_Amount.This_Year[ PeriodNo], -pD^.dsTemp_Base_Amount);
                                    end;
                                 end;
                                 pD := pD^.dsNext;
                              end;
                            end;
                        end;
                     end else begin
                        PeriodNo := GetPeriodNo( pT^.txDate_Effective, aClient.clFields.clTemp_Period_Details_Last_Year);
                        if (PeriodNo <> -1)
                        and Assigned(Contra) then begin
                           if (pT^.txFirst_Dissection = nil) then begin
                              if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                              or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pt^.txJob_Code) then
                              begin
                                  AddTo(Contra^.chTemp_Amount.Last_Year[ PeriodNo], -pt^.txAmount);

                                  if IsForex and UseLocalAmountAsBase then
                                  begin
                                    AddTo(Contra^.chTemp_Base_Amount.Last_Year[ PeriodNo], -pt^.Local_Amount);
                                  end
                                  else
                                  begin
                                    AddTo(Contra^.chTemp_Base_Amount.Last_Year[ PeriodNo], -pt^.txTemp_Base_Amount);
                                  end;
                              end;
                            end else begin
                              pD := pT^.txFirst_Dissection;
                              while ( pD <> nil) do begin
                                 if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                                 or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pd.dsJob_Code) then
                                 begin
                                   AddTo(Contra^.chTemp_Amount.Last_Year[ PeriodNo], -pD^.dsAmount);

                                   if IsForex and UseLocalAmountAsBase then
                                   begin
                                     AddTo(Contra^.chTemp_Base_Amount.Last_Year[ PeriodNo], -pD^.Local_Amount);
                                   end
                                   else
                                   begin
                                     AddTo(Contra^.chTemp_Base_Amount.Last_Year[ PeriodNo], -pD^.dsTemp_Base_Amount);
                                   end;
                                 end;
                                 pD := pD^.dsNext;
                              end;
                            end;
                        end;
                     end;

                     if (PeriodNo <> -1) then begin
                       //valid period found


                       if (pT^.txFirst_Dissection = nil) then begin
                           if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                           or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pt^.txJob_Code) then begin
                              if IsForex then
                              begin
                                if UseLocalAmountAsBase then
                                begin
                                  AddItem( WhichYear, PeriodNo, pT^.txAccount, pt^.Local_Amount, pt^.txGST_Class, pT^.txGST_Amount, pT^.txQuantity);
                                end
                                else
                                begin
                                  AddItem( WhichYear, PeriodNo, pT^.txAccount, pt^.txTemp_base_Amount, pt^.txGST_Class, pT^.txGST_Amount, pT^.txQuantity);
                                end;
                              end
                              else
                              begin
                                AddItem( WhichYear, PeriodNo, pT^.txAccount, pt^.txAmount, pt^.txGST_Class, pT^.txGST_Amount, pT^.txQuantity);
                              end;
                           end;
                       end else begin
                          pD := pT^.txFirst_Dissection;
                          while ( pD <> nil) do begin
                             if (aclient.clFields.clTemp_FRS_Job_To_Use = '')
                             or SameText(aclient.clFields.clTemp_FRS_Job_To_Use, pd.dsJob_Code) then begin
                                if IsForex then
                                begin
                                  if UseLocalAmountAsBase then
                                  begin
                                    AddItem(WhichYear, PeriodNo, pD^.dsAccount, pD^.Local_Amount, pD^.dsGST_Class, pD^.dsGST_Amount, pD^.dsQuantity);
                                  end
                                  else
                                  begin
                                    AddItem(WhichYear, PeriodNo, pD^.dsAccount, pD^.dsTemp_Base_Amount, pD^.dsGST_Class, pD^.dsGST_Amount, pD^.dsQuantity);
                                  end;
                                end
                                else
                                begin
                                  AddItem(WhichYear, PeriodNo, pD^.dsAccount, pD^.dsAmount, pD^.dsGST_Class, pD^.dsGST_Amount, pD^.dsQuantity);
                                end;
                             end;
                             pD := pD^.dsNext;
                          end;
                       end;
                     end;
                  end;
               end; //for t

               //Add the gain/loss amounts
               if IncludeExchangeGainLoss then
               begin
                 for Index := 0 to BA.baExchange_Gain_Loss_List.ItemCount - 1 do
                 begin
                   GainLossEntry := BA.baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(Index);

                   if (GainLossEntry.glFields.glDate >= Last_Year_Starts) and (GainLossEntry.glFields.glDate <= This_Year_Ends) and ((GainLossEntry.glFields.glDate <= MaxDate) or not UseMaxDate) then
                   begin
                     if CompareDates(GainLossEntry.glFields.glDate, This_Year_Starts, This_Year_Ends) = Within then
                     begin
                       WhichYear := wyThisYear
                     end
                     else
                     begin
                       WhichYear := wyLastYear;
                     end;

                     if WhichYear = wyThisYear then
                     begin
                       PeriodNo := GetPeriodNo(GainLossEntry.glFields.glDate, aClient.clFields.clTemp_Period_Details_This_Year);

                       if (PeriodNo <> -1) then
                       begin
                         if Assigned(Contra) then
                         begin
                           AddTo(Contra^.chTemp_Base_Amount.This_Year[PeriodNo], -GainLossEntry.glFields.glAmount);
                         end;

                         AddItem(WhichYear, PeriodNo, GainLossEntry.glFields.glAccount, GainLossEntry.glFields.glAmount, 0, 0, 0);
                       end;
                     end
                     else
                     begin
                       PeriodNo := GetPeriodNo(GainLossEntry.glFields.glDate, aClient.clFields.clTemp_Period_Details_Last_Year);

                       if (PeriodNo <> -1) then
                       begin
                         if Assigned(Contra) then
                         begin
                           AddTo(Contra^.chTemp_Base_Amount.Last_Year[PeriodNo], -GainLossEntry.glFields.glAmount);
                         end;

                         AddItem(WhichYear, PeriodNo, GainLossEntry.glFields.glAccount, GainLossEntry.glFields.glAmount, 0, 0, 0);
                       end;
                     end;
                   end;
                 end;
               end;
            end;
         end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure AddBudgetFigures;
   var
      Budget   : TBudget;
      Detail   : pBudget_Detail_Rec;
      b, i     : integer;
      PeriodNo : integer;
      DestPeriod : integer;

      Budget_Period_Type : byte;

      Budget_Period_End_Dates : array of integer;
      PeriodEnds                : integer;
      Day,Month,Year            : integer;
      MaxPeriods                : integer;
      pAcct                     : pAccount_Rec;

      NetAmount                 : Money;
      GSTAmount                 : Money;
      RateNo                    : integer;
      GSTRate                   : double;
      G                         : pAccount_Rec;
    BudgetQuantity: Money;
    BudgetUnitPrice: Money;

   begin
      if aClient.clFields.clTemp_FRS_Budget_To_Use = '' then
         Exit;

      //find the budget in the list
      //must match name and start date in case of duplicate names
      Budget := nil;
      for i := 0 to Pred(aClient.clBudget_List.ItemCount) do
      begin
        Budget := aClient.clBudget_List.Budget_At(i);
        if (Budget.buFields.buName = aClient.clFields.clTemp_FRS_Budget_To_Use) and
           (Budget.buFields.buStart_Date = aClient.clFields.clTemp_FRS_Budget_To_Use_Date) then
           Break
        else
          Budget := nil;
      end;
      if not Assigned( Budget) then exit;

      with aClient, Budget do begin
         Budget_Period_Type := frpMonthly; //need to change this if change budgets

         if Budget.buFields.buStart_Date = 0 then exit;

         //there must be at least the same number of periods in the budget as
         //are in the report.  Ie can't produce a weekly report from a monthly
         //budget
         if pdMaximumNoOfPeriods[ Budget_Period_Type] < pdMaximumNoOfPeriods[ clFields.clFRS_Reporting_Period_Type] then
            Exit;

         //This is a valid budget to use so need to set up the periods for the
         //budget. We current assume ignore the budget start date and assume that
         //the budget start date is the same as the reporting year start date selected.
         //The reason for this is to avoid having to filter the budget pick list.
         //Another valid reason is that there is no reason that you cannot compare
         //this years figures to last years budget.  In 99% of cases the start
         //month for the budget will be the same as the start month for the report

         MaxPeriods := pdMaximumNoOfPeriods[ Budget_Period_Type];
         Setlength( Budget_Period_End_Dates, MaxPeriods + 1); //add 0th position for balances
         try
            case Budget_Period_Type of
               frpMonthly : {, frp2Monthly, frpQuarterly, frp6Monthly,frpYearly}
               begin
                  PeriodEnds :=  aClient.clFields.clReporting_Year_Starts - 1;
                  for PeriodNo := 0 to MaxPeriods do begin
                     Budget_Period_End_Dates[ PeriodNo] := PeriodEnds;
                     //find next date
                     StDatetoDMY( PeriodEnds, Day, Month, Year ) ;
                     IncMY( Month, Year, IncBy[ Budget_Period_Type ] ) ;
                     Day        := DaysInMonth( Month, Year, Epoch ) ;
                     PeriodEnds := DMYtoStDate( Day, Month, Year, Epoch ) ;
                  end ;
               end;

               //Weekly types are not support yet
            end;

            //have end dates
            with Budget.buDetail do begin
               for b:= 0 to Pred( ItemCount) do begin
                  Detail := Budget_Detail_At( b);
                  pAcct  := aClient.clChart.FindCode( Detail.bdAccount_Code);
                  if Assigned( pAcct) then begin
                     //cash on hand report group accounts are ignore from the
                     //budgeted figures.  Movement should only come from
                     //non-cash on hand accounts
                     //check that is in correct division
                     if DivisionInReport(AClient, pAcct^)
                     and ( pAcct^.chAccount_Type <> atBankAccount)  then
                     begin
                       if ExcludeGainLossFromBudget then
                       begin
                         if aClient.clBank_Account_List.IsExchangeGainLossCode(pAcct.chAccount_Code) then
                         begin
                           Continue;
                         end;
                       end;
                                        
                        //add the budgeted figure for each period into the chart accumulators
                        Assert( MaxPeriods < Length( Detail.bdBudget));

                        for PeriodNo := 1 to MaxPeriods do
                        begin//cycle through each period in the budget
                          if UseMaxDate then
                          begin
                            if (Budget_Period_End_Dates[PeriodNo] > MaxDate) then
                              Continue;
                          end;

                           DestPeriod := GetPeriodNo( Budget_Period_End_Dates[ PeriodNo], aClient.clFields.clTemp_Period_Details_This_Year);
                           if DestPeriod <> -1 then
                           begin
                              //Budgeted figures are always GST EXCLUSIVE so need to add GST
                              NetAmount  := Detail.bdBudget[ PeriodNo] * 100;
                              if ExpectedSign( pAcct^.chAccount_Type) = Credit then
                                 NetAmount := -NetAmount;

                              //Budget figures are exclusive, calculate gst amount
                              GSTAmount  := 0;
                              RateNo     := WhichGSTRateApplies( aClient, Budget_Period_End_Dates[ PeriodNo]);
                              If RateNo > 0 then
                              begin
                                 If ( pAcct^.chGST_Class in [ 1..MAX_GST_CLASS ] ) AND ( clFields.clGST_Rates[ pAcct^.chGST_Class, RateNo ] = 1000000 ) then begin
                                    //Special Case - ALL GST
                                    GSTAmount := NetAmount;
                                 end
                                 else
                                 begin
                                    If ( pAcct^.chGST_Class in [ 1..MAX_GST_CLASS ] ) then
                                       GSTRate  := clFields.clGST_Rates[ pAcct^.chGST_Class, RateNo ] / 1000000.0
                                    else
                                       GSTRate := 0.0;
                                    GSTAmount  := Round( NetAmount * GSTRate );
                                 end;
                              end;

                              //add gst amount to appropriate section of report
                              if clFields.clGST_Inclusive_Cashflow then begin
                                 AddTo( pAcct^.chTemp_Amount.Budget[ DestPeriod], NetAmount + GSTAmount);
                                 AddTo( pAcct^.chTemp_Base_Amount.Budget[ DestPeriod], NetAmount + GSTAmount);
                              end
                              else begin
                                 AddTo( pAcct^.chTemp_Amount.Budget[ DestPeriod], NetAmount);
                                 AddTo( pAcct^.chTemp_Base_Amount.Budget[ DestPeriod], NetAmount);
                                 //post gst component to the GST contra
                                 if pAcct^.chGST_Class in [ 1..MAX_GST_CLASS] then begin
                                   G := GST_Posting_Accounts[ pAcct^.chGST_Class];
                                   if Assigned( G) and AddContras then begin
                                      Inc( G^.chHits);
                                      AddTo( G^.chTemp_Amount.Budget[ DestPeriod], GSTAmount);
                                      AddTo( G^.chTemp_Base_Amount.Budget[ DestPeriod], GSTAmount);
                                   end;
                                 end;
                              end;

                              //Add Budget Quantities and Unit Prices
                              BudgetQuantity := Detail.bdQty_Budget[PeriodNo];
                              BudgetUnitPrice :=  Detail.bdEach_Budget[PeriodNo] / 100;
                              if ExpectedSign( pAcct^.chAccount_Type) = Credit then
                              begin
                                BudgetQuantity := -BudgetQuantity;
                                BudgetUnitPrice := -BudgetUnitPrice;
                              end;

                              AddTo(PAcct^.chTemp_Quantity.Budget[ DestPeriod], BudgetQuantity);
                              AddTo(Pacct^.chTemp_Amount.Budget_Unit_Price[DestPeriod], BudgetUnitPrice);
                              AddTo(Pacct^.chTemp_Base_Amount.Budget_Unit_Price[DestPeriod], BudgetUnitPrice);

                              //add contra amount to the budgeted movement account
                              if Assigned( Budget_Movement_Account) then begin
                                AddTo( Budget_Movement_Account^.chTemp_Amount.Budget[ DestPeriod], -( NetAmount + GSTAmount));
                                AddTo( Budget_Movement_Account^.chTemp_Base_Amount.Budget[ DestPeriod], -( NetAmount + GSTAmount));
                              end;
                           end;
                        end;
                     end;
                  end;  //if Assigned(...
               end;
            end;
         finally
            SetLength( Budget_Period_End_Dates, 0);
         end;
      end;
   end;

var
   pAcct         : pAccount_Rec;
   MaxPeriods    : integer;
   i             : integer;
begin
   if aClient.clFields.clReporting_Year_Starts = 0 then exit;

   //set year start and end dates
   CalcYearStartEndDates( aClient, This_Year_Starts, This_Year_Ends, Last_Year_Starts, Last_Year_Ends);

   //load period information, this will tell us how many periods are required
   //in the chart to store the totals

   with aClient.clFields do begin
      clTemp_Periods_This_Year := PeriodUtils.LoadPeriodDetailsIntoArray( aClient,
                                         This_Year_Starts,
                                         This_Year_Ends,
                                         clTemp_FRS_Account_Totals_Cash_Only,
                                         clFRS_Reporting_Period_Type,
                                         clTemp_Period_Details_This_Year);

      clTemp_Periods_Last_Year := PeriodUtils.LoadPeriodDetailsIntoArray( aClient,
                                         Last_Year_Starts,
                                         Last_Year_Ends,
                                         clTemp_FRS_Account_Totals_Cash_Only,
                                         clFRS_Reporting_Period_Type,
                                         clTemp_Period_Details_Last_Year);

      //sort out the max number of periods required, this may be different
      //due to the number of weeks data is required for
      if clTemp_Periods_This_Year > clTemp_Periods_Last_Year then
         MaxPeriods := clTemp_Periods_This_Year
      else
         MaxPeriods := clTemp_Periods_Last_Year;
   end;

   //set the number of periods needed
   aClient.clChart.AccumulatorPeriods := 0; //makes sure that accumulators are empty
   aClient.clChart.AccumulatorPeriods := MaxPeriods + 1; //add 0th element for balances
   with aClient.clChart do begin
     //clear accumulators
     for i := 0 to Pred( ItemCount) do begin
        with Account_At(i)^ do begin
          chTotal     := 0;
          chHits      := 0;
          MoneyDef.DBR_ClearValues( chTemp_Amount );
          MoneyDef.DBR_ClearValues( chTemp_Quantity );
        end;
     end;
   end;
   //get the gst contra accounts, load into structure for easier access
   for i := 1 to MAX_GST_CLASS do begin
      if aClient.clFields.clGST_Account_Codes[i] <> '' then
         GST_Posting_Accounts[i] := aClient.clChart.FindCode( aClient.clFields.clGST_Account_Codes[i])
      else
         GST_Posting_Accounts[i] := nil;
   end;

   //get the uncoded accounts and budget movement account
   with aClient.clChart do begin
      Uncoded_DR_Posting_Account := nil;
      Uncoded_CR_Posting_Account := nil;
      Budget_Movement_Account    := nil;

      for i := 0 to Pred( ItemCount) do begin
         pAcct := Account_At(i);
         if pAcct^.chAccount_Type = atUncodedDr then
            Uncoded_DR_Posting_Account := pAcct;

         if pAcct^.chAccount_Type = atUncodedCr then
            Uncoded_CR_Posting_Account := pAcct;

         if pAcct^.chTemp_Calc_Totals_Tag = Tag_Budget_Movement then
            Budget_Movement_Account := pAcct;
      end;
   end;

   //add opening balance figures into period 0
   AddOpeningBalances;

   //add actual movement figures for this year and last year into period 1..n
   AddMovement;

   //add budget figures
   AddBudgetFigures;

   //set unknown report groups
   with aClient.clChart do
      for i := 0 to Pred( ItemCount) do begin
         pAcct := Account_At(i);
         if pAcct^.chAccount_Type in [ atNone, atUnknownDR, atUnknownCR] then begin
            case SignOf( MoneyDef.DMA_Sum( pAcct^.chTemp_Amount.This_Year)) of
               Credit : pAcct^.chAccount_Type := atUnknownCR;
               Debit  : pAcct^.chAccount_Type := atUnknownDR;
            end;
         end;
      end;

   //set last period clTemp_Last_Period_Of_Actual_Data
   with aClient.clFields do begin
     clTemp_Last_Period_Of_Actual_Data := 0;
     for i := 1 to clTemp_Periods_This_Year do begin
       if clTemp_Period_Details_This_Year[ i].HasData then
         clTemp_Last_Period_Of_Actual_Data := i;
     end;
     if clTemp_FRS_Last_Actual_Period_To_Use > clTemp_Last_Period_Of_Actual_Data then
       clTemp_FRS_Last_Actual_Period_To_Use := clTemp_Last_Period_Of_Actual_Data;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddAutoContraCodes( aClient : TClientObj);

   function CodeToAdd( DefaultCode : bk5CodeStr) : bk5CodeStr;
   var
      NewCode : bk5codeStr;
      i       : integer;
   begin
      NewCode := DefaultCode;
      i := 1;
      while ( aClient.clChart.FindCode( NewCode) <> nil) do begin
         NewCode := DefaultCode + inttostr( i);
         Inc( i);
      end;
      result := NewCode;
   end;

var
   NewAcct : pAccount_Rec;
   pAcct   : pAccount_Rec;
   NewCode : bk5CodeStr;
   ClassNo : integer;
   BankAccount : TBank_Account;
   b           : integer;
begin
   RemoveAutoContraCodes( aClient);

   //add uncoded dr account
   NewCode := CodeToAdd('UNC_DR');
   NewAcct := bkchio.New_Account_Rec;
   with NewAcct^ do begin
      chAccount_Type     := BKCONST.atUncodedDr;
      chAccount_Description := 'Uncoded Debits';
      chAccount_Code     := NewCode;
      chPosting_Allowed  := true;
      chTemp_Calc_Totals_Tag := Tag_Uncoded_Contra;
   end;
   aClient.clChart.Insert( NewAcct);

   //add uncoded cr account
   NewCode := CodeToAdd('UNC_CR');
   NewAcct := bkchio.New_Account_Rec;
   with NewAcct^ do begin
      chAccount_Type     := BKCONST.atUncodedCr;
      chAccount_Description := 'Uncoded Credits';
      chAccount_Code     := NewCode;
      chPosting_Allowed  := true;
      chTemp_Calc_Totals_Tag := Tag_Uncoded_Contra;
   end;
   aClient.clChart.Insert( NewAcct);

   //add bank account to record budget movement
   NewCode := CodeToAdd('BUD_MV');
   NewAcct := bkchio.New_Account_Rec;
   with NewAcct^ do begin
      chAccount_Type     := BKCONST.atBankAccount;
      chAccount_Description := 'Movement from Budget';
      chAccount_Code     := NewCode;
      chPosting_Allowed  := true;
      chTemp_Calc_Totals_Tag := Tag_Budget_Movement;
   end;
   aClient.clChart.Insert( NewAcct);

   //add retained P & L accounts
   NewCode := CodeToAdd('RPL');
   NewAcct := bkchio.New_Account_Rec;
   with NewAcct^ do begin
      chAccount_Type     := BKCONST.atRetainedPorL;
      chAccount_Description := 'Retained Profit/Loss for Period';
      chAccount_Code     := NewCode;
      chPosting_Allowed  := true;
      chTemp_Calc_Totals_Tag := Tag_Retained_PL;
   end;
   aClient.clChart.Insert( NewAcct);//add missing gst contra codes

   NewCode := CodeToAdd('CYE');
   NewAcct := bkchio.New_Account_Rec;
   with NewAcct^ do begin
      chAccount_Type     := BKCONST.atCurrentYearsEarnings;
      chAccount_Description := 'Current Years Earnings';
      chAccount_Code     := NewCode;
      chPosting_Allowed  := true;
      chTemp_Calc_Totals_Tag := Tag_Retained_PL;
   end;
   aClient.clChart.Insert( NewAcct);//add missing gst contra codes

   //add an account for each valid gst type
   for ClassNo := 1 to Max_GST_Class do begin
     if (aClient.clFields.clGST_Class_Codes[ ClassNo] <> '') then begin
       if (aClient.clFields.clGST_Account_Codes[ ClassNo] = '') then begin
         //add a contra for missing codes
         NewCode := CodeToAdd( aClient.TaxSystemNameUC + '_' + aClient.clFields.clGST_Class_Codes[ ClassNo] );
         NewAcct := bkchio.New_Account_Rec;
         with NewAcct^ do begin
            chAccount_Type         := BKCONST.atGSTPayable;
            chAccount_Description  := 'Contra for ' + aClient.clFields.clGST_Class_Names[ ClassNo];
            chAccount_Code         := NewCode;
            chPosting_Allowed      := true;
            chTemp_Calc_Totals_Tag := Tag_Temp_GST_Contra;
         end;
         aClient.clChart.Insert( NewAcct);
         aClient.clFields.clGST_Account_Codes[ ClassNo] := NewCode;
       end
       else begin
         //add an account for invalid codes so that still appear on the report
         pAcct := aClient.clChart.FindCode( aClient.clFields.clGST_Account_Codes[ ClassNo]);
         if pAcct = nil then begin
           NewCode := aClient.clFields.clGST_Account_Codes[ ClassNo];
           NewAcct := bkchio.New_Account_Rec;
           with NewAcct^ do begin
              chAccount_Type         := BKCONST.atGSTPayable;
              chAccount_Description  := 'Contra for ' + aClient.clFields.clGST_Class_Names[ ClassNo];
              chAccount_Code         := NewCode;
              chPosting_Allowed      := true;
              chTemp_Calc_Totals_Tag := Tag_Invalid_GST_Contra;
           end;
           aClient.clChart.Insert( NewAcct);
         end;
       end;
     end;
   end;

   //add missing bank account contras
   for b := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
     BankAccount := aClient.clBank_Account_List.Bank_Account_At(b);
     if ( BankAccount.baFields.baAccount_Type = btBank ) then begin
       if ( BankAccount.baFields.baContra_Account_Code = '') then begin
         //automatically add a contra code
         NewCode := CodeToAdd('BNK');
         NewAcct := bkchio.New_Account_Rec;
         with NewAcct^ do begin
            chAccount_Type         := BKCONST.atBankAccount;
            chAccount_Description  := 'Contra for ' + BankAccount.Title;
            chAccount_Code         := NewCode;
            chPosting_Allowed      := true;
            chTemp_Calc_Totals_Tag := Tag_Temp_Bank_Contra;
         end;
         aClient.clChart.Insert( NewAcct);
         BankAccount.baFields.baContra_Account_Code := NewCode;
       end
       else begin
         //add a temporary contra for invalid contras so that it still appears
         pAcct := aClient.clChart.FindCode( BankAccount.baFields.baContra_Account_Code);
         if pAcct = nil then begin
           NewCode := BankAccount.baFields.baContra_Account_Code;
           NewAcct := bkchio.New_Account_Rec;
           with NewAcct^ do begin
              chAccount_Type         := BKCONST.atBankAccount;
              chAccount_Description  := 'Contra for ' + BankAccount.Title;
              chAccount_Code         := NewCode;
              chPosting_Allowed      := true;
              chTemp_Calc_Totals_Tag := Tag_Invalid_Bank_Contra;
           end;
           aClient.clChart.Insert( NewAcct);
         end;
       end;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RemoveAutoContraCodes( aClient : TClientObj);
var
  i       : integer;
  pAcct   : pAccount_Rec;
  ClassNo : integer;
  b       : integer;
  BankAccount : TBank_Account;
begin
  //remove gst contras, don't remove codes that were just invalid
  for ClassNo := 1 to Max_GST_Class do begin
    if (aClient.clFields.clGST_Class_Codes[ ClassNo] <> '') then begin
      pAcct := aClient.clChart.FindCode( aClient.clFields.clGST_Account_Codes[ ClassNo]);
      //see if this was a temp account, if so remove it
      if Assigned( pAcct) and ( pAcct^.chTemp_Calc_Totals_Tag = Tag_Temp_GST_Contra) then
          aClient.clFields.clGST_Account_Codes[ ClassNo] := '';
    end;
  end;

  //remove bank account contras for temp contra, don't remove codes that were just invalid
  for b := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(b);
    if ( BankAccount.baFields.baAccount_Type = btBank) then begin
      pAcct := aClient.clChart.FindCode( BankAccount.baFields.baContra_Account_Code);
      if Assigned( pAcct) and ( pAcct^.chTemp_Calc_Totals_Tag = Tag_Temp_Bank_Contra) then
        BankAccount.baFields.baContra_Account_Code := '';
    end;
  end;

  //remove temp accounts
  i := 0;
  while i < aClient.clChart.ItemCount do begin
     pAcct := aClient.clChart.Account_At(i);
     if (pAcct^.chTemp_Calc_Totals_Tag <> 0) then
        aClient.clChart.DelFreeItem( pAcct)
     else
        Inc( i);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CalculateCurrentEarnings( aClient : TClientObj);
//this routine calculates the retained profit and loss figures
//the retained p&l account holds the value for each period
//the current earnings account holds the sum of all the previous periods

//need to use the Profit and Loss Account Info object so that opening and
//closing stock accounts are correct

//assumes that calculate account totals has already been called
var
  i : integer;
  PeriodNo : integer;
  AccountInfo : TProfitAndLossAccountInfo;

  pCurrentEarnings : pAccount_Rec;
  pAcct       : pAccount_Rec;
begin
  //find the retained p & l account and the Current Year Earnings Accounts
  pCurrentEarnings := nil;
  for i := 0 to Pred( aClient.clChart.ItemCount) do begin
    pAcct := aClient.clChart.Account_At(i);
    if pAcct^.chAccount_Type = atCurrentYearsEarnings then
      pCurrentEarnings := pAcct;
  end;

  AccountInfo := TProfitAndLossAccountInfo.Create( aClient);
  try
    if Assigned( pCurrentEarnings) then begin
      //add up retained PL for each period
      for i := 0 to Pred( aClient.clChart.ItemCount) do begin
        AccountInfo.AccountCode := aClient.clChart.Account_At(i).chAccount_Code;
        AccountInfo.UseBudgetIfNoActualData     := False;
        AccountInfo.LastPeriodOfActualDataToUse := aClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;

        if AccountInfo.Account.chAccount_Type in  ProfitAndLossReportGroupsSet then begin
          for PeriodNo := AccountInfo.LowestPeriod to AccountInfo.HighestPeriod do begin
            AddTo(pCurrentEarnings.chTemp_Amount.This_Year[ PeriodNo], AccountInfo.ActualOrBudget( PeriodNo) );
            AddTo(pCurrentEarnings.chTemp_Amount.Last_Year[ PeriodNo], AccountInfo.LastYear( PeriodNo) );
            AddTo(pCurrentEarnings.chTemp_Amount.Budget[ PeriodNo], AccountInfo.Budget( PeriodNo) );

            AddTo(pCurrentEarnings.chTemp_Base_Amount.This_Year[ PeriodNo], AccountInfo.ActualOrBudget( PeriodNo) );
            AddTo(pCurrentEarnings.chTemp_Base_Amount.Last_Year[ PeriodNo], AccountInfo.LastYear( PeriodNo) );
            AddTo(pCurrentEarnings.chTemp_Base_Amount.Budget[ PeriodNo], AccountInfo.Budget( PeriodNo) );
          end;
        end;
      end;
    end;
  finally
    AccountInfo.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FlagAllAccountsForUse( aClient : TClientObj);
//will be called by old dialog routines so that all accounts are selected
var
  i : integer;
  ba : TBank_Account;
begin
  with aClient do begin
     //now set temporary flag into bank accounts;
     for i := 0 to Pred( clBank_Account_List.ItemCount) do begin
       ba := clBank_Account_List.Bank_Account_At(i);
       ba.baFields.baTemp_Include_In_Report := true;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EstimateOpeningBalancesForBankAccountContras( aClient : TClientObj);
//added an estimated opening balance figure in for contra accounts where
//no opening balance figure exists
//the figure is taken from the sum of the opening balances for all bank account
//that use that contra
var
  i,j : integer;
  BankAccount : TBank_Account;
  pAcct       : pAccount_Rec;
  OB_ThisYear : Money;
  OB_LastYear : Money;
  OB_BaseThisYear : Money;
  OB_BaseLastYear : Money;

  NewBalance  : Money;

  m1,m2,m3    : Money;

  HasBalanceThisYear : boolean;
  HasBalanceLastYear : boolean;

  This_Year_Starts         : integer;
  This_Year_Ends           : integer;
  Last_Year_Starts         : integer;
  Last_Year_Ends           : integer;
begin
  //set this year starts and last year starts, code same as above
  if aClient.clFields.clReporting_Year_Starts = 0 then exit;

  CalcYearStartEndDates( aClient, This_Year_Starts, This_Year_Ends, Last_Year_Starts, Last_Year_Ends);

  //cycle thru chart codes
  for i := aClient.clChart.First to aClient.clChart.Last do begin
    pAcct := aClient.clChart.Account_At(i);
    //see if this account has report group atBankAccount
    if ( pAcct^.chAccount_Type = atBankAccount){ and ( not (pAcct^.chTemp_Calc_Totals_Tag = Tag_Temp_Bank_Contra))} then
    begin
      //see if already has opening balances
      HasBalanceThisYear := pAcct^.chTemp_Amount.This_Year[ 0 ] <> 0;
      HasBalanceLastYear := pAcct^.chTemp_Amount.Last_Year[ 0 ] <> 0;

      if not (HasBalanceThisYear and HasBalanceLastYear) then begin
        //look for contra codes that use this account
        OB_LastYear := 0;
        OB_ThisYear := 0;
        OB_BaseThisYear := 0;
        OB_BaseLastYear := 0;

        for j := 0 to aClient.clBank_Account_List.Last do begin
          BankAccount := aClient.clBank_Account_List.Bank_Account_At(j);
          if ( BankAccount.baFields.baAccount_Type = btBank) and ( BankAccount.baFields.baContra_Account_Code = pAcct^.chAccount_Code) then
          begin
            //MUST use the Cash Book Opening Balance as this includes UPC's.  Note
            //UPC's are also included in the cash flow.
            //total this year

            BankAccount.CalculatePDBalances( This_Year_Starts, This_Year_Ends, m1, m2, NewBalance, m3);

            // Valid new balance?
            if NewBalance <> Unknown then begin
              OB_ThisYear := OB_ThisYear + NewBalance;

              //Convert to base currency
              if BankAccount.IsAForexAccount then
              begin
                if BankAccount.Default_Forex_Conversion_Rate(This_Year_Starts-1) <> 0 then //Divide by zero
                begin
                  // Opening balances are calculated at the last day of the previous month
                  NewBalance := Double2Money(Money2Double(NewBalance) / BankAccount.Default_Forex_Conversion_Rate(This_Year_Starts-1));

                  OB_BaseThisYear := OB_BaseThisYear + NewBalance;
                end;
              end
              else
              begin
                OB_BaseThisYear := OB_BaseThisYear + NewBalance;
              end;
            end;

            //total last year
            BankAccount.CalculatePDBalances( Last_Year_Starts, Last_Year_Ends, m1, m2, NewBalance, m3);

            // Valid new balance?
            if NewBalance <> Unknown then begin
              OB_LastYear := OB_LastYear + NewBalance;
                                                                        
              //Convert to base currency
              if (BankAccount.IsAForexAccount) then
              begin
                if (BankAccount.Default_Forex_Conversion_Rate(Last_Year_Starts-1)  > 0) then
                begin
                  //May not have an exchange rate for last year if no using budget figures
                  // Opening balances are calculated at the last day of the previous month
                  NewBalance := Double2Money(Money2Double(NewBalance) / BankAccount.Default_Forex_Conversion_Rate(Last_Year_Starts-1));
            
                  OB_BaseLastYear := OB_BaseLastYear + NewBalance;
                end;
              end
              else
              begin
                OB_BaseLastYear := OB_BaseLastYear + NewBalance;
              end;
            end;

          end;
        end;

        if not HasBalanceThisYear then begin
          pAcct^.chTemp_Amount.This_Year[ 0 ] := -OB_ThisYear;
          pAcct^.chTemp_Base_Amount.This_Year[ 0] := -OB_BaseThisYear;
        end;

        if not HasBalanceLastYear then begin
          pAcct^.chTemp_Amount.Last_Year[ 0 ] := -OB_LastYear;
          pAcct^.chTemp_Base_Amount.Last_Year[ 0 ] := -OB_BaseLastYear;
        end;
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
