unit WPBltDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2004 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to define bullets/numbers
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{ Manage numbers - This unit used to work for WPTools 4. WPTools 5 number support
  works very much like the number support in WPTools 4.
  Please see the source of this unit to compare the 'old' and the 'new' code }

{$I WPINC.INC}
{$DEFINE WPTools5}

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, {$IFDEF WPXPRN} WPX_Dialogs, {$ELSE} Dialogs, {$ENDIF} StdCtrls, Buttons, ExtCtrls, WPUtil, WPCtrMemo, WPRTEDefs,
  Menus, ComCtrls, WPCtrRich;

type
{$IFNDEF T2H}
  TWPBulletDialogBtn = class(TWinControl) // TSpeedButton)
  protected
    NumberStyle: TWPRTFNumberingStyle;
    ActivePage: TTabSheet;
    FDown, FHasFocus: Boolean;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetDown(x: Boolean);
    procedure Click; override;
    procedure KeyPress(var Key: Char); override;
  public
    property Down: Boolean read FDown write SetDown;
  end;

  TWPBulletDialog = class(TWPShadedForm)
    btnOk: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    ScrollBox3: TScrollBox;
    Bullets: TLabel;
    Numbers: TLabel;
    Outline: TLabel;
    btnAdd: TButton;
    AddPopup: TPopupMenu;
    menAddBullet: TMenuItem;
    menAddNumber: TMenuItem;
    menAddOutline: TMenuItem;
    EditPopup: TPopupMenu;
    menEdit: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelectBulletClick(Sender: TObject);
    procedure ItemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnAddClick(Sender: TObject);
    procedure menAddBulletClick(Sender: TObject);
    procedure menAddOutlineClick(Sender: TObject);
    procedure menEditClick(Sender: TObject);
    procedure menAddNumberClick(Sender: TObject);
  public
    DontEditOutline: Boolean;
    fsEditBox: TWPCustomRtfEdit;
    // RtfText   : TWPRtfTextPaint;
    FAllOptions: TList;
    CurrentItem: TWPBulletDialogBtn;
  end;
{$ENDIF}

  TWPBulletDlg = class(TWPCustomAttrDlg)
  private
    dia: TWPBulletDialog;
    FHideOutlineTab : Boolean;
  public
    DontEditOutline: Boolean;
    function Execute: Boolean; override;
    property HideOutlineTab : Boolean read FHideOutlineTab write FHideOutlineTab;
  published
    property EditBox;
  end;


implementation

{$IFDEF WP6}
uses WPBltStyleDlg, WPSymDlgEx;
{$ELSE}
uses WPBltStyleDlg, WPSymDlg;
{$ENDIF}

{$R *.DFM}

function TWPBulletDlg.Execute: Boolean;
begin
  Result := FALSE;
  if assignedActiveRTFEdit(FEditBox) and Changing then
  begin
    dia := TWPBulletDialog.Create(Self);
    if FHideOutlineTab then dia.TabSheet3.TabVisible := FALSE;
    try
      dia.DontEditOutline := DontEditOutline;
        // dia.RtfText           := (ActiveRTFEdit(FEditBox).RtfText as TWPRtfTextPaint);
      dia.fsEditBox := ActiveRTFEdit(FEditBox);
      if not FCreateAndFreeDialog and MayOpenDialog(dia) and (dia.ShowModal = IDOK) then
      begin
        Result := TRUE;
        dia.fsEditBox.ReformatAll;
        dia.fsEditBox.Invalidate;
      end else dia.fsEditBox.Modified := FOldModified;
    finally
      dia.Free;
    end;
  end;
end;

procedure TWPBulletDialog.FormActivate(Sender: TObject);
var i, numlevel: Integer;
  sty: TWPRTFNumberingStyle;
  SkipNumbering: Boolean;
