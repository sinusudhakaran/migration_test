program bkmap;

uses
  LockUtils,
  Forms,
  frmMapChecker in 'frmMapChecker.pas' {MainForm},
  imagesfrm in '..\Win32\imagesfrm.pas' {AppImages};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BK Map';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAppImages, AppImages);
  InitLocking;
  Application.Run;
end.
