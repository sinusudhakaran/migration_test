{##############################################################################}
{# NexusDB: nxReplacementMemoryManager.pas 2.00                               #}
{# NexusDB Memory Manager: nxReplacementMemoryManager.pas 2.03                #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Replacement for Borland Memory Management                         #}
{##############################################################################}

{$I nxDefine.inc}

unit nxReplacementMemoryManager;

interface

uses
  nxllMemoryManager;

var
  OrgMemoryManager : TMemoryManager;

implementation

initialization
  if GetHeapStatus.TotalAllocated <> 0 then
    {$IFNDEF DCC6OrLater}
    RunError(2 {reInvalidPtr});
    {$ELSE}
    Error(reInvalidPtr);
    {$ENDIF}

  GetMemoryManager(OrgMemoryManager);
  SetMemoryManager(_nxMemoryManager);
finalization
end.
