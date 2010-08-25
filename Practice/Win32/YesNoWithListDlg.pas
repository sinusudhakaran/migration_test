unit YesNoWithListDlg;
//------------------------------------------------------------------------------
{
   Title:       Yes No Dlg with List box

   Description: Used during refresh chart so can show long list of items


   Author:      Matthew Hopkins  Jun 2004

   Remarks:     Have not made this generic as there is current no demand for it

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  bkXPThemes,
  OSFont;

type
  TdlgYesNoWithList = class(TForm)
    btnYes: TButton;
    btnNo: TButton;
    btnCancel: TButton;
    lblHeaderMsg: TLabel;
    lblFooterMsg: TLabel;
    memItems: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function AskYesNoWithList( aTitle : string;
                           aHeaderMsg : string;
                           aListText : string;
                           aFooterMsg : string
                          ) : TModalResult;

//******************************************************************************
implementation

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AskYesNoWithList( aTitle : string;
                           aHeaderMsg : string;
                           aListText : string;
                           aFooterMsg : string
                          ) : TModalResult;
begin
  with TdlgYesNoWithList.Create( Application.Mainform) do
  begin
    try
      Caption := aTitle;

      lblHeaderMsg.Caption := aHeaderMsg;
      lblFooterMsg.Caption := aFooterMsg;
      memItems.Lines.Text := aListText;

      result := ShowModal;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure TdlgYesNoWithList.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
