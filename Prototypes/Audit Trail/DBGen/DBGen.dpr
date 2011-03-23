program DBGen;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  DBMISC in 'DBMISC.PAS',
  DBREAD in 'DBREAD.PAS',
  DBRV in 'DBRV.PAS',
  DBTOKENS in 'DBTOKENS.PAS',
  DBUNITS in 'DBUNITS.PAS',
  DBWRITE in 'DBWRITE.PAS',
  DBWV in 'DBWV.PAS',
  DBCRC in 'DBCRC.pas',
  DBIO in 'DBIO.PAS',
  DBObj in 'DBObj.pas',
  DBFree in 'DBFree.pas',
  DBAUDIT in 'DBAUDIT.PAS';

Var
   SysName : String[2];
begin
   If ParamCount = 0 then
   Begin
      Writeln( 'DBGEN.EXE Builds Record Definitions' );
      Writeln;
      Writeln( 'Usage is:' );
      Writeln( 'DBGEN BK (Builds BKDEFS.PAS, BKCRC.PAS and BK??IO.PAS from BK.TXT)' );
      Halt( 1 );
   end;
   SysName := UpperCase( ParamStr( 1 ) );
   If not FileExists( SysName + '.TXT' ) then
   Begin
      Writeln( 'The file ',SysName, '.TXT does not exist' );
      Halt;
   end;
   Writeln( 'Generating Record Definitions' );
   GenerateUnitFiles( SysName );
   Writeln( 'Generating Audit Definitions' );
   GenerateAuditFiles( SysName );
   Writeln( 'Generating Audit Utils' );
   GenerateAuditUtils( SysName );
   Writeln( 'Generating Audit Compare' );
   GenerateAuditCompare( SysName );
   Writeln( 'Generating Tokens' );
   GenerateTokenFiles( SysName );
   Writeln( 'Generating Read Procedures' );
   GenerateReadFiles( SysName );
   Writeln( 'Generating Free Procedures' );
   GenerateFreeFiles( SysName );
   Writeln( 'Generating Read Variables' );
   GenerateRVFiles( SysName );
   Writeln( 'Generating Write Variables' );
   GenerateWVFiles( SysName );
   Writeln( 'Generating Write Files Procedures' );
   GenerateWriteFiles( SysName );
   Writeln( 'Generating IO Procedures' );
   GenerateIOFiles( SysName );
   Writeln( 'Generating CRC Procedures' );
   GenerateCRCFiles( SysName );
   Writeln( 'Completed OK.' );
end.


