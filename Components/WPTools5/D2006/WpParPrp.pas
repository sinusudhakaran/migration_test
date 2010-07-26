unit WpParPrp;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2004 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to change indent and spacing
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{ Paragraph properties - This unit used to work for WPTools 4. WPTools 5 offers
  optimized access to paragraph properties and this unit has been optimized to
  support those. Please see the source of this unit to compare the 'old' and
  the 'new' code }

{$I WPINC.INC}

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
{$IFDEF WPTools5}WPCtrMemo, WPRTEDefs, WPCtrRich, WPRTEPaint,
{$ELSE}WPDefs, WPLabel, WPRtfIO, WPPrint, WPWinctr, WPRich, WPRtfPA, StdCtrls, WPUtil, ExtCtrls{$ENDIF}
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil;

type
{$IFNDEF T2H}
  TWPParagraphProp = class(TWPShadedForm)
    labFirst: TLabel;
    labLeft: TLabel;
    labRight: TLabel;
    labBefore: TLabel;
    labLinespacing: TLabel;
    labAfter: TLabel;
    Bevel1: TBevel;
    FirstIndent: TWPValueEdit;
    LeftIndent: TWPValueEdit;
    RightIndent: TWPValueEdit;
    SpacingBefore: TWPValueEdit;
    SpacingAfter: TWPValueEdit;
    SpacingBetween: TWPValueEdit;
    labAlignment: TLabel;
    labIndent: TLabel;
    labSpacing: TLabel;
    Bevel2: TBevel;
    SpacingType: TComboBox;
    labValue: TLabel;
    Bevel3: TBevel;
    ButOK: TButton;
    ButCancel: TButton;
    ButUpdate: TButton;
    cbxAlignment: TComboBox;
    RichBevel: TBevel;
    ButOpenTabs: TButton;
    Label1: TLabel;
    cbxOutlineLevel: TComboBox;
    procedure FormActivate(Sender: TObject);
    procedure SpacingBetweenUnitChange(Sender: TObject);
    procedure ButUpdateClick(Sender: TObject);
    procedure ButOKClick(Sender: TObject);
    procedure SpacingTypeClick(Sender: TObject);
    procedure UpdateExample(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure ButOpenTabsClick(Sender: TObject);
  public
    WPRichText1: TWPCustomRtfEdit; // The preview
    FOnEditTabsClick: TNotifyEvent;
{$IFDEF WPTools5}
    fsEditBox: TWPCustomRtfEdit;
    FDemoPar: TParagraph; // This paragraph is our 'demo' paragraph in the little preview editor
{$ELSE}
  //  RtfText   : TWPRtfTextPaint; // Does not exit in WPTools 5
{$ENDIF}
  end;
{$ENDIF}

  TWPParagraphPropDlg = class(TWPCustomAttrDlg)
  private
    dia: TWPParagraphProp;
    FAutoUpdate: Boolean;
    FOnEditTabsClick: TNotifyEvent;
  public
    function Execute: Boolean; override;
  published
    property EditBox;
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate;
    property OnEditTabsClick: TNotifyEvent read FOnEditTabsClick write FOnEditTabsClick;
  end;

implementation

{$R *.DFM}

function TWPParagraphPropDlg.Execute: Boolean;
begin
  Result := FALSE;
  if assignedActiveRTFEdit(FEditBox) and Changing then
    try
      dia := TWPParagraphProp.Create(Self);

      if not Assigned(FOnEditTabsClick) then
      begin
        dia.FOnEditTabsClick := FOnEditTabsClick;
        dia.ButUpdate.Left := dia.ButOpenTabs.Left;
        dia.ButOpenTabs.Visible := FALSE;
      end;

{$IFNDEF WPTOOLS5}
   {  dia.RtfText := (ActiveRTFEdit(FEditBox).RtfText as TWPRtfTextPaint);

     if paprIsTable in dia.RtfText.active_paragraph^.prop then
     begin
       dia.SpacingAfter.Visible := FALSE;
       dia.labAfter.Visible := FALSE;
       dia.labBefore.Caption :=  dia.labBefore.Caption + '/' + dia.labAfter.Caption;
     end;  }
{$ENDIF}

      dia.fsEditBox := ActiveRTFEdit(FEditBox);
      dia.SpacingType.Items.Clear;
      dia.SpacingType.Items.Add('');
      dia.SpacingType.Items.Add(WPLoadStr(meSpacingMultiple));
      dia.SpacingType.Items.Add(WPLoadStr(meSpacingAtLeast));
      dia.SpacingType.Items.Add(WPLoadStr(meSpacingExact));

      with dia.cbxAlignment do
      begin
        Items.Clear;
        Items.Add('');
        Items.Add(WPLoadStr(meDiaAlLeft));
        Items.Add(WPLoadStr(meDiaAlCenter));
        Items.Add(WPLoadStr(meDiaAlRight));
        Items.Add(WPLoadStr(meDiaAlJustified));
      end;

      if FAutoUpdate then dia.ButUpdate.Visible := False;
      dia.WPRichText1.Clear;
      dia.WPRichText1.LayoutMode := wplayNormal;

     // Fill the preview
      dia.WPRichText1.ActiveParagraph.ASet(WPAT_CharFontSize, 650); // 6.5pt
      dia.WPRichText1.Header.LeftMargin := 0;
      dia.WPRichText1.Header.RightMargin := 0;
      dia.WPRichText1.Header.PageWidth := 4500;
      dia.WPRichText1.Memo.RTFData.DefaultAttr.Clear; // SetFontSize(6.5);
      dia.WPRichText1.InputString('Aaa bbb ccc ddd eee aaa bbb ccc ddd.');
      dia.WPRichText1.InputString(#13);
      dia.FDemoPar := dia.WPRichText1.ActiveParagraph;
      dia.WPRichText1.ActiveParagraph.ASetColor(WPAT_BGColor, $E5E0E0);
      dia.WPRichText1.InputString('Aaaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd eee aaa bbb ccc ddd.');
      dia.WPRichText1.InputString(#13);
      dia.WPRichText1.ActiveParagraph.ADel(WPAT_BGColor);
      dia.WPRichText1.InputString('Eee aaa bbb ccc ddd eee aaa bbb ccc.');

    { par := ActiveRTFEdit(FEditBox).Memo.active_paragraph;
     lin := ActiveRTFEdit(FEditBox).Memo.active_line;
     cp  :=  ActiveRTFEdit(FEditBox).Memo.cursor_pos;
     for i:=0 to 5 do
     begin
        if not dia.WPRichText1.FastAppendActiveLine( dia.fsEditBox ) then break;
     end;
     dia.WPRichText1.Memo.FastAppendText( dia.WPRtfStorage1.RTFText.FirstPar, nil );
     dia.WPRichText1.Refresh;
     ActiveRTFEdit(FEditBox).Memo.active_paragraph := par;
     ActiveRTFEdit(FEditBox).Memo.active_line := lin;
     ActiveRTFEdit(FEditBox).Memo.cursor_pos := cp;  }
      if not FCreateAndFreeDialog and MayOpenDialog(dia) and (dia.ShowModal = IDOK) then Result := TRUE
      else ActiveRTFEdit(FEditBox).Modified := FOldModified;
    finally
      dia.Free;
    end;
end;

procedure TWPParagraphProp.FormActivate(Sender: TObject);
var
  val: Integer;
  par: TParagraph;
begin
  FirstIndent.AllowNegative := TRUE;
  FirstIndent.UnitType := GlobalValueUnit;
  LeftIndent.UnitType := GlobalValueUnit;
  RightIndent.UnitType := GlobalValueUnit;
  SpacingBefore.UnitType := GlobalValueUnit;
  SpacingAfter.UnitType := GlobalValueUnit;
  SpacingBetween.UnitType := GlobalValueUnit;

  FirstIndent.AllowUndefined := TRUE;
  LeftIndent.AllowUndefined := TRUE;
  RightIndent.AllowUndefined := TRUE;
  SpacingBefore.AllowUndefined := TRUE;
  SpacingAfter.AllowUndefined := TRUE;
  SpacingBetween.AllowUndefined := TRUE;

{$IFDEF WPTOOLS5}
  if not fsEditBox.IsSelected then
    par := fsEditBox.ActiveParagraph
  else par := nil;


  if fsEditBox.AGet(WPAT_IndentFirst, val) then
    FirstIndent.Value := val
  else
  begin
    if par <> nil then
      FirstIndent.UndefinedValue := par.AGetDefInherited(WPAT_IndentFirst, 0)
    else FirstIndent.Undefined := TRUE;
  end;
  if fsEditBox.AGet(WPAT_IndentLeft, val) then
    LeftIndent.Value := val
  else
  begin
    if par <> nil then
      LeftIndent.UndefinedValue := par.AGetDefInherited(WPAT_IndentLeft, 0)
    else LeftIndent.Undefined := TRUE;
  end;
  if fsEditBox.AGet(WPAT_IndentRight, val) then
    RightIndent.Value := val
  else
  begin
    if par <> nil then
      RightIndent.UndefinedValue := par.AGetDefInherited(WPAT_IndentRight, 0)
    else RightIndent.Undefined := TRUE;
  end;

  if fsEditBox.AGet(WPAT_SpaceBefore, val) then
    SpacingBefore.Value := val
  else
  begin
    if par <> nil then
      SpacingBefore.UndefinedValue := par.AGetDefInherited(WPAT_SpaceBefore, 0)
    else SpacingBefore.Undefined := TRUE;
  end;

  if fsEditBox.AGet(WPAT_SpaceAfter, val) then
    SpacingAfter.Value := val
  else
  begin
    if par <> nil then
      SpacingAfter.UndefinedValue := par.AGetDefInherited(WPAT_SpaceAfter, 0)
    else SpacingAfter.Undefined := TRUE;
  end;

  if fsEditBox.AGet(WPAT_LineHeight, val) then
  begin
    SpacingType.ItemIndex := 1;
    SpacingBetween.UnitType := euMultiple;
    SpacingBetween.Value := MulDiv(val, 240, 100);
  end
  else if fsEditBox.AGet(WPAT_SpaceBetween, val) then
  begin
    if val < 0 then
    begin
      SpacingType.ItemIndex := 3;
      SpacingBetween.Value := -val;
    end
    else
    begin
      SpacingType.ItemIndex := 2;
      SpacingBetween.Value := val;
    end;
  end else
  begin
    if par <> nil then
    begin
      if par.AGetInherited(WPAT_LineHeight, val) then
      begin
        SpacingType.ItemIndex := 1;
        SpacingBetween.UnitType := euMultiple;
        SpacingBetween.UndefinedValue := MulDiv(val, 240, 100);
      end
      else if par.AGetInherited(WPAT_SpaceBetween, val) then
      begin
        if val < 0 then
        begin
          SpacingType.ItemIndex := 3;
          SpacingBetween.UndefinedValue := -val;
        end
        else
        begin
          SpacingType.ItemIndex := 2;
          SpacingBetween.UndefinedValue := val;
        end;
      end
      else
      begin
        SpacingType.ItemIndex := 1;
        SpacingBetween.UnitType := euMultiple;
        SpacingBetween.UndefinedValue := 1;
      end;
    end else
    begin
      SpacingType.ItemIndex := -1;
      SpacingBetween.Undefined := TRUE;
    end;
  end;
  if fsEditBox.AGet(WPAT_Alignment, val) then
    cbxAlignment.ItemIndex := val + 1
  else
  begin
    if par <> nil then
      val := par.AGetDefInherited(WPAT_Alignment, 0) + 1
    else val := -1;
      // cbxAlignment.Undefined := TRUE;
    cbxAlignment.ItemIndex := val;
  end; 


  // note: WPAT_OUTLINELEVEL and WPAT_NUMBERLEVEL is the same!
  if fsEditBox.AGet(WPAT_OUTLINELEVEL, val) then
    cbxOutlineLevel.ItemIndex := val
  else cbxOutlineLevel.ItemIndex := -1;

{$ELSE}
  { WPTools 4 code:
  FirstIndent.Value    := RtfText.active_paragraph^.indentfirst;
  LeftIndent.Value     := RtfText.active_paragraph^.indentleft;
  RightIndent.Value    := RtfText.active_paragraph^.indentright;
  SpacingBefore.Value  := RtfText.active_paragraph^.spacebefore;
  SpacingAfter.Value   := RtfText.active_paragraph^.spaceafter;
  val := RtfText.active_paragraph^.spacebetween;
  if paprMultSpacing in RtfText.active_paragraph^.prop then
  begin
     SpacingType.ItemIndex := 0;
     SpacingBetween.UnitType := euMultiple;
     SpacingBetween.Value := val;
  end else
  begin
     if val<0 then
     begin  SpacingBetween.Value  := -val;
            SpacingType.ItemIndex := 2;
     end else if val=0 then
     begin
             SpacingType.ItemIndex := 0;
             SpacingBetween.UnitType := euMultiple;
             SpacingBetween.Value := 240;
     end else
     begin
            SpacingBetween.UnitType :=  SpacingBefore.UnitType;
            SpacingBetween.Value  := val;
            SpacingType.ItemIndex := 1;
     end;
  end;
  cbxAlignment.ItemIndex := Integer(RtfText.active_paragraph^.align);  }
{$ENDIF}
  WPRichText1.CPPosition := 0;
  WPRichText1.Memo.ReformatAll;
  WPRichText1.Invalidate;
end;

procedure TWPParagraphProp.SpacingBetweenUnitChange(Sender: TObject);
begin
  if TWPValueEdit(Sender).UnitType <> euMultiple then
  begin
    GlobalValueUnit := TWPValueEdit(Sender).UnitType;
    FirstIndent.UnitType := GlobalValueUnit;
    LeftIndent.UnitType := GlobalValueUnit;
    RightIndent.UnitType := GlobalValueUnit;
    SpacingBefore.UnitType := GlobalValueUnit;
    SpacingAfter.UnitType := GlobalValueUnit;
    SpacingBetween.UnitType := GlobalValueUnit;
  end;
end;

procedure TWPParagraphProp.UpdateExample(Sender: TObject);
begin
{$IFDEF WPTOOLS5}

  if not FirstIndent.Undefined then
    FDemoPar.ASet(WPAT_IndentFirst, FirstIndent.Value)
  else if FirstIndent.ChangeToUndefined then FDemoPar.ADel(WPAT_IndentFirst);
  if not LeftIndent.Undefined then
    FDemoPar.ASet(WPAT_IndentLeft, LeftIndent.Value)
  else if LeftIndent.ChangeToUndefined then FDemoPar.ADel(WPAT_IndentLeft);
  if not RightIndent.Undefined then
    FDemoPar.ASet(WPAT_IndentRight, RightIndent.Value)
  else if RightIndent.ChangeToUndefined then FDemoPar.ADel(WPAT_IndentRight);
  if not SpacingBefore.Undefined then
    FDemoPar.ASet(WPAT_SpaceBefore, SpacingBefore.Value)
  else if SpacingBefore.ChangeToUndefined then FDemoPar.ADel(WPAT_SpaceBefore);
  if not SpacingAfter.Undefined then
    FDemoPar.ASet(WPAT_SpaceAfter, SpacingAfter.Value)
  else if SpacingAfter.ChangeToUndefined then FDemoPar.ADel(WPAT_SpaceAfter);
  if not SpacingBetween.Undefined or (SpacingType.ItemIndex = 0) then
    case SpacingType.ItemIndex of
      0: begin
          FDemoPar.ADel(WPAT_SpaceBetween);
          FDemoPar.ADel(WPAT_LineHeight);
          SpacingBetween.Undefined := TRUE;
        end;
      1: begin
          FDemoPar.ADel(WPAT_SpaceBetween);
          FDemoPar.ASet(WPAT_LineHeight, MulDiv(SpacingBetween.Value, 100, 240));
        end;
      2: begin
          FDemoPar.ADel(WPAT_LineHeight);
          FDemoPar.ASet(WPAT_SpaceBetween, SpacingBetween.Value);
        end;
      3: begin
          FDemoPar.ADel(WPAT_LineHeight);
          FDemoPar.ASet(WPAT_SpaceBetween, -SpacingBetween.Value);
        end;
    end
  else if SpacingBetween.ChangeToUndefined then
  begin
    fsEditBox.ADel(WPAT_LineHeight);
    fsEditBox.ADel(WPAT_SpaceBetween);
  end;
  if cbxAlignment.ItemIndex > 0 then
    FDemoPar.ASet(WPAT_Alignment, cbxAlignment.ItemIndex - 1) else
    if cbxAlignment.ItemIndex = 0 then
      FDemoPar.ADel(WPAT_Alignment);

  if cbxOutlineLevel.ItemIndex > 0 then
    FDemoPar.ASet(WPAT_OUTLINELEVEL, cbxOutlineLevel.ItemIndex)
  else
    if cbxOutlineLevel.ItemIndex = 0 then
      FDemoPar.ADel(WPAT_OUTLINELEVEL);

  WPRichText1.Refresh;
{$ELSE}
{  with WPRichText1 do
    begin
      Set_ParMargin(FirstIndent.Value,LeftIndent.Value,RightIndent.Value);
      Set_ParAlign(TParAlign(cbxAlignment.ItemIndex));
      case SpacingType.ItemIndex of
        0 : Memo.Set_ParSpacing(FALSE,SpacingBefore.Value, SpacingBetween.Value, SpacingAfter.Value,TRUE);
        1 : Memo.Set_ParSpacing(FALSE,SpacingBefore.Value, SpacingBetween.Value, SpacingAfter.Value,FALSE);
        2 : Memo.Set_ParSpacing(FALSE,SpacingBefore.Value,-SpacingBetween.Value,SpacingAfter.Value,FALSE);
      end;
      Invalidate;
      Update;
    end;   }
{$ENDIF}
end;


procedure TWPParagraphProp.ButUpdateClick(Sender: TObject);
begin
  if fsEditBox <> nil then
  begin
{$IFDEF WPTOOLS5}
    if not FirstIndent.Undefined then
      fsEditBox.ASet(WPAT_IndentFirst, FirstIndent.Value)
    else if FirstIndent.ChangeToUndefined then fsEditBox.ADel(WPAT_IndentFirst);
    if not LeftIndent.Undefined then
      fsEditBox.ASet(WPAT_IndentLeft, LeftIndent.Value)
    else if LeftIndent.ChangeToUndefined then fsEditBox.ADel(WPAT_IndentLeft);
    if not RightIndent.Undefined then
      fsEditBox.ASet(WPAT_IndentRight, RightIndent.Value)
    else if RightIndent.ChangeToUndefined then fsEditBox.ADel(WPAT_IndentRight);
    if not SpacingBefore.Undefined then
      fsEditBox.ASet(WPAT_SpaceBefore, SpacingBefore.Value)
    else if SpacingBefore.ChangeToUndefined then fsEditBox.ADel(WPAT_SpaceBefore);
    if not SpacingAfter.Undefined then
      fsEditBox.ASet(WPAT_SpaceAfter, SpacingAfter.Value)
    else if SpacingAfter.ChangeToUndefined then fsEditBox.ADel(WPAT_SpaceAfter);
    if not SpacingBetween.Undefined or (SpacingType.ItemIndex = 0) then
      case SpacingType.ItemIndex of
        0: begin
            fsEditBox.ADel(WPAT_SpaceBetween);
            fsEditBox.ADel(WPAT_LineHeight);
          end;
        1: begin
            fsEditBox.ADel(WPAT_SpaceBetween);
            fsEditBox.ASet(WPAT_LineHeight, MulDiv(SpacingBetween.Value, 100, 240));
          end;
        2: begin
            fsEditBox.ADel(WPAT_LineHeight);
            fsEditBox.ASet(WPAT_SpaceBetween, SpacingBetween.Value);
          end;
        3: begin
            fsEditBox.ADel(WPAT_LineHeight);
            fsEditBox.ASet(WPAT_SpaceBetween, -SpacingBetween.Value);
          end;
      end
    else if SpacingBetween.ChangeToUndefined then
    begin
      fsEditBox.ADel(WPAT_LineHeight);
      fsEditBox.ADel(WPAT_SpaceBetween);
    end;
    if cbxAlignment.ItemIndex > 0 then
      fsEditBox.ASet(WPAT_Alignment, cbxAlignment.ItemIndex - 1) else
      if cbxAlignment.ItemIndex = 0 then
        fsEditBox.ADel(WPAT_Alignment);

    if cbxOutlineLevel.ItemIndex > 0 then
      fsEditBox.ASet(WPAT_OUTLINELEVEL, cbxOutlineLevel.ItemIndex) else
      if cbxOutlineLevel.ItemIndex = 0 then
        fsEditBox.ADel(WPAT_OUTLINELEVEL);

    fsEditBox.Refresh;
{$ELSE}
 {       fsEditBox.Set_ParMargin(FirstIndent.Value,LeftIndent.Value,RightIndent.Value);
        fsEditBox.Set_ParAlign(TParAlign(cbxAlignment.ItemIndex));
        case SpacingType.ItemIndex of
          0 : fsEditBox.Memo.Set_ParSpacing(FALSE,SpacingBefore.Value, SpacingBetween.Value, SpacingAfter.Value,TRUE);
          1 : fsEditBox.Memo.Set_ParSpacing(FALSE,SpacingBefore.Value, SpacingBetween.Value, SpacingAfter.Value,FALSE);
          2 : fsEditBox.Memo.Set_ParSpacing(FALSE,SpacingBefore.Value,-SpacingBetween.Value,SpacingAfter.Value,FALSE);
        end;
}{$ENDIF}
  end;
end;

procedure TWPParagraphProp.ButOKClick(Sender: TObject);
begin
// fsEditBox.Memo.NewUndolevel;
// fsEditBox.Memo.StartUndolevel;
// fsEditBox.Memo.UndoBufferSaveTo(fsEditBox.ActivePar, wpuReLoadText, wputChangeAlignment);
  ButUpdateClick(ButUpdate);
// fsEditBox.Memo.EndUndolevel;
  ModalResult := IDOK;
end;

procedure TWPParagraphProp.SpacingTypeClick(Sender: TObject);
begin
  if SpacingType.ItemIndex = 0 then
  begin
    SpacingBetween.Undefined := TRUE;
  end else
    if SpacingType.ItemIndex = 1 then
    begin
      SpacingBetween.UnitType := euMultiple;
      SpacingBetween.Value := 1;
    end
    else
    begin
      if SpacingBetween.UnitType = euMultiple then
      begin
        SpacingBetween.UnitType := SpacingBefore.UnitType;
        SpacingBetween.Value := 0;
      end;
    end;
end;




procedure TWPParagraphProp.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end;
end;

procedure TWPParagraphProp.FormCreate(Sender: TObject);
begin
  WPRichText1 := TWPCustomRtfEdit.Create(Self);
  WPRichText1.Parent := Self;
  WPRichText1.BoundsRect := RichBevel.BoundsRect;
end;

procedure TWPParagraphProp.ButOpenTabsClick(Sender: TObject);
begin
  if assigned(FOnEditTabsClick) then
    FOnEditTabsClick(Self);
end;

end.

