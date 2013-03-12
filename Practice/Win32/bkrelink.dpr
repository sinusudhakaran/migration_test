program bkrelink;

uses
  LockUtils,
  Forms,
  frmResync in 'frmResync.pas' {ResynchronizeFrm},
  imagesfrm in 'imagesfrm.pas' {AppImages};

{$R *.res}

begin
  Application.Initialize;
  InitLocking;
  Application.CreateForm(TResynchronizeFrm, ResynchronizeFrm);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;
end.
