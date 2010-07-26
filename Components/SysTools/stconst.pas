{*********************************************************}
{* SysTools: StConst.pas 3.03                            *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Base unit for SysTools                      *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF MSWINDOWS}
  {$R StConst.r32}
{$ENDIF}
{$IFDEF WIN16}
  {$R StConst.r16}
{$ENDIF}

unit StConst;
  {-Resource constants for SysTools}

interface

uses
  SysUtils, StSrMgr;

{$I StConst.inc}

const
  StVersionStr = '3.03';

var
  SysToolStr : TStStringResource;

implementation


procedure FreeSysToolStr; far;
begin
  SysToolStr.Free;
end;


initialization
  SysToolStr := TStStringResource.Create(HInstance, 'SYSTOOLS_STRINGS_ENGLISH');

{$IFDEF MSWINDOWS}
finalization
  FreeSysToolStr;
{$ENDIF}
{$IFDEF WIN16}
  AddExitProc(FreeSysToolStr);
{$ENDIF}
end.
