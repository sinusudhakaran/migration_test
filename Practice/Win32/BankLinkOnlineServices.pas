unit BankLinkOnlineServices;

//------------------------------------------------------------------------------
interface

uses
  Forms,
  BlopiServiceFacade,
  InvokeRegistry,
  Windows,
  XMLIntf,
  TypInfo,
  Classes,
  ComCtrls;

type
  TBloStatus                = BlopiServiceFacade.Status;
  TBloArrayOfString         = BlopiServiceFacade.ArrayOfString;

  TBloGuid                  = BlopiServiceFacade.Guid;
  TBloArrayOfGuid           = BlopiServiceFacade.ArrayOfGuid;

  TBloCatalogueEntry        = BlopiServiceFacade.CatalogueEntry;
  TBloArrayOfCatalogueEntry = BlopiServiceFacade.ArrayOfCatalogueEntry;

  TBloPracticeRead          = BlopiServiceFacade.PracticeRead;

  TBloClientCreate          = BlopiServiceFacade.ClientCreate;
  TBloClientReadDetail      = BlopiServiceFacade.ClientReadDetail;

  TBloUserCreate            = BlopiServiceFacade.UserCreate;
  TBloUserCreatePractice    = BlopiServiceFacade.UserCreatePractice;
  TBloUserUpdate            = BlopiServiceFacade.UserUpdate;
  TBloUserUpdatePractice    = BlopiServiceFacade.UserUpdatePractice;
  TBloUserRead              = BlopiServiceFacade.UserRead;

  TVarTypeData = record
    Name     : String;
    TypeInfo : PTypeInfo;
  end;

  TArrVarTypeData = Array of TVarTypeData;

  TUserDetailHelper = class helper for BlopiServiceFacade.User
  public
    function AddRoleName(RoleName: string) : Boolean;
  end;

  TClientBaseHelper = class helper for BlopiServiceFacade.Client
  private
    function GetStatusString: string;
  public
    function AddSubscription(AProductID: TBloGuid) : Boolean;
    function RemoveSubscription(AProductID: TBloGuid) : Boolean;
    function HasSubscription(AProductID: TBloGuid) : Boolean;
    property StatusString: string read GetStatusString;
  end;

  TClientHelper = Class helper for BlopiServiceFacade.ClientReadDetail
  private
    function GetDeactivated: boolean;
    function GetClientConnectDays: string;
    function GetFreeTrialEndDate: TDateTime;
    function GetBillingEndDate: TDateTime;
    function GetUserOnTrial: boolean;
    function GetSuspended: boolean;
  public
    procedure UpdateAdminUser(AUserName, AEmail: WideString);
    property Deactivated: boolean read GetDeactivated;
    property ClientConnectDays: string read GetClientConnectDays; // 0 if client must always be online
    property FreeTrialEndDate: TDateTime read GetFreeTrialEndDate;
    property BillingEndDate: TDateTime read GetBillingEndDate;
    property UserOnTrial: boolean read GetUserOnTrial;
    property Suspended: boolean read GetSuspended;
  End;

  TPracticeHelper = Class helper for PracticeRead
  private
    function GetUserRoleGuidFromPracUserType(aUstNameIndex : integer;
                                             aInstance: PracticeRead) : Guid;
  public
    function GetRoleFromPracUserType(aUstNameIndex : integer;
                                     aInstance: PracticeRead) : Role;
    function IsEqual(Instance: PracticeRead): Boolean;
  End;

  TProductConfigService = class(TObject)
  private
    fMethodName: string;
    fSOAPRequest: InvString;

    FPractice, FPracticeCopy: TBloPracticeRead;
    FClientList: ClientList;
    FOnLine: Boolean;
    FRegistered: Boolean;
    FValidBConnectDetails: Boolean;
    FArrNameSpaceList : Array of TRemRegEntry;
    procedure CopyRemotableObject(ASource, ATarget: TRemotable);

    function IsUserCreatedOnBankLinkOnline(const APractice : TBloPracticeRead;
                                           const AUserId   : TBloGuid   = '';
                                           const AUserCode : string = ''): Boolean;

    function RemotableObjectToXML(ARemotable: TRemotable): string;
    procedure LoadRemotableObjectFromXML(const XML: string; ARemotable: TRemotable);
    procedure SaveRemotableObjectToFile(ARemotable: TRemotable);
    function LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
    function OnlineStatus: TBloStatus;
    function GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                              const aName : String) : integer;
    procedure AddTypeItem(var aDataArray : TArrVarTypeData;
                          var aDataItem  : TVarTypeData);
    procedure AddToXMLTypeNameList(const aName : String;
                                   aTypeInfo : PTypeInfo;
                                   var aNameList : TArrVarTypeData);
    procedure FindXMLTypeNamesToModify(const aMethodName : String;
                                       var aNameList : TArrVarTypeData);
    procedure AddXMLNStoArrays(const aCurrNode : IXMLNode;
                               var aNameList : TArrVarTypeData);
    procedure DoBeforeExecute(const MethodName: string;
                              var SOAPRequest: InvString);
    procedure SetTimeOuts(ConnecTimeout : DWord ;
                          SendTimeout   : DWord ;
                          ReciveTimeout : DWord);
    function GetServiceFacade : IBlopiServiceFacade;
    function GetClientGuid(const AClientCode: string): WideString;
    function GetCachedPractice: TBloPracticeRead;
    function MessageResponseHasError(AMesageresponse: MessageResponse; ErrorText: string): Boolean;
    function GetProducts : TBloArrayOfGuid;
    function GetRegistered: Boolean;
    function GetValidBConnectDetails: Boolean;
    procedure RemoveInvalidSubscriptions;
  public
    destructor Destroy; override;
    //Practice methods
    function GetPractice(aUpdateUseOnline: Boolean = True; aForceOnlineCall : Boolean = false): TBloPracticeRead;
    function IsPracticeActive(ShowWarning: Boolean = true): Boolean;
    function GetCatalogueEntry(AProductId: TBloGuid): TBloCatalogueEntry;
    function IsPracticeProductEnabled(AProductId: TBloGuid; AUsePracCopy : Boolean): Boolean;
    function HasProductJustBeenUnTicked(AProductId: TBloGuid): Boolean;
    function GetNotesId : TBloGuid;
    function IsNotesOnlineEnabled: Boolean;
    function IsCICOEnabled: Boolean;
    procedure UpdateUserAllowOnlineSetting;
    function SavePractice: Boolean;
    function PracticeChanged: Boolean;
    procedure AddProduct(AProductId: TBloGuid);
    procedure ClearAllProducts;
    procedure RemoveProduct(AProductId: TBloGuid);
    procedure SelectAllProducts;
    procedure SetPrimaryContact(AUser: TBloUserRead);
    function GetCatFromSub(aSubGuid : Guid): CatalogueEntry;
    property CachedPractice: PracticeRead read GetCachedPractice;
    procedure GetServiceAgreement(ARichEdit: TRichEdit);
    procedure SavePracticeDetailsToSystemDB(ARemotable: TRemotable);
    //Client methods
    procedure LoadClientList;
    function GetClientDetailsWithCode(AClientCode: string): TBloClientReadDetail;
    function GetClientDetailsWithGUID(AClientGuid: Guid): TBloClientReadDetail;
    function CreateNewClient(ANewClient: TBloClientCreate): Guid;
    function SaveClient(AClient: TBloClientReadDetail): Boolean;
    property Clients: ClientList read FClientList;
    //User methods
    function AddEditPracUser(var   aUserId         : TBloGuid;
                             const aEMail          : WideString;
                             const aFullName       : WideString;
                             const aUserCode       : WideString;
                             const aUstNameIndex   : integer;
                             var   aIsUserCreated  : Boolean;
                             const aChangePassword : Boolean;
                             const aPassword       : WideString ) : Boolean;
    function DeletePracUser(const aUserCode : string;
                            const aUserGuid : string;
                            aPractice : TBloPracticeRead = nil): Boolean;
    function IsPrimPracUser(const aUserCode : string = '';
                            aPractice : TBloPracticeRead = nil): Boolean;
    function GetPracUserGuid(const aUserCode : string;
                             aPractice : TBloPracticeRead): TBloGuid;
    function ChangePracUserPass(const aUserCode : WideString;
                                const aPassword : WideString;
                                aPractice : TBloPracticeRead = nil) : Boolean;
    property OnLine: Boolean read FOnLine;
    property Registered: Boolean read GetRegistered;
    property ValidBConnectDetails: Boolean read GetValidBConnectDetails;    
    property ProductList : TBloArrayOfGuid read GetProducts;
  end;

