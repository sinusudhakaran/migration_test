{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

{ __revision_history__
  __revision_history__ }

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }
UNIT READF;
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }
INTERFACE USES DBMISC;
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function  OpenImportFile(FileName : String): Boolean;
Function  EndofImportFile : Boolean;
Procedure ReadLine;
Function  GetAField(N : Word): String;
Function  GetBField(N : Word): Byte;
Function  GetLField(N : Word): LongInt;
Function  NoOfFields: Word;
Function  LineNumber: Word;
Procedure CloseImportFile;

VAR
   LineBuffer  : Array[1..512] of Char;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }
IMPLEMENTATION
{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

{ __keyword_flag__ '%n v%v, %d' }
CONST CurrentVersionNo = 'READF.PAS v1, 24-Mar-94';

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

VAR
   ImportFile  : Text;
   FC,BC,LC    : Word;
   FS          : Array[1..100] of Word;
   FL          : Array[1..100] of Word;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function OpenImportFile( FileName : String ): Boolean;

Begin
   Assign( ImportFile, FileName );
   {$I-} Reset( ImportFile ); {$I+}
   OpenImportFile := ( IOResult=0 );
   FillChar( LineBuffer, Sizeof( LineBuffer ), 0 );
   FillChar( FS, Sizeof( FS ), 0);
   FillChar( FL, Sizeof( FL ), 0);
   FC:=0; BC:=0; LC:=0;
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function EndOfImportFile : Boolean;

Begin
   EndOfImportFile:=EOF( ImportFile );
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

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

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function GetAField( N : Word ): String;
Var Result : String;
Begin
   Result:='';
   If FL[ N ]>0 then
   begin
      Move( LineBuffer[ FS[ N ] ], Result[ 1 ], FL[ N ] );
      Result[ 0 ]:=Chr( FL[N] );
   end;
   GetAField:=Result;
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function GetBField( N : Word ): Byte;

Begin
   GetBField := StrToByte( GetAField( N ) );
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function GetLField( N : Word ): LongInt;
Begin
   GetLField := StrToLong( GetAField( N ) );
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Procedure CloseImportFile;

Begin
   Close(ImportFile);
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function NoOfFields : Word;

Begin
   NoOfFields:=FC;
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

Function  LineNumber: Word;
Begin
   LineNumber:=LC;
end;

{  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  }

END.

