//*****************************************************************************
//
// Unit Name: formBConnect
// Date/Time: 27/09/2001 16:35:58
// Purpose  : Main form for processing BConnect Web Requests.
// Author   : Peter Speden
// History  : 27/09/2001  Version 2 Completed
//
// Remarks  : The BConnect form is shared between banklink 5 and smartbooks
//            As at Aug 2002 Smartbooks was still Delphi 5, therefore there
//            are a number of conditional compiles do do with commands from
//            unit filectrl.pas which is platform specific
//
//*****************************************************************************

//*****************************************************************************
// With the introduction of SSL v6 some things have changed..
// We are using the Delphi Ver DEFINes to check which is which
// assuming that Delphi 2005 and 2006 use SSL V6
// You can use anything else to turn SSLV6 on..
//*****************************************************************************

{$IFDEF VER170}  // Delphi 2005
  {$DEFINE SSLV6}
{$ENDIF}
{$IFDEF VER180}  // Delphi 2006
  {$DEFINE SSLV6}
{$ENDIF}
unit formBConnect;
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, SHDocVw, ComCtrls, ExtCtrls, ActnList, RzTreeVw, RzPanel,
  RzStatus, RzPrgres, AppEvnts, RzLabel, ImgList, RzAnimtr, RzLstBox, ipscore,
  ipshttps, jpeg
{$IFDEF SSLV6}
  ,bkXPThemes,
  OSFont
{$ENDIF}
   ;
const
  WM_KILLTIMER = WM_USER + 200;

type
  EBcServerError   = class( Exception);
  EBcPasswordError = class( EbcServerError);
  EBcOverdue       = class( EbcServerError);
  EBcInvalidUser   = class( EbcServerError);

  TBCStep = (bcsNONE, bcsLOGIN, bcsCHECKLAST, bcsDOWNLOAD, bcsLOGOUT,
    bcsCOMPLETE);

  TbcErrorDetail = class(TObject)
  private
    FServerErrorMessage: string;
    FServerErrorNo: integer;
    FErrorMessage: string;
    FErrorClass: string;
    FUserName: string;
    FOffsiteError : Boolean;
    procedure SetServerErrorMessage(const Value: string);
    procedure SetServerErrorNo(const Value: integer);
    function GetUserErrorMessage: string;
    procedure SetErrorClass(const Value: string);
    procedure SetErrorMessage(const Value: string);
  public
    constructor Create(AUserName: string; AServerErrorNo: integer;
      AServerErrorMessage: string; AEClassName: string; AEMessage: string;
      AOffsite : Boolean);
    property UserName: string read FUserName;
    property UserErrorMessage: string read GetUserErrorMessage;
    property ServerErrorMessage: string read FServerErrorMessage write
      SetServerErrorMessage;
    property ServerErrorNo: integer read FServerErrorNo write SetServerErrorNo;
    property ErrorClass: string read FErrorClass write SetErrorClass;
    property ErrorMessage: string read FErrorMessage write SetErrorMessage;
  end;

  TLogCallbackProc = procedure( S: string);

  TfrmBConnectHTTPS = class(TForm)
    pnlStatus: TRzStatusBar;
    pbProgress: TRzProgressBar;
    lblStatus: TRzStatusPane;
    imgSecure: TRzGlyphStatus;
    RzPanel1: TRzPanel;
    alstMainActions: TActionList;
    actConnect: TAction;
    actProcess: TAction;
    actClose: TAction;
    actSettings: TAction;
    actCancel: TAction;
    pnlMessages: TPanel;
    pnlInformation: TPanel;
    pnlError: TPanel;
    imgError: TImage;
    ilStep: TImageList;
    tmrProcess: TTimer;
    RzPanel2: TRzPanel;
    btnSettings: TButton;
    btnConnect: TButton;
    btnProcess: TButton;
    btnCancel: TButton;
    lblTransferredText: TLabel;
    lblTransferred: TLabel;
    lblFileNameText: TLabel;
    lblFileName: TLabel;
    lblElapsedTimeText: TLabel;
    lblElapsedTime: TLabel;
    Panel1: TPanel;
    tmrElapsed: TTimer;
    actShowLog: TAction;
    btnShowLog: TButton;
    HTTPClient: TipsHTTPS;
    Shape1: TShape;
    imgStep1: TRzAnimator;
    lblStep1: TLabel;
    imgStep2: TRzAnimator;
    lblStep2: TLabel;
    imgStep3: TRzAnimator;
    lblStep3: TLabel;
    imgStep4: TRzAnimator;
    lblStep4: TLabel;
    imgStep5: TRzAnimator;
    lblStep5: TLabel;
    pnlError2: TPanel;
    lblError: TLabel;
    lbErrors: TRzListBox;
    pnlBanner: TPanel;
    imgHeader: TImage;

    procedure actConnectExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCancelExecute(Sender: TObject);
    procedure actProcessExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrProcessTimer(Sender: TObject);
    procedure lbErrorsDblClick(Sender: TObject);
    procedure tmrElapsedTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actShowLogExecute(Sender: TObject);
    procedure HTTPClientTransfer(Sender: TObject; Direction,
      BytesTransferred: Integer; Text: String);
    procedure HTTPClientStartTransfer(Sender: TObject; Direction: Integer);
    procedure HTTPClientEndTransfer(Sender: TObject; Direction: Integer);
    procedure HTTPClientConnected(Sender: TObject; StatusCode: Integer;
      const Description: String);
    procedure HTTPClientDisconnected(Sender: TObject; StatusCode: Integer;
      const Description: String);
    procedure HTTPClientError(Sender: TObject; ErrorCode: Integer;
      const Description: String);
    procedure HTTPClientHeader(Sender: TObject; const Field,
      Value: String);
{$IFDEF SSLV6}
      procedure HTTPClientSSLServerAuthentication(Sender: TObject;
      CertEncoded: string; const CertSubject, CertIssuer, Status: string;
      var Accept: Boolean);

