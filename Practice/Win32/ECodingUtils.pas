unit ECodingUtils;

interface

uses clObj32, BKdefs, payeeObj;

   procedure UpdateTransGSTFields( aClient : TClientObj; pT : BKDEFS.pTransaction_Rec;
                                   BankPrefix : string;
                                   CodedBy: Byte);

   function UpdateNarration( const ImportOptions: Integer;
                             const ExistingNarration : string ;
                             PayeeDetail : string;
                             Notes : string) : string;

   function BK5DissectionMatchesBK5Payee( bkPayee : PayeeObj.TPayee;
                                          BKT     : bkDefs.pTransaction_Rec) : boolean;



   // Typicaly used for Re/ Imporing of Trf files
   Procedure UpdateNotes (pT: pTransaction_Rec; NewNotes : String);Overload;
   Procedure UpdateNotes (pD: pDissection_Rec;  NewNotes : String);Overload;

   procedure AddToImportNotes( pT : pTransaction_Rec; aMSg, aProduct : string); overload;
   procedure AddToImportNotes( pD : pDissection_Rec; aMSg, aProduct : string); overload;

   function  ExportECodingFileToFile( aClient : TClientObj; Dest : Byte) : boolean;

   procedure ImportECodingFileFromFile( aClient : TClientObj; var Filename : string; ConfirmFirst : Boolean; Dest: Byte);
   function CheckOutstandingEcodingFiles(aClient: TClientObj) : boolean;
implementation

uses
   UsageUtils,
    Classes, SysUtils, GenUtils, moneydef, bkconst, gstcalc32, ecObj,
     InfoMoreFrm, ErrorMoreFrm, WebXOffice, WebXUtils, glConst, WinUtils,
     ImportFromECodingDlg, ExportToECodingDlg, bkDateUtils, YesNoDlg,
     BNotesInterface, LogUtil, baObj32, GlobalDirectories, Globals,
     PracticeLogo, MailFrm, todoHandler, StDate, Windows,
     ClientHomepagefrm, Forms, Admin32, WebNotesDataUpload, WebNotesImportFrm,
     ForexHelpers, AuditMgr, Files, BanklinkOnlineServices,
     bkBranding, bkProduct;

const
   UnitName = 'ECodingUtils';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateTransGSTFields( aClient : TClientObj; pT : BKDEFS.pTransaction_Rec;
  BankPrefix : string; CodedBy: Byte);
var
 NewClass         : byte;
 NewGST           : money;
 IsEldersAccount  : boolean;
 IsActive         : boolean;
 txAccount        : boolean;
begin
 IsActive := True;
 with pT^ do begin
    if aClient.clChart.CanCodeTo( txAccount, IsActive) then begin
       IsEldersAccount := ( BankPrefix = EldersPrefix) and ( aClient.clFields.clCountry = whAustralia);
                                         // misc dr,  misc cr
       if not ( IsEldersAccount and ( txType in [9,10])) then begin
          //Assumes that Elders Account is never Forex and uses txAmount instead of Local_Amount
          CalculateGST( aClient, txDate_Effective, txAccount, txAmount, NewClass, NewGST);
          txGST_Class  := NewClass;
          txGST_Amount := NewGST;
          txCoded_By   := CodedBy;
          txGST_Has_Been_Edited := false;
       end
       else begin
          //special case - elders accounts receive transaction is strange way so
          //               GST needs to be blank by default
          //               Only if Misc Dr or Cr,  GST should still be calced
          //               on cheques.
          txGST_Class   := 0;
          txGST_Amount  := 0;
          txCoded_By    := CodedBy;
          txGST_Has_Been_Edited := true;
          pT^.txTransfered_To_Online := False;
       end;
    end
    else begin
       //note: Gst not cleared by an invalid account to allow independant editing of gst
       //      however it should be cleared if the account code has been deleted
       if ( txAccount = '' ) then begin
          txCoded_By        := cbNotcoded;
          txGST_Class       := 0;
          txGST_Amount      := 0;
          txHas_Been_Edited := false;
          txGST_Has_Been_Edited := false;
       end
       else begin
          //is an invalid code, just mark as manually coded so autocode doesnt
          //set to blank
          txCoded_By        := CodedBy;
       end;
    end;
 end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateNarration( const ImportOptions: Integer;
                          const ExistingNarration : string;
                          PayeeDetail : string;
                          Notes : string) : string;
