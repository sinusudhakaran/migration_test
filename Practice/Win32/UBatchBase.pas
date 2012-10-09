unit UBatchBase;
//------------------------------------------------------------------------------
{
   Title:       Batched Reports Base

   Description: Place holder for the Batch settings

   Remarks:     The structure allows for named batches, each having a list of Clients
                The Clients hold a list of configured reports.
                This structure allows for management of batches accross multiple (All) Clients

                In the end only a sinle level list per Client is implemented,
                but both levels still available

                The structure still has the option to have it operate more as Sceduled reports.
                Things like Frequency, WillRun and RunDate are


}
//------------------------------------------------------------------------------
interface

uses classes,
     Contnrs,
     OmniXml,
     Controls,
     Menus,
     RZGroupbar,
     VirtualTreeHandler,
     windows,
     Graphics,
     GraphDefs,
     stDate,
//     BatchEmail,
     ReportDefs,
     sysutils;


const GraphBase = 1000;
      CUSTOM_DOC_BASE = 2000;

type
     TBatchRunMode = (R_Normal, R_Setup, R_Batch, R_BatchAdd);
 {
type
   TReportFrequency = (
       F_Monthly,
       F_TwoMonthly,
       F_Quarterly,
       F_SixMonthly,
       F_Annually
     );

const
   DefaultFrequency = F_Monthly;

type
   TReportPeriod = (
       P_Current,
       P_Prev
      );

const
   DefaultPeriod = P_Current;
   DefaultMonth  = 1;

type
   TReportDates = (
       D_None,
       D_Date,
       D_FromTo,
       D_YearTo );

const
   DefaultDates  = D_FromTo;
  }

type


TBatchReportList = class;

TReportBase = class (TTreeBaseItem)
// Base item, representing each client report ast part of a batched report
private
    //FCopies: Integer;
    FUser: string;
    FLastRun: TDateTime;
    FParent: TReportBase;
    FSettings: IxmlNode;
    // FID: Integer;
    // FDestination: Integer;
    FChanged: Boolean;
    FName: string;
    FRunResult: string;
    //FRunDate: Integer;
    //FSetupOnly: Boolean;
    FOnReportStatus: TNotifyEvent;
    FRundateFrom: Integer;
    FRundateTo: Integer;
    {
    FRun : Boolean;
    FFrequency: TReportFrequency;
    FPeriod: TReportPeriod;
    FEndMonth: Integer;
    fDatesText : string;
    }
    FLockCount : integer;
    {
    FDestinationFile: Integer;
    }
    FBatchReportList: TBatchReportList;
    FSaved: Boolean;
    FRunFileLocation: string;
    FRunDestination: string;
    FSelected: Boolean;
    FCreatedby: string;
    FCreatedon: TDateTime;
    FBatchRunMode: TBatchRunMode;
    FRunBtn: Integer;
    FRunFileName: string;
    procedure SetParent(const Value: TReportBase);
    //procedure SetCopies(const Value: Integer);
    procedure SetLastRun(const Value: TDateTime);
    procedure SetUser(const Value: string);
    function DateText (const Value : TDateTime) : string;
    procedure SetSettings(const Value: IxmlNode);
    //procedure SetID(const Value: Integer);
    //function GetID : Integer;
    {
    procedure SetDestination(const Value: Integer);
    procedure SetDestinationText(const Value: string);
    function GetDestinationText: string;
    }
    procedure OnChanged; virtual;
    procedure SetChanged(const Value: Boolean);
    procedure SetName(const Value: string);
    procedure SetRunResult(const Value: string);
    {
    procedure SetRunDate(const Value: Integer);virtual;
    }
    //procedure SetSetupOnly(const Value: Boolean);
    {
    function GetDestination: Integer;
    }
    procedure SetOnReportStatus(const Value: TnotifyEvent);
    procedure StatusChange;
    {
    function GetFrequencyText: string;
    procedure SetFrequency(const Value: TReportFrequency);
    procedure SetFrequencyText(const Value: string);
    //function GetPeriod: TReportPeriod;
    function GetPeriodText: string;
    procedure SetPeriod(const Value: TReportPeriod);
    procedure SetPeriodText(const Value: string);
    procedure SetEndMonth(const Value: Integer);
    procedure SetEndMonthText(const Value: string);
    function GetEndMonthText: string;
    }
    procedure Update; virtual;
    //procedure SetDestinationFile(const Value: Integer);
    procedure SetBatchReportList(const Value: TBatchReportList);
    //function GetEndMonth: Integer;
    procedure SetRundateFrom(const Value: Integer);
    procedure SetRundateTo(const Value: Integer);
    function GetDatesText: string;
    procedure SetSaved(const Value: Boolean);
    procedure SetRunDestination(const Value: string);
    procedure SetRunFileLocation(const Value: string);
    procedure SetSelected(const Value: Boolean);
    procedure SetCreatedby(const Value: string);
    procedure SetCreatedon(const Value: TDateTime);
    procedure SetBatchRunMode(const Value: TBatchRunMode);
    procedure SetRunBtn(const Value: Integer);
    procedure SetRunFileName(const Value: string);
protected

public
    constructor Create (const Value : IxmlNode = nil;
                        const AParent : TReportBase = nil;
                        const ABatchReportList : TBatchReportList = nil);
    // manage settings
    function GetSettingsBool (const Name : string; Default : boolean) : Boolean;
    procedure SetSettingsBool (const Name : string; Value : Boolean);
    function GetSettingsText (const Name, Default : string): string;
    procedure SetsettingsText (const Name, Value : string);
    // Saved Properties
    //property ID : Integer read GetID write SetID;
    property Settings : IxmlNode read FSettings write SetSettings;
    property Parent: TReportbase read FParent write SetParent;
    property BatchReportList: TBatchReportList read FBatchReportList write SetBatchReportList;
    property Name: string read FName write SetName;
    property LastRun: TDateTime read FLastRun write SetLastRun;
    property RunResult: string read FRunResult write SetRunResult;
    property RunBtn: Integer read FRunBtn write SetRunBtn;
    property RunDestination: string read FRunDestination write SetRunDestination;
    property RunFileLocation: string read FRunFileLocation write SetRunFileLocation;
    property RunFileName: string read FRunFileName write SetRunFileName;
    property User: string read FUser write SetUser;
    property Createdby: string read FCreatedby write SetCreatedby;
    property Createdon: TDateTime read FCreatedon write SetCreatedon;
    property BatchRunMode: TBatchRunMode read FBatchRunMode write SetBatchRunMode;
    //property Copies : Integer read FCopies write SetCopies;

    //property Frequency : TReportFrequency read FFrequency write SetFrequency;
    //property FrequencyText : string read GetFrequencyText write SetFrequencyText;

    //property Destination : Integer read GetDestination write SetDestination;
    //property DestinationText : string read GetDestinationText write SetDestinationText;
    //property DestinationFile : Integer read FDestinationFile write SetDestinationFile;
    //property Period :TReportPeriod read FPeriod write SetPeriod;
    //property PeriodText : string read GetPeriodText write SetPeriodText;
    //property EndMonth : Integer read GetEndMonth write SetEndMonth;
    //property EndMonthText : string read GetEndMonthText write SetEndMonthText;
    property RundateFrom : Integer read FRundateFrom write SetRundateFrom;
    property RundateTo : Integer read FRundateTo write SetRundateTo;
    property Saved : Boolean read FSaved write SetSaved;

    // Local/Temp properties
    //property RunDate : Integer read fRunDate write SetRunDate;
    //property DatesText : string read fDatesText;
    property DatesText : string read GetDatesText;
    //property WillRun : Boolean read fRun;
    //property SetupOnly : Boolean read FSetupOnly write SetSetupOnly;
    //procedure PassOn (ToBase : TReportBase); //Could use Set methode to do child..
    property Selected: Boolean read FSelected write SetSelected;
    // management
    property OnReportStatus : TnotifyEvent read FOnReportStatus write SetOnReportStatus;
    property Changed : Boolean read FChanged write SetChanged;
    procedure Lock;
    procedure Unlock;

    //function GetText (Value : Integer):string; virtual; // So you can use column tag direct..
    function GetTagText(const Tag : Integer) : string; override;
    function SaveToNode   (Value : IxmlNode) : Boolean; virtual;
    function ReadFromNode (Value : IxmlNode) : Boolean; virtual;
    procedure Clear; virtual;

    procedure DoubleClickTag(const Tag: Integer; Offset: TPoint); override;
    procedure ClickTag(const Tag: Integer; Offset: TPoint; Button: TMouseButton; Shift:TShiftstate ); override;
    procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);override;
end;


TReportClient = class (TReportBase)
// This represents a Client in the Batch report Tree,
// It holds all the reports for a client, in a Batch
private
    fList : tObjectlist;
    function GetChild(index: integer): TReportBase;
    procedure SetChild(index: integer; const Value: TReportBase);
    //function GetLastIDs (Value : Integer): Integer;
    procedure OnChanged; override;
    //procedure Update; override;