Const
  staActive      = BlopiServiceFacade.Active;
  staSuspended   = BlopiServiceFacade.Suspended;
  staDeactivated = BlopiServiceFacade.Deactivated;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

//------------------------------------------------------------------------------
implementation

uses
  Controls,
  Globals,
  SysUtils,
  XMLDoc,
  OPToSOAPDomConv,
  LogUtil,
  WarningMoreFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  IniSettings,
  WebUtils,
  stDate,
  IniFiles,
  Progress,
  BkConst,
  WinINet,
  SOAPHTTPClient,
  OpConvert,
  strUtils,
  WideStrUtils,
  WSDLIntf,
  IntfInfo,
  ObjAuto,
  SyDefs;

const
  UNIT_NAME = 'BankLinkOnlineServices';
  INIFILE_NAME = 'BankLinkOnline.ini';

  PRODUCT_GUID_CICO = '6D700B31-DAEE-4847-8CB2-82C21328AC33';
  PRODUCT_GUID_NOTES_ONLINE = '6D700B31-DAEE-4847-8CB2-82C21328AC30';

var
  __BankLinkOnlineServiceMgr: TProductConfigService;
  DebugMe : Boolean = False;

//------------------------------------------------------------------------------
function ProductConfigService: TProductConfigService;
begin
  if not Assigned(__BankLinkOnlineServiceMgr) then
    __BankLinkOnlineServiceMgr := TProductConfigService.Create;
  Result := __BankLinkOnlineServiceMgr;
end;

{ TProductConfigService }
//------------------------------------------------------------------------------
procedure TProductConfigService.AddProduct(AProductId: TBloGuid);
var
  i: integer;
  SubArray:  TBloArrayOfGuid;
begin
  //Add product
  for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    if AProductId = FPracticeCopy.Subscription[i] then
      Exit;
  //Add if still here
  SubArray := FPracticeCopy.Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.ClearAllProducts;
var
  i: integer;
  SubArray: TBloArrayOfGuid;
begin
  //Copy the subscription array
  SetLength(SubArray, Length(FPracticeCopy.Subscription));
  for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    SubArray[i] := FPracticeCopy.Subscription[i];
  //Try to remove product  
  for i := Low(SubArray) to High(SubArray) do
    RemoveProduct(SubArray[i]);
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.CopyRemotableObject(ASource,
  ATarget: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XML: IXMLDocument;
  XMLStr: WideString;
begin
  XML:= NewXMLDocument;
  NodeRoot:= XML.AddChild('Root');
  NodeParent:= NodeRoot.AddChild('Parent');
  Converter:= TSOAPDomConv.Create(NIL);
  NodeObject:= ASource.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                    'CopyObject', '', [ocoDontPrefixNode],
                                    XMLStr);
  ATarget.SOAPToObject(NodeRoot, NodeObject, Converter);
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateNewClient(ANewClient: TBloClientCreate): TBloGuid;
var
  i: integer;
  Msg: string;
  BlopiInterface: IBlopiServiceFacade;
  MsgResponse: MessageResponseOfGuid;
  ShowProgress : Boolean;
begin
  Result := '';

  if not Assigned(AdminSystem) then
    Exit;

  if not Registered then
    Exit;

  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Creating Client', 50);

      BlopiInterface :=  GetServiceFacade;
      MsgResponse := BlopiInterface.CreateClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                 AdminSystem.fdFields.fdBankLink_Code,
                                                 AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                 ANewClient);
      if not MessageResponseHasError(MsgResponse, 'create client on') then
        Result := MsgResponse.Result;

      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do HelpfulErrorMsg('Error creating a new client on ' +
                                      BANKLINK_ONLINE_NAME + ': ' + E.Message, 0);
  end;
end;

//------------------------------------------------------------------------------
destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FreeAndNil(FPracticeCopy);
  FreeAndNil(FPractice);
  FreeAndNil(FClientList);
  inherited;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCachedPractice: TBloPracticeRead;
begin
  Result := FPractice;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCatalogueEntry(
  AProductId: TBloGuid): TBloCatalogueEntry;
var
  i: integer;
begin
  Result :=  nil;
  for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
    if (AProductId = FPractice.Catalogue[i].Id) then begin
      Result := FPractice.Catalogue[i];
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientDetailsWithCode(AClientCode: string): TBloClientReadDetail;
var
  ClientGuid: WideString;
begin
  Result := nil;

  if not Assigned(AdminSystem) then
    Exit;

  if not Registered then
    Exit;

  //Find client code in the client list
  ClientGuid := GetClientGuid(AClientCode);
  if (ClientGuid <> '') then
    Result := GetClientDetailsWithGuid(ClientGuid);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientDetailsWithGuid(AClientGuid: TBloGuid): TBloClientReadDetail;
var
  i, j: integer;
  BlopiInterface: IBlopiServiceFacade;
  ClientDetailResponse: MessageResponseOfClientReadDetailMIdCYrSK;
  Msg: string;
  ShowProgress : Boolean;
begin
  Result := nil;
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Client Details', 50);

      BlopiInterface :=  GetServiceFacade;
      //Get the client from BankLink Online
      ClientDetailResponse := BlopiInterface.GetClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       AClientGuid);
      if not MessageResponseHasError(MessageResponse(ClientDetailResponse), 'get the client settings from') then
        Result := ClientDetailResponse.Result;

      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do HelpfulErrorMsg('Error getting client settings: ' + E.Message, 0);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientGuid(const aClientCode: string): WideString;
var
  i: integer;
begin
  Result := '';
  if Assigned(FClientList) then
  begin
    for i := Low(FClientList.Clients) to High(FClientList.Clients) do
    begin
      if (AClientCode = FClientList.Clients[i].ClientCode) then
      begin
        Result := FClientList.Clients[i].Id;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPractice(aUpdateUseOnline: Boolean; aForceOnlineCall : Boolean): TBloPracticeRead;
var
  i: integer;
  BlopiInterface: IBlopiServiceFacade;
  PracticeDetailResponse: MessageResponseOfPracticeReadMIdCYrSK;
  Msg: string;
  ShowProgress : Boolean;
