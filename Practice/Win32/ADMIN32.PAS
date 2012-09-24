unit Admin32;
//------------------------------------------------------------------------------
{
   Title:        Admin file control unit

   Description:  Controls access to the system.db file

   Remarks:      Rewritten to leave the lock.$$$ file open so that locking actually
                 works. The lock file is closed when the admin system is unlocked.

                 The unit failed before because a file could be created by another
                 workstation in between the fileExists test and the rewrite
                 statement on the current PC.  In this case an access violation
                 would occur when trying to write the lock.$$$ file.

   Author:       Matthew Hopkins Jan 2001

}
//------------------------------------------------------------------------------
interface
uses
  SYSOBJ32,
  SYDEFS,
  CLASSES,
  Blowunit,
  Cryptutils;

CONST
   LockAdminSystem     : Boolean = True;
   DontLockAdminSystem : Boolean = False;

function  AdminExists : Boolean;

//function  AdminHasChanged : Boolean;
//function  AdminSystemOK : boolean;  {must exist AND be assigned}

//there are now two calls to load admin system, one handles all of the existing
//call in the system so that we do not have to edit everywhre.  This is not
//ideal but a the time this change was made I (MH) was nervous about making
//large scale changes this close to a release  ( Apr 2003)
function  LoadAdminSystem( HoldLock : Boolean; RequestedBy : string; IsEncrypted: Boolean = True) : boolean;
function  LockAndLoadAdminSystem( HoldLock : boolean;
                           RequestedBy : string;
                           UpdateSnapshot : boolean;
                           var aSnapshot : TSystemObj;
                           IsEncrypted: Boolean = True) : boolean;

function  RefreshAdmin : boolean;  {dont hold lock}

procedure SaveAdminSystem(IsEncrypted: Boolean = True);  {save and release lock}
function  LockAdmin( RequestedBy : string ) : Boolean;
procedure UnlockAdmin;

procedure ReloadAdminAndTakeSnapshot( var aSnapshot : TSystemObj);
{$IFDEF LOOKUPDLL}
function SetBKAdminLocation( AdminDir : PChar) : LongBool; stdcall;
{$ENDIF}

procedure IntegrityCheck;
procedure DumpClientAccountMapToFile;

function ValidateUserPassword(User: TUser_Rec; const Password: String): Boolean;
function UpdateUserDataBlock(User: pUser_Rec; const Key: String): Boolean;
function DecryptUserDataBlock(User: TUser_Rec; const Key: String): String;

//******************************************************************************
implementation
uses
   sysutils,
   progress,
   windows,
   forms,
   LogUtil,
{$IFDEF LOOKUPDLL}
   dialogs,
{$ENDIF}
   bkdbexcept,
   bk5except,
{$IF not (Defined(TESTLOCKING) or Defined(LOOKUPDLL))}
   bugfixes,
{$IFEND}
   WinUtils,
   syfdio,
   usrList32,
   cflist32,
   sysDList32,
   sbaList32,
   globals,
   GlobalCache,
   bkConst,
   StBits,
   LockUtils, TimeUtils, bkdateutils;

const
  UnitName = 'ADMIN32';

var
  DebugMe       : boolean = false;
  AdminDate     : Int64 = 0;
  AdminIsLocked : Boolean = False;

function DecryptUserDataBlock(User: TUser_Rec; const Key: String): String;
var
  AuthenticationString: AnsiString;
  Index: Integer;
  KeyHash: String;
begin  
  for Index := 1 to Length(User.usUser_Data_Block) do
  begin
    AuthenticationString := AuthenticationString + AnsiChar(User.usUser_Data_Block[Index]);
  end;

  KeyHash := HashStr(Key + User.usSalt, False);
  
  Result := DecryptStr128(KeyHash, AuthenticationString);
end;

function UpdateUserDataBlock(User: pUser_Rec; const Key: String): Boolean;
var
  AuthenticationString: AnsiString;
  Index: Integer;
  KeyHash: String;
  Salt: String;
begin
  Result := False;

  Salt := RandomString(64);

  KeyHash := HashStr(Key + Salt, False);
  
  AuthenticationString := EncryptStr128(KeyHash, User.usCode);

  if AuthenticationString <> '' then
  begin
    for Index := 1 to Length(AuthenticationString) do
    begin
      User.usUser_Data_Block[Index] := Ord(AuthenticationString[Index]);
    end;

    User.usSalt := Salt;
    User.usUsing_Secure_Authentication := True;
    
    Result := True;
  end
  else
  begin
    FillChar(User.usUser_Data_Block, Length(User.usUser_Data_Block), 0);
    
    User.usUsing_Secure_Authentication := False;
  end;
