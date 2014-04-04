unit Merge32;
{-----------------------------------------------------------------}
{  Handles syncronisation between the client files and the admin  }
{  system.                                                        }
{  SyncClient to Admin called when OPening or Checkin a client    }
{  SyncAdmin to CLient called when saving or Checkout a client    }
{                                                                 }
{-----------------------------------------------------------------}

interface

uses
  sydefs, clObj32;

procedure SyncClientToAdmin(aClient : TClientObj; Silent : boolean; MergeTrx : boolean = true;
  IsCheckOut: Boolean = False; IsScheduledReports: Boolean = false; AutoMerge: Boolean = false;
  UpdateStats: Boolean = True);
procedure SyncAdminToClient(AdminClientRec : pClient_File_Rec; aClient : TClientObj);

procedure RefreshContactDetails( aClient : TClientObj; pCF : pClient_File_Rec; SyncDirection : byte);

procedure StripMasterMemorised(aClient : TClientObj);
procedure SyncMasterMemorised(aClient : TclientObj);

procedure EmbedCustomLogo( aClient : TClientObj; EncodedLogo : AnsiString = '');
procedure StripCustomLogo( aClient : TClientObj);

procedure UpdateProcessingStats(aClient: TClientObj; const IncludeDownloads: Boolean; Save: Boolean = True);
procedure RefreshAllProcessingStatistics(const IncludeDownloads: Boolean; const Save: Boolean = True; const Sync: Boolean = False);
procedure UpdateSystemDownloadIndicators;

// For homepage..
function NewDataAvailable(aClient : TClientObj) : boolean;
procedure MergeNewDataYN(aClient : TClientObj; Silent : boolean; IsCheckOut: Boolean = False;
  ShowPrompt: Boolean = True; IsScheduledReports: Boolean = False);

const
  syncdir_Both = 0;
  syncdir_ClientToAdmin = 1;
  syncdir_AdminToClient = 2;

//******************************************************************************
implementation

uses
  globals,
  glConst,
  admin32,
  Files,
  GenUtils,
  YesNoDlg,
  ovcDate,
  ClientDetailCacheObj,
  baobj32,
  ArchUtil32,
  ueList32,
  LogUtil,
  sysutils,
  bktxio,
  bkdefs,
  moneydef,
  infomorefrm,
  bkConst,
  MemorisationsObj,
  BKMLIO,
  EnterPwdDlg,
  Progress,
  PracticeLogo,
  bkDateUtils,
  AutoCode32,
  baUtils,
  mxFiles32,
  ECollect,
  BaList32,
  SysObj32,
  cfList32,
  WinUtils,
  PDDates32,
  ClientCodingStatistics,
  stDate,
  CodingStatsList32,
  UsageUtils,
  AuditMgr,
  SystemMemorisationList,
  MainFrm;

const
  UnitName = 'MERGE32';
var
  DebugMe : boolean;

{------------------------------------------------------------------}

function NewDataAvailable(aClient : TClientObj) : boolean;
const
   ThisMethodName = 'NewDataAvailable';
Var
   I        : LongInt;
   pSB      : pSystem_Bank_Account_Rec;
   MaxLRN   : LongInt;
   Bank_Account : tBank_Account;
   Msg      : String;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False;
   If not (RefreshAdmin and Assigned(aClient)) then begin
      if DebugMe then begin
         Msg := 'Not RefreshAdmin and Assigned(aClient)';
         LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
      end;
      Exit;
   end;

   if aClient.clDisk_Log.ItemCount > 0 then begin
     if DebugMe then begin
        Msg := 'Cannot merge a client that has download data directly';
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
     end;
     Exit; {cannot merge a client that has received data directly}
   end;

   With aClient.clBank_Account_List do begin
     for I := 0 to Pred( itemCount ) do
     begin
       Bank_Account := Bank_Account_At( I );

       if Bank_Account.baFields.baAccount_Type <> sbtOnlineSecure  then
       begin
         With Bank_Account, baFields do begin
            if Bank_Account.IsManual then
              Continue;
            MaxLRN := baHighest_LRN;  //baTransaction_List.HighestLRN;
            pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baBank_Account_Number );
            If Assigned( pSB ) then begin
               With pSB^ do If ( sbLast_Transaction_LRN > MaxLRN ) then begin
                 Result := True;
                 exit;
               end;
            end;
         end;
       end;
     end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

{-----------------------------------------------------------------}
procedure SetEarliestDownloadDate(aClientCode: string; aAccountLRN: LongInt);
var
  ClientAccountMap: pClient_Account_Map_Rec;
  ClientFile: pClient_File_Rec;
begin
  Admin32.LoadAdminSystem( true, 'DownloadDate');
  try
  ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(aAccountLRN);
  while ClientAccountMap <> nil do begin
    ClientFile := AdminSystem.fdSystem_Client_File_List.FindLRN(ClientAccountMap.amClient_LRN);
    if (ClientFile <> nil) then
      if Uppercase(Copy(ClientFile.cfFile_Code, 1, Length(aClientCode))) = Uppercase(aClientCode) then
        ClientAccountMap.amEarliest_Download_Date := MaxInt; //Transactions are synchronised so don't need it anymore
    ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.FindNextClient(aAccountLRN);
  end;
  finally
     Admin32.SaveAdminSystem;
  end;
end;

{-----------------------------------------------------------------}
Procedure MergeNewData( aClient : TClientObj; Silent : boolean; IsScheduledReports: Boolean = False);
//ONLY called by MergeNewDataYN which prompts the user
//Admin system is refreshed by MergeNewData when NewDataAvail is called
const
   ThisMethodName = 'MergeNewData';