public
    constructor Create (const Value : IxmlNode = nil;
                        const AParent : TReportBase = nil;
                        const ABatchReportList : TBatchReportList = nil );
    destructor Destroy; override;
    property List :  tObjectlist read fList;
    property Child [index: integer] : TReportBase read GetChild write SetChild;
    function AddChild (Value: IxmlNode; ABatchReportList: TBatchReportList): TReportBase; virtual;
    function ChildName : string; virtual;
    function SaveToNode   (Value : IxmlNode) : Boolean; override;
    function ReadFromNode (Value : IxmlNode) : Boolean; override;
    procedure Clear; override;
    procedure ClearSelection;
    procedure SelectAll;
    function NewName(Base: string = 'Favourite'): string;
    function FindReportName(Value: string): TReportBase; virtual;
    //procedure SetRunDate(const Value: Integer);override;
end;

   (*
TReportBatch = class (TReportClient)
// This represents a Batch, in the Btachlist
// It holds a list of clients,
private
public
    function AddChild (Value : IxmlNode;ABatchReportList : TBatchReportList) : TReportBase; override;
    function ChildName : string; override;
end;
     *)
TBatchReportList = class (TReportClient)
// This represents All the Batches
// It holds a list of Batches
private
    //FFileName: TFilename;
    fDocument : IXMLDocument;
    //FLastID: Integer;
    //FEmailList : TBatchEmailList;
    //procedure SetFileName(const Value: TFilename);
    //procedure ReadFromFile;
    //procedure SaveToFile;
    //procedure MakeBackup(const NewExt : string);
    //function MakeNewID : Integer;
    //procedure SetLastID(const Value: Integer);
    FSelected: TObjectlist;
    function GetXMLString: string;
    procedure SetXMLString(const Value: string);
    procedure RunMenu(Sender: TObject);

public
    constructor Create (const AFilename : tFilename);
    destructor Destroy; override;
    //property FileName : TFilename read FFileName write SetFileName;
    //property LastID : Integer read FLastID write SetLastID;
    property Document : IXMLDocument read fDocument;

    function AddChild (Value : IxmlNode;ABatchReportList : TBatchReportList) : TReportBase; override;
    function ChildName : string; override;
    property XMLString: string read GetXMLString write SetXMLString;
    function FindReportName(Value: string): TReportBase; override;

    function NewReport(Value: string): TReportBase;

    procedure FillMenu(Value: TMenuItem; IncludeFinancialReports: Boolean);

    procedure RunReport(Value: TReportBase); overload;
    procedure RunReport(Value: string); overload;
    procedure RunReports(Sender: TObject);
    property Selected: TObjectList read FSelected;
    class function IsReportFinancialReport(ReportType: REPORT_LIST_TYPE): boolean; static;

    //overall report handeling
    //procedure RunStart;
    //procedure RunDone;
    //Email Handeling
    //property EmailList : TBatchEmailList read FEmailList;
end;

const
  // For the GetText function
  gt_Title       = 0;
  //gt_Frequency   = 1;
  gt_LastRun     = 2;
  //gt_NextDue     = 3;
  gt_Copies      = 5;
  gt_User        = 6;
  //gt_Destination = 7;
  gt_Name        = 8;
  gt_Result      = 9;
  //gt_Period      = 10;
  gt_Dates       = 11;
  //gt_EndMonth    = 12;
  gt_BatchRun    = 13;
  //gt_ID          = 14;
  gt_FullName    = 15;
  gt_RunDest     = 16;
  gt_Selected    = 17;
  gt_CreatedBy   = 18;
  gt_CreatedOn   = 19;


// Text for Destination..

const
  t_Screen            = 'Screen';
  t_Printer           = 'Printer';

  t_File              = 'File';
  t_Ask               = 'Ask';
  t_Setup             = 'Setup';
  t_None              = 'None';
  t_Email             = 'Email';
  t_Fax               = 'Fax';
  t_Ecoding           = 'Ecoding';
  t_CSVExport         = 'CSVExport';
  t_WebX              = 'WebX';
  t_CheckOut          = 'CheckOut';
  t_BusinessProduct   = 'BusinessProduct';


  t_CSVFile           = 'Comma seperated File';
  t_FixedFile         = 'Fixed width text File';
  t_Abode             = 'PDF File';


const
  // Report levels, so we know whats 'behind the tree(item)'

  l_Root    = 0; // Nothing
  l_Batch   = 1;
  l_Client  = 2;
  l_Report  = 3;
  l_Setting = 4;


// Translation funtions
// Could/Shoul make them Metodes of TReportBase
// but a ReportBase may not always be available...
{
function Get_FrequencyText (Value : TReportFrequency): string;overload;
function Get_FrequencyText (Value : Integer): string;overload;

function Get_PeriodText (Value : TReportPeriod): string;overload;
function Get_PeriodText (Value : Integer): string;overload;
}
function Get_ReportText (Value: REPORT_LIST_TYPE): string;overload;
function Get_ReportText (Value: Integer): string;overload;
function Get_ReportListType (Value: string) : REPORT_LIST_TYPE;

function Get_GRAPHLISTType (Value: string) :  GRAPH_LIST_TYPE;

function Get_ReportName(Value: REPORT_LIST_TYPE): string;overload;
function Get_ReportName(Value: GRAPH_LIST_TYPE): string;overload;
function Get_ReportName(Value: Integer): string;overload;

function Get_ReportType (Value: string): Integer;
{

function Get_ReportDates (Value : REPORT_LIST_TYPE) : TReportDates;
}
function Get_DestinationText (Value : TReportDest): string;overload;
function Get_DestinationText (Value : Integer): string;overload;
function Get_DestinationType (Value : string) : TReportDest; overload;
function Get_DestinationType (Value : integer) : TReportDest; overload;

function GetReportLevel (Value : TTreeBaseItem): Integer;

// Changed to "Yes" and "No"  to make it more 'Man readable'
function  GetNodeBool (Node : IxmlNode; const TagName :string; default : boolean) : Boolean;
procedure SetNodeBool (Node : IxmlNode; const TagName :string; Value : boolean);

// Date Related
function Get_Month (date : TStdate): Integer;
function Get_MonthText (date : TstDate): string;


function BatchReports: TBatchReportList;


implementation

uses BatchReportFrm,
     DateUtils,
     bkDateUtils,
     bkConst,
     stdatest,
     Basfrm,
     GST101Frm,
     BalanceSheetOptionsDlg,
     ProfitAndLossOptionsDlg,
     CashflowOptionsDlg,
     TrialBalanceOptionsDlg,
     imagesfrm,
     UpdateMF,
     math,
     Graphs,
     Reports,
     Globals,
     rptParams,
     omniXMLutils,
     StrUtils,
     VatReturn,
     CustomDocEditorFrm;

var
  FBatchReports: TBatchReportList;

function BatchReports: TBatchReportList;
begin
   if not assigned(FBatchReports) then
      FBatchReports := TBatchReportList.Create('');
   Result := FBatchReports;
end;

// Basic Tag Names
const
  t_BatchList   = 'BatchList';
  t_Batch       = 'Batch';
  t_Report      = 'Report';
  t_Version     = 'Version';
  t_User        = 'User';
  t_Client      = 'Client';
  t_LastRun     = 'LastRun';
  t_Copies      = 'Copies';
  t_Destination = 'Destination';
  t_Title       = 'Title';
  t_Frequency   = 'Frequency';
  t_Period      = 'Period';
  t_ID          = 'ID';
  t_LastID      = 'LastID';
  t_Name        = 'Name';
  t_Settings    = 'Settings';
  t_Result      = 'Result';
  t_RunDest     = 'LastDestination';
  t_FileLoc     = 'FileLocation';

  t_EndMonth    = 'EndMonth';
  t_Ok          = 'Ok'; // is not a tag but default result..

  t_RunFromDate = 'RunFrom';
  t_RunToDate   = 'RunTo';
  t_CreatedBy   = 'CreatedBy';
  t_CreatedOn   = 'CreatedOn';

  t_Picture     = 'dd/mm/yyyy'; // Format for the StDate


  // Text for Frequency..
const
  t_Monthly           = 'Monthly';
  t_TwoMonthly        = 'TwoMonthly';
  t_Quarterly         = 'Quarterly';
  t_SixMonthly        = 'SixMonthly';
  t_Annually          = 'Annually';

// Text for Period
  t_Current           = 'Current';
  t_Prev              = 'Prev';
  t_Next              = 'Next';



(*
function Get_FrequencyText (Value : TReportFrequency): string;
begin
   case Value of
   F_TwoMonthly    : Result := t_TwoMonthly;
   F_QuarterLy     : Result := t_Quarterly;
   F_SixMonthly    : Result := t_SixMonthly;
   F_Annually      : Result := t_Annually;
   else              Result := t_Monthly;
   end;
end;

function  Get_FrequencyText (Value : integer): string;
begin
  if (Value >= 0)
  and (Value <= ord(High(TReportFrequency))) then
     Result := Get_FrequencyText( TReportFrequency(Value))
  else
     Result := '';
end;


function Get_PeriodText (Value : integer): string;
begin
  if (Value >= 0)
  and (Value <=  ord(High (TReportPeriod))) then
     Result := Get_PeriodText( TReportPeriod(Value))
  else
     Result := '';
end;

function Get_PeriodText (Value : TReportPeriod): string;
begin
   case Value of
      P_Prev    :  Result := t_Prev;
      P_Current :  Result := t_Current;
      else         Result := t_current;
   end;
end;

*)