{$ELSE}

    procedure HTTPClientSSLServerAuthentication(Sender: TObject;
      CertHandle: Integer; const CertSubject, CertIssuer, Status: String;
      var Accept: Boolean);
{$ENDIF}
  private
    { Private declarations }
    sKey: string;
    FOnLogMessage : TLogCallbackProc;

    FLastStep: TBCStep;
    FLog : TStringList;
    FHeaders : TStringList;
    FStartTime: TDateTime;
    FProcessing: boolean;
    FCancel: boolean;
    FUsingPrimaryHost : boolean;

    FFileName: string;
    FFileSize: longint;
    FBytesReceived : integer;
    FFilenameSentByServer : string;
    FFilesToDownload : integer;

    FServerResponseMsg: string;
    FServerErrorNo: integer;
    FAccountIsOverdue : boolean;

    FVersionDescription: string;
    FStatsString : string;
    FFilesDownloaded: integer;
    FDownloadPath: string;
    FSettingsChanged: boolean;
    FUseProxy: boolean;
    FPasswordEncrypted: boolean;
    FUseFirewallAuthentication: boolean;
    FUseCustomConfiguration: boolean;
    FUseFirewall: boolean;
    FFirewallPort: integer;
    FTimeout: integer;
    FCountry: integer;
    FSecondaryPort: integer;
    FProxyAuthMethod: integer;
    FProxyPort: integer;
    FPrimaryPort: integer;
    FFirewallPassword: string;
    FFirewallUserName: string;
    FFirewallHost: string;
    FUserName: string;
    FPassword: string;
    FProxyPassword: string;
    FPrimaryHost: string;
    FSecondaryHost: string;
    FProxyHost: string;
    FProxyUserName: string;
    FLastFileID: string;
    FPreferredFileVersion : string;
    FFirewallType: TipshttpsFirewallTypes;
    FUseWinINet: boolean;
    FOffsite : Boolean;
    FManualAccountXML: string;
    FManualAccountInfoSent: Boolean;
    FUsageInfoSent: Boolean;
    FSendUsageData: Boolean;
    FHTTPMethod : string;

    procedure BlankStep(AStep: TBCStep);
    procedure CompleteStep(AStep: TBCStep);
    procedure ErrorStep(AStep: TBCStep);
    procedure ProcessStep(AStep: TBCStep);

    procedure ClearErrors;
    procedure IncrementFilesDownloaded;
    function RetrieveWinVer: string;
    function GetVInfo(AString: string): string;
    function GetFileSize( FileName: string ) : Int64;

    function GetBConnectServerPath: string;
    function GetCountryAsString: string;
    function GetFirewallTypeAsInt: integer;

    procedure SetError(const Value: TbcErrorDetail);
    procedure SetFilesDownloaded(const Value: integer);
    procedure SetProcessing(const Value: boolean);
    procedure SetStatus(AMsg: string);
    procedure SetBasicProxyAuthenticate;

    procedure InitialiseHTTPS;
    procedure InitialiseForm;

    procedure LogConfiguration;
    procedure Login;
    procedure InvalidPasswordDlg(AttemptCount: Integer);
    procedure GetFileList(AStringList: TStringList);
    procedure GetFile( RemoteFilename: string; LocalFilename : string);
    procedure LogMessageOnServer( s : string);
    procedure LogStatisticsToServer( s : string);
    procedure LogAccountInfoToServer( s : string);
    procedure LogUsageInfoToServer;
    procedure Logout;

    procedure LogMessage (s: string);
    procedure ExtractDetails;

    procedure DisplayConnected;
    procedure DisplayDisconnected;
  protected
    property Status: string write SetStatus;
    property Error: TbcErrorDetail write SetError;
    property BConnectServerPath: string read GetBConnectServerPath;
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
      AFirewallType : integer;
      UseFirewallAuthentication : boolean;
      AFirewallUserName : string;
      AFirewallPassword : string;
      ACaption : String;
      APicture : TPicture;
      AUserName : string;
      APassword : string;
      ACountry: integer;
      ALastFileID : string;
      IsPasswordEncrypted: boolean;
      AFileVersion : string;
      AOnLogMessage : TLogCallbackProc;
      ADownloadPath: string = '';
      AVersionDescription: string = '';
      AStatsString : string = '';
      AOffSite : Boolean = False;
      AManualAccountXML: string = '';
      SendUsageData: Boolean = False;
      HTTPMethod: string = 'https://'); reintroduce;

    property PrimaryHost: string read FPrimaryHost;
    property PrimaryPort: integer read FPrimaryPort;
    property SecondaryHost: string read FSecondaryHost;
    property SecondaryPort: integer read FSecondaryPort;
    property Timeout: integer read FTimeout;
    property UseCustomConfiguration: boolean read FUseCustomConfiguration;
    property UseWinINet: boolean read FUseWinINet;
    property UseProxy: boolean read FUseProxy;
    property ProxyHost: string read FProxyHost;
    property ProxyPort: integer read FProxyPort;
    property ProxyAuthMethod: integer read FProxyAuthMethod;
    property ProxyUserName: string read FProxyUserName;
    property ProxyPassword: string read FProxyPassword;
    property UseFirewall: boolean read FUseFirewall;
    property FirewallHost: string read FFirewallHost;
    property FirewallPort: integer read FFirewallPort;
    property FirewallType: TipshttpsFirewallTypes read FFirewallType;
    property UseFirewallAuthentication : boolean read FUseFirewallAuthentication;
    property FirewallUserName: string read FFirewallUserName;
    property FirewallPassword: string read FFirewallPassword;

    property LastFileID: string read FLastFileID;
    property FileVersion : string read FPreferredFileVersion;
    property UserName: string read FUserName;
    property Password: string read FPassword;
    property PasswordEncrypted: boolean read FPasswordEncrypted;
    property Country: integer read FCountry;
    property CountryAsString: string read GetCountryAsString;
    property FirewallTypeAsInt: integer read GetFirewallTypeAsInt;
    property SettingsChanged: boolean read FSettingsChanged;
    property FilesDownloaded: integer read FFilesDownloaded;
    property DownloadPath: string read FDownloadPath;
    property ManualAccountInfoSent: Boolean read FManualAccountInfoSent;
    property UsageInfoSent: Boolean read FUsageInfoSent;
  end;

const
{$IFDEF RAY}
  //Ray: On my machine using OmniSecure referencing the DLL doesn't work.
  //SHOULDN'T BE COMMITTED
  WebAppPath = '/bconnect/';
{$ELSE}
  WebAppPath = '/bconnect/bcWebServer.dll/';
{$ENDIF}



//******************************************************************************
implementation

{$IFDEF VER130}
  {$DEFINE BK_DELPHI5}
{$ENDIF}

uses
{$IFNDEF SmartBooks}
  BKHelp,
{$ENDIF}
{$IFDEF BK_DELPHI5}
   FileCtrl,
{$ELSEIF SSLV6}
   //FileCtrl,
{$IFEND}
   DlgSettings,
   formPassword,
   UsageUtils,
   bkBranding;

{$R *.DFM}

{ TfrmBConnect }

//******************************************************************************
// TfrmBConnect.Create
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AOwner: TComponent;                - Owner Component
//              APrimaryHost: string;              - Name or address of Primary Host   (eg. SECURE1.BANKLINK.CO.NZ)
//              ASecondaryHost: string;            - Name or address of Secondary Host (eg. SECURE2.BANKLINK.CO.NZ)
//              APrimaryPort: integer;             - Primary Port   (Can be 0 as will be set to the correct port on connect)
//              ASecondaryPort: integer;           - Secondary Port (Can be 0 as will be set to the correct port on connect)
//              ALastFileID: string;               - The last file system says was downloaded
//              AUserName: string;                 - Client Code as assigned by Banklink
//              APassword: string;                 - Password for Client Code
//              ACountry: integer;                 - Country that Client is in (0=NZ or 1=OZ or 2=UK)
//              IsPasswordEncrypted: boolean;      - Is the supplied password an MD5 string or plain text
//              UseProxy: boolean;                 - Are we connecting through a proxy
//              AProxyHost: string;                - Name or address of Proxy Host (Only applicable if Use Proxy)
//              AProxyPort: integer;               - Proxy Port (Only applicable if Use Proxy)
//              LoginToProxy: boolean;             - Do we have to log in to the proxy (Only applicable if Use Proxy)
//              AProxyUserName: string;            - Username for log in to the proxy (Only applicable if Login To Proxy)
//              AProxyPassword: string;            - Password for log in to the proxy (Only applicable if Login To Proxy)
//              UseSocks: boolean;                 - Use a SOCKS connection (Only applicable if Use Proxy)
//              ASocksVersion: integer;            - Version of SOCKS connection to use (Only applicable if Use Socks)
//              AFileVersion : string              - File version required '2' = BK 5.2 format file
//              ADownloadPath: string;             - [OPTIONAL] Path to place files in once downloaded (can be blank and will use Exe's Path)
//              AVersionDescription: string;       - [OPTIONAL] Description of Exe.  (Can be blank and will retrieve Version and ExeName for use here)
//              AStatsString : string              - [OPTIONAL] Stats info to be passed to server
//              UseSSL: boolean                    - [OPTIONAL] Whether to connect using SSL.  (Defaults to true)
//              ACaption : string;
//              APicture : TPicture;
//              AOffsite : Boolean;                - [OPTIONAL] Offsite client or not
//              AManualAccountXML : string;        - [OPTIONAL] Manual account info
//              SendUsageData : string;            - [OPTIONAL] Should we send usage data
//              HTTPMethod : string;               - [OPTIONAL] To use HTTP
// Result     : None
// Purpose    : Create the form and initialise variables.
//
//******************************************************************************

constructor TfrmBConnectHTTPS.Create(AOwner: TComponent;
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
      AFirewallType : integer;
      UseFirewallAuthentication : boolean;
      AFirewallUserName : string;
      AFirewallPassword : string;
      ACaption : string;
      APicture : TPicture;
      AUserName : string;
      APassword : string;
      ACountry: integer;
      ALastFileID : string;
      IsPasswordEncrypted: boolean;
      AFileVersion : string;
      AOnLogMessage : TLogCallbackProc;
      ADownloadPath: string;
      AVersionDescription: string;
      AStatsString : string;
      AOffSite : Boolean;
      AManualAccountXML : string;
      SendUsageData: Boolean;
      HTTPMethod: string);
