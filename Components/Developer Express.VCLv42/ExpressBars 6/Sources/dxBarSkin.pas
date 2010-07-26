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

unit dxBarSkin;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, ExtCtrls, dxCore, cxGraphics, dxGDIPlusAPI;

type
  TcxSkinRectType = (spt1x1, spt3x1, spt1x3, spt3x3);

  TdxCustomBarSkin = class;

  { TdxSkinnedRect }

  TdxSkin3x3Part = (
    sp3x3TopLeft,    sp3x3Top,    sp3x3TopRight,
    sp3x3Left,       sp3x3Center, sp3x3Right,
    sp3x3BottomLeft, sp3x3Bottom, sp3x3BottomRight
  );

  { TdxSkinnedRect }

  TdxSkinnedRect = class
  private
    FAlphaValue: Byte;
    FCalculatedSize: TSize;
    FDrawPartSizes: array[TdxSkin3x3Part] of TSize;
    FFixedPartSize: TRect;
    FGPImage: GpBitmap;
    FGPCacheBitmap: GpBitmap;
    FID: Integer;
    FInterpolationMode: Integer;
    FLastSize: TSize;
    FMinSize: TSize;
    FName: string;
    FOpaque: Boolean;
    FOwner: TdxCustomBarSkin;
    FPartBounds: array[TdxSkin3x3Part] of TRect;
    FTextOffset: TRect;
    procedure CalculatePartBounds(const ARect: TRect);
    procedure CheckCachedImage;
    procedure CheckCalculate(AWidth, AHeight: Integer);
    procedure UpdateCacheImage;
    procedure UpdateSizes;
  protected
    procedure Calculate(AWidth, AHeight: Integer); virtual;
    procedure Clear; virtual;
    procedure DefaultDraw(DC: HDC; const R: TRect); virtual;
    procedure DoDraw(DC: HDC; const R: TRect); virtual;

    property CalculatedSize: TSize read FCalculatedSize;
  public
    constructor Create(AOpaque: Boolean = False);
    destructor Destroy; override;
    procedure Draw(DC: HDC; const R: TRect; AlphaValue: Byte = 255);
    function GetBitmap(const AWidth, AHeight: Integer; AUseAlphaChannel: Boolean = False): TBitmap;
    function GetTextBounds(const R: TRect): TRect; virtual;
    procedure LoadFromBitmap(ABitmap: GpBitmap; const ARect, AFixedPartSize: TRect);
    procedure LoadFromFile(const AFileName: string; const AFixedPartSize: TRect); overload;
    procedure LoadFromFile(const AFileName: string; const ARect, AFixedPartSize: TRect); overload;

    property AlphaValue: Byte read FAlphaValue write FAlphaValue default 255;
    property ID: Integer read FID write FID;
    property InterpolationMode: Integer read FInterpolationMode write FInterpolationMode
      default InterpolationModeDefault;
    property MinSize: TSize read FMinSize write FMinSize;
    property Name: string read FName write FName;
    property Opaque: Boolean read FOpaque write FOpaque;
    property Owner: TdxCustomBarSkin read FOwner;
    property TextOffset: TRect read FTextOffset write FTextOffset;
  end;

  { TdxCustomBarSkin }

  TdxCustomBarSkin = class(TList)
  private
    FName: string;
    function GetPart(Index: Integer): TdxSkinnedRect;
  protected
    function IsPersistent: Boolean; virtual;
  public
    constructor Create(const AName: string);
    procedure Clear; override;
    function Add(ASkinnedRect: TdxSkinnedRect): Integer;
    function AddPart1x1(ABitmap: GpBitmap; const R: TRect; AID: Integer;
      const AName: string = ''; AInterpolationMode: Integer = InterpolationModeDefault): Integer;
    function AddPart1x3(ABitmap: GpBitmap; const R: TRect; ATop, ABottom, AID: Integer;
      const AName: string = ''; AInterpolationMode: Integer = InterpolationModeDefault): Integer;
    function AddPart3x3(ABitmap: GpBitmap; const R, AFixedSize: TRect;
      AID: Integer; const AName: string = ''; AInterpolationMode: Integer = InterpolationModeDefault): Integer;
    function PartByName(const AName: string): TdxSkinnedRect;
    function PartByID(const AID: Integer): TdxSkinnedRect;
    property Name: string read FName write FName;
    property Parts[Index: Integer]: TdxSkinnedRect read GetPart; default;
  end;

  { TcxSkinManager }

  TdxBarSkinManager = class(TPersistent)
  private
    FList: TList;
    function GetSkin(Index: Integer): TdxCustomBarSkin;
    function GetSkinCount: Integer;
  protected
    function CanDeleteSkin(ASkin: TdxCustomBarSkin): Boolean;
    procedure Changed; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function AddSkin(ASkin: TdxCustomBarSkin): Integer;
    function RemoveSkin(ASkin: TdxCustomBarSkin): Boolean;
    function SkinByName(const AName: string): TdxCustomBarSkin;
    property SkinCount: Integer read GetSkinCount;
    property Skins[Index: Integer]: TdxCustomBarSkin read GetSkin; default;
  end;

