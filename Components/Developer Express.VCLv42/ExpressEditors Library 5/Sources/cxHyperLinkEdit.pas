
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

unit cxHyperLinkEdit;

{$I cxVer.inc}

interface

uses
  Messages,
  Windows,
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  SysUtils, Graphics, Classes, Controls, Menus, cxGraphics, cxContainer,
  cxControls, cxEdit, cxTextEdit, cxEditConsts, cxFilterControlUtils;

const
  cxHyperLinkEditDefaultLinkColor = clBlue;

type
  { TcxHyperLinkEditViewInfo }

  TcxCustomHyperLinkEdit = class;

  TcxHyperLinkEditViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure GetColorSettingsByPainter(out ABackground, ATextColor: TColor); override;
  public
    function IsHotTrack: Boolean; override;
    function IsHotTrack(P: TPoint): Boolean; override;
    procedure PrepareCanvasFont(ACanvas: TCanvas); override;
  end;

  { TcxCustomHyperLinkEditProperties }

  TcxHyperLinkEditUsePrefix = (upAlways, upOnlyOnExecute, upNever);

  TcxCustomHyperLinkEditProperties = class(TcxCustomTextEditProperties)
  private
    FSingleClick: Boolean;
    FLinkColor: TColor;
    FOnStartClick: TNotifyEvent;
    FPrefix: string;
    FStartKey: TShortCut;
    FUsePrefix: TcxHyperLinkEditUsePrefix;
    function GetAutoComplete: Boolean;
    function GetPrefixStored: Boolean;
    procedure ReadPrefix(Reader: TReader);
    procedure SetAutoComplete(Value: Boolean);
    procedure SetLinkColor(const Value: TColor);
    procedure SetSingleClick(Value: Boolean);
    procedure WritePrefix(Writer: TWriter);
  protected
    procedure DefineProperties(AFiler: TFiler); override;
    function AddPrefixTo(AStr: string): string; virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    class function GetStyleClass: TcxCustomEditStyleClass; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    procedure ValidateDisplayValue(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit); override;
    // !!!
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete
      stored False; // deprecated
    property AutoSelect default False;
    property LinkColor: TColor read FLinkColor write SetLinkColor
      default cxHyperLinkEditDefaultLinkColor;
    property Prefix: string read FPrefix write FPrefix stored False;
    property SingleClick: Boolean read FSingleClick write SetSingleClick
      default False;
    property StartKey: TShortCut read FStartKey write FStartKey
      default VK_RETURN + scCtrl;
    property UsePrefix: TcxHyperLinkEditUsePrefix read FUsePrefix
      write FUsePrefix default upAlways; 
    property OnStartClick: TNotifyEvent read FOnStartClick write FOnStartClick;
  end;

  { TcxHyperLinkEditProperties }

  TcxHyperLinkEditProperties = class(TcxCustomHyperLinkEditProperties)
  published
    property Alignment;
    property AssignedValues;
    property AutoComplete; // deprecated
    property AutoSelect;
    property ClearKey;
    property ImeMode;
    property ImeName;
    property IncrementalSearch;
    property LinkColor;
    property LookupItems;
    property LookupItemsSorted;
    property Prefix;
    property ReadOnly;
    property StartKey;
    property SingleClick;
    property UseLeftAlignmentOnEditing;
    property UsePrefix;
    property ValidateOnEnter;
    property OnChange;
    property OnEditValueChanged;
    property OnStartClick;
    property OnValidate;
  end;

  { TcxHyperLinkStyle }

  TcxHyperLinkStyle = class(TcxEditStyle)
  protected
    function GetTextColor: TColor; override;
    function GetTextStyle: TFontStyles; override;
  end;

  { TcxCustomHyperLinkEdit }

  TcxCustomHyperLinkEdit = class(TcxCustomTextEdit)
  private
    FSaveCursor: TCursor;
    function GetActiveProperties: TcxCustomHyperLinkEditProperties;
    function GetProperties: TcxCustomHyperLinkEditProperties;
    function GetStyle: TcxHyperLinkStyle;
    procedure InternalSetCursor(ACursor: TCursor);
    procedure SetProperties(const Value: TcxCustomHyperLinkEditProperties);
    procedure SetStyle(Value: TcxHyperLinkStyle);
  protected
    function DoOnStartClick: Boolean;
    procedure DoStart; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseEnter(AControl: TControl); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure PropertiesChanged(Sender: TObject); override;
  public
    procedure ActivateByMouse(Shift: TShiftState; X, Y: Integer;
      var AEditData: TcxCustomEditData); override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure SelectAll; override;
    property ActiveProperties: TcxCustomHyperLinkEditProperties read GetActiveProperties;
    property Properties: TcxCustomHyperLinkEditProperties read GetProperties
      write SetProperties;
    property Style: TcxHyperLinkStyle read GetStyle write SetStyle;
  end;

  { TcxHyperLinkEdit }

  TcxHyperLinkEdit = class(TcxCustomHyperLinkEdit)
  private
    function GetActiveProperties: TcxHyperLinkEditProperties;
    function GetProperties: TcxHyperLinkEditProperties;
    procedure SetProperties(Value: TcxHyperLinkEditProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxHyperLinkEditProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxHyperLinkEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Text;
  {$IFDEF DELPHI12}
    property TextHint;
  {$ENDIF}
    property Visible;
    property OnClick;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnDblClick;
    property OnEditing;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property BiDiMode;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
  end;

  { TcxFilterHyperLinkEditHelper }

  TcxFilterHyperLinkEditHelper = class(TcxFilterTextEditHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
  end;

implementation

uses
  ShellAPI,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Forms, cxVariants, cxClasses, cxLibraryConsts;

{ TcxHyperLinkEditViewInfo }

procedure TcxHyperLinkEditViewInfo.GetColorSettingsByPainter(
  out ABackground, ATextColor: TColor);
begin
  inherited GetColorSettingsByPainter(ABackground, ATextColor);
  ATextColor := clDefault;
end;

function TcxHyperLinkEditViewInfo.IsHotTrack: Boolean;
begin
  Result := inherited IsHotTrack or
    TcxCustomHyperLinkEditProperties(EditProperties).SingleClick;
end;

function TcxHyperLinkEditViewInfo.IsHotTrack(P: TPoint): Boolean;
begin
  Result := IsHotTrack;
end;

procedure TcxHyperLinkEditViewInfo.PrepareCanvasFont(ACanvas: TCanvas);
begin
  inherited PrepareCanvasFont(ACanvas);
  if Edit = nil then
  begin
    ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline];
    if IsSelected then
      ACanvas.Font.Color := TextColor
    else
      ACanvas.Font.Color := TcxCustomHyperLinkEditProperties(EditProperties).LinkColor;
  end;
end;

{ TcxCustomHyperLinkEditProperties }

constructor TcxCustomHyperLinkEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  AutoSelect := False;
  FLinkColor := clBlue;
  FPrefix := cxGetResourceString(@scxSHyperLinkPrefix);
  FSingleClick := False;
  FStartKey := VK_RETURN + scCtrl;
  FUsePrefix := upAlways;
end;

function TcxCustomHyperLinkEditProperties.GetAutoComplete: Boolean;
begin
  Result := not (UsePrefix = upNever); 
end;

function TcxCustomHyperLinkEditProperties.GetPrefixStored: Boolean;
begin
  Result := FPrefix <> cxGetResourceString(@scxSHyperLinkPrefix);
end;

procedure TcxCustomHyperLinkEditProperties.ReadPrefix(Reader: TReader);
begin
  Prefix := Reader.ReadString;
end;

procedure TcxCustomHyperLinkEditProperties.SetAutoComplete(Value: Boolean);
begin
  if Value then
    UsePrefix := upAlways
  else
    UsePrefix := upNever;
end;

procedure TcxCustomHyperLinkEditProperties.SetLinkColor(
  const Value: TColor);
begin
  if FLinkColor <> Value then
  begin
    FLinkColor := Value;
    Changed;
  end;
end;

procedure TcxCustomHyperLinkEditProperties.SetSingleClick(Value: Boolean);
begin
  if Value <> FSingleClick then
  begin
    FSingleClick := Value;
    Changed;
  end;
end;

procedure TcxCustomHyperLinkEditProperties.WritePrefix(Writer: TWriter);
begin
  Writer.WriteString(Prefix);
end;

procedure TcxCustomHyperLinkEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomHyperLinkEditProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxCustomHyperLinkEditProperties(Source) do
      begin
        Self.LinkColor := LinkColor;
        Self.Prefix := Prefix;
        Self.SingleClick := SingleClick;
        Self.StartKey := StartKey;
        Self.UsePrefix := UsePrefix;
        Self.OnStartClick := OnStartClick;
      end;
    finally
      EndUpdate
    end
  end
  else
    inherited Assign(Source);
end;

class function TcxCustomHyperLinkEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxHyperLinkEdit;
end;

class function TcxCustomHyperLinkEditProperties.GetStyleClass: TcxCustomEditStyleClass;
begin
  Result := TcxHyperLinkStyle;
end;

function TcxCustomHyperLinkEditProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := inherited GetSupportedOperations;
  if SingleClick then
   Include(Result, esoAlwaysHotTrack);
end;

class function TcxCustomHyperLinkEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxHyperLinkEditViewInfo;
end;

procedure TcxCustomHyperLinkEditProperties.ValidateDisplayValue(
  var ADisplayValue: TcxEditValue; var AErrorText: TCaption; var Error: Boolean;
    AEdit: TcxCustomEdit);
begin
  if UsePrefix = upAlways then
    ADisplayValue := AddPrefixTo(VarToStr(ADisplayValue));
  inherited ValidateDisplayValue(ADisplayValue, AErrorText, Error, AEdit);
end;

procedure TcxCustomHyperLinkEditProperties.DefineProperties(AFiler: TFiler);
begin
  inherited DefineProperties(AFiler);
  AFiler.DefineProperty('Prefix', ReadPrefix, WritePrefix, GetPrefixStored);
end;

function TcxCustomHyperLinkEditProperties.AddPrefixTo(AStr: string): string;
begin
  Result := Trim(AStr);
  if (Prefix <> '') and (Result <> '') and (Pos(Prefix, Result) <> 1) then
    Result := Trim(Prefix + Result);
end;

{ TcxHyperLinkStyle }

function TcxHyperLinkStyle.GetTextColor: TColor;
begin
  if DirectAccessMode then
    Result := inherited GetTextColor
  else
  begin
    if (Container = nil) or (TcxCustomHyperLinkEdit(Container).ActiveProperties = nil) then
      Result := cxHyperLinkEditDefaultLinkColor
    else
      Result := TcxCustomHyperLinkEdit(Container).ActiveProperties.LinkColor;
  end;
end;

function TcxHyperLinkStyle.GetTextStyle: TFontStyles;
begin
  Result := inherited GetTextStyle + [fsUnderline];
end;

{ TcxCustomHyperLinkEdit }

function TcxCustomHyperLinkEdit.DoOnStartClick: Boolean;
begin
  Result := Assigned(Properties.OnStartClick) or
    Assigned(ActiveProperties.OnStartClick);
  with Properties do
    if Assigned(OnStartClick) then
      OnStartClick(Self);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnStartClick) then
        OnStartClick(Self);
