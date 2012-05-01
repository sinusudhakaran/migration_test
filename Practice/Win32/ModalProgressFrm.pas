unit ModalProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzPrgres, ExtCtrls, OSFont, Progress;

const
  UM_START_PROCESS = WM_USER + 1;

type
  TfrmModalProgress = class;
  
  TStartProcessEvent = procedure(Sender: ISingleProgressForm) of object;

  TfrmModalProgress = class(TForm, ISingleProgressForm)
    lblProgressTitle: TLabel;
    btnCancel: TButton;
    prgProgress: TRzProgressBar;
    lblProgress: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FCurrentStepTotal: Extended;
    
    FCancelled: Boolean;

    FOnStartProcess: TStartProcessEvent;

    procedure StartProcess;

    procedure UMStartProcess(var Message: TMessage); message UM_START_PROCESS;
  protected
    function GetCancelled: Boolean;
    
    procedure Initialize(const Title: String);
    procedure UpdateProgressLabel(const ProgressLabel: String); overload;
    procedure UpdateProgress(const ProgressLabel: String; StepSize: Double); overload;
    procedure UpdateProgress(StepSize: Double); overload;
    procedure ToggleCancelEnabled(Enabled: Boolean);
    procedure CompleteProgress;
  public
    class function ShowProgress(Owner: TCustomForm; Caption: String; OnStartProcessHandler: TStartProcessEvent): TModalResult; static;

    property OnStartProcess: TStartProcessEvent read FOnStartProcess write FOnStartProcess;
  end;
  
var
  frmModalProgress: TfrmModalProgress;

implementation

{$R *.dfm}

{ TfrmModalProgress }

procedure TfrmModalProgress.btnCancelClick(Sender: TObject);
begin
  FCancelled := True;
end;

procedure TfrmModalProgress.CompleteProgress;
begin
  if prgProgress.Percent < 100 then
  begin
    prgProgress.Percent := 100;

    Application.ProcessMessages;
  end;
end;

procedure TfrmModalProgress.FormCreate(Sender: TObject);
begin
  lblProgressTitle.Font.Name := Font.Name;
end;

procedure TfrmModalProgress.FormShow(Sender: TObject);
begin
  PostMessage(Handle, UM_START_PROCESS, 0, 0);
end;

function TfrmModalProgress.GetCancelled: Boolean;
begin
  Result := FCancelled;
end;

procedure TfrmModalProgress.UpdateProgress(StepSize: Double);
var
  Remainder: Double;
begin
  FCurrentStepTotal := FCurrentStepTotal + StepSize;

  if FCurrentStepTotal >= 1 then
  begin
    Remainder := Frac(FCurrentStepTotal);
    
    prgProgress.Percent := prgProgress.Percent + Round(FCurrentStepTotal - Remainder);

    FCurrentStepTotal := Remainder;
  end;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.UpdateProgressLabel(const ProgressLabel: String);
begin
  lblProgress.Caption := ProgressLabel;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.Initialize(const Title: String);
begin
  FCurrentStepTotal := 0;
  
  FCancelled := False;
  
  lblProgressTitle.Caption := Title;

  prgProgress.Percent := 0;

  Application.ProcessMessages;
end;

class function TfrmModalProgress.ShowProgress(Owner: TCustomForm; Caption: String; OnStartProcessHandler:  TStartProcessEvent): TModalResult;
var
  ProgressForm: TfrmModalProgress;
begin
  ProgressForm := TfrmModalProgress.Create(Owner);

  try
    ProgressForm.Caption := Caption;
    ProgressForm.OnStartProcess := OnStartProcessHandler;
    ProgressForm.PopupParent := Owner;
    ProgressForm.PopupMode := pmExplicit;

    Result := ProgressForm.ShowModal;
  finally
    ProgressForm.Free;
  end;
end;

procedure TfrmModalProgress.StartProcess;
begin
  if Assigned(FOnStartProcess) then
  begin
    FOnStartProcess(Self);
  end;
end;

procedure TfrmModalProgress.ToggleCancelEnabled(Enabled: Boolean);
begin
  btnCancel.Enabled := Enabled;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.UMStartProcess(var Message: TMessage);
begin
  StartProcess;

  if FCancelled then
  begin
    ModalResult := mrCancel;
  end
  else
  begin
    ModalResult := mrOk;
  end;
end;

procedure TfrmModalProgress.UpdateProgress(const ProgressLabel: String; StepSize: Double);
var
  Remainder: Double;
begin
  lblProgress.Caption := ProgressLabel;

  FCurrentStepTotal := FCurrentStepTotal + StepSize;

  if FCurrentStepTotal >= 1 then
  begin
    Remainder := Frac(FCurrentStepTotal);
    
    prgProgress.Percent := prgProgress.Percent + Round(FCurrentStepTotal - Remainder);

    FCurrentStepTotal := Remainder;
  end;

  Application.ProcessMessages;
end;

end.
