unit CodingStatsList32;
//------------------------------------------------------------------------------
//  Title:   Coding Statistics List
//
//  Written: Oct 2009
//
//  Authors: Scott Wilson
//
//  Purpose: Creates a binary tree for acessing monthly coding statistics.
//
//  Notes:  TStTree was used because searching it is more efficient than
//          using TExtdSortedCollection.
//------------------------------------------------------------------------------
interface

uses
  StTree, Classes, csDefs, ioStream, sysUtils, clObj32, BKDefs;

type
  TSystem_Coding_Statistics = class(TObject)
  private
    FCodingStatsTree: TStTree;
  public
    constructor Create;
    destructor Destroy; override;
    function Coding_Stat_At(Index: LongInt): pCoding_Statistics_Rec;
    function FindClientMonth(AClientLRN: integer; AMonth: integer): pCoding_Statistics_Rec;
    function Insert(AClientLRN, AMonth: integer): pCoding_Statistics_Rec;
    procedure Delete(ACodingStatRec: pCoding_Statistics_Rec);
    procedure GetPracticeCounts(APracticeStats: TSystem_Coding_Statistics);
    procedure SaveToStream(var S: TIOStream); overload;
    procedure SaveToCSV(AFileName: string); overload;
    procedure LoadFromStream(var S: TIOStream);
    procedure ClearUpdateFlags;
    property StatTree: TStTree read FCodingStatsTree;
  end;

  TCodingStatsManager = class(TObject)
  private
    FTempClientStats: TSystem_Coding_Statistics;
    FSavedClientStats: TSystem_Coding_Statistics;// The one saved to the DB
    FClientSaved: boolean;
    FStatFields: tCoding_Stat_Fields_Rec;
    FLastReadVersion: Integer;
    FLocked: Boolean;
    procedure SetClientSaved(const Value: boolean);
    procedure ReadFromFile;
    procedure LoadFromStream(var S: TIOStream);
    procedure SaveToFile;
    function Lock: Boolean;
    function LockAndLoad(const KeepLock: Boolean = False): Boolean;
    function Save(const WasLocked: Boolean = True): Boolean; // Should only save if WasLocked..
    function UnLock: Boolean;
    function GetSavedClientStats: TSystem_Coding_Statistics;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveClientStats(AClientLRN: integer);//Updates the Temp Client to the saved Clients
    function GetPracticeStats: TSystem_Coding_Statistics;
    procedure ClearStats;
    procedure UpdateClientStats(AClientLRN: integer; ATxn: pTransaction_Rec);
    property ClientStats: TSystem_Coding_Statistics read GetSavedClientStats;
    property ClientSaved: boolean read FClientSaved write SetClientSaved;
    procedure Refresh;
  end;

  function CodingStatsManager: TCodingStatsManager;

const
   PracticeLRN = 0; // The practice count is treated like any client.


implementation

uses
  CSsfIO, LockUtils,
  SYDEFS, Admin32, Globals, bkConst, stBase, CScsIO, Tokens, malloc, LogUtil,
  BKDbExcept, BKDateUtils, BAObj32, CRCFileUtils, WinUtils;

const
  DEBUG_ME : Boolean = False;
  UNIT_NAME = 'CodingStatsList32';
  CODING_STATS_FILENAME = 'CodingStats.db';


var
  _CodingStatsManager: TCodingStatsManager;

function CodingStatsManager: TCodingStatsManager;
begin
  if not Assigned(_CodingStatsManager) then
    _CodingStatsManager := TCodingStatsManager.Create;
  Result := _CodingStatsManager
end;

function CodingStatCompare(Item1, Item2: Pointer): integer;
var
  CodingStat1, CodingStat2: TCoding_Statistics_Rec;
begin
  CodingStat1 := TCoding_Statistics_Rec(Item1^);
  CodingStat2 := TCoding_Statistics_Rec(Item2^);
  Result := (CodingStat1.csClient_LRN - CodingStat2.csClient_LRN);
  if Result = 0 then
    Result := (CodingStat1.csMonth - CodingStat2.csMonth);
end;

