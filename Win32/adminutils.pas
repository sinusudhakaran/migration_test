unit adminutils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UpdateAdminCFStatus( const FileCode   : ShortString;
                               const FileStatus : Byte;
                               const UserLRN    : Longint );

procedure RenameAdminCF(       const OldCode : ShortString;
                               const NewCode : ShortString );

procedure DuplicateAdminCF(    const OldCode : ShortString;
                               const NewCode, NewName : ShortString );
                               
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uses
   globals, Admin32, SyDefs, SyCFIO, BK5Except, LogUtil, BKConst, SysUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const 
   UnitName = 'ADMINUTILS';   
var
   DebugMe : boolean = false;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UpdateAdminCFStatus( const FileCode   : ShortString;
                               const FileStatus : Byte;
                               const UserLRN    : Longint );

const
   ThisMethodName = 'SetAdminCFStatus';
Var
   CFRec : pClient_File_Rec;
   Msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not LoadAdminSystem( LockAdminSystem, 'UpdateAdminCFStatus' ) then 
   begin
      Msg := 'Unable to Lock the Admin System.';
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
   
   CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( FileCode );
   if not Assigned( CFRec ) then
   Begin
      Admin32.UnlockAdmin;
      Msg := Format( 'Admin System update failed: %s not found in Admin System.', [ FileCode ] );
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
         
   CFRec.cfFile_Status  := FileStatus;
   CFRec.cfCurrent_User := UserLRN;
   SaveAdminSystem; { Unlocks it again }
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RenameAdminCF( const OldCode : ShortString;
                         const NewCode : ShortString );
const
   ThisMethodName = 'RenameAdminCF';
Var
   CFRec : pClient_File_Rec;
   Msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not LoadAdminSystem( LockAdminSystem, 'RenameAdminCF' ) then 
   begin
      Msg := 'Unable to Lock the Admin System.';
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

   CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( OldCode );
   if not Assigned( CFRec ) then
   Begin
      Admin32.UnlockAdmin;
      Msg := Format( 'Admin System update failed: %s not found in Admin System.', [ OldCode ] );
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
   
   AdminSystem.fdSystem_Client_File_List.Delete( CFRec );
   CFRec.cfFile_Code := NewCode;
   AdminSystem.fdSystem_Client_File_List.Insert( CFRec );
   SaveAdminSystem; { Unlocks it again }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DuplicateAdminCF(    const OldCode : ShortString;
                               const NewCode, NewName : ShortString );

// Creates a new client file code and marks it as open.                               

const
   ThisMethodName = 'DuplicateAdminCF';
Var
   OldCFRec : pClient_File_Rec;
   NewCFRec : pClient_File_Rec;
   Msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not LoadAdminSystem( LockAdminSystem, 'DuplicateAdminCF' ) then 
   begin
      Msg := 'Unable to Lock the Admin System.';
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

   OldCFRec := AdminSystem.fdSystem_Client_File_List.FindCode( OldCode );
   if not Assigned( OldCFRec ) then
   Begin
      Admin32.UnlockAdmin;
      Msg := Format( 'Admin System update failed: %s not found in Admin System.', [ OldCode ] );
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EAdminSystem.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
                                     
   NewCFRec := New_Client_File_Rec;
   with AdminSystem, NewCFRec^ do
   begin
      cfFile_Code           := NewCode;
      cfFile_Name           := NewName;
      cfFile_Type           := OldCFRec^.cfFile_Type;
      cfFile_Status         := fsOpen;
      cfDate_Last_Accessed  := 0;
      cfFile_Save_Count     := 0;
      cfUser_Responsible    := OldCFRec^.cfUser_Responsible;
      cfGroup               := OldCFRec^.cfGroup;
      cfClient_Type_Name    := OldCFRec^.cfClient_Type_Name;
      cfCurrent_User        := CurrUser.LRN;
      cfFile_Password       := OldCFRec^.cfFile_Password;
      cfReport_Start_Date   := OldCFRec^.cfReport_Start_Date;
      cfReporting_Period    := OldCFRec^.cfReporting_Period;
      cfForeign_File        := OldCFRec^.cfForeign_File;
      cfArchived            := OldCFRec^.cfArchived;

      {update the LRN}
      Inc( fdFields.fdClient_File_LRN_Counter );
      cfLRN := fdFields.fdClient_File_LRN_Counter ;
   end;
   AdminSystem.fdSystem_Client_File_List.Insert( NewCFRec );
   SaveAdminSystem;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
  
end.
