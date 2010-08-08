unit ReportCashflowBase;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Base Cashflow Object which is used by the Cashflow Reports and the Profitability
//Reports. Object provides common routines for both
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ReportTypes,
   NewReportObj, bkdefs, MoneyDef, SignUtils, clObj32, glConst,
   bkConst, ReportDefs, RptParams, Classes;

type
  ATTypeSet = Set of Byte;
  MoneyArray = Array of Money;

  TFinancialValueType = ( ftActual, ftComparative, ftVariance, ftQuantity, ftFullPeriodBudget, ftBudgetRemaining, ftPercentage, ftBudgetQuantity, ftBudgetUnitPrice);
  TColumnTypeArray = Array of TFinancialValueType;
  TValuesArray = Array of Money; //dynamic array


  //This is the base object for the financial reports such as cashflow and 'Profit & Loss'
  //It holds information about the columns in the report and returns useful properties
  //such as the number of columns per period and the number of visible periods

  //The routines for actually retrieveing the report values are abstract routines
  //and must be implemented in the child class.

  //This object provides functionality for printing a report section.
  //All parameters are taken directly from the client file.

  //It is assumed that the account totals have all be calculated prior to calling
  //this object.  An array is constructed that contained the number of accounts
  //that need to be printed in each sub group/report group. The routine that
  //constructs this array also sets a temporary flag in the chart that is used
  //to determine if an account should be printed.

  TFinancialReportBase = class ( TBKReport)
    constructor Create( aClient : TClientObj; aRptParameters: TRptParameters); reintroduce; virtual;
    destructor Destroy; override;
  private
    AccountsToPrintCount : Array [atMin..atMax, 0..Max_SubGroups] of integer;
    FClientForReport     : TClientObj;
    FMaxPeriod           : integer;
    FMinPeriod           : integer;
    FVisiblePeriods      : integer;
    FReportScaleFactor   : double;
    procedure SetMinAndMaxPeriods;
    procedure SetClientForReport(const Value: TClientObj);
    function  GetColumnsPerPeriod: integer;
    procedure SetReportScaleFactor(const Value: double);
    function GetPercentColumnsPerPeriod: integer;
  protected
    FColumnTypes          : TColumnTypeArray;
    FControlAccountsToPrint: TStringList;
    FDoPercentage         : Boolean;
    FSuppressPercentage   : Boolean;
    FRptParameters       : TRptParameters;
    procedure AddColumnTypeToArray( NewType : TFinancialValueType);
    procedure ClearColumnTypeArray;
    function  ReportGroupNeedsPrinting( ReportGroup : byte) : boolean;
    function  AccountNeedsPrinting( pAcct : pAccount_Rec) : boolean; virtual;
    procedure PrintControlAccountTitle( aAccount: pAccount_Rec);
    procedure PrintValuesForPeriod( const Values : TValuesArray; DefaultSign : TSign);
    procedure SetCurrencyFormatForPeriod(const Values : TValuesArray; NewFormat: string);
    procedure SkipPeriod;

    function  GetHeading( No : Integer): string; virtual; abstract;

    procedure GetValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); virtual; abstract;
    procedure GetYTD_ValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); virtual; abstract;
    procedure SetupColumnsTypes; virtual; abstract;
  public
    property  ClientForReport : TClientObj read FClientForReport write SetClientForReport;
    property  ColumnsPerPeriod : integer read GetColumnsPerPeriod;
    property  PercentColumnsPerPeriod : integer read GetPercentColumnsPerPeriod;
    property  MinPeriodToShow : integer read FMinPeriod;
    property  MaxPeriodToShow : integer read FMaxPeriod;
    property  iVisiblePeriods : integer read FVisiblePeriods;
    property  ReportScaleFactor : double read FReportScaleFactor write SetReportScaleFactor;
    property  ControlAccountsToPrint: TStringList read FControlAccountsToPrint;
    property  ColumnTypes: TColumnTypeArray read FColumnTypes;

    function  ReportSectionNeedsPrinting( ReportGroupsSet : ATTypeSet) : boolean;
    function  SubGroupNeedsPrinting( ReportGroupSet : ATTypeSet; SubGroup : integer) : boolean;
    function  GetControlAccount( aAccount: pAccount_Rec): pAccount_Rec;
    function  GetDivisionSubHeading(aDivision : integer = 0): string;
    procedure LoadAccountsToPrint;
    procedure PrintSection(ReportGroupsSet: ATTypeSet; SectionHeadingId: integer;
                           SectionTotalId: Integer; DefaultSign: TSign;
                           Style: TStyleTypes = siSectionTotal
                           );
    procedure PrintTotalsArray( const Title : string;
                                TotalsArray : TValuesArray; DefaultSign : TSign;
                                Style: TStyleTypes = siSectionTotal);
    procedure PrintSectionWithControlAccnt(ReportGroupsSet: ATTypeSet;
      SectionHeadingId: integer; SectionTotalId: Integer; DefaultSign: TSign;
      Style: TStyleTypes = siSectionTotal);
    procedure PrintSectionWithSubGroupAndControlAccnt(ReportGroupsSet: ATTypeSet;
      SectionHeadingId: integer; SectionTotalId: Integer; DefaultSign: TSign;
      Style: TStyleTypes = siSectionTotal);
    procedure PrintDetailForAccount( pAcct : pAccount_Rec;
                                     DefaultSignForSection : TSign);
    procedure PrintCtrlAcctsAndAccounts(ReportGroupsSet: ATTypeSet;
                                        SubGroupNo: integer;
                                        DefaultSign: TSign;
                                        var LinesPrinted: integer);

    procedure BKPrint; override;
    procedure Generate(Dest: TReportDest;Params : TRptParameters = nil; Preview: Boolean = True; AskToOpen: Boolean = True); override;
    procedure ResetControlAccounts;
  end;

  function ExcelAddress( const Value : integer; Row : integer) : string;

  function GetGSTString(aClient : TClientObj) : string;

