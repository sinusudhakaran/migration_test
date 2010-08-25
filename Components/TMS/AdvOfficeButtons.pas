{*************************************************************************}
{ TAdvOfficeButtons components                                            }
{ for Delphi & C++Builder                                                 }
{ version 1.0                                                             }
{                                                                         }
{ written by                                                              }
{    TMS Software                                                         }
{    copyright © 2007                                                     }
{    Email : info@tmssoftware.com                                         }
{    Web : http://www.tmssoftware.com                                     }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvOfficeButtons;

{$I TMSDEFS.INC}
{$R AdvOfficeButtons.res}
{$DEFINE REMOVESTRIP}
{$DEFINE REMOVEDRAW}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus, Buttons, ComObj, ActiveX,
  PictureContainer, AdvGroupBox;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  //


type
  TAnchorClick = procedure (Sender:TObject; Anchor:string) of object;

  TCustomAdvOfficeCheckBox = class(TCustomControl)
  private
    FDown:Boolean;
    FState:TCheckBoxState;
    FFocused:Boolean;
    FCheckColor:TColor;
    FReturnIsTab:Boolean;
    FImages:TImageList;
    FAnchor: string;
    FAnchorClick: TAnchorClick;
    FAnchorEnter: TAnchorClick;
    FAnchorExit: TAnchorClick;
    FURLColor: TColor;
    FImageCache: THTMLPictureCache;
    FBtnVAlign: TTextLayout;
    FAlignment: TLeftRight;
    FEllipsis: Boolean;
    FCaption: string;
    FContainer: TPictureContainer;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FIsWinXP: Boolean;
    FHot: Boolean;
    FClicksDisabled: Boolean;
    FOldCursor: TCursor;
    FReadOnly: Boolean;
    {$IFNDEF TMSDOTNET}
    FBkgBmp: TBitmap;
    FBkgCache: boolean;
    FTransparentCaching: boolean;
    {$ENDIF}
    FDrawBkg: boolean;
    procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure SetCheckColor(Value:TColor);
    procedure SetState(Value:TCheckBoxState);
    procedure SetChecked(Value:Boolean);
    function  GetChecked:Boolean;
    procedure SetCaption(Value: string);
    procedure SetImages(const Value: TImageList);
    procedure SetURLColor(const Value:TColor);
    function IsAnchor(x,y:integer):string;
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetAlignment(const Value: TLeftRight);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    {$IFNDEF TMSDOTNET}
    procedure DrawParentImage (Control: TControl; Dest: TCanvas);
    {$ENDIF}
  protected
    function GetVersionNr: Integer; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer); override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure SetDown(Value:Boolean);
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Loaded; override;
    property Checked: Boolean read GetChecked write SetChecked default False;
    property ClicksDisabled: Boolean read FClicksDisabled write FClicksDisabled;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle; virtual;
    {$IFNDEF TMSDOTNET}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property TransparentChaching: boolean read FTransparentCaching write FTransparentCaching;
    {$ENDIF}
    property DrawBkg: Boolean read FDrawBkg write FDrawBkg;    
  published
    property Action;
    property Anchors;
    property Constraints;
    property Color;
    property Alignment: TLeftRight read FAlignment write SetAlignment;
    property ButtonVertAlign: TTextLayout read FBtnVAlign write setButtonVertAlign default tlTop;
    property Caption: string read FCaption write SetCaption;
    property CheckColor: TColor read FCheckColor write SetCheckColor default clBlack;
    property Down: Boolean read FDown write SetDown default False;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis default False;
    property Enabled;
    property Font;
    property Images: TImageList read FImages write SetImages;
    property ParentFont;
    property ParentColor;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property PopupMenu;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property ReturnIsTab: Boolean read FReturnIsTab write FReturnIsTab;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowHint;
    property State: TCheckBoxState read FState write SetState default cbUnchecked;
    property TabOrder;
    property TabStop;
    property URLColor: TColor read FURLColor write SetURLColor default clBlue;
    property Visible;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnAnchorClick: TAnchorClick read fAnchorClick write fAnchorClick;
    property OnAnchorEnter: TAnchorClick read fAnchorEnter write fAnchorEnter;
    property OnAnchorExit: TAnchorClick read fAnchorExit write fAnchorExit;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeCheckBox = class(TCustomAdvOfficeCheckBox)
  published
    property Checked;
  end;

  TAdvOfficeRadioButton = class(TCustomControl)
  private
    FDown: Boolean;
    FChecked: Boolean;
    FFocused: Boolean;
    FCheckColor: TColor;
    FGroupIndex: Byte;
    FReturnIsTab: Boolean;
    FImages: TImageList;
    FAnchor: string;
    FAnchorClick: TAnchorClick;
    FAnchorEnter: TAnchorClick;
    FAnchorExit: TAnchorClick;
    FURLColor: TColor;
    FImageCache: THTMLPictureCache;
    FBtnVAlign: TTextLayout;
    FAlignment: TLeftRight;
    FEllipsis: Boolean;
    FCaption: string;
    FContainer: TPictureContainer;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FIsWinXP: Boolean;
    FHot: Boolean;
    FClicksDisabled: Boolean;
    FOldCursor: TCursor;
    {$IFNDEF TMSDOTNET}
    FBkgBmp: TBitmap;
    FBkgCache: boolean;
    FTransparentCaching: boolean;
    {$ENDIF}
    FDrawBkg: Boolean;
    procedure TurnSiblingsOff;
    procedure SetDown(Value:Boolean);
    procedure SetChecked(Value:Boolean);
    procedure SetCheckColor(Value:TColor);
    procedure SetImages(const Value: TImageList);
    procedure SetURLColor(const Value:TColor);
    function IsAnchor(x,y:integer):string;
    procedure WMLButtonDown(var Message:TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetAlignment(const Value: TLeftRight);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetCaption(const Value: string);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
    {$IFNDEF TMSDOTNET}
    procedure DrawParentImage (Control: TControl; Dest: TCanvas);
    {$ENDIF}
  protected
    procedure Paint; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer); override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Loaded; override;
    procedure Click; override;
    procedure DoClick; virtual;
    property ClicksDisabled: Boolean read FClicksDisabled write FClicksDisabled;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFNDEF TMSDOTNET}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property TransparentChaching: boolean read FTransparentCaching write FTransparentCaching;
    {$ENDIF}
    property DrawBkg: Boolean read FDrawBkg write FDrawBkg;
  published
    {$IFDEF DELPHI4_LVL}
    property Action;
    property Anchors;
    property Constraints;
    {$ENDIF}
    property Color;
    property Alignment: TLeftRight read fAlignment write SetAlignment;
    property URLColor:TColor read FURLColor write SetURLColor default clBlue;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property Caption: string read FCaption write SetCaption;
    property CheckColor:TColor read FCheckColor write SetCheckColor default clBlack;
    property Checked:Boolean read FChecked write SetChecked default False;
    property Down:Boolean read FDown write SetDown default False;
    property DragCursor;
    {$IFDEF DELPHI4_LVL}
    property DragKind;
    {$ENDIF}
    property DragMode;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis default False;
    property Enabled;
    property Font;
    property GroupIndex:Byte read FGroupIndex write FGroupIndex
      default 0;
    property Images:TImageList read fImages write SetImages;
    property ParentFont;
    property ParentColor;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property PopupMenu;
    property ReturnIsTab:Boolean read FReturnIsTab write FReturnIsTab;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnAnchorClick:TAnchorClick read fAnchorClick write fAnchorClick;
    property OnAnchorEnter:TAnchorClick read fAnchorEnter write fAnchorEnter;
    property OnAnchorExit:TAnchorClick read fAnchorExit write fAnchorExit;
    property Version: string read GetVersion write SetVersion;
  end;

  TEnabledEvent = procedure (Sender:TObject; ItemIndex: Integer; var Enabled: Boolean) of object;


  TCustomAdvOfficeRadioGroup = class(TAdvGroupbox)
  private
    FButtons: TList;
    FItems: TStrings;
    FItemIndex: Integer;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    FCheckColor: TColor;
    FAlignment: TAlignment;
    FBtnVAlign: TTextLayout;
    FImages: TImageList;
    FContainer: TPictureContainer;
    FEllipsis: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FOnIsEnabled: TEnabledEvent;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetCheckColor(const Value: TColor);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetImages(const Value: TImageList);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    function GetVersionNr: Integer; virtual;
    procedure Loaded; override;
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    property Columns: Integer read FColumns write SetColumns default 1;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Items: TStrings read FItems write SetItems;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF DELPHI4_LVL}
    procedure FlipChildren(AllLevels: Boolean); override;
    {$ENDIF}
    procedure PushKey(var Key: Char);
    procedure PushKeyDown(var Key: Word; Shift: TShiftState);
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property CheckColor: TColor read FCheckColor write SetCheckColor default clBlack;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis;
    property Images: TImageList read FImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clSilver;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property OnIsEnabled: TEnabledEvent read FOnIsEnabled write FOnIsEnabled;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeRadioGroup = class(TCustomAdvOfficeRadioGroup)
  private
  protected
  public
  published
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    {$ENDIF}
    property Caption;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ItemIndex;
    property Items;
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
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    {$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property OnStartDrag;
  end;

  TCustomAdvOfficeCheckGroup = class(TAdvGroupBox)
  private
    FButtons: TList;
    FItems: TStrings;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    FCheckColor: TColor;
    FAlignment: TAlignment;
    FBtnVAlign: TTextLayout;
    FImages: TImageList;
    FContainer: TPictureContainer;
    FEllipsis: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FOnIsEnabled: TEnabledEvent;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetCheckColor(const Value: TColor);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetImages(const Value: TImageList);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetChecked(Index: Integer): Boolean;
    procedure SetChecked(Index: Integer; const Value: Boolean);
    function GetReadOnly(Index: Integer): Boolean;
    procedure SetReadOnly(Index: Integer; const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
  protected
    procedure Loaded; override;
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    property Columns: Integer read FColumns write SetColumns default 1;
    property Items: TStrings read FItems write SetItems;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF DELPHI4_LVL}
    procedure FlipChildren(AllLevels: Boolean); override;
    {$ENDIF}
    procedure PushKey(var Key: Char);
    procedure PushKeyDown(var Key: Word; Shift: TShiftState);
    property Checked[Index: Integer]: Boolean read GetChecked write SetChecked;
    property ReadOnly[Index: Integer]: Boolean read GetReadOnly write SetReadOnly;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property CheckColor: TColor read FCheckColor write SetCheckColor default clBlack;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis;
    property Images: TImageList read FImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clSilver;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property OnIsEnabled: TEnabledEvent read FOnIsEnabled write FOnIsEnabled;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeCheckGroup = class(TCustomAdvOfficeCheckGroup)
  private
  protected
  public
  published
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    {$ENDIF}
    property Caption;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Items;
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
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    {$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property OnStartDrag;
  end;




implementation
uses
  ShellApi, CommCtrl, Math
{$IFDEF DELPHI4_LVL}
  ,Imglist
{$ENDIF}
  ;

{$I HTMLENGO.PAS}


const
  BW = 12;

{$IFNDEF DELPHI4_LVL}
function Min(a,b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;
{$ENDIF}

{$IFDEF DELPHI4_LVL}
{$IFNDEF TMSDOTNET}
function GetFileVersion(FileName:string): Integer;
var
  FileHandle:dword;
  l: Integer;
  pvs: PVSFixedFileInfo;
  lptr: uint;
  querybuf: array[0..255] of char;
  buf: PChar;
begin
  Result := -1;

  StrPCopy(querybuf,FileName);
  l := GetFileVersionInfoSize(querybuf,FileHandle);
  if (l>0) then
  begin
    GetMem(buf,l);
    GetFileVersionInfo(querybuf,FileHandle,l,buf);
    if VerQueryValue(buf,'\',Pointer(pvs),lptr) then
    begin
      if (pvs^.dwSignature = $FEEF04BD) then
      begin
        Result := pvs^.dwFileVersionMS;
      end;
    end;
    FreeMem(buf);
  end;
end;
{$ENDIF}
{$ENDIF}


function DoThemeDrawing: Boolean;
var
  VerInfo: TOSVersioninfo;
  FIsWinXP,FIsComCtl6: boolean;
  i: integer;
begin
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}

  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  FIsComCtl6 := (i > 5);

  Result := FIsComCtl6 and FIsWinXP;
end;

{ TCustomHTMLCheckBox }

constructor TCustomAdvOfficeCheckBox.Create(AOwner: TComponent);
var
  VerInfo: TOSVersioninfo;

begin
  inherited Create(AOwner);
  Width := 120;
  Height := 20;
  FUrlColor := clBlue;
  FBtnVAlign := tlTop;
  FImageCache := THTMLPictureCache.Create;
  FCaption := self.ClassName;
  FShadowOffset := 1;
  FShadowColor := clGray;

  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}

  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  ControlStyle := ControlStyle - [csClickEvents];
  FReadOnly := False;

  {$IFNDEF TMSDOTNET}
  FBkgBmp := TBitmap.Create;
  FBkgCache := false;
  FTransparentCaching := false;
  {$ENDIF}
  FDrawBkg := true;
end;

function TCustomAdvOfficeCheckBox.IsAnchor(x,y:integer):string;
var
  r,hr: TRect;
  XSize,YSize,HyperLinks,MouseLink: Integer;
  s:string;
  Anchor, Stripped, FocusAnchor:string;
begin
  r := Clientrect;
  s := Caption;
  Anchor:='';

  r.left := r.left + BW + 5;
  r.top := r.top + 4;

  Result := '';

  if HTMLDrawEx(Canvas,s,r,FImages,x,y,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
                clNone,clNone,FShadowColor,Anchor,Stripped,FocusAnchor,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0) then
    Result := Anchor;
end;

{$IFNDEF TMSDOTNET}

procedure TCustomAdvOfficeCheckBox.DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then
      Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);

    Parent.Perform(WM_ERASEBKGND, Integer(DC), Integer(0));
    Parent.Perform(WM_PAINT, Integer(DC), Integer(0));
    RestoreDC(DC, SaveIndex);
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  FBkgCache := false;
  Repaint;
end;
{$ENDIF}

procedure TCustomAdvOfficeCheckBox.Paint;
var
  BL,BT:Integer;
  R, hr: TRect;
  a,s,fa,text: string;
  xsize,ysize: Integer;
  bmp: TBitmap;
  ExtraBW,HyperLinks,MouseLink: Integer;

begin
  Canvas.Font := Font;

  BT := 4;

  begin
    if FTransparentCaching then
    begin
      if FBkgCache then
      begin

        Self.Canvas.Draw(0,0,FBkgBmp)
      end
      else
      begin
        FBkgBmp.Width := self.Width;
        FBkgBmp.Height := self.Height;
        DrawParentImage(Self, FBkgBmp.Canvas);
        Self.Canvas.Draw(0,0,FBkgBmp);
        FBkgCache := true;
      end;
    end
    else
    begin
      if FDrawBkg then
        DrawParentImage(Self, self.Canvas);
    end;


  with Canvas do
  begin
    Text := Caption;

      begin
        ExtraBW := 4;
        bmp := TBitmap.Create;
        if state = cbChecked then
        begin
          if Down then
            bmp.LoadFromResourceName(hinstance,'TMSOFCCD')
          else
            if FHot then
              bmp.LoadFromResourceName(hinstance,'TMSOFCCH')
            else
              bmp.LoadFromResourceName(hinstance,'TMSOFCC');

        end
        else
        begin
          if Down then
            bmp.LoadFromResourceName(hinstance,'TMSOFCUD')
          else
            if FHot then
              bmp.LoadFromResourceName(hinstance,'TMSOFCUH')
            else
              bmp.LoadFromResourceName(hinstance,'TMSOFCU');

        end;

        bmp.Transparent:=true;
        bmp.TransparentMode := tmAuto;

        case fBtnVAlign of
        tlTop: BT := 4;
      	tlCenter: BT := (ClientRect.Bottom-ClientRect.Top) div 2 - (bmp.Height div 2);
        tlBottom: BT := ClientRect.Bottom - bmp.Height;
        end;

        if fAlignment = taRightJustify then
          BL := ClientRect.Right - bmp.Width - 1
        else
     	  BL := 0;
        Canvas.Draw(BL,BT,bmp);
        bmp.free;
      end;

    end;

    R := GetClientRect;

    if FAlignment = taRightJustify then
    begin
      r.Left := 0;
      r.Right := r.Right - BW - ExtraBW;
    end
    else																																	
      r.left := r.left + BW + ExtraBW;

    r.top := r.top + 4;

    if not Enabled then
    begin
      OffsetRect(r,1,1);
      Canvas.Font.Color := clWhite;
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clWhite,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);

      Canvas.Font.Color := clGray;
      Offsetrect(r,-1,-1);

      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clGray,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
    end
    else
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);

    if FFocused then
    begin
      r.right := r.left + xsize + 3;
      r.bottom := r.top + ysize + 1;
      DrawFocusRect(Canvas.Handle,R);
    end;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetDown(Value:Boolean);
