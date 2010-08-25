{*********************************************************}
{*                   OVCURL.PAS 4.05                     *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

(*Changes)
{!!.03}
  01/23/02 - Added UnderlineURL property.
*)


{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovcurl;
  {-URL label}

interface

uses
  Windows, Classes, Controls, Dialogs, ExtCtrls, Graphics, Menus, ShellAPI,
  Messages, StdCtrls, SysUtils, OvcVer;

type
  TOvcURL = class(TCustomLabel)
  protected {private}
    FCaption         : string;
    FHighlightColor  : TColor;
    FURL             : string;
    FUseVisitedColor : Boolean;
    FVisitedColor    : TColor;

    {internal variables}
    urlTimer         : TTimer;
    urlFontColor     : TColor;

    {property methods}
    function GetAbout : string;
    function GetUnderlineURL: Boolean;                                {!!.03}
    procedure SetAbout(const Value : string);
    procedure SetCaption(const Value : string);
    procedure SetHighlightColor(const Value : TColor);
    procedure SetUnderlineURL(Value: Boolean);                        {!!.03}
    procedure SetURL(const Value : string);
    procedure SetVisitedColor(const Value : TColor);

    {internal methods}
    procedure TimerEvent(Sender : TObject);

    procedure Loaded; override;

  protected
    procedure MouseMove(Shift : TShiftState; X, Y : Integer);
      override;

  public
    procedure Click;
      override;
    constructor Create(AOwner : TComponent);
      override;
    destructor Destroy;
      override;

  published
    property About : string
      read GetAbout write SetAbout stored False;
    property Caption : string
      read FCaption write SetCaption;
    property HighlightColor : TColor
      read FHighlightColor write SetHighlightColor
      default clRed;                                                   {!!.05}
    property UnderlineURL: Boolean                                    {!!.03}
      read GetUnderlineURL write SetUnderlineURL                      {!!.03}
      stored False;                                                    {!!.05}
    property URL : string
      read FURL write SetURL;
    property UseVisitedColor : Boolean
      read FUseVisitedColor write FUseVisitedColor
      default False;                                                   {!!.05}
    property VisitedColor : TColor
      read FVisitedColor write SetVisitedColor
      stored FUseVisitedColor                                          {!!.05}
      default clBlack;                                                 {!!.05}

    {$IFDEF VERSION4}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property Cursor default crHandPoint;
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
    property Transparent default False;                               {!!.05}
    property Layout;
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
    property OnStartDrag;
  end;

implementation

{$IFDEF TRIALRUN}
uses OrTrial;
{$I ORTRIALF.INC}
{$ENDIF}

const
  BadColor = $02000000;

{*** TOvcURL ***}
procedure TOvcURL.Loaded;
begin
  inherited Loaded;

//  Font.Style := Font.Style + [fsUnderline];                         {!!.03}
  urlFontColor := BadColor;
end;

procedure TOvcURL.Click;
var
  Buf : array[0..1023] of Char;
begin
  if URL > '' then begin
    StrPLCopy(Buf, URL, SizeOf(Buf)-1);
    if ShellExecute(0, 'open', Buf, '', '', SW_SHOWNORMAL) <= 32 then
      MessageBeep(0);
  end;

  inherited Click;

  {change color to visited color if enabled}
  if FUseVisitedColor then
    urlFontColor := FVisitedColor;
end;

constructor TOvcURL.Create(AOwner : TComponent);
{$IFDEF TRIALRUN}
var
  X : Integer;
{$ENDIF}
begin
  inherited Create(AOwner);
  FHighlightColor := clRed;
  Cursor := crHandPoint;
  Font.Style := Font.Style + [fsUnderline];                           {!!.03}
{$IFDEF TRIALRUN}
  X := _CC_;
  if (X < ccRangeLow) or (X > ccRangeHigh) then Halt;
  X := _VC_;
  if (X < ccRangeLow) or (X > ccRangeHigh) then Halt;
{$ENDIF}
end;

destructor TOvcURL.Destroy;
begin
  if Assigned(urlTimer) then begin
    urlTimer.Free;
    urlTimer := nil;
  end;

  inherited Destroy;
end;

function TOvcURL.GetAbout : string;
begin
  Result := OrVersionStr;
end;

function TOvcURL.GetUnderlineURL: Boolean;
begin
  result := fsUnderline in Font.Style;
end;

procedure TOvcURL.MouseMove(Shift : TShiftState; X, Y : Integer);
begin
  inherited MouseMove(Shift, X, Y);

  if PtInRect(ClientRect, Point(X, Y)) then begin
    if not Assigned(urlTimer) then begin
      {save current font color}
      if urlFontColor = BadColor then
        urlFontColor := Font.Color;
      Font.Color := FHighlightColor;
      urlTimer := TTimer.Create(Self);
      urlTimer.Interval := 100;
      urlTimer.OnTimer := TimerEvent;
      urlTimer.Enabled := True;
    end;
  end;
end;

procedure TOvcURL.SetAbout(const Value : string);
begin
end;

procedure TOvcURL.SetCaption(const Value : string);
begin
  FCaption := Value;
  if FCaption > '' then
    inherited Caption := FCaption
  else
    inherited Caption := URL;
end;

procedure TOvcURL.SetHighlightColor(const Value: TColor);
begin
  if Value = clNone then
    FHighlightColor := Font.Color
  else
    FHighlightColor := Value;

  {reset stored color}
  urlFontColor := BadColor;
end;

{!!.03 - added}
procedure TOvcURL.SetUnderlineURL(Value: Boolean);
begin
  if Value then
    Font.Style := Font.Style + [fsUnderline]
  else
    Font.Style := Font.Style - [fsUnderline];
end;

procedure TOvcURL.SetURL(const Value : string);
begin
  FURL := Value;
  if FCaption = '' then
    inherited Caption := URL;
end;
       
procedure TOvcURL.SetVisitedColor(const Value : TColor);
begin
  if Value = clNone then
    FVisitedColor := Font.Color
  else
    FVisitedColor := Value;

  {reset stored color}
  urlFontColor := BadColor;
end;

procedure TOvcURL.TimerEvent(Sender : TObject);
var
  Pt : TPoint;
begin
  GetCursorPos(Pt);
  Pt := ScreentoClient(Pt);
  if not PtInRect(ClientRect, Pt) then begin
    urlTimer.Free;
    urlTimer := nil;
    Font.Color := urlFontColor;
    Repaint;
  end;
end;

end.
