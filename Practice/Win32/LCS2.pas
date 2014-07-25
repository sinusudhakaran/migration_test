unit LCS2;

interface

uses
  Classes;

  {-----------------------------------------------------------------------------
    FindLCS
  -----------------------------------------------------------------------------}
  function  FindLCS(const aFirst: string; const aSecond: string;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;


  {-----------------------------------------------------------------------------
    LongestCommonSubstring (in words)
  -----------------------------------------------------------------------------}
  function  LongestCommonSubstring(const aS1: string; const aS2: string
              ): string;


type
  {-----------------------------------------------------------------------------
    TToken
  -----------------------------------------------------------------------------}
  PToken = ^TToken;
  TToken = record
    Text: string;
    Delimiter: string;
  end;


  {-----------------------------------------------------------------------------
    TTokens
  -----------------------------------------------------------------------------}
  TTokens = class(TObject)
  private
    fTokens: array of TToken;

  public
    function  GetCount: integer;
    property  Count: integer read GetCount;

    function  GetToken(const aIndex: integer): PToken;
    property  Tokens[const aIndex: integer]: PToken read GetToken; default;

    procedure Parse(const aValue: string);

    function  StringLength(const aStart: integer; const aCount: integer
                ): integer;

    function  Copy(const aStart: integer; const aCount: integer): string;

    class function  Compare(
                      const aTokens1: TTokens;
                      const aStart1: integer;
                      const aTokens2: TTokens;
                      const aStart2: integer;
                      const aCount: integer
                      ): boolean;

  private
    function  IsAlpha(const aValue: char): boolean;
    function  IsDelimiter(const aValue: char): boolean;
    function  IsNumeric(const aValue: char): boolean;

    function  EatAlpha(var aIndex: integer; const aValue: string): string;
    function  EatDelimiter(var aIndex: integer; const aValue: string): string;
    function  EatNumeric(var aIndex: integer; const aValue: string): string;
  end;


implementation

uses
  SysUtils,
  LogUtil,
  DebugTimer;

const
  UnitName = 'LCS2';
var
  DebugMe: boolean;

{-------------------------------------------------------------------------------
  FindLCS
-------------------------------------------------------------------------------}
function FindLCS(const aFirst: string; const aSecond: string;
  var aStartData: boolean; var aDetails: string; var aEndData: boolean
  ): boolean;
var
  iPos1: integer;
  iPos2: integer;
  iLastPos1: integer;
  iLastPos2: integer;
  iLength1: integer;
  iLength2: integer;
begin
  if DebugMe then
    CreateDebugTimer('FindLCS');

  // Longest match
  aDetails := LongestCommonSubstring(aFirst, aSecond);
  if (aDetails = '') then
  begin
    result := false;
    exit;
  end;

  // Spacing broke actual LCS comparison?
  iPos1 := Pos(aDetails, aFirst);
  iPos2 := Pos(aDetails, aSecond);
  if (iPos1 = 0) or (iPos2 = 0) then
  begin
    result := false;
    exit;
  end;

  // Data BEFORE the Details?
  aStartData := (iPos1 > 1) or (iPos2 > 1);

  // Data AFTER the Details?
  iLastPos1 := iPos1 + Length(aDetails) - 1;
  iLastPos2 := iPos2 + Length(aDetails) - 1;
  iLength1 := Length(aFirst);
  iLength2 := Length(aSecond);
  aEndData := (iLastPos1 < iLength1) or (iLastPos2 < iLength2);

  result := true;
end;


{-------------------------------------------------------------------------------
  LongestCommonSubstring
-------------------------------------------------------------------------------}
function LongestCommonSubstring(const aS1: string; const aS2: string): string;
const
  MIN_LENGTH = 3;
var
  Tokens1: TTokens;
  Tokens2: TTokens;

  iStart: integer;
  iMaxCount: integer;
  iMaxLength: integer;

  i: integer;
  j: integer;
  iCount: integer;
  iLength: integer;
begin
  if DebugMe then
    CreateDebugTimer('LongestCommonSubstring');

  result := '';

  // Setup tokens
  Tokens1 := TTokens.Create;
  Tokens2 := TTokens.Create;
  try
    // Break up text
    Tokens1.Parse(aS1);
    Tokens2.Parse(aS2);

    iStart := -1;
    iMaxCount := 0;
    iMaxLength := 0;

    for i := 0 to Tokens1.Count-1 do
    begin
      for j := 0 to Tokens2.Count-1 do
      begin
        iCount := 0;

        while TTokens.Compare(Tokens1, i, Tokens2, j, iCount+1) do
        begin
          Inc(iCount);

          // Reached the end?
          if ((i + iCount) = Tokens1.Count) or ((j + iCount) = Tokens2.Count) then
            break;
        end;

        // New longest?
        iLength := Tokens1.StringLength(i, iCount);
        if (iLength > iMaxLength) then
        begin
          iStart := i;
          iMaxCount := iCount;
          iMaxLength := iLength;
        end;
      end;
    end;

    // Minimum length check
    if (iStart <> -1) then
    begin
      result := Tokens1.Copy(iStart, iMaxCount);
      result := Trim(result);
      if (Length(result) < MIN_LENGTH) then
        result := '';
    end;
  finally
    FreeAndNil(Tokens1);
    FreeAndNil(Tokens2);
  end;
end;


{-------------------------------------------------------------------------------
  TTokens
-------------------------------------------------------------------------------}
function TTokens.GetCount: integer;
begin
  result := Length(fTokens);
end;

//------------------------------------------------------------------------------
function TTokens.GetToken(const aIndex: integer): PToken;
begin
  ASSERT(aIndex < Count);

  result := @fTokens[aIndex];
end;

//------------------------------------------------------------------------------
procedure TTokens.Parse(const aValue: string);
var
  iIndex: integer;
  ch: char;
  sWord: string;
  sDelimiter: string;
begin
  SetLength(fTokens, 0);

  iIndex := 1;
  while (iIndex <= Length(aValue)) do
  begin
    sWord := '';

    ch := aValue[iIndex];

    if IsAlpha(ch) then
    begin
      sWord := EatAlpha(iIndex, aValue);
      sDelimiter := EatDelimiter(iIndex, aValue);
    end
    else if IsNumeric(ch) then
    begin
      sWord := EatNumeric(iIndex, aValue);
      sDelimiter := EatDelimiter(iIndex, aValue);
    end
    else if IsDelimiter(ch) then
      Inc(iIndex)
    else
      ASSERT(false);

    // Add?
    if (sWord <> '') then
    begin
      SetLength(fTokens, Count+1);
      with fTokens[Count-1] do
      begin
        Text := sWord;
        Delimiter := sDelimiter;
      end;
    end;

    sDelimiter := '';
  end;
end;

//------------------------------------------------------------------------------
function TTokens.StringLength(const aStart: integer; const aCount: integer
  ): integer;
var
  i: integer;
  Token: PToken;
begin
  result := 0;

  for i := 0 to aCount-1 do
  begin
    Token := Tokens[aStart + i];

    result := result + Length(Token.Text);

    if (i <> aCount-1) then
      result := result + Length(Token.Delimiter);
  end;
end;

//------------------------------------------------------------------------------
function TTokens.Copy(const aStart: integer; const aCount: integer): string;
var
  i: integer;
  Token: PToken;
begin
  result := '';

  for i := 0 to aCount-1 do
  begin
    Token := Tokens[aStart + i];

    result := result + Token.Text;

    if (i <> aCount-1) then
      result := result + Token.Delimiter;
  end;
end;

//------------------------------------------------------------------------------
class function TTokens.Compare(const aTokens1: TTokens; const aStart1: integer;
  const aTokens2: TTokens; const aStart2: integer; const aCount: integer
  ): boolean;
var
  i: integer;
  Token1: PToken;
  Token2: PToken;
begin
  for i := 0 to aCount-1 do
  begin
    Token1 := aTokens1[aStart1 + i];
    Token2 := aTokens2[aStart2 + i];

    // Check token
    if (Token1.Text <> Token2.Text) then
    begin
      result := false;
      exit;
    end;

    // Check delimiter also?
    if (i <> aCount-1) then
    begin
      // Must check delimiter also
      if (Token1.Delimiter <> Token2.Delimiter) then
      begin
        result := false;
        exit;
      end;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TTokens.IsAlpha(const aValue: char): boolean;
begin
  result := not (IsDelimiter(aValue) or IsNumeric(aValue));
end;

//------------------------------------------------------------------------------
function TTokens.IsDelimiter(const aValue: char): boolean;
begin
  result := (aValue = ' ') or (aValue = '-');
end;

//------------------------------------------------------------------------------
function TTokens.IsNumeric(const aValue: char): boolean;
begin
  result := (('0' <= aValue) and (aValue <= '9'));
end;

//------------------------------------------------------------------------------
function TTokens.EatAlpha(var aIndex: integer; const aValue: string): string;
var
  ch: char;
begin
  result := '';

  while (aIndex <= Length(aValue)) do
  begin
    ch := aValue[aIndex];

    if IsAlpha(ch) then
      result := result + ch
    else
      break;

    Inc(aIndex);
  end;
end;

//------------------------------------------------------------------------------
function TTokens.EatDelimiter(var aIndex: integer; const aValue: string
  ): string;
var
  ch: char;
begin
  result := '';

  while (aIndex <= Length(aValue)) do
  begin
    ch := aValue[aIndex];

    if IsDelimiter(ch) then
      result := result + ch
    else
      break;

    Inc(aIndex);
  end;
end;

//------------------------------------------------------------------------------
function TTokens.EatNumeric(var aIndex: integer; const aValue: string): string;
var
  ch: char;
begin
  result := '';

  while (aIndex <= Length(aValue)) do
  begin
    ch := aValue[aIndex];

    if IsNumeric(ch) then
      result := result + ch
    else
      break;

    Inc(aIndex);
  end;
end;


{-------------------------------------------------------------------------------
  Initialization
-------------------------------------------------------------------------------}
initialization
begin
  DebugMe := DebugUnit(UnitName);
end;


end.
