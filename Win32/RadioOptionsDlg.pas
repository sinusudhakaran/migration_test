unit RadioOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:       Radio Options Dialog

   Description: Generation Dialog for up to 4 radio buttons

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  OsFont;

type
  TdlgRadioOptions = class(TForm)
    lblLine1: TLabel;
    lblLine2: TLabel;
    radRadio1: TRadioButton;
    radRadio2: TRadioButton;
    radRadio3: TRadioButton;
    radRadio4: TRadioButton;
    Panel1: TPanel;
    btnButton1: TButton;
    btnButton2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FHelpID : Integer;
  public
    { Public declarations }
  end;

function SelectFromRadioDialog( aTitle : string; aCaption : string;
                                   Button1Text : string;
                                   Button2Text : string;
                                   HelpCtx : integer;
                                   Item1 : string = '';
                                   Item2 : string = '';
                                   Item3 : string = '';
                                   Item4 : string = '') : integer;

//******************************************************************************
implementation

{$R *.dfm}

uses
  bkXPThemes,
  bkHelp;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgRadioOptions.FormShow(Sender: TObject);
const
  Gap = 10;
var
  TopPosition : integer;
  S : string;
begin
  bkHelp.BKHelpSetUp( Self, FHelpID);

  //reapply captions to force controls to resize themselves
  S := lblLine1.Caption;
  lblLine1.Caption := '';
  lblLine1.Width := Self.ClientWidth - ( lblLine1.Left * 2);
  lblLine1.Caption := S;

  S := lblLine2.Caption;
  lblLine2.Caption := '';
  lblLine2.Width := Self.ClientWidth - ( lblLine2.Left * 2);
  lblLine2.Caption := S;

  //position label 2
  lblLine2.Top := lblLine1.Top + lblLine1.Height + Gap;
  if lblLine2.Caption = '' then
    TopPosition := lblLine2.Top
  else
    TopPosition := lblLine2.Top + lblLine2.Height;

  //position all radio controls
  TopPosition := TopPosition + ( Gap * 2);

  radRadio1.Top := TopPosition;
  TopPosition   := TopPosition + radRadio1.Height + Gap;

  radRadio2.Top := TopPosition;
  TopPosition   := TopPosition + radRadio2.Height + Gap;

  if radRadio3.Visible then
  begin
    radRadio3.Top := TopPosition;
    TopPosition   := TopPosition + radRadio3.Height + Gap;

    if radRadio4.Visible then
    begin
      radRadio4.Top := TopPosition;
      TopPosition   := TopPosition + radRadio4.Height + Gap;
    end;
  end;

  Self.ClientHeight := TopPosition + ( Gap * 2) + Panel1.Height;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgRadioOptions.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  lblLine1.Caption := '';
  lblLine2.Caption := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectFromRadioDialog( aTitle : string; aCaption : string;
                                   Button1Text : string;
                                   Button2Text : string;
                                   HelpCtx : integer;
                                   Item1 : string = '';
                                   Item2 : string = '';
                                   Item3 : string = '';
                                   Item4 : string = '') : integer;
//parameters   Title         : dialog title
//             Caption       : dialog caption
//             Item1..4      : text for radio buttons, button will not be displayed if blank
//
//returns -1 if cancel press, otherwise return radio number
begin
   result := -1;
   with TdlgRadioOptions.Create(Application.MainForm) do
   begin
     try
       Caption := aTitle;
       lblLine1.Caption := aCaption;
       lblLine2.Caption := '';

       radRadio1.Caption := Item1;
       radRadio1.Visible := radRadio1.caption <> '';
       radRadio2.Caption := Item2;
       radRadio2.Visible := radRadio2.caption <> '';
       radRadio3.Caption := Item3;
       radRadio3.Visible := radRadio3.caption <> '';
       radRadio4.Caption := Item4;
       radRadio4.Visible := radRadio4.caption <> '';

       radRadio1.Checked := True;
       BtnButton1.Caption := Button1Text;
       BtnButton2.Caption := Button2Text;

       FHelpID := HelpCtx;

       if ShowModal = mrOK then
       begin
         if radRadio1.Checked then
           result := 1
         else
         if radRadio2.Checked then
           result := 2
         else
         if radRadio3.Checked then
           result := 3
         else
         if radRadio4.Checked then
           result := 4;
       end;
     finally
       Free;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
