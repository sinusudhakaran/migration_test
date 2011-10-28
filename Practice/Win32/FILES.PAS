unit Files;
{unit for handling all of the file menu commands, Win32 only}
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Dialogs, Classes, Windows, Sysutils,
  LogUtil, clObj32, ChkProgressFrm, AuditMgr, WebCiCoClient;

  {$IFNDEF TESTLOCKING}
  procedure OpenClient(OpenCode : string; IsDDE: Boolean = False);
  function CloseClient( Interactive : boolean = false; DoClientHomePage: Boolean = True): Boolean;
  procedure SaveClient;
  function AbandonChanges(ConfirmAction : boolean): Boolean; {only applicable to global client obj}
  procedure SendClientFiles(CodesToSend : string = ''; ASendMethod: byte = 0;
                            AFirstUpload: boolean = False; AFlagReadOnly: boolean = False;
                            AEditEmail: boolean = False; ASendEmail: boolean = False);
  function SendClient(Code : string; Path : string; ProgressFrm : TfrmChkProgress;
                      var AClientEmail: string; IsScheduledReport: Boolean = False;
                      Silent: Boolean = False; AllowMultiplePwdFiles: Boolean = False;
                      ASendMethod: byte = 0; FlagReadOnly: boolean = true) : Boolean; overload;
  function SendClient(Code : string; Path : string; ASendMethod: byte = 0;
                      FlagReadOnly: boolean = true): Boolean; overload;
  function CheckInClient(Code : string; Path : string; ProgressFrm : TfrmChkProgress;
                         IsScheduledReports: Boolean = False; ASendMethod: byte = 0) : boolean;
  function CheckInRemoteClient( filename : string) : boolean;

  procedure Checkin(ASendMethod: byte; CodesToCheckIn : string = '');
  procedure SaveAs;
  procedure OpenFromMRU(Sender: TObject);
  {$ENDIF}

  //Operations on a specified client
  procedure OpenAClient(OpenCode : string;
                        var Client : TClientObj;
                        Silent : boolean;
                        AllowOpenReadOnly : boolean = false;
                        PasswordVerified: Boolean = false;
                        IsDDE: Boolean = False);
  procedure CloseAClient(var Client : TClientObj; AllowReadOnlyToBeSaved : boolean = false);
  procedure SaveAClient(Client :TClientObj); // AJ: Is this ever used (Not in BK5)
  procedure AbandonAClient(var Client : TClientObj);
  function DoClientSave(Closing: Boolean; Client: TClientObj; const Silent: Boolean = False): Boolean;
  function ClientFileExists(ClientCode : string): boolean;
  procedure OpenAClientForRead(OpenCode :string; var Client : TClientObj);

//******************************************************************************
implementation

uses
  ClientWrapper,
  ResyncClient,
  Controls,
  Forms,
  Admin32,
  AppTime,
  Bk5Except,
  bkconst,
  bkdbExcept,
  bkHelp,
  BugFixes,
  ClientLookupExFrm,
  ClientHomepagefrm,
  CrcFileUtils,
  EnterPwdDlg,
  ExceptH,
  FCopy,
  globals,
  Math,
  menus,
  Merge32,
  Progress,
  statusFrm,
  syCFio,
  sydefs,
  stDate,
{$IFNDEF TESTLOCKING}
  CheckInOutFrm,
  cInfoFrm,
  ClientNotesFrm,
  ErrorMoreFrm,
  InfoMorefrm,
  SaveAsDlg,
  ToDoHandler,
  updateMF,
  WarningMoreFrm,
{$ENDIF}
  OffsiteBackup,
  WinUtils,
  YesNoDlg,
  DirUtils,
  UBatchBase,
  RadioOptionsDlg, BKDEFS, SysObj32, cfList32, GenUtils, syamio, WebXUtils,
  ECodingUtils, BKUtil32, baObj32, baUtils, bkDateUtils,
  UpgradeHelper, ClientManagerFrm, ClientUtils, ExchangeRateList,
  MailFrm, ClientDetailCacheObj, BankLinkOnline;

const
  UnitName = 'FILES';
