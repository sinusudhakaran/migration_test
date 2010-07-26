{===============================================================================
  RzAnimtr Unit

  Raize Components - Component Source Unit

  Copyright © 1995-2007 by Raize Software, Inc.  All Rights Reserved.


  Components
  ------------------------------------------------------------------------------
  TRzAnimator
    Cycles through images in a ImageList


  Modification History
  ------------------------------------------------------------------------------
  4.0    (23 Dec 2005)
    * Added DelayUntilRepeat property to TRzAnimator. This property controls the
      amount of time (in milliseconds) that pass before the animation repeats.
  ------------------------------------------------------------------------------
  3.0.13 (15 May 2005)
    * Added OnFrameChange event to TRzAnimator.  This event fires when a new
      image is drawn during the animation.
  ------------------------------------------------------------------------------
  3.0    (20 Dec 2002)
    * Cleaned-up image list code.
    * Changed ImageList to type TCustomImageList.
    * Added TChangeLink reference.
    * Added Transparent property.
===============================================================================}

{$I RzComps.inc}

unit RzAnimtr;

interface

uses
  {$IFDEF USE_CS}
  CodeSiteLogging,
  {$ENDIF}
  {&RF}
  Messages,
  Windows,
  Classes,
  Controls,
  Graphics,
  SysUtils,
  ExtCtrls,
  ImgList,
  RzCommon;

type
  TRzAnimatorFrameChangeEvent = procedure( Sender: TObject; Frame: Integer ) of object;

  TRzAnimator = class( TCustomControl )
  private
    FAboutInfo: TRzAboutInfo;
    FAnimate: Boolean;
    FDelay: Word;
    FDelayUntilRepeat: Word;
    FLastImageIndex: TImageIndex;
    FImageIndex: TImageIndex;
    FImageList: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FBitmap: TBitmap;
    FTimer: TTimer;
    FTransparent: Boolean;

    FOnFrameChange: TRzAnimatorFrameChangeEvent;

    { Internal Event Handlers }
    procedure TimerExpired( Sender: TObject );
    procedure ImageListChange( Sender: TObject );

    { Message Handling Methods }
    procedure WMSize( var Msg: TWMSize ); message wm_Size;
  protected
    procedure Notification( AComponent: TComponent; Operation: TOperation ); override;
    procedure DrawImage; virtual;
    procedure Paint; override;

    procedure FrameChange( Frame: Integer ); dynamic;

    { Property Access Methods }
    procedure SetAnimate( Value: Boolean ); virtual;
    procedure SetDelay( Value: Word ); virtual;
    procedure SetImageIndex( Value: TImageIndex ); virtual;
    procedure SetImageList( Value: TCustomImageList ); virtual;
    procedure SetTransparent( Value: Boolean ); virtual;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
  published
    property About: TRzAboutInfo
      read FAboutInfo
      write FAboutInfo
      stored False;

    property Animate: Boolean
      read FAnimate
      write SetAnimate
      default True;

    property Delay: Word
      read FDelay
      write SetDelay
      default 100;

    property DelayUntilRepeat: Word
      read FDelayUntilRepeat
      write FDelayUntilRepeat
      default 100;

    property ImageIndex: TImageIndex
      read FImageIndex
      write SetImageIndex
      default 0;

    property ImageList: TCustomImageList
      read FImageList
      write SetImageList;

    property Transparent: Boolean
      read FTransparent
      write SetTransparent
      default False;

    property OnFrameChange: TRzAnimatorFrameChangeEvent
      read FOnFrameChange
      write FOnFrameChange;

    { Inherited Properties & Events }
    property Color;
    property OnClick;
    property OnDblClick;
    property OnContextPopup;
  end;


implementation


uses
  RzGrafx;

{&RT}
{=========================}
{== TRzAnimator Methods ==}
{=========================}

constructor TRzAnimator.Create( AOwner: TComponent );
begin
  inherited;
  Height := 40;
  Width := 40;
  FAnimate := True;
  FLastImageIndex := -1;
  FImageIndex := 0;
  FDelay := 100;                                            { 100 milliseconds }
  FDelayUntilRepeat := 100;

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;

  FBitmap := TBitmap.Create;
  FTimer := TTimer.Create( Self );
  FTimer.Interval := FDelay;
  FTimer.Enabled := True;
  FTimer.OnTimer := TimerExpired;
  {&RCI}
