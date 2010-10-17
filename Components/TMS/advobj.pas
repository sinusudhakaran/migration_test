{*************************************************************************}
{ Arrow col and row move indicators support file                          }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{            copyright © 1996-2008                                        }
{            Email : info@tmssoftware.com                                 }
{            Web : http://www.tmssoftware.com                             }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvObj;

{$I TMSDEFS.INC}

interface

uses
  Windows, StdCtrls, Controls, Graphics, ExtCtrls, Dialogs, Classes, Messages,
  SysUtils, AdvUtil, AsgHTMLE, Buttons, Menus, Forms, ImgList
  {$IFNDEF TMSDOTNET}
  , AdvXPVS
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , WinUtils, uxTheme, System.Text, System.Runtime.InteropServices
  {$ENDIF}
  ;

type
  TArrowDirection = (arrUp,arrDown,arrLeft,arrRight);

  TAdvGridButtonStyle = (tasButton, tasCheck);

  TAdvGridButton = class;


  TImageChangeEvent = procedure (Sender:TObject;Acol,Arow: Integer) of object;

  TArrowWindow = class(TPanel)
  private
    Dir: TArrowDirection;
    Arrow: array[0..8] of TPoint;
  public
    constructor Init(AOwner: TComponent;direction:TArrowDirection);
    procedure Loaded; override;
  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  TPopupButton = class(TCustomControl)
  private
    FCaption: string;
    FImages: TCustomImageList;
    FFlat: boolean;
    FGradTo: TColor;
    FGradFrom: TColor;
    FGradMirrorTo: TColor;
    FGradMirrorFrom: TColor;
  private
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure CreateWnd; override;
    property Images: TCustomImageList read FImages write FImages;
  published
    property Caption:string read FCaption write FCaption;
    property Flat: boolean read FFlat write FFlat;
    property GradFrom: TColor read FGradFrom write FGradFrom;
    property GradTo: TColor read FGradTo write FGradTo;
    property GradMirrorFrom: TColor read FGradMirrorFrom write FGradMirrorFrom;
    property GradMirrorTo: TColor read FGradMirrorTo write FGradMirrorTo;
  end;

  TIntList = class(TList)
  private
    FOnChange: TImageChangeEvent;
    FCol,FRow: Integer;
    procedure SetInteger(Index: Integer; Value: Integer);
    function GetInteger(Index: Integer):Integer;
    function GetStrValue: string;
    procedure SetStrValue(const Value: string);
  public
    constructor Create(Col,Row: Integer);
    procedure DeleteValue(Value: Integer);
    function HasValue(Value: Integer): Boolean;
    property Items[index: Integer]: Integer read GetInteger write SetInteger; default;
    procedure Add(Value: Integer);
    procedure Insert(Index,Value: Integer);
    procedure Delete(Index: Integer);
    property StrValue: string read GetStrValue write SetStrValue;
    property OnChange: TImageChangeEvent read FOnChange write FOnChange;
  end;



  TSortIndexList = class(TIntList)
  private
    function GetSortColumns(i: Integer): Integer;
    function GetSortDirections(i: Integer): Boolean;
    procedure SetSortColumns(i: Integer; const Value: Integer);
    procedure SetSortDirections(i: Integer; const Value: Boolean);
  public
    procedure AddIndex(ColumnIndex: integer; Ascending:boolean);
    function FindIndex(ColumnIndex: integer):integer;
    procedure ToggleIndex(ColumnIndex: integer);
    property SortColumns[i: Integer]: Integer read GetSortColumns write SetSortColumns;
    property SortDirections[i: Integer]: Boolean read GetSortDirections write SetSortDirections;
  end;

  TControlItem = class(TObject)
  private
    FX: Integer;
    FY: Integer;
    FObject: TControl;
  public
    constructor Create(AX,AY: Integer; AObject: TControl);
    property X: integer read FX write FX;
    property Y: integer read FY write FY;
    property Control: TControl read FObject write FObject;
  end;

  TControlList = class(TList)
  private
    function GetControl(i: Integer): TControlItem;
  public
    procedure AddControl(X,Y: Integer; AObject: TControl);
    procedure RemoveControl(i: Integer);
    function ControlIndex(X,Y: Integer): Integer; 
    property Control[i: Integer]: TControlItem read GetControl;
    destructor Destroy; override;
    function HasHandle(Handle: THandle): Boolean; 
  end;

  TFilePicture = class(TPersistent)
  private
    FFilename: string;
    FWidth: Integer;
    FHeight: Integer;
    FPicture: TPicture;
    procedure SetFileName(const Value: string);
  public
    procedure DrawPicture(Canvas:TCanvas;r:TRect);
    procedure Assign(Source: TPersistent); override;
  published
    property Filename:string read FFileName write SetFileName;
    property Width:integer read FWidth;
    property Height:integer read FHeight;
  end;


  {$IFDEF DELPHI6_LVL}
  TAdvGridButtonActionLink = class(TControlActionLink)
  protected
    FClient: TAdvGridButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsCheckedLinked: Boolean; override;
    function IsGroupIndexLinked: Boolean; override;
    procedure SetGroupIndex(Value: Integer); override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetCaption(const Value: string); override;
  end;
  {$ENDIF}

  TAdvGridButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
    FGlyph: TBitmap;
    FDown: Boolean;
    FDragging: Boolean;
    FAllowAllUp: Boolean;
    FLayout: TButtonLayout;
    FSpacing: Integer;
    FTransparent: Boolean;
    FMargin: Integer;
    FFlat: Boolean;
    FMouseInControl: Boolean;
    FColorTo: TColor;
    FColorHot: TColor;
    FColorHotTo: TColor;
    FColorDown: TColor;
    FColorDownTo: TColor;
    FBorderColor: TColor;
    FBorderDownColor: TColor;
    FBorderHotColor: TColor;
    FGlyphDisabled: TBitmap;
    FGlyphHot: TBitmap;
    FGlyphDown: TBitmap;
    FGlyphShade: TBitmap;
    FShaded: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FColorChecked: TColor;
    FColorCheckedTo: TColor;
    FStyle: TAdvGridButtonStyle;
    FLook: Integer;
    FRounded: Boolean;
    FDropDownButton: Boolean;
    FAutoThemeAdapt: Boolean;
    FAutoXPStyle: Boolean;
    FOnDropDown: TNotifyEvent;
    FDropDownMenu: TPopupMenu;
    FShowCaption: Boolean;
    procedure GlyphChanged(Sender: TObject);
    procedure UpdateExclusive;
    procedure SetGlyph(Value: TBitmap);
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetMargin(Value: Integer);
    procedure UpdateTracking;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    {$IFNDEF TMSDOTNET}
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    {$ENDIF}
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetGlyphDisabled(const Value: TBitmap);
    procedure SetGlyphDown(const Value: TBitmap);
    procedure SetGlyphHot(const Value: TBitmap);
    procedure GenerateShade;
    procedure SetShaded(const Value: Boolean);
    procedure SetColorTo(const Value: TColor);
    procedure SetColorChecked(const Value: TColor);
    procedure SetColorCheckedTo(const Value: TColor);
    procedure SetStyle(const Value: TAdvGridButtonStyle);
    procedure SetRounded(const Value: Boolean);
    procedure SetDropDownButton(const Value: Boolean);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetBorderColor(const Value: TColor);
    procedure SetLook(const Value: Integer);
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
  protected
    FState: TButtonState;
    {$IFDEF DELPHI6_LVL}
    function GetActionLinkClass: TControlActionLinkClass; override;
    {$ENDIF}
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DrawButtonGlyph(Canvas: TCanvas; const GlyphPos: TPoint;
      State: TButtonState; Transparent: Boolean);
    procedure DrawButtonText(Canvas: TCanvas; const Caption: string;
      TextBounds: TRect; State: TButtonState; BiDiFlags: LongInt);
    function DrawButton(Canvas: TCanvas; const Client: TRect;
      const Offset: TPoint; const Caption: string; Layout: TButtonLayout;
      Margin, Spacing: Integer; State: TButtonState; Transparent: Boolean;
      BiDiFlags: LongInt): TRect;
    procedure CalcButtonLayout(Canvas: TCanvas; const Client: TRect;
      const Offset: TPoint; const Caption: string; Layout: TButtonLayout; Margin,
      Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect;
      BiDiFlags: LongInt);
    procedure Paint; override;
    property MouseInControl: Boolean read FMouseInControl;
    procedure WndProc(var Message: TMessage); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;    
    procedure ThemeAdapt;
    procedure SetAutoThemeAdapt(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    property Look: Integer read FLook write SetLook;
    {$IFDEF TMSDOTNET}
    procedure ButtonPressed(Group: Integer; Button: TAdvGridButton);
    {$ENDIF}
  published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property AutoThemeAdapt: Boolean read FAutoThemeAdapt write SetAutoThemeAdapt;
    property AutoXPStyle: Boolean read FAutoXPStyle write FAutoXPStyle;
    property BiDiMode;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clNone;
    property BorderDownColor: TColor read FBorderDownColor write FBorderDownColor default clNone;
    property BorderHotColor: TColor read FBorderHotColor write FBorderHotColor default clNone;
    property Color: TColor read GetColor write SetColor default clBtnFace;
    property ColorTo: TColor read FColorTo write SetColorTo default clNone;
    property ColorDown: TColor read FColorDown write FColorDown;
    property ColorDownTo: TColor read FColorDownTo write FColorDownTo default clNone;
    property ColorHot: TColor read FColorHot write FColorHot;
    property ColorHotTo: TColor read FColorHotTo write FColorHotTo default clNone;
    property ColorChecked: TColor read FColorChecked write SetColorChecked default clGray;
    property ColorCheckedTo: TColor read FColorCheckedTo write SetColorCheckedTo default clNone;
    property Constraints;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property DropDownButton: Boolean read FDropDownButton write SetDropDownButton default False;
    property DropDownMenu: TPopupMenu read FDropDownMenu write FDropDownMenu;
    property Caption;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default True;
    property Font;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GlyphHot: TBitmap read FGlyphHot write SetGlyphHot;
    property GlyphDown: TBitmap read FGlyphDown write SetGlyphDown;
    property GlyphDisabled: TBitmap read FGlyphDisabled write SetGlyphDisabled;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property Rounded: Boolean read FRounded write SetRounded default False;
    property Shaded: Boolean read FShaded write SetShaded default True;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Style: TAdvGridButtonStyle read FStyle write SetStyle default tasButton;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
  end;

  TFileStringList = class(TStringList)
  private
    fp: integer;
    cache: string;
    function GetEOF: boolean;
  public
    procedure Reset;
    procedure ReadLn(var s: string);
    procedure Write(s: string);
    procedure WriteLn(s: string);
    property Eof: boolean read GetEOF;
  end;


//procedure Register;


implementation

uses
  ActnList, ComObj
{$IFDEF TMSDOTNET}
  , Types
{$ENDIF}
  ;

const
  // theme changed notifier
  WM_THEMECHANGED = $031A;

type
  XPColorScheme = (xpNone, xpBlue, xpGreen, xpGray);

//procedure Register;
//begin
//  RegisterComponents('TMS Grids', [TAdvGridButton]);
//end;

{ TArrowWindow }

procedure TArrowWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP; // or WS_BORDER;
  end;
end;

procedure TArrowWindow.Loaded;
begin
  inherited;
end;


procedure TArrowWindow.CreateWnd;
var
  hrgn: THandle;

begin
  inherited;

  case Dir of
  arrDown:begin
         arrow[0] := point(3,0);
         arrow[1] := point(7,0);
         arrow[2] := point(7,4);
         arrow[3] := point(9,4);
         arrow[4] := point(5,8);
         arrow[5] := point(1,4);
         arrow[6] := point(3,4);
         end;
  arrUp:begin
         arrow[0] := point(5,0);
         arrow[1] := point(10,5);
         arrow[2] := point(7,5);
         arrow[3] := point(7,9);
         arrow[4] := point(3,9);
         arrow[5] := point(3,5);
         arrow[6] := point(0,5);
       end;
  arrLeft:begin
         arrow[0] := point(0,3);
         arrow[1] := point(0,7);
         arrow[2] := point(4,7);
         arrow[3] := point(4,10);
         arrow[4] := point(8,5);
         arrow[5] := point(4,0);
         arrow[6] := point(4,3);
         end;
  arrRight:begin
         arrow[0] := point(0,5);
         arrow[1] := point(4,10);
         arrow[2] := point(4,7);
         arrow[3] := point(8,7);
         arrow[4] := point(8,3);
         arrow[5] := point(4,3);
         arrow[6] := point(4,0);
         end;
  end;
  hrgn := CreatePolygonRgn(arrow,7,WINDING);
  SetWindowRgn(Handle,hrgn,True);
end;

procedure TArrowWindow.Paint;
begin
//  inherited;  // remove, is not working in Windows XP
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := Color;
  Canvas.Rectangle(ClientRect.Left,ClientRect.Top,ClientRect.Right,ClientRect.Bottom);
end;

constructor TArrowWindow.Init(AOwner: TComponent; Direction:TArrowDirection);
begin
  Dir := Direction;
  inherited Create(aOwner);
  Color := clLime;
  Parent := TWinControl(AOwner);
  Visible := False; 
end;

{ TIntList }

constructor TIntList.Create(Col,Row: Integer);
begin
  inherited Create;
  FCol := Col;
  FRow := Row;
end;

procedure TIntList.SetInteger(Index:Integer;Value:Integer);
begin
  {$IFDEF TMSDOTNET}
  inherited Items[Index] := TObject(Value);
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  inherited Items[Index] := Pointer(Value);
  {$ENDIF}

  if Assigned(OnChange) then
    OnChange(Self,FCol,FRow);
end;

function TIntList.GetInteger(Index: Integer): Integer;
begin
  Result := Integer(inherited Items[Index]);
end;

procedure TIntList.DeleteValue(Value: Integer);
var
  i: integer;
begin
  {$IFNDEF TMSDOTNET}
  i := IndexOf(Pointer(Value));
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  i := IndexOf(TObject(Value));
  {$ENDIF}

  if i <> -1 then
    Delete(i);
end;

function TIntList.HasValue(Value: Integer): Boolean;
begin
  {$IFNDEF TMSDOTNET}
  Result := IndexOf(Pointer(Value)) <> -1;
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  Result := IndexOf(TObject(Value)) <> -1;
  {$ENDIF}
end;


procedure TIntList.Add(Value: Integer);
begin
  {$IFDEF TMSDOTNET}
  inherited Add(TObject(Value));
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  inherited Add(Pointer(Value));
  {$ENDIF}

  if Assigned(OnChange) then
    OnChange(Self,FCol,FRow);
end;

procedure TIntList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  if Assigned(OnChange) then
    OnChange(Self,FCol,FRow);
end;

function TIntList.GetStrValue: string;
var
  i: integer;
begin
  for i := 1 to Count do
    if i = 1 then
      Result:= IntToStr(Items[i - 1])
    else
      Result := Result + ',' + IntToStr(Items[i - 1]);
end;

procedure TIntList.SetStrValue(const Value: string);
var
  sl:TStringList;
  i: Integer;
begin
  sl := TStringList.Create;
  sl.CommaText := Value;
  Clear;
  for i := 1 to sl.Count do
   Add(StrToInt(sl.Strings[i - 1]));
  sl.Free;
end;

procedure TIntList.Insert(Index, Value: Integer);
begin
  {$IFDEF TMSDOTNET}
  inherited Insert(Index, TObject(Value));
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  inherited Insert(Index, Pointer(Value));
  {$ENDIF}
end;

{ TFilePicture }

procedure TFilePicture.Assign(Source: TPersistent);
begin
  FFileName := TFilePicture(Source).Filename;
  FWidth := TFilePicture(Source).Width;
  FHeight := TFilePicture(Source).Height;
end;

procedure TFilePicture.DrawPicture(Canvas: TCanvas; r: TRect);
begin
  if FFilename = '' then
    Exit;

  FPicture := TPicture.Create;
  FPicture.LoadFromFile(FFilename);
  Canvas.StretchDraw(r,FPicture.Graphic);
  FPicture.Free;
end;

procedure TFilePicture.SetFileName(const Value: string);
begin
  FFileName := Value;
  FPicture := TPicture.Create;
  FPicture.LoadFromFile(FFilename);
  FWidth := FPicture.Width;
  FHeight := FPicture.Height;
  FPicture.Free;
end;

{ TSortIndexList }

procedure TSortIndexList.AddIndex(ColumnIndex: Integer;
  Ascending: boolean);
begin
  if Ascending then
    Add(ColumnIndex)
  else
    Add(integer($80000000) or ColumnIndex);
end;

function TSortIndexList.FindIndex(ColumnIndex: integer): integer;
var
  i: Integer;
begin
  Result := -1;
  i := 0;
  while i < Count do
  begin
    if Items[i] and $7FFFFFFF = ColumnIndex then
    begin
      Result := i;
      Break;
    end;
    Inc(i);
  end;
end;

function TSortIndexList.GetSortColumns(i: Integer): Integer;
begin
  Result := Items[i] and $7FFFFFFF;
end;

function TSortIndexList.GetSortDirections(i: Integer): Boolean;
begin
  Result := (Items[i] and $80000000) = $80000000;
end;

procedure TSortIndexList.SetSortColumns(i: Integer; const Value: Integer);
begin
  Items[i] := (DWord(Value) and $7FFFFFFF) + (Items[i] and $80000000);
end;

procedure TSortIndexList.SetSortDirections(i: Integer;
  const Value: Boolean);
begin
  if Value then
    Items[i] := (Items[i] and $7FFFFFFF)
  else
    Items[i] := (DWord(Items[i]) or $80000000);
end;

procedure TSortIndexList.ToggleIndex(ColumnIndex: integer);
var
  i: Integer;
begin
  i := 0;
  while i < Count do
  begin
    if Items[i] and $7FFFFFFF = ColumnIndex then
    begin
      if Items[i] and $80000000 = $80000000 then
        Items[i] := Items[i] and $7FFFFFFF
      else
        Items[i] := Items[i] or Integer($80000000);
      Break;
    end;
    Inc(i);
  end;
end;

{ TPopupButton }

constructor TPopupButton.Create(AOwner: TComponent);
begin
  inherited;
  FGradFrom := clNone;
  FGradTo := clNone;
  FImages := nil;
  DoubleBuffered := true;
end;

procedure TPopupButton.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER or WS_DISABLED;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
  end;
  Color := clBtnFace;
end;


procedure TPopupButton.CreateWnd;
begin
  inherited;
  SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE);
end;

procedure TPopupButton.Paint;
var
  r: TRect;
  v, a, fa, ah: string;
  xs, ys, ml, hl: Integer;
  cid, cv, ct: string;
  cr, hr: TRect;

begin
  r := GetClientRect;
  if not FFlat then
    Frame3D(Canvas,r,clWhite,clGray,1);

  DrawVistaGradient(Canvas,r,FGradFrom,FGradTo,FGradMirrorFrom,FGradMirrorTo,true,clNone);

  {
  if FGradFrom <> clNone then
  begin
    DrawGradient(Canvas,FGradFrom,FGradTo, 64, r, False);
  end;
  }

  SetBkMode(Canvas.Handle,TRANSPARENT);

  if Pos('</',FCaption) > 0 then
  begin
    HTMLDrawEx(Canvas,FCaption, r, FImages, 2, 2, -1, -1, 2, false, false, false, false, false, false, false, false, 1.0, clBlue, clNone, clNone,
      clGray, v, a, fa, ah, xs, ys, hl, ml, hr, cr, cid, cv, ct, nil, nil, self.Handle)
  end
  else
  begin
    {$IFDEF TMSDOTNET}
    DrawTextEx(Canvas.Handle,FCaption,Length(FCaption),r,DT_CENTER or DT_END_ELLIPSIS,nil);
    {$ENDIF}

    {$IFNDEF TMSDOTNET}
    DrawTextEx(Canvas.Handle,PChar(FCaption),Length(FCaption),r,DT_CENTER or DT_END_ELLIPSIS,nil);
    {$ENDIF}
  end;  
end;


{ TControlList }

procedure TControlList.AddControl(X, Y: Integer; AObject: TControl);
begin
  Add(TControlItem.Create(X,Y,AObject));
end;

function TControlList.ControlIndex(X, Y: Integer): Integer;
var
  i: Integer;
  CI: TControlItem;
begin
  Result := -1;

  for i := 1 to Count do
  begin
    CI := GetControl(i - 1);
    if (CI.X = X) and (CI.Y = Y) then
    begin
      Result := i - 1;
      Break;
    end;
  end;
end;

destructor TControlList.Destroy;
begin
  while Count > 0 do
    RemoveControl(0);
  inherited;
end;

function TControlList.GetControl(i: Integer): TControlItem;
begin
  Result := TControlItem(Items[i]);
end;

function TControlList.HasHandle(Handle: THandle): Boolean;
var
  i: Integer;
  CI: TControlItem;
begin
  Result := False;

  for i := 1 to Count do
  begin
    CI := GetControl(i - 1);
    if (CI.Control is TWinControl) then
    begin
      if (CI.Control as TWinControl).Handle = Handle then
      begin
        Result := true;
        Break;
      end;

    end;
  end;
end;

procedure TControlList.RemoveControl(i: Integer);
begin
  TControlItem(Items[i]).Free;
  Delete(i);
end;

{ TControlItem }

constructor TControlItem.Create(AX, AY: Integer; AObject: TControl);
begin
  inherited Create;
  FX := AX;
  FY := AY;
  FObject := AObject;
end;


function IsWinXP: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
{$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
{$ENDIF}
{$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(OSVersionInfo));
{$ENDIF}
  GetVersionEx(verinfo);
  Result := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));
