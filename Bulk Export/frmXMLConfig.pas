unit frmXMLConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TXMLConfig = class(TForm)
    Label1: TLabel;
    eFilename: TEdit;
    btnBrowse: TButton;
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    SaveDlg: TSaveDialog;
    rbSingle: TRadioButton;
    rbSplit: TRadioButton;
    Label2: TLabel;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  protected
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses
  FileCtrl, ExtractHelpers;

procedure TXMLConfig.btnBrowseClick(Sender: TObject);
begin
   SaveDlg.FileName := eFilename.Text;
   SaveDlg.InitialDir := ExtractFilePath(eFilename.Text);
   if SaveDlg.Execute then
      eFilename.Text := SaveDlg.FileName;
end;

procedure TXMLConfig.btnOKClick(Sender: TObject);
begin
  // Check the file/path...
  if ValidFilePath(eFilename.Text) then
    ModalResult := mrOK;
end;

procedure TXMLConfig.FormKeyPress(Sender: TObject; var Key: Char);
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


procedure TXMLConfig.FormShow(Sender: TObject);
begin
  if not ValidFilePath(eFilename.Text) then
    ShowMessage('Please enter a valid path and filename');
end;

end.
