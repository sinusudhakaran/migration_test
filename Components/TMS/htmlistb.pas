{**************************************************************************}
{ THTMListBox component                                                    }
{ for Delphi & C++Builder                                                  }
{ version 1.9                                                              }
{                                                                          }
{ Copyright © 2001 - 2006                                                  }
{   TMS Software                                                           }
{   Email : info@tmssoftware.com                                           }
{   Web : http://www.tmssoftware.com                                       }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit HTMListB;

{$I TMSDEFS.INC}
{$DEFINE REMOVEDRAW}
{$DEFINE HILIGHT}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls,
  Comobj, Activex, PictureContainer, AdvGradient, AdvStyleIF
  {$IFDEF TMSDOTNET}
  , Types
  {$ENDIF}
  ;

{$IFNDEF DELPHI3_LVL}
const
  crHandPoint = crUpArrow;
{$ENDIF}

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 9; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 1; // Build nr.

  // History
  // 1.8.0.1 : Fixed issue with item sizing
  // 1.8.0.2 : Fixed issue with initial scrollbar display on component load
  // 1.9.0.0 : New property AutoItemHeight added
  //         : New styler interface added with Office 2007 gradient selection colors
  //         : New ShowFocus property added
  // 1.9.0.1 : Fixed issue with AutoItemHeight
  // 1.9.1.0 : New added support for Office 2007 silver style
  // 1.9.1.1 : Fixed issue with ItemHeight


type
  EHTMListBoxError = class(Exception);

  TAnchorClick = procedure(Sender:TObject;index:integer;anchor:string) of object;

  TAnchorHintEvent = procedure(Sender:TObject; Index: Integer; var Anchor:string) of object;

  {$IFDEF DELPHI5_LVL}
  TOwnerDrawState = Windows.TOwnerDrawState;
  {$NODEFINE TOwnerDrawState}
  {$ENDIF}

  THTMListBox = class(TCustomListBox, ITMSStyle)
  private
    { Private declarations }
    FBlinking: Boolean;
    FOldCursor: Integer;
    FOldAnchor: string;
    FOnAnchorClick: TAnchorClick;
    FOnAnchorEnter: TAnchorClick;
    FOnAnchorExit: TAnchorClick;
    FOnAnchorHint: TAnchorHintEvent;
    FImages: TImageList;
    FMultiLine: Boolean;
    FURLColor: TColor;
    FSelectionColors: TGradientStyle;
    FSelectionFontColor: TColor;
    FIsMeasuring: Boolean;
    FTimerID: Integer;
    FEnableBlink: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FAnchorHint: boolean;
    FSortedEx: boolean;
    FIncrLookup: boolean;
    FLookup: string;
    FScrollHorizontal: boolean;
    FMaxExtent: integer;
    FUpdateCount: integer;
    FImageCache:THTMLPictureCache;
    FTimerCount: Integer;
    FEllipsis: Boolean;
    FLastHintPos: Integer;
    FItemHint: Boolean;
    FHTMLHint: Boolean;
    FContainer: TPictureContainer;
    FSortWithHTML: Boolean;
    FLineSpacing: Integer;
    FShowSelection: Boolean;
    FAutoItemHeight: Boolean;
    FShowFocus: Boolean;
    procedure ReMeasure;
    procedure DoMeasureList;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(Var Msg: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    procedure SetImages(value : TImageList);
    procedure SetMultiLine(value : boolean);
    procedure SetURLColor(const Value : tColor);
    procedure SetSelectionFontColor(const Value : tColor);
    function GetTextItem(index:integer):string;
    procedure SetEnableBlink(const Value: boolean);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: integer);
    function IsAnchor(x,y:integer;var Idx:integer):string;
    function GetSortedEx: boolean;
    procedure SetSortedEx(const Value: boolean);
    procedure SetScrollHorizontal(const Value: boolean);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetSelectionColors(const Value: TGradientStyle);
    procedure SetLineSpacing(const Value: Integer);
    procedure SetAutoItemHeight(const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
    function GetItemHeight: integer;
    procedure SetItemHeight(const value: integer);
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure Loaded; override;
    procedure DoEnter; override;
    function MaxHorizontalExtent: Integer;
    procedure UpdateHScrollExtent(maxextent: Integer);
    procedure QuickSortList(List:TStringList;Left,Right: Integer);
  public
    { Public declarations }
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    property TextItems[index:integer]:string read GetTextItem;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure HilightInList(HiText: string; DoCase: Boolean);
    procedure HilightInItem(Index: Integer; HiText: string; DoCase: Boolean);
    procedure UnHilightInList;
    procedure UnHilightInItem(Index: Integer);
    procedure MarkInList(HiText: string; DoCase: Boolean);
    procedure MarkInItem(Index: Integer; HiText: string; DoCase: Boolean);
    procedure UnMarkInList;
    procedure UnMarkInItem(Index: Integer);
    procedure SetComponentStyle(AStyle: TTMSStyle);    
  published
    { Published declarations }
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property AnchorHint: Boolean read FAnchorHint write FAnchorHint default False;
    property AutoItemHeight: boolean read FAutoItemHeight write SetAutoItemHeight default true;
    property BorderStyle;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis;
    property EnableBlink: Boolean read FEnableBlink write SetEnableBlink default False;
    property Enabled;
    property ExtendedSelect;
    property Font;
    property HTMLHint: Boolean read FHTMLHint write FHTMLHint default False;
    property Images:TImageList read FImages write SetImages;
    property IncrLookup:boolean read FIncrLookup write FIncrLookup default False;
    {$IFDEF DELPHI3_LVL}
    property ImeMode;
    property ImeName;
    {$ENDIF}
    property ItemHeight read GetItemHeight write SetItemHeight;
    property ItemHint: Boolean read FItemHint write FItemHint default False;
    property Items;
    property LineSpacing: Integer read FLineSpacing write SetLineSpacing default 0;
    property MultiSelect;
    property Multiline: Boolean read FMultiLine write SetMultiline;
    property ParentCtl3D;
    property ParentColor;
    property ParentShowHint;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property PopupMenu;
    property ScrollHorizontal: Boolean read fScrollHorizontal write SetScrollHorizontal default False;
    property ShowFocus: Boolean read FShowFocus write FShowFocus default True;
    property ShowHint;
    property SelectionColors: TGradientStyle read FSelectionColors write SetSelectionColors;
    property SelectionFontColor: TColor read fSelectionFontColor write SetSelectionFontColor;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset;
    property ShowSelection: Boolean read FShowSelection write FShowSelection;    
    property Sorted: Boolean read GetSortedEx write SetSortedEx;
    property SortWithHTML: Boolean read FSortWithHTML write FSortWithHTML;
    property TabOrder;
    property URLColor: TColor read FURLColor write SetURLColor default clBlue;
    property Visible;
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
    property OnStartDrag;
    property OnAnchorClick:TAnchorClick read FOnAnchorClick write FOnAnchorClick;
    property OnAnchorEnter:TAnchorClick read FOnAnchorEnter write FOnAnchorEnter;
    property OnAnchorExit:TAnchorClick read FOnAnchorExit write FOnAnchorExit;
    property OnAnchorHint:TAnchorHintEvent read FOnAnchorHint write FOnAnchorHint;
    property Version: string read GetVersion write SetVersion;
  end;


implementation

uses
  CommCtrl, ShellApi, Forms {$IFDEF DELPHI4_LVL} ,ImgList {$ENDIF};


type
  TGradientDirection = (gdVertical, gdHorizontal);

{$I htmlengo.pas}

procedure DrawGradient(Canvas: TCanvas; FromColor,ToColor: TColor; Steps: Integer;R:TRect; Direction: Boolean);
var
  diffr,startr,endr: Integer;
  diffg,startg,endg: Integer;
  diffb,startb,endb: Integer;
  iend: Integer;
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
    for i := 0 to Steps - 1 do
    begin
      endr := startr + Round(rstepr*i);
      endg := startg + Round(rstepg*i);
      endb := startb + Round(rstepb*i);
      stepw := Round(i*rstepw);
      Pen.Color := endr + (endg shl 8) + (endb shl 16);
      Brush.Color := Pen.Color;
      if Direction then
      begin
        iend := R.Left + stepw + Trunc(rstepw) + 1;
        if iend > R.Right then
          iend := R.Right;
        Rectangle(R.Left + stepw,R.Top,iend,R.Bottom)
      end
      else
      begin
        iend := R.Top + stepw + Trunc(rstepw)+1;
        if iend > r.Bottom then
          iend := r.Bottom;
        Rectangle(R.Left,R.Top + stepw,R.Right,iend);
      end;
    end;
  end;
end;

// Draw gradient in the specified rectangle (if Fill = True and ColorFrom <> clNone),
// frame it with BorderColor color.
procedure DrawVistaGradient(ACanvas: TCanvas; ARect: TRect; ColorFrom, ColorTo, ColorMirrorFrom, ColorMirrorTo: TColor;
  Direction: TGradientDirection; BorderColor: TColor; Fill: Boolean = True);
var
  r: Trect;

begin
  if Fill and (ColorFrom <> clNone) then
  begin
    if ColorMirrorFrom <> clNone then
    begin
      r := ARect;

      if Direction = gdHorizontal then
      begin
        r.Right := r.Left + ((r.Right - r.Left) div 2);
        DrawGradient(ACanvas,  ColorFrom, ColorTo, 128, r, Direction = gdVertical);
        r := ARect;
        r.Left := r.Left + ((r.Right - r.Left) div 2);
        DrawGradient(ACanvas,  ColorMirrorFrom, ColorMirrorTo, 128, r, Direction = gdVertical);
      end
      else
      begin
        r.Bottom := r.Top + ((r.Bottom - r.Top) div 2);
        DrawGradient(ACanvas,  ColorFrom, ColorTo, 128, r, Direction = gdHorizontal);
        r := ARect;
        r.Top := r.Top + ((r.Bottom - r.Top) div 2);
        DrawGradient(ACanvas,  ColorMirrorFrom, ColorMirrorTo, 128, r, Direction = gdHorizontal);
      end;
    end
    else
      DrawGradient(ACanvas, ColorFrom, ColorTo, 128, ARect, Direction = gdVertical);
  end;

  if BorderColor <> clNone then
  begin
    ACanvas.Brush.Color := BorderColor;
    ACanvas.FrameRect(ARect);
  end;
end;



procedure THTMListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  a,s,f: string;
  xsize,ysize,ml,hl: Integer;
  urlcol: TColor;
  hrect,hr: TRect;
  pt: TPoint;
  dx: Integer;
  dc: HDC;
  ACanvas: TCanvas;
  FColorTo: TColor;
  gd: TGradientDirection;

begin
  dx := 0;
  if FScrollHorizontal then
    dx := GetScrollPos(Handle,SB_HORZ);

  dc := GetDC(handle);

  try
    ACanvas := TCanvas.Create;
    try
      if dx = 0 then
        ACanvas.handle := Canvas.Handle
      else
        ACanvas.Handle := dc;

      ACanvas.Font.Assign(Font);

      hrect := Rect;

      if Index = Self.Items.Count -1 then
        if rect.Bottom < Height then
        begin
          rect.bottom := Height;
          ACanvas.Brush.Color := self.Color;
          ACanvas.Pen.Color := self.Color;
          ACanvas.Rectangle(rect.Left,rect.Top,rect.Right,rect.Bottom);
        end;

      Rect := hrect;

      if (odSelected in State) and (ShowSelection) then
      begin
        ACanvas.Brush.Color := FSelectionColors.ColorFrom;
        ACanvas.Font.Color := FSelectionFontColor;
        FColorTo := FSelectionColors.ColorTo;
        if FColorTo <> clNone then
          ACanvas.Pen.Color := FSelectionColors.BorderColor
        else
          ACanvas.Pen.Color := ACanvas.Brush.Color;
        Urlcol := FSelectionFontColor;
      end
      else
      begin
        ACanvas.Brush.Color := self.Color;
        ACanvas.Pen.Color := self.Color;
        ACanvas.Font.Color := self.Font.Color;
        FColorTo := clNone;
        Urlcol := FURLColor;
      end;

      if SelectionColors.Direction then
        gd := gdHorizontal
      else
        gd := gdVertical;

      if FColorTo <> clNone then
        DrawVistaGradient(ACanvas, Rect, ACanvas.Brush.Color, FColorTo, FSelectionColors.ColorMirrorFrom, FSelectionColors.ColorMirrorTo, gd, FSelectionColors.BorderColor)
        //DrawHTMLGradient(ACanvas, ACanvas.Brush.Color, FColorTo, FSelectionColors.BorderColor, 64, rect, FSelectionColors.Direction)
      else
        ACanvas.Rectangle(rect.Left,rect.Top,rect.Right,rect.Bottom);

      if (odFocused in State) and ShowFocus and ShowSelection then
      begin
        if (odSelected in State) then
        begin
          ACanvas.Pen.Style := psClear;
          ACanvas.Brush.Style := bsClear;
        end;
        ACanvas.DrawFocusRect(Rect);
      end;

      GetCursorPos(pt);
      pt := ScreenToClient(pt);

      // Correction for border
      hrect.Left := hrect.Left + 2 - dx;
      pt.X := pt.X + 2;

      // Unlimited width simulation if horiz. scroll
      if FScrollHorizontal then
        hrect.Right := hrect.Left + 4096;

      hrect.Bottom := hrect.Bottom + 4;

      HTMLDrawEx(aCanvas,items[index],hrect,FImages,pt.x,pt.y,-1,-1,FShadowOffset,False,False,False,(odSelected in State) and ShowSelection,
        True,False,not FEllipsis,1.0,urlcol,clNone,clNone,FShadowColor,a,s,f,XSize,YSize,hl,ml,hr,FImageCache,FContainer,FLineSpacing);

      if (odFocused in State) and ShowSelection then
      begin
        hrect.Left := hrect.Left - 2;
        ACanvas.Brush.Style := bsClear;
//        ACanvas.Pen.Color := FSelectionColors.BorderColor;
//        ACanvas.Rectangle(hrect.left,hrect.Top,hrect.Right,hrect.Bottom);

      end;



    finally
      ACanvas.Free;
    end;
  finally
    ReleaseDC(handle,dc);
  end;
end;

{$IFNDEF TMSDOTNET}
Procedure THTMListBox.CMHintShow(Var Msg: TMessage);
{$IFNDEF DELPHI3_LVL}
type
  PHintInfo = ^THintInfo;
{$ENDIF}
var
  CanShow: Boolean;
  hi: PHintInfo;
  Anchor: string;
  Res,Idx: Integer;
  R: TRect;

Begin
  CanShow := True;
  hi := PHintInfo(Msg.LParam);
  Anchor :='';

  if FAnchorHint then
  begin
    Anchor := IsAnchor(hi^.cursorPos.x,hi^.cursorpos.y,res);
    if Anchor <> '' then
    begin
      if Assigned(FOnAnchorHint) then
        FOnAnchorHint(self,res,Anchor);
      hi^.HintPos := ClientToScreen(hi^.CursorPos);
      hi^.Hintpos.y := hi^.Hintpos.Y - 10;
      hi^.Hintpos.x := hi^.Hintpos.X + 10;
      {$IFNDEF DELPHI3_LVL}
      Hint := Anchor;
      {$ELSE}
      hi^.HintStr := Anchor;
      {$ENDIF}
    end;
  end;

  if FItemHint and (Anchor ='') then
  begin
    Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(Hi^.CursorPos.X,Hi^.CursorPos.Y));

    SendMessage(Handle,LB_GETITEMRECT,Idx,Longint(@R));

    if PtInRect(R,Point(Hi^.CursorPos.X,Hi^.CursorPos.Y)) then
    begin
      if HTMLHint then
        Hi^.HintStr := Items[Idx]
      else
        Hi^.HintStr := TextItems[Idx];
      Hi^.Hintpos.X := 0;
      Hi^.Hintpos.Y := R.Top;
      Hi^.HintPos := ClientToScreen(Hi^.HintPos);
    end;
  end;

  Msg.Result := Ord(Not CanShow);
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure THTMListBox.CMHintShow(var Message: TCMHintShow);
var
  CanShow: Boolean;
  hi: THintInfo;
  Anchor: string;
  Res,Idx: Integer;
  R: TRect;

Begin
  CanShow := True;
  hi := Message.HintInfo;
  Anchor :='';

  if FAnchorHint then
  begin
    Anchor := IsAnchor(hi.cursorPos.x,hi.cursorpos.y,res);
    if Anchor <> '' then
    begin
      if Assigned(FOnAnchorHint) then
        FOnAnchorHint(self,res,Anchor);
      hi.HintPos := ClientToScreen(hi.CursorPos);
      hi.Hintpos.y := hi.Hintpos.Y - 10;
      hi.Hintpos.x := hi.Hintpos.X + 10;
      {$IFNDEF DELPHI3_LVL}
      Hint := Anchor;
      {$ELSE}
      hi.HintStr := Anchor;
      {$ENDIF}
    end;
  end;

  if FItemHint and (Anchor ='') then
  begin
    Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(Hi.CursorPos.X,Hi.CursorPos.Y));

    Perform(LB_GETITEMRECT,Idx,R);

    if PtInRect(R,Point(Hi.CursorPos.X,Hi.CursorPos.Y)) then
    begin
      if HTMLHint then
        Hi.HintStr := Items[Idx]
      else
        Hi.HintStr := TextItems[Idx];
      Hi.Hintpos.X := 0;
      Hi.Hintpos.Y := R.Top;
      Hi.HintPos := ClientToScreen(Hi.HintPos);
    end;
  end;

  Message.Result := Ord(Not CanShow);
