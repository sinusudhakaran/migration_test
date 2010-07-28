unit NNWFax;

interface

uses ActiveX, Classes;

type

  ISDK_Sink = dispinterface
    ['{6F12F9A0-75FB-11D0-BD2A-00805F98AB78}']
    procedure EntryIDReady(const EntryID: WideString; Index: Smallint); dispid 1;
    procedure ReceivedEvent(const EntryID: WideString); dispid 2;
    procedure Status(const EntryID: WideString); dispid 3;
  end;

  TNNWFax = class;

  TEventSink = class(TInterfacedObject, IUnknown, IDispatch)
  private
    FOwner: TNNWFax;
    FCookie: Integer;
    FCP: IConnectionPoint;
    FSinkIID: TGUID;
    FSource: IUnknown;
    procedure DoEntryIDReady(const entryID: WideString; index: Smallint); safecall;
    procedure DoReceivedEvent(const entryID: WideString); safecall;
    procedure DoStatus(const entryID: WideString); safecall;
    function  DoInvoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var dps: TDispParams; pDispIds: PDispIdList; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
    procedure BuildPositionalDispIds(pDispIds: PDispIdList; const dps: TDispParams);
    function  QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function  _AddRef: Integer; stdcall;
    function  _Release: Integer; stdcall;
    function  GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT; stdcall;
    function  GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function  GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function  Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
  public
    constructor Create(AOwner: TNNWFax);
    destructor  Destroy; override;
    procedure   Connect(pSource: IDispatch);
    procedure   Disconnect;
  end;

  TCover = ( cNoCover, cQuickCover, cCoverFile );
  TResolution = ( rStandard, rFine );

  TEntryIDReadyEvent =
    procedure (Sender: TObject; const EntryID: WideString; Index: Smallint) of object;
  TReceivedEventEvent =
    procedure (Sender: TObject; const EntryID: WideString) of object;
  TStatusEvent =
    procedure (Sender: TObject; const EntryID: WideString) of object;

  TMessageStatus = (msUnknown, msComplete, msFailed, msHolding, msWaitingAtServer,
                    msRecurring, msSending, msGroupSend, msPending);

  TMessageInfo = record
    DateTime: TDateTime;
    Name: string;
    PhoneNumber: string;
    Subject: string;
    Company: string;
    Keywords: string;
    BillingCode: string;
    CallingStationID: string;
    DeviceNameUsed: string;
    Duration: Integer;
    PageCount: Smallint;
    BaudRate: Smallint;
    Retries: Smallint;
    AttachmentCount: Smallint;
    Resolution: TResolution;
    Hold: Boolean;
    ErrorCorrectionModeUsed: Boolean;
  end;

  TExportFormat = ( efPCX, efDCX, efTIF, efBMP );
  TExportMode = ( emMultiFile, emMultiPage, emAutoDetect );
  TBitsPerPixel = ( bp1, bp4, bp8, bp16, bp24, bp32 );
  TStandardFolder = ( sfRoot, sfLog, sfReceiveLog, sfSendLog, sfWasteBasket, sfOutbox, sfMAPI );

  TRecipients = class;

  TNNWFax = class(TComponent)
  private
    FEvents: TEventSink;
    FRecipients: TRecipients;
    FCoverText: TStrings;
    SDKSendObject: Variant;
    FAttachments: TStrings;
    FSubject: string;
    FCoverFile: string;
    FKeywords: string;
    FBillingCode: string;
    FLastError: Integer;
    FResolution: TResolution;
    FCover: TCover;
    FNeedEntryID: Boolean;
    FPrintFromApp: Boolean;
    FUseCreditCard: Boolean;
    FDeleteAfterSend: Boolean;
    FShowCallProgress: Boolean;
    FPreviewBeforeSending: Boolean;
    FShowSendScreen: Boolean;
    FEnableBillingCodeKeywords: Boolean;
    FOnEntryIDReady: TEntryIDReadyEvent;
    FOnReceivedEvent: TReceivedEventEvent;
    FOnStatus: TStatusEvent;
    function  GetAbout: string;
    function  GetConnected: Boolean;
    procedure SetAbout(const Value: string);
    procedure SetAttachments(const Value: TStrings);
    procedure SetCoverText(const Value: TStrings);
    procedure SetRecipients(const Value: TRecipients);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure EditRecipients;
    function SendFax: Boolean;
    function GetLastError: string;
    function GetMessageStatus(const EntryID: WideString): TMessageStatus;
    function GetMessageInfo(const EntryID: WideString): TMessageInfo;
    function ExportMessage(const MessageID: WideString;
                           const DestFormat: TExportFormat;
                           const DestFileNameOrFolder: string = '';
                           const BitsPerPixel: TBitsPerPixel = bp1;
                           ExportMode: TExportMode = emAutoDetect
                          ): Boolean;
    function ExportFolder(const StandardFolder: TStandardFolder;
                          const DestFormat: TExportFormat;
                          DestPath: string = '';
                          const BitsPerPixel: TBitsPerPixel = bp1;
                          ExportMode: TExportMode = emAutoDetect
                         ): Boolean;
    property Connected: Boolean read GetConnected;
  published
    property About: string read GetAbout write SetAbout stored False;
    property Recipients: TRecipients read FRecipients write SetRecipients;
    property NeedEntryID: Boolean read FNeedEntryID write FNeedEntryID;
    property PrintFromApplication: Boolean read FPrintFromApp write FPrintFromApp;
    property Cover: TCover read FCover write FCover;
    property CoverText: TStrings read FCoverText write SetCoverText;
    property CoverFile: string read FCoverFile write FCoverFile;
    property Resolution: TResolution read FResolution write FResolution;
    property Subject: string read FSubject write FSubject;
    property PreviewBeforeSending: Boolean read FPreviewBeforeSending write FPreviewBeforeSending;
    property DeleteAfterSend: Boolean read FDeleteAfterSend write FDeleteAfterSend;
    property UseCreditCard: Boolean read FUseCreditCard write FUseCreditCard;
    property ShowCallProgress: Boolean read FShowCallProgress write FShowCallProgress;
    property Billing: Boolean read FEnableBillingCodeKeywords write FEnableBillingCodeKeywords;
    property BillingKeywords: string read FKeywords write FKeywords;
    property BillingCode: string read FBillingCode write FBillingCode;
    property Attachments: TStrings read FAttachments write SetAttachments;
    property ShowSendScreen: Boolean read FShowSendScreen write FShowSendScreen;
    property OnEntryIDReady: TEntryIDReadyEvent read FOnEntryIDReady write FOnEntryIDReady;
    property OnReceivedEvent: TReceivedEventEvent read FOnReceivedEvent write FOnReceivedEvent;
    property OnStatus: TStatusEvent read FOnStatus write FOnStatus;
  end;

  TDelivery = ( dSendNow, dScheduled, dOffPeak, dHold );
  TPriority = ( pLow, pNormal, pHigh );

  TRecipient = class(TCollectionItem)
    private
      FDate: TDateTime;
      FTime: TDateTime;
      FName: string;
      FCompany: string;
      FCountryCode: string;
      FAreaCode: string;
      FLocalNumber: string;
      FPriority: TPriority;
      FDelivery: TDelivery;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
    published
      property Name: string read FName write FName;
      property Company: string read FCompany write FCompany;
      property CountryCode: string read FCountryCode write FCountryCode;
      property AreaCode: string read FAreaCode write FAreaCode;
      property LocalNumber: string read FLocalNumber write FLocalNumber;
      property Delivery: TDelivery read FDelivery write FDelivery;
      property ScheduledDate: TDateTime read FDate write FDate;
      property ScheduledTime: TDateTime read FTime write FTime;
      property Priority: TPriority read FPriority write FPriority;
  end;

  TRecipients = class(TCollection)
  private
    FOwner: TComponent;
    function  GetItem(Index: Integer): TRecipient;
    procedure SetItem(Index: Integer; const Value: TRecipient);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TRecipient;
    property Items[Index: Integer]: TRecipient read GetItem write SetItem; default;
  end;

