
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

unit dxDockPanel;

{$I cxVer.inc}

interface

uses
  Menus, Windows, Graphics, Classes, Controls, ExtCtrls, Messages, Forms,
  dxCore, dxDockConsts, dxDockControl;

type
  TdxDockPanel = class(TdxCustomDockControl)
  private
    FShowSingleTab: Boolean;
    FTabIsDown: Boolean;
    FTabPosition: TdxTabContainerTabsPosition;
    FTabsRect: TRect;
    FTabRect: TRect;

    procedure SetShowSingleTab(const Value: Boolean);
    procedure SetTabPosition(const Value: TdxTabContainerTabsPosition);

    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
  protected
    function GetClientRect: TRect; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure ValidateInsert(AComponent: TComponent); override;

    function IsDockPanel: Boolean; override;

    // Activation
    procedure CheckActiveDockControl; override;
    procedure DoActivate; override;
    // Docking
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Site layout
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType; Index: Integer); override;
    // SideContainer site
    function CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean; override;
    // TabContainer site
    procedure AssignTabContainerSiteProperies(ASite: TdxTabContainerDockSite); override;
    function CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean; override;
    // Painting
    procedure CalculateNC(var ARect: TRect); override;
    procedure InvalidateCaptionArea; override;
    procedure NCPaint(ACanvas: TCanvas); override;
    function NeedInvalidateCaptionArea: Boolean; override;
    function IsTabPoint(pt: TPoint): Boolean;
    function GetTabPosition: TdxTabContainerTabsPosition;
    function HasBorder: Boolean; override;
    function HasCaption: Boolean; override;
    function HasTabs: Boolean; override;

    property TabRect: TRect read FTabRect;
    property TabsRect: TRect read FTabsRect;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanActive: Boolean; override;
    function CanAutoHide: Boolean; override;
    function CanDock: Boolean; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;
    function CanMaximize: Boolean; override;
  published
    property AllowDockClients;
    property AllowFloating;
    property AllowDock;
    property AutoHide;
    property Caption;
    property CaptionButtons;
    property Dockable;
    property ImageIndex;
    property ShowCaption;
    property ShowSingleTab: Boolean read FShowSingleTab write SetShowSingleTab default False;
    property TabPosition: TdxTabContainerTabsPosition read FTabPosition write SetTabPosition default tctpBottom;

    property OnActivate;
    property OnAutoHideChanged;
    property OnAutoHideChanging;
    property OnCanResize;
    property OnClose;
    property OnCloseQuery;
    property OnCreateFloatSite;
    property OnCreateSideContainer;
    property OnCreateTabContainer;
    property OnCustomDrawDockingSelection;
    property OnCustomDrawResizingSelection;
    property OnDock;
    property OnDocking;
    property OnEndDocking;
    property OnEndResizing;
    property OnGetAutoHidePosition;
    property OnLayoutChanged;
    property OnMakeFloating;
    property OnResize;
    property OnResizing;
    property OnRestoreDockPosition;
    property OnStartDocking;
    property OnStartResizing;
    property OnStoreDockPosition;
    property OnUnDock;
    property OnUpdateDockZones;
    property OnUpdateResizeZones;
  end;

implementation

uses
  Types, SysUtils, dxDockZones, cxGraphics, cxGeometry;

type
  TdxCustomDockControlAccess = class(TdxCustomDockControl);
  TdxDockingControllerAccess = class(TdxDockingController);  

{ TdxDockPanel }

constructor TdxDockPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowSingleTab := False;
  TabPosition := tctpBottom;
  UseDoubleBuffer := True;
  SetBounds(0, 0, 185, 140);
end;

destructor TdxDockPanel.Destroy;
begin
  inherited;
end;

function TdxDockPanel.CanActive: Boolean;
begin
  Result := True;
end;

function TdxDockPanel.CanAutoHide: Boolean;
begin
  Result := IsLoading or
    ((AutoHideHostSite <> nil) and ((AutoHideControl = nil) or (AutoHideControl = Self)));
