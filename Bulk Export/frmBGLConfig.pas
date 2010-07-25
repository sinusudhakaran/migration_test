unit frmBGLConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TBGLXMLConfig = class(TForm)
    Label1: TLabel;
    eFilename: TEdit;
    btnBrowse: TButton;
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    SaveDlg: TSaveDialog;
    eClearing: TEdit;
    ckCoding: TCheckBox;
    rbSingle: TRadioButton;
    rbSplit: TRadioButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  protected
    procedure UpdateActions; override;   
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

procedure TBGLXMLConfig.btnBrowseClick(Sender: TObject);
begin
   SaveDlg.FileName := eFilename.Text;
   if SaveDlg.Execute then
      eFilename.Text := SaveDlg.FileName;
end;

procedure TBGLXMLConfig.btnOKClick(Sender: TObject);
begin
   // Check the file/path...
   if Trim(eFilename.Text) = '' then begin
       MessageBox(Self.Handle,'No Directory','Please select a directory to use.',mb_ok );
       eFilename.SetFocus;
       Exit;
   end;

   if not ckCoding.Checked then
      if Trim(eClearing.Text) = '' then begin
         MessageBox(Self.Handle,'No Clearing Account','Please enter a default Clearing account.',mb_ok );
         eClearing.SetFocus;
         Exit;
      end;


   ModalResult := mrOK;
end;

procedure TBGLXMLConfig.FormKeyPress(Sender: TObject; var Key: Char);
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

procedure TBGLXMLConfig.updateActions;
begin
  inherited;
  eClearing.Enabled := not ckCoding.Checked
end;

end.
