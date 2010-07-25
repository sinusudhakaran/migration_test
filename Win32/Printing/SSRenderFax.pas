//------------------------------------------------------------------------------
{
   Title: Rave (tm) Fax Add-On Component (SSRenderFax)
          Copyright (c) 2003 by John Sandage

   Description:

   Author:  as above

   Remarks: calls the windows fax service API's

   Revisions: Apr 04 - modified by Matthew Hopkins to remove need to link in set up form

}
//------------------------------------------------------------------------------

unit SSRenderFax;

interface

uses
  Windows, SysUtils, Classes, Graphics, Printers, Dialogs, SSFaxSupport,
  IniFiles, Controls, WinUtils;

type
  ESSRenderFaxError = Exception;

  p_DWord = ^DWORD;

  FAX_PRINT_INFO = record
    SizeOfStruct: DWORD;  // Structure Size in Bytes
    DocName: PChar;  // Pointer to document name to display
    RecipientName: PChar;  // Pointer to recipient's name
    RecipientNumber: PChar;  // Pointer to recipient's number
    SenderName: PChar;  //pointer to senders's name
    SenderCompany: PChar;  // Pointer to sender's company
    SenderDept: PChar;  // Pointer to Sender's Department
    SenderBillingCode: PChar; // Pointer to Sender's Billing Code
    Reserved: PChar;  // Must be NULL
    DrEMailAddress: PChar;  //Pointer to e-mail address
    OutputFileName: PChar; // reserverd, must be NULL
  end; {Record ...}
  p_FAX_PRINT_INFO = ^FAX_PRINT_INFO;

  FAX_CONTEXT_INFO = record
    SizeOfStruct: DWord;
    DeviceContext: HDC;
    ServerName: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  end; {record}
  p_FAX_CONTEXT_INFO = ^FAX_CONTEXT_INFO;

  FAX_COVERPAGE_INFO = record
    SizeOfStruct: DWORD;
    CoverPageName: PChar;
    UseServerPage: BOOL;
    RecName: PChar;
    RecFaxNumer: PChar;
    RecCompany: PChar;
    RecStreetAddress: PChar;
    RecCity: PChar;
    RecState: PChar;
    RecZip: PChar;
    RecCountry: PChar;
    RecTitle: PChar;
    RecDepartment: PChar;
    RecOfficeLocation: PChar;
    RecHomePhone: PChar;
    RecOfficePhone: PChar;
    SdrName: PChar;
    SdrFaxNumer: PChar;
    SdrCompany: PChar;
    SdrAddress: PChar;
    SdrTitle: PChar;
    SdrDepartment: PChar;
    SdrOfficeLocation: PChar;
    SdrHomePhone: PChar;
    SdrOfficePhone: PChar;
    Note: PChar;
    Subject: PChar;
    TimeSent: TSystemTime;
    PageCount: DWORD;
  end; {record ...}
  p_FAX_COVERPAGE_INFO = ^FAX_COVERPAGE_INFO;

  FAX_TIME = record
    Hour: WORD;
    Minute: WORD;
  end;

  FAX_CONFIGURATION = record
    SizeOfStruct: DWORD; // size of this structure
    Retries: DWORD; // number of retries for fax send
    RetryDelay: DWORD; // number of minutes between retries
    DirtyDays: DWORD; // number of days to keep an unsent job in the queue
    Branding: BOOL; // fsp should brand outgoing faxes
    UseDeviceTsid: BOOL; // server uses device tsid only
    ServerCp: BOOL; // clients must use cover pages on the server
    PauseServerQueue: BOOL; // is the server queue paused?
    StartCheapTime: FAX_TIME; // start of discount rate period
    StopCheapTime: FAX_TIME; // end of discount rate period
    ArchiveOutgoingFaxes: BOOL; // whether outgoing faxes should be archived
    ArchiveDirectory: LPCSTR; // archive directory for outgoing faxes
    Reserved: LPCSTR; // Reserved; must be NULL
  end;
  p_FAX_CONFIGURATION = ^FAX_CONFIGURATION;

  p_FaxStartPrintJob = function(PrinterName: PChar; PrintInfo: p_FAX_PRINT_INFO; FaxJobID: p_DWord; FaxContextInfo: P_FAX_CONTEXT_INFO): BOOL; stdcall;
  p_FaxPrintCoverPage = function(FaxContextInfo: P_FAX_CONTEXT_INFO; CoverPageInfo: P_FAX_COVERPAGE_INFO): BOOL; stdcall;
  p_FaxConnectFaxServer = function(MachineName: LPCSTR; var FaxHandle: THandle): BOOL; stdcall;
  p_FaxGetConfiguration = function(FaxHandle: THandle; var FaxConfig: p_FAX_CONFIGURATION): BOOL; stdcall;
  p_FaxFreeBuffer = function(const FaxConfig): BOOL; stdcall;
  p_FaxSetConfiguration = function(FaxHandle: THandle; FaxConfig: p_FAX_CONFIGURATION): BOOL; stdcall;  
  p_FaxClose = function(FaxHandle: THandle): BOOL; stdcall;

  TFaxSenderInfo = class(TPersistent)
  private
    FName: String;
    FCompany: String;
    FDept: String;
    FBillingCode: String;
  published
    property Name: String read FName write FName;
    property Company: String read FCompany write FCompany;
    property Dept: String read FDept write FDept;
    property BillingCode: String read FBillingCode write FBillingCode;
  end; {TFaxSenderInfo}

  TFaxRecipientInfo = class(TPersistent)
  private
    FName: String;
    FFaxNumber: String;
  published
    property Name: String read FName write FName;
    property FaxNumber: String read FFaxNumber write FFaxNumber;
  end; {TFaxRecipientInfo}

  TFaxCoverPageInfo = class(TPersistent)
  private
    FCoverPageName: String;
    FRecName: String;
    FRecFaxNumber: String;
    FRecCompany: String;
    FRecStreetAddress: String;
    FRecCity: String;
    FRecState: String;
    FRecZip: String;
    FRecCountry: String;
    FRecTitle: String;
    FRecDepartment: String;
    FRecOfficeLocation: String;
    FRecHomePhone: String;
    FRecOfficePhone: String;
    FSdrName: String;
    FSdrFaxNumber: String;
    FSdrCompany: String;
    FSdrAddress: String;
    FSdrTitle: String;
    FSdrDepartment: String;
    FSdrOfficeLocation: String;
    FSdrHomePhone: String;
    FSdrOfficePhone: String;
    FSubject: String;
    FNote: string;
    procedure SetNote(Value: string);
  public
    constructor Create; virtual;
    destructor Destroy; override;
  published
    property CoverPageName: String read FCoverPageName write FCoverPageName;
    property RecName: String read FRecName write FRecName;
    property RecFaxNumber: String read FRecFaxNumber write FRecFaxNumber;
    property RecCompany: String read FRecCompany write FRecCompany;
    property RecStreetAddress: String read FRecStreetAddress write FRecStreetAddress;
    property RecCity: String read FRecCity write FRecCity;
    property RecState: String read FRecState write FRecState;
    property RecZip: String read FRecZip write FRecZip;
    property RecCountry: String read FRecCountry write FRecCountry;
    property RecTitle: String read FRecTitle write FRecTitle;
    property RecDepartment: String read FRecDepartment write FRecDepartment;
    property RecOfficeLocation: String read FRecOfficeLocation write FRecOfficeLocation;
    property RecHomePhone: String read FRecHomePhone write FRecHomePhone;
    property RecOfficePhone: String read FRecOfficePhone write FRecOfficePhone;
    property SdrName: String read FSdrName write FSdrName;
    property SdrFaxNumber: String read FSdrFaxNumber write FSdrFaxNumber;
    property SdrCompany: String read FSdrCompany write FSdrCompany;
    property SdrAddress: String read FSdrAddress write FSdrAddress;
    property SdrTitle: String read FSdrTitle write FSdrTitle;
    property SdrDepartment: String read FSdrDepartment write FSdrDepartment;
    property SdrOfficeLocation: String read FSdrOfficeLocation write FSdrOfficeLocation;
    property SdrHomePhone: String read FSdrHomePhone write FSdrHomePhone;
    property SdrOfficePhone: String read FSdrOfficePhone write FSdrOfficePhone;
    property Subject: String read FSubject write FSubject;
    property Note: string read FNote write SetNote;
  end; {TFaxCoverPageInfo}

  TCoverPageType = (cptNone, cptLocal, cptServer);

  TFaxSetupTabs = (vtGeneral, vtCoverPageGeneral, vtCoverPageRecipient, vtCoverPageSender);
  TFaxSetupVisibleTabs = set of TFaxSetupTabs;
  TFaxSetupAction = (saAlways, saBlank, saNever);

  TFaxSetupInfo = class(TPersistent)
  private
    FVisibleTabs: TFaxSetupVisibleTabs;
    FSetupAction: TFaxSetupAction;
    FCoverPageDir: String;
  public
    constructor Create; virtual;
  published
    property VisibleTabs: TFaxSetupVisibleTabs read FVisibleTabs write FVisibleTabs;
    property SetupAction: TFaxSetupAction read FSetupAction write FSetupAction;
    property CoverPageDir: String read FCoverPageDir write FCoverPageDir;
  end; {TSetupInfo}

  TSSRenderFax = class( TComponent )
  private
    FWinFaxDLLHandle: THandle;
    FCanvas: TCanvas;
    FSenderInfo: TFaxSenderInfo;
    FRecipientInfo: TFaxRecipientInfo;
    FCoverPageInfo: TFaxCoverPageInfo;
    FSetupInfo: TFaxSetupInfo;
    FBeforeSetupDlg: TNotifyEvent;
    FOnDocBegin: TNotifyEvent;
    FOnDocEnd: TNotifyEvent;
    FAfterSetupDlg: TNotifyEvent;

    FaxPrintInfo: FAX_PRINT_INFO;
    FaxContextInfo: FAX_CONTEXT_INFO;
    FaxCoverPageInfo: FAX_COVERPAGE_INFO;

    FDocumentName: String;
    FCoverPageType: TCoverPageType;
    FPrinting: Boolean;
    FAborted: Boolean;
    FOnPage: Boolean;
    FPageCount: Integer;
    FFaxPrinterName: String;
    FFaxPrinterIndex: Integer;
    FFaxJobID: DWORD;
    FPagesToPrint : Integer;
    FDC: hDC;
    FaxHandle: THandle;
    FIsRemote: Boolean;
    procedure CheckPrinting(CalledFrom: String);
    procedure CheckNotPrinting(CalledFrom: String);
    procedure CheckConstraints;
    function GetServerName: String;
    function GetFaxingSupported: Boolean;
    function IsFaxBanner: Boolean;
    procedure SetFaxPrinterName(const Value: string);
    procedure SetFaxPrinterIndex(const Value: Integer);
  protected
    FaxStartPrintJob: p_FaxStartPrintJob;
    FaxPrintCoverPage: p_FaxPrintCoverPage;
    FaxConnectFaxServer: p_FaxConnectFaxServer;
    FaxGetConfiguration: p_FaxGetConfiguration;
    FaxFreeBuffer: p_FaxFreeBuffer;
    FaxSetConfiguration: p_FaxSetConfiguration;
    FaxClose: p_FaxClose;

    procedure Loaded; Override;
    procedure LoadFaxCalls; virtual;
    procedure LoadStructures; virtual;
  public
    constructor Create( Owner : TComponent ); Override;
    destructor Destroy; Override;
    property Printing: Boolean read FPrinting;
    property Aborted: Boolean read FAborted;
    property FaxJobID: DWORD read FFaxJobID;
    property DC: hDC read FDC;
    property ServerName: string read GetServerName;
    property FaxingSupported: Boolean read GetFaxingSupported;
    function GetCanvas: TCanvas;
    procedure DocBegin;
    procedure DoCoverPage(Pages: Integer);
    procedure DocEnd;
    procedure PageBegin;
    procedure PageEnd;
    function GetXDPI: integer;
    function GetYDPI: integer;
    procedure SetFaxBanner(status: Boolean);
    procedure ConnectFax;
  published
