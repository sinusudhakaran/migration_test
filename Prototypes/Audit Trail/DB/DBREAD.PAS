Unit DBRead;

INTERFACE

Procedure GenerateReadFiles( SysName : String );

{  -------------------------------------------------------------------  }
IMPLEMENTATION Uses DBMisc, ReadF;
{  -------------------------------------------------------------------  }

Procedure GenerateReadFiles( SysName : String );

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
   ReadFile    : Text;
   Name        : String[60];
   Prefix      : String[2];
   
   ReadFileName      : String;
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

            ReadFileName      := UpCaseStr( Prefix )+'.R';

            Assign( ReadFile, ReadFileName ); Rewrite( ReadFile );
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );

            If FieldType = 'S' then
            Begin { String Field }
               B1 := GetBField( 4 ); { Length }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
                  WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadStringValue;' );
            end
            else
            If FieldType = 'B' then
            Begin { Byte Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadByteValue;' );
            end
            else
            If FieldType = 'R' then
            Begin { 8 Byte Double Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadDoubleValue;' );
            end
            else
            If FieldType = 'L' then
            Begin { LongInt Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadLongIntValue;' );
            end
            else
            If FieldType = '$' then
            Begin { Money Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadMoneyValue;' );
            end
            else
            If FieldType = 'Y' then
            Begin { Boolean Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadBooleanValue;' );
            end
            else
            If FieldType = 'D' then
            Begin { Date Field }
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName,  
               WS( FieldName), ' : ',Prefix,FieldName,' := F.ReadDateValue;' );
            end
            else
            If FieldType = 'P' then
            Begin { Pointer Field }
               S := MakeName( GetAField( 4 ) );
            end
            else
            If FieldType = 'B$' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   M := F.ReadBMoneyValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := M;' );
               Writeln( ReadFile, Sp12, 'end;' );

            end
            else
            If FieldType = 'B$0' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   M := F.ReadBMoneyValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := M;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BB' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   B := F.ReadBByteValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := B;' );
               Writeln( ReadFile, Sp12, 'end;' );

            end
            else
            If FieldType = 'BB0' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   B := F.ReadBByteValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := B;' );
               Writeln( ReadFile, Sp12, 'end;' );

            end
            else
            If FieldType = 'BC' then
            Begin { Array of Char }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   B := F.ReadBByteValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := Chr( B );' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   Y := F.ReadBBooleanValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := Y;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BBY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   Y := F.ReadBB_BooleanValue( I1, I2 );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I1, 1, ', B1, ', ', Q, FieldName, Q, ' ) and' );
               Writeln( ReadFile, Sp12, '      CheckBounds( I2, 1, ', B2, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I1, I2 ] := True;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BBY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   Y := F.ReadBB_BooleanValue( I1, I2 );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I1, 0, ', B1, ', ', Q, FieldName, Q, ' ) and' );
               Writeln( ReadFile, Sp12, '      CheckBounds( I2, 0, ', B2, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I1, I2 ] := True;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   Y := F.ReadBBooleanValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := Y;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BB$' then
            Begin { 2D Array of Money }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   M := F.ReadBBMoneyValue( I1, I2 );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I1, 1, ', B1, ', ', Q, FieldName, Q, ' ) and' );
               Writeln( ReadFile, Sp12, '      CheckBounds( I2, 1, ', B2, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I1, I2 ] := M;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BS' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );

               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   S := F.ReadBStringValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := S;' );
               Writeln( ReadFile, Sp12, 'end;' );

            end
            else
            If FieldType = 'BS0' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   S := F.ReadBStringValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := S;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BD' then
            Begin { Array of Date }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   D := F.ReadBDateValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := D;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            If FieldType = 'BL' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   L := F.ReadBLongIntValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 1, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := L;' );
               Writeln( ReadFile, Sp12, 'end;' );

            end
            else
            If FieldType = 'BL0' then
            Begin { Zero Based Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( ReadFile, Sp9,  'tk',Prefix,FieldName, ' : ' );
               Writeln( ReadFile, Sp12, 'Begin' );
               Writeln( ReadFile, Sp12, '   L := F.ReadBLongIntValue( I );' );
               Writeln( ReadFile, Sp12, '   If CheckBounds( I, 0, ', B1, ', ', Q, FieldName, Q, ' ) then' );
               Writeln( ReadFile, Sp12, '      ',Prefix,FieldName,' [ I ] := L;' );
               Writeln( ReadFile, Sp12, 'end;' );
            end
            else
            begin
               Writeln( 'Unknown Field Type ', FieldType, ' on line ', LineNumber );
               Halt;
            end;
         end
         else
         If LineType='E' then
            Close( ReadFile );
      end;
   end;
   CloseImportFile;
end;

end.

