Unit DBWV;

INTERFACE

Procedure GenerateWVFiles( SysName : String );

{  -------------------------------------------------------------------  }
IMPLEMENTATION Uses DBMisc, ReadF;
{  -------------------------------------------------------------------  }

Procedure GenerateWVFiles( SysName : String );

{  -------------------------------------------------------------------  }

Function MakeName ( S : String ): String;
Var O : String; i : Integer;
Begin
   O:=S;
   For i:=1 to Length( O ) do if not ( O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then O[i]:='_';         
   MakeName:=O;
end;

{  -------------------------------------------------------------------  }

CONST
   Q = '''';
   Sp3  = '   ';
   Sp6  = '      ';
   Sp9  = '         ';
   sp12 = '            ';

Var
   InFile      : Text;
   WVFile      : Text;
   Name        : String[60];
   Prefix      : String[2];
   
   WVFileName  : String;
   TokenNo     : Integer;

   LineType    : String[10];
   FieldType   : String[10];
   FieldName   : String[60];
   B1,B2,i     : Byte;
      
   S : String;

   Function WS( S : String ): String;
   Begin
      WS := '';
      If Length( S )<32 then WS := ConstStr( ' ', 32-Length( S ) );
   end;

Var
   Needs_I  : Boolean;
   Needs_I1 : Boolean;
   Needs_I2 : Boolean;

Begin
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
            TokenNo  := GetLField( 4 );

            WVFileName     := UpCaseStr( Prefix )+'.WV';
            Assign( WVFile, WVFileName ); Rewrite( WVFile );
            Needs_I  := False;
            Needs_I1 := False;
            Needs_I2 := False;
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );
            If FieldType = 'B$' then Needs_I := True;
            If FieldType = 'B$0' then Needs_I := True;
            If FieldType = 'BB' then Needs_I := True;
            If FieldType = 'BC' then Needs_I := True;
            If FieldType = 'BY' then Needs_I := True;
            If FieldType = 'BBY' then 
            Begin
               Needs_I1 := True;
               Needs_I2 := True;
            end;

            If FieldType = 'BBY0' then 
            Begin
               Needs_I1 := True;
               Needs_I2 := True;
            end;

            If ( FieldType = 'BL' ) or ( FieldType = 'BL0' ) then Needs_I := True;
            If FieldType = 'BB$' then
            Begin 
               Needs_I1 := True;
               Needs_I2 := True;
            end;
            If FieldType = 'BS' then Needs_I := True;
            If FieldType = 'BS0' then Needs_I := True;
            If FieldType = 'BD' then Needs_I := True;
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

end.

