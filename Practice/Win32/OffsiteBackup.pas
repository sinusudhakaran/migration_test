unit OffsiteBackup;
//------------------------------------------------------------------------------
{
   Title:       Offsite Backup

   Description: Offsite Backup and Restore routines

   Author:      Matthew Hopkins Jan 2004

   Remarks:     Feb 2004.  After some discussion we decided to throw away the
                disk spanning functionality and state that offsite backups
                do not support multi disk backups.  Decision made of the basis
                of the availability of USB key devices, the fact that we don't
                support check outs over 1 disk, and normally small size of
                bk5 files.

                Jan 2004 Uses VCL zip, default dir = a:\

   Revisions:

}
//------------------------------------------------------------------------------

interface

const
  osbNever    = 0;
  osbPrompt   = 1;
  osbAuto     = 2;

procedure DoOffsiteBackup( aClientCode : string; ForcePrompt : boolean = false);
procedure DoOffsiteRestore;

//******************************************************************************
implementation
uses

  logUtil,
  Classes,
  crcFileUtils,
  bkDateUtils,
  bk5except,
  ClientWrapper,
  Backup,
  FCopy,
  BackupRestoreDlg,
  ErrorMoreFrm,
  InfoMoreFrm,
  WarningMoreFrm,
  YesNoDlg,
  Dialogs,
  Globals,
  Progress,
  WinUtils,
  SysUtils, Windows,
  VCLUnZip, kpZipObj;

const
  Unitname = 'offsitebackup';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowBackupProgress( s : string; p : double);
begin
  UpdateAppStatus( 'Backing Up Files', s, p);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogBackupMessage( s : string);
begin
  LogMsg( lmInfo, Unitname, 'Backup.' + s);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowRestoreProgress( s : string; p : double);
begin
  UpdateAppStatus( 'Restoring Files', s, p);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogRestoreMessage( s : string);
begin
  LogMsg( lmInfo, Unitname, 'Restore.' + s);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateCopyProgress( BytesCopied : Int64; TotalBytes : int64);
var
  Perc : double;
begin
  if TotalBytes <> 0 then
    Perc := BytesCopied / TotalBytes * 100
  else
    Exit;

  UpdateAppStatusPerc_NR( Perc);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoOffsiteBackup( aClientCode : string; ForcePrompt : boolean = false);
//- - - - - - - - - - - - - - - - - - - -
// Purpose:     Calls the offsite backup routine
//              Assumes that
//
// Parameters:  None, uses bk5win.ini settings
//
// Result:      none
//- - - - - - - - - - - - - - - - - - - -
var
  DirName : string;
  BackupFilename : string;
  ClientFilename : string;
  aMSg : string;
  ErrorType : byte;
  Overwrite : boolean;
  InvalidPath : boolean;
  EstimatedSize : int64;
  ConfirmationMessageNeeded : boolean;
  S : string;