end;
{$ENDIF}

procedure THTMListBox.MeasureItem(Index: Integer; var Height: Integer);
begin
  Height := SendMessage(Handle,LB_GETITEMHEIGHT, Index ,0);
end;

constructor THTMListBox.Create(aOwner: tComponent);
begin
  inherited Create(aOwner);
  Style := lbOwnerDrawVariable;
  FIsMeasuring := False;
  FURLColor := clBlue;
  FSelectionFontColor := clHighLightText;
  FTimerID:=0;
  FEnableBlink := False;
  FShadowColor := clGray;
  FShadowOffset := 1;
  FOldAnchor := '';
  FScrollHorizontal := False;
  FImageCache := THTMLPictureCache.Create;
  FLastHintPos := -1;
  {$IFDEF DELPHI4_LVL}
  DoubleBuffered := True;
  {$ENDIF}
  FSelectionColors := TGradientStyle.Create;
  FShowSelection := True;
  FAutoItemHeight := True;
  FShowFocus := True;
end;

procedure THTMListBox.Loaded;
begin
  inherited;
  FOldCursor := self.Cursor;
  if FEnableBlink and (FTimerID = 0) then
    FTimerID := SetTimer(self.Handle,1,100,nil);
  if not FEnableBlink and (FTimerID <> 0) then
    KillTimer(self.Handle,FTimerID);

  ReMeasure;
  Width := Width - 1;
  Width := Width + 1;
