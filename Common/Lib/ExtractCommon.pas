unit ExtractCommon;
///------------------------------------------------------------------------------
///  Title:   Bulk Export Common bits
///
///  Written: June 2009
///
///  Authors: Andre' Joosten
///
///  Purpose: One unit used in the extract DLLs and Practice, for all common bits
///
///  Notes:  When making changes, consider the impact on all (exsisting) versions of dll's
///          Typically (not guarantied) you can add, just dont alter exsiting bits
///
///          You can always introduce an other version, to make more elaborate changes
///
///          The actual data, is just comma separated text.
///          I can easaly be changed while remaining backward compatible, i.e not all DLL need updating
///          There is a commom structure that is passed around, with the obvious common bits for simplicity.
///
///------------------------------------------------------------------------------

interface
uses
   Windows, graphics, SysUtils;



// Basic Version handeling
// Each dll has a version Number,
// so if we need to make major changes to the way they operate we can handle old versions
type
  ProcGetversion = function: Integer; stdcall;

const
   GetVersionName = 'GetExtractVersion';
   Version_1 = 1;  // Only Current version


// Extract type
// In theory each dll could handle more that one extract type (small variations to very similar types)
// Extract Class can be used for Authorization types

type
  ExtractType = packed record
     Index: Integer;
     Code: Pchar;
     Description: Pchar;
     ExtractClass: Integer;
  end;

  ProcGetExtractType = function (Index: Integer; var EType: ExtractType): Boolean; stdcall;

const
  GetExtractTypeName = 'GetExtractType';
  ClassBase = 0;


// Extract Session
// Common data passed for each Extract function

type
  TExtractSession = packed record
     Index: Integer;
     ExtractFunction: Integer;
     IniFile: pChar;
     FromDate: Integer;    // Not desparetly needed
     ToDate: Integer;
     AccountType: Integer; // So we can handle Journals Different
     ExtractDate: Integer;
     Data: pChar;
  end;

const
   // Extract Function values
   // Altering these would break all dll's
   ef_SessionStart = 0;
   ef_SessionEnd   = 1;
   ef_ClientStart  = 2;
   ef_ClientEnd    = 3;
   ef_AccountStart = 4;
   ef_AccountEnd   = 5;
   ef_Transaction  = 6; //Undissected Transaction
   ef_Dissection   = 7; //Dissection (s) of a transaction
   ef_Dissected    = 8; //Transaction followed by the dissections

   ef_CanConfig    = 1000; // Test to see if it has a configuration option
   ef_DoConfig     = 1001; // Do an actual config (Run the config Dialog)

// Actual Export Procedures
type
  ProcBulkExport = function(var Session: TExtractSession): Integer; stdcall;


const
   //Expected Results
   er_NotImplemented  = 0; // Assume success
   er_OK              = 1;
   // Errors
   er_Skip            = -1; // Not required, i.e Account Type / Journal
   er_Cancel          = -2; // Some dialog was canceled..
   er_Error           = -3; // Individual probleml; Data hold some logable error i.e. no Contra code for account ....
   er_Abort           = -4; // cannot continue Data may hold error

const
  BulkExportName = 'DoBulkExport';

//Check ExportFeature
type
  ProcCheckFeature = function(const index, Feature: Integer): Integer; stdcall;

const
     tr_Default = 0; //simplesed default return
  tf_TransactionID = 1; //test for transaction ID
     // 0 : No specific id, comes with Line Numbers and transaction numbers for the whole export
     // I.E need you own counters if you want per Client or Account
     tr_BNotes   = 1; // Generate and pass
     tr_GUID     = 2; // Generate and pass GUIDS
     tr_HalvGUID = 3;

  tf_TransactionType = 2;
     tr_Coded      = 1; // Must be coded
     tr_Superfund  = 2; // Must have superfund

  tf_BankAccountType = 3;
     tr_Contra     = 1; //Most have Contra Code

  tf_ClientType = 4;

const
  CheckFeatureName = 'CheckFeature';

