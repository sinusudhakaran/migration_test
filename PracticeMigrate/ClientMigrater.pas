unit ClientMigrater;



interface

uses
   Classes,
   DB,
   ADODB,
   syDefs,
   bkTables,
   CDTables,
   sqlHelpers,
   Guidlist,
   Migraters,
   clobj32,
   MigrateActions;

type

TClientMigrater = class (TMigrater)
  private
    FCode: string;
    FClientID: TGuid;
    FClient: TClientObj;
    FDoSuperfund: Boolean;
    DissectionCount: Integer;
    FClient_RecFieldsTable: TClient_RecFieldsTable;
    FBudget_Detail_RecTable: TBudget_Detail_RecTable;
    FChart_RecTable: TChart_RecTable;
    FBudget_Header_RecTable: TBudget_Header_RecTable;
    FMemorisation_Line_RecTable: TMemorisation_Line_RecTable;
    FPayee_Detail_RecTable: TPayee_Detail_RecTable;
    FCustom_Heading_RecTable: TCustom_Heading_RecTable;
    FTransaction_RecTable: TTransaction_RecTable;
    FJob_Heading_RecTable: TJob_Heading_RecTable;
    FDissection_RecTable: TDissection_RecTable;
    FMemorisation_Detail_RecTable: TMemorisation_Detail_RecTable;
    FAccount_RecTable: TAccount_RecTable;
    FPayee_Line_RecTable: TPayee_Line_RecTable;
    FDivisionsTable: TDivisionsTable;
    FTaxEntriesTable: TTaxEntriesTable;
    FTaxRatesTable: TTaxRatesTable;
    FClient_ScheduleTable: TClient_ScheduleTable;
    FSubGroupTable: TSubGroupTable;
    //FClient_ReportOptionsTable: TClient_ReportOptionsTable;
    FClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable;
    FCodingReportOptionsTable: TCodingReportOptionsTable;
    FCustomDocSceduleTable: TCustomDocSceduleTable;
    FSystemMirater: TMigrater;
    FClientLRN: Integer;
    FChartDivisionTable: TChartDivisionTable;
    FDivisionList: TGuidList;
    FReminderTable: TReminderTable;
    FDownloadlogTable: TDownloadlogTable;
    FBalances_RecTable: TBalances_RecTable;
    FBalances_ParamTable: TBalances_ParamTable;
    FFuelSheetTable: TFuelSheetTable;
    FBAS_OptionsTable: TBAS_OptionsTable;
    FNotesOptionsTable: TNotesOptionsTable;
    FColumnConfigTable: TColumnConfigTable;
    FColumnConfigColumnsTable: TColumnConfigColumnsTable;
    FMatchIDList: TGuidList;
    FMemList: TGuidList;
    FMasterMemList: TGuidList;
    //FUpdateAccountStatus: TADOStoredProc;
    //FUpdateProcessingStatusForAllClients : TADOStoredProc;
    FExcludedFromScheduledReports: TStringList;
    FClientReportTable: TClientReportTable;
    FReportParameterTable: TReportParameterTable;
    procedure SetClientID(const Value: TGuid);
    procedure SetCode(const Value: string);

    procedure AddGStRates(ForAction: TMigrateAction);
    procedure AddDivisions(ForAction: TMigrateAction);
    procedure AddSubGroups(ForAction: TMigrateAction);
    procedure AddReminders(ForAction: TMigrateAction);
    procedure MigrateDiskLog(ForAction: TMigrateAction);


    // List iteration functions
    function AddTransaction(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddMemorisation(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddAccount(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddBudget(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddBudgetLine(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddChart(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddJob(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddPayee(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddPayeeLine(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddHeading(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddBalance(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddDiskLog(ForAction: TMigrateAction; Value: TGuidObject): Boolean;


    procedure Reset;
    function GetAccount_RecTable: TAccount_RecTable;
    function GetBudget_Detail_RecTable: TBudget_Detail_RecTable;
    function GetBudget_Header_RecTable: TBudget_Header_RecTable;
    function GetChart_RecTable: TChart_RecTable;
    function GetClient_RecFieldsTable: TClient_RecFieldsTable;
    function GetCustom_Heading_RecTable: TCustom_Heading_RecTable;
    function GetDissection_RecTable: TDissection_RecTable;
    function GetJob_Heading_RecTable: TJob_Heading_RecTable;
    function GetMemorisation_Detail_RecTable: TMemorisation_Detail_RecTable;
    function GetMemorisation_Line_RecTable: TMemorisation_Line_RecTable;
    function GetPayee_Detail_RecTable: TPayee_Detail_RecTable;
    function GetPayee_Line_RecTable: TPayee_Line_RecTable;
    function GetTransaction_RecTable: TTransaction_RecTable;
    function GetDivisionsTable: TDivisionsTable;
    function GetTaxEntriesTable: TTaxEntriesTable;
    function GetTaxRatesTable: TTaxRatesTable;
    function GetClient_ScheduleTable: TClient_ScheduleTable;
    function GetColumnConfigTable: TColumnConfigTable;
    function GetColumnConfigColumnsTable: TColumnConfigColumnsTable;
    function GetSubGroupTable: TSubGroupTable;
    //function GetClient_ReportOptionsTable: TClient_ReportOptionsTable;
    function GetClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable;
    function GetCodingReportOptionsTable: TCodingReportOptionsTable;
    procedure SetDoSuperfund(const Value: Boolean);
    procedure SetSystemMirater(const Value: TMigrater);
    procedure SetClientLRN(const Value: Integer);
    function GetChartDivisionTable: TChartDivisionTable;
    procedure SetDivisionList(const Value: TGuidList);
    function GetDivisionList: TGuidList;
    function GetReminderTable: TReminderTable;
    function GetDownloadlogTable: TDownloadlogTable;
    function GetBalances_RecTable: TBalances_RecTable;
    function GetBalances_ParamTable: TBalances_ParamTable;
    function GetFuelSheetTable: TFuelSheetTable;
    function GetCustomDocSceduleTable: TCustomDocSceduleTable;
    function GetTBAS_OptionsTable: TBAS_OptionsTable;
    function GetNotesOptionsTable: TNotesOptionsTable;
    function GetMatchIDList: TGuidList;
    //function GetUpdateAccountStatus: TADOStoredProc;
    //function GetUpdateProcessingStatusForAllClients: TADOStoredProc;
    function GetReportParameterTable: TReportParameterTable;
    function GetClientReportTable: TClientReportTable;
    procedure SetMemList(const Value: TGuidList);
   
  public
   constructor Create(AConnection: string);
   destructor Destroy; override;
   function ClearData(ForAction: TMigrateAction): Boolean; override;

   function Migrate(ForAction:TMigrateAction;
                    ACode: string;
                    AClientID,
                    AUserID,
                    AGroupID,
                    ATypeID: TGuid;
                    AMagicNumber,
                    ACountry: Integer;
                    CheckedOutUserID: TGuid;
                    AClient: pClient_File_Rec = nil): Boolean;


   // Tables
   property Client_RecFieldsTable: TClient_RecFieldsTable read GetClient_RecFieldsTable;
   property Account_RecTable: TAccount_RecTable read GetAccount_RecTable;
   property Transaction_RecTable: TTransaction_RecTable read GetTransaction_RecTable;
   property Dissection_RecTable: TDissection_RecTable read GetDissection_RecTable;
   property Memorisation_Detail_RecTable: TMemorisation_Detail_RecTable read GetMemorisation_Detail_RecTable;
   property Memorisation_Line_RecTable: TMemorisation_Line_RecTable read GetMemorisation_Line_RecTable;
   property Chart_RecTable: TChart_RecTable read GetChart_RecTable;
   property Custom_Heading_RecTable: TCustom_Heading_RecTable read GetCustom_Heading_RecTable;
   property Payee_Detail_RecTable: TPayee_Detail_RecTable read GetPayee_Detail_RecTable;
   property Payee_Line_RecTable: TPayee_Line_RecTable read GetPayee_Line_RecTable;
   property Job_Heading_RecTable: TJob_Heading_RecTable read GetJob_Heading_RecTable;
   property Budget_Header_RecTable: TBudget_Header_RecTable read GetBudget_Header_RecTable;
   property Budget_Detail_RecTable: TBudget_Detail_RecTable read GetBudget_Detail_RecTable;
   property DivisionsTable: TDivisionsTable read GetDivisionsTable;
   property SubGroupTable: TSubGroupTable read GetSubGroupTable;
   property TaxEntriesTable: TTaxEntriesTable read GetTaxEntriesTable;
   property TaxRatesTable: TTaxRatesTable read GetTaxRatesTable;
   property Balances_RecTable: TBalances_RecTable read GetBalances_RecTable;
   property Balances_ParamTable: TBalances_ParamTable read GetBalances_ParamTable;
   property FuelSheetTable: TFuelSheetTable read GetFuelSheetTable;
   property Client_ScheduleTable: TClient_ScheduleTable read GetClient_ScheduleTable;
   //property Client_ReportOptionsTable: TClient_ReportOptionsTable read GetClient_ReportOptionsTable;
   property ClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable read GetClientFinacialReportOptionsTable;
   property CodingReportOptionsTable: TCodingReportOptionsTable read GetCodingReportOptionsTable;
   property ChartDivisionTable: TChartDivisionTable read GetChartDivisionTable;
   property ReminderTable: TReminderTable read GetReminderTable;
   property DownloadlogTable: TDownloadlogTable read GetDownloadlogTable;
   property CustomDocSceduleTable: TCustomDocSceduleTable read GetCustomDocSceduleTable;
   property BAS_OptionsTable: TBAS_OptionsTable read GetTBAS_OptionsTable;
   property NotesOptionsTable: TNotesOptionsTable read GetNotesOptionsTable;
   property ReportParameterTable: TReportParameterTable read GetReportParameterTable;
   property ClientReportTable: TClientReportTable read GetClientReportTable;
   property ColumnConfigTable: TColumnConfigTable read GetColumnConfigTable;
   property ColumnConfigColumnsTable: TColumnConfigColumnsTable read GetColumnConfigColumnsTable;

   // Lists
   property DivisionList: TGuidList read GetDivisionList write SetDivisionList;
   property MatchIDList: TGuidList read GetMatchIDList;
   property MemList: TGuidList read FMemList write SetMemList;
   property MasterMemList: TGuidList read FMasterMemList write FMasterMemList;

   // Stored Procs
  // property UpdateAccountStatus: TADOStoredProc read GetUpdateAccountStatus;
  // procedure UpdateClientsStatus(ForAction: TMigrateAction);

  // property UpdateProcessingStatusForAllClients: TADOStoredProc read GetUpdateProcessingStatusForAllClients;
  // procedure UpdateProcessingStatusAllClients(ForAction: TMigrateAction);

   property DoSuperfund: Boolean read FDoSuperfund write SetDoSuperfund;
   property Code: string read FCode write SetCode;
   property ClientID: TGuid read FClientID write SetClientID;
   property ClientLRN: Integer read FClientLRN write SetClientLRN;

   property SystemMirater:TMigrater read FSystemMirater write SetSystemMirater;
   function GetUser(const Value: string): TGuid;
end;


implementation
uses
   mxFiles32,
   AutoCode32,
   logger,
   STRUtils,
   OmniXML,
   OmniXMLUtils,
   ClientDetailCacheObj,
   variants,
   MigrateTable,
   MoneyDef,
   UBatchBase,
   CustomDocEditorFrm,
   ToDoListUnit,
   AdminNotesForClient,
   SystemMigrater,
   BUDOBJ32,
   PayeeObj,
   MemorisationsObj,
   bkConst,
   bkDefs,
   stDate,
   glConst,
   baObj32,
   Software,
   files,
   Sysutils,
   logutil,
   Globals;

{ TClientMigrater }

function TClientMigrater.Addaccount(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
   MyAction: TMigrateAction;
   Account: tBank_Account;
   GuidList: TGuidList;

   AdminBankAccount: TGuidObject;
   Map: TGuidObject;
   MapRec: tClient_Account_Map_Rec;

   function AddClientAccountMap: pClient_Account_Map_Rec;
   var System: TSystemMigrater;

       function GetClientMap: TGuidObject;
       var I: Integer;
       begin
          Result := nil;
          for I := 0 to System.ClientAccountMap.Count - 1 do
             with pClient_Account_Map_Rec(TGuidObject(System.ClientAccountMap[I]).Data)^ do
                if  (amClient_LRN = ClientLRN)
                and (amAccount_LRN = pSystem_Bank_Account_Rec(AdminBankAccount.Data).sbLRN) then begin
                   Result := TGuidObject(System.ClientAccountMap[I]);
                   Exit;
                end;
       end;
   begin
      Result := nil;
      if not Assigned(SystemMirater) then
         Exit;
      System := SystemMirater as TSystemMigrater;
      AdminBankAccount := System.GetSystemAccount(Account.baFields.baBank_Account_Number);
      if not Assigned(AdminBankAccount) then
         Exit;

      Map := getClientMap;
      if Assigned(Map) then begin
         // Have map.. All ok
         System.ClientAccountMapTable.Insert(Map.GuidID, ClientID, Value.GuidID, AdminBankAccount.GuidID, pClient_Account_Map_Rec(Map.Data));
         Result := pClient_Account_Map_Rec(Map.Data);
      end else if (Account.baFields.baAccount_Type = btBank)
               and (FClient.clFields.clMagic_Number = System.System.fdFields.fdMagic_Number)
               and (not FClient.clFields.clSuppress_Check_for_New_TXns)
               and (FClient.clFields.clDownload_From = dlAdminSystem)
               and (PSystem_Bank_Account_Rec(AdminBankAccount.Data).sbAccount_Type <> sbtOnlineSecure) then begin
         // Have matching accounts No ... Need to add a map entry
         MyAction.AddWarning (format('Client account map added for Account %s: %s',[FClient.clFields.clCode, Account.Title]));
         fillChar(MapRec, Sizeof(MapRec), 0);
         System.ClientAccountMapTable.Insert(NewGuid, ClientID, Value.GuidID, AdminBankAccount.GuidID, @MapRec);
      end;

   end;

   function ExcludedFromScheduledReports : Boolean;
   begin
       Result := false;
       if not assigned(FExcludedFromScheduledReports) then
          Exit;
       result := FExcludedFromScheduledReports.IndexOf(Account.baFields.baBank_Account_Number)>=0;
   end;
     (*
   procedure  DoUpdateAccountStatus(ForAction:TMigrateAction);
   var MyAction : TMigrateAction;
   begin
      MyAction := ForAction.InsertAction ('Update status');
      try
         UpdateAccountStatus.Parameters.ParamByName('@CLIENTID').Value := TMigrateTable.toSQL(ClientID);
         UpdateAccountStatus.Parameters.ParamByName('@BANKACCOUNTID').Value := TMigrateTable.toSQL(Value.GuidID);
         UpdateAccountStatus.ExecProc;
         MyAction.Status := Success;
      except
         on E: Exception do
           MyAction.Error := E.Message;
      end;
   end;
     *)
   procedure AddColumnConfiguration (
        ScreenType: Integer; // the screen type we are saving
        Positions: array of byte;
        Widths: array of integer;
        IsEdtiables: array of Boolean;
        IsVisibles: array of Boolean;
        SortColumn: Integer);

   var ConfigID: TGuid;
       I: Integer;
       Name: string;
       NoData : boolean;
   begin
       // Test First....
       NoData := true;
       for I := low(positions) to High(Positions) do
           if (Widths[i] > 0)then begin
              Nodata := false;
              break; // One is enough ??
           end;
       if Nodata then
          Exit;
       // Have a Go..
       ConfigID := NewGuid;
       ColumnConfigTable.Insert(ConfigID,Value.GuidID,ScreenType,bkConst.whShortNames[FClient.clFields.clCountry], CurrentDate);

       for I := low(positions) to High(Positions) do begin
          Name := GetColumnName(FClient.clFields.clCountry,ScreenType,I);
          if (Name = '')
          or (Widths[i] = 0) then
             Continue;
          ColumnConfigColumnsTable.Insert(NewGuid, ConfigID, Name,
              Positions[i],
              Widths[i],
              not IsEdtiables[i],
              not IsVisibles[i],
              IsSortColumn(ScreenType,I, SortColumn) ); // This is the sort column
       end;
   end;

   procedure GetMasteMemList;
   var BankPrefix : string;
       System: TSystemMigrater;
   begin
      if not Assigned(SystemMirater) then
         Exit;
      System := SystemMirater as TSystemMigrater;

      FmasterMemList := nil;
      if (Account.baFields.baApply_Master_Memorised_Entries) and Assigned(AdminSystem) and
         (FClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) and
         (FClient.clFields.clDownload_From = dlAdminSystem) then
      begin
         BankPrefix := mxFiles32.GetBankPrefix(Account.baFields.baBank_Account_Number);
         if BankPrefix = '' then
            exit;
         masterMemList :=  System.GetMasterMemList(BankPrefix);

      end;
   end;
begin
   Result := False;
   Account := tBank_Account(Value.Data);
   GuidList := nil;
   FreeAndNil(FMemList);


   MyAction := ForAction.InsertAction (Account.Title,Value);
   try try
      Account_RecTable.Insert
          (
             Value.GuidID,
             ClientID,
             @Account.baFields,
             AddClientAccountMap,
             ExcludedFromScheduledReports
          );

       if Account.baFields.baAccount_Type = btBank then
         AddColumnConfiguration(0,
                 Account.baFields.baColumn_Order,
                 Account.baFields.baColumn_Width,
                 Account.baFields.baColumn_Is_Not_Editable,
                 Account.baFields.baColumn_is_Hidden,
                 Account.baFields.baCoding_Sort_Order)
       else if Account.baFields.baAccount_Type in [ btCashJournals, btAccrualJournals, btGSTJournals,  btStockJournals] then
          // List journals
          AddColumnConfiguration(3,
                 Account.baFields.baColumn_Order,
                 Account.baFields.baColumn_Width,
                 Account.baFields.baColumn_Is_Not_Editable,
                 Account.baFields.baColumn_is_Hidden,
                 Account.baFields.baCoding_Sort_Order);


       if Account.baFields.baAccount_Type = 0 then
           // Dissections..
          AddColumnConfiguration(1,
                 Account.baFields.baDIS_Column_Order,
                 Account.baFields.baDIS_Column_Width,
                 Account.baFields.baDIS_Column_Is_Not_Editable,
                 Account.baFields.baDIS_Column_is_Hidden,                 

                 Account.baFields.baDIS_Sort_Order)
        else if Account.baFields.baAccount_Type in [ btCashJournals, btAccrualJournals, btGSTJournals,  btStockJournals] then
           // JourNal entry..
          AddColumnConfiguration(4,
                 Account.baFields.baDIS_Column_Order,
                 Account.baFields.baDIS_Column_Width,
                 Account.baFields.baDIS_Column_Is_Not_Editable,
                 Account.baFields.baDIS_Column_is_Hidden,
                 Account.baFields.baDIS_Sort_Order);

       AddColumnConfiguration(2,
                 Account.baFields.baMDE_Column_Order,
                 Account.baFields.baMDE_Column_Width,
                 Account.baFields.baMDE_Column_Is_Not_Editable,
                 Account.baFields.baMDE_Column_is_Hidden,
                 Account.baFields.baMDE_Sort_Order);

        {
        AddColumnConfiguration(3,
                 Account.baFields.baHDE_Column_Order,
                 Account.baFields.baHDE_Column_Width,
                 Account.baFields.baHDE_Column_Is_Not_Editable,
                 Account.baFields.baHDE_Column_is_Hidden,
                 Account.baFields.baHDE_Sort_Order);
                 }


       MemList := TGuidList.Create(Account.baMemorisations_List);
       MemList.reverse;
       if not RunGuidList(MyAction,'Memorizations',MemList,AddMemorisation) then
          Exit;

       GetMasteMemList;

       AutoCodeEntries(FClient,Account,AllEntries,0,0);

       GuidList := TGuidList.Create(Account.baTransaction_List);
       if not RunGuidList(MyAction,'Transactions',GuidList,AddTransaction) then
          Exit;


       MyAction.Status := Success;


       //DoUpdateAccountStatus(MyAction);

       Result := True;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
   finally
      FreeAndNil(GuidList);
      FreeAndNil(FMemList);
   end;
end;


function TClientMigrater.AddBalance(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var Balance : pBalances_Rec;
    FuelSheet: pFuel_Sheet_Rec;
begin
   Balance := pBalances_Rec(Value.Data);
   Result := Balances_RecTable.Insert(Value.GuidID, ClientID, Balance);
   if not Result then
      Exit;

   Result := Balances_ParamTable.Insert(Value.GuidID, Balance);
   if not Result then
      Exit;

   FuelSheet := Balance.blFirst_Fuel_Sheet;
   while assigned(FuelSheet) do begin
      { TODO : Re do Fuel sheet }
      //Result := FuelSheetTable.Insert(NewGuid,Value.GuidID, Fuelsheet);
      if not Result then
         Exit;
      FuelSheet := FuelSheet.fsNext;
   end;
end;

function TClientMigrater.AddBudget(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
   Budget: tBudget;
   Linelist: TGuidList;
begin
    Budget := tBudget(Value.Data);
    Result := Budget_Header_RecTable.Insert(Value.GuidID,ClientID,@Budget.buFields);
    if not result then
      Exit;
    Linelist := TGuidList.Create(Budget.buDetail);
    ForAction.Item := Value;
    try
       Result := RunGuidList(ForAction,'',Linelist,AddBudgetLine);
    finally
       FreeAndNil(LineList);
    end;
end;

function TClientMigrater.AddBudgetLine(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var P: Integer;
begin
   Result := false;
   with pBudget_Detail_Rec(Value.data)^ do
      for P := 1 to 12 do
         if (bdBudget[P] <> 0)
         or (bdQty_Budget[P] <> 0)
         or (bdEach_Budget[P] <> 0) then begin
            Result := Budget_Detail_RecTable.Insert(NewGuid,ForAction.Item.GuidID,P,pBudget_Detail_Rec(Value.data));
            if not Result then
               Exit;
         end;
end;

function TClientMigrater.AddChart(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var Account: pAccount_Rec;
    I: Integer;
    Division: TGuidObject;

    function GetDivision(Value: integer):TGuidObject;
    var I: Integer;
    begin
       Result := nil;
       for I := 0 to DivisionList.Count - 1 do
          if TGuidObject(DivisionList[I]).SequenceNo = value then begin
             Result := TGuidObject(DivisionList[I]);
             Exit;
          end;
    end;

begin
   Account := pAccount_Rec(Value.Data);
   // First the chart..
   Result := Chart_recTable.Insert(Value.GuidID,ClientID, Account);
   // Now do the divisions..
   for I := low(Account.chPrint_in_Division) to high(Account.chPrint_in_Division) do begin
      if not Account.chPrint_in_Division[I] then
         Continue;
      Division := GetDivision(I);
      if Assigned(Division) then begin
         Result := ChartDivisionTable.Insert(NewGuid, Value.GuidID, ClientID, I);
         if not Result then
            Exit;
      end;
   end;
end;

procedure TClientMigrater.MigrateDiskLog(ForAction: TMigrateAction);
var lList: TGuidList;
begin
   if FClient.clDisk_Log.ItemCount < 1 then
      Exit;

   lList := TGuidList.Create(FClient.clDisk_Log);
   try
      RunGuidList(ForAction,'Disk log',lList, AddDiskLog);
   finally
      lList.Free;
   end;
end;

function TClientMigrater.AddDiskLog(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
  Result := DownloadLogTable.Insert(Value.GuidID, ClientID, pDisk_Log_Rec(Value.Data))
end;

procedure TClientMigrater.AddDivisions(ForAction: TMigrateAction);
var I,C: Integer;
    DivisionName: string;
    Division: TGuidObject;
begin
   if ForAction.CheckCanceled then
      Exit;
   C := 0;
   DivisionList.Clear;
   for i := 1 to Max_Divisions do begin
      DivisionName := Trim(FClient.clCustom_Headings_List.Get_Division_Heading(i));
      if DivisionName > '' then begin
         // Keep the Divisions as a Lookup
         Division := TGuidObject.Create;
         Division.GuidID := NewGuid;
         Division.SequenceNo := i;
         DivisionList.Add(Division);
         if DivisionsTable.Insert(Division.GuidID, ClientID, Division.SequenceNo, DivisionName) then
            inc(C);

      end;
   end;
   if C > 0 then
      ForAction.InsertAction('Divisions').Count := C;
end;

procedure TClientMigrater.AddGStRates(ForAction: TMigrateAction);
 var
    ClassNo,
    Rate: Integer;
    EntryId,
    ClassId: TGuid;
begin
   if ForAction.CheckCanceled then
      Exit;

   for ClassNo := 1 to MAX_GST_CLASS do begin
      if FClient.clFields.clGST_Class_Names[ClassNo] = '' then
        Continue; // nothing to save...
      if FClient.clFields.clGST_Class_Codes[ClassNo] = '' then
        Continue;

      ClassID := GetTaxClassGuid(FClient.clFields.clCountry, FClient.clFields.clGST_Class_Types[ClassNo]);
      if IsEqualGUID(ClassID,emptyGuid) then
        Continue; // Not A Valid Tax Entry..

      try
      CreateGuid(EntryId);
      // Add The Entry
      TaxEntriesTable.Insert
         (
            EntryId,
            ClassID,
            ClientId,
            ClassNo,
            FClient.clFields.clGST_Class_Codes[ClassNo],
            FClient.clFields.clGST_Class_Names[ClassNo],
            FClient.clFields.clGST_Account_Codes[ClassNo],
            FClient.clFields.clGST_Business_Percent[ClassNo]
         );

      // Now add the rates
      for Rate := 1 to High(FClient.clFields.clGST_Applies_From) do begin

         if ((FClient.clFields.clGST_Applies_From[Rate]) = 0)
         or ((FClient.clFields.clGST_Applies_From[Rate]) = -1) then begin
            // No Date
            if FClient.clFields.clGST_Rates[ClassNo][Rate] = 0 then
               Continue //No date and No Rate... nothing to save...
            else
               TaxRatesTable.Insert
             (
                NewGuid,
                EntryId,
                FClient.clFields.clGST_Rates[ClassNo][Rate],
                141257 // 1-oct-1986
             );

         end else
            // Have Date so save rate, even if zero...
            TaxRatesTable.Insert
             (
                NewGuid,
                EntryId,
                FClient.clFields.clGST_Rates[ClassNo][Rate],
                FClient.clFields.clGST_Applies_From[Rate]
             );
      end;
      except
         on e: exception do
            ForAction.Exception(e, 'Adding Tax Rates')
      end;

   end;
end;

function TClientMigrater.AddHeading(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
  result := Custom_Heading_RecTable.Insert(Value.GuidID, ClientID, pCustom_Heading_Rec(Value.Data));
end;

function TClientMigrater.AddJob(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
begin
   Result := Job_Heading_RecTable.Insert(Value.GuidID,ClientID,pJob_Heading_Rec(Value.Data));
end;

function TClientMigrater.AddMemorisation(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
var
   Memorization: TMemorisation;
   LineList: TGuidList;
   I: Integer;
begin
   Memorization := TMemorisation(Value.Data);
   if Memorization.mdFields.mdFrom_Master_List then begin
      Result := True;
      Exit; // this does scew the result...
   end else
      Result := Memorisation_Detail_RecTable.Insert
                (
                   Value.GuidID,
                   ForAction.Item.GuidID,
                   GetProviderID(AccountingSystem,FClient.clFields.clCountry,
                              Memorization.mdFields.mdAccounting_System),
                   Value.SequenceNo,
                   Memorization.mdFields
                );

    if not Result then
       Exit;
    // Add The lines..
    LineList := TGuidList.Create(Memorization.mdLines);
    try
       for I := 0 to LineList.Count - 1 do begin
          with  TGuidObject(LineList.Items[I]) do
             Result := Memorisation_Line_RecTable.Insert
                       (
                            GuidID,
                            Value.GuidID,
                            Succ(i),
                            pMemorisation_Line_Rec(Data)

                       );
          if not Result then
             Exit;

       end;
    finally
       FreeAndnil(LineList);
    end;
end;

function TClientMigrater.AddPayee(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
  Payee: TPayee;
  Linelist: TGuidList;
begin
   LineList := nil;
   Payee := Value.Data;
   Result := Payee_Detail_RecTable.Insert(Value.GuidID,ClientID,@Payee.pdFields);
   if not result then
      Exit;
   Linelist := TGuidList.Create(Payee.pdLines);
   ForAction.Item := Value;
   try
      Result := RunGuidList(ForAction,'',Linelist,AddPayeeLine);
   finally
      FreeAndNil(LineList);
   end;
end;

function TClientMigrater.AddPayeeLine(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
   Result := Payee_Line_RecTable.Insert(Value.SequenceNo,Value.GuidID,ForAction.Item.GuidID, pPayee_Line_Rec(Value.Data));
end;

procedure TClientMigrater.AddReminders(ForAction: TMigrateAction);
var
   ClientsToDoList: TClientToDoList;
   I: Integer;
begin
   if ForAction.CheckCanceled then
      Exit;

   ClientsToDoList := TClientToDoList.Create(ClientLRN);
   try
      if ClientsToDoList.Count = 0 then
         Exit; // Nothing to do..

      for I := 0 to ClientsToDoList.Count - 1 do
         ReMinderTable.Insert(
             NewGuid,
             ClientID,
             GetUser(ClientsToDoList.ToDoItemAt(I).tdEntered_By),
             ClientsToDoList.ToDoItemAt(I)
                              );

      ForAction.InsertAction('Tasks').Count := ClientsToDoList.Count;
   finally
      FreeAndNil(ClientsToDoList);
   end;
end;

procedure TClientMigrater.AddSubGroups(ForAction: TMigrateAction);
var I,C: Integer;
    SubGroupName: string;
begin
   if ForAction.CheckCanceled then
      Exit;

   C := 0;
   for i := 1 to Max_SubGroups do begin
      SubGroupName := Trim(FClient.clCustom_Headings_List.Get_SubGroup_Heading(i));
      if SubGroupName > '' then begin
         if SubGroupTable.Insert(NewGuid,ClientID, i, SubGroupName) then
            inc(C);
      end;
   end;

   if C > 0 then begin
      ForAction.InsertAction('Subgroups').Count := C;
   end else begin
      SubGroupTable.Insert(NewGuid,ClientID, 0, 'Unallocated');
   end;
end;


function TClientMigrater.AddTransaction(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
   Diss: PDissection_Rec;
   Transaction: PTransaction_Rec;
   GST: money;
   JobCode: string;
   SplitPayee,
   IsDissected,
   IsSplitJob,
   IsPayeeOverridden,
   IsJobOverridden : Boolean;
   DissPayee : integer;

   function FindMem(fromList: TGuidList): TGuid;
   var I: Integer;
   begin
      fillChar(Result,Sizeof(TGuid),0);
      if not Assigned(fromList) then
         Exit;

      for I := 0 to fromList.Count - 1 do
         if TMemorisation(TGuidObject(fromList.Items[I]).Data).mdFields.mdSequence_No = Transaction.txMatched_By.mdSequence_No then begin
            Result := TGuidObject(fromList.Items[I]).GuidID;
            Exit;
         end;
   end;

   function GetMem: TGuid;
   begin
       fillChar(Result,Sizeof(TGuid),0);
       if Transaction.txCoded_By <> BKCONST.cbMemorisedC then
          exit;

       if not assigned(Transaction.txMatched_By) then
          exit;

       if Transaction.txMatched_By.mdFrom_Master_List then
          exit;
       Result := FindMem(memList);
   end;


   function GetMasterMem: TGuid;
   begin
       fillChar(Result,Sizeof(TGuid),0);
       if Transaction.txCoded_By <> BKCONST.cbMemorisedM then
          exit;
       if not assigned(Transaction.txMatched_By) then
          exit;
       if not Transaction.txMatched_By.mdFrom_Master_List then
          exit;
       Result := FindMem(MasterMemList);
   end;

begin
   Transaction := PTransaction_Rec(Value.Data);

   // reset the extra help fields
   GST := 0;
   SplitPayee := False;
   IsDissected := False;
   IsSplitJob := False;
   IsPayeeOverridden := False;
   IsJobOverridden := False;
   JobCode := '';
   DissPayee := 0;

   Diss := Transaction.txFirst_Dissection;
   while Assigned(Diss) do begin
      // Dissected ?
      IsDissected := true;

      // GST ?
      GST := GST + Diss.dsGST_Amount;

      // Split Job? See CodingForm
      if (Diss.dsJob_Code <> Transaction.txJob_code) then begin
         if (Transaction.txJob_code > '')
         and (Diss.dsJob_Code > '') then
            IsJobOverridden := True;

         if JobCode > '' then begin // Have Dissection Job
            if (JobCode <> Diss.dsJob_Code)
            and (Diss.dsJob_Code > '') then begin
                 //Dissections not the same
                 IsSplitJob := True;
            end;
         end else
            if Diss.dsJob_Code > '' then
              // First Dissection with a Job
              JobCode := Diss.dsJob_Code;
      end;

      if (Diss.dsAmount <> 0)
      or (Diss.dsAccount <> '') then begin
         if Diss.dsPayee_Number <> Transaction.txPayee_Number then begin
             if (Diss.dsPayee_Number <> 0)
             and (Transaction.txPayee_Number <> 0) then
               IsPayeeOverridden := True;

             if(DissPayee > 0) then begin
                if (DissPayee <> Diss.dsPayee_Number) then
                    SplitPayee := True;
             end else
                DissPayee := Diss.dsPayee_Number;

         end;

      end;


      Diss := Diss.dsNext;
   end;
   if IsDissected then
      Transaction.txGST_Amount := GST;


   Transaction_RecTable.Insert
                       (
                            Value.GuidID,
                            ForAction.Item.GuidID,
                            MatchIDList.GetIDGuid(Transaction.txMatched_Item_ID),
                            Transaction,
                            SplitPayee,
                            IsDissected,
                            IsSplitJob,
                            IsPayeeOverridden,
                            IsJobOverridden,
                            GetMem,
                            GetMasterMem
                       );

   Diss := Transaction.txFirst_Dissection;
   while Assigned(Diss) do begin

      Dissection_RecTable.Insert
                       (
                            NewGuid,
                            Value.GuidID,
                            Diss
                       );
      inc(DissectionCount);
      Diss := Diss.dsNext;
   end;
   Result := true;
end;

function TClientMigrater.ClearData(ForAction: TMigrateAction): Boolean;
var myAction: TMigrateAction;
    KeepTime: Integer;

    function ClearConfig : Boolean;
    var ClearAction: TMigrateAction;
    begin
       result := true;
       ClearAction := MyAction.InsertAction('Clear Column configuration');
       try
       RunSQL(connection,MyAction,
       'DELETE ccc FROM ( SELECT c.Id as confid FROM  CodingColumnConfigurations c where c.IsDefault = 0) cc INNER JOIN Codingcolumns ccc ON cc.confid = ccc.CodingColumnConfiguration_Id'
            ,'Clear Codingcolumns' );
        RunSQL(connection,MyAction,
       'DELETE c FROM CodingColumnConfigurations c where c.IsDefault = 0',
        'Clear CodingColumnConfigurations'
             );

         ClearAction.Status := Success;
       except
           on e: Exception do begin
              ClearAction.Exception(e);
              result := false;
           end;
       end;
    end;


    function ClearParametersTable(Name, Table: string) : Boolean;
    var ClearAction: TMigrateAction;
    begin
       result := true;

       ClearAction := MyAction.InsertAction(format('Clear %s',[Name]));
       try
           RunSQL(connection,MyAction, format('DELETE rp FROM [%s] rp where rp.[Client_ID] is not null',[Table]),'Clear Parameters' );
            ClearAction.Status := Success;
          except
           on e: Exception do begin
              ClearAction.Exception(e);
              result := false;
           end;
       end;
    end;


begin
   Result := false;
   MyAction := ForAction.InsertAction('Clear Clients');

   logger.LogMessage(Info,'Clearing All Client data');

   //RunSQL(Connection,MyAction,'EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"', 'Drop Constraints');

   try try
      Connected := true;
      EnableIndexes(MyAction,True);
      // Dont use the Table to get the name, Too early and Clear may not work...


      //DeleteTable(MyAction,'ClientBankAccountsProcessingStatus',True); Gone...
      
      DeleteTable(MyAction,Job_Heading_RecTable, True);

      DeleteTable(MYAction,'ClientDownloads', True);

      DeleteTable(MyAction,'FuelSheets', True);
      //DeleteTable(MyAction,'Balances');
      DeleteTable(MyAction,'TaxReturnParameters', True);
      DeleteTable(MyAction,'TaxReturns');


      DeleteTable(MyAction,NotesOptionsTable, True);
      DeleteTable(MyAction,BAS_OptionsTable, True);

      DeleteTable(MyAction,'Headings');

      DeleteTable(MyAction,CustomDocSceduleTable);
      //DeleteTable(MyAction,'CustomDocuments');

      DeleteTable(MyAction,'ScheduledTaskValues');

      DeleteTable(MyAction,'PayeeLines', True);
      DeleteTable(MyAction,'Payees');

      DeleteTable(MyAction,'BudgetLines', True);
      DeleteTable(MyAction,'Budgets');

      DeleteTable(MyAction,'TaxRates', True);
      DeleteTable(MyAction,'TaxEntries');

      DeleteTable(MyAction,'MemorisationLines', True);
      DeleteTable(MyAction,'Memorisations');
      DeleteTable(MyAction,'Dissections', True);

      //
      RunSQL(Connection,MyAction,Format('DBCC SHRINKFILE(''%s_Log'',1)',['PracticeClient']), 'Shrink Log');
      KeepTime := Connection.CommandTimeout;
      Connection.CommandTimeout := 20 * 60;
      DeleteTable(MyAction,'Transactions');
      Connection.CommandTimeout := KeepTime;

      ClearConfig;

      //DeleteTable(MyAction,'ProcessingStatuses'); Gone...

      DeleteTable(MyAction,'BankAccounts');
      DeleteTable(MyAction,'CodingReportOptions');
      //DeleteTable(MyAction,'ReportingOptions');
      DeleteTable(MyAction,'ReportSubGroups');

      DeleteTable(MyAction,'ClientReportDivisionCharts');
      DeleteTable(MyAction,Chart_RecTable);
      DeleteTable(MyAction,'ReportClientDivisions');

      DeleteTable(MyAction,'Reminders');

      DeleteTable(MyAction,ClientFinacialReportOptionsTable, True);

      // Still To do..
      DeleteTable(MyAction,'TaxReturnParameters', True);
      DeleteTable(MyAction,'TaxReturns');

      //DeleteTable(MyAction,'FavouriteReports', True);
      DeleteTable(MyAction,'ClientAttachments', True);

      DeleteTable(MyAction,'ClientTasks');

      ClearParametersTable('Client Parameters','ClientParameters');

      DeleteTable(MyAction,'ReportParameters',True);
      DeleteTable(MyAction,'ClientReports');

      //ClearParametersTable('Report Parameters','ReportParameters');

      DeleteTable(MyAction,'ReportParameters',True);

      KeepTime := Connection.CommandTimeout;
      Connection.CommandTimeout := 10 * 60;
      DeleteTable(MyAction,'Clients');
      Connection.CommandTimeout := KeepTime;

      Result := True;
      MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
   finally
      //RunSQL(Connection,MyAction,'EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"', 'Re-instate Constraints');
   end;
end;

constructor TClientMigrater.Create(AConnection: string);
begin
   inherited Create;
   Connection.DefaultDatabase := 'PracticeClient';
   FClient := nil;

   FClient_RecFieldsTable := nil;
   FBudget_Detail_RecTable := nil;
   FChart_RecTable := nil;
   FBudget_Header_RecTable := nil;
   FMemorisation_Line_RecTable := nil;
   FPayee_Detail_RecTable := nil;
   FCustom_Heading_RecTable := nil;
   FTransaction_RecTable := nil;
   FJob_Heading_RecTable := nil;
   FDissection_RecTable := nil;
   FSubGroupTable := nil;
   FMemorisation_Detail_RecTable := nil;
   FAccount_RecTable := nil;
   FPayee_Line_RecTable := nil;
   FDivisionsTable := nil;
   FDivisionList := nil;
   FTaxEntriesTable := nil;
   FTaxRatesTable := nil;
   FBalances_RecTable := nil;
   FFuelSheetTable := nil;
   FClient_ScheduleTable := nil;
   //FClient_ReportOptionsTable := nil;
   FClientFinacialReportOptionsTable := nil;
   FCodingReportOptionsTable := nil;
   FChartDivisionTable := nil;
   FReminderTable := nil;
   FDownloadlogTable := nil;
   FCustomDocSceduleTable := nil;
   FBAS_OptionsTable := nil;
   FNotesOptionsTable := nil;
   FExcludedFromScheduledReports := nil;
   FReportParameterTable := nil;
   FClientReportTable := nil;
   MemList := nil;
end;

destructor TClientMigrater.Destroy;
begin
  FreeAndNil(FClient_RecFieldsTable);
  FreeAndNil(FBudget_Detail_RecTable);
  FreeAndNil(FChart_RecTable);
  FreeAndNil(FBudget_Header_RecTable);
  FreeAndNil(FMemorisation_Line_RecTable);
  FreeAndNil(FPayee_Detail_RecTable);
  FreeAndNil(FCustom_Heading_RecTable);
  FreeAndNil(FTransaction_RecTable);
  FreeAndNil(FJob_Heading_RecTable);
  FreeAndNil(FDissection_RecTable);
  FreeAndNil(FSubGroupTable);
  FreeAndNil(FMemorisation_Detail_RecTable);
  FreeAndNil(FAccount_RecTable);
  FreeAndNil(FPayee_Line_RecTable);
  FreeAndNil(FDivisionsTable);
  FreeAndNil(FDivisionList);
  FreeAndnil(FTaxEntriesTable);
  FreeAndNil(FTaxRatesTable);
  FreeAndNil(FBalances_RecTable);
  FreeAndnil(FFuelSheetTable);
  FreeAndNil(FClient_ScheduleTable);
  //FreeAndNil(FClient_ReportOptionsTable);
  FreeAndNil(FClientFinacialReportOptionsTable);
  FreeAndNil(FCodingReportOptionsTable);
  FreeAndNil(FCustomDocSceduleTable);
  FreeAndNil(FChartDivisionTable);
  FreeAndNil(FReminderTable);
  FreeAndNil(FDownloadlogTable);
  FreeAndNil(FBAS_OptionsTable);
  FreeAndNil(FNotesOptionsTable);
  FreeAndNil(FMatchIDList);
  FreeAndNil(FExcludedFromScheduledReports);
  FreeAndNil(FReportParameterTable);
  FreeAndNil(FClientReportTable);
  FreeAndNil(FColumnConfigTable);
  FreeAndNil(FColumnConfigColumnsTable);
  inherited;
end;

function TClientMigrater.GetDivisionList: TGuidList;
begin
  if not Assigned(FDivisionList) then
      FDivisionList := TGuidList.Create();
   Result := FDivisionList
end;

function TClientMigrater.GetAccount_RecTable: TAccount_RecTable;
begin
   if not Assigned(FAccount_RecTable) then
      FAccount_RecTable := TAccount_RecTable.Create(Connection);
   Result := FAccount_RecTable;
end;

function TClientMigrater.GetBalances_RecTable: TBalances_RecTable;
begin
   if not Assigned(FBalances_RecTable) then
      FBalances_RecTable := TBalances_RecTable.Create(Connection);
   Result := FBalances_RecTable;
end;

function TClientMigrater.GetBalances_ParamTable: TBalances_ParamTable;
begin
   if not assigned( FBalances_ParamTable)
   and assigned(FCLient) then
      case FCLient.clFields.clCountry   of
      { TODO : Needs implementation for each country }
      whNewZealand : FBalances_ParamTable := TBalances_ParamTableNZ.Create(connection);
      whAustralia : FBalances_ParamTable := TBalances_ParamTableNZ.Create(connection);
      whUK : FBalances_ParamTable := TBalances_ParamTableNZ.Create(connection)
      end;

      
   result := FBalances_ParamTable;
end;

function TClientMigrater.GetBudget_Detail_RecTable: TBudget_Detail_RecTable;
begin
   if not Assigned(FBudget_Detail_RecTable) then
      FBudget_Detail_RecTable := TBudget_Detail_RecTable.Create(Connection);
   Result := FBudget_Detail_RecTable;
end;

function TClientMigrater.GetBudget_Header_RecTable: TBudget_Header_RecTable;
begin
   if not Assigned(FBudget_Header_RecTable) then
      FBudget_Header_RecTable := TBudget_Header_RecTable.Create(Connection);
   Result := FBudget_Header_RecTable;
end;

function TClientMigrater.GetChartDivisionTable: TChartDivisionTable;
begin
  if not Assigned(FChartDivisionTable) then
      FChartDivisionTable := TChartDivisionTable.Create(Connection);
   Result := FChartDivisionTable;
end;

function TClientMigrater.GetChart_RecTable: TChart_RecTable;
begin
   if not Assigned(FChart_RecTable) then
      FChart_RecTable := TChart_RecTable.Create(Connection);
   Result := FChart_RecTable;
end;

function TClientMigrater.GetClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable;
begin
   if not Assigned(FClientFinacialReportOptionsTable) then
      FClientFinacialReportOptionsTable := TClientFinacialReportOptionsTable.Create(Connection);
   Result := FClientFinacialReportOptionsTable;
end;

function TClientMigrater.GetClient_RecFieldsTable: TClient_RecFieldsTable;
begin
   if not Assigned(FClient_RecFieldsTable) then
      FClient_RecFieldsTable := TClient_RecFieldsTable.Create(Connection);
   Result := FClient_RecFieldsTable;
end;
    {
function TClientMigrater.GetClient_ReportOptionsTable: TClient_ReportOptionsTable;
begin
   if not Assigned(FClient_ReportOptionsTable) then
      FClient_ReportOptionsTable := TClient_ReportOptionsTable.Create(Connection);
   Result := FClient_ReportOptionsTable;
end;
}

function TClientMigrater.GetClient_ScheduleTable: TClient_ScheduleTable;
begin
  if not Assigned(FClient_ScheduleTable) then
      FClient_ScheduleTable := TClient_ScheduleTable.Create(Connection);
   Result := FClient_ScheduleTable;
end;

function TClientMigrater.GetCodingReportOptionsTable: TCodingReportOptionsTable;
begin
   if not Assigned(FCodingReportOptionsTable) then
      FCodingReportOptionsTable := TCodingReportOptionsTable.Create(Connection);
   Result := FCodingReportOptionsTable;
end;

function TClientMigrater.GetColumnConfigColumnsTable: TColumnConfigColumnsTable;
begin
   if not Assigned(FColumnConfigColumnsTable) then
      FColumnConfigColumnsTable := TColumnConfigColumnsTable.Create(Connection);
   Result := FColumnConfigColumnsTable;
end;

function TClientMigrater.GetColumnConfigTable: TColumnConfigTable;
begin
  if not Assigned(FColumnConfigTable) then
      FColumnConfigTable := TColumnConfigTable.Create(Connection);
   Result := FColumnConfigTable;
end;

function TClientMigrater.GetCustomDocSceduleTable: TCustomDocSceduleTable;
begin
   if not Assigned(FCustomDocSceduleTable) then
      FCustomDocSceduleTable := TCustomDocSceduleTable.Create(Connection);
   Result := FCustomDocSceduleTable;
end;

function TClientMigrater.GetCustom_Heading_RecTable: TCustom_Heading_RecTable;
begin
   if not Assigned(FCustom_Heading_RecTable) then
      FCustom_Heading_RecTable := TCustom_Heading_RecTable.Create(Connection);
   Result := FCustom_Heading_RecTable;
end;

function TClientMigrater.GetDissection_RecTable: TDissection_RecTable;
begin
   if not Assigned(FDissection_RecTable) then
      FDissection_RecTable := TDissection_RecTable.Create(Connection);
   Result := FDissection_RecTable;
end;

function TClientMigrater.GetDivisionsTable: TDivisionsTable;
begin
   if not Assigned(FDivisionsTable) then
      FDivisionsTable := TDivisionsTable.Create(Connection);
   Result := FDivisionsTable;
end;

function TClientMigrater.GetDownloadlogTable: TDownloadlogTable;
begin
   if not Assigned(FDownloadlogTable) then
      FDownloadlogTable := TDownloadlogTable.Create(Connection);
   Result := FDownloadlogTable;
end;

function TClientMigrater.GetFuelSheetTable: TFuelSheetTable;
begin
  if not Assigned(FFuelSheetTable) then
      FFuelSheetTable := TFuelSheetTable.Create(Connection);
   Result := FFuelSheetTable;
end;

function TClientMigrater.GetJob_Heading_RecTable: TJob_Heading_RecTable;
begin
   if not Assigned(FJob_Heading_RecTable) then
      FJob_Heading_RecTable := TJob_Heading_RecTable.Create(Connection);
   Result := FJob_Heading_RecTable;
end;

function TClientMigrater.GetMatchIDList: TGuidList;
begin

   if not assigned (FMatchIDList) then
       FMatchIDList := TGuidList.Create();
   result := FMatchIDList;
end;

function TClientMigrater.GetMemorisation_Detail_RecTable: TMemorisation_Detail_RecTable;
begin
   if not Assigned(FMemorisation_Detail_RecTable) then
      FMemorisation_Detail_RecTable := TMemorisation_Detail_RecTable.Create(Connection);
   Result := FMemorisation_Detail_RecTable;
end;

function TClientMigrater.GetMemorisation_Line_RecTable: TMemorisation_Line_RecTable;
begin
   if not Assigned(FMemorisation_Line_RecTable) then
      FMemorisation_Line_RecTable := TMemorisation_Line_RecTable.Create(Connection);
   Result := FMemorisation_Line_RecTable;
end;

function TClientMigrater.GetNotesOptionsTable: TNotesOptionsTable;
begin
   if not Assigned(FNotesOptionsTable) then
      FNotesOptionsTable := TNotesOptionsTable.Create(Connection);
   Result := FNotesOptionsTable;
end;

function TClientMigrater.GetPayee_Detail_RecTable: TPayee_Detail_RecTable;
begin
   if not Assigned(FPayee_Detail_RecTable) then
      FPayee_Detail_RecTable := TPayee_Detail_RecTable.Create(Connection);
   Result := FPayee_Detail_RecTable;
end;

function TClientMigrater.GetPayee_Line_RecTable: TPayee_Line_RecTable;
begin
   if not Assigned(FPayee_Line_RecTable) then
      FPayee_Line_RecTable := TPayee_Line_RecTable.Create(Connection);
   Result := FPayee_Line_RecTable;
end;

function TClientMigrater.GetReminderTable: TReminderTable;
begin
   if not Assigned(FReminderTable) then
      FReminderTable := TReminderTable.Create(Connection);
   Result := FReminderTable;
end;

function TClientMigrater.GetReportParameterTable: TReportParameterTable;
begin
  if not Assigned(FReportParameterTable) then
      FReportParameterTable := TReportParameterTable.Create(Connection);
   Result := FReportParameterTable;
end;

function TClientMigrater.GetClientReportTable: TClientReportTable;
begin
  if not Assigned(FClientReportTable) then
      FClientReportTable := TClientReportTable.Create(Connection);
   Result := FClientReportTable;
end;

function TClientMigrater.GetSubGroupTable: TSubGroupTable;
begin
   if not Assigned(FSubGroupTable) then
      FSubGroupTable := TSubGroupTable.Create(Connection);
   Result := FSubGroupTable;
end;

function TClientMigrater.GetTaxEntriesTable: TTaxEntriesTable;
begin
   if not Assigned(FTaxEntriesTable) then
      FTaxEntriesTable := TTaxEntriesTable.Create(Connection);
   Result := FTaxEntriesTable;
end;

function TClientMigrater.GetTaxRatesTable: TTaxRatesTable;
begin
   if not Assigned(FTaxRatesTable) then
      FTaxRatesTable := TTaxRatesTable.Create(Connection);
   Result := FTaxRatesTable;
end;

function TClientMigrater.GetTBAS_OptionsTable: TBAS_OptionsTable;
begin
   if not Assigned(FBAS_OptionsTable) then
      FBAS_OptionsTable := TBAS_OptionsTable.Create(Connection);
   Result := FBAS_OptionsTable;
end;

function TClientMigrater.GetTransaction_RecTable: TTransaction_RecTable;
begin
   if not Assigned(FTransaction_RecTable) then
      FTransaction_RecTable := TTransaction_RecTable.Create(Connection);
   Result := FTransaction_RecTable;
end;

{
function TClientMigrater.GetUpdateAccountStatus: TADOStoredProc;
begin
   if not assigned (FUpdateAccountStatus) then begin
      FUpdateAccountStatus := TADOStoredProc.Create(nil);

      FUpdateAccountStatus.Connection := connection;
      FUpdateAccountStatus.ProcedureName := 'UpdateProcessingStatusForAClient';
      FUpdateAccountStatus.Parameters.Refresh;


      FUpdateAccountStatus.Prepared := true;
      //FUpdateAccountStatus.Parameters.ParamByName('@PeriodEndDate').Value := null;
      //FUpdateAccountStatus.Parameters.ParamByName('@DurationInMonths').Value := null;
   end;
   result := FUpdateAccountStatus;
end;

function TClientMigrater.GetUpdateProcessingStatusForAllClients: TADOStoredProc;
begin
  if not assigned (FUpdateProcessingStatusForAllClients) then begin
      FUpdateProcessingStatusForAllClients := TADOStoredProc.Create(nil);

      FUpdateProcessingStatusForAllClients.Connection := connection;
      //FUpdateProcessingStatusForAllClients.ProcedureName := 'UpdateProcessingStatusForAllClients';
      FUpdateProcessingStatusForAllClients.ProcedureName := 'UpdateProcessingStatus';
      FUpdateProcessingStatusForAllClients.Parameters.Refresh;


      FUpdateProcessingStatusForAllClients.Prepared := true;
      FUpdateProcessingStatusForAllClients.CommandTimeout := 60 * 10;

   end;
   result := FUpdateProcessingStatusForAllClients;
end;
    }
function TClientMigrater.GetUser(const Value: string): TGuid;
begin
   fillChar(result,SizeOf(result),0);
   if not Assigned(SystemMirater) then
      Exit;
   if not (SystemMirater is TSystemMigrater) then
      Exit;

   Result := TSystemMigrater(SystemMirater).GetUser(Value);
end;

function TClientMigrater.Migrate(ForAction:TMigrateAction;
                    ACode: string;
                    AClientID,
                    AUserID,
                    AGroupID,
                    ATypeID: TGuid;
                    AMagicNumber,
                    ACountry: Integer;
                    CheckedOutUserID: TGuid;
                    AClient: pClient_File_Rec = nil): Boolean;


var
   MyAction: TMigrateAction;
   GuidList: TGuidList;
   LID: TGuid;
   I: Integer;

   procedure AddScheduledCustomDoc(Doc: TReportBase);
   begin
      if not Assigned(Doc) then
         Exit;
      CustomDocSceduleTable.Insert(NewGuid, LID, Doc.GetGUID);
   end;

   function Acrchived: Boolean;
   begin
       if Assigned(AClient) then
          result := AClient.cfArchived
       else
          result := false;
   end;

   procedure AddReporting;
   var ClientReportID: TGuid;
       i: Integer;
       CustomDoc: TReportBase;
       SeqNo: Integer;

       procedure CheckClient (Value : TReportClient);
           function NextSeq: Integer;
           begin
              inc(SeqNo);
              result := SeqNo;
           end;

           procedure addFavouriteReport (Value: TReportBase);
                   (*
           procedure AddSettings(Value: IXMLNode);
           var nxn: IXMLNode;
               LList: IXMLNodeList;
               I: Integer;
               S: string;
           begin //AddSettings
              if not Assigned(Value) then
                 Exit;

              if Sametext(Value.NodeName,ReportGUID)
              or SameText(Value.NodeName,'_Report_Column')  then
                  Exit; // Not usefull


              if Sametext(Value.NodeName,'Accounts') then begin
                  LList := FilterNodes(Value,'Account');
                  S := '';
                  if Assigned(LList) then
                     for I := 0 to pred(LList.Length) do
                        S:= S + GetNodeTextStr(LList.Item[I],'_Number','') +',';
                  I := Length(S);
                  if I > 1 then begin
                     SetLength(S,Pred(I));
                     ReportParameterTable.Update('Accounts',S,'Favoutire',ClientReportID);
                  end;

                  Exit;
              end;

              if Sametext(Value.NodeName,'Codes') then begin
                 LList := FilterNodes(Value,'Code');
                  S := '';
                  if Assigned(LList) then
                     for I := 0 to pred(LList.Length) do
                        S:= S + GetNodeTextStr(LList.Item[I],'_Number','') +',';
                  I := Length(S);
                  if I > 1 then begin
                     SetLength(S,Pred(I));
                     ReportParameterTable.Update('Codes',S,'Favoutire',ClientReportID);
                  end;

                  Exit;
              end;

              nxn := Value.FirstChild;
              while assigned(nxn) do begin
                 if (nxn.NodeType in [TEXT_NODE])
                 and (Length(nxn.ParentNode.NodeName) > 0)then begin
                   ReportParameterTable.Update(
                      Replacetext(nxn.ParentNode.NodeName,'_',''),
                      Replacetext(Replacetext(nxn.NodeValue,'_',''),' ',''),
                      'Favoutire',ClientReportID);
                 end;
                 AddSettings (nxn);
                 nxn := nxn.NextSibling;
              end;
           end; //AddSettings
               *)
           begin //addFavouriteReport
              ClientReportID := NewGuid;
              ClientReportTable.InsertReport(ClientReportID, ClientID, Value, NextSeq);
              ReportParameterTable.Update('Settings',Value.Settings.XML,'String',ClientReportID);
              //AddSettings(Value.Settings);
           end;
       var i : integer;
       begin //CheckClient
          SeqNo := 0;
          for i  := 0 to Value.List.Count - 1 do
             addFavouriteReport(Value.Child[i]);

       end;

       {DEBUG}
       procedure SaveXML(value: string);
       var f: text;
       begin
          assignFile(F,format('C:\temp\%s.xml', [FCLient.clFields.clCode] ));
          rewrite(F);
          WriteLn(F,Value);
          CloseFile(F);
       end;
       {}
   begin
      // Client report settings..
      ClientReportID := NewGuid;
      ClientReportTable.InsertClient(ClientReportID, ClientID);
      ReportParameterTable.AddClient(NewGuid,ClientReportID,@FClient.clFields, @FCLient.clExtra);

      // Favourites ...
      //SaveXML(FClient.clFields.clFavourite_Report_XML);
      BatchReports.XMLString := FClient.clFields.clFavourite_Report_XML;
      // Now run trough the list..
      for I := 0 to pred(BatchReports.List.Count) do
         CheckClient( TReportClient(BatchReports.Child[I]));

   end;


begin
   Result := False;
   Reset;
   // set some global bits
   Code := ACode;
   ClientID := AClientID;
   GuidList := nil;
   MyAction := ForAction.InsertAction(Code);
   MyAction.LogMessage('TClientMigrater.Migrate Start');
   logger.LogMessage(Info,format('Start Client : %s',[Code]),Code );

   try try
      if Assigned(AClient) then begin
         ClientLRN := AClient.cfLRN;
         if AClient.cfClient_Type = ctProspect then begin
            if ClientDetailsCache.Load(ClientLRN) then
                Client_RecFieldsTable.InsertProspect
                    (
                      ClientID,
                      AUserID,
                      AGroupID,
                      ATypeID,
                      Acrchived,
                      AMagicNumber,
                      ACountry,
                      GetNotesForClient(ClientLRN),
                      ClientDetailsCache,
                      AClient
                    );

            Exit;
         end;
      end else
         ClientLRN := 0;

      files.OpenAClientForRead(Code, FClient);
      if not Assigned(FClient) then
         raise exception.Create('Could not open File');


      if FClient.clFields.clExclude_From_Scheduled_Reports > '' then begin
         if  not assigned(FExcludedFromScheduledReports) then begin
            FExcludedFromScheduledReports := TStringList.Create;
            FExcludedFromScheduledReports.StrictDelimiter := true;
            FExcludedFromScheduledReports.Delimiter := ','
         end;
         FExcludedFromScheduledReports.DelimitedText := FClient.clFields.clExclude_From_Scheduled_Reports;
      end else
         FreeAndNil(FExcludedFromScheduledReports);


      DoSuperFund := Software.IsSuperFund(FClient.clFields.clCountry, FClient.clFields.clAccounting_System_Used);

      try
      // Add The Client File record
      Client_RecFieldsTable.Insert
                    ( ClientID,
                      AUserID,
                      GetProviderID(AccountingSystem, FClient.clFields.clCountry, FClient.clFields.clAccounting_System_Used ),
                      GetProviderID(TaxSystem, FClient.clFields.clCountry, FClient.clFields.clTax_Interface_Used ),
                      AGroupID,
                      ATypeID,
                      GetProviderID(WebExport, FClient.clFields.clCountry, FClient.clFields.clWeb_Export_Format ),
                      Acrchived,
                      GetNotesForClient(ClientLRN),
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra ,
                      AClient,
                      CheckedOutUserID
                    );


      except
        on E: Exception do MyAction.AddError(E);
      end;


      try
         LID := NewGuid;
         Client_ScheduleTable.Insert
                    ( LID,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra
                    );
          for I := low(FClient.clExtra.ceSend_Custom_Documents_List) to High(FClient.clExtra.ceSend_Custom_Documents_List) do
             if FClient.clExtra.ceSend_Custom_Documents_List[I] > '' then begin
                AddScheduledCustomDoc( CustomDocManager.GetReportByGUID(FClient.clExtra.ceSend_Custom_Documents_List[I]));
                if MyAction.CheckCanceled then
                   Exit;
             end;


      except
        on E: Exception do MyAction.AddError(E);
      end;


      AddReporting;

      //ReportingParameterTable.Update('GstReport_IncludeFuelTaxCalculationSheet',FClient.clFields.clBAS_Include_Fuel, ClientID );

        {
      try
         Client_ReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);

      except
        on E: Exception do MyAction.AddWarining(E);
      end;
      }
      if MyAction.CheckCanceled then
         Exit;

      try
         ClientFinacialReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);

      except
        on E: Exception do MyAction.AddError(E);
      end;
      if MyAction.CheckCanceled then
         Exit;

      try
         CodingReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);

      except
         on E: Exception do MyAction.AddError(E);
      end;
      if MyAction.CheckCanceled then
         Exit;

      try
         if Assigned(AClient) then
            I := AClient.cfWebNotes_Email_Notifications
         else
            I := 0;

         NotesOptionsTable.Insert(NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clExtra,
                      I);

      except
         on E: Exception do MyAction.AddError(E);
      end;
      if MyAction.CheckCanceled then
         Exit;

      if FClient.clFields.clCountry = whAustralia then begin
         try
              BAS_OptionsTable.Insert(NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields);
         except
            on E: Exception do MyAction.AddError(E);
         end;
         if MyAction.CheckCanceled then
            Exit;
      end;


      GuidList := TGuidList.Create(FClient.clBank_Account_List);
      if not RunGuidList(MyAction,'Bank Accounts',GuidList,AddAccount) then
         Exit;

      AddDivisions(MyAction);
      if MyAction.CheckCanceled then
         Exit;

      AddSubGroups(MyAction);
      if MyAction.CheckCanceled then
         Exit;

      if not RunGuidList(MyAction,'Chart',GuidList.CloneList(FClient.clChart),AddChart) then
         Exit;

      if not RunGuidList(MyAction,'Budgets',GuidList.CloneList(FClient.clBudget_List),AddBudget) then
         Exit;

      if not RunGuidList(MyAction,'Jobs',GuidList.CloneList(FClient.clJobs),AddJob) then
         Exit;

      if not RunGuidList(MyAction,'Payees',GuidList.CloneList(FClient.clPayee_List),AddPayee) then
         Exit;

      if not RunGuidList(MyAction,'Headings',GuidList.CloneList(FClient.clCustom_Headings_List ),AddHeading) then
         Exit;

      AddGStRates(MyAction);
      if MyAction.CheckCanceled then
         Exit;

      if not  RunGuidList(MyAction,'Balances',GuidList.CloneList(FClient.clBalances_List ),AddBalance) then
         Exit;

      AddReminders(MyAction);
      if MyAction.CheckCanceled then
         Exit;

      MigrateDiskLog(MyAction);
      if MyAction.CheckCanceled then
         Exit;

      MyAction.Status := Success;
      Result := true;
   except
      on E: Exception do begin
         MyAction.Error := E.Message;
      end;
   end;
   finally
      FreeAndNil(FClient);
      FreeAndNil(GuidList);
      logger.LogMessage(Info,format('Completed Client : %s',[Code]),Code );
   end;
end;


procedure TClientMigrater.Reset;
begin
   FClient := nil;
   DoSuperfund := False;
   DissectionCount := 0;
end;



procedure TClientMigrater.SetClientID(const Value: TGuid);
begin
  FClientID := Value;
  if assigned(FBalances_ParamTable) then
     FreeAndNil(FBalances_ParamTable);
end;

procedure TClientMigrater.SetClientLRN(const Value: Integer);
begin
  FClientLRN := Value;
end;

procedure TClientMigrater.SetCode(const Value: string);
begin
  FCode := Value;
end;

procedure TClientMigrater.SetDivisionList(const Value: TGuidList);
begin
  FDivisionList := Value;
end;

procedure TClientMigrater.SetDoSuperfund(const Value: Boolean);
begin
   if FDoSuperfund = Value then
      Exit;
   FDoSuperfund := Value;

   Client_RecFieldsTable.DoSuperfund := FDoSuperfund;
   Budget_Detail_RecTable.DoSuperfund := FDoSuperfund;
   Chart_RecTable.DoSuperfund := FDoSuperfund;
   Budget_Header_RecTable.DoSuperfund := FDoSuperfund;
   Memorisation_Line_RecTable.DoSuperfund := FDoSuperfund;
   Payee_Detail_RecTable.DoSuperfund := FDoSuperfund;
   Custom_Heading_RecTable.DoSuperfund := FDoSuperfund;
   Transaction_RecTable.DoSuperfund := FDoSuperfund;
   Job_Heading_RecTable.DoSuperfund := FDoSuperfund;
   Dissection_RecTable.DoSuperfund := FDoSuperfund;
   Memorisation_Detail_RecTable.DoSuperfund := FDoSuperfund;
   Account_RecTable.DoSuperfund := FDoSuperfund;
   Payee_Line_RecTable.DoSuperfund := FDoSuperfund;
   DivisionsTable.DoSuperfund := FDoSuperfund;
   TaxEntriesTable.DoSuperfund := FDoSuperfund;
   TaxRatesTable.DoSuperfund := FDoSuperfund;
   Client_ScheduleTable.DoSuperfund := FDoSuperfund;
   SubGroupTable.DoSuperfund := FDoSuperfund;
   //Client_ReportOptionsTable.DoSuperfund := FDoSuperfund;
   ClientFinacialReportOptionsTable.DoSuperfund := FDoSuperfund;
   CodingReportOptionsTable.DoSuperfund := FDoSuperfund;

end;



procedure TClientMigrater.SetMemList(const Value: TGuidList);
begin
  FreeAndNil(FMemList);
  FMemList := Value;
end;

procedure TClientMigrater.SetSystemMirater(const Value: TMigrater);
begin
  FSystemMirater := Value;
end;

 {
procedure TClientMigrater.UpdateClientsStatus(ForAction: TMigrateAction);

var MyAction : TMigrateAction;
begin
   MyAction := ForAction.InsertAction ('Update Client status');
   try
      UpdateAccountStatus.Parameters.ParamByName('@CLIENTID').Value := TMigrateTable.toSQL(ClientID);

      UpdateAccountStatus.ExecProc;
      MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
end;

procedure TClientMigrater.UpdateProcessingStatusAllClients(
  ForAction: TMigrateAction);
var
   MyAction : TMigrateAction;

begin
   MyAction := ForAction.InsertAction ('Update all Clients status');
   try
      UpdateProcessingStatusForAllClients.ExecProc;
      MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
end;
   }
end.