end;

procedure THTMListBox.SetImages(value:TImagelist);
begin
  FImages := Value;
  ReMeasure;
end;

procedure THTMListBox.SetURLColor(const Value:tColor);
begin
  if Value <> FURLColor then
  begin
    FURLColor := Value;
    Invalidate;
  end;
end;

procedure THTMListBox.SetSelectionFontColor(const Value: tColor);
begin
  if Value <> fSelectionFontColor then
  begin
    FSelectionFontColor := Value;
    Invalidate;
  end;
end;

procedure THTMListBox.SetMultiLine(value:boolean);
begin
  if Value <> FMultiline then
  begin
    FMultiline := Value;
    ReMeasure;
  end;
end;

procedure THTMListBox.SetAutoItemHeight(const Value: Boolean);
begin
  if (Value <> FAutoItemHeight) then
  begin
    FAutoItemHeight := value;
    Remeasure;
    Invalidate;
  end;
end;

function THTMListBox.GetTextItem(index:integer):string;
begin
  if (index >= 0) and (Index < self.Items.Count) then
  begin
    Result := HTMLStrip(self.Items[index]);
  end
  else
    raise EHTMListBoxError.Create('Item index out of range');
end;

procedure THTMListBox.DoMeasureList;
var
  r,hr: TRect;
  i: Integer;
  MaxX: integer;
  xsize,ysize,ml,hl: Integer;
  a,s,f: string;