begin
  //was: sty := fsEditBox.CurrAttr.ExNumberStyle;
  // We are using the more basic interface to the RTF engine
  sty := fsEditBox.Memo.Cursor.RTFProps.NumberStyles.FindParNumberStyle(fsEditBox.Memo.Cursor.active_paragraph, numlevel, SkipNumbering);

  for i := 0 to FAllOptions.Count - 1 do
  begin
    if TWPBulletDialogBtn(FAllOptions[i]).NumberStyle = sty then
    begin
      TWPBulletDialogBtn(FAllOptions[i]).Down := TRUE;
      if sty <> nil then PageControl1.ActivePage := TWPBulletDialogBtn(FAllOptions[i]).ActivePage;
    end;
  end;
end;

procedure TWPBulletDialog.btnOkClick(Sender: TObject);
var sty: TWPRTFNumberingStyle;
  i, dummy: Integer;
begin
  sty := nil;
  for i := 0 to FAllOptions.Count - 1 do
  begin
    if TWPBulletDialogBtn(FAllOptions[i]).Down then
      sty := TWPBulletDialogBtn(FAllOptions[i]).NumberStyle;
  end;

  //was: fsEditBox.CurrAttr.ExNumberStyle := sty;
  // We are using the more basic interface to the RTF engine
  if sty = nil then
  begin
    fsEditBox.ASet(WPAT_NumberSTYLE, 0);
    fsEditBox.ASet(WPAT_NumberLevel, 0);
  end
  else
  begin
    if not sty.TextStyle.AGet(WPAT_IndentLeft, dummy) and
       not sty.TextStyle.AGet(WPAT_IndentFirst, dummy) then
    begin
      if sty.Group = 0 then
      begin
        fsEditBox.ASet(WPAT_NumberSTYLE, sty.Number);
        fsEditBox.ADel(WPAT_NumberLevel);
        fsEditBox.ASet(WPAT_IndentLeft, 0);
        fsEditBox.ASet(WPAT_IndentFirst, 0);
      // Align to next tabstop
        if fsEditBox.IsSelected then
          fsEditBox.TextCursor.SelectedTextAttr.AutoIndentFirst(fsEditBox.DefaultNumberIndent)
        else fsEditBox.TextCursor.WritingTextAttr.AutoIndentFirst(fsEditBox.DefaultNumberIndent);
      end else
      begin
        fsEditBox.ASet(WPAT_NumberSTYLE, sty.Number);
        fsEditBox.ASet(WPAT_NumberLevel, sty.LevelInGroup);
        fsEditBox.ASet(WPAT_IndentLeft, sty.LevelInGroup * fsEditBox.DefaultNumberIndent);
        fsEditBox.ASet(WPAT_IndentFirst, -fsEditBox.DefaultNumberIndent);
      end;
    end else
    begin
        fsEditBox.ASet(WPAT_NumberSTYLE, sty.Number);
        if sty.Group = 0 then
              fsEditBox.ADel(WPAT_NumberLevel)
        else  fsEditBox.ASet(WPAT_NumberLevel, sty.LevelInGroup);
    end;
  end;
  fsEditBox.ChangeApplied;

 (* if (sty <> nil) and (sty.Style = wp_bullet)
    then begin
  //was:        fsEditBox.CurrAttr.indentleft := fsEditBox.CurrAttr.indentleft +
  //was:           (200 + fsEditBox.CurrAttr.indentfirst);
  //was:        fsEditBox.CurrAttr.indentfirst := -200;
    if not fsEditBox.AGet(WPAT_IndentLeft, l) then l := 0;
    if not fsEditBox.AGet(WPAT_IndentLeft, f) then f := 0;
    fsEditBox.ASet(WPAT_IndentLeft, l + 200 + f);
    fsEditBox.ASet(WPAT_IndentFirst, -200);
  end; *)

  ModalResult := mrOk;
end;

procedure TWPBulletDialog.SelectBulletClick(Sender: TObject);
var i: Integer;
begin
  TWPBulletDialogBtn(Sender).Down := not TWPBulletDialogBtn(Sender).Down;

  if (TWPBulletDialogBtn(Sender).NumberStyle = nil) or
    not TWPBulletDialogBtn(Sender).Down then
    for i := 0 to FAllOptions.Count - 1 do
    begin
      TWPBulletDialogBtn(FAllOptions[i]).Down
        := TWPBulletDialogBtn(FAllOptions[i]).NumberStyle = nil;
    end
  else
    for i := 0 to FAllOptions.Count - 1 do
    begin
      if TWPBulletDialogBtn(FAllOptions[i]) <> Sender then
        TWPBulletDialogBtn(FAllOptions[i]).Down := FALSE;
    end;