//returns the updated narration.  This is determined using the options stored
//in the client file
var
  sPayeeDetail : string;
  sTrimmedNotes : string;
  sNewNarration : string;

  NarrationFillmode  : integer;
  OverwriteNarration : boolean;
  AppendNarration   : boolean;
begin
  result := ExistingNarration;

  NarrationFillMode := noDontFill;

  //set the narration file mode so that know what to do with narration and notes
  if ( ImportOptions = noDontFill) then
     NarrationFillMode := noDontFill
  else
  begin
     if ((ImportOptions and noFillWithPayeeName) = noFillWithPayeeName) then
       NarrationFillMode := noFillWithPayeeName;

     if ((ImportOptions and noFillWithNotes) = noFillWithNotes) then
       NarrationFillMode := noFillWithNotes;

     if ((ImportOptions and noFillWithBoth) = noFillWithBoth) then
       NarrationFillMode := noFillWithBoth;
  end;

  OverwriteNarration := not((ImportOptions and noDontOverwrite) = noDontOverwrite);
  AppendNarration    := ( ImportOptions and noAppend) = noAppend;

  sPayeeDetail    := Trim( PayeeDetail);
  sTrimmedNotes := GenUtils.StripReturnCharsFromString( Trim(Notes), ' ');

  if NarrationFillMode <> noDontFill then
  begin
     case NarrationFillMode of
        noFillWithPayeeName : sNewNarration := sPayeeDetail;
        noFillWithNotes     : sNewNarration := sTrimmedNotes;
        noFillWithBoth      : begin
           if sPayeeDetail = '' then
              sNewNarration := sTrimmedNotes
           else begin
              if sTrimmedNotes <> '' then
                 sNewNarration := sPayeeDetail + ' : ' + sTrimmedNotes
              else
                 sNewNarration := sPayeeDetail;
           end;
        end;
     end;
     sNewNarration := Trim( sNewNarration);

     if sNewNarration <> '' then
     begin
       if AppendNarration and ( ExistingNarration <> '') then
       begin
         result := Copy( ExistingNarration + ' : ' + sNewNarration, 1, 200);
         exit;
       end;

       if ( ExistingNarration = '') or OverwriteNarration then
       begin
         result := Copy( sNewNarration, 1, 200);
         exit;
       end;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BK5DissectionMatchesBK5Payee( bkPayee : PayeeObj.TPayee;
                                       BKT     : bkDefs.pTransaction_Rec) : boolean;
//matches the lines in the dissection with the lines in the payee.
//the match is done on account
var
  D : bkDefs.pDissection_Rec;
  Line : integer;
  PayeeLine : bkdefs.pPayee_Line_Rec;
begin
  result := true;

  D := BKT^.txFirst_Dissection;
  Line := 0;

  while ( D <> nil) do
    begin
      Inc( Line);
      D := D.dsNext;
    end;

  if Line = bkPayee.pdLines.ItemCount then
    begin
      D := BKT^.txFirst_Dissection;
      for line := bkPayee.pdLines.First to bkPayee.pdLines.Last do
        begin
          PayeeLine := bkPayee.pdLines.PayeeLine_At( Line);
          if PayeeLine.plAccount <> D.dsAccount then
            begin
              result := false;
              exit;
            end;
          D := D.dsNext;
        end;
    end
  else
    result := false;
end;


  // Local
  function Checkread ( var Old : String; New : String; Beenread : boolean ): Boolean;
  begin
     // existing blank, new not blank - replace with new
     if (Old = '') and (New <> '') then
     begin
       Old := New;
       result := false;
     end
     else if (Old <> '') and (New <> '') then
     begin
       // existing not blank, new not blank, same - do nothing
       if sametext(Old, New) then
         result := beenread
       else  // existing not blank, new not blank, different - append new
       begin
         if Pos(Old, New) = 1 then // dont append existing text
           Old := Old + ' ' + Copy(New, Length(Old)+1, Length(New))
         else
           Old := Old + ' ' + New;
         result := false;
       end;
     end
     else
       // existing not blank, new blank - do nothing
       // existing blank, new blank - do nothing
       result := beenread;
  end;
  (*
  function Checkread ( var Old : String; New : String; Beenread : boolean ): Boolean;
  begin // Check New
     result := beenread;
     if length(new) = 0 then Exit;  // Keep old notes.. and status
     result := false;
     Old := new;
  end;
   *)
