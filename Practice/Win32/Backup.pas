unit Backup;
//------------------------------------------------------------------------------
{
   Title:       Backup/Restore Routines

   Description: Provide a set of backup routines to backup all or selected
                files that form part of the banklink installation

   Author:      Matthew Hopkins Oct 2002

   Remarks:     ** Feb 2004: Further work required to improve disk spanning,
                currently using default VCL code to handle multi disk prompt.
                Need to write our own routines to make this more robust.

   Revisions:   Jan 2004, extended backup to show total percent progress and
                ability to add a single file to a backup

                Restore object added, only works for single files at this stage

                Verify directory also added so can check a backup dir
}
//------------------------------------------------------------------------------

interface
uses
  SysUtils, VCLZip, VCLUnZip, kpZipObj, StDate, WinUtils, Classes;

type
  TSetOfByte = set of byte;

type
  EBkBackupError = class( Exception);

  EBkBNotEnoughSpace = class( EBkBackupError);

const
  biSystemDb       = 1;
  biArchive        = 2;
  biMasterMemFiles = 3;
  biINIFiles       = 4;
  biLogFile        = 5;
  biAllClientFiles  = 6;
  biSpecifiedFile   = 7;

  biSetOfAllFiles = [ biSystemDb,
                      biArchive,
                      biMasterMemFiles,
                      biINIFiles,
                      biLogFile,
                      biAllClientFiles ];

  biSetOfAdminFiles = [ biSystemDb,
                      biArchive,
                      biMasterMemFiles ];

  bkErrorGeneral = 0;
  bkErrorMedia = 1;

type
  TProgressCallbackProc = procedure( S: string; PercentComplete : double);
  TLogMessageEvent      = procedure( S: string);