end;

procedure TcxCustomHyperLinkEdit.DoStart;
var
  AText: string;
begin
  if not DoOnStartClick then
  begin
    AText := Trim(DisplayValue);
    if ActiveProperties.UsePrefix <> upNever then
      AText := ActiveProperties.AddPrefixTo(AText);
    if AText <> '' then
      ShellExecute(0, 'OPEN', PChar(AText),
        nil, nil, SW_SHOWMAXIMIZED);
  end;
end;

function TcxCustomHyperLinkEdit.GetActiveProperties: TcxCustomHyperLinkEditProperties;
begin
  Result := TcxCustomHyperLinkEditProperties(InternalGetActiveProperties);
end;

function TcxCustomHyperLinkEdit.GetProperties: TcxCustomHyperLinkEditProperties;
begin
  Result := TcxCustomHyperLinkEditProperties(FProperties);
end;

function TcxCustomHyperLinkEdit.GetStyle: TcxHyperLinkStyle;
begin
  Result := TcxHyperLinkStyle(FStyles.Style);
end;

procedure TcxCustomHyperLinkEdit.InternalSetCursor(ACursor: TCursor);
begin
  InnerTextEdit.Control.Cursor := ACursor;
  Cursor := ACursor;
  SetCursor(Screen.Cursors[ACursor]);
