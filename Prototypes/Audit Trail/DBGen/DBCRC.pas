unit DBCRC;

// -----------------------------------------------------------------------------
INTERFACE
// -----------------------------------------------------------------------------

Procedure GenerateCRCFiles( SysName : String );

// -----------------------------------------------------------------------------
IMPLEMENTATION Uses DBMisc, DBObj, ReadF, SysUtils, Classes, StStrS;
// -----------------------------------------------------------------------------

Procedure GenerateCRCFiles( SysName : String );

// -----------------------------------------------------------------------------

Function MakeName ( S : String ): String;
Var O : String; i : Integer;
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
   CRCFile     : Text;
   Name        : String[60];
   Prefix      : String[2];
   CRCFileName : String;
   LineType    : String[10];
   FieldName   : String[60];
   FieldCode   : String[10];
   FieldType   : TFieldType;
   B1, B2      : Integer;
   CRCCode     : TStringList;
   i           : Integer;

   FirstNonSavedField : String[60];

   Procedure WriteLine( AMargin : Integer; ALine : String );
   Const
      CR : String = #$0D;
   Var
      SL : TStringList;
      i  : Integer;
   Begin
      DBObj.ReplaceCodes( ALine, '%NAME%', Prefix + FieldName );
      DBObj.ReplaceCodes( ALine, '%TOKEN%', 'tk' + Prefix + FieldName );
      DBObj.ReplaceCodes( ALine, '%B1%', IntToStr( B1 ) );
      DBObj.ReplaceCodes( ALine, '%B2%', IntToStr( B2 ) );
      SL := TStringList.Create;

      i := Pos( CR, ALine );
      While i > 0 do
      Begin
         SL.Add( Copy( ALine, 1, i-1 ) );
         ALine := Copy( ALine, i+1, Length( ALine ) );
         i := Pos( CR, ALine );
      end;
      SL.Add( ALine );

      For i := 0 to Pred( SL.Count ) do
      Begin
         CRCCode.Add( CharStrS( ' ', AMargin ) + SL[ i ] );
      end;
      FreeAndNil( SL );
   end;
   {  -------------------------------------------------------------------  }

   Function WS( S : String ): String;
   Begin
      WS := '';
      If Length( S )<32 then WS := ConstStr( ' ', 32-Length( S ) );
   end;

   {  -------------------------------------------------------------------  }

   Procedure NS;

   Begin
      Writeln( CRCFile, '// ------------------------------------------------------------------- ' );
   end;

   {  -------------------------------------------------------------------  }

   Procedure LF;

   Begin
      Writeln( CRCFile );
   end;

   {  -------------------------------------------------------------------  }

Begin
   If not OpenImportFile( SysName+'.TXT' ) then Halt( 1 );

   CRCFileName := SysName + 'CRC.PAS';
   Assign( CRCFile, CRCFileName );
   Rewrite( CRCFile );

   Writeln( CRCFile, 'UNIT ',SysName,'CRC;' );
   LF;
   Writeln( CRCFile, '// This code was generated automatically by running DBGen' );
   Writeln( CRCFile, '// Do not change it - any changes you make will disappear' );
   Writeln( CRCFile, '// when DBGen is run again.' );
   LF;
   NS;
   Writeln( CRCFile, 'Interface uses ', SysName, 'Defs, Windows;' );
   NS;
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
            Writeln( CRCFile, 'PROCEDURE Update', 'CRC( CONST Rec : T', Name, '_Rec; VAR CRC : LongWord ); OVERLOAD;' );
         end;
      end;
   end;
   CloseImportFile;

   LF;
   NS;
   Writeln( CRCFile, 'Implementation uses CRC32, MoneyDef;' );
   NS;

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
            Prefix   := GetAField( 3 );
            FirstNonSavedField := '';
            CRCCode  := TStringList.Create;
         end;

         If LineType='F' then
         Begin
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
            If FieldType.fCRCCode<>'' then WriteLine( 6, FieldType.fCRCCode );
         end;
         If LineType='C' then
         Begin { Non-Stored fields }
            FieldName := MakeName( GetAField( 2 ) );
            If FirstNonSavedField = '' then FirstNonSavedField := FieldName;
         end;
         If LineType='E' then
         Begin
            If FirstNonSavedField = '' then FirstNonSavedField := 'EOR';

            LF;
            Writeln( CRCFile, 'PROCEDURE Update', 'CRC( CONST Rec : T', Name, '_Rec; VAR CRC : LongWord ); OVERLOAD;' );
            Writeln( CRCFile, 'Var' );
            Writeln( CRCFile, '   Len    : Integer;' );
            Writeln( CRCFile, '   RS, RE : Pointer;' );
            Writeln( CRCFile, 'Begin' );
            Writeln( CRCFile, '   With Rec do begin' );
            Writeln( CRCFile, '      RS    := @', Prefix, 'Record_Type;' );
            Writeln( CRCFile, '      RE    := @', Prefix, FirstNonSavedField, ';' );
            Writeln( CRCFile, '      Len   := Integer( RE ) - Integer( RS );' );
            Writeln( CRCFile, '      CRC32.UpdateCRC( CRC , RS^, Len );' );

            If CRCCode.Count > 0 then
               For i := 0 to Pred( CRCCode.Count ) do
                  Writeln( CRCFile, CRCCode[i] );

            FreeAndNil( CRCCode );
            
            Writeln( CRCFile, '   end;' );
            Writeln( CRCFile, 'end;' );
            LF;
            NS;
         end;
      end;
   end;
   CloseImportFile;

   LF;
   Writeln( CRCFile, 'end.' );
   Close( CRCFile );
end;

// -----------------------------------------------------------------------------

end.
