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

unit cxImage;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  Windows, Messages, ExtDlgs, SysUtils, Classes, Clipbrd, Controls, Dialogs,
  ExtCtrls, Forms, Graphics, Menus, StdCtrls, cxClasses, cxContainer,
  cxControls, cxDataUtils, cxEdit, cxEditConsts, cxGraphics, cxLookAndFeels, dxCore;

const
  cxImageDefaultInplaceHeight = 15;

type
  TcxCustomImage = class;
  TcxPopupMenuItem = (pmiCut, pmiCopy, pmiPaste, pmiDelete, pmiLoad, pmiSave,
    pmiCustom);
  TcxPopupMenuItemClick = procedure(Sender: TObject;
    MenuItem: TcxPopupMenuItem) of object;
  TcxPopupMenuItems = set of TcxPopupMenuItem;

  { TcxPopupMenuLayout }

  TcxPopupMenuLayout = class(TPersistent)
  private
    FCustomMenuItemCaption: string;
    FCustomMenuItemGlyph: TBitmap;
    FImage: TcxCustomImage;
    FMenuItems: TcxPopupMenuItems;
    function GetCustomMenuItemGlyph: TBitmap; virtual;
    procedure SetCustomMenuItemGlyph(Value: TBitmap);
  public
    constructor Create(AImage: TcxCustomImage);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property MenuItems: TcxPopupMenuItems read FMenuItems write FMenuItems default
      [pmiCut, pmiCopy, pmiPaste, pmiDelete, pmiLoad, pmiSave];
    property CustomMenuItemCaption: string
      read FCustomMenuItemCaption write FCustomMenuItemCaption;
    property CustomMenuItemGlyph: TBitmap
      read GetCustomMenuItemGlyph write SetCustomMenuItemGlyph;
  end;

  { TcxImageViewInfo }

  TcxImageViewInfo = class(TcxCustomEditViewInfo)
  private
    FFreePicture: Boolean;
    FTempBitmap: TBitmap;
    procedure DrawTransparentBackground(ACanvas: TcxCanvas; const R: TRect);
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
    function IsRepaintOnStateChangingNeeded: Boolean; override;
  public
    ShowFocusRect: Boolean;
    TopLeft: TPoint;
    Caption: string;
    Center: Boolean;
    Picture: TPicture;
    Proportional: Boolean;
    Stretch: Boolean;
    destructor Destroy; override;
  end;

  { TcxImageViewData }

  TcxImageViewData = class(TcxCustomEditViewData)
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    function GetEditContentSize(ACanvas: TcxCanvas;
      const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;
  end;

  { TcxCustomImageProperties }

  TcxImageAssignPictureEvent = procedure(Sender: TObject;
    const Picture: TPicture) of object;
  TcxImageGraphicClassEvent = procedure(AItem: TObject; ARecordIndex: Integer;
    APastingFromClipboard: Boolean; var AGraphicClass: TGraphicClass) of object;
  TcxImageEditGraphicClassEvent = procedure(Sender: TObject;
    APastingFromClipboard: Boolean; var AGraphicClass: TGraphicClass) of object;

  TcxImageTransparency = (gtDefault, gtOpaque, gtTransparent);

  TcxCustomImageProperties = class(TcxCustomEditProperties)
  private
    FCaption: string;
    FCenter: Boolean;
    FCustomFilter: string;
    FDefaultHeight: Integer;
    FGraphicClass: TGraphicClass;
    FGraphicTransparency: TcxImageTransparency;
    FPopupMenuLayout: TcxPopupMenuLayout;
    FProportional: Boolean;
    FShowFocusRect: Boolean;
    FStretch: Boolean;
    FOnAssignPicture: TcxImageAssignPictureEvent;
    FOnCustomClick: TNotifyEvent;
    FOnGetGraphicClass: TcxImageGraphicClassEvent;
    function GetGraphicClassName: string;
    function IsGraphicClassNameStored: Boolean;
    procedure ReadIsGraphicClassNameEmpty(Reader: TReader);
    procedure SetCaption(const Value: string);
    procedure SetCenter(Value: Boolean);
    procedure SetGraphicClass(const Value: TGraphicClass);
    procedure SetGraphicClassName(const Value: string);
    procedure SetGraphicTransparency(Value: TcxImageTransparency);
    procedure SetPopupMenuLayout(Value: TcxPopupMenuLayout);
    procedure SetProportional(AValue: Boolean);
    procedure SetShowFocusRect(Value: Boolean);
    procedure SetStretch(Value: Boolean);
    procedure WriteIsGraphicClassNameEmpty(Writer: TWriter);
  protected
    function CanValidate: Boolean; override;
    procedure DefineProperties(Filer: TFiler); override;
    function IsDesigning: Boolean;
    function GetDefaultGraphicClass: TGraphicClass; virtual;
    function GetRealStretch(const APictureSize, ABoundsSize: TSize): Boolean;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    property DefaultHeight: Integer read FDefaultHeight write FDefaultHeight
      default cxImageDefaultInplaceHeight;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    function GetGraphicClass(AItem: TObject;
      ARecordIndex: Integer;
      APastingFromClipboard: Boolean = False): TGraphicClass; virtual;
    function GetSpecialFeatures: TcxEditSpecialFeatures; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsResetEditClass: Boolean; override;
    procedure ValidateDisplayValue(var DisplayValue: TcxEditValue; var ErrorText: TCaption;
      var Error: Boolean; AEdit: TcxCustomEdit); override;
    property GraphicClass: TGraphicClass read FGraphicClass write SetGraphicClass;
    // !!!
    property Caption: string read FCaption write SetCaption;
    property Center: Boolean read FCenter write SetCenter default True;
    property CustomFilter: string read FCustomFilter write FCustomFilter;
    property GraphicClassName: string read GetGraphicClassName
      write SetGraphicClassName stored IsGraphicClassNameStored;
    property GraphicTransparency: TcxImageTransparency
      read FGraphicTransparency write SetGraphicTransparency default gtDefault;
    property PopupMenuLayout: TcxPopupMenuLayout
      read FPopupMenuLayout write SetPopupMenuLayout;
    property Proportional: Boolean read FProportional write SetProportional default True;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default True;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property OnAssignPicture: TcxImageAssignPictureEvent
      read FOnAssignPicture write FOnAssignPicture;
    property OnCustomClick: TNotifyEvent read FOnCustomClick
      write FOnCustomClick;
    property OnGetGraphicClass: TcxImageGraphicClassEvent read FOnGetGraphicClass
      write FOnGetGraphicClass;
  end;

  { TcxImageProperties }

  TcxImageProperties = class(TcxCustomImageProperties)
  published
    property AssignedValues;
    property Caption;
    property Center;
    property ClearKey;
    property CustomFilter;
    property GraphicClassName;
    property GraphicTransparency;
    property ImmediatePost;
    property PopupMenuLayout;
    property Proportional;
    property ReadOnly;
    property ShowFocusRect;
    property Stretch;
    property OnAssignPicture;
    property OnChange;
    property OnCustomClick;
    property OnEditValueChanged;
    property OnGetGraphicClass;
  end;

  { TcxCustomImage }

  TcxCustomImage = class(TcxCustomEdit)
  private
    FClipboardFormat: Word;
    FEditPopupMenu: TPopupMenu;
    FInternalChanging: Boolean;
    FIsDialogShowed: Boolean;
    FPicture: TPicture;
    FTransparent: Boolean;
    FOnGetGraphicClass: TcxImageEditGraphicClassEvent;
    procedure EditAndClear;
    procedure EditPopupMenuClick(Sender: TObject);
  {$IFDEF CBUILDER10}
    function GetPicture: TPicture;
  {$ENDIF}
    function GetProperties: TcxCustomImageProperties;
    function GetActiveProperties: TcxCustomImageProperties;
    procedure MenuItemClick(Sender: TObject; MenuItem: TcxPopupMenuItem);
    procedure PictureChanged(Sender: TObject);
    procedure PreparePopup;
    procedure ResetImage;
    procedure SetPicture(Value: TPicture);
    procedure SetProperties(const Value: TcxCustomImageProperties);
    procedure SetTransparent(AValue: Boolean);
    procedure SynchronizeImage;
  protected
    function CanAutoSize: Boolean; override;
    function CanAutoWidth: Boolean; override;
    procedure DoContextPopup( MousePos: TPoint;
      var Handled: Boolean); override;
    procedure Initialize; override;
    procedure InitScrollBarsParameters; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function NeedsInvokeAfterKeyDown(AKey: Word; AShift: TShiftState): Boolean; override;
    function NeedsScrollBars: Boolean; override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    function GetEditValue: TcxEditValue; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AIsValueValid: Boolean); override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure UpdateScrollBars; override;

    // virtual methods
    function CanPasteFromClipboard: Boolean; virtual;
    procedure CustomClick; virtual;
    procedure DoOnAssignPicture;
    function GetGraphicClass(APastingFromClipboard: Boolean = False): TGraphicClass; virtual;
    property AutoSize default False;
    property ParentColor default False;
    property OnGetGraphicClass: TcxImageEditGraphicClassEvent
      read FOnGetGraphicClass write FOnGetGraphicClass;
  public
    destructor Destroy; override;
    procedure CopyToClipboard; override;
    procedure CutToClipboard; override;
    function Focused: Boolean; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure LoadFromFile;
    procedure PasteFromClipboard; override;
    procedure SaveToFile;
    property ActiveProperties: TcxCustomImageProperties read GetActiveProperties;
    property ClipboardFormat: Word
      read FClipboardFormat write FClipboardFormat;
    property Picture: TPicture read {$IFDEF CBUILDER10}GetPicture{$ELSE}FPicture{$ENDIF}
      write SetPicture;
    property Properties: TcxCustomImageProperties read GetProperties
      write SetProperties;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;

  { TcxImage }

  TcxImage = class(TcxCustomImage)
  private
    function GetActiveProperties: TcxImageProperties;
    function GetProperties: TcxImageProperties;
    procedure SetProperties(Value: TcxImageProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxImageProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property Picture;
    property PopupMenu;
    property Properties: TcxImageProperties read GetProperties
      write SetProperties;
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
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetGraphicClass;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

function IsPictureEmpty(APicture: TPicture): Boolean;
procedure LoadPicture(APicture: TPicture; AGraphicClass: TGraphicClass;
  const AValue: Variant);
procedure SavePicture(APicture: TPicture; var AValue: AnsiString);

function GetGraphicClassByName(const AClassName: string): TGraphicClass;
function GetRegisteredGraphicClasses: TList;
procedure RegisterGraphicClass(AGraphicClass: TGraphicClass);
procedure UnRegisterGraphicClass(AGraphicClass: TGraphicClass);

implementation

uses
{$IFNDEF DELPHI6}
  cxVariants,
{$ENDIF}
{$IFDEF USEJPEGIMAGE}
  Jpeg,
{$ENDIF}
  dxGDIPlusApi, dxGDIPlusClasses, cxGeometry,
  Math, ImgList, cxEditUtils;

type
  {$IFNDEF DELPHI6}
  TDummyGraphic = class(TGraphic);
  TDummyGraphicClass = class of TDummyGraphic;
  {$ENDIF}
  TMemoryStreamAccess = class(TMemoryStream);
  {$IFDEF USEJPEGIMAGE}
  TJPEGImageAccess = class(TJPEGImage);
  {$ENDIF}

var
  cxGraphicPopupMenuImages: TImageList;
  cxRegisteredGraphicClasses: TList;

function GetGraphicClassByName(const AClassName: string): TGraphicClass;
var
  I: Integer;
begin
  Result := nil;
  for i := 0 to GetRegisteredGraphicClasses.Count - 1 do
    if InternalCompareString(AClassName, TClass(GetRegisteredGraphicClasses[I]).ClassName, False) then
    begin
      Result := TGraphicClass(GetRegisteredGraphicClasses[I]);
      Break;
    end;
end;

function GetRegisteredGraphicClasses: TList;
begin
  if cxRegisteredGraphicClasses = nil then
  begin
    cxRegisteredGraphicClasses := TList.Create;
    RegisterGraphicClass(TBitmap);
    RegisterGraphicClass(TIcon);
    RegisterGraphicClass(TMetaFile);
    if GetClass(TdxPNGImage.ClassName) <> nil then
      RegisterGraphicClass(TdxPNGImage);
  {$IFDEF USEJPEGIMAGE}
    RegisterGraphicClass(TJpegImage);
  {$ENDIF}
  end;
  Result := cxRegisteredGraphicClasses
end;

procedure RegisterGraphicClass(AGraphicClass: TGraphicClass);
begin
  if cxRegisteredGraphicClasses.IndexOf(TObject(AGraphicClass)) = -1 then
    cxRegisteredGraphicClasses.Add(TObject(AGraphicClass));
end;

procedure UnRegisterGraphicClass(AGraphicClass: TGraphicClass);
var
  I: Integer;
begin
  I := cxRegisteredGraphicClasses.IndexOf(TObject(AGraphicClass));
  if I <> -1 then
    cxRegisteredGraphicClasses.Delete(I);
end;

procedure CalcStretchRect(R: TRect; W, H: Integer; out CalcRect: TRect);
var
  W1, H1: Integer;
begin
  if IsRectEmpty(R) then
  begin
    CalcRect := R;
    Exit;
  end;
  CalcRect.TopLeft := R.TopLeft;
  W1 := R.Right - R.Left;
  H1 := R.Bottom - R.Top;
  if W / H > W1 / H1 then
  begin
    CalcRect.Right := R.Right;
    CalcRect.Bottom := CalcRect.Top + (W1 * H div W);
  end
  else
  begin
    CalcRect.Bottom := R.Bottom;
    CalcRect.Right := CalcRect.Left + (H1 * W div H);
  end;
end;

function IsPictureEmpty(APicture: TPicture): Boolean;
begin
  Result := not Assigned(APicture.Graphic) or APicture.Graphic.Empty;
end;

function cxVarIsBlob(const V: Variant): Boolean;
begin
  Result := VarIsStr(V) or VarIsArray(V); // Field.Value -> stored as string and as array of byte 
end;

procedure LoadPicture(APicture: TPicture; AGraphicClass: TGraphicClass;
  const AValue: Variant);
{ Paradox graphic BLOB header - see DB.pas}
type
  TGraphicHeader = record
    Count: Word;                { Fixed at 1 }
    HType: Word;                { Fixed at $0100 }
    Size: Longint;              { Size not including header }
  end;
var
  AGraphic: TGraphic;
  AHeader: TGraphicHeader;
  ASize: Longint;
  AStream: TMemoryStream;
  AValueAsString: AnsiString;
begin
  if cxVarIsBlob(AValue) then
  begin
    AStream := TMemoryStream.Create;
    try
      AValueAsString := dxVariantToAnsiString(AValue);
      ASize := Length(AValueAsString);
      if ASize >= SizeOf(AHeader) then
      begin
        TMemoryStreamAccess(AStream).SetPointer(@AValueAsString[1], ASize);
        AStream.Position := 0;
        AStream.Read(AHeader, SizeOf(AHeader));
        if (AHeader.Count <> 1) or (AHeader.HType <> $0100) or
          (AHeader.Size <> ASize - SizeOf(AHeader)) then
          AStream.Position := 0;
      end;
      if AStream.Size > 0 then
        try
          if AGraphicClass = nil then
            APicture.Bitmap.LoadFromStream(AStream)
          else
          begin
            AGraphic := {$IFNDEF DELPHI6}TDummyGraphicClass{$ENDIF}(AGraphicClass).Create;
            try
              AGraphic.LoadFromStream(AStream);
              APicture.Graphic := AGraphic;
            finally
              AGraphic.Free;
            end;
          end;
        except
          APicture.Assign(nil);
        end
      else
        APicture.Assign(nil);
    finally
      AStream.Free;
    end;
  end
  else
    APicture.Assign(nil);
end;

procedure SavePicture(APicture: TPicture; var AValue: AnsiString);
var
  AStream: TMemoryStream;
begin
  if not Assigned(APicture) or IsPictureEmpty(APicture) then
    AValue := ''
  else
  begin
    AStream := TMemoryStream.Create;
    try
      APicture.Graphic.SaveToStream(AStream);
      AStream.Position := 0;
      SetLength(AValue, AStream.Size);
      AStream.ReadBuffer(AValue[1], AStream.Size);
    finally
      AStream.Free;
    end;
  end;
end;

{ TcxPopupMenuLayout }

constructor TcxPopupMenuLayout.Create(AImage: TcxCustomImage);
begin
  inherited Create;
  FImage := AImage;
  FMenuItems := [pmiCut, pmiCopy, pmiPaste, pmiDelete, pmiLoad, pmiSave];
end;

destructor TcxPopupMenuLayout.Destroy;
begin
  if FCustomMenuItemGlyph <> nil then FCustomMenuItemGlyph.Free;
  inherited Destroy;
end;

function TcxPopupMenuLayout.GetCustomMenuItemGlyph: TBitmap;
begin
  if FCustomMenuItemGlyph = nil then
    FCustomMenuItemGlyph := TBitmap.Create;
  Result := FCustomMenuItemGlyph;
end;

procedure TcxPopupMenuLayout.SetCustomMenuItemGlyph(Value: TBitmap);
begin
  if (Value = nil) then
  begin
    FCustomMenuItemGlyph.Free;
    FCustomMenuItemGlyph := nil;
  end
  else
    CustomMenuItemGlyph.Assign(Value);
end;

procedure TcxPopupMenuLayout.Assign(Source: TPersistent);
begin
  if Source is TcxPopupMenuLayout then
    with TcxPopupMenuLayout(Source) do
    begin
      Self.MenuItems := MenuItems;
      Self.CustomMenuItemCaption := CustomMenuItemCaption;
      Self.CustomMenuItemGlyph.Assign(CustomMenuItemGlyph);
    end
  else
    inherited Assign(Source);
end;

{ TcxCustomImageProperties }

constructor TcxCustomImageProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FPopupMenuLayout := TcxPopupMenuLayout.Create(nil);
  FCenter := True;
  FDefaultHeight := cxImageDefaultInplaceHeight;
  FGraphicTransparency := gtDefault;
  FProportional := True;
  FShowFocusRect := True;
  FStretch := False;
  FGraphicClass := GetDefaultGraphicClass;
end;

destructor TcxCustomImageProperties.Destroy;
begin
  FPopupMenuLayout.Free;
  inherited Destroy;
end;

function TcxCustomImageProperties.GetGraphicClassName: string;
begin
  if FGraphicClass = nil then
    Result := ''
  else
    Result := FGraphicClass.ClassName;
end;

function TcxCustomImageProperties.IsGraphicClassNameStored: Boolean;
begin
  Result := GraphicClass <> GetDefaultGraphicClass;
end;

procedure TcxCustomImageProperties.ReadIsGraphicClassNameEmpty(Reader: TReader);
begin
  Reader.ReadBoolean;
  GraphicClassName := '';
end;

procedure TcxCustomImageProperties.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetCenter(Value: Boolean);
begin
  if FCenter <> Value then
  begin
    FCenter := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetGraphicClass(
  const Value: TGraphicClass);
begin
  if FGraphicClass <> Value then
  begin
    FGraphicClass := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetGraphicClassName(
  const Value: string);
var
  AGraphicClass: TGraphicClass;
begin
  if Value = '' then
    GraphicClass := nil
  else
  begin
    AGraphicClass := GetGraphicClassByName(Value);
    if AGraphicClass <> nil then
      GraphicClass := AGraphicClass;
  end;
end;

procedure TcxCustomImageProperties.SetGraphicTransparency(
  Value: TcxImageTransparency);
begin
  if FGraphicTransparency <> Value then
  begin
    FGraphicTransparency := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetPopupMenuLayout(
  Value: TcxPopupMenuLayout);
begin
  FPopupMenuLayout.Assign(Value);
end;

procedure TcxCustomImageProperties.SetProportional(AValue: Boolean);
begin
  if AValue <> FProportional then
  begin
    FProportional := AValue;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetShowFocusRect(Value: Boolean);
begin
  if FShowFocusRect <> Value then
  begin
    FShowFocusRect := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.SetStretch(Value: Boolean);
begin
  if FStretch <> Value then
  begin
    FStretch := Value;
    Changed;
  end;
end;

procedure TcxCustomImageProperties.WriteIsGraphicClassNameEmpty(Writer: TWriter);
begin
  Writer.WriteBoolean(True);
end;

function TcxCustomImageProperties.CanValidate: Boolean;
begin
  Result := True;
end;

procedure TcxCustomImageProperties.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('IsGraphicClassNameEmpty', ReadIsGraphicClassNameEmpty,
    WriteIsGraphicClassNameEmpty, GraphicClassName = '');
end;

function TcxCustomImageProperties.IsDesigning: Boolean;
var
  AOwner: TPersistent;
begin
  AOwner := GetOwner;
  Result := (AOwner is TComponent) and
    (csDesigning in (AOwner as TComponent).ComponentState);
end;

function TcxCustomImageProperties.GetDefaultGraphicClass: TGraphicClass;
begin
  if GetRegisteredGraphicClasses.Count > 0 then
    Result := TGraphicClass(GetRegisteredGraphicClasses[0])
  else
    Result := nil;
end;

function TcxCustomImageProperties.GetRealStretch(const APictureSize, ABoundsSize: TSize): Boolean;
begin
  Result := Stretch or (Proportional and
    ((APictureSize.cy > ABoundsSize.cy) or (APictureSize.cx > ABoundsSize.cx)));
end;

class function TcxCustomImageProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxImageViewData;
end;

procedure TcxCustomImageProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomImageProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxCustomImageProperties(Source) do
      begin
        Self.Caption := Caption;
        Self.Center := Center;
        Self.CustomFilter := CustomFilter;
        Self.GraphicClass := GraphicClass;
        Self.GraphicTransparency := GraphicTransparency;
        Self.PopupMenuLayout := PopupMenuLayout;
        Self.ShowFocusRect := ShowFocusRect;
        Self.Proportional := Proportional;
        Self.Stretch := Stretch;
        Self.OnAssignPicture := OnAssignPicture;
        Self.OnCustomClick := OnCustomClick;
        Self.OnGetGraphicClass := OnGetGraphicClass;
      end;
    finally
      EndUpdate
    end
  end  
  else
    inherited Assign(Source);
end;

class function TcxCustomImageProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxImage;
end;

function TcxCustomImageProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
begin
  if VarIsNull(AEditValue) then Result := '' else Result := Caption;
end;

function TcxCustomImageProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsValue;
end;

function TcxCustomImageProperties.GetGraphicClass(AItem: TObject;
  ARecordIndex: Integer; APastingFromClipboard: Boolean = False): TGraphicClass;
begin
  Result := FGraphicClass;
  if Result = nil then
  begin
    if APastingFromClipboard then
      Result := TBitmap;
    if Assigned(FOnGetGraphicClass) then
      FOnGetGraphicClass(AItem, ARecordIndex, APastingFromClipboard, Result);
  end;
end;

function TcxCustomImageProperties.GetSpecialFeatures: TcxEditSpecialFeatures;
begin
  Result := inherited GetSpecialFeatures + [esfBlobEditValue];
end;

function TcxCustomImageProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := inherited GetSupportedOperations + [esoAutoHeight, esoEditing];
end;

class function TcxCustomImageProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxImageViewInfo;
end;

function TcxCustomImageProperties.IsResetEditClass: Boolean;
begin
  Result := True;
end;

procedure TcxCustomImageProperties.ValidateDisplayValue(var DisplayValue: TcxEditValue;
  var ErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit);
begin
  with TcxCustomImage(AEdit) do
  begin
    LockEditValueChanging(True);
    try
      DoOnAssignPicture;
      SaveModified;
      try
        EditModified := False;
        DoEditing;
      finally
        RestoreModified;
      end;
    finally
      LockEditValueChanging(False);
    end;
  end;
end;

{ TcxCustomImage }

destructor TcxCustomImage.Destroy;
begin
  if FEditPopupMenu <> nil then FEditPopupMenu.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TcxCustomImage.EditAndClear;
begin
  if DoEditing then
    FPicture.Graphic := nil;
end;

procedure TcxCustomImage.EditPopupMenuClick(Sender: TObject);
begin
  MenuItemClick(Sender, TcxPopupMenuItem(Integer(TMenuItem(Sender).Tag)));
end;

{$IFDEF CBUILDER10}
function TcxCustomImage.GetPicture: TPicture;
begin
  Result := FPicture;
end;
{$ENDIF}

function TcxCustomImage.GetProperties: TcxCustomImageProperties;
begin
  Result := TcxCustomImageProperties(FProperties);
end;

function TcxCustomImage.GetActiveProperties: TcxCustomImageProperties;
begin
  Result := TcxCustomImageProperties(InternalGetActiveProperties);
end;

procedure TcxCustomImage.MenuItemClick(Sender: TObject;
  MenuItem: TcxPopupMenuItem);
begin
  KeyboardAction := True;
  try
    case MenuItem of
      pmiCut: CutToClipboard;
      pmiCopy: CopyToClipboard;
      pmiPaste: PasteFromClipboard;
      pmiDelete: EditAndClear;
      pmiLoad: LoadFromFile;
      pmiSave: SaveToFile;
      pmiCustom: CustomClick;
    end;
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomImage.PictureChanged(Sender: TObject);
var
  PrevEvent: TNotifyEvent;
begin
  LockChangeEvents(True);
  try
    if Picture.Graphic is TIcon then // Otherwise the Icon returns the incorrect sizes
      TIcon(Picture.Graphic).Handle; // HandleNeeded;

    if ActiveProperties.GraphicTransparency <> gtDefault then
    begin
      PrevEvent := FPicture.OnChange;
      try
        FPicture.OnChange := nil;
        if not IsPictureEmpty(FPicture) then
          FPicture.Graphic.Transparent := ActiveProperties.GraphicTransparency = gtTransparent;
      finally
        FPicture.OnChange := PrevEvent;
      end;
    end;
    if not (csLoading in ComponentState) then
    begin
      ResetImage;
      SetSize;
    end;
    if not FInternalChanging then
    begin
      if KeyboardAction then
        ModifiedAfterEnter := True;
      DoChange;
      ShortRefreshContainer(False);
    end;
    if ActiveProperties.ImmediatePost and CanPostEditValue and ValidateEdit(True) then
      InternalPostEditValue;
  finally
    LockChangeEvents(False);
  end;
  UpdateScrollBars;
end;

procedure TcxCustomImage.PreparePopup;

  procedure RefreshCaptions;
  begin
    with FEditPopupMenu do
    begin
      Items[0].Caption := cxGetResourceString(@cxSMenuItemCaptionCut);
      Items[1].Caption := cxGetResourceString(@cxSMenuItemCaptionCopy);
      Items[2].Caption := cxGetResourceString(@cxSMenuItemCaptionPaste);
      Items[3].Caption := cxGetResourceString(@cxSMenuItemCaptionDelete);
      Items[5].Caption := cxGetResourceString(@cxSMenuItemCaptionLoad);
      Items[6].Caption := cxGetResourceString(@cxSMenuItemCaptionSave);
    end;
  end;

  function NewItem(const ACaption: string; ABitmap: TBitmap;
    ATag: Integer): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    with Result do
    begin
      Caption := ACaption;
      if Assigned(ABitmap) then Bitmap := ABitmap else ImageIndex := ATag;
      Tag := ATag;
      OnClick := EditPopupMenuClick;
    end;
  end;

  procedure AddItem(AItems: TMenuItem; AMenuItem: TcxPopupMenuItem);
  begin
    with AItems do
    begin
      if AMenuItem = pmiCustom then
      begin
        ActiveProperties.PopupMenuLayout.CustomMenuItemGlyph.Transparent := True;
        Add(NewItem(ActiveProperties.PopupMenuLayout.CustomMenuItemCaption,
          ActiveProperties.PopupMenuLayout.CustomMenuItemGlyph, Integer(AMenuItem)));
      end
      else
        Add(NewItem('', nil, Integer(AMenuItem)));
      if AMenuItem in [pmiDelete, pmiSave] then
        Add(NewItem('-', nil, -1));
    end;
  end;

var
  I: TcxPopupMenuItem;
  AFlagRO, AFlagEmpty, AIsIcon, ACanPaste: Boolean;
begin
  with ActiveProperties.PopupMenuLayout do
  begin
    if FEditPopupMenu = nil then
    begin
      FEditPopupMenu := TPopupMenu.Create(nil);
      FEditPopupMenu.Images := cxGraphicPopupMenuImages;
      for I := Low(TcxPopupMenuItem) to High(TcxPopupMenuItem) do
        AddItem(FEditPopupMenu.Items, I);
    end;
    RefreshCaptions;
    // visible
    with FEditPopupMenu do
    begin
      Items[0].Visible := pmiCut in MenuItems;
      Items[1].Visible := pmiCopy in MenuItems;
      Items[2].Visible := pmiPaste in MenuItems;
      Items[3].Visible := pmiDelete in MenuItems;
      Items[5].Visible := pmiLoad in MenuItems;
      Items[6].Visible := pmiSave in MenuItems;
      Items[8].Visible := pmiCustom in MenuItems;
      // Separators
      Items[4].Visible := Items[5].Visible or Items[6].Visible;
      Items[7].Visible := Items[8].Visible;

      AIsIcon := ActiveProperties.GraphicClass = TIcon;

      ACanPaste := CanPasteFromClipboard;
      // Custom Item
      with Items[8] do
      begin
        Caption := CustomMenuItemCaption;
        Bitmap := CustomMenuItemGlyph;
      end;

      AFlagRO := not CanModify;
      AFlagEmpty := IsPictureEmpty(FPicture);
      Items[0].Enabled := not (AFlagEmpty or AFlagRO or AIsIcon);
      Items[1].Enabled := not AFlagEmpty and not AIsIcon;
      Items[2].Enabled := not AFlagRO and ACanPaste;
      Items[3].Enabled := not AFlagEmpty and not AFlagRO;
      Items[5].Enabled := not AFlagRO;
      Items[6].Enabled := not AFlagEmpty;
    end;
  end;
end;

procedure TcxCustomImage.ResetImage;
begin
  HScrollBar.Position := 0;
  VScrollBar.Position := 0;
  SynchronizeImage;
end;

procedure TcxCustomImage.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TcxCustomImage.SetProperties(const Value: TcxCustomImageProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomImage.SetTransparent(AValue: Boolean);
begin
  if AValue <> FTransparent then
  begin
    FTransparent := AValue;
    ViewInfo.Transparent := FTransparent;
    InvalidateRect(ViewInfo.ClientRect, False);
  end;
end;

procedure TcxCustomImage.SynchronizeImage;
begin
  if not HandleAllocated then Exit;
  with TcxImageViewInfo(ViewInfo) do
  begin
    if HScrollBar.Visible then TopLeft.X := HScrollBar.Position else TopLeft.X := 0;
    if VScrollBar.Visible then TopLeft.Y := VScrollBar.Position else TopLeft.Y := 0;
  end;
  CalculateViewInfo(False);
  InvalidateRect(ViewInfo.ClientRect, False);
end;

function TcxCustomImage.CanAutoSize: Boolean;
begin
  Result := inherited CanAutoSize and not IsPictureEmpty(Picture);
end;

function TcxCustomImage.CanAutoWidth: Boolean;
begin
  Result := True;
end;

procedure TcxCustomImage.DoContextPopup( MousePos: TPoint;
  var Handled: Boolean);
var
  P: TPoint;
begin
  if (PopupMenu = nil) and (ActiveProperties.PopupMenuLayout.MenuItems <> []) then
  begin
    Handled := True;
    P := MousePos;
    if (P.X = -1) and (P.Y = -1) then
    begin
      P.X := 10;
      P.Y := 10;
    end;
    // Popup
    PreparePopup;
    P := ClientToScreen(P);
    FEditPopupMenu.Popup(P.X, P.Y);
  end
  else
    inherited;
end;

procedure TcxCustomImage.Initialize;
begin
  inherited Initialize;
  AutoSize := False;
  Width := 140;
  Height := 100;
  FClipboardFormat := CF_PICTURE;
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  TcxImageViewInfo(ViewInfo).Picture := FPicture;
end;

procedure TcxCustomImage.InitScrollBarsParameters;
begin
  if IsInplace or AutoSize or IsRectEmpty(ClientBounds) or IsPictureEmpty(Picture) or // TODO
    ActiveProperties.Center or ActiveProperties.Stretch then                          // TODO
      Exit;
  with ClientBounds do
  begin
    SetScrollBarInfo(sbHorizontal, 0, Picture.Width - 1, 8, Right - Left,
      TcxImageViewInfo(ViewInfo).TopLeft.X, True, True);
    SetScrollBarInfo(sbVertical, 0, Picture.Height - 1, 8, Bottom - Top,
      TcxImageViewInfo(ViewInfo).TopLeft.Y, True, True);
  end;
  SynchronizeImage;
end;

procedure TcxCustomImage.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  KeyboardAction := True;
  try
    case Key of
      VK_INSERT:
        if ssShift in Shift then
          PasteFromClipBoard
        else
          if ssCtrl in Shift then
            CopyToClipBoard;
      VK_DELETE:
        if ssShift in Shift then
          CutToClipBoard;
    end;
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomImage.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  KeyboardAction := True;
  try
    case Key of
      ^X: CutToClipBoard;
      ^C: CopyToClipBoard;
      ^V: PasteFromClipBoard;
    end;
  finally
    KeyboardAction := False;
  end;
end;

function TcxCustomImage.NeedsInvokeAfterKeyDown(AKey: Word;
  AShift: TShiftState): Boolean;
begin
  Result := inherited NeedsInvokeAfterKeyDown(AKey, AShift);
  case AKey of
    VK_INSERT:
      Result := AShift * [ssCtrl, ssShift] = [];
    VK_DELETE:
      Result := not (ssShift in AShift);
  end;
end;

function TcxCustomImage.NeedsScrollBars: Boolean;
begin
  Result := True;
end;

procedure TcxCustomImage.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);
begin
  case AScrollCode of
   scLineUp:
     Dec(AScrollPos, 8);
   scLineDown:
     Inc(AScrollPos, 8);
  end;
  case AScrollBarKind of
    sbVertical:
      begin
        AScrollPos := Min(AScrollPos, Picture.Height - VScrollBar.PageSize);
        VScrollBar.Position := AScrollPos;
        AScrollPos := VScrollBar.Position;
      end;
    sbHorizontal:
      begin
        AScrollPos := Min(AScrollPos, Picture.Width - HScrollBar.PageSize);
        HScrollBar.Position := AScrollPos;
        AScrollPos := HScrollBar.Position;
      end;
  end;
  SynchronizeImage;
end;

function TcxCustomImage.GetEditValue: TcxEditValue;
var
  S: AnsiString;
begin
  if IsPictureEmpty(FPicture) then
    Result := Null
  else
  begin
    SavePicture(FPicture, S);
    Result := S;
  end;
end;

procedure TcxCustomImage.InternalSetEditValue(const Value: TcxEditValue; AIsValueValid: Boolean);
begin
  FInternalChanging := True;
  try
    if cxVarIsBlob(Value) then
      LoadPicture(Picture, GetGraphicClass, Value)
    else
      Picture.Assign(nil);
  finally
    EditModified := False;
    FInternalChanging := False;
  end;
end;

procedure TcxCustomImage.PropertiesChanged(Sender: TObject);
begin
  if not PropertiesChangeLocked then
  begin
    PictureChanged(nil);
    UpdateScrollBars;
    inherited PropertiesChanged(Sender)
  end;
end;

procedure TcxCustomImage.UpdateScrollBars;
begin
  inherited UpdateScrollBars;
  SynchronizeImage;
end;

function TcxCustomImage.CanPasteFromClipboard: Boolean;
var
  AGraphicClass: TGraphicClass;
begin
  AGraphicClass := ActiveProperties.GraphicClass;
  if AGraphicClass = TBitmap then
    Result := Clipboard.HasFormat(CF_BITMAP)
  else if AGraphicClass = TIcon then
    Result := False
  else if AGraphicClass = TMetafile then
    Result := Clipboard.HasFormat(CF_METAFILEPICT)
  {$IFDEF USEJPEGIMAGE}
  else if AGraphicClass = TJPEGImage then
    Result := Clipboard.HasFormat(CF_BITMAP)
  {$ENDIF}
  else if AGraphicClass = nil then
    Result := Clipboard.HasFormat(CF_PICTURE)
  else
    Result := Clipboard.HasFormat(ClipboardFormat);
end;

procedure TcxCustomImage.CustomClick;
begin
  with Properties do
    if Assigned(OnCustomClick) then
      OnCustomClick(Self);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnCustomClick) then
        OnCustomClick(Self);
