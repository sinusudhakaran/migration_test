
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressDocking                                              }
{                                                                   }
{       Copyright (c) 2002-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSDOCKING AND ALL ACCOMPANYING  }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.             }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxDockZones;

{$I cxVer.inc}

interface

uses
  Windows, Classes, cxGraphics, dxDockControl, dxDockPanel;

type
  TdxLeftZone = class(TdxZone)
  protected
    function GetDirection: TdxZoneDirection; override;
    function GetDockType: TdxDockingType; override;
    function GetRectangle: TRect; override;

    function CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean; override;
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function GetResizingSelection(pt: TPoint): TRect; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxRightZone = class(TdxZone)
  protected
    function GetDirection: TdxZoneDirection; override;
    function GetDockType: TdxDockingType; override;
    function GetRectangle: TRect; override;

    function CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean; override;
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function GetResizingSelection(pt: TPoint): TRect; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxTopZone = class(TdxZone)
  protected
    function GetDirection: TdxZoneDirection; override;
    function GetDockType: TdxDockingType; override;
    function GetRectangle: TRect; override;

    function CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean; override;
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function GetResizingSelection(pt: TPoint): TRect; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxBottomZone = class(TdxZone)
  protected
    function GetDirection: TdxZoneDirection; override;
    function GetDockType: TdxDockingType; override;
    function GetRectangle: TRect; override;

    function CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean; override;
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function GetResizingSelection(pt: TPoint): TRect; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxClientZone = class(TdxZone)
  protected
    function GetDirection: TdxZoneDirection; override;
    function GetDockType: TdxDockingType; override;
    function GetRectangle: TRect; override;
  public
    constructor Create(AOwner: TdxCustomDockControl; AWidth: Integer);
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxInvisibleClientZone = class(TdxClientZone)
  protected
    function FindTargetDockControlInControl(AControl: TdxCustomDockControl): TdxCustomDockControl;
    function FindTargetDockControl: TdxCustomDockControl;
  public
    function CanDock(AControl: TdxCustomDockControl): Boolean; override;
    procedure DoDock(AControl: TdxCustomDockControl); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxFloatZone = class(TdxClientZone)
  private
    function GetFloatSite: TdxFloatDockSite;
  protected
    function FindTargetDockZone: TdxZone;
  public
    constructor Create(AControl: TdxFloatDockSite);

    function CanDock(AControl: TdxCustomDockControl): Boolean; override;
    procedure DoDock(AControl: TdxCustomDockControl); override;
    procedure DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint); override;
    procedure PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect); override;

    function IsZonePoint(pt: TPoint): Boolean; override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;

    property FloatSite: TdxFloatDockSite read GetFloatSite;
  end;

  TdxAutoHideLeftZone = class(TdxLeftZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoHideRightZone = class(TdxRightZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoHideTopZone = class(TdxTopZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoHideBottomZone = class(TdxBottomZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoSizeLeftZone = class(TdxLeftZone)
  public
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoSizeRightZone = class(TdxRightZone)
  public
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoSizeTopZone = class(TdxTopZone)
  public
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoSizeBottomZone = class(TdxBottomZone)
  public
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxAutoSizeClientZone = class(TdxClientZone)
  public
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function IsZonePoint(pt: TPoint): Boolean; override;
  end;

  TdxInvisibleAutoSizeClientZone = class(TdxInvisibleClientZone)
  public
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; override;
    function IsZonePoint(pt: TPoint): Boolean; override;
  end;

  TdxCustomTabContainerZone = class(TdxClientZone)
  protected
    procedure CorrectTabRects(var ATabsRect, ATabRect: TRect); virtual;
    function GetTabPosition: TdxTabContainerTabsPosition; virtual; abstract;
    function GetTabRect(AControl: TdxCustomDockControl): TRect; virtual; abstract;
    function GetTabsRect: TRect; virtual; abstract;
  public
    procedure PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect); override;
  end;

  TdxTabContainerZone = class(TdxCustomTabContainerZone)
  private
    function GetTabContainer: TdxTabContainerDockSite;
  protected
    procedure CorrectTabRects(var ATabsRect, ATabRect: TRect); override;
    function GetDockIndex: Integer; override;
    function GetTabPosition: TdxTabContainerTabsPosition; override;
    function GetTabRect(AControl: TdxCustomDockControl): TRect; override;
    function GetTabsRect: TRect; override;
  public
    constructor Create(AControl: TdxTabContainerDockSite);
    procedure DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint); override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
    property TabContainer: TdxTabContainerDockSite read GetTabContainer;
  end;

  TdxTabContainerCaptionZone = class(TdxTabContainerZone)
  public
    function IsZonePoint(pt: TPoint): Boolean; override;
  end;

  TdxTabContainerTabZone = class(TdxTabContainerZone)
  private
    FDockIndex: Integer;
  protected
    function GetDockIndex: Integer; override;
  public
    constructor Create(AControl: TdxTabContainerDockSite; ADockIndex: Integer);
    function IsZonePoint(pt: TPoint): Boolean; override;
    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; override;
  end;

  TdxHorizContainerZone = class(TdxRightZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
  end;

  TdxVertContainerZone = class(TdxBottomZone)
  public
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; override;
    procedure DoResize(StartPoint, EndPoint: TPoint); override;
  end;

  TdxDockPanelClientZone = class(TdxCustomTabContainerZone)
  private
    function GetDockPanel: TdxDockPanel;
  protected
    function GetTabPosition: TdxTabContainerTabsPosition; override;
    function GetTabRect(AControl: TdxCustomDockControl): TRect; override;
    function GetTabsRect: TRect; override;
  public
    constructor Create(AControl: TdxDockPanel);
    procedure DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint); override;
    property DockPanel: TdxDockPanel read GetDockPanel;
  end;

  TdxDockPanelCaptionClientZone = class(TdxDockPanelClientZone)
  public
    function IsZonePoint(pt: TPoint): Boolean; override;
  end;

implementation

uses
  dxDockConsts, Forms, Controls, Types, Math, Graphics;

type
  TdxCustomDockControlAccess = class(TdxCustomDockControl);
  TdxTabContainerDockSiteAccess = class(TdxTabContainerDockSite);
  TdxSideContainerDockSiteAccess = class(TdxSideContainerDockSite);
  TdxDockPanelAccess = class(TdxDockPanel);

{ TdxLeftZone }

function TdxLeftZone.GetDirection: TdxZoneDirection;
begin
  Result := zdVertical;
end;

function TdxLeftZone.GetDockType: TdxDockingType;
begin
  Result := dtLeft;
end;

function TdxLeftZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Owner.Width + (StartPoint.X - EndPoint.X);
  NewHeight := Owner.Height;
  Result := (NewWidth > 0) and (NewWidth < Owner.Parent.ClientWidth) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

function TdxLeftZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
begin
  Result := Rect(0, 0, Min(AControl.OriginalWidth, Owner.Width - 2 * SelectionFrameWidth), Owner.Height);
  GetWindowRect(Owner.Handle, R);
  OffsetRect(Result, R.Left, R.Top);
end;

function TdxLeftZone.GetResizingSelection(pt: TPoint): TRect;
var
  R: TRect;
begin
  GetWindowRect(Owner.Handle, R);
  Result.Left := pt.X;
  Result.Right := Result.Left + SelectionFrameWidth;
  Result.Top := R.Top;
  Result.Bottom := R.Bottom;
end;

function TdxLeftZone.GetRectangle: TRect;
var
  AZoneOffset: Integer;
begin
  if (Kind = zkDocking) and
    (doUseCaptionAreaToClientDocking in TdxCustomDockControlAccess(Owner).ControllerOptions) and
    TdxCustomDockControlAccess(Owner).HasCaption and
    TdxCustomDockControlAccess(Owner).IsCaptionVertical then
  begin
    AZoneOffset := TdxCustomDockControlAccess(Owner).Painter.GetCaptionHeight;
    if TdxCustomDockControlAccess(Owner).HasBorder then
      Inc(AZoneOffset, TdxCustomDockControlAccess(Owner).Painter.GetBorderWidths.Left);
  end
  else
    AZoneOffset := 0;
  Result := Rect(AZoneOffset, 0, Width + AZoneOffset, Owner.Height)
end;

function TdxLeftZone.CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := ((Owner.Constraints.MinWidth <= 0) or (NewWidth > Owner.Constraints.MinWidth)) and
    ((Owner.Constraints.MaxWidth <= 0) or (NewWidth < Owner.Constraints.MaxWidth));
end;

procedure TdxLeftZone.DoResize(StartPoint, EndPoint: TPoint);
begin
  Owner.Width := Owner.Width + (StartPoint.X - EndPoint.X);
end;

class function TdxLeftZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := dtLeft in AOwner.AllowDockClients;
  if Result then
    for I := 0 to AControl.DockZones.Count - 1 do
    begin
      AZone := TdxZone(AControl.DockZones.Items[I]);
      if (AZone.DockType = dtLeft) and (AZone.Owner.Height = AOwner.Height) then
      begin
        Result := False;
        Break;
      end;
    end;
end;

class function TdxLeftZone.ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.ParentDockControl <> nil) and (AOwner.DockType = dtRight);
end;

{ TdxRightZone }

function TdxRightZone.GetDirection: TdxZoneDirection;
begin
  Result := zdVertical;
end;

function TdxRightZone.GetDockType: TdxDockingType;
begin
  Result := dtRight;
end;

function TdxRightZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Owner.Width - (StartPoint.X - EndPoint.X);
  NewHeight := Owner.Height;
  Result := (NewWidth > 0) and (Owner.Left + NewWidth < Owner.Parent.ClientWidth) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

function TdxRightZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
begin
  if Owner.Width - AControl.OriginalWidth - 2 * SelectionFrameWidth > 0 then
    Result := Rect(Owner.Width - AControl.OriginalWidth, 0, Owner.Width, Owner.Height)
  else
    Result := Rect(2 * SelectionFrameWidth, 0, Owner.Width, Owner.Height);
  GetWindowRect(Owner.Handle, R);
  OffsetRect(Result, R.Left, R.Top);
end;

function TdxRightZone.GetResizingSelection(pt: TPoint): TRect;
var
  R: TRect;
begin
  GetWindowRect(Owner.Handle, R);
  Result.Right := pt.X;
  Result.Left := Result.Right - SelectionFrameWidth;
  Result.Top := R.Top;
  Result.Bottom := R.Bottom;
end;

class function TdxRightZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := dtRight in AOwner.AllowDockClients;
  if Result then
    for I := 0 to AControl.DockZones.Count - 1 do
    begin
      AZone := TdxZone(AControl.DockZones.Items[I]);
      if (AZone.DockType = dtRight) and (AZone.Owner.Height = AOwner.Height) then
      begin
        Result := False;
        Break;
      end;
    end;
end;

class function TdxRightZone.ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.ParentDockControl <> nil) and (AOwner.DockType = dtLeft);
end;

