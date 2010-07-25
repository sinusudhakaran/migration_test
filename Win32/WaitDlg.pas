unit WaitDlg;
//------------------------------------------------------------------------------
{
   Title:       Wait Dialog

   Description: Wait Dialog for use by Lock Utils unit to show how far thru waiting

   Remarks:

   Author:      Steve/Matt  Jan 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, RzPrgres;

type
  TDelayForm = class(TForm)
    lblDelay: TLabel;
    pbProgress: TRzProgressBar;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


     
//******************************************************************************
implementation

{$R *.DFM}

procedure TDelayForm.FormCreate(Sender: TObject);
begin
   pbProgress.Percent := 0;
end;
//------------------------------------------------------------------------------

end.
