{ -----------------------------------------------------------------------------
  WPPanel   - Copyright (C) 2002 by wpcubed GmbH    -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  -----------------------------------------------------------------------------
  WPTools Version 5 GUI controls
  This unit may not be distributed!
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }


{$I WPINC.INC}

unit WPPanel;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, WPRTEDefs, WPCTRRich, WPCTRMemo,
  WPTBar, Controls, Printers, WPAction;

{$IFNDEF T2H}
{$I WPMSG.INC}
{$ENDIF}

{.$DEFINE STYLEBOX_VARIABLE} // Draw style box variable

type
  TWPSpeedButtonStyle = string;

  TWPToolButton = class(TWPSpeedButton)
  private
    FUseOwnGylph: Boolean;
    FStyle: TWPSpeedButtonStyle;
    FStyleGroup: Integer;
    FStyleNumber: Integer;
    procedure SetStyle(x: TWPSpeedButtonStyle);
    procedure SetStyleNumber(x: Integer);
    procedure SetStyleGroup(x: Integer);
  protected
    procedure WPRTFEDITCHANGED(var Message: TMessage); message WP_RTFEDIT_CHANGED;
    procedure WPSELICON(var Message: TMessage); message WP_SEL_ICON;
    procedure WPENABLEICON(var Message: TMessage); message WP_ENABLE_ICON;
  public
{$IFNDEF T2H}
    procedure Click; override;
    constructor Create(AOwner: TComponent); override;
{$ENDIF}
  published
    property StyleGroup: Integer read FStyleGroup write SetStyleGroup stored TRUE;
    property StyleNumber: Integer read FStyleNumber write SetStyleNumber stored TRUE;
  published
    property UseOwnGylph: Boolean read FUseOwnGylph write FUseOwnGylph;
    { published first }
    property StyleName: TWPSpeedButtonStyle read FStyle write SetStyle stored TRUE;
    { -------------- }
{$IFNDEF T2H}
    property AllowAllUp;
    property GroupIndex;
    property Down;
    property Caption;
    property Enabled;
    property Font;
{$IFNDEF EXPLORERBUTTONS}
    property Glyph;
    property Layout;
    property Margin;
    property NumGlyphs;
    property Spacing;
{$ENDIF}
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$IFDEF DELPHI4}
    property Anchors;
    property Constraints;
{$ENDIF}
{$ENDIF}
  end;



{$IFDEF T2H}
  TWPComboBox = class(TComboBox)
{$ELSE}
  TWPComboBox = class(TWPTBCombo)
{$ENDIF}
  private
    FComboBoxStyle: TWPComboBoxStyle;
    FBitmap: TBitmap;
    FDontApplyChanges: Boolean;
    FNoEditItemsInStyleList : Boolean;
    procedure SetComboBoxStyle(x: TWPComboBoxStyle);
    procedure ColBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DrawPic(Background: TColor);
  protected
    procedure UpdateSel; override;
    // procedure WPRTFEDITCHANGED(var Message: TMessage); message WP_RTFEDIT_CHANGED;
    // procedure WPSELLIST(var Message: TMessage); message WP_SELLIST;
    procedure DropDown; override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
  public
{$IFNDEF T2H}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{$ENDIF}
    procedure Click; override;
    procedure UpdateItems;
    function IndexOf(str: string): Integer;
  published
    {:: If this property is TRUE the cbsStyleNames and cbsStyleNamesEx
      combobox will not display items to create a new style or to edit
      a style }
    property NoEditItemsInStyleList : Boolean read
      FNoEditItemsInStyleList write FNoEditItemsInStyleList default FALSE;
  {$IFNDEF T2H}
    property Style;
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
{$IFDEF DELPHI4}
    property Anchors;
    property Constraints;
{$ENDIF}
{$ENDIF}
    property ComboBoxStyle: TWPComboBoxStyle read FComboBoxStyle write SetComboBoxStyle;
    property DontApplyChanges: Boolean read FDontApplyChanges write FDontApplyChanges;

  end;

  TWPToolPanel = class(TWPCustomToolPanel)
  private
{$IFNDEF T2H}
    FXGap: INTEGER;
    FYGap: INTEGER;
    FAutoalign: Boolean;
    procedure SetXGap(gap: INTEGER);
    procedure SetYGap(gap: INTEGER);
  protected
    procedure Resize; override;
  public
    procedure Loaded; override;
    function SelectIcon(index, group, num: Integer): Boolean; override;
    function DeselectIcon(index, group, num: Integer): Boolean; override;
    function EnableIcon(index, group, num: Integer; enabled: Boolean): Boolean; override;
    procedure UpdateSelection(Typ: TWpSelNr; const str: string; num: Integer); override;
    procedure RealignControls;
  published
    property Align;
    property Alignment;
    property BevelLines;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property AutoEnabling;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Caption;
    property Color;
    property Ctl3D;
    property Font;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
{$IFDEF WIN32}
    property OnEndDrag;
{$ENDIF}
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property NextToolBar;
    property Moveable;
    property Sizeable;
{$IFDEF DELPHI4}
    property Anchors;
    property Constraints;
{$ENDIF}
{$ENDIF}
    property Autoalign: Boolean read FAutoalign write FAutoalign;
    property XGap: INTEGER read FXGap write SetXGap;
    property YGap: INTEGER read FYGap write SetYGap;
  end;