var
  DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFDEF TESTLOCKING}  //Stubs for hidden routines
  function CloseMDIChildren : boolean; begin result := true; end;
  procedure HelpfulErrorMsg( aMsg : string; aInt : integer);
  begin
    ShowMessage( 'Error: ' + aMsg);
  end;
  procedure HelpfulInfoMsg( aMsg : string; aInt : integer);
  begin
    ShowMessage( 'Info: ' + aMsg);
  end;
{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ClientFileExists(ClientCode : string): boolean;
const
  ThisMethodName = 'ClientFileExists';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := BKFileExists( DataDir+ClientCode+FILEEXTN );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBankLinkOnlineSubDomain: string;
begin
  Result := '';
  if (PRACINI_OnlineLink <> '') then begin
    if (Pos('//', PRACINI_OnlineLink) > 0) and
       (Pos('.', PRACINI_OnlineLink) > 0) then
      Result := Copy(PRACINI_OnlineLink,
                     Pos('//', PRACINI_OnlineLink) + 2,
                     Pos('.', PRACINI_OnlineLink)- (Pos('//', PRACINI_OnlineLink) + 2));
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetAdminStatusToClosed( Code : string);
const
  ThisMethodName = 'SetAdminStatusToClosed';
var
  CFRec : pClient_File_Rec;
begin
   //Cancel the open, this requires us to clear the status in the admin system
   //if there is one
   if Assigned( AdminSystem) then begin
      if LoadAdminSystem(true, ThisMethodName ) then begin
         CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
         if Assigned( CFRec) then
         begin
           CFRec^.cfCurrent_User  := 0;
           CFRec^.cfFile_Status   := fsNormal;
         end;
         SaveAdminSystem;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure OpenAClient( OpenCode : string;
                       var Client : TClientObj;
                       Silent : boolean;
                       AllowOpenReadOnly : boolean = false;
                       PasswordVerified: Boolean = false;
                       IsDDE: Boolean = False);
const
  ThisMethodName = 'OpenAClient';
var
  Code           : string;
  CFRec          : pClient_File_Rec;
  URec           : pUser_Rec;
  User           : string;
  Wrapper        : TClientWrapper;
  AutoSaveWrapper: TClientWrapper;
  Msg, S, S1, S2 : String;
  AutoSaveDateTime : TDateTime;
  LastSaveDateTime : TDateTime;
  VarDateTime    : TDateTime;
  p, i           : integer;
  OpenReadOnly   : Boolean;
  Button         : integer;
  b: TBank_Account;
  PasswordCorrect: Boolean;
  LExchangeRates: TExchangeRateList;
  LExchangeSource: TExchangeSource;
  ISOCodes: TStrings;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Code := '';
  try //finally  - clear status
    try //except
       if Client <> nil then begin
          raise EInvalidCall.CreateFmt( '%s %s Client object must be nil', [ UnitName, ThisMethodName ]);
       end;

       RefreshAdmin;
       if OpenCode = '' then begin
          //find code of first MRU an position on that
          S := INI_MRUList[1];
          p := Pos(#9, S) - 1;
          If p <= 0 Then Begin
             p := Length(S)
          End;
          S := Copy(S, 1, p);

          //Select client from list
          Code := ClientLookupExFrm.LookupClientCodes( 'Open a file', S, []);
          if Code = '' then
             Exit
       end
       else
          Code := OpenCode;

       if Assigned(AdminSystem) then
       begin
         if ( AdminSystem.fdSystem_Client_File_List.FindCode( Code) = nil) then begin
            Msg := Format( 'Client Code %s could not be found in the Admin System.', [Code] );

            if not Silent then
               HelpfulErrorMsg( Msg,0);
            Exit;

            LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
         end;
       end;

       if not ClientFileExists(code) then
       begin
          Msg := Format( 'File not found for Client Code %s.', [ Code] );

          if not Silent then
             HelpfulErrorMsg( Msg,0);

          LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
          Exit;
       end;

       UpdateAppStatus('Opening Client',Code,0);
       try
          GetClientWrapper( DataDir+Code+FILEEXTN, Wrapper, false);  //to check password

          if ( Wrapper.wSignature <> BankLink_Signature) then
            raise EFileWrapper.Create( 'Invalid File Signature');
       except
          on e : EFileWrapper do begin
             Msg := 'Cannot open file for ' + Code + '. Error: ' + E.Message;
             if not Silent then
                HelpfulErrorMsg( Msg, 0);

             LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
             exit;
          end;
       end;

       OpenReadOnly := False;

       if Assigned( AdminSystem) then
       begin
         //Practice Version

         RefreshAdmin;

         //check if file is currently read-only, offsite etc
         //This is done before locking the admin system so that we can ask the
         //user if they want to open the file read only.
         //If we did this once the admin system is locked then it is possible that
         //a dialog will be sitting on screen long enough to crash all other
         //workstations
         CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
         if Assigned(CFRec) and (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite]) then
         begin
           //read only and off site clients may be opened read only
           if not Silent then
           begin
             if AllowOpenReadOnly then
             begin
               //the user can be given the option to open this file read only
               //build a message if the file status is not normal
               Msg := '';
               case CFRec.cfFile_Status of
                 fsCheckedOut : begin
                   Msg := Format( 'Client file %s is currently Read-only.', [ Code ] );
                 end;

                 fsOffsite : begin
                   Msg := Format( 'Client File %s is currently Off-site.', [ Code ] );
                 end;
               end;
               Msg := Msg + #13#13+
                  'You may open this file Read-Only however you will not be able to save any changes.' + #13#13 +
                  'Do you want to open the client file Read-Only?';

               OpenReadOnly := (AskYesNo('Open Client File Read-Only', Msg, DLG_YES, 0) = DLG_YES);

               if not OpenReadOnly then
                 Exit;
             end
           end;
         end;
       end
       else
       begin
         //Offsite version
         //open read only
         if Wrapper.wRead_Only then
         begin
           if Silent then
             Exit;

           if AllowOpenReadOnly then
           begin
             Msg := 'You may open this file Read-Only however you will not be able to save any changes.' + #13#13 +
                    'Do you want to open the client file Read-Only?';

             OpenReadOnly := (AskYesNo('Open Client File Read-Only', Msg, DLG_YES, 0) = DLG_YES);
             if not OpenReadOnly then
               Exit;

             OpenReadOnly := true;
           end
         end;
       end;

       //Check password
       if (HasPassword(Wrapper)) and (not (SuperUserLoggedIn)) and (not PasswordVerified) then
       begin
         //password required
         if silent then
         begin
           Msg := Format( '%s Password Required in Silent Mode - Not Opened.', [ Code] );
           LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
           Exit;
         end;
         //Check against hashed password if it exists, if not against unhashed password
         //Unhashed password is cleared when the file is saved.
         if Wrapper.wPwdHash <> '' then
           PasswordCorrect := EnterPwdDlg.EnterHashedPassword('Open Client '+Wrapper.wCode, Wrapper.wPwdHash)
         else
           PasswordCorrect := EnterPwdDlg.EnterPassword( 'Open Client '+Wrapper.wCode,
                                           Wrapper.wOldPassword,
                                           0,
                                           pwdNormal,
                                           pwdHidePassword );


         if not PasswordCorrect then
         begin
            Msg := 'A valid password is required to open this file! [' + Code + ']';
            HelpfulErrorMsg( Msg, 0);
            Exit;
         end;
       end;

       if Assigned( AdminSystem) then
       begin
         //*********** LOCK ADMIN SYSTEM **********************
         if LoadAdminSystem(True, ThisMethodName ) then
         begin
           //check that a cf rec exists
           CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
           if not Assigned(CFRec) then
           begin
              UnlockAdmin;

              Msg := Format( 'Client Code %s is not in the Admin System.', [Code] );
              if DebugMe or Silent then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
              if not Silent then HelpfulErrorMsg( Msg,0);
              Exit;
           end;

           //check file status
           if CFRec.cfFile_Status <> fsNormal then
           begin
             URec := AdminSystem.fdSystem_User_List.FindLRN(cfRec.cfCurrent_User);
             if Assigned(URec) then
                User := URec.usCode
             else
                User := '<unknown>';

             //build a message if the file status is not normal
             Msg := '';
             case CFRec.cfFile_Status of
                fsOpen : begin
                   Msg := Format( 'User %s is working on client file %s.', [ User, Code ] );
                end;

                fsCheckedOut : begin
                   Msg := Format( 'User %s has marked file %s as read-only.', [ User, Code ] );
                end;

                fsOffsite : begin
                   Msg := Format( 'Client File %s is currently Off-site.', [ Code ] );
                end;
             end; {case}
             if (Msg <> '') and ( DebugMe or Silent) then
               LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );


             if not OpenReadOnly then
             begin
               UnlockAdmin;

               if Silent then
                 LogUtil.LogError( Unitname, 'Cannot open read-only file ' + Code + ' [Silent]')
               else
                 HelpfulInfoMsg( 'Sorry, ' + Msg, 0 );
               if IsDDE then
                DoClientManager(0, 0, 0, 0);
               Exit;
             end;
           end;

           if OpenReadOnly then
           begin
             //opening file read only,no need to tell admin system anything
             UnlockAdmin;
           end
           else
           begin
             //update admin system to say that I have it loaded
             CFRec.cfCurrent_User := CurrUser.LRN;
             CFRec.cfFile_Status  := fsOpen;
             SaveAdminSystem;
           end;
         end
         else
           Exit;
       end;

       //file is to be opened normally and password has been okayed
       if BKFileExists(DATADIR + Code + AUTOSAVEEXTN) then
       begin
         if not Silent then
         begin
           //Test the time of the auto save file against the current file
           //only prompt user if auto save is later than last bk5 file
           FileAge(DATADIR + Code + AUTOSAVEEXTN, AutoSaveDateTime);
           FileAge(DATADIR + Code + FILEEXTN, LastSaveDateTime);
           if (AutoSaveDateTime > LastSaveDateTime) then
           begin
             GetClientWrapper( DATADIR + Code + AUTOSAVEEXTN, AutoSaveWrapper, false);  //to check integrity
             if IntegrityCheckClientWrapper(AutoSaveWrapper) then
             begin
               //there is an auto-saved file on disc for this client
               S := 'BankLink has detected a later version of the client file ' + Code + ' that was auto-saved ';
               VarDateTime := AutoSaveDateTime;
               if (Trunc(VarDateTime) = Date) then
                 S := S + 'Today'
               else
                 S := S + ' on ' + DateToStr(VarDateTime);

               S := S + ' at ' + TimeToStr(VarDateTime) + #13#13 +
                    'What do you want to do?';

               S1 := 'Open the auto-saved version of this file';
               S2 := 'Open the last manually saved version of this file';

               Button := SelectFromRadioDialog( 'Recover file',
                            S,
                            '&Open', 'Cancel',
                            0,
                            S1,
                            S2);

               case Button of
                 1 : begin
                   //use the auto-save file as the client file
                   if DeleteFile(DATADIR + Code + FILEEXTN) then
                   begin
                     if RenameFile(DATADIR + Code + AUTOSAVEEXTN, DATADIR + Code + FILEEXTN) then
                       LogMsg( lmInfo, Unitname, ThisMethodName + ': ' + Code + ' recovered from Auto Save File')
                     else
                       LogMsg( lmError, Unitname, ThisMethodName + ': ' + Code + ' recover from Auto Save FAILED')
                   end;
                 end;
                 2 : ;// open normally
               else
                 SetAdminStatusToClosed( Code);
                 Exit;
               end;
             end;
           end;
         end
         else
         begin
           //in silent mode so cant ask whether to recover or not
           SetAdminStatusToClosed( Code);
           LogMsg( lmInfo, Unitname, ThisMethodName + ': Auto save file found in silent mode for ' + Code + '- Not Opened.');
           Exit;
         end;
       end;
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

       //create object
       Client := TClientObj.Create;
       APPTIME.StartTime;
       Client.Open(Code, FILEEXTN);
       APPTIME.StopTime;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

       //Strip out any master memorised entries if there is an admin system
       StripMasterMemorised(Client);

       //remove embedded graphic if there is an admin system
       StripCustomLogo(Client);

       //Update non stored fields
       Client.clWas_Code := Client.clFields.clCode; {so can detect a rename}

       with Client.clFields do begin
         clFile_Name := Code;
         clFile_Memory_Usage  := 0;
         clFile_Load_Time     := Round(AppTime.GetElapsed*1000);
         clFile_Save_Required := FALSE;
         clFile_Read_Only     := OpenReadOnly;
       end;

       Msg := Format( 'Client file %s Opened by %s', [ Code, CurrUser.Code ] );
       if Client.clFields.clFile_Read_Only then
         Msg := Msg + ' (READ-ONLY)'
       else if Assigned(AdminSystem) then
       begin
         //Load exchange rates
         if Client.HasForeignCurrencyAccounts then begin
           LExchangeRates := GetExchangeRates;
           try
             LExchangeSource := LExchangeRates.FindSource('Master');
             if (not Assigned(LExchangeSource)) then begin
               //Assing an empty exchange source to the client file if
               //there is no system exchange source
               LExchangeSource := TExchangeSource.Create;
               try
                 //Books Secure Client file exchange rates do not get updated
                 if (Client.clFields.clDownload_From = dlAdminSystem) then
                   Client.ExchangeSource.Assign(LExchangeSource);
               finally
                 LExchangeSource.Free;
               end;
             end else if (Client.clFields.clDownload_From = dlAdminSystem) then
               //Books Secure Client file exchange rates do not get updated
               Client.ExchangeSource.Assign(LExchangeSource);
           finally
             LExchangeRates.Free;
           end;
         end;
         //Update AdminSystem
         if LoadAdminSystem(True, ThisMethodName) then
         begin
           //Update ISO code list in Client File Rec
           ISOCodes := TStringList.Create;
           try
             //Get list ISO codes used in the Client File
             Client.FillIsoCodeList(ISOCodes);
             //Update Client File Rec
             CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
             if Assigned(CFRec) then
               AdminSystem.AddISOCodes(CFRec, ISOCodes);
           finally
             ISOCodes.Free;
           end;
           // see if manual accounts need sending to admin
           if HasManualAccounts(Client, True) then begin
             for i := Client.clBank_Account_List.First to Client.clBank_Account_List.Last do
             begin
               b := Client.clBank_Account_List.Bank_Account_At(i);
               if (b.IsManual)
               and (not b.baFields.baManual_Account_Sent_To_Admin)
               and (b.baFields.baManual_Account_Type <> -1) then
               begin
                 b.baFields.baManual_Account_Sent_To_Admin := True;
                 AdminSystem.fdFields.fdManual_Account_XML := AdminSystem.fdFields.fdManual_Account_XML +
                    MakeManualXMLString(mtNames[b.baFields.baManual_Account_Type], b.baFields.baManual_Account_Institution);
               end;
             end;
           end;
           SaveAdminSystem;
           DoClientSave(false, Client);
         end;
       end;
       LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ' : ' + Msg );

    except
       on E : EInvalidDataInFile do begin
          //unknown token, bounds error
          Msg := Format( 'Unable to Open Client file %s. %s', [ Code, E.Message ] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          if not Silent then
             HelpfulErrorMsg( Msg, 0 );
          Client.Free;
          Client := nil;
       end;

       on E : EBKFileError do begin
          //crc failure, wrapper error
          Msg := Format( 'Unable to Open Client file %s. %s', [ Code, E.Message ] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          if not Silent then
             HelpfulErrorMsg( Msg, 0 );
          Client.Free;
          Client := nil;
       end;

       on E : EIncorrectVersion do begin
          Client.Free;
          Client := nil;

          if not Silent then
          begin
             if Assigned( AdminSystem) then
               HelpfulErrorMsg( e.Message,0)
             else
             begin
               if AskYesNo( 'Check for Updates',
                            'A later version of ' + ShortAppName+
                            ' is required to open this file.'#13#13 +
                            'Would you like to check for a later version now?',
                            DLG_YES, 0) = DLG_YES then
               begin
                 UpgradeHelper.CheckForUpgrade_Offsite(Application.MainForm.Handle, '', Wrapper.wCountry, false);
                 if Globals.ApplicationMustShutdownForUpdate then
                   Application.Terminate;
               end;
             end;
          end;
       end;
    end;  // try/except
  finally
    ClearStatus;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure OpenAClientForRead(OpenCode :string; var Client : TClientObj);
//used to load a copy of the client that will be thrown away
//only used by Scheduled Reports
const
  ThisMethodName = 'OpenAClientForRead';
var
  fileName        : string;
  Msg : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Starts' );
  try
    fileName := DATADIR + OpenCode + FILEEXTN;
    Client := TClientObj.Create;
    Client.Open(OpenCode, FILEEXTN);
  except
    on e : EInOutError do begin
      Msg := Format( 'Unable to Open Client file %s. %s', [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Client.Free;
      Client := nil;
    end;

    on E: EInvalidDataInFile do begin
      Msg := Format( 'Unable to Open Client file %s. %s', [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Client.Free;
      Client := nil;
    end;

    on E: EBKFileError do begin
      Msg := Format( 'Unable to Open Client file %s. %s', [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Client.Free;
      Client := nil;
    end;


    on E : EIncorrectVersion do begin
       Client.Free;
       Client := nil;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ResetReadOnlyFlag( OpenCode : string; ASendMethod: Byte);
const
  ThisMethodname = 'ResetReadOnlyFlag';
  S_RESETERROR = 'Unable to Reset Read-only status for client %s. %s';
var
  Client : TClientObj;
  filename : string;
  Msg : string;
begin
  Assert( not Assigned( AdminSystem), 'ResetReadOnly called when Admin Exists');

  try
    fileName := DATADIR + OpenCode + FILEEXTN;
    Client := TClientObj.Create;
    try
      //open the client file and clear the read only status
      Client.Open(OpenCode, FILEEXTN);

      with Client.clFields do begin
        clFile_Memory_Usage  := 0;
        clFile_Save_Required := FALSE;
        clFile_Read_Only     := False;
      end;

      //Reset file transfer method
      Client.clExtra.ceFile_Transfer_Method := ASendMethod;

      Client.Save;
    finally
      Client.Free;
    end;

  except
    on e : EInOutError do begin
      Msg := Format( S_RESETERROR, [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
    end;

    on E: EInvalidDataInFile do begin
      Msg := Format( S_RESETERROR, [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
    end;

    on E: EBKFileError do begin
      Msg := Format( S_RESETERROR, [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
    end;

    on E : EIncorrectVersion do begin
      Msg := Format( S_RESETERROR, [ OpenCode, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoClientSave(Closing: boolean; Client: TClientObj; const Silent: Boolean = False): Boolean;
const
   ThisMethodName = 'DoClientSave';
var
   pCF : pClient_File_Rec;
   Code : string;
   RenameRequired : boolean;
   Msg, UserCode: string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if Assigned(CurrUser) then
      UserCode := CurrUser.Code
   else
      UserCode := '<unknown>';

   RenameRequired := (Client.clWas_Code <> Client.clFields.clCode);
   if RenameRequired then
      LogUtil.LogMsg(lmInfo,UnitName,Format('%s : Renaming file from %s to %s',[ThisMethodName,Client.clWas_Code,Client.clFields.clCode]));


   if Assigned( AdminSystem) then
   begin
     //update cached details
     if AdminSystem.fdFields.fdMagic_Number = Client.clFields.clMagic_Number then
        Client.clFields.clCopy_Narration_Dissection := PRACINI_CopyNarrationDissection;
   end;

   // Write last use date if theres a manual account
   if HasManualAccounts(Client) and (CurrentDate >= Client.clFields.clLast_Use_Date) then
      Client.clFields.clLast_Use_Date := CurrentDate;

   Client.TestForChange;
   Code := Client.clWas_Code;

   if Assigned( AdminSystem) then begin
      //get the latest details from the admin cache in case someone edited details
      //while i had the file open
      RefreshAdmin;
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Code);
      if Assigned(pCF) then begin
        RefreshContactDetails(Client, pCF, syncDir_AdminToClient);
      end;

   end;
   Result := Client.clFields.clFile_Save_Required;
   if Client.clFields.clFile_Save_Required then begin
      if not Silent then
         UpdateAppStatus('Saving Client File ',Code,0);
      try
        Client.Save;
        if RenameRequired then
          LogUtil.LogMsg(lmInfo, UnitName, Format('%s: Client File %s SAVED by %s', [ ThisMethodName, Client.clFields.clCode, UserCode ]))
        else
          LogUtil.LogMsg(lmInfo, UnitName, Format('%s: Client File %s SAVED by %s', [ ThisMethodName, Code, UserCode ]));
      finally
         if not Silent then
            ClearStatus;
      end;
   end
   else
     LogUtil.LogMsg(lmInfo, UnitName, Format('%s: Client File %s CLOSED by %s', [ ThisMethodName, Code, UserCode ]));

   //delete the autosave file if it exists
   DeleteFile(DATADIR + Code + AUTOSAVEEXTN);

   //update admin system - must update regardless of whether changed so that file status is set back to fsNormal
   if Assigned( AdminSystem) then begin
      if LoadAdminSystem(true, ThisMethodName ) then begin
         UpdateProcessingStats(Client, True, False);
         pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

         If not Assigned( pCF ) then begin
            Msg := Format( 'Could not find CF Record for %s',[Code]);
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
            Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         if RenameRequired then begin
            AdminSystem.fdSystem_Client_File_List.Delete(pCF);
            pCf.cfFile_Code := Client.clFields.clCode;
            AdminSystem.fdSystem_Client_File_List.Insert(pCF);
         end;

         //make sure admin has latest cached details
         SyncAdminToClient(pCF, Client);
         RefreshContactDetails( Client, pCF, syncDir_ClientToAdmin);

         if Closing then begin //closing so clear status and curr user
            pCF^.cfCurrent_User        := 0;
            pCF^.cfFile_Status         := fsNormal;
         end;

         SaveAdminSystem;
      end;
   end;

   if RenameRequired then begin
      //now delete old file name
      DeleteFile(DATADIR + Client.clWas_Code + FILEEXTN);
      LogUtil.LogMsg(lmInfo,UnitName,Format('%s : Rename Completed',[ThisMethodName]));
   end;

   Client.clWas_Code := Client.clFields.clCode;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CloseAClient(var Client : TClientObj; AllowReadOnlyToBeSaved : boolean = false);
//close a specified client
//parameters:
//   Client    : client object to save
//   AllowReadOnlyToBeSaved : Allows us to force a save, even if the file is read only
//                      This is used to set the readonly flag when sending
//                      from an offsite
const
  ThisMethodName = 'CloseAClient';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Assigned(Client) then begin
      if (Client = MyClient) then begin // AJ: I don't think it would need to be here
         //must close any mdi client windows also
         CloseMDIChildren(True);
         //dereference but dont clear memory as this is pointed to by Client}
         MyClient := nil;

      end;

      //Check the status of the client file. Don't save if it has been openned Read Only
      if (not Client.clFields.clFile_Read_Only) or ( AllowReadOnlyToBeSaved) then
        DoClientSave(true, Client);

      Client.Free;
      Client := nil;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SaveAClient(Client :TClientObj);
{save a specifed client, but dont close}
begin
  if Assigned(Client) then
  begin
    //Check the status of the client file. Don't save if it has been openned Read Only
    if (not Client.clFields.clFile_Read_Only) then
      DoClientSave(false, Client);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AbandonAClient(var Client : TClientObj);
//destroy client object without saving
const
  ThisMethodName = 'AbandonAClient';
var
  pCf  : pClient_File_Rec;
  Code :string;
  Msg : string;
  FileWasOpenedReadOnly, IsPartOfAdmin : boolean;
  pS: pSystem_Bank_Account_Rec;
  pM: pClient_Account_Map_Rec;
  i, j: Integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Code := Client.clFields.clCode;
  FileWasOpenedReadOnly := Client.clFields.clFile_Read_Only;

  IsPartOfAdmin := Assigned(AdminSystem) and (Client.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number);

  Client.Free;
  Client := nil;

  //no need to update the admin system if the file is read only
  if FileWasOpenedReadOnly then
    exit;

  //delete the autosave file if it exists, raise exception if cant delete
  if (BKFileExists(DATADIR + Code + AUTOSAVEEXTN)) then
    WinUtils.RemoveFile(DATADIR + Code + AUTOSAVEEXTN);

  //update admin system
  if Assigned( AdminSystem) then begin
     if LoadAdminSystem(true, ThisMethodName ) then begin
        pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

        If not Assigned( pCF ) then begin
           Msg := Format( 'Could not find CF Record for %s',[Code]);
           LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
           Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
        end;

        pCF^.cfCurrent_User  := 0;
        pCF^.cfFile_Status   := fsNormal;
        // processing stats need updating regardless of if it is a syncronised file
        OpenAClientForRead(Code, Client);
        Merge32.UpdateProcessingStats(Client, True, False);

        // Create client-account maps
        // Add deleted ones that were abandoned
        if IsPartOfAdmin then begin

          ReSyncClientAccountMap(Client);


          // Remove added ones that were abandoned
          // look at all maps for this client, if the account is no longer in the client file then delete it
          i := 0;
          while i < AdminSystem.fdSystem_Client_Account_Map.ItemCount do
          begin
            pM := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
            pS := AdminSystem.fdSystem_Bank_Account_List.FindLRN(pM.amAccount_LRN);
            if Assigned(pS) and (pM.amClient_LRN = pCF.cfLRN) and
               (not Assigned(Client.clBank_Account_List.FindCode(pS.sbAccount_Number))) then
            begin
              j := AdminSystem.fdSystem_Client_Account_Map.FindIndexOf(pS.sbLRN, pCF.cfLRN);
              if j > -1 then
                AdminSystem.fdSystem_Client_Account_Map.AtDelete(j);
              if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, pCF.cfLRN)) then
                // its now unattached
                pS.sbAttach_Required := True;
            end
            else
              Inc(i);
          end;
          // If client was sychronised this session then need to delete all created client-account maps
          if Client.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number then
          begin
            for i := 0 to Pred(Client.clBank_Account_List.ItemCount) do
            begin
              pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(Client.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
              if Assigned(ps) then
              begin
                j := AdminSystem.fdSystem_Client_Account_Map.FindIndexOf(pS.sbLRN, pCF.cfLRN);
                if j > -1 then
                  AdminSystem.fdSystem_Client_Account_Map.AtDelete(j);
                if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, pCF.cfLRN)) then
                  // its now unattached
                pS.sbAttach_Required := True;
              end;
            end;
          end;
        end;
        Client.Free;
        Client := nil;

        //*** Flag Audit ***
        SystemAuditMgr.FlagAudit(arAttachBankAccounts);

        SaveAdminSystem;
     end;
  end;
end;
{$IFNDEF TESTLOCKING}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure OpenClient(OpenCode : string; IsDDE: Boolean = False);
//the user is loading the client to work on it.  This client will be loaded
//into the myClient global object
const
  ThisMethodName = 'OpenClient';
var
  pCF : pClient_File_Rec;
  FileName: string;
  {PurgeDate: integer;
  EntriesBefore, TotalDeleted: integer;
  sMsg: string; }
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  try
    MsgBar('Loading Client',true);
    if Assigned(MyClient) then
      CloseClientHomePage;

    if ( OpenCode <> '') and ( Assigned( AdminSystem)) then
    begin
      RefreshAdmin;
      //check to see if current user has access to this file
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( OpenCode);
      if Assigned( pCF) then
      begin
        if not AdminSystem.fdSystem_File_Access_List.Allow_Access( CurrUser.LRN, pCF^.cfLRN ) then
        begin
          HelpfulErrorMsg( 'You do not have access to file ' + OpenCode + '.', 0);
          Exit;
        end;
      end;
    end;

    //OpenAClient handles the admin system
    OpenAClient(OpenCode,MyClient,false, True, False, IsDDE);  //allow read only

    if Assigned(MyClient) then
    begin
       with MyClient.clFields do
         AddToMRU( clCode, clName );

       SyncClientToAdmin(MyClient,False,False,False,False,Assigned(AdminSystem) and AdminSystem.fdFields.fdAuto_Retrieve_New_Transactions);

       //Apply fix for invalid GST Apply Dates
       FixClientInvalidGSTRateAppliesDates;

       //update cached admin contact details
       if Assigned( AdminSystem) then
       begin
         pCF := AdminSystem.fdSystem_Client_File_List.FindCode( OpenCode);
         if Assigned( pCF) then
         begin
           RefreshContactDetails( MyClient, pCF, syncDir_AdminToClient);
         end;
       end;
       BatchReports.XMLString := MyClient.clFields.clFavourite_Report_XML; 
    end;

  finally
    UpdateName;
    UpdateMenus;
    RefreshHomepage([HPR_Client]);
    ClearStatus(True);
    MsgBar('',false);
  end;

  if Assigned(MyClient) then begin
     {if Assigned(AdminSystem) and (not MyClient.clFields.clRetain_Entries) and (AdminSystem.fdFields.fdExpire_Client_Entries > 0) then
     begin
        sMsg := 'Do you want to purge all Entries before %s. (%d entries)'#13#13 +
         'WARNING: This will permanently remove these entries from ' + MyClient.clFields.clCode + '.';
        PurgeDate := IncDate( MyClient.clFields.clFinancial_Year_Starts, 0, 0, -exYears[AdminSystem.fdFields.fdExpire_Client_Entries]);
        EntriesBefore := CountEntriesToPurge ( PurgeDate, False, nil);
        if EntriesBefore > 0 then
        begin
          if AskYesNo('Automatically Purge Old Entries', Format( sMsg, [BkDate2Str(PurgeDate), EntriesBefore]), DLG_YES, 0) = DLG_YES then
          begin
            PurgeEntriesFromMyClient( PurgeDate, False, TotalDeleted, nil );
            if TotalDeleted > 0 then
            begin
              sMsg := Format( '%s purged %d Entries prior to %s.', [ ShortAppName,TotalDeleted, BkDate2Str( PurgeDate)]);
              HelpfulInfoMsg( sMsg,0);
            end;
          end
          else // Don't ask again - but can be reset in Client Details
            MyClient.clFields.clRetain_Entries := True;
        end;
     end;}

     if INI_ShowClientProperties then
        ShowClientProperties;

     if MyClient.clFields.clShow_Notes_On_Open then
        ShowClientNotesOnOpen := True;

     if (MyClient.clFields.clWeb_Export_Format = wfWebX) and IsWebFileWaiting then
     begin
       if AskYesNo(WebXDisplayName + ' New File', 'There is a new ' + WebXDisplayName +
            ' file waiting to be imported.'#13#13'Would you like to import this file now?', DLG_YES, 0) = DLG_YES then
       begin
         FileName := '';
         ImportECodingFileFromFile( MyClient, FileName,true, ecDestWebX);
       end;
     end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CloseClient( Interactive : boolean = false; DoClientHomePage: Boolean = True): Boolean;
//close the global client, the interactive flag tells us whether or not
//to prompt the user on close.  It is set to false by default
const
  ThisMethodName = 'CloseClient';
var
  ShowTasks : boolean;
  pCF       : pClient_File_Rec;
  aMsg      : string;
  rMsg      : string; //review message
  BackupRequired, WasChanged : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False;
   if Assigned(MyClient) then
   begin
      try
        MsgBar('Closing Client',true);
        if not CloseMDIChildren(Assigned(AdminSystem) and (not Globals.ApplicationIsTerminating) and DoClientHomePage) then
          //could not close all the child windows
          Exit;

        //Check the status of the client file. Don't save if it has been openned Read Only
        if (not MyClient.clFields.clFile_Read_Only) then begin
           MyClient.clFields.clFavourite_Report_XML := BatchReports.XMLString;
           WasChanged := DoClientSave(true, MyClient);
        end else
           WasChanged := False;

        if Interactive then
        begin
          if Assigned( AdminSystem) then
          begin
            //if prompt is on the ask user about tasks
            if (AdminSystem.fdFields.fdTask_Tracking_Prompt_Type = ttOnlyIfOutstanding)
            and (not CurrUser.HasRestrictedAccess) then
            begin
              pCF := AdminSystem.fdSystem_Client_File_List.FindCode( MyClient.clFields.clCode);
              if Assigned( pCF) then
                ShowTasks := ( pCF^.cfPending_ToDo_Count > 0) and (( pCF^.cfNext_ToDo_Rem_Date = 0) or
                                                                   ( pCF^.cfNext_ToDo_Rem_Date < CurrentDate))
              else
                ShowTasks := false;

              if ShowTasks then
              begin
                aMsg := 'There are one or more overdue tasks';
                rMsg := 'Do you want to review them now?';

                aMsg := aMsg + ' for client ' + pCF^.cfFile_Code + ' : ' + pCF^.cfFile_Name + #13#13 + rMsg;

                ShowTasks := AskYesNo( 'Closing Client ' + pCF^.cfFile_Code+ '...',
                                       aMsg, DLG_YES, 0) = DLG_YES;
              end;
            end
            else
              ShowTasks := False;

            if ShowTasks then
              ToDoHandler.MaintainToDoItems( MyClient.clFields.clCode, true);
          end
          else if WasChanged then // books
          begin
            BackupRequired := (INI_BackupLevel <> 0) and not ( MyClient.clFields.clFile_Read_Only);
            if BackupRequired then
              OffsiteBackup.DoOffsiteBackup( MyClient.clFields.clCode);
          end;
        end;
        if ((not Assigned(AdminSystem)) or (Assigned(CurrUser) and (CurrUser.HasRestrictedAccess))) and
           (not Globals.ApplicationIsTerminating) and (DoClientHomePage) then
          CloseClientHomePage;
        MyClient.Free;
        MyClient := nil;
        BatchReports.XMLString := '';
      finally
         MsgBar('',false);
         UpdateName;
         UpdateMenus;
      end;
   end;
   Result := True;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AbandonChanges(ConfirmAction : boolean): Boolean;
const
   ThisMethodName = 'AbandonChanges';
var
  WasAbandoned   : Boolean;

   function Abandon: Boolean;
   begin
      {destroy client object without saving}
      AbandonClientHomePage;
      RefreshClientManager;
      Result := CloseMDIChildren(True);
      if (Result) then
      begin
        AbandonAClient(MyClient);
        BatchReports.XMLString := '';
        WasAbandoned := True;
      end;
   end;

var
  S              : string;
  FileDateTime   : TDateTime;
  SaveDateTime   : TDateTime;
  VarDateTime    : TDateTime;
  Button         : Integer;
  ClientCode     : String;
begin
   WasAbandoned := False;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   try
      if Assigned(MyClient) then begin
         if ConfirmAction then
         begin
           FileAge(DATADIR + MyClient.clFields.clCode + FILEEXTN, FileDateTime);
           FileAge(DATADIR + MyClient.clFields.clCode + AUTOSAVEEXTN, SaveDateTime);
           if (FileDateTime > SaveDateTime) then
           begin
             //the client file is newer than the last auto-saved file
             if (AskYesNo('Abandon Changes','Abandoning the file will close it without saving changes. '
                        + 'Are you sure you want to do this?', DLG_NO, BKH_Closing_a_client_file) = DLG_YES) then begin
                //log info
                ClientCode := MyClient.clFields.clCode;
                if (Abandon) then
                  LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ': ABANDON Changes to Client File ' + ClientCode);
             end;
           end else
           begin
             VarDateTime := SaveDateTime;
             S := 'Abandon changes made since the last auto-save';
             if (Trunc(VarDateTime) = Date) then
               S := S + ', Today'
             else
               S := S + ' on ' + DateToStr(VarDateTime);
             S := S + ' at ' + TimeToStr(VarDateTime);

             Button := SelectFromRadioDialog( 'Abandon Changes',
                          'Abandoning the file will close it without saving changes.'#13+
                          'What do you want to do?',
                          '&Abandon', 'Cancel',
                          BKH_Closing_a_client_file,
                          S,
                          'Abandon changes made since the last manual save');

             case Button of
               1 :
                 begin
                   //use the auto-save file as the client file
                   if DeleteFile(DATADIR + MyClient.clFields.clCode + FILEEXTN) then
                   begin
                     if RenameFile(DATADIR + MyClient.clFields.clCode + AUTOSAVEEXTN, DATADIR + MyClient.clFields.clCode + FILEEXTN) then
                       LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ': Revert to last auto save for ' + MyClient.clFields.clCode)
                     else
                       LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ': Revert to last auto save for ' + MyClient.clFields.clCode + ' FAILED');
                   end;
                   Abandon; //clean up
                 end;
               2 :
                 begin
                   ClientCode := MyClient.clFields.clCode;
                   if (Abandon) then
                     LogUtil.LogMsg( lmInfo, UnitName, ThisMethodName + ': ABANDON Changes to Client File ' + ClientCode);
                 end;
             else
             begin
               Result := WasAbandoned;
               Exit;
             end;
             end;
           end;
         end
         else
           //no need to ask the user, confirm action was false
           Abandon;
      end;
   finally
      MsgBar('',false);
      UpdateName;
      UpdateMenus;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   Result := WasAbandoned;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SaveClient;
{save the global client, but dont close}
const
  ThisMethodName = 'SaveClient';
begin
 if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
 if Assigned(MyClient) then begin
   try
    //Check the status of the client file. Don't save if it has been openned Read Only
    if (not MyClient.clFields.clFile_Read_Only) then
    begin
      MyClient.clFields.clFavourite_Report_XML := BatchReports.XMLString;
      MsgBar('Saving Client',true);
      DoClientSave(false, MyClient);
    end;
   finally
     MsgBar('',false);
     UpdateName;
     UpdateMenus;
   end;
 end;
 if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure OpenFromMRU(Sender: TObject);
const
   ThisMethodName = 'OpenFromMRU';
var
  S : string;
  p : integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  //Extract Code from TMenuItem Caption
  S := TMenuItem(Sender).Caption;
  //Trim number off front
  p := Pos(' ',S);
  S := Copy(S, p+1, Length(S));
  // Replace &
  S := StringReplace(S, '&&', '&', [rfReplaceAll]);
  //Remove File Name
  p :=  pos( #9, S ) - 1;
  if p <= 0 then
     p := Length( S );
  S := Copy( S, 1, p );

  OpenClient(S);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendPracticeClient(Code: string; Path: string; ProgressFrm: TfrmChkProgress;
  var AClientEmail: string; IsScheduledReport: Boolean = False; Silent: Boolean = False;
  AllowMultiplePwdFiles: Boolean = False; ASendMethod: byte = 0;
  FlagReadOnly: Boolean = True): Boolean;
const
  ThisMethodName = 'SendPracticeClient';
var
  TempClient: TClientObj;
  TempClientIsOffsite: boolean;
  CFRec: pClient_File_Rec;
  LocalFileName: string;
  RemoteFileName: string;
  Msg: string;
  ClientName: string;
begin
  Result := False;
  TempClient := nil;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  LocalFileName  := DATADIR + CODE + FILEEXTN;
  RemoteFileName := Path + CODE + FILEEXTN;

  //check if this is the code for the current client
  if Assigned(MyClient) and (MyClient.clFields.clCode = Code) then begin
    //make sure this is not a read only file
    if MyClient.clFields.clFile_Read_Only then begin
      Msg := 'Cannot send a read-only file [' + Code + ']';
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
      if not IsScheduledReport then
        ProgressFrm.mProgress.Lines.Add('Skipped ' + Code + ' - ' + Msg);
      Exit;
    end;

    //file is not read only, proceed using the currently selected client
    if not CloseMDIChildren(True) then begin
      //could not close all the child windows
      Exit;
    end;
    if IsScheduledReport then
      TempClient := MyClient
    else
      OpenAClient(Code, TempClient,silent,False,AllowMultiplePwdFiles);
    if not IsScheduledReport then
      MyClient := nil;
    UpdateName;
    UpdateMenus;
    RefreshHomepage([HPR_Client]);
  end else
    OpenAClient(Code, TempClient, Silent, False, AllowMultiplePwdFiles);

  if not Assigned(TempClient) then begin
    Msg := Format('Cannot Open Client %s',[Code]);
    LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
    if not IsScheduledReport then
      ProgressFrm.mProgress.Lines.Add('Skipped ' + Code + ' - ' + Msg);
    Exit;
  end;

  ClientName  := TempClient.clFields.clName;
  AClientEmail := Trim(TempClient.clFields.clClient_EMail_Address);

  try
    StatusSilent := false;   //what is this doing? (Matt&Andy)
    try
      SyncClientToAdmin( TempClient, IsScheduledReport, True, Silent );
      SyncMasterMemorised( TempClient );
      EmbedCustomLogo( TempClient);
      TempClientIsOffsite := (TempClient.clFields.clDownload_From <> dlAdminSystem);
      //*** Test
      TempClient.clExtra.ceFile_Transfer_Method := ASendMethod;
    finally
      StatusSilent := true;
    end;

    //Close client
    if not IsScheduledReport then
      CloseAClient( TempClient )
    else begin
      TempClient.clWas_Code := TempClient.clFields.clCode;
      DoClientSave(false, Tempclient);
    end;

    //Copy/Upload client file
    try
      case ASendMethod of
        ftmNone,
        ftmFile:
              begin
                FCopy.CopyFile(LocalFileName, RemoteFileName);
                if DebugMe then
                  LogUtil.LogMsg(lmDebug, UnitName, Format('%s : Copied to %s',
                                 [ThisMethodName, RemoteFileName]));
                //Check that crc is valid of new file
                CrcFileUtils.CheckEmbeddedCRC( RemoteFileName);
              end;
        ftmOnline:
              begin
                //Check we have a valid email address for BankLink Online
                { TODO -oSW : Validate email }
                if (AClientEmail = '') then
                  raise EUploadFailed.Create('Invalid email address.');

                BankLinkOnlineMgr.Silent := IsScheduledReport;
                BankLinkOnlineMgr.UploadClient(Code, ProgressFrm, ClientName,
                                               AClientEmail);
                if DebugMe then
                  LogUtil.LogMsg(lmDebug, UnitName, Format('%s : Uploaded to %s',
                                 [ThisMethodName, BankLinkLiveName]));
              end;
      end;
    except
      //Copy file exception
      on E : EFCopyFailed do begin
        Msg := Format( 'File Copy Failed %s.', [ E.Message ] );
        LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' : '+Msg);
        if not IsScheduledReport then
          ProgressFrm.mProgress.Lines.Add('Skipped '+Code+' - '+Msg);
        Exit;
      end;
      //CRC exception
      on E : EInOutError do begin
        Msg := '** CRC Check failed for '+CODE+'.  Error: ' + E.Message;
        LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
        if not IsScheduledReport then
          ProgressFrm.mProgress.Lines.Add(Msg);
        Exit;
      end;
      //CRC failed
      on E : ECRCCheckFailed do begin
        Msg := '** CRC Check failed for '+CODE;
        LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg +'  Error: ' + E.Message);
        if not IsScheduledReport then
          ProgressFrm.mProgress.Lines.Add(Msg);
        Exit;
      end;
      //BankLink Online exception
      on E : EUploadFailed do begin
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + E.Message);
        if not IsScheduledReport then
          ProgressFrm.mProgress.Lines.Add('Skipped ' + Code + ' - ' + E.Message);
        Exit;
      end;
    end;

    //Update admin system client file rec
    if LoadAdminSystem(true, ThisMethodName ) then begin
      CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
      if not Assigned( CFRec ) then begin
        Msg := Format( 'Could not find CF Record for %s',[Code]);
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
        raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
      end;

      //Set to read only or offsite in practice
      CFRec.cfCurrent_User := CurrUser.LRN;
      if TempClientIsOffsite then begin
        //Offsite
        CFRec.cfFile_Status := fsOffsite;
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %s status set to offsite',
                         [ThisMethodName, Code]));
      end else if FlagReadOnly then begin
        //Read Only
        CFRec.cfFile_Status := fsCheckedOut;
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %s status set to read-only',
                         [ThisMethodName, Code]));
      end;

      //Update send method
      if ASendMethod <> ftmNone then
        CFRec.cfFile_Transfer_Method := ASendMethod;

      //Scheduled report tasks will be added after email has been successfully sent
      if not IsScheduledReport then
        AddAutomaticToDoItem(CFRec, ttyCheckOut, Format(ToDoMsg_Checkout, [bkDate2Str(CurrentDate)]));

      //*** Flag Audit ***
      SystemAuditMgr.FlagAudit(arSystemClientFiles);

      SaveAdminSystem;
    end;
  finally
    if not IsScheduledReport then begin
      TempClient.Free;
      TempClient := nil;
      ProgressFrm.Refresh;
    end;
  end;

  Result := True;
  case ASendMethod of
    ftmNone,
    ftmFile: Msg := Format('Send %s to %s succeeded',[Code, RemoteFileName]);
    ftmOnline      : Msg := Format('Send %s to %s ''%s\%s'' succeeded',
                                   [Code, BANKLINK_ONLINE_NAME,
                                    AdminSystem.fdFields.fdBankLink_Code, Code]);
  end;
  LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
  if not IsScheduledReport then
    ProgressFrm.mProgress.Lines.Add(Msg);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendBooksClient(Code: string; Path: string; ProgressFrm: TfrmChkProgress;
  var AClientEmail: string; IsScheduledReport: Boolean = False; Silent: Boolean = False;
  AllowMultiplePwdFiles: Boolean = False; ASendMethod: byte = 0; FlagReadOnly: boolean = true): Boolean;
const
  ThisMethodName = 'SendBooksClient';
var
  TempClient: TClientObj;
  LocalFileName: string;
  RemoteFileName: string;
  BackupFileName: string;
  Msg: string;
  SendCopy: Boolean;
begin
  //Never comes in here for scheduled reports - admin system must exist
  //admin system does not exists so is an off-site client
  Result := False;
  TempClient := nil;
  SendCopy := (not FlagReadOnly);

  LocalFileName  := DATADIR + CODE + FILEEXTN;
  RemoteFileName := Path + CODE + FILEEXTN;
  BackupFileName := DATADIR + CODE + BACKUPEXTN;

  if Assigned(MyClient) and (MyClient.clFields.clCode = Code) then begin
    AClientEmail := MyClient.clFields.clPractice_Name + #9' ' +
                    MyClient.clFields.clPractice_EMail_Address;
    if MyClient.clFields.clCustom_Contact_EMail_Address <> '' then
      AClientEmail := MyClient.clFields.clContact_Name + #9' ' +
                      MyClient.clFields.clCustom_Contact_EMail_Address;
    SendCopy := (ASendMethod = ftmOnline) and (MyClient.clFields.clDisable_Offsite_Check_Out or (not FlagReadOnly));
    FlagReadOnly := FlagReadOnly or (MyClient.clFields.clForce_Offsite_Check_Out);
    if (not SendCopy) and MyClient.clFields.clDisable_Offsite_Check_Out then begin
      Msg := 'Cannot mark client file ' + CODE +
             ' as read-only because the option is disabled';
      LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
      ProgressFrm.mProgress.Lines.Add(Msg);
      Exit;
    end else if not CloseClient then begin
      Msg := 'Cannot close client file ' + CODE;
      LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
      ProgressFrm.mProgress.Lines.Add(Msg);
      Exit;
    end;
  end else begin //is send disabled?
    OpenAClient( Code, TempClient, true, false, true);
    if Assigned( TempClient) then begin
      SendCopy := (ASendMethod = ftmOnline) and (TempClient.clFields.clDisable_Offsite_Check_Out or (not FlagReadOnly));
      FlagReadOnly := FlagReadOnly or (TempClient.clFields.clForce_Offsite_Check_Out);
      if (not SendCopy) and TempClient.clFields.clDisable_Offsite_Check_Out then begin
        CloseAClient(TempClient);
        Msg := 'Cannot mark client file ' + CODE +
               ' as read-only because the option is disabled';
        LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
        ProgressFrm.mProgress.Lines.Add(Msg);
        Exit;
      end;
      AClientEmail := TempClient.clFields.clPractice_Name + #9' ' +
                      TempClient.clFields.clPractice_EMail_Address;
      if TempClient.clFields.clCustom_Contact_EMail_Address <> '' then
        AClientEmail := TempClient.clFields.clContact_Name + #9' ' +
                        TempClient.clFields.clCustom_Contact_EMail_Address;
      CloseAClient(TempClient);
    end else if (ASendMethod = ftmOnline) then begin
      //Need to get email for banklink online
      OpenAClientForRead( Code, TempClient);
      if Assigned( TempClient) then begin
        FlagReadOnly := FlagReadOnly or (TempClient.clFields.clForce_Offsite_Check_Out);      
        AClientEmail := TempClient.clFields.clPractice_Name + #9' ' +
                        TempClient.clFields.clPractice_EMail_Address;
        if TempClient.clFields.clCustom_Contact_EMail_Address <> '' then
          AClientEmail := TempClient.clFields.clContact_Name + #9' ' +
                          TempClient.clFields.clCustom_Contact_EMail_Address;
        CloseAClient(TempClient);
      end;
    end;
  end;

  //Take a backup copy
  if BKFileExists(BackupFileName) then
    DeleteFile(BackupFileName);
  FCOPY.CopyFile(LocalFileName, BackupFileName);

  //Copy/Upload client file
  try
    case ASendMethod of
      ftmNone,
      ftmFile:
            begin
              if DebugMe then begin
                Msg := Format('%s : Send Copy to %s', [ThisMethodName, RemoteFileName]);
                LogUtil.LogMsg(lmDebug, UnitName, Msg);
              end;
              FCopy.CopyFile(LocalFileName, RemoteFileName);
              if DebugMe then
                LogUtil.LogMsg(lmDebug, UnitName, Format('%s : Copied to %s',
                               [ThisMethodName, RemoteFileName]));
              //Check that crc is valid of new file
              CrcFileUtils.CheckEmbeddedCRC(RemoteFileName);
            end;
      ftmOnline:
            begin
              if DebugMe then begin
                Msg := Format('%s : Send Copy to %s', [ThisMethodName, BANKLINK_ONLINE_NAME]);
                LogUtil.LogMsg(lmDebug, UnitName, Msg);
              end;
              BankLinkOnlineMgr.Silent := IsScheduledReport;
              BankLinkOnlineMgr.UploadClient(Code, ProgressFrm, '', '', SendCopy);
              if DebugMe then
                LogUtil.LogMsg(lmDebug, UnitName, Format('%s : Uploaded to %s',
                               [ThisMethodName, BankLinkLiveName]));
            end;
    end;
  except
    on E : EFCopyFailed do begin
      Msg := Format( 'File Copy Failed %s.', [E.Message]);
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
      ProgressFrm.mProgress.Lines.Add('Skipped '+ Code + ': ' + Msg);
      Exit;
    end;
    on E : EInOutError do begin
      Msg := '** CRC Check failed for ' + CODE + '.  Error: ' + E.Message;
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' ' + Msg);
      ProgressFrm.mProgress.Lines.Add(Msg);
      Exit;
    end;
    on E : ECRCCheckFailed do begin
      Msg := '** CRC Check failed for ' + CODE;
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' ' + Msg + '  Error: ' + E.Message);
      ProgressFrm.mProgress.Lines.Add(Msg);
      Exit;
    end;
    //BankLink Online exception
    on E : EUploadFailed do begin
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + E.Message);
      if not IsScheduledReport then
        ProgressFrm.mProgress.Lines.Add('Skipped ' + Code + ' - ' + E.Message);
      Exit;
    end;
  end;

  //Backup exists, remote file has been crc checked
  if FlagReadOnly then begin
    OpenAClient(Code, TempClient, true, false, true);
    if Assigned(TempClient) then begin
      if SendCopy then
        //Copy sent to BankLink Online - do not mark as read-only!
      else if not TempClient.clFields.clFile_Read_Only then begin
        //Decrement the file save count so it matches the sent file
        Dec(TempClient.clFields.clFile_Save_Count);
        //Mark the local file as read only
        TempClient.clFields.clFile_Read_Only := true;
        //Force to save so that read only flag is saved
        CloseAClient(TempClient, True);
      end else
        CloseAClient( TempClient);
    end else
      LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' Could not mark ' +
                                       Code + ' as read-only');
  end;

  Result := True;
  case ASendMethod of
    ftmNone,
    ftmFile  : Msg := Format('Send %s to %s succeeded',[Code, RemoteFileName]);
    ftmOnline: if SendCopy then
                 Msg := Format('Send copy %s to %s succeeded',[Code, BANKLINK_ONLINE_NAME]);    
               else
                 Msg := Format('Send %s to %s succeeded',[Code, BANKLINK_ONLINE_NAME]);
  end;
  LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
  if not IsScheduledReport then
    ProgressFrm.mProgress.Lines.Add(Msg);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Code for sending an individual client file