begin
  if Items.Count = 0 then
    Exit;

  {$IFNDEF TMSDOTNET}
  SendMessage(Handle,LB_GETITEMRECT,0,Longint(@r));
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Perform(LB_GETITEMRECT,0,r);
  {$ENDIF}

  MaxX := 0;

  if FScrollHorizontal then
    r.Right := r.Left + 4096
  else
  begin
    if items.Count * ItemHeight > Height then
      r.Right := r.Right - GetSystemMetrics(SM_CXVSCROLL)
    else
      r.Right := r.Right - 4;
  end;

  Canvas.Font.Assign(Font);

  r.Bottom := r.Top + Height;

  for i := 0 to Items.Count - 1 do
  begin
    if FAutoItemHeight then
    begin
      HTMLDrawEx(Canvas,Items[i],r,FImages,0,0,-1,-1,FShadowOffset,True,True,False,True,True,False,not FEllipsis,1.0,
        FURLColor,clNone,clNone,FShadowColor,a,s,f,xsize,ysize,hl,ml,hr,FImageCache,FContainer,FLineSpacing);

      if YSize > ClientRect.Bottom - ClientRect.Top then
        YSize := ClientRect.Bottom - ClientRect.Top;

      if YSize > 251 then
        YSize := 251;

      SendMessage(Handle,LB_SETITEMHEIGHT,i,YSize - 2);

      if XSize + 6 > MaxX then
        MaxX := XSize + 6;
    end
    else
    begin
      SendMessage(Handle,LB_SETITEMHEIGHT,i,ItemHeight);
      MaxX := ItemHeight;
    end;

  end;

  if FScrollHorizontal and (MaxX > FMaxExtent) then
  begin
    FMaxExtent := MaxX;
    UpdateHScrollExtent(FMaxExtent);
  end;
