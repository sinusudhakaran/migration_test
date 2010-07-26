unit DelChequeDlg;
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,bkXPThemes,
  OSFont;

//------------------------------------------------------------------------------
Const
   DLG_ENTRY = 1;
   DLG_RANGE = 2;
   DLG_CANCEL= 3;

type
  TdlgDelCheque = class(TForm)
    btnEntry: TButton;
    btnRange: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    InfoBmp: TImage;
    procedure btnCancelClick(Sender: TObject);
    procedure btnRangeClick(Sender: TObject);
    procedure btnEntryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    FResult : integer;              
  public
    { Public declarations }
    function Execute : integer;
  end;

//******************************************************************************
implementation
{$R *.DFM}
uses
   Globals;
//------------------------------------------------------------------------------
procedure TdlgDelCheque.btnCancelClick(Sender: TObject);
begin
   FResult := DLG_CANCEL;
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgDelCheque.btnRangeClick(Sender: TObject);
begin
   FResult := DLG_RANGE;
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgDelCheque.btnEntryClick(Sender: TObject);
begin
   FResult := DLG_ENTRY;
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgDelCheque.FormCreate(Sender: TObject);
begin
   FResult := DLG_CANCEL;
   bkXPThemes.ThemeForm(Self);
   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelCheque.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   btnEntry.Hint    :=
                    'Delete an Unpresented Cheque|' +
                    'Delete an Unpresented Cheque';
   btnRange.Hint    :=
                    'Delete a range of Unpresented Cheques|' +
                    'Delete a range of Unpresented Cheques';
end;
//------------------------------------------------------------------------------
function TdlgDelCheque.Execute: integer;
begin
   label1.Caption := 'The entry you are trying to delete is an Unpresented Cheque.'+#13+#13+

                     'To delete this entry only, click ''Delete Entry''.'+#13+
                     'To delete an incorrect cheque range click ''Delete Range''.'+#13+#13+

                     'To return to coding without deleting anything click ''Cancel''.';

   ShowModal;
   result := FResult;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
