unit WPBltStyleDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to define bullets/numbers
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{$I WPINC.INC}

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  WPCtrMemo, WPRTEDefs, WPCtrRich, WPRTEPaint,
  Forms, {$IFDEF WPXPRN} WPX_Dialogs, {$ELSE} Dialogs, {$ENDIF} StdCtrls, Buttons, ExtCtrls, WPUtil;


type
  TWPBulletStyleDialog = class(TWPShadedForm)
    labType: TLabel;
    SelectType: TComboBox;
    labTextB: TLabel;
    labTextA: TLabel;
    Label2: TLabel;
    SelectFont: TComboBox;
    EditTextB: TEdit;
    EditTextA: TEdit;
    CheckUsePrev: TCheckBox;
    btnCancel: TButton;
    btnOK: TButton;
    labIndent: TLabel;
    EditIndent: TWPValueEdit;
    ColorDialog1: TColorDialog;
    btnSelectFont: TSpeedButton;
    btnSelectSymbol: TSpeedButton;
    labFontSize: TLabel;
    cbxFontSize: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnSelectSymbolClick(Sender: TObject);
    procedure SelectFontChange(Sender: TObject);
    procedure SelectTypeChange(Sender: TObject);
    procedure btnSelectFontClick(Sender: TObject);
  private
    function GetStyle: TWPNumberStyle;
    function GetSize: Integer;
    procedure SetSize(x: Integer);
    function GetFontName: string;
    function GetFontColor: TColor;
    procedure SetFontColor(const X: TColor);
    function GetTextB: string;
    function GetTextA: string;
    function GetUsePrev: Boolean;
    function GetIndent: Integer;
    procedure SetStyle(X: TWPNumberStyle);
    procedure SetFontName(const X: string);

    procedure SetTextB(const X: string);
    procedure SetTextA(const X: string);
    procedure SetUsePrev(X: Boolean);
    procedure SetIndent(X: Integer);
  public
    function EditStyleNums(sty: TWPTextStyle): Boolean;
    property Style: TWPNumberStyle read GetStyle write SetStyle;
    property FontName: string read GetFontName write SetFontName;
    property FontSize: Integer read GetSize write SetSize;
    property FontColor: TColor read GetFontColor write SetFontColor;
    property TextB: string read GetTextB write SetTextB;
    property TextA: string read GetTextA write SetTextA;
    property UsePrev: Boolean read GetUsePrev write SetUsePrev;
    property Indent: Integer read GetIndent write SetIndent;
  end;

implementation

{$IFDEF WP6}
uses WPSymDlgEx;
{$ELSE}
uses WPSymDlg;
{$ENDIF}

{$R *.DFM}

procedure TWPBulletStyleDialog.FormCreate(Sender: TObject);
begin
  SelectFont.Items.Assign(Screen.Fonts);
  SelectFont.Items.Insert(0, '');
  SelectType.ItemIndex := 0;
  cbxFontSize.ItemIndex := -1;
end;

function TWPBulletStyleDialog.EditStyleNums(sty: TWPTextStyle): Boolean;
var i, a: Integer;
begin
  CheckUsePrev.Enabled := true;
  if sty.AGet(WPAT_NumberMODE, i) and (i <= High(WPNr_to_NumberStyle)) then
    Style := WPNr_to_NumberStyle[i]
  else Style := wp_none;
  UsePrev := sty.AGet(WPAT_NumberFLAGS, i) and ((i and WPNUM_FLAGS_USEPREV) <> 0);
  TextA := sty.ANumberToString(sty.AGetDef(WPAT_NumberTEXTA, 0));
  TextB := sty.ANumberToString(sty.AGetDef(WPAT_NumberTEXTB, 0));
  if sty.AGet(WPAT_NumberFONT, a) then
    FontName := sty.RTFProps.Fontname[a]
  else FontName := '';
  FontSize := sty.AGetDef(WPAT_NumberFONTSIZE, 0) div 100;
  if sty.AGet(WPAT_NumberFONTCOLOR, i) then
    FontColor := sty.RTFProps.ColorTable[i]
  else FontColor := clNone;
  if sty.AGet(WPAT_NumberINDENT, a) then Indent := a
  else Indent := 0;
  if ShowModal = IDOK then
  begin
    sty.ADelAllFromTo(WPAT_NumberMODE, WPAT_Number_RES3);
    if Style <> wp_none then
    begin
      sty.ASet(WPAT_NumberMODE, WPNumberStyle_to_Nr[Style]);
      if FontName <> '' then sty.ASet(WPAT_NumberFONT, sty.AStringToNumber(FontName));
      if UsePrev then sty.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_USEPREV)
      else sty.ASetDel(WPAT_NumberFLAGS, WPNUM_FLAGS_USEPREV);
      SetUsePrev(UsePrev);
      if TextA <> '' then sty.ASet(WPAT_NumberTextA, sty.AStringToNumber(TextA));
      if TextB <> '' then sty.ASet(WPAT_NumberTextB, sty.AStringToNumber(TextB));
      if FontName <> '' then sty.ASet(WPAT_NumberFont,
           sty.RTFProps.AddFontName(FontName));
      if Indent <> 0 then sty.ASet(WPAT_NumberIndent, Indent);
      if FontColor<>clNone then
         sty.ASetColor(WPAT_NumberFONTCOLOR, FontColor);
      if FontSize>0 then
         sty.ASet(WPAT_NumberFONTSIZE, FontSize * 100);
    end;
    Result := true;
  end else Result := false;
