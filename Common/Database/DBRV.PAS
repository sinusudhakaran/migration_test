Unit DBRV;

INTERFACE

Procedure GenerateRVFiles( SysName : String );

{  -------------------------------------------------------------------  }
IMPLEMENTATION Uses DBMisc, ReadF;
{  -------------------------------------------------------------------  }

Procedure GenerateRVFiles( SysName : String );

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
   RVFile    : Text;
   Name        : String[60];
   Prefix      : String[2];
   
   RVFileName      : String;
   TokenNo           : Integer;

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
   Needs_L  : Boolean;  
   Needs_M  : Boolean;
   Needs_B  : Boolean;
   Needs_D  : Boolean;
   Needs_Y  : Boolean;  
   Needs_S  : Boolean;
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

            RVFileName      := UpCaseStr( Prefix )+'.RV';

            Assign( RVFile, RVFileName ); Rewrite( RVFile );

            Needs_I  := False;
            Needs_I1 := False;
            Needs_I2 := False;
            Needs_L  := False; 
            Needs_M  := False;
            Needs_B  := False;
            Needs_D  := False;
            Needs_Y  := False; 
            Needs_S  := False;
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );

            If FieldType = 'BL' then
            Begin { Array of LongInt }
               Needs_L := True;
               Needs_I := True;
            end
            else
            If FieldType = 'BL0' then
            Begin { Array of LongInt }
               Needs_L := True;
               Needs_I := True;
            end
            else
            If FieldType = 'B$' then
            Begin { Array of Money }
               Needs_M := True;
               Needs_I := True;
            end
            else
            If FieldType = 'B$0' then
            Begin { Array of Money }
               Needs_M := True;
               Needs_I := True;
            end
            else
            If ( FieldType = 'BB' ) or ( FieldType = 'BB0' ) then
            Begin { Array of Byte }
               Needs_B := True;
               Needs_I := True;
            end
            else
            If FieldType = 'BC' then
            Begin { Array of Char }
               Needs_B := True;
               Needs_I := True;
            end
            else
            If ( FieldType = 'BY' ) or ( FieldType = 'BY0' ) then
            Begin { Array of Boolean }
               Needs_Y := True;
               Needs_I := True;
            end
            else
            If ( FieldType = 'BBY' ) or ( FieldType = 'BBY0' ) then
            Begin { Array of Boolean }
               Needs_Y := True;
               Needs_I1 := True;
               Needs_I2 := True;
            end
            else
            If FieldType = 'BB$' then
            Begin { 2D Array of Money }
               Needs_M  := True;
               Needs_I1 := True;
               Needs_I2 := True;
            end
            else
            If FieldType = 'BS' then
            Begin { Array of String }
               Needs_S := True;
               Needs_I := True;
            end
            else
            If FieldType = 'BS0' then
            Begin { Array of String }
               Needs_S := True;
               Needs_I := True;
            end
            else
            If FieldType = 'BD' then
            Begin { Array of Date }
               Needs_D := True;
               Needs_I := True;
            end;
         end
         else
         If LineType='E' then
         Begin
            Writeln( RVFile );
            Writeln( RVFile, 'Var' );
            Writeln( RVFile, '   Token : Byte;' );
            If Needs_I  then Writeln( RVFile, '   I     : Byte;' );
            If Needs_I1 then Writeln( RVFile, '   I1    : Byte;' );
            If Needs_I2 then Writeln( RVFile, '   I2    : Byte;' );
            If Needs_L  then Writeln( RVFile, '   L     : LongInt;' );
            If Needs_M  then Writeln( RVFile, '   M     : Money;' );
            If Needs_B  then Writeln( RVFile, '   B     : Byte;   ' );
            If Needs_D  then Writeln( RVFile, '   D     : LongInt;' );
            If Needs_Y  then Writeln( RVFile, '   Y     : Boolean;' );
            If Needs_S  then Writeln( RVFile, '   S     : String[255];' );
            Close( RVFile );
         end;
      end;
   end;
   CloseImportFile;
end;

end.