begin
  Result := Nil;
  if not Assigned(AdminSystem) then
    Exit;

  //Check that BConnect secure code has been assigned
  if AdminSystem.fdFields.fdBankLink_Code = '' then begin
    HelpfulErrorMsg('The BankLink Secure Code for this practice has not been set. ' +
                    'Please set this before attempting to use ' + BANKLINK_ONLINE_NAME +
                    '.', 0);
    Exit;
  end;

  //Initialise
  FOnLine := False;
  FRegistered := False;
  FValidBConnectDetails := False;
  //UseBankLinkOnline is updated by the user when the practice details
  //dialog is open - so dont't reset it.
  if aUpdateUseOnline then
    UseBankLinkOnline := False;
  FreeAndNil(FPractice);
  FPractice := TBloPracticeRead.Create;
  FreeAndNil(FPracticeCopy);
  FPracticeCopy := TBloPracticeRead.Create;
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;

    try
      try
        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Practice Details', 50);

        //Load cached practice details if they are registered or not
        if AdminSystem.fdFields.fdBankLink_Online_Config <> '' then
          LoadRemotableObjectFromXML(AdminSystem.fdFields.fdBankLink_Online_Config, FPractice);

        //UseBankLinkOnline is updated by the user when the practice details
        //dialog is open - so dont't reload it from the system db.
        if aUpdateUseOnline then
          UseBankLinkOnline := AdminSystem.fdFields.fdUse_BankLink_Online;

        //Try to load practice details from BankLink Online
        FOnLine := False;
        if (UseBankLinkOnline)
        or not FPractice.IsEqual(FPracticeCopy)
        or (aForceOnlineCall) then
        begin
          //Reload from BankLink Online
          BlopiInterface := GetServiceFacade;
          PracticeDetailResponse := BlopiInterface.GetPractice(CountryText(AdminSystem.fdFields.fdCountry),
                                                               AdminSystem.fdFields.fdBankLink_Code,
                                                               AdminSystem.fdFields.fdBankLink_Connect_Password);
          if Assigned(PracticeDetailResponse) then begin
            FOnline := True;

            for i := 1 to Screen.FormCount - 1 do
            begin
              if (Screen.Forms[i].Name = 'frmClientManager') then
              begin
                SendMessage(Screen.Forms[i].Handle, BK_PRACTICE_DETAILS_CHANGED, 0, 0);
                break;
              end;
            end;

            if Assigned(PracticeDetailResponse.Result) then begin
              AdminSystem.fdFields.fdLast_BankLink_Online_Update := stDate.CurrentDate;
              FPractice := PracticeDetailResponse.Result;
              FRegistered := True;
              FValidBConnectDetails := True;
            end else begin
              //Something went wrong
              Msg := '';
              if Length(PracticeDetailResponse.ErrorMessages) > 0 then begin
                //Check for non-registered Practice
                if (PracticeDetailResponse.ErrorMessages[0].ErrorCode = 'BusinessPlusService_GetPracticeIdFailed') then begin
                  FRegistered := False;
                  FValidBConnectDetails := True;
                  AdminSystem.fdFields.fdBankLink_Online_Config := '';
                end else begin
                  for i := Low(PracticeDetailResponse.ErrorMessages) to High(PracticeDetailResponse.ErrorMessages) do
                    Msg := Msg + ServiceErrorMessage(PracticeDetailResponse.ErrorMessages[i]).Message_;
                  if Msg = 'Invalid BConnect Credentials' then
                    //Clear the cached practice details if not registered for this practice code
                    AdminSystem.fdFields.fdBankLink_Online_Config := '';
                end;
              end else
                Msg := 'Unknown error';
              if Msg <> '' then
                raise Exception.Create(Msg);
            end;
          end;
        end;
        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
      except
        on E: Exception do
          HelpfulErrorMsg(BKPRACTICENAME + ' is unable to connect to ' + BANKLINK_ONLINE_NAME + '.',
                          0, True, E.Message, True);

      end;
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    //Make a copy for editing
    if FPractice <> nil then
      CopyRemotableObject(FPractice, FPracticeCopy);
    Result := FPracticeCopy;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetProducts: TBloArrayOfGuid;
begin
  if Assigned(FPracticeCopy) then
    Result := FPracticeCopy.Subscription;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetRegistered: Boolean;
begin
  if not Assigned(FPractice) then
    GetPractice;
  Result := FRegistered;  
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.LoadClientList;
var
  BlopiInterface: IBlopiServiceFacade;
  BlopiClientList: MessageResponseOfClientListMIdCYrSK;
  Msg: string;
  i: integer;
  ShowProgress : Boolean;
begin
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;
    try
      FreeAndNil(FClientList);
      if UseBankLinkOnline then begin
        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Client List', 50);

        BlopiInterface := GetServiceFacade;
        BlopiClientList := BlopiInterface.GetClientList(CountryText(AdminSystem.fdFields.fdCountry),
                                                        AdminSystem.fdFields.fdBankLink_Code,
                                                        AdminSystem.fdFields.fdBankLink_Connect_Password);
        if not MessageResponseHasError(MessageResponse(BlopiClientList), 'load the client list from') then
          if Assigned(BlopiClientList.Result) then
            FClientList := BlopiClientList.Result;

        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
      end;
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do begin
      HelpfulErrorMsg('Error getting client list from ' + BANKLINK_ONLINE_NAME + '.',
                      0, True, E.Message, True);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
var
  XMLDoc: IXMLDocument;
begin
  Result := False;
  if FileExists(ARemotable.ClassName + '.xml') then begin
    XMLDoc := NewXMLDocument;
    XMLDoc.LoadFromFile(ARemotable.ClassName + '.xml');
    LoadRemotableObjectFromXML(XMLDoc.XML.Text, ARemotable);
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.LoadRemotableObjectFromXML(const XML: string;
  ARemotable: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  Converter := TSOAPDomConv.Create(NIL);
  XMLDoc := NewXMLDocument;
  XMLDoc.LoadFromXML(XML);
  NodeRoot := XMLDoc.ChildNodes.FindNode('Root');
  NodeParent := NodeRoot.ChildNodes.FindNode('Parent');
  NodeObject := NodeParent.ChildNodes.FindNode('CopyObject');
  ARemotable.SOAPToObject(NodeRoot, NodeObject, Converter);
end;

//------------------------------------------------------------------------------
function TProductConfigService.MessageResponseHasError(
  AMesageresponse: MessageResponse; ErrorText: string): Boolean;
const
  MAIN_ERROR_MESSAGE = BKPRACTICENAME + ' is unable to %s ' + BANKLINK_ONLINE_NAME + '.';
var
  ErrorMessage: string;
  ErrIndex : integer;
  Details: TStringList;

  //-------------------------------------------------------------
  procedure AddLine(const aName: string; const aMessage: string);
  begin
    if aMessage = '' then
      Exit;
    if Assigned(Details) then begin
      if Details.Count > 0 then
        Details.add('');
      Details.Add(aName + ': ' + aMessage);
    end;
  end;

begin
  Result := False;
  if Assigned(AMesageresponse) then
  begin
    if not AMesageresponse.Success then
    begin
      //Error message returned by BankLink Online
      Result := True;
      ErrorMessage := Format(MAIN_ERROR_MESSAGE, [ErrorText]);
      Details := TStringList.Create;
      try
        for ErrIndex := 0 to high(AMesageresponse.ErrorMessages) do
        begin
          AddLine('Code', AMesageresponse.ErrorMessages[ErrIndex].ErrorCode);
          AddLine('Message', AMesageresponse.ErrorMessages[ErrIndex].Message_);
        end;
        for ErrIndex := 0 to high(AMesageresponse.Exceptions) do
        begin
          AddLine('Message', AMesageresponse.Exceptions[ErrIndex].Message_);
          AddLine('Source', AMesageresponse.Exceptions[ErrIndex].Source);
          AddLine('StackTrace', AMesageresponse.Exceptions[ErrIndex].StackTrace);
        end;
        HelpfulErrorMsg(ErrorMessage, 0, True, Details.Text, True);
      finally
        Details.Free;
      end;
    end;
  end
  else
  begin
    //No response from BankLink Online
    ErrorMessage := Format(MAIN_ERROR_MESSAGE, ['connect to']);
    HelpfulErrorMsg(ErrorMessage, 0);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.OnlineStatus: TBloStatus;
begin
  Result := Active;
  if Assigned(FPractice) then
    Result := FPractice.Status;
end;

//------------------------------------------------------------------------------
function TProductConfigService.PracticeChanged: Boolean;
begin
  if not Assigned(FPracticeCopy) then
    Result := True
  else
    Result := not FPracticeCopy.IsEqual(FPractice);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                                                const aName : String) : integer;