end;

procedure TcxCustomHyperLinkEdit.SetProperties(
  const Value: TcxCustomHyperLinkEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomHyperLinkEdit.SetStyle(Value: TcxHyperLinkStyle);
begin
  FStyles.Style := Value;
end;

procedure TcxCustomHyperLinkEdit.KeyDown(var Key: Word;
  Shift: TShiftState);
begin
  if (ShortCut(Key, Shift) <> 0) and (ActiveProperties.StartKey = ShortCut(Key, Shift)) then
  begin
    DoStart;
    Key := 0;
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TcxCustomHyperLinkEdit.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and PtInRect(ViewInfo.ClientRect, Point(X, Y)) and
    (not ActiveProperties.SingleClick and (ssDouble in Shift)) then
      DoStart;
end;

procedure TcxCustomHyperLinkEdit.MouseEnter(AControl: TControl);
begin
  inherited MouseEnter(AControl);
  if ActiveProperties.SingleClick and (Cursor = crDefault) then
  begin
    FSaveCursor := Cursor;
    InternalSetCursor(crcxHandPoint);
  end;
end;

procedure TcxCustomHyperLinkEdit.MouseLeave(AControl: TControl);
begin
  inherited MouseLeave(AControl);
  if ActiveProperties.SingleClick then
    InternalSetCursor(FSaveCursor);
end;

procedure TcxCustomHyperLinkEdit.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and PtInRect(ViewInfo.ClientRect, Point(X, Y)) and
    ActiveProperties.SingleClick and (SelLength = 0) then
      DoStart;
end;

procedure TcxCustomHyperLinkEdit.PropertiesChanged(Sender: TObject);
begin
  inherited PropertiesChanged(Sender);
  ContainerStyleChanged(Style);
end;

class function TcxCustomHyperLinkEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomHyperLinkEditProperties;
end;

procedure TcxCustomHyperLinkEdit.ActivateByMouse(Shift: TShiftState; X, Y: Integer;
  var AEditData: TcxCustomEditData);
begin
  if IsInplace and ActiveProperties.SingleClick and (Cursor = crDefault) then
  begin
    FSaveCursor := Cursor;
    InternalSetCursor(crcxHandPoint);
  end;
  inherited;
end;

procedure TcxCustomHyperLinkEdit.SelectAll;
begin
  if not (IsInplace and ActiveProperties.SingleClick) then
    inherited SelectAll;
end;

{ TcxHyperLinkEdit }

class function TcxHyperLinkEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxHyperLinkEditProperties;
end;

function TcxHyperLinkEdit.GetActiveProperties: TcxHyperLinkEditProperties;
begin
  Result := TcxHyperLinkEditProperties(InternalGetActiveProperties);
end;

function TcxHyperLinkEdit.GetProperties: TcxHyperLinkEditProperties;
begin
  Result := TcxHyperLinkEditProperties(FProperties);
end;

procedure TcxHyperLinkEdit.SetProperties(Value: TcxHyperLinkEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterHyperLinkEditHelper }

class function TcxFilterHyperLinkEditHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxHyperLinkEdit;
end;

initialization
  GetRegisteredEditProperties.Register(TcxHyperLinkEditProperties, scxSEditRepositoryHyperLinkItem);
  FilterEditsController.Register(TcxHyperLinkEditProperties, TcxFilterHyperLinkEditHelper);

finalization
  FilterEditsController.Unregister(TcxHyperLinkEditProperties, TcxFilterHyperLinkEditHelper);
  
end.
