unit WPTabdlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  Dialog to edit tabstops
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{ Paragraph Tabstop properties - This unit used to work for WPTools 4.
  WPTools 5 offers a new way to work with tab stops. They are now handled in an
  array for each paragraph / style. This makde it possible to support tab filling
  modes. We have kommented the old code to make it possible to compare the code
  which used to work with WPTools and the new code.

  The logic of the tab dialog has been updated to
  a) support the new fill modes
  b) support the change of fillmode/kind of tabstops (not value!)
  c) apply delete and insertion in the 'OK' procedure  }

{$I WPINC.INC}

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
     {$IFDEF WPTools5}  WPCtrMemo, WPRTEDefs, WPCtrRich, WPRTEPaint,
     {$ELSE} WPDefs, WPLabel, WPRtfIO, WPPrint, WPWinctr, WPRich, WPRtfPA, StdCtrls, WPUtil, ExtCtrls,
  Buttons {$ENDIF}
     Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil;
     
type
   {$IFNDEF T2H}
   TWPTabDialog = class(TWPShadedForm)
    TabList: TListBox;
    btnDelete: TBitBtn;
    btnDeleteAll: TBitBtn;
    labDefaultTab: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    AlignmentGroup: TRadioGroup;
    veTabDefault: TWPValueEdit;
    btnInsert: TBitBtn;
    veInsertTab: TWPValueEdit;
    gbxTabStop: TLabel;
    TabFillGroup: TRadioGroup;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure btnDeleteAllClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure TabListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormActivate(Sender: TObject);
    procedure veInsertTabChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure veInsertTabUnitChange(Sender: TObject);
    procedure TabListClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AlignmentGroupClick(Sender: TObject);
    procedure TabFillGroupClick(Sender: TObject);
   private
     FDeleteList : TList;
     FDontDisableList : Boolean;
     procedure ModTabValue(val : Integer);
  public
  {$IFDEF WPTools5}
    fsEditBox : TWPCustomRtfEdit;// The preview
  {$ELSE}
    RtfText   : TWPRtfTextPaint; // Does not exit in WPTools 5
  {$ENDIF}
  end;
  {$ENDIF}

  TWPTabDlg = class(TWPCustomAttrDlg)
  private
    dia      : TWPTabDialog;
  public
    function Execute : Boolean; override;
  published
    property EditBox;
  end;

  TWPTabDlgPrp = class
    PosInTwips: Integer;
    kind: TTabKind;
    FillMode : TTabFill;
    FillColor: Integer;
  end;

implementation

{$R *.DFM}

function TWPTabDlg.Execute : Boolean;
begin
  Result := FALSE;
  if assignedActiveRTFEdit(FEditBox) and Changing then
    begin
      dia := TWPTabDialog.Create(Self);
      try
       // dia.RtfText                 := (ActiveRTFEdit(FEditBox).RtfText as TWPRtfTextPaint);
        dia.fsEditBox               := ActiveRTFEdit(FEditBox);
      {  dia.AlignmentGroup.Items[0] := WPLoadStr(meDiaTkLeft);
        dia.AlignmentGroup.Items[1] := WPLoadStr(meDiaTkRight);
        dia.AlignmentGroup.Items[2] := WPLoadStr(meDiaTkCenter);
        dia.AlignmentGroup.Items[3] := WPLoadStr(meDiaTkDecimal); }
        if not FCreateAndFreeDialog and   MayOpenDialog(dia) and(dia.ShowModal=IDOK) then Result := TRUE
        else FEditBox.Modified := FOldModified;
      finally
        dia.Free;
      end;
    end;
end;

procedure TWPTabDialog.FormActivate(Sender: TObject);
var
  I    : Integer;
  TPos : String;
  Value: Integer; Kind: TTabKind; FillMode: TTabFill; FillColor: Integer;
  procedure AddTab;
  var t : TWPTabDlgPrp;
  begin
     if GlobalValueUnit = euCM then
            TPos  := Format('%8.2f',[WPTwipsToCentimeter(Value)])
     else
            TPos  := Format('%8.2f',[WPTwipsToInch(Value)]);
     t := TWPTabDlgPrp.Create;
     t.PosInTwips := Value;
     t.kind := Kind;
     t.FillMode := FillMode;
     t.FillColor := FillColor;
     TabList.Items.AddObject(Char(65 + Integer(Kind))+TPos, t);
  end;
