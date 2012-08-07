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
    lblCrDr: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure eAmountKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    okPressed : boolean;
    fAllowNegativeValues : Boolean;
    fIsCr : Boolean;
  public
    { Public declarations }
    function Execute(var Amount: double): boolean;

    property AllowNegativeValues : Boolean read fAllowNegativeValues write fAllowNegativeValues default true;
    property IsCr : Boolean read fIsCr write fIsCr default true;
  end;



//******************************************************************************
implementation
{$R *.DFM}

uses
  Globals;

const
  NEGLOWVALUE = '-1.7E+0308';
  NONEGLOWVALUE = '0';

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
procedure TdlgNewAmount.eAmountKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '-') and
     (not fAllowNegativeValues) then
    Key := #0;
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

  if (not fAllowNegativeValues) and
     (fIsCr) then
    eAmount.asFloat := -Amount
  else
    eAmount.asFloat := Amount;

  if fAllowNegativeValues then
  begin
    eAmount.RangeLo := NEGLOWVALUE;
    lblCrDr.Visible := false;
  end
  else
  begin
    eAmount.RangeLo := NONEGLOWVALUE;
    lblCrDr.Visible := true;
    if fIsCr then
      lblCrDr.Caption := 'CR'
    else
      lblCrDr.Caption := 'DR';
  end;

  ShowModal;

  if okPressed then
  begin
    result := true;
    if (not fAllowNegativeValues) and
       (fIsCr) then
      Amount := -eAmount.AsFloat
    else
      Amount := eAmount.AsFloat;
  end;
end;


end.