end;

procedure THTMListBox.WndProc(var Message: TMessage);
var
  r,hr: TRect;
  xsize,ysize,ml,hl: Integer;
  a,s,f: string;
begin
  inherited;

  if Message.msg = WM_DESTROY then
  begin
    if FEnableBlink and (FTimerID <> 0) then
      KillTimer(Handle,FTimerID);
  end;

  if (Message.msg = LB_DELETESTRING) or
     (Message.msg = LB_RESETCONTENT) then
  begin
    if FScrollHorizontal and (FUpdateCount = 0) then
      UpdateHScrollExtent(0);
  end;


  if (Message.msg = LB_ADDSTRING) or
     (Message.msg = LB_INSERTSTRING) then
  begin
    {$IFNDEF TMSDOTNET}
    SendMessage(Handle,LB_GETITEMRECT,Message.Result,Longint(@r));
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    Perform(LB_GETITEMRECT,Message.Result,r);
    {$ENDIF}


    if FScrollHorizontal then
      r.Right := r.Left + 4096
    else
    begin
      if items.Count * ItemHeight > Height then
        r.Right := r.Right - GetSystemMetrics(SM_CXVSCROLL)
      else
        r.Right := r.Right - 2;
    end;

    Canvas.Font.Assign(Font);

    r.Bottom := r.Top + Height;

    HTMLDrawEx(Canvas,Items[message.Result],r,FImages,0,0,-1,-1,FShadowOffset,True,True,False,True,True,False,not FEllipsis,1.0,
               FURLColor,clNone,clNone,FShadowColor,a,s,f,xsize,ysize,hl,ml,hr,FImageCache,FContainer,FLineSpacing);

    if YSize > ClientRect.Bottom - ClientRect.Top then
      YSize := ClientRect.Bottom - ClientRect.Top;

    if YSize > 251 then
       YSize := 251;

    if not AutoItemHeight then
      YSize := ItemHeight + 2;
      
    SendMessage(Handle,LB_SETITEMHEIGHT,Message.Result,YSize - 2);

    if FScrollHorizontal and (XSize + 6 > FMaxExtent) then
    begin
      FMaxExtent := XSize + 6;
      UpdateHScrollExtent(FMaxExtent);
    end;

  end;

end;

function THTMListBox.MaxHorizontalExtent: Integer;
var
  r,hr: TRect;
  xsize,ysize,ml,hl,i: Integer;
  a,s,f: string;
begin
  FMaxExtent := 0;
  for i := 1 to Items.Count do
  begin

    HTMLDrawEx(Canvas,Items[i-1],r,fImages,0,0,-1,-1,fShadowOffset,true,true,false,true,true,false,not FEllipsis,1.0,
               FURLColor,clNone,clNone,fShadowColor,a,s,f,xsize,ysize,hl,ml,hr,FImageCache,FContainer,0);
    if (XSize + 6 > FMaxExtent) then
      FMaxExtent := XSize + 6;
  end;
  Result := FMaxExtent;
end;

procedure THTMListBox.UpdateHScrollExtent(MaxExtent:Integer);
var
  max,w: Integer;
  r: TRect;
begin
  if FUpdateCount > 0 then
   Exit;

  if (Items.Count <= 0) or (FScrollHorizontal = False) then
  begin
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, 0, 0 );
    SendMessage(Handle, WM_HSCROLL, SB_TOP, 0 );
    Exit;
  end;

  if MaxExtent > 0 then
    Max := MaxExtent
  else
    Max := MaxHorizontalExtent;

  {$IFNDEF TMSDOTNET}
  SendMessage(self.Handle,LB_GETITEMRECT,0,Longint(@r));
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Perform(LB_GETITEMRECT,0,r);
  {$ENDIF}

  w := r.Right - r.Left;

  inc(FUpdateCount);
  if Max > w then
  begin
    SendMessage(Handle,LB_SETHORIZONTALEXTENT,Max,0);
  end
  else
  begin
    SendMessage(Handle,LB_SETHORIZONTALEXTENT,0,0);
    SendMessage(Handle,WM_HSCROLL,SB_TOP,0);
    ShowScrollBar(Handle,SB_HORZ,False);
  end;

  dec(FUpdateCount);
end;

procedure THTMListBox.ReMeasure;
//var
//  i: Integer;
//  sel: Boolean;
begin
  if csLoading in ComponentState then
    Exit;

  FIsMeasuring := True;

  DoMeasureList;
  {
  sel := False;
  for i := 1 to Items.Count do
  begin
    if MultiSelect then
      sel := Selected[i - 1];
    Items[i - 1] := Items[i - 1];
    if sel and MultiSelect then
      Selected[i - 1] := sel;
  end;
  }
  FIsMeasuring := False;
  MaxHorizontalExtent;
end;

function THTMListBox.IsAnchor(x,y:integer;var idx:integer):string;
var
  res: Integer;
  r,hr: TRect;
  anchor,stripped,f: string;
  xsize,ysize,ml,hl: Integer;

