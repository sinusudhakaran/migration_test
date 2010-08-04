unit glConst;
//------------------------------------------------------------------------------

// Title:
//   BankLink 5.0 Global Constants.
// Description:
//   This unit contains constants for Array indexes.
// Note:
//   The existing constants in GLOBALS.PAS should be progressively
//   moved into here.
//

//------------------------------------------------------------------------------
interface
uses
   BKConst;
//------------------------------------------------------------------------------

CONST
   Max_mx_Lines       = 250;
// The maximum number of dissections in a Memorised Entry.

   Max_py_Lines       = 250;
// The maximum number of dissections in a Payee Record.

   Max_tx_Lines       = 2000;
// The maximum number of dissections in a Transaction Record.

   Max_GST_Class      = 99;
// The maximum number of GST Classes available.
    MAX_VISIBLE_GST_CLASS_RATES = 3;

   bkFORCE_GST_CLASS_TO_ZERO = 255;
// Special marker used during chart refresh to allow gst class to be forced
// to zero on refresh, rather than merged with an existing class

   GST_Class_Range    = [ 1..Max_GST_Class ];
// The valid range of GST Classes.

   Max_GST_Class_Rates = 5;
// We allow for up to 5 Rates.

   Max_Divisions = 250;
// The maximum no of divisions that can be set up for a client. should match
// the size of  chPrint_in_Division[1..]

   Max_SubGroups = 250;
// The maximum no of divisions that can be set up for a client.

   ReportGroupTotalSubHeadingPos = 999;
// The sub group position to look in for the optional report group total

   Max_CESColArraySize = 32;
// THe maximum no of column settings that can be stored for a bank account

   ECODING_APP_NAME       = bkConst.ECodingDisplayName;
   ECODING_DEFAULT_EXTN   = 'trf';
   WEBX_APP_NAME          = bkConst.WebXDisplayName;
   WEBX_GENERIC_APP_NAME  = 'Web';
   WEBX_DEFAULT_EXTN      = 'bkx';
   WEBX_QUEUE_EXTN        = 'xml';
   WEBX_IMPORT_EXTN       = 'bko';
   WEBX_EXPORT_FOLDER     = 'Files';
   WEBX_QUEUE_FOLDER      = 'Queue';
   WEBX_IMPORT_FOLDER     = 'BankLink';
   WEBX_FOLDERINFO_FILE   = 'folderInfo.xml';
   WEBX_REGISTRY_KEY      = 'Software\Acclipse\WebXOffice\';
   WEBX_REGISTRY_VALUE    = 'Datapath';
   WDDX_FILENAME          = 'wddx_com.dll';

   Default_GST_Rate_NZ = 0.125;
   Default_GST_Rate_AU = 0.100;

    //Integrity Check Parameters
   MinValidDate        = 138792;   // 01/01/1980  //duplicated in globals.pas
   MaxValidDate        = 161072;   // 31/12/2040  //duplicated in globals.pas
   BKDATEEPOCH         = 1970;         //duplicated in globals.pas
   BKDATEFORMAT        = 'dd/mm/yy';   //duplicated in globals.pas

   //YesNo Dialogs
   DLG_YES             = 1;     //duplicated in globals.pas
   DLG_NO              = 2;     //duplicated in globals.pas
   DLG_CANCEL          = 3;

   // Fixed Tax Types
   tt_CompanyTax = 1;
//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------
end.