//******************************************************************************
implementation

uses
  chList32,
  Math,
  sysUtils,
  CustomHeadingsListObj;

const
   UnitName = 'REPORTCASHFLOWBASE';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ExcelAddress(const Value: integer;
  Row: integer): string;
var
  i : integer;
  Col : integer;
begin
  Col := Value + 1;  //value starts at 0 for first col
  i   := 0;
  while Col > 26 do begin
     Inc( i);
     Col := Col - 26
  end;
  if i > 0 then
     result := Chr( 64 + i) + Chr( 64 + Col)
  else
     result := Chr(64 + Col);

  result := result + inttostr( Row);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGSTString(aClient : TClientObj) : string;
//returns a string as to whether the report is gst inclusive or exclusive,
//depends on if the client uses GST
Var
  TaxName : String;
begin
  TaxName := aClient.TaxSystemNameUC;
  if aClient.clFields.clGST_Inclusive_Cashflow then
    result := ' (Incl ' + TaxName + ') '
  else
    result := ' (Excl ' + TaxName + ') ';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ TFinancialReportBase }

function TFinancialReportBase.AccountNeedsPrinting( pAcct: pAccount_Rec): boolean;
//needs printing if has values if any period that is visible, including ytd
var
  i           : integer;
  ValuesArray : TValuesArray;
  PeriodNo    : integer;
begin
  result := false;
  SetLength( ValuesArray, ColumnsPerPeriod);

  //see if anything in periodic columns
  for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
    if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
      //GetValues
      GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
      //see if anything there
      for i := Low( ValuesArray) to High( ValuesArray) do
        if ValuesArray[i] <> 0 then begin
          result := true;
          Exit;
        end;
    end;
  end;

  //see if anything in ytd columns
  if ClientForReport.clFields.clFRS_Show_YTD then begin
     //GetYTDValues
     GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
     //see if anything there
     for i := Low( ValuesArray) to High( ValuesArray) do
       if ValuesArray[i] <> 0 then begin
         result := true;
         Exit;
       end;
  end;
end;

procedure TFinancialReportBase.AddColumnTypeToArray(
  NewType: TFinancialValueType);
//elements in the dynamic array are retained when the array is extended
//the elements in this array are used by the GetValues routines to determine
//which value to retrieve
begin
  SetLength( FColumnTypes, Length( FColumnTypes) + 1);
  FColumnTypes[ High( FColumnTypes)] := NewType;
end;

procedure TFinancialReportBase.BKPrint;
begin
  inherited;
end;

procedure TFinancialReportBase.ClearColumnTypeArray;
begin
  FColumnTypes := nil;
end;

constructor TFinancialReportBase.Create( aClient : TClientObj; aRptParameters: TRptParameters);
begin
  Inherited Create(rptFinancial);
  FSuppressPercentage := False;
  ClientForReport := aClient;
  FRptParameters := aRptParameters;
  if Assigned(ClientForReport) then
    FDoPercentage := ClientForReport.clFields.clProfit_Report_Show_Percentage;

  FReportScaleFactor := 1.0;

  //The following values can be loaded from the client
  SetupColumnsTypes;
  SetMinAndMaxPeriods;

  FControlAccountsToPrint := TStringList.Create;
  LoadAccountsToPrint;
end;

destructor TFinancialReportBase.Destroy;
begin
  FControlAccountsToPrint.Free;
  inherited;
end;

procedure TFinancialReportBase.Generate(Dest: TReportDest;Params : TRptParameters = nil; Preview: Boolean = True; AskToOpen: Boolean = True);
begin
  UserReportSettings.s7Temp_Font_Scale_Factor := ReportScaleFactor;
  inherited;
end;

function TFinancialReportBase.GetColumnsPerPeriod: integer;
begin
    result := Length( FColumnTypes); //add 1 because array starts at zero
end;

function TFinancialReportBase.GetControlAccount(
  aAccount: pAccount_Rec): pAccount_Rec;
var
  i: integer;
  pAcct: pAccount_Rec;
begin
  Result := nil;
  for i := 0 to Pred( FControlAccountsToPrint.Count) do begin
    pAcct := pAccount_Rec(FControlAccountsToPrint.Objects[i]);
    if (pAcct <> aAccount) and
       (pAcct.chAccount_Code <> '') and
       (pAcct.chAccount_Type = aAccount.chAccount_Type) and
       (AnsiPos(pAcct.chAccount_Code, aAccount.chAccount_Code) = 1) then begin
      Result := pAcct;
    end;
  end;
