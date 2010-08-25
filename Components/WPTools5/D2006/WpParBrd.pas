unit WpParBrd;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to change the borders of the current paragraph/cell
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

  { This dialog has been just slightly modified to work with WPTools 5 -
    The possibilities of WPTools 5 go far beyond this simple dialog, so
    an improved border dialog has to be added to the package }

interface

{$I WPINC.INC}

uses Windows, SysUtils, Messages, Classes, Graphics, Controls, WPRTEDefs,
  Forms, Dialogs, StdCtrls, Buttons, WPCTRMemo, WPCTRRich, ExtCtrls,
  WPColSel, WPTbar, WPPanel, WPUtil, WPAction;

type
{$IFNDEF T2H}
  TWPParagraphBord = class(TWPShadedForm)
    btnOk: TButton;
    btnCancel: TButton;
    btnUpdate: TButton;
    Borders: TGroupBox;
    Style: TGroupBox;
    vePenWidth: TWPValueEdit;
    veSpace: TWPValueEdit;
    Ndouble: TCheckBox;
    btnTColor: TWPToolButton;
    btnLColor: TWPToolButton;
    btnRColor: TWPToolButton;
    btnBColor: TWPToolButton;
    PaintBox1: TPaintBox;
    labWidth: TLabel;
    labSpace: TLabel;
    Dotted: TCheckBox;
    labShading: TLabel;
    cbxShading: TWPComboBox;
    Bevel1: TBevel;
    WPToolButton1: TWPToolButton;
    cpxShadingValue: TWPValueEdit;
    btnTop: TCheckBox;
    btnLeft: TCheckBox;
    btnRight: TCheckBox;
    btnBottom: TCheckBox;
    cbxAll: TSpeedButton;
    drBox: TCheckBox;
    btnUndo: TBitBtn;
    procedure cbxAllClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BorderButtonsClick(Sender: TObject);
    procedure WidthSpaceChange(Sender: TObject);
    procedure ColorButtonClick(Sender: TObject);
    procedure DottedClick(Sender: TObject);
    procedure cbxShadingChange(Sender: TObject);
    procedure NdoubleClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure WPToolButton1Click(Sender: TObject);
    procedure drBoxClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure cpxShadingValueChange(Sender: TObject);
  public
    { Public-Deklarationen }
    twips: array[1..7] of Longint;
    fsEditBox: TWPCustomRTFEdit;
    // RtfText : TWPRtfTextPaint;
    allnew: Boolean;
    //was: procedure UpdateValues(x : TBorder);
    procedure UpdateValues(Ref: TWPTextStyle);
  end;
{$ENDIF}

  TWPParagraphBorderDlg = class(TWPCustomAttrDlg)
  private
    dia: TWPParagraphBord;
    FAutoUpdate: Boolean;
  public
    function Execute: Boolean; override;
  published
    property EditBox;
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate;
  end;

implementation

{$R *.DFM}

function TWPParagraphBorderDlg.Execute: Boolean;

begin
  Result := FALSE;
  if assignedActiveRTFEdit(FEditBox) then
  begin
    try
      dia := TWPParagraphBord.Create(Self);
      dia.fsEditBox := ActiveRTFEdit(FEditBox) as TWPCustomRTFEdit;
      dia.cbxShading.DontApplyChanges := TRUE;
      dia.cbxShading.FRtfEdit := dia.fsEditBox as TWPCustomRTFEdit;

      if FAutoUpdate then dia.btnUpdate.Visible := False;
      if not FCreateAndFreeDialog and MayOpenDialog(dia) and (dia.ShowModal = IDOK) then Result := TRUE;
      ActiveRTFEdit(FEditBox).Repaint;
    finally
      dia.Free;
    end;
  end;
end;

procedure TWPParagraphBord.FormActivate(Sender: TObject);
begin
  if (fsEditBox <> nil) and (fsEditBox.ActiveParagraph <> nil) then
    UpdateValues(fsEditBox.ActiveParagraph); // ^.Border);
  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.UpdateValues(Ref: TWPTextStyle);
