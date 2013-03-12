unit SectionManager;
//------------------------------------------------------------------------------
//  Title:   Section Manager
//
//  Written: Feb 2009
//
//  Authors: Scott Wilson
//
//  Purpose: More flexible way to manage sections within the financial reports.
//
//  Notes:  The section manager loads all the data required for the section
//          into a tree-like structure. Then depending on the report settings
//          it formats the data as required. For example Summerised or Detailed.
//
//          The P&L Direct Expences section has an extra SubSection level.
//
//          To render totals use:
//          RenderDetailSubTotal (SubTotal) => Section Total
//          RenderDetailSectionTotal (SectionTotal) => Sub Section Total
//          RenderDetailSubSectionTotal (SubSectionTotal) => Sub Group Total
//------------------------------------------------------------------------------

interface

uses
  Contnrs, SysUtils, SignUtils, ReportCashflowBase, ReportTypes, BKDEFS,
  clObj32, RptParams, NewReportObj;

const
  HAS_ACCOUNTS = True;

type
  TSectionType = (stSection, stSubSection, stSubGroup, stCtrlAccnt, stAccount);

  TSectionItem = class(TObject)
  private
    ID: integer;
    ParentID: integer;
    SectionType: TSectionType;
    Text, DefaultText, TotalText: string;
    Account: pAccount_Rec;
    ColTypeID : integer;
  end;

  TSection = class(TObject)
  private
    FClient: TClientObj;
    FDefaultSign: TSign;
    FReportGroupsSet: ATTypeSet;
    FRptParameters: TRptParameters;
    FSectionItems: TObjectList;
    FShowChartCodes: boolean;
    FStyle: TStyleTypes;
    FTotalsArray: TValuesArray;
    FValuesArray: TValuesArray;
    function OutputAccount(pAcct: pAccount_Rec; aSubGroupNo: integer = 0): boolean;
    procedure ClearSectionItems;
    procedure ClearTotalsArray;
  public
    constructor Create(aClient: TClientObj; aReport: TBKReport;
                       aRptParameters: TRptParameters); virtual;
    destructor Destroy; override;
    procedure PrintSection; overload; virtual; abstract;
    procedure PrintSection(ReportGroupsSet: ATTypeSet; SectionHeadingId: integer;
                           SectionTotalId: Integer; DefaultSign: TSign;
                           Style: TStyleTypes = siSectionTotal); overload; virtual; abstract;
  end;

{ TODO -oSW : Need to finish this so it can replace PrintSection in all financial reports }
{ TODO -oSW : Move anything to do with Control Accounts out of ReportCashFlowBase to here }
  TSectionStandard = class(TSection)
  private
    FColumnsPerPeriod: integer;
    FCtrlAccntSummarised: boolean;
    FCurrSubGroupNo: integer;
    FDetailed: boolean;
    FIncludeCtrlAccntTitles: boolean;
    FLastPeriod: integer;
    FPeriods: integer;
    FReport: TFinancialReportBase;
    FSectionHeadingId: integer;
    FSectionTotalId: integer;
    FLineAfterCtrlAccnt: boolean;
    function AddSectionItem(aParentID: integer; aSectionType: TSectionType;
                            aText: string; aAccount: pAccount_Rec = nil; aDefaultText: string = '';
                            aTotalText: string = ''; aColTypeID : integer = 0 ): integer;
    function GetSectionTypeCount(aParentID: integer; aSectionType: TSectionType): integer;
    procedure AddAccountTotals(pAcct: pAccount_Rec); virtual;
    procedure GetAccountCount(aParentID: integer; var AccountCount: integer; Recursive: boolean = True);
    procedure GetCtrlAccountCount(aParentID: integer; var CtrlAccountCount: integer; Recursive: boolean = True);
    procedure LoadAccounts(aParentID: integer); virtual;
    procedure LoadSectionMain; virtual;
    procedure LoadSubGroups(aParentID: integer); virtual;
    procedure PrintAccounts(aSectionItem: TSectionItem; var CtrlAccntCount,
                            AccountCount, LineCount: integer); virtual;
    procedure PrintSectionMain; virtual;
    procedure PrintSubGroups(aSectionItem: TSectionItem); virtual;
    procedure PrintSubSectionSummaries(aSectionItem: TSectionItem); virtual;
    procedure PrintSubGroupSummaries(aSectionItem: TSectionItem); virtual;
    procedure PrintAccountSummary(aSectionItem: TSectionItem); virtual;
    procedure SummariseAccounts(aParentID: integer; var aAccountCount: integer); virtual;
  public
    constructor Create(aClient: TClientObj; aReport: TBKReport;
                       aRptParameters: TRptParameters); override;
    procedure PrintSection(ReportGroupsSet: ATTypeSet; SectionHeadingId: integer;
                           SectionTotalId: Integer; DefaultSign: TSign;
                           Style: TStyleTypes = siSectionTotal); override;
  end;

  TSectionProfitAndLossDirectExpenses = class(TSectionStandard)
  private
    FNoSubGroupText: string;
    procedure LoadSectionMain; override;
    procedure LoadSubSections(aParentID: integer);
    procedure LoadCogSubGroups(aParentID: integer);
    procedure PrintSectionMain; override;
    procedure PrintSubSections(aSectionItem: TSectionItem);
    procedure AddAccountTotals(pAcct: pAccount_Rec); override;
    procedure SetValuesForPeriod(const pAcct: pAccount_Rec; const ForPeriod: integer);
    procedure SetYtdValuesForPeriod(const pAcct: pAccount_Rec; const ForPeriod: integer);
  public
    procedure PrintSection; override;
  end;

