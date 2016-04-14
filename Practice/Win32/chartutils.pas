Unit chartutils;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

Interface


uses
  chList32,
  clObj32,
  stdate,
  BKchIO;

type
  TCashBookChartClasses = (ccNone,
                           ccIncome,
                           ccExpense,
                           ccOtherIncome,
                           ccOtherExpense,
                           ccAsset,
                           ccLiabilities,
                           ccEquity,
                           ccCostOfSales);

  TCashBookGSTClasses = (cgNone,
                         cgGoodsandServices,
                         cgCapitalAcquisitions,
                         cgExportSales,
                         cgGSTFree,
                         cgInputTaxedSales,
                         cgPurchaseForInput,
                         cgNotReportable,
                         cgGSTNotRegistered,
                         cgExempt,
                         cgZeroRated,
                         cgCustoms);

Function LoadChartFrom(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;

Function SaveChartTo(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;

function MergeCharts(var NewChart : TChart; const aClient : TClientObj;
  const ReplaceChartID: Boolean = False; KeepSubAndReportGroups: Boolean = false;
  KeepPostingAllowed: boolean = false; OldChartOnlyKeepAndSetInActive : Boolean = false) : boolean;

Function GetChartFileName( ClientCode  : string;
                           aInitDir    : string;
                           aFilter     : string;
                           DefExtn     : string;
                           HelpCtx     : Integer ) : String;

function StripInvalidCharacters(aValue: String): String;
function GetMappedReportGroupCode(aMappedGroupId : TCashBookChartClasses) : string;
function GetMigrationMappedReportGroupCode(aMappedGroupId : TCashBookChartClasses): string;
function SendZeroOpeningBalance(aMappedGroupId : TCashBookChartClasses; aOpeningBalanceDate, aFinancialYearStart : TstDate): boolean;
function GetGSTClassTypeIndicatorFromGSTClass(aGST_Class : byte) : byte;
function GetMappedNZGSTTypeCode(aGSTClassTypeIndicator : byte) : TCashBookGSTClasses;
procedure GetMYOBCashbookGSTDetails(aCashBookGstClass : TCashBookGSTClasses;
                                    var aCashBookGstClassCode : string;
                                    var aCashBookGstClassDesc : string);

function GetLastFullyCodedMonth(var aFullyCodedMonth : TStDate): Boolean;
function GetMigrationOpeningBalance(aValue : string) : integer;
function IsGSTClassUsedInChart(aChartExportCol : TObject; aGST_Class: byte): boolean;
function IsChartCodeABankContra(aCode: string): boolean;
procedure FillGstMapCol(aChartExportCol : TObject; aGSTMapCol : TObject; aExcludeGSTItemsNotInChart : boolean = true);

//------------------------------------------------------------------------------
Implementation
//------------------------------------------------------------------------------

Uses
  SysUtils,
  Dialogs,
  glConst,
  GlobalDirectories,
  gstCalc32,
  bkconst,
  bkDefs,
  classes,
  controls,
  logUtil,
  YesNoWithListDlg,
  Globals,
  DateUtils,
  bkDateUtils,
  PeriodUtils,
  ChartExportToMYOBCashbook,
  baObj32,
  AuditMgr;

const
  UnitName = 'CHARTUTILS';
var
  DebugMe : boolean = false;

//------------------------------------------------------------------------------

Function LoadChartFrom(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;
Var
   OpenDlg : TOpenDialog;
Begin
   Result  := false;
   OpenDlg := TOpenDialog.Create(Nil);
   Try
      With OpenDlg Do
      Begin
         DefaultExt   := DefExtn;
         Filename     := aFileName;
         Filter       := aFilter + '|All Files|*.*';
         HelpContext  := HelpCtx;
         Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
         Title        := 'Load ' + ClientCode + ' Chart From';
         InitialDir   := ExtractFilePath( aInitDir );
      End;

      If OpenDlg.Execute Then
      Begin
         aFileName := OpenDlg.Filename;
         Result := true;
      End;
   Finally
      OpenDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;
//------------------------------------------------------------------------------

Function SaveChartTo(ClientCode: string; Var aFileName: string; aInitDir: string;
   aFilter: string; DefExtn: string; HelpCtx: Integer) : boolean;
Var
   SaveDlg : TSaveDialog;
Begin
   Result  := false;
   SaveDlg := TSaveDialog.Create(Nil);
   Try
      With SaveDlg Do
      Begin
         DefaultExt   := DefExtn;
         Filename     := aFileName;
         Filter       := aFilter + '|All Files|*.*';
         HelpContext  := HelpCtx;
         Options      := [ ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir, ofOverwritePrompt ];
         Title        := 'Save ' + ClientCode + ' Chart To';
         InitialDir   := ExtractFilePath( aInitDir );
      End;

      If SaveDlg.Execute Then
      Begin
         aFileName := SaveDlg.Filename;
         Result := true;
      End;
   Finally
      SaveDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;

//------------------------------------------------------------------------------

Function GetChartFileName( ClientCode  : string;
                           aInitDir    : string;
                           aFilter     : string;
                           DefExtn     : string;
                           HelpCtx     : Integer ) : String;

Var
   OpenDlg : TOpenDialog;
Begin
   Result  := '';
   OpenDlg := TOpenDialog.Create( nil );
   Try
      With OpenDlg Do
      Begin
         DefaultExt    := DefExtn;
         Filename      := '';
         Filter        := aFilter + '|All Files|*.*';
         HelpContext   := HelpCtx;
         Options       := [ ofHideReadOnly,  ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
         Title         := 'Load ' + ClientCode + ' Chart From';
         InitialDir    := ExtractFilePath( aInitDir );
      End;

      If OpenDlg.Execute then Result := OpenDlg.Filename;
   Finally
      OpenDlg.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
   End;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MergeCharts(var NewChart : TChart; const aClient : TClientObj;
  const ReplaceChartID: Boolean = False; KeepSubAndReportGroups: Boolean = false;
  KeepPostingAllowed: boolean = false; OldChartOnlyKeepAndSetInActive : Boolean = false): boolean;
// Used by each of the import chart routines to merge the new chart list into
// the existing chart list.
const
  ThisMethodName = 'MergeCharts';
var
  ni : integer;
  ei : integer;
  NewAccount,
  ExistingAccount : pAccount_Rec;
  AllowGSTClassToBeCleared : boolean;
  ChangesList : TStringList;
  ClientChart : TChart;

  DialogResult : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := false;

   ClientChart := aClient.clChart;

   if not Assigned(NewChart) then begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' NewChart not Assigned' );
      Exit;
   end;

   AllowGSTClassToBeCleared := false;

   if Assigned(ClientChart) then
   begin
     ChangesList := TStringList.Create;
     try
       //see if we need to ask the user about clear the gst class during refresh\
       //look for a gst class of "bkFORCE_GST_CLASS_TO_ZERO", if we find one
       //warn the user that the class for the chart code will be changed
       for ni := 0 to NewChart.ItemCount -1 do
       begin
         NewAccount    := Newchart.Account_At(ni);
         ExistingAccount := ClientChart.FindCode(NewAccount.chAccount_Code);

         //copy across stored fields
         if Assigned(ExistingAccount) then
         begin
           //255 is a marker that indicates the gst class should be forced to 0
           if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) and ( ExistingAccount.chGST_Class <> 0) then
           begin
             ChangesList.Add( NewAccount.chAccount_Code + ' ' + NewAccount.chAccount_Description + #9 + '('+GetGSTClassCode( aClient, ExistingAccount.chGST_Class)+')');
           end;
         end;
       end;

       //prompt user if anything will be changed
       if ChangesList.Count > 0 then
       begin
         DialogResult := AskYesNoWithList( 'Clear GST Classes',
                              'The following chart codes no longer have a GST rate associated with them in ' +
                                 aClient.clAccountingSystemName + ', however they currently have a GST class in ' + ShortAppNAme + ':',
                               ChangesList.Text,
                               'Do you want to clear the GST class in ' + ShortAppName +
                                 ' for these chart codes?');

         if DialogResult = mrYes then
           AllowGSTClassToBeCleared := True
         else
         if DialogResult = mrCancel then
           Exit;
       end;
     finally
       ChangesList.Free;
     end;

     // Set Existing Chart Code inactive if it does not exist in new chart if flag is set
     if OldChartOnlyKeepAndSetInActive then
     begin
       for ei := 0 to ClientChart.ItemCount-1 do
       begin
         ExistingAccount := ClientChart.Account_At(ei);
         NewAccount := NewChart.FindCode(ExistingAccount.chAccount_Code);
         if not ExistingAccount.chInactive and
            not assigned(NewAccount) then
           ExistingAccount.chInactive := true;
       end;
     end;

     // Don't delete inactive chart codes
     for ei := 0 to ClientChart.ItemCount-1 do
     begin
       ExistingAccount := ClientChart.Account_At(ei);

       // Add existing inactive accounts to the new chart
       if not ExistingAccount.chInactive then
         continue;

       // Prevent duplicates
       NewAccount := NewChart.FindCode(ExistingAccount.chAccount_Code);
       if assigned(NewAccount) then
         continue;

       // Note: all the other fields will be transferred below
       NewAccount := New_Account_Rec;
       NewAccount.chAccount_Code := ExistingAccount.chAccount_Code;
       NewAccount.chAccount_Description := ExistingAccount.chAccount_Description;
       NewChart.Insert(NewAccount);
     end;

     //Merge the existing chart into the New Chart
     for ni := 0 to NewChart.ItemCount -1 do
     begin
       NewAccount    := Newchart.Account_At(ni);
       ExistingAccount := ClientChart.FindCode(NewAccount.chAccount_Code);

       //copy across stored fields
       if Assigned(ExistingAccount) then
       begin
          //Keep the 'posting allowed?' setting
          if not KeepPostingAllowed then
            NewAccount.chPosting_Allowed := ExistingAccount.chPosting_Allowed;

          //Keep the same Audit ID
          NewAccount.chAudit_Record_ID := ExistingAccount.chAudit_Record_ID;

          if ( ExistingAccount.chGST_Class > 0) then
          begin
            //account has an existing GST class, use this if we are not setting
            //one
            if NewAccount.chGST_Class = 0 then
              NewAccount.chGST_Class := ExistingAccount.chGST_Class;

            if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) then
            begin
              if ( AllowGSTClassToBeCleared) then
                NewAccount.chGST_Class := 0
              else
                //don't override, just use existing class
                NewAccount.chGST_Class := ExistingAccount.chGST_Class;
            end;
          end;

          //maintain existing account type info unless a report group is defined
          if KeepSubAndReportGroups or
             ( NewAccount.chAccount_Type = atNone ) and ( ExistingAccount.chAccount_Type <> atNone ) then
          begin
             NewAccount.chAccount_Type := ExistingAccount.chAccount_Type ;
             NewAccount.chSubtype      := ExistingAccount.chSubtype;
          end;
          //sub groups are not included in the chart refresh so just retain existing
          NewAccount.chSubtype                := ExistingAccount.chSubtype;

          //these fields are not filled as part of the refresh chart so retain existing
          if not ReplaceChartID then
            NewAccount.chChart_ID  := ExistingAccount.chChart_ID;
          NewAccount.chEnter_Quantity         := ExistingAccount.chEnter_Quantity;
          NewAccount.chMoney_Variance_Up      := ExistingAccount.chMoney_Variance_Up;
          NewAccount.chMoney_Variance_Down    := ExistingAccount.chMoney_Variance_Down;
          NewAccount.chPercent_Variance_Up    := ExistingAccount.chPercent_Variance_Up;
          NewAccount.chPercent_Variance_Down  := ExistingAccount.chPercent_Variance_Down;
          NewAccount.chPrint_in_Division      := ExistingAccount.chPrint_in_Division;
          NewAccount.chLinked_Account_OS      := ExistingAccount.chLinked_Account_OS;
          NewAccount.chLinked_Account_CS      := ExistingAccount.chLinked_Account_CS;
          NewAccount.chHide_In_Basic_Chart    := ExistingAccount.chHide_In_Basic_Chart;
          NewAccount.chInactive               := ExistingAccount.chInactive;

       end else
          NewAccount.chAccount_Type := atNone; // N/A

       //make sure we don't set it to bkFORCE_GST_CLASS_TO_ZERO
       if ( NewAccount.chGST_Class = bkFORCE_GST_CLASS_TO_ZERO) then
         NewAccount.chGST_Class := 0;
     end;
   end;

   aClient.clChart.Free;  {free old chart - no longer needed}
   aClient.clChart := nil;

   aClient.clChart := NewChart;

   //*** Flag Audit ***
   aClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);

   NewChart := nil;   {only kill the pointer, DON'T kill the data}
   result := true;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function StripInvalidCharacters(aValue: String): String;
var
  StrIndex : integer;
begin
  Result := '';
  for StrIndex := 1 to Length(aValue) do
  begin
    if not (aValue[StrIndex] = ',') then
      Result := Result + aValue[StrIndex];
  end;
end;

//------------------------------------------------------------------------------
function GetMappedReportGroupCode(aMappedGroupId : TCashBookChartClasses): string;
begin
  case aMappedGroupId of
    ccNone         : Result := 'uncategorised';
    ccIncome       : Result := 'Income';
    ccExpense      : Result := 'Expense';
    ccOtherIncome  : Result := 'Other Income';
    ccOtherExpense : Result := 'Other Expense';
    ccAsset        : Result := 'Assets';
    ccLiabilities  : Result := 'Liabilities';
    ccEquity       : Result := 'Equity';
    ccCostOfSales  : Result := 'Cost of sales';
  end;
end;

//------------------------------------------------------------------------------
function GetMigrationMappedReportGroupCode(aMappedGroupId : TCashBookChartClasses): string;
begin
  case aMappedGroupId of
    ccNone         : Result := 'uncategorised';
    ccIncome       : Result := 'income';
    ccExpense      : Result := 'expense';
    ccOtherIncome  : Result := 'other_income';
    ccOtherExpense : Result := 'other_expense';
    ccAsset        : Result := 'asset';
    ccLiabilities  : Result := 'liability';
    ccEquity       : Result := 'equity';
    ccCostOfSales  : Result := 'cost_of_sales';
  end;
end;

//------------------------------------------------------------------------------
function SendZeroOpeningBalance(aMappedGroupId : TCashBookChartClasses; aOpeningBalanceDate, aFinancialYearStart : TstDate): boolean;
var
  FinDay, FinMonth, FinYear : integer;
  OpenDay, OpenMonth, OpenYear : Integer;
begin
  Result := false;

  if not (aMappedGroupId in [ccIncome, ccCostOfSales, ccExpense]) then
    Exit;

  StDateToDMY(aFinancialYearStart, FinDay, FinMonth, FinYear);
  StDateToDMY(aOpeningBalanceDate, OpenDay, OpenMonth, OpenYear);

  Result := ((OpenDay = 1) and (OpenMonth = FinMonth));
end;

//------------------------------------------------------------------------------
function GetGSTClassTypeIndicatorFromGSTClass(aGST_Class : byte) : byte;
begin
  If ( aGST_Class in GST_CLASS_RANGE ) then
    Result := MyClient.clFields.clGST_Class_Types[aGST_Class]
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function GetMappedNZGSTTypeCode(aGSTClassTypeIndicator : byte): TCashBookGSTClasses;
begin
  case aGSTClassTypeIndicator of
    gtUndefined      : Result := cgNone;
    gtIncomeGST      : Result := cgGoodsandServices;
    gtExpenditureGST : Result := cgGoodsandServices;
    gtExempt         : Result := cgExempt;
    gtZeroRated      : Result := cgZeroRated;
    gtCustoms        : Result := cgCustoms
  else
    Result := cgNone;
  end;
end;

//------------------------------------------------------------------------------
procedure GetMYOBCashbookGSTDetails(aCashBookGstClass : TCashBookGSTClasses;
                                    var aCashBookGstClassCode : string;
                                    var aCashBookGstClassDesc : string);
begin
  case aCashBookGstClass of
    cgNone : begin
      aCashBookGstClassCode := 'NA';
      aCashBookGstClassDesc := 'Undefined';
    end;
    cgGoodsandServices : begin
      aCashBookGstClassCode := 'GST';
      aCashBookGstClassDesc := 'Goods & Services Tax';
    end;
    cgCapitalAcquisitions : begin
      aCashBookGstClassCode := 'CAP';
      aCashBookGstClassDesc := 'Capital Acquisitions';
    end;
    cgExportSales : begin
      aCashBookGstClassCode := 'EXP';
      aCashBookGstClassDesc := 'Export Sales';
    end;
    cgGSTFree : begin
      aCashBookGstClassCode := 'FRE';
      aCashBookGstClassDesc := 'GST Free';
    end;
    cgInputTaxedSales : begin
      aCashBookGstClassCode := 'ITS';
      aCashBookGstClassDesc := 'Input Taxed Sales';
    end;
    cgPurchaseForInput : begin
      aCashBookGstClassCode := 'INP';
      aCashBookGstClassDesc := 'Purchases for Input Tax Sales';
    end;
    cgNotReportable : begin
      aCashBookGstClassCode := 'NTR';
      aCashBookGstClassDesc := 'Not Reportable';
    end;
    cgGSTNotRegistered : begin
      aCashBookGstClassCode := 'GNR';
      aCashBookGstClassDesc := 'GST Not Registered';
    end;
    cgExempt : begin
      aCashBookGstClassCode := 'E';
      aCashBookGstClassDesc := 'Exempt';
    end;
    cgZeroRated : begin
      aCashBookGstClassCode := 'Z';
      aCashBookGstClassDesc := 'Zero-Rated';
    end;
    cgCustoms : begin
      aCashBookGstClassCode := 'I';
      aCashBookGstClassDesc := 'GST on Customs Invoice';
    end;
  end;
end;

//------------------------------------------------------------------------------
function GetLastFullyCodedMonth(var aFullyCodedMonth : TStDate): Boolean;
Const
  MAX_YEARS_TO_GOBACK = 10;
var
  StartDay, StartMonth, StartYear, PeriodIndex : integer;
  CurrentYear : integer;
  PeriodType : integer;

  MaxPeriods : integer;

  tmpYearStarts, tmpYearEnds : integer;
begin
  Result := false;
  StartYear  := YearOf(Now());
  StartDay   := 1;
  StartMonth := 1;

  for CurrentYear := StartYear downto StartYear - MAX_YEARS_TO_GOBACK do
  begin
    tmpYearStarts := DmyToStDate(StartDay, StartMonth, CurrentYear, bkDateEpoch);
    tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);

    PeriodType := frpMonthly;

    MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( MyClient,
                                                          tmpYearStarts,
                                                          tmpYearEnds,
                                                          false,
                                                          PeriodType,
                                                          MyClient.clFields.clTemp_Period_Details_This_Year);

    for PeriodIndex := MaxPeriods downto 1 do
    begin
      If (MyClient.clFields.clTemp_Period_Details_This_Year[PeriodIndex].HasData) and
         (not( MyClient.clFields.clTemp_Period_Details_This_Year[PeriodIndex].HasUncodedEntries)) then
      begin
        aFullyCodedMonth := MyClient.clFields.clTemp_Period_Details_This_Year[PeriodIndex].Period_End_Date;
        Result := true;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function GetMigrationOpeningBalance(aValue : string) : integer;
var
  ValStr : string;
  Index : integer;
begin
  Result := 0;

  ValStr := '';
  for Index := 1 to length(aValue) do
    if aValue[Index] <> '.' then
      ValStr := ValStr + aValue[Index];

  TryStrtoint(ValStr, Result);
end;

//------------------------------------------------------------------------------
function IsGSTClassUsedInChart(aChartExportCol : TObject; aGST_Class: byte): boolean;
var
  ChartIndex : integer;
  ChartExportItem: TChartExportItem;
  ChartExportCol : TChartExportCol;
begin
  Result := false;

  if not(aChartExportCol is TChartExportCol) then
    Exit;

  ChartExportCol := TChartExportCol(aChartExportCol);

  for ChartIndex := 0 to ChartExportCol.count-1 do
  begin
    if ChartExportCol.ItemAtColIndex(ChartIndex, ChartExportItem) then
    begin
      if ChartExportItem.GSTClassId = aGST_Class then
      begin
        Result := true;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function IsChartCodeABankContra(aCode: string): boolean;
var
  BankAcc      : TBank_Account;
  BankAccIndex : Integer;
begin
  Result := false;

  if trim(aCode) = '' then
    Exit;

  for BankAccIndex := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
  begin
    BankAcc := MyClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
    if (BankAcc.baFields.baContra_Account_Code = aCode) and
       (not (BankAcc.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure FillGstMapCol(aChartExportCol : TObject; aGSTMapCol : TObject; aExcludeGSTItemsNotInChart : boolean);
var
  GstIndex : integer;
  ChartExportCol : TChartExportCol;
  GSTMapCol : TGSTMapCol;
begin
   if not (aChartExportCol is TChartExportCol) or
      not (aGSTMapCol is TGSTMapCol) then
     Exit;

  ChartExportCol := TChartExportCol(aChartExportCol);
  GSTMapCol := TGSTMapCol(aGSTMapCol);

  GSTMapCol.Clear;
  for GstIndex := 1 to high(MyClient.clfields.clGST_Class_Names) do
  begin
    if MyClient.clfields.clGST_Class_Names[GstIndex] > '' then
    begin
      if (not aExcludeGSTItemsNotInChart) or
         (IsGSTClassUsedInChart(ChartExportCol, GstIndex)) then
      begin
        GSTMapCol.AddGSTMapItem(GstIndex,
                                MyClient.clfields.clGST_Class_Codes[GstIndex],
                                MyClient.clfields.clGST_Class_Names[GstIndex],
                                GSTMapCol.GetMappedAUGSTTypeCode(MyClient.clfields.clGST_Class_Names[GstIndex]));
      end;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
