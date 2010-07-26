
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
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

unit dxSkinsCore;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Windows, SysUtils, Classes, Graphics, Math, cxGraphics, cxGeometry, cxClasses,
  cxLookAndFeels, dxGDIPlusApi, dxGDIPlusClasses, dxSkinsStrs, ActiveX, Forms,
  dxOffice11, dxCore;

type
  TdxSkinVersion = Double;
  TdxSkinSignature = array[0..5] of AnsiChar;

const
  dxSkinSignature: TdxSkinSignature = 'dxSkin';
  dxSkinStreamVersion: TdxSkinVersion = 1.02;
  ImageNameSuffix = '_Image.png';
  GlyphNameSuffix = '_Glyph.png';
  BitmapNameSuffixes: array[Boolean] of string = (GlyphNameSuffix, ImageNameSuffix);
{$IFNDEF DELPHI6}
  PathDelim = '\';
{$ENDIF}

type
  TdxSkin = class;
  TdxSkinClass = class of TdxSkin;
  TdxSkinCustomPersistentObject = class;
  TdxSkinCustomPersistentObjectClass = class of TdxSkinCustomPersistentObject;
  TdxSkinPersistentClass = class of TdxSkinPersistent;
  TdxSkinControlGroupClass = class of TdxSkinControlGroup;
  TdxSkinElementClass = class of TdxSkinElement;
  TdxSkinColor = class;
  TdxSkinProperty = class;
  TdxSkinPropertyClass = class of TdxSkinProperty;
  TdxSkinControlGroup = class;
  TdxSkinImage = class;
  TdxSkinElement = class;

  EdxSkin = class(EdxException);

  IdxSkinChangeListener = interface
  ['{28681774-0475-43AE-8704-1C904D294742}']
    procedure SkinChanged(Sender: TdxSkin);
  end;

  IdxSkinInfo = interface
  ['{97D85495-E631-413C-8DBC-BE7B784A9EA0}']
    function GetSkin: TdxSkin;
  end;

  { TdxSkinCustomPersistentObject }

  TdxSkinCustomPersistentObject = class(TPersistent)
  private
    FName: string;
    FOwner: TPersistent;
    FTag: Integer; 
    FOnChange: TNotifyEvent;
  protected
    procedure DoChange; virtual;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent; const AName: string); virtual;
    function Clone: TdxSkinCustomPersistentObject; virtual;
    
    property Tag: Integer read FTag write FTag;
  published
    property Name: string read FName write FName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { TdxSkinPersistent }

  TdxSkinPersistent = class(TdxSkinCustomPersistentObject)
  private
    FLockCount: Integer;
    FModified: Boolean;
    FProperties: TcxObjectList;
    FSorted: Boolean;
    function GetPropertyCount: Integer;
    function GetProperty(Index: Integer): TdxSkinProperty;
    procedure SetSorted(AValue: Boolean);
  protected
    procedure AddSubItem(AInstance: TdxSkinCustomPersistentObject; AList: TcxObjectList);
    procedure Changed; virtual;
    procedure DoSort; virtual;
    procedure SubItemHandler(Sender: TObject); virtual;
    procedure ReadProperties(AStream: TStream);
    procedure WriteProperties(AStream: TStream);

    property LockCount: Integer read FLockCount write FLockCount;
    property Sorted: Boolean read FSorted write SetSorted;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function AddProperty(const AName: string;
      APropertyClass: TdxSkinPropertyClass): TdxSkinProperty;
    procedure BeginUpdate;
    procedure CancelUpdate;
    procedure DeleteProperty(const AProperty: TdxSkinProperty); virtual;
    procedure EndUpdate;
    function GetPropertyByName(const AName: string): TdxSkinProperty;
    procedure Sort;

    property Modified: Boolean read FModified write FModified;
    property PropertyCount: Integer read GetPropertyCount;
    property Properties[Index: Integer]: TdxSkinProperty read GetProperty;
  end;

  { TdxSkin }

  TdxSkin = class(TdxSkinPersistent)
  private
    FColors: TcxObjectList;
    FGroups: TcxObjectList;
    FListeners: TInterfaceList;
    FName: string;
    FOnChange: TNotifyEvent;
    FVersion: TdxSkinVersion;
    function GetColor(Index: Integer): TdxSkinColor;
    function GetColorCount: Integer;
    function GetGroup(Index: Integer): TdxSkinControlGroup;
    function GetGroupCount: Integer;
    procedure SetName(const Value: string);
  protected
    procedure DoChange; override;
    procedure DoSort; override;
    procedure LoadFromResource(hInst: THandle); virtual;
    procedure NotifyListeners;

    property Listeners: TInterfaceList read FListeners;
  public
    constructor Create(const AName: string; ALoadOnCreate: Boolean; hInst: THandle); reintroduce; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override; 
    function AddColor(const AName: string; const AColor: TColor): TdxSkinColor;
    function AddGroup(const AName: string = ''): TdxSkinControlGroup;
    procedure AddListener(AListener: IdxSkinChangeListener);
    procedure Clear;
    procedure ClearModified;
    function Clone(const AName: string): TdxSkin; reintroduce; virtual;
    procedure DeleteProperty(const AProperty: TdxSkinProperty); override;
    function GetColorByName(const AName: string): TdxSkinColor;
    function GetGroupByName(const AName: string): TdxSkinControlGroup;
    procedure LoadFromStream(AStream: TStream); virtual;
    procedure LoadFromFile(const AFileName: string);
    procedure RemoveListener(AListener: IdxSkinChangeListener);
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(AStream: TStream); virtual;

    property ColorCount: Integer read GetColorCount;
    property Colors[Index: Integer]: TdxSkinColor read GetColor;
    property GroupCount: Integer read GetGroupCount;
    property Groups[Index: Integer]: TdxSkinControlGroup read GetGroup;
  published
    property Name: string read FName write SetName;
    property Version: TdxSkinVersion read FVersion;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { TdxSkinProperty }

  TdxSkinProperty = class(TdxSkinCustomPersistentObject)
  protected
    procedure ReadData(Stream: TStream); virtual;
    procedure ReadFromStream(Stream: TStream); virtual;
    procedure WriteData(Stream: TStream); virtual;
    procedure WriteToStream(Stream: TStream); virtual;
  public
    class procedure Register;
    class procedure Unregister;
    class function Description: string; virtual;
    function Compare(AProperty: TdxSkinProperty): Boolean; virtual;
  end;

  TdxSkinGradientMode = (gmHorizontal, gmVertical, gmForwardDiagonal,
    gmBackwardDiagonal);

  { TdxSkinCanvas }

  TdxSkinCanvas = class(TObject)
  private
    FBuffer: TcxBitmap;
    FGraphics: GpGraphics;
    FRect: TRect;
    FSourceDC: HDC;
    function GetInterpolationMode: Integer;
    procedure SetInterpolationMode(AValue: Integer);
    procedure FillRectByDiagonalGradient(const R: TRect; AColor1, AColor2: TColor;
      AForward: Boolean);
  public
    function IsRectVisible(DC: HDC; const R: TRect): Boolean;
    procedure BeginPaint(DC: HDC; const R: TRect);
    procedure BeginPaintEx(Graphics: GpGraphics; const R: TRect);
    procedure DrawImage(AImage: TdxPNGImage; const ADest, ASource: TRect);
    procedure EndPaint; overload;
    procedure FillRectByColor(const R: TRect; AColor: TColor);
    procedure FillRectByGradient(const R: TRect; AColor1, AColor2: TColor;
      AMode: TdxSkinGradientMode);
    procedure StretchDrawImage(AImage: TdxPNGImage; const ADest, ASource: TRect);
    procedure TileImage(AImage: TdxPNGImage; const ADest, ASource: TRect);
    // Properties
    property Graphics: GpGraphics read FGraphics;
    property InterpolationMode: Integer read GetInterpolationMode write SetInterpolationMode;
  end;

  { TdxSkinIntegerProperty }

  TdxSkinIntegerProperty = class(TdxSkinProperty)
  private
    FValue: Integer;
    procedure SetValue(AValue: Integer);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
  published
    property Value: Integer read FValue write SetValue default 0;
  end;

  { TdxSkinBooleanProperty }

  TdxSkinBooleanProperty = class(TdxSkinProperty)
  private
    FValue: Boolean;
    procedure SetValue(AValue: Boolean);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
  published
    property Value: Boolean read FValue write SetValue default False;
  end;

  { TdxSkinColor }

  TdxSkinColor = class(TdxSkinProperty)
  private
    FValue: TColor;
    procedure SetValue(AValue: TColor);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
  published
    property Value: TColor read FValue write SetValue default clDefault;
  end;

  { TdxSkinRectProperty }

  TdxSkinRectProperty = class(TdxSkinProperty)
  private
    FValue: TcxRect;
    function GetValueByIndex(Index: Integer): Integer;
    procedure SetValue(Value: TcxRect);
    procedure SetValueByIndex(Index, Value: Integer);
    procedure InternalHandler(Sender: TObject);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;

    property Value: TcxRect read FValue write SetValue;
  published
    property Left: Integer index 0 read GetValueByIndex write SetValueByIndex default 0;
    property Top: Integer index 1 read GetValueByIndex write SetValueByIndex default 0;
    property Right: Integer index 2 read GetValueByIndex write SetValueByIndex default 0;
    property Bottom: Integer index 3 read GetValueByIndex write SetValueByIndex default 0;
  end;

  { TdxSkinSizeProperty }

  TdxSkinSizeProperty = class(TdxSkinProperty)
  private
    FValue: TSize;
    procedure SetValue(const Value: TSize);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
    function GetValueByIndex(Index: Integer): Integer;
    procedure SetValueByIndex(Index, Value: Integer);

    property Value: TSize read FValue write SetValue;
  published
    property cx: Integer index 0 read GetValueByIndex write SetValueByIndex default 0;
    property cy: Integer index 1 read GetValueByIndex write SetValueByIndex default 0;
  end;

  { TdxSkinBorder }

  TdxSkinBorder = class(TdxSkinProperty)
  private
    FColor: TColor;
    FKind: TcxBorder;
    FThin: Integer;
    procedure SetColor(AValue: TColor);
    procedure SetThin(AValue: Integer);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
    procedure Draw(DC: HDC; const ABounds: TRect); virtual;
    procedure DrawEx(ACanvas: TdxSkinCanvas; const ABounds: TRect); virtual;

    property Kind: TcxBorder read FKind;
  published
    property Color: TColor read FColor write SetColor default clNone;
    property Thin: Integer read FThin write SetThin default 1;
  end;

  { TdxSkinBorders }

  TdxSkinBorders = class(TdxSkinProperty)
  private
    FBorders: array[TcxBorder] of TdxSkinBorder;
    function GetBorder(ABorder: TcxBorder): TdxSkinBorder;
    function GetBorderByIndex(Index: Integer): TdxSkinBorder;
    procedure SetBorderByIndex(Index: Integer; AValue: TdxSkinBorder);
  protected
    procedure CreateBorders;
    procedure DeleteBorders;
    procedure SubItemHandler(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
    procedure Draw(ACanvas: TdxSkinCanvas; const ABounds: TRect); virtual;

    property Items[AKind: TcxBorder]: TdxSkinBorder read GetBorder; default;
  published
    property Left: TdxSkinBorder index 0 read GetBorderByIndex write SetBorderByIndex;
    property Top: TdxSkinBorder index 1 read GetBorderByIndex write SetBorderByIndex;
    property Right: TdxSkinBorder index 2 read GetBorderByIndex write SetBorderByIndex;
    property Bottom: TdxSkinBorder index 3 read GetBorderByIndex write SetBorderByIndex;
  end;

  { TdxSkinStringProperty }

  TdxSkinStringProperty = class(TdxSkinProperty)
  private
    FValue: string;
    procedure SetValue(const AValue: string);
  protected
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    procedure Assign(Source: TPersistent); override;
    function Compare(AProperty: TdxSkinProperty): Boolean; override;
  published
    property Value: string read FValue write SetValue;
  end;

  { TdxSkinControlGroup }

  TdxSkinControlGroup = class(TdxSkinPersistent)
  private
    FElements: TcxObjectList;
    function GetCount: Integer;
    function GetElement(AIndex: Integer): TdxSkinElement;
    function GetSkin: TdxSkin;
    procedure SetElement(AIndex: Integer; AElement: TdxSkinElement);
  protected
    procedure DoSort; override; 
    procedure ReadData(AStream: TStream; const AVersion: TdxSkinVersion); virtual;
    procedure WriteData(AStream: TStream); virtual;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function AddElement(const AName: string): TdxSkinElement;
    function AddElementEx(const AName: string; AElementClass: TdxSkinElementClass): TdxSkinElement;
    procedure Clear;
    procedure ClearModified;
    procedure Delete(AIndex: Integer);
    procedure RemoveElement(AElement: TdxSkinElement);
    function GetElementByName(const AName: string): TdxSkinElement;

    property Count: Integer read GetCount;
    property Elements[Index: Integer]: TdxSkinElement read GetElement write SetElement;
    property Skin: TdxSkin read GetSkin;
  end;

  { TdxSkinImage }

  TdxSkinElementState = (esNormal, esHot, esPressed, esDisabled, esActive,
    esFocused, esDroppedDown, esChecked, esHotCheck, esActiveDisabled,
    esCheckPressed);

  TdxSkinElementStates = set of TdxSkinElementState;

  TdxSkinImageLayout = (ilHorizontal, ilVertical);
  TdxSkinStretchMode = (smStretch, smTile, smNoResize);
  TdxSkinElementPartBounds = array[0..2, 0..2] of TRect;
  TdxSkinElementPartVisibility = array[0..2, 0..2] of Boolean;

  TdxSkinImage = class(TPersistent)
  private
    FGradient: TdxSkinGradientMode;
    FGradientBeginColor: TColor;
    FGradientEndColor: TColor;
    FImageLayout: TdxSkinImageLayout;
    FIsDirty: Boolean;
    FMargins: TcxRect;
    FOnChange: TNotifyEvent;
    FOwner: TdxSkinElement;
    FPartSizing: TdxSkinElementPartVisibility;
    FPartsVisibility: TdxSkinElementPartVisibility;
    FSize: TSize;
    FSourceName: string;
    FStateBounds: array[TdxSkinElementState] of TRect;
    FStateCount: Integer;
    FStates: TdxSkinElementStates;
    FStretch: TdxSkinStretchMode;
    FTexture: TdxPNGImage;
    FTransparentColor: TColor;
    function GetEmpty: Boolean;
    function GetImageCount: Integer;
    function GetIsGradientParamsAssigned: Boolean;
    function GetName: string;
    function GetPartSizing(Col, Row: Integer): Boolean;
    function GetPartVisible(Col, Row: Integer): Boolean;
    function GetSize: TSize;
    function GetSourceName: string;
    function GetStateBounds(AImageIndex: Integer; AState: TdxSkinElementState): TRect;
    function GetStateCount: Integer;
    procedure SetGradientBeginColor(AValue: TColor);
    procedure SetGradientEndColor(AValue: TColor);
    procedure SetGradientMode(AValue: TdxSkinGradientMode);
    procedure SetImageLayout(AValue: TdxSkinImageLayout);
    procedure SetMargins(AValue: TcxRect);
    procedure SetName(const AValue: string);
    procedure SetStates(AValue: TdxSkinElementStates);
    procedure SetStretch(AValue: TdxSkinStretchMode);
    procedure SetTransparentColor(AValue: TColor);
    procedure SubItemHandler(Sender: TObject);
  protected
    procedure CheckInfo;
    procedure CheckState(var AState: TdxSkinElementState);
    procedure DoChange; virtual;
    procedure DoInitializeInfo; virtual;
    procedure DrawPart(ACanvas: TdxSkinCanvas; const ADest, ASource: TRect;
      APartSizing, AIsCenterPart: Boolean); virtual;
    procedure DrawPartByGradient(ACanvas: TdxSkinCanvas; const R: TRect);
    function GetOwner: TPersistent; override;
    procedure InitializePartsInfo(const ABounds: TRect; var AParts;
      var AVisibility; ACheckMargins: Boolean);
    procedure ReadData(AStream: TStream);
    procedure WriteData(AStream: TStream);

    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
    property IsDirty: Boolean read FIsDirty write FIsDirty;

    property IsGradientParamsAssigned: Boolean read GetIsGradientParamsAssigned;
    property PartSizing[Col, Row: Integer]: Boolean read GetPartSizing;
    property PartVisible[Col, Row: Integer]: Boolean read GetPartVisible;
  public
    constructor Create(AOwner: TdxSkinElement); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    function Compare(AImage: TdxSkinImage): Boolean; virtual; 
    procedure Draw(DC: HDC; const ARect: TRect; AImageIndex: Integer = 0;
      AState: TdxSkinElementState = esNormal); virtual;
    procedure DrawEx(ACanvas: TdxSkinCanvas; const ARect: TRect;
      AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal); virtual;
    procedure GetBitmap(AImageIndex: Integer; AState: TdxSkinElementState;
      ABitmap: TBitmap;  ABkColor: TColor = clNone);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure SetStateMapping(AStateOrder: array of TdxSkinElementState);

    property Empty: Boolean read GetEmpty;
    property ImageCount: Integer read GetImageCount;
    property Name: string read GetName write SetName;
    property Owner: TdxSkinElement read FOwner;
    property Size: TSize read GetSize;
    property SourceName: string read GetSourceName;
    property StateBounds[ImageIndex: Integer; State: TdxSkinElementState]: TRect read GetStateBounds;
    property StateCount: Integer read GetStateCount;
    property Texture: TdxPNGImage read FTexture;
  published
    property Gradient: TdxSkinGradientMode read FGradient write SetGradientMode default gmHorizontal;
    property GradientBeginColor: TColor read FGradientBeginColor write SetGradientBeginColor default clNone;
    property GradientEndColor: TColor read FGradientEndColor write SetGradientEndColor default clNone;
    property ImageLayout: TdxSkinImageLayout read FImageLayout write SetImageLayout default ilHorizontal;
    property Margins: TcxRect read FMargins write SetMargins;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property States: TdxSkinElementStates read FStates write SetStates;
    property Stretch: TdxSkinStretchMode read FStretch write SetStretch default smStretch;
  end;

  { TdxSkinElement }

  TdxSkinElement = class(TdxSkinPersistent)
  private
    FAlpha: Byte;
    FBorders: TdxSkinBorders;
    FBrush: GpBrush;
    FCanvas: TdxSkinCanvas;
    FColor: TColor;
    FContentOffset: TcxRect;
    FGlyph: TdxSkinImage;
    FImage: TdxSkinImage;
    FImageCount: Integer;
    FIsColorAssigned: Boolean;
    FMinSize: TcxSize;
    FTextColor: TColor;
    function GetGroup: TdxSkinControlGroup;
    function GetIsAlphaUsed: Boolean;
    function GetPath: string;
    function GetSize: TSize;
    procedure SetAlpha(AValue: Byte);
    procedure SetBorders(AValue: TdxSkinBorders);
    procedure SetColor(AValue: TColor);
    procedure SetContentOffset(AValue: TcxRect);
    procedure SetGlyph(AValue: TdxSkinImage);
    procedure SetImage(AValue: TdxSkinImage);
    procedure SetImageCount(AValue: Integer);
    procedure SetMinSize(AValue: TcxSize);
    procedure SetTextColor(AValue: TColor);
  protected
    function CompareProperties(AElement: TdxSkinElement): Boolean; virtual;
    function ExpandName(ABitmap: TdxSkinImage): string; virtual;
    procedure FillBackgroundByColor(ACanvas: TdxSkinCanvas; const ARect: TRect);
    procedure InternalDraw(ACanvas: TdxSkinCanvas; const ARect: TRect;
      AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);
    procedure ReadData(AStream: TStream; AVersion: TdxSkinVersion); virtual;
    procedure WriteData(AStream: TStream; AVersion: TdxSkinVersion); virtual;
    property Brush: GpBrush read FBrush;
    property Canvas: TdxSkinCanvas read FCanvas;
    property IsColorAssigned: Boolean read FIsColorAssigned;
  public
    constructor Create(AOwner: TPersistent; const AName: string); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Compare(AElement: TdxSkinElement): Boolean; virtual;
    procedure Draw(DC: HDC; const ARect: TRect; AImageIndex: Integer = 0;
      AState: TdxSkinElementState = esNormal); virtual;
    procedure SetStateMapping(AStateOrder: array of TdxSkinElementState);

    property Group: TdxSkinControlGroup read GetGroup;
    property IsAlphaUsed: Boolean read GetIsAlphaUsed;
    property Path: string read GetPath;
    property Size: TSize read GetSize;
  published
    property Color: TColor read FColor write SetColor default clDefault;
    property Alpha: Byte read FAlpha write SetAlpha default 255;
    property Borders: TdxSkinBorders read FBorders write SetBorders;
    property ContentOffset: TcxRect read FContentOffset write SetContentOffset;
    property Glyph: TdxSkinImage read FGlyph write SetGlyph;
    property MinSize: TcxSize read FMinSize write SetMinSize;
    property TextColor: TColor read FTextColor write SetTextColor default clDefault;
    property Image: TdxSkinImage read FImage write SetImage;
    property ImageCount: Integer read FImageCount write SetImageCount default 1;
  end;

  { TdxSkinEmptyElement }

  TdxSkinEmptyElement = class(TdxSkinElement)
  public
    procedure Draw(DC: HDC; const ARect: TRect; AImageIndex: Integer = 0;
      AState: TdxSkinElementState = esNormal); override;
  end;

  { TdxSkinPartStream }

  TdxSkinPartStream = class(TStream)
  private
    FPosEnd: Longint;
    FPosStart: Longint;
    FSource: TStream;
  protected
  {$IFDEF DELPHI7}
    function GetSize: Int64; override;
  {$ENDIF}
  public
    constructor Create(ASource: TStream); virtual;
    procedure Initialize(const APosStart, APosEnd: Longint);
    procedure InitializeEx(ASource: TStream; const APosStart, APosEnd: Longint);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;

    property PosEnd: Longint read FPosEnd;
    property PosStart: Longint read FPosStart;
    property Source: TStream read FSource;
  end;

  { TdxSkinElementCache }

  TdxSkinElementCache = class(TObject)
  private
    FCache: GpBitmap;
    FCacheOpaque: TcxBitmap;
    FElement: TdxSkinElement;
    FImageIndex: Integer;
    FIsAlphaBlendUsed: Boolean;
    FRect: TRect;
    FState: TdxSkinElementState;
  protected
    procedure FreeCache;
    procedure InitCache(R: TRect);
    procedure InitOpaqueCache(R: TRect);
    // Properties
    property Element: TdxSkinElement read FElement;
    property ImageIndex: Integer read FImageIndex;
    property IsAlphaBlendUsed: Boolean read FIsAlphaBlendUsed;
    property State: TdxSkinElementState read FState;
  public
    destructor Destroy; override;
    procedure CheckCacheState(AElement: TdxSkinElement; const R: TRect;
      AState: TdxSkinElementState = esNormal; AImageIndex: Integer = 0);
    procedure Draw(DC: HDC; const R: TRect);
    procedure DrawEx(DC: HDC; AElement: TdxSkinElement; const R: TRect;
      AState: TdxSkinElementState = esNormal; AImageIndex: Integer = 0);
  end;

  { TdxSkinElementCacheList }

  TdxSkinElementCacheList = class(TcxObjectList)
  private
    FCacheListLimit: Integer;
    procedure CheckListLimits;
    function FindElementCache(AElement: TdxSkinElement; const R: TRect;
      out AElementCache: TdxSkinElementCache): Boolean;
    function GetElementCache(AIndex: Integer): TdxSkinElementCache;
  public
    constructor Create;
    procedure DrawElement(DC: HDC; AElement: TdxSkinElement; const R: TRect;
      AState: TdxSkinElementState = esNormal; AImageIndex: Integer = 0);
    property CacheListLimit: Integer read FCacheListLimit write FCacheListLimit;
    property ElementCache[Index: Integer]: TdxSkinElementCache read GetElementCache;
  end;

function dxSkinRegisteredPropertyTypes: TList;

procedure dxSkinInvalidOperation(const AMessage: string);
procedure dxSkinCheck(ACondition: Boolean; const AMessage: string);
procedure dxSkinCheckVersion(AVersion: Double);
function dxSkinCheckSignature(AStream: TStream; out AVersion: TdxSkinVersion): Boolean;
function dxSkinCheckSkinElement(AElement: TdxSkinElement): TdxSkinElement;
procedure dxSkinWriteSignature(AStream: TStream);

implementation

const
  dxSkinElementCacheListLimit = 8;
  
  PartSizing: array[0..2, 0..2] of Boolean =
   ((False, True, False),
    (True, True, True),
    (False, True, False));

var
  dxSkinEmptyElement: TdxSkinElement;
  PartStream: TdxSkinPartStream;
  RegisteredPropertyTypes: TList;

type
  TdxSkinARGBQuad = packed record
    rgbRed: Byte;
    rgbGreen: Byte;
    rgbBlue: Byte;
    Alpha: Byte;
  end;

  TRect2Int = array[TcxBorder] of Integer;

function ColorToARGB(AColor: TColor; Alpha: Byte = 255): Integer;
begin
  with TRGBQUAD(ColorToRgb(AColor)) do
  begin
    TdxSkinARGBQuad(Result).Alpha := Alpha;
    TdxSkinARGBQuad(Result).rgbRed := rgbRed;
    TdxSkinARGBQuad(Result).rgbGreen := rgbGreen;
    TdxSkinARGBQuad(Result).rgbBlue := rgbBlue;
  end;
end;

function ReadStringFromStream(AStream: TStream): string;
var
  L: Integer;
  AStr: AnsiString;
begin
  AStream.Read(L, SizeOf(L));
  SetLength(AStr, L);
  if L > 0 then
    AStream.ReadBuffer(AStr[1], L);
  Result := dxAnsiStringToString(AStr);
end;

function ReadInteger(AStream: TStream): Integer;
begin
  AStream.Read(Result, SizeOf(Result));
end;

procedure WriteStringToStream(AStream: TStream; const AValue: string);
var
  AStr: AnsiString;
  L: Integer;
begin
  AStr := dxStringToAnsiString(AValue);
  L := Length(AStr);
  AStream.Write(L, SizeOf(L));
  if L > 0 then
    AStream.WriteBuffer(AStr[1], L);
end;

procedure WriteInteger(AStream: TStream; const AValue: Integer);
begin
  AStream.Write(AValue, SizeOf(AValue));
end;

function dxSkinRegisteredPropertyTypes: TList;
begin
  Result := RegisteredPropertyTypes; 
end;

procedure dxSkinInvalidOperation(const AMessage: string);
begin
  raise EdxSkin.Create(AMessage);
end;

procedure dxSkinCheck(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
     dxSkinInvalidOperation(AMessage);
end;

procedure dxSkinCheckVersion(AVersion: Double);
begin
  if AVersion < 1 then
    raise EdxSkin.Create(sdxOldFormat);
end;

function dxSkinCheckSignature(AStream: TStream; out AVersion: TdxSkinVersion): Boolean;
var
  ASignature: TdxSkinSignature;
begin
  AStream.Position := AStream.Position + SizeOf(Integer);
  Result := AStream.Read(ASignature, SizeOf(ASignature)) = SizeOf(ASignature);
  Result := Result and (ASignature = dxSkinSignature);
  if Result then
    AStream.ReadBuffer(AVersion, SizeOf(AVersion));
end;

function dxSkinCheckSkinElement(AElement: TdxSkinElement): TdxSkinElement;
begin
  Result := AElement;
  if Result = nil then
    Result := dxSkinEmptyElement;
end;

procedure dxSkinWriteSignature(AStream: TStream);
var
  ALen: Integer;
begin
  ALen := SizeOf(dxSkinSignature);
  AStream.Write(ALen, SizeOf(ALen));
  AStream.Write(dxSkinSignature[0], SizeOf(dxSkinSignature));
  AStream.Write(dxSkinStreamVersion, SizeOf(dxSkinStreamVersion));
end;

function dxCompareByName(AItem1, AItem2: TdxSkinCustomPersistentObject): Integer;
begin
  Result := AnsiCompareStr(AItem1.Name, AItem2.Name);
end;

function FindItemByName(AItemsList: TcxObjectList; const AName: string): TObject;
var
  L, H, AIndex, C: Integer;
begin
  Result := nil;
  L := 0;
  H := AItemsList.Count - 1;
  while L <= H do
  begin
    AIndex := (L + H) div 2;
    C := AnsiCompareStr(TdxSkinCustomPersistentObject(AItemsList[AIndex]).Name, AName);
    if C < 0 then
      L := AIndex + 1
    else
    begin
      H := AIndex - 1;
      if C = 0 then
      begin
        Result := TdxSkinCustomPersistentObject(AItemsList[AIndex]);
        Break;
      end
    end;
  end;
end;

{ TdxSkinPersistent }

constructor TdxSkinPersistent.Create(
  AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  FProperties := TcxObjectList.Create;
end;

destructor TdxSkinPersistent.Destroy;
begin
  FProperties.Free;
  inherited Destroy; 
end;

procedure TdxSkinPersistent.Assign(Source: TPersistent);
var
  I: Integer;
begin
  BeginUpdate;
  try
    if Source is TdxSkinPersistent then
    begin
      for I := 0 to TdxSkinPersistent(Source).PropertyCount - 1 do
        AddSubItem(TdxSkinPersistent(Source).Properties[I].Clone, FProperties);
    end
    else
      inherited Assign(Source);
  finally
    EndUpdate;
  end;
end;

function TdxSkinPersistent.AddProperty(
  const AName: string; APropertyClass: TdxSkinPropertyClass): TdxSkinProperty;
begin
  Result := APropertyClass.Create(Self, AName);
  AddSubItem(Result, FProperties);
end;

procedure TdxSkinPersistent.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TdxSkinPersistent.CancelUpdate;
begin
  Dec(FLockCount);
end;

procedure TdxSkinPersistent.DeleteProperty(const AProperty: TdxSkinProperty);
begin
  if FProperties.Remove(AProperty) <> -1 then
  begin
    AProperty.Free;
    Changed;
  end;
end;

procedure TdxSkinPersistent.EndUpdate;
begin
  Dec(FLockCount);
  if FLockCount = 0 then
    Changed;
end;

procedure TdxSkinPersistent.Sort;
begin
  SetSorted(True);
end;

procedure TdxSkinPersistent.AddSubItem(
  AInstance: TdxSkinCustomPersistentObject; AList: TcxObjectList);
begin
  AInstance.FOwner := Self;
  AInstance.OnChange := SubItemHandler;
  AList.Add(AInstance);
  Changed;
end;

procedure TdxSkinPersistent.Changed;
begin
  Modified := True; 
  FSorted := False;
  if LockCount = 0 then
    DoChange;
end;

procedure TdxSkinPersistent.DoSort;
begin
  FProperties.Sort(TListSortCompare(@dxCompareByName));
end;

procedure TdxSkinPersistent.SubItemHandler(Sender: TObject);
begin
  Changed;
end;

procedure TdxSkinPersistent.ReadProperties(AStream: TStream);
var
  I: Integer;
  APropClass: TdxSkinPropertyClass;
begin
  for I := 0 to ReadInteger(AStream) - 1 do
  begin
    APropClass := TdxSkinPropertyClass(FindClass(ReadStringFromStream(AStream)));
    AddProperty(ReadStringFromStream(AStream), APropClass).ReadData(AStream);
  end;
end;

procedure TdxSkinPersistent.WriteProperties(AStream: TStream);
var
  I: Integer;
begin
  WriteInteger(AStream, PropertyCount);
  for I := 0 to PropertyCount -1 do
    Properties[I].WriteToStream(AStream);
end;

function TdxSkinPersistent.GetPropertyByName(const AName: string): TdxSkinProperty;
begin
  Sort;
  Result := TdxSkinProperty(FindItemByName(FProperties, AName));
end;

function TdxSkinPersistent.GetPropertyCount: Integer;
begin
  Result := FProperties.Count;
end;

function TdxSkinPersistent.GetProperty(Index: Integer): TdxSkinProperty;
begin
  Result := FProperties[Index] as TdxSkinProperty;
end;

procedure TdxSkinPersistent.SetSorted(AValue: Boolean);
begin
  if AValue <> FSorted then
  begin
    FSorted := AValue;
    if AValue then
      DoSort;
  end;
end;

{ TdxSkin }

constructor TdxSkin.Create(const AName: string;
  ALoadOnCreate: Boolean; hInst: THandle);
begin
  inherited Create(nil, AName);
  FListeners := TInterfaceList.Create;
  FColors := TcxObjectList.Create;
  FGroups := TcxObjectList.Create;
  FVersion := dxSkinStreamVersion;
  FName := AName;
  if ALoadOnCreate then
    LoadFromResource(hInst);
end;

destructor TdxSkin.Destroy;
begin
  FListeners.Free;
  FColors.Free;
  FGroups.Free;
  inherited Destroy;
end;

procedure TdxSkin.ClearModified;
var
  I: Integer;
begin
  FModified := False;
  for I := 0 to GroupCount - 1 do
    Groups[I].ClearModified;
end;

function TdxSkin.Clone(const AName: string): TdxSkin;
var
  AClass: TdxSkinClass;
begin
  AClass := TdxSkinClass(ClassType);
  Result := AClass.Create(Name, False, 0);
  Result.Assign(Self);
end;

procedure TdxSkin.Assign(Source: TPersistent);
var
  I: Integer;
begin
  BeginUpdate;
  try
    if Source is TdxSkin then
    begin
      // clone colors
      for I := 0 to TdxSkin(Source).ColorCount - 1 do
        AddSubItem(TdxSkin(Source).Colors[I].Clone, FColors);
      for I := 0 to TdxSkin(Source).GroupCount - 1 do
        AddSubItem(TdxSkin(Source).Groups[I].Clone, FGroups);
    end;
    inherited Assign(Source);
  finally
    EndUpdate;
  end;
end;

function TdxSkin.AddColor(
  const AName: string; const AColor: TColor): TdxSkinColor;
begin
  Result := TdxSkinColor.Create(Self, AName);
  BeginUpdate;
  try
    AddSubItem(Result, FColors);
    Result.Value := AColor;
  finally
    EndUpdate;
  end;
end;

function TdxSkin.AddGroup(const AName: string): TdxSkinControlGroup;
begin
  Result := TdxSkinControlGroup.Create(Self, AName);
  AddSubItem(Result, FGroups);
end;

procedure TdxSkin.AddListener(AListener: IdxSkinChangeListener);
begin
  Listeners.Add(AListener);
end;

procedure TdxSkin.Clear;
begin
  FGroups.Clear;
  FColors.Clear;
  FProperties.Clear;
end;

function TdxSkin.GetColorByName(const AName: string): TdxSkinColor;
begin
  Sort;
  Result := TdxSkinColor(FindItemByName(FColors, AName));
end;

procedure TdxSkin.DeleteProperty(const AProperty: TdxSkinProperty);
begin
  inherited DeleteProperty(AProperty);
  if FColors.Remove(AProperty) <> -1 then
  begin
    AProperty.Free;
    Changed;
  end;
end;

function TdxSkin.GetGroupByName(const AName: string): TdxSkinControlGroup;
begin
  Sort;
  Result := TdxSkinControlGroup(FindItemByName(FGroups, AName));
end;

procedure TdxSkin.LoadFromStream(AStream: TStream);
var
  I: Integer;
begin
  if not CheckGdiPlus then Exit;
  if not dxSkinCheckSignature(AStream, FVersion) then
    raise EdxSkin.Create(sdxSkinInvalidStreamFormat);
  FName := ReadStringFromStream(AStream);
  dxSkinCheckVersion(FVersion);
  BeginUpdate;
  try
    Clear;
    for I := 0 to ReadInteger(AStream) - 1 do
    begin
      if FVersion >= 0.92 then
        ReadStringFromStream(AStream);
      AddColor(ReadStringFromStream(AStream), ReadInteger(AStream));
    end;
    ReadProperties(AStream);
    for I := 0 to ReadInteger(AStream) - 1 do
      AddGroup(ReadStringFromStream(AStream)).ReadData(AStream, Version);
  finally
    EndUpdate;
  end;
end;

procedure TdxSkin.LoadFromFile(const AFileName: string);
var
  AStream: TStream;
begin
  AStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    LoadFromStream(AStream);
  finally
    AStream.Free
  end;
end;

procedure TdxSkin.RemoveListener(AListener: IdxSkinChangeListener);
begin
  Listeners.Remove(AListener);
end;

procedure TdxSkin.SaveToFile(const AFileName: string);
var
  AStream: TStream;
begin
  AStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(AStream);
  finally
    AStream.Free
  end;
end;

procedure TdxSkin.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  dxSkinWriteSignature(AStream);
  WriteStringToStream(AStream, Name);
  WriteInteger(AStream, ColorCount);
  for I := 0 to ColorCount - 1 do
    Colors[I].WriteToStream(AStream);
  WriteProperties(AStream);
  WriteInteger(AStream, GroupCount);
  for I := 0 to GroupCount - 1 do
    Groups[I].WriteData(AStream);
end;


procedure TdxSkin.DoChange;
begin
  NotifyListeners;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TdxSkin.DoSort;
begin
  inherited DoSort;
  FGroups.Sort(TListSortCompare(@dxCompareByName));
  FColors.Sort(TListSortCompare(@dxCompareByName));
end;

procedure TdxSkin.NotifyListeners;
var
  I: Integer;
begin
  Inc(FLockCount);
  try
    for I := 0 to Listeners.Count - 1 do
      IdxSkinChangeListener(Listeners[I]).SkinChanged(Self);
  finally
    Dec(FLockCount);
  end;
end;

procedure TdxSkin.LoadFromResource(hInst: THandle);
var
  AStream: TStream;
begin
  AStream := TResourceStream.Create(hInst, Name, PChar(sdxResourceType));
  try
    LoadFromStream(AStream);
  finally
    AStream.Free;
  end;
end;

function TdxSkin.GetColor(Index: Integer): TdxSkinColor;
begin
  Result := FColors[Index] as TdxSkinColor;  
end;

function TdxSkin.GetColorCount: Integer;
begin
  Result := FColors.Count;
end;

function TdxSkin.GetGroup(Index: Integer): TdxSkinControlGroup;
begin
  Result := FGroups[Index] as TdxSkinControlGroup;
end;

function TdxSkin.GetGroupCount: Integer;
begin
  Result := FGroups.Count;
end;

procedure TdxSkin.SetName(const Value: string);
begin
  FName := Value;
end;

{  TdxSkinImage }

constructor TdxSkinImage.Create(AOwner: TdxSkinElement);
begin
  FOwner := AOwner;
  FTexture := TdxPNGImage.Create();
  FMargins := TcxRect.Create(Self);
  FMargins.OnChange := SubItemHandler;
  FGradientBeginColor := clNone;
  FGradientEndColor := clNone;
  FGradient := gmHorizontal;
  FTransparentColor := clNone;
end;

destructor TdxSkinImage.Destroy;
begin
  FMargins.Free;
  FTexture.Free;
  inherited Destroy;
end;

procedure TdxSkinImage.Assign(Source: TPersistent);
begin
  if not (Source is TdxSkinImage) then Exit;
  if TdxSkinImage(Source).Empty then
    Clear
  else
  begin
    Texture.Assign(TdxSkinImage(Source).Texture);
    FSourceName := TdxSkinImage(Source).SourceName;
    FIsDirty := True;
  end;
  GradientBeginColor := TdxSkinImage(Source).GradientBeginColor;
  GradientEndColor := TdxSkinImage(Source).GradientEndColor;
  Gradient := TdxSkinImage(Source).Gradient;
  ImageLayout := TdxSkinImage(Source).ImageLayout;
  Margins.Assign(TdxSkinImage(Source).Margins);
  States := TdxSkinImage(Source).States;
  Stretch := TdxSkinImage(Source).Stretch;
end;

procedure TdxSkinImage.Clear;
begin
  Texture.Handle := nil;
  FSourceName := '';
  DoChange;
end;

procedure TdxSkinImage.GetBitmap(AImageIndex: Integer; 
  AState: TdxSkinElementState; ABitmap: TBitmap; ABkColor: TColor = clNone);
begin
  ABitmap.FreeImage;
  ABitmap.Width := Size.cx;
  ABitmap.Height := Size.cy;
  if ABkColor <> clNone then
  begin
    if ABkColor <> clDefault then
      ABitmap.Canvas.Brush.Color := ABkColor;
    ABitmap.Canvas.FillRect(Rect(0, 0, Size.cx, Size.cy));
  end;
  Draw(ABitmap.Canvas.Handle, Rect(0, 0, Size.cx, Size.cy), AImageIndex, AState);
end;

procedure TdxSkinImage.LoadFromFile(const AFileName: string);
var
  AFile : TFileStream;
begin
  FSourceName := AFileName;
  AFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Texture.LoadFromStream(AFile);
  finally
    AFile.Free;
  end;
  DoChange;
end;

procedure TdxSkinImage.SaveToFile(const AFileName: string);
begin
  if Empty then Exit;
  Texture.SaveToFile(ChangeFileExt(AFileName, '.png'));
  DoChange;
end;

procedure TdxSkinImage.SetStateMapping(AStateOrder: array of TdxSkinElementState);
var
  ASrc: TRect;
  ASize: TSize;
  ABitmap: TBitmap;
  AIndex, AImageIndex: Integer;
begin
  if Texture.Empty then Exit;
  ABitmap := Texture.GetAsBitmap;
  try
    ASize := Size;
    ASrc := Rect(0, 0, ASize.cx, ASize.cy);
    if ImageLayout = ilHorizontal then
      ASize.cy := 0
    else
      ASize.cx := 0;
    for AImageIndex := 0 to ImageCount - 1 do
      for AIndex := Low(AStateOrder) to High(AStateOrder) do
      begin
        if not (AStateOrder[AIndex] in States) then Continue;
        Texture.StretchDraw(ABitmap.Canvas.Handle,
          StateBounds[AImageIndex, AStateOrder[AIndex]], ASrc);
        OffsetRect(ASrc, ASize.cx, ASize.cy);
      end;
    Texture.SetBitmap(ABitmap);
  finally
    ABitmap.Free;
  end;
end;

procedure TdxSkinImage.CheckInfo;
begin
  if not IsDirty then Exit;
  IsDirty := False;
  DoInitializeInfo;
end;

procedure TdxSkinImage.CheckState(var AState: TdxSkinElementState);
var
  AFirstState: TdxSkinElementState;
begin
  if not (AState in FStates) then
    for AFirstState := Low(TdxSKinElementState) to High(TdxSKinElementState) do
      if AFirstState in FStates then
      begin
        AState := AFirstState;
        Break;
      end;
end;

function TdxSkinImage.Compare(AImage: TdxSkinImage): Boolean; 
begin
  Result := (AImage.ImageLayout = ImageLayout) and (AImage.Empty = Empty) and
    (AImage.States = States) and (AImage.Gradient = Gradient) and
    (AImage.GradientBeginColor = GradientBeginColor) and
    (AImage.GradientEndColor = GradientEndColor) and (AImage.Stretch = Stretch) and
    (AImage.Size.cx = Size.cx) and (AImage.Size.cy = Size.cy) and
    AImage.Margins.IsEqual(Margins.Rect) and Texture.Compare(AImage.Texture);
end;

procedure TdxSkinImage.Draw(DC: HDC; const ARect: TRect;
  AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);
var
  ACanvas: TdxSkinCanvas;
begin
  CheckInfo;
  if (FSize.cx <= 0) or (FSize.cy <= 0) or IsRectEmpty(ARect) or not RectVisible(DC, ARect) then Exit;
  ACanvas := TdxSkinCanvas.Create;
  try
    ACanvas.BeginPaint(DC, ARect);
    DrawEx(ACanvas, ARect, AImageIndex, AState);
    ACanvas.EndPaint;
  finally
    ACanvas.Free;
  end;
end;

procedure TdxSkinImage.DrawEx(ACanvas: TdxSkinCanvas; const ARect: TRect;
  AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);
var
  ACol, ARow: Integer;
  AVisibility: TdxSkinElementPartVisibility;
  DestParts, SourceParts: TdxSkinElementPartBounds;
begin
  if Empty then
  begin
    if IsGradientParamsAssigned then
    begin
      InitializePartsInfo(ARect, DestParts, AVisibility, True);
      DrawPartByGradient(ACanvas, DestParts[1, 1]);
    end;
    Exit;
  end;
  
  CheckInfo;
  CheckState(AState);
  if Stretch = smNoResize then
    ACanvas.DrawImage(Texture, cxRectCenter(ARect, Size), StateBounds[AImageIndex, AState])
  else
  begin
    FillChar(AVisibility, SizeOf(AVisibility), 1);
    InitializePartsInfo(StateBounds[AImageIndex, AState], SourceParts, AVisibility, False);
    InitializePartsInfo(ARect, DestParts, AVisibility, True);
    for ARow := 0 to 2 do
      for ACol := 0 to 2 do
        if AVisibility[ACol, ARow] then
        begin
          DrawPart(ACanvas, DestParts[ACol, ARow], SourceParts[ACol, ARow],
            PartSizing[ACol, ARow], (ACol = 1) and (ARow = 1));
        end;
  end;
end;

procedure TdxSkinImage.DrawPart(ACanvas: TdxSkinCanvas; const ADest: TRect;
  const ASource: TRect; APartSizing, AIsCenterPart: Boolean); 
begin
  if IsGradientParamsAssigned and AIsCenterPart then
    DrawPartByGradient(ACanvas, ADest)
  else
    if not APartSizing then
      ACanvas.DrawImage(Texture, ADest, ASource)
    else
      if Stretch = smTile then
        ACanvas.TileImage(Texture, ADest, ASource)
      else
        ACanvas.StretchDrawImage(Texture, ADest, ASource);
end;

procedure TdxSkinImage.DrawPartByGradient(ACanvas: TdxSkinCanvas; const R: TRect);
begin
  ACanvas.FillRectByGradient(R, GradientBeginColor, GradientEndColor, Gradient);
end;

procedure TdxSkinImage.DoChange;
begin
  IsDirty := True;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TdxSkinImage.DoInitializeInfo;
var
  AState: TdxSkinElementState;
  AParts: TdxSkinElementPartBounds;
  AStateIndices: array[TdxSkinElementState] of Byte;
begin
  FStateCount := 0;
  FillChar(AStateIndices, SizeOf(AStateIndices), 0);
  for AState := Low(TdxSkinElementState) to High(TdxSkinElementState) do
    if AState in States then
    begin
      AStateIndices[AState] := FStateCount;
      Inc(FStateCount);
    end;
  FSize := cxSize(Texture.Width, Texture.Height);
  if StateCount > 0 then
  begin
    if ImageLayout = ilHorizontal then
      FSize.cx := FSize.cx div ImageCount div StateCount
    else
      FSize.cy := FSize.cy div ImageCount div StateCount;
  end;
  for AState := Low(TdxSkinElementState) to High(TdxSkinElementState) do
  begin
    if ImageLayout = ilHorizontal then
      FStateBounds[AState] := Rect(AStateIndices[AState] * FSize.cx,
       0, (AStateIndices[AState] + 1) * FSize.cx, FSize.cy)
    else
      FStateBounds[AState] := Rect(0, AStateIndices[AState] * FSize.cy,
       FSize.cx, (AStateIndices[AState] + 1) * FSize.cy)
  end;
  InitializePartsInfo(Rect(0, 0, FSize.cx, FSize.cy), AParts, FPartsVisibility, False);
end;

function TdxSkinImage.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TdxSkinImage.InitializePartsInfo(const ABounds: TRect;
  var AParts; var AVisibility; ACheckMargins: Boolean);

  procedure MakePart(const ALeft, ATop, ARight, ABottom: Integer;
    var ARect: TRect; var AVisible: Boolean);
  begin
    if not AVisible then Exit;
    ARect.Left := ALeft;
    ARect.Top := ATop;
    ARect.Right := ARight;
    ARect.Bottom := ABottom;
    AVisible := (ALeft < ARight) and (ATop < ABottom);
  end;

  procedure DoCheckMargins(var AMargins: TRect);
  var
    ASize, ADelta, I: Integer;
  begin
    if ACheckMargins then
    begin
      ASize := AMargins.Left + AMargins.Right;
      ADelta := ASize - cxRectWidth(ABounds);
      if ADelta > 0 then
      begin
        for I := 0 to 2 do
        begin
          FPartSizing[0, I] := True;
          FPartSizing[2, I] := True;
        end;
        Dec(AMargins.Left, MulDiv(AMargins.Left, ADelta, ASize));
        Dec(AMargins.Right, MulDiv(AMargins.Right, ADelta, ASize));
      end;
      ASize := AMargins.Top + AMargins.Bottom;
      ADelta := ASize - cxRectHeight(ABounds);
      if ADelta > 0 then
      begin
        Dec(AMargins.Top, MulDiv(AMargins.Top, ADelta, ASize));
        Dec(AMargins.Bottom, MulDiv(AMargins.Bottom, ADelta, ASize));
        for I := 0 to 2 do
        begin
          FPartSizing[I, 0] := True;
          FPartSizing[I, 2] := True;
        end;
      end;
    end;
  end;

var
  AMargins, R: TRect;
begin
  AMargins := Margins.Rect;
  // stretch margins
  Move(dxSkinsCore.PartSizing, FPartSizing, SizeOf(FPartSizing));
  DoCheckMargins(AMargins);
  //
  with AMargins do
  begin
    R := cxRect(ABounds.Left + Left, ABounds.Top + Top,
      ABounds.Right - Right, ABounds.Bottom - Bottom);
    // check horizontal bounds
    if R.Left > ABounds.Right then
      R.Left := ABounds.Right;
    if R.Left > R.Right then
      R.Right := R.Left;
    if R.Right > ABounds.Right then
      R.Right := ABounds.Right;
    // check vertical bounds
    if R.Top > ABounds.Bottom then
      R.Top := ABounds.Bottom;
    if R.Top > R.Bottom then
      R.Bottom := R.Top;
    if R.Bottom > ABounds.Bottom then
      R.Bottom := ABounds.Bottom;
  end;
  // top line
  MakePart(ABounds.Left, ABounds.Top, R.Left, R.Top,
    TdxSkinElementPartBounds(AParts)[0, 0],
    TdxSkinElementPartVisibility(AVisibility)[0, 0]);
  MakePart(R.Left, ABounds.Top, R.Right, R.Top,
    TdxSkinElementPartBounds(AParts)[1, 0],
    TdxSkinElementPartVisibility(AVisibility)[1, 0]);
  MakePart(R.Right, ABounds.Top, ABounds.Right, R.
    Top, TdxSkinElementPartBounds(AParts)[2, 0],
    TdxSkinElementPartVisibility(AVisibility)[2, 0]);
  // middle line
  MakePart(ABounds.Left, R.Top, R.Left, R.Bottom,
    TdxSkinElementPartBounds(AParts)[0, 1],
    TdxSkinElementPartVisibility(AVisibility)[0, 1]);
  MakePart(R.Left, R.Top, R.Right, R.Bottom,
    TdxSkinElementPartBounds(AParts)[1, 1],
    TdxSkinElementPartVisibility(AVisibility)[1, 1]);
  MakePart(R.Right, R.Top, ABounds.Right, R.Bottom,
    TdxSkinElementPartBounds(AParts)[2, 1],
    TdxSkinElementPartVisibility(AVisibility)[2, 1]);
  // bottom line
  MakePart(ABounds.Left, R.Bottom, R.Left, ABounds.Bottom,
    TdxSkinElementPartBounds(AParts)[0, 2],
    TdxSkinElementPartVisibility(AVisibility)[0, 2]);
  MakePart(R.Left, R.Bottom, R.Right, ABounds.Bottom,
    TdxSkinElementPartBounds(AParts)[1, 2],
    TdxSkinElementPartVisibility(AVisibility)[1, 2]);
  MakePart(R.Right, R.Bottom, ABounds.Right, ABounds.Bottom,
    TdxSkinElementPartBounds(AParts)[2, 2],
    TdxSkinElementPartVisibility(AVisibility)[2, 2]);
end;

function TdxSkinImage.GetEmpty: Boolean;
begin
  Result := (FSourceName = '') and Texture.Empty;
end;

function TdxSkinImage.GetImageCount: Integer;
begin
  Result := Owner.ImageCount;
end;

function TdxSkinImage.GetIsGradientParamsAssigned: Boolean;
begin
  Result := GradientBeginColor <> clNone;
end;

function TdxSkinImage.GetName: string;
begin
  if Empty then
    Result := ''
  else
    Result := Owner.ExpandName(Self);
end;

function TdxSkinImage.GetPartSizing(Col, Row: Integer): Boolean;
begin
  Result := FPartSizing[Col, Row];
end;

function TdxSkinImage.GetPartVisible(Col, Row: Integer): Boolean;
begin
  Result := FPartsVisibility[Col, Row];
end;

function TdxSkinImage.GetSize: TSize;
begin
  CheckInfo;
  Result := FSize;
end;

function TdxSkinImage.GetSourceName: string;
begin
  Result := FSourceName;
  if (Result = '') and not Empty then
    Result := Owner.Path + Name;
end;

function TdxSkinImage.GetStateBounds(
  AImageIndex: Integer; AState: TdxSkinElementState): TRect;
begin
  CheckInfo;
  Result := FStateBounds[AState];
  if AImageIndex > 0 then
  begin
    if ImageLayout = ilHorizontal then
      OffsetRect(Result, StateCount * AImageIndex * Size.cx, 0)
    else
      OffsetRect(Result, 0, StateCount * AImageIndex * Size.cy)
  end;
end;

function TdxSkinImage.GetStateCount: Integer;
begin
  CheckInfo;
  Result := FStateCount;
end;

procedure TdxSkinImage.ReadData(AStream: TStream);
var
  APos, ASize: Integer;
begin
  AStream.Read(FMargins.Data^, SizeOf(TRect));
  AStream.Read(FImageLayout, SizeOf(TdxSkinImageLayout));
  AStream.Read(FStates, SizeOf(TdxSkinElementStates));
  AStream.Read(FStretch, SizeOf(FStretch));
  if Owner.Group.Skin.Version >= 1.02 then
  begin
    AStream.Read(FGradientBeginColor, SizeOf(FGradientBeginColor));
    AStream.Read(FGradientEndColor, SizeOf(FGradientEndColor));
    AStream.Read(FGradient, SizeOf(FGradient));
  end;
  AStream.Read(ASize, SizeOf(Integer));
  APos := AStream.Position;
  if ASize > 0 then
  begin
    PartStream.InitializeEx(AStream, AStream.Position, AStream.Position + ASize);
    Texture.LoadFromStream(PartStream);
  end;
  AStream.Position := APos + ASize;
  IsDirty := True;
end;

procedure TdxSkinImage.WriteData(AStream: TStream);
var
  ASize: Integer;
  APNGStream: TMemoryStream;
begin
  AStream.Write(Margins.Data^, SizeOf(TRect));
  AStream.Write(FImageLayout, SizeOf(TdxSkinImageLayout));
  AStream.Write(FStates, SizeOf(TdxSkinElementStates));
  AStream.Write(FStretch, SizeOf(FStretch));
  AStream.Write(FGradientBeginColor, SizeOf(FGradientBeginColor));
  AStream.Write(FGradientEndColor, SizeOf(FGradientEndColor));
  AStream.Write(FGradient, SizeOf(FGradient));
  APNGStream := TMemoryStream.Create;
  try
    if not Empty then
      Texture.SaveToStream(APNGStream);
    ASize := APNGStream.Size;
    AStream.Write(ASize, SizeOf(Integer));
    if ASize > 0 then
    begin
      APNGStream.Position := 0;
      AStream.Write(APNGStream.Memory^, APNGStream.Size);
    end;
  finally
    APNGStream.Free;
  end;
end;

procedure TdxSkinImage.SetGradientBeginColor(AValue: TColor);
begin
  if AValue <> FGradientBeginColor then
  begin
    FGradientBeginColor := AValue;
    DoChange;
  end;
end;

procedure TdxSkinImage.SetGradientEndColor(AValue: TColor);
begin
  if AValue <> GradientEndColor then
  begin
    FGradientEndColor := AValue;
    DoChange;
  end;
end;

procedure TdxSkinImage.SetGradientMode(AValue: TdxSkinGradientMode);
begin
  if AValue <> FGradient then
  begin
    FGradient := AValue;
    DoChange;
  end;
end;

procedure TdxSkinImage.SetImageLayout(AValue: TdxSkinImageLayout);
begin
  if ImageLayout <> AValue then
  begin
    FImageLayout := AValue;
    DoChange;
  end;
end;

procedure TdxSkinImage.SetMargins(AValue: TcxRect);
begin
  FMargins.Assign(AValue);
end;

procedure TdxSkinImage.SetStates(AValue: TdxSkinElementStates);
begin
  if FStates <> AValue then
  begin
    FStates := AValue;
    DoChange;          
  end;
end;

procedure TdxSkinImage.SetStretch(AValue: TdxSkinStretchMode);
begin
  if Stretch <> AValue then
  begin
    FStretch := AValue;
    DoChange;
  end; 
end;

procedure TdxSkinImage.SetTransparentColor(AValue: TColor);
begin
  if AValue <> TransparentColor then
  begin
    FTransparentColor := AValue;
    DoChange;
  end;
end;

procedure TdxSkinImage.SetName(const AValue: string);
begin
  LoadFromFile(AValue);
end;

procedure TdxSkinImage.SubItemHandler(Sender: TObject);
begin
  DoChange;
end;

{  TdxSkinCustomPersistentObject }

constructor TdxSkinCustomPersistentObject.Create(
  AOwner: TPersistent; const AName: string);
begin
  FName := AName;
  FOwner := AOwner;
end;

function TdxSkinCustomPersistentObject.Clone: TdxSkinCustomPersistentObject;
var
  AClass: TdxSkinCustomPersistentObjectClass;
begin
  AClass := TdxSkinCustomPersistentObjectClass(ClassType);
  Result := AClass.Create(nil, Name);
  Result.Assign(Self);
end;

procedure TdxSkinCustomPersistentObject.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TdxSkinCustomPersistentObject.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{ TdxSkinProperty }

class procedure TdxSkinProperty.Register;
begin
  RegisteredPropertyTypes.Add(Self);
  RegisterClass(Self);
end;

class procedure TdxSkinProperty.Unregister;
begin
  UnRegisterClass(Self);
  RegisteredPropertyTypes.Remove(Self); 
end;

class function TdxSkinProperty.Description: string;
begin
  Result := StringReplace(ClassName,
    'TdxSkin', '', [rfReplaceAll, rfIgnoreCase]);
  Result :=  StringReplace(Result, 'Property', '', [rfReplaceAll, rfIgnoreCase]);
end;

function TdxSkinProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := False;
end;

procedure TdxSkinProperty.ReadData(Stream: TStream);
begin
end;

procedure TdxSkinProperty.ReadFromStream(Stream: TStream);
begin
  Name := ReadStringFromStream(Stream);
  ReadData(Stream);
end;

procedure TdxSkinProperty.WriteData(Stream: TStream);
begin
end;

procedure TdxSkinProperty.WriteToStream(Stream: TStream);
begin
  WriteStringToStream(Stream, ClassName);
  WriteStringToStream(Stream, Name);
  WriteData(Stream);
end;

{ TdxSkinIntegerProperty }

procedure TdxSkinIntegerProperty.Assign(Source: TPersistent);
begin
  if Source is TdxSkinIntegerProperty then
    Value := TdxSkinIntegerProperty(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinIntegerProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinIntegerProperty) and
    (TdxSkinIntegerProperty(AProperty).Value = Value);
end;

procedure TdxSkinIntegerProperty.ReadData(Stream: TStream);
begin
  Stream.ReadBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinIntegerProperty.WriteData(Stream: TStream);
begin
  Stream.WriteBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinIntegerProperty.SetValue(AValue: Integer);
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    DoChange;
  end;
end;

{ TdxSkinBooleanProperty }

procedure TdxSkinBooleanProperty.Assign(Source: TPersistent);
begin
  if Source is TdxSkinBooleanProperty then
    Value := TdxSkinBooleanProperty(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinBooleanProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinBooleanProperty) and
    (TdxSkinBooleanProperty(AProperty).Value = Value)
end;

procedure TdxSkinBooleanProperty.ReadData(Stream: TStream);
begin
  Stream.ReadBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinBooleanProperty.WriteData(Stream: TStream);
begin
  Stream.WriteBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinBooleanProperty.SetValue(AValue: Boolean);
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    DoChange;
  end;
end;

{ TdxSkinColor }

constructor TdxSkinColor.Create(AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  FValue := clDefault;  
end;

procedure TdxSkinColor.Assign(Source: TPersistent);
begin
  if Source is TdxSkinColor then
    Value := TdxSkinColor(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinColor.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinColor) and
    (TdxSkinColor(AProperty).Value = Value);
end;

procedure TdxSkinColor.ReadData(Stream: TStream);
begin
  Stream.ReadBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinColor.WriteData(Stream: TStream);
begin
  Stream.WriteBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinColor.SetValue(AValue: TColor);
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    DoChange;
  end;
end;

{ TdxSkinRectProperty }

constructor TdxSkinRectProperty.Create(AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  FValue := TcxRect.Create(Self);               
  FValue.OnChange := InternalHandler;
end;

destructor TdxSkinRectProperty.Destroy;
begin
  FValue.Free;
  inherited Destroy;
end;

procedure TdxSkinRectProperty.Assign(Source: TPersistent);
begin
  if Source is TdxSkinRectProperty then
    Value := TdxSkinRectProperty(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinRectProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinRectProperty) and
    TdxSkinRectProperty(AProperty).Value.IsEqual(Value); 
end;

procedure TdxSkinRectProperty.ReadData(Stream: TStream);
var
  ARect: TRect;
begin
  Stream.ReadBuffer(ARect, SizeOf(TRect));
  FValue.Rect := ARect;   
end;

procedure TdxSkinRectProperty.WriteData(Stream: TStream);
begin
  Stream.WriteBuffer(FValue.Rect, SizeOf(TRect));
end;

function TdxSkinRectProperty.GetValueByIndex(Index: Integer): Integer;
begin
  Result := FValue.GetValue(Index);
end;

procedure TdxSkinRectProperty.SetValue(Value: TcxRect);
begin
  FValue.Assign(Value);
end;

procedure TdxSkinRectProperty.SetValueByIndex(Index, Value: Integer);
begin
  FValue.SetValue(Index, Value);
end;

procedure TdxSkinRectProperty.InternalHandler(Sender: TObject);
begin
  DoChange;
end;

{ TdxSkinSizeProperty }

procedure TdxSkinSizeProperty.Assign(Source: TPersistent);
begin
  if Source is TdxSkinSizeProperty then
    Value := TdxSkinSizeProperty(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinSizeProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinSizeProperty);
  if Result then
    with TdxSkinSizeProperty(AProperty) do
      Result := ((Self.Value.cx) = Value.cx) and ((Self.Value.cy) = Value.cy);
end;

function TdxSkinSizeProperty.GetValueByIndex(Index: Integer): Integer;
begin
  if Index = 0 then
    Result := FValue.cx
  else
    Result := FValue.cy
end;

procedure TdxSkinSizeProperty.SetValueByIndex(Index, Value: Integer);
var
  AValue: TSize;
begin
  AValue := FValue;
  if Index = 0 then
    AValue.cx := Value
  else
    AValue.cy := Value;
  SetValue(AValue);
end;

procedure TdxSkinSizeProperty.ReadData(Stream: TStream);
begin
  Stream.ReadBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinSizeProperty.WriteData(Stream: TStream);
begin
  Stream.WriteBuffer(FValue, SizeOf(FValue));
end;

procedure TdxSkinSizeProperty.SetValue(const Value: TSize);
begin
  if (Value.cx <> FValue.cx) or (Value.cy <> FValue.cy) then
  begin
    FValue := Value;
    DoChange;
  end;
end;

{ TdxSkinBorder }
 
constructor TdxSkinBorder.Create(AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  FColor := clNone;
  FThin := 1;
end;

procedure TdxSkinBorder.Assign(Source: TPersistent);
var
  ASource: TdxSkinBorder;
begin
  if not (Source is TdxSkinBorder) then Exit;
  ASource := TdxSkinBorder(Source);
  Color := ASource.Color;
  FKind := ASource.Kind;
  Thin := ASource.Thin;
end;

function TdxSkinBorder.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty is TdxSkinBorder);
  if Result then
    with TdxSkinBorder(AProperty) do
    begin
      Result := (Color = Self.Color) and (Thin = Self.Thin) and
        (Kind = Self.Kind);
    end;
end;

procedure TdxSkinBorder.Draw(DC: HDC; const ABounds: TRect);
var
  ACanvas: TdxSkinCanvas;
begin
  if Color = clNone then Exit;
  ACanvas := TdxSkinCanvas.Create;
  try
    ACanvas.BeginPaint(DC, ABounds);
    DrawEx(ACanvas, ABounds);
    ACanvas.EndPaint;
  finally
    ACanvas.Free;
  end;
end;

procedure TdxSkinBorder.DrawEx(ACanvas: TdxSkinCanvas; const ABounds: TRect);
begin
  if Color = clNone then Exit;
  with ABounds do
    case Kind of
      bLeft:
        ACanvas.FillRectByColor(Rect(Left, Top, Left + Thin, Bottom), Color);
      bTop:
        ACanvas.FillRectByColor(Rect(Left, Top, Right, Top + Thin), Color);
      bRight:
        ACanvas.FillRectByColor(Rect(Right - Thin, Top, Right, Bottom), Color);
      bBottom:
        ACanvas.FillRectByColor(Rect(Left, Bottom - Thin, Right, Bottom), Color);
    end;
end;

procedure TdxSkinBorder.ReadData(Stream: TStream);
var
  AColor: TColor;
begin
  Stream.Read(AColor, SizeOf(FColor));
  Stream.Read(FThin, SizeOf(FThin));
  Color := AColor;
end;

procedure TdxSkinBorder.WriteData(Stream: TStream);
begin
  Stream.Write(FColor, SizeOf(FColor));
  Stream.Write(FThin, SizeOf(FThin));
end;

procedure TdxSkinBorder.SetColor(AValue: TColor);
begin
  if AValue <> FColor then
  begin
    FColor := AValue;
    DoChange;
  end;
end;

procedure TdxSkinBorder.SetThin(AValue: Integer);
begin
  if AValue <> FThin then
  begin
    FThin := AValue;
    DoChange;
  end;
end;

{ TdxSkinBorders }

constructor TdxSkinBorders.Create(AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  CreateBorders;
end;

destructor TdxSkinBorders.Destroy;
begin
  DeleteBorders;
  inherited Destroy;
end;

procedure TdxSkinBorders.Assign(ASource: TPersistent);
var
  ABorder: TcxBorder;
begin
  if ASource is TdxSkinBorders then
  begin
    for ABorder := Low(TcxBorder) to High(TcxBorder) do
      FBorders[ABorder].Assign(TdxSkinBorders(ASource).FBorders[ABorder])
  end
  else
    inherited Assign(ASource);
end;

function TdxSkinBorders.Compare(AProperty: TdxSkinProperty): Boolean;
var
  ASide: TcxBorder;
begin
  Result := (AProperty is TdxSkinBorders);
  if Result then
  begin
    for ASide := Low(TcxBorder) to High(TcxBorder) do
      Result := Items[ASide].Compare(TdxSkinBorders(AProperty).Items[ASide]);
  end;
end;

procedure TdxSkinBorders.Draw(ACanvas: TdxSkinCanvas; const ABounds: TRect);
var
  ASide: TcxBorder;
begin
  for ASide := Low(TcxBorder) to High(TcxBorder) do
    Items[ASide].DrawEx(ACanvas, ABounds);
end;

procedure TdxSkinBorders.CreateBorders;
var
  ASide: TcxBorder;
const
  BorderNames: array[TcxBorder] of string =
    (sdxLeft, sdxTop, sdxRight, sdxBottom);
begin
  for ASide := bLeft to bBottom do
  begin
    FBorders[ASide] := TdxSkinBorder.Create(Self, BorderNames[ASide]);
    FBorders[ASide].FKind := ASide;
    FBorders[ASide].OnChange := SubItemHandler;
  end;
end;

procedure TdxSkinBorders.DeleteBorders;
var
  ASide: TcxBorder;
begin
  for ASide := bLeft to bBottom do
    FBorders[ASide].Free;
end;

procedure TdxSkinBorders.SubItemHandler(Sender: TObject);
begin
  DoChange;
end;

function TdxSkinBorders.GetBorder(ABorder: TcxBorder): TdxSkinBorder;
begin
  Result := FBorders[ABorder];
end;

function TdxSkinBorders.GetBorderByIndex(Index: Integer): TdxSkinBorder;
begin
  Result := FBorders[TcxBorder(Index)];
end;

procedure TdxSkinBorders.SetBorderByIndex(Index: Integer; AValue: TdxSkinBorder);
begin
  FBorders[TcxBorder(Index)].Assign(AValue);
end;

{ TdxSkinStringProperty }

procedure TdxSkinStringProperty.Assign(Source: TPersistent);
begin
  if Source is TdxSkinStringProperty then
    Value := TdxSkinStringProperty(Source).Value
  else
    inherited Assign(Source);
end;

function TdxSkinStringProperty.Compare(AProperty: TdxSkinProperty): Boolean;
begin
  Result := (AProperty.Name = Name) and (AProperty is TdxSkinStringProperty) and
    (AnsiCompareStr(TdxSkinStringProperty(AProperty).Value, Value) = 0);
end;

procedure TdxSkinStringProperty.ReadData(Stream: TStream);
begin
  Value := ReadStringFromStream(Stream);
end;

procedure TdxSkinStringProperty.WriteData(Stream: TStream);
begin
  WriteStringToStream(Stream, Value);
end;

procedure TdxSkinStringProperty.SetValue(const AValue: string);
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    DoChange; 
  end;
end;

{ TdxSkinControlGroup }

constructor TdxSkinControlGroup.Create(
  AOwner: TPersistent; const AName: string); 
begin
  inherited Create(AOwner, AName);
  FElements := TcxObjectList.Create;
end;

destructor TdxSkinControlGroup.Destroy;
begin
  FElements.Free;
  inherited Destroy;
end;

procedure TdxSkinControlGroup.Assign(Source: TPersistent);
var
  I: Integer;
  ASource: TdxSkinControlGroup;
begin
  BeginUpdate;
  try
    if Source is TdxSkinControlGroup then
    begin
      ASource := TdxSkinControlGroup(Source);
      for I := 0 to ASource.Count - 1 do
        AddSubItem(ASource.Elements[I].Clone, FElements);
    end;
    inherited Assign(Source);
  finally
    EndUpdate; 
  end;
end;

function TdxSkinControlGroup.AddElement(const AName: string): TdxSkinElement;
begin
  Result := AddElementEx(AName, TdxSkinElement);
end;

function TdxSkinControlGroup.AddElementEx(
  const AName: string; AElementClass: TdxSkinElementClass): TdxSkinElement;
begin
  Result := AElementClass.Create(Self, AName);
  AddSubItem(Result, FElements);
end;

procedure TdxSkinControlGroup.Clear;
begin
  FElements.Clear;
  FProperties.Clear;
end;

procedure TdxSkinControlGroup.ClearModified;
var
  I: Integer;
begin
  FModified := False;
  for I := 0 to Count - 1 do
    Elements[I].Modified := False;  
end;

procedure TdxSkinControlGroup.Delete(AIndex: Integer);
begin
  FElements[AIndex].Free;
  FElements.Delete(AIndex);
  Changed;
end;

procedure TdxSkinControlGroup.RemoveElement(AElement: TdxSkinElement);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if AElement = Elements[I] then
    begin
      Delete(I);
      Break;
    end;
end;

function TdxSkinControlGroup.GetElementByName(
  const AName: string): TdxSkinElement;
begin
  Sort;
  Result := TdxSkinElement(FindItemByName(FElements, AName));
end;

procedure TdxSkinControlGroup.DoSort;
begin
  inherited DoSort;
  FElements.Sort(TListSortCompare(@dxCompareByName));
end;

procedure TdxSkinControlGroup.ReadData(
  AStream: TStream; const AVersion: TdxSkinVersion);
var
  AIndex: Integer;
begin
  for AIndex := 0 to ReadInteger(AStream) - 1 do
    AddElement(ReadStringFromStream(AStream)).ReadData(AStream, AVersion);
  if AVersion < 0.91 then Exit;
  ReadProperties(AStream);
  Changed;
end;

procedure TdxSkinControlGroup.WriteData(AStream: TStream);
var
  AIndex: Integer;
  AElement: TdxSkinElement;
begin
  WriteStringToStream(AStream, Name);
  WriteInteger(AStream, Count);
  for AIndex := 0 to Count - 1 do
  begin
    AElement := Elements[AIndex];
    WriteStringToStream(AStream, AElement.Name);
    AElement.WriteData(AStream, dxSkinStreamVersion);
  end;
  WriteProperties(AStream);
end;

function TdxSkinControlGroup.GetCount: Integer;
begin
  Result := FElements.Count;
end;

function TdxSkinControlGroup.GetElement(AIndex: Integer): TdxSkinElement;
begin
  Result := FElements[AIndex] as TdxSkinElement;
end;

function TdxSkinControlGroup.GetSkin: TdxSkin;
begin
  Result := GetOwner as TdxSkin;
end;

procedure TdxSkinControlGroup.SetElement(AIndex: Integer; AElement: TdxSkinElement);
begin
  Elements[AIndex].Assign(AElement);
end;

{ TdxSkinElement }

constructor TdxSkinElement.Create(
  AOwner: TPersistent; const AName: string);
begin
  inherited Create(AOwner, AName);
  FCanvas := TdxSkinCanvas.Create;
  FColor := clDefault;
  FImageCount := 1;
  FImage := TdxSkinImage.Create(Self);
  FImage.OnChange := SubItemHandler;
  FContentOffset := TcxRect.Create(Self);
  FContentOffset.OnChange := SubItemHandler;
  FGlyph := TdxSkinImage.Create(Self);
  FGlyph.OnChange := SubItemHandler;
  FAlpha := 255;
  FBorders := TdxSkinBorders.Create(Self, sdxBorders);
  FBorders.OnChange := SubItemHandler;
  FTextColor := clDefault;
  FMinSize := TcxSize.Create(Self);
  FMinSize.OnChange := SubItemHandler;  
end;

destructor TdxSkinElement.Destroy;
begin
  FCanvas.Free;
  FMinSize.Free;
  FContentOffset.Free;
  FImage.Free;
  FGlyph.Free;
  FBorders.Free;
  if FBrush <> nil then
    GdipDeleteBrush(FBrush); 
  inherited Destroy;  
end;

procedure TdxSkinElement.Assign(Source: TPersistent);
var
  ASource: TdxSkinElement;
begin
  if Source is TdxSkinElement then
  begin
    ASource := TdxSkinElement(Source);
    Image.Assign(ASource.Image);
    Glyph.Assign(ASource.Glyph);
    Color := ASource.Color;
    Alpha := ASource.Alpha;
    ContentOffset.Assign(ASource.ContentOffset);
    ImageCount := ASource.ImageCount;
    Borders := ASource.Borders;
    MinSize.Assign(ASource.MinSize);
    TextColor := ASource.TextColor;
  end;
  inherited Assign(Source);
end;

function TdxSkinElement.Compare(AElement: TdxSkinElement): Boolean;
begin
  Result := (AElement.Name = Name) and (Color = AElement.Color) and
    (ImageCount = AElement.ImageCount) and (Alpha = AElement.Alpha) and
    (TextColor = AElement.TextColor) and MinSize.IsEqual(AElement.MinSize) and
    (ContentOffset.IsEqual(AElement.ContentOffset.Rect)) and
    Borders.Compare(AElement.Borders) and CompareProperties(AElement) and
    Image.Compare(AElement.Image) and Glyph.Compare(AElement.Glyph);
end;

procedure TdxSkinElement.Draw(DC: HDC; const ARect: TRect;
  AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);
begin
  if Canvas.IsRectVisible(DC, ARect) then
  begin
    Canvas.BeginPaint(DC, ARect);
    try
      InternalDraw(Canvas, ARect, AImageIndex, AState);
    finally
      Canvas.EndPaint;
    end;
  end;
end;

procedure TdxSkinElement.SetStateMapping(AStateOrder: array of TdxSkinElementState);
begin
  FImage.SetStateMapping(AStateOrder);
  FGlyph.SetStateMapping(AStateOrder);
end;

function TdxSkinElement.CompareProperties(AElement: TdxSkinElement): Boolean;
var
  I: Integer;
begin
  Result := AElement.PropertyCount = PropertyCount;
  if Result then
    for I := 0 to PropertyCount - 1 do
    begin
      Result := AElement.Properties[I].Compare(Properties[I]);
      if not Result then
        Break;
    end;
end;

function TdxSkinElement.ExpandName(ABitmap: TdxSkinImage): string;
begin
  Result := Name + BitmapNameSuffixes[ABitmap = Image]
end;

procedure TdxSkinElement.FillBackgroundByColor(ACanvas: TdxSkinCanvas;
  const ARect: TRect);
begin
  if IsColorAssigned and (Image.Empty or (Image.Stretch = smNoResize) or IsAlphaUsed) then
  begin
    if Alpha = 255 then
      ACanvas.FillRectByColor(ARect, Color)
    else
      GdipFillRectangleI(ACanvas.Graphics, Brush, ARect.Left, ARect.Top,
        ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
  end;
end;

procedure TdxSkinElement.InternalDraw(ACanvas: TdxSkinCanvas;
  const ARect: TRect; AImageIndex: Integer = 0;
  AState: TdxSkinElementState = esNormal);
begin
  FillBackgroundByColor(ACanvas, ARect);
  Image.DrawEx(ACanvas, ARect, AImageIndex, AState);
  Borders.Draw(ACanvas, ARect);
  Glyph.DrawEx(ACanvas, cxRectContent(ARect, ContentOffset.Rect), AImageIndex, AState);
end;

procedure TdxSkinElement.ReadData(AStream: TStream; AVersion: TdxSkinVersion);
var
  ASide: TcxBorder;
begin
  AStream.Read(FColor, SizeOf(TColor));
  AStream.Read(FAlpha, SizeOf(FAlpha));
  AStream.Read(FImageCount, SizeOf(Integer));
  AStream.Read(ContentOffset.Data^, SizeOf(TRect));
  Glyph.ReadData(AStream);
  Image.ReadData(AStream);
  for ASide := Low(TcxBorder) to High(TcxBorder) do
  begin
    if Group.Skin.Version >= 0.92 then
      ReadStringFromStream(AStream);
    Borders[ASide].ReadFromStream(AStream);
  end;
  Color := FColor;
  if Group.Skin.Version >= 0.93 then
    AStream.Read(FTextColor, SizeOf(TColor));
  if Group.Skin.Version >= 0.94 then
    AStream.Read(FMinSize.Data^, SizeOf(TSize));
  if Group.Skin.Version >= 0.95 then
    ReadProperties(AStream);
end;

procedure TdxSkinElement.WriteData(AStream: TStream; AVersion: TdxSkinVersion);
var
  ASide: TcxBorder;
begin
  AStream.Write(FColor, SizeOf(TColor));
  AStream.Write(FAlpha, SizeOf(Alpha));
  AStream.Write(FImageCount, SizeOf(Integer));
  AStream.Write(ContentOffset.Data^, SizeOf(TRect));   
  Glyph.WriteData(AStream);
  Image.WriteData(AStream);
  for ASide := bLeft to bBottom do
    Borders[ASide].WriteToStream(AStream);
  AStream.Write(FTextColor, SizeOf(TColor));
  AStream.Write(FMinSize.Data^, SizeOf(TSize));
  WriteProperties(AStream);
end;

function TdxSkinElement.GetGroup: TdxSkinControlGroup;
begin
  Result := GetOwner as TdxSkinControlGroup;
end;

function TdxSkinElement.GetIsAlphaUsed: Boolean;
begin
  if Image.Empty then
    Result := Alpha < 255
  else
    Result := Image.Texture.IsAlphaUsed;
end;

function TdxSkinElement.GetPath: string;
begin
  Result := Group.Name + PathDelim;
end;

function TdxSkinElement.GetSize: TSize;
begin
  Result := Image.Size; 
end;

procedure TdxSkinElement.SetAlpha(AValue: Byte);
begin
  if Alpha <> AValue then
  begin
    FAlpha := AValue;
    Color := Color; 
  end;
end;

procedure TdxSkinElement.SetBorders(AValue: TdxSkinBorders);
begin
  FBorders.Assign(AValue);
end;

procedure TdxSkinElement.SetColor(AValue: TColor);
begin
  FColor := AValue;
  FIsColorAssigned := (Color <> clDefault) and (Color <> clNone);
  if IsColorAssigned then
  begin
    if FBrush <> nil then
      GdipSetSolidFillColor(FBrush, ColorToARGB(AValue, Alpha))
    else
      GdipCreateSolidFill(ColorToARGB(AValue, Alpha), FBrush);
  end;
  DoChange;
end;

procedure TdxSkinElement.SetContentOffset(AValue: TcxRect);
begin
  ContentOffset.Assign(AValue);
end;

procedure TdxSkinElement.SetGlyph(AValue: TdxSkinImage);
begin
  Glyph.Assign(AValue);
end;

procedure TdxSkinElement.SetImage(AValue: TdxSkinImage);
begin
  Image.Assign(AValue);
end;

procedure TdxSkinElement.SetImageCount(AValue: Integer);
begin
  if AValue < 1 then
    AValue := 1;
  if AValue <> FImageCount then
  begin
    FImageCount := AValue;
    Image.IsDirty := True;
    Glyph.IsDirty := True;
    DoChange;
  end;
end;

procedure TdxSkinElement.SetMinSize(AValue: TcxSize);
begin
  FMinSize.Assign(AValue);
end;

procedure TdxSkinElement.SetTextColor(AValue: TColor);
begin
  FTextColor := AValue;
  DoChange;
end;

{  TdxSkinEmptyElement }

procedure TdxSkinEmptyElement.Draw(DC: HDC; const ARect: TRect;
  AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);
var
  RedBrush: HBRUSH; 
begin
  FillRect(DC, ARect, GetStockObject(WHITE_BRUSH));
  RedBrush := CreateSolidBrush(255);
  FrameRect(DC, ARect, RedBrush);
  DeleteObject(RedBrush);
end;

{  TdxSkinPartStream }

constructor TdxSkinPartStream.Create(ASource: TStream);
begin
  FSource := ASource;
end;

{$IFDEF DELPHI7}

function TdxSkinPartStream.GetSize: Int64;
begin
  Result := FPosEnd - FPosStart;
end;

{$ENDIF}

procedure TdxSkinPartStream.Initialize(const APosStart, APosEnd: Longint);
begin
  FPosStart := APosStart;
  FPosEnd := APosEnd;
end;

procedure TdxSkinPartStream.InitializeEx(
  ASource: TStream; const APosStart, APosEnd: Longint);
begin
  FSource := ASource;
  Initialize(APosStart, APosEnd);
end;

function TdxSkinPartStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := Source.Read(Buffer, Count);
end;

function TdxSkinPartStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  ANewPos: Longint;
begin
  ANewPos := Source.Position + Offset;
  case Origin of
    soFromBeginning:
      ANewPos := PosStart + Offset;
    soFromEnd:
      ANewPos := PosEnd + Offset;
  end;
  Source.Position := Min(Max(PosStart, ANewPos), PosEnd);
  Result := Source.Position - PosStart;
end;

function TdxSkinPartStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := Source.Write(Buffer, Count);
  FPosEnd := Source.Position;
end;

{ TdxSkinCanvas }

function TdxSkinCanvas.GetInterpolationMode: Integer;
begin
  GdipCheck(GdipGetInterpolationMode(Graphics, Result));
end;

procedure TdxSkinCanvas.SetInterpolationMode(AValue: Integer);
begin
{$IFDEF CXTEST}
  GdipCheck(GdipSetInterpolationMode(Graphics, InterpolationModeDefault));
{$ELSE}
  GdipCheck(GdipSetInterpolationMode(Graphics, AValue));
{$ENDIF}
end;

function TdxSkinCanvas.IsRectVisible(DC: HDC; const R: TRect): Boolean;
begin
  Result := not cxRectIsEmpty(R) and RectVisible(DC, R);
end;

procedure TdxSkinCanvas.BeginPaint(DC: HDC; const R: TRect);
var
  ATempDC: HDC;
begin
  FRect := R;
  ATempDC := DC;
  FSourceDC := DC;
  if GetDeviceCaps(DC, BITSPIXEL) <= 16 then
  begin
    FBuffer := TcxBitmap.Create;
    FBuffer.PixelFormat := pf32bit;
    FBuffer.SetSize(R.Right - R.Left, R.Bottom - R.Top);
    ATempDC := FBuffer.Canvas.Handle;
    cxBitBlt(ATempDC, DC, FBuffer.ClientRect, R.TopLeft, SRCCOPY);
    SetWindowOrgEx(ATempDC, R.Left, R.Top, nil);
  end;
  GdipCheck(GdipCreateFromHDC(ATempDC, FGraphics));
end;

procedure TdxSkinCanvas.BeginPaintEx(Graphics: GpGraphics; const R: TRect);
begin
  FRect := R;
  FSourceDC := 0;
  FGraphics := Graphics;
end;

procedure TdxSkinCanvas.EndPaint;
var
  ACanvas: TCanvas;
  ASaveIndex: Integer;
begin
  GdipCheck(GdipDeleteGraphics(FGraphics));
  if FBuffer <> nil then
  begin
    SetWindowOrgEx(FBuffer.Canvas.Handle, 0, 0, nil);
    // todo: using TCanvas for valid bitmap drawing to 256 colors DC
    ACanvas := TCanvas.Create;
    try
      ASaveIndex := SaveDC(FSourceDC);
      ACanvas.Handle := FSourceDC;
      ACanvas.Draw(FRect.Left, FRect.Top, FBuffer);
      ACanvas.Handle := 0;
      RestoreDC(FSourceDC, ASaveIndex);
    finally
      ACanvas.Free;
    end;
    FreeAndNil(FBuffer);
  end;
end;

procedure TdxSkinCanvas.FillRectByColor(const R: TRect; AColor: TColor);
var
  ABrush: HBRUSH;
  DC: HDC;
begin
  ABrush := CreateSolidBrush(ColorToRGB(AColor));
  GdipCheck(GdipGetDC(Graphics, DC));
  FillRect(DC, R, ABrush);
  GdipCheck(GdipReleaseDC(Graphics, DC));
  DeleteObject(ABrush);
end;

procedure TdxSkinCanvas.FillRectByGradient(const R: TRect; AColor1: TColor;
  AColor2: TColor; AMode: TdxSkinGradientMode);
var
  DC: HDC;
begin
  if (AColor1 = AColor2) or (AColor2 = clNone) or (AColor2 = clDefault) then
    FillRectByColor(R, AColor1)
  else
    if AMode in [gmVertical, gmHorizontal] then
    begin
      GdipCheck(GdipGetDC(Graphics, DC));
      FillGradientRect(DC, R, AColor1, AColor2, AMode = gmHorizontal);
      GdipCheck(GdipReleaseDC(Graphics, DC));
    end
    else
      FillRectByDiagonalGradient(R, AColor1, AColor2, AMode = gmForwardDiagonal);
end;

procedure TdxSkinCanvas.DrawImage(AImage: TdxPNGImage; const ADest, ASource: TRect);
var
  AOldIntpMode: Integer;
begin
  AOldIntpMode := InterpolationMode;
  try
    InterpolationMode := InterpolationModeNearestNeighbor;
    StretchDrawImage(AImage, ADest, ASource);
  finally
    InterpolationMode := AOldIntpMode;
  end;
end;

procedure TdxSkinCanvas.FillRectByDiagonalGradient(const R: TRect;
  AColor1, AColor2: TColor; AForward: Boolean);
const
  GradientModeFlags: array[Boolean] of LinearGradientMode = (
    LinearGradientModeBackwardDiagonal, LinearGradientModeForwardDiagonal 
  );
var
  ABrush: GpLineGradient;
  R1: TdxGPRect;
begin
  R1.X := R.Left;
  R1.Y := R.Top;
  R1.Width := R.Right - R.Left;
  R1.Height := R.Bottom - R.Top;
  GdipCheck(GdipCreateLineBrushFromRectI(@R1, ColorToARGB(AColor1),
    ColorToARGB(AColor2), GradientModeFlags[AForward], WrapModeTile, ABrush));
  GdipCheck(GdipFillRectangleI(Graphics, ABrush, R1.X, R1.Y, R1.Width, R1.Height));
  GdipCheck(GdipDeleteBrush(ABrush));
end;

procedure TdxSkinCanvas.StretchDrawImage(AImage: TdxPNGImage;
  const ADest, ASource: TRect);
begin
  AImage.StretchDrawEx(Graphics, ADest, ASource);
end;

procedure TdxSkinCanvas.TileImage(AImage: TdxPNGImage; const ADest, ASource: TRect);
var
  ALastCol, ALastRow, ACol, ARow: Integer;
  AOldIntpMode: Integer;
  ASize, ADestSize: TSize;
  RDest, RSrc: TRect;
begin
  AOldIntpMode := InterpolationMode;
  try
    InterpolationMode := InterpolationModeNearestNeighbor;
    ASize := cxSize(cxRectWidth(ASource), cxRectHeight(ASource));
    ADestSize := cxSize(cxRectWidth(ADest), cxRectHeight(ADest));
    ALastCol := ADestSize.cx div ASize.cx - Ord(ADestSize.cx mod ASize.cx = 0);
    ALastRow := ADestSize.cy div ASize.cy - Ord(ADestSize.cy mod ASize.cy = 0);
    for ARow := 0 to ALastRow do
    begin
      RSrc.Top := ASource.Top;
      RSrc.Bottom := ASource.Bottom;
      RDest.Top := ADest.Top + ASize.cy * ARow;
      RDest.Bottom := RDest.Top + ASize.cy;
      if RDest.Bottom > ADest.Bottom then
      begin
        Dec(RSrc.Bottom, RDest.Bottom - ADest.Bottom);
        RDest.Bottom := ADest.Bottom;
      end;
      for ACol := 0 to ALastCol do
      begin
        RSrc.Left := ASource.Left;
        RSrc.Right := ASource.Right;
        RDest.Left := ADest.Left + ASize.cx * ACol;
        RDest.Right := RDest.Left + ASize.cx;
        if RDest.Right > ADest.Right then
        begin
          Dec(RSrc.Right, RDest.Right - ADest.Right);
          RDest.Right := ADest.Right;
        end;
        AImage.DrawEx(Graphics, RDest, RSrc);
      end;
    end;
  finally
    InterpolationMode := AOldIntpMode;
  end;
end;

{ TdxSkinElementCache }

destructor TdxSkinElementCache.Destroy;
begin
  FreeCache;
  inherited Destroy;
end;

procedure TdxSkinElementCache.FreeCache;
begin
  if Assigned(FCache) then
  begin
    GdipCheck(GdipDisposeImage(FCache));
    FCache := nil;
  end;
  FreeAndNil(FCacheOpaque);
end;

procedure TdxSkinElementCache.CheckCacheState(AElement: TdxSkinElement;
  const R: TRect; AState: TdxSkinElementState = esNormal;
  AImageIndex: Integer = 0);
begin
  if (AElement <> Element) or (AState <> FState) or
    (FImageIndex <> AImageIndex) or (cxRectWidth(R) <> cxRectWidth(FRect)) or
    (cxRectHeight(R) <> cxRectHeight(FRect))
  then
  begin
    FElement := AElement;
    FImageIndex := AImageIndex;
    FRect := R;
    FState := AState;
    FIsAlphaBlendUsed := AElement.IsAlphaUsed;
    FreeCache;
    if not IsRectEmpty(R) then
    begin
      if IsAlphaBlendUsed then
        InitCache(R)
      else
        InitOpaqueCache(R);
    end;
  end;
end;

procedure TdxSkinElementCache.InitCache(R: TRect);
var
  ACanvas: TdxSkinCanvas;
  AGraphics: GpGraphics;
begin
  ACanvas := TdxSkinCanvas.Create;
  try
    OffsetRect(R, -R.Left, -R.Top);
    GdipCheck(GdipCreateBitmapFromScan0(R.Right, R.Bottom, 0,
      PixelFormat32bppPARGB, nil, FCache));
    GdipCheck(GdipGetImageGraphicsContext(FCache, AGraphics));
    ACanvas.BeginPaintEx(AGraphics, R);
    try
      Element.InternalDraw(ACanvas, R, ImageIndex, State);
    finally
      ACanvas.EndPaint;
    end;
  finally
    ACanvas.Free;                                     
  end;
end;

procedure TdxSkinElementCache.InitOpaqueCache(R: TRect);
var
  ACanvas: TdxSkinCanvas;
begin
  ACanvas := TdxSkinCanvas.Create;
  try
    OffsetRect(R, -R.Left, -R.Top);
    FCacheOpaque := TcxBitmap.CreateSize(R, pf32bit);
    ACanvas.BeginPaint(FCacheOpaque.Canvas.Handle, R);
    try
      Element.InternalDraw(ACanvas, R, ImageIndex, State);
    finally
      ACanvas.EndPaint;
    end;
  finally
    ACanvas.Free;
  end;
end;

procedure TdxSkinElementCache.Draw(DC: HDC; const R: TRect);
var
  AGraphics: GpGraphics;
begin
  if FCacheOpaque <> nil then
    cxBitBlt(DC, FCacheOpaque.Canvas.Handle, R, cxNullPoint, SRCCOPY)
  else
    if FCache <> nil then
    begin
      GdipCheck(GdipCreateFromHDC(DC, AGraphics));
      GdipCheck(GdipDrawImageRectI(AGraphics, FCache, R.Left, R.Top,
        R.Right - R.Left, R.Bottom - R.Top));
      GdipCheck(GdipDeleteGraphics(AGraphics));
    end;
end;

procedure TdxSkinElementCache.DrawEx(DC: HDC; AElement: TdxSkinElement;
  const R: TRect; AState: TdxSkinElementState = esNormal; AImageIndex: Integer = 0);
begin
  CheckCacheState(AElement, R, AState, AImageIndex);
  Draw(DC, R);
end;

{ TdxSkinElementCacheList }

constructor TdxSkinElementCacheList.Create;
begin
  inherited Create;
  CacheListLimit := dxSkinElementCacheListLimit;
end;

procedure TdxSkinElementCacheList.DrawElement(DC: HDC; AElement: TdxSkinElement;
  const R: TRect; AState: TdxSkinElementState = esNormal; AImageIndex: Integer = 0);
var
  AElementCache: TdxSkinElementCache;
begin
  if not FindElementCache(AElement, R, AElementCache) then
  begin
    AElementCache := TdxSkinElementCache.Create;
    Add(AElementCache);
    CheckListLimits;
  end;
  AElementCache.DrawEx(DC, AElement, R, AState, AImageIndex);
end;

procedure TdxSkinElementCacheList.CheckListLimits;
begin
  if Count > CacheListLimit then
  begin
    ElementCache[0].Free;
    Delete(0);
  end;
end;

function TdxSkinElementCacheList.FindElementCache(AElement: TdxSkinElement;
  const R: TRect; out AElementCache: TdxSkinElementCache): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    AElementCache := ElementCache[I];
    Result := (AElementCache.Element = AElement) and cxRectIsEqual(R, AElementCache.FRect);
    if Result then
      Break;
  end;
end;

function TdxSkinElementCacheList.GetElementCache(AIndex: Integer): TdxSkinElementCache;
begin
  Result := TdxSkinElementCache(Items[AIndex]);
end;

procedure RegisterAssistants;
begin
  dxSkinEmptyElement := TdxSkinEmptyElement.Create(nil, '');
  RegisteredPropertyTypes := TList.Create;
  PartStream := TdxSkinPartStream.Create(nil);
  RegisterClasses([TdxSkinControlGroup, TdxSkinElement, TdxSkinImage]);
  // register properties
  TdxSkinIntegerProperty.Register;
  TdxSkinColor.Register;
  TdxSkinRectProperty.Register;
  TdxSkinSizeProperty.Register;
  TdxSkinBooleanProperty.Register;
  TdxSkinStringProperty.Register;
  //
  CheckGdiPlus;
  CheckPngCodec;
end;

procedure UnregisterAssistants;
begin
  RegisteredPropertyTypes.Free;
  UnRegisterClasses([TdxSkinControlGroup, TdxSkinElement, TdxSkinImage]);
  UnRegisterClasses([TdxSkinIntegerProperty, TdxSkinColor, TdxSkinRectProperty,
    TdxSkinSizeProperty, TdxSkinBooleanProperty]);
  PartStream.Free;
  FreeAndNil(dxSkinEmptyElement);
end;

initialization
  dxUnitsLoader.AddUnit(@RegisterAssistants, @UnregisterAssistants);
finalization
  dxUnitsLoader.RemoveUnit(@UnregisterAssistants);

end.
