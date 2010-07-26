{*********************************************************}
{*                  OVCREGF2.PAS 4.05                    *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$IFNDEF VERSION3}
!! Error - not for Delphi 1 or Delphi 2 or C++ Builder 1
{$ENDIF}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

{$R OVCREGF2.RES}

unit OvcRegF2;
  {-Registration unit for the FlashFiler 2 support}

interface

uses
  Windows,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Classes,
  Controls,
  TypInfo;

procedure Register;

implementation

uses
  SysUtils,
  Forms,
  Graphics,
  OvcDbHF2;  {FlashFiler 2 database engine helper}


{*** component registration ***}

procedure Register;
begin
  RegisterComponents('Orpheus db', [
    TOvcDbFF2EngineHelper
    ]);
end;


end.