end;

function TFinancialReportBase.GetDivisionSubHeading(aDivision: integer): string;
const
  DIVISION_PREFIX_SINGLE = 'For Division: ';
  DIVISION_PREFIX_MULTI = 'For Divisions: ';
var
  i: integer;
  DivisionList: TStringList;
  DivisionArray: DynamicBooleanArray;
begin
  Result := DIVISION_PREFIX_SINGLE;
  DivisionArray := ClientForReport.clFields.clTemp_FRS_Divisions;
  //Single Division
  if (Length(DivisionArray) = 0) or (ClientForReport.clFields.clTemp_FRS_Split_By_Division) then begin
    if aDivision = 0 then
      Result := Result + '(No Division Allocated)'
    else
      Result := Result + ClientForReport.clCustom_Headings_List.Get_Division_Heading(aDivision)
  end else begin
    //Multiple Divisions
    DivisionList := TStringList.Create;
    try
      for i := 0 to Length(DivisionArray) - 1 do
        if DivisionArray[i] then
          if (i = 0) then
            DivisionList.Add('(No Division Allocated)')
          else
            DivisionList.Add(ClientForReport.clCustom_Headings_List.Get_Division_Heading(i));
      if DivisionList.Count > 1 then
        Result := DIVISION_PREFIX_MULTI;
      for i := 0 to DivisionList.Count - 1 do
        if i = 0 then
          Result := Format('%s%s',[Result, DivisionList[i]])
        else
          Result := Format('%s, %s',[Result, DivisionList[i]]);
    finally
      DivisionList.Free;
    end;
  end;
end;

function TFinancialReportBase.GetPercentColumnsPerPeriod: integer;
var i : Integer;
begin
   Result := 0;
   for i := Low(FColumnTypes) to High(FColumnTypes) do
     if FColumnTypes[i] = ftPercentage then
       inc(Result)
end;

procedure TFinancialReportBase.LoadAccountsToPrint;
//load the count array and set the temporary flag in the account rec
//this should negate the need to check the values so many times during the
//report
var
   i : integer;
   pAcct : pAccount_Rec;
begin
  FillChar( AccountsToPrintCount, SizeOf(AccountsToPrintCount), #0);
  FControlAccountsToPrint.Clear;

  for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
    pAcct := FRptParameters.Chart.Account_At(i);
    pAcct^.chTemp_Include_In_Report := false;
    if AccountNeedsPrinting( pAcct) then begin
      Inc( AccountsToPrintCount[ pAcct^.chAccount_Type, pAcct^.chSubtype]);
      pAcct^.chTemp_Include_In_Report := true;
    end else if not pAcct^.chPosting_Allowed then begin
      FControlAccountsToPrint.AddObject(pAcct^.chAccount_Code + '=0', Pointer(pAcct));
    end;
  end;
end;

procedure TFinancialReportBase.PrintControlAccountTitle(aAccount: pAccount_Rec);
var
  pAcct: pAccount_Rec;
begin
  pAcct := GetControlAccount( aAccount);
  if Assigned(pAcct) then begin
    //Output title
    if (FControlAccountsToPrint.Values[pAcct.chAccount_Code] = '0') then begin
      if ClientForReport.clFields.clFRS_Print_Chart_Codes then
        RenderTextLine( pAcct.chAccount_Code + ' ' + pAcct.chAccount_Description, True, False)
      else
        RenderTextLine( pAcct.chAccount_Description, True, False);
      //Flag so title is not output again
      FControlAccountsToPrint.Values[pAcct.chAccount_Code] := '1';
    end;
  end;
end;

procedure TFinancialReportBase.PrintCtrlAcctsAndAccounts(
  ReportGroupsSet: ATTypeSet; SubGroupNo: integer;
  DefaultSign: TSign; var LinesPrinted: integer);
var
  i, j: integer;
  HasSubAccounts: boolean;
  pAcct, pCtrlAcct, pLastCtrlAcct: pAccount_Rec;
  TotalsArray: TValuesArray;
  TotalsArrayPos: integer;
  ValuesArray: TValuesArray;
  SectionHeading: string;
  NumOfTotals, PeriodNo: integer;
begin
  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil these afterward
  NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
  SetLength( TotalsArray, NumOfTotals );
  HasSubAccounts := False;
  pLastCtrlAcct := nil;

  //Control accounts
  for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
    pAcct := FRptParameters.Chart.Account_At(i);
    pCtrlAcct := GetControlAccount(pAcct);
    if (i = 0) then
      pLastCtrlAcct := pCtrlAcct;

    //Output Totals if control account changes
    if HasSubAccounts and (pLastCtrlAcct <> pCtrlAcct) then begin
      PrintTotalsArray( SectionHeading, TotalsArray, DefaultSign, siDetail);
      Inc(LinesPrinted);
      HasSubAccounts := False;
      //clear totals
      for j := Low(TotalsArray) to High(TotalsArray) do
        TotalsArray[j] := 0;
      if Assigned(pLastCtrlAcct) then
        //Flag so not output again
        FControlAccountsToPrint.Values[pLastCtrlAcct.chAccount_Code] := '1';
    end;

    if Assigned(pCtrlAcct) and (pAcct.chSubtype = SubGroupNo) then begin
      if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
        //add values for this accounts to the totals
        TotalsArrayPos := 0;

        for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);

            //Add account values to report group total
            for j := Low( ValuesArray) to High( ValuesArray) do begin
               TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
               Inc(TotalsArrayPos);
            end;
          end
          else
            Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;
        //add YTD values to totals
        GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
        //Add account values to report group total
        for j := Low( ValuesArray) to High( ValuesArray) do begin
           TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
           Inc(TotalsArrayPos);
        end;
        HasSubAccounts := True;
        if ClientForReport.clFields.clFRS_Print_Chart_Codes then
          SectionHeading := pCtrlAcct.chAccount_Code + ' ' + pCtrlAcct.chAccount_Description
        else
          SectionHeading := pCtrlAcct.chAccount_Description;
        pLastCtrlAcct := pCtrlAcct;
      end;
    end else begin
      //Accounts
      if (pAcct.chSubtype = SubGroupNo) then begin //Has matching sub-group
        if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
          //Print Account Info
          PrintDetailForAccount( pAcct, DefaultSign);
          Inc(LinesPrinted);
        end;
      end;
    end;
  end;
