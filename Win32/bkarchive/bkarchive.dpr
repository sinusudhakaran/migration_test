program bkarchive;

uses
//  FastMM4,
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  frmMapChecker in 'frmMapChecker.pas' {MainForm},
  TPAfrm in '..\Authority Forms\TPAfrm.pas' {frmTPA},
  CAFfrm in '..\Authority Forms\CAFfrm.pas' {frmCAF},
  imagesfrm in '..\imagesfrm.pas' {AppImages},
  uprintpreview in 'uprintpreview.pas' {Printpreview};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BankLink Archive Check';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAppImages, AppImages);
  Application.CreateForm(TPrintpreview, Printpreview);
  Application.Run;
end.
