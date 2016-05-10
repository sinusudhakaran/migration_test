unit DownloadEx;
//------------------------------------------------------------------------------
{
   Title:       Download Routines

   Description:

   Author:      Matthew Hopkins  Sep 2002

   Remarks:     Replaces the old disk download routines with calls to new
                disk image object that is common to production and bk5 client
}
//------------------------------------------------------------------------------

interface

const
  ONLINE_OFFSITE_ACCOUNTS_FILE = 'onlineaccounts';
  ONLINE_OFFSITE_ACCOUNTS_DELIMITER = ',';

type
  TDownloadSource = ( dsFloppy, dsBConnect);

  procedure DownloadDiskImages( Source : TDownloadSource);


//******************************************************************************
implementation
uses
  Admin32,
  ArchiveCheck,
  ArchUtil32,
  banklinkConnect,
  bkconst,
  bkdateutils,
  bk5Except,
  bkhelp,
  classes,
  dbObj,              //disk image bank account obj
  DownloadFloppy,
  DownloadUtils,
  EnterPinDlg,
  ErrorMoreFrm,
  FHDefs,
  FHExceptions,
  GenUtils,
  Globals,
  InfoMoreFrm,
  LogUtil,
  MoneyDef,                                
  NFDiskObj,
  NZDiskObj,
  OZDiskObj,
  UKDiskObj,
  Progress,
  stDate,
  stDateSt,
  math,
  syDLio,
  sySBio,
  SysUtils,
  YesNoDlg,
  SYDEFS,
  BaseDisk,
  ECollect,
  dbList,
  SysObj32,
  SBAList32,
  dtList,
  WinUtils,
  Windows,
  Merge32,
  AuditMgr,
  clObj32,
  Files,
  DirUtils,
  CsvParser,
  SecureOnlineAccounts,
  WarningMoreFrm,
  ReportFileFormat,
  MainFrm;

resourcestring
  rsHelpErrorMsg = 'Incorrect PIN number entered. Please email %s '+
                   'Support requesting your Practice PIN number.  Note: You MUST email the request from a Practice email address.';

const
  UnitName = 'DownloadEx';
  S_VALIDATE_ERROR = 'Validate Error: Image name = %s but Disk File name = %s';
  
var
  DebugMe  : boolean;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogDebugMsg( aMsg : string);
begin
  if DebugMe then
  begin
    LogUtil.LogMsg( lmDebug, Unitname, aMsg);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ProcessChargesFile(Filename: string; Date: Tstdate);
var
   lFile, LLine: TStringList;
   I: Integer;
   NewDate: tStDate;
   NewBal: Money;
   SAccount: pSystem_Bank_Account_Rec;
const
   fcBanklinkCode = 0;
   fcAccNo = 1;
   fcAccName = 2;
   fcFileCode = 3;
   fcCostCode = 4;
   fcCharges = 5;
   fcTransCount = 6;
   fcNewAccount = 7;
   fcLoadChargeBilled = 8;
   fcOffsiteChargeIncluded = 9;
   fcIsActive = 10;
   fcBalace = 11;
   fcLastDate = 12;
   fcCurrency = 13;
   fcInstitution = 14;



   ThisMethodName  =  'ProcessChargesFile';

   procedure CheckNo(Value: string; var IsNo: Boolean );
   begin
      if Value > '' then
         IsNo := Upcase(VAlue[1]) = 'N'
   end;

   function CheckInvalidMoney(aMoney : Money):Money;
   var
    strMoney, strExponential : string;
    iPos : Integer;
   begin
    Result := aMoney;

    strMoney := FloatToStr(aMoney);
    if DebugMe then
    begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' FloatToStr(aMoney) ' + strMoney);
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' moneytostr(aMoney) ' + money2str(aMoney));
    end;

    // check E18 in 4.2346E18
    iPos := Pos('E', strMoney);
    if iPos > 0 then // if holds exponential floating value
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' found high floating value ' + strMoney);

      strExponential := Copy(strMoney, iPos, Length(strMoney)- iPos + 1);
      strExponential := StringReplace(strExponential, 'E','',[rfReplaceAll,rfIgnoreCase]);
      if StrToIntDef(strExponential,0) > 16 then
      begin
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' System balance reset to Unknown for bank account ' + SAccount.sbAccount_Number + ' ' + SAccount.sbAccount_Name);

        Result := Unknown;
      end;
    end;
   end;

   function Str2Money(Value:string; default:Money): Money;
   begin
      Value := StringReplace( Value, ',', '', [rfReplaceAll]);
      Value := StringReplace( Value, '(', '-', [rfReplaceAll]);
      Value := StringReplace( Value, ')', '', [rfReplaceAll]);

      Default := CheckInvalidMoney(default); // Check default is an invalid float value, then return Unknown constant
      if default = Unknown then
        Result := Unknown
      else
        Result := StrToFloatDef( Value, default) * 100;
   end;

   function CheckText(Value, Old: string): string;
   begin // Don't loose info
      if Value > '' then
         Result := Value
      else
         Result := Old;
   end;