procedure UpdateNotes (pT: pTransaction_Rec; NewNotes : String);
begin
   pT.txNotes_Read := CheckRead(pT.txNotes,NewNotes,pT.txNotes_Read);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateNotes (pD: pDissection_Rec;  NewNotes : String);
begin
  pD.dsNotes_Read := CheckRead(pD.dsNotes,NewNotes,pD.dsNotes_Read);
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddToImportNotes( pT : BKDEFS.pTransaction_Rec; aMSg, aProduct : string); overload;
begin
  if Trim( aMsg) = '' then exit;

  pT^.txECoding_Import_Notes := pT^.txECoding_Import_Notes +
                                aProduct +': ' +
                                Trim( aMsg) + #13#10;
  pT^.txImport_Notes_Read := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddToImportNotes( pD : BKDEFS.pDissection_Rec; aMSg, aProduct : string); overload;
begin
  if Trim( aMsg) = '' then exit;

  pD^.dsECoding_Import_Notes := pD^.dsECoding_Import_Notes +
                                aProduct +': ' +
                                Trim( aMsg) + #13#10;
  pD^.dsImport_Notes_Read := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RaiseImportError( eMsg : string);
begin
   Raise Exception.Create( eMsg);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportECodingFileFromFile( aClient : TClientObj; var Filename : string;  ConfirmFirst : Boolean; Dest: Byte);
//allow the user to select a file and import it
var
  RejectedCount        : integer;
  NewCount             : integer;
  ImportedCount        : integer;
  ECFile               : TEcClient;
  NextNo               : integer;
  Msg                  : string;
  WebXFile             : string;
  ShowDialog           : Boolean;
  HasBankEntries       : Boolean;
  i                    : Integer;
  ba                   : TBank_Account;
  WebXFileNumber: Integer;
  SaveUserCode: string;
