unit S6INI;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  function s6UseMAS50Import  : Boolean;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses SysUtils, Forms, WinUtils, IniFiles;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   SubKey                = 'Settings';
   s6UseMAS50ImportKey   = 'MAS5 Import';

   
VAR
   iniFileName : String;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
function ReadSettings: boolean;
Var
   I   : TMemIniFile;
Begin
   Result := False;
   if not BKFileExists( IniFileName ) then
      Exit;
   I := TMemIniFile.Create( IniFileName );
   Try
      Result := StrToBool(I.ReadString( SubKey, s6UseMAS50ImportKey, 'FALSE' ));
//      s6UseAsciiImport := I.ReadBoolean( s6UseAsciiImportKey, s6UseAsciiImport );
   Finally
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SaveSettings(Value: Boolean);
Var
   I   : TMemIniFile;
Begin
   I := TMemIniFile.Create( IniFileName );
   try
      I.WriteBool( SubKey, s6UseMAS50ImportKey, Value );
//      I.WriteBoolean( s6UseAsciiImportKey, s6UseAsciiImport );
   finally
      I.UpdateFile;
      I.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function s6UseMAS50Import  : Boolean;
begin
   iniFileName := ExtractFilePath( Application.ExeName ) + '\MAS.INI';
   Result := ReadSettings;
   if not BKFileExists( IniFileName ) then begin
      SaveSettings(Result);
   end;
end;

end.

