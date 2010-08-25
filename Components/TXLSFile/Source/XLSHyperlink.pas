unit XLSHyperlink;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Hyperlinks

    Rev hostory:
    2008-10-07  Fix: Checking of data size fixed

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface

uses HList, XLSBase, XLSError;

{$IFDEF XLF_D3}
type
  Longword = Cardinal;
{$ENDIF}

type
  {TCellHyperlinkType}
  TCellHyperlinkType = (hltAuto, hltURL, hltFile, hltUNC, hltCurrentWorkbook);

{ Parse/compile functions for BIFF8 }  
function CompileCellHyperlink(const AHyperlink: WideString;
  const AHyperlinkType: TCellHyperlinkType): AnsiString;
function ParseCellHyperlink(const ARawData: AnsiString;
  var AHyperlinkType: TCellHyperlinkType;
  var ARowFrom: Word;
  var ARowTo: Word;
  var AColumnFrom: Word;
  var AColumnTo: Word): WideString;

implementation

uses SysUtils, Unicode;

const
  hlGUIDStdLink: array[0..15] of Byte = ($D0, $C9, $EA, $79, $F9, $BA, $CE, $11, $8C, $82, $00, $AA, $00, $4B, $A9, $0B);
  hlGUIDURLLink: array[0..15] of Byte = ($E0, $C9, $EA, $79, $F9, $BA, $CE, $11, $8C, $82, $00, $AA, $00, $4B, $A9, $0B);
  hlGUIDFileMon: array[0..15] of Byte = ($03, $03, $00, $00, $00, $00, $00, $00, $C0, $00, $00, $00, $00, $00, $00, $46 );
  hlMagic1: array[0..23] of Byte = ($FF, $FF, $AD, $DE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00);

{ CompileCellHyperlink }
function CompileCellHyperlink(const AHyperlink: WideString;
  const AHyperlinkType: TCellHyperlinkType): AnsiString;
var
  LHyperlinkType: TCellHyperlinkType;
  LHyperlink: WideString;
  SHyperlink, S: AnsiString;
  IsRelativePath: Boolean;
  Options: Longword;
  L: Longword;