end;

function ValidateUserPassword(User: TUser_Rec; const Password: String): Boolean;
begin
  if User.usUsing_Secure_Authentication then
  begin
    Result := DecryptUserDataBlock(User, Password) = User.usCode;
  end
  else
  if User.usUsing_Mixed_Case_Password then
  begin
    Result := CompareStr(Password, User.usPassword) = 0;
  end
  else
  begin
    Result := Uppercase(Password) = Uppercase(User.usPassword);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  LockAdmin( RequestedBy : string ) : Boolean;
{called internally only!}
const
   ThisMethodName = 'LockAdmin';
Var
   LockMsgFile     : TextFile;
   LockMsgFileName : String;
Begin
   Assert( not AdminIsLocked, 'The Admin System was already locked by me!' );

   //PracINI_TicksToWait is badly names.  It actually represented milliseconds not ticks!
   AdminIsLocked := ObtainLock( ltAdminSystem, PRACINI_TicksToWaitForAdmin div 1000 );

   If AdminIsLocked then Begin
      //Check for existence of system.$$$ file.  If it still exists this will
      //indicate a crash occured.  File region locking only works while application
      //is active.  Once terminated the lock disappears.
      if BKFileExists( DATADIR + SYSLOCKNAME) then begin
         Raise EAdminSystem.Create( 'Admin Lock File already exists');
      end;

      // Write the user information into the SYSTEM.$$$ file.
      LockMsgFileName := DATADIR + SYSLOCKNAME;
      Assign( LockMsgFile, LockMsgFileName );
      Rewrite( LockMsgFile );
      Writeln( LockMsgFile, Format( 'Admin Locked by [%s] - Requested by %s', [ GlobalCache.cache_Current_Username , RequestedBy ] ) );
      CloseFile( LockMsgFile );
      Result := True;
   end
   else
      Raise EAdminSystem.Create( 'Unable to lock the Admin System' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UnlockAdmin;

Const
   ThisMethodName = 'UnlockAdmin';

Var
   LockMsgFileName : String;
   Msg             : String;
   OK              : Boolean;
begin
   Assert( AdminIsLocked, Format( 'Admin Unlock when not Locked by [%s]', [ GlobalCache.cache_Current_Username ] ) );

   { Delete the message file SYSTEM.$$$ }
   LockMsgFileName := DATADIR + SYSLOCKNAME;
   SysUtils.DeleteFile( LockMsgFileName );

   OK := ReleaseLock( ltAdminSystem );

   If OK then
      AdminIsLocked := False
   else
   Begin
      Msg := Format( 'Unable to unlock the Admin System by [%s]', [ GlobalCache.cache_Current_Username ] );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function  AdminHasChanged : Boolean;
//tells us if the date on the system.db file is different to the last
//version we loaded.
//
// is called by  Admin32.RefreshAdmin
//
var
  TimeNow : Int64;
begin
  if PRACINI_AlwaysReloadAdmin then
    result := true
  else
  begin
    TimeNow := GetFileTimeAsInt64( DATADIR + SYSFILENAME );
    result  := (TimeNow <> AdminDate);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function  AdminExists : Boolean;
begin
   LockAdmin( 'AdminExists');
   try
     AdminExists := BKFileExists(DATADIR + SYSFILENAME);
   finally
     UnlockAdmin;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//function AdminSystemOK : boolean;
//begin
//   result := AdminExists and Assigned(AdminSystem);
//end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SaveAdminSystem(IsEncrypted: Boolean = True);
const
   ThisMethodName = 'SaveAdminSystem';
var
   Msg : String;
begin
   IntegrityCheck;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If not Assigned( AdminSystem ) then begin
      Msg := 'Admin System not Assigned';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
   If not AdminIsLocked then  Begin
      Msg := 'Admin System not locked.  Cannot Save';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
   AdminSystem.Save(IsEncrypted);
   AdminDate := GetFileTimeAsInt64( DATADIR + SYSFILENAME );
//   Sleep( 100);
   UnlockAdmin;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function RefreshAdmin : boolean;
{returns true if we have a valid adminsystem after calling

 note: this could fail for one of two reasons:
   1)  Admin system doesnt exist;
   2)  Admin systems exists but couldnt be loaded;
}
const
   ThisMethodName = 'RefreshAdmin';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := false;

   if Assigned( AdminSystem) then
   begin
     if not AdminHasChanged then {have an adminsystem and it is up to date}
       Result := true
     else
       Result := LoadAdminSystem(false, ThisMethodName );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure IntegrityCheck;
