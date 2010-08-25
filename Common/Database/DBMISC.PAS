Unit DBMisc;

(* General routines for DOS or TV *)

INTERFACE Uses DOS;

FUNCTION  ConstStr( C : Char; N : Integer ) : String;
FUNCTION  UpCaseStr( S : String ) : String;
FUNCTION  TrimSpaces( S : String ) : String;
function TrimQuotesAndSpaces( S : String ) : String;
FUNCTION  NumToStr ( R : real ) : string ;
FUNCTION  StrToLong ( S : string ) : longint ;
FUNCTION  StrToWord ( S : string ) : word ;
FUNCTION  StrToInt ( S : string ) : integer ;
FUNCTION  StrToShort ( S : string ) : shortint ;
FUNCTION  StrToByte ( S : string ) : byte ;
FUNCTION  StrToReal ( S : string ) : real ;

function FileExist ( Const Path : string ) : boolean ;
function DirExist  ( Const DirName : string ) : boolean ;
function FileErase ( S : string ) : boolean ;
function FileRename ( OldName , NewName : string ) : boolean ;

IMPLEMENTATION

{  -------------------------------------------------------------------  }

{ __keyword_flag__ '%n v%v, %d' }
CONST CurrentVersionNo = 'MISC.PAS v1:3, 27-Feb-97';

{  -------------------------------------------------------------------  }

function UpcaseStr( S : String ) : String;  (*  UpcaseStr converts a string to upper case *)

var
   P : Integer;
begin
   for P := 1 to Length( S ) do S[P] := Upcase( S[P] );
   UpcaseStr := S;
end;

{  -------------------------------------------------------------------  }

function TrimSpaces( S : String ) : String;

Begin
   While ( S<>'' ) and ( S[1]=' ' ) do Delete ( S,1,1 );
   While ( S<>'' ) and ( S[Length( S )]=' ' ) do Delete( S,Length( S ),1 );
   TrimSpaces:=S;
end;

{  -------------------------------------------------------------------  }

function TrimQuotesAndSpaces( S : String ) : String;

Begin
   While ( S<>'' ) and ( S[1] in [ ' ', '"' ] ) do Delete ( S,1,1 );
   While ( S<>'' ) and ( S[Length( S )] in [' ', '"'] ) do Delete( S,Length( S ),1 );
   TrimQuotesAndSpaces:=S;
end;

{  -------------------------------------------------------------------  }

function ConstStr( C : Char; N : Integer ) : String;  (*  ConstStr returns a string with N characters of value C *)
var
   S : string;
begin
   If N < 0 then N := 0;
   If N = 0 then
   Begin
      ConstStr := '';
      exit;
   end;
   S[0] := Chr( N );
   FillChar( S[1],N,C );
   ConstStr := S;
end;

{  -------------------------------------------------------------------  }

function StrToReal ( S : string ) : real ;
var
   R                         : real ;
   code                      : integer ;
begin
   StrToReal                 := 0 ;
   Val ( S , R , code ) ;
   if code = 0 then
      StrToReal              := R ;
end ;

{  -------------------------------------------------------------------  }

function Range ( S : string ; Low , High : real ) : boolean ;
var
   R                         : real ;
begin
   R                         := StrToReal ( S ) ;
   Range                     := ( R >= Low ) and
                                ( R <= High ) ;
end ;

{  -------------------------------------------------------------------  }

function StrToByte ( S : string ) : byte ;
var
   b                         : byte ;
   code                      : integer ;
begin
   StrToByte                 := 0 ;
   if not Range ( S , 0 , 255 ) then EXIT ;
   Val ( S , b , code ) ;
   StrToByte                 := b ;
end ;

{  -------------------------------------------------------------------  }

function StrToShort ( S : string ) : shortint ;
var
   i                         : shortint ;
   code                      : integer ;
begin
   StrToShort                := 0 ;
   if not Range ( S , -128 , 127 ) then EXIT ;
   Val ( S , i , code ) ;
   StrToShort                := i ;
end ;

{  -------------------------------------------------------------------  }

function StrToInt ( S : string ) : integer ;
var
   i                         : integer ;
   code                      : integer ;
begin
   StrToInt                  := 0 ;
   if not Range ( S , -32768 , 32767 ) then EXIT ;
   Val ( S , i , code ) ;
   StrToInt                  := i ;
end ;

{  -------------------------------------------------------------------  }

function StrToWord ( S : string ) : word ;
var
   W                         : word ;
   code                      : integer ;
begin
   StrToWord                 := 0 ;
   if not Range ( S , 0 , 65535 ) then EXIT ;
   Val ( S , W , code ) ;
   StrToWord                 := W ;
end ;

{  -------------------------------------------------------------------  }

function StrToLong ( S : string ) : longint ;
var
   L                         : longint ;
   code                      : integer ;
begin
   StrToLong                 := 0 ;
   if not Range ( S , -2147483647 , 2147483647 ) then EXIT ;
   Val ( S , L , code ) ;
   StrToLong                 := L ;
end ;

{  -------------------------------------------------------------------  }

function NumToStr ( R : real ) : string ;
var
   S1 ,
   S2                        : string ;
   L                         : longint ;
begin
   L                         := Trunc ( R ) ;          { 1.23 -->   1 }
   R                         := Frac ( R ) ;           { 1.23 --> .23 }
   Str ( L : -1 , S1 ) ;
   Str ( R : -1 : 5 , S2 ) ;
   SYSTEM.delete ( S2 , 1 , 1 ) ;
   S1                        := S1 + S2 ;
   while S1 [ length ( S1 ) ] = '0' do
      SYSTEM.delete ( S1 , length ( S1 ) , 1 ) ;
   while S1 [ length ( S1 ) ] = '.' do
      SYSTEM.delete ( S1 , length ( S1 ) , 1 ) ;
   if S1 = '' then
      S1                     := '0' ;
   NumToStr                  := S1 ;
end ;

{  -------------------------------------------------------------------  }

function FileExist ( Const Path : string ) : boolean ;

VAR
   F  :  File;
   W  :  Word;
Begin
   FileExist := FALSE;
   If Path='' then exit;
   Assign ( F, Path );
   GetFAttr ( F, W );
   FileExist := DOSERROR =0 ;
End;

{  -------------------------------------------------------------------  }

function DirExist  ( Const DirName : string ) : boolean ;

VAR
   F  :  File;
   W  :  Word;
Begin
   DirExist := FALSE;
   If DirName='' then exit;
   Assign ( F, DirName );
   GetFAttr ( F, W );
   DirExist := ( DosError = 0 ) and ( W and Directory <> 0 );
End;

{  -------------------------------------------------------------------  }

function FileErase ( S : string ) : boolean ;
var
   F : File ;
begin
   {$I-}
   Assign ( F , S ) ;
   Erase ( F ) ;
   {$I+}
   FileErase := IOresult = 0 ;
end ;

{  -------------------------------------------------------------------  }

function FileRename ( OldName , NewName : string ) : boolean ;
var
   Ftemp : File ;
begin
   SYSTEM.Assign ( Ftemp , OldName ) ;
   {$I-}
   SYSTEM.Rename ( Ftemp , NewName ) ;
   {$I+}
   FileRename := IOresult = 0 ;
end ;

END.
