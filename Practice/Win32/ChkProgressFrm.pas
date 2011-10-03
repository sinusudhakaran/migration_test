unit ChkProgressFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  bkXPThemes,
  OsFont,
  ComCtrls,
  WebCiCoClient;

type
  TfrmChkProgress = class(TForm)
    mProgress: TMemo;
    btnOK: TButton;
    ProgressBar1: TProgressBar;
    lblStatus: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FClientCode: string;
    FPracticeCode: string;

    procedure SetClientCode(const Value: string);
    procedure SetPracticeCode(const Value: string);
  public
    procedure UpdateCICOStatus(StatusMessage : string);
    procedure UpdateCICOProgress(APercentComplete : integer;
                                 AMessage         : string);
    procedure UpdateStatus(StatusMessage : string);                                 
    property ClientCode: string read FClientCode write SetClientCode;
    property PracticeCode: string read FPracticeCode write SetPracticeCode;
  end;

implementation

uses
  LOGUTIL;

const
  UnitName = 'ChkProgressFrm';

{$R *.DFM}

procedure TfrmChkProgress.btnOKClick(Sender: TObject);
begin
  CiCoClient.OnTransferFileEvent := nil; 
  Close;
end;

procedure TfrmChkProgress.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  btnOk.left := (Self.Width - btnOK.Width) div 2;
end;

procedure TfrmChkProgress.FormResize(Sender: TObject);
begin
  btnOk.left := (Self.Width - btnOK.Width) div 2;
end;

procedure TfrmChkProgress.SetClientCode(const Value: string);
begin
  FClientCode := Value;
end;

procedure TfrmChkProgress.SetPracticeCode(const Value: string);
begin
  FPracticeCode := Value;
end;

procedure TfrmChkProgress.UpdateCICOProgress(APercentComplete : integer;
                                             AMessage         : string);
begin
  lblStatus.Caption     := AMessage;
  ProgressBar1.Position := APercentComplete;
  Refresh;
end;

procedure TfrmChkProgress.UpdateCICOStatus(StatusMessage: string);
begin
  mProgress.Lines.Add(StatusMessage);
end;

procedure TfrmChkProgress.UpdateStatus(StatusMessage: string);
begin
  mProgress.Lines.Add(StatusMessage);
end;

end.