function TdxRightZone.GetRectangle: TRect;
begin
  Result := Rect(Owner.Width - Width, 0, Owner.Width, Owner.Height)
end;

function TdxRightZone.CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := ((Owner.Constraints.MinWidth <= 0) or (NewWidth > Owner.Constraints.MinWidth)) and
    ((Owner.Constraints.MaxWidth <= 0) or (NewWidth < Owner.Constraints.MaxWidth));
end;

procedure TdxRightZone.DoResize(StartPoint, EndPoint: TPoint);
begin
  Owner.Width := Owner.Width - (StartPoint.X - EndPoint.X);
end;

{ TdxTopZone }

function TdxTopZone.GetDirection: TdxZoneDirection;
begin
  Result := zdHorizontal;
end;

function TdxTopZone.GetDockType: TdxDockingType;
begin
  Result := dtTop;
end;

function TdxTopZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewHeight := Owner.Height + (StartPoint.Y - EndPoint.Y);
  NewWidth := Owner.Width;
  Result := (NewHeight > 0) and (NewHeight < Owner.Parent.ClientHeight) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

function TdxTopZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
begin
  if AControl.OriginalHeight < Owner.Height - 2 * SelectionFrameWidth then
    Result := Rect(0, 0, Owner.Width, AControl.OriginalHeight)
  else
    Result := Rect(0, 0, Owner.Width, Owner.Height - 2 * SelectionFrameWidth);
  GetWindowRect(Owner.Handle, R);
  OffsetRect(Result, R.Left, R.Top);
