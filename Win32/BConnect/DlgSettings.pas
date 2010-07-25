//*****************************************************************************
//
// Unit Name: DlgSettings
// Date/Time: 28/09/2001 10:04:13
// Purpose  :
// Author   : Peter Speden
// History  :
//
//*****************************************************************************

unit DlgSettings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RzEdit, StdCtrls, Mask, RzCommon, RzCmboBx, ExtCtrls, RzDlgBtn, RzButton,
  RzPanel, ipshttps, ComCtrls

{$IFDEF SSLV6}
  ,bkXPThemes,
  OSFont
{$ENDIF}
   ;


type
  TdlgSettings = class(TForm)
    dbtnButtons: TRzDialogButtons;
    RzFrameController1: TRzFrameController;
    pnlBasic: TRzPanel;
    pnlAdvanced: TRzPanel;
    gbAdvancedSettings: TGroupBox;
    RzPanel1: TRzPanel;
    chkUseWinINet: TCheckBox;
    pcAdvancedSettings: TPageControl;
    tshtProxySettings: TTabSheet;
    lblProxyPort: TLabel;
    lblProxyHost: TLabel;
    lblProxyAuthMethod: TLabel;
    lblProxyUserName: TLabel;
    lblProxyPassword: TLabel;
    chkUseProxy: TCheckBox;
    rbtnDetect: TRzButton;
    rnProxyPort: TRzNumericEdit;
    reProxyHost: TRzEdit;
    cboProxyAuthMethod: TRzComboBox;
    reProxyUserName: TRzEdit;
    reProxyPassword: TRzEdit;
    tshtFirewallSettings: TTabSheet;
    lblFirewallType: TLabel;
    lblFirewallUserName: TLabel;
    lblFirewallPassword: TLabel;
    lblFirewallHost: TLabel;
    lblFirewallPort: TLabel;
    cboFirewallType: TRzComboBox;
    chkUseFirewallAuthentication: TCheckBox;
    reFirewallUsername: TRzEdit;
    reFirewallPassword: TRzEdit;
    chkUseFirewall: TCheckBox;
    reFirewallHost: TRzEdit;
    rnFirewallPort: TRzNumericEdit;
    gbPrimaryServer: TGroupBox;
    lblPrimaryHost: TLabel;
    rePrimaryHost: TRzEdit;
    lblPrimaryPort: TLabel;
    rnPrimaryPort: TRzNumericEdit;
    rnSecondaryPort: TRzNumericEdit;
    lblSecondaryPort: TLabel;
    reSecondaryHost: TRzEdit;
    lblSecondaryHost: TLabel;
    lblTimeout: TLabel;
    rnTimeout: TRzNumericEdit;
    chkUseCustomConfiguration: TCheckBox;
    procedure dbtnButtonsClickOk(Sender: TObject);
    procedure dbtnButtonsClickCancel(Sender: TObject);
    procedure chkUseProxyClick(Sender: TObject);
    procedure rbtnDetectClick(Sender: TObject);
    procedure chkUseFirewallAuthenticationClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure chkUseCustomConfigurationClick(Sender: TObject);
    procedure cboProxyAuthMethodChange(Sender: TObject);
    procedure cboFirewallTypeChange(Sender: TObject);
    procedure chkUseFirewallClick(Sender: TObject);
    procedure chkUseWinINetClick(Sender: TObject);
  private
    { Private declarations }
    FTop : integer;
    FSettingsUpdated: boolean;
    FiniUseProxy: boolean;
    FiniUseFirewall: boolean;
    FiniUseCustomConfiguration: boolean;
    FiniPrimaryPort: integer;
    FiniProxyAuthMethod: integer;
    FiniTimeout: integer;
    FiniFirewallPort: integer;
    FiniSecondaryPort: integer;
    FiniProxyPort: integer;
    FiniPrimaryHost: string;
    FiniProxyUserName: string;
    FiniProxyHost: string;
    FiniProxyPassword: string;
    FiniSecondaryHost: string;
    FiniUseFirewallAuthentication: boolean;
    FiniFirewallUserName: string;
    FiniFirewallPassword: string;
    FiniFirewallHost: string;
    FiniFirewallType: TipshttpsFirewallTypes;
    FiniUseWinINet: boolean;

    InitialisingForm : boolean;
    UserCanChangeWinInet : boolean;

    function IntToSocksVersion(const VerInt: integer): TipshttpsFirewallTypes;
    function SocksVersionToInt(SocksVer: TipshttpsFirewallTypes): integer;
    procedure SetiniFirewallHost(const Value: string);
    procedure SetiniFirewallPassword(const Value: string);
    procedure SetiniFirewallPort(const Value: integer);
    procedure SetiniFirewallType(const Value: TipshttpsFirewallTypes);
    procedure SetiniFirewallUserName(const Value: string);
    procedure SetiniPrimaryHost(const Value: string);
    procedure SetiniPrimaryPort(const Value: integer);
    procedure SetiniProxyAuthMethod(const Value: integer);
    procedure SetiniProxyHost(const Value: string);
    procedure SetiniProxyPassword(const Value: string);
    procedure SetiniProxyPort(const Value: integer);
    procedure SetiniProxyUserName(const Value: string);
    procedure SetiniSecondaryHost(const Value: string);
    procedure SetiniSecondaryPort(const Value: integer);
    procedure SetiniTimeout(const Value: integer);
    procedure SetiniUseCustomConfiguration(const Value: boolean);
    procedure SetiniUseFirewall(const Value: boolean);
    procedure SetiniUseFirewallAuthentication(const Value: boolean);
    procedure SetiniUseProxy(const Value: boolean);
    procedure SetiniUseWinINet(const Value: boolean);
    procedure AutoDetect(Root: Cardinal);    
  public
    { Public declarations }
    constructor Create(AOwner: TComponent;
      APrimaryHost : string;
      APrimaryPort : integer;
      ASecondaryHost: string;
      ASecondaryPort: integer;
      ATimeout : integer;
      UseCustomConfiguration : boolean;
      UseWinINet : boolean;
      UseProxy : boolean;
      AProxyHost: string;
      AProxyPort: integer;
      AProxyAuthMethod : integer;
      AProxyUserName : string;
      AProxyPassword : string;
      UseFirewall : boolean;
      AFirewallHost: string;
      AFirewallPort: integer;
      AFirewallType : TipshttpsFirewallTypes;
      UseFirewallAuthentication : boolean;
      AFirewallUserName : string;
      AFirewallPassword : string
      ); reintroduce;
    property iniPrimaryHost: string read FiniPrimaryHost write
      SetiniPrimaryHost;
    property iniPrimaryPort: integer read FiniPrimaryPort write
      SetiniPrimaryPort;
    property iniSecondaryHost: string read FiniSecondaryHost write
      SetiniSecondaryHost;
    property iniSecondaryPort: integer read FiniSecondaryPort write
      SetiniSecondaryPort;
    property iniTimeout: integer read FiniTimeout write SetiniTimeout;
    property iniUseCustomConfiguration: boolean read FiniUseCustomConfiguration write SetiniUseCustomConfiguration;
    property iniUseWinINet: boolean read FiniUseWinINet write SetiniUseWinINet;
    property iniUseProxy: boolean read FiniUseProxy write SetiniUseProxy;
    property iniProxyHost: string read FiniProxyHost write SetiniProxyHost;
    property iniProxyPort: integer read FiniProxyPort write SetiniProxyPort;
    property iniProxyAuthMethod: integer read FiniProxyAuthMethod write SetiniProxyAuthMethod;
    property iniProxyUserName: string read FiniProxyUserName write
      SetiniProxyUserName;
    property iniProxyPassword: string read FiniProxyPassword write
      SetiniProxyPassword;
    property iniUseFirewall: boolean read FiniUseFirewall write SetiniUseFirewall;
    property iniFirewallHost: string read FiniFirewallHost write SetiniFirewallHost;
    property iniFirewallPort: integer read FiniFirewallPort write SetiniFirewallPort;
    property iniFirewallType: TipshttpsFirewallTypes read FiniFirewallType write
      SetiniFirewallType;
    property iniUseFirewallAuthentication : boolean
      read FiniUseFirewallAuthentication
      write SetiniUseFirewallAuthentication;
    property iniFirewallUserName: string read FiniFirewallUserName write
      SetiniFirewallUserName;
    property iniFirewallPassword: string read FiniFirewallPassword write
      SetiniFirewallPassword;

    property SettingsUpdated: boolean read FSettingsUpdated default false;
  end;

  //******************************************************************************