end;

procedure TcxCustomImage.DoOnAssignPicture;
begin
  with Properties do
    if Assigned(OnAssignPicture) then
      OnAssignPicture(Self, Picture);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnAssignPicture) then
        OnAssignPicture(Self, Picture);
end;

function TcxCustomImage.GetGraphicClass(APastingFromClipboard: Boolean = False): TGraphicClass;
begin
  if IsInplace then
    Result := ActiveProperties.GetGraphicClass(InplaceParams.Position.Item,
      InplaceParams.Position.RecordIndex, APastingFromClipboard)
  else
  begin
    Result := ActiveProperties.GraphicClass;
    if Result = nil then
    begin
      if APastingFromClipboard then
        Result := TBitmap;
      if Assigned(FOnGetGraphicClass) then
        FOnGetGraphicClass(Self, APastingFromClipboard, Result);
    end;
  end;
end;

procedure TcxCustomImage.CopyToClipboard;
begin
  if (FPicture <> nil) and (FPicture.Graphic <> nil) then
    Clipboard.Assign(FPicture);
end;

procedure TcxCustomImage.CutToClipboard;
begin
  CopyToClipboard;
  EditAndClear;
end;

function TcxCustomImage.Focused: Boolean;
begin
  Result := FIsDialogShowed or inherited Focused;
