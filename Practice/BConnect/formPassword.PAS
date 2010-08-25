unit formPassword;
{-----------------------------------------------------------}
{ Author:    Matthew Hopkins
  Date:      Nov 97

  Purpose:
  password dialog box}
{-----------------------------------------------------------}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TbkPasswordDialog = class ( TForm )
    txtUser: TEdit;
    txtPass: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    lblPass: TLabel;
    imgKey: TImage;

    Label1: TLabel;
    lblMsg: TLabel;
    lblName: TLabel;

    procedure FormCreate ( Sender: TObject ) ;
    procedure FormActivate ( Sender: TObject ) ;
  private
    { Private declarations }
    function GetPassword: string;
    procedure SetMessage ( msg: string ) ;
    procedure SetUser ( msg: string ) ;
  public
    { Public declarations }
    function Execute: boolean;
    property Password: string read GetPassword;
    property TextMessage: string write SetMessage;
    property DefaultUser: string write SetUser;
  end;

{-----------------------------------------------------------}
implementation

uses Globals;

{$R *.DFM}

{-----------------------------------------------------------}

procedure TbkPasswordDialog.SetUser ( msg: string ) ;
begin
  txtUser.Text := msg;
end;

procedure TbkPasswordDialog.SetMessage ( msg: string ) ;
begin
  lblMsg.caption := msg;
end;

function TbkPasswordDialog.GetPassword: string;
begin
  result := txtPass.Text;
end;

procedure TbkPasswordDialog.FormCreate ( Sender: TObject ) ;
begin
  {$IFDEF SmartBooks}
  Caption := 'Log in to SmartBooks Direct';
  {$ELSE}
  Caption := 'Log in to ' + BCONNECTNAME;
  {$ENDIF}
end;

function TbkPasswordDialog.Execute: boolean;
begin
  txtPass.text := '';
  Result := ( ShowModal = mrOK );
end;

{-----------------------------------------------------------}

procedure TbkPasswordDialog.FormActivate ( Sender: TObject ) ;
begin
  txtPass.SetFocus;
end;

end.