begin
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := true;
      lFile.LoadFromFile(Filename);
      if LoadAdminSystem(True, ThisMethodName ) then begin
         for I := 1 to LFile.Count - 1 do begin // Skip the header
            lLine.DelimitedText := LFile[I];
            if lLine.Count < fcTransCount then
               Continue; // not likely to be correct..

            SAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(LLine[fcAccNo]);
            if not Assigned(SAccount) then begin
               SAccount := AdminSystem.NewSystemAccount(LLine[fcAccNo], False);
               SAccount.sbAccount_Name  := LLine[fcAccName];
            end;
            if DebugMe then
              LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Account in the system (' + SAccount.sbAccount_Number +') ' + SAccount.sbAccount_Name);

            // Update the rest of the details
            SAccount.sbBankLink_Code := CheckText(LLine[fcBanklinkCode], SAccount.sbBankLink_Code);

            if LLine.Count > fcIsActive then
               CheckNo(LLine[fcIsActive],SAccount.sbInActive);

            if SAccount.sbAccount_Type = sbtOffsite then begin
               // Don't update from here if they are delivered
               if (LLine.Count > fcBalace) then begin
                  if DebugMe then
                  begin
                    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' balance ' + LLine[fcBalace]);
                    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' SAccount.sbCurrent_Balance ' + FloatToStr(SAccount.sbCurrent_Balance));
                  end;

                  if SAccount.sbCurrent_Balance <> Unknown then                  
                    NewBal := Str2Money(LLine[fcBalace], SAccount.sbCurrent_Balance)
				  else
				  	NewBal := Unknown;

                  if (LLine.Count > fcLastDate) then begin
                     NewDate := bkStr2Date(LLine[fcLastDate]);

                     if NewDate >= SAccount.sbLast_Entry_Date then begin
                        SAccount.sbLast_Entry_Date := NewDate;
                        SAccount.sbCurrent_Balance := NewBal;
                     end;

                     if (LLine.Count > fcCurrency) then begin
                        SAccount.sbCurrency_Code:= CheckText(LLine[fcCurrency], SAccount.sbCurrency_Code);

                        if (LLine.Count > fcInstitution) then
                           SAccount.sbInstitution := CheckText(LLine[fcInstitution], SAccount.sbInstitution);
                     end;
                  end;
               end;

            end;

         end;
         // While we are here, and about to save..
         AdminSystem.fdFields.fdLast_ChargeFile_Date := Date;
         if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + 'Finished processing charge file');

         SaveAdminSystem;
      end;
   finally
      lFile.Free;
      lLine.Free;
   end;
end;


procedure ProcessChargesFiles;
const
  ThisMethodName = 'ProcessChargesFiles';
var
   BD, ED: TStDate;
   Filename: string;
begin
  // Find date range..
  ED := GetFirstDayOfMonth(CurrentDate);// Last expected end date..
  BD := AdminSystem.fdFields.fdLast_ChargeFile_Date;
  if BD = 0 then
     BD := IncDate(ED,0,-12,0); // Last Six months
  {else  That ok, at least we can test stuff...
     BD := IncDate(BD,0,1,0); // The month after..
  }
  while (BD < ED) do begin
     Filename := DownloadWorkDir + Date2Str (BD,'nnnyyyy') + RptFileFormat.Extensions[rfCSV];
     if BKFileExists(Filename) then begin
        ProcessChargesFile(Filename, BD);
     end;
     //Try the next  month...
     BD := IncDate(BD,0,1,0);
  end;

end;

procedure ProcessOnlineSecureAccountsFile(const FileName: String);

   function CheckText(Value, Old: string): string;
   begin
     // Don't loose info
     if Value > '' then
     begin
       Result := Value;
     end
     else
     begin
       Result := Old;
     end;
   end;
const
  ThisMethodName = 'ProcessOnlineSecureAccountsFile';
var
  AccountSource: TSecureOnlineAccounts;
  Index: Integer;
  SystemAccount: pSystem_Bank_Account_Rec;
begin
  if FileExists(FileName) then
  begin
    AccountSource := TSecureOnlineAccounts.Create;

    try
      AccountSource.LoadFromFile(FileName);
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + Filename + ' loaded');

      while not AccountSource.Eof do
      begin
        SystemAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(AccountSource.AccountNo);

        if not Assigned(SystemAccount) then
        begin
          SystemAccount := AdminSystem.NewSystemAccount(AccountSource.AccountNo, True);
          SystemAccount.sbAccount_Name  := AccountSource.AccountName;
        end;

        SystemAccount.sbAccount_Type := sbtOnlineSecure;

        {An account cannot be both a secure online account and an secure account}
        SystemAccount.sbBankLink_Code := '';
        
        SystemAccount.sbWas_On_Latest_Disk := true;

        SystemAccount.sbCost_Code := AccountSource.CostCode;
        SystemAccount.sbFile_Code := AccountSource.FileCode;

        SystemAccount.sbCore_Account_ID := StrToIntDef(AccountSource.CoreAccountID, 0);

        SystemAccount.sbSecure_Online_Code := AccountSource.SecureCode;

        AccountSource.Next;
      end;
    finally
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends');
      AccountSource.Free;
    end;
  end;
end;

procedure ProcessOnlineSecureAccountsFiles(const FilePath: String; out ErrorsOccurred: Boolean);
const
  ThisMethodName = 'ProcessOnlineSecureAccountsFiles';

var
  SearchRec: TSearchRec;
  SourceFile: String;