end;

class function TcxCustomImage.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomImageProperties;
end;

procedure TcxCustomImage.LoadFromFile;

  function GetDialogFilter: string;
  var
  AGraphicClass: TGraphicClass;
      begin
        if ActiveProperties.CustomFilter <> '' then
      Result := ActiveProperties.CustomFilter
        else
        begin
          AGraphicClass := ActiveProperties.GraphicClass;
          if AGraphicClass <> nil then
        Result := GraphicFilter(AGraphicClass)
          else
        Result := GraphicFilter(TGraphic);
        end;
  end;

var
  ADialog: TOpenPictureDialog;
begin
  if not CanModify then
    Exit;
  ADialog := TOpenPictureDialog.Create(nil);
        try
    FIsDialogShowed := True;
    ADialog.Filter := GetDialogFilter;
    if ADialog.Execute and DoEditing then
          begin
      FPicture.LoadFromFile(ADialog.FileName);
            DoClosePopup(crEnter);
          end
          else
            DoClosePopup(crCancel);
    Application.ProcessMessages;
        finally
          FIsDialogShowed := False;
      ADialog.Free;
    end;
end;

procedure TcxCustomImage.PasteFromClipboard;
{$IFDEF USEJPEGIMAGE}
var
  AGraphicClass: TGraphicClass;
  AGraphic: TJPEGImage;
{$ENDIF}
begin
  if CanPasteFromClipboard and DoEditing then
    if Clipboard.HasFormat(CF_BITMAP) then
    begin
{$IFDEF USEJPEGIMAGE}
      AGraphicClass := GetGraphicClass(True);
      if (AGraphicClass = TJPEGImage) then
      begin
        AGraphic := TJPEGImage.Create;
        try
          TJPEGImageAccess(AGraphic).NewBitmap;
          TJPEGImageAccess(AGraphic).Bitmap.Assign(Clipboard);
          AGraphic.JPEGNeeded;
          FPicture.Graphic := AGraphic;
        finally
          AGraphic.Free;
        end;
      end
      else
{$ENDIF}
        FPicture.Bitmap.Assign(Clipboard);
    end
    else
      FPicture.Assign(Clipboard);
