unit UsageUtils;

// -----------------------------------------------------------------------------
interface
// -----------------------------------------------------------------------------

procedure IncUsage( const AName: ShortString; const Replace: Boolean = False; const Count: Integer = 1) ;
procedure SetUsage( const AName: ShortString; const Count: Integer ) ;
procedure DeleteUsageData;
function CurrentUsageXML: string;
procedure SaveUsage;

Const
  UnitName = 'USAGEUTILS';
  USAGE_FILE = 'USAGE.CURRENT';

// -----------------------------------------------------------------------------
implementation

uses
   CodingStatsList32,csDefs,bkDateUtils,
   SysUtils, eCollect, StStrS, StDateSt, StDate, LockUtils,
  Globals, LogUtil, GlobalCache, Windows, SyDefs, BkConst, Admin32, Classes,
  inisettings,
  bkProduct;
// -----------------------------------------------------------------------------

type
  pUsageStatistics = ^tUsageStatistics;
  tUsageStatistics = record
    Name: string[ 80 ];
    Counter: Integer;
    Overwrite: Boolean;
  end;

type
  TUsageList = class( TExtdSortedCollection )
    function Compare( Item1, Item2: pointer ) : Integer; override;
  protected
    procedure FreeItem( Item: Pointer ) ; override;
    function Find( const AName: ShortString ) : pUsageStatistics;
    procedure SaveToFile( const AFileName: string ) ;
    procedure LoadFromFile( const AFileName: string ) ;
    procedure AppendTo( List: TUsageList ) ;
    procedure ResetSubStr( const AName: ShortString );
  end;

var
  UsageList: TUsageList;
  DebugMe : boolean = false;

// -----------------------------------------------------------------------------

procedure DeleteUsageData;
var
  i: Integer;
  u: pUser_Rec;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Delete Usage Data.');

  SysUtils.DeleteFile(UsageDir + USAGE_FILE);
  FreeAndNil( UsageList );
  UsageList := TUsageList.Create;
  if Assigned(AdminSystem) and LoadAdminSystem(true, 'UsageUtils.DeleteUsageData') then
  begin
    for i := 0 to Pred(AdminSystem.fdSystem_User_List.ItemCount) do
    begin
      u := AdminSystem.fdSystem_User_List.User_At(i);
      u.usLogin_Count := 0;
      u.usReset_Count := 0;
    end;
    SaveAdminSystem;
  end;
end;

function CurrentUsageXML: string;
var
  FileName, XML: string;
  Totals: TUsageList;
  P: pUsageStatistics;
  i: Integer;
begin
  SaveUsage;
  FileName := UsageDir + USAGE_FILE;
  Totals := TUsageList.Create;
  try
    Totals.LoadFromFile( FileName ) ;
    XML := '';
    for i := 0 to Pred(Totals.ItemCount) do
    begin
      P := pUsageStatistics(Totals.At(i));
      XML := XML + '<feature>' + P.Name + '</feature><count>' + IntToStr(P.Counter) + '</count>';
    end;
  finally
    FreeAndNil( Totals ) ;
  end;
  Result := XML;
end;

procedure IncUsage( const AName: ShortString; const Replace: Boolean = False; const Count: Integer = 1 ) ;
var
  P: pUsageStatistics;
begin
  If (not Assigned(AdminSystem)) or (not AdminSystem.fdFields.fdCollect_Usage_Data) then exit;
  P := UsageList.Find( AName ) ;
  if ( P = nil ) then
  begin
    New( P ) ;
    P.Name := AName;
    P.Counter := 0;
    P.Overwrite := Replace;
    UsageList.Insert( P ) ;
  end;
  Inc( P.Counter, Count ) ;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Inc Usage Data, Name - ' + AName + ', Current Value - ' + inttostr(P.Counter));
end;

procedure SetUsage( const AName: ShortString; const Count: Integer ) ;
var
  P: pUsageStatistics;
begin
  If (not Assigned(AdminSystem)) or (not AdminSystem.fdFields.fdCollect_Usage_Data) then exit;
  P := UsageList.Find( AName ) ;
  if ( P = nil ) then
  begin
    New( P ) ;
    P.Name := AName;
    P.Counter := Count;
    P.Overwrite := True;
    UsageList.Insert( P ) ;
  end
  else
    p.Counter := Count;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Set Usage Data, Name - ' + AName + ', Value - ' + inttostr(P.Counter));
end;

{ TUsageList }

