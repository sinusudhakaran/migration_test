unit TMSSplash;

interface

uses
  ToolsApi, Windows, Classes, Graphics;

{$R TMSSPLASH.RES}

implementation

procedure AddSplash;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.LoadFromResourceName(HInstance, 'TMSSPLASH');
  {$IFDEF VER170}
  SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2005 v3.8',bmp.Handle,false,'Registered','');
  {$ENDIF}
  {$IFDEF VER180}
  SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2006 v3.8',bmp.Handle,false,'Registered','');
  {$ENDIF}
  bmp.Free;
end;

begin
  AddSplash;

end.
