{*********************************************************}
{*                   OVCEVENTS.PAS 4.05                  *}
{*     COPYRIGHT (C) 2000-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovcevents;
  {-Miscellaneous generic event method types}

interface

uses classes;

type
  TOvcErrorEvent = 
    procedure(Sender: TObject; ErrorCode: Word; const ErrorMsg: string)
    of object;

implementation

end.
 
