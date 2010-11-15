unit ClientMigrater;



interface

uses
   bkTables,
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
    FClient_ReportOptionsTable: TClient_ReportOptionsTable;
    FClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable;
    FCodingReportOptionsTable: TCodingReportOptionsTable;
    FSystemMirater: TMigrater;
    FClientLRN: Integer;
    procedure SetClientID(const Value: TGuid);
    procedure SetCode(const Value: string);

    procedure AddGStRates(ForAction: TMigrateAction);
    procedure AddDivisions(ForAction: TMigrateAction);
    procedure AddSubGroups(ForAction: TMigrateAction);
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


    procedure Reset;
    procedure SetAccount_RecTable(const Value: TAccount_RecTable);
    procedure SetBudget_Detail_RecTable(const Value: TBudget_Detail_RecTable);
    procedure SetBudget_Header_RecTable(const Value: TBudget_Header_RecTable);
    procedure SetChart_RecTable(const Value: TChart_RecTable);
    procedure SetClient_RecFieldsTable(const Value: TClient_RecFieldsTable);
    procedure SetCustom_Heading_RecTable(const Value: TCustom_Heading_RecTable);
    procedure SetDissection_RecTable(const Value: TDissection_RecTable);
    procedure SetJob_Heading_RecTable(const Value: TJob_Heading_RecTable);
    procedure SetMemorisation_Detail_RecTable(const Value: TMemorisation_Detail_RecTable);
    procedure SetMemorisation_Line_RecTable(const Value: TMemorisation_Line_RecTable);
    procedure SetPayee_Detail_RecTable(const Value: TPayee_Detail_RecTable);
    procedure SetPayee_Line_RecTable(const Value: TPayee_Line_RecTable);
    procedure SetTransaction_RecTable(const Value: TTransaction_RecTable);
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
    procedure SetDivisionsTable(const Value: TDivisionsTable);
    function GetDivisionsTable: TDivisionsTable;
    procedure SetTaxEntriesTable(const Value: TTaxEntriesTable);
    function GetTaxEntriesTable: TTaxEntriesTable;
    procedure SetTaxRatesTable(const Value: TTaxRatesTable);
    function GetTaxRatesTable: TTaxRatesTable;
    procedure SetClient_ScheduleTable(const Value: TClient_ScheduleTable);
    function GetClient_ScheduleTable: TClient_ScheduleTable;
    procedure SetSubGroupTable(const Value: TSubGroupTable);
    function GetSubGroupTable: TSubGroupTable;
    procedure SetClient_ReportOptionsTable(
      const Value: TClient_ReportOptionsTable);
    function GetClient_ReportOptionsTable: TClient_ReportOptionsTable;
    procedure SetClientFinacialReportOptionsTable(
      const Value: TClientFinacialReportOptionsTable);
    function GetClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable;
    procedure SetCodingReportOptionsTable(
      const Value: TCodingReportOptionsTable);
    function GetCodingReportOptionsTable: TCodingReportOptionsTable;
    procedure SetDoSuperfund(const Value: Boolean);
    procedure SetSystemMirater(const Value: TMigrater);
    procedure SetClientLRN(const Value: Integer);
  published
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
                    AClientLRN: Integer): Boolean;



   property Client_RecFieldsTable: TClient_RecFieldsTable read GetClient_RecFieldsTable write SetClient_RecFieldsTable;
   property Account_RecTable: TAccount_RecTable read GetAccount_RecTable write SetAccount_RecTable;
   property Transaction_RecTable: TTransaction_RecTable read GetTransaction_RecTable write SetTransaction_RecTable;
   property Dissection_RecTable: TDissection_RecTable read GetDissection_RecTable write SetDissection_RecTable;
   property Memorisation_Detail_RecTable: TMemorisation_Detail_RecTable read GetMemorisation_Detail_RecTable write SetMemorisation_Detail_RecTable;
   property Memorisation_Line_RecTable: TMemorisation_Line_RecTable read GetMemorisation_Line_RecTable write SetMemorisation_Line_RecTable;
   property Chart_RecTable: TChart_RecTable read GetChart_RecTable write SetChart_RecTable;
   property Custom_Heading_RecTable: TCustom_Heading_RecTable read GetCustom_Heading_RecTable write SetCustom_Heading_RecTable;
   property Payee_Detail_RecTable: TPayee_Detail_RecTable read GetPayee_Detail_RecTable write SetPayee_Detail_RecTable;
   property Payee_Line_RecTable: TPayee_Line_RecTable read GetPayee_Line_RecTable write SetPayee_Line_RecTable;
   property Job_Heading_RecTable: TJob_Heading_RecTable read GetJob_Heading_RecTable write SetJob_Heading_RecTable;
   property Budget_Header_RecTable: TBudget_Header_RecTable read GetBudget_Header_RecTable write SetBudget_Header_RecTable;
   property Budget_Detail_RecTable: TBudget_Detail_RecTable read GetBudget_Detail_RecTable write SetBudget_Detail_RecTable;
   property DivisionsTable: TDivisionsTable read GetDivisionsTable write SetDivisionsTable;
   property SubGroupTable: TSubGroupTable read GetSubGroupTable write SetSubGroupTable;
   property TaxEntriesTable: TTaxEntriesTable read GetTaxEntriesTable write SetTaxEntriesTable;
   property TaxRatesTable: TTaxRatesTable read GetTaxRatesTable write SetTaxRatesTable;
   property Client_ScheduleTable: TClient_ScheduleTable read GetClient_ScheduleTable write SetClient_ScheduleTable;
   property Client_ReportOptionsTable: TClient_ReportOptionsTable read GetClient_ReportOptionsTable write SetClient_ReportOptionsTable;
   property ClientFinacialReportOptionsTable: TClientFinacialReportOptionsTable read GetClientFinacialReportOptionsTable write SetClientFinacialReportOptionsTable;
   property CodingReportOptionsTable: TCodingReportOptionsTable read GetCodingReportOptionsTable write SetCodingReportOptionsTable;

   property DoSuperfund: Boolean read FDoSuperfund write SetDoSuperfund;
   property Code: string read FCode write SetCode;
   property ClientID: TGuid read FClientID write SetClientID;
   property ClientLRN: Integer read FClientLRN write SetClientLRN;

   property SystemMirater:TMigrater read FSystemMirater write SetSystemMirater;