var
  Index : integer;
begin
  Result := -1;
  for Index := 0 to high(aDataArray) do
  begin
    if UpperCase(aDataArray[Index].Name) = UpperCase(aName) then
    begin
      Result := Index;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetValidBConnectDetails: Boolean;
begin
  Result := FValidBConnectDetails;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddTypeItem(var aDataArray: TArrVarTypeData;
                                            var aDataItem: TVarTypeData);
begin
  SetLength(aDataArray, High(aDataArray) + 2);
  aDataArray[High(aDataArray)] := aDataItem;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddToXMLTypeNameList(const aName : String;
                                                     aTypeInfo : PTypeInfo;
                                                     var aNameList : TArrVarTypeData);
var
  TypeData : PTypeData;
  PropList : PPropList;
  Index    : integer;
  NewItem  : TVarTypeData;
begin
  TypeData := GetTypeData(aTypeInfo);

  case aTypeInfo.Kind of
    tkClass : begin
      if TypeData.PropCount > 0 then
      begin
        // Loops through all published properties of the class
        new(PropList);

        GetPropInfos(aTypeInfo, PropList);
        for Index := 0 to TypeData.PropCount-1 do
        begin
          // Recursive call for published class properties
          AddToXMLTypeNameList(PropList[Index].Name, PropList[Index].PropType^, aNameList)
        end;

        Dispose(PropList)
      end
    end;
    tkDynArray : begin
      if TypeData.elType2^.Kind in
        [tkInteger, tkChar, tkFloat, tkString, tkWChar, tkLString, tkWString, tkVariant, tkInt64] then
      begin
        //Adds the name and TypeInfo to the Name List
        NewItem.Name     := aName;
        NewItem.TypeInfo := aTypeInfo;
        AddTypeItem(aNameList, NewItem);
      end
      else
      begin
        // Recursive call for array Element Type
        AddToXMLTypeNameList('Array', TypeData.elType2^, aNameList);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.FindXMLTypeNamesToModify(const aMethodName : String;
                                                         var aNameList : TArrVarTypeData);
var
  InterfaceMetaData : TIntfMetaData;
  InterfaceIndex    : integer;
  ParamIndex        : integer;
begin
  // Gets the RTTI info for the the Interface
  GetIntfMetaData(TypeInfo(IBlopiServiceFacade), InterfaceMetaData);

  // Searches for the passed method name in the Info List
  for InterfaceIndex := 0 to high(InterfaceMetaData.MDA) do
  begin
    if InterfaceMetaData.MDA[InterfaceIndex].Name = aMethodName then
    begin
      for ParamIndex := 0 to InterfaceMetaData.MDA[InterfaceIndex].ParamCount - 1 do
      begin
        AddToXMLTypeNameList(InterfaceMetaData.MDA[InterfaceIndex].Params[ParamIndex].Name,
                             InterfaceMetaData.MDA[InterfaceIndex].Params[ParamIndex].Info,
                             aNameList);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddXMLNStoArrays(const aCurrNode : IXMLNode;
                                                 var aNameList : TArrVarTypeData);
var
  NodeIndex : integer;
  NamSpcURI : WideString;
  NamSpcPre : WideString;
  ClassName : WideString;
  NodeName  : String;
  EditIndex : integer;
  FindIndex : integer;
  Values : Array of OleVariant;
  IsScalar : Boolean;
begin
  if not Assigned(aCurrNode) then
    Exit;

  // Searches for the Node Name in the passed Name List
  FindIndex := GetTypeItemIndex(aNameList, aCurrNode.LocalName);
  if FindIndex > -1 then
  begin
    if aCurrNode.ChildNodes.Count > 0 then
    begin
      NamSpcPre := 'D5P1';
      // Gets the Name Space URI from the RemClassRegistry, this is added in the
      // Service Facade by the Auto generated code
      RemClassRegistry.InfoToURI(aNameList[FindIndex].TypeInfo, NamSpcURI, ClassName, IsScalar);
      // since it is only fixing arrays it uses the first element name as the node name
      NodeName := aCurrNode.ChildNodes[0].NodeName;

      // Saves values
      SetLength(Values, aCurrNode.ChildNodes.Count);
      for EditIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
        Values[EditIndex] := aCurrNode.ChildNodes[EditIndex].NodeValue;

      // removes all child nodes
      for EditIndex := aCurrNode.ChildNodes.Count - 1 downto 0 do
        aCurrNode.ChildNodes.Delete(EditIndex);

      // Adds the Names Space to the Array Node
      aCurrNode.DeclareNamespace(NamSpcPre, NamSpcURI);

      // ReAdds the Child nodes adding the Name Space Alias
      for EditIndex := 0 to High(Values) do
        aCurrNode.AddChild(NamSpcPre + ':' + NodeName).NodeValue := Values[EditIndex];

      SetLength(Values, 0);
    end;
  end
  else
  begin
    // Recursive call for child nodes
    for NodeIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
      AddXMLNStoArrays(aCurrNode.ChildNodes.Nodes[NodeIndex], aNameList);
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.DoBeforeExecute(const MethodName: string;
                                                var SOAPRequest: InvString);
var
  Document : IXMLDocument;
  NameList : TArrVarTypeData;
  LogXmlFile : String;
begin
  // Fills the passed Name List Array with all the XML Node Names and thier
  // TypeInfo that are arrays and need thier xml name spaces added
  FindXMLTypeNamesToModify(MethodName, NameList);

  if (high(NameList) = -1) and
     (not DebugMe) then
    Exit;

  // Loads the SoapRequest into a XML Document
  Document := NewXMLDocument;
  try
    Document.LoadFromXML(SOAPRequest);

    if not Document.IsEmptyDoc then
    begin
      // Searchs in the XML for the Node Name in the passed NameList and adds
      // the relavant namespace to the node and all elements
      AddXMLNStoArrays(Document.DocumentElement, NameList);

      Document.SaveToXML(SOAPRequest);

      if DebugMe then
      begin
        LogXmlFile := Globals.DataDir + 'Blopi_' + MethodName + '_' +
                      FormatDateTime('yyyy-mm-dd hh-mm-ss zzz', Now) + '.xml';

        Document.SaveToFile(LogXmlFile);
      end;

    end;
  finally
    Document := nil;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SetTimeOuts(ConnecTimeout : DWord ;
                                            SendTimeout   : DWord ;
                                            ReciveTimeout : DWord);