function Get_ReportText (Value : REPORT_LIST_TYPE): string;
begin
   // need to catch some extra BAS ones...
   case Value of
      REPORT_BASSUMMARY :  Result := 'Annual GST information report';
      Report_GST372 : Result := 'Annual GST Return';
   else Result :=  REPORT_LIST_NAMES [Value];
   end;
end;

function Get_ReportName(Value: Integer): string;
begin
  if (Value >= 0)
  and (Value < ord(Report_Last)) then
     Result :=  Get_ReportName (REPORT_LIST_TYPE(Value))
  else if (Value >= GraphBase)
       and (Value < (GraphBase + ord(Graph_Last))) then
     Result := Get_ReportName( GRAPH_LIST_TYPE (Value - GraphBase))
  else
     Result := '';
end;

function Get_ReportName(Value: GRAPH_LIST_TYPE): string;
begin
  Result := GRAPH_LIST_NAMES[Value];
end;

function Get_ReportName(Value : REPORT_LIST_TYPE): string;overload;
begin
   case Value of
      {
      Report_List_Chart:;
      Report_List_Entries:;
      Report_List_Journals: ;
      Report_List_BankAccts: ;
      Report_List_Payee: ;
      }
      Report_List_Ledger,
      Report_Summary_List_Ledger : Result := 'Ledger';

      Report_Coding,
      Report_Coding_Standard,
      Report_Coding_TwoCol,
      Report_Coding_Details,
      Report_Coding_Standard_With_Notes,
      Report_Coding_TwoCol_With_Notes,
      Report_Coding_Anomalies : Result := 'Coding';
        {
      Report_Cashflow_Act,
      Report_Cashflow_ActBud,
      Report_Cashflow_ActBudVar,
      Report_Cashflow_12Act,
      Report_Cashflow_Date,
      Report_Cashflow_BudRem,
      Report_Cashflow_ActLastYVar,
      Report_Budget_12CashFlow,
      Report_Cashflow_12ActBud: Result := 'Cash Flow';
         }

      Report_Cashflow_Single,
      Report_Cashflow_Multiple : Result := 'Cash Flow';

      Report_BankRec_Sum,
      Report_BankRec_Detail: Result := 'Bank Reconciliation';

      Report_Payee_Spending,
      Report_Payee_Spending_Detailed: Result := 'Payee Spending';

      Report_Job_Summary,
      Report_Job_Detailed: Result := 'Coding by Job';
      {
      Report_GST101: ;
      Report_GST372: ;
      Report_Exception: ;
      }
      {
      Report_Profit_Date,
      Report_Profit_BudRem,
      REPORT_Profit_ACT,
      REPORT_Profit_ACT_LY,
      Report_Profit_ActBud,
      Report_Profit_ActBud_LY,
      Report_Profit_ActBudVar,
      Report_Profit_12Act,
      Report_Profit_12ActBud,
      Report_Profit_Export: Result := 'Profit and Loss';
      }
      Report_ProfitandLoss_Single,
      Report_ProfitandLoss_Multiple: Result := 'Profit and Loss';

      {
      Report_GST_Summary: ;
      Report_GST_allocationSummary: ;
      Report_GST_Summary_12: ;
      Report_GST_Audit: ;

      Report_Budget_Listing: ;


      Report_Client_Header: ;
      Report_Staff_Member_Header: ;
      Report_Download: ;
      Report_Admin_Charges: ;
      Report_WhatsDue: ;
      Report_Admin_Accounts: ;
      Report_Admin_Inactive_Accounts: ;
      Report_Clients_By_Staff: ;
      Report_Client_Report_Opt: ;
      Report_Download_Log: ;
      Report_TrialBalance: ;
      Report_Income_Expenditure: ;
      Report_BAS: ;
      Report_BAS_CAL: ;
      Report_Download_Log_Offsite: ;
      Report_GST_BusinessNorms: ;
      Report_GST_Overrides: ;
      Report_List_GST_Details: ;
      Report_Schd_Rep_Summary: ;
      Report_List_Memorisations: ;
      Report_Client_Status: ;


      Report_File_Access_Control: ;
      }


      Report_BalanceSheet_Single,
      Report_BalanceSheet_Multiple,
      Report_BalanceSheet_Export : Result := 'Balance Sheet';
      {
      Report_Summary_Download: ;
      Report_Unpresented_Items: ;
      Report_List_Divisions: ;
      Report_List_SubGroups: ;
      Report_List_Entries_With_Notes: ;
      Report_Cashflow_Export: ;
      Report_TasksDueForClient: ;
      Report_Missing_Cheques: ;
      Report_BasSummary: ;
      REPORT_TEST_FAX: ;
      REPORT_MAILMERGE_PRINT: ;
      REPORT_MAILMERGE_EMAIL: ;
      Report_Billing: ;
      Report_Charges: ;
      Report_CAF: ;
      Report_TPA: ;
      Report_ClientManager: ;
      Report_ClientHome: ;
      Report_Last: ;
      }

      Report_Taxable_Payments,
      Report_Taxable_Payments_Detailed: Result := 'Taxable Payments';
      
      else begin
         Result := Get_ReportText(value);
      end;
   end;
end;


function Get_ReportText (Value : Integer): string;
begin
  if (Value >= 0)
  and (Value < ord(Report_Last)) then
     result :=  Get_ReportText (REPORT_LIST_TYPE(Value))
  else
     Result := '';
end;

function Get_GRAPHLISTType (Value : string) :  GRAPH_LIST_TYPE;
var I : GRAPH_LIST_TYPE;
begin
    for i := GRAPH_TRADING_SALES to GRAPH_LAST do
       if sametext(GRAPH_LIST_NAMES[i],Value) then begin
          Result := i;
          exit;
       end;
     // Now what....
     Result := GRAPH_LAST;
end;

function Get_ReportListType (Value : string): REPORT_LIST_TYPE;
var i : REPORT_LIST_TYPE;
begin
  if Sametext(Value,'Annual GST information report') then
     Result := REPORT_BASSUMMARY
  else if Sametext(Value,'Annual GST Return') then
     Result := Report_GST372
  else begin
     for i := Report_List_Chart to Report_Last do
       if sametext(REPORT_LIST_NAMES[i],Value) then begin
          Result := i;
          exit;
       end;
     if Sametext(Value,'Ledger') then
        Result := Report_List_Ledger
     else if Sametext(Value,'Coding') then
        Result := Report_Coding
     else if Sametext(Value,'Cash Flow') then
        Result := Report_Cashflow_Single
     else if Sametext(Value,'Bank Reconciliation') then
        Result := Report_BankRec_Sum
     else if Sametext(Value,'Payee Spending') then
        Result := Report_Payee_Spending
     else if SameText(Value, 'Coding by Job') then
        Result := Report_Job_Summary
     else if Sametext(Value,'Profit and Loss') then
        Result := Report_ProfitandLoss_Single
     else if Sametext(Value,'Balance Sheet') then
        Result := Report_BalanceSheet_Single
     else if Sametext(Value,'GST Return 101') then // original title
        Result := Report_GST101
     else if Sametext(Value,'Taxable Payments') then
       Result := Report_Taxable_Payments
     else if Sametext(Copy(Value, 1, Length(CUSTOM_DOC_TITLE)), CUSTOM_DOC_TITLE) then
        Result := Report_Custom_Document
     else

     // Now what....
     Result := Report_Last; // Any better default ??
  end;
end;

function Get_ReportType (Value: string): Integer;
begin
   Result := ord(Get_ReportListType(Value));
   if Result = ord(Report_Last) then
       Result := ord(Get_GRAPHLISTType(Value)) + GraphBase;