end;

function TdxDockPanel.CanDock: Boolean;
begin
  Result := True;
end;

function TdxDockPanel.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
var
  ACanDockHost: Boolean;
begin
  if Container <> nil then
  begin
    ACanDockHost := Container.CanContainerDockHost(AType);
    if Container is TdxTabContainerDockSite then
    begin
      if doSideContainerCanInTabContainer in ControllerOptions then
        ACanDockHost := ACanDockHost or (AType in [dtLeft, dtRight, dtTop, dtBottom]);
    end;
    if Container is TdxSideContainerDockSite then
    begin
      if doTabContainerCanInSideContainer in ControllerOptions then
        ACanDockHost := ACanDockHost or (AType in [dtClient]);
      if doSideContainerCanInSideContainer in ControllerOptions then
        ACanDockHost := ACanDockHost or (AType in [dtLeft, dtRight, dtTop, dtBottom]);
    end;
  end
  else
    ACanDockHost := (AType in [dtClient, dtLeft, dtRight, dtTop, dtBottom]);
  Result := inherited CanDockHost(AControl, AType) and ACanDockHost;;
end;

function TdxDockPanel.CanMaximize: Boolean;
begin
  Result := not AutoHide and (SideContainer <> nil) and (SideContainer.ValidChildCount > 1);
end;

procedure TdxDockPanel.CheckActiveDockControl;
begin
  if Active and not IsDesigning and CanFocusEx and not dxDockingController.IsDockControlFocusedEx(Self) then
    DoActivate;
end;

procedure TdxDockPanel.DoActivate;
var
  AParentForm: TCustomForm;
begin
  AParentForm := Forms.GetParentForm(Self);
  if (AParentForm <> nil) then
  begin
    AParentForm.ActiveControl := Self;
    if AParentForm.ActiveControl = Self then
      SelectFirst;
  end
  else
    SetFocus;
end;

function TdxDockPanel.GetClientRect: TRect;
begin
  if HandleAllocated then
    Result := inherited GetClientRect
  else
    Result := cxEmptyRect;

  if TdxDockingControllerAccess(Controller).IsUpdateNCLocked and
    ((Height = 0) or (Width = 0) or (cxRectWidth(Result) = 0) or (cxRectHeight(Result) = 0)) then
    Result := Rect(0, 0, OriginalWidth, OriginalHeight);
end;

procedure TdxDockPanel.SetParent(AParent: TWinControl);
var
  ALeft, ATop: Integer;
  APrevParent: TWinControl;
  I: TdxDockingType;
begin
  if (UpdateLayoutLock = 0) and not IsDestroying and
    ((AParent = nil) or not (csLoading in AParent.ComponentState)) then
  begin
    if IsDesigning and (AParent <> nil) then
      ValidateContainer(AParent);
    if AParent is TdxCustomDockControl then
      for I := Low(TdxDockingType) to High(TdxDockingType) do
      begin
        if TdxCustomDockControl(AParent).CanDockHost(Self, I) then
        begin
          DockTo(AParent as TdxCustomDockControl, I, -1);
          Exit;
        end;
      end;
    // else Make Float  
    APrevParent := Parent;
    ALeft := Left;
    ATop := Top;
    if AParent = nil then
      AParent := APrevParent;
    if AParent <> nil then
    begin
      ALeft := AParent.ClientOrigin.X + ALeft;
      ATop := AParent.ClientOrigin.Y + ATop;
    end;
    MakeFloating(ALeft, ATop);
  end
  else
  begin
    if (AParent <> nil) and
      not ((AParent is TdxCustomDockControl) or (AutoHide and (AParent is TdxDockSiteAutoHideContainer))) then
      raise EdxException.CreateFmt(sdxInvalidParent, [ClassName])
    else
      inherited SetParent(AParent);
  end
end;

