
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

unit cxImageComboBox;

{$I cxVer.inc}

interface

uses
  Windows, Messages, ComCtrls,
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  cxVariants, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Clipbrd,
  ImgList, cxClasses, cxGraphics, cxControls, cxContainer, cxDataStorage, cxDataUtils,
  cxEdit, cxDropDownEdit, cxTextEdit, cxFilterControlUtils;

type
  { TcxImageComboBoxItem }

  TcxImageComboBoxItem = class(TCollectionItem)
  private
    FDescription: TCaption;
    FImageIndex: TImageIndex;
    FTag: TcxTag;
    FValue: Variant;
    function IsStoredValue: Boolean;
    function IsTagStored: Boolean;
    procedure SetDescription(const Value: TCaption);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetValue(const AValue: Variant);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Description: TCaption read FDescription write SetDescription;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
    property Value: Variant read FValue write SetValue stored IsStoredValue;
  end;

  { TcxImageComboBoxItems }

  TcxImageComboBoxItems = class(TOwnedCollection)
  private
    function GetItems(Index: Integer): TcxImageComboBoxItem;
    procedure SetItems(Index: Integer; const Value: TcxImageComboBoxItem);
  protected
    procedure InternalChanged;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TcxImageComboBoxItem;
  {$IFNDEF DELPHI6}
    function Owner: TPersistent;
  {$ENDIF}
    property Items[Index: Integer]: TcxImageComboBoxItem
      read GetItems write SetItems; default;
  end;

  { TcxImageComboBoxListBox }

  TcxCustomImageComboBox = class;
  TcxCustomImageComboBoxProperties = class;

  TcxImageComboBoxListBox = class(TcxComboBoxListBox)
  private
    FClientWidth: Integer;
    FHasScrollbar: Boolean;
    function GetEdit: TcxCustomImageComboBox;
    function GetProperties: TcxCustomImageComboBoxProperties;
  protected
    procedure DrawItem(Index: Integer; Rect: TRect;
      State: TOwnerDrawState); override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure RecreateWindow; override;
    function GetImageRect(const R: TRect): TRect;
    function GetImages: TCustomImageList;
    function GetMaxItemWidth: Integer; virtual;
    property Edit: TcxCustomImageComboBox read GetEdit;
    property Properties: TcxCustomImageComboBoxProperties read GetProperties;
  public
    constructor Create(AOwner: TComponent); override;
    function GetHeight(ARowCount: Integer; AMaxHeight: Integer): Integer; override;
    function GetItemWidth(AIndex: Integer): Integer; override;
  end;

  { TcxImageComboBoxLookupData }

  TcxImageComboBoxLookupData = class(TcxComboBoxLookupData)
  private
    function GetList: TcxImageComboBoxListBox;
  protected
    function GetListBoxClass: TcxCustomEditListBoxClass; override;
    function GetItem(Index: Integer): string; override;
    function GetItemCount: Integer; override;
    property List: TcxImageComboBoxListBox read GetList;
  public
    procedure TextChanged; override;
  end;

  { TcxImageComboBoxViewData }

  TcxImageComboBoxViewData = class(TcxCustomDropDownEditViewData)
  private
    function GetProperties: TcxCustomImageComboBoxProperties;
  protected
    function InternalEditValueToDisplayText(AEditValue: TcxEditValue): string; override;
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
      AViewInfo: TcxCustomEditViewInfo): TSize; override;
    function IsComboBoxStyle: Boolean; override;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
      const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean); override;
    procedure DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    property Properties: TcxCustomImageComboBoxProperties read GetProperties;
  end;

  { TcxImageComboBoxViewInfo }

  TcxImageAlign = (iaLeft, iaRight);

  TcxImageComboBoxViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  public
    ImageRect: TRect;
    ShowDescriptions: Boolean;
    ImageAlign: TcxImageAlign;
    ImageIndex: TImageIndex;
    Images: TCustomImageList;
    procedure Offset(DX, DY: Integer); override;
  end;

  { TcxCustomImageComboBoxProperties }

  TcxCustomImageComboBoxProperties = class(TcxCustomComboBoxProperties)
  private
    FDefaultDescription: string;
    FDefaultImageIndex: TImageIndex;
    FImageAlign: TcxImageAlign;
    FImages: TCustomImageList;
    FImagesChangeLink: TChangeLink;
    FItems: TcxImageComboBoxItems;
    FLargeImages: TCustomImageList;
    FLargeImagesChangeLink: TChangeLink;
    FMultiLineText: Boolean;
    FShowDescriptions: Boolean;
    procedure ImagesChange(Sender: TObject);
    procedure LargeImagesChange(Sender: TObject);
    procedure SetDefaultDescription(const Value: string);
    procedure SetDefaultImageIndex(const Value: TImageIndex);
    procedure SetImageAlign(const Value: TcxImageAlign);
    procedure SetImages(Value: TCustomImageList);
    procedure SetItems(const Value: TcxImageComboBoxItems);
    procedure SetLargeImages(Value: TCustomImageList);
    procedure SetMultiLineText(const Value: Boolean);
    procedure SetShowDescriptions(const Value: Boolean);
  protected
    function FindItemByText(const AText: string): TcxImageComboBoxItem;
    function FindLookupText(const AText: string): Boolean; override;
    procedure FreeNotification(Sender: TComponent); override;
    function GetDisplayFormatOptions: TcxEditDisplayFormatOptions; override;
    class function GetLookupDataClass: TcxInterfacedPersistentClass; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
    procedure InternalGetImageComboBoxDisplayValue(AItem: TcxImageComboBoxItem;
      out AText: TCaption; out AImageIndex: TImageIndex;
      AAlwaysShowDescription: Boolean = False); virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    function FindItemByValue(const AValue: Variant): TcxImageComboBoxItem;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    procedure GetImageComboBoxDisplayValue(const AEditValue: TcxEditValue;
      out AText: TCaption; out AImageIndex: TImageIndex);
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsEditValueValid(var AEditValue: TcxEditValue; AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    // !!!
    property DefaultDescription: string
      read FDefaultDescription write SetDefaultDescription;
    property DefaultImageIndex: TImageIndex
      read FDefaultImageIndex write SetDefaultImageIndex default -1;
    property ImageAlign: TcxImageAlign
      read FImageAlign write SetImageAlign default iaLeft;
    property Images: TCustomImageList read FImages write SetImages;
    property Items: TcxImageComboBoxItems read FItems write SetItems;
    property LargeImages: TCustomImageList read FLargeImages write SetLargeImages;
    property MultiLineText: Boolean
      read FMultiLineText write SetMultiLineText default False;
    property ShowDescriptions: Boolean
      read FShowDescriptions write SetShowDescriptions default True;
  end;

  { TcxImageComboBoxProperties }

  TcxImageComboBoxProperties = class(TcxCustomImageComboBoxProperties)
  published
    property Alignment;
    property AssignedValues;
    property ButtonGlyph;
    property ClearKey;
    property DefaultDescription;
    property DefaultImageIndex;
    property DropDownRows;
    property ImageAlign;
    property Images;
    property ImeMode;
    property ImeName;
    property ImmediateDropDown;
    property ImmediatePost;
    property ImmediateUpdateText;
    property Items;
    property LargeImages;
    property MultiLineText;
    property PopupAlignment;
    property PostPopupValueOnTab;
    property ReadOnly;
    property Revertable;
    property ShowDescriptions;
    property ValidateOnEnter;
    property OnButtonClick;
    property OnChange;
    property OnCloseQuery;
    property OnCloseUp;
    property OnEditValueChanged;
    property OnInitPopup;
    property OnPopup;
    property OnValidate;
  end;

  { TcxCustomImageComboBox }

  TcxCustomImageComboBox = class(TcxCustomComboBox)
  private
    function GetProperties: TcxCustomImageComboBoxProperties;
    function GetActiveProperties: TcxCustomImageComboBoxProperties;
    function GetLookupData: TcxImageComboBoxLookupData;
    procedure SetProperties(const Value: TcxCustomImageComboBoxProperties);
  protected
    function GetItemObject: TObject; override;
    function GetPopupWindowClientPreferredSize: TSize; override;
    function InternalGetEditingValue: TcxEditValue; override;
    function IsValidChar(AChar: Char): Boolean; override;
    function LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue; override;
    procedure SynchronizeDisplayValue; override;
    procedure UpdateDrawValue; override;
    property LookupData: TcxImageComboBoxLookupData read GetLookupData;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    property ActiveProperties: TcxCustomImageComboBoxProperties read GetActiveProperties;
    property Properties: TcxCustomImageComboBoxProperties read GetProperties
      write SetProperties;
  end;

  { TcxImageComboBox }

  TcxImageComboBox = class(TcxCustomImageComboBox)
  private
    function GetActiveProperties: TcxImageComboBoxProperties;
    function GetProperties: TcxImageComboBoxProperties;
    procedure SetProperties(Value: TcxImageComboBoxProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxImageComboBoxProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditValue;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ItemIndex;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxImageComboBoxProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnEditing;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  { TcxFilterImageComboBoxHelper }

  TcxFilterImageComboBoxHelper = class(TcxFilterComboBoxHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

implementation

uses
  Dialogs, Math, cxGeometry, cxButtons, cxEditConsts, cxEditUtils, cxScrollBar,
  cxDWMApi;

const
  EmptyRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

type
  TcxCustomTextEditAccess = class(TcxCustomTextEdit);

{ TcxImageComboBoxItem }

constructor TcxImageComboBoxItem.Create(Collection: TCollection);
var
  AImages: TCustomImageList;
begin
  FValue := Null; // for D5 variants
  inherited Create(Collection);
  AImages :=
    TcxCustomImageComboBoxProperties(TcxImageComboBoxItems(Collection).Owner).Images;
  if (AImages <> nil) and (AImages.Count >= Collection.Count) then
    FImageIndex := Collection.Count - 1
  else
    FImageIndex := -1;
end;

function TcxImageComboBoxItem.IsStoredValue: Boolean;
begin
  Result := not VarIsNull(FValue);
end;

function TcxImageComboBoxItem.IsTagStored: Boolean;
begin
  Result := FTag <> 0;
end;

procedure TcxImageComboBoxItem.SetDescription(const Value: TCaption);
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    TcxImageComboBoxItems(Collection).InternalChanged;
  end;
end;

procedure TcxImageComboBoxItem.SetImageIndex(const Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    TcxImageComboBoxItems(Collection).InternalChanged;
  end;
end;

procedure TcxImageComboBoxItem.SetValue(const AValue: Variant);
begin
  if not InternalVarEqualsExact(FValue, AValue) then
  begin
    FValue := AValue;
    TcxImageComboBoxItems(Collection).InternalChanged;
  end;
end;

procedure TcxImageComboBoxItem.Assign(Source: TPersistent);
begin
  if Source is TcxImageComboBoxItem then
    with TcxImageComboBoxItem(Source) do
    begin
      Self.Description := Description;
      Self.ImageIndex := ImageIndex;
      Self.Tag := Tag;
      Self.Value := Value;
    end
  else
    inherited Assign(Source);
end;

{ TcxImageComboBoxItems }

function TcxImageComboBoxItems.GetItems(Index: Integer): TcxImageComboBoxItem;
begin
  Result := TcxImageComboBoxItem(inherited Items[Index]);
end;

procedure TcxImageComboBoxItems.SetItems(Index: Integer;
  const Value: TcxImageComboBoxItem);
begin
  inherited Items[Index] := Value;
end;

procedure TcxImageComboBoxItems.InternalChanged;
begin
  Changed;
end;

procedure TcxImageComboBoxItems.Update(Item: TCollectionItem);
begin
  with TcxCustomImageComboBoxProperties(Owner) do
    Changed;
end;

constructor TcxImageComboBoxItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TcxImageComboBoxItem);
end;

function TcxImageComboBoxItems.Add: TcxImageComboBoxItem;
begin
  Result := TcxImageComboBoxItem(inherited Add);
end;

{$IFNDEF DELPHI6}
function TcxImageComboBoxItems.Owner: TPersistent;
begin
  Result := GetOwner;
end;
{$ENDIF}

{ TcxImageComboBoxListBox }

constructor TcxImageComboBoxListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BorderStyle := bsNone;
  Style := lbOwnerDrawVariable;
end;

function TcxImageComboBoxListBox.GetHeight(ARowCount: Integer; AMaxHeight: Integer): Integer;
var
  I, H: Integer;
  R: TRect;
begin
  if Properties.MultiLineText then
    with TcxCustomImageComboBox(Edit) do
    begin
      R := GetPopupWindowOwnerControlBounds;
      FClientWidth := R.Right - R.Left;
      R := PopupWindow.ViewInfo.GetClientExtent;
      Dec(FClientWidth, R.Left + R.Right);
    end
  else
    FClientWidth := 0;
  Result := 0;
  for I := 0 to ARowCount - 1 do
  begin
    H := 0;
    MeasureItem(I, H);
    Inc(Result, H);
  end;
  if Properties.MultiLineText then
  begin
    FHasScrollbar := (Result > AMaxHeight) or (ARowCount < Items.Count);
    if FHasScrollbar then
    begin
      Dec(FClientWidth, GetScrollBarSize.cx);
      Result := 0;
      for I := 0 to ARowCount - 1 do
      begin
        H := 0;
        MeasureItem(I, H);
        Inc(Result, H);
      end;
    end;
  end;
end;

function TcxImageComboBoxListBox.GetItemWidth(AIndex: Integer): Integer;
begin
  if Properties.MultiLineText then
    Result := 0
  else
    Result := inherited GetItemWidth(AIndex);
end;

procedure TcxImageComboBoxListBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Flags: Longint;
  Data: string;
  AImages: TCustomImageList;
  R: TRect;
  AImageIndex: Integer;
begin
  if not DoDrawItem(Index, Rect, State) then
  begin
    Canvas.FillRect(Rect);
    if (Index < Items.Count) and (Index > -1) then
    begin
      if Properties.MultiLineText then
        Flags := DrawTextBiDiModeFlags(DT_LEFT or DT_EXPANDTABS or
          DT_NOPREFIX or DT_WORDBREAK)
      else
        Flags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or
          DT_NOPREFIX);
      if not UseRightToLeftAlignment then
        Inc(Rect.Left, 2)
      else
        Dec(Rect.Right, 2);
      Data := Properties.Items[Index].Description;
      AImages := GetImages;
      if AImages <> nil then
      begin
        R := GetImageRect(Rect);
        AImageIndex := Properties.Items[Index].ImageIndex;
        if (AImageIndex > -1) and (AImageIndex < AImages.Count) then
          with R do
            AImages.Draw(Canvas.Canvas, Left + 1, (Bottom + Top - AImages.Height) div 2,
              AImageIndex, Enabled);
        if R.Left > Rect.Left then Rect.Right := R.Left;
        if R.Right < Rect.Right then Rect.Left := R.Right;
      end;
      if not IsRectEmpty(Rect) then
      begin
        SetBkMode(Handle, TRANSPARENT);
        DrawText(Canvas.Handle, PChar(Data), Length(Data), Rect, Flags);
      end;
    end;
  end;
end;

procedure TcxImageComboBoxListBox.MeasureItem(Index: Integer; var Height: Integer);
var
  AData: string;
  AImages: TCustomImageList;
  W, H, AFlags: Integer;
  R: TRect;
begin
  W := FClientWidth - 2;
  AImages := GetImages;
  if AImages <> nil then
  begin
    Dec(W, AImages.Width + 4);
    H := AImages.Height + 2;
  end
  else
    H := 0;
  if Properties.MultiLineText and (W > 0) then
  begin
    R := Rect(0, 0, W, H);
    AData := Properties.Items[Index].Description;
    AFlags := DT_LEFT or DT_EXPANDTABS or DT_NOPREFIX or DT_WORDBREAK or DT_CALCRECT;
    DrawText(Canvas.Handle, PChar(AData), Length(AData), R, AFlags);
    H := Max(H, R.Bottom - R.Top + 2);
  end
  else
    H := Max(Canvas.TextHeight('Wg') + 2, H);
  Height := H;
  if (Index >= 0) and Edit.IsOnMeasureItemEventAssigned then
    Edit.DoOnMeasureItem(Index, Canvas, Height);
end;

procedure TcxImageComboBoxListBox.RecreateWindow;
begin
  InternalRecreateWindow;
end;

function TcxImageComboBoxListBox.GetImageRect(const R: TRect): TRect;
var
  AImages: TCustomImageList;
begin
  AImages := GetImages;
  if AImages <> nil then
    with Properties do
    begin
      Result := R;
      with Result do
        if ImageAlign = iaLeft then
          Right := Left + AImages.Width + 4
        else
          Left := Right - AImages.Width - 4;
    end
    else
      Result := EmptyRect;
end;

function TcxImageComboBoxListBox.GetImages: TCustomImageList;
begin
  Result := Properties.LargeImages;
  if Result = nil then Result := Properties.Images;
end;

function TcxImageComboBoxListBox.GetMaxItemWidth: Integer;
var
  AImages: TCustomImageList;
  I, W, J: Integer;
begin
  AImages := GetImages;
  if AImages <> nil then Result := AImages.Width + 8 else Result := 4;
  with Properties do
  begin
    J := Result;
    for I := 0 to Items.Count - 1 do
    begin
      W := Canvas.TextWidth(Items[I].Description) + J;
      if W > Result then Result := W;
    end;
  end;
  if Properties.DropDownRows < Items.Count then
    Inc(Result, GetScrollBarSize.cx);
end;

function TcxImageComboBoxListBox.GetEdit: TcxCustomImageComboBox;
begin
  Result := TcxCustomImageComboBox(inherited Edit);
end;

function TcxImageComboBoxListBox.GetProperties: TcxCustomImageComboBoxProperties;
begin
  Result := TcxCustomImageComboBox(Edit).ActiveProperties;
end;

{ TcxImageComboBoxLookupData }

function TcxImageComboBoxLookupData.GetListBoxClass: TcxCustomEditListBoxClass;
begin
  Result := TcxImageComboBoxListBox;
end;

function TcxImageComboBoxLookupData.GetItem(Index: Integer): string;
begin
  with TcxCustomImageComboBox(Edit).ActiveProperties do
    if (Index > -1) and (Index < Items.Count) then
      Result := Items[Index].Description
    else
      Result := ''
end;

function TcxImageComboBoxLookupData.GetItemCount: Integer;
begin
  Result := TcxCustomImageComboBox(Edit).ActiveProperties.Items.Count;
end;

function TcxImageComboBoxLookupData.GetList: TcxImageComboBoxListBox;
begin
  Result := TcxImageComboBoxListBox(inherited List);
end;

procedure TcxImageComboBoxLookupData.TextChanged;
var
  AItem: TcxImageComboBoxItem;
begin
  if TcxCustomImageComboBox(Edit).EditModeSetting then
    Exit;
  with TcxCustomImageComboBoxProperties(ActiveProperties) do
    AItem := FindItemByValue(Edit.EditValue);
  if AItem <> nil then
    InternalSetCurrentKey(AItem.Index)
  else
    InternalSetCurrentKey(-1);
end;

{ TcxImageComboBoxViewData }

procedure TcxImageComboBoxViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  R: TRect;
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo,
    AIsMouseEvent);

  with TcxImageComboBoxViewInfo(AViewInfo) do
  begin
    ImageAlign := TcxCustomImageComboBoxProperties(Properties).ImageAlign;
    Images := TcxCustomImageComboBoxProperties(Properties).Images;
    ShowDescriptions := TcxCustomImageComboBoxProperties(Properties).ShowDescriptions;
    R := ClientRect;
    if Assigned(Images) then
    begin
      ImageRect := cxRectInflate(R, -2, 0);
      with ImageRect do
      begin
        if cxRectWidth(ImageRect) > Images.Width then
        begin
          if ShowDescriptions then
            if ImageAlign = iaLeft then
            begin
              Right := Left + Images.Width;
              R.Left := Right + 2;
            end
            else
            begin
              Left := Right - Images.Width;
              R.Right := Left - 2;
            end
          else
          begin
            Left := Left + (Right - Left - Images.Width) div 2;
            Right := Left + Images.Width;
          end;
        end
        else
          R.Left := R.Right;
        if cxRectHeight(ImageRect) > Images.Height then
        begin
          Top := Top + (Bottom - Top - Images.Height) div 2;
          Bottom := Top + Images.Height;
        end;
      end;
    end;

    if not IsInplace then
      ClientRect := R;
    InflateRect(R, -2, -1);
    TextRect := R;
    if not ShowDescriptions then
      Text := '';
    if not IsInplace then
      DrawSelectionBar := False;
  end;
end;

procedure TcxImageComboBoxViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  AText: string;
  ACaption: TCaption;
  AImageIndex: TImageIndex;
begin
  PrepareSelection(AViewInfo);
  Properties.GetImageComboBoxDisplayValue(AEditValue, ACaption, AImageIndex);
  TcxImageComboBoxViewInfo(AViewInfo).ImageIndex := AImageIndex;
  AText := ACaption;
  DoOnGetDisplayText(AText);
  TcxImageComboBoxViewInfo(AViewInfo).Text := AText;
end;

procedure TcxImageComboBoxViewData.DisplayValueToDrawValue(
  const ADisplayValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  ACurrentKey: TcxEditValue;
  AItem: TcxImageComboBoxItem;
  ACaption: TCaption;
  AImageIndex: TImageIndex;
begin
  if Edit = nil then
    Exit;
  ACurrentKey := TcxCustomImageComboBox(Edit).ILookupData.CurrentKey;
  if ACurrentKey = -1 then
    AItem := Properties.FindItemByValue(Edit.EditValue)
  else
    AItem := Properties.Items[ACurrentKey];
  Properties.InternalGetImageComboBoxDisplayValue(AItem, ACaption, AImageIndex);
  TcxImageComboBoxViewInfo(AViewInfo).Text := ACaption;
  TcxImageComboBoxViewInfo(AViewInfo).ImageIndex := AImageIndex;
end;

function TcxImageComboBoxViewData.InternalEditValueToDisplayText(
  AEditValue: TcxEditValue): string;
var
  AIndex: TImageIndex;
  ACaption: TCaption;
begin
  Properties.GetImageComboBoxDisplayValue(AEditValue,
    ACaption, AIndex);
  Result := ACaption;  
end;

function TcxImageComboBoxViewData.InternalGetEditConstantPartSize(
  ACanvas: TcxCanvas; AIsInplace: Boolean;
  AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
  AViewInfo: TcxCustomEditViewInfo): TSize;
begin
  Result := inherited InternalGetEditConstantPartSize(ACanvas, AIsInplace,
    AEditSizeProperties, MinContentSize, AViewInfo);
  with TcxCustomImageComboBoxProperties(Properties) do
  begin
    if Assigned(Images) then
    begin
      if Images.Height > MinContentSize.cy then
        MinContentSize.cy := Images.Height;
      Result.cx := Result.cx + Images.Width + 5;
    end
    else
      Result.cx := Result.cx + 1;
  end;
end;

function TcxImageComboBoxViewData.IsComboBoxStyle: Boolean;
begin
  Result := IsCompositionEnabled;
end;

function TcxImageComboBoxViewData.GetProperties: TcxCustomImageComboBoxProperties;
begin
  Result := TcxCustomImageComboBoxProperties(FProperties);
end;

{ TcxImageComboBoxViewInfo }

procedure TcxImageComboBoxViewInfo.Offset(DX, DY: Integer);
begin
  inherited Offset(DX, DY);
  OffsetRect(ImageRect, DX, DY);
end;

procedure TcxImageComboBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
var
  R: TRect;
begin
  if not RectVisible(ACanvas.Handle, Bounds) then
    Exit;
  inherited InternalPaint(ACanvas);
  if Assigned(Images) and (ImageIndex > -1) and (ImageIndex < Images.Count) then
  begin
    ACanvas.SaveClipRegion;
    try
      IntersectRect(R, ImageRect, BorderRect);
      ACanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);

      if Transparent or IsCompositionEnabled and NativeStyle then
        Images.Draw(ACanvas.Canvas, ImageRect.Left, ImageRect.Top,
          ImageIndex, Enabled)
      else
        cxEditUtils.DrawGlyph(ACanvas,
          Images, ImageIndex, ImageRect, BackgroundColor, Enabled);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;
end;

{ TcxCustomImageComboBoxProperties }

constructor TcxCustomImageComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FShowDescriptions := True;
  FDefaultImageIndex := -1;
  FImageAlign := iaLeft;
  FItems := TcxImageComboBoxItems.Create(Self);
  DropDownListStyle := lsFixedList;
  FImagesChangeLink := TChangeLink.Create;
  FImagesChangeLink.OnChange := ImagesChange;
  FLargeImagesChangeLink := TChangeLink.Create;
  FLargeImagesChangeLink.OnChange := LargeImagesChange;
end;

destructor TcxCustomImageComboBoxProperties.Destroy;
begin
  FImagesChangeLink.Free;
  FLargeImagesChangeLink.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TcxCustomImageComboBoxProperties.ImagesChange(Sender: TObject);
begin
  Changed;
end;

procedure TcxCustomImageComboBoxProperties.LargeImagesChange(Sender: TObject);
begin
  Changed;
end;

procedure TcxCustomImageComboBoxProperties.SetDefaultDescription(
  const Value: string);
begin
  if FDefaultDescription <> Value then
  begin
    FDefaultDescription := Value;
    Changed;
  end;
end;

procedure TcxCustomImageComboBoxProperties.SetDefaultImageIndex(
  const Value: TImageIndex);
begin
  if FDefaultImageIndex <> Value then
  begin
    FDefaultImageIndex := Value;
    Changed;
  end;
end;

procedure TcxCustomImageComboBoxProperties.SetImageAlign(
  const Value: TcxImageAlign);
begin
  if FImageAlign <> Value then
  begin
    FImageAlign := Value;
    Changed;
  end;
end;

procedure TcxCustomImageComboBoxProperties.SetImages(Value: TCustomImageList);
begin
  cxSetImageList(Value, FImages, FImagesChangeLink, FreeNotificator);
end;

procedure TcxCustomImageComboBoxProperties.SetLargeImages(Value: TCustomImageList);
begin
  cxSetImageList(Value, FLargeImages, FLargeImagesChangeLink, FreeNotificator);
end;

procedure TcxCustomImageComboBoxProperties.SetItems(
  const Value: TcxImageComboBoxItems);
begin
  FItems.Assign(Value);
  Changed;
end;

procedure TcxCustomImageComboBoxProperties.SetMultiLineText(
  const Value: Boolean);
begin
  if FMultiLineText <> Value then
  begin
    FMultiLineText := Value;
    Changed;
  end;
end;

procedure TcxCustomImageComboBoxProperties.SetShowDescriptions(
  const Value: Boolean);
begin
  if FShowDescriptions <> Value then
  begin
    FShowDescriptions := Value;
    Changed;
  end;
end;

function TcxCustomImageComboBoxProperties.FindItemByText(const AText: string):
  TcxImageComboBoxItem;
var
  I: Integer;
begin
  Result := nil;
  if ShowDescriptions then
    for I := 0 to Items.Count - 1 do
      if InternalCompareString(Items[I].Description, AText, False) then
      begin
        Result := Items[I];
        Break;
      end;
end;

function TcxCustomImageComboBoxProperties.FindLookupText(const AText: string): Boolean;
begin
  Result := FindItemByText(AText) <> nil;
end;

procedure TcxCustomImageComboBoxProperties.FreeNotification(Sender: TComponent);
begin
  inherited FreeNotification(Sender);
  if Sender = FImages then
    FImages := nil;
  if Sender = FLargeImages then
    FLargeImages := nil;
end;

function TcxCustomImageComboBoxProperties.GetDisplayFormatOptions: TcxEditDisplayFormatOptions;
begin
  Result := [];
end;

class function TcxCustomImageComboBoxProperties.GetLookupDataClass: TcxInterfacedPersistentClass;
begin
  Result := TcxImageComboBoxLookupData;
end;

class function TcxCustomImageComboBoxProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxImageComboBoxViewData;
end;

function TcxCustomImageComboBoxProperties.HasDisplayValue: Boolean;
begin
  Result := False;
end;

procedure TcxCustomImageComboBoxProperties.InternalGetImageComboBoxDisplayValue(
  AItem: TcxImageComboBoxItem; out AText: TCaption; out AImageIndex: TImageIndex;
  AAlwaysShowDescription: Boolean = False);
begin
  if AAlwaysShowDescription or ShowDescriptions then
    if AItem = nil then
      AText := DefaultDescription
    else
      AText := AItem.Description
  else
    AText := '';
  if AItem = nil then
    AImageIndex := DefaultImageIndex
  else
    AImageIndex := AItem.ImageIndex;
end;

procedure TcxCustomImageComboBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomImageComboBoxProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxCustomImageComboBoxProperties(Source) do
      begin
        Self.DefaultDescription := DefaultDescription;
        Self.DefaultImageIndex := DefaultImageIndex;
        Self.ImageAlign := ImageAlign;
        Self.Images := Images;
        Self.Items.Assign(Items);
        Self.LargeImages := LargeImages;
        Self.MultiLineText := MultiLineText;
        Self.ShowDescriptions := ShowDescriptions;
      end;
    finally
      EndUpdate
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomImageComboBoxProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
var
  AImageIndex1, AImageIndex2: TImageIndex;
  AText1, AText2: TCaption;
begin
  GetImageComboBoxDisplayValue(AEditValue1, AText1, AImageIndex1);
  GetImageComboBoxDisplayValue(AEditValue2, AText2, AImageIndex2);
  Result := InternalCompareString(AText1, AText2, True) and ((Images = nil) or
    (AImageIndex1 = AImageIndex2));
end;

function TcxCustomImageComboBoxProperties.FindItemByValue(
  const AValue: Variant): TcxImageComboBoxItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Items.Count - 1 do
    with Items[I] do
      if VarEqualsExact(AValue, Value) then
      begin
        Result := Items[I];
        Break;
      end;
end;

class function TcxCustomImageComboBoxProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxImageComboBox;
end;

function TcxCustomImageComboBoxProperties.GetDisplayText(
 const AEditValue: TcxEditValue; AFullText: Boolean = False;
 AIsInplace: Boolean = True): WideString;
var
  ADisplayValue: TcxEditValue;
begin
  PrepareDisplayValue(AEditValue, ADisplayValue, False);
  Result := ADisplayValue;
end;

function TcxCustomImageComboBoxProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsValue;
end;

procedure TcxCustomImageComboBoxProperties.GetImageComboBoxDisplayValue(
  const AEditValue: TcxEditValue; out AText: TCaption;
  out AImageIndex: TImageIndex);
begin
  InternalGetImageComboBoxDisplayValue(FindItemByValue(AEditValue), AText,
    AImageIndex);
end;

function TcxCustomImageComboBoxProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoEditing, esoFiltering, esoHorzAlignment, esoSorting,
    esoSortingByDisplayText];
  if Buttons.Count > 0 then
    Include(Result, esoHotTrack);
  if ShowDescriptions then
    Include(Result, esoIncSearch);