var x: TBorder;
    flags, i,l,r,b : Integer;
begin
  //WPTools 5: Fill a TBorder record
  Ref.AGetBorder(x, false, true, true);
  if not (blEnabled in x.LineType) then
  begin
    FillChar(x, Sizeof(TBorder), 0);
    allnew := True;
  end
  else
    allnew := False;

  with x do
  begin
    btnTop.State := cbGrayed;
    btnLeft.State := cbGrayed;
    btnRight.State := cbGrayed;
    btnBottom.State := cbGrayed;
    Ndouble.State := cbGrayed;
    Dotted.State := cbGrayed;
    drBox.State := cbGrayed;
    btnLColor.Tag := -1; // BorderColor[blLeft];
    btnRColor.Tag := -1; // BorderColor[blRight];
    btnTColor.Tag := -1; // BorderColor[blTop];
    btnBColor.Tag := -1; // BorderColor[blBottom];
    vePenWidth.Undefined := TRUE;
    cpxShadingValue.Undefined := TRUE;
    veSpace.Undefined := TRUE;
    // veSpace.Enabled := fsEditBox.InTable; // only in Tables!
    // labSpace.Enabled := veSpace.Enabled; // only in Tables!
    drBox.Visible := not fsEditBox.InTable; // NOT in tables!
    cbxShading.ItemIndex := -1;
  end;

if Ref.AGet(WPAT_BorderFlags,flags) then
         begin
            btnTop.Checked := (flags and WPBRD_DRAW_Top)<>0;
            btnLeft.Checked := (flags and WPBRD_DRAW_Left)<>0;
            btnRight.Checked := (flags and WPBRD_DRAW_Right)<>0;
            btnBottom.Checked := (flags and WPBRD_DRAW_Bottom)<>0;
            if Ref.AGet(WPAT_BorderType,i) then // ALL!
            begin
               if i=WPBRD_DOTTED then Dotted.Checked := TRUE
               else if i=WPBRD_DOUBLE then Ndouble.Checked := TRUE;
            end;

            if Ref.AGet(WPAT_BorderWidthT,i) then
            begin
               l := Ref.AGetDef(WPAT_BorderWidthT,i);
               r := Ref.AGetDef(WPAT_BorderWidthR,i);
               b := Ref.AGetDef(WPAT_BorderWidthB,i);
               if (i=l) and (r=b) and (i=r) then
                 vePenWidth.Value := i;
            end;   

            if Ref.AGet(WPAT_BorderWidth,i) then // ALL!
            begin
               vePenWidth.Value := i;
            end;

            if Ref.AGet(WPAT_PaddingLeft,i) and
               (i=Ref.AGetDef(WPAT_PaddingRight,0)) and
               (i=Ref.AGetDef(WPAT_PaddingTop,0)) and
               (i=Ref.AGetDef(WPAT_PaddingBottom,0)) then
            begin
               veSpace.Value := i;
            end else
            if Ref.AGet(WPAT_PaddingAll,i) then // ALL!
            begin
               veSpace.Value := i;
            end;
         end;
         cbxShading.UpdateItems;
         if Ref.AGet(WPAT_FGColor,i) and (i<>0) then
               cbxShading.ItemIndex := i
         else if Ref.AGet(WPAT_BGColor,i) and (i<>0) then
               cbxShading.ItemIndex := i
         else  cbxShading.ItemIndex := 0;

         if Ref.AGet(WPAT_ShadingValue,i) then
               cpxShadingValue.Value := i;


end;

procedure TWPParagraphBord.PaintBox1Paint(Sender: TObject);
var
  TW, BT, BL, BR, BB, Space, h: Integer;
  Txt: string;
