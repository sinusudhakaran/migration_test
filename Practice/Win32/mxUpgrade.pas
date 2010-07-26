unit mxUpgrade;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Master Memorisations Upgrade Routines

   Written:  Jun 00
   Authors:  Matthew

   Purpose:  Contains routines for upgrading the Master Mem files when the
             pMemorised_Tranaction_Rec structure changes

   Notes:    Does not use BKDEFS because the latest version will change.  The file structures
             must use hard coded definitions to make sure the version upgrades are using
             the correct structure for that version
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

Procedure UpdateMasterMemorisedEntryFilesToS20;
Procedure UpgradeMasterMemorisedAddGSTEdited;
Procedure UpgradeMasterMemorisedAddNotes;      //admin ver 48   5.1.63.x
procedure RenameMasterMemorisedFiles;          //admin ver 49   5.1.64.1
procedure UpgradeMasterMemorisedTo50Lines;     //admin ver 50   5.1.64.2
procedure UpgradeMasterMemorisedToIncludeNarration; //admin ver 52  5.2.0.x
procedure UpgradeMasterMemorisedToIncludeLineType; //admin ver 66 5.3.0.141+
procedure UpgradeMasterMemorisedFileFormat( IsAReupgrade : boolean); //admin ver 68 5.3.4.260+


implementation

uses
  Classes,
  BKDefs,
  //BKMDIO,
  crcFileUtils,
  BKMLIO,
  BKmxIO,
  bkConst,
  FCopy,
  GenUtils,
  Globals,
  ioStream,
  LogUtil,
  WinUtils,
  MemorisationsObj,
  MoneyDef,
  mxFiles32,
  SysUtils,
  Tokens,
  Windows;

//------------------------------------------------------------------------------
// These type definitions MUST always be hard coded to a particular version
// otherwise the upgrade will always try to use the LATEST version of the structure

Type
   tV33_Memorised_Transaction_Rec = Packed Record        // !!! 331 bytes !!!
      V33_mxRecord_Type                      : Byte;
      V33_mxSequence_No                      : LongInt;       { Stored }
      V33_mxType                             : Byte;       { Stored }
      V33_mxAmount                           : Money;       { Stored }
      V33_mxReference                        : String[ 12 ];       { Stored }
      V33_mxParticulars                      : String[ 12 ];       { Stored }
      V33_mxAnalysis                         : String[ 12 ];       { Stored }
      V33_mxOther_Party                      : String[ 20 ];       { Stored }
      V33_mxNarration                        : String[ 40 ];       { Stored }
      V33_mxMatch_on_Amount                  : Byte;       { Stored }
      V33_mxMatch_on_Refce                   : Boolean;       { Stored }
      V33_mxMatch_on_Particulars             : Boolean;       { Stored }
      V33_mxMatch_on_Analysis                : Boolean;       { Stored }
      V33_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V33_mxMatch_On_Narration               : Boolean;       { Stored }
      V33_mxAccount                          : Array[ 1..10 ] of String[ 10 ];       { Stored }
      V33_mxPercentage                       : Array[ 1..10 ] of Money;       { Stored }
      V33_mxGST_Class                        : Array[ 1..10 ] of Byte;       { Stored }
      V33_mxPayee_Number                     : LongInt;       { Stored }
      V33_mxFrom_Master_List                 : Boolean;       { Stored }
      V33_mxNext                             : Pointer;
      V33_mxEOR                              : Byte;
   end;

Type
   tV36_Memorised_Transaction_Rec = Packed Record       // !!! 431 bytes !!!
      V36_mxRecord_Type                      : Byte;
      V36_mxSequence_No                      : LongInt;       { Stored }
      V36_mxType                             : Byte;       { Stored }
      V36_mxAmount                           : Money;       { Stored }
      V36_mxReference                        : String[ 12 ];       { Stored }
      V36_mxParticulars                      : String[ 12 ];       { Stored }
      V36_mxAnalysis                         : String[ 12 ];       { Stored }
      V36_mxOther_Party                      : String[ 20 ];       { Stored }
      V36_mxNarration                        : String[ 40 ];       { Stored }
      V36_mxMatch_on_Amount                  : Byte;       { Stored }
      V36_mxMatch_on_Refce                   : Boolean;       { Stored }
      V36_mxMatch_on_Particulars             : Boolean;       { Stored }
      V36_mxMatch_on_Analysis                : Boolean;       { Stored }
      V36_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V36_mxMatch_On_Narration               : Boolean;       { Stored }
      V36_mxAccount                          : Array[ 1..10 ] of String[ 20 ];       { Stored }
      V36_mxPercentage                       : Array[ 1..10 ] of Money;       { Stored }
      V36_mxGST_Class                        : Array[ 1..10 ] of Byte;       { Stored }
      V36_mxPayee_Number                     : LongInt;       { Stored }
      V36_mxFrom_Master_List                 : Boolean;       { Stored }
      V36_mxNext                             : Pointer;
      V36_mxEOR                              : Byte;
   end;