end;

procedure TcxCustomImage.SaveToFile;
var
  ADialog: TSavePictureDialog;
begin
  if (FPicture = nil) or (FPicture.Graphic = nil) then
    Exit;
  ADialog := TSavePictureDialog.Create(Application);
  FIsDialogShowed := True;
    try
        if ActiveProperties.CustomFilter <> '' then
      ADialog.Filter := ActiveProperties.CustomFilter
        else
      ADialog.Filter := GraphicFilter(TGraphicClass(FPicture.Graphic.ClassType));
    ADialog.DefaultExt := GraphicExtension(TGraphicClass(FPicture.Graphic.ClassType));
    if ADialog.Execute then
      FPicture.SaveToFile(ADialog.FileName);
    Application.ProcessMessages;
        finally
          FIsDialogShowed := False;
    ADialog.Free;
  end;
end;

{ TcxImage }

class function TcxImage.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxImageProperties;
end;

function TcxImage.GetActiveProperties: TcxImageProperties;
begin
  Result := TcxImageProperties(InternalGetActiveProperties);
end;

function TcxImage.GetProperties: TcxImageProperties;
begin
  Result := TcxImageProperties(FProperties);
end;

procedure TcxImage.SetProperties(Value: TcxImageProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxImageViewInfo }

destructor TcxImageViewInfo.Destroy;
begin
  if FFreePicture then
    Picture.Free;
  FTempBitmap.Free;
  inherited Destroy;
