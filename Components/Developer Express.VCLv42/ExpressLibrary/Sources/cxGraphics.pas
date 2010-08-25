{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library graphics classes          }
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

unit cxGraphics;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Windows, Classes, SysUtils, Controls, Graphics, CommCtrl, ComCtrls, ImgList,
  dxCore, cxClasses;

const
  cxAlignLeft = 1;
  cxAlignRight = 2;
  cxAlignHCenter = 4;
  cxAlignTop = 8;
  cxAlignBottom = 16;
  cxAlignVCenter = 32;
  cxAlignCenter = 36;
  cxSingleLine = 64;
  cxDontClip = 128;
  cxExpandTabs = 256;
  cxShowPrefix = 512;
  cxWordBreak = 1024;
  cxShowEndEllipsis = 2048;
  cxDontPrint = 4096;
  cxShowPathEllipsis = 8192;
  cxDontBreakChars = 16384;

  SystemAlignmentsHorz: array[TAlignment] of Integer = (DT_LEFT, DT_RIGHT, DT_CENTER);
  SystemAlignmentsVert: array[TcxAlignmentVert] of Integer = (DT_TOP, DT_BOTTOM, DT_VCENTER);
  cxAlignmentsHorz: array[TAlignment] of Integer = (cxAlignLeft, cxAlignRight, cxAlignHCenter);
  cxAlignmentsVert: array[TcxAlignmentVert] of Integer = (cxAlignTop, cxAlignBottom, cxAlignVCenter);

{$IFNDEF DELPHI6}
  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);
  clCream = TColor($F0FBFF);
  clMedGray = TColor($A4A0A0);
{$ENDIF}
  clcxLightGray = $CFCFCF;

  cxEmptyRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

  cxDesignSelectionWidth = 2;

  cxDefaultAlphaValue = 200;

  cxHalfToneBrush: TBrush = nil;

  cxDoubleBufferedBitmapPixelFormat: TPixelFormat = pfDevice;

type
  IcxFontListener = interface
    ['{B144DD7E-0B27-439A-B908-FC3ACFE6A2D3}']
    procedure Changed(Sender: TObject; AFont: TFont);
  end;

  TcxBorder = (bLeft, bTop, bRight, bBottom);
  TcxBorders = set of TcxBorder;

const
  cxBordersAll = [bLeft, bTop, bRight, bBottom];