//    property Active default false;
    property SenderInfo: TFaxSenderInfo read FSenderInfo write FSenderInfo;
    property RecipientInfo: TFaxRecipientInfo read FRecipientInfo write FRecipientInfo;
    property CoverPageInfo: TFaxCoverPageInfo read FCoverPageInfo write FCoverPageInfo;
    property SetupInfo: TFaxSetupInfo read FSetupInfo write FSetupInfo;

    property DocumentName: String read FDocumentName write FDocumentName;
    property CoverPageType: TCoverPageType read FCoverPageType write FCoverPageType;
    property FaxPrinterName : string read FFaxPrinterName write SetFaxPrinterName;
    property FaxPrinterIndex: Integer read FFaxPrinterIndex write SetFaxPrinterIndex;
    property PagesToPrint: Integer read FPagesToPrint write FPagesToPrint;
    property BeforeSetupDlg: TNotifyEvent read FBeforeSetupDlg write FBeforeSetupDlg;
    property AfterSetupDlg: TNotifyEvent read FAfterSetupDlg write FAfterSetupDlg;
    property OnDocBegin: TNotifyEvent read FOnDocBegin write FOnDocBegin;
    property OnDocEnd: TNotifyEvent read FOnDocEnd write FOnDocEnd;

    property IsBanner: Boolean read IsFaxBanner;
    property IsRemote: Boolean read FIsRemote write FIsRemote;
  end; {SSRenderFax}

