unit upgrade;

{
This unit contains all the code required to upgrade the data for each new
version of BankLink 5.0. This is called from the project file before any forms
appear.

V32     Upgrades GST Class Code information in AdminSystem.
V33     Bk5CodeStr has increased to 20 characters, so the Master Memorised Entry
        files must be upgraded to the new record layout.



        NOTE:  Dont Use MY-CLIENT!!!

}

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------
uses
   clObj32;

Procedure UpgradeAdminToLatestVersion;
Procedure UpgradeClientToLatestVersion( aClient : TClientObj );
Procedure UpgradeExchangeRatesToLatestVersion;

// ----------------------------------------------------------------------------
implementation
uses
  OmniXML,
  OmniXMLUtils,
  Graphics,
  Admin32,
  ArchiveCheck,
  ArchUtil32,
  backup,
  baObj32,
  bkblio,
  bkplio,
  bk5Except,
  bkConst,
  bkDateUtils,
  bkDefs,
  bkmlio,
  blList32,
  bufFStrm,
  BUDOBJ32,
  chList32,
  classes,
  CustomHeadingsListObj,
  DBCreate,
  ECollect,
  fcopy,
  Files,
  Forms,  //need access to Application Obj
  Dialogs,
  genUtils,
  glConst,
  Globals,
  GSTCalc32,
  LogUtil,
  Merge32,
  MemorisationsObj,
  MoneyDef,
  MxUpgrade,
  PayeeObj,
  Progress,
  stDate,
  stDateSt,
  stStrs,
  SYDEFS,
  SysUtils,
  SysObj32,
  SBAList32,
  Inisettings,
  Windows,
  ReportTypes,
  YesNoDlg, pyList32, cfList32, WinUtils, SYamIO, mxFiles32, BasUtils, Software,
  SystemMemorisationList, IOStream, AuditMgr, CountryUtils,
  ExchangeRateList, MCDEFS, stTree, stBase,
  BankLinkOnlineServices,
  SYctIO,
  bkBranding,
  UpgradeMemorisations,
  CodingFormConst,
  RecommendedMems;
// ----------------------------------------------------------------------------

Const
   DebugMe  : Boolean = False;
   UnitName = 'UPGRADE';

   Max_Py_Lines_V53 = 50;  //version 5.3
   Max_mx_lines_V53 = 50;

type
   EUpgradeAdmin = class( Exception);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DeleteFile_RaiseException( Filename : string);
var
  ErrorCode : DWord;
begin
  if BKFileExists( Filename) then
  begin
    if not SysUtils.DeleteFile( Filename) then
    begin
      ErrorCode := Windows.GetLastError;
      raise EBKFileError.Create( 'Could not delete file ' + Filename + ' Error Code ' + inttostr( ErrorCode));
    end;

    if BKFileExists( Filename) then
      raise EBKFileError.Create( 'Could not delete file ' + Filename + ' file still exists');
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RenameFileOverwriteIfExists( Source : string; Dest : string);
//will raise exception of delete or rename failed
var
  ErrorCode : DWord;
