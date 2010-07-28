unit WP1Style;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to edit one style.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{$I WPINC.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, WPUtil, Dialogs,
  StdCtrls, Menus, WPBltDlg, WPTabdlg, WpParBrd, WpParPrp,
  ExtCtrls, WPCTRStyleCol, WPRTEDefs,
  WPCTRMemo, WPCTRRich;

type
{$IFNDEF T2H}
  TWPOneStyleDlg = class;

  TWPOneStyleDefinition = class(TWPShadedForm)
    WPParagraphPropDlg1: TWPParagraphPropDlg;
    WPParagraphBorderDlg1: TWPParagraphBorderDlg;
    WPTabDlg1: TWPTabDlg;
    WPBulletDlg1: TWPBulletDlg;
    PopupMenu1: TPopupMenu;
    ParagraphProperties1: TMenuItem;
    Borders1: TMenuItem;
    Tabstops1: TMenuItem;
    Numbers1: TMenuItem;
    ModifyEntry: TButton;
    LevelSel: TComboBox;
    labNumberLevel: TLabel;
    labBasedOn: TLabel;
    BasedOnSel: TComboBox;
    NextSel: TComboBox;
    labNextStyle: TLabel;
    labName: TLabel;
    NameEdit: TEdit;
    TemplateWP: TWPRichText;
    Bevel1: TBevel;
    Bevel2: TBevel;
    labFont: TLabel;
    Bevel3: TBevel;
    BoldCheck: TCheckBox;
    UnderCheck: TCheckBox;
    labSize: TLabel;
    ItalicCheck: TCheckBox;
    FontCombo: TComboBox;
    SizeCombo: TComboBox;
    FontColor: TComboBox;
    BKColor: TComboBox;
    labColors: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    labBold: TLabel;
    labItalic: TLabel;
    labUnderline: TLabel;
    Memo1: TMemo;
    IsOutline: TCheckBox;
    labIsOutline: TLabel;
    labKeepTextToether: TLabel;
    labKeepWithNext: TLabel;
    labIsCharacterStyle: TLabel;
    NONE_str: TLabel;
    ckOverwriteParProps: TCheckBox;
    procedure ModifyEntryClick(Sender: TObject);
    procedure Numbers1Click(Sender: TObject);
    procedure SizeComboKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FontComboChange(Sender: TObject);
    procedure SizeComboChange(Sender: TObject);
    procedure BoldCheckClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FontColorClick(Sender: TObject);
    procedure FontColorDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LevelSelChange(Sender: TObject);
    procedure IsOutlineClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    Controller: TWPOneStyleDlg;
  end;
{$ENDIF}

  TWPOneStyleDlg = class(TWPCustomAttrDlg)
  private
    dia: TWPOneStyleDefinition;
    FStyleCollection: TWPStyleCollection;
    FStyleName: string;
    FStyleBasedOn: string;
    FStyleNext: string;
    FCollection: TWPStyleCollection; // can be nil !
    FProcessUpdate, FCreateNew: Boolean;
    FOverwriteMode_Show, FOverwriteMode_Preset: Boolean;
    procedure SetStyleCollection(x: TWPStyleCollection);
  protected
    procedure SetEditBox(x: TWPCustomRtfEdit); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    FWindowLeft, FWindowTop: Integer;
    constructor Create(aOwner: TComponent); override;
    function Execute: Boolean; override;
    function CreateNewStyleDlg: Boolean;
  published
    property EditBox;
    property ProcessUpdate: Boolean read FProcessUpdate write FProcessUpdate;
    property OnShowDialog;
    property StyleCollection: TWPStyleCollection read FStyleCollection write SetStyleCollection;
    property StyleName: string read FStyleName write FStyleName;
    property StyleBasedOn: string read FStyleBasedOn write FStyleBasedOn;
    property StyleNext: string read FStyleNext write FStyleNext;
    property OverwriteMode_Show: Boolean read FOverwriteMode_Show write FOverwriteMode_Show default TRUE;
    property OverwriteMode_Preset: Boolean read FOverwriteMode_Preset write FOverwriteMode_Preset default FALSE;
  end;

procedure WPStyleOpenDialog(Form: TForm; Sender: TObject;
  DiaType: TWPCustomRtfEditDialog; var ResultValue: Boolean);

implementation

{$IFDEF WP6}
uses WPBltStyleDlg, WPSymDlgEx;
{$ELSE}
uses WPBltStyleDlg, WPSymDlg;
{$ENDIF}

{$R *.DFM}

procedure WPStyleOpenDialog(Form: TForm; Sender: TObject;
  DiaType: TWPCustomRtfEditDialog; var ResultValue: Boolean);
begin
  if DiaType = wpdiaCreateNewStyle then
  begin
    with TWPOneStyleDlg.Create(Form) do
    try
      EditBox := Sender as TWPCustomRtfEdit;
      CreateNewStyleDlg;
    finally
      Free;
    end;
    ResultValue := TRUE;
  end else
    if DiaType = wpdiaEditCurrentStyle then
    begin
      with TWPOneStyleDlg.Create(Form) do
      try
        EditBox := Sender as TWPCustomRtfEdit;
        Execute;
      finally
        Free;
      end;
      ResultValue := TRUE;
    end;
end;

constructor TWPOneStyleDlg.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FOverwriteMode_Show := TRUE;
end;

function TWPOneStyleDlg.CreateNewStyleDlg: Boolean;
begin
  FCreateNew := TRUE;
  try
    Result := Execute;
  finally
    FCreateNew := FALSE;
  end;
end;

function TWPOneStyleDlg.Execute: Boolean;
var
  aStyleC: TWPParStyle;
  aStyleR: TWPRTFStyleElement;
  aStyle2: TWPTextStyle;
  FCurrentStyle: string;
begin
  Result := FALSE;
  if FStyleCollection <> nil then
    FCollection := FStyleCollection
 // else if FEditBox <> nil then
 //   FCollection := FEditBox.WPStyleCollection as TWPStyleCollection
  else
    FCollection := nil;

  try
    dia := TWPOneStyleDefinition.Create(Self);
    dia.Controller := Self;

    if (FWindowLeft <> 0) and (FWindowTop <> 0) then
    begin
      dia.Left := FWindowLeft;
      dia.Top := FWindowTop;
    end
    else
      dia.Position := poScreenCenter;

    FCurrentStyle := FStyleName;
    if (FCurrentStyle = '') and (FEditBox <> nil) then
    begin
      FCurrentStyle := FEditBox.ActiveStyleName;
    end;

    dia.TemplateWP.Clear;
    dia.TemplateWP.BodyText.AppendPar.SetText(
      'Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd ');

    if FCollection <> nil then
    begin
      Dia.NextSel.Style := csDropDownList;
      Dia.BasedOnSel.Style := csDropDownList;
      FCollection.GetStyleList(Dia.NextSel.Items);
      FCollection.GetStyleList(Dia.BasedOnSel.Items);
      if FCollection.NumberingControlledByStyles then
        dia.TemplateWP.FormatOptionsEx :=
          dia.TemplateWP.FormatOptionsEx + [wpfNumberingControlledByStyles]
      else dia.TemplateWP.FormatOptionsEx :=
        dia.TemplateWP.FormatOptionsEx - [wpfNumberingControlledByStyles];
    end
    else if FEditBox <> nil then
    begin
      Dia.NextSel.Items.Add(FCurrentStyle);
      dia.TemplateWP.NumberStyles.Clear;
      dia.TemplateWP.NumberStyles.Assign(FEditBox.NumberStyles);
      if wpfNumberingControlledByStyles in FEditBox.FormatOptionsEx then
        dia.TemplateWP.FormatOptionsEx :=
          dia.TemplateWP.FormatOptionsEx + [wpfNumberingControlledByStyles]
      else dia.TemplateWP.FormatOptionsEx :=
        dia.TemplateWP.FormatOptionsEx - [wpfNumberingControlledByStyles];
      FEditBox.ParStyles.GetStringList(Dia.NextSel.Items);
      FEditBox.ParStyles.GetStringList(Dia.BasedOnSel.Items);
    end;

    // use the first paragraph in as style 'TemplateWP'
    if FCreateNew then FCurrentStyle := '';
    dia.ckOverwriteParProps.Visible := OverwriteMode_Show;
    dia.ckOverwriteParProps.Checked := OverwriteMode_Preset;

    aStyle2 := dia.TemplateWP.FirstPar;

    if FCollection <> nil then
    begin
      aStyleC := FCollection.Find(FCurrentStyle);
      aStyleR := nil;
      if aStyleC = nil then
      begin
        dia.NameEdit.Text := WPLoadStr(meNewStyleName);
        dia.NextSel.Text := '';
        aStyle2.ClearCharAttributes;
      end
      else
      begin
        dia.BasedOnSel.Text := aStyleC.BasedOnStyle;
        dia.NextSel.Text := aStyleC.NextStyle;
        dia.NameEdit.Text := FCurrentStyle;
        aStyle2.ASetAsINI(
          aStyleC.Values,
          [wpINI_CharAttr,
            wpINI_ParAttr,
            wpINI_Borders,
            wpINI_ParSpecial,
            wpINI_Tabstops]
          );
      end;
    end
    else if FEditBox <> nil then
    begin
      aStyleR := FEditBox.ParStyles.FindStyle(FCurrentStyle);
      aStyleC := nil;
      if aStyleR = nil then
      begin
        dia.NameEdit.Text := WPLoadStr(meNewStyleName);
        dia.NextSel.Text := '';
        aStyle2.ClearCharAttributes;
      end
      else
      begin
        dia.BasedOnSel.Text := aStyleR.TextStyle.ABaseStyleName;
        dia.NextSel.Text := aStyleR.NextStyleName;
        dia.NameEdit.Text := FCurrentStyle;
        aStyle2.Assign(aStyleR.TextStyle);
      end;
    end else
      raise Exception.Create('Please assign EditBox');

    dia.btnOk.Enabled := (aStyleC <> nil) or (aStyleR <> nil);

    // Show the dialog
    if not FCreateAndFreeDialog
      and MayOpenDialog(dia)
      then
    begin
      if (dia.ShowModal = mrOK) and (dia.NameEdit.Text <> '') then
      begin
        Result := TRUE;
        FCurrentStyle := dia.NameEdit.Text;

        if (aStyleC = nil) and (FCollection <> nil) and (dia.NameEdit.Text <> WPLoadStr(meNewStyleName)) then
        begin
          aStyleC := FCollection.Add(dia.NameEdit.Text);
        end;
        if (aStyleR = nil) and (FEditBox <> nil) and (dia.NameEdit.Text <> WPLoadStr(meNewStyleName)) then
        begin
          aStyleR := FEditBox.ParStyles.Add(dia.NameEdit.Text);
        end;

        if FEditBox <> nil then
        begin
          FEditBox.NumberStyles.Assign(dia.TemplateWP.NumberStyles);
        end;

        if aStyleC <> nil then
        begin
          // First change the name!
          aStyleC.Name := dia.NameEdit.Text;
          // Then get ATTR
          aStyle2.AGetAsINI(
            aStyleC.Values,
            [wpINI_CharAttr,
            wpINI_ParAttr,
              wpINI_Borders,
              wpINI_ParSpecial,
              wpINI_Tabstops]);
          aStyleC.NextStyle := dia.NextSel.Text;
          aStyleC.BasedOnStyle := dia.BasedOnSel.Text;
        end else
          if aStyleR <> nil then
          begin
            aStyleR.TextStyle.Assign(aStyle2);
            aStyleR.Name := dia.NameEdit.Text;
            aStyleR.NextStyleName := dia.NextSel.Text;
            aStyleR.TextStyle.ABaseStyleName := dia.BasedOnSel.Text;
          end;

        if FEditBox <> nil then
        begin
          FEditBox.ActiveStyleName := dia.NameEdit.Text;

          if dia.ckOverwriteParProps.Checked then
            FEditBox.ParStyleNormalizePar(dia.NameEdit.Text)
          else FEditBox.ParStyleMarkForReformat(dia.NameEdit.Text);

          FEditBox.Invalidate;
          FEditBox.SetFocusValues(true);
        end;
      end;
    end;
  finally
    dia.Free;
  end;
end;

{ -------------------------------------------------------------------------- }

procedure TWPOneStyleDlg.SetStyleCollection(x: TWPStyleCollection);
begin
  FStyleCollection := x;
  if FStyleCollection <> nil then
  begin
    FStyleCollection.FreeNotification(Self);
    FEditBox := nil;
  end;
end;


procedure TWPOneStyleDlg.SetEditBox(x: TWPCustomRtfEdit);
begin
  inherited SetEditBox(x);
  if EditBox <> nil then FStyleCollection := nil;
end;

procedure TWPOneStyleDlg.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FStyleCollection) then FStyleCollection := nil;
  inherited Notification(AComponent, Operation);