type
  TBrushHandle = HBRUSH;

  TPointArray = array of TPoint;
  TRectArray = array of TRect;

  TcxColorPart = -100..100;

  TcxGridLines = (glBoth, glNone, glVertical, glHorizontal);

  PcxViewParams = ^TcxViewParams;
  TcxViewParams = record
    Bitmap: TBitmap;
    Color: TColor;
    Font: TFont;
    TextColor: TColor;
  end;

  { TcxRegion }

  TcxRegionHandle = HRGN;
  TcxRegionOperation = (roSet, roAdd, roSubtract, roIntersect);

  TcxRegion = class  {6}
  private
    FHandle: TcxRegionHandle;
    function GetBoundsRect: TRect;
    function GetIsEmpty: Boolean;
  protected
    procedure DestroyHandle;
  public
    constructor Create(AHandle: TcxRegionHandle); overload;
    constructor Create(const ABounds: TRect); overload;
    constructor Create; overload;
    constructor Create(ALeft, ATop, ARight, ABottom: Integer); overload;
    constructor CreateRoundCorners(const ABounds: TRect; AWidthEllepse, AHeightEllepse: Integer); overload;
    constructor CreateRoundCorners(ALeft, ATop, ARight, ABottom, AWidthEllepse, AHeightEllepse: Integer); overload;
    destructor Destroy; override;

    procedure Combine(ARegion: TcxRegion; AOperation: TcxRegionOperation;
      ADestroyRegion: Boolean = True);
    function IsEqual(ARegion: TcxRegion): Boolean; overload;
    function IsEqual(ARegionHandle: TcxRegionHandle): Boolean; overload;
    procedure Offset(DX, DY: Integer);
    function PtInRegion(const Pt: TPoint): Boolean; overload;
    function PtInRegion(X, Y: Integer): Boolean; overload;
    function RectInRegion(const R: TRect): Boolean; overload;
    function RectInRegion(ALeft, ATop, ARight, ABottom: Integer): Boolean; overload;

    property BoundsRect: TRect read GetBoundsRect;
    property Handle: TcxRegionHandle read FHandle write FHandle;
    property IsEmpty: Boolean read GetIsEmpty;
  end;

  { TcxCanvas }     

  TcxRotationAngle = (ra0, raPlus90, raMinus90, ra180);
  TcxCanvasState = record
    Font: TFont;
    Brush: TBrush;
    Pen: TPen;
  end;
  TcxCanvasStates = array of TcxCanvasState;

  TcxCanvas = class
  private
    FCanvas: TCanvas;
    FSavedDCs: TList;
    FSavedRegions: TList;
    FSavedStates: TcxCanvasStates;

    function GetBrush: TBrush;
    function GetCopyMode: TCopyMode;
    function GetDCOrigin: TPoint;
    function GetFont: TFont;
    function GetHandle: HDC;
    function GetPen: TPen;
    function GetViewportOrg: TPoint;
    function GetWindowOrg: TPoint;
    procedure SetBrush(Value: TBrush);
    procedure SetCopyMode(Value: TCopyMode);
    procedure SetFont(Value: TFont);
    procedure SetPen(Value: TPen);
    procedure SetPixel(X, Y: Integer; Value: TColor);
    procedure SetViewportOrg(const P: TPoint);
    procedure SetWindowOrg(const P: TPoint);
  protected
    procedure SynchronizeObjects(ADC: THandle);
  public
    constructor Create(ACanvas: TCanvas); virtual;
    destructor Destroy; override;

    procedure AlignMultiLineTextRectVertically(var R: TRect; const AText: string;
      AAlignmentVert: TcxAlignmentVert; AWordBreak, AShowPrefix: Boolean;
      AEnabled: Boolean = True; ADontBreakChars: Boolean = False);
    procedure CopyRect(const Dest: TRect; ACanvas: TCanvas; const Source: TRect);
    procedure Draw(X, Y: Integer; Graphic: TGraphic);
    procedure DrawComplexFrame(const R: TRect; ALeftTopColor, ARightBottomColor: TColor;
      ABorders: TcxBorders = [bLeft, bTop, bRight, bBottom]; ABorderWidth: Integer = 1);
    procedure DrawEdge(const R: TRect; ASunken, AOuter: Boolean;
      ABorders: TcxBorders = [bLeft, bTop, bRight, bBottom]);
    procedure DrawFocusRect(const R: TRect);
    procedure DrawGlyph(X, Y: Integer; AGlyph: TBitmap; AEnabled: Boolean = True;
      ABackgroundColor: TColor = clNone{; ATempCanvas: TCanvas = nil});
    procedure DrawImage(Images: TCustomImageList; X, Y, Index: Integer;
      Enabled: Boolean = True);
    procedure DrawTexT(const Text: string; R: TRect; Flags: Integer;
      Enabled: Boolean = True);
    procedure FillRect(const R: TRect; AColor: TColor); overload;
    procedure FillRect(const R: TRect; ABitmap: TBitmap = nil;
      AExcludeRect: Boolean = False); overload;
    procedure FillRect(R: TRect; const AParams: TcxViewParams;
      ABorders: TcxBorders = []; ABorderColor: TColor = clDefault;
      ALineWidth: Integer = 1; AExcludeRect: Boolean = False); overload;
    procedure DrawDesignSelection(ARect: TRect; AWidth: Integer = cxDesignSelectionWidth);
    procedure DrawRegion(ARegion: TcxRegion; AContentColor: TColor = clDefault;
      ABorderColor: TColor = clDefault; ABorderWidth: Integer = 1; ABorderHeight: Integer = 1); overload;
    procedure DrawRegion(ARegion: TcxRegionHandle; AContentColor: TColor = clDefault;
      ABorderColor: TColor = clDefault; ABorderWidth: Integer = 1; ABorderHeight: Integer = 1); overload;
    procedure FillRegion(ARegion: TcxRegion; AColor: TColor = clDefault); overload;
    procedure FillRegion(ARegion: TcxRegionHandle; AColor: TColor = clDefault); overload;
    procedure FlipHorizontally(ABitmap: TBitmap);
    procedure FrameRegion(ARegion: TcxRegion; AColor: TColor = clDefault;
      ABorderWidth: Integer = 1; ABorderHeight: Integer = 1); overload;
    procedure FrameRegion(ARegion: TcxRegionHandle; AColor: TColor = clDefault;
      ABorderWidth: Integer = 1; ABorderHeight: Integer = 1); overload;
    procedure Pie(const R: TRect; const ARadial1, ARadial2: TPoint); overload;
    procedure Pie(const R: TRect; AStartAngle, ASweepAngle: Integer); overload;
    function FontHeight(AFont: TFont): Integer;
    procedure FrameRect(const R: TRect; Color: TColor = clDefault;
      ALineWidth: Integer = 1; ABorders: TcxBorders = cxBordersAll;
      AExcludeFrame: Boolean = False);
    procedure InvertFrame(const R: TRect; ABorderSize: Integer);
    procedure InvertRect(const R: TRect);
    procedure LineTo(X, Y: Integer);
    procedure MoveTo(X, Y: Integer);
    procedure Polygon(const Points: array of TPoint);
    procedure Polyline(const Points: array of TPoint);
    procedure RotateBitmap(ABitmap: TBitmap; ARotationAngle: TcxRotationAngle;
      AFlipVertically: Boolean = False);
    function TextExtent(const Text: string): TSize; overload;
    procedure TextExtent(const Text: string; var R: TRect; Flags: Integer); overload;
    function TextHeight(const Text: string): Integer;
    function TextWidth(const Text: string): Integer;
    procedure TransparentDraw(X, Y: Integer; ABitmap: TBitmap; AAlpha: Byte;
      ABackground: TBitmap = nil);

    procedure RestoreDC;
    procedure SaveDC;
    procedure RestoreClipRegion;
    procedure SaveClipRegion;
    procedure RestoreState;
    procedure SaveState;

    procedure GetParams(var AParams: TcxViewParams);
    procedure SetParams(AParams: TcxViewParams);
    procedure SetBrushColor(Value: TColor);
    procedure SetFontAngle(Value: Integer);

    procedure GetTextStringsBounds(Text: string; R: TRect; Flags: Integer;
      Enabled: Boolean; var ABounds: TRectArray);

    procedure BeginPath;
    procedure EndPath;
    function PathToRegion: TcxRegion;
    procedure WidenPath;

    // clipping
    procedure ExcludeClipRect(const R: TRect);
    procedure IntersectClipRect(const R: TRect);
    function GetClipRegion(AConsiderOrigin: Boolean = True): TcxRegion;
    procedure SetClipRegion(ARegion: TcxRegion; AOperation: TcxRegionOperation;
      ADestroyRegion: Boolean = True; AConsiderOrigin: Boolean = True);
    function RectFullyVisible(const R: TRect): Boolean;
    function RectVisible(const R: TRect): Boolean;

    property Brush: TBrush read GetBrush write SetBrush;
    property Canvas: TCanvas read FCanvas write FCanvas;
    property CopyMode: TCopyMode read GetCopyMode write SetCopyMode;
    property DCOrigin: TPoint read GetDCOrigin;
    property Font: TFont read GetFont write SetFont;
    property Handle: HDC read GetHandle;
    property Pen: TPen read GetPen write SetPen;
    property Pixels[X, Y: Integer]: TColor write SetPixel;
    property ViewportOrg: TPoint read GetViewportOrg write SetViewportOrg;
    property WindowOrg: TPoint read GetWindowOrg write SetWindowOrg;
  end;

  { TcxScreenCanvas }

  TcxScreenCanvas = class(TcxCanvas)
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
  end;

  { TcxCustomBitmap }
  
  TcxCustomBitmap = class(TBitmap)
  private
    FCompressData: Boolean;
    FcxCanvas: TcxCanvas;
    FLockCount: Integer;
    FModified: Boolean;

    function GetClientRect: TRect;

    procedure Compress(ASourceStream, ADestStream: TStream; ASize: Integer);
    procedure Decompress(ASourceStream, ADestStream: TStream; ASize: Integer);
  protected
    procedure Changed(Sender: TObject); override;
    function ChangeLocked: Boolean;
    procedure Initialize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat); virtual;
    procedure Update; virtual;

    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    constructor Create; override;
    constructor CreateSize(const ARect: TRect); overload;
    constructor CreateSize(AWidth, AHeight: Integer); overload;
    constructor CreateSize(const ARect: TRect; APixelFormat: TPixelFormat); overload;
    constructor CreateSize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat); overload; virtual;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate(AForceUpdate: Boolean = True);

    procedure CopyBitmap(ABitmap: TBitmap; ACopyMode: DWORD = SRCCOPY); overload;
    procedure CopyBitmap(ABitmap: TBitmap; const ADestRect: TRect; const ASrcTopLeft: TPoint; ACopyMode: DWORD = SRCCOPY); overload;
    procedure Clear; virtual;
    procedure Rotate(ARotationAngle: TcxRotationAngle; AFlipVertically: Boolean = False);
    procedure SetSize(AWidth, AHeight: Integer); {$IFDEF DELPHI10}override;{$ELSE}virtual;{$ENDIF}

    property CompressData: Boolean read FCompressData write FCompressData;
    property ClientRect: TRect read GetClientRect;
    property cxCanvas: TcxCanvas read FcxCanvas;
  end;

  { TcxBitmap }

  TRGBColors = array of TRGBQuad;
  TcxImageDrawMode = (idmNormal, idmDisabled, idmFaded, idmGrayScale, idmDingy, idmShadowed);
  TcxBitmapTransformationMode = (btmDingy, btmDirty, btmGrayScale, btmSetOpaque, btmMakeMask, btmFade, btmDisable, btmCorrectBlend, btmHatch, btmClear, btmResetAlpha);
  TcxBitmapTransformationProc = procedure(var AColor: TRGBQuad) of object;
  TcxDrawImageProc = function (ACanvas: TCanvas; AImages: TCustomImageList; AImageIndex: Integer; AGlyph: TBitmap; ARect: TRect; ADrawMode: TcxImageDrawMode): Boolean;

  TcxColorTransitionMap = record
    RedScale: Single;
    GreenScale: Single;
    BlueScale: Single;
    SrcAlpha: Byte;
    SrcConstantAlpha: Byte;
  end;

  TcxHatchData = record
    Color1: TRGBQuad;
    Alpha1: Byte;
    Color2: TRGBQuad;
    Alpha2: Byte;
    Step: Byte;
  end;

  TcxColorList = class(TList)
  public
    function Add(AColor: TColor): Integer;
  end;

  TcxBitmap = class(TcxCustomBitmap)
  private
    FBitmapInfo: TBitmapInfo;
    FTransparentBkColor: TRGBQuad;
    FTransparentPixels: TcxColorList;

    FCurrentColorIndex: TPoint;
    FHatchData: TcxHatchData;

    function GetIsAlphaUsed: Boolean;

    procedure CorrectBlend(var AColor: TRGBQuad);
    procedure ClearColor(var AColor: TRGBQuad);
    procedure Dingy(var AColor: TRGBQuad);
    procedure Dirty(var AColor: TRGBQuad);
    procedure Disable(var AColor: TRGBQuad);
    procedure Fade(var AColor: TRGBQuad);
    procedure GrayScale(var AColor: TRGBQuad);
    procedure Hatch(var AColor: TRGBQuad);
    procedure MakeMask(var AColor: TRGBQuad);
    procedure SetOpaque(var AColor: TRGBQuad);
    procedure ResetAlpha(var AColor: TRGBQuad);

    procedure Scale(var AColor: TRGBQuad; const AColorMap: TcxColorTransitionMap);

    procedure UpdateBitmapInfo;

    function IsColorTransparent(const AColor: TRGBQuad): Boolean;
  protected
    procedure Initialize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat); override;
    procedure Update; override;

    property HatchData: TcxHatchData read FHatchData write FHatchData;
    property TransparentBkColor: TRGBQuad read FTransparentBkColor write FTransparentBkColor;
    property TransparentPixels: TcxColorList read FTransparentPixels;
  public
    constructor CreateSize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat); override;
    constructor CreateSize(AWidth, AHeight: Integer; ATransparentBkColor: TRGBQuad); overload;
    destructor Destroy; override;

    procedure GetBitmapColors(out AColors: TRGBColors);
    procedure SetBitmapColors(const AColors: TRGBColors);

    procedure AlphaBlend(ABitmap: TcxBitmap; const ARect: TRect; ASmoothImage: Boolean; AConstantAlpha: Byte = $FF);
    procedure Clear; override;
    procedure DrawHatch(const AHatchData: TcxHatchData); overload;
    procedure DrawHatch(AColor1, AColor2: TColor; AStep: Byte; AAlpha1: Byte = $FF; AAlpha2: Byte = $FF); overload;
    procedure DrawShadow(AMaskBitmap: TcxBitmap; AShadowSize: Integer; AShadowColor: TColor; AInflateSize: Boolean = False);
    procedure Filter(AMaskBitmap: TcxBitmap);
    procedure Invert;
    procedure MakeOpaque;
    procedure RecoverAlphaChannel(ATransparentColor: TColor);
    procedure SetSize(AWidth, AHeight: Integer); override;
    procedure Shade(AMaskBitmap: TcxBitmap);

    procedure TransformBitmap(AMode: TcxBitmapTransformationMode);

    property IsAlphaUsed: Boolean read GetIsAlphaUsed;
  end;

  TcxImageInfo = class(TPersistent)
  private
    FImage: TBitmap;
    FMask: TBitmap;
    FMaskColor: TColor;

    procedure AssignBitmap(ASourceBitmap, ADestBitmap: TBitmap);
  protected
    procedure SetImage(Value: TBitmap); virtual;
    procedure SetMask(Value: TBitmap); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property Image: TBitmap read FImage write SetImage;
    property Mask: TBitmap read FMask write SetMask;
    property MaskColor: TColor read FMaskColor write FMaskColor;
  end;

  TcxImageList = class(TDragImageList)
  private
    FAlphaBlending: Boolean;
    FFormatVersion: Integer;
    FImages: TCollection;
    FLockCount: Integer;
    FSynchronization: Boolean;

    function GetCompressData: Boolean;
    procedure SetCompressData(Value: Boolean);

    function GetHandle: HImageList;
    procedure SetHandle(Value: HImageList);

    procedure ReadFormatVersion(AReader: TReader);
    procedure WriteFormatVersion(AWriter: TWriter);
    procedure ReadImageInfo(AReader: TReader);
    procedure WriteImageInfo(AWriter: TWriter);
    procedure ReadDesignInfo(AReader: TReader);
    procedure WriteDesignInfo(AWriter: TWriter);
    function NeedSynchronizeImageInfo: Boolean;
    procedure SynchronizeImageInfo;
    procedure SynchronizeHanle;

    procedure AddToInternalCollection(AImage, AMask: TBitmap; AMaskColor: TColor = clNone);
    procedure DormantImage(AIndex: Integer);
    function GetImageHandle(AImage: TBitmap): Integer;
  protected
    function ChangeLocked: Boolean;
    procedure Change; override;
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
      Style: Cardinal; Enabled: Boolean = True); override;
    procedure DoDrawEx(AIndex: Integer; ACanvas: TCanvas;
      const ARect: TRect; AStyle: Cardinal; AStretch, ASmoothResize, AEnabled: Boolean);

    procedure Initialize; override;
    procedure Finalize;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Dormant;

    // for cxImageListEditor
    procedure AddImageInfo(AImageInfo: TcxImageInfo);
    procedure InternalCopyImageInfos(AImageList: TcxImageList; AStartIndex, AEndIndex: Integer);
    procedure InternalCopyImages(AImageList: TCustomImageList; AStartIndex, AEndIndex: Integer);
    procedure GetImageInfo(AIndex: Integer; AImageInfo: TcxImageInfo); overload;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    // BaseFunctions
    function Add(AImage, AMask: TBitmap): Integer;
    function AddIcon(AIcon: TIcon): Integer;
    function AddMasked(AImage: TBitmap; AMaskColor: TColor): Integer;
    procedure Move(ACurIndex, ANewIndex: Integer);
    procedure Delete(AIndex: Integer);

    // SubsidiaryFunctions
    function AddImage(AValue: TCustomImageList; AIndex: Integer): Integer;
    procedure AddImages(AImageList: TCustomImageList);
    procedure CopyImages(AImageList: TCustomImageList; AStartIndex: Integer = 0; AEndIndex: Integer = -1);
    procedure Clear;
    procedure Insert(AIndex: Integer; AImage, AMask: TBitmap);
    procedure InsertIcon(AIndex: Integer; AIcon: TIcon);
    procedure InsertMasked(AIndex: Integer; AImage: TBitmap; AMaskColor: TColor);
    procedure Replace(AIndex: Integer; AImage, AMask: TBitmap);
    procedure ReplaceIcon(AIndex: Integer; AIcon: TIcon);
    procedure ReplaceMasked(AIndex: Integer; AImage: TBitmap; AMaskColor: TColor);

    function LoadImage(AInstance: THandle; const AResourceName: string;
      AMaskColor: TColor = clDefault; AWidth: Integer = 0; AFlags: TLoadResources = []): Boolean;
    function GetResource(AResType: TResType; const AName: string;
      AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean;
    function GetInstRes(AInstance: THandle; AResType: TResType; const AName: string;
      AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean; overload;
    function GetInstRes(AInstance: THandle; AResType: TResType; AResID: DWORD;
      AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean; overload;
    function ResourceLoad(AResType: TResType; const AName: string;
      AMaskColor: TColor): Boolean;
    function ResInstLoad(AInstance: THandle; AResType: TResType;
      const AName: string; AMaskColor: TColor): Boolean;

    procedure BeginUpdate;
    procedure EndUpdate(AForceUpdate: Boolean = True);

  {$IFNDEF DELPHI6}
    procedure Draw(ACanvas: TCanvas; X, Y, AIndex: Integer;
      ADrawingStyle: TDrawingStyle; AImageType: TImageType;
      AEnabled: Boolean = True); overload;
  {$ENDIF}
    procedure Draw(ACanvas: TCanvas; const ARect: TRect; AIndex: Integer;
      AStretch: Boolean = True; ASmoothResize: Boolean = False; AEnabled: Boolean = True); overload;

    procedure GetImageInfo(AIndex: Integer; AImage, AMask: TBitmap); overload;
    procedure GetImage(AIndex: Integer; AImage: TBitmap);
    procedure GetMask(AIndex: Integer; AMask: TBitmap);

    class procedure GetImageInfo(AHandle: HIMAGELIST; AIndex: Integer; AImage, AMask: TBitmap); overload;
    class function GetPixelFormat(AHandle: HIMAGELIST): Integer;
    
    property AlphaBlending: Boolean read FAlphaBlending write FAlphaBlending;
    property Handle: HImageList read GetHandle write SetHandle;
  published
    property BlendColor;
    property BkColor;
    property CompressData: Boolean read GetCompressData write SetCompressData default False;
    property DrawingStyle;
    property Height;
    property ImageType;
    property ShareImages;
    property Width;
    property OnChange;
  end;

  { TcxBrushCache }

  TcxBrushData = record
    Brush: TBrush;
    Color: TColor;
    RefCount: Integer;
  end;

  TcxBrushesData = array of TcxBrushData;

  EBrushCache = class(EdxException);

  TcxBrushCache = class
  private
    FCapacity: Integer;
    FCount: Integer;
    FData: TcxBrushesData;
    FDeletedCount: Integer;
    FLockRef: Integer;
  protected
    function Add(AColor: TColor): TBrush;
    function AddItemAt(AIndex: Integer; AColor: TColor): TBrush;
    procedure CacheCheck(Value: Boolean; const AMessage: string);
    procedure Delete(AIndex: Integer);
    function IndexOf(AColor: TColor; out AIndex: Integer): Boolean;
    procedure InitItem(var AItem: TcxBrushData; AColor: TColor);
    function IsSystemBrush(ABrush: TBrush): Boolean;
    function FindNearestItem(AColor: TColor): Integer;
    procedure Move(ASrc, ADst, ACount: Integer);
    procedure Pack;
    procedure Recreate;
    procedure Release(AIndex: Integer);
  public
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ReleaseBrush(var ABrush: TBrush);
    procedure SetBrushColor(var ABrush: TBrush; AColor: TColor);
  end;

const
  DisableMap: TcxColorTransitionMap = (RedScale: 0.0729; GreenScale: 0.7146; BlueScale: 0.2125; SrcAlpha: 105; SrcConstantAlpha: 151);
  FadeMap: TcxColorTransitionMap = (RedScale: 0.299; GreenScale: 0.587; BlueScale: 0.114; SrcAlpha: 192; SrcConstantAlpha: 64);
  GrayMap: TcxColorTransitionMap = (RedScale: 0.299; GreenScale: 0.587; BlueScale: 0.114; SrcAlpha: $FF; SrcConstantAlpha: $FF);

type
  TcxColorInfo = record
    Name: string;
    Color: TColor;
  end;

const
  cxColorsByName: array[0..168] of TcxColorInfo = (
    (Name: 'aliceblue';            Color: $00FFF8F0),
    (Name: 'antiquewhite';         Color: $00D7EBFA),
    (Name: 'aqua';                 Color: clAqua),
    (Name: 'aquamarine';           Color: $007FD4FF),
    (Name: 'azure';                Color: $00FFFFF0),
    (Name: 'beige';                Color: $00DCF5F5),
    (Name: 'bisque';               Color: $00C4E4FF),
    (Name: 'black';                Color: clBlack),
    (Name: 'blanchedalmond';       Color: $00CDFFFF),
    (Name: 'blue';                 Color: clBlue),
    (Name: 'blueviolet';           Color: $00E22B8A),
    (Name: 'brown';                Color: $002A2AA5),
    (Name: 'burlywood';            Color: $0087B8DE),
    (Name: 'cadetblue';            Color: $00A09E5F),
    (Name: 'chartreuse';           Color: $0000FF7F),
    (Name: 'chocolate';            Color: $001E69D2),
    (Name: 'coral';                Color: $00507FFF),
    (Name: 'cornflowerblue';       Color: $00ED9564),
    (Name: 'cornsilk';             Color: $00DCF8FF),
    (Name: 'crimson';              Color: $003C14DC),
    (Name: 'cyan';                 Color: $00FFFF00),
    (Name: 'darkblue';             Color: $008B0000),
    (Name: 'darkcyan';             Color: $008B8B00),
    (Name: 'darkgoldenrod';        Color: $000B86B8),
    (Name: 'darkgray';             Color: $00A9A9A9),
    (Name: 'darkgreen';            Color: $00006400),
    (Name: 'darkkhaki';            Color: $006BB7BD),
    (Name: 'darkmagenta';          Color: $008B008B),
    (Name: 'darkolivegreen';       Color: $002F6B55),
    (Name: 'darkorange';           Color: $00008CFF),
    (Name: 'darkorchid';           Color: $00CC3299),
    (Name: 'darkred';              Color: $0000008B),
    (Name: 'darksalmon';           Color: $007A96E9),
    (Name: 'darkseagreen';         Color: $008FBC8F),
    (Name: 'darkslateblue';        Color: $008B3D48),
    (Name: 'darkslategray';        Color: $004F4F2F),
    (Name: 'darkturquoise';        Color: $00D1CE00),
    (Name: 'darkviolet';           Color: $00D30094),
    (Name: 'deeppink';             Color: $009314FF),
    (Name: 'deepskyblue';          Color: $00FFBF00),
    (Name: 'dimgray';              Color: $00696969),
    (Name: 'dodgerblue';           Color: $00FF901E),
    (Name: 'firebrick';            Color: $002222B2),
    (Name: 'floralwhite';          Color: $00F0FAFF),
    (Name: 'forestgreen';          Color: $00228B22),
    (Name: 'fuchsia';              Color: $00FF00FF),
    (Name: 'gainsboro';            Color: $00DCDCDC),
    (Name: 'ghostwhite';           Color: $00FFF8F8),
    (Name: 'gold';                 Color: $0000D7FF),
    (Name: 'goldenrod';            Color: $0020A5DA),
    (Name: 'gray';                 Color: clGray),
    (Name: 'green';                Color: clGreen),
    (Name: 'greenyellow';          Color: $002FFFAD),
    (Name: 'honeydew';             Color: $00F0FFF0),
    (Name: 'hotpink';              Color: $00B469FF),
    (Name: 'indianred';            Color: $005C5CCD),
    (Name: 'indigo';               Color: $0082004B),
    (Name: 'ivory';                Color: $00F0F0FF),
    (Name: 'khaki';                Color: $008CE6F0),
    (Name: 'lavender';             Color: $00FAE6E6),
    (Name: 'lavenderblush';        Color: $00F5F0FF),
    (Name: 'lawngreen';            Color: $0000FC7C),
    (Name: 'lemonchiffon';         Color: $00CDFAFF),
    (Name: 'lightblue';            Color: $00E6D8AD),
    (Name: 'lightcoral';           Color: $008080F0),
    (Name: 'lightcyan';            Color: $00FFFFE0),
    (Name: 'lightgoldenrodyellow'; Color: $00D2FAFA),
    (Name: 'lightgreen';           Color: $0090EE90),
    (Name: 'lightgrey';            Color: $00D3D3D3),
    (Name: 'lightpink';            Color: $00C1B6FF),
    (Name: 'lightsalmon';          Color: $007AA0FF),
    (Name: 'lightseagreen';        Color: $00AAB220),
    (Name: 'lightskyblue';         Color: $00FACE87),
    (Name: 'lightslategray';       Color: $00998877),
    (Name: 'lightsteelblue';       Color: $00DEC4B0),
    (Name: 'lightyellow';          Color: $00E0FFFF),
    (Name: 'lime';                 Color: clLime),
    (Name: 'limegreen';            Color: $0032CD32),
    (Name: 'linen';                Color: $00E6F0FA),
    (Name: 'magenta';              Color: $00FF00FF),
    (Name: 'maroon';               Color: clMaroon),
    (Name: 'mediumaquamarine';     Color: $00AACD66),
    (Name: 'mediumblue';           Color: $00CD0000),
    (Name: 'mediumorchid';         Color: $00D355BA),
    (Name: 'mediumpurple';         Color: $00DB7093),
    (Name: 'mediumseagreen';       Color: $0071B33C),
    (Name: 'mediumpurple';         Color: $00DB7093),
    (Name: 'mediumslateblue';      Color: $00EE687B),
    (Name: 'mediumspringgreen';    Color: $009AFA00),
    (Name: 'mediumturquoise';      Color: $00CCD148),
    (Name: 'mediumvioletred';      Color: $008515C7),
    (Name: 'midnightblue';         Color: $00701919),
    (Name: 'mintcream';            Color: $00FAFFF5),
    (Name: 'mistyrose';            Color: $00E1E4FF),
    (Name: 'moccasin';             Color: $00B5E4FF),
    (Name: 'navajowhite';          Color: $00ADDEFF),
    (Name: 'navy';                 Color: clNavy),
    (Name: 'oldlace';              Color: $00E6F5FD),
    (Name: 'olive';                Color: $00008080),
    (Name: 'olivedrab';            Color: $00238E6B),
    (Name: 'orange';               Color: $0000A5FF),
    (Name: 'orangered';            Color: $000045FF),
    (Name: 'orchid';               Color: $00D670DA),
    (Name: 'palegoldenrod';        Color: $00AAE8EE),
    (Name: 'palegreen';            Color: $0098FB98),
    (Name: 'paleturquoise';        Color: $00EEEEAF),
    (Name: 'palevioletred';        Color: $009370DB),
    (Name: 'papayawhip';           Color: $00D5EFFF),
    (Name: 'peachpuff';            Color: $00BDDBFF),
    (Name: 'peru';                 Color: $003F85CD),
    (Name: 'pink';                 Color: $00CBC0FF),
    (Name: 'plum';                 Color: $00DDA0DD),
    (Name: 'powderblue';           Color: $00E6E0B0),
    (Name: 'purple';               Color: $00800080),
    (Name: 'red';                  Color: clRed),
    (Name: 'rosybrown';            Color: $008F8FBC),
    (Name: 'royalblue';            Color: $00E16941),
    (Name: 'saddlebrown';          Color: $0013458B),
    (Name: 'salmon';               Color: $007280FA),
    (Name: 'sandybrown';           Color: $0060A4F4),
    (Name: 'seagreen';             Color: $00578B2E),
    (Name: 'seashell';             Color: $00EEF5FF),
    (Name: 'sienna';               Color: $002D52A0),
    (Name: 'silver';               Color: $00C0C0C0),
    (Name: 'skyblue';              Color: $00EBCE87),
    (Name: 'slateblue';            Color: $00CD5A6A),
    (Name: 'slategray';            Color: $00908070),
    (Name: 'snow';                 Color: $00FAFAFF),
    (Name: 'springgreen';          Color: $007FFF00),
    (Name: 'steelblue';            Color: $00B48246),
    (Name: 'tan';                  Color: $008CB4D2),
    (Name: 'teal';                 Color: clTeal),
    (Name: 'thistle';              Color: $00D8BFD8),
    (Name: 'tomato';               Color: $004763FD),
    (Name: 'turquoise';            Color: $00D0E040),
    (Name: 'violet';               Color: $00EE82EE),
    (Name: 'wheat';                Color: $00B3DEF5),
    (Name: 'white';                Color: clWhite),
    (Name: 'whitesmoke';           Color: $00F5F5F5),
    (Name: 'yellow';               Color: clYellow),
    (Name: 'yellowgreen';          Color: $0032CD9A),

    (Name: 'activeborder';         Color: clActiveBorder),
    (Name: 'activecaption';        Color: clActiveCaption),
    (Name: 'appworkspace';         Color: clAppWorkSpace),
    (Name: 'background';           Color: clBackground),
    (Name: 'buttonface';           Color: clBtnFace),
    (Name: 'buttonhighlight';      Color: clBtnHighlight),
    (Name: 'buttonshadow';         Color: clBtnShadow),
    (Name: 'buttontext';           Color: clBtnText),
    (Name: 'captiontext';          Color: clCaptionText),
    (Name: 'graytext';             Color: clGrayText),
    (Name: 'highlight';            Color: clHighlight),
    (Name: 'highlighttext';        Color: clHighlightText),
    (Name: 'inactiveborder';       Color: clInactiveBorder),
    (Name: 'inactivecaption';      Color: clInactiveCaption),
    (Name: 'inactivecaptiontext';  Color: clInactiveCaptionText),
    (Name: 'infobackground';       Color: clInfoBk),
    (Name: 'infotext';             Color: clInfoText),
    (Name: 'menu';                 Color: clMenu),
    (Name: 'menutext';             Color: clMenuText),
    (Name: 'scrollbar';            Color: clScrollBar),
    (Name: 'threeddarkshadow';     Color: cl3DDkShadow),
    (Name: 'threedface';           Color: clBtnFace),
    (Name: 'threedhighlight';      Color: clHighlightText),
    (Name: 'threedlightshadow';    Color: cl3DLight),
    (Name: 'threedshadow';         Color: clBtnShadow),
    (Name: 'window';               Color: clWindow),
    (Name: 'windowframe';          Color: clWindowFrame),
    (Name: 'windowtext';           Color: clWindowText)
  );

var
  CustomDrawImageProc: TcxDrawImageProc = nil;

function cxFlagsToDTFlags(Flags: Integer): Integer;

procedure cxSetImageList(const AValue: TCustomImageList; var AFieldValue: TCustomImageList; const AChangeLink: TChangeLink; ANotifyComponent: TComponent);
procedure ExtendRect(var Rect: TRect; const AExtension: TRect);
function IsGlyphAssigned(AGlyph: TBitmap): Boolean;
function IsImageAssigned(AImageList: TCustomImageList; AImageIndex: Integer): Boolean;

function IsXPManifestEnabled: Boolean;

function GetRealColor(AColor: TColor): TColor;

// light colors
function GetLightColor(ABtnFaceColorPart, AHighlightColorPart, AWindowColorPart: TcxColorPart): TColor;
function GetLightBtnFaceColor: TColor;
function GetLightDownedColor: TColor;
function GetLightDownedSelColor: TColor;
function GetLightSelColor: TColor;

function GetBitmapBits(ABitmap: TBitmap; ATopDownDIB: Boolean): TRGBColors;
procedure SetBitmapBits(ABitmap: TBitmap; var AColors: TRGBColors;
  ATopDownDIB: Boolean);
function SystemAlphaBlend(ADestDC, ASrcDC: HDC; const ADestRect, ASrcRect: TRect; AConstantAlpha: Byte = $FF): Boolean;

function cxColorByName(const AText: string; var AColor: TColor): Boolean;
function cxNameByColor(AColor: TColor; var AText: string): Boolean;
function cxColorToRGBQuad(AColor: TColor; AReserved: Byte = 0): TRGBQuad;
function cxColorIsEqual(const AColor1, AColor2: TRGBQuad): Boolean;

procedure cxAlphaBlend(ADestBitmap, ASrcBitmap: TBitmap; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
procedure cxAlphaBlend(ADestDC: HDC; ASrcBitmap: TBitmap; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
procedure cxAlphaBlend(ADestDC, ASrcDC: HDC; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
procedure cxBitBlt(ADestDC, ASrcDC: HDC; const ADestRect: TRect; const ASrcTopLeft: TPoint; ROP: DWORD);
//procedure cxBitmapToTrueColorBitmap(ABitmap: TBitmap); -> cxMakeTrueColorBitmap
procedure cxBlendFunction(const ASource: TRGBQuad; var ADest: TRGBQuad; ASourceConstantAlpha: Byte);
function cxCreateBitmap(const ASize: TSize; AFormat: TPixelFormat = pf24bit): TBitmap; overload;
function cxCreateBitmap(const ARect: TRect; AFormat: TPixelFormat = pf24bit): TBitmap; overload;
function cxCreateBitmap(AWidth, AHeight: Integer; AFormat: TPixelFormat = pf24bit): TBitmap; overload;
function cxCreateTrueColorBitmap(const ASize: TSize): TBitmap; overload;
function cxCreateTrueColorBitmap(AWidth, AHeight: Integer): TBitmap; overload;
function cxCreateTrueColorBitmapHandle(AWidth, AHeight: Integer; ABPP: Integer = 32): HBitmap;
procedure cxDrawDesignRect(ACanvas: TcxCanvas; const ARect: TRect; ASelected: Boolean);
procedure cxDrawBitmap(ADestDC: THandle; ASrcBitmap: TBitmap;
  const ADestRect: TRect; const ASrcPoint: TPoint; AMode: Integer = SRCCOPY);
procedure cxDrawImage(ADC: THandle; AGlyphRect, ABackgroundRect: TRect; AGlyph: TBitmap;
  AImages: TCustomImageList; AImageIndex: Integer; ADrawMode: TcxImageDrawMode;
  ASmoothImage: Boolean = False; ABrush: THandle = 0;
  ATransparentColor: TColor = clNone; AUseLeftBottomPixelAsTransparent: Boolean = True);
procedure cxDrawImageList(AImageListHandle: HIMAGELIST; AImageIndex: Integer;
  ADC: HDC; APoint: TPoint; ADrawingStyle: TDrawingStyle; AImageType: TImageType);
procedure cxDrawHatch(ADC: HDC; const ARect: TRect; AColor1, AColor2: TColor; AStep: Byte; AAlpha1: Byte = $FF; AAlpha2: Byte = $FF);
procedure cxSmoothResizeBitmap(ASource, ADestination: TBitmap; AForceUseLanczos3Filter: Boolean = False);

procedure cxMakeTrueColorBitmap(ASourceBitmap, ATrueColorBitmap: TBitmap);
procedure cxMakeMaskBitmap(ASourceBitmap, AMaskBitmap: TBitmap);

{!!! TODO: adapt to .net}
// mouse cursor size
function cxGetCursorSize: TSize;

// image helper routines
procedure cxAlphaBlend(ASource: TBitmap; ARect: TRect; const ASelColor: TColor; Alpha: Byte = 170); overload;
procedure cxAlphaBlend(ADest, ABkSource, ASource: TBitmap; Alpha: Byte = cxDefaultAlphaValue); overload;
procedure cxApplyViewParams(ACanvas: TcxCanvas; const AViewParams: TcxViewParams);
procedure cxCopyImage(ASource, ADest: TBitmap; const ASrcOffset, ADstOffset: TPoint; const ARect: TRect); overload;
procedure cxCopyImage(ASource, ADest: TCanvas; const ASrcOffset, ADstOffset: TPoint; const ARect: TRect); overload;
procedure cxDrawArrows(ACanvas: TCanvas; const ARect: TRect;
  ASide: TcxBorder; AColor: TColor; APenColor: TColor = clDefault);
procedure cxFillHalfToneRect(Canvas: TCanvas; const ARect: TRect; ABkColor, AColor: TColor);
procedure cxSetCanvasOrg(ACanvas: TCanvas; var AOrg: TRect);

function cxGetTextExtentPoint32(ADC: THandle; const AText: string; out ASize: TSize; ACharCount: Integer = -1): Boolean;
procedure cxGetTextLines(const AText: string; ACanvas: TcxCanvas; const ARect: TRect; ALines: TStrings);
function cxDrawText(ADC: THandle; const AText: string; var ARect: TRect;
  AFormat: UINT; ACharCount: Integer = - 1): Integer;
function cxExtTextOut(ADC: THandle; const AText: string; const APoint: TPoint;
  const ARect: TRect; AOptions: UINT; ACharCount: Integer = -1): Boolean; overload;
function cxExtTextOut(ADC: THandle; const AText: string; const APoint: TPoint;
  AOptions: UINT; ACharCount: Integer = -1): Boolean; overload;
procedure cxInvalidateRect(AHandle: THandle; const ARect: TRect; AEraseBackground: Boolean = True); overload;
procedure cxInvalidateRect(AHandle: THandle; AEraseBackground: Boolean = True); overload;

function cxTextHeight(AFont: TFont; const S: string = 'Wg'; AFontSize: Integer = 0): Integer;
function cxTextWidth(AFont: TFont; const S: string; AFontSize: Integer = 0): Integer;
function cxTextExtent(AFont: TFont; const S: string; AFontSize: Integer = 0): TSize;
function cxTextSize(ADC: THandle; const AText: string): TSize;
function cxGetTextRect(ADC: THandle; const AText: string; ARowCount: Integer;
  AReturnMaxRectHeight: Boolean = False): TRect; overload;
function cxGetTextRect(AFont: TFont; const AText: string; ARowCount: Integer): TRect; overload;
function cxGetScreenPixelsPerInch(AHorizontal: Boolean = False): Integer;
function cxGetStringAdjustedToWidth(ADC: HDC; AFontHandle: HFONT; const S: string; AWidth: Integer): string; overload;
function cxGetStringAdjustedToWidth(AFont: TFont; const S: string; AWidth: Integer): string; overload;

function cxGetBitmapData(ABitmapHandle: HBITMAP; out ABitmapData: Windows.TBitmap): Boolean;
function cxGetBitmapPixelFormat(ABitmap: TBitmap): Integer;
function cxGetBrushData(ABrushHandle: HBRUSH; out ALogBrush: TLogBrush): Boolean; overload;
function cxGetBrushData(ABrushHandle: HBRUSH): TLogBrush; overload;
function cxGetFontData(AFontHandle: HFONT; out ALogFont: TLogFont): Boolean;
function cxGetPenData(APenHandle: HPEN; out ALogPen: TLogPen): Boolean;
procedure cxResetFont(const AFont: TFont);

function cxGetWritingDirection(AFontCharset: TFontCharset; const AText: string): TCanvasOrientation;
procedure cxDrawThemeParentBackground(AControl: TWinControl; ACanvas: TcxCanvas; const ARect: TRect); overload;
procedure cxDrawThemeParentBackground(AControl: TWinControl; ACanvas: TCanvas; const ARect: TRect); overload;
procedure cxDrawTransparentControlBackground(AControl: TWinControl;
  ACanvas: TcxCanvas; ARect: TRect; APaintParentWithChildren: Boolean = True); overload;
procedure cxDrawTransparentControlBackground(AControl: TWinControl;
  ACanvas: TCanvas; const ARect: TRect; APaintParentWithChildren: Boolean = True); overload;
function cxScreenCanvas: TcxScreenCanvas;

implementation

uses
  Messages, Math, Menus, cxControls, cxGeometry, dxUxTheme, dxOffice11,
  cxDrawTextUtils;

type
  TCanvasAccess = class(TCanvas);
  TBitmapAccess = class(TBitmap);

  TContributor = record
    Pixel: Integer;
    Weight: Integer;
  end;
  TContributorArray = array of TContributor;

  TContributors = record
    Count: Integer;
    Contributors: TContributorArray;
  end;
  TContributorList = array of TContributors;

const
{!!! TODO: adapt to .net}
  BaseRgns: array[0..3, 0..6, 0..1] of Integer =
  (((0, -1), (-5, -6),(-2, -6), (-2, -9), (2, -9), (2, -6), (5, -6)),
   ((0, 0), (5, 5), (2, 5), (2, 8), (-2, 8), (-2, 5), (-5, 5)),
   ((-1, 0), (-6, -5), (-6, -2), (-9, -2), (-9, 2), (-6, 2), (-6, 5)),
   ((0, 0), (5, 5), (5, 2), (8, 2), (8, -2), (5, -2), (5, -5)));
  DefaultBlendFunction: TBlendFunction =
   (BlendOp: AC_SRC_OVER;
    BlendFlags: 0;
    SourceConstantAlpha: cxDefaultAlphaValue;
    AlphaFormat: $0);

var
  VCLAlphaBlend: function(DC: LongWord; p2, p3, p4, p5: Integer; DC6: LongWord;
    p7, p8, p9, p10: Integer; p11: TBlendFunction): BOOL; stdcall;
  ScreenCanvas: TcxScreenCanvas = nil;
  DrawBitmap, ImageBitmap, MaskBitmap: TcxBitmap;

procedure cxBitmapInit(var ABitmap: TcxBitmap; AWidth, AHeight: Integer);
begin
  if ABitmap = nil then
    ABitmap := TcxBitmap.CreateSize(AWidth, AHeight)
  else
  begin
    ABitmap.TransparentPixels.Clear;
    ABitmap.SetSize(AWidth, AHeight);
  end;
end;

function GetDrawBitmap(AWidth, AHeight: Integer): TcxBitmap;
begin
  cxBitmapInit(DrawBitmap, AWidth, AHeight);
  Result := DrawBitmap;
end;

function GetImageBitmap(AWidth, AHeight: Integer): TcxBitmap;
begin
  cxBitmapInit(ImageBitmap, AWidth, AHeight);
  Result := ImageBitmap;
end;

function GetMaskBitmap(AWidth, AHeight: Integer): TcxBitmap;
begin
  cxBitmapInit(MaskBitmap, AWidth, AHeight);
  Result := MaskBitmap;
end;

function cxFlagsToDTFlags(Flags: Integer): Integer;
begin
  Result := DT_NOPREFIX;
  if cxAlignLeft and Flags <> 0 then
    Result := Result or DT_LEFT;
  if cxAlignRight and Flags <> 0 then
    Result := Result or DT_RIGHT;
  if cxAlignHCenter and Flags <> 0 then
    Result := Result or DT_CENTER;
  if cxAlignTop and Flags <> 0 then
    Result := Result or DT_TOP;
  if cxAlignBottom and Flags <> 0 then
    Result := Result or DT_BOTTOM;
  if cxAlignVCenter and Flags <> 0 then
    Result := Result or DT_VCENTER;
  if cxSingleLine and Flags <> 0 then
    Result := Result or DT_SINGLELINE;
  if cxDontClip and Flags <> 0 then
    Result := Result or DT_NOCLIP;
  if cxExpandTabs and Flags <> 0 then
    Result := Result or DT_EXPANDTABS;
  if cxShowPrefix and Flags <> 0 then
    Result := Result and not DT_NOPREFIX;
  if cxWordBreak and Flags <> 0 then
  begin
    Result := Result or DT_WORDBREAK;
    if cxDontBreakChars and Flags = 0 then
      Result := Result or DT_EDITCONTROL;
  end;
  if cxShowEndEllipsis and Flags <> 0 then
    Result := Result or DT_END_ELLIPSIS;
  if cxDontPrint and Flags <> 0 then
    Result := Result or DT_CALCRECT;
  if cxShowPathEllipsis and Flags <> 0 then
    Result := Result or DT_PATH_ELLIPSIS;
end;

procedure cxSetImageList(const AValue: TCustomImageList; var AFieldValue: TCustomImageList; const AChangeLink: TChangeLink; ANotifyComponent: TComponent);
begin
  if AValue <> AFieldValue then
  begin
    if AFieldValue <> nil then
    begin
      AFieldValue.RemoveFreeNotification(ANotifyComponent);
      if AChangeLink <> nil then
        AFieldValue.UnRegisterChanges(AChangeLink);
    end;
    AFieldValue := AValue;
    if AValue <> nil then
    begin
      if AChangeLink <> nil then
        AValue.RegisterChanges(AChangeLink);
      AValue.FreeNotification(ANotifyComponent);
    end;
    if AChangeLink <> nil then
      AChangeLink.Change;
  end;
end;

procedure ExtendRect(var Rect: TRect; const AExtension: TRect);
begin
  with AExtension do
  begin
    Inc(Rect.Left, Left);
    Inc(Rect.Top, Top);
    Dec(Rect.Right, Right);
    Dec(Rect.Bottom, Bottom);
  end;
end;

function IsGlyphAssigned(AGlyph: TBitmap): Boolean;
begin
  Result := (AGlyph <> nil) and not AGlyph.Empty;
end;

function IsImageAssigned(AImageList: TCustomImageList; AImageIndex: Integer): Boolean;
begin
  Result := (AImageList <> nil) and (0 <= AImageIndex) and (AImageIndex < AImageList.Count);
end;

function IsXPManifestEnabled: Boolean;
{$IFNDEF DELPHI7}
const
  ComCtlVersionIE6 = $00060000;
{$ENDIF}
begin
  Result := GetComCtlVersion >= ComCtlVersionIE6
end;

function GetRealColor(AColor: TColor): TColor;
var
  DC: HDC;
begin
  DC := GetDC(0);
  Result := GetNearestColor(DC, AColor);
  ReleaseDC(0, DC);
end;

function GetChannelValue(AValue: Integer): Byte;
begin
  if AValue < 0 then
    Result := 0
  else
    if AValue > 255 then
      Result := 255
    else
      Result := AValue;
end;

function GetLightColor(ABtnFaceColorPart, AHighlightColorPart, AWindowColorPart: TcxColorPart): TColor;
var
  ABtnFaceColor, AHighlightColor, AWindowColor: TColor;

  function GetLightIndex(ABtnFaceValue, AHighlightValue, AWindowValue: Byte): Integer;
  begin
    Result := GetChannelValue(
      MulDiv(ABtnFaceValue, ABtnFaceColorPart, 100) +
      MulDiv(AHighlightValue, AHighlightColorPart, 100) +
      MulDiv(AWindowValue, AWindowColorPart, 100));
  end;

begin
  ABtnFaceColor := ColorToRGB(clBtnFace);
  AHighlightColor := ColorToRGB(clHighlight);
  AWindowColor := ColorToRGB(clWindow);
  if (ABtnFaceColor = 0) or (ABtnFaceColor = $FFFFFF) then
    Result := AHighlightColor
  else
    Result := RGB(
      GetLightIndex(GetRValue(ABtnFaceColor), GetRValue(AHighlightColor), GetRValue(AWindowColor)),
      GetLightIndex(GetGValue(ABtnFaceColor), GetGValue(AHighlightColor), GetGValue(AWindowColor)),
      GetLightIndex(GetBValue(ABtnFaceColor), GetBValue(AHighlightColor), GetBValue(AWindowColor)));
end;

function GetLightBtnFaceColor: TColor;

  function GetLightValue(Value: Byte): Byte;
  begin
    Result := GetChannelValue(Value + MulDiv(255 - Value, 16, 100));
  end;

begin
  Result := ColorToRGB(clBtnFace);
  Result := RGB(
    GetLightValue(GetRValue(Result)),
    GetLightValue(GetGValue(Result)),
    GetLightValue(GetBValue(Result)));
  Result := GetRealColor(Result);
end;

function GetLightDownedColor: TColor;
begin
  Result := GetRealColor(GetLightColor(11, 9, 73));
end;

function GetLightDownedSelColor: TColor;
begin
  Result := GetRealColor(GetLightColor(14, 44, 40));
end;

function GetLightSelColor: TColor;
begin
  Result := GetRealColor(GetLightColor(-2, 30, 72));
end;

procedure FillBitmapInfoHeader(out AHeader: TBitmapInfoHeader; AWidth, AHeight: Integer;
  ATopDownDIB: Boolean); overload;
begin
  AHeader.biSize := SizeOf(TBitmapInfoHeader);
  AHeader.biWidth := AWidth;
  if ATopDownDIB then
    AHeader.biHeight := -AHeight
  else
    AHeader.biHeight := AHeight;
  AHeader.biPlanes := 1;
  AHeader.biBitCount := 32;
  AHeader.biCompression := BI_RGB;
end;

procedure FillBitmapInfoHeader(out AHeader: TBitmapInfoHeader; ABitmap: TBitmap;
  ATopDownDIB: Boolean); overload;
begin
  FillBitmapInfoHeader(AHeader, ABitmap.Width, ABitmap.Height, ATopDownDIB);
end;

function GetBitmapBits(ABitmap: TBitmap; ATopDownDIB: Boolean): TRGBColors;
var
  AInfo: TBitmapInfo;
begin
  SetLength(Result, ABitmap.Width * ABitmap.Height);
  FillBitmapInfoHeader(AInfo.bmiHeader, ABitmap, ATopDownDIB);
{$IFDEF CXTEST}
  if GetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, Result, AInfo, DIB_RGB_COLORS) = 0 then
  begin
    FreeAndNil(ScreenCanvas);
  {$IFDEF DELPHI9}
    Assert(GetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, Result, AInfo, DIB_RGB_COLORS) <> 0, 'GetBitmapBits fails');
  {$ELSE}
    GetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, Result, AInfo, DIB_RGB_COLORS);
  {$ENDIF}
  end;
{$ELSE}
  GetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, Result, AInfo, DIB_RGB_COLORS);
{$ENDIF}
end;

procedure SetBitmapBits(ABitmap: TBitmap; var AColors: TRGBColors;
  ATopDownDIB: Boolean);
var
  AInfo: TBitmapInfo;
begin
  FillBitmapInfoHeader(AInfo.bmiHeader, ABitmap, ATopDownDIB);
{$IFDEF CXTEST}
  if SetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, AColors, AInfo, DIB_RGB_COLORS) = 0 then
  begin
    FreeAndNil(ScreenCanvas);
  {$IFDEF DELPHI9}
    Assert(SetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, AColors, AInfo, DIB_RGB_COLORS) <> 0, Format('SetBitmapBits fails W=%d H=%d', [ABitmap.Width, ABitmap.Height]));
  {$ELSE}
    SetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, AColors, AInfo, DIB_RGB_COLORS);
  {$ENDIF}
  end;
{$ELSE}
  SetDIBits(cxScreenCanvas.Handle, ABitmap.Handle, 0, ABitmap.Height, AColors, AInfo, DIB_RGB_COLORS);
{$ENDIF}
  AColors := nil;