begin
  //delete existing file
  DeleteFile_RaiseException( Dest);

  //rename file
  if not SysUtils.RenameFile( Source, Dest) then
  begin
    ErrorCode := Windows.GetLastError;
    raise EBKFileError.Create( 'Could not rename file ' + Source + ' to ' + Dest + ' Error Code ' + inttostr( ErrorCode));
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CleanUpTemporaryFiles( OriginalVersion : integer);
begin
  //LogUtil.LogMsg( lmInfo, 'CleanUpTemporaryFiles', 'CleanUpTemporaryFiles Started');
  //LogUtil.LogMsg( lmInfo, 'CleanUpTemporaryFiles', 'CleanUpTemporaryFiles Completed');
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure DoUpgradeAdminToLatestVersion( var UpgradingToVersion : integer; const OriginalVersion : integer);

   // -------------------------------------------------------------------------
   Procedure UpgradeAdminToVersion33;
   {
     This upgrade increases the length of the account code field (& related fields)
     from 10 to 20 to cater for long codes from Attache BP and Cee-Data. Because the
     master memorised transactions are stored as records these files have to be converted
     to use the new record layout.
   }
   Begin
      UpgradingToVersion := 33;
      MXUPGRADE.UpdateMasterMemorisedEntryFilesToS20;
      AdminSystem.fdFields.fdFile_Version := 33;
   end;
   // -------------------------------------------------------------------------
   procedure UpgradeAdminBefore32toVersion36;
   {
     Prior to this, the Admin System did not keep a version ID field.

     This upgrade bumps the maximum no of GST Classes up from 9 to MAX_GST and
     changes how the GST Class Codes are stored.

     The GST Class codes were stored in a delimited string from version 32 to 36
     however these we only internal versions and would cause unnecessary gst id codes
     to be added to the file. For this reason the upgrade skips that storage method
   }
   var
      i : integer;
   begin
      UpgradingToVersion := 36;
      //copy the existing gst codes into the array structure
      with AdminSystem.fdFields do begin
         if fdOld_GST_Class_Codes <> '' then begin
            //the data will be in char positions from 1 .. 9.  Put char into
            //the array position.
            for i := 1 to 9 do begin
               fdGST_Class_Codes[ i] := fdOld_GST_Class_Codes[ i];
            end;
            fdOld_GST_Class_Codes := '';
         end;
      end;
      //upgrade the account code lengths
      UpgradeAdminToVersion33;
      AdminSystem.fdFields.fdFile_Version := 36;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminAfter32ToVersion36;
   //the gst classes will have been copied into the delimiter string, so copy
   //each into the array
   //will not normally occur as version 32 - 36 were internal releases only
   var
      i : integer;
   begin
      UpgradingToVersion := 36;
      with AdminSystem.fdFields do begin
         for i := 1 to 20 do begin
            fdGST_Class_Codes[ i] := ExtractWordS( i, fdOld_GST_Class_Codes, '|');
         end;
      end;
      AdminSystem.fdFields.fdFile_Version := 36;
   end;

   procedure UpgradeAdminToVersion37;
   var
      i : integer;
      RateSpecified : boolean;
   begin
      UpgradingToVersion := 37;
      with AdminSystem.fdFields do begin
         //check rate 1 to see if any gst rates have been specified, if so then make
         //sure that an applies from date is specified
         RateSpecified := false;
         for i := 1 to MAX_GST_CLASS do begin
            if fdGST_Rates[ i, 1] <> 0 then begin
               RateSpecified := true;
               break;
            end;
         end;
         //see if rate being used
         if RateSpecified and ( fdGST_Applies_From[ 1] <= 0) then begin
            case fdCountry of
               whNewZealand : fdGST_Applies_From[ 1] := 138792;  // 01/01/80
               whAustralia  : fdGST_Applies_From[ 1] := 146279;  // 01/07/00
            end;
         end;
      end;
      AdminSystem.fdFields.fdFile_Version := 37;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion40;
   //The memorised entry definition changed in bkdefs file version 41 to add the
   //mx_GST_Has_Been_Edited flag.  This will always be set to false for master memorised entries
   begin
      UpgradingToVersion := 40;
      MXUPGRADE.UpgradeMasterMemorisedAddGSTEdited;
      AdminSystem.fdFields.fdFile_Version := 40;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion44;
   //ini setting PRAC INI Extend HDE Time Limit has been removed and replace with
   //setting in system.db
   begin
      UpgradingToVersion := 44;
      //AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts ] := PRACINI_ExtendHDETimeLimit;
      AdminSystem.fdFields.fdFile_Version := 44;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion46;
   //changed sched rep email message to ansi string so copy existing message
   begin
      UpgradingToVersion := 46;
      AdminSystem.fdFields.fdSched_Rep_Email_Message := AdminSystem.fdFields.fdOld_Sched_Rep_Email_Line1 +
                                                        AdminSystem.fdFields.fdOld_Sched_Rep_Email_Line2;

      AdminSystem.fdFields.fdOld_Sched_Rep_Email_Line1  := '';
      AdminSystem.fdFields.fdOld_Sched_Rep_Email_Line2  := '';
      AdminSystem.fdFields.fdFile_Version := 46;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion47;
   //set default bconnect method to FTP for existing installations
   //MH 5.2.0 removed this temporarily. Will be removed when FTP code is removed
   begin
      {
      PRACINI_Use_FTP_BConnect := true;
      ForcePracIniUpdate       := true;
      }
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion48;
   //The memorised entry definition changed in bkdefs file version 41 to add the
   //mx_GST_Has_Been_Edited flag.  This will always be set to false for master memorised entries
   begin
      UpgradingToVersion := 48;
      MXUPGRADE.UpgradeMasterMemorisedAddNotes;
      AdminSystem.fdFields.fdFile_Version := 48;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion49;
   //filename format has changed for master mem files to accomidate alpha accounts
   begin
      UpgradingToVersion := 49;
      MXUPGRADE.RenameMasterMemorisedFiles;
      AdminSystem.fdFields.fdFile_Version := 49;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion50;
   begin
      UpgradingToVersion := 50;
      MXUpgrade.UpgradeMasterMemorisedTo50Lines;
      AdminSystem.fdFields.fdFile_Version := 50;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion52;
   begin
      UpgradingToVersion := 52;
      MXUpgrade.UpgradeMasterMemorisedToIncludeNarration;
      AdminSystem.fdFields.fdFile_Version := 52;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion53;
   //fake the was on last disk flag so summarised download report works
   var
     LastDate : integer;
     dl       : pSystem_Disk_Log_Rec;
     i        : integer;
   begin
     UpgradingToVersion := 53;
     LastDate := 0;
     for i := AdminSystem.fdSystem_Disk_Log.Last downto AdminSystem.fdSystem_Disk_Log.First do begin
       dl := AdminSystem.fdSystem_Disk_Log.Disk_Log_At(i);
       if (LastDate = 0) then
         LastDate := dl^.dlDate_Downloaded;

       dl^.dlWas_In_Last_Download := ( dl^.dlDate_Downloaded = LastDate);
     end;
     AdminSystem.fdFields.fdFile_Version := 53;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion54;
   const
     uaBuffSize = 8192;
   var
     i : integer;
     OriginalFileName : string;
     NewFilename      : string;
     Shortname        : string;

     OldFile : TbfsBufferedFileStream;
     NewFile : TbfsBufferedFileStream;
     sb      : pSystem_Bank_Account_Rec;

     OldArchRec : tV53_Archived_Transaction;
     NewArchRec : tV54_Archived_Transaction;
     NumRead    : integer;
   begin
     UpgradingToVersion := 54;
     Progress.UpdateAppStatus( 'Upgrading Transaction Archive','Please wait', 0 , ProcessMessages_On);

     for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
     begin
       sb := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At( i);
       Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Bank_Account_List.ItemCount * 100), True);
       if sb.sbLast_Transaction_LRN > 0 then
       begin
         try
           OriginalFileName := ArchUtil32.ArchiveFileName( sb.sbLRN);
           Shortname        := ExtractFilename( OriginalFilename);
           if BKFileExists( OriginalFilename) then
           begin
             Progress.UpdateAppStatusLine2( 'Upgrading file ' + Shortname, ProcessMessages_On);
             if DebugMe then
               LogMsg( lmDebug, Unitname, 'Upgrading ' + OriginalFilename);

             NewFilename      := ExtractFilePath( OriginalFilename) + 'newtxn.tmp';
             DeleteFile_RaiseException( NewFilename);

             //open the old file.
             OldFile := TbfsBufferedFileStream.Create( OriginalFilename, fmOpenRead, uaBuffSize);
             try
               NewFile := TbfsBufferedFileStream.Create( NewFilename, fmCreate, uaBuffSize);
               try
                 repeat
                   NumRead := OldFile.Read( OldArchRec, SizeOf( tV53_Archived_Transaction));
                   if NumRead > 0 then
                   begin
                     if NumRead <> SizeOf( tV53_Archived_Transaction) then
                       raise Exception.Create( 'Stream Read error reading ' + OriginalFilename);

                     FillChar( NewArchRec, Sizeof( NewArchRec ), 0 );
                     with OldArchRec, NewArchRec do
                     begin
                       aV54_LRN                 := aV53_LRN;
                       aV54_Type                := aV53_Type;
                       aV54_Source              := aV53_Source;
                       aV54_Date_Presented      := aV53_Date_Presented;
                       aV54_Date_Transferred    := aV53_Date_Transferred;
                       aV54_Amount              := aV53_Amount;
                       aV54_Quantity            := aV53_Quantity;
                       aV54_Cheque_Number       := aV53_Cheque_Number;
                       aV54_Reference           := aV53_Reference;
                       aV54_Particulars         := aV53_Particulars;
                       aV54_Analysis            := aV53_Analysis;
                       aV54_OrigBB              := aV53_OrigBB;
                       aV54_Other_Party         := aV53_Other_Party;
                       aV54_Narration           := '';
                       if AdminSystem.fdFields.fdCountry = whNewZealand then begin
                         //new zealand systems need to have a statement details column
                         //construct this from the other party and particulars fields
                         aV54_Statement_Details  := MakeStatementDetails( sb.sbAccount_Number,
                                                      aV53_Other_Party, aV53_Particulars);
                       end
                       else begin
                         //australian systems will already have a narration, just move
                         //it to the new statement details field
                         aV54_Statement_Details   := aV53_Narration;
                       end;
                       aV54_Unique_ID           := 0;
                       //aV54_Spare               :=
                       aV54_Record_End_Marker   := ARCHIVE_REC_END_MARKER;
                     end;
                     //write out new record
                     NewFile.WriteBuffer( NewArchRec, SizeOf( tV54_Archived_Transaction));
                   end;
                 until NumRead = 0;
                 //ensure buffer is written to disk
                 NewFile.Commit;
               finally
                 NewFile.Free;
               end;
             finally
               OldFile.Free;
             end;
             //now rename temp file to new file
             if DebugMe then
               LogMsg( lmDebug, Unitname, 'Renaming ' + NewFilename + ' to ' + OriginalFilename);
             RenameFileOverwriteIfExists( NewFilename, OriginalFilename);
           end
           else
           begin
             //the trx file is missing, see if we are validating the archive
             if PRACINI_ValidateArchive then
               raise EUpgradeAdmin.Create( 'Transaction file ' + OriginalFilename + ' is missing!');
           end;
         except
           //re raise any exceptions so that we know which file we were working on
           On E : Exception do
           begin
             raise EUpgradeAdmin.Create( 'Error upgrading ' + OriginalFilename +
                                     ' ' + E.Message + ' ' + E.Classname);
           end;
         end;
       end;
     end;
     //upgrade ok
     AdminSystem.fdFields.fdFile_Version := 54;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion55;
   //need to set the tax interface settings
   begin
     UpgradingToVersion := 55;

     if AdminSystem.fdFields.fdCountry = whAustralia then
     begin
       if AdminSystem.fdFields.fdAccounting_System_Used in [ saSolution6MAS42, saSolution6CLS3,
                                                      saSolution6CLS4,  saSolution6MAS41,
                                                      saSolution6CLSY2K ] then
       begin
         AdminSystem.fdFields.fdTax_Interface_Used := BKCONST.tsBAS_Sol6ELS;
         AdminSystem.fdFields.fdSave_Tax_Files_To  := 'ELS\';
       end
       else
       begin
         AdminSystem.fdFields.fdTax_Interface_Used := BKCONST.tsBAS_XML;
         AdminSystem.fdFields.fdSave_Tax_Files_To  := 'XML\';
       end;
     end;

     //upgrade ok
     AdminSystem.fdFields.fdFile_Version := 55;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion60;
   begin
      UpgradingToVersion := 60;

      //Added Scheduled Reports Header and BNotes messages
      AdminSystem.fdFields.fdSched_Rep_Header_Message := AdminSystem.fdFields.fdSched_Rep_Cover_Page_Message;
      AdminSystem.fdFields.fdSched_Rep_BNotes_Subject := AdminSystem.fdFields.fdSched_Rep_Email_Subject;
      AdminSystem.fdFields.fdSched_Rep_BNotes_Message := AdminSystem.fdFields.fdSched_Rep_Email_Message;
      //upgrade ok
      AdminSystem.fdFields.fdFile_Version := 60;
   end;

   procedure UpgradeAdminToVersion63;
   var
      i : integer;
      pCF : pClient_File_Rec;
      aClient : TClientObj;
   begin
      //update the cached admin data for all client files
      UpgradingToVersion := 63;

      aClient := nil;

      for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
      begin
         pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i);

         Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Client_File_List.ItemCount * 100));
         Progress.UpdateAppStatusLine2( 'Caching details for ' + pCF^.cfFile_Code, ProcessMessages_On);
         try
            OpenAClientForRead( pCF^.cfFile_Code, aClient);
            try
              if Assigned( aClient) then
              begin
                 aClient.clFields.clContact_Details_Edit_Date := -1;
                 Merge32.RefreshContactDetails( aClient, pCF, syncDir_ClientToAdmin);
                 Merge32.SyncAdminToClient( pCF, aClient);
              end
              else
                 LogMsg( lmError, UnitName ,'Could not update cached Details for ' + pCF^.cfFile_Code);
            finally
              FreeAndNil( aClient);
            end;
         except
           on E : Exception do
             raise EUpgradeAdmin.Create( 'Error caching details for ' + pCF^.cfFile_Code +
                                      ' ' + E.Message + ' ' + E.Classname);
         end;
      end;

      //upgrade ok
      AdminSystem.fdFields.fdFile_Version := 63;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion66;
   begin
      UpgradingToVersion := 66;
      MXUpgrade.UpgradeMasterMemorisedToIncludeLineType;

      AdminSystem.fdFields.fdTask_Tracking_Prompt_Type := ttNeverPrompt;
      AdminSystem.fdFields.fdFile_Version := 66;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion69;
   {
     There was a problem with the BuildMasterMemFilesList() function used in
     5.4.0.338/341 that meant it only upgraded '*.mxl' files and would miss
     '.MXL' files.

     The routine now reads the header of the file to look for

    }
   var
    IsAReupgrade : boolean;
   begin
      IsAReupgrade := ( OriginalVersion = 68);

      UpgradingToVersion := 69;
      MXUpgrade.UpgradeMasterMemorisedFileFormat( IsAReupgrade);
      AdminSystem.fdFields.fdFile_Version := 69;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion70;
   begin
      //set the fax transport to winfax if reports have been sent via fax
      if AdminSystem.fdFields.fdSched_Rep_Include_Fax then
       AdminSystem.fdFields.fdSched_Rep_Fax_Transport := fxtWinFax;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion72;
   begin
      //set the default web export to Acclipse
      UpgradingToVersion := 72;
      AdminSystem.fdFields.fdWeb_Export_Format := 255;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion73;
   begin
      UpgradingToVersion := 73;
      // Transaction type 19 changes
      if AdminSystem.fdFields.fdCountry = whNewZealand then
      begin
         AdminSystem.fdFields.fdShort_Name[19] := 'O/D Fee';
         AdminSystem.fdFields.fdLong_Name[19] := 'Overdraft Fee';
      end;
      // CSV Export in SR switched off
     AdminSystem.fdFields.fdBulk_Export_Enabled := False;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion74;
   begin
      UpgradingToVersion := 74;
      // Move ini settings to db
      AdminSystem.fdFields.fdForce_Login := PRACINI_ForceLogin;
      AdminSystem.fdFields.fdLogin_Bitmap_Filename := PRACINI_CustomBitmapFilename;
      AdminSystem.fdFields.fdAuto_Print_Sched_Rep_Summary := PRACINI_AutoPrintSchdRepSummary;
      AdminSystem.fdFields.fdIgnore_Quantity_In_Download := PRACINI_IgnoreQtyInDownload;
      // These stay in ini for support for offsites
      AdminSystem.fdFields.fdCopy_Dissection_Narration := PRACINI_CopyNarrationDissection;
      AdminSystem.fdFields.fdRound_Cashflow_Reports := PRACINI_RoundCashFlowReports;
      AdminSystem.fdFields.fdUse_Xlon_Chart_Order := PRACINI_UseXLonChartOrder;
      AdminSystem.fdFields.fdExtract_Multiple_Accounts_PA := PRACINI_ExtractMultipleAccountsToPA;
      AdminSystem.fdFields.fdExtract_Journal_Accounts_PA := PRACINI_ExtractJournalsAsPAJournals;
      AdminSystem.fdFields.fdExtract_Quantity := PRACINI_ExtractQuantity;
      AdminSystem.fdFields.fdReports_New_Page := PRACINI_Reports_NewPage;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion75;
   begin
      UpgradingToVersion := 75;
      Adminsystem.fdFields.fdMaximum_Narration_Extract := 200;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion76;
   var
      i: Integer;
      TempClient: TClientObj;
      pF: pClient_File_Rec;
   begin
      // Build client account map
      UpgradingToVersion := 76;
      with AdminSystem do
         for i := 0 to Pred(fdSystem_Client_File_List.ItemCount) do
         begin
            pF := fdSystem_Client_File_List.Client_File_At(i);
            Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Client_File_List.ItemCount * 100));
            Progress.UpdateAppStatusLine2( 'Building client account map for ' + pF^.cfFile_Code, ProcessMessages_On);
            OpenAClientForRead( pF^.cfFile_Code, TempClient ); // triggers upgrade to file version 104!
            TempClient.Free;
            TempClient := nil;
         end;
   end;

   // -------------------------------------------------------------------------

   procedure UpgradeAdminToVersion77;
   begin
      // will encrypt DB on save
      UpgradingToVersion := 77;
   end;

   // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion80;
    var
       PrefixList: TStringList;
       i, j, k: Integer;
       sba: pSystem_Bank_Account_Rec;
       Prefix: BankPrefixStr;
       MemList: TMaster_Memorisations_List;
       Mem: TMemorisation;
       Line: pMemorisation_Line_Rec;
    begin
       UpgradingToVersion := 80;
       PrefixList := TStringList.Create;
       try
         for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
         begin
            sba := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
            Prefix := mxFiles32.GetBankPrefix(sba.sbAccount_Number);
            if PrefixList.IndexOf(Prefix) = -1 then
               PrefixList.Add(Prefix);
         end;
         for i := 0 to Pred(PrefixList.Count) do
         begin
            Master_Mem_Lists_Collection.ReloadSystemMXList(PrefixList[i]);
            MemList := Master_Mem_Lists_Collection.FindPrefix(PrefixList[i]);
            if Assigned(MemList) then
            begin
               for j := MemList.First to MemList.Last do
               begin
                  Mem := MemList.Memorisation_At(j);
                  if Mem.mdFields.mdPayee_Number = 0 then
                     Continue;
                  for k := Mem.mdLines.First to Mem.mdLines.Last do
                  begin
                     Line := Mem.mdLines.MemorisationLine_At(k);
                     Line.mlPayee := Mem.mdFields.mdPayee_Number;
                  end;
                  Mem.mdFields.mdPayee_Number := 0;
               end;
               MemList.SaveToFile;
            end;
         end;
       finally
          PrefixList.Free;
       end;
    end;

    // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion82;
    begin
       // Switch on usage collection by default
       UpgradingToVersion := 82;
       AdminSystem.fdFields.fdCollect_Usage_Data := true;
       if (AdminSystem.fdFields.fdCountry = whAustralia)
       and (AdminSystem.fdFields.fdWeb_Export_Format <> wfWebX) then
          AdminSystem.fdFields.fdWeb_Export_Format := 255
       else
          if (AdminSystem.fdFields.fdCountry = whAustralia)
          and (PRACINI_ShowAcclipseInOz) then
             AdminSystem.fdFields.fdWeb_Export_Format := wfWebX;
    end;

    // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion85;
    begin
       // set qty to extract
       UpgradingToVersion := 85;
       AdminSystem.fdFields.fdExtract_Quantity_Decimal_Places := 4;
    end;

    // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion86;
    var
       i: Integer;
       pCF : pClient_File_Rec;
    begin
       // copy sched rep method to filtering
       UpgradingToVersion := 86;

       for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
       begin
          pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i);
          pCF.cfSchd_Rep_Method_Filter := pCF.cfSchd_Rep_Method;
       end;
    end;

    // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion87;
    const
       uaBuffSize = 8192;
    var
       i, j, k, NumRead: Integer;
       PrefixList: TStringList;
       sba: pSystem_Bank_Account_Rec;
       Prefix: BankPrefixStr;
       MemList: TMaster_Memorisations_List;
       Mem: TMemorisation;
       Line: pMemorisation_Line_Rec;
       OriginalFileName, ShortName, NewFilename: string;
       OldFile : TbfsBufferedFileStream;
       NewFile : TbfsBufferedFileStream;
       OldArchRec : tV169_Archived_Transaction;
       NewArchRec : tV169_Archived_Transaction;
    begin
       // upgrade to 4 decimal places
       UpgradingToVersion := 87;

       // GST Rates
       For i := 1 to MAX_GST_CLASS do
       begin
          For j := 1 to MAX_VISIBLE_GST_CLASS_RATES do
             AdminSystem.fdFields.fdGST_Rates[ i, j ] := AdminSystem.fdFields.fdGST_Rates[ i, j ] * 100;
       end;

       // Master Mems and Archive upgrade
       PrefixList := TStringList.Create;
       try
          Progress.UpdateAppStatus( 'Updating Transaction Archive','Please wait', 0 , ProcessMessages_On);
          for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
          begin
             sba := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
             Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Bank_Account_List.ItemCount * 100), True);
             if sba.sbLast_Transaction_LRN > 0 then
             begin
                try
                   OriginalFileName := ArchUtil32.ArchiveFileName( sba.sbLRN);
                   Shortname        := ExtractFilename( OriginalFilename);
                   if BKFileExists( OriginalFilename) then
                   begin
                     Progress.UpdateAppStatusLine2( 'Updating file ' + Shortname, ProcessMessages_On);
                     if DebugMe then
                        LogMsg( lmDebug, Unitname, 'Updating ' + OriginalFilename);
                     NewFilename      := ExtractFilePath( OriginalFilename) + 'newtxn.tmp';
                     DeleteFile_RaiseException( NewFilename);
                     //open the old file.
                     OldFile := TbfsBufferedFileStream.Create( OriginalFilename, fmOpenRead, uaBuffSize);
                     try
                        NewFile := TbfsBufferedFileStream.Create( NewFilename, fmCreate, uaBuffSize);
                        try
                           repeat
                              NumRead := OldFile.Read( OldArchRec, SizeOf( tV169_Archived_Transaction));
                              if NumRead > 0 then
                                 begin
                                    if NumRead <> SizeOf( tV169_Archived_Transaction) then
                                       raise Exception.Create( 'Stream Read error reading ' + OriginalFilename);

                                    FillChar( NewArchRec, Sizeof( NewArchRec ), 0 );
                                    NewArchRec.tV169_aLRN                 := OldArchRec.tV169_aLRN;
                                    NewArchRec.tV169_aType                := OldArchRec.tV169_aType;
                                    NewArchRec.tV169_aSource              := OldArchRec.tV169_aSource;
                                    NewArchRec.tV169_aDate_Presented      := OldArchRec.tV169_aDate_Presented;
                                    NewArchRec.tV169_aDate_Transferred    := OldArchRec.tV169_aDate_Transferred;
                                    NewArchRec.tV169_aAmount              := OldArchRec.tV169_aAmount;
                                    NewArchRec.tV169_aQuantity            := OldArchRec.tV169_aQuantity * 10;
                                    NewArchRec.tV169_aCheque_Number       := OldArchRec.tV169_aCheque_Number;
                                    NewArchRec.tV169_aReference           := OldArchRec.tV169_aReference;
                                    NewArchRec.tV169_aParticulars         := OldArchRec.tV169_aParticulars;
                                    NewArchRec.tV169_aAnalysis            := OldArchRec.tV169_aAnalysis;
                                    NewArchRec.tV169_aOrigBB              := OldArchRec.tV169_aOrigBB;
                                    NewArchRec.tV169_aOther_Party         := OldArchRec.tV169_aOther_Party;
                                    NewArchRec.tV169_aNarration           := OldArchRec.tV169_aNarration;
                                    NewArchRec.tV169_aStatement_Details   := OldArchRec.tV169_aStatement_Details;
                                    NewArchRec.tV169_aUnique_ID           := OldArchRec.tV169_aUnique_ID;
                                    NewArchRec.tV169_aSpare               := OldArchRec.tV169_aSpare;
                                    NewArchRec.tV169_aRecord_End_Marker   := OldArchRec.tV169_aRecord_End_Marker;
                                    NewFile.WriteBuffer( NewArchRec, SizeOf( tV169_Archived_Transaction));
                                 end; // if NumRead > 0
                           until NumRead = 0;
                           //ensure buffer is written to disk
                           NewFile.Commit;
                        finally
                           NewFile.Free;
                        end;
                     finally
                        OldFile.Free;
                     end;
                     //now rename temp file to new file
                     if DebugMe then
                        LogMsg( lmDebug, Unitname, 'Renaming ' + NewFilename + ' to ' + OriginalFilename);
                     RenameFileOverwriteIfExists( NewFilename, OriginalFilename);
                   end; // if bkfileexists
                except on E : Exception do
                   //re raise any exceptions so that we know which file we were working on
                   raise EUpgradeAdmin.Create( 'Error Updating ' + OriginalFilename + ' ' + E.Message + ' ' + E.Classname);
                end;
             end; // if lrn > 0
             Prefix := mxFiles32.GetBankPrefix(sba.sbAccount_Number);
             if PrefixList.IndexOf(Prefix) = -1 then
                PrefixList.Add(Prefix);
          end; // for

          // Master Mems
          for i := 0 to Pred(PrefixList.Count) do
          begin
             Master_Mem_Lists_Collection.ReloadSystemMXList(PrefixList[i]);
             MemList := Master_Mem_Lists_Collection.FindPrefix(PrefixList[i]);
             if Assigned(MemList) then
             begin
                for j := MemList.First to MemList.Last do
                begin
                   Mem := MemList.Memorisation_At(j);
                   for k := Mem.mdLines.First to Mem.mdLines.Last do
                   begin
                      Line := Mem.mdLines.MemorisationLine_At(k);
                      if Line.mlLine_Type = mltPercentage then
                         Line.mlPercentage := Line.mlPercentage * 100;
                   end;
                end;
                MemList.SaveToFile;
             end;
          end;
       finally
          PrefixList.Free;
       end;
    end;

    // -------------------------------------------------------------------------

    procedure UpgradeAdminToVersion90;
    const
       uaBuffSize = 8192;
    var
       i, NumRead, LastLRN : Integer;
       sba: pSystem_Bank_Account_Rec;
       OriginalFileName, ShortName, NewFilename: string;
       OldFile : TbfsBufferedFileStream;
       NewFile : TbfsBufferedFileStream;
       OldArchRec : tV169_Archived_Transaction;
       NewArchRec : tV169_Archived_Transaction;
       FErrors: Boolean;
    begin
       // #7218 - fix for archive duplication bug
       UpgradingToVersion := 90;
       FErrors := False;
       LastLRN := -999;
       Progress.UpdateAppStatus( 'Updating Transaction Archive','Please wait', 0 , ProcessMessages_On);
    for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
    begin
      sba := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
      Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Bank_Account_List.ItemCount * 100), True);
      if sba.sbLast_Transaction_LRN > 0 then
      begin
        try
          OriginalFileName := ArchUtil32.ArchiveFileName( sba.sbLRN);
          Shortname        := ExtractFilename( OriginalFilename);
          if BKFileExists( OriginalFilename) then
          begin
            Progress.UpdateAppStatusLine2( 'Updating file ' + Shortname, ProcessMessages_On);
            NewFilename      := ExtractFilePath( OriginalFilename) + 'newtxn.tmp';
            DeleteFile_RaiseException( NewFilename);
            //open the old file.
            OldFile := TbfsBufferedFileStream.Create( OriginalFilename, fmOpenRead, uaBuffSize);
            try
              NewFile := TbfsBufferedFileStream.Create( NewFilename, fmCreate, uaBuffSize);
              try
                repeat
                  NumRead := OldFile.Read( OldArchRec, SizeOf( tV169_Archived_Transaction));
                  if NumRead > 0 then
                  begin
                    if NumRead <> SizeOf( tV169_Archived_Transaction) then
                      raise Exception.Create( 'Stream Read error reading ' + OriginalFilename);

                    if LastLRN = OldArchRec.tV169_aLRN then
                      FErrors := True
                    else
                    begin
                      LastLRN := OldArchRec.tV169_aLRN;
                      FillChar( NewArchRec, Sizeof( NewArchRec ), 0 );
                      NewArchRec.tV169_aLRN                 := OldArchRec.tV169_aLRN;
                      NewArchRec.tV169_aType                := OldArchRec.tV169_aType;
                      NewArchRec.tV169_aSource              := OldArchRec.tV169_aSource;
                      NewArchRec.tV169_aDate_Presented      := OldArchRec.tV169_aDate_Presented;
                      NewArchRec.tV169_aDate_Transferred    := OldArchRec.tV169_aDate_Transferred;
                      NewArchRec.tV169_aAmount              := OldArchRec.tV169_aAmount;
                      NewArchRec.tV169_aQuantity            := OldArchRec.tV169_aQuantity * 10;
                      NewArchRec.tV169_aCheque_Number       := OldArchRec.tV169_aCheque_Number;
                      NewArchRec.tV169_aReference           := OldArchRec.tV169_aReference;
                      NewArchRec.tV169_aParticulars         := OldArchRec.tV169_aParticulars;
                      NewArchRec.tV169_aAnalysis            := OldArchRec.tV169_aAnalysis;
                      NewArchRec.tV169_aOrigBB              := OldArchRec.tV169_aOrigBB;
                      NewArchRec.tV169_aOther_Party         := OldArchRec.tV169_aOther_Party;
                      NewArchRec.tV169_aNarration           := OldArchRec.tV169_aNarration;
                      NewArchRec.tV169_aStatement_Details   := OldArchRec.tV169_aStatement_Details;
                      NewArchRec.tV169_aUnique_ID           := OldArchRec.tV169_aUnique_ID;
                      NewArchRec.tV169_aSpare               := OldArchRec.tV169_aSpare;
                      NewArchRec.tV169_aRecord_End_Marker   := OldArchRec.tV169_aRecord_End_Marker;
                      NewFile.WriteBuffer( NewArchRec, SizeOf( tV169_Archived_Transaction));
                    end;
                  end; // if NumRead > 0
                until NumRead = 0;
                //ensure buffer is written to disk
                NewFile.Commit;
              finally
                NewFile.Free;
              end;
            finally
              OldFile.Free;
            end;
            //now rename temp file to new file
            RenameFileOverwriteIfExists( NewFilename, OriginalFilename);
          end; // if bkfileexists
        except on E : Exception do
          //re raise any exceptions so that we know which file we were working on
          raise EUpgradeAdmin.Create( 'Error upgrading ' + OriginalFilename + ' ' + E.Message + ' ' + E.Classname);
        end;
      end; // if lrn > 0
    end; // for

    if FErrors then
      LogUtil.LogMsg(lmDebug,UnitName,'UpgradeAdminToVersion90 Fixed Archive' )
    else
      LogUtil.LogMsg(lmDebug,UnitName,'UpgradeAdminToVersion90 No Archive Problems' )
  end;

  // Build in bkmap
  procedure UpgradeAdminToVersion98;
    // Add an entry to the client-account map if its not already there
    // Returns TRUE if changes were made
    function AddToMap(ClientLRN, AccountLRN: Integer): Boolean;
    var
      pM: pClient_Account_Map_Rec;
    begin
      Result := False;
      if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(AccountLRN, ClientLRN)) then
      begin
        pM := New_Client_Account_Map_Rec;
        if Assigned(pM) then
        begin
          pM.amClient_LRN := ClientLRN;
          pM.amAccount_LRN := AccountLRN;
          //pM.amLast_Date_Printed := 0;
          pM.amLast_Date_Printed := IncDate(GetFirstDayOfMonth(CurrentDate), -1, 0, 0);
          AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
          Result := True;
        end;
      end;
    end;

    // Read the bank accounts of each client file, if the bank account exists in the
    // admin system then make sure there is a client account map entry for it
    procedure CheckClientFile(Code: string; LRN: Integer);
    var
      i: Integer;
      ac: string;
      Client: TClientObj;
      pS: pSystem_Bank_Account_Rec;
    begin
      OpenAClientForRead(Code, Client);
      try
        if Assigned(Client) then
        begin
          for i := 0 to Pred(Client.clBank_Account_List.ItemCount) do
          begin
            // Is account in admin system?
            ac := Client.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number;
            pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(ac);
            if Assigned(pS) then // Yes - add to map if not there already
            begin
              if AddToMap(LRN, pS.sbLRN) then
              begin
                pS.sbAttach_Required := False;
                LogUtil.LogMsg(lmDebug,UnitName,Code + '" had account number "' + ac + '" missing -> added');
              end;
            end;
          end;
        end;
      finally
        Client.Free;
        Client := nil;
      end;
    end;

  var
    i: Integer;
    pF: pClient_File_Rec;
    pM: pClient_Account_Map_Rec;
    pS: pSystem_Bank_Account_Rec;
    pC: pClient_File_Rec;
  begin  //UpgradeAdminToVersion98;
    // Look thru each client file in the admin system, make sure there is a
    // client-account map entry for every attached bank account as long as the bank
    // account is in the admin system
    UpgradingToVersion := 98;
    Progress.UpdateAppStatus( 'Updating Account Map','Please wait', 0 , ProcessMessages_On);
    for i := 0 to Pred(AdminSystem.fdSystem_Client_File_List.ItemCount) do
    begin
      Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Client_File_List.ItemCount * 100), True);
      pF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
      CheckClientFile(pF.cfFile_Code, pF.cfLRN);
    end;

    // Read through each client account map entry and remove entries that have an
    // a client LRN that no longer exists in the admin system
    i := 0;
    while i < AdminSystem.fdSystem_Client_Account_Map.ItemCount do
    begin
      pM := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
      pS := AdminSystem.fdSystem_Bank_Account_List.FindLRN(pM.amAccount_LRN);
      pC := AdminSystem.fdSystem_Client_File_List.FindLRN(pM.amClient_LRN);
      if not Assigned(pS) then // map record exists for non-existant account
      begin
        AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
        LogUtil.LogMsg(lmDebug,UnitName,'Client LRN "' + IntToStr(pM.amClient_LRN) + '" and account LRN "' + IntToStr(pM.amClient_LRN) + '" orphaned -> deleted');
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pM.amAccount_LRN)) then
        begin
          pS.sbAttach_Required := True;
          LogUtil.LogMsg(lmDebug,UnitName,'Account LRN "' + IntToStr(pM.amAccount_LRN) + '" orphaned -> unattached');
        end;
      end
      else if not Assigned(pC) then // map record exists for non-existant client
      begin
        AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
        LogUtil.LogMsg(lmDebug,UnitName,'Client LRN "' + IntToStr(pM.amClient_LRN) + '" and account number "' + pS.sbAccount_Number + '" orphaned -> deleted');
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pS.sbLRN)) then
        begin
          pS.sbAttach_Required := True;
          LogUtil.LogMsg(lmDebug,UnitName,'Account number "' + pS.sbAccount_Number + '" orphaned -> unattached');
        end;
      end
      else
        Inc(i);
    end;
  end;



  procedure UpgradeAdminToVersion96;
  begin
     UpgradingToVersion := 96;
     // Add the default Client Types to the Database.
     AddClientTypes(AdminSystem);
  end;

  procedure UpgradeAdminToVersion97;
  // Move Headers and Footers to external file..
  var
     RptHeaderFooters : array [TReportType] of TReportTypeParams;
     i: Integer;
     FI: TFooterItems;
  const
     DefaultFontString = '"Arial","",9';

  procedure getfont (FromText: string; Font: TFont);
     begin
       if FromText = '' then
          StrToFont(DefaultFontString,Font)
       else
          StrToFont(FromText,Font);
     end;

  procedure SaveReportTypes;
  var Document : IXMLDocument;
      bn: IXMLNode;
      i: integer;
  begin
      Document := CreateXMLDoc;
      try
         Document.Text := '';
         bn := EnsureNode(Document, 'ReportTypes');
         SetNodeText(bn,'Version','1');
         for I := ord(low(TReportType)) to ord(High(TReportType)) do
            RPTHeaderFooters[TReportType(I)].SavetoNode(EnsureNode(bn,ReportTypenames[TReportType(I)]));
         Document.Save(ReportTypesFilename,ofIndent);
      finally
        Document := nil;
      end;
  end;

  begin with AdminSystem.fdFields do begin //UpgradeAdminToVersion97
     UpgradingToVersion := 97;

     //Build the default footer
     case fdSpare_Byte_11 of // Date Time in footer
     0 : FI := [fiPrinted , FITime];
     1 : FI := [fiPrinted]
     else FI := [];
     end;
     FI := FI + [fiClientCode, fiPageNumbers]; // Where always on.

     for I := ord(low(TReportType)) to ord(High(TReportType)) do begin
        RPTHeaderFooters[TReportType(I)] := TReportTypeParams.Create;
        with RPTHeaderFooters[TReportType(I)] do begin
           FooterItems := FI;
           RoundValues := Globals.PRACINI_RoundCashFlowReports;
           NewPageforAccounts := Globals.PRACINI_Reports_NewPage;
        end;
     end;

     with RptHeaderFooters [rptFinancial] do begin
       //Header Logo
       //Note: fdSpare_Text_1 and fdSpare_Byte_1 have been repurposed for
       //printing a custom doc header page
       H_LogoFile := fdSched_Rep_Print_Custom_Doc_GUID;             fdSched_Rep_Print_Custom_Doc_GUID := '';
       H_LogoFileAlignment := TAlignment(fdSched_Rep_Print_Custom_Doc); fdSched_Rep_Print_Custom_Doc := 0;

       H_LogoFileWidth := fdLast_ChargeFile_Date;         fdLast_ChargeFile_Date  := 0; //Has been re-used
       H_LogoFileHeight := fdAudit_Record_ID;             fdAudit_Record_ID := 0;
       //Header Title
       H_Title := fdSched_Rep_fax_Custom_Doc_GUID;        fdSched_Rep_fax_Custom_Doc_GUID := '';
       H_TitleAlignment := TAlignment(fdSched_Rep_Fax_Custom_Doc);    fdSched_Rep_Fax_Custom_Doc := 0;
       GetFont(fdSpare_Text_3,H_TitleFont);
       //Header Text
       H_Text := fdSched_Rep_Email_Custom_Doc_GUID;       fdSched_Rep_Email_Custom_Doc_GUID := ''; //Has been re-used
       H_TextAlignment := TAlignment(fdSched_Rep_Email_Custom_Doc);   fdSched_Rep_Email_Custom_Doc := 0; //Has been re-used
       GetFont(fdSpare_Text_5,H_TextFont);                fdSpare_Text_5 := '';
       //Footer Logo
       F_LogoFile := fdSched_Rep_Books_Custom_Doc_GUID;   fdSched_Rep_Books_Custom_Doc_GUID := ''; //Has been re-used
       F_LogoFileAlignment := TAlignment(fdSched_Rep_Books_Custom_Doc); fdSched_Rep_Books_Custom_Doc := 0; //Has been re-used
       F_LogoFileWidth := fdSpare_Integer_3;              fdSpare_Integer_3 := 0;
       F_LogoFileHeight := fdSpare_Integer_4;             fdSpare_Integer_4 := 0;
       //Header Text
       F_Text := fdSched_Rep_Notes_Custom_Doc_GUID;       fdSched_Rep_Notes_Custom_Doc_GUID := ''; //Has been re-used
       F_TextAlignment := TAlignment(fdSched_Rep_Notes_Custom_Doc);     fdSched_Rep_Notes_Custom_Doc := 0 ;//Has been re-used
       GetFont(fdSpare_Text_8,F_TextFont);                fdSpare_Text_8 := '';
       HF_Enabled := fdSpare_Bool_1;                      fdSpare_Bool_1 := False;
    end;
    with RptHeaderFooters [rptCoding] do begin
       //Header Logo
       H_LogoFile := fdSched_Rep_WebNotes_Custom_Doc_GUID;  fdSched_Rep_WebNotes_Custom_Doc_GUID := ''; //Has been re-used
       H_LogoFileAlignment := TAlignment(fdSched_Rep_WebNotes_Custom_Doc); fdSched_Rep_WebNotes_Custom_Doc := 0; //Has been re-used
       H_LogoFileWidth := fdSpare_Integer_5;              fdSpare_Integer_5 := 0;
       H_LogoFileHeight := fdSpare_Integer_6;             fdSpare_Integer_6 := 0;
       //Header Title
       H_Title := fdSpare_Text_10;                        fdSpare_Text_10 := '';
       H_TitleAlignment := TAlignment(fdSpare_Byte_7);    fdSpare_Byte_7 := 0;
       GetFont(fdSpare_Text_11,H_TitleFont);              fdSpare_Text_11 := '';
       //Header Text
       H_Text := fdSpare_Text_12;                         fdSpare_Text_12 := '';
       H_TextAlignment := TAlignment(fdSpare_Byte_8);     fdSpare_Byte_8 := 0;
       GetFont(fdSpare_Text_13,H_TextFont);               fdSpare_Text_13 := '';
       //Footer Logo
