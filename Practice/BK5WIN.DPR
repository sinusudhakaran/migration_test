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
  Forms,
  Windows,
  dialogs,
  SysUtils,
  ApplicationStartupAndShutDown in 'Win32\ApplicationStartupAndShutDown.pas',
  SPLASH in 'Win32\SPLASH.PAS' {frmSplash},
  StatusFrm in 'Win32\StatusFrm.pas' {frmStatus},
  MAINFRM in 'Win32\MAINFRM.PAS' {frmMain},
  imagesfrm in 'Win32\imagesfrm.pas' {AppImages},
  BudgetFrm in 'Win32\BudgetFrm.pas' {frmBudget},
  OSFont in 'Win32\OSFont.pas',
  winutils in 'Win32\winutils.pas',
  TSUtils in 'Win32\TSUtils.pas';

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