end;

procedure TcxImageViewInfo.DrawTransparentBackground(ACanvas: TcxCanvas; const R: TRect);
begin
  ACanvas.SaveClipRegion;
  try
    ACanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
    cxDrawTransparentControlBackground(Edit, ACanvas, Bounds);
  finally
    ACanvas.RestoreClipRegion;
  end;
end;

procedure TcxImageViewInfo.InternalPaint(ACanvas: TcxCanvas);

  procedure FocusRect(ACanvas: TCanvas; R: TRect);
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(R);
    ACanvas.Brush.Style := bsSolid;
  end;

var
  CR, R, Temp: TRect;
  NeedDrawBkg: Boolean;
  SaveRgn: TcxRegion;
begin
  CR := ClientRect;
  if Transparent and not IsInplace then
    DrawTransparentBackground(ACanvas, Bounds);
  with ACanvas do
  begin
    if not Assigned(Picture) or IsPictureEmpty(Picture) then
    begin
      inherited InternalPaint(ACanvas);
      Brush.Color := BackgroundColor;
      if Caption <> '' then
      begin
        Brush.Style := bsClear;
        Canvas.Font.Assign(Self.Font);
        Canvas.Font.Color := Self.TextColor;
        ACanvas.DrawText(Caption, CR, cxAlignCenter + cxSingleLine);
        Brush.Style := bsSolid;
      end;
      if ShowFocusRect then FocusRect(Canvas, CR);
      Exit;
    end;
    with CR do
    begin
      if TcxCustomImageProperties(EditProperties).GetRealStretch(Size(Picture.Width, Picture.Height),
        Size(cxRectWidth(CR), cxRectHeight(CR))) then
      begin
        if Proportional then
          CalcStretchRect(CR, Picture.Width, Picture.Height, R)
        else
          R := CR;
      end
      else
        R := cxRectBounds(Left, Top, Picture.Width, Picture.Height);
      if Center then
      begin
        OffsetRect(R, (Right - Left - cxRectWidth(R)) div 2, 0);
        OffsetRect(R, 0, (Bottom - Top - cxRectHeight(R)) div 2);
      end
      else
        OffsetRect(R, -Self.TopLeft.X, -Self.TopLeft.Y);
    end;
    SaveRgn := GetClipRegion; // for native mode
    ExcludeClipRect(CR);
    DrawCustomEdit(ACanvas, Self, False, bpsSolid);
    SetClipRegion(SaveRgn, roSet);
    if ShowFocusRect then
    begin
      FocusRect(Canvas, CR);
      InflateRect(CR, -1, -1);
    end;
    SaveRgn := GetClipRegion;
    IntersectClipRect(CR);
    if ShowFocusRect then InflateRect(CR, 1, 1);
    if not Self.Transparent and Picture.Graphic.Transparent then
    begin
      if FTempBitmap = nil then
      begin
        FTempBitmap := TBitmap.Create;
        FTempBitmap.PixelFormat := pfDevice;
      end;
      try
        FTempBitmap.Width := R.Right - R.Left;
        FTempBitmap.Height := R.Bottom - R.Top;
        FTempBitmap.Canvas.Brush.Color := BackgroundColor;
        FTempBitmap.Canvas.FillRect(Rect(0, 0, FTempBitmap.Width, FTempBitmap.Height));
        FTempBitmap.Canvas.StretchDraw(Rect(0, 0, FTempBitmap.Width, FTempBitmap.Height), Picture.Graphic);
        Canvas.Draw(R.Left, R.Top, FTempBitmap);
      except
        on EOutOfResources do
        begin
          Canvas.Brush.Color := BackgroundColor;
          Canvas.FillRect(ClientRect);
          Canvas.StretchDraw(R, Picture.Graphic);
        end;
      end;
    end
    else
      Canvas.StretchDraw(R, Picture.Graphic);
    NeedDrawBkg := not (IntersectRect(Temp, R, CR) and EqualRect(Temp, CR)) and not Self.Transparent;
    if NeedDrawBkg then
    begin
      ExcludeClipRect(R);
      Brush.Color := BackgroundColor;
      FillRect(CR);
    end;
    SetClipRegion(SaveRgn, roSet);
  end;