procedure CodingStatFree(Item: Pointer);
begin
  CSCSIO.Free_Coding_Statistics_Rec_Dynamic_Fields(pCoding_Statistics_Rec(Item)^);
  SafeFreeMem(Item, Coding_Statistics_Rec_Size);
end;

{ TSystem_Coding_Statistics }

procedure TSystem_Coding_Statistics.ClearUpdateFlags;
var
  TN: TstTreeNode;
  CS: pCoding_Statistics_Rec;
begin
  TN := FCodingStatsTree.First;
  while TN <> nil do begin
    CS := pCoding_Statistics_Rec(TN.Data);
    if Assigned(CS) then
      CS^.csUpdated := False;
    TN := FCodingStatsTree.Next(TN);
  end;
end;

function TSystem_Coding_Statistics.Coding_Stat_At(
  Index: Integer): pCoding_Statistics_Rec;
begin
  Result := nil;
  inherited;
end;

constructor TSystem_Coding_Statistics.Create;
begin
  FCodingStatsTree := TStTree.Create(TStTreeNode);
  FCodingStatsTree.Compare := CodingStatCompare;
  FCodingStatsTree.DisposeData := CodingStatFree;
end;

procedure TSystem_Coding_Statistics.Delete(ACodingStatRec: pCoding_Statistics_Rec);
var
  TN: TstTreeNode;
begin
  TN := FCodingStatsTree.Find(ACodingStatRec);
  if (TN <> nil) then
    FCodingStatsTree.Delete(ACodingStatRec);
end;

destructor TSystem_Coding_Statistics.Destroy;
begin
  FCodingStatsTree.Free;
end;

function TSystem_Coding_Statistics.FindClientMonth(AClientLRN,
  AMonth: integer): pCoding_Statistics_Rec;
var
  CodingStat: TCoding_Statistics_Rec;
  TreeNode: TStTreeNode;
begin
  Result := nil;
  CodingStat.csClient_LRN := AClientLRN;
  CodingStat.csMonth := AMonth;
  TreeNode := FCodingStatsTree.Find(@CodingStat);
  if (TreeNode <> nil) then
    Result := pCoding_Statistics_Rec(TreeNode.Data);
end;

