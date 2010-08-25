{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Common Editing Library            }
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
{   LICENSED TO DISTRIBUTE THE COMMONEDITINGLIBRARY AND ALL          }
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

unit cxGeometry;

{$I cxVer.inc}

interface

uses
  Windows, Classes;

type
  TcxPtInRectType = (ptrtNone, ptrtArea, ptrtLeft, ptrtTop, ptrtRight, ptrtBottom);

  { TcxRect }

  TcxRect = class(TPersistent)
  private
    FOwner: TPersistent;
    FRect: TRect;
    FOnChange: TNotifyEvent;
    function GetData: Pointer;
    function GetHeight: Integer;
    function GetVertex(AIndex: Integer): TPoint;
    function GetWidth: Integer;
    procedure SetHeight(AValue: Integer);
    procedure SetRect(const AValue: TRect);
    procedure SetVertex(AIndex: Integer; const AValue: TPoint);
    procedure SetWidth(AValue: Integer);
  protected
    procedure DoChange;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent); virtual;
    procedure Assign(Source: TPersistent); override;

    function GetValue(AIndex: Integer): Integer;
    procedure SetValue(AIndex, AValue: Integer);

    function IsEmpty: Boolean;
    function IsEqual(const ARect: TRect): Boolean; overload;
    function IsEqual(ARect: TcxRect): Boolean; overload;

    property BottomLeft: TPoint index 2 read GetVertex write SetVertex;
    property BottomRight: TPoint index 3 read GetVertex write SetVertex;
    property Data: Pointer read GetData;
    property Height: Integer read GetHeight write SetHeight;
    property Rect: TRect read FRect write SetRect;
    property TopLeft: TPoint index 0 read GetVertex write SetVertex;
    property TopRight: TPoint index 1 read GetVertex write SetVertex;
    property Width: Integer read GetWidth write SetWidth;
  published
    property Left: Integer index 0 read GetValue write SetValue default 0;
    property Top: Integer index 1 read GetValue write SetValue default 0;
    property Right: Integer index 2 read GetValue write SetValue default 0;
    property Bottom: Integer index 3 read GetValue write SetValue default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { TcxSize }

  TcxSize = class(TPersistent)
  private
    FOwner: TPersistent;
    FSize: TSize;
    FOnChange: TNotifyEvent;
    function GetData: Pointer;
    function GetSize: TSize;
    procedure SetValue(Index, Value: Integer);
  protected
    procedure DoChange; virtual;
    function GetOwner: TPersistent; override;
    function GetValue(Index: Integer): Integer; virtual;
    function IsSizeStored(Index: Integer): Boolean; virtual;
    procedure SetSize(const Value: TSize); virtual;
  public
    constructor Create(AOwner: TPersistent);
    procedure Assign(Source: TPersistent); override;

    function IsEmpty: Boolean;
    function IsEqual(const ASize: TSize): Boolean; overload;
    function IsEqual(ASize: TcxSize): Boolean; overload;

    property Data: Pointer read GetData;
    property Size: TSize read GetSize write SetSize;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Height: Integer index 0 read GetValue write SetValue stored IsSizeStored;
    property Width: Integer index 1 read GetValue write SetValue stored IsSizeStored;
  end;