Type
   tV40_Memorised_Transaction_Rec = Packed Record   // !!! 441 bytes !!!
      V40_mxRecord_Type                      : Byte;
      V40_mxSequence_No                      : LongInt;       { Stored }
      V40_mxType                             : Byte;       { Stored }
      V40_mxAmount                           : Money;       { Stored }
      V40_mxReference                        : String[ 12 ];       { Stored }
      V40_mxParticulars                      : String[ 12 ];       { Stored }
      V40_mxAnalysis                         : String[ 12 ];       { Stored }
      V40_mxOther_Party                      : String[ 20 ];       { Stored }
      V40_mxNarration                        : String[ 40 ];       { Stored }
      V40_mxMatch_on_Amount                  : Byte;       { Stored }
      V40_mxMatch_on_Refce                   : Boolean;       { Stored }
      V40_mxMatch_on_Particulars             : Boolean;       { Stored }
      V40_mxMatch_on_Analysis                : Boolean;       { Stored }
      V40_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V40_mxMatch_On_Narration               : Boolean;       { Stored }
      V40_mxAccount                          : Array[ 1..10 ] of String[ 20 ];       { Stored }
      V40_mxPercentage                       : Array[ 1..10 ] of Money;       { Stored }
      V40_mxGST_Class                        : Array[ 1..10 ] of Byte;       { Stored }
      V40_mxPayee_Number                     : LongInt;       { Stored }
      V40_mxFrom_Master_List                 : Boolean;       { Stored }
      V40_mxGST_Has_Been_Edited              : Array[ 1..10 ] of Boolean;       { Stored }
      V40_mxNext                             : Pointer;
      V40_mxEOR                              : Byte;
   end;

Type
   tV48_Memorised_Transaction_Rec = Packed Record   // !!! 483 bytes !!!
      V48_mxRecord_Type                      : Byte;
      V48_mxSequence_No                      : LongInt;       { Stored }
      V48_mxType                             : Byte;       { Stored }
      V48_mxAmount                           : Money;       { Stored }
      V48_mxReference                        : String[ 12 ];       { Stored }
      V48_mxParticulars                      : String[ 12 ];       { Stored }
      V48_mxAnalysis                         : String[ 12 ];       { Stored }
      V48_mxOther_Party                      : String[ 20 ];       { Stored }
      V48_mxNarration                        : String[ 40 ];       { Stored }
      V48_mxMatch_on_Amount                  : Byte;       { Stored }
      V48_mxMatch_on_Refce                   : Boolean;       { Stored }
      V48_mxMatch_on_Particulars             : Boolean;       { Stored }
      V48_mxMatch_on_Analysis                : Boolean;       { Stored }
      V48_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V48_mxMatch_On_Narration               : Boolean;       { Stored }
      V48_mxAccount                          : Array[ 1..10 ] of String[ 20 ];       { Stored }
      V48_mxPercentage                       : Array[ 1..10 ] of Money;       { Stored }
      V48_mxGST_Class                        : Array[ 1..10 ] of Byte;       { Stored }
      V48_mxPayee_Number                     : LongInt;       { Stored }
      V48_mxFrom_Master_List                 : Boolean;       { Stored }
      V48_mxGST_Has_Been_Edited              : Array[ 1..10 ] of Boolean;       { Stored }
      V48_mxMatch_on_Notes                   : Boolean;       { Stored }
      V48_mxNotes                            : String[ 40 ];       { Stored }
      V48_mxNext                             : Pointer;
      V48_mxEOR                              : Byte;
   end;

type
   tV50_Memorised_Transaction_Rec = Packed Record
      V50_mxRecord_Type                      : Byte;
      V50_mxSequence_No                      : Integer;       { Stored }
      V50_mxType                             : Byte;       { Stored }
      V50_mxAmount                           : Money;       { Stored }
      V50_mxReference                        : String[ 12 ];       { Stored }
      V50_mxParticulars                      : String[ 12 ];       { Stored }
      V50_mxAnalysis                         : String[ 12 ];       { Stored }
      V50_mxOther_Party                      : String[ 20 ];       { Stored }
      V50_mxNarration                        : String[ 40 ];       { Stored }
      V50_mxMatch_on_Amount                  : Byte;       { Stored }
      V50_mxMatch_on_Refce                   : Boolean;       { Stored }
      V50_mxMatch_on_Particulars             : Boolean;       { Stored }
      V50_mxMatch_on_Analysis                : Boolean;       { Stored }
      V50_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V50_mxMatch_On_Narration               : Boolean;       { Stored }
      V50_mxAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      V50_mxPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      V50_mxGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      V50_mxPayee_Number                     : Integer;       { Stored }
      V50_mxFrom_Master_List                 : Boolean;       { Stored }
      V50_mxGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      V50_mxMatch_on_Notes                   : Boolean;       { Stored }
      V50_mxNotes                            : String[ 40 ];       { Stored }
      V50_mxNext                             : Pointer;
      V50_mxEOR                              : Byte;
   end;

type
   tV52_Memorised_Transaction_Rec = Packed Record
      V52_mxRecord_Type                      : Byte;
      V52_mxSequence_No                      : Integer;       { Stored }
      V52_mxType                             : Byte;       { Stored }
      V52_mxAmount                           : Money;       { Stored }
      V52_mxReference                        : String[ 12 ];       { Stored }
      V52_mxParticulars                      : String[ 12 ];       { Stored }
      V52_mxAnalysis                         : String[ 12 ];       { Stored }
      V52_mxOther_Party                      : String[ 20 ];       { Stored }
      V52_mxStatement_Details                : String[ 40 ];       { Stored }
      V52_mxMatch_on_Amount                  : Byte;       { Stored }
      V52_mxMatch_on_Refce                   : Boolean;       { Stored }
      V52_mxMatch_on_Particulars             : Boolean;       { Stored }
      V52_mxMatch_on_Analysis                : Boolean;       { Stored }
      V52_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V52_mxMatch_On_Statement_Details       : Boolean;       { Stored }
      V52_mxAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      V52_mxPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      V52_mxGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      V52_mxPayee_Number                     : Integer;       { Stored }
      V52_mxFrom_Master_List                 : Boolean;       { Stored }
      V52_mxGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      V52_mxMatch_on_Notes                   : Boolean;       { Stored }
      V52_mxNotes                            : String[ 40 ];       { Stored }
      V52_mxGL_Narration                     : Array[ 1..50 ] of String[ 40 ];       { Stored }
      V52_mxNext                             : Pointer;
      V52_mxEOR                              : Byte;
   end;

