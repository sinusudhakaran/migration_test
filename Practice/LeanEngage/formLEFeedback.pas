unit formLEFeedback;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  uNPS;


type
  TfrmLEFeedback = class(TForm)
    imgIcon: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitialiseAndShowForm( aParent : TForm; aTop, aLeft : integer );
    procedure FloatForm( aTop, aLeft : integer );
  end;

var
  frmLEFeedback: TfrmLEFeedback;

implementation
{$R *.dfm}

procedure TfrmLEFeedback.FloatForm(aTop, aLeft: integer);
begin
  Top    := aTop  - Height - 44 - 20; //Compensate for scrollbars on forms
  Left   := aLeft - Width - 20 - 20;  //Compensate for scrollbars on forms
end;

procedure TfrmLEFeedback.InitialiseAndShowForm( aParent : TForm; aTop, aLeft : integer );
begin
  if aParent is TForm then begin

    Parent := aParent;
    FloatForm( aTop, aLeft );
  end;
  Show;
end;

end.

                                             
