unit Download;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Download and Process new transactions into the Admin System
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

{!! no longer used !!}

procedure DownloadFromFloppy;
procedure DownloadFromBConnect;

//******************************************************************************
implementation
uses
  SysUtils,
  stDatest,
  ovcDate,
  abArcTyp,
  MoneyDef,
  sySBio,
  syDLio,
  sydefs,
  bkconst,
  bk5Except,
  globals,
  Admin32,
  YesNoDlg,
  InfoMoreFrm,
  ErrorMoreFrm,
  CRYPTX,
  EnterPINdlg,
  CRC32,
  CrcFileUtils,
  MAlloc,
  ArchUtil32,
  LogUtil,
  GenUtils,
  bkDateUtils,
  Progress,
  DownloadUtils,
  DownloadDefs,
  DownloadFloppy,
  BankLinkConnect,
  ZipUtils,
  ArchiveCheck,
  AbUtils, SysObj32, ECollect;


const
   UnitName = 'DOWNLOAD';

resourcestring
  rsHelpErrorMsg = 'Incorrect PIN Number Entered.  Please Email %s '+
                   ' Support requesting your Practice PIN number.  Note: You MUST email the request from a Practice email address.';
   
var
   DebugMe  : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDownloadNZ;
const
   ThisMethodName = 'DoDownloadNZ';
const
  BUFFER_SIZE = 8192;
  RT86_DIR_SIZE = 7168;
  DIRECTORY_SIZE = 16384;