type
   tV66_Memorised_Transaction_Rec = Packed Record
      V66_mxRecord_Type                      : Byte;
      V66_mxSequence_No                      : Integer;       { Stored }
      V66_mxType                             : Byte;       { Stored }
      V66_mxAmount                           : Money;       { Stored }
      V66_mxReference                        : String[ 12 ];       { Stored }
      V66_mxParticulars                      : String[ 12 ];       { Stored }
      V66_mxAnalysis                         : String[ 12 ];       { Stored }
      V66_mxOther_Party                      : String[ 20 ];       { Stored }
      V66_mxStatement_Details                : String[ 40 ];       { Stored }
      V66_mxMatch_on_Amount                  : Byte;       { Stored }
      V66_mxMatch_on_Refce                   : Boolean;       { Stored }
      V66_mxMatch_on_Particulars             : Boolean;       { Stored }
      V66_mxMatch_on_Analysis                : Boolean;       { Stored }
      V66_mxMatch_on_Other_Party             : Boolean;       { Stored }
      V66_mxMatch_On_Statement_Details       : Boolean;       { Stored }
      V66_mxAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      V66_mxPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      V66_mxGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      V66_mxPayee_Number                     : Integer;       { Stored }
      V66_mxFrom_Master_List                 : Boolean;       { Stored }
      V66_mxGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      V66_mxMatch_on_Notes                   : Boolean;       { Stored }
      V66_mxNotes                            : String[ 40 ];       { Stored }
      V66_mxGL_Narration                     : Array[ 1..50 ] of String[ 40 ];       { Stored }
      V66_mxLine_Type                        : Array[ 1..50 ] of Byte;       { Stored }
      V66_mxNext                             : Pointer;
      V66_mxEOR                              : Byte;
   end;

const
   UnitName = 'MXUPGRADE';
var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  PreV49_MasterFileName( Bank_No : Byte ): String;
//assumes that admin system is assigned, the routines in this unit are only called
//when an upgrade of the admin system is done.
var
   Prefix : String[2];
begin
   result := DATADIR + 'MMMM.MMD';

   Str( Bank_No:2, Prefix );
   If Prefix[1]=' ' then Prefix[1] := '0';
   If Prefix[2]=' ' then Prefix[2] := '0';

   case AdminSystem.fdFields.fdCountry of
      whNewZealand : result := DATADIR + MASTERMEMFILENAMENZ + '.'+ Prefix + MASTERMEMTRAILINGCHAR;
      whAustralia  : result := DATADIR + MASTERMEMFILENAMEOZ + '.'+ Prefix + MASTERMEMTRAILINGCHAR;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure UpdateMasterMemorisedEntryFilesToS20;

const
   ThisMethodName = 'UpdateMasterMemorisedEntryFilesToS20';
Var
   OldMxRec     : tV33_Memorised_Transaction_Rec;
   NewMxRec     : tV36_Memorised_Transaction_Rec;
   OldFile      : File of tV33_Memorised_Transaction_Rec;
   TempFile     : File of tV36_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   Bank         : Integer;
   i            : Integer;
