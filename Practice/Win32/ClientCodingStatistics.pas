unit ClientCodingStatistics;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
interface

uses
  clObj32, baObj32, bkDateUtils, SyDefs;

// Collects data for 12 calender months based on a Last Date
// Period 0 is everyting before the 'first' month
// Period 13 is everything after the 'Last' month


const
  stFirstPeriod = 0;
  stLastPeriod  = 13;

type

  TResultType = ( rtNoData, rtFully, rtPartially, rtNone );

  TStatisticsType = (stAll, stBank, stJournal, stBlank);

  TClientCodingStatistics = class
  private
    // Fills full year of months, plus a 'Pre'year and 'Post'year period
    FCount: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FUncodes: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FUntransferred: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FTransferred: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FLocked: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FUnlocked: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FDownloaded: array[ stFirstPeriod..stLastPeriod ] of Integer;
    FFirstdate,
    FLastDate: Integer;
//    BLastDate : Integer;
    {
    FFirstUncodedate,
    FLastUncodedDate,
    FFirstCodedDate : Integer;
     }
    // -----------------
    function GetPeriod( const ADate: Integer ): Integer;
    procedure CheckIndex( const Index: Integer; const Msg: string );
    function GetResult( const ItemCount, TotalCount: Integer ): TResultType;
    function GetClientAccountMap( const ClientCode: string; AccountLRN: LongInt): pClient_Account_Map_Rec;
    procedure GetDownloadStats(const Client: TClientObj; const Account: TBank_Account);
  public
    FPEDates: TMonthEndDates;
    //property PEDates: TMonthEndDates read FPEDates write FPEDates;  // Does not work..
    constructor Create( const Client: TClientObj; const IncludeDownloads: Boolean; const Statistics:TStatisticsType = stAll; const endDate : Integer = 0 ); overload;
    constructor Create( const Client: TClientObj; const IncludeDownloads: Boolean; const Account: TBank_Account; const endDate : Integer = 0); overload;
    procedure Reset (EndDate : Integer);
    function GetLockState( const Index: Integer ): TResultType;
    function GetCodingState( const Index: Integer ): TResultType;
    function GetTransferState( const Index: Integer ): TResultType;
    function GetDownloadedState( const Index: Integer ): TResultType;    
    function NoOfEntries( const Index: Integer ): Integer;
    function NoOfCodedEntries( const Index: Integer ): Integer;
    function NoOfUncodedEntries( const Index: Integer ): Integer;
    function NoOfUnLockedEntries( const Index: Integer ): Integer;
    function NoOfTransferredEntries( const Index: Integer ): Integer;
    function NoOfEntriesReadyToTransfer( const Index: Integer ): Integer;
    function NoOfDownloadedEntries( const Index: Integer ): Integer;
    function GetDateRangeS( Const Index : Integer ): String;
    function GetPeriodStartDate( Const Index : Integer ): Integer;
    function GetPeriodEndDate( Const Index : Integer ): Integer;
    function GetDateRange( Const Index : Integer ): TDateRange;
    function GetPeriodFillColor (const index : Integer) : Integer;
    function GetPeriodText (const Index : Integer; MultiLine : Boolean = True):string;
    //function GetUncodedDateRange : TDateRange;
    //function GetCodedDateRange : TDateRange;
    procedure GetStatistics( const Client: TClientObj; const IncludeDownloads: Boolean; Statistics:TStatisticsType = stAll); overload;
    procedure GetStatistics( const Client: TClientObj; const IncludeDownloads: Boolean; const Account: TBank_Account ); overload;
  end;

implementation

uses
 SysUtils, Math, BKDefs, BkConst, StDate, BKBranding, Globals, CodingStatsList32;

{ TClientObjCodingStatistics }

constructor TClientCodingStatistics.Create( const Client: TClientObj; const IncludeDownloads: Boolean; const Statistics:TStatisticsType = stAll; const EndDate : Integer = 0);
begin
  inherited Create;
  Reset(EndDate);
  GetStatistics( Client, IncludeDownloads, Statistics);
end;

procedure TClientCodingStatistics.CheckIndex( const Index: Integer;
  const Msg: string );
begin
  Assert( ( Index >= stFirstPeriod ) and ( Index <= stLastPeriod ), Msg );
end;

constructor TClientCodingStatistics.Create( const Client: TClientObj;
  const IncludeDownloads: Boolean; const Account: TBank_Account; const EndDate : Integer = 0 );
begin
  inherited Create;
  Reset(EndDate);
  GetStatistics(Client, IncludeDownloads, Account);
