Unit DBMisc;

// -----------------------------------------------------------------------------
INTERFACE Uses SysUtils;
// -----------------------------------------------------------------------------

FUNCTION  TrimQuotesAndSpaces( S : ShortString ) : ShortString;
FUNCTION  ConstStr( C : Char; N : Integer ) : ShortString;  (*  ConstStr returns a ShortString with N characters of value C *)
FUNCTION  NumToStr ( R : real ) : ShortString ;
FUNCTION  StrToLong ( S : ShortString ) : longint ;
FUNCTION  StrToWord ( S : ShortString ) : word ;
FUNCTION  StrToInt ( S : ShortString ) : integer ;
FUNCTION  StrToShort ( S : ShortString ) : shortint ;
FUNCTION  StrToByte ( S : ShortString ) : byte ;
FUNCTION  StrToReal ( S : ShortString ) : real ;

// -----------------------------------------------------------------------------
IMPLEMENTATION
// -----------------------------------------------------------------------------

function TrimQuotesAndSpaces( S : ShortString ) : ShortString;

Begin
   While ( S<>'' ) and ( S[1] in [ ' ', '"' ] ) do Delete ( S,1,1 );
   While ( S<>'' ) and ( S[Length( S )] in [' ', '"'] ) do Delete( S,Length( S ),1 );
   Result := S;
end;

// -----------------------------------------------------------------------------

function ConstStr( C : Char; N : Integer ) : ShortString;  (*  ConstStr returns a ShortString with N characters of value C *)
var
   S : ShortString;
begin
   If N < 0 then N := 0;
   If N = 0 then
   Begin
      ConstStr := '';
      exit;
   end;
   S[0] := Chr( N );
   FillChar( S[1],N,C );
   Result := S;
end;

// -----------------------------------------------------------------------------

function StrToReal ( S : ShortString ) : real ;
var
   R                         : real ;
   code                      : integer ;
begin
   StrToReal                 := 0 ;
   Val ( S , R , code ) ;
   if code = 0 then
      StrToReal              := R ;
end ;

// -----------------------------------------------------------------------------

function Range ( S : ShortString ; Low , High : real ) : boolean ;
var
   R                         : real ;
begin
   R                         := StrToReal ( S ) ;
   Range                     := ( R >= Low ) and
                                ( R <= High ) ;
end ;

// -----------------------------------------------------------------------------

function StrToByte ( S : ShortString ) : byte ;
var
   b                         : byte ;
   code                      : integer ;
begin
   StrToByte                 := 0 ;
   if not Range ( S , 0 , 255 ) then EXIT ;
   Val ( S , b , code ) ;
   StrToByte                 := b ;
end ;

// -----------------------------------------------------------------------------

function StrToShort ( S : ShortString ) : shortint ;
var
   i                         : shortint ;
   code                      : integer ;
begin
   StrToShort                := 0 ;
   if not Range ( S , -128 , 127 ) then EXIT ;
   Val ( S , i , code ) ;
   StrToShort                := i ;
end ;

// -----------------------------------------------------------------------------

function StrToInt ( S : ShortString ) : integer ;
var
   i                         : integer ;
   code                      : integer ;
begin
   StrToInt                  := 0 ;
   if not Range ( S , -32768 , 32767 ) then EXIT ;
   Val ( S , i , code ) ;
   StrToInt                  := i ;
end ;

// -----------------------------------------------------------------------------

function StrToWord ( S : ShortString ) : word ;
var
   W                         : word ;
   code                      : integer ;
begin
   StrToWord                 := 0 ;
   if not Range ( S , 0 , 65535 ) then EXIT ;
   Val ( S , W , code ) ;
   StrToWord                 := W ;
end ;

// -----------------------------------------------------------------------------

function StrToLong ( S : ShortString ) : longint ;
var
   L                         : longint ;
   code                      : integer ;
begin
   StrToLong                 := 0 ;
   if not Range ( S , -2147483647 , 2147483647 ) then EXIT ;
   Val ( S , L , code ) ;
   StrToLong                 := L ;
end ;

// -----------------------------------------------------------------------------

function NumToStr ( R : real ) : ShortString ;
var
   S1 ,
   S2                        : ShortString ;
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
   Result := S1 ;
end ;

// -----------------------------------------------------------------------------


END.