end;

procedure TWPBulletDialog.ItemMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var p: TPoint;
begin
  if Button = mbRight then
  begin
    CurrentItem := TWPBulletDialogBtn(Sender);
    if (CurrentItem.NumberStyle <> nil) and
      (not DontEditOutline or (CurrentItem.NumberStyle.Group = 0)) then
    begin
      p := CurrentItem.ClientToScreen(Point(x, y));
      EditPopup.PopupComponent := CurrentItem;
      EditPopup.Popup(p.x, p.y);
    end;
  end;
end;

procedure TWPBulletDialog.btnAddClick(Sender: TObject);
var p: TPoint;
begin
  p := (Sender as TControl).ClientToScreen(Point(0, (Sender as TControl).Height));
  EditPopup.PopupComponent := (Sender as TControl);
  AddPopup.Popup(p.x, p.y);
end;


procedure TWPBulletDialog.menAddBulletClick(Sender: TObject);
{$IFDEF WP6}
var dia: TWPSymbolDlgEx;
begin
  dia := TWPSymbolDlgEx.Create(Self);
{$ELSE}
var dia: TWPSymbolDlg;
begin
  dia := TWPSymbolDlg.Create(Self);
{$ENDIF}
  try
    dia.FontName := 'Wingdings';
    dia.Character := '1';
    dia.NotAttachedToEditBox := TRUE;
    dia.UseOKButton := TRUE;
    if dia.Execute then
    begin
       // with TWPRTFNumberingStyle(fsEditBox.Memo.FNumberStyles.Add) do
      with TWPRTFNumberingStyle(fsEditBox.Memo.RTFData.RTFProps.NumberStyles.Add) do
      begin
        Group := 0;
        Style := wp_Bullet;
        Indent := fsEditBox.DefaultNumberIndent;
        Font := dia.FontName;
        TextB := dia.Character;
      end;
      PageControl1.ActivePageIndex := 0;
      FormShow(nil);
    end;
  finally
    dia.Free;
  end;
end;

procedure TWPBulletDialog.menAddOutlineClick(Sender: TObject);
begin
   // not implemented
  PageControl1.ActivePageIndex := 2;
end;



procedure TWPBulletDialog.FormCreate(Sender: TObject);
begin
  FAllOptions := TList.Create;
  TabSheet1.Caption := Bullets.Caption;
  TabSheet2.Caption := Numbers.Caption;
  TabSheet3.Caption := Outline.Caption;
end;

procedure TWPBulletDialog.FormDestroy(Sender: TObject);
begin
  FAllOptions.Free;
end;

procedure TWPBulletDialog.FormShow(Sender: TObject);
var i: Integer;
  x, y: Integer;
  sty: TWPRTFNumberingStyle;
  ctr: TControl;
  procedure AddItem(Par: TScrollBox; ActivePage: TTabSheet; Style: TWPRTFNumberingStyle);
  var but: TWPBulletDialogBtn;
  begin
    but := TWPBulletDialogBtn.Create(Par);
    but.Width := 60;
    but.Height := 80;
    if x + 60 > Par.Width - 30 then
    begin
      x := 2;
      inc(y, 84);
    end;
    but.Left := x;
    but.Top := y;
    inc(x, 62);
    but.Parent := Par;
    but.NumberStyle := Style;
    but.ActivePage := ActivePage;
    but.TabStop := TRUE;
      // but.GroupIndex := FAllOptions.Count+1;
      // but.AllowAllUp := TRUE;
    but.OnClick := SelectBulletClick;
    but.OnMouseDown := ItemMouseDown;
    FAllOptions.Add(but);
  end;
