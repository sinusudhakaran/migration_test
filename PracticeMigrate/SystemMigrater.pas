unit SystemMigrater;

interface

uses
   Classes,
   UBatchBase,
   DB,
   SysObj32,
   Sydefs,
   ADODB,
   sqlHelpers,
   Guidlist,
   btTables,
   syTables,
   Migraters,
   Archutil32,
   MigrateActions;

type

TSystemMigrater = class (TMigrater)
private
    FClientTypeList,
    FClientGroupList,
    FUserList,
    FSystemAccountList,
    FClientList: TGuidList;
    FSystemUsers: TADODataSet;
    FSystem: TSystemObj;
    FbtTable: TbtTable;
    FSystemAccountTable: TSystemBankAccountTable;
    FClientAccountMapTable: TClientAccountMapTable;
    FSystemClientFileTable: TSystemClientFileTable;
    FClientTypeTable: TClientTypeTable;
    FUserTable: TUserTable;
    FGroupTable: TClientGroupTable;
    FClientMigrater: TMigrater;
    FDoUsers: Boolean;
    FDoArchived: Boolean;
    FDoUnsynchronised: Boolean;
    FUserMappingTable: TUserMappingTable;
    FClientAccountMap: tGuidList;
    FMasterMemorisationsTable: TMasterMemorisationsTable;
    FMasterMemlinesTable: TMasterMemlinesTable;
    FChargesTable: TChargesTable;
    FDoSystemTransactions: Boolean;
    FDownloadDocumentTable: TDownloadDocumentTable;
    FDownloadlogTable: TDownloadlogTable;
    FParameterTable: TParameterTable;
    FTaxEntriesTable: TTaxEntriesTable;
    FTaxRatesTable: TTaxRatesTable;
    function GetClientGroupList: TGuidList;
    function GetClientList: TGuidList;
    function GetClientTypeList: TGuidList;
    function GetSystemAccountList: TGuidList;

    // Add Items
    function MergeUser(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddSystemAccount(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddClientGroup(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddClientType(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddSystemClient(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddClientFile(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddUserMap(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddDiskLog(ForAction: TMigrateAction; Value: TGuidObject): Boolean;

    procedure MigrateMasterMems(ForAction: TMigrateAction);
    function AddMasterMemFile(ForAction: TMigrateAction; Prefix: string): Boolean;
    function AddMasterMem(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
    function AddMasterMemLine(ForAction: TMigrateAction; Value: TGuidObject): Boolean;

    function GetlongDate(const Value: string): Integer;
    function AddCharges(ForAction: TMigrateAction; Value: string): Boolean;
    function AddHTMFile(ForAction: TMigrateAction; Value: string): Boolean;
    function AddRPTFile(ForAction: TMigrateAction; Value: string): Boolean;
    function MigrateWorkFolder(ForAction: TMigrateAction): Boolean;
    function MigrateDisklog(ForAction: TMigrateAction): Boolean;
    function MigrateSystem(ForAction: TMigrateAction): Boolean;
    function MigrateCustomDocs(ForAction:TMigrateAction): Boolean;
    function MigrateTax(ForAction: TMigrateAction): Boolean;


    // Size Items
    function SizeSystemAccount(Value: TGuidObject): Int64;
    function SizeClientFile(Value: TGuidObject): Int64;

    function GetSystemUsers: TADODataSet;
    function GetUserRoleID(user: pUser_Rec): TGuid;
    procedure SetSystem(const Value: TSystemObj);
    function GetUserList: TGuidList;
    function GetbtTable: TbtTable;
    function GetSystemAccountTable: TSystemBankAccountTable;
    function GetClientTypeTable: TClientTypeTable;
    function GetGroupTable: TClientGroupTable;
    function GetClientAccountMapTable: TClientAccountMapTable;
    function GetSystemClientFileTable: TSystemClientFileTable;
    function GetUserTable: TUserTable;
    procedure SetClientMigrater(const Value: TMigrater);
    procedure SetDoArchived(const Value: Boolean);
    procedure SetDoUnsynchronised(const Value: Boolean);
    procedure SetDoUsers(const Value: Boolean);
    function GetUserMappingTable: TUserMappingTable;
    function GetClientAccountMap: tGuidList;
    function GetMasterMemorisationsTable: TMasterMemorisationsTable;
    function GetMasterMemlinesTable: TMasterMemlinesTable;
    function GetChargesTable: TChargesTable;
    procedure SetDoSystemTransactions(const Value: Boolean);
    function GetDownloadDocumentTable: TDownloadDocumentTable;
    function GetDownloadlogTable: TDownloadlogTable;
    function GetParameterTable: TParameterTable;
    function GetTaxEntriesTable: TTaxEntriesTable;
    function GetTaxRatesTable: TTaxRatesTable;
protected
    procedure OnConnected; override;
public
    constructor Create;
    destructor Destroy; override;

    function ClearData(ForAction: TMigrateAction): Boolean; override;

    property System: TSystemObj read FSystem write SetSystem;

    // Lists
    property ClientTypeList: TGuidList read GetClientTypeList;
    property ClientGroupList: TGuidList read GetClientGroupList;
    property UserList: TGuidList read GetUserList;
    property SystemAccountList: TGuidList read GetSystemAccountList;
    property ClientList: TGuidList read GetClientList;
    property ClientAccountMap: tGuidList read GetClientAccountMap;
    property SystemUsers: TADODataSet read GetSystemUsers;
    function GetSystemAccount(AccountNo: string): TGuidObject;

    //Tables
    property btTable: TbtTable read GetbtTable;
    property SystemAccountTable: TSystemBankAccountTable read GetSystemAccountTable;
    property GroupTable: TClientGroupTable read GetGroupTable;
    property ClientTypeTable: TClientTypeTable read GetClientTypeTable;
    property SystemClientFileTable: TSystemClientFileTable read GetSystemClientFileTable;
    property UserTable: TUserTable read GetUserTable;
    property ClientAccountMapTable: TClientAccountMapTable read GetClientAccountMapTable;
    property UserMappingTable: TUserMappingTable read GetUserMappingTable;
    property MasterMemorisationsTable: TMasterMemorisationsTable read GetMasterMemorisationsTable;
    property MasterMemlinesTable: TMasterMemlinesTable read GetMasterMemlinesTable;
    property ChargesTable: TChargesTable read GetChargesTable;
    property DownloadDocumentTable: TDownloadDocumentTable read GetDownloadDocumentTable;
    property DownloadlogTable: TDownloadlogTable read GetDownloadlogTable;
    property ParameterTable: TParameterTable read GetParameterTable;
    property TaxEntriesTable: TTaxEntriesTable read GetTaxEntriesTable;
    property TaxRatesTable: TTaxRatesTable read GetTaxRatesTable;
    //Options
    property DoSystemTransactions: Boolean read FDoSystemTransactions write SetDoSystemTransactions;
    property DoUsers: Boolean read FDoUsers write SetDousers;
    property DoArchived: Boolean read FDoArchived write SetDoArchived;
    property DoUnsynchronised: Boolean read FDoUnsynchronised write SetDoUnsynchronised;
    //Migrate functions ..
    property ClientMigrater: TMigrater read FClientMigrater write SetClientMigrater;
    function Migrate(ForAction:TMigrateAction): Boolean;

    // Helper for the Client
    function GetUser(const Value: string): TGuid; overload;
    function GetUser(const Value: integer): TGuid; overload;

    // Work Documents
    function GetWorkFileList:TStringList;
end;

implementation

uses
   CustomDocEditorFrm,
   INISettings,
   PassWordHash,
   Stdate,
   Moneydef,
   Globals,
   StDateSt,
   bkDefs,
   MemorisationsObj,
   GLConst,
   bkconst,
   ClientMigrater,
   winutils,
   SyHelpers,
   SysUtils;

{ TSystemMigrater }

function TSystemMigrater.AddCharges(ForAction: TMigrateAction; Value: string): Boolean;
var lFile,lLine: TStringList;
    MyAction: TMigrateAction;
    ChargesDate: Integer;
    L: Integer;
    cAcc,cFileCode,cCostCode,cCharges,cTrans,cNew,cLoad,cOffsite : integer;

    function GetDate: Integer;
    var lFile: string;
    begin
       lFile := copy(ExtractFilename(Value),1,7);
       Result := DateStringToStDate('NNNyyyy', LFile, BKDATEEPOCH);
    end;

    procedure AddAccountLine;
    var
       Account: TGuidobject;
       Charges: Double;
       Transactions: Integer;
       IsNew, LoadChargeBilled: Boolean;
       OffSiteChargeIncluded: Boolean;
       FileCode,CostCode: string;

       function TextField(Col: Integer):string;
       begin
          Result := '';
          if Col < 0  then
             Exit;
          if Col >= lLine.Count then
             Exit;
          Result := lLine[Col];
       end;

       function IntField(Col: Integer): Integer;
       var iStr: string;
       begin
          Result := 0;
          iStr := TextField(Col);
          if iStr > '' then
             result := StrToInt(istr);
       end;

       function BoolField(Col: Integer; Default: Boolean = false): Boolean;
       var bStr: string;
       begin
          Result := Default;
          bStr := TextField(Col);
          if bStr > '' then
             Result := (Upcase(bStr[1]) = 'Y')
                    or (Upcase(bStr[1]) = 'T')
       end;

    begin
       Account := GetSystemAccount(lLine[cAcc]);
       if not Assigned(Account) then begin
          // Make it up...
          // Practice should already have added it if we did need it...
          Exit;
       end;
       Charges := StrToFloat(lLine[cCharges]);
       FileCode := TextField(cFileCode);
       CostCode := TextField(cCostCode);
       IsNew := BoolField(cNew);
       LoadChargeBilled := BoolField(cLoad);
       OffSiteChargeIncluded := BoolField(cOffsite);
       Transactions := IntField(cTrans);
       ChargesTable.Insert(NewGuid,Account.GuidID,ChargesDate,Charges, Transactions,
             IsNew, LoadChargeBilled,OffSiteChargeIncluded,FileCode,CostCode );
    end;

begin
   Result := True;
   lLine := nil;
   MyAction := nil;
   lFile := TStringList.Create;
   try
      lFile.LoadFromFile(Value);
      if LFile.Count < 1 then
         Exit; //Only have header line or less...

      // Get Ready to run..
      lLine := TStringList.Create;
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := true;
      ChargesDate := GetDate;

      if LFile.Count > 150 then begin
         // not worth it if to small
         MyAction := ForAction.InsertAction(format('Charges: %s',[StDateToDateString('NNN yyyy',ChargesDate,false)] ));
         MyAction.Target := lFile.Count;
      end;

      lLine.DelimitedText := LFile[0];
      // Find the names.
      cAcc := lLine.IndexOf('Account No');
      cFileCode := lLine.IndexOf('File Code');
      cCostCode := lLine.IndexOf('Cost Code');
      cCharges := lLine.IndexOf('Charges');
      cTrans := lLine.IndexOf('No Of Transactions');
      cNew := lLine.IndexOf('New Account');
      cLoad := lLine.IndexOf('Load Charge Billed');
      cOffsite := lLine.IndexOf('Off-site charge included');
      for L := 1 to LFile.Count - 1 do  begin
         lLine.DelimitedText := LFile[L];
         AddAccountLine;
         if Assigned(MyAction) then
            MyAction.AddCount;
      end;

      if Assigned(MyAction) then begin
         MyAction.Count := LFile.Count;
         MyAction.AddRunSize(GetFileSize(Value));
      end;
   finally
      FreeAndnil(LFile);
      FreeAndnil(LLine);
   end;
end;

function TSystemMigrater.AddClientFile(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;

var
   Clients: TClientMigrater;
   Clientrec: pClient_File_Rec;
begin

   Result := false;

   if not (ClientMigrater is TClientMigrater) then
      Exit; // Raise exception... or set error..

   Clients := ClientMigrater as TClientMigrater;
   Clientrec := pClient_File_Rec(Value.Data);
   if DoUnsynchronised
   or (not Clientrec.cfForeign_File) then
      Result := Clients.Migrate
         (
            ForAction,
            Clientrec.cfFile_Code,
            Value.GuidID,
            GetUser(Clientrec.cfUser_Responsible),
            ClientGroupList.FindLrnGuid(Clientrec.cfGroup_LRN),
            ClientTypeList.FindLrnGuid(Clientrec.cfClient_Type_LRN),
            Clientrec
         );
end;

function TSystemMigrater.AddClientGroup(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
   Result := GroupTable.Insert(Value.GuidID, pGroup_Rec(Value.Data))
end;

function TSystemMigrater.AddClientType(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
  Result := ClientTypeTable.Insert(Value.GuidID, pClient_Type_Rec(Value.Data))
end;

function TSystemMigrater.AddDiskLog(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
  Result := DownloadLogTable.Insert(Value.GuidID, pSystem_Disk_Log_Rec(Value.Data))
end;

function TSystemMigrater.AddHTMFile(ForAction: TMigrateAction; Value: string): Boolean;

var lFile: TStringList;
    L, Doctype: string;
    I,P: Integer;
    ForDate: Integer;
begin
   ForDate := -1;
   Doctype := '';
   lFile := TStringList.Create;
   try
      lFile.LoadFromFile(Value);
      for I := 0 to lfile.Count - 1 do begin
         if pos('STATEMENT<br>',lFile[I]) > 0 then begin
            Doctype := 'Statement';
         end else if pos('TRANSACTIONS<br>',lFile[I]) > 0 then begin
            Doctype := 'Interim report';
         end else if I > 75  then
            Break // Past any header bits..
         else
            Continue; // still looking

         if I = Pred(lfile.Count) then
            Break; // No more lines left...

         L := lFile[I + 1];

         P := pos( '<br>', L);
         if P > 0 then begin
            L := Copy(L, 1, P-1);
            P := pos( '>', L); // any other tags...
            if P > 0 then
               L := Copy(L, p + 1, length(L));
            ForDate := GetlongDate(L);
         end;

         Break; // Found what I was looking for..
      end;

      // add The document..
      Result := DownLoadDocumentTable.Insert(NewGuid,Doctype,
             ExtractFilename(value),
             Value,
             Fordate);

   finally
      LFile.Free;
   end;
end;

function TSystemMigrater.AddMasterMem(ForAction: TMigrateAction; Value: TGuidObject): Boolean;

var
   Memorisation: TMemorisation;
   LineList: TGuidList;
begin
   Memorisation := TMemorisation(Value.Data);
   Result := MasterMemorisationsTable.Insert(
        Value.GuidID,
        GetProviderID(AccountingSystem,System.fdFields.fdCountry,
                         Memorisation.mdFields.mdAccounting_System),
        value.SequenceNo,
        ForAction.Title, // Is a bit dangorous, may need to make a TGuidObject for it...
        @Memorisation.mdFields);
   if not result then
      Exit;

   ForAction.Item := Value;
   LineList := TGuidList.Create(Memorisation.mdLines);
   try
      result := RunGuidList(ForAction,'',LineList,AddMasterMemLine);
   finally
      FreeAndNil(LineList);
   end;
end;

function TSystemMigrater.AddMasterMemFile(ForAction: TMigrateAction; prefix: string): Boolean;
var Master_Mems: TMaster_Memorisations_List;
    MasterList: TGuidList;
begin
   Result := True;
   MasterList := nil;
   Master_Mems := TMaster_Memorisations_List.Create(Prefix);
   try
      Master_Mems.QuickRead;
      if Master_Mems.ItemCount = 0 then
         Exit;

      MasterList := TGuidList.Create(Master_Mems);
      // ReSequence..
      MasterList.reverse;
      Result := RunGuidList(ForAction,Prefix,MasterList,AddMasterMem);
   finally
      Master_Mems.Free;
      FreeAndNil(MasterList);
   end;
end;

function TSystemMigrater.AddMasterMemLine(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
begin
   Result := MasterMemlinesTable.Insert
      (
         Value.GuidID,
         ForAction.Item.GuidID,
         Value.SequenceNo,
         pMemorisation_Line_Rec(Value.Data)
      )
end;

function TSystemMigrater.AddRPTFile(ForAction: TMigrateAction;
  Value: string): Boolean;

   function ReNameFile(Filename, NewExtention: string): string;
   var point: Integer;
   begin
        // Moves the numer to before the extention
        Result := FileName;
        Point := Pos('.',Result);
        if Point > 0 then
           Result := format('%s_%s.%s',[ copy(Filename,1,Point-1), Copy(FileName,Point+ 1, 255),NewExtention]) ;
   end;
var lFile: TStringList;
    L, Doctype: string;
    I: Integer;
    ForDate: Integer;

begin
   ForDate := -1;
   Doctype := '';
   lFile := TStringList.Create;
   try
      lFile.LoadFromFile(Value);
      for I := 0 to lfile.Count - 1 do begin
         if pos('<big>STATEMENT',lFile[I]) > 0 then begin
            Doctype := 'Statement';
         end else if pos('<big>CLIENT',lFile[I]) > 0 then begin
            Doctype := 'Interim report';
         end else if I > 75  then  // must be past the header...
            Break
         else
            Continue;

         if I = Pred(lfile.Count) then
            Break;

         L := lFile[I + 1];

         if pos( '<lmp>', L) = 1 then
            ForDate := GetlongDate(copy(L, 6, length(L)));

         Break;
      end;

      Result := DownLoadDocumentTable.Insert(NewGuid,Doctype,
             reNameFile(ExtractFilename(value),'rpt'),
             Value,
             Fordate);


   finally
      LFile.Free;
   end;
end;


function TSystemMigrater.AddSystemAccount(ForAction: TMigrateAction; Value: TGuidObject): Boolean;
var
    Account: pSystem_Bank_Account_Rec;
    eFileName: string;
    eFile: file of tArchived_Transaction;
    Entry: tArchived_Transaction;
    MyAction: TMigrateAction;
    Count: Integer;
begin
   Account := pSystem_Bank_Account_Rec(Value.Data);
   // Do the record
   Result := SystemAccountTable.Insert(Value.GuidID,Account);

   if not FDoSystemTransactions then
      Exit;

   // find the transactions
   eFileName := ArchiveFileName( Account.sbLRN );
   if not BKFileExists(eFileName)then
      Exit;



   // have a go..
   Count := 0;
   MyAction := nil;
   AssignFile(eFile, eFileName);
   Reset(eFile); { TODO : May need to chnge, cannot handle readOnly files.. }

   try
      Count := FileSize(eFile);
      if Count = 0 then
         Exit // Nothing in the file.
      else begin
         MyAction := ForAction.InsertAction(format('%s %s',[Account.sbAccount_Number, Account.sbAccount_Name]));
         MyAction.Target := Count;
         Count := 0;
      end;

      while not EOF(eFile) do begin
         Read(eFile, Entry);
         BTTable.Insert(NewGuid,Value.GuidID,Entry);

         inc(Count);
         MyAction.AddCount;
      end;

   finally
      CloseFile(eFile);
      if Assigned(Myaction) then
         MyAction.Count := Count;



   end;
end;

function TSystemMigrater.AddSystemClient(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
var Clientrec: pClient_File_Rec;
begin
   Clientrec := pClient_File_Rec(Value.Data);
   if DoUnsynchronised
   or ( not Clientrec.cfForeign_File) then
      Result := SystemClientFileTable.Insert
        (
          Value.GuidID,
          'PracticeClient',
          ClientGroupList.FindLrnGuid(Clientrec.cfGroup_LRN),
          ClientTypeList.FindLrnGuid(Clientrec.cfClient_Type_LRN),
          Clientrec
        )
    else
       Result := false;
end;

function TSystemMigrater.AddUserMap(ForAction: TMigrateAction; Value: TGuidObject): Boolean;

var UserID, ClientID: TGuid;

begin
   Result := true;
   with pFile_Access_Mapping_Rec(Value.Data)^ do begin
      UserID := GetUser(acUser_LRN);
      if IsEqualGUID(UserID,emptyGuid) then
         Exit;
      ClientID := ClientList.FindLRNGuid(acClient_File_LRN);
      if IsEqualGUID(ClientID,emptyGuid) then
         Exit;
      Result := UserMappingTable.Insert(Value.GuidID, UserID, ClientID);
   end;
end;

function TSystemMigrater.ClearData(ForAction: TMigrateAction): Boolean;
var MyAction: TMigrateAction;
begin
   Result := false;
   MyAction := ForAction.NewAction('Clear System');
   try
      Connected := true;

      DeleteTable(MyAction,'UserClients');

      DeleteTable(MyAction,Chargestable,True);
      DeleteTable(MyAction,DownloadDocumentTable, True);
      DeleteTable(MyAction,btTable, True);

      DeleteTable(MyAction,TaxRatesTable);
      DeleteTable(MyAction,TaxEntriesTable);

      DeleteTable(MyAction,'ClientSystemAccounts');;
      DeleteTable(MyAction,'SystemBankAccounts');

      DeleteTable(MyAction,'PracticeClients');

      DeleteTable(MyAction,'ClientGroups');
      DeleteTable(MyAction,'ClientTypes');

      DeleteTable(MyAction,'MasterMemorisationLines', true);
      DeleteTable(MyAction,'MasterMemorisations');


      Result := True;
      MyAction.Status := Success;
   except
      on E: Exception do
         MyAction.Error := E.Message;
   end;
end;

constructor TSystemMigrater.Create;
begin
   Inherited Create;
   FClientTypeList := nil;
   FClientGroupList := nil;
   FUserList := nil;
   FSystemAccountList := nil;
   FClientList := nil;
   FSystemUsers := nil;
   FbtTable := nil;
   FSystemAccountTable := nil;
   FClientAccountMapTable := nil;
   FSystemClientFileTable := nil;
   FClientTypeTable := nil;
   FUserTable := nil;
   FGroupTable := nil;
   FUserMappingTable := nil;
   FClientAccountMap := nil;
   FMasterMemorisationsTable := nil;
   FMasterMemlinesTable := nil;
   FChargesTable := nil;
   FDownloadDocumentTable := nil;
   FDownloadlogTable := nil;
   FParameterTable := nil;
end;

destructor TSystemMigrater.Destroy;
begin
   FreeAndnil(FClientTypeList);
   FreeAndnil(FClientGroupList);
   FreeAndnil(FUserList);
   FreeAndnil(FSystemAccountList);
   FreeAndnil(FClientList);
   FreeAndNil(FSystemUsers);
   FreeAndNil(FbtTable);
   FreeAndNil(FSystemAccountTable);
   FreeAndNil(FClientAccountMapTable);
   FreeAndNil(FSystemClientFileTable);
   FreeAndNil(FClientTypeTable);
   FreeAndNil(FUserTable);
   FreeAndNil(FGroupTable);
   FreeAndNil(FUserMappingTable);
   FreeAndnil(FClientAccountMap);
   FreeAndNil(FMasterMemorisationsTable);
   FreeAndNil(FMasterMemlinesTable);
   FreeAndNil(FChargesTable);
   FreeAndNil(FDownloadDocumentTable);
   FreeAndNil(FDownloadlogTable);
   FreeAndNil(FParameterTable);
   inherited;
end;

function TSystemMigrater.GetbtTable: TbtTable;
begin
   if not Assigned(FbtTable) then
      FbtTable := TbtTable.Create(Connection);
   Result := FbtTable;
end;

function TSystemMigrater.GetClientGroupList: TGuidList;
begin
   if not Assigned(FClientGroupList) then
      FClientGroupList := TGuidList.Create();
   Result := FClientGroupList;
end;

function TSystemMigrater.GetClientList: TGuidList;
begin
   if not Assigned(FClientList) then
      FClientList := TGuidList.Create();
   Result := FClientList;
end;

function TSystemMigrater.GetClientTypeList: TGuidList;
begin
   if not Assigned(FClientTypeList) then
      FClientTypeList := TGuidList.Create();
   Result := FClientTypeList;
end;

function TSystemMigrater.GetClientTypeTable: TClientTypeTable;
begin
   if not Assigned(FClientTypeTable) then
      FClientTypeTable := TClientTypeTable.Create(Connection);
   Result := FClientTypeTable;
end;

function TSystemMigrater.GetDownloadDocumentTable: TDownloadDocumentTable;
begin
   if not Assigned(FDownloadDocumentTable) then
      FDownloadDocumentTable := TDownloadDocumentTable.Create(Connection);
   Result := FDownloadDocumentTable;
end;

function TSystemMigrater.GetDownloadlogTable: TDownloadlogTable;
begin
  if not Assigned(FDownloadlogTable) then
      FDownloadlogTable := TDownloadlogTable.Create(Connection);
   Result := FDownloadlogTable;
end;

function TSystemMigrater.GetGroupTable: TClientGroupTable;
begin
   if not Assigned(FGroupTable) then
      FGroupTable := TClientGroupTable.Create(Connection);
   Result := FGroupTable;
end;

function TSystemMigrater.GetlongDate(const Value: string): Integer;
var L: string;
    P,D,M,Y: Integer;

    function CleanLine: string;
    var i: Integer;
    begin
       Result := Value;
       for I := 1 to Length(Value) do
       case Result[i] of
       #$A0 : Result[I] := #$20; // None braking space to 'Normal' space See Case 10726
       else Result[I] := UpCase(Result[I]);
       end;
  end;
begin
   M := -1;
   try
      L := CleanLine;
      p := pos(' ',L);
      D := StrToInt(Copy(L,1,P-1));
      L := Copy(L,P+1,255);
      for P := 1 to 12 do
         if Pos(Uppercase(ShortMonthNames[P]),L) = 1 then begin
            M := P;
         end;
      p := pos(' ',L);
      L := Copy(L,P+1,255);
      Y := StrToInt(L);
      Result := DMYtoStDate(D,M,Y,BKDATEEPOCH);
   except
      Result := -1;
   end;
end;

function TSystemMigrater.GetMasterMemlinesTable: TMasterMemlinesTable;
begin
  if not Assigned(FMasterMemlinesTable) then
      FMasterMemlinesTable := TMasterMemlinesTable.Create(Connection);
   Result := FMasterMemlinesTable;
end;

function TSystemMigrater.GetMasterMemorisationsTable: TMasterMemorisationsTable;
begin
   if not Assigned(FMasterMemorisationsTable) then
      FMasterMemorisationsTable := TMasterMemorisationsTable.Create(Connection);
   Result := FMasterMemorisationsTable;
end;

function TSystemMigrater.GetParameterTable: TParameterTable;
begin
   if not Assigned(FParameterTable) then
      FParameterTable := TParameterTable.Create(Connection);
   Result := FParameterTable;
end;

function TSystemMigrater.GetChargesTable: TChargesTable;
begin
  if not Assigned(FChargesTable) then
      FChargesTable := TChargesTable.Create(Connection);
   Result := FChargesTable;
end;

function TSystemMigrater.GetClientAccountMap: tGuidList;
begin
   if not Assigned(FClientAccountMap) then
      FClientAccountMap := TGuidList.Create();
   Result := FClientAccountMap;
end;

function TSystemMigrater.GetClientAccountMapTable: TClientAccountMapTable;
begin
   if not Assigned(FClientAccountMapTable) then
      FClientAccountMapTable := TClientAccountMapTable.Create(Connection);
   Result := FClientAccountMapTable;
end;

function TSystemMigrater.GetSystemAccount(AccountNo: string): TGuidObject;
var I: Integer;
begin
    fillchar(Result, Sizeof(Result), 0);
    for I := 0 to SystemAccountList.Count - 1 do
       with pSystem_Bank_Account_Rec(TGuidObject(SystemAccountList[I]).Data)^ do
           if SameText(sbAccount_Number,AccountNo) then begin
              Result := TGuidObject(SystemAccountList[I]);
              Exit;// we are done...
           end;
end;

function TSystemMigrater.GetSystemAccountList: TGuidList;
begin
  if not Assigned(FSystemAccountList) then
      FSystemAccountList := TGuidList.Create();
   Result := FSystemAccountList;
end;

function TSystemMigrater.GetSystemAccountTable: TSystemBankAccountTable;
begin
   if not Assigned(FSystemAccountTable) then
      FSystemAccountTable := TSystemBankAccountTable.Create(Connection);
   Result := FSystemAccountTable;
end;

function TSystemMigrater.GetSystemClientFileTable: TSystemClientFileTable;
begin
   if not Assigned(FSystemClientFileTable) then
      FSystemClientFileTable := TSystemClientFileTable.Create(Connection);
   Result := FSystemClientFileTable;
end;

function TSystemMigrater.GetSystemUsers: TADODataSet;
begin
   if not Assigned(FSystemUsers) then begin
      FSystemUsers := TADODataSet.Create(nil);
      FSystemUsers.ParamCheck := True;
      FSystemUsers.Connection := Connection;
      FSystemUsers.CommandText := 'Select [Id] from [users] where [code] = :Code';
   end;
   Result := FSystemUsers;
end;

function TSystemMigrater.GetTaxEntriesTable: TTaxEntriesTable;
begin
   if not Assigned(FTaxEntriesTable) then
      FTaxEntriesTable := TTaxEntriesTable.Create(Connection);
   Result := FTaxEntriesTable;
end;

function TSystemMigrater.GetTaxRatesTable: TTaxRatesTable;
begin
   if not Assigned(FTaxRatesTable) then
      FTaxRatesTable := TTaxRatesTable.Create(Connection);
   Result := FTaxRatesTable;
end;

function TSystemMigrater.GetUser(const Value: string): TGuid;
var I: Integer;
begin
   FillChar(Result, Sizeof(Result), 0);
   for I := 0 to UserList.Count - 1 do
      if(PUser_Rec(TGuidObject(FuserList.Items[i]).Data)^.usCode = Value) then begin
         Result := TGuidObject(FuserList.Items[i]).GuidID;
         Exit;
      end;
end;

function TSystemMigrater.GetUser(const Value: integer): TGuid;
var I: Integer;
begin
   FillChar(Result, Sizeof(Result), 0);
   for I := 0 to UserList.Count - 1 do
      if(PUser_Rec(TGuidObject(FuserList.Items[i]).Data)^.usLRN = Value) then begin
         Result := TGuidObject(FuserList.Items[i]).GuidID;
         Exit;
      end;
end;

function TSystemMigrater.GetUserList: TGuidList;
begin
   if not Assigned(FUserList) then
      FUserList := TGuidList.Create();
   Result := FUserList;
end;

function TSystemMigrater.GetUserMappingTable: TUserMappingTable;
begin
   if not Assigned(FUserMappingTable) then
      FUserMappingTable := TUserMappingTable.Create(Connection);
   Result := FUserMappingTable;
end;

function TSystemMigrater.GetUserRoleID(user: pUser_Rec): TGuid;
begin
   if user.usSystem_Access then
      Result :=  StringToGuid('{23C33A8C-BF2C-4655-9135-6EF3B77EC1A1}')
   else if user.usIs_Remote_User then
      Result :=  StringToGuid('{54BB8CA5-091B-46B6-915A-5C8760DC7631}')
   else
      Result :=  StringToGuid('{26767464-57F4-4B2F-AC57-0222AFE36521}');
end;

function TSystemMigrater.GetUserTable: TUserTable;
begin
   if not Assigned(FUserTable) then
      FUserTable := TUserTable.Create(Connection);
   Result := FUserTable;
end;

function TSystemMigrater.GetWorkFileList: TStringList;
  var Rec: TSearchRec;
      ext: string;
begin
   Result := TStringList.Create;
   if FindFirst(DownloadWorkDir + '*.*', faAnyFile, Rec) = 0 then begin
      repeat
			     // Exclude directories from the list of files.
			     ext := ExtractFileExt(rec.Name );
           if Sametext(Ext,'.csv') then
              Result.AddObject(DownloadWorkDir + Rec.Name, TObject(1))
           else if Sametext(Ext,'.htm') then
              Result.AddObject(DownloadWorkDir + Rec.Name, TObject(2))
           else if pos('REPORTS',rec.Name) = 1 then
              Result.AddObject(DownloadWorkDir + Rec.Name, TObject(3))


      until FindNext(Rec) <> 0;
      FindClose(Rec);
   end;
end;


procedure TSystemMigrater.MigrateMasterMems(ForAction: TMigrateAction);
var
   PrefixList: TStringList;
   MyAction: TMigrateAction;
   I: Integer;
begin
    PrefixList := TStringList.Create;
    try
       if GetMasterMemList(system.fdFields.fdCountry,PrefixList) = 0 then
          Exit;
       if PrefixList.Count = 0 then
          Exit;
       MyAction := ForAction.NewAction('Master memorizations');
       MyAction.Target := PrefixList.Count;

       for I := 0 to PrefixList.Count - 1 do begin
          AddMasterMemFile(MyAction,PrefixList[I]);
          MyAction.Counter := I;
       end;

       MyAction.Count := PrefixList.Count;

    finally
       PrefixList.Free;
    end;
end;

function TSystemMigrater.MigrateSystem(ForAction: TMigrateAction): Boolean;
begin
   ParameterTable.Update('AccountCodeMask', System.fdFields.fdAccount_Code_Mask);
   ParameterTable.Update('AccountingSystem', GetProviderID(AccountingSystem,System.fdFields.fdCountry, System.fdFields.fdAccounting_System_Used));
   ParameterTable.Update('AutoPrintScheduledReportSummary', System.fdFields.fdAuto_Print_Sched_Rep_Summary);
   ParameterTable.Update('BankLinkCode', System.fdFields.fdBankLink_Code);

   ParameterTable.Update('BankLinkConnectPassword', System.fdFields.fdBankLink_Connect_Password);
   ParameterTable.Update('EnableBulkexport', System.fdFields.fdBulk_Export_Enabled);
   ParameterTable.Update('BulkExportFormat', System.fdFields.fdBulk_Export_Code);

   ParameterTable.Update('CodingFont', System.fdFields.fdCoding_Font);
   ParameterTable.Update('CollectUsageData', System.fdFields.fdCollect_Usage_Data);

   ParameterTable.Update('CopyDissectionNarration', System.fdFields.fdCopy_Dissection_Narration);

   ParameterTable.Update('DiskSequenceNo', System.fdFields.fdDisk_Sequence_No);

   ParameterTable.Update('ExportChargesRemarks', System.fdFields.fdExport_Charges_Remarks);

   //ParameterTable.Update('ExportTaxFileTo', System.fdFields);

   ParameterTable.Update('ExtractJournalAccountsPA', System.fdFields.fdExtract_Journal_Accounts_PA);
   ParameterTable.Update('ExtractMultipleAccountsPA', System.fdFields.fdExtract_Multiple_Accounts_PA);
   ParameterTable.Update('ExtractQuantity', System.fdFields.fdExtract_Quantity);
   ParameterTable.Update('ExtractQuantityDecimalPlaces', System.fdFields.fdExtract_Quantity_Decimal_Places);

   ParameterTable.Update('FixedChargeIncrease', System.fdFields.fdFixed_Charge_Increase);
   ParameterTable.Update('FixedDollarAmount', System.fdFields.fdFixed_Dollar_Amount);

   ParameterTable.Update('ForceLogin', System.fdFields.fdForce_Login );

   ParameterTable.Update('IgnoreQuantityInDownload', System.fdFields.fdIgnore_Quantity_In_Download);

   ParameterTable.Update('LastDiskImageVersion', System.fdFields.fdLast_Disk_Image_Version);

   ParameterTable.Update('LastExportChargesSavedTo', System.fdFields.fdLast_Export_Charges_Saved_To);

   ParameterTable.Update('LoadChartFrom', System.fdFields.fdLoad_Client_Files_From);
   ParameterTable.Update('LoadClientSuperFilesFrom', System.fdFields.fdLoad_Client_Super_Files_From);
   ParameterTable.Update('LoginBitmapFilename', System.fdFields.fdLogin_Bitmap_Filename);

   ParameterTable.Update('PracticeManagementSystem', GetProviderID(ManagementSystem,System.fdFields.fdCountry, System.fdFields.fdPractice_Management_System));

   ParameterTable.Update('PINNumber', System.fdFields.fdPIN_Number);

   ParameterTable.Update('PracticeName', System.fdFields.fdPractice_Name_for_Reports);
   ParameterTable.Update('PracticePhone', System.fdFields.fdPractice_Phone);
   ParameterTable.Update('PracticeWebSite', System.fdFields.fdPractice_Web_Site);
   ParameterTable.Update('PracticeEmail', System.fdFields.fdPractice_EMail_Address);

   ParameterTable.Update('PrintClientTypeHeaderPage', System.fdFields.fdPrint_Client_Type_Header_Page);
   ParameterTable.Update('PrintGroupHeaderPage', System.fdFields.fdPrint_Group_Header_Page);

   ParameterTable.Update('ReplaceNarrationWithPayee', System.fdFields.fdReplace_Narration_With_Payee);

   ParameterTable.Update('SaveClientSuperFilesTo', System.fdFields.fdSave_Client_Super_Files_To);
   ParameterTable.Update('SaveEntriesTo', System.fdFields.fdSave_Client_Files_To);//???
   ParameterTable.Update('SaveTaxFilesTo', System.fdFields.fdSave_Tax_Files_To);
   ParameterTable.Update('SetFixedDollarAmount', System.fdFields.fdSet_Fixed_Dollar_Amount);



   ParameterTable.Update('SystemReportPassword', System.fdFields.fdSystem_Report_Password);
   ParameterTable.Update('TaskTrackingPromptType', System.fdFields.fdTask_Tracking_Prompt_Type);
   ParameterTable.Update('TaxInterfaceUsed', GetProviderID(TaxSystem,System.fdFields.fdCountry, System.fdFields.fdTax_Interface_Used));
   ParameterTable.Update('UpdateServerForOffsites', System.fdFields.fdUpdate_Server_For_Offsites);

   ParameterTable.Update('UseXlonChartOrder', System.fdFields.fdUse_Xlon_Chart_Order);
   ParameterTable.Update('WebExportFormat',GetProviderID (WebExport,System.fdFields.fdCountry, System.fdFields.fdWeb_Export_Format));

   //Pracini
   ReadPracticeINI;
   case System.fdFields.fdCountry of
      whNewZealand : begin
         ParameterTable.Update('GSTReturnLink', PRACINI_GST101Link);
         ParameterTable.Update('Institutionslink',PRACINI_InstListLinkNZ);
      end;
      whAustralia : begin
         ParameterTable.Update('Institutionslink',PRACINI_InstListLinkAU);
      end;
   end;

   //ParameterTable.Update('ShowCaptions', System.fdFields.fd)
   //Userini
   //ParameterTable.Update('ShowCaptions', System.fdFields.fd);
   //ParameterTable.Update('ShowDesrciptions', System.fdFields.fd);
   //ParameterTable.Update('SMTPAccountName', System.fdFields.fd);
   Result := true;
end;

function TSystemMigrater.MigrateTax(ForAction: TMigrateAction): Boolean;
var ClassNo, Rate: Integer;
    ClassID,
    EntryID: TGuid;
begin
  if ForAction.CheckCanceled then
      Exit;

   for ClassNo := 1 to MAX_GST_CLASS do begin
      if FSystem.fdFields.fdGST_Class_Names[ClassNo] = '' then
        Continue; // nothing to save...
      if FSystem.fdFields.fdGST_Class_Codes[ClassNo] = '' then
        Continue;

      ClassID := GetTaxClassGuid(FSystem.fdFields.fdCountry, FSystem.fdFields.fdGST_Class_Types[ClassNo]);
      if IsEqualGUID(ClassID,emptyGuid) then
        Continue; // Not A Valid Tax Entry..

      try
      CreateGuid(EntryId);
      // Add The Entry
      TaxEntriesTable.Insert
         (
            EntryId,
            ClassID,
            ClassNo,
            FSystem.fdFields.fdGST_Class_Codes[ClassNo],
            FSystem.fdFields.fdGST_Class_Names[ClassNo],
            FSystem.fdFields.fdGST_Account_Codes[ClassNo]
         );

      // Now add the rates
      for Rate := 1 to High(FSystem.fdFields.fdGST_Applies_From) do begin
         if (FSystem.fdFields.fdGST_Applies_From[Rate]) = 0 then
            Continue;
         if FSystem.fdFields.fdGST_Rates[ClassNo][Rate] = 0 then
            Continue;

         TaxRatesTable.Insert
             (
                NewGuid,
                EntryId,
                FSystem.fdFields.fdGST_Rates[ClassNo][Rate],
                FSystem.fdFields.fdGST_Applies_From[Rate]
             );
      end;
      except
         on e: exception do
            ForAction.Exception(e, 'Adding Tax Rates')
      end;

   end;
end;

function TSystemMigrater.MigrateWorkFolder(ForAction: TMigrateAction): Boolean;
var
  MyAction: TMigrateAction;
  Files: TStringList;
  I: Integer;

const
  sizeWeight = 50;
begin
  Result := false;
  Files := GetWorkFileList;
  try
     if Files.Count = 0 then begin
        Result := True;
        Exit;
     end;
     MyAction := ForAction.InsertAction('Download Documents');
     MyAction.Target := Files.Count;
     try
        // Work out the size...
        for I := 0 to Files.Count - 1 do
           case Integer(Files.Objects[I]) of
              1: MyAction.TotSize := MyAction.TotSize + GetFileSize(Files[I])
              else MyAction.TotSize := MyAction.TotSize + sizeWeight;
           end;

        for I := 0 to Files.Count - 1 do begin
           case Integer(Files.Objects[I]) of
              1: AddCharges(MyAction, Files[i]);
              2: begin
                    AddHTMFile(MyAction, Files[i]);
                    MyAction.AddRunSize(sizeWeight);
                 end;
              3: begin
                    AddRPTFile(MyAction, Files[i]);
                     MyAction.AddRunSize(sizeWeight);
                 end;
           end;

           if MyAction.CheckCanceled then begin
              Exit;
           end else
              MyAction.AddCount;

        end;

        MyAction.Count := Files.Count;
        Result := True;
     except
        on e: Exception do
           MyAction.Exception(E)
     end;
  finally
     Files.Free;
  end;
end;

function TSystemMigrater.MergeUser(ForAction: TMigrateAction;
  Value: TGuidObject): Boolean;
var User: PUser_rec;
begin

   User := PUser_rec(Value.Data);

   // See if we have it already
   Systemusers.Active := false;
   Systemusers.Parameters.ParamValues['Code']:= User.usCode;
   Systemusers.Active := True;
   if Systemusers.RecordCount > 0 then begin
      RunSQL(ForAction,format('Delete from [UserRoles] where [User_Id] = ''%s''',[SystemUsers.Fields[0].AsString]));
      RunSQL(ForAction,format('Delete from [Users] where [Code] = ''%s''',[User.usCode]));
           //RunSystemSQL(format('Delete from [UserClients] where [userID_ID] = %s',[ToSQL(UserId, false)]), 'Delete User clients', false);
           //Exit; // Merge....
   end;

   // Need a user name..
   if User.usName = '' then
      User.usName := User.usCode;

   // Add the user..
   UserTable.Insert(Value.GuidID,user);

   // Add the role
   InsertTable(
      ForAction,
      'UserRoles',
      '[Id],[User_Id],[Role_Id]',
      ToSql(NewGuid) + ToSQL(Value.GuidID) + ToSQL(GetUserRoleID(User),False),
      'User Role');
   Result := true;
end;

function TSystemMigrater.Migrate(ForAction: TMigrateAction): Boolean;
var
   MyAction: TMigrateAction;
   lList: TGuidList;
begin
   result := false;
   if not Assigned(System) then
      Exit;

   MyAction := ForAction.InsertAction(Format('Migrate %s',[System.fdFields.fdPractice_Name_for_Reports]));
   MyAction.Target := 100;
   MyAction.LogMessage('Migration Start');

   if DoUsers then
      if not RunGuidList(MyAction,'Users',UserList,MergeUser, true) then
         exit;

   if not RunGuidList(MyAction,'Client Groups',ClientGroupList, AddClientGroup) then
      Exit;

   if not RunGuidList(MyAction,'Client Types',ClientTypeList, AddClientType) then
      Exit;

   MyAction.Counter := 5;

   SystemAccountList.CheckSpeed := true;
   if not RunGuidList(MyAction,'System Accounts',SystemAccountList, AddSystemAccount, true) then
      Exit;
   MyAction.Counter := 20;

   ClientList.CheckSpeed := False;
   if not RunGuidList(MyAction,'Client List',ClientList, AddSystemClient) then
      Exit;

   MyAction.Counter := 25;

   // User map..
   lList := TGuidList.Create(System.fdSystem_File_Access_List);
   try
      if not RunGuidList(MyAction,'User Clients',LList, AddUserMap) then
         Exit;
   finally
      FreeAndNil(lList);
   end;

   MigrateMasterMems(MyAction);
   if MyAction.CheckCanceled then
      Exit;

   MigrateCustomDocs(MyAction);
   if MyAction.CheckCanceled then
      Exit;

   MigrateTax(MyAction);
   if MyAction.CheckCanceled then
      Exit;

   ClientList.CheckSpeed := True;
   if not RunGuidList(MyAction,'Client Files',ClientList, AddClientFile, true) then
      Exit;
   MyAction.Counter := 75;

   MigrateSystem(MyAction);

   MigrateWorkFolder(MyAction);
   if MyAction.CheckCanceled then
      Exit;

   MigrateDisklog(MyAction);
   if MyAction.CheckCanceled then
      Exit;

   Result := true;
   MyAction.Status := success;
   MyAction.LogMessage('Migration Complete');
end;



function TSystemMigrater.MigrateCustomDocs(ForAction: TMigrateAction): Boolean;
begin
   Result := false;
   if not (ClientMigrater is TClientMigrater) then
      Exit; // Raise exception... or set error..
   Result := TClientMigrater(ClientMigrater).MigrateCustomDocs(ForAction);
end;

function TSystemMigrater.MigrateDisklog(ForAction: TMigrateAction): Boolean;
var lList: TGuidList;
begin
   lList := TGuidList.Create(System.fdSystem_Disk_Log);
   try
      result := RunGuidList(ForAction,'Disk log',lList, addDiskLog);
   finally
      lList.Free;
   end;
end;

procedure TSystemMigrater.OnConnected;
begin
  inherited;
   BTTable.Prepared := True;
end;


procedure TSystemMigrater.SetClientMigrater(const Value: TMigrater);
begin
  FClientMigrater := Value;
end;


procedure TSystemMigrater.SetDoArchived(const Value: Boolean);
begin
  FDoArchived := Value;
end;


procedure TSystemMigrater.SetDoSystemTransactions(const Value: Boolean);
begin
  FDoSystemTransactions := Value;
end;

procedure TSystemMigrater.SetDoUnsynchronised(const Value: Boolean);
begin
  FDoUnsynchronised := Value;
end;

procedure TSystemMigrater.SetDousers(const Value: Boolean);
begin
  FDousers := Value;
end;


procedure TSystemMigrater.SetSystem(const Value: TSystemObj);
begin
  FSystem := Value;
  if Assigned(FSystem) then begin
     SystemAccountList.CloneList(FSystem.fdSystem_Bank_Account_List,SizeSystemAccount);
     UserList.CloneList(FSystem.fdSystem_User_List);
     ClientGroupList.CloneList(FSystem.fdSystem_Group_List);
     ClientTypeList.CloneList(FSystem.fdSystem_Client_Type_List);
     ClientList.CloneList(FSystem.fdSystem_Client_File_List,SizeClientFile);
     ClientAccountMap.CloneList(FSystem.fdSystem_Client_Account_Map);
  end;
end;


function TSystemMigrater.SizeClientFile(Value: TGuidObject): int64;
begin
   Value.Size := GetFileSize(DATADIR + pClient_File_Rec(Value.Data).cfFile_Code + FILEEXTN) div 500;
   Result := Value.Size;
end;

function TSystemMigrater.SizeSystemAccount(Value: TGuidObject): Int64;
begin
   // find the transactions
   Value.Size := GetFilesize(ArchiveFileName(pSystem_Bank_Account_Rec(Value.Data).sbLRN));
   Result := Value.Size;
end;

end.
