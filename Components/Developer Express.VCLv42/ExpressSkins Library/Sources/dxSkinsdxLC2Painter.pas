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

unit dxSkinsdxLC2Painter;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Controls, Graphics, cxGraphics, dxLayoutCommon,
  dxLayoutLookAndFeels, dxLayoutControl, cxLookAndFeels, cxClasses,
  dxSkinsLookAndFeelPainter, dxSkinsCore, cxLookAndFeelPainters, dxLayoutPainters;

type
  { TdxLayoutSkinLookAndFeel }

  TdxLayoutSkinLookAndFeel = class(TdxLayoutStandardLookAndFeel)
  private
    FLookAndFeel: TcxLookAndFeel;
    FPainterData: TdxSkinLookAndFeelPainterInfo;
    function GetSkinNameAssigned: Boolean;
    function GetSkinName: TdxSkinName;
    function IsSkinNameStored: Boolean;
    procedure SetSkinNameAssigned(AValue: Boolean);
    procedure SetSkinName(const AValue: TdxSkinName);
  protected
    function ForceControlArrangement: Boolean; override;
    function GetGroupBoxElement(APosition: TcxGroupBoxCaptionPosition; ACaption: Boolean = False): TdxSkinElement;
    function GetGroupOptionsClass: TdxLayoutLookAndFeelGroupOptionsClass; override;
    function GetInternalName: string; override;
    function IsSkinDataAssigned: Boolean;
    procedure SetInternalName(const AValue: string); override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
    procedure UpdateSkinInfo;

    property PainterData: TdxSkinLookAndFeelPainterInfo read FPainterData;
  public
    class function Description: String; override;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetEmptyAreaColor: TColor; override;
    function GetGroupBorderWidth(AControl: TControl; ASide: TdxLayoutSide;
      AHasCaption: Boolean): Integer; override;
    function GetGroupPainterClass: TClass; override;
    function GetGroupViewInfoClass: TClass; override;
    function GetItemPainterClass: TClass; override;

    property LookAndFeel: TcxLookAndFeel read FLookAndFeel;
  published
    property SkinName: TdxSkinName read GetSkinName write SetSkinName stored IsSkinNameStored;
    property SkinNameAssigned: Boolean read GetSkinNameAssigned write SetSkinNameAssigned default False;
  end;

  { TdxLayoutGroupCaptionSkinPainter }

  TdxLayoutGroupCaptionSkinPainter = class(TdxLayoutGroupCaptionPainter)
  private
    function GetLookAndFeel: TdxLayoutSkinLookAndFeel;
  protected
    procedure BeforeDrawText; override;
    procedure DrawBackground; override;

    property LookAndFeel: TdxLayoutSkinLookAndFeel read GetLookAndFeel;
  end;

  { TdxLayoutGroupSkinViewInfo }

  TdxLayoutGroupSkinViewInfo = class(TdxLayoutGroupStandardViewInfo)
  private
    function GetCaptionBorderSize: TRect;
    function GetLookAndFeel: TdxLayoutSkinLookAndFeel;
    function IsSkinAvalaible: Boolean;
  protected
    function CalculateCaptionViewInfoBounds: TRect; override;
    function GetClientBounds: TRect; override;
    function GetColor: TColor; override;
    function GetFrameBounds: TRect; override;
    function GetIsTransparent: Boolean; override;
    function HasSkinBackground: Boolean; virtual;

    property LookAndFeel: TdxLayoutSkinLookAndFeel read GetLookAndFeel;
  end;

  { TdxLayoutGroupSkinPainter }

  TdxLayoutGroupSkinPainter = class(TdxLayoutGroupStandardPainter)
  private
    function GetLookAndFeel: TdxLayoutSkinLookAndFeel;
    function GetViewInfo: TdxLayoutGroupSkinViewInfo;
    procedure DrawBorderCaptionPart(ACanvas: TcxCanvas; const ABounds: TRect;
      ACaptionElement: TdxSkinElement);
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
    function GetPainerData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
    function IsParentBackground: Boolean; virtual;
    procedure DrawBorders; override;
    procedure DrawCaption; override;
    procedure DrawItemsArea; override;

    property ViewInfo: TdxLayoutGroupSkinViewInfo read GetViewInfo;
  public
    procedure Paint; override;

    property LookAndFeel: TdxLayoutSkinLookAndFeel read GetLookAndFeel;
  end;

  { TdxLayoutItemCaptionSkinPainter }

  TdxLayoutItemCaptionSkinPainter = class(TdxLayoutItemCaptionPainter)
  protected
    procedure BeforeDrawText; override;
    procedure DrawBackground; override;
  end;

  { TdxLayoutItemSkinPainter }

  TdxLayoutItemSkinPainter = class(TdxLayoutItemPainter)
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
    function GetPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
  end;

  { TdxLayoutSkinLookAndFeelGroupOptions }

  TdxLayoutSkinLookAndFeelGroupOptions = class(TdxLayoutStandardLookAndFeelGroupOptions)
  protected
    function GetCaptionOptionsClass: TdxLayoutLookAndFeelCaptionOptionsClass; override;
  end;

  { TdxLayoutSkinLookAndFeelGroupCaptionOptions }

  TdxLayoutSkinLookAndFeelGroupCaptionOptions = class(TdxLayoutStandardLookAndFeelGroupCaptionOptions)
  private
    function GetLookAndFeel: TdxLayoutSkinLookAndFeel;
    function GetOptions: TdxLayoutSkinLookAndFeelGroupOptions;
  protected
    function GetDefaultTextColor: TColor; override;
    // Properties
    property LookAndFeel: TdxLayoutSkinLookAndFeel read GetLookAndFeel;
    property Options: TdxLayoutSkinLookAndFeelGroupOptions read GetOptions;
  end;

