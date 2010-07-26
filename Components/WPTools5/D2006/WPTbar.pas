{ -----------------------------------------------------------------------------
  WPTbar  - Copyright (C) 2002 by wpcubed GmbH    -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  The good old TWPToolBar -  now for WPTools 5
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

unit WPTbar;
{$R WPTBRES.RES}

interface

{$I WPINC.INC}


uses
  Windows, SysUtils, Messages, Buttons, Classes, Graphics, Controls, Printers,
  Forms, Dialogs, ExtCtrls, StdCtrls, Menus, WPRTEDefs, WPCtrMemo, WPCtrRich,
  WPUtil, WPActnStr, WPAction;

{$DEFINE USESTYLES}


const
{$IFNDEF T2H}
  NumSpeedButtons = 90;
  MaxCtrlElements = 99; { used to store enabled + down state	}
  MIN_DISTANCE = 2;
  GLYPHWIDTH = 16;
{$ENDIF}
type
{$IFNDEF DELPHI3ANDUP}
{$IFNDEF WPTOOLBAR97}
{$DEFINE FLATWPBUT} { use WPTools Button	style }
{$ENDIF}
{$ENDIF}

{$DEFINE WPVER3}
{$IFNDEF T2H}
{$IFDEF EXPLORERBUTTONS}
  TWPSpeedButton = class(TExplorerButton)
{$ELSE}
{$IFDEF WPTOOLBAR97}
  TWPSpeedButton = class(TToolBarButton97)
{$ELSE}
{$IFDEF DELPHI4xxxxx}
  TWPSpeedButton = class(TToolButton)
{$ELSE}
    TWPSpeedButton = class(TSpeedButton)
{$ENDIF}
{$ENDIF}
{$ENDIF}
    public
      FRtfEdit: TWPCustomRichText;
      FLastEnabled: Boolean;
      FLastEnabledValid: Boolean;
{$IFDEF FLATWPBUT}
    private
      FFlatStyle: Boolean;
      FMouseInControl: Boolean;
      procedure SetFlatStyle(x: Boolean);
    protected
      procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    public
      procedure Paint; override;
      constructor Create(AOwner: TComponent); override;
    published
      property Flat: Boolean read FFlatStyle write SetFlatStyle;
{$ENDIF}
    end;

  TWPSpeedButtonRec = record
    name: string;
    index: Integer;
    group: Integer;
    number: Integer;
    Face: TWPSpeedButton;
  end;

{ You may select these Icons in tree groups }
  {$IFNDEF T2H}
  TWpTbIcon = (SelNormal, SelBold, SelItalic, SelUnder, SelHyperLink,
    SelStrikeOut, SelSuper, SelSub, SelHidden, SelProtected,
    SelRTFCode,
    SelLeft, SelRight, SelBlock, SelCenter);

  TWpTbIcon2 = (SelExit, SelNew, SelOpen, SelSave, SelClose,
    SelPrint, SelPrintSetup, SelFitWidth, SelFitHeight,
    SelZoomIn, SelZoomOut, SelNextPage, SelPriorPage);

  TWPTbIcon3 = (SelToStart, SelNext, SelPrev, SelToEnd, SelEdit, SelAdd, SelDel,
    SelCancel, SelPost);

  TWPTbIcon4 = (SelUndo, SelRedo, SelDeleteText, SelCopy, SelCut, SelPaste, SelSelAll, SelHideSel,
    SelFind, SelReplace, SelSpellCheck);

  TWPTbIcon5 = (SelCreateTable, SelSelRow, SelInsRow, SelDelRow, SelInsCol,
    SelDelCol, SelSelCol,
    SelSplitCell, SelCombineCell,
    SelBAllOff, SelBAllOn, SelBInner, SelBOuter
    , SelBLeft, SelBRight, SelBTop, SelBBottom);

  TWPTbIcon6 = (SelBullets, SelNumbers, SelNextLevel, SelPriorLevel,
    SelParProtect, SelParKeep);

  TwpTbIcons = set of TWpTbIcon;

  TwpTbIcons2 = set of TWpTbIcon2;

  TwpTbIcons3 = set of TWpTbIcon3;

  TwpTbIcons4 = set of TWpTbIcon4;

  TwpTbIcons5 = set of TWpTbIcon5;

  TwpTbIcons6 = set of TWpTbIcon6;

  TWpTbListbox = (SelFontName, SelFontSize, SelFontColor, SelBackgroundColor,
    SelStyle, SelParColor);

  TwpTbListboxen = set of TWpTbListbox;
  {$ELSE}
  TWpTbIcons = set of (SelNormal, SelBold, SelItalic, SelUnder, SelHyperLink,
    SelStrikeOut, SelSuper, SelSub, SelHidden, SelProtected,
    SelRTFCode,
    SelLeft, SelRight, SelBlock, SelCenter);

  TWpTbIcons2 = set of (SelExit, SelNew, SelOpen, SelSave, SelClose,
    SelPrint, SelPrintSetup, SelFitWidth, SelFitHeight,
    SelZoomIn, SelZoomOut, SelNextPage, SelPriorPage);

  TWPTbIcons3 = set of (SelToStart, SelNext, SelPrev, SelToEnd, SelEdit, SelAdd, SelDel,
    SelCancel, SelPost);

  TWPTbIcons4 = set of (SelUndo, SelCopy, SelCut, SelPaste, SelSelAll, SelHideSel,
    SelFind, SelReplace, SelSpellCheck);

  TWPTbIcons5 = set of (SelCreateTable, SelSelRow, SelInsRow, SelDelRow, SelInsCol,
    SelDelCol, SelSelCol,
    SelSplitCell, SelCombineCell,
    SelBAllOff, SelBAllOn, SelBInner, SelBOuter
    , SelBLeft, SelBRight, SelBTop, SelBBottom);

  TWPTbIcons6 = set of (SelBullets, SelNumbers, SelNextLevel, SelPriorLevel,
    SelParProtect, SelParKeep);

  TWpTbListboxen = set of (SelFontName, SelFontSize, SelFontColor, SelBackgroundColor,
    SelStyle, SelParColor);
  {$ENDIF}


  TWPTBCombo = class(TWPTBCustomCombo)
  public
    FLastEnabled: Boolean;
    FLastEnabledValid: Boolean;
    procedure CreateWnd; override;
  protected
    procedure UpdateSel; virtual;
  private
    FCTStr: string;
    SaveIndex: Integer;
    WasCancelled: Boolean;
    FOnCloseUP: TNotifyEvent;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure DoCloseUp; dynamic;
    property OnCloseUP: TNotifyEvent read FOnCloseUP write FOnCloseUp;
  published
    property Style; {Must be published before Items}
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
  end;

  PTFont = ^TFont;
  PTBrush = ^TBrush;
{$ENDIF}

  TWPHorzLine = (wplTop, wplBottom);
  TWPHorzLines = set of TWPHorzLine;

  TWPCustomToolPanel = class(TWPCustomToolCtrl)
  private
    FBevelInner: TPanelBevel;
    FBevelOuter: TPanelBevel;
    FBevelWidth: TBevelWidth;
    FBorderWidth: TBorderWidth;
    FBorderStyle: TBorderStyle;
    FHorzLines: TWPHorzLines;
    FFullRepaint: Boolean;
    FLocked, FTrueTypeOnly: Boolean;
    FOnResize: TNotifyEvent;
    FAlignment: TAlignment;
    fUpdateCount: Integer;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message
      CM_ENABLEDCHANGED;
{$IFDEF WIN32}
    procedure CMIsToolControl(var Message: TMessage); message CM_ISTOOLCONTROL;
{$ENDIF}
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message
      WM_WINDOWPOSCHANGED;
    procedure SetHorzLines(x: TWPHorzLines);
    procedure SetAlignment(Value: TAlignment);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetTrueTypeOnly(x: Boolean);
  public
{$IFNDEF T2H}
    procedure PerformAll(m: Cardinal; w, l: Longint); override;
{$ENDIF}
  protected
    FRecursion: Boolean;
    FMovable: Boolean;
    FSizeable: Boolean;
    procedure CreateWnd; override;
    procedure WMNCHitTest(var Msg: TWMMouse); message WM_NCHITTEST;
    procedure SetRTFedit(x: TWPCustomRichText); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure Init; virtual;
    procedure UpdateSel; override;
    procedure Resize; {$IFDEF	DELPHI4} override; {$ELSE} virtual; {$ENDIF}
    property TrueTypeOnly: Boolean read FTrueTypeOnly write SetTrueTypeOnly;
    property Alignment: TAlignment read FAlignment write SetAlignment default
      taCenter;
    property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default
      bvNone;
    property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default
      bvRaised;
    property BevelWidth: TBevelWidth read FBevelWidth write SetBevelWidth default
      1;
    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth
      default 0;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsNone;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default
      True;
    property Locked: Boolean read FLocked write FLocked default False;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  public
{$IFNDEF T2H}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    function SelectIcon(index, group, num: Integer): Boolean; override;
    function DeselectIcon(index, group, num: Integer): Boolean; override;
    function EnableIcon(index, group, num: Integer; enabled: Boolean): Boolean;
      override;
    procedure EnableControls(state: Boolean; ExclList: array of TControl);
    procedure UpdateSelection(Typ: TWpSelNr; const str: string; num: Integer);
      override;
    { procedure	UpdateFromFont(Fon:TFont;const Bru:PTBrush); }
    procedure UpdateEnabledState; override;
    property Moveable: Boolean read FMovable write FMovable;
    property Sizeable: Boolean read FSizeable write FSizeable;
    property BevelLines: TWPHorzLines read FHorzLines write SetHorzLines;
{$IFDEF DELPHI4}
  public
    property DockManager;
  published
    property Color default clBtnFace;
    property ParentColor default TRUE;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Constraints;
    property UseDockManager default True;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property ParentBiDiMode;
    property OnCanResize;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
{$ENDIF}
{$ENDIF}
  end;

TWPSelectEvent = procedure(Sender: TObject;
    var Typ: TWpSelNr;
    const str: string;
    const num: Integer) of object;

  TWPIconSelectEvent = procedure(Sender: TObject;
    var Typ: TWpSelNr;
    const str: string;
    const group: Integer;
    const num: Integer;
    const index: Integer) of object;

  TFontSelChoice = (fsPrinterFonts, fsScreenFonts);

  PTWPToolBar = ^TWPToolBar;
  TWPToolBar = class(TWPCustomToolPanel)
  private
    FChildsEnabled: Boolean;
    FBitmap: TBitmap;
    FStyleString: string;
    FCanvas: TControlCanvas;
    FFontChoice: TFontSelChoice;
    FontName: TWPTBCombo;
    HasFontTypes: Integer;
    FFlatButtons: Boolean;
    FLockedCount: Integer;
    FKeepGroupsTogether: Boolean;
    FontSize: TWPTBCombo;
    FontColor: TWPTBCombo;
    FontBKColor: TWPTBCombo;
    ParBKColor: TWPTBCombo;
    FontType: TWPTBCombo;
    FontInFont: Boolean;
    fsSelection: TwpTbListboxen;
    fsIntIcons: TwpTbIcons;
    fsIntIcons2: TwpTbIcons2;
    fsIntIcons3: TwpTbIcons3;
    fsIntIcons4: TwpTbIcons4;
    fsIntIcons5: TwpTbIcons5;
    fsIntIcons6: TwpTbIcons6;
    fsFontSizeFrom, fsFontSizeTo: Integer;
    IconsLoaded: Boolean;
    may_align: Boolean;
{$IFNDEF WIN32}
    ctrl_elements_down: array[0..MaxCtrlElements] of Boolean;
{$ENDIF}
    {ctrl_el_anz	  : Integer;}
    { reference	the self created speed buttons }
    Speedb: array[1..NumSpeedButtons] of TWPSpeedButtonRec;
    Speedb_anz: Integer;
    fsUpDateObjp: TComponent;
    fsUpDateName: string;
    fsShowFace: Integer;
    FWidthBG: Integer;
    FOnSelection: TWPSelectEvent;
    FInitInProgress: Boolean;
    FOnIconSelection: TWPIconSelectEvent;
    FOnClick: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseEvent;
    FButtonHeight: Integer;
    procedure SetKeepGroupsTogether(x: Boolean);
    procedure ctSetChildsEnabled(how: Boolean);
    procedure SetButtonHeight(x: Integer);
    procedure UpdateCaption;
  public
{$IFNDEF T2H}
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetPreviewButtons; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
{$ENDIF}
  protected
    procedure DoToolBarIconSelection(var group, num: Integer); virtual;
    procedure ColBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FontBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure UpdateObj(UpdateObjp: TComponent; typ: TWpSelNr; str: string; num:
      Integer);
    procedure SetListboxes(x: TwpTbListboxen);
    procedure SetFWidthBG(x: Integer);

    function GetIntIcons: TwpTbIcons;
    function GetIntIcons2: TwpTbIcons2;
    function GetIntIcons3: TwpTbIcons3;
    function GetIntIcons4: TwpTbIcons4;
    function GetIntIcons5: TwpTbIcons5;
    function GetIntIcons6: TwpTbIcons6;
    procedure SetIntIcons(x: TwpTbIcons);
    procedure SetIntIcons2(x: TwpTbIcons2);
    procedure SetIntIcons3(x: TwpTbIcons3);
    procedure SetIntIcons4(x: TwpTbIcons4);
    procedure SetIntIcons5(x: TwpTbIcons5);
    procedure SetIntIcons6(x: TwpTbIcons6);
    procedure SetShowFont(x: Boolean);
    procedure SetRTFedit(x: TWPCustomRichText); override;
    procedure SetFontChoice(x: TFontSelChoice);
    procedure SetStyleString(const x: string);
    function GetShowFont: Boolean;
    procedure DrawPic(Background: TColor);
    procedure AddIcon(const name: string; index, group, num: Integer);
    procedure AlignAllControls;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
{$IFNDEF T2H}
    UseSameGroupForAllButtons, FHold: Boolean;
    procedure DoClick(Sender: TObject);
    procedure DoStyleDropDown(Sender: TObject);
    procedure Exit(Sender: TObject);
    procedure Change(Sender: TObject);
    procedure Init; override;
    procedure CreateWnd; override;
    procedure AddControl(comp: TControl);
    procedure RemoveControl(comp: TControl);
    procedure BeginUpdate;
    procedure EndUpdate;
{$ENDIF}
    function SelectIcon(index, group, num: Integer): Boolean; override;
    function DeselectIcon(index, group, num: Integer): Boolean; override;
    function EnableIcon(index, group, num: Integer; enabled: Boolean): Boolean;
      override;
    procedure SetFontSelect(var fon: TFont);
    function GetIcon(index, group, num: Integer): TWPSpeedButton;
    function GetStyleItems: TStrings;
    function GetFontItems: TStrings;
    function GetSizeItems: TStrings;
    function GetStyleBox: TComboBox;
    function GetFontBox: TComboBox;
    function GetSizeBox: TComboBox;
    procedure UpdateSelection(Typ: TWpSelNr; const str: string; num: Integer);
      override;
    { procedure	UpdateFromFont(Fon:TFont;const Bru:PTBrush);   }
    property ChildsEnabled: Boolean read FChildsEnabled write
      ctSetChildsEnabled;
    property StyleString: string read FStyleString write SetStyleString;
  published
    { Published-Deklarationen }
    property KeepGroupsTogether: Boolean read FKeepGroupsTogether write
      SetKeepGroupsTogether;
{$IFNDEF T2H}
    property Color default clBtnFace;
    property ParentColor default TRUE;
    property Align;
    property Font;
    property Height default 32;
    property Width default 300;
    property Locked;
    property Caption;
    property ParentShowHint;
    property ShowHint;
    property PopupMenu;
    property Enabled;
    property Visible;
    property BevelLines;
    property BevelInner;
    property AutoEnabling;
    property BevelOuter;
    property BevelWidth;
{$ENDIF}
    property WidthBetweenGroups: Integer read FWidthBG write SetFWidthBG;
    property FontChoice: TFontSelChoice read FFontChoice write SetFontChoice;
    property UpdateObject: TComponent read fsUpdateObjp write fsUpdateObjp;
    property UpdateObjectName: string read fsUpdateName write fsUpdateName;
    property ShowFont: Boolean read GetShowFont write SetShowFont default FALSE;
    property sel_ListBoxes: TWpTbListboxen read fsSelection write SetListboxes;
    property sel_StatusIcons: TWpTbIcons read GetIntIcons write SetIntIcons;
    property sel_ActionIcons: TWpTbIcons2 read GetIntIcons2 write SetIntIcons2;
    property sel_DatabaseIcons: TWpTbIcons3 read GetIntIcons3 write SetIntIcons3;
    property sel_EditIcons: TWpTbIcons4 read GetIntIcons4 write SetIntIcons4;
    property sel_TableIcons: TWpTbIcons5 read GetIntIcons5 write SetIntIcons5;
    property sel_OutlineIcons: TWpTbIcons6 read GetIntIcons6 write SetIntIcons6;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property FontSizeFrom: Integer read fsFontSizeFrom write fsFontSizeFrom
      default 7;
    property FontSizeTo: Integer read fsFontSizeTo write fsFontSizeTo default
      72;
    property OnSelection: TWPSelectEvent read FOnSelection write FOnSelection;
    property OnIconSelection: TWPIconSelectEvent read FOnIconSelection write
      FOnIconSelection;
    property FlatButtons: Boolean read FFlatButtons write FFlatButtons;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight;
    property TrueTypeOnly;
    property NextToolBar;
{$IFNDEF T2H}
{$IFDEF DELPHI4}
    property Anchors;
    property Constraints;
{$ENDIF}
{$ENDIF}
  end;

var
  {: IF this global boolen is trie the toolbar will not assign defauls buttons }
  FWPNotInitializeButtons : Boolean;
  {: Set this property to true if you are using the TWPToolBar in an MDI application }
  WPIsMDIApp: Boolean;

procedure WPUpdateNumberCombo(combo: TComboBox; num: Integer);

implementation


procedure TWPTBCombo.CNCommand(var Message: TWMCommand);
begin
  case Message.NotifyCode of
    cbn_Dropdown:
      begin
        FCtStr := Text;
        SaveIndex := ItemIndex;
        WasCancelled := False;
        inherited;
      end;
    cbn_SelEndCancel:
      WasCancelled := True;
    cbn_Closeup:
      begin
        if WasCancelled then
        begin
          ItemIndex := SaveIndex;
          if FRTFEdit <> nil then
            Windows.SetFocus(FRTFEdit.Handle);
          Exit;
        end;
        if Text = FctStr then
        begin
          DoCloseUP;
          Text := Items[ItemIndex];
          Click;
          Change;
        end
        else
        begin
          if ItemIndex = -1 then
            ItemIndex := SaveIndex
          else
            Text := Items[ItemIndex];
          Click;
          Change;
        end;
      end;
    cbn_selchange:
  else
    inherited
  end;
end;

procedure TWPTBCombo.DoCloseUp;
begin
  if Assigned(FOnCloseUp) then FOnCloseUp(Self);
end;

procedure TWPTBCombo.CreateWnd;
begin
  inherited CreateWnd;
end;

procedure TWPTBCombo.UpdateSel;
begin

end;

destructor TWPCustomToolPanel.Destroy;
begin
  inherited destroy;
end;

{ Initialize the variable WPTBRCTRL wich will never be destroyed }

procedure TWPCustomToolPanel.SetTrueTypeOnly(x: Boolean);
begin
  if FTrueTypeOnly <> x then
  begin
    WPTInitFonts;
    FTrueTypeOnly := x;
    Init;
  end;
end;

procedure TWPCustomToolPanel.BeginUpdate;
begin
  Inc(fUpdateCount);
end;

procedure TWPCustomToolPanel.EndUpdate;
begin
  if fUpdateCount > 0 then
    Dec(fUpdateCount);
end;

procedure TWPCustomToolPanel.PerformAll(m: Cardinal; w, l: Longint); { V1.99f }
begin
  case m of
    WP_RTFEDIT_CHANGED: RTFEdit := Pointer(l);
    WP_SEL_ICON:
      if w = WP_ICONDOWN then
        SelectIcon(0, l and $FF00, l and $FF)
      else
        DeSelectIcon(0, l and $FF00, l and $FF);
    WP_ENABLE_ICON:
      if w = 1 then
        EnableIcon(0, l and $FF00, l and $FF, TRUE)
      else
        EnableIcon(0, l and $FF00, l and $FF, FALSE);
  end;
end;

procedure TWPCustomToolPanel.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  UpdateEnabledState;
end;

procedure TWPCustomToolPanel.UpdateEnabledState;
var
  i, c: Integer;
  e: Boolean;
begin
  if fUpdateCount > 0 then Exit;
  i := 0;
  c := ControlCount;
  e := Enabled;
  while i < c do
  begin
    if Controls[i] is TWPSpeedButton then
      with TWPSpeedButton(Controls[i]) do
      begin
        if not FLastEnabledValid then
        begin
          FLastEnabledValid := TRUE;
          FLastEnabled := Enabled;
        end;
        if not e then
          Enabled := FALSE
        else
        begin
          if AutoEnabling then
            Enabled := FLastEnabled
          else Enabled := TRUE;
          FLastEnabledValid := FALSE;
        end;
      end
    else if Controls[i] is TWPTBCombo then
      with TWPTBCombo(Controls[i]) do
      begin
        if not FLastEnabledValid then
        begin
          FLastEnabledValid := TRUE;
          FLastEnabled := Enabled;
        end;
        if not e then
          Enabled := FALSE
        else
        begin
          Enabled := FLastEnabled;
          FLastEnabledValid := FALSE;
        end;
      end;
    inc(i);
  end;
end;

procedure TWPCustomToolPanel.SetRTFedit(x: TWPCustomRichText);
var
  i, c: Integer;
begin
  if FRecursion then
  begin ShowMessage(WPLoadStr(meRecursiveToolbarUsage));
    exit;
  end;
  FRecursion := TRUE;
  try
    i := 0;
    c := ControlCount;
    while i < c do
    begin
      if Controls[i] is TWPSpeedButton then
        TWPSpeedButton(Controls[i]).FRTFEdit := x
      else if (Controls[i] is TWPTBCombo) and
        (TWPTBCombo(Controls[i]).FRTFEdit<>x) then
      begin
        TWPTBCombo(Controls[i]).FRTFEdit := x;
        TWPTBCombo(Controls[i]).UpdateSel;
      end;
      inc(i);
    end;

    if x = nil then
    begin
      i := 0;
      while i < Parent.ComponentCount do
      begin
        if Parent.Components[i] is TWPCustomRtfEdit then
        begin
          with TWPCustomRtfEdit(Parent.Components[i]) do
          begin
            if Focused then
            begin
              x := TWPCustomRichText(Parent.Components[i]);
              break;
            end;
          end;
        end;
        inc(i);
      end;
    end;
    FRtfEdit := x;
    if assigned(FNextWPTCtrl) and (FNextWPTCtrl <> Self) then
      FNextWPTCtrl.RTFEdit := x;
  finally
    FRecursion := FALSE;
  end;
  inherited SetRTFedit(x);
  if FAutoEnabling then
  begin
    Enabled := FRtfEdit <> nil;
    UpdateEnabledState;
  end;
end;

procedure TWPCustomToolPanel.UpdateSel;
var i : Integer;
begin
    for i:=0 to ControlCount-1 do
    if Controls[i] is TWPTBCombo then
    begin
        TWPTBCombo(Controls[i]).UpdateSel;
    end;
end;

procedure TWPCustomToolPanel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FNextWPTCtrl) then
    FNextWPTCtrl := nil;
  if (Operation = opRemove) and (AComponent = FRTFEdit) then
    FRTFEdit := nil;
  inherited Notification(AComponent, Operation);
