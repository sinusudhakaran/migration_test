
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

unit cxCheckBox;

{$I cxVer.inc}

interface

uses
  Messages, Windows,
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  Classes, Controls, Forms, Graphics, SysUtils, cxClasses, cxContainer, cxControls,
  cxCustomData, cxDataStorage, cxEdit, cxGraphics, cxLookAndFeels, cxTextEdit,
  cxDropDownEdit, cxVariants, cxFilterControlUtils, cxLookAndFeelPainters;

const
  cxEditCheckBoxSingleBorderDefaultColor = clBtnShadow;

type
  TcxCheckBoxNullValueShowingStyle = (nssUnchecked, nssInactive, nssGrayedChecked);
  TcxCheckStatesValueFormat = (cvfCaptions, cvfIndices, cvfInteger,
    cvfStatesString);
  TcxCheckStates = array of TcxCheckBoxState;
  TcxEditCheckBoxBorderStyle = TcxEditBorderStyle;
  TcxEditCheckState = (ecsNormal, ecsHot, ecsPressed, ecsDisabled);

  TcxCheckStatesToValueEvent = procedure(Sender: TObject;
    const ACheckStates: TcxCheckStates; out AValue: TcxEditValue) of object;
  TcxValueToCheckStatesEvent = procedure(Sender: TObject;
    const AValue: TcxEditValue; var ACheckStates: TcxCheckStates) of object;

  { IcxCheckItems }

  IcxCheckItems = interface
  ['{5BF13228-CF05-4741-9833-F2B8FBFD57ED}']
    function GetCaption(Index: Integer): string;
    function GetCount: Integer;
    property Captions[Index: Integer]: string read GetCaption;
    property Count: Integer read GetCount;
  end;

  { TcxCustomCheckBoxViewInfo }

  TcxCustomCheckBox = class;

  TcxCustomCheckBoxViewInfo = class(TcxCustomTextEditViewInfo)
  private
    function GetEdit: TcxCustomCheckBox;
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
    function IsTextEnabled: Boolean;
  public
    Alignment: TAlignment;
    CheckBorderOffset: Integer;
    CheckBoxBorderStyle: TcxEditCheckBoxBorderStyle;
    CheckBoxGlyph: TBitmap;
    CheckBoxGlyphCount: Integer;
    CheckBoxRect: TRect;
    CheckBoxState: TcxEditCheckState;
    DrawCaptionFlags: Integer;
    FocusRect: TRect;
    HasGlyph: Boolean;
    IsTextColorAssigned: Boolean;
    NullValueShowingStyle: TcxCheckBoxNullValueShowingStyle;
    State: TcxCheckBoxState;
    procedure Assign(Source: TObject); override;
    procedure DrawText(ACanvas: TcxCanvas); override;
    function GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion; override;
    function IsHotTrack: Boolean; override;
    function IsHotTrack(P: TPoint): Boolean; override;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint; out AText: TCaption;
      out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean; override;
    procedure Offset(DX, DY: Integer); override;
    function Repaint(AControl: TWinControl; const AInnerEditRect: TRect;
      AViewInfo: TcxContainerViewInfo = nil): Boolean; override;
    property Edit: TcxCustomCheckBox read GetEdit;
  end;

  { TcxCustomCheckBoxViewData }

  TcxCustomCheckBoxProperties = class;

  TcxCustomCheckBoxViewData = class(TcxCustomEditViewData)
  private
    function GetProperties: TcxCustomCheckBoxProperties;
  protected
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties;
      var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo): TSize; override;
    function GetDrawTextFlags: Integer; virtual;
    function GetIsEditClass: Boolean;
    function IsCheckPressed: Boolean;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    function GetBorderStyle: TcxEditBorderStyle; override;
    property Properties: TcxCustomCheckBoxProperties read GetProperties;
  end;

  { TcxCheckBoxStyle }

  TcxCheckBoxStyle = class(TcxEditStyle)
  public
    function HasBorder: Boolean; override;
  end;

  { TcxCustomCheckBoxProperties }

  TcxCustomCheckBoxProperties = class(TcxCustomEditProperties)
  private
    FAllowGrayed: Boolean;
    FCaption: TCaption; // obsolete
    FDisplayChecked: WideString;
    FDisplayGrayed: WideString;
    FDisplayUnchecked: WideString;
    FFullFocusRect: Boolean;
    FGlyph: TBitmap;
    FGlyphCount: Integer;
    FIsCaptionAssigned: Boolean; // obsolete
    FMultiLine: Boolean;
    FNullStyle: TcxCheckBoxNullValueShowingStyle;
    FUseAlignmentWhenInplace: Boolean;
    FValueChecked: TcxEditValue;
    FValueGrayed: TcxEditValue;
    FValueUnchecked: TcxEditValue;
    function GetAlignment: TAlignment;
    function GetGlyph: TBitmap;
    function GetInternalAlignment: TcxEditAlignment;
    procedure GlyphChanged(Sender: TObject);
    function IsAlignmentStored: Boolean;
    function IsDisplayCheckedStored: Boolean;
    function IsDisplayGrayedStored: Boolean;
    function IsDisplayUncheckedStored: Boolean;
    function IsLoading: Boolean;
    function IsValueCheckedStored: Boolean;
    function IsValueGrayedStored: Boolean;
    function IsValueUncheckedStored: Boolean;
    procedure ReadCaption(Reader: TReader); // obsolete
    procedure SetAlignment(Value: TAlignment);
    procedure SetCaption(const Value: TCaption); // obsolete
    procedure SetFullFocusRect(Value: Boolean);
    procedure SetGlyph(Value: TBitmap);
    procedure SetGlyphCount(Value: Integer);
    procedure SetMultiLine(Value: Boolean);
    procedure SetNullStyle(Value: TcxCheckBoxNullValueShowingStyle);
    procedure SetStateValues(const AValueChecked, AValueGrayed, AValueUnchecked: TcxEditValue);
    procedure SetUseAlignmentWhenInplace(Value: Boolean);
    procedure SetValueChecked(const Value: TcxEditValue);
    procedure SetValueGrayed(const Value: TcxEditValue);
    procedure SetValueUnchecked(const Value: TcxEditValue);
  protected
    function CanValidate: Boolean; override;
    procedure DefineProperties(Filer: TFiler); override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
    function CheckValue(const AValue: TcxEditValue): Boolean;
    function GetState(const AEditValue: TcxEditValue): TcxCheckBoxState;
    function InternalGetGlyph: TBitmap; virtual;
    function IsEmbeddedEdit: Boolean; virtual;
    property InternalAlignment: TcxEditAlignment read GetInternalAlignment;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; override;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    class function GetStyleClass: TcxCustomEditStyleClass; override;
    function GetSpecialFeatures: TcxEditSpecialFeatures; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsActivationKey(AKey: Char): Boolean; override;
    function IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean; override;
    function IsResetEditClass: Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    // !!!
    property Alignment: TAlignment read GetAlignment write SetAlignment
      stored IsAlignmentStored;
