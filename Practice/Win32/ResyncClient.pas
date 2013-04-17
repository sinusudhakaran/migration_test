unit ResyncClient;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Purpose: Resynchronises an offsite of foreign client file with the admin system.
           This allows the client to retreive transactions from the current admin system.


  Process:                      
  ------------

  Verify client file:

  Allow the user to select a client file to resync.  The client file should have
  been checked in.

  A valid file  1) belongs to another practice
                2) belongs to this practice but is an offsite client
                3) belongs to another practice and is an offsite client

  Check if the client file can be resynchronised to the admin system.  This requires
  that the date of last transaction in each bank account is less than or equal to the
  last date of transactions in the admin system.

  ** if not the client file has later transactions resync would cause duplicate
     transactions when new data is downloaded into the admin system


  Verify dates:

  For each bank account in the client file

         check that date of last BANK trx in client account is <= date of last trx for all
                                                             accounts in admin system

  If the client has later transactions than the admin system the client CANNOT be Resync'ed

  Load transactions from admin system
  --------------------------------

  Create a bank account list and the create bank account objects for each account.
  Load the transactions from the archive into the transaction list for each.

  Use the txTemp_Admin_LRN to store the LRN no of the trx in the archive.


  Begin Matching transactions

  The goal is to find the last transaction in the admin system that is in the clients
  bank account so that we can set the LRN in the clients bank account

  To do this we need find the last presentation date in the client BA trx's and look
  at all trx's on that date ( including UPI's that have been matched ).

  ** ALL BANK ACCOUNTS MUST BE REsynchronISED BEFORE THE CLIENT CAN BE REsynchronISED

  The reason for using the presentation date is that trx's could have been matched against
  an unpresented item.


  The safest way to match the transactions is to get the user to choose the first new trx
  in the admin system.  The will be presented with a list of transactions from the
  client bank accounts and a list from the admin system bank account.

  The list of transactions from the admin system will comprise of transactions on the
  last presentation date.


  Automatic matches of bank account can occur if

  1) There are no trx in the admin bank account on the last presentation date in the
     client.  Set the LRN to the trx before the trx on the next day.

  2) If the client bank account does not have any transactions

  3) If the bank account does not exist in the admin system

  4) All "n" client trxs on the pres date can be matched against the first "n"
     admin system trx.

  5) if same number of trx of the last presentation date for both admin and client,
     and all amounts can be matched.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   clObj32;

   procedure ReSyncAClient(aClient: TClientObj);
   procedure ReSyncClientAccountMap(aClient: TClientObj);

   procedure AdoptAClient( aClient : tClientObj);        {mjch #1724}
//******************************************************************************
implementation

uses
  Forms,
  LogUtil,
  bkConst,
  Globals,
  baList32,
  trxList32,
  sydefs,
  bkdefs,
  bktxio,
  baObj32,
  archUtil32,
  sysUtils,
  ResyncDlg,
  bkDateUtils,
  Progress,
  Merge32,
  YesNoDlg,
  bk5Except,
  WinUtils,
  EnterPwdDlg,
  syamio,
  BankLinkOnlineServices,
  BlopiServiceFacade,
  ErrorMoreFrm;

const
   UnitName = 'RESYNCCLIENT';
var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LoadAdminTransactions( aBankAccount : TBank_Account;
                                 PresDate : integer;
                                 AdminLRN : integer): Boolean;
// Returns True if there are any transactions
const
   ThisMethodName = 'LoadAdminTransactions';
Var
   ArchiveName : String;
   ArchiveFile : File of tArchived_Transaction;
   T           : tArchived_Transaction;
   TrxDate     : integer;
   NoTrx       : integer;
   Transaction : pTransaction_Rec;
   Msg         : string;

   TempLRN     : integer; //stores the number of the last admin trx before the pres date

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False; // No transactions;
   ArchiveName := ArchiveFileName( AdminLRN );
   TempLRN := 0;

   If not BKFileExists( ArchiveName ) then begin
      Msg := Format('The Entry File for %s (%s) does not exist', [ aBankAccount.baFields.baBank_Account_Number,
                                                                   ArchiveName ] );
      LogUtil.LogMsg(lmError,UnitName, ThisMethodName + ' : ' + Msg );
      Raise EInOutError.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

   Assignfile(ArchiveFile,ArchiveName);
   Reset(ArchiveFile);
   try
     NoTrx := FileSize(ArchiveFile);

     If NoTrx > 0 then Begin
        Seek( ArchiveFile, 0 );
        Result := True; // We must have some.
        repeat
           Read( ArchiveFile, T );
           TrxDate := T.aDate_Presented;

           if ( TrxDate = PresDate ) then begin
              //found a transaction to add to the transaction list
              Transaction := aBankAccount.baTransaction_List.New_Transaction;
              With Transaction^, T do
              Begin
                 txTemp_Admin_LRN     := aLrn;
                 txType               := aType;
                 txSource             := aSource;
                 txDate_Presented     := aDate_Presented;
                 txDate_Effective     := aDate_Presented;
                 txDate_Transferred   := 0;
                 txAmount             := aAmount;
                 txQuantity           := aQuantity;
                 txCheque_Number      := aCheque_Number;
                 txReference          := aReference;
                 txParticulars        := aParticulars;
                 txAnalysis           := aAnalysis;
                 txOrigBB             := aOrigBB;
                 txOther_Party        := aOther_Party;
                 txStatement_Details  := aStatement_Details;
                 txBank_Seq           := aBankAccount.baFields.baNumber;  //setbank account sequence no to current bank index
                 txMatched_In_Resync  := false;
              end;
              aBankAccount.baTransaction_List.Insert_Transaction_Rec( Transaction, False );
           end
           else begin
              //if trxDate before PresDate, store LRN.
              //Need to test that trxDate is less than PresDate because it may
              //still have been read in above even though trxDate > PresDate
              if TrxDate < PresDate then
                 TempLRN := T.aLRN;
           end;
        until ( EOF( ArchiveFile ) or ( TrxDate > PresDate ));
     end;
   finally
     CloseFile(ArchiveFile);
   end;

   if aBankAccount.baTransaction_List.ItemCount = 0 then begin
      //no transactions found on the specified date, or the day after
      //so should store the LRN of the last trx before the pres date
      //any new transactions will appear after that.
      aBankAccount.baFields.baTemp_Resync_LRN := TempLRN;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MatchClientToAdmin( Client            : TClientObj;
                             ClientBankAccount : TBank_Account;
                             AdminBankAccount  : TBank_Account;

                             AccountSeqNo      : integer;
                             MaxAccounts       : integer;
                             ClientCode        : string) : boolean;
const
   ThisMethodName = 'MatchClientToAdmin';
var
   i,j           : integer;
   TempTransList : TTransaction_List;
   Transaction   : pTransaction_rec;
   TrxMatched    : boolean;

   AdminTrx      : pTransaction_Rec;
   ClientTrx     : pTransaction_Rec;

   NoClientTrxToMatch : integer;
   NoClientTrxMatched : integer;
   LastMatchedLRN     : integer;
   UserSelectedLRN    : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   result := false;
   ClientBankAccount.baFields.baTemp_Resync_LRN := -1;

   //try to automatch account... if can't then user will have to choose
   LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName+' Matching ' +
                      ClientBankAccount.baFields.baBank_Account_Number+' '+
                      ' on '+bkdate2Str(ClientBankAccount.baFields.baTemp_Resync_Date));


   //no admin bank account which matches client account
   if not Assigned(AdminBankAccount) then begin
      ClientBankAccount.baFields.baTemp_Resync_LRN := 0;
      result := true;

      LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName+' '+
                          'LRN = 0 No matching Admin Account ');
      exit;
   end;

   //no transactions in the clients bank account yet
   if ClientBankAccount.baTransaction_List.ItemCount = 0 then begin
      ClientBankAccount.baFields.baTemp_Resync_LRN := 0;
      result := true;

      LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName+' ' +
                          'LRN = 0 No Client transactions');
      exit;
   end;

   //no admin transactions on the date or the day after
   //use the LRN of the last transaction in the admin system on the date before.
   //this value was stored when the admin bank account trx list was built
   if AdminBankAccount.baTransaction_List.ItemCount = 0 then begin
      ClientBankAccount.baFields.baTemp_Resync_LRN := AdminBankAccount.baFields.baTemp_Resync_LRN;
      result := true;

      LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName+' ' +
                      'LRN = 0 No Admin transactions for date');
      exit;
   end;

   //Build temporary transaction list of client transactions on the pres date only
   //Temp resync date is set for all accounts before calling this routine
   TempTransList := TTransaction_List.Create( Client, ClientBankAccount, NIL );
   try
      for i := 0 to Pred ( ClientBankAccount.baTransaction_List.ItemCount ) do begin
         Transaction := ClientBankAccount.baTransaction_List.Transaction_At(i);

         if ( Transaction^.txDate_Presented = ClientBankAccount.baFields.baTemp_Resync_Date ) then begin
            Transaction^.txMatched_In_Resync := false;
            TempTransList.Insert_Transaction_Rec(Transaction, False);
         end;
      end;

      if ( AdminBankAccount.baTransaction_List.ItemCount <= TempTransList.ItemCount ) then begin
         //if admin system has equal or less no of transactions then can assume that
         //all transactions from the admin system for that day already appear in the
         //client account
         //may have more transactions in the client account if transaction has been
         //split into a transaction and a UPI
         //Set LRN to the LRN of the last admin trx
         with AdminBankAccount.baTransaction_List do
            ClientBankAccount.baFields.baTemp_Resync_LRN := Transaction_At(ItemCount-1)^.txTemp_Admin_LRN;

         result := true;

         LogUtil.LogMsg( lmDebug, UnitName,
               Format ( '%s LRN = %d Admin Trx ItemCount (%d) <= Client Trx Item Count (%d)',
                         [ ThisMethodName,
                           ClientBankAccount.baFields.baTemp_Resync_LRN,
                           AdminBankAccount.baTransaction_List.ItemCount,
                           TempTransList.ItemCount ]));
         exit;
      end;

      //Admin transaction count >= Client transaction count

      //different number of transactions, try to match all of the client trx's
      //step through the admin trx and try to match each with a client trx
      //stop matching when unable to match a trx
      //test if all the client trx has been matched.  if yes then auto match succesful
      //otherwise auto match failed .. prompt user to select first new trx
      //
      //most common case for auto match failing would be a split UPI, or the trx
      //amount has been edited

      NoClientTrxToMatch := TempTransList.ItemCount;
      NoClientTrxMatched := 0;
      LastMatchedLRN     := 0;

      for i := 0 to Pred( AdminBankAccount.baTransaction_List.ItemCount ) do begin
         trxMatched := false;

         AdminTrx := AdminBankAccount.baTransaction_List.Transaction_At(i);

         for j := 0 to Pred( TempTransList.ItemCount ) do begin
            ClientTrx := TempTransList.Transaction_At(j);

            if not ClientTrx.txMatched_In_Resync then //not already matched
               if ClientTrx.txAmount = AdminTrx.txAmount then begin
                  TrxMatched := true;

                  ClientTrx.txMatched_In_Resync := true;  //so can't match twice
                  Inc( NoClientTrxMatched );
                  LastMatchedLRN  := AdminTrx^.txTemp_Admin_LRN;
               end;
         end;

         //check to see if have matched all client trx's
         if ( not trxMatched ) or ( NoClientTrxMatched = NoClientTrxToMatch ) then
            break;
      end;

      if ( NoClientTrxMatched = NoClientTrxToMatch) then begin
         //matched all of the client trx with admin trx so automatch was sucessful
         //set the clients last LRN to the Last Matched LRN
         ClientBankAccount.baFields.baTemp_Resync_LRN := LastMatchedLRN;
         result := true;

            LogUtil.LogMsg(lmDebug, UnitName,
               Format( '%s LRN = %d Auto matched all entries in client account (%d) with Admin entries (%d)',
                        [ ThisMethodName,
                          ClientBankAccount.baFields.baTemp_Resync_LRN,
                          TempTransList.ItemCount,
                          AdminBankAccount.baTransaction_List.ItemCount ]));
         exit;
      end
      else begin
         LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Auto match failed');
      end;

      //can't do it - get the user to do the rest
      ClearStatus;
      with TDlgResync.Create(Application.MainForm) do begin
         try
            AdminTransList  := AdminBankAccount.baTransaction_List;
            ClientTransList := TempTransList;
            lblClient.caption := 'Clients Bank Account :  ' +
                                  ClientBankAccount.baFields.baBank_Account_Number+' '+
                                  ClientBankAccount.baFields.baBank_Account_Name;
            AccountNo      := ClientBankAccount.baFields.baBank_Account_Number;
            lblBanner.caption := Format( 'Synchronising Client %s  Account %d of %d',
                                         [ ClientCode, AccountSeqNo+1, MaxAccounts+1 ]);


            UserSelectedLRN := GetLastLRN;

            if ( UserSelectedLRN <> -1 ) then begin  //user selected a match
               ClientBankAccount.baFields.baTemp_Resync_LRN := UserSelectedLRN;
               result := true;

                  LogUtil.LogMsg( lmDebug, UnitName, Format( '%s LRN = %d User Selected',
                                [ ThisMethodName, ClientBankAccount.baFields.baTemp_Resync_LRN ]));
            end;
         finally
            Free;
         end;
      end;
   finally
      TempTransList.DeleteAll;   //delete pointers, don't free trx's
      TempTransList.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ResyncClientDetails(aClient : TclientObj);
