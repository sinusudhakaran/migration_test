// Create a new merge doc by linking it to a data source containing the BK merge fields

unit CreateMergeDocDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, OpShared, OpWrdXP, OpWord, ExtCtrls,
  OSFont;

type
  TfrmCreateMergeDoc = class(TForm)
    GroupBox1: TGroupBox;
    rbNew: TRadioButton;
    rbExisting: TRadioButton;
    edtDocument: TEdit;
    btnFromFile: TSpeedButton;
    OpenDialog1: TOpenDialog;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    edtSave: TEdit;
    btnToFile: TSpeedButton;
    SaveDialog1: TSaveDialog;
    GroupBox3: TGroupBox;
    chkOpen: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    InfoBmp: TImage;
    Label5: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnToFileClick(Sender: TObject);
    procedure btnFromFileClick(Sender: TObject);
    procedure rbExistingClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FowMerge: TOpWord;
    FDataSource: string;
    procedure CreateDoc;
    function VerifyForm: Boolean;
  public
    { Public declarations }
    property Word: TOpWord read FowMerge write FowMerge;
    property DataSource: string read FDataSource write FDataSource;
  end;


const
  UnitName = 'CreateMergeDocDlg';

procedure PerformDocCreation(WordObj: TOpWord; var LoseFocus: Boolean);

implementation

uses ImagesFrm, WarningMoreFrm, ErrorMoreFrm, InfoMoreFrm, YesNoDlg, Globals, WinUtils,
  GlobalDirectories, bkXPThemes, progress, LogUtil, bkHelp, ShellAPI,
  bkBranding;

{$R *.dfm}

procedure TfrmCreateMergeDoc.CreateDoc;
const
  ThisMethodName = 'CreateDoc';
var
  MergeDoc: TOpWordDocument;
  filename, sql, idx, changes: OleVariant;
  i: Integer;
  DocumentName: string;