//    property AlignmentVert: TcxAlignmentVert read GetAlignmentVert
//      write SetAlignmentVert stored IsAlignmentVertStored;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property Caption: TCaption read FCaption write SetCaption stored False; // obsolete
    property DisplayChecked: WideString read FDisplayChecked write FDisplayChecked
      stored IsDisplayCheckedStored;
    property DisplayGrayed: WideString read FDisplayGrayed write FDisplayGrayed
      stored IsDisplayGrayedStored;
    property DisplayUnchecked: WideString read FDisplayUnchecked write FDisplayUnchecked
      stored IsDisplayUncheckedStored;
    property FullFocusRect: Boolean read FFullFocusRect write SetFullFocusRect default False;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property GlyphCount: Integer read FGlyphCount write SetGlyphCount default 6;
    property MultiLine: Boolean read FMultiLine write SetMultiLine default False;
    property NullStyle: TcxCheckBoxNullValueShowingStyle read FNullStyle write
      SetNullStyle default nssGrayedChecked;
    property UseAlignmentWhenInplace: Boolean read FUseAlignmentWhenInplace
      write SetUseAlignmentWhenInplace default False;
    property ValueChecked: TcxEditValue read FValueChecked write SetValueChecked
      stored IsValueCheckedStored;
    property ValueGrayed: TcxEditValue read FValueGrayed write SetValueGrayed
      stored IsValueGrayedStored;
    property ValueUnchecked: TcxEditValue read FValueUnchecked write SetValueUnchecked
      stored IsValueUncheckedStored;
  end;

  { TcxCheckBoxProperties }

  TcxCheckBoxProperties = class(TcxCustomCheckBoxProperties)
  published
    property Alignment;
    property AllowGrayed;
    property AssignedValues;
    property Caption; // obsolete
    property ClearKey;
    property DisplayChecked;
    property DisplayUnchecked;
    property DisplayGrayed;
    property FullFocusRect;
    property Glyph;
    property GlyphCount;
    property ImmediatePost;
    property MultiLine;
    property NullStyle;
    property ReadOnly;
    property UseAlignmentWhenInplace;
    property ValueChecked;
    property ValueGrayed;
    property ValueUnchecked;
    property OnChange;
    property OnEditValueChanged;
    property OnValidate;
  end;

  { TcxCustomCheckBox }

  TcxCustomCheckBox = class(TcxCustomEdit)
  private
    FIsCheckPressed: Boolean;
    FIsLoaded: Boolean;
    FIsLoadingStateAssigned: Boolean;
    FLoadingState: TcxCheckBoxState;
    function GetChecked: Boolean;
    function GetProperties: TcxCustomCheckBoxProperties;
    function GetActiveProperties: TcxCustomCheckBoxProperties;
    function GetState: TcxCheckBoxState;
    function GetStyle: TcxCheckBoxStyle;
    function GetViewInfo: TcxCustomCheckBoxViewInfo;
    function IsStateStored: Boolean;
    procedure SetChecked(Value: Boolean);
    procedure SetProperties(Value: TcxCustomCheckBoxProperties);
    procedure SetState(Value: TcxCheckBoxState);
    procedure SetStyle(Value: TcxCheckBoxStyle);
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
  protected
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function CanHaveTransparentBorder: Boolean; override;
    function DefaultParentColor: Boolean; override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEditKeyPress(var Key: Char); override;
    procedure DoEditKeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoExit; override;
    procedure FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    function GetEditStateColorKind: TcxEditStateColorKind; override;
    function GetShadowBounds: TRect; override;
    procedure Initialize; override;
    function InternalGetNotPublishedStyleValues: TcxEditStyleValues; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    function IsClickEnabledDuringLoading: Boolean; override;
    function IsNativeBackground: Boolean; override;
    procedure Loaded; override;
    procedure ProcessViewInfoChanges(APrevViewInfo: TcxCustomEditViewInfo;
      AIsMouseDownUpEvent: Boolean); override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure TextChanged; override;
    procedure InvalidateCheckRect;
    procedure Toggle; virtual;
    property Caption;
    property Checked: Boolean read GetChecked write SetChecked stored False;
    property ViewInfo: TcxCustomCheckBoxViewInfo read GetViewInfo;
  public
    procedure Clear; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    property ActiveProperties: TcxCustomCheckBoxProperties read GetActiveProperties;
    property Properties: TcxCustomCheckBoxProperties read GetProperties
      write SetProperties;
    property State: TcxCheckBoxState read GetState write SetState
      stored IsStateStored default cbsUnchecked;
    property Style: TcxCheckBoxStyle read GetStyle write SetStyle;
    property Transparent;
  end;

  { TcxCheckBox }

  TcxCheckBox = class(TcxCustomCheckBox)
  private
    function GetActiveProperties: TcxCheckBoxProperties;
    function GetProperties: TcxCheckBoxProperties;
    procedure SetProperties(Value: TcxCheckBoxProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxCheckBoxProperties read GetActiveProperties;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property Caption;
    property Checked;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentBackground;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxCheckBoxProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property State;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
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

  { TcxFilterCheckBoxHelper }

  TcxFilterCheckBoxHelper = class(TcxFilterComboBoxHelper)
  public
    class procedure GetFilterValue(AEdit: TcxCustomEdit;
      AEditProperties: TcxCustomEditProperties; var V: Variant; var S: TCaption); override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
    class procedure SetFilterValue(AEdit: TcxCustomEdit; AEditProperties: TcxCustomEditProperties;
      AValue: Variant); override;
    class function UseDisplayValue: Boolean; override;
  end;

  { TcxCheckBoxActionLink }

  TcxCheckBoxActionLink = class(TWinControlActionLink)
  protected
    FClient: TcxCustomCheckBox;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    procedure SetChecked(Value: Boolean); override;
    procedure InternalSetChecked(Value: Boolean);
  end;

var
  CheckStates: TcxCheckStates = nil;

function CalculateCheckStatesValue(const ACheckStates: TcxCheckStates;
  AItems: IcxCheckItems; AValueFormat: TcxCheckStatesValueFormat): TcxEditValue;
function CalculateCheckStates(const AValue: TcxEditValue;
  AItems: IcxCheckItems; AValueFormat: TcxCheckStatesValueFormat;
  var ACheckStates: TcxCheckStates): Boolean;
procedure DrawEditCheck(ACanvas: TcxCanvas; const ACheckRect: TRect;
  AState: TcxCheckBoxState; ACheckState: TcxEditCheckState; AGlyph: TBitmap;
  AGlyphCount: Integer; ABorderStyle: TcxEditCheckBoxBorderStyle;
  ANativeStyle: Boolean; ABorderColor: TColor; ABackgroundColor: TColor;
  ADrawBackground, AIsDesigning, AFocused, ASupportGrayed: Boolean;
  APainter: TcxCustomLookAndFeelPainterClass;
  AGrayedShowingStyle: TcxCheckBoxNullValueShowingStyle = nssGrayedChecked);
function GetEditCheckBorderOffset(ACheckBorderStyle: TcxContainerBorderStyle;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer; overload;
function GetEditCheckBorderOffset(ACheckBorderStyle: TcxEditBorderStyle;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer; overload;
function GetEditCheckBorderOffset(ALookAndFeelKind: TcxLookAndFeelKind;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer; overload;
function GetEditCheckGlyphIndex(AState: TcxCheckBoxState;
  ACheckState: TcxEditCheckState; ASupportGrayed: Boolean;
  AGlyphCount: Integer): Integer;
function GetEditCheckSize(ACanvas: TcxCanvas; ANativeStyle: Boolean;
  AGlyph: TBitmap; AGlyphCount: Integer; APainter: TcxCustomLookAndFeelPainterClass): TSize;

procedure DrawCheckBoxText(ACanvas: TcxCanvas; AText: string; AFont: TFont;
  ATextColor: TColor; ATextRect: TRect; ADrawTextFlags: Integer; AEnabled: Boolean);

implementation

uses
  ActnList, dxThemeConsts, dxThemeManager, dxUxTheme, cxEditConsts,
  cxEditPaintUtils, cxDrawTextUtils, cxEditUtils;

var
  FCheckMask: TBitmap;

procedure PrepareCheckMask;

  procedure InternalPrepareCheckMask(AButtonsBitmap: HBITMAP);
  var
    AMemDC: HDC;
    APrevBitmap: HBITMAP;
    I, J: Integer;
  begin
    FCheckMask := TBitmap.Create;
    with TcxCustomLookAndFeelPainter do
    begin
      FCheckMask.Width := CheckButtonSize.cx;
      FCheckMask.Height := CheckButtonSize.cy;
    end;

    AMemDC := CreateCompatibleDC(0);
    APrevBitmap := 0;
    try
      APrevBitmap := SelectObject(AMemDC, AButtonsBitmap);
      with FCheckMask.Canvas do
        for I := 0 to FCheckMask.Height - 1 do
          for J := 0 to FCheckMask.Width - 1 do
            if Windows.GetPixel(AMemDC, J, I) = Windows.GetPixel(AMemDC, J + FCheckMask.Width, I) then
              Pixels[J, I] := clWhite
            else
              Pixels[J, I] := 0;
    finally
      if APrevBitmap <> 0 then
        SelectObject(AMemDC, APrevBitmap);
      DeleteDC(AMemDC);
    end;
  end;

var
  AButtonsBitmap: HBITMAP;
begin
  AButtonsBitmap := LoadBitmap(0, PChar(OBM_CHECKBOXES));
  try
    InternalPrepareCheckMask(AButtonsBitmap);
  finally
    DeleteObject(AButtonsBitmap);
  end;
end;

procedure CalculateCheckBoxViewInfo(AViewData: TcxCustomCheckBoxViewData; AViewInfo:
  TcxCustomCheckBoxViewInfo; AIsMouseEvent: Boolean);
begin
  with AViewInfo do
  begin
    AViewData.CalculateViewInfo(AViewInfo, AIsMouseEvent);
    TextRect := ClientRect;
    ExtendRect(TextRect, GetTextEditDrawTextOffset(AViewData));
  end;
end;

function CalculateCheckStatesValue(const ACheckStates: TcxCheckStates;
  AItems: IcxCheckItems; AValueFormat: TcxCheckStatesValueFormat): TcxEditValue;

  function CalculateCaptionsValue: TcxEditValue;
  var
    ACheckedCaptions, AGrayedCaptions: string;
    I: Integer;
  begin
    ACheckedCaptions := '';
    AGrayedCaptions := '';
    for I := 0 to Length(ACheckStates) - 1 do
    begin
      if ACheckStates[I] <> cbsUnchecked then
        if ACheckStates[I] = cbsGrayed then
          AGrayedCaptions := AGrayedCaptions +
            IntToStr(Length(AItems.Captions[I])) + ':' + AItems.Captions[I]
        else
          ACheckedCaptions := ACheckedCaptions +
            IntToStr(Length(AItems.Captions[I])) + ':' + AItems.Captions[I];
    end;
    Result := AGrayedCaptions;
    if Length(ACheckedCaptions) > 0 then
      Result := Result + ';' + ACheckedCaptions;
  end;

  function CalculateIndicesValue: TcxEditValue;
  var
    ACheckedCaptions, AGrayedCaptions: string;
    I: Integer;
  begin
    ACheckedCaptions := '';
    AGrayedCaptions := '';
    for I := 0 to Length(ACheckStates) - 1 do
      if ACheckStates[I] <> cbsUnchecked then
        if ACheckStates[I] = cbsGrayed then
        begin
          if AGrayedCaptions <> '' then
            AGrayedCaptions := AGrayedCaptions + ',';
          AGrayedCaptions := AGrayedCaptions + IntToStr(I);
        end
        else
        begin
          if ACheckedCaptions <> '' then
            ACheckedCaptions := ACheckedCaptions + ',';
          ACheckedCaptions := ACheckedCaptions + IntToStr(I);
        end;
    Result := AGrayedCaptions;
    if Length(ACheckedCaptions) > 0 then
      Result := Result + ';' + ACheckedCaptions;
  end;

  function CalculateStatesIntegerValue: TcxEditValue;
  var
    V: {$IFDEF DELPHI6}Int64{$ELSE}Integer{$ENDIF};
    I, L: Integer;
  begin
    V := 0;
    L := Length(ACheckStates);
    if L > SizeOf({$IFDEF DELPHI6}Int64{$ELSE}Integer{$ENDIF}) * 8 then
      L := SizeOf({$IFDEF DELPHI6}Int64{$ELSE}Integer{$ENDIF}) * 8;
    for I := L - 1 downto 0 do
    begin
      V := V shl 1;
      V := V + {$IFDEF DELPHI6}Int64{$ELSE}Integer{$ENDIF}(ACheckStates[I] = cbsChecked);
    end;
    Result := V;
    VarCast(Result, Result, {$IFDEF DELPHI6}varInt64{$ELSE}varInteger{$ENDIF});
  end;

  function CalculateStatesStringValue: TcxEditValue;
  var
    I: Integer;
    S: string;
  begin
    SetLength(S, Length(ACheckStates));
    for I := 0 to High(ACheckStates) do
      S[I + 1] := Char(Integer(ACheckStates[I]) + Ord('0'));
    Result := S;
  end;

begin
  Result := Null;
  case AValueFormat of
    cvfCaptions:
      Result := CalculateCaptionsValue;
    cvfIndices:
      Result := CalculateIndicesValue;
    cvfInteger:
      Result := CalculateStatesIntegerValue;
    cvfStatesString:
      Result := CalculateStatesStringValue;
  end;
end;

function CalculateCheckStates(const AValue: TcxEditValue;
  AItems: IcxCheckItems; AValueFormat: TcxCheckStatesValueFormat;
  var ACheckStates: TcxCheckStates): Boolean;

  function GetNumber(var ANumber, AIndex: Integer;
    const S: string): Boolean;

    function IsDigit(C: Char): Boolean;
    begin
      Result := (C >= '0') and (C <= '9');
    end;

  const
    AMaxLength = MaxInt div 10;
    AMaxIntLastDigit = MaxInt mod 10;
  var
    L: Integer;
    D: Integer;
  begin
    Result := False;
    L := Length(S);
    if (AIndex > L) or not IsDigit(S[AIndex]) then
      Exit;
      
    ANumber := 0;
    repeat
      D := StrToInt(S[AIndex]);
      if (ANumber > AMaxLength) or
        ((ANumber = AMaxLength) and (D > AMaxIntLastDigit)) then
          Exit;
      ANumber := ANumber * 10 + D;
      Inc(AIndex);
    until (AIndex > L) or not IsDigit(S[AIndex]);
    Result := True;
  end;

  function CalculateItemsByCaptionsValue: Boolean;

    function GetCaptions(ACaptions: TStringList): Boolean;
    var
      S: string;
      ACaptionLength, AIndex, AValueLength: Integer;
      AChecked: Boolean;
    begin
      S := VarToStr(AValue);
      Result := S = '';
      if Result then
        Exit;

      Result := False;
      AChecked := False;
      AValueLength := Length(S);
      AIndex := 1;
      repeat
        if (S[AIndex] = ';') and not AChecked then
        begin
          AChecked := True;
          Inc(AIndex);
        end;
        if not GetNumber(ACaptionLength, AIndex, S) then
          Exit;
        if (AIndex > AValueLength) or (S[AIndex] <> ':') then
          Exit;
        Inc(AIndex);
        if AIndex + ACaptionLength - 1 > AValueLength then
          Exit;
        ACaptions.AddObject(Copy(S, AIndex, ACaptionLength),
          Pointer(AChecked));
        Inc(AIndex, ACaptionLength);
        if AIndex > AValueLength then
          Break;
      until (AIndex > AValueLength);
      Result := True;
    end;

    function CalculateStates(ACaptions: TStringList): Boolean;
    var
      AIndex, I: Integer;
    begin
      for I := 0 to AItems.Count - 1 do
      begin
        AIndex := ACaptions.IndexOf(AItems.Captions[I]);
        if AIndex = -1 then
          ACheckStates[I] := cbsUnchecked
        else
        begin
          if Boolean(ACaptions.Objects[AIndex]) then
            ACheckStates[I] := cbsChecked
          else
            ACheckStates[I] := cbsGrayed;
          ACaptions.Delete(AIndex);
        end;
      end;
      Result := ACaptions.Count = 0;
    end;

  var
    ACaptions: TStringList;
  begin
    if not(VarIsNull(AValue) or VarIsStr(AValue)) then
    begin
      Result := False;
      Exit;
    end;
    ACaptions := TStringList.Create;
    try
      Result := GetCaptions(ACaptions);
      if not Result then
        Exit;
      ACaptions.Sort;
      Result := CalculateStates(ACaptions);
    finally
      FreeAndNil(ACaptions);
    end;
  end;

  procedure SetStatesToUnchecked;
  var
    I: Integer;
  begin
    for I := 0 to AItems.Count - 1 do
      ACheckStates[I] := cbsUnchecked;
  end;

  function CalculateItemsByIndicesValue: Boolean;
  var
    AChecked: Boolean;
    AIndex, AItemIndex, L: Integer;
    S: string;
  begin
    Result := VarIsNull(AValue) or VarIsStr(AValue);
    if not Result then
      Exit;

    S := VarToStr(AValue);
    SetStatesToUnchecked;
    if S = '' then
      Exit;

    Result := False;
    AIndex := 1;
    L := Length(S);
    AChecked := False;
    repeat
      if (S[AIndex] = ';') and not AChecked then
      begin
        AChecked := True;
        Inc(AIndex);
      end;
      if not GetNumber(AItemIndex, AIndex, S) or (AItemIndex >= AItems.Count) then
        Exit;
      if AChecked then
        ACheckStates[AItemIndex] := cbsChecked
      else
        ACheckStates[AItemIndex] := cbsGrayed;
      if AIndex > L then
        Break;
      if S[AIndex] = ',' then
        Inc(AIndex);
    until AIndex > L;
    Result := True;
  end;

  function CalculateItemsByStatesIntegerValue: Boolean;
  var
    V: {$IFDEF DELPHI6}Int64{$ELSE}Integer{$ENDIF};
    I, ACode: Integer;
  begin
    Result := VarIsNumericEx(AValue) or VarIsStr(AValue) or VarIsDate(AValue) or
      VarIsNull(AValue);
    if Result then
    begin
      if VarIsNull(AValue) then
        V := 0
      else
        if VarIsStr(AValue) then
        begin
          Val(AValue, V, ACode);
          Result := ACode = 0;
          if not Result then
            Exit;
        end
        else
          V := VarAsType(AValue, {$IFDEF DELPHI6}varInt64{$ELSE}varInteger{$ENDIF});
      for I := 0 to AItems.Count - 1 do
      begin
        if V and 1 = 0 then
          ACheckStates[I] := cbsUnchecked
        else
          ACheckStates[I] := cbsChecked;
        V := V shr 1;
      end;
    end
  end;

  function CalculateItemsByStatesStringValue: Boolean;
  var
    AItemCount, I: Integer;
    S: string;
  begin
    Result := VarIsNull(AValue) or VarIsStr(AValue);
    if not Result then
      Exit;

    Result := False;
    S := VarToStr(AValue);
    AItemCount := Length(S);
    if AItemCount > AItems.Count then
      AItemCount := AItems.Count;
    for I := 1 to AItemCount do
      if (S[I] < '0') or (S[I] > '2') then
        Exit
      else
        ACheckStates[I - 1] := TcxCheckBoxState(Ord(S[I]) - Ord('0'));
    if AItemCount < AItems.Count then
      for I := AItemCount to AItems.Count - 1 do
        ACheckStates[I] := cbsUnchecked;
    Result := True;
  end;

var
  I: Integer;
begin
  SetLength(ACheckStates, AItems.Count);

  case AValueFormat of
    cvfCaptions:
      Result := CalculateItemsByCaptionsValue;
    cvfIndices:
      Result := CalculateItemsByIndicesValue;
    cvfInteger:
      Result := CalculateItemsByStatesIntegerValue;
    cvfStatesString:
      Result := CalculateItemsByStatesStringValue;
    else
      Result := False;
  end;

  if not Result then
    for I := 0 to AItems.Count - 1 do
      ACheckStates[I] := cbsUnchecked;
end;

procedure CalculateCustomCheckBoxViewInfo(ACanvas: TcxCanvas; AViewData: TcxCustomCheckBoxViewData;
  AViewInfo: TcxCustomCheckBoxViewInfo);

  procedure CheckFocusRectBounds;
  var
    AMaxRect: TRect;
  begin
    with AViewInfo do
    begin
      if Alignment = taCenter then
        AMaxRect := Rect(FocusRect.Left, ClientRect.Top, FocusRect.Right, ClientRect.Bottom)
      else
      begin
        AMaxRect := Rect(TextRect.Left - 1, TextRect.Top - 1 + 2 * Integer(IsInplace),
          TextRect.Right + 1, TextRect.Bottom + 1 - 2 * Integer(IsInplace));
        if AMaxRect.Right > BorderRect.Right - 1 then
          AMaxRect.Right := BorderRect.Right - 1;
      end;

      if FocusRect.Left < AMaxRect.Left then
        FocusRect.Left := AMaxRect.Left;
      if FocusRect.Top < AMaxRect.Top then
        FocusRect.Top := AMaxRect.Top;
      if FocusRect.Right > AMaxRect.Right then
        FocusRect.Right := AMaxRect.Right;
      if FocusRect.Bottom > AMaxRect.Bottom then
        FocusRect.Bottom := AMaxRect.Bottom;
    end;
  end;

begin
  with AViewInfo do
  begin
    BackgroundColor := AViewData.Style.Color;

    if Focused and ((not IsInplace or AViewData.Properties.IsEmbeddedEdit) and (Alignment <> taCenter) or
      IsInplace and (Alignment = taCenter) and (epoShowFocusRectWhenInplace in PaintOptions)) then
    begin
      if Alignment = taCenter then
      begin
        FocusRect := ClientRect;
        InflateRect(FocusRect, -1, -1);
      end
      else
        if Length(Text) <> 0 then
        begin
          FocusRect := TextRect;
          if not AViewData.Properties.FullFocusRect then
          begin
            ACanvas.Font := Font;
            ACanvas.TextExtent(Text, FocusRect, DrawTextFlags);
          end;
          InflateRect(FocusRect, 1, 1);
          Inc(FocusRect.Bottom);
        end
        else
          FocusRect := cxEmptyRect;
    end
    else
      FocusRect := cxEmptyRect;
    if not IsRectEmpty(FocusRect) then
      CheckFocusRectBounds;
  end;
end;

procedure DrawCheckBoxText(ACanvas: TcxCanvas; AText: string; AFont: TFont;
  ATextColor: TColor; ATextRect: TRect; ADrawTextFlags: Integer; AEnabled: Boolean);
begin
  ACanvas.Font := AFont;
  ACanvas.Font.Color := ATextColor;
  ACanvas.Brush.Style := bsClear;
  ACanvas.DrawText(AText, ATextRect, ADrawTextFlags, AEnabled);
  ACanvas.Brush.Style := bsSolid;
end;

function IsGlyphValid(AGlyph: TBitmap; AGlyphCount: Integer): Boolean;
begin
  Result := (AGlyphCount > 0) and VerifyBitmap(AGlyph);
end;

function GetCheckNativeState(AState: TcxCheckBoxState; ACheckState: TcxEditCheckState): Integer;
const
  ANativeCheckStateMap: array[TcxCheckBoxState, TcxEditCheckState] of Integer = (
    (CBS_UNCHECKEDNORMAL, CBS_UNCHECKEDHOT, CBS_UNCHECKEDPRESSED, CBS_UNCHECKEDDISABLED),
    (CBS_CHECKEDNORMAL, CBS_CHECKEDHOT, CBS_CHECKEDPRESSED, CBS_CHECKEDDISABLED),
    (CBS_MIXEDNORMAL, CBS_MIXEDHOT, CBS_MIXEDPRESSED, CBS_MIXEDDISABLED)
  );
begin
  Result := ANativeCheckStateMap[AState, ACheckState];
end;

procedure DrawCustomCheckBox(ACanvas: TcxCanvas; AViewInfo: TcxCustomCheckBoxViewInfo); overload;
var
  AIsBackgroundTransparent: Boolean;
  ACheckRect: TRect;
  ACheckTransparent: Boolean;
begin
  AIsBackgroundTransparent := AViewInfo.IsBackgroundTransparent;

//  ACanvas.Brush.Color := AViewInfo.BackgroundColor; // to fix problem with DC color after RestoreDC

  ACheckRect := AViewInfo.CheckBoxRect;
  InflateRect(ACheckRect, -AViewInfo.CheckBorderOffset, -AViewInfo.CheckBorderOffset);

  ACheckTransparent := AIsBackgroundTransparent and
    (Assigned(AViewInfo.Painter) or AViewInfo.HasGlyph or
    AViewInfo.NativeStyle and IsThemeBackgroundPartiallyTransparent(
    OpenTheme(totButton), BP_CHECKBOX, GetCheckNativeState(AViewInfo.State, AViewInfo.CheckBoxState)));

  AViewInfo.DrawEditBackground(ACanvas, AViewInfo.Bounds, ACheckRect, ACheckTransparent);

  DrawEditCheck(ACanvas, AViewInfo.CheckBoxRect, AViewInfo.State, AViewInfo.CheckBoxState,
    AViewInfo.CheckBoxGlyph, AViewInfo.CheckBoxGlyphCount,
    AViewInfo.CheckBoxBorderStyle, AViewInfo.NativeStyle,
    AViewInfo.BorderColor, AViewInfo.BackgroundColor, not AIsBackgroundTransparent,
    AViewInfo.IsDesigning, AViewInfo.Focused, True, AViewInfo.Painter,
    AViewInfo.NullValueShowingStyle);

  if AViewInfo.Alignment <> taCenter then
    DrawCheckBoxText(ACanvas, AViewInfo.Text, AViewInfo.Font, AViewInfo.TextColor,
      AViewInfo.TextRect, AViewInfo.DrawTextFlags, AViewInfo.IsTextEnabled);
  if not IsRectEmpty(AViewInfo.FocusRect) then
    ACanvas.DrawFocusRect(AViewInfo.FocusRect);
end;

procedure DrawEditCheck(ACanvas: TcxCanvas; const ACheckRect: TRect;
  AState: TcxCheckBoxState; ACheckState: TcxEditCheckState; AGlyph: TBitmap;
  AGlyphCount: Integer; ABorderStyle: TcxEditCheckBoxBorderStyle;
  ANativeStyle: Boolean; ABorderColor: TColor; ABackgroundColor: TColor;
  ADrawBackground, AIsDesigning, AFocused, ASupportGrayed: Boolean;
  APainter: TcxCustomLookAndFeelPainterClass;
  AGrayedShowingStyle: TcxCheckBoxNullValueShowingStyle = nssGrayedChecked);
const
  CheckState2ButtonState: array[TcxEditCheckState] of TcxButtonState =
      (cxbsNormal, cxbsHot, cxbsPressed, cxbsDisabled);

  procedure DrawCheckBoxGlyph;
  var
    ABitmap: TBitmap;
    AGlyphIndex: Integer;
    R: TRect;
  begin
    AGlyphIndex := GetEditCheckGlyphIndex(AState, ACheckState, ASupportGrayed,
      AGlyphCount);
    ABitmap := TBitmap.Create;
    try
      ABitmap.Assign(AGlyph);
      ABitmap.Height := ACheckRect.Bottom - ACheckRect.Top;
      ABitmap.Width := ACheckRect.Right - ACheckRect.Left;

      R.Left := (AGlyph.Width div AGlyphCount) * AGlyphIndex;
      R.Right := R.Left + ABitmap.Width;
      R.Top := (AGlyph.Height - ABitmap.Height) div 2;
      R.Bottom := R.Top + ABitmap.Height;

      ABitmap.Canvas.CopyRect(Rect(0, 0, ABitmap.Width, ABitmap.Height),
        AGlyph.Canvas, R);
      DrawGlyph(ACanvas, ACheckRect.Left, ACheckRect.Top, ABitmap,
        ACheckState <> ecsDisabled, ColorToRGB(ABackgroundColor));
    finally
      ABitmap.Free;
    end;
  end;

  procedure DrawCheckBoxBorder;
  const
    ACheckBoxStateToButtonStateMap: array [TcxEditCheckState] of TcxButtonState =
      (cxbsNormal, cxbsHot, cxbsPressed, cxbsDisabled);
  var
    ACheckBorderOffset: Integer;
    R: TRect;
  begin
    if ANativeStyle then
    begin
      DrawThemeBackground(OpenTheme(totButton), ACanvas.Handle, BP_CHECKBOX,
        GetCheckNativeState(AState, ACheckState), ACheckRect);
      Exit;
    end;

    R := ACheckRect;
    ACheckBorderOffset := GetEditCheckBorderOffset(ABorderStyle, False, False, APainter);

    if ADrawBackground and (ACheckBorderOffset > 0) then
      ACanvas.FrameRect(R, ABackgroundColor, ACheckBorderOffset);
    InflateRect(R, -ACheckBorderOffset, -ACheckBorderOffset);
    with ACanvas do
    begin
      case ABorderStyle of
        ebsSingle:
          FrameRect(R, ABorderColor);
        ebsThick:
          FrameRect(R, ABorderColor, 2);
        ebsFlat:
          begin
            DrawEdge(R, True, True, cxBordersAll);
            InflateRect(R, -1, -1);
            FrameRect(R, clBtnFace);
          end;
        ebs3D:
          begin
            DrawEdge(R, True, True, cxBordersAll);
            InflateRect(R, -1, -1);
            DrawComplexFrame(R, cl3DDkShadow, cl3DLight, cxBordersAll);
          end;
        ebsUltraFlat, ebsOffice11:
          begin
            if (ABorderStyle = ebsOffice11) and (ACheckState = ecsNormal) and
              not AIsDesigning and not AFocused then
                ABorderColor := clBtnText
            else
              if (ACheckState in [ecsHot, ecsPressed]) or
                AIsDesigning and (ACheckState <> ecsDisabled) or
                (ACheckState = ecsNormal) and AFocused then
                  ABorderColor := GetEditBorderHighlightColor(
                    ABorderStyle = ebsOffice11)
              else
                ABorderColor := clBtnShadow;
            FrameRect(R, ABorderColor);
          end;
      end;
    end;
  end;

  procedure DrawCheck(R: TRect; AColor: TColor);
  const
    ROP_PSDPxax = $B8074A;
  var
    APrevClipRgn: TcxRegion;
  begin
    APrevClipRgn := ACanvas.GetClipRegion;
    try
      ACanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
      InflateRect(R, cxEditMaxCheckBoxBorderWidth, cxEditMaxCheckBoxBorderWidth);
      ACanvas.Brush.Color := AColor;
      BitBlt(ACanvas.Handle, R.Left, R.Top, FCheckMask.Width, FCheckMask.Height,
        FCheckMask.Canvas.Handle, 0, 0, ROP_PSDPxax);
    finally
      ACanvas.SetClipRegion(APrevClipRgn, roSet);
    end;
  end;

  function GetCheckBoxContentColor: TColor;
  const
    AColors: array[TcxEditCheckState] of TColor =
      (clWindow, clWindow, clBtnFace, clBtnFace);
  begin
    if ABorderStyle in [ebsUltraFlat, ebsOffice11] then
      case ACheckState of
        ecsNormal:
          if (AState = cbsGrayed) and (AGrayedShowingStyle = nssInactive) then
            Result := clBtnFace
          else
            Result := clWindow;
        ecsHot, ecsPressed:
          Result := GetEditButtonHighlightColor(
            ACheckState = ecsPressed,
            ABorderStyle = ebsOffice11);
        else
          Result := clBtnFace;
      end
    else
      if (AState = cbsGrayed) and (AGrayedShowingStyle = nssInactive) then
        Result := clBtnFace
      else
        Result := AColors[ACheckState];
  end;

  procedure InternalDrawCheckBoxContent(AContentRect: TRect);
  const
    AButtonStateMap: array [TcxEditCheckState] of TcxButtonState =
      (cxbsNormal, cxbsHot, cxbsPressed, cxbsDisabled);
  var
    ACheckColor: TColor;
  begin
    cxEditFillRect(ACanvas.Handle, AContentRect,
      GetSolidBrush(GetCheckBoxContentColor));
    if (AState = cbsUnchecked) or
      (AState = cbsGrayed) and (AGrayedShowingStyle <> nssGrayedChecked) then
        Exit;
    if (ACheckState = ecsDisabled) or (AState = cbsGrayed) then
      ACheckColor := clBtnShadow
    else
      ACheckColor := clBtnText;
    DrawCheck(AContentRect, ACheckColor);
  end;

  procedure DrawWindowsCheckBoxContent(AContentRect: TRect);
  const
    ABorder3DStyleMap: array [Boolean] of Integer = (DFCS_FLAT, 0);
    AGrayedShowingStyleMap: array [TcxCheckBoxNullValueShowingStyle] of Integer =
      (0, DFCS_INACTIVE, DFCS_CHECKED);
  var
    AClipRgnExists: Boolean;
    AFlags: Integer;
    APrevClipRgn: HRGN;
  begin
    if ACheckState = ecsDisabled then
    begin
      AFlags := DFCS_BUTTON3STATE or DFCS_PUSHED;
      if (AState = cbsUnchecked) or ((AState = cbsGrayed) and (AGrayedShowingStyle <> nssGrayedChecked)) then
        AFlags := AFlags or DFCS_INACTIVE
      else
        AFlags := AFlags or DFCS_CHECKED;
    end
    else
    begin
      AFlags := 0;
      case AState of
        cbsGrayed:
          AFlags := DFCS_BUTTON3STATE or
            AGrayedShowingStyleMap[AGrayedShowingStyle];
        cbsChecked:
          AFlags := DFCS_CHECKED;
      end;
      if ACheckState = ecsPressed then
        AFlags := AFlags or DFCS_PUSHED;
    end;

    APrevClipRgn := CreateRectRgn(0, 0, 0, 0);
    AClipRgnExists := GetClipRgn(ACanvas.Handle, APrevClipRgn) = 1;
    with AContentRect do
      IntersectClipRect(ACanvas.Handle, Left, Top, Right, Bottom);
    InflateRect(AContentRect, cxEditMaxCheckBoxBorderWidth, cxEditMaxCheckBoxBorderWidth);

    DrawFrameControl(ACanvas.Handle, AContentRect, DFC_BUTTON, DFCS_BUTTONCHECK or AFlags or ABorder3DStyleMap[ABorderStyle = ebs3D]);

    if AClipRgnExists then
      SelectClipRgn(ACanvas.Handle, APrevClipRgn)
    else
      SelectClipRgn(ACanvas.Handle, 0);
    DeleteObject(APrevClipRgn);
  end;

  procedure DrawCheckBoxContent;
  var
    ACheckBoxBorderWidth: Integer;
    R: TRect;
  begin
    if ANativeStyle then
      Exit;

    ACheckBoxBorderWidth := cxEditMaxCheckBoxBorderWidth;
    R := ACheckRect;
    InflateRect(R, -ACheckBoxBorderWidth, -ACheckBoxBorderWidth);

    if ABorderStyle in [ebsUltraFlat, ebsOffice11] then
      InternalDrawCheckBoxContent(R)
    else
      DrawWindowsCheckBoxContent(R);
  end;

begin
  if not ADrawBackground then
    ABackgroundColor := clNone;
  if (AState = cbsGrayed) and (AGrayedShowingStyle = nssUnchecked) then
    AState := cbsUnchecked;

  if IsGlyphValid(AGlyph, AGlyphCount) then
    DrawCheckBoxGlyph
  else
  begin
    if APainter <> nil then
    begin
      if ADrawBackground then
        ACanvas.FillRect(ACheckRect, ABackgroundColor);
      APainter.DrawCheckButton(ACanvas, ACheckRect,
        CheckState2ButtonState[ACheckState], AState);
    end
    else
    begin
      DrawCheckBoxBorder;
      DrawCheckBoxContent;
    end;  
  end;
end;

function GetEditCheckBorderOffset(ACheckBorderStyle: TcxContainerBorderStyle;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer;
begin
  if ANativeStyle or AHasGlyph or (APainter <> nil) then
    Result := 0
  else
    Result := cxContainerMaxBorderWidth - GetContainerBorderWidth(ACheckBorderStyle);
end;

function GetEditCheckBorderOffset(ACheckBorderStyle: TcxEditBorderStyle;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer; overload;
begin
  Result := GetEditCheckBorderOffset(
    TcxContainerBorderStyle(ACheckBorderStyle), ANativeStyle, AHasGlyph, APainter);
end;

function GetEditCheckBorderOffset(ALookAndFeelKind: TcxLookAndFeelKind;
  ANativeStyle, AHasGlyph: Boolean; APainter: TcxCustomLookAndFeelPainterClass): Integer;
begin
  if ANativeStyle or AHasGlyph or (APainter <> nil) then
    Result := 0
  else
    Result := cxContainerMaxBorderWidth - GetContainerBorderWidth(ALookAndFeelKind);
end;

function GetEditCheckGlyphIndex(AState: TcxCheckBoxState;
  ACheckState: TcxEditCheckState; ASupportGrayed: Boolean;
  AGlyphCount: Integer): Integer;
var
  AStateCount: Integer;
begin
  AStateCount := Integer(High(TcxCheckBoxState)) -
    Integer(Low(TcxCheckBoxState)) + 1;
  if not ASupportGrayed and (AGlyphCount mod 3 <> 0) and (AGlyphCount mod 2 = 0) then
    Dec(AStateCount);
  case AState of
    cbsUnchecked:
      Result := 0;
    cbsChecked:
      Result := 1;
    else
      Result := 2;
  end;
  if ACheckState = ecsPressed then
    Inc(Result, AStateCount);
  if (Result >= AGlyphCount) and (Result > AStateCount - 1) then
    Result := Result mod AStateCount;
end;

function GetEditCheckSize(ACanvas: TcxCanvas; ANativeStyle: Boolean;
  AGlyph: TBitmap; AGlyphCount: Integer; APainter: TcxCustomLookAndFeelPainterClass): TSize;
var
  AHasGlyph: Boolean;
begin
    AHasGlyph := IsGlyphValid(AGlyph, AGlyphCount);
    if AHasGlyph then
    begin
      Result.cx := AGlyph.Width div AGlyphCount;
      Result.cy := AGlyph.Height;
    end
    else
      if APainter <> nil then
         Result := APainter.CheckButtonSize
      else
        if AreVisualStylesMustBeUsed(ANativeStyle, totButton) then
          with TcxWinXPLookAndFeelPainter do
            Result := CheckButtonSize
        else
          with TcxCustomLookAndFeelPainter do
            Result := CheckButtonSize;
end;

{ TcxCustomCheckBoxViewInfo }

procedure TcxCustomCheckBoxViewInfo.Assign(Source: TObject);
begin
  if Source is TcxCustomCheckBoxViewInfo then
    with Source as TcxCustomCheckBoxViewInfo do
    begin
      Self.CheckBoxState := CheckBoxState;
      Self.State := State;
    end;
  inherited Assign(Source);
end;

procedure TcxCustomCheckBoxViewInfo.DrawText(ACanvas: TcxCanvas);
begin
  DrawCheckBoxText(ACanvas, Text, Font, TextColor, TextRect, DrawTextFlags, IsTextEnabled);
end;

function TcxCustomCheckBoxViewInfo.GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion;
var
  AEquals: Boolean;
  ATempRgn: TcxRegion;
begin
  Result := inherited GetUpdateRegion(AViewInfo);
  if not(AViewInfo is TcxCustomCheckBoxViewInfo) then
    Exit;
  with TcxCustomCheckBoxViewInfo(AViewInfo) do
    AEquals := (Self.CheckBoxState = CheckBoxState) and (Self.State = State);
  if not AEquals then
  begin
    ATempRgn := TcxRegion.Create(CheckBoxRect);
    UniteRegions(Result, ATempRgn);
    ATempRgn.Free;
  end;
end;

function TcxCustomCheckBoxViewInfo.IsHotTrack: Boolean;
begin
  Result := True;
end;

function TcxCustomCheckBoxViewInfo.IsHotTrack(P: TPoint): Boolean;
begin
  Result := IsHotTrack;
end;

function TcxCustomCheckBoxViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; out AText: TCaption; out AIsMultiLine: Boolean;
  out ATextRect: TRect): Boolean;
begin
  Result := False;
end;

procedure TcxCustomCheckBoxViewInfo.Offset(DX, DY: Integer);
begin
  inherited Offset(DX, DY);
  OffsetRect(CheckBoxRect, DX, DY);
  OffsetRect(FocusRect, DX, DY);
end;

function TcxCustomCheckBoxViewInfo.Repaint(AControl: TWinControl;
  const AInnerEditRect: TRect; AViewInfo: TcxContainerViewInfo = nil): Boolean;
var
  R: TRect;
begin
  Result := AControl.HandleAllocated;
  if not Result then
    Exit;

  Result := inherited Repaint(AControl, AInnerEditRect, AViewInfo);
  with TcxCustomCheckBoxViewInfo(AViewInfo) do
  begin
    Result := Result or (AViewInfo <> nil) and
      ((Self.CheckBoxState <> CheckBoxState) or (Self.State <> State));
    if (AViewInfo = nil) or (Self.CheckBoxState <> CheckBoxState) or (Self.State <> State) then
    begin
      R := Self.CheckBoxRect;
      OffsetRect(R, Self.Left, Self.Top);
      InternalInvalidate(AControl.Handle, R, cxEmptyRect, False);
    end;
  end;
end;

function TcxCustomCheckBoxViewInfo.IsTextEnabled: Boolean;
begin
  Result := IsContainerInnerControl or Enabled or IsTextColorAssigned or NativeStyle;
end;

procedure TcxCustomCheckBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  DrawCustomCheckBox(ACanvas, Self);
end;

function TcxCustomCheckBoxViewInfo.GetEdit: TcxCustomCheckBox;
begin
  Result := TcxCustomCheckBox(FEdit);
end;

{ TcxCustomCheckBoxViewData }

procedure TcxCustomCheckBoxViewData.Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);

var
  ACheckBoxViewInfo: TcxCustomCheckBoxViewInfo;

  procedure CalculateCheckRects(const ACheckSize: TSize);
  var
    ACaptionRect, ACheckBoxRect: TRect;
    AAlignment: TAlignment;
  begin
    AAlignment := ACheckBoxViewInfo.Alignment;
    ACheckBoxRect := AViewInfo.ClientRect;
    ACaptionRect := ACheckBoxRect;

    if IsInplace then
    begin
      if AAlignment = taLeftJustify then
      begin
        Dec(ACaptionRect.Right, 2);
        if not Properties.IsEmbeddedEdit then
          Inc(ACheckBoxRect.Left, 2);
      end
      else
        if AAlignment = taRightJustify then
        begin
          Inc(ACaptionRect.Left, 2);
          if not Properties.IsEmbeddedEdit then
            Dec(ACheckBoxRect.Right, 2);
        end;
      Inc(ACaptionRect.Top, EditContentParams.Offsets.Top);
      Dec(ACaptionRect.Bottom, EditContentParams.Offsets.Bottom);
    end
    else
    begin
      InflateRect(ACaptionRect, -2, -2);
      if not Properties.IsEmbeddedEdit and (not EmulateStandardControlDrawing or
        not AreVisualStylesMustBeUsed(AViewInfo.NativeStyle, totButton) and (Style.LookAndFeel.SkinPainter = nil)) then
          Dec(ACaptionRect.Top);
    end;
    if not (IsInplace or AreVisualStylesMustBeUsed(AViewInfo.NativeStyle, totButton) and Properties.IsEmbeddedEdit) then
      InflateRect(ACheckBoxRect, -2, -2);
      
    if ACheckBoxRect.Bottom - ACheckBoxRect.Top > ACheckSize.cy then
    begin
      Inc(ACheckBoxRect.Top, (ACheckBoxRect.Bottom - ACheckBoxRect.Top - ACheckSize.cy) div 2);
      ACheckBoxRect.Bottom := ACheckBoxRect.Top + ACheckSize.cy;
    end;
    if ACheckBoxRect.Right - ACheckBoxRect.Left > ACheckSize.cx then
      if AAlignment = taCenter then
      begin
        Inc(ACheckBoxRect.Left, (ACheckBoxRect.Right - ACheckBoxRect.Left - ACheckSize.cx) div 2);
        ACheckBoxRect.Right := ACheckBoxRect.Left + ACheckSize.cx;
      end
      else
        if AAlignment = taLeftJustify then
        begin
          ACheckBoxRect.Right := ACheckBoxRect.Left + ACheckSize.cx;
          ACaptionRect.Left := ACheckBoxRect.Right + 3;
        end
        else
        begin
          ACheckBoxRect.Left := ACheckBoxRect.Right - ACheckSize.cx;
          ACaptionRect.Right := ACheckBoxRect.Left - 3 + Integer(IsInplace and Properties.IsEmbeddedEdit);
        end
    else
      ACaptionRect.Right := ACaptionRect.Left;
    if IsRectEmpty(ACheckBoxRect) then
      ACheckBoxRect := cxEmptyRect;

    if not ACheckBoxViewInfo.IsTextEnabled and (Style.LookAndFeel.SkinPainter = nil) then
    begin
      Inc(ACaptionRect.Right);
      Inc(ACaptionRect.Bottom);
    end;

    ACheckBoxViewInfo.TextRect := ACaptionRect;
    ACheckBoxViewInfo.CheckBoxRect := ACheckBoxRect;
  end;

  function GetCheckBoxBorderStyle(AEditHotState: TcxContainerHotState): TcxEditBorderStyle;
  const
    ABorderStyles: array[TcxContainerHotState, TcxEditBorderStyle] of TcxEditBorderStyle = (
      (ebsNone, ebsSingle, ebsThick, ebsFlat, ebs3D, ebsUltraFlat, ebsOffice11),
      (ebsNone, ebsSingle, ebsThick, ebsFlat, ebs3D, ebsUltraFlat, ebsOffice11),
      (ebsFlat, ebsThick, ebsThick, ebs3D, ebs3D, ebsUltraFlat, ebsOffice11)
    );
  begin
    Result := ABorderStyles[AEditHotState, Style.BorderStyle];
  end;

begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);

  ACheckBoxViewInfo := TcxCustomCheckBoxViewInfo(AViewInfo);
  ACheckBoxViewInfo.IsEditClass := GetIsEditClass;
  ACheckBoxViewInfo.DrawSelectionBar := False;
  ACheckBoxViewInfo.HasPopupWindow := False;
  ACheckBoxViewInfo.DrawTextFlags := GetDrawTextFlags;
  CalculateCheckBoxViewInfo(Self, ACheckBoxViewInfo, AIsMouseEvent);
  if Edit <> nil then
//    ACheckBoxViewInfo.Text := ''
//  else
    ACheckBoxViewInfo.Text := TcxCustomCheckBox(Edit).Caption;
  if IsInplace and not (Properties.IsEmbeddedEdit or
    Properties.UseAlignmentWhenInplace or (ACheckBoxViewInfo.Text <> '')) then
      ACheckBoxViewInfo.Alignment := taCenter
  else
    ACheckBoxViewInfo.Alignment := Properties.Alignment;
  ACheckBoxViewInfo.CheckBoxBorderStyle := GetCheckBoxBorderStyle(AViewInfo.HotState);
  ACheckBoxViewInfo.CheckBoxGlyph := Properties.Glyph;
  ACheckBoxViewInfo.CheckBoxGlyphCount := Properties.GlyphCount;
  ACheckBoxViewInfo.NullValueShowingStyle := Properties.NullStyle;
  ACheckBoxViewInfo.HasGlyph := IsGlyphValid(Properties.Glyph, Properties.GlyphCount);
  ACheckBoxViewInfo.CheckBorderOffset :=
    GetEditCheckBorderOffset(ACheckBoxViewInfo.CheckBoxBorderStyle, NativeStyle,
    ACheckBoxViewInfo.HasGlyph, ACheckBoxViewInfo.Painter);
  ACheckBoxViewInfo.IsTextColorAssigned := Style.IsValueAssigned(svTextColor) or
    ((ACheckBoxViewInfo.Painter <> nil) and
    (ACheckBoxViewInfo.Painter.DefaultEditorTextColor(True) <> clDefault));

  CalculateCheckRects(GetEditCheckSize(ACanvas, NativeStyle, Properties.Glyph,
    Properties.GlyphCount, AViewInfo.Painter));
  if not Enabled then
    ACheckBoxViewInfo.CheckBoxState := ecsDisabled
  else
    if IsCheckPressed then
      ACheckBoxViewInfo.CheckBoxState := ecsPressed
    else
      if not IsDesigning and PtInRect(ACheckBoxViewInfo.BorderRect, P) then
        if Shift = [] then
          ACheckBoxViewInfo.CheckBoxState := ecsHot
        else if (Shift = [ssLeft]) and ((Button = cxmbLeft) or (ACheckBoxViewInfo.CheckBoxState = ecsPressed)) then
          ACheckBoxViewInfo.CheckBoxState := ecsPressed
        else
          ACheckBoxViewInfo.CheckBoxState := ecsNormal
      else
        ACheckBoxViewInfo.CheckBoxState := ecsNormal;

  CalculateCustomCheckBoxViewInfo(ACanvas, Self, ACheckBoxViewInfo);

  if IsInplace and (ACheckBoxViewInfo.CheckBoxBorderStyle = ebsSingle) then
    if (ACheckBoxViewInfo.CheckBoxState = ecsHot) or (IsDesigning and (ACheckBoxViewInfo.CheckBoxState <> ecsDisabled)) then
      ACheckBoxViewInfo.BorderColor := clHighlight
    else
      ACheckBoxViewInfo.BorderColor := clBtnShadow;
end;

procedure TcxCustomCheckBoxViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
  if PreviewMode then
    TcxCustomCheckBoxViewInfo(AViewInfo).State := cbsChecked
  else
    TcxCustomCheckBoxViewInfo(AViewInfo).State := Properties.GetState(AEditValue);
  if IsInplace and not Properties.IsEmbeddedEdit then
    TcxCustomCheckBoxViewInfo(AViewInfo).Text := '';
  CalculateCustomCheckBoxViewInfo(ACanvas, Self, TcxCustomCheckBoxViewInfo(AViewInfo));
end;

function TcxCustomCheckBoxViewData.GetBorderStyle: TcxEditBorderStyle;
begin
  Result := ebsNone;
end;

function TcxCustomCheckBoxViewData.InternalGetEditConstantPartSize(ACanvas: TcxCanvas;
  AIsInplace: Boolean; AEditSizeProperties: TcxEditSizeProperties;
  var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo): TSize;
var
  ACheckBoxViewInfo: TcxCustomCheckBoxViewInfo;
  ASize1, ASize2: TSize;
  AText: string;
begin
  Result := inherited InternalGetEditConstantPartSize(ACanvas, AIsInplace,
    AEditSizeProperties, MinContentSize, AViewInfo);
  ACheckBoxViewInfo := TcxCustomCheckBoxViewInfo(AViewInfo);
  with ACheckBoxViewInfo.CheckBoxRect do
    ASize1 := Size(Right - Left, Bottom - Top);

  if IsInplace then
    if (ACheckBoxViewInfo.Alignment <> taCenter) and (ACheckBoxViewInfo.Text <> '') then
    begin
      ACanvas.Font := Style.GetVisibleFont;
      ASize1.cx := ACheckBoxViewInfo.TextRect.Left - ACheckBoxViewInfo.Bounds.Left +
        ACanvas.TextWidth(RemoveAccelChars(ACheckBoxViewInfo.Text)) +
        (ACheckBoxViewInfo.Bounds.Right - ACheckBoxViewInfo.TextRect.Right);
    end
    else
      ASize1.cx := ASize1.cx + 2 * 2;

  if IsInplace then
    ASize1.cy := ASize1.cy + (1 - ACheckBoxViewInfo.CheckBorderOffset) * 2
  else
    ASize1.cy := ASize1.cy + 2 * 2;
  if (Properties.Alignment = taCenter) or IsInplace then
    AText := 'Gg'
  else
    AText := RemoveAccelChars(TcxCustomCheckBox(Edit).Caption);
  if not Enabled and not IsNativeStyle(Style.LookAndFeel) then
    Dec(AEditSizeProperties.Width);
  ASize2 := GetTextEditContentSize(ACanvas, Self, AText,
    DrawTextFlagsTocxTextOutFlags(GetDrawTextFlags) or CXTO_SINGLELINE or CXTO_CHARBREAK,
    AEditSizeProperties, 0, False);
  if ASize1.cy < ASize2.cy then
    ASize1.cy := ASize2.cy;

  Result.cx := Result.cx + ASize1.cx;
  Result.cy := Result.cy + ASize1.cy;
end;

function TcxCustomCheckBoxViewData.GetDrawTextFlags: Integer;
const
  AHorzAlignmentFlags: array [TcxEditHorzAlignment] of Integer = (
    cxAlignLeft, cxAlignLeft, cxAlignHCenter
  );
begin
  with Properties.InternalAlignment do
  begin
    Result := AHorzAlignmentFlags[Horz];
    Result := Result or cxSingleLine;
  end;
  Result := Result or cxShowPrefix;
  if Properties.MultiLine then
  begin
    Result := Result and (not cxSingleLine);
    Result := Result or cxDontClip;
    Result := Result or cxWordBreak;
  end;

  if IsInplace or not Properties.MultiLine then
    Result := Result or cxAlignVCenter
  else
    Result := Result or cxAlignTop;
end;

function TcxCustomCheckBoxViewData.GetIsEditClass: Boolean;
begin
  Result := True;
end;

function TcxCustomCheckBoxViewData.IsCheckPressed: Boolean;
begin
  Result := (Edit <> nil) and TcxCustomCheckBox(Edit).FIsCheckPressed;
end;

function TcxCustomCheckBoxViewData.GetProperties: TcxCustomCheckBoxProperties;
begin
  Result := TcxCustomCheckBoxProperties(FProperties);
end;

{ TcxCheckBoxStyle }

function TcxCheckBoxStyle.HasBorder: Boolean;
begin
  Result := False;
end;

{ TcxCustomCheckBoxProperties }

constructor TcxCustomCheckBoxProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FDisplayChecked := cxGetResourceString(@cxSEditCheckBoxChecked);
  FDisplayUnchecked := cxGetResourceString(@cxSEditCheckBoxUnchecked);
  FDisplayGrayed := cxGetResourceString(@cxSEditCheckBoxGrayed);

  FGlyphCount := 6;
  FNullStyle := nssGrayedChecked;
  FValueChecked := True;
  FValueGrayed := Null;
  FValueUnchecked := False;
end;

destructor TcxCustomCheckBoxProperties.Destroy;
begin
  if FGlyph <> nil then
    FreeAndNil(FGlyph);
  inherited Destroy;
end;

procedure TcxCustomCheckBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomCheckBoxProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomCheckBoxProperties do
      begin
        Self.AllowGrayed := AllowGrayed;
        Self.DisplayChecked := DisplayChecked;
        Self.DisplayGrayed := DisplayGrayed;
        Self.DisplayUnchecked := DisplayUnchecked;
        Self.FullFocusRect := FullFocusRect;
        Self.Glyph := Glyph;
        Self.GlyphCount := GlyphCount;
        Self.MultiLine := MultiLine;
        Self.NullStyle := NullStyle;
        Self.UseAlignmentWhenInplace := UseAlignmentWhenInplace;
        Self.SetStateValues(ValueChecked, ValueGrayed, ValueUnchecked);
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomCheckBoxProperties.CanCompareEditValue: Boolean;
begin
  Result := True;
end;

function TcxCustomCheckBoxProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
begin
  Result := GetState(AEditValue1) = GetState(AEditValue2);
end;

class function TcxCustomCheckBoxProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxCheckBox;
end;

function TcxCustomCheckBoxProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
begin
  case GetState(AEditValue) of
    cbsChecked:
      Result := FDisplayChecked;
    cbsUnchecked:
      Result := FDisplayUnchecked;
    cbsGrayed:
      Result := FDisplayGrayed;
  end;
end;

class function TcxCustomCheckBoxProperties.GetStyleClass: TcxCustomEditStyleClass;
begin
  Result := TcxCheckBoxStyle;
end;

function TcxCustomCheckBoxProperties.GetSpecialFeatures: TcxEditSpecialFeatures;
begin
  Result := inherited GetSpecialFeatures + [esfNoContentPart];
end;

function TcxCustomCheckBoxProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoAlwaysHotTrack, esoEditing, esoFiltering, esoHotTrack,
    esoShowingCaption, esoSorting, esoTransparency];
end;

class function TcxCustomCheckBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomCheckBoxViewInfo;
end;

function TcxCustomCheckBoxProperties.IsActivationKey(AKey: Char): Boolean;
begin
  Result := AKey = ' ';
end;

function TcxCustomCheckBoxProperties.IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := inherited IsEditValueValid(EditValue, AEditFocused);
  if Result then
    Result := not CheckValue(EditValue);
end;

function TcxCustomCheckBoxProperties.IsResetEditClass: Boolean;
begin
  Result := True;
end;

procedure TcxCustomCheckBoxProperties.PrepareDisplayValue(const AEditValue:
  TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean);
begin
  if VarEqualsExact(AEditValue, FValueChecked) then
    DisplayValue := Integer(cbsChecked)
  else
    if VarEqualsExact(AEditValue, FValueUnchecked) then
      DisplayValue := Integer(cbsUnchecked)
    else
      DisplayValue := Integer(cbsGrayed);
end;

function TcxCustomCheckBoxProperties.CanValidate: Boolean;
begin
  Result := True;
end;

procedure TcxCustomCheckBoxProperties.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Caption', ReadCaption, nil, False);
end;

class function TcxCustomCheckBoxProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomCheckBoxViewData;
end;

function TcxCustomCheckBoxProperties.HasDisplayValue: Boolean;
begin
  Result := True;
end;

function TcxCustomCheckBoxProperties.CheckValue(const AValue: TcxEditValue): Boolean;
begin
  Result := not(InternalVarEqualsExact(AValue, FValueChecked) or InternalVarEqualsExact(AValue,
    FValueGrayed) or InternalVarEqualsExact(AValue, FValueUnchecked));
end;

function TcxCustomCheckBoxProperties.GetState(
  const AEditValue: TcxEditValue): TcxCheckBoxState;
var
  ADisplayValue: TcxEditValue;
begin
  PrepareDisplayValue(AEditValue, ADisplayValue, False);
  Result := TcxCheckBoxState(Integer(ADisplayValue));
end;

function TcxCustomCheckBoxProperties.InternalGetGlyph: TBitmap;
begin
  if FGlyph = nil then
  begin
    FGlyph := TBitmap.Create;
    FGlyph.OnChange := GlyphChanged;
  end;
  Result := FGlyph;
end;

function TcxCustomCheckBoxProperties.IsEmbeddedEdit: Boolean;
begin
  Result := False;
end;

function TcxCustomCheckBoxProperties.GetAlignment: TAlignment;
begin
  Result := inherited Alignment.Horz;
end;

function TcxCustomCheckBoxProperties.GetGlyph: TBitmap;
begin
  Result := InternalGetGlyph;
end;

function TcxCustomCheckBoxProperties.GetInternalAlignment: TcxEditAlignment;
begin
  Result := inherited Alignment;
end;

procedure TcxCustomCheckBoxProperties.GlyphChanged(Sender: TObject);
begin
  Changed;
end;

function TcxCustomCheckBoxProperties.IsAlignmentStored: Boolean;
begin
  Result := inherited Alignment.IsHorzStored;
end;

function TcxCustomCheckBoxProperties.IsDisplayCheckedStored: Boolean;
begin
  Result := not InternalCompareString(FDisplayChecked,
    cxGetResourceString(@cxSEditCheckBoxChecked), True);
end;

function TcxCustomCheckBoxProperties.IsDisplayGrayedStored: Boolean;
begin
  Result := not InternalCompareString(FDisplayGrayed,
    cxGetResourceString(@cxSEditCheckBoxGrayed), True);
end;

function TcxCustomCheckBoxProperties.IsDisplayUncheckedStored: Boolean;
begin
  Result := not InternalCompareString(FDisplayUnchecked,
    cxGetResourceString(@cxSEditCheckBoxUnchecked), True);
end;

function TcxCustomCheckBoxProperties.IsLoading: Boolean;
begin
  Result := (GetOwnerComponent(Self) <> nil) and (csLoading in GetOwnerComponent(Self).ComponentState); 
end;

function TcxCustomCheckBoxProperties.IsValueCheckedStored: Boolean;
begin
  Result := not InternalVarEqualsExact(FValueChecked, True);
end;

function TcxCustomCheckBoxProperties.IsValueGrayedStored: Boolean;
begin
  Result := not VarIsNull(FValueGrayed);
end;

function TcxCustomCheckBoxProperties.IsValueUncheckedStored: Boolean;
begin
  Result := not InternalVarEqualsExact(FValueUnchecked, False);
end;

// obsolete
procedure TcxCustomCheckBoxProperties.ReadCaption(Reader: TReader);
begin
  Caption := Reader.ReadString;
end;

procedure TcxCustomCheckBoxProperties.SetAlignment(Value: TAlignment);
begin
  inherited Alignment.Horz := Value;
end;

// obsolete
procedure TcxCustomCheckBoxProperties.SetCaption(const Value: TCaption);
begin
  FIsCaptionAssigned := True;
  if not InternalCompareString(Value, FCaption, True) then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetFullFocusRect(Value: Boolean);
begin
  if Value <> FFullFocusRect then
  begin
    FFullFocusRect := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetGlyph(Value: TBitmap);
begin
  if Value = nil then
    FreeAndNil(FGlyph)
  else
    Glyph.Assign(Value);
  Changed;
end;

procedure TcxCustomCheckBoxProperties.SetGlyphCount(Value: Integer);
begin
  if FGlyphCount <> Value then
  begin
    FGlyphCount := Value;
    if FGlyph <> nil then
      Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetMultiLine(Value: Boolean);
begin
  if Value <> FMultiLine then
  begin
    FMultiLine := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetNullStyle(Value: TcxCheckBoxNullValueShowingStyle);
begin
  if Value <> FNullStyle then
  begin
    FNullStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetStateValues(const AValueChecked, AValueGrayed, AValueUnchecked: TcxEditValue);
var
  AIsValuesValid: Boolean;
begin
  AIsValuesValid := not(InternalVarEqualsExact(AValueChecked, AValueGrayed) or
    InternalVarEqualsExact(AValueGrayed, AValueUnchecked) or
    InternalVarEqualsExact(AValueChecked, AValueUnchecked) or
    VarIsNull(AValueChecked) or VarIsNull(AValueUnchecked));
  if AIsValuesValid then
  begin
    FValueChecked := AValueChecked;
    FValueGrayed := AValueGrayed;
    FValueUnchecked := AValueUnchecked;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetUseAlignmentWhenInplace(Value: Boolean);
begin
  if Value <> FUseAlignmentWhenInplace then
  begin
    FUseAlignmentWhenInplace := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetValueChecked(const Value: TcxEditValue);
begin
  if IsLoading or CheckValue(Value) and not VarIsNull(Value) then
  begin
    FValueChecked := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetValueGrayed(const Value: TcxEditValue);
begin
  if IsLoading or CheckValue(Value) then
  begin
    FValueGrayed := Value;
    Changed;
  end;
end;

procedure TcxCustomCheckBoxProperties.SetValueUnchecked(const Value: TcxEditValue);
begin
  if IsLoading or CheckValue(Value) and not VarIsNull(Value) then
  begin
    FValueUnchecked := Value;
    Changed;
  end;
end;

{ TcxCustomCheckBox }

procedure TcxCustomCheckBox.Clear;
begin
  Checked := False;
end;

class function TcxCustomCheckBox.GetPropertiesClass: TcxCustomEditPropertiesClass; 
begin
  Result := TcxCustomCheckBoxProperties;
end;

procedure TcxCustomCheckBox.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
begin
  case TcxCheckBoxState(Integer(ADisplayValue)) of
    cbsUnchecked:
      EditValue := ActiveProperties.FValueUnchecked;
    cbsChecked:
      EditValue := ActiveProperties.FValueChecked;
    cbsGrayed:
      EditValue := ActiveProperties.FValueGrayed;
  end;
end;

procedure TcxCustomCheckBox.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if (IsLoading or FIsLoaded) and FIsLoadingStateAssigned or not(Sender is TCustomAction) then
    Exit;
  if not CheckDefaults or (Checked = False) then
    TcxCheckBoxActionLink(ActionLink).InternalSetChecked(TCustomAction(Sender).Checked);
end;

function TcxCustomCheckBox.CanHaveTransparentBorder: Boolean;
begin
  Result := not IsInplace and not ActiveProperties.IsEmbeddedEdit or
    inherited CanHaveTransparentBorder;
end;

function TcxCustomCheckBox.DefaultParentColor: Boolean;
begin
  Result := True;
end;

procedure TcxCustomCheckBox.DoEditKeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited DoEditKeyDown(Key, Shift);
  if Key = 0 then
    Exit;

  case Key of
    VK_SPACE:
      begin
        with ViewInfo do
          if CheckBoxState in [ecsNormal, ecsHot] then
          begin
            FIsCheckPressed := True;
            CheckBoxState := ecsPressed;
            ShortRefreshContainer(False);
            Key := 0;
          end;
      end;
  end;
end;

procedure TcxCustomCheckBox.DoEditKeyPress(var Key: Char);
begin
  inherited DoEditKeyPress(Key);
  if Key = #0 then
    Exit;

  if IsInplace and (Key = #32) and (ViewInfo.CheckBoxState = ecsNormal) then
  begin
    Toggle;
    Key := #0;
  end;
end;

procedure TcxCustomCheckBox.DoEditKeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited DoEditKeyUp(Key, Shift);
  if Key = 0 then
    Exit;

  case Key of
    VK_SPACE:
      begin
        if ViewInfo.CheckBoxState = ecsPressed then
        begin
          FIsCheckPressed := False;
          ViewInfo.CheckBoxState := ecsNormal;
          InvalidateCheckRect;
          Toggle;
        end;
      end;
  end;
end;

procedure TcxCustomCheckBox.DoExit;
begin
  FIsCheckPressed := False;
  inherited DoExit;
end;

procedure TcxCustomCheckBox.FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties);
begin
  AEditSizeProperties := DefaultcxEditSizeProperties;
  if not ActiveProperties.MultiLine then
    AEditSizeProperties.MaxLineCount := 1;
  AEditSizeProperties.Width := ViewInfo.TextRect.Right - ViewInfo.TextRect.Left;
end;

function TcxCustomCheckBox.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TcxCheckBoxActionLink;
end;

function TcxCustomCheckBox.GetEditStateColorKind: TcxEditStateColorKind;
begin
  Result := cxEditStateColorKindMap[Enabled];
end;

function TcxCustomCheckBox.GetShadowBounds: TRect;
begin
  if not IsInplace and not ActiveProperties.IsEmbeddedEdit and
    ViewInfo.NativeStyle and Style.TransparentBorder then
  begin
    Result := GetControlRect(Self);
    InflateRect(Result, -cxContainerMaxBorderWidth, -cxContainerMaxBorderWidth);
  end
  else
    Result := inherited GetShadowBounds;
end;

procedure TcxCustomCheckBox.Initialize;
begin
  inherited Initialize;
  ControlStyle := ControlStyle - [csDoubleClicks];
  Width := 121;
  PrepareEditValue(Integer(cbsUnchecked), FEditValue, False);
end;

function TcxCustomCheckBox.InternalGetNotPublishedStyleValues: TcxEditStyleValues;
begin
  Result := inherited InternalGetNotPublishedStyleValues;
  Include(Result, svEdges);
end;

procedure TcxCustomCheckBox.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
var
  APrevState: TcxCheckBoxState;
begin
  APrevState := State;
  inherited InternalSetEditValue(Value, AValidateEditValue);
  if APrevState <> State then
  begin
    ViewInfo.State := State;
    Click;
    DoChange;
  end;
  ShortRefreshContainer(False);
end;

function TcxCustomCheckBox.IsClickEnabledDuringLoading: Boolean;
begin
  Result := IsDBEdit;
end;

function TcxCustomCheckBox.IsNativeBackground: Boolean;
begin
  Result := IsNativeStyle and ParentBackground and not IsInplace and
    not Transparent;
end;

procedure TcxCustomCheckBox.Loaded;
begin
  FIsLoaded := True;
  LockChangeEvents(True);
  LockClick(True);
  try
    inherited Loaded;
    if FIsLoadingStateAssigned then
      State := FLoadingState
    else
      if not IsDBEdit then
        State := cbsUnchecked;
  finally
    LockClick(False);
    LockChangeEvents(False, False);
    FIsLoaded := False;
  end;
end;

procedure TcxCustomCheckBox.ProcessViewInfoChanges(APrevViewInfo: TcxCustomEditViewInfo;
  AIsMouseDownUpEvent: Boolean);
begin
  if (TcxCustomCheckBoxViewInfo(APrevViewInfo).CheckBoxState = ecsPressed) and
      (ViewInfo.CheckBoxState = ecsHot) then
    Toggle;
end;

procedure TcxCustomCheckBox.PropertiesChanged(Sender: TObject);
begin
  if ActiveProperties.FIsCaptionAssigned then
  begin
    Caption := ActiveProperties.Caption;
    ActiveProperties.FIsCaptionAssigned := False;
  end;

  if ViewInfo.State <> State then
  begin
    ViewInfo.State := State;
    InvalidateCheckRect;
    if not AreChangeEventsLocked then
    begin
      Click;
      DoChange;
    end;
  end;
  inherited PropertiesChanged(Sender);
end;

procedure TcxCustomCheckBox.TextChanged;
begin
  inherited TextChanged;
  ViewInfo.Text := Caption;
  Invalidate;
end;

procedure TcxCustomCheckBox.InvalidateCheckRect;
begin
  InvalidateRect(ViewInfo.CheckBoxRect, False);
end;

procedure TcxCustomCheckBox.Toggle;
begin
  LockChangeEvents(True);
  try
    KeyboardAction := True;
    try
      begin
        case State of
          cbsUnchecked:
            if ActiveProperties.AllowGrayed then
              State := cbsGrayed
            else
              State := cbsChecked;
          cbsChecked:
            State := cbsUnchecked;
          cbsGrayed:
            State := cbsChecked;
        end;
      end;
    finally
      KeyboardAction := False;
    end;
    if ActiveProperties.ImmediatePost and CanPostEditValue and ValidateEdit(True) then
      InternalPostEditValue;
  finally
    LockChangeEvents(False);
  end;
end;

function TcxCustomCheckBox.GetChecked: Boolean;
begin
  Result := State = cbsChecked;
end;

function TcxCustomCheckBox.GetProperties: TcxCustomCheckBoxProperties;
begin
  Result := TcxCustomCheckBoxProperties(FProperties);
end;

function TcxCustomCheckBox.GetActiveProperties: TcxCustomCheckBoxProperties;
begin
  Result := TcxCustomCheckBoxProperties(InternalGetActiveProperties);
end;

function TcxCustomCheckBox.GetState: TcxCheckBoxState;
begin
  Result := ActiveProperties.GetState(EditValue);
end;

function TcxCustomCheckBox.GetStyle: TcxCheckBoxStyle;
begin
  Result := TcxCheckBoxStyle(FStyles.Style);
end;

function TcxCustomCheckBox.GetViewInfo: TcxCustomCheckBoxViewInfo;
begin
  Result := TcxCustomCheckBoxViewInfo(FViewInfo);
end;

function TcxCustomCheckBox.IsStateStored: Boolean;
const
  AStates: array[Boolean] of TcxCheckBoxState = (cbsUnchecked, cbsChecked);
begin
  Result := not (Action is TCustomAction) or
    (State <> AStates[TCustomAction(Action).Checked]);
end;

procedure TcxCustomCheckBox.SetChecked(Value: Boolean);
begin
  if Value then
    State := cbsChecked
  else
    State := cbsUnchecked;
end;

procedure TcxCustomCheckBox.SetProperties(Value: TcxCustomCheckBoxProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomCheckBox.SetState(Value: TcxCheckBoxState);
var
  AEditValue: TcxEditValue;
begin
  if IsLoading then
  begin
    FLoadingState := Value;
    FIsLoadingStateAssigned := True;
  end
  else
    if Value <> State then
    begin
      PrepareEditValue(Integer(Value), AEditValue, InternalFocused);
      InternalEditValue := AEditValue;
    end;
end;

procedure TcxCustomCheckBox.SetStyle(Value: TcxCheckBoxStyle);
begin
  FStyles.Style := Value;
end;

procedure TcxCustomCheckBox.WMLButtonUp(var Message: TWMLButtonUp);
begin
  ControlState := ControlState - [csClicked];
  inherited;
end;

procedure TcxCustomCheckBox.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) {D3 - bug "&&"} and CanFocus then
    begin
      SetFocus;
      if Focused then
        Toggle;
      Result := 1;
    end
    else
      inherited;
end;

procedure TcxCustomCheckBox.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  if ViewInfo.NativeStyle and ParentBackground then
    Invalidate;
end;

{ TcxCheckBox }

class function TcxCheckBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCheckBoxProperties;
end;

function TcxCheckBox.GetActiveProperties: TcxCheckBoxProperties;
begin
  Result := TcxCheckBoxProperties(InternalGetActiveProperties);
end;

function TcxCheckBox.GetProperties: TcxCheckBoxProperties;
begin
  Result := TcxCheckBoxProperties(FProperties);
end;

procedure TcxCheckBox.SetProperties(Value: TcxCheckBoxProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterCheckBoxHelper }

class procedure TcxFilterCheckBoxHelper.GetFilterValue(AEdit: TcxCustomEdit;
  AEditProperties: TcxCustomEditProperties; var V: Variant; var S: TCaption);
begin
  with TcxComboBox(AEdit) do
  begin
    case ItemIndex of
      -1:
        V := Null;
      0:
        V := TcxCustomCheckBoxProperties(AEditProperties).ValueChecked;
      1:
        V := TcxCustomCheckBoxProperties(AEditProperties).ValueUnchecked;
    end;
    if ItemIndex = -1 then
      S := ''
    else
      S := TcxCustomCheckBoxProperties(AEditProperties).GetDisplayText(V);
  end;
end;

class function TcxFilterCheckBoxHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoBlanks, fcoNonBlanks];
end;

class procedure TcxFilterCheckBoxHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
var
  ACheckBoxProperties: TcxCustomCheckBoxProperties;
begin
  ACheckBoxProperties := TcxCustomCheckBoxProperties(AEditProperties);
  with TcxComboBoxProperties(AProperties).Items do
  begin
    Clear;
    Add(ACheckBoxProperties.GetDisplayText(ACheckBoxProperties.ValueChecked));
    Add(ACheckBoxProperties.GetDisplayText(ACheckBoxProperties.ValueUnchecked));
  end;
  TcxComboBoxProperties(AProperties).DropDownListStyle := lsFixedList;
  TcxComboBoxProperties(AProperties).IDefaultValuesProvider := nil;
  ClearPropertiesEvents(AProperties);
end;

class procedure TcxFilterCheckBoxHelper.SetFilterValue(AEdit: TcxCustomEdit;
  AEditProperties: TcxCustomEditProperties; AValue: Variant);
const
  AItemIndexMap: array [TcxCheckBoxState] of Integer = (1, 0, -1);
var
  V: TcxEditValue;
begin
  AEditProperties.PrepareDisplayValue(AValue, V, AEdit.Focused);
  TcxComboBox(AEdit).ItemIndex := AItemIndexMap[TcxCheckBoxState((V))];
end;

class function TcxFilterCheckBoxHelper.UseDisplayValue: Boolean;
begin
  Result := True;
end;

{ TcxCheckBoxActionLink }

procedure TcxCheckBoxActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TcxCustomCheckBox;
end;

function TcxCheckBoxActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and (FClient.State <> cbsGrayed) and
    (FClient.Checked = TCustomAction(Action).Checked);
end;

procedure TcxCheckBoxActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then
    InternalSetChecked(Value);
end;

procedure TcxCheckBoxActionLink.InternalSetChecked(Value: Boolean);
begin
  FClient.LockClick(True);
  FClient.LockChangeEvents(True);
  try
    FClient.Checked := Value;
  finally
    FClient.LockChangeEvents(False, False);
    FClient.LockClick(False);
  end;
end;

initialization
  GetRegisteredEditProperties.Register(TcxCheckBoxProperties, scxSEditRepositoryCheckBoxItem);
  FilterEditsController.Register(TcxCheckBoxProperties, TcxFilterCheckBoxHelper);
  PrepareCheckMask;

finalization
  FilterEditsController.Unregister(TcxCheckBoxProperties, TcxFilterCheckBoxHelper);
  FreeAndNil(FCheckMask);

end.