end;

function SystemAlphaBlend(ADestDC, ASrcDC: HDC; const ADestRect, ASrcRect: TRect; AConstantAlpha: Byte = $FF): Boolean;
{$IFNDEF DELPHI6}
const
  AC_SRC_ALPHA = 1;
{$ENDIF}
var
  ABlendFunction: TBlendFunction;
begin
  ABlendFunction.BlendOp := AC_SRC_OVER;
  ABlendFunction.BlendFlags := 0;
  ABlendFunction.SourceConstantAlpha := AConstantAlpha;
  ABlendFunction.AlphaFormat := AC_SRC_ALPHA;
  Result := Assigned(VCLAlphaBlend) and VCLAlphaBlend(
    ADestDC, ADestRect.Left, ADestRect.Top, cxRectWidth(ADestRect), cxRectHeight(ADestRect),
    ASrcDC, ASrcRect.Left, ASrcRect.Top, cxRectWidth(ASrcRect), cxRectHeight(ASrcRect), ABlendFunction);
end;

function cxColorByName(const AText: string; var AColor: TColor): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(cxColorsByName) to High(cxColorsByName) do
    if SameText(AText, cxColorsByName[I].Name) then
    begin
      AColor := cxColorsByName[I].Color;
      Result := True;
      Break;
    end;
end;

