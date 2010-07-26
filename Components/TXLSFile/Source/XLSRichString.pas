unit XLSRichString;

{-----------------------------------------------------------------
    SM Software, 2000-2006

    TXLSFile v.4.0

    Rich strings

    Rev history:
    2006-08-31  Add: GetRichTextWidthPx added

-----------------------------------------------------------------}

(*
    Rich format grammar:

    RichFormat::= RichFormat
      [;<PosStart>-<PosEnd>(
      [style:{b}{i}{u};]
      [color:<rgb-color>;]
      [size:<size>;]
      [font:<fontname>;]
      [script:{sub}|{super};]      
      )]

    Examples:
      1-3(style:b;)
      1-3(style:b;color:ffcc00;);6-10(style:i;);
*)


{$I XLSFile.inc}

interface

uses SysUtils, XLSFont, XLSFormat, XLSStrUtil, XLSBase;

function RichFormatToFontIndex(const ARichFormat: AnsiString;
                               const ADefaultFontIndex: Integer;
                               const FontTable: TVirtualFontTable): Integer;
                               
function RichFormatToRichSSTPart(const ARichFormat: AnsiString;
                                 const ADefaultFontIndex: Integer;
                                 const FontTable: TVirtualFontTable): AnsiString;

function RichFormatToRichCommentPart(const ARichFormat: AnsiString;
                                     const ADefaultFontIndex: Integer;
                                    const FontTable: TVirtualFontTable): AnsiString;

function GetRichTextWidthPx(const AText: WideString;
                            const ARotation: Integer;
                            const ARichFormat: AnsiString;
                            const ADefaultFontIndex: Integer;
                            const FontTable: TVirtualFontTable): Integer;

function FontIndexToRichFormat(const CharFrom, CharTo: Integer;
                               const AFontIndex: Integer;
                               const AFontTable: TVirtualFontTable): AnsiString;
function ShiftRichFormatChars(const ARichFormat: AnsiString;
                              const ShiftCount: Integer): AnsiString;

implementation
uses
     Windows
   {$IFDEF XLF_D2009}
   , AnsiStrings
   {$ENDIF}
   ;

function RichFormatToFontIndex(const ARichFormat: AnsiString;
                               const ADefaultFontIndex: Integer;
                               const FontTable: TVirtualFontTable): Integer;
var
  APFontData: PFontData;
  S, S2: AnsiString;
  Pos1, Pos2: Integer;
  ColorRGB: Integer;
  FontSize: Integer;
  FontName: AnsiString;
  Changed: Boolean;