function SendClient(Code: string; Path: string; ProgressFrm: TfrmChkProgress;
  var AClientEmail: string;
  IsScheduledReport: Boolean = False; Silent: Boolean = False;
  AllowMultiplePwdFiles: Boolean = False; ASendMethod: byte = 0;
  FlagReadOnly: boolean = true): Boolean;
const
  ThisMethodName = 'SendClient';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  ProgressFrm.ClientCode := Code;
  if not IsScheduledReport then
    ProgressFrm.mProgress.Lines.Add( 'Sending client ' + Code);

  if Assigned(AdminSystem) then begin
    //Practice Client File
    ProgressFrm.PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
    Result := SendPracticeClient(Code, Path, ProgressFrm, AClientEmail,
                                 IsScheduledReport, Silent,
                                 AllowMultiplePwdFiles, ASendMethod,
                                 FlagReadOnly)
  end else
    //Books Client File
    Result := SendBooksClient(Code, Path, ProgressFrm, AClientEmail,
                              IsScheduledReport, Silent,
                              AllowMultiplePwdFiles, ASendMethod, FlagReadOnly);

  if not IsScheduledReport then begin
    ProgressFrm.BringToFront;
    ProgressFrm.SetFocus;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function SendClient(Code : string; Path : string; ASendMethod: byte = 0;
  FlagReadOnly: boolean = true) : Boolean;