end;

procedure TWPCustomToolPanel.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
    SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) or WS_EX_TOOLWINDOW
      or WS_EX_TOPMOST);
end;

procedure TWPCustomToolPanel.WMNCHitTest(var Msg: TWMMouse);
var
  x: TControl;
  p: TPoint;
begin
  if (csDesigning in ComponentState) or
    (not FMovable and not FSizeable) then
    inherited
  else if FMovable or FSizeable then
  begin
    p := ScreenToClient(Point(Msg.xpos, Msg.ypos));
    x := ControlAtPos(p, TRUE);
    if x <> nil then
      inherited
    else
    begin
      if FSizeable and (p.y >= Height - 2) then
        Msg.Result := HTBottom
      else if FSizeable and (p.x >= Width - 2) then
        Msg.Result := HTRight
      else if FSizeable and (p.x >= Width - 2) and (p.y >= Height - 2) then
        Msg.Result := HTBottomRight
      else if GetAsyncKeyState(VK_LBUTTON) < 0 then
        Msg.Result := HTCAPTION
      else
        Msg.Result := HTCLIENT;
    end;
  end;

end;

procedure TWPCustomToolPanel.UpdateSelection(Typ: TWpSelNr; const str: string;
  num: Integer);
begin
  if fUpdateCount > 0 then Exit;
  if FRecursion then
  begin FNextWPTCtrl := nil;
    ShowMessage(WPLoadStr(meRecursiveToolbarUsage));
  end;
  FRecursion := TRUE;
  try
    if assigned(FNextWPTCtrl) and
      (FNextWPTCtrl <> Self) then FNextWPTCtrl.UpdateSelection(Typ, str, num);
  finally
    FRecursion := FALSE;
  end;