begin
  ErrorsOccurred := False;
  
  if SysUtils.FindFirst(AppendFileNameToPath(FilePath, '*.csv'), faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if CompareText(Copy(SearchRec.Name, 0, Length('OnlineAccounts_')), 'OnlineAccounts_') = 0 then
        begin
          try
            SourceFile := AppendFileNameToPath(FilePath, SearchRec.Name);

            if LoadAdminSystem(True, ThisMethodName) then
            begin
              try
                try
                  ProcessOnlineSecureAccountsFile(SourceFile);

                  SaveAdminSystem;
                except
                  on E:Exception do
                  begin
                    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' Could not import secure online accounts from file ' + SourceFile + '. ' + E.Message);

                    UnlockAdmin;

                    ErrorsOccurred := True;
                  end;
                end;
              finally
                DeleteFile(PChar(SourceFile));
              end;
            end
            else
            begin
              LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' Could not import secure online accounts. Could not open the system database.');

              ErrorsOccurred := True;

              Break;
            end;
          except
            on E:Exception do
            begin
              LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' Could not import secure online accounts. ' + E.Message);

              ErrorsOccurred := True;

              Break;
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);   
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ProcessDiskImages: Boolean;
//expand any available disk images and import transactions
const
  ThisMethodName = 'ProcessDiskImages';
var
  NumDisksToProcess : integer;

  FirstDiskImageNo  : integer;
  LastDiskImageNo   : integer;
  CurrentDiskNo     : integer;
  ImagesProcessed   : integer;

  aMsg              : string;

  DiskImage         : TNewFormatDisk;
  ImageVersion      : integer;
  ImageFilename     : string;
  i                 : integer;

  SerialNo          : string;
  NewPin            : integer;
  NameForPin        : string;

  wasDiskSeq        : integer;
  wasBankLinkCode   : string;
  wasLogCount       : integer;

  pDiskLogRec       : pSystem_Disk_Log_Rec;
  NumAccounts       : integer;
  NumEntries        : integer;
  HighestDate       : integer;
  LowestDate        : integer;

  CSV_File          : Text;
  CSV_Buf           : array[ 1..8192 ] of Byte;
  CSV_Filename      : String[80];

  DiskAccount       : TDisk_Bank_Account;
  SystemAccount     : pSystem_Bank_Account_Rec;

  daNo              : integer;  //index for account in disk image
  dtNo              : integer;  //index for transaction in disk image

  TxnFilename       : string;
  ArchiveFile       : File of TArchived_Transaction; { in ARCHUTIL32.pas }
  ArchiveTxn        : tArchived_Transaction;
  DiskTxn           : pDisk_Transaction_Rec;

  S                 : string;
  AttachmentsList   : TStringList;

  ClientAccountMap  : pClient_Account_Map_Rec;
  OnlineSecureAccountsErrors: Boolean;