const
  ThisMethodName = 'SendClient';
var
  ClientEmail: string;
begin
  Result := False;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned( AdminSystem) then
    Exit;

  //Send client file for scheduled reports
  Result := SendPracticeClient(Code, Path, nil, ClientEmail,
                               True, True, False, ASendMethod, True);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function GetEmailAddress(ACodeList: TStringList): string;
//Only returns an email address if they are the same for all client files sent
var
  i: integer;
  LastEmail: string;
begin
  Result := '';
  LastEmail := '';
  for i := 0 to ACodeList.Count - 1 do begin
    if (ACodeList.ValueFromIndex[i] <> '') and
       (ACodeList.ValueFromIndex[i] <> '*') then begin
      if (LastEmail = '') then begin
        LastEmail := ACodeList.ValueFromIndex[i];
        Result := LastEmail;
      end else if (ACodeList.ValueFromIndex[i] <> LastEmail) then begin
        Result := '';
        Exit;
      end;
    end;
  end;
end;

function GetEmailAddresses(ACodeList: TStringList; var EmailCount: integer): string;
//Returns non-blank email addresses for the client files sent
var
  i: integer;
  EmailAddress: string;
  EmailList: TStringList;
begin
  Result := '';
  EmailList := TStringList.Create;
  try
    EmailList.StrictDelimiter := True;
    EmailList.Delimiter := bkConst.VALUES_DELIMITER;
    for i := 0 to ACodeList.Count - 1 do begin
      EmailAddress := Trim(ACodeList.ValueFromIndex[i]);
      if (EmailAddress <> '') and
         (EmailAddress <> '*') then begin
        if (EmailList.IndexOf(EmailAddress) = -1) then
          EmailList.Add(EmailAddress);
      end;
    end;
    Result := EmailList.DelimitedText;
  finally
    EmailList.Free;
  end;
