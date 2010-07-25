unit NewAmountDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF,
  bkXPThemes,
  OSFont;

type
  TdlgNewAmount = class(TForm)
    Label1: TLabel;
    OvcController1: TOvcController;
    eAmount: TOvcNumericField;
    btnCancel: TButton;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
     okPressed : boolean;
  public
    { Public declarations }
    function Execute(var Amount: double): boolean;
  end;



//******************************************************************************
implementation
{$R *.DFM}
uses
   Globals;

//------------------------------------------------------------------------------
procedure TdlgNewAmount.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TdlgNewAmount.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eAmount.Hint     :=
                    'Enter the Amount for this transaction|' +
                    'Enter the Amount for this transaction';
end;
//------------------------------------------------------------------------------
procedure TdlgNewAmount.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgNewAmount.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
function TdlgNewAmount.Execute(var Amount : double) :boolean;
begin
  result := false;

  okPressed := false;
  eAmount.asFloat := Amount;
  ShowModal;

  if okPressed then
  begin
    result := true;
    Amount := eAmount.AsFloat;
  end;
end;    //
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