end;

function TcxImageViewInfo.IsRepaintOnStateChangingNeeded: Boolean;
begin
  Result := (not Assigned(Picture) or IsPictureEmpty(Picture)) and (Caption <> '');
end;

{ TcxImageViewData }

procedure TcxImageViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  AProperties: TcxCustomImageProperties;
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  if IsRectEmpty(ABounds) then
    Exit;
  AProperties := TcxCustomImageProperties(Properties);
  with TcxImageViewInfo(AViewInfo) do
  begin
    Caption := AProperties.Caption;
    Center := AProperties.Center;
    ShowFocusRect := AProperties.ShowFocusRect and Focused and not IsInplace;
    Stretch := AProperties.Stretch;
    Proportional := AProperties.Proportional;
    if Center or Stretch then
      TopLeft := Point(0, 0);
  end;
end;

procedure TcxImageViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  AGraphicClass: TGraphicClass;
begin
  with TcxImageViewInfo(AViewInfo) do
    if Length(dxVariantToAnsiString(AEditValue)) > 0 then
    begin
      if not Assigned(Picture) then
      begin
        Picture := TPicture.Create;
        FFreePicture := True;
      end;
      AGraphicClass := TcxCustomImageProperties(Properties).GetGraphicClass(
        InplaceEditParams.Position.Item, InplaceEditParams.Position.RecordIndex);
      LoadPicture(Picture, AGraphicClass, AEditValue);
      if TcxCustomImageProperties(Properties).GraphicTransparency <> gtDefault then
        Picture.Graphic.Transparent :=
          TcxCustomImageProperties(Properties).GraphicTransparency = gtTransparent;
    end
    else
      if Assigned(Picture) then
        Picture.Assign(nil);