Var
   I           : LongInt;
   pSB         : pSystem_Bank_Account_Rec;
   psbLRN      : Integer;
   eFileName   : String;
   eFile       : File of tArchived_Transaction;
   Entry       : tArchived_Transaction;
   UEList      : tUEList;
   UE          : pUE;
   MaxLRN      : LongInt;
   FirstAdminLRN,
   L, R, M     : Longint;

   Bank_Account: TBank_Account;
   Transaction   : pTransaction_Rec;

   NoForAccount,
   NoOfEntries,
   FirstDate,
   LastDate    : integer;

   FirstDateThisAccount,
   LastDateThisAccount : integer;

   AccountPasswordOK : boolean;
   Msg               : string;
   BCode, CCode : String[3];
   Rate : Extended;

   MaintainMemScanStatus: boolean;
Begin
  if DebugMe then begin
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  end;

  try
    if Assigned(frmMain) then
    begin
      MaintainMemScanStatus := frmMain.MemScanIsBusy;
      frmMain.MemScanIsBusy := True;
      if Assigned(aClient) then
        aClient.clRecommended_Mems.RemoveAccountsFromMems;
    end;

    NoOfEntries := 0;
    FirstDate   := 0;
    LastDate    := 0;

    AccountPasswordOK := false;

    if not Silent then
       Msg := 'Importing new transactions...'
    else
       Msg := 'Merging new transactions for ' + aClient.clFields.clCode + '...';

    UpdateAppStatus( Msg,'',10);
    try
       With aClient.clBank_Account_List do
       Begin
          For I := 0 to Pred( itemCount ) do
          Begin
             Bank_Account := Bank_Account_At( I );

             if Bank_Account.baFields.baAccount_Type <> sbtOnlineSecure then
             begin
               With Bank_Account, baFields do
               Begin
                  BCode := baCurrency_Code;
                  CCode := aClient.clExtra.ceLocal_Currency_Code;

                  MaxLRN := baHighest_LRN;  //baTransaction_List.HighestLRN;
                  pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baBank_Account_Number );

                  If Assigned( pSB ) then With pSB^ do If ( sbLast_Transaction_LRN > MaxLRN ) then
                  Begin
                     psbLRN := pSB.sbLRN; // Keep this in case admin gets a refresh
                     //must test the bank account password to make sure this is not a restriced account
                     if(sbAccount_Password <> '') then
                     begin
                       //password set - test again bank account password in client
                       if baFields.baBank_Account_Password = sbAccount_Password then
                         AccountPasswordOK := true
                       else
                       begin
                         //password has changed ask user for new one
                         if EnterPassword('Update Bank Account '+ sbAccount_Number + ' '+sbAccount_Name, sbAccount_Password,0,false,true) then
                         begin
                            baFields.baBank_Account_Password := sbAccount_Password;
                            AccountPasswordOK := true
                         end
                         else
                             if not Silent then HelpfulInfomsg('Invalid Password.  Transactions for Account '+sbAccount_Number + ' '+sbAccount_Name
                                                              + ' have not been updated.',0);
                       end;
                     end
                     else
                     begin
                       //no password, clear client bank password if there was one
                       baFields.baBank_Account_Password := '';
                       AccountPasswordOK := true;
                     end;

                     //-------------------------
                     if AccountPasswordOK then
                     begin
                       // merge begins
                       //-------------------------
                       FirstDateThisAccount := 0;
                       LastDateThisAccount  := 0;
                       NoForAccount := 0;

                       if DebugMe then begin
                          Msg := 'Processing account ' + baBank_Account_Number;
                          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
                       end;

                       eFileName := ArchiveFileName( sbLRN );

                       if (not Silent) or ( DebugMe) or IsScheduledReports then begin
                          Msg := Format( 'Checking %s for %s (%s)', [ baBank_Account_Number,
                                                                      aClient.clFields.clCode,
                                                                      eFileName
                                                                     ] );
                          LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
                       end;

                       If not BKFileExists( eFileName ) then begin
                         Msg := Format('The Entry File for %s (%s) does not exist %s', [baBank_Account_Number, eFileName, aClient.clFields.clCode ] );
                         LogUtil.LogMsg(lmError,UnitName, ThisMethodName + ' : ' + Msg );
                         Raise EInOutError.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
                       end;
                       //build list of unpresented items

                         UEList    := MakeUEList( Bank_Account );

                       //begin import for archive
                       AssignFile( eFile, eFileName );
                       Reset( eFile );
                       try
                         L := 0;
                         R := FileSize( eFile )-1;
                         Repeat
                            M := ( L+R ) shr 1;
                            Seek( eFile, M );
                            Read( eFile, Entry );
                            If ( Entry.aLRN > MaxLRN ) then
                               R := M - 1
                            else
                               L := M + 1;
                         Until ( Entry.aLRN = MaxLRN ) or ( L > R );

                         Seek(eFile,M);  //make sure at last position, needed if LRN match not found
                                         //this happens when the bank account is new

                         {cycle thru importing transactions - this portion of code actually
                          updates the transaction list in the client file}

                         {a crash at this point should cause the process to halt, the client will
                          have transactions upto the last good transaction}
                         FirstAdminLRN := -1;

                         While not EOF( eFile ) do
                         Begin
                            Read( eFile, Entry );
                            With Entry do If ( aLRN > MaxLRN ) then
                            Begin
                               if FirstAdminLRN = -1 then FirstAdminLRN := aLRN;

                               //try and match a transaction
                               UE := NIL;
                               If (Assigned(UEList) and (aCheque_Number <> 0) and (aAmount <> 0)) then
                                  UE := UEList.FindUEByNumberAndAmount( aCheque_Number, aAmount );

                               //Make sure the UE item hasnt been matched since UElist was built
                               //and the presentation date is not earlier than effective date
                               if Assigned( UE) then begin
                                  if ( UE^.Presented <> 0) or
                                     ( UE^.Issued > aDate_Presented) then UE := nil;
                               end;

                               //Try to match with a UPC before importing
                               If Assigned( UE ) then With UE^ do Begin
                                  //an unpresented cheque has been found that matches
                                  //both the amount and the cheque number.
                                  //update UPC to show that has been matched
                                  ptr^.txUPI_State          := upMatchedUPC;
                                  ptr^.txDate_Presented     := aDate_Presented;
                                  UE^.Presented             := aDate_Presented;
                                  ptr^.txOriginal_Reference := aReference;
                                  ptr^.txOriginal_Source    := aSource;
                                  ptr^.txOriginal_Type      := aType;
                                  ptr^.txOriginal_Forex_Conversion_Rate    := ptr^.txForex_Conversion_Rate   ;
                                  ptr^.txOriginal_Amount                   := ptr^.txAmount;
                                  ptr^.txOriginal_Cheque_Number            := aCheque_Number;
                               end
                               else
                               Begin
                                  Transaction := baTransaction_List.New_Transaction;
                                  With Transaction^ do
                                  Begin
                                     txType               := aType;
                                     txSource             := aSource;
                                     txDate_Presented     := aDate_Presented;
                                     txDate_Effective     := aDate_Presented;
                                     txDate_Transferred   := 0;

                                     txAmount             := aAmount;

                                     txQuantity           := ForceSignToMatchAmount( aQuantity, aAmount);
                                     txCheque_Number      := aCheque_Number;
                                     txReference          := aReference;
                                     txParticulars        := aParticulars;
                                     txAnalysis           := aAnalysis;
                                     txOrigBB             := aOrigBB;
                                     txOther_Party        := aOther_Party;
                                     txGL_Narration       := aStatement_Details;
                                     txStatement_Details  := aStatement_Details;
                                     txBank_Seq           := baFields.baNumber;  //setbank account sequence no to current bank index

                                     txCore_Transaction_ID      := aCoreTransactionID;
                                     txCore_Transaction_ID_High := aCoreTransactionIDHigh;

                                     //Get extra info for Provisional transactions
                                     if (txSource = orProvisional) then
                                       SetProvisionalInfo(aLRN, txTemp_Prov_Entered_By, txTemp_Prov_Date_Time);
                                  end;
                                  baTransaction_List.Insert_Transaction_Rec( Transaction );
                                  aClient.clRecommended_Mems.UpdateCandidateMems(Transaction, True);

                                  //Flag Audit for bank account
                                  aClient.ClientAuditMgr.FlagAudit(arClientBankAccounts);
                               end;

                               If baCurrent_Balance <> Unknown then baCurrent_Balance := baCurrent_Balance + aAmount;

                               //- - - - VERY IMPORTANT - - - - - -
                               baHighest_LRN := aLRN;

                               Inc( NoOfEntries );
                               Inc( NoForAccount);

                               //update transaction date range for all accounts
                               If ( FirstDate = 0 ) or ( ( FirstDate > 0 ) and ( aDate_Presented < FirstDate ) ) then
                                  FirstDate   := ADate_Presented;

                               If ADate_Presented > LastDate then LastDate := ADate_Presented;


                               //update transaction date range for this account only
                               If (FirstDateThisAccount = 0) or ((FirstDateThisAccount>0) and (aDate_Presented < FirstDateThisAccount)) then
                                  FirstDateThisAccount := ADate_Presented;
                               If (aDate_Presented > LastDateThisAccount) then
                                  LastDateThisAccount := ADate_Presented;

                               //show progress
                               if (sbLast_Transaction_LRN - FirstAdminLRN) > 0 then
                                 UpdateAppStatusPerc_NR( (aLrn - FirstAdminLRN) / (sbLast_Transaction_LRN - FirstAdminLRN)*100);

                            end; //with Entry do
                         end; //while not EOF
                       finally
                         UEList.Free;
                         CloseFile( eFile );
                       end;

                       if ( not Silent) or DebugMe or IsScheduledReports then begin
                          Msg := Format('%s : Merged %d entries',[ThisMethodName, NoForAccount]);
                          LogUtil.LogMsg(lmInfo, UnitName, Msg);
                       end;

                       //Autocode the entries
                       if NoForAccount > 0 then begin
                          AutoCodeEntries(aClient, Bank_Account,AllEntries, FirstDateThisAccount, LastDateThisAccount);
                       end;

                       //Set Earliest Download Date in Client Account Map to MaxInt
                       SetEarliestDownloadDate(aClient.clFields.clCode, psbLRN);

                       //------------------------
                       //merge ends
                       //------------------------
                     end;
                  end;  {if pbs assigned}

               end; {with bank account}
             end;
          end;
       end; {with bank account list}
      finally
        //leave the status window up if scheduled reports in running
        if not Silent then ClearStatus;
    end;

    {report on what happened}
    if NoOfEntries > 0 then begin
       if (not Silent) or (IsScheduledReports) then begin
          Msg := Format('Imported %d transactions dated from %s to %s',
                        [ NoOfEntries, bkDate2Str( FirstDate ), bkDate2Str( LastDate ) ] );
          LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
          if not IsScheduledReports then
            HelpfulInfoMsg(SHORTAPPNAME+' ' + Msg, 0);
       end;
    end;
  finally
    if Assigned(frmMain) then
      if not MaintainMemScanStatus then
        frmMain.MemScanIsBusy := False;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
{-----------------------------------------------------------------}
procedure MergeBankBalances(aClient : TClientObj; Silent : boolean);
// transactions have been merged, so admin and client transactions
// are upto date
const
   ThisMethodName = 'MergeBankBalances';
