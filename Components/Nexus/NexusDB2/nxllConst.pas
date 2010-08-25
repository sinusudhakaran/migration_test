{##############################################################################}
{# NexusDB: nxllConst.pas 2.00                                                #}
{# NexusDB Memory Manager: nxllConst.pas 2.03                                 #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Stringtable constants                                             #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllConst;

interface

uses
  nxllTypes;

const
  nxVersionNumber : Integer = 20000; {2.00.00}
  nxTableFormatVersionNumber : Integer = 20000; {2.00.00}
  {$IFDEF Delphi5}  nxSpecialString : string = 'Alpha (D5)'{$IFDEF NX_EMBEDDEDSERVER_ONLY}+' (Embedded)'{$ENDIF}{$IFDEF NX_TRIAL}+' (Trial)'{$ENDIF}{$IFDEF NX_LITE}+' (Lite)'{$ENDIF};{$ENDIF}
  {$IFDEF Delphi6}  nxSpecialString : string = 'Alpha (D6)'{$IFDEF NX_EMBEDDEDSERVER_ONLY}+' (Embedded)'{$ENDIF}{$IFDEF NX_TRIAL}+' (Trial)'{$ENDIF}{$IFDEF NX_LITE}+' (Lite)'{$ENDIF};{$ENDIF}
  {$IFDEF Delphi7}  nxSpecialString : string = 'Alpha (D7)'{$IFDEF NX_EMBEDDEDSERVER_ONLY}+' (Embedded)'{$ENDIF}{$IFDEF NX_TRIAL}+' (Trial)'{$ENDIF}{$IFDEF NX_LITE}+' (Lite)'{$ENDIF};{$ENDIF}
  {$IFDEF CBuilder5}nxSpecialString : string = 'Alpha (C5)'{$IFDEF NX_EMBEDDEDSERVER_ONLY}+' (Embedded)'{$ENDIF}{$IFDEF NX_TRIAL}+' (Trial)'{$ENDIF}{$IFDEF NX_LITE}+' (Lite)'{$ENDIF};{$ENDIF}
  {$IFDEF CBuilder6}nxSpecialString : string = 'Alpha (C6)'{$IFDEF NX_EMBEDDEDSERVER_ONLY}+' (Embedded)'{$ENDIF}{$IFDEF NX_TRIAL}+' (Trial)'{$ENDIF}{$IFDEF NX_LITE}+' (Lite)'{$ENDIF};{$ENDIF}

  nxVersion10000 : Integer = 10000; {1.00.00}
  nxVersion10100 : Integer = 10100; {1.01.00}
  nxVersion10200 : Integer = 10200; {1.02.00}
  nxVersion10300 : Integer = 10300; {1.03.00}
  nxVersion10301 : Integer = 10301; {1.03.01}
  nxVersion20000 : Integer = 20000; {2.00.00}

  nxcl_1KB = 1024;                   {One kilobyte. }
  nxcl_1MB = 1024 * 1024;            {One megabyte. }

  nxcCRLF = #13#10;

  nxccREG_PRODUCT = '\Software\Nexus\NexusDB\2.0';

  { default timeout for all nexus comps }
  nxDefaultTimeOut = 10 * 1000; { 10 Seconds }

  nxInt64Null : TnxInt64 = 0;

  {$IFDEF Delphi5}  nxPackageVerion : string = '50';{$ENDIF}
  {$IFDEF Delphi6}  nxPackageVerion : string = '60';{$ENDIF}
  {$IFDEF Delphi7}  nxPackageVerion : string = '70';{$ENDIF}
  {$IFDEF CBuilder5}nxPackageVerion : string = '51';{$ENDIF}
  {$IFDEF CBuilder6}nxPackageVerion : string = '61';{$ENDIF}

  nxVersionString = '200';

implementation

end.

