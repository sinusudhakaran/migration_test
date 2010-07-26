unit WPSymDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH    
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  Show a Symboldialog
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{$I WPINC.INC}
{$DEFINE USEENUMF}//Load current list, maybe we have loaded new fonts ?

interface

uses Windows,  SysUtils, Messages, Classes, Graphics, Controls,
     Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,Math,
     WPUtil, WPCTRRich, WPCtrMemo, WPRTEDefs;

type
   {$IFNDEF T2H}
   TWPSymbolDialog = class(TWPShadedForm)
    labFont: TLabel;
    CharacterGrid: TStringGrid;
    Panel1: TPanel;
    CharCode: TLabel;
    Bevel2: TBevel;
    PaintBox1: TPaintBox;
    cbxFontList: TComboBox;
    OKButton: TButton;
    btnCancel: TButton;
    procedure cbxFontListChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CharacterGridClick(Sender: TObject);
    procedure CharacterGridMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OKButtonClick(Sender: TObject);
    procedure CharacterGridDblClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    fsEditBox : TWPCustomRtfEdit;
    // RtfText   : TWPRtfTextPaint;
    FCol,FRow : Integer;
    aCharset : Integer;
    FDontTakeNext,FModified : Boolean;
    FFontName, FCharacter : String;
    procedure Insert;
  end;
  {$ENDIF}

  TWPSymbolDlg = class(TWPCustomAttrDlg)
  private
    dia      : TWPSymbolDialog;
    FShowOKButton : Boolean;
    FNotAttachedToEditBox : Boolean;
  public
    FontName, Character : String;
    function Execute : Boolean; override;
    constructor Create(aOwner : TComponent); override;
  published
    property EditBox;
    property UseOKButton : Boolean read FShowOKButton write FShowOKButton;
    property NotAttachedToEditBox : Boolean read FNotAttachedToEditBox write FNotAttachedToEditBox;
  end;

implementation

var SymDlgWidth, SymDlgHeight : Integer;

{$R *.DFM}
constructor TWPSymbolDlg.Create(aOwner : TComponent);
begin
   inherited Create(aOwner);
   FontName := 'Arial';
end;

function TWPSymbolDlg.Execute : Boolean;
var f : TFontName;  c : Integer;
begin
  Result := FALSE;
  if FNotAttachedToEditBox or (assignedActiveRTFEdit(FEditBox) and Changing) then
    begin
      dia := TWPSymbolDialog.Create(Self);
      try
        dia.OKButton.Visible  := FNotAttachedToEditBox or FShowOKButton;
        dia.Panel1.Align := alNone;
        dia.BorderIcons := [biMaximize];
        if FNotAttachedToEditBox then
        begin
             dia.aCharset := 1;
             // dia.RtfText := nil;
             dia.fsEditBox := nil;
             dia.FCharacter := Character;
             dia.FFontName := FontName;
             if dia.ShowModal=mrOK then
             begin
                Result := TRUE;
                Character := dia.FCharacter;
                FontName := dia.FFontName;
             end;
        end else
        begin
             // dia.RtfText           := (ActiveRTFEdit(FEditBox).RtfText as TWPRtfTextPaint);
             dia.fsEditBox         := ActiveRTFEdit(FEditBox);
             dia.fsEditBox.PushAttr;

             if dia.fsEditBox.WritingAttr.GetFontName(f) then
                  dia.FFontName := f
             else dia.FFontName := dia.fsEditBox.CPAttr.FontName;

             if dia.fsEditBox.WritingAttr.GetFontCharset(c) then
                  dia.aCharset := c
             else dia.aCharset  := dia.fsEditBox.CPAttr.CharSet;; // WAS: ActiveRTFEdit(FEditBox).Header.FontCharset[a.Font];

             if dia.FFontName='' then
             begin
               dia.FFontName := 'Wingdings';
               dia.aCharset  := 2;
             end;

             if not FCreateAndFreeDialog  and MayOpenDialog(dia) then
             begin
                  //was: dia.RtfText.AlwaysNewUndolevel;
                  //TODO

                  if (dia.ShowModal=mrCancel) and dia.FModified then dia.fsEditBox.Undo
                  else begin
                      //was: dia.RtfText.AlwaysNewUndolevel;
                  end;
                  Result := TRUE;
             end;
             dia.fsEditBox.PopAttr;
             //debug: dia.fsEditBox.InputString('more');
        end;
      finally
        dia.Free;
      end;
    end;
end;

procedure TWPSymbolDialog.FormActivate(Sender: TObject);
var
  i : Integer;
  s : string;
begin
  if fsEditBox=nil then
       s := FFontName
  else
  begin
    s := fsEditBox.CPAttr.FontName;
    if s='' then s := FFontName
  end;
  for I := 0 to cbxFontList.Items.Count do
    if CompareText(cbxFontList.Items.Strings[i], s)=0 then
      begin
        cbxFontList.ItemIndex := I;
        Break;
      end;

  CharacterGrid.Font.Name    := s;
  CharacterGrid.Font.CharSet := DEFAULT_CHARSET	; // aCharset;
  cbxFontListChange(Sender);
end;

