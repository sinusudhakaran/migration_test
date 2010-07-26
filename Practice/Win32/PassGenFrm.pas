unit PassGenFrm;
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, RzLabel, ExtCtrls;

type
  TfrmPassGen = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    eSeed: TEdit;
    Button1: TButton;
    Button2: TButton;
    edtPass: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure SetUpHelp;
  public
    { Public declarations }
  end;

var
  frmPassGen: TfrmPassGen;

//******************************************************************************
implementation
{$R *.DFM}

uses
   PwdSeed;

//------------------------------------------------------------------------------
procedure TfrmPassGen.btnCloseClick(Sender: TObject);
begin

end;
//------------------------------------------------------------------------------
procedure TfrmPassGen.btnGenerateClick(Sender: TObject);
begin

end;
//------------------------------------------------------------------------------
procedure TfrmPassGen.FormCreate(Sender: TObject);
begin
   left := 10;
   top  := 10;
{$IFDEF SmartBooks}
   Self.Caption := 'SmartBooks Password Utility';
{$ENDIF}
   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPassGen.SetUpHelp;
begin
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfrmPassGen.Button1Click(Sender: TObject);
var
   Err : integer;
   Va  : integer;
begin
   Val(eSeed.Text,Va,Err);
   edtPass.text := PasswordFromSeed(Va);
   edtPass.SelectAll;
   edtPass.CopyToClipboard;
end;

procedure TfrmPassGen.Button2Click(Sender: TObject);
begin
   Close;
end;

end.