const
  MessageStatusString: array[TMessageStatus] of string =
  (
   'UNKNOWN',
   'COMPLETE',
   'FAILED',
   'HOLDING',
   'WAITING AT SERVER',
   'RECURRING',
   'SENDING',
   'GROUP SEND',
   'PENDING'
  );

implementation

uses {$IFDEF VER140}Variants,{$ENDIF}{$IFDEF VER180}Variants,{$ENDIF}
 SysUtils, ComObj, Windows, Forms, NNWFaxRE;


{ TRecipient }


constructor TRecipient.Create(Collection: TCollection);
begin
  if Assigned(Collection) and (Collection is TRecipients) then
  begin
    inherited Create(Collection);
    FPriority := pNormal;
    FDate := Date
  end
end;


procedure TRecipient.Assign(Source: TPersistent);
begin
  if Source is TRecipient then
  begin
    FName := (Source as TRecipient).Name;
    FCompany := (Source as TRecipient).Company;
    FCountryCode := (Source as TRecipient).CountryCode;
    FAreaCode := (Source as TRecipient).AreaCode;
    FLocalNumber := (Source as TRecipient).LocalNumber;
    FDelivery := (Source as TRecipient).Delivery;
    FDate := (Source as TRecipient).ScheduledDate;
    FTime := (Source as TRecipient).ScheduledTime;
    FPriority := (Source as TRecipient).Priority
  end
  else
    inherited Assign(Source)