begin
  TabList.Sorted := FALSE;
  veInsertTab.UnitType  := GlobalValueUnit;
  veTabDefault.UnitType := GlobalValueUnit;
  veTabDefault.Value    := fsEditBox.Header.DefaultTabstop;

  {$IFDEF WPTOOLS5}
  // the WPTools 4 code used a fix count of possible tab stops. In WPTools 5 the
  // tabstops are properties of the style / paragraph
  // A selection can have a union of defined tabstops - in 'OnDeleteAll' we are only
  // deleting the tabstops which are the same for all!
  // Unlike for attributes the TWPRichText has no 'AGet' procedure for tabstops which automatically
  // retrieves the cursor / selected
  if fsEditBox.IsSelected then
  begin
    for i:=0 to fsEditBox.Memo.Cursor.SelectedTextAttr.TabstopCount-1 do
    begin
         fsEditBox.Memo.Cursor.SelectedTextAttr.TabstopGet(i,
            Value, Kind, FillMode,FillColor);
         AddTab;
    end;
  end else
  begin
    for i:=0 to fsEditBox.Memo.Cursor.WritingTextAttr.TabstopCount-1 do
    begin
         fsEditBox.Memo.Cursor.WritingTextAttr.TabstopGet(i,
            Value, Kind, FillMode,FillColor);
         AddTab;
    end;
  end;

  {$ELSE}
 {
    for I:=0 to TABMAX-1 do
    begin
      if (RtfText.Header.TabPos[I] <> 0) and
         ((TabsRef[I mod 16] and RtfText.Active_Paragraph^.Tabs[I div 16])>0) then
        begin
          if GlobalValueUnit = euCM then
            TPos  := Format('%8.2f',[WPTwipsToCentimeter(RtfText.Header.TabPosTw[I])])
          else
            TPos  := Format('%8.2f',[WPTwipsToInch(RtfText.Header.TabPosTw[I])]);
          TKind := RtfText.Header.TabKind[I];
          TabList.Items.AddObject(
             Char(65 + Integer(TKind))+TPos, TObject(RtfText.Header.TabPosTw[I]));
        end;
    end; }
    {$ENDIF}
    veInsertTab.OnChange(Self);
    btnDeleteAll.Enabled := TabList.Items.Count>0;

    if TabList.Items.Count>0 then
    begin
     TabList.ItemIndex := 0;
     TabListClick(nil);
    end;
end;

procedure TWPTabDialog.btnInsertClick(Sender: TObject);
var
  tw,i  : Integer;
  TPos : String;
  t : TWPTabDlgPrp;
begin
  if veInsertTab.Value > 0 then
    begin
      if GlobalValueUnit = euCM then
        begin
          tw   := veInsertTab.Value;
          TPos := Format('%8.2f cm',[WPTwipsToCentimeter(veInsertTab.Value)]);
        end
      else
        begin
          tw   := veInsertTab.Value;
          TPos := Format('%8.2f in',[WPTwipsToInch(veInsertTab.Value)]);
        end;
      t := TWPTabDlgPrp.Create;
      t.PosInTwips := tw;
      t.kind := TTabKind(AlignmentGroup.ItemIndex);
      t.FillMode := TTabFill( TabFillGroup.ItemIndex );
      t.FillColor := 0;
      TabList.Items.AddObject(Char(65+AlignmentGroup.ItemIndex)+TPos,t);

   {  no- we update the list later!
      o := fsEditBox.Header.RoundTabs;
      fsEditBox.Header.RoundTabs := FALSE;
      case AlignmentGroup.ItemIndex of
        0 : fsEditBox.SetTabPos(tw, tkLeft, False);
        1 : fsEditBox.SetTabPos(tw, tkRight, False);
        2 : fsEditBox.SetTabPos(tw, tkCenter, False);
        3 : fsEditBox.SetTabPos(tw, tkDecimal, False);
      end;
      fsEditBox.Header.RoundTabs := o; }
      btnInsert.Enabled := FALSE;
      for i:=0 to TabList.Items.Count-1 do
        if TWPTabDlgPrp(TabList.Items.Objects[i]).PosInTwips=tw then
        begin
           TabList.ItemIndex := i;
           break;
        end;
    end;
    btnDeleteAll.Enabled := TabList.Items.Count>0;

end;

procedure TWPTabDialog.btnDeleteClick(Sender: TObject);
var
  tw: LongInt;
