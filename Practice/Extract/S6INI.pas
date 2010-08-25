unit S6INI;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   s6UseMAS50Import  : Boolean;
//   s6UseASCIIImport  : Boolean;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses SysUtils, Forms, WinUtils, IniFiles;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   SubKey                = 'Settings';
   s6UseMAS50ImportKey   = 'MAS5 Import';
//   s6UseAsciiImportKey   = 'ASCII Import';
   
VAR
   iniFileName : String;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure SetDefaults;
Begin
   s6UseMAS50Import := False;
//   s6UseAsciiImport := False;
end;   
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure ReadSettings;
Var
   I   : TMemIniFile;
Begin
   if not BKFileExists( IniFileName ) then Exit;
   I := TMemIniFile.Create( IniFileName );
   Try
      s6UseMAS50Import := StrToBool(I.ReadString( SubKey, s6UseMAS50ImportKey, 'FALSE' ));
//      s6UseAsciiImport := I.ReadBoolean( s6UseAsciiImportKey, s6UseAsciiImport );
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
      I.WriteBool( SubKey, s6UseMAS50ImportKey, s6UseMAS50Import );
//      I.WriteBoolean( s6UseAsciiImportKey, s6UseAsciiImport );
   finally
      I.UpdateFile;
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   iniFileName := ExtractFilePath( Application.ExeName ) + '\MAS.INI';
   SetDefaults;
   ReadSettings;
   if not BKFileExists( IniFileName ) then begin
      SaveSettings;
   end;
end.

