{*********************************************************}
{*                    OVCUTILS.PAS 4.05                  *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

unit OvcUtils;
  { Miscellaneous Utilities }

interface

procedure StripCharSeq(CharSeq: string; var Str: string);
procedure StripCharFromEnd(Chr: Char; var Str: string);
procedure StripCharFromFront(Chr: Char; var Str: string);

implementation
{ Strips specified character(s) from the string and returns the modified string}
procedure StripCharSeq(CharSeq: string; var Str: string);
begin
  while Pos(CharSeq, Str) > 0 do
    Delete(Str, Pos(CharSeq, Str), Length(CharSeq));
end;

{ Strips the specified character from the end of the string }
procedure StripCharFromEnd(Chr: Char; var Str: string);
begin
  while Str[Length(Str)] = Chr do Delete(Str, Length(Str), 1);
end;

{ Strips the specified character from the beginning of the string }
procedure StripCharFromFront(Chr: Char; var Str: string);
begin
  while Str[1] = Chr do Delete(Str, 1, 1);
end;


end.
