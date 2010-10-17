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
  SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2005 v4.7',bmp.Handle,false,'Registered','');
  {$ENDIF}
  {$IFDEF VER180}
    {$IFDEF VER185}
    SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2007  v4.7',bmp.Handle,false,'Registered','');
    {$ENDIF}
    {$IFNDEF VER185}
    SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2006 v4.7',bmp.Handle,false,'Registered','');
    {$ENDIF}
  {$ENDIF} 
  {$IFDEF VER200}
    SplashScreenServices.AddPluginBitmap('TMS Component Pack Pro for Delphi 2008 v4.7',bmp.Handle,false,'Registered','');
  {$ENDIF} 
  bmp.Free;
end;

begin
  AddSplash;

end.