begin
  FAllOptions.Clear;
  for i := ScrollBox1.ControlCount - 1 downto 0 do
  begin
    ctr := ScrollBox1.Controls[i];
    ctr.Parent := nil;
    ctr.Free;
  end;
  for i := ScrollBox2.ControlCount - 1 downto 0 do
  begin
    ctr := ScrollBox2.Controls[i];
    ctr.Parent := nil;
    ctr.Free;
  end;
  for i := ScrollBox3.ControlCount - 1 downto 0 do
  begin
    ctr := ScrollBox3.Controls[i];
    ctr.Parent := nil;
    ctr.Free;
  end;


  if fsEditBox <> nil then
  begin
     // Page 1: Bullets
    x := 2;
    y := 2;
    AddItem(ScrollBox1, TabSheet1, nil);
    for i := 0 to fsEditBox.Memo.RTFData.RTFProps.NumberStyles.Count - 1 do
    begin
      sty := fsEditBox.Memo.RTFData.RTFProps.NumberStyles[i];
      if (sty.Style in [wp_bullet, wp_circle,
              {wp_1st, wp_One, wp_First, }wp_unicode, wp_char])
         and (sty.Group = 0)
         and ((sty.TextB<>'') or (sty.TextA<>''))
         then AddItem(ScrollBox1, TabSheet1, sty);
    end;
     // Page 2: Numbers
    x := 2;
    y := 2;
    AddItem(ScrollBox2, TabSheet2, nil);
    for i := 0 to fsEditBox.Memo.RTFData.RTFProps.NumberStyles.Count - 1 do
    begin
      sty := fsEditBox.Memo.RTFData.RTFProps.NumberStyles[i];
      if not (sty.Style in [wp_bullet, wp_circle,
                            wp_1st, wp_One, wp_First, wp_unicode, wp_char])
         and (sty.Group = 0)
      then AddItem(ScrollBox2, TabSheet2, sty);
    end;
     // Page 3 Outline
     // We currently support only one outline Group
    if fsEditBox.Memo.RTFData.RTFProps.NumberStyles.InitGroupArray(1) = 0 then
      TabSheet3.TabVisible := FALSE
    else
    begin
      x := 2;
      y := 2;
      TabSheet3.TabVisible := TRUE;
      AddItem(ScrollBox3, TabSheet3, nil);
      for i := 1 to 9 do
      begin
        sty := fsEditBox.Memo.RTFData.RTFProps.NumberStyles.GroupItems[i];
        if sty <> nil then AddItem(ScrollBox3, TabSheet3, sty);
      end;
    end;
  end;
end;

 //   NumberStyle : TWPRTFNumberingStyle;

procedure TWPBulletDialogBtn.SetDown(x: Boolean);
begin
  if FDown <> x then
  begin FDown := x;
    invalidate;
  end;
end;

procedure TWPBulletDialogBtn.Click;
begin
  inherited;
  SetFocus;
end;

procedure TWPBulletDialogBtn.KeyPress(var Key: Char);
begin
  inherited;
  if Key = #32 then Click;
end;

procedure TWPBulletDialogBtn.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  FHasFocus := TRUE;
  invalidate;
end;

procedure TWPBulletDialogBtn.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  FHasFocus := FALSE;
  invalidate;
end;

procedure TWPBulletDialogBtn.WMPaint(var Message: TWMPaint);
var r: TRect; i, h: Integer;
  Canvas: TCanvas; DC: HDC;
