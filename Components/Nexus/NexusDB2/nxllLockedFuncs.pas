{##############################################################################}
{# NexusDB: nxllLockedFuncs.pas 2.00                                          #}
{# NexusDB Memory Manager: nxllLockedFuncs.pas 2.03                           #}
{# Portions Copyright (c) Thorsten Engler 2001-2002                           #}
{# Portions Copyright (c) Real Business Software Pty. Ltd. 2002-2003          #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Atomic Integer and Single-linked List functions                   #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllLockedFuncs;

interface

uses
  nxllTypes;

{- Locked Integer manipulation -}
function LockedAdd(var Target: Integer; Value: Integer): Integer; register; overload;
function LockedCompareExchange(var Target: Integer; Exch, Comp: Integer): Integer; register; overload;
function LockedDec(var Target: Integer): Integer; register; overload;
function LockedExchange(var Target: Integer; Value: Integer): Integer; register; overload;
function LockedExchangeAdd(var Target: Integer; Value: Integer): Integer; register; overload;
function LockedExchangeDec(var Target: Integer): Integer; register; overload;
function LockedExchangeInc(var Target: Integer): Integer; register; overload;
function LockedExchangeSub(var Target: Integer; Value: Integer): Integer; register; overload;
function LockedInc(var Target: Integer): Integer; register; overload;
function LockedSub(var Target: Integer; Value: Integer): Integer; register; overload;

{- Locked Cardinal manipulation -}
function LockedAdd(var Target: Cardinal; Value: Cardinal): Cardinal; register; overload;
function LockedCompareExchange(var Target: Cardinal; Exch, Comp: Cardinal): Cardinal; register; overload;
function LockedDec(var Target: Cardinal): Cardinal; register; overload;
function LockedExchange(var Target: Cardinal; Value: Cardinal): Cardinal; register; overload;
function LockedExchangeAdd(var Target: Cardinal; Value: Cardinal): Cardinal; register; overload;
function LockedExchangeDec(var Target: Cardinal): Cardinal; register; overload;
function LockedExchangeInc(var Target: Cardinal): Cardinal; register; overload;
function LockedExchangeSub(var Target: Cardinal; Value: Cardinal): Cardinal; register; overload;
function LockedInc(var Target: Cardinal): Cardinal; register; overload;
function LockedSub(var Target: Cardinal; Value: Cardinal): Cardinal; register; overload;

{- Locked Pointer manipulation -}
function LockedAdd(var Target: Pointer; Value: Integer): Pointer; register; overload;
function LockedAdd(var Target: Pointer; Value: Cardinal): Pointer; register; overload;
function LockedCompareExchange(var Target: Pointer; Exch, Comp: Pointer): Pointer; register; overload;
function LockedDec(var Target: Pointer): Pointer; register; overload;
function LockedExchange(var Target: Pointer; Value: Pointer): Pointer; register; overload;
function LockedExchangeAdd(var Target: Pointer; Value: Integer): Pointer; register; overload;
function LockedExchangeAdd(var Target: Pointer; Value: Cardinal): Pointer; register; overload;
function LockedExchangeDec(var Target: Pointer): Pointer; register; overload;
function LockedExchangeInc(var Target: Pointer): Pointer; register; overload;
function LockedExchangeSub(var Target: Pointer; Value: Integer): Pointer; register; overload;
function LockedExchangeSub(var Target: Pointer; Value: Cardinal): Pointer; register; overload;
function LockedInc(var Target: Pointer): Pointer; register; overload;
function LockedSub(var Target: Pointer; Value: Integer): Pointer; register; overload;
function LockedSub(var Target: Pointer; Value: Cardinal): Pointer; register; overload;

{- Locked Single-linked Lists -}
type
  PnxListEntry = ^TnxListEntry;
  TnxListEntry = packed record
    leNext     : PnxListEntry;
  end;

  PnxListHead = ^TnxListHead;
  TnxListHead = packed record
    lhFirst    : PnxListEntry;
    lhSequence : TnxWord32;
  end;

  PnxStackEntry = ^TnxStackEntry;
  TnxStackEntry = packed record
    seListEntry : TnxListEntry;
    seData      : Pointer;
  end;

procedure InitSListHead(aListHead: PnxListHead); register;
function LockedPopEntrySList(aListHead: PnxListHead): PnxListEntry; register;
function LockedPushEntrySList(aListHead: PnxListHead; aListEntry: PnxListEntry): PnxListEntry; register;
function LockedPushEntriesSList(aListHead: PnxListHead; aFirstListEntry: PnxListEntry; aLastListEntry: PnxListEntry): PnxListEntry; register;
function LockedFlushSList(aListHead: PnxListHead): PnxListEntry; register;

implementation

{===Locked Integer manipulation================================================}
function LockedAdd(var Target: Integer; Value: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{------------------------------------------------------------------------------}
function LockedCompareExchange(var Target: Integer; Exch, Comp: Integer): Integer; register; overload;
asm
        xchg    eax, ecx
   lock cmpxchg [ecx], edx
end;
{------------------------------------------------------------------------------}
function LockedDec(var Target: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
        dec     eax
end;
{------------------------------------------------------------------------------}
function LockedExchange(var Target: Integer; Value: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xchg    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeAdd(var Target: Integer; Value: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeDec(var Target: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeInc(var Target: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeSub(var Target: Integer; Value: Integer): Integer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedInc(var Target: Integer): Integer; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
        inc     eax
end;
{------------------------------------------------------------------------------}
function LockedSub(var Target: Integer; Value: Integer): Integer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{==============================================================================}



{===Locked Cardinal manipulation================================================}
function LockedAdd(var Target: Cardinal; Value: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{------------------------------------------------------------------------------}
function LockedCompareExchange(var Target: Cardinal; Exch, Comp: Cardinal): Cardinal; register; overload;
asm
        xchg    eax, ecx
   lock cmpxchg [ecx], edx
end;
{------------------------------------------------------------------------------}
function LockedDec(var Target: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
        dec     eax
end;
{------------------------------------------------------------------------------}
function LockedExchange(var Target: Cardinal; Value: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xchg    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeAdd(var Target: Cardinal; Value: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeDec(var Target: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeInc(var Target: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeSub(var Target: Cardinal; Value: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedInc(var Target: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
        inc     eax
end;
{------------------------------------------------------------------------------}
function LockedSub(var Target: Cardinal; Value: Cardinal): Cardinal; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{==============================================================================}



{===Locked Pointer manipulation================================================}
function LockedAdd(var Target: Pointer; Value: Integer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{------------------------------------------------------------------------------}
function LockedAdd(var Target: Pointer; Value: Cardinal): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{------------------------------------------------------------------------------}
function LockedCompareExchange(var Target: Pointer; Exch, Comp: Pointer): Pointer; register; overload;
asm
        xchg    eax, ecx
   lock cmpxchg [ecx], edx
end;
{------------------------------------------------------------------------------}
function LockedDec(var Target: Pointer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
        dec     eax
end;
{------------------------------------------------------------------------------}
function LockedExchange(var Target: Pointer; Value: Pointer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xchg    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeAdd(var Target: Pointer; Value: Integer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeAdd(var Target: Pointer; Value: Cardinal): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeDec(var Target: Pointer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, -1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeInc(var Target: Pointer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeSub(var Target: Pointer; Value: Integer): Pointer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedExchangeSub(var Target: Pointer; Value: Cardinal): Pointer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
end;
{------------------------------------------------------------------------------}
function LockedInc(var Target: Pointer): Pointer; register;
asm
        mov     ecx, eax
        mov     eax, 1
   lock xadd    [ecx], eax
        inc     eax
end;
{------------------------------------------------------------------------------}
function LockedSub(var Target: Pointer; Value: Integer): Pointer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{------------------------------------------------------------------------------}
function LockedSub(var Target: Pointer; Value: Cardinal): Pointer; register;
asm
        mov     ecx, eax
        neg     edx
        mov     eax, edx
   lock xadd    [ecx], eax
        add     eax, edx
end;
{==============================================================================}



{===Locked Single-linked Lists=================================================}
procedure InitSListHead(aListHead: PnxListHead); register;
asm
        and       dword ptr [eax + TnxListHead.lhFirst    ], 0
        and       dword ptr [eax + TnxListHead.lhSequence ], 0
end;
{------------------------------------------------------------------------------}
function LockedPopEntrySList(aListHead: PnxListHead): PnxListEntry; register;
asm
        push      ebx
        push      ebp

        mov       ebp, eax
        mov       edx, [ebp + TnxListHead.lhSequence]
        mov       eax, [ebp + TnxListHead.lhFirst]
  @@loop:
        or        eax, eax
        jz       @@exit
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [ebp]
   {$ELSE}
        db        0F0H,00FH,0C7H,04DH,000H
   {$ENDIF}
        jnz       @@loop
  @@exit:

        pop       ebp
        pop       ebx
end;
{------------------------------------------------------------------------------}
function LockedPushEntrySList(aListHead: PnxListHead; aListEntry: PnxListEntry): PnxListEntry; register;
asm
        push      ebx
        push      ebp

        mov       ebp, eax
        mov       ebx, edx
        mov       edx, [ebp + TnxListHead.lhSequence]
        mov       eax, [ebp + TnxListHead.lhFirst]
  @@loop:
        mov       [ebx], eax
        lea       ecx, [edx+1]
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [ebp]
   {$ELSE}
        db        0F0H,00FH,0C7H,04DH,000H
   {$ENDIF}
        jnz       @@loop

        pop       ebp
        pop       ebx
end;
{------------------------------------------------------------------------------}
function LockedPushEntriesSList(aListHead: PnxListHead; aFirstListEntry: PnxListEntry; aLastListEntry: PnxListEntry): PnxListEntry; register;
asm
        push      ebx
        push      ebp
        push      esi

        mov       ebp, eax
        mov       ebx, edx
        mov       esi, ecx
        mov       edx, [ebp + TnxListHead.lhSequence]
        mov       eax, [ebp + TnxListHead.lhFirst]
  @@loop:
        mov       [esi], eax
        lea       ecx, [edx+1]
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [ebp]
   {$ELSE}
        db        0F0H,00FH,0C7H,04DH,000H
   {$ENDIF}
        jnz       @@loop

        pop       esi
        pop       ebp
        pop       ebx
end;
{------------------------------------------------------------------------------}
function LockedFlushSList(aListHead: PnxListHead): PnxListEntry; register;
asm
        push      ebx
        push      ebp

        xor       ebx, ebx
        mov       ebp, eax
        mov       edx, [ebp + TnxListHead.lhSequence]
        mov       eax, [ebp + TnxListHead.lhFirst]
  @@loop:
        or        eax, eax
        jz       @@exit
        mov       ecx, edx
        mov       cx, bx
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [ebp]
   {$ELSE}
        db        0F0H,00FH,0C7H,04DH,000H
   {$ENDIF}
        jnz       @@loop
  @@exit:

        pop       ebp
        pop       ebx
end;
{==============================================================================}

end.
