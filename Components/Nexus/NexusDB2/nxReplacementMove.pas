{##############################################################################}
{# NexusDB: nxReplacementMove.pas 2.00                                        #}
{# NexusDB Memory Manager: nxReplacementMove.pas 2.03                         #}
{##############################################################################}
{# NexusDB: replaces the default System.Move implementation                   #}
{##############################################################################}

{$I nxDefine.inc}

unit nxReplacementMove;
(*
FastMove by John O'Harrow (john@elmcrest.demon.co.uk)

Version: 1.20 - 30-MAY-2004
*)

interface

implementation

{$IFDEF DCC6OrLater}
uses
  nxllFastMove,
  Windows;

procedure ReplaceMove;
type {Jump Positions in Move Prodedures - Really Horrible but Works}
  NewMoveType = packed record {Size = 58 Bytes, System.Move = 64 Bytes}
    Padding1  : array[1..15] of Byte;
    Jump1Dest : Integer; {jmp SmallForwardMove}
    Padding2  : array[1.. 5] of Byte;
    Jump2Dest : Integer; {jmp SmallBackwardMove}
    Padding3  : array[1.. 6] of Byte;
    Jump3Dest : Integer; {jg  Forwards_XXX}
    Padding4  : array[1..10] of Byte;
    Jump4Dest : Integer; {jg  Backwards_XXX}
    Padding5  : array[1.. 1] of Byte;
    Jump5Dest : Integer; {jmp Forwards_XXX}
    Padding6  : array[1.. 1] of Byte;
  end;
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;
var
  I, Offset : Integer;
  SrcProc   : Pointer;
  Src, Dest : PByteArray;
  NewMove   : NewMoveType;
  OldProtect,
  Protect   : DWORD;
begin
  SrcProc := @nxMove;

  VirtualProtect(@System.Move, 256, PAGE_READWRITE, @OldProtect);
  if PWord(@System.Move)^ = $25FF then
    begin {System.Move Starts JMP DWORD PTR [XXXXXXX](Using Packages)}
      PByte(@System.Move)^:=$E9;
      PInteger(Integer(@System.Move)+1)^ :=
        Integer(SrcProc) - Integer(@System.Move)-5; {Change Destination}
    end
  else
    begin {Patch system.move}
      Move(SrcProc^, NewMove, SizeOf(NewMove));
      {Adjust Jump Destinations in Copied Procedure}
      Offset := Integer(SrcProc) - Integer(@System.Move);
      Inc(NewMove.Jump1Dest, Offset);
      Inc(NewMove.Jump2Dest, Offset);
      Inc(NewMove.Jump3Dest, Offset);
      Inc(NewMove.Jump4Dest, Offset);
      Inc(NewMove.Jump5Dest, Offset);
      Src  := @NewMove;
      Dest := @System.Move;
      for I := 0 to SizeOf(NewMove) - 1 do
        Dest[I] := Src[I]; {Overwrite System.Move}
    end;
  VirtualProtect(@System.Move, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, @System.Move, SizeOf(NewMove));
end;

initialization
  ReplaceMove;
{$ENDIF}
end.

