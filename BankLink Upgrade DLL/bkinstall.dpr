program bkinstall;
//------------------------------------------------------------------------------
{
   Title:       Stand alone installer app

   Description: This app takes command line parameters and installs applications
                from the list of applications in the <appid>.xml file

   Author:      Matthew Hopkins  Feb 2006

   Remarks:     will be passed the following command line parameters
                bkinstall <appid>

                expected the bkupgcor.dll file to be in this directory


}
//------------------------------------------------------------------------------
{%TogetherDiagram 'ModelSupport_bkinstall\default.txaPackage'}

uses
  Dialogs,
  Forms,
  SysUtils,
  upgConstants,
  upgClientCommon in 'upgClientCommon.pas';

{$R *.res}
var
  Upgrader : TBkCommonUpgrader;
  aAppID : integer;


procedure SetCommandLineParameters;
const
  AppIDSwitch = '/aid=';
  MaxAppIDLength = 8;
var
  i : integer;
  s : string;
  p : string;
begin
  for i := 1 to ParamCount do
  begin
    s := lowercase( ParamStr(i));
    if Pos( AppIDSwitch, S) > 0 then
    begin
      //appid
      p := Copy( S, Pos( AppIDSwitch, S) + Length(AppIDSwitch), MaxAppIDLength);
      if p <> '' then
        aAppID := StrToIntDef( p, -1);
    end;
  end;
end;


begin
  Application.Initialize;

  aAppID := -1;
  SetCommandLineParameters;

  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    //process <appid>.xml file, install components that must be installed when
    //the main app is closed
    case Upgrader.InstallUpdates( 'BankLink Installer', 0, aAppID, ifUpgradeWithAppClosed,0) of
      uaUnableToLoad : ShowMessage('Load failed');
    end;
  finally
    Upgrader.Free;
  end;

  Application.Title := 'BankLink Installer';
  Application.Run;
end.
