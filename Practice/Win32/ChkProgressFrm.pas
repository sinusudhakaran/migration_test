unit ChkProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,bkXPThemes,
  OsFont, ComCtrls, WebCiCoClient;

type
  TfrmChkProgress = class(TForm)
    mProgress: TMemo;
    btnOK: TButton;
    ProgressBar1: TProgressBar;
    lblStatus: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FClientCode: string;
    FPracticeCode: string;
    { Private declarations }
    procedure ActivateApplication(Sender: TObject);
    procedure SetClientCode(const Value: string);
    procedure SetPracticeCode(const Value: string);
  public
    { Public declarations }
    procedure UpdateCICOStatus(StatusMessage : string);
    procedure UpdateCICOProgress(Direction: TDirectionIndicator;
                                 TransferStatus : TTransferStatus;
                                 BytesTransferred: LongInt;
                                 TotalBytes: LongInt;
                                 ContentType: String);
    procedure UpdateStatus(StatusMessage : string);                                 
    property ClientCode: string read FClientCode write SetClientCode;
    property PracticeCode: string read FPracticeCode write SetPracticeCode;
  end;

implementation

uses LOGUTIL;

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
  Application.OnActivate := Self.ActivateApplication;
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

procedure TfrmChkProgress.UpdateCICOProgress(Direction: TDirectionIndicator;
  TransferStatus: TTransferStatus; BytesTransferred, TotalBytes: Integer;
  ContentType: String);
const
  ThisMethodName = 'TfrmChkProgress.UpdateCICOProgress';
var
  Msg: string;
begin
  if (Direction = dirFromClient) then begin
    case TransferStatus of
      trsStartTrans      : lblStatus.Caption := 'Upload to BankLink Online started';
      trsTransInProgress : begin
                             lblStatus.Caption := 'Uploading to BankLink Online';
                             ProgressBar1.Max := TotalBytes;
                             ProgressBar1.Step := 1;
                             ProgressBar1.Position := BytesTransferred;
                           end;
      trsEndTrans        : begin
                             Msg := Format('Check Out %s to BankLink Online ''%s\%s'' succeeded',
                                           [FClientCode, FPracticeCode, FClientCode]);
                             LogUtil.LogMsg(lmInfo, UnitName , ThisMethodName + ' : ' + Msg);
                             mProgress.Lines.Add(Msg);
                             lblStatus.Caption := 'Uploaded to BankLink Online';
                           end;
    end;
  end;
end;

procedure TfrmChkProgress.UpdateCICOStatus(StatusMessage: string);
begin
  mProgress.Lines.Add(StatusMessage);
end;

procedure TfrmChkProgress.UpdateStatus(StatusMessage: string);
begin
  mProgress.Lines.Add(StatusMessage);
end;

procedure TfrmChkProgress.ActivateApplication(Sender: TObject);
begin
  Application.BringToFront;
  if Self.Visible and Self.Enabled then
  begin
    Self.BringToFront;
    Self.SetFocus;
  end;
end;

procedure TfrmChkProgress.FormDestroy(Sender: TObject);
begin
  Application.OnActivate := nil;
end;

end.