procedure TWPSymbolDialog.cbxFontListChange(Sender: TObject);
var
  i:	Integer;
  j:	Integer;
begin
  CharacterGrid.Font.Name := cbxFontList.Text;
  CharacterGrid.Font.CharSet := DEFAULT_CHARSET	; // aCharset;
  for j := 0 to 6 do
    for i := 0 to 31 do
      CharacterGrid.Cells[i, j] := Chr(i + (32 * (j + 1)));

  cbxFontList.SetFocus;
end;

procedure TWPSymbolDialog.Insert;
var
  TheSelection: TGridRect;
begin
  if fsEditBox<>nil then
  begin
     fsEditBox.SetFocus;
     // fsEditBox.CurrAttr.FontName := FFontName;
     fsEditBox.Memo.Cursor.WritingTextAttr.SetFontName(FFontName);
     TheSelection := CharacterGrid.Selection;
     fsEditBox.InputString(FCharacter);
     FModified := TRUE;
     fsEditBox.Refresh;
  end;
end;

procedure TWPSymbolDialog.CharacterGridClick(Sender: TObject);
var
  c,r : Longint;
begin
  FDontTakeNext := FALSE;
  c := CharacterGrid.Col;
  r := CharacterGrid.Row;
  if ((c<>FCol) or (r<>Frow) or not PaintBox1.Visible) then
  begin
     if c>=0 then FCol := c;
     if r>=0 then Frow := r;
     PaintBox1.Visible := TRUE;
     PaintBox1.Invalidate;
  end;
  if not OKButton.Visible then
  begin
    Insert;
    ModalResult   := mrOK;
  end;
end;

procedure TWPSymbolDialog.CharacterGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  c,r : Longint;
begin
  if not OKButton.Visible then
  begin
    CharacterGrid.MouseToCell(x,y, c,r);
    if ((c<>FCol) or (r<>Frow) or not PaintBox1.Visible) then
    begin
     if c>=0 then FCol := c;
     if r>=0 then Frow := r;
     PaintBox1.Visible := TRUE;
     PaintBox1.Invalidate;
    end;
  end;
end;

procedure TWPSymbolDialog.PaintBox1Paint(Sender: TObject);
begin
  FFontName := CharacterGrid.Font.Name;
  FCharacter := CharacterGrid.Cells[FCol, FRow];
  with PaintBox1.Canvas do
  begin
    Font.Name := CharacterGrid.Font.Name;
    Font.Height := PaintBox1.Height - 2;
    TextOut(0,0,FCharacter);
  end;
  CharCode.Caption := IntToStr(Integer(CharacterGrid.Cells[FCol, FRow][1]));
end;

procedure TWPSymbolDialog.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if not OKButton.Visible then
      PaintBox1.Visible := FALSE;
end;


procedure TWPSymbolDialog.OKButtonClick(Sender: TObject);
begin
  if not FDontTakeNext or OKButton.Visible then
  begin
    Insert;
  end;
  ModalResult := mrOK;
end;

procedure TWPSymbolDialog.CharacterGridDblClick(Sender: TObject);
begin
  Insert;
  FDontTakeNext := TRUE;
  if not OKButton.Visible then ModalResult := mrOk;
end;

procedure TWPSymbolDialog.btnCancelClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TWPSymbolDialog.FormResize(Sender: TObject);
var i, a,b : Integer;
begin
  CharacterGrid.Width := ClientWidth - CharacterGrid.Left-4-Panel1.Width;
  CharacterGrid.Height := ClientHeight - CharacterGrid.Top-4;
  a := CharacterGrid.Width div (CharacterGrid.ColCount+1);
  for i:=0 to CharacterGrid.ColCount-1 do
    CharacterGrid.ColWidths[i]:=a;
  b := CharacterGrid.Height div (CharacterGrid.RowCount+1);
  for i:=0 to CharacterGrid.RowCount-1 do
    CharacterGrid.RowHeights[i]:=b;
  if a<b then
     CharacterGrid.Font.Height := -a-2
  else
     CharacterGrid.Font.Height := -b-2;
  Panel1.Left := ClientWidth - Panel1.Width;

end;

procedure TWPSymbolDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SymDlgWidth := Width;
  SymDlgHeight:= Height;
end;

procedure TWPSymbolDialog.FormShow(Sender: TObject);
begin
  if SymDlgWidth>50  then Width := SymDlgWidth;
  if SymDlgHeight>50 then Height := SymDlgHeight;
end;

{$IFDEF USEENUMF}
function EnumFont(var lp: TEnumLogFont;
  var tm: TNewTextMetric;
  dwType: DWORD;
  lpData: lParam): Integer; stdcall;
begin
  Result := 1;
  with TWPSymbolDialog(lpData), cbxFontList do
  begin
    Items.Add(lp.elfLogFont.lfFaceName);
  end;
end;
{$ENDIF}

procedure TWPSymbolDialog.FormCreate(Sender: TObject);
begin
  {$IFDEF USEENUMF}
   cbxFontList.Items.Clear;
   EnumFontFamilies(Canvas.Handle, nil, @EnumFont, Integer(Self));
  {$ELSE}
   cbxFontList.Items := Screen.Fonts;
  {$ENDIF}
end;

end.