var
  I           : LongInt;
  pSB         : pSystem_Bank_Account_Rec;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  //cycle thru each bank account in the client.  If the balance is known in the
  //admin system then put this balance into the client files bank accounts
  with aClient.clBank_Account_List, AdminSystem do begin
    for i:= 0 to pred(ItemCount) do with Bank_Account_At(i) do begin
      if (baFields.baCurrent_Balance = UNKNOWN) and (baFields.baAccount_Type = btBank) then begin
        //find the bank account in the admin system
        pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode(baFields.baBank_Account_Number );
        if Assigned( pSB ) then begin
          with pSB^ do begin
            if sbCurrent_Balance <> UNKNOWN then
              baFields.baCurrent_Balance := sbCurrent_Balance;
          end;
        end;
      end;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

{-----------------------------------------------------------------}

function CanMergeNewDataNow( Client : TClientObj ): Boolean;
Begin
  Result := False;
  if not NewDataAvailable( Client ) then
      Exit; { No new data }

  Result := not Client.clExtra.ceDeliverDataDirectToBLO;
End;

{-----------------------------------------------------------------}

procedure MergeNewDataYN(aClient : TClientObj; Silent : boolean; IsCheckOut: Boolean = False;
  ShowPrompt: Boolean = True; IsScheduledReports: Boolean = False);
