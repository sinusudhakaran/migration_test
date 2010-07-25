//------------------------------------------------------------------------------
//
// CodingFormConst
//
// Constants to be used byoperations on the Coding Form.
//
// Author        Date        Version Description
// Michael Foot  08/04/2003  1.00    Initial version
//
//------------------------------------------------------------------------------
unit CodingFormConst;

interface

uses
  BKConst;

const
   ceStatus         = 0;       ceMin = 0;
   ceEffDate        = 1;
   ceReference      = 2;
   ceAnalysis       = 3;
   ceAccount        = 4;
   ceAmount         = 5;
   ceNarration      = 6;    {oz}
   ceOtherParty     = 7;    {nz}
   ceParticulars    = 8;    {nz}
   cePayee          = 9;
   ceGSTClass       = 10;   {nz}
   ceGSTAmount      = 11;   {nz}
   ceQuantity       = 12;
   ceEntryType      = 13;
   cePresDate       = 14;
   ceCodedBy        = 15;
   ceNotesIcon      = 16;   //obosolete in v5.2
   ceStatementDetails = 17;
   ceTaxInvoice     = 18;
   ceBalance        = 19;
   ceDescription    = 20;
   cePayeeName      = 21;
   ceDocument       = 22;
   ceJob            = 23;
   ceJobName        = 24;
   ceAction         = 25;
   ceForexAmount    = 26;
   ceForexRate      = 27;
   ceLocalCurrencyAmount = 28;
   ceAltChartCode  = 29;

   ceMax = 29;

   MaxNZColumns = 28;

   DefaultColumnOrderNZ : array[ 1..MaxNZColumns] of byte =
             (
             ceStatus,
             ceEffDate,
             ceReference,
             ceAnalysis,
             ceAccount,
             ceDescription,
             ceForexAmount,
             ceForexRate,
             ceLocalCurrencyAmount,
             ceAmount,
             ceBalance,
             ceStatementDetails,
             ceOtherParty,
             ceParticulars,
             ceNarration,
             cePayee,
             cePayeeName,
             ceJob,
             ceJobName,
             ceGSTClass,
             ceGSTAmount,
             ceTaxInvoice,
             ceQuantity,
             ceEntryType,
             cePresDate,
             ceCodedBy,
             ceAction,
             ceAltChartCode
             );