begin
  Changed:= False;

  { Load font index }
  APFontData:= FontTable.LoadFontToBuffer(ADefaultFontIndex);

  {$IFDEF XLF_D2009}
  S:= AnsiStrings.Trim(
      AnsiStrings.StringReplace(
      AnsiStrings.StringReplace(ARichFormat, '(', '', [rfReplaceAll]),
                   ')', '', [rfReplaceAll])
      );
  {$ELSE}
  S:= Trim(
      StringReplace(
      StringReplace(ARichFormat, '(', '', [rfReplaceAll]),
                   ')', '', [rfReplaceAll])
      );
  {$ENDIF}
  S:= S + ';';

  { Find style string }
  Pos1:= Pos(AnsiString('style:'), S);
  if (Pos1 > 0) then
  begin
    S2:= Copy(S, Pos1 + Length('style:'), Length(S));
    Pos2:= Pos(AnsiString(';'), S2);
    S2:= Trim(AnsiLowerCase(Copy(S2, 1, Pos2 - 1)));

    { Analyze format string }
    if Pos(AnsiString('b'), S2) > 0 then
      APFontData^.Bold:= True;
    if Pos(AnsiString('i'), S2) > 0 then
      APFontData^.Italic:= True;
    if Pos(AnsiString('u'), S2) > 0 then
      APFontData^.Underline:= True;

    Changed:= True;
  end;

  { Find script style }
  Pos1:= Pos(AnsiString('script:'), S);
  if (Pos1 > 0) then
  begin
    S2:= Copy(S, Pos1 + Length('script:'), Length(S));
    Pos2:= Pos(AnsiString(';'), S2);
    S2:= Trim(AnsiLowerCase(Copy(S2, 1, Pos2 - 1)));

    { Analyze script string }
    if Pos(AnsiString('sub'), S2) > 0 then
      APFontData^.SSStyle:= xlFontSSSub;
    if Pos(AnsiString('super'), S2) > 0 then
      APFontData^.SSStyle:= xlFontSSSuper;

    Changed:= True;
  end;

  { Find color string }
  Pos1:= Pos(AnsiString('color:'), S);
  if (Pos1 > 0) then
  begin
    S2:= Copy(S, Pos1 + Length('color:'), Length(S));
    Pos2:= Pos(AnsiString(';'), S2);
    S2:= Trim(AnsiLowerCase(Copy(S2, 1, Pos2 - 1)));

    { Analyze color string. Color string is hex. }
    if Pos(AnsiString('$'), S2) <> 1 then
      S2:= '$' + S2;
    ColorRGB:= StrToInt(String(S2));
    APFontData^.ColorIndex:= ColorRGBToXLSColorIndex(ColorRGB);
    Changed:= True;
  end;

  { Find size string }
  Pos1:= Pos(AnsiString('size:'), S);
  if (Pos1 > 0) then
  begin
    S2:= Copy(S, Pos1 + Length('size:'), Length(S));
    Pos2:= Pos(AnsiString(';'), S2);
    S2:= Trim(AnsiLowerCase(Copy(S2, 1, Pos2 - 1)));

    { Size is integer }
    FontSize:= StrToInt(String(S2));
    APFontData^.Height:= FontSize;
    Changed:= True;
  end;

  { Find fontname string }
  Pos1:= Pos(AnsiString('font:'), S);
  if (Pos1 > 0) then
  begin
    S2:= Copy(S, Pos1 + Length('font:'), Length(S));
    Pos2:= Pos(AnsiString(';'), S2);
    S2:= Trim(Copy(S2, 1, Pos2 - 1));

    FontName:= S2;
    SetFontDataNameAsString(APFontData, WideString(FontName));
    Changed:= True;
  end;

  { Get new font index }
  if Changed then
    Result:= FontTable.SaveChangedBuffer
  else
    Result:= ADefaultFontIndex;
end;

function FontIndexToRichFormat(const CharFrom, CharTo: Integer;
                               const AFontIndex: Integer;
                               const AFontTable: TVirtualFontTable): AnsiString;
var
  PFont: PFontData;
  S: AnsiString;
  I: Integer;
begin
  Result:= '';

  { Ignore bad font index }
  if not ((AFontIndex >= 0) and (AFontIndex < AFontTable.Count)) then
    Exit;

  PFont:= AFontTable.Font[AFontIndex];
  if not Assigned(PFont) then
    Exit;

  { Style }
  S:= '';
  if PFont^.Bold then S:= S + 'b';
  if PFont^.Italic then S:= S + 'i';
  if PFont^.Underline then S:= S + 'u';
  if (S <> '') then
    Result:= Result + 'style:' + S + ';';

  { Color }
  I:= XLSColorIndexToColorRGB(PFont.ColorIndex);
  S:= '000000' + AnsiString(IntToHex(I, 6));
  S:= Copy(S, Length(S) - 6 + 1, 6);
  Result:= Result + 'color:' + S + ';';

  { Size }
  S:= AnsiString(IntToStr(PFont.Height));
  Result:= Result + 'size:' + S + ';';

  { Font name }
  S:= AnsiString(GetFontDataNameAsString(PFont));
  Result:= Result + 'font:' + S + ';';

  { Script }
  case PFont.SSStyle of
    xlFontSSSuper: S:= 'super';
    xlFontSSSub  : S:= 'sub';
    else S:= '';
  end;
  if (S <> '') then
    Result:= Result + 'script:' + S + ';';

  { Add char indexes }
  Result:= AnsiString(IntToStr(CharFrom)) + '-' + AnsiString(IntToStr(CharTo))
         + '(' + Result + ');';
end;

function RichFormatToRichSSTPart(const ARichFormat: AnsiString;
                                 const ADefaultFontIndex: Integer;
                                 const FontTable: TVirtualFontTable): AnsiString;
var
  S, S2, S3: AnsiString;
  Pos1, Pos2: Integer;
  CharStart, CharEnd: Integer;
  FontIndex: Integer;
  DefaultFontIndex: Integer;  
  FormatRun: array[1..4] of AnsiChar;
