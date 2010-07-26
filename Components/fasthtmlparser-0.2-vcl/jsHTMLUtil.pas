unit jsHTMLUtil;

interface

Uses SysUtils;

Function GetTagName(Tag:String):String;
  { Return tag name in upper/lowercase! }
  
Function GetTagAttribute(Tag, Attribute: String):String;

Function GetTagAttributei(Tag, Attribute: String):String;

Function GetAttributeValue(Attribute: String):String;
  { Get value of attribute, e.g WIDTH=36 -return-> 36 }


implementation

Function CopyBuffer(StartIndex: PChar;Length:Integer):String;
Var
  S : String;
Begin
  SetLength(S, Length);
  StrLCopy(@S[1], StartIndex, Length);
  Result := S;
End;

Function GetTagName(Tag:String):String;
Var
  P : Pchar;
  S : Pchar;
Begin
  P := Pchar(Tag);
  While P^ in ['<',' '] do Inc(P);
  S := P;
  While Not (P^ in [' ','>',#0]) do Inc(P);
  Result := CopyBuffer( S, P-S);
End;

Function GetTagAttribute(Tag, Attribute: String):String;
Var
  P    : Pchar;
  S    : Pchar;
  C    : Char;
Begin
  P := Pchar(Tag);
  S := StrPos(P, Pchar(Attribute));
  If S<>nil then
  Begin
    P := S;

    // Skip attribute name
    While not (P^ in ['=',' ','>',#0]) do
      Inc(P);

    If (P^='=') then inc(P);
    
    While not (P^ in [' ','>',#0]) do
    Begin

      If (P^ in ['"','''']) then
      Begin
        C:= P^;
        Inc(P); { Skip current character }
      End else
        C:= ' ';

      While not (P^ in [C, #0]) do
        Inc(P);

      Inc(P); { Skip current character }
      Break;
    End;
    Result := CopyBuffer(S, P-S);
  End;
End;

Function GetTagAttributei(Tag, Attribute: String):String;
Var
  P    : Pchar;
  S    : Pchar;
  UT,
  UA   : String;
  Start: Integer;
  L    : Integer;
  C    : Char;
Begin
  UA := Uppercase(Attribute);
  UT := Uppercase(Tag);
  P := Pchar(UT);
  S := StrPos(P, Pchar(UA));
  If S<>nil then
  Begin

    P := S;

    // Skip attribute name
    While not (P^ in ['=',' ','>',#0]) do
      Inc(P);

    If (P^='=') then inc(P);
    
    While not (P^ in [' ','>',#0]) do
    Begin

      If (P^ in ['"','''']) then
      Begin
        C:= P^;
        Inc(P); { Skip current character }
      End else
        C:= ' ';

      While not (P^ in [C, #0]) do
        Inc(P);

      Inc(P); { Skip current character }
      Break;
    End;
    
    L := P-S;
    Start := S - Pchar(UT);
    P := Pchar(Tag);
    S := P;
    Inc(S,Start);
    Result := CopyBuffer(S, L);
  End;
End;

Function GetAttributeValue(Attribute: String):String;
Var
  P    : Pchar;
  S    : Pchar;
  C    : Char;
Begin
  P     := Pchar(Attribute);
  S     := StrPos(P, '=');
  If S<>nil then
  Begin

    Inc(S);  
    P := S; // set P to a character after =

    If (P^ in ['"','''']) then
    Begin
      C := P^;
      Inc(P); { Skip current character }
    End else
      C := ' ';

    S := P;
    While not (P^ in [C, #0]) do
      Inc(P);
    Result := CopyBuffer(S, P-S);

  End;

End;


end.