function cxNameByColor(AColor: TColor; var AText: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(cxColorsByName) to High(cxColorsByName) do
    if AColor = cxColorsByName[I].Color then
    begin
      AText := cxColorsByName[I].Name;
      Result := True;
      Break;
    end;
end;

function cxColorToRGBQuad(AColor: TColor; AReserved: Byte = 0): TRGBQuad;
begin
  DWORD(Result) := ColorToRGB(AColor);

  //#DG exchange values
  Result.rgbBlue := Result.rgbBlue xor Result.rgbRed;
  Result.rgbRed := Result.rgbBlue xor Result.rgbRed;
  Result.rgbBlue := Result.rgbBlue xor Result.rgbRed;
  Result.rgbReserved := AReserved;
end;

procedure CommonAlphaBlend(ADestDC, ASrcDC: HDC; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean; AConstantAlpha: Byte = $FF);

  function CreateDirectBitmap(ASrcDC: HDC; const ASrcRect: TRect): TBitmap;
  var
    ARect: TRect;
  begin
    ARect := Rect(0, 0, cxRectWidth(ASrcRect), cxRectHeight(ASrcRect));
    Result := cxCreateBitmap(ARect, pf32bit);
    Result.Canvas.Brush.Color := 0;
    Result.Canvas.FillRect(ARect);
    cxBitBlt(Result.Canvas.Handle, ASrcDC, ARect, ASrcRect.TopLeft, SRCCOPY);
  end;

  function cxRectIdentical(const ARect1, ARect2: TRect): Boolean;
  begin
    Result := (cxRectWidth(ARect1) = cxRectWidth(ARect2)) and (cxRectHeight(ARect1) = cxRectHeight(ARect2));
  end;

  procedure ResizeBitmap(ADestBitmap, ASrcBitmap: TBitmap);
  begin
    StretchBlt(ADestBitmap.Canvas.Handle, 0, 0, ADestBitmap.Width, ADestBitmap.Height,
      ASrcBitmap.Canvas.Handle, 0, 0, ASrcBitmap.Width, ASrcBitmap.Height, SRCCOPY);
  end;

  procedure InternalAlphaBlend(ADestBitmap, ASrcBitmap: TBitmap);

    procedure SoftwareAlphaBlend(AWidth, AHeight: Integer);
    var
      ASourceColors, ADestColors: TRGBColors;
      I: Integer;
    begin
      ASourceColors := GetBitmapBits(ASrcBitmap, False);
      ADestColors := GetBitmapBits(ADestBitmap, False);
      for I := 0 to AWidth * AHeight - 1 do
        cxBlendFunction(ASourceColors[I], ADestColors[I], AConstantAlpha);
      SetBitmapBits(ADestBitmap, ADestColors, False);
    end;

  var
    AClientRect: TRect;
  begin
    AClientRect := Rect(0, 0, ADestBitmap.Width, ADestBitmap.Height);
    if not SystemAlphaBlend(ADestBitmap.Canvas.Handle, ASrcBitmap.Canvas.Handle, AClientRect, AClientRect, AConstantAlpha) then
      SoftwareAlphaBlend(AClientRect.Right, AClientRect.Bottom);
  end;

  procedure ComplexAlphaBlend;
  var
    ADirectDestBitmap, ADirectSrcBitmap, AStretchedSrcBitmap: TBitmap;
  begin
    ADirectSrcBitmap := CreateDirectBitmap(ASrcDC, ASrcRect);
    ADirectDestBitmap := CreateDirectBitmap(ADestDC, ADestRect);
    AStretchedSrcBitmap := cxCreateBitmap(ADestRect, pf32bit);
    try
      if ASmoothImage then
        cxSmoothResizeBitmap(ADirectSrcBitmap, AStretchedSrcBitmap, True)
      else
        ResizeBitmap(AStretchedSrcBitmap, ADirectSrcBitmap);
      InternalAlphaBlend(ADirectDestBitmap, AStretchedSrcBitmap);
      cxBitBlt(ADestDC, ADirectDestBitmap.Canvas.Handle, ADestRect, cxNullPoint, SRCCOPY);
    finally
      AStretchedSrcBitmap.Free;
      ADirectDestBitmap.Free;
      ADirectSrcBitmap.Free;
    end;
  end;

begin
  ASmoothImage := ASmoothImage and not cxRectIdentical(ADestRect, ASrcRect);
  if IsWin9X or not Assigned(VCLAlphaBlend) or ASmoothImage then
    ComplexAlphaBlend
  else
    SystemAlphaBlend(ADestDC, ASrcDC, ADestRect, ASrcRect, AConstantAlpha);
end;

procedure cxAlphaBlend(ADestBitmap, ASrcBitmap: TBitmap; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
begin
  CommonAlphaBlend(ADestBitmap.Canvas.Handle, ASrcBitmap.Canvas.Handle, ADestRect, ASrcRect, ASmoothImage, AConstantAlpha);
end;

procedure cxAlphaBlend(ADestDC: HDC; ASrcBitmap: TBitmap; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
begin
  CommonAlphaBlend(ADestDC, ASrcBitmap.Canvas.Handle, ADestRect, ASrcRect, ASmoothImage, AConstantAlpha);
end;

procedure cxAlphaBlend(ADestDC, ASrcDC: HDC; const ADestRect, ASrcRect: TRect; ASmoothImage: Boolean = False; AConstantAlpha: Byte = $FF); overload;
begin
  CommonAlphaBlend(ADestDC, ASrcDC, ADestRect, ASrcRect, ASmoothImage, AConstantAlpha);
end;

procedure cxBitBlt(ADestDC, ASrcDC: HDC; const ADestRect: TRect; const ASrcTopLeft: TPoint; ROP: DWORD);
begin
  BitBlt(ADestDC, ADestRect.Left, ADestRect.Top, cxRectWidth(ADestRect), cxRectHeight(ADestRect),
    ASrcDC, ASrcTopLeft.X, ASrcTopLeft.Y, ROP);
end;

procedure cxBlendFunction(const ASource: TRGBQuad; var ADest: TRGBQuad; ASourceConstantAlpha: Byte);

  function GetValue(AValue: Single): Byte;
  begin
    Result := GetChannelValue(Round(AValue));
  end;

var
  ASCA, ASrcAlpha: Single;
begin
  ASCA := ASourceConstantAlpha / 255;
  ASrcAlpha := 1 - ASource.rgbReserved * ASCA / 255;

  ADest.rgbRed := GetValue(ASource.rgbRed * ASCA + ASrcAlpha * ADest.rgbRed);
  ADest.rgbGreen := GetValue(ASource.rgbGreen * ASCA + ASrcAlpha * ADest.rgbGreen);
  ADest.rgbBlue := GetValue(ASource.rgbBlue * ASCA + ASrcAlpha * ADest.rgbBlue);
  ADest.rgbReserved := GetValue(ASource.rgbReserved * ASCA + ASrcAlpha * ADest.rgbReserved);
end;

procedure cxSetBitmapParams(ABitmap: TBitmap; AWidth, AHeight: Integer; AFormat: TPixelFormat);
begin
{$IFDEF DELPHI6}
  ABitmap.PixelFormat := AFormat;
{$ENDIF}
  ABitmap.Width := AWidth;
  ABitmap.Height := AHeight;
{$IFNDEF DELPHI6}
  ABitmap.PixelFormat := AFormat;
{$ENDIF}
end;

function cxCreateBitmap(const ASize: TSize; AFormat: TPixelFormat = pf24bit): TBitmap;
begin
  Result := cxCreateBitmap(ASize.cx, ASize.cy, AFormat);
end;

function cxCreateBitmap(const ARect: TRect; AFormat: TPixelFormat = pf24bit): TBitmap;
begin
  Result := cxCreateBitmap(cxRectWidth(ARect), cxRectHeight(ARect), AFormat);
end;

function cxCreateBitmap(AWidth, AHeight: Integer; AFormat: TPixelFormat = pf24bit): TBitmap;
begin
  Result := TBitmap.Create;
  cxSetBitmapParams(Result, AWidth, AHeight, AFormat);
end;

function cxCreateTrueColorBitmap(const ASize: TSize): TBitmap;
begin
  Result := cxCreateTrueColorBitmap(ASize.cx, ASize.cy);
end;

function cxCreateTrueColorBitmap(AWidth, AHeight: Integer): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Handle := cxCreateTrueColorBitmapHandle(AWidth, AHeight);
end;

function cxCreateTrueColorBitmapHandle(AWidth, AHeight: Integer; ABPP: Integer = 32): HBitmap;
begin
  Result := CreateBitmap(AWidth, AHeight, 1, ABPP, nil);
end;

procedure cxDrawDesignRect(ACanvas: TcxCanvas; const ARect: TRect; ASelected: Boolean);
const
  Colors: array[Boolean] of TColor = ($A0FFA0, $9090FF);
var
  AColor: TColor;
  I: Integer;
  AShadowRect: TRect;
begin
  if not IsRectEmpty(ARect) then
  begin
    ACanvas.SaveState;
    try
      ACanvas.SetClipRegion(TcxRegion.Create(ARect), roSet);
      AColor := Colors[ASelected];
      ACanvas.FillRect(ARect, AColor);
      ACanvas.Pen.Color := Dark(AColor, 75);
      for I := 1 to MulDiv(ARect.Right, 3, 2) do
        ACanvas.Polyline([Point(ARect.Right - I * 3, ARect.Top), Point(ARect.Right, ARect.Top + I * 3)]);
      ACanvas.FrameRect(ARect, Dark(AColor, 50));
    finally
      ACanvas.RestoreState;
    end;
    ACanvas.ExcludeClipRect(ARect);
    AShadowRect := cxRectOffset(ARect, 1, 1);
    ACanvas.FillRect(AShadowRect, clBtnShadow);
    ACanvas.ExcludeClipRect(AShadowRect);
  end;
end;

function cxGetBitmapPixelFormat(ABitmap: TBitmap): Integer;
const
  ABitCounts: array [pf1Bit..pf32Bit] of Byte = (1,4,8,16,16,24,32);
begin
  case ABitmap.PixelFormat of
    pf1bit..pf32Bit: Result := ABitCounts[ABitmap.PixelFormat]
  else
    Result := GetDeviceCaps(ABitmap.Canvas.Handle, BITSPIXEL);
  end;
end;

procedure cxDrawBitmap(ADestDC: THandle; ASrcBitmap: TBitmap;
  const ADestRect: TRect; const ASrcPoint: TPoint; AMode: Integer); overload;

  procedure InternalDrawBitmap;

    procedure SoftwareBitBlt;
    var
      ABitmap: TcxBitmap;
    begin
      ABitmap := TcxBitmap.CreateSize(ADestRect);
      try
        cxBitBlt(ABitmap.Canvas.Handle, ASrcBitmap.Canvas.Handle, ABitmap.ClientRect, ASrcPoint, SRCCOPY);
        ABitmap.TransformBitmap(btmResetAlpha);
        cxBitBlt(ADestDC, ABitmap.Canvas.Handle, ADestRect, cxNullPoint, AMode);
      finally
        ABitmap.Free;
      end;
    end;

   begin
    if IsWin9X and (GetDeviceCaps(ADestDC, BITSPIXEL) = 32) and (cxGetBitmapPixelFormat(ASrcBitmap) < 32) then
      SoftwareBitBlt
    else
      cxBitBlt(ADestDC, ASrcBitmap.Canvas.Handle, ADestRect, ASrcPoint, AMode);
  end;

var
  APrevPalette: HPALETTE;
begin
  if (ASrcBitmap.Palette <> 0) and (GetDeviceCaps(ADestDC, BITSPIXEL) <= 8) then
  begin
    APrevPalette := SelectPalette(ADestDC, ASrcBitmap.Palette, True);
    RealizePalette(ADestDC);
    InternalDrawBitmap;
    SelectPalette(ADestDC, APrevPalette, True);
  end
  else
    InternalDrawBitmap;
end;

procedure cxDrawImage(ADC: THandle; AGlyphRect, ABackgroundRect: TRect; AGlyph: TBitmap;
  AImages: TCustomImageList; AImageIndex: Integer; ADrawMode: TcxImageDrawMode;
  ASmoothImage: Boolean = False; ABrush: THandle = 0;
  ATransparentColor: TColor = clNone; AUseLeftBottomPixelAsTransparent: Boolean = True);

  procedure DrawBackGround(ABitmap: TcxBitmap);
  begin
    if ABrush = 0 then
      cxBitBlt(ABitmap.Canvas.Handle, ADC, ABitmap.ClientRect, ABackgroundRect.TopLeft, SRCCOPY)
    else
      FillRect(ABitmap.Canvas.Handle, ABitmap.ClientRect, ABrush);
  end;

  procedure DrawImage(ABitmap: TcxBitmap; ADrawMode: TcxImageDrawMode);

    procedure MakeImage(AImageBitmap: TcxBitmap; out AIsAlphaUsed: Boolean);
    begin
      if not IsGlyphAssigned(AGlyph) then
      begin
        if AImages is TcxImageList then
          TcxImageList(AImages).GetImageInfo(AImageIndex, AImageBitmap, nil)
        else
          TcxImageList.GetImageInfo(AImages.Handle, AImageIndex, AImageBitmap, nil);

//        cxDrawImageList(AImages.Handle, AImageIndex, AImageBitmap.Canvas.Handle,
//          cxNullPoint, AImages.DrawingStyle, AImages.ImageType)
//#DG can break destination        AImages.Draw(AImageBitmap.Canvas, 0, 0, AImageIndex)
        AIsAlphaUsed := TcxImageList.GetPixelFormat(AImages.Handle) >= 32;
      end
      else
      begin
        AImageBitmap.CopyBitmap(AGlyph);
        AIsAlphaUsed := cxGetBitmapPixelFormat(AGlyph) >= 32;
      end;
      AIsAlphaUsed := AIsAlphaUsed and AImageBitmap.IsAlphaUsed;
      if not AIsAlphaUsed then
        AImageBitmap.TransformBitmap(btmSetOpaque);
    end;

    procedure MakeMask(AImageBitmap, AMaskBitmap: TcxBitmap; AIsAlphaUsed: Boolean);
    var
      AImageListMask: TcxBitmap;
    begin
      AMaskBitmap.CopyBitmap(AImageBitmap);
      if not AIsAlphaUsed then
      begin
        if not IsGlyphAssigned(AGlyph) then
        begin
          AImageListMask := TcxBitmap.CreateSize(AMaskBitmap.ClientRect);
          try
            TcxImageList.GetImageInfo(AImages.Handle, AImageIndex, nil, AImageListMask);
            AImageListMask.TransformBitmap(btmCorrectBlend);
            AMaskBitmap.Filter(AImageListMask);
          finally
            AImageListMask.Free;
          end;
        end;
        if ATransparentColor <> clNone then
          AMaskBitmap.TransparentPixels.Add(ATransparentColor);
        if AUseLeftBottomPixelAsTransparent and IsGlyphAssigned(AGlyph) then
          AMaskBitmap.TransparentPixels.Add(AMaskBitmap.TransparentColor);
      end;
      AMaskBitmap.TransformBitmap(btmMakeMask);
    end;

  const
    AImageShadowSize = 2;
  var
    BW, BH: Integer;
    AImageBitmap, AMaskBitmap: TcxBitmap;
    AConstantAlpha: Byte;
    AIsAlphaUsed: Boolean;
  begin
    OffsetRect(AGlyphRect, -ABackgroundRect.Left, -ABackgroundRect.Top);
    if not Assigned(CustomDrawImageProc) or not CustomDrawImageProc(ABitmap.Canvas, AImages, AImageIndex, AGlyph, AGlyphRect, ADrawMode) then
    begin
      if not IsGlyphAssigned(AGlyph) then
      begin
        BW := AImages.Width;
        BH := AImages.Height;
      end
      else
      begin
        BW := AGlyph.Width;
        BH := AGlyph.Height;
      end;

      AImageBitmap := GetImageBitmap(BW, BH);
      MakeImage(AImageBitmap, AIsAlphaUsed);

      AMaskBitmap := GetMaskBitmap(BW, BH);
      MakeMask(AImageBitmap, AMaskBitmap, AIsAlphaUsed);
      AImageBitmap.Filter(AMaskBitmap);
      AConstantAlpha := $FF;
      case ADrawMode of
        idmFaded:
          begin
            AImageBitmap.TransformBitmap(btmFade);
            AConstantAlpha := FadeMap.SrcConstantAlpha;
          end;
        idmGrayScale:
          AImageBitmap.TransformBitmap(btmGrayScale);
        idmDingy:
          AImageBitmap.TransformBitmap(btmDingy);
        idmShadowed:
          begin
            AImageBitmap.DrawShadow(AMaskBitmap, AImageShadowSize, clBtnShadow, True);
            AGlyphRect := cxRectInflate(AGlyphRect, 0, 0, AImageShadowSize, AImageShadowSize);
            OffsetRect(AGlyphRect, -AImageShadowSize div 2, -AImageShadowSize div 2);
          end;
        idmDisabled:
          begin
            if AIsAlphaUsed then
            begin
              AImageBitmap.TransformBitmap(btmDisable);
              AConstantAlpha := DisableMap.SrcConstantAlpha;
            end
            else
            begin
              AImageBitmap.TransformBitmap(btmDirty);
              AImageBitmap.DrawShadow(AMaskBitmap, 1, clBtnHighlight);
            end;
          end;
      end;
      AImageBitmap.AlphaBlend(ABitmap, AGlyphRect, ASmoothImage, AConstantAlpha);
    end;
  end;

var
  ADrawBitmap: TcxBitmap;
begin
  if not (IsGlyphAssigned(AGlyph) or IsImageAssigned(AImages, AImageIndex)) then
    Exit;

  ADrawBitmap := GetDrawBitmap(cxRectWidth(ABackgroundRect), cxRectHeight(ABackgroundRect));
  DrawBackGround(ADrawBitmap);
  DrawImage(ADrawBitmap, ADrawMode);
  cxDrawBitmap(ADC, ADrawBitmap, ABackgroundRect, cxNullPoint);
end;

function GetImageListStyle(ADrawingStyle: TDrawingStyle; AImageType: TImageType): DWORD;
const
  ADrawingStyles: array[TDrawingStyle] of DWORD = (ILD_FOCUS, ILD_SELECTED, ILD_NORMAL, ILD_TRANSPARENT);
  AImageTypes: array[TImageType] of DWORD = (0, ILD_MASK);
begin
  Result := ADrawingStyles[ADrawingStyle] or AImageTypes[AImageType];
end;

procedure cxDrawImageList(AImageListHandle: HIMAGELIST; AImageIndex: Integer;
  ADC: HDC; APoint: TPoint; ADrawingStyle: TDrawingStyle; AImageType: TImageType);
begin
  ImageList_Draw(AImageListHandle, AImageIndex, ADC, APoint.X, APoint.Y, GetImageListStyle(ADrawingStyle, AImageType));
end;

procedure cxDrawHatch(ADC: HDC; const ARect: TRect; AColor1, AColor2: TColor; AStep: Byte; AAlpha1: Byte = $FF; AAlpha2: Byte = $FF);
var
  ADrawBitmap: TcxBitmap;
begin
  ADrawBitmap := TcxBitmap.CreateSize(ARect);
  try
    cxBitBlt(ADrawBitmap.Canvas.Handle, ADC, ADrawBitmap.ClientRect, ARect.TopLeft, SRCCOPY);
    ADrawBitmap.DrawHatch(AColor1, AColor2, AStep, AAlpha1, AAlpha2);
    cxBitBlt(ADC, ADrawBitmap.Canvas.Handle, ARect, cxNullPoint, SRCCOPY);
  finally
    ADrawBitmap.Free;
  end;
end;

function Lanczos3Filter(Value: Single): Single;

  function SinC(Value: Single): Single;
  begin
    if (Value <> 0.0) then
    begin
      Value  := Value * PI;
      Result := Sin(Value) / Value
    end
    else Result := 1.0;
  end;

begin
  if (Value < 0.0) then Value := -Value;
  if (Value < 3.0) then
    Result := SinC(Value) * SinC(Value / 3.0)
  else
    Result := 0.0;
end;

procedure BuildFilter(out AContributorList: TContributorList; AScale: Single; ASrcSize, ADestSize: Integer);
var
  I, J, APixel, AMaxContributors, AWeight: Integer;
  ACenter, ARadius, AScaleFactor: Single;
begin
  SetLength(AContributorList, ADestSize);
  if AScale < 1.0 then AScaleFactor := 1.0 / AScale else AScaleFactor := 1.0;
  ARadius := 3 * AScaleFactor;
  AMaxContributors := Trunc(ARadius * 2.0 + 1);
  for I := 0 to ADestSize - 1 do
    with AContributorList[I] do
    begin
      SetLength(Contributors, AMaxContributors);
      Count := 0;
      ACenter := I / AScale;
      for J := Floor(ACenter - ARadius) to Ceil(ACenter + ARadius) do
      begin
        AWeight := Round(Lanczos3Filter((ACenter - J) / AScaleFactor) / AScaleFactor * 256);
        if AWeight = 0 then continue;
        if J < 0 then
          APixel := -J
        else
          if (J >= ASrcSize) then
            APixel := ASrcSize - J + ASrcSize - 1
          else
            APixel := J;
        Contributors[Count].Pixel := APixel;
        Contributors[Count].Weight := AWeight;
        Inc(Count);
      end;
    end;
end;

procedure ApplyFilter(var AContributorList: TContributorList;
  var ASource: TRGBColors; ASrcSize, ASrcLineLength: Integer;
  var ADest: TRGBColors; ADestSize, ADestLineLength: Integer;
  AHorizontal: Boolean);

  function GetColorPart(Value: Integer): Integer;
  begin
    if Value < 0 then
      Result := 0
    else
    begin
      Value := Value shr 8;
      Result := Min(255, Value);
    end;
  end;

var
  AWeight: Integer;
  AColor: TRGBQuad;
  R, G, B, A: Integer;
  K, I, J: Integer;
begin
  for I := 0 to ASrcSize - 1 do
    for J := 0 to ADestSize - 1 do
      with AContributorList[J] do
      begin
        R := 0; G := 0; B := 0; A := 0;
        for K := 0 to Count - 1 do
        begin
          if AHorizontal then
            AColor := ASource[Contributors[K].Pixel + (I * ASrcLineLength)]
          else
            AColor := ASource[I + (Contributors[K].Pixel * ASrcLineLength)];
          AWeight := Contributors[K].Weight;
          if AWeight = 0 then continue;
          Inc(R, AColor.rgbRed * AWeight);
          Inc(G, AColor.rgbGreen * AWeight);
          Inc(B, AColor.rgbBlue * AWeight);
          Inc(A, AColor.rgbReserved * AWeight);
        end;
        AColor.rgbRed := GetColorPart(R);
        AColor.rgbGreen := GetColorPart(G);
        AColor.rgbBlue := GetColorPart(B);
        AColor.rgbReserved := GetColorPart(A);
        if AHorizontal then
          ADest[J + (I * ADestLineLength)] := AColor
        else
          ADest[I + (J * ADestLineLength)] := AColor;
      end;
  //dispose contributors and source buffer
  for I := 0 to HIGH(AContributorList) do
    AContributorList[I].Contributors := nil;
  AContributorList := nil;
  ASource := nil;
end;

procedure cxSmoothResizeBitmap(ASource, ADestination: TBitmap; AForceUseLanczos3Filter: Boolean = False);
var
  AContributorList: TContributorList;
  ASrcWidth, ASrcHeight, ADestWidth, ADestHeight: Integer;
  ABuffer1, ABuffer2: TRGBColors;
  AOldMode: Cardinal;
  AScale: Single;
begin
  ADestWidth := ADestination.Width;
  ADestHeight := ADestination.Height;
  ASrcWidth := ASource.Width;
  ASrcHeight := ASource.Height;
  if (ADestWidth = 0) or (ADestHeight = 0) or (ASrcWidth = 0) or (ASrcHeight = 0) then Exit;
  ASource.Canvas.Lock;
  ADestination.Canvas.Lock;
  try
    if IsWinNT and not AForceUseLanczos3Filter then
    begin
      AOldMode := SetStretchBltMode(ADestination.Canvas.Handle, HALFTONE);
      StretchBlt(ADestination.Canvas.Handle, 0, 0, ADestWidth, ADestHeight,
        ASource.Canvas.Handle, 0, 0, ASrcWidth, ASrcHeight, srcCopy);
      SetStretchBltMode(ADestination.Canvas.Handle, AOldMode);
    end
    else
    begin
      ABuffer1 := GetBitmapBits(ASource, False);
      SetLength(ABuffer2, ADestWidth * ASrcHeight);
      if ASrcWidth = 1 then
        AScale :=  ADestWidth / ASrcWidth
      else
        AScale :=  (ADestWidth - 1) / (ASrcWidth - 1);
      BuildFilter(AContributorList, AScale, ASrcWidth, ADestWidth);
      ApplyFilter(AContributorList, ABuffer1, ASrcHeight, ASrcWidth, ABuffer2, ADestWidth, ADestWidth, True);
      ABuffer1 := GetBitmapBits(ADestination, False);
      if (ASrcHeight = 1) or (ADestHeight = 1) then
        AScale :=  ADestHeight / ASrcHeight
      else
        AScale :=  (ADestHeight - 1) / (ASrcHeight - 1);
      BuildFilter(AContributorList, AScale, ASrcHeight, ADestHeight);
      ApplyFilter(AContributorList, ABuffer2, ADestWidth, ADestWidth, ABuffer1, ADestHeight, ADestWidth, False);
      SetBitmapBits(ADestination, ABuffer1, False);
    end;
  finally
    ASource.Canvas.Unlock;
    ADestination.Canvas.Unlock;
  end;
end;

function cxCreateBitmapCopy(ASourceBitmap: TBitmap): TcxBitmap;
begin
  Result := TcxBitmap.CreateSize(ASourceBitmap.Width, ASourceBitmap.Height);
  Result.CopyBitmap(ASourceBitmap);
end;

procedure cxMakeTrueColorBitmap(ASourceBitmap, ATrueColorBitmap: TBitmap);
var
  AcxBitmap, AcxMask: TcxBitmap;
begin
  AcxBitmap := cxCreateBitmapCopy(ASourceBitmap);
  try
    AcxBitmap.TransformBitmap(btmSetOpaque);
    AcxMask := cxCreateBitmapCopy(ASourceBitmap);
    try
      AcxMask.TransparentPixels.Add(ASourceBitmap.TransparentColor);
      AcxMask.TransformBitmap(btmMakeMask);
      AcxBitmap.Filter(AcxMask);
      ATrueColorBitmap.Assign(AcxBitmap);
    finally
      AcxMask.Free;
    end;
  finally
    AcxBitmap.Free;
  end;
end;

procedure cxMakeMaskBitmap(ASourceBitmap, AMaskBitmap: TBitmap);
var
  ABitmap: TcxBitmap;
begin
  ABitmap := cxCreateBitmapCopy(ASourceBitmap);
  try
    if not ABitmap.IsAlphaUsed then
      ABitmap.RecoverAlphaChannel(ASourceBitmap.TransparentColor);
    ABitmap.TransformBitmap(btmMakeMask);
    cxBitBlt(AMaskBitmap.Canvas.Handle, ABitmap.Canvas.Handle, ABitmap.ClientRect, cxNullPoint, SRCCOPY);
  finally
    ABitmap.Free;
  end;
end;

{!!! TODO: adapt to .net}

function cxGetCursorSize: TSize;
var
  IconInfo: TIconInfo;
  BitmapInfoSize, BitmapBitsSize, ImageSize: DWORD;
  Bitmap: PBitmapInfoHeader;
  Bits: Pointer;
  BytesPerScanline: Integer;

  function FindScanline(Source: Pointer; MaxLen: Cardinal;
    Value: Cardinal): Cardinal; assembler;
  asm
    PUSH    ECX
    MOV     ECX,EDX
    MOV     EDX,EDI
    MOV     EDI,EAX
    POP     EAX
    REPE    SCASB
    MOV     EAX,ECX
    MOV     EDI,EDX
  end;

begin
  { Default value is entire icon height }
  Result.cy := GetSystemMetrics(SM_CYCURSOR);
  Result.cx := GetSystemMetrics(SM_CXCURSOR);

  if GetIconInfo(GetCursor, IconInfo) then
  try
    GetDIBSizes(IconInfo.hbmMask, BitmapInfoSize, BitmapBitsSize);
    Bitmap := AllocMem(DWORD(BitmapInfoSize) + BitmapBitsSize);
    try
    Bits := Pointer(DWORD(Bitmap) + BitmapInfoSize);
    if GetDIB(IconInfo.hbmMask, 0, Bitmap^, Bits^) and
      (Bitmap^.biBitCount = 1) then
    begin
      { Point Bits to the end of this bottom-up bitmap }
      with Bitmap^ do
      begin
        Result.cx := biWidth;
        BytesPerScanline := ((biWidth * biBitCount + 31) and not 31) div 8;
        ImageSize := biWidth * BytesPerScanline;
        Bits := Pointer(DWORD(Bits) + BitmapBitsSize - ImageSize);
        { Use the width to determine the height since another mask bitmap
          may immediately follow }
        Result.cy := FindScanline(Bits, ImageSize, $FF);
        { In case the and mask is blank, look for an empty scanline in the
          xor mask. }
        if (Result.cy = 0) and (biHeight >= 2 * biWidth) then
          Result.cy := FindScanline(Pointer(DWORD(Bits) - ImageSize),
          ImageSize, $00);
        Result.cy := Result.cy div BytesPerScanline;
      end;
      Dec(Result.cy, IconInfo.yHotSpot);
    end;
    finally
      FreeMem(Bitmap);
    end;
  finally
    if IconInfo.hbmColor <> 0 then DeleteObject(IconInfo.hbmColor);
    if IconInfo.hbmMask <> 0 then DeleteObject(IconInfo.hbmMask);
  end;
end;

procedure cxAlphaBlend(ASource: TBitmap; ARect: TRect;
  const ASelColor: TColor; Alpha: Byte = 170);
var
  ARow, ACol: Integer;
  SrcLine: Pointer;
  C1, C2: Double;
  AColorValues: array[0..3] of Byte;
  P: TPoint;
begin
  C1 := Alpha / 255;
  C2 := 1.0 - C1;
  AColorValues[0] := Round(GetBValue(ASelColor) * C1);
  AColorValues[1] := Round(GetGValue(ASelColor) * C1);
  AColorValues[2] := Round(GetRValue(ASelColor) * C1);
  AColorValues[3] := 0;
  GetWindowOrgEx(ASource.Canvas.Handle, P);
  OffsetRect(ARect, -P.X, -P.Y);
  for ARow := Max(ARect.Top, 0) to Min(ARect.Bottom, ASource.Height - 1) do
  begin
    SrcLine := ASource.ScanLine[ARow];
    ACol := Max(0, ARect.Left * 4);
    while ACol < Min(ARect.Right * 4, ASource.Width * 4 - 1) do
    begin
      WriteByte(SrcLine, AColorValues[ACol mod 4] + Round(ReadByte(SrcLine, ACol) * C2), ACol);
      Inc(ACol);
    end;
  end;
end;

procedure cxAlphaBlend(
  ADest, ABkSource, ASource: TBitmap; Alpha: Byte = cxDefaultAlphaValue);

  function SystemAlphaPaint: Boolean;
  var
    ABlendFunction: TBlendFunction;
  begin
    if not Assigned(VCLAlphaBlend) then
    begin
      Result := False;
      Exit;
    end;
    ABlendFunction := DefaultBlendFunction;
    ABlendFunction.SourceConstantAlpha := Alpha;
    with ADest do
    begin
      Canvas.Draw(0, 0, ABkSource); //      Assign(ABkSource); todo: graphics bug image not copying but _AddRef called
      Result := VCLAlphaBlend(Canvas.Handle,
        0, 0, Width, Height, ASource.Canvas.Handle, 0, 0, Width, Height, ABlendFunction);
    end;
  end;

  procedure AlphaPaint;
  var
    ACount, K: Integer;
    DstLine, BkSrcLine, SrcLine: Pointer;
    C1, C2: Double;
  begin
    C1 := Alpha / 255;
    C2 := 1.0 - C1;
    with ASource do
    begin
      K := Height;
      ACount := ((Width * 24 + 31) and not 31) shr 3 * K;
    end;
    BkSrcLine := ABkSource.ScanLine[K - 1];
    SrcLine := ASource.ScanLine[K - 1];
    DstLine := ADest.ScanLine[K - 1];
    for K := 0 to ACount - 1 do
      WriteByte(DstLine,
        Round(ReadByte(SrcLine, K) * C1) + Round(ReadByte(BkSrcLine, K) * C2), K);
  end;

  procedure DoAlphaPaint;
  begin
    if GetDeviceCaps(cxScreenCanvas.Handle, BITSPIXEL) in [16, 24, 32] then
      AlphaPaint
    else
      ADest.Canvas.Draw(0, 0, ASource); // .Assign(ASource);
  end;

begin
  if not SystemAlphaPaint then DoAlphaPaint;
end;

procedure cxApplyViewParams(ACanvas: TcxCanvas;
  const AViewParams: TcxViewParams);
begin
  with ACanvas do
  begin
    Font := AViewParams.Font;
    Font.Color := AViewParams.TextColor;
    Brush.Color := AViewParams.Color;
  end;
end;

procedure cxCopyImage(ASource, ADest: TBitmap;
  const ASrcOffset, ADstOffset: TPoint; const ARect: TRect);
var
  ADstRect, ASrcRect: TRect;
begin
  ADstRect := ARect;
  ASrcRect := ARect;
  OffsetRect(ASrcRect, ASrcOffset.X, ASrcOffset.Y);
  OffsetRect(ADstRect, ADstOffset.X, ADstOffset.Y);
  ADest.Canvas.CopyRect(ASrcRect, ASource.Canvas, ADstRect);
end;

procedure cxCopyImage(ASource, ADest: TCanvas;
  const ASrcOffset, ADstOffset: TPoint; const ARect: TRect);
var
  ADstRect, ASrcRect: TRect;
begin
  ADstRect := ARect;
  ASrcRect := ARect;
  OffsetRect(ASrcRect, ASrcOffset.X, ASrcOffset.Y);
  OffsetRect(ADstRect, ADstOffset.X, ADstOffset.Y);
  ADest.CopyRect(ADstRect, ASource, ASrcRect);
end;

procedure cxDrawArrows(ACanvas: TCanvas; const ARect: TRect;
  ASide: TcxBorder; AColor: TColor; APenColor: TColor = clDefault);
type
  TArrowPolygon = array[0..6] of TPoint;
var
  ArrowRgns: array[0..1, 0..6, 0..1] of Integer;
  BaseLine: array[0..1, 0..1] of Integer;
  I, J, K: Integer;
begin
  with ARect do
  begin
    BaseLine[0, 0] := Left;
    BaseLine[0, 1] := Top;
    BaseLine[1, 0] := Right;
    BaseLine[1, 1] := Bottom;
  end;
  if ASide in [bLeft, bBottom] then
  begin
    BaseLine[Byte(ASide = bLeft), 0] := ARect.Left;
    BaseLine[Byte(ASide = bLeft), 1] := ARect.Bottom;
  end
  else
  begin
    BaseLine[Byte(ASide = bTop), 0] := ARect.Right;
    BaseLine[Byte(ASide = bTop), 1] := ARect.Top;
  end;
  Move(BaseRgns[Byte(ASide in [bTop, bBottom]) shl 1], ArrowRgns, SizeOf(ArrowRgns));
  for I := 0 to 1 do
    for J := 0 to 6 do
      for K := 0 to 1 do
        Inc(ArrowRgns[I, J, K], BaseLine[I, K]);
  ACanvas.Brush.Color := AColor;
  if APenColor = clDefault then
    ACanvas.Pen.Color := $FFFFFF xor ColorToRgb(AColor)
  else
    ACanvas.Pen.Color := APenColor;
  for I := 0 to 1 do
    ACanvas.Polygon(TArrowPolygon(ArrowRgns[I]));
end;

procedure cxFillHalfToneRect(
  Canvas: TCanvas; const ARect: TRect; ABkColor, AColor: TColor);
begin
  with Canvas do
  begin
    ABkColor := SetBkColor(Handle, ColorToRgb(ABkColor));
    AColor := SetTextColor(Handle, ColorToRgb(AColor));
    Windows.FillRect(Handle, ARect, cxHalfToneBrush.Handle);
    SetBkColor(Handle, ABkColor);
    SetTextColor(Handle, AColor);
  end;
end;

procedure cxSetCanvasOrg(ACanvas: TCanvas; var AOrg: TRect);
begin
  with AOrg do
    SetWindowOrgEx(ACanvas.Handle, Left, Top, @TopLeft);
end;

function cxGetTextExtentPoint32(ADC: THandle; const AText: string; out ASize: TSize; ACharCount: Integer = -1): Boolean;
begin
  if ACharCount = -1 then
    ACharCount := Length(AText);
  Result := GetTextExtentPoint32(ADC, PChar(AText), ACharCount, ASize);
end;

{TODO:
procedure cxGetTextLines(const AText: string; ACanvas: TcxCanvas;
  const ARect: TRect; ALines: TStrings);
var
  ATextRows: TcxTextRows;
  ATextParams: TcxTextParams;
  I, ACount, ALen: Integer;
  S: WideString;
begin
  ATextParams := cxCalcTextParams(ACanvas.Handle, CXTO_WORDBREAK or CXTO_CALCROWCOUNT);
  cxMakeTextRows(ACanvas.Handle, PChar(AText), Length(AText), ARect, ATextParams, ATextRows, ACount);
  for I := 0 to ACount - 1 do
  begin
    ALen := cxGetTextRow(ATextRows, I).TextLength;
    SetString(S, cxGetTextRow(ATextRows, I).Text, ALen);
    if (ALen > 0) and ((S[ALen] = ' ') or (S[ALen] = #9)) then
      SetLength(S, ALen - 1);
    ALines.Add(dxWideStringToString(S));
  end;
  cxResetTextRows(ATextRows);
end;
}

type
  TcxPosition = record
    Start: Integer;
    Finish: Integer;
  end;

procedure cxGetTextLines(const AText: string; ACanvas: TcxCanvas; const ARect: TRect; ALines: TStrings);
var
  AWideText: WideString;

  procedure GetNextWordPos(const AWideText: string; ALength: Integer; const ACurrentWord: TcxPosition; var ANextWord: TcxPosition);

    function IsDelimiter(AIndex: Integer): Boolean;
    begin
      Result := (AWideText[AIndex] = ' ') or (AWideText[AIndex] = #9) or
        (AWideText[AIndex] = #13) or (AWideText[AIndex] = #10)
    end;

    function IsDoubleDelimiter(AIndex: Integer): Boolean;
    begin
      Result := (AIndex > 1) and IsDelimiter(AIndex) and IsDelimiter(AIndex - 1);
    end;

    function IsWordStart(AIndex: Integer): Boolean;
    begin
      Result := not IsDelimiter(AIndex);
    end;

    function IsWordEnd(AIndex: Integer): Boolean;
    begin
      Result := IsDelimiter(AIndex);
    end;

  var
    ACharPos: Integer;
  begin
    ANextWord.Start := ACurrentWord.Finish + 1;

    while (ANextWord.Start < ALength) and not IsWordStart(ANextWord.Start) and not IsDoubleDelimiter(ANextWord.Start) do
      Inc(ANextWord.Start);
    ACharPos := ANextWord.Start;
    while (ACharPos + 1 <= ALength) and not IsWordEnd(ACharPos + 1) and not IsDoubleDelimiter(ACharPos) do
      Inc(ACharPos);
    ANextWord.Finish := ACharPos;
  end;

var
  ADrawText: string;
  ACurrentWord, ANextWord: TcxPosition;
  ALineStart, ALength, ARectWidth: Integer;
begin
  ARectWidth := cxRectWidth(ARect);
  ACurrentWord.Finish := 0;
  ALineStart := 1;
  AWideText := dxStringToWideString(AText);
  ALength := Length(AWideText);
  repeat
    GetNextWordPos(AWideText, ALength, ACurrentWord, ANextWord);

    ADrawText := Copy(AWideText, ALineStart, ANextWord.Finish - ALineStart + 1);
    if cxTextSize(ACanvas.Handle, ADrawText).cx > ARectWidth then
    begin
      ALines.Add(dxWideStringToString(Copy(AWideText, ALineStart, ACurrentWord.Finish - ALineStart + 1)));
      ALineStart := ANextWord.Start;
    end;
    ACurrentWord := ANextWord;
  until ACurrentWord.Finish >= ALength;
  ALines.Add(dxWideStringToString(Copy(AWideText, ALineStart, ALength)));
end;

function cxDrawText(ADC: THandle; const AText: string; var ARect: TRect; AFormat: UINT; ACharCount: Integer = - 1): Integer;
begin
  Result := Windows.DrawText(ADC, PChar(AText), ACharCount, ARect, AFormat);
end;

function cxExtTextOut(ADC: THandle; const AText: string; const APoint: TPoint;
  const ARect: TRect; AOptions: UINT; ACharCount: Integer = -1): Boolean;
begin
 if ACharCount = -1 then
   ACharCount := Length(AText);
  Result := ExtTextOut(ADC, APoint.X, APoint.Y, AOptions,
    @ARect, PChar(AText), ACharCount, nil);
end;

function cxExtTextOut(ADC: THandle; const AText: string; const APoint: TPoint;
  AOptions: UINT; ACharCount: Integer = -1): Boolean; overload;
begin
 if ACharCount = -1 then
   ACharCount := Length(AText);
  Result := ExtTextOut(ADC, APoint.X, APoint.Y, AOptions,
    nil, PChar(AText), ACharCount, nil);
end;

procedure cxInvalidateRect(AHandle: THandle; const ARect: TRect; AEraseBackground: Boolean = True);
begin
  InvalidateRect(AHandle, @ARect, AEraseBackground);
end;

procedure cxInvalidateRect(AHandle: THandle; AEraseBackground: Boolean = True);
begin
  InvalidateRect(AHandle, nil, AEraseBackground);  
end;

function cxTextHeight(AFont: TFont; const S: string = 'Wg'; AFontSize: Integer = 0): Integer;
begin
  Result := cxTextExtent(AFont, S, AFontSize).cy;
end;

function cxTextWidth(AFont: TFont; const S: string; AFontSize: Integer = 0): Integer;
begin
  Result := cxTextExtent(AFont, S, AFontSize).cx;
end;

function cxTextExtent(AFont: TFont; const S: string; AFontSize: Integer = 0): TSize;
begin
  with cxScreenCanvas do
  begin
    Font.Assign(AFont);
    if AFontSize <> 0 then Font.Size := AFontSize;
    Result := TextExtent(S);
  end;
end;

function cxTextSize(ADC: THandle; const AText: string): TSize; // differs from cxTextExtent
var
  ARect: TRect;
begin
  ARect := cxGetTextRect(ADC, AText, 1);
  Result := Size(ARect.Right, ARect.Bottom);
end;

function cxGetTextRect(ADC: THandle; const AText: string; ARowCount: Integer; AReturnMaxRectHeight: Boolean = False): TRect;

const
  DT_NOFULLWIDTHCHARBREAK = $80000;
  ASingleLineTextFlag = DT_SINGLELINE or DT_CALCRECT;
  AMultiLineTextFlag = DT_WORDBREAK or DT_NOFULLWIDTHCHARBREAK or DT_CALCRECT;

  function GetMaxWidth: Integer;
  var
    R: TRect;
  begin
    R := cxEmptyRect;
    cxDrawText(ADC, AText, R, ASingleLineTextFlag);
    Result := R.Right;
  end;

  function GetMinWidth: Integer;
  var
    R: TRect;
  begin
    R := Rect(0, 0, 1, 1);
    cxDrawText(ADC, AText, R, AMultiLineTextFlag);
    Result := R.Right;
  end;

  function GetTextSize(AWidth: Integer): TRect;
  begin
    Result := Rect(0, 0, AWidth, 1);
    cxDrawText(ADC, AText, Result, AMultiLineTextFlag);
  end;

var
  AMaxTextHeight, AMaxWidth, AMinWidth, AWidth: Integer;
begin
  Result := cxEmptyRect;
  if ARowCount <= 0 then
    Exit;
  if ARowCount = 1 then
    cxDrawText(ADC, AText, Result, ASingleLineTextFlag)
  else
  begin
    AMaxTextHeight := cxTextSize(ADC, 'Wg').cy * ARowCount;
    AMinWidth := GetMinWidth;
    AMaxWidth := GetMaxWidth;
    AWidth := (AMinWidth + AMaxWidth) div 2;
    while AMaxWidth - AMinWidth > 1 do
    begin
      if GetTextSize(AWidth).Bottom > AMaxTextHeight then
        AMinWidth := AWidth
      else
        AMaxWidth := AWidth;
      AWidth := (AMinWidth + AMaxWidth) div 2;
    end;
    Result := GetTextSize(AMinWidth);
    if Result.Bottom > AMaxTextHeight then
      Result := GetTextSize(AMaxWidth);
    if AReturnMaxRectHeight then
      Result.Bottom := AMaxTextHeight;
  end;
end;

function cxGetTextRect(AFont: TFont; const AText: string; ARowCount: Integer): TRect;
begin
  cxScreenCanvas.Font := AFont;
  Result := cxGetTextRect(cxScreenCanvas.Handle, AText, ARowCount);
end;

function cxGetScreenPixelsPerInch(AHorizontal: Boolean): Integer;
const
  ADirectionMap: array [Boolean] of DWORD = (LOGPIXELSY, LOGPIXELSX);
begin
  Result := GetDeviceCaps(cxScreenCanvas.Handle, ADirectionMap[AHorizontal]);
end;

function cxGetStringAdjustedToWidth(ADC: HDC; AFontHandle: HFONT; const S: string; AWidth: Integer): string; overload;
var
  ACalcDC: HDC;
  ASize: TSize;
  ACharNumber: Integer;
begin
  if (Length(S) = 0) or (AWidth < 1) then
  begin
    Result := '';
    Exit;
  end;
  if ADC = 0 then ACalcDC := GetDC(0) else ACalcDC := ADC;
  if AFontHandle <> 0 then
    SelectObject(ACalcDC, AFontHandle);
  GetTextExtentPoint32(ACalcDC, PChar(S), Length(S), ASize);
  if ASize.cx > AWidth then
  begin
    ACharNumber := 0;
    GetTextExtentPoint32(ACalcDC, '...', 3, ASize);
    Dec(AWidth, ASize.cx);
    if AWidth > 0 then
      GetTextExtentExPoint(ACalcDC, PChar(S), Length(S), AWidth, @ACharNumber, nil, ASize);
    if ACharNumber < 1 then ACharNumber := 1;
    Result := Copy(S, 1, ACharNumber) + '...';
  end
  else
    Result := S;
  if ADC = 0 then ReleaseDC(0, ACalcDC);
end;

function cxGetStringAdjustedToWidth(AFont: TFont; const S: string; AWidth: Integer): string; overload;
begin
  Result := cxGetStringAdjustedToWidth(0, AFont.Handle, S, AWidth);
end;

function cxGetBitmapData(ABitmapHandle: HBITMAP; out ABitmapData: Windows.TBitmap): Boolean;
begin
  Result := GetObject(ABitmapHandle, SizeOf(Windows.TBitmap), @ABitmapData) <> 0;
end;

function cxGetBrushData(ABrushHandle: HBRUSH; out ALogBrush: TLogBrush): Boolean;
begin
  Result := GetObject(ABrushHandle, SizeOf(TLogBrush), @ALogBrush) <> 0;
end;

function cxGetBrushData(ABrushHandle: HBRUSH): TLogBrush;
begin
  cxGetBrushData(ABrushHandle, Result);
end;

function cxGetFontData(AFontHandle: HFONT; out ALogFont: TLogFont): Boolean;
begin
  Result := GetObject(AFontHandle, SizeOf(TLogFont), @ALogFont) <> 0;
end;

function cxGetPenData(APenHandle: HPEN; out ALogPen: TLogPen): Boolean;
begin
  Result := GetObject(APenHandle, SizeOf(TLogPen), @ALogPen) <> 0;
end;

function cxGetWritingDirection(AFontCharset: TFontCharset; const AText: string): TCanvasOrientation;

  function IsStandardASCIIChar: Boolean;
  begin
    Result := (Length(AText) > 0) and (cxStrCharLength(AText) = 1) and (Integer(AText[1]) < 128);
  end;

begin
  if AFontCharset = DEFAULT_CHARSET then
    AFontCharset := GetDefFontCharset;
  if not IsStandardASCIIChar and (AFontCharset in [ARABIC_CHARSET, CHINESEBIG5_CHARSET, GB2312_CHARSET]) then
    Result := coRightToLeft
  else
    Result := coLeftToRight;
end;

procedure cxDrawThemeParentBackground(AControl: TWinControl; ACanvas: TcxCanvas; const ARect: TRect);
begin
  if AControl.Parent.DoubleBuffered or not IsThemeLibraryLoaded then
    cxDrawTransparentControlBackground(AControl, ACanvas, ARect, False)
  else
    DrawThemeParentBackground(AControl.Handle, ACanvas.Handle, ARect);
end;

procedure cxDrawThemeParentBackground(AControl: TWinControl; ACanvas: TCanvas; const ARect: TRect);
var
  AcxCanvas: TcxCanvas;
begin
  AcxCanvas := TcxCanvas.Create(ACanvas);
  try
    cxDrawThemeParentBackground(AControl, AcxCanvas, ARect);
  finally
    AcxCanvas.Free;
  end;
end;

procedure cxDrawTransparentControlBackground(AControl: TWinControl;
  ACanvas: TcxCanvas; ARect: TRect; APaintParentWithChildren: Boolean = True);

  procedure cxPaintControlTo(ADrawControl: TWinControl;
    AOffsetX, AOffsetY: Integer; ADrawRect: TRect);

    procedure DrawEdgesAndBorders;
    var
      AEdgeFlags, ABorderFlags: Integer;
      ABorderRect: TRect;
    begin
      ABorderFlags := 0;
      AEdgeFlags := 0;
      if GetWindowLong(ADrawControl.Handle, GWL_EXSTYLE) and WS_EX_CLIENTEDGE <> 0 then
      begin
        AEdgeFlags := EDGE_SUNKEN;
        ABorderFlags := BF_RECT or BF_ADJUST
      end
      else
        if GetWindowLong(ADrawControl.Handle, GWL_STYLE) and WS_BORDER <> 0 then
        begin
          AEdgeFlags := BDR_OUTER;
          ABorderFlags := BF_RECT or BF_ADJUST or BF_MONO;
        end;
      if ABorderFlags <> 0 then
      begin
        ABorderRect := Rect(0, 0, ADrawControl.Width, ADrawControl.Height);
        DrawEdge(ACanvas.Handle, ABorderRect, AEdgeFlags, ABorderFlags);
        ACanvas.SetClipRegion(TcxRegion.Create(ABorderRect), roIntersect);
        MoveWindowOrg(ACanvas.Handle, ABorderRect.Left, ABorderRect.Top);
      end;
    end;

  var
    I: Integer;
    AChildControl: TControl;
  begin
    ACanvas.SaveDC;
    try
      MoveWindowOrg(ACanvas.Handle, AOffsetX, AOffsetY);
      if not RectVisible(ACanvas.Handle, ADrawRect) then Exit;
      
      ADrawControl.ControlState := ADrawControl.ControlState + [csPaintCopy];
      try
        if ADrawControl <> AControl.Parent then
          DrawEdgesAndBorders;
        ACanvas.Canvas.Lock;
        try
          ADrawControl.Perform(WM_ERASEBKGND, ACanvas.Handle, ACanvas.Handle);
          ADrawControl.Perform(WM_PAINT, ACanvas.Handle, 0);
        finally
          ACanvas.Canvas.Unlock;
        end;
        if APaintParentWithChildren then
          for I := 0 to ADrawControl.ControlCount - 1 do
          begin
            AChildControl := ADrawControl.Controls[I];
            if AChildControl = AControl then
              Break;
            if (AChildControl is TWinControl) and TWinControl(AChildControl).Visible then
              cxPaintControlTo(TWinControl(AChildControl), AChildControl.Left, AChildControl.Top, Rect(0, 0, AChildControl.Width, AChildControl.Height));
          end;
      finally
        ADrawControl.ControlState := ADrawControl.ControlState - [csPaintCopy];
      end;
    finally
      ACanvas.RestoreDC;
    end;
  end;

begin
  if AControl.Parent <> nil then
  begin
    OffsetRect(ARect, AControl.Left, AControl.Top);
    cxPaintControlTo(AControl.Parent, -ARect.Left, -ARect.Top, ARect);
// wrong cxLabel painting    cxPaintControlTo(AControl.Parent, -AControl.Left, -AControl.Top, ARect);
  end;
end;

procedure cxDrawTransparentControlBackground(AControl: TWinControl;
  ACanvas: TCanvas; const ARect: TRect; APaintParentWithChildren: Boolean = True);
var
  AcxCanvas: TcxCanvas;
begin
  AcxCanvas := TcxCanvas.Create(ACanvas);
  try
    cxDrawTransparentControlBackground(AControl, AcxCanvas, ARect, APaintParentWithChildren);
  finally
    AcxCanvas.Free;
  end;
end;

procedure cxResetFont(const AFont: TFont);
begin
{$IFDEF CXTEST}
  AFont.Charset := DEFAULT_CHARSET;
  AFont.Name := 'Tahoma';
  AFont.Height := -11;
  AFont.Pitch := fpDefault;
  AFont.Style := [];
{$ELSE}
  AFont.Charset := DefFontData.Charset;
  AFont.Name := dxShortStringToString(DefFontData.Name);
  AFont.Height := DefFontData.Height;
  AFont.Pitch := DefFontData.Pitch;
  AFont.Style := DefFontData.Style;
{$ENDIF}
end;

{ TcxRegion }

constructor TcxRegion.Create(AHandle: TcxRegionHandle);
begin
  inherited Create;
  FHandle := AHandle;
end;

constructor TcxRegion.Create(const ABounds: TRect);
var
  AHandle: TcxRegionHandle;
begin
  AHandle := CreateRectRgnIndirect(ABounds);
  Create(AHandle);
end;

constructor TcxRegion.Create;
begin
  Create(0, 0, 0, 0);
end;

constructor TcxRegion.Create(ALeft, ATop, ARight, ABottom: Integer);
begin
  Create(Rect(ALeft, ATop, ARight, ABottom));
end;

constructor TcxRegion.CreateRoundCorners(const ABounds: TRect; AWidthEllepse, AHeightEllepse: Integer);
begin
  CreateRoundCorners(ABounds.Left, ABounds.Top, ABounds.Right, ABounds.Bottom, AWidthEllepse, AHeightEllepse);
end;

constructor TcxRegion.CreateRoundCorners(ALeft, ATop, ARight, ABottom, AWidthEllepse, AHeightEllepse: Integer);
var
  AHandle: TcxRegionHandle;
begin
  AHandle := CreateRoundRectRgn(ALeft + 1, ATop + 1, ARight, ABottom, AWidthEllepse, AHeightEllepse);
  Create(AHandle);
end;

destructor TcxRegion.Destroy;
begin
  DestroyHandle;
  inherited;
end;

function TcxRegion.GetBoundsRect: TRect;
begin
  if GetRgnBox(FHandle, Result) = NULLREGION then
    Result := cxNullRect;
end;

function TcxRegion.GetIsEmpty: Boolean;
var
  R: TRect;
begin
  Result := GetRgnBox(FHandle, R) = NULLREGION;
end;

procedure TcxRegion.DestroyHandle;
begin
  if FHandle <> 0 then
  begin
    DeleteObject(FHandle);
    FHandle := 0;
  end;
end;

procedure TcxRegion.Combine(ARegion: TcxRegion; AOperation: TcxRegionOperation;
  ADestroyRegion: Boolean = True);
const
  Modes: array[TcxRegionOperation] of Integer = (RGN_COPY, RGN_OR, RGN_DIFF, RGN_AND);
begin
  if AOperation = roSet then
    CombineRgn(FHandle, ARegion.Handle, 0, Modes[AOperation])
  else
    CombineRgn(FHandle, FHandle, ARegion.Handle, Modes[AOperation]);
  if ADestroyRegion then ARegion.Free;
end;

function TcxRegion.IsEqual(ARegion: TcxRegion): Boolean;
begin
  Result := (ARegion <> nil) and ((IsEmpty and ARegion.IsEmpty) or IsEqual(ARegion.Handle));
end;

function TcxRegion.IsEqual(ARegionHandle: TcxRegionHandle): Boolean;
begin
  Result := EqualRgn(Handle, ARegionHandle);
end;

procedure TcxRegion.Offset(DX, DY: Integer);
begin
  OffsetRgn(FHandle, DX, DY);
end;

function TcxRegion.PtInRegion(const Pt: TPoint): Boolean;
begin
  Result := Windows.PtInRegion(Handle, Pt.X, Pt.Y);
end;

function TcxRegion.PtInRegion(X, Y: Integer): Boolean;
begin
  Result := PtInRegion(Point(X, Y));
end;

function TcxRegion.RectInRegion(const R: TRect): Boolean;
begin
  Result := Windows.RectInRegion(Handle, R);
end;

function TcxRegion.RectInRegion(ALeft, ATop, ARight, ABottom: Integer): Boolean;
begin
  Result := RectInRegion(Rect(ALeft, ATop, ARight, ABottom));
end;

{ TcxCanvas }

constructor TcxCanvas.Create(ACanvas: TCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FSavedDCs := TList.Create;
  FSavedRegions := TList.Create;
end;

destructor TcxCanvas.Destroy;
begin
  FreeAndNil(FSavedRegions);
  FreeAndNil(FSavedDCs);
  inherited;
end;

function TcxCanvas.GetBrush: TBrush;
begin
  Result := Canvas.Brush;
end;

function TcxCanvas.GetCopyMode: TCopyMode;
begin
  Result := Canvas.CopyMode;
end;

function TcxCanvas.GetDCOrigin: TPoint;
var
  AWindowOrg, AViewportOrg: TPoint;
begin
  AWindowOrg := WindowOrg;
  AViewportOrg := ViewportOrg;
  Result := Point(AViewportOrg.X - AWindowOrg.X, AViewportOrg.Y - AWindowOrg.Y);
end;

function TcxCanvas.GetFont: TFont;
begin
  Result := Canvas.Font;
end;

function TcxCanvas.GetHandle: HDC;
begin
  Result := Canvas.Handle;
end;

function TcxCanvas.GetPen: TPen;
begin
  Result := Canvas.Pen;
end;

function TcxCanvas.GetViewportOrg: TPoint;
begin
  GetViewportOrgEx(Handle, Result);
end;

function TcxCanvas.GetWindowOrg: TPoint;
begin
  GetWindowOrgEx(Handle, Result);
end;

procedure TcxCanvas.SetBrush(Value: TBrush);
begin
  Canvas.Brush := Value;
end;

procedure TcxCanvas.SetCopyMode(Value: TCopyMode);
begin
  Canvas.CopyMode := Value;
end;

procedure TcxCanvas.SetFont(Value: TFont);
begin
  Canvas.Font := Value;
end;

procedure TcxCanvas.SetPen(Value: TPen);
begin
  Canvas.Pen := Value;
end;

procedure TcxCanvas.SetPixel(X, Y: Integer; Value: TColor);
begin
  Canvas.Pixels[X, Y] := Value;
end;

procedure TcxCanvas.SetViewportOrg(const P: TPoint);
begin
  SetViewportOrgEx(Handle, P.X, P.Y, nil);
end;

procedure TcxCanvas.SetWindowOrg(const P: TPoint);
begin
  SetWindowOrgEx(Handle, P.X, P.Y, nil);
end;

procedure TcxCanvas.SynchronizeObjects(ADC: THandle);

  procedure AssignFont;
  var
    ALogFont: TLogFont;
  begin
    cxGetFontData(GetCurrentObject(ADC, OBJ_FONT), ALogFont);
    Font.Handle := CreateFontIndirect(ALogFont);
    Font.Color := GetTextColor(ADC);
  end;

  procedure AssignBrush;

    function GetBrushStyle(const ALogBrush: TLogBrush): TBrushStyle;
    begin
      Result := bsSolid;
      case ALogBrush.lbStyle of  // TODO lbStyle = BS_PATTERN
        BS_HATCHED:
          case ALogBrush.lbHatch of
            HS_BDIAGONAL: Result := bsBDiagonal;
            HS_CROSS: Result := bsCross;
            HS_DIAGCROSS: Result := bsDiagCross;
            HS_FDIAGONAL: Result := bsFDiagonal;
            HS_HORIZONTAL: Result := bsHorizontal;
            HS_VERTICAL: Result := bsVertical;
          end;
        BS_HOLLOW:
          Result := bsClear;
      end;
    end;

  var
    ALogBrush: TLogBrush;
  begin
    cxGetBrushData(GetCurrentObject(ADC, OBJ_BRUSH), ALogBrush);
    Brush.Handle := CreateBrushIndirect(ALogBrush);
    Brush.Color := ALogBrush.lbColor;  // required: set Color before Style
    Brush.Style := GetBrushStyle(ALogBrush)
  end;

  procedure AssignPen;

    function GetPenStyle(const ALogPen: TLogPen): TPenStyle;
    begin
      Result := TPenStyle(ALogPen.lopnStyle);
    end;

    function GetPenMode: TPenMode;
    const
      PenModes: array[TPenMode] of Integer =
        (R2_BLACK, R2_WHITE, R2_NOP, R2_NOT, R2_COPYPEN, R2_NOTCOPYPEN, R2_MERGEPENNOT,
         R2_MASKPENNOT, R2_MERGENOTPEN, R2_MASKNOTPEN, R2_MERGEPEN, R2_NOTMERGEPEN,
         R2_MASKPEN, R2_NOTMASKPEN, R2_XORPEN, R2_NOTXORPEN);
    var
      I: TPenMode;
      ADrawMode: Integer;
    begin
      Result := pmCopy;
      ADrawMode := GetROP2(ADC);
      for I := Low(TPenMode) to High(TPenMode) do
        if PenModes[I] = ADrawMode then
          Result := I;
    end;

  var
    ALogPen: TLogPen;
  begin
    cxGetPenData(GetCurrentObject(ADC, OBJ_PEN), ALogPen);
    Pen.Handle := CreatePenIndirect(ALogPen);
    Pen.Color := ALogPen.lopnColor;
    Pen.Style := GetPenStyle(ALogPen);
    Pen.Mode := GetPenMode;
    Pen.Width := ALogPen.lopnWidth.X;
  end;

begin
  AssignFont;
  AssignBrush;
  AssignPen;
end;

procedure TcxCanvas.AlignMultiLineTextRectVertically(var R: TRect;
  const AText: string; AAlignmentVert: TcxAlignmentVert;
  AWordBreak, AShowPrefix: Boolean; AEnabled: Boolean = True;
  ADontBreakChars: Boolean = False);
var
  ASizeR: TRect;
  AFlags: Integer;
begin
  if AAlignmentVert = vaTop then Exit;
  ASizeR := Rect(0, 0, R.Right - R.Left - Ord(not AEnabled), 0);
  AFlags := cxAlignLeft or cxAlignTop;
  if AWordBreak then
    AFlags := AFlags or cxWordBreak;
  if AShowPrefix then
    AFlags := AFlags or cxShowPrefix;
  if ADontBreakChars then
    AFlags := AFlags or cxDontBreakChars;
  TextExtent(AText, ASizeR, AFlags);
  case AAlignmentVert of
    vaCenter:
      R.Top := (R.Top + R.Bottom - (ASizeR.Bottom - ASizeR.Top)) div 2;
    vaBottom:
      R.Top := R.Bottom - (ASizeR.Bottom - ASizeR.Top + Ord(not AEnabled));
  end;
end;

procedure TcxCanvas.CopyRect(const Dest: TRect; ACanvas: TCanvas;
  const Source: TRect);
begin
  Canvas.CopyRect(Dest, ACanvas, Source);
end;

procedure TcxCanvas.Draw(X, Y: Integer; Graphic: TGraphic);
begin
  Canvas.Draw(X, Y, Graphic);
end;

procedure TcxCanvas.DrawComplexFrame(const R: TRect;
  ALeftTopColor, ARightBottomColor: TColor; ABorders: TcxBorders;
  ABorderWidth: Integer);
var
  ABorder: TcxBorder;

  function GetBorderColor: TColor;
  begin
    if ABorder in [bLeft, bTop] then
      Result := ALeftTopColor
    else
      Result := ARightBottomColor;
  end;

  function GetBorderBounds: TRect;
  begin
    Result := R;
    with Result do
      case ABorder of
        bLeft:
          Right := Left + ABorderWidth;
        bTop:
          Bottom := Top + ABorderWidth;
        bRight:
          Left := Right - ABorderWidth;
        bBottom:
          Top := Bottom - ABorderWidth;
      end;
  end;

begin
  for ABorder := Low(ABorder) to High(ABorder) do
    if ABorder in ABorders then
    begin
      SetBrushColor(GetBorderColor);
      FillRect(GetBorderBounds);
    end;
end;

procedure TcxCanvas.DrawEdge(const R: TRect; ASunken, AOuter: Boolean;
  ABorders: TcxBorders);
begin
  if ASunken then
    if AOuter then
      DrawComplexFrame(R, clBtnShadow, clBtnHighlight, ABorders)
    else
      DrawComplexFrame(R, cl3DDkShadow{clBtnText}, cl3DLight{clBtnFace}, ABorders)
  else
    if AOuter then
      DrawComplexFrame(R, cl3DLight{clBtnFace}, cl3DDkShadow{clBtnText}, ABorders)
    else
      DrawComplexFrame(R, clBtnHighlight, clBtnShadow, ABorders);
end;

procedure TcxCanvas.DrawFocusRect(const R: TRect);
begin
  SetBrushColor(clWhite);
  Canvas.Font.Color := clBlack;
  TCanvasAccess(Canvas).RequiredState([csFontValid]);
  Canvas.DrawFocusRect(R);
end;

procedure TcxCanvas.DrawGlyph(X, Y: Integer; AGlyph: TBitmap; AEnabled: Boolean = True;
  ABackgroundColor: TColor = clNone{; ATempCanvas: TCanvas = nil});
var
  APrevBrushStyle: TBrushStyle;
  AImageList: TImageList;
  ABitmap: TBitmap;
begin
  if AEnabled {and (ATempCanvas = nil)} then
  begin
    APrevBrushStyle := Brush.Style;
    if ABackgroundColor = clNone then
      Brush.Style := bsClear
    else
      Brush.Color := ABackgroundColor;
    Canvas.BrushCopy(Bounds(X, Y, AGlyph.Width, AGlyph.Height), AGlyph,
      Rect(0, 0, AGlyph.Width, AGlyph.Height), AGlyph.TransparentColor);
    Brush.Style := APrevBrushStyle;
    Exit;
  end;

  AImageList := nil;
  ABitmap := nil;
  try
    AImageList := TImageList.Create(nil);
    AImageList.Width := AGlyph.Width;
    AImageList.Height := AGlyph.Height;
    if ABackgroundColor <> clNone then
      //if ATempCanvas = nil then
      begin
        ABitmap := TBitmap.Create;
        ABitmap.Width := AImageList.Width;
        ABitmap.Height := AImageList.Height;
        with ABitmap.Canvas do
        begin
          Brush.Color := ABackgroundColor;
          FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
        end;
      end
      {else
        with ATempCanvas do
        begin
          Brush.Color := ABackgroundColor;
          FillRect(Bounds(X, Y, AGlyph.Width, AGlyph.Height));
        end};

    if AGlyph.TransparentMode = tmFixed then
      AImageList.AddMasked(AGlyph, AGlyph.TransparentColor)
    else
      AImageList.AddMasked(AGlyph, clDefault);

    if ABitmap <> nil then
    begin
      AImageList.Draw(ABitmap.Canvas, 0, 0, 0, AEnabled); // ??? itMask TODO
      Draw(X, Y, ABitmap);
    end
    else
      (*if ATempCanvas <> nil then
        AImageList.Draw(ATempCanvas, X, Y, 0, AEnabled) // ??? itMask TODO
      else*)
        AImageList.Draw(Canvas, X, Y, 0, AEnabled); // ??? itMask TODO
  finally
    ABitmap.Free;
    AImageList.Free;
  end;        
end;

procedure TcxCanvas.DrawImage(Images: TCustomImageList; X, Y, Index: Integer;
  Enabled: Boolean = True);
begin
  if (0 <= Index) and (Index < Images.Count) then
  begin
    SaveDC;
    Images.Draw(Canvas, X, Y, Index, Enabled);
    RestoreDC;
  end;
end;

procedure TcxCanvas.DrawText(const Text: string; R: TRect; Flags: Integer;
  Enabled: Boolean);
var
  AUseDrawText: Boolean;
  PrevBrushStyle: TBrushStyle;
  PrevFontColor: TColor;

  procedure ProcessFlags;
  var
    ASize: TSize;
    AAlignmentVert: TcxAlignmentVert;
  begin
    ASize := TextExtent(Text);
    if (ASize.cx <= R.Right - R.Left) and (ASize.cy <= R.Bottom - R.Top) then
      Flags := Flags or cxDontClip;
    if AUseDrawText then
    begin
      if (Flags and cxSingleLine = 0) and (Flags and (cxAlignBottom or cxAlignVCenter) <> 0) then
      begin
        if Flags and cxAlignBottom <> 0 then
          AAlignmentVert := vaBottom
        else
          AAlignmentVert := vaCenter;
        AlignMultiLineTextRectVertically(R, Text, AAlignmentVert,
          cxWordBreak and Flags <> 0, cxShowPrefix and Flags <> 0, Enabled,
          cxDontBreakChars and Flags <> 0);
      end;
      Flags := cxFlagsToDTFlags(Flags);
    end
    else
    begin
      if ASize.cx < R.Right - R.Left then
        case Flags and (cxAlignLeft or cxAlignRight or cxAlignHCenter) of
          cxAlignRight:
            R.Left := R.Right - ASize.cx - Ord(not Enabled);
          cxAlignHCenter:
            R.Left := (R.Left + R.Right - ASize.cx) div 2;
        end;
      if ASize.cy < R.Bottom - R.Top then
        case Flags and (cxAlignTop or cxAlignBottom or cxAlignVCenter) of
          cxAlignBottom:
            R.Top := R.Bottom - ASize.cy - Ord(not Enabled);
          cxAlignVCenter:
            R.Top := (R.Top + R.Bottom - ASize.cy) div 2;
        end;
      if Flags and cxDontClip = 0 then
        Flags := ETO_CLIPPED
      else
        Flags := 0;
    end;
  end;

  procedure DoDrawText;
  begin
    if AUseDrawText then
      cxDrawText(Canvas.Handle, Text, R, Flags)
    else
      cxExtTextOut(Canvas.Handle, Text, R.TopLeft, R, Flags);
  end;

begin
  if Length(Text) = 0 then Exit;
  AUseDrawText := (Flags and cxSingleLine = 0) or
    (Flags and (cxShowPrefix or cxShowEndEllipsis or cxShowPathEllipsis) <> 0);
  ProcessFlags;
  PrevBrushStyle := Brush.Style;
  PrevFontColor := Font.Color;
  if not Enabled then
  begin
    with R do
    begin
      Inc(Left);
      Inc(Top);
    end;
    Brush.Style := bsClear;
    Font.Color := clBtnHighlight;
    DoDrawText;
    OffsetRect(R, -1, -1);
    Font.Color := clBtnShadow;
  end;
  DoDrawText;
  if Brush.Style <> PrevBrushStyle then
    Brush.Style := PrevBrushStyle;
  Font.Color := PrevFontColor;
end;
                                 
procedure TcxCanvas.FillRect(const R: TRect; AColor: TColor); 
begin
  if AColor = clNone then Exit; 
  if AColor <> clDefault then
    SetBrushColor(AColor);
  Canvas.FillRect(R);
end;

procedure TcxCanvas.FillRect(const R: TRect; ABitmap: TBitmap = nil;
  AExcludeRect: Boolean = False);
var
  ABitmapSize, AOffset: TPoint;
  AFirstCol, AFirstRow, ALastCol, ALastRow, I, J: Integer;
  ABitmapRect, ACellRect: TRect;
begin
  if IsRectEmpty(R) then Exit;
  if not IsGlyphAssigned(ABitmap) then
    Canvas.FillRect(R)
  else
    with ABitmapSize do
    begin
      X := ABitmap.Width;
      Y := ABitmap.Height;
      AFirstCol := R.Left div X;
      AFirstRow := R.Top div Y;
      ALastCol := R.Right div X - Ord(R.Right mod X = 0);
      ALastRow := R.Bottom div Y - Ord(R.Bottom mod Y = 0);
      for J := AFirstRow to ALastRow do
        for I := AFirstCol to ALastCol do
        begin
          AOffset.X := I * X;
          AOffset.Y := J * Y;
          ACellRect := Bounds(AOffset.X, AOffset.Y, X, Y);
          IntersectRect(ACellRect, ACellRect, R);
          ABitmapRect := ACellRect;
          OffsetRect(ABitmapRect, -AOffset.X, -AOffset.Y);
          CopyRect(ACellRect, ABitmap.Canvas, ABitmapRect);
        end;
    end;
  if AExcludeRect then
    SetClipRegion(TcxRegion.Create(R), roSubtract);
end;

procedure TcxCanvas.FillRect(R: TRect; const AParams: TcxViewParams;
  ABorders: TcxBorders = []; ABorderColor: TColor = clDefault;
  ALineWidth: Integer = 1; AExcludeRect: Boolean = False);
begin
  FrameRect(R, ABorderColor, ALineWidth, ABorders, AExcludeRect);
  with R do
  begin
    if bLeft in ABorders then
      Inc(Left, ALineWidth);
    if bRight in ABorders then
      Dec(Right, ALineWidth);
    if bTop in ABorders then
      Inc(Top, ALineWidth);
    if bBottom in ABorders then
      Dec(Bottom, ALineWidth);
  end;
  SetBrushColor(AParams.Color);
  FillRect(R, AParams.Bitmap, AExcludeRect);
end;

procedure TcxCanvas.DrawDesignSelection(ARect: TRect; AWidth: Integer = cxDesignSelectionWidth);
var
  I: Integer;
begin
  for I := 0 to AWidth - 1 do
  begin
    DrawFocusRect(ARect);
    InflateRect(ARect, -1, -1);
  end;
end;

procedure TcxCanvas.DrawRegion(ARegion: TcxRegion; AContentColor: TColor = clDefault;
  ABorderColor: TColor = clDefault; ABorderWidth: Integer = 1; ABorderHeight: Integer = 1);
begin
  DrawRegion(ARegion.Handle, AContentColor, ABorderColor, ABorderWidth, ABorderHeight);
end;

procedure TcxCanvas.DrawRegion(ARegion: TcxRegionHandle; AContentColor: TColor = clDefault;
  ABorderColor: TColor = clDefault; ABorderWidth: Integer = 1; ABorderHeight: Integer = 1);
begin
  FillRegion(ARegion, AContentColor);
  FrameRegion(ARegion, ABorderColor, ABorderWidth, ABorderHeight);
end;

procedure TcxCanvas.FillRegion(ARegion: TcxRegion; AColor: TColor = clDefault);
begin
  FillRegion(ARegion.Handle, AColor);
end;

procedure TcxCanvas.FillRegion(ARegion: TcxRegionHandle; AColor: TColor = clDefault);
begin
  SetBrushColor(AColor);
  FillRgn(Handle, ARegion, Brush.Handle);
end;

procedure TcxCanvas.FlipHorizontally(ABitmap: TBitmap);
var
  Bits: TRGBColors;
  ARow, ACol, W, H, ARowStart: Integer;
  AValue: TRGBQuad;
begin
  W := ABitmap.Width;
  H := ABitmap.Height;

  Bits := GetBitmapBits(ABitmap, True);
  ARowStart := 0;
  for ARow := 0 to H - 1 do
  begin
    for ACol := 0 to (W - 1) div 2 do
    begin
      AValue := Bits[ARowStart + ACol];
      Bits[ARowStart + ACol] := Bits[ARowStart + W - 1 - ACol];
      Bits[ARowStart + W - 1 - ACol] := AValue;
    end;
    Inc(ARowStart, W);
  end;
  SetBitmapBits(ABitmap, Bits, True);
end;

procedure TcxCanvas.FrameRegion(ARegion: TcxRegion; AColor: TColor = clDefault;
  ABorderWidth: Integer = 1; ABorderHeight: Integer = 1);
begin
  FrameRegion(ARegion.Handle, AColor, ABorderWidth, ABorderHeight);
end;

procedure TcxCanvas.FrameRegion(ARegion: TcxRegionHandle; AColor: TColor = clDefault;
  ABorderWidth: Integer = 1; ABorderHeight: Integer = 1);
begin
  SetBrushColor(AColor);
  FrameRgn(Handle, ARegion, Brush.Handle, ABorderWidth, ABorderHeight);
end;

procedure TcxCanvas.Pie(const R: TRect; const ARadial1, ARadial2: TPoint);
begin
  with R do
    Canvas.Pie(Left, Top, Right, Bottom, ARadial1.X, ARadial1.Y, ARadial2.X, ARadial2.Y);
end;

procedure TcxCanvas.Pie(const R: TRect; AStartAngle, ASweepAngle: Integer);

{
                      A * B
  V = ---------------------------------------------
      Sqrt(A^2 * Sin^2(Alpha) + B^2 * Cos^2(Alpha))

  Radial.X = V * Cos(Alpha)
  Radial.Y = V * Sin(Alpha)

  where:
    A - horizontal ellipse semiaxis
    B - vertical ellipse semiaxis
    Angle - an angle between Radius-Vector and A calculated in counterclockwise direction
}

  function CalculateRadial(A, B: Integer; const ACenter: TPoint; AnAngle: Integer): TPoint;
  var
    Sin, Cos, V: Extended;
  begin
    SinCos(DegToRad(AnAngle), Sin, Cos);
    if (A <> 0) and (B <> 0) then
      V := A * B / Sqrt(A * A * Sin * Sin + B * B * Cos * Cos)
    else
      V := 0;
    Result.X := ACenter.X + Round(V * Cos);
    Result.Y := ACenter.Y - Round(V * Sin);
  end;

var
  A, B: Integer;
  Center, Radial1, Radial2: TPoint;
begin
  if IsRectEmpty(R) or (ASweepAngle = 0) then Exit;
  with R do
  begin
    A := (Right - Left) div 2;
    B := (Bottom - Top) div 2;
    Center.X := Left + A;
    Center.Y := Top + B;
  end;
  Radial1 := CalculateRadial(A, B, Center, AStartAngle);
  if ASweepAngle = 360 then
    Radial2 := Radial1
  else
    Radial2 := CalculateRadial(A, B, Center, AStartAngle + ASweepAngle);
  if (Radial1.X <> Radial2.X) or (Radial1.Y <> Radial2.Y) or (ASweepAngle > 180) then
    Pie(R, Radial1, Radial2);
end;

function TcxCanvas.FontHeight(AFont: TFont): Integer;
begin
  Font := AFont;
  Result := TextHeight('Qq');
end;

procedure TcxCanvas.FrameRect(const R: TRect; Color: TColor = clDefault;
  ALineWidth: Integer = 1; ABorders: TcxBorders = cxBordersAll;
  AExcludeFrame: Boolean = False);
begin
  if IsRectEmpty(R) then Exit;
  if Color <> clDefault then
  begin
    SetBrushColor(Color);
  end;
  with R do
  begin
    if bLeft in ABorders then
      FillRect(Rect(Left, Top, Min(Left + ALineWidth, Right), Bottom), nil, AExcludeFrame);
    if bRight in ABorders then
      FillRect(Rect(Max(Right - ALineWidth, Left), Top, Right, Bottom), nil, AExcludeFrame);
    if bTop in ABorders then
      FillRect(Rect(Left, Top, Right, Min(Top + ALineWidth, Bottom)), nil, AExcludeFrame);
    if bBottom in ABorders then
      FillRect(Rect(Left, Max(Bottom - ALineWidth, Top), Right, Bottom), nil, AExcludeFrame);
  end;
end;

procedure TcxCanvas.InvertFrame(const R: TRect; ABorderSize: Integer);
begin
  with R do
  begin
    InvertRect(Rect(Left, Top, Left + ABorderSize, Bottom));
    InvertRect(Rect(Right - ABorderSize, Top, Right, Bottom));
    InvertRect(Rect(Left + ABorderSize, Top,
      Right - ABorderSize, Top + ABorderSize));
    InvertRect(Rect(Left + ABorderSize, Bottom - ABorderSize,
      Right - ABorderSize, Bottom));
  end;
end;

procedure TcxCanvas.InvertRect(const R: TRect);
begin
  with Canvas do
  begin
    CopyMode := cmDstInvert;
    CopyRect(R, Canvas, R);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TcxCanvas.LineTo(X, Y: Integer);
begin
  Canvas.LineTo(X, Y);
end;

procedure TcxCanvas.MoveTo(X, Y: Integer);
begin
  Canvas.MoveTo(X, Y);
end;

procedure TcxCanvas.Polygon(const Points: array of TPoint);
begin
  Canvas.Polygon(Points);
end;

procedure TcxCanvas.Polyline(const Points: array of TPoint);
begin
  Canvas.Polyline(Points);
end;

procedure TcxCanvas.RotateBitmap(ABitmap: TBitmap; ARotationAngle: TcxRotationAngle;
  AFlipVertically: Boolean = False);
var
  SourceRGBs, DestRGBs: TRGBColors;
  ARow, ACol, H, W, ASourceI, ADestI: Integer;
begin
  SourceRGBs := nil; // to remove compiler's warning
  if (ARotationAngle = ra0) and not AFlipVertically then exit;
  H := ABitmap.Height;
  W := ABitmap.Width;

  SourceRGBs := GetBitmapBits(ABitmap, True);
  SetLength(DestRGBs, Length(SourceRGBs));

  for ARow := 0 to H - 1 do
    for ACol := 0 to W - 1 do
    begin
      ASourceI := ARow * W + ACol;
      case ARotationAngle of
        raPlus90:
          if AFlipVertically then
            ADestI := ACol * H + ARow
          else
            ADestI := (W - ACol - 1) * H + ARow;
        ra0:
          ADestI := (H - 1 - ARow) * W + ACol;
        ra180:
          if AFlipVertically then
            ADestI := ARow * W + W - ACol - 1
          else
            ADestI := (H - ARow - 1) * W + W - ACol - 1;
      else
        if AFlipVertically then
          ADestI := (W - ACol - 1) * H + H - ARow - 1
        else
          ADestI := H - 1 + ACol * H - ARow;
      end;
      DestRGBs[ADestI] := SourceRGBs[ASourceI];
    end;

  if ARotationAngle in [raPlus90, raMinus90] then
  begin
    ABitmap.Height := 0;
    ABitmap.Width := H;
    ABitmap.Height := W;
  end;
  SetBitmapBits(ABitmap, DestRGBs, True);
end;

function TcxCanvas.TextExtent(const Text: string): TSize;
begin
  TCanvasAccess(Canvas).RequiredState([csHandleValid, csFontValid]);
  Result.cX := 0;
  Result.cY := 0;
  cxGetTextExtentPoint32(Handle, Text, Result);
end;

procedure TcxCanvas.TextExtent(const Text: string; var R: TRect; Flags: Integer);
var
  RWidth, RHeight, TextWidth, TextHeight: Integer;

  procedure CalcRSizes(var AWidth, AHeight: Integer);
  begin
    with R do
    begin
      AWidth := Right - Left;
      AHeight := Bottom - Top;
    end;
  end;

  procedure AlignR;
  begin
    if Flags and DT_CENTER <> 0 then
      OffsetRect(R, (RWidth - TextWidth) div 2, 0)
    else
      if Flags and DT_RIGHT <> 0 then
        OffsetRect(R, RWidth - TextWidth, 0);
    if Flags and DT_VCENTER <> 0 then
      OffsetRect(R, 0, (RHeight - TextHeight) div 2)
    else
      if Flags and DT_BOTTOM <> 0 then
        OffsetRect(R, 0, RHeight - TextHeight);
  end;

begin
  CalcRSizes(RWidth, RHeight);
  Flags := cxFlagsToDTFlags(Flags);
  if (RWidth <= 0) and (Text <> '') then  // A2079
    R.Right := R.Left + 1;
  if cxDrawText(Canvas.Handle, Text, R, Flags and not DT_VCENTER or DT_CALCRECT) = 0 then
  begin
    R.Right := R.Left;
    R.Bottom := R.Top;
  end;
  CalcRSizes(TextWidth, TextHeight);
  AlignR;
end;

function TcxCanvas.TextHeight(const Text: string): Integer;
begin
  Result := TextExtent(Text).cy;
end;

function TcxCanvas.TextWidth(const Text: string): Integer;
begin
  Result := TextExtent(Text).cx;
end;

procedure TcxCanvas.TransparentDraw(X, Y: Integer; ABitmap: TBitmap; AAlpha: Byte;
  ABackground: TBitmap = nil);

  function BlendValues(ASource, ADestination: DWORD): DWORD;
  begin
    Result := MulDiv(ASource, AAlpha, 255) + MulDiv(ADestination, 255 - AAlpha, 255);
  end;

  procedure BlendValue(const ASource: TRGBQuad; var ADestination: TRGBQuad);
  begin
    ADestination.rgbBlue := BlendValues(ASource.rgbBlue, ADestination.rgbBlue);
    ADestination.rgbGreen := BlendValues(ASource.rgbGreen, ADestination.rgbGreen);
    ADestination.rgbRed := BlendValues(ASource.rgbRed, ADestination.rgbRed);
  end;

var
  W, H, ARow, ACol: Integer;
  ABackgroundBitmap: TBitmap;
  ABlendFunction: TBlendFunction;
  ABits, ABackgroundBits: TRGBColors;
begin
  ABits := nil; // to remove compiler's warning
  W := ABitmap.Width;
  H := ABitmap.Height;

  ABackgroundBitmap := TBitmap.Create;
  ABackgroundBitmap.Width := W;
  ABackgroundBitmap.Height := H;

  if ABackground = nil then
    ABackgroundBitmap.Canvas.CopyRect(Rect(0, 0, W, H), Canvas, Bounds(X, Y, W, H))
  else
    ABackgroundBitmap.Canvas.Draw(0, 0, ABackground);

  if Assigned(VCLAlphaBlend) then
  begin
    ABlendFunction := DefaultBlendFunction;
    ABlendFunction.SourceConstantAlpha := AAlpha;
    VCLAlphaBlend(ABackgroundBitmap.Canvas.Handle,
      0, 0, W, H, ABitmap.Canvas.Handle, 0, 0, W, H, ABlendFunction);
  end
  else
  begin
    ABits := GetBitmapBits(ABitmap, True);
    ABackgroundBits := GetBitmapBits(ABackgroundBitmap, True);

    for ARow := 0 to H - 1 do
      for ACol := 0 to W - 1 do
        BlendValue(ABits[ACol * H + ARow], ABackgroundBits[ACol * H + ACol]);

    SetBitmapBits(ABackgroundBitmap, ABackgroundBits, True);
  end;

  Draw(X, Y, ABackgroundBitmap);

  ABackgroundBitmap.Free;
end;

procedure TcxCanvas.RestoreDC;
var
  ALastSavedDCIndex: Integer;
begin
  ALastSavedDCIndex := FSavedDCs.Count - 1;
  if ALastSavedDCIndex >= 0 then
  begin
    Windows.RestoreDC(Handle, Integer(FSavedDCs[ALastSavedDCIndex]));
    FSavedDCs.Delete(ALastSavedDCIndex);
  end;
end;

procedure TcxCanvas.SaveDC;
begin
  FSavedDCs.Add(TObject(Windows.SaveDC(Handle)));
end;

procedure TcxCanvas.RestoreClipRegion;
var
  ALastSavedRegionIndex: Integer;
begin
  ALastSavedRegionIndex := FSavedRegions.Count - 1;
  if ALastSavedRegionIndex >= 0 then
  begin
    SetClipRegion(TcxRegion(FSavedRegions[ALastSavedRegionIndex]), roSet);
    FSavedRegions.Delete(ALastSavedRegionIndex);
  end;
end;

procedure TcxCanvas.SaveClipRegion;
begin
  FSavedRegions.Add(GetClipRegion);
end;

procedure TcxCanvas.RestoreState;

  procedure InternalRestoreState(var ACurrentState: TcxCanvasState);
  begin
    Font.Assign(ACurrentState.Font);
    ACurrentState.Font.Free;
    Brush.Assign(ACurrentState.Brush);
    ACurrentState.Brush.Free;
    Pen.Assign(ACurrentState.Pen);
    ACurrentState.Pen.Free;
  end;

begin
  if Length(FSavedStates) > 0 then
  begin
    InternalRestoreState(FSavedStates[High(FSavedStates)]);
    SetLength(FSavedStates, Length(FSavedStates) - 1);
    RestoreDC;
  end;
end;

procedure TcxCanvas.SaveState;

  procedure InternalSaveState(var ACurrentState: TcxCanvasState);
  begin
    ACurrentState.Font := TFont.Create;
    ACurrentState.Font.Assign(Font);
    ACurrentState.Brush := TBrush.Create;
    ACurrentState.Brush.Assign(Brush);
    ACurrentState.Pen := TPen.Create;
    ACurrentState.Pen.Assign(Pen);
  end;

begin
  SaveDC;
  SetLength(FSavedStates, Length(FSavedStates) + 1);
  InternalSaveState(FSavedStates[High(FSavedStates)]);
end;

procedure TcxCanvas.GetParams(var AParams: TcxViewParams);
begin
  AParams.Color := Brush.Color;
  AParams.Font := Font;
  AParams.TextColor := Font.Color;
end;

procedure TcxCanvas.SetParams(AParams: TcxViewParams);
begin
  SetBrushColor(AParams.Color);
  Font := AParams.Font;
  Font.Color := AParams.TextColor;
end;

procedure TcxCanvas.SetBrushColor(Value: TColor);
begin
  if Brush.Color <> Value then
    Brush.Color := Value;
end;

procedure TcxCanvas.SetFontAngle(Value: Integer);
var
  ALogFont: TLogFont;
begin
  cxGetFontData(Font.Handle, ALogFont);
  ALogFont.lfEscapement := Value * 10;
  if Value <> 0 then
    ALogFont.lfOutPrecision := OUT_TT_ONLY_PRECIS;
  Font.Handle := CreateFontIndirect(ALogFont);
end;

procedure TcxCanvas.GetTextStringsBounds(Text: string; R: TRect; Flags: Integer;
  Enabled: Boolean; var ABounds: TRectArray);
var
  AAlignHorz, AAlignVert, AMaxCharCount: Integer;
  ATextR: TRect;
  AStringSize: TSize;

  procedure PrepareRects;
  begin
    if not Enabled then
      with R do
      begin
        Dec(Right);
        Dec(Bottom);
      end;
    ATextR := R;
    TextExtent(Text, ATextR, Flags);
    case AAlignVert of
      cxAlignBottom:
        OffsetRect(ATextR, 0, R.Bottom - ATextR.Bottom);
      cxAlignVCenter:
        OffsetRect(ATextR, 0, (R.Bottom - ATextR.Bottom) div 2);
    end;
  end;

  procedure CheckMaxCharCount;

    function ProcessSpecialChars: Boolean;
    const
      SpecialChars = [#10, #13];
    var
      I, ACharCount: Integer;
    begin
      Result := False;
      for I := 1 to AMaxCharCount do
        if dxCharInSet(Text[I], SpecialChars) then
        begin
          AMaxCharCount := I - 1;
          ACharCount := 1;
          if (I < Length(Text)) and
            dxCharInSet(Text[I + 1], SpecialChars) and (Text[I] <> Text[I + 1]) then
            Inc(ACharCount);
          Delete(Text, I, ACharCount);
          Result := True;
          Break;
        end;
    end;

    procedure ProcessSpaces;
    var
      I: Integer;
    begin
      if AMaxCharCount < Length(Text) then
        for I := AMaxCharCount + 1 downto 1 do
          if Text[I] = ' ' then
          begin
            if I < AMaxCharCount then
            begin
              AMaxCharCount := I;
              if AAlignHorz <> cxAlignLeft then
              begin
                Delete(Text, I, 1);
                Dec(AMaxCharCount);
              end;
            end;  
            Break;
          end;
    end;

  begin
    if not ProcessSpecialChars then
      ProcessSpaces;
  end;

  procedure GetStringSize;
  begin
    if AMaxCharCount = 0 then
      AStringSize.cx := 0
    else
      cxGetTextExtentPoint32(Handle, Copy(Text, 1, AMaxCharCount), AStringSize, AMaxCharCount);
  end;

  function GetBounds: TRect;
  begin
    Result := ATextR;
    with Result, AStringSize do
    begin
      case AAlignHorz of
        cxAlignLeft:
          Right := Left + cx;
        cxAlignRight:
          Left := Right - cx;
        cxAlignHCenter:
          begin
            Left := (Left + Right - cx) div 2;
            Right := Left + cx;
          end;
      end;
      Bottom := Top + cy;
    end;
    ATextR.Top := Result.Bottom;
  end;

begin
  if Text = '' then Exit;
  if Flags and cxShowPrefix <> 0 then
  begin
    Text := StripHotKey(Text);
    Flags := Flags and not cxShowPrefix;
  end;
  AAlignHorz := Flags and (cxAlignLeft or cxAlignRight or cxAlignHCenter);
  AAlignVert := Flags and (cxAlignTop or cxAlignBottom or cxAlignVCenter);
  PrepareRects;
  repeat
    GetTextExtentExPoint(Handle, PChar(Text), Length(Text), R.Right - R.Left,
      @AMaxCharCount, nil, AStringSize);
    CheckMaxCharCount;
    GetStringSize;
    SetLength(ABounds, High(ABounds) + 2);
    ABounds[High(ABounds)] := GetBounds;
    Delete(Text, 1, AMaxCharCount);
  until Text = '';
end;

procedure TcxCanvas.BeginPath;
begin
  Windows.BeginPath(Handle);
end;

procedure TcxCanvas.EndPath;
begin
  Windows.EndPath(Handle);
end;

function TcxCanvas.PathToRegion: TcxRegion;
begin
  Result := TcxRegion.Create(Windows.PathToRegion(Handle));
end;

procedure TcxCanvas.WidenPath;
begin
  Windows.WidenPath(Handle);
end;

procedure TcxCanvas.ExcludeClipRect(const R: TRect);
begin
  with R do
    Windows.ExcludeClipRect(Handle, Left, Top, Right, Bottom);
end;

procedure TcxCanvas.IntersectClipRect(const R: TRect);
begin
  with R do
    Windows.IntersectClipRect(Canvas.Handle, Left, Top, Right, Bottom);
end;

function TcxCanvas.GetClipRegion(AConsiderOrigin: Boolean = True): TcxRegion;
const
  MaxRegionSize = 30000;
begin
  Result := TcxRegion.Create;
  if GetClipRgn(Handle, Result.Handle) = 0 then
    SetRectRgn(Result.Handle, 0, 0, MaxRegionSize, MaxRegionSize);
  if AConsiderOrigin then
    Result.Offset(-DCOrigin.X, -DCOrigin.Y);
end;

procedure TcxCanvas.SetClipRegion(ARegion: TcxRegion; AOperation: TcxRegionOperation;
  ADestroyRegion: Boolean = True; AConsiderOrigin: Boolean = True);
var
  AClipRegion: TcxRegion;
  ARegionOrigin: TPoint;
begin
  if AOperation = roSet then
  begin
    if AConsiderOrigin then
    begin
      ARegionOrigin := DCOrigin;
      ARegion.Offset(ARegionOrigin.X, ARegionOrigin.Y);
    end;
    SelectClipRgn(Handle, ARegion.Handle);
    if ADestroyRegion then
      ARegion.Free
    else
      if AConsiderOrigin then
        ARegion.Offset(-ARegionOrigin.X, -ARegionOrigin.Y);
  end
  else
  begin
    AClipRegion := GetClipRegion(AConsiderOrigin);
    AClipRegion.Combine(ARegion, AOperation, ADestroyRegion);
    SetClipRegion(AClipRegion, roSet, True, AConsiderOrigin);
  end;
end;

function TcxCanvas.RectFullyVisible(const R: TRect): Boolean;
var
  AClipRegion, ARegion: TcxRegion;
begin
  AClipRegion := GetClipRegion;
  ARegion := TcxRegion.Create(R);
  try
    CombineRgn(AClipRegion.Handle, AClipRegion.Handle, ARegion.Handle, RGN_AND);
    Result := AClipRegion.IsEqual(ARegion);
  finally
    ARegion.Free;
    AClipRegion.Free;
  end;
end;

function TcxCanvas.RectVisible(const R: TRect): Boolean;
begin
  Result := Windows.RectVisible(Handle, R);
end;

{ TcxScreen }

type
  TcxScreenControl = class(TWinControl)
  protected
    procedure CreateHandle; override;
    procedure DestroyWindowHandle; override;

    function GetDeviceContext(var WindowHandle: HWnd): HDC; override;
  end;

  TScreenCanvas = class(TControlCanvas)
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TcxScreenControl }

procedure TcxScreenControl.CreateHandle;
begin
  WindowHandle := GetDesktopWindow;
end;

procedure TcxScreenControl.DestroyWindowHandle;
begin
  WindowHandle := 0;
end;

function TcxScreenControl.GetDeviceContext(var WindowHandle: HWnd): HDC;
begin
{$IFDEF CXTEST}
  Result := GetDC(Handle);
{$ELSE}
  Result := GetDCEx(Handle, 0, DCX_CACHE or DCX_LOCKWINDOWUPDATE); //B96653
{$ENDIF}
  WindowHandle := Handle;
end;

{ TScreenCanvas }

constructor TScreenCanvas.Create;
begin
  inherited;
  Control := TcxScreenControl.Create(nil);
end;

destructor TScreenCanvas.Destroy;
begin
  FreeHandle;
  Control.Free;
  Control := nil;
  inherited;
end;

{ TcxScreenCanvas }

constructor TcxScreenCanvas.Create;
begin
  inherited Create(TScreenCanvas.Create);
end;

destructor TcxScreenCanvas.Destroy;
begin
  FreeAndNil(FCanvas);
  inherited;
end;

function cxScreenCanvas: TcxScreenCanvas;
begin
  if ScreenCanvas = nil then
    ScreenCanvas := TcxScreenCanvas.Create;
  Result := ScreenCanvas;
end;

{ TcxCustomBitmap }

constructor TcxCustomBitmap.Create;
begin
  CreateSize(0, 0);
end;

constructor TcxCustomBitmap.CreateSize(const ARect: TRect);
begin
  CreateSize(cxRectWidth(ARect), cxRectHeight(ARect));
end;

constructor TcxCustomBitmap.CreateSize(AWidth, AHeight: Integer);
begin
  CreateSize(AWidth, AHeight, pf24bit);
end;

constructor TcxCustomBitmap.CreateSize(const ARect: TRect; APixelFormat: TPixelFormat);
begin
  CreateSize(cxRectWidth(ARect), cxRectHeight(ARect), APixelFormat);
end;

constructor TcxCustomBitmap.CreateSize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat);
begin
  inherited Create;

  Initialize(AWidth, AHeight, APixelFormat);
end;

destructor TcxCustomBitmap.Destroy;
begin
  FreeAndNil(FcxCanvas);
  inherited;
end;

procedure TcxCustomBitmap.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxCustomBitmap.EndUpdate(AForceUpdate: Boolean = True);
begin
  if FLockCount > 0 then
  begin
    Dec(FLockCount);
    if AForceUpdate or FModified then
      Changed(Self);
  end;
end;

procedure TcxCustomBitmap.CopyBitmap(ABitmap: TBitmap; ACopyMode: DWORD = SRCCOPY);
begin
  CopyBitmap(ABitmap, ClientRect, cxNullPoint, ACopyMode);
end;

procedure TcxCustomBitmap.CopyBitmap(ABitmap: TBitmap; const ADestRect: TRect; const ASrcTopLeft: TPoint; ACopyMode: DWORD);
begin
  cxBitBlt(Canvas.Handle, ABitmap.Canvas.Handle, ADestRect, ASrcTopLeft, ACopyMode);
end;

procedure TcxCustomBitmap.Clear;
begin
  Canvas.Brush.Color := 0;
  Canvas.FillRect(ClientRect);
end;

procedure TcxCustomBitmap.Rotate(ARotationAngle: TcxRotationAngle; AFlipVertically: Boolean);
begin
  cxCanvas.RotateBitmap(Self, ARotationAngle, AFlipVertically);
end;

procedure TcxCustomBitmap.SetSize(AWidth, AHeight: Integer);
begin
  BeginUpdate;
  try
{$IFDEF DELPHI10}
    inherited;
{$ELSE}
    Width := AWidth;
    Height := AHeight;
{$ENDIF}
  finally
    EndUpdate(False);
  end;
end;

procedure TcxCustomBitmap.Changed(Sender: TObject);
begin
  if not ChangeLocked then
  begin
    inherited;
    Update;
    FModified := False;
  end
  else
    FModified := True;
end;

function TcxCustomBitmap.ChangeLocked: Boolean;
begin
  Result := FLockCount > 0;
end;

procedure TcxCustomBitmap.Initialize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat);
begin
  FcxCanvas := TcxCanvas.Create(Canvas);

  BeginUpdate;
  try
    Width := AWidth;
    Height := AHeight;
    PixelFormat := APixelFormat;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomBitmap.Update;
begin
// do nothing
end;

const
  ADXBMSignature: Integer = $4D424458; //DXBM
  ADXBMVersion: Word = 1;

procedure TcxCustomBitmap.ReadData(Stream: TStream);
var
  ASize: Integer;
  ASignature: Integer;
  AVersion: Word;
  AStreamPos: Integer;
  AMemoryStream: TMemoryStream;
begin
  AStreamPos := Stream.Position;
  Stream.Read(ASize, SizeOf(ASize));
  Stream.Read(ASignature, SizeOf(ASignature));
  Stream.Read(AVersion, SizeOf(AVersion));
  if ASignature <> ADXBMSignature then
  begin
    Stream.Position := AStreamPos;
    inherited ReadData(Stream);
  end
  else
  begin
    AMemoryStream := TMemoryStream.Create;
    try
      Decompress(Stream, AMemoryStream, ASize);
      AMemoryStream.Position := 0;
      inherited ReadData(AMemoryStream);
    finally
      AMemoryStream.Free;
    end;
  end;
end;

procedure TcxCustomBitmap.WriteData(Stream: TStream);

  procedure WriteSignature(AStream: TStream; ASize, ASignaturePosition: Integer);
  var
    ACurrentPos: Integer;
  begin
    ACurrentPos := AStream.Position;
    AStream.Position := ASignaturePosition;
    AStream.Write(ASize, SizeOf(ASize));
    AStream.Write(ADXBMSignature, SizeOf(ADXBMSignature));
    AStream.Write(ADXBMVersion, SizeOf(ADXBMVersion));
    AStream.Position := ACurrentPos;
  end;

var
  AMemoryStream: TMemoryStream;
  ASignaturePosition, ADataOffset: Integer;
  ASize: Integer;
begin
  if CompressData then
  begin
    AMemoryStream := TMemoryStream.Create;
    try
      inherited WriteData(AMemoryStream);
      AMemoryStream.Position := 0;
      ASignaturePosition := Stream.Position;
      ADataOffset := SizeOf(ASize) + SizeOf(ADXBMSignature) + SizeOf(ADXBMVersion);
      Stream.Position := Stream.Position + ADataOffset;
      Compress(AMemoryStream, Stream, AMemoryStream.Size);
    finally
      AMemoryStream.Free;
    end;
    ASize := Stream.Position - ADataOffset;
    WriteSignature(Stream, ASize, ASignaturePosition);
  end
  else
    inherited;
end;

type
  TSeekMode = (smDup, smUnique);
const
  AModeMap: array[Boolean] of TSeekMode = (smDup, smUnique);
  AModeMask: array[TSeekMode] of Byte = (0, 128);

function ReadByte(AStream: TStream; AMaxPos: Integer; var AByte: Byte): Boolean;
begin
  Result := AStream.Position < AMaxPos;
  if Result then
    AStream.Read(AByte, SizeOf(Byte));
end;

procedure WriteByte(AStream: TStream; AByte: Byte);
begin
  AStream.Write(AByte, SizeOf(Byte));
end;

procedure TcxCustomBitmap.Compress(ASourceStream, ADestStream: TStream; ASize: Integer);

  function GetCounter(ASeekByte: Byte; AMode: TSeekMode; AMaxPos: Integer): Integer;
  var
    AByte: Byte;
  begin
    Result := 1;
    while (Result < 125) and ReadByte(ASourceStream, AMaxPos, AByte) do
    begin
      if (AMode = smDup) and (AByte = ASeekByte) or (AMode = smUnique) and (AByte <> ASeekByte) then
        Inc(Result)
      else
      begin
        if AMode = smUnique then
          Dec(Result);
        Break;
      end;
      ASeekByte := AByte;
    end;
  end;

var
  AReadByte1, AReadByte2, AWriteByte1, AWriteByte2: Byte;
  ACounter, AReadedCount: Integer;
  AStreamPos, AMaxPos: Integer;
  AMode: TSeekMode;
begin
  AMaxPos := ASourceStream.Position + ASize;
  while ReadByte(ASourceStream, AMaxPos, AReadByte1) do
  begin
    AReadedCount := 1;
    AStreamPos := ASourceStream.Position - 1;
    if ReadByte(ASourceStream, AMaxPos, AReadByte2) then
      Inc(AReadedCount);
    AMode := AModeMap[(AReadedCount = 1) or (AReadByte1 <> AReadByte2)];
    ASourceStream.Position := ASourceStream.Position - (AReadedCount - 1);

    ACounter := GetCounter(AReadByte1, AMode, AMaxPos);
    AWriteByte1 := ACounter or AModeMask[AMode];
    WriteByte(ADestStream, AWriteByte1);
    case AMode of
      smUnique:
        begin
          ASourceStream.Position := AStreamPos;
          ADestStream.CopyFrom(ASourceStream, ACounter);
        end;
      smDup:
        begin
          AWriteByte2 := AReadByte2;
          WriteByte(ADestStream, AWriteByte2);
        end;
    end;
    ASourceStream.Position := AStreamPos + ACounter;
  end;
end;

procedure TcxCustomBitmap.Decompress(ASourceStream, ADestStream: TStream; ASize: Integer);
var
  AReadByte1, AReadByte2: Byte;
  AMaxPos: Integer;
  I: Integer;
  ACounter: Integer;
begin
  AMaxPos := ASourceStream.Position + ASize;
  while ReadByte(ASourceStream, AMaxPos, AReadByte1) do
  begin
    ACounter := AReadByte1 and 127;
    if (AReadByte1 and AModeMask[smUnique]) <> 0 then
      ADestStream.CopyFrom(ASourceStream, ACounter)
    else
    begin
      ReadByte(ASourceStream, AMaxPos, AReadByte2);
      for I := 0 to ACounter - 1 do
        WriteByte(ADestStream, AReadByte2);
    end;
  end;
end;

function TcxCustomBitmap.GetClientRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
end;

{ TcxBitmap }

const
  ClrNone: TRGBQuad = (rgbBlue: $FF; rgbGreen: $FF; rgbRed: $FF; rgbReserved: $FF);
  ClrTransparent: TRGBQuad = (rgbBlue: 0; rgbGreen: 0; rgbRed: 0; rgbReserved: 0);

function cxColorIsEqual(const AColor1, AColor2: TRGBQuad): Boolean;
begin
  Result := DWORD(AColor1) = DWORD(AColor2);
end;

function cxColorEssence(const AColor: TRGBQuad): DWORD;
begin
  Result := DWORD(AColor) and $00FFFFFF;
end;

function TcxColorList.Add(AColor: TColor): Integer;
begin
  Result := inherited Add(Pointer(cxColorEssence(cxColorToRGBQuad(AColor))));
end;

constructor TcxBitmap.CreateSize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat);
begin
  inherited CreateSize(AWidth, AHeight, pf32bit);
  Clear;
end;

constructor TcxBitmap.CreateSize(AWidth, AHeight: Integer; ATransparentBkColor: TRGBQuad);
begin
  inherited CreateSize(AWidth, AHeight, pf32bit);

  TransparentBkColor := ATransparentBkColor;
  Clear;
end;

destructor TcxBitmap.Destroy;
begin
  FreeAndNil(FTransparentPixels);
  inherited;
end;

procedure TcxBitmap.GetBitmapColors(out AColors: TRGBColors);
begin
  SetLength(AColors, Width * Height);

{$IFDEF CXTEST}
  if GetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS) = 0 then
  begin
    FreeAndNil(ScreenCanvas);
  {$IFDEF DELPHI9}
    Assert(GetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS) <> 0, 'GetBitmapColors fails');
  {$ELSE}
    GetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS);
  {$ENDIF}
  end;
{$ELSE}
  GetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS)
{$ENDIF}
end;

procedure TcxBitmap.SetBitmapColors(const AColors: TRGBColors);
begin
{$IFDEF CXTEST}
  if SetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS) = 0 then
  begin
    FreeAndNil(ScreenCanvas);
  {$IFDEF DELPHI9}
    Assert(SetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS) <> 0, 'SetBitmapColors fails');
  {$ELSE}
    SetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS);
  {$ENDIF}
  end;
{$ELSE}
  SetDIBits(cxScreenCanvas.Handle, Handle, 0, Height, AColors, FBitmapInfo, DIB_RGB_COLORS);
{$ENDIF}
end;

