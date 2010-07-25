Unit DBIO;

INTERFACE

Procedure GenerateIOFiles( SysName : String );

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }
IMPLEMENTATION Uses DBMisc, ReadF;
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

Procedure GenerateIOFiles( SysName : String );

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

Function MakeName ( S : String ): String;
Var O : String; i : Integer;
Begin
   O:=S;
   For i:=1 to Length( O ) do if not ( O[i] in ['a'..'z','0'..'9','_','A'..'Z'] ) then O[i]:='_';         
   MakeName:=O;
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

CONST
   Q = '''';
   Sp3  = '   ';
   Sp6  = '      ';
   Sp9  = '         ';
   sp12 = '            ';

Var
   InFile      : Text;
   ReadFile    : Text;
   RVFile      : Text;
   WriteFile   : Text;
   WVFile      : Text;
   TokenFile   : Text;
   IOFile      : Text;
   Name        : String[60];
   Prefix      : String[2];
   UPrefix     : String[2];
   
   IOFileName        : String;
   ReadFileName      : String;
   WriteFileName     : String;
   RVFileName        : String;
   WVFileName        : String;
   TokenFileName     : String;
   UnitFileName      : String;
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

   {  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

   Procedure NS;

   Begin
      Writeln( IOFile, '{  -------------------------------------------------------------------  }' );
   end;

   {  -------------------------------------------------------------------  }

   Procedure LF;

   Begin
      Writeln( IOFile );
   end;

   {  -------------------------------------------------------------------  }

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
            UPrefix  := UpCaseStr( Prefix );
            TokenNo  := GetLField( 4 );

            ReadFileName      := UpCaseStr( Prefix )+'.R';
            WriteFileName     := UpCaseStr( Prefix )+'.W';
            TokenFileName     := UpCaseStr( Prefix )+'.TOK';

            RVFileName        := UpCaseStr( Prefix )+'.RV';

            WVFileName        := UpCaseStr( Prefix )+'.WV';

            Assign( ReadFile, ReadFileName ); Reset( ReadFile );
            Assign( WriteFile, WriteFileName ); Reset( WriteFile );
            Assign( TokenFile, TokenFileName ); Reset( TokenFile );

            Assign( RVFile, RVFileName ); Reset( RVFile );

            Assign( WVFile, WVFileName ); Reset( WVFile );

            IOFileName     := SysName+UpCaseStr( Prefix )+'IO.PAS';

            Assign( IOFile, IOFileName );
            Rewrite( IOFile );

            NS;
            LF;

            Writeln( IOFile, 'UNIT ',SysName,Prefix,'IO;' );
            LF;
            Writeln( IOFile, '{$I COMPILER}' );
            LF;
            NS;
            Writeln( IOFile, 'INTERFACE USES ',SysName,'DEFS, IOSTREAM;' );
            NS;
            LF;

            Writeln( IOFile, 'CONST' );
            While not EOF( TokenFile ) do
            Begin
               Readln( TokenFile, S );
               Writeln( IOFile, S );
            end;
            LF;
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION  IsA',Name,'_Rec ( P : Pointer ): Boolean;' );
            Writeln( IOFile, 'PROCEDURE Write_',Name,'_Rec ( Var O : T', Name, '_Rec ; Var F : TIOStream );' );
            Writeln( IOFile, 'PROCEDURE Read_',Name,'_Rec ( Var O : T', Name, '_Rec ; Var F : TIOStream );' );
            Writeln( IOFile, 'FUNCTION  New_',Name,'_Rec : p',Name,'_Rec ;' );
            LF;
            NS;
            Writeln( IOFile, 'IMPLEMENTATION USES {$IFDEF WIN32} BK5EXCEPT, {$ENDIF} MONEYDEF, MALLOC, LOGUTIL;' );
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION CheckBounds( Value, Min, Max : Integer; FieldName : String ): Boolean;' );
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   CheckBounds := TRUE;' );
            Writeln( IOFile, '   If ( Value >= Min ) and' );
            Writeln( IOFile, '      ( Value <= Max ) then exit;' );
            Writeln( IOFile, '   LogError( ' , Q , SysName,UPrefix,'IO', Q , ', ' 
               ,Q, 'Index Bounds Error reading ',Q, ' + FieldName );' );
            Writeln( IOFile, '   {$IFDEF WIN32}' );
            Writeln( IOFile, '      Raise EInvalidDataInFile.Create( ' , Q , SysName,UPrefix,'IO: ', Q , ' + ' 
                                      ,Q, 'Index Bounds Error reading ',Q, ' + FieldName );' );
            Writeln( IOFile, '   {$ENDIF}' );
            Writeln( IOFile, '   CheckBounds := FALSE;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION  IsA',Name,'_Rec ( P : Pointer ): Boolean;' );
            LF;
            Writeln( IOFile, 'Begin' );
            Writeln( IOFile, '   IsA',Name,'_Rec := FALSE;' );
            Writeln( IOFile, '   If P=NIL then' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      LogError( ' , Q , SysName,UPrefix,'IO', Q , ', ' 
               ,Q, 'P is NIL in IsA',Name, Q, ' );' );
            Writeln( IOFile, '      {$IFDEF WIN32}' );
            Writeln( IOFile, '         Raise ECorruptData.Create( ' , Q , SysName,UPrefix,'IO: ', Q , ' + ' 
                                            ,Q, Name, ' pointer is NIL in IsA', Name, Q, ' );' );
            Writeln( IOFile, '      {$ENDIF}' );
            Writeln( IOFile, '      Halt;' );

            Writeln( IOFile, '   end;' );
            Writeln( IOFile, '   With P',Name,'_Rec ( P )^ do' );
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      If ',Prefix,'Record_Type',' <> tkBegin_',Name,' then' );
            Writeln( IOFile, '      Begin' );
            Writeln( IOFile, '         LogError( ' , Q , SysName,UPrefix,'IO', Q , ', ' 
                                         ,Q, 'Corrupted start token in IsA',Name, Q, ' );' );
            Writeln( IOFile, '         {$IFDEF WIN32}' );
            Writeln( IOFile, '            Raise ECorruptData.Create( ' , Q , SysName,UPrefix,'IO: ', Q , ' + ' 
                                            ,Q, 'Corrupted start token in IsA',Name, Q, ' );' );
            Writeln( IOFile, '         {$ENDIF}' );
            Writeln( IOFile, '      end;' );
            Writeln( IOFile, '      If ',Prefix,'EOR',' <> tkEnd_',Name,' then' );
            Writeln( IOFile, '      Begin' );
            Writeln( IOFile, '         LogError( ' , Q , SysName,UPrefix,'IO', Q , ', ' 
                                          ,Q, 'Corrupted EOR in IsA',Name, Q, ' );' );
            Writeln( IOFile, '         {$IFDEF WIN32}' );
            Writeln( IOFile, '            Raise ECorruptData.Create( ' , Q , SysName,UPrefix,'IO', Q , ' + ' 
                                            ,Q, 'Corrupted EOR in IsA',Name, Q, ' );' );
            Writeln( IOFile, '         {$ENDIF}' );
            Writeln( IOFile, '      end;' );
            Writeln( IOFile, '      IsA',Name,'_Rec := TRUE;' );
            Writeln( IOFile, '   end;' );
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
               Writeln( IOFile, Sp3,  S );
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
            Writeln( IOFile, '         Begin' );
            Writeln( IOFile, '            LogError( ' , Q ,SysName,UPrefix,'IO', Q , ', ' 
               ,Q, 'Unknown Token ',Q,' + TokenToStr( Token ) + ',Q,' in Read_',Name, '_Rec', Q, ' );' );
            Writeln( IOFile, '            {$IFDEF WIN32}' );
            Writeln( IOFile, '               Raise EInvalidDataInFile.Create( ' , Q , SysName,UPrefix,'IO: ', Q , ' + ' 
                                            ,Q, 'Unknown Token in Read_',Name, Q, ' );' );
            Writeln( IOFile, '            {$ENDIF}' );
            Writeln( IOFile, '            Halt;' );
            Writeln( IOFile, '         end;' );
            Writeln( IOFile, '      end; { of Case }' );
            Writeln( IOFile, '      Token := F.ReadToken;' );
            Writeln( IOFile, '   end; { of While }' );
            Writeln( IOFile, 'end; { of Read_',Name,'_Rec }' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'FUNCTION  New_',Name,'_Rec : p',Name,'_Rec ;' );
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
            Writeln( IOFile, '   Begin' );
            Writeln( IOFile, '      LogError( ' , Q ,SysName,UPrefix,'IO', Q , ', ' 
               ,Q, 'Unable to allocate a new p',Name,'_Rec ', Q, ' );' );
            Writeln( IOFile, '      {$IFDEF WIN32}' );
            Writeln( IOFile, '         Raise EInsufficientMemory.Create( ' , Q , SysName,UPrefix,'IO: ', Q , ' + ' 
                                            ,Q, 'Memory Allocation Failed in New_',Name, '_Rec', Q, ' );' );
            Writeln( IOFile, '      {$ENDIF}' );
            Writeln( IOFile, '   end;' );
            Writeln( IOFile, '   New_',Name,'_Rec := P;' );
            Writeln( IOFile, 'end;' );
            LF;
            NS;
            LF;
            Writeln( IOFile, 'END.' );

            Close( IOFile );

            Close( ReadFile );
            Close( WriteFile );
            Close( RVFile );
            Close( WVFile );
            Close( TokenFile );

            FileErase( RVFileName );
            FileErase( WVFileName );

            FileErase( ReadFileName );
            FileErase( WriteFileName );
            FileErase( TokenFileName );

         end;
      end;
   end;
   CloseImportFile;
end;

end.

