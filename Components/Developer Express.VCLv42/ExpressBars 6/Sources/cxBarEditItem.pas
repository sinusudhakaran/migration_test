{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars components                                      }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
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

unit cxBarEditItem;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Windows, Classes, Controls, Graphics, Messages, cxContainer, cxControls,
  cxDropDownEdit, cxEdit, cxEditConsts, cxGraphics, cxLookAndFeels, dxBar, cxGeometry;

type
  { TcxItemsEditorEx }

  TcxItemsEditorEx = class(TdxItemsEditorEx)
  protected
    class procedure InitSubItem(AItemLinks: TdxBarItemLinks); override;
    class function GetAddedItemClass(const AAddedItemName: string): TdxBarItemClass; override;
    class function GetPopupItemCaption: string; override;
    class procedure InitializeAddedItem(AItemLink: TdxBarItemLink; AAddedItemName: string); override;
  end;

  { TcxCustomBarEditItem }

  TcxCustomBarEditItem = class(TdxCustomBarEdit, IcxEditRepositoryItemListener)
  private
    FEditData: TcxCustomEditData;
    FEditValue: TcxEditValue;
    FHeight: Integer;
    FPrevIsBlobEditValue: Boolean;
    FPrevOnEditValueChanged: TNotifyEvent;
    FProperties: TcxCustomEditProperties;
    FPropertiesEvents: TNotifyEvent;
    FPropertiesValue: TcxCustomEditProperties;
    FRepositoryItem: TcxEditRepositoryItem;
    FRepositoryItemValue: TcxEditRepositoryItem;
    FBarStyleDropDownButton: Boolean;

    // IcxEditRepositoryItemListener
    procedure IcxEditRepositoryItemListener.ItemRemoved = RepositoryItemItemRemoved;
    procedure IcxEditRepositoryItemListener.PropertiesChanged = RepositoryItemPropertiesChanged;
    procedure RepositoryItemItemRemoved(Sender: TcxEditRepositoryItem);
    procedure RepositoryItemPropertiesChanged(Sender: TcxEditRepositoryItem);

    procedure CustomizingDoDrawEditButtonBackground(Sender: TcxCustomEditViewInfo;
      ACanvas: TcxCanvas; const ARect: TRect; AButtonVisibleIndex: Integer;
      var AHandled: Boolean);
    procedure CustomizingDoGetEditDefaultButtonWidth(Sender: TcxCustomEditViewData;
      AIndex: Integer; var ADefaultWidth: Integer);

    procedure CheckIsBlobEditValue;
    procedure CreateProperties(APropertiesClass: TcxCustomEditPropertiesClass);
    procedure DestroyProperties;
    function GetCurEditValue: TcxEditValue;
    function GetPropertiesClass: TcxCustomEditPropertiesClass;
    function GetPropertiesClassName: string;
    function GetPropertiesValue: TcxCustomEditProperties;
    function GetRepositoryItemValue: TcxEditRepositoryItem;
    function IsBarCompatibleEdit(AEditProperties: TcxCustomEditProperties = nil): Boolean;
    function IsBlobEditValue: Boolean;
    function IsEditValueStored(AFiler: TFiler): Boolean;
    procedure PropertiesChangedHandler(Sender: TObject);
    procedure PropertiesValueChanged;
    procedure ReadEditValue(AReader: TReader); overload;
  {$HINTS OFF}
    procedure ReadEditValue(AStream: TStream); overload;
  {$HINTS ON}
    procedure SetEditValue(const Value: TcxEditValue);
    procedure SetHeight(Value: Integer);
    procedure SetProperties(Value: TcxCustomEditProperties);
    procedure SetPropertiesClass(Value: TcxCustomEditPropertiesClass);
    procedure SetPropertiesClassName(const Value: string);
    procedure SetRepositoryItem(Value: TcxEditRepositoryItem);
    procedure SetRepositoryItemValue(Value: TcxEditRepositoryItem);
    procedure SetBarStyleDropDownButton(Value: Boolean);
    procedure UpdateRepositoryItemValue;
    function UseBarPaintingStyle: Boolean;
    procedure WriteEditValue(AWriter: TWriter); overload;
  {$HINTS OFF}
    procedure WriteEditValue(AStream: TStream); overload;
  {$HINTS ON}
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure DrawCustomizingImage(ACanvas: TCanvas; const ARect: TRect;
      AState: TOwnerDrawState); override;
    procedure DrawCustomizingImageContent(ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean); override;
    function GetControlClass(AIsVertical: Boolean): TdxBarItemControlClass; override;
    function HasAccel(AItemLink: TdxBarItemLink): Boolean; override;
    function CanEdit: Boolean;
    function CaptionIsEditValue: Boolean;
    procedure DoEditValueChanged(Sender: TObject);
    procedure PropertiesChanged; virtual;
    procedure UpdatePropertiesValue;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure DoClick; override;
    function GetProperties: TcxCustomEditProperties;
    property CurEditValue: TcxEditValue read GetCurEditValue;
    property EditValue: TcxEditValue read FEditValue write SetEditValue
      stored False;
    property Height: Integer read FHeight write SetHeight default 0;
    property Properties: TcxCustomEditProperties read FProperties
      write SetProperties;
    property PropertiesClass: TcxCustomEditPropertiesClass
      read GetPropertiesClass write SetPropertiesClass;
    property RepositoryItem: TcxEditRepositoryItem read FRepositoryItem
      write SetRepositoryItem;
  published
    property PropertiesClassName: string read GetPropertiesClassName
      write SetPropertiesClassName;
    property PropertiesEvents: TNotifyEvent read FPropertiesEvents
      write FPropertiesEvents;
    property BarStyleDropDownButton: Boolean read FBarStyleDropDownButton write SetBarStyleDropDownButton default True;
  end;

  { TcxBarEditItem }

  TcxBarEditItem = class(TcxCustomBarEditItem)
  published
    property CanSelect;
    property EditValue;
    property Height;
    property Properties;
    property RepositoryItem;
    property StyleEdit;
  end;

  TcxBarEditItemControlEditEvents = record
    OnAfterKeyDown: TKeyEvent;
    OnChange: TNotifyEvent;
    OnClosePopup: TcxEditClosePopupEvent;
    OnFocusChanged: TNotifyEvent;
    OnInitPopup: TNotifyEvent;
    OnKeyDown: TKeyEvent;
    OnKeyPress: TKeyPressEvent;
    OnKeyUp: TKeyEvent;
    OnMouseMove: TMouseMoveEvent;
    OnPostEditValue: TNotifyEvent;
    OnValidate: TcxEditValidateEvent;
  end;

  { TcxBarEditItemControl }

  TcxBarEditItemControl = class(TdxBarCustomEditControl)
  private
    FEdit: TcxCustomEdit;
    FEditViewInfo: TcxCustomEditViewInfo;
    FSavedEditEvents: TcxBarEditItemControlEditEvents;
    FEditValueBeforeHiding: Variant;
    FIsEditValueAssigned: Boolean;

    procedure ClearEditEvents;
    procedure InternalShowEdit;
    procedure SaveEditEvents;

    procedure DoAfterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoCustomDrawPopupBorder(AViewInfo: TcxContainerViewInfo; ACanvas: TcxCanvas; const R: TRect; var AHandled: Boolean;
      out ABorderWidth: Integer);
    procedure DoDrawEditBackground(Sender: TcxCustomEditViewInfo;
      ACanvas: TcxCanvas; var AHandled: Boolean);
    procedure DoDrawEditButton(Sender: TcxCustomEditViewInfo;
      ACanvas: TcxCanvas; AButtonVisibleIndex: Integer; var AHandled: Boolean);
    procedure DoDrawEditButtonBackground(Sender: TcxCustomEditViewInfo;
      ACanvas: TcxCanvas; const ARect: TRect; AButtonVisibleIndex: Integer;
      var AHandled: Boolean);
    procedure DoDrawEditButtonBorder(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
      out ABackgroundRect, AContentRect: TRect; var AHandled: Boolean);
    procedure DoEditPaint(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas);
    procedure DoEditClosePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason);
    procedure DoEditPropertiesChange(Sender: TObject);
    procedure DoGetEditButtonState(Sender: TcxCustomEditViewInfo;
      AButtonVisibleIndex: Integer; var AState: TcxEditButtonState);
    procedure DoGetEditDefaultButtonWidth(Sender: TcxCustomEditViewData;
      AIndex: Integer; var ADefaultWidth: Integer);
    procedure DoFocusChanged(Sender: TObject);
    procedure DoInitPopup(Sender: TObject);
    procedure DoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoKeyPress(Sender: TObject; var Key: Char);
    procedure DoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoPostEditValue(Sender: TObject);
    procedure DoValidate(Sender: TObject; var DisplayValue: TcxEditValue;
      var ErrorText: TCaption; var Error: Boolean);
    function GetEditButtonState(AButtonViewInfo: TcxEditButtonViewInfo): Integer;

    procedure AssignViewInfoEvents(AViewInfo: TcxCustomEditViewInfo);
    procedure ClearViewInfoEvents(AViewInfo: TcxCustomEditViewInfo);
    procedure DrawEditBackground(ACanvas: TcxCanvas; ARect: TRect; AColor: TColor);
    function GetBoundsRect: TRect;
    function GetCurEditValue: TcxEditValue;
    function GetDefaultEditButtonWidth(AIndex: Integer): Integer;
    function GetDropDownEdit: TcxCustomDropDownEdit;
    function GetEditSize: TSize;
    function GetEditStyle: TcxEditStyle;
    function GetEditViewInfo: TcxCustomEditViewInfo;
    function GetItem: TcxCustomBarEditItem;
    function GetProperties: TcxCustomEditProperties;
    procedure InitEditContentParams(var AParams: TcxEditContentParams);
    function IsDropDownEdit: Boolean;
    function IsPopupSideward: Boolean;
    function NeedEditShowCaption: Boolean;
    procedure PrepareEditForClose;

    procedure LockChangeEvents(ALock: Boolean);

    property DropDownEdit: TcxCustomDropDownEdit read GetDropDownEdit;
  protected
    procedure ActivateEdit(AByMouse: Boolean; AKey: Char = #0); override;
    procedure CalcDrawParams(AFull: Boolean = True); override;
    procedure CalcParts; override;
    function CanHide: Boolean; override;
    function CanSelect: Boolean; override;
    procedure CheckHotTrack(APoint: TPoint); override;
    procedure ControlInactivate(Immediately: Boolean); override;
    procedure DoPaint(ARect: TRect; PaintType: TdxBarPaintType); override;
    procedure DoMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DrawTextField; override;
    function GetControl: TControl; override;
    function GetHandle: HWND; override;
    function GetDefaultHeight: Integer; override;
    function GetMinEditorWidth: Integer; override;
    function GetPartCount: Integer; override;
    function GetShowCaption: Boolean; override;
    function GetCaptionAreaWidth: Integer; override;
    function GetControlAreaWidth: Integer; override;
    function GetPossibleViewLevels: TdxBarItemViewLevels; override;
    procedure Hide(AStoreDisplayValue: Boolean); override;
    procedure InitEdit; override;
    function IsChildWindow(AWnd: HWND): Boolean; override;
    function IsEditTransparent: Boolean; override;
    function IsTransparentOnGlass: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ParentVisibleChange(AIsShowing: Boolean); override;
    procedure RestoreDisplayValue; override;
    procedure Show; override;
    procedure StoreDisplayValue; override;
    function WantsKey(Key: Word): Boolean; override;
    procedure CalculateEditViewInfo(const ABounds: TRect; P: TPoint;
      AIsMouseEvent: Boolean; AEditViewInfo: TcxCustomEditViewInfo = nil; AFull: Boolean = True);
    function CreateEditViewData(AFull: Boolean = True): TcxCustomEditViewData;
    function CreateEditViewInfo: TcxCustomEditViewInfo;
    property EditStyle: TcxEditStyle read GetEditStyle;
    property EditViewInfo: TcxCustomEditViewInfo read GetEditViewInfo;
    property Item: TcxCustomBarEditItem read GetItem;
    property Properties: TcxCustomEditProperties read GetProperties;
  public
    destructor Destroy; override;
    function IsDroppedDown: Boolean; override;
    property CurEditValue: TcxEditValue read GetCurEditValue;
    property Edit: TcxCustomEdit read FEdit;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ELSE}
  Consts, TypInfo,
{$ENDIF}
  Forms, SysUtils, cxBarEditItemValueEditor, cxClasses, cxEditPaintUtils,
  cxEditRepositoryItems, cxEditUtils, cxLookAndFeelPainters, cxTextEdit,
  cxVariants, dxBarCustomCustomizationForm, dxOffice11, dxBarStrs, dxBarSkinConsts, dxCore;//, cxDWMApi;