implementation

type
  TdxLayoutItemViewInfoAccess = class(TdxLayoutItemViewInfo);
  TdxLayoutGroupViewInfoAccess = class(TdxLayoutGroupViewInfo);
  TdxLayoutControlViewInfoAccess = class(TdxLayoutControlViewInfo);
  
{ TdxLayoutSkinLookAndFeel }

constructor TdxLayoutSkinLookAndFeel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := LookAndFeelChanged;
  UpdateSkinInfo;
end;

destructor TdxLayoutSkinLookAndFeel.Destroy;
begin
  FLookAndFeel.Free;
  inherited Destroy;
end;

procedure TdxLayoutSkinLookAndFeel.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  UpdateSkinInfo;
  if [lfvSkinName, lfvNativeStyle] * AChangedValues <> [] then
    Changed;
end;

procedure TdxLayoutSkinLookAndFeel.UpdateSkinInfo;
begin
  GetExtendedStylePainters.GetPainterData(LookAndFeel.SkinPainter, FPainterData);
end;

class function TdxLayoutSkinLookAndFeel.Description: String;
begin
  Result := 'Skin';
end;

function TdxLayoutSkinLookAndFeel.GetEmptyAreaColor: TColor;
var
  AElement: TdxSkinColor;
begin
  if IsSkinDataAssigned then
    AElement := PainterData.LayoutControlColor
  else
    AElement := nil;
    
  if AElement = nil then
    Result := inherited GetEmptyAreaColor
  else
    Result := AElement.Value;
    
  if Result = clDefault then
    Result := clBtnFace;
end;

function TdxLayoutSkinLookAndFeel.GetGroupBorderWidth(AControl: TControl;
  ASide: TdxLayoutSide; AHasCaption: Boolean): Integer;
var
  AGroupBox: TdxSkinElement;
  AFont: TFont;
begin
  AGroupBox := GetGroupBoxElement(cxgpTop, True);
  if AGroupBox = nil then
    Result := inherited GetGroupBorderWidth(AControl, ASide, AHasCaption)
  else
  begin
    AFont := GetGroupCaptionFont(AControl);
    if ASide in [sdTop, sdBottom] then
    begin
      Result := DLUToPixels(AFont, 4);
      if (ASide = sdTop) and AHasCaption then
        Inc(Result, VDLUToPixels(AFont, 11));
    end
    else
      Result := DLUToPixels(AFont, 2);
    if AHasCaption then
      with AGroupBox.ContentOffset.Rect do
        Result := Top + Bottom + Result;
  end;
end;

function TdxLayoutSkinLookAndFeel.GetGroupPainterClass: TClass;
begin
  Result := TdxLayoutGroupSkinPainter;
end;

function TdxLayoutSkinLookAndFeel.GetGroupViewInfoClass: TClass;
begin
  Result := TdxLayoutGroupSkinViewInfo;
end;

function TdxLayoutSkinLookAndFeel.GetItemPainterClass: TClass;
begin
  Result := TdxLayoutItemSkinPainter;
end;