begin
    if TabList.ItemIndex <> -1 then
    begin
      tw := TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).PosInTwips;
      FDeleteList.Add(Pointer(tw));
      TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).Free;
      TabList.Items.Delete(TabList.ItemIndex);
    end;
    btnDeleteAll.Enabled := TabList.Items.Count>0;
    btnInsert.Enabled := TRUE;
end;



procedure TWPTabDialog.btnDeleteAllClick(Sender: TObject);
var i : Integer;
begin
  for i:=0 to TabList.Items.Count-1 do
  begin
    FDeleteList.Add(Pointer(TWPTabDlgPrp(TabList.Items.Objects[ i ]).PosInTwips));
    TWPTabDlgPrp(TabList.Items.Objects[ i ]).Free;
  end;
  TabList.Clear;
  btnDeleteAll.Enabled := FALSE;
  btnDelete.Enabled := FALSE;
  btnInsert.Enabled := TRUE;
  {$IFDEF WPTOOLS5}
    // NO, we do this in 'OK' ! fsEditBox.TabstopClear;
  {$ELSE}
  // fsEditBox.CurrAttr.ClearAllTabs;
  {$ENDIF}
end;

procedure TWPTabDialog.veInsertTabChange(Sender: TObject);
var i,v : Integer;
 en : Boolean;
begin
  if not FDontDisableList then
  begin
     TabList.ItemIndex := -1;
     btnDelete.Enabled := FALSE;
  end;
  if Length(veInsertTab.Text) > 0 then
  begin
     v := veInsertTab.Value;
     en := v>0;
     for i:= 0 to TabList.Items.Count-1 do
        if Abs(TWPTabDlgPrp(TabList.Items.Objects[i]).PosInTwips-v)<4 then
        begin en := FALSE; break; end;
     btnInsert.Enabled := en; 
  end
  else
     btnInsert.Enabled := False;
end;

procedure TWPTabDialog.TabListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
        tw : Longint;
        s,TPos : string;
begin
  s := TabList.Items.Strings[Index];
  //c := s[1];
  tw := (TWPTabDlgPrp(TabList.Items.Objects[ Index ]).PosInTwips);
  if GlobalValueUnit = euCM then
        begin
          TPos := Format('%8.2f cm',[WPTwipsToCentimeter(tw)]);
        end
  else
        begin
          TPos := Format('%8.2f in',[WPTwipsToInch(tw)]);
        end;

  case TWPTabDlgPrp(TabList.Items.Objects[ Index ]).kind of
  	{Draw left aligned tab marker.}
  	tkLeft:	begin
     	with (Control as TListBox).Canvas do
        	begin
           Pen.Width := 2;
           FillRect(Rect);
           MoveTo(Rect.Left + 4, Rect.Top + 4);
           LineTo(Rect.Left + 4, Rect.Bottom - 2);
           MoveTo(Rect.Left + 4, Rect.Bottom - 2);
           LineTo(Rect.Left + 4 + 6, Rect.Bottom - 2);
           TextOut(Rect.Left + 4 + 6 + 6, Rect.Top, TPos);
           end;
     	end;
  	{Draw right aligned tab marker.}
     tkRight:	begin
     	with (Control as TListBox).Canvas do
        	begin
           Pen.Width := 2;
           FillRect(Rect);
           MoveTo(Rect.Left + 4 + 6, Rect.Top + 4);
           LineTo(Rect.Left + 4 + 6, Rect.Bottom - 2);
           MoveTo(Rect.Left + 4, Rect.Bottom - 2);
           LineTo(Rect.Left + 4 + 6, Rect.Bottom - 2);
           TextOut(Rect.Left + 4 + 6 + 6, Rect.Top, TPos);
           end;
     	end;
  	{Draw center aligned tab marker.}
     tkCenter:	begin
     	with (Control as TListBox).Canvas do
        	begin
           Pen.Width := 2;
           FillRect(Rect);
           MoveTo(Rect.Left + 4 + 3, Rect.Top + 4);
           LineTo(Rect.Left + 4 + 3, Rect.Bottom - 2);
           MoveTo(Rect.Left + 4, Rect.Bottom - 2);
           LineTo(Rect.Left + 4 + 6, Rect.Bottom - 2);
           TextOut(Rect.Left + 4 + 6 + 6, Rect.Top, TPos);
           end;
     	end;
  	{Draw decimal aligned tab marker.}
     tkDecimal:	begin
     	with (Control as TListBox).Canvas do
        	begin
           Pen.Width := 2;
           FillRect(Rect);
           MoveTo(Rect.Left + 4 + 3, Rect.Top + 4);
           LineTo(Rect.Left + 4 + 3, Rect.Bottom - 2);
           MoveTo(Rect.Left + 4, Rect.Bottom - 2);
           LineTo(Rect.Left + 4 + 6, Rect.Bottom - 2);
           MoveTo(Rect.Left + 4 + 6, Rect.Top + 5);
           LineTo(Rect.Left + 4 + 6, Rect.Top + 6);
           TextOut(Rect.Left + 4 + 6 + 6, Rect.Top, TPos);
           end;
     	end;
     tkBarTab:	begin  // Bar Tab
     	with (Control as TListBox).Canvas do
        	begin
           Pen.Width := 2;
           FillRect(Rect);
           MoveTo(Rect.Left + 4 , Rect.Top + 1);
           LineTo(Rect.Left + 4 , Rect.Bottom - 1);
           end;
     	end;
  end;
