unit frmCSVConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TCSVConfig = class(TForm)
    Label1: TLabel;
    eFilename: TEdit;
    btnBrowse: TButton;
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    SaveDlg: TSaveDialog;
    ckSeparate: TCheckBox;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure eFilenameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses
  ExtractHelpers;

{$R *.dfm}

procedure TCSVConfig.FormShow(Sender: TObject);
begin
  if not ValidFilePath(eFilename.Text) then
    ShowMessage('Please enter a valid path and filename');
end;

procedure TCSVConfig.btnBrowseClick(Sender: TObject);
begin
  SaveDlg.FileName := eFilename.Text;
  if SaveDlg.Execute then
    eFilename.Text := SaveDlg.FileName;
end;

procedure TCSVConfig.btnOKClick(Sender: TObject);
begin
  // Check the file/path...
  if ValidFilePath(eFilename.Text) then
    ModalResult := mrOK;
end;

procedure TCSVConfig.eFilenameChange(Sender: TObject);
begin
  btnOK.Enabled := Trim(eFileName.Text) <> '';
end;

procedure TCSVConfig.FormKeyPress(Sender: TObject; var Key: Char);
begin
   case ord(Key) of
   VK_RETURN: begin
         Key := #0;
         btnOKClick(nil);
      end;
   VK_ESCAPE: begin
         Key := #0;
         ModalResult := mrCancel;
      end;
   end;

end;

end.