end;


 (*
function Get_ReportDates (Value : REPORT_LIST_TYPE) : TReportDates;
begin  // Should only need a subset...
   Result := D_FromTo;
   case Value of
      Report_List_Chart       : Result := D_None;
      Report_List_Entries     : Result := D_FromTo;
      Report_List_Journals    : Result := D_FromTo;
      Report_List_BankAccts,
      Report_List_Payee       : Result := D_None;

      Report_List_Ledger      : Result := D_FromTo;

      Report_Coding,
      Report_Coding_Standard,
      Report_Coding_TwoCol,
      Report_Coding_Details,
      Report_Coding_Anomalies : Result := D_FromTo;

      Report_Cashflow_Act,
      Report_Cashflow_ActBud,
      Report_Cashflow_ActBudVar,
      Report_Cashflow_12Act,
      Report_Cashflow_12ActBud : Result := D_YearTo;

      Report_BankRec_Sum: ;
      Report_BankRec_Detail: ;
      Report_Payee_Spending: ;
      Report_Payee_Spending_Detailed: ;
      Report_GST101: ;
      Report_GST372: ;
      Report_Exception: ;
      Report_Cashflow_Date: ;
      Report_Cashflow_BudRem: ;

      Report_Profit_Date: ;
      Report_Profit_BudRem: ;
      REPORT_Profit_ACT: ;
      REPORT_Profit_ACT_LY: ;
      Report_Profit_ActBud: ;
      Report_Profit_ActBud_LY: ;
      Report_Profit_ActBudVar: ;
      Report_Profit_12Act: ;
      Report_Profit_12ActBud: ;
      Report_Profit_Export: ;

      Report_GST_Summary: ;
      Report_GST_Summary_12: ;
      Report_GST_Audit: ;
      Report_Budget_Listing: ;
      Report_Budget_12CashFlow: Result := D_FromTo;

      Report_Client_Header,
      Report_Staff_Member_Header,
      Report_Download,
      Report_Admin_Charges,
      Report_WhatsDue,

      Report_Admin_Accounts,
      Report_Admin_Inactive_Accounts,
      Report_Clients_By_Staff,
      Report_Client_Report_Opt,
      Report_Download_Log : Result := D_None;

      Report_TrialBalance,
      Report_Income_Expenditure,
      Report_BAS,
      Report_BAS_CAL : Result := D_Date;

      Report_Download_Log_Offsite,
      Report_GST_BusinessNorms : Result := D_None;
      Report_GST_Overrides : Result := D_FromTo;

      Report_List_GST_Details:  Result := D_None;
      Report_Schd_Rep_Summary,
      Report_List_Memorisations,
      Report_Client_Status : Result := D_None;

      Report_Cashflow_ActLastYVar: ;
      Report_Summary_List_Ledger: ;
      Report_File_Access_Control: ;
      Report_Cashflow_Single: ;
      Report_Cashflow_Multiple: ;
      Report_ProfitandLoss_Single: ;
      Report_ProfitandLoss_Multiple: ;
      Report_BalanceSheet_Single: ;
      Report_BalanceSheet_Multiple: ;
      Report_BalanceSheet_Export: ;

      Report_Summary_Download: ;
      Report_Unpresented_Items: ;
      Report_List_Divisions: ;
      Report_List_SubGroups: ;
      Report_List_Entries_With_Notes: ;

      Report_Coding_Standard_With_Notes: ;
      Report_Coding_TwoCol_With_Notes: ;

      Report_Cashflow_Export: ;
      Report_TasksDueForClient: ;
      Report_Missing_Cheques: ;
      Report_BasSummary: ;
      REPORT_TEST_FAX: ;
      REPORT_MAILMERGE_PRINT: ;
      REPORT_MAILMERGE_EMAIL: ;
      Report_Billing: ;
      Report_Charges: ;
   end;
end;
*)

function GetBoolText(Value: string): Boolean;
begin
   Result := sametext(value, 'Yes')
          or sametext(value, '1')
          or sametext(value, 'True')
          or sametext(value, 'On')
end;

function GetNodeBool(Node: IxmlNode; const TagName: string;
  default: boolean): Boolean;
var S : string;
begin
   s := OmniXMLUtils.GetNodeTextStr(Node,TagName,'');
   if S <> '' then
      Result := GetBoolText(s)
   else
      Result := Default;
end;


function SetBoolText(Value: Boolean): string;
begin
  if Value then
    Result := 'Yes' // Works a bit more user friendly
  else
    Result := 'No';
end;

procedure SetNodeBool(Node: IxmlNode; const TagName: string;
  Value: boolean);
begin
   SetNodeText(Node,TagName,SetBoolText(Value));
end;


function Get_DestinationText (Value : TReportDest): string;
begin
case Value of
  rdScreen          : Result := t_Screen;
  rdPrinter         : Result := t_Printer;
  rdFile            : Result := t_File;

  rdAsk             : Result := t_Ask;
  rdSetup           : Result := t_Setup;
  rdNone            : Result := t_None;
  rdEmail           : Result := t_Email;
  rdFax             : Result := t_Fax;
  rdEcoding         : Result := t_Ecoding;
  rdCSVExport       : Result := t_CSVExport;
  rdWebX            : Result := t_WebX;
  rdCheckOut        : Result := t_CheckOut;
  rdBusinessProduct : Result := t_BusinessProduct;
  else Result := t_Printer;
end;
end;

function Get_DestinationText (Value : Integer): string;
begin // can use 'invalid' to get a Blank..
   if (value >= 0)
   and (value <= (ord(rdBusinessProduct))) then
      Result := Get_DestinationText(TReportDest(Value))
   else
      Result := ''; // So we can have Blanks
end;

function Get_DestinationType (Value : integer) : TReportDest;
begin // Always valid...
   if (value >= 0)
   and (value <= (ord(rdBusinessProduct))) then
      Result := TReportDest(Value)
   else
      Result := rdPrinter
end;

function Get_DestinationType (Value : string) : TReportDest;
var I : integer;
begin // Always valid...
   Result := rdPrinter;
   for I := ord(low(TReportDest)) to ord(High(TReportDest)) do
      if sametext(Get_DestinationText(I),Value) then begin
         Result := TReportDest(I);
         Exit;
      end;
end;


function GetReportLevel (Value : TTreeBaseItem): Integer;
begin
   Result := l_Root;
   if assigned(Value) then begin
      //if Value is TReportBatch  then Result := l_Batch else
      if Value is TReportClient then Result := l_Client else
      if Value is TReportBase   then Result := l_Report; //?? It better be...
   end;
end;

function Get_Month (date : TStdate): Integer;
var Day, Month, Year : Integer;
begin
   StDateToDMY(date,Day, Month, Year);
   Result := Month;
end;

function Get_MonthText (date : TstDate): string;
var Day, Month, Year : Integer;
begin
   StDateToDMY(date,Day, Month, Year);
   result := ShortMonthNames[month] + ' ' + intToStr(Year);
end;


{ TReportBase }

procedure TReportBase.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);

begin
   case Tag of
     gt_Selected :  if Selected then
          AppImages.ilFileActions_ClientMgr.Draw(Canvas, CellRect.Left, CellRect.Top, 21)
       else
          AppImages.ilFileActions_ClientMgr.Draw(Canvas, CellRect.Left, CellRect.Top, 22);
   end;
end;

procedure TReportBase.Clear;
begin
   //Frequency := Monthly;
   LastRun := 0;
   Title := '';
   User := '';
   //Copies := 0; // Could make that 1 ?
   RunResult := '';
   //Destination := ord(rdPrinter);
end;

procedure TReportBase.DoubleClickTag(const Tag: Integer; Offset: TPoint);
var ReportsForm: TfrmBatchReports;
begin
   if Tag <> gt_Selected  then begin
      ReportsForm := TfrmBatchReports(ParentList.Tree.Owner);
      if ReportsForm is TfrmBatchReports then
         ReportsForm.RunReportBase(self);
   end;
end;

procedure TReportBase.ClickTag(const Tag: Integer; Offset: TPoint;
  Button: TMouseButton; Shift: TShiftstate);
begin
  case tag of
    gt_Selected : Selected := not Selected;
  end;
end;

constructor TReportBase.Create(const Value : IxmlNode = nil;
                               const AParent : TReportBase = nil;
                               const ABatchReportList : TBatchReportList = nil );
begin
   inherited Create('',0);
   BatchReportList := ABatchReportList;
   Parent := aParent;
   if Assigned(Value) then
      ReadFromNode(Value);
end;

function TReportBase.DateText(const Value: TDateTime): string;
begin
   Result := formatDateTime('dd/mm/yy', Value);
end;
   (*
function TReportBase.GetFrequencyText: string;
begin
   Result := Get_FrequencyText(FFrequency);
end;
   *)
 {
function TReportBase.GetID: Integer;
begin
   if (FID = 0) then
      if Assigned(BatchReportList ) then
         FID := BatchReportList.MakeNewID;
   Result := FID;
end;
  }
 {
function TReportBase.GetPeriod: TReportPeriod;
begin
   Result := FPeriod;
end;

function TReportBase.GetPeriodText: string;
begin
   Result := Get_PeriodText(FPeriod);
end;
  }

function TReportBase.GetSettingsBool(const Name: string;
  Default: boolean): Boolean;
begin
   Result := GetNodeBool(settings,Name,default);
end;

function TReportBase.GetSettingsText(const Name, Default: string): string;
begin
   Result := GetNodeTextStr(settings,Name,default);
end;

{
function TReportBase.GetEndMonth: Integer;
begin
   if not (FEndMonth in [ 1, 12]) then
      FEndMonth := DefaultMonth;
   Result := FEndMonth;
end;

function TReportBase.GetEndMonthText: string;
begin
   Result := ShortMonthNames[EndMonth];
end;
}

function TReportBase.GetDatesText: string;

begin
   if RunDateFrom <> 0 then
      Result := bkDateUtils.GetDateRangeS(RunDateFrom,RunDateTo)
   else
      Result := '';
end;
 {
function TReportBase.GetDestination: Integer;
begin
   if SetupOnly then
      Result := ord(rdScreen)
   else
      Result := fDestination;
end;

function TReportBase.GetDestinationText: string;
begin
   if TReportDest(FDestination) = rdFile then
      case DestinationFile of
      0 :  Result := t_CSVFile;
      1 :  Result := t_FixedFile ;
      3 :  Result := t_Abode;
      else Result := t_File;
      end
   else
      result := Get_DestinationText(fDestination);
end;
  }