end;

{procedure TWPCustomToolPanel.UpdateFromFont(Fon:TFont;const Bru:PTBrush);
begin
    if FRecursion then begin FNextWPTCtrl := nil;
        ShowMessage(WPLoadStr(meRecursiveToolbarUsage));	end;
    FRecursion := TRUE;
    try
    if assigned(FNextWPTCtrl)	and
      (FNextWPTCtrl<>Self) then	FNextWPTCtrl.UpdateFromFont(Fon,Bru);
    finally
    FRecursion := FALSE;
    end;
end;}

function TWPCustomToolPanel.SelectIcon(index, group, num: Integer): Boolean;
begin
  if FRecursion then
  begin FNextWPTCtrl := nil;
    ShowMessage(WPLoadStr(meRecursiveToolbarUsage));
  end;
  FRecursion := TRUE;
  try
    if assigned(FNextWPTCtrl) and
      (FNextWPTCtrl <> Self) then
      Result := FNextWPTCtrl.SelectIcon(index, group, num)
    else
      Result := FALSE;
  finally
    FRecursion := FALSE;
  end;
end;

function TWPCustomToolPanel.DeselectIcon(index, group, num: Integer): Boolean;
begin
  if FRecursion then
  begin FNextWPTCtrl := nil;
    ShowMessage(WPLoadStr(meRecursiveToolbarUsage));
  end;
  FRecursion := TRUE;
  try
    if assigned(FNextWPTCtrl) and
      (FNextWPTCtrl <> Self) then
      Result := FNextWPTCtrl.DeselectIcon(index, group, num)
    else
      Result := FALSE;
  finally
    FRecursion := FALSE;
  end;
end;

procedure TWPCustomToolPanel.EnableControls(state: Boolean; ExclList: array of TControl);
var
  i, c: Integer;
  excl: Boolean;
  obj: TControl;
begin
  for c := 0 to ControlCount - 1 do
  begin
    excl := FALSE;
    obj := Controls[c];
    for I := 0 to High(ExclList) do
    begin
      if obj = ExclList[i] then
      begin excl := TRUE; break;
      end;
    end;
    if not excl then obj.Enabled := state;
  end;
end;

function TWPCustomToolPanel.EnableIcon(index, group, num: Integer; enabled:
  Boolean): Boolean;
begin
  if FRecursion then
  begin FNextWPTCtrl := nil;
    ShowMessage(WPLoadStr(meRecursiveToolbarUsage));
  end;
  FRecursion := TRUE;
  try
    if assigned(FNextWPTCtrl) and
      (FNextWPTCtrl <> Self) then
      Result := FNextWPTCtrl.EnableIcon(index, group, num, enabled)
    else
      Result := FALSE;
  finally
    FRecursion := FALSE;
  end;
end;

constructor TWPCustomToolPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  Width := 185;
  Height := 41;
  FAlignment := taCenter;
  BevelOuter := bvRaised;
  BevelWidth := 1;
  FBorderStyle := bsNone;
  Color := clBtnFace;
  FFullRepaint := True;
  FAutoEnabling := TRUE;
end;

procedure TWPCustomToolPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if FBorderStyle <> bsNone then
      Params.Style := Style or WS_BORDER;
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TWPCustomToolPanel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TWPCustomToolPanel.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TWPCustomToolPanel.CMIsToolControl(var Message: TMessage);
begin
  if not FLocked then Message.Result := 1;
end;

procedure TWPCustomToolPanel.Resize;
begin
{$IFDEF DELPHI4}inherited Resize; {$ENDIF}
  if Assigned(FOnResize) then FOnResize(Self);
end;

procedure TWPCustomToolPanel.WMWindowPosChanged(var Message:
  TWMWindowPosChanged);
var
  BevelPixels: Integer;
  Rect: TRect;
begin
  if FullRepaint or (Caption <> '') then
    Invalidate
  else
  begin
    BevelPixels := BorderWidth;
    if BevelInner <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelOuter <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelPixels > 0 then
    begin
      Rect.Right := Width;
      Rect.Bottom := Height;
      if Message.WindowPos^.cx <> Rect.Right then
      begin
        Rect.Top := 0;
        Rect.Left := Rect.Right - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
      if Message.WindowPos^.cy <> Rect.Bottom then
      begin
        Rect.Left := 0;
        Rect.Top := Rect.Bottom - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
    end;
  end;
  inherited;
  if not (csLoading in ComponentState) then Resize;
end;

procedure TWPCustomToolPanel.AlignControls(AControl: TControl; var Rect: TRect);
var
  BevelSize: Integer;
begin
  BevelSize := BorderWidth;
  if BevelOuter <> bvNone then Inc(BevelSize, BevelWidth);
  if BevelInner <> bvNone then Inc(BevelSize, BevelWidth);
  InflateRect(Rect, -BevelSize, -BevelSize);
  inherited AlignControls(AControl, Rect);
end;

procedure TWPCustomToolPanel.Init;
begin
end;

procedure TWPCustomToolPanel.Paint;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);

  procedure ADJUSTCOLORS(BEVEL: TPANELBEVEL);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with Rect do
    begin
      Top := ((Bottom + Top) - FontHeight) div 2;
      Bottom := Top + FontHeight;
    end;

    if wplTop in FHorzLines then
    begin
      with Canvas do
      begin
        Pen.Color := clBtnShadow;
        MoveTo(0, 0);
        LineTo(Width, 0);
        Pen.Color := clWhite;
        MoveTo(0, 1);
        LineTo(Width, 1);
      end;
    end;

    if wplBottom in FHorzLines then
    begin
      with Canvas do
      begin
        Pen.Color := clBtnShadow;
        MoveTo(0, Height - 2);
        LineTo(Width, Height - 2);
        Pen.Color := clWhite;
        MoveTo(0, Height - 1);
        LineTo(Width, Height - 1);
      end;
    end;

    { DrawText(Handle, PChar(Caption), -1, Rect,	(DT_EXPANDTABS or
       DT_VCENTER) or Alignments[FAlignment]); }
  end;
end;

procedure TWPCustomToolPanel.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetHorzLines(x: TWPHorzLines);
begin
  FHorzLines := x;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetBevelInner(Value: TPanelBevel);
begin
  FBevelInner := Value;
  Realign;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetBevelOuter(Value: TPanelBevel);
begin
  FBevelOuter := Value;
  Realign;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetBevelWidth(Value: TBevelWidth);
begin
  FBevelWidth := Value;
  Realign;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetBorderWidth(Value: TBorderWidth);
begin
  FBorderWidth := Value;
  Realign;
  Invalidate;
end;

procedure TWPCustomToolPanel.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TWPToolBar.SetPreviewButtons;
begin
  sel_ActionIcons := [SelExit, SelPrint, SelPrintSetup, SelFitWidth,
    SelFitHeight, SelZoomIn, SelZoomOut, SelNextPage, SelPriorPage];
  sel_DatabaseIcons := [];
  sel_EditIcons := [];
  sel_ListBoxes := [];
  sel_StatusIcons := [];
end;

var
  FAllToolbar: TList;

procedure TWPToolbar.UpdateCaption;
var
  a: Integer;
  hStr, cStr: string;
begin
  hStr := '';
  cStr := '';
  if (FontName <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wptName), cStr, hStr) then
    FontName.Hint := hStr;
  if (FontSize <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wptSize), cStr, hStr) then
    FontSize.Hint := hStr;
  if (FontColor <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wptColor), cStr, hStr) then
    FontColor.Hint := hStr;
  if (FontBKColor <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wptBkColor), cStr, hStr) then
    FontBKColor.Hint := hStr;
  if (FontType <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wpaParStyleSelection), cStr, hStr) then
    FontType.Hint := hStr;
  if (ParBKColor <> nil) and
    WPGetActionHintCap(WPI_GR_DROPDOWN, Integer(wptParColor), cStr, hStr) then
    ParBKColor.Hint := hStr;
  for a := 1 to Speedb_anz do
    if (Speedb[a].Face <> nil) and
      WPGetActionHintCap(Speedb[a].Group, Speedb[a].number, cStr, hStr) then
      Speedb[a].Face.Hint := hStr;
end;

constructor TWPToolBar.Create;
var
  i: Integer;
const
  Col: array[0..15] of TColor =
  (clBlack, clRed, clGreen, clBlue, clYellow,
    clFuchsia, clPurple, clMaroon, clLime, clAqua, clTeal, clNavy,
    clWhite, clLtGray, clGray, clBlack);
begin
  inherited Create(aOwner);
  FAllToolbar.Add(self);
  FBitmap := TBitmap.Create;
  FBitmap.Height := 12;
  FBitmap.Width := 12;
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  Width := 300;
  Height := 31;
  FontInFont := TRUE;
  ChildsEnabled := False;
  FontChoice := fsPrinterFonts;
  BevelWidth := 1;
  if (fsFontSizeFrom = 0) and (fsFontSizeTo = 0) then
  begin fsFontSizeFrom := 8;
    fsFontSizeTo := 72;
  end;
  BorderStyle := bsNone;
  for i := 0 to 15 do FDefaultPalette[i] := col[i];
  if not FWPNotInitializeButtons then
  begin
    sel_ListBoxes   := [SelFontName, SelFontSize, SelFontColor, SelParColor];
    sel_StatusIcons := [SelBold, SelItalic, SelUnder, SelLeft, SelRight, SelBlock, SelCenter];
    sel_ActionIcons := [SelOpen,SelSave,SelPrint,SelPrintSetup];
    sel_EditIcons   := [SelCopy, SelCut, SelPaste, SelFind, SelReplace];
    sel_TableIcons  := [SelCreateTable];
  end;
  Caption := '';
  {  Align := alTop;  }
  WidthBetweenGroups := 4;
  KeepGroupsTogether := TRUE;
end;

destructor TWPToolBar.Destroy;
var
  i: Integer;
begin
  i := FAllToolbar.IndexOf(self);
  if i >= 0 then FAllToolbar.Delete(i);
  for i := 1 to NumSpeedButtons do  // V5.11.1
  with Speedb[i] do
  if Face <> nil then
  begin
          Face.Parent := nil;
          Face.Free;
          Face := nil;
  end;
  FBitmap.Free;
  FCanvas.Free;
  inherited Destroy;
end;

