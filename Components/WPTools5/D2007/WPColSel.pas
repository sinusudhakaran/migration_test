unit WPColSel;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to select a color
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$I WPINC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF WPXPRN} WPX_Dialogs, {$ELSE} Dialogs, {$ENDIF} 
  StdCtrls, Buttons, ExtCtrls, WPCtrMemo, WPUtil;

type
  TWPTColorSelector = class(TWPShadedForm)
    PaintBox1: TPaintBox;
    Shape1: TShape;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    SelNr   : Integer;
    editor  : TWPCustomRtfEdit;
  end;

var
  WPTColorSelector: TWPTColorSelector;

procedure WPCreateColorForm(Form : TWinControl;Sender : TControl; editor : TWPCustomRtfEdit; var colorindex : Integer);

implementation

const
  BoxSize  = 16;

{$R *.DFM}

procedure WPCreateColorForm(Form : TWinControl;Sender : TControl; editor : TWPCustomRtfEdit; var colorindex : Integer);
var
  dia : TWPTColorSelector;
  p : TPoint;
begin
   dia := nil;
   if editor<>nil then
   try
    dia := TWPTColorSelector.Create(Form);
    dia.editor := editor;
    p.x := 0;
    p.y := 0;
    p := Sender.ClientToScreen(p);
    dia.Left := p.x;
    dia.Top  := p.y + Sender.Height;
    if (dia.ShowModal=IDOK)  then
    begin
      colorindex := dia.SelNr;
    end else colorindex := -1;
  finally
    dia.Free;
  end;
end;


procedure TWPTColorSelector.PaintBox1Paint(Sender: TObject);
var
  i, j,n : Integer;
  PROCEDURE DRAWCOLOR(N,X,Y : INTEGER; COLOR : TCOLOR);
  var
    r : TRect;
  begin
    r.Left   := x;
    r.Top    := y;
    r.Right  := x + BoxSize;
    r.Bottom := y + BoxSize;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := Self.Color;
    Canvas.Rectangle( r.Left, r.Top, r.Right, r.Bottom);
    Canvas.FillRect(r);
    InflateRect( r, -1, -1 );
    if n = SelNr then Canvas.Pen.Color := clBlue
    else Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle( r.Left, r.Top, r.Right, r.Bottom);
    inflateRect( r, -1, -1 );
    if n = SelNr then Canvas.Pen.Color := clWhite
    else Canvas.Pen.Color := Self.Color;
    Canvas.Rectangle( r.Left, r.Top, r.Right, r.Bottom);
    inflateRect( r, -1, -1 );
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(r);
  end;
begin
  n := 0;
  for i := 0 to 1 do
    for j := 0 to 7 do
    begin
        DrawColor( n,PaintBox1.Left + j * BoxSize, PaintBox1.Top + i * BoxSize,
           editor.TextColors[n] );
        inc(n);
    end;
end;

procedure TWPTColorSelector.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if Key=#27 then begin ModalResult := idCancel; end;
end;

procedure TWPTColorSelector.FormShow(Sender: TObject);
begin
  ClientWidth  := BoxSize * 8 + 2;
  ClientHeight := BoxSize * 2 + 2;
  PaintBox1.SetBounds(1,1,BoxSize * 8 + 2,BoxSize * 2 + 2);
  MouseCapture := TRUE;
end;

procedure TWPTColorSelector.FormMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if SelNr in [0..15] then ModalResult := idOK else ModalResult := idCancel;
end;

procedure TWPTColorSelector.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
 i : integer;
begin
  dec(y);
  dec(x);
  i := (y div BoxSize) * 8  + x div BoxSize;
  if (i<>SelNr) and (x<Width) and (y<Height) and (x>0) and (y>0) then
  begin
    SelNr := i;
    PaintBox1Paint(PaintBox1);
  end;
end;

end.
