
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressDataController                                        }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSDATACONTROLLER AND ALL         }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxLike;

{$I cxVer.inc}

interface

uses
  SysUtils;

type
  TcxFilterLikeOperator = (floLike, floBeginsWith, floEndsWith, floContains);

function LikeOperatorByPattern(var APatternStr: string; APercent: Char): TcxFilterLikeOperator;
function LikeStr(const AStr, APatternStr: string; APercent, AUnderline: Char): Boolean;

implementation

procedure PreparePatternStr(var PatternStr: string; APercent: Char);
var
  I: Integer;
  S: string;
begin
  // delete '%%', because '%%' = '%'
  S := APercent + APercent;
  repeat
    I := Pos(S, PatternStr);
    if I > 0 then
      PatternStr := Copy(PatternStr, 1, I - 1) + APercent + Copy(PatternStr, I + 2, MaxInt);
  until I = 0;
end;

function LikeOperatorByPattern(var APatternStr: string; APercent: Char): TcxFilterLikeOperator;
var
  ABeginFlag, AEndFlag: Boolean;
begin
  Result := floLike;
  PreparePatternStr(APatternStr, APercent);
  if Length(APatternStr) > 1 then
  begin
    ABeginFlag := APatternStr[1] = APercent;
    AEndFlag := APatternStr[Length(APatternStr)] = APercent;
    if ABeginFlag then
    begin
      Delete(APatternStr, 1, 1);
      if AEndFlag then
      begin
        Result := floContains;
        Delete(APatternStr, Length(APatternStr), 1);
      end
      else
        Result := floEndsWith;
    end
    else
      if AEndFlag then
      begin
        Result := floBeginsWith;
        Delete(APatternStr, Length(APatternStr), 1);
      end;
  end;
end;

function Like(p1: PChar; l1: Integer; p2: PChar; l2: Integer;
  percent_char, underline_char, escape_char: Char): Boolean;
var
  c: Char;
  AEscapeFlag: Boolean;
begin
  AEscapeFlag := False;
  repeat
    Dec(l2);
    if l2 < 0 then Break;
    c := p2^;
    p2 := p2 + 1;
    if (escape_char <> #0) and not AEscapeFlag and (c = escape_char) then
    begin
      AEscapeFlag := True;
      Continue;
    end;
    if not AEscapeFlag and (c = percent_char) then
    begin
      if l2 = 0 then
      begin
        Result := True;
        Exit;
      end;
      while l1 > 0 do
      begin
        if Like(p1, l1, p2, l2, percent_char, underline_char, escape_char) then
        begin
          Result := True;
          Exit;
        end;
        p1 := p1 + 1;
        Dec(l1);
      end;
      Result := False;
      Exit;
    end;
    Dec(l1);
    if l1 < 0 then
    begin
      Result := False;
      Exit;
    end;
    if (AEscapeFlag or (c <> underline_char)) and (c <> p1^) then
    begin
      Result := False;
      Exit;
    end;
    AEscapeFlag := False;
    p1 := p1 + 1;
  until False;
  Result := l1 = 0;
end;

function LikeStr(const AStr, APatternStr: string; APercent, AUnderline: Char): Boolean;
begin
  Result := Like(PChar(AStr), Length(AStr), PChar(APatternStr),
    Length(APatternStr), APercent, AUnderline, #0);
end;

end.
