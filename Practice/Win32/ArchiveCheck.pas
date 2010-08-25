unit ArchiveCheck;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Archive Check Unit

   Written:  Apr 2000
   Authors:  Matthew

   Purpose:  Checks that the LRN in the bank account matches the LRN of the
             last transaction in the TRX file for that account

   Notes:    Provides a validation check that the admin system and the
             Archive directory are still in sync.

             Raises an Exception if it fails

             Runs thru all bank accounts in the admin system and looks at their
             TRX file.
             Checks that the TRX files exist for the bank accounts.
             Reads the last record in the file and checks that the
             admin system LRN matches

             Can be disabled thru an INI setting in the BK5PRAC.INI
             Can be called when the first user logs in/out.

             [Environment]
             ValidateArchive=0
             ValidateArchiveDownloadOnly=1

             This is needed for internal testing and support.  Without it the
             trx files would always have to match the admin system before we
             could do any new downloads.

             Is called just before requesting new data.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

procedure CheckArchiveDirSynchronised;
procedure CheckArchiveDirSynchronised_V53;

function GetSizeOfArchive : Int64;

//******************************************************************************
implementation
uses
   ArchUtil32,
   Admin32,
   SyDefs,
   SysUtils,
   Bk5Except,
   LogUtil,
   Progress,
   WinUtils,
   Globals;

const
   UnitName = 'ArchiveCheck';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckArchiveDirSynchronised;
//Note: Application Process Messages will be called during this procedure
var
   i           : integer;
   pSB         : pSystem_Bank_Account_Rec;
   TrxFileName : string;
   ArchiveFile : EntryArchive;
   NoTrx       : integer;
   t           : tArchived_Transaction;
   sMsg        : string;
   WrongLRNCount    : integer;
   FileMissingCount : integer;
   WrongFormatCount : integer;
   NumAccounts      : integer;