type
  TBkBackup = class
    constructor Create; reintroduce;
  private
    Zipper            : TVCLZip;
    FFileTypesToInclude: TSetOfByte;
    FZipFilename      : string;
    FRootDir          : string;
    FOnProgressEvent  : TProgressCallbackProc;
    FOnLogEvent       : TLogMessageEvent;
    CurrentFile       : string;
    FileBeingZipped   : string;

    NumFilesToZip     : integer;
    NumFilesZipped    : integer;
    FCheckFilesizeBeforeZip: boolean;
    FDiskSpanning: boolean;
    FFileToAdd: string;
    FReplaceExistingBackup: boolean;
    FCompressionLevel: integer;

    procedure SetFilesTypesToInclude(const Value: TSetOfByte);
    procedure SetRootDir(const Value: string);
    procedure SetZipFilename(const Value: string);
    procedure SetOnProgressEvent(const Value: TProgressCallbackProc);
    procedure SetOnLogEvent(const Value : TLogMessageEvent);

    procedure UpdateProgress( aMsg : string; aPercentComplete : double);
    procedure LogMessage( aMsg : string);

    procedure BkBackupOnStartZip( Sender: TObject; FName: String; var ZipHeader: TZipHeaderInfo; var Skip: Boolean );
    procedure BkBackupOnEndZip( Sender: TObject; FName: String; UncompressedSize, CompressedSize, CurrentZipSize: LongInt );
    procedure BkBackupOnStartZipInfo( Sender: TObject; NumFiles: Integer; TotalBytes: Comp; var EndCentralRecord: TEndCentral; var StopNow: Boolean );
    procedure BkBackupOnTotalPercent( Sender: TObject; Percent: LongInt );

    procedure SetCheckFilesizeBeforeZip(const Value: boolean);
    procedure SetDiskSpanning(const Value: boolean);
    procedure SetFileToAdd(const Value: string);
    procedure SetReplaceExistingBackup(const Value: boolean);
    procedure SetCompressionLevel(const Value: integer);
  public
    property FilesTypesToInclude : TSetOfByte read FFileTypesToInclude write SetFilesTypesToInclude;
    property RootDir : string read FRootDir write SetRootDir;
    property ZipFilename : string read FZipFilename write SetZipFilename;
    property CheckFilesizeBeforeZip : boolean read FCheckFilesizeBeforeZip write SetCheckFilesizeBeforeZip;
    property DiskSpanning : boolean read FDiskSpanning write SetDiskSpanning;
    property FileToAdd : string read FFileToAdd write SetFileToAdd;
    property ReplaceExistingBackup : boolean read FReplaceExistingBackup write SetReplaceExistingBackup;
    property CompressionLevel : integer read FCompressionLevel write SetCompressionLevel;

    property OnProgressEvent : TProgressCallbackProc write SetOnProgressEvent;
    property OnLogEvent      : TLogMessageEvent write SetOnLogEvent;

    procedure ZipFiles;
  end;

  TBkRestore = class
    constructor Create; reintroduce;
  private
    Unzipper : TVCLUnzip;

    FZipFilename: string;
    FOnProgressEvent  : TProgressCallbackProc;
    FOnLogEvent       : TLogMessageEvent;
    FRootDir: string;

    CurrentFile       : string;
    FileBeingUnzipped : string;
    NumFilesToUnzip : integer;
    NumFilesUnzipped : integer;

    FFileTypesToExtract: TSetOfByte;
    FExtractTo: string;

    FFileToExtract: string;
    FOverwriteFileIfExists: boolean;
    FCheckFileSizeBeforeUnzip: boolean;

    FDoAll, FRecreateDirs: Boolean;

    procedure SetOnLogEvent(const Value: TLogMessageEvent);
    procedure SetOnProgressEvent(const Value: TProgressCallbackProc);
    procedure SetRootDir(const Value: string);
    procedure SetZipFilename(const Value: string);
    procedure SetFileTypesToExtract(const Value: TSetOfByte);
    procedure SetExtractTo(const Value: string);

    procedure UpdateProgress( aMsg : string; aPercentComplete : double);
    procedure LogMessage( aMsg : string);
    procedure SetFileToExtract(const Value: string);
    procedure SetOverwriteFileIfExists(const Value: boolean);

    procedure bkRestoreOnStartUnzip( Sender: TObject; FileIndex: Integer; var FName: String; var Skip: Boolean );
    procedure bkRestoreOnEndUnzip( Sender: TObject; FileIndex: Integer; FName: String );
    procedure bkRestoreOnStartUnzipInfo( Sender: TObject; NumFiles: Integer; TotalBytes: Comp; var StopNow: Boolean );
    procedure bkRestoreOnTotalPercent( Sender: TObject; Percent: LongInt );

    procedure SetCheckFileSizeBeforeUnzip(const Value: boolean);

  public
    property RootDir : string read FRootDir write SetRootDir;
    property ZipFilename : string read FZipFilename write SetZipFilename;

    property OnProgressEvent : TProgressCallbackProc write SetOnProgressEvent;
    property OnLogEvent      : TLogMessageEvent write SetOnLogEvent;

    property FileTypesToExtract : TSetOfByte read FFileTypesToExtract write SetFileTypesToExtract;
    property ExtractToDir : string read FExtractTo write SetExtractTo;
    property FileToExtract : string read FFileToExtract write SetFileToExtract;
    property OverwriteFileIfExists : boolean read FOverwriteFileIfExists write SetOverwriteFileIfExists;
    property CheckFileSizeBeforeUnzip : boolean read FCheckFileSizeBeforeUnzip write SetCheckFileSizeBeforeUnzip;
    property DoAll: Boolean read FDoAll write FDoAll;
    property RecreateDirs: Boolean read FRecreateDirs write FRecreateDirs;    

    procedure UnZipFiles;
    procedure GetFileList( aListofFiles : TStringList);
  end;

  function ZipFilenameToUse( const DefaultName : string) : string;

  function VerifyDirectory( const Path : string;
                            const Overwrite : boolean;
                            const DiskSpanningSupported : boolean;
                            var ErrorMsg : string;
                            var ErrorType : byte;
                            BackupFilename : string = '';
                            EstimatedFileSize : int64 = 0) : boolean;