begin //ProcessDiskImages
  Result := False;
  LogDebugMsg( ThisMethodName + ' starts');

  //get latest version of admin system
  if not RefreshAdmin then
    Exit;

  OnlineSecureAccountsErrors := False;

  //count how many disk images there are to process
  with AdminSystem.fdFields do
  begin
    NumDisksToProcess := NoOfNewFilesToDownload( fdBankLink_Code, DOWNLOADINBOXDIR, fdDisk_Sequence_No);

    if (NumDisksToProcess < 1) and (StartupParam_Action <> sa_Connect) then
    begin
      ProcessOnlineSecureAccountsFiles(Globals.DownloadWorkDir, OnlineSecureAccountsErrors);

      ProcessChargesFiles;// Still want to try this...

      HelpfulInfoMsg('There are no files to process.', 0);

      Exit;
    end;
  end;

  //---------------------------------------------------------------------------
  //verify disk images
  //
  //---------------------------------------------------------------------------

  FirstDiskImageNo := AdminSystem.fdFields.fdDisk_Sequence_No + 1;
  LastDiskImageNo  := AdminSystem.fdFields.fdDisk_Sequence_No + NumDisksToProcess;
  ImagesProcessed  := 0;

  UpdateAppStatus( 'Verifying Files', '', 0, ProcessMessages_On);
  LogUtil.LogMsg( lmInfo, UnitName, 'Verifying Files Started');
  try
    //verify each disk
    for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
    begin
      //determine disk filename and format
      if not GetFilenameAndFormat( AdminSystem.fdFields.fdBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
        raise EDownloadVerify.Create( 'Disk image not found for ' + inttostr( CurrentDiskNo));

      LogMsg( lmInfo, Unitname, 'Verifying Disk Image ' + DOWNLOADINBOXDIR + ImageFilename);
      UpdateAppStatusLine2( inttostr( ImagesProcessed + 1) + ' of ' + inttostr( NumDisksToProcess), ProcessMessages_On);

      //check that is not older version that last downloaded
      if not Globals.PRACINI_IgnoreDiskImageVersion then
      begin
        if ImageVersion < AdminSystem.fdFields.fdLast_Disk_Image_Version then
          raise EDownloadVerify.Create( 'The format of the file ' + ImageFilename +
                                        ' is older than the format required. '+
                                        '(Last = ' + inttostr( AdminSystem.fdFields.fdLast_Disk_Image_Version) +
                                        ' This = ' + inttostr( ImageVersion)+')');
      end;

      //do country check
      if not (AdminSystem.fdFields.fdCountry in [ whNewZealand, whAustralia, whUK]) then
        raise Exception.Create( 'Unknown Country in ' + ThisMethodName);

      //create disk image
      case AdminSystem.fdFields.fdCountry of
        whNewZealand : DiskImage := TNZDisk.Create;
        whAustralia : DiskImage := TOZDisk.Create;
        whUK  : DiskImage := TUKDisk.Create;
      else
        DiskImage := nil;
      end;

      try
        //load disk image, reraise any errors as EDownloadVerify so that
        //can be caught, otherwise will cause Critical Application Error
        try
          //no attachments list will be returned for these calls so no need to
          //free it
          if ImageVersion < 2 then
            DiskImage.LoadFromFileOF( DOWNLOADINBOXDIR + ImageFilename, '', false)
          else
            DiskImage.LoadFromFile( DOWNLOADINBOXDIR + ImageFilename, '', false);

          //validate disk image format
          DiskImage.Validate;

          if DiskImage.dhFields.dhTrue_File_Name <> ImageFilename then
            raise EDownloadVerify.CreateFmt( S_VALIDATE_ERROR, [ ImageFilename, DiskImage.dhFields.dhTrue_File_Name]);

        except
          On E : Exception do
          begin
            raise EDownloadVerify.Create( E.ClassName + ':' + E.Message);
          end;
        end;

        //check that we have the correct pin number for this disk
        if AdminSystem.fdFields.fdCountry = whNewZealand then
          NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 20))
        else
          NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 40));

        if not EnterPIN( DiskImage.dhFields.dhTrue_File_Name,
                         NameForPin, AdminSystem.fdFields.fdPIN_Number) then
        begin
          HelpfulErrorMsg(Format(rsHelpErrorMsg, [SHORTAPPNAME]), 0);
          Exit;
        end;
        //store new pin number so can save to admin system after it is reloaded
        NewPin := AdminSystem.fdFields.fdPIN_Number;

        //check that disk has not been downloaded already
        SerialNo := GetSerialNoForImage( AdminSystem.fdFields.fdCountry, DiskImage);
        with AdminSystem.fdSystem_Disk_Log do
        begin
          for  i := First to Last do
          begin
            if ( Disk_Log_At(i)^.dlDisk_ID = SerialNo) then
            begin
              aMsg := 'The file ' + DiskImage.dhFields.dhTrue_File_Name +
                      ' has already been downloaded.  You cannot download it '+
                      'more than once.';
              raise EDownloadVerify.Create( aMsg);
            end;
          end;
        end;

      finally
        DiskImage.Free;
      end;
      //move on to next disk
      Inc( ImagesProcessed);
      UpdateAppStatusPerc( (ImagesProcessed) / NumDisksToProcess * 100, ProcessMessages_On);
    end;

    //prepare work directory for use when importing
    if not DirectoryExists( Globals.DownloadWorkDir) then
    begin
      if not CreateDir( Globals.DownloadWorkDir) then
      begin
        aMsg := Format('Unable To Create Directory %s', [ Globals.DownloadWorkDir ]);

        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + aMsg );
        raise EDownloadVerify.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, aMsg ] );
      end;
    end;
  finally
    //clear progress window
    ClearStatus;
  end;

  //----------------------------------------------------------------------------
  //       IMPORT ready to begin - the files have been extracted into
  //       the WORK directory.  Now Cycle thru each file and extract
  //       data into the archive directory
  //
  //----------------------------------------------------------------------------
  wasDiskSeq      := AdminSystem.fdFields.fdDisk_Sequence_No;
  wasBankLinkCode := AdminSystem.fdFields.fdBankLink_Code;
  wasLogCount     := AdminSystem.fdSystem_Disk_Log.ItemCount;
  UpdateAppStatus( 'Downloading Files', '', 0, ProcessMessages_On);

  try
    if LoadAdminSystem(True, ThisMethodName ) then
    begin
      //check for changes to the admin system - might indicate someone else downloading
      //this code is probably never called because of the improvements made
      //to locking, however lets leave it here just in case
      if (AdminSystem.fdFields.fdDisk_Sequence_No <> wasDiskSeq) or
         (AdminSystem.fdFields.fdBankLink_Code <> wasBankLinkCode) or
         (AdminSystem.fdSystem_Disk_Log.ItemCount <> wasLogCount) then
      begin
        UnlockAdmin;

        aMsg := 'The Admin System has been changed during the verification Process.  '+
                'To ensure that there are no serious data conflicts you must restart '+
                'the Download Process.';
        HelpfulErrorMsg( aMsg, 0);
        exit;
      end;

      //initialise the admin system
      //this involves initialisinig accumulators and clearing out details
      //in existing admin accounts
      NumEntries  := 0;
      HighestDate := 0;
      LowestDate  := MaxInt;

      //store pin number as it may have changed
      AdminSystem.fdFields.fdPIN_Number := NewPin;

      with AdminSystem.fdSystem_Bank_Account_List do
      begin
        for i := First to Last do
        begin
          with System_Bank_Account_At(i)^ do
          begin
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

      //loop thru each disk, verify each disk
      ImagesProcessed := 0;
      for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
      begin
        //determine disk filename and format
        if not GetFilenameAndFormat( AdminSystem.fdFields.fdBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
          raise EDownload.Create( 'Disk image not found for ' + inttostr( CurrentDiskNo));

        LogMsg( lmInfo, Unitname, 'Processing Disk Image ' + DOWNLOADINBOXDIR + ImageFilename);
        UpdateAppStatus( 'Downloading File ' + ImageFilename, '', ImagesProcessed / NumDisksToProcess * 100, ProcessMessages_On);

        //create disk image
        case AdminSystem.fdFields.fdCountry of
          whNewZealand : DiskImage := TNZDisk.Create;
          whAustralia : DiskImage := TOZDisk.Create;
          whUK : DiskImage := TUKDisk.Create;
        else
          DiskImage := nil;
        end;

        try
          //load disk image, reraise any errors as EDownloadVerify so that
          //can be caught, otherwise will cause Critical Application Error
          try
            AttachmentsList := nil;
            try
              if ImageVersion < 2 then
                AttachmentsList := DiskImage.LoadFromFileOF( DOWNLOADINBOXDIR + ImageFilename, Globals.DownloadWorkDir, true)
              else
                AttachmentsList := DiskImage.LoadFromFile( DOWNLOADINBOXDIR + ImageFilename, Globals.DownloadWorkDir, true);
            finally
              AttachmentsList.Free;
            end;

            //validate disk image format
            DiskImage.Validate;

            if DiskImage.dhFields.dhTrue_File_Name <> ImageFilename then
              raise EDownloadVerify.CreateFmt( S_VALIDATE_ERROR, [ ImageFilename, DiskImage.dhFields.dhTrue_File_Name]);


            //store version no
            AdminSystem.fdFields.fdLast_Disk_Image_Version := ImageVersion;
          except
            On E : Exception do
            begin
              raise EDownload.Create( E.ClassName + ':' + E.Message);
            end;
          end;

          //create a new log entry and store serial no
          pDiskLogRec := syDLio.New_System_Disk_Log_Rec;
          with pDiskLogRec^ do
          begin
            //get the serial no for this image
            SerialNo := GetSerialNoForImage( AdminSystem.fdFields.fdCountry, DiskImage);
            dlDisk_ID              := SerialNo;
            dlDate_Downloaded      := CurrentDate;
            dlNo_of_Accounts       := 0;
            dlNo_of_Entries        := 0;
            dlWas_In_Last_Download := True;
            AdminSystem.fdSystem_Disk_Log.Insert( pDiskLogRec);
          end;

          //prepare the CSV file for this disk, this is required for backwards compatibility
          if Globals.PRACINI_CreateCSVFile then
          begin
            CSV_FileName := DownloadWorkDir + MakeSuffix( CurrentDiskNo) + '.CSV';
            LogMsg( lmInfo, Unitname, 'Exporting to ' + CSV_Filename);
            AssignFile( CSV_File, CSV_FileName );
            SetTextBuf( CSV_File, CSV_Buf );
            Rewrite( CSV_File );

            if AdminSystem.fdFields.fdCountry = whNewZealand then
              Writeln( CSV_File, '"Account Number","Date","Type","Reference","Analysis","Amount","Other Party","Particulars"' )
            else
              Writeln( CSV_File, '"Account Number","Date","Type","Reference","Amount","Narrative"' );
          end;

          try
            //have a good disk image, begin importing bank accounts and
            //transactions
            for daNo := DiskImage.dhAccount_List.First to DiskImage.dhAccount_List.Last do begin
              DiskAccount := DiskImage.dhAccount_List.Disk_Bank_Account_At( daNo);
              Inc( pDiskLogRec^.dlNo_of_Accounts );
              UpdateAppStatusLine2( DiskAccount.dbFields.dbAccount_Number, ProcessMessages_On);

              //find this bank account in the system, if not found create a new one
              SystemAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(DiskAccount.dbFields.dbAccount_Number);
              if not Assigned( SystemAccount) then
              begin
                 SystemAccount := AdminSystem.NewSystemAccount(DiskAccount.dbFields.dbAccount_Number, True);
                 SystemAccount.sbAccount_Name    := DiskAccount.dbFields.dbAccount_Name;
                 SystemAccount.sbCore_Account_ID := 0;
              end;

              {An account cannot be both a normal account and an online secure account}
              SystemAccount.sbSecure_Online_Code := '';
              
              //This can actualy change, over time, so update regardless.
              SystemAccount.sbInstitution := DiskAccount.dbFields.dbBank_Name;
              // Might have been introduced by the Charges
              // But is obviously delivered now.
              SystemAccount.sbAccount_Type := sbtData;
              // Similar..
              SystemAccount.sbBankLink_Code := Adminsystem.fdFields.fdBankLink_Code;
              if DiskAccount.dbFields.dbCurrency > '' then
                 SystemAccount.sbCurrency_Code := DiskAccount.dbFields.dbCurrency;

              //Update the systen account first available transaction date
              if (DiskAccount.dbFields.dbFirst_Transaction_Date > 0) then begin
                if (SystemAccount.sbFirst_Available_Date = 0) then
                   SystemAccount.sbFirst_Available_Date := DiskAccount.dbFields.dbFirst_Transaction_Date
                else
                   SystemAccount.sbFirst_Available_Date :=
                      Min(DiskAccount.dbFields.dbFirst_Transaction_Date,SystemAccount.sbFirst_Available_Date);

                //update the Earliest Download Date to the Client Account Map
                for i := AdminSystem.fdSystem_Client_Account_Map.First to
                   AdminSystem.fdSystem_Client_Account_Map.Last do begin
                      ClientAccountMap := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
                      if ClientAccountMap.amAccount_LRN = SystemAccount.sbLRN then begin
                         if (ClientAccountMap.amEarliest_Download_Date = 0) then
                            ClientAccountMap.amEarliest_Download_Date := DiskAccount.dbFields.dbFirst_Transaction_Date
                         else
                            ClientAccountMap.amEarliest_Download_Date :=
                               Min(DiskAccount.dbFields.dbFirst_Transaction_Date,ClientAccountMap.amEarliest_Download_Date);
                      end;
                   end;
              end;

              SystemAccount.sbWas_On_Latest_Disk := true;

              SystemAccount.sbAccount_Type := sbtData;
              if DiskAccount.dbFields.dbIs_Provisional then
                SystemAccount.sbAccount_Type := sbtProvisional;

              //set the closing balance if known,
              //NOTE:  The balances in the production system and disk image
              //       have the opposite sign to the client software
              //
              //       Prod'n                Client
              //       -ve = OD              -ve = IF
              //       +ve = IF              +ve = OD
              if DiskAccount.dbFields.dbOpening_Balance <> Unknown then
                SystemAccount.sbCurrent_Balance := -DiskAccount.dbFields.dbOpening_Balance
              else
                SystemAccount.sbCurrent_Balance := Unknown;

              if DiskAccount.dbFields.dbFrequency_ID <> SystemAccount.sbFrequency then begin
                SystemAccount.sbFrequency := DiskAccount.dbFields.dbFrequency_ID;
                SystemAccount.sbFrequency_Change_Pending := Byte(False);
              end;

              //The dbAccount_LRN is the unique core id
              if (DiskAccount.dbFields.dbAccount_LRN <> 0) then
              begin
                SystemAccount.sbCore_Account_ID := DiskAccount.dbFields.dbAccount_LRN;
              end;
              
              //now prepare archive txn file for transactions
              TxnFilename := ArchUtil32.ArchiveFileName( SystemAccount.sbLRN);

              if BKFileExists( TxnFilename) then
              begin
                LogDebugMsg( 'Opening Archive File ' + TxnFilename);

                AssignFile( ArchiveFile, TxnFilename);
                Reset( ArchiveFile);
                //move to the end of the file
                Seek( ArchiveFile, FileSize( ArchiveFile));
              end
              else
              begin
                LogMsg( lmInfo, Unitname, 'Creating Archive File ' + TxnFilename);

                AssignFile( ArchiveFile, TxnFilename);
                Rewrite( ArchiveFile);
              end;

              try
                //begin importing transaction for disk account and write out
                //to the txn file
                for dtNo := DiskAccount.dbTransaction_List.First to DiskAccount.dbTransaction_List.Last do
                begin
                  DiskTxn := DiskAccount.dbTransaction_List.Disk_Transaction_At( dtNo);
                  //clear archive transaction record
                  FillChar( ArchiveTxn, SizeOf( ArchiveTxn), 0);
                  //fill fields in transaction record
                  with ArchiveTxn do
                  begin
                    aRecord_End_Marker := ArchUtil32.ARCHIVE_REC_END_MARKER;

                    aCoreTransactionID     := DiskTxn.dtBankLink_ID;
                    aCoreTransactionIDHigh := DiskTxn.dtBankLink_ID_H;
                    aType              := DiskTxn.dtEntry_Type;
                    aSource            := BKCONST.orBank;
                    aDate_Presented    := DiskTxn.dtEffective_Date;
                    aReference         := DiskTxn.dtReference;
                    aStatement_Details := DiskTxn.dtNarration;  //statement details is limited to 200
                    aAmount            := DiskTxn.dtAmount;

                    if not AdminSystem.fdFields.fdIgnore_Quantity_In_Download then
                    begin
                      if DiskTxn.dtQuantity <> Unknown then
                        aQuantity := DiskTxn.dtQuantity * 10;
                    end;

                    //construct the cheque number from the reference field
                    case AdminSystem.fdFields.fdCountry of
                      whAustralia, whUK : begin
                        if (aType = 1) then begin
                          S := Trim( aReference);
                          //cheque no is assumed to be last 6 digits
                          if Length( S) > MaxChequeLength then
                            S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                          aCheque_Number := Str2Long( S);
                        end;
                      end;

                      whNewZealand : begin
                        if (aType in [0,4..9]) then begin
                          S := Trim( aReference);
                          //cheque no is assumed to be last 6 digits
                          if Length( S) > MaxChequeLength then
                            S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                          aCheque_Number := Str2Long( S);
                        end;
                      end;
                    end;

                    //set country specific fields
                    case AdminSystem.fdFields.fdCountry of
                      whAustralia, whUK : begin
                        aParticulars := DiskTxn.dtBank_Type_Code_OZ_Only;
                      end;
                      whNewZealand : begin
                        aParticulars := DiskTxn.dtParticulars_NZ_Only;
                        aOther_Party := DiskTxn.dtOther_Party_NZ_Only;
                        //the analysis column is padded to 12 char to maintain
                        //compatibility
                        aAnalysis    := GenUtils.PadStr( DiskTxn.dtAnalysis_Code_NZ_Only, 12, ' ');
                        aOrigBB      := DiskTxn.dtOrig_BB;

                        //statement details may need to be constructed for NZ
                        //clients because there is no corresponding field in the
                        //old disk image
                        if ( aStatement_Details = '') and
                           (( aOther_Party <> '') or ( aParticulars <> '')) then
                        begin
                          aStatement_Details := MakeStatementDetails( SystemAccount.sbAccount_Number,
                                                                      aOther_Party,
                                                                      aParticulars);
                        end;
                      end;
                    end;

                    //allocate new lrn for this transaction and write to txn file
                    Inc( AdminSystem.fdFields.fdTransaction_LRN_Counter);
                    aLRN := AdminSystem.fdFields.fdTransaction_LRN_Counter;

                    //transaction has been constructed
                    Write( ArchiveFile, ArchiveTxn);

                    //write CSV file if needed
                    if Globals.PRACINI_CreateCSVFile then
                    begin
                      if AdminSystem.fdFields.fdCountry = whNewZealand then
                      begin
                        Write( CSV_File, '"', SystemAccount.sbAccount_Number, '",' );
                        Write( CSV_File, '"', Date2Str( aDate_Presented, 'dd/mm/yyyy' ), '",' );
                        Write( CSV_File, '"', aType, '",' );
                        Write( CSV_File, '"', aReference, '",' );
                        Write( CSV_File, '"', aAnalysis, '",' );
                        Write( CSV_File, '"', aAmount/100:0:2, '",' );
                        Write( CSV_File, '"', aOther_Party, '",' );
                        Write( CSV_File, '"', aParticulars, '"' );
                        Writeln( CSV_File );
                      end
                      else
                      begin
                        Write( CSV_File, '"', SystemAccount.sbAccount_Number, '",' );
                        Write( CSV_File, '"', Date2Str( aDate_Presented, 'dd/mm/yyyy' ), '",' );
                        Write( CSV_File, '"', aType, '",' );
                        Write( CSV_File, '"', aReference, '",' );
                        Write( CSV_File, '"', aAmount/100:0:2, '",' );
                        Write( CSV_File, '"', aStatement_Details, '"' );
                        Writeln( CSV_File );
                      end;
                    end;

                    //update last transaction lrn for this bank account
                    SystemAccount.sbLast_Transaction_LRN := aLRN;

                    //update date range for this account
                    if ( SystemAccount.sbFrom_Date_This_Month = 0 ) or
                       ( aDate_Presented < SystemAccount.sbFrom_Date_This_Month )
                    then
                       SystemAccount.sbFrom_Date_This_Month := aDate_Presented;

                    if aDate_Presented > SystemAccount.sbTo_Date_This_Month then
                       SystemAccount.sbTo_Date_This_Month := aDate_Presented;

                    if aDate_Presented > SystemAccount.sbLast_Entry_Date then
                       SystemAccount.sbLast_Entry_Date := aDate_Presented;

                    //add transaction amount to current balance
                    //for AU the current balance will have been set to the opening balance
                    //for NZ the current balance will be whatever the user has set up
                    if SystemAccount.sbCurrent_Balance <> Unknown then
                       SystemAccount.sbCurrent_Balance := SystemAccount.sbCurrent_Balance + aAmount;

                    //record date range
                    if aDate_Presented > HighestDate then
                      HighestDate := aDate_Presented;
                    if aDate_Presented < LowestDate then
                      LowestDate  := aDate_Presented;
                  end; //with ArchiveTxn

                  Inc( SystemAccount.sbNo_of_Entries_This_Month );
                  Inc( pDiskLogRec^.dlNo_of_Entries );
                  Inc( NumEntries );
                end;  // disk transaction loop
              finally
                //close the txn file
                CloseFile( ArchiveFile);
              end;
            end;  //disk account loop
          finally
            if Globals.PRACINI_CreateCSVFile then
            begin
              CloseFile( CSV_File);
            end;
          end;
        finally
          DiskImage.Free;
        end;
        //move on to next image
        Inc( ImagesProcessed);
        Result := True; // did at least one...
        UpdateAppStatusPerc( ImagesProcessed / NumDisksToProcess * 90, ProcessMessages_On);
      end;

      //update last disk no in admin system
      AdminSystem.fdFields.fdDisk_Sequence_No := LastDiskImageNo;

      if HighestDate <> 0 then
      begin
        AdminSystem.fdFields.fdPrint_Reports_Up_To         := HighestDate;
        AdminSystem.fdFields.fdDate_of_Last_Entry_Received := HighestDate;
        if HighestDate > AdminSystem.fdFields.fdHighest_Date_Ever_Downloaded then
          AdminSystem.fdFields.fdHighest_Date_Ever_Downloaded := HighestDate;
      end;

      //*** Flag Audit ***
//      SystemAuditMgr.FlagAudit(atDownloadingData); - NOT AUDITED because same information is in Disk Log
      SystemAuditMgr.FlagAudit(arSystemBankAccounts);

      //save the updated admin system
      SaveAdminSystem;
      //backup admin to system.sav
      AdminSystem.DownloadSave;

      LogMsg( lmInfo, Unitname, 'CRITICAL DOWNLOAD STAGE COMPLETED');
      UpdateAppStatus( 'Download Complete, Cleaning Up', '', 90, ProcessMessages_On);

      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' LastDiskImageNo ' + IntToStr(LastDiskImageNo));

      //clean up processed disk images
      for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
      begin
        //determine disk filename and format
        if GetFilenameAndFormat( AdminSystem.fdFields.fdBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
        begin
          //delete disk image
          SysUtils.DeleteFile( DOWNLOADINBOXDIR + ImageFilename);
        end;
      end;

      UpdateAppStatus( 'Process Charges', '', 95, ProcessMessages_On);

      ProcessOnlineSecureAccountsFiles(Globals.DownloadWorkDir, OnlineSecureAccountsErrors);

      ProcessChargesFiles;

      ClearStatus;
      if Result then begin

         //build final message for user
         //count no of accounts on disk(s)
         NumAccounts := 0;
         for i := 0 to Pred( AdminSystem.fdSystem_Bank_Account_List.ItemCount) do
         begin
            if AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At( i).sbWas_On_Latest_Disk then
               Inc( NumAccounts);
         end;

         //TFS 13323 - there is no highest date if there are no transactions.
         if HighestDate = 0 then
            HighestDate := LowestDate;

         if (StartupParam_Action <> sa_Connect) then begin //Don't do if command line download
           aMsg := 'Download Complete.  ' +
               inttoStr( ImagesProcessed) + ' disk image(s). ' +
               inttoStr( NumAccounts) + ' accounts received. ' +
               inttoStr( NumEntries)  + ' entries';
           if NumEntries > 0 then
             aMsg := aMsg + ' from ' + bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate);
           aMsg := aMsg + '.';             
           LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + aMsg);

           aMsg := 'Download Complete.  '#13#13 +
               inttoStr( ImagesProcessed) + ' file(s) downloaded. '#13 +
               inttoStr( NumAccounts) + ' accounts received. '#13 +
               inttoStr( NumEntries)  + ' entries';
           if NumEntries > 0 then
             aMsg := aMsg + ' from ' + bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate);
           aMsg := aMsg + '.';             
           HelpfulInfoMsg(aMsg,0);
         end;
      end;
    end
    else //if load admin
    begin
      aMsg := 'Cannot Download New Information At This Time.  Admin System Cannot Be Loaded';
      HelpfulErrorMsg( aMsg, 0);
    end;
  finally
    //clear progress window
    ClearStatus;
  end;

  if OnlineSecureAccountsErrors then
  begin
    HelpfulWarningMsg('One or more errors occurred while importing online secure account files.  See the system log for more information.', 0);
  end;
      
  LogDebugMsg( ThisMethodName + ' ends');
