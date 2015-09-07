unit frmAdoptOrSynchronise;
//------------------------------------------------------------------------------
{
   Title:         Adopt or Sync form

   Description:   Allows the user to select whether to adopt or sync a client

   Author:        Matthew Hopkins  Nov 2007

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const
  asAdoptClient = 1;
  asSyncroniseClient = 2;

type
  TAdoptOrSyncFrm = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    btnAdopt: TButton;
    btnSync: TButton;
    btnCancel: TButton;
    ShapeBorder: TShape;
    procedure btnCancelClick(Sender: TObject);
    procedure btnAdoptClick(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
  private
    { Private declarations }
    Response : word;
  public
    { Public declarations }
    function Execute : word;
  end;

  function AdoptOrSynchronise( aClientCode : string) : word;


implementation
{$R *.dfm}

uses
  bkConst;

function AdoptOrSynchronise( aClientCode : string) : word;
var
  MyDlg : TAdoptOrSyncFrm;
begin
  MyDlg := TAdoptOrSyncFrm.Create(Application);
  try
    MyDlg.Caption := 'Adopt or Synchronise? ' + aClientCode;
    result            := MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

{ TAdoptOrSyncFrm }

procedure TAdoptOrSyncFrm.btnAdoptClick(Sender: TObject);
begin
  Response := asAdoptClient;
  Close;
end;

procedure TAdoptOrSyncFrm.btnCancelClick(Sender: TObject);
begin
  Response := 0;
  Close;
end;

procedure TAdoptOrSyncFrm.btnSyncClick(Sender: TObject);
begin
  Response := asSyncroniseClient;
  Close;
end;

function TAdoptOrSyncFrm.Execute: word;
begin
   Response := 0;   //cancel
   Self.ShowModal;
   result := response;
end;

end.
