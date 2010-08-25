{*********************************************************}
{* SysTools: StRegDb.pas 3.03                            *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Data-Aware Component Registration Unit      *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF WIN16}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
  {$R StRegDb.r16}
{$ENDIF}

{$IFDEF MSWINDOWS}
  {$R StRegDb.r32}
{$ENDIF}

unit StRegDb;

interface

uses
  Classes;

procedure Register;

implementation

uses
  StBase,
  StDbBarC,
  StDbPNBC;

procedure Register;
begin
  RegisterComponents('SysTools', [TStDbBarCode, TStDbPNBarCode]);
end;

end.