unit ModalProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzPrgres, ExtCtrls, OSFont, Progress, bkBranding;

const
  UM_START_PROCESS = WM_USER + 1;

type
  TfrmModalProgress = class;
  
  TStartProcessEvent = procedure(Sender: ISingleProgressForm) of object;
  TStartProcessExEvent = procedure(Sender: ISingleProgressForm; CallbackParams: Pointer) of object;

  TfrmModalProgress = class(TForm, ISingleProgressForm)
    lblProgressTitle: TLabel;
    prgProgress: TRzProgressBar;
    lblProgress: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FCurrentStepTotal: Extended;

    FCancelled: Boolean;

    FProgressData: TProgressData;

    FOnStartProcess: TStartProcessEvent;
    FOnStartProcessEx: TStartProcessExEvent;
    FRaiseException: Boolean;

    procedure StartProcess;

    procedure UMStartProcess(var Message: TMessage); message UM_START_PROCESS;
    function GetTitle: String;
    procedure SetTitle(const Value: String);
    procedure SetProgressData(const Value: TProgressData);
    procedure SetRaiseException(const Value: Boolean);
  protected
    function GetCancelled: Boolean;
    
    procedure Initialize;
    procedure UpdateProgressLabel(const ProgressLabel: String); overload;
    procedure UpdateProgress(const ProgressLabel: String; StepSize: Double); overload;
    procedure UpdateProgress(StepSize: Double); overload;
    procedure CompleteProgress;
  public
    constructor Create(Owner: TComponent); override;
    
    class function ShowProgress(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandler: TStartProcessEvent): TModalResult; static;
    class function ShowProgressEx(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandlerEx: TStartProcessExEvent; var ProgressData: TProgressData): TModalResult; static;

    property Title: String read GetTitle write SetTitle;

    property ProgressData: TProgressData read FProgressData write SetProgressData;
    property RaiseException: Boolean read FRaiseException write SetRaiseException;

    property OnStartProcess: TStartProcessEvent read FOnStartProcess write FOnStartProcess;
    property OnStartProcessEx: TStartProcessExEvent read FOnStartProcessEx write FOnStartProcessEx;
  end;
  
var
  frmModalProgress: TfrmModalProgress;

implementation

{$R *.dfm}

{ TfrmModalProgress }

procedure TfrmModalProgress.CompleteProgress;
begin
  if prgProgress.Percent < 100 then
  begin
    prgProgress.Percent := 100;

    Application.ProcessMessages;
  end;
end;

constructor TfrmModalProgress.Create(Owner: TComponent);
begin
  inherited;

  FRaiseException := True;

  lblProgress.Visible := False;
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

function TfrmModalProgress.GetTitle: String;
begin
  Result := lblProgressTitle.Caption;
end;

procedure TfrmModalProgress.UpdateProgress(StepSize: Double);
var
  Remainder: Double;
begin
  FCurrentStepTotal := FCurrentStepTotal + StepSize;

  if not lblProgress.Visible then
  begin
    lblProgress.Visible := True;
  end;

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
  lblProgress.Caption := bkBranding.Rebrand(ProgressLabel);

  if not lblProgress.Visible then
  begin
    lblProgress.Visible := True;
  end;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.Initialize;
begin
  lblProgress.Visible := False;

  FCurrentStepTotal := 0;
  
  FCancelled := False;

  prgProgress.Percent := 0;

  Application.ProcessMessages;
end;

procedure TfrmModalProgress.SetProgressData(const Value: TProgressData);
begin
  FProgressData := Value;
end;

procedure TfrmModalProgress.SetRaiseException(const Value: Boolean);
begin
  FRaiseException := Value;
end;

procedure TfrmModalProgress.SetTitle(const Value: String);
begin
  lblProgressTitle.Caption := Value;
end;

class function TfrmModalProgress.ShowProgress(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandler:  TStartProcessEvent): TModalResult;
var
  ProgressForm: TfrmModalProgress;
begin
  ProgressForm := TfrmModalProgress.Create(Owner);

  try
    ProgressForm.Caption := bkBranding.Rebrand(Caption);
    ProgressForm.Title := bkBranding.Rebrand(Title);
    ProgressForm.OnStartProcess := OnStartProcessHandler;
    ProgressForm.PopupParent := Owner;
    ProgressForm.PopupMode := pmExplicit;

    Result := ProgressForm.ShowModal;
  finally
    ProgressForm.Free;
  end;
end;

class function TfrmModalProgress.ShowProgressEx(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandlerEx: TStartProcessExEvent; var ProgressData: TProgressData): TModalResult;
var
  ProgressForm: TfrmModalProgress;
begin
  ProgressForm := TfrmModalProgress.Create(Owner);

  try
    ProgressForm.Caption := bkBranding.Rebrand(Caption);
    ProgressForm.Title := bkBranding.Rebrand(Title);
    ProgressForm.ProgressData := ProgressData;
    ProgressForm.RaiseException := False;
    ProgressForm.OnStartProcessEx := OnStartProcessHandlerEx;
    ProgressForm.PopupParent := Owner;
    ProgressForm.PopupMode := pmExplicit;

    Result := ProgressForm.ShowModal;

    ProgressData := ProgressForm.ProgressData;
  finally
    ProgressForm.Free;
  end;
end;

procedure TfrmModalProgress.StartProcess;
begin
  if Assigned(FOnStartProcess) then
  begin
    FOnStartProcess(Self);
  end
  else
  if Assigned(FOnStartProcessEx) then
  begin
    FOnStartProcessEx(Self, ProgressData.CallbackParams); 
  end;
end;

procedure TfrmModalProgress.UMStartProcess(var Message: TMessage);
begin
  FProgressData.ExceptionRaised := False;

  try
    StartProcess;

    if FCancelled then
    begin
      ModalResult := mrCancel;
    end
    else
    begin
      ModalResult := mrOk;
    end;
  except
    on E: Exception do
    begin
      ModalResult := mrCancel;

      if not FRaiseException then
      begin
        FProgressData.Exception.ClassType := E.ClassType;
        FProgressData.Exception.Message := E.Message;

        FProgressData.ExceptionRaised := True;
      end
      else
      begin
        raise;
      end;
    end;
  end;
end;

procedure TfrmModalProgress.UpdateProgress(const ProgressLabel: String; StepSize: Double);
var
  Remainder: Double;
begin
  lblProgress.Caption := bkBranding.Rebrand(ProgressLabel);

  if not lblProgress.Visible then
  begin
    lblProgress.Visible := True;
  end;

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