begin
  if FDown <> Value then
  begin
    FDown := Value;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetState(Value:TCheckBoxState);
var
  r: TRect;
begin
  if FState <> Value then
  begin
    FState := Value;
    r := GetClientRect;
    case Alignment of
    taLeftJustify: r.Right := 20;
    taRightJustify: r.Left := r.Right - 20;
    end;
    {$IFNDEF TMSDOTNET}
    InvalidateRect(self.Handle,@r,True);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateRect(self.Handle,r,True);
    {$ENDIF}
  end;
end;

function TCustomAdvOfficeCheckBox.GetChecked: Boolean;
begin
  Result := State = cbChecked;
end;

procedure TCustomAdvOfficeCheckBox.SetChecked(Value:Boolean);
begin
  if Value then
    State := cbChecked
  else
    State := cbUnchecked;

  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetCheckColor(Value:TColor);
begin
  FCheckColor := Value;
  Paint;
end;

procedure TCustomAdvOfficeCheckBox.DoEnter;
var
  R: TRect;
begin
  inherited DoEnter;
  FFocused := True;

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @R, true);
end;

procedure TCustomAdvOfficeCheckBox.DoExit;

begin
  inherited DoExit;
  FFocused := False;

  if not FDrawBkg then
    FFocused := true;
  Repaint;
  FFocused := false;