end;

procedure TFinancialReportBase.PrintDetailForAccount(pAcct: pAccount_Rec;
                                                     DefaultSignForSection : TSign);
//prints the account description and the prints all of the required
//columns for this account
var
  sAccountDesc : string;
  PeriodNo     : integer;
  ValuesArray  : TValuesArray;
begin
  if ClientForReport.clExtra.ceFRS_Print_NP_Chart_Code_Titles then
    PrintControlAccountTitle(pAcct);

  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil this afterward
                                              //delphi will handle it through
                                              //reference counting
  //Print Account Info
  if ClientForReport.clFields.clFRS_Print_Chart_Codes then begin
     sAccountDesc := Trim( pAcct^.chAccount_Code) + ' ' + Trim( pAcct^.chAccount_Description);
  end
  else
     sAccountDesc := Trim( pAcct^.chAccount_Description);
  PutString( sAccountDesc);

  //Print Periodic Information
  for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
    if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
      //GetValues
      GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
      //PrintValues
      PrintValuesForPeriod( ValuesArray, DefaultSignForSection);
    end
    else
       SkipPeriod;
  end;

  //Period YTD Information
  if ClientForReport.clFields.clFRS_Show_YTD then begin
     //GetYTDValues
     GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
     //PrintValues
     PrintValuesForPeriod( ValuesArray, DefaultSignForSection);
  end;

  RenderDetailLine;
end;

procedure TFinancialReportBase.PrintSection(
              ReportGroupsSet: ATTypeSet; SectionHeadingId: integer;
              SectionTotalId: Integer; DefaultSign: TSign;
              Style: TStyleTypes = siSectionTotal
              );
var
  sSectionHeading        : string;
  sSectionTotal          : string;
  sSubGroupHeading       : string;
  sSubGroupTotal         : string;

  i,j,k                  : integer;
  pAcct                  : pAccount_Rec;
  ValuesArray            : TValuesArray;
  TotalsArray            : TValuesArray;
  NumOfTotals            : integer;
  TotalsArrayPos         : integer;

  iLinesPrinted          : integer;

  HasSubGroups           : boolean;
  SubGroupNo             : integer;
  PeriodNo               : integer;

  ControlAcct            : pAccount_Rec;
  LastControlAcct        : pAccount_Rec;
  //Flags to track the start and end of each group
  StartSection         : boolean;
  StartSubGroup        : boolean;
  HasControlAcct       : boolean;