begin
  with PaintBox1.Canvas do
  begin
    Pen.Width := 1;
    Pen.Color := clBlack;
    Brush.Color := clWhite;
    FillRect(ClipRect);
    if cbxShading.ItemIndex > 0 then
    begin
      if not cpxShadingValue.Undefined then
           Brush.Color := WPShadedColor(  fsEditBox.NrToColor(cbxShading.ItemIndex),cpxShadingValue.Value)
      else Brush.Color := fsEditBox.NrToColor(cbxShading.ItemIndex);
    end;
    Pen.Color := Brush.Color;
    Font.Color := (Brush.Color and TColor($FF000000))
      + (Brush.Color xor TColor($FFFFFF));
    Font.Height := 14;
    h := TextHeight('Ag');
    Space := veSpace.Value div 20;
    Txt := '  Test  ';
    TW := TextWidth(Txt);
    BT := (PaintBox1.Height - h - (Space * 2)) div 2;
    BL := (PaintBox1.Width - TW - (Space * 2)) div 2;
    BR := (BL + TW + (Space * 2));
    BB := (BT + h + (Space * 2));
    Rectangle(BL, BT, BR, BB);
    TextOut((PaintBox1.Width - TW) div 2, BT+Space, Txt);
    if Dotted.Checked then Pen.Style := psDot
    else Pen.Style := psSolid;
   { if vePenWidth.Value = 0 then vePenWidth.Value := 20; }
    Pen.Width := vePenWidth.Value div 20;

    if btnTop.Checked then
    begin
      if btnTColor.Tag > 0 then
        Pen.Color := fsEditBox.NrToColor(btnTColor.Tag)
      else
        Pen.Color := clBlack;
      MoveTo(BL, BT);
      LineTo(BR, BT);
      if NDouble.Checked then
      begin
        MoveTo(BL - Pen.Width - 2, BT - Pen.Width - 2);
        LineTo(BR + Pen.Width + 2, BT - Pen.Width - 2);
      end;
    end;
    if btnLeft.Checked {or drBox.Checked} then
    begin
      if btnLColor.Tag > 0 then
        Pen.Color := fsEditBox.NrToColor(btnLColor.Tag)
      else
        Pen.Color := clBlack;
      MoveTo(BL, BT);
      LineTo(BL, BB);
      if NDouble.Checked then
      begin
        MoveTo(BL - Pen.Width - 2, BT - Pen.Width - 2);
        LineTo(BL - Pen.Width - 2, BB + Pen.Width + 2);
      end;
    end;
    if btnRight.Checked {or drBox.Checked} then
    begin
      if btnRColor.Tag > 0 then
        Pen.Color := fsEditBox.NrToColor(btnRColor.Tag)
      else
        Pen.Color := clBlack;
      MoveTo(BR, BT);
      LineTo(BR, BB);
      if NDouble.Checked then
      begin
        MoveTo(BR + Pen.Width + 2, BT - Pen.Width - 2);
        LineTo(BR + Pen.Width + 2, BB + Pen.Width + 2);
      end;
    end;
    if btnBottom.Checked {or drBox.Checked} then
    begin
      if btnBColor.Tag > 0 then
        Pen.Color := fsEditBox.NrToColor(btnBColor.Tag)
      else
        Pen.Color := clBlack;
      MoveTo(BL, BB);
      LineTo(BR, BB);
      if NDouble.Checked then
      begin
        MoveTo(BL - Pen.Width - 2, BB + Pen.Width + 2);
        LineTo(BR + Pen.Width + 2, BB + Pen.Width + 2);
      end;
    end;
  end;
end;

procedure TWPParagraphBord.BorderButtonsClick(Sender: TObject);
begin
 // if (btnTop.Down) and (btnLeft.Down) and (btnRight.Down) and (BtnBottom.Down) then cbxAll.Down := True;
  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TWPParagraphBord.btnOkClick(Sender: TObject);
begin
  btnUpdate.Click;
  ModalResult := mrOK;
end;

procedure TWPParagraphBord.btnUpdateClick(Sender: TObject);
var
  typ, deltyp, v: Integer;
  NeedRef: Boolean;
  CurrAttr: TWPAbstractCharParAttrInterface;