begin
  UpdateAppStatus('Creating Document', 'Please wait...', 50, True);
  try
    DocumentName := ExtractFilePath(edtSave.Text);
    if DocumentName = '' then
      DocumentName := GlobalDirectories.glDataDir + edtSave.Text
    else
      DocumentName := edtSave.Text;
    if rbNew.Checked then
      MergeDoc := FowMerge.NewDocument
    else
      MergeDoc := FowMerge.OpenDocument(edtDocument.Text);
    FowMerge.Visible := False;
    try
      // Close everything else
      i := 1;
      changes := False;
      while FowMerge.Server.Documents.Count > 1 do
      begin
        idx := i;
        if Pos(MergeDoc.Name, FowMerge.Server.Documents.Item(idx).Name) > 0 then
          Inc(i)
        else
        begin
          FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
          Sleep(500); // Time for Word to close the docs
        end;
      end;
      filename := FDataSource;
      sql := 'select * from ' + FDataSource;
      if FowMerge.OfficeVersion = ov2000 then
        MergeDoc.AsDocument.MailMerge.OpenDataSource2000(filename, emptyParam,
          emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
          emptyParam, emptyParam, emptyParam, filename, sql, emptyParam)
      else
        MergeDoc.AsDocument.MailMerge.OpenDataSource(filename, emptyParam, emptyParam, emptyParam,
          emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam, emptyParam,
          filename, sql, emptyParam,emptyParam,emptyParam);
      MergeDoc.SaveAs(DocumentName);
      UpdateAppStatusPerc( 70, True);
      // Close everything else
      i := 1;
      changes := False;
      while FowMerge.Server.Documents.Count > 1 do
      begin
        idx := i;
        if chkOpen.Checked and (Pos(ExtractFilename(DocumentName),
                                    FowMerge.Server.Documents.Item(idx).Name) > 0) then
          Inc(i)
        else
        begin
          FowMerge.Server.Documents.Item(idx).Close(changes, emptyParam, emptyParam);
          Sleep(500); // Time for Word to close the doc
        end;
      end;
      UpdateAppStatusPerc( 90, True);

      FowMerge.Connected := False;

      if chkOpen.Checked then
        //Open the Word document
        ShellExecute(Application.MainForm.Handle, 'open', PChar(DocumentName), nil, nil, SW_SHOWNORMAL)
      else
        HelpfulInfoMsg(Format('The mail merge document has been created in:%s%s',
                              [#13, DocumentName]), 0);
    finally
      ClearStatus(True);
    end;
  except on E: Exception do
   begin
    FowMerge.Connected := False;
    HelpFulErrorMsg('There were problems creating the Mail Merge document using Word.' + #13#13 +
      'Please see log for more details.', 0);
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Create Mail Merge Document Failure: ' + E.Message);
   end;
  end;
end;

// Verify the form is all ok
function TfrmCreateMergeDoc.VerifyForm: Boolean;
var
  path, match: string;
begin
  Result := False;
  match := ExtractFilePath(edtSave.Text);
  if match = '' then
    match := GlobalDirectories.glDataDir + edtSave.Text
  else
    match := edtSave.Text;
  if rbExisting.Checked and (ExtractFilename(edtDocument.Text) = '') then
  begin
    HelpfulWarningMsg('You must specify the filename of the existing document.', 0);
    edtDocument.SetFocus;
  end
  else if rbExisting.Checked and (not BKFileExists(edtDocument.Text)) then
  begin
    HelpfulWarningMsg('The specified document does not exist.' + #13 +
      'Filename: ' + edtDocument.Text, 0);
    edtDocument.SetFocus;
  end
  else if ExtractFilename(edtSave.Text) = '' then
  begin
    HelpfulWarningMsg('You must specify the filename for the new mail merge document.', 0);
    edtSave.SetFocus;
  end
  else if rbExisting.Checked  and (Lowercase(edtDocument.Text) = Lowercase(match)) then
  begin
    HelpfulWarningMsg('The destination file must not be the same as the source file.', 0);
    edtSave.SetFocus;
  end
  else
    Result := True;

  if Result then // All ok up to now
  begin
    path := ExtractFilePath(edtSave.Text);
    if (path <> '') then
    begin
      if not DirectoryExists(path) then
      begin
        if AskYesNo('Create Directory',
                    'The folder ' + path + ' does not exist. Do you want to Create it?',
                     DLG_YES,0) <> DLG_YES then
           Result := False
        else
        begin
          try
             ForceDirectories(path);
          except
          end;
          if not DirectoryExists(path) then
          begin
            HelpfulErrorMsg('Cannot Create Directory ' + path, 0);
            Result := False;
          end;
        end;
      end;
    end;
  end;
  path := ExtractFileExt(edtSave.Text);
  if path = '' then
    edtSave.Text := edtSave.Text + '.doc'
  else if path = '.' then
    edtSave.Text := edtSave.Text + 'doc';
  if Result and BKFileExists( edtSave.Text) then
  begin
    if AskYesNo('Overwrite File', 'The file ' +  edtSave.Text +
                ' already exists. Overwrite?', DLG_YES, 0) <> DLG_YES then
      Result := False;
  end;
end;

// Do the create if all valid
procedure TfrmCreateMergeDoc.btnOkClick(Sender: TObject);
begin
  if VerifyForm then
  begin
    CreateDoc;
    ModalResult := mrOk;
  end;
end;

procedure TfrmCreateMergeDoc.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  btnFromFile.Glyph := ImagesFrm.AppImages.imgFindStates.Picture.Bitmap;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFile.Glyph);

  Label5.Caption := bkBranding.Rebrand(Label5.Caption);
end;

// Browse for saved doc
procedure TfrmCreateMergeDoc.btnToFileClick(Sender: TObject);
begin
  with SaveDialog1 do
  begin
    FileName := ExtractFileName(edtSave.Text);
    InitialDir := ExtractFilePath(edtSave.Text);
    if Execute then
      edtSave.Text := Filename;
  end;
  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir(GlobalDirectories.glDataDir);
end;

// Browse for existing doc
procedure TfrmCreateMergeDoc.btnFromFileClick(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    InitialDir := ExtractFilePath( edtDocument.Text);
    Filename := ExtractFilename( edtDocument.Text);

    if Execute then
      edtDocument.Text := Filename;
  end;
  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir(GlobalDirectories.glDataDir);
end;

// Create and setup the mail merge form
procedure PerformDocCreation(WordObj: TOpWord; var LoseFocus: Boolean);
var
  TempPath:String;
begin
 try
  if not BKFileExists(glDataDir + MAIL_MERGE_DATASOURCE_FILENAME) then
  begin
    HelpfulErrorMsg('The ' + bkBranding.ProductName + ' Mail Merge Data Source cannot be found.'#13#13 +
      'Filename:' + glDataDir + MAIL_MERGE_DATASOURCE_FILENAME, 0);
    Exit;
  end;
  // copy it locally otherwise it doesnt work on Office 2003
  SetLength(TempPath,Max_Path);
  SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));
  CopyFile(PChar(glDataDir + MAIL_MERGE_DATASOURCE_FILENAME), PChar(TempPath + MAIL_MERGE_DATASOURCE_FILENAME), False);
  if (not BKFileExists(TempPath + MAIL_MERGE_DATASOURCE_FILENAME)) then
  begin
    HelpfulErrorMsg('The ' + bkBranding.ProductName + ' Mail Merge Data Source cannot be copied onto your computer.'#13#13 +
      'Please make sure the following file exists: ' + glDataDir + MAIL_MERGE_DATASOURCE_FILENAME, 0);
    Exit;
  end;
  with TfrmCreateMergeDoc.Create(Application.MainForm) do
    try
      // Disconnect and hide now
      WordObj.Connected := False;
      WordObj.Visible := False;
      Word := WordObj;
      DataSource := TempPath + MAIL_MERGE_DATASOURCE_FILENAME;
      if ShowModal = mrOk then begin
        LoseFocus := chkOpen.Checked;
      end;
    finally
      Free;
    end;
 except on E: Exception do
    HelpfulErrorMsg('Microsoft Word did not respond as expected.'#13#13'Please check that Microsoft Word is set up correctly on your computer.'#13#13 +
      'Error: ' + E.Message, 0);
 end;
end;

procedure TfrmCreateMergeDoc.rbExistingClick(Sender: TObject);
begin
  edtDocument.Enabled := rbExisting.Checked;
  btnFromFile.Enabled := rbExisting.Checked;
end;

procedure TfrmCreateMergeDoc.FormShow(Sender: TObject);
begin
  BKHelpSetup(Self, BKH_Creating_documents_and_e_mails_using_Client_Manager);
end;

end.