begin
  Result:= '';
  S:= Trim(ARichFormat) + ';';
  Pos1:= Pos(AnsiString(');'), S);
  while (Pos1 > 0) do
  begin
    S2:= Copy(S, 1, Pos1);
    Pos2:= Pos(AnsiString('('), S2);
    S3:= Copy(S2, 1, Pos2-1);
    S2:= Copy(S2, Pos2+1, Length(S2));
    Pos2:= Pos(AnsiString('-'), S3);
    CharStart:= StrToInt(Trim(Copy(String(S3), 1, Pos2-1)));
    CharEnd:= StrToInt(Trim(Copy(String(S3), Pos2+1, Length(S3))));
    { Character index must be 0-based }
    CharStart:= CharStart-1;

    FontIndex:= RichFormatToFontIndex(S2, ADefaultFontIndex, FontTable);
    DefaultFontIndex:= ADefaultFontIndex;
    { Skip $04 font }    
    if (FontIndex >= $04) then FontIndex:= FontIndex + 1;
    if (DefaultFontIndex >= $04) then DefaultFontIndex:= DefaultFontIndex + 1;

    Move(CharStart, FormatRun[1], 2);
    Move(FontIndex, FormatRun[3], 2);
    Result:= Result + FormatRun[1] + FormatRun[2] + FormatRun[3] + FormatRun[4];
    Move(CharEnd, FormatRun[1], 2);
    Move(DefaultFontIndex, FormatRun[3], 2);
    Result:= Result + FormatRun[1] + FormatRun[2] + FormatRun[3] + FormatRun[4];

    { next formatting run }
    S:= Copy(S, Pos1 + 2, Length(S));
    Pos1:= Pos(AnsiString(');'), S);
  end;
end;

function RichFormatToRichCommentPart(const ARichFormat: AnsiString;
                                 const ADefaultFontIndex: Integer;
                                 const FontTable: TVirtualFontTable): AnsiString;
var
  S, S2, S3: AnsiString;
  Pos1, Pos2: Integer;
  CharStart, CharEnd: Integer;
  FontIndex: Integer;
  DefaultFontIndex: Integer;
  FormatRun: array[1..4] of AnsiChar;
  PrevCharIndex: Integer;
  PrevFormatPart: AnsiString;
begin
  Result:= '';
  PrevFormatPart:= '';
  PrevCharIndex:= -1;
  S:= Trim(ARichFormat) + ';';
  Pos1:= Pos(AnsiString(');'), S);
  while (Pos1 > 0) do
  begin
    S2:= Copy(S, 1, Pos1);
    Pos2:= Pos(AnsiString('('), S2);
    S3:= Copy(S2, 1, Pos2-1);
    S2:= Copy(S2, Pos2+1, Length(S2));
    Pos2:= Pos(AnsiString('-'), S3);
    CharStart:= StrToInt(Trim(Copy(String(S3), 1, Pos2-1)));
    CharEnd:= StrToInt(Trim(Copy(String(S3), Pos2+1, Length(S3))));
    { Character index must be 0-based }
    CharStart:= CharStart-1;

    FontIndex:= RichFormatToFontIndex(S2, ADefaultFontIndex, FontTable);
    DefaultFontIndex:= ADefaultFontIndex;
    { Skip $04 font }
    if (FontIndex >= $04) then FontIndex:= FontIndex + 1;
    if (DefaultFontIndex >= $04) then DefaultFontIndex:= DefaultFontIndex + 1;

    if (PrevCharIndex <> CharStart) then
      Result:= Result + PrevFormatPart;

    Move(CharStart, FormatRun[1], 2);
    Move(FontIndex, FormatRun[3], 2);
    Result:= Result + FormatRun[1] + FormatRun[2] + FormatRun[3] + FormatRun[4];
    Result:= Result + #0#0#0#0;

    PrevFormatPart:= '';
    Move(CharEnd, FormatRun[1], 2);
    Move(DefaultFontIndex, FormatRun[3], 2);
    PrevFormatPart:= FormatRun[1] + FormatRun[2] + FormatRun[3] + FormatRun[4];
    PrevFormatPart:= PrevFormatPart + #0#0#0#0;
    PrevCharIndex:= CharEnd;

    { next formatting run }
    S:= Copy(S, Pos1 + 2, Length(S));
    Pos1:= Pos(AnsiString(');'), S);
  end;

  if PrevFormatPart <> '' then
      Result:= Result + PrevFormatPart;
end;

function GetRichTextWidthPx(const AText: WideString;
                            const ARotation: Integer;
                            const ARichFormat: AnsiString;
                            const ADefaultFontIndex: Integer;
                            const FontTable: TVirtualFontTable): Integer;
