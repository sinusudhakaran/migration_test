{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       Express Cross Platform Library classes                                      }
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

unit dxFading;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Windows, Classes, SysUtils, Graphics, cxGraphics, ExtCtrls, dxGDIPlusClasses,
  dxGDIPlusApi, cxControls, cxClasses;

const
  dxFadeInDefaultAnimationFrameCount: Integer = 4;
  dxFadeInDefaultAnimationFrameDelay: Integer  = 15;
  dxFadeOutDefaultAnimationFrameCount: Integer = 12;
  dxFadeOutDefaultAnimationFrameDelay: Integer  = 20;

type
  TdxFader = class;
  TdxFadingList = class;

  IdxFadingElementData = interface
  ['{982B842D-FF38-4E6E-B7CE-BB608FE193F7}']
    function DrawImage(DC: HDC; const R: TRect): Boolean;
    function GetFadeWorkImage(out AImage: TdxGPImage): Boolean;
  end;

  TdxFadingObjectState = (fosNone, fosGetParams, fosFading);

  IdxFadingObject = interface
  ['{73AB2A92-CDD9-4F13-965A-DC799DE837F9}']
    function CanFade: Boolean;
    procedure DrawFadeImage;
    procedure FadingBegin(AData: IdxFadingElementData);
    procedure FadingEnd;
    procedure GetFadingParams(
      out AFadeOutImage, AFadeInImage: TcxBitmap;
      var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
      var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
  end;

  { TdxFadingElement }

  TdxFadingState = (fsFadeIn, fsFadeOut);

  TdxFadingElement = class(TcxIUnknownObject, IdxFadingElementData)
  private
    FElement: TObject;
    FFadeInAnimationFrameCount: Integer;
    FFadeInAnimationFrameDelay: Integer;
    FFadeInImage: TdxGPImage;
    FFadeOutAnimationFrameCount: Integer;
    FFadeOutAnimationFrameDelay: Integer;
    FFadeOutImage: TdxGPImage;
    FFadingDelayCount: Integer;
    FFadingDelayIndex: Integer;
    FFadingObject: IdxFadingObject;
    FFadingWorkImage: TdxGPImage;
    FOwner: TdxFader;
    FStage: Integer;
    FState: TdxFadingState;
    function GetAnimationFrameCount: Integer;
    procedure SetFadingWorkImage(AImage: TdxGPImage);
    procedure SetState(const Value: TdxFadingState);
    procedure ValidateStageParams;
  protected
    procedure CalculateIntervals;
    procedure CheckBitmapColors(var AColors: TdxRGBColors);
    function CreateGPImage(const ABitmap: TcxBitmap): TdxGPImage;
    procedure DoFade;
    function GetFinalImageState: TdxGPImage;
    function GetInvertedStage: Integer;
    function GetStageAlpha: Byte;
    // IdxFadingElementData
    function DrawImage(DC: HDC; const R: TRect): Boolean;
    function GetFadeWorkImage(out AImage: TdxGPImage): Boolean;
    // Properties
    property AnimationFrameCount: Integer read GetAnimationFrameCount;
    property FadeInAnimationFrameCount: Integer read FFadeInAnimationFrameCount;
    property FadeInAnimationFrameDelay: Integer read FFadeInAnimationFrameDelay;
    property FadeOutAnimationFrameCount: Integer read FFadeOutAnimationFrameCount;
    property FadeOutAnimationFrameDelay: Integer read FFadeOutAnimationFrameDelay;
    property FadingDelayCount: Integer read FFadingDelayCount;
    property Owner: TdxFader read FOwner;
    property Stage: Integer read FStage;
  public
    constructor Create(AOwner: TdxFader; AElement: TObject;
      AState: TdxFadingState; const AFadeOutImage, AFadeInImage: TcxBitmap;
      AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
      AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
    destructor Destroy; override;
    procedure Initialize;
    procedure Finalize;
    // Properties
    property Element: TObject read FElement;
    property FadingWorkImage: TdxGPImage read FFadingWorkImage write SetFadingWorkImage;
    property State: TdxFadingState read FState write SetState;
  end;

  { TdxFadingObjectHelper }

  TdxFadingObjectHelper = class(TcxIUnknownObject, IdxFadingObject)
  private
    FFadingElementData: IdxFadingElementData;
    function GetIsEmpty: Boolean;
  protected
    // IdxFadingObject
    function CanFade: Boolean; virtual;
    procedure DrawFadeImage; virtual;
    procedure FadingBegin(AData: IdxFadingElementData);
    procedure FadingEnd;
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); virtual;
  public
    procedure DrawImage(DC: HDC; const R: TRect);
    // Properties
    property IsEmpty: Boolean read GetIsEmpty;
  end;

  { TdxFadingList }

  TdxFadingList = class(TList)
  private
    function GetItems(Index: Integer): TdxFadingElement;
  public
    procedure Clear; override;
    property Items[Index: Integer]: TdxFadingElement read GetItems; default;
  end;

  { TdxFader }

  TdxFaderAnimationState = (fasDefault, fasEnabled, fasDisabled);

  TdxFader = class(TObject)
  private
    FList: TdxFadingList;
    FMaxAnimationCount: Integer;
    FState: TdxFaderAnimationState;
    FTimer: TTimer;
    function GetActive: Boolean;
    function GetIsReady: Boolean;
    function GetSystemAnimationState: Boolean;
    procedure SetMaxAnimationCount(Value: Integer);
    procedure ValidateQueue;
  protected
    procedure AddFadingElement(AObject: TObject; AState: TdxFadingState);
    procedure DoFade(AObject: TObject; AState: TdxFadingState);
    procedure DoTimer(Sender: TObject);
    procedure RemoveFadingElement(AElement: TdxFadingElement);
    property Active: Boolean read GetActive;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Contains(AObject: TObject): Boolean;
    procedure FadeIn(AObject: TObject);
    procedure FadeOut(AObject: TObject);
    function Find(AObject: TObject; out AFadingElement: TdxFadingElement): Boolean;
    procedure Remove(AObject: TObject; ADestroying: Boolean = True);
    property IsReady: Boolean read GetIsReady;
    property MaxAnimationCount: Integer read FMaxAnimationCount write SetMaxAnimationCount;
    property State: TdxFaderAnimationState read FState write FState;
  end;

function dxFader: TdxFader;

implementation

uses
  Math;

const
  dxMaxAnimationFrameCount = 32;
  dxMaxAnimationFrameDelay = 300;
  dxMaxAnimationCount = 20;
  dxMinFadingInterval = 10;

var
  Fader: TdxFader;

function dxFader: TdxFader;
begin
  Result := Fader; 
end;

{ TdxFadingElement }

constructor TdxFadingElement.Create(AOwner: TdxFader; AElement: TObject;
  AState: TdxFadingState; const AFadeOutImage, AFadeInImage: TcxBitmap;
  AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
  AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
begin
  inherited Create;
  FOwner := AOwner;
  FElement := AElement;
  FState := AState;
  FFadeInAnimationFrameCount := AFadeInAnimationFrameCount;
  FFadeInAnimationFrameDelay := AFadeInAnimationFrameDelay;
  FFadeOutAnimationFrameCount := AFadeOutAnimationFrameCount;
  FFadeOutAnimationFrameDelay := AFadeOutAnimationFrameDelay;
  Supports(AElement, IdxFadingObject, FFadingObject);
  FFadeInImage := CreateGPImage(AFadeInImage);
  FFadeOutImage := CreateGPImage(AFadeOutImage);
  ValidateStageParams;
  Initialize;
end;

destructor TdxFadingElement.Destroy;
begin
  FadingWorkImage := GetFinalImageState;
  Owner.RemoveFadingElement(Self);
  FFadingObject.FadingEnd;
  FreeAndNil(FFadeOutImage);
  FreeAndNil(FFadeInImage);
  FadingWorkImage := nil;
  FFadingObject := nil;
  inherited Destroy;
end;

function TdxFadingElement.CreateGPImage(const ABitmap: TcxBitmap): TdxGPImage;
var
  AColors: TdxRGBColors;
begin
  AColors := dxGPImageClass.GetBitmapBits(ABitmap);
  CheckBitmapColors(AColors);
  Result := dxGPImageClass.CreateFromPattern(ABitmap.Width, ABitmap.Height,
    AColors, ABitmap.PixelFormat = pf32bit);
end;

procedure TdxFadingElement.CheckBitmapColors(var AColors: TdxRGBColors);
var
  I: Integer;
begin
  for I := Low(AColors) to High(AColors) do
    with AColors[I] do
    begin
      if (rgbBlue + rgbGreen + rgbRed > 0) and (rgbReserved = 0) then
        rgbReserved := $FF;
    end;
end;


procedure TdxFadingElement.Initialize;
begin
  FFadingObject.FadingBegin(Self);
  if State = fsFadeIn then
    FadingWorkImage := FFadeOutImage.Clone
  else
    FadingWorkImage := FFadeInImage.Clone;
end;

procedure TdxFadingElement.Finalize;
begin
  Free;
end;

function TdxFadingElement.GetFinalImageState: TdxGPImage;
begin
  if State = fsFadeIn then
    Result := FFadeInImage.Clone
  else
    Result := FFadeOutImage.Clone;
end;

function TdxFadingElement.GetInvertedStage: Integer;
begin
  if State = fsFadeIn then
    Result := Round((1 - Stage / (FadeInAnimationFrameCount + 1)) * FadeOutAnimationFrameCount)
  else
    Result := Round((1 - Stage / (FadeOutAnimationFrameCount + 1)) * FadeInAnimationFrameCount);
end;

function TdxFadingElement.GetStageAlpha: Byte;
begin
  if State = fsFadeIn then
    Result := Min(255, Stage * (256 div FadeInAnimationFrameCount))
  else
    Result := Max(0, 255 - Stage * (256 div FadeOutAnimationFrameCount));
end;

procedure TdxFadingElement.CalculateIntervals;
var
  AInterval: Integer;
begin
  if State = fsFadeIn then
    AInterval := FadeInAnimationFrameDelay
  else
    AInterval := FadeOutAnimationFrameDelay;
  FFadingDelayCount := Max(AInterval div dxMinFadingInterval, 1);
  FFadingDelayIndex := 0;
end;

procedure TdxFadingElement.DoFade;
begin
  FFadingDelayIndex := (FFadingDelayIndex + 1) mod FadingDelayCount;
  if FFadingDelayIndex = 0 then
  begin
    if Stage >= AnimationFrameCount then
      Finalize
    else
    begin
      Inc(FStage);
      FadingWorkImage := FFadeOutImage.MakeComposition(FFadeInImage, GetStageAlpha);
    end;
  end;
end;

procedure TdxFadingElement.ValidateStageParams;
begin
  if FFadeInAnimationFrameCount <= 0 then
    FFadeInAnimationFrameCount := dxFadeInDefaultAnimationFrameCount
  else
    FFadeInAnimationFrameCount := Min(FFadeInAnimationFrameCount, dxMaxAnimationFrameCount);
    
  if FFadeOutAnimationFrameCount <= 0 then
    FFadeOutAnimationFrameCount := dxFadeOutDefaultAnimationFrameCount
  else
    FFadeOutAnimationFrameCount := Min(FFadeOutAnimationFrameCount, dxMaxAnimationFrameCount);

  if FFadeInAnimationFrameDelay < dxMinFadingInterval then
    FFadeInAnimationFrameDelay := dxFadeInDefaultAnimationFrameDelay
  else
    FFadeInAnimationFrameDelay := Min(FFadeInAnimationFrameDelay, dxMaxAnimationFrameDelay);

  if FFadeOutAnimationFrameDelay < dxMinFadingInterval then
    FFadeOutAnimationFrameDelay := dxFadeOutDefaultAnimationFrameDelay
  else
    FFadeOutAnimationFrameDelay := Min(dxMaxAnimationFrameDelay, FFadeOutAnimationFrameDelay);

  CalculateIntervals;
end;

function TdxFadingElement.GetAnimationFrameCount: Integer;
begin
  if State = fsFadeIn then
    Result := FadeInAnimationFrameCount
  else
    Result := FadeOutAnimationFrameCount;
end;

procedure TdxFadingElement.SetFadingWorkImage(AImage: TdxGPImage);
var
  ATemp: TdxGPImage;
begin
  ATemp := FFadingWorkImage;
  try
    FFadingWorkImage := AImage;
    if AImage <> nil then
      FFadingObject.DrawFadeImage;
  finally
    ATemp.Free;
  end;
end;

procedure TdxFadingElement.SetState(const Value: TdxFadingState);
begin
  if FState <> Value then
  begin
    FStage := GetInvertedStage;
    FState := Value;
    CalculateIntervals;
  end;
end;

function TdxFadingElement.DrawImage(DC: HDC; const R: TRect): Boolean;
begin
  Result := Assigned(FadingWorkImage);
  if Result then
    FadingWorkImage.Draw(DC, R);
end;

function TdxFadingElement.GetFadeWorkImage(out AImage: TdxGPImage): Boolean;
begin
  AImage := FadingWorkImage;
  Result := AImage <> nil;
end;

{ TdxFadingList }

procedure TdxFadingList.Clear;
begin
  while Count > 0 do
    Items[0].Free;
  inherited Clear;
end;

function TdxFadingList.GetItems(Index: Integer): TdxFadingElement;
begin
  Result := TdxFadingElement(inherited Items[Index]);
end;

{ TdxFader }

constructor TdxFader.Create;
begin
  inherited Create;
  FState := fasDefault;
  FList := TdxFadingList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := dxMinFadingInterval;
  FTimer.OnTimer := DoTimer;
  FMaxAnimationCount := 10;
end;

destructor TdxFader.Destroy;
begin
  Clear;
  FreeAndNil(FTimer);
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TdxFader.Clear;
begin
  FList.Clear;
end;

function TdxFader.Contains(AObject: TObject): Boolean;
var
  AFadingElement: TdxFadingElement;
begin
  Result := Find(AObject, AFadingElement);
end;

procedure TdxFader.FadeIn(AObject: TObject);
begin
  DoFade(AObject, fsFadeIn);
end;

procedure TdxFader.FadeOut(AObject: TObject);
begin
  DoFade(AObject, fsFadeOut);
end;

procedure TdxFader.AddFadingElement(AObject: TObject; AState: TdxFadingState);
var
  AFadeInAnimationFrameCount: Integer;
  AFadeInAnimationFrameDelay: Integer;
  AFadeOutAnimationFrameCount: Integer;
  AFadeOutAnimationFrameDelay: Integer;
  AFadingObject: IdxFadingObject;
  ATemp1, ATemp2: TcxBitmap;
begin
  ATemp1 := nil;
  ATemp2 := nil;
  Supports(AObject, IdxFadingObject, AFadingObject);
  AFadeInAnimationFrameCount := dxFadeInDefaultAnimationFrameCount;
  AFadeInAnimationFrameDelay := dxFadeInDefaultAnimationFrameDelay;
  AFadeOutAnimationFrameCount := dxFadeOutDefaultAnimationFrameCount;
  AFadeOutAnimationFrameDelay := dxFadeOutDefaultAnimationFrameDelay;
  AFadingObject.GetFadingParams(ATemp1, ATemp2, AFadeInAnimationFrameCount,
    AFadeInAnimationFrameDelay, AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay);
  try
    if (ATemp1 <> nil) and (ATemp2 <> nil) and not (ATemp1.Empty or ATemp2.Empty) then
    begin
      FList.Add(TdxFadingElement.Create(Self, AObject, AState, ATemp1, ATemp2,
        AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay, AFadeOutAnimationFrameCount,
        AFadeOutAnimationFrameDelay));
      ValidateQueue;
    end;
  finally
    ATemp1.Free;
    ATemp2.Free;
  end;
end;

procedure TdxFader.DoFade(AObject: TObject; AState: TdxFadingState);
var
  AElement: TdxFadingElement;
  AIntf: IdxFadingObject;
begin
  if IsReady and Supports(AObject, IdxFadingObject, AIntf) and AIntf.CanFade then
  begin
    if Find(AObject, AElement) then
      AElement.State := AState
    else
      AddFadingElement(AObject, AState);
  end;
end;

procedure TdxFader.DoTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do
    FList.Items[I].DoFade;
end;

function TdxFader.GetSystemAnimationState: Boolean;
begin
  SystemParametersInfo(SPI_GETMENUANIMATION, 0, @Result, 0);
end;

procedure TdxFader.RemoveFadingElement(AElement: TdxFadingElement);
begin
  FList.Remove(AElement);
  ValidateQueue;
end;

function TdxFader.Find(AObject: TObject; out AFadingElement: TdxFadingElement): Boolean;
var
  I: Integer;
begin
  AFadingElement := nil;
  for I := 0 to FList.Count - 1 do
    if FList[I].Element = AObject then
    begin
      AFadingElement := FList[I];
      Break;
    end;
  Result := AFadingElement <> nil;
end;

procedure TdxFader.Remove(AObject: TObject; ADestroying: Boolean = True);
var
  AElement: TdxFadingElement;
begin
  if Find(AObject, AElement) then
  begin
    if ADestroying then
      AElement.Free
    else
      AElement.Finalize;
  end;
end;

function TdxFader.GetActive: Boolean;
begin
  if State = fasDefault then
    Result := GetSystemAnimationState
  else
    Result := State = fasEnabled;
end;

function TdxFader.GetIsReady: Boolean;
begin
  Result := Active and CheckGdiPlus and
    (GetDeviceCaps(cxScreenCanvas.Handle, BITSPIXEL) > 16);
end;

procedure TdxFader.SetMaxAnimationCount(Value: Integer);
begin
  Value := Min(Max(0, Value), dxMaxAnimationCount);
  if FMaxAnimationCount <> Value then
  begin
    FMaxAnimationCount := Value;
    ValidateQueue;
  end;
end;

procedure TdxFader.ValidateQueue;
begin
  while FList.Count > MaxAnimationCount do
    FList[0].Finalize;
  FTimer.Enabled := FList.Count > 0;  
end;

{ TdxFadingObjectHelper }

function TdxFadingObjectHelper.GetIsEmpty: Boolean;
begin
  Result := FFadingElementData = nil;
end;

function TdxFadingObjectHelper.CanFade: Boolean;
begin
  Result := False;
end;

procedure TdxFadingObjectHelper.DrawFadeImage;
begin
end;

procedure TdxFadingObjectHelper.FadingBegin(AData: IdxFadingElementData);
begin
  FFadingElementData := AData;
end;

procedure TdxFadingObjectHelper.FadingEnd;
begin
  FFadingElementData := nil;
end;

procedure TdxFadingObjectHelper.GetFadingParams(out AFadeOutImage: TcxBitmap;
  out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
  var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
  var AFadeOutAnimationFrameDelay: Integer);
begin
end;

procedure TdxFadingObjectHelper.DrawImage(DC: HDC; const R: TRect);
begin
  if FFadingElementData <> nil then
    FFadingElementData.DrawImage(DC, R);
end;

initialization
  Fader := TdxFader.Create;

finalization
  FreeAndNil(Fader);

end.