// rect helper routines
function cxRectCompare(const R1, R2: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectCenter(const R: TRect): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectCenter(const Bounds: TRect; const ASize: TSize): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectCenter(const Bounds: TRect; Width, Height: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectContain(const ABounds, AInner: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectContent(const R, Margins: TRect): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectHeight(const R: TRect): Integer; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIntersect(const R1, R2: TRect): Boolean; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIntersect(out R: TRect; const R1, R2: TRect): Boolean; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectInflate(const R: TRect; DX, DY: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectInflate(const R: TRect; DX1, DY1, DX2, DY2: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectInvert(const R: TRect): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIsEmpty(const R: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIsEqual(const R, R1: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIsInvalid(const R: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectIsNull(const R: TRect): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectGetItem(const ARect: TRect; AIndex: Integer): Integer; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectGetSize(const ARect: TRect; AIndex: Integer): Integer; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectLeftBottom(const R: TRect): TPoint; {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectMinMaxHeight(const R: TRect; var AMax, AMin: Integer); {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectMinMaxInit(var AMin, AMax: Integer); {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectMinMaxWidth(const R: TRect; var AMax, AMin: Integer); {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectOffset(const R: TRect; const P: TPoint): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectOffset(const R: TRect; const Ps: array of TPoint): TRect; overload;
function cxRectOffset(const R: TRect; DX, DY: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectOffsetHorz(const R: TRect; DX: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectOffsetVert(const R: TRect; DY: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectOverlapped(const Src, Dst: TRect; out SrcH, SrcV, DstH, DstV: TRect);
function cxRectPtIn(const R: TRect; const P: TPoint): Boolean; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectPtIn(const R: TRect; const X, Y: Integer): Boolean; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectPtInEx(const R: TRect; X, Y, Delta: Integer): TcxPtInRectType; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectPtInEx(const R: TRect; X, Y, DeltaX, DeltaY: Integer): TcxPtInRectType; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectPtInEx(const R: TRect; const X, Y: Integer; DL, DT, DR, DB: Integer): TcxPtInRectType; overload;
function cxRectRotate(const R: TRect): TRect;
function cxRect(const Left, Top, Right, Bottom: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRect(const TopLeft, BottomRight: TPoint): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectAdjust(const R: TRect): TRect; //#DG - too complex {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectBounds(Left, Top, Width, Height: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectRightTop(const R: TRect): TPoint; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectScaleHeight(const R: TRect; Y1, Y2, H1, H2: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectScaleWidth(const R: TRect; X1, X2, W1, W2: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetBottom(const R: TRect; Y: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetBottom(const R: TRect; Y, H: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetHeight(const R: TRect; H: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetLeft(const R: TRect; X: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetLeft(const R: TRect; X, W: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetTop(const R: TRect; Y: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetTop(const R: TRect; Y, H: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetRight(const R: TRect; X: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetRight(const R: TRect; X, W: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetSize(const R: TRect; W, H: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetWidth(const R: TRect; W: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetWidth(const R: TRect; X, W: Integer): TRect; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetXPos(const R: TRect; X1, X2: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSetYPos(const R: TRect; Y1, Y2: Integer): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectSize(const R: TRect): TSize; {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectSplitHorz(const ABounds: TRect; var ARect1, ARect2: TRect); {$IFDEF DELPHI9} inline; {$ENDIF}
procedure cxRectSplitVert(const ABounds: TRect; var ARect1, ARect2: TRect); {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectUnion(const R1, R2: TRect): TRect; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxRectWidth(const R: TRect): Integer; {$IFDEF DELPHI9} inline; {$ENDIF}

// point helper routines
function cxPointInvert(const P: TPoint): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointIsEqual(const P1, P2: TPoint): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointIsNull(const P: TPoint): Boolean; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointGetItem(const P: TPoint; AIndex: Integer): Integer; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPoint(X, Y: Integer): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPoint(const ASize: TSize): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointOffset(const P, DP: TPoint): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointOffset(const P: TPoint; const Ps: array of TPoint): TPoint; overload;
function cxPointOffset(const P: TPoint; X, Y: Integer): TPoint; overload; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointReplaceItem(const P: TPoint; const AIndex, AValue: Integer): TPoint; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxPointSum(const Ps: array of TPoint): TPoint;

function cxSize(DX, DY: Integer): TSize; {$IFDEF DELPHI9} inline; {$ENDIF}
function cxSizeIsEqual(const S1, S2: TSize): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}

const
  cxInvalidRect: TRect = (Left: -1; Top: -1; Right: -1; Bottom: -1);
  cxSimpleRect: TRect = (Left: 1; Top: 1; Right: 1; Bottom: 1);
  cxInvalidPoint: TPoint = (X: -1; Y: -1);

var
  cxNullRect: TRect;
  cxNullSize: TSize;
  cxNullPoint: TPoint;

implementation

uses
  Math;

{ TcxRect }

constructor TcxRect.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TcxRect.Assign(Source: TPersistent);
begin
  if Source is TcxRect then
    Rect := TcxRect(Source).Rect;
end;

procedure TcxRect.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TcxRect.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TcxRect.IsEmpty: Boolean;
begin
  Result := cxRectIsEmpty(FRect);
end;

function TcxRect.IsEqual(const ARect: TRect): Boolean;
begin
  Result := cxRectIsEqual(ARect, FRect);
end;

function TcxRect.IsEqual(ARect: TcxRect): Boolean;
begin
  Result := IsEqual(ARect.Rect);
end;

function TcxRect.GetData: Pointer;
begin
  Result := @FRect;
end;

function TcxRect.GetHeight: Integer;
begin
  Result := FRect.Bottom - FRect.Top;
end;

function TcxRect.GetValue(AIndex: Integer): Integer;
begin
  case AIndex of
    0:
      Result := FRect.Left;
    1:
      Result := FRect.Top;
    2:
      Result := FRect.Right;
  else
    Result := FRect.Bottom;
  end;
end;

function TcxRect.GetVertex(AIndex: Integer): TPoint;
begin
  case AIndex of
    0:
      Result := FRect.TopLeft;
    1:
      Result := Point(FRect.Right, FRect.Top);
    2:
      Result := Point(FRect.Left, FRect.Bottom);
  else
    Result := FRect.BottomRight;
  end;
end;

function TcxRect.GetWidth: Integer;
begin
  Result := FRect.Right - FRect.Left;
end;

procedure TcxRect.SetHeight(AValue: Integer);
begin
  Bottom := Top + AValue;
end;

procedure TcxRect.SetRect(const AValue: TRect);
begin
  if not IsEqual(AValue) then
  begin
    FRect := AValue;
    DoChange;
  end;
end;

procedure TcxRect.SetValue(AIndex, AValue: Integer);
var
  ARect: TRect; 
begin
  ARect := Rect;
  case AIndex of
    0:
      ARect.Left := AValue;
    1:
      ARect.Top := AValue;
    2:
      ARect.Right := AValue;
    3:
      ARect.Bottom := AValue;
  end;
  Rect := ARect;
end;

procedure TcxRect.SetVertex(AIndex: Integer; const AValue: TPoint);
var
  ARect: TRect;
begin
  ARect := Rect;
  case AIndex of
    0:
      ARect.TopLeft := AValue;
    1:
    begin
      ARect.Right := AValue.X;
      ARect.Top := AValue.Y;
    end;
    2:
    begin
      ARect.Left := AValue.X;
      ARect.Bottom := AValue.Y;
    end;
    3:
      ARect.BottomRight := AValue;
  end;
  Rect := ARect;
end;

procedure TcxRect.SetWidth(AValue: Integer);
begin
  Right := Left + AValue;
end;

{ TcxSize }

constructor TcxSize.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TcxSize.Assign(Source: TPersistent);
begin
  if Source is TcxSize then
    Size := TcxSize(Source).Size
  else
    inherited Assign(Source);
end;

function TcxSize.GetValue(Index: Integer): Integer;
begin
  if Index = 0 then
    Result := FSize.cy
  else
    Result := FSize.cx;
end;

function TcxSize.GetSize: TSize;
begin
  Result.cx := Width;
  Result.cy := Height;
end;

procedure TcxSize.SetValue(Index, Value: Integer);
var
  ASize: TSize;
begin
  ASize := Size;
  if Index = 0 then
    ASize.cy := Value
  else
    ASize.cx := Value;
  Size := ASize;
end;

function TcxSize.IsEmpty: Boolean;
begin
  Result := (FSize.cx = 0) and (FSize.cy = 0);
end;

function TcxSize.IsEqual(const ASize: TSize): Boolean;
begin
  Result := cxSizeIsEqual(ASize, FSize);
end;

function TcxSize.IsEqual(ASize: TcxSize): Boolean;
begin
  Result := IsEqual(ASize.Size);
end;

procedure TcxSize.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TcxSize.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TcxSize.GetData: Pointer;
begin
  Result := @FSize;
end;

function TcxSize.IsSizeStored(Index: Integer): Boolean;
begin
  if Index = 0 then
    Result := FSize.cy <> 0
  else
    Result := FSize.cx <> 0;
end;

procedure TcxSize.SetSize(const Value: TSize);
var
  ASize: TSize;
begin
  ASize.cx := Max(0, Value.cx);
  ASize.cy := Max(0, Value.cy);
  if not IsEqual(ASize) then
  begin
    FSize := ASize;
    DoChange;
  end;
end;

function cxRectHeight(const R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;

function cxRectIntersect(const R1, R2: TRect): Boolean;
var
  R: TRect;
begin
  Result := cxRectIntersect(R, R1, R2);
end;

function cxRectIntersect(out R: TRect; const R1,
  R2: TRect): Boolean;
begin
  R := R1;
  with R do
  begin
    if R2.Left > R1.Left then Left := R2.Left;
    if R2.Top > R1.Top then Top := R2.Top;
    if R2.Right < R1.Right then Right := R2.Right;
    if R2.Bottom < R1.Bottom then Bottom := R2.Bottom;
    Result := not ((Right <= Left) or (Bottom <= Top));
  end;
  if not Result then R := cxNullRect;
end;

function cxRectInflate(const R: TRect; DX, DY: Integer): TRect;
begin
  Result := cxRectInflate(R, DX, DY, DX, DY);
end;

function cxRectInflate(const R: TRect; DX1, DY1, DX2, DY2: Integer): TRect;
begin
  Result := R;
  with Result do
  begin
    Dec(Left, DX1);
    Dec(Top, DY1);
    Inc(Right, DX2);
    Inc(Bottom, DY2);
  end;
end;

function cxRectInvert(const R: TRect): TRect;
begin
  Result.TopLeft := cxPointInvert(R.TopLeft);
  Result.BottomRight := cxPointInvert(R.BottomRight);
end;

function cxRectIsEmpty(const R: TRect): Boolean;
begin
  with R do
    Result := (Right <= Left) or (Bottom <= Top);
end;

function cxRectIsEqual(const R, R1: TRect): Boolean;
begin
  Result := (R.Left = R1.Left) and (R.Top = R1.Top) and
    (R.Right = R1.Right) and (R.Bottom = R1.Bottom);
end;

function cxRectIsInvalid(const R: TRect): Boolean;
begin
  Result := cxRectIsEqual(R, cxInvalidRect);
end;

function cxRectIsNull(const R: TRect): Boolean;
begin
  Result := (R.Left = 0) and (R.Top = 0) and (R.Right = 0) and (R.Bottom = 0);
end;

function cxRectGetItem(const ARect: TRect; AIndex: Integer): Integer;
begin
  case AIndex of
    0:
      Result := ARect.Left;
    1:
      Result := ARect.Top;
    2:
      Result := ARect.Right;
    3:
      Result := ARect.Bottom;
  else
    Result := 0
  end;
end;

function cxRectGetSize(const ARect: TRect; AIndex: Integer): Integer;
begin
  if AIndex = 0 then
    Result := ARect.Right - ARect.Left
  else
    Result := ARect.Bottom - ARect.Top;
end;

function cxRectLeftBottom(const R: TRect): TPoint;
begin
  Result := cxPoint(R.Left, R.Bottom);
end;

procedure cxRectMinMaxHeight(const R: TRect; var AMax, AMin: Integer);
begin
  with R do
  begin
    if AMax < Bottom then AMax := Bottom;
    if AMin > Top then AMin := Top;
  end;
end;

procedure cxRectMinMaxInit(var AMin, AMax: Integer);
begin
  AMin := MaxInt;
  AMax := -1;
end;

procedure cxRectMinMaxWidth(const R: TRect; var AMax, AMin: Integer);
begin
  with R do
  begin
    if AMax < Right then AMax := Right;
    if AMin > Left then AMin := Left;
  end;
end;

function cxRectOffset(const R: TRect; const P: TPoint): TRect;
begin
  Result := cxRectOffset(R, P.X, P.Y);
end;

function cxRectOffset(const R: TRect; DX, DY: Integer): TRect;
begin
  Result := R;
  with Result do
  begin
    Inc(Left, DX);
    Inc(Top, DY);
    Inc(Right, DX);
    Inc(Bottom, DY);
  end;
end;

function cxRectOffset(const R: TRect; const Ps: array of TPoint): TRect;
begin
  with cxPointSum(Ps) do
    Result := cxRectOffset(R, X, Y);
end;

function cxRectOffsetHorz(const R: TRect; DX: Integer): TRect;
begin
  Result := R;
  Inc(Result.Left, DX);
  Inc(Result.Right, DX);
end;

function cxRectOffsetVert(const R: TRect; DY: Integer): TRect;
begin
  Result := R;
  Inc(Result.Top, DY);
  Inc(Result.Bottom, DY);
end;

function GetRectCoordinate(const R: TRect; ABottomRight, AVertCoordinate: Boolean): Integer;
begin
  if ABottomRight then
    if AVertCoordinate then
      Result := R.Bottom
    else
      Result := R.Right
  else
    if AVertCoordinate then
      Result := R.Top
    else
      Result := R.Left;
end;

procedure SetRectCoordinate(var R: TRect; ABottomRight, AVertCoordinate: Boolean; AValue: Integer);
begin
  if ABottomRight then
    if AVertCoordinate then
      R.Bottom := AValue
    else
      R.Right := AValue
  else
    if AVertCoordinate then
      R.Top := AValue
    else
      R.Left := AValue;
end;

procedure cxRectOverlapped(const Src, Dst: TRect; out SrcH, SrcV, DstH, DstV: TRect);
var
  H, W: Integer;

  procedure IncV(const ARect: TRect; AVertCoordinate, ABottomRight: Boolean;
    Value: Integer; out AResult: TRect);
  begin
    if Value <> 0 then
    begin
      AResult := ARect;
      SetRectCoordinate(AResult, ABottomRight, AVertCoordinate,
        GetRectCoordinate(AResult, not ABottomRight, AVertCoordinate) + Value);
    end
    else
      AResult := cxNullRect;
  end;

begin
  H := Src.Bottom - Dst.Bottom;
  W := Src.Right - Dst.Right;
  IncV(Src, True, H < 0, -H, SrcH);
  IncV(Dst, True, H > 0, H, DstH);
  IncV(Src, False, W < 0, -W, SrcV);
  IncV(Dst, False, W > 0, W, DstV);
end;

function cxRectPtIn(const R: TRect; const P: TPoint): Boolean;
begin
  Result := cxRectPtIn(R, P.X, P.Y);
end;

function cxRectPtIn(const R: TRect; const X, Y: Integer): Boolean;
begin
  with R do
    Result := (X >= Left) and (X < Right) and (Y >= Top) and (Y < Bottom);
end;

function cxRectPtInEx(const R: TRect;
  const X, Y: Integer; DL, DT, DR, DB: Integer): TcxPtInRectType;

  function InRange(V, V1, V2: Integer): Boolean;
  begin
    V := V - V1;
    Result := (V >= -V2) and (V < V2);
  end;

begin
  if cxRectPtIn(R, X, Y) then
    Result := ptrtArea
  else
    if cxRectPtIn(cxRectInflate(R, DL, DT, DR, DB), X, Y) then
    begin
      with R do
      begin
        if InRange(X, Right, DR) then
          Result := ptrtRight
        else
          if InRange(Y, Bottom, DB) then
            Result := ptrtBottom
          else
            if InRange(X, Left, DL) then
              Result := ptrtLeft
            else
              Result := ptrtTop;
      end;
    end
    else
      Result := ptrtNone;
end;

function cxRectRotate(const R: TRect): TRect;
begin
  Result := Rect(R.Top, R.Left, R.Bottom, R.Right);
end;

function cxRectPtInEx(const R: TRect; X, Y, Delta: Integer): TcxPtInRectType;
begin
  Result := cxRectPtInEx(R, X, Y, Delta, Delta, Delta, Delta);
end;

function cxRectPtInEx(const R: TRect;
  X, Y, DeltaX, DeltaY: Integer): TcxPtInRectType;
begin
  Result := cxRectPtInEx(R, X, Y, DeltaX, DeltaY, DeltaX, DeltaY);
end;

function cxRect(const Left, Top, Right, Bottom: Integer): TRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Right;
  Result.Bottom := Bottom;
end;

function cxRect(const TopLeft, BottomRight: TPoint): TRect;
begin
  Result.TopLeft := TopLeft;
  Result.BottomRight := BottomRight;
end;

function cxRectAdjust(const R: TRect): TRect;
begin
  with R do
    Result := Rect(Min(Left, Right), Min(Top, Bottom), Max(Left, Right), Max(Top, Bottom));
end;

function cxRectBounds(Left, Top, Width, Height: Integer): TRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Height;
end;

function cxRectRightTop(const R: TRect): TPoint;
begin
  Result := cxPoint(R.Right, R.Top);
end;

function cxRectScaleHeight(const R: TRect; Y1, Y2, H1, H2: Integer): TRect;
var
  H: Integer;
begin
  Result := R;
  with Result do
  begin
    H := MulDiv(Bottom - Top, H2, H1);
    Top := MulDiv(Y1 - Top, H2, H1) + Y2;
    Bottom := Top + H;
  end;
end;

function cxRectScaleWidth(const R: TRect; X1, X2, W1,
  W2: Integer): TRect;
var
  L: Integer;
begin
  Result := R;
  with Result do
  begin
    L := MulDiv(Right - Left, W2, W1);
    Left := MulDiv(X1 - Left, W2, W1) + X2;
    Right := Left + L;
  end;
end;

function cxRectSetBottom(const R: TRect; Y: Integer): TRect; 
begin
  Result := cxRectSetBottom(R, Y, R.Bottom - R.Top);
end;

function cxRectSetBottom(const R: TRect; Y, H: Integer): TRect;
begin
  Result := R;
  Result.Bottom := Y;
  Result.Top := Y - H;
end;

function cxRectSetHeight(const R: TRect; H: Integer): TRect;
begin
  Result := R;
  Result.Bottom := Result.Top + H;
end;

function cxRectSetLeft(const R: TRect; X: Integer): TRect;
begin
  Result := cxRectSetLeft(R, X, R.Right - R.Left);
end;

function cxRectSetLeft(const R: TRect; X, W: Integer): TRect;
begin
  Result := R;
  Result.Left := X;
  Result.Right := X + W;
end;

function cxRectSetTop(const R: TRect; Y: Integer): TRect;
begin
  Result := cxRectSetTop(R, Y, R.Bottom - R.Top);
end;

function cxRectSetTop(const R: TRect; Y, H: Integer): TRect;
begin
  Result := R;
  Result.Top := Y;
  Result.Bottom := Y + H;
end;

function cxRectSetRight(const R: TRect; X: Integer): TRect;
begin
  Result := cxRectSetRight(R, X, R.Right - R.Left);
end;

function cxRectSetRight(const R: TRect; X, W: Integer): TRect;
begin
  Result := R;
  Result.Right := X;
  Result.Left := X - W;
end;

function cxRectSetSize(const R: TRect; W, H: Integer): TRect;
begin
  Result := R;
  with R do
  begin
    Result.Right := Left + W;
    Result.Bottom := Top + H;
  end;
end;

function cxRectSetWidth(const R: TRect; W: Integer): TRect;
begin
  Result := R;
  Result.Right := R.Left + W;
end;

function cxRectSetWidth(const R: TRect; X, W: Integer): TRect;
begin
  Result := R;
  Result.Left := X;
  Result.Right := X + W;
end;

function cxRectSetXPos(const R: TRect; X1, X2: Integer): TRect;
begin
  with R do
    Result := cxRect(X1, Top, X2, Bottom);
end;

function cxRectSetYPos(const R: TRect; Y1, Y2: Integer): TRect;
begin
  with R do
    Result := cxRect(Left, Y1, Right, Y2);
end;

function cxRectSize(const R: TRect): TSize;
begin
  with R do
  begin
    Result.cx := Right - Left;
    Result.cy := Bottom - Top;
  end;
end;

procedure cxRectSplitHorz(const ABounds: TRect; var ARect1, ARect2: TRect);
begin
  ARect1 := ABounds;
  ARect2 := ABounds;
  ARect1.Right := (ABounds.Right + ABounds.Left) div 2;
  ARect2.Left := ARect1.Right;
end;

procedure cxRectSplitVert(const ABounds: TRect; var ARect1, ARect2: TRect);
begin
  ARect1 := ABounds;
  ARect2 := ABounds;
  ARect1.Bottom := (ABounds.Bottom + ABounds.Top) div 2;
  ARect2.Top := ARect1.Bottom;
end;

function cxRectUnion(const R1, R2: TRect): TRect;
begin
  Result := R1;
  if (R2.Right - R2.Left <= 0) or (R2.Bottom - R2.Top <= 0) then Exit;
  if R2.Left < R1.Left then
    Result.Left := R2.Left;
  if R2.Top < R1.Top then
    Result.Top := R2.Top;
  if R2.Right > R1.Right then
    Result.Right := R2.Right;
  if R2.Bottom > R1.Bottom then
    Result.Bottom := R2.Bottom;
end;

function cxRectWidth(const R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function cxRectCompare(const R1, R2: TRect): Boolean;
begin
  Result := cxRectIsEqual(R1, R2);
end;

function cxRectCenter(const R: TRect): TPoint;
begin
  with R do
    Result := cxPoint((Right + Left) div 2, (Bottom + Top) div 2);
end;

function cxRectCenter(const Bounds: TRect; const ASize: TSize): TRect;
begin
  Result := cxRectCenter(Bounds, ASize.cx, ASize.cy)
end;

function cxRectCenter(const Bounds: TRect; Width, Height: Integer): TRect;
begin
  with Bounds do
  begin
    Result.Left := (Left + Right - Width) div 2;
    Result.Top :=  (Top + Bottom - Height) div 2;
    Result.Right := Result.Left + Width;
    Result.Bottom := Result.Top + Height;
  end;
end;

function cxRectContain(const ABounds, AInner: TRect): Boolean;
begin
  with ABounds do
    Result := (Left <= AInner.Left) and (Right >= AInner.Right) and
      (Top <= AInner.Top) and (Bottom >= AInner.Bottom);
end;

function cxRectContent(const R, Margins: TRect): TRect;
begin
  with Result do
  begin
    Left := R.Left + Margins.Left;
    Top := R.Top + Margins.Top;
    Right := R.Right - Margins.Right;
    Bottom := R.Bottom - Margins.Bottom;
  end;
end;

function cxPointInvert(const P: TPoint): TPoint;
begin
  Result.X := -P.X;
  Result.Y := -P.Y;
end;

function cxPointIsEqual(const P1, P2: TPoint): Boolean;
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;

function cxPointIsNull(const P: TPoint): Boolean;
begin
  Result := (P.X = cxNullPoint.X) and (P.Y = cxNullPoint.Y);
end;

function cxPointGetItem(const P: TPoint; AIndex: Integer): Integer;
begin
  if AIndex = 0 then
    Result := P.X
  else
    Result := P.Y;
end;

function cxPointOffset(const P: TPoint; const Ps: array of TPoint): TPoint;
begin
  with cxPointSum(Ps) do
    Result := cxPointOffset(P, X, Y);
end;

function cxPointOffset(const P: TPoint; X, Y: Integer): TPoint;
begin
  Result.X := P.X + X;
  Result.Y := P.Y + Y;
end;

function cxPointReplaceItem(const P: TPoint; const AIndex, AValue: Integer): TPoint;
begin
  if AIndex = 0 then
    Result.X := AValue
  else
    Result.Y := AValue;
end;

function cxPoint(X, Y: Integer): TPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function cxPoint(const ASize: TSize): TPoint;
begin
  with Result do
  begin
    X := ASize.cx;
    Y := ASize.cy;
  end;
end;

function cxPointOffset(const P, DP: TPoint): TPoint;
begin
  Result := cxPointOffset(P, DP.X, DP.Y);
end;

function cxPointSum(const Ps: array of TPoint): TPoint;
var
  I: Integer;
begin
  if Length(Ps) >= 1 then
  begin
    Result := Ps[Low(Ps)];
    for I := Low(Ps) + 1 to High(Ps) do
      with Ps[I] do
      begin
        Inc(Result.X, X);
        Inc(Result.Y, Y);
      end;
  end
  else
    Result := cxNullPoint;
end;

function cxSize(DX, DY: Integer): TSize;
begin
  Result.cx := DX;
  Result.cy := DY;
end;

function cxSizeIsEqual(const S1, S2: TSize): Boolean;
begin
  Result := (S1.cx = S2.cx) and (S1.cy = S2.cy);
end;

initialization
  RegisterClasses([TcxRect]);

finalization
  UnregisterClasses([TcxRect]);

end.