var
  S, S2, S3: AnsiString;
  Pos1, Pos2: Integer;
  CharStart, CharEnd, PrevCharEnd: Integer;
  FontIndex: Integer;
  ATextPart: WideString;
  Size: TSize;
  Width, Height: Integer;  
begin
  Result:= 0;

  if Length(AText) = 0 then
    Exit;

  Width:= 0;
  Height:= 0;
  S:= Trim(ARichFormat) + ';';
  PrevCharEnd:= 0;

  Pos1:= Pos(AnsiString(');'), S);
  while (Pos1 > 0) do
  begin
    S2:= Copy(S, 1, Pos1);
    Pos2:= Pos(AnsiString('('), S2);
    S3:= Copy(S2, 1, Pos2-1);
    S2:= Copy(S2, Pos2+1, Length(S2));
    Pos2:= Pos(AnsiString('-'), S3);
    CharStart:= StrToInt(Trim(Copy(String(S3), 1, Pos2-1)));
    CharEnd:= StrToInt(Trim(Copy(String(S3), Pos2+1, Length(S3))));

    if (CharStart - (PrevCharEnd + 1)) > 0 then
    begin
      ATextPart:= Copy(AText, PrevCharEnd + 1, CharStart - PrevCharEnd);
      Size:= GetTextSize(ATextPart, ADefaultFontIndex, FontTable);
      Width:= Width + Size.cx;
      if Size.cy > Height then Height:= Size.cy;
    end;

    FontIndex:= RichFormatToFontIndex(S2, ADefaultFontIndex, FontTable);
    if (CharEnd - CharStart) > 0 then
    begin
      ATextPart:= Copy(AText, CharStart, CharEnd - CharStart + 1);
      Size:= GetTextSize(ATextPart, FontIndex, FontTable);
      Width:= Width + Size.cx;
      if Size.cy > Height then Height:= Size.cy;
    end;

    { next format }
    PrevCharEnd:= CharEnd;
    S:= Copy(S, Pos1 + 2, Length(S));
    Pos1:= Pos(AnsiString(');'), S);
  end;

  {last part}
  if  (PrevCharEnd < Length(AText)) then
  begin
    CharStart:= PrevCharEnd + 1;
    CharEnd:= Length(AText);
    ATextPart:= Copy(AText, CharStart, CharEnd - CharStart + 1);
    Size:= GetTextSize(ATextPart, ADefaultFontIndex, FontTable);
    Width:= Width + Size.cx;
    if Size.cy > Height then Height:= Size.cy;
  end;

  { Adjust padding and rotate }
  Width:= round(1.035466 * Width + 0.6 * Width / Length(AText) );
  Height:= round(1.0 * Height * 1.50);

  if ( ARotation = 90 ) then
     Width:= Height
  else if ( ARotation <> 0 ) then
  begin
    Width:= round(Width  * cos(ARotation * Pi / 180.0) + Height * sin(ARotation * Pi / 180.0));
  end;

  Result:= Width;
end;

function ShiftRichFormatChars(const ARichFormat: AnsiString;
                              const ShiftCount: Integer): AnsiString;
var
  S, S2, S3: AnsiString;
  Pos1, Pos2: Integer;
  CharStart, CharEnd: Integer;
begin
  Result:= '';
  S:= Trim(ARichFormat) + ';';
  Pos1:= Pos(AnsiString(');'), S);
  while (Pos1 > 0) do
  begin
    S2:= Copy(S, 1, Pos1);
    Pos2:= Pos(AnsiString('('), S2);
    S3:= Copy(S2, 1, Pos2-1);
    S2:= Copy(S2, Pos2+1, Length(S2));
    Pos2:= Pos(AnsiString('-'), S3);
    CharStart:= StrToInt(Trim(Copy(String(S3), 1, Pos2-1)));
    CharEnd:= StrToInt(Trim(Copy(String(S3), Pos2+1, Length(S3))));

    { Shift chars }
    CharStart:= CharStart + ShiftCount;
    CharEnd:= CharEnd + ShiftCount;

    Result:= Result
           + AnsiString(IntToStr(CharStart)) + '-' + AnsiString(IntToStr(CharEnd))
           + '(' + S2 + ';';

    { next formatting run }
    S:= Copy(S, Pos1 + 2, Length(S));
    Pos1:= Pos(AnsiString(');'), S);
  end;
end;

end.