const
   ThisMethodName = 'ResyncClientDetails';
var
   s : string;
begin
   ClearStatus;

   s := 'Client File '+ aClient.clFields.clCode +' synchronised';
   //fix offsite status if was offsite as well
   if aClient.clFields.clDownload_From <> dlAdminSystem then begin
      aClient.clFields.clDownload_From := dlAdminSystem;
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Clearing Disk Log');
      aClient.clDisk_Log.DeleteAll;
   end;

   //adopt the client if is a foreign client
   if ( aClient.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number ) then
   begin
      //clear user responsible, otherwise file will be unknown
      aClient.clFields.clStaff_Member_LRN := 0;
      //#1725 - always resync to practice details
      aClient.clFields.clContact_Details_To_Show := cdtPractice;
      aClient.clFields.clMagic_Number := AdminSystem.fdFields.fdMagic_Number;
      s := 'Client File '+ aClient.clFields.clCode +' adopted and syncd';
   end;

   //set check for transactions back on
   aClient.clFields.clSuppress_Check_for_New_TXns := false;

   aClient.clFields.clExclude_From_Scheduled_Reports := '';

   LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' '+S);

   //merge any new transactions
   SyncClientToAdmin( aClient, false );
end;

procedure ReSyncClientAccountMap(aClient: TClientObj);
var
   pS: pSystem_Bank_Account_Rec;
   pM: pClient_Account_Map_Rec;
   pF: pClient_File_Rec;
   i: Integer;