begin
  inherited Create(AOwner);
{$IFDEF SmartBooks}
{$ELSE}
  BKHelpSetup(Self, BKH_BankLink_Connect_Security);
  bkXPThemes.ThemeForm( Self);
{$ENDIF}
  lblError.Font.Style := [fsBold];
  Caption := ACaption;
  imgHeader.Picture := APicture;
  RzPanel1.Color    := APicture.Bitmap.TransparentColor;

  bkBranding.StyleBConnectBannerPanel(pnlBanner);
  bkBranding.StyleBConnectBannerImage(imgHeader); 

  FLog := TStringList.Create;
  FHeaders := TStringList.Create;
  SetProcessing(false);

  //Set the normal variables
  FUserName := AUserName;
  FPassword := APassword;
  FCountry := ACountry;
  FLastFileID := ALastFileID;
  FPasswordEncrypted := IsPasswordEncrypted;
  FDownloadPath := '';
  if Trim(ADownloadPath) <> '' then
  begin
    FDownloadPath := IncludeTrailingPathDelimiter(Trim(ADownloadPath));
  end;
  if Trim(AVersionDescription) <> '' then
    FVersionDescription := Trim(AVersionDescription)
  else
    FVersionDescription := ExtractFileName(Application.EXEName) + ' ' +
      GetVInfo('FileVersion');

  FStatsString          := AStatsString;
  FOnLogMessage         := AOnLogMessage;
  FPreferredFileVersion := AFileVersion;
  FManualAccountXML     := AManualAccountXML;
  FManualAccountInfoSent:= False;
  FSendUsageData := SendUsageData;
  FUsageInfoSent := False;
  //Set the configuration
  FPrimaryHost := APrimaryHost;
  FPrimaryPort := APrimaryPort;
  FSecondaryHost := ASecondaryHost;
  FSecondaryPort := ASecondaryPort;
  FTimeout := ATimeout;
  FUseCustomConfiguration := UseCustomConfiguration;
  FUseWinINet := UseWinINet;
  FUseProxy := UseProxy;
  FProxyHost := AProxyHost;
  FProxyPort := AProxyPort;
  FProxyAuthMethod := AProxyAuthMethod;
  FProxyUserName := AProxyUserName;
  FProxyPassword := AProxyPassword;
  FUseFirewall := UseFirewall;
  FFirewallHost := AFirewallHost;
  FFirewallPort := AFirewallPort;
  try
    FFirewallType := TipshttpsFirewallTypes(AFirewallType);
  except
    FFirewallType := TipshttpsFirewallTypes(0);
  end;
  FUseFirewallAuthentication := UseFirewallAuthentication;
  FFirewallUserName := AFirewallUserName;
  FFirewallPassword := AFirewallPassword;
  FOffsite := AOffsite;
  FHTTPMethod := HTTPMethod;

  InitialiseForm;

  if (Trim(FDownloadPath) <> '') and not (DirectoryExists(FDownloadPath)) then
    begin
      Error := TbcErrorDetail.Create(FUserName, 0,
        Format('Directory specified for Download (%s) does not exist.  Will use the current application directory instead (%s).', [FDownloadPath, ExtractFilePath(Application.ExeName)]), '',
        Format('Directory specified for Download (%s) does not exist.  Will use the current application directory instead (%s).', [FDownloadPath, ExtractFilePath(Application.ExeName)]),
        FOffsite);
      FDownloadPath := '';
    end;
end;

//******************************************************************************
// TfrmBConnect.actConnectExecute
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Main Processing loop.  Main process flows through here
//
//******************************************************************************

procedure TfrmBConnectHTTPS.actConnectExecute(Sender: TObject);

   function HandleLogonException( ErrorCode : integer; ExceptionMessage : string; ErrorClass : string) : Boolean;
   //returns true if the error was handled correctly
   begin
     result := false;

     if FUsingPrimaryHost then begin
       Error := TbcErrorDetail.Create( FUserName, ErrorCode,
                                       'Unable to contact Primary Host (' + FPrimaryHost + ')',
                                       ErrorClass,
                                       ExceptionMessage,
                                       FOffsite);
     end
     else begin
       Error := TbcErrorDetail.Create( FUserName, ErrorCode,
                                       'Unable to contact Secondary Host (' + FSecondaryHost + ')',
                                       ErrorClass,
                                       ExceptionMessage,
                                       FOffsite);
     end;

     //try the secondary host
     if FUsingPrimaryHost then begin
        if ( FSecondaryHost <> '') then begin
           //HttpClient.Action := httpIdle;
           FUsingPrimaryHost := false;
           result            := true;
        end
        else begin
           //no secondary host specified
           ErrorStep( bcsLOGIN);
       end;
     end
     else begin
        //error occured trying secondary host, raise silent exception
        ErrorStep(bcsLOGIN);
     end;
   end;

   procedure HandleException( ErrorCode : integer; ErrorMessage : string;
                              ExceptionMessage : string; ErrorClass : string);
   begin
      Error := TbcErrorDetail.Create( FUserName, ErrorCode,
                                      ErrorMessage,
                                      ErrorClass,
                                      ExceptionMessage,
                                      FOffsite);
      ErrorStep(FLastStep);
   end;

var
  Files         : TStringList;
  x             : integer;
  Success       : boolean;
  CancelPressedBeforeLogout : boolean;
  LocalFilename : string;
  LocalFilesize : Int64;

  RemoteFilename : string;

  aMsg          : string;