begin
   //init counters
   WrongLRNCount    := 0;
   FileMissingCount := 0;
   WrongFormatCount := 0;
   //refresh the admin system
   RefreshAdmin;
   //cycle thru each bank account
   with AdminSystem.fdSystem_Bank_Account_List do begin
      NumAccounts := ItemCount;
      if NumAccounts > 100 then begin
         //notify user whats happening if more than 100 accounts
         UpdateAppStatus('Verifying Transaction Archive', '' ,0, ProcessMessages_On);
      end;
      for i := 0 to Pred( ItemCount) do begin
         pSB := System_Bank_Account_At( i);
         if NumAccounts > 100 then begin
            //notify user whats happening if more than 100 accounts
            UpdateAppStatusPerc( i / NumAccounts * 100, ProcessMessages_On);
         end;
         //get the trx file name
         TrxFileName := ArchUtil32.ArchiveFileName( pSB^.sbLRN);
         //check file exists
         if not BKFileExists( TrxFileName) then begin
            //check to see if we are expecting a file to exist
            if pSB^.sbLast_Transaction_LRN > 0 then begin
               sMsg :=  'Archive file ' + TrxFileName + ' not found for Account ' + pSB^.sbAccount_Number + ' LRN =' + inttostr( pSB^.sbLast_Transaction_LRN);
               LogUtil.LogMsg( lmDebug, UnitName, sMsg);
               Inc( FileMissingCount);
            end;
            //File does not exist so skip the read
            continue;
         end;
         //read the last transaction
         //open file
         try
           AssignFile( ArchiveFile, TrxFileName);
           Reset( ArchiveFile);
           try
             NoTrx := FileSize(ArchiveFile);
             if NoTrx > 0 then begin
                Seek( ArchiveFile, NoTrx-1 );
                Read( ArchiveFile, T );
                //compare the bank lrn with the lrn of the last transaction
                if T.aLRN <> pSB^.sbLast_Transaction_LRN then begin
                   sMsg := 'Archive file ' + TrxFileName + ' LRN = ' + inttoStr( T.aLRN) +
                           ' does not match Account ' + pSB^.sbAccount_Number + ' LRN = ' + inttoStr( pSB^.sbLast_Transaction_LRN);
                   LogUtil.LogMsg( lmError, UnitName, sMsg);
                   Inc( WrongLRNCount);
                end;
                //check end record type
                if T.aRecord_End_Marker <> ARCHIVE_REC_END_MARKER then
                begin
                  sMSg :=  'Archive file ' + TrxFileName + ' is wrong format LRN = ' + inttoStr( T.aLRN) +
                           ' MARKER = ' + inttostr( T.aRecord_End_Marker);
                  LogUtil.LogMsg( lmError, UnitName, sMsg);
                  Inc( WrongFormatCount);
                end;

             end
             else begin
                //not sure if this should be an error.  There may be cases where the txn file has been
                //cut back to zero.  ie.  Transactions have been purged.
                if pSB^.sbLast_Transaction_LRN > 0 then begin
                  sMsg := 'WARNING - Archive file ' + TrxFileName + ' is 0 bytes.  LRN = ' +  inttoStr( pSB^.sbLast_Transaction_LRN) + ' Account ' + pSB^.sbAccount_Number;
                  LogUtil.LogMsg( lmInfo, UnitName, sMsg);
                end;
             end;
           finally
              CloseFile(ArchiveFile);
           end;
         except
           on E : Exception do
             raise Exception.Create( E.Message + ' [' + E.Classname + '] Processing file ' + TrxFilename);
         end;
      end;
      ClearStatus;
      //check how many errors were encountered
      If ( WrongLRNCount > 0) or ( FileMissingCount > 0) or ( WrongFormatCount > 0) then begin
         sMsg := 'The Transaction Archive and the Admin System do not match.';
         if WrongLRNCount > 0 then
            sMsg := sMsg + ' Mismatched LRNs = ' + inttostr( WrongLRNCount);
         if FileMissingCount > 0 then
            sMsg := sMsg + ' Missing Files = ' + inttostr( FileMissingCount);
         if WrongFormatCount > 0 then
            sMsg := sMsg + ' Wrong Format Files = ' + inttostr( WrongFormatCount);
         sMsg := sMsg + '. See Log for details.';
         raise EAdminSystem.Create( sMsg);
//         exit;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSizeOfArchive : Int64;
//Note: Application Process Messages will be called during this procedure
var
  NumAccounts : integer;
  TrxFilename : string;
  i           : integer;
  pSB         : pSystem_Bank_Account_Rec;
begin
  result := 0;
  //refresh the admin system
  RefreshAdmin;
  try
    //cycle thru each bank account
    with AdminSystem.fdSystem_Bank_Account_List do
    begin
      NumAccounts := ItemCount;
      if NumAccounts > 100 then
      begin
         //notify user whats happening if more than 100 accounts
         UpdateAppStatus('Calculating disk space required for upgrade', '' ,0, ProcessMessages_On);
      end;

      for i := 0 to Pred( ItemCount) do
      begin
        pSB := System_Bank_Account_At( i);
        if NumAccounts > 100 then begin
           //notify user whats happening if more than 100 accounts
           UpdateAppStatusPerc( i / NumAccounts * 100, ProcessMessages_On );
        end;
        //get the trx file name
        TrxFileName := ArchUtil32.ArchiveFileName( pSB^.sbLRN);
        //check file exists
        if BKFileExists( TrxFileName) then
        begin
          result := result + WinUtils.GetFileSize( TrxFilename);
        end;
      end;
    end;
  finally
    ClearStatus;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckArchiveDirSynchronised_V53;
//the version of check archive is used to check the archive before upgrading
//it to version 54

//Note: Application Process Messages will be called during this procedure
var
   i           : integer;
   pSB         : pSystem_Bank_Account_Rec;
   TrxFileName : string;
   ArchiveFile : File of tV53_Archived_Transaction;
   NoTrx       : integer;
   t           : tV53_Archived_Transaction;
   sMsg        : string;
   WrongLRNCount    : integer;
   FileMissingCount : integer;
   NumAccounts      : integer;