end;


implementation
uses
   syDefs,
   SystemMigrater,
   BUDOBJ32,
   PayeeObj,
   MemorisationsObj,
   bkDefs,
   glConst,
   baObj32,
   Software,
   files,

   Sysutils;

{ TClientMigrater }

function TClientMigrater.Addaccount(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
   MyAction: TMigrateAction;
   Account: tBank_Account;
   GuidList: TGuidList;
   AdminBankAccount: TGuidObject;// pSystem_Bank_Account_Rec;
   Map: TGuidObject; //pClient_Account_Map_Rec;


   procedure AddClientAccountMap;
   var System: TSystemMigrater;

       function GetSystemAccount: TGuidObject;
       var I: Integer;
       begin
          fillchar(Result, Sizeof(Result), 0);
          for I := 0 to System.SystemAccountList.Count - 1 do
             with pSystem_Bank_Account_Rec(TGuidObject(System.SystemAccountList[I]).Data)^ do
                if SameText(sbAccount_Number,Account.baFields.baBank_Account_Number) then begin
                   Result := TGuidObject(System.SystemAccountList[I]);
                   Exit;
                end;
       end;

       function GetClientMap: TGuidObject;
       var I: Integer;
       begin
          fillchar(Result, Sizeof(Result), 0);
          for I := 0 to System.ClientAccountMap.Count - 1 do
             with pClient_Account_Map_Rec(TGuidObject(System.ClientAccountMap[I]).Data)^ do
                if  (amClient_LRN = ClientLRN)
                and (amAccount_LRN = pSystem_Bank_Account_Rec(AdminBankAccount.Data).sbLRN) then begin
                   Result := TGuidObject(System.ClientAccountMap[I]);
                   Exit;
                end;
       end;
   begin
      if not Assigned(SystemMirater) then
         Exit;
      System := SystemMirater as TSystemMigrater;
      AdminBankAccount := GetSystemAccount;
      if not Assigned(AdminBankAccount) then
         Exit;
      Map := getClientMap;
      if not Assigned(Map) then
         Exit;
      // Now we can have a go...
      System.ClientAccountMapTable.Insert(Map.GuidID,ClientID,Value.GuidID,AdminBankAccount.GuidID,pClient_Account_Map_Rec(Map.Data));
   end;

begin
   Result := False;
   Account := tBank_Account(Value.Data);
   GuidList := nil;
   MyAction := ForAction.InsertAction (Format('Insert Account %s',[Account.Title]),Value);
   try try
      Account_RecTable.Insert
          (
             Value.GuidID,
             ClientID,
             @Account.baFields
          );

       GuidList := TGuidList.Create(Account.baTransaction_List);
       RunGuidList(MyAction,'Transactions',GuidList,AddTransaction);

       GuidList.CloneList(Account.baMemorisations_List);
       RunGuidList(MyAction,'Memorizations',GuidList,AddMemorisation);

       MyAction.Status := Success;
       AddClientAccountMap;
       Result := True;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
   finally
      FreeAndNil(GuidList);
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
   Result = false; 
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
begin
   Result := Chart_recTable.Insert(Value.GuidID,ClientID, pAccount_Rec(Value.Data));
end;

procedure TClientMigrater.AddDivisions(ForAction: TMigrateAction);
var I,C: Integer;
    DivisionName: string;
begin
     C := 0;
     for i := 1 to Max_Divisions do begin
        DivisionName := Trim(FClient.clCustom_Headings_List.Get_Division_Heading(i));
        if DivisionName > '' then begin

           if DivisionsTable.Insert(NewGuid,ClientID, i,DivisionName ) then
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
   for ClassNo := 1 to MAX_GST_CLASS do begin
      if FClient.clFields.clGST_Class_Names[ClassNo] = '' then
        Continue; // nothing to save...
      if FClient.clFields.clGST_Class_Codes[ClassNo] = '' then
        Continue;

      ClassID := GetTaxClassGuid(FClient.clFields.clCountry, FClient.clFields.clGST_Class_Types[ClassNo]);
      if IsEqualGUID(ClassID,emptyGuid) then
        Continue; // Not A Valid Tax Entry..

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
         if (FClient.clFields.clGST_Applies_From[Rate]) = 0 then
            Continue;
         if FClient.clFields.clGST_Rates[ClassNo][Rate] = 0 then
            Continue;

         TaxRatesTable.Insert
             (
                NewGuid,
                EntryId,
                FClient.clFields.clGST_Rates[ClassNo][Rate],
                FClient.clFields.clGST_Applies_From[Rate]
             );
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
   Result := Memorisation_Detail_RecTable.Insert
                (
                   Value.GuidID,
                   ForAction.Item.GuidID,
                   GetProviderID(AccountingSystem,FClient.clFields.clCountry,
                              Memorization.mdFields.mdAccounting_System),
                   @Memorization.mdFields
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

procedure TClientMigrater.AddSubGroups(ForAction: TMigrateAction);
var I,C: Integer;
    SubGroupName: string;
begin
     C := 0;
     for i := 1 to Max_SubGroups do begin
        SubGroupName := Trim(FClient.clCustom_Headings_List.Get_SubGroup_Heading(i));
        if SubGroupName > '' then begin
           if SubGroupTable.Insert(NewGuid,ClientID, i, SubGroupName) then
              inc(C);
        end;
     end;
     if C > 0 then
        ForAction.InsertAction('Subgroups').Count := C;
end;


function TClientMigrater.AddTransaction(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;

var
   Diss: PDissection_Rec;
   Transaction: PTransaction_Rec;
begin
   Transaction := PTransaction_Rec(Value.Data);
   Transaction_RecTable.Insert
                       (
                            Value.GuidID,
                            ForAction.Item.GuidID,
                            Transaction
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
begin
   Result := false;
   MyAction := ForAction.NewAction('Clear Clients');
   try
      Connected := true;
      DeleteTable(MyAction,'Jobs', True);

      DeleteTable(MyAction,'FuelSheets', True);
      DeleteTable(MyAction,'Balances');

      DeleteTable(MyAction,'Charts', True);

      DeleteTable(MyAction,'NotesOptions');
      DeleteTable(MyAction,'Headings');

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

      KeepTime := Connection.CommandTimeout;
      Connection.CommandTimeout := 10 * 60;
      DeleteTable(MyAction,'Transactions');
      connection.CommandTimeout := KeepTime;

      DeleteTable(MyAction,'BankAccounts');
      DeleteTable(MyAction,'CodingReportOptions');
      DeleteTable(MyAction,'ReportingOptions');
      DeleteTable(MyAction,'ReportSubGroups');

      DeleteTable(MyAction,'ReportClientDivisions');

      DeleteTable(MyAction,'Clients');

      Result := True;
      MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;

end;

constructor TClientMigrater.Create(AConnection: string);
begin
   inherited Create;
   Connection.DefaultDatabase := 'PracticeClient';
   //ConnectionString := AConnection;
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
  FreeAndnil(FTaxEntriesTable);
  FreeAndNil(FTaxRatesTable);
  FreeAndNil(FClient_ScheduleTable);
  FreeAndNil(FClient_ReportOptionsTable);
  FreeAndNil(FClientFinacialReportOptionsTable);
  FreeAndNil(FCodingReportOptionsTable);
  inherited;
end;

function TClientMigrater.GetAccount_RecTable: TAccount_RecTable;
begin
   if not Assigned(FAccount_RecTable) then
      FAccount_RecTable := TAccount_RecTable.Create(Connection);
   Result := FAccount_RecTable;
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

function TClientMigrater.GetClient_ReportOptionsTable: TClient_ReportOptionsTable;
begin
   if not Assigned(FClient_ReportOptionsTable) then
      FClient_ReportOptionsTable := TClient_ReportOptionsTable.Create(Connection);
   Result := FClient_ReportOptionsTable;
end;

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

function TClientMigrater.GetJob_Heading_RecTable: TJob_Heading_RecTable;
begin
   if not Assigned(FJob_Heading_RecTable) then
      FJob_Heading_RecTable := TJob_Heading_RecTable.Create(Connection);
   Result := FJob_Heading_RecTable;
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

function TClientMigrater.GetTransaction_RecTable: TTransaction_RecTable;
begin
   if not Assigned(FTransaction_RecTable) then
      FTransaction_RecTable := TTransaction_RecTable.Create(Connection);
   Result := FTransaction_RecTable;
end;

function TClientMigrater.Migrate(ForAction:TMigrateAction;
                    ACode: string;
                    AClientID,
                    AUserID,
                    AGroupID,
                    ATypeID: TGuid;
                    AClientLRN: Integer): Boolean;
var
   MyAction: TMigrateAction;
   GuidList: TGuidList;
begin
   Result := False;

   FClient := nil;
   Code := ACode;
   ClientID := AClientID;
   ClientLRN := AClientLRN;

   GuidList := nil;
   MyAction := ForAction.InsertAction(format('Client: %s',[Code]));

   try try
      files.OpenAClientForRead(Code, FClient);
      if not Assigned(FClient) then
         raise exception.Create('Could not open File');

      DoSuperFund :=
                Software.IsSuperFund(FClient.clFields.clCountry,FClient.clFields.clAccounting_System_Used);
        // Add The Client File record
      Client_RecFieldsTable.Insert
                    ( ClientID,
                      AUserID,
                      GetProviderID(AccountingSystem,FClient.clFields.clCountry, FClient.clFields.clAccounting_System_Used ),
                      GetProviderID(TaxSystem,FClient.clFields.clCountry, FClient.clFields.clTax_Interface_Used ),
                      AGroupID,
                      ATypeID,
                      EmptyGuid, //WebExport format
                      False,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra
                    );



      Client_ScheduleTable.Insert
                    ( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra
                    );

      Client_ReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);

      ClientFinacialReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);

      CodingReportOptionsTable.Insert( NewGuid,
                      ClientID,
                      @FClient.clFields,
                      @FClient.clMoreFields,
                      @FClient.clExtra);


      GuidList := TGuidList.Create(FClient.clBank_Account_List);
      RunGuidList(MyAction,'Bank Accounts',GuidList,AddAccount);

      RunGuidList(MyAction,'Chart',GuidList.CloneList(FClient.clChart),AddChart);

      RunGuidList(MyAction,'Budgets',GuidList.CloneList(FClient.clBudget_List),AddBudget);

      RunGuidList(MyAction,'Jobs',GuidList.CloneList(FClient.clJobs),AddJob);

      RunGuidList(MyAction,'Payees',GuidList.CloneList(FClient.clPayee_List),AddPayee);

      RunGuidList(MyAction,'Headings',GuidList.CloneList(FClient.clCustom_Headings_List ),AddHeading);

      AddGStRates(MyAction);

      AddDivisions(MyAction);
      AddSubGroups(MyAction);

      MyAction.Status := Success;
      Result := true;
   except
      on E: Exception do begin
         MyAction.Error := E.Message;
         ForAction.Status := Warning;
      end;
   end;
   finally
      FreeAndNil(FClient);
      FreeAndNil(GuidList);
   end;
end;

procedure TClientMigrater.Reset;
begin
   DoSuperfund := False;
   DissectionCount := 0;
end;

procedure TClientMigrater.SetAccount_RecTable(const Value: TAccount_RecTable);
begin
  FAccount_RecTable := Value;
end;

procedure TClientMigrater.SetBudget_Detail_RecTable(
  const Value: TBudget_Detail_RecTable);
begin
  FBudget_Detail_RecTable := Value;
end;

procedure TClientMigrater.SetBudget_Header_RecTable(
  const Value: TBudget_Header_RecTable);
begin
  FBudget_Header_RecTable := Value;
end;

procedure TClientMigrater.SetChart_RecTable(const Value: TChart_RecTable);
begin
  FChart_RecTable := Value;
end;

procedure TClientMigrater.SetClientFinacialReportOptionsTable(
  const Value: TClientFinacialReportOptionsTable);
begin
  FClientFinacialReportOptionsTable := Value;
end;

procedure TClientMigrater.SetClientID(const Value: TGuid);
begin
  FClientID := Value;
end;

procedure TClientMigrater.SetClientLRN(const Value: Integer);
begin
  FClientLRN := Value;
end;

procedure TClientMigrater.SetClient_RecFieldsTable(
  const Value: TClient_RecFieldsTable);
begin
  FClient_RecFieldsTable := Value;
end;

procedure TClientMigrater.SetClient_ReportOptionsTable(
  const Value: TClient_ReportOptionsTable);
begin
  FClient_ReportOptionsTable := Value;
end;

procedure TClientMigrater.SetClient_ScheduleTable(
  const Value: TClient_ScheduleTable);
begin
  FClient_ScheduleTable := Value;
end;

procedure TClientMigrater.SetCode(const Value: string);
begin
  FCode := Value;
end;
procedure TClientMigrater.SetCodingReportOptionsTable(
  const Value: TCodingReportOptionsTable);
begin
  FCodingReportOptionsTable := Value;
end;

procedure TClientMigrater.SetCustom_Heading_RecTable(
  const Value: TCustom_Heading_RecTable);
begin
  FCustom_Heading_RecTable := Value;
end;

procedure TClientMigrater.SetDissection_RecTable(
  const Value: TDissection_RecTable);
begin
  FDissection_RecTable := Value;
end;

procedure TClientMigrater.SetDivisionsTable(const Value: TDivisionsTable);
begin
  FDivisionsTable := Value;
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
   Client_ReportOptionsTable.DoSuperfund := FDoSuperfund;
   ClientFinacialReportOptionsTable.DoSuperfund := FDoSuperfund;
   CodingReportOptionsTable.DoSuperfund := FDoSuperfund;

end;

procedure TClientMigrater.SetJob_Heading_RecTable(
  const Value: TJob_Heading_RecTable);
begin
  FJob_Heading_RecTable := Value;
end;

procedure TClientMigrater.SetMemorisation_Detail_RecTable(
  const Value: TMemorisation_Detail_RecTable);
begin
  FMemorisation_Detail_RecTable := Value;
end;

procedure TClientMigrater.SetMemorisation_Line_RecTable(
  const Value: TMemorisation_Line_RecTable);
begin
  FMemorisation_Line_RecTable := Value;
end;

procedure TClientMigrater.SetPayee_Detail_RecTable(
  const Value: TPayee_Detail_RecTable);
begin
  FPayee_Detail_RecTable := Value;
end;

procedure TClientMigrater.SetPayee_Line_RecTable(
  const Value: TPayee_Line_RecTable);
begin
  FPayee_Line_RecTable := Value;
end;

procedure TClientMigrater.SetSubGroupTable(const Value: TSubGroupTable);
begin
  FSubGroupTable := Value;
end;

procedure TClientMigrater.SetSystemMirater(const Value: TMigrater);
begin
  FSystemMirater := Value;
end;

procedure TClientMigrater.SetTaxEntriesTable(const Value: TTaxEntriesTable);
begin
  FTaxEntriesTable := Value;
end;

procedure TClientMigrater.SetTaxRatesTable(const Value: TTaxRatesTable);
begin
  FTaxRatesTable := Value;
end;

procedure TClientMigrater.SetTransaction_RecTable(
  const Value: TTransaction_RecTable);
begin
  FTransaction_RecTable := Value;
end;

{
procedure TClientMigrater.SetForAction(const Value: TMigrateAction);
begin
  FForAction := Value;
end;
}
end.
