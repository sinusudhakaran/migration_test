{  -------------------------------------------------------------------  }
Unit Matches;

{$I COMPILER}
{$IFDEF DPMI}
   {$C MOVEABLE DEMANDLOAD DISCARDABLE}
{$ENDIF}

{ --------------------------------------------------------------------  }
INTERFACE
{$IFNDEF WIN32}
type
   ShortString = String;
{$ENDIF}

Function WildCardMatch( Mask, Name : ShortString ) : Boolean;

//******************************************************************************
IMPLEMENTATION

Function WildCardMatch( Mask, Name : ShortString ) : Boolean;

CONST
  AnyChar = '*';         {Match zero or more characters}
  OneChar = '?';         {Match exactly one character}
  EndChar = #255;        {Terminator to match strings}
  CaseSensitive = FALSE;

VAR
  wcMask : ShortString;

   {  -------------------------------------------------------------------  }
   procedure SimplifyMask;
   {-Used internally to simplify mask when object instantiated}
   var
      MLen : Byte;
      MPos : Word;
      OMask : ShortString;
      OLen : Byte absolute OMask;
   Begin
      MLen := Length( wcMask );
      MPos := 1;
      OLen := 0;
      While MPos <= MLen do
      Begin
         if ( MPos = 1 ) or ( wcMask[MPos] <> '*' ) or ( wcMask[MPos-1] <> '*' ) then
         begin
            {Transfer wcMask to OMask, skipping repeated asterisks}
            Inc( OLen );
            OMask[OLen] := wcMask[MPos];
            If not CaseSensitive then OMask[OLen] := UpCase( OMask[OLen] );
         end;
         inc( MPos );
      end;
      wcMask := OMask;
   end;

var
  NLen : Byte;
  MPos : Word;
  NPos : Word;
  MPSave : Word;
  NPSave : Word;
  AnyOn : Boolean;
  Ch : Char;
  i : Byte;
Begin
   WildCardMatch := False;
   NPSave        := 0;
   MPSave        := 0;

   If Mask[0]<>#0 then
   Begin
      While (Mask[0]<>#0) and (Mask[ Byte( Mask[0] )] = ' ' ) do Dec(Mask[0]);
      I := 1;
      While (I <= Byte( Mask[0] ) ) and ( Mask[I] = ' ') do Inc( I );
      Dec( I );
      If I > 0 then Delete(Mask, 1, I);
   end;

   If Name[0]<>#0 then
   Begin
      While (Name[0]<>#0) and (Name[ Byte( Name[0] )] = ' ' ) do Dec(Name[0]);
      I := 1;
      While (I <= Byte( Name[0] ) ) and ( Name[I] = ' ') do Inc( I );
      Dec( I );
      If I > 0 then Delete(Name, 1, I);
   end;

   wcMask := Mask;
   SimplifyMask;
   wcMask[Length( wcMask )+1] := EndChar;

   {Add terminator to input string, make sure string has room for one more char}
   NLen := Length( Name);
   if NLen = 255 then
     Name[255] := EndChar
   else
     Name[NLen+1] := EndChar;

   AnyOn := False;
   MPos := 1;
   NPos := 1;

   While ( wcMask[MPos] <> EndChar ) or ( Name[NPos] <> EndChar ) do
   Begin
      {Look for '*'}
      If wcMask[MPos] = AnyChar then
      Begin
         If MPos >= Length( wcMask ) then
         Begin
            {Last character in wcMask is '*', rest must match}
            WildCardMatch := True;
            Exit;
         end;
         AnyOn := True;
         NPSave := NPos;
         inc( MPos );
         MPSave := MPos;
      end;

      {Get next character from Name string}
      if CaseSensitive then
         Ch := Name[NPos]
      else
         Ch := UpCase( Name[NPos] );

      {Look for literal match}
      If ( Ch <> EndChar ) and ( ( wcMask[MPos] = OneChar ) or ( wcMask[MPos] = Ch ) ) then
      Begin
         {Matching character}
         inc( MPos );
         inc( NPos );
      end
      else
      begin
         {Mismatched character}
         if not AnyOn or ( NPSave >= Length( Name ) ) then
            {Fatal mismatch, no '*' in effect or no way to advance past mismatch}
         Exit;
         {Increment restart point}
         inc( NPSave );
         {Try again at next Name position}
         NPos := NPSave;
         {Restart wcMask just after the '*'}
         MPos := MPSave;
      end;
   end;

   WildCardMatch := True;
end;

END.