begin
  InternetSetOption(nil, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@ConnecTimeout), SizeOf(ConnecTimeout));
  InternetSetOption(nil, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@SendTimeout), SizeOf(SendTimeout));
  InternetSetOption(nil, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@ReciveTimeout), SizeOf(ReciveTimeout));
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.GetServiceAgreement(ARichEdit: TRichEdit);
var
  BlopiInterface: IBlopiServiceFacade;
  Msg: string;
  i: integer;
  ReturnMsg: MessageResponseOfstring;
  ShowProgress : Boolean;
begin
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;
    try
      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Service Agreement', 50);

      BlopiInterface := GetServiceFacade;
      ReturnMsg := BlopiInterface.GetTermsAndConditions(CountryText(AdminSystem.fdFields.fdCountry),
                                                        AdminSystem.fdFields.fdBankLink_Code,
                                                        AdminSystem.fdFields.fdBankLink_Connect_Password);
      if not MessageResponseHasError(MessageResponse(ReturnMsg), 'get the service agreement from') then
        if ReturnMsg.Result <> '' then
          ARichEdit.Text := ReturnMsg.Result;

      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do begin
      HelpfulErrorMsg('Error getting service agreement from ' + BANKLINK_ONLINE_NAME + '.',
                      0, True, E.Message, True);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceFacade: IBlopiServiceFacade;
var
  HTTPRIO: THTTPRIO;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute := DoBeforeExecute;
  Result := GetIBlopiServiceFacade(False, PRACINI_BankLink_Online_BLOPI_URL, HTTPRIO);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCatFromSub(aSubGuid : TBloGuid): TBloCatalogueEntry;
var
  i, j: integer;
begin
  Result := Nil;
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      if FPracticeCopy.Catalogue[i].id = aSubGuid then
      begin
        Result := FPracticeCopy.Catalogue[i];
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsCICOEnabled: Boolean;
var
  i, j: integer;
  Cat: TBloCatalogueEntry;
begin
  Result := False;
  if not Assigned(FPractice) then
    GetPractice;

  if Assigned(FPractice) then begin
    for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
      Cat := FPractice.Catalogue[i];
      if UpperCase(Cat.Id) = PRODUCT_GUID_CICO then begin
        for j := Low(FPractice.Subscription) to High(FPractice.Subscription) do begin
          if FPractice.Subscription[j] = Cat.Id then begin
            Result := True;
            Break;
          end;
        end;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.UpdateUserAllowOnlineSetting;
var
  AdminUserIndex : integer;
  BlopiUserIndex : integer;
  User           : pUser_Rec;
begin
  if not Assigned(AdminSystem) then
    Exit;

  if not Assigned(FPractice) then
    GetPractice;

  if Assigned(FPractice) then
  begin
    for AdminUserIndex := AdminSystem.fdSystem_User_List.First to
                          AdminSystem.fdSystem_User_List.Last do
    begin
      User := AdminSystem.fdSystem_User_List.User_At(AdminUserIndex);

      User.usAllow_Banklink_Online := False;
      for BlopiUserIndex := Low(FPractice.Users) to High(FPractice.Users) do
      begin
        if User.usCode = FPractice.Users[BlopiUserIndex].UserCode then
        begin
          User.usAllow_Banklink_Online := True;
          Break;
        end;
      end;

      if CurrUser.Code = User.usCode then
        CurrUser.AllowBanklinkOnline := User.usAllow_Banklink_Online;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetNotesId : TBloGuid;
var
  i   : integer;
  Cat : TBloCatalogueEntry;
begin
  Result := '';
  if Assigned(FPractice) then
  begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do
    begin
      Cat := FPracticeCopy.Catalogue[i];
      if UpperCase(Cat.Id) = PRODUCT_GUID_NOTES_ONLINE then
      begin
        Result := Cat.Id;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsNotesOnlineEnabled: Boolean;
var
  i       : integer;
  NotesId : TBloGuid;
begin
  Result := False;

  NotesId := GetNotesId;
  if not(NotesId = '') then
  begin
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    begin
      if FPracticeCopy.Subscription[i] = NotesId then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeActive(ShowWarning: Boolean): Boolean;
begin
  Result := not (OnlineStatus in [Suspended, Deactivated]);
  if ShowWarning then
    case OnlineStatus of
      Suspended: HelpfulWarningMsg(BANKLINK_ONLINE_NAME + ' is currently in suspended ' +
                                   '(read-only) mode. Please contact BankLink ' +
                                   'Support for further assistance.', 0);
      Deactivated: HelpfulWarningMsg(BANKLINK_ONLINE_NAME + ' is currently deactivated. ' +
                                     'Please contact BankLink Support for further ' +
                                     'assistance.', 0);
    end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeProductEnabled(AProductId: TBloGuid; AUsePracCopy : Boolean): Boolean;
var
  i: integer;
  Prac : TBloPracticeRead;
begin
  if AUsePracCopy then
    Prac := FPracticeCopy
  else
    Prac := FPractice;

  Result := False;
  if Assigned(Prac) then begin
    for i := Low(Prac.Subscription) to High(Prac.Subscription) do begin
      if Prac.Subscription[i] = AProductID then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.HasProductJustBeenUnTicked(AProductId: TBloGuid): Boolean;
begin
  // Was the Product Ticked and is it currently unticked
  Result := (IsPracticeProductEnabled(AProductId, False)) and
            (not IsPracticeProductEnabled(AProductId, True));
end;

//------------------------------------------------------------------------------
function TProductConfigService.RemotableObjectToXML(
  ARemotable: TRemotable): string;
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XMLDoc: IXMLDocument;
  XMLStr: WideString;