begin
  sSectionHeading := GetHeading( SectionHeadingId);
  sSectionTotal   := GetHeading( SectionTotalId);
  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil these afterward
                                              //delphi will handle it through
                                              //reference counting

  //See if section has report groups with sub groups, and count no of report groups
  HasSubGroups := false;
  //see if has sub groups
  for i := 1 to Max_SubGroups do
    HasSubGroups := HasSubGroups or ( SubGroupNeedsPrinting( ReportGroupsSet, i));

  //test to see if the report is detailed or summarised
  if ClientForReport.clFields.clFRS_Report_Detail_Type = cflReport_Detailed then begin
    if sSectionHeading <> '' then
      RenderTitleLine( sSectionHeading);

    if not HasSubGroups then begin    
      if (ClientForReport.clExtra.ceFRS_NP_Chart_Code_Detail_Type = cflReport_Summarised) then begin
        //1. DETAILED, NO SUB GROUPS, SUMMARISED CONTROL ACCOUNTS
        PrintSectionWithControlAccnt(ReportGroupsSet, SectionHeadingId,
                                     SectionTotalId, DefaultSign, Style);
      end else begin
        //2. DETAILED, NO SUB GROUPS, DETAILED CONTROL ACCOUNTS
        StartSection := True;
        HasControlAcct := False;
        iLinesPrinted := 0;
        LastControlAcct := nil;
        ControlAcct := nil;
        for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
          pAcct := FRptParameters.Chart.Account_At(i);
          if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
            if ClientForReport.clExtra.ceFRS_Print_NP_Chart_Code_Titles then begin
              ControlAcct := GetControlAccount(pAcct);
              //Add extra line after control acct group
              if (ControlAcct = nil) and (LastControlAcct <> nil) then begin
                RenderTextLine('');
                Inc(iLinesPrinted);
                LastControlAcct := nil;
              end;
              //Add extra line before control acct group
              if (not StartSection) and (ControlAcct <> nil) and (ControlAcct <> LastControlAcct)  then begin
                RenderTextLine('');
                Inc(iLinesPrinted);
                HasControlAcct := True;
              end;
            end;
            //Print Account Info
            PrintDetailForAccount( pAcct, DefaultSign);
            Inc(iLinesPrinted);
            StartSection := False;
            LastControlAcct := ControlAcct;
          end;
        end;
        //print total
        if iLinesPrinted > 1 then begin
           if HasControlAcct then
             RenderTextLine('');
           RenderDetailSubTotal( sSectionTotal, DefaultSign, Style);
        end;

        ClearSubTotals;
      end;
    end
    else begin
      if (ClientForReport.clExtra.ceFRS_NP_Chart_Code_Detail_Type = cflReport_Summarised) then begin
        //3. DETAILED, SUB GROUPS, SUMMARISED CONTROL ACCOUNTS
        PrintSectionWithSubGroupAndControlAccnt(ReportGroupsSet, SectionHeadingId, 
                                                SectionTotalId, DefaultSign, Style); 
      end else begin
        //4. DETAILED, SUB GROUPS, DETAILED CONTROL ACCOUNTS
        //Has Sub Groups.  Print sub groups within each report group
        {
          Totaling levels:

          Section
            Sub Group 1
            ...
            Total Sub Group1              Sub Section Total
            Sub Groups 2
            ...
            Total Sub Group 2             Sub Section Total
          Total Section                     Sub Total
        }
        StartSubGroup := False;
        for j := 1 to Max_SubGroups + 1 do begin
          iLinesPrinted := 0;
          //do all sub groups first, this do unassigned account codes
          if ( j > Max_SubGroups) then
            SubGroupNo := 0
          else
            SubGroupNo := j;

          if SubGroupNeedsPrinting( ReportGroupsSet, SubGroupNo) then begin
            StartSubGroup := True;
            sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);

            if (sSubGroupHeading <> '') then
              RenderTitleline(sSubGroupHeading)
            else
              RenderTextLine( '');

            //cycle thru accounts
            HasControlAcct := False;
            LastControlAcct := nil;
            ControlAcct := nil;
            for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
              pAcct := FRptParameters.Chart.Account_At(i);
              if ( pAcct^.chAccount_Type in ReportGroupsSet)
                and ( pAcct^.chSubtype   = SubGroupNo)
                and ( pAcct^.chTemp_Include_In_Report) then
              begin
                if ClientForReport.clExtra.ceFRS_Print_NP_Chart_Code_Titles then begin
                  //Add extra line after control acct group
                  ControlAcct := GetControlAccount(pAcct);
                  if (ControlAcct = nil) and (LastControlAcct <> nil) then begin
                    RenderTextLine('');
                    Inc( iLinesPrinted);
                    LastControlAcct := nil;
                  end;
                  //Add extra line before control acct group
                  if (not StartSection) and (not StartSubGroup) and 
                     (ControlAcct <> nil) and (ControlAcct <> LastControlAcct)  then begin
                    RenderTextLine('');
                    Inc( iLinesPrinted);
                  end;
                  if (ControlAcct <> nil) then
                    HasControlAcct := True;
                end;
                PrintDetailForAccount( pAcct, DefaultSign);
                Inc( iLinesPrinted);
                StartSubGroup := False;
                LastControlAcct := ControlAcct;
              end;
            end;

            //check how many accounts printed for this sub group
            if iLinesPrinted > 1 then begin
               sSubGroupTotal := '';
               if not (SubGroupNo = 0) then begin
                 if sSubGroupHeading <> '' then
                   sSubGroupTotal := 'Total ' + sSubGroupHeading;
               end;
               //Add line before totals of section has control acct
               if HasControlAcct then
                 RenderTextLine('');
               RenderDetailSubSectionTotal(sSubGroupTotal, DefaultSign);
            end;
            //finished this subgroup
            ClearSubSectionTotal;
            //Reset control accounts so headings are printed again
            for i := 0 to Pred( FControlAccountsToPrint.Count) do
              FControlAccountsToPrint.ValueFromIndex[i] := '0';
          end; //subgroup needs printing
        end; //cycle round sub groups
        ClearSectionTotal;

        //Always print section total if has sub groups
        RenderDetailSubTotal( sSectionTotal, DefaultSign, Style);
        ClearSubTotals;
      end; //has sub groups
    end;  
  end
  else
  begin
    //Report is Summarised.  This means that only report groups or sub groups
    //should be shown on the report.  It also means that we need to total up
    //the values for individual accounts in each report group/sub group

    //get totals, make enough space for the total for each period plus YTD
    //note: The size of the values array was set earlier to ColumnsPerPeriod
    NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
    SetLength( TotalsArray, NumOfTotals );
    //clear totals
    for i := Low(TotalsArray) to High(TotalsArray) do
       TotalsArray[i] := 0;

    if not HasSubGroups then
    begin
      //5. SUMMARISED, NO SUB GROUPS
      //show total for this section
      //cycle thru accounts, load values into array
      for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
        pAcct := FRptParameters.Chart.Account_At(i);
        if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
          //add values for this accounts to the totals
          TotalsArrayPos := 0;

          for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
            if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
              //GetValues
              GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);

              //Add account values to report group total
              for j := Low( ValuesArray) to High( ValuesArray) do begin
                 TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
                 Inc(TotalsArrayPos);
              end;
            end
            else
              Inc(TotalsArrayPos, ColumnsPerPeriod);
          end;
          //add YTD values to totals
          GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
          //Add account values to report group total
          for j := Low( ValuesArray) to High( ValuesArray) do begin
             TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
             Inc(TotalsArrayPos);
          end;
        end;
      end;

      //now print results, need to load values back into a value array for printing
      PrintTotalsArray( sSectionHeading, TotalsArray, DefaultSign, Style);
      ClearSubTotals;
    end
    else begin
      //6. SUMMARISED SUBGROUPS
      //print sub groups within each report group
      //load totals for each sub groups
      //show report group total if more than one sub group
      if sSectionHeading <> '' then
        RenderTitleLine( sSectionHeading);

      for j := 1 to Max_SubGroups + 1 do begin
        //do all sub groups first, this do unassigned account codes
        if ( j > Max_SubGroups) then
          SubGroupNo := 0
        else
          SubGroupNo := j;

        //clear totals
        for i := Low(TotalsArray) to High(TotalsArray) do
           TotalsArray[i] := 0;

        if SubGroupNeedsPrinting( ReportGroupsSet, SubGroupNo) then begin
          sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
          //cycle thru accounts, load values into array
          for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
            pAcct := FRptParameters.Chart.Account_At(i);
            if ( pAcct^.chAccount_Type in ReportGroupsSet)
               and ( pAcct^.chSubtype  = SubGroupNo)
               and ( pAcct^.chTemp_Include_In_Report) then
            begin
              //add values for this accounts to the totals
              TotalsArrayPos := 0;

              for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
                if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
                  //GetValues
                  GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);

                  //Add account values to report group total
                  for k := Low( ValuesArray) to High( ValuesArray) do begin
                     TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[k];
                     Inc(TotalsArrayPos);
                  end;
                end
                else
                  Inc(TotalsArrayPos, ColumnsPerPeriod);
              end;
              //add YTD values to totals
              GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
              //Add account values to report group total
              for k := Low( ValuesArray) to High( ValuesArray) do begin
                 TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[k];
                 Inc(TotalsArrayPos);
              end;
            end;
          end;

          //now print results, need to load values back into a value array for printing
          PrintTotalsArray( sSubGroupHeading, TotalsArray, DefaultSign);
          ClearSectionTotal;
        end; //subgroup needs printing
      end; //cycle round sub groups
      ClearSectionTotal;

      //Always print section total if has sub groups
      RenderDetailSubTotal( sSectionTotal, DefaultSign, Style);
      ClearSubTotals;
    end; //has sub groups
  end;
