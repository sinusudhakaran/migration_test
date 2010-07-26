unit WPUtil;
{ -----------------------------------------------------------------------------
  WPUtil Version 4 / WPTools 5
  Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  TextProcessor Utilities to be used in	WPTools	Dialog boxes
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$I WPINC.INC}
{$IFDEF VER150}
{.$DEFINE USETHEMES}// modifications by Horst Reichert for XP themes
                     // activate if you want to use a theme manager
{$ENDIF}

{$DEFINE USELOCALIZATION}

{.$DEFINE LANG_MODIFY_LABELS}

uses Windows, SysUtils, Messages, Classes, Graphics, Controls, TypInfo,
{$IFDEF WPTOOLS5}WPRTEDefs, WPCTRMemo, {$ELSE}WpDefs, WPRich, WPrtfIO, {$ENDIF}
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Menus, ComCtrls;

const IID_WPLocalizationInterface: TGUID = '{A12EF1F7-E592-4483-855F-67E28332AFC5}';

type
  TWPCustomAttrDlg = class;
  TWPEditUnits = set of TWPEditUnit;

  IWPLocalizationInterface = interface
    ['{A12EF1F7-E592-4483-855F-67E28332AFC5}']
{:: This method can be used to save the menu items and captions
   on a certain form. If you use the TWPLocalizeForm class you don't need
   to care about that. }
    procedure SaveForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);

{:: Load all Components on a certain TForm. }
    procedure LoadForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);

{:: This method saves a string list under a certain name. The string list has to use
   the syntax NAME=xxx\n }
    procedure SaveStrings(
      const Name: string;
      Entries: TStrings;
      Charset: Integer);

{:: Loads back the string(s) saved with  WPLangSaveStrings }
    function LoadStrings(
      const Name: string;
      Entries: TStrings;
      var Charset: Integer): Boolean;

{:: Method to save a certain string. To save multiple strings use  WPLangSaveStrings }
    procedure SaveString(
      const Name, Text: string;
      Charset: Integer);

{:: Loads back a string saved with WPLangSaveString. Since WPTools V5.18.1 the string
     "WPLocalizeLanguage" can be passed as name. Than the ID (such as DE, IT etc) of
     the selected language will be assigned to variable Text }
    function LoadString(
      const Name: string;
      var Text: string;
      var Charset: Integer): Boolean;
  end;

  {:: This object acts as marshalling object between the local code and
  the IWPLocalizationInterface which must be provided with the constructor. }
  TWPLocalizationInterface = class(TObject)
  private
    FInterface: IWPLocalizationInterface;
  public
    constructor Create(WPLocalizationInterface: IUnknown);
    destructor Destroy; override;
{:: This method can be used to save the menu items and captions
   on a certain form. If you use the TWPLocalizeForm class you don't need
   to care about that. }
    procedure SaveForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);
{:: Load all Components on a certain TForm. }
    procedure LoadForm(
      const Name: string;
      Form: TWinControl;
      Menus, Captions, Hints: Boolean);
{:: This method saves a string list under a certain name. The string list has to use
   the syntax NAME=xxx\n }
    procedure SaveStrings(
      const Name: string;
      const Entries: TStrings;
      Charset: Integer);
{:: Loads back the string(s) saved with  WPLangSaveStrings }
    function LoadStrings(
      const Name: string;
      Entries: TStrings;
      var Charset: Integer): Boolean;
{:: Method to save a certain string. To save multiple strings use  WPLangSaveStrings }
    procedure SaveString(
      const Name, Text: string;
      Charset: Integer);
{:: Loads back a string saved with WPLangSaveString }
    function LoadString(
      const Name: string;
      var Text: string;
      var Charset: Integer): Boolean;
  end;


{: This class implements a TForm with automatic localisation capability.
   It requires the global variable<br>
     <b>WPLangInterface</b><br>
   to be set to an interface object which supports the<br>
     <b>TWPLocalizationInterface</b><br>
   definition.
   <note>
   In WPTools 4 the localisation interface was attached through one unit,
   the WPLocalize unit. This has been changed, now you need to add one line
   to the project to set the LocalizationInterface in your code. This avoids
   dependencies between packages.
   </note>
   If the global boolean WPLocalizeSaveForms = TRUE all hints and captions
   will be  written to the localisation component after the
   OnDestroy event was triggered.
   The variable _DontSaveLanguage can be set to TRUE to avoid the saving.
   The strings are loaded after OnCreate
   Inherit the forms from this class to enable the localization capability }
{$IFDEF USELOCALIZATION}
  TWPLocalizeForm = class(TForm)
  public
    // Set this Boolean to TRUE in OnCreate to abort the localization
    _DontLocalize: Boolean;
    // Set this Boolean to TRUE to avoid saving after OnDestroy.
    _DontSaveLanguage: Boolean;
    // Parent Name - name of the sub element in the XML tree
    _XMLParent: string;
    // Name in the XML tree (default is the class name!)
    _XMLName: string;
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
    {$IFDEF LANG_MODIFY_LABELS}
    procedure WndProc(var Msg: TMessage); override;
    {$ENDIF}
  public
    procedure LoadLocStrings; virtual;
    procedure SaveLocStrings; virtual;
    function LocStringName: string; virtual;
  end;
{$ENDIF}