begin
  try
  //make sure that there are bank accounts to import into
  HasBankEntries := false;

  for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
     ba := aClient.clBank_Account_List.Bank_Account_At( i);
     if ( ba.baFields.baAccount_Type = btBank) then
     begin
        HasBankEntries := true;
        Break;
     end;
  end;
  if not HasBankEntries then
  begin
    HelpfulInfoMsg('There are no bank accounts set up for this client',0);
    Exit;
  end;


  if (Dest = ecDestWebX) then
     case aClient.clFields.clWeb_Export_Format of
     wfWebX : begin
        IncUsage('CCH Import');
         // If there is no WebXOffice installed then tell the user
        WebXFile := WebXOffice.GetWebXDataPath;
        if (WebXFile = '') then begin
           HelpfulInfoMsg(WEBX_APP_NAME + ' Secure Client Manager does not appear to be installed on the workstation.' + #13#13 +
              'You must install the software before you can use this function.', 0);
           exit;
        end;
        if not IsWDDXInstalled then begin
           if not RegisterWDDXCOM then // Re-register if we can
           begin
                HelpfulInfoMsg('The WDDX Reader does not appear to be installed on the workstation.' + #13#13 +
                'You must install the software before you can use this function.', 0);
                exit;
           end;
        end;

     end;//wfWebX

     wfWebNotes : begin
          IncUsage('WebNotes Import');
          ImportWebNotesFile(aClient);
          Exit;
       end;
     else Exit;
  end;


  //get the file details from the user if no default name has been specified
  if (filename = '') then
  begin
    ConfirmFirst := true;
    if (Dest = ecDestWebX)
    and (aClient.clFields.clWeb_Export_Format = wfWebX)  then
    begin
      NextNo := aClient.clFields.clECoding_Last_File_No_Imported + 1;
      while NextNo <= aClient.clFields.clECoding_Last_File_No do
      begin
        Filename := WebXOffice.GetWebXDataPath(WEBX_IMPORT_FOLDER) +
                  MyClient.clFields.clCode + '_' + inttostr(NextNo) + '.' + WEBX_IMPORT_EXTN;
        if BKFileExists(Filename) then
          Break
        else
          Inc(NextNo);
      end;
      if NextNo > aClient.clFields.clECoding_Last_File_No then
      begin
        NextNo := aClient.clFields.clECoding_Last_File_No_Imported + 1;
        Filename := WebXOffice.GetWebXDataPath(WEBX_IMPORT_FOLDER) +
                  MyClient.clFields.clCode + '_' + inttostr(NextNo) + '.' + WEBX_IMPORT_EXTN;
      end;
    end
    else
    begin
      NextNo   := aClient.clFields.clECoding_Last_File_No;
      Filename := aClient.clFields.clECoding_Last_Import_Dir +
                  aClient.clFields.clCode + '_' + inttostr( nextNo) + '.' + ECODING_DEFAULT_EXTN;
    end;

  end;
  // 7313 - if we have come here via the handler then always use DDE filename
  if DDE_Filename_To_Process <> '' then
    Filename := DDE_Filename_To_Process;

  if ConfirmFirst then begin
     if not GetEcodingImportOptions( aClient, Filename, Dest) then
        Exit;

      //store the directory so we can point here by default next time
      aClient.clFields.clECoding_Last_Import_Dir := ExtractFilePath( Filename);
  end;

  if (Dest = ecDestWebX)
  and (aClient.clFields.clWeb_Export_Format = wfWebX)  then
  begin
    try
      NewCount := 0;
      ShowDialog := True;
      while ShowDialog do
      begin
        if not WebXOffice.ImportFile(aClient, Filename, ImportedCount, RejectedCount, ShowDialog, WebXFileNumber) then
        begin
          if ShowDialog then
          begin
            if not GetEcodingImportOptions( aClient, Filename, Dest) then
              Exit;
          end
          else
            exit;
        end;
        //Now Check to see if any task need closing
        CloseExportTask(aClient.clFields.clCode, ttyExportWeb, WebXFileNumber);
      end;
    except
      //crash system because client file will have been updated
      On E : Exception do
      begin
        Msg := 'An error occurred during the import of ' + filename +'. ' + E.Message;
        Raise Exception.Create( Msg);
        Exit;
      end;
    end;
  end
  else
  begin
    //open the ecoding file
    ShowDialog := False;
    ECFile        := TECClient.Create;
    try
      try
        if FileExists(filename) then
        begin
          try
            ECFile.LoadFromFile( filename, 0)
          except
            ShowDialog := True;
            raise;
          end;
        end
        else
        begin
          ShowDialog := True;
          RaiseImportError('The selected file does not exist.');
        end;

        //check client code
        if ECFile.ecFields.ecCode <> aClient.clFields.clCode then
        begin
          ShowDialog := True;
          RaiseImportError( 'The selected file is for a different client code. [ ' +
                            ECFile.ecFields.ecCode + ']');
        end;

        //check that this is not an older file
        if ( ECFile.ecFields.ecFile_Number < aClient.clFields.clECoding_Last_File_No_Imported) then begin
           Msg := 'This file is older than the last file you have imported.  It '+
                  'contains transactions from ' + bkDate2Str( ECFile.ecFields.ecDate_Range_From) +
                  ' to ' + bkDate2Str( ECFile.ecFields.ecDate_Range_To) + '. '#13#13+

                   'Please confirm that you wish to import this file?';
            if AskYesNo( 'Import file', Msg, DLG_NO, 0) <> DLG_YES then exit;
        end;

        //prompt the user if this is an old file
        if ( ECFile.ecFields.ecFile_Number = aClient.clFields.clECoding_Last_File_No_Imported) then begin
           Msg := 'You have already imported this file.  If you import it again any '+
                  'new transactions will be duplicated'#13#13+
                  'Please confirm that you wish to do this?';

           if AskYesNo( 'Import file', Msg, DLG_NO, 0) <> DLG_YES then exit;
        end;

      except
        //catch file open exceptions, these can be handled, all others must
        //crash application because may have begun updating client
        on E :Exception do begin
          Msg := 'Cannot import file ' + filename + '. ' + E.Message;
          HelpfulErrorMsg( Msg, 0);
          if ShowDialog then
          begin
            Filename := '';
            ImportECodingFileFromFile(aClient, Filename,True, Dest);
            exit;
          end;
          exit;
        end;
      end;

      //File successfully openned, read to verify
      if not VerifyBNotesFile( ECFile, aClient, filename) then
        Exit;

      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //                     I M P O R T   S T A R T S
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      LogUtil.LogMsg( lmInfo, Unitname, 'Importing file ' + filename);
      try
         //Save for audit
         if aClient.clFields.clCountry = whUK then
          SaveAClient(aClient);

         ProcessBNotesFile( ECFile, aClient, ImportedCount, NewCount, RejectedCount);

         //Save for audit
         if aClient.clFields.clCountry = whUK then begin
            SaveUserCode := CurrUser.Code;
            try
              CurrUser.Code := 'Notes';
              SaveAClient(aClient);
            finally
              CurrUser.Code := SaveUserCode;
            end;
         end;
      except
        //crash system because client file will have been updated
        On E : Exception do
        begin
          Msg := 'An error occurred during the import of ' + filename +'. ' + E.Message;
          Raise Exception.Create( Msg);
          Exit;
        end;
      end;

      //Now Check to see if any task need closing
      CloseExportTask(aClient.clFields.clCode, ttyExportBNotes, ECFile.ecFields.ecFile_Number);
    finally
      ECFile.Free;
    end;
  end;



  //import successful
  HelpfulInfoMsg( 'Import Successful', 0);
  Msg :=  'File imported successfully ' +
          inttostr( ImportedCount) + ' transaction(s) updated '+
          inttostr( NewCount)      + ' new transaction(s) ' +
          inttostr( RejectedCount) + ' rejected transaction(s)';
  LogUtil.LogMsg(lmInfo, UnitName, Msg);

  //*** Flag Audit ***
  Msg := Format('%s (Filename=%s)',[Msg, Filename]);
  aClient.ClientAuditMgr.FlagAudit(arBankLinkNotes, 0, aaNone, Msg);
  finally
     RefreshHomepage;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ExportECodingFileToFile(aClient : TClientObj; Dest : Byte) : boolean;