procedure TcxBitmap.AlphaBlend(ABitmap: TcxBitmap; const ARect: TRect; ASmoothImage: Boolean; AConstantAlpha: Byte = $FF);
begin
  cxAlphaBlend(ABitmap, Self, ARect, ClientRect, ASmoothImage, AConstantAlpha);
end;

procedure TcxBitmap.Clear;
begin
  if FTransparentBkColor.rgbReserved <> 0 then
    TransformBitmap(btmClear)
  else
    inherited;
end;

procedure TcxBitmap.DrawHatch(const AHatchData: TcxHatchData);
begin
  HatchData := AHatchData;
  TransformBitmap(btmHatch);
end;

procedure TcxBitmap.DrawHatch(AColor1, AColor2: TColor; AStep, AAlpha1, AAlpha2: Byte);
var
  AHatchData: TcxHatchData;
begin
  AHatchData.Color1 := cxColorToRGBQuad(AColor1, $FF);
  AHatchData.Alpha1 := AAlpha1;
  AHatchData.Color2 := cxColorToRGBQuad(AColor2, $FF);
  AHatchData.Alpha2 := AAlpha2;
  AHatchData.Step := AStep;
  DrawHatch(AHatchData);
end;

procedure TcxBitmap.DrawShadow(AMaskBitmap: TcxBitmap; AShadowSize: Integer; AShadowColor: TColor; AInflateSize: Boolean);
const
  DPSnaa = $00200F09;