end;

procedure UpdateClientAccounts;

  function FindSystemAccount(const BankAccountNumber: String): pSystem_Bank_Account_Rec;
  var
    Index: Integer;
  begin
    Result := nil;
    
    for Index := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount -1  - 1 do
    begin
      if CompareText(AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(Index).sbAccount_Number, BankAccountNumber) = 0 then
      begin
        Result := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(Index);

        Break;
      end;
    end;
  end;

var
  Index: Integer;
  AdminAccountIndex: Integer;
  Client: TClientObj;
begin
  for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount  - 1 do
  begin
    if AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Status = bkConst.fsNormal then
    begin
      try
        Client := nil;
        OpenAClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client, True);

        if Assigned(Client) then
        begin
          UpdateCoreAccountIds(Client, AdminSystem);

          DoClientSave(true, Client);
        end;
      except
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadDiskImages( Source : TDownloadSource);
//Note: Application Process Messages will be called during this procedure
var
  NumImagesFound : integer;
  OldStatusSilent: Boolean;
  MaintainMemScanStatus: boolean;
begin
  OldStatusSilent := StatusSilent;
  StatusSilent := False;

  try
    if (StartupParam_Action = 0) then
       if not (AskYesNo('Download data',
                     'You should back up your '+SHORTAPPNAME+' System before you download new data.'#13#13+
                     'Do you want to download now?',DLG_YES, BKH_The_download_process) = DLG_YES) then
          Exit;

    if not RefreshAdmin then
      Exit;

    //Check integrity of the admin system before doing anything
    Admin32.IntegrityCheck;
    //check that test has not been disabled in the prac ini
    if PRACINI_ValidateArchive then
    begin
      //ensure that file LRN's match admin system LRN
      //will raise an exception if it fails
      CheckArchiveDirSynchronised;
    end;                          
    //images found may return the following
    // -1 : user cancelled copy from floppy or bconnect
    //  0 : no new disks downloaded, user may be processing disks that are
    //      already in the directory
    //  n : number of new disks
    case Source of
      dsFloppy : begin
        with AdminSystem.fdFields do
        begin
          NumImagesFound := DoCopyFloppy(fdBankLink_Code,fdDisk_Sequence_No);
        end;
      end;

      dsBConnect :
      begin
        NumImagesFound := DoBankLinkConnect;
      end;
    else
      NumImagesFound := -1;
    end;
    //process disk images unless user pressed cancel
    if NumImagesFound <> -1 then
    begin
      try
        if ProcessDiskImages then
        begin
          //UpdateClientAccounts is used for update the core account id's for data upload however this causes a memory leak (because the client files are not freed
          //after being saved) as well as performance issues.  The core account id's are also updated when opening a client file and then performing the data
          //upload so this shouldnt be required anymore.
          //UpdateClientAccounts;
        
           // all done - now update processing status to show downloaded months
          if PRACINI_FastDownloadStatsUpdate then
          begin
            UpdateSystemDownloadIndicators;
          end
          else
          begin
            RefreshAllProcessingStatistics(True);
          end;
        end;
      except
        on E : EDownloadVerify do
        begin
           HelpfulErrorMsg('An error occurred while verifying the downloaded data.'+#13+#13+
                           E.Message+ #13+#13+
                           'Please contact '+SHORTAPPNAME+' support.',0);
        end;
      end;
    end;
  finally
    StatusSilent := OldStatusSilent;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
   //make sure unknown types match
   Assert( MoneyDef.Unknown = BaseDisk.Unknown, 'MoneyDef.Unknown = BaseDisk.Unknown');
end.

