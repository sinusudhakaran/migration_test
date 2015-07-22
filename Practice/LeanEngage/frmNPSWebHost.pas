unit frmNPSWebHost;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ExtCtrls, OSFont;

const
  WM_SHOWING = WM_USER + 1;
  
type
  TfrmNPSWebHost = class(TForm)
    WebBrowser: TWebBrowser;
    procedure FormShow(Sender: TObject);
    procedure WebBrowserQuit(Sender: TObject);
    procedure WebBrowserWindowClosing(ASender: TObject; IsChildWindow: WordBool;
      var Cancel: WordBool);
  private
    FUrl: String;
    
    procedure WMShowing(var Message: TMessage); message WM_SHOWING;
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;
  public
    class procedure Show(Url: String; Owner: TComponent = nil); static;

    property Url: String read FUrl write FUrl;
  end;

implementation

{$R *.dfm}

{ TfrmNPSWebHost }

procedure TfrmNPSWebHost.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_SHOWING, 0, 0);
end;

class procedure TfrmNPSWebHost.Show(Url: String; Owner: TComponent = nil);
var
  WebForm: TfrmNPSWebHost;
begin
  WebForm := TfrmNPSWebHost.Create(Owner);

  try
    WebForm.Url := Url;

    WebForm.ShowModal;
  finally
    WebForm.Free;
  end;
end;

procedure TfrmNPSWebHost.WebBrowserQuit(Sender: TObject);
begin
  Close;
end;

procedure TfrmNPSWebHost.WebBrowserWindowClosing(ASender: TObject;
  IsChildWindow: WordBool; var Cancel: WordBool);
begin
  Cancel := True;
  
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TfrmNPSWebHost.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if Msg.Result = htClient then
  begin
    Msg.Result := htCaption;
  end;
end;

procedure TfrmNPSWebHost.WMShowing(var Message: TMessage);
begin
  if FUrl <> '' then
  begin
    WebBrowser.Navigate(FUrl);
  end;
end;

end.
