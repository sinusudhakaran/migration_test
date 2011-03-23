Unit DBIO;

// -----------------------------------------------------------------------------
INTERFACE
// -----------------------------------------------------------------------------

Procedure GenerateIOFiles( SysName : ShortString );

// -----------------------------------------------------------------------------
IMPLEMENTATION Uses DBMisc, ReadF, SysUtils;
// -----------------------------------------------------------------------------

Procedure GenerateIOFiles( SysName : ShortString );

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
   ReadFile    : Text;
   RVFile      : Text;
   WriteFile   : Text;
   WVFile      : Text;
   FreeFile    : Text;
   IntTokenFile: Text;
   ImpTokenFile: Text;
   IOFile      : Text;
   ACFile      : Text;
   Name        : String[60];
   Prefix      : String[2];
   UPrefix     : String[2];

   IOFileName        : ShortString;
   ReadFileName      : ShortString;
   WriteFileName     : ShortString;
   FreeFileName      : ShortString;
   RVFileName        : ShortString;
   WVFileName        : ShortString;
   ACFileName        : ShortString;
   IntTokenFileName  : ShortString;
   ImpTokenFileName  : ShortString;
   UnitFileName      : ShortString;
   LineType          : String[10];

   S : ShortString;
   FirstToken, LastToken: string;

   // --------------------------------------------------------------------------

   Function WS( S : ShortString ): ShortString;
   Begin
      WS := '';
      If Length( S )<32 then WS := ConstStr( ' ', 32-Length( S ) );
   end;

   // --------------------------------------------------------------------------

   Procedure NS;

   Begin
      Writeln( IOFile, '{  -------------------------------------------------------------------  }' );
   end;

   // --------------------------------------------------------------------------

   Procedure LF;

   Begin
      Writeln( IOFile );
   end;

   // --------------------------------------------------------------------------