procedure TdxDockPanel.ValidateInsert(AComponent: TComponent);
begin
  if AComponent is TdxCustomDockControl then
    raise EdxException.CreateFmt(sdxInvalidPanelChild, [AComponent.ClassName]);
end;

function TdxDockPanel.IsDockPanel: Boolean;
begin
  Result := True;
end;

procedure TdxDockPanel.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
begin
  if not (doUseCaptionAreaToClientDocking in ControllerOptions) then
  begin
    if (TabContainer <> nil) and TdxTabContainerZone.ValidateDockZone(Self, AControl) then
      DockZones.Insert(0, TdxTabContainerZone.Create(TabContainer))
    else
      if TdxDockPanelClientZone.ValidateDockZone(Self, AControl) then
        DockZones.Insert(0, TdxDockPanelClientZone.Create(Self));
  end;
  inherited;
  if doUseCaptionAreaToClientDocking in ControllerOptions then
  begin
    if (TabContainer <> nil) and TdxTabContainerCaptionZone.ValidateDockZone(Self, AControl) then
      DockZones.Insert(0, TdxTabContainerCaptionZone.Create(TabContainer))
    else
      if TdxDockPanelCaptionClientZone.ValidateDockZone(Self, AControl) then
        DockZones.Insert(0, TdxDockPanelCaptionClientZone.Create(Self));
  end;
end;

procedure TdxDockPanel.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
begin
  if (Container <> nil) and Container.CanContainerDockHost(AType) then
    CreateContainerLayout(Container, AControl, AType, DockIndex)
  else
    case AType of
      dtClient:
        CreateTabContainerLayout(AControl, AType, Index);
      dtLeft, dtRight, dtTop, dtBottom:
        CreateSideContainerLayout(AControl, AType, Index);
    else
      Assert(False, Format(sdxInternalErrorCreateLayout, [TdxContainerDockSite.ClassName]));
    end;
end;

function TdxDockPanel.CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean;
begin
  Result := True;
end;

procedure TdxDockPanel.AssignTabContainerSiteProperies(ASite: TdxTabContainerDockSite);
begin
  inherited;
  if ShowSingleTab then
    ASite.TabsPosition := TabPosition;
end;

function TdxDockPanel.CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean;
begin
  Result := True;
end;

procedure TdxDockPanel.CalculateNC(var ARect: TRect);
begin
  inherited;
  FTabsRect.Left := ARect.Left;
  FTabsRect.Right := ARect.Right;
  if GetTabPosition = tctpTop then
  begin
    FTabsRect.Top := ARect.Top;
    FTabsRect.Bottom := FTabsRect.Top + Painter.GetTabsHeight;
    if HasTabs then
      ARect.Top := FTabsRect.Bottom;
  end
  else
  begin
    FTabsRect.Bottom := ARect.Bottom;
    FTabsRect.Top := FTabsRect.Bottom - Painter.GetTabsHeight;
    if FTabsRect.Top < ARect.Top then
    begin
      FTabsRect.Top := ARect.Top;
      FTabsRect.Bottom := FTabsRect.Top + Painter.GetTabsHeight;
    end;
    if HasTabs then
      ARect.Bottom := FTabsRect.Top;
  end;

  FTabRect.Left := FTabsRect.Left + Painter.GetTabHorizInterval;
  FTabRect.Top := FTabsRect.Top + Painter.GetTabVertInterval;
  if GetTabPosition = tctpBottom then
    Inc(FTabRect.Top, Painter.GetTabVertInterval);
  FTabRect.Bottom := FTabsRect.Bottom - Painter.GetTabVertInterval;
  if GetTabPosition = tctpTop then
    Dec(FTabRect.Bottom, Painter.GetTabVertInterval);
  FTabRect.Right := FTabRect.Left + GetTabWidth(Canvas);
  if FTabRect.Right > FTabsRect.Right - Painter.GetTabHorizInterval then
    FTabRect.Right := FTabsRect.Right - Painter.GetTabHorizInterval;
end;