begin
  Result := '';
  idx := -1;
  res := loword(SendMessage(self.handle,LB_ITEMFROMPOINT,0,MakeLParam(X,Y)));
  if (res >= 0) and (res < self.Items.Count) then
  begin
    idx := res;
    {$IFNDEF TMSDOTNET}
    SendMessage(self.Handle,LB_GETITEMRECT,Res,longint(@r));
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    Perform(LB_GETITEMRECT,Res,r);
    {$ENDIF}

    if HTMLDrawEx(canvas,self.items[res],r,FImages,X,Y,-1,-1,FShadowOffset,true,false,false,true,true,false,not FEllipsis,1.0,
                  FURLColor,clNone,clNone,fShadowColor,anchor,stripped,f,xsize,ysize,hl,ml,hr,FImageCache,FContainer,0) then

    Result := Anchor;
  end;
end;

procedure THTMListBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Anchor:string;
  idx: Integer;
begin
  Anchor := IsAnchor(X,Y,idx);
  if Anchor <> '' then
  begin
    if (Pos('://',Anchor) > 0) or (Pos('mailto:',Anchor) > 0) then
      {$IFNDEF TMSDOTNET}
      ShellExecute(0,'open',PChar(Anchor),nil,nil,SW_NORMAL)
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      ShellExecute(0,'open',Anchor,'','',SW_NORMAL)
      {$ENDIF}
    else
      begin
        if Assigned(FOnAnchorClick) then
          FOnAnchorClick(Self,idx,Anchor);
      end;
    Exit;
  end;
  inherited MouseDown(Button,Shift,X,Y);
end;

procedure THTMListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Anchor: string;
  Idx: integer;
  R: TRect;
begin
  inherited MouseMove(Shift,X,Y);

  if FItemHint then
  begin
    Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(X,Y));
    {$IFNDEF TMSDOTNET}
    SendMessage(Handle,LB_GETITEMRECT,Idx,Longint(@R));
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    Perform(LB_GETITEMRECT,Idx,R);
    {$ENDIF}

    if PtInRect(R,Point(X,Y)) then
    begin
      if Idx <> FLastHintPos then
      begin
        Application.CancelHint;
        FLastHintPos := Idx;
      end
    end
    else
    begin
      if FLastHintPos >= 0 then
      begin
        Application.CancelHint;
        FLastHintPos := -1;
      end;
    end;
  end;

  Anchor := IsAnchor(x,y,idx);

  if Anchor <> '' then
  begin
    if (FOldAnchor <> Anchor) and (FOldAnchor <> '') then
    begin
      Application.Cancelhint;
      if Assigned(FOnAnchorExit) then
        FOnAnchorExit(self,idx,FOldAnchor);
    end;

    if self.Cursor <> crHandPoint then
    begin
      FOldCursor := self.Cursor;
      self.Cursor := crHandPoint;
    end;

    if FOldAnchor <> Anchor then
      if Assigned(FOnAnchorEnter) then
        FOnAnchorEnter(self,idx,Anchor);

    FOldAnchor:=anchor;
  end
  else
  begin
    if self.Cursor = crHandPoint then
    begin
      //Invalidate;
      if (FOldAnchor <> '') then
      begin
        Application.CancelHint;
        self.Cursor := FOldCursor;
        if Assigned(FOnAnchorExit) then
          FOnAnchorExit(self,idx,fOldAnchor);
        FOldAnchor := '';
      end;
    end;
  end;
end;

procedure THTMListBox.WMSize(var Msg: TWMSize);
begin
  inherited;

  if not FScrollHorizontal then
    if not FIsMeasuring then
      ReMeasure;

  if FScrollHorizontal then
    UpdateHScrollExtent(0);
end;

procedure THTMListBox.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages := nil;
  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
  inherited;
end;

procedure THTMListBox.WMTimer(var Msg: TWMTimer);
var
  i,i1,i2: Integer;
  r: TRect;
  a,s,f: string;
  xsize,ysize: Integer;
  sel: Boolean;
  hr:trect;
  hl,ml:integer;
  DoAnim: Boolean;
  IsSelect: Boolean;

begin
  if (Items.Count = 0) or not FEnableBlink then
    Exit;

  DoAnim := False;

  if Assigned(FImageCache) then
    if FImageCache.Animate then
      DoAnim := True;

  if Assigned(FContainer) then
    if FContainer.Items.Animate then
      DoAnim := True;

  if DoAnim then
    Invalidate;

  inc(FTimerCount);

  if FTimerCount mod 5 <>0 then
    Exit;

  r := GetClientRect;
  i1 := SendMessage(handle,LB_ITEMFROMPOINT,0,makelparam(0,r.Top));
  i2 := SendMessage(handle,LB_ITEMFROMPOINT,0,makelparam(0,r.Bottom));

  if i1 < 0 then i1 := 0;
  if i2 > Items.Count - 1 then
    i2 := Items.Count - 1;

  for i := i1 to i2 do
  begin
    //only redraw items with blinking
    if Pos('<BLINK',UpperCase(items[i])) > 0 then
    begin
      {$IFNDEF TMSDOTNET}
      SendMessage(handle,LB_GETITEMRECT,i,longint(@r));
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      Perform(LB_GETITEMRECT,i,r);
      {$ENDIF}

      sel := SendMessage(handle,LB_GETSEL,i,0) > 0;
      r.left := r.Left + 2;
      if not sel then
      begin
        Canvas.Brush.color := self.Color;
        Canvas.Font.color := self.Font.Color;
      end
      else
      begin
        Canvas.Brush.Color := FSelectionColors.ColorFrom;
        Canvas.Font.Color := FSelectionFontColor;
      end;

      IsSelect := (ItemIndex = i) or (MultiSelect and Selected[i]);

      HTMLDrawEx(Canvas,Items[i],r,FImages,0,0,-1,-1,FShadowOffset,False,False,False,IsSelect,FBlinking,False,not FEllipsis,1.0,fURLColor,clNone,clNone,fShadowColor,
                 a,s,f,xsize,ysize,hl,ml,hr,FImageCache,FContainer,0);
    end;
  end;
  FBlinking := not FBlinking;