Begin
   UnitFileName := SysName+'DEFS.PAS';

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
            UPrefix  := UpperCase( Prefix );

            ReadFileName      := UpperCase( Prefix )+'.R';
            WriteFileName     := UpperCase( Prefix )+'.W';
            FreeFileName      := UpperCase( Prefix )+'.F';
            IntTokenFileName  := UpperCase( Prefix )+'.TIN';
            ImpTokenFileName  := UpperCase( Prefix )+'.TIM';

            RVFileName        := UpperCase( Prefix )+'.RV';

            WVFileName        := UpperCase( Prefix )+'.WV';

            ACFileName        := UpperCase( Prefix )+'.AC';
            Assign( ReadFile, ReadFileName ); Reset( ReadFile );
            Assign( WriteFile, WriteFileName ); Reset( WriteFile );
            Assign( FreeFile, FreeFileName ); Reset( FreeFile );
            Assign( IntTokenFile, IntTokenFileName ); Reset( IntTokenFile );
            Assign( ImpTokenFile, ImpTokenFileName ); Reset( ImpTokenFile );

            Assign( RVFile, RVFileName ); Reset( RVFile );

            Assign( WVFile, WVFileName ); Reset( WVFile );
            Assign( ACFile, ACFileName ); Reset( ACFile );

            IOFileName     := SysName+UpperCase( Prefix )+'IO.PAS';

            Assign( IOFile, IOFileName );
            Rewrite( IOFile );

            Writeln( IOFile, 'UNIT ',SysName,Prefix,'IO;' );
            LF;
            Writeln( IOFile, '// This code was generated automatically by running DBGen' );
            Writeln( IOFile, '// Do not change it - any changes you make will disappear' );
            Writeln( IOFile, '// when DBGen is run again.' );
            LF;
            NS;
            Writeln( IOFile, 'INTERFACE USES ',SysName,'DEFS, IOSTREAM, ',SysName,'AUDITUTILS;' );
            NS;
            LF;
            Writeln( IOFile, 'CONST' );
            While not EOF( IntTokenFile ) do
            Begin
               Readln( IntTokenFile, S );
               Writeln( IOFile, S );
            end;
            LF;

            Writeln( IOFile, 'FUNCTION  IsA',Name,'_Rec ( P : Pointer ): Boolean;' );
            Writeln( IOFile, 'PROCEDURE Write_',Name,'_Rec ( Var O : T', Name, '_Rec ; Var F : TIOStream );' );
            Writeln( IOFile, 'PROCEDURE Read_',Name,'_Rec ( Var O : T', Name, '_Rec ; Var F : TIOStream );' );
            Writeln( IOFile, 'FUNCTION  New_',Name,'_Rec : p',Name,'_Rec ;' );
            Writeln( IOFile, 'PROCEDURE Free_',Name,'_Rec_Dynamic_Fields ( Var O : T', Name, '_Rec );' );
            Writeln( IOFile, 'FUNCTION ',Name,'_Rec_Delta(P1, P2, P3: p',Name,'_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;' );
            Writeln( IOFile, 'procedure Copy_',Name,'_Rec(P1, P2: p',Name,'_Rec);' );
            Writeln( IOFile, 'procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);');
            LF;
            NS;
            Writeln( IOFile, 'IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;' );
            NS;
            LF;
            Writeln( IOFile, 'CONST' );
            Writeln( IOFile, '   SUnitName           = ', Q, SysName,UPrefix,'IO', Q , ';' );
            Writeln( IOFile, '   SBoundsError        = ', Q, SysName,UPrefix,'IO Error: %s is out of bounds [ %d %d ], value is %d', Q, ';' );
            Writeln( IOFile, '   SInvalidPointer     = ', Q, SysName,UPrefix,'IO Error: Pointer is NIL in IsA', Name, '_Rec', Q, ';' );
            Writeln( IOFile, '   SInvalidType        = ', Q, SysName,UPrefix,'IO Error: Type is invalid in IsA', Name, '_Rec', Q, ';' );
            Writeln( IOFile, '   SInvalidEOR         = ', Q, SysName,UPrefix,'IO Error: EOR is missing in IsA', Name, '_Rec', Q, ';' );
            Writeln( IOFile, '   SUnknownToken       = ', Q, SysName,UPrefix,'IO Error: Unknown token %d in Read_', Name, '_Rec', Q, ';' );
            Writeln( IOFile, '   SInsufficientMemory = ', Q, SysName,UPrefix,'IO Error: Out of memory in New_', Name, '_Rec', Q, ';' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );' );
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   If ( Value >= Min ) and' );
            Writeln( IOFile, '      ( Value <= Max ) then exit;' );
            Writeln( IOFile, '   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'CONST' );
            While not EOF( ImpTokenFile ) do
            Begin
               Readln( ImpTokenFile, S );
               Writeln( IOFile, S );
            end;
            LF;
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION IsA',Name,'_Rec ( P : Pointer ): Boolean;' );
            LF;
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   If P=NIL then' );
            Writeln( IOFile, '      Raise ECorruptData.Create( SInvalidPointer );' );
            Writeln( IOFile, '   With P',Name,'_Rec ( P )^ do Begin' );
            Writeln( IOFile, '      If ',Prefix,'Record_Type',' <> tkBegin_',Name,' then' );
            Writeln( IOFile, '         Raise ECorruptData.Create( SInvalidType );' );
            Writeln( IOFile, '      If ',Prefix,'EOR',' <> tkEnd_',Name,' then' );
            Writeln( IOFile, '         Raise ECorruptData.Create( SInvalidEOR );' );
            Writeln( IOFile, '   end;' );
            Writeln( IOFile, '   Result := TRUE;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'PROCEDURE Write_',Name,'_Rec ( Var O : T', Name, '_Rec ; Var F : TIOStream );' );
            While not EOF( WVFile ) do
            Begin
               Readln( WVFile, S );
               Writeln( IOFile, S );
            end;
            LF;
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   If IsA',Name,'_Rec ( @O ) then With O do' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      F.WriteToken( tkBegin_',Name,' );' );
            While not EOF( WriteFile ) do
            Begin
               Readln( WriteFile, S );
               Writeln( IOFile, S );
            end;
            Writeln( IOFile, '      F.WriteToken( tkEnd_',Name,' );' );
            Writeln( IOFile, '   end;' );
            Writeln( IOFile, 'end; { of Write_',Name,'_Rec }' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'PROCEDURE Read_',Name,'_Rec ( Var O : T', Name, '_Rec; Var F : TIOStream );' );
            While not EOF( RVFile ) do
            Begin
               Readln( RVFile, S );
               Writeln( IOFile, S );
            end;
            LF;
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   FillChar( O, ',Name,'_Rec_Size, 0 );' );
            Writeln( IOFile, '   O.',Prefix,'Record_Type := tkBegin_',Name,';' );
            Writeln( IOFile, '   O.',Prefix,'EOR := tkEnd_',Name,';' );
            Writeln( IOFile, '   Token := tkBegin_',Name,';' );
            Writeln( IOFile, '' );
            Writeln( IOFile, '   While Token <> tkEnd_',Name,' do With O do' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      Case Token of' );
            Writeln( IOFile, '         tkBegin_',Name,' :; { Do Nothing }' );
            Writeln( IOFile, '         tkEnd_',Name,' :; { Do Nothing }' );
            While not EOF( ReadFile ) do
            Begin
               Readln( ReadFile, S );
               Writeln( IOFile, S );
            end;
            Writeln( IOFile, '         else' );
            Writeln( IOFile, '            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );' );
            Writeln( IOFile, '      end; { of Case }' );
            Writeln( IOFile, '      Token := F.ReadToken;' );
            Writeln( IOFile, '   end; { of While }' );
            Writeln( IOFile, 'end; { of Read_',Name,'_Rec }' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION New_',Name,'_Rec : p',Name,'_Rec ;' );
            Writeln( IOFile, '' );
            Writeln( IOFile, 'Var' );
            Writeln( IOFile, '   P : p',Name,'_Rec;' );
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   SafeGetMem( P, ',Name,'_Rec_Size ); ' );
            Writeln( IOFile, '   If Assigned( P ) then With P^ do' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      FillChar( P^, ',Name,'_Rec_Size, 0 );' );
            Writeln( IOFile, '      ',Prefix,'Record_Type := tkBegin_',Name,';' );
            Writeln( IOFile, '      ',Prefix,'EOR         := tkEnd_',Name,';' );
            Writeln( IOFile, '   end' );
            Writeln( IOFile, '   else' );
            Writeln( IOFile, '      Raise EInsufficientMemory.Create( SInsufficientMemory );' );
            Writeln( IOFile, '   New_',Name,'_Rec := P;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'PROCEDURE Free_',Name,'_Rec_Dynamic_Fields ( Var O : T', Name, '_Rec );' );
            Writeln( IOFile, '' );
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   If IsA',Name,'_Rec ( @O ) then With O do' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      { Free any dynamically allocated memory }' );
            While not EOF( FreeFile ) do
            Begin
               Readln( FreeFile, S );
               Writeln( IOFile, S );
            end;
            Writeln( IOFile, '   end;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            //All tokens
            Writeln( IOFile, 'procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);');
            Writeln( IOFile, 'var' );
            Writeln( IOFile, '  i, j: integer;' );
            Writeln( IOFile, 'begin' );
            Writeln( IOFile, '  for i := Low(ChangedFields) to High(ChangedFields) do' );
            Writeln( IOFile, '    ChangedFields[i] := 0;');

            Reset( ImpTokenFile );
            Readln( ImpTokenFile, S );
            FirstToken := Copy(S, 1, Pos('=', S) - 1);
            While not EOF( ImpTokenFile ) do
            Begin
              Readln( ImpTokenFile, S );
              LastToken := Copy(S, 1, Pos('=', S) - 1);
            end;
            Writeln( IOFile, '  j := 0;');
            Writeln( IOFile, '  for i := ',Trim(FirstToken),' to ',Trim(LastToken),' do begin' );
            Writeln( IOFile, '    ChangedFields[j] := i;');
            Writeln( IOFile, '    Inc(j);');
            Writeln( IOFile, '  end;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            //Delta
            Writeln( IOFile, 'FUNCTION ',Name,'_Rec_Delta(P1, P2, P3: p',Name,'_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;' );
            Writeln( IOFile, 'var' );
            Writeln( IOFile, '  i: integer;' );
            Writeln( IOFile, 'begin' );
            Writeln( IOFile, '  for i := Low(ChangedFields) to High(ChangedFields) do' );
            Writeln( IOFile, '    ChangedFields[i] := 0;');
            Writeln( IOFile );
            Writeln( IOFile, '  //Add' );
            Writeln( IOFile, '  if not Assigned(P2) then begin' );
            Writeln( IOFile, '    Copy_',Name,'_Rec(P1, P3);' );
            Writeln( IOFile, '    SetAllFieldsChanged(ChangedFields);' );
            Writeln( IOFile, '    Exit;' );
            Writeln( IOFile, '  end;' );
            Writeln( IOFile );
            Writeln( IOFile, '  //Change' );
            Writeln( IOFile, '  i := 0;' );
            While not EOF( ACFile ) do
            Begin
               Readln( ACFile, S );
               Writeln( IOFile, S );
            end;
            Writeln( IOFile );
            Writeln( IOFile, '  Result := (i > 0);');
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            //Copy
            Writeln( IOFile, 'procedure Copy_',Name,'_Rec(P1, P2: p',Name,'_Rec);' );
            Writeln( IOFile, 'var' );
            Writeln( IOFile, '  S: TIOStream;' );
            Writeln( IOFile, 'begin' );
            Writeln( IOFile, '  S := TIOStream.Create;' );
            Writeln( IOFile, '  try' );
            Writeln( IOFile, '    Write_',Name,'_Rec(P1^, S);' );
            Writeln( IOFile, '    S.Position := 0;' );
            Writeln( IOFile, '    Read_',Name,'_Rec(P2^, S);' );
            Writeln( IOFile, '  finally' );
            Writeln( IOFile, '    S.Free;' );
            Writeln( IOFile, '  end;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'END.' );

            Close( IOFile );

            Close( ReadFile );
            Close( WriteFile );
            Close( FreeFile );
            Close( RVFile );
            Close( WVFile );
            Close( IntTokenFile );
            Close( ImpTokenFile );

            DeleteFile( RVFileName );
            DeleteFile( WVFileName );

            DeleteFile( ReadFileName );
            DeleteFile( WriteFileName );
            DeleteFile( IntTokenFileName );
            DeleteFile( ImpTokenFileName );

         end;
      end;
   end;
   CloseImportFile;
end;

// -----------------------------------------------------------------------------

end.