end;

function TdxTopZone.GetResizingSelection(pt: TPoint): TRect;
var
  R: TRect;
begin
  GetWindowRect(Owner.Handle, R);
  Result.Top := pt.Y;
  Result.Bottom := Result.Top + SelectionFrameWidth;
  Result.Left := R.Left;
  Result.Right := R.Right;
end;

function TdxTopZone.GetRectangle: TRect;
var
  AZoneOffset: Integer;
begin
  if (Kind = zkDocking) and
    (doUseCaptionAreaToClientDocking in TdxCustomDockControlAccess(Owner).ControllerOptions) and
    TdxCustomDockControlAccess(Owner).HasCaption and
    not TdxCustomDockControlAccess(Owner).IsCaptionVertical then
  begin
    AZoneOffset := TdxCustomDockControlAccess(Owner).Painter.GetCaptionHeight;
    if TdxCustomDockControlAccess(Owner).HasBorder then
      Inc(AZoneOffset, TdxCustomDockControlAccess(Owner).Painter.GetBorderWidths.Top);
  end
  else
    AZoneOffset := 0;
  Result := Rect(0, AZoneOffset, Owner.Width, Width + AZoneOffset);
end;

function TdxTopZone.CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := ((Owner.Constraints.MinHeight <= 0) or (NewHeight > Owner.Constraints.MinHeight)) and
    ((Owner.Constraints.MaxHeight <= 0) or (NewHeight < Owner.Constraints.MaxHeight));
end;

procedure TdxTopZone.DoResize(StartPoint, EndPoint: TPoint);
var
  DY: Integer;
begin
  if Owner.Parent <> nil then
  begin
    Owner.Parent.DisableAlign;
    try
      DY := StartPoint.Y - EndPoint.Y;
      Owner.Top := Owner.Top - DY;
      Owner.Height := Owner.Height + DY;
    finally
      Owner.Parent.EnableAlign;
    end;
  end
  else
    Owner.Height := Owner.Height + (StartPoint.Y - EndPoint.Y);
end;

class function TdxTopZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := dtTop in AOwner.AllowDockClients;
  if Result then
    for I := 0 to AControl.DockZones.Count - 1 do
    begin
      AZone := TdxZone(AControl.DockZones.Items[I]);
      if (AZone.DockType = dtTop) and (AZone.Owner.Width = AOwner.Width) then
      begin
        Result := False;
        Break;
      end;
    end;
end;

class function TdxTopZone.ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.ParentDockControl <> nil) and (AOwner.DockType = dtBottom);
end;

{ TdxBottomZone }

function TdxBottomZone.GetDirection: TdxZoneDirection;
begin
  Result := zdHorizontal;
end;

function TdxBottomZone.GetDockType: TdxDockingType;
begin
  Result := dtBottom;
end;

function TdxBottomZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewHeight := Owner.Height - (StartPoint.Y - EndPoint.Y);
  NewWidth := Owner.Width;
  Result := (NewHeight > 0) and (Owner.Top + NewHeight < Owner.Parent.ClientHeight) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

function TdxBottomZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
begin
  if Owner.Height - AControl.OriginalHeight - 2 * SelectionFrameWidth > 0 then
    Result := Rect(0, Owner.Height - AControl.OriginalHeight, Owner.Width, Owner.Height)
  else
    Result := Rect(0, 2 * SelectionFrameWidth, Owner.Width, Owner.Height);
  GetWindowRect(Owner.Handle, R);
  OffsetRect(Result, R.Left, R.Top);
end;

function TdxBottomZone.GetResizingSelection(pt: TPoint): TRect;
var
  R: TRect;
begin
  GetWindowRect(Owner.Handle, R);
  Result.Bottom := pt.Y;
  Result.Top := Result.Bottom - SelectionFrameWidth;
  Result.Left := R.Left;
  Result.Right := R.Right;
end;

function TdxBottomZone.GetRectangle: TRect;
begin
  Result := Rect(0, Owner.Height - Width, Owner.Width, Owner.Height)
end;

function TdxBottomZone.CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := ((Owner.Constraints.MinHeight <= 0) or (NewHeight > Owner.Constraints.MinHeight)) and
    ((Owner.Constraints.MaxHeight <= 0) or (NewHeight < Owner.Constraints.MaxHeight));
end;

procedure TdxBottomZone.DoResize(StartPoint, EndPoint: TPoint);
begin
  Owner.Height := Owner.Height - (StartPoint.Y - EndPoint.Y);
end;

class function TdxBottomZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := dtBottom in AOwner.AllowDockClients;
  if Result then
    for I := 0 to AControl.DockZones.Count - 1 do
    begin
      AZone := TdxZone(AControl.DockZones.Items[I]);
      if (AZone.DockType = dtBottom) and (AZone.Owner.Width = AOwner.Width) then
      begin
        Result := False;
        Break;
      end;
    end;
end;

class function TdxBottomZone.ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.ParentDockControl <> nil) and (AOwner.DockType = dtTop);
end;

{ TdxClientZone }

constructor TdxClientZone.Create(AOwner: TdxCustomDockControl; AWidth: Integer);
begin
  inherited Create(AOwner, AWidth, zkDocking);
end;

function TdxClientZone.GetDirection: TdxZoneDirection;
begin
  Result := zdUndefined;
end;

function TdxClientZone.GetDockType: TdxDockingType;
begin
  Result := dtClient;
end;

function TdxClientZone.GetRectangle: TRect;
begin
  Result := Rect(0, 0, Owner.Width, Owner.Height);
end;

class function TdxClientZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := dtClient in AOwner.AllowDockClients;
  Result := Result and (AOwner = AControl) and (AOwner.ChildCount = 0);
end;

{ TdxInvisibleClientZone }

function TdxInvisibleClientZone.CanDock(AControl: TdxCustomDockControl): Boolean;
var
  ATarget: TdxCustomDockControl;
begin
  ATarget := FindTargetDockControl;
  Result := (ATarget <> nil) and
    (ATarget.CanDockHost(AControl, dtClient) or
    ATarget.CanDockHost(AControl, dtRight) or
    ATarget.CanDockHost(AControl, dtBottom));
end;

procedure TdxInvisibleClientZone.DoDock(AControl: TdxCustomDockControl);
var
  ATarget: TdxCustomDockControl;
begin
  ATarget := FindTargetDockControl;
  if ATarget <> nil then
  begin
    if ATarget.CanDockHost(AControl, dtClient) then
      AControl.DockTo(ATarget, dtClient, -1)
    else
      if ATarget.CanDockHost(AControl, dtRight) then
        AControl.DockTo(ATarget, dtRight, -1)
      else
        if ATarget.CanDockHost(AControl, dtBottom) then
          AControl.DockTo(ATarget, dtBottom, -1);
  end
end;

function TdxInvisibleClientZone.FindTargetDockControlInControl(AControl: TdxCustomDockControl): TdxCustomDockControl;
var
  I: Integer;
begin
  if AControl.ChildCount > 0 then
  begin
    Result := nil;
    for I := 0 to AControl.ChildCount - 1 do
    begin
      if AControl.Children[I].DockType <> dtClient then Continue;
      if (Result = nil) and (AControl.Children[I].CanDock or (AControl.Children[I].ChildCount = 0)) then
        Result := AControl.Children[I]
      else
        if (Result <> nil) and AControl.Children[I].CanDock then
          Result := AControl.Children[I];
    end;
    if (Result <> nil) and not Result.CanDock then
      Result := FindTargetDockControlInControl(Result);
  end
  else
    Result := AControl;
end;

function TdxInvisibleClientZone.FindTargetDockControl: TdxCustomDockControl;
begin
  Result := FindTargetDockControlInControl(Owner);
end;

class function TdxInvisibleClientZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := dtClient in AOwner.AllowDockClients;
  Result := Result and (AOwner = AControl) and (AOwner.ChildCount = 2) and
    not AOwner.IsValidChild(AOwner.Children[0]) and
    not AOwner.IsValidChild(AOwner.Children[1]);