// Common FieldNames
const
  f_Name         = 'Name';
  f_Code         = 'Code';
  f_Desc         = 'Desc';
  f_Number       = 'Number';
  f_ContraCode   = 'ContraCode';
  f_ContraDesc   = 'ContraDesc';
  f_Date         = 'Date';
  f_Line         = 'Line';     //Line Number
  f_Trans        = 'Trans';    //Transaction Numer
  f_Dissect      = 'Diss';     //Dissection Number in the Transaction
  f_TransID      = 'TransID';  //Transaction ID, format may depend on the DLL features
  f_Amount       = 'Amount';
  f_TransType    = 'TransType';
  f_Reference    = 'Ref';
  f_ChequeNo     = 'ChequeNo';
  f_Analysis     = 'Analysis';
  f_OtherParty   = 'OtherParty';
  f_Particulars  = 'Particulars';
  f_Narration    = 'Narration';
  f_Notes        = 'Notes';
  f_Quantity     = 'Quantity';
  f_Tax          = 'Tax'; //GST or VAT...
  f_TaxCode      = 'TaxCode';
  f_TaxDesc      = 'TaxDesc';
  f_Balance      = 'Balance';
  f_JobCode      = 'JobCode';
  f_JobDesc      = 'JobDesc';
  // Superfund Fields
  f_CGTDate      = 'CGTDate';
  f_Franked      = 'Franked';     //Franked Dividend
  f_Unfranked    = 'UnFranked';   //UnFranked_Dividend
  f_Imp_Credit   = 'Imp_Credit';  //Imputation Credit
  f_TFN_Credit   = 'TFN_Credit';  //Tax File Number?? Credit
  f_Frn_Credit   = 'Frn_Credit';  //Foreign Tax Credit
  f_OT_Credit    = 'OT_Credit';   //Other Tax Credit

  f_TF_Dist      = 'TF_Dist';     //Tax Free Distribution
  f_TE_Dist      = 'TE_Dist';     //Tax Exempt Distribution
  f_TD_Dist      = 'TD_Dist';     //Tax Defered Distribution
  f_Frn_Income   = 'Frn_Income';  //Foreign Income
  f_CGI          = 'CGI';         //Capital Gains Indexed
  f_CGD          = 'CGD';         //Capital Gains Discounted
  f_CGO          = 'CGO';         //Capital Gains Other
  f_MemComp      = 'MemComp';     //Member component
  f_MemID        = 'MemID';       //Member ID / Code
  f_OExpences    = 'O_Expence';   //Other Expences

  f_FundID       = 'FundID';      //FundID / Code
  f_SFTransID    = 'SFTransID';   //Superfund Transaction ID
  f_SFTransCode  = 'SFTransCode'; //Superfund Transaction Code

  f_Interest        = 'SFInterest';        //Interest
  f_ForeignCG       = 'SFForeignCG';       //Foreign Capital Gain
  f_ForeignDiscCG   = 'SFForeignDiscCG';   //Capital Gains Foreign Disc
  f_Rent            = 'SFRent';            //Rent
  f_SpecialIncome   = 'SFSpecialIncome';   //Special Income
  f_ForeignCGCredit = 'SFForeignCGCredit'; //Foreign Capital Gains Credit
  f_NonResidentTax  = 'SFNonResidentTax';  //Non Resident Tax

  f_CGFraction      = 'CGFrac';     // Capital Gains Fraction;

  f_Country      = 'Country';
    c_NZ         = 'NZ';
    c_AU         = 'AU';
    c_UK         = 'UK';

// Some Help Procs
type
  // Used for forms, making sure any launched dll forms apear to belong to the mainApp
  // Also manage any operating system based font
  procInitDllApplication = procedure (ApplicationHandle: HWnd; BaseFont: TFont); stdcall;
const
  procInitDllApplicationName = 'procInitDllApplication';

// Basic name for the DLL
// BankLink Bulk Export
const
   DllFilemask = 'BBE_*.dll';


// Extract Codes
// May need to move Elswhere, but have to start somewhere
// They could/should reside in the individual DLL code,
// but this way we have a record of all of them, in the one place.
// Max Lenght only 8 Chars
const                   // 12345678
  CSVSimple             = 'CSV00';
  BGLXMLcode            = 'BGLXML00';
  XMLBasicCode          = 'XML00';
  OnePlaceBasicCode     = '1Place00';
  PraemiumCode          = 'Praemium';
  ProSuperXml           = 'ProSFXml';
  RewardSuperXml        = 'RewrdXml';
  SageHandisoftSuperXml = 'SageHdSF';
  superMateXml          = 'SprMtXml';
  BBTechBasicCode       = 'BBTech';
  ClassSuperBasicCode   = 'ClssSupr';
  IDSSuper              = 'IDSSuper';
  TwinField             = 'TwnfdCSV';

implementation

// Takes in a disk code, returns BSB and account number
// NOTE: PUT ANY CHANGES MADE HERE INTO PROCESSDISKCODE IN ExtractIDS_Super, for some
// reason ExtractIDS_Super can't access ProcessDiskCode in ExtractCommon so I've had to
// duplicate the functionality
procedure ProcessDiskCode(InputString: string; var Bsb, AccountNum: string);
const
  NumericalChars = ['0'..'9'];
var
  InputStringNumericOnly: string;
  FirstSixChars, RemainingChars: string;

  function StripNonNumeric(const AValue: string): string;
  var
    SrcPtr, DestPtr: PChar;
  begin
    SrcPtr := PChar(AValue);
    SetLength(Result, Length(AValue));
    DestPtr := PChar(Result);
    while SrcPtr[0] <> #0 do
    begin
      if SrcPtr[0] in NumericalChars then
      begin
        DestPtr[0] := SrcPtr[0];
        Inc(DestPtr);
      end;
      Inc(SrcPtr);
      if (SrcPtr = '') then
        break;
    end;
    SetLength(Result, DestPtr - PChar(Result));
  end;

begin
  InputStringNumericOnly := StripNonNumeric(InputString);

  // Special conditions
  if (AnsiCompareText(InputString, 'Cash Journals') = 0) then // Note: AnsiCompareText is not case sensitive
  begin
    Bsb := '000000';
    AccountNum := '11111111';
  end else
  if (AnsiCompareText(InputString, 'Accrual Journals') = 0) then
  begin
    Bsb := '000000';
    AccountNum := '99999999';
  end else
  // Condition 1: disk code has 12 characters or more, first character is numeric
  if (Length(InputString) > 11) and (InputString[1] in NumericalChars) then
  begin
    FirstSixChars := Copy(InputStringNumericOnly, 1, 6);
    RemainingChars := Copy(InputStringNumericOnly, 7);
    Bsb := FirstSixChars;
    AccountNum := RemainingChars;
  end else
  // Condition 2: disk code has 11 or less numeric characters, first character is non-numeric
  if (Length(InputStringNumericOnly) < 12) and not (InputString[1] in NumericalChars) then
  begin
    Bsb := '000000';
    AccountNum := InputStringNumericOnly;
  end else
  // Condition 3: disk code has 12 or more characters, first character is non-numeric
  begin
    Bsb := Copy(InputStringNumericOnly, 1, 6);
    AccountNum := Copy(InputStringNumericOnly, 7);
  end;
end;

end.