//******************************************************************************
implementation
uses
  Forms, Windows, dialogs;

function ZipFilenameToUse( const DefaultName : string) : string;
//takes the default file name and add to num to it until file with that name
//is not found
var
  i  : integer;
  NewName : string;

  Path     : string;
  Filename : string;
  Extn     : string;
begin
  result := '';
  i := 0;
  NewName := DefaultName;

  while (BKFileExists( NewName)) do
  begin
    Inc( i);

    Filename := ExtractFilename( DefaultName);
    Path     := ExtractFilePath( DefaultName);
    Extn     := ExtractFileExt( Filename);

    if Extn <> '' then
      Filename := Copy( Filename, 1, Pos( Extn, Filename) -1);

    NewName := Path + Filename + inttostr( i) + Extn;
  end;

  result := NewName;
end;

{ TBkBackup }

procedure TBkBackup.BkBackupOnEndZip(Sender: TObject; FName: String;
  UncompressedSize, CompressedSize, CurrentZipSize: Integer);
var
  p : double;
  s : string;
begin
  Inc( NumFilesZipped);
  S := ExtractFilename( FName);

  if NumFilesToZip > 0 then
    p := (NumFilesZipped / NumFilesToZip) * 100
  else
    p := 0.0;

  UpdateProgress( S + ' added', p);
  FileBeingZipped := '';
end;

procedure TBkBackup.BkBackupOnStartZip(Sender: TObject; FName: String;
  var ZipHeader: TZipHeaderInfo; var Skip: Boolean);
var
  S : string;
  p : double;
begin
  S := ExtractFilename( FName);
  FileBeingZipped := S;

  if NumFilesToZip > 0 then
    p := (NumFilesZipped / NumFilesToZip) * 100
  else
    p := 0.0;

  UpdateProgress( 'Adding ' + S, p);
end;

procedure TBkBackup.BkBackupOnStartZipInfo(Sender: TObject;
  NumFiles: Integer; TotalBytes: Comp; var EndCentralRecord: TEndCentral;
  var StopNow: Boolean);
var
  Path        : string;
  DiskSizeOK  : boolean;
  FreeSpace   : Int64;
  TotalSpace  : Int64;
  SpaceNeeded : Int64;
begin
  //provides estimated info before the zipping starts
  NumFilesToZip := NumFiles;
  FileBeingZipped := '';

  //make sure there is enough disk space
  if FCheckFilesizeBeforeZip then
  begin
    Path       := ExtractFileDrive( Self.ZipFilename);
    DiskSizeOK := SysUtils.GetDiskFreeSpaceEx( PChar(Path), FreeSpace, TotalSpace, nil);
    if DiskSizeOK then
    begin
      //managed to get the disk space free, if can't get it then dont do test
      SpaceNeeded := Round( TotalBytes);
      if ( FreeSpace < SpaceNeeded) then
        raise EBkBNotEnoughSpace.Create( 'Not enough space to do backup ' +
                                         inttostr( SpaceNeeded div 1024) + ' Kb required');
    end;
  end;
end;

procedure TBkBackup.BkBackupOnTotalPercent(Sender: TObject;
  Percent: Integer);
begin
  if FileBeingZipped <> '' then
    UpdateProgress( 'Adding ' + FileBeingZipped, Percent);
end;

constructor TBkBackup.Create;
begin
  FOnProgressEvent     := nil;
  FOnLogEvent          := nil;
  FFileTypesToInclude := [];
  FRootDir             := '';
  FZipFilename         := '';
  FDiskSpanning        := false;
  FReplaceExistingBackup := false;
  FCheckFilesizeBeforeZip := true;
  FCompressionLevel    := -1;  //only set if <> -1
