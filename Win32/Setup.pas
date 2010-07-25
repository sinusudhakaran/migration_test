unit Setup;

// BankLink 5 for Windows
// April 1999
// Andrew Bell
//
// This code tests the presence of a Registry Key to determine if this
// is the first time BankLink has been run.
// If the key does not exist (first time run) the following occur
//    Add BankLink Shortcut to Desktop
//    Add EXE location key to Registry
//
// This code assumes that this program is run from the BK5WIN directory
// The Shortcut is created using the TShellLink component described in
// "Managing DeskTop Shortcuts" by Dave Jewell Issue 19 of the Delphi Magazine
//
//------------------------------------------------------------------------------
interface

function TestRegistryForBK5Key : boolean;

function TestUserDirRights : boolean;

procedure SetupBK5;

//******************************************************************************
implementation

uses
   Windows, Registry, Forms, SysUtils, ShellLink, //Delphi Magazine
   ststrl, //TurboPower
   Globals, LockUtils, ErrorMoreFrm, InfoMoreFrm, WinUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TestRegistryForBK5Key : boolean;
// Tests registry for existence of BK5 key
// Used to determine first time BK5 run
begin { TestRegistryForBK5Key }
   Result := false;
   with TRegistry.Create do
   begin
      try
         RootKey := HKEY_LOCAL_MACHINE;
         if KeyExists(Globals.regBK5RootKey) then
         begin
            Result := true;
         end { KeyExists(Globals.regBK5RootKey) };
      finally
         Free;
      end { try };
   end { with TRegistry.Create };
end; { TestRegistryForBK5Key }


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateRegistry(ExePath: string) : boolean;
//Adds/Updates Banklink Registry Key with Exe Path Data Value
//This key is also used to determine if BankLink has been run previously
begin { UpdateRegistry }
   Result := false;
   with TRegistry.Create do
   begin
      try
         RootKey := HKEY_LOCAL_MACHINE;
         if OpenKey(Globals.regBK5RootKey, true) then
         begin
            WriteString(Globals.regExeLocationData, ExePath);
            Result := true;
         end { OpenKey(Globals.regBK5RootKey, true) };
      finally
         CloseKey;
         Free;
      end { try };
   end { with TRegistry.Create };
end; { UpdateRegistry }


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CreateDesktopShortCut(const ShortCutName: string; const Desc: string;
   const ExePathAndName: string; const WorkingDir: string; const Parameters: string) : boolean;
begin { CreateDesktopShortCut }
   //result := false;
   with TShellLink.Create(nil) do
   begin
      try
         WindowState := wsNormal;
         LinkPath := ShortCutName;
         Description := Desc;
         TargetPath := ExePathAndName;
         Arguments := Parameters;
         WorkingDirectory := WorkingDir;
         Result := Save;
      finally
         Free;
      end { try };
   end { with TShellLink.Create(nil) };
end; { CreateDesktopShortCut }


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckRequiredPrivilage(const Path: string; var Msg: string) : boolean;

   // Return True if User can Create/Read/Write/Delete on named Path
   // Msg contains failed Priviliges
   function ConcatMsg(const Msg, S: string) : string;
   begin { ConcatMsg }
      Result := '';
      if Length(Msg) > 0 then
      begin
         Result := Msg + ', ' + S
      end { Length(Msg) > 0 }
      else
      begin
         Result := S
      end { not (Length(Msg) > 0) };
   end; { ConcatMsg }

const
   Filename = 'TEST.$$$';
var
   f  : file of Char;
   ch : Char;
begin { CheckRequiredPrivilage }
   Result := true;
   Msg := '';
   AssignFile(f, Path + Filename);
   ch := 'X';
   try
      try
         if BKFileExists(Path + Filename) then
         begin
            try
               Erase(f); //Delete
            except
               on EInOutError do
                  begin

                     // No message here

                  end;
            end { try };
         end { BKFileExists(Path + Filename) };
         try
            Rewrite(f); //Create
         except
            on EInOutError do
               begin
                  Msg := ConcatMsg(Msg, 'Create');
                  Result := false;
               end;
         end { try };
         try
            Write(f, ch); //Write;
         except
            on EInOutError do
               begin
                  Msg := ConcatMsg(Msg, 'Write');
                  Result := false;
               end;
         end { try };
         CloseFile(f);
         Reset(f);
         try
            Read(f, ch); //Read
         except
            on EInOutError do
               begin
                  Msg := ConcatMsg(Msg, 'Read');
                  Result := false;
               end;
         end { try };
         CloseFile(f);
         try
            Erase(f); //Read
         except
            on EInOutError do
               begin
                  Msg := ConcatMsg(Msg, 'Delete');
                  Result := false;
               end;
         end { try };
      except
         on EInOutError do
            begin
               Msg := ConcatMsg(Msg, 'Other Rights');
               Result := false;
            end;
      end { try };
   finally
      DeleteFile(Path + Filename);
   end { try };
end; { CheckRequiredPrivilage }


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TestUserDirRights : boolean;
// Checks User rights in BK5 Exe Directory and displays ErrorMsg if insufficient
var
   ExePath : String;
   S       : String;
   Msg     : String;
begin
   ExePath := AddBackSlashL( JustPathnameL( Application.ExeName) );

// ** Locking is current disabled because we dont want to introduce it into
//    June 01 release.
//
//   Try
//      ObtainLock( ltStartupCheck, 10 );
      Result := CheckRequiredPrivilage( ExePath, Msg );
//   Finally
//      ReleaseLock( ltStartUpCheck );
//   end;

   If not Result then Begin
      S := Format('Unable to run %0:s'#13 + 'Insufficient Rights to %0:s Directory.'#13#13
         + 'Directory Path is : %1:s.'#13 + 'These rights are required : %2:s.'#13#13,
         [SHORTAPPNAME, ExePath, Msg]);
      HelpfulErrorMsg(S, 0);
   end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetupBK5;
// Add Desktop ShortCut;
// Add Registry Key
var
   ShortCutName: string;
   Desc: string;
   ExeName : String;
   ExePath : String;
begin { SetupBK5 }
   ShortCutName := APPTITLE;
   Desc         := 'ShortCut to '+APPTITLE;
   ExeName := JustFileNameL(Application.ExeName);
   ExePath := AddBackSlashL(JustPathnameL(Application.ExeName));
   if CreateDesktopShortCut(ShortCutName, Desc, ExePath + ExeName, ExePath, '') then
      UpdateRegistry(ExePath);
end; { SetupBK5 }


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