end;


destructor TRzAnimator.Destroy;
begin
  FBitmap.Free;
  FTimer.Free;
  FImageChangeLink.Free;
  inherited;
end;


procedure TRzAnimator.Notification( AComponent: TComponent; Operation: TOperation );
begin
  inherited;

  if ( Operation = opRemove ) and ( AComponent = FImageList ) then
    SetImageList( nil )  // Call access method so connections to link object can be cleared
end;


procedure TRzAnimator.DrawImage;
var
  R: TRect;
begin
  FBitmap.Height := FImageList.Height;
  FBitmap.Width := FImageList.Width;

  if FTransparent then
  begin
    DrawParentImage( Self, FBitmap.Canvas );
    Sleep( 10 );  { Need to allow short time to get image }
  end
  else
  begin
    FBitmap.Canvas.Brush.Color := Color;
    R := Rect( 0, 0, FBitmap.Width + 1, FBitmap.Height + 1 );
    FBitmap.Canvas.FillRect( R );
  end;

  FImageList.GetBitmap( FImageIndex, FBitmap );
  Canvas.Draw( 0, 0, FBitmap );

  if FLastImageIndex <> FImageIndex then
    FrameChange( FImageIndex );
  FLastImageIndex := FImageIndex;
end;


procedure TRzAnimator.FrameChange( Frame: Integer );
begin
  if Assigned( FOnFrameChange ) then
    FOnFrameChange( Self, Frame );
end;


procedure TRzAnimator.Paint;
begin
  inherited;

  if csDesigning in ComponentState then
  begin
    if not FAnimate and ( FImageList <> nil ) and ( FImageList.Count > 0 ) then
      FImageList.Draw( Canvas, 0, 0, FImageIndex );

    Canvas.Pen.Style := psDot;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle( ClientRect );
  end
  else if FImageList <> nil then
  begin
    DrawImage;
  end;
end; {= TRzAnimator.Paint =}


procedure TRzAnimator.TimerExpired( Sender: TObject );
begin
  if FImageList <> nil then
  begin
    try
      FTimer.Interval := FDelay;
      if FImageIndex >= FImageList.Count then
        FImageIndex := 0;

      DrawImage;

      Inc( FImageIndex );
      if FImageIndex = FImageList.Count then
      begin
        FImageIndex := 0;
        FTimer.Interval := FDelayUntilRepeat;
      end;
    except
      Animate := False;
      raise;
    end;
  end;
end;


procedure TRzAnimator.SetAnimate( Value: Boolean );
begin
  if FAnimate <> Value then
  begin
    FAnimate := Value;
    FTimer.Enabled := FAnimate;
  end;
  {&RV}
end;


procedure TRzAnimator.SetDelay( Value: Word );
begin
  if FDelay <> Value then
  begin
    FDelay := Value;
    FTimer.Interval := FDelay;
  end;
end;


procedure TRzAnimator.SetImageIndex( Value: TImageIndex );
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Invalidate;
  end;
end;


procedure TRzAnimator.SetImageList( Value: TCustomImageList );
begin
  if FImageList <> nil then
    FImageList.UnRegisterChanges( FImageChangeLink );

  FImageList := Value;

  if FImageList <> nil then
  begin
    FImageList.RegisterChanges( FImageChangeLink );
    FImageList.FreeNotification( Self );
    Width := FImageList.Width;
    Height := FImageList.Height;
  end;
  Invalidate;
end;


procedure TRzAnimator.ImageListChange( Sender: TObject );
begin
  if Sender = ImageList then
  begin
    Update;         // Call Update instead of Invalidate to prevent flicker
  end;
end;


procedure TRzAnimator.SetTransparent( Value: Boolean );
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;


procedure TRzAnimator.WMSize( var Msg: TWMSize );
begin
  inherited;

  if FImageList <> nil then
  begin
    Width := FImageList.Width;
    Height := FImageList.Height;
  end;
end;



{&RUIF}
end.