//       F_LogoFile := fdSpare_Text_14;                     fdSpare_Text_14 := ''; //Reused as fdBankLink_Online_Config
       F_LogoFile := fdBankLink_Online_Config;            fdBankLink_Online_Config := '';
       F_LogoFileAlignment := TAlignment(fdSpare_Byte_9); fdSpare_Byte_9 := 0;
       F_LogoFileWidth := fdSpare_Integer_7;              fdSpare_Integer_7 := 0;
       F_LogoFileHeight := fdSpare_Integer_8;             fdSpare_Integer_8 := 0;
       //Footer Text
       F_Text := fdSched_Rep_WebNotes_Subject;            fdSched_Rep_WebNotes_Subject := ''; //Has been re-used;
       F_TextAlignment := TAlignment(fdSpare_Byte_10);    fdSpare_Byte_10 := 0;
       GetFont(fdSched_Rep_webNotes_Message,F_TextFont);  fdSched_Rep_webNotes_Message := ''; //Has been re-used;
       HF_Enabled := fdSpare_Bool_2;                      fdSpare_Bool_2 := false;
    end;
    SaveReportTypes;

    for I := ord(low(TReportType)) to ord(High(TReportType)) do
      RptHeaderFooters[TReportType(I)].Free;

  end;end;

  procedure UpgradeAdminToVersion100;
  begin
     UpgradingToVersion := 100;
     AdminSystem.fdFields.fdCollect_Usage_Data := true;

     if Pos('19.0715',PRACINI_FuelCreditRates) = 0 then begin
        PRACINI_FuelCreditRates := PRACINI_FuelCreditRates + ',19.0715';
        WritePracticeINI_WithLock;
     end;
     with AdminSystem.fdFields do if fdCountry = whAustralia then begin
        fdTAX_Applies_From[tt_CompanyTax][1] := 146644; //01/07/2001
        fdTAX_Rates[tt_CompanyTax][1] := Double2GSTRate( 30.0);
     end;
  end;

  procedure UpgradeAdminToVersion101;
  begin
     UpgradingToVersion := 101;
     AdminSystem.fdFields.fdSuperfund_System := asNone;
     if Software.IsSuperFund( AdminSystem.fdFields.fdCountry,
                              AdminSystem.fdFields.fdAccounting_System_Used) then
     begin
       AdminSystem.fdFields.fdSuperfund_System := AdminSystem.fdFields.fdAccounting_System_Used;
       AdminSystem.fdFields.fdAccounting_System_Used := asNone;

       AdminSystem.fdFields.fdSuperfund_Code_Mask  :=  AdminSystem.fdFields.fdAccount_Code_Mask;
       AdminSystem.fdFields.fdLoad_Client_Super_Files_From := AdminSystem.fdFields.fdLoad_Client_Files_From;
       AdminSystem.fdFields.fdSave_Client_Super_Files_To := AdminSystem.fdFields.fdSave_Client_Files_To;
       AdminSystem.fdFields.fdLoad_Client_Files_From := '';
       AdminSystem.fdFields.fdSave_Client_Files_To := '';
       AdminSystem.fdFields.fdAccount_Code_Mask := '';
     end;
  end;

  procedure UpgradeAdminToVersion102;
  var
    i: integer;
    sba: pSystem_Bank_Account_Rec;
    NumberOfTrx, FirstTrxDate, LastTrxDate: LongInt;
  begin
    UpgradingToVersion := 102;
    for i := AdminSystem.fdSystem_Bank_Account_List.First to
             AdminSystem.fdSystem_Bank_Account_List.Last do begin
      sba := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
      if sba <> nil then begin
        GetArchiveInfo(sba.sbLRN, NumberOfTrx, FirstTrxDate, LastTrxDate);
        sba.sbFirst_Available_Date := FirstTrxDate;
      end;
    end;
  end;

  procedure UpgradeAdminToVersion103;
  var
    i: integer;
    cam: pClient_Account_Map_Rec;
  begin
    UpgradingToVersion := 103;
    for i := AdminSystem.fdSystem_Client_Account_Map.First to
             AdminSystem.fdSystem_Client_Account_Map.Last do begin
      cam := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
      cam.amEarliest_Download_Date := MaxInt;
    end;
  end;

  procedure UpgradeAdminToVersion104;
  begin
    //If they used to sort by Staff Member (renamed to spare boolean 3) then continue
    //to sort by staff member
    //Spare Boolean 3 renames to Use BankLink Online in v128
    if AdminSystem.fdFields.fdUse_BankLink_Online then
    begin
      AdminSystem.fdFields.fdSort_Reports_By := srsoStaffMember;
      AdminSystem.fdFields.fdUse_BankLink_Online := false;
    end;
  end;

  procedure UpgradeAdminToVersion105;
  var i: integer;
      User: pUser_Rec;
  begin
    //Set suppress header footer field to checked or unchecked depending on user
    for i := 0 to AdminSystem.fdSystem_User_List.ItemCount - 1 do
    begin
      User := AdminSystem.fdSystem_User_List.Items[i];
      if (User.usSystem_Access) then
        user.usSuppress_HF := shfUnchecked
      else if (User.usIs_Remote_User) then
        user.usSuppress_HF := shfChecked
      else
        user.usSuppress_HF := shfUnchecked;
    end;
  end;

  procedure UpgradeAdminToVersion106;
  begin
    AdminSystem.fdFields.fdSet_Fixed_Dollar_Amount := 0.00;
  end;

  procedure UpgradeAdminToVersion108;
  begin
    AdminSystem.fdFields.fdPractice_Management_System := 2; // Old Other
  end;

  procedure UpgradeAdminToVersion109;
  var i: Integer;
      BankAccount : pSystem_Bank_Account_Rec;
  begin
    for i := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount-1 do
    begin
      BankAccount := AdminSystem.fdSystem_Bank_Account_List[i];
      BankAccount.sbNo_Charge_Account := False;
    end;
  end;

  procedure UpgradeAdminToVersion110;
  var
    I: Integer;
  begin
    //Case 1210. Copy (old) Global Automatic Task Creation settings
    //To new individual (per task type) settings
    for I := ttyAutoMin to ttyAutoMax do
    begin
      //Don't Check the two new tasks types
      if not I in [ttyCheckIn, ttyQueryEmail] then
      begin
        AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[I] := AdminSystem.fdFields.fdSpare_Boolean_4;
        AdminSystem.fdFields.fdAutomatic_Task_Reminder_Delay[I] := AdminSystem.fdFields.fdSpare_Integer_9;
      end;
    end;
    AdminSystem.fdFields.fdSpare_Boolean_4 := false;
    AdminSystem.fdFields.fdSpare_Integer_9 := 0;
  end;

  procedure UpgradeAdminToVersion111;
  var
    i: integer;
  begin
    for i := 0 to AdminSystem.fdSystem_User_List.ItemCount - 1 do
      pUser_Rec(AdminSystem.fdSystem_User_List.Items[i])^.usShow_Practice_Logo := False;
  end;

  procedure UpgradeAdminToVersion112;
  begin
    UpgradingToVersion := 112;
    if Pos('17.143',PRACINI_FuelCreditRates) = 0 then begin
        PRACINI_FuelCreditRates := PRACINI_FuelCreditRates + ',17.143';
        WritePracticeINI_WithLock;
    end;
  end;

  procedure UpgradeAdminToVersion114;
  begin
    case AdminSystem.fdFields.fdPractice_Management_System of
    0 : AdminSystem.fdFields.fdPractice_Management_System  := xcAPS;
    1 : AdminSystem.fdFields.fdPractice_Management_System  := xcMYOB;
    // Drop the default of other to N/A
    3 : AdminSystem.fdFields.fdPractice_Management_System  := xcMYOBAO;
    4 : AdminSystem.fdFields.fdPractice_Management_System  := xcHandi;
    else AdminSystem.fdFields.fdPractice_Management_System := xcNA;
    end;
  end;

  procedure UpgradeAdminToVersion115;
  begin
     AdminSystem.fdFields.fdBulk_Export_Enabled := True;
     AdminSystem.fdFields.fdBulk_Export_Code := '';
  end;

  procedure UpgradeAdminToVersion116;
  var
     i: Integer;
     BankAccount : pSystem_Bank_Account_Rec;
  begin
    for i := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount-1 do begin
       BankAccount := AdminSystem.fdSystem_Bank_Account_List[i];
       BankAccount.sbCurrency_Code := whCurrencyCodes[ AdminSystem.fdFields.fdCountry ];
    end;
    if Pos('16.443',PRACINI_FuelCreditRates) = 0 then begin
        PRACINI_FuelCreditRates := PRACINI_FuelCreditRates + ',16.443';
        WritePracticeINI_WithLock;
    end;
  end;

  procedure UpgradeAdminToVersion120;
  var
     i: Integer;
     BankAccount : pSystem_Bank_Account_Rec;
  begin
    for i := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount-1 do begin
       BankAccount := AdminSystem.fdSystem_Bank_Account_List[i];
       BankAccount.sbFrequency := difUnspecified; //Default to unspecified
       BankAccount.sbFrequency_Change_Pending := 0;
    end;
  end;

  procedure UpgradeAdminToVersion122;
  var
    i: Integer;
    pCF : pClient_File_Rec;
    aClient : TClientObj;
    ISOList: TStringList;
  begin
    //update the ISO codes for all client files
    UpgradingToVersion := 122;

    //Only upgrade currencies for UK
    if AdminSystem.fdFields.fdCountry <> whUK then Exit;    

    aClient := nil;
    ISOList := TStringList.Create;
    try
      for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
      begin
        pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i);

        Progress.UpdateAppStatusPerc_NR((i /AdminSystem.fdSystem_Client_File_List.ItemCount * 100));
        Progress.UpdateAppStatusLine2( 'Updating currency details for ' + pCF^.cfFile_Code, ProcessMessages_On);
        try
          OpenAClientForRead( pCF^.cfFile_Code, aClient);
          try
            if Assigned( aClient) then begin
              //Update ISO Codes in Client File Rec
              aClient.FillIsoCodeList(ISOList);
              AdminSystem.AddISOCodes(pCF, ISOList);
            end else
                   LogMsg( lmError, UnitName ,'Could not update currency Details for ' + pCF^.cfFile_Code);
          finally
            FreeAndNil( aClient);
          end;
        except
          on E : Exception do
            raise EUpgradeAdmin.Create( 'Error updating currency details for ' + pCF^.cfFile_Code +
                                        ' ' + E.Message + ' ' + E.Classname);
        end;
      end;
    finally
      ISOList.Free;
    end;
  end;

  procedure UpgradeAdminToVersion123;
  var
    i: integer;
  begin
    if DebugMe then LogMsg( lmDebug, Unitname, 'Audit Trail System DB Upgrade Start');
    UpgradingToVersion := 123;
    //Add unique record ID's to all system tables
    //Practice
    AdminSystem.fdFields.fdAudit_Record_ID := 0;
    //User
    for i := AdminSystem.fdSystem_User_List.First to AdminSystem.fdSystem_User_List.Last do
      AdminSystem.fdSystem_User_List.User_At(i).usAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Clients
    for i := AdminSystem.fdSystem_Client_File_List.First to AdminSystem.fdSystem_Client_File_List.Last do
      AdminSystem.fdSystem_Client_File_List.Client_File_At(i).cfAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Disks
    for i := AdminSystem.fdSystem_Disk_Log.First to AdminSystem.fdSystem_Disk_Log.Last do
      AdminSystem.fdSystem_Disk_Log.Disk_Log_At(i).dlAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //System bank accounts
    for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
      AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i).sbAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Access
    for i := AdminSystem.fdSystem_File_Access_List.First to AdminSystem.fdSystem_File_Access_List.Last do
      AdminSystem.fdSystem_File_Access_List.Access_At(i).acAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Client file map
    for i := AdminSystem.fdSystem_Client_Account_Map.First to AdminSystem.fdSystem_Client_Account_Map.Last do
      AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i).amAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Groups
    for i := AdminSystem.fdSystem_Group_List.First to AdminSystem.fdSystem_Group_List.Last do
      AdminSystem.fdSystem_Group_List.Group_At(i).grAudit_Record_ID := AdminSystem.NextAuditRecordID;
    //Client types
    for i := AdminSystem.fdSystem_Client_Type_List.First to AdminSystem.fdSystem_Client_Type_List.Last do
      AdminSystem.fdSystem_Client_Type_List.Client_Type_At(i).ctAudit_Record_ID := AdminSystem.NextAuditRecordID;
    if DebugMe then LogMsg( lmDebug, Unitname, 'Audit Trail System DB Upgrade Finish');
  end;

  procedure UpgradeAdminToVersion124;
  var
    i, j, k: integer;
    Prefix: BankPrefixStr;
    MemList: TMaster_Memorisations_List;
    PrefixList: TStringList;
    sba: pSystem_Bank_Account_Rec;
    M: Tmemorisation;
    ML: pMemorisation_Line_Rec;
  begin
    UpgradingToVersion := 124;
    //Copy master memorisations from MXL files into the System DB
    PrefixList := TStringList.Create;
    try
      //Get list of bank prefixes
      for i := AdminSystem.fdSystem_Bank_Account_List.First to AdminSystem.fdSystem_Bank_Account_List.Last do
      begin
        sba := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i);
        Prefix := mxFiles32.GetBankPrefix(sba.sbAccount_Number);
        if PrefixList.IndexOf(Prefix) = -1 then
          PrefixList.Add(Prefix);
      end;

      for i := 0 to Pred(PrefixList.Count) do
      begin
        Master_Mem_Lists_Collection.ReloadSystemMXList(PrefixList[i]);
        MemList := Master_Mem_Lists_Collection.FindPrefix(PrefixList[i]);
        if Assigned(MemList) then begin
          //Add audit record ID's
          for j := 0 to MemList.ItemCount - 1 do begin
             M := MemList.Memorisation_At(j);
             M.mdFields.mdAudit_Record_ID := SystemAuditMgr.NextAuditRecordID;
             for k := 0 to M.mdLines.ItemCount - 1 do begin
               ML := M.mdLines.MemorisationLine_At(k);
               ML.mlAudit_Record_ID := SystemAuditMgr.NextAuditRecordID;
             end;
          end;
          //Add to System DB
          AdminSystem.fSystem_Memorisation_List.AddMemorisation(PrefixList[i], TMemorisations_List(MemList));
        end;
      end;
    finally
      PrefixList.Free;
    end;
  end;

  procedure UpgradeAdminToVersion128;
  var
    UserIndex : integer;
    Prac: TBloPracticeRead;
    Index: Integer;
  begin
    UpgradingToVersion := 128;

    for UserIndex := 0 to AdminSystem.fdSystem_User_List.ItemCount-1 do
    begin
      // Moves Redundant password to New 12 length Password
      AdminSystem.fdSystem_User_List.User_At(UserIndex).usPassword :=
        AdminSystem.fdSystem_User_List.User_At(UserIndex).usRedundant_Password;

      //Default this to false for the first time.
      AdminSystem.fdSystem_User_List.User_At(UserIndex).usUsing_Mixed_Case_Password := False;
    end;

    if (Trim(Globals.PRACINI_OnlineLink) <> '') then
    begin
      AdminSystem.fdFields.fdUse_BankLink_Online := True;
      
      //Connect to BankLink Online and get the Practice details
      Prac := ProductConfigService.GetPractice(True, False, '', True, True);
      
      if not ProductConfigService.Registered then
      begin
        AdminSystem.fdFields.fdUse_BankLink_Online := False;
      end;
    end;

    for Index := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount - 1 do
    begin
      AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(Index).sbCore_Account_ID := 0;  
    end;
  end;

  procedure UpgradeAdminToVersion129;
  var
    UserIndex: Integer;
  begin
    UpgradingToVersion := 129;

    for UserIndex := 0 to AdminSystem.fdSystem_User_List.ItemCount-1 do
    begin
      AdminSystem.fdSystem_User_List.User_At(UserIndex).usUsing_Secure_Authentication := False;
    end;
  end;

  procedure UpgradeAdminToVersion130;

    procedure AddNewClientType(Name: string);
    var
      pc: pClient_Type_Rec;
    begin
      pc := New_Client_Type_Rec;
      Inc(AdminSystem.fdFields.fdClient_Type_LRN_Counter);
      pc.ctLRN := AdminSystem.fdFields.fdClient_Type_LRN_Counter;
      pc.ctName := Name;
      AdminSystem.fdSystem_Client_Type_List.Insert(pc);
    end;

  var
    NewClientTypeName: string;
  begin
    UpgradingToVersion := 130;

    NewClientTypeName := 'Books via ' + bkBranding.ProductOnlineName;

    //For many sites this would have been done already so only do it if it doesn't exist.
    if (AdminSystem.fdSystem_Client_Type_List.FindName(NewClientTypeName) = nil) then
    begin
      AddNewClientType(NewClientTypeName);
    end;
  end;

  procedure UpgradeAdminToVersion132;
  begin
    UpgradeAdmin_Memorisation_EntryType(AdminSystem);
  end;

  procedure UpgradeAdminToVersion134;
  var
    ClientFileRec : pClient_File_Rec;
    AdminClientIndex : integer;
    SuggDisabledList : TStringList;
    ClientCodes : TStringList;
    ClientIndex : integer;
    ClientCode : string;
  begin
    SuggDisabledList := TStringList.create();
    try
      ClientCodes := TStringList.create();
      ClientCodes.Sorted := True;
      ClientCodes.Duplicates := dupIgnore;
      try
        // Loop through System Clients and read any mem ini settings in, also used for sorting
        for AdminClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
        begin
          ClientFileRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(AdminClientIndex);

          ReadMemorisationINI(ClientFileRec^.cfFile_Code);

          ClientCodes.Add(ClientFileRec^.cfFile_Code);
          if MEMSINI_SupportOptions = meiDisableSuggestedMems then
            SuggDisabledList.Add(ClientFileRec^.cfFile_Code);
        end;

        // Write Codes to ini file
        for ClientIndex := 0 to ClientCodes.Count - 1 do
        begin
          ClientCode := ClientCodes.Strings[ClientIndex];

          if SuggDisabledList.IndexOf(ClientCode) = -1 then
            MEMSINI_SupportOptions := meiResetMems
          else
            MEMSINI_SupportOptions := meiDisableSuggestedMems;

          WriteMemorisationINI_WithLock(ClientCode);
        end;

      finally;
        FreeAndNil(ClientCodes);
      end;
    finally
      FreeAndNil(SuggDisabledList);
    end;
  end;

Const
   ThisMethodName = 'DoUpgradeAdminToLatestVersion';