function TdxLayoutSkinLookAndFeel.ForceControlArrangement: Boolean;
begin
  if IsSkinDataAssigned then
    Result := True
  else
    Result := inherited ForceControlArrangement;
end;

function TdxLayoutSkinLookAndFeel.GetGroupBoxElement(
  APosition: TcxGroupBoxCaptionPosition; ACaption: Boolean = False): TdxSkinElement;
begin
  if not IsSkinDataAssigned then
    Result := nil
  else
    if ACaption then
      Result := PainterData.GroupBoxCaptionElements[APosition]
    else
      Result := PainterData.GroupBoxElements[APosition];
end;

function TdxLayoutSkinLookAndFeel.GetGroupOptionsClass: TdxLayoutLookAndFeelGroupOptionsClass;
begin
  Result := TdxLayoutSkinLookAndFeelGroupOptions;
end;

function TdxLayoutSkinLookAndFeel.GetInternalName: string;
begin
  Result := FLookAndFeel.SkinName;
end;

procedure TdxLayoutSkinLookAndFeel.SetInternalName(const AValue: string);
var
  I: Integer;
begin
  FLookAndFeel.SkinName := AValue;
  for I := 0 to UserCount - 1 do
    Users[I].LookAndFeelChanged;
end;

function TdxLayoutSkinLookAndFeel.IsSkinNameStored: Boolean;
begin
  Result := SkinNameAssigned;
end;

function TdxLayoutSkinLookAndFeel.IsSkinDataAssigned: Boolean;
begin
  Result := PainterData <> nil;
end;

function TdxLayoutSkinLookAndFeel.GetSkinName: TdxSkinName;
begin
  Result := InternalName;
end;

procedure TdxLayoutSkinLookAndFeel.SetSkinName(const AValue: TdxSkinName);
begin
  InternalName := AValue;
end;

function TdxLayoutSkinLookAndFeel.GetSkinNameAssigned: Boolean;
begin
  Result := lfvSkinName in FLookAndFeel.AssignedValues
end;

procedure TdxLayoutSkinLookAndFeel.SetSkinNameAssigned(AValue: Boolean);
begin
  if AValue then
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues + [lfvSkinName]
  else
    FLookAndFeel.AssignedValues := FLookAndFeel.AssignedValues - [lfvSkinName];
end;

{ TdxLayoutSkinLookAndFeelGroupOptions }

function TdxLayoutSkinLookAndFeelGroupOptions.GetCaptionOptionsClass: TdxLayoutLookAndFeelCaptionOptionsClass;
begin
  Result := TdxLayoutSkinLookAndFeelGroupCaptionOptions;
end;

{ TdxLayoutSkinLookAndFeelGroupCaptionOptions }

function TdxLayoutSkinLookAndFeelGroupCaptionOptions.GetDefaultTextColor: TColor;
var
  ASkinElement: TdxSkinElement;
begin
  ASkinElement := LookAndFeel.GetGroupBoxElement(cxgpTop, True);
  if ASkinElement = nil then
    Result := inherited GetDefaultTextColor
  else
    Result := ASkinElement.TextColor;
end;

function TdxLayoutSkinLookAndFeelGroupCaptionOptions.GetLookAndFeel: TdxLayoutSkinLookAndFeel;
begin
  Result := TdxLayoutSkinLookAndFeel(Options.LookAndFeel);
end;

function TdxLayoutSkinLookAndFeelGroupCaptionOptions.GetOptions: TdxLayoutSkinLookAndFeelGroupOptions;
begin
  Result := TdxLayoutSkinLookAndFeelGroupOptions(inherited Options);
end;

{ TdxLayoutGroupCaptionSkinPainter }

function TdxLayoutGroupCaptionSkinPainter.GetLookAndFeel: TdxLayoutSkinLookAndFeel;
begin
  Result := TdxLayoutSkinLookAndFeel(inherited LookAndFeel);
end;

procedure TdxLayoutGroupCaptionSkinPainter.BeforeDrawText;
begin
  Canvas.Font := ViewInfo.Font;
  Canvas.Font.Color := ViewInfo.TextColor;
  if ViewInfo.IsTextUnderlined then
    Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  Canvas.Brush.Style := bsClear;
end;

procedure TdxLayoutGroupCaptionSkinPainter.DrawBackground;
begin
  if not LookAndFeel.IsSkinDataAssigned then
    inherited DrawBackground;
end;

{ TdxLayoutGroupSkinViewInfo }

function TdxLayoutGroupSkinViewInfo.CalculateCaptionViewInfoBounds: TRect;
var
  ACaptionWidth: Integer;