end;

(*
function TClientCodingStatistics.GetCodedDateRange: TDateRange;
begin
    Result := MakeDaterange( FFirstCodedDate,FFirstUncodedate);
end;
*)
function TClientCodingStatistics.GetClientAccountMap(const ClientCode: string;
  AccountLRN: Integer): pClient_Account_Map_Rec;
var
  ClientFile: pClient_File_Rec;
  ClientAccountMap: pClient_Account_Map_Rec;
begin
  Result := nil;
  with AdminSystem.fdSystem_Client_Account_Map do begin
    ClientAccountMap := FindFirstClient(AccountLRN);
    while ClientAccountMap <> nil do begin
      ClientFile := AdminSystem.fdSystem_Client_File_List.FindLRN(ClientAccountMap.amClient_LRN);
      if (ClientFile <> nil) then
        if Uppercase(Copy(ClientFile.cfFile_Code, 1, Length(ClientCode))) = Uppercase(ClientCode) then begin
          Result := ClientAccountMap;
          Break;
        end;
      ClientAccountMap := FindNextClient(AccountLRN);
    end;
  end;
end;

function TClientCodingStatistics.GetCodingState(
  const Index: Integer ): TResultType;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetCodingState' );
  Result := GetResult( NoOfCodedEntries( Index ), FCount[ Index ] );
end;

function TClientCodingStatistics.GetLockState(
  const Index: Integer ): TResultType;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetLockState' );
  Result := GetResult( FLocked[ Index ], FCount[ Index ] );
end;

function TClientCodingStatistics.GetPeriod( const ADate: Integer ): Integer;
var
  i: Integer;
begin
  if ADate <= FPEDates[stFirstPeriod] then
     Result := stFirstPeriod
  else begin
     for i := 1 to 12 do
        if  (ADate > FPEDates[i - 1])
        and (ADate <= FPEDates[i]) then begin
           Result := i;
           exit;
        end;
     // Still here..
     Result := stLastPeriod;
  end;
end;

function TClientCodingStatistics.GetTransferState(
  const Index: Integer ): TResultType;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetTransferState' );
  Result := GetResult( FTransferred[ Index ], FCount[ Index ] );
end;

function TClientCodingStatistics.GetDownloadedState(
  const Index: Integer ): TResultType;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetDownloadedState' );
  Result := GetResult( FDownloaded[ Index ], FDownloaded[ Index ] );
end;

(*
function TClientCodingStatistics.GetUncodeddateRange: TDateRange;
begin
   Result := MakeDaterange( FFirstUncodedate,FLastUncodedDate);
end;
 *)
function TClientCodingStatistics.NoOfCodedEntries(
  const Index: Integer ): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfCodedEntries' );
  Result := FCount[ Index ] - FUncodes[ Index ];
end;

function TClientCodingStatistics.NoOfDownloadedEntries(
  const Index: Integer): Integer;
begin
   CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfCodedEntries' );
  Result := FDownloaded [ Index ];
end;

function TClientCodingStatistics.NoOfEntriesReadyToTransfer(
  const Index: Integer ): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfEntriesReadyToTransfer' );
  if FUncodes[ Index ] = 0 then
    Result := FUntransferred[ Index ]
  else
    Result := 0;
end;

function TClientCodingStatistics.NoOfUncodedEntries(
  const Index: Integer ): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfUncodedEntries' );
  Result := FUncodes[ Index ];
end;

function TClientCodingStatistics.NoOfUnLockedEntries(
  const Index: Integer): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfUnLockedEntries' );
  Result := FUnLocked[ Index ];
end;

procedure TClientCodingStatistics.Reset (EndDate : Integer);
begin
    FillChar (FCount,         Sizeof(FCount),         0);
    FillChar (FUncodes,       Sizeof(FUncodes),       0);
    FillChar (FUntransferred, Sizeof(FUntransferred), 0);
    FillChar (FTransferred,   Sizeof(FTransferred),   0);
    FillChar (FLocked,        Sizeof(FLocked),        0);
    FillChar (FUnlocked,      Sizeof(FUnlocked ),     0);
    FillChar (FDownloaded,    Sizeof(FDownloaded ),   0);
    FFirstdate := MaxInt;
    FLastDate := 0;
    FLastDate := 0;
    //FFirstUncodedate := MaxInt;
    //FFirstCodedDate := MaxInt;
    //FLastUncodedDate := 0;
    if EndDate = 0 then
       FPEDates := GetMonthEndDates(CurrentDate)
    else
       FPEDates := GetMonthEndDates(EndDate);
