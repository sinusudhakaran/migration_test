unit UserReportSettings;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:

  Written:
  Authors:

  Purpose:

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   LADEFS,Printers, PrintMgrObj;

const
   BK_PORTRAIT  = 0;
   BK_LANDSCAPE = 1;
   DEFAULT_PRINTER_ID = 'USE_DEFAULT_PRINTER';

function FindPrinterIndex(DeviceName : string) : integer;
function FindPrinterDeviceName(index : integer) : string;
function GetBKReportDefaultOrientation(RepName :string): TPrinterOrientation;

//set and get a pointer to the report settings
function  GetBKUserReportSettings(PrintManager : TPrintManagerObj; RepName : string) : pWindows_Report_Setting_Rec;
function  GetDefaultReportSettings(const RepName : string ) : pWindows_Report_Setting_Rec;
procedure InsertNewUserReportSettings(PrintManager : TPrintManagerObj; NewSetting : pWindows_Report_Setting_Rec);

//******************************************************************************
implementation
uses
   Globals,
   Reports,
   GraphDefs,
   PrntInfo,
   ReportDefs,
   las7io;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBKUserReportSettings(PrintManager : TPrintManagerObj; RepName : string) : pWindows_Report_Setting_Rec;
begin
  if Assigned(PrintManager) then
    result := PrintManager.pmWindows_Report_Setting_List.Find_Windows_Report_Setting(RepName)
  else
    result := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InsertNewUserReportSettings(PrintManager : TPrintManagerObj; NewSetting : pWindows_Report_Setting_Rec);
begin
  if Assigned(PrintManager) then
     PrintManager.pmWindows_Report_Setting_List.Insert(NewSetting);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FindPrinterIndex(DeviceName : string) : integer;
var
  i : integer;
begin
   result := -1; {default}
   if (DeviceName = DEFAULT_PRINTER_ID) then exit;

   for i := 0 to Pred(Printer.Printers.Count) do
     if (GetPrinterName(i) = DeviceName) then
     begin
       result := i;
       break;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FindPrinterDeviceName(index : integer) : string;
var
  DName : string;
begin
   result := DEFAULT_PRINTER_ID;
   if (index = -1) then exit;

   dName := GetPrinterName(index);
   if dName <> '' then
     result := dNAme;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBKReportDefaultOrientation(RepName :string): TPrinterOrientation;
const
   RN_LANDSCAPE = 'ZZZ';
begin
   if (RepName = RN_LANDSCAPE) or
      (RepName = GRAPH_LIST_NAMES[GRAPH_TRADING_SALES]) or
      (RepName = GRAPH_LIST_NAMES[GRAPH_TRADING_RESULTS]) or
      (RepName = GRAPH_LIST_NAMES[GRAPH_TRADING_PAYMENTS]) or
      (RepName = GRAPH_LIST_NAMES[GRAPH_SUMMARY]) or
      (RepName = GRAPH_LIST_NAMES[GRAPH_BANK_BALANCE]) or
      (RepName = REPORT_LIST_NAMES[Report_Cashflow_12Act]) or
      (RepName = REPORT_LIST_NAMES[Report_Cashflow_12ActBud]) or
      (RepName = REPORT_LIST_NAMES[Report_Profit_12Act]) or
      (RepName = REPORT_LIST_NAMES[Report_Profit_12ActBud]) or
      (RepName = REPORT_LIST_NAMES[REPORT_BUDGET_12CashFlow]) or
      (RepName = REPORT_LIST_NAMES[REPORT_BUDGET_LISTING]) or
      (RepName = REPORT_LIST_NAMES[REPORT_CLIENT_STATUS]) or
      (RepName = REPORT_LIST_NAMES[REPORT_CASHFLOW_MULTIPLE]) or
      (RepName = REPORT_LIST_NAMES[REPORT_PROFITANDLOSS_MULTIPLE]) or
      (RepName = REPORT_LIST_NAMES[REPORT_BALANCESHEET_MULTIPLE]) or
      (RepName = REPORT_LIST_NAMES[Report_List_Entries_With_Notes]) or
      (RepName = REPORT_LIST_NAMES[Report_Coding_Standard_With_Notes]) or
      (RepName = REPORT_LIST_NAMES[Report_Coding_TwoCol_With_Notes]) or
      (RepName = REPORT_LIST_NAMES[REPORT_GST_SUMMARY_12]) or
      (RepName = REPORT_LIST_NAMES[REPORT_GST_ALLOCATIONSUMMARY]) or
      (RepName = 'YYY')
      then
      result := poLandscape
   else
      result := poPortrait;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  GetDefaultReportSettings(const RepName : string ) : pWindows_Report_Setting_Rec;
//Creates a Report Setting Rec and fills it with the defaults
//Should be destroyed if not added to the list of user settings otherwise will
//cause a memory leak.
var
   DefaultSettings : pWindows_Report_Setting_Rec;
begin
   DefaultSettings := New_Windows_Report_Setting_Rec;
   with DefaultSettings^ do begin
      s7Report_Name     := RepName;
      s7Printer_Name    := DEFAULT_PRINTER_ID;

      if GetBKReportDefaultOrientation( RepName) = poPortrait then
         s7Orientation  := BK_PORTRAIT
      else
         s7Orientation  := BK_LANDSCAPE;

      s7Paper           := 9; //DMPAPER_A4 from Windows.pas;
      s7Bin             := 7; //Automatic
      s7Base_Font_Name  := 'Arial';
      s7Base_Font_Size  := 8;
      s7Temp_Font_Scale_Factor := 0;  //scaling is not used by default

      s7Base_Font_Style := 0;
      s7Top_Margin      := 0;
      s7Left_Margin     := 0;
      s7Bottom_Margin   := 0;
      s7Right_Margin    := 0;

      s7Is_Default      := true;
   end;
   result := DefaultSettings;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