const
   ThisMethodName = 'IntegrityCheck';

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure RaiseIntegrityException( FailureReason : string );
   var Msg : string;
   begin
      Msg := 'Failure '+ FailureReason;
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EDataIntegrity.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

Var
   i        : Integer;
   LastCode : string[30];
   sbLRNS   : TStBits;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Assigned( AdminSystem ) then begin
      with AdminSystem do begin
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         if fdFields.fdRecord_Type <> tkBegin_Practice_Details then begin
            RaiseIntegrityException('fdRecord_Type');
         end;
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         if fdFields.fdEOR <> tkEnd_Practice_Details then begin
            RaiseIntegrityException('fdEOR');
         end;
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         LastCode := '';
         with fdSystem_User_List do Begin
            for i := 0 to Pred( ItemCount ) do with User_At( i )^ do Begin
               if ( usCode < LastCode ) then Begin
                  RaiseIntegrityException('User Code Sequence');
               end;
               LastCode := usCode;
            end;
         end;
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         LastCode := '';
         with fdSystem_Client_File_List do Begin
            for i := 0 to Pred( ItemCount ) do with Client_File_At( i )^ do Begin
               if ( cfFile_Code < LastCode ) then Begin
                  RaiseIntegrityException('Client File Code Sequence');
               end;
               LastCode := cfFile_Code;
            end;
         end;

         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         with fdSystem_Disk_Log do for i := 0 to Pred( ItemCount ) do with Disk_Log_At( i )^ do;
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

         sbLRNS   := TStBits.Create( AdminSystem.fdFields.fdBank_Account_LRN_Counter );
         LastCode := '';
         with fdSystem_Bank_Account_List do Begin
            for i := 0 to Pred( ItemCount ) do with System_Bank_Account_At( i )^ do
            Begin
               if ( sbAccount_Number < LastCode ) then
                 RaiseIntegrityException('Bank Account Number Sequence');

               //check that there are no duplicated LRN numbers or any out of range.
               //This check can be disabled so that user can login to banklink.
               //This check will be also be done before a download
               if not Globals.PRACINI_DisableBankLRNCheck then begin
                  If ( sbLRN < 1 ) or ( sbLRN > AdminSystem.fdFields.fdBank_Account_LRN_Counter ) then
                    RaiseIntegrityException('Bank Account LRN out of range');
                  If sbLRNS.BitIsSet( sbLRN ) then
                    RaiseIntegrityException('Duplicate Bank Account LRN');
                  sbLRNS.SetBit( sbLRN );
               end;
               LastCode := sbAccount_Number;
            end;
         end;

         sbLRNS.Free;

         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LoadAdminSystem( HoldLock : Boolean; RequestedBy : string; IsEncrypted: Boolean = True ) :boolean;
var
  O : TSystemObj;
begin
  O := nil;
  result := LockAndLoadAdminSystem( HoldLock, RequestedBy, false, O, IsEncrypted);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  LockAndLoadAdminSystem( HoldLock : boolean;
                                  RequestedBy : string;
                                  UpdateSnapshot : boolean;
                                  var aSnapshot : TSystemObj;
                                  IsEncrypted: Boolean = True) : boolean;
const
   ThisMethodName = 'LoadAdminSystem';
var
   Msg : String;
   NewAdminObj : TSystemObj;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := false;

   if LockAdmin(RequestedBy) then begin
     try
       If not BKFileExists(DATADIR + SYSFILENAME) then begin
          Msg := 'Unable to find Admin System';
          Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
       end;

       //create a new admin system object before freeing the old object
       //to avoid using the same memory
       Msg := 'Creating New Admin System';
       NewAdminObj := TSystemObj.Create;

       Msg := 'Free old Admin System';
       if Assigned( AdminSystem) then
         FreeAndNil( AdminSystem);

       //Assign new memory
       AdminSystem := NewAdminObj;
       try
         //see if we need to load a snapshot of the admin system
         if UpdateSnapshot then
         begin
           Msg := 'OpenAndSnapshot';
           try
             AdminSystem.OpenAndSnapshot( TObject( aSnapshot), IsEncrypted);
           except on E: EInvalidPointer do                      
             Raise EAdminSystem.Create( 'Sharing Violation: the system.db file is in use by another process' );
           end;
         end
         else
         begin
           Msg := 'Open';
           try
             AdminSystem.Open(IsEncrypted);
           except on E: EInvalidPointer do           
             Raise EAdminSystem.Create( 'Sharing Violation: the system.db file is in use by another process' );
           end;
         end;

         Msg := 'Read Admin TimeStamp';
         AdminDate := GetFileTimeAsInt64( DATADIR + SYSFILENAME );
         Msg := 'New Admin System Created';
         {$IF not (Defined(TESTLOCKING) or Defined(LOOKUPDLL))}
           //Fix bug in GST Effective Dates
           FixAdminInvalidGSTRateAppliesDates;
         {$IFEND}
         Result := true;
         if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
       except
         On E : EInvalidDataInFile do begin
            Raise EAdminSystem.CreateFmt( '%s - %s : ' + E.ClassName + ' %s', [ UnitName, ThisMethodName, E.Message ] );
         end;
         //catch all other errors, reraise as admin system
         On E : Exception do begin
            Raise EAdminSystem.CreateFmt( '%s - %s : %s [%s]', [ UnitName, ThisMethodName, E.Message, Msg ] );
         end;
       end;
     finally
       If not HoldLock then
         UnlockAdmin;
     end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReloadAdminAndTakeSnapshot( var aSnapshot : TSystemObj);