var
  AShadowBitmap, ASelfCopy: TcxBitmap;
begin
  AShadowBitmap := TcxBitmap.CreateSize(Width + AShadowSize * 2, Height + AShadowSize * 2, ClrNone);
  try
    AShadowBitmap.CopyBitmap(AMaskBitmap, cxRectOffset(ClientRect, AShadowSize, AShadowSize), cxNullPoint);
    AShadowBitmap.Canvas.Brush.Color := AShadowColor;
    AShadowBitmap.Canvas.CopyMode := DPSnaa;
    AShadowBitmap.Canvas.Draw(AShadowSize, AShadowSize, AShadowBitmap);

    AShadowBitmap.TransparentBkColor := ClrTransparent;
    AShadowBitmap.TransformBitmap(btmCorrectBlend);

    ASelfCopy := TcxBitmap.CreateSize(Width + AShadowSize, Height + AShadowSize);
    try
      ASelfCopy.CopyBitmap(Self);
      ASelfCopy.CopyBitmap(AShadowBitmap, ASelfCopy.ClientRect, Point(AShadowSize, AShadowSize), SRCPAINT);
      if AInflateSize then
        SetSize(Width + AShadowSize, Height + AShadowSize);
      CopyBitmap(ASelfCopy);
    finally
      ASelfCopy.Free;
    end;
  finally
    AShadowBitmap.Free;
  end;