end;

procedure TCustomAdvOfficeCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
  R: TRect;
begin
  Anchor := '';

  if FFocused then
  begin
    Anchor := IsAnchor(X,Y);

    if Anchor <> '' then
    begin
      if (Pos('://',Anchor) > 0) or (Pos('mailto:',anchor) > 0) then
        {$IFNDEF TMSDOTNET}
        Shellexecute(0,'open',pchar(anchor),nil,nil,SW_NORMAL)
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        Shellexecute(0,'open',anchor,'','',SW_NORMAL)
        {$ENDIF}
      else
      begin
        if Assigned(FAnchorClick) then
          FAnchorClick(self,anchor);
      end;
    end;
  end
  else
  begin
    SetFocus;
    FFocused := True;
  end;

  if Anchor = '' then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    MouseCapture := True;
    Down := True;
  end;

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(Self.Handle,@R, true);
end;

procedure TCustomAdvOfficeCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
var
  R: TRect;                                  
begin
  MouseCapture := False;

  Down := False;

  if (X >= 0) and (X<=Width) and (Y>=0) and (Y<=Height) and FFocused then
  begin
    ClicksDisabled := True;
    Toggle;
    ClicksDisabled := False;
    Click;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(Self.Handle,@R, true);
end;

procedure TCustomAdvOfficeCheckBox.MouseMove(Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
begin
  if MouseCapture then
     Down:=(X>=0) and (X<=Width) and (Y>=0) and (Y<=Height);

  if fFocused then
    Anchor := IsAnchor(x,y)
  else
    Anchor := '';

  if Anchor <> '' then
  begin
    if (self.Cursor = crDefault) or (FAnchor <> Anchor) then
    begin
      FAnchor := Anchor;
      self.Cursor := crHandPoint;
      if Assigned(FAnchorEnter) then
        FAnchorEnter(self,Anchor);
    end;
  end
  else
  begin
    if self.Cursor = crHandPoint then
    begin
      self.Cursor := FOldCursor;
      if Assigned(FAnchorExit) then
        FAnchorExit(self,Anchor);
    end;
  end;

  inherited MouseMove(Shift,X,Y);
end;

procedure TCustomAdvOfficeCheckBox.KeyDown(var Key:Word;Shift:TShiftSTate);
begin
  if (Key=vk_return) and (fReturnIsTab) then
  begin
    Key := vk_tab;
    PostMessage(self.Handle,wm_keydown,VK_TAB,0);
  end;

  if Key = vk_Space then
    Down := True;
    
  inherited KeyDown(Key,Shift);
end;

procedure TCustomAdvOfficeCheckBox.KeyUp(var Key:Word;Shift:TShiftSTate);
begin
  if Key = vk_Space then
  begin
    Down := False;
    Toggle;
    Click;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetURLColor(const Value: TColor);
begin
  if FURLColor <> Value then
  begin
    FURLColor := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages:=nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeCheckBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetButtonVertAlign(const Value: TTextLayout);
begin
  if Value <> FBtnVAlign then
  begin
    FBtnVAlign := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetAlignment(const Value: TLeftRight);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

destructor TCustomAdvOfficeCheckBox.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  FBkgBmp.Free;
  {$ENDIF}
  FImageCache.Free;
  inherited;
end;

procedure TCustomAdvOfficeCheckBox.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then
  begin
    FEllipsis := Value;
    Invalidate
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetCaption(Value: string);
begin
  {$IFNDEF TMSDOTNET}
  SetWindowText(Handle,pchar(Value));
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  SetWindowText(Handle,Value);
  {$ENDIF}
  FCaption := Value;
  Invalidate;
end;


procedure TCustomAdvOfficeCheckBox.Toggle;
begin
  if not FReadOnly then
    Checked := not Checked;
end;

procedure TCustomAdvOfficeCheckBox.WMEraseBkGnd(var Message: TMessage);
begin
  Message.Result := 1
end;

procedure TCustomAdvOfficeCheckBox.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, FCaption) and CanFocus then
    begin
      Toggle;
      if TabStop then SetFocus;
      Result := 1;
    end else
      inherited;