function SkinManager: TdxBarSkinManager;
function GetImageFromStream(AStream: TStream): GPImage;

implementation

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}  
  cxGeometry, dxOffice11, cxControls, dxBar, cxDWMApi, ActiveX;

var
  FSkinManager: TdxBarSkinManager;

function SkinManager: TdxBarSkinManager;
begin
  if FSkinManager = nil then
    FSkinManager := TdxBarSkinManager.Create;
  Result := FSkinManager;
end;

function GetImageFromStream(AStream: TStream): GPImage;
var
  Data: HGlobal;
  DataPtr: Pointer;
  AccessStream: IStream;
begin
  Result := nil;
  if not CheckGdiPlus then Exit;
  Data := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, AStream.Size);
  try
    DataPtr := GlobalLock(Data);
    try
      AStream.Read(DataPtr^, AStream.Size);
      GdipCheck(CreateStreamOnHGlobal(Data, False, AccessStream) = s_OK);
      GdipCheck(GdipCreateBitmapFromStream(AccessStream, Result));
    finally
      GlobalUnlock(Data);
      AccessStream := nil;
    end;
  finally
    GlobalFree(Data);
  end;
end;

function dxAlphaBlend(ADestDC: HDC; const ADestRect: TRect; ASrcDC: HDC; const ASrcRect: TRect;
  AlphaValue: Byte = 255): Boolean;
begin
  if IsWin9X then
  begin
    Result := True;
    cxAlphaBlend(ADestDC, ASrcDC, ADestRect, ASrcRect, False, AlphaValue);
  end
  else
    Result := SystemAlphaBlend(ADestDC, ASrcDC, ADestRect, ASrcRect, AlphaValue);
end;

{ TdxSkinnedRect }

constructor TdxSkinnedRect.Create(AOpaque: Boolean = False);
begin
  FAlphaValue := 255;
  FID := -1;
  FOpaque := AOpaque;
  FTextOffset := cxRect(8, 8, 8, 8);
  FInterpolationMode := InterpolationModeDefault;
end;

destructor TdxSkinnedRect.Destroy;
begin
  if FGPImage <> nil then
    GdipDisposeImage(FGPImage);
  if FGPCacheBitmap <> nil then
    GdipDisposeImage(FGPCacheBitmap);
  inherited Destroy;
end;

