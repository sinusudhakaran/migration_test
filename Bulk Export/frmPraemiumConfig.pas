unit frmPraemiumConfig;
///------------------------------------------------------------------------------
///  Title:   Praemium Config form
///
///  Written: June 2009
///
///  Authors: Andre' Joosten
///
///  Purpose:
///
///  Notes:
///
///------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TPraemiumConfig = class(TForm)
    lSave: TLabel;
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
  protected
    procedure UpdateActions; override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

procedure TPraemiumConfig.btnBrowseClick(Sender: TObject);
begin
   SaveDlg.FileName := eFilename.Text;
   if SaveDlg.Execute then
      eFilename.Text := SaveDlg.FileName;
end;

procedure TPraemiumConfig.btnOKClick(Sender: TObject);
begin
   // Check the file/path...
   ModalResult := mrOK;
end;

procedure TPraemiumConfig.FormKeyPress(Sender: TObject; var Key: Char);
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

procedure TPraemiumConfig.UpdateActions;
begin
  inherited;
  if ckSeparate.Checked then
     lSave.Caption := 'Save in directory'
  else
     lsave.Caption := 'Save to file';
end;

end.