implementation

function TWPToolPanel.SelectIcon(index, group, num: Integer): Boolean;
var
  i, j: Integer;
begin
  j := ControlCount; i := 0;
  Result := FALSE;
  while i < j do
  begin
    if Controls[i] is TWPToolButton then
      with (Controls[i] as TWPToolButton) do
      begin
        if (StyleGroup = group) and (StyleNumber = num) then
        begin Result := TRUE;
          Down := TRUE;
        end
        else if StyleGroup = WPI_GR_ALIGN then Down := FALSE;
      end;
    inc(i);
  end;
  inherited SelectIcon(index, group, num);
end;

function TWPToolPanel.DeselectIcon(index, group, num: Integer): Boolean;
var
  i, j: Integer;
begin
  j := ControlCount; i := 0;
  Result := FALSE;
  while i < j do
  begin
    if Controls[i] is TWPToolButton then
      with (Controls[i] as TWPToolButton) do
      begin
        if (StyleGroup = group) and (StyleNumber = num) then
        begin Result := TRUE;
          Down := FALSE;
        end;
      end;
    inc(i);
  end;
  inherited DeSelectIcon(index, group, num); ;
end;

function TWPToolPanel.EnableIcon(index, group, num: Integer; enabled: Boolean): Boolean;
var
  i, j: Integer;
begin
  j := ControlCount;
  i := 0;
  Result := FALSE;
  while i < j do
  begin
    if Controls[i] is TWPToolButton then
    begin
      if ((Controls[i] as TWPToolButton).StyleGroup = group)
        and ((Controls[i] as TWPToolButton).StyleNumber = num) then
      begin
        (Controls[i] as TWPToolButton).enabled := enabled;
        Result := TRUE;
      end;
    end;
    inc(i);
  end;
  inherited EnableIcon(index, group, num, enabled);
end;

procedure TWPToolPanel.UpdateSelection(Typ: TWpSelNr; const str: string; num: Integer);
var
 i, j, z: Integer;
 combo: TWPComboBox;
 label search;