end;

procedure TCustomAdvOfficeCheckBox.SetContainer(const Value: TPictureContainer);
begin
  FContainer := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetShadowOffset(const Value: Integer);
begin
  if FShadowOffset <> Value then
  begin
    FShadowOffset := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.CMMouseEnter(var Message: TMessage);
var
  R: TRect;
begin
  FHot := True;
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(handle, @R, true);
end;

procedure TCustomAdvOfficeCheckBox.CMMouseLeave(var Message: TMessage);
var
  R: TRect;
begin
  FHot := False;
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(handle, @R, true);
end;

procedure TCustomAdvOfficeCheckBox.Loaded;
begin
  inherited;
  FOldCursor := Cursor;
end;

function TCustomAdvOfficeCheckBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeCheckBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeCheckBox.SetVersion(const Value: string);
begin

end;

{ THTMLRadioButton }

constructor TAdvOfficeRadioButton.Create(AOwner: TComponent);
var
  VerInfo: TOSVersionInfo;

begin
  inherited Create(AOwner);
  Width := 135;
  Height := 20;
  FURLColor := clBlue;
  FBtnVAlign := tlTop;
  FImageCache := THTMLPictureCache.Create;
  FCaption := self.ClassName;
  FShadowOffset := 1;
  FShadowColor := clGray;
  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}
  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  {$IFNDEF TMSDOTNET}
  FBkgBmp := TBitmap.Create;
  FBkgCache := false;
  FTransparentCaching := false;
  {$ENDIF}
  FDrawBkg := true;
