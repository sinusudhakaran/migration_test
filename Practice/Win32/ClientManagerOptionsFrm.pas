unit ClientManagerOptionsFrm;
//------------------------------------------------------------------------------
{
   Title:       Options form for client manager

   Description:

   Author:      Matthew Hopkins Apr 03

   Remarks:     Loads and Saves admin system

}
//------------------------------------------------------------------------------

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
  ExtCtrls,
  ComCtrls,
  Mask,
  RzEdit,
  RzSpnEdt,
  OsFont;

type
  TfrmClientManagerOptions = class(TForm)
    pnlFooter: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pnlAutoTasks: TPanel;
    chkShowOverdue: TCheckBox;
    lblCoding1: TLabel;
    lblCoding2: TLabel;
    chkCoding: TCheckBox;
    rzsCoding: TRzSpinEdit;
    lblWillAdd: TLabel;
    chkBNotes: TCheckBox;
    lblBNotes1: TLabel;
    rzsBNotes: TRzSpinEdit;
    lblBNotes2: TLabel;
    chkBNotesClose: TCheckBox;
    chkWeb: TCheckBox;
    lblWeb1: TLabel;
    rzsWeb: TRzSpinEdit;
    lblWeb2: TLabel;
    chkWebClose: TCheckBox;
    chkSend: TCheckBox;
    lblCheckOut1: TLabel;
    rzsCheckOut: TRzSpinEdit;
    lblCheckOut2: TLabel;
    chkSendClose: TCheckBox;
    chkGet: TCheckBox;
    lblCheckIn1: TLabel;
    rzsCheckIn: TRzSpinEdit;
    lblCheckIn2: TLabel;
    chkQueryEmail: TCheckBox;
    lblQueryEmail1: TLabel;
    rzsQueryEmail: TRzSpinEdit;
    lblQueryEmail2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkTaskClick(Sender: TObject);
    procedure spinEditChange(Sender: TObject);
  private
    function GetTaskTypeFromCheckbox(CheckBox: TCheckBox): Integer;
    function GetTaskTypeFromSpinEdit(SpinEdit: TRzSpinEdit): Integer;
    function GetTypeCheckbox(TaskType: Integer): TCheckBox;
    procedure GetReminderLabels(TaskType: Integer; var Reminder1, Reminder2: TLabel);
    function GetTypeReminderSpinEdit(TaskType: Integer): TRzSpinEdit;
    function GetTypeCloseCheckBox(TaskType: Integer): TCheckBox;
  public
    procedure LoadSettings;
    procedure SaveSettings;
  end;

procedure UpdateClientManagerOptions;

//------------------------------------------------------------------------------
implementation

uses
  admin32,
  bkconst,
  globals,
  SysObj32,
  SYDEFS,
  usrlist32,
  bkXPThemes,
  glConst, bkBranding, bkProduct;

{$R *.dfm}

//------------------------------------------------------------------------------
procedure UpdateClientManagerOptions;
var
  Dlg: TfrmClientManagerOptions;
begin
  RefreshAdmin;

  Dlg := TfrmClientManagerOptions.Create(Application.MainForm);
  try
    Dlg.LoadSettings;
    if Dlg.ShowModal = mrOK then
      Dlg.SaveSettings;
  finally
    Dlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.chkTaskClick(Sender: TObject);
var
  SenderChkBox: TCheckBox;
  TaskType: Integer;
  Reminder1, Reminder2: TLabel;
  SpinEdit: TRzSpinEdit;
  CloseChkBox: TCheckBox;
begin
  SenderChkBox := Sender as TCheckBox;
  if not Assigned(SenderChkBox) then
    Exit;

  TaskType := GetTaskTypeFromCheckbox(SenderChkBox);
  if TaskType = ttyManual then
    Exit;

  GetReminderLabels(TaskType, Reminder1, Reminder2);
  if Assigned(Reminder1) then
    Reminder1.Enabled := SenderChkBox.Checked;
  if Assigned(Reminder2) then
    Reminder2.Enabled := SenderChkBox.Checked;

  SpinEdit := GetTypeReminderSpinEdit(TaskType);
  if Assigned(SpinEdit) then
    SpinEdit.Enabled := SenderChkBox.Checked;

  CloseChkBox := GetTypeCloseCheckBox(TaskType);
  if Assigned(CloseChkBox) then
    CloseChkBox.Enabled := SenderChkBox.Checked;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.spinEditChange(Sender: TObject);
