unit TransactionNotesFrm;
//------------------------------------------------------------------------------
{
   Title:       

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  bkDefs;

type
  TfrmTransactionNotes = class(TForm)
    memImportNotes: TMemo;
    memNotes: TMemo;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }

    OkPressed : boolean;
  public
    { Public declarations }
    parentTrans  : pTransaction_Rec;
  end;

var
   frmTransactionNotes : TfrmTransactionNotes;

var
   NotesShowing : boolean;

//******************************************************************************
implementation

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTransactionNotes.FormShow(Sender: TObject);
begin
   NotesShowing := true;

   if not Assigned( parentTrans) then exit;

   if parentTrans^.txECoding_Import_Notes <> '' then begin
      memImportNotes.Text := parentTrans^.txECoding_Import_Notes;
      memImportNotes.Visible := true;
   end;

   memNotes.Text := parentTrans^.txNotes;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTransactionNotes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTransactionNotes.btnOKClick(Sender: TObject);
begin
   OkPressed := true;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTransactionNotes.FormCreate(Sender: TObject);
begin
   OkPressed := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmTransactionNotes.btnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmTransactionNotes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   NotesShowing := false;
end;

initialization
   NotesShowing := false;

end.