implementation

constructor TFaxCoverPageInfo.Create;
begin
  inherited Create;
  FNote := '';
end; {Create}

destructor TFaxCoverPageInfo.Destroy;
begin
  inherited Destroy;
end; {Destroy}

procedure TFaxCoverPageInfo.SetNote(Value: string);
begin
  FNote := Value;
end; {SetNote}

constructor TFaxSetupInfo.Create;
begin
  FVisibleTabs := [vtGeneral, vtCoverPageGeneral, vtCoverPageSender, vtCoverPageRecipient];
  FSetupAction := saBlank;
  FCoverPageDir := 'C:\Documents and Settings\All Users\Application Data\Microsoft\Windows NT\MSFax\Common Coverpages';
end; {Create}

constructor TSSRenderFax.Create( Owner : TComponent );
begin
  inherited Create( Owner );
//  DisplayName := 'MS Fax Service';
  FCanvas := TCanvas.Create;
  FSenderInfo := TFaxSenderInfo.Create;
  FRecipientInfo := TFaxRecipientInfo.Create;
  FCoverPageInfo := TFaxCoverPageInfo.Create;
  FSetupInfo := TFaxSetupInfo.Create;
  FCoverPageType := cptNone;
  FFaxPrinterIndex := -1;
  FDocumentName := 'Faxed Report';
  FPrinting := false;
  FAborted := false;
  FOnPage := false;
  FPageCount := 0;
  FFaxPrinterName := '';
  FaxHandle := 0;
  FIsRemote := False;
  {Initialize the Fax DLL pointers}
  LoadFaxCalls;