end;

function GetClientWithNoEmail(ACodeList: TStringList): string;
//Returns a delimited list of client codes for clients with invalid email addresses
var
  i: integer;
begin
  Result := '';
  for i := 0 to ACodeList.Count - 1 do begin
    if (ACodeList.ValueFromIndex[i] = '') then begin
      if (Result = '') then
        Result := ACodeList.Names[i]
      else
        Result := Result + ', ' + ACodeList.Names[i];
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SendClientFiles(CodesToSend : string = ''; ASendMethod: byte = 0;
  AFirstUpload: boolean = False; AFlagReadOnly: boolean = False;
  AEditEmail: boolean = False; ASendEmail: boolean = False);
const
  ThisMethodName = 'SendClientFiles';
var
  i: integer;
  CodeList: TStringList;
  SentClientCodes: string;
  ProgressFrm: TfrmChkProgress;
  Failures: Integer;
  ClientEmail, PracticeEmail, PracticeEmailList: string;
  EmailBody: string;
  Msg: string;
  NoEmail: string;
  ClientObj : TClientObj;
  EmailCount: integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  CodeList := TStringList.Create;
  try
    StatusSilent := true;
    try
      CodeList.Delimiter := ClientCodeDelimiter;
      CodeList.StrictDelimiter := true;
      if CodesToSend <> '' then
        CodeList.DelimitedText := CodesToSend
      else begin
        CodeList.DelimitedText := SelectCodesToSend('Select Client(s) to Send',
                                                    ASendMethod, AFirstUpload,
                                                    AFlagReadOnly, AEditEmail, ASendEmail);
        if CodeList.DelimitedText = '' then
          Exit;
      end;

      ProgressFrm := TfrmChkProgress.Create(Application.MainForm);
      try
        ProgressFrm.mProgress.Lines.Add('');
        ProgressFrm.mProgress.Lines.Add('Sending files');
        ProgressFrm.mProgress.Lines.Add('');
        ProgressFrm.Caption := 'Send Progress';
        ProgressFrm.btnOK.Enabled := false;
        ProgressFrm.Show;
        ProgressFrm.Refresh;
        //Cycle thru each client, updating transactions without asking
        Failures := 0;

        ClientEmail := '';
        SentClientCodes := '';
        for i := 0 to CodeList.Count -1 do begin
          if not SendClient(CodeList[i], Globals.INI_CheckOutDir, ProgressFrm, ClientEmail,
                            False, (CodeList.Count > 1) , True, ASendMethod, AFlagReadOnly) then begin
            //Flag email for failures
            ClientEmail := '*';
            Inc(Failures);
          end else begin
            //Add to comma delimited list of client codes
            if i = 0 then
              SentClientCodes := CodeList[i]
            else
              SentClientCodes := SentClientCodes + ', ' + CodeList[i];
          end;
          //Save the email address
          CodeList[i] := CodeList[i] + '=' + ClientEmail;
        end;

        if Assigned(AdminSystem) and (GetClientWithNoEmail(CodeList) <> '') then begin
          Msg := Format('A valid email address is required for clients files to '+
                        'be sent via %s. Please update the following clients: %s',
                        [BANKLINK_ONLINE_NAME, GetClientWithNoEmail(CodeList)]);
          HelpfulErrorMsg(Msg, 0);
        end;

        ProgressFrm.mProgress.Lines.Add('');
        ProgressFrm.mProgress.Lines.Add('Send Completed');
        if (Failures > 0) then begin
          ProgressFrm.mProgress.Lines.Add('');
          ProgressFrm.mProgress.Lines.Add(Format('%d Clients failed to be sent.',
                                                 [Failures]));
        end;
        ProgressFrm.btnOK.Enabled := true;
        ProgressFrm.Hide;
        ProgressFrm.ShowModal;
        ProgressFrm.BringToFront;


        //If sent from Practice,
        //   to banklink online,
        //   and at least one file has been uploaded...
        if (Assigned(AdminSystem)) and
           (ASendMethod = ftmOnline) and
           (ASendEmail) and
           (CodeList.Count > Failures) then begin
          //Send email
          EmailBody := Format('The following Client File(s) are now available ' +
                              'via %s: %s.' + #10 + 'To access the ' +
                              'client file(s) select ‘Get Client Files | from ' +
                              'BankLink Online’.',
                              [BANKLINK_ONLINE_NAME, SentClientCodes]);
          if AFirstUpload then
            EmailBody := EmailBody + #10#10 +
                         'Subdomain: ' + GetBankLinkOnlineSubDomain +  #10 +
                         'Username: ' + GetEmailAddress(CodeList) + #10#10 +
                         'If you are new to ' + BANKLINK_ONLINE_NAME + ', you will receive ' +
                         'an email shortly which will help you complete the ' +
                         'setup process. Please wait for this email before continuing.';
          SendMailTo('Send Client File(s) via ' + BankLinkLiveName,
                     GetEmailAddress(CodeList),
                     'BankLink Books File for ' + SentClientCodes,
                     EmailBody, '', False);
        end;

        //If sent from Books,
        //   to banklink online,
        //   and at least one file has been uploaded...
        if not (Assigned(AdminSystem)) and
           (ASendMethod = ftmOnline) and
           ((AEditEmail) or (GetEmailAddress(CodeList) = '')) and
           (CodeList.Count > Failures) then begin
          PracticeEmail := GetEmailAddress(CodeList);
          PracticeEmail := Trim(Copy(PracticeEmail, Pos(#9, PracticeEmail) + 2, Length(PracticeEmail)));
          PracticeEmailList := GetEmailAddresses(CodeList, EmailCount);
          if EmailCount = 1 then
            PracticeEmail := '';
          //Send email
          EmailBody := '';
          SendMailTo('Send Client File(s) via ' + BankLinkLiveName,
                     PracticeEmail,
                     'BankLink Books File for ' + SentClientCodes,
                     EmailBody, '', False, PracticeEmailList);
        end;


      finally
        ProgressFrm.Free;
      end;
    finally
      StatusSilent := false;
    end;
  finally
    CodeList.Free;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckInClient(Code : string; Path : string; ProgressFrm : TfrmChkProgress;
  IsScheduledReports: Boolean = False; ASendMethod: byte = 0) : boolean;
const
   ThisMethodName = 'CheckInClient';
var
   CFRec          : pClient_File_Rec;
   LocalFileName,
   RemoteFileName,
   BackupFileName,
   RemoteRename   : string;
   Wrapper        : TClientWrapper;
   WrapperOfExistingFile : TClientWrapper;
   Msg            : string;
   Attributes  : Integer;
   aClient        : TClientObj;
   RemapAccounts : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CFRec := nil;
   RemapAccounts := False;
   Result := False;
   LocalFileName  := DATADIR + CODE + FILEEXTN;
   RemoteFileName := Path + CODE + FILEEXTN;
   if (ASendMethod = ftmOnline) then
     RemoteRename   := ''
   else
     RemoteRename   := Path + CODE + RENAMEEXTN;
   BackupFileName := DATADIR + CODE+ BACKUPEXTN;

   Msg := 'Updating Client '+Code;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' '+Msg);

   if not IsScheduledReports then
   begin
     ProgressFrm.mProgress.Lines.Add( Msg);
     ProgressFrm.Refresh;
   end;

   if (ASendMethod = ftmOnline) then
   try
     //Download the client file from BankLink Online to the temp folder
     BankLinkOnlineMgr.Silent := IsScheduledReports;
     BankLinkOnlineMgr.DownloadClient(Code, ProgressFrm, RemoteFilename);
   except
      on E : EDownloadFailed do begin
         Msg := Format('Download from %s failed for %s.  Error: %s',
                       [BANKLINK_ONLINE_NAME, CODE, E.Message]);
         LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
         if not IsScheduledReports then
           ProgressFrm.mProgress.Lines.Add( Msg);
         Exit;
      end;
   end;

   //see if the file exists, this is in case the wrapper code differs to the
   //file name
   if not FileExists( RemoteFilename) then
   begin
     Msg := 'Cannot update client ' + code + ' because the file ' + RemoteFilename +
            ' cannot be found.';
     LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
     if not IsScheduledReports then
       ProgressFrm.mProgress.Lines.Add( Msg);
     exit;
   end;

   //make sure this is not a read only file
   if Assigned( MyClient) and ( MyClient.clFields.clCode = Code) then
   begin
     Msg := 'Cannot update file ' + Code + ' because you currently have it open';
     if (MyClient.clFields.clFile_Read_Only) then
       Msg := Msg + ' in read-only mode';
     Msg := Msg + '.';

     LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' : '+Msg);
     if not IsScheduledReports then
       ProgressFrm.mProgress.Lines.Add('Skipped '+Code+' - '+Msg);
     Result := False;
     exit;
   end;

   //clear read only status on remote file (if set) so that can read wrapper and
   //rename file to bk!
   Attributes := FileGetAttr( RemoteFileName);
   if (Attributes <> -1) then begin
      if (Attributes and faReadOnly) <> 0 then begin
         //current file is read only, clear read only flag so can rename
         FileSetAttr( RemoteFileName, Attributes and not faReadOnly);
      end;
   end;

   //check that crc is valid
   try
      CrcFileUtils.CheckEmbeddedCRC( RemoteFileName);
   except
      on E : EInOutError do begin
         Msg := '** CRC Check failed for '+CODE+'.  Error: ' + E.Message;
         LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
         if not IsScheduledReports then
           ProgressFrm.mProgress.Lines.Add( Msg);
         exit;
      end;

      on E : ECRCFileOpen do begin
         Msg := '** CRC Check failed for '+CODE+'.  Error: ' + E.Message;
         LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
         if not IsScheduledReports then
           ProgressFrm.mProgress.Lines.Add( Msg);
         exit;
      end;

      on E : ECRCCheckFailed do begin
         Msg := '** CRC Check failed for '+CODE;
         LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg +'  Error: ' + E.Message);
         if not IsScheduledReports then
           ProgressFrm.mProgress.Lines.Add( Msg);
         exit;
      end
   end;
   //make sure we can read the file wrapper, this will check we have
   //access to the file
   try
      GetClientWrapper( RemoteFileName, Wrapper, true);  //to check age
   except
      on e : EFileWrapper do begin
         Msg := '** Cannot Read File ' + CODE + ' Error: ' + E.Message;
         LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
         if not IsScheduledReports then
           ProgressFrm.mProgress.Lines.Add( Msg);
         exit;
      end;
   end;

   if Assigned( AdminSystem) then begin
      {test admin system to see make sure status is read-only}
      if RefreshAdmin then begin
         //verify is read-only
         CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

         if Assigned( CFRec ) then begin  {found in admin so test that is read-only}
            //Don't do this check for BankLink Online files because the
            //user has already said they want to overwrite the Client File.
            if (ASendMethod <> ftmOnline) and (not (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite])) then begin
               Msg := Format( '** CF Record for %s file status not Read-only or Off-site',[Code]);
               LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
               if not IsScheduledReports then
                 ProgressFrm.mProgress.Lines.Add( Msg);
               exit;
            end;

            //check the age of the file, Wrapper will have been read above
            if (not IsScheduledReports) and (Wrapper.wSave_Count < cfRec.cfFile_Save_Count) then
               if AskYesNo('Update Client','The client file '+ CODE+ ' is OLDER than the file currently held by the Admin system.  You may lose some data '+
                       'if you update this client.  Please confirm you want to proceed.',dlg_no,0) <> DLG_YES then
               begin
                  Msg := '** User aborted update of '+CODE+'.  File version older than in Admin system';
                  LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
                  ProgressFrm.mProgress.Lines.Add( Msg);
                  exit;
               end;
         end;

         //check wrapper version now so dont update a file that cant be openned
         if ( Wrapper.wVersion > BKDEFS.BK_FILE_VERSION) then
         begin
           Msg := 'Invalid version. Version ' + Wrapper.wVersion_Reqd_Str + ' or later required to update this client file';
           LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' '+Msg);
           ProgressFrm.mProgress.Lines.Add( Msg);
           exit;
         end;
      end;

      if BKFileExists(LocalFileName) then begin
         {backup existing file, then delete}
         DeleteFile(BackupFileName);
         RenameFile(LocalFileName,BackupFileName);
         DeleteFile(LocalFileName);
      end;

      {copy in new file}
      if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,ThisMethodName+' '+Format('Copying file from %s to %s',[remoteFilename, localfilename]));
      Try
         FCopy.CopyFile( RemoteFileName, LocalFileName );
      Except
         on E : EFCopyFailed do begin
            Msg := Format( 'File Copy Failed %s.', [ E.Message ] );
            LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' : '+Msg);
            if not IsScheduledReports then
              ProgressFrm.mProgress.Lines.Add( 'Skipped '+Code+': '+Msg);
            exit;
         end;
      end;

      //rename updated file to *.BK!
      DeleteFile(RemoteRename);
      RenameFile(RemoteFileName,RemoteRename);

      {all ok.. now tell admin system}
      if LoadAdminSystem(true, ThisMethodName ) then begin
        {update admin}
        CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

        if not Assigned( CFRec ) then begin
          {not found in admin system so need to create a CF record for this client}
          {note this client may be from a foreign system, if so it will not be able}
          {to receive new data}
          Msg := Format('Adding new client file %s',[Code]);
          LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName+' '+Msg);

