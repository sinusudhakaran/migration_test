unit OffsiteDownload;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ Purpose:
  --------

  This unit will provide the ability to download disk images ,created by the
  BankLink production system, directly into a client file.


  BankLink Off-site Download Process:
  -------------------------

  The process for creating an off-site client is as follows

  1) A new client file will be created at the Practice.

  2) The client details dlg contains a tab for administration.  A user with
     administrator rights will have access to the check box on this tab which
     sets this  client up as an off-site client.  Once checked the panel for
     selecting how the download occurs, what the off-site clients BankLink
     code is, and what the last disk downloaded was, will become enabled.

     The transfer method can be set to BankLink Connect or Floppy Disk

  3) The client file is then checked out and installed on the off-site clients
     PC.

  4) Once a client file is setup as an off-site client a new menu item appears on
     the Other Functions menu.  This item "Download New Data" will begin the download
     process.  The transfer method used will be set by the selection in the
     Client Details|Administration tab.

     Once a disk image has been downloaded it will be processed automatically
     into the clients transactions.  The download will also be added to the list
     of downloaded disk images.

  Design Considerations:
  ----------------------

  Relevant Client Obj fields

      clBankLink_Connect_Password        : String[ 60 ];
      clPIN_Number                       : LongInt;
      clBankLink_Code                    : String[ 8 ];
      clDisk_Sequence_No                 : LongInt;
      clDownload_From                    : Byte;         // 0 = Admin System
                                                         // 1 = BankLink Connect
                                                         // 2 = Floppy Disk

  The itemCount of clDisk_Log can be used to determine if any off-site downloads
  have occured.

  Master memorised entries will not be available for off-site clients.
  Master memorised entries will not be added to the client file when it is checked out.

  The check in process will be altered to allow files to be checked in that have
  a file status of off-site.  The file status Off-site is equivalent to Checked Out.
  The off-site status can be reset in ViewClientFileDlg.

  The Off-site checkbox can be unchecked until such time as an off-site
  download has been done for that client.  Once an off-site download has
  occured it is no longer possible for this client to receive data from the
  admin system, attach new bank accounts, or use master memorised entries.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

  procedure DoOffsiteDownloadEx;

//******************************************************************************
implementation
uses
  Autocode32,
  BankLinkConnect,
  baobj32,
  bk5Except,
  bkconst,
  bkDefs,
  bkDLIO,
  bkTXIO,
  bkDateUtils,
  classes,
  dbObj,              //disk image bank account obj
  DownloadFloppy,
  DownloadUtils,
  EnterPINdlg,
  ErrorMoreFrm,
  FHDefs,
  FHExceptions,
  GenUtils,
  globals,
  InfoMoreFrm,
  LogUtil,
  MoneyDef,
  NFDiskObj,
  NZDiskObj,
  OZDiskObj,
  UKDiskObj,
  ovcDate,
  Progress,
  stDatest,
  SysUtils,
  UEList32,
  Windows,
  YesNoDlg;

const
   UnitName = 'OFFSITEDOWNLOAD';
   S_VALIDATE_ERROR = 'Validate Error: Image name = %s but Disk File name = %s';
var
   DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogDebugMsg( aMsg : string);
begin
  if DebugMe then
  begin
    LogUtil.LogMsg( lmDebug, Unitname, aMsg);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ProcessDiskImages;
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
  NameForPin        : string;

  pDiskLogRec       : pDisk_Log_Rec;
  NumAccounts       : integer;
  NumEntries        : integer;
  HighestDate       : integer;
  LowestDate        : integer;

  DiskAccount       : TDisk_Bank_Account;
  DiskTxn           : pDisk_Transaction_Rec;
  ClientAccount     : TBank_Account;
  pT                : pTransaction_Rec;

  daNo              : integer;  //index for account in disk image
  dtNo              : integer;  //index for transaction in disk image

  S                 : string;

  UEList            : tUEList;
  UE                : pUE;
  TrxChequeNo       : Integer;
  TrxAmount         : Money;
  TrxType           : Byte;
  TrxDate           : integer;
  TrxReference      : string[12];

  FirstDateThisAccount,
  LastDateThisAccount,
  NoForAccount      : integer;

  AttachmentsList   : TStringList;
  AccountsList      : TStringList;
