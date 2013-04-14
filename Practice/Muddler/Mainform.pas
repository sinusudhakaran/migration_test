//------------------------------------------------------------------------------
{
   Title:       Mainform

   Description: Main front end to the Muddle Application

   Remarks:

   Author:      Ralph Austen

}
//------------------------------------------------------------------------------
unit Mainform;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  ComCtrls,
  ActnList,
  Menus,
  Muddle;

type
  TformMain = class(TForm)
    lblSourceDirectory: TLabel;
    edtSourceDirectory: TEdit;
    btnSourceDirectory: TSpeedButton;
    btnDestinationDirectory: TSpeedButton;
    edtDestinationDirectory: TEdit;
    lblDestinationDirectory: TLabel;
    btnGo: TButton;
    btnExit: TButton;
    ProgressBar: TProgressBar;
    MainMenu: TMainMenu;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    mnuFile: TMenuItem;
    ActionList: TActionList;
    actLoadDataFile: TAction;
    actLoadFirstNames: TAction;
    actLoadSurnames: TAction;
    actLoadCompanyTypeNames: TAction;
    actSaveDataFile: TAction;
    actSaveFirstNames: TAction;
    actSaveSurnames: TAction;
    actSaveCompanyTypeNames: TAction;
    mnuLoadDataFile: TMenuItem;
    mnuLoadFirstNames: TMenuItem;
    mnuLoadSurnames: TMenuItem;
    mnuLoadCompanyTypeNames: TMenuItem;
    N1: TMenuItem;
    mnuSaveDataFile: TMenuItem;
    mnuSaveFirstNames: TMenuItem;
    mnuSaveSurnames: TMenuItem;
    mnuSaveCompanyTypeNames: TMenuItem;
    N2: TMenuItem;
    actExecute: TAction;
    actExit: TAction;
    mnuExit: TMenuItem;
    actLoadBK5Exe: TAction;
    actSaveBk5Exe: TAction;
    mnuLoadBK5Exe: TMenuItem;
    mnuSaveBk5Exe: TMenuItem;
    grpOptions: TGroupBox;
    chkOnlyMuddleEmails: TCheckBox;
    chkSetAllEmailsToOne: TCheckBox;
    edtGlobalEmail: TEdit;
    lblStatus: TLabel;
    procedure btnSourceDirectoryClick(Sender: TObject);
    procedure btnDestinationDirectoryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actLoadDataFileExecute(Sender: TObject);
    procedure actLoadFirstNamesExecute(Sender: TObject);
    procedure actLoadSurnamesExecute(Sender: TObject);
    procedure actLoadCompanyTypeNamesExecute(Sender: TObject);
    procedure actSaveDataFileExecute(Sender: TObject);
    procedure actSaveFirstNamesExecute(Sender: TObject);
    procedure actSaveSurnamesExecute(Sender: TObject);
    procedure actSaveCompanyTypeNamesExecute(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actLoadBK5ExeExecute(Sender: TObject);
    procedure actSaveBk5ExeExecute(Sender: TObject);
    procedure chkSetAllEmailsToOneClick(Sender: TObject);
  private
    fLastMessage : string;
    fMuddler : TMuddler;
    fMuddleDatFileName : string;

    procedure DoProgress(ProgressPercent : single; MessageStr : String);
    procedure ResetControls;
    function Validate : boolean;
    procedure EnableControls(Enable : boolean);
  end;

var
  formMain: TformMain;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
{$R *.dfm}

uses
  ShellUtils,
  LogUtil,
  StackTracing;

Const
  MSG_SELECT_FOLDER         = 'Select a %S directory';
  MSG_SOURCE_DIR_NOT_EXISTS = 'Error : The source directory does not exist!';
  MSG_DEST_DIR_EXISTS       = 'The destination directory already exists. Clear all and overwrite it?';
  MSG_FINISHED              = 'Finished the muddle!';
  MSG_ERROR_OCCURED         = 'Error : Muddle Process : %s';
  MSG_SHOULD_WRITE_MUDDLER  = 'The muddler application uses a default data file. Should both files be written to?';
  MSG_DAT_FILE_NOT_FOUND    = 'The %s (Muddler Data File) was not found! some default name data will be used instead.';

  ADDON_MUDDLED        = '(Muddled)';
  FILE_EXT_DATA_FILTER = 'Muddler Data File|*.dat';
  FILE_EXT_TEXT_FILTER = 'Text File|*.txt';
  FILE_EXT_EXE_FILTER  = 'Bk5 Exe File|*.exe';

  UNITNAME = 'MainForm';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.btnSourceDirectoryClick(Sender: TObject);
var
  SelectedDir : string;
begin
  SelectedDir := edtSourceDirectory.Text;

  if BrowseFolder(SelectedDir, format(MSG_SELECT_FOLDER, ['Source']) ) then
  begin
    edtSourceDirectory.Text := SelectedDir;

    if Length(edtDestinationDirectory.Text) = 0 then
    begin
      edtDestinationDirectory.Text := edtSourceDirectory.Text + ADDON_MUDDLED;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.chkSetAllEmailsToOneClick(Sender: TObject);
begin
  edtGlobalEmail.enabled := chkSetAllEmailsToOne.Checked;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.btnDestinationDirectoryClick(Sender: TObject);
var
  SelectedDir : string;
begin
  SelectedDir := edtDestinationDirectory.Text;

  if BrowseFolder(SelectedDir, format(MSG_SELECT_FOLDER, ['Destination']) ) then
  begin
    edtDestinationDirectory.Text := SelectedDir;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.FormCreate(Sender: TObject);
begin
  fMuddler := TMuddler.Create;
  // Link Call Back Procedure
  fMuddler.AppFolder := ExtractFilePath(ParamStr(0));
  fMuddler.OnProgressUpdate := DoProgress;
  fMuddleDatFileName := fMuddler.AppFolder + FILENAME_MUDDLE_DAT;

  if FileExists(fMuddleDatFileName) then
    fMuddler.DataGenerator.Load(fMuddleDatFileName)
  else
  begin
    Messagedlg(format(MSG_DAT_FILE_NOT_FOUND,[fMuddleDatFileName]), mtInformation, [mbOk], 0);
    fMuddler.MakeBasicData;
  end;

  fMuddler.DataGenerator.ShuffleLists;

  ResetControls;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMuddler);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.DoProgress(ProgressPercent : single; MessageStr : String);