end;



{ TRecipients }


constructor TRecipients.Create(AOwner: TComponent);
begin
  inherited Create(TRecipient);
  FOwner := AOwner
end;


function TRecipients.GetOwner: TPersistent;
begin
  Result := FOwner
end;


function TRecipients.Add: TRecipient;
begin
  Result := TRecipient(inherited Add)
end;


function TRecipients.GetItem(Index: Integer): TRecipient;
begin
  Result := (inherited GetItem(Index)) as TRecipient
end;


procedure TRecipients.SetItem(Index: Integer; const Value: TRecipient);
begin
  inherited SetItem(Index, Value)
end;


procedure TRecipients.Update(Item: TCollectionItem);
begin
  inherited Update(Item)
end;



{ TNNWFax }


procedure WinFaxCheck(ReturnValue: Smallint);
begin
  if ReturnValue <> 0 then
    raise Exception.Create('WinFax Check')
end;


function TNNWFax.GetLastError: string;
begin
  case FLastError of
    0: Result := 'OK-Success.';
    1: Result := 'No cover page or attachments in this send job.';
    2: Result := 'No address has been specified.';
    3: Result := 'A required entry ID was not specified.';
    4: Result := 'Cover page filler error.';
    5: Result := 'The attachment was not found in the attachment database.';
    6: Result := 'The cover page was not found in the cover page database.';
    7: Result := 'Could not set the current recipient, most likely the index is out of range.';
    8: Result := 'No recipient was specified.';
    9: Result := 'Transport type error, most likely index or name out of range.';
   10: Result := 'Group recipient could not be set, most likely due to wrong group unique ID.';
   11: Result := 'User recipient could not be set, most likely due to wrong user unique ID.';
   12: Result := 'The unique ID could not be resolved to a group or a single user.';
   16: Result := 'Number too long.';
   32: Result := 'Broadcast error.';
   64: Result := 'Broadcast invalid parameter.';
  128: Result := 'No Internet Fax password.';
  else Result := '<Unknown Error>'
  end
end;


constructor TNNWFax.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecipients := TRecipients.Create(Self);
  FCoverText := TStringList.Create;
  FAttachments := TStringList.Create;
  FNeedEntryID := True;
  FCover := cQuickCover;
  if not (csDesigning in ComponentState) then
    try
      SDKSendObject := CreateOleObject('WinFax.SDKSend');
      WinFaxCheck( SDKSendObject.LeaveRunning );
      FEvents := TEventSink.Create(Self);
      FEvents.Connect(SDKSendObject)
    except
      SDKSendObject := Unassigned
    end
end;


destructor TNNWFax.Destroy;
begin
  if not VarIsEmpty(SDKSendObject) then
  begin
    WinFaxCheck( SDKSendObject.Done );
    SDKSendObject := Unassigned
  end;
  FRecipients.Free;
  FCoverText.Free;
  FAttachments.Free;
  if not (csDesigning in ComponentState) then
    FEvents.Free;
  inherited Destroy
end;


function TNNWFax.SendFax: Boolean;
var
  I: Integer;
  ws: WideString;