end;

{ TdxFloatZone }

constructor TdxFloatZone.Create(AControl: TdxFloatDockSite);
begin
  inherited Create(AControl, 0);
end;

function TdxFloatZone.CanDock(AControl: TdxCustomDockControl): Boolean;
var
  AZone: TdxZone;
begin
  AZone := FindTargetDockZone;
  if AZone <> nil then
    Result := AZone.CanDock(AControl)
  else
    Result := False;
end;

function TdxFloatZone.IsZonePoint(pt: TPoint): Boolean;
begin
  Result := dxDockingController.GetFloatDockSiteAtPos(pt) = Owner;
end;

function TdxFloatZone.FindTargetDockZone: TdxZone;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := nil;
  if FloatSite.Child <> nil then
  begin
    for I := 0 to FloatSite.Child.DockZones.Count - 1 do
    begin
      AZone := TdxZone(FloatSite.Child.DockZones[I]);
      if (AZone.Owner = FloatSite.Child) and (AZone.DockType = dtClient) then
      begin
        Result := AZone;
        Break;
      end;
    end;
  end;
end;

procedure TdxFloatZone.DoDock(AControl: TdxCustomDockControl);
var
  AZone: TdxZone;
begin
  AZone := FindTargetDockZone;
  if AZone <> nil then
    AZone.DoDock(AControl);
end;

procedure TdxFloatZone.DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint);
var
  AZone: TdxZone;
begin
  AZone := FindTargetDockZone;
  if AZone <> nil then
    AZone.DrawDockingSelection(DC, AControl, pt);
end;

procedure TdxFloatZone.PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect);
var
  AZone: TdxZone;
begin
  AZone := FindTargetDockZone;
  if AZone <> nil then
    AZone.PrepareSelectionRegion(ARegion, AControl, ARect);
end;

class function TdxFloatZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner = AControl) and (AOwner is TdxFloatDockSite);
end;

function TdxFloatZone.GetFloatSite: TdxFloatDockSite;
begin
  Result := Owner as TdxFloatDockSite;
end;

{ TdxAutoHideLeftZone }

function TdxAutoHideLeftZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Owner.Width + (StartPoint.X - EndPoint.X);
  NewHeight := Owner.Height;
  Result := (NewWidth > 0) and ((Owner.AutoHideHostSite.AutoSize and
    (NewWidth < Owner.AutoHideContainer.Parent.ClientWidth - Owner.AutoHideHostSite.Width)) or
    (not Owner.AutoHideHostSite.AutoSize and (NewWidth < Owner.AutoHideHostSite.ClientWidth))) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

class function TdxAutoHideLeftZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := AOwner.AutoHide and (AOwner.AutoHideHostSite <> nil) and
    (AOwner.AutoHideHostSite.GetPositionByControl(AOwner) = ahpRight);
end;

{ TdxAutoHideRightZone }

function TdxAutoHideRightZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Owner.Width - (StartPoint.X - EndPoint.X);
  NewHeight := Owner.Height;
  Result := (NewWidth > 0) and ((Owner.AutoHideHostSite.AutoSize and
    (NewWidth < Owner.AutoHideContainer.Parent.ClientWidth - Owner.AutoHideHostSite.Width)) or
    (not Owner.AutoHideHostSite.AutoSize and (NewWidth < Owner.AutoHideHostSite.ClientWidth))) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

class function TdxAutoHideRightZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := AOwner.AutoHide and (AOwner.AutoHideHostSite <> nil) and
    (AOwner.AutoHideHostSite.GetPositionByControl(AOwner) = ahpLeft);
end;

{ TdxAutoHideTopZone }

function TdxAutoHideTopZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewHeight := Owner.Height + (StartPoint.Y - EndPoint.Y);
  NewWidth := Owner.Width;
  Result := (NewHeight > 0) and ((Owner.AutoHideHostSite.AutoSize and
    (NewHeight < Owner.AutoHideContainer.Parent.ClientHeight - Owner.AutoHideHostSite.Height)) or
    (not Owner.AutoHideHostSite.AutoSize and (NewHeight < Owner.AutoHideHostSite.ClientHeight))) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

class function TdxAutoHideTopZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := AOwner.AutoHide and (AOwner.AutoHideHostSite <> nil) and
    (AOwner.AutoHideHostSite.GetPositionByControl(AOwner) = ahpBottom);
end;

{ TdxAutoHideBottomZone }

function TdxAutoHideBottomZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
var
  NewWidth, NewHeight: Integer;
begin
  NewHeight := Owner.Height - (StartPoint.Y - EndPoint.Y);
  NewWidth := Owner.Width;
  Result := (NewHeight > 0) and ((Owner.AutoHideHostSite.AutoSize and
    (NewHeight < Owner.AutoHideContainer.Parent.ClientHeight - Owner.AutoHideHostSite.Height)) or
    (not Owner.AutoHideHostSite.AutoSize and (NewHeight < Owner.AutoHideHostSite.ClientHeight))) and
    CanConstrainedResize(NewWidth, NewHeight);
  Result := Result and TdxCustomDockControlAccess(Owner).CanResizing(NewWidth, NewHeight);