implementation

uses
  bkConst,
  rptProfit,
  PRHEAD,
  glConst,
  AccountInfoObj;

{ TSection }

procedure TSection.ClearSectionItems;
var
  i: integer;
begin
  for i := 0 to FSectionItems.Count - 1 do
    if Assigned(FSectionItems[i]) then
      TSectionItem(FSectionItems[i]).Free;
end;

procedure TSection.ClearTotalsArray;
var
  i: integer;
begin
  for i := Low(FTotalsArray) to High(FTotalsArray) do
    FTotalsArray[i] := 0;
end;

constructor TSection.Create(aClient: TClientObj; aReport: TBKReport;
  aRptParameters: TRptParameters);
begin
  FClient := aClient;
  FRptParameters := aRptParameters;

  FSectionItems := TObjectList.Create;
  FSectionItems.OwnsObjects := False;
end;

destructor TSection.Destroy;
begin
  ClearSectionItems;
  FSectionItems.Free;

  inherited;
end;

function TSection.OutputAccount(pAcct: pAccount_Rec; aSubGroupNo: integer): boolean;
begin
  Result := False;
  if Assigned(pAcct) then
    Result := (pAcct^.chAccount_Type in FReportGroupsSet) and
              (pAcct^.chTemp_Include_In_Report) and
              (pAcct^.chSubtype = aSubGroupNo) and
              (pAcct^.chPosting_Allowed);
end;


{ TSectionProfitAndLossDirectExpenses }


procedure TSectionProfitAndLossDirectExpenses.PrintSection;
begin
  inherited PrintSection([atOpeningStock, atPurchases,
                          atClosingStock, atDirectExpense],
                         phdLess_Direct_Expenses,
                         phdTotal_Direct_Expenses,
                         Debit);
end;

procedure TSectionProfitAndLossDirectExpenses.PrintSectionMain;
var
  i: integer;
  SectionItem: TSectionItem;
  SubSectionCount: integer;
  SubGroupCount: integer;
  AccountCount: integer;
begin
  SectionItem := TSectionItem(FSectionItems[0]);
  if FDetailed then
  begin
    //Title
    FReport.RenderTitleLine(SectionItem.Text);

    //Sub sections
    PrintSubSections(SectionItem);
    //Total
    FReport.RenderDetailSubTotal(GetPRHeading(FClient, phdTotal_Direct_Expenses), FDefaultSign);
  end
  else
  begin
    SubSectionCount := GetSectionTypeCount(SectionItem.ID, stSubSection);
    
    if (SubSectionCount = 1) then
    begin
      SubGroupCount := 0;

      for i := 0 to FSectionItems.Count - 1 do
      begin
        if (TSectionItem(FSectionItems[i]).SectionType = stSubSection) then
          SubGroupCount := SubGroupCount + GetSectionTypeCount(TSectionItem(FSectionItems[i]).ID, stSubGroup);
      end;

      if (SubGroupCount > 0) then
      begin
        //Title
        FReport.RenderTitleLine(SectionItem.Text);

        //Sub section summaries
        PrintSubSectionSummaries(SectionItem);
        //Total
        FReport.RenderDetailSubTotal(GetPRHeading(FClient, phdTotal_Direct_Expenses), FDefaultSign);
      end
      else
      begin
       //One line summary
        ClearTotalsArray;
        SetLength(FValuesArray, FColumnsPerPeriod);
        //Summarise accounts
        AccountCount := 0;
        SummariseAccounts(SectionItem.ID, AccountCount);

        FReport.RenderTextLine('');
        
        //Print section total
        FReport.PrintTotalsArray(GetPRHeading(FClient, phdLess_Direct_Expenses), FTotalsArray, FDefaultSign, FStyle);
      end;
    //Sub section summary
    end
    else if (SubSectionCount > 1) then
    begin
      //Title
      FReport.RenderTitleLine(SectionItem.Text);

      //Sub section summaries
      PrintSubSectionSummaries(SectionItem);
      //Total
      FReport.RenderDetailSubTotal(GetPRHeading(FClient, phdTotal_Direct_Expenses), FDefaultSign);
    end;
  end;
