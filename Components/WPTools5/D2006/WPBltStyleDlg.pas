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
     {$IFDEF WPTools5}  WPCtrMemo, WPRTEDefs, WPCtrRich, WPRTEPaint,
     {$ELSE} WPDefs, WPLabel, WPRtfIO, WPPrint, WPWinctr, WPRich, WPRtfPA, StdCtrls, WPUtil, ExtCtrls,
  Dialogs, Buttons {$ENDIF}
     Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil;


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
    procedure SetSize(x : Integer);
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
    property Style: TWPNumberStyle read GetStyle write SetStyle;
    property FontName: string read GetFontName write SetFontName;
    property FontSize : Integer read GetSize write SetSize;
    property FontColor: TColor read GetFontColor write SetFontColor;
    property TextB: string read GetTextB write SetTextB;
    property TextA: string read GetTextA write SetTextA;
    property UsePrev: Boolean read GetUsePrev write SetUsePrev;
    property Indent: Integer read GetIndent write SetIndent;
  end;

implementation

uses WPSymDlg;

{$R *.DFM}

procedure TWPBulletStyleDialog.FormCreate(Sender: TObject);
begin
  SelectFont.Items.Assign(Screen.Fonts);
  SelectFont.Items.Insert(0, '');
  SelectType.ItemIndex := 0;
  cbxFontSize.ItemIndex := -1;
end;

function TWPBulletStyleDialog.GetStyle: TWPNumberStyle;
begin
  Result := TWPNumberStyle(SelectType.ItemIndex);
end;

function TWPBulletStyleDialog.GetSize: Integer;
begin
  if cbxFontSize.ItemIndex<0 then Result := 0
  else Result := StrToIntDef(cbxFontSize.Text,0);
end;

procedure TWPBulletStyleDialog.SetSize(x : Integer);
begin
 if x=0 then cbxFontSize.Text := ''
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
var dia: TWPSymbolDlg;
begin
  dia := TWPSymbolDlg.Create(Self);
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
   if (SelectType.ItemIndex in [1,2]) and
      (EditTextB.Text='') then
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