function TReportBase.GetTagText(const Tag: Integer): string;
begin
   Result := '';
   case Tag of
   //gt_Title      : result := Title;
   //gt_Frequency   : Result := GetFrequencyText; // the property wont inherit as expected..
   gt_LastRun     : if lastRun <> 0 then
                      Result := DateText(LastRun)
                    else
                      Result := 'Never';
   //gt_NextDue     : Result := DateText(LastRun); // Still to do..
   //gt_Copies      : if Copies <> 0 then Result := IntToStr(Copies)
   //                 else Result := '';
   gt_User        : Result := User;
   //gt_Destination : Result := DestinationText;
   gt_Name        : Result := Name;
   gt_Result      : if LastRun <> 0 then
                      Result := RunResult
                    else
                      Result := '';
   //gt_Period      : Result := PeriodText;
   gt_Dates       : Result := DatesText;
   //gt_ID          : Result := IntTostr(Id);
   gt_FullName    : begin
                    Result := Title;
                    if fName > '' then
                      Result := Result + ', ' + FName;
                  end;
   gt_BatchRun    : Result := ''; // is 'Drawn'
   gt_RunDest     : begin
                    Result := RunDestination;

                     if sametext( RunDestination, t_File)
                     and (FRunFileLocation > '') then
                        Result := Result + #13 + RunFileLocation
                   end;
   gt_Selected    : Result := '';
   gt_CreatedBy   : Result := CreatedBy;
   gt_CreatedOn   : if CreatedOn <> 0 then
                       Result := DateText(CreatedOn);

   else Result := Title;
   end;
end;

procedure TReportBase.Lock;
begin
   inc(FLockCount);
end;

procedure TReportBase.OnChanged;
begin
    if FChanged then
      if assigned (Parent) then
        Parent.Changed := true;
end;

{
procedure TReportBase.PassOn(ToBase: TReportBase);
begin
  if assigned(Tobase) then begin
     //Tobase.RunDate := RunDate;
     ToBase.SetupOnly := SetupOnly;
  end;
end;
}
function TReportBase.ReadFromNode(Value: IxmlNode): Boolean;
var s : string;
begin
  result := false;
  Lock;
  try
     Clear;
     if assigned(Value) then try
        User          := GetNodeTextStr(Value,t_user,User);
        LastRun       := GetNodeTextDateTime(value, t_lastRun ,lastRun);
        if LastRun <> 0 then begin
           RunDestination  := GetNodeTextStr(Value,t_RunDest,RunDestination);
           RunFileLocation := GetNodeTextStr(Value,t_FileLoc,RunFileLocation);
           RunResult       := GetNodeTextStr(Value,t_Result,t_ok);
        end;
        Title         := GetNodeTextStr(Value,t_Title,Title);
        //Copies        := GetNodeTextInt(Value,t_Copies,Copies);
        //DestinationText := GetNodeTextStr(Value,t_destination,'');
        Name          := GetNodeTextStr(Value,t_Name,Name);
        //FrequencyText := GetNodeTextStr(Value,t_Frequency,'');
        //PeriodText    := GetNodeTextStr(Value,t_Period,'');
        //EndMonthText  := GetNodeTextStr(Value,t_EndMonth,'');
        {
        ID := GetNodeTextInt(Value,t_ID,Fid); // read it first..
        Fid := ID; // The GET will Force it..
        }
        s := Trim(GetNodeTextStr(Value,t_RunFromDate,''));
        if s > '' then
            RunDateFrom  := DateStringToStDate(t_Picture, s, 0 );

        s := Trim(GetNodeTextStr(Value,t_RunTodate,''));
        if s > '' then
            RunDateTo  := DateStringToStDate(t_Picture, s, 0 );


        CreatedOn := GetNodeTextDateTime(value, t_CreatedOn ,0);
        CreatedBy := Trim(GetNodeTextStr(Value,t_CreatedBy,''));

        Settings := EnsureNode(value, t_settings);
        result := true;
        Changed := False;
     except
     end;
  finally
     Unlock;
     Update;
  end;
end;

function TReportBase.SaveToNode(Value: IxmlNode): Boolean;
    // Its a bit odd,
    // The nodes read the 'White Space' But also keep adding to it when writing
    // This is to stop the file from growing Blank lines..
    procedure SaveNode (ANode,AtNode: IxmlNode);
    var lChild : IxmlNode;
    begin
       if ANode.HasChildNodes then begin
          // Add The Children
           AtNode := AtNode.AppendChild(
                   value.OwnerDocument.CreateElement(ANode.NodeName)
                              );

          lChild := ANode.FirstChild;
          while Assigned(LChild) do begin
             //if not Sametext(LChild.NodeName , '#text') then
                 SaveNode(LChild,AtNode);
             lChild := lchild.NextSibling;
          end;
       end else begin
          // Just Add the node
          //if not Sametext(ANode.NodeName , '#text') then
             SetNodeTextStr(AtNode,Anode.NodeName,
                GetNodeTextStr(ANode.ParentNode,ANode.NodeName,'')
                           );
       end;
    end;

begin
  Result := false;
  if Assigned(Value) then try
     if user <> '' then
        SetNodeTextStr(Value,t_user,User);
     if LastRun <> 0 then begin
        SetNodeTextDateTime(value, t_lastRun ,lastRun);
        if (RunResult <> '')
        and (not Sametext(RunResult,t_ok)) then
           SetNodeTextStr(Value,t_Result,RunResult);
        if RunDestination <> '' then
           SetNodeTextStr(Value,t_RunDest,RunDestination);
        if RunFileLocation <> '' then
           SetNodeTextStr(Value,t_FileLoc,RunFileLocation);
     end;
     if Title <> '' then
        setNodeTextStr(Value,t_Title, Title);
     {
     if ID <> 0 Then
        SetNodeTextInt(Value,t_ID,ID);
     }
     {if Copies <> 0 then
        SetNodeTextInt(Value,t_Copies,Copies);}
     {if Destination >= 0 then
        SetNodeTextStr(Value,t_Destination,DestinationText);}
     if Name <> '' then
        SetNodeTextStr(Value,t_Name,Name);
     {if FFrequency <> DefaultFrequency then
        SetNodeTextStr(Value,t_Frequency,FrequencyText);}
     {if FPeriod <> DefaultPeriod then
        SetNodeTextStr(Value,t_Period,PeriodText);}
     {if EndMonth <> DefaultMonth then
        SetNodeTextStr(Value,t_EndMonth,EndMonthtext);}
     if RunDateFrom <> 0 then
        SetNodeText(Value,t_RunFromdate, StDateToDateString(t_Picture,RunDateFrom, True));
     if RunDateTo <> 0 then
        SetNodeText(Value,t_RunTodate, StDateToDateString(t_Picture,RunDateTo, True));

     if CreatedOn <> 0 then
        SetNodeTextDateTime(Value, t_CreatedOn, CreatedOn);

     if CreatedBy <> '' then
        SetNodeTextStr(Value, t_CreatedBy, CreatedBy);

     if assigned(FSettings) then begin
         if Fsettings.HasChildNodes then begin
            //SaveNode(Fsettings,Value);
            Value.AppendChild(FSettings);
         end;
     end;
     result := true;
  except
  end;
end;

procedure TReportBase.SetParent(const Value: TReportBase);
begin
  FParent := Value;
end;

(*
procedure TReportBase.SetPeriod(const Value: TReportPeriod);
begin
   if FPeriod <> Value then begin
      FPeriod := Value;
      Changed := True
   end;
end;

procedure TReportBase.SetPeriodText(const Value: string);
begin
   if Sametext(value,t_Prev) then
      Period := P_Prev
   else if Sametext(value,t_current) then
      Period := P_Current
   else
      Period := DefaultPeriod;

end;
*)
procedure TReportBase.SetRunResult(const Value: string);
begin
  if not SameText(Value,FRunresult) then begin
     FRunResult := Value;
     Changed :=true;
  end;
end;

procedure TReportBase.SetSaved(const Value: Boolean);
begin
  FSaved := Value;
end;

procedure TReportBase.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
end;

procedure TReportBase.SetSettings(const Value: IxmlNode);
begin
  FSettings := Value;
end;

{
procedure TReportBase.SetSetupOnly(const Value: Boolean);
begin
  FSetupOnly := Value;
end;
}

(*
procedure TReportBase.SetEndMonth(const Value: Integer);
begin
  if Value in [1..12] then
     FEndMonth := Value
  else FEndMonth := DefaultMonth;
end;

procedure TReportBase.SetEndMonthText(const Value: string);
var I : Integer;
begin
   for I := 1 to 12 do
     if SameText(Value,LongMonthNames[i]) then begin
        EndMonth := I;
        Exit;
     end;
   for I := 1 to 12 do
     if SameText(Value,ShortMonthNames[i]) then begin
        EndMonth := I;
        Exit;
     end;
   EndMonth := DefaultMonth;
end;
*)
procedure TReportBase.SetsettingsBool(const Name: string; Value: Boolean);
begin
   SetNodeBool(Settings,name,Value);
end;

procedure TReportBase.SetsettingsText(const Name, Value: string);
begin
   SetNodeTextStr(Settings,name,Value);
end;

procedure TReportBase.SetBatchReportList(const Value: TBatchReportList);
begin
  FBatchReportList := Value;
end;

procedure TReportBase.SetBatchRunMode(const Value: TBatchRunMode);
begin
  FBatchRunMode := Value;
end;

procedure TReportBase.SetChanged(const Value: Boolean);
begin
  if value
  and (FLockCount = 0) then begin
     Update;
     Statuschange;
  end;

  if FChanged <> Value then begin
     FChanged := Value;
     OnChanged;
  end;
end;

procedure TReportBase.SetCreatedby(const Value: string);
begin
  FCreatedby := Value;
end;

procedure TReportBase.SetCreatedon(const Value: TDateTime);
begin
  FCreatedon := Value;
end;

{
procedure TReportBase.SetCopies(const Value: Integer);
begin
  if FCopies <> Value then begin
     FCopies := Value;
     Changed := True;
  end;
end;
}