var
  s: string;
//only called by SyncClientToAdmin
begin
   if NewDataAvailable( aClient )
   and CanMergeNewDataNow( aClient ) then
   begin
     if IsCheckOut then
      s := aClient.clFields.clCode + ' (' + aClient.clFields.clName + ')'
     else
      s := 'this client';
     //causes refresh of admin system
      if Silent or (not ShowPrompt) or
        ( AskYesNo('Update Client','There are new transactions available for ' + s + '.'+#13+#13+
                   'Do you want to retrieve them?',
                    DLG_YES,0) = DLG_YES ) then
      begin
         {merge data}
         MergeNewData(aClient, Silent, IsScheduledReports);
         {merge bank balances}
         MergeBankBalances(aClient,Silent);
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SyncClientToAdmin(aClient : TClientObj; Silent : Boolean; MergeTrx : boolean = true;
  IsCheckOut: Boolean = False; IsScheduledReports: Boolean = false; AutoMerge: Boolean = false;
  UpdateStats: Boolean = True);
//merge trx should only be false when we just want to update details like
//practice email, website, user email etc
const
   ThisMethodName = 'SyncClientToAdmin';
{called when Client is openned or checked-out}
var
  i : integer;
  User : pUser_Rec;
  Group: pGroup_Rec;
  ClientType: pClient_Type_Rec;
  Msg  : String;
  ba   : TBank_Account;
  sysClientRec : pClient_File_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if aClient.clFields.clFile_Read_Only then
  begin
    if (not IsScheduledReports) and UpdateStats then
      UpdateProcessingStats(aClient, False);
    Exit;
  end;

  if not (Assigned(aClient) and Assigned(AdminSystem)) then begin
    if DebugMe then begin
       Msg := 'Not Assigned(aClient) and Assigned(AdminSystem)';
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
    end;
    Exit;
  end;
  RefreshAdmin;

  if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Client Code ' + aClient.clFields.clCode);

  //check that file belongs to this admin system
  If (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) then
  Begin
     //update practice details
     with aClient.clFields, AdminSystem.fdFields do begin
        clPractice_Name          := fdPractice_Name_for_Reports;
        clPractice_EMail_Address := fdPractice_EMail_Address;
        clPractice_Web_Site      := fdPractice_Web_Site;
        clPractice_Phone         := fdPractice_Phone;

        clPractice_Code          := fdBankLink_Code;
     end;

     //other details
     aClient.clFields.clCopy_Narration_Dissection := PRACINI_CopyNarrationDissection;

     //update person responsible
     with aClient.clFields, AdminSystem.fdSystem_User_List do begin
        User := FindLRN(clStaff_Member_LRN);
        if Assigned(User) then begin
           if User^.usName <> '' then
             clStaff_Member_Name := User^.usName
           else
             clStaff_Member_Name := User^.usCode;
           clStaff_Member_EMail_Address := User^.usEMail_Address;
           clStaff_Member_Direct_Dial   := User^.usDirect_Dial;
        end
        else
        begin
           clStaff_Member_Name          := '';
           clStaff_Member_EMail_Address := '';
           clStaff_Member_Direct_Dial   := '';
        end;
     end;

     // Update group
     with aClient.clFields, AdminSystem.fdSystem_Group_List do begin
        Group := FindLRN(clGroup_LRN);
        if Assigned(Group) then
           clGroup_Name := Group^.grName
        else
           clGroup_Name := '';
     end;

     // Update client type
     with aClient.clFields, AdminSystem.fdSystem_Client_Type_List do begin
        ClientType := FindLRN(clClient_Type_LRN);
        if Assigned(ClientType) then
           clClient_Type_Name := ClientType^.ctName
        else
           clClient_Type_Name := '';
     end;

     //update TrxTyp Table if same country
     with aClient, AdminSystem do
        if ( clFields.clCountry = fdFields.fdCountry ) then
        for i := 0 to MAX_TRX_TYPE do begin
           clFields.clShort_Name[i] := fdFields.fdShort_Name[i];
           clFields.clLong_Name[i]  := fdFields.fdLong_Name[i];
        end;

     //Set expiry flag for temp accounts
     for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
     begin
       ba := aClient.clBank_Account_List.Bank_Account_At(i);
       if ba.IsManual then
          ba.baFields.baExtend_Expiry_Date := AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts]
       else
          ba.baFields.baExtend_Expiry_Date := False;
     end;

     //update system lrn
     sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( aClient.clFields.clCode);
     if assigned( sysClientRec) then
       aClient.clFields.clSystem_LRN := sysClientRec.cfLRN;

     if MergeTrx or AutoMerge then
     begin
       //Check for New Data - must belong to this admin and has data from set to dlAdminSystem}
       if (not aClient.clFields.clSuppress_Check_for_New_TXns) and
          (aClient.clFields.clDownload_From = dlAdminSystem) then
          MergeNewDataYN(aClient, Silent, IsCheckOut, not AutoMerge, IsScheduledReports);
     end;
  end;
  if (not IsScheduledReports) and UpdateStats then
    UpdateProcessingStats(aClient, False);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
{------------------------------------------------------------------------}
procedure SyncAdminToClient(AdminClientRec : pClient_File_Rec; aClient : TClientObj);
//called when client is saved
//no need to check magic number in this case because file will exist in the admin system
const
  ThisMethodName = 'SyncAdminToClient';
