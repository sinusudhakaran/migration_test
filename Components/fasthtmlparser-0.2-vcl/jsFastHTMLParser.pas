unit jsFastHTMLParser;

interface

Uses SysUtils, Dialogs;

type
  TOnFoundTag  = procedure(Sender: TObject; Tag: string) of object;
  TOnFoundText = procedure(Sender: TObject; Text: string) of object;
  
  TjsFastHTMLParser = class(TObject)
    public
      OnFoundTag   : TOnFoundTag;
      OnFoundText  : TOnFoundText;
      Raw          : Pchar;
      constructor Create(sRaw:String);overload;
      constructor Create(pRaw:PChar);overload;
      Procedure Execute;
  End;

implementation

Function CopyBuffer(StartIndex: PChar;Length:Integer):String;
Var
  S : String;
Begin
  SetLength(S, Length);
  StrLCopy(@S[1], StartIndex, Length);
  Result := S;
End;

constructor TjsFastHTMLParser.Create(sRaw:String);
Begin
  Raw := Pchar(sRaw);
End;

constructor TjsFastHTMLParser.Create(pRaw:Pchar);
Begin
  Raw := pRaw;
End;

Procedure TjsFastHTMLParser.Execute;
Var
  L     : Integer;
  TL    : Integer;
  I     : Integer;
  Done  : Boolean;
  TagStart,
  TextStart,
  P       : PChar;   // Pointer to current char.
  C     : Char;
Begin
  TL := StrLen(Raw);
  I  := 0;
  P  := Raw;
  Done := False;
  If P<>nil then
  Begin
    TagStart := nil;
    Repeat
      TextStart := P;
      { Get next tag position }
      While Not (P^ in [ '<', #0 ]) do
      Begin
        Inc(P);Inc(I);
        if I>=TL then
        Begin
          Done := True;
          Break;
        End;
      End;
      If Done then Break;
      
      { Is there any text before ? }
      if (TextStart<>nil) and (P>TextStart) then
      Begin

        L := P-TextStart;
        { Yes, copy to buffer }
        
        if (assigned(OnFoundText)) then
          OnFoundText(Self, CopyBuffer( TextStart, L ));

      End else
      Begin
        TextStart:=nil;
      End;
      { No }

      TagStart := P;
      while Not (P^ in [ '>', #0]) do
      Begin

        // Find string in tag
        If (P^='"') or (P^='''') then
        Begin
          C:= P^;
          Inc(P);Inc(I); // Skip current char " or '

          // Skip until string end
          While Not (P^ in [C, #0]) do
          Begin
            Inc(P);Inc(I);
          end;
        End;

        Inc(P);Inc(I);
        if I>=TL then
        Begin
          Done := True;
          Break;
        End;
      End;
      If Done then Break;
      { Copy this tag to buffer }
      L := P-TagStart+1;

      if (Assigned(OnFoundTag)) then
        OnFoundTag(Self, CopyBuffer( TagStart, L ));

      Inc(P);Inc(I);
      if I>=TL then Break;

    Until (Done);
  End;
end;

end.