const
  MinContentWidth = 9;

type
  TControlAccess = class(TControl);
{$IFNDEF DELPHI6}
  TReaderAccess = class(TReader);
  TWriterAccess = class(TWriter);
{$ENDIF}
  TdxBarManagerAccess = class(TdxBarManager);
  TdxBarSubMenuControlAccess = class(TdxBarSubMenuControl);

  { TFakeWinControl }

  TFakeWinControl = class(TWinControl)
  protected
    procedure CreateWnd; override;
    procedure DestroyWindowHandle; override;
    procedure DestroyWnd; override;
  public
    destructor Destroy; override;
  end;

  { TEditorParentForm }

  TEditorParentForm = class(TCustomForm)
  public
    destructor Destroy; override;
    procedure GetTabOrderList(List: TList); override;
    function SetFocusedControl(Control: TWinControl): Boolean; override;
  end;

  { TcxBarEditItemVerticalButtonControl }

  TcxBarEditItemVerticalButtonControl = class(TdxBarButtonControl)
  private
    function CanEdit: Boolean;
  protected
    function CanClicked: Boolean; override;
    function CanSelect: Boolean; override;
    function GetPaintStyle: TdxBarPaintStyle; override;
  end;

var
  FDefaultRepositoryItem: TcxEditRepositoryItem;
  FEditList: TcxInplaceEditList;
  FEditorParentForm: TEditorParentForm;
  FEditStyle: TcxEditStyle;
  FFakeWinControl: TFakeWinControl;

function DefaultRepositoryItem: TcxEditRepositoryItem;

  procedure CreateDefaultRepositoryItem;
  begin
    FDefaultRepositoryItem := TcxEditRepositoryTextItem.Create(nil);
  end;

begin
  if FDefaultRepositoryItem = nil then
    CreateDefaultRepositoryItem;
  Result := FDefaultRepositoryItem;
end;

function EditList: TcxInplaceEditList;
begin
  if FEditList = nil then
    FEditList := TcxInplaceEditList.Create(nil);
  Result := FEditList;
end;

function EditorParentForm: TEditorParentForm;
begin
  if FEditorParentForm = nil then
  begin
    FEditorParentForm := TEditorParentForm.CreateNew(nil);
    FEditorParentForm.Position := poDesigned;
    FEditorParentForm.Name := 'EditorParentForm';
    FEditorParentForm.BorderStyle := bsNone;
  end;
  Result := FEditorParentForm;
end;

function FakeWinControl: TFakeWinControl;
begin
  if FFakeWinControl = nil then
  begin
    FFakeWinControl := TFakeWinControl.Create(nil); //#!!!
    FFakeWinControl.Name := 'FakeWinControl';
  end;
  Result := FFakeWinControl;
end;

function InternalGetEditStyle(AEditProperties: TcxCustomEditProperties; ABarManager: TdxBarManager;
  APainter: TdxBarPainter; AFont: TFont; AColor, ATextColor: TColor; ADrawSelected: Boolean): TcxEditStyle;

  procedure InitEditStyle;

    procedure SetStyleColors;
    begin
      FEditStyle.Font := AFont;
      FEditStyle.Color := AColor;
      FEditStyle.TextColor := ATextColor;
    end;

    procedure SetLookAndFeel;
    begin
      if APainter <> nil then
        APainter.EditGetRealLookAndFeel(ABarManager, FEditStyle.LookAndFeel)
      else
        TdxBarManagerAccess(ABarManager).GetRealLookAndFeel(FEditStyle.LookAndFeel);
      if (FEditStyle.LookAndFeel.ActiveStyle = lfsFlat) and
        ((AEditProperties.Buttons.VisibleCount <> 0) and not ADrawSelected) then
        FEditStyle.LookAndFeel.SetStyle(lfsUltraFlat);
    end;

  begin
    SetStyleColors;
    SetLookAndFeel;
    FEditStyle.GradientButtons := True;
    FEditStyle.ButtonTransparency := ebtNone;
  end;

begin
  if FEditStyle = nil then
    FEditStyle := TcxEditStyle.Create(nil, True);
  InitEditStyle;
  Result := FEditStyle;
end;

{$IFNDEF DELPHI6}
procedure WriteVariantProperty(AWriter: TWriter; AInstance: TObject;
  const APropName: string);

  procedure WriteValue(AValue: TValueType);
  begin
    AWriter.Write(AValue, SizeOf(AValue));
  end;

  function IsAncestorValid: Boolean;
  begin
    Result := (AWriter.Ancestor <> nil) and ((AInstance.ClassType = AWriter.Ancestor.ClassType) or
      (AInstance = AWriter.Root));
  end;

  function IsDefaultValue(const AValue: Variant): Boolean;
  begin
    if IsAncestorValid then
      Result := AValue = GetVariantProp(AWriter.Ancestor, GetPropInfo(AInstance, APropName))
    else
      Result := VarIsEmpty(AValue);
  end;

var
  AValue: Variant;
