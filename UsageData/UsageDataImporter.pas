unit UsageDataImporter;

//------------------------------------------------------------------------------
interface

uses
  Classes,
  DB,
  SqlExpr,
  ExtCtrls;

type
  TServiceState = (usStop          = 1,
                   usStopping      = 2,
                   usStarting      = 3,
                   usWaiting       = 4,
                   usSearching     = 5,
                   usProcessing    = 6);

  TFileState = (fsAdded            = 1,
                fsWaitingForAccess = 2,
                fsTimeOutForAccess = 3,
                fsCleaning         = 4,
                fsErrorCleaning    = 5,
                fsCleaned          = 6,
                fsImporting        = 7,
                fsErrorImporting   = 8,
                fsImported         = 9,
                fsFinnishing       = 10,
                fsErrorFinnishing  = 11,
                fsDone             = 12);

  TFileType = (ftUsageStats = 1,
               ftPractice   = 2);

  TImportLineState = (ilNone             = 1,
                      ilDelimiterError   = 2,
                      ilInsert           = 3,
                      ilUpdate           = 4);

  TFeatureType = (ftNormal          = 1,
                  ftGenerate        = 2,
                  ftFavourite       = 3,
                  ftScheduled       = 4);

  TFeatureDest = (fdNone          = 1,
                  fdView          = 2,
                  fdPrint         = 3,
                  fdFile          = 4,
                  fdEmail         = 5,
                  fdFax           = 6,
                  fdEcoding       = 7,
                  fdCSVExport     = 8,
                  fdWebX          = 9,
                  fdCheckOut      = 10,
                  fdBusProd       = 11,
                  fdCSVFile       = 12,
                  fdTXTFile       = 13,
                  fdXLSXFile      = 14,
                  fdXLSFile       = 15,
                  fdPDFFile       = 16,
                  fdCCHFile       = 17);

  TUsageStates = set of TServiceState;

  //----------------------------------------------------------------------------
  TFileData = class(TObject)
  private
    fName : string;
    fStartTickCount : int64;
    fState : TFileState;
    fFileType : TFileType;
    fError : string;
  protected
    function GetFileTypeName() : string;
  public
    constructor Create;
    destructor Destroy; override;

    property Name : string read fName write fName;
    property StartTickCount : int64 read fStartTickCount write fStartTickCount;
    property State : TFileState read fState write fState;
    property FileType : TFileType read fFileType write fFileType;
    property FileTypeName : string read GetFileTypeName;
    property Error : string read fError write fError;
  end;

  //----------------------------------------------------------------------------
  TFeatureItem = class(TObject)
  private
    fName : string;
    fCount : string;
  public
    property Name : string read fName write fName;
    property Count : string read fCount write fCount;
  end;

  //----------------------------------------------------------------------------
  TUsageDataImporter = class(TObject)
  private
    fBusy : boolean;
    fNumOfSQLStatements : integer;
    fFileDirectory : string;

    fFolderScanTimer : TTimer;

    fCurrentServiceStatus : TServiceState;

    fFilesToProcess : TStringList;

    fSQLConnection : TSQLConnection;
    fSQLDataSet    : TSQLDataSet;
    fSQLQuery      : TSQLQuery;

    fHostName : string;
    fDatabase : string;
    fUserName : string;
    fPassword : string;
  protected
    function GetCleanString(aValue : string) : string;

    procedure AddIntValue(var aResStr : string; aValue : string; aAddComma : boolean; aDefault : string);
    procedure AddStrValue(var aResStr : string; aValue : string; aAddComma : boolean);
    procedure AddDateValue(var aResStr : string; aValue : string; aAddComma : boolean; aDefault : string);

    procedure AddUpdIntValue(aColumn : integer; var aResStr : string; aColumnValues : TStringList; aAddComma : boolean; aDefault : string);
    procedure AddUpdStrValue(aColumn : integer; var aResStr : string; aColumnValues : TStringList; aAddComma : boolean);
    procedure AddUpdDateValue(aColumn : integer; var aResStr : string; aColumnValues : TStringList; aAddComma : boolean; aDefault : string);

    function CleanXML(aInstring: string): string;
    function CleanFeatureName(aInstring: string): string;
    function GetCodingTypeId(aCodingStr: string): integer;
    function GetCodingTypeName(aCodingStr: string): string;
    function GetMonthFromName(aInMonth: string): integer;
    function GetCountryIdFromCode(aCode : string) : integer;

    function IsReportFeature(aFeature : string; var aReportName: string) : boolean;
    procedure GetReportFeatureTypeAndDest(aFeature, aReportName: string;
                                          var aFeatureType : TFeatureType;
                                          var aFeatureDest : TFeatureDest);
    function GetReportFeatureIndex(aReportName : string) : integer;
    procedure SearchAndAddFiles(aDirectory : string);
    function CanAccessFile(aFileName : string) : boolean;
    procedure ProcessFiles();

    procedure CleanFile(var aFileData : TFileData);
    procedure CleanUsageFile(aFileName : string);
    procedure CleanPracticeFile(aFileName : string);
    procedure CleanPracticeFileTabsEOL(aFileName : string);

    procedure ImportFile(var aFileData : TFileData);
    procedure ImportUsageFile(aFileName : string);
    function FillFeatures(aXMLString: WideString; var aFeatureList : TList; aLogError : boolean) : boolean;
    procedure ClearFeatures(var aFeatureList : TList);
    function GetPracticeUsageUpdateSQL(aColumnValues: TStringList; aPracticeInfoId : integer): string;
    function GetFeatureInsertFromXML(aId: integer; aTimeStamp : string; var aFeatureList : TList): string;
    procedure GetReportFeatureInsertFromXML(aId: integer; aTimeStamp : string; var aFeatureList : TList; var aSQLCodingList : TStringList);
    procedure GetCodingInsertFromXML(aId: integer; var aFeatureList : TList; var aSQLCodingList : TStringList);
    procedure ImportPracticeFile(aFileName : string);
    function GetPracticeInsertSQL(aColumnValues : TStringList) : string;
    function GetPracticeUpdateSQL(aColumnValues : TStringList) : string;

    procedure FinnishFile(var aFileData : TFileData);

    procedure StartService();
    procedure StopService();
    function SetServiceState(aValue : TServiceState) : boolean;
    procedure DoFolderScanTimer(Sender: TObject);

    procedure SetupDatabase(aHostName : string;
                            aDatabase : string;
                            aUserName : string;
                            aPassword : string);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Start();
    procedure Stop();

    property FileDirectory : string read fFileDirectory write fFileDirectory;
    property ServiceStatus : TServiceState read fCurrentServiceStatus;

    property HostName : string read fHostName write fHostName;
    property Database : string read fDatabase write fDatabase;
    property UserName : string read fUserName write fUserName;
    property Password : string read fPassword write fPassword;
  end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  StrUtils,
  omniXML,
  logutil,
  Forms,
  Windows;