end;

procedure TSectionProfitAndLossDirectExpenses.PrintSubSections(
  aSectionItem: TSectionItem);
var
  i: integer;
  SectionItem: TSectionItem;
  SubGroupCount: integer;
  OtherAccountCount: integer;
  CtrlAccntCount, AccountCount, LineCount: integer;
  TotalAccounts: integer;
begin
  TotalAccounts := 0;
  GetAccountCount(aSectionItem.ID, TotalAccounts);
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);

    if (SectionItem.SectionType = stSubSection) then begin
      if (SectionItem.ParentID = aSectionItem.ID) then begin
        FReport.RenderTitleLine(SectionItem.Text);

        //Sub groups
        SubGroupCount := GetSectionTypeCount(SectionItem.ID, stSubGroup);
        PrintSubGroups(SectionItem);

       //Line between sub groups and other accounts for the section
        OtherAccountCount := 0;
        CtrlAccntCount := 0;
        GetAccountCount(SectionItem.ID, OtherAccountCount, False);
        GetCtrlAccountCount(SectionItem.ID, CtrlAccntCount, False);
        //Optional title for accounts without a sub group BugzId: 11908
        if (SubGroupCount > 0) and ((OtherAccountCount > 0) or (CtrlAccntCount > 0))then
          if FNoSubGroupText = '' then
            FReport.RenderTextLine( '')
          else
            FReport.RenderTitleline(FNoSubGroupText);

        //Accounts
        CtrlAccntCount := 0;
        AccountCount := 0;
        LineCount := 0;
        PrintAccounts(SectionItem, CtrlAccntCount, AccountCount, LineCount);
        if (SubGroupCount > 0) and (AccountCount > 1) then begin
          //Line before total if section has accounts and ctrl accnts
          if (not FCtrlAccntSummarised) and (CtrlAccntCount > 0) then
            FReport.RenderTextLine('');
          //Other accounts sub total
          FReport.RenderDetailSubSectionTotal('', FDefaultSign);
          FReport.ClearSubSectionTotal;
        end else begin
          //Line before total if section has accounts and ctrl accnts
          if (not FCtrlAccntSummarised) and (CtrlAccntCount > 0) then
            FReport.RenderTextLine('');
        end;
        //Sub section total
        // if Cost of Goods show total if there is only 1 row
        if (TotalAccounts > 1) or
           (SectionItem.ColTypeID = phdCOGS) or
           (SectionItem.ColTypeID = phdOther_Direct_Expenses) then
        begin
          if SectionItem.TotalText = '' then
            FReport.RenderDetailSectionTotal('Total ' + SectionItem.Text, FDefaultSign)
          else
            FReport.RenderDetailSectionTotal(SectionItem.TotalText, FDefaultSign);
        end;
      end;
    end;
  end;
end;

procedure TSectionProfitAndLossDirectExpenses.LoadCogSubGroups(
  aParentID: integer);
var
  SubGroupNo: integer;
  SubGroupID: integer;
