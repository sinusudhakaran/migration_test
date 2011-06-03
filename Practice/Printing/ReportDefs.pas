unit ReportDefs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Defines the Report Destination types and all of the report identifiers
//
//conditional compile options for smartbooks
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

type
   TReportDest = ( rdScreen, rdPrinter, rdFile, rdAsk, rdSetup, rdNone,
                   rdEmail, rdFax, rdEcoding, rdCSVExport, rdWebX, rdCheckOut, rdBusinessProduct) ;

  //export file formats                 
  TFileFormats = (ffCSV, ffFixedWidth, ffExcel, ffPDF, ffAcclipse,ffRtf);
  TFileFormatSet = set of TFileFormats;

   REPORT_LIST_TYPE = (Report_List_Chart,
                       Report_List_Entries,
                       Report_List_Journals,
                       Report_List_BankAccts,
                       Report_List_Payee,
                       Report_List_Ledger,
                       Report_Coding,
                       Report_Coding_Standard,
                       Report_Coding_TwoCol,
                       Report_Coding_Details,
                       Report_Coding_Anomalies,
                       Report_Cashflow_Act,
                       Report_Cashflow_ActBud,
                       Report_Cashflow_ActBudVar,
                       Report_Cashflow_12Act,
                       Report_Cashflow_12ActBud,
                       Report_BankRec_Sum,
                       Report_BankRec_Detail,
                       Report_Payee_Spending,
                       Report_Payee_Spending_Detailed,
                       Report_Job_Summary,
                       Report_Job_Detailed,
                       Report_GST101,
                       Report_GST372,
                       Report_Exception,
                       Report_Cashflow_Date,
                       Report_Cashflow_BudRem,
                       Report_Profit_Date,
                       Report_Profit_BudRem,
                       REPORT_Profit_ACT,
                       REPORT_Profit_ACT_LY,
                       Report_Profit_ActBud,
                       Report_Profit_ActBud_LY,
                       Report_Profit_ActBudVar,
                       Report_Profit_12Act,
                       Report_Profit_12ActBud,
                       Report_Profit_12Bud,
                       Report_Profit_Export,

                       Report_GST_Summary,
                       Report_GST_allocationSummary,
                       Report_GST_Summary_12,
                       Report_GST_Audit,
                       Report_Budget_Listing,
                       Report_Budget_12CashFlow,

                       Report_Client_Header,
                       Report_Sort_Header, //Isn't actually used. Except to store print settings between the next 3 reports
                       Report_Staff_Member_Header,
                       Report_Group_Header,
                       Report_Client_Type_Header,
                       Report_Download,
                       Report_Admin_Charges,
                       Report_WhatsDue,
                       Report_Admin_Accounts,
                       Report_Admin_Inactive_Accounts,
                       Report_Prov_Accounts,
                       Report_Clients_By_Staff,
                       Report_Client_Report_Opt,
                       Report_Download_Log,

                       Report_TrialBalance,
                       Report_Income_Expenditure,

                       Report_BAS,
                       Report_BAS_CAL,

                       Report_Download_Log_Offsite,

                       Report_GST_BusinessNorms,
                       Report_GST_Overrides,
                       Report_List_GST_Details,

                       Report_Schd_Rep_Summary,

                       Report_List_Memorisations,
                       Report_Client_Status,
                       Report_Cashflow_ActLastYVar,
                       Report_Summary_List_Ledger,
                       Report_File_Access_Control,

                       Report_Cashflow_Single,
                       Report_Cashflow_Multiple,
                       Report_ProfitandLoss_Single,
                       Report_ProfitandLoss_Multiple,
                       Report_BalanceSheet_Single,
                       Report_BalanceSheet_Multiple,
                       Report_BalanceSheet_Export,

                       Report_Summary_Download,
                       Report_Unpresented_Items,
                       Report_List_Divisions,
                       Report_List_Jobs,
                       Report_List_SubGroups,
                       Report_List_Entries_With_Notes,
                       Report_Coding_Standard_With_Notes,
                       Report_Coding_TwoCol_With_Notes,

                       Report_Cashflow_Export,
                       Report_TasksDueForClient,
                       Report_AllTasksDue,
                       Report_Missing_Cheques,

                       Report_BasSummary,
                       REPORT_TEST_FAX,

                       REPORT_MAILMERGE_PRINT,
                       REPORT_MAILMERGE_EMAIL,

                       Report_Billing,
                       Report_Charges,

                       Report_CAF,
                       Report_TPA,

                       Report_ClientManager,
                       Report_ClientHome,

                       List_Groups,
                       List_Client_Types,
                       Report_VAT,
                       Report_Foreign_Exchange,
                       Report_Coding_Optimisation,
                       Report_Custom_Document,
                       Report_System_Accounts,
                       Report_Audit,
                       Report_Last);

