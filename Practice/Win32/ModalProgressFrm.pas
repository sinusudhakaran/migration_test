unit ModalProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzPrgres, ExtCtrls, OSFont;

const
  UM_START_PROCESS = WM_USER + 1;

type
  TfrmModalProgress = class;
  
  TStartProcessEvent = procedure(Sender: TfrmModalProgress) of object;

  TfrmModalProgress = class(TForm)
    lblProgressTitle: TLabel;
    btnCancel: TButton;
    prgProgress: TRzProgressBar;
    lblProgress: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FCancelled: Boolean;

    FOnStartProcess: TStartProcessEvent;

    procedure StartProcess;

    procedure UMStartProcess(var Message: TMessage); message UM_START_PROCESS;
  public
    class function ShowProgress(Owner: TCustomForm; Caption: String; OnStartProcessHandler: TStartProcessEvent): TModalResult; static;

    procedure Initialize(const Title: String);
    procedure UpdateProgress(const ProgressLabel: String; StepSize: Double); overload;
    procedure UpdateProgress(StepSize: Double); overload;
    procedure ToggleCancelEnabled(Enabled: Boolean);

    property Cancelled: Boolean read FCancelled; 

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

procedure TfrmModalProgress.FormCreate(Sender: TObject);
begin
  lblProgressTitle.Font.Name := Font.Name;
end;

procedure TfrmModalProgress.FormShow(Sender: TObject);
begin
  PostMessage(Handle, UM_START_PROCESS, 0, 0);
end;

procedure TfrmModalProgress.UpdateProgress(StepSize: Double);
begin
  prgProgress.Percent := prgProgress.Percent + StepSize;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.Initialize(const Title: String);
begin
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

    ProgressForm.ShowModal;
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
end;

procedure TfrmModalProgress.UpdateProgress(const ProgressLabel: String; StepSize: Double);
begin
  lblProgress.Caption := ProgressLabel;
  
  prgProgress.Percent := prgProgress.Percent + StepSize;

  Application.ProcessMessages;
end;

end.