begin
  for SubGroupNo := 1 to Max_SubGroups do begin
    FReportGroupsSet := [atOpeningStock, atPurchases, atClosingStock];
    if FReport.SubGroupNeedsPrinting(FReportGroupsSet, SubGroupNo) then begin
      FCurrSubGroupNo := SubGroupNo;
      SubGroupID := AddSectionItem(aParentID, stSubGroup,
                                   FClient.clCustom_Headings_List.Get_SubGroup_Heading(SubGroupNo));
      //Opening stock
      FReportGroupsSet := [atOpeningStock];
      LoadAccounts(SubGroupID);
      //Purchases
      FReportGroupsSet := [atPurchases];
      LoadAccounts(SubGroupID);
      //Closing stock
      FReportGroupsSet := [atClosingStock];
      LoadAccounts(SubGroupID);
    end;
  end;
  FCurrSubGroupNo := 0;
end;

procedure TSectionProfitAndLossDirectExpenses.LoadSectionMain;
var
  SectionID: integer;
begin
  //Direct Expenses Section
  SectionID := AddSectionItem(-1, stSection, GetPRHeading(FClient, FSectionHeadingId));
  FNoSubGroupText := Trim(FClient.clCustom_Headings_List.Get_SubGroup_Heading(0));
  LoadSubSections(SectionID);
end;

procedure TSectionProfitAndLossDirectExpenses.LoadSubSections(
  aParentID: integer);
var
  SubSectionID: integer;
begin
  if FReport.ReportSectionNeedsPrinting([atOpeningStock, atPurchases, atClosingStock]) then
  begin
    //Cost of goods sold
    SubSectionID := AddSectionItem(aParentID, stSubSection, GetPRHeading(FClient, phdCOGS),
                                   nil, '', GetPRHeading(FClient, phdTotal_COGS), phdCOGS);

    //COG sub groups
    LoadCogSubGroups(SubSectionID);

    //Opening stock
    FReportGroupsSet := [atOpeningStock];
    LoadAccounts(SubSectionID);
    //Purchases
    FReportGroupsSet := [atPurchases];
    LoadAccounts(SubSectionID);
    //Closing stock
    FReportGroupsSet := [atClosingStock];
    LoadAccounts(SubSectionID);
  end;

  if FReport.ReportSectionNeedsPrinting([atDirectExpense]) then begin
    //Other direct expenses
    SubSectionID := AddSectionItem(aParentID, stSubSection,
                                   GetPRHeading(FClient, phdOther_Direct_Expenses),
                                   nil, '', GetPRHeading(FClient, phdTotal_Other_Direct_Expenses), phdOther_Direct_Expenses );
    FReportGroupsSet := [atDirectExpense];
    LoadSubGroups(SubSectionID);
    LoadAccounts(SubSectionID);
  end;
end;

procedure TSectionProfitAndLossDirectExpenses.SetValuesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer);
var
  AccountInfo  : TProfitAndLossAccountInfo;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