end;

function TAdvOfficeRadioButton.IsAnchor(x,y:integer):string;
var
  r,hr: TRect;
  XSize,YSize,HyperLinks,MouseLink: Integer;
  s: string;
  Anchor,Stripped,FocusAnchor: string;
begin
  r := Clientrect;
  s := Caption;
  Anchor := '';

  r.left := r.left + BW + 5;
  r.top := r.top + 4;

  Result := '';

  if HTMLDrawEx(Canvas,s,r,FImages,x,y,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
                clNone,clNone,FShadowColor,Anchor,Stripped,FocusAnchor,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0) then
    Result := Anchor;
end;

procedure TAdvOfficeRadioButton.DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then
      Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(WM_ERASEBKGND, Integer(DC), Integer(0));
    Parent.Perform(WM_PAINT, Integer(DC), Integer(0));
    RestoreDC(DC, SaveIndex);
  end;
end;


procedure TAdvOfficeRadioButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  begin
    FBkgCache := false;
    Repaint;
  end;
end;

procedure TAdvOfficeRadioButton.Paint;
var
  BL,BT,BR:Integer;
  R,hr: TRect;
  a,s,fa,text: string;
  XSize,YSize,HyperLinks,MouseLink: Integer;
  bmp: TBitmap;

begin
  Canvas.Font := Font;
  Text := Caption;

    if FTransparentCaching then
    begin
      if FBkgCache then
      begin
        Self.Canvas.Draw(0,0,FBkgBmp)
      end
      else
      begin
        FBkgBmp.Width := self.Width;
        FBkgBmp.Height := self.Height;
        FBkgBmp.PixelFormat := pf32bit;
        DrawParentImage(Self, FBkgBmp.Canvas);
        Self.Canvas.Draw(0,0,FBkgBmp);
        FBkgCache := true;
      end;
    end
    else
    begin
      if DrawBkg then
        DrawParentImage(Self, self.Canvas);
    end;

  with Canvas do
  begin
    BT := 4;

      begin
        BR := 13;
        bmp := TBitmap.Create;
        if (Checked) then
        begin
          if Down then
            bmp.LoadFromResourceName(hinstance,'TMSOFRCD')
          else
            if FHot then
              bmp.LoadFromResourceName(hinstance,'TMSOFRCH')
            else
              bmp.LoadFromResourceName(hinstance,'TMSOFRC');

        end
        else
        begin
          if Down then
            bmp.LoadFromResourceName(hinstance,'TMSOFRUD')
          else
            if FHot then
              bmp.LoadFromResourceName(hinstance,'TMSOFRUH')
            else
              bmp.LoadFromResourceName(hinstance,'TMSOFRU');
        end;

        bmp.Transparent:=true;
        bmp.TransparentMode :=tmAuto;

        case FBtnVAlign of
        tlTop: BT := 4;
        tlCenter: BT := (ClientRect.Bottom-ClientRect.Top) div 2 - (bmp.Height div 2);
        tlBottom: BT := ClientRect.Bottom - bmp.Height - 2;
        end;

        if fAlignment = taRightJustify then
          BL := ClientRect.Right - bmp.Width - 1
        else
          BL := 0;
        Canvas.Draw(BL,BT,bmp);
        bmp.Free;
      end;

      r := GetClientRect;
      if FAlignment = taRightJustify then
      begin
        r.Left := 0;
        r.Right := r.Right - BR - 5;
      end
      else
        r.Left := r.Left + BR + 5;

      r.Top := r.Top + 4;

      if not Enabled then
      begin
        OffsetRect(R,1,1);
        Canvas.Font.Color := clWhite;
        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clGray,
          clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
        Canvas.Font.Color := clGray;
        Offsetrect(R,-1,-1);
        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clWhite,
          clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
      end
      else
      begin
        Canvas.Font.Color := Font.Color;
        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
                clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
      end;

      if FFocused then
      begin
        r.Right := r.Left + xsize + 3;
        r.Bottom := r.Top + ysize + 1;
        WinProcs.DrawFocusRect(Canvas.Handle, R);
      end;

    end;
end;