end;

function TWPBulletStyleDialog.GetStyle: TWPNumberStyle;
begin
  Result := TWPNumberStyle(SelectType.ItemIndex);
end;

function TWPBulletStyleDialog.GetSize: Integer;
begin
  if cbxFontSize.ItemIndex < 0 then Result := 0
  else Result := StrToIntDef(cbxFontSize.Text, 0);
end;

procedure TWPBulletStyleDialog.SetSize(x: Integer);
begin
  if x = 0 then cbxFontSize.Text := ''
  else cbxFontSize.Text := IntToStr(x);
end;

function TWPBulletStyleDialog.GetFontName: string;
begin
  Result := SelectFont.Text;
end;

function TWPBulletStyleDialog.GetFontColor: TColor;
begin
  Result := EditTextB.Font.Color;
end;

procedure TWPBulletStyleDialog.SetFontColor(const X: TColor);
begin
  EditTextB.Font.Color := x;
  EditTextA.Font.Color := x;
end;

function TWPBulletStyleDialog.GetTextB: string;
begin
  Result := EditTextB.Text;
end;

function TWPBulletStyleDialog.GetTextA: string;
begin
  Result := EditTextA.Text;
end;

function TWPBulletStyleDialog.GetUsePrev: Boolean;
begin
  Result := CheckUsePrev.Checked;
end;

function TWPBulletStyleDialog.GetIndent: Integer;
begin
  Result := EditIndent.Value;
end;

procedure TWPBulletStyleDialog.SetStyle(X: TWPNumberStyle);
begin
  try SelectType.ItemIndex := Integer(x); except end;
end;

procedure TWPBulletStyleDialog.SetFontName(const X: string);
var i: Integer;
begin
  if x <> '' then
  begin
    for i := 0 to SelectFont.Items.Count - 1 do
      if CompareText(SelectFont.Items[i], x) = 0 then
      begin SelectFont.ItemIndex := i; exit; end;
    SelectFont.ItemIndex := -1;
    SelectFontChange(SelectFont);
  end;
end;

procedure TWPBulletStyleDialog.SetTextB(const X: string);
begin
  EditTextB.Text := X;
end;

procedure TWPBulletStyleDialog.SetTextA(const X: string);
begin
  EditTextA.Text := X;
end;

procedure TWPBulletStyleDialog.SetUsePrev(X: Boolean);
begin
  CheckUsePrev.Checked := X;
end;

procedure TWPBulletStyleDialog.SetIndent(X: Integer);
begin
  EditIndent.Value := X;
end;

procedure TWPBulletStyleDialog.btnSelectSymbolClick(Sender: TObject);
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
    dia.FontName := FontName;
    dia.Character := '1';
    dia.NotAttachedToEditBox := TRUE;
    dia.UseOKButton := TRUE;
    if dia.Execute then
    begin
      FontName := dia.FontName;
      TextB := dia.Character;
      EditTextB.Font.Name := FontName;
    end;
  finally
    dia.Free;
  end;
end;

procedure TWPBulletStyleDialog.SelectFontChange(Sender: TObject);
begin
  if FontName <> '' then
  begin
    EditTextB.Font.Name := FontName;
    EditTextA.Font.Name := FontName;
  end else
  begin
    EditTextB.Font.Name := Font.Name;
    EditTextA.Font.Name := Font.Name;
  end;
  if (CompareText(EditTextB.Font.Name, 'Symbol') = 0) or
    (CompareText(Copy(EditTextB.Font.Name, 1, 9), 'Wingdings') = 0) or // ..1, ..2, ...
    (CompareText(EditTextB.Font.Name, 'Webdings') = 0) then
  begin
    EditTextB.Font.Charset := 2;
    EditTextA.Font.Charset := 2;
  end else
  begin
    EditTextB.Font.Charset := DEFAULT_CHARSET;
    EditTextA.Font.Charset := DEFAULT_CHARSET;
  end;
end;

procedure TWPBulletStyleDialog.SelectTypeChange(Sender: TObject);
begin
  if (SelectType.ItemIndex in [1, 2]) and
    (EditTextB.Text = '') then
    EditTextB.Text := '•';
end;

procedure TWPBulletStyleDialog.btnSelectFontClick(Sender: TObject);
begin
  ColorDialog1.Color := EditTextB.Font.Color;
  if ColorDialog1.Execute then
  begin
    EditTextB.Font.Color := ColorDialog1.Color;
    EditTextA.Font.Color := ColorDialog1.Color;
  end;
end;

end.