implementation
uses
  Registry, WinUtils;
{$R *.DFM}

const
  MIN_FORM_HEIGHT   = 190;
  MAX_FORM_HEIGHT   = 450;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function WinInetRequired : boolean;
//returns true if win inet MUST be used, this is true for Win 9x machines
//or NT prior to NT4
var
  OSVersionInfo32: OSVERSIONINFO;
begin
  Result := false;

  OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
  GetVersionEx(OSVersionInfo32);

  case OSVersionInfo32.dwPlatformId of
    VER_PLATFORM_WIN32s:        //Win 3.x 32bit
       result := true;

    VER_PLATFORM_WIN32_WINDOWS: //Windows 95/98
       result := true;

    VER_PLATFORM_WIN32_NT:      //Windows NT, 2000, XP
       if OSVersionInfo32.dwMajorVersion < 4 then
          result := true
       else
          result := false;
  end; { end case }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//******************************************************************************
// TdlgSettings.SocksVersionToInt
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : SocksVer: TipshttpsFirewallTypes
// Result     : integer
// Purpose    : Retrieve the socks version as an interger
//
//******************************************************************************

function TdlgSettings.SocksVersionToInt(SocksVer: TipshttpsFirewallTypes): integer;
begin
  result := Ord (SocksVer);
end;