var
  SpinEdit: TRzSpinEdit;
  TaskType: Integer;
  Reminder1: TLabel;
  Reminder2: TLabel;
  TestValue: Integer;
begin
  SpinEdit := Sender as TRzSpinEdit;
  if not Assigned(SpinEdit) then
    Exit;

  if not TryStrToInt(SpinEdit.EditText, TestValue) then
    Exit; //An invalid value has been entered (e.g. - or + pressed)

  if SpinEdit.IntValue > SpinEdit.Max then
    SpinEdit.IntValue := Round(SpinEdit.Max);

  if SpinEdit.IntValue < SpinEdit.Min then
    SpinEdit.IntValue := Round(SpinEdit.Min);

  TaskType := GetTaskTypeFromSpinEdit(SpinEdit);
  if TaskType = ttyManual then
    Exit;

  GetReminderLabels(TaskType, Reminder1, Reminder2);
  if Assigned(Reminder2) then
  begin
    case SpinEdit.IntValue of
      0: Reminder2.Caption := 'days (OFF)';
      1: Reminder2.Caption := 'day after the task is added';
      else Reminder2.Caption := 'days after the task is added';
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  lblWillAdd.Caption := Globals.ShortAppName + ' will add a task to the client when you:';

  chkBNotes.Caption := TProduct.Rebrand(chkBNotes.Caption);
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.GetReminderLabels(TaskType: Integer;
  var Reminder1, Reminder2: TLabel);
begin
  case TaskType of
    ttyCodingReport:
      begin
        Reminder1 := lblCoding1;
        Reminder2 := lblCoding2;
      end;
    ttyExportBNotes:
      begin
        Reminder1 := lblBNotes1;
        Reminder2 := lblBNotes2;
      end;
    ttyExportWeb:
      begin
        Reminder1 := lblWeb1;
        Reminder2 := lblWeb2;
      end;
    ttyCheckOut:
      begin
        Reminder1 := lblCheckOut1;
        Reminder2 := lblCheckOut2;
      end;
    ttyCheckIn:
      begin
        Reminder1 := lblCheckIn1;
        Reminder2 := lblCheckIn2;
      end;
     ttyQueryEmail:
      begin
        Reminder1 := lblQueryEmail1;
        Reminder2 := lblQueryEmail2;
      end
    else
    begin
      Reminder1 := nil;
      Reminder2 := nil;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmClientManagerOptions.GetTaskTypeFromCheckbox(
  CheckBox: TCheckBox): Integer;
begin
  //Could have used the Tag on the controls for this, but I thought
  //this would be simplier to see what's going on.
  if CheckBox = chkCoding then
    Result := ttyCodingReport
  else if CheckBox = chkBNotes then
    Result := ttyExportBNotes
  else if CheckBox = chkWeb then
    Result := ttyExportWeb
  else if CheckBox = chkSend then
    Result := ttyCheckOut
  else if CheckBox = chkGet then
    Result := ttyCheckIn
  else if CheckBox = chkQueryEmail then
    Result := ttyQueryEmail
  else
    Result := ttyManual;
end;

//------------------------------------------------------------------------------
function TfrmClientManagerOptions.GetTaskTypeFromSpinEdit(
  SpinEdit: TRzSpinEdit): Integer;
begin
  //Could have used the Tag on the controls for this, but I thought
  //this would be simplier to see what's going on.
  if SpinEdit = rzsCoding then
    Result := ttyCodingReport
  else if SpinEdit = rzsBNotes then
    Result := ttyExportBNotes
  else if SpinEdit = rzsWeb then
    Result := ttyExportWeb
  else if SpinEdit = rzsCheckOut then
    Result := ttyCheckOut
  else if SpinEdit = rzsCheckIn then
    Result := ttyCheckIn
  else if SpinEdit = rzsQueryEmail then
    Result := ttyQueryEmail
  else
    Result := ttyManual;
end;

