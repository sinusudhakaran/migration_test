Unit DBUnits;

// -----------------------------------------------------------------------------
INTERFACE
// -----------------------------------------------------------------------------

Procedure GenerateUnitFiles( SysName : String );

// -----------------------------------------------------------------------------
IMPLEMENTATION Uses DBMisc, ReadF, StDate, StDateSt, SysUtils, Classes, DBObj;
// -----------------------------------------------------------------------------

Procedure GenerateUnitFiles( SysName : String );

// -----------------------------------------------------------------------------

Function MakeName ( S : ShortString ): ShortString;
Var O : ShortString; i : Integer;
Begin
   O:=S;
   For i:=1 to Length( O ) do if not ( O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then O[i]:='_';
   MakeName := O;
end;

// -----------------------------------------------------------------------------

Function TodayStr : String;
Begin
   Result := StDateSt.StDateToDateString( 'dd/mm/yy', CurrentDate, False );
end;

// -----------------------------------------------------------------------------

CONST
   Q = '''';
   Sp3  = '   ';
   Sp6  = '      ';
   NS6  = '{NS}  ';
   Sp9  = '         ';
   sp12 = '            ';

Var
   UnitFile    : Text;

   VersionFile       : Text;
   VersionFileName   : String;

   Name        : String[60];
   Prefix      : String[2];

   UnitFileName      : String;
   LineType    : String[10];
   FieldCode   : String[10];
   FieldType   : TFieldType;
   FieldName   : String[60];
   B1,B2,B3    : Byte;
   A4          : String;
   Version     : LongInt;
   Definition  : String;

   {  -------------------------------------------------------------------  }

   Function WS( S : ShortString ): ShortString;
   Begin
      WS := '';
      If Length( S )<32 then WS := ConstStr( ' ', 32-Length( S ) );
   end;

   {  -------------------------------------------------------------------  }

   Procedure NS;

   Begin
      Writeln( UnitFile, '{  -------------------------------------------------------------------  }' );
   end;

   {  -------------------------------------------------------------------  }

   Procedure LF;

   Begin
      Writeln( UnitFile );
   end;

   {  -------------------------------------------------------------------  }
   
Begin
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );

   Version := 099;

   VersionFileName := SysName+'.NO';
   If FileExists( VersionFileName ) then
   Begin
      Assign( VersionFile, VersionFileName );
      Reset( VersionFile );
      Readln( VersionFile, Version );
      Close( VersionFile );
   end;

   Inc( Version );

   Assign( VersionFile, VersionFileName );
   Rewrite( VersionFile );
   Writeln( VersionFile, Version );
   Close( VersionFile );

   UnitFileName := SysName+'DEFS.PAS';
   Assign( UnitFile, UnitFileName );
   Rewrite( UnitFile );

   Writeln( UnitFile, 'Unit ',SysName,'DEFS;' );
   LF;
   Writeln( UnitFile, '// This code was generated automatically by running DBGen' );
   Writeln( UnitFile, '// Do not change it - any changes you make will disappear' );
   Writeln( UnitFile, '// when DBGen is run again.' );
   LF;
   NS;
   Writeln( UnitFile, 'Interface uses MONEYDEF, DATEDEF;' );
   NS;
   LF;
   Writeln( UnitFile, 'Const' );
   Writeln( UnitFile, '   ', SysName, '_IOLIB_Version : Integer = ', Version, ';' );
   Writeln( UnitFile, '   ', SysName, '_IOLIB_Date    = ', Q, TodayStr, Q, ';' );
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );
         If LineType='$' then
           Writeln( UnitFile, '   ', GetAField( 2 ) );
      end;
   end;
   CloseImportFile;
   LF;
   NS;
   LF;

   Writeln( UnitFile, 'Type' );

   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );
         If LineType='N' then
         Begin
            If NoOfFields<4 then
            Begin
               Writeln( 'Error: Too Few Fields on line ', LineNumber );
               Halt;
            end;
            Name     := MakeName( GetAField( 2 ) );
            Writeln( UnitFile, '   p', Name, '_Rec', WS(Name), ' = ^t',Name,'_Rec ;' );
         end;
      end;
   end;
   CloseImportFile;

   LF;

   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );
         If LineType='N' then
         Begin
            If NoOfFields<4 then
            Begin
               Writeln( 'Error: Too Few Fields on line ', LineNumber );
               Halt;
            end;
            Name     := MakeName( GetAField( 2 ) );
            Prefix   := GetAField( 3 );

            NS;
            LF;

            Writeln( UnitFile, '   t',Name,'_Rec = Packed Record' );
            Writeln( UnitFile, Sp6, Prefix, 'Record_Type', WS('Record_Type'),' : Byte;' );
         end
         else
         If ( LineType='C' ) or ( LineType='F' ) then
         Begin { 'C'=Calculated Fields, 'F'=Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldCode := GetAField( 3 );
            FieldType := DBObj.FindFieldType( FieldCode );
            If FieldType = NIL then
            Begin
               Writeln( 'Unknown Field Type ', FieldCode, ' on line ', LineNumber );
               Halt;
            end;

            B1 := GetBField( 4 );
            B2 := GetBField( 5 );
            B3 := GetBField( 6 );
            A4 := MakeName( GetAField( 4 ) );

            Definition := FieldType.fDefn;
            DBObj.ReplaceCodes( Definition, '%NAME%', Prefix + FieldName );
            DBObj.ReplaceCodes( Definition, '%TOKEN%', 'tk' + Prefix + FieldName );
            DBObj.ReplaceCodes( Definition, '%B1%', IntToStr( B1 ) );
            DBObj.ReplaceCodes( Definition, '%B2%', IntToStr( B2 ) );
            DBObj.ReplaceCodes( Definition, '%B3%', IntToStr( B3 ) );
            DBObj.ReplaceCodes( Definition, '%A4%', A4 );

            If LineType = 'F' then { Stored Fields }
               Writeln( UnitFile, Sp6, Prefix, FieldName, WS( FieldName ), ' : ', Definition, '       { Stored }' )
            else { non-stored fields }
               Writeln( UnitFile, Sp6, Prefix, FieldName, WS( FieldName ), ' : ', Definition )
         end
         else
         If LineType='E' then
         Begin
            Writeln( UnitFile, Sp6, Prefix, 'EOR', WS('EOR'),' : Byte;' );
            Writeln( UnitFile, '   end;' );
            LF;
         end;
      end;
   end;
   CloseImportFile;

   Writeln( UnitFile, 'Const' );

   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );
         If LineType='N' then
         Begin
            Name     := MakeName( GetAField( 2 ) );
            Writeln( UnitFile, '   ',Name,'_Rec_Size', WS( Name ),' = Sizeof( T',Name,'_Rec ); ' );
         end;
      end;
   end;
   CloseImportFile;

   LF;
   NS;
   Writeln( UnitFile, 'Implementation' );
   NS;
   LF;
   Writeln( UnitFile, 'end.' );
   Close( UnitFile );
end;

// -----------------------------------------------------------------------------

end.