begin
  inherited;
  Canvas := TControlCanvas.Create;
  if Message.dc <> 0 then
  begin
    Canvas.Handle := Message.dc;
    DC := 0;
  end
  else
  begin
    DC := GetDC(Handle);
    Canvas.Handle := DC;
  end;
  try
    Canvas.Brush.Color := clWhite;
    if Down then
      Canvas.Pen.Color := clNavy
    else Canvas.Pen.Color := clBtnFace;
    Canvas.Pen.Width := 3;
    r := ClientRect;
    Canvas.Rectangle(r.Left, r.Top, r.Right, r.Bottom);
    inflateRect(r, -3, -3);
    if NumberStyle = nil then
    begin
       // Cross ...
      Canvas.Pen.Color := clBtnShadow;
      Canvas.MoveTo(r.Left, r.Top);
      Canvas.LineTo(r.Right, r.Bottom);
      Canvas.MoveTo(r.Right, r.Top);
      Canvas.LineTo(r.Left, r.Bottom);
    end else
    begin
      h := (Height - 8) div 3;
      Canvas.Font.Size := 11;
      Canvas.Pen.Color := clBtnFace;
      for i := 0 to 2 do
      begin
        Canvas.MoveTo(20, 4 + h * i + h div 2);
        Canvas.LineTo(Width - 6, 4 + h * i + h div 2);
        NumberStyle.DrawTo(Canvas, i + 1, 6, 4 + h * i, 0);
      end;
    end;

    if FHasFocus then
      DrawFocusRect(Canvas.Handle, r);

  finally
    Canvas.Handle := 0;
    if DC <> 0 then ReleaseDC(Handle, DC);
    Canvas.Free;
  end;
end;

procedure TWPBulletDialog.menEditClick(Sender: TObject);
var dia: TWPBulletStyleDialog; i: Integer;
begin
  if (CurrentItem <> nil) and (CurrentItem.NumberStyle <> nil) then
  begin
    dia := TWPBulletStyleDialog.Create(Self);
    try
      dia.CheckUsePrev.Enabled := CurrentItem.NumberStyle.Group > 0;
      dia.UsePrev := CurrentItem.NumberStyle.UsePrev;
      dia.TextA := CurrentItem.NumberStyle.TextA;
      dia.TextB := CurrentItem.NumberStyle.TextB;
      dia.FontName := CurrentItem.NumberStyle.Font;
      dia.FontSize := CurrentItem.NumberStyle.TextStyle.AGetDef(
        WPAT_CharFontSize, 0) div 100;
      if CurrentItem.NumberStyle.TextStyle.AGet(WPAT_CharColor, i) then
        dia.FontColor := CurrentItem.NumberStyle.TextStyle.RTFProps.ColorTable[i];
      dia.Style := CurrentItem.NumberStyle.Style;
      dia.Indent := CurrentItem.NumberStyle.Indent;
      if dia.ShowModal = IDOK then
      begin
        CurrentItem.NumberStyle.UsePrev :=
          (CurrentItem.NumberStyle.Group > 0) and dia.UsePrev;
        CurrentItem.NumberStyle.TextA := dia.TextA;
        CurrentItem.NumberStyle.TextB := dia.TextB;
        CurrentItem.NumberStyle.Font := dia.FontName;
        CurrentItem.NumberStyle.Style := dia.Style;
        CurrentItem.NumberStyle.Indent := dia.Indent;
        CurrentItem.NumberStyle.TextStyle.ASetNeutral(
          WPAT_CharFontSize, dia.FontSize * 100);
        if dia.FontColor <> clWindowText then
          CurrentItem.NumberStyle.TextStyle.ASetColor(
            WPAT_CharColor, dia.FontColor
            )
        else CurrentItem.NumberStyle.TextStyle.ADel(WPAT_CharColor);
        CurrentItem.Invalidate;
      end;
    finally
      dia.Free;
    end;
  end;
end;

procedure TWPBulletDialog.menAddNumberClick(Sender: TObject);
var dia: TWPBulletStyleDialog;
begin
  dia := TWPBulletStyleDialog.Create(Self);
  try
    dia.CheckUsePrev.Enabled := FALSE;
    dia.UsePrev := FALSE;
    dia.TextA := '.)';
    dia.TextB := '';
    dia.FontName := '';
    dia.Style := wp_1;
    dia.Indent := fsEditBox.DefaultNumberIndent;
    if dia.ShowModal = IDOK then
    begin
      with TWPRTFNumberingStyle(fsEditBox.Memo.RTFData.RTFProps.NumberStyles.Add) do
      begin
        TextA := dia.TextA;
        TextB := dia.TextB;
        Font := dia.FontName;
        Style := dia.Style;
        Indent := dia.Indent;
      end;
      PageControl1.ActivePageIndex := 1;
      FormShow(nil);
    end;
  finally
    dia.Free;
  end;
end;

end.

