Program DBMake;

Uses DBRead, DBWrite, DBRV, DBWV, DBTokens, DBUnits, DBIO, DBMisc;

Var
   SysName : String[2];

Begin
   If ParamCount = 0 then
   Begin
      Writeln( 'DBMAKE.EXE Builds Record Definitions' );
      Writeln;
      Writeln( 'Usage is:' );
      Writeln( 'DBMAKE BK (Builds BKDEFS.PAS and BK??IO.PAS from BK.TXT)' );
      Writeln( 'DBMAKE SY (Builds SYDEFS.PAS and SY??IO.PAS from SY.TXT)' );
      Writeln( 'DBMAKE LA (Builds LADEFS.PAS and LA??IO.PAS from LA.TXT)' );
      Halt;
   end;
   SysName := UpCaseStr( ParamStr( 1 ) );
   If not FileExist( SysName + '.TXT' ) then
   Begin
      Writeln( 'The file ',SysName, '.TXT does not exist' );
      Halt;
   end;
   Writeln( 'Generating Record Definitions' );
   GenerateUnitFiles( SysName );
   Writeln( 'Generating Tokens' );
   GenerateTokenFiles( SysName );
   Writeln( 'Generating Read Procedures' );
   GenerateReadFiles( SysName );
   Writeln( 'Generating Read Variables' );
   GenerateRVFiles( SysName );
   Writeln( 'Generating Write Variables' );
   GenerateWVFiles( SysName );
   Writeln( 'Generating Write Files Procedures' );
   GenerateWriteFiles( SysName );
   Writeln( 'Generating IO Procedures' );
   GenerateIOFiles( SysName );
   Writeln( 'Completed OK.' );
end.