procedure TWPToolBar.SetFontChoice(x: TFontSelChoice);
begin
  if x <> FFontChoice then
  begin
    FFontChoice := x;
    Init;
  end;
end;

procedure TWPToolBar.SetFWidthBG(x: Integer);
begin
  if FWidthBG <> x then
  begin FWidthBG := x;
    AlignAllControls;
  end;
end;

procedure TWPToolBar.SetKeepGroupsTogether(x: Boolean);
begin
  FKeepGroupsTogether := x;
  AlignAllControls;
end;

procedure TWPToolBar.AlignAllControls;
var
  i, h, off, ic_top, WindowH, offset, PriorGroupIndex: Integer;
  LastGroupStart: Integer;
  LastGroupStartCount: Integer;
begin
  if may_align then
  begin
    offset := 0;
    if BevelOuter <> bvNone then offset := BevelWidth;
    inc(offset, BevelWidth);

    ic_top := offset + 2;
    h := 0;
    off := offset + 2;
    { 1. Step:	allign all WPTBComo }
    i := 0;
    while i < ControlCount do
    begin
      if Controls[i].Visible and (Controls[i] is TWPTBCombo) then
      begin
        if (off + TWPTBCombo(Controls[i]).Width > Width - offset) and (off > 4)
          then
        begin
          ic_top := ic_top + h + 4;
          off := offset + 2;
          h := 0;
        end;

        if TWPTBCombo(Controls[i]).Height > h then
          h := TWPTBCombo(Controls[i]).Height;
        off := off + MIN_DISTANCE;

        TWPTBCombo(Controls[i]).Left := off;
        TWPTBCombo(Controls[i]).Top := ic_top;
        off := off + TWPTBCombo(Controls[i]).Width;
      end;
      inc(i);
    end;

    { 2. Step:	align all SpeedButtons with name = '' }
    i := 0;
    PriorGroupIndex := -1;
    LastGroupStart := -1;
    LastGroupStartCount := 1;
    while i < ControlCount do
    begin
      if Controls[i].Visible and (Controls[i] is TWPSpeedButton) and (TWPSpeedButton(Controls[i]).Name =
        '') then
      begin
        if PriorGroupIndex = -1 then
          PriorGroupIndex := TWPSpeedButton(Controls[i]).GroupIndex;
        if (off + TWPSpeedButton(Controls[i]).Width
          + WidthBetweenGroups { V1.99g }
          > Width - offset) and (off > 4) then
        begin
          ic_top := ic_top + h + 4;
          off := offset + 2;
          h := 0;
          PriorGroupIndex := -1;
          if FKeepGroupsTogether and
            (LastGroupStartCount > 0) and (LastGroupStart > 0) then
          begin
            i := LastGroupStart;
            LastGroupStartCount := 0;
            continue;
          end;
        end;

        if TWPSpeedButton(Controls[i]).Height > h then
          h := TWPSpeedButton(Controls[i]).Height;
        if ((TWPSpeedButton(Controls[i])).GroupIndex shr 8 <> PriorGroupIndex shr
          8) and (off > 10) then
        begin off := off + FWidthBG;
          PriorGroupIndex := (TWPSpeedButton(Controls[i])).GroupIndex;
          LastGroupStart := i;
          inc(LastGroupStartCount);
        end
        else
          off := off + MIN_DISTANCE;

        TWPSpeedButton(Controls[i]).Left := off;
        TWPSpeedButton(Controls[i]).Top := ic_top - 1;
        off := off + TWPSpeedButton(Controls[i]).Width;
      end;
      inc(i);
    end;

    { 3. Step:	align the rest }
    i := 0;
    while i < ControlCount do
    begin
      if Controls[i].Visible and not ((Controls[i] is TWPSpeedButton) and
        (TWPSpeedButton(Controls[i]).Name = '')) and
        not (Controls[i] is TWPTBCombo) and
        (Controls[i].Align = alNone) then
      begin
        if (off + Controls[i].Width > Width - offset) and (off > 4) then
        begin
          ic_top := ic_top + h + 4;
          off := offset + 2;
          h := 0;
        end;

        if Controls[i].Height > h then
          h := (Controls[i]).Height;
        if (Controls[i] is TWPSpeedButton) and
          (TWPSpeedButton(Controls[i]).GroupIndex shr 8 <> PriorGroupIndex shr 8)
          and (off > 10) then
        begin off := off + FWidthBG;
          PriorGroupIndex := (TWPSpeedButton(Controls[i])).GroupIndex;
        end
        else
          off := off + MIN_DISTANCE;

        (Controls[i]).Left := off;
        (Controls[i]).Top := ic_top - 1;
        off := off + (Controls[i]).Width;
      end;
      inc(i);
    end;
    WindowH := ic_top + h;
    if (Height <> WindowH + offset + 2) and ((Align = alTop) or (Align = alBottom)) then
    begin
      Height := WindowH + offset + 2;
      if (Parent <> nil) and not WPIsMDIApp then
      begin
        if not (Parent is TForm) or
          (TForm(Parent).FormStyle <> fsMdiChild) or
          (TForm(Parent).WindowState <> wsMaximized) then
          PostMessage(Parent.Handle, WM_SIZE, 0, 0);
      end;
    end;
  end;
end;

procedure TWPToolBar.WMSize(var Message: TWMSize);
begin
  if not (csLoading in ComponentState) then
  begin
    may_align := TRUE;
    AlignAllControls;
    may_align := TRUE;
  end;
  inherited;
end;

procedure TWPToolBar.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (fsUpDateObjp <> nil) and
    (AComponent = UpdateObject) then UpdateObject := nil;
end;

procedure TWPToolBar.SetRTFedit(x: TWPCustomRichText);
begin
  FRtfEdit := x; { update status }
  inherited SetRTFedit(x);
end;

procedure TWPToolBar.SetListboxes(x: TwpTbListboxen);
begin
  fsSelection := x;
  if not (csloading in self.ComponentState) then Init;
end;

function TWPToolBar.GetIntIcons: TwpTbIcons;
begin
  Result := fsIntIcons;
end;

function TWPToolBar.GetIntIcons2: TwpTbIcons2;
begin
  Result := fsIntIcons2;
end;

function TWPToolBar.GetIntIcons3: TwpTbIcons3;
begin
  Result := fsIntIcons3;
end;

function TWPToolBar.GetIntIcons4: TwpTbIcons4;
begin
  Result := fsIntIcons4;
end;

function TWPToolBar.GetIntIcons5: TwpTbIcons5;
begin
  Result := fsIntIcons5;
end;

function TWPToolBar.GetIntIcons6: TwpTbIcons6;
begin
  Result := fsIntIcons6;
end;

procedure TWPToolBar.SetIntIcons(x: TwpTbIcons);
begin
  fsIntIcons := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetStyleString(const x: string);
begin
  FStyleString := x;
  if not (csloading in self.ComponentState) and not FHold then Init;
end;

procedure TWPToolBar.SetIntIcons2(x: TwpTbIcons2);
begin
  fsIntIcons2 := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetIntIcons3(x: TwpTbIcons3);
begin
  fsIntIcons3 := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetIntIcons4(x: TwpTbIcons4);
begin
  fsIntIcons4 := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetIntIcons5(x: TwpTbIcons5);
begin
  fsIntIcons5 := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetIntIcons6(x: TwpTbIcons6);
begin
  fsIntIcons6 := x;
  if not (csloading in self.ComponentState) then Init;
end;

procedure TWPToolBar.SetShowFont(x: Boolean);
begin
  if x then
    fsShowFace := 1
  else
    fsShowFace := 0;
  if FontName <> nil then FontName.Update;
end;

function TWPToolBar.GetShowFont: Boolean;
begin
  Result := fsShowFace <> 0;
end;

procedure TWPToolBar.BeginUpdate;
begin
  inc(FLockedCount);
end;

procedure TWPToolBar.EndUpdate;
begin
  dec(FLockedCount);
  if FLockedCount <= 0 then
  begin FLockedCount := 0; Init;
  end;
end;

function TWPToolBar.GetStyleBox: TComboBox;
begin
  Result := FontType;
end;

function TWPToolBar.GetStyleItems: TStrings;
begin
  if FontType <> nil then
    Result := FontType.Items
  else
    result := nil;
end;

function TWPToolBar.GetFontBox: TComboBox;
begin
  Result := FontName;
end;

function TWPToolBar.GetFontItems: TStrings;
begin
  if FontName <> nil then
    Result := FontName.Items
  else
    result := nil;
end;

function TWPToolBar.GetSizeBox: TComboBox;
begin
  Result := FontSize;
end;

function TWPToolBar.GetSizeItems: TStrings;
begin
  if FontSize <> nil then
    Result := FontSize.Items
  else
    result := nil;
end;


procedure TWPToolBar.AddIcon(const name: string; index, group, num: Integer);
begin
  if Speedb_anz < NumSpeedButtons - 1 then
  begin
    inc(Speedb_anz);
    Speedb[Speedb_anz].Name := name;
    Speedb[Speedb_anz].group := group;
    Speedb[Speedb_anz].number := num;
    Speedb[Speedb_anz].index := index;
    Init;
  end;
end;

procedure TWPToolBar.CreateWnd;
begin
  inherited CreateWnd;
  FHold := FALSE;
  // if Parent <> nil then  // V5.11.1
  Init;
  //------ if FRTFEdit <> nil then
  //         FRTFEdit.SetFocusValues(TRUE);
end;

function TWPToolBar.GetIcon(index, group, num: Integer): TWPSpeedButton;
var
  i: Integer;
begin
  result := nil;
  if index <> 0 then
  begin
    for i := 1 to Speedb_anz do
      if Speedb[i].index = index then break;
    if (Speedb[i].index = index) and (Speedb[i].Face <> nil) then
      result := Speedb[i].Face;
  end
  else
  begin
    for i := 1 to Speedb_anz do
      if Speedb[i].group = group then
      begin
        if (Speedb[i].number = num) or (num = 0) then
        begin result := Speedb[i].Face; break;
        end;
      end;
  end;
end;

function TWPToolBar.SelectIcon(index, group, num: Integer): Boolean;
var
  p: TWPSpeedButton;
begin
  p := GetIcon(index, group, num);
  if p <> nil then
  begin
    result := p.Down;
    p.Down := TRUE;
  end
  else
    Result := inherited SelectIcon(index, group, num);
end;

function TWPToolBar.DeSelectIcon(index, group, num: Integer): Boolean;
var
  p: TWPSpeedButton;
begin
  p := GetIcon(index, group, num);
  if p <> nil then
  begin
    result := p.Down;
    p.Down := FALSE;
  end
  else
    Result := inherited DeSelectIcon(index, group, num);
end;

function TWPToolBar.EnableIcon(index, group, num: Integer; enabled: Boolean):
  Boolean;
var
  i, FExeptNr: Integer;
  erg: Boolean;
begin
  if Num < 0 then
  begin
    FExeptNr := -Num;
    Num := 0;
  end
  else
    FExeptNr := 0;

  if index <> 0 then
  begin
    for i := 1 to Speedb_anz do
      if Speedb[i].index = index then break;
    if (Speedb[i].index = index) and (Speedb[i].Face <> nil) then
    begin erg := Speedb[i].Face.Enabled;
      Speedb[i].Face.Enabled := enabled;
    end
    else
      erg := FALSE;
    EnableIcon := erg;
  end
  else
  begin
    erg := FALSE;
    for i := 1 to Speedb_anz do
      if (Speedb[i].group = group) and (Speedb[i].number <> FExeptNr) then
      begin
        if ((Speedb[i].number = num) or
          ((num = 0) and (Speedb[i].group = group)))
          and (Speedb[i].Face <> nil) then
        begin
          erg := Speedb[i].Face.Enabled;
          if erg <> enabled then
          begin
            Speedb[i].Face.Enabled := enabled;
            Speedb[i].Face.Invalidate;
          end;
        end;
      end;
    EnableIcon := erg;
  end;
  inherited EnableIcon(index, group, num, enabled);
end;