{ This is a simple up/down speedbutton with arrows }
{$IFNDEF USETHEMES}
  TWPSpinButtonState = (spNormal, spUp, spDown);
  TWPSpinButton = class(TCustomControl)
  private
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    FState: TWPSpinButtonState;
    Timer: TTimer;
    FStartTime: DWORD;
    procedure SetState(x: TWPSpinButtonState);
  protected
    procedure OnTimer(Sender: TObject);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    property State: TWPSpinButtonState read FState write SetState;
  published
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
{$IFNDEF T2H}
    property Align;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnEnter;
    property OnExit;
{$ENDIF}
  end;
{$ENDIF} //USETHEMES

  TWPValueEditFormatValue = procedure(Sender: TObject;
    UnitType: TWPEditUnit; Value: Integer; var NewText: string) of object;


  TWPValueEdit = class(TCustomEdit)
  private
    FIncrement: Integer;
    FEditorEnabled, FInKeyPress: Boolean;
    FUnit: TWPEditUnit;
    FPopUp: TPopupMenu;
    FUndefinedPop: TMenuItem;
    FPrecision: Integer;
    FOnUnitChange: TNotifyEvent;
    FOnFormatValue: TWPValueEditFormatValue;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    FAvailableUnits: TWPEditUnits;
    FAllowUndefined: Boolean;
    FAllowNegative: Boolean;
    FUndefined, FChangeToUndefined: Boolean;
{$IFNDEF USETHEMES}
    FButton: TWPSpinButton;
{$ELSE}
    FUpDn: TUpDown;
    procedure SetUndefined(x : Boolean);
    procedure ChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
{$ENDIF}
    function GetMinHeight: Integer;
    function GetValue: Integer;
    function GetIntValue: Integer;
    function CheckValue(NewValue: Integer): Integer;
    procedure InternSetValue(NewValue: Integer);
    procedure SetValue(NewValue: Integer);
    procedure SetUndefinedValue(NewValue: Integer);
    procedure SetIntValue(NewValue: Integer);
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMEnabledChanged(var Message: TMessage); message
      CM_ENABLEDCHANGED;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
{$IFDEF DELPHI4}
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
      override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
      override;
{$ENDIF}
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure UpClick(Sender: TObject); virtual;
    procedure DownClick(Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CreateWnd; override;
    procedure SetUnit(x: TWPEditUnit);
    procedure UnitClick(Sender: TObject);
    procedure Change; override;
    procedure SetUndefined(x: Boolean);
    function  GetUndefined : Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FormatValue(NewValue: Integer);
    procedure SetUndefinedVal(Sender: TObject);
{$IFNDEF USETHEMES}
    property Button: TWPSpinButton read FButton;
{$ELSE}
    property Button: TUpDown read FUpDn;
{$ENDIF}
  published
    property AllowUndefined: Boolean read FAllowUndefined write FAllowUndefined default FALSE;
    property AvailableUnits: TWPEditUnits read FAvailableUnits write
      FAvailableUnits;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled
      default True;
    property UnitType: TWPEditUnit read FUnit write SetUnit;
    property OnUnitChange: TNotifyEvent read FOnUnitChange write FOnUnitChange;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnFormatValue: TWPValueEditFormatValue read FOnFormatValue write FOnFormatValue;
    property Precision: Integer read FPrecision write FPrecision default 2;
  {$IFNDEF T2H}
    property AutoSelect;
    property BorderStyle;
    property AutoSize;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property TabOrder;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$ENDIF}
    property AllowNegative: Boolean read FAllowNegative write FAllowNegative;
    property Value: Integer read GetValue write SetValue;

    property IntValue: Integer read GetIntValue write SetIntValue;
    property Undefined: Boolean read GetUndefined write SetUndefined;
    property ChangeToUndefined: Boolean read FChangeToUndefined;
  public
    NoUnitText: Boolean;
    ValueHasChanged: Boolean;
    function GetValue_VHC(old: Integer): Integer;
    procedure ChangeValue(NewValue: Integer);
    property UndefinedValue: Integer write SetUndefinedValue;
  end;

{$IFDEF USEWPRESCOMP} // OBSOLETE!
  TWPResCheckBox = class(TCheckBox)
  private
    FResourceBase: Integer;
    FResourceIndex: Integer;
  published
    property ResourceBase: Integer read FResourceBase write FResourceBase;
    property ResourceIndex: Integer read FResourceIndex write FResourceIndex;
{$IFNDEF T2H}
    property Alignment;
    property AllowGrayed;
    property Caption;
    property Checked;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property State;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
{$ENDIF}
  end;

  TWPResLabel = class(TLabel)
  private
    FResourceBase: Integer;
    FResourceIndex: Integer;
  published
    property ResourceBase: Integer read FResourceBase write FResourceBase;
    property ResourceIndex: Integer read FResourceIndex write FResourceIndex;
{$IFNDEF T2H}
    property Align;
    property Alignment;
    property AutoSize;
    property Caption;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$ENDIF}
  end;
{$ENDIF}

  TWPShadedPanel = class(TCustomPanel)
  private
    FShadeBothWays: Boolean;
    FHorizontal: Boolean;
    FOnPaint: TNotifyEvent;
    FImage: TImage;
    FImageTiled: Boolean;
    FNoShading: Boolean;
    procedure SetShadeBothWays(x: Boolean);
    procedure SetHorizontal(x: Boolean);
    procedure SetImageTiled(x: Boolean);
    procedure SetImage(x: TImage);
  protected
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure Paint; override;
    constructor Create(aOwner: TComponent); override;
    procedure UseGlobal;
    property NoShading: Boolean read FNoShading write FNoShading;
  published
    property ShadeBothWays: Boolean read FShadeBothWays write SetShadeBothWays;
    property Horizontal: Boolean read FHorizontal write SetHorizontal;
    property Image: TImage read FImage write SetImage;
    property ImageTiled: Boolean read FImageTiled write SetImageTiled;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
{$IFNDEF T2H}
    property Align;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FullRepaint;
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
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
{$IFDEF DEFLPHI4}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnContextPopup;
    property OnEndDock;
    property OnStartDock;
{$ENDIF}
{$ENDIF}
  end;

{$IFDEF USELOCALIZATION}
  TWPShadedForm = class(TWPLocalizeForm)
{$ELSE}
  TWPShadedForm = class(TForm)
{$ENDIF}
  private
    FWPCustomAttrDlg: TWPCustomAttrDlg;
  protected
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(aOwner: TComponent); override;
    procedure DoShow; override;
    procedure Paint; override;
  end;

  TWPMemoryStream = class(TMemoryStream)
  private
    function GetAsString: string;
    function GetAsBoolean: Boolean;
    function GetAsInteger: Integer;
    procedure SetAsString(const x: string);
    procedure SetAsBoolean(const x: Boolean);
    procedure SetAsInteger(const x: Integer);
  public
    function GetAsNameValue(var name: string; var Value: Integer): Boolean;
    procedure SetAsNameValue(const name: string; const Value: Integer);
    property AsString: string read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
  end;

{ TWPRTFContainer --- storage for more than one	streams	}
  TWPContLoadDataEvent = procedure(ThisName: string; Source: TStream) of object;
  TWPContainer = class(TComponent)
  private
    FData: TMemoryStream;
    FWorkStream: TWPMemoryStream;
    FOnLoadData: TWPContLoadDataEvent;
    FNameBuf: array[0..101] of Char;
    FErrmsg: string;
    FStreamIsOpen: Boolean;
    function GetStream: TWPMemoryStream;
  public
    DataId: DWORD;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function OpenStream(name: string): TWPMemoryStream;
    procedure CloseStream;
    property Stream: TWPMemoryStream read GetStream;

    procedure SaveToStream(s: TStream);
    procedure LoadFromStream(s: TStream);
    function DataStream: TStream;
    procedure SaveToFile(s: TFilename);
    procedure LoadFromFile(s: TFilename);
    procedure Clear;
    procedure Load;
  published
    property OnLoadData: TWPContLoadDataEvent read FOnLoadData write
      FOnLoadData;
    property Errmsg: string read FErrmsg write FErrmsg;
  end;