end;

{$IFDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: StringBuilder;
begin
  Result := xpNone;

  if IsWinXP then
  begin
    if IsThemeActive then
    begin
      FileName := StringBuilder.Create(255);
      SizeName := StringBuilder.Create(255);
      ColorScheme := StringBuilder.Create(255);
      GetCurrentThemeName(FileName, 255, ColorScheme, 255, SizeName, 255);
      if(ColorScheme.ToString = 'NormalColor') then
        Result := xpBlue
      else if (ColorScheme.ToString = 'HomeStead') then
        Result := xpGreen
      else if (ColorScheme.ToString = 'Metallic') then
        Result := xpGray
    end;
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: WideString;
  hThemeLib: THandle;
begin
  hThemeLib := 0;
  Result := xpNone;

  if not IsWinXP then
    Exit;

  try
    if IsThemeActive then
    begin
      SetLength(FileName, 255);
      SetLength(ColorScheme, 255);
      SetLength(SizeName, 255);
      GetCurrentThemeName(PWideChar(FileName), 255,
        PWideChar(ColorScheme), 255, PWideChar(SizeName), 255);
      if(PWideChar(ColorScheme)='NormalColor') then
        Result := xpBlue
      else if(PWideChar(ColorScheme)='HomeStead') then
        Result := xpGreen
      else if(PWideChar(ColorScheme)='Metallic') then
        Result := xpGray
      else
        Result := xpNone;
    end;
  finally
    if hThemeLib <> 0 then
      FreeLibrary(hThemeLib);
  end;
end;
{$ENDIF}

procedure DrawGradient(Canvas: TCanvas; FromColor,ToColor, PenColor: TColor; Steps: Integer; R: TRect; Direction: Boolean);
var
  diffr,startr,endr: Integer;
  diffg,startg,endg: Integer;
  diffb,startb,endb: Integer;
  rstepr,rstepg,rstepb,rstepw: Real;
  i,stepw: Word;

begin
  if Steps = 0 then
    Steps := 1;

  FromColor := ColorToRGB(FromColor);
  ToColor := ColorToRGB(ToColor);

  startr := (FromColor and $0000FF);
  startg := (FromColor and $00FF00) shr 8;
  startb := (FromColor and $FF0000) shr 16;
  endr := (ToColor and $0000FF);
  endg := (ToColor and $00FF00) shr 8;
  endb := (ToColor and $FF0000) shr 16;

  diffr := endr - startr;
  diffg := endg - startg;
  diffb := endb - startb;

  rstepr := diffr / steps;
  rstepg := diffg / steps;
  rstepb := diffb / steps;

  if Direction then
    rstepw := (R.Right - R.Left) / Steps
  else
    rstepw := (R.Bottom - R.Top) / Steps;

  with Canvas do
  begin
    Brush.Style := bsSolid;  
    for i := 0 to steps-1 do
    begin
      endr := startr + Round(rstepr*i);
      endg := startg + Round(rstepg*i);
      endb := startb + Round(rstepb*i);
      stepw := Round(i*rstepw);
      Pen.Color := endr + (endg shl 8) + (endb shl 16);
      Brush.Color := Pen.Color;
      if Direction then
        Rectangle(R.Left + stepw,R.Top,R.Left + stepw + Round(rstepw)+1,R.Bottom)
      else
        Rectangle(R.Left,R.Top + stepw,R.Right,R.Top + stepw + Round(rstepw)+1);
    end;

    if PenColor <> clNone then
    begin
      Pen.Color := PenColor;
      Brush.Style := bsClear;
      Rectangle(R.Left,R.Top,R.Right, R.Bottom);
    end;
  end;

end;


constructor TAdvGridButton.Create(AOwner: TComponent);
begin
  {$IFNDEF TMSDOTNET}
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := GlyphChanged;
  FGlyphHot := TBitmap.Create;
  FGlyphDown := TBitmap.Create;
  FGlyphDisabled := TBitmap.Create;
  FGlyphShade := TBitmap.Create;
  {$ENDIF}
  inherited Create(AOwner);
  {$IFDEF TMSDOTNET}
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := GlyphChanged;
  FGlyphHot := TBitmap.Create;
  FGlyphDown := TBitmap.Create;
  FGlyphDisabled := TBitmap.Create;
  FGlyphShade := TBitmap.Create;
  {$ENDIF}

  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FColorTo := clNone;
  FColorHot := RGB(199,199,202);
  FColorHotTo := clNone;
  FColorDown := RGB(210,211,216);
  FColorDownTo := clNone;
  FColorChecked := clGray;
  FColorCheckedTo := clNone;
  FBorderColor := clNone;
  FBorderDownColor := clNone;
  FBorderHotColor := clNone;  
  FSpacing := 4;
  FMargin := -1;
  Flat := True;
  FLayout := blGlyphLeft;
  FTransparent := True;
  FShaded := True;
  FShowCaption := True;
end;

destructor TAdvGridButton.Destroy;
begin
  inherited Destroy;
  FGlyph.Free;
  FGlyphHot.Free;
  FGlyphDown.Free;
  FGlyphDisabled.Free;
  FGlyphShade.Free;
end;

procedure TAdvGridButton.DrawButtonGlyph(Canvas: TCanvas; const GlyphPos: TPoint;
  State: TButtonState; Transparent: Boolean);
var
  SelGlyph: TBitmap;
begin
  if FMouseInControl then
  begin
    if (FState in [ bsDown, bsExclusive]) then
    begin
      if GlyphDown.Empty then
        SelGlyph := FGlyph
      else
        SelGlyph := GlyphDown;
    end
    else
    begin
      if GlyphHot.Empty or (csDesigning in ComponentState) then
        SelGlyph := FGlyph
      else
        SelGlyph := GlyphHot;
    end;
  end
  else
  begin
    if (FState in [ bsDown, bsExclusive]) then
    begin
      if GlyphDown.Empty then
        SelGlyph := FGlyph
      else
        SelGlyph := GlyphDown;
    end
    else
      SelGlyph := FGlyph;
  end;


  if not Enabled then
  begin
    if FGlyphDisabled.Empty then
      SelGlyph := FGlyph
    else
      SelGlyph := FGlyphDisabled;
  end;

//  Shaded := true;

  if not SelGlyph.Empty then
  begin
    if FMouseInControl and Shaded and Enabled and not (FState = bsDown) then
    begin
      FGlyphShade.TransparentMode := tmAuto;
      FGlyphShade.Transparent := True;
      if Caption <> '' then
        Canvas.Draw(GlyphPos.X + 2,GlyphPos.Y + 2, FGlyphShade)
      else
        Canvas.Draw(GlyphPos.X,GlyphPos.Y, FGlyphShade)

    end;

    SelGlyph.TransparentMode := tmAuto;
    SelGlyph.Transparent := True;

    if Caption = '' then
      Canvas.Draw(0,0,SelGlyph)
    else
      Canvas.Draw(GlyphPos.X,GlyphPos.Y,SelGlyph);
  end;
end;

procedure TAdvGridButton.DrawButtonText(Canvas: TCanvas; const Caption: string;
  TextBounds: TRect; State: TButtonState; BiDiFlags: LongInt);
begin
  with Canvas do
  begin
    Brush.Style := bsClear;
    if State = bsDisabled then
    begin
      OffsetRect(TextBounds, 1, 1);
      Font.Color := clBtnHighlight;
      {$IFNDEF TMSDOTNET}
      DrawText(Handle, PChar(Caption), Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      DrawText(Handle, Caption, Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
      OffsetRect(TextBounds, -1, -1);
      Font.Color := clBtnShadow;
      {$IFNDEF TMSDOTNET}
      DrawText(Handle, PChar(Caption), Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      DrawText(Handle, Caption, Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
    end else
      {$IFNDEF TMSDOTNET}
      DrawText(Handle, PChar(Caption), Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      DrawText(Handle, Caption, Length(Caption), TextBounds,
        DT_CENTER or DT_VCENTER or BiDiFlags);
      {$ENDIF}
  end;
end;

procedure TAdvGridButton.CalcButtonLayout(Canvas: TCanvas; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout; Margin,
  Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect;
  BiDiFlags: LongInt);
var
  TextPos: TPoint;
  ClientSize, GlyphSize, TextSize: TPoint;
  TotalSize: TPoint;
begin
  if (BiDiFlags and DT_RIGHT) = DT_RIGHT then
    if Layout = blGlyphLeft then Layout := blGlyphRight
    else
      if Layout = blGlyphRight then Layout := blGlyphLeft;
  { calculate the item sizes }
  ClientSize := Point(Client.Right - Client.Left, Client.Bottom -
    Client.Top);

  if not FGlyph.Empty then
    GlyphSize := Point(FGlyph.Width, FGlyph.Height) else
    GlyphSize := Point(0, 0);

  if Length(Caption) > 0 then
  begin
    TextBounds := Rect(0, 0, Client.Right - Client.Left, 0);
    {$IFNDEF TMSDOTNET}
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), TextBounds,
      DT_CALCRECT or BiDiFlags);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    DrawText(Canvas.Handle, Caption, Length(Caption), TextBounds,
      DT_CALCRECT or BiDiFlags);
    {$ENDIF}
    TextSize := Point(TextBounds.Right - TextBounds.Left, TextBounds.Bottom -
      TextBounds.Top);
  end
  else
  begin
    TextBounds := Rect(0, 0, 0, 0);
    TextSize := Point(0,0);
  end;
    
  { If the layout has the glyph on the right or the left, then both the
    text and the glyph are centered vertically.  If the glyph is on the top
    or the bottom, then both the text and the glyph are centered horizontally.}
  if Layout in [blGlyphLeft, blGlyphRight] then
  begin
    GlyphPos.Y := (ClientSize.Y - GlyphSize.Y + 1) div 2;
    TextPos.Y := (ClientSize.Y - TextSize.Y + 1) div 2;
  end
  else
  begin
    GlyphPos.X := (ClientSize.X - GlyphSize.X + 1) div 2;
    TextPos.X := (ClientSize.X - TextSize.X + 1) div 2;
  end;

  { if there is no text or no bitmap, then Spacing is irrelevant }
  if (TextSize.X = 0) or (GlyphSize.X = 0) then
    Spacing := 0;
    
  { adjust Margin and Spacing }
  if Margin = -1 then
  begin
    if Spacing = -1 then
    begin
      TotalSize := Point(GlyphSize.X + TextSize.X, GlyphSize.Y + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X) div 3
      else
        Margin := (ClientSize.Y - TotalSize.Y) div 3;
      Spacing := Margin;
    end
    else
    begin
      TotalSize := Point(GlyphSize.X + Spacing + TextSize.X, GlyphSize.Y +
        Spacing + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X + 1) div 2
      else
        Margin := (ClientSize.Y - TotalSize.Y + 1) div 2;
    end;
  end
  else
  begin
    if Spacing = -1 then
    begin
      TotalSize := Point(ClientSize.X - (Margin + GlyphSize.X), ClientSize.Y -
        (Margin + GlyphSize.Y));
      if Layout in [blGlyphLeft, blGlyphRight] then
        Spacing := (TotalSize.X - TextSize.X) div 2
      else
        Spacing := (TotalSize.Y - TextSize.Y) div 2;
    end;
  end;
    
  case Layout of
    blGlyphLeft:
      begin
        GlyphPos.X := Margin;
        TextPos.X := GlyphPos.X + GlyphSize.X + Spacing;
      end;
    blGlyphRight:
      begin
        GlyphPos.X := ClientSize.X - Margin - GlyphSize.X;
        TextPos.X := GlyphPos.X - Spacing - TextSize.X;
      end;
    blGlyphTop:
      begin
        GlyphPos.Y := Margin;
        TextPos.Y := GlyphPos.Y + GlyphSize.Y + Spacing;
      end;
    blGlyphBottom:
      begin
        GlyphPos.Y := ClientSize.Y - Margin - GlyphSize.Y;
        TextPos.Y := GlyphPos.Y - Spacing - TextSize.Y;
      end;
  end;

  { fixup the result variables }
  with GlyphPos do
  begin
    Inc(X, Client.Left + Offset.X);
    Inc(Y, Client.Top + Offset.Y);
  end;


  OffsetRect(TextBounds, TextPos.X + Client.Left + Offset.X,
    TextPos.Y + Client.Top + Offset.X);
end;

function TAdvGridButton.DrawButton(Canvas: TCanvas; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout;
  Margin, Spacing: Integer; State: TButtonState; Transparent: Boolean;
  BiDiFlags: LongInt): TRect;
var
  GlyphPos: TPoint;
begin
  CalcButtonLayout(Canvas, Client, Offset, Caption, Layout, Margin, Spacing,
    GlyphPos, Result, BiDiFlags);

  if Caption = '' then
  begin
    GlyphPos.X := 0;
    GlyphPos.Y := 0;
  end;

  DrawButtonGlyph(Canvas, GlyphPos, State, Transparent);

  if not (State in [bsDown, bsExclusive]) then
  begin
    if FMouseInControl and Shaded and Enabled and not (State = bsDown) and Flat and not (csDesigning in ComponentState) then
    begin
      if Shaded then
        OffsetRect(Result, +1 , +1)
      else
        OffsetRect(Result, 0, +1);
    end;
  end;

  if ShowCaption then
    DrawButtonText(Canvas, Caption, Result, State, BiDiFlags);
end;


procedure TAdvGridButton.Paint;
const
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);
var
  PaintRect: TRect;
  DrawFlags: Integer;
  Offset: TPoint;
  PColorTo: TColor;
  mid: Integer;
  dotheme: boolean;
  HTheme: THandle;

begin
  if not Enabled then
  begin
    FState := bsDisabled;
    FDragging := False;
  end
  else
  begin
    if (FState = bsDisabled) then
      if FDown and (GroupIndex <> 0) then
        FState := bsExclusive
      else
        FState := bsUp;
  end;

  if (Style = tasCheck) and (Down) then
  begin
    FState := bsDown;
  end;

  Canvas.Font := Self.Font;
  PaintRect := Rect(0, 0, Width, Height);

  if not FFlat then
  begin
    dotheme := false;

    if IsWinXP and AutoXPStyle then
      dotheme := IsThemeActive;

    if dotheme then
    begin
      {$IFNDEF TMSDOTNET}
      HTHeme := OpenThemeData(Parent.Handle,'button');

      if FState in [bsDown,bsExclusive] then
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_PRESSED,@paintrect,nil)
      else

      if FMouseInControl then
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_HOT,@paintrect,nil)
      else
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_NORMAL,@paintrect,nil);

      CloseThemeData(HTHeme);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      HTHeme := OpenThemeData(Parent.Handle,'button');

       if FState in [bsDown,bsExclusive] then
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_PRESSED,paintrect,nil)
      else
      if FMouseInControl then
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_HOT,paintrect,nil)
      else
        DrawThemeBackground(HTheme,Canvas.Handle, BP_PUSHBUTTON,PBS_NORMAL,paintrect,nil);

      CloseThemeData(HTHeme);
      {$ENDIF}
    end
    else
    begin
      DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
      if FState in [bsDown, bsExclusive] then
        DrawFlags := DrawFlags or DFCS_PUSHED;
      DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
    end;
  end
  else
  begin
    if ((FState in [bsDown, bsExclusive]) or
      (FMouseInControl and (FState <> bsDisabled)) or
      (csDesigning in ComponentState)) and not Rounded and not Flat and (BorderDownColor = clNone) then
        DrawEdge(Canvas.Handle, PaintRect, DownStyles[FState in [bsDown, bsExclusive]],
          FillStyles[FTransparent] or BF_RECT);

      if {(csDesigning in ComponentState) or} (FBorderDownColor = clNone) or Rounded then
        InflateRect(PaintRect,-1,-1);

      if FMouseInControl and Enabled and not (csDesigning in ComponentState) then
      begin
        if (FState in [bsDown]) then
        begin
          Canvas.Brush.Color := ColorDown;
          PColorTo := ColorDownTo;
          Canvas.Pen.Color := FBorderDownColor;
        end
        else
        begin
          Canvas.Brush.Color := ColorHot;
          PColorTo := ColorHotTo;
          Canvas.Pen.Color := FBorderHotColor;
        end;

        if (Style = tasCheck) and Down and (FState <> bsDown) then
        begin
          Canvas.Pen.Color := FBorderDownColor;
          Canvas.Pen.Width := 1;
          Canvas.Brush.Color := ColorChecked;
          PColorTo := ColorCheckedTo;
          Canvas.Pen.Color := FBorderDownColor;
        end;

        Canvas.Pen.Width := 1;

        if Rounded then
          Canvas.Pen.Color := clNone;

        if PColorTo <> clNone then
        begin
          DrawGradient(Canvas, Canvas.Brush.Color, PColorTo, Canvas.Pen.Color, 16, PaintRect, False);
        end
        else
        begin
          if Canvas.Pen.Color = clNone then
            Canvas.Pen.Color := Canvas.Brush.Color;
          Canvas.Rectangle(PaintRect.Left,PaintRect.Top,PaintRect.Right,PaintRect.Bottom);
        end;

        if Rounded then
        begin
          InflateRect(PaintRect, +1, +1);
          if (FState in [bsDown]) then
            Canvas.Pen.Color := FBorderDownColor
          else
            Canvas.Pen.Color := FBorderHotColor;
          Canvas.Brush.Style := bsClear;
          Canvas.RoundRect(PaintRect.Left,PaintRect.Top,PaintRect.Right,PaintRect.Bottom,8,8);
        end;

        if FDropDownButton then
        begin
          if FState = bsDown then
            Canvas.Pen.COlor := FBorderDownColor
          else
            Canvas.Pen.COlor := FBorderHotColor;

          Canvas.MoveTo(PaintRect.Right - 12, PaintRect.Top);
          Canvas.LineTo(PaintRect.Right - 12, PaintRect.Bottom);
        end;
      end
      else
      begin
        Canvas.Pen.Width := 1;

        if (Style = tasCheck) and Down then
        begin
          Canvas.Pen.Color := FBorderDownColor;
          Canvas.Pen.Width := 1;
          Canvas.Brush.Color := ColorChecked;

          if ColorCheckedTo <> clNone then
            DrawGradient(Canvas, Canvas.Brush.Color, ColorCheckedTo, Canvas.Pen.Color, 16, PaintRect, False)
          else
          begin
            if FBorderDownColor = clNone then
              Canvas.Pen.Color := Canvas.Brush.Color;

            Canvas.Rectangle(PaintRect.Left,PaintRect.Top,PaintRect.Right,PaintRect.Bottom);
          end;

        end
        else
        begin
          Canvas.Brush.Color := ColorToRGB(Color);
          if ColorTo <> clNone then
          begin
            if Down then
              Canvas.Pen.Color := BorderDownColor
            else
              Canvas.Pen.Color := BorderColor;

            if Rounded then
              Canvas.Pen.Color := clNone;

            DrawGradient(Canvas, Color, ColorTo, Canvas.Pen.Color, 16, PaintRect, False);
          end
          else
            Canvas.FillRect(PaintRect);

          if (FBorderColor <> clNone) then
          begin
            if Rounded then
            begin
              InflateRect(PaintRect, +1, +1);
              Canvas.Pen.Color := FBorderColor;
              Canvas.Pen.Width := 1;
              Canvas.RoundRect(PaintRect.Left,PaintRect.Top,PaintRect.Right,PaintRect.Bottom,8,8);
            end
            else
            begin
              Canvas.Pen.Color := FBorderColor;
              Canvas.Brush.Style := bsClear;
              Canvas.Rectangle(PaintRect.Left, PaintRect.Top, PaintRect.Right, PaintRect.Bottom);
            end;
          end;

        end;
      end;

    InflateRect(PaintRect, -1, -1);
  end;

  Offset := Point(0,0);

  if FState in [bsDown, bsExclusive] then
  begin
    if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
    begin
      Canvas.Brush.Color := ColorChecked;
      PColorTo := ColorCheckedTo;

      if Down then
        Canvas.Pen.Color := BorderDownColor
      else
        Canvas.Pen.Color := BorderColor;

      InflateRect(PaintRect, +1, +1);
      if PColorTo <> clNone then
      begin
        DrawGradient(Canvas, ColorChecked, ColorCheckedTo, Canvas.Pen.Color, 16, PaintRect, False)
      end
      else
        Canvas.FillRect(PaintRect);
    end;
    if not FFlat and not (csDesigning in ComponentState) then
      Offset := Point(1,1);
  end
  else
  begin
    if FFlat then
    begin
      if FMouseInControl and Enabled and Shaded and not (FState = bsDown) and not (csDesigning in ComponentState) then
        Offset := Point(-1,-1)
    end;
  end;

  if FDropDownButton then
  begin
    mid := PaintRect.Top + (PaintRect.Bottom - PaintRect.Top) div 2;
    Canvas.Brush.Color := Font.Color;
    Canvas.Pen.Color := Font.Color;
    Canvas.Polygon([Point(PaintRect.Right -8, Mid -1),Point(PaintRect.Right - 4, Mid -1),Point(PaintRect.Right - 6, Mid + 1)]);
    PaintRect.Right := PaintRect.Right - 12;
  end;

   if FDown and (GroupIndex <> 0) then
     DrawButton(Canvas, PaintRect, Offset, Caption, FLayout, FMargin,
       FSpacing, bsDown, FTransparent, DrawTextBiDiModeFlags(0))
   else
     DrawButton(Canvas, PaintRect, Offset, Caption, FLayout, FMargin,
       FSpacing, FState, FTransparent, DrawTextBiDiModeFlags(0));