procedure TWPToolBar.SetFontSelect(var fon: TFont);
begin
 { if FontName <> nil then        5.11.1
    FontName.Text := fon.Name; }
  if FontSize <> nil then
    FontSize.Text := IntToStr(fon.Size);  
end;

procedure TWPToolBar.Exit(Sender: TObject);
begin
  if assigned(FRtfEdit) then
      Windows.SetFocus(FRTFEdit.Handle);
  if Assigned(FOnExit) then FOnExit(Self);
end;

procedure TWPToolBar.Change(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TWPToolBar.ColBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  color: Integer;
  alist: TComboBox;
  cp: TColor;
  i: Integer;
begin
  alist := Control as TComboBox;
  { if index <>	alist.ItemIndex	then  } InflateRect(Rect, -2, -1);
  if (Index <= 0) and (alist.Tag <> 3) then
  begin
    alist.Canvas.Brush.Color := clWindow;
  end
  else
  begin color := StrToIntDef(alist.Items.Strings[Index], 0);
    if RtfEdit = nil then
      cp := FDefaultPalette[0]
    else
      cp := RtfEdit.TextColors[color];
    alist.Canvas.Brush.Color := cp;
  end;
  alist.Canvas.Pen.Color := clBlack;
  alist.Canvas.Pen.Style := psSolid;
  alist.Canvas.Pen.Width := 1;
  alist.Canvas.FillRect(Rect);
  alist.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  if Control.Tag = 6 then
  begin
    i := (Rect.Bottom - Rect.Top) div 3;
    alist.Canvas.MoveTo(Rect.Left, Rect.Top + i - 1);
    alist.Canvas.LineTo(Rect.Right, Rect.Top + i - 1);
    alist.Canvas.MoveTo(Rect.Left, Rect.Top + i * 2);
    alist.Canvas.LineTo(Rect.Right, Rect.Top + i * 2);
  end;  
end;


procedure TWPToolBar.FontBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  nam: string;
  alist: TComboBox;
  off: Integer;
  TT: Boolean;
begin
  alist := Control as TComboBox;
  TT := WPTGetFontType(alist.Items[Index]);
  nam := alist.Items.Strings[Index];
  if FontInFont then
  begin
    if (alist.tag = 1) and (fsshowface <> 0)
      and (Rect.Left <> 3)
      then
      alist.Canvas.Font.Name := nam
    else
      alist.Canvas.Font.Name := font.name;
    alist.Canvas.Font.Style := [];
  end;
  with alist.Canvas do
  begin
    FillRect(Rect);
    if alist.tag = 1 then
    begin
      if TT then
      begin
        DrawPic(Brush.Color);
        Draw(Rect.Left + 2, Rect.Top, FBitmap);
      end;
      if (Rect.Left <> 3) then
        off := 16
      else
        off := 19;
      rect.Left := Rect.Left + 16;
    end
    else
      off := 2;
    TextRect(Rect, off, rect.top, nam);
  end;
end;


procedure TWPToolBar.DrawPic(Background: TColor);
  procedure DRAWT(ORGX, ORGY: INTEGER; COLOR: TCOLOR);
  begin
    with FBitmap.Canvas do
    begin
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
  with FBitmap.Canvas do
  begin
    Brush.Style := bsClear;
    Brush.Color := background;
    FillRect(Rect(0, 0, 12, 12));
    DrawT(0, 0, clGray);
    DrawT(3, 3, clBlack);
  end;
end;

{ now global for easier use in WPComboBox	}



{ don't	use this anymore ! }

procedure TWPToolBar.AddControl(comp: TControl);
begin
  if comp.Parent <> Self then
  begin
    comp.Parent := Self;
    PostMessage(Handle, WM_SIZE, 0, 0);
  end;
end;

procedure TWPToolBar.RemoveControl(comp: TControl);
begin
  { ignored ! }
end;

type
  TTbBtnSty = record
    n: string;
    g, c: Integer;
    i: string; // ID - for StyleString
  end;

var gl_AllBitmaps : TStringList;

const
  TheButtonCount = 70;
  TheButtons: array[0..TheButtonCount] of TTbBtnSty =
  (
    (n: 'WPI_NORMAL'; g: WPI_GR_STYLE; c: WPI_CO_Normal; i: 'Sn'),
    (n: 'WPI_BOLD'; g: WPI_GR_STYLE; c: WPI_CO_Bold; i: 'Sb'),
    (n: 'WPI_ITALIC'; g: WPI_GR_STYLE; c: WPI_CO_Italic; i: 'Si'),
    (n: 'WPI_UNDER'; g: WPI_GR_STYLE; c: WPI_CO_Under; i: 'Su'),
    (n: 'WPI_SUPER'; g: WPI_GR_STYLE; c: WPI_CO_Super; i: 'Sp'),
    (n: 'WPI_SUB'; g: WPI_GR_STYLE; c: WPI_CO_Sub; i: 'Sb'),
    (n: 'WPI_STRIKEOUT'; g: WPI_GR_STYLE; c: WPI_CO_StrikeOut; i: 'Ss'),
    (n: 'WPI_HYPERLINK'; g: WPI_GR_STYLE; c: WPI_CO_HyperLink; i: 'Sh'),
    (n: 'WPI_HIDDEN'; g: WPI_GR_STYLE; c: WPI_CO_HIDDEN; i: 'Sv'),
    (n: 'WPI_PROTECTED'; g: WPI_GR_STYLE; c: WPI_CO_PROTECTED; i: 'Sm'),
    (n: 'WPI_RTFCODE'; g: WPI_GR_STYLE; c: WPI_CO_RTFCODE; i: 'Sc'),

    (n: 'WPI_LEFT'; g: WPI_GR_ALIGN; c: WPI_CO_Left; i: 'Al'),
    (n: 'WPI_CENTER'; g: WPI_GR_ALIGN; c: WPI_CO_Center; i: 'Ac'),
    (n: 'WPI_JUSTIFIED'; g: WPI_GR_ALIGN; c: WPI_CO_Justified; i: 'Aj'),
    (n: 'WPI_RIGHT'; g: WPI_GR_ALIGN; c: WPI_CO_Right; i: 'Ar'),

    (n: 'WPI_New'; g: WPI_GR_DISK; c: WPI_CO_New; i: 'Fn'),
    (n: 'WPI_OPEN'; g: WPI_GR_DISK; c: WPI_CO_Open; i: 'Fo'),
    (n: 'WPI_SAVE'; g: WPI_GR_DISK; c: WPI_CO_Save; i: 'Fs'),
    (n: 'WPI_CLOSE'; g: WPI_GR_DISK; c: WPI_CO_Close; i: 'Fc'),
    (n: 'WPI_EXIT'; g: WPI_GR_DISK; c: WPI_CO_Exit; i: 'Fx'),

    (n: 'WPI_FITWIDTH'; g: WPI_GR_Print; c: WPI_CO_FitWidth; i: 'Zw'),
    (n: 'WPI_FITHEIGHT'; g: WPI_GR_Print; c: WPI_CO_FitHeight; i: 'Zf'),
    (n: 'WPI_ZOOMOUT'; g: WPI_GR_Print; c: WPI_CO_ZoomOut; i: 'Zi'),
    (n: 'WPI_ZOOMIN'; g: WPI_GR_Print; c: WPI_CO_ZoomIn; i: 'Zo'),
    (n: 'WPI_PRIORPAGE'; g: WPI_GR_Print; c: WPI_CO_PriorPage; i: 'Zp'),
    (n: 'WPI_NEXTPAGE'; g: WPI_GR_Print; c: WPI_CO_NextPage; i: 'Zn'),
    (n: 'WPI_PRINT'; g: WPI_GR_Print; c: WPI_CO_Print; i: 'Pp'),
    (n: 'WPI_PRINTSETUP'; g: WPI_GR_Print; c: WPI_CO_PrintSetup; i: 'Ps'),

    (n: 'WPI_TOSTART'; g: WPI_GR_Data; c: WPI_CO_ToStart; i: 'Df'),
    (n: 'WPI_PREV'; g: WPI_GR_Data; c: WPI_CO_Prev; i: 'Dp'),
    (n: 'WPI_NEXT'; g: WPI_GR_Data; c: WPI_CO_Next; i: 'Dn'),
    (n: 'WPI_TOEND'; g: WPI_GR_Data; c: WPI_CO_ToEnd; i: 'Dl'),
    (n: 'WPI_ADD'; g: WPI_GR_Data; c: WPI_CO_Add; i: 'D+'),
    (n: 'WPI_DEL'; g: WPI_GR_Data; c: WPI_CO_Del; i: 'D-'),
    (n: 'WPI_EDIT'; g: WPI_GR_Data; c: WPI_CO_Edit; i: 'De'),
    (n: 'WPI_CANCEL'; g: WPI_GR_Data; c: WPI_CO_Cancel; i: 'Dx'),
    (n: 'WPI_POST'; g: WPI_GR_Data; c: WPI_CO_Post; i: 'Dp'),

    (n: 'WPI_UNDO'; g: WPI_GR_Edit; c: WPI_CO_Undo; i: 'Eu'),
    (n: 'WPI_REDO'; g: WPI_GR_Edit; c: WPI_CO_Redo; i: 'Ez'),
    (n: 'WPI_DELTETETEXT'; g: WPI_GR_Edit; c: WPI_CO_DeleteText; i: 'Ed'),
    (n: 'WPI_SelAll'; g: WPI_GR_Edit; c: WPI_CO_SelAll; i: 'Ea'),
    (n: 'WPI_HideSel'; g: WPI_GR_Edit; c: WPI_CO_HideSel; i: 'En'),
    (n: 'WPI_CUT'; g: WPI_GR_Edit; c: WPI_CO_Cut; i: 'Ex'),
    (n: 'WPI_COPY'; g: WPI_GR_Edit; c: WPI_CO_Copy; i: 'Ec'),
    (n: 'WPI_PASTE'; g: WPI_GR_Edit; c: WPI_CO_Paste; i: 'Ep'),
    (n: 'WPI_FIND'; g: WPI_GR_Edit; c: WPI_CO_Find; i: 'Ef'),
    (n: 'WPI_REPLACE'; g: WPI_GR_Edit; c: WPI_CO_Replace; i: 'Er'),
    (n: 'WPI_SPELL'; g: WPI_GR_Edit; c: WPI_CO_SpellCheck; i: 'Es'),

    (n: 'WPI_CREATETABLE'; g: WPI_GR_Table; c: WPI_CO_CreateTable; i: 'Tc'),
    (n: 'WPI_SELROW'; g: WPI_GR_Table; c: WPI_CO_SelRow; i: 'Tr'),
    (n: 'WPI_INSROW'; g: WPI_GR_Table; c: WPI_CO_InsRow; i: 'T+'),
    (n: 'WPI_DELROW'; g: WPI_GR_Table; c: WPI_CO_DelRow; i: 'T-'),
    (n: 'WPI_INSCOL'; g: WPI_GR_Table; c: WPI_CO_InsCol; i: 'C+'),
    (n: 'WPI_DELCOL'; g: WPI_GR_Table; c: WPI_CO_DelCol; i: 'C-'),
    (n: 'WPI_SELCOL'; g: WPI_GR_Table; c: WPI_CO_SelCol; i: 'Tc'),
    (n: 'WPI_SPLITCELL'; g: WPI_GR_Table; c: WPI_CO_SplitCell; i: 'Ts'),
    (n: 'WPI_COMBINECELL'; g: WPI_GR_Table; c: WPI_CO_CombineCell; i: 'Tm'),
    (n: 'WPI_BOFF'; g: WPI_GR_Table; c: WPI_CO_BAllOff; i: 'Bx'),
    (n: 'WPI_BON'; g: WPI_GR_Table; c: WPI_CO_BAllOn; i: 'Ba'),
    (n: 'WPI_BINNER'; g: WPI_GR_Table; c: WPI_CO_BInner; i: 'Bi'),
    (n: 'WPI_BOUTER'; g: WPI_GR_Table; c: WPI_CO_BOuter; i: 'Bo'),
    (n: 'WPI_BLEFT'; g: WPI_GR_Table; c: WPI_CO_BLeft; i: 'Bl'),
    (n: 'WPI_BRIGHT'; g: WPI_GR_Table; c: WPI_CO_BRight; i: 'Br'),
    (n: 'WPI_BTOP'; g: WPI_GR_Table; c: WPI_CO_BTop; i: 'Bt'),
    (n: 'WPI_BBOTTOM'; g: WPI_GR_Table; c: WPI_CO_BBottom; i: 'Bb'),

    (n: 'WPI_BULLETS'; g: WPI_GR_Outline; c: WPI_CO_Bullets; i: 'Nb'),
    (n: 'WPI_NUMBERS'; g: WPI_GR_Outline; c: WPI_CO_Numbers; i: 'Nn'),
    (n: 'WPI_INCINDENT'; g: WPI_GR_Outline; c: WPI_CO_NextLevel; i: 'N+'),
    (n: 'WPI_DECINDENT'; g: WPI_GR_Outline; c: WPI_CO_PriorLevel; i: 'N-'),

    (n: 'WPI_PARPROTECT'; g: WPI_GR_PARAGRAPH; c: WPI_CO_PARPROTECT; i: 'Pm'),
    (n: 'WPI_PARKEEP'; g: WPI_GR_PARAGRAPH; c: WPI_CO_PARKEEP; i: 'Pk')
    );


procedure TWPToolBar.Init;
var
  w, off, i, aa, h, ic_top: Integer;
  bit : TBitmap;
  Acaption, Ahint: string;
  // ---------------------------------------------------------------------------
  procedure ProcessStyleString;
  var
    l, j: Integer;
    ccc: string;
  begin
    l := 1;
    fsSelection := [];
    while l < Length(FStyleString) do
    begin
      if FStyleString[l] = ';' then
      begin // seperator;
        inc(l);
      end else
      begin
        ccc := Copy(FStyleString, l, 2);
        if ccc = 'Ln' then include(fsSelection, SelFontName)
        else if ccc = 'Ls' then include(fsSelection, SelFontSize)
        else if ccc = 'Lc' then include(fsSelection, SelFontColor)
        else if ccc = 'Lb' then include(fsSelection, SelBackgroundColor)
        else if ccc = 'Lp' then include(fsSelection, SelParColor)
        else
          for j := 0 to TheButtonCount do
            if (TheButtons[j].i = ccc) then
            begin
              AddIcon(TheButtons[j].n, WPI_IDX_INTERN, TheButtons[j].g, TheButtons[j].c);
              break;
            end;
        inc(l, 2);
      end;
    end;
  end;
  // ---------------------------------------------------------------------------
  procedure AddStyle(GR, CO: INTEGER);
  var
    i: Integer;
  begin
    for i := 0 to TheButtonCount do
      if (TheButtons[i].g = gr) and (TheButtons[i].c = co) then
      begin
        AddIcon(TheButtons[i].n, WPI_IDX_INTERN, gr, co);
        break;
      end;
  end;
  // ---------------------------------------------------------------------------
  procedure GetHint(ctrl: TControl; Group, Command: Integer);
  var
    cstr, hstr: string;
  begin
    if WPGetActionHintCap(group, Command, cstr, hstr) then
    begin
      ctrl.Hint := hstr;
      if ctrl is TComboBox then
        TComboBox(ctrl).ParentShowHint := FALSE
      else if ctrl is TWPSpeedButton then
        TWPSpeedButton(ctrl).ParentShowHint := FALSE;
      ctrl.ShowHint := TRUE;
    end
    else
      ctrl.ShowHint := FALSE;
  end;
  // ---------------------------------------------------------------------------
label
  finish;
begin
  if FInitInProgress or (ComponentState = [csLoading]) or not HandleAllocated or
    (FLockedCount > 0) then System.exit;
  FInitInProgress := TRUE;
  if Caption = Name then Caption := '';
  off := 0;
  w := 0;
  h := abs(font.height) + 9;
  Speedb_anz := 0;
  may_align := FALSE;
            
  if FStyleString <> '' then ProcessStyleString
  else
  begin
    { Style Icons	}
    if SelNormal in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Normal);
    if SelBold in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Bold);
    if SelItalic in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Italic);
    if SelUnder in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Under);
    if SelSuper in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Super);
    if SelSub in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_Sub);
    if SelStrikeOut in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_StrikeOut);
    if SelHyperLink in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_HyperLink);
    if SelHidden in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_HIDDEN);
    if SelProtected in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_PROTECTED);
    if SelRTFCode in fsIntIcons then
      AddStyle(WPI_GR_STYLE, WPI_CO_RTFCODE);


    if SelLeft in fsIntIcons then
      AddStyle(WPI_GR_ALIGN, WPI_CO_Left);
    if SelCenter in fsIntIcons then
      AddStyle(WPI_GR_ALIGN, WPI_CO_Center);
    if SelBLOCK in fsIntIcons then
      AddStyle(WPI_GR_ALIGN, WPI_CO_Justified);
    if SelRIGHT in fsIntIcons then
      AddStyle(WPI_GR_ALIGN, WPI_CO_Right);
    { Action Icons }
    if SelNew in fsIntIcons2 then
      AddStyle(WPI_GR_DISK, WPI_CO_New);
    if SelOpen in fsIntIcons2 then
      AddStyle(WPI_GR_DISK, WPI_CO_Open);
    if SelSave in fsIntIcons2 then
      AddStyle(WPI_GR_DISK, WPI_CO_Save);
    if SelClose in fsIntIcons2 then
      AddStyle(WPI_GR_DISK, WPI_CO_Close);
    if SelExit in fsIntIcons2 then
      AddStyle(WPI_GR_DISK, WPI_CO_Exit);

    { only for preview }
    if SelFitWidth in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_FitWidth);
    if SelFitHeight in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_FitHeight);
    if SelZoomOut in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_ZoomOut);
    if SelZoomIn in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_ZoomIn);
    if SelPriorPage in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_PriorPage);
    if SelNextPage in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_NextPage);

    if SelPrint in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_Print);
    if SelPrintSetup in fsIntIcons2 then
      AddStyle(WPI_GR_Print, WPI_CO_PrintSetup);

    { Database Icons }
    if SelToStart in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_ToStart);
    if SelPrev in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Prev);
    if SelNext in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Next);
    if SelToEnd in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_ToEnd);
    if SelAdd in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Add);
    if SelDel in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Del);
    if SelEdit in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Edit);
    if SelCancel in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Cancel);
    if SelPost in fsIntIcons3 then
      AddStyle(WPI_GR_Data, WPI_CO_Post);
    { Edit Icons }
    if SelUndo in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Undo);
    if SelRedo in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Redo);
    if SelSelAll in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_SelAll);
    if SelHideSel in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_HideSel);
    if SelDeleteText in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_DeleteText);
    if SelCut in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Cut);
    if SelCopy in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Copy);
    if SelPaste in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Paste);
    if SelFind in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Find);
    if SelReplace in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_Replace);
    if SelSpellCheck in fsIntIcons4 then
      AddStyle(WPI_GR_Edit, WPI_CO_SpellCheck);
    { Table Icons	}
    if SelCreateTable in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_CreateTable);
    if SelSelRow in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_SelRow);
    if SelInsRow in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_InsRow);
    if SelDelRow in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_DelRow);

    if SelInsCol in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_InsCol);
    if SelDelCol in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_DelCol);

    if SelSelCol in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_SelCol);

    if SelSplitCell in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_SplitCell);
    if SelCombineCell in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_CombineCell);
    if SelBAllOff in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BAllOff);
    if SelBAllOff in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BAllOn);
    if SelBInner in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BInner);
    if SelBOuter in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BOuter);
    if SelBLeft in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BLeft);
    if SelBRight in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BRight);
    if SelBTop in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BTop);
    if SelBBottom in fsIntIcons5 then
      AddStyle(WPI_GR_Table, WPI_CO_BBottom);

    { --- }
    if SelBullets in fsIntIcons6 then
      AddStyle(WPI_GR_Outline, WPI_CO_Bullets);
    if SelNumbers in fsIntIcons6 then
      AddStyle(WPI_GR_Outline, WPI_CO_Numbers);
    if SelNextLevel in fsIntIcons6 then
      AddStyle(WPI_GR_Outline, WPI_CO_NextLevel);
    if SelPriorLevel in fsIntIcons6 then
      AddStyle(WPI_GR_Outline,
        WPI_CO_PriorLevel);
    if SelParProtect in fsIntIcons6 then
      AddStyle(WPI_GR_PARAGRAPH,
        WPI_CO_PARPROTECT);
    if SelParKeep in fsIntIcons6 then
      AddStyle(WPI_GR_PARAGRAPH, WPI_CO_PARKEEP);
  end;

  IconsLoaded := TRUE;

  {---------------------------------}
 if SelStyle in fsSelection then
  begin
    w := Canvas.TextWidth('http://www.wptools.de');
    if FontType = nil then FontType := TWPTBCombo.Create(Self);
    FontType.Parent := Self;

    FontType.OnChange := Change;
    FontType.OnCLoseUp := Exit;
    FontType.OnClick := DoClick;
    FontType.OnDrawItem := FontBoxDrawItem;
    FontType.OnDropDown := DoStyleDropDown;
    FontType.Left := off;

    FontType.ItemHeight := abs(font.height) + 2;
    FontType.TabOrder := 1;
    FontType.TabStop := FALSE;
    FontType.Width := w;
    FontType.Top := 4;
    FontType.ParentFont := TRUE;
    FontType.Tag := 4;
    FontType.Items.Clear;
    FontType.Style := csOwnerDrawFixed;
    // FontType.ItemIndex := 0; // V5.11.1
    GetHint(FontType, WPI_GR_DROPDOWN, Integer(wpaParStyleSelection));

  end
  else if FontType <> nil then
  begin
    FontType.Parent := nil;
    FontType.Free;
    FontType := nil;
  end;
  off := off + w + 2;
  {---------------------------------}
  if SelFontName in fsSelection then
  begin
    if FontName = nil then FontName := TWPTBCombo.Create(Self);
    FontName.Parent := Self;
    //FontName.Text := Font.Name;  5.11.1
    FontName.MaxLength := 31;
    FontName.Left := 4;

    FontName.ItemHeight := abs(font.height) + 2;
    FontName.TabOrder := 1;
    FontName.Top := 4;
    FontName.Clear;
    FontName.Sorted := True;
    FontName.Items.Clear;
    {----------------------------------}
    if WPNoPrinterInstalled or (Printer.Printers.Count <= 0) or (FFontChoice = fsScreenFonts) then
      FontName.Items := Screen.Fonts
    else
    try
      FontName.Items := Printer.Fonts;
    except
      FontName.Items := Screen.Fonts;
    end;
    if FTrueTypeOnly then
    begin
      for i := FontName.Items.Count - 1 downto 0 do
        if not WPTGetFontType(FontName.Items[i]) then FontName.Items.Delete(i);
    end;
    {----------------------------------}
    HasFontTypes := 0;
    FontName.OnChange := Change;
    FontName.OnCloseUp := Exit;
    FontName.OnClick := DoClick;
    FontName.OnDrawItem := FontBoxDrawItem;
    FontName.Style := csOwnerDrawFixed;
    FontName.TabStop := FALSE;
    i := 0;
    w := 0;
    while i < FontName.Items.Count do
    begin
      off := Canvas.TextWidth(FontName.Items.Strings[i] + '    ');
      if off > w then w := off;
      inc(i);
    end;
    FontName.Width := w;
    FontName.Tag := 1;
    // FontName.ItemIndex := 0;  // V5.11.1

    GetHint(FontName, WPI_GR_DROPDOWN, Integer(wptName));
    FontName.Visible := TRUE;
    off := 6 + w;

  end
  else if FontName <> nil then
  begin
    FontName.Parent := nil;
    FontName.Free;
    FontName := nil;
  end;
  {------------------------------------}
  if SelFontSize in fsSelection then
  begin

    if FontSize = nil then FontSize := TWPTBCombo.Create(Self);
    FontSize.Parent := Self;

    FontSize.OnChange := Change;
    FontSize.OnCloseUp := Exit;
    FontSize.OnClick := DoClick;
    FontSize.Left := off;

    FontSize.ItemHeight := abs(font.Height) + 2;
    FontSize.TabOrder := 1;
    FontSize.TabStop := FALSE;
    w := Canvas.TextWidth('8') * 3 + 24;
    FontSize.Width := w;
    FontSize.Top := 4;
    FontSize.Tag := 2;
    FontSize.Items.Clear;

    i := FontSizeFrom;
    if i = 0 then i := 1;
    while i <= FontSizeTo do
    begin FontSize.Items.Add(' ' + InttoStr(i)); inc(i);
    end;
    FontSize.OnDrawItem := FontBoxDrawItem;
    FontSize.Style := csOwnerDrawFixed;
    // FontSize.ItemIndex := 0;  // V5.11.1
    GetHint(FontSize, WPI_GR_DROPDOWN, Integer(wptSize));

    off := off + w + 2;
  end
  else if FontSize <> nil then
  begin
    FontSize.Parent := nil;
    FontSize.Free;
    FontSize := nil;
  end;
  {---------------------------------}
  if SelFontColor in fsSelection then
  begin
    w := Canvas.TextWidth('A') + 32;
    if FontColor = nil then FontColor := TWPTBCombo.Create(Self);
    FontColor.Parent := Self;

    FontColor.OnCloseUp := Exit;
    FontColor.OnChange := Change;
    FontColor.OnClick := DoClick;
    // FontColor.Text := '';  5.11.1
    FontColor.Left := off;

    FontColor.DropDownCount := 16;

    FontColor.ItemHeight := abs(Font.Height) + 2;
    FontColor.TabOrder := 1;
    FontColor.TabStop := FALSE;
    FontColor.Width := w;
    FontColor.Top := 4;
    FontColor.OnDrawItem := ColBoxDrawItem;
    FontColor.Tag := 3;
    FontColor.Items.Clear;
    FontColor.OnDropDown := OnColorDropDown;
    FontColor.Items.Add('0');
    FontColor.Style := CsOwnerDrawFixed;
    // FontColor.ItemIndex := 0; // V5.11.1
    GetHint(FontColor, WPI_GR_DROPDOWN, Integer(wptColor));
    off := 2 + off + w;

  end
  else if FontColor <> nil then
  begin
    FontColor.Parent := nil;
    FontColor.Free;
    FontColor := nil;
  end;

  if SelBackgroundColor in fsSelection then
  begin
    w := Canvas.TextWidth('A') + 32;
    if FontBKColor = nil then FontBKColor := TWPTBCombo.Create(Self);
    FontBKColor.Parent := Self;

    FontBKColor.OnChange := Change;
    FontBKColor.OnCloseUp := Exit;
    FontBKColor.OnClick := DoClick;
    // FontBKColor.Text := '';  5.11.1
    FontBKColor.Left := off;

    FontBKColor.DropDownCount := 16;

    FontBKColor.ItemHeight := abs(font.height) + 2;
    FontBKColor.TabOrder := 1;
    FontBKColor.TabStop := FALSE;
    FontBKColor.Width := w;
    FontBKColor.Top := 4;
    FontBKColor.OnDrawItem := ColBoxDrawItem;
    FontBKColor.Tag := 5;
    FontBKColor.OnDropDown := OnColorDropDown;
    FontBKColor.Items.Add('0');
    FontBKColor.Style := csOwnerDrawFixed;
    // FontBKColor.ItemIndex := 0; // V5.11.1
    GetHint(FontBKColor, WPI_GR_DROPDOWN, Integer(wptBkColor));
    off := 2 + off + w;

  end
  else if FontBKColor <> nil then
  begin
    FontBKColor.Parent := nil;
    FontBKColor.Free;
    FontBKColor := nil;
  end;



  if SelParColor in fsSelection then
  begin
    w := Canvas.TextWidth('A') + 32;
    if ParBKColor = nil then ParBKColor := TWPTBCombo.Create(Self);
    ParBKColor.Parent := Self;

    ParBKColor.OnChange := Change;
    ParBKColor.OnCloseUp := Exit;
    ParBKColor.OnClick := DoClick;
    // ParBKColor.Text := '';  5.11.1
    ParBKColor.Left := off;

    ParBKColor.DropDownCount := 16;

    ParBKColor.ItemHeight := abs(font.height) + 2;
    ParBKColor.TabOrder := 1;
    ParBKColor.TabStop := FALSE;
    ParBKColor.Width := w;
    ParBKColor.Top := 4;
    ParBKColor.OnDrawItem := ColBoxDrawItem;
    ParBKColor.Tag := 6;
    ParBKColor.OnDropDown := OnColorDropDown;
    ParBKColor.Items.Add('0');
    ParBKColor.Style := csOwnerDrawFixed;
    // ParBKColor.ItemIndex := 0; // V5.11.1
    GetHint(ParBKColor, WPI_GR_DROPDOWN, Integer(wptParColor));
    off := 2 + off + w;
  end
  else if ParBKColor <> nil then
  begin
    ParBKColor.Parent := nil;
    ParBKColor.Free;
    ParBKColor := nil;
  end;
  off := 2 + off + w;

  ic_top := 3;
  for i := 1 to Speedb_anz do
    with Speedb[i] do
    begin

      if Face = nil then
      begin
        Face := TWPSpeedButton.Create(self);
        Face.Parent := Self; // V5.11.1
      end;
{$IFNDEF FLATWPBUT}
      Face.Flat := FlatButtons;
{$ELSE}
      if Face is TWPSpeedButton then TWPSpeedButton(Face).Flat := FlatButtons;
{$ENDIF}
      // Face.Parent := Self; // V5.11.1
      if UseSameGroupForAllButtons then
      begin
        Face.AllowAllUp := TRUE;
        Face.Down := FALSE;
        Face.GroupIndex := 77;
      end
      else
      begin
        Face.AllowAllUp := TRUE;
        Face.Down := FALSE;
        if group <> WPI_GR_ALIGN then
        begin
          Face.AllowAllUp := TRUE;
          (* Face.GroupIndex:= 78+i;  *)
          Face.GroupIndex := group + i;
        end
        else
        begin
          Face.AllowAllUp := FALSE;
          Face.GroupIndex := group;
          if (group = WPI_GR_ALIGN) and (number = WPI_CO_LEFT) then
            Face.Down := TRUE;
        end;
      end;
      if (off + h > Width) and (off > 30) and
        ((Align = alTop) or (Align = alBottom)) then
      begin
        Height := Height + h + 2;
        ic_top := ic_top + h + 2;
        off := 4;
      end;

      Face.Left := off;
      Face.Top := ic_top;
      Face.Tag := 10 + i;
      if FButtonHeight > 0 then
      begin
        Face.Height := FButtonHeight;
        Face.Width := FButtonHeight;
      end else
      begin
        Face.Height := h;
        Face.Width := h;
      end;

      aa := gl_AllBitmaps.IndexOf(Name);    // V5.11.1 - optimation
      if aa<0 then
      begin
        bit := TBitmap.Create;
        bit.LoadFromResourceName(Hinstance,Name);
        gl_AllBitmaps.AddObject(Name, bit);
      end else bit := TBitmap(gl_AllBitmaps.Objects[aa]);

      Face.Glyph.Assign(bit);

      if (Face.Glyph <> nil) and
        (Face.Glyph.Width > GLYPHWIDTH) then
        Face.NumGlyphs := 2;
      if WPGetActionHintCap(Group, Number, ACaption, AHint) then
      begin
        Face.Hint := aHint;
        Face.ParentShowHint := TRUE;
      end;
      Face.OnClick := DoClick;
      off := off + 2 + Face.Width;
    end;
  if Speedb_anz + 1 <= NumSpeedButtons then
    for i := Speedb_anz + 1 to NumSpeedButtons do
      with Speedb[i] do
        if Face <> nil then
        begin
          Face.Visible := FALSE;
          // free the SpeedButtons which are unused
          Face.Parent := nil;
          Face.Free;
          Face := nil;
        end;
  may_align := TRUE;
  if FAutoEnabling then
  begin
    Enabled := FRtfEdit <> nil;
    UpdateEnabledState;
  end;
  finish:
  FInitInProgress := FALSE;
  AlignAllControls;