end;

class function TdxAutoHideBottomZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := AOwner.AutoHide and (AOwner.AutoHideHostSite <> nil) and
    (AOwner.AutoHideHostSite.GetPositionByControl(AOwner) = ahpTop);
end;

{ TdxAutoSizeLeftZone }

class function TdxAutoSizeLeftZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.Parent <> nil) and (AOwner.Align in [alRight]);
end;

{ TdxAutoSizeRightZone }

class function TdxAutoSizeRightZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.Parent <> nil) and (AOwner.Align in [alLeft, alNone]);
end;

{ TdxAutoSizeTopZone }

class function TdxAutoSizeTopZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.Parent <> nil) and (AOwner.Align in [alBottom]);
end;

{ TdxAutoSizeBottomZone }

class function TdxAutoSizeBottomZone.ValidateResizeZone(AOwner,
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner.Parent <> nil) and (AOwner.Align in [alTop, alNone]);
end;

{ TdxAutoSizeClientZone }

function TdxAutoSizeClientZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
  AWidth, AHeight: Integer;
begin
  GetWindowRect(Owner.Handle, R);
  if Owner.Width < AControl.OriginalWidth then
    AWidth := AControl.OriginalWidth
  else
    AWidth := Owner.Width;
  if Owner.Height < AControl.OriginalHeight then
    AHeight := AControl.OriginalHeight
  else
    AHeight := Owner.Height;
  case Owner.Align of
    alLeft:
      begin
        Result := Rect(0, 0, AWidth, Owner.Height);
        OffsetRect(Result, R.Left, R.Top);
      end;
    alRight:
      begin
        Result := Rect(0, 0, AWidth, Owner.Height);
        OffsetRect(Result, R.Right - AWidth, R.Top);
      end;
    alTop:
      begin
        Result := Rect(0, 0, Owner.Width, AHeight);
        OffsetRect(Result, R.Left, R.Top);
      end;
    alBottom:
      begin
        Result := Rect(0, 0, Owner.Width, AHeight);
        OffsetRect(Result, R.Left, R.Bottom - AHeight);
      end;
    alClient:
      begin
        Result := Rect(0, 0, Owner.Width, Owner.Height);
        OffsetRect(Result, R.Left, R.Top);
      end;
  else
    Result := Rect(0, 0, AWidth, AHeight);
    OffsetRect(Result, R.Left, R.Top);
  end;
end;

function TdxAutoSizeClientZone.IsZonePoint(pt: TPoint): Boolean;
begin
  Result := inherited IsZonePoint(pt) or
    (dxDockingController.GetNearestDockSiteAtPos(pt) = Owner);
end;

{ TdxInvisibleAutoSizeClientZone }

function TdxInvisibleAutoSizeClientZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
  AWidth, AHeight: Integer;
begin
  GetWindowRect(Owner.Handle, R);
  if Owner.Width < AControl.OriginalWidth then
    AWidth := AControl.OriginalWidth
  else
    AWidth := Owner.Width;
  if Owner.Height < AControl.OriginalHeight then
    AHeight := AControl.OriginalHeight
  else
    AHeight := Owner.Height;
  case Owner.Align of
    alLeft:
      begin
        Result := Rect(0, 0, AWidth, Owner.Height);
        OffsetRect(Result, R.Left, R.Top);
      end;
    alRight:
      begin
        Result := Rect(0, 0, AWidth, Owner.Height);
        OffsetRect(Result, R.Right - AWidth, R.Top);
      end;
    alTop:
      begin
        Result := Rect(0, 0, Owner.Width, AHeight);
        OffsetRect(Result, R.Left, R.Top);
      end;
    alBottom:
      begin
        Result := Rect(0, 0, Owner.Width, AHeight);
        OffsetRect(Result, R.Left, R.Bottom - AHeight);
      end;
    alClient:
      begin
        Result := Rect(0, 0, Owner.Width, Owner.Height);
        OffsetRect(Result, R.Left, R.Top);
      end;
  else
    Result := Rect(0, 0, AWidth, AHeight);
    OffsetRect(Result, R.Left, R.Top);
  end;
end;

function TdxInvisibleAutoSizeClientZone.IsZonePoint(pt: TPoint): Boolean;
begin
  Result := dxDockingController.GetNearestDockSiteAtPos(pt) = Owner;
end;

{ TdxCustomTabContainerZone }

procedure TdxCustomTabContainerZone.PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect);
var
  AContentRect, ATabsRect, ATabRect: TRect;
begin
  ATabsRect := GetTabsRect;
  ATabRect := GetTabRect(AControl);

  CorrectTabRects(ATabsRect, ATabRect);

  AContentRect := ARect;
  if GetTabPosition = tctpTop then
  begin
    AContentRect.Top := ATabsRect.Bottom;
    ATabRect.Bottom := AContentRect.Top;
  end
  else
  begin
    AContentRect.Bottom := ATabsRect.Top;
    ATabRect.Top := AContentRect.Bottom;
  end;

  ARegion.Combine(TcxRegion.Create(AContentRect), roSet);
  ARegion.Combine(TcxRegion.Create(ATabRect), roAdd);