begin
  Result:= '';
  
  LHyperlinkType:= AHyperlinkType;
  LHyperlink:= WideStringLowerCase(AHyperlink);
  SHyperlink:= WideStringToANSIWideString(AHyperlink);  

  { try to find a type }
  if (LHyperlinkType = hltAuto) then
  begin
     if (Pos(WideString('!'), LHyperlink ) <> 0) then LHyperlinkType:= hltCurrentWorkbook
     else if (Pos(WideString('\\'), LHyperlink ) = 1) then LHyperlinkType:= hltUNC
     else if (Pos(WideString('http'), LHyperlink ) = 1) then LHyperlinkType:= hltURL
     else if (Pos(WideString('@'), LHyperlink ) <> 0) then LHyperlinkType:= hltURL
     else if (Pos(WideString(':'), LHyperlink ) <> 0) then LHyperlinkType:= hltFile
     else if (Pos(WideString('\'), LHyperlink ) <> 0) then LHyperlinkType:= hltFile
     else LHyperlinkType:= hltURL;
  end;        

  { path is relative if it does not contain disk char and : }
  IsRelativePath:= (LHyperlinkType = hltFile) and (Pos(':', LHyperlink ) = 0);

  { Get options }
  Options:= 0;
  if (LHyperlinkType = hltFile) then Options:= Options or 1;
  if (LHyperlinkType = hltURL) then Options:= Options or 1;  
  if (not IsRelativePath) then Options:= Options or 2;
  if (LHyperlinkType = hltUNC) then Options:= Options or $100 or 1 or 2;
  if (LHyperlinkType = hltCurrentWorkbook) then Options:= 8;

  { Common part }
  SetLength(Result, 24);
  FillChar(Result[1], 24, 0);
  Move(hlGUIDStdLink[0], Result[1], 16);
  Result[17]:= #2; // unknown value
  Move(Options, Result[21], 4);

  { Special parts }
  case LHyperlinkType of
    hltURL:
      begin
        SetLength(S, 16);
        Move(hlGUIDURLLink[0], S[1], 16);
        Result:= Result + S;
        L:= Length(SHyperlink) + 2;
        SetLength(S, 4);
        Move(L, S[1], 4);
        { length and 0-terminated 16-bit string }
        Result:= Result + S + SHyperlink + #0#0;
      end;
    hltFile:
      begin
        SetLength(S, 16);
        Move(hlGUIDFileMon[0], S[1], 16);
        Result:= Result + S;
        Result:= Result + #0#0 + #1#0#0#0 + #0;
        SetLength(S, 24);
        Move(hlMagic1[0], S[1], 24);
        Result:= Result + S;

        { size of the ending part }
        L:= 4 + 2 + Length(SHyperlink);
        SetLength(S, 4);
        Move(L, S[1], 4);
        Result:= Result + S;

        L:= Length(SHyperlink);
        SetLength(S, 4);
        Move(L, S[1], 4);
        Result:= Result + S + #3#0 + SHyperlink;

      end;
    hltUNC,
    hltCurrentWorkbook:
      begin
        L:= (Length(SHyperlink) div 2) + 1;
        SetLength(S, 4);
        Move(L, S[1], 4);
        { length and 0-terminated 16-bit string }
        Result:= Result + S + SHyperlink + #0#0;
      end;
  end;
end;

function ParseCellHyperlink(const ARawData: AnsiString;
  var AHyperlinkType: TCellHyperlinkType;
  var ARowFrom: Word;
  var ARowTo: Word;
  var AColumnFrom: Word;
  var AColumnTo: Word): WideString;
var
  S: AnsiString;
  Options, L, Offset, RawDataLength: Integer;
  IsDescription, IsTextMark, IsFrame: Boolean;
  ShortName: WideString;
  
  function ReadStringData(
    const LengthIsCharCount: Boolean;
    const ZeroTerminated: Boolean;
    const IsUnicode: Boolean;
    const SkipBytesAfterLength: Byte): WideString;
  var
    L, StringSize, DataSize: Integer;
    S: AnsiString;
    CharIndex: Integer;
    UnicodeFactor: Integer;
  begin
    Result:= '';
    if IsUnicode then UnicodeFactor:= 2 else UnicodeFactor:= 1;

     if (RawDataLength < Offset - 1 + 4) then
       raise EXLSError.Create(EXLS_INVALIDHLINK);
     Move(ARawData[Offset], L, 4);
     
     Offset:= Offset + 4 + SkipBytesAfterLength;

     if LengthIsCharCount then
       StringSize:= L * UnicodeFactor
     else
       StringSize:= L;

     DataSize:= StringSize;
       
     if (RawDataLength < (Offset - 1 + DataSize)) then
       raise EXLSError.Create(EXLS_INVALIDHLINK);

     SetLength(S, StringSize);
     if (StringSize > 1) then
       Move(ARawData[Offset], S[1], StringSize);

     if ZeroTerminated then
     begin
       for CharIndex:= 1 to (Length(S) div UnicodeFactor) do
         if (    (S[CharIndex * UnicodeFactor - (UnicodeFactor - 1)] = #0)
             and (S[CharIndex * UnicodeFactor] = #0)
            ) then
         begin
           S:= Copy(S, 1, CharIndex * UnicodeFactor - 1);
           Break;
         end;
     end;

     Offset:= Offset + DataSize;
     
     if IsUnicode then
       Result:= ANSIWideStringToWideString(S)
     else
       Result:= StringToWideString(S);  
  end;

begin
  Result:= '';
  AHyperlinkType:= hltAuto;
  RawDataLength:= Length(ARawData);

  if (RawDataLength < 32) then
    raise EXLSError.Create(EXLS_INVALIDHLINK);

  { Read common link data }
  Move(ARawData[1], ARowFrom, 2);
  Move(ARawData[3], ARowTo, 2);
  Move(ARawData[5], AColumnFrom, 2);
  Move(ARawData[7], AColumnTo, 2);
  Move(ARawData[29], Options, 4);

  IsDescription:= ((Options and $14) = $14);
  IsTextMark:= ((Options and $8) = $8);
  IsFrame:= ((Options and $80) = $80);

  if ((Options and $100) = $100) then AHyperlinkType:= hltUNC
  else if ((Options and $1) = $1) then AHyperlinkType:= hltURL
  else AHyperlinkType:= hltCurrentWorkbook;

  Offset:= 33;

  { ignore description and frame }
  if IsDescription then
    ReadStringData(True, True, True, 0);
  if IsFrame then
    ReadStringData(True, True, True, 0);

  { Read special data }  
  case AHyperlinkType of
    hltURL:
      begin
        SetLength(S, 16);
        if (RawDataLength < Offset - 1 + 16) then
          raise EXLSError.Create(EXLS_INVALIDHLINK);
        Move(ARawData[Offset], S[1], 16);

        { analyze GUIDs, because hltURL may be URL or file }
        if CompareMem(@ARawData[Offset], @hlGUIDFileMon[0], 16) then
          AHyperlinkType:= hltFile;
        if (AHyperlinkType = hltURL) then
          if not CompareMem(@ARawData[Offset], @hlGUIDURLLink[0], 16) then
            raise EXLSError.Create(EXLS_INVALIDHLINK);
        Offset:= Offset + 16;

        { read URL }
        if (AHyperlinkType = hltURL) then
          Result:= ReadStringData(False, True, True, 0)
        else
        { read file }
        if (AHyperlinkType = hltFile) then
        begin
          if (RawDataLength < Offset - 1 + 6) then
            raise EXLSError.Create(EXLS_INVALIDHLINK);
          Offset:= Offset + 2;

          { read short name }
          ShortName:= ReadStringData(True, True, False, 0);

          { ignore magic data }
          if (RawDataLength < Offset - 1 + 24) then
            raise EXLSError.Create(EXLS_INVALIDHLINK);
          Offset:= Offset + 24;

          { Read data size, if data size is 0 then exit }
          if (RawDataLength < Offset - 1 + 4) then
            raise EXLSError.Create(EXLS_INVALIDHLINK);
          Move(ARawData[Offset], L, 4);
          Offset:= Offset + 4;
          if (L = 0) then
          begin
            Result:= ShortName;
            Exit;
          end;

          { read string }
          Result:= ReadStringData(False, False, True, 2);

          { get short name if it contains more data }
          if Length(Result) < Length(ShortName) then
            Result:= ShortName;
        end;
      end;
    hltUNC:
        Result:= ReadStringData(True, True, True, 0);
    hltCurrentWorkbook:
      begin
        if IsTextMark then
          Result:= ReadStringData(True, True, True, 0);
      end;
  end;
end;

end.