//  SetupForm := TFaxSetupForm.Create(Self);
end; {Create}

destructor TSSRenderFax.Destroy;
begin
  FaxClose(FaxHandle); // close connection to fax server
  FCanvas.Free;
  FSenderInfo.Free;
  FRecipientInfo.Free;
  FCoverPageInfo.Free;
  FSetupInfo.Free;
//  SetupForm.Free;
  inherited Destroy;
end; {Destroy}

// Connect to the fax server - used to see if there is a banner and switch off if necessary
// Note this function supports local only - so for remote faxes the user set mmFaxBannerHeight instead
procedure TSSRenderFax.ConnectFax;
begin
  if Pos('\\', FFaxPrinterName) <> 1 then // Local
  begin
    FaxConnectFaxServer('', FaxHandle);
    FIsRemote := False;
  end
  else // Remote
  begin
    FaxHandle := 0;
    FIsRemote := True;
  end;
end;

procedure TSSRenderFax.Loaded;
begin
  inherited;
end; {Loaded}

procedure TSSRenderFax.LoadFaxCalls;

  function LoadOne(FunctionName: String): pointer;
  begin
    result := GetProcAddress(FWinFaxDLLHandle, PChar(FunctionName));
    if result = nil then begin
      raise ESSRenderFaxError.Create('Application links to missing export: '+FunctionName+'.');
    end;
  end; {LoadOne}

