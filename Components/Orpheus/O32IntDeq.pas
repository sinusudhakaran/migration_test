{*********************************************************}
{*                  O32INTDEQ.PAS 4.05                   *}
{*        Copyright (c) 2001 TurboPower Software Co      *}
{*                 All rights reserved.                  *}
{*********************************************************}

{The following is a modified version of deque code, which was originally written
 for Algorithms Alfresco. It is copyright(c)2001 by Julian M. Bucknall and is
 used here with permission.}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit o32intdeq;
  {A simple deque class for Orpheus}

interface

uses
  Classes;

type
  TO32IntDeque = class
    protected {private}
      FList : TList;
      FHead : integer;
      FTail : integer;
      procedure idGrow;
    public
      constructor Create(aCapacity : integer);
      destructor Destroy; override;
      function IsEmpty : boolean;
      procedure Enqueue(aValue: integer);
      procedure Push(aValue: integer);
      function  Pop: integer;
  end;

implementation

uses
  SysUtils;

{=== TO32IntDeque ====================================================}
constructor TO32IntDeque.Create(aCapacity : integer);
begin
  inherited Create;
  FList := TList.Create;
  FList.Count := aCapacity;
  {let's help out the user of the deque by putting the head and tail
   pointers in the middle: it's probably more efficient}
  FHead := aCapacity div 2;
  FTail := FHead;
end;
{--------}
destructor TO32IntDeque.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;
{--------}
procedure TO32IntDeque.Enqueue(aValue : integer);
begin
  FList.List^[FTail] := pointer(aValue);
  inc(FTail);
  if (FTail = FList.Count) then
    FTail := 0;
  if (FTail = FHead) then
    idGrow;
end;
{--------}
procedure TO32IntDeque.idGrow;
var
  OldCount : integer;
  i, j     : integer;
begin
  {grow the list by 50%}
  OldCount := FList.Count;
  FList.Count := (OldCount * 3) div 2;
  {expand the data into the increased space, maintaining the deque}
  if (FHead = 0) then
    FTail := OldCount
  else begin
    j := FList.Count;
    for i := pred(OldCount) downto FHead do begin
      dec(j);
      FList.List^[j] := FList.List^[i]
    end;
    FHead := j;
  end;
end;
{--------}
function TO32IntDeque.IsEmpty : boolean;
begin
  Result := FHead = FTail;
end;
{--------}
procedure TO32IntDeque.Push(aValue : integer);
begin
  if (FHead = 0) then
    FHead := FList.Count;
  dec(FHead);
  FList.List^[FHead] := pointer(aValue);
  if (FTail = FHead) then
    idGrow;
end;
{--------}
function TO32IntDeque.Pop : integer;
begin
  if FHead = FTail then
    raise Exception.Create('Integer deque is empty: cannot pop');
  Result := integer(FList.List^[FHead]);
  inc(FHead);
  if (FHead = FList.Count) then
    FHead := 0;
end;
{=== TO32IntDeque - end ==============================================}

end.