{$IFDEF WPTOOLS5}
  TWPWallPaper = class(TGraphicControl)
  private
    FPicture: TPicture;
    FBackground: TBitmap;
    FLeftOffset: Integer;
    FTopOffset: Integer;
    procedure PictureChanged(Sender: TObject);
    procedure SetPicture(Value: TPicture);
  protected
    function GetPalette: HPALETTE; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    property Canvas;
    function Draw(thiscanvas: TCanvas; r: TRect): Boolean;
  published
    property Align;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property Picture: TPicture read FPicture write SetPicture;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
   { Now you can scroll the image : }
    property LeftOffset: Integer read FLeftOffset write FLeftOffset;
    property TopOffset: Integer read FTopOffset write FTopOffset;
  end;
{$ENDIF}


  TWPCustomAttrDlg = class(TComponent)
  protected
    FCreateAndFreeDialog: Boolean;
    FOnShowDialog: TNotifyEvent;
    FRTFProps : TWPRTFProps;
    FOldModified : Boolean;
{$IFDEF WPTOOLS5}
    FEditBox: TWPCustomRtfEdit;
    procedure SetEditBox(x: TWPCustomRtfEdit); virtual;
{$ELSE}
    FEditBox: TWPCustomRichText;
    procedure SetEditBox(x: TWPCustomRichText); virtual;
{$ENDIF}
    function Changing: Boolean; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function MayOpenDialog(Form: TForm): Boolean; virtual;
    procedure DoShowDialog(Sender: TObject); virtual;
  published
{$IFDEF WPTOOLS5}
    property EditBox: TWPCustomRtfEdit read FEditBox write SetEditBox;
{$ELSE}
    property EditBox: TWPCustomRichText read FEditBox write SetEditBox;
{$ENDIF}
    {:: This event is triggered when the dialog is displayed. It can be used to
    modify the dialog. Example:
    <code>
    procedure TForm1.WPBulletDlg1ShowDialog(Sender: TObject);
begin
   (Sender as TWPBulletDialog).TabSheet3.TabVisible := FALSE;
end;</code> }
    property OnShowDialog: TNotifyEvent read FOnShowDialog write FOnShowDialog;
  public
    function Execute: Boolean; virtual;
    function Show: Boolean;
    {:: Close and free the dialog. Only usuable for non modal dialogs,
    such as the preview or the WPManageHeaderFooter dialog. }
    procedure Close; virtual;
    procedure _CreateFormAndFree;
    property RTFProps : TWPRTFProps read FRTFProps write FRTFProps;
  end;

  // Modify the shaded forms globally !
var WPShadedFormStandard: Boolean;
  WPShadedFormBothWays: Boolean;
  WPShadedFormHorizontal: Boolean;
  WPShadedFormImage: TImage;
  WPShadedFormImageTiled: Boolean;

  WPCheckBoxStateToThreeState: array[TCheckBoxState] of TThreeState = (tsFALSE, tsTRUE, tsIgnore);
  WPThreeStatetoCheckBoxState: array[TThreeState] of TCheckBoxState = (cbGrayed, cbChecked, cbUnchecked);


//:: This global string is used to separate the trees in the created XML structure
  WPLocalizeLanguage: string = 'EN';

{:: If this boolean is true all instances of TWPLocalizeForm will save their strings after the OnDestroy event. }
  WPLocalizeSaveForms: Boolean;

{:: If this boolean is true all instances of TWPLocalizeForm will LOAD their strings after the OnCreate event. }
  WPLocalizeLoadForms: Boolean;
 {:: See <see class="TWPLocalizeForm">. }
  WPLangInterface: TWPLocalizationInterface;


procedure WPTools_SaveVCLStrings;
procedure WPTools_LoadVCLStrings;

implementation

{ ------- TWPValueEdit ----------------------------------------------
   will automatically convert the input into twips
  ------------------------------------------------------------------- }

{$IFDEF USETHEMES}

procedure TWPValueEdit.ChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
begin
  AllowChange := False;
  if Direction = updUp then UpClick(Sender);
  if Direction = updDown then DownClick(Sender);
end;
{$ENDIF}



constructor TWPValueEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFNDEF USETHEMES}
  FButton := TWPSpinButton.Create(Self);
  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
{$ELSE}
  FUpDn := TUpDown.Create(Self);
  FUpDn.Parent := Self;
  FUpDn.Align := alRight;
  FUpDn.Width := 15;
  FUpDn.Associate := Self;
  FUpDn.Min := Low(SmallInt);
  FUpDn.Max := High(SmallInt);
  FUpDn.OnChangingEx := ChangingEx;
{$ENDIF}
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FUndefined := FALSE;
  FIncrement := 1;
  FPrecision := 2;
  FEditorEnabled := True;
  FPopUp := nil;
  AvailableUnits := [euInch, euCm, euPt];
end;

destructor TWPValueEdit.Destroy;
begin
{$IFNDEF USETHEMES}
  FButton := nil;
{$ELSE}
  FUpDn.Free;
{$ENDIF}
  inherited Destroy;
end;

procedure TWPValueEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then
    UpClick(Self)
  else if Key = VK_DOWN then
    DownClick(Self);
  inherited KeyDown(Key, Shift);
end;

procedure TWPValueEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then
  try
    FInKeyPress := TRUE;
    inherited KeyPress(Key);
  finally
    FInKeyPress := FALSE;
    if FUndefined then
    begin FUndefined := FALSE;
          invalidate;
    end;
     // Change;
  end;
end;

function TWPValueEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, #8, #27, '0'..'9']);

  {
    ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled	and Result and ((Key >=	#32) or
      (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE)))	then
    Result := False;	  }
end;

procedure TWPValueEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not Ctl3d then
    Params.Style := Params.Style or WS_BORDER
  else
    Params.Style := Params.Style and not WS_BORDER;
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TWPValueEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TWPValueEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TWPValueEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, Integer(@Loc));
  Loc.Bottom := ClientHeight;
  Loc.Right := ClientWidth - Button.Width - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, Integer(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, Integer(@Loc)); {debug}
end;

procedure TWPValueEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  if Height < MinHeight then
    Height := MinHeight
  else if Button <> nil then
  begin
    if Ctl3D then
      Button.SetBounds(ClientWidth - Button.Width, 0, Button.Width,
        ClientHeight)
    else
      Button.SetBounds(ClientWidth - Button.Width - 1, 1, Button.Width,
        ClientHeight - 2);
    SetEditRect;
  end;
end;

function TWPValueEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TWPValueEdit.UpClick(Sender: TObject);
begin
  if ReadOnly then
    MessageBeep(0)
  else
  begin
    InternSetValue(CheckValue(Value + FIncrement));
    if assigned(FOnUpClick) then FOnUpClick(Self);
  end;
end;

procedure TWPValueEdit.DownClick(Sender: TObject);
begin
  if ReadOnly then
    MessageBeep(0)
  else
  begin
    InternSetValue(CheckValue(Value - FIncrement));
    if assigned(FOnDownClick) then FOnDownClick(Self);
  end;
end;

{$IFDEF DELPHI4}

function TWPValueEdit.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint):
  Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  if not Result then
  begin
    DownClick(nil);
  end;
end;

function TWPValueEdit.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint):
  Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  if not Result then
  begin
    UpClick(nil);
  end;
end;
{$ENDIF}


procedure TWPValueEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
  Value := CheckValue(Value);
end;

procedure TWPValueEdit.WMPaint(var Message: TWMPaint);
begin
  if FUndefined then
  begin
    Font.Color := clBtnShadow;
  end else
     Font.Color := clWindowText;
  inherited;
end;