end;

procedure THTMListBox.SetEnableBlink(const Value: boolean);
begin
  FEnableBlink := Value;
  if not (csLoading in ComponentState) then
  begin
    if FEnableBlink and (FTimerID = 0) then
      FTimerID := SetTimer(self.Handle,1,100,nil);
    if not FEnableBlink and (FTimerID <> 0) then
    begin
      KillTimer(self.handle,fTimerID);
      FTimerID := 0;
      FBlinking := False;
      Invalidate;
    end;
  end;
end;

procedure THTMListBox.SetShadowColor(const Value: TColor);
begin
  FShadowColor := Value;
  self.Invalidate;
end;

procedure THTMListBox.SetShadowOffset(const Value: integer);
begin
  FShadowOffset := Value;
  self.Invalidate;
end;

function THTMListBox.GetSortedEx: boolean;
begin
  Result := FSortedEx;
end;

function DoStrip(s:string; NoStrip: Boolean): string;
begin
  if NoStrip then
    Result := s
  else
    Result := HTMLStrip(s);
end;

procedure THTMListBox.QuickSortList(List:TStringList;left,right:integer);
var
  i,j:integer;
  s,sw: string;
  obj: TObject;

  begin
  i := Left;
  j := Right;

  {get middle item here}
  s := DoStrip(List.Strings[(left+right) shr 1],FSortWithHTML);

  repeat
    {$IFDEF VER90}
    while (StrComp(pchar(s),PChar(DoStrip(List.Strings[i],FSortWithHTML))) > 0) and (i<right) do inc(i);
    while (StrComp(pchar(s),PChar(DoStrip(List.Strings[j],FSortWithHTML))) < 0) and (j>left) do dec(j);
    {$ELSE}
    {$IFNDEF TMSDOTNET}
    while (AnsiStrComp(pchar(s),PChar(DoStrip(List.Strings[i],FSortWithHTML))) > 0) and (i<right) do inc(i);
    while (AnsiStrComp(pchar(s),PChar(DoStrip(List.Strings[j],FSortWithHTML))) < 0) and (j>left) do dec(j);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    while (AnsiCompareStr(s,DoStrip(List.Strings[i],FSortWithHTML)) > 0) and (i<right) do inc(i);
    while (AnsiCompareStr(s,DoStrip(List.Strings[j],FSortWithHTML)) < 0) and (j>left) do dec(j);
    {$ENDIF}

    {$ENDIF}
    if (i<=j) then
    begin
      if (i<>j) then
      begin
        {$IFDEF VER90}
        if StrComp(pchar(DoStrip(List.Strings[i],FSortWithHTML)),pchar(DoStrip(List.Strings[j],FSortWithHTML)))<>0 then
        {$ELSE}
        {$IFNDEF TMSDOTNET}
        if AnsiStrComp(pchar(DoStrip(List.Strings[i],FSortWithHTML)),pchar(DoStrip(List.Strings[j],FSortWithHTML)))<>0 then
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        if AnsiCompareStr(DoStrip(List.Strings[i],FSortWithHTML),DoStrip(List.Strings[j],FSortWithHTML))<>0 then
        {$ENDIF}
        {$ENDIF}
        begin
          sw := List.Strings[i];
          obj := List.Objects[i];
          List.Strings[i] := List.Strings[j];
          List.Objects[i] := List.Objects[j];
          List.Strings[j] := sw;
          List.Objects[j] := obj;
        end;
      end;
      inc(i);
      dec(j);
    end;
  until i > j;

  if Left < j then QuicksortList(List,Left,j);
  if i < Right then QuickSortList(List,i,Right);
end;

procedure THTMListBox.SetSortedEx(const Value: boolean);
var
  sl: TStringList;
begin
  FSortedEx := Value;

  if Value then
  begin
    sl := TStringList.Create;
    sl.Assign(Items);

    if sl.Count > 1 then
      QuickSortList(sl,0,sl.Count-1);

    Items.Assign(sl);
    sl.Free;
  end;
end;

procedure THTMListBox.KeyDown(var Key: Word; Shift: TShiftState);
var
  i: Integer;
  s: String;

  function Max(a,b: Integer):Integer;
  begin
    if a > b then Result := a else Result := b;
  end;

begin
  inherited;
  if Key in [vk_up,vk_down,vk_left,vk_right,vk_next,vk_prior,vk_home,vk_end,vk_escape] then
  begin
    FLookup := '';
    Exit;
  end;

  if (key = vk_back) and (Length(FLookup)>0) then
    Delete(FLookup,Length(FLookup),1)
  else
  if not FIncrLookup then
    FLookup := chr(key)
  else
    if (key>31) and (key<=255) then FLookup := fLookup+chr(key);

  if (ItemIndex>=0) or (FIncrLookup) then
  begin
    for i := Max(1,ItemIndex+1) to Items.Count do
    begin
      s := TextItems[i-1];
      if s <> '' then
        if Pos(UpperCase(FLookup),Uppercase(s)) = 1 then
        begin
          ItemIndex := i-1;
          Exit;
        end;
    end;
  end;

  for i := 1 to Items.Count do
  begin
    s := TextItems[i-1];
    if s <> '' then
      if Pos(UpperCase(FLookup),Uppercase(s)) = 1 then
    begin
      ItemIndex := i-1;
      Exit;
    end;
  end;

  if FIncrLookup then
  begin
    FLookup := chr(key);
    for i := 1 to Items.Count do
    begin
      s := TextItems[i-1];
      if s <> '' then
        if Pos(Uppercase(FLookup),Uppercase(s)) = 1 then
        begin
          ItemIndex := i-1;
          Exit;
        end;
    end;
  end;