procedure TdxDockPanel.InvalidateCaptionArea;
begin
  if HasTabs then
    InvalidateNC(True)
  else
    inherited;
end;

procedure TdxDockPanel.NCPaint(ACanvas: TCanvas);
begin
  inherited;
  if HasTabs then
  begin
    Painter.DrawTabs(ACanvas, TabsRect, TabRect, TabPosition);
    Painter.DrawTab(ACanvas, Self, TabRect, True, TabPosition);
  end;
end;

function TdxDockPanel.NeedInvalidateCaptionArea: Boolean;
begin
  Result := inherited NeedInvalidateCaptionArea or HasTabs;
end;

function TdxDockPanel.IsTabPoint(pt: TPoint): Boolean;
begin
  Result := HasTabs and PtInRect(TabRect, ClientToWindow(pt));
end;

function TdxDockPanel.GetTabPosition: TdxTabContainerTabsPosition;
begin
  if ShowSingleTab then
    Result := TabPosition
  else
    if Controller.DefaultTabContainerSiteProperties(ParentForm) <> nil then
      Result := Controller.DefaultTabContainerSiteProperties(ParentForm).TabsPosition
    else
      Result := tctpBottom;
end;

function TdxDockPanel.HasBorder: Boolean;
begin
  Result := (FloatDockSite = nil) and
    (AutoHide or
      ((TabContainer = nil) or ((TabContainer.ValidChildCount < 2) and not TabContainer.AutoHide)) and
      ((ParentDockControl = nil) or TdxCustomDockControlAccess(ParentDockControl).CanUndock(Self))
    );
end;

function TdxDockPanel.HasCaption: Boolean;
begin
  Result := ShowCaption and HasBorder;
end;

function TdxDockPanel.HasTabs: Boolean;
begin
  Result := ShowSingleTab and ((TabContainer = nil) or (TabContainer.ValidChildCount = 1));
end;

procedure TdxDockPanel.SetShowSingleTab(const Value: Boolean);
begin
  if FShowSingleTab <> Value then
  begin
    FShowSingleTab := Value;
    NCChanged;
  end;
end;

procedure TdxDockPanel.SetTabPosition(const Value: TdxTabContainerTabsPosition);
begin
  if FTabPosition <> Value then
  begin
    FTabPosition := Value;
    NCChanged;
  end;
end;

procedure TdxDockPanel.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  pt: TPoint;
begin
  inherited;
  if Message.Result = 0 then
  begin
    if not IsDesigning and (doDblClickDocking in ControllerOptions) and
      not AutoHide and IsTabPoint(CursorPoint) then
    begin
      pt := ClientToScreen(CursorPoint);
      DoStartDocking(pt);
      if FloatDockSite = nil then
        MakeFloating
      else
        RestoreDockPosition(ClientToWindow(pt));
      DoEndDocking(pt);
      Message.Result := 1;
    end;
  end;
end;

procedure TdxDockPanel.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Message.Result = 0 then
  begin
    FTabIsDown := IsTabPoint(SourcePoint);
    if FTabIsDown then
      CaptureMouse;
    Message.Result := 1;
  end;
end;

procedure TdxDockPanel.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if Message.Result = 0 then
  begin
    if FTabIsDown then
    begin
      ReleaseMouse;
      FTabIsDown := False;
      Message.Result := 1;
    end;
  end;
end;

procedure TdxDockPanel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if (Message.Result = 0) and (FloatFormActive or ParentFormActive or IsDesigning) then
  begin
    if FTabIsDown and ((IsDesigning and
      ((Abs(CursorPoint.X - SourcePoint.X) > 3) or
      (Abs(CursorPoint.Y - SourcePoint.Y) > 3))) or
      not IsTabPoint(CursorPoint)) then
    begin
      ReleaseMouse;
      FTabIsDown := False;
      StartDocking(ClientToScreen(SourcePoint));
      Message.Result := 1;
    end;
  end;
end;

initialization
  RegisterClasses([TdxDockPanel]);

end.