//******************************************************************************
// TdlgSettings.IntToSocksVersion
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : const VerInt: integer
// Result     : TipshttpsFirewallTypes
// Purpose    : Turn an integer into the Socks Version
//
//******************************************************************************

function TdlgSettings.IntToSocksVersion(const VerInt: integer): TipshttpsFirewallTypes;
begin
  result := TipshttpsFirewallTypes (VerInt);
end;

//******************************************************************************
// TdlgSettings.dbtnButtonsClickOk
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Clicking the OK button updates all the values for sending back
//              to the calling screen and then closes
//
//******************************************************************************

procedure TdlgSettings.dbtnButtonsClickOk(Sender: TObject);
begin
  //save ini settings
  iniPrimaryHost               := rePrimaryHost.Text;
  iniPrimaryPort               := rnPrimaryPort.IntValue;
  iniSecondaryHost             := reSecondaryHost.Text;
  iniSecondaryPort             := rnSecondaryPort.IntValue;
  iniTimeout                   := rnTimeout.IntValue;
  iniUseCustomConfiguration    := chkUseCustomConfiguration.Checked;
  iniUseWinINet                := chkUseWinINet.Checked;
  iniUseProxy                  := chkUseProxy.Checked;
  iniProxyHost                 := reProxyHost.Text;
  iniProxyPort                 := rnProxyPort.IntValue;
  iniProxyAuthMethod           := cboProxyAuthMethod.ItemIndex;
  iniProxyUserName             := reProxyUsername.Text;
  iniProxyPassword             := reProxyPassword.Text;
  iniUseFirewall               := chkUseFirewall.Checked;
  iniFirewallHost              := reFirewallHost.Text;
  iniFirewallPort              := rnProxyPort.IntValue;
  iniFirewallType              := IntToSocksVersion(cboFirewallType.ItemIndex);
  iniUseFirewallAuthentication := chkUseFirewallAuthentication.Checked;
  iniFirewallUserName          := reFirewallUsername.Text;
  iniFirewallPassword          := reFirewallPassword.Text;
  Close;
