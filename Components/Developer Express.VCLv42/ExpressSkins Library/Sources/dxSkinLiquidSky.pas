unit dxSkinLiquidSky;

interface

uses
  Classes, dxGDIPlusApi, cxLookAndFeelPainters, dxSkinsCore, dxSkinsLookAndFeelPainter;

type
  { TdxLiquidSkyPainter }
  TdxLiquidSkyPainter = class(TdxSkinLookAndFeelPainter)
  protected
    class function CacheData: TdxSkinLookAndFeelPainterInfo; override;
  public
    class function InternalUnitName: string; override;
  end;

const
  SkinsCount = 1;
  SkinNames: array[0..SkinsCount - 1] of string = ('LiquidSky');
  SkinPainters: array[0..SkinsCount - 1] of TcxCustomLookAndFeelPainterClass =
    (TdxLiquidSkyPainter);

implementation

{$R dxSkinLiquidSky.res}

var
  CachedPainterData: array[0..SkinsCount - 1] of TdxSkinLookAndFeelPainterInfo;

{ TdxLiquidSkyPainter }

class function TdxLiquidSkyPainter.CacheData: TdxSkinLookAndFeelPainterInfo;
begin
  Result := CachedPainterData[0];
end;

class function TdxLiquidSkyPainter.InternalUnitName: string;
begin
  Result := 'dxSkinLiquidSky';
end;


procedure RegisterPainters;
var
  SkinIndex: Integer;
begin
  if not CheckGdiPlus then Exit;
  for SkinIndex := 0 to SkinsCount - 1 do
  begin
    CachedPainterData[SkinIndex] :=
      TdxSkinLookAndFeelPainterInfo.Create(TdxSkin.Create(SkinNames[SkinIndex], True, HInstance));
    GetExtendedStylePainters.Register(
      SkinNames[SkinIndex], SkinPainters[SkinIndex], CachedPainterData[SkinIndex]);
  end;
end;

procedure UnregisterPainters;
var
  SkinIndex: Integer;
begin
  if GetExtendedStylePainters = nil then Exit;
  for SkinIndex := 0 to SkinsCount - 1 do
    GetExtendedStylePainters.UnRegister(SkinNames[SkinIndex]);
end;

{$IFNDEF DXSKINDYNAMICLOADING}
initialization
  dxUnitsLoader.AddUnit(@RegisterPainters, @UnregisterPainters);

finalization
  dxUnitsLoader.RemoveUnit(@UnregisterPainters);
{$ENDIF}

end.
