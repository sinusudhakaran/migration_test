unit frm1PlaceConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TOnePlaceConfig = class(TForm)
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

  private
    { Private declarations }
  protected
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

procedure TOnePlaceConfig.btnBrowseClick(Sender: TObject);
begin
   SaveDlg.FileName := eFilename.Text;
   if SaveDlg.Execute then
      eFilename.Text := SaveDlg.FileName;
end;

procedure TOnePlaceConfig.btnOKClick(Sender: TObject);
begin
   // Check the file/path...
   if Trim(eFilename.Text) = '' then begin
       MessageBox(Self.Handle,'No Directory','Please select a directory to use.',mb_ok );
       eFilename.SetFocus;
       Exit;
   end;




   ModalResult := mrOK;
end;

procedure TOnePlaceConfig.FormKeyPress(Sender: TObject; var Key: Char);
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