Begin
   Assert( Sizeof( OldMxRec ) = 331, '! Record Size Error !' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   For Bank := 1 to 99 do
   Begin
      OldFileName := PreV49_MasterFileName( Bank );
      If BKFileExists( OldFileName ) then
      Begin
         LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
         Assign( OldFile, OldFileName );
         Reset( OldFile );
         TempFileName := DataDir + 'MASTER.TMP';
         Assign( TempFile, TempFileName );
         Rewrite( TempFile );
         While not EOF( OldFile ) do
         Begin
            Read( OldFile, OldMxRec );
            FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
            With OldMxRec, NewMxRec do
            Begin
               Assert( V33_mxRecord_Type = tkBegin_Memorised_Transaction );
               Assert( V33_mxEOR = tkEnd_Memorised_Transaction );
               V36_mxRecord_Type          := V33_mxRecord_Type           ;
               V36_mxSequence_No          := V33_mxSequence_No           ;
               V36_mxType                 := V33_mxType                  ;
               V36_mxAmount               := V33_mxAmount                ;
               V36_mxReference            := V33_mxReference             ;
               V36_mxParticulars          := V33_mxParticulars           ;
               V36_mxAnalysis             := V33_mxAnalysis              ;
               V36_mxOther_Party          := V33_mxOther_Party           ;
               V36_mxNarration            := V33_mxNarration             ;
               V36_mxMatch_on_Amount      := V33_mxMatch_on_Amount       ;
               V36_mxMatch_on_Refce       := V33_mxMatch_on_Refce        ;
               V36_mxMatch_on_Particulars := V33_mxMatch_on_Particulars  ;
               V36_mxMatch_on_Analysis    := V33_mxMatch_on_Analysis     ;
               V36_mxMatch_on_Other_Party := V33_mxMatch_on_Other_Party  ;
               V36_mxMatch_On_Narration   := V33_mxMatch_On_Narration    ;
               For i := 1 to 10 do V36_mxAccount[i]    := V33_mxAccount[i]     ;  // extended field
               For i := 1 to 10 do V36_mxPercentage[i] := V33_mxPercentage[i]  ;
               For i := 1 to 10 do V36_mxGST_Class[i]  := V33_mxGST_Class[i]   ;
               V36_mxPayee_Number         := V33_mxPayee_Number          ;
               V36_mxFrom_Master_List     := True                        ;
               V36_mxNext                 := NIL                         ;
               V36_mxEOR                  := V33_mxEOR                   ;
            end;
            Write( TempFile, NewMxRec );
         end;
         Close( OldFile );
         Close( TempFile );
         SysUtils.DeleteFile( PChar( OldFileName ) );
         SysUtils.RenameFile( TempFileName, OldFileName );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
//------------------------------------------------------------------------------

Procedure UpgradeMasterMemorisedAddGSTEdited;
//The mxGST_Has_Been_Edited flag was added to bkdefs in version 41.  Sydefs version
//was increased to v40 to force this routine to be called.
//The mxGST_Has_Been_Edited flag is set to FALSE for existing MASTER memorisations so
//that MASTER memorised entries always calculate GST at the current default GST rate for
//the client's chart.
//Any new memorisations will be forced to use the default gst class for the client being used
const
   ThisMethodName = 'UpgradeMasterMemorisedAddGSTEdited';


Var
   OldMxRec     : tV36_Memorised_Transaction_Rec;
   NewMxRec     : tV40_Memorised_Transaction_Rec;
   OldFile      : File of tV36_Memorised_Transaction_Rec;
   TempFile     : File of tV40_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   Bank         : Integer;
   i            : Integer;
Begin
   Assert( Sizeof( OldMxRec ) = 431, '! Record Size Error !' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   For Bank := 1 to 99 do
   Begin
      OldFileName := PreV49_MasterFileName( Bank );
      If BKFileExists( OldFileName ) then
      Begin
         LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
         Assign( OldFile, OldFileName );
         Reset( OldFile );
         TempFileName := DataDir + 'MASTER.TMP';
         Assign( TempFile, TempFileName );
         Rewrite( TempFile );
         While not EOF( OldFile ) do
         Begin
            Read( OldFile, OldMxRec );
            FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
            With OldMxRec, NewMxRec do
            Begin
               Assert( V36_mxRecord_Type = tkBegin_Memorised_Transaction );
               Assert( V36_mxEOR = tkEnd_Memorised_Transaction );
               V40_mxRecord_Type          := V36_mxRecord_Type           ;
               V40_mxSequence_No          := V36_mxSequence_No           ;
               V40_mxType                 := V36_mxType                  ;
               V40_mxAmount               := V36_mxAmount                ;
               V40_mxReference            := V36_mxReference             ;
               V40_mxParticulars          := V36_mxParticulars           ;
               V40_mxAnalysis             := V36_mxAnalysis              ;
               V40_mxOther_Party          := V36_mxOther_Party           ;
               V40_mxNarration            := V36_mxNarration             ;
               V40_mxMatch_on_Amount      := V36_mxMatch_on_Amount       ;
               V40_mxMatch_on_Refce       := V36_mxMatch_on_Refce        ;
               V40_mxMatch_on_Particulars := V36_mxMatch_on_Particulars  ;
               V40_mxMatch_on_Analysis    := V36_mxMatch_on_Analysis     ;
               V40_mxMatch_on_Other_Party := V36_mxMatch_on_Other_Party  ;
               V40_mxMatch_On_Narration   := V36_mxMatch_On_Narration    ;
               For i := 1 to 10 do V40_mxAccount[i]    := V36_mxAccount[i]     ;
               For i := 1 to 10 do V40_mxPercentage[i] := V36_mxPercentage[i]  ;
               For i := 1 to 10 do V40_mxGST_Class[i]  := V36_mxGST_Class[i]   ;
               For i := 1 to 10 do V40_mxGST_Has_Been_Edited[i] := FALSE ;          // new field
               V40_mxPayee_Number         := V36_mxPayee_Number          ;
               V40_mxFrom_Master_List     := True                        ;
               V40_mxNext                 := NIL                         ;
               V40_mxEOR                  := V36_mxEOR                   ;
            end;
            Write( TempFile, NewMxRec );
         end;
         Close( OldFile );
         Close( TempFile );
         SysUtils.DeleteFile( PChar( OldFileName ) );
         SysUtils.RenameFile( TempFileName, OldFileName );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpgradeMasterMemorisedAddNotes;
//Added  mxMatch_on_Notes                   : Boolean;       { Stored }
//       mxNotes                            : String[ 40 ];       { Stored }
//in version 58 of bkdefs
//Sydefs was increased to v48 to force this routine to be called.
const
   ThisMethodName = 'UpgradeMasterMemorisedAddGSTEdited';

Var
   OldMxRec     : tV40_Memorised_Transaction_Rec;
   NewMxRec     : tV48_Memorised_Transaction_Rec;
   OldFile      : File of tV40_Memorised_Transaction_Rec;
   TempFile     : File of tV48_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   Bank         : Integer;
   i            : Integer;
Begin
   Assert( Sizeof( OldMxRec ) = 441, '! Record Size Error !' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   For Bank := 1 to 99 do
   Begin
      OldFileName := PreV49_MasterFileName( Bank );
      If BKFileExists( OldFileName ) then
      Begin
         LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
         Assign( OldFile, OldFileName );
         Reset( OldFile );
         TempFileName := DataDir + 'MASTER.TMP';
         Assign( TempFile, TempFileName );
         Rewrite( TempFile );
         While not EOF( OldFile ) do
         Begin
            Read( OldFile, OldMxRec );
            FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
            With OldMxRec, NewMxRec do
            Begin
               Assert( V40_mxRecord_Type = tkBegin_Memorised_Transaction );
               Assert( V40_mxEOR = tkEnd_Memorised_Transaction );
               V48_mxRecord_Type          := V40_mxRecord_Type           ;
               V48_mxSequence_No          := V40_mxSequence_No           ;
               V48_mxType                 := V40_mxType                  ;
               V48_mxAmount               := V40_mxAmount                ;
               V48_mxReference            := V40_mxReference             ;
               V48_mxParticulars          := V40_mxParticulars           ;
               V48_mxAnalysis             := V40_mxAnalysis              ;
               V48_mxOther_Party          := V40_mxOther_Party           ;
               V48_mxNarration            := V40_mxNarration             ;
               V48_mxMatch_on_Amount      := V40_mxMatch_on_Amount       ;
               V48_mxMatch_on_Refce       := V40_mxMatch_on_Refce        ;
               V48_mxMatch_on_Particulars := V40_mxMatch_on_Particulars  ;
               V48_mxMatch_on_Analysis    := V40_mxMatch_on_Analysis     ;
               V48_mxMatch_on_Other_Party := V40_mxMatch_on_Other_Party  ;
               V48_mxMatch_On_Narration   := V40_mxMatch_On_Narration    ;
               For i := 1 to 10 do V48_mxAccount[i]    := V40_mxAccount[i]     ;
               For i := 1 to 10 do V48_mxPercentage[i] := V40_mxPercentage[i]  ;
               For i := 1 to 10 do V48_mxGST_Class[i]  := V40_mxGST_Class[i]   ;
               For i := 1 to 10 do V48_mxGST_Has_Been_Edited[i] := V40_mxGST_Has_Been_Edited[i];
               V48_mxPayee_Number         := V40_mxPayee_Number          ;
               V48_mxFrom_Master_List     := True                        ;
               V48_mxMatch_on_Notes       := false                       ; //NEW
               V48_mxNotes                := ''                          ; //NEW
               V48_mxNext                 := NIL                         ;
               V48_mxEOR                  := V40_mxEOR                   ;
            end;
            Write( TempFile, NewMxRec );
         end;
         Close( OldFile );
         Close( TempFile );
         SysUtils.DeleteFile( PChar( OldFileName ) );
         SysUtils.RenameFile( TempFileName, OldFileName );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RenameMasterMemorisedFiles;
//Sydefs was increased to v49 to force this routine to be called.

   function AcctPrefix( bNo : byte) : BankPrefixStr;
   var
      Prefix : String[ 2];
   begin
      Str( bNo:2, Prefix );
      If Prefix[1]=' ' then Prefix[1] := '0';
      If Prefix[2]=' ' then Prefix[2] := '0';
      result := Prefix;
   end;

const
   ThisMethodName = 'RenameMasterMemorisedFiles';
Var
   OldFileName  : String;
   NewFilename  : string;
   BankNo       : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   For BankNo := 1 to 99 do
   Begin
      OldFileName := PreV49_MasterFileName( BankNo );
      NewFilename := MasterFilename( AcctPrefix( BankNo));

      If BKFileExists( OldFileName ) then
      Begin
         LogUtil.LogMsg( lmInfo, UnitName, 'Renaming '+ OldFileName + ' to ' + NewFilename);
         SysUtils.RenameFile( OldFileName, NewFilename );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BuildMasterMemFilesList( var FilenameList : TStringList) : boolean;
var
   CountryPrefix     : String;
   FileSearchMask    : String;
   Found             : Integer;
   SearchRec         : TSearchRec;
begin
   result := false;
   CountryPrefix  := whShortNames[ AdminSystem.fdFields.fdCountry ];
   FileSearchMask := mmxPrefix + CountryPrefix + '*' + mmxExtn;
   Found := FindFirst(DATADIR + FileSearchMask, faAnyFile, SearchRec);
   try
      while Found = 0 do begin
         Result := true;
         //note:  searching for *.mxl will also return *.mxlold - Windows??!!@
         if lowercase( ExtractFileExt( SearchRec.Name)) = lowercase(mmxExtn) then
           FileNameList.Add( DataDir + SearchRec.Name);
         Found := FindNext(SearchRec);
      end;
   finally
      SysUtils.FindClose(SearchRec);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpgradeMasterMemorisedTo50Lines;
const
   ThisMethodName = 'UpgradeMasterMemorisedTo50Lines';

Var
   OldMxRec     : tV48_Memorised_Transaction_Rec;
   NewMxRec     : tV50_Memorised_Transaction_Rec;
   OldFile      : File of tV48_Memorised_Transaction_Rec;
   TempFile     : File of tV50_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   j            : Integer;
   i            : Integer;
   Filenames    : TStringList;
Begin
   Assert( Sizeof( OldMxRec ) = 483, '! Record Size Error !' + inttostr( SizeOf( OldMXRec)));

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   FileNames := TStringList.Create;
   try
      if not BuildMasterMemFilesList( Filenames) then
         Exit;

      //have list of file names, upgrade each one
      for j := 0 to Pred( Filenames.Count) do begin
         OldFileName := Filenames[ j];
         If BKFileExists( OldFileName ) then
         Begin
            LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
            Assign( OldFile, OldFileName );
            Reset( OldFile );
            TempFileName := DataDir + 'MASTER.TMP';
            Assign( TempFile, TempFileName );
            Rewrite( TempFile );
            While not EOF( OldFile ) do
            Begin
               Read( OldFile, OldMxRec );
               FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
               With OldMxRec, NewMxRec do
               Begin
                  Assert( V48_mxRecord_Type = tkBegin_Memorised_Transaction );
                  Assert( V48_mxEOR = tkEnd_Memorised_Transaction );
                  V50_mxRecord_Type          := V48_mxRecord_Type           ;
                  V50_mxSequence_No          := V48_mxSequence_No           ;
                  V50_mxType                 := V48_mxType                  ;
                  V50_mxAmount               := V48_mxAmount                ;
                  V50_mxReference            := V48_mxReference             ;
                  V50_mxParticulars          := V48_mxParticulars           ;
                  V50_mxAnalysis             := V48_mxAnalysis              ;
                  V50_mxOther_Party          := V48_mxOther_Party           ;
                  V50_mxNarration            := V48_mxNarration             ;
                  V50_mxMatch_on_Amount      := V48_mxMatch_on_Amount       ;
                  V50_mxMatch_on_Refce       := V48_mxMatch_on_Refce        ;
                  V50_mxMatch_on_Particulars := V48_mxMatch_on_Particulars  ;
                  V50_mxMatch_on_Analysis    := V48_mxMatch_on_Analysis     ;
                  V50_mxMatch_on_Other_Party := V48_mxMatch_on_Other_Party  ;
                  V50_mxMatch_On_Narration   := V48_mxMatch_On_Narration    ;
                  For i := 1 to 10 do V50_mxAccount[i]    := V48_mxAccount[i]     ;
                  For i := 1 to 10 do V50_mxPercentage[i] := V48_mxPercentage[i]  ;
                  For i := 1 to 10 do V50_mxGST_Class[i]  := V48_mxGST_Class[i]   ;
                  For i := 1 to 10 do V50_mxGST_Has_Been_Edited[i] := V48_mxGST_Has_Been_Edited[i];
                  V50_mxPayee_Number         := V48_mxPayee_Number          ;
                  V50_mxMatch_on_Notes       := V48_mxMatch_On_Notes        ;
                  V50_mxNotes                := V48_mxNotes                 ;

                  V50_mxFrom_Master_List     := True                        ;
                  V50_mxNext                 := NIL                         ;

                  V50_mxEOR                  := V48_mxEOR                   ;
               end;
               Write( TempFile, NewMxRec );
            end;
            Close( OldFile );
            Close( TempFile );
            SysUtils.DeleteFile( PChar( OldFileName ) );
            SysUtils.RenameFile( TempFileName, OldFileName );
         end;
      end;
   finally
      Filenames.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpgradeMasterMemorisedToIncludeNarration;
const
   ThisMethodName = 'UpgradeMasterMemorisedToIncludeNarration';

Var
   OldMxRec     : tV50_Memorised_Transaction_Rec;
   NewMxRec     : tV52_Memorised_Transaction_Rec;
   OldFile      : File of tV50_Memorised_Transaction_Rec;
   TempFile     : File of tV52_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   j            : Integer;
   i            : Integer;
   Filenames    : TStringList;
Begin
   Assert( Sizeof( OldMxRec ) = 1723, '! Record Size Error ! 1723 <> ' + inttostr( SizeOf( OldMXRec)));

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   FileNames := TStringList.Create;
   try
      if not BuildMasterMemFilesList( Filenames) then
         Exit;

      //have list of file names, upgrade each one
      for j := 0 to Pred( Filenames.Count) do begin
         OldFileName := Filenames[ j];
         If BKFileExists( OldFileName ) then
         Begin
            LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
            Assign( OldFile, OldFileName );
            Reset( OldFile );
            TempFileName := DataDir + 'MASTER.TMP';
            Assign( TempFile, TempFileName );
            Rewrite( TempFile );
            While not EOF( OldFile ) do
            Begin
               Read( OldFile, OldMxRec );
               FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
               With OldMxRec, NewMxRec do
               Begin
                  Assert( V50_mxRecord_Type = tkBegin_Memorised_Transaction );
                  Assert( V50_mxEOR = tkEnd_Memorised_Transaction );
                  V52_mxRecord_Type          := V50_mxRecord_Type           ;
                  V52_mxSequence_No          := V50_mxSequence_No           ;
                  V52_mxType                 := V50_mxType                  ;
                  V52_mxAmount               := V50_mxAmount                ;
                  V52_mxReference            := V50_mxReference             ;
                  V52_mxParticulars          := V50_mxParticulars           ;
                  V52_mxAnalysis             := V50_mxAnalysis              ;
                  V52_mxOther_Party          := V50_mxOther_Party           ;
                  V52_mxStatement_Details    := V50_mxNarration             ;
                  V52_mxMatch_on_Amount      := V50_mxMatch_on_Amount       ;
                  V52_mxMatch_on_Refce       := V50_mxMatch_on_Refce        ;
                  V52_mxMatch_on_Particulars := V50_mxMatch_on_Particulars  ;
                  V52_mxMatch_on_Analysis    := V50_mxMatch_on_Analysis     ;
                  V52_mxMatch_on_Other_Party := V50_mxMatch_on_Other_Party  ;
                  V52_mxMatch_On_Statement_Details        := V50_mxMatch_On_Narration    ;
                  For i := 1 to 50 do V52_mxAccount[i]    := V50_mxAccount[i]     ;
                  For i := 1 to 50 do V52_mxPercentage[i] := V50_mxPercentage[i]  ;
                  For i := 1 to 50 do V52_mxGST_Class[i]  := V50_mxGST_Class[i]   ;
                  For i := 1 to 50 do V52_mxGST_Has_Been_Edited[i] := V50_mxGST_Has_Been_Edited[i];
                  For i := 1 to 50 do V52_mxGL_Narration[i] := '';           //NEW FIELD
                  V52_mxPayee_Number         := V50_mxPayee_Number          ;
                  V52_mxMatch_on_Notes       := V50_mxMatch_On_Notes        ;
                  V52_mxNotes                := V50_mxNotes                 ;

                  V52_mxFrom_Master_List     := True                        ;
                  V52_mxNext                 := NIL                         ;

                  V52_mxEOR                  := V50_mxEOR                   ;
               end;
               Write( TempFile, NewMxRec );
            end;
            Close( OldFile );
            Close( TempFile );
            SysUtils.DeleteFile( PChar( OldFileName ) );
            SysUtils.RenameFile( TempFileName, OldFileName );
         end;
      end;
   finally
      Filenames.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpgradeMasterMemorisedToIncludeLineType;
const
   ThisMethodName = 'UpgradeMasterMemorisedToIncludeNarration';

Var
   OldMxRec     : tV52_Memorised_Transaction_Rec;
   NewMxRec     : tV66_Memorised_Transaction_Rec;
   OldFile      : File of tV52_Memorised_Transaction_Rec;
   TempFile     : File of tV66_Memorised_Transaction_Rec;
   OldFileName  : String;
   TempFileName : String;
   j            : Integer;
   i            : Integer;
   Filenames    : TStringList;
   DefaultLineType : byte;
Begin
   Assert( Sizeof( OldMxRec ) = 3773, '! Record Size Error ! 3773 <> ' + inttostr( SizeOf( OldMXRec)));

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   FileNames := TStringList.Create;
   try
      if not BuildMasterMemFilesList( Filenames) then
         Exit;

      //have list of file names, upgrade each one
      for j := 0 to Pred( Filenames.Count) do begin
         OldFileName := Filenames[ j];
         If BKFileExists( OldFileName ) then
         Begin
            LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );
            Assign( OldFile, OldFileName );
            Reset( OldFile );
            TempFileName := DataDir + 'MASTER.TMP';
            Assign( TempFile, TempFileName );
            Rewrite( TempFile );
            While not EOF( OldFile ) do
            Begin
               Read( OldFile, OldMxRec );
               FillChar( NewMxRec, Sizeof( NewMxRec ), 0 );
               With OldMxRec, NewMxRec do
               Begin
                  Assert( V52_mxRecord_Type = tkBegin_Memorised_Transaction );
                  Assert( V52_mxEOR = tkEnd_Memorised_Transaction );
                  V66_mxRecord_Type          := V52_mxRecord_Type           ;
                  V66_mxSequence_No          := V52_mxSequence_No           ;
                  V66_mxType                 := V52_mxType                  ;
                  V66_mxAmount               := V52_mxAmount                ;
                  V66_mxReference            := V52_mxReference             ;
                  V66_mxParticulars          := V52_mxParticulars           ;
                  V66_mxAnalysis             := V52_mxAnalysis              ;
                  V66_mxOther_Party          := V52_mxOther_Party           ;
                  V66_mxStatement_Details    := V52_mxStatement_Details     ;

                  //v52 values  0= No   1= Yes   2= $/%
                  case V52_mxMatch_on_Amount of
                    mxNo :   V66_mxMatch_on_Amount := mxNo;
                    mxOld_Yes : V66_mxMatch_on_Amount := mxAmtEqual;
                    mxOld_FixVbl : V66_mxMatch_on_Amount := mxNo;
                  else
                    V66_mxMatch_on_Amount := mxNo;
                  end;

                  V66_mxMatch_on_Refce       := V52_mxMatch_on_Refce        ;
                  V66_mxMatch_on_Particulars := V52_mxMatch_on_Particulars  ;
                  V66_mxMatch_on_Analysis    := V52_mxMatch_on_Analysis     ;
                  V66_mxMatch_on_Other_Party := V52_mxMatch_on_Other_Party  ;
                  V66_mxMatch_On_Statement_Details := V52_mxMatch_On_Statement_Details;

                  For i := 1 to 50 do V66_mxAccount[i]    := V52_mxAccount[i]     ;
                  For i := 1 to 50 do V66_mxPercentage[i] := V52_mxPercentage[i]  ;
                  For i := 1 to 50 do V66_mxGST_Class[i]  := V52_mxGST_Class[i]   ;
                  For i := 1 to 50 do V66_mxGST_Has_Been_Edited[i] := V52_mxGST_Has_Been_Edited[i];
                  For i := 1 to 50 do V66_mxGL_Narration[i] := V52_mxGL_Narration[i];

                  //new field, set the line type
                  if V52_mxMatch_on_Amount = mxOld_Yes then
                    DefaultLineType := mltDollarAmt
                  else
                    DefaultLineType := mltPercentage;

                  //set default
                  For i := 1 to 50 do
                    V66_mxLine_Type[ i] := DefaultLineType;

                  //override first line type if was %/$
                  if V52_mxMatch_on_Amount = mxOld_FixVbl then
                    V66_mxLine_Type[ 1] := mltDollarAmt;

                  V66_mxPayee_Number         := V52_mxPayee_Number          ;
                  V66_mxMatch_on_Notes       := V52_mxMatch_On_Notes        ;
                  V66_mxNotes                := V52_mxNotes                 ;
                  V66_mxFrom_Master_List     := True                        ;
                  V66_mxNext                 := NIL                         ;
                  V66_mxEOR                  := V52_mxEOR                   ;
               end;
               Write( TempFile, NewMxRec );
            end;
            Close( OldFile );
            Close( TempFile );
            SysUtils.DeleteFile( PChar( OldFileName ) );
            SysUtils.RenameFile( TempFileName, OldFileName );
         end;
      end;
   finally
      Filenames.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReadMasterMemHeader( aFilename : string; var Header : TSystemMemorisationListHeader);
var
  MasterFileStream : TIOStream;
begin
  FillChar( Header, SizeOf( TSystemMemorisationListHeader), #0);

  MasterFileStream := TIOStream.Create;
  try
    //load into stream
    MasterFileStream.LoadFromFile( aFilename);
    //check crc
    try
      CheckEmbeddedCRC( MasterFileStream);
    except
      On E :ECRCCheckFailed do
        exit;
    end;
    //read header
    MasterFileStream.Position := 0;
    MasterFileStream.Read( Header, SizeOf(TSystemMemorisationListHeader));
  finally
    MasterFileStream.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpgradeMasterMemorisedFileFormat( IsAReupgrade : boolean);
const
   ThisMethodName = 'UpgradeMasterMemorisedToIncludeNarration';

Var
  OldMxRec     : tV66_Memorised_Transaction_Rec;
  OldFile      : File of tV66_Memorised_Transaction_Rec;
  //TempFile     : File of tV66_Memorised_Transaction_Rec;
  OldFileName  : String;
  TempFileName : String;
  fs : Int64;
  i, j, k      : Integer;
  Filenames    : TStringList;
  ACode : String;
  PrefixLen : Integer;

  Master_Memorisations_List : TMaster_Memorisations_List;
  Memorisation : TMemorisation;
  pM : pMemorisation_Line_Rec;

  Header : TSystemMemorisationListHeader;

  UpgradeThisFile : boolean;
begin
  Assert( Sizeof( OldMxRec ) = 3823, '! Record Size Error ! 3823 <> ' + inttostr( SizeOf( OldMXRec)));

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   if IsAReupgrade then
     LogUtil.LogMsg( lmInfo, UnitName, 'Reupgrading Master Mem Files');

   FileNames := TStringList.Create;
   try
      if not BuildMasterMemFilesList( Filenames) then
         Exit;

      //have list of file names, upgrade each one
      for j := 0 to Pred( Filenames.Count) do
      begin
         OldFileName := Filenames[ j];
         if BKFileExists( OldFileName ) then
         begin
           //find expected code
           //get memorisation code
           ACode  := whNames[ AdminSystem.fdFields.fdCountry ];
           PrefixLen := Length(mmxPrefix) + Length(ACode);
           ACode := ExtractFileName(OldFileName);
           k := Pos('.',ACode);
           ACode := Copy(ACode, PrefixLen+1, Length(ACode)-PrefixLen-(Length(ACode)-k+1));

           UpgradeThisFile := true;

           if IsAReupgrade then
           begin
             //due to a problem in 5.4.0.338/341 some files were skipped if
             //the search rec returned .MXL instead of .mxl.  To handle re upgrading
             //we now need to read the header if this flag is set
             ReadMasterMemHeader( OldFilename, Header);
             if ( Header.smPrefix = aCode) and ( Header.smFile_Version = 96) then
             begin
               //file appears to be be upgraded already
               UpgradeThisFile := false;
               LogUtil.LogMsg( lmInfo, UnitName, OldFileName + ' skipped' );
             end;
           end;

           if UpgradeThisFile then
           begin
             //backup the file
             TempFileName := ChangeFileExt(OldFileName, '.bak');
             FCopy.CopyFile(OldFileName, TempFileName);
             //start upgrade
             LogUtil.LogMsg( lmInfo, UnitName, 'Upgrading '+OldFileName + ' to new format' );

             fs := WinUtils.GetFileSize( OldFilename);
             Assert(( fs mod SizeOf( OldMXRec)) = 0, 'Invalid file size, FileSize mod SizeOf <> 0');

             Assign( OldFile, OldFileName );
             Reset( OldFile );

             Master_Memorisations_List := TMaster_Memorisations_List.Create(ACode);
             try
               while not EOF( OldFile ) do
               begin
                  Read( OldFile, OldMxRec );
                  Memorisation := TMemorisation.Create;
                  with Memorisation, OldMxRec do
                  begin
                     Assert( V66_mxRecord_Type = tkBegin_Memorised_Transaction );
                     Assert( V66_mxEOR = tkEnd_Memorised_Transaction );

                     //mdFields.mdRecord_Type := V66_mxRecord_Type;  Will be set during TMemorisation.Create
                     //mdFields.mdSequence_No := V66_mxSequence_No;  Will be set during insert
                     //mdFields.mdEOR := V66_mxEOR;

                     mdFields.mdType := V66_mxType;

                     mdFields.mdAmount := V66_mxAmount;
                     mdFields.mdReference := V66_mxReference;
                     mdFields.mdParticulars := V66_mxParticulars;
                     mdFields.mdAnalysis := V66_mxAnalysis;
                     mdFields.mdOther_Party := V66_mxOther_Party;
                     mdFields.mdStatement_Details := V66_mxStatement_Details;
                     mdFields.mdNotes := V66_mxNotes;

                     mdFields.mdMatch_on_Amount := V66_mxMatch_on_Amount;
                     mdFields.mdMatch_on_Refce := V66_mxMatch_on_Refce;
                     mdFields.mdMatch_on_Particulars := V66_mxMatch_on_Particulars;
                     mdFields.mdMatch_on_Analysis := V66_mxMatch_on_Analysis;
                     mdFields.mdMatch_on_Other_Party := V66_mxMatch_on_Other_Party;
                     mdFields.mdMatch_On_Statement_Details := V66_mxMatch_On_Statement_Details;
                     mdFields.mdMatch_on_Notes := V66_mxMatch_on_Notes;

                     for i := 1 to 50 do
                     begin
                       if (V66_mxAccount[i] <> '') then
                       begin
                         pM := BKMLIO.New_Memorisation_Line_Rec;
                         PM^.mlAccount := V66_mxAccount[i];
                         PM^.mlPercentage := V66_mxPercentage[i];
                         PM^.mlGST_Class := V66_mxGST_Class[i];
                         PM^.mlGST_Has_Been_Edited := V66_mxGST_Has_Been_Edited[i];
                         PM^.mlGL_Narration := V66_mxGL_Narration[i];
                         PM^.mlLine_Type := V66_mxLine_Type[i];
                         Memorisation.mdLines.Insert(pM);
                       end;
                     end;

                     mdFields.mdPayee_Number := V66_mxPayee_Number;
                     mdFields.mdFrom_Master_List := V66_mxFrom_Master_List;
                  end;
                  Master_Memorisations_List.Insert_Memorisation(Memorisation);
               end;
               Close( OldFile );

               //save file in new format
               Master_Memorisations_List.SaveToFile;
             finally
               Master_Memorisations_List.Free;
             end;
             SysUtils.DeleteFile(TempFileName);
           end; //if upgradeThisFile
         end;
      end;
   finally
      Filenames.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.

