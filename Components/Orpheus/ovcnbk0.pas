{*********************************************************}
{*                   OVCTAB0.PAS 4.05                    *}
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

unit ovcnbk0;
  {-component editor for the tab control}

interface

uses
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Forms, SysUtils, OvcBase, OvcData, OvcNbk, OvcColE0;

type
  TOvcNotebookEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer) : string;
      override;
    function GetVerbCount : Integer;
      override;
  end;


implementation


{*** TOvcNotebookEditor ***}

       
procedure TOvcNotebookEditor.ExecuteVerb(Index : Integer);
begin
{$IFDEF VERSION5}
  if Index = 0 then
    ShowCollectionEditor(Designer,
                         (Component as TOvcNotebook).PageCollection,
                         IsInInLined);
{$ELSE}
  if Index = 0 then
    ShowCollectionEditor(Designer, (Component as TOvcNotebook).PageCollection);
{$ENDIF}
end;
       

function TOvcNotebookEditor.GetVerb(Index : Integer) : string;
begin
  Result := 'Edit Pages...';
end;

function TOvcNotebookEditor.GetVerbCount : Integer;
begin
  Result := 1;
end;


end.