//        Wrapper is now read above while file is still in remote location
//          GetxWrapper(LocalFileName, Wrapper, false);  //during update

          CFRec := New_Client_File_Rec;
          with AdminSystem, cfRec^, Wrapper do begin
            cfFile_Code           := wCode;
            cfFile_Name           := wName;
            case wSignature of
              BANKLINK_SIGNATURE  : cfFile_Type := 0;
              SBOOKS_SIGNATURE    : cfFile_Type := 1;
            end;
            cfFile_Status         := fsNormal;
            cfDate_Last_Accessed  := CurrentDate;
            cfFile_Save_Count     := wSave_Count;
            cfUser_Responsible    := 0;
            cfCurrent_User        := 0;
            //don't do password here, as it's done in SyncAdminToClient and password
            //is hashed in the wrapper now. Case 9444
            //cfFile_Password       := wOldPassword;
            cfReport_Start_Date   := wReport_Start_Date;
            cfReporting_Period    := wReporting_Period;
            cfForeign_File        := wMagic_Number <> fdFields.fdMagic_Number;
            {update the LRN}
            Inc( fdFields.fdClient_File_LRN_Counter );
            cfLRN                 := fdFields.fdClient_File_LRN_Counter ;
          end;
          AdminSystem.fdSystem_Client_File_List.Insert(CFRec);
          RemapAccounts := True;
        end
        else begin
          CFRec.cfFile_Status := fsNormal;
          CFRec.cfCurrent_User := 0;
        end;

        //resynchronise admin cache as details may have changed while file
        //was offsite
        OpenAClientForRead( CFRec^.cfFile_Code, aClient);
        if Assigned( aClient) then
        begin
          try
            SyncAdminToClient( CFRec, aClient);
            RefreshContactDetails( aClient, CFRec, syncDir_ClientToAdmin);
            if RemapAccounts then
               ReSyncClientAccountMap(aClient);
                                   

            UpdateProcessingStats(aClient, True, False);
          finally
            FreeAndNil( aClient);
          end;
        end;

        //*** Flag Audit ***
        SystemAuditMgr.FlagAudit(arAttachBankAccounts);
        //Add audit info for update - this has to be aaNone because
        //File_Status=fsNormal is not audited to prevent too many audit records.
        Msg := Format('File_Code=%s%sFile_Status=Updated',[CFRec.cfFile_Code, VALUES_DELIMITER]);
        SystemAuditMgr.FlagAudit(arSystemClientFiles, CFRec.cfAudit_Record_ID, aaNone, Msg);

        SaveAdminSystem;
      end;
   end
   else begin
      //no admin system.. must be banklink client
      if BKFileExists(LocalFileName) then
      begin
         Msg := '';
         try
           GetClientWrapper( LocalFilename, WrapperOfExistingFile, False);
           //Test if read-only (BankLink Online allows overwriting writable Client files in Books
           if (ASendMethod <> ftmOnline) and not WrapperOfExistingFile.wRead_Only then
             Msg := Format('**A writable copy of file %s already exists.  Cannot update',[LocalFileName]);

           //Test if file older than current
           if (Wrapper.wSave_Count < WrapperOfExistingFile.wSave_Count) then begin
             Msg := Format('The client file %s is OLDER than the file currently ' +
                           'available. You may lose some data if you update this ' +
                           'client. Please confirm you want to proceed.', [CODE]);
             if AskYesNo('Update Client', Msg, dlg_no, 0) <> DLG_YES then
             begin
                Msg := Format('%s ** User aborted update of %s. File version ' +
                              'older than current file', [ThisMethodName, CODE]);
                LogUtil.LogMsg(lmInfo, UnitName, Msg);
                ProgressFrm.mProgress.Lines.Add( Msg);
                exit;
             end else
               Msg := '';
           end else if (Wrapper.wSave_Count = WrapperOfExistingFile.wSave_Count) and
                       (ASendMethod <> ftmOnline) then begin
             //The client file save count of a file re-sent by Practice via BankLink Online
             //can be the same as the client file in Books - but it cannot be read-only -
             //so we don't need to do this check.
             Msg := 'This file is the same as your current read-only file. ' +
                    'Do you wish to reset the read-only status so you can ' +
                    'make changes to the file?';
             if AskYesNo('Reset Read-only Status', Msg, dlg_no, 0) <> DLG_YES then
             begin
                Msg := Format('%s ** User aborted update of %s. File ' +
                              'is the same as current read-only file',
                              [ThisMethodName, CODE]);
                LogUtil.LogMsg(lmInfo, UnitName, Msg);
                ProgressFrm.mProgress.Lines.Add( Msg);
                exit;
             end else begin
               //Reset read-only
               try
                 ResetReadOnlyFlag(Code, ASendMethod);
               except
                 Msg := Format('** Could not reset read-only status for %s.', [ CODE ]);
                 LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
                 ProgressFrm.mProgress.Lines.Add(Msg);
                 Exit;
               end;
               Msg := Format('Read-only status reset for %s.', [ CODE ]);
               LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg);
               ProgressFrm.mProgress.Lines.Add(Msg);
               Result := True;
               Exit;
             end;
           end;

         except
           on E : Exception do
           begin
             //unable to read wrapper, assume that a conflict will exist
             Msg := Format('**A writable copy of file %s already exists.  Cannot update',[LocalFileName]);
           end;
         end;

         if Msg <> '' then
         begin
           LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' : '+Msg);
           ProgressFrm.mProgress.Lines.Add( 'Skipped '+Code+': '+Msg);
           exit;
         end
         else
         begin
           {backup existing file, then delete}
           DeleteFile(BackupFileName);
           RenameFile(LocalFileName,BackupFileName);
           DeleteFile(LocalFileName);
         end;
      end;

      Try
         FCopy.CopyFile( RemoteFileName, LocalFileName );
      Except
         on E : EFCopyFailed do begin
            Msg := Format( '** File Copy Failed %s.', [ E.Message ] );
            LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName + ' : '+Msg);
            ProgressFrm.mProgress.Lines.Add( 'Skipped '+Code+': '+Msg);
            exit;
         end;
      end;
      DeleteFile(RemoteRename);
      RenameFile(RemoteFileName,RemoteRename);

      //open the file and clear the read only flag if set
      if Wrapper.wRead_Only then
      begin
        ResetReadOnlyFlag( Code, ASendMethod);
        ProgressFrm.mProgress.Lines.Add( 'Read-only flag cleared');
      end;
   end;

   if (ASendMethod = ftmOnline) then
     Msg := Format('Update %s from %s succeeded',[Code, BANKLINK_ONLINE_NAME])
   else
     Msg := Format('Update %s from %s succeeded',[Code, RemoteFileName]);
   LogUtil.LogMsg(lmInfo,unitname,ThisMethodName+' '+Msg);

   if not IsScheduledReports and Assigned( AdminSystem) then
   begin
     if Assigned(CFRec) then     
       CloseCheckOutTask(CFRec);
     AddAutomaticToDoItem(Code, ttyCheckIn, Format(ToDoMsg_CheckIn, [bkDate2Str(CurrentDate)]), 0, 0, true);
   end;

   if not IsScheduledReports then
     ProgressFrm.mProgress.Lines.Add(Msg);
   Result := True;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Checkin(ASendMethod: byte; CodesToCheckIn : string = '');