var
  Msg  : String;
  i, BankCount, ManualCount, MemCount: Integer;
  b: TBank_Account;

  function DivisionCount: Integer;
  var I: Integer;
  begin
     Result := 0;
     with AClient, clFields do
     for  i := 1 to glConst.Max_Divisions do
       if clCustom_Headings_List.Get_Division_Heading(i) <> '' then begin
          Inc(Result);
       end;
   end;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if aClient.clFields.clFile_Read_Only then Exit;

  if not (Assigned(aClient) and Assigned(AdminSystem)) then begin
    if DebugMe then begin
       Msg := 'Not Assigned(aClient) and Assigned(AdminSystem)';
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
    end;
    Exit;
  end;

  with AdminClientRec^, aClient.clFields do
  begin
     cfFile_Name               := clName;
     cfFile_Password           := clFile_Password;
     cfFile_Save_Count         := clFile_Save_Count;
     cfReport_Start_Date       := clReport_Start_Date;
     cfReporting_Period        := clReporting_Period;
     cfUser_Responsible        := clStaff_Member_LRN;
     cfGroup_LRN               := clGroup_LRN;
     cfClient_Type_LRN         := clClient_Type_LRN;
     cfDate_Last_Accessed      := CurrentDate;
     cfForeign_File            := ( clMagic_Number <> AdminSystem.fdFields.fdMagic_Number);
     cfFinancial_Year_Starts   := clFinancial_Year_Starts;
     cfContact_Details_To_Show := clContact_Details_To_Show;
     cfArchived                := aClient.clMoreFields.mcArchived;

     //Update the scheduled reporting destination
     if cfReporting_Period = roDontSendReports then
       cfSchd_Rep_Method     := srdNone
     else
     if clEmail_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdEmail;
       cfSchd_Rep_Method_Filter := srdEmail;
     end
     else
     if clFax_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdFax;
       cfSchd_Rep_Method_Filter := srdFax;
     end
     else
     if clECoding_Export_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdECoding;
       cfSchd_Rep_Method_Filter := srdECoding;
     end
     else
     if clCSV_Export_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdCSVExport;
       cfSchd_Rep_Method_Filter := srdCSVExport;
     end
     else
     if clWebX_Export_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdWebX;
       cfSchd_Rep_Method_Filter := srdWebX;
     end
     else
     if clCheckOut_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdCheckOut;
       cfSchd_Rep_Method_Filter := srdCheckOut;
     end
     else
     if aClient.clExtra.ceOnline_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdOnline;
       cfSchd_Rep_Method_Filter := srdOnline;
     end
     else
     if clBusiness_Products_Scheduled_Reports then
     begin
       cfSchd_Rep_Method        := srdBusinessProducts;
       cfSchd_Rep_Method_Filter := srdBusinessProducts;
     end
     else
     begin
       cfSchd_Rep_Method        := srdPrinted;
       cfSchd_Rep_Method_Filter := srdPrinted;
     end;

     //update the cache schedules reports to send setting
     cfSched_Rep_Reports_To_Send := 0;
     if cfSchd_Rep_Method <> srdNone then
     begin
       case cfSchd_Rep_Method of
         srdECoding : begin
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsCoding;

           if not clECoding_Dont_Send_Chart then
             cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsChart;

           if not clECoding_Dont_Send_Payees then
             cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsPayee;
         end;
         srdWebX : begin
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsCoding;

           if not clECoding_Dont_Send_Chart then
             cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsChart;

           if not clECoding_Dont_Send_Payees then
             cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsPayee;
         end;
         srdCSVExport : begin
           cfSched_Rep_Reports_To_Send := srsCoding;
         end;
         srdBusinessProducts: begin
           cfSched_Rep_Reports_To_Send := srsCoding;
         end;
       else
         //show selected reports when printing
         if clSend_Coding_Report then
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsCoding;

         if clSend_Chart_of_Accounts then
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsChart;

         if clSend_Payee_List then
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsPayee;

         if aClient.clExtra.ceSend_Job_List then
           cfSched_Rep_Reports_To_Send := cfSched_Rep_Reports_To_Send or srsJob;
       end;
     end;

     // update usage stats counters
     cfPayee_Count := aClient.clPayee_List.ItemCount;
     cfJob_Count :=  aClient.clJobs.ItemCount;
     cfDivision_Count := DivisionCount;
     ManualCount := 0;
     BankCount := 0;
     MemCount := 0;
     AdminSystem.ClearISOCodes(AdminClientRec);
     for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do
     begin
       b := aClient.clBank_Account_List.Bank_Account_At(i);
       AdminSystem.AddISOCode(AdminClientRec, b.baFields.baCurrency_Code);
       if b.IsManual then
         Inc(ManualCount)
       else if b.baFields.baAccount_Type = btBank then
         Inc(BankCount);
       MemCount := MemCount + b.baMemorisations_List.ItemCount;
     end;
     cfBank_Account_Count := BankCount;
     cfManual_Account_Count := ManualCount;
     cfMem_Count := MemCount;
     cfAccounting_System := aClient.clAccountingSystemName;
     cfGST_Start_Month := clGST_Start_Month;
     //for NZ copy GST Period
     //for AU find the shortest valid period between the GST Period, PAYG text withheld period and PAYG income tax period
     if clCountry = whNewZealand then
       cfGST_Period := clGST_Period
     else if clCountry = whAustralia then
     begin
       cfGST_Period := 0;
       if (clGST_Period > 0) then
         cfGST_Period := clGST_Period;
       if (clBAS_PAYG_Withheld_Period > 0) and ((cfGST_Period = 0) or (clBAS_PAYG_Withheld_Period < cfGST_Period)) then
         cfGST_Period := clBAS_PAYG_Withheld_Period;
       if (clBAS_PAYG_Instalment_Period > 0) and ((cfGST_Period = 0) or (clBAS_PAYG_Instalment_Period < cfGST_Period)) then
         cfGST_Period := clBAS_PAYG_Instalment_Period;
     end;

     //*** Flag Audit ***
     SystemAuditMgr.FlagAudit(arSystemClientFiles);
  end;

  //sync client bank accounts with admin system
  //this will not be done at the moment
  //because of the complexity involved with updating the balance when it has been
  //entered off-site ( circa 1999)

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;