end;

procedure TdxCustomTabContainerZone.CorrectTabRects(var ATabsRect, ATabRect: TRect);
begin
// do nothing
end;

{ TdxTabContainerZone }

constructor TdxTabContainerZone.Create(AControl: TdxTabContainerDockSite);
begin
  inherited Create(AControl, 0);
end;

procedure TdxTabContainerZone.CorrectTabRects(var ATabsRect, ATabRect: TRect);
const
  AMinWidth = 10;
begin
  if ATabRect.Left < ATabsRect.Left then
  begin
    ATabRect.Left := ATabsRect.Left;
    ATabRect.Right := Max(ATabRect.Right, ATabRect.Left + AMinWidth);
  end;
  if ATabRect.Right > ATabsRect.Right then
  begin
    ATabRect.Right := ATabsRect.Right;
    ATabRect.Left := Min(ATabRect.Left, ATabRect.Right - AMinWidth);
  end;
end;

function TdxTabContainerZone.GetDockIndex: Integer;
begin
  Result := -1;
end;

function TdxTabContainerZone.GetTabPosition: TdxTabContainerTabsPosition;
begin
  Result := TabContainer.TabsPosition;
end;

function TdxTabContainerZone.GetTabRect(AControl: TdxCustomDockControl): TRect;
var
  AIndex: Integer;
  ATextWidth: Integer;
begin
  if (0 <= DockIndex) and (DockIndex < TdxTabContainerDockSiteAccess(TabContainer).TabRectCount) then
    Result := TdxTabContainerDockSiteAccess(TabContainer).TabsRects[DockIndex]
  else
  begin
    AIndex := TdxTabContainerDockSiteAccess(TabContainer).GetLastValidChildIndex;
    if AIndex > -1 then
    begin
      Result := TdxTabContainerDockSiteAccess(TabContainer).TabsRects[AIndex];

      ATextWidth := TdxTabContainerDockSiteAccess(TabContainer).Canvas.TextWidth(AControl.Caption);
      if TdxTabContainerDockSiteAccess(TabContainer).Painter.GetImageWidth > 0 then
        Inc(ATextWidth, TdxTabContainerDockSiteAccess(TabContainer).Painter.GetImageWidth);
      Result.Left := Result.Right;
      Result.Right := Result.Left + ATextWidth;
    end
    else
      Result := Rectangle;
  end;
end;

function TdxTabContainerZone.GetTabsRect: TRect;
begin
  Result := TdxTabContainerDockSiteAccess(TabContainer).TabsRect
end;

procedure TdxTabContainerZone.DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint);
var
  PenSize: Integer;
  R, TabRect, TabsRect: TRect;
begin
  PenSize := SelectionFrameWidth;
  R := GetDockingSelection(AControl);
  TabRect := GetTabRect(AControl);
  TabsRect := GetTabsRect;
  if TabRect.Left < TabsRect.Left then
  begin
    TabRect.Left := TabsRect.Left;
    if TabRect.Right < TabsRect.Left + 3 * PenSize then
      TabRect.Right := TabRect.Left + 3 * PenSize;
  end;
  if TabRect.Right > TabsRect.Right then
  begin
    TabRect.Right := TabsRect.Right;
    if TabRect.Left > TabsRect.Right  - 3 * PenSize then
      TabRect.Left := TabRect.Right - 3 * PenSize;
  end;
  with R do
    if TabContainer.TabsPosition = tctpTop then
    begin
      PatBlt(DC, Left + PenSize, Bottom - PenSize, Right - Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Bottom, PenSize, Bottom - Top - TabRect.Bottom, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Bottom - PenSize, TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top - PenSize, TabRect.Right - TabRect.Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right - PenSize, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top + PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right, Top + TabRect.Bottom - PenSize, Right - Left - TabRect.Right - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Right - PenSize, Top + TabRect.Bottom - PenSize, PenSize, Bottom - Top - TabRect.Bottom, PATINVERT);
    end
    else
    begin
      PatBlt(DC, Left + PenSize, Top, Right - Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left, Top, PenSize, TabRect.Top - PenSize, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Top - PenSize, TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Bottom - PenSize, TabRect.Right - TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right - PenSize, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Right, Top + TabRect.Top - PenSize, Right - Left - TabRect.Right - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Right - PenSize, Top + PenSize, PenSize, TabRect.Top - PenSize, PATINVERT);
    end;
end;

class function TdxTabContainerZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner = AControl) and (((AOwner is TdxTabContainerDockSite) and
    ((AOwner as TdxTabContainerDockSite).ActiveChild <> nil)) or
    ((AOwner.TabContainer <> nil) and (AOwner.TabContainer.ActiveChild <> nil)));
end;

function TdxTabContainerZone.GetTabContainer: TdxTabContainerDockSite;
begin
  Result := inherited Owner as TdxTabContainerDockSite;
end;

{ TdxTabContainerCaptionZone }

function TdxTabContainerCaptionZone.IsZonePoint(pt: TPoint): Boolean;
begin
  pt := TabContainer.ScreenToClient(pt);
  Result := TdxCustomDockControlAccess(TabContainer).IsCaptionPoint(pt);
end;

{ TdxTabContainerTabZone }

