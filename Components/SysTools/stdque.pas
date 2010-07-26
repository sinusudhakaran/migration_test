{*********************************************************}
{* SysTools: StDQue.pas 3.03                             *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: DEQue class                                 *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF WIN16}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
{$ENDIF}

{Notes:
   This class is derived from TStList and allows all of
   the inherited list methods to be used.

   The "head" of the queue is element 0 in the list. The "tail" of the
   queue is the last element in the list.

   The dequeue can be used as a LIFO stack by calling PushTail and
   PopTail, or as a FIFO queue by calling PushTail and PopHead.
}

unit StDQue;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  {$IFDEF WIN16}
  WinTypes, WinProcs,
  {$ENDIF}
  STConst, StBase, StList;

type
  TStDQue = class(TStList)
    public
      procedure PushTail(Data : Pointer);
        {-Add element at tail of queue}
      procedure PopTail;
        {-Delete element at tail of queue, destroys its data}
      procedure PeekTail(var Data : Pointer);
        {-Return data at tail of queue}

      procedure PushHead(Data : Pointer);
        {-Add element at head of queue}
      procedure PopHead;
        {-Delete element at head of queue, destroys its data}
      procedure PeekHead(var Data : Pointer);
        {-Return data at head of queue}
  end;

{======================================================================}

implementation



procedure TStDQue.PeekHead(var Data : Pointer);
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count = 0 then
      Data := nil
    else
      Data := Head.Data;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TStDQue.PeekTail(var Data : Pointer);
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count = 0 then
      Data := nil
    else
      Data := Tail.Data;
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TStDQue.PopHead;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count > 0 then
      Delete(Head);
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TStDQue.PopTail;
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    if Count > 0 then
      Delete(Tail);
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TStDQue.PushHead(Data : Pointer);
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    Insert(Data);
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;

procedure TStDQue.PushTail(Data : Pointer);
begin
{$IFDEF ThreadSafe}
  EnterCS;
  try
{$ENDIF}
    Append(Data);
{$IFDEF ThreadSafe}
  finally
    LeaveCS;
  end;
{$ENDIF}
end;


end.