end;

function TcxImageViewData.GetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue;
  const AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  ABorderExtent: TRect;
  AGraphicClass: TGraphicClass;
  APicture: TPicture;
begin
  if IsInplace then
  begin
    if Edit <> nil then
    begin
      Result := Size(Edit.Width, Edit.Height);
      ABorderExtent := GetBorderExtent;
      Result.cx := Result.cx - (ABorderExtent.Left + ABorderExtent.Right);
      Result.cy := Result.cy - (ABorderExtent.Top + ABorderExtent.Bottom);
    end
    else
      with TcxCustomImageProperties(Properties) do
      begin
        Result := Size(0, DefaultHeight);
        if cxVarIsBlob(AEditValue) then
        begin
          AGraphicClass := GetGraphicClass(InplaceEditParams.Position.Item,
            InplaceEditParams.Position.RecordIndex);
          APicture := TPicture.Create;
          try
            LoadPicture(APicture, AGraphicClass, AEditValue);
            Result := Size(APicture.Width, APicture.Height);
          finally
            APicture.Free;
          end;
          if GetRealStretch(Result, Size(AEditSizeProperties.Width, AEditSizeProperties.Height)) then
            if (AEditSizeProperties.Width > 0) and (Result.cx > 0) then
              Result := Size(AEditSizeProperties.Width, Round(Result.cy * AEditSizeProperties.Width / Result.cx))
            else
              if (AEditSizeProperties.Height > 0) and (Result.cy > 0) then
                Result := Size(Round(Result.cx * AEditSizeProperties.Height / Result.cy), AEditSizeProperties.Height);
        end
        else
          if Length(Caption) <> 0 then
          begin
            ACanvas.Font := Style.GetVisibleFont;
            Result := ACanvas.TextExtent(Caption);
          end;
      end;
  end
  else
    if Edit <> nil then
      with TcxCustomImage(Edit) do
        Result := Size(Picture.Width, Picture.Height)
    else
      Result := Size(0, 0);