end;

//******************************************************************************
// TdlgSettings.dbtnButtonsClickCancel
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Cancel is clicked, all updates are cancelled and the screen is
//              closed
//
//******************************************************************************

procedure TdlgSettings.dbtnButtonsClickCancel(Sender: TObject);
begin
  FSettingsUpdated := false;
  Close;
end;

//******************************************************************************
// TdlgSettings.chkUseProxyClick
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : If the user clicks the Use Proxy check box it must enable or
//              disable the checkboxes that rely on it.
//
//******************************************************************************

procedure TdlgSettings.chkUseProxyClick(Sender: TObject);
var
  tf: boolean;
begin
  tf := chkUseProxy.Checked and chkUseCustomConfiguration.Checked;

  lblProxyHost.Enabled := tf;
  reProxyHost.Enabled := tf;

  lblProxyPort.Enabled := tf;
  rnProxyPort.Enabled := tf;

  lblProxyAuthMethod.Enabled := tf;
  cboProxyAuthMethod.Enabled := tf;
  cboProxyAuthMethodChange (self);
end;

//******************************************************************************
// TdlgSettings.rbtnDetectClick
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Reads the proxy settings out of the registry and puts them into
//              the appropriate fields.
//
//******************************************************************************

procedure TdlgSettings.rbtnDetectClick(Sender: TObject);
begin
  AutoDetect(HKEY_CURRENT_USER);
  if (Pos('Vista', WinUtils.GetWinVer) > 0) and (not chkUseProxy.Checked) then
    // Vista security - may be set here
    AutoDetect(HKEY_LOCAL_MACHINE);
end;

procedure TdlgSettings.AutoDetect(Root: Cardinal);
var
  Reg          : TRegistry;
  KeyName      : string;
  CP           : string;
  ProxyEnabled : integer;
  HttpProxyHost: string;
  HttpProxyPort: integer;
  RegDataSize  : integer;
  Buffer       : Array[0..3] of Byte;
begin
  KeyName := '\Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  Reg := TRegistry.Create;
  try
     Reg.Access := KEY_READ;
     Reg.RootKey := Root;
     Reg.OpenKey(KeyName, False);

     if Reg.ValueExists('ProxyEnable') then begin
          ProxyEnabled := 0;
          try
             case Reg.GetDataType( 'ProxyEnable') of
                rdInteger : ProxyEnabled := Reg.ReadInteger('ProxyEnable');
                rdBinary : begin
                   //win95 machines stored Proxy Enable as a 4 bit binary value
                   RegDataSize := Reg.GetDataSize( 'ProxyEnable');
                   if ( RegDataSize = 4) then begin
                      Reg.ReadBinaryData( 'ProxyEnable', Buffer, RegDataSize);
                      ProxyEnabled := Integer( Buffer);
                   end;
                end;
             end;
          except
             On E : ERegistryException do
                ;
          end;
          chkUseProxy.Checked := (ProxyEnabled <> 0);
       end
     else
       chkUseProxy.Checked := false;

     if Reg.ValueExists('ProxyServer') then begin
         try
           CP := Reg.ReadString('ProxyServer'); // Your Proxy that is currently set on
         except
           On E : ERegistryException do
              Exit;
         end;
         //an active connection

         //if different proxy settings for each protocol then ; will be in string
         if (Pos(';', CP) <> 0) then
           begin
             CP := Copy(CP, Pos('http=', CP) + 5, Length(CP));
             CP := Copy(CP, 0, Pos(';', CP) - 1);
           end;
         //should have string  'http://SLIDER:80'
         //strip of // if added
         if Pos('//', CP) > 0 then
           CP := Copy(CP, Pos('//', CP) + 2, length(CP));

         HttpProxyHost := Copy(CP, 1, Pos(':', CP) - 1);
         CP := Copy(CP, Pos(':', CP) + 1, length(CP));
         HttpProxyPort := StrToIntDef(CP, 0);

         reProxyHost.Text := httpProxyHost;
         rnProxyPort.IntValue := httpProxyPort;
       end;
  finally
     Reg.Free;
  end;
