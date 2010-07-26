program Bk5Win;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//                          B A N K L I N K   5
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  GraphicEx,
  HTMLHelpViewer,
  Forms,
  Windows,
  dialogs,
  SysUtils,
  SQASrvr,
  ApplicationStartupAndShutDown,
  MAINFRM,
  StatusFrm,
  imagesfrm,
  splash;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$R *.RES}
//{/$R WINXP.RES}   //disabled the manifest in the res file until win98 server to xp client issue resolved

const
  UnitName = 'BK5WIN';
begin
  try //finally
    try //except
      frmSplash := TfrmSplash.Create(Application);
      frmSplash.show;
      frmSplash.Update;

      ApplicationStartUpAndShutDown.BeforeAppInitialize;
      Application.Initialize;
      ApplicationStartUpAndShutDown.AfterAppInitialize;

      //********************************************
      //delphi generated code
      Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TAppImages, AppImages);
  Application.CreateForm(TfrmStatus, frmStatus);
  //********************************************
      ApplicationStartUpAndShutDown.AfterFormCreation;
    except
      On E : Exception do
      begin
        HandleStartUpError( E);
      end;
    end;
  finally
    frmSplash.Close;
    frmSplash.Free;
  end;

  //********************************************
  //finally ready to run the application
  Application.Run;
  //********************************************

  ApplicationStartUpAndShutDown.ApplicationShutDown;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