{
procedure TReportBase.SetDestination(const Value: Integer);
begin
  if FDestination <> Value then begin
     FDestination := Value;
     Changed := True;
  end;
end;
}
{
procedure TReportBase.SetDestinationFile(const Value: Integer);
begin
  if FDestinationFile <> Value then begin
     FDestinationFile := Value;
     Changed := True;
  end;
end;
}
{
procedure TReportBase.SetDestinationText(const Value: string);
begin
  if value = '' then begin
     Destination := -1;
     DestinationFile := 0;
  end else begin
     if SameText(Value,t_CSVFile) then begin
        Destination  := ord(rdFile);
        DestinationFile := 0;
     end else if SameText(Value,t_FixedFile) then begin
        Destination  := ord(rdFile);
        DestinationFile := 1;
     end else if SameText(Value,t_Abode) then begin
        Destination  := ord(rdFile);
        DestinationFile := 3;
     end else begin
        Destination := Integer(Get_DestinationType(Value));
        DestinationFile := 0;
     end;
  end;
end;
}
{
procedure TReportBase.SetFrequency(const Value: TReportFrequency);
begin
  if FFrequency <> Value then begin
     FFrequency := Value;
     Changed := true;
  end;
end;

procedure TReportBase.SetFrequencyText(const Value: string);
begin
   if SameText(Value,t_Monthly) then
      Frequency := F_Monthly
   else if SameText(Value,t_TwoMonthly) then
      Frequency := F_TwoMonthly
   else if SameText(Value,t_Quarterly) then
      Frequency := F_Quarterly
   else if SameText(Value,t_TwoMonthly) then
      Frequency := F_TwoMonthly
   else if SameText(Value,t_Annually) then
      Frequency := F_Annually
   else
      Frequency := DefaultFrequency;
end;
}
{
procedure TReportBase.SetID(const Value: Integer);
begin
  if FID <> Value then begin
     FID := Value;
     Changed := True;
  end;
end;
}
procedure TReportBase.SetLastRun(const Value: TDateTime);
begin
  if FLastRun <> Value then begin
     FLastRun := Value;
     Changed := True;
  end;
end;


procedure TReportBase.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TReportBase.SetOnReportStatus(const Value: TnotifyEvent);
begin
  FOnReportStatus := Value;
end;


{
procedure TReportBase.SetRunDate(const Value: Integer);
begin
  if Value <> FRundate then begin
     FRunDate := Value;
     Changed := true;
  end;
end;
}

procedure TReportBase.SetRunBtn(const Value: Integer);
begin
  FRunBtn := Value;
end;

procedure TReportBase.SetRundateFrom(const Value: Integer);
begin
  if FRundateFrom <> Value then begin
     FRundateFrom := Value;
     Changed := True;
  end;
end;

procedure TReportBase.SetRundateTo(const Value: Integer);
begin
  if FRundateTo <> Value then begin
     FRundateTo := Value;
     Changed := True;
  end;
end;

procedure TReportBase.SetRunDestination(const Value: string);
begin
  if not sametext(FRunDestination, Value) then begin
     FRunDestination := Value;
     Changed := True;
  end;
end;

procedure TReportBase.SetRunFileLocation(const Value: string);
var lv : string;
begin
  if pos('.',Value) <> 0 then
     lv := ExtractFilePath(Value)
  else
     lv := Value;

  if not sametext(lv,FRunFileLocation) then begin
     FRunFileLocation := lv;
     Changed := True;
  end;
end;

procedure TReportBase.SetRunFileName(const Value: string);
begin
  FRunFileName := Value;
end;

procedure TReportBase.SetUser(const Value: string);
begin
  if not (FUser = Value) then begin
     FUser := Value;
     Changed := True;
  end;
  FUser := Value;
end;


procedure TReportBase.StatusChange;
   procedure CheckParent ( Value : TReportBase);
   begin
      if assigned(Value) then begin
         if assigned(value.OnReportStatus) then
            value.OnReportStatus(Self);
         CheckParent(Value.FParent);
      end;
   end;
begin
   if assigned(OnReportStatus) then
      OnReportStatus(Self);
    CheckParent(fparent);
end;

procedure TReportBase.Unlock;
begin
   if FLockCount > 0 then dec(FLockCount);
   if FLockCount = 0 then
      if Changed then begin
        Update;
        Statuschange;
      end;
end;

procedure TReportBase.Update;
(*
var Day, Month, Year, EMonth : integer;
    Dates : TReportdates;

    procedure FillData;
    begin
         StDateToDMY(FRundate,Day, Month, Year);
         case fPeriod of
            P_Current:;
            P_Prev : begin
                   if Month > 1 then Dec(Month)
                   else begin
                      Month := 12;
                      Dec(Year);
                   end;
                   day := Min( DaysInAMonth(Year,Month) ,Day);
               end;
         end;
    end;

    procedure FindPeriod (Len : Integer);
    begin
       FillData;
       EMonth := EndMonth mod Len;
       while EMonth < Month do Inc(EMonth,Len);
       if Emonth > 12 then begin
          Dec(Emonth,12);
          Inc(Year);
       end;
       FRunDateTo   := DMYtoStDate( DaysInAMonth(Year,EMonth), EMonth, Year, 0);
       if Emonth >= Len then begin
          // Both dates in the same calender year
          fDatesText := ShortMonthNames[Emonth - Pred(Len)]
                     + '-' + ShortMonthNames[Emonth]
                     + ' ' + IntToStr(Year);

          fRunDateFrom := DMYtoStDate(1,Emonth - Pred(Len), Year, 0);
       end else begin
          // not in the same calender year
          fDatesText := ShortMonthNames[(13-Len)+ EMonth] + ' ' +  IntToStr(Pred(Year))
                      + '-' + ShortMonthNames[Emonth] + ' ' + IntToStr(Year);
          fRunDateFrom := DMYtoStDate(1,(13-Len)+ EMonth , Pred(Year), 0);
       end;
       fRun := (Month = EMonth);
    end;
  *)
begin
  // Re-Set the vars
  Exit;
  (*
  if fRunDate = 0 then
    fRundate := CurrentDate;
  FDatesText   := '';

  FRundateFrom := 0;
  FRundateTo   := 0;
  FRun         := True;
  Dates :=  Get_ReportDates( Get_ReportListType(Title));
  case Dates of
     D_None: Exit; // Done

     D_Date: begin
           FDatesText   := StDateToDateString('DD MMM YYYY', fRundate,True);
           FRundateFrom := fRundate;
           Exit;
         end;
  end;


  case frequency of
     F_Monthly: begin
               FillData;
               fDatesText := ShortMonthNames[month]
                          + ' ' + IntToStr(Year);
               FRunDateFrom := DMYtoStDate(1, Month, Year, 0);
               FRunDateTo   := DMYtoStDate( DaysInAMonth(Year,Month), Month, Year, 0);
            End;
     F_TwoMonthly: begin
            FindPeriod (2);
         end;
     F_Quarterly: begin
            FindPeriod (3);
            fDatesText := fDatesText + ' Quarter';
         end;
     F_SixMonthly: begin
            FindPeriod (6);
         end;
     F_Annually: begin
            FindPeriod (12);
            fDatesText := fDatesText + ' Year';
         end;
  end;
  *)
end;


{ TReportBatch }
   {
function TReportBatch.AddChild(Value: IxmlNode;ABatchReportList : TBatchReportList): TReportBase;
begin
   Result := TReportClient.Create(Value,Self,ABatchReportList);
   fList.Add(Result);
end;

function TReportBatch.ChildName: string;
begin
   Result := t_Client;
end;
    }

{ TBatchReportList }

function TBatchReportList.AddChild(Value: IxmlNode;ABatchReportList: TBatchReportList): TReportBase;
begin
   //Result := TReportBatch.Create(Value,Self,ABatchReportList);
   Result := TReportClient.Create(Value,Self,ABatchReportList);
   fList.Add(Result);
end;

function TBatchReportList.ChildName: string;
begin
  Result := T_Batch;
end;


constructor TBatchReportList.Create(const AFilename: tFilename);
begin
  inherited create(nil,nil,nil);
  BatchReportList := Self; // I only exsist AFTER Create...
  fDocument := CreateXMLDoc;
  FSelected := TObjectlist.Create(False);
  //FileName := AFilename;
 // FEmailList := TBatchEmailList.Create(True);
end;

destructor TBatchReportList.Destroy;
begin
  //FileName := ''; // forces a save if required..
  fDocument := nil;
  //FEmailList.Free;
  FSelected.Free;
  inherited;
end;

class function TBatchReportList.IsReportFinancialReport(ReportType: REPORT_LIST_TYPE): boolean;
begin
  Result := ReportType in [
                        REPORT_Profit_ACT,
                        REPORT_Profit_ACT_LY,
                        Report_Profit_ActBud,
                        Report_Profit_ActBud_LY,
                        Report_Profit_ActBudVar,
                        Report_Cashflow_Date,
                        Report_Cashflow_BudRem,
                        Report_Profit_Date,
                        Report_Profit_BudRem,
                        Report_Profit_12Act,
                        Report_Profit_12ActBud,
                        Report_Profit_Export,
                        Report_ProfitandLoss_Single,
                        Report_ProfitandLoss_Multiple,
                        Report_Cashflow_Act,
                        Report_Cashflow_ActBud,
                        Report_Cashflow_ActBudVar,
                        Report_Cashflow_12Act,
                        Report_Cashflow_12ActBud,
                        Report_Cashflow_Single,
                        Report_Cashflow_Multiple,
                        Report_Budget_12CashFlow,
                        Report_Cashflow_ActLastYVar,
                        Report_TrialBalance,
                        Report_BalanceSheet_Single,
                        Report_BalanceSheet_Multiple,
                        Report_BalanceSheet_Export,
                        Report_Cashflow_Export];