end;

procedure TWPToolBar.DoToolBarIconSelection(var group, num: Integer);
begin
end;

procedure TWPToolBar.DoStyleDropDown(Sender: TObject);
begin
  if RTFProps<>nil then
  begin
    (Sender as TComboBox).ItemIndex :=
       RTFProps.ParStyles.GetStringList(
      (Sender as TComboBox).Items,true,
         RtfEdit.CurrAttr.StyleName );
  end;

end;

procedure TWPToolBar.DoClick(Sender: TObject);
var
  Typ: TWpSelNr;
  num, ind, index, group: Integer;
  str: string;
  ret: Boolean;
  UpDatePtr: TComponent;
begin
  if fUpdateCount = 0 then
  begin
    num := 0;
    group := 0;
    str := '';
    ret := TRUE;
    with Sender as TComponent do
      case Tag of
        1:
          begin Typ := wptName;
            str := (Sender as TComboBox).Text;
          end;
        2:
          begin Typ := wptSize;
            str := (Sender as TComboBox).Text;
            num := StrToIntDef(str, 1);
          end;
        3:
          begin Typ := wptColor;
            str := (Sender as TComboBox).Text;
            num := StrToIntDef(str, 0);
          end;
        4:
          begin Typ := wptTyp;
            str := (Sender as TComboBox).Text;
            num := (Sender as TComboBox).ItemIndex;
          end;
        5:
          begin Typ := wptBKColor;
            str := (Sender as TComboBox).Text;
            num := StrToIntDef(str, 0);
          end;
        6:
          begin Typ := wptParColor;
            str := (Sender as TComboBox).Text;
            num := StrToIntDef(str, 0);
          end;
      else
        begin
          ind := (Sender as TComponent).Tag - 10;
          if (ind > 0) and (ind <= Speedb_anz) then
          begin
            str := Speedb[ind].Name;
            index := Speedb[ind].Index;
            group := Speedb[ind].group;
            num := Speedb[ind].number;
            if (Sender as TWPSpeedButton).Down then
              Typ := wptIconSel
            else
              Typ := wptIconDeSel;
            if Assigned(FOnIconSelection) then
              FOnIconSelection(Self, typ, str, group, num, index);
            if Assigned(FRtfEdit) and (Typ <> wptNone) then
            begin
              Windows.SetFocus(FRTFEdit.Handle);
              DoToolBarIconSelection(group, num);
              {   if (num=0) and (Sender is TWPSpeedButton) then
                    TWPSpeedButton(Sender).Down := FALSE
                 else } FRtfEdit.OnToolBarIconSelection(Sender, typ, str, group, num,
                index);
            end;
          end;
          ret := (group = WPI_GR_STYLE);
        end;
      end;
    if ret then
    begin
      if fsUpdateName <> '' then
      begin
        UpDatePtr := Parent.FindComponent(fsUpdateName);
        if UpDatePtr <> nil then
          UpdateObj(UpDatePtr, Typ, str, num)
        else
          fsUpdateName := '';
      end;
      if (typ <> wptIconDeSel) and (typ <> wptIconSel) then
      begin
        if Assigned(fsUpdateObjp) then
          UpdateObj(fsUpdateObjp, Typ, str, num);
        if Assigned(FOnSelection) then
          FOnSelection(Self, Typ, str, num);
        if Assigned(FRtfEdit) and (Typ <> wptNone) then
        begin
          Windows.SetFocus(FRTFEdit.Handle);
          FRtfEdit.OnToolBarSelection(Self, Typ, str, num);
        end;
      end;
    end;
  end;