end;


function TClientCodingStatistics.GetResult( const ItemCount,
  TotalCount: Integer ): TResultType;
begin
  if TotalCount = 0 then
    Result := rtNoData
  else if ( ItemCount = TotalCount ) then
    Result := rtFully
  else if ( ItemCount = 0 ) then
    Result := rtNone
  else
    Result := rtPartially;
end;

function TClientCodingStatistics.NoOfTransferredEntries(
  const Index: Integer): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfTransferredEntries' );
  Result := FTransferred[ Index ];
end;

function TClientCodingStatistics.GetDateRangeS(
  const Index: Integer): String;
Var
  DR : TDateRange;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.PeriodStr' );
  DR := GetDateRange(Index);
  Result := bkDateUtils.GetDateRangeS( DR.FromDate, DR.ToDate );
end;

function TClientCodingStatistics.GetPeriodEndDate(
  const Index: Integer): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetPeriodEndDate' );
  if Index = 13 then
     Result := FLastDate
  else
     Result := FPEDates[ Index ];
end;

function TClientCodingStatistics.GetPeriodFillColor(
  const index: Integer): Integer;
begin

   CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetPeriodFillColor' );
   if FDownloaded[Index] > 0 then
      Result := bkBranding.ColorDownloaded
   else if FCount[Index] > 0 then begin
      // Have Entries...
      if FUntransferred[Index] = 0 then begin
         Result := bkBranding.ColorTransferred;  // All Transferred
         Exit;
      end;
      if FUnlocked[Index] = 0  then begin
         // All Finalised...
         Result := bkBranding.ColorFinalised;
         Exit;
      end;

      if FUncodes[Index]> 0 then
         Result := bkBranding.ColorUncoded // All i need to know
      else
      // All Coded...
         Result := bkBranding.ColorCoded
   end else
       Result := bkBranding.ColorNoData;
end;

function TClientCodingStatistics.GetPeriodStartDate(
  const Index: Integer): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetPeriodStartDate' );
  if Index = stFirstPeriod then
     Result := FFirstdate
  else
     Result := FPEDates[ Index - 1 ] + 1;
end;

function TClientCodingStatistics.GetPeriodText(const Index: Integer;
  MultiLine: Boolean): string;
begin
  Result := '';
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetPeriodText' );

  if FCount[Index] > 0 then begin
      // Have Entries...
      if FUntransferred[Index] = 0 then begin
         Result := 'All Transferred';  // All Transferred
         Exit;
      end;
      if FUnlocked[Index] = 0  then begin
         // All Finalised...
         Result := 'All Finalised';
         Exit;
      end;

      if FUncodes[Index]> 0 then begin
         if NoOfCodedEntries(Index) = 0 then
           Result := 'All Uncoded'
         else begin
           Result := 'Uncoded: ' + intToStr(NoOfUncodedEntries (Index));
           if MultiLine then
              Result := Result + #10;

           Result := Result + ('Coded: ' + intToStr(NoOfCodedEntries (Index)));
        end
      end else
      // All Coded...
         Result := 'All Coded'

   end
   else if FDownloaded[Index] > 0 then
      Result := 'Downloaded';
  // Else No Entries....
end;

function TClientCodingStatistics.NoOfEntries(
  const Index: Integer): Integer;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.NoOfEntries' );
  Result := FCount[ Index ];
end;

procedure TClientCodingStatistics.GetStatistics(const Client: TClientObj;const IncludeDownloads: Boolean;Statistics:TStatisticsType = stAll);
Var
  i : Integer;
begin
  if Statistics <> stBlank then

  for i := Client.clBank_Account_List.First to Client.clBank_Account_List.Last do
    case Statistics of
       stAll: GetStatistics( Client, IncludeDownloads, Client.clBank_Account_List.Bank_Account_At( i ) );
       stBank: if not (Client.clBank_Account_List.Bank_Account_At( i ).IsAJournalAccount) then
                   GetStatistics( Client, IncludeDownloads, Client.clBank_Account_List.Bank_Account_At( i ) );
       stJournal: if (Client.clBank_Account_List.Bank_Account_At( i ).IsAJournalAccount) then
                   GetStatistics( Client, IncludeDownloads, Client.clBank_Account_List.Bank_Account_At( i ) );
    end;


end;