begin
  LogDebugMsg( ThisMethodName + ' starts');

  //count how many disk images there are to process
  with MyClient.clFields do begin
     NumDisksToProcess := NoOfNewFilesToDownload( clBankLink_Code, DOWNLOADINBOXDIR, clDisk_Sequence_No);
     if NumDisksToProcess < 1 then
       Exit;
  end;

  //---------------------------------------------------------------------------
  //verify disk images
  //
  //---------------------------------------------------------------------------

  FirstDiskImageNo := MyClient.clFields.clDisk_Sequence_No + 1;
  LastDiskImageNo  := MyClient.clFields.clDisk_Sequence_No + NumDisksToProcess;
  ImagesProcessed  := 0;

  UpdateAppStatus( 'Verifying Files', '', 0, ProcessMessages_On);
  LogUtil.LogMsg( lmInfo, UnitName, 'Verifying Files Started');
  try
    //verify each disk
    for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
    begin
      //determine disk filename and format
      if not GetFilenameAndFormat( MyClient.clFields.clBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
        raise EDownloadVerify.Create( 'Disk image not found for ' + inttostr( CurrentDiskNo));

      LogMsg( lmInfo, Unitname, 'Verifying Disk Image ' + DOWNLOADINBOXDIR + ImageFilename);
      UpdateAppStatusLine2( inttostr( ImagesProcessed + 1) + ' of ' + inttostr( NumDisksToProcess), ProcessMessages_On);

      //check that is not older version that last downloaded
      if not Globals.PRACINI_IgnoreDiskImageVersion then
      begin
        if ImageVersion < MyClient.clFields.clLast_Disk_Image_Version then
          raise EDownloadVerify.Create( 'The format of the file ' + ImageFilename +
                                        ' is older than the format required. '+
                                        '(Last = ' + inttostr( MyClient.clFields.clLast_Disk_Image_Version) +
                                        ' This = ' + inttostr( ImageVersion)+ ')');
      end;

      //do country check
      if not ( MyClient.clFields.clCountry in [whNewZealand, whAustralia]) then
        raise Exception.Create( 'Unknown Country in ' + ThisMethodName);

      //create disk image
      case MyClient.clFields.clCountry of
        whNewZealand : DiskImage := TNZDisk.Create;
        whAustralia  : DiskImage := TOZDisk.Create;
        whUK  : DiskImage := TUKDisk.Create;
      else
        DiskImage := nil;
      end;

      try
        //load disk image, reraise any errors as EDownloadVerify so that
        //can be caught, otherwise will cause Critical Application Error
        try
          //no need to free attachements for these calls as will be nil
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
        if MyClient.clFields.clCountry = whNewZealand then
          NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 20))
        else
          NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 40));

        if not EnterPIN( DiskImage.dhFields.dhTrue_File_Name,
                         NameForPin, MyClient.clFields.clPIN_Number) then
        begin
          HelpfulErrorMsg( 'Incorrect PIN Number Entered.  Please contact ' +
                           MyClient.clFields.clPractice_Name +
                           ' to obtain your PIN number.',0);
          Exit;
        end;

        //check that disk has not been downloaded already
        SerialNo := GetSerialNoForImage( MyClient.clFields.clCountry, DiskImage);
        with MyClient.clDisk_Log do
        begin
          for  i := First to Last do
          begin
            if ( Disk_Log_At(i)^.dlDisk_ID = SerialNo) then
            begin
              aMsg := 'The file ' + DiskImage.dhFields.dhFile_Name +
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
    if not DirectoryExists( Globals.DownloadOffsiteWorkDir) then
    begin
      if not CreateDir( Globals.DownloadOffsiteWorkDir) then
      begin
        aMsg := Format('Unable To Create Directory %s', [ Globals.DownloadOffsiteWorkDir ]);

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
  try
    //initialise accumulators
    NumEntries  := 0;

    HighestDate := 0;
    LowestDate  := MaxInt;
    //NumAccounts := 0;

    //crashes or error before this point will not affect the admin system or
    //transaction files in the archive dir.
    //Errors after this will require a restore
    LogUtil.LogMsg( lmInfo, UnitName, 'DOWNLOAD STARTED');

    //build final message for user
    //count no of accounts on disk(s)
    NumAccounts := 0;
    AccountsList := TStringList.Create;
    try
      //loop thru each disk, verify each disk
      ImagesProcessed := 0;
      for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
      begin
        //determine disk filename and format
        if not GetFilenameAndFormat( MyClient.clFields.clBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
          raise EDownload.Create( 'Disk image not found for ' + inttostr( CurrentDiskNo));

        LogMsg( lmInfo, Unitname, 'Processing Disk Image ' + DOWNLOADINBOXDIR + ImageFilename);
        UpdateAppStatus( 'Downloading File ' + ImageFilename, '', ImagesProcessed / NumDisksToProcess * 100, ProcessMessages_On);

        //create disk image
        case MyClient.clFields.clCountry of
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
                AttachmentsList := DiskImage.LoadFromFileOF( DOWNLOADINBOXDIR + ImageFilename, Globals.DownloadOffsiteWorkDir, true)
              else
                AttachmentsList := DiskImage.LoadFromFile( DOWNLOADINBOXDIR + ImageFilename, Globals.DownloadOffsiteWorkDir, true);
            finally
              AttachmentsList.Free;
            end;

            //validate disk image format
            DiskImage.Validate;

            if DiskImage.dhFields.dhTrue_File_Name <> ImageFilename then
              raise EDownloadVerify.CreateFmt( S_VALIDATE_ERROR, [ ImageFilename, DiskImage.dhFields.dhTrue_File_Name]);

            //store version no
            MyClient.clFields.clLast_Disk_Image_Version := ImageVersion;
          except
            On E : Exception do
            begin
              raise EDownload.Create( E.ClassName + ':' + E.Message);
            end;
          end;

          //create a new log entry and store serial no
          pDiskLogRec := bkDLio.New_Disk_Log_Rec;
          with pDiskLogRec^ do
          begin
            //get the serial no for this image
            SerialNo  := GetSerialNoForImage( MyClient.clFields.clCountry, DiskImage);
            dlDisk_ID              := SerialNo;
            dlDate_Downloaded      := CurrentDate;
            dlNo_of_Accounts       := 0;
            dlNo_of_Entries        := 0;
            MyClient.clDisk_Log.Insert( pDiskLogRec);
          end;
          MyClient.clFields.clSuppress_Check_For_New_Txns := true;

          //have a good disk image, begin importing bank accounts and transactions
          for daNo := DiskImage.dhAccount_List.First to DiskImage.dhAccount_List.Last do begin
            DiskAccount := DiskImage.dhAccount_List.Disk_Bank_Account_At( daNo);

            FirstDateThisAccount := 0;
            LastDateThisAccount  := 0;
            NoForAccount := 0;

            Inc( pDiskLogRec^.dlNo_of_Accounts );

            if (AccountsList.IndexOf(DiskAccount.dbFields.dbAccount_Number) = -1) then
              AccountsList.Add(DiskAccount.dbFields.dbAccount_Number);

            //Inc( NumAccounts);

            UpdateAppStatusLine2( DiskAccount.dbFields.dbAccount_Number, ProcessMessages_On);

            //find this bank account in the client, if not found create a new one
            ClientAccount := MyClient.clBank_Account_List.FindCode( DiskAccount.dbFields.dbAccount_Number);
            if not Assigned( ClientAccount) then
            begin
              ClientAccount := TBank_Account.Create;
              with ClientAccount.baFields do
              begin
                baAccount_Type        := btBank;
                baBank_Account_Number := DiskAccount.dbFields.dbAccount_Number;
                baBank_Account_Name   := DiskAccount.dbFields.dbAccount_Name;
                if DiskAccount.dbFields.dbCurrency > '' then
                   baCurrency_Code := DiskAccount.dbFields.dbCurrency
                else
                   baCurrency_Code := whCurrencyCodes[ MyClient.clFields.clCountry ];

                baCurrent_Balance     := UNKNOWN;
                baApply_Master_Memorised_Entries := false;
                baDesktop_Super_Ledger_ID := -1;                
              end;
              //insert new bank account in the list of accounts           
              MyClient.clBank_Account_List.Insert( ClientAccount);
            end;
            //set the opening balance if known
            //NOTE:  The balances in the production system and disk image
            //       have the opposite sign to the client software
            //
            //       Prod'n                Client
            //       -ve = OD              -ve = IF
            //       +ve = IF              +ve = OD
            if (DiskAccount.dbFields.dbOpening_Balance <> Unknown) and (ClientAccount.baFields.baCurrent_Balance = Unknown) then
            begin
              ClientAccount.baFields.baCurrent_Balance := -DiskAccount.dbFields.dbOpening_Balance;
            end;

            //construct a list to handle unpresented entries
            UEList    := MakeUEList( ClientAccount);
            try
              //begin importing transaction for disk account
              for dtNo := DiskAccount.dbTransaction_List.First to DiskAccount.dbTransaction_List.Last do
              begin
                DiskTxn := DiskAccount.dbTransaction_List.Disk_Transaction_At( dtNo);

                TrxAmount            := DiskTxn.dtAmount;
                TrxType              := DiskTxn.dtEntry_Type;
                TrxReference         := DiskTxn.dtReference;
                TrxDate              := DiskTxn.dtEffective_Date;
                TrxChequeNo          := 0;

                //construct the cheque number from the reference field
                case MyClient.clFields.clCountry of
                  whAustralia : begin
                    if (TrxType = 1) then begin
                      S := Trim( TrxReference);
                      //cheque no is assumed to be last 6 digits
                      if Length( S) > MaxChequeLength then
                        S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                      TrxChequeNo := Str2Long( S);
                    end;
                  end;

                  whNewZealand : begin
                    if (TrxType in [0,4..9]) then begin
                      S := Trim( TrxReference);
                      //cheque no is assumed to be last 6 digits
                      if Length( S) > MaxChequeLength then
                        S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                      TrxChequeNo := Str2Long( S);
                    end;
                  end;
                end;

                //try to match the new transaction with a unpresented item
                UE := nil;
                if Assigned( UEList) and ( TrxChequeNo <> 0) and ( TrxAmount <> 0) then
                  UE := UEList.FindUEByNumberAndAmount( TrxChequeNo, TrxAmount);

                if Assigned( UE) then
                begin
                  if ( UE^.Presented <> 0) or ( UE^.Issued > TrxDate) then
                    UE := nil;
                end;

                if Assigned( UE) then
                begin
                  //an unpresented cheque has been found that matches
                  //both the amount and the cheque number.
                  //update UPC to show that has been matched
                  UE^.ptr^.txUPI_State          := upMatchedUPC;
                  UE^.ptr^.txDate_Presented     := TrxDate;
                  UE^.Presented                 := TrxDate;
                  UE^.ptr^.txOriginal_Reference := TrxReference;
                  UE^.ptr^.txOriginal_Source    := orBank;
                  UE^.ptr^.txOriginal_Type      := TrxType;
                  UE^.ptr^.txOriginal_Amount    := TrxAmount;
                  UE^.ptr^.txOriginal_Cheque_Number := TrxChequeNo;
                end
                else
                begin
                  //no unpresented item to match with, this is a NEW TRANSACTION
                  pT := ClientAccount.baTransaction_List.New_Transaction;

                  pT^.txType               := TrxType;
                  pT^.txSource             := BKCONST.orBank;
                  pT^.txDate_Presented     := TrxDate;
                  pT^.txDate_Effective     := TrxDate;
                  pT^.txDate_Transferred   := 0;
                  pT^.txAmount             := TrxAmount;
                  pT^.txCheque_Number      := TrxChequeNo;
                  pT^.txReference          := TrxReference;
                  pT^.txStatement_Details  := Copy( DiskTxn.dtNarration, 1, 200);
                  pT^.txSF_Member_Account_ID:= -1;
                  pT^.txSF_Fund_ID          := -1;

                  if DiskTxn.dtQuantity <> Unknown then
                    pT^.txQuantity := ForceSignToMatchAmount( DiskTxn.dtQuantity * 10, pT^.txAmount)
                  else
                    pT^.txQuantity := 0;

                  //set country specific fields
                  case MyClient.clFields.clCountry of
                    whAustralia : begin
                      pT^.txParticulars := DiskTxn.dtBank_Type_Code_OZ_Only;
                    end;
                    whNewZealand : begin
                      pT^.txParticulars := DiskTxn.dtParticulars_NZ_Only;
                      pT^.txOther_Party := DiskTxn.dtOther_Party_NZ_Only;
                      //the analysis column is padded to 12 char to maintain
                      //compatibility
                      pT^.txAnalysis    := GenUtils.PadStr( DiskTxn.dtAnalysis_Code_NZ_Only, 12, ' ');
                      pT^.txOrigBB      := DiskTxn.dtOrig_BB;
                      //statement details may need to be constructed for NZ
                      //clients because there is no corresponding field in the
                      //old disk image
                      if ( pT^.txStatement_Details = '') and
                         (( pT^.txOther_Party <> '') or ( pT^.txParticulars <> '')) then
                      begin
                        pT^.txStatement_Details := MakeStatementDetails( ClientAccount.baFields.baBank_Account_Number,
                                                                         pT^.txOther_Party, pT^.txParticulars);
                      end;
                    end;
                  end;

                  pT^.txGL_Narration := pT^.txStatement_Details;
                  pT^.txBank_Seq     := ClientAccount.baFields.baNumber;

                  //fields populated, add transaction to list
                  ClientAccount.baTransaction_List.Insert_Transaction_Rec( pT);
                end;

                //add transaction amount to current balance
                //for AU the current balance will have been set to the opening balance
                //for NZ the current balance will be whatever the user has set up
                if ClientAccount.baFields.baCurrent_Balance <> Unknown then
                   ClientAccount.baFields.baCurrent_Balance := ClientAccount.baFields.baCurrent_Balance + TrxAmount;

                //update transaction date range for this account only
                If (FirstDateThisAccount = 0) or ((FirstDateThisAccount>0) and (TrxDate < FirstDateThisAccount)) then
                   FirstDateThisAccount := TrxDate;
                If (TrxDate > LastDateThisAccount) then
                   LastDateThisAccount := TrxDate;

                //update transaction date range for all accounts
                If ( TrxDate < LowestDate) then
                   LowestDate := TrxDate;
                If ( TrxDate > HighestDate) then
                   HighestDate := TrxDate;

                Inc( pDiskLogRec^.dlNo_of_Entries );
                Inc( NumEntries );
                Inc( NoForAccount );
              end;  // disk transaction loop
            finally
              UEList.Free;
            end;

            //log stats for this account
            LogDebugMsg( 'Imported ' + inttostr( NoForAccount) + ' entries for ' +
                         'account ' + ClientAccount.baFields.baBank_Account_Number);

            //auto code entries
            if NoForAccount > 0 then
            begin
              LogDebugMsg( 'Autocoding Entries');
              AutoCodeEntries( MyClient,
                               ClientAccount,
                               AllEntries,
                               FirstDateThisAccount,
                               LastDateThisAccount);
            end;
          end;  //disk account loop
        finally
          DiskImage.Free;
        end;
        //move on to next image
        Inc( ImagesProcessed);
        UpdateAppStatusPerc( ImagesProcessed / NumDisksToProcess * 100, ProcessMessages_On);
      end;
    finally
      NumAccounts := AccountsList.Count;
      AccountsList.Free;
    end;

    //update last disk no in admin system
    MyClient.clFields.clDisk_Sequence_No := LastDiskImageNo;

    LogMsg( lmInfo, Unitname, 'DOWNLOAD COMPLETED');
    UpdateAppStatus( 'Download Complete, Cleaning Up', '', 99, ProcessMessages_On);

    //clean up processed disk images
    for CurrentDiskNo := FirstDiskImageNo to LastDiskImageNo do
    begin
      //determine disk filename and format
      if GetFilenameAndFormat( MyClient.clFields.clBankLink_Code, DOWNLOADINBOXDIR, CurrentDiskNo, ImageFilename, ImageVersion) then
      begin
        //delete disk image
        SysUtils.DeleteFile( DOWNLOADINBOXDIR + ImageFilename);
      end;
    end;
    ClearStatus;

    //build final message for user
    aMsg := 'Download Complete.  ' +
           inttoStr( ImagesProcessed) + ' disk image(s). ' +
           inttoStr( NumAccounts) + ' accounts received. ' +
           inttoStr( NumEntries)  + ' entries from ' +
           bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
    LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' - ' + aMsg);

    aMsg := 'Download Complete.  '#13#13 +
           inttoStr( ImagesProcessed) + ' file(s) downloaded. '#13 +
           inttoStr( NumAccounts) + ' accounts received. '#13 +
           inttoStr( NumEntries)  + ' entries from ' +
           bkDate2Str( LowestDate) + ' to ' + bkDate2Str( HighestDate) + '.';
    HelpfulInfoMsg(aMsg,0);
  finally
    //clear progress window
    ClearStatus;
  end;

  LogDebugMsg( ThisMethodName + ' ends');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoOffsiteDownloadEx;
var
  NumImagesFound : integer;
begin
  if ( MyClient.clFields.clDownload_From = dlAdminSystem ) then exit;
  //images found may return the following
  // -1 : user cancelled copy from floppy or bconnect
  //  0 : no new disks downloaded, user may be processing disks that are
  //      already in the directory
  //  n : number of new disks
  case MyClient.clFields.clDownload_From of
    dlFloppyDisk : begin
      with MyClient.clFields do
      begin
        NumImagesFound := DoCopyFloppy(clBankLink_Code,clDisk_Sequence_No);
      end;
    end;
    dlBankLinkConnect :
    begin
      NumImagesFound := DoBankLinkOffsiteConnect;
    end;
  else
    NumImagesFound := -1;
  end;

  //process disk images unless user pressed cancel
  if NumImagesFound <> -1 then
  begin
    try
      ProcessDiskImages;
    except
      on E : EDownloadVerify do
      begin
         HelpfulErrorMsg('An error occured while verifying the downloaded data.'+#13+#13+
                         E.Message+ #13+#13+
                         'Please contact '+SHORTAPPNAME+' support.',0);
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
