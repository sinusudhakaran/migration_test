unit StdHints;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Holds constants for hints that are common to a few different forms
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

const
  //print preview hints
  PREVIEWHINT        = 'View the Report on screen|'+
                       'View the Report on screen prior to printing';

  PRINTHINT          = 'Print the Report|'+
                       'Send the Report directly to the default printer for this report';

  PrintToFileHint    = 'Print the Report to File|'+
                       'Send the Report to a file';  

  //other common hints
  CHARTLOOKUPHINT    = 'Lookup the Chart of Accounts|' +
                       'Lookup the Chart of Accounts';

  JOBLOOKUPHINT      = 'Lookup the Job list|' +
                       'Lookup the Job list';

  PAYEELOOKUPHINT    = 'Lookup the Payee list|'+
                       'Lookup the Payee list';

  DATEFROMHINT       = 'Enter the date to select transactions from|' +
                       'Transactions from this date will be included';

  DATETOHINT         = 'Enter the date to select transactions up to|' +
                       'Transactions up to this date will be included';

  PREVDATEHINT       = 'Select the dates for the previous period|' +
                       'Select the dates for the previous period';

  NEXTDATEHINT       = 'Select the dates for the next period|' +
                       'Select the dates for the next period';

  QUICKDATEHINT      = 'Display a menu of common date ranges|' +
                       'Display a menu of common date ranges';

  RPTFINYEARSTARTHINT= 'Enter the Financial Year Start Date|' +
                       'Enter the Financial Year Start Date for this report';

  RPTPERIODHINT      = 'Select the reporting period|' +
                       'Select the period for reporting up to';

  RPTINCLUDECODESHINT= 'Check to include the Chart Codes in the report|' +
                       'Check to include the Chart Codes next to the description in the report';

  RPTINCLUDEGSTHINT =  'Check to include GST in the Report figures|' +
                       'Check to include GST in the Report figures';

  RPTINCLUDEVATHINT =  'Check to include VAT in the Report figures|' +
                       'Check to include VAT in the Report figures';

  DIRBUTTONHINT     =  'Select a directory path|'+
                       'Select a directory path';

  SUPERFIELDSHINT   =  'View/Edit the Superfund details for this line';

implementation

end.