end;


procedure TBatchReportList.FillMenu(Value: TmenuItem; IncludeFinancialReports: Boolean);
var I,J: Integer;
    L: TStringList;
    CustomDoc: TReportBase;

   function HandleAmpersand(ReportName: string): string;
   begin
     Result := ReportName;
     if Pos('&', Result) > 0 then begin
       Result := AnsiReplaceStr(Result, '&', '&&');
     end;
   end;
   procedure LAddReportMenu(Report : TReportBase);
   begin
      try
         if Report.GetGUID <> '' then begin
           //Check that custom doc esists
           CustomDoc := CustomDocManager.GetReportByGUID(Report.GetGUID);
           if Assigned(CustomDoc) then
             Report.AddMenuItem(HandleAmpersand(Report.Name),Value,RunMenu);
         end else
           Report.AddMenuItem(HandleAmpersand(Report.Name),Value,RunMenu);
      except // Same name ??
      end;
   end;

   procedure LAddReportList(Report : TReportBase);
   begin
      try
        if IncludeFinancialReports or
          not IsReportFinancialReport(Get_ReportListType(Report.Title)) then
            L.AddObject(HandleAmpersand(Report.Name),Report);
      except
        // Same name ??
      end;
   end;

begin
   Value.Clear;
   L := TStringList.Create;
   try
     for I := 0 to List.Count - 1 do
        with TReportClient(Child[I]) do
          for J := 0 to List.Count - 1 do
             LAddReportList(Child[J]);

     L.Sort;
     for I := 0 to L.Count - 1 do
        LAddReportMenu(TReportBase(l.Objects[I]));

     if Value.Count = 0 then begin
        Value.OnClick := RunReports;
     end else begin
        Value.OnClick := nil;
        AddMenuItem('-',Value,nil);
        AddMenuItem('Manage Favourites',Value,RunReports);
     end;
   finally
     L.Free;
   end;
end;

function TBatchReportList.FindReportName(Value: string): TReportBase;
var I: Integer;
begin
   Result := nil;
   for I := 0 to List.Count - 1 do begin
      Result := TReportClient(Child[I]).FindReportName(Value);
      if assigned(Result) then
         Break;
   end;
end;

function TBatchReportList.GetXMLString: string;
var ln : IXMLNode;
begin
   try try
      fDocument.Text := '';
      ln := EnsureNode(fDocument, t_BatchList);
      SetNodeText(ln,t_version,'1');
      SaveToNode(ln);
   except
   end;
   finally
      Result := string(FDocument.XML  );
   end;
end;


function TBatchReportList.NewReport(Value: string): TReportBase;
var LClient: TReportClient;
begin
   // May need some more work...
   // Get Client Batchlist..
   if List.Count > 0 then begin
      LClient := TReportClient(BatchReports.Child[0]);
   end else begin
      // Add the Base Batch
      LClient := TReportClient(AddChild(nil,Self));
      LClient.Title := 'Reports';
   end;
   Result := TReportBase.Create;
   // setup some defaults
   Result.Lock;
   Result.Createdby := Globals.CurrUser.Code;
   Result.Createdon := Now;
   Result.Settings := Document.CreateElement('Settings');
   Result.BatchRunMode := R_Setup; // Only used as setup..
   Result.Parent := LClient;
   Result.Name := Value;
   LClient.List.Add(Result);
   Result.Unlock;
   UpdateMF.UpdateMenus;
end;

procedure TBatchReportList.RunMenu(Sender: TObject);
var
  ReportName: string;
begin
   if not Assigned(Sender) then
      Exit;
   if Sender is TmenuItem then begin
      //remove any added hotkeys
      BatchRunMode := R_Setup;
      //Remove single '&'  and replace '&&' with '&'
      //'¦' is a non-keyboard char used as a placeholder
      ReportName := TmenuItem (Sender).Caption;
      ReportName := AnsiReplaceStr(ReportName, '&&', '¦');
      ReportName := AnsiReplaceStr(ReportName, '&', '');
      ReportName := AnsiReplaceStr(ReportName, '¦', '&');
      Runreport(ReportName);
   end;
end;

procedure TBatchReportList.RunReport(Value: string);
var LR: TReportBase;
begin
   LR := FindReportName(Value);
   if Assigned(LR) then
      RunReport(LR);
end;

procedure TBatchReportList.RunReports(Sender: TObject);
begin
  RunBatchreports(ByReport);
end;

procedure TBatchReportList.RunReport(Value: TReportBase);
var RptType : REPORT_LIST_TYPE;
    GrphType : GRAPH_LIST_TYPE;

    procedure RunGst;
    var lParams: TRptParameters;
    begin
       lParams := TRptParameters.Create(Ord (RptType),MyClient,Value);
       try
           case RptType of
           Report_GST101,
           Report_BAS :

              case MyClient.clFields.clCountry of
              whNewZealand : begin
                               Value.Title := REPORT_LIST_NAMES[Report_GST101];
                               ShowGST101Form(0,0,lParams);
                           end;
              whAustralia  : begin
                               Value.Title := REPORT_LIST_NAMES[Report_BAS];
                               ShowBasForm(0,0,LParams);
                           end;
              whUK         : begin
                               Value.Title := REPORT_LIST_NAMES[Report_VAT];
                               ShowVATReturn(0,0,LParams);
                           end;
              end;
              //may have locked accounting period so update any coding windows
               // SendCmdToAllCodingWindows( ecRecodeTrans);

           REPORT_BASSUMMARY : case MyClient.clFields.clCountry of
                             whAustralia  : ShowAnnualGSTInformationReport(lParams);
                         end;
           Report_GST372 : case MyClient.clFields.clCountry of
                             whAustralia  : ShowAnnualGSTReturn(lParams);
                         end;
           end;
       finally
         lParams.Free;
       end;
    end;

begin
   try try
      //Value.SetupOnly := True;
      Value.BatchRunMode := Self.BatchRunMode;
      RptType := Get_ReportListType(Value.Title);

      if RptType = Report_Last then begin
         // Could be Grapgh
         GrphType := Get_GraphListType(Value.Title);
         if GrphType <> Graph_Last then
            Graphs.DoGraph(GrphType,Value)
         else
            Value.RunBtn := BTN_Print; //Case 6959,Just Contiue:
      end else

      case RptType of

         Report_List_Chart,
         Report_List_Payee: begin
                      DoReport(RptType,rdScreen,0,Value);
                      Value.RundateFrom := 0;
                      Value.RundateTo := 0;
                    end;
         Report_List_Journals : DoReport(RptType,rdScreen,0,Value);
         Report_List_Entries,
         Report_List_Entries_With_Notes : DoReport(Report_List_Entries,rdScreen,0,Value);

         Report_List_GST_Details,
         Report_List_Divisions,
         Report_List_SubGroups,
         Report_List_bankAccts,
         REPORT_DOWNLOAD_LOG_OFFSITE,
         REPORT_List_Jobs : begin
                      Value.RundateFrom := 0;
                      Value.RundateTo := 0;
                      Reports.DoReport(RptType,rdask,0,Value);
                    end;

         Report_List_Ledger,    // Can use either one in DoReport
         Report_Summary_List_Ledger : DoReport(Report_List_Ledger,rdScreen,0,Value);

         Report_Coding,
         Report_Coding_Standard,
         Report_Coding_TwoCol,
         Report_Coding_Details,
         Report_Coding_Anomalies, // seems is not used..
         Report_Coding_Standard_With_Notes,
         Report_Coding_TwoCol_With_Notes : DoReport(Report_Coding,rdScreen,0,Value);

         Report_Payee_Spending,
         Report_Payee_Spending_Detailed: DoReport(Report_Payee_Spending,rdScreen,0,Value);

         Report_Job_Summary,
         Report_Job_Detailed: DoReport(Report_Job_Summary, rdScreen, 0, Value);

         REPORT_BASSUMMARY,
         Report_GST372,
         Report_GST101,
         Report_BAS  : RunGst;


       {
         Report_Cashflow_Act: ;
         Report_Cashflow_ActBud: ;
         Report_Cashflow_ActBudVar: ;
         Report_Cashflow_12Act: ;
         Report_Cashflow_12ActBud: ;
         Report_BankRec_Sum: ;
         Report_BankRec_Detail: ;
         Report_Exception: ;
         Report_Cashflow_Date: ;
         Report_Cashflow_BudRem: ;

         Report_GST_Summary: ;
         Report_GST_Summary_12: ;
         Report_GST_Audit: ;
         Report_Budget_Listing: ;
         Report_Budget_12CashFlow: ;
         Report_Client_Header: ;
         Report_Staff_Member_Header: ;
         Report_Download: ;
         Report_Admin_Charges: ;
         Report_WhatsDue: ;
         Report_Admin_Accounts: ;
         Report_Admin_Inactive_Accounts: ;
         Report_Clients_By_Staff: ;
         Report_Client_Report_Opt: ;
         Report_Download_Log: ;

         Report_Income_Expenditure: ;
         Report_BAS_CAL: ;
         Report_Download_Log_Offsite: ;
         Report_GST_BusinessNorms: ;
         Report_GST_Overrides: ;

         Report_Schd_Rep_Summary: ;

         Report_Client_Status: ;

         Report_File_Access_Control: ;
         }
         Report_TrialBalance: TrialBalanceOptionsDlg.UpdateTrialBalanceReportOptions(MyClient, Value);

         Report_Cashflow_Single,
         Report_Cashflow_Multiple: CashflowOptionsDlg.UpdateCashflowReportOptions(MyClient,Value);

         REPORT_PROFITANDLOSS_SINGLE,
         REPORT_PROFITANDLOSS_MULTIPLE: ProfitAndLossOptionsDlg.UpdateProfitandLossReportOptions (MyClient,Value);

         Report_BalanceSheet_Multiple,
         Report_BalanceSheet_single : BalanceSheetOptionsDlg.UpdateBalanceSheetOptions(MyClient,Value);

         REPORT_CUSTOM_DOCUMENT : DoReport(REPORT_CUSTOM_DOCUMENT, rdAsk, 0, Value);

         {

         Report_BalanceSheet_Export: ;
         Report_Summary_Download: ;
         Report_Unpresented_Items: ;



         Report_Cashflow_Export: ;
         Report_TasksDueForClient: ;
         Report_Missing_Cheques: ;
         Report_BasSummary: ;
         REPORT_TEST_FAX: ;
         REPORT_MAILMERGE_PRINT: ;
         REPORT_MAILMERGE_EMAIL: ;
         Report_Billing: ;
         Report_Charges: ;
         }
        // Report_Download_Log : DoDownloadLog(rdScreen);

         Report_Taxable_Payments,
         Report_Taxable_Payments_Detailed: DoReport(Report_Taxable_Payments, rdScreen, 0, Value);

        else  DoReport(RptType,rdScreen,0,Value);
      end;

      Changed := True; // ??
   except

   end;
   finally
   end;