begin
  {
  For each instance of the SDKSend object, you can create only one send job
  with one or more recipients. After the job is successfully sent, you must
  destroy the old object and create a new SDKSend object for the next send job.

  The Application SDK supports only one connection point accessed via the Send
  object and this connection point supports only one connection at a time.
  The connection-point managing class is included in the lifetime of the Send
  object, and clients requesting notifications from WinFax should keep a live
  connection to the above object.
  }

  if not VarIsEmpty(SDKSendObject) then
  begin
    FEvents.Disconnect;
    WinFaxCheck( SDKSendObject.Done );
    SDKSendObject := Unassigned
  end
  else
  begin
    Result := False;
    Exit
  end;

  SDKSendObject := CreateOleObject('WinFax.SDKSend');
  FEvents.Connect(SDKSendObject);

  if FPrintFromApp and (FAttachments.Count > 0) then
  begin
    ws := Self.Name;
    WinFaxCheck( SDKSendObject.SetClientID(ws) )
  end;

  WinFaxCheck( SDKSendObject.LeaveRunning );
  WinFaxCheck( SDKSendObject.ResetGeneralSettings );

  // General Recipient Properties (Apply to All recipients)
  ////////////////////////////////////////////////////////////

  // Set Cover properties
  if FCover = cNoCover then
    WinFaxCheck( SDKSendObject.SetUseCover(Smallint(0)) )
  else
  begin
    WinFaxCheck( SDKSendObject.SetUseCover(Smallint(1)) );
    if FCover = cQuickCover then
    begin
      WinFaxCheck( SDKSendObject.SetQuickCover(Smallint(1)) );
      // If the cover page is a quick cover and no text was entered,
      // insert a blank space to suppress the cover page filler which doesn't
      // work for Quick CoverPages.
      ws := FCoverText.Text;
      if ws = '' then
        ws := ' '
    end
    else if Cover = cCoverFile then
    begin
      WinFaxCheck( SDKSendObject.SetQuickCover(Smallint(0)) );
      ws := Trim(FCoverFile);
      if ws <> '' then
        WinFaxCheck( SDKSendObject.SetCoverFile(ws) );
      ws := FCoverText.Text;
      if ws = '' then
        ws := ' '
    end;
    WinFaxCheck( SDKSendObject.SetCoverText(ws) )
  end;

  ws := FSubject;
  WinFaxCheck( SDKSendObject.SetSubject(ws) );
  WinFaxCheck( SDKSendObject.SetPreviewFax(Smallint(FPreviewBeforeSending)) );
  WinFaxCheck( SDKSendObject.SetUseCreditCard(Smallint(FUseCreditCard)) );
  WinFaxCheck( SDKSendObject.SetDeleteAfterSend(Smallint(FDeleteAfterSend)) );
  WinFaxCheck( SDKSendObject.SetResolution(Smallint(Ord(FResolution))) );
  WinFaxCheck( SDKSendObject.ShowCallProgess(Smallint(FShowCallProgress)) );
  WinFaxCheck( SDKSendObject.ShowSendScreen(Smallint(FShowSendScreen)) );
  if FPrintFromApp then
    WinFaxCheck( SDKSendObject.SetPrintFromApp(Smallint(1)) );

  /////////////////////////////////////////////////////////////
  // Individual Recipient Properties - on a per recipient basis
  for I := 0 to FRecipients.Count - 1 do
  begin

    ws := FRecipients.Items[I].Name;
    WinFaxCheck( SDKSendObject.SetTo(ws) );

    ws := FRecipients.Items[I].Company;
    WinFaxCheck( SDKSendObject.SetCompany(ws) );

    ws := FRecipients.Items[I].CountryCode;
    if ws <> '' then
      WinFaxCheck( SDKSendObject.SetCountryCode(ws) );

    ws := FRecipients.Items[I].AreaCode;
    if ws <> '' then
      WinFaxCheck( SDKSendObject.SetAreaCode(ws) );

    ws := FRecipients.Items[I].LocalNumber;
    WinFaxCheck( SDKSendObject.SetNumber(ws) );

    if FRecipients.Items[I].Delivery = dHold then
       WinFaxCheck( SDKSendObject.SetHold(Smallint(1)) )
    else if FRecipients.Items[I].Delivery = dOffPeak then
       WinFaxCheck( SDKSendObject.SetOffPeak(Smallint(1)) )
    else if FRecipients.Items[I].Delivery = dScheduled then
    begin
      ws := FormatDateTime('MM"/"DD"/"YY', FRecipients.Items[I].ScheduledDate);
      WinFaxCheck( SDKSendObject.SetDate(ws) );
      ws := FormatDateTime('HH":"MM":"SS', FRecipients.Items[I].ScheduledTime);
      WinFaxCheck( SDKSendObject.SetTime(ws) )
    end;

    WinFaxCheck( SDKSendObject.SetPriority( Smallint( Ord(FRecipients.Items[I].Priority) + 1) ) );

    // Add this recipeint to the Send Job
    WinFaxCheck( SDKSendObject.AddRecipient )
  end;
  /////////////////////////////////////////////////////////////////////////////

  // Add all attachments here
  for I := 0 to FAttachments.Count - 1 do
  begin
    ws := Trim(FAttachments.Strings[I]);
    if ws <> '' then
      WinFaxCheck( SDKSendObject.AddAttachmentFile(ws) )
  end;

  if FEnableBillingCodeKeyWords then
  begin
    WinFaxCheck( SDKSendObject.EnableBillingCodeKeyWords(Smallint(1)) );
    ws := Trim(FKeywords);
    if ws <> '' then
      WinFaxCheck( SDKSendObject.SetKeywords(ws) );
    ws := Trim(FBillingCode);
    if ws <> '' then
      WinFaxCheck( SDKSendObject.SetBillingCode(ws) )
  end;

  SDKSendObject.Send( Smallint(Ord(FNeedEntryID)) );
  FLastError := SDKSendObject.GetLastError;

  if FLastError = 0 then
  begin
    if FNeedEntryID and not FPrintFromApp then
      while SDKSendObject.IsEntryIDReady(Smallint(0)) = 0 do
        Sleep(10);
    if FPrintFromApp then
      while SDKSendObject.IsReadyToPrint = 0 do
        Sleep(10)
  end;

  Result := FLastError = 0