procedure TUsageList.AppendTo( List: TUsageList ) ;
var
  P1, P2: pUsageStatistics;
  i: Integer;
begin
  if ItemCount > 0 then
  begin
    for i := 0 to Pred( ItemCount ) do
    begin
      P1 := pUsageStatistics( At( i ) ) ;
      P2 := List.Find( P1.Name ) ;
      if P2 = nil then
      begin
        New( P2 ) ;
        P2.Name := P1.Name;
        P2.Counter := P1.Counter;
        P2.Overwrite := False;
        List.Insert( P2 ) ;
      end
      else if P1.Overwrite then
        P2.Counter := P1.Counter
      else
        P2.Counter := P2.Counter + P1.Counter;
    end;
  end;
end;

function TUsageList.Compare( Item1, Item2: pointer ) : Integer;
begin
  result := StStrS.CompStringS( pUsageStatistics( Item1 ) ^.Name,
    pUsageStatistics( Item2 ) ^.Name ) ;
end;

function TUsageList.Find( const AName: ShortString ) : pUsageStatistics;
var
  L, H, I, C: Integer;
  P: pUsageStatistics;
begin
  result := nil;
  L := 0;
  H := Last;
  if L > H then Exit;
  repeat
    I := ( L + H ) shr 1;
    P := pUsageStatistics( At( i ) ) ;
    C := StStrS.CompStringS( AName, P^.Name ) ;
    if C > 0 then L := I + 1 else H := I - 1;
  until ( c = 0 ) or ( L > H ) ;
  if c = 0 then result := P;
end;

procedure TUsageList.ResetSubStr( const AName: ShortString );
var
  I: Integer;
  P: pUsageStatistics;
begin
  for I := 0 to Pred(ItemCount) do
  begin
    P := pUsageStatistics( At( i ) ) ;
    if Pos(AName, p^.Name) > 0 then
    begin
      P^.Overwrite := True;
      P^.Counter := 0;
    end;
  end;
end;

procedure TUsageList.FreeItem( Item: Pointer ) ;
begin
  Dispose( pUsageStatistics( Item ) ) ;
end;

//-----------------------------------------------------------------------------


const
  PracticeCodingMonths = 18;
  PracticeCodingStatPrefix = 'PCS_';

procedure UpdateSystemCounters;
const
  SCHED_REP_ID_TEXT = 'Sched Rep';
  ACCT_SYS_ID_TEXT = 'Acct System';
  ACCT_SYS_COUNT_TEXT = 'Acct System Acounts';