var
  Progress : integer;
begin
  Progress := round((ProgressPercent/100) * ProgressBar.Max);
  ProgressBar.Position := Progress;
  lblStatus.Caption := MessageStr;

  if fLastMessage <> MessageStr then
  begin
    LogUtil.LogMsg(lmInfo, 'MainForm', MessageStr);
    fLastMessage := MessageStr;
  end;

  Application.ProcessMessages;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.ResetControls;
begin
  ProgressBar.Min := 0;
  ProgressBar.Max := 10000;
  ProgressBar.Position := 0;
  EnableControls(True);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TformMain.Validate : boolean;
begin
  Result := False;

  if not SysUtils.DirectoryExists(edtSourceDirectory.Text) then
  begin
    Messagedlg(MSG_SOURCE_DIR_NOT_EXISTS, mtError, [mbOk], 0);
    edtSourceDirectory.SetFocus;
    Exit;
  end;

  if SysUtils.DirectoryExists(edtDestinationDirectory.Text) then
  begin
    if Messagedlg(MSG_DEST_DIR_EXISTS, mtConfirmation, [mbYes,mbNo], 0) = mrNo then
    begin
      edtDestinationDirectory.setfocus;
      Exit;
    end;
  end;

  Result := True;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.EnableControls(Enable: boolean);
begin
  edtSourceDirectory.Enabled := Enable;
  btnSourceDirectory.Enabled := Enable;
  btnDestinationDirectory.Enabled := Enable;
  edtDestinationDirectory.Enabled := Enable;
  btnGo.Enabled := Enable;
  btnExit.Enabled := Enable;
  mnuFile.Enabled := Enable;
  chkOnlyMuddleEmails.Enabled := Enable;
  chkSetAllEmailsToOne.Enabled := Enable;
  edtGlobalEmail.Enabled := Enable;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actLoadDataFileExecute(Sender: TObject);
begin
  OpenDialog.Filter := FILE_EXT_DATA_FILTER;
  if OpenDialog.Execute then
  begin
    fMuddler.DataGenerator.Load(OpenDialog.FileName);
    fMuddler.DataGenerator.ShuffleLists;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actLoadFirstNamesExecute(Sender: TObject);
begin
  OpenDialog.Filter := FILE_EXT_TEXT_FILTER;
  if OpenDialog.Execute then
  begin
    fMuddler.DataGenerator.NameList.LoadFromFile(OpenDialog.FileName);
    fMuddler.DataGenerator.ShuffleLists;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actLoadSurnamesExecute(Sender: TObject);
begin
  OpenDialog.Filter := FILE_EXT_TEXT_FILTER;
  if OpenDialog.Execute then
  begin
    fMuddler.DataGenerator.SurnameList.LoadFromFile(OpenDialog.FileName);
    fMuddler.DataGenerator.ShuffleLists;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actLoadCompanyTypeNamesExecute(Sender: TObject);