end;

procedure TFinancialReportBase.PrintSectionWithControlAccnt(
  ReportGroupsSet: ATTypeSet; SectionHeadingId, SectionTotalId: Integer;
  DefaultSign: TSign; Style: TStyleTypes);
var
  HasSubAccounts: boolean;
  i, j: integer;
  LinesPrinted: integer;
  NumOfTotals: integer;
  pAcct, pCtrlAcct, pLastCtrlAcct: pAccount_Rec;
  PeriodNo: integer;
  SectionHeading, SectionTotal: string;
  TotalsArray: TValuesArray;
  TotalsArrayPos: integer;
  ValuesArray: TValuesArray;
begin
  //DETAILED SECTION WITH SUMMARISED CONTROL ACCOUNTS
  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil these afterward
  NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
  SetLength( TotalsArray, NumOfTotals );
  SectionTotal := GetHeading( SectionTotalId);

  //Clear totals
  for i := Low(TotalsArray) to High(TotalsArray) do
    TotalsArray[i] := 0;

  //For each chart code that is not a control account
  HasSubAccounts := False;
  pLastCtrlAcct := nil;
  LinesPrinted := 0;
  for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
    pAcct := FRptParameters.Chart.Account_At(i);
    pCtrlAcct := GetControlAccount(pAcct);

    //Output Totals if control account changes
    if HasSubAccounts and (pLastCtrlAcct <> pCtrlAcct) then begin
      PrintTotalsArray( SectionHeading, TotalsArray, DefaultSign, siDetail);
      Inc(LinesPrinted);
      HasSubAccounts := False;
      //clear totals
      for j := Low(TotalsArray) to High(TotalsArray) do
        TotalsArray[j] := 0;
    end;

    if Assigned(pCtrlAcct) then begin
      if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
        //add values for this accounts to the totals
        TotalsArrayPos := 0;

        for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);

            //Add account values to report group total
            for j := Low( ValuesArray) to High( ValuesArray) do begin
               TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
               Inc(TotalsArrayPos);
            end;
          end
          else
            Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;
        //add YTD values to totals
        GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
        //Add account values to report group total
        for j := Low( ValuesArray) to High( ValuesArray) do begin
           TotalsArray[ TotalsArrayPos] := TotalsArray[ TotalsArrayPos] + ValuesArray[j];
           Inc(TotalsArrayPos);
        end;
        HasSubAccounts := True;
        if ClientForReport.clFields.clFRS_Print_Chart_Codes then
          SectionHeading := pCtrlAcct.chAccount_Code + ' ' + pCtrlAcct.chAccount_Description
        else
          SectionHeading := pCtrlAcct.chAccount_Description;
        pLastCtrlAcct := pCtrlAcct;
      end;
    end else begin
      //Output total for account that doesn't have a control account
      if ( pAcct^.chAccount_Type in ReportGroupsSet) and ( pAcct^.chTemp_Include_In_Report) then begin
        //Print Account Info
        PrintDetailForAccount( pAcct, DefaultSign);
        Inc(LinesPrinted);
      end;
    end;
  end;

  //print total
  if LinesPrinted > 1 then begin
     RenderDetailSubTotal( SectionTotal, DefaultSign, Style);
  end;
  ClearSubTotals;