end;

class function TcxCustomImageComboBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxImageComboBoxViewInfo;
end;

function TcxCustomImageComboBoxProperties.IsEditValueValid(
  var AEditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := True;
end;

procedure TcxCustomImageComboBoxProperties.PrepareDisplayValue(
  const AEditValue: TcxEditValue; var DisplayValue: TcxEditValue;
  AEditFocused: Boolean);
var
  AImageIndex: TImageIndex;
  AText: TCaption;
begin
  InternalGetImageComboBoxDisplayValue(FindItemByValue(AEditValue), AText,
    AImageIndex, True);
  DisplayValue := AText;
end;

{ TcxCustomImageComboBox }

function TcxCustomImageComboBox.GetProperties: TcxCustomImageComboBoxProperties;
begin
  Result := TcxCustomImageComboBoxProperties(FProperties);
end;

function TcxCustomImageComboBox.GetActiveProperties: TcxCustomImageComboBoxProperties;
begin
  Result := TcxCustomImageComboBoxProperties(InternalGetActiveProperties);
end;

function TcxCustomImageComboBox.GetLookupData: TcxImageComboBoxLookupData;
begin
  Result := TcxImageComboBoxLookupData(inherited LookupData);
end;

procedure TcxCustomImageComboBox.SetProperties(const Value: TcxCustomImageComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

function TcxCustomImageComboBox.IsValidChar(AChar: Char): Boolean;
begin
  Result := IsTextChar(AChar);
end;

function TcxCustomImageComboBox.GetItemObject: TObject;
begin
  Result := nil;
end;

function TcxCustomImageComboBox.GetPopupWindowClientPreferredSize: TSize;
begin
  Result := inherited GetPopupWindowClientPreferredSize;
  if not ActiveProperties.MultiLineText then
  begin
    if (LookupData.ActiveControl <> nil) and (LookupData.ActiveControl is TcxImageComboBoxListBox) then
      with TcxImageComboBoxListBox(LookupData.ActiveControl) do
        Result.cx := Max(GetMaxItemWidth, Result.cx);
  end
  else
  begin
    Result.cx := 0;
    if LookupData <> nil then
      LookupData.List.RecreateWindow;
  end;
end;

function TcxCustomImageComboBox.InternalGetEditingValue: TcxEditValue;
begin
  PrepareEditValue(Null, Result, True);
end;

function TcxCustomImageComboBox.LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue;
begin
  if not VarEqualsExact(AKey, -1) then
    Result := ActiveProperties.Items[AKey].Value
  else
    Result := Null;
end;

procedure TcxCustomImageComboBox.SynchronizeDisplayValue;
var
  APrevLookupKey: TcxEditValue;
begin
  SaveModified;
  try
    APrevLookupKey := ILookupData.CurrentKey;
    LockClick(True);
    try
      ILookupData.TextChanged;
    finally
      LockClick(False);
      if (*ModifiedAfterEnter and *)not VarEqualsExact(APrevLookupKey, ILookupData.CurrentKey) then
        DoClick;
    end;
  finally
    RestoreModified;
    ResetOnNewDisplayValue;
    UpdateDrawValue;
  end;
end;

procedure TcxCustomImageComboBox.UpdateDrawValue;
begin
  inherited UpdateDrawValue;
  SetInternalDisplayValue(ViewInfo.Text);
end;

class function TcxCustomImageComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomImageComboBoxProperties;
end;

procedure TcxCustomImageComboBox.PrepareEditValue(
  const ADisplayValue: TcxEditValue; out EditValue: TcxEditValue;
  AEditFocused: Boolean);
begin
  if VarEqualsExact(LookupData.CurrentKey, -1) then
    EditValue := Null
  else
    EditValue := ActiveProperties.Items[LookupData.CurrentKey].Value;
end;

{ TcxImageComboBox }

class function TcxImageComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxImageComboBoxProperties;
end;

function TcxImageComboBox.GetActiveProperties: TcxImageComboBoxProperties;
begin
  Result := TcxImageComboBoxProperties(InternalGetActiveProperties);
end;

function TcxImageComboBox.GetProperties: TcxImageComboBoxProperties;
begin
  Result := TcxImageComboBoxProperties(FProperties);
end;

procedure TcxImageComboBox.SetProperties(Value: TcxImageComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterImageComboBoxHelper }

class function TcxFilterImageComboBoxHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxImageComboBox;
end;

class function TcxFilterImageComboBoxHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then
    Result := Result + [fcoInList, fcoNotInList];
end;

class procedure TcxFilterImageComboBoxHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  TcxImageComboBoxProperties(AProperties).DropDownListStyle := lsFixedList;
  TcxImageComboBoxProperties(AProperties).ImmediateDropDown := True;
  TcxImageComboBoxProperties(AProperties).ShowDescriptions := True;
end;

initialization
  GetRegisteredEditProperties.Register(TcxImageComboBoxProperties, scxSEditRepositoryImageComboBoxItem);
  FilterEditsController.Register(TcxImageComboBoxProperties, TcxFilterImageComboBoxHelper);

finalization
  FilterEditsController.Unregister(TcxImageComboBoxProperties, TcxFilterImageComboBoxHelper);
  
end.