const
   ThisMethodName = 'Checkin';
var
  CodeList    : TStringList;
  i           : integer;
  ProgressFrm : TfrmChkProgress;

  SuccessCount,
  ErrorCount  : integer;
  Title: string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CodeList := TStringList.Create;
   ProgressFrm := TfrmChkProgress.Create(Application.MainForm);
   try
      StatusSilent := true;

      CodeList.Delimiter := ClientCodeDelimiter;
      CodeList.StrictDelimiter := True;
      Title := 'Select Client(s) to Update';
      if (ASendMethod = ftmOnline) then
        Title := Title + ' from ' + BANKLINK_ONLINE_NAME;
      CodeList.DelimitedText := SelectCodesToGet(Title, ASendMethod, CodesToCheckIn);
      if CodeList.Count = 0 then
        Exit;

      //Now have a list of clients to update and a valid dir
      //cycle thru each client, updating transactions without asking
      with ProgressFrm do begin
        Caption := 'Update Progress';
        ProgressFrm.mProgress.Lines.Add('');
        ProgressFrm.mProgress.Lines.Add('Updating files');
        ProgressFrm.mProgress.Lines.Add('');

        btnOK.Enabled := False;
        Show;
        Refresh;
      end;

      SuccessCount := 0;
      ErrorCount   := 0;

      for i := 0 to CodeList.Count -1 do begin
        if CheckInClient(CodeList[i], Globals.INI_CheckInDir, ProgressFrm, False, ASendMethod) then
          Inc( SuccessCount)
        else
          Inc( ErrorCount);
      end;

      with ProgressFrm do begin
        ProgressFrm.mProgress.Lines.Add('');
        if SuccessCount = 0 then
          ProgressFrm.mProgress.Lines.Add('Update FAILED')
        else
        begin
          if ErrorCount = 0 then
            ProgressFrm.mProgress.Lines.Add( 'Update Completed')
          else
            ProgressFrm.mProgress.Lines.Add( 'Update Completed -  ' +
                                             inttostr( SuccessCount) + ' file(s) OK  ' +
                                             inttostr( ErrorCount) + ' file(s) FAILED');
        end;


        btnOK.Enabled := True;
        Hide;
        ShowModal;
      end;
   finally
     StatusSilent := false;
     ProgressFrm.Free;
     CodeList.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckInRemoteClient( filename : string) : boolean;
//this function differs from the existing checkinClient in that it accepts
//a file rather than a code.  This is to allow the file to be updated
//from a file named AUCODED (1).BK5 when the actual code is AUCODED.BK5
//
//Initially this will be used for the right-click checkin, however refactoring
//should be done to extract the common parts of this routine
//
//Have removed all of the links to progress form
const
  ThisMethodName = 'CheckInRemoteClient';
