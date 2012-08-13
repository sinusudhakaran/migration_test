unit upgStubfrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  XPMan,
  ipscore,
  ipshttps;

type
  TForm1 = class(TForm)
    Button1: TButton;
    XPManifest1: TXPManifest;
    Button2: TButton;
    Button3: TButton;
    ipsHTTPS1: TipsHTTPS;
    btnCheckForCoreUpdate: TButton;
    btnCheckForCoreUpdateEx: TButton;
    bthCheckUpdatesCoreCheckIndividualFiles: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnCheckForCoreUpdateClick(Sender: TObject);
    procedure btnCheckForCoreUpdateExClick(Sender: TObject);
    procedure bthCheckUpdatesCoreCheckIndividualFilesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  //sCOREUPDATELOCATION = '\\banklink-fp\product\Internal\Banklink Core Application\Beta';
  sCOREUPDATELOCATION = '\\banklink-fp\product\Internal\Banklink Core Application';
  iCOREMAJOR = 1;
  iCOREMINOR = 45;
  iCORERELEASE = 4;
  iCOREBUILD = 0;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses
  upgConstants,
  upgClientCommon;

procedure TForm1.bthCheckUpdatesCoreCheckIndividualFilesClick(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;
begin
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    if Upgrader.CheckForUpdatesEx('BankLink Core Application', 0, aidInternal, iCOREMAJOR,
      iCOREMINOR, iCORERELEASE, iCOREBUILD, sCOREUPDATELOCATION, coInternal, PChar(''), false, true, true) =
      uaInstallPending then
      if
        MessageDlg('Updates for Banklink Core Application are pending.  Do you want to process them now?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        case Upgrader.InstallUpdatesEx('BankLink Core Application', 0,
          aidInternal, ifCloseIfRequired, True, true, 0) of
          uaCloseCallingApp: Close;
          uaUnableToLoad: ShowMessage('Load failed');
        end;
  finally
    Upgrader.Free;
  end;
end;

procedure TForm1.btnCheckForCoreUpdateClick(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;
begin
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    if Upgrader.CheckForUpdatesEx('BankLink Core Application', 0, aidInternal, iCOREMAJOR,
      iCOREMINOR, iCORERELEASE, iCOREBUILD, sCOREUPDATELOCATION, coInternal, PChar(''), false, false, true) =
      uaInstallPending then
      if
        MessageDlg('Updates for Banklink Core Application are pending.  Do you want to process them now?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        case Upgrader.InstallUpdates('BankLink Core Application', 0,
          aidInternal, ifCloseIfRequired, 0) of
          uaCloseCallingApp: Close;
          uaUnableToLoad: ShowMessage('Load failed');
        end;
  finally
    Upgrader.Free;
  end;
end;

procedure TForm1.btnCheckForCoreUpdateExClick(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;
begin
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    if Upgrader.CheckForUpdatesEx('BankLink Core Application', 0, aidInternal, iCOREMAJOR,
      iCOREMINOR, iCORERELEASE, iCOREBUILD, sCOREUPDATELOCATION, coInternal, PChar(''), true, true, false) =
      uaInstallPending then
      if
        MessageDlg('Updates for Banklink Core Application are pending.  Do you want to process them now?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        case Upgrader.InstallUpdatesEx('BankLink Core Application', 0,
          aidInternal, ifCloseIfRequired, True, true, 0) of
          uaCloseCallingApp: Close;
          uaUnableToLoad: ShowMessage('Load failed');
        end;
  finally
    Upgrader.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;

  Config: string;
begin
  //proxy/firewall
  Config := upgClientCommon.ConstructConfigXml(3600,
    true, //use wininet
    true, //use proxy
    '192.168.2.10', //server
    8002, //port
    '', //user
    '', //pwd
    0, //auth type
    false, //use firewall
    '', //host
    0, //port
    0, //type
    false, //use firewall auth
    '', //user
    '' //pwd
    );
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    if Upgrader.CheckForUpdates('BankLink', 0, aidBK5_Practice, 1, 2, 3, 4,
      'www.banklink.co.nz', 0, PChar(config)) = uaInstallPending then
      begin
        ShowMessage('downloads found');
      end;
  finally
    Upgrader.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;
begin
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    case Upgrader.InstallUpdates('BankLink', 0, aidBK5_Practice,
      ifCloseIfRequired, 0) of
      uaCloseCallingApp:
        Close;
      uaUnableToLoad: ShowMessage('Load failed');
    end;
  finally
    Upgrader.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Upgrader: TBkCommonUpgrader;
begin
  Upgrader := TBkCommonUpgrader.Create;
  try
    Upgrader.LoadShadowDll := false;
    if Upgrader.UpdatesPending('BankLink', 0, aidBK5_Practice) then
      ShowMessage('Updates pending...')
    else
      ShowMessage('None');
  finally
    Upgrader.Free;
  end;
end;

end.