end;

procedure TWPToolBar.UpdateObj(UpdateObjp: TComponent; typ: TWpSelNr; str:
  string; num: Integer);
var
  xcol: TColor;
  xstyle: TFontStyle;
begin
  if fUpdateCount = 0 then
  begin
    xcol := 0;
    xstyle := TFontStyle(0);
  { if (num > 0) and (num <= NumPaletteEntries) then
    begin
      if (typ = wptBKColor) and (num = 0) then
        xcol := clWindow
      else
      begin
        if FPPaletteEntries = nil then
          cp := @(FDefaultPalette[0])
        else
          cp := FPPaletteEntries;

        inc(cp, Num);
        with cp^ do
          xcol := TColor(RGB(peRed, peGreen, peBlue));
      end;
    end; }
    if (typ = wptIconSel) or (typ = wptIconDesel) then
    begin
      case num of
        WPI_CO_Bold: xstyle := fsBold;
        WPI_CO_Italic: xstyle := fsItalic;
        WPI_CO_Under: xstyle := fsUnderline;
        WPI_CO_StrikeOut: xstyle := fsStrikeout;
      end;
    end;

    if (UpdateObjp <> nil) and (Enabled = TRUE) then
    begin
      if UpdateObjp is TMemo then
      begin case Typ of
          wptName: (UpdateObjp as TMemo).Font.Name := str;
          wptSize: (UpdateObjp as TMemo).Font.Size := num;
          wptColor: (UpdateObjp as TMemo).Font.Color := xcol;
          wptBKColor: (UpdateObjp as TMemo).Color := xcol;
          wptIconSel: (UpdateObjp as TMemo).Font.Style := [xstyle];
          wptIconDeSel: (UpdateObjp as TMemo).Font.Style := [];
        end;
        (UpdateObjp as TMemo).Update;
      end
      else if UpdateObjp is TEdit then
      begin case Typ of
          wptName: (UpdateObjp as TEdit).Font.Name := str;
          wptSize: (UpdateObjp as TEdit).Font.Size := num;
          wptColor: (UpdateObjp as TEdit).Font.Color := xcol;
          wptBKColor: (UpdateObjp as TEdit).Color := xcol;
          wptIconSel: (UpdateObjp as TEdit).Font.Style := [xstyle];
          wptIconDeSel: (UpdateObjp as TEdit).Font.Style := [];
        end;
        (UpdateObjp as TEdit).Update;
      end
      else if UpdateObjp is TLabel then
      begin case Typ of
          wptName: (UpdateObjp as TLabel).Font.Name := str;
          wptSize: (UpdateObjp as TLabel).Font.Size := num;
          wptColor: (UpdateObjp as TLabel).Font.Color := xcol;
          wptBKColor: (UpdateObjp as TLabel).Color := xcol;
          wptIconSel: (UpdateObjp as TLabel).Font.Style := [xstyle];
          wptIconDeSel: (UpdateObjp as TLabel).Font.Style := [];
        end;
        (UpdateObjp as TLabel).Update;
      end
      else if UpdateObjp is TPanel then
      begin case Typ of
          wptName: (UpdateObjp as TPanel).Font.Name := str;
          wptSize: (UpdateObjp as TPanel).Font.Size := num;
          wptColor: (UpdateObjp as TPanel).Font.Color := xcol;
          wptBKColor: (UpdateObjp as TPanel).Color := xcol;
          wptIconSel: (UpdateObjp as TPanel).Font.Style := [xstyle];
          wptIconDeSel: (UpdateObjp as TPanel).Font.Style := [];
        end;
        (UpdateObjp as TPanel).Update;
      end;
    end;
  end;
