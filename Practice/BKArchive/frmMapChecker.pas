// Check for duplicates in client files case #7218
unit frmMapChecker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MoneyDef, ComCtrls;

type
  TMainForm = class(TForm)
    btnCheck: TButton;
    sbStatus: TStatusBar;
    moResults: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    chkFix: TCheckBox;
    btnPrint: TButton;
    moFixed: TMemo;
    moManual: TMemo;
    moTemp: TMemo;
    pBar: TProgressBar;
    procedure btnCheckClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
   EUpgradeAdmin = class( Exception);

   TStoredTx = class
    Date: Integer;
    Amount: Money;
    TheType: Byte;
    Reference: String[12];              
    Particulars: String[12];
    Analysis: String[12];
    Other_Party: String[20];
    Statement_Details: String[200];
    ACNumber: string[20];
    ChequeNo: Integer;
   end;

var
  MainForm: TMainForm;
  HasRun: Boolean;

implementation

uses Admin32, Globals, SyDefs, baobj32, clobj32, Files, bufFStrm, WinUtils,
  ArchUtil32, bk5except, backup, bkdateutils, genutils, uprintpreview,
  shellapi, sysobj32, bkdefs, bkconst, mailfrm, inisettings, login32, stdate, stdatest;

{$R *.dfm}

// Restore a backup zip into a temp folder
function RestoreArchive( const FileTypes : TSetOfByte; const filename: string) : boolean;
var
  RestoreObj    : TBkRestore;
  aMsg         : string;
begin
  try
    RestoreObj := TBkRestore.Create;
    try
      RestoreObj.ZipFilename := filename;
      RestoreObj.FileTypesToExtract := FileTypes;
      RestoreObj.ExtractToDir := DataDir + 'ArchiveCheck\';
      RestoreObj.RootDir     := DataDir;
      RestoreObj.DoAll := True;
      RestoreObj.RecreateDirs := True;
      RestoreObj.UnZipFiles;
    finally
      RestoreObj.Free;
    end;
  except
    On E : Exception do
    begin
      aMsg := 'Restore Failed. ' + E.Message + ' [' + E.Classname + ']';
      ShowMessage( aMsg);
    end;
  end;
  Result := true;
end;