Var
  ArchiveCheckNeeded : boolean;

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Begins' );

   ArchiveCheckNeeded := false;
   Try
      With AdminSystem.fdFields do Begin

         If ( fdFile_Version < 32 ) then Begin
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrading Database  < 32 to 36' );
            UpgradeAdminBefore32ToVersion36;      //includes the version upgrade from 32 to 33!
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         If ( fdFile_Version < 33 ) then Begin
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 33' );
            UpgradeAdminToVersion33;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 36 ) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading < 36 to Version 36');
            UpgradeAdminAfter32ToVersion36;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 37 ) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 37');
            UpgradeAdminToVersion37;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 40 ) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 40');
            UpgradeAdminToVersion40;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 44) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 44');
            UpgradeAdminToVersion44;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 46) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 46');
            UpgradeAdminToVersion46;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 47) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 47');
            UpgradeAdminToVersion47;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 48) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 48');
            UpgradeAdminToVersion48;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 49) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 49');
            UpgradeAdminToVersion49;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 50) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 50');
            UpgradeAdminToVersion50;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 52) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 52');
            UpgradeAdminToVersion52;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 53) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 53');
            UpgradeAdminToVersion53;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 54) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 54');
            UpgradeAdminToVersion54;
            ArchiveCheckNeeded := True;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 55) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 55');
            UpgradeAdminToVersion55;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 60) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 60');
            UpgradeAdminToVersion60;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 63) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 63');
            UpgradeAdminToVersion63;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 66) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 66');
            UpgradeAdminToVersion66;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 69) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 69');
            UpgradeAdminToVersion69;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 70) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 70');
            UpgradeAdminToVersion70;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 72) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 72');
            UpgradeAdminToVersion72;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 73) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 73');
            UpgradeAdminToVersion73;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 74) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 74');
            UpgradeAdminToVersion74;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 75) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 75');
            UpgradeAdminToVersion75;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 76) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 76');
            UpgradeAdminToVersion76;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 77) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 77');
            UpgradeAdminToVersion77;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 80) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 80');
            UpgradeAdminToVersion80;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 82) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 82');
            UpgradeAdminToVersion82;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 85) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 85');
            UpgradeAdminToVersion85;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 86) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 86');
            UpgradeAdminToVersion86;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 87) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 87');
            UpgradeAdminToVersion87;
            ArchiveCheckNeeded := True;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 90) and (fdFile_Version > 86) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 90');
            UpgradeAdminToVersion90;
            ArchiveCheckNeeded := True;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         //  5.13 (2008)

         if ( fdFile_Version < 96) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 96');
            UpgradeAdminToVersion96;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 97) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 97');
            UpgradeAdminToVersion97;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 98) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 98');
            UpgradeAdminToVersion98;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         //  5.14 (SMSF)

         if ( fdFile_Version < 100) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 100');
            UpgradeAdminToVersion100;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 101) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 101');
            UpgradeAdminToVersion101;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         //  5.15 (2009)

         if ( fdFile_Version < 102) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 102');
            UpgradeAdminToVersion102;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 103) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 103');
            UpgradeAdminToVersion103;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 104) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 104');
            UpgradeAdminToVersion104;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 105) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 105');
            UpgradeAdminToVersion105;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 106) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 106');
            UpgradeAdminToVersion106;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 108) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 108');
            UpgradeAdminToVersion108;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 109) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 109');
            UpgradeAdminToVersion109;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 110) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 110');
            UpgradeAdminToVersion110;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 111) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 111');
            UpgradeAdminToVersion111;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

        if ( fdFile_Version < 112) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 112');
            UpgradeAdminToVersion112;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 113) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 113');
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;

         if ( fdFile_Version < 114) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 114');
            UpgradeAdminToVersion114;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // Bulk Extract
         if ( fdFile_Version < 115) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 115');
            UpgradeAdminToVersion115;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // 2010
         if ( fdFile_Version < 116) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 116');
            UpgradeAdminToVersion116;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // daily Date 2010
         if ( fdFile_Version < 120) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 120');
            UpgradeAdminToVersion120;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // UK multi-currency 2011
         if ( fdFile_Version < 122) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 122');
            UpgradeAdminToVersion122;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // UK audit trail 2011
         if ( fdFile_Version < 123) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 123');
            UpgradeAdminToVersion123;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // UK audit trail 2011 - Master memorisations
         if ( fdFile_Version < 124) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 124');
            UpgradeAdminToVersion124;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
          // UK audit trail 2011 - compulsory passwords for UK only
         if ( fdFile_Version < 125) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 125');
            UpgradingToVersion := 125;
            //Nothing to do
            if (OriginalVersion < 120) then  //No need to update if already on v120
              RefreshAllProcessingStatistics(True, False, True); //Always move to last upgrade
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
           // BLOPI - User Password upgrade to 12 characters
         if ( fdFile_Version < 128) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 128');
            UpgradeAdminToVersion128;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
           // BLOPI Secure - User Password upgrade to 12 characters
         if ( fdFile_Version < 129) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 128');
            UpgradeAdminToVersion129;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
         //BLOPI Added in new client type
         if ( fdFile_Version < 130) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 130');
            UpgradeAdminToVersion130;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
         if ( fdFile_Version < 132) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 132');
            UpgradeAdminToVersion132;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end;
         if ( fdFile_Version < 134) then begin
            Logutil.LogMsg( lmInfo, ThisMethodName, 'Upgrading to Version 134');
            UpgradeAdminToVersion134;
            LogUtil.LogMsg( lmInfo, ThisMethodName, 'Upgrade completed normally' );
         end
      end;
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //  FIELDS AND FILES UPGRADED, NOW SAVE NEW ADMIN SYSTEM
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFNDEF BK_UNITTESTINGON}
      SaveAdminSystem;
{$ENDIF}

      if ArchiveCheckNeeded and PRACINI_ValidateArchive then
      begin
        //now check the archive - may cause reload so must be called after new admin saved
        ArchiveCheck.CheckArchiveDirSynchronised;
      end;
   Finally
      if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' : Ends' );
      ClearStatus;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowBackupProgress( s : string; p : double);
begin
  UpdateAppStatus( 'Backing Up Files', s, p, ProcessMessages_On);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogBackupMessage( s : string);
begin
  LogMsg( lmInfo, Unitname, 'Backup.' + s);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ArchiveBackupNeeded( const OriginalVersion, NewVersion : integer) : boolean;
begin
  result := OriginalVersion < 90;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BackupAdminSystem( const FileTypes : TSetOfByte) : boolean;
//backups up all parts of the admin system: system.db, txns, master mem files
var
  BackupObj    : TBkBackup;
  DefaultBackupFilename : string;
  TodaysDate   : integer;
  aMsg         : string;
begin
  try
    //do backup
    TodaysDate := StDate.CurrentDate;
    DefaultBackupFilename := DataDir + StDateToDateString( 'ddmmyy', TodaysDate, false) + '.zip';

    BackupObj := TBkBackup.Create;
    try
      BackupObj.ZipFilename := Backup.ZipFilenameToUse( DefaultBackupFilename);
      BackupObj.FilesTypesToInclude := FileTypes;
      BackupObj.RootDir     := DataDir;
      BackupObj.OnProgressEvent := ShowBackupProgress;
      BackupObj.OnLogEvent      := LogBackupMessage;

      BackupObj.ZipFiles;
    finally
      BackupObj.Free;
      ClearStatus;
    end;
  except
    On E : Exception do
    begin
      aMsg := 'Backup Failed. ' + E.Message + ' [' + E.Classname + ']';
      ShowMessage( aMsg);

      LogMsg( lmError, Unitname, aMsg);
    end;
  end;
  Result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MasterMemsBackupNeeded( const OriginalVersion, NewVersion : integer) : boolean;
begin
  result := ((OriginalVersion > 54) and (OriginalVersion < 68)) or
            (NewVersion = 80) or (NewVersion = 87) or (NewVersion = 124);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BackupMasterMemFiles : boolean;
var
  BackupObj    : TBkBackup;
  DefaultBackupFilename : string;
  TodaysDate   : integer;
  aMsg         : string;
begin
  try
    //do backup
    TodaysDate := StDate.CurrentDate;
    DefaultBackupFilename := DataDir + 'mx' + StDateToDateString( 'ddmmyy', TodaysDate, false) + '.zip';

    BackupObj := TBkBackup.Create;
    try
      BackupObj.ZipFilename := Backup.ZipFilenameToUse( DefaultBackupFilename);
      BackupObj.FilesTypesToInclude := [ biMasterMemFiles, biSystemDb ];
      BackupObj.RootDir     := DataDir;
      BackupObj.OnProgressEvent := ShowBackupProgress;
      BackupObj.OnLogEvent      := LogBackupMessage;

      BackupObj.ZipFiles;
    finally
      BackupObj.Free;
      ClearStatus;
    end;
  except
    On E : Exception do
    begin
      aMsg := 'Backup Failed. ' + E.Message + ' [' + E.Classname + ']';
      ShowMessage( aMsg);

      LogMsg( lmError, Unitname, aMsg);
    end;
  end;
  Result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BackupSystemDbNeeded( const OriginalVersion, NewVersion : integer) : boolean;
//always create a system db backup unless one of the other backups has been done
begin
  result := not( MasterMemsBackupNeeded( OriginalVersion, NewVersion) or
                 ArchiveBackupNeeded( OriginalVersion, NewVersion));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TestPreconditions( OriginalVersion : integer) : boolean;
var
  ExtraSpace   : Int64;
  Path         : String;
  DiskSizeOK   : boolean;

  FreeSpace    : Int64;
  TotalSpace   : Int64;
begin
  result := false;

  //test for backup done
  if OriginalVersion < 54 then
  begin
    //check disk space
    //calculate the current space used by the archive directory
    ExtraSpace := Round( ArchiveCheck.GetSizeOfArchive * 1.25);
    //get the drive that bk5 is installed on and check free space
    Path       := ExtractFileDrive( Globals.DataDir);
    DiskSizeOK := SysUtils.GetDiskFreeSpaceEx( PChar(Path), FreeSpace, TotalSpace, nil);
    if DiskSizeOK then
    begin
      //managed to get the disk space free, if can't get it then dont do test
      if ( FreeSpace < ExtraSpace) then
      begin
        LogMsg( lmInfo, Unitname, 'Not enough disk space to upgrade. Required = ' +
                                  inttostr( ExtraSpace div 1024) + ' Kb  Avail = ' +
                                  inttostr( FreeSpace div 1024) + ' Kb');

        ShowMessage( 'You do not have enough disk space to complete this upgrade.  ' +
                     ShortAppName + ' requires ' + inttostr( ExtraSpace div 1024) + ' Kb of free space on ' +
                     Path + '.  There are ' + inttostr( FreeSpace div 1024) + ' Kb available');
        Exit;
      end;
    end
    else
      LogMsg( lmInfo, Unitname, 'Unable to check disk space, require ' +
                                inttostr( ExtraSpace div 1024));
  end;



  //everything succeeded
  result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpgradeAdminToLatestVersion;
//the process assumes that an external backup of the system has been taken
//prior to the new version of banklink being run
const
  ThisMethodName = 'UpgradeAdminToLatestVersion';
var
  OriginalVersion     : integer;
  NewVersion          : integer;

  UpgradingToVersion  : integer;
  ErrorMessage        : string;
begin
{$IFNDEF BK_UNITTESTINGON}
  //If unit testing, the unit test will create a new Admin System, so don't load
  LoadAdminSystem( True, 'Upgrade.UpgradeAdminToLatestVersion' );
{$ENDIF}

  //see if needs upgrading
  if ( AdminSystem.fdFields.fdFile_Version = SYDEFS.SY_FILE_VERSION ) then
  begin { We are up to date }
    UnlockAdmin;
    Exit;
  end;
  //admin system is still locked at this point
  OriginalVersion := AdminSystem.fdFields.fdFile_Version;
  NewVersion      := SYDEFS.SY_FILE_VERSION;

  LogUtil.LogMsg( lmInfo, ThisMethodName, 'Starting Upgrade' );

  //validate archive

  //backup admin system
  if ArchiveBackupNeeded( OriginalVersion, NewVersion) then
  begin
    //test archive for missing files etc
    //check that test has not been disabled in the prac ini
    if PRACINI_ValidateArchive then
    begin
      //ensure that file LRN's match admin system LRN
      //will raise an exception if it fails
      if OriginalVersion < 54 then
        ArchiveCheck.CheckArchiveDirSynchronised_V53
      else
        ArchiveCheck.CheckArchiveDirSynchronised;
    end;

    if not BackupAdminSystem([ biSystemDb, biArchive, biMasterMemFiles ]) then
    begin
      //backup failed or was cancelled
      UnlockAdmin;
      Application.Terminate;
      Halt;
    end;
  end;

  //see if need to backup mems
  if MasterMemsBackupNeeded( OriginalVersion, NewVersion) then
    begin
      if not BackupMasterMemFiles then
        begin
          //backup failed or was cancelled
          UnlockAdmin;
          Application.Terminate;
          Halt;
        end;
    end;

  //this will only be done in the absence of the previous backups
  if BackupSystemDbNeeded( OriginalVersion, NewVersion) then
  begin
    if not BackupAdminSystem([ biSystemDb]) then
    begin
      //backup failed or was cancelled
      UnlockAdmin;
      Application.Terminate;
      Halt;
    end;
  end;

  //test pre upgrade conditions
  if not TestPreConditions( OriginalVersion) then begin
    UnlockAdmin;
    Application.Terminate;
    Halt;
  end;

  Progress.UpdateAppStatus( 'Upgrading Admin System', 'This process may take several minutes', 1, ProcessMessages_On);

  try
    try
      //upgrade, this will unlock the system db
      //upgradingToVersion is set within DoUpgradeAdminToLatestVersion so that
      //we know what step we need to rollback from
      DoUpgradeAdminToLatestVersion( UpgradingToVersion, OriginalVersion);
      CleanUpTemporaryFiles( OriginalVersion);
    except
      on E : Exception do begin
        ErrorMessage := 'Upgrade Failed [' + E.Message +
             '] Original ver = ' + inttostr( OriginalVersion) +
             ' Upgrade reached ver ' + inttostr( UpgradingToVersion);
        LogUtil.LogMsg( lmInfo, ThisMethodName, ErrorMessage );
        //Raise exception
        Raise Exception.Create( ErrorMessage);
      end;
    end;
  finally
    //clean up temp files
    Progress.ClearStatus;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//    UPGRADE CLIENT FILES
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CopyVersion50BalanceRec( pRFrom : pBalances_Rec; pRTo : pBalances_Rec);
begin
  pRTo.blGST_Period_Starts           := pRFrom.blGST_Period_Starts;
  pRTo.blGST_Period_Ends             := pRFrom.blGST_Period_Ends;
  pRTo.blClosing_Debtors_Balance     := pRFrom.blClosing_Debtors_Balance;
  pRTo.blOpening_Debtors_Balance     := pRFrom.blOpening_Debtors_Balance;
  pRTo.blFBT_Adjustments             := pRFrom.blFBT_Adjustments;
  pRTo.blOther_Adjustments           := pRFrom.blOther_Adjustments;
  pRTo.blClosing_Creditors_Balance   := pRFrom.blClosing_Creditors_Balance;
  pRTo.blOpening_Creditors_Balance   := pRFrom.blOpening_Creditors_Balance;
  pRTo.blCredit_Adjustments          := pRFrom.blCredit_Adjustments;
  pRTo.blBAS_Document_ID             := pRFrom.blBAS_Document_ID;


  pRTo.blBAS_1C_PT_Last_Months_Income   := pRFrom.blBAS_1C_PT_Last_Months_Income;
  pRTo.blBAS_1D_PT_Branch_Income        := pRFrom.blBAS_1D_PT_Branch_Income;
  pRTo.blBAS_1E_PT_Assets               := pRFrom.blBAS_1E_PT_Assets;
  pRTo.blBAS_1F_PT_Tax                  := pRFrom.blBAS_1F_PT_Tax;
  pRTo.blBAS_1G_PT_Refund_Used          := pRFrom.blBAS_1G_PT_Refund_Used;
  pRTo.blBAS_5B_PT_Ratio                := pRFrom.blBAS_5B_PT_Ratio;
  pRTo.blBAS_6B_GST_Adj_PrivUse      := pRFrom.blBAS_6B_GST_Adj_PrivUse;
  pRTo.blBAS_7_VAT4_GST_Adj_BAssets  := pRFrom.blBAS_7_VAT4_GST_Adj_BAssets;
  pRTo.blBAS_G7_GST_Adj_Assets       := pRFrom.blBAS_G7_GST_Adj_Assets;
  pRTo.blBAS_G18_GST_Adj_Entertain   := pRFrom.blBAS_G18_GST_Adj_Entertain;
  pRTo.blBAS_W1_GST_Adj_Change       := pRFrom.blBAS_W1_GST_Adj_Change;
  pRTo.blBAS_W2_GST_Adj_Exempt       := pRFrom.blBAS_W2_GST_Adj_Exempt;
  pRTo.blBAS_W3_GST_Adj_Other        := pRFrom.blBAS_W3_GST_Adj_Other;
  pRTo.blBAS_W4_GST_Cdj_BusUse       := pRFrom.blBAS_W4_GST_Cdj_BusUse;
  pRTo.blBAS_T1_VAT1_GST_Cdj_PAssets := pRFrom.blBAS_T1_VAT1_GST_Cdj_PAssets;
  pRTo.blBAS_T2_VAT2_GST_Cdj_Change  := pRFrom.blBAS_T2_VAT2_GST_Cdj_Change;
  pRTo.blBAS_T3_VAT3_GST_Cdj_Other   := pRFrom.blBAS_T3_VAT3_GST_Cdj_Other;
  pRTo.blBAS_T4                      := pRFrom.blBAS_T4;
  pRTo.blBAS_F1_GST_Closing_Debtors_BalanceA := pRFrom.blBAS_F1_GST_Closing_Debtors_BalanceA;
  pRTo.blBAS_F2_GST_Opening_Debtors_BalanceB := pRFrom.blBAS_F2_GST_Opening_Debtors_BalanceB;
  pRTo.blBAS_F3                      := pRFrom.blBAS_F3;
  pRTo.blBAS_F4                      := pRFrom.blBAS_F4;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure UpgradeClientToLatestVersion( aClient : TClientObj );
var
   Initial_Version : integer;