end;

procedure TAdvGridButton.UpdateTracking;
var
  P: TPoint;
begin
  if FFlat then
  begin
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not (FindDragTarget(P, True) = Self);
      if FMouseInControl then
        Perform(CM_MOUSELEAVE, 0, 0)
      else
        Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;
end;
    
procedure TAdvGridButton.Loaded;
begin
  inherited Loaded;

  if FShaded then
    GenerateShade;

  if AutoThemeAdapt then
    ThemeAdapt;  
end;

procedure TAdvGridButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  pt: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Button = mbLeft) and Enabled then
  begin
    if (FDropDownButton) and (X > ClientRect.Right - 12) then
    begin
      FState := bsUp;
      FMouseInControl := False;
      Repaint;
      if Assigned(FOnDropDown) then
        FOnDropDown(Self);

      if Assigned(FDropDownMenu) then
      begin
        pt := Point(Left, Top + Height);
        pt := Parent.ClientToScreen(pt);
        FDropDownMenu.Popup(pt.X,pt.Y);
      end;

      Exit;
    end;

    if not FDown then
    begin
      FState := bsDown;
      Invalidate;
    end;
    if Style = tasCheck then
    begin
      FState := bsDown;
      Repaint;
    end;

    FDragging := True;
  end;
end;

procedure TAdvGridButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if (not FDown) then NewState := bsUp
    else NewState := bsExclusive;

    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := bsExclusive else NewState := bsDown;

    if (Style = tasCheck) and FDown then
    begin
      NewState := bsDown;
    end;

    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end
  else if not FMouseInControl then
    UpdateTracking;
