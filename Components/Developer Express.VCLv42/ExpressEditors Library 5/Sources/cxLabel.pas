
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
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

unit cxLabel;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  Windows, Classes, Controls, Forms, Graphics, Messages, SysUtils, cxClasses,
  cxContainer, cxControls, cxCustomData, cxDataUtils, cxEdit, cxExtEditConsts,
  cxGraphics, cxTextEdit, cxVariants, cxLookAndFeelPainters;

type
  TcxLabelEffect = (cxleNormal, cxleFun, cxleExtrude, cxleCool);
  TcxLabelLineAlignment = (cxllaTop, cxllaCenter, cxllaBottom);
  TcxLabelLineOrientation = (cxlloHorizontal, cxlloVertical);
  TcxLabelStyle = (cxlsNormal, cxlsRaised, cxlsLowered, cxlsOutLine);
  TcxLabelOrientation = (cxoLeft, cxoRight, cxoTop, cxoBottom, cxoLeftTop,
    cxoLeftBottom, cxoRightTop, cxoRightBottom);

  TcxCustomLabel = class;

  { TcxLabelEditStyle }

  TcxLabelEditStyle = class(TcxEditStyle)
  protected
    function DefaultBorderStyle: TcxContainerBorderStyle; override;
    function DefaultHotTrack: Boolean; override;
  end;

  { TcxLabelLineOptions }

  TcxLabelLineOptions = class(TPersistent)
  private
    FAlignment: TcxLabelLineAlignment;
    FInnerColor: TColor;
    FOnChanged: TNotifyEvent;
    FOuterColor: TColor;
    FVisible: Boolean;
    function GetIsCustomColorsAssigned: Boolean;
    procedure SetAlignment(AValue: TcxLabelLineAlignment);
    procedure SetInnerColor(AValue: TColor);
    procedure SetOuterColor(AValue: TColor);
    procedure SetVisible(AValue: Boolean);
  protected
    procedure Changed; virtual;
    
    property IsCustomColorsAssigned: Boolean read GetIsCustomColorsAssigned;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  public
    constructor Create; virtual;
    procedure Assign(Source: TPersistent); override;
  published
    property Alignment: TcxLabelLineAlignment read FAlignment write SetAlignment default cxllaCenter;
    property InnerColor: TColor read FInnerColor write SetInnerColor default clDefault;
    property OuterColor: TColor read FOuterColor write SetOuterColor default clDefault;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  { TcxCustomLabelViewInfo }

  TcxCustomLabelViewInfo = class(TcxCustomTextEditViewInfo)
  private
    FAlignment: TcxEditAlignment;
    FAngle: Integer;
    FDepth: Word;
    FDepthDeltaSize: TSize;
    FDrawBitmap: TcxBitmap;
    FGlyph: TBitmap;
    FInplaceOffset: TPoint;
    FIsDrawBitmapDirty: Boolean;
    FLabelEffect: TcxLabelEffect;
    FLabelStyle: TcxLabelStyle;
    FLabelStyleOffset: Integer;
    FLabelTextRect: TRect;
    FLineInnerColor: TColor;
    FLineOrientation: TcxLabelLineOrientation;
    FLineOuterColor: TColor;
    FLineRect: TRect;
    FOrientation: TcxLabelOrientation;
    FPenWidth: Integer;
    FShadowedColor: TColor;
    FWordWrap: Boolean;
  protected
    procedure InternalDrawBackground(ACanvas, ASource: TcxCanvas; const R: TRect;
      AParentBackgroundOffset: TPoint); virtual;
    procedure SetBackgroundColor(Value: TColor); override;

    property Alignment: TcxEditAlignment read FAlignment write FAlignment;
    property Angle: Integer read FAngle write FAngle;
    property Depth: Word read FDepth write FDepth;
    property DepthDeltaSize: TSize read FDepthDeltaSize write FDepthDeltaSize;
    property Glyph: TBitmap read FGlyph write FGlyph;
    property LabelEffect: TcxLabelEffect read FLabelEffect write FLabelEffect;
    property LabelStyle: TcxLabelStyle read FLabelStyle write FLabelStyle;
    property LabelStyleOffset: Integer read FLabelStyleOffset write FLabelStyleOffset;
    property LabelTextRect: TRect read FLabelTextRect write FLabelTextRect;
    property LineInnerColor: TColor read FLineInnerColor write FLineInnerColor;
    property LineOrientation: TcxLabelLineOrientation read FLineOrientation write FLineOrientation;
    property LineOuterColor: TColor read FLineOuterColor write FLineOuterColor;
    property LineRect: TRect read FLineRect write FLineRect;
    property Orientation: TcxLabelOrientation read FOrientation write FOrientation;
    property PenWidth: Integer read FPenWidth write FPenWidth;
    property ShadowedColor: TColor read FShadowedColor write FShadowedColor;
    property WordWrap: Boolean read FWordWrap write FWordWrap;
  public
    DrawTextOffsets: TRect;
    FocusRect: TRect;
    HasGlyph: Boolean;
    LeftTop: TPoint;
    ShowAccelChar: Boolean;
    constructor Create; override;
    destructor Destroy; override;
    procedure Offset(DX, DY: Integer); override;
    procedure Paint(ACanvas: TcxCanvas); override;
    procedure DrawLabel(ACanvas: TcxCanvas); virtual;
  end;

  { TcxCustomLabelViewData }

  TcxCustomLabelProperties = class;

  TcxCustomLabelViewData = class(TcxCustomEditViewData)
  private
    function GetLineOptions: TcxLabelLineOptions;
    function GetProperties: TcxCustomLabelProperties;
    procedure CalculateLabelViewInfoProps(AViewInfo: TcxCustomEditViewInfo);
  protected
    function CalculateLabelStyleOffset(ACanvas: TcxCanvas): Integer; virtual;
    function CalculateLineRect(var ATextRect: TRect; const ABounds: TRect;
      AAlignment: TcxLabelLineAlignment; AVisible: Boolean; ALineHeight: Integer;
      AOrientation: TcxLabelLineOrientation): TRect; virtual;
    function CalculateTextRect(const R: TRect; const ATextSize: TSize): TRect; virtual;
    function CalculateTextSize(ACanvas: TcxCanvas; const R: TRect; AText: string): TSize; virtual;
    procedure CalculateViewParams(ACanvas: TcxCanvas; AViewInfo: TcxCustomLabelViewInfo);
    function GetDrawTextFlags: Integer; virtual;
    function GetIsEditClass: Boolean;
    function GetLineHeight: Integer; virtual;
    function InternalEditValueToDisplayText(AEditValue: TcxEditValue): string; override;
    function IsLineVisible(ARealAngle: Integer): Boolean; virtual;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    function GetEditContentSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;

    property LineOptions: TcxLabelLineOptions read GetLineOptions;
    property Properties: TcxCustomLabelProperties read GetProperties;
  end;

  { TcxCustomLabelProperties }

  TcxCustomLabelProperties = class(TcxCustomEditProperties)
  private
    FAngle: Integer;
    FDepth: Word;
    FGlyph: TBitmap;
    FLabelEffect: TcxLabelEffect;
    FLabelStyle: TcxLabelStyle;
    FLineOptions: TcxLabelLineOptions;
    FOrientation: TcxLabelOrientation;
    FPenWidth: Integer;
    FShadowedColor: TColor;
    FShowAccelChar: Boolean;
    FShowEndEllipsis: Boolean; // deprecated
    FWordWrap: Boolean;
    procedure SetAngle(Value: Integer);
    procedure SetDepth(Value : Word);
    procedure SetLabelEffect(Value : TcxLabelEffect);
    procedure SetLabelStyle(Value : TcxLabelStyle);
    procedure SetLineOptions(AValue: TcxLabelLineOptions);
    procedure SetOrientation(Value : TcxLabelOrientation);
    procedure SetPenWidth(Value: Integer);
    procedure SetShadowedColor(Value : TColor);
    function GetGlyph: TBitmap;
    procedure DoChanged(Sender: TObject);
    procedure SetGlyph(Value: TBitmap);
    procedure SetShowAccelChar(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
  protected
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
    function CalculateDepthDelta: TSize; virtual;
    function GetDisplayFormatOptions: TcxEditDisplayFormatOptions; override;
    //
    property ShowEndEllipsis: Boolean read FShowEndEllipsis write FShowEndEllipsis stored False; // deprecated
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    class function GetStyleClass: TcxCustomEditStyleClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    // !!!
    property Angle: Integer read FAngle write SetAngle default 0;
    property Depth: Word read FDepth write SetDepth default 0;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property LabelEffect: TcxLabelEffect read FLabelEffect write SetLabelEffect default cxleNormal;
    property LabelStyle: TcxLabelStyle read FLabelStyle write SetLabelStyle default cxlsNormal;
    property LineOptions: TcxLabelLineOptions read FLineOptions write SetLineOptions;
    property Orientation: TcxLabelOrientation read FOrientation write SetOrientation default cxoRightBottom;
    property PenWidth: Integer read FPenWidth write SetPenWidth default 1;
    property ShadowedColor: TColor read FShadowedColor write SetShadowedColor default clGrayText;
    property ShowAccelChar: Boolean read FShowAccelChar write SetShowAccelChar default True;
    property Transparent; // deprecated
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  { TcxLabelProperties }

  TcxLabelProperties = class(TcxCustomLabelProperties)
  published
    property Alignment;
    property Angle;
    property Depth;
    property Glyph;
    property LabelEffect;
    property LabelStyle;
    property LineOptions;
    property Orientation;
    property PenWidth;
    property ShadowedColor;
    property ShowAccelChar;
    property ShowEndEllipsis; // deprecated
    property Transparent; // deprecated
    property WordWrap;
  end;

  { TcxCustomLabel }

  TcxCustomLabel = class(TcxCustomEdit)
  private
    FFocusControl: TWinControl;
    FLockCaption: Boolean;
    function GetProperties: TcxCustomLabelProperties;
    function GetActiveProperties: TcxCustomLabelProperties;
    function GetStyle: TcxLabelEditStyle;
    function GetViewInfo: TcxCustomLabelViewInfo;
    procedure SetFocusControl(Value: TWinControl);
    procedure SetProperties(Value: TcxCustomLabelProperties);
    procedure SetStyle(Value: TcxLabelEditStyle);
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
  protected
    function GetEditStateColorKind: TcxEditStateColorKind; override;
    procedure Initialize; override;
    procedure InternalSetEditValue(const Value: TcxEditValue; AValidateEditValue: Boolean); override;
    procedure Loaded; override;
    procedure SetInternalDisplayValue(Value: TcxEditValue); override;
    procedure DoAutoSizeChanged; override;
    procedure TextChanged; override;
    function CanAutoWidth: Boolean; override;
    function CanFocusOnClick: Boolean; override;
    function DefaultParentColor: Boolean; override;
    procedure Notification(ACOmponent: TComponent; Operation: TOperation); override;
    procedure PropertiesChanged(Sender: TObject); override;
    function UseAnchorX: Boolean; override;
    function UseAnchorY: Boolean; override;

    property FocusControl: TWinControl read FFocusControl write SetFocusControl;
    property ViewInfo: TcxCustomLabelViewInfo read GetViewInfo;
  public
    destructor Destroy; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    function CanFocus: Boolean; override;
  {$IFDEF DELPHI10}
    function GetTextBaseLine: Integer; override;
    function HasTextBaseLine: Boolean; override;
  {$ENDIF}
    property ActiveProperties: TcxCustomLabelProperties read GetActiveProperties;
    property Caption;
    property Properties: TcxCustomLabelProperties read GetProperties write SetProperties;
    property Style: TcxLabelEditStyle read GetStyle write SetStyle;
    property TabOrder stored False;
    property Transparent;
  end;

  { TcxCustomLabel }

  TcxLabel = class(TcxCustomLabel)
  private
    function GetActiveProperties: TcxLabelProperties;
    function GetProperties: TcxLabelProperties;
    procedure SetProperties(Value: TcxLabelProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxLabelProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Caption;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property Properties: TcxLabelProperties read GetProperties
      write SetProperties;
    property TabOrder;
    property Transparent;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  Math, cxEditConsts, cxEditPaintUtils, cxEditUtils, cxExtEditUtils, dxUxTheme,
  cxGeometry, cxFilterControlUtils, dxThemeConsts, dxThemeManager;

const
  TextFromBorderOffset = 1;
  TextFromLineOffset = 3;

function GetRealTextAngle(AAngle: Integer; AIsTrueTypeFont: Boolean): Integer;
begin
  Result := Integer(AIsTrueTypeFont) * (AAngle mod 360 + 360) mod 360;
end;

procedure CalculateCustomLabelViewInfo(ACanvas: TcxCanvas;
  AViewData: TcxCustomLabelViewData; AViewInfo: TcxCustomLabelViewInfo);

  procedure CheckFocusRectBounds;
  begin
    with AViewInfo do
    begin
      if FocusRect.Left < TextRect.Left - 1 then
        FocusRect.Left := TextRect.Left - 1;
      if FocusRect.Top < TextRect.Top - 1 then
        FocusRect.Top := TextRect.Top - 1;
      if FocusRect.Right > TextRect.Right + 1 then
        FocusRect.Right := TextRect.Right + 1;
      if FocusRect.Bottom > TextRect.Bottom + 1 then
        FocusRect.Bottom := TextRect.Bottom + 1;
    end;
  end;

begin
  with AViewInfo do
  begin
    if not IsInplace and Focused then
      if Length(Text) = 0 then
        FocusRect := cxEmptyRect
      else
      begin
        FocusRect := TextRect;
        InflateRect(FocusRect, 1, 1);
        CheckFocusRectBounds;
      end;
  end;
end;

{ TcxLabelEditStyle }

function TcxLabelEditStyle.DefaultBorderStyle: TcxContainerBorderStyle;
begin
  if IsBaseStyle then
    Result := cbsNone
  else
    Result := inherited DefaultBorderStyle;
end;

function TcxLabelEditStyle.DefaultHotTrack: Boolean;
begin
  Result := False;
end;

{ TcxCustomLabelViewInfo }

constructor TcxCustomLabelViewInfo.Create;
begin
  inherited Create;
  FAlignment := TcxEditAlignment.Create(nil);
  FDrawBitmap := TcxBitmap.Create;
  FInplaceOffset := Point(MaxInt, MaxInt);
end;

destructor TcxCustomLabelViewInfo.Destroy;
begin
  FreeAndNil(FDrawBitmap);
  FreeAndNil(FAlignment);
  inherited;
end;

procedure TcxCustomLabelViewInfo.Offset(DX, DY: Integer);
begin
  inherited Offset(DX, DY);
  OffsetRect(FLabelTextRect, DX, DY);
  OffsetRect(FocusRect, DX, DY);
  if Transparent then
    FIsDrawBitmapDirty := True;
end;

procedure TcxCustomLabelViewInfo.Paint(ACanvas: TcxCanvas);
begin
  DrawCustomEdit(ACanvas, Self, False, bpsSolid);
  DrawLabel(ACanvas);
end;

procedure TcxCustomLabelViewInfo.InternalDrawBackground(
  ACanvas, ASource: TcxCanvas; const R: TRect; AParentBackgroundOffset: TPoint);
begin
  if DrawBackground(ACanvas, AParentBackgroundOffset) then
    Exit;

  if not Transparent or IsInplace and Focused then
    cxEditFillRect(ACanvas, R, BackgroundColor)
  else
    if IsInplace then
      cxBitBlt(ACanvas.Handle, ASource.Handle, R, AParentBackgroundOffset, SRCCOPY)
    else
      if not (csPaintCopy in Edit.ControlState) then
      begin
        cxDrawTransparentControlBackground(Edit, ACanvas,
          cxRectOffset(R, AParentBackgroundOffset.X - R.Left,
          AParentBackgroundOffset.Y -R.Top ));
      end;
end;

procedure TcxCustomLabelViewInfo.DrawLabel(ACanvas: TcxCanvas);

  function GetColor(BColor, EColor: TColor; N, H: Integer) : TColor;
  begin
    EColor := ColorToRGB(EColor);
    BColor := ColorToRGB(BColor);

    Result := RGB(Trunc(GetRValue(BColor) + (GetRValue(EColor) - GetRValue(BColor)) * N / H),
                  Trunc(GetGValue(BColor) + (GetGValue(EColor) - GetGValue(BColor)) * N / H),
                  Trunc(GetBValue(BColor) + (GetBValue(EColor) - GetBValue(BColor)) * N / H));
  end;

  function GetTextDrawingParameters(ACanvas: TCanvas; ADrawingRect: TRect;
    AAngle: Integer; out AStep: TSize): TPoint;

    procedure CalcRotatedTextPos(ACanvas: TCanvas);
    var
     ARect: TRect;
     AText: string;
    begin
      if AAngle <> 0 then
      begin
        ARect := ADrawingRect;
        Dec(ARect.Right, DepthDeltaSize.cx);
        Dec(ARect.Bottom, DepthDeltaSize.cy);
        AText := Text;
        if ShowAccelChar then
          AText := RemoveAccelChars(AText);
        cxDrawText(ACanvas.Handle, AText, ADrawingRect, DT_CALCRECT or DT_NOPREFIX);

        Result.X := Round(
          (ARect.Left + ARect.Right)/2 -
          RectWidth(ADrawingRect) / 2  * Cos(AAngle * PI / 180) -
          RectHeight(ADrawingRect) / 2 * Sin(AAngle * PI / 180));
        Result.Y := Round(
          (ARect.Top + ARect.Bottom)/2 +
          RectWidth(ADrawingRect) / 2  * Sin(AAngle * PI / 180) -
          RectHeight(ADrawingRect) / 2 * Cos(AAngle * PI / 180));
      end;
    end;

    function GetSignByValue(AValue: Longint): ShortInt;
    begin
      Result := 0;
      if AValue = 0 then
        Exit;
      if AValue > 0 then
        Result := 1
      else
        Result := -1;
    end;

  begin
    Result := Point(0, 0);
    CalcRotatedTextPos(ACanvas);
    AStep := Size(0, 0);
    if (LabelEffect <> cxleNormal) and (FDepth <> 0) then
    begin
      AStep := DepthDeltaSize;
      if Orientation in [cxoRight, cxoRightTop, cxoRightBottom] then
      begin
        Inc(Result.X, DepthDeltaSize.cx + LabelStyleOffset);
        AStep.cx := -AStep.cx;
      end;
      if Orientation in [cxoBottom, cxoLeftBottom , cxoRightBottom] then
      begin
        Inc(Result.Y, DepthDeltaSize.cy + LabelStyleOffset);
        AStep.cy := -AStep.cy;
      end;
      if LabelEffect in [cxleFun, cxleExtrude] then
      begin
        AStep.cx := GetSignByValue(AStep.cx);
        AStep.cy := GetSignByValue(AStep.cy);
      end;
    end;
  end;

  procedure DrawActualText(ACanvas: TcxCanvas; const ADrawingRect: TRect;
    const APosition: TPoint; AIsTextRotated: Boolean);
  var
    ATextRect: TRect;
    AText: string;
  begin
    ATextRect := ADrawingRect;
    if AIsTextRotated then
    begin
      AText := Text;
      if ShowAccelChar then
        AText := RemoveAccelChars(AText);
      ExtTextOut(ACanvas.Handle, APosition.X, APosition.Y, 0,
        @ATextRect, PChar(AText), Length(AText), nil);
    end
    else
    begin
      Dec(ATextRect.Right, DepthDeltaSize.cx);
      Dec(ATextRect.Bottom, DepthDeltaSize.cy);
      OffsetRect(ATextRect, APosition.X, APosition.Y);
      ACanvas.DrawText(Text, ATextRect,
        PrepareTextFlag(0, Alignment.Horz, TcxAlignmentVert(Ord(Alignment.Vert)),
          (epoShowEndEllipsis in PaintOptions) and IsInplace, WordWrap, 0,
          False, ShowAccelChar));
    end;
  end;

  procedure DrawLabelEffect(ACanvas: TcxCanvas; const ADrawingRect: TRect;
    var AStartPos: TPoint; const AStep: TSize; AIsTextRotated: Boolean);
  var
    AIterationCount, I: Integer;
  begin
    if (LabelEffect = cxleNormal) or (FDepth = 0) then
      Exit;
    if AStep.cx = 0 then
      AIterationCount := FDepth div Abs(AStep.cy)
    else
      AIterationCount := FDepth div Abs(AStep.cx);
      
    if LabelEffect <> cxleFun then
      ACanvas.Font.Color := ShadowedColor;
    for I := 1 to AIterationCount do
    begin
      if LabelEffect = cxleFun then
        ACanvas.Font.Color :=
          GetColor(BackgroundColor, ShadowedColor, I, AIterationCount);
      DrawActualText(ACanvas, ADrawingRect, AStartPos, AIsTextRotated);
      Inc(AStartPos.X, AStep.cx);
      Inc(AStartPos.Y, AStep.cy);
    end;
  end;

  procedure DrawConventionalizedText(ACanvas: TcxCanvas; ARect: TRect;
    const APosition: TPoint; AGlyph: TBitmap; AIsTrueType: Boolean;
    AIsTextRotated: Boolean);

    procedure DrawFilledText(X, Y: Integer; AGlyphOnly: Boolean = False);
    begin
      if not AGlyph.Empty and AIsTrueType then
      begin
        BeginPath(ACanvas.Handle);
        DrawActualText(ACanvas, ARect,
          Point(APosition.X + X, APosition.Y + Y), AIsTextRotated);
        EndPath(ACanvas.Handle);
        SelectClipPath(ACanvas.Handle, RGN_COPY);
        ACanvas.FillRect(ARect, AGlyph);
        SelectClipRgn(ACanvas.Handle, 0);
      end
      else
        if not AGlyphOnly then
        begin
          DrawActualText(ACanvas, ARect,
            Point(APosition.X + X, APosition.Y + Y), AIsTextRotated);
        end;
    end;

  begin
    ACanvas.Font.Color := TextColor;
    case LabelStyle of
      cxlsNormal:
        DrawFilledText(0, 0);
        
      cxlsRaised:
        begin
          ACanvas.Font.Color := clBtnHighlight;
          DrawActualText(ACanvas, ARect, APosition, AIsTextRotated);
          if Font.Size >= 12 then
          begin
            ACanvas.Font.Color := clBtnShadow;
            DrawActualText(ACanvas, ARect, Point(APosition.X + 2, APosition.Y + 2),
              AIsTextRotated);
          end;
          ACanvas.Font.Color := TextColor;
          DrawFilledText(1, 1);
        end;
        
      cxlsLowered:
        begin
          if Font.Size >= 12 then
          begin
            ACanvas.Font.Color :=  clBtnShadow;
            DrawActualText(ACanvas, ARect, APosition,
              AIsTextRotated);
          end;
          ACanvas.Font.Color := clBtnHighlight;
          DrawActualText(ACanvas, ARect, Point(APosition.X + 2, APosition.Y + 2),
            AIsTextRotated);
          ACanvas.Font.Color := TextColor;
          DrawFilledText(1, 1);
        end;
        
      cxlsOutLine:
        begin
          DrawFilledText(0, 0, AIsTrueType);
          if AIsTrueType then
          begin
            BeginPath(ACanvas.Handle);
            DrawActualText(ACanvas, ARect, APosition, AIsTextRotated);
            EndPath(ACanvas.Handle);
            ACanvas.Pen.Color := TextColor;
            ACanvas.Pen.Width := FPenWidth;
            StrokePath(ACanvas.Handle);
            ACanvas.Pen.Width := 1;
          end;
        end;
    end;
  end;

  procedure AdjustTextPosWithLabelStyle(var APosition: TPoint;
    const AStep: TSize);
  begin
    if AStep.cx < 0 then
      Dec(APosition.X, LabelStyleOffset);
    if AStep.cy < 0 then
      Dec(APosition.Y, LabelStyleOffset);
  end;

  procedure DrawLabelLine(ACanvas: TcxCanvas; const ALineRect, ATextRect: TRect);
  var
    ALookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
    ARect: TRect;
  begin
    if not IsRectEmpty(ALineRect) then
    begin
      if Painter = nil then
        ALookAndFeelPainter := TcxCustomLookAndFeelPainter
      else
        ALookAndFeelPainter := Painter;

      ACanvas.SaveClipRegion;
      try
        if LineOrientation = cxlloVertical then
          ARect := cxRectInflate(ATextRect, 0, TextFromLineOffset)
        else
          ARect := cxRectInflate(ATextRect, TextFromLineOffset, 0);
        ACanvas.ExcludeClipRect(ARect);
        ALookAndFeelPainter.DrawLabelLine(ACanvas, ALineRect,
          LineOuterColor, LineInnerColor, LineOrientation = cxlloVertical);
      finally
        ACanvas.RestoreClipRegion;
      end;
    end;
  end;

  procedure InternalDrawLabel(ADrawCanvas: TcxCanvas;
    const ABkgRect, ATextRect, ALineRect: TRect; const AParentBackgroundOffset: TPoint);
  var
    AIsTrueType: Boolean;
    ARealAngle: Integer;
    AStep: TSize;
    AStartPos: TPoint;
  begin
    InternalDrawBackground(ADrawCanvas, ACanvas, ABkgRect, AParentBackgroundOffset);
    AIsTrueType := AdjustCanvasFont(ADrawCanvas.Canvas, Font, FAngle);
    ARealAngle := GetRealTextAngle(FAngle, AIsTrueType);
    AStartPos := GetTextDrawingParameters(ADrawCanvas.Canvas, ATextRect, ARealAngle, AStep);
    ADrawCanvas.Brush.Style := bsClear;
    DrawLabelEffect(ADrawCanvas, ATextRect, AStartPos, AStep, ARealAngle <> 0);
    AdjustTextPosWithLabelStyle(AStartPos, AStep);
    DrawConventionalizedText(ADrawCanvas, ATextRect, AStartPos, FGlyph,
      AIsTrueType, ARealAngle <> 0);
    DrawLabelLine(ADrawCanvas, ALineRect, ATextRect);
    ADrawCanvas.Brush.Style := bsSolid;
  end;

  function InplaceOffsetChanged: Boolean;
  begin
    Result := (FInplaceOffset.X <> Left) or (FInplaceOffset.Y <> Top);
    if Result then
    begin
      FInplaceOffset.X := Left;
      FInplaceOffset.Y := Top;
    end;
  end;

var
  AContentRect, ATextRect, ALineRect: TRect;
  APrevLogFont: TLogFont;
begin
  SaveCanvasFont(ACanvas, APrevLogFont);
  try
    ALineRect := LineRect;
    AContentRect := ClientRect;
    ATextRect := LabelTextRect;
    if not IsInplace and Transparent and (csPaintCopy in Edit.ControlState) then
      InternalDrawLabel(ACanvas, AContentRect, LabelTextRect, ALineRect, AContentRect.TopLeft)
    else
    begin
      if not IsInplace and NativeStyle then
        GetThemeBackgroundContentRect(OpenTheme(totEdit), ACanvas.Handle,
          EP_EDITTEXT, NativeState, Bounds, AContentRect);
      if InplaceOffsetChanged or FIsDrawBitmapDirty or Transparent then
      begin
        FDrawBitmap.SetSize(cxRectWidth(AContentRect), cxRectHeight(AContentRect));
        OffsetRect(ATextRect, -AContentRect.Left, -AContentRect.Top);
        OffsetRect(ALineRect, -AContentRect.Left, -AContentRect.Top);
        InternalDrawLabel(FDrawBitmap.cxCanvas, FDrawBitmap.ClientRect,
          ATextRect, ALineRect, AContentRect.TopLeft);
        FIsDrawBitmapDirty := False;
      end;
      cxBitBlt(ACanvas.Handle, FDrawBitmap.Canvas.Handle, AContentRect,
        cxNullPoint, SRCCOPY);
     end;
  finally
    RestoreCanvasFont(ACanvas, APrevLogFont);
  end;
end;

procedure TcxCustomLabelViewInfo.SetBackgroundColor(Value: TColor);
begin
  inherited SetBackgroundColor(Value);
  FIsDrawBitmapDirty := True;
end;

{ TcxCustomLabelViewData }

procedure TcxCustomLabelViewData.CalculateLabelViewInfoProps(AViewInfo: TcxCustomEditViewInfo);
begin
  with TcxCustomLabelViewInfo(AViewInfo) do
  begin
    LabelEffect := Properties.LabelEffect;
    LabelStyle := Properties.LabelStyle;
    Orientation := Properties.Orientation;
    Depth := Properties.Depth;
    ShadowedColor := Properties.ShadowedColor;
    ShowAccelChar := Properties.ShowAccelChar;
    Angle := Properties.Angle;
    PenWidth := Properties.PenWidth;
    WordWrap := Properties.WordWrap;
    LineOuterColor := Properties.LineOptions.OuterColor;
    LineInnerColor := Properties.LineOptions.InnerColor;
    Alignment.Assign(Properties.Alignment);
    Glyph := Properties.Glyph;
  end;
end;

procedure TcxCustomLabelViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  ALabelViewInfo: TcxCustomLabelViewInfo;
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  if ((ABounds.Bottom >= MaxInt) or (ABounds.Right >= MaxInt)) and IsInplace then
    Exit;
  ALabelViewInfo := TcxCustomLabelViewInfo(AViewInfo);

  ALabelViewInfo.IsEditClass := GetIsEditClass;
  ALabelViewInfo.DrawSelectionBar := False;
  ALabelViewInfo.HasPopupWindow := False;
  ALabelViewInfo.DrawTextFlags := GetDrawTextFlags;
  if AreVisualStylesMustBeUsed(ALabelViewInfo.NativeStyle, totButton) and
    (ALabelViewInfo.BorderStyle = ebsNone) then
    ALabelViewInfo.NativeStyle := False;
  if not IsInplace then
    ALabelViewInfo.Transparent := TcxCustomLabel(Edit).Transparent;

  CalculateLabelViewInfoProps(ALabelViewInfo);
  ALabelViewInfo.DepthDeltaSize := Properties.CalculateDepthDelta;
  CalculateViewParams(ACanvas, ALabelViewInfo);
  CalculateCustomLabelViewInfo(ACanvas, Self, ALabelViewInfo);
  if not IsInplace then
    ALabelViewInfo.DrawSelectionBar := False;

  if Edit <> nil then
    ALabelViewInfo.LeftTop := Point(Edit.Left, Edit.Top);

  ALabelViewInfo.DrawTextOffsets := GetTextEditDrawTextOffset(Self);

  ALabelViewInfo.FIsDrawBitmapDirty := True;
end;

function TcxCustomLabelViewData.CalculateLabelStyleOffset(ACanvas: TcxCanvas): Integer;
const
  LabelStyleOffsetsMap: array[Boolean] of Integer = (1, 2);
begin
  if Properties.LabelStyle in [cxlsRaised, cxlsLowered] then
    Result := LabelStyleOffsetsMap[ACanvas.Font.Size >= 12]
  else
    Result := 0;
end;

function TcxCustomLabelViewData.CalculateLineRect(var ATextRect: TRect;
  const ABounds: TRect; AAlignment: TcxLabelLineAlignment; AVisible: Boolean;
  ALineHeight: Integer; AOrientation: TcxLabelLineOrientation): TRect; 

  function CalcHorLineRect: TRect;
  const
    SignsMap: array[TcxLabelLineAlignment] of Integer = (1, 0, -1);
  begin
    Result := ABounds;
    case AAlignment of
      cxllaTop:
        Result.Bottom := Result.Top + ALineHeight;
      cxllaBottom:
        Result.Top := Result.Bottom - ALineHeight;
      else
        begin
          Result := cxRectCenter(Result, cxRectWidth(Result), ALineHeight);
          case Properties.Alignment.Horz of
            taLeftJustify:
              Result.Left := ATextRect.Right + TextFromLineOffset;
            taRightJustify:
              Result.Right := ATextRect.Left - TextFromLineOffset;
          end;
        end;
    end;
    OffsetRect(ATextRect, 0, SignsMap[AAlignment] * ALineHeight);
  end;

  function CalcVertLineRect: TRect;
  const
    SignsMap: array[TcxLabelLineAlignment] of Integer = (-1, 0, 1);
  begin
    Result := ABounds;
    case AAlignment of
      cxllaTop:
        Result.Right := Result.Left + ALineHeight;
      cxllaBottom:
        Result.Left := Result.Bottom - ALineHeight;
      else
        begin
          Result := cxRectCenter(Result, ALineHeight, cxRectHeight(Result));
          case Properties.Alignment.Vert of
            taTopJustify:
              Result.Top := ATextRect.Bottom - TextFromLineOffset;
            taBottomJustify:
              Result.Bottom := ATextRect.Top + TextFromLineOffset;
          end;
        end;
    end;
    OffsetRect(ATextRect, SignsMap[AAlignment] * ALineHeight, 0);
  end;

begin
  Result := cxEmptyRect;
  if AVisible then
  begin
    if AOrientation = cxlloHorizontal then
      Result := CalcHorLineRect
    else
      Result := CalcVertLineRect;
  end;
end;

function TcxCustomLabelViewData.CalculateTextRect(
  const R: TRect; const ATextSize: TSize): TRect;
begin
  Result := R;

  case Properties.Alignment.Horz of
    taLeftJustify:
      Result.Right := Min(Result.Left + ATextSize.cx, Result.Right);
    taRightJustify:
      Result.Left := Max(Result.Right - ATextSize.cx, Result.Left);
    taCenter:
      Result := cxRectCenter(Result, ATextSize.cx, cxRectHeight(Result));
  end;

  case Properties.Alignment.Vert of
    taTopJustify:
      Result.Bottom := Min(Result.Top + ATextSize.cy, Result.Bottom);
    taBottomJustify:
      Result.Top := Max(Result.Bottom - ATextSize.cy, Result.Top);
    taVCenter:
      Result := cxRectCenter(Result, cxRectWidth(Result), ATextSize.cy);
  end;
end;

function TcxCustomLabelViewData.CalculateTextSize(
  ACanvas: TcxCanvas; const R: TRect; AText: string): TSize;
var
  ADepthSize: TSize;
  ALabelStyleOffset: Integer;
  ARealAngle: Integer;
  ARect: TRect;
  ATextMetric: TTextMetric;
begin
  ARect := R;
  GetTextMetrics(ACanvas.Handle, ATextMetric);
  ARealAngle := GetRealTextAngle(Properties.Angle,
    ATextMetric.tmPitchAndFamily and TMPF_TRUETYPE <> 0);

  if (ARealAngle <> 0) and Properties.ShowAccelChar then
    AText := RemoveAccelChars(AText);

  with Properties do
    cxDrawText(ACanvas.Handle, AText, ARect,
      PrepareTextFlag(DT_CALCRECT, taLeftJustify, vaTop, False,
        Properties.WordWrap and (ARealAngle = 0) and not (IsInplace and (R.Right <= 0)),
        0, True, Properties.ShowAccelChar and (ARealAngle = 0)));

  if ARealAngle = 0 then
    Result := Size(cxRectWidth(ARect), cxRectHeight(ARect))
  else
  begin
    Result.cx := Trunc(Abs(cxRectWidth(ARect) * Cos(ARealAngle * PI / 180)) +
      Abs(cxRectHeight(ARect) * Sin(ARealAngle  * PI / 180)) + 0.5);
    Result.cy := Trunc(Abs(cxRectWidth(ARect) * Sin(ARealAngle * PI / 180)) +
      Abs(cxRectHeight(ARect) * Cos(ARealAngle  * PI / 180)) + 0.5);
  end;

  ADepthSize := Properties.CalculateDepthDelta;
  ALabelStyleOffset := CalculateLabelStyleOffset(ACanvas);
  Inc(Result.cx, ALabelStyleOffset + ADepthSize.cx);
  Inc(Result.cy, ALabelStyleOffset + ADepthSize.cy);
end;

procedure TcxCustomLabelViewData.CalculateViewParams(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomLabelViewInfo);
const
  LineOrientationMap: array[Boolean] of TcxLabelLineOrientation = (
    cxlloHorizontal, cxlloVertical
  );
var
  APrevLogFont: TLogFont;
  ARealAngle: Integer;
  ARect: TRect;
  ATextSize: TSize;
begin
  SaveCanvasFont(ACanvas, APrevLogFont);
  try
    ARealAngle := GetRealTextAngle(Properties.Angle,
      AdjustCanvasFont(ACanvas.Canvas, Style.GetVisibleFont, Properties.Angle));
    with AViewInfo do
    begin
      ATextSize := CalculateTextSize(ACanvas, ClientRect, Text);
      LabelStyleOffset := CalculateLabelStyleOffset(ACanvas);
      ARect := CalculateTextRect(ClientRect, ATextSize);
      LineOrientation := LineOrientationMap[ARealAngle <> 0];
      LineRect := CalculateLineRect(ARect, ClientRect, LineOptions.Alignment,
        IsLineVisible(ARealAngle), GetLineHeight, LineOrientation);
      LabelTextRect := ARect;
      TextRect := ARect;
    end;
  finally
    RestoreCanvasFont(ACanvas, APrevLogFont);
  end;
end;

procedure TcxCustomLabelViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
  TcxCustomLabelViewInfo(AViewInfo).Text := EditValueToDisplayText(AEditValue);
end;

function TcxCustomLabelViewData.GetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; const AEditSizeProperties: TcxEditSizeProperties): TSize;

  function GetEditDisplayText: string;
  begin
    if Edit = nil then
      Result := EditValueToDisplayText(AEditValue)
    else
      Result := TcxCustomLabel(Edit).ViewInfo.Text;

    if Result = '' then
      Result := ' ';
  end;

  function CalculateLabelMinSize(ACanvas: TcxCanvas; const AText: string;
    const ATextRect: TRect; ARealAngle: Integer; ADepthSize, AContentSizeCorrection: TSize;
    ALabelStyleOffset: Integer; AIsInplace, AWordWrap, AShowAccelChar: Boolean): TSize;
  var
    ARect: TRect;
  begin
    ARect := cxRectOffset(ATextRect, -ATextRect.Left, -ATextRect.Top);
    if ARect.Right >= 0 then
    begin
      Dec(ARect.Right, ADepthSize.cx + ALabelStyleOffset);
      if AIsInplace then
        Dec(ARect.Right, AContentSizeCorrection.cx)
      else
        if Style.BorderStyle <> ebsNone then
          Dec(ARect.Right, TextFromBorderOffset * 2);
    end;
    
    Result := CalculateTextSize(ACanvas, ARect, AText);
    if AIsInplace then
    begin
      Inc(Result.cx, AContentSizeCorrection.cx);
      Inc(Result.cy, AContentSizeCorrection.cy);
    end
    else
      if Style.BorderStyle <> ebsNone then
        Inc(Result.cx, TextFromBorderOffset * 2);

    if IsLineVisible(ARealAngle) and (LineOptions.Alignment <> cxllaCenter) then
    begin
      if ARealAngle = 0 then
        Inc(Result.cy, GetLineHeight)
      else
        Dec(Result.cx, GetLineHeight);
    end;
  end;

var
  APrevLogFont: TLogFont;
  ARealAngle: Integer;
begin
  SaveCanvasFont(ACanvas, APrevLogFont);
  try
    ARealAngle := GetRealTextAngle(Properties.Angle,
      AdjustCanvasFont(ACanvas.Canvas, Style.GetVisibleFont, Properties.Angle));
    Result := Size(AEditSizeProperties.Width, 0);

    with Properties do
      Result := CalculateLabelMinSize(ACanvas, GetEditDisplayText,
        Rect(0, 0, Result.cx, Result.cy), ARealAngle, CalculateDepthDelta,
        Self.GetEditContentSizeCorrection, CalculateLabelStyleOffset(ACanvas),
        IsInplace, WordWrap, Properties.ShowAccelChar);
  finally
    RestoreCanvasFont(ACanvas, APrevLogFont);
  end;
end;

function TcxCustomLabelViewData.IsLineVisible(ARealAngle: Integer): Boolean;
begin
  Result := LineOptions.Visible and ((ARealAngle = 0) or (ARealAngle = 90));
end;

function TcxCustomLabelViewData.GetDrawTextFlags: Integer;
var
  ARealAngle: Integer;
begin
  ARealAngle := (Properties.Angle mod 360 + 360) mod 360;
  Result := DrawTextFlagsTocxTextOutFlags(
    PrepareTextFlag(0, Properties.Alignment.Horz,
      TcxAlignmentVert(Ord(Properties.Alignment.Vert)),
      epoShowEndEllipsis in PaintOptions,
      Properties.WordWrap and (ARealAngle = 0), 0, False));
end;

function TcxCustomLabelViewData.GetIsEditClass: Boolean;
begin
  Result := False;
end;

function TcxCustomLabelViewData.GetLineHeight: Integer;
begin
  if Edit = nil then
    Result := 0
  else
    Result := Edit.Style.LookAndFeel.Painter.LabelLineHeight;
end;

function TcxCustomLabelViewData.InternalEditValueToDisplayText(
  AEditValue: TcxEditValue): string;
begin
  Result := VarToStr(AEditValue);
end;

function TcxCustomLabelViewData.GetLineOptions: TcxLabelLineOptions;
begin
  Result := Properties.LineOptions;
end;

function TcxCustomLabelViewData.GetProperties: TcxCustomLabelProperties;
begin
  Result := TcxCustomLabelProperties(FProperties);
end;

{ TcxCustomLabelProperties }

constructor TcxCustomLabelProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FLabelEffect := cxleNormal;
  FLabelStyle := cxlsNormal;
  FOrientation := cxoRightBottom;
  FDepth := 0;
  FShadowedColor := clGrayText;
  FShowAccelChar := True;
  FAngle := 0;
  FPenWidth := 1;
  FWordWrap := False;
  FLineOptions := TcxLabelLineOptions.Create;
  FLineOptions.OnChanged := DoChanged;
end;

destructor TcxCustomLabelProperties.Destroy;
begin
  FreeAndNil(FGlyph);
  FreeAndNil(FLineOptions);
  inherited Destroy;
end;

procedure TcxCustomLabelProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomLabelProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomLabelProperties do
      begin
        Self.LabelEffect := LabelEffect;
        Self.LabelStyle := LabelStyle;
        Self.Orientation := Orientation;
        Self.Depth := Depth;
        Self.ShadowedColor := ShadowedColor;
        Self.Angle := Angle;
        Self.PenWidth := PenWidth;
        Self.Glyph := Glyph;
        Self.ShowAccelChar := ShowAccelChar;
        Self.WordWrap := WordWrap;
        Self.LineOptions := LineOptions;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomLabelProperties.CanCompareEditValue: Boolean;
begin
  Result := True;
end;

class function TcxCustomLabelProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxLabel;
end;

class function TcxCustomLabelProperties.GetStyleClass: TcxCustomEditStyleClass;
begin
  Result := TcxLabelEditStyle;
end;

function TcxCustomLabelProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
var
  ADisplayValue: TcxEditValue;
begin
  PrepareDisplayValue(AEditValue, ADisplayValue, False);
  Result := ADisplayValue;
end;

function TcxCustomLabelProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoAutoHeight, esoFiltering, esoShowingCaption, esoSorting,
    esoTransparency];
