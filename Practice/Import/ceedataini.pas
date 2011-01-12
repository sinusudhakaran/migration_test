unit ceedataini;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  function cdActiveOnly   : Boolean;
  function cdGroupID      : string;
  function cdHomeDir      : string;
  function cdPrototypeDir : string;
  function cdExeName      : string;

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

   fcdActiveOnly   : Boolean;
   fcdGroupID      : string;
   fcdHomeDir      : string;
   fcdPrototypeDir : string;
   fcdExeName      : string;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure SetDefaults;
Begin
   fcdExeName      := 'ACTCHART.EXE';
   fcdActiveOnly   := False;
   fcdGroupID      := '0';
   fcdHomeDir      := '';
   fcdPrototypeDir := '';
end;   
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure ReadSettings;
Var
   I   : TMemIniFile;
Begin
   if not BKFileExists( IniFileName ) then Exit;
   I := TMemIniFile.Create( IniFileName );
   Try
      fcdExeName      := I.ReadString(  SubKey, cdExeNameKey,      cdExeName       );
      fcdActiveOnly   := StrToBool(I.ReadString( SubKey, cdActiveOnlyKey,   'FALSE'));
      fcdGroupID      := I.ReadString(  SubKey, cdGroupIDKey,      cdGroupID       );
      fcdHomeDir      := I.ReadString(  SubKey, cdHomeDirKey,      cdHomeDir       );
      fcdPrototypeDir := I.ReadString(  SubKey, cdPrototypeDirKey, cdPrototypeDir  );
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
      I.WriteString( SubKey, cdExeNameKey,  fcdExeName      );
      I.WriteBool( SubKey, cdActiveOnlyKey, fcdActiveOnly   );
      I.WriteString( SubKey, cdGroupIDKey, fcdGroupID      );
      I.WriteString( SubKey, cdHomeDirKey, fcdHomeDir      );
      I.WriteString( SubKey, cdPrototypeDirKey, fcdPrototypeDir );
   finally
      I.UpdateFile;
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure Doinit;
begin
   if iniFileName > '' then
      Exit; // Been here before..

   iniFileName := ExtractFilePath( Application.ExeName ) + '\ACTCHART.INI';

   ReadSettings;
   if not BKFileExists( IniFileName ) then begin
      SaveSettings;
   end;
end;

function cdActiveOnly : Boolean;
begin
   Doinit;
   Result := fcdActiveOnly
end;

function cdGroupID : string;
begin
   Doinit;
   Result := fcdGroupID
end;

function cdHomeDir : string;
begin
   Doinit;
   Result := fcdHomeDir;
end;

function cdPrototypeDir : string;
begin
   Doinit;
   Result := fcdPrototypeDir
end;

function cdExeName : string;
begin
   Doinit;
   Result := fcdExeName
end;

initialization
   iniFileName := '';
   SetDefaults;
end.

