unit formWebHost;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, BKWebBrowser, ExtCtrls, OSFont, ActiveX,
  SHDocVw;

const
  WM_SHOWING = WM_USER + 1;

type
  TfrmWebHost = class(TForm)
    WebBrowser: TBKWebBrowser;
    procedure FormShow(Sender: TObject);
    procedure WebBrowserQuit(Sender: TObject);
    procedure WebBrowserWindowClosing(ASender: TObject; IsChildWindow: WordBool;
      var Cancel: WordBool);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GetFinalRedirectedURL(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);

  private
    FUrl: String;
    FFragmentTerminateUrl : shortstring;
    FFinalRedirectedUrl: String;
    fCloseOnFinalRedirect : boolean;
    FOleInPlaceActiveObject: IOleInPlaceActiveObject;
    FSaveMessageHandler: TMessageEvent;

    procedure WMShowing(var Message: TMessage); message WM_SHOWING;
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;
    procedure MsgHandler(var Msg: TMsg; var Handled: Boolean);
  public
    class procedure Show(Url: String ); static;
    class function GetRedirectedURL( Sender : TComponent; aURL,
      aFragmentTerminateUrl  : string;
      aCloseOnFinalRedirect : boolean = true ) : string; static;

    property Url: String read FUrl write FUrl;
    property FragmentTerminateUrl: shortstring read FFragmentTerminateUrl write FFragmentTerminateUrl;
    property CloseOnFinalRedirect : boolean read fCloseOnFinalRedirect write fCloseOnFinalRedirect;
    property FinalRedirectedUrl: String read FFinalRedirectedUrl;
  end;

implementation

{$R *.dfm}

{ TfrmNPSWebHost }

class function TfrmWebHost.GetRedirectedURL( Sender : TComponent; aURL,
        aFragmentTerminateUrl : string;
        aCloseOnFinalRedirect : boolean = true  ) : string;
var
  frmWebHost : TfrmWebHost;
begin
  result := '';
  frmWebHost := TfrmWebHost.Create( nil );
  try
    frmWebHost.Url := aUrl;
    frmWebHost.FragmentTerminateUrl := aFragmentTerminateUrl;
    frmWebHost.CloseOnFinalRedirect := aCloseOnFinalRedirect;
    frmWebHost.WebBrowser.OnNavigateComplete2 := frmWebHost.GetFinalRedirectedURL;
    frmWebHost.ShowModal;
  finally
    result := frmWebHost.FinalRedirectedUrl;
    freeAndNil( frmWebHost );
  end;
end;

procedure TfrmWebHost.FormCreate(Sender: TObject);
begin
  FSaveMessageHandler := Forms.Application.OnMessage;
  Application.OnMessage := MsgHandler;
end;

procedure TfrmWebHost.FormDestroy(Sender: TObject);
begin
  FOleInPlaceActiveObject := nil;
  Application.OnMessage := FSaveMessageHandler;
end;


procedure TfrmWebHost.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WebBrowser.Stop;
// DN !!!!!! Hack to avoid TWebBrowser bug that causes main process to hang on termination
  WebBrowser.LoadFromStream( nil ); // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// DN !!!!!! Hack to avoid TWebBrowser bug that causes main process to hang on termination
  Action := caFree;
end;

procedure TfrmWebHost.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_SHOWING, 0, 0);
end;

procedure TfrmWebHost.MsgHandler(var Msg: TMsg; var Handled: Boolean);
const
  StdKeys = [VK_BACK, VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_ESCAPE];
var IOIPAO: IOleInPlaceActiveObject;
  Dispatch: IDispatch;
begin
  if WebBrowser = nil then
  begin
    Handled := False;
    Exit;
  end;
  Handled := (IsDialogMessage(WebBrowser.Handle, Msg) = True);
  if (Handled) and (not WebBrowser.Busy) then
  begin
    if FOleInPlaceActiveObject = nil then
    begin
      Dispatch := WebBrowser.Application;
      if Dispatch <> nil then
      begin
        Dispatch.QueryInterface(IOleInPlaceActiveObject, IOIPAO);
        if IOIPAO <> nil then FOleInPlaceActiveObject := IOIPAO;
      end;
    end;
    if FOleInPlaceActiveObject <> nil then
      if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP)) and
        (Msg.wParam in StdKeys) then
        //nothing  -  do not pass on Backspace, Left, Right, Up, Down arrows
        if Msg.wParam = VK_ESCAPE then  //#89359 Lean Engage: ESC to close form and update button
          Close                         //#89359 Lean Engage: ESC to close form and update button
        else //if Msg.wParam = VK_ESCAPE then
      else FOleInPlaceActiveObject.TranslateAccelerator(Msg);
  end;
end;

class procedure TfrmWebHost.Show(Url: String);
var
  WebForm: TfrmWebHost;
begin
  WebForm := TfrmWebHost.Create(nil);

  try
    WebForm.Url := Url;

    WebForm.ShowModal;
  finally
    freeAndNil( WebForm );
  end;
end;

procedure TfrmWebHost.GetFinalRedirectedURL(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  lURL : shortstring;
  i : integer;
begin
  if not VarIsNull( URL  ) then begin
    lURL := URL;

    i := pos( fFragmentTerminateUrl, lURL );
    if i > 0 then begin

      lURL := copy(lURL, pos( fFragmentTerminateUrl, lURL ) +
        length( fFragmentTerminateUrl ),
          length( lURL ));
      FFinalRedirectedUrl := URL;

      if fCloseOnFinalRedirect then begin
        WebBrowser.Stop;
        Close;
      end;
    end;
  end;
end;

procedure TfrmWebHost.WebBrowserQuit(Sender: TObject);
begin
  WebBrowser.Stop;
  Close;
end;

procedure TfrmWebHost.WebBrowserWindowClosing(ASender: TObject;
  IsChildWindow: WordBool; var Cancel: WordBool);
begin
  Cancel := True;
  
  WebBrowser.Stop;
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TfrmWebHost.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if Msg.Result = htClient then
  begin
    Msg.Result := htCaption;
  end;
end;

procedure TfrmWebHost.WMShowing(var Message: TMessage);
begin
  if FUrl <> '' then
  begin
    WebBrowser.Navigate(FUrl);
  end;
end;

end.