begin
  FWinFaxDllHandle := LoadLibrary(PChar('WinFax.dll'));
  if FWinFaxDllHandle = 0 then begin
    raise ESSRenderFaxError.Create('WinFax.dll could not be found.');
  end;
  @FaxStartPrintJob := LoadOne('FaxStartPrintJobA'); {For Ansi character sets}
  @FaxPrintCoverPage := LoadOne('FaxPrintCoverPageA'); {For Ansi character sets}
  @FaxConnectFaxServer := LoadOne('FaxConnectFaxServerA');
  @FaxGetConfiguration := LoadOne('FaxGetConfigurationA');
  @FaxFreeBuffer := LoadOne('FaxFreeBuffer');
  @FaxSetConfiguration := LoadOne('FaxSetConfigurationA');
  @FaxClose := LoadOne('FaxClose');
end; {LoadFaxCalls}

function TSSRenderFax.GetCanvas: TCanvas;
begin
  result := FCanvas;
end; {GetCanvas}

function TSSRenderFax.GetServerName: String;
begin
  result := StrPas(FaxContextInfo.ServerName);
end; {GetServerName}

function TSSRenderFax.GetFaxingSupported: Boolean;
begin
  result := false;
  repeat
    if IsWin9x then break;
    if not DLLFound('WinFax.dll') then break;
    result := true;
  until true;
end; {GetFaxingSupported}


procedure TSSRenderFax.LoadStructures;
begin
  {Load the structures}
  {FaxPrintInfo}
  FaxPrintInfo.SizeOfStruct := SizeOf(FaxPrintInfo);
  FaxPrintInfo.DocName := PChar(FDocumentName);

  FaxPrintInfo.RecipientName := PChar(RecipientInfo.Name);
  FaxPrintInfo.RecipientNumber := PChar(RecipientInfo.FaxNumber);
  FaxPrintInfo.SenderName := PChar(SenderInfo.Name);
  FaxPrintInfo.SenderCompany := PChar(SenderInfo.Company);
  FaxPrintInfo.SenderDept := PChar(SenderInfo.Dept);
  FaxPrintInfo.SenderBillingCode := PChar(SenderInfo.BillingCode);
  FaxPrintInfo.Reserved := nil;
  FaxPrintInfo.DrEMailAddress := nil;
  FaxPrintInfo.OutputFileName := nil;

  {FaxContextFinfo}
  FaxContextInfo.SizeOfStruct := SizeOf(FaxContextInfo);

  {CoverPageInfo}
  FaxCoverPageInfo.SizeOfStruct := SizeOf(FaxCoverPageInfo);
  FaxCoverPageInfo.CoverPageName := PChar(CoverPageInfo.CoverPageName);
  FaxCoverPageInfo.UseServerPage := false;
  FaxCoverPageInfo.Subject := PChar(CoverPageInfo.Subject);
  FaxCoverPageInfo.Note := PChar(CoverpageInfo.Note);

  FaxCoverPageInfo.RecName := PChar(CoverPageInfo.RecName);
  FaxCoverPageInfo.RecFaxNumer := PChar(CoverPageInfo.RecFaxNumber);
  FaxCoverPageInfo.RecCompany := PChar(CoverPageInfo.RecCompany);
  FaxCoverPageInfo.RecStreetAddress := PChar(CoverPageInfo.RecStreetAddress);
  FaxCoverPageInfo.RecCity := PChar(CoverPageInfo.RecCity);
  FaxCoverPageInfo.RecState := PChar(CoverPageInfo.RecState);
  FaxCoverPageInfo.RecZip := PChar(CoverPageInfo.RecZip);
  FaxCoverPageInfo.RecCountry := PChar(CoverPageInfo.RecCountry);
  FaxCoverPageInfo.RecTitle := PChar(CoverPageInfo.RecTitle);
  FaxCoverPageInfo.RecDepartment := PChar(CoverPageInfo.RecDepartment);
  FaxCoverPageInfo.RecOfficeLocation := PChar(CoverPageInfo.RecOfficeLocation);
  FaxCoverPageInfo.RecHomePhone := PChar(CoverPageInfo.RecHomePhone);
  FaxCoverPageInfo.RecOfficePhone := PChar(CoverPageInfo.RecOfficePhone);

  FaxCoverPageInfo.SdrName := PChar(CoverPageInfo.SdrName);
  FaxCoverPageInfo.SdrFaxNumer := PChar(CoverPageInfo.SdrFaxNumber);
  FaxCoverPageInfo.SdrCompany := PChar(CoverPageInfo.SdrCompany);
  FaxCoverPageInfo.SdrAddress := PChar(CoverPageInfo.SdrAddress);
  FaxCoverPageInfo.SdrTitle := PChar(CoverPageInfo.SdrTitle);
  FaxCoverPageInfo.SdrDepartment := PChar(CoverPageInfo.SdrDepartment);
  FaxCoverPageInfo.SdrOfficeLocation := PChar(CoverPageInfo.SdrOfficeLocation);
  FaxCoverPageInfo.SdrHomePhone := PChar(CoverPageInfo.SdrHomePhone);
  FaxCoverPageInfo.SdrOfficePhone := PChar(CoverPageInfo.SdrOfficePhone);
  FaxCoverPageInfo.PageCount := FPagesToPrint + 1; // One is added for the cover page
