program MobilePractice;

uses
  System.StartUpCopy,
  FMX.Forms,
  RatingsListViewForm in 'RatingsListViewForm.pas' {frmMainForm},
  RatingListItems in 'RatingListItems.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