begin
  Result := '';
  try
    XMLDoc:= NewXMLDocument;
    NodeRoot:= XMLDoc.AddChild('Root');
    NodeParent:= NodeRoot.AddChild('Parent');
    Converter:= TSOAPDomConv.Create(NIL);
    NodeObject:= ARemotable.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                         'CopyObject', '', [ocoDontPrefixNode],
                                         XMLStr);
    Result := XMLDoc.XML.Text;
  except
    on E:Exception do HelpfulErrorMsg('Error converting remotable object to text: ' + E.Message, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.RemoveInvalidSubscriptions;
var
  i, j: integer;
  GuidList: TStringList;
  Found: Boolean;
begin
  GuidList := TStringList.Create;
  try
    //Remove any subscriptions that aren't in the catalogue
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
      Found := False;
      for j := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
        if FPracticeCopy.Subscription[i] = FPracticeCopy.Catalogue[j].Id then
          Found := True;
      end;
      if not Found then
        GuidList.Add(FPracticeCopy.Subscription[i]);
    end;
    for i  := 0 to GuidList.Count - 1 do
      RemoveProduct(GuidList[i]);
  finally
    GuidList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.RemoveProduct(AProductId: TBloGuid);
var
  i, j: integer;
  SubArray: TBloArrayOfGuid;
  ClientsUsingProduct: integer;
  Msg: string;
  TempCatalogueEntry: TBloCatalogueEntry;
begin
  try
    if not Assigned(FClientList) then
      LoadClientList;

    if not Assigned(FClientList) then
      raise Exception.Create('Error getting client detials from ' + BANKLINK_ONLINE_NAME);

    ClientsUsingProduct := 0;
    //Check if any clients are using the product
    for i := Low(FClientList.Clients) to High(FClientList.Clients) do begin
      for j := Low(FClientList.Clients[i].Subscription) to High(FClientList.Clients[i].Subscription) do begin
        if (FClientList.Clients[i].Status <> Deactivated) and (AProductId = FClientList.Clients[i].Subscription[j]) then
          Inc(ClientsUsingProduct);
      end;
    end;

    TempCatalogueEntry := GetCatalogueEntry(AProductId);
    if Assigned(TempCatalogueEntry) then begin
      if ClientsUsingProduct > 0 then begin
        if ClientsUsingProduct = 1 then
          Msg := Format('There is currently 1 client using %s. Please remove ' +
                        'access for this clients from this product before ' +
                        'disabling it',
                        [TempCatalogueEntry.Description])
        else
          Msg := Format('There are currently %d clients using %s. Please remove ' +
                        'access for these clients from this product before ' +
                        'disabling it',
                        [ClientsUsingProduct, TempCatalogueEntry.Description]);
        HelpfulWarningMsg(MSg, 0);
        Exit;
      end;
    end;

    SubArray := FPracticeCopy.Subscription;
    try
      for i := Low(SubArray) to High(SubArray) do begin
        if AProductId = SubArray[i] then begin
          if (i < 0) or (i > High(SubArray)) then
            Break;
          for j := i to High(SubArray) - 1 do begin
            SubArray[j] := SubArray[j+1];
          end;
          SubArray[High(SubArray)] := '';
          SetLength(SubArray, Length(SubArray) - 1);
          Break;
        end;
      end;
    finally
      FPracticeCopy.Subscription := SubArray;
    end;
  except
    on E: Exception do begin
      HelpfulErrorMsg('Product could not be removed: ' + E.Message, 0);
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SaveClient(AClient: TBloClientReadDetail): Boolean;
var
  i: integer;
  Msg: string;
  BlopiInterface: IBlopiServiceFacade;
  MsgResponse: MessageResponse;
  MsgResponseOfGuid: MessageResponseOfGuid;
  MyClientUpdate: ClientUpdate;
  ShowProgress : Boolean;
  BlankSubscription: TBloArrayOfGuid;

  MyUserRead   : TBloUserRead;
  MyUserUpdate : TBloUserUpdate;
  MyUserCreate : TBloUserCreate;
begin
  Result := False;

  if not Assigned(AdminSystem) then
    Exit;

  if not Registered then
    Exit;

  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
    end;

    try
      MyClientUpdate := ClientUpdate.Create;
      try
        //Save client
        MyClientUpdate.Id := AClient.Id;
        MyClientUpdate.ClientCode := AClient.ClientCode;
        MyClientUpdate.Name_ := AClient.Name_;
        MyClientUpdate.Status := AClient.Status;
        MyClientUpdate.Subscription := AClient.Subscription;
        MyClientUpdate.BillingFrequency := AClient.BillingFrequency;
        MyClientUpdate.MaxOfflineDays := AClient.MaxOfflineDays;
        MyClientUpdate.PrimaryContactUserId := AClient.Users[0].Id;

        BlopiInterface := GetServiceFacade;

        //Save client admin user
        if (Length(AClient.Users) > 0) then
        begin
          MyUserRead := AClient.Users[0];
          if MyUserRead.Id = '' then
          begin
            if ShowProgress then
              Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Creating Client User', 30);

            //Create new client admin user
            MyUserCreate := TBloUserCreate.Create;
            try
              MyUserCreate.FullName := MyUserRead.FullName;
              MyUserCreate.EMail    := MyUserRead.EMail;
              MyUserCreate.AddRoleName('Client Administrator');
              MyUserCreate.UserCode := '';
              SetLength(BlankSubscription, 0);
              MyUserCreate.Subscription := BlankSubscription;

              MsgResponseOfGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                             AdminSystem.fdFields.fdBankLink_Code,
                                                             AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                             AClient.Id,
                                                             MyUserCreate);
              if not MessageResponseHasError(MsgResponseOfGuid, 'create the client user on') then
                MyClientUpdate.PrimaryContactUserId := MsgResponseOfGuid.Result;
            finally
              FreeAndNil(MyUserCreate);
            end;
          end else
          begin
            //Update existing client admin user
            if ShowProgress then
              Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Updating Client User', 30);

            //Create new client admin user
            MyUserUpdate := TBloUserUpdate.Create;
            try
              MyUserUpdate.FullName     := MyUserRead.FullName;
              MyUserUpdate.Id           := MyUserRead.Id;
              MyUserUpdate.RoleNames    := MyUserRead.RoleNames;
              MyUserUpdate.UserCode     := MyUserRead.UserCode;
              MyUserUpdate.Subscription := MyUserRead.Subscription;

              MsgResponse := BlopiInterface.SaveclientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                         AdminSystem.fdFields.fdBankLink_Code,
                                                         AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                         AClient.Id,
                                                         MyUserUpdate);
              MessageResponseHasError(MsgResponse, 'update this client user on');
            finally
              FreeAndNil(MyUserUpdate);
            end;
          end;
        end;

        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Updating Client', 50);
        MsgResponse := BlopiInterface.SaveClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                 AdminSystem.fdFields.fdBankLink_Code,
                                                 AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                 MyClientUpdate);
        MessageResponseHasError(MsgResponse, 'update this client''s settings on');

        Result := True;

        if ShowProgress then
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);

        Msg := Format('Settings for %s have been successfully updated to ' +
                      '%s.',[AClient.ClientCode, BANKLINK_ONLINE_NAME]);
        HelpfulInfoMsg(Msg, 0);
        LogUtil.LogMsg(lmInfo, UNIT_NAME, Msg);
      finally
        FreeAndNil(MyClientUpdate);
      end;
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E: Exception do
      HelpfulErrorMsg(Msg, 0);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SavePractice: Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