end;

(*
procedure TBatchReportList.MakeBackup(const NewExt: string);
begin
   //CopyFile(pChar(fFileName),PChar(ChangeFileExt( fFileName, NewExt)),False);
end;
*)
{
function TBatchReportList.MakeNewID: Integer;
begin
   LastID := LastID + 1;
   Result := LastID;
   Changed := true;
end;
}
(*
procedure TBatchReportList.ReadFromFile;
var ln : IXMLNode;
begin
   clear;
   if fileexists(FFileName) then begin
      try
         // read the file...
         fDocument.Load(fFileName);

         ln := EnsureNode(fDocument, t_BatchList);
         {LastID := GetNodeTextInt(ln,t_LastID,LastID);}
         ReadFromNode(ln);
         {LastID := getLastIDs(LastId);} // Just in case the file is damaged
       except
          fDocument.Text := '';
       end;
    end else begin
       // Will Need these regardless..
       ln := EnsureNode(fDocument, t_BatchList);
       Settings := EnsureNode(LN, t_settings);
    end;
end;
 *)
(*
procedure TBatchReportList.RunDone;
begin

end;

procedure TBatchReportList.RunStart;
begin
   //FEmailList.Clear;
end;
*)
(*
procedure TBatchReportList.SaveToFile;
var ln : IXMLNode;
begin
   try try
      fDocument.Text := '';
      ln := EnsureNode(fDocument, t_BatchList);
      SetNodeText(ln,t_version,'1');
      //SetNodeTextInt(ln,t_LastID,GetLastIDs(LastID)); // Just in case..
      SaveToNode(ln);

      MakeBackup('.bak');
      DeleteFile(pChar(fFilename));
      fDocument.Save(FFileName,ofNone {ofIndent, ofFlat});
   except

   end;
   finally
      Changed := False;
   end;
end;
*)

(*
procedure TBatchReportList.SetFileName(const Value: TFilename);
begin
  if not (sametext( FFileName, Value)) then begin
     // Save changes
     //if (FFileName <> '')
     //and Changed then SavetoFile;

     FFileName := Value;
     //ReadFromFile;
  end;
end;
*)
(*
procedure TBatchReportList.SetLastID(const Value: Integer);
begin
  FLastID := Value;
end;
*)

procedure TBatchReportList.SetXMLString(const Value: string);
begin
   clear;
   fDocument.LoadXML(WideString(value));

   ReadFromNode(EnsureNode(fDocument, t_BatchList));
end;

{ TReportClient }

function TReportClient.AddChild(Value: IxmlNode; ABatchReportList: TBatchReportList): TReportBase;
var tName: string;
begin
   Result := nil;
   if Assigned(Value) then begin//case 6959 valid title first Check First..
      tName := GetNodeTextStr(Value,t_Title,'');
      if tName = '' then
         Exit;
      if Get_ReportListType(tName) = Report_Last then
         if Get_GRAPHLISTType(tName) = Graph_Last then
            Exit;
   end;
   Result := Treportbase.Create(Value,Self,ABatchReportList);
   if (Result.FName = '') then 
      Result.Name := NewName;

   fList.Add(Result);
end;

function TReportClient.ChildName: string;
begin
   result := t_Report;
end;

procedure TReportClient.Clear;
begin
  inherited;
  //Destination := -1;
  FList.Clear;
end;

procedure TReportClient.ClearSelection;
var I: Integer;
begin
  for I := 0 to FList.Count - 1 do begin
    Child[I].Selected := False;
    if Child[I] is TReportClient then
       TReportClient(Child[I]).ClearSelection;

  end;
end;

procedure TReportClient.SelectAll;
var I: Integer;
begin
  for I := 0 to FList.Count - 1 do begin
    Child[I].Selected := True;
    if Child[I] is TReportClient then
       TReportClient(Child[I]).SelectAll;

  end;
end;



constructor TReportClient.Create(const Value : IxmlNode = nil;
                                 const AParent : TReportBase = nil;
                                 const ABatchReportList : TBatchReportList = nil);
begin
   inherited Create;
   fList := TObjectlist.Create(True);

   BatchReportList := ABatchReportList;
   Parent := aParent;

   if assigned(Value) then
      ReadFromNode(Value);
end;

destructor TReportClient.Destroy;
begin
  fList.Free;
  inherited;
end;

function TReportClient.FindReportName(Value: string): TReportBase;
var I: Integer;
begin
   Result := nil;
   for I := 0 to List.Count - 1 do
      if sametext(Child[I].FName, Value) then begin
         Result := Child[I];
         Break;
      end;
end;

function TReportClient.GetChild(index: integer): TReportBase;
begin
   if (Index >= 0)
   and (Index < fList.Count)  then
      Result := TReportBase(fList[Index])
   else
     Result := nil;
end;

function TReportClient.NewName(Base: string = 'Favourite'): string;
var c : Integer;
begin

  Result := Base;
  c := 0;
  while assigned(FindReportName(Result)) do begin
     inc(c);
     Result := Base +  ' (' + intToStr(c) + ')';
  end;
end;

{
function TReportClient.GetLastIDs(Value: Integer): Integer;
var I : integer;
begin
   Result := Max(Value,ID);
   for I := 0 to List.Count - 1 do begin
     Result := Max(Result,Child[I].ID);
     if Child[I] is TReportClient then
        Result := TReportClient(Child[I]).GetLastIDs(Result);
   end;
end;
 }
procedure TReportClient.OnChanged;
var I : Integer;
begin
  if fChanged then inherited
  else for I := 0 to fList.Count - 1 do
      Child[I].Changed := False;
end;

function TReportClient.ReadFromNode(Value: IxmlNode): Boolean;
var LList : IXMLNodeList;
    I : Integer;
begin
  result := false;
  lock;
  try
     if inherited ReadFromNode(Value) then try
        LList := FilterNodes(Value,ChildName);
        if assigned(LList) then begin

          for I := 0 to pred(LList.Length) do
             AddChild(LList.Item[I],BatchReportList);
          LList := nil;
        end;

        Result := true;

     except
     end;
  finally
     Unlock;
     Update;
  end;
end;

function TReportClient.SaveToNode(Value: IxmlNode): Boolean;
var i : integer;
begin
   result := false;
   if inherited SaveToNode (value) then begin
     try

        for I := 0 to fList.Count - 1 do
          if not Child[I].SaveToNode(
               Value.AppendChild(
                   value.OwnerDocument.CreateElement(ChildName)
                                )
                                      ) then
            exit;
        result := true;
     except
     end;
   end else begin
     result := false;
   end;
end;


procedure TReportClient.SetChild(index: integer; const Value: TReportBase);
begin
  if (Index >= 0)
  and (Index < fList.Count)  then
      fList[Index] := Value;
end;
{
procedure TReportClient.SetRunDate(const Value: Integer);
var I : Integer;
begin
  fRunDate :=  Value;
   for I := 0 to fList.Count - 1 do
      Child[I].SetRunDate(Value);
end;

procedure TReportClient.Update;
begin
  //fDatesText := '';
end;
}

initialization
  FBatchReports := nil;
finalization
  if assigned(FBatchReports) then
     FBatchReports.Free;
  FBatchReports := nil;
end.