procedure TWPValueEdit.WMCut(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
  Value := CheckValue(Value);
end;

procedure TWPValueEdit.CMExit(var Message: TCMExit);
var
  val: Integer;
begin
  inherited;
  val := Value;
  if CheckValue(val) <> val then SetValue(val);
  FPopUp.Free;
  FPopUp := nil;
end;

procedure TWPValueEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  FPopUp.Free;
  FPopUp := nil;
  inherited;
end;

procedure TWPValueEdit.SetUnit(x: TWPEditUnit);
var
  tv: Integer;
begin
  if FUnit <> x then
  begin
    tv := Value;
    if (x <> euPercent) and (FUnit <> euPercent)
      and (x <> euMultiple) and (FUnit <> euMultiple) then
    begin
      FUnit := x;
      if not Undefined then ChangeValue(tv);
    end
    else { conversion is senseless }
    begin
      FUnit := x;
      if (FUnit = euPercent) and not Undefined then Value := 100;
    end;
    case FUnit of
      euStandard: FIncrement := 1;
      euCM: FIncrement := 56;
      euInch: FIncrement := 144;
      euPt: FIncrement := 20;
      euTwips: FIncrement := 1;
      euPercent: FIncrement := 1;
      euMultiple: FIncrement := 120;
    end;
    if assigned(FOnUnitChange) then FOnUnitChange(Self);
  end;
end;

procedure TWPValueEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Button.Enabled := Enabled;
  Button.invalidate;
end;

function TWPValueEdit.GetValue: Integer;
var
  val: real;
  t, vt: string;
  i, l: Integer;
begin
  Result := 0;
  i := 1;
  t := text;
  if t <> '' then
  begin
    vt := '';
    l := length(t);
    if (t <> '') and (t <> '0') then
      while (i <= l) and (((t[i] in ['0'..'9']) or (t[i] = DecimalSeparator))
        or (FAllowNegative and (t[i] = '-'))) do
      begin
        vt := vt + t[i];
        inc(i);
      end;
    if vt = '' then
      val := 0
    else
    begin
      try
        val := StrToFloat(vt);
      except
        val := 0;
        text := '0';
      end;
    end;

    case FUnit of
      euStandard: Result := Round(val);
      euCM: Result := round(val * 566.929);
      euInch: Result := round(val * 1440);
      euPt: Result := round(val * 20);
      euTwips: Result := round(val);
      euPercent: Result := round(val);
      euMultiple:
        begin Result := round(val * 240);
          if Result < 240 then Result := 240;
        end;
    end;
    Result := CheckValue(Result);
  end;
end;

function TWPValueEdit.GetIntValue: Integer;
var
  t, vt: string;
  i, l: Integer;
begin
  Result := 0;
  i := 1;
  t := text;
  if t <> '' then
  begin
    vt := '';
    l := length(t);
    if (t <> '') and (t <> '0') then
      while (i <= l) and (((t[i] in ['0'..'9']) or (t[i] = DecimalSeparator))
        or (FAllowNegative and (t[i] = '-'))) do
      begin
        vt := vt + t[i];
        inc(i);
      end;
    if vt = '' then
      Result := 0
    else
    begin
      try
        Result := Round(StrToFloat(vt));
      except
        Result := 0;
        text := '0';
      end;
    end;
  end;
end;

procedure TWPValueEdit.SetUndefinedVal(Sender: TObject);
begin
  if FChangeToUndefined then
    FChangeToUndefined := FALSE
  else
  begin
    Undefined := TRUE;
    FChangeToUndefined := TRUE;
  end;
end;

procedure TWPValueEdit.FormatValue(NewValue: Integer);
var S: string;
begin
  S := '';
  case FUnit of
    euStandard: S := IntToStr(NewValue);
    euCM: S := FloatToStrF(NewValue / 566.929, ffFixed, 8, FPrecision) + #32 + 'cm';
    euInch: S := FloatToStrF(NewValue / 1440, ffFixed, 8, FPrecision) + #32 + 'in';
    euPt: S := IntToStr(NewValue div 20) + #32 + 'pt';
    euTwips:
      if NoUnitText then
        S := IntToStr(NewValue)
      else
        S := IntToStr(NewValue) + #32 + 'tw';
    euPercent: S := IntToStr(NewValue) + #32 + '%';
    euMultiple: S := FloatToStrF(NewValue / 240, ffFixed, 3, 1);
  end;
  if not (csLoading in ComponentState) and Assigned(FOnFormatValue) then
    FOnFormatValue(Self, FUnit, NewValue, S);

{$IFNDEF CLR}
  if csLoading in ComponentState then
    Perform(WM_SETTEXT, 0, Integer(PChar(s)))
  else
{$ENDIF}
    Text := S;
end;


procedure TWPValueEdit.ChangeValue(NewValue: Integer);
var
  temp: Boolean;
begin
  temp := FInKeyPress;
  FInKeyPress := TRUE;
  try
    NewValue := CheckValue(NewValue);
    FormatValue(NewValue);
  finally
    FInKeyPress := temp;
  end;
end;

procedure TWPValueEdit.SetValue(NewValue: Integer);
begin
  FUndefined := FALSE;
  FChangeToUndefined := FALSE;
{$IFNDEF USETHEMES}
  FButton.Timer.Enabled := FALSE;
{$ENDIF}
  InternSetValue(NewValue);
end;

procedure TWPValueEdit.SetUndefinedValue(NewValue: Integer);
begin
  SetValue(NewValue);
  FUndefined := TRUE;
end;

procedure TWPValueEdit.SetIntValue(NewValue: Integer);
begin
  FUndefined := FALSE;
  FChangeToUndefined := FALSE;
{$IFNDEF USETHEMES}
  FButton.Timer.Enabled := FALSE;
{$ENDIF}
  NewValue := CheckValue(NewValue);
  FormatValue(NewValue);
end;

procedure TWPValueEdit.SetUndefined(x: Boolean);
begin
  FUndefined := x;
  FChangeToUndefined := FALSE;
  if x then Text := '';
end;

function TWPValueEdit.GetUndefined : Boolean;
begin
  Result := FUndefined or (Text='');

end;

procedure TWPValueEdit.InternSetValue(NewValue: Integer);
var
  FOnChange: TNotifyEvent;
begin
  NewValue := CheckValue(NewValue);
  FormatValue(NewValue);
  if not (csLoading in ComponentState) then
  begin
    FOnChange := OnCHange;
    if assigned(FOnChange) then FOnChange(Self);
    FUndefined := FALSE;
    FChangeToUndefined := FALSE;
  end;
end;

function TWPValueEdit.CheckValue(NewValue: Integer): Integer;
begin
  if (NewValue >= 0) or FAllowNegative then
    Result := NewValue
  else
    Result := 0;
  if (FUnit = euMultiple) and (Result < 240) then Result := 240;
end;

procedure TWPValueEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  n: TMenuItem;
  p: TPoint;
  i: Integer;
  chk: Boolean;
begin
  inherited MouseDown(Button, Shift, x, y);
  if (ssRight in Shift) and not Assigned(PopupMenu)
    and not (FAvailableUnits = []) and (FUnit <> euPercent)
    and (FUnit <> euMultiple) and (FUnit <> euStandard) then
  begin
    if FPopUp = nil then
    begin
      FPopUp := TPopUpMenu.Create(self);
      if euInch in FAvailableUnits then
      begin
        n := TMenuItem.Create(FPopUp);
        n.Caption := WPLoadStr(meUnitInch);
        n.OnClick := UnitClick;
        n.Tag := 1;
        FPopUp.Items.Add(n);
      end;
      if euCm in FAvailableUnits then
      begin
        n := TMenuItem.Create(FPopUp);
        n.Caption := WPLoadStr(meUnitCM);
        n.OnClick := UnitClick;
        n.Tag := 2;
        FPopUp.Items.Add(n);
      end;
      if euPt in FAvailableUnits then
      begin
        n := TMenuItem.Create(FPopUp);
        n.Caption := 'Pt';
        n.OnClick := UnitClick;
        n.Tag := 3;
        FPopUp.Items.Add(n);
      end;
      if euTwips in FAvailableUnits then
      begin
        n := TMenuItem.Create(FPopUp);
        n.Caption := 'Twips';
        n.OnClick := UnitClick;
        n.Tag := 4;
        FPopUp.Items.Add(n);
      end;
      if AllowUndefined then
      begin
        FUndefinedPop := TMenuItem.Create(FPopUp);
        FUndefinedPop.Caption := '<empty>';
        FUndefinedPop.OnClick := SetUndefinedVal;
        FUndefinedPop.Tag := 1000;
        FPopUp.Items.Add(FUndefinedPop);
      end;
    end;

    if FUndefinedPop <> nil then
      FUndefinedPop.Checked := ChangeToUndefined;
    p.x := x;
    p.y := y;
    p := ClientToScreen(p);
    i := 0;
    chk := FALSE;
    while i < FPopUp.Items.Count do
    begin
      case FPopUp.Items[i].Tag of
        1: chk := FUnit = euInch;
        2: chk := FUnit = euCM;
        3: chk := FUnit = euPT;
        4: chk := FUnit = euTWIPS;
      end;
      if FPopUp.Items[i].Tag < 1000 then
        FPopUp.Items[i].Checked := chk;
      inc(i);
    end;
    FPopUp.PopUp(p.x, p.y);
  end;
end;

procedure TWPValueEdit.UnitClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    case TMenuItem(Sender).Tag of
      1: SetUnit(euInch);
      2: SetUnit(euCM);
      3: SetUnit(euPT);
      4: SetUnit(euTWIPS);
    end;
  end;
end;

procedure TWPValueEdit.Change;
begin
  if not FInKeyPress and (Text <> '') then inherited Change;
end;

function TWPValueEdit.GetValue_VHC(old: Integer): Integer;
begin
  if ValueHasChanged then
    Result := Value
  else
    Result := old;
  ValueHasChanged := FALSE;
end;

{ ---------- only a little modified spin button	---------- }

{ TWPSpinButton	}
{$IFNDEF USETHEMES}

constructor TWPSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Timer := TTimer.Create(Self);
  Timer.OnTimer := OnTimer;
  Timer.Enabled := FALSE;
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];
  Width := 20;
  Height := 25;
  Ctl3d := FALSE;