end;

procedure TBkBackup.LogMessage(aMsg: string);
begin
  if Assigned( FOnLogEvent) then
  begin
    FOnLogEvent( aMsg);
  end
end;

procedure TBkBackup.SetCheckFilesizeBeforeZip(const Value: boolean);
begin
  FCheckFilesizeBeforeZip := Value;
end;

procedure TBkBackup.SetCompressionLevel(const Value: integer);
begin
  FCompressionLevel := Value;
end;

procedure TBkBackup.SetDiskSpanning(const Value: boolean);
begin
  FDiskSpanning := Value;
end;

procedure TBkBackup.SetFilesTypesToInclude(const Value: TSetOfByte);
begin
  FFileTypesToInclude := Value;
end;

procedure TBkBackup.SetFileToAdd(const Value: string);
begin
  FFileToAdd := Value;
end;

procedure TBkBackup.SetOnLogEvent(const Value: TLogMessageEvent);
begin
  FOnLogEvent := Value;
end;

procedure TBkBackup.SetOnProgressEvent(const Value: TProgressCallbackProc);
begin
  FOnProgressEvent := Value;
end;

procedure TBkBackup.SetReplaceExistingBackup(const Value: boolean);
begin
  FReplaceExistingBackup := Value;
end;

procedure TBkBackup.SetRootDir(const Value: string);
begin
  FRootDir := Value;
end;

procedure TBkBackup.SetZipFilename(const Value: string);
begin
  FZipFilename := Value;
end;

procedure TBkBackup.UpdateProgress(aMsg: string; aPercentComplete : double);
begin
  if Assigned( FOnProgressEvent) then
  begin
    FOnProgressEvent( aMsg, aPercentComplete);
  end
end;

procedure TBkBackup.ZipFiles;
var
  aMsg : string;
begin
  //check that everything is filled in
  if FZipFilename = '' then
    raise EBkBackupError.Create('Filename not specified');

  if FReplaceExistingBackup then
  begin
    if BKFileExists( FZipFilename) then
    begin
      UpdateProgress( 'Removing existing backup', 0.0);
      try
        WinUtils.RemoveFile( FZipFilename);
      except
        On E : Exception do
          raise EBkBackupError.Create( E.Message);
      end;
    end;
  end;

  LogMessage( 'Creating Backup ' + FZipFilename);

  CurrentFile := '';
  //if the root dir is not filled then the current dir will be used
  Zipper := TVCLZip.Create( Application);
  try
    Zipper.ZipName       := FZipFilename;
    Zipper.RelativePaths := true;
    Zipper.RootDir       := FRootDir;
    Zipper.Recurse       := true;

    if FDiskSpanning then
    begin
      Zipper.MultiMode   := mmSpan;
      Zipper.MultiZipInfo.SaveZipInfoOnFirstDisk := true;
      Zipper.MultiZipInfo.WriteDiskLabels := true;
    end;
    Zipper.OnStartZipInfo:= BkBackupOnStartZipInfo;
    Zipper.OnStartZip    := BkBackupOnStartZip;
    Zipper.OnEndZip      := BkBackupOnEndZip;
    Zipper.OnTotalPercentDone := BkBackupOnTotalPercent;

    if FCompressionLevel <> -1 then
      Zipper.PackLevel := FCompressionLevel;

    NumFilesToZip        := 0;
    NumFilesZipped       := 0;
    //now add selected file types
    try
      if biSystemDb in FFileTypesToInclude then
        Zipper.FilesList.Add( 'system.db');

      if biArchive in FFileTypesToInclude then
        Zipper.FilesList.Add( '*.txn');

      if biMasterMemFiles in FFileTypesToInclude then
      begin
        //need to add both old and new format master files
        //as both may exist
        Zipper.FilesList.Add( '*.mxl');
        Zipper.FilesList.Add( 'master*.*');
      end;

      if biINIFiles in FFileTypesToInclude then
        Zipper.FilesList.Add( '*.ini');

      if biLogFile in FFileTypesToInclude then
        Zipper.FilesList.Add( 'bk5win.log');

      if biAllClientFiles in FFileTypesToInclude then
        Zipper.FilesList.Add( '*.bk5');

      if biSpecifiedFile in FFileTypesToInclude then
        Zipper.FilesList.Add( FFileToAdd);

      //do the zip
      UpdateProgress( 'Preparing Backup', 0);
      Zipper.Zip;

      LogMessage( 'Backup Completed');
    except
      on e : exception do
      begin
        aMsg := E.Message + ' [' + E.Classname + ']';
        if CurrentFile <> '' then
          aMsg := aMsg + ' Processing ' + CurrentFile;

        raise EBkBackupError.Create( aMsg);
      end;
    end;
  finally
    Zipper.Free;
  end;