end;

procedure TFinancialReportBase.PrintSectionWithSubGroupAndControlAccnt(
  ReportGroupsSet: ATTypeSet; SectionHeadingId, SectionTotalId: Integer;
  DefaultSign: TSign; Style: TStyleTypes);
var
  HasSubAccounts: boolean;
  i, j: integer;
  LinesPrinted: integer;
  NumOfTotals: integer;
  pAcct, pCtrlAcct, pLastCtrlAcct: pAccount_Rec;
  PeriodNo: integer;
  SectionHeading, SubGroupHeading, SubGroupTotal, SectionTotal: string;
  TotalsArray: TValuesArray;
  TotalsArrayPos: integer;
  ValuesArray: TValuesArray;
  SubGroupNo: integer;
begin
  //DETAILED SECTION WITH SUMMARISED CONTROL ACCOUNTS

  //Print Sub-Section Heading
  //  Print Control Account Summaries
  //  Print non-control accounts

  SectionTotal := GetHeading( SectionTotalId);
  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil these afterward
  NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
  SetLength( TotalsArray, NumOfTotals );

  //do all sub groups first, then do unassigned account codes
  for j := 1 to Max_SubGroups + 1 do begin

    //do all sub groups first, this do unassigned account codes
    if (j > Max_SubGroups) then
      SubGroupNo := 0
    else
      SubGroupNo := j;

    if SubGroupNeedsPrinting( ReportGroupsSet, SubGroupNo) then begin
      //Sub group heading
      SubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
      if SubGroupHeading = '' then
        RenderTextLine( '')
      else
        RenderTitleline(SubGroupHeading);

      //Reset control accounts so headings are printed again
      for i := 0 to Pred( FControlAccountsToPrint.Count) do
        FControlAccountsToPrint.ValueFromIndex[i] := '0';

      //Clear totals
      for i := Low(TotalsArray) to High(TotalsArray) do
        TotalsArray[i] := 0;

      HasSubAccounts := False;
      LinesPrinted := 0;

      PrintCtrlAcctsAndAccounts(ReportGroupsSet, SubGroupNo, DefaultSign, LinesPrinted);

      //check how many accounts printed for this sub group
      if LinesPrinted > 1 then begin
         SubGroupTotal := '';
         if SubGroupHeading <> '' then
           SubGroupTotal := 'Total ' + SubGroupHeading;
         RenderDetailSubSectionTotal(SubGroupTotal, DefaultSign);
      end;

      //finished this subgroup
      ClearSubSectionTotal;
    end; //Sub group needs printing
  end; //cycle round sub groups

  ClearSectionTotal;
  //Always print section total if has sub groups
  RenderDetailSubTotal( SectionTotal, DefaultSign, Style);
  ClearSubTotals;
end;

procedure TFinancialReportBase.PrintTotalsArray( const Title: string;
                                                 TotalsArray: TValuesArray;
                                                 DefaultSign: TSign;
                                                 Style: TStyleTypes = siSectionTotal);

var
  PeriodNo    : integer;
  j           : integer;
  ValuesArray : TValuesArray;
  TotalsArrayPos : integer;
begin
  SetLength( ValuesArray, ColumnsPerPeriod);
  TotalsArrayPos := 0;

  PutString(Title);

  for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
    if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
      //GetValues
      for j := Low( ValuesArray) to High( ValuesArray) do begin
         ValuesArray[j] := TotalsArray[ TotalsArrayPos];
         Inc(TotalsArrayPos);
      end;
      //PrintValues
      PrintValuesForPeriod( ValuesArray, DefaultSign);
    end
    else begin
      SkipPeriod;
      Inc(TotalsArrayPos, ColumnsPerPeriod);
    end;
  end;

  if ClientForReport.clFields.clFRS_Show_YTD then begin
    //GetValues
    for j := Low( ValuesArray) to High( ValuesArray) do begin
       ValuesArray[j] := TotalsArray[ TotalsArrayPos];
       Inc(TotalsArrayPos);
    end;
    //PrintValues
    PrintValuesForPeriod( ValuesArray, DefaultSign);
  end;

  RenderDetailLine(True, Style);
