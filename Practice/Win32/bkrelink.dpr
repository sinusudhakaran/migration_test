program bkrelink;

uses
  Forms,
  frmResync in 'frmResync.pas' {ResynchronizeFrm},
  imagesfrm in 'imagesfrm.pas' {AppImages};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TResynchronizeFrm, ResynchronizeFrm);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;
end.