procedure TdxSkinnedRect.Calculate(AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  if (FFixedPartSize.Left + FFixedPartSize.Right) >= AWidth then
  begin
    W := AWidth div 2;
    FDrawPartSizes[sp3x3TopLeft].cx := W;
    FDrawPartSizes[sp3x3BottomLeft].cx := W;
    FDrawPartSizes[sp3x3Left].cx := W;
    W := AWidth - W;
    FDrawPartSizes[sp3x3TopRight].cx := W;
    FDrawPartSizes[sp3x3BottomRight].cx := W;
    FDrawPartSizes[sp3x3Right].cx := W;
    //don't draw
    FDrawPartSizes[sp3x3Center].cx := 0;
    FDrawPartSizes[sp3x3Top].cx := 0;
    FDrawPartSizes[sp3x3Bottom].cx := 0;
  end
  else
  begin
    FDrawPartSizes[sp3x3TopLeft].cx := FFixedPartSize.Left;
    FDrawPartSizes[sp3x3Left].cx := FFixedPartSize.Left;
    FDrawPartSizes[sp3x3BottomLeft].cx := FFixedPartSize.Left;
    FDrawPartSizes[sp3x3TopRight].cx := FFixedPartSize.Right;
    FDrawPartSizes[sp3x3Right].cx := FFixedPartSize.Right;
    FDrawPartSizes[sp3x3BottomRight].cx := FFixedPartSize.Right;
    FDrawPartSizes[sp3x3Center].cx := AWidth - (FFixedPartSize.Right + FFixedPartSize.Left);
    FDrawPartSizes[sp3x3Top].cx := FDrawPartSizes[sp3x3Center].cx;
    FDrawPartSizes[sp3x3Bottom].cx := FDrawPartSizes[sp3x3Center].cx;
  end;
  if (FFixedPartSize.Top + FFixedPartSize.Bottom) >= AHeight then
  begin
    H := AHeight div 2;
    FDrawPartSizes[sp3x3TopLeft].cy := H;
    FDrawPartSizes[sp3x3TopRight].cy := H;
    FDrawPartSizes[sp3x3Top].cy := H;
    H := AHeight - H;
    FDrawPartSizes[sp3x3BottomLeft].cy := H;
    FDrawPartSizes[sp3x3BottomRight].cy := H;
    FDrawPartSizes[sp3x3Bottom].cy := H;
    //don't draw
    FDrawPartSizes[sp3x3Center].cy := 0;
    FDrawPartSizes[sp3x3Left].cy := 0;
    FDrawPartSizes[sp3x3Right].cy := 0;
  end
  else
  begin
    FDrawPartSizes[sp3x3TopLeft].cy := FFixedPartSize.Top;
    FDrawPartSizes[sp3x3Top].cy := FFixedPartSize.Top;
    FDrawPartSizes[sp3x3TopRight].cy := FFixedPartSize.Top;
    FDrawPartSizes[sp3x3BottomLeft].cy := FFixedPartSize.Bottom;
    FDrawPartSizes[sp3x3Bottom].cy := FFixedPartSize.Bottom;
    FDrawPartSizes[sp3x3BottomRight].cy := FFixedPartSize.Bottom;
    FDrawPartSizes[sp3x3Center].cy := AHeight - (FFixedPartSize.Bottom + FFixedPartSize.Top);
    FDrawPartSizes[sp3x3Left].cy := FDrawPartSizes[sp3x3Center].cy;
    FDrawPartSizes[sp3x3Right].cy := FDrawPartSizes[sp3x3Center].cy;
  end;
end;

procedure TdxSkinnedRect.Clear;
begin
  FCalculatedSize := cxNullSize;
end;

procedure TdxSkinnedRect.DefaultDraw(DC: HDC; const R: TRect);
begin
  FillRectByColor(DC, R, clBtnFace);
end;

procedure TdxSkinnedRect.DoDraw(DC: HDC; const R: TRect);
var
  H, OldBitmap: HBITMAP;
  BDC: HDC;
begin
  CheckCachedImage;
  GdipCreateHBITMAPFromBitmap(FGPCacheBitmap, H, 0);
  BDC := CreateCompatibleDC(DC);
  OldBitmap := SelectObject(BDC, H);
  if not FOpaque and not dxAlphaBlend(DC, R, BDC, cxRect(0, 0, CalculatedSize.cx, CalculatedSize.cy), AlphaValue) then
    cxBitBlt(DC, BDC, R, cxPoint(0, 0), srccopy);
  SelectObject(BDC, OldBitmap);
  DeleteDC(BDC);
  DeleteObject(H);
end;

procedure TdxSkinnedRect.Draw(DC: HDC; const R: TRect; AlphaValue: Byte = 255);
begin
  FAlphaValue := AlphaValue;
  if (R.Right - R.Left <= 0) or (R.Bottom - R.Top <= 0) then Exit;
  CheckCalculate(R.Right - R.Left, R.Bottom - R.Top);
  if RectVisible(DC, R) then
    DoDraw(DC, R)
end;

function TdxSkinnedRect.GetBitmap(const AWidth, AHeight: Integer;
  AUseAlphaChannel: Boolean = False): TBitmap;
begin
  Result := TcxBitmap.CreateSize(AWidth, AHeight);;
  if AUseAlphaChannel then
    Result.PixelFormat := pf32bit;
  Draw(Result.Canvas.Handle, cxRect(0, 0, AWidth, AHeight));
  if AUseAlphaChannel then
    TcxBitmap(Result).RecoverAlphaChannel(clFuchsia);
end;

function TdxSkinnedRect.GetTextBounds(const R: TRect): TRect;
begin
  Result := R;
  Inc(Result.Left, FTextOffset.Left);
  Inc(Result.Top, FTextOffset.Top);
  Dec(Result.Right, FTextOffset.Right);
  Dec(Result.Bottom, FTextOffset.Bottom);
end;

procedure TdxSkinnedRect.LoadFromBitmap(ABitmap: GpBitmap;
  const ARect, AFixedPartSize: TRect);
var
  G: GpGraphics;
begin
  Clear;
  GdipCheck(GdipCreateBitmapFromScan0(ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    0, PixelFormat32bppPARGB, nil, FGPImage));
  GdipCheck(GdipGetImageGraphicsContext(FGPImage, G));
  GdipCheck(GdipSetInterpolationMode(G, InterpolationModeNearestNeighbor));
  GdipCheck(GdipSetCompositingMode(G, CompositingModeSourceCopy));
  GdipCheck(GdipDrawImageRectRectI(G, ABitmap, 0, 0, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, UnitPixel, nil, nil, nil));
  GdipCheck(GdipDeleteGraphics(G));
  FFixedPartSize := AFixedPartSize;
  CalculatePartBounds(ARect);
  UpdateSizes;
end;

procedure TdxSkinnedRect.LoadFromFile(const AFileName: string;
  const AFixedPartSize: TRect);
var
  ARect: TRect;
begin
  Clear;
  FFixedPartSize := AFixedPartSize;
  ARect.Left := 0;
  ARect.Top := 0;
  GdipCheck(GdipLoadImageFromFile(PWideChar(WideString(AFileName)), FGPImage));
  GdipCheck(GdipGetImageWidth(FGPImage, ARect.Right));
  GdipCheck(GdipGetImageHeight(FGPImage, ARect.Bottom));
  CalculatePartBounds(ARect);
  UpdateSizes;
end;

procedure TdxSkinnedRect.LoadFromFile(const AFileName: string;
  const ARect, AFixedPartSize: TRect);
var
  B: GpBitmap;
  G: GpGraphics;
begin
  Clear;
  FFixedPartSize := AFixedPartSize;
  GdipCheck(GdipLoadImageFromFile(PWideChar(WideString(AFileName)), B));
  GdipCheck(GdipCreateBitmapFromScan0(ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    0, PixelFormat32bppPARGB, nil, FGPImage));
  GdipCheck(GdipGetImageGraphicsContext(FGPImage, G));
  GdipCheck(GdipDrawImageRectRectI(G, B, 0, 0, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, UnitPixel, nil, nil, nil));
  GdipCheck(GdipDeleteGraphics(G));
  GdipCheck(GdipDisposeImage(B));
  CalculatePartBounds(ARect);
  UpdateSizes;
end;

procedure TdxSkinnedRect.CalculatePartBounds(const ARect: TRect);
var
  I: TdxSkin3x3Part;
  R: TRect;
begin
  for I := sp3x3TopLeft to sp3x3BottomRight do
  begin
    case I of
      sp3x3TopLeft:
        R := cxRectBounds(ARect.Left, ARect.Top,
          FFixedPartSize.Left, FFixedPartSize.Top);
      sp3x3Top:
        R := cxRect(ARect.Left + FFixedPartSize.Left, ARect.Top,
          ARect.Right - FFixedPartSize.Right, ARect.Top + FFixedPartSize.Top);
      sp3x3TopRight:
        R := cxRect(ARect.Right - FFixedPartSize.Right, ARect.Top, ARect.Right,
          ARect.Top + FFixedPartSize.Top);
      sp3x3Left:
        R := cxRect(ARect.Left, ARect.Top + FFixedPartSize.Top,
          ARect.Left + FFixedPartSize.Left, ARect.Bottom - FFixedPartSize.Bottom);
      sp3x3Center:
        R := cxRect(ARect.Left + FFixedPartSize.Left, ARect.Top + FFixedPartSize.Top,
          ARect.Right - FFixedPartSize.Right, ARect.Bottom - FFixedPartSize.Bottom);
      sp3x3Right:
        R := cxRect(ARect.Right - FFixedPartSize.Right, ARect.Top + FFixedPartSize.Top,
          ARect.Right, ARect.Bottom - FFixedPartSize.Bottom);
      sp3x3BottomLeft:
        R := cxRect(ARect.Left, ARect.Bottom - FFixedPartSize.Bottom,
          ARect.Left + FFixedPartSize.Left, ARect.Bottom);
      sp3x3Bottom:
        R := cxRect(ARect.Left + FFixedPartSize.Left, ARect.Bottom - FFixedPartSize.Bottom,
          ARect.Right - FFixedPartSize.Right, ARect.Bottom);
    else
      R := cxRect(ARect.Right - FFixedPartSize.Right,
        ARect.Bottom - FFixedPartSize.Bottom, ARect.Right, ARect.Bottom);
    end;
    FPartBounds[I] := cxRectBounds(R.Left - ARect.Left, R.Top - ARect.Top,
      R.Right - R.Left, R.Bottom - R.Top);
  end;
end;

procedure TdxSkinnedRect.CheckCachedImage;
begin
  if (FLastSize.cx = CalculatedSize.cx) and (FLastSize.cy = CalculatedSize.cy) then Exit;
  FLastSize := CalculatedSize;
  if FGPCacheBitmap <> nil then
    GdipDisposeImage(FGPCacheBitmap);
  GdipCreateBitmapFromScan0(CalculatedSize.cx, CalculatedSize.cy, 0,
    PixelFormat32bppPARGB, nil, FGPCacheBitmap);
  UpdateCacheImage;
end;

procedure TdxSkinnedRect.CheckCalculate(AWidth, AHeight: Integer);
begin
  if (AWidth <> CalculatedSize.cx) or (AHeight <> CalculatedSize.cy) then
  begin
    Calculate(AWidth, AHeight);
    FCalculatedSize.cx := AWidth;
    FCalculatedSize.cy := AHeight;
  end;
end;

procedure TdxSkinnedRect.UpdateCacheImage;
var
  X, Y: Integer;
  G: GpGraphics;

  procedure StretchDraw(X, Y, W, H: Integer; const ASrcRect: TRect);
  var
    ASrcWidth, ASrcHeight: Integer;
  begin
    ASrcWidth := ASrcRect.Right - ASrcRect.Left;
    ASrcHeight := ASrcRect.Bottom - ASrcRect.Top;
    if (ASrcWidth > 1) and (W > ASrcWidth) then Dec(ASrcWidth);
    if (ASrcHeight > 1) and (H > ASrcHeight) then Dec(ASrcHeight);
    GdipDrawImageRectRectI(G, FGPImage, X, Y, W, H, ASrcRect.Left, ASrcRect.Top,
      ASrcWidth, ASrcHeight, UnitPixel,
      nil, nil, nil);
  end;

  procedure DrawPart(var X: Integer; Y: Integer; APart: TdxSkin3x3Part);
  var
    W, H: Integer;
  begin
    W := FDrawPartSizes[APart].cx;
    H := FDrawPartSizes[APart].cy;
    if (W > 0) and (H > 0) then
      StretchDraw(X, Y, W, H, FPartBounds[APart]);
    Inc(X, W);
  end;

begin
  GdipGetImageGraphicsContext(FGPCacheBitmap, G);
  GdipSetInterpolationMode(G, FInterpolationMode);
  GdipSetCompositingMode(G, CompositingModeSourceCopy);

  X := 0;
  Y := 0;
  DrawPart(X, Y, sp3x3TopLeft);
  DrawPart(X, Y, sp3x3Top);
  DrawPart(X, Y, sp3x3TopRight);
  X := 0;
  Inc(Y, FDrawPartSizes[sp3x3TopLeft].cy);
  DrawPart(X, Y, sp3x3Left);
  DrawPart(X, Y, sp3x3Center);
  DrawPart(X, Y, sp3x3Right);
  X := 0;
  Inc(Y, FDrawPartSizes[sp3x3Left].cy);
  DrawPart(X, Y, sp3x3BottomLeft);
  DrawPart(X, Y, sp3x3Bottom);
  DrawPart(X, Y, sp3x3BottomRight);
  GdipDeleteGraphics(G);
end;

procedure TdxSkinnedRect.UpdateSizes;
begin
  FTextOffset := FFixedPartSize;
  FMinSize.cx := FTextOffset.Left + FTextOffset.Right;
  FMinSize.cy := FTextOffset.Top + FTextOffset.Bottom;
end;

{ TdxCustomBarSkin }

constructor TdxCustomBarSkin.Create(const AName: string);
begin
  FName := AName;
end;

function TdxCustomBarSkin.Add(ASkinnedRect: TdxSkinnedRect): Integer;
var
  I: Integer;

//  j: TdxSkin3x3Part;
//  R: TRect;

begin
  Result := -1;
  if ASkinnedRect = nil then Exit;
  for I := 0 to Count - 1 do
    with Parts[I] do
      if (ASkinnedRect.ID <> -1) and (ASkinnedRect.ID = ID) then
        raise EdxException.CreateFmt('ERROR: Duplicate part''s ID = %d', [ASkinnedRect.ID])
      else if (ASkinnedRect.Name <> '') and (AnsiSameText(ASkinnedRect.Name, Name)) then
        raise EdxException.CreateFmt('ERROR: Duplicate part''s name = "%s"', [ASkinnedRect.Name]);
  Result := inherited Add(ASkinnedRect);

//  for j := sp3x3TopLeft to sp3x3BottomRight do
//    with ASkinnedRect.FPartBounds[j] do
//    begin
//      if (Bottom - Top = 1) or (Right - Left = 1) then
//        raise EdxException.CreateFmt('ERROR: Duplicate part''s ID = %d', [ASkinnedRect.ID])
//    end;

end;

function TdxCustomBarSkin.AddPart1x1(ABitmap: GpBitmap;
  const R: TRect; AID: Integer; const AName: string = '';
  AInterpolationMode: Integer = InterpolationModeDefault): Integer;
var
  P: TdxSkinnedRect;
begin
  P := TdxSkinnedRect.Create;
  P.LoadFromBitmap(ABitmap, R, cxNullRect);
  P.ID := AID;
  P.Name := AName;
  P.InterpolationMode := AInterpolationMode;
  Result := Add(P);
end;

function TdxCustomBarSkin.AddPart1x3(ABitmap: GpBitmap;
  const R: TRect; ATop, ABottom, AID: Integer; const AName: string = '';
  AInterpolationMode: Integer = InterpolationModeDefault): Integer;
var
  P: TdxSkinnedRect;
begin
  P := TdxSkinnedRect.Create;
  P.LoadFromBitmap(ABitmap, R, cxRect(0, ATop, 0, ABottom));
  P.ID := AID;
  P.Name := AName;
  P.InterpolationMode := AInterpolationMode;
  Result := Add(P);
end;

function TdxCustomBarSkin.AddPart3x3(ABitmap: GpBitmap; const R,
  AFixedSize: TRect; AID: Integer; const AName: string = '';
  AInterpolationMode: Integer = InterpolationModeDefault): Integer;
var
  P: TdxSkinnedRect;
begin
  P := TdxSkinnedRect.Create;
  P.LoadFromBitmap(ABitmap, R, AFixedSize);
  P.ID := AID;
  P.Name := AName;
  P.InterpolationMode := AInterpolationMode;
  Result := Add(P);
end;

procedure TdxCustomBarSkin.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Parts[I].Free;
  inherited Clear;
end;

function TdxCustomBarSkin.PartByID(const AID: Integer): TdxSkinnedRect;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AID = Parts[I].ID then
    begin
      Result := Parts[I];
      Break;
    end;
end;

function TdxCustomBarSkin.PartByName(const AName: string): TdxSkinnedRect;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiSameText(AName, Parts[I].Name) then
    begin
      Result := Parts[I];
      Break;
    end;
end;

function TdxCustomBarSkin.IsPersistent: Boolean;
begin
  Result := False;
end;

function TdxCustomBarSkin.GetPart(Index: Integer): TdxSkinnedRect;
begin
  Result := TdxSkinnedRect(List^[Index]);
end;

{ TdxBarSkinManager }

constructor TdxBarSkinManager.Create;
begin
  FList := TList.Create;
end;

destructor TdxBarSkinManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    Skins[I].Free;
  FList.Free;
  inherited Destroy;
end;

function TdxBarSkinManager.AddSkin(ASkin: TdxCustomBarSkin): Integer;
var
  I: Integer;
begin
  Result := -1;
  if not CheckGdiPlus then Exit;
  if (ASkin <> nil) and (ASkin.Name <> '') then
  begin
    for I := 0 to SkinCount - 1 do
      if AnsiSameText(ASkin.Name, Skins[I].Name) then
        Exit;
    Result := FList.Add(ASkin);
    Changed;
  end
end;

function TdxBarSkinManager.CanDeleteSkin(ASkin: TdxCustomBarSkin): Boolean;
begin
  Result := not ASkin.IsPersistent;
end;

procedure TdxBarSkinManager.Changed;
begin
end;

function TdxBarSkinManager.GetSkin(Index: Integer): TdxCustomBarSkin;
begin
  Result := TdxCustomBarSkin(FList[Index]);
end;

function TdxBarSkinManager.RemoveSkin(ASkin: TdxCustomBarSkin): Boolean;
var
  I: Integer;
begin
  Result := CanDeleteSkin(ASkin);
  if Result then
  begin
    I := FList.IndexOf(ASkin);
    if I >= 0 then
    begin
      ASkin.Free;
      FList.Delete(I);
      Changed;
    end;
  end;
end;

function TdxBarSkinManager.SkinByName(const AName: string): TdxCustomBarSkin;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to SkinCount - 1 do
    if AnsiSameText(AName, Skins[I].Name) then
    begin
      Result := Skins[I];
      Break;
    end;
end;

function TdxBarSkinManager.GetSkinCount: Integer;
begin
  Result := FList.Count;
end;

procedure DestroySkinManager;
begin
  FreeAndNil(FSkinManager);
end;

initialization

finalization
  DestroySkinManager;

end.