const
   MethodName = 'UpgradeClientToLatestVersion';

   procedure UpgradeBefore31ToVersion36;
   var i : integer;
   begin
      with aClient.clFields do begin
         if clOld_GST_Class_Codes <> '' then begin
            //the data will be in char positions from 1 .. 9.  Put char into
            //the array position.
            for i := 1 to 9 do begin
               clGST_Class_Codes[ i] := clOld_GST_Class_Codes[ i];
            end;
            clOld_GST_Class_Codes := '';
         end;
      end;
   end;

   procedure UpgradeAfter30ToVersion36;
   //upgrades the internal build done after 36.  They will have default gst id whereas
   //in for upgrades done after 35 it is ok to have blank gst ids
   var i : integer;
   begin
      with aClient.clFields do begin
         //the data in the gst_class_codes string will be in a delimited string, extract the fields
         //and insert into array
         for i := 1 to 20 do begin
            clGST_Class_Codes[ i] := ExtractWordS( i, clOld_GST_Class_Codes, '|');
         end;
         clOld_GST_Class_Codes := '';
      end;
   end;

   procedure UpgradeToVersion37;
   var
      i : integer;
      RateSpecified : boolean;
   begin
      with aClient.clFields do begin
         //check rate 1 to see if any gst rates have been specified, if so then make
         //sure that an applies from date is specified
         RateSpecified := false;
         for i := 1 to MAX_GST_CLASS do begin
            if clGST_Rates[ i, 1] <> 0 then begin
               RateSpecified := true;
               break;
            end;
         end;
         //see if rate being used
         if RateSpecified and ( clGST_Applies_From[ 1] <= 0) then begin
            case clCountry of
               whNewZealand : clGST_Applies_From[ 1] := 138792;  // 01/01/80
               whAustralia  : clGST_Applies_From[ 1] := 146279;  // 01/07/00
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion41;
   //major upgrade to how changes to the chart affect entries, memorisations and
   //how recalc GST works.

   { requires a change to the master memorised files:
     need to set mxGST_Has_Been_Edited to true for existing master memorised entries

     requires changes to client file:
     need to set the following flags during the upgrade
           txGST_Has_Been_Edited
           dsGST_Has_Been_Edited
           mxGST_Has_Been_Edited

     Need to look through all bank accounts and journals to set these.  Compare the
     current gst amount and gst class to the default for the chart.  Set flag if different
     If the chart code does not exist or is invalid set flag to false.

     The txGST_Has_Been_Edited flag does not need to be set if the transaction is
     dissected.

     Do the same for memorisations.  If there are master memorisations in the client file
     then set the mxGST_Has_Been_Edited to TRUE.  This is the default for EXISTING
     master memorised entries.

     Set for all transactions.
   }
   var
      pT : pTransaction_Rec;
      pD : pDissection_Rec;
      pM : pMemorised_Transaction_Rec;
      b, t, m ,i : integer;

      DefaultGSTClass :  byte;
      DefaultGSTAmt   : money;
   begin
      //set GST has been edited flag for transactions and dissections
      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
            //cycle thru each bank account, including all journals
            for t := 0 to Pred( baTransaction_List.ItemCount) do begin
               pT := baTransaction_List.Transaction_At( t);
               with pT^ do begin
                  //is it a dissection?
                  if txFirst_Dissection = nil then begin
                     //is transaction validly coded? doesnt matter.  if is invalid gst class and amt will be 0
                     //compare gst to see if different
                     CalculateGST( aClient, txDate_Effective, txAccount, txAmount, DefaultGSTClass, DefaultGSTAmt);
                     txGST_Has_Been_Edited := (txGST_Class <> DefaultGSTClass) or (txGST_Amount <> DefaultGSTAmt);
                  end
                  else begin
                     pD := txFirst_Dissection;
                     while (pD <> nil) do with pD^ do begin
                        //compare gst to see if different
                        CalculateGST( aClient, txDate_Effective, dsAccount, dsAmount, DefaultGSTClass, DefaultGSTAmt);
                        dsGST_Has_Been_Edited := (dsGST_Class <> DefaultGSTClass) or (dsGST_Amount <> DefaultGSTAmt);
                        pD := pD^.dsNext;
                     end;
                  end;
               end;
            end;

            //set GST has been edited flag for all client memorisations.
            for m := 0 to Pred( baOld_Memorised_Transaction_List.ItemCount) do begin
                pM := baOld_Memorised_Transaction_List.Memorised_Transaction_At( m);
                with pM^ do begin
                   for i := 1 to 10 do
                      mxGST_Has_Been_Edited[ i] := ( mxGST_Class[ i] <> aClient.clChart.GSTClass( mxAccount[ i]));
                end;
            end;
         end;
      end;
   end;

   procedure UpgradeMemorisations;
   //upgrade memorisation so that the default gst is set to the default for the
   //account code.  AutoCode32 was changed in this release not to replace blank
   //with the default.
   var
      i,j,line       : integer;
      mem            : pMemorised_Transaction_Rec;
      IsActive       : boolean;
   begin
      IsActive := True;
      with aClient.clBank_Account_List do begin
         for i := 0 to Pred( ItemCount) do with Bank_Account_At( i) do begin
            for j := 0 to Pred( baOld_Memorised_Transaction_List.ItemCount) do begin
               mem := baOld_Memorised_Transaction_List.Memorised_Transaction_At( j);
               for line := 1 to 10 do begin
                  if ( not mem^.mxFrom_Master_List) and
                     ( mem^.mxAccount[ line] <> '') and
                     ( aClient.clChart.CanCodeTo( mem^.mxAccount[ line], IsActive)) and
                     ( mem^.mxGST_Class[ line] = 0) then
                  begin
                     //have found a line with a valid code that has a blank gst class
                     //set gst to default and clear gst has been edited flag
                     mem^.mxGST_Class[ line] := aClient.clChart.GSTClass( mem^.mxAccount[ line]);
                     mem^.mxGST_Has_Been_Edited[ line] := false;
                  end;
               end;
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion44;
   //make sure that the PAYG witholding period is set.
   begin
      with aClient.clFields do begin
         clBAS_PAYG_Withheld_Period := clGST_Period;
      end;
   end;

   procedure UpgradeToVersion46;
   //Set GST all clients payees, no need to check if different to default because
   //was not used prior to this version
   var
      p  : integer;
      i  : integer;
      pP : pPayee_Rec;
   begin
      with aClient.clPayee_List_V53 do begin
         for p := 0 to Pred( ItemCount) do begin
            pP := Payee_At( p);
            for i := 1 to Max_Py_Lines_V53 do begin
               pP^.pyGST_Class[ i] := aClient.clChart.GSTClass( pP^.pyAccount[ i]);
               pP^.pyGST_Has_Been_Edited[ i] := false;
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion49;
   //set the UPI_State variable.  The only values that we can calculate from the
   //existing data are
   //
   //upNone, upUPC, upUPD, upMatchedUPC, upMatchedUPD.
   //upBalanceOfUPC and upBalanceOfUPD cannot be identified in the existing data
   //upReversing etc do not existing in prior versions
   var
      pT            : pTransaction_Rec;
      b, t          : integer;
      isChequeType  : boolean;
      isDepositType : boolean;
   begin
      //set UPI_Status flag for transactions
      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
            //cycle thru each bank account, only include bank accounts!
            if baFields.baAccount_Type <> btBank then Continue;
            //cycle thru each transaction
            for t := 0 to Pred( baTransaction_List.ItemCount) do begin
               pT := baTransaction_List.Transaction_At( t);
               with pT^ do begin
                  //see if cheq of deposit type
                  isChequeType  := false;
                  isDepositType := false;

                  case aClient.clFields.clCountry of
                     whNewZealand : begin
                        if txType = 0 then begin
                           isChequeType := true;
                        end;
                        if txType = 50 then begin
                           isDepositType := true;
                        end;
                     end;
                     whAustralia : begin
                        if txType = 1 then begin
                           isChequeType := true;
                        end;
                        if txType = 10 then begin
                           isDepositType := true;
                        end;
                     end;
                  end;

                  //look for unpresented items
                  if txDate_Presented = 0 then begin
                     if isChequeType then begin
                        txUPI_State := upUPC;
                        //strip of upc reference
                        txReference := inttostr( txCheque_Number)
                     end;
                     if isDepositType then begin
                        txUPI_State := upUPD;
                        //strip upl, upd refernce
                        if ( pos( 'UPL', txReference) > 0) then
                           txReference := Copy( txReference, 4, length( txReference));
                     end;
                  end
                  else begin
                     //look for matched or moved cheques/deposits.
                     if ( txSource = orGenerated) then begin
                        if isChequeType then begin
                           txUPI_State := upMatchedUPC;
                           //strip of upc, upc* reference
                           txReference := inttoStr( txCheque_Number);
                           //store known details so that add/delete code will work
                           txOriginal_Source := orBank;
                           txOriginal_Type   := txType;
                           txOriginal_Cheque_Number := txCheque_Number;
                           txOriginal_Reference     := txReference;
                           txOriginal_Amount        := txAmount;
                        end;
                        //deposits cannot be moved other than by matching
                        //so if generated, presented and deposit then must be
                        //a matched deposit. there will be no reference to strip
                        if isDepositType then begin
                           txUPI_State          := upMatchedUPD;
                           //store known details so that add/delete code will work
                           txOriginal_Source    := orBank;
                           txOriginal_Type      := txType;
                           txOriginal_Reference := txReference;
                           txOriginal_Amount    := txAmount;
                        end;
                     end
                     else begin
                        //type must be orBank or orHistorical, see if has been moved
                        //note: only cheques can be moved so will be a cheque
                        if ( txDate_Presented <> txDate_Effective) then begin
                           //date has changed and is not orGenerated so must
                           //be a moved cheque.
                           if ( txCheque_Number <> 0) then begin
                              txUPI_State := upMatchedUPC;
                              //strip of upc* reference
                              txReference := Inttostr( txCheque_Number);
                              //store known details so that add/delete code will work
                              txOriginal_Source := txSource;
                              txOriginal_Type   := txType;
                              txOriginal_Cheque_Number := txCheque_Number;
                              txOriginal_Reference     := txReference;
                              txOriginal_Amount        := txAmount;
                           end;
                        end;
                     end;
                  end;
                  //clear matched item link
                  txMatched_Item_ID := 0;
               end; //with pT^
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion50;
   //upgrade the way that the user editable fields are stored for BAS forms.
   //prior to 60 monthly bas figures were always stored with the monthly to/from dates.
   //In 60 this was changes so that the bas fields are stored with the date range
   //of the BAS statement. This means the statement will look for and save a
   //quarterly date range for quarterly statements and monthly date range for
   //monthly statements.

   // Since this upgrade, some fields are used for other countries
   // So it reads a bit odd, but no other country figues would exsit in this upgrade

      function FindBalancesForPeriod( BalList : TBalances_List; FromDate : integer; ToDate : integer) : pBalances_Rec;
      var
         BalanceRec : pBalances_Rec;
         i          : integer;
      begin
         result := nil;
         with BalList do for i := 0 to Pred( itemCount ) do begin
            BalanceRec := Balances_At( i );
            with BalanceRec^ do begin
               If ( blGST_Period_Starts = FromDate ) and
                  ( blGST_Period_Ends   = ToDate ) then begin
                     result := BalanceRec;
                     exit;
                  end;
               end;
         end;
      end;

      function IsQuarterlyStatement( PeriodFromDate : integer) : boolean;
      var
         d1, diffMth, y1       : integer;
         StartDate  : integer;
      begin
         //see if the month should be a quarterly return
         StartDate := DMYTostDate( 1, aClient.clFields.clGST_Start_Month, DefaultYear, BKDATEEPOCH );
         //Figure out if this is a quarter month
         //calc months between first month specified in clgst_starts and clgst_period_starts.
         //if mod 3 = 0 then this is a quarter.
         DateDiff( StartDate, PeriodFromDate, d1, diffmth, y1 );
         if ( PeriodFromDate < StartDate) then
            //need to sub one because begin of current mth to end of prev is 0 mths
            IsQuarterlyStatement := (( diffMth - 1) mod 3 = 0)
         else
            //need to add one because begin of current mth to end is 1 mth
            IsQuarterlyStatement := (( diffMth + 1) mod 3 = 0);
      end;

      function PeriodHasValues( pBalRec : pBalances_Rec) : boolean;
      begin
         result := false;
         with pBalRec^ do begin
            if
              ( blBAS_G7_GST_Adj_Assets  <> 0) or
              ( blBAS_G18_GST_Adj_Entertain <> 0) or
              ( blBAS_W1_GST_Adj_Change  <> 0) or
              ( blBAS_W2_GST_Adj_Exempt  <> 0) or
              ( blBAS_W3_GST_Adj_Other  <> 0) or
              ( blBAS_W4_GST_Cdj_BusUse  <> 0) or
              ( blBAS_T1_VAT1_GST_Cdj_PAssets  <> 0) or
              ( blBAS_T2_VAT2_GST_Cdj_Change  <> 0) or
              ( blBAS_T3_VAT3_GST_Cdj_Other  <> 0) or
              ( blBAS_T4  <> 0) or
              ( blBAS_F1_GST_Closing_Debtors_BalanceA  <> 0) or
              ( blBAS_F2_GST_Opening_Debtors_BalanceB  <> 0) or
              ( blBAS_F3  <> 0) or
              ( blBAS_F4  <> 0) or
              ( blBAS_1C_PT_Last_Months_Income  <> 0) or
              ( blBAS_1E_PT_Assets  <> 0) or
              ( blBAS_1D_PT_Branch_Income  <> 0) or
              ( blBAS_1F_PT_Tax  <> 0) or
              ( blBAS_1G_PT_Refund_Used  <> 0) or
              ( blBAS_5B_PT_Ratio  <> 0) or
              ( blBAS_6B_GST_Adj_PrivUse  <> 0) or
              ( blBAS_7_VAT4_GST_Adj_BAssets   <> 0)
            then result := true;
         end;
      end;

   var
      NewList     : TBalances_List;
      NewBalances : pBalances_Rec;
      B           : integer;
      Balances    : pBalances_Rec;
      ExistingQtr : pBalances_Rec;
      PrevMonthBals : pBalances_Rec;
      d1,m1,y1    : integer;
      d2,m2,y2    : integer;
      QuarterlyFromDate : integer;
      MonthHasValues    : boolean;
      QuarterHasValues  : boolean;
      ReplaceQtr        : boolean;
      LastMonthFrom       : integer;
      LastMonthTo         : integer;
   begin
      if aClient.clFields.clCountry <> whAustralia then exit;

      //search thru list looking for monthly periods which need to be re-dated
      //with actual quarterly date range
      NewList := TBalances_List.Create;
      with aClient.clBalances_List do for B := 0 to Pred( itemCount ) do begin
         Balances := Balances_At( B );
         with Balances^ do begin
            //see if these balances are for a monthly date range
            StDateToDMY( blGST_Period_Starts, d1, m1, y1);
            StDateToDMY( blGST_Period_Ends, d2, m2, y2);
            if ( m1 = m2) and IsQuarterlyStatement( blGST_Period_Starts) then begin
               //change fromdate to match quarterly from date
               QuarterlyFromDate := IncDate( blGST_Period_Ends + 1, 0, -3, 0);
               ExistingQtr := FindBalancesForPeriod( NewList, QuarterlyFromDate, blGST_Period_Ends);
               if Assigned( ExistingQtr) then begin
                  //need to decide if should replace the existing quarterly date info
                  //with the quarterly date info from this month
                  MonthHasValues   := PeriodHasValues( Balances);
                  QuarterHasValues := PeriodHasValues( ExistingQtr);
                  ReplaceQtr       := false;
                  if ( MonthHasValues and ( not QuarterHasValues)) then
                     ReplaceQtr := true;
                  //if (( not MonthHasValues) and ( QuarterHasValues)) then
                  //   Replace := false;
                  //if (( not MonthHasValues) and ( not QuarterHasValues)) then
                  //   Replace := false;
                  if ( MonthHasValues) and ( QuarterHasValues) then begin
                     //need to decide which month to pick, try to find prev
                     //monthly period, if not there assume should be on quarterly
                     //otherwise pick monthly
                     LastMonthFrom := IncDate( blGST_Period_Starts, 0, -1, 0);
                     LastMonthTo   := blGST_Period_Starts - 1;
                     PrevMonthBals := FindBalancesForPeriod( NewList, LastMonthFrom, LastMonthTo);
                     ReplaceQtr    := Assigned( PrevMonthBals);
                  end;
                  //remove existing quarter and replace with monthly totals
                  if ReplaceQtr then begin
                     NewList.DelFreeItem( ExistingQtr);
                     NewBalances := New_Balances_Rec;
                     //copy values from existing rec
                     CopyVersion50BalanceRec( Balances, NewBalances);
                     NewBalances^.blGST_Period_Starts := QuarterlyFromDate;
                     //check for existing quarterly period
                     NewList.Insert( NewBalances);
                  end;
               end
               else begin
                  //no duplicate found so insert
                  NewBalances := New_Balances_Rec;
                  //copy values from existing rec
                  CopyVersion50BalanceRec( Balances, NewBalances);
                  NewBalances^.blGST_Period_Starts := QuarterlyFromDate;
                  //check for existing quarterly period
                  NewList.Insert( NewBalances);
               end;
            end
            else begin
               //put copy of existing balance rec into new list
               NewBalances := New_Balances_Rec;
               CopyVersion50BalanceRec( Balances, NewBalances);
               NewList.Insert( NewBalances);
            end;
         end;  //with Balances^
      end;
      //replace existing list with upgraded list
      aClient.clBalances_List.Free;
      aClient.clBalances_List := NewList;
   end;

   procedure UpgradeToVersion55;
   begin
      if aClient.clFields.clEmail_Scheduled_Reports then
         aClient.clFields.clEmail_Report_Format := rfFixedWidth;
   end;

   procedure UpgradeToVersion56;
   //the annual option will be replaced by two new reports that list annual gst
   begin
      if aClient.clFields.clCountry = whAustralia then begin
         if aClient.clFields.clBAS_PAYG_Withheld_Period = gpAnnually then
            aClient.clFields.clBAS_PAYG_Withheld_Period := gpQuarterly;

         if aClient.clFields.clGST_Period = gpAnnually then
            aClient.clFields.clGST_Period := gpQuarterly;
      end;
   end;

   procedure UpgradeToVersion60;
   //Statement Details and GL Narration have been added.  The existing narration,
   //other party and particulars should be copied into both new fields.
   var
      c          : integer;
      b, t       : integer;
      pT         : pTransaction_Rec;
      S          : string;
      ColOrder   : byte;
   begin
      //fill new Statement details and GL narration fields
      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
            //cycle thru each bank account, only include bank accounts!
            if baFields.baAccount_Type <> btBank then Continue;
            //cycle thru each transaction
            for t := 0 to Pred( baTransaction_List.ItemCount) do begin
               pT := baTransaction_List.Transaction_At( t);
               with pT^ do begin
                  S := '';
                  case aClient.clFields.clCountry of
                     whNewZealand : S := MakeStatementDetails( baFields.baBank_Account_Number,
                                                               pT^.txOther_Party,
                                                               pT^.txParticulars);
                     whAustralia  : S := pT^.txOld_Narration;
                  end;
                  pT^.txStatement_Details := S;
                  pT^.txGL_Narration      := S;

                  pT^.txOld_Narration         := '';   //clear out old AU narration field
               end;
            end;
         end;
      end;

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //insert the new columns
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      //            CodingFrm.pas constants
      // ceNarration      = 6;    {oz}
      // ceOtherParty     = 7;    {nz}
      // ceParticulars    = 8;    {nz}
      // ceStatementDetails = 17;    ceMax = 17;

      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
           //insert the Narration col for NZ clients, insert after the particulars field
           if aClient.clFields.clCountry = whNewZealand then begin
             ColOrder := baFields.baColumn_Order[  8] + 1;
             for c := 0 to 32 do begin
                if baFields.baColumn_Order[ c] >= ColOrder then
                   baFields.baColumn_Order[ c] := baFields.baColumn_Order[ c] + 1;
             end;
             //now set up defaults for narration column
             baFields.baColumn_Order[ 6]           := ColOrder;
             baFields.baColumn_Width[ 6]           := baFields.baColumn_Width[ 7] + baFields.baColumn_Width[ 8];
             baFields.baColumn_is_Hidden[ 6]       := false;
             baFields.baColumn_Is_Not_Editable[ 6] := false;

             //hide other party and particulars columns for NZ by default
             baFields.baColumn_Is_Hidden[ 7]       := true;
             baFields.baColumn_Is_Hidden[ 8]       := true;
           end;

           //insert Statement Details Column before the narration col for AU and
           //before the other party field for NZ
           case aClient.clFields.clCountry of
             whNewZealand : ColOrder := baFields.baColumn_Order[  7]; //other party
             whAustralia  : ColOrder := baFields.baColumn_Order[  6]; //narration
           else
             ColOrder := baFields.baColumn_Order[  7];
           end;

           //if col order is 0 then assume that account has never been viewed in CES
           if ColOrder > 0 then begin
             for c := 0 to 32 do begin
               if baFields.baColumn_Order[ c] >= ColOrder then
                  baFields.baColumn_Order[ c] := baFields.baColumn_Order[ c] + 1;
             end;
             //now set up defaults for statement details column
             baFields.baColumn_Order[ 17] := ColOrder;
             baFields.baColumn_Width[ 17] := 150;
             baFields.baColumn_is_Hidden[ 17] := true;
             baFields.baColumn_Is_Not_Editable[ 17] := false;
           end;
         end;
      end;
   end;

   procedure UpgradeToVersion62;
   //Statement Details and GL Narration have been added.  The existing narration,
   //other party and particulars should be copied into both new fields.
   var
      b, t       : integer;
      pT         : pTransaction_Rec;
      pD         : pDissection_Rec;
   begin
      //copy existing dissection narrations to new GL narration
      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
            //cycle thru each transaction
            for t := 0 to Pred( baTransaction_List.ItemCount) do begin
               pT := baTransaction_List.Transaction_At( t);
               pD := pT^.txFirst_Dissection;
               while (pD <> nil) do begin
                  pD^.dsGL_Narration  := pD^.dsOld_Narration;
                  pD^.dsOld_Narration := '';  //clear out older field
                  pD := pD^.dsNext;
               end;
            end;
         end;
      end;
   end;

   procedure TrimPayeeNames;
   //upgrade payee names, payee names should be trimmed, because they were
   //not it is possible to create names that look the same but refer to diff
   //payee numbers, this causes a problem for bconnect
   var
     i            : integer;
     pPayee       : pPayee_Rec;
     NewPayeeList : TPayee_List_V53;

     NewName      : string;
     OldName      : string;
   begin
     NewPayeeList := TPayee_List_V53.Create;
     while ( aClient.clPayee_List_V53.ItemCount > 0) do
     begin
       //always take item at top of list
       pPayee := aClient.clPayee_List_V53.Payee_At( 0);
       //make sure the name is not already there
       OldName := Trim( pPayee^.pyName);
       NewName := OldName;
       i := 1;
       while ( NewPayeeList.Find_Payee_Name( NewName) <> nil) do begin
         NewName := OldName + inttostr( i);
         Inc( i);
       end;
       //delete from old list, add to new
       aClient.clPayee_List_V53.Delete( pPayee);
       pPayee.pyName := NewName;
       NewPayeeList.Insert( pPayee);
     end;
     //dispose of old list and assign new
     aClient.clPayee_List_V53.Free;
     aClient.clPayee_List_V53 := NewPayeeList;
   end;

   procedure UpgradeToVersion64;
   //copy to payee name into the narration fields for each payee
   //only copy if something is in the account code field.
   var
      p  : integer;
      i  : integer;
      pP : pPayee_Rec;
   begin
      TrimPayeeNames;
      with aClient.clPayee_List_V53 do begin
         for p := 0 to Pred( ItemCount) do begin
            pP := Payee_At( p);
            for i := 1 to Max_py_lines_V53 do begin
               if pP^.pyAccount[ i] <> '' then
                  pP^.pyGL_Narration[ i] := Trim( pP^.pyName);
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion65;
   //map old report groups in chart to new report groups.
   //map the retained earnings report group to equity
   var
      a : integer;
      pA : pAccount_Rec;
   begin
      with aClient.clChart do begin
         for a := 0 to Pred( ItemCount) do begin
            pA := Account_At( a);
            if pA^.chAccount_Type = atRetainedPorL then
               pA^.chAccount_Type := atEquity;
         end;
      end;
   end;

   procedure UpgradeToVersion66;
   //added a new reporting year start variable so copy across old Fin Year
   //set the report group for all accounts that are used as a bank contra to
   //bank account
   var
     i : integer;
     pAcct : pAccount_Rec;
   begin
     //update report start year
     aClient.clFields.clReporting_Year_Starts := aClient.clFields.clFinancial_Year_Starts;

     //update contra bank accounts
     for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
       with aClient.clBank_Account_List.Bank_Account_At( i) do begin
         if baFields.baAccount_Type = btBank then begin
           pAcct := aClient.clChart.FindCode( baFields.baContra_Account_Code);
           if Assigned( pAcct) and ( pAcct^.chAccount_Type <> atBankAccount) then
             pAcct^.chAccount_Type := atBankAccount;
         end;
       end;
     end;

     //update gst contra account types
     for i := 1 to Max_GST_Class do begin
       if (aClient.clFields.clGST_Account_Codes[ i] <> '') then begin
         pAcct := aClient.clChart.FindCode( aClient.clFields.clGST_Account_Codes[ i]);
         if Assigned( pAcct) and ( pAcct^.chAccount_Type <> atGSTPayable) then
           pAcct^.chAccount_Type := atGSTPayable;
       end;
     end;
   end;

   procedure UpgradePre67SubGroups;
   //version 70 represents a major change in how sub groups are stored.
   //SG's were previously stored for each report group.  Each RG (report group)
   //having 9 sub groups.
   //In 5.2.0.3x forward the sub groups will be set the same for all report groups

      //taken from CFUtils.pas
      function CFTS2Int( Const AType, ASubType : Integer ): Integer;
      Const
         SATypeError    = 'Account Type %d out of range in %s';
         SASubTypeError = 'Account Subtype %d out of range in %s';
      Begin
         Assert( AType    in [ 1..18 ]);
         Assert( ASubType in [ 0..10 ]);
         Result := 11 * ( Pred ( AType ) ) + ASubType ;
      end;

   const
     MaxReportGroupInVer66 = 18;
     MaxSubgroupInVer66    = 9;
   var
     ReportGroupNo : integer;
     SubGroupNo    : integer;
     i             : integer;
     NewHeading    : string;
     SubGroupHeading : string;
     SubGroupsUsed : boolean;
     SubGroupsAllSame : boolean;
     NewSubGroupNo : integer;
     pAcct         : pAccount_Rec;
     j             : integer;
   begin
     with aClient.clFields do begin
       //first determine if sub groups are used
       SubGroupsUsed := False;
       //clGraph_Headings renamed from clOld_Report_Headings
       for i := Low(clGraph_Headings) to High(clGraph_Headings) do
         if clGraph_Headings[i] <> '' then
           SubGroupsUsed := True;

       //determine if all sub groups are set the same
       SubGroupsAllSame := True;
       SubGroupNo := 0;
       while ( SubGroupNo < MaxSubgroupInVer66) and ( SubGroupsAllSame) do begin
         SubGroupHeading := clGraph_Headings[ CFTS2Int( 1, SubGroupNo)];
         for ReportGroupNo := 2 to  MaxReportGroupInVer66 do begin
           if clGraph_Headings[ CFTS2Int( ReportGroupNo, SubGroupNo)] <> SubGroupHeading then
             SubGroupsAllSame := False;
         end;
         Inc( SubGroupNo);
       end;

       //if sub groups are not used then nothing to do
       if not SubGroupsUsed then Exit;

       //if the sub groups are all the same then can just store the sub groups
       //once, for report group 0, use report group 1 for names
       if SubGroupsAllSame then begin
         for SubGroupNo := 0 to MaxSubGroupInVer66 do begin
           NewHeading := clGraph_Headings[ CFTS2Int( 1, SubGroupNo)];
           aClient.clCustom_Headings_List.Set_SubGroup_Heading( SubGroupNo, NewHeading);
         end;
       end
       else
       begin
         //sub groups are used, but are different
         //store sub groups headings for each report group, map opening/closing
         //stock to purchases

         //set tag variable to current sub group. we will use this to temporarily
         //store the new sub group no.
         for j := aClient.clChart.First to aClient.clChart.Last do begin
           aClient.clChart.Account_At(j)^.chTemp_Tag := aClient.clChart.Account_At(j)^.chSubtype;
         end;
         NewSubGroupNo := 1;

         for ReportGroupNo := 1 to MaxReportGroupInVer66 do
         begin
           if ReportGroupNo in [ atOpeningStock, atClosingStock] then
           begin
             //do nothing. these groups will be mapped by purchases
           end
           else
           begin
             //assign report group name to a sub group to make list easy to read
             NewHeading := '** ' + atNames[ ReportGroupNo]+ ' **';
             aClient.clCustom_Headings_List.Set_SubGroup_Heading( NewSubGroupNo, NewHeading);
             Inc( NewSubGroupNo);

             //copy each report group heading, and map account codes
             for SubGroupNo := 1 to MaxSubGroupInVer66 do
             begin
               NewHeading := clGraph_Headings[ CFTS2Int( ReportGroupNo, SubGroupNo)];
               aClient.clCustom_Headings_List.Set_SubGroup_Heading( NewSubGroupNo, NewHeading);

               //change settings in chart from old sub group no to new sub group no
               //store the new sub group no in chTemp_Tag and update the
               //new sub group number once all have been assigned

               for j := aClient.clChart.First to aClient.clChart.Last do
               begin
                 pAcct := aClient.clChart.Account_At(j);

                 if ( ReportGroupNo <> atPurchases) then
                 begin
                   if (pAcct^.chAccount_Type = ReportGroupNo) and (pAcct^.chSubtype = SubGroupNo) then
                   begin
                     pAcct^.chTemp_Tag := NewSubGroupNo;
                   end;
                 end
                 else
                 begin
                   //special case - Report Group = Purchases

                   //BK5.2 forces the sub groups for purchases, opening stock and closing stock
                   //to be the same so that the COGS section can be displayed correctly.
                   //Therefore we only copy the sub groups for purchases, and assign these to
                   //opening and closing stock as well
                   if (pAcct^.chAccount_Type in [atPurchases, atOpeningStock, atClosingStock]) and
                      (pAcct^.chSubType = SubGroupNo) then
                   begin
                     pAcct^.chTemp_Tag := NewSubGroupNo;
                   end;
                 end;
               end;
               //move on to next number
               Inc(NewSubGroupNo);
             end;
           end;
         end;

         //assign new sub group numbers
         for j := aClient.clChart.First to aClient.clChart.Last do
         begin
           aClient.clChart.Account_At(j)^.chSubType := aClient.clChart.Account_At(j)^.chTemp_Tag;
         end;
       end;
     end;  //with

     //clean out the old array
     for i := Low( aClient.clFields.clGraph_Headings) to High( aClient.clFields.clGraph_Headings) do
       aClient.clFields.clGraph_Headings[ i] := '';
   end;

   procedure UpgradeSubGroups_V67_to_V70;
   //this routine upgrade version 67 to 70, which were internal alpha versions only
   //the upgrade process was changed in v71.

   //the simplist way to do this is delete all of the existing sub groups and setup
   //some defaults
   //this will only affect internal clients as no customers ever received alpha versions
   var
     i : integer;
   begin
     aClient.clCustom_Headings_List.FreeAll;
     for i := 1 to 9 do begin
       aClient.clCustom_Headings_List.Set_SubGroup_Heading( i, 'Sub Group ' + inttostr( i));
     end;
   end;

   procedure UpgradeToVersion67;
   begin
       UpgradePre67SubGroups;
   end;

   procedure UpgradeToVersion70;
   var
     d,m,y : integer;
   begin
     with aClient.clFields do
     begin
       if clFinancial_Year_Starts <> 0 then
       begin
         //make sure starts on 1st of month
         StDateToDMY( clFinancial_Year_Starts, d, m, y);
         clFinancial_Year_Starts := DMYToStDate( 1, m, y, bkDateEpoch);

         clLast_Financial_Year_Start := GetPrevYearStartDate( clFinancial_Year_Starts);
       end;
     end;
   end;

   procedure UpgradeToVersion71;
   begin
     //upgrade sub groups if upgrading from an alpha version of 5.2
     if (Initial_Version in [67..70]) then begin
       //the way that sub groups were upgraded changed in version 71.  This routine
       //upgrade sub groups that were upgraded by versions 67..70.
       //version 67 to 70 were alpha version of 5.2.0.
       UpgradeSubGroups_V67_to_V70;
     end;
   end;

   procedure UpgradeToVersion72;

     function TranslateReportGroup( OldNo : integer) : integer;
     begin
       Result := OldNo;
       case OldNo of
         19 : Result := 5;
         20 : Result := 4;
         21 : Result := 19;
         22 : Result := 20;
         23 : Result := 21;
         24 : Result := 22;
         25 : Result := 23;
         26 : Result := 24;
       end;
     end;

   var
     i : integer;
     p : pAccount_Rec;
   begin
     //previous alpha version had report groups for other dr, other income,
     //other cr, and other expenses.  The other dr/cr groups are not needed so
     //remove from list
     if (Initial_Version in [67..71]) then begin
       for i := aClient.clChart.First to aClient.clChart.Last do begin
         p := aClient.clChart.Account_At(i);
         p^.chAccount_Type := TranslateReportGroup( p^.chAccount_Type);
       end;
     end;
   end;

   procedure UpgradeToVersion73;
   //need to upgrade the divisions
   var
     i : integer;
   begin
     for i := 1 to 9 do begin
       //store in new structure
       if aClient.clFields.clOld_Division_Names[ i] <> '' then
         aClient.clCustom_Headings_List.Set_Division_Heading( i, aClient.clFields.clOld_Division_Names[ i]);
       //clean out old structure
       aClient.clFields.clOld_Division_Names[ i] := '';
     end;
   end;

   procedure UpgradeToVersion75;
   //need to set the tax interface settings
   begin
     if aClient.clFields.clCountry = whAustralia then
     begin
       if aClient.clFields.clAccounting_System_Used in [ saSolution6MAS42, saSolution6CLS3,
                                                         saSolution6CLS4,  saSolution6MAS41,
                                                         saSolution6CLSY2K ] then
       begin
         aClient.clFields.clTax_Interface_Used := BKCONST.tsBAS_Sol6ELS;
         aClient.clFields.clSave_Tax_Files_To  := 'ELS\';
       end
       else
       begin
         aClient.clFields.clTax_Interface_Used := BKCONST.tsBAS_XML;
         aClient.clFields.clSave_Tax_Files_To  := 'XML\';
       end;
     end;
   end;

   procedure UpgradeToVersion76;
   const
     TaxInvoicePhrase = 'BNotes: Tax Invoice is available';
   var
     OldNote    : string;
     NewNote    : string;
     c, b, t    : integer;
     pT         : pTransaction_Rec;
     ColOrder   : integer;
   begin
     //copy existing dissection narrations to new GL narration
     with aClient.clBank_Account_List do
     begin
       for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do
       begin
         //cycle thru each bank account, only include bank accounts!
         if baFields.baAccount_Type <> btBank then Continue;
         //cycle thru each transaction
         for t := 0 to Pred( baTransaction_List.ItemCount) do
         begin
            //set flag for transaction where tax invoice has been added
            //to the front of normal notes
            pT := baTransaction_List.Transaction_At( t);
            OldNote := pT^.txNotes;
            if Pos( TaxInvoicePhrase, OldNote) = 1 then
            begin
              //strip tax inv from front
              NewNote := Trim( Copy( OldNote, Length( TaxInvoicePhrase) + 1, Length( OldNote)));
              pT^.txNotes := NewNote;
              pT^.txTax_Invoice_Available := True;
            end;
            //set the flag for where tax inv added to front of import notes
            if Pos( 'Tax Invoice Available', pT^.txECoding_Import_Notes) > 0 then
            begin
              pT^.txTax_Invoice_Available := True;
            end;
         end;

         //insert the tax invoice col after GST Amount,
         //codingform.ceGSTAmount = 11
         //           ceTaxInvoice     = 18
         //first find pos of gst amount
         ColOrder := baFields.baColumn_Order[  11] + 1;
         for c := 0 to 32 do begin
            if baFields.baColumn_Order[ c] >= ColOrder then
               baFields.baColumn_Order[ c] := baFields.baColumn_Order[ c] + 1;
         end;
         //now set up defaults for tax invoice column
         baFields.baColumn_Order[ 18]          := ColOrder;
         baFields.baColumn_Width[ 18]          := 55;
         baFields.baColumn_is_Hidden[18]       := true;
         baFields.baColumn_Is_Not_Editable[18] := false;

         //insert the balance col Amount,
         //codingform.ceAmount  = 5
         //           ceBalance = 19
         //first find pos of gst amount
         ColOrder := baFields.baColumn_Order[  5] + 1;
         for c := 0 to 32 do begin
            if baFields.baColumn_Order[ c] >= ColOrder then
               baFields.baColumn_Order[ c] := baFields.baColumn_Order[ c] + 1;
         end;
         //now set up defaults for tax invoice column
         baFields.baColumn_Order[ 19]          := ColOrder;
         baFields.baColumn_Width[ 19]          := 140;
         baFields.baColumn_is_Hidden[19]       := True;
         baFields.baColumn_Is_Not_Editable[19] := True;
       end;
     end;
   end;

   procedure UpgradeToVersion77;
   begin
     //upgrade to client coding report settings
     //set anomalies to uncoded
     if aClient.clFields.clCoding_Report_Entry_Selection = 2 then
       aClient.clFields.clCoding_Report_Entry_Selection := 1;


     //rsAnomalies = 3
     //rsDetailsOnly = 2
     //rsTwoCol = 1
     //rsStandard = 0
     if aClient.clFields.clCoding_Report_Style = 3 then
     begin
       //set anomalies style to standard, anomalies style removed in 5.2
       aClient.clFields.clCoding_Report_Style := rsStandard
     end
     else
     if aClient.clFields.clCoding_Report_Style = 2 then
     begin
       //set to standard, details only style removed in 5.2
       aClient.clFields.clCoding_Report_Style := rsStandard;
       aClient.clFields.clCoding_Report_Show_OP := False;
     end
     else
     if aClient.clFields.clCoding_Report_Style = rsStandard then
     begin
       aClient.clFields.clCoding_Report_Show_OP := True;
     end;

     with aClient.clFields do
       if not clCoding_Report_Style in [ rsMin..rsMax] then
         clCoding_Report_Style := rsStandard;
   end;


   procedure UpgradeToVersion80;
   begin
     //only trim payees if we havent already done so in v64 upgrade
     if Initial_Version > 64 then
       TrimPayeeNames;
   end;

   procedure UpgradeToVersion82;
   //this upgrade is to fix a problem in the offsite download code that was
   //introduced in 5.2.0.85.  A fix for the problem was released in 5.2.0.97
   //so this code is to catch any clients that did not upgrade to that release
   //the clSpare_Boolean_2 field was used in the 0.97 fix so we should reset
   //it to false

   //A bug in 5.2.0.85/94 meant that the reference field was not populated during
   //offsite downloads.  We can reconstruct the reference for all cheques that
   //do not have one
   var
     Ba      : TBank_Account;
     pT      : pTransaction_Rec;
     b       : integer;
     t       : integer;
   begin
     if aClient.clFields.cl520_Reference_Fix_Run then
       Exit;

     for b := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
     begin
        Ba := aClient.clBank_Account_List.Bank_Account_At( b);
        if Ba.baFields.baAccount_Type = btBank then
        begin
          for t := ba.baTransaction_List.First to ba.baTransaction_List.Last do
          begin
            pT := ba.baTransaction_List.Transaction_At( t);
            if (( aClient.clFields.clCountry = whAustralia) and ( pT^.txType = 1)) or
               (( aClient.clFields.clCountry = whNewZealand) and ( pT^.txType in [0,4..9])) then
            begin
              if ( pT^.txCheque_Number > 0) and ( pT^.txReference = '') then
                pT^.txReference := IntToStr( pT^.txCheque_Number);

              if ( pT^.txOriginal_Cheque_Number > 0) and ( pT^.txOriginal_Reference = '') then
                pT^.txOriginal_Reference := IntToStr( pT^.txOriginal_Cheque_Number);
            end;
          end;
        end;
     end;
   end;

   procedure UpgradeToVersion83;
   begin
     //Separated out settings for manual and scheduled coding report
     aClient.clFields.clScheduled_Coding_Report_Style := aClient.clFields.clCoding_Report_Style;
     aClient.clFields.clScheduled_Coding_Report_Sort_Order := aClient.clFields.clCoding_Report_Sort_Order;
     aClient.clFields.clScheduled_Coding_Report_Entry_Selection := aClient.clFields.clCoding_Report_Entry_Selection;
     aClient.clFields.clScheduled_Coding_Report_Blank_Lines := aClient.clFields.clCoding_Report_Blank_Lines;
     aClient.clFields.clScheduled_Coding_Report_Rule_Line := aClient.clFields.clCoding_Report_Rule_Line;
     aClient.clFields.clScheduled_Coding_Report_New_Page := aClient.clFields.clCoding_Report_New_Page;
     aClient.clFields.clScheduled_Coding_Report_Print_TI := aClient.clFields.clCoding_Report_Print_TI;
     aClient.clFields.clScheduled_Coding_Report_Show_OP := aClient.clFields.clCoding_Report_Show_OP;
   end;

   procedure UpgradeToVersion84;
   var
     i : Integer;
     BA : TBank_Account;
   begin
     with aClient.clBank_Account_List do
     begin
       for i := 0 to ItemCount-1 do
       begin
         BA := Bank_Account_At( i);
         if (Copy( BA.baFields.baBank_Account_Number, 1, 9) = 'TEMP A/C ') then
           BA.baFields.baIs_A_Manual_Account := True
         else
           BA.baFields.baIs_A_Manual_Account := False;
       end;
     end;
   end;

   //---------------------------------------------------------------------------
   // UpgradeToVersion85
   //
   // Update the budgets if they do not have a start date or name.
   //
   procedure UpgradeToVersion85;
   var
     i : Integer;
     BU : TBudget;
   begin
     with aClient.clBudget_List do
     begin
       for i := 0 to ItemCount-1 do
       begin
         BU := Budget_At(i);
         if (BU.buFields.buStart_Date = 0) then
           BU.buFields.buStart_Date := aClient.clFields.clFinancial_Year_Starts;
         if (BU.buFields.buName = '') then
           BU.buFields.buName := 'NONAME ' + IntToStr(i+1);
       end;
     end;
   end;

   procedure UpgradeToVersion87;
   //restrict analysis flag move from client level to account level
   var
     i : Integer;
     BA : TBank_Account;
   begin
     with aClient.clBank_Account_List do
     begin
       for i := 0 to ItemCount-1 do
       begin
         BA := Bank_Account_At( i);
         Ba.baFields.baAnalysis_Coding_Level := acEnabled;

         if Ba.baFields.baAccount_Type = btBank then
         begin
           if aClient.clFields.clOld_Restrict_Analysis_Codes then
             Ba.baFields.baAnalysis_Coding_Level := acRestrictedLevel1;
         end;
       end;
     end;
   end;

   procedure UpgradeToVersion89;
   //set/upgrade new memorisation fields, need to modify the mxMatch_On_Account
   //setting and set new line type setting to indicate whether an amount on a
   //line is $ or %
   var
      i,j,line       : integer;
      mem            : pMemorised_Transaction_Rec;
      OldMatchOnAmt  : byte;
      DefaultLineType : byte;
   begin
      with aClient.clBank_Account_List do begin
         for i := 0 to Pred( ItemCount) do with Bank_Account_At( i) do begin
            for j := 0 to Pred( baOld_Memorised_Transaction_List.ItemCount) do begin
               mem := baOld_Memorised_Transaction_List.Memorised_Transaction_At( j);
               //upgrade the match on amount setting
               //v52 values  0= No   1= Yes   2= $/%
               OldMatchOnAmt := mem^.mxMatch_on_Amount;
               case OldMatchOnAmt of
                 mxNo :   mem^.mxMatch_on_Amount := mxNo;
                 mxOld_Yes : mem^.mxMatch_on_Amount := mxAmtEqual;
                 mxOld_FixVbl : mem^.mxMatch_on_Amount := mxNo;
               else
                 mem^.mxMatch_on_Amount := mxNo;
               end;

               //new field, set the line type
               if OldMatchOnAmt = mxOld_Yes then
                 DefaultLineType := mltDollarAmt
               else
                 DefaultLineType := mltPercentage;

               //set default
               for line := 1 to 50 do
                 mem^.mxLine_Type[ line] := DefaultLineType;

               //override first line type if was %/$
               if OldMatchOnAmt = mxOld_FixVbl then
                 mem^.mxLine_Type[ 1] := mltDollarAmt;
            end;
         end;
      end;
   end;

   procedure UpgradeToVersion90;
   var
     OldPayee : pPayee_Rec;
     NewPayee : TPayee;
     NewPayeeLine : pPayee_Line_Rec;
     i,j      : integer;
   begin
     for i := aClient.clPayee_List_V53.First to aClient.clPayee_List_V53.Last do
       begin
         OldPayee := aClient.clPayee_List_V53.Payee_At(i);
         NewPayee := PayeeObj.TPayee.Create;

         NewPayee.pdFields.pdNumber := OldPayee.pyNumber;
         NewPayee.pdFields.pdName   := OldPayee.pyName;

         for j := 1 to Max_Py_Lines_V53 do
           begin
             if ( OldPayee.pyAccount[j] <> '') or ( j = 1) then
               begin
                 //assume is a valid line if account exists
                 NewPayeeLine := bkPLio.New_Payee_Line_Rec;
                 NewPayeeLine.plAccount := OldPayee.pyAccount[j];
                 NewPayeeLine.plPercentage := OldPayee.pyPercentage[j];
                 NewPayeeLine.plGST_Class := OldPayee.pyGST_Class[j];
                 NewPayeeLine.plGST_Has_Been_Edited := OldPayee.pyGST_Has_Been_Edited[j];
                 NewPayeeLine.plGL_Narration := OldPayee.pyGL_Narration[j];
                 NewPayeeLine.plLine_Type := pltPercentage;

                 NewPayee.pdLines.Insert( NewPayeeLine);
               end;
           end;
         aClient.clPayee_List.Insert( NewPayee);
       end;

     //verify upgrade
     Assert( aClient.clPayee_List.ItemCount = aClient.clPayee_List_V53.ItemCount, 'aClient.clPayee_List.ItemCount = aClient.clPayee_List_V53.ItemCount');
     aClient.clPayee_List.CheckIntegrity;

     //remove all items from the old list
     aClient.clPayee_List_V53.FreeAll;
   end;

   procedure UpgradeToVersion91;
   //move memorisations from old structure to new
   var
      i,j,line       : integer;
      OldMxRec       : pMemorised_Transaction_Rec;
      NewMem         : TMemorisation;
      NewMemLine     : pMemorisation_Line_Rec;
   begin
     for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
       with aClient.clBank_Account_List.Bank_Account_At( i) do
         begin
           for j := baOld_Memorised_Transaction_List.First to baOld_Memorised_Transaction_List.Last do
             begin
               OldMxRec := baOld_Memorised_Transaction_List.Memorised_Transaction_At( j);
               NewMem := TMemorisation.Create(nil);
               NewMem.mdFields.mdType := OldMxRec.mxType;

               NewMem.mdFields.mdAmount := OldMxRec.mxAmount;
               NewMem.mdFields.mdReference := OldMxRec.mxReference;
               NewMem.mdFields.mdParticulars := OldMxRec.mxParticulars;
               NewMem.mdFields.mdAnalysis := OldMxRec.mxAnalysis;
               NewMem.mdFields.mdOther_Party := OldMxRec.mxOther_Party;
               NewMem.mdFields.mdStatement_Details := OldMxRec.mxStatement_Details;
               NewMem.mdFields.mdNotes := OldMxRec.mxNotes;

               NewMem.mdFields.mdMatch_on_Amount := OldMxRec.mxMatch_on_Amount;
               NewMem.mdFields.mdMatch_on_Refce := OldMxRec.mxMatch_on_Refce;
               NewMem.mdFields.mdMatch_on_Particulars := OldMxRec.mxMatch_on_Particulars;
               NewMem.mdFields.mdMatch_on_Analysis := OldMxRec.mxMatch_on_Analysis;
               NewMem.mdFields.mdMatch_on_Other_Party := OldMxRec.mxMatch_on_Other_Party;
               NewMem.mdFields.mdMatch_On_Statement_Details := OldMxRec.mxMatch_On_Statement_Details;
               NewMem.mdFields.mdMatch_on_Notes := OldMxRec.mxMatch_on_Notes;

               for line := 1 to Max_mx_lines_V53 do
               begin
                 if (OldMxRec.mxAccount[line] <> '') then
                 begin
                   NewMemLine := BKMLIO.New_Memorisation_Line_Rec;
                   NewMemLine^.mlAccount := OldMxRec.mxAccount[line];
                   NewMemLine^.mlPercentage := OldMxRec.mxPercentage[line];
                   NewMemLine^.mlGST_Class := OldMxRec.mxGST_Class[line];
                   NewMemLine^.mlGST_Has_Been_Edited := OldMxRec.mxGST_Has_Been_Edited[line];
                   NewMemLine^.mlGL_Narration := OldMxRec.mxGL_Narration[line];
                   NewMemLine^.mlLine_Type := OldMxRec.mxLine_Type[line];
                   NewMem.mdLines.Insert( NewMemLine);
                 end;
               end;

               NewMem.mdFields.mdPayee_Number := OldMxRec.mxPayee_Number;
               NewMem.mdFields.mdFrom_Master_List := OldMxRec.mxFrom_Master_List;

               baMemorisations_List.Insert_Memorisation( NewMem);
             end;

           //verify upgrade
           Assert( baMemorisations_List.ItemCount = baOld_Memorised_Transaction_List.ItemCount);
           baMemorisations_List.CheckIntegrity;

           //remove items from old list
           baOld_Memorised_Transaction_List.FreeAll;
         end;
   end;

   procedure UpgradeToVersion97;
   begin
    aClient.clFields.clWeb_Export_Format := 255;
   end;

   procedure UpgradeToVersion104;
   var
    i: Integer;
    pM: pClient_Account_Map_Rec;
    pF: pClient_File_Rec;
    pSBA: pSystem_Bank_Account_Rec;
    BankLRN, ClientLRN: LongInt;
   begin
    // Build client account map for this client
    if Assigned(AdminSystem) then
    begin
      if AdminSystem.fdFields.fdMagic_Number = aClient.clFields.clMagic_Number then
      begin
        pF := AdminSystem.fdSystem_Client_File_List.FindCode(aClient.clFields.clCode);
        if Assigned(pF) then
        begin
          ClientLRN := pF.cfLRN;
          for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do
          begin
            pSBA := AdminSystem.fdSystem_Bank_Account_List.FindCode(aClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
            if Assigned(pSBA) then
            begin
              BankLRN := pSBA.sbLRN;
              if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(BankLRN, ClientLRN)) then
              begin
                pM := New_Client_Account_Map_Rec; 
                if Assigned(pM) then
                begin
                  pM.amClient_LRN := ClientLRN;
                  pM.amAccount_LRN := BankLRN;
                  pM.amLast_Date_Printed := pSBA.sbDate_Of_Last_Entry_Printed;
                  AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
   end;

   procedure UpgradeToVersion105;
   begin
    // Show contra summaries in ledger report by default
    aClient.clFields.clLedger_Report_Bank_Contra := Byte(bcTotal);
    aClient.clFields.clLedger_Report_GST_Contra := Byte(gcTotal);
    aClient.clFields.clLedger_Report_Show_Non_Trf := true;
   end;

   procedure UpgradeToVersion106;
   //move the new payee name column into position in the bank account layout
   //move after the existing payee col and shuffle all other columns
   var
     c, b    : integer;
     ColOrder   : integer;
   begin
     //copy existing dissection narrations to new GL narration
     with aClient.clBank_Account_List do
     begin
       for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do
       begin
         //cycle thru each bank account, only include bank accounts!
         if baFields.baAccount_Type <> btBank then Continue;

         //insert the payee name column after the payee column
         // cePayee          = 9;
         // cePayeeName      = 21;
         //first find pos of payee amount
         ColOrder := baFields.baColumn_Order[  9] + 1;
         for c := 0 to 32 do begin
            if baFields.baColumn_Order[ c] >= ColOrder then
               baFields.baColumn_Order[ c] := baFields.baColumn_Order[ c] + 1;
         end;
         //now set up defaults for tax invoice column
         baFields.baColumn_Order[ 21]          := ColOrder;
         baFields.baColumn_Width[ 21]          := 100;
         baFields.baColumn_is_Hidden[21]       := true;
         baFields.baColumn_Is_Not_Editable[21] := true;
       end;
     end;

     // Default the ledger "Include transferring journals" to be set
     aClient.clFields.clLedger_Report_Show_Non_Trf := True;
   end;

   // upgrade temp accounts to manual accounts
   procedure UpgradeToVersion113;
   var
    i: Integer;
   begin
     for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
       with aClient.clBank_Account_List.Bank_Account_At( i) do
       begin
        if baFields.baIs_A_Manual_Account then
        begin
          baFields.baManual_Account_Type := -1;
          baFields.baManual_Account_Institution := '';
        end;
       end;
   end;

   // change mem payee from 'one per mem' to 'one per line'
   procedure UpgradeToVersion114;
   var
    i, j, k: Integer;
    MemList: TMemorisations_List;
    Mem: TMemorisation;
    Line: pMemorisation_Line_Rec;
   begin
     for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
     begin
      MemList := aClient.clBank_Account_List.Bank_Account_At(i).baMemorisations_List;
      for j := MemList.First to MemList.Last do
      begin
        Mem := MemList.Memorisation_At(j);
        if Mem.mdFields.mdPayee_Number = 0 then Continue;
        for k := Mem.mdLines.First to Mem.mdLines.Last do
        begin
          Line := Mem.mdLines.MemorisationLine_At(k);
          Line.mlPayee := Mem.mdFields.mdPayee_Number;
        end;
        Mem.mdFields.mdPayee_Number := 0;
      end;
     end;
   end;

   procedure UpgradeToVersion117;
   begin
    if aClient.clFields.clCountry = whAustralia then
    begin
      if Assigned(AdminSystem) and (AdminSystem.fdFields.fdWeb_Export_Format = wfWebX) and (aClient.clFields.clWeb_Export_Format = wfWebX) then
        exit
      else if PRACINI_ShowAcclipseInOz then
        aClient.clFields.clWeb_Export_Format := wfWebX
      else
        aClient.clFields.clWeb_Export_Format := 255;
    end;
   end;

   // Change all manual accounts to have an M on the front
   procedure UpgradeToVersion119;
   var
    i: Integer;
    b: TBank_Account;
   begin
    aClient.clExtra.ceLocal_Currency_Code := whCurrencyCodes[ aClient.clFields.clCountry ];
    i := aClient.clBank_Account_List.First;
    while i <= aClient.clBank_Account_List.Last do
    begin
      b := aClient.clBank_Account_List.Bank_Account_At(i);
      if b.baFields.baIs_A_Manual_Account and (Length(b.baFields.baBank_Account_Number) > 0) and
         (Pos('M', b.baFields.baBank_Account_Number) <> 1) then
      begin
         aClient.clBank_Account_List.Delete(b);
         b.baFields.baBank_Account_Number := 'M' + Copy(b.baFields.baBank_Account_Number, 1, 19);
         if b.baFields.baCurrency_Code = '' then // may not have been set
            b.baFields.baCurrency_Code := aClient.clExtra.ceLocal_Currency_Code;
         aClient.clBank_Account_List.Insert(b);
         i := aClient.clBank_Account_List.First;
      end
      else
       Inc(i);
    end;
   end;

   // upgrade to 4d.p.
   // Turn of Notes while we are here #6640
   procedure UpgradeToVersion123;
   var
      pT : pTransaction_Rec;
      pD : pDissection_Rec;
      b, t, i, j : integer;
      M: TMemorisation;
      Line: pMemorisation_Line_Rec;
      p: TPayee;
      PLine: pPayee_Line_Rec;
   begin
      with aClient.clBank_Account_List do begin
         for b := 0 to Pred( ItemCount) do with Bank_Account_At(b) do begin
            //cycle thru each bank account, including all journals
            baFields.baDesktop_Super_Ledger_ID := -1;
            // Quantities
            for t := 0 to Pred( baTransaction_List.ItemCount) do begin
               pT := baTransaction_List.Transaction_At( t);
               with pT^ do begin
                  if txFirst_Dissection = nil then begin
                    pT^.txQuantity := pT^.txQuantity * 10;
                    pT^.txSF_Member_Account_ID:= -1;
                    pT^.txSF_Fund_ID          := -1;
                  end
                  else begin
                     pD := txFirst_Dissection;
                     while (pD <> nil) do with pD^ do begin
                        pD.dsQuantity := pD.dsQuantity * 10;
                        pD^.dsSF_Member_Account_ID:= -1;
                        pD^.dsSF_Fund_ID          := -1;
                        pD := pD^.dsNext;
                     end;
                  end;
               end;
            end;
            // Mems
            for t := baMemorisations_List.First to baMemorisations_List.Last do
            begin
              M := baMemorisations_List.Memorisation_At(t);
              for i := M.mdLines.First to M.mdLines.Last do
              begin
                Line := M.mdLines.MemorisationLine_At(i);
                if Line.mlLine_Type = mltPercentage then
                  Line.mlPercentage := Line.mlPercentage * 100;
              end;
            end;
         end;
      end;
      // Payees
      for i := aClient.clPayee_List.First to aClient.clPayee_List.Last do
      begin
        p := aClient.clPayee_List.Payee_At(i);
        for j := p.pdLines.First to p.pdLines.Last do
        begin
          PLine := p.pdLines.PayeeLine_At(j);
          if PLine.plLine_Type = pltPercentage then
            PLine.plPercentage := PLine.plPercentage * 100;
        end;
      end;
      // GST Rates
      For i := 1 to MAX_GST_CLASS do
      begin
        For j := 1 to MAX_VISIBLE_GST_CLASS_RATES do
          aClient.clFields.clGST_Rates[ i, j ] := aClient.clFields.clGST_Rates[ i, j ] * 100;
      end;
      // BAS Rules
      For i := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do
      begin
        aClient.clFields.clBAS_Field_Percent[ i] := aClient.clFields.clBAS_Field_Percent[ i] * 100;
      end;
   end;

   procedure UpgradeToVersion124;
   begin
     aClient.clFields.clAll_EditMode_DIS := PRACINI_DefaultDissectionMode = 0;
     aClient.clFields.clAll_EditMode_CES := PRACINI_DefaultCodeEntryMode = 0;
   end;

   procedure UpgradeToVersion127;
   var
    i: Integer;
   begin
     for i := btMin to btMax do
       aClient.clFields.clAll_EditMode_Journals[i] := True;
   end;

   procedure UpgradeToVersion136;
   var I, B: Integer;
       pD : PDissection_Rec;
   begin
      with aClient, clFields do begin
        if ClFile_Version < 134 then
           exit; // No Jobs so nothing to do
        // The Jobs are upgraded on read...

        with clBank_Account_List do
        for B := First to Last do with Bank_Account_At(B) do begin
            //cycle thru each bank account, including all journals
            for I := 0 to Pred( baTransaction_List.ItemCount) do
               with baTransaction_List.Transaction_At(I)^ do begin
                  if txAudit_Record_ID <> 0 then // Job LRN
                     txJob_Code := IntToStr(txAudit_Record_ID);

                  pD := txFirst_Dissection;
                  while assigned(Pd) do begin
                     if pD.dsAudit_Record_ID <> 0 then
                        pD.dsJob_Code := IntToStr(pD.dsAudit_Record_ID);
                     pd := PD.dsNext;
                  end;

               end;
        end; //Bank_Account
      end; //Client
   end;

   procedure UpgradeToVersion138;
   begin
     with aClient, clFields do begin
        clPractice_code := ''; // Was clUpgrade_server
     end;
   end;

   procedure RemoveEmptyPhantomJournals;
   //#1821 - remove empty journals
   var
    i, j: Integer;
    p: pTransaction_rec;
    b: TBank_Account;
    Removed: Boolean;
   begin
     i := 0;
     while i < aClient.clBank_Account_List.ItemCount do
     begin
       Removed := False;
       b := aClient.clBank_Account_List.Bank_Account_At(i);
       if b.IsAJournalAccount and (b.baFields.baAccount_Type <> btOpeningBalances) then
       begin
         // Remove phantom journal entries (no dissection)
         j := 0;
         while j < b.baTransaction_List.ItemCount do
         begin
           p := b.baTransaction_List.Transaction_At(j);
           if p.txFirst_Dissection = nil then
             b.baTransaction_List.Delete(p)
           else
             Inc(j);
         end;
         // Remove entire journal ba if empty
         if b.baTransaction_List.ItemCount = 0 then
         begin
           Removed := True;
           aClient.clBank_Account_List.DelFreeItem(b);
         end;
       end;
       if not Removed then
         Inc(I);
     end;
   end;

   procedure UpgradeToVersion139;
   var I, T: Integer;
       fs: pFuel_Sheet_Rec;
       p: pTransaction_rec;
       b: TBank_Account;
   begin
      // Fueltax defaults
      if  aClient.clFields.clCountry = whAustralia then begin

         // Change to 4 dp for Fuel credit rate
         for I := aClient.clBalances_List.First to aClient.clBalances_List.Last do
            with aClient.clBalances_List.Balances_At(I)^ do begin
               fs := blFirst_Fuel_Sheet;
               while assigned(fs) do begin
                  if fs.fsCredit_Rate <> 0 then
                     fs.fsCredit_Rate := fs.fsCredit_Rate * 10;
                  fs := fs.fsNext;
               end;
            end;
         // set Default Company tax
         with aClient.clExtra do begin
            ceTAX_Applies_From[tt_CompanyTax][1] := 146644; //01/07/2001
            ceTAX_Rates[tt_CompanyTax][1] := Double2GSTRate( 30.0);
         end;

         // Set manual Super...
         for I :=  aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
            b := aClient.clBank_Account_List.Bank_Account_At(I);
            if b.baFields.baAccount_Type = btBank then begin
               for T := b.baTransaction_List.First to b.baTransaction_List.Last do begin
                  p := b.baTransaction_List.Transaction_At(T);
                  if p.txSF_Super_Fields_Edited then
                     p.txCoded_By := cbManualSuper;
               end;
            end;
         end;

      end;
   end;

   procedure UpgradeToVersion140;
   //case 1908 clECoding_File_Attachments was renamed and repurposed to clSchedule_File_Attachments
   //so that you can attach files with any email destination of scheduled reports
   //However if they haven't selected BNotes before, we don't want files to suddenly be attached if
   //they had files attached for BNotes at a previous date.
   begin
      if not aClient.clFields.clEcoding_Export_Scheduled_Reports then
        aClient.clFields.clScheduled_File_Attachments := '';
   end;

   procedure UpgradeToVersion141;
   begin
     //Set Defaults
     aClient.clExtra.ceList_Entries_Sort_Order       := csDateEffective;
     aClient.clExtra.ceList_Entries_Include          := esUncodedOnly;
     aClient.clExtra.ceList_Entries_Two_Column       := false;
     aClient.clExtra.ceList_Entries_Show_Balance     := false;
     aClient.clExtra.ceList_Entries_Show_Notes       := false;
     aClient.clExtra.ceList_Entries_Wrap_Narration   := false;
     aClient.clExtra.ceList_Entries_Show_Other_Party := false;
   end;



   procedure UpgradeToVersion144;
   begin
     aClient.clExtra.ceBook_Gen_Finance_Reports := True;
   end;

   procedure UpgradeToVersion145;
   begin
     aClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles := False;
   end;

   procedure UpgradeToVersion149;
   begin
     aClient.clExtra.ceAllow_Client_Edit_Chart := True;
     aClient.clExtra.ceAllow_Client_Unlock_Entries := True;
   end;

   procedure UpgradeToVersion152;
   begin
     //Separated out settings for manual and scheduled custom coding report
     aClient.clExtra.ceScheduled_Custom_CR_XML := aClient.clExtra.ceCustom_Coding_Report_XML; 
   end;

   procedure UpgradeToVersion157;
   var
      i: Integer;
      b: TBank_Account;
      Country: Byte;
   begin
      Country := aClient.clFields.clCountry;
      aClient.clExtra.ceLocal_Currency_Code := whCurrencyCodes[ Country ];
      for I :=  aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
         b := aClient.clBank_Account_List.Bank_Account_At(I);
         b.baFields.baCurrency_Code := whCurrencyCodes[Country];
     end;
   end;

   procedure UpgradeToVersion163;
   var
     i, j: Integer;
     BA: TBank_Account;
     pT: pTransaction_Rec;
   begin
     for i :=  aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
       BA := aClient.clBank_Account_List.Bank_Account_At(i);
       if Assigned(BA) then begin
         if BA.IsAForexAccount then
           for j := BA.baTransaction_List.First to BA.baTransaction_List.Last do begin
             pT := BA.baTransaction_List.Transaction_At(j);
             pT.txAmount := pT.txSpare_Money_1; //txForeign_Currency_Amount
             pT.txSpare_Money_1 := 0;
             pT.txSpare_Money_2 := 0;
             //Reset Conversion Rates is not locked or transfered
             if (pT.txDate_Transferred = 0) or (not pT.txLocked) then
               pT.txForex_Conversion_Rate := 0;
           end;
       end;
     end;
   end;

  procedure UpgradeToVersion165;
  //Audit trail - adds audit ID values for existing records
  var
    i, j, k: Integer;
    BA: TBank_Account;
    TX: pTransaction_Rec;
    DS: pDissection_Rec;
    PD: TPayee;
    MD: TMemorisation;
    CHL: PCustom_Heading_Rec;
  begin
    if DebugMe then LogMsg( lmDebug, Unitname, 'Audit Trail Client Upgrade Start');
    //CL Client
    aClient.clExtra.ceAudit_Record_ID := 0;
    //CH Chart of Accounts
    for i := aClient.clChart.First to aClient.clChart.Last do
      aClient.clChart.Account_At(i).chAudit_Record_ID := aClient.NextAuditRecordID;
    //PY Payees
    for i := aClient.clPayee_List_V53.First to aClient.clPayee_List_V53.Last do
      aClient.clPayee_List_V53.Payee_At(i).pyAudit_Record_ID := aClient.NextAuditRecordID;
    //PD Payee Detail
    for i := aClient.clPayee_List.First to aClient.clPayee_List.Last do begin
      PD := aClient.clPayee_List.Payee_At(i);
      if Assigned(PD) then begin
        PD.pdFields.pdAudit_Record_ID := aClient.NextAuditRecordID;
        //PL Payee Lines
        for j := PD.pdLines.First to PD.pdLines.Last do
          PD.pdLines.PayeeLine_At(j).plAudit_Record_ID := aClient.NextAuditRecordID;
      end;
    end;
    //BA Bank Accounts
    for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
      BA := aClient.clBank_Account_List.Bank_Account_At(i);
      if Assigned(BA) then begin
        BA.baFields.baAudit_Record_ID := aClient.NextAuditRecordID;

        //Localise UK VAT journal names
        if (aClient.clFields.clCountry = whUK) then begin
          if (BA.baFields.baAccount_Type = btGSTJournals) then begin
            BA.baFields.baBank_Account_Number := Localise(aClient.clFields.clCountry,
                                                          BA.baFields.baBank_Account_Number);
            BA.baFields.baBank_Account_Name := Localise(aClient.clFields.clCountry,
                                                        BA.baFields.baBank_Account_Name);
          end;
        end;

        //TX Transactions
        for j := BA.baTransaction_List.First to BA.baTransaction_List.Last do begin
          TX := BA.baTransaction_List.Transaction_At(j);
          if Assigned(TX) then begin
            TX.txAudit_Record_ID := aClient.NextAuditRecordID;
            //DS Dissections
            DS := TX.txFirst_Dissection;
            while (DS <> nil) do begin
              DS.dsAudit_Record_ID := aClient.NextAuditRecordID;
              DS := DS.dsNext;
            end;
          end;
        end;
        //MD Memorisations
        for j := BA.baMemorisations_List.First to BA.baMemorisations_List.Last do begin
          MD := BA.baMemorisations_List.Memorisation_At(j);
          if Assigned(MD) then begin
            MD.mdFields.mdAudit_Record_ID := aClient.NextAuditRecordID;
            //ML Memorisation Lines
            for k := MD.mdLines.First to MD.mdLines.Last do
              MD.mdLines.MemorisationLine_At(k).mlAudit_Record_ID := aClient.NextAuditRecordID;
          end;
        end;
      end;
    end;
    //Balances
    for i := aClient.clBalances_List.First to aClient.clBalances_List.Last do
      aClient.clBalances_List.Balances_At(i).blAudit_Record_ID := aClient.NextAuditRecordID;

    //SubGroup Heading - not used
    //Division Heading - not used

    //Custom Heading
    for i := aClient.clCustom_Headings_List.First to aClient.clCustom_Headings_List.Last do begin
      CHL := PCustom_Heading_Rec(aClient.clCustom_Headings_List.Items[i]);
      if Assigned(CHL) then
        CHL.hdAudit_Record_ID := aClient.NextAuditRecordID;
    end;
    //Job Heading
    for i := aClient.clJobs.First to aClient.clJobs.Last do
      aClient.clJobs.Job_At(i).jhAudit_Record_ID := aClient.NextAuditRecordID;
    if DebugMe then LogMsg( lmDebug, Unitname, 'Audit Trail Client Upgrade Finish');

    //Reload the client copy so that anything changed from here on gets audited.
    aClient.ClientCopyReset;
  end;

  procedure UpgradeToVersion171;
  var
    Index: Integer;
    Payee: TPayee;
  begin
    for Index := aClient.clPayee_List.First to aClient.clPayee_List.Last do
    begin
      Payee := aClient.clPayee_List.Payee_At(Index);

      Payee.pdFields.pdContractor := False;
    end;
  end;

  procedure UpgradeToVersion174;
  begin
    aClient.clExtra.ceInclude_Unused_Chart_Codes := False;
    aClient.clExtra.ceInclude_Non_Posting_Chart_Codes := True;
  end;

  procedure UpgradeToVersion175;
  begin
    // Constants for clECoding_Import_Options were changed from 0,1,2 to 1,2,4 to fix a bug
    case aClient.clFields.clECoding_Import_Options of
      0: aClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
      1: aClient.clFields.clECoding_Import_Options := noFillWithNotes;
      2: aClient.clFields.clECoding_Import_Options := noFillWithBoth;
    end;
  end;

  procedure UpgradeToVersion181;
  begin
    UpgradeClient_Memorisation_EntryType(aClient);
  end;

  procedure UpgradeToVersion182;
  var
    PayeeIndex : integer;
    StateIndex : integer;
    CountryCode, CountryDesc : string;
    found : boolean;
  begin
    aClient.clTPR_Payee_Detail.As_pRec.prUsePracticeTPRSupplierDetails := true;
    aClient.clTPR_Payee_Detail.As_pRec.prFirstTimeTPRATOExtractDone := true;
    aClient.clTPR_Payee_Detail.As_pRec.prTRPATOReportRunUpToYear := 0;

    for PayeeIndex := 0 to aClient.clPayee_List.ItemCount-1 do
    begin
      found := false;
      aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdStateId := 0;
      for StateIndex := MIN_STATE to MAX_STATE do
      begin
        GetAustraliaStateFromIndex(StateIndex, CountryCode, CountryDesc);

        if Uppercase(aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdState) = uppercase(CountryCode) then
        begin
          aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdStateId := StateIndex;
          found := true;
          break;
        end;
      end;

      if not found then
      begin
        if Length(aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdState) = 0 then
        begin
          aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdStateId := MIN_STATE;
          aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdCountry := '';
        end
        else
        begin
          aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdStateId := MAX_STATE;
          aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdCountry :=
            aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdState;
        end;
      end;

      aClient.clPayee_List.Payee_At(PayeeIndex).pdFields.pdIsIndividual := true;
    end;
  end;

  procedure UpgradeToVersion183;
  begin
    aClient.clTPR_Payee_Detail.As_pRec.prTRPATOReportRunUpToYear := 0;
  end;

  procedure UpgradeToVersion184;
  begin
  end;

  function OneCharacterPhoneNumber(const aPhoneNumber: string): boolean;
  var
    chFirst: char;
    i: integer;
  begin
    result := false;

    if (aPhoneNumber = '') then
      exit;

    chFirst := aPhoneNumber[1];

    for i := 1 to Length(aPhoneNumber) do
    begin
      if (aPhoneNumber[i] <> chFirst) then
        exit;
    end;

    result := true;
  end;

  procedure UpgradeToVersion185;
  var
    i: integer;
    sPhoneNumber: string;
    Payee: TPayee;
  begin
    for i := 0 to aClient.clPayee_List.ItemCount-1 do
    begin
      Payee := aClient.clPayee_List.Payee_At(i);
      sPhoneNumber := Payee.pdFields.pdPhone_Number;
      if OneCharacterPhoneNumber(sPhoneNumber) then
        Payee.pdFields.pdPhone_Number := '';
    end;
  end;

  // Exception code for Suggested Mem only to be done after upgrade
  procedure UpgradeToVersion187;
  var
    AccIndex : integer;
    BankAcc : TBank_Account;
  begin
    for AccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAcc := aClient.clBank_Account_List.Bank_Account_At(AccIndex);
      BankAcc.baFields.baColumn_Order[ ceSuggestedMemCount] := 255;
    end;
  end;

  // Default Joutnal Report Parameters
  procedure UpgradeToVersion188;
  begin
    aClient.clExtra.ceList_Entries_Show_Summary := true;
  end;

