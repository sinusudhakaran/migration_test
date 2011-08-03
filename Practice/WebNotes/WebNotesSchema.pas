unit WebNotesSchema;
//------------------------------------------------------------------------------
{
   Title: WebNotesSchema

   Description:

      Holds most of the Field and atribute names, matching the Webnotes schema

      also has Some XML helpers for reading wnd writing field types.

      Used in 
         CheckWebNotesdata
         WebNotesDataUpload   (Upload to webnotes)
         WebNotesImportfrm (Download from webNotes)

      similar EncodeText and DecodeText

      this code should not be altered unless the Webnotes schema demands it.



   Author: Andre' Joosten

   Remarks:


}
//------------------------------------------------------------------------------
interface

uses
  bkConst;

(* vvvvvvvvvvvvvvv  DO NOT CHANGE UNLESS THE SCHEMA AT THE WEBNOTES END DEMANDS IT vvvvvvvvvvvv*)
const
  nCountry = 'Country';
  nCompany = 'Company';
  nEmail = 'Email';
  nContact = 'Contact';
  nPracticeContact = 'PracticeContact';
  nVersion = 'Version';
  nDateMask =  'yyyy-mm-dd';
  nConfiguration = 'Configuration';
  nOptions ='Options';
  nOption = 'Option';
  nShowQuantity = 'ShowQuantity';
  nShowTax = 'ShowTax';
  nShowTaxInvoice = 'ShowTaxInvoice';
  nShowAccount = 'ShowAccount';
  nRestrictUPI = 'RestrictUPI';
  nShowJob = 'ShowJob';
  nShowPayee = 'ShowPayee';
  nShowSuperfund = 'ShowSuperfund';
  nSendNotification = 'SendNotification';

  nAccounts = 'Accounts';
  nAccount = 'Account';
  nNumber = 'Number';
  nCurrency = 'Currency';
  nTransactions  = 'Transactions';
  nTransaction = 'Transaction';
  nSource = 'Source';
  nCodedBy = 'CodedBy';
  nUPIState = 'UPIState';

  // Boolean
  nValue = 'Value';
  nTrue = 'true';
  nFalse = 'false';

  nUploadBatchRequest = 'UploadBatchRequest';
  nItems = 'Items';
  nBatch = 'Batch';
  nFromDate = 'FromDate';
  nToDate = 'ToDate';
  nEndDate = 'EndDate';

  nSequenceIndex = 'SequenceIndex';
  nExternalID = 'ExternalID';
  nDateEffective = 'DateEffective';
  nChartCode = 'ChartCode';
  nAmount = 'Amount';
  nTaxAmount = 'TaxAmount';
  nTaxCode = 'TaxCode';
  nTaxEdited = 'TaxEdited';
  nTaxInvoice = 'TaxInvoice';
  nNarration = 'Narration';
  nReference = 'Reference';
  nChequeNumber = 'ChequeNumber';
  nQuantity =  'Quantity';
  nJobCode = 'JobCode';
  nPayeeNumber = 'PayeeNumber';
  nSFFranked = 'SFFranked';
  nSFUnFranked = 'SFUnfranked';
  nSFFrankingCredit = 'SFFrankingCredit';
  nCodeLocked = 'CodeLocked';
  nDissections = 'Dissections';
  nDissection  = 'Dissection';
  nNotes = 'Notes';

  nChart = 'Chart';
  nCodeMask = 'CodeMask';
  nChartEntry = 'ChartEntry';
  nCode = 'Code';
  nDescription = 'Description';

  nPosting = 'Posting';
  nBasic = 'Basic';

  nTaxRates = 'TaxRates';
  nTaxRate = 'TaxRate';
  nRate = 'Rate';
  nAppliesFrom  = 'AppliesFrom';
  nCompanyTax = 'CompanyTax';

  nJobs = 'Jobs';
  nJob = 'Job';
  nName = 'Name';
  nAdded = 'Added';
  nCompleted = 'Completed';

  nPayees = 'Payees';
  nPayee = 'Payee';
  nPayeeLine = 'PayeeLine';
  nPercentage = 'Percentage';
  nValueType = 'ValueType';

  nIndex = 'Index';


  nDisplayName = 'DisplayName';
  nBatchID = 'BatchId';
  nStatus = 'Status';

  nDateFinished = 'DateFinished';
  nDateCreated = 'DateCreated';

  nUPINames : array[ upMin..upMax] of string[15] =(
    'None',
    'UPC',
    'MatchedUPC',
    'BalanceOfUPC',
    'ReversedUPC',
    'ReversalOfUPC',

    'UPD',
    'MatchedUPD',
    'BalanceOfUPD',
    'ReversedUPD',
    'ReversalOfUPD',

    'UPW',
    'MatchedUPW',
    'BalanceOfUPW',
    'ReversedUPW',
    'ReversalOfUPW'
   );

  nBatchComplete = 'Completed';

  nCompanyCode = 'CompanyCode';
  nCount = 'Count';

  nAvailableDataResponse = 'AvailableDataResponse';

  nSuccess = 'Success';
  nError  = 'Error';
  nMessage = 'Message';

  CreateBatchRequestNameSpace = 'http://banklink.co.nz/oct/schema';
  CreateBatchRequestVersion = '1.0';
(* ^^^^^^^^^^^^  DO NOT CHANGE UNLESS THE SCHEMA AT THE WEBNOTES END DEMANDS IT ^^^^^^^^^ *)

implementation

end.