constructor TdxTabContainerTabZone.Create(AControl: TdxTabContainerDockSite;
  ADockIndex: Integer);
begin
  inherited Create(AControl);
  FDockIndex := ADockIndex;
end;

function TdxTabContainerTabZone.GetDockIndex: Integer;
begin
  Result := FDockIndex;
end;

function TdxTabContainerTabZone.IsZonePoint(pt: TPoint): Boolean;
begin
  pt := TabContainer.ScreenToClient(pt);
  Result := TdxTabContainerDockSiteAccess(TabContainer).GetTabIndexAtPos(pt) = DockIndex;
end;

class function TdxTabContainerTabZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner = AControl) and (AOwner is TdxTabContainerDockSite) and
    TdxTabContainerDockSiteAccess(AOwner).HasTabs;
end;

{ TdxHorizContainerZone }

function TdxHorizContainerZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
begin
  Result := inherited CanResize(StartPoint, EndPoint);
  if Owner.SideContainer <> nil then
    Result := Result and TdxSideContainerDockSiteAccess(Owner.SideContainer).CanChildResize(Owner.SideContainerItem,
      - (StartPoint.X - EndPoint.X));
end;

procedure TdxHorizContainerZone.DoResize(StartPoint, EndPoint: TPoint);
begin
  if Owner.SideContainer <> nil then
    TdxSideContainerDockSiteAccess(Owner.SideContainer).DoChildResize(Owner.SideContainerItem,
      - (StartPoint.X - EndPoint.X));
end;

{ TdxVertContainerZone }

function TdxVertContainerZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
begin
  Result := inherited CanResize(StartPoint, EndPoint);
  if Owner.SideContainer <> nil then
    Result := Result and TdxSideContainerDockSiteAccess(Owner.SideContainer).CanChildResize(Owner.SideContainerItem,
      - (StartPoint.Y - EndPoint.Y));
end;

procedure TdxVertContainerZone.DoResize(StartPoint, EndPoint: TPoint);
begin
  if Owner.SideContainer <> nil then
    TdxSideContainerDockSiteAccess(Owner.SideContainer).DoChildResize(Owner.SideContainerItem,
      - (StartPoint.Y - EndPoint.Y));
end;

{ TdxDockPanelClientZone }

constructor TdxDockPanelClientZone.Create(AControl: TdxDockPanel);
begin
  inherited Create(AControl, 0);
end;

procedure TdxDockPanelClientZone.DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint);
var
  PenSize: Integer;
  R: TRect;
  TabRect: TRect;
begin
  PenSize := SelectionFrameWidth;
  R := GetDockingSelection(AControl);
  TabRect := TdxDockPanelAccess(Owner).TabRect;
  with R do
    if TdxDockPanelAccess(Owner).GetTabPosition = tctpTop then
    begin
      PatBlt(DC, Left + PenSize, Bottom - PenSize, Right - Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Bottom, PenSize, Bottom - Top - TabRect.Bottom, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Bottom - PenSize, TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top - PenSize, TabRect.Right - TabRect.Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right - PenSize, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top + PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right, Top + TabRect.Bottom - PenSize, Right - Left - TabRect.Right - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Right - PenSize, Top + TabRect.Bottom - PenSize, PenSize, Bottom - Top - TabRect.Bottom, PATINVERT);
    end
    else
    begin
      PatBlt(DC, Left + PenSize, Top, Right - Left - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Left, Top, PenSize, TabRect.Top - PenSize, PATINVERT);
      PatBlt(DC, Left, Top + TabRect.Top - PenSize, TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Left, Top + TabRect.Bottom - PenSize, TabRect.Right - TabRect.Left, PenSize, PATINVERT);
      PatBlt(DC, Left + TabRect.Right - PenSize, Top + TabRect.Top - PenSize, PenSize, TabRect.Bottom - TabRect.Top, PATINVERT);
      PatBlt(DC, Left + TabRect.Right, Top + TabRect.Top - PenSize, Right - Left - TabRect.Right - PenSize, PenSize, PATINVERT);
      PatBlt(DC, Right - PenSize, Top + PenSize, PenSize, TabRect.Top - PenSize, PATINVERT);
    end;
end;

function TdxDockPanelClientZone.GetTabPosition: TdxTabContainerTabsPosition;
begin
  Result := TdxDockPanelAccess(Owner).GetTabPosition;
end;

function TdxDockPanelClientZone.GetTabRect(AControl: TdxCustomDockControl): TRect;
begin
  Result := TdxDockPanelAccess(Owner).TabRect;
end;

function TdxDockPanelClientZone.GetTabsRect: TRect;
begin
  Result := TdxDockPanelAccess(Owner).TabsRect;
end;

function TdxDockPanelClientZone.GetDockPanel: TdxDockPanel;
begin
  Result := inherited Owner as TdxDockPanel;
end;

{ TdxDockPanelCaptionClientZone }

function TdxDockPanelCaptionClientZone.IsZonePoint(pt: TPoint): Boolean;
begin
  pt := DockPanel.ScreenToClient(pt);
  Result := TdxCustomDockControlAccess(DockPanel).IsCaptionPoint(pt);
end;

end.
