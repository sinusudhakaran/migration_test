{***************************************************************************}
{ TAdvShapeButton component                                                 }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2006                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvShapeButton;

{$I TMSDEFS.INC}

interface

uses
  Classes, Windows, Forms, Dialogs, Controls, Graphics, Messages, ExtCtrls,
  SysUtils, Math, GDIPicture, ActnList, AdvHintInfo, AdvPreviewMenu, AdvGlowButton;

const

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 1; // Build nr.

  // version history:
  // 1.0.0.0 : first release
  // 1.0.0.1 : fixed issue with menu positioning on multimonitor screens

type
  TAdvCustomShapeButton = class;
  TInternalAdvPreviewMenu = class(TAdvPreviewMenu);
  
  TAdvToolButtonStyle = (tasButton, tasCheck);
  TAdvButtonState = (absUp, absDisabled, absDown, absDropDown, absExclusive);

{$IFDEF DELPHI6_LVL}
  TAdvShapeButtonActionLink = class(TControlActionLink)
  protected
    FClient: TAdvCustomShapeButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    function IsGroupIndexLinked: Boolean; override;
    procedure SetGroupIndex(Value: Integer); override;
    procedure SetChecked(Value: Boolean); override;
  end;
{$ENDIF}

  TAdvCustomShapeButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
    FDown: Boolean;
    FAllowAllUp: Boolean;
    FOffSet: integer;
    FMouseInControl: Boolean;
    FHot: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FStyle: TAdvToolButtonStyle;
    FState: TAdvButtonState;
    FMouseDownInControl: Boolean;
    FGrouped: Boolean;
    FDragging: Boolean;
    FPropHot: Boolean;
    FUnHotTimer: TTimer;
    FInitialDown: Boolean;
    FOfficeHint: TAdvHintInfo;
    FIPictureDown: TGDIPPicture;
    FIPictureDisabled: TGDIPPicture;
    FIPicture: TGDIPPicture;
    FIPictureHot: TGDIPPicture;
    FAdvPreviewMenu: TAdvPreviewMenu;
    FShortCutHint: TShortCutHintWindow;
    FShortCutHintPos: TShortCutHintPos;
    FShortCutHintText: string;
    FPreviewMenuOffSet: Integer;
    procedure UnHotTimerOnTime(Sender: TObject);
    procedure UpdateExclusive;
    procedure UpdateTracking;

    procedure ButtonDown;

    procedure OnPictureChanged(Sender: TObject);
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
{$IFNDEF TMSDOTNET}
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
{$ENDIF}
    procedure ShapePaint(Sender: TObject; Canvas: TCanvas; R: TRect);
    procedure OnPreviewMenuHide(Sender: TObject);
    procedure SetDown(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetStyle(const Value: TAdvToolButtonStyle);
    procedure SetState(const Value: TAdvButtonState);
    procedure SetGrouped(const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetHot: Boolean;
    procedure SetHot(const Value: Boolean);
    procedure SetOfficeHint(const Value: TAdvHintInfo);
    procedure SetIPicture(const Value: TGDIPPicture);
    procedure SetIPictureDisabled(const Value: TGDIPPicture);
    procedure SetIPictureDown(const Value: TGDIPPicture);
    procedure SetIPictureHot(const Value: TGDIPPicture);
    procedure SetAdvPreviewMenu(const Value: TAdvPreviewMenu);
  protected
    procedure SetParent(AParent: TWinControl); override;
{$IFDEF DELPHI6_LVL}
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
{$ENDIF}
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrawButton(ACanvas: TCanvas); virtual;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;

    procedure InvalidateMe;
    property MouseInControl: Boolean read FMouseInControl;
    property State: TAdvButtonState read FState write SetState;

    // published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;

    property Constraints;
    property Grouped: Boolean read FGrouped write SetGrouped default False;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property Enabled;
    property Font;
    property Hot: Boolean read GetHot write SetHot default false;

    property Picture: TGDIPPicture read FIPicture write SetIPicture;
    property PictureHot: TGDIPPicture read FIPictureHot write SetIPictureHot;
    property PictureDown: TGDIPPicture read FIPictureDown write SetIPictureDown;
    property PictureDisabled: TGDIPPicture read FIPictureDisabled write SetIPictureDisabled;

    property AdvPreviewMenu: TAdvPreviewMenu read FAdvPreviewMenu write SetAdvPreviewMenu;

    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property OfficeHint: TAdvHintInfo read FOfficeHint write SetOfficeHint;
    property Style: TAdvToolButtonStyle read FStyle write SetStyle default tasButton;
    property ShortCutHint: string read FShortCutHintText write FShortCutHintText;
    property ShortCutHintPos: TShortCutHintPos read FShortCutHintPos write FShortCutHintPos default shpTop;
    property Version: string read GetVersion write SetVersion;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
{$IFDEF TMSDOTNET}
    procedure ButtonPressed(Group: Integer; Button: TAdvCustomShapeButton);
{$ENDIF}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function GetVersionNr: Integer; virtual;

    procedure ShowShortCutHint;
    procedure HideShortCutHint;
  end;

  TAdvShapeButton = class(TAdvCustomShapeButton)
  public
  published
    property Action;
    property AdvPreviewMenu;
    property AllowAllUp;
    property Constraints;
    property GroupIndex;
    property Down;
    property Enabled;
    property Font;
    property Picture;
    property PictureHot;
    property PictureDown;
    property PictureDisabled;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property OfficeHint;
    property ShortCutHint;
    property ShortCutHintPos;
    property Style;
    property Version;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;



implementation

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}

{ TAdvShapeButtonActionLink }

procedure TAdvShapeButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TAdvCustomShapeButton;
end;

//------------------------------------------------------------------------------

function TAdvShapeButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked {and (FClient.GroupIndex <> 0) and
    FClient.AllowAllUp} and (FClient.Down = (Action as TCustomAction).Checked);
end;

//------------------------------------------------------------------------------

function TAdvShapeButtonActionLink.IsGroupIndexLinked: Boolean;
begin
  Result := (FClient is TAdvCustomShapeButton) and
    (TAdvCustomShapeButton(FClient).GroupIndex = (Action as TCustomAction).GroupIndex);
end;

//------------------------------------------------------------------------------

procedure TAdvShapeButtonActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then TAdvCustomShapeButton(FClient).Down := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvShapeButtonActionLink.SetGroupIndex(Value: Integer);
begin
  if IsGroupIndexLinked then TAdvCustomShapeButton(FClient).GroupIndex := Value;
end;

{$ENDIF}

//------------------------------------------------------------------------------

{ TAdvCustomShapeButton }

constructor TAdvCustomShapeButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIPicture := TGDIPPicture.Create;
  FIPicture.OnChange := OnPictureChanged;

  FIPictureHot := TGDIPPicture.Create;
  FIPictureDown := TGDIPPicture.Create;

  FIPictureDisabled := TGDIPPicture.Create;
  FIPictureDisabled.OnChange := OnPictureChanged;

  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;

  // make sure to use a Truetype font
  Font.Name := 'Tahoma';

  FOffSet := 4;

  FStyle := tasButton;
  FGroupIndex := 0;
  FGrouped := true;

  FUnHotTimer := TTimer.Create(self);
  FUnHotTimer.Interval := 1;
  FUnHotTimer.Enabled := false;
  FUnHotTimer.OnTimer := UnHotTimerOnTime;

  FOfficeHint := TAdvHintInfo.Create;
  FShortCutHint := nil;
  FShortCutHintPos := shpTop;
  FShortCutHintText := '';

  ShowHint := False;
  //Width := 32;
  //Height := 32;
end;

//------------------------------------------------------------------------------

destructor TAdvCustomShapeButton.Destroy;
begin
  if Assigned(FShortCutHint) then
    FShortCutHint.Free;
  FIPicture.Free;
  FIPictureHot.Free;
  FIPictureDown.Free;
  FIPictureDisabled.Free;
  FUnHotTimer.Free;
  FOfficeHint.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMDialogChar(var Message: TCMDialogChar);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := true;
  if Enabled then
  begin
    //if Assigned(FAdvToolBar) then
    begin
      //Hot := True;
    end;
    InvalidateMe;
  end;
  FUnHotTimer.Enabled := True;

  if Assigned(FOnMouseEnter) then
     FOnMouseEnter(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if (csDesigning in ComponentState) then
    exit;

  FUnHotTimer.Enabled := False;
  FMouseInControl := false;
  FHot := false;

  //if Assigned(FAdvToolBar) then
    //if not (FAdvToolBar.FInMenuLoop and FAdvToolBar.FMenuFocused) then
      //Hot := False;

  if Enabled then
    InvalidateMe;

  if Assigned(FOnMouseLeave) then
     FOnMouseLeave(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMSysColorChange(var Message: TMessage);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Loaded;
begin
  inherited;

  if (Down <> FInitialDown) then
    Down := FInitialDown;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if (Button <> mbLeft) or not Enabled or (csDesigning in ComponentState) then
    Exit;

  FMouseDownInControl := true;

  ButtonDown;

  if not FDown then
  begin
    FState := absDown;
    Invalidate;
  end;

  if Style = tasCheck then
  begin
    FState := absDown;
    Repaint;
  end;

  FDragging := True;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseMove(Shift: TShiftState; X,
  Y: Integer);
var
  NewState: TAdvButtonState;
begin
  inherited;

  if (csDesigning in ComponentState) then
    Exit;

  if FDragging then
  begin
    if (not FDown) then NewState := absUp
    else NewState := absExclusive;

    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := absExclusive else NewState := absDown;

    if (Style = tasCheck) and FDown then
    begin
      NewState := absDown;
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

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited;

  if (csDesigning in ComponentState) then
    exit;

  FMouseDownInControl := false;
  InvalidateMe;

  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      // Redraw face in-case mouse is captured
      FState := absUp;
      FMouseInControl := False;
      FHot := false;

      if Style = tasCheck then
      begin
        SetDown(not FDown);
        FState := absUp;
      end;

      if DoClick and not (FState in [absExclusive, absDown]) then
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
          FState := absExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if not (csDestroying in ComponentState) and (AOperation = opRemove) then
  begin
    if (AComponent = AdvPreviewMenu) then
      AdvPreviewMenu := nil;
  end;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WndProc(var Message: TMessage);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Paint;
begin
  if not Enabled then
  begin
    FState := absDisabled;
    FDragging := False;
  end
  else
  begin
    if (FState = absDisabled) then
      if FDown and (GroupIndex <> 0) then
        FState := absExclusive
      else
        FState := absUp;
  end;

  if (Style = tasCheck) and (Down) then
  begin
    FState := absDown;
  end;

  inherited;

  DrawButton(Canvas);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.DrawButton(ACanvas: TCanvas);
var
  Pic: TGDIPPicture;
  x, y: Integer;
begin
  Pic := Picture;
  if not Enabled and not PictureDisabled.Empty then
    Pic := PictureDisabled
  else if ((FMouseDownInControl and FMouseInControl) or (Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) and not PictureDown.Empty then
    Pic := PictureDown
  else if FMouseInControl and not PictureHot.Empty then
    Pic := PictureHot;

  if Assigned(Pic) and not Pic.Empty then
  begin
    Pic.GetImageSizes;
    x := (Width - Pic.Width) div 2;
    y := (Height - Pic.Height) div 2;

    ACanvas.Draw(x, y, Pic);
  end
  else
  begin
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := clBlue;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(ClientRect);
  end;
end;

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}

procedure TAdvCustomShapeButton.UpdateExclusive;
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

    {if Assigned(FAdvToolBar) and not (Parent is TAdvCustomToolBar) then
      FAdvToolBar.Broadcast(Msg)
    else if Assigned(AdvToolBar) and (Parent is TAdvCustomToolBar) and Assigned(AdvToolBar.FOptionWindowPanel) then
      FAdvToolBar.FOptionWindowPanel.Broadcast(Msg);}
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF TMSDOTNET}

procedure TAdvCustomShapeButton.ButtonPressed(Group: Integer; Button: TAdvCustomShapeButton);
begin
  if (Group = FGroupIndex) and (Button <> Self) then
  begin
    if Button.Down and FDown then
    begin
      FDown := False;
      FState := absUp;
      if (Action is TCustomAction) then
        TCustomAction(Action).Checked := False;
      Invalidate;
    end;
    FAllowAllUp := Button.AllowAllUp;
  end;
end;

procedure TAdvCustomShapeButton.UpdateExclusive;
var
  I: Integer;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    for I := 0 to Parent.ControlCount - 1 do
      if Parent.Controls[I] is TSpeedButton then
        TAdvToolButton(Parent.Controls[I]).ButtonPressed(FGroupIndex, Self);
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.UpdateTracking;
var
  P: TPoint;
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

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetDown(Value: Boolean);
begin
  if (csLoading in ComponentState) then
    FInitialDown := Value;

  if (FGroupIndex = 0) and (Style = tasButton) then
    Value := False;

  if (Style = tasCheck) then
  begin
    FDown := Value;
    if FDown then
      FState := absDown
    else
      FState := absUp;
    Repaint;
    Exit;
  end;

  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = absUp then Invalidate;
      FState := absExclusive
    end
    else
    begin
      FState := absUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetState(const Value: TAdvButtonState);
begin
  if FState <> Value then
  begin
    FState := Value;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetStyle(const Value: TAdvToolButtonStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.InvalidateMe;
begin
  invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetGrouped(const Value: Boolean);
begin
  FGrouped := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ButtonDown;
begin
  //State:= absDown;
//InvalidateMe;
end;

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}

procedure TAdvCustomShapeButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TAdvCustomShapeButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TAdvCustomShapeButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := absUp;
        if (Action is TCustomAction) then
          TCustomAction(Action).Checked := False;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}

procedure TAdvCustomShapeButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if CheckDefaults or (Self.GroupIndex = 0) then
        Self.GroupIndex := GroupIndex;
      //Self.ImageIndex := ImageIndex;
    end;
end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TAdvShapeButtonActionLink;
end;
{$ENDIF}

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetHot: Boolean;
begin
  Result := FPropHot;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetHot(const Value: Boolean);
var
  OldV: Boolean;
begin
  OldV := FPropHot;
  FPropHot := Value;
  if (State <> absUp) then
    FPropHot := false;

  {if Assigned(FAdvToolBar) then
    FAdvToolBar.UpdateButtonHot(self)
  else }
    FPropHot := false;
  if OldV <> FPropHot then
    InvalidateMe;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.UnHotTimerOnTime(Sender: TObject);
var
  CurP: TPoint;
begin
  GetCursorPos(CurP);
  CurP := ScreenToClient(CurP);
  if (not PtInRect(ClientRect, CurP)) then
  begin
    FUnHotTimer.Enabled := False;
    FMouseInControl := false;
    FHot := false;

    {if Assigned(FAdvToolBar) then
      if not (FAdvToolBar.FInMenuLoop and FAdvToolBar.FMenuFocused) then
        Hot := False; }

    if Enabled then
      InvalidateMe;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetParent(AParent: TWinControl);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetOfficeHint(const Value: TAdvHintInfo);
begin
  FOfficeHint.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPicture(const Value: TGDIPPicture);
begin
  FIPicture.Assign(Value);
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureDisabled(const Value: TGDIPPicture);
begin
  FIPictureDisabled.Assign(Value);
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureDown(const Value: TGDIPPicture);
begin
  FIPictureDown.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureHot(const Value: TGDIPPicture);
begin
  FIPictureHot.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.OnPictureChanged(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAdvPreviewMenu(
  const Value: TAdvPreviewMenu);
begin
  if (FAdvPreviewMenu <> nil) then
  begin
    FAdvPreviewMenu.OnDrawButtonFrameTop := nil;
    TInternalAdvPreviewMenu(AdvPreviewMenu).OnPreviewHide := nil;
  end;

  FAdvPreviewMenu := Value;

  if Assigned(FAdvPreviewMenu) then
  begin
    FAdvPreviewMenu.OnDrawButtonFrameTop := ShapePaint;
    TInternalAdvPreviewMenu(AdvPreviewMenu).OnPreviewHide := OnPreviewMenuHide;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Click;
var
  Pt: TPoint;
  DoShowMenuHint: Boolean;
  W, H: Integer;
  R: TRect;
begin
  DoShowMenuHint := Assigned(FShortCutHint) and FShortCutHint.Visible;
  inherited;
  if Assigned(AdvPreviewMenu) then
  begin
    W := 0;
    H := 0;
    FPreviewMenuOffSet := 0;
    TInternalAdvPreviewMenu(AdvPreviewMenu).GetMenuSize(W, H);

    Pt.X := 0;
    Pt.Y := Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight+2;
    pt := ClientToScreen(pt);

    {$IFDEF DELPHI7_LVL}
    r := Screen.MonitorFromPoint(pt).WorkareaRect;
    {$ELSE}
    SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
    {$ENDIF}
    
    pt.X := pt.X - 3;

    if (pt.X + w) > R.Right then
    begin
      FPreviewMenuOffSet := (R.Right - (pt.X + w));
      pt.X := pt.X + FPreviewMenuOffSet; {-ve vlaue}
      FAdvPreviewMenu.OnDrawButtonFrameTop := ShapePaint;
    end;

    AdvPreviewMenu.ShowMenu(Pt.X, Pt.Y);
    if DoShowMenuHint then
      AdvPreviewMenu.ShowShortCutHints;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ShapePaint(Sender: TObject;
  Canvas: TCanvas; R: TRect);
var
  Pic: TGDIPPicture;
  x, y: Integer;
begin
  Pic := Picture;
  if not Enabled and not PictureDisabled.Empty then
    Pic := PictureDisabled
  else if ((FMouseDownInControl and FMouseInControl) or (Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) and not PictureDown.Empty then
    Pic := PictureDown
  else if FMouseInControl and not PictureHot.Empty then
    Pic := PictureHot;

  if Assigned(Pic) and not Pic.Empty then
  begin
    Pic.GetImageSizes;
    x := (Width - Pic.Width) div 2;
    y := (Height - Pic.Height) div 2;

    x := x - FPreviewMenuOffSet;
    Canvas.Draw(R.Left + 3+x, R.top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight+2 - y), Pic);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.OnPreviewMenuHide(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.HideShortCutHint;
begin
  if Assigned(FShortCutHint) then
  begin
    FShortCutHint.Visible := false;
    FShortCutHint.Free;
    FShortCutHint := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ShowShortCutHint;
var
  pt: TPoint;
begin
  if not Assigned(Parent) then
    Exit;

  if not Assigned(FShortCutHint) then
  begin
    FShortCutHint := TShortCutHintWindow.Create(Self);
    FShortCutHint.Visible := False;
    FShortCutHint.Parent := nil;
    FShortCutHint.ParentWindow := Parent.Handle;
  end;

  FShortCutHint.Caption := FShortCutHintText;

  pt := ClientToScreen(Point(0,0));

  case ShortCutHintPos of
  shpLeft:
    begin
      FShortCutHint.Left := pt.X - (FShortCutHint.Width div 2);
      FShortCutHint.Top := pt.Y + (self.Height - FShortCutHint.Height) div 2;
    end;
  shpTop:
    begin
      FShortCutHint.Left := pt.X + (self.Width - FShortCutHint.Width) div 2;
      FShortCutHint.Top := pt.Y - (FShortCutHint.Height div 2);
    end;
  shpRight:
    begin
      FShortCutHint.Left := pt.X + self.Width - (FShortCutHint.Width div 2);
      FShortCutHint.Top := pt.Y + (self.Height - FShortCutHint.Height) div 2;
    end;
  shpBottom:
    begin
      FShortCutHint.Left := pt.X + (self.Width - FShortCutHint.Width) div 2;
      FShortCutHint.Top := pt.Y + self.Height - (FShortCutHint.Height div 2);
    end;
  end;

  FShortCutHint.Visible := true;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMHintShow(var Message: TMessage);
begin
  if (Message.WParam = 1) then
  begin
    if (Message.LParam = 0) then
    //if Assigned(FShortCutHint) and FShortCutHint.Visible then
    begin
      HideShortCutHint;
    end
    else if (Message.LParam = 1) then
    begin
      ShowShortCutHint;
    end;
    Message.Result := 1;
  end;

  inherited;
end;

//------------------------------------------------------------------------------

end.