begin
  OpenDialog.Filter := FILE_EXT_TEXT_FILTER;
  if OpenDialog.Execute then
  begin
    fMuddler.DataGenerator.CompanyTypeList.LoadFromFile(OpenDialog.FileName);
    fMuddler.DataGenerator.ShuffleLists;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actLoadBK5ExeExecute(Sender: TObject);
begin
  OpenDialog.Filter := FILE_EXT_EXE_FILTER;
  if OpenDialog.Execute then
    fMuddler.DataGenerator.Bk5Exe.LoadFromFile(OpenDialog.FileName);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actSaveDataFileExecute(Sender: TObject);
begin
  SaveDialog.Filter := FILE_EXT_DATA_FILTER;
  if SaveDialog.Execute then
  begin
    if Uppercase(fMuddleDatFileName) <> Uppercase(SaveDialog.FileName) then
    begin
      if Messagedlg(MSG_SHOULD_WRITE_MUDDLER, mtConfirmation, [mbYes,mbNo], 0) = mrYes then
        fMuddler.DataGenerator.Save(fMuddleDatFileName);
    end;

    fMuddler.DataGenerator.Save(SaveDialog.FileName);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actSaveFirstNamesExecute(Sender: TObject);
begin
  SaveDialog.Filter := FILE_EXT_TEXT_FILTER;
  if SaveDialog.Execute then
  begin
    fMuddler.DataGenerator.NameList.SaveToFile(SaveDialog.FileName);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actSaveSurnamesExecute(Sender: TObject);
begin
  SaveDialog.Filter := FILE_EXT_TEXT_FILTER;
  if SaveDialog.Execute then
  begin
    fMuddler.DataGenerator.SurnameList.SaveToFile(SaveDialog.FileName);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actSaveCompanyTypeNamesExecute(Sender: TObject);
begin
  SaveDialog.Filter := FILE_EXT_TEXT_FILTER;
  if SaveDialog.Execute then
  begin
    fMuddler.DataGenerator.CompanyTypeList.SaveToFile(SaveDialog.FileName);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actSaveBk5ExeExecute(Sender: TObject);
begin
  SaveDialog.Filter := FILE_EXT_EXE_FILTER;
  if SaveDialog.Execute then
  begin
    fMuddler.DataGenerator.Bk5Exe.SaveToFile(SaveDialog.FileName);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actExecuteExecute(Sender: TObject);
var
  Msg : string;
begin
  if not Validate then
    Exit;

  fLastMessage := '';
  LogUtil.LogMsg(lmInfo, UNITNAME, '-------------------------------------------------');
  LogUtil.LogMsg(lmInfo, UNITNAME, 'Source Folder : ' + edtSourceDirectory.Text);
  LogUtil.LogMsg(lmInfo, UNITNAME, 'Destination Folder : ' + edtDestinationDirectory.Text);
  if chkOnlyMuddleEmails.Checked then
    LogUtil.LogMsg(lmInfo, UNITNAME, 'Only Muddle Emails : On')
  else
    LogUtil.LogMsg(lmInfo, UNITNAME, 'Only Muddle Emails : Off');
  if chkSetAllEmailsToOne.Checked then
    LogUtil.LogMsg(lmInfo, UNITNAME, 'Set All Emails To One : On, Email : ' + edtGlobalEmail.text)
  else
    LogUtil.LogMsg(lmInfo, UNITNAME, 'Set All Emails To One : Off');
  LogUtil.LogMsg(lmInfo, UNITNAME, '-------------------------------------------------');

  ResetControls;
  Self.Cursor := crHourGlass;
  try
    try
      EnableControls(False);
      fMuddler.OnlyMuddleEmails := chkOnlyMuddleEmails.Checked;
      fMuddler.SetAllEmailToOne := chkSetAllEmailsToOne.Checked;
      fMuddler.GlobalEmail := edtGlobalEmail.text;

      fMuddler.Execute(edtSourceDirectory.Text, edtDestinationDirectory.Text);

      Messagedlg(MSG_FINISHED, mtInformation, [mbOk], 0);
    except
      On E : Exception do
      begin
        Msg := format(MSG_ERROR_OCCURED,[E.Message]);
        LogUtil.LogError(UNITNAME, Msg);
        GetAndLogStackTrace(UNITNAME, 'actExecuteExecute');
        Messagedlg(Msg, mtError, [mbOk], 0);
      end;
    end;
  finally
    Self.Cursor := crDefault;
    ResetControls;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TformMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

end.