begin
   with aClient.clFields do begin

      if not clEmpty_Journals_Removed then
      begin
        RemoveEmptyPhantomJournals;
        clEmpty_Journals_Removed := True;
      end;

      if clFile_Version = BKDEFS.BK_FILE_VERSION then
         exit;

      Initial_Version := clFile_Version;

      //this flag must be set to true so that the token for this field is written
      //out. this will cause a crash when opening this client file in a version
      //prior to 306. 306 introduced code to check the file version no. previous
      //versions dont have this so they must be forced to crash so that
      //GST_Class_Codes are not trashed
      clV31_GST_Format_Used  := true;

      //make sure the report start date is not 0
      if clReport_Start_Date = 0 then
            clReport_Start_Date := clFinancial_Year_Starts;

      if clFile_Version < 31 then begin
         UpgradeBefore31ToVersion36;
         //update file version.  this would normally upgrade to 31, however there
         //are some internal releases btwn 31 and 36 which will have been upgraded in
         //a different way
         clFile_Version     := 36;
      end;

      if clFile_Version < 36 then begin
         UpgradeAfter30ToVersion36;
         //update file version
         clFile_Version     := 36;
      end;

      if clFile_Version < 37 then begin
         //update to latest version.. check here that a gst effective date is set
         //if there are non-zero gst rates
         UpgradeToVersion37;
         clFile_Version := 37;
      end;

      //5.1.0.44 Beta - will upgrade versions > 5.1.0.37 Beta
      if clFile_Version < 41 then begin
         //update to latest version.. check here that a gst effective date is set
         //if there are non-zero gst rates
         UpgradeToVersion41;
         //introduced in 5.1.60.x - mem update fix
         UpgradeMemorisations;
         clFile_Version := 41;
      end;

      //5.1.60.1 - will upgrade version > 5.1.0.44 Beta
      if clFile_Version <  44 then begin
         UpgradeToVersion44;
         clFile_Version := 44;
      end;

      if clFile_Version < 46 then begin
         //set default gst class for payees
         UpgradeToVersion46;
         clFile_Version := 46;
      end;

      //5.1.60.5
      if clFile_Version < 49 then begin
         //set UPI_State values
         UpgradeToVersion49;
         clFile_Version := 49
      end;

      //5.1.60.9
      if clFile_Version < 50 then begin
         //upgrade the way that monthly bas figures have been stored
         UpgradeToVersion50;
         clFile_Version := 50;
      end;
      //5.1.62.7
      if clFile_Version < 55 then begin
         UpgradeToVersion55;
         clFile_Version := 55;
      end;
      //5.1.62.15
      if clFile_Version < 56 then begin
         UpgradeToVersion56;
         clFile_Version := 56;
      end;

      //5.2.0.1
      if clFile_Version < 60 then begin
         UpgradeToVersion60;
         clFile_Version := 60;
      end;

      if clFile_Version < 62 then begin
         UpgradeToVersion62;
         clFile_Version := 62;
      end;

      if clFile_Version < 64 then begin
         UpgradeToVersion64;
         clFile_Version := 64;
      end;

      if clFile_Version < 65 then begin
         UpgradeToVersion65;
         clFile_Version := 65;
      end;

      if clFile_Version < 66 then begin
         UpgradeToVersion66;
         clFile_Version := 66;
      end;

      if clFile_Version < 67 then begin
         UpgradeToVersion67;
         clFile_Version := 67;
      end;

      //5.2.0.32
      if clFile_Version < 70 then begin
         UpgradeToVersion70;
         clFile_Version := 70;
      end;

      if clFile_Version < 71 then begin
         UpgradeToVersion71;
         clFile_Version := 71;
      end;

      //5.2.0.33
      if clFile_Version < 72 then begin
         UpgradeToVersion72;
         clFile_Version := 72;
      end;

      if clFile_Version < 73 then begin
         UpgradeToVersion73;
         clFile_Version := 73;
      end;

      if clFile_Version < 75 then begin
         UpgradeToVersion75;
         clFile_Version := 75;
      end;

      if clFile_Version < 76 then begin
         UpgradeToVersion76;
         clFile_Version := 76;
      end;

      if clFile_Version < 77 then begin
         UpgradeToVersion77;
         clFile_Version := 77;
      end;

      if clFile_Version < 80 then begin
         UpgradeToVersion80;
         clFile_Version := 80;
      end;

      if clFile_Version < 82 then begin
         UpgradeToVersion82;
         clFile_Version := 82;
      end;

      if clFile_Version < 83 then
      begin
        //coding reports options split
        UpgradeToVersion83;
        clFile_Version := 83;
      end;

      if clFile_Version < 84 then
      begin
        UpgradeToVersion84;
        clFile_Version := 84;
      end;

      if clFile_Version < 85 then
      begin
        UpgradeToVersion85;
        clFile_Version := 85;
      end;

      if clFile_Version < 87 then
      begin
        UpgradeToVersion87;
        clFile_Version := 87;
      end;

      if clFile_Version < 89 then
      begin
        UpgradeToVersion89;
        clFile_Version := 89;
      end;

      if clFile_Version < 90 then
        begin
          UpgradeToVersion90;
          clFile_Version := 90;
        end;

      if clFile_Version < 91 then
        begin
          UpgradeToVersion91;
          clFile_Version := 91;
        end;

      if clFile_Version < 97 then
        begin
          UpgradeToVersion97;
          clFile_Version := 97;
        end;

      if clFile_Version < 104 then
        begin
          UpgradeToVersion104;
          clFile_Version := 104;
        end;

      if clFile_Version < 105 then
        begin
          UpgradeToVersion105;
          clFile_Version := 105;
        end;

      if clFile_Version < 106 then
        begin
          UpgradeToVersion106;
          clFile_Version := 106;
        end;

      if clFile_Version < 113 then
        begin
          UpgradeToVersion113;
          clFile_Version := 113;
        end;

      if clFile_Version < 114 then
        begin
          UpgradeToVersion114;
          clFile_Version := 114;
        end;

      if clFile_Version < 117 then
        begin
          UpgradeToVersion117;
          clFile_Version := 117;
        end;

      if clFile_Version < 119 then
        begin
          UpgradeToVersion119;
          clFile_Version := 119;
        end;

      if clFile_Version < 123 then
        begin
          UpgradeToVersion123;
          clFile_Version := 123;
        end;

      if clFile_Version < 124 then
        begin
          UpgradeToVersion124;
          clFile_Version := 124;
        end;

      if clFile_Version < 127 then
        begin
          UpgradeToVersion127;
          clFile_Version := 127;
        end;
      if (ClFile_Version < 136) then
        begin
          UpgradeToVersion136;
          clFile_Version := 136;
        end;
      if (ClFile_Version <138) then begin
         UpgradeToVersion138;
         clFile_Version := 138;
      end;
      if (ClFile_Version <139) then begin
         UpgradeToVersion139;
         clFile_Version := 139;
      end;
      if (ClFile_Version <140) then begin
         UpgradeToVersion140;
         clFile_Version := 140;
      end;
      if (ClFile_Version <141) then begin
         UpgradeToVersion141;
         clFile_Version := 141;
      end;

      if (CLFile_Version<144) then begin
        UpgradeToVersion144;
        clFile_Version := 144;
      end;

      if (CLFile_Version<145) then begin
        UpgradeToVersion145;
        clFile_Version := 145;
      end;

      if (CLFile_Version<149) then begin
        UpgradeToVersion149;
        clFile_Version := 149;
      end;

      if (CLFile_Version<152) then begin
        UpgradeToVersion152;
        clFile_Version := 152;
      end;
      // 2010 /Multi currency
      if (CLFile_Version<157) then begin
        UpgradeToVersion157;
        clFile_Version := 157;
      end;
      // 2011 /Multi currency
      if (CLFile_Version < 163) then begin
        UpgradeToVersion163;
        clFile_Version := 163;
      end;
      // 2011 Audit Trail
      if (CLFile_Version < 165) then begin
        UpgradeToVersion165;
        clFile_Version := 165;
      end;
      // 2012 Tagging
      if (CLFile_Version < 170) then
      begin
        clFile_Version := 170;
      end;
      // 2012 Post Tagging
      if (CLFile_Version < 171) then
      begin
        UpgradeToVersion171;
        clFile_Version := 171;
      end;
      // Non-Posting code changes
      if (CLFile_Version < 174) then
      begin
        UpgradeToVersion174;
        clFile_Version := 174;
      end;
      // Adding default for top group of radio buttons in ImportFromECodingDlg
      if (CLFile_Version < 175) then
      begin
        UpgradeToVersion175;
        clFile_Version := 175;
      end;
      // Memorisations, for 49:Withdrawal
      if (CLFile_Version < 181) then
      begin
        UpgradeToVersion181;
        clFile_Version := 181;
      end;

      // ATO Extract for TPR Reports
      if (CLFile_Version < 182) then
      begin
        UpgradeToVersion182;
        clFile_Version := 182;
      end;

      // ATO Extract for bug fix
      if (CLFile_Version < 183) then
      begin
        UpgradeToVersion183;
        clFile_Version := 183;
      end;

      // Fix for transactions from journals being added to the unscanned transaction
      // list for suggested mems in prior version
      if (CLFile_Version < 184) then
      begin
        UpgradeToVersion184;
        clFile_Version := 184;
      end;

      // Payee "clean up"
      if (CLFile_Version < 185) then
      begin
        UpgradeToVersion185;
        clFile_Version := 185;
      end;

      // Added column
      if (CLFile_Version < 187) then
      begin
        UpgradeToVersion187;
        clFile_Version := 187;
      end;

      // Defaults to Journal Report
      if (CLFile_Version < 188) then
      begin
        UpgradeToVersion188;
        clFile_Version := 188;
      end;
   end;