// Work out if the given account has transactions downloaded into the archive but
// not yet imported into the client file
(*
procedure TClientCodingStatistics.GetDownloadStats(const Client: TClientObj; const IncludeDownloads: Boolean; const Account: TBank_Account);
var
  P: Integer;
  I, L, R, M, MaxLRN: LongInt;
  pSB: pSystem_Bank_Account_Rec;
  eFileName: string;
  eFile: File of tArchived_Transaction;
  Entry: tArchived_Transaction;
  SavedFileMode: Byte;
begin
  if (not Assigned(AdminSystem))
  or (not Assigned(Account))
  or (Account.baFields.baAccount_Type <> btBank) then
     Exit;
  // Open everything read-only - safer!
  if Client.clFields.clSuppress_Check_for_New_TXns then
     Exit;
  SavedFileMode := FileMode;
  FileMode := fmOpenRead;
  try
     with Account, baFields do
     begin
        MaxLRN := baHighest_LRN;
        pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baBank_Account_Number );
        if Assigned( pSB ) then With pSB^ do if ( sbLast_Transaction_LRN > MaxLRN ) then
        begin // system bank account has a higher LRN than client bank account
           eFileName := ArchiveFileName( sbLRN );
           If not BKFileExists( eFileName ) then exit; // broken archive?
           //open the archive file

           AssignFile( eFile, eFileName );
           System.Reset( eFile );

           try
             L := 0;
             R := FileSize(eFile)-1;
             repeat // find the entry up to which we have imported
                M := (L+R) shr 1;
                Seek(eFile, M);
                Read(eFile, Entry);
                If (Entry.aLRN > MaxLRN) then
                   R := M - 1
                else
                   L := M + 1;
             until (Entry.aLRN = MaxLRN) or (L > R);
             Seek(eFile,M);  //make sure at last position, needed if LRN match not found
                             //this happens when the bank account is new

             while not EOF(eFile) do // now check all un-imported entries
             begin
                Read(eFile, Entry);
                with Entry do
                  if (aLRN > MaxLRN) then
                  begin
                    P := GetPeriod(aDate_Presented);
                    Inc(FDownloaded[p]);
                  end; //with Entry do
             end; //while not EOF
           finally
             CloseFile(eFile);

           end;
        end;  {if pbs assigned}
     end; {with bank account}

  finally
    FileMode := SavedFileMode;
  end;
end;
 *)

procedure TClientCodingStatistics.GetDownloadStats(const Client: TClientObj;  const Account: TBank_Account);
var
  i: integer;
  MaxLRN: LongInt;
  pSB: pSystem_Bank_Account_Rec;
  pCAM: pClient_Account_Map_Rec;
  cbaLastPresentDate: LongInt;
  cbaEarliestDownloadPeriod: Integer;
  cbaStartPeriod: Integer;
  sbaStartPeriod: Integer;
  ClientBankAccount: TBank_Account;
begin
  {$B-}
  if (not Assigned(AdminSystem))
  or (not Assigned(Account))
  or (Account.baFields.baAccount_Type <> btBank) then
    Exit;

  if Client.clFields.clSuppress_Check_for_New_TXns then
    Exit;

  if Client.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number then
    Exit;  //Case #9341

  with Account, baFields do begin
    MaxLRN := baHighest_LRN;
    pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode(baBank_Account_Number);
    if Assigned(pSB) then begin
      with pSB^ do begin
        // System bank account has a higher LRN than client bank account
        if (sbLast_Transaction_LRN > MaxLRN) then begin

          // Get last presented date from client bank account
          cbaLastPresentDate := 0;
          ClientBankAccount := Client.clBank_Account_List.FindCode(baBank_Account_Number);
          if Assigned(ClientBankAccount) then
            cbaLastPresentDate := ClientBankAccount.baTransaction_List.LastPresDate;

          if cbaLastPresentDate > 0 then begin
            cbaStartPeriod := GetPeriod(cbaLastPresentDate) + 1;
            //Get Client Account Map
            pCAM := GetClientAccountMap(Client.clFields.clCode, pSB^.sbLRN);
            if pCAM <> nil then begin
              cbaEarliestDownloadPeriod := GetPeriod(pCAM^.amEarliest_Download_Date);
              if (cbaEarliestDownloadPeriod < cbaStartPeriod) then
                cbaStartPeriod := cbaEarliestDownloadPeriod;
            end;
          end else
            // No data retrieved so use first available date from system bank account
            cbaStartPeriod := GetPeriod(pSB^.sbFirst_Available_Date);

          // Find the last downloaded date
          sbaStartPeriod := GetPeriod(sbLast_Entry_Date);
          if sbaStartPeriod >= cbaStartPeriod then begin
            //There is more than one period available
            for i := cbaStartPeriod to sbaStartPeriod do
              Inc(FDownloaded[i])
          end else begin
            //We Know we have new data in this month...
            Inc(FDownloaded[sbaStartPeriod]);
          end;
        end;
      end;
    end; //System Bank account
  end;