begin
  if ( INI_BackupLevel = osbNever) and ( not ForcePrompt) then
    Exit;

  DirName := Globals.INI_BackupDir;
  Overwrite := Globals.INI_BackupOverwrite;

  ConfirmationMessageNeeded := false;

  //see if we can do a automatic backup
  //if not tell the user why and bring up the prompt
  InvalidPath := false;
  if (not ForcePrompt) and (INI_BackupLevel = osbAuto) then
  begin
    BackupFilename := aClientCode + Globals.OffsiteBackupExtn;
    SetCurrentDir( Globals.DataDir);
    EstimatedSize := WinUtils.GetFileSize( aClientCode + Globals.FILEEXTN) + 128;

    InvalidPath := not VerifyDirectory( DirName,
                                        Overwrite,
                                        False,  //disk spanning
                                        aMsg,
                                        ErrorType,
                                        aClientCode + Globals.OffsiteBackupExtn,
                                        EstimatedSize);

    if InvalidPath then
      LogMsg( lmInfo, Unitname, 'AutoBackup - ' + aMsg);
  end;

  //get dir to use from user
  if ( ForcePrompt) or ( INI_BackupLevel = osbPrompt) or ( InvalidPath) then
  begin
    if not GetBackupOptions( DirName, Overwrite, aClientCode) then
      exit;

    INI_BackupDir := DirName;
    INI_BackupOverwrite := Overwrite;

    ConfirmationMessageNeeded := true;
  end;

  //dir is valid and media can take the file
  ClientFilename := DataDir + aClientCode + Globals.FILEEXTN;
  Globals.mfModalCommandResult := 0;

  ShowBackupProgress( '', 0.0);
  LogBackupMessage( 'Backing up ' + aClientCode);

  try
    try
      BackupFilename := INI_BackupDir + aClientCode + Globals.OffsiteBackupExtn;
      if not INI_BackupOverwrite then
        BackupFilename := Backup.ZipFilenameToUse( BackupFilename);

      if BKFileExists( BackupFilename) then
      begin
        ShowBackupProgress( 'Removing existing backup', 0.0);
        WinUtils.RemoveFile( BackupFilename);
      end;

      //copy file
      S := ExtractFileName( BackupFilename);
      ShowBackupProgress( 'Copying file ' + S, 0);
      FCopy.CopyFile( ClientFilename, BackupFilename, UpdateCopyProgress );
    except
      on E : Exception do
      begin
         HelpfulErrorMsg( 'Backup of ' + aClientCode + ' failed. ' + E.Message, 0, false);
         aMsg := Format( 'Backup of %s to %s failed - %s.', [ ClientFilename, BackupFilename, E.Message ] );
         LogUtil.LogMsg(lmError,UnitName, aMsg);
         Exit;
      end;
    end;
    //backup succeeded
    Globals.mfModalCommandResult := 1;
  finally
    ClearStatus;
  end;

  LogBackupMessage('Backup Completed');

  if ConfirmationMessageNeeded then
    HelpfulInfoMsg( 'Backup completed.', 0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoOffsiteRestore;
var
  BackupFilename : string;
  ClientFilename : string;
  ClientCode : string;
  BakFilename : string;
  TempFilename : string;
  OD : TOpenDialog;
  BackupDateTime : Integer;
  VarDateTime    : TDateTime;
  S : string;
  aMsg : string;
  Wrapper: TClientWrapper;
begin
   //select a file to restore, unzip the file into bk5 dir after user confirms this
   OD := TOpenDialog.Create( NIL );
   Try
      OD.InitialDir := INI_BackupDir;
      OD.Filter     := BKBOOKSNAME + ' Backup (*' + Globals.OFFSITEBACKUPEXTN + ')|*' + Globals.OFFSITEBACKUPEXTN;
      OD.Filename   := '';
      OD.Options    := [ ofHideReadOnly, ofFileMustExist, ofPathMustExist, ofDontAddToRecent, ofEnableSizing, ofNoChangeDir];
      If OD.Execute then
        BackupFilename := OD.FileName;
   Finally
      OD.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( Globals.DataDir);
   end;

   if BackupFilename = '' then
     exit;

   LogRestoreMessage('Read Backup File Wrapper ' + backupFilename);

   //check crc and read wrapper so that we can get the real file code
   try
     GetClientWrapper( BackupFilename, Wrapper, true);  //to check password
     if ( Wrapper.wSignature <> BankLink_Signature) then
       raise EFileWrapper.Create( 'Invalid File Signature');

     ClientCode := Wrapper.wCode;
   except
     on e : Exception do
     begin
       aMsg := 'Cannot open backup file ' + BackupFilename + '  Error: ' + E.Message + ' (' + E.ClassName + ')';
       HelpfulErrorMsg( aMsg, 0);
       exit;
     end;
   end;

   ClientFilename := DataDir + ClientCode + Globals.FILEEXTN;
   TempFilename := DataDir + ClientCode + Globals.OFFSITERESTOREEXTN;
   BakFilename := DataDir + ClientCode + Globals.BACKUPEXTN;

   //confirm restore
   BackupDateTime := FileAge( BackupFilename);
   VarDateTime := FileDateToDateTime( BackupDateTime);
   if (Trunc(VarDateTime) = Date) then
     S := S + 'Today'
   else
     S := S + ' on ' + DateToStr(VarDateTime);
   S := S + ' at ' + TimeToStr(VarDateTime);


   aMsg := 'Do you want to restore client ' + ClientCode + #13' from a backup created '#13#13 + S + '?';
   if BKFileExists( ClientFilename) then
     aMsg := aMsg + #13#13 + 'Note: This will overwrite your existing client file.';

   if AskYesNo( 'Restore Client File',
                     aMsg,
                     dlg_yes, 0) <> dlg_yes then
     Exit;

   S := ExtractFileName( BackupFilename);
   ShowRestoreProgress( 'Restoring file ' + S, 0);
   try //finally
     try //except
       LogRestoreMessage( 'Restore Started');

       //copy to local dir
       SysUtils.DeleteFile( TempFilename);
       LogRestoreMessage('Copying Backup File ' + backupFilename);
       FCopy.CopyFile( BackupFilename, TempFilename, UpdateCopyProgress);

       //check crc
       ShowRestoreProgress( 'Verifying', 95);
       LogRestoreMessage('Verifying ' + TempFilename);
       CrcFileUtils.CheckEmbeddedCRC( TempFilename);

       //rename existing bk5 to bak
       SysUtils.DeleteFile(BakFilename);
       if BKFileExists( ClientFilename) then
         RenameFileEx(ClientFilename,BakFilename);

       //rename osr to bk5
       RenameFileEx(TempFilename, ClientFilename);

       LogRestoreMessage( 'Restore Completed');
       ShowRestoreProgress( 'Restore Complete', 100.0);
     except
       on E : Exception do
       begin
         S := E.Message;

         if E.ClassType = ECRCCheckFailed then
           S := 'File is corrupt';

         HelpfulErrorMsg( 'Restore of ' + ClientCode + ' failed (' + S + ').', 0, false);

         aMsg := Format( 'Restore of %s to %s failed - %s.', [ BackupFilename, ClientFilename, E.Message + ' ' + E.ClassName ] );
         LogUtil.LogMsg(lmError,UnitName, aMsg);
         Exit;
       end;
     end;
   finally
     ClearStatus;
     SysUtils.DeleteFile( TempFilename);  //clean up
   end;

   HelpfulInfoMsg( 'Restore completed.', 0);

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// VCL Backup

  (*
    This code has been kept in case we need to add support for multi disk
    backups.  If this is required then changes will need to be made to
    zip code to improve prompting/checking when doing disk spanning

  //zip the file, span disks if necessary
  try
    BackupObj := TBkBackup.Create;
    try
      BackupObj.ZipFilename := BackupFilename;
      BackupObj.FilesTypesToInclude := [ biSpecifiedFile ];
      BackupObj.FileToAdd := ClientFilename;
      BackupObj.RootDir     := DataDir;
      BackupObj.OnProgressEvent := ShowBackupProgress;
      BackupObj.OnLogEvent      := LogBackupMessage;
      BackupObj.CheckFilesizeBeforeZip := false;  //already done
      BackupObj.ReplaceExistingBackup := true;
      BackupObj.CompressionLevel := 0; //no compression
      BackupObj.DiskSpanning := true;

      BackupObj.ZipFiles;
    finally
      BackupObj.Free;
      ClearStatus;
    end;
  except
    On E : Exception do
    begin
      aMsg := 'Backup Failed. ' + E.Message + ' [' + E.Classname + ']';
      HelpfulErrorMsg( aMsg, 0);
    end;
  end;
*)

//  VCL Restore


  (*
    This code has been kept in case we need to add support for multi disk
    backups.  If this is required then changes will need to be made to
    zip code to improve prompting/checking when doing disk spanning

  try
    RestoreObj := TBkRestore.Create;
    try
      RestoreObj.ZipFilename := BackupFilename;
      RestoreObj.FileTypesToExtract := [ biAllClientFiles ];
      RestoreObj.OnProgressEvent := ShowRestoreProgress;
      RestoreObj.OnLogEvent      := LogRestoreMessage;
      RestoreObj.ExtractToDir := Globals.DataDir;

      FileList := TStringList.Create;
      try
        //will return a list of client files in the backup
        RestoreObj.GetFileList( FileList);
        if FileList.Count = 0 then
        begin
          raise Exception.Create( 'No client files found in backup');
        end
        else
        begin
          //get name of first client file
          ClientFilename := Copy( FileList[0], 1, Pos( #9, FileList[0]) - 1);
          FileDateTime := Copy( FileList[0], Pos( #9, FileList[0]) + 1, length( FileList[0]));
          aMsg := 'Do you want to restore the file ' + ClientFilename + ' saved on ' + FileDateTime + '?';
          if BKFileExists( Globals.DataDir + ClientFilename) then
            aMsg := aMsg + #13#13 + 'Note: This will overwrite your existing client file.';
        end;

        if AskYesNo( 'Restore Client File',
                     aMsg,
                     dlg_yes, 0) <> dlg_yes then
          Exit;

        //restore the file
        RestoreObj.FileToExtract := ClientFilename;
        RestoreObj.FileTypesToExtract := [ biSpecifiedFile];
        RestoreObj.OverwriteFileIfExists := true;
        RestoreObj.UnZipFiles;

      finally
        FileList.Free;
      end;

    finally
      RestoreObj.Free;
      ClearStatus;
    end;

  except
    On E : Exception do
    begin
      aMsg := 'Restore Failed. ' + E.Message + ' [' + E.Classname + ']';
      HelpfulErrorMsg( aMsg, 0);
    end;
  end;
  *)


end.