end; {LoadStructures}

procedure TSSRenderFax.CheckPrinting(CalledFrom: String);
begin
  if not FPrinting then begin
    raise ESSRenderFaxError.Create('Invalid method call.  Device is not printing.  Called from: '+CalledFrom+'.');
  end; { if }
end;  {CheckPrinting}

procedure TSSRenderFax.CheckNotPrinting(CalledFrom: String);
begin
  if FPrinting then begin
    raise ESSRenderFaxError.Create('Invalid method call.  Device is printing.  Called from: '+CalledFrom+'.');
  end; { if }
end;  {CheckNotPrinting}

procedure TSSRenderFAX.CheckConstraints;
begin
  if IsWin9x then begin
    raise ESSRenderFaxError.Create('Faxing is not supported under Windows 9x.');
  end;
  if not DLLFound('WinFax.dll') then begin
    raise ESSRenderFaxError.Create('"WinFax.dll" could not be found.');
  end;
  if Trim( RecipientInfo.FFaxNumber) = '' then begin
    raise ESSRenderFaxError.Create('Fax number cannot be blank.');
  end;
  if (Self.CoverPageType <> cptNone) and (not BKFileExists( CoverPageInfo.CoverPageName)) then begin
    raise ESSRenderFaxError.Create('Cover page "'+CoverPageInfo.CoverPageName+'" could not be found.');
  end;
end; {CheckConstraints}

// Print a coverpage if you should
procedure TSSRenderFax.DoCoverPage(Pages: Integer);
begin
  if  Self.CoverPageType <> cptNone then begin
    FaxCoverPageInfo.PageCount := Pages + 1; // Total pages (including cover)
    if Integer(FaxPrintCoverPage(@FaxContextInfo, @FaxCoverPageInfo)) = 0 then begin
      raise ESSRenderFaxError.Create('"FaxPrintCoverPage" failed.');
    end;
  end;
end;

procedure TSSRenderFax.DocBegin;
  var ThisFaxName: String;
      pThisFaxName: PChar;
begin
  //MessageDlg('DocBegin ...', mtConfirmation, [mbOK], 0);
  CheckNotPrinting('DocBegin');

  {Fire the DocBegin Event}
  if Assigned(FOnDocBegin) then begin
    FOnDocBegin(Self);
  end;