end;

procedure THTMListBox.DoEnter;
begin
  inherited;
  FLookup := '';
end;

procedure THTMListBox.SetScrollHorizontal(const Value: boolean);
begin
  if FScrollHorizontal <> Value then
  begin
    FScrollHorizontal := Value;
    UpdateHScrollExtent(0);
  end;
end;

procedure THTMListBox.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure THTMListBox.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
    begin
      UpdateHScrollExtent(0);
    end;  
  end;
end;

destructor THTMListBox.Destroy;
begin
  FSelectionColors.Free;
  FImageCache.Free;
  inherited;
end;

procedure THTMListBox.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then
  begin
    FEllipsis := Value;
    Invalidate;
  end;
end;

procedure THTMListBox.SetComponentStyle(AStyle: TTMSStyle);
begin
  case AStyle of
    tsOffice2003Blue, tsOffice2003Silver, tsOffice2003Olive, tsOffice2003Classic:
      begin
        SelectionColors.BorderColor := clNone;
        SelectionColors.ColorFrom := $C2EEFF;  // #FFEEC2
        SelectionColors.ColorTo := clNone;
        SelectionColors.ColorMirrorFrom := clNone;
        SelectionColors.ColorMirrorTo := clNone;
        SelectionFontColor := clBlack;
      end;
    tsOffice2007Luna, tsOffice2007Obsidian, tsOffice2007Silver:
      begin
        SelectionColors.BorderColor := clSilver;
        SelectionColors.ColorFrom := $EBFDFF;
        SelectionColors.ColorTo := $ABEBFF;
        SelectionColors.ColorMirrorFrom := $69D6FF;
        SelectionColors.ColorMirrorTo := $96E4FF;
        SelectionFontColor := clBlack;
      end;
    tsWindowsXP, tsWhidbey:
      begin
        SelectionColors.BorderColor := clNone;
        SelectionColors.ColorFrom := clHighlight;
        SelectionColors.ColorTo := clNone;
        SelectionColors.ColorMirrorFrom := clNone;
        SelectionColors.ColorMirrorTo := clNone;
        SelectionFontColor := clHighlightText;
      end;
    tsCustom: ;
  end;
end;

procedure THTMListBox.SetContainer(const Value: TPictureContainer);
begin
  FContainer := Value;  
  ReMeasure;
end;

procedure THTMListBox.HilightInItem(Index: Integer; HiText: string;
  DoCase: Boolean);
begin
  Items[Index] := Hilight(Items[Index],HiText,'hi',DoCase);
end;

procedure THTMListBox.HilightInList(HiText: string; DoCase: Boolean);
var
  i: Integer;
begin
  BeginUpdate;
  for i := 1 to Items.Count do
    Items[i - 1] := Hilight(Items[i - 1],HiText,'hi',DoCase);
  EndUpdate;
end;

procedure THTMListBox.MarkInItem(Index: Integer; HiText: string;
  DoCase: Boolean);
begin
  Items[Index] := Hilight(Items[Index],HiText,'e',DoCase);
end;

procedure THTMListBox.MarkInList(HiText: string; DoCase: Boolean);
var
  i: Integer;
begin
  BeginUpdate;
  for i := 1 to Items.Count do
    Items[i - 1] := Hilight(Items[i - 1],HiText,'e',DoCase);
  EndUpdate;
end;

procedure THTMListBox.UnHilightInItem(Index: Integer);
begin
  Items[Index] := UnHilight(Items[Index],'hi');
end;

procedure THTMListBox.UnHilightInList;
var
  i: Integer;
begin
  BeginUpdate;
  for i := 1 to Items.Count do
    Items[i - 1] := UnHilight(Items[i - 1],'hi');
  EndUpdate;
end;

procedure THTMListBox.UnMarkInItem(Index: Integer);
begin
  Items[Index] := UnHilight(Items[Index],'e');
end;

procedure THTMListBox.UnMarkInList;
var
  i: Integer;
begin
  BeginUpdate;
  for i := 1 to Items.Count do
    Items[i - 1] := UnHilight(Items[i - 1],'e');
  EndUpdate;
end;

procedure THTMListBox.SetSelectionColors(const Value: TGradientStyle);
begin
  FSelectionColors.Assign(Value);
end;

procedure THTMListBox.SetLineSpacing(const Value: Integer);
begin
  if (FLineSpacing <> Value) then
  begin
    FLineSpacing := Value;
    Remeasure;
    Invalidate;
  end;
end;

function THTMListBox.GetItemHeight: integer;
begin
  result := inherited ItemHeight;
end;

procedure THTMListBox.SetItemHeight(const value: integer);
begin
  inherited ItemHeight := value;

  if not FAutoItemHeight then
    Remeasure;
end;


function THTMListBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function THTMListBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure THTMListBox.SetVersion(const Value: string);
begin

end;

end.
