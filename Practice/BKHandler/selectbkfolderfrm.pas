unit selectbkfolderfrm;

interface
//simple form for selection which bk5 folder to send the dde commands to
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmSelectBK5Folder = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lblCheckin: TLabel;
    lblBK5File: TLabel;
    cbPaths: TListBox;
    lblFilename: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbPathsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function SelectBK5Folder( PathsList : string; filename : string) : string;

implementation

{$R *.dfm}

function SelectBK5Folder( PathsList : string; filename : string) : string;
//allows the user to select a bk5 folder, returns empty string
//if nothing selected or cancel pressed
var
  dlg : TfrmSelectBK5Folder;
begin
  result := '';
  dlg := TfrmSelectBK5Folder.Create( Application);
  try
    //fill box
    dlg.cbPaths.Items.Text := PathsList;
    dlg.lblFilename.Caption  := ExtractFileName( filename);

    if dlg.ShowModal = mrOK then
    begin
      //return selected item
      if dlg.cbPaths.ItemIndex <> - 1 then
        result := dlg.cbPaths.Items[ dlg.cbpaths.ItemIndex];
    end;
  finally
    dlg.Release;
  end;
end;

procedure TfrmSelectBK5Folder.cbPathsDblClick(Sender: TObject);
begin
  btnOK.Click;
end;



procedure TfrmSelectBK5Folder.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if cbPaths.ItemIndex = -1 then
    begin
      MessageDlg( 'Please select a BankLink folder', mtInformation, [mbOK], 0);
      CanClose := false;
    end;
  end;
end;

end.
