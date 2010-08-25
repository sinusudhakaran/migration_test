{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{           Copyright (c) 2006-2009 Developer Express Inc.           }
{                     ALL RIGHTS RESERVED                            }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSSKINS AND ALL ACCOMPANYING     }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.              }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit dxSkinsdxNavBarPainter;

interface

uses
  Types, Windows, Graphics, Classes, dxNavBar, dxNavBarBase, dxNavBarCollns, dxNavBarStyles,
  dxNavBarExplorerViews, dxNavBarGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsLookAndFeelPainter, dxNavBarConsts, dxNavBarOffice11Views, ImgList,
  cxGraphics, cxClasses, dxNavBarOfficeViews;

type

  { TdxNavBarSkinNavPaneLinkViewInfo }

  TdxNavBarSkinNavPaneLinkViewInfo = class(TdxNavBarOffice3LinkViewInfo)
  public
    function FontColor: TColor; override;
    function SelectionRect: TRect; override;
  end;

  { TdxNavBarSkinNavPaneGroupViewInfo }

  TdxNavBarSkinNavPaneGroupViewInfo = class(TdxNavBarOffice11NavPaneGroupViewInfo)
  public
    function CaptionFontColor: TColor; override;
  end;

  { TdxNavBarSkinNavPaneViewInfo }

  TdxNavBarSkinNavPaneViewInfo = class(TdxNavBarOffice11NavPaneViewInfo)
  protected
    function GetOverflowPanelClientOffset: TRect; override;
    function GetOverflowPanelImageWidthAddon: Integer; override;
    function GetOverflowPanelSignWidth: Integer; override;
    function GetSkinInfo(var ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
  public
    procedure AssignDefaultNavigationPaneHeaderStyle; override;
    function GetHeaderHeight: Integer; override;
    function GetOverflowPanelHeight: Integer; override;
    function HeaderFont: TFont; override;
    function HeaderFontColor: TColor; override;
  end;

  { TdxNavBarSkinNavPanePainter }

  TdxNavBarSkinNavPanePainter = class(TdxNavBarOffice11NavPanePainter)
  private
    FLookAndFeel: TcxLookAndFeel;
    function GetSkinNameAssigned: Boolean;
    function GetSkinName: TdxSkinName;
    function InternalDrawScrollButton(ADownButton: Boolean; const ARect: TRect;
      AState: TdxNavBarObjectStates): Boolean;
    function IsSkinNameStored: Boolean;
    procedure SetSkinNameAssigned(AValue: Boolean);
    procedure SetSkinName(const Value: TdxSkinName);
    // Custom draw
    function CustomDrawHeader: Boolean;
    function CustomDrawOverflowPanel: Boolean;
    function CustomDrawSplitter: Boolean;
  protected
    function CreateViewInfo: TdxNavBarViewInfo; override;
    function CreateGroupViewInfo(AViewInfo: TdxNavBarViewInfo; AGroup: TdxNavBarGroup;
      ACaptionVisible: Boolean; AItemsVisible: Boolean): TdxNavBarGroupViewInfo; override;
    function CreateLinkViewInfo(AViewInfo: TdxNavBarGroupViewInfo;
      ALink: TdxNavBarItemLink; ACaptionVisible: Boolean;
      AImageVisisble: Boolean): TdxNavBarLinkViewInfo; override;
    function GetMasterLookAndFeel: TcxLookAndFeel; override;
    function GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean; virtual;
    function IsSkinAvailable: Boolean;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues); virtual;
  public
    constructor Create(ANavBar: TdxCustomNavBar); override;
    destructor Destroy; override;

    procedure DrawBackground; override;
    procedure DrawBorder; override;
    procedure DrawBottomScrollButton; override;
    procedure DrawGroupBorder(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupCaptionButton(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupControl(ACanvas: TCanvas; ARect: TRect;
      AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawHeader; override;
    procedure DrawItemSelection(ALinkViewInfo: TdxNavBarLinkViewInfo); override;
    procedure DrawOverflowPanel; override;
    procedure DrawOverflowPanelItems; override;
    procedure DrawOverflowPanelSign; override;
    procedure DrawPopupMenuItem(ACanvas: TCanvas; ARect: TRect;
      AImageList: TCustomImageList; AImageIndex: Integer; AText: String;
      State: TdxNavBarObjectStates); override;
    procedure DrawSplitter; override;
    procedure DrawTopScrollButton; override;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel;
  published
    property SkinName: TdxSkinName read GetSkinName write SetSkinName stored IsSkinNameStored;
    property SkinNameAssigned: Boolean read GetSkinNameAssigned write SetSkinNameAssigned default False;
  end;

  { TdxNavBarSkinExplorerBarPainter }

  TdxNavBarSkinExplorerBarPainter = class(TdxNavBarExplorerBarPainter)
  private
    FLookAndFeel: TcxLookAndFeel;
    function GetSkinNameAssigned: Boolean;
    function GetSkinName: TdxSkinName;
    function IsSkinNameStored: Boolean;
    procedure SetSkinNameAssigned(AValue: Boolean);
    procedure SetSkinName(const Value: TdxSkinName);
  protected
    function CreateGroupViewInfo(AViewInfo: TdxNavBarViewInfo; AGroup: TdxNavBarGroup;
      ACaptionVisible: Boolean; AItemsVisible: Boolean): TdxNavBarGroupViewInfo; override;
    function CreateLinkViewInfo(AViewInfo: TdxNavBarGroupViewInfo;
      ALink: TdxNavBarItemLink; ACaptionVisible: Boolean;
      AImageVisisble: Boolean): TdxNavBarLinkViewInfo; override;
    function GetMasterLookAndFeel: TcxLookAndFeel; override;
    function GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean; virtual;
    function IsSkinAvailable: Boolean;
    procedure DrawGroupTopBorder(AGroupViewInfo: TdxNavBarGroupViewInfo);
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues); virtual;
  public
    constructor Create(ANavBar: TdxCustomNavBar); override;
    destructor Destroy; override;

    procedure DrawBackground; override;
    procedure DrawGroupBackground(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupBorder(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupCaption(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupCaptionButton(AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    procedure DrawGroupControl(ACanvas: TCanvas; ARect: TRect;
      AGroupViewInfo: TdxNavBarGroupViewInfo); override;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel;
  published
    property SkinName: TdxSkinName read GetSkinName write SetSkinName stored IsSkinNameStored;
    property SkinNameAssigned: Boolean read GetSkinNameAssigned write SetSkinNameAssigned default False;
  end;

  { TdxNavBarSkinExplorerBarLinkViewInfo }

  TdxNavBarSkinExplorerBarLinkViewInfo = class(TdxNavBarLinkViewInfo)
  public
    function FontColor: TColor; override;
  end;

  { TdxNavBarSkinExplorerBarGroupViewInfo }

  TdxNavBarSkinExplorerBarGroupViewInfo = class(TdxNavBarGroupViewInfo)
  public
    function CaptionFontColor: TColor; override;
    procedure CalculateBounds(X: Integer; Y: Integer); override;
  end;

implementation

uses
  dxNavBarViewsFact, dxSkinsCore, Math, cxGeometry;

function NavBarObjectStateToSkinState(AState: TdxNavBarObjectStates): TdxSkinElementState;
begin
  Result := esNormal;
  if sPressed in AState then
    Result := esPressed
  else
    if sHotTracked in AState then
      Result := esHot
    else
      if sDisabled in AState then
        Result := esDisabled;
end;

{ TdxNavBarSkinNavPaneGroupViewInfo }

function TdxNavBarSkinNavPaneGroupViewInfo.CaptionFontColor: TColor;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  with TdxNavBarSkinNavPanePainter(Painter) do
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneGroupButton[False];
    if AElement <> nil then
      Result := AElement.TextColor
    else
      Result := inherited CaptionFontColor;
  end;
end;

{ TdxNavBarSkinNavPaneLinkViewInfo }

function TdxNavBarSkinNavPaneLinkViewInfo.FontColor: TColor;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  with TdxNavBarSkinNavPanePainter(Painter) do
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneItem;
    if AElement <> nil then
      Result := AElement.TextColor
    else
      Result := inherited FontColor;
  end;
end;

function TdxNavBarSkinNavPaneLinkViewInfo.SelectionRect: TRect;
begin
  Result := Rect;
  InflateRect(Result, -2, 0);
end;

{ TdxNavBarSkinNavPaneViewInfo }

procedure TdxNavBarSkinNavPaneViewInfo.AssignDefaultNavigationPaneHeaderStyle;
begin
  with NavBar.DefaultStyles.NavigationPaneHeader do
  begin
    ResetValues;
    HAlignment := haCenter;
    BackColor := clNone;
    BackColor2 := clNone;
    Font.Color := clNone;
    Font.Name := 'Arial';
    Font.Style := [fsBold];
    Font.Size := 9;
  end;
end;

function TdxNavBarSkinNavPaneViewInfo.HeaderFont: TFont;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited HeaderFont;
  if (Result.Size = 9) and GetSkinInfo(ASkinInfo) then
    if Assigned(ASkinInfo.NavPaneCaptionFontSize) then
      Result.Size := ASkinInfo.NavPaneCaptionFontSize.Value;
end;

function TdxNavBarSkinNavPaneViewInfo.HeaderFontColor: TColor;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinInfo(ASkinInfo) and (ASkinInfo.NavPaneGroupCaption <> nil) then
    Result := ASkinInfo.NavPaneGroupCaption.TextColor
  else
    Result := inherited HeaderFontColor;
end;

function TdxNavBarSkinNavPaneViewInfo.GetHeaderHeight: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited GetHeaderHeight;
  if GetSkinInfo(ASkinInfo) then
    if Assigned(ASkinInfo.NavPaneCaptionHeight) then
      Result := Max(ASkinInfo.NavPaneCaptionHeight.Value, Result);
end;

function TdxNavBarSkinNavPaneViewInfo.GetOverflowPanelHeight: Integer;
var
  AOverflowButton: TdxSkinElement;
  AOverflowPanel: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited GetOverflowPanelHeight;
  if GetSkinInfo(ASkinInfo) then
  begin
    AOverflowButton := ASkinInfo.NavPaneOverflowPanelItem;
    AOverflowPanel := ASkinInfo.NavPaneOverflowPanel;
    if (AOverflowButton <> nil) and (AOverflowPanel <> nil) then
      with AOverflowPanel.ContentOffset do
        Result := Max(Result, Top + Bottom + AOverflowButton.Size.cy);
  end;
end;

function TdxNavBarSkinNavPaneViewInfo.GetOverflowPanelClientOffset: TRect;
var
  AOverflowPanel: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AOverflowPanel := nil;
  if GetSkinInfo(ASkinInfo) then
    AOverflowPanel := ASkinInfo.NavPaneOverflowPanel;

  if AOverflowPanel = nil then
    Result := inherited GetOverflowPanelClientOffset
  else
    Result := AOverflowPanel.ContentOffset.Rect;
end;

function TdxNavBarSkinNavPaneViewInfo.GetOverflowPanelImageWidthAddon: Integer;
var
  AOverflowButton: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinInfo(ASkinInfo) then
    AOverflowButton := ASkinInfo.NavPaneOverflowPanelItem
  else
    AOverflowButton := nil;

  if AOverflowButton = nil then
    Result := inherited GetOverflowPanelImageWidthAddon
 else
    with AOverflowButton.ContentOffset do
      Result := (Left + Right) div 2;
end;

function TdxNavBarSkinNavPaneViewInfo.GetOverflowPanelSignWidth: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited GetOverflowPanelSignWidth;
  if GetSkinInfo(ASkinInfo) then
  begin
    if ASkinInfo.NavPaneOverflowPanelExpandedItem <> nil then
      with ASkinInfo.NavPaneOverflowPanelExpandedItem do
        Result := Max(Size.cx, Result);
  end;
end;

function TdxNavBarSkinNavPaneViewInfo.GetSkinInfo(
  var ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  with TdxNavBarSkinNavPanePainter(Painter) do
    Result := GetSkinPainterData(ASkinInfo);
end;

{ TdxNavBarSkinNavPanePainter }

constructor TdxNavBarSkinNavPanePainter.Create(ANavBar: TdxCustomNavBar);
begin
  inherited Create(ANavBar);
  FLookAndFeel := TcxLookAndFeel.Create(nil);
  FLookAndFeel.NativeStyle := False;
  FLookAndFeel.OnChanged := LookAndFeelChanged;
end;

destructor TdxNavBarSkinNavPanePainter.Destroy;
begin
  FLookAndFeel.Free;
  inherited Destroy;
end;

function TdxNavBarSkinNavPanePainter.CreateViewInfo: TdxNavBarViewInfo;
begin
  Result := TdxNavBarSkinNavPaneViewInfo.Create(Self);
end;

function TdxNavBarSkinNavPanePainter.CreateGroupViewInfo(AViewInfo: TdxNavBarViewInfo;
  AGroup: TdxNavBarGroup; ACaptionVisible: Boolean; AItemsVisible: Boolean): TdxNavBarGroupViewInfo;
begin
  Result := TdxNavBarSkinNavPaneGroupViewInfo.Create(AViewInfo, AGroup, ACaptionVisible,
    AItemsVisible);
end;

function TdxNavBarSkinNavPanePainter.CreateLinkViewInfo(AViewInfo: TdxNavBarGroupViewInfo;
  ALink: TdxNavBarItemLink; ACaptionVisible: Boolean;
  AImageVisisble: Boolean): TdxNavBarLinkViewInfo;
begin
  Result := TdxNavBarSkinNavPaneLinkViewInfo.Create(AViewInfo, ALink, ACaptionVisible,
    AImageVisisble);
end;

function TdxNavBarSkinNavPanePainter.GetMasterLookAndFeel: TcxLookAndFeel;
begin
  Result := FLookAndFeel;
end;

function TdxNavBarSkinNavPanePainter.GetSkinPainterData(
  var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(FLookAndFeel.SkinPainter, AData);
end;

procedure TdxNavBarSkinNavPanePainter.LookAndFeelChanged(
  Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  NavBar.InvalidateAll(doRecreate);
end;

function TdxNavBarSkinNavPanePainter.InternalDrawScrollButton(ADownButton: Boolean;
  const ARect: TRect; AState: TdxNavBarObjectStates): Boolean;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavPaneScrollButtons[ADownButton];
  Result := AElement <> nil;
  if Result then
    AElement.Draw(Canvas.Handle, ARect, 0, NavBarObjectStateToSkinState(AState));
end;

function TdxNavBarSkinNavPanePainter.IsSkinAvailable: Boolean;
begin
  Result := FLookAndFeel.SkinPainter <> nil;
end;

function TdxNavBarSkinNavPanePainter.IsSkinNameStored: Boolean;
begin
  Result := SkinNameAssigned;
end;

function TdxNavBarSkinNavPanePainter.GetSkinName: TdxSkinName;
begin
  Result := FLookAndFeel.SkinName;
end;

procedure TdxNavBarSkinNavPanePainter.SetSkinName(const Value: TdxSkinName);
begin
  FLookAndFeel.SkinName := Value;
end;

function TdxNavBarSkinNavPanePainter.GetSkinNameAssigned: Boolean;
begin
  Result := lfvSkinName in FLookAndFeel.AssignedValues;
end;

procedure TdxNavBarSkinNavPanePainter.SetSkinNameAssigned(AValue: Boolean);
begin
  if AValue then
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues + [lfvSkinName]
  else
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues - [lfvSkinName];
end;

function TdxNavBarSkinNavPanePainter.CustomDrawHeader: Boolean;
begin
  Result := False;
  if Assigned(NavBar.OnCustomDrawNavigationPaneHeader) then
    NavBar.OnCustomDrawNavigationPaneHeader(NavBar, Canvas, ViewInfo, Result);
end;

function TdxNavBarSkinNavPanePainter.CustomDrawOverflowPanel: Boolean;
begin
  Result := False;
  if Assigned(NavBar.OnCustomDrawNavigationPaneOverflowPanel) then
    NavBar.OnCustomDrawNavigationPaneOverflowPanel(NavBar, Canvas, ViewInfo, Result);
end;

function TdxNavBarSkinNavPanePainter.CustomDrawSplitter: Boolean;
begin
  Result := False;
  if Assigned(NavBar.OnCustomDrawNavigationPaneSplitter) then
    NavBar.OnCustomDrawNavigationPaneSplitter(NavBar, Canvas, ViewInfo, Result);
end;

procedure TdxNavBarSkinNavPanePainter.DrawBackground;
var
  AColor: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AColor := nil;
  if GetSkinPainterData(ASkinInfo) then
    AColor := ASkinInfo.NavBarBackgroundColor;
  if AColor = nil then
    inherited DrawBackground
  else
  begin
    Canvas.Brush.Color := AColor.Color;
    Canvas.FillRect(NavBar.ClientRect);
  end;
end;

procedure TdxNavBarSkinNavPanePainter.DrawBorder;
begin
  if not IsSkinAvailable then
    inherited DrawBorder;
end;

procedure TdxNavBarSkinNavPanePainter.DrawBottomScrollButton;
begin
  with ViewInfo do
    if not InternalDrawScrollButton(True, BottomScrollButtonRect,
      BottomScrollButtonState)
    then
      inherited DrawBottomScrollButton;
end;

procedure TdxNavBarSkinNavPanePainter.DrawHeader;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not CustomDrawHeader then
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneGroupCaption;
    if AElement = nil then
      inherited DrawHeader
    else
    begin
      AElement.Draw(Canvas.Handle, ViewInfo.HeaderRect);
      DrawHeaderText;
    end;
  end;  
end;

procedure TdxNavBarSkinNavPanePainter.DrawGroupBorder(AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavPaneGroupClient;
  if AElement = nil then
    inherited DrawGroupBorder(AGroupViewInfo)
  else
  begin
    AElement.Draw(Canvas.Handle, AGroupViewInfo.ControlRect);
  end;
end;

procedure TdxNavBarSkinNavPanePainter.DrawGroupCaptionButton(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  with AGroupViewInfo do
  begin
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneGroupButton[sActive in AGroupViewInfo.State];
    if AElement = nil then
      inherited DrawGroupCaptionButton(AGroupViewInfo)
    else
    begin
      ARect := AGroupViewInfo.CaptionRect;
      Dec(ARect.Top);
      AElement.Draw(Canvas.Handle, ARect, 0, NavBarObjectStateToSkinState(State));
    end;
  end;
end;

procedure TdxNavBarSkinNavPanePainter.DrawGroupControl(ACanvas: TCanvas; ARect: TRect;
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavPaneGroupClient;

  if AElement = nil then
    inherited DrawGroupControl(ACanvas, ARect, AGroupViewInfo)
  else
    AElement.Draw(ACanvas.Handle, ARect);
end;

procedure TdxNavBarSkinNavPanePainter.DrawItemSelection(
  ALinkViewInfo: TdxNavBarLinkViewInfo);
var
  AItem: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  AState: TdxSkinElementState;
begin
  AItem := nil;
  AState := NavBarObjectStateToSkinState(ALinkViewInfo.State);

  if GetSkinPainterData(ASkinInfo) then
    if (AState = esNormal) and (sSelected in ALinkViewInfo.State) then
      AItem := ASkinInfo.NavPaneSelectedItem
    else
      AItem := ASkinInfo.NavPaneItem;
        
  if AItem = nil then
    inherited DrawItemSelection(ALinkViewInfo)
  else
    AItem.Draw(Canvas.Handle, ALinkViewInfo.SelectionRect, 0, AState);
end;

procedure TdxNavBarSkinNavPanePainter.DrawOverflowPanel;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not CustomDrawOverflowPanel then
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneOverflowPanel;
    if AElement = nil then
      inherited DrawOverflowPanel
    else
    begin
      AElement.Draw(Canvas.Handle, ViewInfo.OverflowPanelRect);
      DrawOverflowPanelSign;
      DrawOverflowPanelItems;
    end;
  end;  
end;

procedure TdxNavBarSkinNavPanePainter.DrawOverflowPanelItems;
var
  AElementItem: TdxSkinElement;
  AElementState: TdxSkinElementState;
  AGroup: TdxNavBarGroup;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  I: Integer;
  R: TRect;
begin
  AElementItem := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElementItem := ASkinInfo.NavPaneOverflowPanelItem;
  if AElementItem = nil then
    inherited DrawOverflowPanelItems
  else
    with ViewInfo do
      for I := 0 to OverflowPanelVisibleItemCount - 1 do
      begin
        R := OverflowPanelItems[I].SelectionRect;
        AGroup := OverflowPanelItems[I].Group;
        if NavBar.NavigationPaneOverflowPanelHotTrackedIndex = I then
          AElementState := esHot
        else
          if NavBar.NavigationPaneOverflowPanelPressedIndex = I then
            AElementState := esPressed
          else
            AElementState := esNormal;
        AElementItem.Draw(Canvas.Handle, R, Byte(AGroup = NavBar.ActiveGroup),
          AElementState);
        R := ViewInfo.OverflowPanelItems[I].Rect;
        with ImagePainterClass do
          if IsValidImage(GetOverflowPanelImageList, GetOverflowPanelImageIndex(AGroup)) then
            DrawImage(Canvas, GetOverflowPanelImageList, GetOverflowPanelImageIndex(AGroup), R)
          else
            if NavBar.NavigationPaneOverflowPanelUseSmallImages then
              Canvas.Draw(R.Left, R.Top, dxOffice11NavPaneDefaultSmallBitmap)
            else
              Canvas.Draw(R.Left, R.Top, dxOffice11NavPaneDefaultLargeBitmap);
      end;
end;

procedure TdxNavBarSkinNavPanePainter.DrawOverflowPanelSign;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  AState: TdxSkinElementState;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavPaneOverflowPanelExpandedItem;
  if AElement = nil then
    inherited DrawOverflowPanelSign
  else
    with ViewInfo do
    begin
      if NavBar.NavigationPaneOverflowPanelSignPressed then
        AState := esPressed
      else
        if NavBar.NavigationPaneOverflowPanelSignHotTracked then
          AState := esHot
        else
          AState := esNormal;
      AElement.Draw(Canvas.Handle, ViewInfo.OverflowPanelSignRect, 0, AState);
    end;
end;

procedure TdxNavBarSkinNavPanePainter.DrawPopupMenuItem(ACanvas: TCanvas; ARect: TRect;
  AImageList: TCustomImageList; AImageIndex: Integer; AText: String;
  State: TdxNavBarObjectStates);
var
  ABuf: TcxBitmap;
  APopupMenu: TdxSkinElement;
  ASelected: TdxSkinElement;
  ASeparator: TdxSkinElement;
  ASideStrip: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  AImageAreaWidth: Integer;
  R: TRect;

  function InitializeElements: Boolean;
  begin
    Result := GetSkinPainterData(ASkinInfo);
    if Result then
    begin
      APopupMenu := ASkinInfo.PopupMenu;
      ASelected := ASkinInfo.PopupMenuLinkSelected;
      ASeparator := ASkinInfo.PopupMenuSeparator;
      ASideStrip := ASkinInfo.PopupMenuSideStrip;
      Result := (APopupMenu <> nil) and (ASelected <> nil) and (ASeparator <> nil) and
        (ASideStrip <> nil);
    end;
  end;

  procedure DrawImage(ACanvas: TCanvas; AIsActive: Boolean; AImageAreaWidth: Integer);
  var
    R: TRect;
  begin
    R := ARect;
    OffsetRect(R, -R.Left, -R.Top);
    R.Right := R.Left + AImageAreaWidth;

    if AIsActive then
      ASelected.Draw(ACanvas.Handle, R);

    with TdxNavBarSkinNavPaneViewInfo(ViewInfo) do
      InflateRect(R, -GetOverflowPanelPopupMenuImageIndent,
        -GetOverflowPanelPopupMenuImageIndent);
    AImageList.Draw(ACanvas, R.Left, R.Top, AImageIndex, not (sDisabled in State));
  end;

  procedure DrawItemText(ACanvas: TCanvas; AImageAreaWidth: Integer);
  var
    R: TRect;
  begin
    R := ARect;
    OffsetRect(R, -R.Left, -R.Top);

    with TdxNavBarSkinNavPaneViewInfo(ViewInfo) do
      R.Left := AImageAreaWidth + GetOverflowPanelPopupMenuTextIndent;

    if sDisabled in State then
      ACanvas.Font.Color := clGrayText
    else
      ACanvas.Font.Color := clMenuText;

    ACanvas.Brush.Style := bsClear;
    cxDrawText(ACanvas.Handle, AText, R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;

  procedure DrawMenuBackground(ACanvas: TCanvas; AImageAreaWidth: Integer);
  var
    R: TRect;
  begin
    R := ARect;
    OffsetRect(R, -R.Left, -R.Top);
    with APopupMenu.Borders do
    begin
      Dec(R.Left, Left.Thin);
      Dec(R.Top, Top.Thin);
      Inc(R.Right, Right.Thin);
      Inc(R.Bottom, Bottom.Thin);
    end;
    APopupMenu.Draw(ABuf.Canvas.Handle, R);

    R := ARect;
    OffsetRect(R, -R.Left, -R.Top);
    R.Right := R.Left + AImageAreaWidth + 2;
    ASideStrip.Draw(ABuf.Canvas.Handle, R);
  end;

begin
  if not InitializeElements then
    inherited DrawPopupMenuItem(ACanvas, ARect, AImageList, AImageIndex, AText, State)
  else
  begin
    with TdxNavBarSkinNavPaneViewInfo(ViewInfo) do
      AImageAreaWidth := 2 * GetOverflowPanelPopupMenuImageIndent + GetSmallImageWidth;

    ABuf := TcxBitmap.CreateSize(ARect);
    try
      ABuf.Canvas.Font := ACanvas.Font;
      ABuf.PixelFormat := pf32bit;
      DrawMenuBackground(ABuf.Canvas, AImageAreaWidth);
      if AText = '-' then
        ASeparator.Draw(ABuf.Canvas.Handle, Rect(AImageAreaWidth + 4,
          cxRectHeight(ARect) div 2, ABuf.Width, cxRectHeight(ARect) div 2 + 1))
      else
      begin
        if sSelected in State then
        begin
          R := ARect;
          OffsetRect(R, -R.Left, -R.Top);
          ASelected.Draw(ABuf.Canvas.Handle, R);
        end;
        DrawImage(ABuf.Canvas, sActive in State, AImageAreaWidth);
        DrawItemText(ABuf.Canvas, AImageAreaWidth);
      end;
      BitBlt(ACanvas.Handle, ARect.Left, ARect.Top, ABuf.Width, ABuf.Height,
        ABuf.Canvas.Handle, 0, 0, SRCCOPY);
    finally
      ABuf.Free;
    end;
  end; 
end;

procedure TdxNavBarSkinNavPanePainter.DrawSplitter;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not CustomDrawSplitter then
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavPaneSplitter;
    if AElement = nil then
      inherited DrawSplitter
    else
      AElement.Draw(Canvas.Handle, ViewInfo.SplitterRect);
  end;    
end;

procedure TdxNavBarSkinNavPanePainter.DrawTopScrollButton;
begin
  with ViewInfo do
    if not InternalDrawScrollButton(False, TopScrollButtonRect,
      TopScrollButtonState)
    then
      inherited DrawTopScrollButton;
end;

{ TdxNavBarSkinExplorerBarPainter }

constructor TdxNavBarSkinExplorerBarPainter.Create(ANavBar: TdxCustomNavBar);
begin
  inherited Create(ANavBar);
  FLookAndFeel := TcxLookAndFeel.Create(nil);
  FLookAndFeel.NativeStyle := False;
  FLookAndFeel.OnChanged := LookAndFeelChanged;
end;

destructor TdxNavBarSkinExplorerBarPainter.Destroy;
begin
  FLookAndFeel.Free;
  inherited Destroy;
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawBackground;
var
  ABackground: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  ABackground := nil;
  if GetSkinPainterData(ASkinInfo) then
    ABackground := ASkinInfo.NavBarBackgroundColor;
  if ABackground = nil then
    inherited DrawBackground
  else
    ABackground.Draw(Canvas.Handle, NavBar.ClientRect);
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupBackground(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
begin
  if not IsSkinAvailable then
    inherited DrawGroupBackground(AGroupViewInfo);
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupBorder(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavBarGroupClient;
  if AElement = nil then
    inherited DrawGroupBorder(AGroupViewInfo)
  else
  begin
    AElement.Draw(Canvas.Handle, AGroupViewInfo.ItemsRect);
    if not AGroupViewInfo.IsCaptionVisible then
      DrawGroupTopBorder(AGroupViewInfo);
  end;
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupTopBorder(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  ACanvas: TcxCanvas;
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R: TRect;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavBarGroupHeader;
  if AElement <> nil then
  begin
    ACanvas := TcxCanvas.Create(Canvas);
    try
      ACanvas.SaveClipRegion;
      try
        R := AGroupViewInfo.ItemsRect;
        ACanvas.SetClipRegion(TcxRegion.Create(cxRectSetHeight(R, 1)), roSet);
        R.Bottom := R.Top + 1;
        Dec(R.Top, AElement.Size.cy);
        AElement.Draw(ACanvas.Handle, R);
      finally
        ACanvas.RestoreClipRegion;
      end;
    finally
      ACanvas.Free;
    end;
  end;
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupCaption(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavBarGroupHeader;
  if AElement <> nil then
  begin
    AElement.Draw(Canvas.Handle, AGroupViewInfo.CaptionRect);
    DrawGroupCaptionButton(AGroupViewInfo);
    DrawGroupCaptionText(AGroupViewInfo);
    if AGroupViewInfo.IsCaptionImageVisible then
      DrawGroupCaptionImage(AGroupViewInfo);
  end else
    inherited DrawGroupCaption(AGroupViewInfo);
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupCaptionButton(
  AGroupViewInfo: TdxNavBarGroupViewInfo);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  with AGroupViewInfo do
  begin
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavBarGroupButtons[sExpanded in State];
    if AElement = nil then
      inherited DrawGroupCaptionButton(AGroupViewInfo)
    else
      if Group.ShowExpandButton then
        AElement.Draw(Canvas.Handle, AGroupViewInfo.CaptionSignRect, 0,
          NavBarObjectStateToSkinState(State));
  end;
end;

procedure TdxNavBarSkinExplorerBarPainter.DrawGroupControl(ACanvas: TCanvas;
  ARect: TRect; AGroupViewInfo: TdxNavBarGroupViewInfo); 
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.NavBarGroupClient;

  if AElement = nil then
    inherited DrawGroupControl(ACanvas, ARect, AGroupViewInfo)
  else
    AElement.Draw(ACanvas.Handle, cxRectInflate(ARect, 1, 0, 1, 1));
end;

function TdxNavBarSkinExplorerBarPainter.CreateGroupViewInfo(
  AViewInfo: TdxNavBarViewInfo; AGroup: TdxNavBarGroup; ACaptionVisible: Boolean;
  AItemsVisible: Boolean): TdxNavBarGroupViewInfo;
begin
  Result := TdxNavBarSkinExplorerBarGroupViewInfo.Create(AViewInfo, AGroup,
    ACaptionVisible, AItemsVisible);
end;

function TdxNavBarSkinExplorerBarPainter.CreateLinkViewInfo(
  AViewInfo: TdxNavBarGroupViewInfo; ALink: TdxNavBarItemLink; ACaptionVisible: Boolean;
  AImageVisisble: Boolean): TdxNavBarLinkViewInfo;
begin
  Result := TdxNavBarSkinExplorerBarLinkViewInfo.Create(AViewInfo, ALink,
    ACaptionVisible, AImageVisisble);
end;

function TdxNavBarSkinExplorerBarPainter.GetMasterLookAndFeel: TcxLookAndFeel;
begin
  Result := FLookAndFeel;
end;

function TdxNavBarSkinExplorerBarPainter.GetSkinPainterData(
  var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(FLookAndFeel.SkinPainter, AData);
end;

function TdxNavBarSkinExplorerBarPainter.IsSkinAvailable: Boolean;
begin
  Result := FLookAndFeel.SkinPainter <> nil;
end;

procedure TdxNavBarSkinExplorerBarPainter.LookAndFeelChanged(
  Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  NavBar.InvalidateAll(doRecreate);
end;

function TdxNavBarSkinExplorerBarPainter.IsSkinNameStored: Boolean;
begin
  Result := SkinNameAssigned;
end;

function TdxNavBarSkinExplorerBarPainter.GetSkinName: TdxSkinName;
begin
  Result := FLookAndFeel.SkinName;
end;

procedure TdxNavBarSkinExplorerBarPainter.SetSkinName(const Value: TdxSkinName);
begin
  FLookAndFeel.SkinName := Value;
end;

function TdxNavBarSkinExplorerBarPainter.GetSkinNameAssigned: Boolean;
begin
  Result := lfvSkinName in FLookAndFeel.AssignedValues;
end;

procedure TdxNavBarSkinExplorerBarPainter.SetSkinNameAssigned(AValue: Boolean);
begin
  if AValue then
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues + [lfvSkinName]
  else
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues - [lfvSkinName];
end;

{ TdxNavBarSkinExplorerBarGroupViewInfo }

function TdxNavBarSkinExplorerBarGroupViewInfo.CaptionFontColor: TColor;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  with TdxNavBarSkinExplorerBarPainter(Painter) do
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavBarGroupHeader;
    if AElement <> nil then
      Result := AElement.TextColor
    else
      Result := inherited CaptionFontColor;
  end;
end;

procedure TdxNavBarSkinExplorerBarGroupViewInfo.CalculateBounds(X: Integer; Y: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  inherited CalculateBounds(X, Y);
  with TdxNavBarSkinExplorerBarPainter(Painter) do
  begin
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavBarGroupHeader
    else
      AElement := nil;
    if (AElement <> nil) and IsCaptionVisible and not IsRectEmpty(FCaptionImageRect) then
    begin
      OffsetRect(FCaptionImageRect, AElement.ContentOffset.Left, 0);
      Inc(FCaptionTextRect.Left, AElement.ContentOffset.Left);
    end;
  end;
end;

{ TdxNavBarSkinExplorerBarLinkViewInfo }

function TdxNavBarSkinExplorerBarLinkViewInfo.FontColor: TColor;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  with TdxNavBarSkinExplorerBarPainter(Painter) do
  begin
    AElement := nil;
    if GetSkinPainterData(ASkinInfo) then
      AElement := ASkinInfo.NavBarItem;
    if AElement <> nil then
      Result := AElement.TextColor
    else
      Result := inherited FontColor;
  end;
end;

initialization
  dxNavBarViewsFactory.RegisterView(dxNavBarSkinExplorerBarView,
    'SkinExplorerBarView', TdxNavBarSkinExplorerBarPainter);
  dxNavBarViewsFactory.RegisterView(dxNavBarSkinNavigatorPaneView,
    'SkinNavigationPaneView', TdxNavBarSkinNavPanePainter);
  RegisterClasses([TdxNavBarSkinNavPanePainter, TdxNavBarSkinExplorerBarPainter]);

finalization
  dxNavBarViewsFactory.UnRegisterView(dxNavBarSkinExplorerBarView);
  dxNavBarViewsFactory.UnRegisterView(dxNavBarSkinNavigatorPaneView);

end.