end;

procedure DoUpgradeExchangeRatesToLatestVersion(var UpgradingToVersion: integer;
  const OriginalVersion: integer; AExchangeSource: TExchangeSource;
  AExchangeRateList: TExchangeRateList);
const
   ThisMethodName = 'DoUpgradeExchangeRatesToLatestVersion';

  procedure  UpgradeExchangeRatesBefore101ToVersion102;
  begin
    AExchangeSource.AuditTrialID := AExchangeRateList.AuditMgr.NextAuditRecordID;
    //Add audit ID's to existing records
    AExchangeSource.Iterate(AddAuditIDs, True, @AExchangeRateList);
    //Merge into source
    AExchangeRateList.MergeSource(AExchangeSource);
    //Reload the exchange rates copy so that anything changed from here on gets audited.
    AExchangeRateList.ExchangeRateCopyReset;
    //Update version
    AExchangeSource.FileVersion := 102;
  end;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : Begins');
  try
    if (AExchangeSource.FileVersion < 102) then Begin
      UpgradingToVersion := 102;
      LogUtil.LogMsg(lmInfo, ThisMethodName, 'Upgrading Database  < 101 to 102');
      UpgradeExchangeRatesBefore101ToVersion102;
      LogUtil.LogMsg(lmInfo, ThisMethodName, 'Upgrade completed normally');
    end;
  finally
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : Ends');
    ClearStatus;
  end;