end;

procedure TFinancialReportBase.PrintValuesForPeriod( const Values: TValuesArray;
                                                     DefaultSign : TSign);
var
  i : integer;
begin
  Assert( Length( FColumnTypes) = Length( Values), 'PrintValuesForPeriod : failed Length( ColumnTypes) = Length( Values)');

  for i := Low(Values) to High(Values) do begin
     if FColumnTypes[i] in [ ftQuantity, ftBudgetQuantity] then
        PutQuantity(Values[i], DefaultSign)
     else if FColumnTypes[i] =  ftPercentage then
        if FSuppressPercentage then
           AddPercentage(Values[i],true,DefaultSign)
        else
           PutPercentage(Values[i],true,DefaultSign)
     else
        PutMoney(Values[i], DefaultSign);
  end;
end;

function TFinancialReportBase.ReportGroupNeedsPrinting(
  ReportGroup: byte): boolean;
//checks each sub group to determine if they need printing
var
  SubGroup    : integer;
begin
  result := false;
  for SubGroup := 0 to Max_SubGroups do
    if SubGroupNeedsPrinting( [ReportGroup], SubGroup) then begin
      result := true;
      Exit;
    end;
end;

function TFinancialReportBase.ReportSectionNeedsPrinting(
  ReportGroupsSet: ATTypeSet): boolean;
//assumes that the AccountsToPrint array will have been loaded
//checks each report group to see if it needs printing
var
  ReportGroup : integer;
begin
  result := false;
  for ReportGroup := atMin to atMax do begin
    if ReportGroup in ReportGroupsSet then begin
      if ReportGroupNeedsPrinting( ReportGroup) then begin
        result := true;
        exit;
      end;
    end;
  end;
end;

procedure TFinancialReportBase.ResetControlAccounts;
var
  i: integer;
begin
  for i := 0 to Pred(FControlAccountsToPrint.Count) do
    FControlAccountsToPrint.ValueFromIndex[i] := '0';
end;

procedure TFinancialReportBase.SetClientForReport(const Value: TClientObj);
begin
  FClientForReport := Value;
end;

procedure TFinancialReportBase.SetCurrencyFormatForPeriod(const Values : TValuesArray; NewFormat: string);
var
  i : integer;
begin
  Assert( Length( FColumnTypes) = Length( Values), 'SetCurrencyFormatForPeriod : failed Length( ColumnTypes) = Length( Values)');

  for i := Low(Values) to High(Values) do begin
     if not (FColumnTypes[i] in [ ftQuantity, ftBudgetQuantity,ftPercentage]) then
        Columns.Report_Column_At(FCurrDetail.Count + i ).FormatString := NewFormat;
  end;
end;

procedure TFinancialReportBase.SetMinAndMaxPeriods;
//this routine is important because it sets up the following properties
//   MaxPeriodToShow
//   MinPeriodToShow
//   iVisiblePeriods
//
//the properties are are constructed from the parameters in the client file.
//they are used when constructing the columns in the report and when filling
//those columns with values.
begin
  with ClientForReport.clFields do begin
    case clFRS_Report_Style of
      crsSinglePeriod :  begin
        FMinPeriod := clTemp_FRS_last_Period_To_Show;
        FMaxPeriod := clTemp_FRS_last_Period_To_Show;
        FVisiblePeriods := 1;
      end;
      crsBudgetRemaining : begin
        FMinPeriod := 0;
        FMaxPeriod := -1;  //set to -1 so that none of the for loops are entered
                           //ie.  For i := Min to Max ...
        FVisiblePeriods := 0;
      end;
      else begin
        FMinPeriod := 1;
        //if we are showing periods for last year then need to check that
        //last year doesnt have more periods than this year
        if clFRS_Compare_Type = cflCompare_To_Last_Year then
          FMaxPeriod := Max( clTemp_Periods_This_Year, clTemp_Periods_Last_Year)
        else
          FMaxPeriod := clTemp_Periods_This_Year;
        //now set the number of visible columns on the report
        FVisiblePeriods := (FMaxPeriod - FMinPeriod) + 1;
      end;
    end;
  end;
end;

procedure TFinancialReportBase.SetReportScaleFactor(const Value: double);
begin
  FReportScaleFactor := Value;
end;

procedure TFinancialReportBase.SkipPeriod;
var
  i : integer;
begin
  for i := 1 to ColumnsPerPeriod do
     SkipColumn;
end;

function TFinancialReportBase.SubGroupNeedsPrinting(ReportGroupSet: ATTypeSet;
  SubGroup: integer): boolean;
//assumes that the AccountsToPrint array will have been loaded
var
  ReportGroup : integer;
begin
  result := false;
  for ReportGroup := atMin to atMax do
    if ReportGroup in ReportGroupSet then
      result := result or (AccountsToPrintCount[ ReportGroup, SubGroup] > 0);
end;

end.