begin
  //make sure the user has entered a password
  if (FPassword = '') then
  begin
    //password has not been set
    try
      InvalidPasswordDlg( 0);
    except
      on E : Exception do begin
        Error := TbcErrorDetail.Create( FUserName, 0, 'User did not enter a password',
                                        E.ClassName,
                                        E.Message,
                                        FOffsite);
        Exit;
      end;
    end;
  end;

  SetProcessing(True);
  Success              := false;
  FLastStep            := bcsLOGIN;
  tmrElapsed.Enabled   := true;

  try //finally
    InitialiseForm;
    try
      InitialiseHTTPS;
    except
      On E : Exception do begin
        Error := TbcErrorDetail.Create( FUserName, 0,
                                        'Error during initialisation',
                                        E.ClassName,
                                        E.Message,
                                        FOffsite);
        Exit;
      end;
    end;
    LogConfiguration;

    LogMessage( 'CONNECTING');
    if fUseWinInet then
      DisplayConnected;

    //clear the overdue flag
    FAccountIsOverdue := false;

    //Attempt to login, try primary host first, then use secondary host
    while TRUE do begin
      //loop until break, or abort from exception handler
      try
         //------------------------------------------------
         Login;
         //------------------------------------------------
         break;
      except
         on E : EBcPasswordError do begin //re-raise the exception
            HandleException( FServerErrorNo, FServerResponseMsg, E.Message, E.ClassName);
            Exit;
         end;

         on E : EBcInvalidUser do begin //re-raise the exception
            HandleException( FServerErrorNo, FServerResponseMsg, E.Message, E.ClassName);
            Exit;
         end;

         on E : EIpsHTTPS do begin
           if not HandleLogonException( -E.Code, E.Message, E.ClassName) then
              Exit;
         end;

         on E: Exception do begin
           if FCancel then begin
             HandleException( 0, '', E.Message, E.ClassName);
             Exit;
           end;
           //Handle all other login exceptions
           if not HandleLogonException( FServerErrorNo, E.Message, E.ClassName) then
              Exit;
         end;
      end; //except
    end;

    //Login was succesful, now download file list and files, always try to
    //log out whatever happens

    try //finally log out
       try
         //Log Statistics
         LogStatisticsToServer( FStatsString);
         // Log manual account info
         LogAccountInfoToServer( FManualAccountXML);
         // Log usage info, if allowed to
         if FSendUsageData then
          LogUsageInfoToServer;
       except
         //dont inform the user of any problems with this. We dont want the
         //post data information to be seen
         On E : Exception do
           ;
       end;

       try
          //make sure the user is not overdue
          if FAccountIsOverdue
            then raise EBcOverdue.Create( 'Account is overdue');

          Files := TStringList.Create;
          try
            FLastStep := bcsCHECKLAST;
            ProcessStep(bcsCHECKLAST);
            //------------------------------------------------
            GetFileList(Files);
            //------------------------------------------------
            CompleteStep(bcsCHECKLAST);

            FFilesToDownload := Files.Count;
            if FFilesToDownload > 0 then
              begin
                lblTransferred.Caption := '0 of ' + IntToStr( FFilesToDownload);

                FLastStep := bcsDOWNLOAD;
                ProcessStep(bcsDOWNLOAD);
                //------------------------------------------------
                {$IFDEF SmartBooks}
                //SmartBooks is configured to only download 1 file at a time
                //and relies on the server providing the files in the correct
                //order
                begin
                  x := 0;  //download the first file

                {$ELSE}
                //BK5 downloads all files that are available
                for x := 0 to FFilesToDownload - 1 do begin
                {$ENDIF}
                  //construct file name
                  if FDownloadPath <> '' then
                  begin
                    RemoteFilename := Files[x];
                    LocalFilename := IncludeTrailingPathDelimiter(FDownloadPath) + RemoteFilename
                  end
                  else
                    LocalFilename := RemoteFilename;

                  //make sure no previous copy of file exists
                  if FileExists( LocalFilename) then begin
                     LogMessage( 'Previous copy of ' + LocalFilename + ' found');
                     if not DeleteFile( LocalFilename) then
                        LogMessage('Delete of ' + LocalFilename + ' failed');
                  end;

                  // - - - - - - - - - - - - - - - - - - - - - - - -
                  //retrieve file(s)
                  GetFile( RemoteFilename, LocalFilename);
                  // - - - - - - - - - - - - - - - - - - - - - - - -

                  //log a message on the server when file has been successfully
                  //retrieved and is the correct size
                  if FileExists( LocalFilename) then begin
                     LocalFileSize := GetFileSize( LocalFilename);
                     if LocalFileSize = FFileSize then begin
                        aMsg := 'Confirmed receipt of ' + Files[ x];
                        LogMessageOnServer( aMsg);
                     end
                     else begin
                        aMsg := 'Local file size error ' + Files[ x] +
                                ' ' + inttostr( LocalFileSize) +
                                ' of ' + inttostr( FFileSize) +
                                ' bytes';
                        Raise Exception.Create( aMsg);
                     end;
                  end
                  else begin
                     //no file exists
                     raise Exception.Create( 'Local file not found ' + Files[ x]);
                  end;
                end;
                //------------------------------------------------
                CompleteStep(bcsDOWNLOAD);
              end;
          finally
            FreeAndNil(Files);
          end;

       except //handle any exceptions that occur during retreiving file list or file
          on E: EIpsHTTPS do begin
             HandleException( -E.Code, 'Transferred ' + inttostr( FBytesReceived) + ' of ' + inttostr( FFileSize), E.Message, E.ClassName);
             Exit;
          end;

          on E: Exception do begin
             HandleException( FServerErrorNo, FServerResponseMsg, E.Message, E.ClassName);
             Exit;
          end;
       end;

      FLastStep := bcsLOGOUT;
    finally
      try
         //Cancel may have been pressed prior to log out, allow log out to proceed
         //so that session is not left open on server
         CancelPressedBeforeLogout := FCancel;

         //Clear error info so that will only raise error if log out fails
         FCancel := false;
         FServerErrorNo := 0;
         FServerResponseMsg := '';
         //------------------------------------------------
         if CancelPressedBeforeLogout then
           LogMessageOnServer( 'User cancelled download');

         Logout;
         //------------------------------------------------
         if CancelPressedBeforeLogout then
            raise Exception.Create( 'Download Cancelled');
      except
          on E: EIpsHTTPS do begin
             HandleException( -E.Code, '', E.Message, E.ClassName);
             Abort;
          end;

          on E: Exception do begin
             HandleException( FServerErrorNo, FServerResponseMsg, E.Message, E.ClassName);
             Abort;
          end;
       end;
    end;

    CompleteStep(bcsCOMPLETE);
    Success := true;

  finally
    tmrElapsed.Enabled := false;
    tmrProcess.Enabled := false;
    SetProcessing(False);

    if fUseWinInet then
      DisplayDisconnected;
  end;

  if (Sender <> nil) // Dont Prompt when Auto
  and Success then begin
       if (FilesDownloaded = 0) then
          MessageDlg('There are no additional files to download.',mtInformation, [mbOk], 0)
       else if FilesDownloaded > 0 then begin
          MessageDlg(Format ('Download complete!'#13#13'%d file(s) downloaded.', [FilesDownloaded]),
               mtInformation, [mbOk], 0);
        Close;
      end;
  end;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.actCloseExecute(Sender: TObject);
begin
  //HTTPClient.Action := httpIdle;

  //Set the files downloaded to -1 so that auto process in not called in BankLink 5
  SetFilesDownloaded(-1);

  Close;
end;

//******************************************************************************
// TfrmBConnect.actSettingsExecute
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Load up the settings screen
//
//******************************************************************************

procedure TfrmBConnectHTTPS.actSettingsExecute(Sender: TObject);
begin
  with TdlgSettings.Create(Application,
    PrimaryHost,
    PrimaryPort,
    SecondaryHost,
    SecondaryPort,
    Timeout,
    UseCustomConfiguration,
    UseWinINet,
    UseProxy,
    ProxyHost,
    ProxyPort,
    ProxyAuthMethod,
    ProxyUserName,
    ProxyPassword,
    UseFirewall,
    FirewallHost,
    FirewallPort,
    FirewallType,
    UseFirewallAuthentication,
    FirewallUserName,
    FirewallPassword) do
    begin
      try
        ShowModal;
        if SettingsUpdated then
          begin
            FPrimaryHost                 := iniPrimaryHost;
            FPrimaryPort                 := iniPrimaryPort;
            FSecondaryHost               := iniSecondaryHost;
            FSecondaryPort               := iniSecondaryPort;
            FTimeout                     := iniTimeout;
            FUseCustomConfiguration      := iniUseCustomConfiguration;
            FUseWinINet                  := iniUseWinINet;
            FUseProxy                    := iniUseProxy;
            FProxyHost                   := iniProxyHost;
            FProxyPort                   := iniProxyPort;
            FProxyAuthMethod             := iniProxyAuthMethod;
            FProxyUserName               := iniProxyUserName;
            FProxyPassword               := iniProxyPassword;
            FUseFirewall                 := iniUseFirewall;
            FFirewallHost                := iniFirewallHost;
            FFirewallPort                := iniFirewallPort;
            FFirewallType                := iniFirewallType;
            FUseFirewallAuthentication   := iniUseFirewallAuthentication;
            FFirewallUserName            := iniFirewallUserName;
            FFirewallPassword            := iniFirewallPassword;

            FSettingsChanged             := SettingsUpdated;
          end;
      finally
        Free;
      end;
    end;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FProcessing then
    CanClose := False or FCancel
  else
    begin
      CanClose := True;
      //HTTPClient.Action := httpIdle;
    end;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.actCancelExecute(Sender: TObject);
begin
  FCancel := true;
  Screen.Cursor := crAppStart;
  LogMessage ('Cancel Pressed');
  //HTTPClient.Action  := httpIdle;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.actProcessExecute(Sender: TObject);
begin
  //HTTPClient.Action := httpIdle;
  Close;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClearErrors;
//FLog.SaveToFile( (ChangeFileExt ( 'Application.ExeName, '.LOG'));
end;

//******************************************************************************
// TfrmBConnect.tmrProcessTimer
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Flick the buttons from green to grey until finished.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.tmrProcessTimer(Sender: TObject);
var
  A: TRzAnimator;
begin
  if tmrProcess.Tag > 0 then
    begin
      A := TRzAnimator(FindComponent(Format('imgStep%d', [tmrProcess.Tag])));
      if A <> nil then
        begin
          A.Animate := false;
          if A.ImageIndex = 0 then
            A.ImageIndex := 1
          else
            A.ImageIndex := 0;
        end;
    end;
end;

//******************************************************************************
// TfrmBConnect.lbErrorsDblClick
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Display the selected Error Message
//
//******************************************************************************

procedure TfrmBConnectHTTPS.lbErrorsDblClick(Sender: TObject);
var
  err: TbcErrorDetail;
begin
  err := nil;
  if (lbErrors.ItemIndex >= 0) and (lbErrors.ItemIndex < lbErrors.Count) then
    err := TbcErrorDetail(lbErrors.Items.Objects[lbErrors.ItemIndex]);
  if err <> nil then
    ShowMessage(Format('User Error Message: %s' + #13 +
      'Server Error No: %d' + #13 +
      'Server Error Message: %s' + #13 +
      'Error Class: %s' + #13 +
      'Error Message: %s'
      ,
      [err.UserErrorMessage,
      err.ServerErrorNo,
        err.ServerErrorMessage,
        err.ErrorClass,
        err.ErrorMessage]));
end;

//******************************************************************************
// TfrmBConnect.tmrElapsedTimer
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Sender: TObject
// Result     : None
// Purpose    : Update the Elapsed Time field to show activity
//
//******************************************************************************

procedure TfrmBConnectHTTPS.tmrElapsedTimer(Sender: TObject);
begin
  lblElapsedTime.Caption := FormatDateTime('HH:NN:SS', Now - FStartTime);
end;

//******************************************************************************
// TfrmBConnect.BlankStep
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AStep: TBCStep
// Result     : None
// Purpose    : Sets the Specified step button to Grey
//
//******************************************************************************

procedure TfrmBConnectHTTPS.BlankStep(AStep: TBCStep);
var
  A: TRzAnimator;
begin
  tmrProcess.Enabled := False;
  A := TRzAnimator(FindComponent(Format('imgStep%d', [Ord(AStep)])));
  if A <> nil then
    begin
      A.Animate := false;
      A.ImageList := ilStep;
      A.ImageIndex := 0;
      A.Tag := 0;
    end;
end;

//******************************************************************************
// TfrmBConnect.CompleteStep
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AStep: TBCStep
// Result     : None
// Purpose    : Sets the Specified step button to Green
//
//******************************************************************************

procedure TfrmBConnectHTTPS.CompleteStep(AStep: TBCStep);
var
  A: TRzAnimator;
  L: TLabel;
begin
  tmrProcess.Enabled := False;
  A := TRzAnimator(FindComponent(Format('imgStep%d', [Ord(AStep)])));
  L := TLabel(FindComponent(Format('lblStep%d', [Ord(AStep)])));
  if L <> nil then
    LogMessage (Format ('Completing Step %d, %s', [Ord (AStep), L.Caption]));
  if A <> nil then
    begin
      A.ImageIndex := 1;
      A.Tag := 2;
    end;
end;

//******************************************************************************
// TfrmBConnect.ErrorStep
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AStep: TBCStep
// Result     : None
// Purpose    : Sets the Specified step button to Red
//
//******************************************************************************

procedure TfrmBConnectHTTPS.ErrorStep(AStep: TBCStep);
var
  A: TRzAnimator;
  x: integer;
begin
  tmrProcess.Enabled := False;
  for x := Ord(AStep) to 5 do
    begin
      A := TRzAnimator(FindComponent(Format('imgStep%d', [x])));
      if A <> nil then
        begin
          A.ImageIndex := 2;
          A.Tag := 3;
        end;
    end;
end;

//******************************************************************************
// TfrmBConnect.ProcessStep
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AStep: TBCStep
// Result     : None
// Purpose    : Sets the Process timer to work on the current step
//
//******************************************************************************

procedure TfrmBConnectHTTPS.ProcessStep(AStep: TBCStep);
var
  A: TRzAnimator;
  L: TLabel;
begin
  A := TRzAnimator(FindComponent(Format('imgStep%d', [Ord(AStep)])));
  L := TLabel(FindComponent(Format('lblStep%d', [Ord(AStep)])));
  if L <> nil then
    LogMessage (Format ('Processing Step %d, %s', [Ord (AStep), L.Caption]));
  if A <> nil then
    begin
      A.Tag := 1;
      tmrProcess.Tag := Ord(AStep);
    end;
  tmrProcess.Enabled := True;
end;

//******************************************************************************
// TfrmBConnect.ClearErrors
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : None
// Purpose    : Because the errors are objects that are stored in the Objects
//              array of the lbErrors (listbox) we need to free them before
//              clearing the list or we will have a memory leak.  This routine
//              frees the Error Objects and then clears the list.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.ClearErrors;
var
  x: integer;
  err: TbcErrorDetail;
begin
  for x := 0 to lbErrors.Count - 1 do
    if Assigned(lbErrors.Items.Objects[x]) then
      begin
        err := TbcErrorDetail(lbErrors.Items.Objects[x]);
        lbErrors.Items.Objects[x] := nil;
        FreeAndNil(err);
      end;
  lbErrors.Clear;
end;

//******************************************************************************
// TfrmBConnect.ExtractDetails
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : Response: TIdResponseHeaderInfo
// Result     : None
// Purpose    : Extracts the generic information from the Response from the
//              BConnect Web Server
//
//******************************************************************************

procedure TfrmBConnectHTTPS.ExtractDetails;
begin
  FServerResponseMsg :=
    FHeaders.Values['serverresponse'];
  FServerErrorNo :=
    StrToIntDef(FHeaders.Values['errorno'], 0);

  if FCancel then
    raise EbcServerError.Create('User Cancelled Request');

  if FServerErrorNo = 2000 then
  begin
    //catch an overdue error, this should only occur during login
    //we want the login process to complete, however the software should
    //logout after that
    if not FAccountIsOverdue then
    begin
       FAccountIsOverdue := true;
       Exit;
    end;
  end;

  if FServerErrorNo <> 0 then
    raise EbcServerError.CreateFmt('Server returned an error: (%d) %s',
      [FServerErrorNo,
      FServerResponseMsg])
end;

//******************************************************************************
// TfrmBConnect.IncrementFilesDownloaded
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : None
// Purpose    : Increment the number of files downloaded
//
//******************************************************************************

procedure TfrmBConnectHTTPS.IncrementFilesDownloaded;
begin
  Inc(FFilesDownloaded);
  lblTransferred.Caption := IntToStr(FFilesDownloaded) + ' of ' + IntToStr( FFilesToDownload);
end;

//******************************************************************************
// TfrmBConnect.RetrieveWinVer
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : string
// Purpose    : Retrieve a string description of the current windows version
//
//******************************************************************************
function TfrmBConnectHTTPS.RetrieveWinVer: string;
type
  { Variant record used to help decipher the long integer containing
    the build number, returned by the GetVersionEx routine in the
    OSVERSIONINFO record }
  TBuildNumber = record
    case Byte of
      0: (VersionInfo: Longint);
      1: (BuildNumber: Word; MinorNumber: Byte; MajorNumber: Byte);
  end;

var
  OSVersionInfo32: OSVERSIONINFO;
  name: string;
begin
  Result := '';

  OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
  GetVersionEx(OSVersionInfo32);

  case OSVersionInfo32.dwPlatformId of
    VER_PLATFORM_WIN32s:
      with OSVersionInfo32 do
        begin
          Name := 'Windows 3.xx (WIN32)';
          Result := Format('%s %d.%.2d.%d%s',
            [Name, dwMajorVersion, dwMinorVersion,
            TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion])
        end;
    VER_PLATFORM_WIN32_WINDOWS: { Windows 95/98 }
      with OSVersionInfo32 do
        begin
          if dwMajorVersion = 4 then
            begin
              if (dwMinorVersion < 10) then
                { Windows 95 }
                Name := 'Windows 95'
              else
                if (dwMinorVersion < 90) then
                  { Windows 98 }
                  Name := 'Windows 98'
                else
                  { Windows ME }
                  Name := 'Windows ME';
            end
          else
            Name := 'Windows 9x (Unknown)';

          Result := Format('%s %d.%.2d.%d%s',
            [Name, dwMajorVersion, dwMinorVersion,
            TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion])
        end; { end with }
    VER_PLATFORM_WIN32_NT: { Windows NT }
      with OSVersionInfo32 do
        begin
          if (dwMajorVersion < 4) then
            { Windows NT 3.5x }
            Name := 'Windows NT 3.5x'
          else
            if (dwMajorVersion < 5) then
              { Windows NT 4 }
              Name := 'Windows NT 4'
            else
              { Windows 2000 }
              if dwMinorVersion = 0 then
                Name := 'Windows 2000'
              else
                Name := 'Windows XP';
          Result := Format('%s %d.%.2d.%d %s', [name, dwMajorVersion,
            dwMinorVersion, TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion]);
        end;
  end; { end case }

end;
//******************************************************************************
// TfrmBConnect.GetVInfo
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AString: string
// Result     : string
// Purpose    : Retrieve a section from the version information included in the
//              Executable
//
//******************************************************************************

function TfrmBConnectHTTPS.GetVInfo(AString: string): string;
var
  Size: DWORD;
  Dummy: DWORD;
  pVerRes: Pointer;
  pTransTab: Pointer;
  strCSet: string;
  Buf: Pointer;
begin
  Size := GetFileVersionInfoSize(PChar(Application.EXEName), Dummy);
  if Size > 0 then
    begin
      GetMem(pVerRes, Size);
      try
        if GetFileVersionInfo(PChar(Application.EXEName), 0, Size, pVerRes) then
          begin
            VerQueryValue(pVerRes, '\\VarFileInfo\\Translation', pTransTab,
              Size);
            strCSet := '\\StringFileInfo\\' +
              IntToHex(LoWord(Longint(pTransTab^)), 4) +
              IntToHex(HiWord(Longint(pTransTab^)), 4) + '\\';
            if VerQueryValue(pVerRes, PChar(strCSet + AString), Buf, Size) then
              Result := StrPas(PChar(Buf))
            else
              Result := AString + ' N/A';
          end
        else
          Result := 'Unknown';
      finally
        FreeMem(pVerRes, Size);
      end;
    end
  else
    Result := 'Unknown';
end;

//******************************************************************************
// TfrmBConnect.GetBConnectServerPath
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : string
// Purpose    : Sets the Server path information.
//
//******************************************************************************

function TfrmBConnectHTTPS.GetBConnectServerPath: string;
var
  AHost: string;
  APort: integer;
begin
  if FUsingPrimaryHost then begin
    AHost := PrimaryHost;
    APort := PrimaryPort;
  end
  else begin
    AHost := SecondaryHost;
    APort := SecondaryPort;
  end;

  if AHost = '' then
    Abort;

  if APort <> 0 then
    Result := Format('%s%s:%d%s', [FHTTPMethod, AHost, APort, WebAppPath])
  else
    Result := Format('%s%s%s', [FHTTPMethod, AHost, WebAppPath]);
end;

//******************************************************************************

function TfrmBConnectHTTPS.GetCountryAsString: string;
begin
  case FCountry of
    0: Result := 'NZ';
    1: Result := 'OZ';
    2: Result := 'UK';
  end;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.SetError(const Value: TbcErrorDetail);
begin
  lbErrors.Items.AddObject(Value.UserErrorMessage, Value);
  LogMessage( 'ERROR: ' + Value.UserErrorMessage + ' - ' +
                          Value.FServerErrorMessage + ' [' +
                          Value.FErrorClass + ']');
  pnlError.Visible := true;
  Application.ProcessMessages;
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.SetFilesDownloaded(const Value: integer);
begin
  if FFilesDownloaded <> Value then
    begin
      FFilesDownloaded := Value;
      lblTransferred.Caption := IntToStr(FFilesDownloaded) + ' of ' + IntToStr( FFilesToDownload);
    end;
end;

//******************************************************************************
// TfrmBConnect.SetProcessing
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : const Value: boolean
// Result     : None
// Purpose    : Sets the Processing Flag so that we know we are processing and
//              disables actions so the user cannot hit the Process button while
//              getting files.  Also triggers the final disconnect when finished
//              processing
//
//******************************************************************************

procedure TfrmBConnectHTTPS.SetProcessing(const Value: boolean);
begin
  FStartTime := Now;
  FProcessing := Value;
  FCancel := false;
  actSettings.Enabled := not FProcessing;
  actProcess.Enabled := not FProcessing;
  actConnect.Enabled := not FProcessing;
  actShowLog.Enabled := not FProcessing;
  if not FProcessing then
    btnCancel.Action := actClose
  else
    btnCancel.Action := actCancel;
         {
  if not FProcessing then
    HTTPClient.Action := httpIdle;
        }
end;

//******************************************************************************

procedure TfrmBConnectHTTPS.SetStatus(AMsg: string);
begin
  lblStatus.Caption := AMsg;
  Application.ProcessMessages;
end;

//******************************************************************************
// TfrmBConnect.InitialiseHTTPS
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : None
// Purpose    : Initialises all the variables so that the downloads can proceed.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.InitialiseHTTPS;
const
   PROTOCOL_TLS1       = $C0;
   PROTOCOL_SSL3       = $30;
   IGNORE_CN_ERROR     = $80000000;
begin
  LogMessage( 'INITIALISING');

  httpClient.Timeout := Timeout;
  httpClient.ProxyServer := '';
  httpClient.ProxyPort := 0;
  httpClient.ProxyUser := '';
  httpClient.ProxyPassword := '';

  httpClient.FirewallUser := '';
  httpClient.FirewallPassword := '';
  httpClient.FirewallHost := '';
  httpClient.FirewallPort := 0;
  httpClient.FirewallType := fwNone;

  {$IFDEF SSLV6}

  if not  (not FUseCustomConfiguration
           or (FUseCustomConfiguration and FUseWinINet)
         ) then  httpClient.Config('useWinInet=False')
  else  httpClient.Config('useWinInet=True');

  httpClient.Config (Format( 'UserAgent=BConnect/2.1 (%s, %s)',
                                  [ FVersionDescription,
                                    RetrieveWinVer]));

   httpClient.Config ('SSLSecurityFlags=0x80000000');
   httpClient.Config ('SSLEnabledProtocols=140');
  {$ELSE}
    httpClient.UseWinInet := not  (not FUseCustomConfiguration
           or (FUseCustomConfiguration and FUseWinINet));

    httpClient.UserAgent := Format( 'BConnect/2.1 (%s, %s)',
                                  [ FVersionDescription,
                                    RetrieveWinVer]);

     //Ignore non-matching CN (certificate CN not-matching server name)
     //This may occur if DNS is not being used and client has specified IP address
     {$WARNINGS OFF}
     httpClient.SSLSecurityFlags    := IGNORE_CN_ERROR;
     {$WARNINGS ON}
     httpClient.SSLEnabledProtocols := PROTOCOL_TLS1 or PROTOCOL_SSL3;


  {$ENDIF}


  if FUseCustomConfiguration then begin
      if FUseProxy then
        begin
          httpClient.ProxyServer   := FProxyHost;
          httpClient.ProxyPort     := FProxyPort;
          case FProxyAuthMethod of
            1 :  SetBasicProxyAuthenticate;
            2 :  httpClient.ProxyServer := Format ('*%s*%s', [FProxyUsername, FProxyPassword]);
          end;
          httpClient.ProxyUser     := FProxyUserName;
          httpClient.ProxyPassword := FProxyPassword;
        end;

      if FUseFirewall then
        begin
          httpClient.FirewallHost := FFirewallHost;
          httpClient.FirewallPort := FProxyPort;
          httpClient.FirewallType := FFirewallType;
          if FUseFirewallAuthentication then
            begin
              httpClient.FirewallUser     := FFirewallUserName;
              httpClient.FirewallPassword := FFirewallPassword;
            end;
        end;
  end;
end;

//******************************************************************************
// TfrmBConnect.InitialiseForm
//
// Date       : 30/11/2001
// Author     : Matthew Hopkins
// Arguments  : None
// Result     : None
// Purpose    : Initialises the form, clear log and error lists, set lights
//
//******************************************************************************
procedure TfrmBConnectHTTPS.InitialiseForm;
var
  x: integer;
begin
  DisplayDisconnected;
  Status := 'Ready';

  FLog.Clear;
  FHeaders.Clear;
  FLastStep := bcsLogin;

  lblFileName.Caption := '';
  lblTransferred.Caption := '';
  lblElapsedTime.Caption := '';
  FUsingPrimaryHost  := true;  //use the primary host first
  tmrProcess.Enabled := false;
  tmrProcess.Tag := -1;

  FFilesToDownload := 0;
  SetFilesDownloaded(0);
  FFileName := '';

  for x := 0 to 5 do
    BlankStep(TBCStep(x));

  ClearErrors;
  pnlError.Visible := false;
end;

//******************************************************************************
// TfrmBConnect.LogConfiguration
//
// Date       : 30/11/2001
// Author     : Matthew Hopkins
// Arguments  : None
// Result     : None
// Purpose    : Logs the current setup.
//
//******************************************************************************
procedure TfrmBConnectHTTPS.LogConfiguration;
begin
  LogMessage( Format( 'Primary Host = %s', [ FPrimaryHost]));
  LogMessage( Format( 'Primary Port = %d', [ FPrimaryPort]));
  LogMessage( Format( 'Secondary Host = %s', [ FSecondaryHost]));
  LogMessage( Format( 'Secondary Port = %d', [ FSecondaryPort]));
  LogMessage( 'Timeout = ' + inttostr( FTimeout));

  if FUseCustomConfiguration then begin
      LogMessage ('Using Custom Settings');
      if FUseProxy then
        begin
          LogMessage (Format ('Proxy Host = %s', [FProxyHost]));
          LogMessage (Format ('Proxy Port = %d', [FProxyPort]));
          case FProxyAuthMethod of
            1 : begin
                LogMessage ('Using Basic Authentication for Proxy');
            end;
            2 : begin
                LogMessage ('Using NTLM Authentication for Proxy');
           end;
          end;
        end;

      if FUseFirewall then
        begin
          LogMessage (Format ('Firewall Host = %s', [FFirewallHost]));
          LogMessage (Format ('Firewall Port = %d', [FFirewallPort]));
          LogMessage (Format ('Firewall Type = %d', [Ord (FFirewallType)]));
          if FUseFirewallAuthentication then
              LogMessage ('Firewall authentication required');
        end;
  end;

  if not FUseCustomConfiguration or (FUseCustomConfiguration and FUseWinINet) then
    LogMessage ('WinInet is ON');
end;

//******************************************************************************
// TfrmBConnect.Login
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : None
// Purpose    : Sends a login instruction to the BConnect Web Server.  Expects
//              back a Session Key.  If the Server has an error this is reported
//              and logged.  Three attempts will be made in the case of the
//              error being an incorrect password.  The user will be prompted
//              for a plain text password each time.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.Login;
var
  PostData: TStringList;
  AttemptCount: integer;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    ProcessStep(bcsLOGIN);
    AttemptCount := 0;
    while AttemptCount < 3 do
    begin
      try
        if FCancel then
          raise Exception.Create('User Cancelled Request');

        Inc(AttemptCount);
        PostData := TStringList.Create;
        try
          PostData.Add('user=' + FUsername);
          PostData.Add('pwd=' + FPassword);
          PostData.Add('country=' + CountryAsString);
          if PasswordEncrypted then
            PostData.Add('encrypted=Y');
          try
            FHeaders.Clear;
            httpClient.ResetHeaders;
            httpClient.PostData := PostData.Text;
            httpClient.URL := BConnectServerPath + 'login';
            SetBasicProxyAuthenticate;
            {$IFDEF SSLV6}
            httpClient.Post(httpClient.URL);
            {$ELSE}
            httpClient.Action := httpPost;
            {$ENDIF}
          finally
            {$IFNDEF SSLV6}
            HTTPClient.Action := httpIdle;
            {$ENDIF}
          end;
        finally
          PostData.Free;
        end;

        skey := FHeaders.Values['skey'];
        ExtractDetails;
        CompleteStep(bcsLOGIN);

        break;
      except
        on E: EbcServerError do
        begin
          if FCancel then
             raise EbcServerError.Create( E.Message);

          case FServerErrorNo of
          1000 :
            raise EBcInvalidUser.Create('Invalid User/Password');
          1001 :
            begin
              if AttemptCount > 2 then
                raise EBcPasswordError.Create('Password failed on third attempt');

              InvalidPasswordDlg(AttemptCount);
            end;
          else
            //re raise the error
            raise EbcServerError.Create( E.Message);
          end;
        end;
      end;  //except
    end;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

//------------------------------------------------------------------------------
//
// InvalidPasswordDlg
//
// Displays the invalid password dialog and prompts the user to input a correct
// password.
//
procedure TfrmBConnectHTTPS.InvalidPasswordDlg(AttemptCount: Integer);
var
  Msg : String;
begin
  with TBkPasswordDialog.Create(self) do
    try
      DefaultUser := FUserName;
      if (FPassword = '') and (AttemptCount = 0) then
        Msg := 'The login password has not been set.  Please enter your password.'
      else
        Msg := 'The password supplied is invalid.  Please enter your password (attempt #%d)';
      TextMessage := Format(Msg, [AttemptCount + 1]);
      if Execute then
        begin
          FPassword := Password;
          FPasswordEncrypted := false;
        end
      else
      begin
        raise EBcPasswordError.Create('User cancelled attempt to enter correct password.');
      end;
    finally
      Free;
    end;
end;

//******************************************************************************
// TfrmBConnect.GetFileList
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : AStringList: TStringList
// Result     : None
// Purpose    : Retrieve a list of new files from the BConnect Web Server
//              starting with the file specified as the last file the system
//              downloaded.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.GetFileList(AStringList: TStringList);
var
  PostData: TStringList;
  OldCursor: TCursor;
begin
  if FCancel then
    raise Exception.Create('User Cancelled Request');


  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    //Status := 'Retrieve a list of files for download';
    PostData := TStringList.Create;
    try
      try
        PostData.Add('skey=' + sKey);
        PostData.Add('username=' + FUsername);
        PostData.Add('fileid=' + FLastFileID);
        PostData.Add('fileversion=' + FPreferredFileVersion);
        FHeaders.Clear;
        httpClient.ResetHeaders;
        httpClient.PostData := PostData.Text;
        httpClient.URL := BConnectServerPath + 'filelist';
        SetBasicProxyAuthenticate;
        {$IFDEF SSLV6}
        httpClient.Post(httpClient.URL);
        {$ELSE}
        httpClient.Action := httpPost;
        {$ENDIF}
      finally
        {$IFNDEF SSLV6}
        httpClient.Action := httpIdle;
        {$ENDIF}
      end;
    finally
      PostData.Free;
    end;

    AStringList.CommaText := FHeaders.Values['Files'];
  finally
    Screen.Cursor := OldCursor;
  end;
end;

//******************************************************************************
// TfrmBConnect.GetFile
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : FileName: string
// Result     : None
// Purpose    : Retrieve a specific file from the BConnect Web Server.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.GetFile( RemoteFilename: string; LocalFilename : string);
var
  Ext: string;
  OldCursor: TCursor;
  FileDownloadedOK : boolean;
  aMsg             : string;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  //Set FFilename, the filename is passed back from server in GetFileList
  FFilename := RemoteFilename;

  try
    if FCancel then
      raise Exception.Create('User Cancelled Request');

    pbProgress.Percent  := 0;
    lblFileName.Caption := RemoteFilename;
    FileDownloadedOK    := false;
    try
      //Set the timeout to zero should mean infinite timeout but doesnt seem
      //to work reliably.
      //Therefore we set the timeout to 60 minutes so that effectively no timeout occurs.
      //The timeout setting for the component is the timeout for the "action"
      //ie the whole file must transfer within the timeout
      HTTPClient.Timeout := 3600;
      {$IFNDEF SSLV6}
      HTTPClient.Action  := httpIdle;
      {$ENDIF}

      //get the file extension, this is passed to the server
      Ext := ExtractFileExt(FFileName);
      //trim off '.' character
      Ext := Copy(Ext, 2, Length(Ext));

      FHeaders.Clear;
      httpClient.ResetHeaders;

      httpClient.LocalFile := Localfilename;
      httpClient.URL       := BConnectServerPath +
                              'datafile?skey=' + skey +
                              '&username=' + FUsername +
                              '&fileid=' + Ext +
                              '&fileversion=' + FPreferredFileVersion;

      //set proxy settings and request the file
      SetBasicProxyAuthenticate;
      {$IFDEF SSLV6}
      httpClient.Get(httpClient.URL);
      {$ELSE}
      httpClient.Action := httpGet;
      {$ENDIF}
      //check for server errors
      ExtractDetails;

      //check that file size was as expected
      if FFileSize <> FBytesReceived then begin
         aMsg := 'Incomplete download for ' + FFilename +
           ' ' + inttostr( FBytesReceived) +
           ' of ' + inttostr( FFileSize) + ' bytes';
         raise Exception.Create( aMsg);
      end;

      //check that we got the file we expected
      if lowercase(FFilename) <> lowercase(FFilenameSentByServer) then
      begin
        aMsg := 'Wrong file received. Expected ' + FFilename +
                ' but received ' + FFilenameSentByServer;
        raise Exception.Create( aMsg);
      end;

      FileDownloadedOK := true;
      httpClient.LocalFile := '';
      IncrementFilesDownloaded;
    finally
      {$IFNDEF SSLV6}
      HTTPClient.Action := httpIdle;
      {$ENDIF}
      HTTPClient.Timeout := FTimeout;
      //clean up file if a problem occurs
      if ( not FileDownloadedOK) or FCancel then
         DeleteFile( httpClient.LocalFile);
    end;
  finally
    FFileName := '';
    Screen.Cursor := OldCursor;
  end;
end;

//******************************************************************************
// TfrmBConnect.Logout
//
// Date       : 27/09/2001
// Author     : Peter Speden
// Arguments  : None
// Result     : None
// Purpose    : Sends a logout instruction to the BConnect Web Server.
//
//******************************************************************************

procedure TfrmBConnectHTTPS.Logout;
var
  PostData: TStringList;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    //Status := 'Logging out';
    ProcessStep(bcsLOGOUT);

    PostData := TStringList.Create;
    try
      try
        PostData.Add('skey=' + sKey);
        PostData.Add('username=' + FUsername);
        FHeaders.Clear;
        httpClient.ResetHeaders;
        httpClient.PostData := PostData.Text;
        httpClient.URL := BConnectServerPath + 'logout';
        SetBasicProxyAuthenticate;
        {$IFDEF SSLV6}
        httpClient.Post(httpClient.URL);
        {$ELSE}
        httpClient.Action := httpPost;
        {$ENDIF}
      finally
        {$IFNDEF SSLV6}
        HTTPClient.Action := httpIdle;
        {$ENDIF}
      end;
    finally
      PostData.Free;
    end;

    ExtractDetails;

    CompleteStep(bcsLOGOUT);
  finally
    Screen.Cursor := OldCursor;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.FormDestroy(Sender: TObject);
begin
  FreeAndNil (FLog);
  FreeAndNil (FHeaders);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.actShowLogExecute(Sender: TObject);
begin
{
  with TfrmLog.Create (self) do
    try
      memoLog.Lines := FLog;
      ShowModal;
    finally
      free;
    end;
}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.LogMessage(s: string);
begin
   if Assigned( FOnLogMessage) then begin
     FOnLogMessage( S);
   end
   else begin
     FLog.Add (Format (FormatDateTime ('YYYYMMDD HH:NN:SS', now) + ' - %s', [s]));
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TbcErrorDetail }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TbcErrorDetail.Create(AUserName: string; AServerErrorNo: integer;
  AServerErrorMessage: string; AEClassName: string; AEMessage: string;
  AOffsite : Boolean);