end;

//******************************************************************************
// TdlgSettings.Create
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : AOwner: TComponent;
//              APrimaryHost: string;
//              ASecondaryHost: string;
//              APrimaryPort: integer;
//              ASecondaryPort: integer;
//              AProxyName: string;
//              AProxyPort: integer;
//              ASocksVersion: TipshttpsFirewallTypes;
//              UseProxy, UseSocks,
//              LoginToProxy: boolean;
//              AProxyUserName: string;
//              AProxyPassword: string;
// Result     : None
// Purpose    : Creates and Initialises the form
//
//******************************************************************************

constructor TdlgSettings.Create(AOwner: TComponent;
      APrimaryHost : string;
      APrimaryPort : integer;
      ASecondaryHost: string;
      ASecondaryPort: integer;
      ATimeout : integer;
      UseCustomConfiguration : boolean;
      UseWinINet : boolean;
      UseProxy : boolean;
      AProxyHost: string;
      AProxyPort: integer;
      AProxyAuthMethod : integer;
      AProxyUserName : string;
      AProxyPassword : string;
      UseFirewall : boolean;
      AFirewallHost: string;
      AFirewallPort: integer;
      AFirewallType : TipshttpsFirewallTypes;
      UseFirewallAuthentication : boolean;
      AFirewallUserName : string;
      AFirewallPassword : string);
begin
  inherited Create(AOwner);
  iniPrimaryHost               := APrimaryHost;
  iniPrimaryPort               := APrimaryPort;
  iniSecondaryHost             := ASecondaryHost;
  iniSecondaryPort             := ASecondaryPort;
  iniTimeout                   := ATimeout;
  iniUseCustomConfiguration    := UseCustomConfiguration;
  iniUseWinINet                := UseWinINet;
  iniUseProxy                  := UseProxy;
  iniProxyHost                 := AProxyHost;
  iniProxyPort                 := AProxyPort;
  iniProxyAuthMethod           := AProxyAuthMethod;
  iniProxyUserName             := AProxyUserName;
  iniProxyPassword             := AProxyPassword;
  iniUseFirewall               := UseFirewall;
  iniFirewallHost              := AFirewallHost;
  iniFirewallPort              := AFirewallPort;
  iniFirewallType              := AFirewallType;
  iniUseFirewallAuthentication := UseFirewallAuthentication;
  iniFirewallUserName          := AFirewallUserName;
  iniFirewallPassword          := AFirewallPassword;

  FSettingsUpdated := false;
end;

//******************************************************************************
// TdlgSettings.chkAuthRequiredClick
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : If the user selects Authentication Required, then the boxes that
//              rely on this are enabled/disabled.
//
//******************************************************************************

procedure TdlgSettings.chkUseFirewallAuthenticationClick(Sender: TObject);
var
  tf: boolean;
begin
  tf := chkUseFirewallAuthentication.Checked and chkUseFirewall.Checked and chkUseCustomConfiguration.Checked;

  lblFirewallUsername.Enabled := tf;
  reFirewallUsername.Enabled := tf;

  lblFirewallPassword.Enabled := tf;
  reFirewallPassword.Enabled := tf;
end;

//******************************************************************************
// TdlgSettings.FormCreate
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Initialises some values as the form is created
//
//******************************************************************************

procedure TdlgSettings.FormCreate(Sender: TObject);
begin
  
{$IFDEF SSLV6}
  bkXPThemes.ThemeForm( Self);
{$ENDIF}

  FTop := (Screen.WorkAreaHeight div 2) - (Height div 2);
  Height := MIN_FORM_HEIGHT;
  UserCanChangeWinInet := not WinInetRequired;
end;


//******************************************************************************
// TdlgSettings.FormActivate
//
// Date       : 28/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : When the form is activated, set the values of the boxes and set
//              the top of the form.
//
//******************************************************************************

