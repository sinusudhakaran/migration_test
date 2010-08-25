unit ClientNotesFrm;
//------------------------------------------------------------------------------
{
   Title:       Client notes form

   Description: Show client notes when file is opened if flag is set

   Remarks:

   Author:      Matthew Hopkins Jun01

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

type
  TfrmClientNotes = class(TForm)
    meNotes: TMemo;
    Panel1: TPanel;
    chkShowOnOpen: TCheckBox;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function ShowClientNotes : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
   bkXPThemes,
   Globals;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ShowClientNotes : boolean;
var
   i : integer;
   S : string;
begin
   result := false;
   with TfrmClientNotes.Create(Application.MainForm)  do begin
      try
         chkShowOnOpen.checked := MyClient.clFields.clShow_Notes_On_Open;
         //load notes field from notes array
         meNotes.Lines.Clear;
         S := '';
         with MyClient.clFields do begin
            for i := Low( clNotes) to High( clNotes) do
               S := S + clNotes[i];
         end;
         meNotes.Text := S;
         ShowModal;
         MyClient.clFields.clShow_Notes_On_Open := chkShowOnOpen.Checked;
      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientNotes.btnOKClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientNotes.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