end;
    
procedure TAdvGridButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);

  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      // Redraw face in-case mouse is captured
      FState := bsUp;
      FMouseInControl := False;

      if Style = tasCheck then
      begin
        SetDown(not FDown);
        FState := bsUp;
      end;

      if DoClick and not (FState in [bsExclusive, bsDown]) then
        Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then
          FState := bsExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
end;
    
procedure TAdvGridButton.Click;
begin
  inherited Click;
end;
    

{$IFDEF DELPHI6_LVL}
function TAdvGridButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TAdvGridButtonActionLink;
end;
{$ENDIF}

procedure TAdvGridButton.SetGlyph(Value: TBitmap);
var
  x,y: Integer;
  PxlColor: TColor;
  c: byte;
begin
  FGlyph.Assign(Value);
  //if no disabled glyph is given... add this automatically...
  if FGlyphDisabled.Empty then
  begin
    FGlyphDisabled.Assign(Value);
    for x := 0 to FGlyphDisabled.Width - 1 do
      for y := 0 to FGlyphDisabled.Height - 1 do
      begin
        PxlColor := ColorToRGB(FGlyphDisabled.Canvas.Pixels[x, y]);
        c := Round((((PxlColor shr 16) + ((PxlColor shr 8) and $00FF) +
               (PxlColor and $0000FF)) div 3)) div 2 + 96;
        FGlyphDisabled.Canvas.Pixels[x, y] := RGB(c, c, c);
      end;
  end;
  Invalidate;