//------------------------------------------------------------------------------
function TfrmClientManagerOptions.GetTypeCheckbox(TaskType: Integer): TCheckBox;
begin
  case TaskType of
    ttyCodingReport:     Result := chkCoding;
    ttyExportBNotes:     Result := chkBNotes;
    ttyExportWeb:        Result := chkWeb;
    ttyCheckOut:         Result := chkSend;
    ttyCheckIn:          Result := chkGet;
    ttyQueryEmail:       Result := chkQueryEmail;
    else Result := nil;
  end;
end;

//------------------------------------------------------------------------------
function TfrmClientManagerOptions.GetTypeCloseCheckBox(
  TaskType: Integer): TCheckBox;
begin
  case TaskType of
    ttyExportBNotes: Result := chkBNotesClose;
    ttyExportWeb:    Result := chkWebClose;
    ttyCheckOut:     Result := chkSendClose;
    else Result := nil;
  end;
end;

//------------------------------------------------------------------------------
function TfrmClientManagerOptions.GetTypeReminderSpinEdit(
  TaskType: Integer): TRzSpinEdit;
begin
  case TaskType of
    ttyCodingReport:     Result := rzsCoding;
    ttyExportBNotes:     Result := rzsBNotes;
    ttyExportWeb:        Result := rzsWeb;
    ttyCheckOut:         Result := rzsCheckOut;
    ttyCheckIn:          Result := rzsCheckIn;
    ttyQueryEmail:       Result := rzsQueryEmail;
    else Result := nil;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.LoadSettings;
var
  TaskType: Integer;
  ChkBox: TCheckBox;
  CloseChkBox: TCheckBox;
  SpinEdit: TRzSpinEdit;
begin
  for TaskType := ttyAutoMin to ttyAutoMax do
  begin
    ChkBox := GetTypeCheckbox(TaskType);
    if not Assigned(ChkBox) then
      Continue; //Automatic task that isn't controlled by this form (no examples at present)

    ChkBox.Checked := AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[TaskType];
    chkTaskClick(ChkBox);

    SpinEdit := GetTypeReminderSpinEdit(TaskType);
    if Assigned(SpinEdit) then //all task might not have reminders (no examples at present)
    begin
      SpinEdit.IntValue := AdminSystem.fdFields.fdAutomatic_Task_Reminder_Delay[TaskType];
      spinEditChange(SpinEdit);
    end;

    CloseChkBox := GetTypeCloseCheckBox(TaskType);
    if Assigned(CloseChkBox) then //most tasks don't have this
      CloseChkBox.Checked := AdminSystem.fdFields.fdAutomatic_Task_Closing_Flags[TaskType];
  end;

  chkShowOverdue.Checked := AdminSystem.fdFields.fdTask_Tracking_Prompt_Type = ttOnlyIfOutstanding;
end;

//------------------------------------------------------------------------------
procedure TfrmClientManagerOptions.SaveSettings;
var
  TaskType: Integer;
  ChkBox: TCheckBox;
  SpinEdit: TRzSpinEdit;
  CloseChkBox: TCheckBox;
begin
  if LoadAdminSystem( true, 'UpdateClientManagerOptions') then
  begin
    for TaskType := ttyAutoMin to ttyAutoMax do
    begin
      ChkBox := GetTypeCheckbox(TaskType);
      if not Assigned(ChkBox) then
        Continue;
      AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[TaskType] := ChkBox.Checked;
      SpinEdit := GetTypeReminderSpinEdit(TaskType);
      if Assigned(SpinEdit) then
        AdminSystem.fdFields.fdAutomatic_Task_Reminder_Delay[TaskType] := SpinEdit.IntValue;

      CloseChkBox := GetTypeCloseCheckBox(TaskType);
      if Assigned(CloseChkBox) then //most tasks don't have this
        AdminSystem.fdFields.fdAutomatic_Task_Closing_Flags[TaskType] := CloseChkBox.Checked;
    end;

    if chkShowOverdue.Checked then
      AdminSystem.fdFields.fdTask_Tracking_Prompt_Type := ttOnlyIfOutstanding
    else
      AdminSystem.fdFields.fdTask_Tracking_Prompt_Type := ttNeverPrompt;

    SaveAdminSystem;
  end;
end;

//------------------------------------------------------------------------------
end.