var
  Count, DiskNo   : integer;
  FileName        : string;
  LocalFileName   : string;
  ZipFileName     : string;
  ID              : NZDiskIDRec;
  i : integer;
  F1,F2           : file;
  SaveCRC         : LongWord;
  CRC             : LongWord;
  Buffer          : Array [1..BUFFER_SIZE] of Byte;
  NumRead,
  NumWritten      : integer;

  UnZipEngine     : TBKUnzip;
  Directory       : pDirectory;
  Log             : pSystem_Disk_Log_Rec;
  NumAccounts     : integer;
  NumEntries      : integer;
  HighestDate     : integer;
  LowestDate      : integer;

  eFileName       : string;
  eFile           : File of TSector;

  DirNo           : integer;
  pSB             : pSystem_Bank_Account_Rec;
  ArchiveFile     : File of tArchived_Transaction; { in ARCHUTIL }
  ArchiveName     : String;
  StartsAt        : Integer;
  NoOfBlocks      : Integer;
  LastBlock       : Integer;
  BlockNo         : Integer;
  SlotNo          : Integer;
  Key, FullKey    : String[20];
  E               : E_Sector_Rec;
  PaxusDataRec    : PaxusDataRecType;
  TranInf         : tArchived_Transaction;
  S               : String[30];

  wasDiskSeq      : integer;
  wasBankLinkCode : string;
  wasLogCount     : integer;
  NewPin          : integer;
  Msg             : String;
  LFSize          : Integer;
  LFCRC           : LongWord;

  CSV_File        : Text;
  CSV_Buf         : array[ 1..8192 ] of Byte;
  CSV_Filename    : String[80];

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if not RefreshAdmin then Exit;

  with AdminSystem.fdFields do begin
     Count := NoOfNewFilesToDownload(fdBankLink_Code,fdDisk_Sequence_No);
     if Count < 1 then Exit;
  end;

  LogUtil.LogMsg( lmInfo, UnitName, 'Verifying Files Started');
  try
    //--------------------------- verification ---------------------------------
    UpdateAppStatus( 'Verifying Files', '', 0);
    try
       With AdminSystem.fdFields do for DiskNo := 1 to Count do begin
         UpdateAppStatusLine2( inttostr(DiskNo)+' of '+inttostr(Count));
         UpdateAppStatusPerc(  DiskNo * 50 div Count);

         FileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
         LocalFileName := DownloadInboxDir + Filename;

         {check that all files are banklink NZ Files}
         CheckNZBanklinkFile(LocalFileName);

         {check for PIN}
         GetFileHeader(LocalFileName,ID,Sizeof(ID));
         if not EnterPIN(FileName,ID.idClientName, fdPIN_Number) then begin
            HelpfulErrorMsg(Format(rsHelpErrorMsg, [SHORTAPPNAME]), 0);
            Exit;
         end;

         {check disk log for this disk already been done}
         with AdminSystem.fdSystem_Disk_Log do begin
           for  i := 0 to Pred(itemCount) do with Disk_Log_At(i)^ do begin
             if (dlDisk_ID = ID.idSerialNo) then begin
                Msg := Format( 'The file %s has already been downloaded.', [ FileName ] );
                if DebugMe then
                   LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
                HelpfulErrorMsg( Msg + ' You cannot download it more than once.',0);
                Exit;
             end;
           end;
         end;
       end;

       UpdateAppStatus( 'Expanding Files ', '', 50);

       with AdminSystem.fdFields do For DiskNo := 1 to Count do begin
         UpdateAppStatusLine2( inttostr(DiskNo)+' of '+inttostr(Count));
         UpdateAppStatusPerc(( DiskNo * 50 div Count) + 50);

         fileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
         LocalFileName := DownloadInboxDir + Filename;

         if DebugMe then begin
            Msg := Format( 'Extracting ZIP and Check CRC for %s', [ LocalFileName ] );
            LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
         end;
         ZipFileName := DOWNLOADINBOXDIR + 'TEMP$'+ ZIP_EXTN;
         SysUtils.DeleteFile(ZipFileName);

         if DebugMe then begin
           Msg := Format( 'Opening File %s', [ LocalFileName ] );
           LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
         end;

         AssignFile(F1,LocalFileName);
         Reset(F1,1);
         LFSize := FileSize( F1 );

         try
           if DebugMe then begin
             Msg := Format( 'Creating Zip File %s', [ ZipFileName ] );
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
           end;

           AssignFile(F2,ZipFileName);
           Rewrite(F2,1);
           try
             BlockRead(F1,ID,SizeOf(ID));

             //status checking crc
             SaveCRC := ID.idCRC;
             ID.idCRC:= 0;
             CRC := 0;
             UpdateCRC(CRC,ID,Sizeof(ID));

             {Extract ZIP File}
             Repeat
                BlockRead(F1,Buffer,Sizeof(Buffer),NumRead);
                UpdateCRC(CRC,Buffer,NumRead);
                Decrypt(Buffer,NumRead);
                BlockWrite(F2,Buffer,NumRead,NumWritten);

                If  NumWritten<>NumRead then begin
                    Msg := Format('Error Writng to %s, Bytes Read <> Bytes Written', [ ZipFileName ]);
                    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                    raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
                end;
             Until(NumRead=0);

           finally
             CloseFile(F2);
           end;
         finally
           CloseFile(F1);
         end;

         If ( SaveCRC <>0 ) and ( CRC <> SaveCRC ) then
         begin
            SysUtils.DeleteFile( ZipFileName ); { it contains garbage so it can go }
            Msg := Format( 'CRC Check Failed For %s', [ LocalFileName ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
            Msg := Format( '%s file size = %d', [ LocalFileName, LFSize ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
            LFCRC := CRCFileUtils.CalculateCRC( LocalFileName );
            Msg := Format( '%s 32bit CRC = %d', [ LocalFileName, LFCRC ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );

            Msg := Format( 'CRC Check Failed For %s', [ LocalFileName ] );
            raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         {unzip the files into the WORKDIR directory - make sure it exists}
         if not DirectoryExists(DownloadWorkDir) then begin
           if not CreateDir(DownloadWorkDir) then begin
              Msg := Format('Unable To Create Directory %s', [ DownloadWorkDir ]);
              LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
              raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
           end;
         end;

         if DebugMe then begin
           Msg := Format( 'UnZipping File %s', [ ZipFileName ] );
           LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
         end;

         try
            UnZipEngine := tBKUnZip.Create(nil);
            try
              UnZipEngine.ArchiveType := atZip;
              UnZipEngine.ForceType   := true;
              UnZipEngine.ExtractOptions := [eoCreateDirs];  { <- doesnt seem to work}
              UnZipEngine.BaseDirectory := DOWNLOADWORKDIR;
              UnZipEngine.FileName      := ZipFileName;
              UnZipEngine.ExtractFiles('*.*');
            finally
              UnZipEngine.free;
            end;
         except
            on E : ECompressionFailure do begin
               //reraise a EDownloadVerify
               raise EDownloadVerify.Create( E.Message);
            end;
         end;

         {erase temporary zip file}
         SysUtils.DeleteFile(ZipFileName);
       end;
    except
       on E : EInOutError do begin
          raise EDownloadVerify.CreateFmt('%s EInOutError %s', [ThisMethodName,E.Message]);
       end;
    end;

    {--------------------------------------------------------------------------------------------------}
    {       IMPORT ready to begin - the files have been extracted into   }
    {       the WORK directory.  Now Cycle thru each file and extract    }
    {       data into the archive directory                              }
    {--------------------------------------------------------------------}
    wasDiskSeq      := AdminSystem.fdFields.fdDisk_Sequence_No;
    wasBankLinkCode := AdminSystem.fdFields.fdBankLink_Code;
    wasLogCount     := AdminSystem.fdSystem_Disk_Log.ItemCount;
    NewPin          := AdminSystem.fdFields.fdPIN_Number;

    if LoadAdminSystem(True, ThisMethodName ) then begin
      {check for changes to the admin system - might indicate someone else downloading}
      if AdminHasChanged then with AdminSystem do
        if (fdFields.fdDisk_Sequence_No <> wasDiskSeq) or
           (fdFields.fdBankLink_Code <> wasBankLinkCode) or
           (fdSystem_Disk_Log.ItemCount <> wasLogCount) then begin
          UnlockAdmin;
          HelpfulErrorMsg('The Admin System has been changed during the verification Process.  '+
                          'To ensure that there are no serious data conflicts you must restart '+
                          'the Download Process.',0);
          exit;
        end;

      {allocate directory}
      SafeGetMem(Directory,SizeOf(tDirectory));
      try
        Log         := nil;
        NumEntries  := 0;
        HighestDate := 0;
        LowestDate  := MaxInt;

        if DebugMe then begin
           Msg := 'Starting Import';
           LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
        end;

        //clear month accumulators
        with AdminSystem.fdSystem_Bank_Account_List do begin
          for i := 0 to Pred(ItemCount) do begin
            with System_Bank_Account_At(i)^ do begin
              sbNew_This_Month            := false;
              sbWas_On_Latest_Disk        := false;
              sbNo_of_Entries_This_Month  := 0;
              sbFrom_Date_This_Month      := 0;
              sbTo_Date_This_Month        := 0;
              sbCharges_This_Month        := 0;
            end;
          end;
        end;

        for i := AdminSystem.fdSystem_Disk_Log.First to AdminSystem.fdSystem_Disk_Log.Last do
          AdminSystem.fdSystem_Disk_Log.Disk_Log_At(i)^.dlWas_In_Last_Download := False;

      //crashes or error before this point will not affect the admin system or
      //transaction files in the archive dir.
      //Errors after this will require a restore
      LogUtil.LogMsg( lmInfo, UnitName, 'CRITICAL DOWNLOAD STAGE STARTED');

       {**************************************************************}
       { Main Loop that goes thru each disk found in the WORK dir     }
       {**************************************************************}
        with AdminSystem.fdFields do begin
          For DiskNo := 1 to Count do begin       {cycle thru the files}
            fileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
            LocalFileName := DownloadWorkDir + FileName;

            If Globals.PRACINI_CreateCSVFile then
            Begin
               CSV_FileName := DownloadWorkDir + MakeSuffix(fdDisk_Sequence_No+DiskNo) + '.CSV';
               Assign( CSV_File, CSV_FileName );
               SetTextBuf( CSV_File, CSV_Buf );
               Rewrite( CSV_File );
               Writeln( CSV_File, '"Account Number","Date","Type","Reference","Analysis","Amount","Other Party","Particulars"' );
            end;

            Msg := Format( 'Importing from %s', [ LocalFileName ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + Msg );
            if DebugMe then begin
               Msg := Format( 'fdTransaction_LRN_Counter = %d', [ fdtransaction_LRN_Counter ] );
               LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
            end;

            UpdateAppStatus('Downloading '+Filename,'', DiskNo * 100 div Count);

            { ******************************************************************}
            { STEP 1: Extract the data from the file containing the file and directory structure}

            AssignFile(F1,LocalFileName);
            Reset(F1,1);
            try
              {strip of RT86 Disk Directory - This is the *.INF section of the file}
              if DebugMe then begin
                 Msg := 'Removing RT86 Directory';
                 LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
              end;

              BlockRead(F1,Buffer,RT86_Dir_Size);

              {read the directory}
              if DebugMe then begin
                 Msg := 'Reading Account Directory';
                 LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
              end;

              BlockRead(F1,Directory^,DIRECTORY_SIZE, NumRead);
              if NumRead <> DIRECTORY_SIZE then begin
                 Msg := 'Reading Account Directory : NumRead <> DIRECTORY_SIZE';
                 LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                 raise EDownload.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
              end;

              Log := syDLio.New_System_Disk_Log_Rec;
              with Directory^[0].DiskHeader, Log^ do begin
                dlDisk_ID        := A2S(Floppy_Desc,Sizeof(Floppy_Desc));
                dlDate_Downloaded := CurrentDate;
                dlNo_of_Accounts  := 0;
                dlNo_of_Entries   := 0;
                dlWas_In_Last_Download := True;
                AdminSystem.fdSystem_Disk_Log.Insert(Log);
              end;

              {extract data into a file}
              eFileName := DOWNLOADWORKDIR+ 'DATA.$$$';
              if DebugMe then begin
                 Msg := Format('Extracting Data Into %s.', [ eFileName ]);
                 LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
              end;

              AssignFile(F2,eFileName);
              Rewrite(F2,1);
              try
                Repeat
                  BlockRead(F1,Buffer,Sizeof(Buffer),NumRead);
                  BlockWrite(F2,Buffer,NumRead,NumWritten);

                  if NumRead <> NumWritten then begin
                     Msg := Format('Error Writng to %s, Bytes Read <> Bytes Written', [ eFileName ]);
                     LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                     raise EDownload.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
                  end;

                Until NumRead = 0;
              finally
                CloseFile(F2);
              end;
            finally
              CloseFile(F1);
            end;

            { ******************************************************************}
            {STEP 2:  Open the temporary data file for reading.  This is the DATA.$$$ file }
            {          Read the bank accounts and transaction and store in the archive directory}

            if DebugMe then begin
               Msg := Format('ReOpening %s.', [ eFileName ]);
               LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
            end;

            AssignFile(eFile,eFileName);
            Reset(eFile);
            try
            For DirNo := 1 to 255 do
               With Directory^[ DirNo ].AcctHeader do if Swap( No_Of_Blocks )>0 then Begin
               Key := A2S( Cust_Code,Sizeof( Cust_Code ) );
               If Directory^[0].DiskHeader.Floppy_Version = 2 then Begin
                  FullKey:=A2S( Cust_FullCode,Sizeof( Cust_FullCode ) );
                  While ( FullKey<>'' ) and ( ( FullKey[Length( FullKey )] = ' ' ) or ( FullKey[Length( FullKey )] = #00 ) )
                     do Dec( FullKey[0] );
                  If ( FullKey<>'' ) and ( FullKey<>Key ) then Key:=FullKey;
               end;

               UpdateAppStatusLine2('Account '+Key);

               if DebugMe then begin
                  Msg := Format('Processing Account %s.', [ Key ]);
                  LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
               end;

               Inc( Log^.dlNo_of_Accounts );

               {Find the bank account in the list, or create a new bank account}
               pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( Key );
               If not Assigned( pSB ) then Begin
                  pSB := New_System_Bank_Account_Rec;
                  With pSB^ do Begin
                     sbAccount_Number := Key;
                     sbAccount_Name   := A2S( Cust_Name,Sizeof( Cust_Name ) );

                     Inc( AdminSystem.fdFields.fdBank_Account_LRN_Counter );
                     sbLRN             := AdminSystem.fdFields.fdBank_Account_LRN_Counter ;
                     sbCurrent_Balance := Unknown;
                     sbNew_This_Month  := TRUE;
                     sbAttach_Required := TRUE;  {very important}
                     AdminSystem.fdSystem_Bank_Account_List.Insert( pSB );
                  end;
               end;

               With pSB^ do Begin
                  sbWas_On_Latest_Disk := true;
                  ArchiveName := ArchiveFileName( sbLRN );
                  If BKFileExists( ArchiveName ) then Begin
                     if DebugMe then begin
                        Msg := Format('Opening %s.', [ ArchiveName ]);
                        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
                     end;
                     Assign( ArchiveFile, ArchiveName );
                     Reset( ArchiveFile );

                     if DebugMe then begin
                        Msg := Format('Seeking To EOF %s.', [ ArchiveName ]);
                        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
                     end;
                     Seek( ArchiveFile, FileSize(ArchiveFile ));
                  end
                  else Begin
                     if DebugMe then begin
                        Msg := Format('Creating %s.', [ ArchiveName ]);
                        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg );
                     end;
                     Assign( ArchiveFile, ArchiveName );
                     Rewrite( ArchiveFile );
                  end;

                 { ******************************************************************}
                 { STEP 3 : Now begin importing the transactions into the Archive Directory structure}

                  try
                    StartsAt    := Swap( Start_Block );
                    NoOfBlocks  := Swap( No_Of_Blocks );
                    LastBlock   := StartsAt + NoOfBlocks - 1;
                    For BlockNo := StartsAt to LastBlock do Begin
                       Seek( eFile, BlockNo );
                       Read( eFile, tSector( E ));

                       For SlotNo:=1 to 6 do Begin
                          PaxusDataRec := E.Slot[ SlotNo ];

                          If PaxusDataRec.Outline.Rectype = 'A' then With PaxusDataRec.Header do Begin
                             sbCost_Code := A2S( CostCode, Sizeof( CostCode ) );
                          end
                          else If PaxusDataRec.Outline.Rectype = 'B' then With PaxusDataRec.Tran, TranInf do Begin
                             FillChar( TranInf, Sizeof( TranInf ), 0 );
                             aRecord_End_Marker  := ArchUtil32.ARCHIVE_REC_END_MARKER;
                             aType            := TranCode;
                             aSource          := orBank;
                             aDate_Presented  := DateStringtoStDate( 'DDMMYY',A2S(PostDate,Sizeof(PostDate)),BKDATEEPOCH);
                             aReference       := A2S( Reference,Sizeof( Reference ) );

                             If ( aType in [0,4..9] ) then Begin
                                S := Trim( aReference );
                                While Length( S ) > 6 do System.Delete( S, 1, 1 );
                                aCheque_Number := Str2Long( S );
                             end;

                             aParticulars     := A2S( Particulars,Sizeof( Particulars ) );

                             S[0]:=#12; Move( Analysis[1],S[1],12 );
                             For i:=1 to 12 do if ( S[i]<' ' ) or ( S[i]>#$7F ) then S[i]:=' ';
                             aAnalysis :=S;

                             aOther_Party := A2S( OtherParty,Sizeof( OtherParty ) );

                             aOrigBB := A2S( OrigBB,Sizeof( OrigBB ) );
                             aAmount := Value_Of( Amount );
                             aQuantity   := 0;
                             //this version of the disk image does not have statement detail
                             //so we must construct it from the other party and particulars
                             aStatement_Details := MakeStatementDetails(pSB^.sbAccount_Number,
                                                                        aOther_Party,
                                                                        aParticulars);
                             With AdminSystem.fdFields do Begin
                                Inc( fdTransaction_LRN_Counter );
                                aLRN := fdTransaction_LRN_Counter;
                             end;

                             Write( ArchiveFile, TranInf );

                             If Globals.PRACINI_CreateCSVFile then
                             Begin
                                Write( CSV_File, '"', sbAccount_Number, '",' );
                                Write( CSV_File, '"', Date2Str( aDate_Presented, 'dd/mm/yyyy' ), '",' );
                                Write( CSV_File, '"', aType, '",' );
                                Write( CSV_File, '"', aReference, '",' );
                                Write( CSV_File, '"', aAnalysis, '",' );
                                Write( CSV_File, '"', aAmount/100:0:2, '",' );
                                Write( CSV_File, '"', aOther_Party, '",' );
                                Write( CSV_File, '"', aParticulars, '"' );
                                Writeln( CSV_File );
                             end;

                             If ( sbFrom_Date_This_Month = 0 ) or
                                ( aDate_Presented < sbFrom_Date_This_Month ) then
                                sbFrom_Date_This_Month := aDate_Presented;

                             If aDate_Presented > sbTo_Date_This_Month then
                                sbTo_Date_This_Month := aDate_Presented;

                             If aDate_Presented > sbLast_Entry_Date then
                                sbLast_Entry_Date := aDate_Presented;

                             sbLast_Transaction_LRN := aLRN;

                             If sbCurrent_Balance <> Unknown then
                                sbCurrent_Balance := sbCurrent_Balance + aAmount;

                             Inc( sbNo_of_Entries_This_Month );

                             Inc( Log^.dlNo_of_Entries );
                             Inc( NumEntries );

                             if aDate_Presented > HighestDate then
                               HighestDate := aDate_Presented;

                             if aDate_Presented < LowestDate then
                               LowestDate  := aDate_Presented;
                          end
                          else If PaxusDataRec.Outline.Rectype = 'C' then begin
                             With PaxusDataRec.Tail do Begin
                                If Trim(A2S( Charges, Sizeof(Charges)))<>'' then
                                   sbCharges_This_Month := sbCharges_This_Month + Value_Of( Charges );
                                Break;
                             end;
                          end;
                       end;
                    end; { of data for this Bank Account }
                  finally
                     CloseFile( ArchiveFile );
                  end;
               end; { scope of pSB }
            end; { of This Account }
            finally
              CloseFile( eFile );
              SysUtils.DeleteFile( eFileName );
              If Globals.PRACINI_CreateCSVFile then System.Close( CSV_File );
            end;
          end;    {end of main loop for all files}
        end; //End with
      finally {getmem}
        SafeFreeMem(Directory,Sizeof(TDirectory));
      end;

      { ******************************************************************}
      { STEP 4 : Cleanup and Update the Admin system                      }

      {At this point we have had a successful download of data from the disk into
       the Archive directory structure }

       AdminSystem.fdFields.fdDisk_Sequence_No := AdminSystem.fdFields.fdDisk_Sequence_No + Count;
       AdminSystem.fdFields.fdPIN_Number       := NewPin;
       if HighestDate <> 0 then begin
          AdminSystem.fdFields.fdPrint_Reports_Up_To := HighestDate;
          AdminSystem.fdFields.fdDate_of_Last_Entry_Received := HighestDate;
       end;

       SaveAdminSystem;
       AdminSystem.DownloadSave;  //saves a copy after a successful download

       UpdateAppStatus('Download Completed','Cleaning up',100);
       LogUtil.LogMsg( lmInfo, UnitName, 'CRITICAL DOWNLOAD STAGE COMPLETED');

       {clean up disk images left over}
       for i := Count-1 downto 0 do begin
         fileName := AdminSystem.fdFields.fdBankLink_Code +'.'+ MakeSuffix(AdminSystem.fdFields.fdDisk_Sequence_No-i);
         LocalFileName := DownloadInBoxDir + FileName;
         SysUtils.DeleteFile(LocalFileName);

         LocalFileName := DownloadWorkDir + FileName;

         SysUtils.DeleteFile(LocalFileName);
       end;
       ClearStatus;

       //count no of accounts on disk(s)
       NumAccounts := 0;
       for i := 0 to Pred( AdminSystem.fdSystem_Bank_Account_List.ItemCount) do begin
          if AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At( i).sbWas_On_Latest_Disk then
             Inc( NumAccounts);
       end;

       Msg := 'Download Complete.  ' +
              inttoStr( NumAccounts) + ' accounts received. ' +
              inttoStr( NumEntries)  + ' entries from ' +
              bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
       LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + Msg);

       Msg := 'Download Complete.  '#13#13 +
              inttoStr( NumAccounts) + ' accounts received. '#13 +
              inttoStr( NumEntries)  + ' entries from ' +
              bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
       HelpfulInfoMsg(Msg,0);
    end
    else begin
      Msg := 'Cannot Download New Information At This Time.  Admin System Cannot Be Loaded';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg);
      HelpfulErrorMsg(Msg,0);
    end;

  {------------------------------------------------}
  finally
    ClearStatus;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDownloadOZ;
const
  ThisMethodName = 'DoDownloadOZ';

  BUFFER_SIZE = 8192;
  RT86_DIR_SIZE = 7168;
  OZ_DIRECTORY_SIZE= 32768;
  MESSAGES_SIZE  = 8192;
var
  Count, DiskNo : integer;
  FileName      : string;
  LocalFileName : string;
  ZipFileName   : string;
  ID            : OZDiskIDRec;
  i : integer;
  F1,F2         : file;
  SaveCRC       : LongWord;
  CRC           : LongWord;
  Buffer        : Array [1..BUFFER_SIZE] of Byte;
  NumRead,
  NumWritten    : integer;

  UnZipEngine   : tBKUnzip;
  Directory     : pOZDirectory;
  Log           : pSystem_Disk_Log_Rec;
  NumEntries    : integer;
  NumAccounts   : integer;
  HighestDate   : integer;
  LowestDate    : integer;

  eFileName     : string;
  eFile         : File of OZ_E_Sector_Rec;

  DirNo         : integer;
  pSB           : pSystem_Bank_Account_Rec;

  ArchiveFile    : File of tArchived_Transaction; { in ARCHUTIL }
  ArchiveName    : String;
  StartsAt       : Integer;
  NoOfBlocks     : Integer;
  LastBlockNo    : Integer;
  BlockNo        : Integer;
  SlotNo         : Integer;
  EntryNo        : integer;
  Key, FullKey   : String[20];
  E              : OZ_E_Sector_Rec;

  TranInf        : tArchived_Transaction;
  S              : String[30];

  DiskID         : string[10];
  SerialNo       : string[20];
  LFSize          : Integer;
  LFCRC           : LongWord;

  wasDiskSeq      : integer;
  wasBankLinkCode : string;
  wasLogCount     : integer;
  NewPin          : integer;
  Msg             : string;

  CSV_File        : Text;
  CSV_Buf         : array[ 1..8192 ] of Byte;
  CSV_Filename    : String[80];

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if not RefreshAdmin then Exit;

   with AdminSystem.fdFields do begin
      Count := NoOfNewFilesToDownload(fdBankLink_Code,fdDisk_Sequence_No);
      if Count < 1 then Exit;
   end;

   LogUtil.LogMsg( lmInfo, UnitName, 'Verifying Files Started');
   try
     //------------------------  verify -------------------------------------------
     try
        UpdateAppStatus( 'Verifying Files ', '', 0);

        With AdminSystem.fdFields do for DiskNo := 1 to Count do begin
          UpdateAppStatusLine2( inttostr(DiskNo)+' of '+inttostr(Count));
          UpdateAppStatusPerc(  DiskNo * 50 div Count);

          fileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
          LocalFileName := DownloadInboxDir + FileName;

          if debugMe then begin
             Msg := Format('Checking File %s', [ LocalFileName ]);
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
          end;

          {check that all files are banklink NZ Files}
          CheckOZBankLinkFile(LocalFileName);

          {check for PIN}
          GetFileHeader(LocalFileName,ID,Sizeof(ID));
          if not EnterPIN(FileName,ID.idClientName, fdPIN_Number) then begin
             HelpfulErrorMsg(Format(rsHelpErrorMsg, [SHORTAPPNAME]), 0);
             Exit;
          end;

          {check disk log for this disk already been done}
          with AdminSystem.fdSystem_Disk_Log do begin
            for  i := 0 to Pred(itemCount) do with Disk_Log_At(i)^ do begin
              if (dlDisk_ID = ID.idFileName) then begin
                 HelpfulErrorMsg('The file '+filename+' has already been downloaded.  You cannot download it more than once.',0);
                 exit;
              end;
            end;
          end;
        end;

        UpdateAppStatus( 'Expanding Files ', '', 50);
        with AdminSystem.fdFields do For DiskNo := 1 to Count do begin
          UpdateAppStatusLine2( inttostr(DiskNo)+' of '+inttostr(Count));
          UpdateAppStatusPerc(( DiskNo * 50 div Count) + 50);

          fileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
          LocalFileName := DownloadInboxDir + FileName;

          if debugMe then begin
             Msg := Format('Extracting Zip File %s', [ LocalFileName ]);
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
          end;

          ZipFileName := DOWNLOADINBOXDIR + 'TEMP$'+ZIP_EXTN;
          SysUtils.DeleteFile(ZipFileName);

          if debugMe then begin
             Msg := Format('Opening File %s', [ LocalFileName ]);
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
          end;

          AssignFile(F1,LocalFileName);
          Reset(F1,1);
          LFSize := FileSize( F1 );

          try
            if debugMe then begin
               Msg := Format('Creating File %s', [ ZipFileName ]);
               LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
            end;

            AssignFile(F2,ZipFileName);
            Rewrite(F2,1);
            try
              BlockRead(F1,ID,SizeOf(ID));

              //status checking crc

              SaveCRC := ID.idCRC;
              ID.idCRC:= 0;
              CRC := 0;

              UpdateCRC(CRC,ID,Sizeof(ID));

              {Extract ZIP File}
              Repeat
                 BlockRead(F1,Buffer,Sizeof(Buffer),NumRead);
                 UpdateCRC(CRC,Buffer,NumRead);
                 Decrypt(Buffer,NumRead);
                 BlockWrite(F2,Buffer,NumRead,NumWritten);

                 If  NumWritten<>NumRead then begin
                    Msg := Format('Error Writng to %s, Bytes Read <> Bytes Written', [ ZipFileName ]);
                    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                    raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
                 end;
              Until(NumRead=0);

            finally
              CloseFile(F2);
            end;
          finally
            CloseFile(F1);
          end;

          if (SaveCRC <>0) and (CRC <> SaveCRC) then
          begin
             SysUtils.DeleteFile( ZipFileName ); { it contains garbage so it can go }
             Msg := Format( 'CRC Check Failed For %s', [ LocalFileName ] );
             LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
             Msg := Format( '%s file size = %d', [ LocalFileName, LFSize ] );
             LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
             LFCRC := CRCFileUtils.CalculateCRC( LocalFileName );
             Msg := Format( '%s CRC = %d', [ LocalFileName, LFCRC ] );
             LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );

             Msg := Format( 'CRC Check Failed For %s', [ LocalFileName ] );
             Raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
          end;

          {unzip the files into the WORKDIR directory - make sure it exists}
          if not DirectoryExists(DownloadWorkDir) then
            if not CreateDir(DownloadWorkDir) then begin
               Msg := Format('Unable To Create Directory %s', [ DownloadWorkDir ]);
               LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
               raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
            end;

          if debugMe then begin
             Msg := Format('Unzipping File %s', [ ZipFileName ]);
             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
          end;

          try
             UnZipEngine := tBKUnzip.Create(nil);
             try
               UnZipEngine.ArchiveType := atZip;
               UnZipEngine.ForceType   := true;
               UnZipEngine.ExtractOptions := [eoCreateDirs];  { <- doesnt seem to work}
               UnZipEngine.BaseDirectory := DOWNLOADWORKDIR;
               UnZipEngine.FileName      := ZipFileName;
               UnZipEngine.ExtractFiles('*.*');
             finally
               UnZipEngine.free;
             end;
          except
             on E : ECompressionFailure do begin
                //reraise a EDownloadVerify
                raise EDownloadVerify.Create( E.Message);
             end;
          end;

          {erase temporary zip file}
          SysUtils.DeleteFile(ZipFileName);
        end;
     except
        on E : EInOutError do begin
           raise EDownloadVerify.CreateFmt('%s EInOutError %s', [ThisMethodName,E.Message]);
        end;
     end;

     {----------------------------------------------------------------------------}
     {       IMPORT ready to begin - the files have been extracted into   }
     {       the WORK directory.  Now Cycle thru each file and extract    }
     {       data into the archive directory                              }
     {--------------------------------------------------------------------}
     wasDiskSeq      := AdminSystem.fdFields.fdDisk_Sequence_No;
     wasBankLinkCode := AdminSystem.fdFields.fdBankLink_Code;
     wasLogCount     := AdminSystem.fdSystem_Disk_Log.ItemCount;
     NewPin          := AdminSystem.fdFields.fdPIN_Number;

     if LoadAdminSystem(True, ThisMethodName ) then begin
       {check for changes to the admin system - might indicate someone else downloading}
       if AdminHasChanged then with AdminSystem do
         if (fdFields.fdDisk_Sequence_No <> wasDiskSeq) or
            (fdFields.fdBankLink_Code <> wasBankLinkCode) or
            (fdSystem_Disk_Log.ItemCount <> wasLogCount) then
         begin
           UnlockAdmin;
           HelpfulErrorMsg('The Admin System has been changed during the verification Process.  '+
                           'To ensure that there are no serious data conflicts you must restart '+
                           'the Download Process.',0);
           exit;
         end;

       {allocate directory}
       SafeGetMem(Directory,SizeOf(tOZDirectory));
       try
         Log         := nil;
         NumEntries  := 0;
         HighestDate := 0;
         LowestDate  := MaxInt;

         if debugMe then begin
            LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - Starting Import');
         end;

         with AdminSystem.fdSystem_Bank_Account_List do begin
           for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
             sbNew_This_Month            := false;
             sbWas_On_Latest_Disk        := false;
             sbNo_of_Entries_This_Month  := 0;
             sbFrom_Date_This_Month      := 0;
             sbTo_Date_This_Month        := 0;
             sbCharges_This_Month        := 0;
           end;
         end;

      //crashes or error before this point will not affect the admin system or
      //transaction files in the archive dir.
      //Errors after this will require a restore
      LogUtil.LogMsg( lmInfo, UnitName, 'CRITICAL DOWNLOAD STAGE STARTED');

        {**************************************************************}
        { Main Loop that goes thru each disk found in the WORK dir     }

         with AdminSystem.fdFields do
         For DiskNo := 1 to Count do begin       {cycle thru the files}
           fileName := fdBankLink_Code +'.'+ MakeSuffix(fdDisk_Sequence_No+DiskNo);
           LocalFileName := DownloadWorkDir + FileName;

           If Globals.PRACINI_CreateCSVFile then
           Begin
              CSV_FileName := DownloadWorkDir + MakeSuffix(fdDisk_Sequence_No+DiskNo) + '.CSV';
              Assign( CSV_File, CSV_FileName );
              SetTextBuf( CSV_File, CSV_Buf );
              Rewrite( CSV_File );
              Writeln( CSV_File, '"Account Number","Date","Type","Reference","Amount","Narrative"' );
           end;

           Msg := Format('Importing From %s', [ LocalFileName ]);
           LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' - ' + Msg);
           if debugMe then begin
              Msg := Format('fdTransaction_LRN_Counter = %d', [ fdtransaction_LRN_Counter ]);
              LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
           end;

           UpdateAppStatus( 'Downloading '+Filename,'', DiskNo * 100 div Count);

           { ******************************************************************}
           { STEP 1: Extract the data from the file containing the file and directory structure}

           AssignFile(F1,LocalFileName);
           Reset(F1,1);
           try
             {strip of RT86 Disk Directory - This is the *.INF section of the file}
             if debugMe then begin
                Msg := 'Removing RT86 Directory';
                LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
             end;

             BlockRead(F1,Buffer,RT86_Dir_Size);

             {read the directory}
             if debugMe then begin
                Msg := 'Reading Account Directory';
                LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
             end;

             BlockRead(F1,Directory^,OZ_DIRECTORY_SIZE, NumRead);
             if NumRead <> OZ_DIRECTORY_SIZE then begin
                Msg := 'Error Reading Account Directory : NumRead <> OZ_DIRECTORY_SIZE';
                LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                raise EDownload.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
             end;

             {strip off messages}
             if debugMe then begin
                Msg := 'Removing Messages';
                LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
             end;

             BlockRead(F1,Buffer,MESSAGES_SIZE);

             {create new log entry}
             with Directory^.DiskHdr do begin
               DiskID   := A2s(Cust_Code,SizeOf(Cust_Code));
               SerialNo := A2S(Disk_Name,SizeOf(Disk_Name));

               Log := syDLio.New_System_Disk_Log_Rec;
               with Log^ do begin
                 dlDisk_ID         := SerialNo;
                 dlDate_Downloaded := CurrentDate;
                 dlNo_of_Accounts  := 0;
                 dlNo_of_Entries   := 0;
                 dlWas_In_Last_Download := True;
               end;

               AdminSystem.fdSystem_Disk_Log.Insert(Log);
             end;

             {extract data into a file}
             eFileName := DOWNLOADWORKDIR+ 'DATA.$$$';
             if debugMe then begin
                Msg := Format('Extracting Data into %s', [ eFileName ]);
                LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
             end;

             AssignFile(F2,eFileName);
             Rewrite(F2,1);
             try
               Repeat
                 BlockRead(F1,Buffer,Sizeof(Buffer),NumRead);
                 BlockWrite(F2,Buffer,NumRead,NumWritten);

                 if NumRead <> NumWritten then begin
                    Msg := Format('Error Writing Data to %s : NumRead <> NumWritten', [ eFileName ]);
                    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
                    raise EDownload.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
                 end;

               Until NumRead = 0;
             finally
               CloseFile(F2);
             end;
           finally
             CloseFile(F1);
           end;

           { ******************************************************************}
           {STEP 2:  Open the temporary data file for reading.  This is the DATA.$$$ file }
           {          Read the bank accounts and transaction and store in the archive directory}

           if debugMe then begin
              Msg := Format('ReOpening %s', [ eFileName ]);
              LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
           end;

           AssignFile(eFile,eFileName);
           Reset(eFile);
           try

           LastBlockNo := -1;
           For DirNo := 2 to 256 do With Directory^.AccInfo[DirNo] do Begin
              Key := A2S(Acc_Bank_Code,Sizeof(Acc_Bank_Code));
              if Key <> '' then begin
                UpdateAppStatusLine2('Account '+Key);

                if debugMe then begin
                   Msg := Format('Processing Account %s', [ Key ]);
                   LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
                end;

                Inc( Log^.dlNo_of_Accounts );

                {Find the bank account in the list, or create a new bank account}
                pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( Key );
                If not Assigned( pSB ) then Begin
                   pSB := New_System_Bank_Account_Rec;
                   With pSB^ do Begin
                      sbAccount_Number := Key;
                      sbAccount_Name   := A2S( Acc_Name,Sizeof( Acc_Name ) );

                      Inc( AdminSystem.fdFields.fdBank_Account_LRN_Counter );
                      sbLRN             := AdminSystem.fdFields.fdBank_Account_LRN_Counter ;
                      sbCurrent_Balance := Unknown;
                      sbNew_This_Month  := TRUE;
                      sbAttach_Required := TRUE;  {very important}
                      AdminSystem.fdSystem_Bank_Account_List.Insert( pSB );
                   end;
                end;

                With pSB^ do Begin
                   sbWas_On_Latest_Disk := true;
                   sbCharges_This_Month := sbCharges_This_Month + Acc_Gross;
                   sbCost_Code          := A2S(Acc_TC_Code,Sizeof(Acc_Tc_Code));

                   {opening balance at bank}
                   if (Acc_File_Code[10] = #$01) then
                     sbCurrent_Balance := -Acc_Dr_Total
                   else
                     sbCurrent_Balance := Unknown;

                   ArchiveName := ArchiveFileName( sbLRN );
                   If BKFileExists( ArchiveName ) then Begin
                      if debugMe then begin
                         Msg := Format('Opening %s', [ ArchiveName ]);
                         LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
                      end;
                      Assign( ArchiveFile, ArchiveName );
                      Reset( ArchiveFile );

                      if debugMe then begin
                         Msg := Format('Seeking To EOF %s', [ ArchiveName ]);
                         LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
                      end;
                      Seek( ArchiveFile, FileSize(ArchiveFile ));
                   end
                   else Begin
                      if debugMe then begin
                         Msg := Format('Creating %s', [ ArchiveName ]);
                         LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + Msg);
                      end;
                      Assign( ArchiveFile, ArchiveName );
                      Rewrite( ArchiveFile );
                   end;

                  { ******************************************************************}
                  { STEP 3 : Now begin importing the transactions into the Archive Directory structure}

                   try
                     if Acc_eStart > 0 then for EntryNo := Acc_eStart to Acc_eFinish do begin
                       BlockNo := ((EntryNo-1)div 6);
                       SlotNo  := ((EntryNo-1)mod 6)+1;

                       if BlockNo <> LastBlockNo then begin
                         Seek(eFile, BlockNo);
                         Read(eFile, E);
                         LastBlockNo := BlockNo;
                       end;

                       with E.Slot[SlotNo], TranInf do begin
                          FillChar(TranInf,SizeOf(TranInf),0);
                          aRecord_End_Marker  := ArchUtil32.ARCHIVE_REC_END_MARKER;
                          aType         := dType;
                          aSource       := orBank;
                          aDate_Presented := dDate;
                          aReference      := A2S(dRefce,SizeOf(dRefce));

                          if (aType = 1) then begin
                            S := Trim(aReference);
                            While Length(S) > 6 do System.Delete(S,1,1);
                            aCheque_Number := Str2Long(S);
                          end;
                          aNarration      := '';
                          aStatement_Details  := A2S(dNarration, SizeOf(dNarration));
                          aParticulars    := A2S(dBankTypeCode,SizeOf(dBankTypeCode));
                          aAmount         := dAmount;

                          With AdminSystem.fdFields do Begin
                             Inc( fdTransaction_LRN_Counter );
                             aLRN := fdTransaction_LRN_Counter;
                          end;

                          Write( ArchiveFile, TranInf );

                          If Globals.PRACINI_CreateCSVFile then
                          Begin
                             write( CSV_File, '"', sbAccount_Number, '",' );
                             write( CSV_File, '"', Date2Str( aDate_Presented, 'dd/mm/yyyy' ), '",' );
                             write( CSV_File, '"', aType, '",' );
                             write( CSV_File, '"', aReference, '",' );
                             write( CSV_File, '"', aAmount/100:0:2, '",' );
                             write( CSV_File, '"', aStatement_Details, '"' );
                             writeln( CSV_File );
                          end;


                          If ( sbFrom_Date_This_Month = 0 ) or
                             ( aDate_Presented < sbFrom_Date_This_Month ) then
                             sbFrom_Date_This_Month := aDate_Presented;

                          If aDate_Presented > sbTo_Date_This_Month then
                             sbTo_Date_This_Month := aDate_Presented;

                          if aDate_Presented > sbLast_Entry_Date then
                             sbLast_Entry_Date := aDate_Presented;

                          sbLast_Transaction_LRN := aLRN;

                          If sbCurrent_Balance <> Unknown then
                             sbCurrent_Balance := sbCurrent_Balance + aAmount;

                          if aDate_Presented > HighestDate then
                            HighestDate := aDate_Presented;
                          if aDate_Presented < LowestDate then
                            LowestDate  := aDate_Presented;

                          Inc( sbNo_of_Entries_This_Month );
                          Inc( Log^.dlNo_of_Entries );
                          Inc( NumEntries );
                       end; {with}
                     end; { of data for this Bank Account }
                   finally
                      CloseFile( ArchiveFile );
                   end;
                end; { scope of pSB }
              end; {if key <> ''}
           end; { for }
           finally
             CloseFile(eFile);
             SysUtils.DeleteFile( eFileName );
             If Globals.PRACINI_CreateCSVFile then System.Close( CSV_File );
           end;
         end;
       finally {getmem}
         SafeFreeMem(Directory,Sizeof(TOZDirectory));
       end;

       { ******************************************************************}
       { STEP 4 : Cleanup and Update the Admin system                      }

       {At this point we have had a successful download of data from the disk into
        the Archive directory structure }

        AdminSystem.fdFields.fdDisk_Sequence_No := AdminSystem.fdFields.fdDisk_Sequence_No + Count;
        AdminSystem.fdFields.fdPIN_Number       := NewPin;
        if HighestDate <> 0 then begin
           AdminSystem.fdFields.fdPrint_Reports_Up_To := HighestDate;
           AdminSystem.fdFields.fdDate_of_Last_Entry_Received := HighestDate;
        end;

        SaveAdminSystem;
        AdminSystem.DownloadSave;  //save copy after succesful download

        UpdateAppStatus('Download Completed','Cleaning up', 100);
        LogUtil.LogMsg( lmInfo, UnitName, 'CRITICAL DOWNLOAD STAGE COMPLETED');

        {clean up disk images left over}
        for i := Count-1 downto 0 do begin
          fileName := AdminSystem.fdFields.fdBankLink_Code +'.'+ MakeSuffix(AdminSystem.fdFields.fdDisk_Sequence_No-i);
          LocalFileName := DownloadInBoxDir + FileName;
          SysUtils.DeleteFile(LocalFileName);

          LocalFileName := DownloadWorkDir + FileName;
          SysUtils.DeleteFile(LocalFileName);
        end;
        ClearStatus;

        //count no of accounts on disk(s)
        NumAccounts := 0;
        for i := 0 to Pred( AdminSystem.fdSystem_Bank_Account_List.ItemCount) do begin
           if AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At( i).sbWas_On_Latest_Disk then
              Inc( NumAccounts);
        end;

        Msg := 'Download Complete.  ' +
               inttoStr( NumAccounts) + ' accounts received. ' +
               inttoStr( NumEntries)  + ' entries from ' +
               bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + Msg);

        Msg := 'Download Complete.  '#13#13 +
               inttoStr( NumAccounts) + ' accounts received. '#13 +
               inttoStr( NumEntries)  + ' entries from ' +
               bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
        HelpfulInfoMsg(Msg,0);
     end
     else begin
       Msg := 'Cannot Download new information at this time.  Admin System cannot be loaded';
       HelpfulErrorMsg(Msg,0);
     end;
     {------------------------------------------------}
   finally
      ClearStatus;
   end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ProcessDownload;
begin
  try
    case AdminSystem.fdFields.fdCountry of
      whNewZealand : DoDownloadNZ;
      whAustralia  : DoDownloadOZ;
    end;
  except
     on E : EDownloadVerify do begin
        HelpfulErrorMsg('An error occurred while verifying the downloaded data.'+#13+#13+
                        E.Message+ #13+#13+
                        'Please contact '+SHORTAPPNAME+' support.',0);
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckArchive;
begin
   //check that test has not been disabled in the prac ini
   if not PRACINI_ValidateArchive then begin
      exit;
   end;
   //ensure that file LRN's match admin system LRN
   //will raise an exception if it fails
   CheckArchiveDirSynchronised;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadFromFloppy;
begin
  if not (AskYesNo('System Backup',
                   'You must back up your '+SHORTAPPNAME+' System before you Download from Floppy.'#13#13+
                   'Have you backed up your '+SHORTAPPNAME+' System?',DLG_YES,0) = DLG_YES) then
     Exit;

  if not RefreshAdmin then Exit;

  //Check integrity of the admin system before doing anything
  Admin32.IntegrityCheck;
  //ensure that file LRN's match admin system LRN
  CheckArchive;

  with AdminSystem.fdFields do begin
     if DoCopyFloppy(fdBankLink_Code,fdDisk_Sequence_No) <> -1 then
        ProcessDownload;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadFromBConnect;
begin
  if not (AskYesNo('System Backup',
                   'You must back up your '+SHORTAPPNAME+' System before you Download from ' + bkBranding.BConnectName + '.'#13#13+
                   'Have you backed up your '+SHORTAPPNAME+' System?',DLG_YES,0) = DLG_YES) then
     Exit;

  if not RefreshAdmin then  Exit;

  //Check integrity of the admin system before doing anything
  Admin32.IntegrityCheck;
  //ensure that file LRN's match admin system LRN
  CheckArchive;

  if DoBankLinkConnect <> -1 then
     ProcessDownload;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