end;
    
procedure TAdvGridButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

{$IFNDEF TMSDOTNET}
procedure TAdvGridButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TAdvGridButton.ButtonPressed(Group: Integer; Button: TAdvGridButton);
begin
  if (Group = FGroupIndex) and (Button <> Self) then
  begin
    if Button.Down and FDown then
    begin
      FDown := False;
      FState := bsUp;
      if (Action is TCustomAction) then
        TCustomAction(Action).Checked := False;
      Invalidate;
    end;
    FAllowAllUp := Button.AllowAllUp;
  end;
end;

procedure TAdvGridButton.UpdateExclusive;
var
  I: Integer;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    for I := 0 to Parent.ControlCount - 1 do
      if Parent.Controls[I] is TSpeedButton then
        TAdvGridButton(Parent.Controls[I]).ButtonPressed(FGroupIndex, Self);
  end;
end;
{$ENDIF}

procedure TAdvGridButton.SetDown(Value: Boolean);
begin
  if (FGroupIndex = 0) and (Style = tasButton) then
    Value := False;

  if (Style = tasCheck) then
  begin
    FDown := Value;
    //FState := bsDown;
    Repaint;
    Exit;
  end;

  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then Invalidate;
      FState := bsExclusive
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;

procedure TAdvGridButton.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    Invalidate;
  end;