begin
  inherited Create;
  FUserName := AUserName;
  FServerErrorNo := AServerErrorNo;
  FServerErrorMessage := AServerErrorMessage;
  FErrorClass := AEClassName;
  FErrorMessage := AEMessage;
  FOffsiteError := AOffsite;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TbcErrorDetail.GetUserErrorMessage: string;
// negative ServerErrorNo come from HTTPS component

// positive error no come from server:
//  NO_ERROR = 0;
//  INVALID_PASSWORD_FILE = 1000;
//  INVALID_PASSWORD = 1001;
//  INVALID_SESSION_KEY = 1002;
//  EXPIRED_SESSION_KEY = 1003;
//  SESSION_ALREADY_COMPLETE = 1004;
//  LAST_FILE_MISMATCH = 1005;
//  OVERDUE_ACCOUNT = 2000;
//  DENY_ALL = 2001;
//  DATABASE_ERROR = 3000;
//  DATABASE_WRITE_ERROR = 3001;
//  UNKNOWN_ERROR = 9000;

begin
  case FServerErrorNo of
    -301: Result := '[301] The request timed out or was interrupted';
    -1 :  Result := 'Winsock Error'; //from HTTPS component
    1000: Result := Format( 'Username and/or Password Invalid for %s',
                            [FUserName]);
    1001: Result := Format( 'Username and/or Password Invalid for %s',
                            [FUserName]);
    1002: Result := 'Session Key supplied is invalid.  Please try again';
    1003: Result := 'Session Key has expired.  Please try again';
    1004: Result := 'Session has already been completed.  Please try again';
    2000:
      begin
        //report a different error if this is offsite
        if (FOffsiteError) then
          Result := 'Data cannot be downloaded at this time. Contact your accountant. [2000]'
        else
          Result := Format( 'Account for %s is overdue.  You cannot download at this time.',
                    [FUserName]);
      end;
    2001: Result := 'The service is currently unavailable. '+'Please try again later.';
    9000: Result := 'Unknown Error at data provider';
  else
    Result := FErrorMessage;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TbcErrorDetail.SetErrorClass(const Value: string);