{-------------------------------------------------------------------------}
procedure StripMasterMemorised(aClient : TClientObj);
const
  ThisMethodName = 'StripMasterMemorised';
var
  i : integer;
  Msg : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if not (Assigned(aClient) and Assigned(AdminSystem)) then begin
    if DebugMe then begin
       Msg := 'Not Assigned(aClient) and Assigned(AdminSystem)';
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
    end;
    Exit;
  end;

  //check that file belongs to this admin system and that download from is dlAdminSystem
  If (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) and
     (aClient.clFields.clDownload_From = dlAdminSystem) then Begin
     with aClient.clBank_Account_List do begin
        for i := 0 to Pred(itemCount) do
           Bank_Account_At(i).baMemorisations_List.DumpMasters;
     end; //with
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

{-------------------------------------------------------------------------}
procedure SyncMasterMemorised(aClient : TclientObj);
//put master memorised entries into the client file as memorised entries for
//each bank account.  entries are flaged as being master memorised and will
//always be applied last.
const
  ThisMethodName = 'SyncMasterMemorised';
var
  BankPrefix  : BankPrefixStr;
  MasterMemList : TMemorisations_List;
  i,j, M      : integer;
  MasterMemX  : TMemorisation;
  ClientMemX  : TMemorisation;
  Msg         : String;
  MasterLine, ClientLine : pMemorisation_Line_Rec;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if not (Assigned(aClient) and Assigned(AdminSystem)) then begin
    if DebugMe then begin
       Msg := 'Not Assigned(aClient) and Assigned(AdminSystem)';
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
    end;
    Exit;
  end;

  //check that file belongs to this admin system and that download from is dlAdminSystem
  //master memorised entries cannot be added to an off-site client
  If (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) and
     (aClient.clFields.clDownload_From = dlAdminSystem) then
  Begin
    with aClient.clBank_Account_List do begin
       for i := 0 to Pred(ItemCount) do with Bank_Account_At(i) do
         //add master memorised entries if the bank account is flagged to accept them
         if (baFields.baApply_Master_Memorised_Entries) then begin
           baMemorisations_List.DumpMasters;  //double check no existing entries

           BankPrefix := mxfiles32.GetBankPrefix( baFields.baBank_Account_Number);
           SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
           MasterMemList := nil;
           if Assigned(SystemMemorisation) then
             MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);

           if Assigned( MasterMemList) then begin
             for M := MasterMemList.First to MasterMemList.Last do begin
               MasterMemX  := MasterMemList.Memorisation_At(m);
               ClientMemX  := TMemorisation.Create(aClient.ClientAuditMgr);


               ClientMemX.mdFields^ := MasterMemX.mdFields^;

               for j := MasterMemX.mdLines.First to MasterMemX.mdLines.Last do
               begin
                 MasterLine  := MasterMemX.mdLines.MemorisationLine_At(j);
                 ClientLine  := BKMLIO.New_Memorisation_Line_Rec;
                 ClientLine^ := MasterLine^;
                 ClientMemX.mdLines.Insert(ClientLine)
               end;
               ClientMemX.mdFields.mdFrom_Master_List := TRUE;
               ClientMemX.mdFields.mdSequence_No := 0;
               baMemorisations_List.Insert_Memorisation(ClientMemX);
             end;
           end;
         end;
    end; //with
    aClient.clFields.clFile_Save_Required := true;  //force a save even if nothing else changed
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EmbedCustomLogo( aClient : TClientObj; EncodedLogo : AnsiString = '');
begin
  if not (Assigned(aClient) and Assigned(AdminSystem)) then
    Exit;

  //check that file belongs to this admin system
  if (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) then
  begin
    if EncodedLogo <> '' then
      aClient.clFields.clPractice_Logo := EncodedLogo
    else
      aClient.clFields.clPractice_Logo := PracticeLogo.EncodePracticeLogo( AdminSystem.fdFields.fdPractice_Logo_Filename);
    if aClient.clFields.clPractice_Logo <> '' then
      SetUsage('Practice Logo', 1);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure StripCustomLogo( aClient : TClientObj);
begin
  if not (Assigned(aClient) and Assigned(AdminSystem)) then
    Exit;

  //check that file belongs to this admin system
  if (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) then
    aClient.clFields.clPractice_Logo := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RefreshContactDetails( aClient : TClientObj; pCF : pClient_File_Rec; SyncDirection : byte);
//parameters:  aClient            Client object to use
//             pCF                Client File Rec pointer for admin system
//             SyncDirection      Direction to syncronise  both C -> A   C <- A
//
//      An admin save will be required if the direction is both or client to admin, IF details have changed
var
  ClientChanged : boolean;
  CacheChanged  : boolean;
