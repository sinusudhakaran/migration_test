Unit DBWrite;

INTERFACE

Procedure GenerateWriteFiles( SysName : String );

{  -------------------------------------------------------------------  }
IMPLEMENTATION Uses DBMisc, ReadF;
{  -------------------------------------------------------------------  }

Procedure GenerateWriteFiles( SysName : String );

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
   WriteFile   : Text;
   Name        : String[60];
   Prefix      : String[2];
   
   WriteFileName     : String;
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

            WriteFileName     := UpCaseStr( Prefix )+'.W';
            Assign( WriteFile, WriteFileName ); Rewrite( WriteFile );
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );

            If FieldType = 'S' then
            Begin { String Field }
               B1 := GetBField( 4 ); { Length }
               Writeln( WriteFile, Sp3,  'F.WriteStringValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'B' then
            Begin { Byte Field }
               Writeln( WriteFile, Sp3,  'F.WriteByteValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'R' then
            Begin { 8 Byte Double Field }
               Writeln( WriteFile, Sp3,  'F.WriteDoubleValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'L' then
            Begin { LongInt Field }
               Writeln( WriteFile, Sp3,  'F.WriteLongIntValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = '$' then
            Begin { Money Field }
               Writeln( WriteFile, Sp3,  'F.WriteMoneyValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'Y' then
            Begin { Boolean Field }
               Writeln( WriteFile, Sp3,  'F.WriteBooleanValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'D' then
            Begin { Date Field }
               Writeln( WriteFile, Sp3,  'F.WriteDateValue( tk',Prefix,FieldName, ' , ', Prefix,FieldName, ' );' );
            end
            else
            If FieldType = 'B$' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBMoneyValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'B$0' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 0 to ' ,B1, ' do F.WriteBMoneyValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BB' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBByteValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BB0' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 0 to ' ,B1, ' do F.WriteBByteValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BC' then
            Begin { Array of Char }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBByteValue( tk' ,
                  Prefix,FieldName, ' , i, Ord( ', Prefix,FieldName, '[ i ] ) );' );
            end
            else
            If FieldType = 'BY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBBooleanValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BBY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( WriteFile, Sp3,  'For i1 := 1 to ' ,B1, ' do' );
               Writeln( WriteFile, Sp3,  '   For i2 := 1 to ' ,B2, ' do' );
               Writeln( WriteFile, Sp3,  '      F.WriteBB_BooleanValue( tk' ,
                  Prefix,FieldName, ', i1, i2, ', Prefix,FieldName, '[ i1, i2 ] );' );
            end
            else
            If FieldType = 'BBY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( WriteFile, Sp3,  'For i1 := 0 to ' ,B1, ' do' );
               Writeln( WriteFile, Sp3,  '   For i2 := 0 to ' ,B2, ' do' );
               Writeln( WriteFile, Sp3,  '      F.WriteBB_BooleanValue( tk' ,
                  Prefix,FieldName, ', i1, i2, ', Prefix,FieldName, '[ i1, i2 ] );' );
            end
            else
            If FieldType = 'BY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 0 to ' ,B1, ' do F.WriteBBooleanValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BB$' then
            Begin { 2D Array of Money }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( WriteFile, Sp3,  'For i1 := 1 to ' ,B1, ' do' );
               Writeln( WriteFile, Sp3,  '   For i2 := 1 to ' ,B2, ' do' );
               Writeln( WriteFile, Sp3,  '      F.WriteBBMoneyValue( tk' ,
                  Prefix,FieldName, ', i1, i2, ', Prefix,FieldName, '[ i1, i2 ] );' );
            end
            else
            If FieldType = 'BS' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBStringValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BS0' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( WriteFile, Sp3,  'For i := 0 to ' ,B1, ' do F.WriteBStringValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BD' then
            Begin { Array of Date }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBDateValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BL' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 1 to ' ,B1, ' do F.WriteBLongIntValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            If FieldType = 'BL0' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( WriteFile, Sp3,  'For i := 0 to ' ,B1, ' do F.WriteBLongIntValue( tk' ,
                  Prefix,FieldName, ' , i, ', Prefix,FieldName, '[ i ] );' );
            end
            else
            begin
               Writeln( 'Unknown Field Type ', FieldType, ' on line ', LineNumber );
               Halt;
            end;
         end
         else
         If LineType='E' then
         Begin
            Close( WriteFile );
         end;
      end;
   end;
   CloseImportFile;
end;

end.

