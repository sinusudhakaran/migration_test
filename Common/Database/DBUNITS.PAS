Unit DBUnits;

INTERFACE

Procedure GenerateUnitFiles( SysName : String );

{  -------------------------------------------------------------------  }
IMPLEMENTATION Uses DBMisc, ReadF, OPDATE, xxDATES;
{  -------------------------------------------------------------------  }

Procedure GenerateUnitFiles( SysName : String );

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
   UnitFile    : Text;

   VersionFile       : Text;  
   VersionFileName   : String;

   Name        : String[60];
   Prefix      : String[2];
   
   UnitFileName      : String;
   TokenNo           : Integer;

   LineType    : String[10];
   FieldType   : String[10];
   FieldName   : String[60];
   B1,B2,i     : Byte;
   Version     : LongInt;
      
   S : String;

   {  -------------------------------------------------------------------  }

   Function WS( S : String ): String;
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
   If FileExist( VersionFileName ) then
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

   NS;
   LF;
   Writeln( UnitFile, 'UNIT ',SysName,'DEFS;' );
   LF;
   NS;
   Writeln( UnitFile, 'INTERFACE USES MONEYDEF, DATEDEF;' );
   NS;
   LF;
   Writeln( UnitFile, 'CONST' );
   Writeln( UnitFile, '   ', SysName, '_IOLIB_Version : LongInt = ', Version, ';' );
   Writeln( UnitFile, '   ', SysName, '_IOLIB_Date    = ', Q, Date2Str( Today ), Q, ';' );
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );
   While not EndOfImportFile do
   Begin
      ReadLine;
      If NoOfFields > 0 then
      Begin
         LineType := GetAField( 1 );
         If LineType='$' then Writeln( UnitFile, '   ', GetAField( 2 ) );
      end;
   end;
   CloseImportFile;
   LF;
   NS;
   LF;

   Writeln( UnitFile, 'TYPE' );

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
            TokenNo  := GetLField( 4 );

            NS;
            LF;

            If Prefix = 'mx' then
               Writeln( UnitFile, '   t',Name,'_Rec = {$IFDEF WIN32} Packed {$ENDIF} Record' )
            else
               Writeln( UnitFile, '   t',Name,'_Rec = Record' );
            Writeln( UnitFile, '      ',Prefix, 'Record_Type', WS('Record_Type'),' : Byte;' );
         end
         else
         If LineType='C' then
         Begin { Calculated Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );

            If FieldType = 'S' then
            Begin { String Field }
               B1 := GetBField( 4 ); { Length }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : String[ ',B1,' ];' );
            end
            else
            If FieldType = 'B' then
            Begin { Byte Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Byte;' );
            end
            else
            If FieldType = 'L' then
            Begin { LongInt Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : LongInt;' );
            end
            else
            If FieldType = '$' then
            Begin { Money Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Money;' );
            end
            else
            If FieldType = 'Y' then
            Begin { Boolean Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Boolean;' );
            end
            else
            If FieldType = 'D' then
            Begin { Date Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : LongInt;' );
            end
            else
            If FieldType = 'P' then
            Begin { Pointer Field }
               S := MakeName( GetAField( 4 ) );
               Writeln( UnitFile, Sp6,  Prefix,FieldName, WS( FieldName),  ' : p',S,';' );
            end
            else
            If FieldType = 'Pt' then
            Begin { Pointer Field }
               S := MakeName( GetAField( 4 ) );
               Writeln( UnitFile, Sp6,  Prefix,FieldName, WS( FieldName),  ' : Pointer;' );
            end
            else
            If FieldType = 'TLB' then
            Begin { Budget, ThisYear, LastYear Field }
               S := MakeName( GetAField( 4 ) );
               Writeln( UnitFile, Sp6,  Prefix,FieldName, WS( FieldName),  ' : TLBRec;' );
            end
            else
            If FieldType = 'B$' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Money;' );
            end
            else
            If FieldType = 'B$0' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of Money;' );
            end
            else
            If FieldType = 'BL' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of LongInt;' );
            end
            else
            If FieldType = 'BL0' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of LongInt;' );
            end
            else
            If FieldType = 'BB' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Byte;' );
            end
            else
            If FieldType = 'BB0' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of Byte;' );
            end
            else
            If FieldType = 'BC' then
            Begin { Array of Char }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Char;' );
            end
            else
            If FieldType = 'BY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Boolean;' );
            end
            else
            If FieldType = 'BBY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,', 1..',B2,' ] of Boolean;' );
            end
            else
            If FieldType = 'BBY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,', 0..',B2,' ] of Boolean;' );
            end
            else
            If FieldType = 'BY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of Boolean;' );
            end
            else
            If FieldType = 'BB$' then
            Begin { 2D Array of Money }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,', 1..', B2,' ] of Money;' );
            end
            else
            If FieldType = 'BB$0' then
            Begin { 2D Array of Money }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 0..',B1,', 0..', B2,' ] of Money;' );
            end
            else
            If FieldType = 'BS' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of String[ ',B2,' ];' );
            end
            else
            If FieldType = 'BS0' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of String[ ',B2,' ];' );
            end
            else
            If FieldType = 'BD' then
            Begin { Array of Date }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of LongInt;' );
            end
            else
            If FieldType = 'PED' then
            Begin { tPeriod_End_Dates of Date }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : tPeriod_End_Dates;' );
            end
            else
            If FieldType = 'TO' then
            Begin { tPeriod_End_Dates of Date }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : TObject;' );
            end
            else
            begin
               Writeln( 'Unknown Field Type ', FieldType, ' on line ', LineNumber );
               Halt;
            end;
         end
         else
         If LineType='F' then
         Begin { Real Fields }
            FieldName := MakeName( GetAField( 2 ) );
            FieldType := GetAField( 3 );

            If FieldType = 'S' then
            Begin { String Field }
               B1 := GetBField( 4 ); { Length }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : String[ ',B1,' ];       { Stored } ' );
            end
            else
            If FieldType = 'B' then
            Begin { Byte Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Byte;       { Stored } ' );
            end
            else
            If FieldType = 'R' then
            Begin { 8 Byte Double Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Double;       { Stored } ' );
            end
            else
            If FieldType = 'L' then
            Begin { LongInt Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : LongInt;       { Stored } ' );
            end
            else
            If FieldType = '$' then
            Begin { Money Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Money;       { Stored } ' );
            end
            else
            If FieldType = 'Y' then
            Begin { Boolean Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Boolean;       { Stored } ' );
            end
            else
            If FieldType = 'D' then
            Begin { Date Field }
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : LongInt;       { Stored } ' );
            end
            else
            If FieldType = 'P' then
            Begin { Pointer Field }
               S := MakeName( GetAField( 4 ) );
               Writeln( UnitFile, Sp6,  Prefix,FieldName, WS( FieldName),  ' : p', S, ';' );
            end
            else
            If FieldType = 'B$' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,' ] of Money;       { Stored } ' );
            end
            else
            If FieldType = 'B$0' then
            Begin { Array of Money }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 0..',B1,' ] of Money;       { Stored } ' );
            end
            else
            If FieldType = 'BL' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,' ] of LongInt;     { Stored } ' );
            end
            else
            If FieldType = 'BL0' then
            Begin { Array of LongInt }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName),
                  ' : Array[ 0..',B1,' ] of LongInt;     { Stored }' );
            end
            else
            If FieldType = 'BB' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Byte;       { Stored } ' );
            end
            else
            If FieldType = 'BB0' then
            Begin { Array of Byte }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 0..',B1,' ] of Byte;       { Stored } ' );
            end
            else
            If FieldType = 'BC' then
            Begin { Array of Char }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), ' : Array[ 1..',B1,' ] of Char;       { Stored } ' );
            end
            else
            If FieldType = 'BY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,' ] of Boolean;       { Stored } ' );
            end
            else
            If FieldType = 'BBY' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  
                  WS( FieldName), ' : Array[ 1..',B1,', 1..',B2,' ] of Boolean; { Stored }' );
            end
            else
            If FieldType = 'BBY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  
                  WS( FieldName), ' : Array[ 0..',B1,', 0..',B2,' ] of Boolean; { Stored }' );
            end
            else
            If FieldType = 'BY0' then
            Begin { Array of Boolean }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 0..',B1,' ] of Boolean;       { Stored } ' );
            end
            else
            If FieldType = 'BB$' then
            Begin { 2D Array of Money }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,', 1..', B2,' ] of Money;       { Stored } ' );
            end
            else
            If FieldType = 'BS' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );

               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,' ] of String[ ',B2,' ];       { Stored } ' );
            end
            else
            If FieldType = 'BS0' then
            Begin { Array of String }
               B1 := GetLField( 4 );
               B2 := GetLField( 5 );

               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 0..',B1,' ] of String[ ',B2,' ];       { Stored } ' );
            end
            else
            If FieldType = 'BD' then
            Begin { Array of Date }
               B1 := GetLField( 4 );
               Writeln( UnitFile, Sp6, Prefix,FieldName,  WS( FieldName), 
                  ' : Array[ 1..',B1,' ] of LongInt;       { Stored } ' );
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
            Writeln( UnitFile, '      ',Prefix, 'EOR', WS('EOR'),' : Byte;' );
            Writeln( UnitFile, '   end;' );
            LF;
         end;
      end;
   end;
   CloseImportFile;

   Writeln( UnitFile, 'CONST' );

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
   Writeln( UnitFile, 'IMPLEMENTATION' );
   NS;
   LF;
   Writeln( UnitFile, 'END.' );
   Close( UnitFile );
end;

end.