end;

procedure TcxBitmap.Filter(AMaskBitmap: TcxBitmap);
const
  DSna = $00220326;
begin
  CopyBitmap(AMaskBitmap, DSna);
end;

procedure TcxBitmap.Invert;
begin
  CopyBitmap(Self, NOTSRCCOPY);
end;

procedure TcxBitmap.MakeOpaque;
var
  AColors: TRGBColors;
  I: Integer;
begin
  GetBitmapColors(AColors);
  for I := 0 to Length(AColors) - 1 do
    AColors[I].rgbReserved := $FF;
  SetBitmapColors(AColors);
end;

procedure TcxBitmap.RecoverAlphaChannel(ATransparentColor: TColor);
begin
  TransparentPixels.Clear;
  TransparentPixels.Add(ATransparentColor);
  TransparentBkColor := cxColorToRGBQuad(ATransparentColor);
  TransformBitmap(btmCorrectBlend);
end;

procedure TcxBitmap.SetSize(AWidth, AHeight: Integer);
begin
  inherited;
  Clear;
end;

procedure TcxBitmap.Shade(AMaskBitmap: TcxBitmap);
const
  DSPDxax = $00E20746;
begin
  AMaskBitmap.Canvas.CopyMode := cmPatInvert;
  AMaskBitmap.Canvas.Draw(0, 0, AMaskBitmap);

  Canvas.CopyMode := cmSrcCopy;
  Canvas.Draw(1, 1, AMaskBitmap);

  Canvas.CopyMode := DSPDxax;
  Canvas.Brush.Color := clBtnShadow;
  Canvas.Draw(0, 0, AMaskBitmap);

  TransformBitmap(btmCorrectBlend);
end;

procedure TcxBitmap.TransformBitmap(AMode: TcxBitmapTransformationMode);
var
  AColors: TRGBColors;
  I, J: Integer;
  ATransformProc: TcxBitmapTransformationProc;
begin
  case AMode of
    btmDingy:
      ATransformProc := Dingy;
    btmDirty:
      ATransformProc := Dirty;
    btmGrayScale:
      ATransformProc := GrayScale;
    btmSetOpaque:
      ATransformProc := SetOpaque;
    btmMakeMask:
      ATransformProc := MakeMask;
    btmFade:
      ATransformProc := Fade;
    btmDisable:
      ATransformProc := Disable;
    btmCorrectBlend:
      ATransformProc := CorrectBlend;
    btmHatch:
      ATransformProc := Hatch;
    btmClear:
      ATransformProc := ClearColor;
    btmResetAlpha:
      ATransformProc := ResetAlpha;
  else
    Exit;
  end;

  GetBitmapColors(AColors);

  for I := 0 to Width - 1 do
    for J := 0 to Height - 1 do
    begin
      FCurrentColorIndex.X := I;
      FCurrentColorIndex.Y := J;

      ATransformProc(AColors[J * Width + I]);
    end;

  SetBitmapColors(AColors);
  Changed(Self);
end;

procedure TcxBitmap.Initialize(AWidth, AHeight: Integer; APixelFormat: TPixelFormat);
begin
  FillBitmapInfoHeader(FBitmapInfo.bmiHeader, Self, False);
  FTransparentPixels := TcxColorList.Create;
  inherited;
end;

procedure TcxBitmap.Update;
begin
  UpdateBitmapInfo;
end;

function TcxBitmap.GetIsAlphaUsed: Boolean;
var
  AColors: TRGBColors;
  I: Integer;
begin
  Result := False;
  GetBitmapColors(AColors);
  for I := Low(AColors) to High(AColors) do
  begin
    Result := AColors[I].rgbReserved <> 0;
    if Result then
      Break;
  end;
end;

procedure TcxBitmap.CorrectBlend(var AColor: TRGBQuad);
begin
  if not IsColorTransparent(AColor) and (AColor.rgbReserved = 0) then
    AColor.rgbReserved := $FF;
end;

procedure TcxBitmap.ClearColor(var AColor: TRGBQuad);
begin
  AColor := TransparentBkColor;
end;

procedure TcxBitmap.Dingy(var AColor: TRGBQuad);

  procedure LightColor(var AColor: Byte);
  begin
    AColor := GetChannelValue(AColor + MulDiv(255 - AColor, 3, 10));
  end;

  procedure BlendColor(var AColor: Byte);
  begin
    AColor := GetChannelValue(MulDiv(AColor, 200, 255));
  end;

begin
  if not IsColorTransparent(AColor) then
  begin
    if AColor.rgbReserved = $FF then
    begin
      LightColor(AColor.rgbRed);
      LightColor(AColor.rgbGreen);
      LightColor(AColor.rgbBlue);
    end
    else
    begin
      BlendColor(AColor.rgbRed);
      BlendColor(AColor.rgbGreen);
      BlendColor(AColor.rgbBlue);
      BlendColor(AColor.rgbReserved);
    end;
  end;
end;

procedure TcxBitmap.Dirty(var AColor: TRGBQuad);
var
  ADirtyScreen:TRGBQuad;
begin
  if not IsColorTransparent(AColor) then
  begin
    Scale(AColor, GrayMap);

    ADirtyScreen := cxColorToRGBQuad(clBtnShadow);
    ADirtyScreen.rgbReserved := $C0;

    cxBlendFunction(ADirtyScreen, AColor, $EE);
  end;
end;

procedure TcxBitmap.Disable(var AColor: TRGBQuad);
begin
  if not IsColorTransparent(AColor) then
    Scale(AColor, DisableMap);
end;

procedure TcxBitmap.Fade(var AColor: TRGBQuad);
begin
  if not IsColorTransparent(AColor) then
    Scale(AColor, FadeMap);
end;

procedure TcxBitmap.GrayScale(var AColor: TRGBQuad);
var
  AValue: Byte;
begin
  if not IsColorTransparent(AColor) then
  begin
    AValue := (AColor.rgbRed + AColor.rgbGreen + AColor.rgbBlue) div 3;
    AColor.rgbRed := AValue;
    AColor.rgbGreen := AValue;
    AColor.rgbBlue := AValue;
  end;
end;

procedure TcxBitmap.Hatch(var AColor: TRGBQuad);
begin
  if Odd(FCurrentColorIndex.X div FHatchData.Step + FCurrentColorIndex.Y div FHatchData.Step) then
    cxBlendFunction(FHatchData.Color2, AColor, FHatchData.Alpha2)
  else
    cxBlendFunction(FHatchData.Color1, AColor, FHatchData.Alpha1);
end;

procedure TcxBitmap.MakeMask(var AColor: TRGBQuad);
begin
  if IsColorTransparent(AColor) then
    AColor := ClrNone
  else
    AColor := ClrTransparent;
end;

procedure TcxBitmap.SetOpaque(var AColor: TRGBQuad);
begin
  AColor.rgbReserved := $FF;
end;

procedure TcxBitmap.ResetAlpha(var AColor: TRGBQuad);
begin
  AColor.rgbReserved := 0;
end;

procedure TcxBitmap.Scale(var AColor: TRGBQuad; const AColorMap: TcxColorTransitionMap);
var
  AResultValue: Byte;
begin
  AResultValue := Round(AColorMap.RedScale * AColor.rgbRed + AColorMap.GreenScale * AColor.rgbGreen + AColorMap.BlueScale * AColor.rgbBlue);
  AColor.rgbBlue := AResultValue;
  AColor.rgbGreen := AResultValue;
  AColor.rgbRed := AResultValue;
end;

procedure TcxBitmap.UpdateBitmapInfo;
begin
  FBitmapInfo.bmiHeader.biHeight := Height;
  FBitmapInfo.bmiHeader.biWidth := Width;
end;

function TcxBitmap.IsColorTransparent(const AColor: TRGBQuad): Boolean;

  function IsTransparentPixel(AColor: DWORD): Boolean;
  begin
    Result := TransparentPixels.IndexOf(Pointer(AColor)) <> -1;
  end;

begin
  Result := cxColorIsEqual(AColor, TransparentBkColor) or IsTransparentPixel(cxColorEssence(AColor));
end;

{ TcxImageInfo }

constructor TcxImageInfo.Create;
begin
  inherited Create;
  FImage := TcxCustomBitmap.Create;
  FMask := TcxCustomBitmap.Create;
  FMaskColor := clNone;
end;

destructor TcxImageInfo.Destroy;
begin
  FreeAndNil(FMask);
  FreeAndNil(FImage);
  inherited;
end;

procedure TcxImageInfo.Assign(Source: TPersistent);
begin
  if Source is TcxImageInfo then
  begin
    Image := TcxImageInfo(Source).Image;
    Mask := TcxImageInfo(Source).Mask;
    MaskColor := TcxImageInfo(Source).MaskColor;
  end
  else
    inherited;
end;

procedure TcxImageInfo.SetImage(Value: TBitmap);
begin
  AssignBitmap(Value, Image);
end;

procedure TcxImageInfo.SetMask(Value: TBitmap);
begin
  AssignBitmap(Value, Mask);
end;

procedure TcxImageInfo.AssignBitmap(ASourceBitmap, ADestBitmap: TBitmap);
begin
  ADestBitmap.Assign(ASourceBitmap);
  ADestBitmap.Handle; // HandleNeeded
end;

{ TcxImageList }

type
  TcxImageInfoItem = class(TCollectionItem)
  private
    FImageInfo: TcxImageInfo;

    function GetCompressData: Boolean;
    function GetImage: TBitmap;
    function GetMask: TBitmap;
    function GetMaskColor: TColor;
    procedure SetCompressData(Value: Boolean);
    procedure SetImage(Value: TBitmap);
    procedure SetMask(Value: TBitmap);
    procedure SetMaskColor(Value: TColor);
  public
    constructor Create(ACollection: TCollection); overload; override;
    constructor Create(ACollection: TCollection; AImage, AMask: TBitmap; AMaskColor: TColor = clNone); reintroduce; overload;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property CompressData: Boolean read GetCompressData write SetCompressData;
    property ImageInfo: TcxImageInfo read FImageInfo;
  published
    property Image: TBitmap read GetImage write SetImage;
    property Mask: TBitmap read GetMask write SetMask;
    property MaskColor: TColor read GetMaskColor write SetMaskColor default clNone;
  end;

  TcxImageInfoCollection = class(TCollection)
  private
    FCompressData: Boolean;
    FImageList: TcxImageList;
    procedure SetCompressData(Value: Boolean);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AImageList: TcxImageList);
    function Add(AImage, AMask: TBitmap; AMaskColor: TColor = clNone): TCollectionItem;
    procedure Move(ACurrentIndex, ANewIndex: Integer);
    procedure Delete(AIndex: Integer);

    property CompressData: Boolean read FCompressData write SetCompressData;
  end;

constructor TcxImageInfoItem.Create(ACollection: TCollection);
begin
  inherited;
  FImageInfo := TcxImageInfo.Create;
  CompressData := TcxImageInfoCollection(ACollection).CompressData;
end;

constructor TcxImageInfoItem.Create(ACollection: TCollection; AImage, AMask: TBitmap; AMaskColor: TColor);
begin
  Create(ACollection);
  Image := AImage;
  Mask := AMask;
  MaskColor := AMaskColor;
end;

destructor TcxImageInfoItem.Destroy;
begin
  FreeAndNil(FImageInfo);
  inherited;
end;

procedure TcxImageInfoItem.Assign(Source: TPersistent);
begin
  if Source is TcxImageInfoItem then
    FImageInfo.Assign(TcxImageInfoItem(Source).ImageInfo)
  else
    inherited;
end;

function TcxImageInfoItem.GetCompressData: Boolean;
begin
  Result := TcxCustomBitmap(Image).CompressData and TcxCustomBitmap(Mask).CompressData;
end;

function TcxImageInfoItem.GetImage: TBitmap;
begin
  Result := FImageInfo.Image;
end;

function TcxImageInfoItem.GetMask: TBitmap;
begin
  Result := FImageInfo.Mask;
end;

function TcxImageInfoItem.GetMaskColor: TColor;
begin
  Result := FImageInfo.MaskColor;
end;

procedure TcxImageInfoItem.SetCompressData(Value: Boolean);
begin
  if CompressData <> Value then
  begin
    TcxCustomBitmap(Image).CompressData := Value;
    TcxCustomBitmap(Mask).CompressData := Value;
  end;
end;

procedure TcxImageInfoItem.SetImage(Value: TBitmap);
begin
  FImageInfo.Image := Value;
end;

procedure TcxImageInfoItem.SetMask(Value: TBitmap);
begin
  FImageInfo.Mask := Value;
end;

procedure TcxImageInfoItem.SetMaskColor(Value: TColor);
begin
  FImageInfo.MaskColor := Value;
end;

constructor TcxImageInfoCollection.Create(AImageList: TcxImageList);
begin
  inherited Create(TcxImageInfoItem);
  FImageList := AImageList;
end;

function TcxImageInfoCollection.Add(AImage, AMask: TBitmap; AMaskColor: TColor = clNone): TCollectionItem;
begin
  Result := TcxImageInfoItem.Create(Self, AImage, AMask, AMaskColor);
end;

procedure TcxImageInfoCollection.Move(ACurrentIndex, ANewIndex: Integer);
begin
  Items[ACurrentIndex].Index := ANewIndex;
end;

procedure TcxImageInfoCollection.Delete(AIndex: Integer);
begin
  if AIndex = -1 then
    Clear
  else
    inherited Delete(AIndex);
end;

function TcxImageInfoCollection.GetOwner: TPersistent;
begin
  Result := FImageList;
end;

procedure TcxImageInfoCollection.SetCompressData(Value: Boolean);
var
  I: Integer;
begin
  if CompressData <> Value then
  begin
    FCompressData := Value;
    for I := 0 to Count - 1 do
      TcxImageInfoItem(Items[I]).CompressData := Value;
  end;
end;

procedure cxCopyBitmap(ADestBitmap, ASrcBitmap: TBitmap); overload;
begin
  cxDrawBitmap(ADestBitmap.Canvas.Handle, ASrcBitmap,
    Rect(0, 0, ADestBitmap.Width, ADestBitmap.Height), cxNullPoint);
  TBitmapAccess(ADestBitmap).Changed(ADestBitmap);
end;

function cxCloneBitmap(ABitmap: TBitmap): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Assign(ABitmap);
end;