begin
  FErrorClass := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TbcErrorDetail.SetErrorMessage(const Value: string);
begin
  FErrorMessage := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TbcErrorDetail.SetServerErrorMessage(const Value: string);
begin
  FServerErrorMessage := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TbcErrorDetail.SetServerErrorNo(const Value: integer);
begin
  FServerErrorNo := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientTransfer(Sender: TObject; Direction,
  BytesTransferred: Integer; Text: String);
begin
  if ( Direction = 1) and ( FFileSize > 0) and ( BytesTransferred <= FFileSize) then begin
    pbProgress.Percent := Trunc((BytesTransferred / FFileSize) * 100);
    FBytesReceived := BytesTransferred;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientStartTransfer(Sender: TObject;
  Direction: Integer);
//Direction 0 = transmitting, 1 = receiving
var
  sMsg   : string;
  SizeKB : integer;
  s      : string;
begin
  Status := '';

  if Direction = 1 then
  begin
    FFileSize             := StrToIntDef( FHeaders.Values['Content-Length'], 0);
    FFilenameSentByServer := '';
    //log the file download and size if it is a data file.
    if FFileName <> '' then begin
      SizeKB := FFileSize div 1024;
      if SizeKB < 1 then
         SizeKB := 1;
      S := FHeaders.Values['Content-Disposition'];
      //content disposition is of the format attachment;filename=name.ext
      FFilenameSentByServer := Copy( S, Pos( '=', S) + 1, Length( S));
      sMsg   := Format('Downloading file %s   (%d KB)...', [ FFilenameSentByServer, SizeKB]);
      Status := sMsg;
      LogMessage ( sMsg);
    end
  end
  else begin
      FFileSize := 0;
  end;
  //reset the counters for this transfer
  FBytesReceived := 0;
  pbProgress.Percent := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientEndTransfer(Sender: TObject;
  Direction: Integer);