begin
  ClientChanged := ( aClient.clFields.clContact_Details_Edit_Date > pCF^.cfContact_Details_Edit_Date) or
                   (( aClient.clFields.clContact_Details_Edit_Date = pCF^.cfContact_Details_Edit_Date) and
                    ( aClient.clFields.clContact_Details_Edit_Time > pCF^.cfContact_Details_Edit_Time)) or
                    (not ClientDetailsCache.CacheExists( pCF.cfLRN));

  CacheChanged  := ( aClient.clFields.clContact_Details_Edit_Date < pCF^.cfContact_Details_Edit_Date) or
                   (( aClient.clFields.clContact_Details_Edit_Date = pCF^.cfContact_Details_Edit_Date) and
                    ( aClient.clFields.clContact_Details_Edit_Time < pCF^.cfContact_Details_Edit_Time));

  if SyncDirection = syncDir_Both then
  begin
    if not( ClientChanged or CacheChanged) then
      exit;

    //decide which way update should occur
    if ClientChanged then
      SyncDirection := syncDir_ClientToAdmin;

    if CacheChanged then
      SyncDirection := syncDir_AdminToClient;
  end;

  if SyncDirection = syncDir_AdminToClient then
  begin
    if not CacheChanged then
      exit;

    with aClient.clFields do
    begin
      try
        ClientDetailsCache.Clear;
        if ClientDetailsCache.Load( pCF^.cfLRN) then
        begin
          clName                  := ClientDetailsCache.Name;
          clAddress_L1            := ClientDetailsCache.Address_L1;
          clAddress_L2            := ClientDetailsCache.Address_L2;
          clAddress_L3            := ClientDetailsCache.Address_L3;
          clContact_Name          := ClientDetailsCache.Contact_Name;
          clPhone_No              := ClientDetailsCache.Phone_No;
          clMobile_No             := ClientDetailsCache.Mobile_No;
          clSalutation            := ClientDetailsCache.Salutation;
          clFax_No                := ClientDetailsCache.Fax_No;
          clClient_EMail_Address  := ClientDetailsCache.Email_Address;

          clContact_Details_Edit_Date := pCF.cfContact_Details_Edit_Date;
          clContact_Details_Edit_Time := pCF.cfContact_Details_Edit_Time;

          //note: Admin save required to make sure these are commited
          LogMsg( lmInfo, Unitname, 'Contact Details updated from cache for ' + clCode);
        end;
      except
        On E : Exception do begin
          LogMsg( lmError, Unitname, 'syncDir_AdminToClient failed. [' + E.Classname + '] ' + E.Message);
        end;
      end;
    end;
  end;

  if SyncDirection = syncDir_ClientToAdmin then
  begin
    if not ClientChanged then
      exit;

    with aClient.clFields do
    begin
      try
        ClientDetailsCache.Clear;
        ClientDetailsCache.Code          := clCode;
        ClientDetailsCache.Name          := clName;
        ClientDetailsCache.Address_L1    := clAddress_L1;
        ClientDetailsCache.Address_L2    := clAddress_L2;
        ClientDetailsCache.Address_L3    := clAddress_L3;
        ClientDetailsCache.Contact_Name  := clContact_Name;
        ClientDetailsCache.Phone_No      := clPhone_No;
        ClientDetailsCache.Mobile_No     := clMobile_No;
        clientdetailsCache.Salutation    := clSalutation;
        ClientDetailsCache.Fax_No        := clFax_No;
        ClientDetailsCache.Email_Address := clClient_EMail_Address;
        ClientDetailsCache.Save( pCF.cfLRN);

        pCF.cfContact_Details_Edit_Date := clContact_Details_Edit_Date;
        pCF.cfContact_Details_Edit_Time := clContact_Details_Edit_Time;

        LogMsg( lmInfo, Unitname, 'Cached Contact Details updated for ' + clCode);
      except
        On E : Exception do begin
          LogMsg( lmError, Unitname, 'syncDir_ClientToAdmin failed. [' + E.Classname + '] ' + E.Message);
          raise;
        end;
      end;
    end;
  end;
end;                                   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateProcessingStats(aClient: TClientObj; const IncludeDownloads: Boolean; Save: Boolean = True);
var
  sysClientRec: pClient_File_Rec;
  Period: Integer;
  Y: Integer;
begin
  if not Assigned(AdminSystem) then exit;

  if Save then
    Admin32.LoadAdminSystem( true, 'UpdateProcessingStats');
  try
    sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( aClient.clFields.clCode);
    if assigned( sysClientRec) then
    begin
        CodingStatsManager.ClientSaved := False;
        AClient.clFields.clSystem_LRN := sysClientRec.cfLRN; // Have found it does not have to match at this stage...
        sysClientRec.cfLast_Processing_Status_Date := GetLastDayOfMonth(CurrentDate);
        for Y := 0 to 2 do begin

           With TClientCodingStatistics.Create( AClient, IncludeDownloads,stAll,
                 IncDate( sysClientRec.cfLast_Processing_Status_Date,0,0, Y - 2  )) do
           try
             for Period := 1 to 12 do begin
                sysClientRec.cfCoded[ Period + Y * 12] := Byte( GetCodingState( Period ) );
                sysClientRec.cfDownloaded[ Period + Y * 12] := Byte( GetDownloadedState( Period ) );
                sysClientRec.cfFinalized[ Period + Y * 12] := Byte( GetLockState( Period ) );
                sysClientRec.cfTransferred[ Period + Y * 12] := Byte( GetTransferState( Period ) );
             end;
           finally
             Free;
           end;
           CodingStatsManager.ClientSaved := True; //prevent coding stats being update 3 times           
        end;

        CodingStatsManager.SaveClientStats(AClient.clFields.clSystem_LRN);
    end;

  finally
    if Save then
      Admin32.SaveAdminSystem;
  end;