begin
  Assert(Length(FReport.ColumnTypes) = Length(FValuesArray));

  //values for P & L reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low(FValuesArray) to High(FValuesArray) do
     FValuesArray[i] := 0;

  ShowLastYear := (FClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (FClient.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TProfitAndLossAccountInfo.Create(FClient);
  try
    AccountInfo.UseBudgetIfNoActualData := FClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := FClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode := pAcct.chAccount_Code;

    for i := Low( FValuesArray) to High( FValuesArray) do begin
      case FReport.ColumnTypes[i] of
        ftActual : FValuesArray[i] := AccountInfo.ActualOrBudget( ForPeriod);
        ftQuantity : FValuesArray[i] := AccountInfo.Quantity( ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
             FValuesArray[i] := AccountInfo.LastYear( ForPeriod);
          if ShowBudget then
             FValuesArray[i]:= AccountInfo.Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
             FValuesArray[i] := AccountInfo.Variance_ActualLastYear(ForPeriod);
          if ShowBudget then
             FValuesArray[i] := AccountInfo.Variance_ActualBudget(ForPeriod);
        end;

        ftPercentage : FValuesArray[i] := FValuesArray[Pred(i)];

      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TSectionProfitAndLossDirectExpenses.SetYtdValuesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer);
var
  AccountInfo  : TProfitAndLossAccountInfo;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
begin
  Assert(Length(FReport.ColumnTypes) = Length(FValuesArray));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low(FValuesArray) to High(FValuesArray) do
    FValuesArray[i] := 0;

  ShowLastYear := (FClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (FClient.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TProfitAndLossAccountInfo.Create(FClient);
  try
    AccountInfo.UseBudgetIfNoActualData     := FClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := FClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low(FValuesArray) to High(FValuesArray) do begin
      case FReport.ColumnTypes[ i] of
        ftActual :  FValuesArray[i] := AccountInfo.YTD_ActualOrBudget( ForPeriod);
        ftQuantity : FValuesArray[i] := AccountInfo.YTD_Quantity( ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
             FValuesArray[i] := AccountInfo.YTD_LastYear( ForPeriod);
          if ShowBudget then
             FValuesArray[i] := AccountInfo.YTD_Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
             FValuesArray[i] := AccountInfo.YTD_Variance_ActualLastYear( ForPeriod);
          if ShowBudget then
             FValuesArray[i] := AccountInfo.YTD_Variance_ActualBudget( ForPeriod);
        end;
        ftFullPeriodBudget : FValuesArray[i] := AccountInfo.BudgetRemaining( 0, AccountInfo.HighestPeriod);
        ftBudgetRemaining  : FValuesArray[i] := AccountInfo.BudgetRemaining( ForPeriod, AccountInfo.HighestPeriod);
        ftPercentage : FValuesArray[i] := FValuesArray[Pred(i)]; // should always follow the columns
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TSectionProfitAndLossDirectExpenses.AddAccountTotals(pAcct: pAccount_Rec);
var
  i: integer;
  PeriodNo: integer;
  TotalsArrayPos: integer;
begin
  //Get account values
  TotalsArrayPos := 0;
  for PeriodNo := FReport.MinPeriodToShow to FReport.MaxPeriodToShow do begin
    if (PeriodNo <= FLastPeriod) then begin
      SetValuesForPeriod(pAcct, PeriodNo);
      //Add account values totals array
      for i := Low(FValuesArray) to High(FValuesArray) do begin
        FTotalsArray[TotalsArrayPos] := FTotalsArray[TotalsArrayPos] +
                                        FValuesArray[i];
        Inc(TotalsArrayPos);
      end;
    end else
      Inc(TotalsArrayPos, FColumnsPerPeriod);
  end;

  //Get YTD values
  SetYtdValuesForPeriod(pAcct, FLastPeriod);
  //Add YTD totals array
  for i := Low(FValuesArray) to High(FValuesArray) do begin
    FTotalsArray[TotalsArrayPos] := FTotalsArray[TotalsArrayPos] +
                                    FValuesArray[i];
    Inc(TotalsArrayPos);
  end;
end;

{ TSectionStandard }

procedure TSectionStandard.AddAccountTotals(pAcct: pAccount_Rec);
begin
//Get code from ReportCashflowBase
end;

function TSectionStandard.AddSectionItem(aParentID: integer;
  aSectionType: TSectionType; aText: string; aAccount: pAccount_Rec = nil; aDefaultText: string = '';
  aTotalText: string = ''; aColTypeID : integer = 0 ): integer;
var
  SectionItem: TSectionItem;
begin
  SectionItem := TSectionItem.Create;
  SectionItem.ParentID := aParentID;
  SectionItem.SectionType := aSectionType;
  SectionItem.Text := aText;
  SectionItem.DefaultText := aDefaultText; 
  if Assigned(aAccount) and FShowChartCodes then
    SectionItem.Text := Format('%s %s', [aAccount.chAccount_Code, SectionItem.Text]);
  SectionItem.Account := aAccount;
  SectionItem.TotalText := aTotalText;
  SectionItem.ColTypeID := aColTypeID;
  SectionItem.ID := FSectionItems.Add(SectionItem);
  Result := SectionItem.ID;
end;

constructor TSectionStandard.Create(aClient: TClientObj; aReport: TBKReport;
  aRptParameters: TRptParameters);
begin
  inherited;
  FReport := TFinancialReportBase(aReport);
  FPeriods := FReport.iVisiblePeriods;
  FColumnsPerPeriod := FReport.ColumnsPerPeriod;
  FDetailed := True;
  FDefaultSign := NNone;
  FStyle := siSectionTotal;
  FLineAfterCtrlAccnt := False;

  SetLength(FValuesArray, FColumnsPerPeriod);
  SetLength(FTotalsArray, (FColumnsPerPeriod * (FPeriods + 1)));
end;

procedure TSectionStandard.GetAccountCount(aParentID: integer; var
  AccountCount: integer; Recursive: boolean);
var
  i: integer;
begin
  //Recursive procedure to count child accounts
  for i := 0 to FSectionItems.Count - 1 do
    if (TSectionItem(FSectionItems[i]).ParentID = aParentID) then
      if (TSectionItem(FSectionItems[i]).SectionType = stAccount) then
        Inc(AccountCount)
      else if Recursive then
        GetAccountCount(TSectionItem(FSectionItems[i]).ID, AccountCount);
end;

procedure TSectionStandard.GetCtrlAccountCount(aParentID: integer;
  var CtrlAccountCount: integer; Recursive: boolean);
var
  i: integer;
begin
  //Recursive procedure to count child control accounts
  for i := 0 to FSectionItems.Count - 1 do
    if (TSectionItem(FSectionItems[i]).ParentID = aParentID) then
      if (TSectionItem(FSectionItems[i]).SectionType = stCtrlAccnt) then
        Inc(CtrlAccountCount)
      else if Recursive then
        if (TSectionItem(FSectionItems[i]).SectionType <> stAccount) then
          GetAccountCount(TSectionItem(FSectionItems[i]).ID, CtrlAccountCount);
end;

function TSectionStandard.GetSectionTypeCount(aParentID: integer;
  aSectionType: TSectionType): integer;
var
  i: integer;
  AccountCount: integer;
begin
  Result := 0;
  for i := 0 to FSectionItems.Count - 1 do
    if (TSectionItem(FSectionItems[i]).SectionType = aSectionType) and
       (TSectionItem(FSectionItems[i]).ParentID = aParentID) then begin
         AccountCount := 0;
         GetAccountCount(TSectionItem(FSectionItems[i]).ID, AccountCount);
         if (AccountCount > 0) then
           Inc(Result);
       end;
end;

procedure TSectionStandard.LoadAccounts(aParentID: integer);
var
  ChartIdx: integer;
  pAcct: pAccount_Rec;
  pCtrlAcct: pAccount_Rec;
  pLastCtrlAcct: pAccount_Rec;
  CtrlAccntID: integer;
begin
  CtrlAccntID := -1;
  pLastCtrlAcct := nil;
  //Loop through chart
  for ChartIdx := 0 to Pred(FRptParameters.Chart.ItemCount) do begin
    pAcct := FRptParameters.Chart.Account_At(ChartIdx);
    pCtrlAcct := FReport.GetControlAccount(pAcct);
    if OutputAccount(pAcct, FCurrSubGroupNo) then begin
      //Has control account
      if Assigned(pCtrlAcct) then begin
        //Control account title
        if (pCtrlAcct <> pLastCtrlAcct) then begin
          CtrlAccntID := AddSectionItem(aParentID, stCtrlAccnt,
                                        pCtrlAcct^.chAccount_Description, pCtrlAcct);
          pLastCtrlAcct := pCtrlAcct;
        end;
        //Sub Account
        if (CtrlAccntID <> -1) then
          AddSectionItem(CtrlAccntID, stAccount, pAcct^.chAccount_Description, pAcct);
      end else begin;
        //Account
        AddSectionItem(aParentID, stAccount, pAcct^.chAccount_Description, pAcct);
      end;
    end;
  end;
end;

procedure TSectionStandard.LoadSectionMain;
var
  SectionID: integer;
begin
  SectionID := AddSectionItem(-1, stSection, GetPRHeading(FClient, FSectionHeadingId));
  LoadSubGroups(SectionID);
  LoadAccounts(SectionID);
end;

procedure TSectionStandard.LoadSubGroups(aParentID: integer);
var
  SubGroupNo: integer;
  SubGroupID: integer;
begin
  for SubGroupNo := 1 to Max_SubGroups do begin
    if FReport.SubGroupNeedsPrinting(FReportGroupsSet, SubGroupNo) then begin
      FCurrSubGroupNo := SubGroupNo;
      SubGroupID := AddSectionItem(aParentID, stSubGroup,
                                   FClient.clCustom_Headings_List.Get_SubGroup_Heading(SubGroupNo));
      LoadAccounts(SubGroupID);
    end;
  end;
  FCurrSubGroupNo := 0;
end;

procedure TSectionStandard.PrintAccounts(aSectionItem: TSectionItem; var
  CtrlAccntCount, AccountCount, LineCount: integer);
var
  i, j: integer;
  SectionItem: TSectionItem;
  SummSectionItem: TSectionItem;
begin
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.SectionType = stCtrlAccnt) then begin
      if (SectionItem.ParentID = aSectionItem.ID) then begin
        if FIncludeCtrlAccntTitles then begin
          Inc(CtrlAccntCount);
          FLineAfterCtrlAccnt := False;
          if FCtrlAccntSummarised then begin
            //Setup arrays
            ClearTotalsArray;
            SetLength(FValuesArray, FColumnsPerPeriod);
            //Summarise section
            for j := 0 to FSectionItems.Count - 1 do begin
              SummSectionItem := TSectionItem(FSectionItems[j]);
              if SummSectionItem.SectionType = stAccount then
                if (SummSectionItem.ParentID = SectionItem.ID) then
                  AddAccountTotals(SummSectionItem.Account);
            end;
            //Print section total
            FReport.PrintTotalsArray(SectionItem.Text, FTotalsArray,
                                     FDefaultSign, siDetail);
            Inc(AccountCount); //Summarised ctrl accnt = 1 account                                    
          end else begin
            //Line before ctrl accnt
            if (LineCount > 0) then begin
              FReport.RenderTextLine('');
              Inc(LineCount);
            end;
            Inc(LineCount); //Ctrl Accnt Title - output by report PrintAccounts
            PrintAccounts(SectionItem, CtrlAccntCount, AccountCount, LineCount);
            FReport.ControlAccountsToPrint.Values[SectionItem.Account.chAccount_Code] := '1';
            FLineAfterCtrlAccnt := True;
          end;
        end else
          //No ctrl accnt titles
          PrintAccounts(SectionItem, CtrlAccntCount, AccountCount, LineCount);
      end;
    end else if (SectionItem.SectionType = stAccount) then begin
      if (SectionItem.ParentID = aSectionItem.ID) then begin
        //Line after ctrl accnt
        if (CtrlAccntCount > 0) and FLineAfterCtrlAccnt then begin
          FLineAfterCtrlAccnt := False;
          FReport.RenderTextLine('');
          Inc(LineCount);
        end;
        FReport.PrintDetailForAccount(SectionItem.Account, FDefaultSign);
        Inc(AccountCount);
        Inc(LineCount);
      end;
    end;
  end;
end;

procedure TSectionStandard.PrintAccountSummary(aSectionItem: TSectionItem);
var
  i: integer;
  SectionItem: TSectionItem;
  AccountCount: integer;
begin
  AccountCount := 0;
  //Summarise accounts for section excluding sub sections (non recursive)
  ClearTotalsArray;
  SetLength(FValuesArray, FColumnsPerPeriod);
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.ParentID = aSectionItem.ID) then begin
      if (SectionItem.SectionType = stAccount) then begin
        AddAccountTotals(SectionItem.Account);
        Inc(AccountCount);
      end else if (SectionItem.SectionType = stCtrlAccnt) then begin
        AccountCount := 0;
        SummariseAccounts(SectionItem.ID, AccountCount);
      end;
    end;
  end;
  //Print total
  if (AccountCount > 0) then
    FReport.PrintTotalsArray('', FTotalsArray, FDefaultSign, FStyle);
end;

procedure TSectionStandard.PrintSection(ReportGroupsSet: ATTypeSet;
  SectionHeadingId, SectionTotalId: Integer; DefaultSign: TSign;
  Style: TStyleTypes);
begin
  //Check if section needs printing
  FReportGroupsSet := ReportGroupsSet;
  if FReport.ReportSectionNeedsPrinting(FReportGroupsSet) then begin
    //Initialise settings
    FSectionHeadingId := SectionHeadingId;
    FSectionTotalId := SectionTotalId;
    FDetailed := (FClient.clFields.clFRS_Report_Detail_Type = cflReport_Detailed);
    FShowChartCodes := FClient.clFields.clFRS_Print_Chart_Codes;
    FIncludeCtrlAccntTitles := FClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
    FCtrlAccntSummarised := (FClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type = cflReport_Summarised);
    FLastPeriod := FClient.clFields.clTemp_FRS_last_Period_To_Show;
    FDefaultSign := DefaultSign;
    FStyle := Style;
    //Load Section
    LoadSectionMain;
    //Output Section
    PrintSectionMain;
  end;
end;

procedure TSectionStandard.PrintSectionMain;
var
  SectionItem: TSectionItem;
  CtrlAccntCount, AccountCount, LineCount: integer;
begin
  SectionItem := TSectionItem(FSectionItems[0]);
  //Title
  FReport.RenderTitleLine(SectionItem.Text);
  if FDetailed then begin
    //Sub groups
    PrintSubGroups(SectionItem);
    CtrlAccntCount := 0;
    AccountCount := 0;
    LineCount := 0;
    //Accounts
    PrintAccounts(SectionItem, CtrlAccntCount, AccountCount, LineCount);
    //Total
    FReport.RenderDetailSubTotal(GetPRHeading(FClient, FSectionTotalId), FDefaultSign);
  end;
{ TODO -oSW : Summarised report }
end;

procedure TSectionStandard.PrintSubGroups(aSectionItem: TSectionItem);
var
  i: integer;
  SectionItem: TSectionItem;
  CtrlAccntCount, AccountCount, LineCount: integer;
begin
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.SectionType = stSubGroup) then begin
      if (SectionItem.ParentID = aSectionItem.ID) then begin
        FReport.RenderTitleLine(SectionItem.Text);
        CtrlAccntCount := 0;
        AccountCount := 0;
        LineCount := 0;
        PrintAccounts(SectionItem, CtrlAccntCount, AccountCount, LineCount);
        if (not FCtrlAccntSummarised) and (CtrlAccntCount > 0) then
          FReport.RenderTextLine('');
        if (AccountCount > 1) then
          FReport.RenderDetailSubSectionTotal(SectionItem.Text + ' Total', FDefaultSign);
        FReport.ClearSubSectionTotal;
        //Reset control accounts titles
        FReport.ResetControlAccounts;
      end;
    end;
  end;
end;

procedure TSectionStandard.PrintSubGroupSummaries(aSectionItem: TSectionItem);
var
  i: integer;
  SectionItem: TSectionItem;
  AccountCount: integer;
begin
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.ParentID = aSectionItem.ID) and
       (SectionItem.SectionType = stSubGroup) then begin
      //Summarise Accounts
      ClearTotalsArray;
      SetLength(FValuesArray, FColumnsPerPeriod);
      //Summarise accounts for section
      AccountCount := 0;
      SummariseAccounts(SectionItem.ID, AccountCount);
      //Print sub section total
      if (AccountCount > 0) then
        FReport.PrintTotalsArray(SectionItem.Text, FTotalsArray, FDefaultSign, FStyle);
    end;
  end;
end;

procedure TSectionStandard.PrintSubSectionSummaries(aSectionItem: TSectionItem);
var
  i: integer;
  SectionItem: TSectionItem;
  SubGroupCount: integer;
  AccountCount: integer;
begin
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.ParentID = aSectionItem.ID) and
       (SectionItem.SectionType = stSubSection) then begin
      SubGroupCount := GetSectionTypeCount(SectionItem.ID, stSubGroup);
      if (SubGroupCount > 0) then begin
        //Title
        FReport.RenderTitleLine(SectionItem.Text);
        //Summarise to sub group level
        PrintSubGroupSummaries(SectionItem);
        //Summarise Accounts
        PrintAccountSummary(SectionItem);
        //Total
        FReport.RenderDetailSubSectionTotal('Total ' + SectionItem.Text, FDefaultSign);
        //FReport.RenderDetailSubSectionTotal(SectionItem.Text + ' Total', FDefaultSign);
        FReport.ClearSubSectionTotal;
      end else begin
        //Sub Section summary
        ClearTotalsArray;
        SetLength(FValuesArray, FColumnsPerPeriod);
        //Summarise to sub section level
        AccountCount := 0;
        SummariseAccounts(SectionItem.ID, AccountCount);
        if (AccountCount > 0) then
          FReport.PrintTotalsArray('Total ' + SectionItem.Text, FTotalsArray, FDefaultSign, FStyle);
          //FReport.PrintTotalsArray(SectionItem.Text + ' Total', FTotalsArray, FDefaultSign, FStyle);
        FReport.ClearSubSectionTotal;          
      end;
    end;
  end;
end;

procedure TSectionStandard.SummariseAccounts(aParentID: integer; var aAccountCount: integer);
var
  i: integer;
  SectionItem: TSectionItem;
begin
  //Recursive procedure to total all child accounts for a section
  for i := 0 to FSectionItems.Count - 1 do begin
    SectionItem := TSectionItem(FSectionItems[i]);
    if (SectionItem.ParentID = aParentID) then
      if (SectionItem.SectionType = stAccount) then begin
        AddAccountTotals(SectionItem.Account);
        Inc(aAccountCount);
      end else
        SummariseAccounts(SectionItem.ID, aAccountCount);
  end;
end;

end.
