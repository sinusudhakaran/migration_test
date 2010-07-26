Unit DBWV;

// -----------------------------------------------------------------------------
INTERFACE
// -----------------------------------------------------------------------------

Procedure GenerateWVFiles( SysName : ShortString );

// -----------------------------------------------------------------------------
IMPLEMENTATION Uses DBMisc, ReadF, SysUtils, Classes, DBObj;
// -----------------------------------------------------------------------------

Procedure GenerateWVFiles( SysName : ShortString );

// -----------------------------------------------------------------------------

Function MakeName ( S : ShortString ): ShortString;
Var O : ShortString; i : Integer;
Begin
   O:=S;
   For i:=1 to Length( O ) do if not ( O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then O[i]:='_';
   MakeName:=O;
end;

// -----------------------------------------------------------------------------

CONST
   Q = '''';
   Sp3  = '   ';
   Sp6  = '      ';
   Sp9  = '         ';
   sp12 = '            ';

Var
   WVFile      : Text;
   Name        : String[60];
   Prefix      : String[2];

   WVFileName  : ShortString;
   LineType    : String[10];
   FieldCode   : String[10];
   FieldType   : TFieldType;
   FieldName   : String[60];

   Function WS( S : ShortString ): ShortString;
   Begin
      WS := '';
      If Length( S )<32 then WS := ConstStr( ' ', 32-Length( S ) );
   end;

Var
   Needs_I  : Boolean;
   Needs_I1 : Boolean;
   Needs_I2 : Boolean;
   SL       : TStringList;
   i        : Integer;

Begin
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );

   Needs_I  := False;
   Needs_I1 := False;
   Needs_I2 := False;

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

            WVFileName     := UpperCase( Prefix )+'.WV';
            Assign( WVFile, WVFileName ); Rewrite( WVFile );
            Needs_I  := False;
            Needs_I1 := False;
            Needs_I2 := False;
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldCode := GetAField( 3 );
            FieldType := FindFieldType( FieldCode );
            If FieldType = NIL then
            Begin
               Writeln( 'Unknown Field Type ', FieldCode, ' on line ', LineNumber );
               Halt;
            end;
            SL := TStringList.Create;
            SL.CommaText := FieldType.fReadVars;
            For i := 0 to Pred( SL.Count ) do
            Begin
               If SL[i] = 'I'  then Needs_I  := True;
               If SL[i] = 'I1' then Needs_I1 := True;
               If SL[i] = 'I2' then Needs_I2 := True;
            end;
            FreeAndNil( SL );
         end
         else
         If LineType='E' then
         Begin
            If ( Needs_I or Needs_I1 or Needs_I2 ) then
            Begin
               Writeln( WVFile );
               Writeln( WVFile, 'Var' );
            end;
            If Needs_I  then Writeln( WVFile, '   I     : Byte;' );
            If Needs_I1 then Writeln( WVFile, '   I1    : Byte;' );
            If Needs_I2 then Writeln( WVFile, '   I2    : Byte;' );
            Close( WVFile );
         end;
      end;
   end;
   CloseImportFile;
end;

// -----------------------------------------------------------------------------

end.