end;


procedure TClientCodingStatistics.GetStatistics( const Client: TClientObj;
  const IncludeDownloads: Boolean; const Account: TBank_Account );
Var
  T  : Integer;

  procedure GetTransStats (Transaction: pTransaction_Rec);
  var Dissection: pDissection_Rec;
      P: Integer;
  begin
     FFirstDate := Min (FFirstDate, Transaction.txDate_Effective);
     FLastDate  := Max (FLastDate,  Transaction.txDate_Effective);
//     BLastDate  := Max (BLastDate,  Transaction.txDate_Effective);
     P := GetPeriod( Transaction.txDate_Effective );
     Inc(FCount[p]);
     if (Transaction.txDate_Transferred = 0) then begin
        // Not Transfered..
        Inc(FUnTransferred[P]);
        if Transaction.txLocked then begin
           // Locked..
           Inc(FLocked[p]);
           // Add The locked disections
           (*
           Dissection := Transaction.txFirst_Dissection;
           while Dissection <> nil do begin
              Inc(FCount[p]);
              Inc(FLocked[p]);
              Dissection := Dissection.dsNext;
           end;
           *)
        end else begin
           //
           Inc(FUnlocked[p]);
           // Now Check what is coded..
           Dissection := Transaction.txFirst_Dissection;
           if Dissection = nil then begin
              if Client.clChart.FindCode( Transaction.txAccount ) = nil then begin
                 Inc(FUncodes[p]);
                 //FFirstUncodeDate := Min ( FFirstUncodeDate, Transaction.txDate_Effective);
                 //FLastUncodedDate := Max ( FLastUncodedDate, Transaction.txDate_Effective);
              end else begin
                 //FFirstCodedDate := Min ( FFirstCodedDate, Transaction.txDate_Effective);
              end;
           end else begin
              repeat
                //check the dissections instead...
                //Inc(FCount[p]);
                if Client.clChart.FindCode( Dissection.dsAccount ) = nil then begin
                   Inc(FUncodes[p]);
                   Exit; // One is enough
                   //FFirstUncodeDate := Min ( FFirstUncodeDate, Transaction.txDate_Effective);
                   //FLastUncodedDate := Max ( FLastUncodedDate, Transaction.txDate_Effective);
                end else begin
                   //FFirstCodedDate := Min ( FFirstCodedDate, Transaction.txDate_Effective);
                end;
                Dissection := Dissection.dsNext;
              until Dissection = nil;
              // Still here .. all Coded...
           end;
        end
     end else begin
        Inc(FTransferred[p]);
        Inc(FLocked[p]); // Inferred
        // Add the Transfered Disections..
        Dissection := Transaction.txFirst_Dissection;
        while Dissection <> nil do begin
           Inc(FCount[p]);
           Inc(FTransferred[p]);
           Inc(FLocked[p]); // This blows-out the lock count But have to stay in step with Fcount
           Dissection := Dissection.dsNext;
        end;
     end;
  end;




Begin // Per account
   if Account.baFields.baAccount_Type = btStockBalances then exit;
//   BLastDate := 0;
   if Account.baTransaction_List.ItemCount > 0 then
      for T := Account.baTransaction_List.First to Account.baTransaction_List.Last do begin
         GetTransStats(Account.baTransaction_List.Transaction_At( T ));

         if Account.baFields.baAccount_Type = btBank then
         if not CodingStatsManager.ClientSaved then
           CodingStatsManager.UpdateClientStats(Client.clFields.clSystem_LRN,
                                                Account.baTransaction_List.Transaction_At(T));
      end;
   GetDownloadStats(Client, Account);
end;

function TClientCodingStatistics.GetDateRange(const Index: Integer): TDateRange;
begin
  CheckIndex( Index, 'Index out of range in TClientObjCodingStatistics.GetDateRange' );
  case Index of
  stFirstPeriod :  Result := MakeDateRange( FFirstDate, FPEDates[ stFirstPeriod] );
  stLastPeriod : Result := MakeDateRange( FPEDates[ stLastPeriod - 1 ] + 1, FLastDate );
  else Result := MakeDateRange( FPEDates[ Index - 1 ] + 1, FPEDates[ Index ] );
  end;
end;


end.