var
  i, ArchiveCount, ForeignCount, ManualCount, ManualAccountsTotal, MemCount,
  PayeeCount, ProspectCount, ResetCount, JobsCount, DivisionsCount: Integer;
  lMonth: TstDate;
  p: pClient_File_Rec;
  u: pUser_Rec;
  lPractice: TSystem_Coding_Statistics;
  ClientFileRec : pClient_File_Rec;
  AdminClientIndex : integer;
  NumClientDisabledSuggestedMems : integer;

    procedure WriteCodingStats(Value: pCoding_Statistics_Rec);
    var lDate: string;
       procedure AddCodingUsage(Value: Integer; Name: string);
       begin
          //if Value > 0 then
          SetUsage(Format('%s%s_%s',[PracticeCodingStatPrefix,lDate,Name]),Value);
       end;
    begin
       if not assigned(Value) then
          Exit;
       lDate := Date2Str(LMonth,'yyyy_NNN');
       AddCodingUsage(Value.csMemorization_Count,'Mem');
       AddCodingUsage(Value.csManual_Count ,'Man');
       AddCodingUsage(Value.csAnalysis_Count ,'Anl');
       AddCodingUsage(Value.csPayee_Count ,'Pay');
       AddCodingUsage(Value.csMaster_Mem_Count ,'MMem');
       AddCodingUsage(Value.csMan_Super_Count ,'Sup');
       AddCodingUsage(Value.csNotes_Count ,'Notes');
       AddCodingUsage(Value.csUncoded_Count ,'Not');

    end;

    procedure SetProvisionalClients;
    var lList: TList;
        I: Integer;

        procedure TestAccount(AccLRN: Integer);
        var map: pClient_Account_Map_Rec;
        begin
            map := AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(AccLRN);
            while assigned (map) do begin
               if lList.IndexOf(Pointer(map.amClient_LRN)) < 0 then
                  lList.Add(Pointer(map.amClient_LRN)); // Not in the list yet
               map := AdminSystem.fdSystem_Client_Account_Map.FindNextClient(AccLRN);
            end;
        end;
    begin
       lList := TList.Create;
       try
          for I := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount - 1 do
             with AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(I)^ do begin
                if sbAccount_Type <> sbtProvisional then
                   Continue;
                TestAccount(sbLRN);
             end;
          SetUsage('No of Client Files with Provisional Bank Accounts',lList.Count);
       finally
          lList.Free;
       end;
    end;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'UpdateSystemCounters Begins');
  // update admin system entries
  If (not Assigned(AdminSystem)) or (not AdminSystem.fdFields.fdCollect_Usage_Data) or
   (not Assigned(UsageList)) then exit;
  ArchiveCount := 0;
  ForeignCount := 0;
  ManualCount := 0;
  ManualAccountsTotal := 0;
  MemCount := 0;
  PayeeCount := 0;
  ProspectCount := 0;
  ResetCount := 0;
  JobsCount := 0;
  DivisionsCount := 0;

  for i := roMin to roMax do
    SetUsage(SCHED_REP_ID_TEXT + ' ' + roNames[i], 0);

  for i := srdMin to srdMax do
    SetUsage(SCHED_REP_ID_TEXT + ' ' + srdNames[i], 0);

  UsageList.ResetSubStr(ACCT_SYS_ID_TEXT);
  UsageList.ResetSubStr(ACCT_SYS_COUNT_TEXT);

  for i := 0 to Pred(AdminSystem.fdSystem_Client_File_List.ItemCount) do
  begin
    p := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);

    if p.cfArchived then
      Inc(ArchiveCount);

    if p.cfForeign_File then
      Inc(ForeignCount);

    if p.cfManual_Account_Count > 0 then
    begin
      Inc(ManualCount);
      ManualAccountsTotal := ManualAccountsTotal + p.cfManual_Account_Count;
    end;

    if p.cfMem_Count > 0 then
       Inc(MemCount);

    if p.cfPayee_Count > 0 then
       Inc(PayeeCount);

    if p.cfClient_Type = ctProspect then
       Inc(ProspectCount);

    if p.cfAccounting_System <> '' then begin
       IncUsage(ACCT_SYS_ID_TEXT + ' ' + p.cfAccounting_System, True);
       IncUsage(ACCT_SYS_COUNT_TEXT + ' ' + p.cfAccounting_System, True, P.cfBank_Account_Count  );
    end;
    if p.cfReporting_Period in [roMin..roMax] then
       IncUsage(SCHED_REP_ID_TEXT + ' ' + roNames[ p.cfReporting_Period]);
    if p.cfSchd_Rep_Method in [srdMin..srdMax] then
       IncUsage(SCHED_REP_ID_TEXT + ' ' + srdNames[ p.cfSchd_Rep_Method]);
    if p.cfJob_Count <> 0 then
       inc(JobsCount);
    if p.cfDivision_Count <> 0 then
       inc(DivisionsCount);
  end;

  // Loop through System Clients and read any mem ini settings in
  NumClientDisabledSuggestedMems := 0;
  for AdminClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
  begin
   ClientFileRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(AdminClientIndex);

   ReadMemorisationINI(ClientFileRec^.cfFile_Code);

   if MEMSINI_SupportOptions = meiDisableSuggestedMems then
     inc(NumClientDisabledSuggestedMems);
  end;

  if NumClientDisabledSuggestedMems > 0 then
   SetUsage('No of Client Files with Suggested Mems Disabled', NumClientDisabledSuggestedMems);

  SetUsage('No of Client Files', AdminSystem.fdSystem_Client_File_List.ItemCount);
  SetUsage('No of Client Files (Archived)', ArchiveCount);
  SetUsage('No of Client Files (Foreign)', ForeignCount);
  SetUsage('No of Client Files with Manual Bank Accounts', ManualCount);
  SetUsage('No of Client Files with Memorised Entries', MemCount);
  SetUsage('No of Client Files with Payees', PayeeCount);
  SetUsage('No of Client Files (Prospects)', ProspectCount);
  SetUsage('No of Actual Bank Accounts', AdminSystem.fdSystem_Bank_Account_List.ItemCount);
  SetUsage('No of Manual Bank Accounts', ManualAccountsTotal);
  SetUsage('No of Users', AdminSystem.fdSystem_User_List.ItemCount);
  SetUsage('No of Client Files with Jobs', JobsCount);
  SetUsage('No of Client Files with Divisions', DivisionsCount);
  SetUsage('No of Client Types',AdminSystem.fdSystem_Client_Type_List.ItemCount);
  SetUsage('No of Client Groups',AdminSystem.fdSystem_Group_List.ItemCount);
  if AdminSystem.DualAccountingSystem then
    SetUsage('No of Admin DualAccountingSystems',1)
  else
    SetUsage('No of Admin DualAccountingSystems',0);

  SetProvisionalClients;

  for i := 0 to Pred(AdminSystem.fdSystem_User_List.ItemCount) do
  begin
    u := AdminSystem.fdSystem_User_List.User_At(i);
    SetUsage('User ' + u.usCode + '(' + u.usName + ') Login Count', u.usLogin_Count);
    SetUsage('User ' + u.usCode + '(' + u.usName + ') Reset Count', u.usReset_Count);
    ResetCount := ResetCount + u.usReset_Count;
  end;
  SetUsage('No of User Resets', ResetCount);

  //Add The Coding Stats;
  UsageList.ResetSubStr(PracticeCodingStatPrefix);
  // Work out what dates to get;
  lPractice := CodingStatsList32.CodingStatsManager.GetPracticeStats;
  try
    lMonth := GetFirstDayOfMonth (CurrentDate);
    for I := 1 to PracticeCodingMonths do
    begin
      WriteCodingStats(lPractice.FindClientMonth(PracticeLRN, lMonth));
      LMonth := IncDate(LMonth,0,-1,0);
    end;
  finally
    lPractice.Free;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'UpdateSystemCounters Ends');