procedure TdlgSettings.FormActivate(Sender: TObject);
begin
  InitialisingForm := true;
  try
     Top := FTop;

     rePrimaryHost.Text                        := iniPrimaryHost;
     rnPrimaryPort.IntValue                    := iniPrimaryPort;
     reSecondaryHost.Text                      := iniSecondaryHost;
     rnSecondaryPort.IntValue                  := iniSecondaryPort;
     rnTimeout.IntValue                        := iniTimeout;
     chkUseCustomConfiguration.Checked         := iniUseCustomConfiguration;
     chkUseWinINet.Checked                     := iniUseWinINet;
     chkUseProxy.Checked                       := iniUseProxy;
     reProxyHost.Text                          := iniProxyHost;
     rnProxyPort.IntValue                      := iniProxyPort;
     cboProxyAuthMethod.ItemIndex              := iniProxyAuthMethod;
     reProxyUsername.Text                      := iniProxyUserName;
     reProxyPassword.Text                      := iniProxyPassword;
     chkUseFirewall.Checked                    := iniUseFirewall;
     reFirewallHost.Text                       := iniFirewallHost;
     rnProxyPort.IntValue                      := iniFirewallPort;
     cboFirewallType.ItemIndex                 := SocksVersionToInt (iniFirewallType);
     chkUseFirewallAuthentication.Checked      := iniUseFirewallAuthentication;
     reFirewallUsername.Text                   := iniFirewallUserName;
     reFirewallPassword.Text                   := iniFirewallPassword;
     FSettingsUpdated := false;

     chkUseCustomConfigurationClick (nil);
  finally
     InitialisingForm := false;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgSettings.chkUseCustomConfigurationClick(Sender: TObject);
var
  tf: boolean;
begin
  tf := chkUseCustomConfiguration.Checked;

  chkUseWinINet.Enabled := tf and UserCanChangeWinInet;

  chkUseProxy.Enabled := tf;
  chkUseProxyClick(self);

  chkUseFirewall.Enabled := tf;
  chkUseFirewallClick(self);

  if chkUseCustomConfiguration.Checked then begin
      Height := MAX_FORM_HEIGHT;
      pnlAdvanced.Visible := true;
  end
  else begin
      Height := MIN_FORM_HEIGHT;
      pnlAdvanced.Visible := false;
  end;
end;

procedure TdlgSettings.SetiniFirewallHost(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniFirewallHost <> Value);
  FiniFirewallHost := Value;
end;

procedure TdlgSettings.SetiniFirewallPassword(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniFirewallPassword <> Value);
  FiniFirewallPassword := Value;
end;

procedure TdlgSettings.SetiniFirewallPort(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniFirewallPort <> Value);
  FiniFirewallPort := Value;
end;

procedure TdlgSettings.SetiniFirewallType(
  const Value: TipshttpsFirewallTypes);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniFirewallType <> Value);
  FiniFirewallType := Value;
end;

procedure TdlgSettings.SetiniFirewallUserName(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniFirewallUserName <> Value);
  FiniFirewallUserName := Value;
end;

procedure TdlgSettings.SetiniPrimaryHost(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniPrimaryHost <> Value);
  FiniPrimaryHost := Value;
end;

procedure TdlgSettings.SetiniPrimaryPort(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniPrimaryPort <> Value);
  FiniPrimaryPort := Value;
end;

procedure TdlgSettings.SetiniProxyAuthMethod(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniProxyAuthMethod <> Value);
  FiniProxyAuthMethod := Value;
end;

procedure TdlgSettings.SetiniProxyHost(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniProxyHost <> Value);
  FiniProxyHost := Value;
end;

procedure TdlgSettings.SetiniProxyPassword(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniProxyPassword <> Value);
  FiniProxyPassword := Value;
end;

procedure TdlgSettings.SetiniProxyPort(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniProxyPort <> Value);
  FiniProxyPort := Value;
end;

procedure TdlgSettings.SetiniProxyUserName(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniProxyUserName <> Value);
  FiniProxyUserName := Value;
end;