const
  UNIT_NAME = 'UsageDataImporter';

  USAGEDATA_FILE_PREFIX = 'UsageStats';
  PRACTICE_FILE_PREFIX = 'PracticeData';
  DATA_FOLDER = 'C:\My Documents\Usage Stats\Test';
  WAIT_TIMEOUT = 2000;
  TIMER_VALUE  = 1000;
  IMPORT_LINES_TO_PROCESS = 20;
  NULLSTR = 'NULL';

  RAW_DATA_EXT = 'TXT';
  TEMP_EXT     = 'TMP';
  CLEAN_EXT    = 'CLN';
  RAW_DONE_EXT = 'RAW';
  ERROR_EXT    = 'ERR';

  FeatureTypeNames : Array[ftNormal..ftScheduled] of String[20] =
    ('',
     '(Generate)',
     '(Favourite)',
     '(Scheduled)');

  FeatureDestNames : Array[fdNone..fdCCHFile] of String[40] =
    ('',
     '(View)',
     '(Print)',
     '(File)',
     '(Email)',
     '(Fax)',
     '(Ecoding)',
     '(CSVExport)',
     '(WebX)',
     '(FCheckOut)',
     '(BusinessProduct)',
     '(Comma Separated (CSV) File)',
     '(Fixed Width Text (TXT) File)',
     '(Microsoft Excel (XLSX) File)',
     '(Microsoft Excel (XLS) File)',
     '(Adobe Acrobat Format (PDF) File)',
     '(CCH Web Manager File)');

  USAGE_FILE_COLS = 12;
  USG_XML             = 0;
  USG_TimeStamp       = 1;
  USG_StateCode       = 2;
  USG_StateDesc       = 3;
  USG_SourceSoftware  = 4;
  USG_PracVersion     = 5;
  USG_OSVersion       = 6;
  USG_PracCode        = 7;
  USG_PracDesc        = 8;
  USG_CountryCode     = 9;
  USG_CountryDesc     = 10;
  USG_XMLSessionId    = 11;

  PRAC_FILE_COLS = 81;
  PRAC_INFO_COLS = 87;
  PracInfoFieldNames : Array[1..PRAC_INFO_COLS] of String[30] =
    ('Id',
     'COUNTRYID',
     'PRODUCTIONCLIENTTYPEID',
     'CODE',
     'NAME',
     'ADDRESS1LINE1',
     'ADDRESS1LINE2',
     'SUBURB1',
     'CITY1',
     'ADDRESS1',
     'STATE1ID',
     'POSTCODE1',
     'ADDRESS2LINE1',
     'ADDRESS2LINE2',
     'SUBURB2',
     'CITY2',
     'ADDRESS2',
     'STATE2ID',
     'POSTCODE2',
     'ADDRESS2ISDELIVERY',
     'PHONE1',
     'PHONE2',
     'FAX1',
     'FAX2',
     'EMAIL1',
     'EMAIL2',
     'EMAIL3',
     'SUPERFUNDNOOFACCOUNTS',
     'ACTIVE',
     'ESTNOOFCLIENTS',
     'BLBUILD',
     'ADDDATE',
     'PRODADDDATE',
     'EDITDATE',
     'LRN',
     'CONTRACTDATE',
     'FLOPPYDISKSIZEID',
     'FLOPPYDISKTYPEID',
     'LASTDISKNUMBER',
     'LASTDISKSENT',
     'FREQUENCYID',
     'INSTITUTIONID',
     'TAGGEDFORDELETION',
     'CLIENTRATINGID',
     'QUESTIONAIREINFO',
     'MOBILE1',
     'MOBILE2',
     'CLIENTSTATUSID',
     'BLBCONNECT',
     'BLIPADDRESS',
     'BLSERVER',
     'REGIONID',
     'ALLOWMAIL',
     'ALLOWPHONE',
     'ALLOWFAX',
     'ALLOWEMAIL',
     'TERRITORYID',
     'CLIENTORIGINID',
     'CLIENTORIGINDETAILS',
     'SHORTNOTE',
     'ISOVERDUE',
     'AllowEMailDownload',
     'DownloadEMailAddress',
     'OVERDUETRIGGER_TOTAL',
     'OVERDUETRIGGER_30PLUS',
     'OVERDUETRIGGER_60PLUS',
     'OVERDUETRIGGER_90PLUS',
     'WEBSITEADDRESS',
     'WEBSITETYPEID',
     'SERVICEAGREEMENTPRESENT',
     'LONGITUDE',
     'LATITUDE',
     'ADDRESS1COUNTRY',
     'ADDRESS2COUNTRY',
     'DELETEDATE',
     'NOOFPROVACCOUNTS',
     'NOOFPROVACCOUNTSBILLED',
     'ONLINE_SERVICEAGMTPRESENT',
     'NO_GSTVAT',
     'ATRISK',
     'NOOFACCOUNTSOFFSITE_ONLINE',
     'UploadDateTime',
     'UploadState',
     'UploadUsing',
     'PracticeVersion',
     'DiskPcOsVersion',
     'SQLSessionId');

  RPT_FEATURE_COLS = 132;
  ReportFeatureNames : Array[1..RPT_FEATURE_COLS] of String[50] =
    ('One_Page_Summary',
     'Annual_GST_information_report',
     'Annual_GST_Return',
     'List_Chart_of_Accounts',
     'List_Entries',
     'List_Journals',
     'List_Bank_Accounts',
     'List_Payees',
     'Ledger_-_Detailed',
     'Coding',
     'Coding_-_Standard',
     'Coding_-_Two_Column',
     'Coding_-_Details_Only',
     'Coding_-_Anomalies',
     'Coding_Report_Preview',
     'Cash_Flow',
     'Cash_Flow_-_Actual',
     'Cash_Flow_-_Actual_and_Budget',
     'Cash_Flow_-_Actual_Budget_and_Variance',
     'Cash_Flow_-_12_Months_Actual',
     'Cash_Flow_-_12_Months_Actual_or_Budget',
     'Bank_Reconciliation',
     'Bank_Reconciliation_-_Summarised',
     'Bank_Reconciliation_-_Detailed',
     'Payee_Spending',
     'Payee_Spending_-_Summarised',
     'Payee_Spending_-_Detailed',
     'Coding_by_Job',
     'Summarised_Coding_by_Job',
     'Detailed_Coding_by_Job',
     'GST_Return',
     'GST_calculation_sheet_372',
     'GST_Report_Preview',
     'General_Report_Preview',
     'Exception',
     'Cash_Flow_-_Date_to_Date',
     'Cash_Flow_-_Budget_Remaining',
     'Profit_and_Loss',
     'Profit_and_Loss_-_Date_to_Date',
     'Profit_and_Loss_-_Budget_Remaining',
     'Profit_and_Loss_-_Actual',
     'Profit_and_Loss_-_Actual_and_last_Year',
     'Profit_and_Loss_-_Actual_and_Budget',
     'Profit_and_Loss_-_Actual_Budget_and_last_Year',
     'Profit_and_Loss_-_Actual_Budget_and_Variance',
     'Profit_and_Loss_-_12_Months_Actual',
     'Profit_and_Loss_-_12_Months_Actual_or_Budget',
     'Profit_and_Loss_-_12_Months_Budget',
     'Profit_and_Loss_-_Export',
     'GST_Summary',
     'GST_Allocation_Summary',
     'GST_Reconciliation',
     'GST_Audit',
     'Budget_Listing',
     'Cash_Flow_-_12_Months_Budget',
     'Client_Header',
     'Sort_Header',
     'Staff_Member_Header',
     'Group_Header',
     'Client_Type_Header',
     'Download_Report',
     'Latest_Charges',
     'List_Reports_Due',
     'List_Admin_Bank_Accounts',
     'List_Admin_Inactive_Bank_Accounts',
     'List_Manual_Bank_Accounts',
     'List_Provisional_Bank_Accounts',
     'List_Clients_by_Staff_Member',
     'List_Client_Report_Options',
     'Download_Log',
     'Trial_Balance',
     'Income_and_Expenditure',
     'Business_Activity_Statement',
     'BAS_Calculation_Sheet',
     'Off-site_Download_Log',
     'Business_Norm_Percentages_Report',
     'GST_Overrides',
     'List_GST_Details',
     'Scheduled_Reports_Summary',
     'List_Memorisations',
     'Client_Status_Report',
     'Cash_Flow_-_This_Year_Last_Year_and_Variance',
     'Ledger',
     'Ledger_-_Summarised',
     'Client_File_Access_Control',
     'Cash_Flow_Single_Period',
     'Cash_Flow_Multiple_Periods',
     'Profit_and_Loss_Single_Period',
     'Profit_and_Loss_Multiple_Periods',
     'Balance_Sheet',
     'Balance_Sheet_Single_Period',
     'Balance_Sheet_Multiple_Periods',
     'Balance_Sheet_Export',
     'Summary_Download_Report',
     'Unpresented_Items',
     'List_Divisions',
     'List_Jobs',
     'List_Sub-groups',
     'List_Entries_(incl._Notes)',
     'Listings_Report_Preview',
     'Coding_-_Standard_with_Notes',
     'Coding_-_Two_Column_with_Notes',
     'Cash_Flow_Export',
     'Tasks',
     'All_Open_Tasks',
     'Missing_Cheques',
     'Activity_Statement_Summary',
     'Test_Fax',
     'Mail_Merge_(Print)_Summary',
     'Mail_Merge_(Email)_Summary',
     'Disk_Image_Documents',
     'List_Charges',
     'BankLink_Client_Authority',
     'BankLink_Third_Party_Authority',
     'Clients_Report',
     'Client_Home_Report',
     'List_Groups',
     'List_Client_Types',
     'VAT_Return',
     'Foreign_Exchange_Report',
     'Coding_Optimisation_Report',
     'Custom_Document',
     'System_Accounts',
     'Audit_Report',
     'Payments',
     'Sales',
     'Taxable_Payments',
     'Taxable_Payments_-_Summarised',
     'Taxable_Payments_-_Detailed',
     'Trading_Results',
     'Total_Bank_Balance',
     'ZZZ');

{ TFileData }
//------------------------------------------------------------------------------
constructor TFileData.Create;
begin
  fName := '';
  fError := '';
end;

//------------------------------------------------------------------------------
destructor TFileData.Destroy;
begin
  fName := '';
  fError := '';
  inherited;
end;

//------------------------------------------------------------------------------
function TFileData.GetFileTypeName(): string;
begin
  case fFileType of
    ftUsageStats : Result := 'Usage Stats';
    ftPractice   : Result := 'Practice Info';
  else
    Result := '';
  end;
end;

{ TUsageDataImpoter }
//------------------------------------------------------------------------------
function TUsageDataImporter.GetCleanString(aValue: string): string;
var
  Index : integer;