function GetPracCounts(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  CS, PS: pCoding_Statistics_Rec;
  PracticeStats: TSystem_Coding_Statistics;
  ClientRec: pClient_File_Rec;
begin
   Result := True;
   CS := pCoding_Statistics_Rec(Node.Data);
   PracticeStats := TSystem_Coding_Statistics(OtherData^);

   // Check if it is (still) relevant for the practice...
   ClientRec := AdminSystem.fdSystem_Client_File_List.FindLRN(CS^.csClient_LRN);
   if Assigned(ClientRec) then begin
      if ClientRec.cfForeign_File
      or ClientRec.cfArchived then
         Exit;

   end else
      Exit;// What does this mean ?? No longer in the Admin system..

   PS := PracticeStats.FindClientMonth(PracticeLRN, CS^.csMonth);
   if (PS = nil) then
     PS := PracticeStats.Insert(PracticeLRN, CS^.csMonth);
   //Check if updated
   PS^.csUpdated := (PS^.csUpdated or CS^.csUpdated);
   //Inc counts
   Inc(PS.csMemorization_Count, CS.csMemorization_Count);
   Inc(PS.csManual_Count, CS.csManual_Count);
   Inc(PS.csPayee_Count, CS.csPayee_Count);
   Inc(PS.csAnalysis_Count, CS.csAnalysis_Count);
   Inc(PS.csUncoded_Count, CS.csUncoded_Count);
   Inc(PS.csMaster_Mem_Count, CS.csMaster_Mem_Count);
   Inc(PS.csMan_Super_Count, CS.csMan_Super_Count);
   Inc(PS.csNotes_Count, CS.csNotes_Count);
end;

procedure TSystem_Coding_Statistics.GetPracticeCounts(APracticeStats: TSystem_Coding_Statistics);
begin
  //Update from client stats
  FCodingStatsTree.Iterate(GetPracCounts, True, @APracticeStats);
end;

function TSystem_Coding_Statistics.Insert(AClientLRN,
  AMonth: integer): pCoding_Statistics_Rec;
var
  pCodingStat: pCoding_Statistics_Rec;
  TN: TstTreeNode;
begin
  pCodingStat := New_Coding_Statistics_Rec;
  pCodingStat^.csClient_LRN := AClientLRN;
  pCodingStat^.csMonth := AMonth;
  pCodingStat^.csUpdated := False;
  TN := FCodingStatsTree.Find(pCodingStat);
  if (TN = nil) then begin
    //New
    FCodingStatsTree.Insert(pCodingStat);
    Result := pCodingStat;
  end else begin
    //Existing
    Result := pCoding_Statistics_Rec(TN.Data);
    Dispose(pCodingStat);
  end;
end;

procedure TSystem_Coding_Statistics.LoadFromStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TSystem_Coding_Statistics.LoadFromFile';
var
  Token: Byte;
  CS: pCoding_Statistics_Rec;
  Msg: string;
  ClientRec: pClient_File_Rec;
begin
  FCodingStatsTree.Clear;
  Token := S.ReadToken;
  while (Token <> tkEndSection) do
  begin
    case Token of
      tkBegin_Coding_Statistics:
        begin
          SafeGetMem(CS, Coding_Statistics_Rec_Size );
          if not Assigned(CS) then
          begin
            Msg := Format( '%s : Unable to Allocate CS',[THIS_METHOD_NAME]);
            LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
            raise EInsufficientMemory.CreateFmt( '%s - %s', [UNIT_NAME, Msg] );
          end;
          Read_Coding_Statistics_Rec (CS^, S);
          //Check that client still exists
          ClientRec := AdminSystem.fdSystem_Client_File_List.FindLRN(CS^.csClient_LRN);
          if Assigned(ClientRec) then
            FCodingStatsTree.Insert(CS);
        end;
      else
        begin { Should never happen }
          Msg := Format( '%s : Unknown Token %d', [ THIS_METHOD_NAME, Token ] );
          LogUtil.LogMsg(lmError, UNIT_NAME, Msg );
          raise ETokenException.CreateFmt( '%s - %s', [ UNIT_NAME, Msg ] );
        end;
      end; { of Case }
    Token := S.ReadToken;
  end;
end;

function SaveToTextFile(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  FileStream: TFileStream;
  CS: pCoding_Statistics_Rec;
  TempStr: string;
  ClientCode: string;
  ClientFileRec: pClient_File_Rec;
begin
  FileStream := TFileStream(OtherData^);
  CS := pCoding_Statistics_Rec(Node.Data);

  if CS^.csClient_LRN = PracticeLRN then
    ClientCode := '-PRACTICE-'
  else begin
    ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindLRN(CS^.csClient_LRN);
    if Assigned(ClientFileRec) then
      ClientCode := ClientFileRec^.cfFile_Code
    else
      ClientCode := Format('-LRN(%d)-',[CS^.csClient_LRN]);
  end;

  if CS^.csUpdated then
    TempStr := '*' + ClientCode + ','
  else
    TempStr := ClientCode + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := bkDate2Str(CS^.csMonth) + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := 'UNCODED=' + IntToStr(CS^.csUncoded_Count) + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := 'MANUAL=' + IntToStr(CS^.csManual_Count) + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := 'MEM=' + IntToStr(CS^.csMemorization_Count) + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := 'ANALYSIS=' + IntToStr(CS^.csAnalysis_Count) + ',';
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  TempStr := 'PAYEE=' + IntToStr(CS^.csPayee_Count) + #13#10;
  FileStream.WriteBuffer(PChar(TempStr)^, Length(TempStr));
  Result := True;
end;

procedure TSystem_Coding_Statistics.SaveToCSV(AFileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(AFileName, fmCreate or fmOpenReadWrite);
  try
    FCodingStatsTree.Iterate(SaveToTextFile, True, @FileStream);
  finally
    FileStream.Free;
  end;
end;

function WriteCodingStats(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  S: TIOStream;
  CS: pCoding_Statistics_Rec;
begin
  S := TIOStream(OtherData^);
  CS := pCoding_Statistics_Rec(Node.Data);
  CSCSIO.Write_Coding_Statistics_Rec(CS^, S);
  Result := True;
end;

procedure TSystem_Coding_Statistics.SaveToStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TSystem_Coding_Statistics.SaveToStream';
begin
  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  S.WriteToken(tkBeginCoding_Stats_List);
  FCodingStatsTree.Iterate(WriteCodingStats, True, @S);
  S.WriteToken(tkEndSection);

  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends' );
end;


{ TCodingStatsManager }

procedure TCodingStatsManager.ClearStats;
begin
  FTempClientStats.FCodingStatsTree.Clear;
end;

function CloneStatRec(AStatRec: pCoding_Statistics_Rec): pCoding_Statistics_Rec;
begin
  Result := nil;
  if Assigned(AStatRec) then begin
    Result := New_Coding_Statistics_Rec;
    Result^.csClient_LRN := AStatRec^.csClient_LRN;
    Result^.csMonth := AStatRec^.csMonth;
    Result^.csAnalysis_Count := AStatRec^.csAnalysis_Count;
    Result^.csManual_Count := AStatRec^.csManual_Count;
    Result^.csMemorization_Count := AStatRec^.csMemorization_Count;
    Result^.csPayee_Count := AStatRec^.csPayee_Count;
    Result^.csUncoded_Count := AStatRec^.csUncoded_Count;
    Result^.csMaster_Mem_Count := AStatRec^.csMaster_Mem_Count;
    Result^.csMan_Super_Count := AStatRec^.csMan_Super_Count;
    Result^.csNotes_Count := AStatRec^.csNotes_Count;
    Result^.csUpdated := AStatRec^.csUpdated;
  end;
end;


constructor TCodingStatsManager.Create;
begin
  FillChar(FStatFields,SizeOf(FStatFields),0);
  FStatFields.sfRecord_Type := tkBegin_Coding_Stat_Fields;
  FStatFields.sfEOR  := tkEnd_Coding_Stat_Fields;

  FSavedClientStats := TSystem_Coding_Statistics.Create;
  FTempClientStats := TSystem_Coding_Statistics.Create;
  FLastReadVersion := 0;
end;

destructor TCodingStatsManager.Destroy;
begin
  FTempClientStats.Free;
  FSavedClientStats.Free;
  inherited;
end;

function TCodingStatsManager.GetPracticeStats:TSystem_Coding_Statistics;

begin
  Result := TSystem_Coding_Statistics.Create;

  LockAndLoad;

  FSavedClientStats.GetPracticeCounts(Result);
  //Result.SaveToCSV('PracCodingStats.txt');

  //Clear update flags
  //Not Realy relevant at this stage...
  //FSavedClientStats.ClearUpdateFlags;

  //FSavedClientStats.SaveToCSV('ClientCodingStats.txt');
end;

function TCodingStatsManager.GetSavedClientStats: TSystem_Coding_Statistics;
begin
  Result :=  FSavedClientStats;
end;

procedure TCodingStatsManager.LoadFromStream(var S: TIOStream);
const THIS_METHOD_NAME = 'TSystem_Coding_Statistics.LoadFromStream';
var  Token: Byte;
begin
   // Asumes The position is Set..
   while  S.Position < S.Size do begin //First version did not have endsection

      Token := S.ReadToken;
      case Token of
         tkBegin_Coding_Stat_Fields : begin
              Read_Coding_Stat_Fields_Rec (FStatFields, S);
              if FLastReadVersion = fStatFields.sfRead_Version then begin
                 if DEBUG_ME then
                    LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Same');
                 Exit; // No Change... Im Done
              end else begin
                 FLastReadVersion := fStatFields.sfRead_Version;
                 if DEBUG_ME then
                    LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' FullRead');
              end;
           end;
        tkBeginCoding_Stats_List : FSavedClientStats.LoadFromStream(S);
        tkEndSection: Break;
     end;
   end;
end;

procedure TCodingStatsManager.ReadFromFile;
var
  S: TIOStream;
  CRC: LongInt;
begin
  if BKFileExists(Datadir + CODING_STATS_FILENAME) then begin
     S := TIOStream.Create;
     try
        S.LoadFromFile(DataDir + CODING_STATS_FILENAME);
        CheckEmbeddedCRC(S);
        S.Position := 0;
        S.Read(CRC, Sizeof(LongInt));
        LoadFromStream(S);
     finally
       S.Free;
     end;
     // Handle any uprades..
     if fStatFields.sfFile_Version < CS_FILE_VERSION then begin
        fStatFields.sfFile_Version := CS_FILE_VERSION;
     end;

  end;
end;

procedure TCodingStatsManager.Refresh;
begin
   Lockandload;
end;

function TCodingStatsManager.Lock: Boolean;
begin
   Assert(not FLocked, 'Coding Stats already locked');
   FLocked := LockUtils.ObtainLock(ltCodingStats,PRACINI_TicksToWaitForAdmin div 1000);
   Result := FLocked;
end;

function TCodingStatsManager.LockAndLoad(const KeepLock: Boolean = False): Boolean;
const
  THIS_METHOD_NAME = 'TSystem_Coding_Statistics.LockAndLoad';
begin
  Result := false;
  if DEBUG_ME then
     LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  if Lock then
  begin
    try
      try
        ReadFromFile;
        Result := True;
      except
        UnLock;
      end;
    finally
      if (FLocked) and (not KeepLock) then
        UnLock;
    end;
  end;

  if DEBUG_ME then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;

function CountsMatch(Rec1, Rec2: pCoding_Statistics_Rec): Boolean;
begin
  Result := False;
  if (Rec1^.csMemorization_Count <> Rec2^.csMemorization_Count) then
     Exit;

  if (Rec1^.csManual_Count <> Rec2^.csManual_Count) then
     Exit;

  if (Rec1^.csPayee_Count <> Rec2^.csPayee_Count) then
     Exit;

  if (Rec1^.csAnalysis_Count <> Rec2^.csAnalysis_Count) then
     Exit;

  if (Rec1^.csUncoded_Count <> Rec2^.csUncoded_Count) then
     Exit;

  if (Rec1^.csMan_Super_Count <> Rec2^.csMan_Super_Count) then
     Exit;

  if (Rec1^.csMaster_Mem_Count <> Rec2^.csMaster_Mem_Count) then
     Exit;

  if (Rec1^.csNotes_Count <> Rec2^.csNotes_Count) then
     Exit;


  Result := True;
end;

procedure TCodingStatsManager.SaveToFile;
var
  S: TIOStream;
  L: LongInt;
begin
  //Delete old stats
  if BKFileExists(DataDir + CODING_STATS_FILENAME) then
     SysUtils.DeleteFile(DataDir + CODING_STATS_FILENAME);
  //Write out new stats
  S := TIOStream.Create;
  try
    L := 0;
    S.Write(L, Sizeof(LongInt)); //Leave space for the CRC
    // Write the fields first..
    // So they get read first
    Write_Coding_Stat_Fields_Rec (FStatFields,S);


    FSavedClientStats.SaveToStream(S);

    S.WriteToken(tkEndSection);

    EmbedCRC(S);
    S.SaveToFile(DataDir + CODING_STATS_FILENAME);
  finally
    S.Free;
  end;
end;

function TCodingStatsManager.Save(const WasLocked: Boolean = True): Boolean;
const
  THIS_METHOD_NAME = 'TSystem_Coding_Statistics.Save';
begin
  if DEBUG_ME then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  Result := False;
  // Check The Locking...
  if not Waslocked then
    if not Lock then
      Exit;

  try
    // Update the Stat fields
    {$Q-}
    repeat
      Inc(fStatFields.sfRead_Version);
    until fStatFields.sfRead_Version <> 0;
    {$Q+}
    FLastReadVersion := fStatFields.sfRead_Version;
    fStatFields.sfFile_Version := CS_FILE_VERSION;

    SaveToFile;
  finally
    if not Waslocked then
      Result := Unlock;
  end;

  if DEBUG_ME then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;


type
  PSaveClientRec = ^SaveClientRec;
  SaveClientRec = record
     ClLRN: Integer;
     ClChanged: Boolean;
  end;

function SaveClientCodingStats(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  TempCS, SaveCS: pCoding_Statistics_Rec;
  ClientRec: PSaveClientRec;
begin
  TempCS := pCoding_Statistics_Rec(Node.Data);
  ClientRec := PSaveClientRec(OtherData);
  if (TempCS.csClient_LRN = ClientRec.ClLRN) then begin
    //Matches, need to copy to saveble

    SaveCS := CodingStatsManager.FSavedClientStats.FindClientMonth(ClientRec.ClLRN, TempCS^.csMonth);
    //if not exists
    if Assigned(SaveCS) then begin
       if not CountsMatch(TempCS, SaveCS) then begin
          //Update counts
          SaveCS.csMemorization_Count  := TempCS.csMemorization_Count;
          SaveCS.csManual_Count        := TempCS.csManual_Count;
          SaveCS.csPayee_Count         := TempCS.csPayee_Count;
          SaveCS.csAnalysis_Count      := TempCS.csAnalysis_Count;
          SaveCS.csUncoded_Count       := TempCS.csUncoded_Count;
          SaveCS.csMaster_Mem_Count    := TempCS.csMaster_Mem_Count;
          SaveCS.csMan_Super_Count     := TempCS.csMan_Super_Count;
          SaveCS.csNotes_Count         := TempCS.csNotes_Count;

          SaveCS.csUpdated := True;
          ClientRec.ClChanged := True;

       end;
    end else begin
       //Insert
       SaveCS := CloneStatRec(TempCS);
       SaveCS.csUpdated := True;
       CodingStatsManager.FSavedClientStats.FCodingStatsTree.Insert(SaveCS);
       ClientRec.ClChanged := True;
    end;
  end;
  Result := True;
end;


procedure TCodingStatsManager.SaveClientStats(AClientLRN: integer);
var ClientRec: SaveClientRec;
begin
  ClientRec.ClLRN := AClientLRN;
  ClientRec.ClChanged := False;

  if LockAndLoad(True) then
  begin
    try
      FTempClientStats.FCodingStatsTree.Iterate(SaveClientCodingStats, True, @ClientRec);

      if ClientRec.ClChanged then
        Save(true);
    finally
      UnLock;
    end;
  end;
  // Should not have to do this here
  FTempClientStats.FCodingStatsTree.Clear;
end;

procedure TCodingStatsManager.SetClientSaved(const Value: boolean);
begin
   FClientSaved := Value;
end;

function TCodingStatsManager.UnLock :Boolean;
begin
  Assert(FLocked, 'Coding Stats not locked');
  FLocked := not LockUtils.ReleaseLock(ltCodingStats);
  Result := FLocked;
end;

procedure TCodingStatsManager.UpdateClientStats(AClientLRN: integer;
  ATxn: pTransaction_Rec);
var
  MonthDate: Integer;
  pCS: pCoding_Statistics_Rec;
begin
  //Get Month
  MonthDate := GetFirstDayOfMonth(ATxn.txDate_Effective);
  //Get CodingStatRec
  pCS := FTempClientStats.FindClientMonth(AClientLRN, MonthDate);
  if (pCS = nil) then
    pCS :=FTempClientStats.Insert(AClientLRN, MonthDate);
  //Update count
  case ATxn.txCoded_By  of
    cbNotCoded            : Inc(pCS.csUncoded_Count);
    cbManual              : Inc(pCS.csManual_Count);
    cbMemorisedC          : Inc(pCS.csMemorization_Count);
    cbAnalysis            : Inc(pCS.csAnalysis_Count);
    cbManualPayee         : Inc(pCS.csPayee_Count);
    cbAutoPayee           : Inc(pCS.csPayee_Count);
    cbMemorisedM          : Inc(pCS.csMaster_Mem_Count);
    cbECodingManual       : Inc(pCS.csNotes_Count);
    cbECodingManualPayee  : Inc(pCS.csNotes_Count);
    cbCodeIT              : Inc(pCS.csManual_Count);
    cbManualSuper         : Inc(pCS.csMan_Super_Count);
    //cbImported            : (Not used)
  end;
end;

initialization
  _CodingStatsManager := nil;
   DEBUG_ME := LogUtil.DebugUnit(UNIT_NAME);
finalization
  if Assigned(_CodingStatsManager) then
    _CodingStatsManager.Free
end.