begin
  AValue := GetVariantProp(AInstance, GetPropInfo(AInstance, APropName));
  if IsDefaultValue(AValue) then
    Exit;
  if VarIsArray(AValue) then
    raise EWriteError.CreateRes(@SWriteError);
  case VarType(AValue) and varTypeMask of
    varEmpty:
      WriteValue(vaNil);
    varNull:
      WriteValue(vaNull);
    varOleStr:
      AWriter.WriteWideString(AValue);
    varString:
      AWriter.WriteString(AValue);
    varByte, varSmallInt, varInteger:
      AWriter.WriteInteger(AValue);
    varSingle:
      AWriter.WriteSingle(AValue);
    varDouble:
      AWriter.WriteFloat(AValue);
    varCurrency:
      AWriter.WriteCurrency(AValue);
    varDate:
      AWriter.WriteDate(AValue);
    varBoolean:
      if AValue then
        WriteValue(vaTrue)
      else
        WriteValue(vaFalse);
  else
    try
      AWriter.WriteString(AValue);
    except
      raise EWriteError.CreateRes(@SWriteError);
    end;
  end;
end;
{$ENDIF}

{ TFakeWinControl }

destructor TFakeWinControl.Destroy;
begin
  inherited;
  FFakeWinControl := nil; //#!!! because DoneApplication
end;

procedure TFakeWinControl.CreateWnd;
begin
// do nothing
end;

procedure TFakeWinControl.DestroyWindowHandle;
begin
  WindowHandle := 0; //#!!! because DoneApplication
end;

procedure TFakeWinControl.DestroyWnd;
begin
  WindowHandle := 0; // because WindowHandle := Edit.Handle
end;

{ TEditorParentForm }

destructor TEditorParentForm.Destroy;
begin
{$IFDEF DELPHI9}
  PopupChildren.Clear; // for test framework
{$ENDIF}
  inherited;
end;

procedure TEditorParentForm.GetTabOrderList(List: TList);
begin
//do nothing
end;

function TEditorParentForm.SetFocusedControl(Control: TWinControl): Boolean;
var
  ALink: TcxObjectLink;
  APopupWindow: TcxCustomPopupWindow;
begin
  ALink := nil;
  APopupWindow := GetParentPopupWindow(Self, True);
  if APopupWindow <> nil then
  begin
    APopupWindow.LockDeactivate(True);
    ALink := cxAddObjectLink(APopupWindow);
  end;
  try
    Result := inherited SetFocusedControl(Control);
  finally
    if APopupWindow <> nil then
    begin
      if ALink.Ref <> nil then
        APopupWindow.LockDeactivate(False);
      cxRemoveObjectLink(ALink);
    end;
  end;
end;

{ TcxBarEditItemVerticalButtonControl }

function TcxBarEditItemVerticalButtonControl.CanClicked: Boolean;
begin
  Result := CanEdit and inherited CanClicked;
end;

function TcxBarEditItemVerticalButtonControl.CanSelect: Boolean;
begin
  Result := CanEdit and inherited CanSelect;
end;

function TcxBarEditItemVerticalButtonControl.GetPaintStyle: TdxBarPaintStyle;
begin
  if CanEdit then
    Result := inherited GetPaintStyle
  else
    if TcxCustomBarEditItem(Item).Glyph.Empty then
      Result := psCaption
    else
      Result := psCaptionGlyph;
end;

function TcxBarEditItemVerticalButtonControl.CanEdit: Boolean;
begin
  Result := TcxCustomBarEditItem(Item).CanEdit;
end;

{ TcxItemsEditorEx }

class procedure TcxItemsEditorEx.InitSubItem(AItemLinks: TdxBarItemLinks);
var
  I: Integer;
begin
  for I := 0 to GetRegisteredEditProperties.Count - 1 do
    BarDesignController.AddInternalItem(AItemLinks, TdxBarButton, GetRegisteredEditProperties.Descriptions[I], OnButtonClick);
end;

class function TcxItemsEditorEx.GetAddedItemClass(const AAddedItemName: string): TdxBarItemClass;
begin
  Result := TcxBarEditItem;
end;

class function TcxItemsEditorEx.GetPopupItemCaption: string;
begin
  Result := dxSBAR_CP_ADDCXITEM;
end;

class procedure TcxItemsEditorEx.InitializeAddedItem(AItemLink: TdxBarItemLink; AAddedItemName: string);
var
  APropertiesClass: TcxCustomEditPropertiesClass;
begin
  APropertiesClass := TcxCustomEditPropertiesClass(GetRegisteredEditProperties.FindByDescription(AAddedItemName));
  TcxBarEditItem(AItemLink.Item).PropertiesClass := APropertiesClass;
end;

{ TcxCustomBarEditItem }

constructor TcxCustomBarEditItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditValue := Null;
  UpdatePropertiesValue;
  FPrevIsBlobEditValue := IsBlobEditValue;
  FBarStyleDropDownButton := True;
end;

destructor TcxCustomBarEditItem.Destroy;
begin
  RepositoryItem := nil;
  PropertiesClass := nil;
  SetRepositoryItemValue(nil);
  FreeAndNil(FEditData);
  inherited Destroy;
end;

procedure TcxCustomBarEditItem.Assign(Source: TPersistent);
begin
  inherited;
  if Self is TcxCustomBarEditItem then
    Properties := TcxCustomBarEditItem(Source).Properties;
end;

procedure TcxCustomBarEditItem.DoClick;
begin
  inherited DoClick;
  if not (Assigned(OnClick) or GetProperties.ReadOnly) then
    ShowValueEditor(ClickItemLink);
end;

function TcxCustomBarEditItem.GetProperties: TcxCustomEditProperties;
begin
  Result := FPropertiesValue;
end;

procedure TcxCustomBarEditItem.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  if esfBlobEditValue in GetProperties.GetSpecialFeatures then
    Filer.DefineBinaryProperty('InternalEditValue', ReadEditValue,
      WriteEditValue, IsEditValueStored(Filer))
  else
    Filer.DefineProperty('InternalEditValue', ReadEditValue, WriteEditValue,
      IsEditValueStored(Filer));
end;

procedure TcxCustomBarEditItem.DrawCustomizingImage(ACanvas: TCanvas;
  const ARect: TRect; AState: TOwnerDrawState);
begin
  if CaptionIsEditValue then
    dxBarCustomizingForm.PainterClass.DrawButtonOrSubItem(ACanvas, ARect, Self,
      GetTextOf(Caption), odSelected in AState)
  else
    dxBarCustomizingForm.PainterClass.DrawEdit(ACanvas, ARect, Self,
      odSelected in AState, UseBarPaintingStyle);
end;