end;


procedure TNNWFax.SetCoverText(const Value: TStrings);
begin
  FCoverText.Assign(Value)
end;


procedure TNNWFax.SetAttachments(const Value: TStrings);
begin
  FAttachments.Assign(Value)
end;


procedure TNNWFax.SetRecipients(const Value: TRecipients);
begin
  FRecipients.Assign(Value)
end;


function TNNWFax.GetAbout: string;
begin
  Result := 'ver 2.0'
end;


procedure TNNWFax.SetAbout(const Value: string);
begin
end;


procedure TNNWFax.EditRecipients;
var
  RecipientsDialog: TRecipientsDialog;
begin
  RecipientsDialog := TRecipientsDialog.Create(Application);
  try
    RecipientsDialog.SetRecipients(FRecipients);
    if RecipientsDialog.ShowModal = idOK then
      FRecipients.Assign(RecipientsDialog.GetRecipients)
  finally
    RecipientsDialog.Free
  end
end;



{ TEventSink }

{$IFDEF VER140}{$WARN SYMBOL_PLATFORM OFF}{$ENDIF}
{$IFDEF VER180}{$WARN SYMBOL_PLATFORM OFF}{$ENDIF}


constructor TEventSink.Create(AOwner: TNNWFax);
begin
  inherited Create;
  FSinkIID := ISDK_Sink;
  FOwner := AOwner
end;


destructor TEventSink.Destroy;
begin
  Disconnect;
  inherited Destroy
end;


procedure TEventSink.Connect(pSource: IDispatch);
var
  pcpc: IConnectionPointContainer;
begin
  OleCheck( pSource.QueryInterface(IConnectionPointContainer, pcpc) );
  OleCheck( pcpc.FindConnectionPoint(FSinkIID, FCP) );
  OleCheck( FCP.Advise(Self, FCookie) );
  FSource := pSource
end;


procedure TEventSink.Disconnect;
begin
  if Assigned(FSource) then
  try
    OleCheck( FCP.Unadvise(FCookie) );
    FCP := nil;
    FSource := nil
  except
    Pointer(FCP) := nil;
    Pointer(FSource) := nil
  end
end;


procedure TEventSink.BuildPositionalDispIds(pDispIds: PDispIdList; const dps: TDispParams);
var
  I: Integer;
begin
  for I := 0 to dps.cArgs - 1 do
    pDispIds^[I] := dps.cArgs - 1 - I;
  if dps.cNamedArgs <= 0 then Exit;
  for I := 0 to dps.cNamedArgs - 1 do
    pDispIds^[dps.rgdispidNamedArgs^[I]] := I
end;


function TEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
begin
  Result := E_NOTIMPL
end;


function TEventSink.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL
end;