procedure TAdvOfficeRadioButton.SetURLColor(const Value: TColor);
begin
  FURLColor := Value;
  Invalidate;
end;


procedure TAdvOfficeRadioButton.SetDown(Value:Boolean);
begin
  if FDown<>Value then
  begin
    FDown := Value;
  end;
end;


procedure TAdvOfficeRadioButton.TurnSiblingsOff;
var
  i:Integer;
  Sibling: TAdvOfficeRadioButton;

begin
  if (Parent <> nil) then
  for i:=0 to Parent.ControlCount-1 do
    if Parent.Controls[i] is TAdvOfficeRadioButton then
    begin
      Sibling := TAdvOfficeRadioButton(Parent.Controls[i]);
      if (Sibling <> Self) and
         (Sibling.GroupIndex = GroupIndex) then
          Sibling.SetChecked(False);
    end;
end;

procedure TAdvOfficeRadioButton.SetChecked(Value: Boolean);
begin
  if FChecked <> Value then
  begin
    TabStop := Value;
    FChecked := Value;
    if Value then
    begin
      TurnSiblingsOff;
      //if not FClicksDisabled then
      DoClick;
    end;
    Invalidate;
  end;
end;


procedure TAdvOfficeRadioButton.SetCheckColor(Value:TColor);
begin
  FCheckColor := Value;
  Invalidate;
end;

procedure TAdvOfficeRadioButton.DoClick;
begin
  if Assigned(OnClick) then
    OnClick(Self);
end;

procedure TAdvOfficeRadioButton.DoEnter;
var
  R: TRect;
begin
  inherited DoEnter;
  FFocused := True;
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @R, true);
end;

procedure TAdvOfficeRadioButton.DoExit;
begin
  inherited DoExit;

  FFocused := False;

  if not FDrawBkg then
    FFocused := true;
    
  Repaint;

  FFocused := false;
end;

procedure TAdvOfficeRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Anchor:string;
  R: TRect;
begin
  Anchor := '';

  if FFocused then
  begin
    Anchor := IsAnchor(X,Y);
    if Anchor <> '' then
    begin
      if (Pos('://',Anchor)>0) or (Pos('mailto:',Anchor)>0) then
        {$IFNDEF TMSDOTNET}
        ShellExecute(0,'open',PChar(Anchor),nil,nil,SW_NORMAL)
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        ShellExecute(0,'open',Anchor,'','',SW_NORMAL)
        {$ENDIF}
      else
      begin
        if Assigned(FAnchorClick) then
          FAnchorClick(self,anchor);
      end;
    end;
  end
  else
  begin
    SetFocus;
    FFocused := True;
  end;

  if Anchor = '' then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    MouseCapture := True;
    Down := True;
  end;

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @r, true);
end;

procedure TAdvOfficeRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
var
  R: TRect;
begin
  MouseCapture := False;
  Down := False;

  if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) and not Checked then
  begin
    Checked := true;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @r, true);
end;

procedure TAdvOfficeRadioButton.MouseMove(Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
begin
  if MouseCapture then
    Down := (X>=0) and (X<=Width) and (Y>=0) and (Y<=Height);

  if FFocused then
    Anchor := IsAnchor(x,y)
  else
    Anchor := '';

  if Anchor <> '' then
  begin
    if (self.Cursor = crDefault) or (fAnchor<>Anchor) then
    begin
      FAnchor := Anchor;
      self.Cursor := crHandPoint;
      if Assigned(FAnchorEnter) then
        FAnchorEnter(self,anchor);
    end;
  end
  else
  begin
    if self.Cursor = crHandPoint then
    begin
      self.Cursor := FOldCursor;
      if Assigned(FAnchorExit) then
        FAnchorExit(self,anchor);
    end;
  end;

  inherited MouseMove(Shift,X,Y);
end;

procedure TAdvOfficeRadioButton.KeyDown(var Key:Word;Shift:TShiftSTate);
begin
  if (Key=vk_return) and (fReturnIsTab) then
  begin
    Key := vk_tab;
    PostMessage(self.Handle,wm_keydown,VK_TAB,0);
  end;

  if Key = vk_Space then
    Down := True;
  inherited KeyDown(Key,Shift);
end;

procedure TAdvOfficeRadioButton.KeyUp(var Key:Word;Shift:TShiftSTate);
begin
  if Key = vk_Space then
  begin
     Down := False;
    if not Checked then Checked := True;
  end;
end;

procedure TAdvOfficeRadioButton.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure TAdvOfficeRadioButton.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;
  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages := nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TAdvOfficeRadioButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TAdvOfficeRadioButton.SetButtonVertAlign(const Value: TTextLayout);
begin
  if Value <> FBtnVAlign then
  begin
    FBtnVAlign := Value;
    Invalidate;
  end;
end;

procedure TAdvOfficeRadioButton.SetAlignment(const Value: TLeftRight);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

destructor TAdvOfficeRadioButton.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  FBkgBmp.Free;
  {$ENDIF}
  FImageCache.Free;
  inherited;
end;

procedure TAdvOfficeRadioButton.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then
  begin
    FEllipsis := Value;
    Invalidate;
  end;
end;

procedure TAdvOfficeRadioButton.SetCaption(const Value: string);
begin
  inherited Caption := Value;
  FCaption := Value;
  Invalidate;
end;

procedure TAdvOfficeRadioButton.Click;
begin
//  inherited;
end;

procedure TAdvOfficeRadioButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, FCaption) and CanFocus then
    begin
      Checked := True;
      if TabStop then SetFocus;
      Result := 1;
    end else
      inherited;

end;

procedure TAdvOfficeRadioButton.SetContainer(const Value: TPictureContainer);
begin
  FContainer := Value;
  Invalidate;