end;
    
procedure TAdvGridButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;
    
procedure TAdvGridButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;
    
procedure TAdvGridButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;
    
procedure TAdvGridButton.SetSpacing(Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TAdvGridButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;
    
procedure TAdvGridButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  inherited;
  if FDown then DblClick;
end;
    
procedure TAdvGridButton.CMEnabledChanged(var Message: TMessage);
const
  NewState: array[Boolean] of TButtonState = (bsDisabled, bsUp);
begin
  UpdateTracking;
  Repaint;
end;

{$IFNDEF TMSDOTNET}
procedure TAdvGridButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TAdvGridButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TAdvGridButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        if (Action is TCustomAction) then
          TCustomAction(Action).Checked := False;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;
{$ENDIF}
    
procedure TAdvGridButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and Enabled and Visible and
      (Parent <> nil) and Parent.Showing then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;
    
procedure TAdvGridButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;
    
procedure TAdvGridButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;
    
procedure TAdvGridButton.CMSysColorChange(var Message: TMessage);
begin
  with TBitmap(FGlyph) do
  begin
    Invalidate;
  end;
end;
    
procedure TAdvGridButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  { Don't draw a border if DragMode <> dmAutomatic since this button is meant to 
    be used as a dock client. }
  if FFlat and not FMouseInControl and Enabled and (DragMode <> dmAutomatic) 
    and (GetCapture = 0) then
  begin
    FMouseInControl := True;
    Repaint;
  end;

  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TAdvGridButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FFlat and FMouseInControl and Enabled and not FDragging then
  begin
    FMouseInControl := False;
    Invalidate;
  end;

  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TAdvGridButton.SetGlyphDisabled(const Value: TBitmap);
begin
  FGlyphDisabled.Assign(Value);
end;

procedure TAdvGridButton.SetGlyphDown(const Value: TBitmap);
begin
  FGlyphDown.Assign(Value);
end;

procedure TAdvGridButton.SetGlyphHot(const Value: TBitmap);
begin
  FGlyphHot.Assign(Value);
end;

procedure TAdvGridButton.GenerateShade;
var
  r: TRect;
  bmp: TBitmap;
begin
  if not FGlyph.Empty then
  begin
    FGlyphShade.Width := FGlyph.Width;
    FGlyphShade.Height := FGlyph.Height;

    r := Rect(0,0,FGlyphShade.Width,FGlyphShade.Height);
    FGlyphShade.Canvas.Brush.Color := ColorToRGB(clBlack);
    FGlyphShade.Canvas.BrushCopy(r,FGlyph,r, FGlyph.Canvas.Pixels[0,FGlyph.Height-1]);
    FGlyphShade.Canvas.CopyMode := cmSrcInvert;
    FGlyphShade.Canvas.CopyRect(r,FGlyph.Canvas,r);

    bmp := TBitmap.Create;
    bmp.Width := FGlyph.Width;
    bmp.Height := FGlyph.Height;
    bmp.Canvas.Brush.Color := ColorToRGB(clGray);
    bmp.Canvas.BrushCopy(r,FGlyphShade,r,ColorToRGB(clBlack));

    FGlyphShade.Canvas.CopyMode := cmSrcCopy;
    FGlyphShade.Canvas.CopyRect(r,bmp.Canvas,r);
    bmp.Free;
  end;
end;

procedure TAdvGridButton.SetShowCaption(const Value: Boolean);
begin
  if (FShowCaption <> Value) then
  begin
    FShowCaption := Value;
    Invalidate;
  end;
end;

procedure TAdvGridButton.SetShaded(const Value: Boolean);
begin
  FShaded := Value;

  if FShaded then
    if not (csLoading in ComponentState) then
    begin
      GenerateShade;
    end;
end;

procedure TAdvGridButton.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetColorChecked(const Value: TColor);
begin
  FColorChecked := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetStyle(const Value: TAdvGridButtonStyle);
begin
  FStyle := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetColorCheckedTo(const Value: TColor);
begin
  FColorCheckedTo := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetRounded(const Value: Boolean);
begin
  FRounded := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetDropDownButton(const Value: Boolean);
begin
  FDropDownButton := Value;
  Invalidate;
end;

procedure TAdvGridButton.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;


procedure TAdvGridButton.WndProc(var Message: TMessage);
begin
  // message does not seem to get through always?
  if (Message.Msg = WM_THEMECHANGED) and AutoThemeAdapt then
  begin
    ThemeAdapt;
  end;

  if (Message.Msg = CM_SYSFONTCHANGED) and AutoThemeAdapt then
  begin
    ThemeAdapt;
  end;
  
  inherited;
end;

procedure TAdvGridButton.ThemeAdapt;
var
  eTheme: XPColorScheme;
begin
  eTheme := CurrentXPTheme();
  case eTheme of
    xpBlue: Look := 2;
    xpGreen: Look := 3;
    xpGray: Look := 4;
  else
    Look := 1;
  end;
end;

procedure TAdvGridButton.SetLook(const Value: Integer);
begin
  case Value of
  // Windows XP
  0:begin
      self.Color := $EDF1F1;
      self.ColorTo := $DFEBEB;
      self.ColorHot := $FAFCFC;
      self.ColorHotTo := $E5ECED;
      self.ColorDown := $E0E6E7;
      self.ColorDownTo := $D8E0E1;
      self.ColorChecked := $FFFFFF;
      self.ColorCheckedTo := clNone;
      self.BorderDownColor := $AF987A;
      self.BorderHotColor := $C3CECE;
      self.BorderColor := clNone;
      self.Rounded := True;
      self.Flat := True;
    end;
  // Office 2002
  1:begin
      self.Color := clBtnFace;
      self.ColorTo := clNone;
      self.ColorHot := $EED2C1;
      self.ColorHotTo := clNone;
      self.ColorDown := $E2B598;
      self.ColorDownTo := clNone;
      self.ColorChecked := $E8E6E1;
      self.ColorCheckedTo := clNone;
      self.BorderDownColor := $C56A31;
      self.BorderHotColor := $C56A31;
      self.BorderColor := clNone;
      self.Rounded := False;
      self.Flat := True;
    end;
  // XP (Blue)
  2:begin
      self.Color := $FDEADA;
      self.ColorTo := $E4AE88;
      self.ColorHot := $CCF4FF;
      self.ColorHotTo := $91D0FF;
      self.ColorDown := $4E91FE;
      self.ColorDownTo := $8ED3FF;
      self.ColorChecked := $8ED3FF;
      self.ColorCheckedTo := $55ADFF;
      self.BorderDownColor := clBlack;
      self.BorderHotColor := clBlack;
      self.BorderColor := clNone;
      self.Rounded := False;
      self.Flat := True;
    end;
  // XP (Olive)
  3:begin
      self.Color := $CFF0EA;
      self.ColorTo := $8CC0B1;
      self.ColorHot := $CCF4FF;
      self.ColorHotTo := $91D0FF;
      self.ColorDown := $4E91FE;
      self.ColorDownTo := $8ED3FF;
      self.ColorChecked := $8ED3FF;
      self.ColorCheckedTo := $55ADFF;
      self.BorderDownColor := clBlack;
      self.BorderHotColor := clBlack;
      self.BorderColor := clNone;
      self.Rounded := False;
      self.Flat := True;
    end;
  // XP (Silver)
  4:begin
      self.Color := $ECE2E1;
      self.ColorTo := $B39698;
      self.ColorHot := $CCF4FF;
      self.ColorHotTo := $91D0FF;
      self.ColorDown := $4E91FE;
      self.ColorDownTo := $8ED3FF;
      self.ColorChecked := $8ED3FF;
      self.ColorCheckedTo := $55ADFF;
      self.BorderDownColor := clBlack;
      self.BorderHotColor := clBlack;
      self.BorderColor := clNone;
      self.Rounded := False;
      self.Flat := True;
    end;
  // Flat style
  5:begin
      self.Color := clBtnFace;
      self.ColorTo := clNone;
      self.ColorHot := clBtnFace;
      self.ColorHotTo := clNone;
      self.ColorDown := $00D8D3D2;
      self.ColorDownTo := clNone;
      self.ColorChecked := $00CAC7C7;
      self.ColorCheckedTo := clNone;
      self.BorderDownColor := clNone;
      self.BorderHotColor := clNone;
      self.BorderColor := clNone;
      self.Rounded := false;
      self.Flat := True;
    end;
  // Avant garde
  6:begin
      self.Color := $00CAFFFF;
      self.ColorTo := $00A6FFFF;
      self.ColorHot := $00A8F0FD;
      self.ColorHotTo := $007CE9FC;
      self.ColorDown := $004DE0FB;
      self.ColorDownTo := $007AE9FC;
      self.ColorChecked := $00B5E6F2;
      self.ColorCheckedTo := $009CDDED;
      self.BorderDownColor := clGray;
      self.BorderHotColor := clGray;
      self.BorderColor := clNone;
      self.Rounded := false;
      self.Flat := True;
    end;
  end;
end;

procedure TAdvGridButton.SetAutoThemeAdapt(const Value: Boolean);
begin
  FAutoThemeAdapt := Value;

//  if not (csDesigning in ComponentState) then
//  begin
    if FAutoThemeAdapt then
      ThemeAdapt;
//  end;
end;


function TAdvGridButton.GetColor: TColor;
begin
  Result := inherited Color;
end;

procedure TAdvGridButton.SetColor(const Value: TColor);
begin
  inherited Color := Value;
end;


procedure TAdvGridButton.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;
  if (AOperation = opRemove) and (AComponent = FDropDownMenu) then
    FDropDownMenu := nil;
end;


{$IFDEF DELPHI6_LVL}

{ TAdvGridButtonActionLink }

procedure TAdvGridButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TAdvGridButton;
end;

function TAdvGridButtonActionLink.IsCaptionLinked: Boolean;
begin
  Result := inherited IsCaptionLinked and
    (FClient.Caption = (Action as TCustomAction).Caption);
end;

function TAdvGridButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and (FClient.GroupIndex <> 0) and
    FClient.AllowAllUp and (FClient.Down = (Action as TCustomAction).Checked);
end;

function TAdvGridButtonActionLink.IsGroupIndexLinked: Boolean;
begin
  Result := (FClient is TAdvGridButton) and
    (TAdvGridButton(FClient).GroupIndex = (Action as TCustomAction).GroupIndex);
end;

procedure TAdvGridButtonActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then
    TAdvGridButton(FClient).Caption := Value;
end;

procedure TAdvGridButtonActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then
    TAdvGridButton(FClient).Down := Value;
end;

procedure TAdvGridButtonActionLink.SetGroupIndex(Value: Integer);
begin
  if IsGroupIndexLinked then
    TAdvGridButton(FClient).GroupIndex := Value;
end;

{$ENDIF}

procedure TFileStringList.Reset;
begin
  fp := 0;
  cache := '';
end;

function TFileStringList.GetEOF;
begin
  Result := fp >= Count;
end;

procedure TFileStringList.ReadLn(var s: string);
begin
  s := Strings[fp];
  inc(fp);
end;

procedure TFileStringList.Write(s: string);
begin
  cache := cache + s;
end;

procedure TFileStringList.WriteLn(s: string);
begin
  Add(cache + s);
  cache := '';
end;

end.
