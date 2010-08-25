unit WPPrTab1;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  Little form to let the user create a table
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

//V4.07 Move to first cell of new table. This is what Word also does
{$DEFINE MOVETONEWTABLE}

interface

{$I WPINC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, WPRTEDefs, WPCTRRich, WPUtil, WPCTRMemo;

type
  TWPTableSelect = class(TForm)
    Panel2: TPanel;
    PaintBox1: TPaintBox;
    Status: TPanel;
    ShowBord: TSpeedButton;
    Button1: TBitBtn;
    PaintBox2: TPaintBox;
    Shape1: TShape;
    procedure FormPaint(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PaintBox1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox2Paint(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    FButton, FDontClose: Boolean;
  public
    row, col: Integer;
    { Public-Deklarationen }
  end;

procedure WPCreateTableForm(Form: TWinControl; Sender: TControl; editor: TWPCustomRichText;
  AllowNestedTables: Boolean = FALSE);

implementation

{$R *.DFM}

procedure WPCreateTableForm(Form: TWinControl; Sender: TControl; editor: TWPCustomRichText;
  AllowNestedTables: Boolean = FALSE);
var
  dia: TWPTableSelect;
  p: TPoint;
  count, ccount: Integer;
  opt: TWPTableAddOptions;
  newtable: TParagraph;
  HasUndo : Boolean;
begin
  dia := nil;
  HasUndo := FALSE;
  if editor <> nil then try
    dia := TWPTableSelect.Create(Form);
    if Sender <> nil then begin
      p.x := 0;
      p.y := 0;
      p := Sender.ClientToScreen(p);
      inc(p.y, Sender.Height);
    end
    else GetCursorPos(p);

    if p.x + dia.Width > Screen.DesktopWidth then
      p.x := Screen.DesktopWidth - dia.Width;
    if p.y + dia.Height > Screen.DesktopWidth then
      p.y := Screen.DesktopWidth - dia.Height;
    dia.Left := p.x;
    dia.Top := p.y;
    // dia.FButton := TRUE;
    if (dia.ShowModal = IDOK) then begin
    {  Style := Editor.Memo.active_paragraph.Style;
      if editor.Memo.active_line^.plen>0 then Editor.InputText(#13);
      Editor.BeginUpdate;
      Editor.InputText(#13);
      Editor.CPMoveBack;
      Editor.Memo.active_paragraph.Style := Style; }
      count := dia.row;
      ccount := dia.col;

{$IFDEF ALLOWUNDO}
  if (wpActivateUndo in Editor.EditOptions) then
  begin
    Editor.RTFData.UndoBufferSaveTo(nil, wpuStoreCursorPos, wputChangeTable);
    if Editor.Table<>nil then
    begin
        Editor.RTFData.UndoBufferSaveTo(Editor.Table, wpuReplaceParTotal, wputChangeTable);
        Editor.RTFData.UndoDisable;
        HasUndo := TRUE;
    end;
  end;
{$ENDIF}

      if AllowNestedTables then begin
        opt := [wptblAllowNestedTables, wptblPlaceCursorInLastCell];
        if dia.ShowBord.Down then
          include(opt, wptblActivateBorders);
        newtable := Editor.TableAdd(ccount, count, opt);
      end
      else newtable := Editor.AddTable(ccount, count, dia.ShowBord.Down);

      if (newtable <> nil) and (newtable.ParentTable <> nil) then //V5.22.2
      begin
        newtable := newtable.ParentTable;
        if newtable.NextPar = nil then
        begin
          newtable.NextPar := TParagraph.Create(newtable.RTFData);
{$IFDEF ALLOWUNDO}
  if (wpActivateUndo in Editor.EditOptions) then
    Editor.RTFData.UndoBufferSaveTo(
      newtable.NextPar, wpuDeletePar, wputChangeTable);
{$ENDIF}
        end;
      end;

{$IFDEF MOVETONEWTABLE} //V4.07
   {   Editor.CPMoveBack;
      Editor.TableColNumber := 0;
      Editor.TableRowNumber := 0;  }
{$ENDIF}
     // Editor.EndUpdate;
    end;
  finally
    dia.Free;
  {$IFDEF ALLOWUNDO}
    if HasUndo then Editor.RTFData.UndoEnable;
{$ENDIF}
  end;
end;

{ Table select form }

procedure TWPTableSelect.PaintBox2Paint(Sender: TObject);
begin
  if WPAllDialogsBitmap <> nil then
    WPDrawShade(PaintBox2.Canvas, PaintBox2.ClientRect, 192 - 128, WPShadedFormHorizontal, WPShadedFormBothWays,
      WPAllDialogsBitmap, true, Color);
end;

procedure TWPTableSelect.FormPaint(Sender: TObject);
var
  w: Integer;
  x, y: Integer;
  r: TRect;
begin
  with PaintBox1 do begin
    w := Canvas.TextHeight('A');
    if row <= 0 then row := 1;
    if col <= 0 then col := 1;
    Status.Caption := IntToStr(col) + #32 + 'X' + IntToStr(row);
    r.Left := 0;
    r.Top := 0;
    r.Right := col * w;
    r.Bottom := row * w;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clHighlight;
    Canvas.FillRect(r);
    Canvas.Pen.Color := clBtnShadow;
    x := w;
    while x < Width do begin
      Canvas.MoveTo(x, 0);
      Canvas.LineTo(x, Height);
      inc(x, w);
    end;
    y := w;
    while y < Height do begin
      Canvas.MoveTo(0, y);
      Canvas.LineTo(Width, y);
      inc(y, w);
    end;
  end;
end;

procedure TWPTableSelect.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  r, c, w: Integer;
begin
  w := PaintBox1.Canvas.TextHeight('A');
  r := (y + w div 2) div w;
  c := (x + w div 2) div w;
  if (r <> row) or (c <> col) then
  begin
    row := r;
    col := c;
    if col * w >= PaintBox1.Width then
      Width := Width + w + 2;
    if row * w >= PaintBox1.Height then
      Height := Height + w + 2;
    PaintBox1.invalidate;
     // OKButton.Enabled := col>=1;
  end;
  FButton := TRUE;
end;

procedure TWPTableSelect.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FButton := FALSE;
end;



procedure TWPTableSelect.PaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  r, c, w: Integer;
begin
  w := PaintBox1.Canvas.TextHeight('A');
  r := (y + w div 2) div w;
  c := (x + w div 2) div w;
  if (r <> row) or (c <> col) then
  begin
    row := r;
    col := c;
    if FButton then
    begin
      if col * w >= PaintBox1.Width then
        Width := Width + w + 2;
      if row * w >= PaintBox1.Height then
        Height := Height + w + 2;
      FDontClose := TRUE;
    end;
    PaintBox1.Invalidate;
     // OKButton.Enabled := col>=1;
  end;
end;

procedure TWPTableSelect.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FButton then
    PaintBox1MouseMove(sender, Shift, x, y);
end;

procedure TWPTableSelect.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style or WS_BORDER;
end;

procedure TWPTableSelect.PaintBox1DblClick(Sender: TObject);
begin
  if col >= 1 then ModalResult := IDOK
  else ModalResult := IDCANCEL;
end;


procedure TWPTableSelect.FormCreate(Sender: TObject);
begin
  ShowBord.Flat := TRUE;
  // OKButton.Flat := TRUE;
  // SpeedButton2.Flat := TRUE;
  Panel2.DoubleBuffered := TRUE;
end;

procedure TWPTableSelect.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then ModalResult := IDOK
  else if Key = #27 then ModalResult := IDCANCEL;
end;

procedure TWPTableSelect.PaintBox1Click(Sender: TObject);
begin
  if not FDontClose then
  begin
    if col >= 1 then ModalResult := IDOK
    else ModalResult := IDCANCEL;
  end;
  FDontClose := FALSE;
end;

procedure TWPTableSelect.FormResize(Sender: TObject);
begin
  Panel2.BoundsRect := Rect(2, 2, Width - 4, Height - 4 - Status.Height);
  // Button1.Top := 2;
  // Button1.Left := Width - Button1.Width-1;
end;



end.

