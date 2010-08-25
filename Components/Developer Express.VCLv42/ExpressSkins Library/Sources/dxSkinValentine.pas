unit dxSkinValentine;

interface

uses
  Classes, dxGDIPlusApi, cxLookAndFeelPainters, dxSkinsCore, dxSkinsLookAndFeelPainter;

type
  { TdxValentinePainter }
  TdxValentinePainter = class(TdxSkinLookAndFeelPainter)
  protected
    class function CacheData: TdxSkinLookAndFeelPainterInfo; override;
  public
    class function InternalUnitName: string; override;
  end;

const
  SkinsCount = 1;
  SkinNames: array[0..SkinsCount - 1] of string = ('Valentine');
  SkinPainters: array[0..SkinsCount - 1] of TcxCustomLookAndFeelPainterClass =
    (TdxValentinePainter);

implementation

{$R dxSkinValentine.res}

var
  CachedPainterData: array[0..SkinsCount - 1] of TdxSkinLookAndFeelPainterInfo;

{ TdxValentinePainter }

class function TdxValentinePainter.CacheData: TdxSkinLookAndFeelPainterInfo;
begin
  Result := CachedPainterData[0];
end;

class function TdxValentinePainter.InternalUnitName: string;
begin
  Result := 'dxSkinValentine';
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
