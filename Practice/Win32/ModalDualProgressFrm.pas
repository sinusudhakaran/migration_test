unit ModalDualProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzPrgres, ExtCtrls, OSFont, Progress, bkProduct;

const
  UM_START_PROCESS = WM_USER + 1;

type
  TStartProcessEvent = procedure(Sender: IDualProgressForm; CallbackParams: Pointer) of object;
  
  TProgressIndicator = class(TInterfacedObject, IProgressControl)
  private
    FProgressBar: TRzProgressBar;
    FProgressLabel: TLabel;
    FCurrentStepTotal: Extended;
  protected
    procedure Initialize;

    procedure CompleteProgress;

    procedure UpdateProgressLabel(const ProgressLabel: String); overload;
    procedure UpdateProgress(const ProgressLabel: String; StepSize: Double); overload;
    procedure UpdateProgress(StepSize: Double); overload;
    procedure SetProgressPosition(Position: Double);
  public
    constructor Create(ProgressBar: TRzProgressBar; ProgressLabel: TLabel = nil);
  end;

  TfrmModalDualProgress = class(TForm, IDualProgressForm)
    lblProgressTitle: TLabel;
    prgFirstProgress: TRzProgressBar;
    lblFirstProgress: TLabel;
    prgSecondProgress: TRzProgressBar;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPrimaryProgress: IProgressControl;
    FSecondaryProgress: IProgressControl;
    
    FCancelled: Boolean;

    FOnStartProcess: TStartProcessEvent;
    FProgressData: TProgressData;
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

    function GetPrimaryProgress: IProgressControl;
    function GetSecondaryProgress: IProgressControl;
  public
    constructor Create(Owner: TComponent); override;

    class function ShowProgress(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandler: TStartProcessEvent; var ProgressData: TProgressData): TModalResult; static;

    property Title: String read GetTitle write SetTitle;

    property ProgressData: TProgressData read FProgressData write SetProgressData;
    property RaiseException: Boolean read FRaiseException write SetRaiseException;

    property OnStartProcess: TStartProcessEvent read FOnStartProcess write FOnStartProcess;
  end;
  
var
  frmModalDualProgress: TfrmModalDualProgress;

implementation

{$R *.dfm}

{ TfrmModalProgress }

constructor TfrmModalDualProgress.Create(Owner: TComponent);
begin
  inherited;

  FPrimaryProgress := TProgressIndicator.Create(prgFirstProgress, lblFirstProgress);
  FSecondaryProgress := TProgressIndicator.Create(prgSecondProgress);
end;

procedure TfrmModalDualProgress.FormCreate(Sender: TObject);
begin
  lblProgressTitle.Font.Name := Font.Name;
end;

procedure TfrmModalDualProgress.FormShow(Sender: TObject);
begin
  PostMessage(Handle, UM_START_PROCESS, 0, 0);
end;

function TfrmModalDualProgress.GetCancelled: Boolean;
begin
  Result := FCancelled;
end;

function TfrmModalDualProgress.GetPrimaryProgress: IProgressControl;
begin
  Result := FPrimaryProgress;
end;

function TfrmModalDualProgress.GetSecondaryProgress: IProgressControl;
begin
  Result := FSecondaryProgress;
end;

function TfrmModalDualProgress.GetTitle: String;
begin
  Result := lblProgressTitle.Caption;
end;

procedure TfrmModalDualProgress.Initialize;
begin
  FPrimaryProgress.Initialize;
  FSecondaryProgress.Initialize;

  FCancelled := False;

  Application.ProcessMessages;
end;

procedure TfrmModalDualProgress.SetProgressData(const Value: TProgressData);
begin
  FProgressData := Value;
end;

procedure TfrmModalDualProgress.SetRaiseException(const Value: Boolean);
begin
  FRaiseException := Value;
end;

procedure TfrmModalDualProgress.SetTitle(const Value: String);
begin
  lblProgressTitle.Caption := Value;
end;

class function TfrmModalDualProgress.ShowProgress(Owner: TCustomForm; Caption, Title: String; OnStartProcessHandler:  TStartProcessEvent; var ProgressData: TProgressData): TModalResult;
var
  ProgressForm: TfrmModalDualProgress;
begin
  ProgressForm := TfrmModalDualProgress.Create(Owner);

  try
    ProgressForm.Caption := Caption;
    ProgressForm.Title := Title;
    ProgressForm.OnStartProcess := OnStartProcessHandler;
    ProgressForm.PopupParent := Owner;
    ProgressForm.PopupMode := pmExplicit;

    Result := ProgressForm.ShowModal;

    ProgressData := ProgressForm.ProgressData;
  finally
    ProgressForm.Free;
  end;
end;

procedure TfrmModalDualProgress.StartProcess;
begin
  if Assigned(FOnStartProcess) then
  begin
    FOnStartProcess(Self, ProgressData.CallbackParams);
  end;
end;

procedure TfrmModalDualProgress.UMStartProcess(var Message: TMessage);
begin
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

{ TProgressIndicator }

procedure TProgressIndicator.CompleteProgress;
begin
  if FProgressBar.Percent < 100 then
  begin
    FProgressBar.Percent := 100;

    Application.ProcessMessages;
  end;
end;

constructor TProgressIndicator.Create(ProgressBar: TRzProgressBar; ProgressLabel: TLabel = nil);
begin
  FProgressBar := ProgressBar;
  FProgressLabel := ProgressLabel;
end;

procedure TProgressIndicator.Initialize;
begin
  if Assigned(FProgressLabel) then
  begin
    FProgressLabel.Visible := False;
  end;
  
  FCurrentStepTotal := 0;

  FProgressBar.Percent := 0;
end;

procedure TProgressIndicator.SetProgressPosition(Position: Double);
begin
  FProgressBar.Percent := Round(Position);
end;

procedure TProgressIndicator.UpdateProgress(StepSize: Double);
var
  Remainder: Double;
begin
  FCurrentStepTotal := FCurrentStepTotal + StepSize;

  if not FProgressBar.Visible then
  begin
    FProgressBar.Visible := True;
  end;

  if FCurrentStepTotal >= 1 then
  begin
    Remainder := Frac(FCurrentStepTotal);
    
    FProgressBar.Percent := FProgressBar.Percent + Round(FCurrentStepTotal - Remainder);

    FCurrentStepTotal := Remainder;
  end;

  Application.ProcessMessages;
end;

procedure TProgressIndicator.UpdateProgress(const ProgressLabel: String; StepSize: Double);
var
  Remainder: Double;
begin
  FProgressLabel.Caption := ProgressLabel;

  if not FProgressLabel.Visible then
  begin
    FProgressLabel.Visible := True;
  end;

  FCurrentStepTotal := FCurrentStepTotal + StepSize;

  if FCurrentStepTotal >= 1 then
  begin
    Remainder := Frac(FCurrentStepTotal);
    
    FProgressBar.Percent := FProgressBar.Percent + Round(FCurrentStepTotal - Remainder);

    FCurrentStepTotal := Remainder;
  end;

  Application.ProcessMessages;
end;

procedure TProgressIndicator.UpdateProgressLabel(const ProgressLabel: String);
begin
  if Assigned(FProgressLabel) then
  begin
    FProgressLabel.Caption := ProgressLabel;

    if not FProgressLabel.Visible then
    begin
      FProgressLabel.Visible := True;
    end;

    Application.ProcessMessages;
  end;
end;

end.