begin
   //init counters
   WrongLRNCount    := 0;
   FileMissingCount := 0;
   //refresh the admin system
   RefreshAdmin;
   //cycle thru each bank account
   with AdminSystem.fdSystem_Bank_Account_List do begin
      NumAccounts := ItemCount;
      if NumAccounts > 100 then begin
         //notify user whats happening if more than 100 accounts
         UpdateAppStatus('Verifying Transaction Archive', '' ,0, ProcessMessages_On);
      end;
      for i := 0 to Pred( ItemCount) do begin
         pSB := System_Bank_Account_At( i);
         if NumAccounts > 100 then begin
            //notify user whats happening if more than 100 accounts
            UpdateAppStatusPerc( i / NumAccounts * 100, ProcessMessages_On );
         end;
         //get the trx file name
         TrxFileName := ArchUtil32.ArchiveFileName( pSB^.sbLRN);
         //check file exists
         if not BKFileExists( TrxFileName) then begin
            //check to see if we are expecting a file to exist
            if pSB^.sbLast_Transaction_LRN > 0 then begin
               sMsg :=  'Archive file ' + TrxFileName + ' not found for Account ' + pSB^.sbAccount_Number + ' LRN =' + inttostr( pSB^.sbLast_Transaction_LRN);
               LogUtil.LogMsg( lmDebug, UnitName, sMsg);
               Inc( FileMissingCount);
            end;
            //File does not exist so skip the read
            continue;
         end;
         //read the last transaction
         //open file
         try
           AssignFile( ArchiveFile, TrxFileName);
           Reset( ArchiveFile);
           try
             NoTrx := FileSize(ArchiveFile);
             if NoTrx > 0 then begin
                Seek( ArchiveFile, NoTrx-1 );
                Read( ArchiveFile, T );
                //compare the bank lrn with the lrn of the last transaction
                if T.aV53_LRN <> pSB^.sbLast_Transaction_LRN then begin
                   sMsg := 'Archive file ' + TrxFileName + ' LRN = ' + inttoStr( T.aV53_LRN) +
                           ' does not match Account ' + pSB^.sbAccount_Number + ' LRN = ' + inttoStr( pSB^.sbLast_Transaction_LRN);
                   LogUtil.LogMsg( lmError, UnitName, sMsg);
                   Inc( WrongLRNCount);
                end;
             end
             else begin
                //not sure if this should be an error.  There may be cases where the txn file has been
                //cut back to zero.  ie.  Transactions have been purged.  Just log warning
                if pSB^.sbLast_Transaction_LRN > 0 then begin
                  sMsg := 'WARNING - Archive file ' + TrxFileName + ' is 0 bytes.  LRN = ' +  inttoStr( pSB^.sbLast_Transaction_LRN) + ' Account ' + pSB^.sbAccount_Number;
                  LogUtil.LogMsg( lmInfo, UnitName, sMsg);
                end;
             end;
           finally
              CloseFile(ArchiveFile);
           end;
         except
           on E : Exception do
             raise Exception.Create( E.Message + ' [' + E.Classname + '] Processing file ' + TrxFilename);
         end;
      end;
      ClearStatus;
      //check how many errors were encountered
      If ( WrongLRNCount > 0) or ( FileMissingCount > 0) then begin
         sMsg := 'The Transaction Archive and the Admin System do not match.';
         if WrongLRNCount > 0 then
            sMsg := sMsg + ' Mismatched LRNs = ' + inttostr( WrongLRNCount);
         if FileMissingCount > 0 then
            sMsg := sMsg + ' Missing Files = ' + inttostr( FileMissingCount);
         sMsg := sMsg + '. See Log for details.';
         raise EAdminSystem.Create( sMsg);
//         exit;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