{$IFDEF SmartLink}
    MaxOZColumns = 25;
   DefaultColumnOrderOZ : array[ 1..MaxOZColumns] of byte =
             (
             ceStatus,
             ceEffDate,
             ceReference,
             ceAccount,
             ceDescription,
             ceForexAmount,
             ceForexRate,
             ceLocalCurrencyAmount,
             ceAmount,
             ceBalance,
             ceStatementDetails,
             ceNarration,
             ceDocument,
             cePayee,
             cePayeeName,
             ceJob,
             ceJobName,
             ceGSTClass,
             ceGSTAmount,
             ceTaxInvoice,
             ceQuantity,
             ceEntryType,
             cePresDate,
             ceCodedBy
             ceAction,
             );
{$ELSE}
   MaxOZColumns = 26;
   DefaultColumnOrderOZ : array[ 1..MaxOZColumns] of byte =
             (
             ceStatus,
             ceEffDate,
             ceReference,
             ceAccount,
             ceDescription,
             ceForexAmount,
             ceForexRate,
             ceLocalCurrencyAmount,
             ceAmount,
             ceBalance,
             ceStatementDetails,
             ceNarration,
             cePayee,
             cePayeeName,
             ceJob,
             ceJobName,
             ceGSTClass,
             ceGSTAmount,
             ceTaxInvoice,
             ceQuantity,
             ceEntryType,
             cePresDate,
             ceCodedBy,
             ceDocument,
             ceAction,
             ceAltChartCode
             );

   MaxUKColumns = 25;
   DefaultColumnOrderUK : array[ 1..MaxUKColumns] of byte =
             (
             ceStatus,
             ceEffDate,
             ceReference,
             ceAccount,
             ceDescription,
             ceForexAmount,
             ceForexRate,
             ceLocalCurrencyAmount,
             ceAmount,
             ceBalance,
             ceStatementDetails,
             ceNarration,
             cePayee,
             cePayeeName,
             ceJob,
             ceJobName,
             ceGSTClass,
             ceGSTAmount,
             ceTaxInvoice,
             ceQuantity,
             ceEntryType,
             cePresDate,
             ceCodedBy,
             ceDocument,
             ceAltChartCode
             );
{$ENDIF}

  //ceStatus
  CE_STATUS_DEF_WIDTH = 32;
  CE_STATUS_DEF_VISIBLE = True;
  CE_STATUS_DEF_EDITABLE = False;
  //ceEffDate
  CE_EFFDATE_DEF_WIDTH = 70;
  CE_EFFDATE_DEF_VISIBLE = True;
  CE_EFFDATE_DEF_EDITABLE = False;
  //ceReference
  CE_REFERENCE_DEF_WIDTH = 100;
  CE_REFERENCE_DEF_VISIBLE = True;
  CE_REFERENCE_DEF_EDITABLE = False;
  //ceAnalysis (NZ only)
  CE_ANALYSIS_DEF_WIDTH = 100;
  CE_ANALYSIS_DEF_VISIBLE = True;
  CE_ANALYSIS_DEF_EDITABLE = False;
  //ceAccount
  CE_ACCOUNT_DEF_WIDTH = 100;
  CE_ACCOUNT_DEF_VISIBLE = True;
  CE_ACCOUNT_DEF_EDITABLE = True;
  //ceDescription
  CE_DESCRIPTION_DEF_WIDTH = 150;
  CE_DESCRIPTION_DEF_VISIBLE = False;
  CE_DESCRIPTION_DEF_EDITABLE = False;
  //ceAmount
  CE_FOREX_AMOUNT_DEF_WIDTH = 140;
  CE_FOREX_AMOUNT_DEF_VISIBLE = True;
  CE_FOREX_AMOUNT_DEF_EDITABLE = True;
  //ceAmount
  CE_FOREX_RATE_DEF_WIDTH = 100;
  CE_FOREX_RATE_DEF_VISIBLE = True;
  CE_FOREX_RATE_DEF_EDITABLE = False;
  //ceAmount
  CE_LOCAL_CURRENCY_AMOUNT_DEF_WIDTH = 140;
  CE_LOCAL_CURRENCY_AMOUNT_DEF_VISIBLE = True;
  CE_LOCAL_CURRENCY_AMOUNT_DEF_EDITABLE = True;
  //ceAmount
  CE_AMOUNT_DEF_WIDTH = 140;
  CE_AMOUNT_DEF_VISIBLE = True;
  CE_AMOUNT_DEF_EDITABLE = False;
  //ceNarration
  CE_NARRATION_DEF_OZ_WIDTH = 150;
  CE_NARRATION_DEF_NZ_WIDTH = 250;
  CE_NARRATION_DEF_VISIBLE = True;
  CE_NARRATION_DEF_EDITABLE = True;
  //ceOtherParty (NZ only)
  CE_OTHERPARTY_DEF_WIDTH = 160;
  CE_OTHERPARTY_DEF_VISIBLE = False;
  CE_OTHERPARTY_DEF_EDITABLE = False;
  //ceParticulars (NZ only)
  CE_PARTICULARS_DEF_WIDTH = 160;
  CE_PARTICULARS_DEF_VISIBLE = False;
  CE_PARTICULARS_DEF_EDITABLE = False;
  //cePayee
  CE_PAYEE_DEF_WIDTH = 60;
  CE_PAYEE_DEF_VISIBLE = True;
  CE_PAYEE_DEF_EDITABLE = True;
  //cePayeeName
  CE_PAYEENAME_DEF_WIDTH = 100;
  CE_PAYEENAME_DEF_VISIBLE = False;
  CE_PAYEENAME_DEF_EDITABLE = False;
  //ceGSTClass
  CE_GSTCLASS_DEF_WIDTH = 40;
  CE_GSTCLASS_DEF_VISIBLE = True;
  CE_GSTCLASS_DEF_EDITABLE = True;
  //ceGSTAmount
  CE_GSTAMOUNT_DEF_WIDTH = 80;
  CE_GSTAMOUNT_DEF_VISIBLE = True;
  CE_GSTAMOUNT_DEF_EDITABLE = True; //exceptions
  //ceQuantity
  CE_QUANTITY_DEF_WIDTH = 60;
  CE_QUANTITY_DEF_VISIBLE = True;
  CE_QUANTITY_DEF_EDITABLE = True;
  //ceEntryType
  CE_ENTRYTYPE_DEF_WIDTH = 70;
  CE_ENTRYTYPE_DEF_VISIBLE = True;
  CE_ENTRYTYPE_DEF_EDITABLE = False;
  //cePresDate
  CE_PRESDATE_DEF_WIDTH = 70;
  CE_PRESDATE_DEF_VISIBLE = True;
  CE_PRESDATE_DEF_EDITABLE = False;
  //ceCodedBy
  CE_CODEDBY_DEF_WIDTH = 150;
  CE_CODEDBY_DEF_VISIBLE = True;
  CE_CODEDBY_DEF_EDITABLE = False;
  //ceNotesIcon

  //ceStatementDetails
  CE_STATEMENT_DEF_WIDTH = 150;
  CE_STATEMENT_DEF_VISIBLE = False;
  CE_STATEMENT_DEF_EDITABLE = False;
  //ceTaxInvoice
  CE_TAXINVOICE_DEF_WIDTH = 55;
  CE_TAXINVOICE_DEF_VISIBLE = False;
  CE_TAXINVOICE_DEF_EDITABLE = False;
  //ceBalance
  CE_BALANCE_DEF_WIDTH = 140;
  CE_BALANCE_DEF_VISIBLE = False;
  CE_BALANCE_DEF_EDITABLE = False;

  //ceDocument (SmartLink ONLY!!)
  CE_DOCUMENT_DEF_WIDTH = 140;
  CE_DOCUMENT_DEF_VISIBLE = True;
  CE_DOCUMENT_DEF_EDITABLE = False;

  CE_JOB_DEF_WIDTH = 60;
  CE_JOB_DEF_VISIBLE = False;
  CE_JOB_DEF_EDITABLE = True;

  //ceAltChartCode
  CE_AltChartCode_DEF_WIDTH = 100;
  CE_AltChartCode_DEF_VISIBLE = False;
  CE_AltChartCode_DEF_EDITABLE = False;

implementation

uses
  glConst;

initialization
  Assert( ceMax <= Max_CESColArraySize, 'ceMax <= Max_CESColArraySize');
end.