begin
  j := ControlCount; z := 0;
  while z < j do
  begin
    if (Controls[z] is TWPComboBox) and not TWPComboBox(Controls[z]).FLockUpdate
      // and (TWPComboBox(Controls[z]).FRtfEdit=nil)
    then
    begin
      combo := TWPComboBox(Controls[z]);
      case Typ of
        wptName: if ((combo.FComboBoxStyle = cbsPrinterFonts) or
            (combo.FComboBoxStyle = cbsScreenFonts) or
            (combo.FComboBoxStyle = cbsTrueTypeFonts) or
            (combo.FComboBoxStyle = cbsAnyFonts)) and
          (combo.Text <> str)
            then
          begin
            search:
            i := 0;
            while i < combo.Items.Count do
            begin if CompareText(combo.Items.Strings[i], str) = 0 then break;
              inc(i);
            end;
            if i >= combo.Items.Count then
            begin
              combo.Items.Add(str);
              goto search;
            end else if combo.ItemIndex <> i then combo.ItemIndex := i;
          end;
        wptSize: if ((combo.FComboBoxStyle = cbsFontSize) or (combo.FComboBoxStyle = cbsHtmlFontSize) or
            (combo.FComboBoxStyle = cbsFontSizeManual)) and ((num<0) or (num >= 7)) then
          begin
            WPUpdateNumberCombo(combo, num);
             { i := items.indexof(#32 + inttostr(num));
              if i < 0 then i := items.indexof(inttostr(num));
              if i >= 0 then ItemIndex := i;  }
          end;
        wptColor: if (RTFProps <> nil) and (combo.FComboBoxStyle = cbsColor) and (num < RTFProps.NumPaletteEntries) then
            WPUpdateNumberCombo(combo, num);
        wptBKColor: if (RTFProps <> nil) and (combo.FComboBoxStyle = cbsBKColor) and (num < RTFProps.NumPaletteEntries) then
            WPUpdateNumberCombo(combo, num);
        wptParColor: if (RTFProps <> nil) and (combo.FComboBoxStyle = cbsParColor) and (num < RTFProps.NumPaletteEntries) then
            WPUpdateNumberCombo(combo, num);
        wptParAlign: if (combo.FComboBoxStyle = cbsParAlignment) then
            combo.ItemIndex := num;
        wptStyleNames :
          if (combo.FComboBoxStyle = cbsStyleNames) or
           (combo.FComboBoxStyle = cbsStyleNamesEx) then
          begin
            num := combo.Items.Indexof(Str);
            if (num > -1) or (Str = '') then
              combo.ItemIndex := num
            else
            begin
                 //add it BEFORE last item
              combo.Items.Insert(combo.Items.Count - 1, Str);
              combo.itemIndex := combo.Items.Indexof(Str);
            end;
          end;
      end;
    end;
    inc(z);
  end;
  inherited UpdateSelection(Typ, str, num);
end;

procedure TWPToolPanel.RealignControls;
var
  display_list: TList;
  i: INTEGER;
  curr_left: INTEGER;
  curr_top: INTEGER;
  curr_ctrl: TControl;
  max_height: INTEGER;
  new_width: INTEGER;
  controls_on_row: INTEGER;

  AlignMode: (amHorz, amVert);
  max_width: INTEGER;

  procedure INSERTCTRL(COMP: TCONTROL);
  var
    i: INTEGER;
    temp: TControl;
  begin
      {just use a simple sweep through all the entries}
    for i := 0 to display_list.count - 1 do begin
      temp := TControl(display_list[i]);
      if AlignMode = amHorz then
      begin
        if comp.top < temp.top then begin
          display_list.insert(i, comp);
          exit;
        end else if (comp.top = temp.top) and (comp.left < temp.left) then
        begin
          display_list.insert(i, comp);
          exit;
        end;
      end else
      begin
        if comp.Left < temp.Left then begin
          display_list.insert(i, comp);
          exit;
        end else if (comp.Left = temp.Left) and (comp.Top < temp.Top) then
        begin
          display_list.insert(i, comp);
          exit;
        end;
      end;
    end;
      {by default, add it at the end}
    display_list.add(comp);
  end;

  procedure PLACE_CONTROL;
  begin
    if curr_ctrl.left <> curr_left then
      curr_ctrl.left := curr_left;
    if curr_ctrl.top <> curr_top then
      curr_ctrl.top := curr_top;
    if AlignMode = amHorz then
    begin
      curr_left := curr_left + curr_ctrl.Width + XGap;
      if max_height < curr_ctrl.height then
        max_height := curr_ctrl.height;
    end else { align vertical }
    begin
      curr_top := curr_top + curr_ctrl.Height + YGap;
      if max_width < curr_ctrl.width then
        max_width := curr_ctrl.width;
    end;
    inc(controls_on_row);
  end;

  procedure NEW_ROW;
  begin
    if AlignMode = amHorz then
    begin
      if max_height = 0 then
        max_height := curr_ctrl.height;
      curr_left := XGap;
      curr_top := curr_top + max_height + YGap;
      max_height := 0;
    end else
    begin
      if max_width = 0 then
        max_width := curr_ctrl.width;
      curr_top := YGap;
      curr_left := curr_left + max_width + XGap;
      max_width := 0;
    end;
    controls_on_row := 0;
  end;

  function CONTROL_FITS: BOOLEAN;
  begin
    if AlignMode = amHorz then
      result := ((curr_left + curr_ctrl.width + XGap) <= Width)
        or ((curr_ctrl.width + 2 * XGap > Width) and (curr_left <= XGap))
    else result := ((curr_top + curr_ctrl.height + YGap) <= Height)
      or ((curr_ctrl.height + 2 * YGap > Height) and (curr_top <= YGap));
  end;

begin
   {Disable alignment at design time or when switched OFF }
  if (csDesigning in ComponentState) or
    (csLoading in ComponentState) or not FAutoalign then exit;

  if (Align = alLeft) or (Align = alRight) then
    AlignMode := amVert
  else AlignMode := amHorz;

  display_list := TList.create;
  try
    for i := 0 to ControlCount - 1 do begin
      InsertCtrl(Controls[i]);
    end;
    if display_list.count <> ControlCount then
      raise Exception.create(WPLoadStr(meSysError));
    curr_left := XGap;
    curr_top := YGap;
    max_height := 0;
    max_width := 0;
    controls_on_row := 0;

    for i := 0 to display_list.count - 1 do begin
      curr_ctrl := TControl(display_list[i]);

         { Do not allign Controls if the are aligned }
      if (curr_ctrl.visible) and (curr_ctrl.Align = alNone) then
      begin
        if control_fits then place_control
        else begin
          new_row;
          if control_fits then
            place_control
          else begin
            if curr_ctrl is TWPComboBOX then begin
              new_width := Width - 2 * XGap;
              if new_width <= 30 then
                new_width := 30;
              curr_ctrl.Width := new_width;
            end;
            place_control;
            new_row;
          end;
        end;
      end;
    end;
    new_row;
    if AlignMode = amVert then
      Width := curr_left
    else Height := curr_top;

        { V2.2 }
    if (Parent <> nil) and not WPIsMDIApp then
    begin
      if not (Parent is TForm) or
        (TForm(Parent).FormStyle <> fsMdiChild) or
        (TForm(Parent).WindowState <> wsMaximized) then
        PostMessage(Parent.Handle, WM_SIZE, 0, 0);
    end;

  finally
    display_list.free;
  end;
end;

procedure TWPToolPanel.SetXGap(gap: INTEGER);
begin
  if FXGap <> gap then begin
    FXGap := gap;
    RealignControls;
  end;
end;

procedure TWPToolPanel.SetYGap(gap: INTEGER);
begin
  if FYGap <> gap then begin
    FYGap := gap;
    RealignControls;
  end;
end;

procedure TWPToolPanel.loaded;
begin
  inherited loaded;
  WPTInitFonts;
  RealignControls;
end;

procedure TWPToolPanel.Resize;
begin
  inherited resize;
  RealignControls;
end;

{ -----------------------------------------------------------------}

constructor TWPToolButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleName := '';
  StyleNumber := 0;
  StyleGroup := 0;
end;

procedure TWPToolButton.WPRTFEDITCHANGED(var Message: TMessage);
begin
  if Message.LParam = 0 then FRTFEdit := nil
  else FRTFEdit := TObject(Message.LParam) as TWPCustomRichText;
end; 

procedure TWPToolButton.WPSELICON(var Message: TMessage);
begin
  if (Message.LParam = StyleGroup + StyleNumber)
    then Down := (Message.WParam <> 0);
end;

procedure TWPToolButton.WPENABLEICON(var Message: TMessage);
begin
  if (Message.LParam = StyleGroup + StyleNumber)
    then Enabled := (Message.WParam <> 0);
end;

procedure TWPToolButton.SetStyle(x: TWPSpeedButtonStyle);
var
  a: array[0..100] of Char;
  h: THandle;
begin
  if x = '' then
  begin
    if not FUseOwnGylph then
    begin
{$IFDEF EXPLORERBUTTONS}
      Bitmap := nil;
{$ELSE}
      Glyph := nil;
{$ENDIF}
    end;
    FStyle := '';
    FStyleGroup := 0;
    FStyleNumber := 0;
  end else
  begin
    StrPLCopy(a, x, 99);
    if not FUseOwnGylph then
    begin
      if csDesigning in ComponentState then
      begin h := LoadBitmap(Hinstance, a);
      end
      else begin FStyle := x; h := 0; end;
      if h <> 0 then
      begin
{$IFDEF EXPLORERBUTTONS}
        Bitmap.Handle := h;
{$ELSE}
        Glyph.Handle := h;
{$ENDIF}
      end;
    end;
    FStyle := x;
    if Stylegroup <> WPI_GR_ALIGN then
    begin
      AllowAllUp := TRUE;
      GroupIndex := 3001 + ComponentIndex;
    end else
    begin
      AllowAllUp := FALSE;
      GroupIndex := 3000;
      if (Stylegroup = WPI_GR_ALIGN) and (Stylenumber = WPI_CO_LEFT) then
        Down := TRUE;
    end;
  end;
end;

procedure TWPToolButton.SetStyleNumber(x: Integer);
begin
  if FStyleNumber = 0 then FStyleNumber := x;
end;

procedure TWPToolButton.SetStyleGroup(x: Integer);
begin
  if FStyleGroup = 0 then FStyleGroup := x;
end;

procedure TWPToolButton.Click;
var
  Typ: TWpSelNr;
begin
  inherited Click;
  if Assigned(FRtfEdit) and (StyleName <> '') then
  begin
    if Down then Typ := wptIconSel else Typ := wptIconDeSel;
    FRtfEdit.OnToolBarIconSelection(Self, typ, StyleName, Stylegroup, Stylenumber, tag);
  end;
end;

{ ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- }

constructor TWPComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmap := TBitmap.Create;
  FBitmap.Height := 12;
  FBitmap.Width := 12;
end;

destructor TWPComboBox.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TWPComboBox.SetComboBoxStyle(x: TWPComboBoxStyle);
begin
  if FComboBoxStyle <> x then
  begin
    if x=cbsStyleNamesEx then
    {$IFDEF STYLEBOX_VARIABLE}
      Style := csOwnerDrawVariable
    {$ELSE}
      Style := csOwnerDrawFixed
    {$ENDIF}
    else if FComboBoxStyle=cbsStyleNamesEx then
      Style := csDropDownList;
    FComboBoxStyle := x;
    UpdateItems;
  end;
end;

function TWPComboBox.IndexOf(str: string): Integer;
var i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    if CompareText(Trim(Items[i]), str) = 0 then
    begin Result := i; exit; end;
  Result := -1;
end;

procedure TWPComboBox.UpdateItems;
var
  i: Integer;
begin
  case FComboBoxStyle of
    cbsPrinterFonts,
      cbsScreenFonts:
      begin
        if not WPNoPrinterInstalled and (Printer.Printers.Count > 0) and
          (FComboBoxStyle = cbsPrinterFonts)
          then begin
          try Items.Assign(Printer.Fonts);
          except Items.Assign(Screen.Fonts);
          end;
        end else Items.Assign(Screen.Fonts);

        OnDrawItem := ListBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsTrueTypeFonts:
      begin
        Items.Assign(Screen.Fonts);
        for i := Items.Count - 1 downto 0 do
          if not WPTGetFontType(Items[i]) then Items.Delete(i);
        OnDrawItem := ListBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsFontSize:
      begin
        Items.Clear;
        for i := 6 to 72 do Items.Add(#32 + InttoStr(i));
        OnDrawItem := ListBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsHtmlFontSize:
      begin
        Items.Clear;
               // 8,10,12,14,18,24,36 (see unit WPWrtHT)
        Items.Add(#32 + '8');
        Items.Add(#32 + '10');
        Items.Add(#32 + '12');
        Items.Add(#32 + '14');
        Items.Add(#32 + '18');
        Items.Add(#32 + '24');
        Items.Add(#32 + '36');
        OnDrawItem := ListBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsFontSizeManual:
      begin
        OnDrawItem := ListBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsColor, cbsBKColor, cbsParColor:
      begin
        WPUpdateNumberCombo(Self, 0);
        Items.Clear;
        if FRtfEdit<>nil then
        for i := 0 to FRtfEdit.Memo.RTFData.RTFProps.ColorTableCount - 1 do
        begin
          Items.AddObject(IntToStr(i), TObject(
          FRtfEdit.Memo.RTFData.RTFProps.ColorTable[i]
          ));
        end else
        for i := 0 to 15 do Items.AddObject(IntToStr(i), TObject(i));
        OnDrawItem := ColBoxDrawItem;
        Style := csOwnerDrawFixed;
      end;
    cbsParAlignment:
      begin
        Items.Clear;
        Items.Add(WPLoadStr(meDiaAlLeft));
        Items.Add(WPLoadStr(meDiaAlCenter));
        Items.Add(WPLoadStr(meDiaAlRight));
        Items.Add(WPLoadStr(meDiaAlJustified));
        ItemIndex := 0;
        OnDrawItem := nil;
      end;
    cbsStyleNames:
      begin
        Items.Clear;
        if (FRtfEdit <> nil) then
          ItemIndex := FRtfEdit.Memo.RTFData.RTFProps.ParStyles.GetStringList(
             Items, not FNoEditItemsInStyleList, FRtfEdit.ActiveStyleName);
        OnDrawItem := nil;
      end;
    cbsStyleNamesEx:
      begin
        Items.Clear;
        if (FRtfEdit <> nil) then
          ItemIndex := FRtfEdit.Memo.RTFData.RTFProps.ParStyles.GetStringList(
             Items, not FNoEditItemsInStyleList, FRtfEdit.ActiveStyleName);
        OnDrawItem := ListBoxDrawItem;
      end;
  end;
end;

(* procedure TWPComboBox.WPRTFEDITCHANGED(var Message: TMessage);
begin
  if Message.LParam = 0 then FRTFEdit := nil
  else
  begin
    FRTFEdit := TObject(Message.LParam) as TWPCustomRichText;
  end;
  UpdateSel;
end; *)

procedure TWPComboBox.UpdateSel;
var i: Integer; r : Boolean; s : Single; f : TFontName;
label search;
begin
    if Parent is TWPToolPanel then exit;
    if (FRTFEdit <> nil) and not FLockUpdate then
    begin
      if (FComboBoxStyle = cbsStyleNames) or
         (FComboBoxStyle = cbsStyleNamesEx) then
      begin
        Items.Clear;
        if FRtfEdit <> nil then 
        begin
          ItemIndex := FRtfEdit.Memo.RTFData.RTFProps.ParStyles.GetStringList(
              Items, not FNoEditItemsInStyleList, FRTFEdit.ActiveStyleName);
        end;
      end
      else if FComboBoxStyle = cbsParAlignment then
      begin
      // ItemIndex := StrToIntDef(StrPas(PChar(Message.LParam)),0);
      end
      else if FComboBoxStyle = cbsColor then
      begin
        if not FRTFEdit.IsSelected then
              r := FRTFEdit.CurrentCharAttr.GetColorNr(i)
        else  r := FRTFEdit.SelectedTextAttr.GetColorNr(i);
        if not r then
          ItemIndex := -1
        else
          WPUpdateNumberCombo(Self, i);
      end
      else if FComboBoxStyle = cbsBKColor then
      begin
        if not FRTFEdit.IsSelected then
              r := FRTFEdit.CurrentCharAttr.GetBGColorNr(i)
        else  r := FRTFEdit.SelectedTextAttr.GetBGColorNr(i);
        if not r then
          ItemIndex := -1
        else
          WPUpdateNumberCombo(Self, i);
      end
      else if FComboBoxStyle = cbsParColor then
      begin
        r := FRTFEdit.AGet(WPAT_BGColor,i);
        if not r then
          ItemIndex := -1 else
          WPUpdateNumberCombo(Self, i);
      end
      else if FComboBoxStyle = cbsFontSize then
      begin
        if not FRTFEdit.IsSelected then
              r := FRTFEdit.CurrentCharAttr.GetFontSize(s)
        else  r := FRTFEdit.SelectedTextAttr.GetFontSize(s);

        if (s<=0) or not r then ItemIndex := -1
        else
        begin 
          if Items.IndexOf(#32 + FloatToStr(s)) < 0 then
          begin
            i := Items.IndexOf(#32 + IntToStr(Trunc(s)));
            Items.Insert(i + 1, #32 + FloatToStr(s));
          end;
          ItemIndex := IndexOf(FloatToStr(s));
        end;
      end
      else if FComboBoxStyle in [cbsPrinterFonts, cbsScreenFonts, cbsAnyFonts, cbsTrueTypeFonts] then
      begin

        if not FRTFEdit.IsSelected then
              r := FRTFEdit.CurrentCharAttr.GetFontName(f)
        else  r := FRTFEdit.SelectedTextAttr.GetFontName(f);

        if not r or (f='') then ItemIndex := -1
        else
        begin

         search:
            i := 0;
            while i < Items.Count do
            begin if CompareText(Items.Strings[i], f) = 0 then break;
              inc(i);
            end;
            if i >= Items.Count then
            begin
              Items.Add(f);
              goto search;
            end else if ItemIndex <> i then ItemIndex := i;

        end;
      end;
    end;
end;

procedure TWPComboBox.MeasureItem(Index: Integer; var Height: Integer);
{$IFDEF STYLEBOX_VARIABLE}
   var sty : TWPTextStyle;
{$ENDIF}
begin
{$IFDEF STYLEBOX_VARIABLE}
  if (FComboBoxStyle = cbsStyleNamesEx) then
  begin
    if (FRTFEdit=nil) or (Index=-1) then sty := nil else
    sty := FRTFEdit.ParStyles.FindTextStyle(Items[index]);
    if sty=nil then   Height := Self.Height
    else
    begin
     Height := FRTFEdit.Memo.PaintSinglePar(
            sty,
           Canvas,
           Rect(0,0,0,0),
           Screen.PixelsPerInch,
           Screen.PixelsPerInch,
           Items[index]
        );
    end;
  end;
{$ENDIF}
end;

procedure TWPComboBox.DropDown;
var i: Integer;
begin
  inherited DropDown;
  if FRTFEdit <> nil then
  begin
    if (FComboBoxStyle in [cbsColor, cbsBKColor, cbsParColor]) then
    begin
      Items.Clear;
      for i := 0 to FRtfEdit.Memo.RTFData.RTFProps.ColorTableCount - 1 do
      begin
        Items.AddObject(IntToStr(i), TObject(
          FRtfEdit.Memo.RTFData.RTFProps.ColorTable[i]
          ));
      end;
    end
    else
      if (FComboBoxStyle = cbsStyleNames) or
         (FComboBoxStyle = cbsStyleNamesEx) then
      begin
        Items.Clear;
        FRtfEdit.Memo.RTFData.RTFProps.ParStyles.GetStringList(
           Items, not FNoEditItemsInStyleList);
      end;
  end;
end;


(* procedure TWPComboBox.WPSELLIST(var Message: TMessage);
var
  i: Integer;
const
  Styles: array[TWPComboBoxStyle] of Integer
  = (0, WP_wptName, WP_wptName, WP_wptName, WP_wptName,
    WP_wptSize, WP_wptSize,
    WP_wptColor, WP_wptBkColor, WP_wptParColor, WP_wptHtmlFontSize,
    WP_wptParAlignment, WP_wptStyleNames, WP_wptStyleNames
    );
begin
  if (Message.LParam <> 0) and (Message.WParam <> 0) and
    (Message.WParam = Styles[FComboBoxStyle]) then
  begin
    if FComboBoxStyle = cbsParAlignment then
    begin
      ItemIndex := StrToIntDef(StrPas(PChar(Message.LParam)), 0);
    end else if FComboBoxStyle in [cbsColor, cbsBKColor, cbsParColor,
      cbsFontSize, cbsFontSizeManual, cbsHtmlFontSize] then
    begin
      WPUpdateNumberCombo(Self, StrToIntDef(StrPas(PChar(Message.LParam)), 0));
    end
    else // if FComboBoxStyle<>cbsStyleNames then
    begin
      i := Items.IndexOf(StrPas(PChar(Message.LParam)));
      if (i < 0) and (StrPas(PChar(Message.LParam)) <> '') then
      begin i := Items.Count;
        Items.Add(StrPas(PChar(Message.LParam)));
      end;
      ItemIndex := i;
    end;
  end;
end;  *)


procedure TWPComboBox.ListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  nam: string;
  off: Integer;
  TT: Boolean;
  sty : TWPTextStyle;
begin
  nam := Items.Strings[Index];

  if FComboBoxStyle = cbsStyleNamesEx then
  begin
    Canvas.FillRect(Rect);
    if (Index = -1) or (FRTFEdit=nil) then sty := nil else
    sty := FRTFEdit.ParStyles.FindTextStyle(nam);
    if sty=nil then
    begin
      Canvas.TextOut(Rect.Left+1, Rect.Top+1, nam);
    end else
    begin
        FRTFEdit.Memo.PaintSinglePar(
          sty,
          Canvas,
          Rect,
          Screen.PixelsPerInch,
          Screen.PixelsPerInch,
          nam
          );
    end;
    if odFocused in State then
       DrawFocusRect(Canvas.Handle, Rect);
  end else
    with Canvas do
    begin
      FillRect(Rect);
      if (FComboBoxStyle = cbsPrinterFonts) or
        (FComboBoxStyle = cbsScreenFonts) or
        (FComboBoxStyle = cbsAnyFonts) or
        (FComboBoxStyle = cbsTrueTypeFonts) then
      begin
        TT := WPTGetFontType(Items[Index]);
        if TT then
        begin
          DrawPic(Brush.Color);
          Draw(Rect.Left + 2, Rect.Top, FBitmap);
        end;
        if (Rect.Left <> 3) then off := 16 else off := 19;
        Rect.Left := Rect.Left + 16;

{$IFDEF SHOWFONTS}
        Font.Name := nam; // <--------
{$ENDIF}
      end
      else off := 2;

      TextRect(Rect, off, rect.top, nam);
    end;
end;

procedure TWPComboBox.DrawPic(Background: TColor);
  procedure DRAWT(ORGX, ORGY: INTEGER; COLOR: TCOLOR);
  begin
    with FBitmap.Canvas do begin
      Brush.Style := bsSolid;
      Pen.Color := Color;

      MoveTo(OrgX, OrgY);
      LineTo(OrgX, OrgY + 4);
      MoveTo(OrgX + 7, OrgY);
      LineTo(OrgX + 7, OrgY + 4);

      MoveTo(OrgX + 1, OrgY);
      LineTo(OrgX + 1, OrgY + 2);

      MoveTo(OrgX + 2, OrgY);
      LineTo(OrgX + 2, OrgY + 1);
      MoveTo(OrgX + 6, OrgY);
      LineTo(OrgX + 6, OrgY + 2);

      MoveTo(OrgX + 5, OrgY);
      LineTo(OrgX + 5, OrgY + 1);

      MoveTo(OrgX + 3, OrgY);
      LineTo(OrgX + 3, OrgY + 8);
      MoveTo(OrgX + 4, OrgY);
      LineTo(OrgX + 4, OrgY + 8);

      MoveTo(OrgX + 1, OrgY + 8);
      LineTo(OrgX + 6, OrgY + 8);
    end;
  end;
begin
  with FBitmap.Canvas do begin
    Brush.Style := bsClear;
    Brush.Color := background;
    FillRect(Rect(0, 0, 12, 12));
    DrawT(0, 0, clGray);
    DrawT(3, 3, wpClWindowText);
  end;
end;

procedure TWPComboBox.ColBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  color: Integer;
  alist: TComboBox;
  i: Integer;
  aColor: TColor;
const
  Col: array[0..15] of TColor =
  (clBlack, clRed, clGreen, clBlue, clYellow,
    clFuchsia, clPurple, clMaroon, clLime, clAqua, clTeal, clNavy,
    clWhite, clLtGray, clGray, clBlack);
begin
  alist := Control as TComboBox;
  { if index <> alist.ItemIndex then  }InflateRect(Rect, -2, -1);
  if (Index = 0) and (alist.Tag <> 3) then
  begin
    if ComboBoxStyle = cbsColor then alist.Canvas.Brush.Color := clBlack
    else alist.Canvas.Brush.Color := clWindow;
  end else
  begin
    color := StrToIntDef(alist.Items.Strings[Index], 0);

    if (FRTFEdit <> nil) and (FRTFEdit is TWPCustomRtfEdit) then
    begin
      acolor := FRTFEdit.TextColors[color];
      alist.Canvas.Brush.Color := acolor;
    end else
      if (Parent is TWPCustomToolPanel) and
        (TWPCustomToolPanel(Parent).RtfEdit <> nil)
        then
      begin
        acolor := TWPCustomToolPanel(Parent).RtfEdit.TextColors[color];
        alist.Canvas.Brush.Color := acolor;
      end else
        if color < 15 then alist.Canvas.Brush.Color := Col[color];
  end;
  alist.Canvas.Pen.Color := clBlack;
  alist.Canvas.Pen.Style := psSolid;
  alist.Canvas.Pen.Width := 1;
  alist.Canvas.FillRect(Rect);
  alist.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  if FComboBoxStyle = cbsParColor then
  begin
    i := (Rect.Bottom - Rect.Top) div 3;
    alist.Canvas.MoveTo(Rect.Left, Rect.Top + i - 1);
    alist.Canvas.LineTo(Rect.Right, Rect.Top + i - 1);
    alist.Canvas.MoveTo(Rect.Left, Rect.Top + i * 2);
    alist.Canvas.LineTo(Rect.Right, Rect.Top + i * 2);
  end;
end;

procedure TWPComboBox.Click;
var
  typ: TWpSelNr;
  str: string;
  num: Integer;
begin
  inherited Click;
  if DontApplyChanges then exit;
  num := 0;
  if Assigned(_OnClick) then _OnClick(Self);
  if Assigned(FRtfEdit) then
  begin
    if ItemIndex >= 0 then str := Items[ItemIndex]
    else Str := '';
    Typ := wptNone;
    case FComboBoxStyle of
      cbsPrinterFonts, cbsTrueTypeFonts, cbsScreenFonts, cbsAnyFonts:
        begin
          Typ := wptName;
        end;
      cbsFontSize, cbsFontSizeManual, cbsHtmlFontSize:
        begin
          Typ := wptSize;
          num := StrToIntDef(str, 0);
        end;
      cbsColor:
        begin
          Typ := wptColor;
          num := StrToIntDef(str, 0);
        end;
      cbsBKColor:
        begin
          Typ := wptBKColor;
          num := StrToIntDef(str, 0);
        end;
      cbsParColor:
        begin                     
          Typ := wptParColor;
          num := StrToIntDef(str, 0);
        end;
      cbsParAlignment:
        begin
          Typ := wptParAlign;
          num := ItemIndex;
        end;
      cbsStyleNames, cbsStyleNamesEx:
        begin
          Typ := wptStyleNames;
          if ItemIndex > -1 then
            str := Items[ItemIndex];
        end;
    end;
    FLockUpdate := TRUE;
    try
    if FRtfEdit.Visible then Windows.SetFocus(FRTFEdit.Handle);

    if Typ <> wptNone then
      FRtfEdit.OnToolBarSelection(Parent, Typ, str, num);
    finally
      FLockUpdate := FALSE;
    end;
  end;
end;

end.