begin
   //update client account map
   pF := AdminSystem.fdSystem_Client_File_List.FindCode(aClient.clFields.clCode);
   if Assigned(pF) then begin
      for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do begin
         // Check if Client has a Sytem account number
         pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(
            aClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
         if Assigned(pS) // we have one, and No Mapitem for it
         and (not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, pF.cfLRN))) then begin
            pM := New_Client_Account_Map_Rec;
            if Assigned(pM) then begin
               pM.amClient_LRN := pF.cfLRN;
               pM.amAccount_LRN := pS.sbLRN;
               pM.amLast_Date_Printed := 0;
               AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
               // Whilew we are here..
               pS.sbAttach_Required := False; // attched now
            end;
         end;
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReSyncAClient( aClient : TClientObj );
//resynchronised the LRN's for each bank accounts with the archive files
//resets the client details to download from the admin system
const
   ThisMethodName = 'ResyncClient';
var
   AccountsMatchedOK: boolean;
   AdminAccountsList: TBank_Account_List;
   AdminBankAccount: TBank_Account;
   AdminHasTrx: boolean;
   AdminLastTrxDate: integer;
   BankAccountExistsInAdmin: boolean;
   ClientBankAccount: TBank_Account;
   ClientHasTrx: boolean;
   ClientLastTrxDate: integer;
   i: integer;
   Msg: string;
   NewBankAccount: TBank_Account;
   OkToResync: boolean;
   pSB: pSystem_Bank_Account_Rec;
   CatEntry: TBloCatalogueEntry;
   ClientReadDetail : TBloClientReadDetail;
   Index: Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //verify file is ok to resync  - offsite or foreign
   okToResync := false;

   //offsite file
   if ( aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number ) then
   begin
      if ( aClient.clFields.clDownload_From <> dlAdminSystem ) then begin
         if aClient.clDisk_Log.ItemCount < 1 then
           Msg := 'No Off-site downloads have been done for this Client File, '+
                  'therefore you do not need to synchronise it.  Instead edit the '+
                  'Client Details for this Client and clear the Off-site Client setting.'
         else
           OkToResync := true; //client is offsite and downloads have been done
      end
      else
         Msg := 'You cannot synchronise this Client File.'#13#13+
                'Only Off-site files or files from another Admin System can be synchronised.';
   end
   else
     //is a foreign file, can be sync'd
     okToResync := true;

   if OkToResync then begin
      //verify the dates for each bank account in the client file against the admin system
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Verify Dates');

      AdminLastTrxDate := 0;
      with AdminSystem.fdSystem_Bank_Account_List do for i := 0 to Pred(ItemCount) do begin
         with System_Bank_Account_At(i)^ do begin
            if sbAccount_Type = sbtOffsite then Continue;
            if ( sbLast_Entry_Date > AdminLastTrxDate ) then
               AdminLastTrxDate := sbLast_Entry_Date;
         end;
      end;

      // *** Clearing Banklink Online details before syncing client (start) ***
      // Changing the web export format (if necessary)
      if aClient.clFields.clWeb_Export_Format = wfWebNotes then
      begin
        aClient.clFields.clWeb_Export_Format := wfNone;
        
        ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);

        if Assigned(ClientReadDetail) then
        begin
          try
            // Get client list
            if ProductConfigService.UpdateClientNotesOption(ClientReadDetail, wfNone) then
            begin
              aClient.clFields.clWeb_Export_Format := wfNone;
            end
            else
            begin
              HelpfulErrorMsg('Client banklink online web export format could not be reset to none', 0);
            end;
          finally
            ClientReadDetail.Free;
          end;
        end
        else
        //Make sure we clear the extra cached settings as well
        if MyClient.clExtra.ceOnlineValuesStored then
        begin
          for Index := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
          begin
            MyClient.clExtra.ceOnlineSubscription[Index] := '';
          end;

          MyClient.clExtra.ceOnlineValuesStored := False;
        end;
        // *** Clearing Banklink Online details before syncing client (end) ***
      end;
      
      ClientLastTrxDate := 0;
      BankAccountExistsInAdmin := False;
      with aClient.clBank_Account_List do for i := 0 to Pred(ItemCount) do begin
         with Bank_Account_At(i) do
         begin
            //we need to check the date of the last transaction for delivered
            //accounts to make sure data has not already be downloaded into the
            //client file that would be redownloaded after a resync
            if (not IsAJournalAccount)
            and (not IsManual) then
            begin
              baFields.baTemp_Resync_Date := baTransaction_List.LastPresDate;
              if ( baFields.baTemp_Resync_Date > ClientLastTrxDate ) then
                 ClientLastTrxDate := baFields.baTemp_Resync_Date;

              //see if account exists in the admin system
              pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number );
              if pSB = nil then
              begin
                if debugMe then
                  LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Account not found in admin system ' + baFields.baBank_account_number);
              end else
                if not pSB.sbMark_As_Deleted then
                  BankAccountExistsInAdmin := True;
            end;
         end;
      end;

      if ( ClientLastTrxDate > AdminLastTrxDate ) then begin
         Msg := 'The Client File cannot be synchronised because: '#13#13+

                'The date of the last Transaction in the client file is greater than '+
                'the date of the last Transaction downloaded into the Admin System.'#13#13+

                'The Admin System MUST contain the latest '+SHORTAPPNAME+' transactions '+
                'before you can synchronise a Client File.  Failure to do this may '+
                'result in duplicated transactions in the Client File.';
         OkToResync := false;
      end;

      //The client file must contain at least one bank account that matches
      //a 'live' account in the admin syetem. If there are no matching accounts
      //then the user is prompted for a support pass code to continue. This
      //gives support a chance to check the attached bank accounts and determine
      //if there could be duplicate entries if the corresponding account is
      //added to the admin system
      if OkToResync and (not BankAccountExistsInAdmin) then
      begin
        if ( AskYesNo( 'Synchronise', 'None of the accounts in this client file '+
                        'exist in your Admin System. You must contact support to proceed. '+ #13#13 +
                        'Are you sure that you want to synchronise this file?',
                        DLG_NO, 0) <> DLG_YES) or
            ( not EnterPwdDlg.EnterPassword( 'Synchronise Client File',
                                             aClient.clFields.clCode,
                                             0,        //help context
                                             True,     //requires support code
                                             False)    //hidden
                                             )
        then
        begin
          raise EResyncAbandoned.Create('The Client File contains accounts that are not in the admin system');
        end;
      end;
   end;


   //Not OK to Resync.  Show warning message and log to log file
   if not OkToResync then begin
      raise EReSyncFailed.Create(Msg);
   end;

   //check for case where client file has no bank accounts, or all bank accounts
   //are empty
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Verify Client has Accounts and Trx');

   ClientHasTrx := false;
   with aClient.clBank_Account_List do
      for i := 0 to Pred( ItemCount ) do with Bank_Account_At(i) do
         if baTransaction_List.ItemCount > 0 then begin
            ClientHasTrx := true;
            break;
         end;

   if not ClientHasTrx then begin
      //*** special case: client either has no bank accounts or all bank accounts are empty
      //make sure that LRN's are zero for any accounts that do exist
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Special Case ClientHasTrx = false');

      for i := 0 to pred( aClient.clBank_Account_List.ItemCount ) do begin
         aClient.clBank_Account_List.Bank_Account_At(i).baFields.baHighest_LRN := 0;
      end;

      // Reset attached flag if bank account is in client but has no txns in the client
      with aClient.clBank_Account_List do
        for i := 0 to Pred(ItemCount) do
        begin
          with Bank_Account_At(i) do
          begin
            //check that bank account exists in admin system
            pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number );
            if pSB <> nil then
              pSB.sbAttach_Required := False;
          end;
        end;
      ReSyncClientAccountMap(aClient);
      ResyncClientDetails(aClient);
      exit;
   end;

   UpdateAppStatus('Synchronising Client','Loading Transactions',10);

                   // **************************************
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //Client file is ok to resync now load transactions from the admin system into a
   //temporary bank account list
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Build Admin System Accounts List');
   AdminAccountsList := TBank_Account_List.Create(nil, nil);
   try
      AdminHasTrx := True;
      with aClient.clBank_Account_List do for i := 0 to Pred(ItemCount) do begin
         with Bank_Account_At(i) do begin
            //check that bank account exists in admin system
            pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number );
            if pSB <> nil then
            begin
               if not(psb.sbAccount_Type in [sbtData, sbtProvisional]) then
                  Continue;

               //account exists in client and admin so load details
               NewBankAccount := TBank_Account.Create(aClient);

               with NewBankAccount, baFields, pSb^ do begin
                  baAccount_Type         := btBank;
                  baBank_Account_Number  := sbAccount_Number;
                  baBank_Account_Name    := sbAccount_Name;
                  sbAttach_Required      := False;
                  baCurrency_Code        := sbCurrency_Code;
