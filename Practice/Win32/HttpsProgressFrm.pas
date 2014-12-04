unit HttpsProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ipscore, ipshttps, ulkJSON;

type
  TfrmHttpsProgress = class(TForm)
    lblStatus: TLabel;
    prgProgress: TProgressBar;
    btnCancel: TButton;
    ipsHTTPS: TipsHTTPS;
    procedure ipsHTTPSConnected(Sender: TObject; StatusCode: Integer;
      const Description: string);
    procedure ipsHTTPSConnectionStatus(Sender: TObject;
      const ConnectionEvent: string; StatusCode: Integer;
      const Description: string);
    procedure ipsHTTPSDisconnected(Sender: TObject; StatusCode: Integer;
      const Description: string);
    procedure ipsHTTPSEndTransfer(Sender: TObject; Direction: Integer);
    procedure ipsHTTPSError(Sender: TObject; ErrorCode: Integer;
      const Description: string);
    procedure ipsHTTPSHeader(Sender: TObject; const Field, Value: string);
    procedure ipsHTTPSRedirect(Sender: TObject; const Location: string;
      var Accept: Boolean);
    procedure ipsHTTPSSetCookie(Sender: TObject; const Name, Value, Expires,
      Domain, Path: string; Secure: Boolean);
    procedure ipsHTTPSSSLServerAuthentication(Sender: TObject;
      CertEncoded: string; const CertSubject, CertIssuer, Status: string;
      var Accept: Boolean);
    procedure ipsHTTPSSSLStatus(Sender: TObject; const Message: string);
    procedure ipsHTTPSStartTransfer(Sender: TObject; Direction: Integer);
    procedure ipsHTTPSStatus(Sender: TObject; const HTTPVersion: string;
      StatusCode: Integer; const Description: string);
    procedure ipsHTTPSTransfer(Sender: TObject; Direction,
      BytesTransferred: Integer; Text: string);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    fResponse: string;
    fError: string;

    procedure HeartBeat;

    procedure Start(const aURL: string; const aRequest: string);

  public
    { Public declarations }

  end;

  function  DoHttpSecure(const aURL: string; const aRequest: string;
              var aResponse: string; var aError: string): boolean;

implementation

{$R *.dfm}

function DoHttpSecure(const aURL: string; const aRequest: string;
  var aResponse: string; var aError: string): boolean;
var
  Progress: TfrmHttpsProgress;
  mrResult: TModalResult;
begin
  Progress := nil;
  try
    Progress := TfrmHttpsProgress.Create(Application.MainForm);

    Progress.Start(aURL, aRequest);

    mrResult := Progress.ShowModal;
    result := (mrResult = mrOk);

    aResponse := Progress.fResponse;
    aError := Progress.fError;
  finally
    FreeAndNil(Progress);
  end;
end;

procedure TfrmHttpsProgress.Start(const aURL: string; const aRequest: string);
begin
  ipsHTTPS.PostData := aRequest;
  ipsHTTPS.Post(aURL);
end;

procedure TfrmHttpsProgress.HeartBeat;
begin
  Application.ProcessMessages;
end;

procedure TfrmHttpsProgress.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmHttpsProgress.ipsHTTPSConnected(Sender: TObject;
  StatusCode: Integer; const Description: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSConnectionStatus(Sender: TObject;
  const ConnectionEvent: string; StatusCode: Integer;
  const Description: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSDisconnected(Sender: TObject;
  StatusCode: Integer; const Description: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSEndTransfer(Sender: TObject;
  Direction: Integer);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSError(Sender: TObject; ErrorCode: Integer;
  const Description: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSHeader(Sender: TObject; const Field,
  Value: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSRedirect(Sender: TObject;
  const Location: string; var Accept: Boolean);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSSetCookie(Sender: TObject; const Name,
  Value, Expires, Domain, Path: string; Secure: Boolean);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSSSLServerAuthentication(Sender: TObject;
  CertEncoded: string; const CertSubject, CertIssuer, Status: string;
  var Accept: Boolean);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSSSLStatus(Sender: TObject;
  const Message: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSStartTransfer(Sender: TObject;
  Direction: Integer);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSStatus(Sender: TObject;
  const HTTPVersion: string; StatusCode: Integer; const Description: string);
begin
  HeartBeat;
end;

procedure TfrmHttpsProgress.ipsHTTPSTransfer(Sender: TObject; Direction,
  BytesTransferred: Integer; Text: string);
begin
  HeartBeat;
end;

end.
