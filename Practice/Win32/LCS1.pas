unit LCS1;

interface


  {-----------------------------------------------------------------------------
    LCS
  -----------------------------------------------------------------------------}
  function  FindLCS(const aFirst: string; const aSecond: string;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;

  function  LongestCommonSubstring(const aS1: string; const aS2: string): string;


implementation

uses
  SysUtils,
  LogUtil,
  DebugTimer;

const
  UnitName = 'LCS1';
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

  // Data BEFORE the Details?
  iPos1 := Pos(aDetails, aFirst);
  iPos2 := Pos(aDetails, aSecond);
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
  Based on LCS Java algorithm from WikiBooks

  http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_substring
-------------------------------------------------------------------------------}
function LongestCommonSubstring(const aS1: string; const aS2: string): string;
const
  MIN_LENGTH = 3;
var
  iStart: integer;
  iMax: integer;
  i: integer;
  j: integer;
  iCount: integer;
begin
  if DebugMe then
    CreateDebugTimer('LongestCommonSubstring');

  iStart := 1;
  iMax := 0;

  for i := 1 to Length(aS1) do
  begin
    for j := 1 to Length(aS2) do
    begin
      iCount := 0;
      while (aS1[i + iCount] = aS2[j + iCount]) do
      begin
        Inc(iCount);
        if ((i + iCount) > Length(aS1)) or ((j + iCount) > Length(aS2)) then
          break;
      end;

      if (iCount > iMax) then
      begin
        iStart := i;
        iMax := iCount;
      end;
    end;
  end;

  result := Copy(aS1, iStart, iMax);
  result := Trim(result);
  if (Length(result) < MIN_LENGTH) then
    result := '';

{$IFDEF DEBUG_LCS}
  ASSERT(result = LongestCommonSubstringOld(aS1, aS2), aS1 + ', ' + aS2 + ' = ' + result + ' <> ' + LongestCommonSubstringOld(aS1, aS2));
{$ENDIF}
end;


{-------------------------------------------------------------------------------
  Initialization
-------------------------------------------------------------------------------}
initialization
begin
  DebugMe := DebugUnit(UnitName);
end;


end.