begin
  if not IsSkinAvalaible then
    Result := inherited CalculateCaptionViewInfoBounds
  else
  begin
    Result := BorderBounds[sdTop];
    with GetCaptionBorderSize do
    begin
      Inc(Result.Top, Top);
      Dec(Result.Bottom, Bottom);
    end;
    ACaptionWidth := CaptionViewInfo.CalculateWidth;
    with Result do
    begin
      case Item.CaptionOptions.AlignHorz of
        taLeftJustify:
          begin
            Inc(Left, CaptionViewInfoOffset);
            Right := Left + ACaptionWidth;
          end;
        taRightJustify:
          begin
            Dec(Right, CaptionViewInfoOffset);
            Left := Right - ACaptionWidth;
          end;
        taCenter:
          begin
            Left := (Left + Right - ACaptionWidth) div 2;
            Right := Left + ACaptionWidth;
          end;
      end;
      Top := (Result.Bottom + Result.Top - CaptionViewInfo.CalculateHeight) div 2;
    end;
  end;
end;

function TdxLayoutGroupSkinViewInfo.GetCaptionBorderSize: TRect;
var
  AGroupBoxCaption: TdxSkinElement;
begin
  AGroupBoxCaption := LookAndFeel.GetGroupBoxElement(cxgpTop, True);
  if AGroupBoxCaption = nil then
    Result := cxEmptyRect
  else
    Result := AGroupBoxCaption.ContentOffset.Rect;
end;

function TdxLayoutGroupSkinViewInfo.GetLookAndFeel: TdxLayoutSkinLookAndFeel;
begin
  Result := TdxLayoutSkinLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupSkinViewInfo.IsSkinAvalaible: Boolean;
begin
  Result := LookAndFeel.IsSkinDataAssigned;
end;

function TdxLayoutGroupSkinViewInfo.GetClientBounds: TRect;
var
  ACaptionHeight: Integer;
  AGroupBox: TdxSkinElement;
begin
  AGroupBox := LookAndFeel.GetGroupBoxElement(cxgpTop);
  if AGroupBox = nil then
    Result := inherited GetClientBounds
  else
  begin
    Result := Bounds;
    if HasBorder then
    begin
      ACaptionHeight := CaptionViewInfo.CalculateHeight;
      if ACaptionHeight <> 0 then
        with GetCaptionBorderSize do
          ACaptionHeight := ACaptionHeight + Top + Bottom;
      with AGroupBox.ContentOffset.Rect do
      begin
        Inc(Result.Left, Left);
        Inc(Result.Top, Top +  ACaptionHeight);
        Dec(Result.Right, Right);
        Dec(Result.Bottom, Bottom);
      end;
    end;
  end;
end;

function TdxLayoutGroupSkinViewInfo.GetColor: TColor;
var
  ALayoutControl: TdxSkinColor;
begin
  if IsSkinAvalaible then
    ALayoutControl := LookAndFeel.PainterData.LayoutControlColor
  else
    ALayoutControl := nil;

  if ALayoutControl = nil then
    Result := inherited GetColor
  else
    Result := ALayoutControl.Value;
end;

function TdxLayoutGroupSkinViewInfo.GetFrameBounds: TRect;
begin
  if not IsSkinAvalaible then
    Result := inherited GetFrameBounds
  else
  begin
    Result := Bounds;
    Result.Top := BorderBounds[sdTop].Bottom;
  end;
end;

function TdxLayoutGroupSkinViewInfo.GetIsTransparent: Boolean;
begin
  if IsSkinAvalaible then
    Result := HasSkinBackground
  else
    Result := inherited GetIsTransparent;
end;

function TdxLayoutGroupSkinViewInfo.HasSkinBackground: Boolean;
begin
  Result := Group.ShowBorder;
  if not Result and (Group.Parent <> nil) and (ParentViewInfo is TdxLayoutGroupSkinViewInfo) then
    Result := TdxLayoutGroupSkinViewInfo(ParentViewInfo).HasSkinBackground
  else
    if Group.Parent = nil then
      Result := inherited GetIsTransparent;
end;

{ TdxLayoutGroupSkinPainter }

function TdxLayoutGroupSkinPainter.GetLookAndFeel: TdxLayoutSkinLookAndFeel;
begin
  Result := TdxLayoutSkinLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupSkinPainter.GetViewInfo: TdxLayoutGroupSkinViewInfo;