end;

function VerifyDirectory( const Path : string;
                          const Overwrite : boolean;
                          const DiskSpanningSupported : boolean;
                          var ErrorMsg : string;
                          var ErrorType : byte;
                          BackupFilename : string = '';
                          EstimatedFileSize : int64 = 0) : boolean;
var
  Drive : string;
  dt : integer;
  aMsg : string;
  DiskSizeOK : boolean;
  FreeSpace   : Int64;
  TotalSpace  : Int64;
  SpaceNeeded : Int64;
  IsRemovableDrive : boolean;
begin
  result := false;
  ErrorMsg := '';
  ErrorType := bkErrorGeneral;

  if ( Path <> '') then
  begin
    Drive := ExtractFileDrive( Path);
    dt := GetDriveType( PChar(Drive));
    IsRemovableDrive := ( dt = DRIVE_REMOVABLE);

    if not DirectoryExists( Path) then
    begin
      aMsg := Path + ' is not a valid directory.  Please select a directory.';
      if ( length( Drive) > 0) then
      begin
        //see if this is a drive letter
        if Copy( Drive, 1,1) <> '\' then
        begin
          //see if this is a removable drive and give a different message
          case dt of
            DRIVE_REMOVABLE, DRIVE_CDROM :
            begin
              aMsg := 'Please insert the appropriate media into drive ' + Drive;
              ErrorType := bkErrorMedia;
            end;
          end;
        end;
      end;

      ErrorMsg := aMsg;
      Exit;
    end;
  end
  else
  begin
    ErrorMsg := 'You must select a directory!';
    exit;
  end;

  //no errors in path, check for space
  if EstimatedFileSize <> 0 then
  begin
    DiskSizeOK := SysUtils.GetDiskFreeSpaceEx( PChar(Drive), FreeSpace, TotalSpace, nil);
    if DiskSizeOK then
    begin
      SpaceNeeded := EstimatedFilesize;

      if Overwrite and ( BackupFilename <> '') then
      begin
        //we will replace the existing file if there is one, so that gives us more
        //space
        if BKFileExists( Path + BackupFilename) then
          SpaceNeeded := SpaceNeeded - WinUtils.GetFileSize( Path + BackupFilename);
      end;

      if ( FreeSpace < SpaceNeeded) then
      begin
        aMsg := 'Not enough space to do backup ' + inttostr( EstimatedFilesize div 1024) + ' Kb required';

        if DiskSpanningSupported and IsRemovableDrive then
        begin
          //make sure the media is empty, zip spanning will do the rest
          case WinUtils.DriveState( Drive) of
            dsEmptyDisk : aMsg := '';
            dsDiskWithFiles : begin
              aMSg := 'You must insert blank media into ' + Drive;
              ErrorType := bkErrorMedia;
            end;
          else
            begin
              aMsg := 'Media Error';
              ErrorType := bkErrorMedia;
            end;
          end;
        end;

        if aMsg <> '' then
        begin
          ErrorMsg := aMsg;
          Exit;
        end;
      end;
    end;
  end;
  //no problems
  result := true;