var
   CFRec          : pClient_File_Rec;
   LocalFileName,
   RemoteFileName,
   BackupFileName,
   RemoteRename   : string;
   Wrapper        : TClientWrapper;
   WrapperOfExistingFile : TClientWrapper;
   aMsg            : string;
   Attributes: Integer;
   aClient: TClientObj;
   RemapAccounts: Boolean;
   Code: string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   RemapAccounts := False;
   Result := False;
   RemoteFilename := filename;
   RemoteRename := Uppercase(ChangeFileExt( RemoteFilename, RENAMEEXTN));
   CFRec := nil;

   //catch any exceptions are show in error message
   try
     //clear read only status on remote file (if set) so that can read wrapper and
     //rename file to bk!
     Attributes := FileGetAttr( RemoteFileName);
     if (Attributes <> -1) then begin
        if (Attributes and faReadOnly) <> 0 then begin
           //current file is read only, clear read only flag so can rename
           FileSetAttr( RemoteFileName, Attributes and not faReadOnly);
        end;
     end;

     //check that crc is valid
     try
        CrcFileUtils.CheckEmbeddedCRC( RemoteFileName);
     except
        on E : EInOutError do begin
           aMsg := '** CRC Check failed.  Error: ' + E.Message;
           raise ECheckIn.Create( aMsg);
        end;

        on E : ECRCFileOpen do begin
           aMsg := '** CRC Check failed.  Error: ' + E.Message;
           raise ECheckIn.Create( aMsg);
        end;

        on E : ECRCCheckFailed do begin
           aMsg := '** CRC Check failed';
           raise ECheckIn.Create( aMsg);
        end
     end;

     //make sure we can read the file wrapper, this will check we have
     //access to the file
     try
        GetClientWrapper( RemoteFileName, Wrapper, true);  //to check age
     except
        on e : EFileWrapper do begin
           aMsg := '** Cannot Read File ' + filename + ' Error: ' + E.Message;
           raise ECheckIn.Create( aMsg);
        end;
     end;

     //need the code from within the file, read wrapper
     Code := Wrapper.wCode;

     LocalFileName  := DATADIR + CODE + FILEEXTN;
     BackupFileName := DATADIR + CODE+ BACKUPEXTN;

     //make sure this is not a read only file
     if Assigned( MyClient) and ( MyClient.clFields.clCode = Code) then
     begin
       aMsg := 'Cannot update file because you currently have client ' + Code + ' open';
       if (MyClient.clFields.clFile_Read_Only) then
         aMsg := aMsg + ' in read-only mode';
       aMsg := aMsg + '.';
       raise ECheckIn.Create( aMsg);
     end;

     if Assigned( AdminSystem) then begin
        {test admin system to see make sure status is read-only}
        if RefreshAdmin then begin
           //verify is read-only
           CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

           if Assigned( CFRec ) then begin  {found in admin so test that is read-only}
              if not ( CFRec.cfFile_Status in [ fsCheckedOut, fsOffsite ] ) then begin
                 aMsg := Format( '** Client %s file status is not Read-only or Off-site',[Code]);
                 raise ECheckIn.Create( aMsg);
              end;

              //check the age of the file, Wrapper will have been read above
              if (Wrapper.wSave_Count < cfRec.cfFile_Save_Count) then
                 if AskYesNo('Update Client','The file for client '+ CODE+ ' is OLDER than the file currently held by the Admin system.  You may lose some data '+
                         'if you update this file.  Please confirm you want to proceed.',dlg_no,0) <> DLG_YES then
                 begin
                    aMsg := '** User aborted update of '+CODE+'.  File version older than in Admin system';
                    raise ECheckIn.Create( aMsg);
                 end;
           end;

           //check wrapper version now so dont update a file that cant be openned
           if ( Wrapper.wVersion > BKDEFS.BK_FILE_VERSION) then
           begin
             aMsg := 'Invalid version. Version ' + Wrapper.wVersion_Reqd_Str + ' or later required to update this client file';
             raise ECheckIn.Create( aMsg);
           end;
        end;

        if BKFileExists(LocalFileName) then begin
           {backup existing file, then delete}
           DeleteFile(BackupFileName);
           RenameFile(LocalFileName,BackupFileName);
           DeleteFile(LocalFileName);
        end;

        {copy in new file}
        Try
           FCopy.CopyFile( RemoteFileName, LocalFileName );
        Except
           on E : EFCopyFailed do begin
              aMsg := Format( 'File Copy Failed %s.', [ E.Message ] );
              raise ECheckIn.Create( aMsg);
           end;
        end;

        //rename updated file to *.BK!
        DeleteFile(RemoteRename);
        RenameFile(RemoteFileName,RemoteRename);

        {all ok.. now tell admin system}
        if LoadAdminSystem(true, ThisMethodName ) then begin
          {update admin}
          CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code );

          if not Assigned( CFRec ) then begin
            {not found in admin system so need to create a CF record for this client}
            {note this client may be from a foreign system, if so it will not be able}
            {to receive new data}
            aMsg := Format('Adding new client file %s',[Code]);
            LogUtil.LogMsg(lmInfo,UnitName,ThisMethodName+' '+aMsg);

            CFRec := New_Client_File_Rec;
            with AdminSystem, cfRec^, Wrapper do begin
              cfFile_Code           := wCode;
              cfFile_Name           := wName;
              case wSignature of
                BANKLINK_SIGNATURE  : cfFile_Type := 0;
                SBOOKS_SIGNATURE    : cfFile_Type := 1;
              end;
              cfFile_Status         := fsNormal;
              cfDate_Last_Accessed  := CurrentDate;
              cfFile_Save_Count     := wSave_Count;
              cfUser_Responsible    := 0;
              cfCurrent_User        := 0;
              //don't do password here, as it's done in SyncAdminToClient and password
              //is hashed in the wrapper now. Case 9444
              //cfFile_Password       := wOldPassword;
              cfReport_Start_Date   := wReport_Start_Date;
              cfReporting_Period    := wReporting_Period;
              cfForeign_File        := wMagic_Number <> fdFields.fdMagic_Number;
              {update the LRN}
              Inc( fdFields.fdClient_File_LRN_Counter );
              cfLRN                 := fdFields.fdClient_File_LRN_Counter ;
            end;
            AdminSystem.fdSystem_Client_File_List.Insert(CFRec);
            RemapAccounts := True; // Check any account mapping  (Books save as..)


          end
          else begin
            CFRec.cfFile_Status := fsNormal;
            CFRec.cfCurrent_User := 0;
          end;

          //resynchronise admin cache as details may have changed while file
          //was offsite
          OpenAClientForRead( CFRec^.cfFile_Code, aClient);
          if Assigned( aClient) then
          begin
            try
              SyncAdminToClient(CFRec, aClient);
              RefreshContactDetails(aClient, CFRec, syncDir_ClientToAdmin);
              if RemapAccounts then
                 ReSyncClientAccountMap(aClient);
              UpdateProcessingStats(aClient, True, False);
            finally
              FreeAndNil( aClient);
            end;
          end;

           //*** Flag Audit ***
          SystemAuditMgr.FlagAudit(arAttachBankAccounts);
          
          SaveAdminSystem;
        end;
     end
     else begin
        //no admin system.. must be banklink client
        if BKFileExists(LocalFileName) then
        begin
           aMsg := '';
           //see if the existing file is writable
           try
             GetClientWrapper( LocalFilename, WrapperOfExistingFile, False);
           except
             on E: EFileWrapper do
               raise ECheckIn.Create( E.Message);
           end;

           //Test if already checked-in
           if not WrapperOfExistingFile.wRead_Only then begin
             aMsg := Format('** Client %s file status is not Read-only',[Code]);
             raise ECheckIn.Create( aMsg);
           end;

           //Test if file older than current
           if (Wrapper.wSave_Count < WrapperOfExistingFile.wSave_Count) then begin
             aMsg := Format('The client file %s is OLDER than the file currently ' +
                            'available. You may lose some data if you update this ' +
                            'client. Please confirm you want to proceed.', [CODE]);
             if AskYesNo('Update Client', aMsg, dlg_no, 0) <> DLG_YES then
             begin
                aMsg := Format('%s ** User aborted update of %s. File version ' +
                               'older than the current file', [ThisMethodName, CODE]);
                raise ECheckIn.Create( aMsg);
             end;
           end;

           {backup existing file, then delete}
           DeleteFile(BackupFileName);
           RenameFile(LocalFileName,BackupFileName);
           DeleteFile(LocalFileName);
        end;

        Try
           FCopy.CopyFile( RemoteFileName, LocalFileName );
        Except
           on E : EFCopyFailed do begin
              aMsg := Format( '** File Copy Failed %s.', [ E.Message ] );
              raise ECheckIn.Create( aMsg);
           end;
        end;
        DeleteFile(RemoteRename);
        RenameFile(RemoteFileName,RemoteRename);

        //open the file and clear the read only flag if set
        if Wrapper.wRead_Only or (Wrapper.wFileTransferMethod <> ftmFile) then
        begin
          ResetReadOnlyFlag(Code, ftmFile);
        end;
     end;

   except
     on E : ECheckIn do
     begin
       LogUtil.LogMsg( lmError, Unitname, ThisMethodName + ': ' +
                       'Update from ' + RemoteFilename + ' failed - ' + E.Message);
       HelpfulErrorMsg( 'Update of ' + ExtractFilename( RemoteFilename) + ' failed.' + #13#13 + E.Message, 0);
       if Assigned(AdminSystem) then
         DoClientManager(0,0,0,0);
       Exit;
     end;
   end;

   //no errors prompt user to open file
   aMsg := Format('Update %s from %s succeeded',[Code,RemoteFileName]);
   LogUtil.LogMsg(lmInfo,unitname,ThisMethodName+' '+aMsg);

   if Assigned( AdminSystem) then
   begin
     if Assigned(CFRec) then     
       CloseCheckOutTask(CFRec);
     AddAutomaticToDoItem(Code, ttyCheckIn, Format(ToDoMsg_CheckIn, [bkDate2Str(CurrentDate)]), 0, 0, true);
   end;

   if Assigned(MyClient) then begin
      HelpfulInfoMsg( 'Update of ' + ExtractFilename( RemoteFilename) + ' succeeded.', 0);
      RefreshClientManager;
   end else begin
       if AskYesNo( 'Open Client File',
                  'Update of ' + ExtractFilename( RemoteFilename) + ' succeeded.' +
                  #13#13 + 'Do you want to open this client file now?', dlg_yes, 0) = dlg_yes then
       begin
          if Assigned(AdminSystem) then
             DoClientManager(0,0,0,0);
          OpenClient( Code);
          RefreshHomepage([HRP_Init]);
       end else
          if Assigned(AdminSystem) then
             DoClientManager(0,0,0,0);
   end;

   Result := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SaveAs;
//save a copy of the global myclient object
const
   ThisMethodName = 'SaveAs';
var
  NewCode, NewName : string;
  OldFileName : string;
  NewFileName : string;

  Code        : string;

  pCF         : pClient_File_Rec;
  CFRec       : pClient_File_Rec;
  Msg         : string;

  pS: pSystem_Bank_Account_Rec;
  pM, pM1: pClient_Account_Map_Rec;
  i: Integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if not Assigned(MyClient) then exit;

  NewCode := MyClient.clFields.clCode;
  NewName := MyClient.clFields.clName;

  if GetSaveAsDetails(NewCode,NewName) then
  begin
    if Assigned( AdminSystem) then
    begin
      {update the admin system. mark current code closed, create new admin record}
      if LoadAdminSystem(true, ThisMethodName ) then
      begin
         Code := MyClient.clFields.clCode;
         pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Code );
                                            
         If not Assigned( pCF ) then begin
            Msg := Format( 'Could not find CF Record for %s',[Code]);
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
            Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         {create new client file rec}
         CFRec := New_Client_File_Rec;
         with AdminSystem, cfRec^ do
         begin
           cfFile_Code           := NewCode;
           cfFile_Name           := pCf^.cfFile_Name;
           cfFile_Type           := pCf^.cfFile_Type;
           if (MyClient.clFields.clFile_Read_Only) then
             cfFile_Status       := fsOpen
           else                                          
             cfFile_Status       := pCf^.cfFile_Status;
           cfDate_Last_Accessed  := pcf^.cfDate_Last_Accessed;
           cfFile_Save_Count     := pCf^.cfFile_Save_Count;
           cfUser_Responsible    := pCf^.cfUser_Responsible;
           cfGroup_LRN           := pCf^.cfGroup_LRN;
           cfClient_Type_LRN     := pCf^.cfClient_Type_LRN;
           cfCurrent_User        := pCf^.cfCurrent_User;
           cfFile_Password       := pcf^.cfFile_Password;
           cfReport_Start_Date   := pcf^.cfReport_Start_Date;
           cfReporting_Period    := pcf^.cfReporting_Period;
           cfForeign_File        := pcf^.cfForeign_File;
           cfBulk_Extract_Code   := pcf^.cfBulk_Extract_Code;
           cfArchived            := pcf^.cfArchived;

           {update the LRN}
           Inc( fdFields.fdClient_File_LRN_Counter );
           cfLRN := fdFields.fdClient_File_LRN_Counter ;
         end;
         AdminSystem.fdSystem_Client_File_List.Insert(CFRec);

         // Check Tasks..
         if Sysutils.FileExists( GetTaskListFilename(pCF.cfLRN)) then
             CopyFile(GetTaskListFilename(pCF.cfLRN), GetTaskListFilename(CFRec.cfLRN));

         if AdminSystem.fdSystem_File_Access_List.Restricted_User( CurrUser.LRN) then
           AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( CurrUser.LRN, cfRec.cfLRN );

         // Create client-account maps
         for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
         begin
           pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
           if Assigned(pS) and (not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, cfREC.cfLRN))) then
           begin
             pM := New_Client_Account_Map_Rec;
             if Assigned(pM) then
             begin
               pM.amClient_LRN := cfREC.cfLRN;
               pM.amAccount_LRN := pS.sbLRN;
               pM1 := AdminSystem.fdSystem_Client_Account_Map.FindLRN(pS.sbLRN, pcf.cfLRN);
               if Assigned(pM1) then begin
                  pM.amLast_Date_Printed := pM1.amLast_Date_Printed;
                  pM.amEarliest_Download_Date := pM1.amEarliest_Download_Date;
               end else begin
                  pM.amLast_Date_Printed := 0;
                  pM.amEarliest_Download_Date := MaxInt;
               end;
               AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
             end;
           end;
         end;

         if (not MyClient.clFields.clFile_Read_Only) then
         begin
           {mark current file as closed}
           pCF^.cfCurrent_User        := 0;
           pCF^.cfFile_Status         := fsNormal;
         end;

         //*** Flag Audit ***
         SystemAuditMgr.FlagAudit(arAttachBankAccounts);
         SystemAuditMgr.FlagAudit(arSystemClientFiles);

         SaveAdminSystem;
      end;

      {save files}
      OldFileName := DATADIR + MyClient.clFields.clCode;
      NewFileName := DATADIR + NewCode;


      with MyClient.clFields do
      begin
        clCode := NewCode;
        clName := NewName;
        MyClient.clWas_Code := NewCode;  {so doesnt try to rename}
        clFile_Read_Only := False; //allow to save as even if it's read only
        clUse_Alterate_ID_for_extract := false;  //default back to client code to avoid duplicates
      end;

      SaveClient;

      //delete the autosave file if it exists
      DeleteFile(OldFileName + AUTOSAVEEXTN);
    end else
    begin
      OldFileName := DATADIR + MyClient.clFields.clCode;
      NewFileName := DATADIR + NewCode;

      with MyClient.clFields do
      begin
        clCode := NewCode;
        clName := NewName;

        MyClient.clWas_Code := NewCode;  {so doesnt try to rename}
        clFile_Read_Only := False; //allow to save as even if it's read only
        clUse_Alterate_ID_for_extract := false;  //default back to client code to avoid duplicates
      end;

      SaveClient;

      //delete the autosave file if it exists
      DeleteFile(OldFileName + AUTOSAVEEXTN);

      OldFileName := OldFileName + FILEEXTN;
      NewFileName := NewFileName + FILEEXTN;

      MsgBar('',false);
      UpdateName;
      UpdateMenus;
    end;
    LogUtil.LogMsg(lmInfo,UnitName,Format('%s : Saving %s as %s',[ThisMethodName,OldFileName,NewFileName]));
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;


{$ENDIF}

initialization
   DebugMe := DebugUnit(UnitName);
end.