procedure TcxCustomBarEditItem.DrawCustomizingImageContent(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
var
  AEditProperties: TcxCustomEditProperties;
  AEditStyle: TcxEditStyle;
  AEditViewData: TcxCustomEditViewData;
  AEditViewInfo: TcxCustomEditViewInfo;
  ATempCanvas: TcxCanvas;
begin
  AEditProperties := nil;
  AEditViewData := nil;
  AEditViewInfo := nil;
  ATempCanvas := nil;
  try
    AEditProperties := GetProperties.CreatePreviewProperties;
    AEditStyle := InternalGetEditStyle(AEditProperties, BarManager, nil,
      ACanvas.Font, clWindow, ACanvas.Font.Color, ASelected);
    if UseBarPaintingStyle then
      AEditStyle.ButtonTransparency := ebtHideInactive;
    AEditViewData := AEditProperties.CreateViewData(AEditStyle, True, True);
    AEditViewData.OnGetDefaultButtonWidth := CustomizingDoGetEditDefaultButtonWidth;
    AEditViewData.EditContentParams.ExternalBorderBounds := ARect;
    AEditViewInfo := TcxCustomEditViewInfo(AEditProperties.GetViewInfoClass.Create);
    AEditViewInfo.Data := Integer(ASelected);
    AEditViewInfo.OnDrawButtonBackground := CustomizingDoDrawEditButtonBackground;
    ATempCanvas := TcxCanvas.Create(ACanvas);
    AEditViewData.EditValueToDrawValue(ATempCanvas, Null, AEditViewInfo);
    AEditViewData.Calculate(ATempCanvas, ARect, Point(-1, -1), cxmbNone, [], AEditViewInfo, False);
    AEditViewInfo.Paint(ATempCanvas);
  finally
    FreeAndNil(AEditProperties);
    FreeAndNil(AEditViewData);
    FreeAndNil(AEditViewInfo);
    FreeAndNil(ATempCanvas);
  end;
end;

function TcxCustomBarEditItem.GetControlClass(AIsVertical: Boolean): TdxBarItemControlClass;
begin
  if AIsVertical then
    Result := TcxBarEditItemVerticalButtonControl
  else
    Result := TcxBarEditItemControl;
end;

function TcxCustomBarEditItem.HasAccel(AItemLink: TdxBarItemLink): Boolean;
begin
  Result := inherited HasAccel(AItemLink) and CanEdit;
end;

function TcxCustomBarEditItem.CanEdit: Boolean;
begin
  Result := esoEditing in GetProperties.GetSupportedOperations;
end;

function TcxCustomBarEditItem.CaptionIsEditValue: Boolean;
begin
  Result := not CanEdit and
    (esoShowingCaption in GetProperties.GetSupportedOperations);
end;

procedure TcxCustomBarEditItem.DoEditValueChanged(Sender: TObject);
begin
  EditValue := TcxCustomEdit(Sender).EditValue;
  if Assigned(FPrevOnEditValueChanged) then
    FPrevOnEditValueChanged(Sender);
end;

procedure TcxCustomBarEditItem.PropertiesChanged;
begin
  if FEditData <> nil then
    FEditData.Clear;
  CheckIsBlobEditValue;
  UpdateEx;
end;

procedure TcxCustomBarEditItem.UpdatePropertiesValue;
begin
  FPropertiesValue := GetPropertiesValue;
end;

procedure TcxCustomBarEditItem.RepositoryItemItemRemoved(
  Sender: TcxEditRepositoryItem);
begin
  RepositoryItem := nil;
end;

procedure TcxCustomBarEditItem.RepositoryItemPropertiesChanged(
  Sender: TcxEditRepositoryItem);
begin
  PropertiesChanged;
end;

procedure TcxCustomBarEditItem.CustomizingDoDrawEditButtonBackground(
  Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; const ARect: TRect;
  AButtonVisibleIndex: Integer; var AHandled: Boolean);
begin
  AHandled := not Sender.NativeStyle;
  if (ACanvas <> nil) and AHandled then
    FillRectByColor(ACanvas.Handle, ARect,
      dxBarCustomizingForm.PainterClass.GetButtonColor(Self, False));
end;

procedure TcxCustomBarEditItem.CustomizingDoGetEditDefaultButtonWidth(
  Sender: TcxCustomEditViewData; AIndex: Integer; var ADefaultWidth: Integer);
begin
  if IsBarCompatibleEdit(Sender.Properties) then
    ADefaultWidth := dxBarCustomizingForm.PainterClass.GetComboBoxButtonWidth;
end;

procedure TcxCustomBarEditItem.CheckIsBlobEditValue;
begin
  if FPrevIsBlobEditValue <> IsBlobEditValue then
  begin
    FPrevIsBlobEditValue := IsBlobEditValue;
    EditValue := Null;
  end;
end;

procedure TcxCustomBarEditItem.CreateProperties(
  APropertiesClass: TcxCustomEditPropertiesClass);
begin
  if APropertiesClass <> nil then
    FProperties := APropertiesClass.Create(Self);
end;

procedure TcxCustomBarEditItem.DestroyProperties;
begin
  FreeAndNil(FProperties);
end;

function TcxCustomBarEditItem.GetCurEditValue: TcxEditValue;
begin
  if (CurItemLink = nil) or (CurItemLink.Control = nil) then
    Result := EditValue
  else
    Result := TcxBarEditItemControl(CurItemLink.Control).CurEditValue;
end;

function TcxCustomBarEditItem.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  if FProperties = nil then
    Result := nil
  else
    Result := TcxCustomEditPropertiesClass(FProperties.ClassType);
end;

function TcxCustomBarEditItem.GetPropertiesClassName: string;
begin
  if FProperties = nil then
    Result := ''
  else
    Result := FProperties.ClassName;
end;

function TcxCustomBarEditItem.GetPropertiesValue: TcxCustomEditProperties;
begin
  UpdateRepositoryItemValue;
  if FRepositoryItemValue <> nil then
  begin
    Result := FRepositoryItemValue.Properties;
    if FProperties <> nil then
      FProperties.OnPropertiesChanged := nil;
  end
  else
  begin
    Result := FProperties;
    FProperties.OnPropertiesChanged := PropertiesChangedHandler;
  end;
end;

function TcxCustomBarEditItem.GetRepositoryItemValue: TcxEditRepositoryItem;
begin
  if FRepositoryItem <> nil then
    Result := FRepositoryItem
  else
    if FProperties = nil then
      Result := DefaultRepositoryItem
    else
      Result := nil;
end;

function TcxCustomBarEditItem.IsBarCompatibleEdit(
  AEditProperties: TcxCustomEditProperties = nil): Boolean;
var
  AButton: TcxEditButton;
  AProperties: TcxCustomEditProperties;
  I: Integer;
begin
  Result := False;
  AProperties := AEditProperties;
  if AProperties = nil then
    AProperties := GetProperties;
  if AProperties.Buttons.VisibleCount = 1 then
    for I := 0 to AProperties.Buttons.Count - 1 do
    begin
      AButton := AProperties.Buttons[I];
      if AButton.Visible then
      begin
        Result := (AButton.Kind = bkDown) and not AButton.LeftAlignment;
        Break;
      end;
    end;
end;

function TcxCustomBarEditItem.IsBlobEditValue: Boolean;
begin
  Result := esfBlobEditValue in GetProperties.GetSpecialFeatures;
end;

function TcxCustomBarEditItem.IsEditValueStored(AFiler: TFiler): Boolean;

  function Equals(const V1, V2: TcxEditValue): Boolean;
  begin
    Result := (VarType(V1) = VarType(V2)) and VarEqualsExact(V1, V2);
  end;

begin
  if AFiler.Ancestor <> nil then
    Result := not (AFiler.Ancestor is TcxCustomBarEditItem) or
      not Equals(EditValue, TcxCustomBarEditItem(AFiler.Ancestor).EditValue)
  else
    Result := not VarIsNull(EditValue);
end;

procedure TcxCustomBarEditItem.PropertiesChangedHandler(Sender: TObject);
begin
  PropertiesChanged;
end;

procedure TcxCustomBarEditItem.PropertiesValueChanged;
begin
  UpdatePropertiesValue;
  if not (csDestroying in ComponentState) then
  begin
    CheckIsBlobEditValue;
    UpdateEx;
    Changed;
    dxBarDesignerModified(BarManager);
  end;
end;

procedure TcxCustomBarEditItem.ReadEditValue(AReader: TReader);
begin
{$IFDEF DELPHI6}
  EditValue := AReader.ReadVariant;
{$ELSE}
  TReaderAccess(AReader).ReadPropValue(Self, GetPropInfo(Self, 'EditValue'));
{$ENDIF}
end;

procedure TcxCustomBarEditItem.ReadEditValue(AStream: TStream);
var
  ASize: DWORD;
  S: AnsiString;
begin
  AStream.ReadBuffer(ASize, SizeOf(ASize));
  SetLength(S, ASize);
  AStream.ReadBuffer(S[1], ASize);
  EditValue := S;
end;

procedure TcxCustomBarEditItem.SetEditValue(const Value: TcxEditValue);
begin
  if not (GetProperties.CanCompareEditValue and (VarType(Value) = VarType(FEditValue)) and
    VarEqualsExact(Value, FEditValue)) then
  begin
    FEditValue := Value;
    Change;
    Update;
  end;
end;

procedure TcxCustomBarEditItem.SetHeight(Value: Integer);
begin
  if Value <> FHeight then
  begin
    FHeight := Value;
    if not IsLoading then // TODO
      UpdateEx;           // TODO
  end;
end;

procedure TcxCustomBarEditItem.SetProperties(Value: TcxCustomEditProperties);
begin
  if Value <> nil then
    FProperties.Assign(Value);
end;

procedure TcxCustomBarEditItem.SetPropertiesClass(
  Value: TcxCustomEditPropertiesClass);
begin
  if Value <> PropertiesClass then
  begin
    if FProperties <> nil then
      Properties.LockUpdate(True);
    DestroyProperties;
    CreateProperties(Value);
    if FProperties <> nil then
      Properties.LockUpdate(False);
    PropertiesValueChanged;
  end;
end;

procedure TcxCustomBarEditItem.SetPropertiesClassName(const Value: string);
begin
  PropertiesClass := TcxCustomEditPropertiesClass(
    GetRegisteredEditProperties.FindByClassName(Value));
end;

procedure TcxCustomBarEditItem.SetRepositoryItem(Value: TcxEditRepositoryItem);
begin
  if FRepositoryItem <> Value then
  begin
    FRepositoryItem := Value;
    PropertiesValueChanged;
  end;
end;

procedure TcxCustomBarEditItem.SetRepositoryItemValue(Value: TcxEditRepositoryItem);
begin
  if Value <> FRepositoryItemValue then
  begin
    if FRepositoryItemValue <> nil then
      FRepositoryItemValue.RemoveListener(Self);
    FRepositoryItemValue := Value;
    if FRepositoryItemValue <> nil then
      FRepositoryItemValue.AddListener(Self);
  end;
end;

procedure TcxCustomBarEditItem.SetBarStyleDropDownButton(Value: Boolean);
begin
  if FBarStyleDropDownButton <> Value then
  begin
    FBarStyleDropDownButton := Value;
    UpdateEx;
  end;
end;

procedure TcxCustomBarEditItem.UpdateRepositoryItemValue;
begin
  SetRepositoryItemValue(GetRepositoryItemValue);
end;

function TcxCustomBarEditItem.UseBarPaintingStyle: Boolean;
begin
  Result := BarStyleDropDownButton and IsBarCompatibleEdit;
end;

procedure TcxCustomBarEditItem.WriteEditValue(AWriter: TWriter);
begin
{$IFDEF DELPHI6}
  AWriter.WriteVariant(EditValue);
{$ELSE}
  WriteVariantProperty(AWriter, Self, 'EditValue');
{$ENDIF}
end;

procedure TcxCustomBarEditItem.WriteEditValue(AStream: TStream);
var
  ASize: DWORD;
  S: AnsiString;
begin
  S := dxVariantToAnsiString(EditValue);
  ASize := Length(S);
  AStream.WriteBuffer(ASize, SizeOf(ASize));
  AStream.WriteBuffer(S[1], ASize);
end;

{ TcxBarEditItemControl }

destructor TcxBarEditItemControl.Destroy;
begin
  Focused := False;
  FreeAndNil(FEditViewInfo);
  inherited Destroy;
end;

function TcxBarEditItemControl.IsDroppedDown: Boolean;
begin
  Result := (Edit <> nil) and Edit.HasPopupWindow;
end;

procedure TcxBarEditItemControl.ActivateEdit(AByMouse: Boolean; AKey: Char = #0);
var
  P: TPoint;
  AActiveWinControl: TWinControl;
begin
  AActiveWinControl := FindControl(GetActiveWindow);
  if AActiveWinControl is TCustomForm then
  begin
    FakeWinControl.Parent := AActiveWinControl;
    FakeWinControl.WindowHandle := Edit.Handle;
    TCustomForm(AActiveWinControl).SetFocusedControl(FakeWinControl);
  end;
  Edit.OnGlass := Parent.IsOnGlass;
  if not AByMouse then
    if AKey = #0 then
      Edit.Activate(Item.FEditData)
    else
      Edit.ActivateByKey(AKey, Item.FEditData)
  else
  begin
    P := Edit.Parent.ScreenToClient(GetMouseCursorPos);
    Edit.ActivateByMouse(InternalGetShiftState, P.X, P.Y, Item.FEditData);
  end;
  Edit.InplaceParams.MultiRowParent := False;
end;

procedure TcxBarEditItemControl.CalcDrawParams(AFull: Boolean = True);
begin
  inherited;
  if AFull then
    FDrawParams.DroppedDown := Focused and Edit.HasPopupWindow;
end;

procedure TcxBarEditItemControl.CalcParts;
begin
  inherited;
  if Item.UseBarPaintingStyle then
    Painter.CalculateComboParts(DrawParams, FParts, ItemBounds);
end;

function TcxBarEditItemControl.CanHide: Boolean;
begin
  Result := inherited CanHide and (not IsDropDownEdit or DropDownEdit.CanHide);
end;

function TcxBarEditItemControl.CanSelect: Boolean;
begin
  Result := inherited CanSelect and (Item.CanEdit or Parent.IsCustomizing);
end;

procedure TcxBarEditItemControl.CheckHotTrack(APoint: TPoint);
var
  ATempViewInfo: TcxCustomEditViewInfo;
begin
  inherited;
  ATempViewInfo := CreateEditViewInfo;
  try
    ATempViewInfo.Assign(EditViewInfo);
    CalculateEditViewInfo(GetBoundsRect, APoint, True);
    EditViewInfo.Repaint(Parent, ATempViewInfo);
  finally
    ATempViewInfo.Free;
  end;
end;

// TODO
procedure TcxBarEditItemControl.ControlInactivate(Immediately: Boolean);
begin
//  Focused := False;
  DisableAppWindows(not IsApplicationActive);
  try
    inherited ControlInactivate(Immediately); //#DG
  finally
    EnableAppWindows;
  end;
end;

procedure TcxBarEditItemControl.DoPaint(ARect: TRect; PaintType: TdxBarPaintType);
begin
  if Edit <> nil then
    Edit.InvalidateWithChildren;
  inherited;
end;

procedure TcxBarEditItemControl.DoMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  if Assigned(FSavedEditEvents.OnMouseMove) then
    FSavedEditEvents.OnMouseMove(Sender, Shift, X, Y);
  P := ClientToParent(Point(X, Y));
  MouseMove(Shift, P.X, P.Y);
end;

procedure TcxBarEditItemControl.DrawTextField;

  function HasEditButtonCompositeFrame: Boolean;
  begin
    Result := Painter.EditButtonAllowCompositeFrame and Item.UseBarPaintingStyle;
  end;

begin
  if not Focused or HasEditButtonCompositeFrame then
  begin
    CalculateEditViewInfo(GetBoundsRect, Parent.ScreenToClient(GetMouseCursorPos), False);
    EditViewInfo.Data := Integer(FDrawParams.PaintType);
//    BarCanvas.BeginPaint(Canvas);
    Canvas.SaveState;
    try
      EditViewInfo.Paint(Canvas);
//      EditViewInfo.Paint(BarCanvas);
    finally
      Canvas.RestoreState;
//      BarCanvas.EndPaint;
    end;
  end;
end;  

function TcxBarEditItemControl.GetControl: TControl;
begin
  Result := Edit;
end;

function TcxBarEditItemControl.GetHandle: HWND;
begin
  if (Edit <> nil) and Edit.HandleAllocated then
    Result := Edit.Handle
  else
    Result := 0;
end;

function TcxBarEditItemControl.GetDefaultHeight: Integer;
var
  AEditHeight: Integer;
begin
  Result := inherited GetDefaultHeight;
  AEditHeight := GetEditSize.cy;
  if Result < AEditHeight then
    Result := AEditHeight;
  if Result < Item.Height then
    Result := Item.Height;
end;

function TcxBarEditItemControl.GetMinEditorWidth: Integer;
begin
  Result := GetEditSize.cx;
end;

function TcxBarEditItemControl.GetPartCount: Integer;
begin
  Result := inherited GetPartCount;
  if Item.UseBarPaintingStyle then
    Inc(Result);
end;

function TcxBarEditItemControl.GetShowCaption: Boolean;
begin
  if Item.CaptionIsEditValue then
    Result := False
  else
    Result := inherited GetShowCaption;
end;

function TcxBarEditItemControl.GetCaptionAreaWidth: Integer;
begin
  if NeedEditShowCaption then
    if (GetPaintType = ptMenu) and Painter.SubMenuControlHasBand and not (cpIcon in GetViewStructure) then
      Result := TdxBarSubMenuControlAccess(SubMenuParent).BandSize
    else
      Result := 0
  else
    Result := inherited GetCaptionAreaWidth;
end;

function TcxBarEditItemControl.GetControlAreaWidth: Integer;
begin
  if NeedEditShowCaption then
    Result := GetMinEditorWidth
  else
    Result := inherited GetControlAreaWidth;
end;

function TcxBarEditItemControl.GetPossibleViewLevels: TdxBarItemViewLevels;
begin
  Result := inherited GetPossibleViewLevels;
  if Item.CaptionIsEditValue then
    Result := Result - [ivlSmallIconWithText];
end;

procedure TcxBarEditItemControl.Hide(AStoreDisplayValue: Boolean);
begin
  if Edit <> nil then
    if not (csDestroying in BarManager.ComponentState) then
    begin
      if not IsWindowEnabled then
      begin
        Item.FPrevOnEditValueChanged := Edit.InternalProperties.OnEditValueChanged;
        Edit.InternalProperties.OnEditValueChanged := Item.DoEditValueChanged;
      end;
      FEditValueBeforeHiding := Edit.EditingValue;
      LockChangeEvents(True);
      try
        Edit.Clear;
        FIsEditValueAssigned := False;
      finally
        LockChangeEvents(False);
      end;
      FakeWinControl.Parent := nil;
      EditorParentForm.SetBounds(0, 0, 0, 0);
      DisableAppWindows(not IsApplicationActive);
      try
        EditorParentForm.FocusControl(nil); // must be before Parent:=nil because DoEnter in WinControl Activate
        Edit.Parent := nil; // must be before DefocusControl
        if IsDropDownEdit then
          DropDownEdit.PopupWindow.ActiveControl := nil;
      finally
        EnableAppWindows;
      end;
      EditorParentForm.DefocusControl(Edit, True); // must be before ClearEditEvents;
      ClearEditEvents;
      ClearViewInfoEvents(Edit.ViewInfo);
      EditorParentForm.Visible := False;
      EditorParentForm.ParentWindow := 0;
      Item.DoExit;
      if AStoreDisplayValue then
        StoreDisplayValue;
      FEdit := nil;
    end
    else
    begin
      ClearEditEvents;
      ClearViewInfoEvents(Edit.ViewInfo);
    end;
end;

procedure TcxBarEditItemControl.InitEdit;

  procedure SetEditButtonsWidth;
  var
    AButton: TcxEditButton;
    I: Integer;
  begin
    for I := 0 to Edit.InternalProperties.Buttons.Count - 1 do
    begin
      AButton := Edit.InternalProperties.Buttons[I];
      if AButton.Visible and (AButton.Width = 0) then
        AButton.Width := GetDefaultEditButtonWidth(I);
    end;
  end;

  procedure InitEditProperties;
  begin
    LockChangeEvents(True);
    try
      Edit.InternalProperties.LockUpdate(true);
      Edit.InternalProperties.Assign(Properties);
      Edit.InternalProperties.LockUpdate(false);
      SetEditButtonsWidth;
    finally
      LockChangeEvents(False);
    end;
  end;

  procedure AssignEditEvents;
  begin
    SaveEditEvents;
    Edit.InternalProperties.OnChange := DoEditPropertiesChange;
    Edit.InternalProperties.OnClosePopup := DoEditClosePopup;
    Edit.InternalProperties.OnValidate := DoValidate;
    Edit.OnFocusChanged := DoFocusChanged;
    Edit.OnKeyDown := DoKeyDown;
    Edit.OnKeyPress := DoKeyPress;
    Edit.OnKeyUp := DoKeyUp;
    Edit.OnMouseMove := DoMouseMove;
    Edit.OnPostEditValue := DoPostEditValue;

    if IsDropDownEdit then
    begin
      DropDownEdit.OnAfterKeyDown := DoAfterKeyDown;
      DropDownEdit.Properties.OnInitPopup := DoInitPopup;
      DropDownEdit.PopupWindow.ViewInfo.OnCustomDrawBorder := DoCustomDrawPopupBorder;
    end;
  end;

var
  ISpellCheckerEdit: IdxSpellCheckerControl;
begin
  FEdit := EditList.GetEdit(TcxCustomEditPropertiesClass(Properties.ClassType));
// #SC todo:
  if Supports(TObject(FEdit), IdxSpellCheckerControl, ISpellCheckerEdit) then
     ISpellCheckerEdit.SetIsBarControl(True);
//#DG (RichEdit want handle)  RestoreDisplayValue;
  InitEditProperties;
  Edit.Style := EditStyle;
  InitEditContentParams(Edit.ContentParams);
  AssignViewInfoEvents(Edit.ViewInfo);
  AssignEditEvents;
end;

function TcxBarEditItemControl.IsChildWindow(AWnd: HWND): Boolean;
begin
  Result := inherited IsChildWindow(AWnd) or (Edit <> nil) and (Edit.IsChildWindow(AWnd));
end;

function TcxBarEditItemControl.IsEditTransparent: Boolean;
begin
  Result := esoTransparency in Properties.GetSupportedOperations;
end;

function TcxBarEditItemControl.IsTransparentOnGlass: Boolean;
begin
  Result := IsEditTransparent;
end;

procedure TcxBarEditItemControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if not Focused then
  begin
    Click(False, Char(Key));
    Key := 0;
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TcxBarEditItemControl.ParentVisibleChange(AIsShowing: Boolean);
const
  AShowParams: array[Boolean] of Integer = (SW_HIDE, SW_SHOWNOACTIVATE);
begin
  if IsDropDownEdit and DropDownEdit.HasPopupWindow then
    ShowWindow(DropDownEdit.PopupWindow.Handle, AShowParams[AIsShowing]);
end;

procedure TcxBarEditItemControl.RestoreDisplayValue;
begin
  LockChangeEvents(True);
  try
    if CanSelect then
    begin
      Edit.EditValue := Item.EditValue;
      FIsEditValueAssigned := True;
      if esoShowingCaption in Properties.GetSupportedOperations then
        if NeedEditShowCaption then
          TControlAccess(Edit).Caption := Caption
        else
          TControlAccess(Edit).Caption := '';
    end;
  finally
    LockChangeEvents(False);
  end;
end;

procedure TcxBarEditItemControl.Show;
begin
  inherited Show;
  InternalShowEdit;
  RestoreDisplayValue;
  Item.DoEnter;
end;

procedure TcxBarEditItemControl.StoreDisplayValue;
begin
  PrepareEditForClose;
  if (Edit <> nil) and FIsEditValueAssigned then
    Item.EditValue := Edit.EditValue
  else
    Item.EditValue := FEditValueBeforeHiding;
end;

function TcxBarEditItemControl.WantsKey(Key: Word): Boolean;
begin
  Result := inherited WantsKey(Key) or Properties.IsActivationKey(Char(Key));
end;

procedure TcxBarEditItemControl.CalculateEditViewInfo(const ABounds: TRect;
  P: TPoint; AIsMouseEvent: Boolean; AEditViewInfo: TcxCustomEditViewInfo; AFull: Boolean);

  function CanHotTrack: Boolean;
  begin
    Result := not (Item.IsDesigning or Parent.IsCustomizing) and IsWindowEnabled and Painter.EditButtonAllowHotTrack(FDrawParams);
  end;

var
  AViewData: TcxCustomEditViewData;
  AViewInfo: TcxCustomEditViewInfo;
begin
  if AEditViewInfo <> nil then
    AViewInfo := AEditViewInfo
  else
    AViewInfo := EditViewInfo;
  AViewData := CreateEditViewData(AFull);
  try
    if not CanHotTrack then
      P := Point(-1, -1);
    AssignViewInfoEvents(AViewInfo);
    if Item.CaptionIsEditValue then
      AViewData.EditValueToDrawValue(Canvas, Caption, AViewInfo)
    else
      AViewData.EditValueToDrawValue(Canvas, Item.EditValue, AViewInfo);
    if not Item.CaptionIsEditValue and NeedEditShowCaption then
      TcxCustomTextEditViewInfo(AViewInfo).Text := Caption;
    BarCanvas.BeginPaint(Canvas.Canvas);
    try
      AViewData.Calculate(BarCanvas, ABounds, P, cxmbNone, [], AViewInfo, AIsMouseEvent);
    finally
      BarCanvas.EndPaint;
    end;
    if AFull then
      CalcParts;
  finally
    AViewData.Free;
  end;
end;

function TcxBarEditItemControl.CreateEditViewData(AFull: Boolean = True): TcxCustomEditViewData;
begin
  Result := Properties.CreateViewData(EditStyle, True);
  Result.Enabled := Enabled;
  if AFull then
    InitEditContentParams(Result.EditContentParams);
  Result.OnGetDefaultButtonWidth := DoGetEditDefaultButtonWidth;
end;

function TcxBarEditItemControl.CreateEditViewInfo: TcxCustomEditViewInfo;
begin
  Result := TcxCustomEditViewInfo(Properties.GetViewInfoClass.Create);
end;

procedure TcxBarEditItemControl.ClearEditEvents;
begin
  Edit.InternalProperties.OnChange := nil;
  Edit.InternalProperties.OnClosePopup := nil;
  Edit.InternalProperties.OnValidate := nil;
  Edit.OnFocusChanged := nil;
  Edit.OnKeyDown := nil;
  Edit.OnKeyPress := nil;
  Edit.OnKeyUp := nil;
  Edit.OnMouseMove := nil;
  Edit.OnPostEditValue := nil;

  if IsDropDownEdit then
  begin
    DropDownEdit.OnAfterKeyDown := nil;
    DropDownEdit.Properties.OnInitPopup := nil;
    DropDownEdit.PopupWindow.ViewInfo.OnCustomDrawBorder := nil;
  end;
end;

procedure TcxBarEditItemControl.InternalShowEdit;
begin
  EditorParentForm.ParentWindow := Parent.Handle;
  EditorParentForm.BoundsRect := GetBoundsRect;
  Edit.Align := alClient;
  Edit.Parent := EditorParentForm;

  Edit.Visible := True; {#DG TODO: MUST BE CHECKED BY SERG}

  TControl(EditorParentForm).Visible := True;
end;

procedure TcxBarEditItemControl.SaveEditEvents;
begin
  FSavedEditEvents.OnChange := Edit.InternalProperties.OnChange;
  FSavedEditEvents.OnClosePopup := Edit.InternalProperties.OnClosePopup;
  FSavedEditEvents.OnValidate := Edit.InternalProperties.OnValidate;
  FSavedEditEvents.OnFocusChanged := Edit.OnFocusChanged;
  FSavedEditEvents.OnKeyDown := Edit.OnKeyDown;
  FSavedEditEvents.OnKeyPress := Edit.OnKeyPress;
  FSavedEditEvents.OnKeyUp := Edit.OnKeyUp;
  FSavedEditEvents.OnMouseMove := Edit.OnMouseMove;
  FSavedEditEvents.OnPostEditValue := Edit.OnPostEditValue;

  if IsDropDownEdit then
  begin
    FSavedEditEvents.OnAfterKeyDown := DropDownEdit.OnAfterKeyDown;
    FSavedEditEvents.OnInitPopup := DropDownEdit.Properties.OnInitPopup;
  end;
end;

procedure TcxBarEditItemControl.DoAfterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FSavedEditEvents.OnAfterKeyDown) then
    FSavedEditEvents.OnAfterKeyDown(Sender, Key, Shift);
  if Key = VK_TAB then
    KeyDown(Key, Shift);
end;

procedure TcxBarEditItemControl.DoCustomDrawPopupBorder(AViewInfo: TcxContainerViewInfo; ACanvas: TcxCanvas; const R: TRect; var AHandled: Boolean;
  out ABorderWidth: Integer);
begin
  AHandled := True;
  ABorderWidth := Painter.GetPopupWindowBorderWidth;
  if (ACanvas <> nil) then
    Painter.DropDownListBoxDrawBorder(ACanvas.Handle, AViewInfo.BackgroundColor, R);
end;

procedure TcxBarEditItemControl.DoDrawEditBackground(
  Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; var AHandled: Boolean);
var
  APrevWindowOrg: TPoint;
  ABounds: TRect;
begin
  AHandled := IsEditTransparent;
  if AHandled and (ACanvas <> nil) then
  begin
    ABounds := Sender.Bounds;
    BeforeDrawBackground(Sender.Edit, Edit, ACanvas.Handle, ABounds, APrevWindowOrg);
    try
      DrawEditBackground(ACanvas, ABounds, Sender.BackgroundColor);
    finally
      AfterDrawBackground(ACanvas.Handle, APrevWindowOrg);
    end;
  end;
end;

procedure TcxBarEditItemControl.DoDrawEditButton(Sender: TcxCustomEditViewInfo;
  ACanvas: TcxCanvas; AButtonVisibleIndex: Integer; var AHandled: Boolean);
var
  APrevWindowOrg: TPoint;
  AOriginalCanvas: TcxCanvas;
  ARect: TRect;
  AUseParentCanvas: Boolean;
begin
  AHandled := Item.UseBarPaintingStyle;
  if AHandled then
  begin
   AUseParentCanvas := ACanvas.Handle = Canvas.Handle;
   ARect := FParts[ccpDropButton];
    if (Edit <> nil) and Edit.HandleAllocated and not AUseParentCanvas then
      MapWindowRect(Parent.Handle, Edit.Handle, ARect);
    BeforeDrawBackground(Edit, Parent, ACanvas.Handle, ARect, APrevWindowOrg);
    try
      AOriginalCanvas := FDrawParams.Canvas;
      try
        FDrawParams.Canvas := ACanvas;
        Painter.ComboControlDrawArrowButton(DrawParams, ARect, True);
      finally
        FDrawParams.Canvas := AOriginalCanvas
      end;
    finally
      AfterDrawBackground(ACanvas.Handle, APrevWindowOrg);
    end;
    if Painter.EditButtonAllowCompositeFrame and not AUseParentCanvas then
      Painter.ComboControlDrawArrowButton(DrawParams, FParts[ccpDropButton], False);
  end;
end;

procedure TcxBarEditItemControl.DoDrawEditButtonBackground(
  Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; const ARect: TRect;
  AButtonVisibleIndex: Integer; var AHandled: Boolean);
var
  APrevWindowOrg: TPoint;
  AOriginalCanvas: TcxCanvas;
  AButtonState: Integer;
  ABackgroundRect: TRect;
begin
  AButtonState := GetEditButtonState(Sender.ButtonsInfo[AButtonVisibleIndex]);
  AHandled := Painter.EditButtonIsCustomBackground(AButtonState);

  if AHandled and (ACanvas <> nil) then
  begin
    ABackgroundRect := ARect;
    BeforeDrawBackground(Edit, Parent, ACanvas.Handle, ABackgroundRect, APrevWindowOrg);
    try
      AOriginalCanvas := FDrawParams.Canvas;
      try
        FDrawParams.Canvas := ACanvas;
        Painter.EditButtonDrawBackground(DrawParams, AButtonState,
          ABackgroundRect, GetSolidBrush(Sender.BackgroundColor));
      finally
        FDrawParams.Canvas := AOriginalCanvas
      end;
    finally
      AfterDrawBackground(ACanvas.Handle, APrevWindowOrg);
    end;
  end;
end;

procedure TcxBarEditItemControl.DoDrawEditButtonBorder(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
  out ABackgroundRect, AContentRect: TRect; var AHandled: Boolean);
var
  APrevWindowOrg: TPoint;
  AOriginalCanvas: TcxCanvas;
  AOffset: TPoint;
begin
  AHandled := Painter.EditButtonIsCustomBorder;
  if (ACanvas <> nil) and AHandled then
  begin
    ABackgroundRect := Sender.ButtonsInfo[AButtonVisibleIndex].Bounds;
    AOffset := BeforeDrawBackground(Edit, Parent, ACanvas.Handle, ABackgroundRect, APrevWindowOrg);
    try
      AOriginalCanvas := FDrawParams.Canvas;
      try
        FDrawParams.Canvas := ACanvas;
        Painter.EditButtonDrawBorder(FDrawParams, GetEditButtonState(Sender.ButtonsInfo[AButtonVisibleIndex]), ABackgroundRect, AContentRect);
      finally
        FDrawParams.Canvas := AOriginalCanvas
      end;
    finally
      AfterDrawBackground(ACanvas.Handle, APrevWindowOrg);
    end;
    ABackgroundRect := cxRectOffset(ABackgroundRect, cxPointInvert(AOffset));
    AContentRect := cxRectOffset(AContentRect, cxPointInvert(AOffset));
  end;
end;

procedure TcxBarEditItemControl.DoEditPaint(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas);
begin
  CalcDrawParams;
end;

procedure TcxBarEditItemControl.DoEditClosePopup(Sender: TcxControl;
  AReason: TcxEditCloseUpReason);
begin
  if Assigned(FSavedEditEvents.OnClosePopup) then
    FSavedEditEvents.OnClosePopup(Sender, AReason);

  case AReason of
    crCancel: DoEscape;
    crEnter: DoEnter;
    crTab: DoNavigation;
  end;
end;

procedure TcxBarEditItemControl.DoEditPropertiesChange(Sender: TObject);
var
  AItem: TcxCustomBarEditItem;
begin
  AItem := Item; // if ItemControl destroyed in OnChange
  if Assigned(FSavedEditEvents.OnChange) then
    FSavedEditEvents.OnChange(Sender);
  AItem.CurChange;
end;

procedure TcxBarEditItemControl.DoGetEditButtonState(Sender: TcxCustomEditViewInfo;
  AButtonVisibleIndex: Integer; var AState: TcxEditButtonState);
begin
  if Item.UseBarPaintingStyle and (Focused or DrawSelected) and (AState = ebsNormal) then
    AState := ebsSelected;
end;

procedure TcxBarEditItemControl.DoGetEditDefaultButtonWidth(
  Sender: TcxCustomEditViewData; AIndex: Integer; var ADefaultWidth: Integer);
begin
  ADefaultWidth := GetDefaultEditButtonWidth(AIndex);
end;

procedure TcxBarEditItemControl.DoFocusChanged(Sender: TObject);
begin
  if Assigned(FSavedEditEvents.OnFocusChanged) then
    FSavedEditEvents.OnFocusChanged(Sender);

  if Focused and not Edit.Focused and not Edit.IsChildWindow(GetFocus) then
    Parent.HideAll;
end;

procedure TcxBarEditItemControl.DoInitPopup(Sender: TObject);
begin
  if Assigned(FSavedEditEvents.OnInitPopup) then
    FSavedEditEvents.OnInitPopup(Sender);
  if IsPopupSideward then
  begin
    DropDownEdit.Properties.PopupDirection := pdHorizontal;
    DropDownEdit.Properties.PopupVertAlignment := pavTop;
    DropDownEdit.Properties.PopupHorzAlignment := pahRight;
  end;
end;

procedure TcxBarEditItemControl.DoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Assigned(FSavedEditEvents.OnKeyDown) then
    FSavedEditEvents.OnKeyDown(Sender, Key, Shift);
  KeyDown(Key, Shift);
end;

procedure TcxBarEditItemControl.DoKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FSavedEditEvents.OnKeyPress) then
    FSavedEditEvents.OnKeyPress(Sender, Key);
  KeyPress(Key);
end;

procedure TcxBarEditItemControl.DoKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Assigned(FSavedEditEvents.OnKeyUp) then
    FSavedEditEvents.OnKeyUp(Sender, Key, Shift);
  KeyUp(Key, Shift);
end;

procedure TcxBarEditItemControl.DoPostEditValue(Sender: TObject);
begin
  Item.EditValue := Edit.EditValue;
end;

procedure TcxBarEditItemControl.DoValidate(Sender: TObject; var DisplayValue: TcxEditValue;
  var ErrorText: TCaption; var Error: Boolean);
begin
  ErrorText := cxGetResourceString(@scxMaskEditInvalidEditValue);
  if Assigned(FSavedEditEvents.OnValidate) then
    FSavedEditEvents.OnValidate(Sender, DisplayValue, ErrorText, Error);
end;

function TcxBarEditItemControl.GetEditButtonState(AButtonViewInfo: TcxEditButtonViewInfo): Integer;
begin
  case AButtonViewInfo.Data.State of
    ebsDisabled: Result := DXBAR_DISABLED;
    ebsPressed: Result := DXBAR_DROPPEDDOWN;
    ebsSelected: Result := DXBAR_HOT
  else
    if FHotPartIndex = ecpEdit then
      Result := DXBAR_ACTIVE
    else
      Result := DXBAR_NORMAL
  end;
end;

procedure TcxBarEditItemControl.AssignViewInfoEvents(
  AViewInfo: TcxCustomEditViewInfo);
begin
  AViewInfo.OnDrawBackground := DoDrawEditBackground;
  AViewInfo.OnDrawButton := DoDrawEditButton;
  AViewInfo.OnDrawButtonBackground := DoDrawEditButtonBackground;
  AViewInfo.OnDrawButtonBorder := DoDrawEditButtonBorder;
  AViewInfo.OnGetButtonState := DoGetEditButtonState;
  AViewInfo.OnPaint := DoEditPaint;
end;

procedure TcxBarEditItemControl.ClearViewInfoEvents(
  AViewInfo: TcxCustomEditViewInfo);
begin
  AViewInfo.OnDrawBackground := nil;
  AViewInfo.OnDrawButton := nil;
  AViewInfo.OnDrawButtonBackground := nil;
  AViewInfo.OnDrawButtonBorder := nil;
  AViewInfo.OnGetButtonState := nil;
  AViewInfo.OnPaint := nil;
end;

procedure TcxBarEditItemControl.DrawEditBackground(ACanvas: TcxCanvas;
  ARect: TRect; AColor: TColor);
var
  APrevWindowOrg: TPoint;
begin
  BeforeDrawBackground(Edit, Parent, ACanvas.Handle, ARect, APrevWindowOrg);
  try
    Painter.DrawItemBackground(Self, ACanvas, ARect, GetSolidBrush(AColor));
  finally
    AfterDrawBackground(ACanvas.Handle, APrevWindowOrg);
  end;
end;

function TcxBarEditItemControl.GetBoundsRect: TRect;
begin
  Result := Painter.EditControlGetContentRect(GetPaintType, GetEditRect);
end;

function TcxBarEditItemControl.GetCurEditValue: TcxEditValue;
begin
  if Edit <> nil then
    Result := Edit.EditingValue
  else
    Result := Item.EditValue;
end;

function TcxBarEditItemControl.GetDefaultEditButtonWidth(AIndex: Integer): Integer;
begin
  if Item.UseBarPaintingStyle then
  begin
    Result := Parent.ComboBoxArrowWidth;
    Painter.EditButtonCorrectDefaultWidth(Result);
  end
  else
    Result := 0;
end;

function TcxBarEditItemControl.GetDropDownEdit: TcxCustomDropDownEdit;
begin
  Result := TcxCustomDropDownEdit(Edit);
end;

function TcxBarEditItemControl.GetEditSize: TSize;
var
  ABorderOffsets: TRect;
  AConstantPartSize, AMinContentSize: TSize;
  AEditViewInfo: TcxCustomEditViewInfo;
  AViewData: TcxCustomEditViewData;
begin
  AEditViewInfo := nil;
  AViewData := nil;
  try
    AEditViewInfo := CreateEditViewInfo;
    AViewData := CreateEditViewData(False);
    CalculateEditViewInfo(Rect(0, 0, MaxInt, MaxInt), Point(-1, -1), False, AEditViewInfo, False);
    BarCanvas.BeginPaint(Canvas.Canvas);
    try
      AConstantPartSize := AViewData.GetEditConstantPartSize(BarCanvas,
        DefaultcxEditSizeProperties, AMinContentSize, AEditViewInfo);
      ABorderOffsets := Painter.EditControlBorderOffsets(GetPaintType);
      Inc(AConstantPartSize.cx, ABorderOffsets.Left + ABorderOffsets.Right);
      Inc(AConstantPartSize.cy, ABorderOffsets.Top + ABorderOffsets.Bottom);
      if Item.CaptionIsEditValue then
        Result := AViewData.GetEditContentSize(BarCanvas, Caption, DefaultcxEditSizeProperties)
      else
        Result := Size(0, 0);
    finally
      BarCanvas.EndPaint;
    end;

    CheckSize(Result, AMinContentSize);
    if not (esfNoContentPart in Properties.GetSpecialFeatures) and (Result.cx < MinContentWidth) then
      Result.cx := MinContentWidth;
    Inc(Result.cx, AConstantPartSize.cx);
    Inc(Result.cy, AConstantPartSize.cy);
  finally
    FreeAndNil(AEditViewInfo);
    FreeAndNil(AViewData);
  end;
end;

function TcxBarEditItemControl.GetEditStyle: TcxEditStyle;
var
  ABackgroundColor, ATextColor: COLORREF;
begin
  CalcDrawParams;
  Painter.EditGetColors(Self, ATextColor, ABackgroundColor);
  if IsEditTransparent then
    ABackgroundColor := cxGetBrushData(Parent.BkBrush).lbColor;
    Result := InternalGetEditStyle(Properties, BarManager, Painter,
      EditFont, ABackgroundColor, ATextColor, DrawSelected);
end;

function TcxBarEditItemControl.GetEditViewInfo: TcxCustomEditViewInfo;
begin
  if (FEditViewInfo <> nil) and (FEditViewInfo.ClassType <> Properties.GetViewInfoClass) then
    FreeAndNil(FEditViewInfo);
  if FEditViewInfo = nil then
    FEditViewInfo := CreateEditViewInfo;
  Result := FEditViewInfo;
end;

function TcxBarEditItemControl.GetItem: TcxCustomBarEditItem;
begin
  Result := TcxCustomBarEditItem(ItemLink.Item);
end;

function TcxBarEditItemControl.GetProperties: TcxCustomEditProperties;
begin
  Result := Item.GetProperties;
end;

procedure TcxBarEditItemControl.InitEditContentParams(
  var AParams: TcxEditContentParams);
var
  ABorderOffsets: TRect;
begin
  AParams.ExternalBorderBounds := GetEditRect;
  OffsetRect(AParams.ExternalBorderBounds, -AParams.ExternalBorderBounds.Left,
    -AParams.ExternalBorderBounds.Top);
  if IsPopupSideward then
    Dec(AParams.ExternalBorderBounds.Left, GetEditOffset);
  ABorderOffsets := Painter.EditControlBorderOffsets(GetPaintType);
  OffsetRect(AParams.ExternalBorderBounds, -ABorderOffsets.Left,
    -ABorderOffsets.Top);

  if NeedEditShowCaption then
  begin
    AParams.Offsets := Painter.GetCaptionOffsets;
    AParams.SizeCorrection.cy := 0;
  end
  else
    Painter.GetEditTextParams(AParams.Offsets, AParams.SizeCorrection.cy);
  AParams.SizeCorrection.cx := 0;

  AParams.Options := [];
  if Painter.EditButtonAllowOffsetContent then
    Include(AParams.Options, ecoOffsetButtonContent);
//  if Focused then
//    AParams.Options := [ecoShowFocusRectWhenInplace];
end;

function TcxBarEditItemControl.IsDropDownEdit: Boolean;
begin
  Result := Edit is TcxCustomDropDownEdit;
end;

function TcxBarEditItemControl.IsPopupSideward: Boolean;
begin
  Result := (Parent.Kind = bkSubMenu) or Parent.IsRealVertical
end;

function TcxBarEditItemControl.NeedEditShowCaption: Boolean;
begin
  Result := Item.CaptionIsEditValue or inherited GetShowCaption and not GetShowCaption;
end;

procedure TcxBarEditItemControl.PrepareEditForClose;
begin
  Edit.Deactivate;
  if Edit <> nil then
  begin
    Item.GetProperties.BeginUpdate;
    try
      Edit.ActiveProperties.Update(Item.GetProperties);
    finally
      Item.GetProperties.EndUpdate(False);
    end;
  end;
end;

procedure TcxBarEditItemControl.LockChangeEvents(ALock: Boolean);
begin
  if ALock then
  begin
    Edit.LockChangeEvents(True);
    Edit.InternalProperties.BeginUpdate;
  end
  else
  begin
    Edit.InternalProperties.EndUpdate(False);
    Edit.LockChangeEvents(False, False);
  end;
end;

initialization
  dxBarRegisterItem(TcxBarEditItem, TcxBarEditItemControl, True);
  BarDesignController.RegisterBarControlEditor(TcxItemsEditorEx);

finalization
  FreeAndNil(FFakeWinControl); //#!!!

  BarDesignController.UnregisterBarControlEditor(TcxItemsEditorEx);
  dxBarUnregisterItem(TcxBarEditItem);  

  FreeAndNil(FDefaultRepositoryItem);
  FreeAndNil(FEditList);
  FreeAndNil(FEditorParentForm);
  FreeAndNil(FEditStyle);

end.