end;

{ TBkRestore }

procedure TBkRestore.bkRestoreOnEndUnzip(Sender: TObject;
  FileIndex: Integer; FName: String);
var
  p : double;
  s : string;
begin
  Inc( NumFilesUnZipped);
  S := ExtractFilename( FName);

  if NumFilesToUnZip > 0 then
    p := (NumFilesUnZipped / NumFilesToUnZip) * 100
  else
    p := 0.0;

  UpdateProgress( S + ' restored', p);
  FileBeingUnZipped := '';
end;

procedure TBkRestore.bkRestoreOnTotalPercent(Sender: TObject;
  Percent: Integer);
begin
  if FileBeingUnzipped <> '' then
    UpdateProgress('Restoring ' + FileBeingUnzipped, percent);
end;

procedure TBkRestore.bkRestoreOnStartUnzip(Sender: TObject;
  FileIndex: Integer; var FName: String; var Skip: Boolean);
var
  S : string;
  p : double;
begin
  S := ExtractFilename( FName);
  FileBeingUnzipped := S;

  if NumFilesToUnZip > 0 then
    p := (NumFilesUnZipped / NumFilesToUnZip) * 100
  else
    p := 0.0;

  UpdateProgress( 'Restoring ' + S, p);
end;


procedure TBkRestore.bkRestoreOnStartUnzipInfo(Sender: TObject;
  NumFiles: Integer; TotalBytes: Comp; var StopNow: Boolean);
var
  Path        : string;
  DiskSizeOK  : boolean;
  FreeSpace   : Int64;
  TotalSpace  : Int64;
  SpaceNeeded : Int64;
begin
  //provides estimated info before the zipping starts
  NumFilesToUnZip := NumFiles;
  FileBeingUnZipped := '';

  //make sure there is enough disk space
  if FCheckFilesizeBeforeUnZip then
  begin
    Path       := ExtractFileDrive( Self.ExtractToDir);
    DiskSizeOK := SysUtils.GetDiskFreeSpaceEx( PChar(Path), FreeSpace, TotalSpace, nil);
    if DiskSizeOK then
    begin
      //managed to get the disk space free, if can't get it then dont do test
      SpaceNeeded := Round( TotalBytes);
      if ( FreeSpace < SpaceNeeded) then
        raise EBkBNotEnoughSpace.Create( 'Not enough space to do restore ' +
                                         inttostr( SpaceNeeded div 1024) + ' Kb required');
    end;
  end;
end;

constructor TBkRestore.Create;
begin
  FOnProgressEvent     := nil;
  FOnLogEvent          := nil;
  FRootDir             := '';
  FZipFilename         := '';
  FOverwriteFileIfExists := true;
  FCheckFilesizeBeforeUnZip := true;
  FDoAll:= False;
  FRecreateDirs := False;
end;

procedure TBkRestore.GetFileList(aListofFiles: TStringList);
var
  i : integer;
  FileDate : TDateTime;