begin
  Result := False;
  if UseBankLinkOnline then begin
    if Assigned(FPracticeCopy) then begin
      FPractice.Free;
      FPractice := PracticeRead.Create;

      PracUpdate := PracticeUpdate.Create;
      try
        RemoveInvalidSubscriptions;
        CopyRemotableObject(FPracticeCopy, FPractice);
        CopyRemotableObject(FPractice, PracUpdate);

        //Save to the web service
        Screen.Cursor := crHourGlass;
        Progress.StatusSilent := False;
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
        try
          PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
          PracCode        := AdminSystem.fdFields.fdBankLink_Code;
          PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

          BlopiInterface := GetServiceFacade;

          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Saving Practice Details', 33);

          MsgResponce := BlopiInterface.SavePractice(PracCountryCode, PracCode, PracPassHash, PracUpdate);
          if not MessageResponseHasError(MsgResponce, 'update the Practice settings to') then
          begin
            Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Saving Practice Details to System Database', 66);
            Result := True;
            Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
          end;

        finally
          Progress.StatusSilent := True;
          Progress.ClearStatus;
          Screen.Cursor := crDefault;
        end;

      finally
        FreeandNil(PracUpdate);
      end;

      if not Result then
        HelpfulErrorMsg(BKPRACTICENAME + ' is unable to update the Practice settings to ' + BANKLINK_ONLINE_NAME + '.', 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SavePracticeDetailsToSystemDB(ARemotable: TRemotable);
begin
  if not Assigned(AdminSystem) then
    Exit;

  AdminSystem.fdFields.fdBankLink_Online_Config := RemotableObjectToXML(ARemotable);
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SaveRemotableObjectToFile(ARemotable: TRemotable);
var
  XMLDoc: IXMLDocument;
begin
  XMLDoc:= NewXMLDocument;
  XMLDoc.LoadFromXML(RemotableObjectToXML(ARemotable));
  XMLDoc.SaveToFile(ARemotable.ClassName + '.xml');
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SelectAllProducts;
var
  i: integer;
  Cat: TBloCatalogueEntry;
  SubArray: TBloArrayOfGuid;
begin
  SubArray := FPracticeCopy.Subscription;
  try
    SetLength(SubArray, Length(FPracticeCopy.Catalogue));
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      Cat := FPracticeCopy.Catalogue[i];
      SubArray[i] := Cat.Id;
    end;
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SetPrimaryContact(AUser: TBloUserRead);
begin
  FPracticeCopy.DefaultAdminUserId := AUser.Id;
end;

{ TClientHelper }
//------------------------------------------------------------------------------
function TClientHelper.GetClientConnectDays: string;
begin
  Result := '90';
end;

//------------------------------------------------------------------------------
function TClientHelper.GetDeactivated: boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TClientHelper.GetFreeTrialEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

//------------------------------------------------------------------------------
function TClientHelper.GetSuspended: boolean;
begin
  Result := (Self.Status = BlopiServiceFacade.Suspended);
end;

//------------------------------------------------------------------------------
function TClientHelper.GetUserOnTrial: boolean;
begin
  Result := false;
end;

//------------------------------------------------------------------------------
procedure TClientHelper.UpdateAdminUser(AUserName, AEmail: WideString);
var
  UserArray : ArrayOfUserRead;
  RoleArray : TBloArrayOfString;
  NewUser   : TBloUserRead;
begin
  //Should only be one client admin user
  if Length(Self.Users) = 0 then begin
    //Add
    NewUser := TBloUserRead.Create;
    UserArray := Self.Users;
    try
      SetLength(UserArray, Length(Self.Users) + 1);
      Self.Users := UserArray;
      Self.Users[0] := NewUser;
      RoleArray := NewUser.RoleNames;
      try
        SetLength(RoleArray, Length(NewUser.RoleNames) + 1);
        RoleArray[0] := 'Client Administrator';
      finally
        NewUser.RoleNames := RoleArray;
      end;
    finally
      Self.Users := UserArray;
    end;
  end;
  //Update
  User(Self.Users[0]).FullName := AUserName;
  //User(Self.Users[0]).EMail := AEmail;  // Email Removed from Service Client User Array
end;

//------------------------------------------------------------------------------
function TUserDetailHelper.AddRoleName(RoleName: string): Boolean;
var
  RoleArray: ArrayOfstring;
  NewRole: Role;
  i: integer;

begin
  Result := False;
  for i := Low(RoleNames) to High(RoleNames) do
    if (RoleNames[i] = RoleName) then
      Exit;

  RoleArray := RoleNames;
  try
    SetLength(RoleArray, Length(RoleArray) + 1);
    RoleArray[High(RoleArray)] := RoleName;
    Result := True;
  finally
    RoleNames := RoleArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.AddSubscription(AProductID: TBloGuid) : Boolean;
var
  SubArray: TBloArrayOfGuid;
  i: integer;
begin
  Result := False;
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
    Result := True;
  finally
    Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.RemoveSubscription(AProductID: TBloGuid) : Boolean;
var
  SubArray: TBloArrayOfGuid;
  i: integer;
  FoundIndex : integer;
begin
  Result := False;
  FoundIndex := -1;
  // Try Find Product to Remove
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      FoundIndex := i;

  if FoundIndex > -1 then
  begin
    SubArray := Subscription;

    // Move Items after Found Item all one back
    if FoundIndex < High(SubArray) then
    begin
      for i := (FoundIndex+1) to High(SubArray) do
        SubArray[i-1] := SubArray[i];
    end;

    // Remove Last item
    SetLength(SubArray, Length(SubArray) - 1);
    Result := True;

    Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.GetStatusString: string;
begin
  case self.Status of
    Active: Result := 'Active';
    Suspended: Result := 'Suspended';
    Deactivated: Result := 'Deactivated';
    else Result := '';
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.HasSubscription(AProductID: TBloGuid) : Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := Low(Subscription) to High(Subscription) do
  begin
    if (Subscription[i] = AProductID) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsUserCreatedOnBankLinkOnline(const APractice : TBloPracticeRead;
                                                             const AUserId   : TBloGuid   = '';
                                                             const AUserCode : string = '') : Boolean;
var
  UserIndex : Integer;
begin
  Result := False;

  // Goes through passed through Practice users and finds the first one with either
  // a matching TBloGuid or Code
  for UserIndex := 0 to High(APractice.Users) do
  begin
    if (APractice.Users[UserIndex].Id       = AUserId)
    or (APractice.Users[UserIndex].UserCode = AUserCode) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddEditPracUser(var   aUserId         : TBloGuid;
                                               const aEMail          : WideString;
                                               const aFullName       : WideString;
                                               const aUserCode       : WideString;
                                               const aUstNameIndex   : integer;
                                               var   aIsUserCreated  : Boolean;
                                               const aChangePassword : Boolean;
                                               const aPassword       : WideString) : Boolean;
var
  UpdateUser      : TBloUserUpdatePractice;
  CreateUser      : TBloUserCreatePractice;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  MsgResponceGuid : MessageResponseOfGuid;
  ErrMsg          : String;
  CurrPractice    : TBloPracticeRead;
  IsUserOnline    : Boolean;
  BlopiInterface  : IBlopiServiceFacade;
  RoleNames       : TBloArrayOfString;
begin
  Result := false;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);

  try
    PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
    PracCode        := AdminSystem.fdFields.fdBankLink_Code;
    PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

    try
      // Does the User Already Exist on BankLink Online?
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Recieving Data', 33);
      CurrPractice := GetPractice(true, true);
      if OnLine then
      begin
        IsUserOnline := IsUserCreatedOnBankLinkOnline(CurrPractice, aUserId, aUserCode);

        SetLength(RoleNames,1);
        RoleNames[0] := CurrPractice.GetRoleFromPracUserType(aUstNameIndex, CurrPractice).RoleName;

        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data', 66);
        BlopiInterface := GetServiceFacade;

        if IsUserOnline then
        begin
          if aUserId = '' then
            aUserId := GetPracUserGuid(aUserCode, CurrPractice);

          UpdateUser := TBloUserUpdatePractice.Create;
          // UpdateUser.EMail        := aEMail;  // Email Removed for Service Pratice User
          UpdateUser.FullName     := aFullName;
          UpdateUser.Id           := aUserId;
          UpdateUser.RoleNames    := RoleNames;
          UpdateUser.Subscription := CurrPractice.Subscription;
          UpdateUser.UserCode     := aUserCode;

          MsgResponce := BlopiInterface.SavePracticeUser(PracCountryCode, PracCode, PracPassHash, UpdateUser);
          if not MessageResponseHasError(MsgResponce, 'update practice user on') then
          begin
            Result := MsgResponce.Success;

            if aChangePassword then
            begin
              Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data', 88);
              Result := ChangePracUserPass(aUserCode, aPassword, CurrPractice);
            end;

            if Result then
            begin
              aIsUserCreated := false;
              Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
              LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' has been successfully updated to BankLink Online.');
            end
            else
              LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not updated to BankLink Online.');
          end;
        end
        else
        begin
          CreateUser := TBloUserCreatePractice.Create;
          CreateUser.EMail        := aEMail;
          CreateUser.FullName     := aFullName;
          CreateUser.RoleNames    := RoleNames;
          CreateUser.Subscription := CurrPractice.Subscription;
          CreateUser.UserCode     := aUserCode;

          if aChangePassword then
            CreateUser.Password := aPassword
          else
            CreateUser.Password := '';

          MsgResponceGuid := BlopiInterface.CreatePracticeUser(PracCountryCode, PracCode, PracPassHash, CreateUser);
          if not MessageResponseHasError(MessageResponse(MsgResponceGuid), 'create practice user on') then begin
            Result  := True;
            aUserId := MsgResponceGuid.Result;
            aIsUserCreated := True;
            Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
            LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' has been successfully created on BankLink Online.');
          end
          else
            LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not created on BankLink Online.');
        end;
      end
      else
      begin
        if aIsUserCreated then
          LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not created on BankLink Online.')
        else
          LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not updated to BankLink Online.');
      end;
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running AddEditPracUser, Error Message : ' + E.Message);
        raise Exception.Create(BKPRACTICENAME + ' was unable to connect to ' + BANKLINK_ONLINE_NAME + '.' + #13#13 + E.Message );
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.DeletePracUser(const aUserCode : string;
                                              const aUserGuid : string;
                                              aPractice : TBloPracticeRead) : Boolean;
var
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  ErrMsg          : String;
  BlopiInterface  : IBlopiServiceFacade;
  UserGuid        : TBloGuid;
begin
  Result := false;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);

  try
    try
      BlopiInterface  := GetServiceFacade;
      PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
      PracCode        := AdminSystem.fdFields.fdBankLink_Code;
      PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

      if not Assigned(aPractice) then
        aPractice := GetPractice;

      if Online then
      begin
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data', 50);
        if aUserCode = '' then
          UserGuid := aUserGuid
        else
          UserGuid := GetPracUserGuid(aUserCode, aPractice);

        if not (UserGuid = '') then
        begin
          MsgResponce := BlopiInterface.DeleteUser(PracCountryCode, PracCode, PracPassHash, UserGuid);

          if not MessageResponseHasError(MsgResponce, 'delete practice user on') then
            Result := MsgResponce.Success;
        end
        else
          Result := True;
      end;

      if Result then
      begin
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
        LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' has been successfully deleted from BankLink Online.');
      end
      else
        LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not deleted from BankLink Online.');
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running DeletePracUser, Error Message : ' + E.Message);
        raise Exception.Create(BKPRACTICENAME + ' was unable to connect to ' + BANKLINK_ONLINE_NAME + '.' + #13#13 + E.Message );
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPrimPracUser(const aUserCode : string;
                                              aPractice : TBloPracticeRead): Boolean;
begin
  if aUserCode = '' then
  begin
    Result := false;
    Exit;
  end;

  if not Assigned(aPractice) then
    aPractice := GetPractice(true);

  Result := (GetPracUserGuid(aUserCode, aPractice) = aPractice.DefaultAdminUserId);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPracUserGuid(const aUserCode : string;
                                               aPractice : TBloPracticeRead): TBloGuid;
var
  i: integer;
  TempUser: TBloUserRead;
begin
  Result := '';

  for i := Low(aPractice.Users) to High(aPractice.Users) do
  begin
    TempUser := aPractice.Users[i];
    if TempUser.UserCode = AUserCode then begin
      Result := TempUser.Id;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ChangePracUserPass(const aUserCode : WideString;
                                                  const aPassword : WideString;
                                                  aPractice : TBloPracticeRead) : Boolean;
var
  MsgResponce     : MessageResponse;
  UserGuid        : WideString;
  BlopiInterface  : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  ShowProgress    : Boolean;
begin
  Result := false;

  ShowProgress := Progress.StatusSilent;
  if ShowProgress then
  begin
    Screen.Cursor := crHourGlass;
    Progress.StatusSilent := False;
    Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);
  end;

  try
    BlopiInterface  := GetServiceFacade;
    PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
    PracCode        := AdminSystem.fdFields.fdBankLink_Code;
    PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

    if not Assigned(aPractice) then
    begin
      if ShowProgress then
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data', 40);
      aPractice := GetPractice;
    end;

    if ShowProgress then
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data', 60);

    UserGuid := GetPracUserGuid(aUserCode, aPractice);
    MsgResponce := BlopiInterface.SetPracticeUserPassword(PracCountryCode, PracCode, PracPassHash, UserGuid, aPassword);

    if not MessageResponseHasError(MsgResponce, 'change practice user password on') then begin
      Result := MsgResponce.Success;
      if ShowProgress then
      begin
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finished', 100);
        LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' password has been successfully changed on BankLink Online.');
      end;
    end;

  finally
    if ShowProgress then
    begin
      Progress.StatusSilent := True;
      Progress.ClearStatus;
      Screen.Cursor := crDefault;
    end;
  end;
