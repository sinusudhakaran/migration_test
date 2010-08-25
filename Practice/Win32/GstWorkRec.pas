unit GstWorkRec;

interface

uses
   bkdateutils,
   MONEYDEF,
   bkConst;

//------------------------------------------------------------------------------

type
   TFormType = (GST101,  // Before 2008
               GST101A,  // No Provisional Tax
               GST103Bc, // 103B Compulsary tax period (Part 2 Filled)
               GST103Bv  // 103B Voluntary tax period (part 3 Only)
              );

   TFormPeriod = (PreOct2010,
                  Transitional,
                  PostOct2010);

const
    GSTRateChangeDate = 150023;  // 1/10/2010

    NewGSTRateText = 'Multiply Box %s by 3 and divide the result by 23';



type
   TGSTForm = record
      rIncome_Ledger  : Double;
      rClosing_Debtors: Double;
      rOpening_Debtors: Double;
      rBox_5          : Double;
      rZ_Rated_Sup    : Double;
      rBox_7          : Double;
      rBox_8          : Double;
      rFBT_Adjust     : Double;
      rOther_Adjust   : Double;
      rGST_Collected  : Double;
      rExendature_Ledger: Double;
      rClosing_Creditors: Double;
      rOpening_Creditors: Double;
      rTotal_Purch    : Double;
      rTotal_Purch_GST : Double;
      rCredit_Adjust  : Double;
      rGST_Credit     : Double;

      //adjustments...
      rAdj_Private     : Double;
      rAdj_Bassets     : Double;
      rAdj_Assets      : Double;
      rAdj_Entertain   : Double;
      rAdj_Change      : Double;
      rAdj_Exempt      : Double;
      rAdj_Other       : Double;

      rAcrt_Use        : Double;
      rAcrt_Private    : Double;
      rAcrt_Change     : Double;
      rAcrt_Customs    : Double;
      rAcrt_Other      : Double;

   end;

   pGSTWorkRec = ^rGSTWorkRec; //used when passing to report
   rGSTWorkRec = record
      rFromDate       : Longint;
      rToDate         : Longint;
      rDueDate        : Longint;
      rFormType       : TFormType;

      FormA: TGSTForm;
      FormB: TGSTForm;

      rGST_To_Pay     : Double;

      HasUncodes       : Boolean;
      HasJournals      : Boolean;
      HasWhichJournals : Array[btMin..btMax] of Boolean;

      rDraftModePrinting : Boolean;

      // Provisional tax;
      rpt_LastMonthIncome : Double;
      rpt_BranchIncome    : Double;
      rpt_Assets          : Double;
      rpt_Ratio           : Double;
      rpt_Tax             : Double;
      rpt_RefundUsed      : Double;
   end;

   mGSTWorkRec = Record // In 'Money' for the actual calculations
      mI_Ledger       : Money;
      mC_Debtors      : Money;
      mO_Debtors      : Money;
      mBox_5          : Money;
      mZ_Rated_Sup    : Money;
      mBox_7          : Money;
      mBox_8          : Money;
      mFBT_Adjust     : Money;
      mOther_Adjust   : Money;
      mGST_Collected  : Money;
      mE_Ledger       : Money;
      mC_Creditors    : Money;
      mO_Creditors    : Money;
      mTotal_Purch    : Money;
      mTotal_Purch_Div_9 : Money;
      mCredit_Adjust  : Money;
      mGST_Credit     : Money;
      mGST_To_Pay     : Money;
   end;


implementation


end.