end;



{ -------------------------------------------------------------------------- }

procedure TWPOneStyleDefinition.ModifyEntryClick(Sender: TObject);
var
  p: TPoint;
begin
  p := ModifyEntry.ClientToScreen(Point(0, ModifyEntry.Height));
  PopupMenu1.Popup(p.x, p.y);
end;

procedure TWPOneStyleDefinition.Numbers1Click(Sender: TObject);
var dia: TWPBulletStyleDialog;
begin
  case (Sender as TMenuItem).Tag of
    1: WPParagraphPropDlg1.Execute;
    3: WPParagraphBorderDlg1.Execute;
    4: WPTabDlg1.Execute;
    5: if not (wpfNumberingControlledByStyles in TemplateWP.FormatOptionsEx) then
        WPBulletDlg1.Execute
      else
      begin
        dia := TWPBulletStyleDialog.Create(Self);
        try
          dia.EditStyleNums(TemplateWP.FirstPar);
        finally
          dia.Free;
        end;
      end;
  end;
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.SizeComboKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in [',', '.', '0'..'9']) and not (Key = #8) then Key := #0;
end;

procedure TWPOneStyleDefinition.FormCreate(Sender: TObject);
begin
  FontCombo.Items.Assign(Screen.Fonts);
  WPBulletDlg1.DontEditOutline := TRUE;
  TemplateWP.ViewOptions := TemplateWP.ViewOptions - [wpNoEndOfDocumentLine];
{$IFNDEF STY_DONTHIDETAB}
  Tabstops1.Visible := FALSE;
{$ENDIF}
end;

procedure TWPOneStyleDefinition.FontComboChange(Sender: TObject);
begin
  TemplateWP.CPPosition := 0;
  if FontCombo.Text = '' then
    TemplateWP.FirstPar.ADel(WPAT_CharFont)
  else
    TemplateWP.FirstPar.ASetFontName(FontCombo.Text);
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.LevelSelChange(Sender: TObject);
begin
  TemplateWP.CPPosition := 0;
  if LevelSel.ItemIndex <= 0 then
    TemplateWP.FirstPar.ADel(WPAT_NumberLEVEL)
  else TemplateWP.FirstPar.ASet(WPAT_NumberLEVEL, LevelSel.ItemIndex);
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.IsOutlineClick(Sender: TObject);
begin
  if IsOutline.Checked then
    TemplateWP.FirstPar.ASet(WPAT_ParIsOutline, 1)
  else TemplateWP.FirstPar.ADel(WPAT_ParIsOutline);
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.SizeComboChange(Sender: TObject);
begin
  TemplateWP.CPPosition := 0;
  if SizeCombo.Text = '' then
    TemplateWP.FirstPar.ADel(WPAT_CharFontSize)
  else TemplateWP.FirstPar.ASet(
      WPAT_CharFontSize, Round(StrToFloat(SizeCombo.Text) * 100));
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.BoldCheckClick(Sender: TObject);
const
  AttrCheck: array[0..2] of Integer = (WPSTY_BOLD, WPSTY_ITALIC, WPSTY_UNDERLINE);
begin
  TemplateWP.FirstPar.ASetCharStyle(
    WPCheckBoxStateToThreeState[(Sender as TCheckBox).State],
    AttrCheck[(Sender as TCheckBox).Tag]);
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.FormShow(Sender: TObject);
var i: Integer;
  par: TParagraph;
begin
  LevelSel.Items[0] := NONE_str.Caption;
  par := TemplateWP.FirstPar;

  BoldCheck.State := WPThreeStatetoCheckBoxState[par.AGetCharStyle(WPSTY_BOLD)];
  ItalicCheck.State := WPThreeStatetoCheckBoxState[par.AGetCharStyle(WPSTY_ITALIC)];
  UnderCheck.State := WPThreeStatetoCheckBoxState[par.AGetCharStyle(WPSTY_UNDERLINE)];

  if par.AGet(WPAT_CharFontSize, i) then
    SizeCombo.Text := FloatToStr(i / 100)
  else SizeCombo.Text := '';

  FontCombo.ItemIndex := FontCombo.Items.IndexOf(par.AGetFontName);

  if par.AGet(WPAT_CharColor, i) then
    FontColor.ItemIndex := FontColor.Items.Add(
      ColorToString(par.AGetColor(WPAT_CharColor)))
  else FontColor.ItemIndex := -1;

  if par.AGet(WPAT_CharBGColor, i) then
    BKColor.ItemIndex := BKColor.Items.Add(
      ColorToString(par.AGetColor(WPAT_CharBGColor)))
  else BKColor.ItemIndex := -1;

  if par.AGet(WPAT_ParIsOutline, i) and (i > 0) then
    IsOutline.Checked := TRUE;

  if par.AGet(WPAT_NumberLevel, i) and (i > 0) and (i <= 9) then
  begin
    LevelSel.ItemIndex := i;
  end;




  // We want to see a preview
//   WPStyleCollection1.AssignStyle(TemplateWP, NameEdit.Text, true);
  // Now we read the values - but we use the TextStyle and not the text
(*  txtstyle := TemplateWP.Memo.GetStyleForName(NameEdit.Text);
  pa := @(txtstyle.data.Attr); //V4.11f was: TemplateWP.FirstPar^.line^.pa;
  if afsParStyleFont in pa^.style then
    FontCombo.ItemIndex := FontCombo.Items.IndexOf(TemplateWP.GetFontName(pa^.Font));
  if afsParStyleSize in pa^.style then
    SizeCombo.Text := IntToStr(pa^.Size);
  if afsParStyleBold in pa^.style then
    BoldCheck.State := state[afsBold in pa^.Style];
  if afsParStyleItalic in pa^.style then
    ItalicCheck.State := state[afsItalic in pa^.Style];
  if afsParStyleUnderline in pa^.style then
    UnderCheck.State := state[afsUnderline in pa^.Style];
  if afsParStyleColor in pa^.style then
    FontColor.ItemIndex := FontColor.Items.Add(ColorToString(TemplateWP.CurrAttr.NrToColor(pa^.Color)));
  if afsParStyleBGColor in pa^.style then
    BKColor.ItemIndex := BKColor.Items.Add(ColorToString(TemplateWP.CurrAttr.NrToColor(pa^.BGColor)));
  IsOutline.Checked := paprIsOutline in TemplateWP.FirstPar^.prop;
  if TemplateWP.FirstPar^.numlevel = 0 then
    LevelSel.ItemIndex := -1
  else
    LevelSel.ItemIndex := TemplateWP.FirstPar^.numlevel mod 9;   *)
end;

procedure TWPOneStyleDefinition.FontColorClick(Sender: TObject);
var
  col: TColor; s: string;
begin
  s := (Sender as TComboBox).Text;
  if s = '' then
  begin
    if Sender = FontColor then TemplateWP.FirstPar.ADel(WPAT_CharColor)
    else TemplateWP.FirstPar.ADel(WPAT_CharBGColor);
  end
  else
  begin
    col := StringToColor(s);
    if Sender = FontColor then
      TemplateWP.FirstPar.ASetColor(WPAT_CharColor, col)
    else
      TemplateWP.FirstPar.ASetColor(WPAT_CharBGColor, col);
  end;
  TemplateWP.ReformatAll(true, true);
end;

procedure TWPOneStyleDefinition.FontColorDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  col: TColor; i: Integer;
begin
  try
    col := StringToColor((Control as TComboBox).Items.Strings[Index]);
  except
    col := clWindow;
  end;
  if Index = 0 then
  begin
  end
  else
    TComboBox(Control).Canvas.Brush.Color := col;
  TComboBox(Control).Canvas.Pen.Color := clBlack;
  TComboBox(Control).Canvas.Pen.Style := psSolid;
  TComboBox(Control).Canvas.Pen.Width := 1;
  TComboBox(Control).Canvas.FillRect(Rect);
  TComboBox(Control).Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  if Control = BKColor then
  begin
    i := (Rect.Bottom - Rect.Top) div 3;
    TComboBox(Control).Canvas.MoveTo(Rect.Left, Rect.Top + i - 1);
    TComboBox(Control).Canvas.LineTo(Rect.Right, Rect.Top + i - 1);
    TComboBox(Control).Canvas.MoveTo(Rect.Left, Rect.Top + i * 2);
    TComboBox(Control).Canvas.LineTo(Rect.Right, Rect.Top + i * 2);
  end;
end;


procedure TWPOneStyleDefinition.NameEditChange(Sender: TObject);
begin
  btnOk.Enabled := (Trim(NameEdit.Text) <> '') and
    (NameEdit.Text <> WPLoadStr(meNewStyleName));
end;

procedure TWPOneStyleDefinition.Memo1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssCtrl in Shift then
    Memo1.Text := TemplateWP.FirstPar.AGetWPSS(true, true, true, false, false);
end;

end.