begin
  Result := TdxLayoutGroupSkinViewInfo(inherited ViewInfo);
end;

procedure TdxLayoutGroupSkinPainter.DrawBorders;
var
  AGroupBox: TdxSkinElement;
begin
  AGroupBox := LookAndFeel.GetGroupBoxElement(cxgpTop);
  if AGroupBox = nil then
    inherited DrawBorders
  else
    with TdxLayoutGroupSkinViewInfo(ViewInfo) do
    begin
      if not IsParentBackground then
        AGroupBox.Draw(Canvas.Handle, FrameBounds);
      if not HasCaption then
        DrawBorderCaptionPart(Canvas, FrameBounds,
          Self.LookAndFeel.GetGroupBoxElement(cxgpTop, True));
    end;
end;

procedure TdxLayoutGroupSkinPainter.DrawCaption;
var
  ACaption: TdxSkinElement;
  ACaptionRect: TRect;
begin
  ACaption := LookAndFeel.GetGroupBoxElement(cxgpTop, True);
  if Assigned(ACaption) then
    with ViewInfo do
    begin
      ACaptionRect := Bounds;
      ACaptionRect.Bottom := FrameBounds.Top;
      ACaption.Draw(Canvas.Handle, ACaptionRect);
    end;
  inherited DrawCaption;
end;

procedure TdxLayoutGroupSkinPainter.DrawBorderCaptionPart(ACanvas: TcxCanvas;
  const ABounds: TRect; ACaptionElement: TdxSkinElement);
var
  ACaptionRect: TRect;
begin
  if ACaptionElement <> nil then
  begin
    ACanvas.SaveClipRegion;
    try
      ACaptionRect := ABounds;
      ACanvas.SetClipRegion(TcxRegion.Create(ACaptionRect), roIntersect);
      ACaptionRect.Bottom := ACaptionRect.Top + ACaptionElement.Size.cy;
      OffsetRect(ACaptionRect, 0, -ACaptionElement.Size.cy + 1);
      ACaptionElement.Draw(ACanvas.Handle, ACaptionRect);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;  
end;

procedure TdxLayoutGroupSkinPainter.DrawItemsArea;
var
  AContent: TdxSkinColor;
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not TdxLayoutGroupSkinViewInfo(ViewInfo).IsTransparent then
  begin
    AContent := nil;
    if GetPainerData(ASkinPainterInfo) then
      AContent := ASkinPainterInfo.LayoutControlColor;
    if AContent = nil then
      inherited DrawItemsArea
    else
      Canvas.FillRect(ViewInfo.ClientBounds, AContent.Value);
  end;
end;

function TdxLayoutGroupSkinPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutGroupCaptionSkinPainter;
end;

function TdxLayoutGroupSkinPainter.GetPainerData(
  var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  AData := TdxLayoutSkinLookAndFeel(LookAndFeel).PainterData;
  Result := AData <> nil;
end;

function TdxLayoutGroupSkinPainter.IsParentBackground: Boolean;
begin
  with TdxLayoutGroupSkinViewInfo(ViewInfo) do
    Result := TdxLayoutControlViewInfoAccess(ContainerViewInfo).HasBackground;
end;

procedure TdxLayoutGroupSkinPainter.Paint;
begin
  inherited Paint;
  with TdxLayoutGroupSkinViewInfo(ViewInfo) do
    if not IsTransparent then
      Canvas.FillRect(ClientBounds, LookAndFeel.GetEmptyAreaColor)
end;

{ TdxLayoutItemSkinPainter }

function TdxLayoutItemSkinPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutItemCaptionSkinPainter;
end;

function TdxLayoutItemSkinPainter.GetPainterData(
  var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  AData := TdxLayoutSkinLookAndFeel(LookAndFeel).PainterData;
  Result := AData <> nil;
end;

{ TdxLayoutItemCaptionSkinPainter }

procedure TdxLayoutItemCaptionSkinPainter.BeforeDrawText;
begin
  Canvas.Font := ViewInfo.Font;
  Canvas.Font.Color := ViewInfo.TextColor;
  if ViewInfo.IsTextUnderlined then
    Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  Canvas.Brush.Style := bsClear;
end;

procedure TdxLayoutItemCaptionSkinPainter.DrawBackground;
begin
end;

initialization
  dxLayoutLookAndFeelDefs.Register(TdxLayoutSkinLookAndFeel);

finalization
  dxLayoutLookAndFeelDefs.Unregister(TdxLayoutStandardLookAndFeel);

end.
