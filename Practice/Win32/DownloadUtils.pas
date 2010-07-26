unit DownloadUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Utility functions used by the download routines
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   NFDiskObj;

function  NoOfNewFilesToDownload( BankLinkCode : string;
                                  DirForImages : string;
                                  StartAt : integer) : Integer;


function  GetNewFormatFilename(const BankLinkCode : string; const DiskNo : integer) : string;
function  GetOldFormatFilename(const BankLinkCode : string; const DiskNo : integer) : string;

function  GetFilenameAndFormat( const BankLinkCode : string;
                                const DirForImages : string;
                                const DiskNo       : integer;
                                var   Filename     : string;
                                var   FormatID     : integer) : boolean;

function GetSerialNoForImage( const Country : byte; const DImage : TNewFormatDisk) : string;

//These three are just call FileExtensionUtils, so that other units calls don't change
function MakeSuffix(Number: Integer) : string;
function SuffixToSequenceNo(Suffix : string) : integer;
function IsValidSuffix(Suffix: string): Boolean;

const
  //References to this should be replaced with IsValidSuffix call
  InvalidSuffixValue = 999999;  //used to indicate value is invalid, set high
                                //so if ever got set then no downloads could be
                                //done

//******************************************************************************
implementation
uses
   LogUtil,
   bkConst,
   SysUtils,
   StrUtils,
   WinUtils,
   FileExtensionUtils;

const
   UnitName = 'DOWNLOADUTILS';
var
   DebugMe  : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetNewFormatFilename(const BankLinkCode : string; const DiskNo : integer) : string;
//returns the filename for the file, no path information is returned
begin
  result := 'BK_' + BankLinkCode + '.' + MakeSuffix( DiskNo );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetOldFormatFilename(const BankLinkCode : string; const DiskNo : integer) : string;
//returns the filename for the file, no path information is returned
begin
  result := BankLinkCode + '.' + MakeSuffix( DiskNo );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetFilenameAndFormat( const BankLinkCode : string;
                               const DirForImages : string;
                               const DiskNo       : integer;
                               var   Filename     : string;
                               var   FormatID     : integer) : boolean;
//returns false if the file could not be found
//looks for version 2 file first
//returns the filename only, does not include path information
var
  NewFormatFilename : string;
  OldFormatFilename : string;
begin
  result   := false;
  Filename := '';
  FormatID := 0;
  //determine disk filename and format
  NewFormatFilename := GetNewFormatFilename( BankLinkCode, DiskNo);
  OldFormatFilename := GetOldFormatFilename( BankLinkCode, DiskNo);

  if BKFileExists( DirForImages + NewFormatFilename ) then
  begin
    Filename  := NewFormatFilename;
    //may need more code here in the future to detect version
    FormatID  := 2;
    result    := true;
  end
  else
  begin
    if BKFileExists( DirForImages + OldFormatFilename) then
    begin
      Filename  := OldFormatFilename;
      FormatID  := 0;
      result    := true;
    end
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSerialNoForImage( const Country : byte; const DImage : TNewFormatDisk) : string;
begin
  if DImage.dhFields.dhDisk_Number < 3600 then
  begin
    if Country = whNewZealand then
      result := DImage.dhFields.dhFloppy_Desc_NZ_Only
    else
      result := DImage.dhFields.dhFile_Name;
  end
  else
    Result := DImage.dhFields.dhTrue_File_Name;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function NoOfNewFilesToDownload( BankLinkCode : string;
                                 DirForImages : string;
                                 StartAt : integer) : Integer;
const
   ThisMethodName = 'NoOfNewFilesToDownload';
Var
   NoOfFiles      : Integer;
   OldFormatFilename    : String;
   NewFormatFilename    : string;
   Count          : Integer;
   aMsg           : string;

   FileFound      : boolean;
   NewSequenceNumber: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Count       := 0;
   NoOfFiles   := 0;

   repeat
     Inc( Count );
     NewSequenceNumber := StartAt + Count;
     //Don't chekc for files that are past the end of the valid sequence numbers
     if NewSequenceNumber > LastSequenceNumber then
      Break;
     

     NewFormatFilename := GetNewFormatFilename( BankLinkCode, NewSequenceNumber);
     OldFormatFilename := GetOldFormatFilename( BankLinkCode, NewSequenceNumber);

     FileFound := ( BKFileExists( DirForImages + NewFormatFilename) or
                    BKFileExists( DirForImages + OldFormatFilename));

     if FileFound then
       Inc( NoOfFiles )
   until (not FileFound);

   if DebugMe then begin
      aMsg := Format( 'Found %d new files', [ NoOfFiles ] );
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - ' + aMsg );
   end;

   Result := NoOfFiles;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function MakeSuffix(Number: Integer) : string;
begin
  Result := FileExtensionUtils.MakeSuffix(Number);
end;

function SuffixToSequenceNo(Suffix : string) : integer;
begin
  Result := FileExtensionUtils.SuffixToSequenceNo(Suffix);
end;

function IsValidSuffix(Suffix: string): Boolean;
begin
  Result := FileExtensionUtils.IsValidSuffix(Suffix);
end;


initialization
   DebugMe := DebugUnit(UnitName);
end.