end;

procedure LoadPopupMenuImages;

  function GetResourceName(APopupMenuItem: TcxPopupMenuItem): string;
  begin
    case APopupMenuItem of
      pmiCut:
        Result := 'CXMENUIMAGE_CUT';
      pmiCopy:
        Result := 'CXMENUIMAGE_COPY';
      pmiPaste:
        Result := 'CXMENUIMAGE_PASTE';
      pmiDelete:
        Result := 'CXMENUIMAGE_DELETE';
      pmiLoad:
        Result := 'CXMENUIMAGE_LOAD';
      pmiSave:
        Result := 'CXMENUIMAGE_SAVE';
      else
        Result := '';
    end;
  end;

  procedure LoadBitmapFromResource(ABitmap: TBitmap;
    APopupMenuItem: TcxPopupMenuItem);
  begin
    ABitmap.LoadFromResourceName(HInstance, GetResourceName(APopupMenuItem));
  end;

var
  ABitmap: TBitmap;
  APopupMenuItem: TcxPopupMenuItem;
begin
  ABitmap := TBitmap.Create;
  try
    LoadBitmapFromResource(ABitmap, Low(TcxPopupMenuItem));
    if cxGraphicPopupMenuImages = nil then
      cxGraphicPopupMenuImages := TImageList.CreateSize(ABitmap.Width, ABitmap.Height);
    cxGraphicPopupMenuImages.AddMasked(ABitmap, clDefault);

    for APopupMenuItem := Succ(Low(TcxPopupMenuItem)) to High(TcxPopupMenuItem) do
    begin
      if APopupMenuItem = pmiCustom then
        Continue;
      LoadBitmapFromResource(ABitmap, APopupMenuItem);
      cxGraphicPopupMenuImages.AddMasked(ABitmap, clDefault);
    end;
  finally
    ABitmap.Free;
  end;
end;

initialization
  LoadPopupMenuImages;
  GetRegisteredEditProperties.Register(TcxImageProperties, scxSEditRepositoryImageItem);

finalization
  FreeAndNil(cxRegisteredGraphicClasses);
  FreeAndNil(cxGraphicPopupMenuImages);

end.