function cxCopyImage(ASrcHandle: THandle): HBITMAP; overload;

  function SystemCopyImage: HBITMAP;
  begin
    Result := CopyImage(ASrcHandle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
  end;

  function SoftwareCopyImage: HBITMAP;
  var
    ABitmapData: Windows.TBitmap;
    AInfo: TBitmapInfo;
    ADestinationBits: Pointer;
    ABits: TBytes;
  begin
    cxGetBitmapData(ASrcHandle, ABitmapData);
    if ABitmapData.bmBitsPixel = 32 then
    begin
      FillBitmapInfoHeader(AInfo.bmiHeader, ABitmapData.bmWidth, ABitmapData.bmHeight, False);
      if ABitmapData.bmBits = nil then
      begin
        SetLength(ABits, ABitmapData.bmWidth * ABitmapData.bmHeight * 4);
        GetDIBits(cxScreenCanvas.Handle, ASrcHandle, 0, ABitmapData.bmHeight, ABits, AInfo, 0);
        ABitmapData.bmBits := ABits;
      end;
      Result := CreateDIBSection(cxScreenCanvas.Handle, AInfo, DIB_RGB_COLORS, ADestinationBits, 0, 0);
      cxCopyData(ABitmapData.bmBits, ADestinationBits, ABitmapData.bmWidth * ABitmapData.bmHeight * 4);
    end
    else
      Result := SystemCopyImage;
  end;

begin
  if IsWin9X then
    Result := SoftwareCopyImage
  else
    Result := SystemCopyImage;
end;

function IsImageListsEqual(AImages1, AImages2: TCustomImageList): Boolean;
var
  AStream1, AStream2: TMemoryStream;
  AnAdapter1, AnAdapter2: TStreamAdapter;
begin
  if AImages1.Count <> AImages2.Count then
    Result := False
  else
    if AImages1.Count = 0 then
      Result := True
    else
    begin
      AStream1 := TMemoryStream.Create;
      AStream2 := TMemoryStream.Create;
      AnAdapter1 := TStreamAdapter.Create(AStream1);
      AnAdapter2 := TStreamAdapter.Create(AStream2);
      try
        ImageList_Write(AImages1.Handle, AnAdapter1);
        ImageList_Write(AImages2.Handle, AnAdapter2);
        Result := (AStream1.Size = AStream2.Size) and CompareMem(AStream1.Memory, AStream2.Memory, AStream1.Size);
      finally
        AnAdapter2.Free;
        AnAdapter1.Free;
        AStream2.Free;
        AStream1.Free;
      end;
    end;
end;

function GetImageCount(ABitmap: TBitmap; AWidth, AHeight: Integer): Integer;
begin
  if (ABitmap.Width mod AWidth) + (ABitmap.Height mod AHeight) = 0 then
    Result := (ABitmap.Width div AWidth) * (ABitmap.Height div AHeight)
  else
    Result := 1;
end;

destructor TcxImageList.Destroy;
begin
  Finalize;
  inherited;
end;

procedure TcxImageList.Assign(Source: TPersistent);
var
  AImages: TCustomImageList;
begin
  if Source is TCustomImageList then
  begin
    BeginUpdate;
    try
      inherited;
      Clear;
      AImages := TCustomImageList(Source);
      if AImages is TcxImageList then
        InternalCopyImageInfos(TcxImageList(AImages), 0, AImages.Count - 1)
      else
        InternalCopyImages(AImages, 0, AImages.Count - 1);
    finally
      EndUpdate;
    end;
  end;
end;

function TcxImageList.Add(AImage, AMask: TBitmap): Integer;
var
  AImageHandle, AMaskHandle: HBITMAP;
  AMaskBits: TBytes;
begin
  AImageHandle := GetImageHandle(AImage);
  if AMask = nil then
  begin
    SetLength(AMaskBits, AImage.Width * AImage.Height);
    AMaskHandle := CreateBitmap(Width, Height, 1, 1, AMaskBits);
  end
  else
    AMaskHandle := AMask.Handle;
  Result := ImageList_Add(Handle, AImageHandle, AMaskHandle);
  if NeedSynchronizeImageInfo and (Result <> -1) then
    AddToInternalCollection(AImage, AMask);
  if AMask = nil then
    DeleteObject(AMaskHandle);
  Change;
end;

function TcxImageList.AddIcon(AIcon: TIcon): Integer;
var
  AImage, AMask: TBitmap;
begin
  BeginUpdate;
  try
    Result := inherited AddIcon(AIcon);
    if NeedSynchronizeImageInfo and (Result <> -1) then
    begin
      AImage := cxCreateBitmap(Width, Height, pf32bit);
      AMask := cxCreateBitmap(Width, Height, pf1bit);
      try
        GetImageInfo(Handle, Count - 1, AImage, AMask);
        AddToInternalCollection(AImage, AMask);
      finally
        AMask.Free;
        AImage.Free
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function TcxImageList.AddMasked(AImage: TBitmap; AMaskColor: TColor): Integer;
var
  ACloneImage: TBitmap;
begin
  BeginUpdate;
  try
    if AMaskColor = clNone then
      Result := Add(AImage, nil)
    else
    begin
      ACloneImage := cxCloneBitmap(AImage);
      try
        Result := ImageList_AddMasked(Handle, ACloneImage.Handle, ColorToRGB(AMaskColor));
      finally
        ACloneImage.Free;
      end;
      if NeedSynchronizeImageInfo and (Result <> -1) then
        AddToInternalCollection(AImage, nil, AMaskColor);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.Move(ACurIndex, ANewIndex: Integer);
var
  AStep, AIndex: Integer;
begin
  BeginUpdate;
  try
    AStep := cxSign(ANewIndex - ACurIndex);
    AIndex := ACurIndex;
    while AIndex <> ANewIndex do
    begin
      ImageList_Copy(Handle, AIndex + AStep, Handle, AIndex, ILCF_SWAP);
      Inc(AIndex, AStep);
    end;
    if NeedSynchronizeImageInfo then
      TcxImageInfoCollection(FImages).Move(ACurIndex, ANewIndex);
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.Delete(AIndex: Integer);
begin
  BeginUpdate;
  try
    inherited;
    if NeedSynchronizeImageInfo then
      TcxImageInfoCollection(FImages).Delete(AIndex);
  finally
    EndUpdate;
  end;
end;

function TcxImageList.AddImage(AValue: TCustomImageList; AIndex: Integer): Integer;
begin
  if (AValue <> nil) and (AIndex < AValue.Count) then
  begin
    Result := Count;
    CopyImages(AValue, AIndex, AIndex);
  end
  else
    Result := -1;
end;

procedure TcxImageList.AddImages(AImageList: TCustomImageList);
begin
  if AImageList <> nil then
  begin
    BeginUpdate;
    try
      CopyImages(AImageList);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxImageList.CopyImages(AImageList: TCustomImageList; AStartIndex, AEndIndex: Integer);
var
  AcxImageList: TcxImageList;
begin
  BeginUpdate;
  try
    AcxImageList := TcxImageList.Create(nil);
    try
      AcxImageList.Assign(AImageList);
      if AEndIndex < 0 then
        AEndIndex := AImageList.Count - 1
      else
        AEndIndex := Min(AImageList.Count - 1, AEndIndex);
      InternalCopyImageInfos(AcxImageList, AStartIndex, AEndIndex);
    finally
      AcxImageList.Free;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.Clear;
begin
  Delete(-1);
end;

procedure TcxImageList.Insert(AIndex: Integer; AImage, AMask: TBitmap);
var
  I, ACurIndex: Integer;
begin
  if (AIndex >= 0) and (AIndex <= Count) then
  begin
    BeginUpdate;
    try
      ACurIndex := Add(AImage, AMask);
      for I := 0 to GetImageCount(AImage, Width, Height) - 1 do
        Move(ACurIndex + I, AIndex + I);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxImageList.InsertIcon(AIndex: Integer; AIcon: TIcon);
begin
  if (AIndex >= 0) and (AIndex <= Count) then
  begin
    BeginUpdate;
    try
      Move(AddIcon(AIcon), AIndex);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxImageList.InsertMasked(AIndex: Integer; AImage: TBitmap; AMaskColor: TColor);
var
  I, ACurIndex: Integer;
begin
  if (AIndex >= 0) and (AIndex <= Count) then
  begin
    BeginUpdate;
    try
      ACurIndex := AddMasked(AImage, AMaskColor);
      for I := 0 to GetImageCount(AImage, Width, Height) - 1 do
        Move(ACurIndex + I, AIndex + I);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxImageList.Replace(AIndex: Integer; AImage, AMask: TBitmap);
begin
  BeginUpdate;
  try
    Delete(AIndex);
    Insert(AIndex, AImage, AMask);
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.ReplaceIcon(AIndex: Integer; AIcon: TIcon);
begin
  BeginUpdate;
  try
    Delete(AIndex);
    InsertIcon(AIndex, AIcon);
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.ReplaceMasked(AIndex: Integer; AImage: TBitmap; AMaskColor: TColor);
begin
  BeginUpdate;
  try
    Delete(AIndex);
    InsertMasked(AIndex, AImage, AMaskColor);
  finally
    EndUpdate;
  end;
end;

function TcxImageList.LoadImage(AInstance: THandle; const AResourceName: string;
  AMaskColor: TColor = clDefault; AWidth: Integer = 0; AFlags: TLoadResources = []): Boolean;
const
  AFlagMap: array [TLoadResource] of DWORD = (LR_DEFAULTCOLOR, LR_DEFAULTSIZE, LR_LOADFROMFILE,
    LR_LOADMAP3DCOLORS, LR_LOADTRANSPARENT, LR_MONOCHROME);
var
  I: TLoadResource;
  ALoadFlags: DWORD;
  AHandle: HImageList;
  ARGBColor: DWORD;
  AImageList: TImageList;
begin
  if AMaskColor = clNone then
    ARGBColor := CLR_NONE
  else
    if AMaskColor = clDefault then
      ARGBColor := CLR_DEFAULT
    else
      ARGBColor := ColorToRGB(AMaskColor);
  ALoadFlags := LR_CREATEDIBSECTION;
  for I := Low(TLoadResource) to High(TLoadResource) do
    if I in AFlags then
      ALoadFlags := ALoadFlags or AFlagMap[I];
  AHandle := ImageList_LoadImage(AInstance, PChar(AResourceName), AWidth, AllocBy, ARGBColor,
    IMAGE_BITMAP, ALoadFlags);
  Result := AHandle <> 0;
  if Result then
  begin
    AImageList := TImageList.Create(Self);
    try
      AImageList.Handle := AHandle;
      CopyImages(AImageList);
    finally
      AImageList.Free;
    end;
  end;
end;

function TcxImageList.GetResource(AResType: TResType; const AName: string;
  AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean;
begin
  Result := inherited GetResource(AResType, AName, AWidth, ALoadFlags, AMaskColor);
  SynchronizeImageInfo;
end;

function TcxImageList.GetInstRes(AInstance: THandle; AResType: TResType; const AName: string;
  AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean;
begin
  Result := inherited GetInstRes(AInstance, AResType, AName, AWidth, ALoadFlags, AMaskColor);
  SynchronizeImageInfo;
end;

function TcxImageList.GetInstRes(AInstance: THandle; AResType: TResType; AResID: DWORD;
  AWidth: Integer; ALoadFlags: TLoadResources; AMaskColor: TColor): Boolean;
begin
  Result := inherited GetInstRes(AInstance, AResType, AResID, AWidth, ALoadFlags, AMaskColor);
  SynchronizeImageInfo;
end;

function TcxImageList.ResourceLoad(AResType: TResType; const AName: string; AMaskColor: TColor): Boolean;
begin
  Result := inherited ResourceLoad(AResType, AName, AMaskColor);
  SynchronizeImageInfo;
end;

function TcxImageList.ResInstLoad(AInstance: THandle; AResType: TResType;
  const AName: string; AMaskColor: TColor): Boolean;
begin
  Result := inherited ResInstLoad(AInstance, AResType, AName, AMaskColor);
  SynchronizeImageInfo;
end;

procedure TcxImageList.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxImageList.EndUpdate(AForceUpdate: Boolean = True);
begin
  if FLockCount > 0 then
  begin
    Dec(FLockCount);
    if AForceUpdate then
      Change;
  end;
end;

{$IFNDEF DELPHI6}
procedure TcxImageList.Draw(ACanvas: TCanvas; X, Y, AIndex: Integer;
  ADrawingStyle: TDrawingStyle; AImageType: TImageType; AEnabled: Boolean);
begin
  if HandleAllocated then
    DoDraw(AIndex, ACanvas, X, Y, GetImageListStyle(ADrawingStyle, AImageType), AEnabled);
end;
{$ENDIF}

procedure TcxImageList.Draw(ACanvas: TCanvas; const ARect: TRect; AIndex: Integer;
  AStretch, ASmoothResize, AEnabled: Boolean);
begin
  DoDrawEx(AIndex, ACanvas, ARect, GetImageListStyle(DrawingStyle, ImageType), AStretch, ASmoothResize, AEnabled);
end;

procedure TcxImageList.GetImageInfo(AIndex: Integer; AImage, AMask: TBitmap);

  procedure GetBitmap(ADestBitmap, ASrcBitmap: TBitmap);
  begin
    ADestBitmap.Width := ASrcBitmap.Width;
    ADestBitmap.Height := ASrcBitmap.Height;
    cxCopyBitmap(ADestBitmap, ASrcBitmap);
  end;

var
  ASourceImage: TBitmap;
begin
  if (0 <= AIndex) and (AIndex < Count) then
  begin
    ASourceImage := TcxImageInfoItem(FImages.Items[AIndex]).ImageInfo.Image;
    if (ASourceImage.PixelFormat = pf32bit) or IsWin9X then
    begin
      if AImage <> nil then
        GetBitmap(AImage, ASourceImage);
      if AMask <> nil then
        GetBitmap(AMask, TcxImageInfoItem(FImages.Items[AIndex]).ImageInfo.Mask);
    end
    else
      GetImageInfo(Handle, AIndex, AImage, AMask);
    ASourceImage.Dormant;
  end;
end;

procedure TcxImageList.GetImage(AIndex: Integer; AImage: TBitmap);
begin
  GetImageInfo(AIndex, AImage, nil);
end;

procedure TcxImageList.GetMask(AIndex: Integer; AMask: TBitmap);
begin
  GetImageInfo(AIndex, nil, AMask);
end;

class procedure TcxImageList.GetImageInfo(AHandle: HIMAGELIST; AIndex: Integer; AImage, AMask: TBitmap);

  procedure GetBitmap(ASrcHandle: HBITMAP; ADestBitmap: TBitmap; ACopyAll: Boolean; const ARect: TRect);

    procedure CopyRect;
    var
      ASrcBitmap: TBitmap;
      AWidth, AHeight: Integer;
    begin
      ASrcBitmap := TBitmap.Create;
      try
        ASrcBitmap.Handle := cxCopyImage(ASrcHandle);
        AWidth := cxRectWidth(ARect);
        AHeight := cxRectHeight(ARect);
        ADestBitmap.Width := AWidth;
        ADestBitmap.Height := AHeight;
        cxBitBlt(ADestBitmap.Canvas.Handle, ASrcBitmap.Canvas.Handle,
          cxRect(0, 0, AWidth, AHeight), ARect.TopLeft, SRCCOPY);
        TBitmapAccess(ADestBitmap).Changed(ADestBitmap);
      finally
        ASrcBitmap.Free;
      end;
    end;

  begin
    if ACopyAll then
      ADestBitmap.Handle := cxCopyImage(ASrcHandle)
    else
      CopyRect;
  end;

var
  AImageInfo: TImageInfo;
  ACopyAll: Boolean;
begin
  ACopyAll := AIndex = -1;
  if ACopyAll then
    AIndex := 0;
  if ImageList_GetImageInfo(AHandle, AIndex, AImageInfo) then
  begin
    if AMask <> nil then
      GetBitmap(AImageInfo.hbmMask, AMask, ACopyAll, AImageInfo.rcImage);
    if AImage <> nil then
      GetBitmap(AImageInfo.hbmImage, AImage, ACopyAll, AImageInfo.rcImage);
    DeleteObject(AImageInfo.hbmImage);
    DeleteObject(AImageInfo.hbmMask);
  end;
end;

class function TcxImageList.GetPixelFormat(AHandle: HIMAGELIST): Integer;
var
  AImageInfo: TImageInfo;
  ABitmap: Windows.TBitmap;
begin
  Result := 0;
  if ImageList_GetImageInfo(AHandle, 0, AImageInfo) then
  begin
    cxGetBitmapData(AImageInfo.hbmImage, ABitmap);
    Result := ABitmap.bmBitsPixel;
    DeleteObject(AImageInfo.hbmImage);
    DeleteObject(AImageInfo.hbmMask);
  end;
end;

function TcxImageList.ChangeLocked: Boolean;
begin
  Result := FLockCount > 0;
end;

procedure TcxImageList.Change;
begin
  if not ChangeLocked then
    inherited Change;
end;

procedure TcxImageList.DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
  Style: Cardinal; Enabled: Boolean = True);
begin
  DoDrawEx(Index, Canvas, cxRectBounds(X, Y, Width, Height), Style, False, False, Enabled);
end;

procedure TcxImageList.DoDrawEx(AIndex: Integer; ACanvas: TCanvas;
  const ARect: TRect; AStyle: Cardinal; AStretch, ASmoothResize, AEnabled: Boolean);
const
  ADrawModes: array [Boolean] of TcxImageDrawMode = (idmDisabled, idmNormal);
var
  AGlyphRect: TRect;
  ADrawBitmap: TBitmap;
begin
  if AStretch then
    AGlyphRect := ARect
  else
    AGlyphRect := cxRectCenter(ARect, Width, Height);
  if AlphaBlending then
    cxDrawImage(ACanvas.Handle, AGlyphRect, ARect, nil, Self, AIndex, ADrawModes[AEnabled], ASmoothResize)
  else
  begin
    if AStretch then
    begin
      ADrawBitmap := cxCreateBitmap(Width, Height, pfDevice);
      try
        inherited DoDraw(AIndex, ADrawBitmap.Canvas, 0, 0, AStyle, AEnabled);
        cxDrawImage(ACanvas.Handle, AGlyphRect, ARect, ADrawBitmap, nil, 0, ADrawModes[AEnabled], ASmoothResize);
      finally
        ADrawBitmap.Free;
      end;
    end
    else
      inherited DoDraw(AIndex, ACanvas, AGlyphRect.Left, AGlyphRect.Top, AStyle, AEnabled);
  end;
end;

procedure TcxImageList.Initialize;
begin
  inherited;
  FImages := TcxImageInfoCollection.Create(Self);
  FAlphaBlending := True;
  inherited Handle := ImageList_Create(Width, Height, ILC_COLOR32 or ILC_MASK, AllocBy, AllocBy);
end;

procedure TcxImageList.Finalize;
begin
  FreeAndNil(FImages);
end;

const
  ADXILSignature: Integer = $494C4458; //DXIL
  ADXILVersion: Word = 1;

procedure TcxImageList.DefineProperties(Filer: TFiler);

  function DoWriteImageInfo: Boolean;
  begin
    if (Filer.Ancestor <> nil) and (Filer.Ancestor is TCustomImageList) then
      Result := not IsImageListsEqual(TCustomImageList(Filer.Ancestor), Self)
    else
      Result := Count > 0;
  end;

  function DoWriteDesignInfo: Boolean;
  begin
    Result := (Filer.Ancestor = nil) or not (Filer.Ancestor is TCustomImageList) or
      (TCustomImageList(Filer.Ancestor).DesignInfo <> DesignInfo);
  end;

var
  AOldSaveFormat: Boolean;
begin
{$IFDEF cxImageListOldSaveFormat}
  AOldSaveFormat := True;
{$ELSE}
  AOldSaveFormat := False;
{$ENDIF}

  Filer.DefineProperty('FormatVersion', ReadFormatVersion, WriteFormatVersion, not AOldSaveFormat);


  if (csReading in ComponentState) or AOldSaveFormat and (csWriting in ComponentState) then
  begin
    inherited;
    if csReading in ComponentState then
      SynchronizeImageInfo;
  end;

  Filer.DefineProperty('DesignInfo', ReadDesignInfo, WriteDesignInfo, not AOldSaveFormat and DoWriteDesignInfo);
  Filer.DefineProperty('ImageInfo', ReadImageInfo, WriteImageInfo, not AOldSaveFormat and DoWriteImageInfo);
end;

procedure TcxImageList.Dormant;
var
  I: Integer;
begin
  for I := 0 to FImages.Count - 1 do
    DormantImage(I);
end;

procedure TcxImageList.AddImageInfo(AImageInfo: TcxImageInfo);
begin
  if IsGlyphAssigned(AImageInfo.Mask) then
    Add(AImageInfo.Image, AImageInfo.Mask)
  else
    AddMasked(AImageInfo.Image, AImageInfo.MaskColor);
end;

procedure TcxImageList.InternalCopyImageInfos(AImageList: TcxImageList; AStartIndex, AEndIndex: Integer);
var
  I: Integer;
  AImageInfo: TcxImageInfo;
begin
  AImageInfo := TcxImageInfo.Create;
  try
    for I := Max(AStartIndex, 0) to AEndIndex do
    begin
      AImageList.GetImageInfo(I, AImageInfo);
      AddImageInfo(AImageInfo);
    end;
  finally
    AImageInfo.Free;
  end;
end;

procedure TcxImageList.InternalCopyImages(AImageList: TCustomImageList; AStartIndex, AEndIndex: Integer);
var
  I: Integer;
  AImage, AMask: TBitmap;
begin
  AImage := cxCreateBitmap(Width, Height, pf32bit);
  AMask := cxCreateBitmap(Width, Height, pf1bit);
  try
    for I := Max(AStartIndex, 0) to AEndIndex do
    begin
      GetImageInfo(AImageList.Handle, I, AImage, AMask);
      Add(AImage, AMask);
    end;
  finally
    AImage.Free;
    AMask.Free;
  end;
end;

procedure TcxImageList.GetImageInfo(AIndex: Integer; AImageInfo: TcxImageInfo);
begin
  if (0 <= AIndex) and (AIndex < Count) then
    AImageInfo.Assign(TcxImageInfoItem(FImages.Items[AIndex]).ImageInfo)
  else
  begin
    AImageInfo.Image := nil;
    AImageInfo.Mask := nil;
    AImageInfo.MaskColor := clNone;
  end;
end;

function TcxImageList.GetCompressData: Boolean;
begin
  Result := TcxImageInfoCollection(FImages).CompressData;
end;

procedure TcxImageList.SetCompressData(Value: Boolean);
begin
  TcxImageInfoCollection(FImages).CompressData := Value;
end;

function TcxImageList.GetHandle: HImageList;
begin
  Result := inherited Handle;
end;

procedure TcxImageList.SetHandle(Value: HImageList);
var
  AImageList: TCustomImageList;
begin
  AImageList := TCustomImageList.Create(Self);
  try
    AImageList.Handle := Value;
    Assign(AImageList);
    ImageList_Destroy(Value);
  finally
    AImageList.Free;
  end;
end;

procedure TcxImageList.ReadFormatVersion(AReader: TReader);
begin
  FFormatVersion := AReader.ReadInteger;
end;

procedure TcxImageList.WriteFormatVersion(AWriter: TWriter);
begin
  FFormatVersion := ADXILVersion;
  AWriter.WriteInteger(FFormatVersion);
end;

procedure TcxImageList.ReadImageInfo(AReader: TReader);
begin
  FImages.Clear;
  AReader.ReadValue;
  AReader.ReadCollection(FImages);
  SynchronizeHanle;
end;

procedure TcxImageList.WriteImageInfo(AWriter: TWriter);
begin
  AWriter.WriteCollection(FImages);
end;

procedure TcxImageList.ReadDesignInfo(AReader: TReader);
begin
  DesignInfo := AReader.ReadInteger;
end;

procedure TcxImageList.WriteDesignInfo(AWriter: TWriter);
begin
  AWriter.WriteInteger(DesignInfo);
end;

function TcxImageList.NeedSynchronizeImageInfo: Boolean;
begin
  Result := not FSynchronization; 
end;

procedure TcxImageList.SynchronizeImageInfo;
var
  I: Integer;
  AImage, AMask: TBitmap;
begin
  FImages.BeginUpdate;
  try
    FImages.Clear;
    AImage := cxCreateBitmap(Width, Height, pf32bit);
    AMask := cxCreateBitmap(Width, Height, pf1bit);
    try
      for I := 0 to Count - 1 do
      begin
        GetImageInfo(Handle, I, AImage, AMask);
        TcxImageInfoCollection(FImages).Add(AImage, AMask);
      end;
    finally
      AMask.Free;
      AImage.Free;
    end;
  finally
    FImages.EndUpdate;
  end;
end;

procedure TcxImageList.SynchronizeHanle;
var
  I: Integer;
  AImageInfoItem: TcxImageInfoItem;
begin
  BeginUpdate;
  try
    FSynchronization := True;
    try
      Clear;
      for I := 0 to FImages.Count - 1 do
      begin
        AImageInfoItem := TcxImageInfoItem(FImages.Items[I]);
        AddImageInfo(AImageInfoItem.ImageInfo);
        DormantImage(I);
      end;
    finally
      FSynchronization := False;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TcxImageList.AddToInternalCollection(AImage, AMask: TBitmap; AMaskColor: TColor);

  procedure InternalAddToInternalCollection(AImage, AMask: TBitmap; AMaskColor: TColor);
  var
    AItem: TCollectionItem;
  begin
    AItem := TcxImageInfoCollection(FImages).Add(AImage, AMask, AMaskColor);
    DormantImage(AItem.Index);
  end;
  
var
  AColCount, ARowCount, AColIndex, ARowIndex: Integer;
  ASourceRect: TRect;
  ADestBitmap, ADestMask: TcxCustomBitmap;
begin
  if (((AImage.Width mod Width) + (AImage.Height mod Height)) = 0) and
    ((AImage.Width <> Width) or (AImage.Height <> Height)) then
  begin
    AColCount := AImage.Width div Width;
    ARowCount := AImage.Height div Height;

    ADestBitmap := TcxCustomBitmap.CreateSize(Width, Height, AImage.PixelFormat);
    if IsGlyphAssigned(AMask) then
      ADestMask := TcxCustomBitmap.CreateSize(Width, Height, AMask.PixelFormat)
    else
      ADestMask := nil;
    try
      for ARowIndex := 0 to ARowCount - 1 do
        for AColIndex := 0 to AColCount - 1 do
        begin
          ASourceRect := Rect(AColIndex * Width, ARowIndex * Height, (AColIndex + 1) * Width, (ARowIndex + 1) * Height);
          ADestBitmap.Canvas.CopyRect(ADestBitmap.ClientRect, AImage.Canvas, ASourceRect);
          if IsGlyphAssigned(AMask) then
          begin
            ADestMask.Clear;
            ADestMask.Canvas.CopyRect(ADestMask.ClientRect, AMask.Canvas, ASourceRect);
          end;
          InternalAddToInternalCollection(ADestBitmap, ADestMask, AMaskColor);
        end;
    finally
      ADestMask.Free;
      ADestBitmap.Free;
    end;
  end
  else
    InternalAddToInternalCollection(AImage, AMask, AMaskColor);
end;

procedure TcxImageList.DormantImage(AIndex: Integer);
begin
  TcxImageInfoItem(FImages.Items[AIndex]).ImageInfo.Image.Dormant;
end;

function TcxImageList.GetImageHandle(AImage: TBitmap): Integer;
begin
  if AImage <> nil then
    Result := AImage.Handle
  else
    Result := 0;
end;

const
  SystemBrushes: TList = nil;
  SysColorPrefix = {$IFDEF DELPHI7} clSystemColor {$ELSE} $80000000 {$ENDIF};
  BrushDataSize = SizeOf(TcxBrushData);
  scxBrushCacheReleaseUnusedBrush = 'Release unused brush';

destructor TcxBrushCache.Destroy;
var
  I: Integer;
begin
  try
    for I := 0 to FCount - 1 do
      FData[I].Brush.Free;
  finally
    inherited Destroy;
  end;
end;

procedure TcxBrushCache.BeginUpdate;
begin
  Inc(FLockRef);
end;

procedure TcxBrushCache.EndUpdate;
begin
  Inc(FLockRef);
  if (FLockRef = 0) and (FDeletedCount <> 0) then Pack;
end;

procedure TcxBrushCache.ReleaseBrush(var ABrush: TBrush);
var
  AIndex: Integer;
begin
  if ABrush <> nil then
  begin
    if not IsSystemBrush(ABrush) and IndexOf(ABrush.Color, AIndex) then
    begin
      with FData[AIndex] do
      begin
        Dec(RefCount);
        CacheCheck(RefCount < 0, scxBrushCacheReleaseUnusedBrush);
        if RefCount <= 0 then Delete(AIndex);
      end;
    end;
  end; 
end;

procedure TcxBrushCache.SetBrushColor(var ABrush: TBrush; AColor: TColor);
begin
  ReleaseBrush(ABrush);
  ABrush := Add(AColor);
end;

function TcxBrushCache.Add(AColor: TColor): TBrush;
begin
  if AColor and SysColorPrefix <> 0 then
    Result := TBrush(SystemBrushes[AColor and not SysColorPrefix])
  else
    Result := AddItemAt(FindNearestItem(AColor), AColor);
  Result.Color := AColor; 
end;

function TcxBrushCache.AddItemAt(AIndex: Integer; AColor: TColor): TBrush;
var
  Delta: Integer;
begin
  if (AIndex >= FCount) or (FData[AIndex].Color <> AColor) then
  begin
    if FCapacity <= FCount then
    begin
      Delta := FCapacity shr 2;
      if Delta < 8 then Delta := 8;
      Inc(FCapacity, Delta);
      SetLength(FData, FCapacity);
    end;
    if AIndex < FCount then Move(AIndex, AIndex + 1, FCount - AIndex);
    InitItem(FData[AIndex], AColor);
    Inc(FCount);
  end
  else
    if FData[AIndex].RefCount = 0 then Dec(FDeletedCount);
  Inc(FData[AIndex].RefCount);
  Result := FData[AIndex].Brush;
end;

procedure TcxBrushCache.CacheCheck(Value: Boolean; const AMessage: string);
begin
  if Value then
    raise EBrushCache.Create(AMessage);
end;

procedure TcxBrushCache.Delete(AIndex: Integer);
begin
  if FLockRef = 0 then
  begin
    FData[AIndex].Brush.Free;
    Dec(FCount);
    if AIndex < FCount then
      Move(AIndex + 1, AIndex, FCount - AIndex);
  end
  else
    Inc(FDeletedCount);
end;

function TcxBrushCache.IndexOf(AColor: TColor; out AIndex: Integer): Boolean;
begin
  AIndex := -1;
  if (AColor and SysColorPrefix = 0) then
    AIndex := FindNearestItem(AColor);
  Result := (AIndex >= 0) and (AIndex < FCount) and (FData[AIndex].Color = AColor);
end;

procedure TcxBrushCache.InitItem(var AItem: TcxBrushData; AColor: TColor);
begin
  FillChar(AItem, BrushDataSize, 0);
  AItem.Brush := TBrush.Create;
  AItem.Brush.Color := AColor;
end;

function TcxBrushCache.IsSystemBrush(ABrush: TBrush): Boolean;
begin
  Result := ABrush = nil;
  Result := Result or ((ABrush.Color and SysColorPrefix) <> 0);
end;

function TcxBrushCache.FindNearestItem(AColor: TColor): Integer;

  function Check(Min, Max: Integer): Integer;
  begin
    Result := Max;
    if AColor <= FData[Min].Color then
      Result := Min
    else
      if AColor > FData[Max].Color then
        AColor := Max + 1;
  end;

var
  A, B, C: Integer;
begin
  if FCount > 0 then
  begin
    A := 0;
    B := FCount - 1;
    if (FData[0].Color >= AColor) or (FData[B].Color <= AColor) then
      Result := Check(A, B)
    else
    begin
      while A < B do
      begin
        C := (A + B) shr 1;
        with FData[C] do
        begin
          if Color < AColor then
            A := C
          else
            if Color > AColor then
              B := C
            else
              B := A;
        end;
      end;
      Result := Check(A, B);
    end;
  end
  else
    Result := 0;
end;

procedure TcxBrushCache.Move(ASrc, ADst, ACount: Integer);
begin
  System.Move(FData[ASrc], FData[ADst], ACount * BrushDataSize);
end;

procedure TcxBrushCache.Pack;
var
  I, ACount: Integer;
begin
  try
    ACount := 0;
    I := FCount - 1;
    while (ACount < FDeletedCount) and (I >= 0) do
    begin
      if FData[I].RefCount < 0 then
      begin
        Delete(I);
        Inc(ACount);
      end;
      Dec(I);
    end;
  finally
    FDeletedCount := 0;
  end;
end;

procedure TcxBrushCache.Recreate;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    with FData[I] do Brush.Color := Color;
end;

procedure TcxBrushCache.Release(AIndex: Integer);
begin
  Dec(FData[AIndex].RefCount);
  if FData[AIndex].RefCount = 0 then Delete(AIndex);
end;

procedure InitSystemBrushes;
var
  I: Word;
  ABrush: TBrush;
begin
  SystemBrushes := TList.Create;
  for I := COLOR_SCROLLBAR to COLOR_ENDCOLORS do
  begin
    ABrush := TBrush.Create;
    ABrush.Handle := GetSysColorBrush(I);
    SystemBrushes.Add(ABrush);
  end;
end;

procedure DestroySystemBrushes;
var
  I: Integer;
begin
  try
    for I := 0 to SystemBrushes.Count - 1 do
      TBrush(SystemBrushes[I]).Free;
  finally
    SystemBrushes.Free;
  end;
end;

procedure InitPredefinedBrushes;
var
  ABitmap:  HBitmap ;
const
  APattern: array[0..7] of Word =
    ($00AA, $0055, $00AA, $0055, $00AA, $0055, $00AA, $0055);
begin
  cxHalfToneBrush := TBrush.Create;
  InitSystemBrushes;
  ABitmap := CreateBitmap(8, 8, 1, 1, @APattern);
  cxHalfToneBrush.Handle := CreatePatternBrush(ABitmap);
  DeleteObject(ABitmap);
end;

procedure DestroyPredefinedBrushes;
begin
  DestroySystemBrushes;
{$IFDEF DELPHI9}
{$IFNDEF DELPHI10}
  cxHalfToneBrush.Bitmap.Free;
{$ENDIF}
{$ENDIF}
  cxHalfToneBrush.Free;
end;

var
  ALib: Integer;

initialization
  InitPredefinedBrushes;
  ALib := LoadLibrary('msimg32.dll');
  if ALib <> 0 then
    VCLAlphaBlend := GetProcAddress(ALib, 'AlphaBlend')
  else
    VCLAlphaBlend := nil;

finalization
  if ALib <> 0 then FreeLibrary(ALib);
  DestroyPredefinedBrushes;
  FreeAndNil(ScreenCanvas);
  FreeAndNil(MaskBitmap);
  FreeAndNil(ImageBitmap);
  FreeAndNil(DrawBitmap);

end.
