{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

UNIT TOKENS;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }
INTERFACE
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

CONST
   tkStartOfFile              = 0;
   tkStartRecord              = 1;
   tkBeginEntries             = 2;
   tkBeginDissections         = 3;
   tkBeginMemorisedEntries    = 4;
   tkBeginChart               = 5;
   tkBeginMacros              = 6;
   tkBeginPayees              = 7;
   tkBeginDiskList            = 8;
   tkBeginBankAccountList     = 9;
   tkBeginBudget              = 10;
   tkBeginBudgetList          = 11;
   tkBeginBalancesList        = 12;
   tkBeginInstructionList     = 13;
   tkBeginClientReportList    = 14;
   tkBeginMatchedItems        = 15;
   tkBeginCustomHeadingsList  = 16;
   tkBeginCustomHeadingsListEx= 17;
   tkBeginPayeesList          = 18;
   tkBeginPayeeLinesList      = 19;
   tkBeginMemorisationsList   = 20;
   tkBeginMemorisationLinesList = 21;
   tkBeginEncryptedData       = 22;
   tkBeginJobList             = 23;

   tkBeginSystem_Disk_Log              = 30;
   tkBeginSystem_Client_File_List      = 31;
   tkBeginSystem_User_List             = 32;
   tkBeginSystem_Bank_Account_List     = 33;
   tkBeginSystem_Access_List           = 34;
   tkBeginSystem_Client_Account_Map    = 35;
   tkBeginSystem_Group_List            = 36;
   tkBeginSystem_Client_Type_List      = 37;
   tkBeginSystem_Audit_Trail_List      = 38;
   tkBeginSystem_Memorisation_List     = 39;
   // 40 Is used by ClientExtra
   tkBeginSystem_Provisional_Entries_Log = 41;
   tkBeginSystem_TPR_Supplier_Detail     = 42;

   tkBeginExchangeRateHeader           = 50; //Just the header on its own
   tkBeginExchangeRateList             = 51; //List of sources
   tkBeginExchangeRateSource           = 52; //Source in the list
   tkBeginExchangeRates                = 53; //The Rates after the header for a Source

   tkBeginPrinter_List                 = 60;
   tkBeginForm_List                    = 61;
   tkBeginReport_Setting_List          = 62;
   tkBeginWindows_Report_Setting_List  = 63;

   tkBeginCoding_Stats_List            = 70;
   tkBeginDeleted_Transaction_List     = 71;

   tkBeginExchange_Gain_Loss_List      = 72;

   tkBeginFinalized_Exchange_Rate_List = 73;

   tkBeginRecommended_Mems             = 74;
   tkBeginUnscanned_Transaction_List   = 75;
   tkBeginCandidate_Mem_List           = 76;
   tkBeginRecommended_Mem_List         = 77;
   tkBeginMem_Scan_Command_List        = 78;

   tkBeginSuggested_Mem_List           = 79;
   tkBeginTran_Suggested_Link_List     = 80;
   tkBeginSuggested_Account_List       = 81;
   tkBeginSuggested_Account_Link_List  = 82;
   tkBeginSuggested_Phrase_List        = 83;

   tkLastAuditRecordID        = 252;
   tkEndRecord                = 253;
   tkEndSection               = 254;
   tkEndOfFile                = 255;      

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }
IMPLEMENTATION
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

end.