function TEventSink.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  Count := 0;
  Result := E_NOTIMPL
end;


function TEventSink.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
var
  dps: TDispParams absolute Params;
  bHasParams: Boolean;
  pDispIds: PDispIdList;
  iDispIdsSize: Integer;
begin
  pDispIds := nil;
  iDispIdsSize := 0;
  bHasParams := dps.cArgs > 0;
  if bHasParams then
  begin
    iDispIdsSize := dps.cArgs * SizeOf(TDispID);
    GetMem(pDispIds, iDispIdsSize)
  end;
  try
    if bHasParams then
      BuildPositionalDispIds (pDispIds, dps);
    Result := DoInvoke(DispID, IID, LocaleID, Flags, dps, pDispIds, VarResult, ExcepInfo, ArgErr)
  finally
    if bHasParams then
      FreeMem(pDispIds, iDispIdsSize)
  end
end;


function TEventSink.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  Pointer(Obj) := nil;
  if GetInterface(IID, Obj) then
    Result := S_OK;
  if not Succeeded(Result) then
    if IsEqualIID(IID, FSinkIID) then
      if GetInterface(IDispatch, Obj) then
        Result := S_OK
end;


function TEventSink._AddRef: Integer;
begin
  Result := -1
end;


function TEventSink._Release: Integer;
begin
  Result := -1
end;


function TEventSink.DoInvoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var dps: TDispParams; pDispIds: PDispIdList; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
begin
  Result := DISP_E_MEMBERNOTFOUND;
  case DispID of
    1:
    begin
      DoEntryIDReady(dps.rgvarg^[pDispIds^[0]].bstrval, dps.rgvarg^[pDispIds^[1]].ival);
      Result := S_OK
    end;
    2:
    begin
      DoReceivedEvent(dps.rgvarg^[pDispIds^[0]].bstrval);
      Result := S_OK
    end;
    3:
    begin
      DoStatus(dps.rgvarg^[pDispIds^[0]].bstrval);
      Result := S_OK
    end
  end
end;


procedure TEventSink.DoEntryIDReady(const EntryID: WideString; Index: Smallint);
begin
  if Assigned(FOwner.OnEntryIDReady) then
    FOwner.OnEntryIDReady(FOwner, EntryID, Index)
end;


procedure TEventSink.DoReceivedEvent(const EntryID: WideString);
begin
  if Assigned(FOwner.OnReceivedEvent) then
    FOwner.OnReceivedEvent(FOwner, EntryID)
end;


procedure TEventSink.DoStatus(const EntryID: WideString);
begin
  if Assigned(FOwner.OnStatus) then
    FOwner.OnStatus(FOwner, EntryID)
end;


function TNNWFax.GetMessageStatus(const EntryID: WideString): TMessageStatus;
var
  WinFaxSDKLog: Variant;
  EventStatus: Smallint;
begin
  try
    WinFaxSDKLog := CreateOleObject('WinFax.SDKLog');
    EventStatus := WinFaxSDKLog.GetMessageStatus(EntryID);
    Result := TMessageStatus(EventStatus - 2)
  except
    Result := msUnknown
  end;
  WinFaxSDKLog := Unassigned
end;


function TNNWFax.ExportMessage(const MessageID: WideString;
                               const DestFormat: TExportFormat;
                               const DestFileNameOrFolder: string;
                               const BitsPerPixel: TBitsPerPixel;
                               ExportMode: TExportMode
                               ): Boolean;
var
  WinFaxSDKLog, SDKFXConverter, ret: Variant;
  folderID, fileID, NULL_BSTR: WideString;
  S, MessageFileName, MessageFilePath, FilePath, FileName, FileExt, S1, S2: string;
  P: Integer;
  Page: Smallint;
