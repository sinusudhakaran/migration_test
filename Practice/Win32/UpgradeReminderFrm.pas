//------------------------------------------------------------------------------
unit UpgradeReminderFrm;

//------------------------------------------------------------------------------
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
  OSFont,
  StdCtrls,
  OleCtrls,
  SHDocVw,
  BKWebBrowser;

type
  //----------------------------------------------------------------------------
  TfrmUpgradeReminder = class(TForm)
    BKWebBrowser: TBKWebBrowser;
    btnOk: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    fHtmlReminder : string;
  protected
  public
    property HtmlReminder : string read fHtmlReminder write fHtmlReminder;
  end;

  procedure ShowUpgradeReminder(aHtmlReminder : string);

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  bkXPThemes,
  BKHelp;

//------------------------------------------------------------------------------
procedure ShowUpgradeReminder(aHtmlReminder : string);
var
  UpgradeReminder : TfrmUpgradeReminder;
begin
  UpgradeReminder := TfrmUpgradeReminder.Create(Application.mainForm);
  try
    UpgradeReminder.HtmlReminder := aHtmlReminder;

    BKHelpSetUp(UpgradeReminder, BKH_Setting_up_BankLink_users);
    UpgradeReminder.ShowModal;
  finally
    FreeAndNil(UpgradeReminder);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmUpgradeReminder.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
end;

//------------------------------------------------------------------------------
procedure TfrmUpgradeReminder.FormShow(Sender: TObject);
begin
  BKWebBrowser.LoadFromString(HtmlReminder);
end;

end.
