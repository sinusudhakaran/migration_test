{*********************************************************}
{*                  OVCCMDP1.PAS 4.05                    *}
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

unit ovccmdp1;
  {-Form and list that allows re-ordering of its contents}

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Buttons, StdCtrls, ExtCtrls;

type
  TOvcfrmScanOrder = class(TForm)
    lbCommands: TListBox;
    btnUp: TBitBtn;
    bntDown: TBitBtn;
    btnOk: TBitBtn;
    Bevel1: TBevel;
    pnlCmdTables: TPanel;
    btnCancel: TBitBtn;
    procedure btnUpClick(Sender: TObject);
    procedure bntDownClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;


implementation

{$R *.DFM}


procedure TOvcfrmScanOrder.btnUpClick(Sender: TObject);
var
  I : Integer;
begin
  I := lbCommands.ItemIndex;

  if I > 0 then begin
    lbCommands.Items.Exchange(I-1, I);
    lbCommands.ItemIndex := I-1;
  end;
end;

procedure TOvcfrmScanOrder.bntDownClick(Sender: TObject);
var
  I : Integer;
begin
  I := lbCommands.ItemIndex;

  if (I > -1) and (I < lbCommands.Items.Count - 1) then begin
    lbCommands.Items.Exchange(I, I+1);
    lbCommands.ItemIndex := I+1;
  end;
end;

procedure TOvcfrmScanOrder.FormCreate(Sender: TObject);
begin
  Top := (Screen.Height - Height) div 3;
  Left := (Screen.Width - Width) div 2;
end;

end.