//  {Allow user to modify FAX info if you should}
//  LoadSetupForm;
//  if (SetupInfo.SetupAction = saAlways) or ((SetupInfo.SetupAction = saBlank) and (RecipientInfo.FaxNumber = '')) then begin
//    if Assigned(FBeforeSetupDlg) then begin
//      FBeforeSetupDlg(Self);
//    end;
//    SetupForm.ShowModal;
//    if SetupForm.ModalResult <> mrOK then begin
//      Abort;
//    end;
//    if Assigned(FAfterSetupDlg) then begin
//      FAfterSetupDlg(Self);
//    end;
//  end;

  LoadStructures;
  CheckConstraints;

  {Set the canvas defaults}
  FCanvas.Handle := 0;
  FCanvas.Pen.Handle := GetStockObject(BLACK_PEN);
  FCanvas.Font.Handle := GetStockObject(SYSTEM_FONT);
  FCanvas.Brush.Handle := GetStockObject(BLACK_BRUSH);

  {Find the desired Fax Printer Name}
  ThisFaxName := FaxPrinterName;
  if ThisFaxName <> '' then
    pThisFaxName := PChar( ThisFaxName)
  else
    pThisFaxName := nil;

  {Start the fax print job}
  if Integer(FaxStartPrintJob(pThisFaxName, @FaxPrintInfo, @FFaxJobID, @FaxContextInfo)) = 0 then begin
    raise ESSRenderFaxError.Create('"FaxStartPrintJob" failed with error code ' + IntToStr(GetLastError()));
  end;

  {Set the canvas handle}
  FDC := FaxContextInfo.DeviceContext;
  FCanvas.Handle := DC;       

  {Set the status variables}
  FPrinting := true;
  FAborted := false;
  FOnPage := false;
end; {DocBegin}

procedure TSSRenderFax.DocEnd;
begin
  //MessageDlg('DocEnd ...', mtConfirmation, [mbOK], 0);
  if Printing then begin
    if FOnPage then begin
      Windows.EndPage(DC);
    end;
    if not Aborted then begin
      Windows.EndDoc(DC);
    end; { if }
  end;

  {Reset the status variables}
  FPrinting := false;
  FAborted := false;

  {De-allocate the DC}
  Windows.DeleteDC(DC);

  {Fire the DocEnd Event}
  if Assigned(FOnDocEnd) then begin
    FOnDocEnd(Self);
  end;

end; {DocEnd}

procedure TSSRenderFax.PageBegin;
begin
  //MessageDlg('PageBegin ...', mtConfirmation, [mbOK], 0);
  CheckPrinting('PageBegin');
  if FOnPage then begin
    Windows.EndPage(DC);
    FCanvas.Refresh;
  end; { if }
  Inc(FPageCount);
  Windows.StartPage(DC);
  FOnPage := true;
end; {PageBegin}

procedure TSSRenderFax.PageEnd;
begin
  //MessageDlg('PageEnd ...', mtConfirmation, [mbOK], 0);
end; {PageEnd}

function TSSRenderFax.GetXDPI: integer;
begin
  //MessageDlg('GetXDPI ...', mtConfirmation, [mbOK], 0);
  CheckPrinting('GetXDPI');
  Result := GetDeviceCaps(DC, LOGPIXELSX);
  if Result = 0 then begin
    Result := 200;
  end;
end; {GetXDPI}

function TSSRenderFax.GetYDPI: integer;
begin
  //MessageDlg('GetYDPI ...', mtConfirmation, [mbOK], 0);
  CheckPrinting('GetYDPI');
  Result := GetDeviceCaps(DC, LOGPIXELSY);
  if Result = 0 then begin
    Result := 200;
  end;
end; {GetYDPI}

// Returns true is there is a fax banner
function TSSRenderFax.IsFaxBanner: Boolean;
var
  FaxConfiguration: p_FAX_CONFIGURATION;
begin
  Result := True; // Assume there is one if it fails
  if (FaxHandle > 0) and (Integer(FaxGetConfiguration(FaxHandle, FaxConfiguration)) = 1) then
  begin
    Result := FaxConfiguration.Branding;
    FaxFreeBuffer(FaxConfiguration^);
  end;
end;

// Set the banner
procedure TSSRenderFax.SetFaxBanner(status: Boolean);
var
  FaxConfiguration: p_FAX_CONFIGURATION;
begin
  if FaxHandle > 0 then
  begin
    if Integer(FaxGetConfiguration(FaxHandle, FaxConfiguration)) = 1 then
    begin
      FaxConfiguration.Branding := status;
      FaxSetConfiguration(FaxHandle, FaxConfiguration);
    end;
    FaxFreeBuffer(FaxConfiguration^);
  end;
end;

procedure TSSRenderFax.SetFaxPrinterName(const Value: string);
begin
  FFaxPrinterName := Value;
end;

procedure TSSRenderFax.SetFaxPrinterIndex(const Value: Integer);
begin
  FFaxPrinterIndex := Value;
end;

end.