end;

function BackupExchangeRates: boolean;
var
  BkBackup: TBkBackup;
  BackupFilename: string;
  ExchangeRatesFilename: string;
  Msg: string;
begin
  Result := False;
  try
    ExchangeRatesFilename := DataDir + EXCHANGE_RATE_FILENAME;
    BackupFilename := ChangeFileExt(ExchangeRatesFilename, '.zip');
    BkBackup := TBkBackup.Create;
    try
      BkBackup.ZipFilename := Backup.ZipFilenameToUse(BackupFilename);
      BkBackup.FilesTypesToInclude := [biSpecifiedFile];
      BkBackup.FileToAdd := ExchangeRatesFilename;
      BkBackup.RootDir     := DataDir;
      BkBackup.OnProgressEvent := ShowBackupProgress;
      BkBackup.OnLogEvent      := LogBackupMessage;
      BkBackup.ZipFiles;
      Result := True;      
    finally
      BkBackup.Free;
      ClearStatus;
    end;
  except
    on E: Exception do begin
      Msg := Format('Exchange Rates Backup Failed. %s [%s]', [E.Message, E.Classname]);
      ShowMessage(Msg);
      LogMsg(lmError, Unitname, Msg);
    end;
  end;
end;

procedure UpgradeExchangeRatesToLatestVersion;
const
  ThisMethodName = 'UpgradeExchangeRatesToLatestVersion';
var
  OriginalVersion     : integer;
  UpgradingToVersion  : integer;
  ErrorMessage        : string;
  ExchangeRates: TExchangeRateList;
  ExchangeSource: TExchangeSource;
  Upgraded: Boolean;
begin
  Upgraded := False;
  //Load exchange rates info
  ExchangeRates := GetExchangeRates(True);
  try
    //Only upgrade if an exchange rate source exists
    if ExchangeRates.ItemCount > 0 then begin
      //We only have one Master exchage rate source at the moment
      ExchangeSource := ExchangeRates.GiveMeSource('Master');
      //See if it needs upgrading
      if (ExchangeSource.FileVersion <> MCDEFS.MC_FILE_VERSION) then begin
        LogUtil.LogMsg(lmInfo, ThisMethodName, 'Starting Upgrade');
        //Exchange rates still locked at this point
        OriginalVersion := ExchangeSource.FileVersion;
        LogUtil.LogMsg(lmInfo, ThisMethodName, 'Latest Exchange Rates Database Version: ' + IntToStr(MCDEFS.MC_FILE_VERSION));
        //Backup exchange rates
        if not BackupExchangeRates then begin
          ExchangeRates.Unlock;
          Application.Terminate;
          Halt;
        end;
        //Upgrade exchange rates
        Progress.UpdateAppStatus( 'Upgrading Exchage Rates', 'This process may take several minutes', 1, ProcessMessages_On);
        try
          try
            //upgrade
            //upgradingToVersion is set within DoUpgradeExchangeRatesToLatestVersion
            //so that we know what step we need to rollback from
            DoUpgradeExchangeRatesToLatestVersion(UpgradingToVersion, OriginalVersion, ExchangeSource, ExchangeRates);
            //Save will also unlock the exchange rates db
            ExchangeRates.Save;
            Upgraded := True;
          except
            on E : Exception do begin
              ErrorMessage := Format('Upgrade Failed [%s] Original ver = %d Upgrade reached ver %d',
                                     [E.Message, OriginalVersion, UpgradingToVersion]);
              LogUtil.LogMsg( lmInfo, ThisMethodName, ErrorMessage );
              //Raise exception
              raise Exception.Create( ErrorMessage);
            end;
          end;
        finally
          //clean up temp files
          Progress.ClearStatus;
        end;
      end;
    end;
  finally
    if not Upgraded then
      ExchangeRates.Unlock;
    ExchangeRates.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit( UnitName );
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