// Delete a folder and all its subfolders and files
Procedure DeleteFilesInDir( directory: String );
 Var
   OpStruct:TSHFileOpStruct;
 Begin
   { Check the passed parameter, make sure it is not empty. }
   If Length(directory) = 0 Then Exit;

   { Make sure that the passed directory name is terminated by a double #0.
     The following method works even if long strings are disabled. }
   AppendStr( directory, #0#0 );
   Fillchar( OpStruct, Sizeof(OpStruct), 0);
   With OpStruct Do Begin
     Wnd:=GetActiveWindow;
     wFunc:=FO_DELETE;
     pFrom:= @directory[1];
     fFlags:=FOF_ALLOWUNDO or FOF_SILENT or FOF_NOCONFIRMATION;
   End; { With }
   SHFileOperation(OpStruct);
End; { DeleteFilesInDir }


procedure TMainForm.btnCheckClick(Sender: TObject);
const
  uaBuffSize = 8192;
var
  i, j, k, m, p, NumRead: Integer;
  sba: pSystem_Bank_Account_Rec;
  cf: pClient_File_Rec;
  OriginalFileName, ShortName: string;
  OldFile : TbfsBufferedFileStream;
  CurrentArchRec, LastArchRec, ReadArchRec : tArchived_Transaction;
  FErrors, WarnedThisClient, ManualCheck, FirstLogForThisClientFixed,
  FirstLogForThisClientManual, FileWasChanged: Boolean;
  s, otherfiles, bk5files, INIFile: TStringList;
  aClient: TClientObj;
  BA: TBank_Account;
  tr, trComp, trUPC: pTransaction_Rec;
  Tx: TStoredTx;
  AdminSnapshot : TSystemObj;
  BackupObj    : TBkBackup;
  ArcFilename : string;
  u: pUser_Rec;
begin
  if HasRun then
  begin
    ShowMessage('To re-run the check, you must re-start this application');
    exit;
  end;
  HasRun := True;
  FErrors := False;
  moResults.Lines.Clear;
  moResults.Clear;
  btnCheck.Enabled := False;
  LastArchRec.aLRN := -1;
  CurrentArchRec.aLRN := -1;
  s := TStringList.Create;
  otherfiles := TStringList.Create;
  bk5files := TStringList.Create;
  INIfile := TStringList.Create;
  try
    // Make sure we're in a BK5 folder
    if not AdminExists then
    begin
      MessageDlg('The BankLink Admin System (SYSTEM.DB) cannot be found.'#13'Please make sure ' +
        ExtractFileName(Application.ExeName) + ' is running from your BankLink Data Directory.',
        mtError, [mbOk], 0);
      exit;
    end;

    // unzip backup prior to 5.11
    if (not BKFileExists(DataDir + Edit1.Text)) or (Trim(Edit1.Text) = '') then
    begin
      ShowMessage('Could not find the backup Zip file. Please enter the filename manually.');
      exit;
    end;
    SHORTAPPNAME := 'BankLink Practice';
    LoginUser('');
    sbStatus.SimpleText := 'Loading admin system...';
    ReloadAdminAndTakeSnapshot(AdminSnapshot);
    if Adminsnapshot.fdFields.fdFile_Version < 90 then
    begin
      ShowMessage('You must upgrade to BankLink 5.11.0.1667 before running this utility.');
      moResults.Lines.Add('You must upgrade to version 5.11.0.1667');
      exit;
    end;
    for i := AdminSnapshot.fdSystem_User_List.First to AdminSnapshot.fdSystem_User_List.Last do
    begin
      u := AdminSnapshot.fdSystem_User_List.User_At(i);
      if u.usLogged_In then
      begin
        ShowMessage(u.usCode + ' is logged into BankLink Practice. All Users must be logged out before running this utility.');
        exit;
      end;
    end;
    sbStatus.SimpleText := 'Unzipping old archive...';
    RestoreArchive([ biSystemDb, biArchive ], DataDir + edit1.text);
    moResults.Lines.Add('BANKLINK PRACTICE ARCHIVE CHECKER LOG');
    moResults.Lines.Add('');
    moResults.Lines.Add('');
    moResults.Lines.Add('Run on ' + FormatDateTime('c', Now) + ' using archive ' + Edit1.Text);
    pBar.Max := AdminSnapshot.fdSystem_Client_File_List.ItemCount + AdminSnapshot.fdSystem_Bank_Account_List.ItemCount;
    // look through each archive file to build a list of transactions that
    // could be duplicated inside a client file
    // it will always be the final entry from the txn file
    for i := AdminSnapshot.fdSystem_Bank_Account_List.First to AdminSnapshot.fdSystem_Bank_Account_List.Last do
    begin
      pBar.StepIt;
      sba := AdminSnapshot.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
      sbStatus.SimpleText := 'Checking ' + sba.sbAccount_Number + '...';
      if sba.sbLast_Transaction_LRN > 0 then
      begin
        try
          // Redirect to our unzipped archive
          OriginalFileName := StringReplace(Uppercase(ArchUtil32.ArchiveFileName( sba.sbLRN)),
            '\ARCHIVE\', '\ARCHIVECHECK\ARCHIVE\', [rfReplaceAll]);
          Shortname := ExtractFilename( OriginalFilename);
          if BKFileExists( OriginalFilename) then
          begin
            LastArchRec.aLRN := -1;
            CurrentArchRec.aLRN := -1;
            // get last tx record from the file - this is the duplicated one
            OldFile := TbfsBufferedFileStream.Create( OriginalFilename, fmOpenRead, uaBuffSize);
            try
              repeat
                NumRead := OldFile.Read( ReadArchRec, SizeOf( tArchived_Transaction));
                if NumRead > 0 then
                begin
                  // we will also need the second to last entry to make sure
                  // the duplicate is not a real-life valid one (very rare?)
                  if CurrentArchRec.aLRN <> -1 then
                    LastArchRec := CurrentArchRec;
                  CurrentArchRec := ReadArchRec;
                  if NumRead <> SizeOf( tArchived_Transaction) then
                    raise Exception.Create( 'Stream Read error reading ' + OriginalFilename);
                end; // if NumRead > 0
              until NumRead = 0;
              // save the last tx
              Tx := TStoredTx.Create;
              Tx.Date := CurrentArchRec.aDate_Presented;
              Tx.Amount := CurrentArchRec.aAmount;
              Tx.TheType  := CurrentArchRec.aType;
              Tx.Reference := CurrentArchRec.aReference;
              Tx.Particulars := CurrentArchRec.aParticulars;
              Tx.Analysis := CurrentArchRec.aAnalysis;
              Tx.Other_Party := CurrentArchRec.aOther_Party;
              Tx.Statement_Details := CurrentArchRec.aStatement_Details;
              Tx.ChequeNo := CurrentArchRec.aCheque_Number;
              Tx.ACNumber := sba.sbAccount_Number;
              // was the last one a real-life duplicate?
              if (LastArchRec.aLRN <> -1) and
                 (LastArchRec.aDate_Presented = CurrentArchRec.aDate_Presented) and
                 (LastArchRec.aAmount = CurrentArchRec.aAmount) and
                 (LastArchRec.aType = CurrentArchRec.aType) and
                 (LastArchRec.aReference = CurrentArchRec.aReference) and
                 (LastArchRec.aParticulars = CurrentArchRec.aParticulars) and
                 (LastArchRec.aAnalysis = CurrentArchRec.aAnalysis) and
                 (LastArchRec.aOther_Party = CurrentArchRec.aOther_Party) and
                 (LastArchRec.aStatement_Details = CurrentArchRec.aStatement_Details) and
                 (LastArchRec.aCheque_Number = CurrentArchRec.aCheque_Number) then
                s.AddObject('1', Tx) // is a real duplicate
              else
                s.AddObject('0', Tx); // is a duplicate we want to remove
            finally
              OldFile.Free;
            end;
          end; // if bkfileexists
        except on E : Exception do
          //re raise any exceptions so that we know which file we were working on
          raise EUpgradeAdmin.Create( 'Error upgrading ' + OriginalFilename + ' ' + E.Message + ' ' + E.Classname);
        end;
      end; // if lrn > 0
    end; // for
                                                  
    // now look at every client file to see if a duplicate tx is in it
    for i := AdminSnapshot.fdSystem_Client_File_List.First to AdminSnapshot.fdSystem_Client_File_List.Last do
    begin
      pBar.StepIt;
      cf := AdminSnapshot.fdSystem_Client_File_List.Client_File_At(i);
      sbStatus.SimpleText := 'Looking at file ' + cf.cfFile_Code + '...';
      FirstLogForThisClientFixed := True;
      FirstLogForThisClientManual := True;
      WarnedThisClient := False;
      ManualCheck := False;
      FileWasChanged := False;
      moTemp.Lines.Clear;
      if chkFix.Checked then
      begin
        // backup before editing
        if BKFileExists(DataDir + cf.cfFile_Code + '.ARK') then
          CopyFile(PChar(DataDir + cf.cfFile_Code + '.ARK'), PChar(DataDir + cf.cfFile_Code + '.ARKX'), False);
        CopyFile(PChar(DataDir + cf.cfFile_Code + FileExtn), PChar(DataDir + cf.cfFile_Code + '.ARK'), False);
        Files.OpenAClient(cf.cfFile_Code, aClient, True, False, True, False);
      end
      else
        OpenAClientForRead(cf.cfFile_Code, aClient);
      if Assigned(aClient) then
      begin
        // check every bank account in the client file
        for j := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
        begin
          BA := aClient.clBank_Account_List.Bank_Account_At(j);
          // Can only happen to downloaded accounts
          if BA.baFields.baAccount_Type <> btBank then Continue;
          // check to see if it contains a transaction from the archive that could be duplicated
          for k := 0 to Pred(s.Count) do
          begin
            Tx := TStoredTx(s.Objects[k]);
            if Tx.ACNumber <> BA.baFields.baBank_Account_Number then Continue;
            // check each transactions to find a match
            for m := BA.baTransaction_List.Last downto BA.baTransaction_List.First do
            begin
              tr := BA.baTransaction_List.Transaction_At(m);
              if  (Tx.Date = tr.txDate_Presented) and
                  (Tx.Amount = tr.txAmount) and
                  (Tx.TheType  = tr.txType) and
                  (Tx.Reference = tr.txReference) and
                  (Tx.Particulars = tr.txParticulars) and
                  (Tx.Analysis = tr.txAnalysis) and
                  (Tx.Other_Party = tr.txOther_Party) and
                  (Tx.Statement_Details = tr.txStatement_Details) and
                  (Tx.ChequeNo = tr.txCheque_Number) then
              begin // this 'tr' is the matching one
                // ok found a tx based on the duplicate in the txn file
                // now do we have another one like this next?
                if m > BA.baTransaction_List.First then
                begin
                  trComp := BA.baTransaction_List.Transaction_At(m-1);
                  if  (Tx.Date = trComp.txDate_Presented) and
                      (Tx.Amount = trComp.txAmount) and
                      (Tx.TheType  = trComp.txType) and
                      (Tx.Reference = trComp.txReference) and
                      (Tx.Particulars = trComp.txParticulars) and
                      (Tx.Analysis = trComp.txAnalysis) and
                      (Tx.Other_Party = trComp.txOther_Party) and
                      (Tx.Statement_Details = trComp.txStatement_Details) and
                      (Tx.ChequeNo = trComp.txCheque_Number) then
                  begin
                    FErrors := True;
                    if (cf.cfFile_Status in [fsCheckedOut, fsOffsite, fsOpen]) and (not WarnedThisClient) then
                    begin
                      WarnedThisClient := True; // just print one warning
                      moTemp.Lines.Add('WARNING: Client is ' + fsNames[cf.cfFile_Status]);
                      ManualCheck := True;
                    end
                    else if (not WarnedThisClient) and (bk5files.IndexOf(cf.cfFile_Code) = -1) then
                      bk5files.Add(cf.cfFile_Code); // will need to send to us (if not auto-fixing)
                    moTemp.Lines.Add('');
                    moTemp.Lines.Add('Bank Account: ' + BA.baFields.baBank_Account_Number + ' (' + BA.baFields.baBank_Account_Name + ')');
                    if chkFix.Checked then
                      moTemp.Lines.Add('Duplicate transaction on ' + bkdate2str(tr.txDate_Effective) + ' for amount $' + Money2Str(tr.txAmount) +
                      '  Reference=' + tr.txReference + '  Details=' + tr.txStatement_Details)
                    else
                      moTemp.Lines.Add('To Do: Delete duplicate transaction on ' + bkdate2str(tr.txDate_Effective) + ' for amount $' + Money2Str(tr.txAmount) +
                      '  Reference=' + tr.txReference + '  Details=' + tr.txStatement_Details);
                    if s[k] = '1' then
                       moTemp.Lines.Add('To Do: Please check this client manually - legitimate duplicate found');
                    sba := AdminSnapshot.fdSystem_Bank_Account_List.FindCode(BA.baFields.baBank_Account_Number);
                    if Assigned(sba) and ((sba.sbCurrent_Balance = BA.baFields.baCurrent_Balance) or (BA.baFields.baCurrent_Balance = Unknown)) then
                      moTemp.Lines.Add('Bank Account balance is OK')
                    else if (s[k] = '0') then
                    begin
                      if chkFix.Checked and (s[k] = '0') and (not tr.txLocked) and (tr.txDate_Transferred = 0) then
                      begin
                        moTemp.Lines.Add('Auto Fix: Bank Account balance was automatically adjusted from $' + Money2Str(BA.baFields.baCurrent_Balance) + ' to $' +
                          Money2Str(BA.baFields.baCurrent_Balance - tr.txAmount));
                        BA.baFields.baCurrent_Balance := BA.baFields.baCurrent_Balance - tr.txAmount;
                        FileWasChanged := True;
                      end
                      else
                        moTemp.Lines.Add('To Do: Adjust Bank Account balance from $' + Money2Str(BA.baFields.baCurrent_Balance) + ' to $' +
                          Money2Str(BA.baFields.baCurrent_Balance - tr.txAmount));
                    end;
                    if (s[k] = '0') then
                    begin
                      if tr.txLocked then
                      begin
                        ManualCheck := True;
                        moTemp.Lines.Add('To Do: This transaction is LOCKED. Please check it manually.');
                      end
                      else if tr.txDate_Transferred <> 0 then
                      begin
                        ManualCheck := True;
                        moTemp.Lines.Add('To Do: This transaction is TRANSFERRED. Please check it manually.');
                      end
                      else if chkFix.Checked then
                      begin
                        moTemp.Lines.Add('Auto Fix: This transaction was automatically deleted');
                        FileWasChanged := True;                        
                        BA.baTransaction_List.DelFreeItem( tr );
                      end;
                    end;
                    if ManualCheck then
                    begin
                      if FirstLogForThisClientManual then
                      begin
                        moManual.Lines.Add('');
                        moManual.Lines.Add('');
                        moManual.Lines.Add('Client ' + cf.cfFile_Code);
                        moManual.Lines.Add('===============');
                        FirstLogForThisClientManual := False;
                      end;
                      moManual.Lines.Text := moManual.Lines.Text + moTemp.Lines.Text
                    end
                    else
                    begin
                      if FirstLogForThisClientFixed then
                      begin
                        moFixed.Lines.Add('');
                        moFixed.Lines.Add('');
                        moFixed.Lines.Add('Client ' + cf.cfFile_Code);
                        moFixed.Lines.Add('===============');
                        FirstLogForThisClientFixed := False;
                      end;
                      moFixed.Lines.Text := moFixed.Lines.Text + moTemp.Lines.Text;
                    end;
                    moTemp.Lines.Clear;
                    Break;
                  end;
                end;
                // no duplicate found, further check for UPC:
                // if its a cheque AND a matched UPC with the dup details exists then we can delete the entry
                if tr.txCheque_Number <> 0 then
                begin
                  // now search for a matched UPC in the trans list
                  for p := BA.baTransaction_List.Last downto BA.baTransaction_List.First do
                  begin
                    trUPC := BA.baTransaction_List.Transaction_At(p);
                    if (trUPC.txSequence_No = tr.txSequence_No) then Continue; // its our 'tr'!
                    if (trUPC.txCheque_Number = tr.txCheque_Number) and
                       (trUPC.txDate_Presented = tr.txDate_Presented) and
                       (trUPC.txAmount = tr.txAmount) and
                       (trUPC.txOriginal_Reference = tr.txReference) and
                       (trUPC.txOriginal_Type = tr.txType) then
                    begin // this is the matched UPC - can delete the other trans ('tr')
                      FErrors := True;
                      if (cf.cfFile_Status in [fsCheckedOut, fsOffsite, fsOpen]) and (not WarnedThisClient) then
                      begin
                        WarnedThisClient := True; // just print one warning
                        moTemp.Lines.Add('WARNING: Client is ' + fsNames[cf.cfFile_Status]);
                        ManualCheck := True;
                      end
                      else if (not WarnedThisClient) and (bk5files.IndexOf(cf.cfFile_Code) = -1) then
                        bk5files.Add(cf.cfFile_Code); // will need to send to us (if not auto-fixing)
                      moTemp.Lines.Add('');
                      moTemp.Lines.Add('Bank Account: ' + BA.baFields.baBank_Account_Number + ' (' + BA.baFields.baBank_Account_Name + ')');
                      if chkFix.Checked then
                        moTemp.Lines.Add('Duplicate transaction on ' + bkdate2str(tr.txDate_Effective) + ' for amount $' + Money2Str(tr.txAmount) +
                        '  Reference=' + tr.txReference + '  Details=' + tr.txStatement_Details)
                      else
                        moTemp.Lines.Add('To Do: Delete duplicate transaction on ' + bkdate2str(tr.txDate_Effective) + ' for amount $' + Money2Str(tr.txAmount) +
                        '  Reference=' + tr.txReference + '  Details=' + tr.txStatement_Details);
                      if s[k] = '1' then
                        moTemp.Lines.Add('To Do: Please check this client manually - legitimate duplicate found');
                      sba := AdminSnapshot.fdSystem_Bank_Account_List.FindCode(BA.baFields.baBank_Account_Number);
                      if Assigned(sba) and ((sba.sbCurrent_Balance = BA.baFields.baCurrent_Balance) or (BA.baFields.baCurrent_Balance = Unknown)) then
                        moTemp.Lines.Add('Bank Account balance is OK')
                      else if (s[k] = '0') then
                      begin
                        if chkFix.Checked and (s[k] = '0') and (not tr.txLocked) and (tr.txDate_Transferred = 0) then
                        begin
                          moTemp.Lines.Add('Auto Fix: Bank Account balance was automatically adjusted from $' + Money2Str(BA.baFields.baCurrent_Balance) + ' to $' +
                            Money2Str(BA.baFields.baCurrent_Balance - tr.txAmount));
                          BA.baFields.baCurrent_Balance := BA.baFields.baCurrent_Balance - tr.txAmount;
                          FileWasChanged := True;                          
                        end
                        else
                          moTemp.Lines.Add('To Do: Adjust Bank Account balance from $' + Money2Str(BA.baFields.baCurrent_Balance) + ' to $' +
                            Money2Str(BA.baFields.baCurrent_Balance - tr.txAmount));
                      end;
                      if (s[k] = '0') then
                      begin
                        if tr.txLocked then
                        begin
                          ManualCheck := True;
                          moTemp.Lines.Add('To Do: This transaction is LOCKED. Please check it manually.');
                        end
                        else if tr.txDate_Transferred <> 0 then
                        begin
                          ManualCheck := True;
                          moTemp.Lines.Add('To Do: This transaction is TRANSFERRED. Please check it manually.');
                        end
                        else if chkFix.Checked then
                        begin
                          moTemp.Lines.Add('Auto Fix: This transaction was automatically deleted');
                          BA.baTransaction_List.DelFreeItem( tr );
                          FileWasChanged := True;                          
                        end;
                      end;
                      if ManualCheck then
                      begin
                        if FirstLogForThisClientManual then
                        begin
                          moManual.Lines.Add('');
                          moManual.Lines.Add('');
                          moManual.Lines.Add('Client ' + cf.cfFile_Code);
                          moManual.Lines.Add('===============');
                          FirstLogForThisClientManual := False;
                        end;
                        moManual.Lines.Text := moManual.Lines.Text + moTemp.Lines.Text
                      end
                      else
                      begin
                        if FirstLogForThisClientFixed then
                        begin
                          moFixed.Lines.Add('');
                          moFixed.Lines.Add('');
                          moFixed.Lines.Add('Client ' + cf.cfFile_Code);
                          moFixed.Lines.Add('===============');
                          FirstLogForThisClientFixed := False;
                        end;
                        moFixed.Lines.Text := moFixed.Lines.Text + moTemp.Lines.Text;
                      end;
                      moTemp.Lines.Clear;
                      Break;
                    end;
                  end;
                end;
                Break; // finished with this transaction
              end; // if <found matching transaction>
            end; // for every transaction in bank account
          end; // for every transaction in archive that could be duplicated
        end; // for every bank account in client file
        if chkFix.Checked then
        begin
          if FileWasChanged then
            aClient.Save;
          Files.CloseAClient(aClient);
        end;
        FreeAndNil(aClient);
      end
      else
      begin
        moManual.Lines.Add('');
        moManual.Lines.Add('');
        moManual.Lines.Add('Client ' + cf.cfFile_Code);
        moManual.Lines.Add('===============');
        if (cf.cfFile_Status in [fsCheckedOut, fsOffsite, fsOpen]) then
          moManual.Lines.Add('WARNING: Client is ' + fsNames[cf.cfFile_Status] + ' - please check this file manually.')
        else
          moManual.Lines.Add('WARNING: Client could not be opened - please check this file manually.');
      end;
      if not FileWasChanged then
        DeleteFile(DataDir + cf.cfFile_Code + '.ARK');
    end; // for i

    moResults.Lines.Add('');
    moResults.Lines.Add('');

    // save fixes
    BackupObj := TBkBackup.Create;
    try
      ArcFilename := DataDir + 'bkarchive' + StDateToDateString( 'ddmmyy', StDate.CurrentDate, false) + '.txt';
      ArcFilename := Backup.ZipFilenameToUse( ArcFilename);
    finally
      BackupObj.Free;
    end;
    if moManual.Lines.Text <> '' then
    begin
      moManual.Lines.Add('');
      moManual.Lines.Add('');
      moManual.Lines.Insert(0, '----------------------------------------------------------------------------');
      moManual.Lines.Insert(0, 'To Do: Please manually check the following files');
      moResults.Lines.Text := moResults.Lines.Text + moManual.Lines.Text;
    end;
    if moFixed.Lines.Text <> '' then
    begin
      moFixed.Lines.Add('');
      moFixed.Lines.Add('');
      moFixed.Lines.Insert(0, '------------------------------------------------------------');
      moFixed.Lines.Insert(0, 'Auto Fix: The following files were fixed');
      moResults.Lines.Text := moResults.Lines.Text + moFixed.Lines.Text;
    end;


    if chkFix.Checked then
    begin
      if (not FErrors) and (moManual.Lines.Text = '') then
      begin
        ShowMessage('No duplicates were found');
        moResults.Lines.Add('No duplicates were found');
      end
      else if FErrors and (moManual.Lines.Text = '') then
      begin
        ShowMessage('All duplicates were removed - see ' + ArcFilename + ' for details');
        moResults.Lines.Add('All duplicates were removed - see ' + ArcFilename + ' for details');
      end
      else if moManual.Lines.Text <> '' then
      begin
        ShowMessage('Some files must be checked manually - see ' + ArcFilename + ' for details');
        moResults.Lines.Add('Some files must be checked manually - see ' + ArcFilename + ' for details');
      end;
    end
    else
    begin
      if (not FErrors) and (moManual.Lines.Text = '') then
        moResults.Lines.Add('No duplicates were found')
      else if FErrors and (moManual.Lines.Text = '') then
        moResults.Lines.Add('Duplicates were found - see ' + ArcFilename + ' for details')
      else if moManual.Lines.Text <> '' then
        moResults.Lines.Add('Some files must be checked manually - see ' + ArcFilename + ' for details');
    end;

    moResults.Lines.SaveToFile(ArcFilename);

    otherfiles.Add(ArcFilename);                  
    // read email settings
    BK5ReadINI; // get email settings
    if chkFix.Checked then
      bk5files.Clear; // fixed it - still want the log
    SendClientAndOtherFilesTo('E-Mail Results to BankLink', 'support@banklink.co.nz', 'BankLink Archive Verification',
      'Here are the results from ' + AdminSnapshot.fdFields.fdBankLink_Code, otherfiles, bk5files, True);
  finally
    INIFile.Add(Edit1.Text);
    INIFile.SaveToFile(DataDir + 'bkarchive.ini');
    LogOutUser;
    btnCheck.Enabled := True;
    sbStatus.SimpleText := '';            
    for i := 0 to Pred(s.Count) do
      TStoredTx(s.Objects[i]).Free;
    s.Free;
    otherfiles.Free;
    bk5files.Free;
    btnPrint.Enabled := True;
    if BKFileExists(DataDir + 'ArchiveCheck') then
      DeleteFilesInDir(DataDir + 'ArchiveCheck');
    Adminsnapshot.Free;
    AdminSystem.Free;
  end;
end;

procedure TMainForm.btnPrintClick(Sender: TObject);
var
  r : TRect;
  newheight:integer;
  lastchar:integer;
  rlist:TStringlist;
begin
  rlist:=TStringlist.create;
  rlist.text:=moResults.text;
  try
    with PrintPreview, r do
    begin
      NewJob;
      Top := YInch(1);
      Bottom:=YInch(10);
      left:=xinch(1);
      right:=XInch(8);                

      newheight:=memoOut(r,rlist,moResults.font, lastchar, true);

      while rlist.count>0 do
      begin
        newpage;
        r.top:=yinch(1);
        r.bottom:=yinch(10);
        newheight:=memoOut(r,rlist, moResults.font, lastchar, true);
      end;

      top:=top+newheight + yinch(0.5);

    end;
    finally
      rlist.free;
  end;
    PrintPreview.PageWidthBtnClick(Self);
    PrintPreview.Preview;
    PrintPreview.showmodal;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  s: TStringList;
  zipfilename: string;
  i, j, x: Integer;
begin
  // get zip from log
  if ParamStr(1) = '/check' then
    chkFix.Checked := False;
  HasRun := False;
  zipfilename := '';
  s := TStringList.Create;
  try
    if BKFileExists(DataDir + 'bk5win.log') then
    begin
      s.LoadFromFile(DataDir + 'bk5win.log');
      for i := 0 to Pred(s.count) do
      begin
        if Pos('Upgrading to Version 87', s[i]) > 0 then
        begin
          for j := i downto 0 do // work back from here
          begin
            x := Pos('UPGRADE,"Backup.Creating Backup ', s[j]);
            if x > 0 then
            begin
              zipfilename := Trim(Copy(s[j], x+32, Length(s[j])));
              zipfilename := Copy(zipfilename, 1, Length(zipfilename)-1); //cut the "
              zipfilename := Extractfilename(zipfilename);
              break;
            end;
          end;
          if zipfilename <> '' then Break;
        end;
      end;
    end;
  finally
    s.Free;
  end;
  if (zipfilename = '' ) or (not BKFileExists(DataDir + zipfilename)) then
  begin
    // try to get it from ini
    if BKFileExists(DataDir + 'bkarchive.ini') then
    begin
      s := TStringList.Create;
      s.LoadFromFile(DataDir + 'bkarchive.ini');
      if s.Count > 0 then
        zipfilename := s[0];
    end;
    if zipfilename = '' then
      ShowMessage('Could not find the Zip file. Please enter the filename manually.');
  end;
  Edit1.Text := zipfilename;
end;

end.
