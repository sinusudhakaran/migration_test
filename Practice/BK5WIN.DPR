program Bk5Win;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//                          B A N K L I N K   5
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  madScreenShot,
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  Windows,
  dialogs,
  SysUtils,
  HTMLHelpViewer,
  ApplicationStartupAndShutDown in 'Win32\ApplicationStartupAndShutDown.pas',
  SPLASH in 'Win32\SPLASH.PAS' {frmSplash},
  StatusFrm in 'Win32\StatusFrm.pas' {frmStatus},
  MAINFRM in 'Win32\MAINFRM.PAS' {frmMain},
  imagesfrm in 'Win32\imagesfrm.pas' {AppImages},
  BudgetFrm in 'Win32\BudgetFrm.pas' {frmBudget},
  OSFont in 'Win32\OSFont.pas',
  GLOBALS in 'Win32\GLOBALS.PAS',
  bkBranding in 'Win32\bkBranding.pas',
  GlobalDirectories in 'Win32\GlobalDirectories.pas',
  ONEINST in 'Win32\ONEINST.PAS',
  AppUserObj in 'Win32\AppUserObj.pas',
  SYSOBJ32 in 'Win32\SYSOBJ32.PAS',
  CLOBJ32 in 'Win32\CLOBJ32.PAS',
  acList32 in 'Win32\acList32.pas',
  amList32 in 'Win32\amList32.pas',
  BALIST32 in 'Win32\BALIST32.PAS',
  BDLIST32 in 'Win32\BDLIST32.PAS',
  BLLIST32 in 'Win32\BLLIST32.PAS',
  BULIST32 in 'Win32\BULIST32.PAS',
  CFLIST32 in 'Win32\CFLIST32.PAS',
  CHLIST32 in 'Win32\CHLIST32.PAS',
  CodingStatsList32 in 'Win32\CodingStatsList32.pas',
  ctypelist32 in 'Win32\ctypelist32.pas',
  DLLIST32 in 'Win32\DLLIST32.PAS',
  grplist32 in 'Win32\grplist32.pas',
  MALIST32 in 'Win32\MALIST32.PAS',
  MXLIST32 in 'Win32\MXLIST32.PAS',
  PYLIST32 in 'Win32\PYLIST32.PAS',
  SBAList32 in 'Win32\SBAList32.pas',
  SysDList32 in 'Win32\SysDList32.pas',
  trxList32 in 'Win32\trxList32.pas',
  UELIST32 in 'Win32\UELIST32.PAS',
  usrlist32 in 'Win32\usrlist32.pas',
  LOGUTIL in 'Win32\LOGUTIL.PAS',
  BKHelp in 'Win32\BKHelp.pas',
  ThirdPartyHelper in 'Win32\ThirdPartyHelper.pas',
  AccountSelectorFme in 'Win32\AccountSelectorFme.pas' {fmeAccountSelector: TFrame},
  ClientLookupFme in 'Win32\ClientLookupFme.pas' {fmeClientLookup: TFrame},
  ClientSelectFme in 'Win32\ClientSelectFme.pas' {FmeClientSelect: TFrame},
  DateSelectorFme in 'Win32\DateSelectorFme.pas' {fmeDateSelector: TFrame},
  DivisionSelectorFme in 'Win32\DivisionSelectorFme.pas' {fmeDivisionSelector: TFrame},
  ECodingExportFme in 'Win32\ECodingExportFme.pas' {fmeECodingExport: TFrame},
  ExistingChequesFme in 'Win32\ExistingChequesFme.pas' {fmeExistingCheques: TFrame},
  RTFEditFme in 'Win32\RTFEditFme.pas' {fmeEditRTF: TFrame},
  SysAccountsfme in 'Win32\SysAccountsfme.pas' {fmeSysAccounts: TFrame},
  peList32 in 'Win32\peList32.pas',
  BKAuditValues in 'Win32\BKAuditValues.pas',
  BankLinkOnline in 'Win32\BankLinkOnline.pas',
  BanklinkOnlineSettingsFrm in 'Win32\BanklinkOnlineSettingsFrm.pas' {frmBanklinkOnlineSettings},
  BlopiClient in 'Win32\BlopiClient.pas',
  AcclipseX in 'Extract\AcclipseX.pas',
  INISettings in 'Win32\INISettings.pas',
  CustomFileFormats in 'Win32\CustomFileFormats.pas',
  ATOFixedWidthFileExtract in 'Win32\ATOFixedWidthFileExtract.pas',
  prObj32 in 'Win32\prObj32.pas',
  srObj32 in 'Win32\srObj32.pas',
  ATOExportMandatoryDataDlg in 'Win32\ATOExportMandatoryDataDlg.pas' {ATOWarningdlg};

//  ExtractHelpers in '..\Bulk Export\ExtractHelpers.pas';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$R *.RES}
//{/$R WINXP.RES}   //disabled the manifest in the res file until win98 server to xp client issue resolved

const
  UnitName = 'BK5WIN';
begin
  try //finally
    try //except
      ReadAppINI;

      frmSplash := TfrmSplash.Create(Application);
      frmSplash.show;
      frmSplash.Update;

      ApplicationStartUpAndShutDown.BeforeAppInitialize;
      Application.Initialize;
      ApplicationStartUpAndShutDown.AfterAppInitialize;
      Application.MainFormOnTaskBar := true;

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

