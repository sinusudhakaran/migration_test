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
    { Private declarations }
    procedure ActivateApplication(Sender: TObject);
  public
    { Public declarations }
    procedure UpdateCICOStatus(StatusMessage : string);
    procedure UpdateCICOProgress(Direction: TDirectionIndicator;
                                 TransferStatus : TTransferStatus;
                                 BytesTransferred: LongInt;
                                 TotalBytes: LongInt);
  end;

implementation

{$R *.DFM}

procedure TfrmChkProgress.btnOKClick(Sender: TObject);
begin
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

procedure TfrmChkProgress.UpdateCICOProgress(Direction: TDirectionIndicator;
  TransferStatus: TTransferStatus; BytesTransferred, TotalBytes: Integer);
begin
  ProgressBar1.Max := TotalBytes;
  ProgressBar1.Step := 1;
  ProgressBar1.Position := BytesTransferred;

  case TransferStatus of
    trsStartTrans      : lblStatus.Caption := 'Upload to BankLink Online started';
    trsTransInProgress : lblStatus.Caption := 'Uploading to BankLink Online';
    trsEndTrans        : lblStatus.Caption := 'Uploaded to BankLink Online';
  end;
end;
procedure TfrmChkProgress.UpdateCICOStatus(StatusMessage: string);
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
