program bkrelink;

uses
  Forms,
  frmResync in 'frmResync.pas' {ResynchronizeFrm},
  FILES in 'FILES.PAS',
  CLOBJ32 in 'CLOBJ32.PAS',
  BKDEFS in '..\Shared\BKDEFS.PAS',
  MONEYDEF in '..\Shared\MONEYDEF.PAS',
  DATEDEF in '..\Shared\DATEDEF.PAS',
  stdate in '..\..\Components\Turbopower\SysTools for BK5\stdate.pas',
  imagesfrm in 'imagesfrm.pas' {AppImages};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TResynchronizeFrm, ResynchronizeFrm);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;
end.