begin
  if fsEditBox <> nil then
  begin
    NeedRef := fsEditBox.ActiveText<>fsEditBox.BodyText;
    if not fsEditBox.IsSelected then
      CurrAttr := fsEditBox.CurrentCharAttr
    else CurrAttr := fsEditBox.SelectedTextAttr;
    CurrAttr.ModifyCellsOnly := TRUE; //<- for current cell
    fsEditBox.HeaderFooter.StartUndolevel;
    CurrAttr.BeginUpdate;
    try
      if (cbxShading.ItemIndex <= 0) then
      begin
        CurrAttr.ADel(WPAT_BGColor);
        CurrAttr.ADel(WPAT_FGColor);
        CurrAttr.ADel(WPAT_ShadingValue);
      end
      else
      begin
        CurrAttr.ASet(WPAT_BGColor, cbxShading.ItemIndex);
        CurrAttr.ASet(WPAT_FGColor, cbxShading.ItemIndex);
      end;

      if not cpxShadingValue.Undefined then
        CurrAttr.ASet(WPAT_ShadingValue, cpxShadingValue.Value);


      if not veSpace.Undefined then
      begin
        v := veSpace.Value;
        CurrAttr.ADel(WPAT_PaddingAll);
        CurrAttr.ASet(WPAT_PaddingRight, v);
        CurrAttr.ASet(WPAT_PaddingLeft, v);
        CurrAttr.ASet(WPAT_PaddingTop, v);
        CurrAttr.ASet(WPAT_PaddingBottom, v);
        NeedRef := TRUE;
      end;

      typ := 0;
      deltyp := 0;
      if (btnTop.State = cbChecked) {or (drBox.State=cbChecked)} then
        typ := typ + WPBRD_DRAW_Top
      else if btnTop.State = cbUnChecked then
        deltyp := deltyp + WPBRD_DRAW_Top;
      if (btnleft.State = cbChecked) {or (drBox.State=cbChecked)} then
        typ := typ + WPBRD_DRAW_LEFT
      else if btnleft.State = cbUnChecked then
        deltyp := deltyp + WPBRD_DRAW_LEFT;
      if (btnBottom.State = cbChecked) {or (drBox.State=cbChecked)} then
        typ := typ + WPBRD_DRAW_BOTTOM
      else if btnBottom.State = cbUnChecked then
        deltyp := deltyp + WPBRD_DRAW_BOTTOM;
      if (btnRight.State = cbChecked) {or (drBox.State=cbChecked)} then
        typ := typ + WPBRD_DRAW_RIGHT
      else if btnRight.State = cbUnChecked then
        deltyp := deltyp + WPBRD_DRAW_RIGHT;

      if drBox.State = cbChecked then
        typ := typ + WPBRD_DRAW_Box
      else if drBox.State = cbUnChecked then
        deltyp := deltyp + WPBRD_DRAW_Box;

      if (Dotted.State = cbUnchecked) or
        (Ndouble.State = cbUnchecked) then
      begin
        CurrAttr.ADel(WPAT_BorderType);
        CurrAttr.ADel(WPAT_BorderTypeL);
        CurrAttr.ADel(WPAT_BorderTypeT);
        CurrAttr.ADel(WPAT_BorderTypeR);
        CurrAttr.ADel(WPAT_BorderTypeB);
      end;

      if Ndouble.State = cbChecked then
        CurrAttr.ASet(WPAT_BorderType, WPBRD_DOUBLE)
      else if Dotted.State = cbChecked then
        CurrAttr.ASet(WPAT_BorderType, WPBRD_DOTTED);

      if not vePenWidth.Undefined then
      begin
        CurrAttr.ADel(WPAT_BorderWidthL);
        CurrAttr.ADel(WPAT_BorderWidthT);
        CurrAttr.ADel(WPAT_BorderWidthR);
        CurrAttr.ADel(WPAT_BorderWidthB);
        CurrAttr.ASet(WPAT_BorderWidth, vePenWidth.Value);
      end;

      if deltyp <> 0 then
      begin
        CurrAttr.ASetDel(WPAT_BorderFlags, deltyp);
      end;

      if typ <> 0 then
      begin
        CurrAttr.ASetAdd(WPAT_BorderFlags, typ);
      end;

      if (btnTColor.Tag = btnBColor.Tag) and
        (btnLColor.Tag = btnRColor.Tag) and
        (btnTColor.Tag = btnLColor.Tag) then
      begin
        if btnTColor.Tag >= 0 then
        begin
          CurrAttr.ADel(WPAT_BorderColorL);
          CurrAttr.ADel(WPAT_BorderColorT);
          CurrAttr.ADel(WPAT_BorderColorR);
          CurrAttr.ADel(WPAT_BorderColorB);
          CurrAttr.ASet(WPAT_BorderColor, btnTColor.Tag);
        end;
      end else
      begin
        if btnLColor.Tag >= 0 then CurrAttr.ASet(WPAT_BorderColorL, btnLColor.Tag);
        if btnTColor.Tag >= 0 then CurrAttr.ASet(WPAT_BorderColorT, btnTColor.Tag);
        if btnRColor.Tag >= 0 then CurrAttr.ASet(WPAT_BorderColorR, btnRColor.Tag);
        if btnBColor.Tag >= 0 then CurrAttr.ASet(WPAT_BorderColorB, btnBColor.Tag);
      end;
    finally
      CurrAttr.ModifyCellsOnly := FALSE; //<- for current cell
      CurrAttr.EndUpdate;
      fsEditBox.HeaderFooter.EndUndolevel;
      fsEditBox.Modified := TRUE;
      if NeedRef and (fsEditBox.BodyText<>nil) then
      begin
           if fsEditBox.Table <> nil then
               fsEditBox.Table.IncludeProps([paprMustInit,paprMustReformat]);
           fsEditBox.BodyText.Reformat(-1,-1);
           fsEditBox.ReformatAll(false, true);
      end
      else fsEditBox.Repaint;
      btnUndo.Visible := fsEditBox.CanUndo;
    end;
  end;