end;

procedure RefreshAllProcessingStatistics(const IncludeDownloads: Boolean; const Save: Boolean = True; const Sync: Boolean = False);
var
  i : integer;
  pCF : pClient_File_Rec;
  aClient : TClientObj;
begin
  UpdateAppStatus('Updating Processing Status', '' ,0, not ProcessMessages_On);
  try
    //Clear coding stats
    CodingStatsManager.ClearStats;

    for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
    begin
      UpdateAppStatusPerc( i / AdminSystem.fdSystem_Client_File_List.ItemCount * 100, not ProcessMessages_On);
      pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i);
      try
        OpenAClientForRead( pCF^.cfFile_Code, aClient);
        try
          if Assigned( aClient) then
          begin
            Merge32.UpdateProcessingStats(aClient, IncludeDownloads, Save);
            if Sync then
               SyncAdminToClient(pCF, aClient); //sync GST Start Date and GST Period
          end;
        finally
          FreeAndNil( aClient);
        end;
      except
      end;
    end;


  finally
    ClearStatus;
  end;
end;

procedure UpdateSystemDownloadIndicators;
var
  i, Y, Period : integer;
  YearStartDate, PeriodStartDate: integer;
  SystemClient: pClient_File_Rec;
  SystemBankAccount: pSystem_Bank_Account_Rec;
  ClientAccountMap: pClient_Account_Map_Rec;
  DateDiff, ArrayIndex: integer;
  OldProcessingStatusDate: integer;
begin
  UpdateAppStatus('Updating Download Status', '' ,0, not ProcessMessages_On);
  try
    Admin32.LoadAdminSystem( True, 'UpdateSystemDownloadIndicators');
    try
      for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do begin
        SystemBankAccount := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
        if Assigned(SystemBankAccount) then begin
          ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(SystemBankAccount.sbLRN);
          while Assigned(ClientAccountMap) do begin
            SystemClient := AdminSystem.fdSystem_Client_File_List.FindLRN(ClientAccountMap.amClient_LRN);
            if Assigned(SystemClient) then begin
              OldProcessingStatusDate := SystemClient.cfLast_Processing_Status_Date;
              SystemClient.cfLast_Processing_Status_Date := GetLastDayOfMonth(CurrentDate);

              //Adjust system client status to match current 36 month period
              DateDiff := bkDateUtils.GetMonthsBetween(OldProcessingStatusDate,
                                                       SystemClient.cfLast_Processing_Status_Date);
              for ArrayIndex := Low(SystemClient.cfDownloaded) to High(SystemClient.cfDownloaded) do begin
                if (ArrayIndex + DateDiff) < High(SystemClient.cfDownloaded) then begin
                  //Move intersection to start of array
                  SystemClient.cfCoded[ArrayIndex]       := SystemClient.cfCoded[ArrayIndex + DateDiff];
                  SystemClient.cfDownloaded[ArrayIndex]  := SystemClient.cfDownloaded[ArrayIndex + DateDiff];
                  SystemClient.cfFinalized[ArrayIndex]   := SystemClient.cfFinalized[ArrayIndex + DateDiff];
                  SystemClient.cfTransferred[ArrayIndex] := SystemClient.cfTransferred[ArrayIndex + DateDiff];
                end else begin
                  //Set rest of array to 0
                  SystemClient.cfCoded[ArrayIndex]       := 0;
                  SystemClient.cfDownloaded[ArrayIndex]  := 0;
                  SystemClient.cfFinalized[ArrayIndex]   := 0;
                  SystemClient.cfTransferred[ArrayIndex] := 0;
                end;
              end;

              SystemClient.cfLast_Processing_Status_Date := GetLastDayOfMonth(CurrentDate);
              //For each year
              for Y := 0 to 2 do begin
                YearStartDate := IncDate(SystemClient.cfLast_Processing_Status_Date, 1, 0, Y - 3);
                PeriodStartDate := YearStartDate;
                //For each month
                for Period := 1 to 12 do begin
                  //Only update the download status on download
                  //Get downloaded state from system bank accounts instead of client bank accounts
                  if (SystemBankAccount.sbNo_of_Entries_This_Month > 0) and
                     (GetFirstDayOfMonth(PeriodStartDate) >= GetFirstDayOfMonth(SystemBankAccount.sbFrom_Date_This_Month)) and
                     (GetLastDayOfMonth(PeriodStartDate)  <= GetLastDayOfMonth(SystemBankAccount.sbTo_Date_This_Month)) then begin
                    //FLAG PERIOD AS DOWNLOADED
                    //Conditions:
                    //The system bank account has new transactions in the last download
                    //and the current period is in the months between the first and last new txn dates.
                    SystemClient.cfDownloaded[ Period + Y * 12] := 1;
                  end else if (SystemClient.cfDownloaded[ Period + Y * 12] = 0) and
                              (SystemClient.cfCoded[ Period + Y * 12] = 0) and
                              (ClientAccountMap.amEarliest_Download_Date <= PeriodStartDate) and
                              (GetFirstDayOfMonth(PeriodStartDate) < GetFirstDayOfMonth(SystemBankAccount.sbFrom_Date_This_Month)) then begin
                    //FLAG PERIOD AS DOWNLOADED
                    //Conditions:
                    //The current period has no status info
                    //and the current period is after the earliest download date for the client
                    //and the current period is before the first new txn date
                    SystemClient.cfDownloaded[ Period + Y * 12] := 1;
                  end;
                  //Get first day of next month
                  PeriodStartDate := IncDate(YearStartDate, 0, Period, 0);
                end;
              end;
            end;
            ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.FindNextClient(SystemBankAccount.sbLRN);
          end;
        end;
      end;
    finally
      Admin32.SaveAdminSystem;
    end;
  finally
    ClearStatus;
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.