//                  baClient               := aClient;
               end;

               AdminAccountsList.Insert(NewBankAccount);

               //load the transactions for each of the accounts
               if not LoadAdminTransactions(NewBankAccount, baFields.baTemp_Resync_Date, pSB^.sbLRN) then
                  AdminHasTrx := False; // There is an account whithout transactions

            end;
         end;
      end;

      if (not AdminHasTrx) then begin
        if (AskYesNo('Synchronise', 'There are no transactions in one or more ' +
                     'of the matching Admin System accounts for this Client File. ' +
                     'This may result in duplicate transactions after the next ' +
                     'download. You must contact support to proceed. '+ #13#13 +
                     'Are you sure that you want to synchronise this file?',
                     DLG_NO, 0) <> DLG_YES) or
           (not EnterPwdDlg.EnterPassword('Synchronise Client File',
                                          aClient.clFields.clCode,
                                          0, True, False)) then
        begin
          ClearStatus(True);
          raise EResyncAbandoned.Create('No transactions in one or more of the matching Admin System accounts');
        end;
      end;

                   // **************************************
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //BEGIN SYNCHRONISING THE ACCOUNTS
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' synchronise Accounts');

      if AdminAccountsList.ItemCount = 0 then begin
         //****  special case: none of the clients bank accounts exist in the admin system
         //   so set LRN to 0 for all of the clients bank accounts, no matching is required
         if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Special Case - no matching admin accounts');

         Msg := 'No Admin Accounts match Client Accounts - Setting LRNs to 0';
         LogUtil.LogMsg( lmInfo, UnitName, Msg );

         with aClient.clBank_Account_List do for i := 0 to Pred(ItemCount) do begin
            with Bank_Account_At(i) do begin
               baFields.baHighest_LRN := 0;
            end;
         end;

         ResyncClientDetails(aClient);
      end
      else begin
         //accounts exist now need to sync each account
         //must synchronise all accounts for this client
         UpdateAppStatusLine2('Processing Accounts');

         AccountsMatchedOK := false;
         with aClient.clBank_Account_List do for i := 0 to Pred(ItemCount) do begin
            UpdateAppStatusPerc ( i/itemCount * 100);

            ClientBankAccount := Bank_Account_At(i);
            AdminBankAccount := AdminAccountsList.FindCode(ClientBankAccount.baFields.baBank_Account_Number);

            //journals don't need to be synch'ed  (FB939)
            if (( ClientBankAccount.IsAJournalAccount) or (ClientBankAccount.IsManual))
            and ( AdminBankAccount = nil) then
              AccountsMatchedOK := true
            else
              AccountsMatchedOK := MatchClientToAdmin( aClient, ClientBankAccount, AdminBankAccount,
                                                     i, Pred( ItemCount ), aClient.clFields.clCode );

            if not AccountsMatchedOK then begin
               LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Failed to Sync '+
                                       ClientBankAccount.baFields.baBank_Account_Number );
               break;
            end;
         end;

         if AccountsMatchedOK then begin
            //All matched ok so now update the LRN's
            with aClient.clBank_Account_List do for i := 0 to Pred( ItemCount ) do
               with Bank_Account_At(i).baFields do
                  if baTemp_Resync_LRN <> -1 then begin
                     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Sync OK '+
                                       baBank_Account_Number+ ' LRN = '+inttostr( baTemp_Resync_LRN ));

                     baHighest_LRN := baTemp_Resync_LRN;
                  end;

            ResyncClientDetails(aClient);
         end
         else begin
            raise EResyncFailed.Create( 'This Client File cannot be synchronised with the Admin System.'#13#13+
                             SHORTAPPNAME+' was unable to synchronise all of the '+
                             'Bank Accounts attached to this Client File. ');
         end;
      end;
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ReSyncClientAccountMap(aClient);

   finally
      AdminAccountsList.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AdoptAClient( aClient : tClientObj);
const
  ThisMethodName = 'AdoptAClient';
var
  s : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  //make this client part of the admin system
  ClearStatus;

  //adopt the client if is a foreign client
  aClient.clFields.clStaff_Member_LRN := 0;
  aClient.clFields.clContact_Details_To_Show := cdtPractice;
  aClient.clFields.clMagic_Number := AdminSystem.fdFields.fdMagic_Number;
  s := 'Client File '+ aClient.clFields.clCode +' adopted';

  aClient.clFields.clExclude_From_Scheduled_Reports := '';

  LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' '+S);

  //merge any new transactions
  SyncClientToAdmin( aClient, false );

    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
