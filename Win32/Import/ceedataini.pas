unit ceedataini;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   cdActiveOnly   : Boolean;
   cdGroupID      : string;
   cdHomeDir      : string;
   cdPrototypeDir : string;
   cdExeName      : string;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses SysUtils, Forms, WinUtils, IniFiles;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   SubKey             = 'Settings';
   cdExeNameKey       = 'Program Name';
   cdActiveOnlyKey    = 'Active Only';  
   cdGroupIDKey       = 'Group';
   cdHomeDirKey       = 'Home Directory';
   cdPrototypeDirKey  = 'Prototype Directory';

VAR   
   iniFileName        : String;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure SetDefaults;
Begin
   cdExeName      := 'ACTCHART.EXE';
   cdActiveOnly   := False;
   cdGroupID      := '0';
   cdHomeDir      := '';
   cdPrototypeDir := '';
end;   
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure ReadSettings;
Var
   I   : TMemIniFile;
Begin
   if not BKFileExists( IniFileName ) then Exit;
   I := TMemIniFile.Create( IniFileName );
   Try
      cdExeName      := I.ReadString(  SubKey, cdExeNameKey,      cdExeName       );
      cdActiveOnly   := StrToBool(I.ReadString( SubKey, cdActiveOnlyKey,   'FALSE'));
      cdGroupID      := I.ReadString(  SubKey, cdGroupIDKey,      cdGroupID       );
      cdHomeDir      := I.ReadString(  SubKey, cdHomeDirKey,      cdHomeDir       );
      cdPrototypeDir := I.ReadString(  SubKey, cdPrototypeDirKey, cdPrototypeDir  );
   Finally
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SaveSettings;
Var
   I   : TMemIniFile;
Begin
   I := TMemIniFile.Create( IniFileName );
   try
      I.WriteString(  SubKey, cdExeNameKey,      cdExeName      );
      I.WriteBool( SubKey, cdActiveOnlyKey,   cdActiveOnly   );
      I.WriteString(  SubKey, cdGroupIDKey,      cdGroupID      );
      I.WriteString(  SubKey, cdHomeDirKey,      cdHomeDir      );
      I.WriteString(  SubKey, cdPrototypeDirKey, cdPrototypeDir );
   finally
      I.UpdateFile;
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   iniFileName := ExtractFilePath( Application.ExeName ) + '\ACTCHART.INI';
   SetDefaults;
   ReadSettings;
   if not BKFileExists( IniFileName ) then begin
      SaveSettings;
   end;
end.