end;

procedure TAdvOfficeRadioButton.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TAdvOfficeRadioButton.SetShadowOffset(const Value: Integer);
begin
  if FShadowOffset <> Value then
  begin
    FShadowOffset := Value;
    Invalidate;
  end;
end;

procedure TAdvOfficeRadioButton.CMMouseEnter(var Message: TMessage);
var
  R: TRect;
begin
  FHot := True;
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle,@R,true);;
end;

procedure TAdvOfficeRadioButton.CMMouseLeave(var Message: TMessage);
var
  R: TRect;
begin
  FHot := False;
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle,@R,true);;
end;


procedure TAdvOfficeRadioButton.WMEraseBkGnd(var Message: TMessage);
begin
  Message.Result := 1
end;

procedure TAdvOfficeRadioButton.WMLButtonDown(var Message:TWMLButtonDown);
begin
  FClicksDisabled := True;
  SetFocus;
  FClicksDisabled := False;
  inherited;
end;

procedure TAdvOfficeRadioButton.Loaded;
begin
  inherited;
  FOldCursor := Cursor;
end;

function TAdvOfficeRadioButton.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvOfficeRadioButton.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAdvOfficeRadioButton.SetVersion(const Value: string);
begin

end;


{ TGroupButton }

type
  TGroupButton = class(TAdvOfficeRadioButton)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(RadioGroup: TCustomAdvOfficeRadioGroup);
    destructor Destroy; override;
  end;

constructor TGroupButton.InternalCreate(RadioGroup: TCustomAdvOfficeRadioGroup);
begin
  inherited Create(RadioGroup);
  RadioGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := RadioGroup.Enabled;
  ParentShowHint := False;
  OnClick := RadioGroup.ButtonClick;
  Parent := RadioGroup;
end;

destructor TGroupButton.Destroy;
begin
  TCustomAdvOfficeRadioGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TGroupButton.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TCustomAdvOfficeRadioGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;

    FInClick := False;
  end;
end;

procedure TGroupButton.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TCustomAdvOfficeRadioGroup(Parent).PushKey(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TCustomAdvOfficeRadioGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TGroupButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TCustomAdvOfficeRadioGroup(Parent).PushKeyDown(Key, Shift);
end;

{ TCustomAdvOfficeRadioGroup }

constructor TCustomAdvOfficeRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FItemIndex := -1;
  FColumns := 1;
  FAlignment := taLeftJustify;
  FCheckColor := clBlack;
  FBtnVAlign := tlTop;
  ShadowOffset := 1;
  ShadowColor := clSilver;
end;

destructor TCustomAdvOfficeRadioGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TCustomAdvOfficeRadioGroup.PushKey(var Key: Char);
begin
  KeyPress(Key);
end;

procedure TCustomAdvOfficeRadioGroup.PushKeyDown(var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key,Shift);
end;

procedure TCustomAdvOfficeRadioGroup.FlipChildren(AllLevels: Boolean);
begin
  { The radio buttons are flipped using BiDiMode }
end;


procedure TCustomAdvOfficeRadioGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
  RadioEnable: Boolean;

begin
 
  if (csLoading in ComponentState) then
    Exit;

  if not HandleAllocated then
    Exit;


  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;

    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TGroupButton(FButtons[I]) do
        begin
          {$IFDEF DELPHI4_LVL}
          BiDiMode := Self.BiDiMode;
          {$ENDIF}

          DrawBkg := false;
          Alignment := Self.Alignment;
          ButtonVertAlign := Self.ButtonVertAlign;
          CheckColor := Self.CheckColor;
          Images := Self.Images;
          PictureContainer := Self.PictureContainer;
          Ellipsis := Self.Ellipsis;
          ShadowOffset := Self.ShadowOffset;
          ShadowColor := Self.ShadowColor;

          RadioEnable := Self.Enabled;
          if Assigned(FOnIsEnabled) then
            FOnIsEnabled(Self,I,RadioEnable);

          Enabled := RadioEnable;

          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          {$IFDEF DELPHI4_LVL}
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          {$ENDIF}

          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);

        //  Left := ALeft;
        //  Top := (I mod ButtonsPerCol) * ButtonHeight + TopMargin;
          Visible := True;

        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    FItemIndex := FButtons.IndexOf(Sender);
    Changed;
    Click;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    if FItemIndex >= FItems.Count then FItemIndex := FItems.Count - 1;
    UpdateButtons;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.Loaded;
begin
  inherited Loaded;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do TGroupButton.InternalCreate(Self);
  while FButtons.Count > Value do TGroupButton(FButtons.Last).Free;
end;

procedure TCustomAdvOfficeRadioGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.SetItemIndex(Value: Integer);
begin
  if FReading then FItemIndex := Value else
  begin
    if Value < -1 then Value := -1;
    if Value >= FButtons.Count then Value := FButtons.Count - 1;
    if FItemIndex <> Value then
    begin
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := False;
      FItemIndex := Value;
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := True;
    end;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomAdvOfficeRadioGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Caption := FItems[I];
  if FItemIndex >= 0 then
  begin
    FUpdating := True;
    TGroupButton(FButtons[FItemIndex]).Checked := True;
    FUpdating := False;
  end;
  ArrangeButtons;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Enabled := Enabled;
end;

procedure TCustomAdvOfficeRadioGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TCustomAdvOfficeRadioGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TCustomAdvOfficeRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TCustomAdvOfficeRadioGroup.SetCheckColor(const Value: TColor);
begin
  FCheckColor := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetButtonVertAlign(
  const Value: TTextLayout);
begin
  fBtnVAlign := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetContainer(
  const Value: TPictureContainer);