end;

class function TcxCustomLabelProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomLabelViewInfo;
end;

function TcxCustomLabelProperties.IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := inherited IsEditValueValid(EditValue, AEditFocused);
end;

procedure TcxCustomLabelProperties.PrepareDisplayValue(const AEditValue:
  TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean);
begin
  DisplayValue := VarToStr(AEditValue);
end;

class function TcxCustomLabelProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomLabelViewData;
end;

function TcxCustomLabelProperties.HasDisplayValue: Boolean;
begin
  Result := True;
end;

procedure TcxCustomLabelProperties.SetLabelEffect(Value : TcxLabelEffect);
begin
  if FLabelEffect <> Value then
  begin
    FLabelEffect := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetLineOptions(AValue: TcxLabelLineOptions);
begin
  FLineOptions.Assign(AValue);
end;

procedure TcxCustomLabelProperties.SetLabelStyle(Value : TcxLabelStyle);
begin
  if FLabelStyle <> Value then
  begin
    FLabelStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetOrientation(Value : TcxLabelOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetDepth(Value : Word);
begin
  if FDepth <> Value then
  begin
    FDepth := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetShadowedColor(Value : TColor);
begin
  if FShadowedColor <> Value then
  begin
    FShadowedColor := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetAngle(Value: Integer);
begin
  if FAngle <> Value then
  begin
    FAngle := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetPenWidth(Value: Integer);
begin
  if FPenWidth <> Value then
  begin
    FPenWidth := Value;
    Changed;
  end;
end;

function TcxCustomLabelProperties.GetGlyph: TBitmap;
begin
  if FGlyph = nil then
  begin
    FGlyph := TBitmap.Create;
    FGlyph.OnChange := DoChanged;
  end;
  Result := FGlyph;
end;

procedure TcxCustomLabelProperties.DoChanged(Sender: TObject);
begin
  Changed;
end;

procedure TcxCustomLabelProperties.SetGlyph(Value: TBitmap);
begin
  if Value = nil then
    FreeAndNil(FGlyph)
  else
    Glyph.Assign(Value);
  Changed;
end;

procedure TcxCustomLabelProperties.SetShowAccelChar(Value: Boolean);
begin
  if FShowAccelChar <> Value then
  begin
    FShowAccelChar := Value;
    Changed;
  end;
end;

procedure TcxCustomLabelProperties.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

function TcxCustomLabelProperties.CalculateDepthDelta: TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
  if LabelEffect = cxleNormal then Exit;
  case FOrientation of
    cxoLeft, cxoRight: Result.cx := FDepth;
    cxoTop, cxoBottom: Result.cy := FDepth;
    cxoLeftTop, cxoLeftBottom, cxoRightTop, cxoRightBottom:
    begin
      Result.cx := FDepth;
      Result.cy := FDepth;
    end;
  end;
end;

function TcxCustomLabelProperties.GetDisplayFormatOptions: TcxEditDisplayFormatOptions;
begin
  Result := [];
end;

function TcxCustomLabelProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsText;
end;

{ TcxCustomLabel }

destructor TcxCustomLabel.Destroy;
begin
  FFocusControl := nil;
  inherited Destroy;
end;

procedure TcxCustomLabel.DoAutoSizeChanged;
begin
  inherited DoAutoSizeChanged;               
  if AutoSize then
    Properties.LineOptions.Visible := False;
end;

procedure TcxCustomLabel.Notification(ACOmponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FFocusControl <> nil) and
    (AComponent = FFocusControl) then FFocusControl := nil;
end;

procedure TcxCustomLabel.PropertiesChanged(Sender: TObject);
begin
  inherited PropertiesChanged(Sender);
  if Properties.LineOptions.Visible then
    AutoSize := False;
end;

function TcxCustomLabel.UseAnchorX: Boolean;
begin
  Result := ActiveProperties.Alignment.Horz <> taLeftJustify;
end;

function TcxCustomLabel.UseAnchorY: Boolean;
begin
  Result := ActiveProperties.Alignment.Vert <> taTopJustify;
end;

class function TcxCustomLabel.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomLabelProperties;
end;

procedure TcxCustomLabel.SetStyle(Value: TcxLabelEditStyle);
begin
  FStyles.Style := Value;
end;

function TcxCustomLabel.GetEditStateColorKind: TcxEditStateColorKind;
begin
  Result := cxEditStateColorKindMap[Enabled];
end;

procedure TcxCustomLabel.Initialize;
begin
  inherited Initialize;
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 121;
  Height := 21;
end;

procedure TcxCustomLabel.SetFocusControl(Value: TWinControl);
begin
  if (FFocusControl <> Value) and (Value <> Self) then
    FFocusControl := Value;
end;

procedure TcxCustomLabel.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
begin
  inherited InternalSetEditValue(Value, AValidateEditValue);
  if not FLockCaption then
    Caption := VarToStr(Value);
  SetInternalDisplayValue(Caption);
end;

procedure TcxCustomLabel.Loaded;
begin
  if CanAllocateHandle(Self) then
    HandleNeeded;
  inherited Loaded;
end;

procedure TcxCustomLabel.SetInternalDisplayValue(Value: TcxEditValue);
begin
  ViewInfo.Text := VarToStr(Value);
  ShortRefreshContainer(False);
end;

procedure TcxCustomLabel.TextChanged;
begin
  inherited TextChanged;
  FLockCaption := True;
  try
    InternalEditValue := Caption;
  finally
    FLockCaption := False;
  end;
end;

function TcxCustomLabel.CanFocus: Boolean;
begin
  Result := IsInplace;
end;

{$IFDEF DELPHI10}
function TcxCustomLabel.GetTextBaseLine: Integer;
begin
  Result := ViewInfo.GetTextBaseLine;
end;

function TcxCustomLabel.HasTextBaseLine: Boolean;
begin
  Result := ActiveProperties.Angle = 0;
end;
{$ENDIF}

function TcxCustomLabel.CanAutoWidth: Boolean;
begin
  Result := not ActiveProperties.WordWrap;
end;

function TcxCustomLabel.CanFocusOnClick: Boolean;
begin
  Result := inherited CanFocusOnClick and IsInplace;
end;

function TcxCustomLabel.DefaultParentColor: Boolean;
begin
  Result := True;
end;

procedure TcxCustomLabel.CMDialogChar(var Message: TCMDialogChar);
begin
  if (FFocusControl <> nil) and Enabled and Properties.ShowAccelChar and
    IsAccel(Message.CharCode, Caption) and FFocusControl.CanFocus then
  begin
    FFocusControl.SetFocus;
    Message.Result := 1;
  end;
end;

function TcxCustomLabel.GetProperties: TcxCustomLabelProperties;
begin
  Result := TcxCustomLabelProperties(FProperties);
end;

function TcxCustomLabel.GetActiveProperties: TcxCustomLabelProperties;
begin
  Result := TcxCustomLabelProperties(InternalGetActiveProperties);
end;

function TcxCustomLabel.GetStyle: TcxLabelEditStyle;
begin
  Result := TcxLabelEditStyle(FStyles.Style);
end;

function TcxCustomLabel.GetViewInfo: TcxCustomLabelViewInfo;
begin
  Result := TcxCustomLabelViewInfo(FViewInfo);
end;

procedure TcxCustomLabel.SetProperties(Value: TcxCustomLabelProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxLabel }

class function TcxLabel.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxLabelProperties;
end;

function TcxLabel.GetActiveProperties: TcxLabelProperties;
begin
  Result := TcxLabelProperties(InternalGetActiveProperties);
end;

function TcxLabel.GetProperties: TcxLabelProperties;
begin
  Result := TcxLabelProperties(FProperties);
end;

procedure TcxLabel.SetProperties(Value: TcxLabelProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxLabelLineOptions }

constructor TcxLabelLineOptions.Create;
begin
  FAlignment := cxllaCenter;
  FInnerColor := clDefault;
  FOuterColor := clDefault;
end;

procedure TcxLabelLineOptions.Assign(Source: TPersistent);
begin
  if Source is TcxLabelLineOptions then
  begin
    FVisible := TcxLabelLineOptions(Source).FVisible;
    FAlignment := TcxLabelLineOptions(Source).FAlignment;
    FInnerColor := TcxLabelLineOptions(Source).FInnerColor;
    FOuterColor := TcxLabelLineOptions(Source).FOuterColor;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TcxLabelLineOptions.Changed;
begin
  if Assigned(OnChanged) then
    OnChanged(Self);
end;

function TcxLabelLineOptions.GetIsCustomColorsAssigned: Boolean;
begin
  Result := (InnerColor <> clDefault) and (OuterColor <> clDefault);  
end;

procedure TcxLabelLineOptions.SetAlignment(AValue: TcxLabelLineAlignment);
begin
  if FAlignment <> AValue then
  begin
    FAlignment := AValue;
    Changed;
  end; 
end;

procedure TcxLabelLineOptions.SetInnerColor(AValue: TColor);
begin
  if FInnerColor <> AValue then
  begin
    FInnerColor := AValue;
    Changed;
  end;
end;

procedure TcxLabelLineOptions.SetOuterColor(AValue: TColor);
begin
  if FOuterColor <> AValue then
  begin
    FOuterColor := AValue;
    Changed;
  end;
end;

procedure TcxLabelLineOptions.SetVisible(AValue: Boolean);
begin
  if Visible <> AValue then
  begin
    FVisible := AValue;
    Changed;
  end;
end;

initialization
  GetRegisteredEditProperties.Register(TcxLabelProperties, scxSEditRepositoryLabelItem);
  FilterEditsController.Register(TcxLabelProperties, TcxFilterTextEditHelper);

finalization
  FilterEditsController.Unregister(TcxLabelProperties, TcxFilterTextEditHelper);
  GetRegisteredEditProperties.Unregister(TcxLabelProperties);
  
end.