end;

procedure WPUpdateNumberCombo(combo: TComboBox; num: Integer);
var
  j, n: Integer;
begin
  if num<0 then
  begin
     if combo<>nil then combo.ItemIndex := -1;
  end else
  if (combo <> nil) and (combo.Text <> IntToStr(num)) then
    with combo do
    begin
      j := 0;
      while j < Items.Count do
      begin
        n := StrToIntDef(Trim(Items[j]), 0);
        if n = num then
        begin
          ItemIndex := j;
          break;
        end else if n > num then
        begin
          Items.InsertObject(j, #32 + IntToStr(num), TObject(num));
          ItemIndex := j;
          break;
        end;
        inc(j);
      end;
      if j = Items.Count then
      begin
        Items.AddObject(#32 + IntToStr(num), TObject(num));
        ItemIndex := Items.Count - 1;
      end;
    end;
end;

procedure TWPToolBar.UpdateSelection(Typ: TWpSelNr; const str: string; num:
  Integer);
var
  i: Integer;
begin
  if fUpdateCount = 0 then
  begin
    case Typ of
      wptName:   
        begin
          if Trim(str)='' then
          begin
            if FontName <> nil then  FontName.ItemIndex :=-1;
          end else
          if (FontName <> nil) and
            ((FontName.ItemIndex < 0) or
            (CompareText(Trim(FontName.Items.Strings[FontName.ItemIndex]), str) <> 0))
            then
          begin
            i := 0;
            while i < FontName.Items.Count do
            begin if CompareText(Trim(FontName.Items.Strings[i]), str) = 0 then break;
              inc(i);
            end;
            if i = FontName.Items.Count then FontName.Items.Add(str);
            FontName.ItemIndex := i;
          end;
        end;
      wptTyp:
      if (FontType<>nil) and FontType.Visible then
      begin
         if Trim(str)='' then FontType.ItemIndex := FontType.Items.IndexOf(WPLoadStr(meUndefinedStyle))
         else
         begin
           i := FontType.Items.IndexOf(str);
           if i<0 then
           begin
              FontType.ItemIndex := RTFProps.ParStyles.GetStringList(
                  FontType.Items,true, str );
           end
           else FontType.ItemIndex := i;
         end;
      end;
      wptSize: WPUpdateNumberCombo(FontSize, num);
      wptColor: if (RTFProps<>nil) and (num < RTFProps.NumPaletteEntries) then WPUpdateNumberCombo(FontColor, num);
      wptBKColor: if (RTFProps<>nil) and (num < RTFProps.NumPaletteEntries) then WPUpdateNumberCombo(FontBKColor, num);
      wptParColor: if (RTFProps<>nil) and (num < RTFProps.NumPaletteEntries) then WPUpdateNumberCombo(ParBKColor, num);
    end;
    inherited UpdateSelection(Typ, str, num);
  end;
end;

procedure TWPToolBar.Loaded;
begin
  inherited Loaded;
  UpdateEnabledState;
  if NextToolbar = Self then NextToolbar := nil;
end;

procedure TWPToolbar.ctSetChildsEnabled;
begin
  FChildsEnabled := How;
  if FontName <> nil then FontName.Enabled := HOW;
  if FontSize <> nil then FontSize.Enabled := HOW;
  if FontColor <> nil then FontColor.Enabled := HOW;
  if FontBKColor <> nil then FontBKColor.Enabled := HOW;
  if FontType <> nil then FontType.Enabled := HOW;
  if ParBKColor <> nil then ParBKColor.Enabled := HOW;
end;

procedure TWPToolbar.SetButtonHeight(x: Integer);
var
  i: Integer;
begin
  if FButtonHeight <> x then
  begin
    FButtonHeight := x;
    if x = 0 then x := abs(font.height) + 9;
    for i := 0 to ControlCount - 1 do
    begin
      if Controls[i] is TWPSpeedButton then
      begin
        TWPSpeedButton(Controls[i]).Width := x;
        TWPSpeedButton(Controls[i]).Height := x;
      end;
    end;
    AlignAllControls;
  end;
end;

{ TWPSpeedButton ---------------- nicer	Buttons	for Delphi 1 and 2 ------  }
{$IFDEF	FLATWPBUT}

constructor TWPSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Flat := TRUE;
end;

procedure TWPSpeedButton.CMMouseEnter(var Message: TMessage);
begin
  if FFlatStyle then FMouseInControl := TRUE;
  invalidate;
end;

procedure TWPSpeedButton.CMMouseLeave(var Message: TMessage);
begin
  FMouseInControl := FALSE;
  invalidate;
end;

procedure TWPSpeedButton.SetFlatStyle(x: Boolean);
begin
  if FFlatStyle <> x then
  begin FFlatStyle := x;
    invalidate;
  end;
end;

{ fix the ugly Delphi1 Speedbuttons ----------------------------------
  certainly not	the only way to	do it, but it
  avoids the duplication of the	complicated Button drawing code	------ }

procedure TWPSpeedButton.Paint;
var
  RR: TRect;
  DrawFlags: (dfUp, dfFlat, dfDown);
begin
  inherited Paint;
  if FFlatStyle then
  begin
    if Down then
      DrawFlags := dfDown
    else if Enabled and FMouseInControl then
      DrawFlags := dfUp
    else
      DrawFlags := dfFlat;
    RR.Left := 0;
    RR.Top := 0;
    RR.Right := Width - 1;
    RR.Bottom := Height - 1;

    Canvas.Pen.Width := 1;
    Canvas.Pen.Mode := pmCopy;
    Canvas.Brush.Style := bsClear;
    if DrawFlags = dfUp then
    begin
      Canvas.Pen.Color := clWhite;
      Canvas.MoveTo(0, Height - 1);
      Canvas.LineTo(0, 0);
      Canvas.LineTo(Width - 1, 0);
      Canvas.Pen.Color := clBtnShadow;
      Canvas.LineTo(Width - 1, Height - 1);
      Canvas.LineTo(0, Height - 1);
    end
    else if DrawFlags = dfDown then
    begin
      Canvas.Pen.Color := clBtnShadow;
      Canvas.MoveTo(0, Height - 1);
      Canvas.LineTo(0, 0);
      Canvas.LineTo(Width - 1, 0);
      Canvas.Pen.Color := clWhite;
      Canvas.LineTo(Width - 1, Height - 1);
      Canvas.LineTo(0, Height - 1);
    end
    else
    begin
      Canvas.Pen.Color := clBtnFace;
      Canvas.MoveTo(RR.Left, RR.Bottom);
      Canvas.LineTo(RR.Left, RR.Top);
      Canvas.LineTo(RR.Right, RR.Top);
      Canvas.LineTo(RR.Right, RR.Bottom);
      Canvas.LineTo(RR.Left, RR.Bottom);
    end;
    Canvas.Pen.Color := clBtnFace;
    InflateRect(RR, -1, -1);
    Canvas.MoveTo(RR.Left, RR.Bottom);
    Canvas.LineTo(RR.Left, RR.Top);
    Canvas.LineTo(RR.Right, RR.Top);
    Canvas.LineTo(RR.Right, RR.Bottom);
    Canvas.LineTo(RR.Left, RR.Bottom);
    {  does not work with	BCB1 :
      Canvas.Rectangle(RR.Left,RR.Top,RR.Right,RR.Bottom); }
  end;
end;
{$ENDIF}


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
var
  prev_WPRefreshActionStrings: procedure;
  aa : Integer;

procedure doWPRefreshActionStrings;
var
  a: Integer;
begin
  for a := 0 to FAllToolbar.Count - 1 do
    TWPToolbar(FAllToolbar[a]).UpdateCaption;
  if assigned(prev_WPRefreshActionStrings) then prev_WPRefreshActionStrings;
end;

initialization
  FAllToolbar := TList.Create;
  gl_AllBitmaps := TStringList.Create;
  prev_WPRefreshActionStrings := WPRefreshActionStrings;
  WPRefreshActionStrings := Addr(doWPRefreshActionStrings);

finalization
  aa := 0;
  while aa<gl_AllBitmaps.Count do // V5.11.1
  begin
    {$IFDEF WPDEBUG}
    (gl_AllBitmaps.Objects[aa] as TBitmap).Free;
    {$ELSE}
    TBitmap(gl_AllBitmaps.Objects[aa]).Free;
    {$ENDIF}
    inc(aa);
  end;
  gl_AllBitmaps.Free;
  FAllToolbar.Free;
  WPRefreshActionStrings := prev_WPRefreshActionStrings;
end.