begin

  if FZipFilename = '' then
    raise EBkBackupError.Create('Filename not specified');

  UpdateProgress( 'Examining Backup', 0.0);
  LogMessage( 'Examining Backup ' + FZipFilename);

  Unzipper := TVCLUnZip.Create( Application);
  try
    Unzipper.ZipName := FZipFilename;
    Unzipper.RootDir := FRootDir;
    Unzipper.ReadZip;

    for i := 0 to Unzipper.Count - 1 do
    begin
      CurrentFile := Unzipper.Filename[i];

      if biAllClientFiles in FFileTypesToExtract then
      begin
        //see if this is a client file
        if lowercase( ExtractFileExt( CurrentFile)) = '.bk5' then
        begin
          FileDate :=  Unzipper.DateTime[i];
          aListOfFiles.Add( Unzipper.Pathname[i] + Unzipper.Filename[i] + #9 + FormatDateTime( 'dd/mm/yy h:mm ampm', FileDate));
        end;
      end;
    end;
  finally
    Unzipper.Free;
  end;
end;

procedure TBkRestore.LogMessage(aMsg: string);
begin
  if Assigned( FOnLogEvent) then
  begin
    FOnLogEvent( aMsg);
  end
end;

procedure TBkRestore.SetCheckFileSizeBeforeUnzip(const Value: boolean);
begin
  FCheckFileSizeBeforeUnzip := Value;
end;

procedure TBkRestore.SetExtractTo(const Value: string);
begin
  FExtractTo := Value;
end;

procedure TBkRestore.SetFileToExtract(const Value: string);
begin
  FFileToExtract := Value;
end;

procedure TBkRestore.SetFileTypesToExtract(const Value: TSetOfByte);
begin
  FFileTypesToExtract := Value;
end;

procedure TBkRestore.SetOnLogEvent(const Value: TLogMessageEvent);
begin
  FOnLogEvent := Value;
end;

procedure TBkRestore.SetOnProgressEvent(
  const Value: TProgressCallbackProc);
begin
  FOnProgressEvent := Value;
end;

procedure TBkRestore.SetOverwriteFileIfExists(const Value: boolean);
begin
  FOverwriteFileIfExists := Value;
end;

procedure TBkRestore.SetRootDir(const Value: string);
begin
  FRootDir := Value;
end;

procedure TBkRestore.SetZipFilename(const Value: string);
begin
  FZipFilename := Value;
end;

procedure TBkRestore.UnZipFiles;
var
  aMsg : string;
begin
  if FZipFilename = '' then
    raise EBkBackupError.Create('Filename not specified');

  LogMessage( 'Restoring Backup ' + FZipFilename);

  CurrentFile := '';
  NumFilesToUnzip := 0;
  NumFilesUnzipped := 0;

  Unzipper := TVCLUnZip.Create( nil);
  try
    Unzipper.ZipName := FZipFilename;
    Unzipper.RootDir := FRootDir;
    UnZipper.OnStartUnZipInfo:= BkRestoreOnStartUnzipInfo;
    UnZipper.OnStartUnZip    := BkRestoreOnStartUnZip;
    UnZipper.OnEndUnZip      := BkRestoreOnEndUnZip;
    UnZipper.OnTotalPercentDone := bkRestoreOnTotalPercent;
    Unzipper.DestDir         := FExtractTo;
    Unzipper.DoAll := FDoAll;
    Unzipper.RecreateDirs := FRecreateDirs;
    //Unzipper.IncompleteZipMode := izAssumeMulti;  //will raise EIncompleteZip

    if FOverwriteFileIfExists then
      Unzipper.OverwriteMode := Always
    else
      Unzipper.OverwriteMode := Never;

    try
      UnZipper.ReadZip;
      if UnZipper.MultiMode = mmSpan then
        UnZipper.CheckDiskLabels := true;

      if biSpecifiedFile in FFileTypesToExtract then
        UnZipper.FilesList.Add( FFileToExtract);

      //do the zip
      UpdateProgress( 'Restoring Backup', 0);
      Unzipper.UnZip;

      LogMessage( 'Restore Completed');
    except
      on e : exception do
      begin
        aMsg := E.Message + ' [' + E.Classname + ']';
        if CurrentFile <> '' then
          aMsg := aMsg + ' Processing ' + CurrentFile;

        raise EBkBackupError.Create( aMsg);
      end;
    end;
  finally
    Unzipper.Free;
  end;
end;

procedure TBkRestore.UpdateProgress(aMsg: string;
  aPercentComplete: double);
begin
  if Assigned( FOnProgressEvent) then
  begin
    FOnProgressEvent( aMsg, aPercentComplete);
  end
end;



end.