begin
  for Index := 1 to length(aValue) do
  begin
    if aValue[Index] = '''' then
      continue;

    Result := Result + aValue[Index];
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddIntValue(var aResStr: string; aValue: string; aAddComma : boolean; aDefault : string);
var
  TestValue : integer;
begin
  if ((trystrtoint(aValue,TestValue)) or (aValue = NULLSTR)) then
    aResStr := aResStr + aValue
  else
    aResStr := aResStr + aDefault;

  if aAddComma then
    aResStr := aResStr + ',';
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddStrValue(var aResStr: string; aValue: string; aAddComma : boolean);
begin
  if (aValue = NULLSTR) then
    aResStr := aResStr + aValue
  else
    aResStr := aResStr + '''' + GetCleanString(aValue) + '''';

  if aAddComma then
    aResStr := aResStr + ',';
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddDateValue(var aResStr: string; aValue: string; aAddComma: boolean; aDefault: string);
begin
  if (aValue = NULLSTR) then
    aResStr := aResStr + aValue
  else
    aResStr := aResStr + '''' + GetCleanString(aValue) + '''';

  if aAddComma then
    aResStr := aResStr + ',';
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddUpdIntValue(aColumn: integer; var aResStr: string; aColumnValues : TStringList; aAddComma: boolean; aDefault: string);
begin
  aResStr := aResStr + PracInfoFieldNames[aColumn+1] + '=';
  AddIntValue(aResStr, aColumnValues.Strings[aColumn], aAddComma, aDefault);
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddUpdStrValue(aColumn: integer; var aResStr: string; aColumnValues : TStringList; aAddComma: boolean);
begin
  aResStr := aResStr + PracInfoFieldNames[aColumn+1] + '=';
  AddStrValue(aResStr, aColumnValues.Strings[aColumn], aAddComma);
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.AddUpdDateValue(aColumn: integer; var aResStr: string; aColumnValues : TStringList; aAddComma: boolean; aDefault: string);
begin
  aResStr := aResStr + PracInfoFieldNames[aColumn+1] + '=';
  AddDateValue(aResStr, aColumnValues.Strings[aColumn], aAddComma, aDefault);
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.CleanXML(aInstring: string): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to length(aInstring) do
  begin
    if aInstring[Index] in ['A'..'Z','a'..'z','0'..'9','_','.','(',')','-','<','>','=','?','/'] then
      Result := Result + aInstring[Index]
    else if aInstring[Index] = ' ' then
      Result := Result + '_'
    else if aInstring[Index] = '[' then
      Result := Result + '('
    else if aInstring[Index] = ']' then
      Result := Result + ')'
  end;

  Result := ReplaceText(Result, '<?xml_version=1.0?>', '');
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.CleanFeatureName(aInstring: string): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to length(aInstring) do
  begin
    if aInstring[Index] in ['A'..'Z','a'..'z','0'..'9','_','.','(',')','-'] then
      Result := Result + aInstring[Index]
    else if aInstring[Index] = ' ' then
      Result := Result + '_'
    else if aInstring[Index] = '[' then
      Result := Result + '('
    else if aInstring[Index] = ']' then
      Result := Result + ')'
  end;

  if Result[length(Result)] = '_' then
    Result := leftstr(Result, length(Result)-1);
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetCodingTypeId(aCodingStr: string): integer;
begin
  if aCodingStr = 'Mem' then Result := 0
  else if aCodingStr = 'Man' then Result := 1
  else if aCodingStr = 'Anl' then Result := 2
  else if aCodingStr = 'Pay' then Result := 3
  else if aCodingStr = 'MMem' then Result := 4
  else if aCodingStr = 'Sup' then Result := 5
  else if aCodingStr = 'Notes' then Result := 6
  else if aCodingStr = 'Not' then Result := 7
  else
    Result := -1;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetCodingTypeName(aCodingStr: string): string;
begin
  if aCodingStr = 'Mem' then Result := 'Memorisation'
  else if aCodingStr = 'Man' then Result := 'Manual'
  else if aCodingStr = 'Anl' then Result := 'Analysis'
  else if aCodingStr = 'Pay' then Result := 'Payee'
  else if aCodingStr = 'MMem' then Result := 'MasterMemorisation'
  else if aCodingStr = 'Sup' then Result := 'Man_Super'
  else if aCodingStr = 'Notes' then Result := 'Notes'
  else if aCodingStr = 'Not' then Result := 'UnCoded'
  else
    Result := 'Error';
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetMonthFromName(aInMonth: string): integer;
begin
  if aInMonth = 'JAN' then Result := 1
  else if aInMonth = 'FEB' then Result := 2
  else if aInMonth = 'MAR' then Result := 3
  else if aInMonth = 'APR' then Result := 4
  else if aInMonth = 'MAY' then Result := 5
  else if aInMonth = 'JUN' then Result := 6
  else if aInMonth = 'JUL' then Result := 7
  else if aInMonth = 'AUG' then Result := 8
  else if aInMonth = 'SEP' then Result := 9
  else if aInMonth = 'OCT' then Result := 10
  else if aInMonth = 'NOV' then Result := 11
  else if aInMonth = 'DEC' then Result := 12
  else Result := 1;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetCountryIdFromCode(aCode: string): integer;
begin
  if aCode = 'NZ' then Result := 1
  else if aCode = 'OZ' then Result := 2
  else Result := 1;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.SearchAndAddFiles(aDirectory : string);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
  FoundIndex : integer;
  UsageDataLength : integer;
  PracticeLength : integer;
  NewFileData : TFileData;
begin
  FileDirectory := aDirectory;
  UsageDataLength := length(USAGEDATA_FILE_PREFIX);
  PracticeLength := length(PRACTICE_FILE_PREFIX);

  // Search for Practice Files first since the usage data relies on the Practice info being there
  FindResult := FindFirst(FileDirectory + '\*.' + RAW_DATA_EXT, (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        if (LeftStr(SearchRec.Name,PracticeLength) = PRACTICE_FILE_PREFIX) then
        begin
          if not fFilesToProcess.Find(SearchRec.Name, FoundIndex) then
          begin
            NewFileData := TFileData.Create;
            NewFileData.Name := LeftStr(SearchRec.Name, length(SearchRec.Name)-4);
            NewFileData.StartTickCount := GetTickCount();
            NewFileData.State := fsAdded;
            NewFileData.FileType := ftPractice;

            fFilesToProcess.AddObject(SearchRec.Name, NewFileData);
          end;
        end;
      end;

      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;

  // Search for usage files next
  FindResult := FindFirst(FileDirectory + '\*.' + RAW_DATA_EXT, (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        if (LeftStr(SearchRec.Name,UsageDataLength) = USAGEDATA_FILE_PREFIX) then
        begin
          if not fFilesToProcess.Find(SearchRec.Name, FoundIndex) then
          begin
            NewFileData := TFileData.Create;
            NewFileData.Name := LeftStr(SearchRec.Name, length(SearchRec.Name)-4);
            NewFileData.StartTickCount := GetTickCount();
            NewFileData.State := fsAdded;
            NewFileData.FileType := ftUsageStats;

            fFilesToProcess.AddObject(SearchRec.Name, NewFileData);
          end;
        end;
      end;

      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.CanAccessFile(aFileName : string): boolean;
var
  CurrFile : TextFile;
  RawLine : string;
begin
  try
    AssignFile(CurrFile, aFileName);
    reset(CurrFile);
    try
      if not( EOF(CurrFile)) then
        readln(CurrFile, RawLine);
    finally
      CloseFile(CurrFile);
    end;

    Result := true;
  except
    on e : exception do
      Result := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.ProcessFiles;
var
  FileIndex : integer;
  FileData : TFileData;

  //----------------------------------------------------------------------------
  function CheckAndLogStop() : boolean;
  begin
    if fCurrentServiceStatus = usStop then
    begin
      logutil.LogMsg(lmInfo, UNIT_NAME, 'Importing Service Stopped.', 0, false);
      Result := true;
    end
    else
      Result := false;
  end;
begin
  fFilesToProcess.Sort;
  for FileIndex := 0 to fFilesToProcess.Count - 1 do
  begin
    FileData := TFileData(fFilesToProcess.Objects[FileIndex]);

    case FileData.State of
      fsAdded, fsWaitingForAccess : begin
        if CanAccessFile(FileDirectory + '\' + FileData.Name + '.' + RAW_DATA_EXT) then
        begin
          CleanFile(FileData);

          if CheckAndLogStop() then Exit;

          ImportFile(FileData);

          if CheckAndLogStop() then Exit;

          FinnishFile(FileData);

          if CheckAndLogStop() then Exit;
        end
        else
        begin
          if FileData.StartTickCount + WAIT_TIMEOUT > GetTickCount() then
            FileData.State := fsTimeOutForAccess
          else
            FileData.State := fsWaitingForAccess;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.CleanFile(var aFileData : TFileData);
begin
  aFileData.State := fsCleaning;
  try
    logutil.LogMsg(lmInfo, UNIT_NAME, 'Started Cleaning ' + aFileData.FileTypeName + ' File, ' +
                                       FileDirectory + '\' + aFileData.Name + '.' + RAW_DATA_EXT, 0, false);

    case aFileData.FileType of
      ftUsageStats : CleanUsageFile(aFileData.Name);
      ftPractice   : begin
        CleanPracticeFileTabsEOL(aFileData.Name);
        CleanPracticeFile(aFileData.Name);
      end;
    end;

    aFileData.State := fsCleaned;
    logutil.LogMsg(lmInfo, UNIT_NAME, 'Finished Cleaning ' + aFileData.FileTypeName + ' File, ' +
                                       FileDirectory + '\' + aFileData.Name + '.' + CLEAN_EXT, 0, false);
  except
    on E : exception do
    begin
      aFileData.State := fsErrorCleaning;
      aFileData.Error := E.Message;

      logutil.LogMsg(lmError, UNIT_NAME, 'Error cleaning ' + aFileData.FileTypeName + ' File, ' +
                                         FileDirectory + '\' + aFileData.Name + '.' + RAW_DATA_EXT + ', ' +
                                         'Error Message : ' + E.Message, 0, false);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.CleanUsageFile(aFileName : string);
const
  FIND_STR_1 = ' - Actual,';
  REPLACE_STR_1 = ' - Actual';
  FIND_STR_2 = ' - This Year,';
  REPLACE_STR_2 = ' - This Year';
  FIND_STR_3 = '<feature>Cash Flow, P';
  REPLACE_STR_3 = '<feature>Cash Flow</feature><count>0</count>';
  FIND_STR_4 = '</count>' + #13#10 + '</usage_info></root>';
  REPLACE_STR_4 = '</count></usage_info></root>';
var
  RawDataFile : TextFile;
  CleanFile : TextFile;
  RawLine : string;
  LineCols : TStringList;
  ColIndex : integer;
begin
  assignfile(RawDataFile, FileDirectory + '\' + aFileName + '.' + RAW_DATA_EXT);
  reset(RawDataFile);
  try
    assignfile(CleanFile, FileDirectory + '\' + aFileName + '.' + CLEAN_EXT);
    rewrite(CleanFile);
    try
      while not( EOF(RawDataFile)) do
      begin
        readln(RawDataFile, RawLine);

        RawLine := ReplaceText(RawLine, FIND_STR_1, REPLACE_STR_1);
        RawLine := ReplaceText(RawLine, FIND_STR_2, REPLACE_STR_2);
        RawLine := ReplaceText(RawLine, FIND_STR_3, REPLACE_STR_3);
        RawLine := ReplaceText(RawLine, FIND_STR_4, REPLACE_STR_4);

        LineCols := TStringList.Create();
        try
          LineCols.Delimiter := #9;
          LineCols.StrictDelimiter := True;
          LineCols.DelimitedText := RawLine;

          if LineCols.Count > USAGE_FILE_COLS then
          begin
            // Practice Description goes over more than one column. so fix this
            if (LineCols.Strings[LineCols.Count-3] = 'OZ') or
               (LineCols.Strings[LineCols.Count-3] = 'NZ') then
            begin
              for ColIndex := 9 to LineCols.Count-4 do
                LineCols.Strings[USG_PracDesc] := LineCols.Strings[USG_PracDesc] + LineCols.Strings[ColIndex];

              LineCols.Strings[USG_CountryCode]  := LineCols.Strings[LineCols.Count-3];
              LineCols.Strings[USG_CountryDesc] := LineCols.Strings[LineCols.Count-2];
              LineCols.Strings[USG_XMLSessionId] := LineCols.Strings[LineCols.Count-1];

              for ColIndex := LineCols.Count-1 downto USAGE_FILE_COLS do
                LineCols.Delete(ColIndex);

              RawLine := LineCols.DelimitedText;
            end;
          end;

          LineCols.Clear();
          LineCols.Delimiter := #9;
          LineCols.StrictDelimiter := True;
          LineCols.DelimitedText := RawLine;
          if LineCols.Count = USAGE_FILE_COLS then
          begin
            LineCols.Strings[USG_XML] := CleanXML(LineCols.Strings[0]);

            RawLine := LineCols.DelimitedText;
            writeln(CleanFile, RawLine);
          end;

        finally
          FreeAndNil(LineCols);
        end;
      end;
    finally
      closefile(CleanFile);
    end;
  finally
    closefile(RawDataFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.CleanPracticeFile(aFileName: string);
var
  RawDataFile : TextFile;
  CleanFile : TextFile;
  RawLine : string;
  LineCols : TStringList;
begin
  assignfile(RawDataFile, FileDirectory + '\' + aFileName + '.' + TEMP_EXT);
  reset(RawDataFile);
  try
    assignfile(CleanFile, FileDirectory + '\' + aFileName + '.' + CLEAN_EXT);
    rewrite(CleanFile);
    try
      while not( EOF(RawDataFile)) do
      begin
        readln(RawDataFile, RawLine);

        LineCols := TStringList.Create();
        try
          LineCols.Delimiter := #9;
          LineCols.StrictDelimiter := True;
          LineCols.DelimitedText := RawLine;

          writeln(CleanFile, RawLine);

        finally
          FreeAndNil(LineCols);
        end;
      end;
    finally
      closefile(CleanFile);
    end;
  finally
    closefile(RawDataFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.CleanPracticeFileTabsEOL(aFileName : string);
const
  BUFFER_SIZE = 8192;
  CHECK_COL   = 61;
var
  RawDataFile : File;
  CleanFile : File;
  ColIndex : integer;
  NumRead    : integer;
  NumToWrite : integer;
  NumWritten : integer;
  ReadBuffer  : Array [1..BUFFER_SIZE] of Byte;
  WriteBuffer : Array [1..BUFFER_SIZE] of Byte;
  BufferIndex : integer;
begin
  // Fix up Tabs and end of line characters
  ColIndex := 1;
  AssignFile(RawDataFile, FileDirectory + '\' + aFileName + '.' + RAW_DATA_EXT);
  Reset(RawDataFile,1);
  try
    AssignFile(CleanFile, FileDirectory + '\' + aFileName + '.' + TEMP_EXT);
    Rewrite(CleanFile,1);
    try
      BlockRead(RawDataFile, ReadBuffer, 3, NumRead);

      Repeat
        BlockRead(RawDataFile, ReadBuffer, Sizeof(ReadBuffer), NumRead);
        NumToWrite := 0;

        for BufferIndex := 1 to NumRead do
        begin
          if ReadBuffer[BufferIndex] = 9 then
          begin
            inc(NumToWrite);
            inc(ColIndex);
            if ((ColIndex) = CHECK_COL) and
               (not (ReadBuffer[BufferIndex+1] in [48,49])) then
            begin
              dec(ColIndex);
              WriteBuffer[NumToWrite] := 32
            end
            else
              WriteBuffer[NumToWrite] := ReadBuffer[BufferIndex];
          end
          else if ReadBuffer[BufferIndex] = 10 then
          begin
            if ColIndex = PRAC_FILE_COLS then
            begin
              inc(NumToWrite);
              WriteBuffer[NumToWrite] := 13;
              inc(NumToWrite);
              WriteBuffer[NumToWrite] := 10;
              ColIndex := 1;
            end;
          end
          else if not (ReadBuffer[BufferIndex] = 13) then
          begin
            inc(NumToWrite);
            WriteBuffer[NumToWrite] := ReadBuffer[BufferIndex];
          end;
        end;

        BlockWrite(CleanFile, WriteBuffer, NumToWrite, NumWritten);
      Until (NumRead = 0);
    finally
      CloseFile(CleanFile);
    end;
  finally
    CloseFile(RawDataFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.ImportFile(var aFileData: TFileData);
begin
  aFileData.State := fsImporting;
  try
    logutil.LogMsg(lmInfo, UNIT_NAME, 'Started Importing ' + aFileData.FileTypeName + ' File, ' +
                                       FileDirectory + '\' + aFileData.Name + '.' + CLEAN_EXT, 0, false);

    case aFileData.FileType of
      ftUsageStats : ImportUsageFile(aFileData.Name);
      ftPractice   : ImportPracticeFile(aFileData.Name);
    end;

    logutil.LogMsg(lmInfo, UNIT_NAME, 'Finished Importing ' + aFileData.FileTypeName + ' File, ' +
                                       FileDirectory + '\' + aFileData.Name + '.' + CLEAN_EXT, 0, false);
  except
    on E : exception do
    begin
      aFileData.State := fsErrorImporting;
      aFileData.Error := E.Message;

      logutil.LogMsg(lmError, UNIT_NAME, 'Error importing ' + aFileData.FileTypeName + ' File, ' +
                                         FileDirectory + '\' + aFileData.Name + '.' + CLEAN_EXT + ', ' +
                                         'Error Message : ' + E.Message, 0, false);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.ImportUsageFile(aFileName : string);
const
  DOES_ID_EXIST_SQL = 'Select Id, CODE, COUNTRYID from PracticeInfo where CODE in (%s);';
var
  CleanFile : TextFile;
  CleanLine : string;
  LineArrCols  : Array[1..IMPORT_LINES_TO_PROCESS] of TStringList;
  LineArrState : Array[1..IMPORT_LINES_TO_PROCESS] of TImportLineState;
  LineArrId    : Array[1..IMPORT_LINES_TO_PROCESS] of integer;
  SQLIdList : TStringList;
  SQLCodingList : TStringList;
  LineIndex : integer;
  ProcessIndex : integer;
  FoundCode : string;
  FoundId   : integer;
  FoundCountryId : integer;
  CodingIndex : integer;
  FeatureList : TList;
  SQLIndex : integer;
  BatchNumber : integer;
begin
  fNumOfSQLStatements := 0;
  for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
  begin
    LineArrCols[LineIndex] := TStringList.Create();
    LineArrState[LineIndex] := ilNone;
    LineArrId[LineIndex] := -1;
  end;
  SQLIdList := TStringList.Create();
  SQLIdList.Delimiter := ',';
  SQLIdList.StrictDelimiter := True;
  BatchNumber := 0;

  try
    SQLCodingList := TStringList.Create();
    try
      FeatureList := TList.create();
      try
        assignfile(CleanFile, FileDirectory + '\' + aFileName + '.' + CLEAN_EXT);
        reset(CleanFile);
        try
          LineIndex := 0;
          while not( EOF(CleanFile)) do
          begin
            readln(CleanFile, CleanLine);
            inc(LineIndex);

            LineArrCols[LineIndex].Delimiter := #9;
            LineArrCols[LineIndex].StrictDelimiter := True;
            LineArrCols[LineIndex].DelimitedText := CleanLine;

            if (LineIndex = IMPORT_LINES_TO_PROCESS) then
            begin
              // Update List State and values
              SQLIdList.Clear;
              for ProcessIndex := 1 to IMPORT_LINES_TO_PROCESS do
              begin
                LineArrId[ProcessIndex] := -1;
                if LineArrCols[ProcessIndex].Count = USAGE_FILE_COLS then
                begin
                  SQLIdList.Add('''' + LineArrCols[ProcessIndex].Strings[USG_PracCode] + '''');
                  LineArrState[ProcessIndex] := ilInsert;
                end
                else
                  LineArrState[ProcessIndex] := ilDelimiterError;
              end;

              if SQLIdList.Count > 0 then
              begin
                fSQLDataSet.CommandText := Format(DOES_ID_EXIST_SQL, [SQLIdList.DelimitedText]);
                fSQLDataSet.Prepared := true;
                fSQLDataSet.Open;

                try
                  // Check if record exists so we need an update
                  while (not fSQLDataSet.Eof) do
                  begin
                    FoundCode := fSQLDataSet.FieldByName('CODE').AsString;
                    FoundId := fSQLDataSet.FieldByName('Id').AsInteger;
                    FoundCountryId := fSQLDataSet.FieldByName('CountryId').AsInteger;

                    for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
                    begin
                      if (LineArrState[LineIndex] = ilInsert) and
                         (LineArrCols[LineIndex].Strings[USG_PracCode] = FoundCode) and
                         (GetCountryIdFromCode(LineArrCols[LineIndex].Strings[USG_CountryCode]) = FoundCountryId) then
                      begin
                        LineArrState[LineIndex] := ilUpdate;
                        LineArrId[LineIndex] := FoundId;
                      end;
                    end;

                    fSQLDataSet.Next;
                  end;
                finally
                  fSQLDataSet.Close;
                end;

                // Create the SQL query to update and insert to database
                fSQLQuery.SQL.Clear;
                for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
                begin
                  if (LineArrState[LineIndex] = ilUpdate) then
                  begin
                    if not FillFeatures(LineArrCols[LineIndex].Strings[USG_XML], FeatureList, false) then
                    begin
                      LineArrCols[LineIndex].Strings[USG_XML] :=
                        ReplaceText(LineArrCols[LineIndex].Strings[USG_XML],
                                    '</usage_info></root>', '</feature><count>0</count></usage_info></root>');

                      FillFeatures(LineArrCols[LineIndex].Strings[USG_XML], FeatureList, true);
                    end;

                    try
                      // Update Practice Info with usage data
                      inc(fNumOfSQLStatements);
                      fSQLQuery.SQL.Add(GetPracticeUsageUpdateSQL(LineArrCols[LineIndex],
                                                                  LineArrId[LineIndex]));

                      // Add Feature Data to DB
                      inc(fNumOfSQLStatements);
                      fSQLQuery.SQL.Add(GetFeatureInsertFromXML(LineArrId[LineIndex],
                                                                LineArrCols[LineIndex].Strings[USG_TimeStamp],
                                                                FeatureList));

                      // Add Report Feature Data to DB
                      GetReportFeatureInsertFromXML(LineArrId[LineIndex],
                                                    LineArrCols[LineIndex].Strings[USG_TimeStamp],
                                                    FeatureList,
                                                    SQLCodingList);
                      for CodingIndex := 0 to SQLCodingList.Count - 1 do
                      begin
                        inc(fNumOfSQLStatements);
                        fSQLQuery.SQL.Add(SQLCodingList.Strings[CodingIndex]);
                      end;

                      // Add or Update Coding Data to DB
                      GetCodingInsertFromXML(LineArrId[LineIndex],
                                             FeatureList,
                                             SQLCodingList);

                      for CodingIndex := 0 to SQLCodingList.Count - 1 do
                      begin
                        inc(fNumOfSQLStatements);
                        fSQLQuery.SQL.Add(SQLCodingList.Strings[CodingIndex]);
                      end;
                    finally
                      ClearFeatures(FeatureList);
                    end;
                  end;
                end;

                Forms.Application.ProcessMessages;
                inc(BatchNumber);
                if Frac(BatchNumber/10) = 0 then
                begin
                  logutil.LogMsg(lmInfo, UNIT_NAME, 'Importing Batch - ' +  inttostr(BatchNumber) +
                                                    ' ,SQL Lines in Batch - ' + inttostr(fNumOfSQLStatements), 0, false);
                  fNumOfSQLStatements := 0;
                end;

                if fCurrentServiceStatus = usStop then
                  Exit;

                if fSQLQuery.SQL.Count > 0 then
                begin
                  try
                    fSQLQuery.ExecSQL();

                  except
                    on E : exception do
                    begin
                      logutil.LogMsg(lmError, UNIT_NAME, 'Error importing ' + aFileName + ' File, ' +
                                                         FileDirectory + '\' + aFileName + '.' + CLEAN_EXT + ', ' +
                                                         'Error Message : ' + E.Message, 0, false);

                      for SQLIndex := 0 to fSQLQuery.SQL.Count-1 do
                        logutil.LogMsg(lmError, UNIT_NAME, '  SQL Line ' + inttostr(SQLIndex) + ' : ' + fSQLQuery.SQL.Strings[SQLIndex], 0, false);
                    end;
                  end;
                end;
              end;

              for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
                LineArrState[LineIndex] := ilNone;

              LineIndex := 0;
            end;
          end;

          if fNumOfSQLStatements > 0 then
            logutil.LogMsg(lmInfo, UNIT_NAME, 'Importing Batch - ' +  inttostr(BatchNumber) +
                                              ' ,SQL Lines in Batch - ' + inttostr(fNumOfSQLStatements), 0, false);
        finally
          closefile(CleanFile);
        end;
      finally
        FreeAndNil(FeatureList);
      end;
    finally
      FreeAndNil(SQLCodingList);
    end;
  finally
    for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
      FreeAndNil(LineArrCols[LineIndex]);

    FreeAndNil(SQLIdList);
  end;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.FillFeatures(aXMLString: WideString; var aFeatureList: TList; aLogError : boolean) : boolean;
var
  NewFeatureItem : TFeatureItem;
  FeatureIndex : integer;
  XMLData : IXMLDocument;
  CurrentNode : IXMLNode;
  CleanText : string;
  Found : boolean;
begin
  XMLData := CreateXMLDoc;
  try
    try
      XMLData.LoadXML(aXMLString);
      CurrentNode := XMLData.FirstChild;
      if (Assigned(CurrentNode)) and (CurrentNode.NodeName = 'root') then
      begin
        CurrentNode := CurrentNode.FirstChild;
        if (Assigned(CurrentNode)) and (CurrentNode.NodeName = 'usage_info') then
        begin
          CurrentNode := CurrentNode.FirstChild;
          if (Assigned(CurrentNode)) then
          begin
            repeat
              if (CurrentNode.NodeName = 'feature') then
              begin
                CleanText := CleanFeatureName(CurrentNode.GetText());
                Found := false;
                for FeatureIndex := 0 to aFeatureList.Count - 1 do
                begin
                  if Uppercase(TFeatureItem(aFeatureList.Items[FeatureIndex]).Name) = UpperCase(CleanText) then
                  begin
                    Found := true;
                    break;
                  end;
                end;

                if not found then
                begin
                  NewFeatureItem := TFeatureItem.Create;
                  NewFeatureItem.Name := CleanText;
                  NewFeatureItem.Count := '0';

                  CurrentNode := CurrentNode.NextSibling;
                  if (Assigned(CurrentNode)) and (CurrentNode.NodeName = 'count') then
                    NewFeatureItem.Count := CurrentNode.GetText();

                  aFeatureList.Add(NewFeatureItem);
                end;
              end;

              CurrentNode := CurrentNode.NextSibling;
            until (not Assigned(CurrentNode));
          end;
        end;
      end;
      Result := true;
    except
      on E : exception do
      begin
        if aLogError then
          logutil.LogMsg(lmError, UNIT_NAME, 'Error parsing XML : ' + aXMLString, 0, false);

        Result := false;
      end;
    end;
  finally
    XMLData := nil;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.ClearFeatures(var aFeatureList: TList);
var
  FeatureIndex : integer;
begin
  for FeatureIndex := aFeatureList.Count-1 downto 0 do
    TFeatureItem(aFeatureList.Items[FeatureIndex]).Free;

  aFeatureList.Clear;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.IsReportFeature(aFeature: string; var aReportName: string): boolean;
var
  ReportIndex : integer;
  RptCleanFeatue : string;
  RptCleanLen : integer;
  FeatureLen : integer;
begin
  Result := false;
  aReportName := '';

  for ReportIndex := 1 to RPT_FEATURE_COLS do
  begin
    RptCleanFeatue := CleanFeatureName(ReportFeatureNames[ReportIndex]);
    RptCleanLen := Length(RptCleanFeatue);
    FeatureLen  := Length(aFeature);

    if (FeatureLen > RptCleanLen) then
    begin
      if (aFeature[RptCleanLen+1] = '(' ) and
         (RptCleanFeatue = LeftStr(aFeature, RptCleanLen)) then
      begin
        Result := true;
        aReportName := RptCleanFeatue;
        Exit;
      end;
    end
    else if (FeatureLen = RptCleanLen) then
    begin
      if (RptCleanFeatue = LeftStr(aFeature, RptCleanLen)) then
      begin
        Result := true;
        aReportName := RptCleanFeatue;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.GetReportFeatureTypeAndDest(aFeature, aReportName: string;
                                                         var aFeatureType: TFeatureType;
                                                         var aFeatureDest: TFeatureDest);
var
  FeatureType : TFeatureType;
  FeatureDest : TFeatureDest;
  CheckStr : string;
begin
  if aFeature = aReportName then
  begin
    aFeatureType := ftNormal;
    aFeatureDest := fdNone;
    Exit;
  end;

  CheckStr := RightStr(aFeature, length(aFeature) - length(aReportName));

  for FeatureType := ftNormal to ftScheduled do
  begin
    if ContainsText(CheckStr, FeatureTypeNames[FeatureType]) then
    begin
      aFeatureType := FeatureType;
      break;
    end;
  end;

  for FeatureDest := fdNone to fdCCHFile do
  begin
    if ContainsText(CheckStr, FeatureDestNames[FeatureDest]) then
    begin
      aFeatureDest := FeatureDest;
      break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetReportFeatureIndex(aReportName : string) : integer;
var
  Index : integer;
begin
  Result := -1;
  for Index := 1 to RPT_FEATURE_COLS do
  begin
    if ReportFeatureNames[Index] = aReportName then
    begin
      Result := Index;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetPracticeUsageUpdateSQL(aColumnValues: TStringList; aPracticeInfoId : integer): string;
const
  UPDATE_PRACTICE_SQL = 'Update PracticeInfo set %s where Id = %s;';
var
  Values : string;
begin
  Values := '';
  // UploadDateTime
  Values := Values + PracInfoFieldNames[82] + '=';
  AddDateValue(Values, aColumnValues.Strings[USG_TimeStamp], true, 'NULL');
  // UploadState
  Values := Values + PracInfoFieldNames[83] + '=';
  AddStrValue(Values, aColumnValues.Strings[USG_StateCode], true);
  // UploadUsing
  Values := Values + PracInfoFieldNames[84] + '=';
  AddStrValue(Values, aColumnValues.Strings[USG_SourceSoftware], true);
  // PracticeVersion
  Values := Values + PracInfoFieldNames[85] + '=';
  AddStrValue(Values, aColumnValues.Strings[USG_PracVersion], true);
  // DiskPcOsVersion
  Values := Values + PracInfoFieldNames[86] + '=';
  AddStrValue(Values, aColumnValues.Strings[USG_OSVersion], true);
  // SQLSessionId
  Values := Values + PracInfoFieldNames[87] + '=';
  AddIntValue(Values, aColumnValues.Strings[USG_XMLSessionId], false, 'NULL');

  Result := Format(UPDATE_PRACTICE_SQL, [Values, inttostr(aPracticeInfoId)]);
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetFeatureInsertFromXML(aId: integer; aTimeStamp : string; var aFeatureList : TList): string;
var
  InsertText : string;
  ValuesText : string;
  FeatureIndex : integer;
  FeatureItem : TFeatureItem;
  ReportName: string;
begin
  Result := '';
  InsertText := 'insert into [feature] ([PracticeInfoId], [UploadDateTime]';
  ValuesText := 'values (' + inttostr(aId) + ',''' + aTimeStamp + '''' ;

  for FeatureIndex := 0 to aFeatureList.Count - 1 do
  begin
    FeatureItem := TFeatureItem(aFeatureList.Items[FeatureIndex]);

    if (not (leftstr(FeatureItem.Name, 4) = 'PCS_')) and
       (not (leftstr(FeatureItem.Name, 5) = 'User_')) and
       (not (IsReportFeature(FeatureItem.Name, ReportName))) then
    begin
      InsertText := InsertText + ',[' + FeatureItem.Name + ']';
      ValuesText := ValuesText + ',' + FeatureItem.Count;
    end;
  end;

  InsertText := InsertText + ') ';
  ValuesText := ValuesText + ');';

  Result := InsertText + ValuesText;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.GetReportFeatureInsertFromXML(aId: integer; aTimeStamp : string; var aFeatureList : TList; var aSQLCodingList : TStringList);
var
  InsertText : string;
  ValuesText : string;
  FeatureIndex : integer;
  FeatureItem : TFeatureItem;
  ReportName: string;
  FeatureType : TFeatureType;
  FeatureDest : TFeatureDest;
  ReportIndex : integer;
begin
  aSQLCodingList.Clear;

  for FeatureIndex := 0 to aFeatureList.Count - 1 do
  begin
    FeatureItem := TFeatureItem(aFeatureList.Items[FeatureIndex]);

    if IsReportFeature(FeatureItem.Name, ReportName) then
    begin
      GetReportFeatureTypeAndDest(FeatureItem.Name, ReportName,
                                  FeatureType, FeatureDest);

      ReportIndex := GetReportFeatureIndex(ReportName);

      InsertText := 'insert into [reportfeature] ([PracticeInfoId], ' +
                                                 '[ReportId], ' +
                                                 '[ReportTypeId], ' +
                                                 '[ReportDestId], ' +
                                                 '[UploadDateTime], ' +
                                                 '[Count]) ';
      ValuesText := 'values (' + inttostr(aId) + ',' +
                                 inttostr(ReportIndex) + ',' +
                                 inttostr(Integer(FeatureType)) + ',' +
                                 inttostr(Integer(FeatureDest)) + ',''' +
                                 aTimeStamp + ''',' +
                                 FeatureItem.Count + ')';

      aSQLCodingList.Add(InsertText + ValuesText);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.GetCodingInsertFromXML(aId: integer; var aFeatureList : TList; var aSQLCodingList : TStringList);
const
  DOES_ID_EXIST_SQL = 'Select Id, CodingYear, CodingMonth, CodingTypeId from Coding where PracticeInfoId = %s;';
var
  SQLText : string;
  Year : integer;
  Month : integer;
  CodingCount : string;
  CodingTypeId : integer;
  CodingId : integer;
  FeatureIndex : integer;
  FeatureItem : TFeatureItem;

  //----------------------------------------------------------------------------
  function DoesRangeExist(aYear, aMonth, aTypeId : integer; var aId : integer) : boolean;
  begin
    Result := false;
    aId := -1;
    fSQLDataSet.First;
    // Check if record exists so we need an update
    while (not fSQLDataSet.Eof) do
    begin
      if (fSQLDataSet.FieldByName('CodingYear').AsInteger = aYear) and
         (fSQLDataSet.FieldByName('CodingTypeId').AsInteger = aTypeId) and
         (fSQLDataSet.FieldByName('CodingMonth').AsInteger = aMonth) then
      begin
        Result := true;
        aId := fSQLDataSet.FieldByName('Id').AsInteger;
        Exit;
      end;

      fSQLDataSet.Next;
    end;
  end;
begin
  aSQLCodingList.Clear;

  fSQLDataSet.CommandText := Format(DOES_ID_EXIST_SQL, [inttostr(aId)]);
  fSQLDataSet.Prepared := true;
  fSQLDataSet.Open;

  try
    for FeatureIndex := 0 to aFeatureList.Count - 1 do
    begin
      FeatureItem := TFeatureItem(aFeatureList.Items[FeatureIndex]);

      if (leftstr(FeatureItem.Name,4) = 'PCS_') then
      begin
        Year := strtoint(midstr(FeatureItem.Name,5,4));
        Month := GetMonthFromName(midstr(FeatureItem.Name,10,3));
        CodingTypeId := GetCodingTypeId(midstr(FeatureItem.Name,14,length(FeatureItem.Name)-13));
        CodingCount := FeatureItem.Count;

        if DoesRangeExist(Year, Month, CodingTypeId, CodingId) then
        begin
          SQLText := 'Update [Coding] ' +
                     'Set [Count] = ' + CodingCount + ' ' +
                     'Where [Id] = ' + inttostr(CodingId)+ ';';
        end
        else
        begin
          SQLText := 'insert into [Coding] ([PracticeInfoId], [CodingYear], [CodingMonth], [Count], [CodingTypeId]) ' +
                     'values (' + inttostr(aId) +
                     ',' + inttostr(Year) +
                     ',' + inttostr(Month) +
                     ',' + CodingCount +
                     ',' + inttostr(CodingTypeId) + ');';
        end;

        aSQLCodingList.Add(SQLText);
      end;
    end;
  finally
    fSQLDataSet.Close;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.ImportPracticeFile(aFileName : string);
const
  DOES_ID_EXIST_SQL = 'Select Id from PracticeInfo where id in (%s);';
var
  CleanFile : TextFile;
  CleanLine : string;
  LineArrCols : Array[1..IMPORT_LINES_TO_PROCESS] of TStringList;
  LineArrState : Array[1..IMPORT_LINES_TO_PROCESS] of TImportLineState;
  SQLIdList : TStringList;
  LineIndex : integer;
  ProcessIndex : integer;
  FoundId : integer;
begin
  for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
  begin
    LineArrCols[LineIndex] := TStringList.Create();
    LineArrState[LineIndex] := ilNone;
  end;
  SQLIdList := TStringList.Create();
  SQLIdList.Delimiter := ',';
  SQLIdList.StrictDelimiter := True;

  try
    assignfile(CleanFile, FileDirectory + '\' + aFileName + '.' + CLEAN_EXT);
    reset(CleanFile);
    try
      LineIndex := 0;
      while not( EOF(CleanFile)) do
      begin
        readln(CleanFile, CleanLine);
        inc(LineIndex);

        LineArrCols[LineIndex].Delimiter := #9;
        LineArrCols[LineIndex].StrictDelimiter := True;
        LineArrCols[LineIndex].DelimitedText := CleanLine;

        if (LineIndex = IMPORT_LINES_TO_PROCESS) then
        begin
          // Update List State and values
          SQLIdList.Clear;
          for ProcessIndex := 1 to IMPORT_LINES_TO_PROCESS do
          begin
            if LineArrCols[ProcessIndex].Count = PRAC_FILE_COLS then
            begin
              SQLIdList.Add(LineArrCols[ProcessIndex].Strings[0]);
              LineArrState[ProcessIndex] := ilInsert;
            end
            else
              LineArrState[ProcessIndex] := ilDelimiterError;
          end;

          if SQLIdList.Count > 0 then
          begin
            fSQLDataSet.CommandText := Format(DOES_ID_EXIST_SQL, [SQLIdList.DelimitedText]);
            fSQLDataSet.Prepared := true;
            fSQLDataSet.Open;

            try
              // Check if record exists so we need an update
              while (not fSQLDataSet.Eof) do
              begin
                FoundId := fSQLDataSet.FieldByName('Id').AsInteger;

                for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
                begin
                  if (LineArrState[LineIndex] = ilInsert) and
                     (strtoint(LineArrCols[LineIndex].Strings[0]) = FoundId)then
                    LineArrState[LineIndex] := ilUpdate;
                end;

                fSQLDataSet.Next;
              end;
            finally
              fSQLDataSet.Close;
            end;

            // Create the SQL query to update and insert to database
            fSQLQuery.SQL.Clear;
            for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
            begin
              if (LineArrState[LineIndex] = ilInsert) then
              begin
                fSQLQuery.SQL.Add(GetPracticeInsertSQL(LineArrCols[LineIndex]));
              end
              else if (LineArrState[LineIndex] = ilUpdate) then
              begin
                fSQLQuery.SQL.Add(GetPracticeUpdateSQL(LineArrCols[LineIndex]));
              end;
            end;

            if fSQLQuery.SQL.Count > 0 then
              fSQLQuery.ExecSQL();
          end;

          for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
            LineArrState[LineIndex] := ilNone;

          LineIndex := 0;
        end;
      end;
    finally
      closefile(CleanFile);
    end;
  finally
    for LineIndex := 1 to IMPORT_LINES_TO_PROCESS do
      FreeAndNil(LineArrCols[LineIndex]);

    FreeAndNil(SQLIdList);
  end;
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetPracticeInsertSQL(aColumnValues: TStringList): string;
const
  INSERT_PRACTICE_SQL = 'Insert into PracticeInfo (%s) values (%s);';
var
  ColIndex : integer;
  ColNames : string;
  Values : string;
begin
  ColNames := '';
  for ColIndex := 1 to PRAC_INFO_COLS do
  begin
    ColNames := ColNames + PracInfoFieldNames[ColIndex];
    if ColIndex < PRAC_INFO_COLS then
      ColNames := ColNames + ', ';
  end;

  Values := '';
  AddIntValue(Values, aColumnValues.Strings[0], true, NULLSTR);
  AddIntValue(Values, aColumnValues.Strings[1], true, NULLSTR);
  AddIntValue(Values, aColumnValues.Strings[2], true, NULLSTR);

  AddStrValue(Values, aColumnValues.Strings[3], true);
  AddStrValue(Values, aColumnValues.Strings[4], true);
  //Address 1
  AddStrValue(Values, aColumnValues.Strings[5], true);
  AddStrValue(Values, aColumnValues.Strings[6], true);
  AddStrValue(Values, aColumnValues.Strings[7], true);
  AddStrValue(Values, aColumnValues.Strings[8], true);
  AddStrValue(Values, aColumnValues.Strings[9], true);
  AddIntValue(Values, aColumnValues.Strings[10], true, NULLSTR);
  AddStrValue(Values, aColumnValues.Strings[11], true);
  //Address 2
  AddStrValue(Values, aColumnValues.Strings[12], true);
  AddStrValue(Values, aColumnValues.Strings[13], true);
  AddStrValue(Values, aColumnValues.Strings[14], true);
  AddStrValue(Values, aColumnValues.Strings[15], true);
  AddStrValue(Values, aColumnValues.Strings[16], true);
  AddIntValue(Values, aColumnValues.Strings[17], true, NULLSTR);
  AddStrValue(Values, aColumnValues.Strings[18], true);

  AddStrValue(Values, aColumnValues.Strings[19], true);
  // Phone
  AddStrValue(Values, aColumnValues.Strings[20], true);
  AddStrValue(Values, aColumnValues.Strings[21], true);
  // Fax
  AddStrValue(Values, aColumnValues.Strings[22], true);
  AddStrValue(Values, aColumnValues.Strings[23], true);
  // Email
  AddStrValue(Values, aColumnValues.Strings[24], true);
  AddStrValue(Values, aColumnValues.Strings[25], true);
  AddStrValue(Values, aColumnValues.Strings[26], true);

  AddIntValue(Values, aColumnValues.Strings[27], true, '0');
  AddIntValue(Values, aColumnValues.Strings[28], true, '0');
  AddIntValue(Values, aColumnValues.Strings[29], true, '0');

  AddStrValue(Values, aColumnValues.Strings[30], true);

  AddDateValue(Values, aColumnValues.Strings[31], true, 'NULL');
  AddDateValue(Values, aColumnValues.Strings[32], true, 'NULL');
  AddDateValue(Values, aColumnValues.Strings[33], true, 'NULL');

  AddIntValue(Values, aColumnValues.Strings[34], true, 'NULL');

  AddDateValue(Values, aColumnValues.Strings[35], true, 'NULL');

  AddIntValue(Values, aColumnValues.Strings[36], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[37], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[38], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[39], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[40], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[41], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[42], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[43], true, 'NULL');
  // Questionare
  AddStrValue(Values, aColumnValues.Strings[44], true);
  // Mobile
  AddStrValue(Values, aColumnValues.Strings[45], true);
  AddStrValue(Values, aColumnValues.Strings[46], true);

  AddIntValue(Values, aColumnValues.Strings[47], true, 'NULL');
  // BConnect
  AddDateValue(Values, aColumnValues.Strings[48], true, 'NULL');
  AddStrValue(Values, aColumnValues.Strings[49], true);
  AddStrValue(Values, aColumnValues.Strings[50], true);

  AddIntValue(Values, aColumnValues.Strings[51], true, 'NULL');
  // Allow Values
  AddIntValue(Values, aColumnValues.Strings[52], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[53], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[54], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[55], true, 'NULL');

  AddIntValue(Values, aColumnValues.Strings[56], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[57], true, 'NULL');

  AddStrValue(Values, aColumnValues.Strings[58], true);
  AddStrValue(Values, aColumnValues.Strings[59], true);
  // IsOverdue
  AddIntValue(Values, aColumnValues.Strings[60], true, 'NULL');

  AddStrValue(Values, aColumnValues.Strings[61], true);
  AddStrValue(Values, aColumnValues.Strings[62], true);

  AddStrValue(Values, aColumnValues.Strings[63], true);
  AddStrValue(Values, aColumnValues.Strings[64], true);
  AddStrValue(Values, aColumnValues.Strings[65], true);
  AddStrValue(Values, aColumnValues.Strings[66], true);

  AddStrValue(Values, aColumnValues.Strings[67], true);
  AddIntValue(Values, aColumnValues.Strings[68], true, 'NULL');
  // ServiceAgreement Present
  AddIntValue(Values, aColumnValues.Strings[69], true, 'NULL');
  // Long and Lat
  AddIntValue(Values, aColumnValues.Strings[70], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[71], true, 'NULL');

  AddStrValue(Values, aColumnValues.Strings[72], true);
  AddStrValue(Values, aColumnValues.Strings[73], true);

  AddDateValue(Values, aColumnValues.Strings[74], true, 'NULL');

  AddIntValue(Values, aColumnValues.Strings[75], true, '0');
  AddIntValue(Values, aColumnValues.Strings[76], true, '0');

  AddIntValue(Values, aColumnValues.Strings[77], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[78], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[79], true, 'NULL');
  AddIntValue(Values, aColumnValues.Strings[80], true, 'NULL');

  // Usage Practice Info Fields
  for ColIndex := 1 to 5 do
    AddStrValue(Values, NULLSTR, true);
  AddStrValue(Values, NULLSTR, false);

  Result := Format(INSERT_PRACTICE_SQL, [ColNames, Values]);
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.GetPracticeUpdateSQL(aColumnValues: TStringList): string;
const
  UPDATE_PRACTICE_SQL = 'Update PracticeInfo set %s where Id = %s;';
var
  Values : string;
begin
  Values := '';
  AddUpdIntValue(1, Values, aColumnValues, true, NULLSTR);
  AddUpdIntValue(2, Values, aColumnValues, true, NULLSTR);

  AddUpdStrValue(3, Values, aColumnValues, true);
  AddUpdStrValue(4, Values, aColumnValues, true);
  //Address 1
  AddUpdStrValue(5, Values, aColumnValues, true);
  AddUpdStrValue(6, Values, aColumnValues, true);
  AddUpdStrValue(7, Values, aColumnValues, true);
  AddUpdStrValue(8, Values, aColumnValues, true);
  AddUpdStrValue(9, Values, aColumnValues, true);
  AddUpdIntValue(10, Values, aColumnValues, true, NULLSTR);
  AddUpdStrValue(11, Values, aColumnValues, true);
  //Address 2
  AddUpdStrValue(12, Values, aColumnValues, true);
  AddUpdStrValue(13, Values, aColumnValues, true);
  AddUpdStrValue(14, Values, aColumnValues, true);
  AddUpdStrValue(15, Values, aColumnValues, true);
  AddUpdStrValue(16, Values, aColumnValues, true);
  AddUpdIntValue(17, Values, aColumnValues, true, NULLSTR);
  AddUpdStrValue(18, Values, aColumnValues, true);

  AddUpdStrValue(19, Values, aColumnValues, true);
  // Phone
  AddUpdStrValue(20, Values, aColumnValues, true);
  AddUpdStrValue(21, Values, aColumnValues, true);
  // Fax
  AddUpdStrValue(22, Values, aColumnValues, true);
  AddUpdStrValue(23, Values, aColumnValues, true);
  // Email
  AddUpdStrValue(24, Values, aColumnValues, true);
  AddUpdStrValue(25, Values, aColumnValues, true);
  AddUpdStrValue(26, Values, aColumnValues, true);

  AddUpdIntValue(27, Values, aColumnValues, true, '0');
  AddUpdIntValue(28, Values, aColumnValues, true, '0');
  AddUpdIntValue(29, Values, aColumnValues, true, '0');

  AddUpdStrValue(30, Values, aColumnValues, true);

  AddUpdDateValue(31, Values, aColumnValues, true, 'NULL');
  AddUpdDateValue(32, Values, aColumnValues, true, 'NULL');
  AddUpdDateValue(33, Values, aColumnValues, true, 'NULL');

  AddUpdIntValue(34, Values, aColumnValues, true, 'NULL');

  AddUpdDateValue(35, Values, aColumnValues, true, 'NULL');

  AddUpdIntValue(36, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(37, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(38, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(39, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(40, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(41, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(42, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(43, Values, aColumnValues, true, 'NULL');
  // Questionare
  AddUpdStrValue(44, Values, aColumnValues, true);
  // Mobile
  AddUpdStrValue(45, Values, aColumnValues, true);
  AddUpdStrValue(46, Values, aColumnValues, true);

  AddUpdIntValue(47, Values, aColumnValues, true, 'NULL');
  // BConnect
  AddUpdDateValue(48, Values, aColumnValues, true, 'NULL');
  AddUpdStrValue(49, Values, aColumnValues, true);
  AddUpdStrValue(50, Values, aColumnValues, true);

  AddUpdIntValue(51, Values, aColumnValues, true, 'NULL');
  // Allow Values
  AddUpdIntValue(52, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(53, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(54, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(55, Values, aColumnValues, true, 'NULL');

  AddUpdIntValue(56, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(57, Values, aColumnValues, true, 'NULL');

  AddUpdStrValue(58, Values, aColumnValues, true);
  AddUpdStrValue(59, Values, aColumnValues, true);
  // IsOverdue
  AddUpdIntValue(60, Values, aColumnValues, true, 'NULL');

  AddUpdStrValue(61, Values, aColumnValues, true);
  AddUpdStrValue(62, Values, aColumnValues, true);

  AddUpdStrValue(63, Values, aColumnValues, true);
  AddUpdStrValue(64, Values, aColumnValues, true);
  AddUpdStrValue(65, Values, aColumnValues, true);
  AddUpdStrValue(66, Values, aColumnValues, true);

  AddUpdStrValue(67, Values, aColumnValues, true);
  AddUpdIntValue(68, Values, aColumnValues, true, 'NULL');
  // ServiceAgreement Present
  AddUpdIntValue(69, Values, aColumnValues, true, 'NULL');
  // Long and Lat
  AddUpdIntValue(70, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(71, Values, aColumnValues, true, 'NULL');

  AddUpdStrValue(72, Values, aColumnValues, true);
  AddUpdStrValue(73, Values, aColumnValues, true);

  AddUpdDateValue(74, Values, aColumnValues, true, 'NULL');

  AddUpdIntValue(75, Values, aColumnValues, true, '0');
  AddUpdIntValue(76, Values, aColumnValues, true, '0');

  AddUpdIntValue(77, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(78, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(79, Values, aColumnValues, true, 'NULL');
  AddUpdIntValue(80, Values, aColumnValues, false, 'NULL');

  Result := Format(UPDATE_PRACTICE_SQL, [Values, aColumnValues.Strings[0]]);
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.FinnishFile(var aFileData: TFileData);
begin
  try
    aFileData.State := fsFinnishing;

    SysUtils.Renamefile(FileDirectory + '\' + aFileData.Name + '.' + RAW_DATA_EXT,
                       FileDirectory + '\' + aFileData.Name + '.' + RAW_DONE_EXT);
    SysUtils.DeleteFile(FileDirectory + '\' + aFileData.Name + '.' + TEMP_EXT);

    aFileData.State := fsDone;
  except
    on E : exception do
    begin
      aFileData.State := fsErrorFinnishing;
      aFileData.Error := E.Message;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.StartService;
begin
  fCurrentServiceStatus := usStarting;

  SetupDatabase(fHostName, fDatabase, fUserName, fPassword);
  fSQLConnection.Connected := true;

  SetServiceState(usWaiting);
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.StopService;
begin
  fCurrentServiceStatus := usStopping;

  fSQLConnection.Connected := false;

  SetServiceState(usStop);
end;

//------------------------------------------------------------------------------
function TUsageDataImporter.SetServiceState(aValue : TServiceState) : boolean;
begin
  Result := false;
  if fCurrentServiceStatus = usStop then
    Exit;

  fCurrentServiceStatus := aValue;
  Result := true;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.DoFolderScanTimer(Sender: TObject);
begin
  if fBusy = true then
    Exit;

  fBusy := true;
  try
    if fCurrentServiceStatus = usStopping then
      StopService();

    if fCurrentServiceStatus = usStarting then
      StartService();

    if fCurrentServiceStatus = usWaiting then
    begin
      SetServiceState(usSearching);

      SearchAndAddFiles(DATA_FOLDER);

      SetServiceState(usProcessing);

      ProcessFiles();

      SetServiceState(usWaiting);
    end;
  finally
    fBusy := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.SetupDatabase(aHostName : string;
                                           aDatabase : string;
                                           aUserName : string;
                                           aPassword : string);
begin
  fSQLConnection := TSQLConnection.Create(Nil);
  fSQLConnection.DriverName    := 'MSSQL';
  fSQLConnection.GetDriverFunc := 'getSQLDriverMSSQL';
  fSQLConnection.LibraryName   := 'dbxmss30.dll';
  fSQLConnection.VendorLib     := 'oledb';
  fSQLConnection.Connected     := false;

  fSQLConnection.Params.Clear;
  fSQLConnection.Params.Add('SchemaOverride=%.dbo');
  fSQLConnection.Params.Add('DriverUnit=DBXDynalink');
  fSQLConnection.Params.Add('DriverPackageLoader=TDBXDynalinkDriverLoader,DBXDynalinkDriver100.bpl');
  fSQLConnection.Params.Add('DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borland.Data.DbxDynalinkDriver,Version=11.0.5000.0,Culture=neutral,PublicKeyToken=91d62ebb5b0d1b1b');
  fSQLConnection.Params.Add('MetaDataPackageLoader=TDBXMsSqlMetaDataCommandFactory,DbxReadOnlyMetaData100.bpl');
  fSQLConnection.Params.Add('MetaDataAssemblyLoader=Borland.Data.TDBXMsSqlMetaDataCommandFactory,Borland.Data.DbxReadOnlyMetaData,Version=11.0.5000.0,Culture=neutral,PublicKeyToken=91d62ebb5b0d1b1b');
  fSQLConnection.Params.Add('HostName='  + aHostName);
  fSQLConnection.Params.Add('DataBase='  + aDatabase);
  fSQLConnection.Params.Add('User_Name=' + aUserName);
  fSQLConnection.Params.Add('Password='  + aPassword);
  fSQLConnection.Params.Add('BlobSize=-1');
  fSQLConnection.Params.Add('ErrorResourceFile=');
  fSQLConnection.Params.Add('LocaleCode=0000');
  fSQLConnection.Params.Add('MSSQL TransIsolation=ReadCommited');
  fSQLConnection.Params.Add('OS Authentication=False');
  fSQLConnection.Params.Add('Prepare SQL=False');

  fSQLDataSet := TSQLDataSet.Create(Nil);
  fSQLDataSet.SQLConnection  := fSQLConnection;
  fSQLDataSet.DbxCommandType := 'Dbx.SQL';
  fSQLDataSet.SchemaName     := 'Dbo';
  fSQLDataSet.Active         := false;

  fSQLQuery := TSQLQuery.Create(Nil);
  fSQLQuery.SQLConnection := fSQLConnection;
end;

//------------------------------------------------------------------------------
constructor TUsageDataImporter.Create;
begin
  fCurrentServiceStatus := usStop;

  fFolderScanTimer := TTimer.Create(nil);
  fFolderScanTimer.Enabled  := true;
  fFolderScanTimer.Interval := TIMER_VALUE;
  fFolderScanTimer.OnTimer  := DoFolderScanTimer;

  fFilesToProcess := TStringList.Create;

  fBusy := false;
end;

//------------------------------------------------------------------------------
destructor TUsageDataImporter.Destroy;
begin
  FreeandNil(fSQLQuery);
  FreeandNil(fSQLDataSet);
  FreeandNil(fSQLConnection);

  FreeandNil(fFilesToProcess);
  FreeandNil(fFolderScanTimer);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.Start;
begin
  if fCurrentServiceStatus in [usStop,usStopping] then
    fCurrentServiceStatus := usStarting;
end;

//------------------------------------------------------------------------------
procedure TUsageDataImporter.Stop;
begin
  if not (fCurrentServiceStatus in [usStop,usStopping]) then
    fCurrentServiceStatus := usStopping;
end;

end.