end;

destructor TWPSpinButton.Destroy;
begin
  Timer.Free;
  inherited Destroy;
end;

procedure TWPSpinButton.OnTimer(Sender: TObject);
var
  l: DWORD;
begin
  l := GetTickCount - FStartTime;
  case State of
    spUp:
      if assigned(FOnUpClick) then FOnUpClick(Self);
    spDown:
      if assigned(FOnDownClick) then FOnDownClick(Self);
  else
    Timer.Enabled := FALSE;
  end;

  if l > 4000 then
  begin
    Timer.Enabled := FALSE;
    while FState <> spNormal do
    begin
      l := GetTickCount + 50;
      while GetTickCount < l do
        Application.ProcessMessages;
      case State of
        spUp:
          if assigned(FOnUpClick) then FOnUpClick(Self);
        spDown:
          if assigned(FOnDownClick) then FOnDownClick(Self);
      end;
    end;
  end
  else if l > 3000 then
    Timer.Interval := 66
  else if l > 2000 then
    Timer.Interval := 100
  else if l > 1000 then
    Timer.Interval := 200;

end;

procedure TWPSpinButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Button=mbLeft then
  begin
  if y > Height div 2 then
    State := spDown
  else
    State := spUp;
  MouseCapture := TRUE;
  Timer.Interval := 300;
  FStartTime := GetTickCount;
  Timer.Enabled := TRUE;
  case FState of
    spUp:
      if assigned(FOnUpClick) then FOnUpClick(Self);
    spDown:
      if assigned(FOnDownClick) then FOnDownClick(Self);
  end;
  end else inherited MouseDown(Button,Shift,X,Y);
end;

procedure TWPSpinButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Button=mbLeft then
  begin
  MouseCapture := FALSE;
  State := spNormal;
  Timer.Enabled := FALSE;
  end else inherited MouseUp(Button,Shift,X,Y);
end;

procedure TWPSpinButton.SetState(x: TWPSpinButtonState);
begin
  if FState <> x then
  begin
    FState := x;
    invalidate;
  end;
end;

procedure TWPSpinButton.Paint;
var
  h, d: Integer;
  rec: TRect;
  procedure FRAME(R: TRECT; DOWN: BOOLEAN);
  begin
    if down then
      with Canvas do
      begin
        Pen.Color := clBtnShadow;
        MoveTo(r.Left, r.Bottom);
        LineTo(r.Left, r.Top);
        LineTo(r.Right, r.Top);
        Pen.Color := clWhite;
        LineTo(r.Right, r.Bottom);
        LineTo(r.Left, r.Bottom);
      end
    else
      with Canvas do
      begin
        Pen.Color := clWhite;
        MoveTo(r.Left, r.Bottom);
        LineTo(r.Left, r.Top);
        LineTo(r.Right - 1, r.Top);
        Pen.Color := clBtnShadow;
        LineTo(r.Right - 1, r.Bottom);
        LineTo(r.Left, r.Bottom);
        Pen.Color := clBlack;
        MoveTo(r.Right, r.Top + 1);
        LineTo(r.Right, r.Bottom);
      end;
  end;
  procedure DRAWARROW(X, Y, W: INTEGER; UP: BOOLEAN);
  var
    i, j: integer;
  begin
    i := w;
    j := 0;
    x := x - w;
    while i >= 0 do
    begin
      Canvas.MoveTo(x + j, y);
      Canvas.LineTo(x + w + i, y);
      dec(i);
      inc(j);
      if up then
        dec(y)
      else
        inc(y);
    end;
  end;
begin
  inherited Paint;
  h := Height div 2;
  rec := ClientRect;
  Canvas.Brush.Color := clBtnFace;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(rec);
  Canvas.Pen.Color := clBtnFace;
  Canvas.Rectangle(rec.Left, Rec.Top, Rec.Right, Rec.Bottom);
  inc(rec.Left, 1);
  rec.Bottom := h - 1;
  Frame(rec, FState = spUp);
  rec.Bottom := Height - 1;
  rec.Top := h;
  Frame(rec, FState = spDown);
   { now draw the arrows }
  if Enabled then
    Canvas.Pen.Color := clBlack
  else
    Canvas.Pen.Color := clBtnShadow;
  if FState = spUp then
    d := 1
  else
    d := 0;
  DrawArrow(Width div 2 + d + 1, h - 4 + d, 3, true);
  if FState = spDown then
    d := 1
  else
    d := 0;
  DrawArrow(Width div 2 + d + 1, h + 3 + d, 3, FALSE);
end;

{$ENDIF}
{ ----- Shaded Panel --------------- }

constructor TWPShadedPanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FShadeBothWays := FALSE;
end;