end;

{ TPracticeHelper }
//------------------------------------------------------------------------------
function TPracticeHelper.GetUserRoleGuidFromPracUserType(aUstNameIndex: integer;
                                                         aInstance: PracticeRead): Guid;
begin
  Result := '';
  if (aUstNameIndex < ustMin)
  or (aUstNameIndex > ustMax) then
    raise Exception.Create('Practice User Type does not exist in the Admin System.');

  if High(aInstance.Roles) < 1 then
    raise Exception.Create('Get Practice Roles returned no role information.');

  case aUstNameIndex of
                            // Accountant Practice Standard User
    ustRestricted : Result := aInstance.Roles[1].id;
                            // Accountant Practice Standard User
    ustNormal     : Result := aInstance.Roles[1].id;
                            // Accountant Practice Administrator
    ustSystem     : Result := aInstance.Roles[0].id;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.IsEqual(Instance: PracticeRead): Boolean;
var
  i: integer;
begin
  Result := False;
  if not Assigned(Instance) then Exit;

  Result :=
    (DefaultAdminUserId = Instance.DefaultAdminUserId) and
    (DisplayName = Instance.DisplayName) and
    (DomainName = Instance.DomainName) and
    (EMail = Instance.EMail) and
    (Phone = Instance.Phone) and
    (Status = Instance.Status);

  //Compare users (shouldn't change)
  if Result then begin
    Result := (High(Users) = High(Instance.Users));
    if Result then begin
      for i := Low(Users) to High(Users) do begin
        if Users[i].Id <> Instance.Users[i].Id then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;

  //Catalogue can't be changed so no need to compare

  //Compare Roles
  if Result then begin
    Result := (High(Roles) = High(Instance.Roles));
    if Result then begin
      for i := Low(Roles) to High(Roles) do begin
        if Roles[i].Id <> Instance.Roles[i].Id then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;

  //Compare subscriptions
  if Result then begin
    Result := (High(Subscription) = High(Instance.Subscription));
    if Result then begin
      for i := Low(Subscription) to High(Subscription) do begin
        if Subscription[i] <> Instance.Subscription[i] then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.GetRoleFromPracUserType(aUstNameIndex: integer;
                                                 aInstance: PracticeRead): Role;
var
  RoleGuid : TBloGuid;
  RoleIndex : integer;
begin
  Result := Nil;
  RoleGuid := GetUserRoleGuidFromPracUserType(aUstNameIndex, aInstance);

  for RoleIndex := 0 to High(Self.Roles) do
  begin
    if (Self.Roles[RoleIndex].Id = RoleGuid) then
    begin
      Result := Self.Roles[RoleIndex];
      Exit;
    end;
  end;

  raise Exception.Create('Practice User Role does not exist on ' + BANKLINK_ONLINE_NAME + '.');
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UNIT_NAME);

end.