begin
  Result := True;
  NULL_BSTR := '';

  try

    WinFaxSDKLog := CreateOleObject('WinFax.SDKLog');

    folderID := WinFaxSDKLog.GetFolderListFirst(Smallint(1), NULL_BSTR);
    if folderID = '' then
    begin
      Result := False;
      WinFaxSDKLog := Unassigned;
      Exit
    end;

    fileID := WinFaxSDKLog.GetMessageFirstFile(folderID, messageID);
    if fileID = '' then
    begin
      Result := False;
      WinFaxSDKLog := Unassigned;
      Exit
    end;

    SDKFXConverter := CreateOleObject('WinFax.SDKFXConverter');
    SDKFXConverter.Format := Integer(DestFormat) + 1;
    case BitsPerPixel of
      bp1:  SDKFXConverter.BitsPerPixel := 1;
      bp4:  SDKFXConverter.BitsPerPixel := 4;
      bp8:  SDKFXConverter.BitsPerPixel := 8;
      bp16: SDKFXConverter.BitsPerPixel := 16;
      bp24: SDKFXConverter.BitsPerPixel := 24;
      bp32: SDKFXConverter.BitsPerPixel := 32
    end;

    FileName := '';
    Page := 0;

    if ExportMode = emAutoDetect then
      if (DestFormat = efTIF) or (DestFormat = efDCX) then
        ExportMode := emMultiPage
      else
        ExportMode := emMultiFile;

    while True do
    begin

      S := fileID;
      if S = '' then Break;
      Inc(Page);

      P := AnsiPos('|', S);
      MessageFileName := Copy(S, 1, P - 1);
      Delete(S, 1, P);
      P := AnsiPos('|', S);
      MessageFilePath := Copy(S, 1, P - 1);

      if (Page = 1) or (ExportMode = emMultiFile) then
      begin

        FilePath := ExtractFilePath(DestFileNameOrFolder);
        if FilePath = '' then
          FilePath := ExtractFilePath(Application.ExeName);

        FileName := ExtractFileName(DestFileNameOrFolder);
        if FileName = '' then
          FileName := MessageFileName
        else if Page > 1 then
          FileName := FileName + '(page' + IntToStr(Page) + ')';

        FileName := ChangeFileExt(FileName, '');

        case DestFormat of
          efPCX: FileExt := '.pcx';
          efDCX: FileExt := '.dcx';
          efTIF: FileExt := '.tif';
          efBMP: FileExt := '.bmp'
        end

      end;

      S1 := MessageFilePath + MessageFileName;
      S2 := FilePath + FileName + FileExt;
      if (Page = 1) or (ExportMode = emMultiFile) then
        SysUtils.DeleteFile(S2);

      if ExportMode = emMultiFile then
        ret := SDKFXConverter.ConvertFromFX(S1, S2)
      else
        ret := SDKFXConverter.ConvertFromFXToPage(S1, S2, Page);

      P := TVarData(ret).VInteger;
      Result := Result and (P = 0);

      fileID := WinFaxSDKLog.GetMessageNextFile

    end;

    SDKFXConverter := Unassigned;
    WinFaxSDKLog := Unassigned

  except
    Result := False;
    SDKFXConverter := Unassigned;
    WinFaxSDKLog := Unassigned
  end
end;


function TNNWFax.ExportFolder(const StandardFolder: TStandardFolder;
                              const DestFormat: TExportFormat;
                              DestPath: string = '';
                              const BitsPerPixel: TBitsPerPixel = bp1;
                              ExportMode: TExportMode = emAutoDetect
                             ): Boolean;
var
  WinFaxSDKLog, SDKFXConverter, ret: Variant;
  stdFolder, nPage: Smallint;
  NULL_BSTR, messageID, folderID, fileID, lpszFXFILE, lpszDestFile: WideString;
  P, Counter: Integer;
  S, MessageFileName, MessageFilePath, DestFileName, DestFileExt: string;