//reloads admin system with the latest copy on disk, loads a copy of the
//admin system into the snapshot
const
  ThisMethodName = 'ReloadAdminAndTakeSnapshot';
begin
  LockAndLoadAdminSystem( false,   //don't hold lock
                          ThisMethodName,
                          true,    //get new snapshot
                          aSnapshot );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFDEF LOOKUPDLL}
function SetBKAdminLocation( AdminDir : PChar) : LongBool; stdcall;
//parameters:
//  AdminDir  : pchar representing the directory to look in for the system.db
//              Cannot be blank, must be a valid directory path,
//              Must include a trailing backslash
//  Returns true if the path is set correctly
var
  aDir : string;
begin
  result := false;
  try
    aDir := AdminDir;

    if (aDir <> '') and DirectoryExists( aDir) then
    begin
      Globals.DataDir := aDir;
      SetLockingFileLocation( aDir);
      result := true;
    end
    else
      raise EAdminSystem.Create( 'Invalid Admin Location (' + aDir + ')');
  except
    on e : exception do
      MessageDlg('Error retrieving client list: ' + E.Message, mtError, [mbOK], 0);
  end;
end;
{$ENDIF}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Write the account/client map to a text file (only if debugging)
procedure DumpClientAccountMapToFile;
var
  F: Text;
  i: LongInt;
  pm: pClient_Account_Map_Rec;
  pf: pClient_File_Rec;
  sb: pSystem_Bank_Account_Rec;
  code, bank, srdate: string;
begin
  if not DebugMe then exit;                    
  try
    AssignFile(F, Globals.DataDir + 'ca_map.txt');
    ReWrite(F);
    for i := 0 to Pred(AdminSystem.fdSystem_Client_Account_Map.ItemCount) do
    begin
      pm := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);

      pf := AdminSystem.fdSystem_Client_File_List.FindLRN(pm.amClient_LRN);
      if Assigned(pf) then
        code := 'clientLRN=' + IntToStr(pm.amClient_LRN) + ' code=' + pf.cfFile_Code
      else
        code := 'clientLRN=' + IntToStr(pm.amClient_LRN) + ' code=UNKNOWN';
      Write(F, Code);

      sb := AdminSystem.fdSystem_Bank_Account_List.FindLRN(pm.amAccount_LRN);
      if Assigned(sb) then
        bank := ', bankLRN=' + IntToStr(pm.amAccount_LRN) + ' name=' + sb.sbAccount_Name + ' number=' + sb.sbAccount_Number
      else
        bank := ', bankLRN=' + IntToStr(pm.amAccount_LRN) + ' name=UNKNOWN number=UNKNOWN';
      Write(F, bank);

      srdate := bkDate2Str(pm.amLast_Date_Printed);
      if srdate = '' then
        srdate := ', sr_date=NOT SET'
      else
        srdate := ', sr_date=' + srdate;
      Write(F, srdate);

      if pm.amEarliest_Download_Date < MaxInt then
         srdate := bkDate2Str(pm.amEarliest_Download_Date)
      else
         srdate := '';
      if srdate = '' then
        srdate := ', ed_date=NOT SET'
      else
        srdate := ', ed_date=' + srdate;
      WriteLn(F, srdate);

      WriteLn(F, '*********************************************************************************');
     end;
     CloseFile(F);
  except
  end;
end;

initialization
   DebugMe        := DebugUnit( UnitName );
end.
