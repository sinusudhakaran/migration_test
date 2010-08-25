{*********************************************************}
{*                  OVCBTNHD0.PAS 4.05                   *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovcbtnh0;
  {-component editor for the button header}

interface

uses
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Forms, SysUtils, OvcData, OvcBase, OvcBtnHd, OvcColE0;

type
  TOvcButtonHeaderEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer) : string;
      override;
    function GetVerbCount : Integer;
      override;
  end;


implementation


{*** TOvcComponentStateEditor ***}

procedure TOvcButtonHeaderEditor.ExecuteVerb(Index : Integer);
begin
{$IFDEF VERSION5}
  if Index = 0 then
    ShowCollectionEditor(Designer,
                         (Component as TOvcButtonHeader).Sections,
                         IsInInLined);
{$ELSE}
  if Index = 0 then
    ShowCollectionEditor(Designer, (Component as TOvcButtonHeader).Sections);
{$ENDIF}
end;

function TOvcButtonHeaderEditor.GetVerb(Index : Integer) : string;
begin
  Result := 'Edit Sections...';
end;

function TOvcButtonHeaderEditor.GetVerbCount : Integer;
begin
  Result := 1;
end;


end.
