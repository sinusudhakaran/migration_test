{*********************************************************}
{*                  OVCREGIS.PAS 4.05                    *}
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

{$R OVCREGIS.RES}

unit OvcRegIs;
  {-Registration unit for the DBISAM support}

interface

uses
  Windows,
  {!!.03}
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Classes, Controls, TypInfo;

procedure Register;

implementation

uses
  SysUtils, Forms, Graphics,
  OvcDbHIs;  {DBISAM database engine helper}


{*** component registration ***}

procedure Register;
begin
  RegisterComponents('Orpheus db', [
    TOvcDbDBISAMEngineHelper
    ]);
end;


end.