end;

procedure SaveUsage;
const
  ThisMethodName = 'UsageUtils.SaveStatistics';
var
  //LogFileName: string;
  //F: TextFile;
  FileName: string;
  Totals: TUsageList;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'SaveUsage Begins');

  UpdateSystemCounters;

  if Assigned( UsageList ) and ( UsageList.ItemCount > 0 ) then
  begin
    if not DirectoryExists(UsageDir) then
    begin
      if not CreateDir(UsageDir) then
        exit;
    end;

    //LogFileName := UsageDir + 'USAGE.LOG';
    FileLocking.ObtainLock( ltUsageStatistics, Globals.PRACINI_TicksToWaitForAdmin div 1000 ) ;
    try

      // Monthly Totals
      FileName := UsageDir + USAGE_FILE;
      Totals := TUsageList.Create;
      try
        Totals.LoadFromFile( FileName ) ;
        Totals.ResetSubStr( PracticeCodingStatPrefix); // Don't Keep any 'old' ones
        UsageList.AppendTo( Totals ) ;
        Totals.SaveToFile( FileName ) ;
      finally
        FreeAndNil( Totals ) ;
      end;

    finally
      FileLocking.ReleaseLock( ltUsageStatistics ) ;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'SaveUsage Ends');
end;

// -----------------------------------------------------------------------------

procedure TUsageList.LoadFromFile( const AFileName: string ) ;
var
  F: TextFile;
  Buffer: array[ 1..8192 ] of Byte;
  P: pUsageStatistics;
  S: string;
begin
  if FileExists( AFileName ) then
  begin
    AssignFile( F, AFileName ) ;
    SetTextBuf( F, Buffer ) ;
    Reset( F ) ;
    while not EOF( F ) do
    begin
      New( P ) ;
      Readln( F, S ) ;
      if Trim(S) = '' then Continue;
      P.Name := S;
      Readln( F, S ) ;
      P.Counter := StrToIntDef( S, 0 ) ;
      if not Assigned( Find( P.Name )) then
        Insert( P ) ;
    end;
    CloseFile( F ) ;
  end;
end;

procedure TUsageList.SaveToFile( const AFileName: string ) ;
var
  F: TextFile;
  Buffer: array[ 1..8192 ] of Byte;
  P: pUsageStatistics;
  i: Integer;
begin
  if ItemCount > 0 then
  begin
    AssignFile( F, AFileName ) ;
    SetTextBuf( F, Buffer ) ;
    Rewrite( F ) ;
    for i := 0 to Pred( ItemCount ) do
    begin
      P := pUsageStatistics( At( i ) ) ;
      if P.Counter > 0 then begin
         Writeln( F, P.Name ) ;
         Writeln( F, P.Counter ) ;
      end;
    end;
    CloseFile( F ) ;
  end;
end;

initialization
  UsageList := TUsageList.Create;
  DebugMe := DebugUnit(UnitName);
finalization
  FreeAndNil( UsageList );
end.

