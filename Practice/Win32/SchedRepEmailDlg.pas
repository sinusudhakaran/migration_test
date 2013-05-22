unit SchedRepEmailDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Schedule Reports default email message dialog

  Written: Feb 2000
  Authors: Matthew

  Purpose: Allow the user to setup a standard email that the clients reports
           will be attached to.

  Notes:   Updates the admin system if ok clicked
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkOKCancelDlg, StdCtrls, ExtCtrls,
  OsFont;

type
  TdlgSchedReportEmail = class(TbkOKCancelDlgForm)
    label1: TLabel;
    edtSubject: TEdit;
    memBody: TMemo;
    Label3: TLabel;
    InfoBmp: TImage;
    procedure FormCreate(Sender: TObject);
    procedure memBodyKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function EditScheduledReportsMessage( Title : string;
                                        LabelCaption : string;
                                        var Subject : string;
                                        var Body : string) : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes, bkBranding;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSchedReportEmail.FormCreate(Sender: TObject);
begin
  inherited;
  //bkXPThemes.ThemeForm( Self); in OKCancel

  edtSubject.Text := bkBranding.Rebrand(edtSubject.Text);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditScheduledReportsMessage( Title : string;
                                      LabelCaption : string;
                                      var Subject : string;
                                      var Body : string) : boolean;

const
   ThisMethodName = 'EditScheduledReportsEmail';
begin
   result := false;
   with TdlgSchedReportEmail.Create(Application.Mainform) do
   try
      Caption := Title;
      label3.Caption := LabelCaption;

      if (Subject = #$FF) then
      begin
        //hide the subject line
        Subject := '';
        Label1.Visible := False;
        edtSubject.Visible := False;
      end else
        edtSubject.Text := Subject;
      memBody.Text    := Body;

      ShowModal;
      if ModalResult = mrOK then begin
         //save results
         Subject := edtSubject.Text;
         Body    := memBody.Text;

         Result  := true;
      end;
   finally
      Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSchedReportEmail.memBodyKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then
    btnCancel.Click;
end;

end.
