// Preview the email merge

unit EmailMergePreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, OpShared, OpWrdXP, OpWord;

type
  TfrmMailMergePreview = class(TForm)
    Label1: TLabel;
    lblDocument: TLabel;
    Label3: TLabel;
    mmoClients: TMemo;
    btnOk: TButton;
    btnCancel: TButton;
    WordPreview: TOpWord;
    lblSubject: TLabel;
    procedure lblDocumentClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mmoClientsEnter(Sender: TObject);
  private
    { Private declarations }
    FFilename: string;
  public
    { Public declarations }
    property Filename: string read FFilename write FFilename;
  end;

var
  frmMailMergePreview: TfrmMailMergePreview;

function PreviewMailMerge(Codes: TStringList; DocName, Subject: string): Boolean;

implementation

uses SyDefs, ShellAPI, ClientDetailCacheObj, GlobalDirectories, WinUtils;

{$R *.dfm}

procedure TfrmMailMergePreview.lblDocumentClick(Sender: TObject);
var
  i: Integer;
  TempFilename: string;
begin
  // We still have the original open because merge isnt finished yet
  // So create a copy to avoid the 'open read-only?' question that Word asks.

  // Find a unique filename
  i := 1;
  TempFilename := glDataDir + 'Preview' + IntToStr(i) + ExtractFilename(FFilename);
  while BKFileExists(TempFilename) do
  begin
    Inc(i);
    TempFilename := glDataDir + 'Preview' + IntToStr(i) + ExtractFilename(FFilename);
  end;

  // Copy and open
  CopyFile(PChar(FFilename), PChar(TempFilename), False);
  WordPreview.OpenDocument(TempFilename);
end;

// Show doc, subject and clients before sending
function PreviewMailMerge(Codes: TStringList; DocName, Subject: string): Boolean;
var
  i: Integer;
  cfRec: pClient_File_Rec;
begin
  with TfrmMailMergePreview.Create(nil) do
  begin
    try
      lblDocument.Caption := '"' + ExtractFilename(DocName) + '"';
      lblSubject.Caption := '"' + Subject + '"';
      Filename := DocName;
      mmoClients.Clear;
      for i := 0 to Pred(Codes.Count) do
      begin
        cfRec := pClient_File_rec(Codes.Objects[i]);
        with ClientDetailsCache do
        begin
          Load(cfRec^.cfLRN);
          if Email_address = '' then
            mmoClients.Lines.Add('<no email address>' + ' will NOT be sent to ' + cfRec^.cfFile_Code + ' (' + Name + ')')
          else
            mmoClients.Lines.Add(Email_Address + ' at ' + cfRec^.cfFile_Code + ' (' + Name + ')');
        end;
      end;
      Result := ShowModal = mrOk;
      Application.ProcessMessages;
    finally
      Free;
    end;
  end;
end;

procedure TfrmMailMergePreview.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  WordPreview.Connected := False;
end;

// Do not allow anything to happen in the memo
procedure TfrmMailMergePreview.mmoClientsEnter(Sender: TObject);
begin
 SelectNext(ActiveControl as TWinControl, True, True);
end;

end.