procedure TWPShadedPanel.SetShadeBothWays(x: Boolean);
begin
  if FShadeBothWays <> x then
  begin FShadeBothWays := x;
    invalidate;
  end;
end;

procedure TWPShadedPanel.SetHorizontal(x: Boolean);
begin
  if FHorizontal <> x then
  begin FHorizontal := x;
    invalidate;
  end;
end;

procedure TWPShadedPanel.SetImageTiled(x: Boolean);
begin
  if FImageTiled <> x then
  begin FImageTiled := x;
    invalidate;
  end;
end;

procedure TWPShadedPanel.SetImage(x: TImage);
begin
  FImage := x;
  if FImage <> nil then FImage.FreeNotification(Self);
  invalidate;
end;

procedure TWPShadedPanel.UseGlobal;
begin
  FHorizontal := WPShadedFormHorizontal;
  FShadeBothWays := WPShadedFormBothWays;
  FImage := WPShadedFormImage;
  FImageTiled := WPShadedFormImageTiled;
end;

procedure TWPShadedPanel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FImage) then
    FImage := nil;
  inherited Notification(AComponent, Operation);
end;

procedure TWPShadedPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if FNoShading then inherited
  else Message.Result := -1;
end;


procedure TWPShadedPanel.Paint;
var
  s, inf: Integer;
  r: TRect;
  TopColor, BottomColor: TColor;
const
  Alignments: array[TAlignment] of Integer = (DT_LEFT, DT_RIGHT, DT_CENTER);
  procedure ADJUSTCOLORS(BEVEL: TPANELBEVEL);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;
begin
  if NoShading then inherited else
  begin
    r := ClientRect;
    inf := 0;
    if BevelInner <> bvNone then inc(inf, BevelWidth);
    if BevelOuter <> bvNone then inc(inf, BevelWidth);
    Inc(r.Top, inf);
    Inc(r.Left, inf);
    Dec(r.Right, inf);
    Dec(r.Bottom, inf);

    s := 192 - 128;
    if FImage <> nil then
      WPDrawShade(Canvas, r, s, FHorizontal, FShadeBothWays, FImage.Picture.Graphic, FImageTiled, Color)
    else WPDrawShade(Canvas, r, s, FHorizontal, FShadeBothWays, nil, FImageTiled, Color);
    if assigned(FOnPaint) then FOnPaint(Self);
    r := GetClientRect;
    if BevelOuter <> bvNone then
    begin
      AdjustColors(BevelOuter);
      Frame3D(Canvas, r, TopColor, BottomColor, BevelWidth);
    end;
    Frame3D(Canvas, r, Color, Color, BorderWidth);
    if BevelInner <> bvNone then
    begin
      AdjustColors(BevelInner);
      Frame3D(Canvas, r, TopColor, BottomColor, BevelWidth);
    end;
  end;
end;

constructor TWPShadedForm.Create(aOwner: TComponent);
begin
{$IFDEF USELOCALIZATION}
  _XMLParent := 'WPTDlg';
{$ENDIF}
  if aOwner is TWPCustomAttrDlg then
    FWPCustomAttrDlg := TWPCustomAttrDlg(aOwner);
  inherited Create(aOwner);
end;

procedure TWPShadedForm.DoShow;
begin
  inherited DoShow;
  if FWPCustomAttrDlg <> nil then
    FWPCustomAttrDlg.DoShowDialog(Self);
end;

procedure TWPShadedForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if WPShadedFormStandard then inherited else Message.Result := 1;
end;

procedure TWPShadedForm.Paint;
begin
  if WPShadedFormStandard then inherited Paint
  else if WPShadedFormImage <> nil then
    WPDrawShade(Canvas, ClientRect, 192 - 128, WPShadedFormHorizontal, WPShadedFormBothWays,
      WPShadedFormImage.Picture.Graphic, WPShadedFormImageTiled, Color)
  else WPDrawShade(Canvas, ClientRect, 192 - 128, WPShadedFormHorizontal, WPShadedFormBothWays,
      nil, WPShadedFormImageTiled, Color);
end;

{ ----- TWPMemoryStream ------------ }

function TWPMemoryStream.GetAsString: string;
begin
  Result := StrPas(Memory);
end;

function TWPMemoryStream.GetAsBoolean: Boolean;
begin
  Result := CompareText(StrPas(Memory), '.T.') = 0;
end;

function TWPMemoryStream.GetAsInteger: Integer;
begin
  Result := StrToIntDef(StrPas(Memory), 0);
end;

procedure TWPMemoryStream.SetAsString(const x: string);
begin
  Clear;
{$IFNDEF CLR}
  if x <> '' then Write(x[1], Length(x));
{$ELSE}
  eof := 0;
  if x <> '' then Write(x);
  Write(eof);
{$ENDIF}
end;

procedure TWPMemoryStream.SetAsBoolean(const x: Boolean);
begin
  if x then SetAsString('.T.')
  else SetAsString('.F.');
end;

procedure TWPMemoryStream.SetAsInteger(const x: Integer);
begin
  SetAsString(IntToStr(x));
end;

function TWPMemoryStream.GetAsNameValue(var name: string; var Value: Integer): Boolean;
var s: string;
  i: integer;
begin
  s := StrPas(Memory);
  i := Pos('=', s);
  if i < 0 then begin name := ''; Value := 0; Result := FALSE; end else
  begin
    name := Copy(s, 1, i - 1);
    Value := StrToIntDef(Copy(s, i + 1, 255), 0);
    Result := TRUE;
  end;
end;

procedure TWPMemoryStream.SetAsNameValue(const name: string; const Value: Integer);
begin
  SetAsString(name + '=' + IntToStr(Value));
end;

{ -----	WPContainer ------------ }

constructor TWPContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FData := TMemoryStream.Create;
  FWorkStream := TWPMemoryStream.Create;
  DataId := $E4E3E2E1;
  Errmsg := 'Unknown Fileformat';
end;

destructor TWPContainer.Destroy;
begin
  FData.Free;
  FWorkStream.Free;
  inherited Destroy;
end;

function TWPContainer.GetStream: TWPMemoryStream;
begin
  Result := TWPMemoryStream(FWorkStream);
end;

function TWPContainer.OpenStream(name: string): TWPMemoryStream;
begin
  if FStreamIsOpen then CloseStream;
  FWorkStream.Clear;
  StrPLCopy(FNameBuf, name, 100);
  Result := TWPMemoryStream(FWorkStream);
  FStreamIsOpen := TRUE;
end;

procedure TWPContainer.CloseStream;
var
  len: Integer;
begin
  FData.Write(DataId, SizeOf(DataId));
  len := StrLen(FNameBuf);
  FData.Write(len, SizeOf(len));
  FData.Write(FNameBuf[0], len);
  len := FWorkStream.Size;
  FData.Write(len, SizeOf(len));
  FData.Write(PChar(FWorkStream.Memory)^, len);
  FWorkStream.Clear;
  FNameBuf[0] := #0;
  FStreamIsOpen := FALSE;
end;

procedure TWPContainer.SaveToStream(s: TStream);
begin
  if FStreamIsOpen then CloseStream;
  FData.SaveToStream(s);
end;

function TWPContainer.DataStream: TStream;
begin
  if FStreamIsOpen then CloseStream;
  FData.Position := 0;
  Result := FData;