begin
  FContainer := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetImages(const Value: TImageList);
begin
  FImages := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages:=nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeRadioGroup.SetEllipsis(const Value: Boolean);
begin
  FEllipsis := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetShadowColor(const Value: TColor);
begin
  FShadowColor := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetShadowOffset(const Value: Integer);
begin
  FShadowOffset := Value;
  ArrangeButtons;
end;

function TCustomAdvOfficeRadioGroup.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeRadioGroup.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeRadioGroup.SetVersion(const Value: string);
begin

end;


{ TGroupCheck }

type
  TGroupCheck = class(TAdvOfficeCheckBox)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(CheckGroup: TCustomAdvOfficeCheckGroup);
    destructor Destroy; override;
  end;

constructor TGroupCheck.InternalCreate(CheckGroup: TCustomAdvOfficeCheckGroup);
begin
  inherited Create(CheckGroup);
  CheckGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := CheckGroup.Enabled;
  ParentShowHint := False;
  OnClick := CheckGroup.ButtonClick;
  Parent := CheckGroup;
end;

destructor TGroupCheck.Destroy;
begin
  TCustomAdvOfficeCheckGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TGroupCheck.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TCustomAdvOfficeCheckGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;
    FInClick := False;
  end;
end;

procedure TGroupCheck.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TCustomAdvOfficeCheckGroup(Parent).PushKey(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TCustomAdvOfficeCheckGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TGroupCheck.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TCustomAdvOfficeCheckGroup(Parent).PushKeyDown(Key, Shift);
end;


{ TCustomAdvOfficeCheckGroup }

constructor TCustomAdvOfficeCheckGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FColumns := 1;
  FAlignment := taLeftJustify;
  FCheckColor := clBlack;
  FBtnVAlign := tlTop;
  ShadowOffset := 1;
  ShadowColor := clSilver;
end;

destructor TCustomAdvOfficeCheckGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TCustomAdvOfficeCheckGroup.PushKey(var Key: Char);
begin
  KeyPress(Key);
end;

procedure TCustomAdvOfficeCheckGroup.PushKeyDown(var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key,Shift);
end;

{$IFDEF DELPHI4_LVL}
procedure TCustomAdvOfficeCheckGroup.FlipChildren(AllLevels: Boolean);
begin
  { The radio buttons are flipped using BiDiMode }
end;
{$ENDIF}

procedure TCustomAdvOfficeCheckGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
  RadioEnable: Boolean;

begin
  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;
    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TGroupCheck(FButtons[I]) do
        begin
          {$IFDEF DELPHI4_LVL}
          BiDiMode := Self.BiDiMode;
          {$ENDIF}

          DrawBkg := false;
          Alignment := Self.Alignment;
          ButtonVertAlign := Self.ButtonVertAlign;
          CheckColor := Self.CheckColor;
          Images := Self.Images;
          PictureContainer := Self.PictureContainer;
          Ellipsis := Self.Ellipsis;
          ShadowOffset := Self.ShadowOffset;
          ShadowColor := Self.ShadowColor;

          RadioEnable := self.Enabled;
          if Assigned(FOnIsEnabled) then
            FOnIsEnabled(Self,I,RadioEnable);

          Enabled := RadioEnable;

          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          {$IFDEF DELPHI4_LVL}
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          {$ENDIF}  
          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);
          Visible := True;

        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    Changed;
    Click;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    UpdateButtons;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.Loaded;
begin
  inherited Loaded;
  ArrangeButtons;

end;

procedure TCustomAdvOfficeCheckGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do TGroupCheck.InternalCreate(Self);
  while FButtons.Count > Value do TGroupCheck(FButtons.Last).Free;
end;

procedure TCustomAdvOfficeCheckGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomAdvOfficeCheckGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TGroupCheck(FButtons[I]).Caption := FItems[I];

  ArrangeButtons;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TGroupCheck(FButtons[I]).Enabled := Enabled;
end;

procedure TCustomAdvOfficeCheckGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TCustomAdvOfficeCheckGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TCustomAdvOfficeCheckGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TCustomAdvOfficeCheckGroup.SetCheckColor(const Value: TColor);
begin
  FCheckColor := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetButtonVertAlign(
  const Value: TTextLayout);
begin
  fBtnVAlign := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetContainer(
  const Value: TPictureContainer);
begin
  FContainer := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetImages(const Value: TImageList);
begin
  FImages := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages:=nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeCheckGroup.SetEllipsis(const Value: Boolean);
begin
  FEllipsis := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetShadowColor(const Value: TColor);
begin
  FShadowColor := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetShadowOffset(const Value: Integer);
begin
  FShadowOffset := Value;
  ArrangeButtons;
end;


function TCustomAdvOfficeCheckGroup.GetChecked(Index: Integer): Boolean;
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    Result := TGroupCheck(FButtons[Index]).Checked
  else
    raise Exception.Create('Invalid checkbox index');
end;

procedure TCustomAdvOfficeCheckGroup.SetChecked(Index: Integer;
  const Value: Boolean);
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    TGroupCheck(FButtons[Index]).Checked := Value;
end;

function TCustomAdvOfficeCheckGroup.GetReadOnly(Index: Integer): Boolean;
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    Result := not TGroupCheck(FButtons[Index]).Enabled
  else
    raise Exception.Create('Invalid checkbox index');
end;

procedure TCustomAdvOfficeCheckGroup.SetReadOnly(Index: Integer;
  const Value: Boolean);
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    TGroupCheck(FButtons[Index]).Enabled := not Value;
end;


function TCustomAdvOfficeCheckGroup.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeCheckGroup.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeCheckGroup.SetVersion(const Value: string);
begin

end;

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
