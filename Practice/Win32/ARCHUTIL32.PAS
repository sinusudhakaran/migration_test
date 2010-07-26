Unit ARCHUTIL32;
{  ---------------------------------------------  }
INTERFACE USES MONEYDEF;
{  ---------------------------------------------  }

TYPE
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  tV53_Archived_Transaction = Packed Record
    aV53_LRN                 : LongInt     ; (* LRN *)
    aV53_Type                : Byte        ; (* Type *)
    aV53_Source              : Byte        ; (* Source *)
    aV53_Date_Presented      : LongInt     ; (* Date Presented *)
    aV53_Date_Transferred    : LongInt     ; (* Date Transferred *)
    aV53_Amount              : Money       ; (* Amount *)
    aV53_Quantity            : Money       ; (* Quantity *)
    aV53_Cheque_Number       : LongInt     ; (* Cheque Number *)
    aV53_Reference           : String[ 12] ; (* Reference *)
    aV53_Particulars         : String[ 12] ; (* Particulars *)
    aV53_Analysis            : String[ 12] ; (* Analysis *)
    aV53_OrigBB              : String[  6] ; (* OrigBB *)
    aV53_Other_Party         : String[ 20] ; (* Other Party *)
    aV53_Narration           : String[ 40] ; (* Narration *)
    aV53_Spare               : Array[1..32] of Byte; (* Spare *)
  End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  tV54_Archived_Transaction = Packed Record
    aV54_LRN                 : LongInt     ; (* LRN *)
    aV54_Type                : Byte        ; (* Type *)
    aV54_Source              : Byte        ; (* Source *)
    aV54_Date_Presented      : LongInt     ; (* Date Presented *)
    aV54_Date_Transferred    : LongInt     ; (* Date Transferred *)
    aV54_Amount              : Money       ; (* Amount *)
    aV54_Quantity            : Money       ; (* Quantity *)
    aV54_Cheque_Number       : LongInt     ; (* Cheque Number *)
    aV54_Reference           : String[ 12] ; (* Reference *)
    aV54_Particulars         : String[ 12] ; (* Particulars *)
    aV54_Analysis            : String[ 12] ; (* Analysis *)
    aV54_OrigBB              : String[  6] ; (* OrigBB *)
    aV54_Other_Party         : String[ 20] ; (* Other Party *)
    aV54_Narration           : String[ 40] ; (* Narration *)
    aV54_Statement_Details   : String[ 200];
    aV54_Unique_ID           : LongInt     ;
    aV54_Spare               : Array[1..32] of Byte; (* Spare *)
    aV54_Record_End_Marker   : LongInt;
  End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //LATEST VERSION
  //upgraded in version 54 of admin
  tArchived_Transaction = Packed Record
    aLRN                 : LongInt     ; (* LRN *)
    aType                : Byte        ; (* Type *)
    aSource              : Byte        ; (* Source *)
    aDate_Presented      : LongInt     ; (* Date Presented *)
    aDate_Transferred    : LongInt     ; (* Date Transferred *)
    aAmount              : Money       ; (* Amount *)
    aQuantity            : Money       ; (* Quantity *)
    aCheque_Number       : LongInt     ; (* Cheque Number *)
    aReference           : String[ 12] ; (* Reference *)
    aParticulars         : String[ 12] ; (* Particulars *)
    aAnalysis            : String[ 12] ; (* Analysis *)
    aOrigBB              : String[  6] ; (* OrigBB *)
    aOther_Party         : String[ 20] ; (* Other Party *)
    aNarration           : String[ 40] ; (* Narration *)
    aStatement_Details   : String[ 200];
    aUnique_ID           : LongInt     ;
    aSpare               : Array[1..32] of Byte; (* Spare *)
    aRecord_End_Marker   : LongInt;
  End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  EntryArchive   = File of tArchived_Transaction;

const
  ARCHIVE_REC_END_MARKER      = 54;

Function    ArchiveFileName( LRN : LongInt ): String;
Function    TempFileName( LRN : LongInt ): String;

function    Backupfilename( LRN : LongInt) : string;

Procedure   GetArchiveInfo( LRN : LongInt; Var NoTrx, First, Last : LongInt );

//******************************************************************************
IMPLEMENTATION
//USES DOS, LOGUTIL, MISC, FILEUTIL;
uses
   Globals, LogUtil, Sysutils, WinUtils;

{---------------------------------------------}
function GetArchiveFileName(LRN : Longint): string;
Var
   S        : String[64];
   SubDir   : String[10];
   SubDirNo : LongInt;
   i        : Byte;
Begin
   Result := '';
   Str( LRN:8, S );
   for i := 1 to 8 do begin
     If S[i]=' ' then
       S[i]:='0';
   end;    

   SubDirNo := ( LRN div 25 ); { Compromise to give 25 files in each subdirectory }
   Str( SubDirNo:5, SubDir );   { With 500 accounts, this gives 20 subdirectories }

   For i := 1 to 5 do If SubDir[i]=' ' then SubDir[i]:= '0';
   SubDir := 'SUB'+SubDir;

   if not DirectoryExists(DownloadArchiveDir) then
     if not CreateDir(DownloadArchiveDir) then
       raise EInOutError.Create('Unable to Create Directory '+DownloadArchiveDir);

   if not DirectoryExists(DownloadArchiveDir+SUBDIR) then
     if not CreateDir(DownloadArchiveDir+SUBDIR) then
       raise EInOutError.Create('Unable to Create Directory '+DownloadArchiveDir+SUBDIR);

   result := DownloadArchiveDir + SubDir+'\'+S;
end;
{---------------------------------------------}
Function ArchiveFileName( LRN : LongInt ): String;
begin
   ArchiveFileName := GetArchiveFileName(LRN)+'.TXN';
end;
{---------------------------------------------}
Function TempFileName( LRN : LongInt ): String;
begin
   TempFileName := GetArchiveFileName(LRN)+'.TX$';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function Backupfilename( LRN : LongInt) : string;
begin
  result := GetArchiveFilename( LRN) + '.txb';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure GetArchiveInfo( LRN : LongInt; Var NoTrx, First, Last : LongInt );
Var
   ArchiveName : String;
   ArchiveFile : File of tArchived_Transaction;
   T           : tArchived_Transaction;
Begin
   ArchiveName := ArchiveFileName( LRN );
   NoTrx := 0;
   First := 0;
   Last  := 0;
   If BKFileExists( ArchiveName ) then
   Begin
      Assignfile(ArchiveFile,ArchiveName);
      Reset(ArchiveFile);
      try
        NoTrx := FileSize(ArchiveFile);
        If NoTrx > 0 then
        Begin
           Seek( ArchiveFile, 0 );
           Read( ArchiveFile, T );
           First := T.aDate_Presented;

           Seek( ArchiveFile, NoTrx-1 );
           Read( ArchiveFile, T );
           Last := T.aDate_Presented;
        end;
      finally
         CloseFile(ArchiveFile);
      end;
   end;
end;

END.
