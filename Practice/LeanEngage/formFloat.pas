unit formFloat;

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
  end;

var
  frmLEFeedback: TfrmLEFeedback;

implementation
{$R *.dfm}

procedure TfrmLEFeedback.InitialiseAndShowForm( aParent : TForm; aTop, aLeft : integer );
begin
  if aParent is TForm then begin

    Parent := aParent;
    Top    := aTop  - Height - 40;
    Left   := aLeft - Width - 40;
  end;
  Show;
end;

end.

                                             