end;

procedure TWPTabDialog.btnOkClick(Sender: TObject);
var i : Integer;
begin
 // if fsEditBox.WPRuler<>nil then fsEditBox.WPRuler.Refresh;
  if fsEditBox.Header.DefaultTabstop<>veTabDefault.Value then
  begin
     fsEditBox.Header.DefaultTabstop := veTabDefault.Value;
     fsEditBox.Memo.ReformatAll;
     fsEditBox.Invalidate;
  end
  else fsEditBox.Refresh; 

  for i:=0 to FDeleteList.Count-1 do
   fsEditBox.TabstopDelete(Integer(FDeleteList[i]));
  for i:=0 to Tablist.Items.Count-1 do
  begin
      fsEditBox.TabstopAdd(
         TWPTabDlgPrp(TabList.Items.Objects[i]).PosInTwips,
         TWPTabDlgPrp(TabList.Items.Objects[ i ]).kind,
         TWPTabDlgPrp(TabList.Items.Objects[ i ]).FillMode,
         TWPTabDlgPrp(TabList.Items.Objects[ i ]).FillColor);
  end;
  TabList.Clear;

  fsEditBox.Refresh;
  ModalResult := mrOk
end;

procedure TWPTabDialog.veInsertTabUnitChange(Sender: TObject);
begin
  GlobalValueUnit :=  (Sender as TWPValueEdit).UnitType;
  veTabDefault.UnitType := GlobalValueUnit;
  veInsertTab.UnitType := GlobalValueUnit;
  TabList.Invalidate;
end;

procedure TWPTabDialog.ModTabValue(val : Integer);
begin
  FDontDisableList := TRUE;
  try
  veInsertTab.Value := val;
  finally
     FDontDisableList := FALSE;
  end;
end;

procedure TWPTabDialog.TabListClick(Sender: TObject);
begin
  if TabList.ItemIndex>=0 then
  begin
      ModTabValue(TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).PosInTwips);
      AlignmentGroup.ItemIndex :=
            Integer(TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).Kind);
      TabFillGroup.ItemIndex :=
            Integer(TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).FillMode);
      btnDelete.Enabled := TRUE;
  end else btnDelete.Enabled := FALSE;
end;

procedure TWPTabDialog.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then
  begin
     ModalResult := mrCancel;
     Key := #0;
  end;
end;

procedure TWPTabDialog.FormCreate(Sender: TObject);
begin
 FDeleteList := TList.Create;
end;

procedure TWPTabDialog.FormDestroy(Sender: TObject);
begin
 FDeleteList.Free;
end;

procedure TWPTabDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
var i : Integer;
begin
  for i:=0 to Tablist.Items.Count-1 do
  begin
      TWPTabDlgPrp(TabList.Items.Objects[ i ]).Free;
  end;
  TabList.Clear;
end;

procedure TWPTabDialog.AlignmentGroupClick(Sender: TObject);
begin
  if TabList.ItemIndex>=0 then
  begin
     TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).kind :=
        TTabKind(AlignmentGroup.ItemIndex);
     TabList.Invalidate;
  end;
end;

procedure TWPTabDialog.TabFillGroupClick(Sender: TObject);
begin
  if TabList.ItemIndex>=0 then
  begin
     TWPTabDlgPrp(TabList.Items.Objects[ TabList.ItemIndex ]).FillMode :=
        TTabFill(TabFillGroup.ItemIndex);
     TabList.Invalidate;
  end;
end;

end.