procedure TdlgSettings.SetiniSecondaryHost(const Value: string);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniSecondaryHost <> Value);
  FiniSecondaryHost := Value;
end;

procedure TdlgSettings.SetiniSecondaryPort(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniSecondaryPort <> Value);
  FiniSecondaryPort := Value;
end;

procedure TdlgSettings.SetiniTimeout(const Value: integer);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniTimeout <> Value);
  FiniTimeout := Value;
end;

procedure TdlgSettings.SetiniUseCustomConfiguration(const Value: boolean);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniUseCustomConfiguration <> Value);
  FiniUseCustomConfiguration := Value;
end;

procedure TdlgSettings.SetiniUseFirewall(const Value: boolean);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniUseFirewall <> Value);
  FiniUseFirewall := Value;
end;

procedure TdlgSettings.SetiniUseFirewallAuthentication(const Value: boolean);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniUseFirewallAuthentication <> Value);
  FiniUseFirewallAuthentication := Value;
end;

procedure TdlgSettings.SetiniUseProxy(const Value: boolean);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniUseProxy <> Value);
  FiniUseProxy := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSettings.cboFirewallTypeChange(Sender: TObject);
var
  tf : boolean;
begin
  tf := chkUseFirewall.Checked and chkUseCustomConfiguration.Checked;

  lblFirewallUsername.Enabled := tf;
  reFirewallUsername.Enabled := tf;

  lblFirewallPassword.Enabled := tf;
  reFirewallPassword.Enabled := tf;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSettings.chkUseFirewallClick(Sender: TObject);
var
  tf : boolean;
begin
  tf := chkUseFirewall.Checked and chkUseCustomConfiguration.Checked;

  lblFirewallHost.Enabled := tf;
  reFirewallHost.Enabled := tf;

  lblFirewallPort.Enabled := tf;
  rnFirewallPort.Enabled := tf;

  lblFirewallType.Enabled := tf;
  cboFirewallType.Enabled := tf;

  chkUseFirewallAuthentication.Enabled := tf;
  chkUseFirewallAuthenticationClick (self);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSettings.SetiniUseWinINet(const Value: boolean);
begin
  FSettingsUpdated := FSettingsUpdated or (FiniUseWinINet <> Value);
  FiniUseWinINet := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSettings.chkUseWinINetClick(Sender: TObject);
begin
  if InitialisingForm then
     Exit;

  if chkUseCustomConfiguration.Checked
     and ( not chkUseWinINet.Checked)
     and ( cboProxyAuthMethod.ItemIndex = 2)
     and ( chkUseProxy.Checked)
  then
    if MessageDlg ( '"' + chkUseWinINet.Caption + '" ' +
                    'must normally be turned ON if you are using NTLM Proxy Authentication.'
                    + #13#13 +
                    'Are you sure you want to turn this OFF?',
                    mtInformation, [mbYes, mbNo], 0) = mrNo
    then
      chkUseWinINet.Checked := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSettings.cboProxyAuthMethodChange(Sender: TObject);
var
  tf : boolean;
  ans : integer;
begin
  tf := (cboProxyAuthMethod.ItemIndex > 0) and chkUseProxy.Checked and chkUseCustomConfiguration.Checked;

  lblProxyUserName.Enabled := tf;
  reProxyUserName.Enabled := tf;

  lblProxyPassword.Enabled := tf;
  reProxyPassword.Enabled := tf;

  if InitialisingForm then
     Exit;

  if tf and (cboProxyAuthMethod.ItemIndex = 2) and not chkUseWinINet.Checked then
    begin
      ans := MessageDlg( 'Using NTLM Authentication usually requires that "' + chkUseWinInet.Caption + '" ' +
                         'is turned ON.' +#13#13+
                         'Would you like to turn this ON now?',
                         mtInformation, mbYesNoCancel, 0);
      case ans of
        mrYes :
          chkUseWinINet.Checked := true;
        mrCancel :
          cboProxyAuthMethod.ItemIndex := iniProxyAuthMethod;
      end;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

