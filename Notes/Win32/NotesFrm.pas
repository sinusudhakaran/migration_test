unit NotesFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BaseFrm, StdCtrls,
  ecObj, ExtCtrls;

type
  TfrmNotes = class(TfrmBase)
    memNotes: TMemo;
    pnlFooter: TPanel;
    chkShowNotesOnOpen: TCheckBox;
    btnClose: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    MyClientFile : TEcClient;
  public
    { Public declarations }
  end;

  procedure ShowNotes(aClientFile : TEcClient);

var
  frmNotes: TfrmNotes;

implementation

{$R *.dfm}

uses
  ecColors;

procedure TfrmNotes.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNotes.FormShow(Sender: TObject);
begin
  inherited;
  btnClose.SetFocus;
end;

procedure TfrmNotes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(MyClientFile) then
    MyClientFile.ecFields.ecShow_Notes_On_Open := (chkShowNotesOnOpen.Checked);
end;

procedure ShowNotes(aClientFile: TEcClient);
begin
  //create the form
  if (not Assigned(frmNotes)) then
    frmNotes := TfrmNotes.Create(Application);
    
  //display it
  with frmNotes do
  begin
    MyClientFile := aClientFile;
    memNotes.Text := MyClientFile.ecFields.ecNotes;
    chkShowNotesOnOpen.Checked := (MyClientFile.ecFields.ecShow_Notes_On_Open);
    Show;
  end;
end;

procedure TfrmNotes.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  if Assigned( MyClientFile) then
    if (memNotes.Text <> MyClientFile.ecFields.ecNotes) then
      MyClientFile.ecFields.ecNotes := memNotes.Text;
end;

end.