end;

procedure TWPContainer.LoadFromStream(s: TStream);
begin
  FData.LoadFromStream(s);
  Load;
end;

procedure TWPContainer.SaveToFile(s: TFilename);
begin
  if FStreamIsOpen then CloseStream;
  FData.SaveToFile(s);
end;

procedure TWPContainer.LoadFromFile(s: TFilename);
begin
  FData.LoadFromFile(s);
  Load;
end;

procedure TWPContainer.Clear;
begin
  FData.Clear;
  FWorkStream.Clear;
  FNameBuf[0] := #0;
end;

procedure TWPContainer.Load;
var
  id, len: DWord;
begin
  FData.Position := 0;
  repeat
    FData.Read(id, SizeOf(id));
    FData.Read(len, Sizeof(len));
    if id <> DataID then exit; //raise Exception.Create(Errmsg);
    FData.Read(FNameBuf[0], len);
    FNameBuf[len] := #0;
    FData.Read(len, Sizeof(len));
    FWorkStream.Clear;
    FWorkStream.SetSize(len);
    FData.Read(FWorkStream.Memory^, len);
    FWorkStream.Position := 0;
    if assigned(FOnLoadData) then
      FOnLoadData(StrPas(FNameBuf), TStream(FWorkStream));
  until FData.Position >= FData.Size - 4;
end;


{$IFDEF WPTOOLS5}

constructor TWPWallPaper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  Height := 105;
  Width := 105;
end;

destructor TWPWallPaper.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

function TWPWallPaper.GetPalette: HPALETTE;
begin
  Result := 0;
  if FPicture.Graphic is TBitmap then
    Result := TBitmap(FPicture.Graphic).Palette;
end;

procedure TWPWallPaper.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TWPWallPaper.PictureChanged(Sender: TObject);
begin
  if (Picture.Graphic is TBitmap) and (Picture.Width = Width) and
    (Picture.Height = Height) then
    ControlStyle := ControlStyle + [csOpaque] else
    ControlStyle := ControlStyle - [csOpaque];
  Invalidate;
end;

function TWPWallPaper.Draw(thiscanvas: TCanvas; r: TRect): Boolean;
var
  bxx, byy, bww, bhh: Integer;
  xx, yy, ww, hh, bx, by: Integer;
  qw, qh: Integer;
  procedure DRAWTHISRECT(X, Y, W, H, SX, SY: INTEGER);
  begin
    if (w > 0) and (h > 0) then
    begin
      if sx + w > bww then w := bww - sx;
      if sy + h > bhh then h := bhh - sy;
      thiscanvas.CopyRect(Rect(x, y, x + w, y + h),
        FBackground.Canvas,
        Rect(sx, sy, sx + w, sy + h));
    end;
  end;
begin
  Result := FALSE;
  if Picture.Graphic is TBitmap then
    FBackground := Picture.Graphic as TBitmap
  else exit;
  Result := FALSE;
  bww := FBackground.Width;
  bhh := FBackGround.Height;
  if (bww > 0) and (bhh > 0) then
  begin
    hh := r.Bottom - r.Top;
    yy := r.Top mod bhh;
    by := r.Top - yy;
     { byy := (topoffset + yy) mod bhh;  }
    byy := yy;
    qh := hh;
    while qh > 0 do
    begin
      if byy + hh > bhh then qh := bhh - byy
      else qh := hh;
      ww := r.Right - r.Left;
      xx := r.Left mod bww;
      bx := r.Left - xx;
      bxx := (leftoffset + xx) mod bww;
      qw := ww;
      while qw > 0 do
      begin
        if bxx + ww > bww then qw := bww - bxx
        else qw := ww;
        DrawThisRect(bx + xx, by + yy, qw, qh, bxx, byy);
        inc(xx, qw);
        dec(ww, qw);
        bxx := 0;
      end;
      inc(yy, qh);
      dec(hh, qh);
      byy := 0;
    end;
    Result := TRUE;
  end;
end;

procedure TWPWallPaper.Paint;
begin
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  if Picture.Graphic is TBitmap then
  begin
    FBackground := Picture.Graphic as TBitmap;
    Draw(Canvas, ClientRect);
  end else
    Canvas.StretchDraw(ClientRect, Picture.Graphic);
end;
{$ENDIF}

{$IFDEF WPTOOLS5}

procedure TWPCustomAttrDlg.SetEditBox(x: TWPCustomRtfEdit);
{$ELSE}

procedure TWPCustomAttrDlg.SetEditBox(x: TWPCustomRichText);
{$ENDIF}
begin
  FEditBox := x;
  if FEditBox <> nil then FEditBox.FreeNotification(Self);
end;

function TWPCustomAttrDlg.Execute: Boolean;
begin
  Result := FALSE;
end;

function TWPCustomAttrDlg.Show: Boolean;
begin
  Result := Execute;
end;

function TWPCustomAttrDlg.MayOpenDialog(Form: TForm): Boolean;
var env : TWPToolsBasicEnviroment;
begin
  if FEditBox<>nil then
       env := FEditBox.HeaderFooter.RTFProps.Enviroment
  else env := GlobalWPToolsCustomEnviroment;
  if (env <> nil) and (env is TWPToolsEnviroment) then
       Result := TWPToolsEnviroment(env).MayOpenDialog(EditBox, Self, Form)
  else Result := TRUE;
end;

procedure TWPCustomAttrDlg.Close;
begin

end;

procedure TWPCustomAttrDlg._CreateFormAndFree;
begin
  try
    FCreateAndFreeDialog := TRUE;
    Execute;
  finally
    FCreateAndFreeDialog := FALSE;
  end;
end;

procedure TWPCustomAttrDlg.DoShowDialog(Sender: TObject);
var env : TWPToolsBasicEnviroment;
begin
  if FEditBox<>nil then
       env := FEditBox.HeaderFooter.RTFProps.Enviroment
  else env := GlobalWPToolsCustomEnviroment;
  if (env <> nil) and (env is TWPToolsEnviroment) then
      TWPToolsEnviroment(env).DoBeforeShow(EditBox, Self, Sender as TForm);
  if assigned(FOnShowDialog) then FOnShowDialog(Sender);
end;

procedure TWPCustomAttrDlg.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FEditBox) then
    FEditBox := nil;
  inherited Notification(AComponent, Operation);
end;

function TWPCustomAttrDlg.Changing: Boolean;
begin
  if FEditBox <> nil then
  begin
    FOldModified := FEditBox.Modified;
    Result := FEditBox.Changing;
    if Result then FEditBox.ChangeApplied; //<-- Set 'Modified'
  end
  else
  begin
     Result := TRUE;
     FOldModified := TRUE;
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// local localisation implementation. Uses a link to IWPLocalizationInterface
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

 //################ TWPLocalizeForm
{$IFDEF USELOCALIZATION}

procedure TWPLocalizeForm.DoCreate;
begin
  inherited DoCreate;
  if WPLocalizeLoadForms and not _DontLocalize then LoadLocStrings;
end;