const
  ThisMethodName = 'ExportECodingFileToFile';
var
   DateFrom,
   DateTo       : integer;
   Filename     : string;
   TempDir      : string;
   sMsg         : string;
   Count        : integer;

   HasBankEntries : boolean;
   i              : integer;
   ba             : TBank_Account;
   NextNo         : integer;

   EncodedLogoString : string;
   S: TStrings;
   WebXFile: string;
   AccountList: TList;
   AttachmentSent: Boolean;
   Subject: string;
   NotifyClient: Boolean;  
   ClientUserName: String;
   ClientUserEmail: String;
begin
   result := false;

   HasBankEntries := false;
   for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
      ba := aClient.clBank_Account_List.Bank_Account_At( i);
      if ( ba.baFields.baAccount_Type = btBank) and
         ( ba.baTransaction_List.ItemCount > 0)
      then begin
         HasBankEntries := true;
         Break;
      end;
   end;

   if not HasBankEntries then begin
      HelpfulInfoMsg('This client file does not have any entries that can be exported.', 0);
      exit;
   end;

   // If there is no WebXOffice installed then tell the user
   case Dest of
   ecDestWebX: case aClient.clFields.clWeb_Export_Format of
      wfWebX : begin
      IncUsage('CCH Export');
      WebXFile := WebXOffice.GetWebXDataPath;
      if (WebXFile = '') then
      begin
        HelpfulInfoMsg(WEBX_APP_NAME + ' Secure Client Manager does not appear to be installed on the workstation.' + #13#13 +
              'You must install the software before you can use this function.', 0);
       exit;
      end;
      WebXFile := WebXOffice.GetWebXDataPath + glConst.WEBX_FOLDERINFO_FILE;
      if not FileExists(WebXFile) then
      begin
       HelpfulInfoMsg('The ' + WEBX_APP_NAME + ' file listing the Secure Areas cannot be found. ' + #13 +
           'File: ' + WebXFile + #13#13 +
           'You must install the software before you can use this function.', 0);
       exit;
      end;
      S := TStringList.Create;
      try
       WebXOffice.ReadSecureAreas(S);
       if S.Count = 0 then
       begin
         HelpfulInfoMsg('There are no ' + WEBX_APP_NAME + ' Secure Areas set up. ' + #13#13 +
           'You must install the software before you can use this function.', 0);
         exit;
       end;
      finally
       S.Free;
      end;
    end;
     wfWebNotes : IncUsage('WebNote Export');
   end;

   end;

   //make sure all relative paths are relative to data dir after browse
   SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);

   //sort out default filename
   NextNo   := aClient.clFields.clECoding_Last_File_No + 1;
   Filename := '';

   case Dest of 
      ecDestEmail : begin
         Filename := aClient.clFields.clCode + '_' + inttostr( nextNo) + '.' + ECODING_DEFAULT_EXTN;
      end;
      ecDestWebX :  if aClient.clFields.clWeb_Export_Format = wfWebX then begin
         Filename := WebXOffice.GetWebXDataPath(WEBX_EXPORT_FOLDER) +
                 aClient.clFields.clCode + '_' + inttostr( nextNo) + '.' + WEBX_DEFAULT_EXTN

      end;
      ecDestFile: begin
         Filename := aClient.clFields.clECoding_Last_Export_Dir +
                 aClient.clFields.clCode + '_' + inttostr( nextNo) + '.' + ECODING_DEFAULT_EXTN;
      end;

   end;

   AccountList := TList.Create;
   try
    if GetECodingExportOptions( aClient, Dest, DateFrom, DateTo, Filename, AccountList) then begin
      if Dest = ecDestFile then begin
         if ExtractFilePath( Filename) = '' then begin
            Filename := DATADIR + Filename;
         end;
         aClient.clFields.clECoding_Last_Export_Dir := ExtractFilePath( Filename);
      end;
      //if mail then just want filename, strip away any path info
      if Dest = ecDestEMail then begin
         Filename := ExtractFilename( filename);
         TempDir  := WinUtils.GetTempDir( DataDir);
         Filename := TempDir + filename;
      end;

      //encode the practice logo so that we can embed it in the file
      if Assigned( Globals.AdminSystem) then
        EncodedLogoString := PracticeLogo.EncodePracticeLogo( AdminSystem.fdFields.fdPractice_Logo_Filename)
      else
        EncodedLogoString := '';

      if (Dest = ecDestWebX) and (aClient.clFields.clWeb_Export_Format = wfWebNotes) then
      begin
        if not ProductConfigService.GetOnlineClientUser(aClient.clFields.clCode, ClientUserName, ClientUserEmail) then
        begin
          if aClient.clExtra.ceOnlineValuesStored then
          begin
            ClientUserName :=  aClient.clExtra.ceOnlineUserFullName;
            ClientUserEmail := aClient.clExtra.ceOnlineUserEMail;
          end
          else
          begin
            ClientUserName := aClient.clFields.clContact_Name;
            ClientUserEmail := aClient.clFields.clClient_EMail_Address;
          end;
        end;

        if ProductConfigService.PracticeUserExists(ClientUserEmail) then
        begin
          HelpfulErrorMsg(Format(bkBranding.PracticeProductName + ' is unable to export the client to ' + bkBranding.NotesOnlineProductName + '. User with email address %s already exists as a Practice user. Please specify a different email address or contact ' + TProduct.BrandName +  ' Support for assistance.', [ClientUserEmail]), 0);

          Exit;
        end;
      end
      else
      begin
        ClientUserName := aClient.clFields.clContact_Name;
        ClientUserEmail := aClient.clFields.clClient_EMail_Address;
      end;  

      try
         try
            if (Dest = ecDestWebX) then
           
             
              case aClient.clFields.clWeb_Export_Format of
              wfWebX :  Count := WebXOffice.ExportAccount(aClient, nil, Filename, DateFrom, DateTo, nil, False, nil, False, AccountList);
              wfWebNotes :  ExportWebNotesFile(aClient, DateFrom, DateTo, Count, Subject, NotifyClient, false, false, nil, AccountList, 0, ClientUserName, ClientUserEmail);
              end

            else
            begin
             
              BNotesInterface.GenerateBNotesFile( aClient, Filename, DateFrom, DateTo, Count, false, nil, false, nil, EncodedLogoString, AccountList);
            end;
         except
            on E : EWebNotesDataUploadError do begin
               // Already Handled 
               exit;
            end;
            on E : Exception do begin
               HelpfulErrorMsg( 'Unable to create file ' + Filename + '.  '+
                                E.Message, 0);
               exit;
            end;
         end;

         if (aClient.clFields.clWeb_Export_Format = wfWebNotes)
         and (Dest = ecDestWebX) then begin
            sMsg := Inttostr(Count) + ' entries successfully exported to ' + wfNames[wfWebNotes];
            HelpfulInfoMsg(sMsg, 0);
            //*** Flag Audit ***
            aClient.ClientAuditMgr.FlagAudit(arBankLinkNotesOnline, 0, aaNone, sMsg);
         end else begin
            sMsg := Inttostr(Count) + ' entries successfully exported to ' + Filename;
            //*** Flag Audit ***
            aClient.ClientAuditMgr.FlagAudit(arBankLinkNotes, 0, aaNone, sMsg);
         end;

         LogUtil.LogMsg( lmInfo, Unitname, sMsg);

         if ( Dest = ecDestFile)
         or ( (Dest = ecDestWebX) and  (aClient.clFields.clWeb_Export_Format = wfWebX)   ) then begin
            HelpfulInfoMsg( sMsg, 0);
            //increase the file number
            Inc( aClient.clFields.clECoding_Last_File_No);
            result := true;
         end;

         if (Dest = ecDestWebX)
         and (aClient.clFields.clWeb_Export_Format = wfWebNotes)
         and (NotifyClient) then
         begin 
            // Build The email,
            //Subject should be the URL..
            SendMailTo(Format('Export to %s Notification', [bkBranding.NotesOnlineProductName]),
                       ClientUserEmail, // Recipients

                       Format('Export to %s, notification for %s (%s to %s)', // Subject
                              [wfNames[wfWebNotes],
                               aClient.clFields.clCode,
                               bkDate2Str(DateFrom),
                               bkDate2Str(DateTo)]),

                       Subject//Email message
                      );
         end;

         if (Dest = ecDestEMail) then begin

            //file created succesfully, now send to client

               Subject := Format(bkBranding.NotesProductName + ' File for %s (%s to %s)',
                              [aClient.clFields.clCode,
                               bkDate2Str(DateFrom),
                               bkDate2Str(DateTo)]);

            if MailFrm.SendFileTo( 'Send ' + bkBranding.NotesProductName + ' file',
                                   aClient.clFields.clClient_EMail_Address,
                                   Subject, filename, AttachmentSent, false) then
            begin
               //increase the file number
               if AttachmentSent then
                 Inc( aClient.clFields.clECoding_Last_File_No);
               result := true;
            end;
         end;

         if Assigned( Globals.AdminSystem) then // Check that this a Practice Application!! 
           if LoadAdminSystem(true, ThisMethodName ) then
           begin
             if Dest = ecDestWebX then
                case aClient.clFields.clWeb_Export_Format of
                wfWebX :  AddAutomaticToDoItem( aClient.clFields.clCode,
                                     ttyExportWeb,
                                     Format( ToDoMsg_Acclipse,
                                             [ bkDate2Str( DateFrom),
                                               bkDate2Str( DateTo),
                                               bkDate2Str(CurrentDate)
                                             ]),
                                     0, NextNo);

                wfWebNotes : AddAutomaticToDoItem( aClient.clFields.clCode,
                                     ttyExportWeb,
                                     Format( ToDoMsg_Webnotes,
                                             [ bkDate2Str( DateFrom),
                                               bkDate2Str( DateTo),
                                               bkDate2Str(CurrentDate)
                                             ]),
                                     0, NextNo);
                end


             else
               AddAutomaticToDoItem( aClient.clFields.clCode,
                                     ttyExportBNotes,
                                     Format( ToDoMsg_ManualECoding,
                                             [ bkDate2Str( DateFrom),
                                               bkDate2Str( DateTo),
                                               bkDate2Str(CurrentDate)
                                             ]),
                                     0, NextNo);
              SaveAdminSystem();
           end;
      finally
         //clean up temp dir if sending mail
         if ( Dest = ecDestEMail) then begin
            SysUtils.DeleteFile( filename);
         end;
      end;
    end;
   finally
     RefreshHomepage;
     AccountList.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckOutstandingEcodingFiles(aClient: TClientObj) : boolean;
begin
  //Check if they have outstanding BNotes or Acclipse files, and warn them against continuing. Case 8625
  //Returns true if OK to proceed (i.e. no outstanding or the user has opted to keep going)
  //False if the user has chosen not to proceed.

  Result := true;
  if not Assigned(aClient) then Exit;

  if aClient.clFields.clECoding_Last_File_No > aClient.clFields.clECoding_Last_File_No_Imported then
  begin
    if (Application.MessageBox('If you combine the bank accounts you will not be able to import the outstanding Notes or CCH file.' +
                 ' Are you sure you want to combine the accounts?', 'Confirm Combine Bank Accounts', MB_YESNO) = IDNO) then
        Result := false;
  end;
end;

end.