const
   {$IFDEF SmartBooks}
   .. smart books code is now seperate
   {$ELSE}
   REPORT_LIST_NAMES : Array[REPORT_LIST_CHART..REPORT_LAST] of String =
                       ('List Chart of Accounts',
                        'List Entries',
                        'List Journals',
                        'List Bank Accounts',
                        'List Payees',
                        'Ledger - Detailed',
                        'Coding',
                        'Coding - Standard',
                        'Coding - Two Column',
                        'Coding - Details Only',
                        'Coding - Anomalies',
                        'Cash Flow - Actual',
                        'Cash Flow - Actual and Budget',
                        'Cash Flow - Actual, Budget and Variance',
                        'Cash Flow - 12 Months Actual',
                        'Cash Flow - 12 Months Actual or Budget',
                        'Bank Reconciliation - Summarised',
                        'Bank Reconciliation - Detailed',
                        'Payee Spending - Summarised',
                        'Payee Spending - Detailed',
                        'Summarised Coding by Job',
                        'Detailed Coding by Job',
                        'GST Return',                                        { Can be changed by UpdateMF.PAS }
                        'GST calculation sheet 372',
                        'Exception',
                        'Cash Flow - Date to Date',
                        'Cash Flow - Budget Remaining',
                        'Profit and Loss - Date to Date',
                        'Profit and Loss - Budget Remaining',
                        'Profit and Loss - Actual',
                        'Profit and Loss - Actual and last Year',
                        'Profit and Loss - Actual and Budget',
                        'Profit and Loss - Actual, Budget and last Year',
                        'Profit and Loss - Actual, Budget and Variance',
                        'Profit and Loss - 12 Months Actual',
                        'Profit and Loss - 12 Months Actual or Budget',
                        'Profit and Loss - 12 Months Budget',
                        'Profit and Loss - Export',
                        'GST Summary',                                       { Can be changed by UpdateMF.PAS }
                        'GST Allocation Summary',                            { Can be changed by UpdateMF.PAS }
                        'GST Reconciliation',                                { Can be changed by UpdateMF.PAS }
                        'GST Audit',                                         { Can be changed by UpdateMF.PAS }
                        'Budget Listing',
                        'Cash Flow - 12 Months Budget',

                        'Client Header',
                        'Sort Header',
                        'Staff Member Header',
                        'Group Header',
                        'Client Type Header',
                        'Download Report',
                        'Latest Charges',
                        'List Reports Due',
                        'List Admin Bank Accounts',
                        'List Admin Inactive Bank Accounts',
                        'List Provisional Bank Accounts',
                        'List Clients by Staff Member',
                        'List Client Report Options',
                        'Download Log',

                        'Trial Balance',
                        'Income and Expenditure',

                        'Business Activity Statement',
                        'BAS Calculation Sheet',
                        'Off-site Download Log',
                        'Business Norm Percentages Report',
                        'GST Overrides',                                     { Can be changed by UpdateMF.PAS }
                        'List GST Details',                                  { Can be changed by UpdateMF.PAS }
                        'Scheduled Reports Summary',
                        'List Memorisations',
                        'Client Status Report',
                        'Cash Flow - This Year, Last Year and Variance',
                        'Ledger - Summarised',
                        'Client File Access Control',
                        'Cash Flow Single Period',
                        'Cash Flow Multiple Periods',
                        'Profit and Loss Single Period',
                        'Profit and Loss Multiple Periods',
                        'Balance Sheet Single Period',
                        'Balance Sheet Multiple Periods',
                        'Balance Sheet Export',
                        'Summary Download Report',
                        'Unpresented Items',
                        'List Divisions',
                        'List Jobs',
                        'List Sub-groups',
                        'List Entries (incl. Notes)',
                        'Coding - Standard with Notes',
                        'Coding - Two Column with Notes',

                        'Cash Flow Export',
                        'Tasks',
                        'All Open Tasks',
                        'Missing Cheques',

                        'Activity Statement Summary',

                        'Test Fax',

                        'Mail Merge (Print) Summary',
                        'Mail Merge (E-mail) Summary',

                        'Disk Image Documents',
                        'List Charges',

                        'BankLink Client Authority',
                        'BankLink Third Party Authority',

                        'Clients Report',
                        'Client Home Report',
                        'List Groups',
                        'List Client Types',
                        'VAT Return',
                        'Foreign Exchange Report',
                        'Coding Optimisation Report',
                        'Custom Document',
                        'System Accounts',
                        'Audit Report',
                        'ZZZ');
   {$ENDIF}

implementation
//******************************************************************************
end.