{$IFDEF LANG_MODIFY_LABELS}
procedure TWPLocalizeForm.WndProc(var Msg: TMessage);
var ctr : TControl; P : TPoint;  s : String;
begin
    if (Msg.Msg = WM_RBUTTONUP) then
    begin
      P := SmallPointToPoint(TWMMouse(Msg).Pos);
      ctr := ControlAtPos(P,true,true);
      if ctr<>nil then
      begin
        if (ctr is TLabel) and InputQuery('Modify label', TLabel(ctr).Name, s) then
        begin
           TLabel(ctr).Caption := s;
           SaveLocStrings;
        end {else
        if (ctr is TButton) and InputQuery('Modify Button', TButton(ctr).Name, s) then
        begin
           TButton(ctr).Caption := s;
           SaveLocStrings;
        end else
        if (ctr is TGroupBox) and InputQuery('Modify GroupBox', TCustomGroupBox(ctr).Name, s) then
        begin
           TGroupBox(ctr).Caption := s;
           SaveLocStrings;
        end else
        if (ctr is TRadioGroup) and InputQuery('Modify Radio Group', TRadioGroup(ctr).Name, s) then
        begin
           TRadioGroup(ctr).Caption := s;
           SaveLocStrings;
        end else
        if (ctr is TTabSheet) and InputQuery('Modify TabSheet', TTabSheet(ctr).Name, s) then
        begin
           TTabSheet(ctr).Caption := s;
           SaveLocStrings;
        end};  
      end;
    end else inherited WndProc(Msg);
end;
{$ENDIF}

procedure TWPLocalizeForm.DoDestroy;
begin
  inherited DoDestroy;
  if WPLocalizeSaveForms and not _DontSaveLanguage then SaveLocStrings;
end;

function TWPLocalizeForm.LocStringName: string;
begin
  Result := '';
  if _XMLParent <> '' then Result := _XMLParent + '/';
  if _XMLName <> '' then Result := Result + _XMLName else Result := Result + Name;
end;

procedure TWPLocalizeForm.LoadLocStrings;
begin
  if assigned(WPLangInterface) then
    WPLangInterface.LoadForm(LocStringName, Self, True, True, True);
end;

procedure TWPLocalizeForm.SaveLocStrings;
begin
  if assigned(WPLangInterface) then
    WPLangInterface.SaveForm(LocStringName, Self, True, True, True);
end;

{$ENDIF USELOCALIZATION}

 //################ TWPLocalizationInterface

constructor TWPLocalizationInterface.Create(WPLocalizationInterface: IUnknown);
begin
  inherited Create;
  FInterface := WPLocalizationInterface as IWPLocalizationInterface;
end;

destructor TWPLocalizationInterface.Destroy;
begin
  FInterface := nil;
  inherited Destroy;
end;

procedure TWPLocalizationInterface.SaveForm(
  const Name: string; Form: TWinControl; Menus, Captions, Hints: Boolean);
begin
  if FInterface <> nil then
    FInterface.SaveForm(Name, Form, Menus, Captions, Hints);
end;

procedure TWPLocalizationInterface.LoadForm(
  const Name: string; Form: TWinControl; Menus, Captions, Hints: Boolean);
begin
  if FInterface <> nil then
    FInterface.LoadForm(Name, Form, Menus, Captions, Hints);
end;

procedure TWPLocalizationInterface.SaveStrings(
  const Name: string; const Entries: TStrings; Charset: Integer);
begin
  if FInterface <> nil then
    FInterface.SaveStrings(Name, Entries, Charset);
end;

function TWPLocalizationInterface.LoadStrings(
  const Name: string; Entries: TStrings; var Charset: Integer): Boolean;
begin
  if FInterface <> nil then
    Result := FInterface.LoadStrings(Name, Entries, Charset)
  else Result := FALSE;
end;

procedure TWPLocalizationInterface.SaveString(
  const Name, Text: string; Charset: Integer);
begin
  if FInterface <> nil then
    FInterface.SaveString(Name, Text, Charset);
end;

function TWPLocalizationInterface.LoadString(
  const Name: string; var Text: string; var Charset: Integer): Boolean;
begin
  if FInterface <> nil then
    Result := FInterface.LoadString(Name, Text, Charset)
  else Result := FALSE;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// load and save the WPTools Standard Strings from array  FWPVCLStrings
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure WPTools_SaveVCLStrings;
var
  i: TWPVCLString;
  j : TWPPagePropertyKind;
  k : TWPPagePropertyRange;
  typ: Pointer;
begin
  typ := TypeInfo(TWPVCLString);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for i := Low(TWPVCLString) to High(TWPVCLString) do
      WPLangInterface.SaveString('WPString/' + GetEnumName(typ, Integer(i)), FWPVCLStrings[i], 0);
 typ := TypeInfo(TWPPagePropertyKind);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for j := Low(TWPPagePropertyKind) to High(TWPPagePropertyKind) do
      WPLangInterface.SaveString('WPString/HFK/' + GetEnumName(typ, Integer(j)), WPPagePropertyKindNames[j], 0);
 typ := TypeInfo(TWPPagePropertyRange);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for k := Low(TWPPagePropertyRange) to High(TWPPagePropertyRange) do
      WPLangInterface.SaveString('WPString/HFR/' + GetEnumName(typ, Integer(k)), WPPagePropertyRangeNames[k], 0);

  //NOT POSSIBLE: if assigned(prevWPLocalSaveVCLStrings) then prevWPLocalSaveVCLStrings;
end;

procedure WPTools_LoadVCLStrings;
var
  i : TWPVCLString;
  j : TWPPagePropertyKind;
  k : TWPPagePropertyRange;
  a: Integer;
  s, aa, st: string;
  typ: Pointer;
begin
  s := '';
  aa := FWPVCLStrings[meDefaultUnit_INCH_or_CM];
  typ := TypeInfo(TWPVCLString);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for i := Low(TWPVCLString) to High(TWPVCLString) do
    begin
      st := GetEnumName(typ, Integer(i));
      if WPLangInterface.LoadString('WPString/' + st, s, a) then
        FWPVCLStrings[i] := s;
    end;

  typ := TypeInfo(TWPPagePropertyKind);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for j := Low(TWPPagePropertyKind) to High(TWPPagePropertyKind) do
    begin
      st := GetEnumName(typ, Integer(j));
      if WPLangInterface.LoadString('WPString/HFK/' + st, s, a) then
        WPPagePropertyKindNames[j] := s;
    end;

   typ := TypeInfo(TWPPagePropertyRange);
  if (typ <> nil) and Assigned(WPLangInterface) then
    for k := Low(TWPPagePropertyRange) to High(TWPPagePropertyRange) do
    begin
      st := GetEnumName(typ, Integer(k));
      if WPLangInterface.LoadString('WPString/HFR/' + st, s, a) then
        WPPagePropertyRangeNames[k] := s;
    end;

   // Update global language, too
  if CompareText(FWPVCLStrings[meDefaultUnit_INCH_or_CM], 'INCH') = 0 then
    GlobalValueUnit := euInch
  else if CompareText(FWPVCLStrings[meDefaultUnit_INCH_or_CM], 'CM') = 0 then
    GlobalValueUnit := euCm;

  //NOT POSSIBLE: if assigned(prevWPLocalLoadVCLStrings) then prevWPLocalLoadVCLStrings;
end;


initialization
  WPShadedFormStandard := TRUE;

end.