begin
  if Direction = 1 then
    begin
      if FFileName <> '' then begin
          Status := Format('Download file %s complete', [FFileName]);
          LogMessage (Format('Download file %s complete', [FFileName]));
      end;
      pbProgress.Percent := 0;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientConnected(Sender: TObject;
  StatusCode: Integer; const Description: String);
begin
  if FProcessing and (HTTPClient.Tag = 0) then
    DisplayConnected;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientDisconnected(Sender: TObject;
  StatusCode: Integer; const Description: String);
begin
  if FCancel or (not FProcessing and (HTTPClient.Tag <> 0)) then
    DisplayDisconnected;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientError(Sender: TObject; ErrorCode: Integer;
  const Description: String);
//Note:  This is only called in exceptional circumstances,
//       normally an EIpWorks exception will be raised
begin
    Error := TbcErrorDetail.Create ( FUserName,
                                     -ErrorCode,
                                     IntToStr (ErrorCode),
                                     'EIpsHTTPS',
                                     Description,
                                     FOffsite);             
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.HTTPClientHeader(Sender: TObject; const Field,
  Value: String);
begin
  FHeaders.Add (Format ('%s=%s', [Field, Value]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.DisplayConnected;
begin
  Status := 'Connected';
  imgSecure.ShowGlyph := true;
  HTTPClient.Tag := 1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.DisplayDisconnected;
begin
  Status := 'Done';
  imgSecure.ShowGlyph := false;
  HTTPClient.Tag := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF SSLV6}

   procedure TfrmBConnectHTTPS.HTTPClientSSLServerAuthentication(Sender: TObject;
          CertEncoded: string;
          const CertSubject, CertIssuer, Status: string;
          var Accept: Boolean);

{$ELSE}

   procedure TfrmBConnectHTTPS.HTTPClientSSLServerAuthentication(Sender: TObject;
            CertHandle: Integer;
           const CertSubject: String;
           const CertIssuer: String;
           const Status: String;
           var  Accept: Boolean);
{$ENDIF}
var
  S: String;
begin
  if not Accept then
    begin
      S := 'Server provided the following certificate' + #13#10#13#10 +
      '    Issuer: ' + CertIssuer + #13#10 +
      '    Subject: ' + CertSubject + #13#10#13#10 +
      'The following problems have been determined for this certificate: ' + Status + #13#10#13#10 +
      'Would you like to continue or cancel the connection?';
      Accept := (Application.MessageBox(
      PChar(S), 'Server Certificate Verification Failure', MB_YESNOCANCEL) = IDYES);
    end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmBConnectHTTPS.GetFirewallTypeAsInt: integer;
begin
  Result := Ord(FFirewallType);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.SetBasicProxyAuthenticate;
begin
  if FProxyAuthMethod <> 1 then
    Exit;

  if Trim (FProxyUsername) = '' then
    Exit;

  httpClient.ProxyUser := FProxyUsername;
  httpClient.ProxyPassword := FProxyPassword;
  httpClient.OtherHeaders := Format ('Proxy-Authorization: %s' + Chr (13) + Chr (10), [httpClient.ProxyAuthorization]);
  httpClient.ProxyUser := '';
  httpClient.ProxyPassword := '';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmBConnectHTTPS.GetFileSize( FileName: string ) : Int64;
Var
   Handle   : THandle;
   FindData : TWin32FindData;
   Converter: packed record
     case Boolean of
       false: ( n : int64 );
       true : ( low, high: DWORD );
     end;
Begin
   Result := -1;
   Handle := FindFirstFile(PChar(FileName), FindData);
   If Handle <> INVALID_HANDLE_VALUE Then
   Begin
      Windows.FindClose(Handle);
      Converter.low  := FindData.nFileSizeLow;
      Converter.high := FindData.nFileSizeHigh;
      Result := Converter.N;
   End;
End;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.LogMessageOnServer(s: string);
//sends a message back to the server, used for logging succesful download
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    try
      PostData.Add('skey=' + sKey);
      PostData.Add('username=' + FUsername);
      PostData.Add('logmessage='+ s);
      FHeaders.Clear;
      httpClient.ResetHeaders;
      httpClient.PostData := PostData.Text;
      httpClient.URL := BConnectServerPath + 'logmessage';
      SetBasicProxyAuthenticate;
      {$IFDEF SSLV6}
      httpClient.Post(httpClient.URL);
      {$ELSE}
      httpClient.Action := httpPost;
      {$ENDIF}
    finally
      {$IFNDEF SSLV6}
      HTTPClient.Action := httpIdle;
      {$ENDIF}
    end;
  finally
    PostData.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.LogStatisticsToServer( s : string);
//sends a message back to the server
//used for logging information about the site
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    try
      PostData.Add('skey=' + sKey);
      PostData.Add('username=' + FUsername);
      PostData.Add('statmessage='+ s);
      FHeaders.Clear;
      httpClient.ResetHeaders;
      httpClient.PostData := PostData.Text;
      httpClient.URL := BConnectServerPath + 'statmessage';
      SetBasicProxyAuthenticate;
      {$IFDEF SSLV6}
      httpClient.Post(httpClient.URL);
      {$ELSE}
      httpClient.Action := httpPost;
      {$ENDIF}
    finally
      {$IFNDEF SSLV6}
      HTTPClient.Action := httpIdle;
      {$ENDIF}
    end;
  finally
    PostData.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.LogAccountInfoToServer( s : string);
//sends a message back to the server
//used for logging information about the manual accounts
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    try
      PostData.Add('skey=' + sKey);
      PostData.Add('username=' + FUsername);
      PostData.Add('accountinfo='+ s);
      FHeaders.Clear;
      httpClient.ResetHeaders;
      httpClient.PostData := PostData.Text;
      httpClient.URL := BConnectServerPath + 'accountinfo';
      SetBasicProxyAuthenticate;
      {$IFDEF SSLV6}
      httpClient.Post(httpClient.URL);
      {$ELSE}
      httpClient.Action := httpPost;
      {$ENDIF}
    finally
      FManualAccountInfoSent := True;
      {$IFNDEF SSLV6}
      HTTPClient.Action := httpIdle;
      {$ENDIF}
    end;
  finally
    PostData.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBConnectHTTPS.LogUsageInfoToServer;
//sends a message back to the server
//used for logging information about usage
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    try
      PostData.Add('skey=' + sKey);
      PostData.Add('username=' + FUsername);
      PostData.Add('usageinfo='+ CurrentUsageXML);
      FHeaders.Clear;
      httpClient.ResetHeaders;
      httpClient.PostData := PostData.Text;
      httpClient.URL := BConnectServerPath + 'usageinfo';
      SetBasicProxyAuthenticate;
      {$IFDEF SSLV6}
      httpClient.Post(httpClient.URL);
      {$ELSE}
      httpClient.Action := httpPost;
      {$ENDIF}
    finally
      FUsageInfoSent := True;
      {$IFNDEF SSLV6}
      HTTPClient.Action := httpIdle;
      {$ENDIF}
    end;
  finally
    PostData.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

