program LockTest;

uses
  Forms,
  LockingTestFrm in 'LockingTestFrm.pas' {TestLockingFrm},
  imagesfrm in 'imagesfrm.pas' {AppImages},  
  ErrorLog in 'Errorlog.pas';

{$R *.RES}

begin
  if Assigned(SysLog) then begin
    SysLog.SysLogStart;                           
  end;

  Application.Initialize;
  Application.CreateForm(TTestLockingFrm, TestLockingFrm);
  Application.CreateForm(TAppImages, AppImages);

  Application.Run;
end.
