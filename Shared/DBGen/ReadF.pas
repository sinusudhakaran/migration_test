UNIT READF;

// -----------------------------------------------------------------------------
INTERFACE
// -----------------------------------------------------------------------------

Function  OpenImportFile( FileName : ShortString ): Boolean;
Function  EndofImportFile : Boolean;
Procedure ReadLine;
Function  GetAField(N : Word): ShortString;
Function  GetBField(N : Word): Byte;
Function  GetLField(N : Word): LongInt;
Function  NoOfFields: Word;
Function  LineNumber: Word;
Procedure CloseImportFile;

VAR
   LineBuffer  : Array[1..512] of Char;

// -----------------------------------------------------------------------------
IMPLEMENTATION Uses DBMisc;
// -----------------------------------------------------------------------------

VAR
   ImportFile  : TextFile;
   FC,BC,LC    : Word;
   FS          : Array[1..100] of Word;
   FL          : Array[1..100] of Word;

// -----------------------------------------------------------------------------

Function OpenImportFile( FileName : ShortString ): Boolean;

Begin
   Assign( ImportFile, FileName );
   {$I-} Reset( ImportFile ); {$I+}
   OpenImportFile := ( IOResult=0 );
   FillChar( LineBuffer, Sizeof( LineBuffer ), 0 );
   FillChar( FS, Sizeof( FS ), 0);
   FillChar( FL, Sizeof( FL ), 0);
   FC:=0; BC:=0; LC:=0;
end;

// -----------------------------------------------------------------------------

Function EndOfImportFile : Boolean;

Begin
   EndOfImportFile:=EOF( ImportFile );
end;

// -----------------------------------------------------------------------------

Procedure ReadLine;

Var Ch : Char; S, W : Word;
Begin
   FillChar( LineBuffer, Sizeof( LineBuffer ), 0 );
   FillChar( FS, Sizeof( FS ), 0 );
   FillChar( FL, Sizeof( FL ), 0 );
   BC :=0; FC :=1; Inc( LC );
   Repeat
      Read( ImportFile, Ch );
      If ( Ch='|' ) then
         Inc( FC )
      else
      If not ( Ch in [ #$0D, #$0A ] ) then
      Begin
         Inc( BC );
         LineBuffer[ BC ] := Ch;
         Inc( FL[ FC ] );
      end;
   Until ( Ch = #$0A );

   S:=0;
   For W:=1 to FC do if FL[ W ]>0 then
   Begin
      FS[ W ]:=S+1;
      S:=S+FL[ W ];
   end;
end;

// -----------------------------------------------------------------------------

Function GetAField( N : Word ): ShortString;
Begin
   Result:='';
   If FL[ N ]>0 then
   begin
      Move( LineBuffer[ FS[ N ] ], Result[ 1 ], FL[ N ] );
      Result[ 0 ]:=Chr( FL[N] );
   end;
   GetAField := Result;
end;

// -----------------------------------------------------------------------------

Function GetBField( N : Word ): Byte;

Begin
   GetBField := StrToByte( GetAField( N ) );
end;

// -----------------------------------------------------------------------------

Function GetLField( N : Word ): LongInt;
Begin
   GetLField := StrToLong( GetAField( N ) );
end;

// -----------------------------------------------------------------------------

Procedure CloseImportFile;

Begin
   Close(ImportFile);
end;

// -----------------------------------------------------------------------------

Function NoOfFields : Word;

Begin
   NoOfFields:=FC;
end;

// -----------------------------------------------------------------------------

Function  LineNumber: Word;
Begin
   LineNumber:=LC;
end;

// -----------------------------------------------------------------------------

END.