end;

procedure TWPParagraphBord.WidthSpaceChange(Sender: TObject);
begin
  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.ColorButtonClick(Sender: TObject);
var
  col: Integer;
begin
  col := (Sender as TWPToolButton).Tag;
  WPCreateColorForm(Self, Sender as TControl, fsEditBox, col);
  if col in [0..15] then
  begin
    TWPToolButton(Sender).Tag := col;
    PaintBox1.Invalidate;
  end;
end;

procedure TWPParagraphBord.cbxAllClick(Sender: TObject);
begin
  btnTop.Checked := not btnTop.Checked;
  btnLeft.Checked := btnTop.Checked;
  btnRight.Checked := btnTop.Checked;
  btnBottom.Checked := btnTop.Checked;
  PaintBox1.Invalidate;
end;

procedure TWPParagraphBord.DottedClick(Sender: TObject);
begin
  if Dotted.Checked then
  begin
    Ndouble.Checked := FALSE;
    Ndouble.State := cbGrayed;
    if (vePenWidth.Value div 20) > 1 then vePenWidth.Value := 20;
    vePenWidth.Enabled := False;
  end
  else
    vePenWidth.Enabled := True;

  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.cbxShadingChange(Sender: TObject);
begin
  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.NdoubleClick(Sender: TObject);
begin
  if Ndouble.Checked then
  begin
     Dotted.Checked := FALSE;
     Dotted.State := cbGrayed;
  end;
  PaintBox1.Invalidate; ;
end;

procedure TWPParagraphBord.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end;
end;

procedure TWPParagraphBord.WPToolButton1Click(Sender: TObject);
var
  col: Integer;
begin
  col := (Sender as TWPToolButton).Tag;
  WPCreateColorForm(Self, Sender as TControl, fsEditBox, col);
  if col in [0..15] then
  begin
    TWPToolButton(Sender).Tag := col;
    btnTColor.Tag := col;
    btnLColor.Tag := col;
    btnRColor.Tag := col;
    btnBColor.Tag := col;
    PaintBox1.Invalidate; ;
  end;
end;

procedure TWPParagraphBord.drBoxClick(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TWPParagraphBord.btnUndoClick(Sender: TObject);
begin
  fsEditBox.Undo;
  btnUndo.Visible := fsEditBox.CanUndo;
end;

procedure TWPParagraphBord.cpxShadingValueChange(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

end.