begin
  Result := False;
  NULL_BSTR := '';
  if DestPath = '' then
    DestPath := ExtractFilePath(Application.ExeName);
  case DestFormat of
    efPCX: DestFileExt := '.pcx';
    efDCX: DestFileExt := '.dcx';
    efTIF: DestFileExt := '.tif';
    efBMP: DestFileExt := '.bmp'
  end;
  if ExportMode = emAutoDetect then
    if (DestFormat = efTIF) or (DestFormat = efDCX) then
      ExportMode := emMultiPage
    else
      ExportMode := emMultiFile;

  try
    WinFaxSDKLog := CreateOleObject('WinFax.SDKLog');
    stdFolder := Ord(StandardFolder) + 1;
    folderID := WinFaxSDKLog.GetFolderListFirst(Smallint(1), NULL_BSTR);
    if folderID = NULL_BSTR then
    begin
      WinFaxSDKLog := Unassigned;
      Exit
    end;
    messageID := WinFaxSDKLog.GetMessageListFirst(stdFolder, NULL_BSTR);
    if messageID = NULL_BSTR then
    begin
      WinFaxSDKLog := Unassigned;
      Exit
    end;
    SDKFXConverter := CreateOleObject('WinFax.SDKFXConverter');
    SDKFXConverter.Format := Integer(DestFormat) + 1;
    case BitsPerPixel of
      bp1:  SDKFXConverter.BitsPerPixel := 1;
      bp4:  SDKFXConverter.BitsPerPixel := 4;
      bp8:  SDKFXConverter.BitsPerPixel := 8;
      bp16: SDKFXConverter.BitsPerPixel := 16;
      bp24: SDKFXConverter.BitsPerPixel := 24;
      bp32: SDKFXConverter.BitsPerPixel := 32
    end;
    Counter := 0;
    repeat
      Inc(Counter);
      fileID := WinFaxSDKLog.GetMessageFirstFile(folderID, messageID);
      nPage := 0;
      while fileID <> '' do
      begin
        Inc(nPage);
        S := fileID;
        P := AnsiPos('|', S);
        MessageFileName := Copy(S, 1, P - 1);
        Delete(S, 1, P);
        P := AnsiPos('|', S);
        MessageFilePath := Copy(S, 1, P - 1);
        lpszFXFILE := MessageFilePath + MessageFileName;
        DestFileName := IntToStr(Counter);
        if (ExportMode = emMultiFile) and (nPage > 1) then
          DestFileName := DestFileName + '(page' + IntToStr(nPage) + ')';
        lpszDestFile := DestPath + DestFileName + DestFileExt;
        if (ExportMode = emMultiFile) or (nPage = 1) then
          SysUtils.DeleteFile(lpszDestFile);
        if ExportMode = emMultiFile then
          ret := SDKFXConverter.ConvertFromFX(lpszFXFILE, lpszDestFile)
        else
          ret := SDKFXConverter.ConvertFromFXToPage(lpszFXFile, lpszDestFile, nPage);
        fileID := WinFaxSDKLog.GetMessageNextFile
      end;
      messageID := WinFaxSDKLog.GetMessageListNext;
    until messageID = NULL_BSTR;
    Result := True
  finally
    SDKFXConverter := Unassigned;
    WinFaxSDKLog := Unassigned
  end
end;


function TNNWFax.GetConnected: Boolean;
begin
  Result := not VarIsEmpty(SDKSendObject)
end;


function TNNWFax.GetMessageInfo(const EntryID: WideString): TMessageInfo;
var
  V: Variant;
  ws, ws1: WideString;
  si: Smallint;
  li: Longint;
begin
  try
    V := CreateOleObject('WinFax.SDKLog');
    ws := V.GetMessageDisplayName(EntryID);
    Result.Name := ws;
    ws := V.GetMessageNumber(EntryID);
    Result.PhoneNumber := ws;
    ws := V.GetMessageSubject(EntryID);
    Result.Subject := ws;
    ws := V.GetMessageCompany(EntryID);
    Result.Company := ws;
    ws := V.GetMessageKeywords(EntryID);
    Result.Keywords := ws;
    ws := V.GetMessageBillingCode(EntryID);
    Result.BillingCode := ws;
    si := V.GetMessageAttachmentCount(EntryID);
    Result.AttachmentCount := si;
    si := V.GetMessageHold(EntryID);
    Result.Hold := si <> 0;
    ws := V.GetMessageDate(EntryID);
    ws1 := V.GetMessageTime(EntryID);
    Result.DateTime := StrToDate(ws) + StrToTime(ws1);
    ws := V.GetMessageCSID(EntryID);
    Result.CallingStationID := ws;
    si := V.GetMessagePageCount(EntryID);
    Result.PageCount := si;
    si := V.GetMessageResolution(EntryID);
    Result.Resolution := TResolution(si);
    li := V.GetMessageDuration(EntryID);
    Result.Duration := li;
    si := V.GetMessageBaudRate(EntryID);
    Result.BaudRate := si;
    si := V.GetMessageUsedECM(EntryID);
    Result.ErrorCorrectionModeUsed := si <> 0;
    ws := V.GetMessageDeviceNameUsed(EntryID);
    Result.DeviceNameUsed := ws;
    si := V.GetMessageRetries(EntryID);
    Result.Retries := si
  finally
    V := Unassigned
  end
end;


end.

