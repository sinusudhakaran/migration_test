unit BankLinkOnlineServices;

interface

uses
  Forms,
  BlopiServiceFacade,
  InvokeRegistry,
  Windows,
  XMLIntf,
  TypInfo,
  Classes;

type
  TBanklinkOnlineStatus = (bosActive, bosSuspended, bosDeactivated);

  Guid                  = BlopiServiceFacade.Guid;
  ArrayOfString         = BlopiServiceFacade.ArrayOfString;
  Practice              = BlopiServiceFacade.Practice;
  Client                = BlopiServiceFacade.Client;
  User                  = BlopiServiceFacade.User;
  CatalogueEntry        = BlopiServiceFacade.CatalogueEntry;
  ArrayOfCatalogueEntry = BlopiServiceFacade.ArrayOfCatalogueEntry;
  ArrayOfGuid           = BlopiServiceFacade.ArrayOfguid;
  
  TVarTypeData = record
    Name     : String;
    TypeInfo : PTypeInfo;
  end;

  TArrVarTypeData = Array of TVarTypeData;

  TClientHelper = Class helper for BlopiServiceFacade.Client
  private
    function GetDeactivated: boolean;
    function GetClientConnectDays: string;
    function GetFreeTrialEndDate: TDateTime;
    function GetBillingEndDate: TDateTime;
    function GetUserOnTrial: boolean;
    function GetBillingFrequency: string;
    function GetUseClientDetails: boolean;
    function GetUserName: string;
    function GetEmailAddress: string;
    function GetSuspended: boolean;
  public
    procedure AddSubscription(AProductID: guid);
    property Deactivated: boolean read GetDeactivated;
    property ClientConnectDays: string read GetClientConnectDays; // 0 if client must always be online
    property FreeTrialEndDate: TDateTime read GetFreeTrialEndDate;
    property BillingEndDate: TDateTime read GetBillingEndDate;
    property UserOnTrial: boolean read GetUserOnTrial;
    property BillingFrequency: string read GetBillingFrequency;
    property UseClientDetails: boolean read GetUseClientDetails;
    property UserName: string read GetUserName;
    property EmailAddress: string read GetEmailAddress;
    property Suspended: boolean read GetSuspended;
  End;

  TPracticeHelper = Class helper for Practice
  private
    function GetUserRoleGuidFromPracUserType(aUstNameIndex : integer) : Guid;
  public
    function GetRoleFromPracUserType(aUstNameIndex : integer) : Role;
  End;

  TClientSummaryHelper = Class helper for BlopiServiceFacade.ClientSummary
  public
    procedure AddSubscription(AProductID: guid);
  End;

  TProductConfigService = class(TObject)
  private
    fMethodName: string;
    fSOAPRequest: InvString;

    FPractice, FPracticeCopy: Practice;
    FRegisteredForBankLinkOnline: boolean;
    FClientList: ClientList;
    FClient, FClientCopy: Client;
    FOnLine: Boolean;
    FRegistered: Boolean;
    FArrNameSpaceList : Array of TRemRegEntry;

    procedure LoadDummyPractice;
    procedure CopyRemotableObject(ASource, ATarget: TRemotable);

    function IsUserCreatedOnBankLinkOnline(const APractice : Practice;
                                           const AUserId   : Guid   = '';
                                           const AUserCode : string = ''): Boolean;
    function GetErrorMessage(aErrorMessages : ArrayOfServiceErrorMessage;
                             aExceptions    : ArrayOfExceptionDetails) : string;

    function GetUseBankLinkOnline: Boolean;
    procedure SetUseBankLinkOnline(const Value: Boolean);
    function RemotableObjectToXML(ARemotable: TRemotable): string;
    procedure LoadRemotableObjectFromXML(const XML: string; ARemotable: TRemotable);
    procedure SaveRemotableObjectToFile(ARemotable: TRemotable);
    function LoadPracticeDetailsfromSystemDB: Boolean;
    procedure SavePracticeDetailsToSystemDB;
    function LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
    procedure SetRegisteredForBankLinkOnline(const Value: Boolean);
    procedure LoadDummyClientList;
    procedure LoadClientList;
    function OnlineStatus: TBankLinkOnlineStatus;
    function GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                              aName : String) : integer;
    procedure AddTypeItem(var aDataArray : TArrVarTypeData;
                          var aDataItem  : TVarTypeData);
    procedure AddToXMLTypeNameList(aName : String;
                                   aTypeInfo : PTypeInfo;
                                   var aNameList : TArrVarTypeData);
    procedure FindXMLTypeNamesToModify(aMethodName : String;
                                       var aNameList : TArrVarTypeData);
    procedure AddXMLNStoArrays(aCurrNode : IXMLNode;
                               var aNameList : TArrVarTypeData);
    procedure DoBeforeExecute(const MethodName: string;
                              var SOAPRequest: InvString);
    procedure SetTimeOuts(ConnecTimeout : DWord ;
                          SendTimeout   : DWord ;
                          ReciveTimeout : DWord);
    function GetServiceFacade : IBlopiServiceFacade;  
  public
    constructor Create;
    destructor Destroy; override;
    //Practice methods
    function GetPractice: Practice;
    function IsPracticeActive(ShowWarning: Boolean = true): Boolean;
    function GetCatalogueEntry(AProductId: Guid): CatalogueEntry;
    function IsPracticeProductEnabled(AProductId: Guid): Boolean;
    function IsNotesOnlineEnabled: Boolean;
    function IsCICOEnabled: Boolean;
    function SavePractice: Boolean;
    procedure AddProduct(AProductId: Guid);
    procedure ClearAllProducts;
    procedure RemoveProduct(AProductId: Guid);
    procedure SelectAllProducts;
    procedure SetPrimaryContact(AUser: User);
    property UseBankLinkOnline: Boolean read GetUseBankLinkOnline write SetUseBankLinkOnline;
    //Client methods
    function AddClient: ClientSummary;
    function GetClientDetails(ClientID: WideString): Client;
    function LoadClientDetails(ClientID: WideString): Boolean;
    property Clients: ClientList read FClientList;
    //User methods
    function UpdateCreateUser(var   aUserId        : Guid;
                              const aEMail         : WideString;
                              const aFullName      : WideString;
                              const aUserCode      : WideString;
                              const aUstNameIndex  : integer;
                              var   aIsUserCreated : Boolean ) : Boolean;
    function DeleteUser(aUserCode: string;
                        aPractice : Practice = nil): Boolean;
    function IsPrimaryUser(aUserCode: string = '';
                           aPractice : Practice = nil): Boolean;
    function GetUserGuid(AUserCode: string;
                         APractice : Practice): Guid;
    function ChangeUserPassword(const aUserCode: string;
                                const aOldPassword : string;
                                const aNewPassword : string) : Boolean;
    property OnLine: Boolean read FOnLine;
    property Registered: Boolean read FRegistered;
  end;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

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
  ObjAuto;

const
  UNIT_NAME = 'BankLinkOnlineServices';
  INIFILE_NAME = 'BankLinkOnline.ini';

var
  __BankLinkOnlineServiceMgr: TProductConfigService;

function ProductConfigService: TProductConfigService;
begin
  if not Assigned(__BankLinkOnlineServiceMgr) then
    __BankLinkOnlineServiceMgr := TProductConfigService.Create;
  Result := __BankLinkOnlineServiceMgr;
end;

{ TProductConfigService }

procedure TProductConfigService.AddProduct(AProductId: Guid);
var
  i: integer;
  SubArray: ArrayOfGuid;
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

procedure TProductConfigService.ClearAllProducts;
var
  i: integer;
  SubArray: ArrayOfGUID;
begin
  SubArray := FPracticeCopy.Subscription;
  try
    //Free subscription GUID's
    for i := Low(SubArray) to High(SubArray) do
      //Make sure no memory is left allocated
      SubArray[i] := '';
    SetLength(SubArray, 0);
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

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

constructor TProductConfigService.Create;
var
  BlopiClientList: MessageResponseOfClientListMIdCYrSK;
begin
  //Create practice
  FPractice := Practice.Create;
  //Load Practice
  GetPractice;
  //Create clients
  // LoadDummyClientList;
  FClientList := ClientList.Create;
  LoadClientList;
end;

destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FPracticeCopy.Free;
  FPractice.Free;
  inherited;
end;

function TProductConfigService.GetCatalogueEntry(
  AProductId: Guid): CatalogueEntry;
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

function TProductConfigService.GetClientDetails(ClientID: WideString): Client;
var
  i: integer;
  ClientArray: ArrayOfClientSummary;
begin
  Result := nil;
  ClientArray := FClientList.Clients;
  for i := Low(ClientArray) to High(ClientArray) do
  begin
    if (ClientID = ClientArray[i].Id) then
    begin
      try
        LoadClientDetails(ClientID);
        FClientCopy.Free;
        FClientCopy := Client.Create;
        CopyRemotableObject(FClient, FClientCopy);
        Result := FClientCopy;
      except
        on E : Exception do
          raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
      end;
      break;
    end;
  end;
end;

function TProductConfigService.LoadClientDetails(ClientID: WideString): Boolean;
var
  BlopiInterface: IBlopiServiceFacade;
  ClientDetailResponse: MessageResponseOfClientMIdCYrSK;
  i: integer;
  Msg: string;
begin
  Result := False;
  if not Assigned(AdminSystem) then
    Exit;

  if not FRegistered then
    Exit;

  if UseBankLinkOnline then begin
    //Reload from BankLink Online
    if AdminSystem.fdFields.fdLast_BankLink_Online_Update < (StDate.CurrentDate + 1) then begin
      // Live
      try
        BlopiInterface := GetServiceFacade;
        ClientDetailResponse := BlopiInterface.GetClientDetail(CountryText(AdminSystem.fdFields.fdCountry),
                                AdminSystem.fdFields.fdBankLink_Code,
                                AdminSystem.fdFields.fdBankLink_Connect_Password, ClientID);
        if Assigned(ClientDetailResponse) then begin
          Result := Assigned(ClientDetailResponse.Result);
          if Result then
            FClient := ClientDetailResponse.Result
          else begin
            // Something went wrong
            Msg := '';
            for i := Low(ClientDetailResponse.ErrorMessages) to High(ClientDetailResponse.ErrorMessages) do
              Msg := Msg + ServiceErrorMessage(ClientDetailResponse.ErrorMessages[i]).Message_;
            raise Exception(Msg);
          end;
        end;
      except
        on E: Exception do HelpfulErrorMsg('Error geting practice details from BankLink Online: ' + E.Message, 0);
      end;
      if not Result  then
        if LoadRemotableObjectFromFile(FClient) then begin //This represents FClient from BankLink Online
          Result := True;
      end;
      //Load from System DB
      if not Result then
        Result := LoadPracticeDetailsfromSystemDB; //This is the local copy of FPractice
      if not Result then begin
        LoadDummyPractice; //This load FPractice with dummy data
        Result := True;
      end;
    end else
      Result := LoadPracticeDetailsfromSystemDB; //This is the local copy of FPractice
  end;
end;

function TProductConfigService.GetPractice: Practice;
var
  i: integer;
  BlopiInterface: IBlopiServiceFacade;
  PracticeDetailResponse: MessageResponseOfPracticeMIdCYrSK;
  Msg: string;
begin
  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 40);
  try
    try
      if Assigned(AdminSystem) then begin
        //Load cached practice details if they are registered or not
        Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Practice Details', 50);
        FRegistered := True;
        try
          if LoadPracticeDetailsfromSystemDB then
            Result := FPractice;
        finally
          FRegistered := False;
        end;
        //try to load practice details from BankLink Online
        FOnLine := False;
        if UseBankLinkOnline then begin
          //Reload from BankLink Online
          BlopiInterface := GetIBlopiServiceFacade;
          PracticeDetailResponse := BlopiInterface.GetPracticeDetail(CountryText(AdminSystem.fdFields.fdCountry),
          AdminSystem.fdFields.fdBankLink_Code, AdminSystem.fdFields.fdBankLink_Connect_Password);
          if Assigned(PracticeDetailResponse) then begin
            FOnLine := True;
            if Assigned(PracticeDetailResponse.Result) then begin
              AdminSystem.fdFields.fdLast_BankLink_Online_Update := stDate.CurrentDate;
              FPractice := PracticeDetailResponse.Result;
              FRegistered := True;
            end else begin
              //Something went wrong
              Msg := '';
              for i := Low(PracticeDetailResponse.ErrorMessages) to High(PracticeDetailResponse.ErrorMessages) do
                Msg := Msg + ServiceErrorMessage(PracticeDetailResponse.ErrorMessages[i]).Message_;
              if Msg = 'Invalid BConnect Credentials' then begin
                //Clear the cached practice details if not registered for this practice code
                FPractice.Free;
                FPractice := Practice.Create;
                AdminSystem.fdFields.fdBankLink_Online_Config := '';
                AdminSystem.fdFields.fdUse_BankLink_Online := False;
                LoadPracticeDetailsfromSystemDB;
                FRegistered := False;
              end else
                raise Exception.Create(Msg);
            end;
          end;
        end;
      end;
      //Make a copy for editing
      FreeAndNil(FPracticeCopy);
      FPracticeCopy := Practice.Create;
      CopyRemotableObject(FPractice, FPracticeCopy);
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Getting Practice Details', 100);
      Result := FPracticeCopy;
    except
      on E: Exception do
        HelpfulErrorMsg('BankLink Practice is unable to connect to BankLink ' +
                        'Online: ' + #13#13 + E.Message, 0);
    end;
  finally
     Progress.StatusSilent := True;
     Progress.ClearStatus;
     Screen.Cursor := crDefault;
  end;
end;

function TProductConfigService.GetUseBankLinkOnline: Boolean;
begin
  Result := False;
  if Assigned(AdminSystem) then
    Result := AdminSystem.fdFields.fdUse_BankLink_Online;
end;

function TProductConfigService.GetUserGuid(AUserCode: string;
                                           aPractice : Practice): Guid;
var
  i: integer;
  TempUser: User;
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

function TProductConfigService.AddClient: ClientSummary;
var
  SubArray: ArrayOfGuid;
  Guid1: TGuid;
  ClientArray: ArrayOfClientSummary;
begin
  ClientArray := FClientList.Clients;
  try
    SetLength(ClientArray, Length(ClientArray) + 1);
    ClientArray[High(ClientArray)] := ClientSummary.Create;
    CreateGUID(Guid1);
    ClientArray[High(ClientArray)].Id := GuidToString(Guid1);
    // ClientArray[High(ClientArray)].Subscription := SubArray;
  finally
     FClientList.Clients := ClientArray;
  end;
  Result := FClientList.Clients[High(FClientList.Clients)];
end;

procedure TProductConfigService.LoadClientList;
var
  BlopiInterface: IBlopiServiceFacade;
  BlopiClientList: MessageResponseOfClientListMIdCYrSK;
  Msg: string;
  i: integer;
begin
  FClientList.Free;
  FClientList := ClientList.Create;
  if UseBankLinkOnline then begin
		BlopiInterface := GetServiceFacade;
    BlopiClientList := BlopiInterface.GetClientList(CountryText(AdminSystem.fdFields.fdCountry),
                                                    AdminSystem.fdFields.fdBankLink_Code,
                                                    AdminSystem.fdFields.fdBankLink_Connect_Password);
    if Assigned(BlopiClientList) then
    begin
      FClientList := BlopiClientList.Result;
    end else
    begin
      //Something went wrong
      FClientList.Free;
      FClientList := ClientList.Create;
      Msg := '';
      for i := Low(BlopiClientList.ErrorMessages) to High(BlopiClientList.ErrorMessages) do
        Msg := Msg + ServiceErrorMessage(BlopiClientList.ErrorMessages[i]).Message_;
      HelpfulErrorMsg(Msg, 0);
    end;
  end;
end;

procedure TProductConfigService.LoadDummyClientList;
begin
  FClientList := ClientList.Create;
  FClientList.Catalogue := FPractice.Catalogue;

  // GetClientList(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfClientListMIdCYrSK; stdcall;

  AddClient;
  if (High(FPractice.Subscription) <> - 1) then
    if Assigned(FClientList.Clients[0]) then
      ClientSummary(FClientList.Clients[0]).AddSubscription(FPractice.Subscription[0]);

  FClient := Client.Create;
  FClient.Id := FClientList.Clients[0].Id;
  FClient.Catalogue := FPractice.Catalogue;
  if (Length(FPractice.Subscription) > 0) then
    FClient.AddSubscription(FPractice.Subscription[0]);

  // add subscriptions to client
end;

procedure TProductConfigService.LoadDummyPractice;
var
  Cat: CatalogueEntry;
  CatArray: ArrayOfCatalogueEntry;
  UserArray: ArrayOfUser;
  SubArray: ArrayOfGuid;
  GUID: TGuid;
  AdminUser: User;
begin
  FPractice.DisplayName := 'practice';
  FPractice.DomainName := 'Domain';
  FPractice.EMail := 'scott.wilson@banklink.co.nz';
  FPractice.Phone := '555 5555';

  //Products and sevices
  CatArray := FPractice.Catalogue;
  try
    SetLength(CatArray, 11);
    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Product';
    Cat.Description := 'WagesPlus';
    CatArray[0] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Product';
    Cat.Description := 'InvoicePlus';
    CatArray[1] := Cat;

    //Auto Subscribe to these services
    SubArray := FPractice.Subscription;
    try
      CreateGUID(GUID);
      Cat := CatalogueEntry.Create;
      Cat.Id := GuidToString(GUID);
      Cat.CatalogueType := 'Service';
      Cat.Description := 'BankLink Notes Online';
      CatArray[2] := Cat;
      SetLength(SubArray, Length(SubArray) + 1);
      SubArray[High(SubArray)] := Cat.Id;

      CreateGUID(GUID);
      Cat := CatalogueEntry.Create;
      Cat.Id := GuidToString(GUID);
      Cat.CatalogueType := 'Service';
      Cat.Description := 'Send and Receive Client Files';
      CatArray[3] := Cat;
      SetLength(SubArray, Length(SubArray) + 1);
      SubArray[High(SubArray)] := Cat.Id;
    finally
      FPractice.Subscription := SubArray;
    end;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[4] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[5] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[6] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[7] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[8] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[9] := Cat;

    CreateGUID(GUID);
    Cat := CatalogueEntry.Create;
    Cat.Id := GuidToString(GUID);
    Cat.CatalogueType := 'Service';
    Cat.Description := 'BankLink Online';
    CatArray[10] := Cat;
  finally
    FPractice.Catalogue := CatArray;
  end;

  //Practice users
  UserArray := FPractice.Users;
  try
    SetLength(UserArray, 2);

    CreateGUID(GUID);
    AdminUser := User.Create;
    AdminUser.Id := GuidToString(GUID);
    AdminUser.FullName := 'Andrew Will';
    UserArray[0] := AdminUser;

    CreateGUID(GUID);
    AdminUser := User.Create;
    AdminUser.Id := GuidToString(GUID);
    AdminUser.FullName := 'Scott Wilson';
    UserArray[1] := AdminUser;
  finally
    FPractice.Users := UserArray;
  end;

  //Set primary contact
  FPractice.DefaultAdminUserId := UserArray[1].Id;
end;

function TProductConfigService.LoadPracticeDetailsfromSystemDB: Boolean;
begin
  Result := False;
  if not Assigned(AdminSystem) then
    Exit;

  if AdminSystem.fdFields.fdBankLink_Online_Config <> '' then begin
    LoadRemotableObjectFromXML(AdminSystem.fdFields.fdBankLink_Online_Config, FPractice);
    Result := True;
  end;
end;

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

function TProductConfigService.OnlineStatus: TBankLinkOnlineStatus;
var
  IniFile: TIniFile;
begin
  Result := bosActive;
  IniFile := TIniFile.Create(ExecDir + INIFILE_NAME);
  try
    Result := TBankLinkOnlineStatus(IniFile.ReadInteger('Settings', 'Status', 0));
  finally
    IniFile.Free;
  end;
end;

function TProductConfigService.GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                                                aName : String) : integer;
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

procedure TProductConfigService.AddTypeItem(var aDataArray: TArrVarTypeData;
                                            var aDataItem: TVarTypeData);
begin
  SetLength(aDataArray, High(aDataArray) + 2);
  aDataArray[High(aDataArray)] := aDataItem;
end;

procedure TProductConfigService.AddToXMLTypeNameList(aName : String;
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
      TypeData := GetTypeData(aTypeInfo);
      if TypeData.PropCount > 0 then
      begin
        new(PropList);

        GetPropInfos(aTypeInfo, PropList);
        for Index := 0 to TypeData.PropCount-1 do
        begin
          AddToXMLTypeNameList(PropList[Index].Name, PropList[Index].PropType^, aNameList)
        end;

        Dispose(PropList)
      end
    end;
    tkDynArray : begin
      if TypeData.elType2^.Kind in
        [tkInteger, tkChar, tkFloat, tkString, tkWChar, tkLString, tkWString, tkVariant, tkInt64] then
      begin
        NewItem.Name     := aName;
        NewItem.TypeInfo := aTypeInfo;
        AddTypeItem(aNameList, NewItem);
      end
      else
      begin
        AddToXMLTypeNameList('Array', TypeData.elType2^, aNameList);
      end;
    end;
  end;
end;

procedure TProductConfigService.FindXMLTypeNamesToModify(aMethodName : String;
                                                         var aNameList : TArrVarTypeData);
var
  InterfaceMetaData : TIntfMetaData;
  InterfaceIndex    : integer;
  ParamIndex        : integer;
begin
  GetIntfMetaData(TypeInfo(IBlopiServiceFacade), InterfaceMetaData);

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

procedure TProductConfigService.AddXMLNStoArrays(aCurrNode : IXMLNode;
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

  FindIndex := GetTypeItemIndex(aNameList, aCurrNode.LocalName);
  if FindIndex > -1 then
  begin
    if aCurrNode.ChildNodes.Count > 0 then
    begin
      NamSpcPre := 'D5P1';
      RemClassRegistry.InfoToURI(aNameList[FindIndex].TypeInfo, NamSpcURI, ClassName, IsScalar);
      NodeName := aCurrNode.ChildNodes[0].NodeName;

      SetLength(Values, aCurrNode.ChildNodes.Count);
      for EditIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
        Values[EditIndex] := aCurrNode.ChildNodes[EditIndex].NodeValue;

      for EditIndex := aCurrNode.ChildNodes.Count - 1 downto 0 do
        aCurrNode.ChildNodes.Delete(EditIndex);

      aCurrNode.DeclareNamespace(NamSpcPre, NamSpcURI);

      for EditIndex := 0 to High(Values) do
        aCurrNode.AddChild(NamSpcPre + ':' + NodeName).NodeValue := Values[EditIndex];

      SetLength(Values, 0);
    end;
  end
  else
  begin
    for NodeIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
      AddXMLNStoArrays(aCurrNode.ChildNodes.Nodes[NodeIndex], aNameList);
  end;
end;

procedure TProductConfigService.DoBeforeExecute(const MethodName: string;
                                                var SOAPRequest: InvString);
var
  Document : IXMLDocument;
  NameList : TArrVarTypeData;
begin
  FindXMLTypeNamesToModify(MethodName, NameList);

  if high(NameList) = -1 then
    Exit;

  Document := NewXMLDocument;
  try
    Document.LoadFromXML(SOAPRequest);

    if not Document.IsEmptyDoc then
    begin
      AddXMLNStoArrays(Document.DocumentElement, NameList);

      Document.SaveToXML(SOAPRequest);

      //SOAPRequest := SOAPRequest;
    end;
  finally
    Document := nil;
  end;
end;

procedure TProductConfigService.SetTimeOuts(ConnecTimeout : DWord ;
                                            SendTimeout   : DWord ;
                                            ReciveTimeout : DWord);
begin
  InternetSetOption(nil, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@ConnecTimeout), SizeOf(ConnecTimeout));
  InternetSetOption(nil, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@SendTimeout), SizeOf(SendTimeout));
  InternetSetOption(nil, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@ReciveTimeout), SizeOf(ReciveTimeout));
end;

function TProductConfigService.GetServiceFacade: IBlopiServiceFacade;
var
  HTTPRIO: THTTPRIO;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute   := DoBeforeExecute;
  Result := GetIBlopiServiceFacade(False, '', HTTPRIO);
end;

function TProductConfigService.IsCICOEnabled: Boolean;
var
  i, j: integer;
  Cat: CatalogueEntry;
begin
  Result := False;
  if Assigned(FPractice) then begin
    for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
      Cat := FPractice.Catalogue[i];
      if Cat.Description = 'Send and Receive Client Files' then begin
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

function TProductConfigService.IsNotesOnlineEnabled: Boolean;
var
  i, j: integer;
  Cat: CatalogueEntry;
begin
  Result := False;
  if Assigned(FPractice) then begin
    for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
      Cat := FPractice.Catalogue[i];
      if Cat.Description = 'BankLink Notes Online' then begin
        for j := Low(FPractice.Subscription) to High(FPractice.Subscription) do begin
          if FPractice.Subscription[j] = Cat.Id then begin
            Result := True;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

function TProductConfigService.IsPracticeActive(ShowWarning: Boolean): Boolean;
begin
  Result := not (OnlineStatus in [bosSuspended, bosDeactivated]);
  if ShowWarning then
    case OnlineStatus of
      bosSuspended: HelpfulWarningMsg('BankLink Online is currently in suspended ' +
                                      '(read-only) mode. Please contact BankLink ' +
                                      'Support for further assistance.', 0);
      bosDeactivated: HelpfulWarningMsg('BankLink Online is currently deactivated. ' +
                                        'Please contact BankLink Support for further ' +
                                        'assistance.', 0);
    end;
end;

function TProductConfigService.IsPracticeProductEnabled(
  AProductId: Guid): Boolean;
var
  i: integer;
begin
  Result := False;
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
      if FPracticeCopy.Subscription[i] = AProductID then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

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

procedure TProductConfigService.RemoveProduct(AProductId: Guid);
var
  i, j: integer;
  SubArray: ArrayOfGuid;
  ClientsUsingProduct: integer;
  Msg: string;
  TempCatalogueEntry: CatalogueEntry;
begin
  ClientsUsingProduct := 1;
  //Check if any clients are using the product
//  for i := Low(FClientList.Clients) to Low(FClientList.Clients) do begin
//    for j := Low(Client.SubList) to High(Client.SubList) do begin
//      if AProductId = Client.SubList[j] then
//        Inc(ClientsUsingProduct);
//    end;
//  end;

//  TempCatalogueEntry := GetCatalogueEntry(AProductId);
//  if Assigned(TempCatalogueEntry) then begin
//    if ClientsUsingProduct > 0 then begin
//      Msg := Format('There are currently %d clients using %s. Please remove ' +
//                    'access for these clients from this product before ' +
//                    'disabling it',
//                    [ClientsUsingProduct, TempCatalogueEntry.Description]);
//      HelpfulWarningMsg(MSg, 0);
//      Exit;
//    end;
//  end;

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
end;

function TProductConfigService.SavePractice: Boolean;
begin
  Result := False;
  if UseBankLinkOnline then begin
    if Assigned(FPracticeCopy) then begin
      FPractice.Free;
      FPractice := Practice.Create;
      CopyRemotableObject(FPracticeCopy, FPractice);
      //Save to the web service
      if FOnline then begin
        SaveRemotableObjectToFile(FPractice);
        //If save ok then save an offline copy to System DB
        SavePracticeDetailsToSystemDB;
        Result := True;
      end else begin
        HelpfulErrorMsg('BankLink Practice is unable to update the Practice settings to BankLink Online', 0);
      end;
    end;
  end else begin
    //Settings are only saved locally if not using BankLink Online
    SavePracticeDetailsToSystemDB;
    Result := True;
  end;
end;

procedure TProductConfigService.SavePracticeDetailsToSystemDB;
begin
  if not Assigned(AdminSystem) then
    Exit;

  AdminSystem.fdFields.fdBankLink_Online_Config := RemotableObjectToXML(FPractice);
end;

procedure TProductConfigService.SaveRemotableObjectToFile(ARemotable: TRemotable);
var
  XMLDoc: IXMLDocument;
begin
  XMLDoc:= NewXMLDocument;
  XMLDoc.LoadFromXML(RemotableObjectToXML(ARemotable));
  XMLDoc.SaveToFile(ARemotable.ClassName + '.xml');
end;

procedure TProductConfigService.SelectAllProducts;
var
  i: integer;
  Cat: CatalogueEntry;
  SubArray: ArrayOfGUID;
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

procedure TProductConfigService.SetPrimaryContact(AUser: User);
begin
  FPracticeCopy.DefaultAdminUserId := AUser.Id;
end;

procedure TProductConfigService.SetRegisteredForBankLinkOnline(
  const Value: Boolean);
begin
  FRegisteredForBankLinkOnline := Value;
end;

procedure TProductConfigService.SetUseBankLinkOnline(const Value: Boolean);
begin
  if Assigned(AdminSystem) then
    AdminSystem.fdFields.fdUse_BankLink_Online := Value;
end;              

{ TClientHelper }

function TClientHelper.GetClientConnectDays: string;
begin
  Result := '90';
end;

function TClientHelper.GetDeactivated: boolean;
begin
  Result := true;
end;

function TClientHelper.GetEmailAddress: string;
begin
  Result := 'someone@somewhere.com';
end;

function TClientHelper.GetFreeTrialEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetSuspended: boolean;
begin
  Result := (Self.Status = BlopiServiceFacade.Suspended);
end;

function TClientHelper.GetUseClientDetails: boolean;
begin
  Result := true;
end;

function TClientHelper.GetUserName: string;
begin
  Result := 'Joe Bloggs';
end;

function TClientHelper.GetUserOnTrial: boolean;
begin
  Result := false;
end;

procedure TClientHelper.AddSubscription(AProductID: guid);
var
  SubArray: arrayofguid;
  i: integer;
begin
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    Subscription := SubArray;
  end;
end;

function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

function TClientHelper.GetBillingFrequency: string;
begin
  Result := 'Monthly';
end;

function TProductConfigService.IsUserCreatedOnBankLinkOnline(const APractice : Practice;
                                                             const AUserId   : Guid   = '';
                                                             const AUserCode : string = '') : Boolean;
var
  UserIndex : Integer;
begin
  Result := False;

  // Goes through passed through Practice users and finds the first one with either
  // a matching Guid or Code
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

function TProductConfigService.GetErrorMessage(aErrorMessages : ArrayOfServiceErrorMessage;
                                               aExceptions    : ArrayOfExceptionDetails ) : string;
var
  ErrIndex : integer;
begin
  Result := '';

  for ErrIndex := 0 to high(aErrorMessages) do
    Result := Result + #13 + aErrorMessages[ErrIndex].ErrorCode + ' : ' +
                       aErrorMessages[ErrIndex].Message_;
  if not (Result = '') then
    Result := #13 + Result;

  for ErrIndex := 0 to high(aExceptions) do
    Result := Result + #13 + 'Message    : ' + aExceptions[ErrIndex].Message_ + #13 +
                             'Source     : ' + aExceptions[ErrIndex].Source  + #13 +
                             'StackTrace : ' + aExceptions[ErrIndex].StackTrace;
  if not (Result = '') then
    Result := #13 + Result;
end;

function TProductConfigService.UpdateCreateUser(var   aUserId        : Guid;
                                                const aEMail         : WideString;
                                                const aFullName      : WideString;
                                                const aUserCode      : WideString;
                                                const aUstNameIndex  : integer;
                                                var   aIsUserCreated : Boolean ) : Boolean;
var
  UpdateUser      : User;
  CreateUser      : NewUser;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  MsgResponceGuid : MessageResponseOfguid;
  ErrMsg          : String;
  CurrPractice    : Practice;
  IsUserOnline    : Boolean;
  BlopiInterface  : IBlopiServiceFacade;
  RoleNames       : ArrayOfString;
  Subscription    : ArrayOfGuid;
begin
  Result := false;

  PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
  PracCode        := AdminSystem.fdFields.fdBankLink_Code;
  PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

  try
    // Does the User Already Exist on BankLink Online?
    CurrPractice := GetPractice;

    setlength(Subscription, 1);
    Subscription[0] := '6D700B31-DAEE-4847-8CB2-82C21328AC28';

    IsUserOnline := IsUserCreatedOnBankLinkOnline(CurrPractice, aUserId, aUserCode);

    SetLength(RoleNames,1);
    RoleNames[0] := CurrPractice.GetRoleFromPracUserType(aUstNameIndex).RoleName;
  except
    on E : Exception do
    begin
      LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running IsUserCreatedOnBankLinkOnline, Error Message : ' + E.Message);
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
    end;
  end;

  BlopiInterface := GetServiceFacade;
  //SetTimeOuts(5000,5000,5000);

  if IsUserOnline then
  begin
    UpdateUser := User.Create;
    UpdateUser.EMail        := aEMail;
    UpdateUser.FullName     := aFullName;
    UpdateUser.Id           := aUserId;
    UpdateUser.RoleNames    := RoleNames;
    UpdateUser.Subscription := Subscription; //CurrPractice.Subscription;
    UpdateUser.UserCode     := aUserCode;

    try
      MsgResponce := BlopiInterface.SavePracticeUser(PracCountryCode, PracCode, PracPassHash, UpdateUser);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running SavePracticeUser, Error Message : ' + E.Message);
        raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
      end;
    end;

    Result := MsgResponce.Success;
    if not Result then
    begin
      ErrMsg := GetErrorMessage(MsgResponce.ErrorMessages, MsgResponce.Exceptions);

      LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running SavePracticeUser, Error Message : ' + ErrMsg);
      raise Exception.Create('BankLink Practice was unable to update ' + UpdateUser.FullName +
                             ' on BankLink Online. ' + ErrMsg );
    end;

    aIsUserCreated := false;
  end
  else
  begin
    CreateUser := NewUser.Create;
    CreateUser.EMail        := aEMail;
    CreateUser.FullName     := aFullName;
    CreateUser.RoleNames    := RoleNames;
    CreateUser.Subscription := Subscription; //CurrPractice.Subscription;
    CreateUser.UserCode     := aUserCode;

    try
      MsgResponceGuid := BlopiInterface.CreatePracticeUser(PracCountryCode, PracCode, PracPassHash, CreateUser);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running CreatePracticeUser, Error Message : ' + E.Message);
        raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
      end;
    end;
    Result  := MsgResponceGuid.Success;
    aUserId := MsgResponceGuid.Result;

    if not Result then
    begin
      ErrMsg := GetErrorMessage(MsgResponceGuid.ErrorMessages, MsgResponceGuid.Exceptions);

      LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running CreatePracticeUser, Error Message : ' + ErrMsg);
      raise Exception.Create('BankLink Practice was unable to create ' + CreateUser.FullName +
                             ' on BankLink Online. ' + ErrMsg );
    end;

    aIsUserCreated := True;
  end;
end;

function TProductConfigService.DeleteUser(aUserCode : string;
                                          aPractice : Practice) : Boolean;
var
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  ErrMsg          : String;
  BlopiInterface  : IBlopiServiceFacade;
  UserGuid        : Guid;
begin
  Result := false;

  BlopiInterface  := GetServiceFacade;
  PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
  PracCode        := AdminSystem.fdFields.fdBankLink_Code;
  PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

  try
    if not Assigned(aPractice) then
      aPractice := GetPractice;

    UserGuid := GetUserGuid(aUserCode, aPractice);
    MsgResponce := BlopiInterface.DeletePracticeUser(PracCountryCode, PracCode, PracPassHash, UserGuid);
    Result := MsgResponce.Success;
  except
    on E : Exception do
    begin
      LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running DeletePracticeUser, Error Message : ' + E.Message);
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
    end;
  end;

  if not Result then
  begin
    ErrMsg := GetErrorMessage(MsgResponce.ErrorMessages, MsgResponce.Exceptions);

    LogUtil.LogMsg(lmError, UNIT_NAME, 'Server Error running DeletePracticeUser, Error Message : ' + ErrMsg);
    raise Exception.Create('BankLink Practice was unable to delete user' +
                           ' from BankLink Online. ' + ErrMsg );
  end;
end;

function TProductConfigService.IsPrimaryUser(aUserCode : string;
                                             aPractice : Practice): Boolean;
begin
  if aUserCode = '' then
  begin
    Result := false;
    Exit;
  end;

  if not Assigned(aPractice) then
    aPractice := GetPractice;

  Result := (GetUserGuid(aUserCode, aPractice) = aPractice.DefaultAdminUserId);
end;

function TProductConfigService.ChangeUserPassword(const aUserCode    : string;
                                                  const aOldPassword : string;
                                                  const aNewPassword : string) : Boolean;
begin
  Result := True;
end;

{ TClientSummaryHelper }
procedure TClientSummaryHelper.AddSubscription(AProductID: guid);
var
  SubArray: arrayofguid;
  i: integer;
begin
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
  finally
    Subscription := SubArray;
  end;
end;

{ TPracticeHelper }
function TPracticeHelper.GetUserRoleGuidFromPracUserType(aUstNameIndex: integer): Guid;
begin
  Result := '';
  if (aUstNameIndex < ustMin)
  or (aUstNameIndex > ustMax) then
    raise Exception.Create('Practice User Type does not exist in the Admin System.');

  case aUstNameIndex of
                            // Accountant Practice Standard User
    ustRestricted : Result := '8C464F01-5071-4FC1-B257-0104D48D141B';
                            // Accountant Practice Standard User
    ustNormal     : Result := '8C464F01-5071-4FC1-B257-0104D48D141B';
                            // Accountant Practice Administrator
    ustSystem     : Result := '8C464F01-5071-4FC1-B257-0104D48D1418';
  end;
end;

function TPracticeHelper.GetRoleFromPracUserType(aUstNameIndex: integer): Role;
var
  RoleGuid : Guid;
  RoleIndex : integer;
begin
  Result := Nil;
  RoleGuid := GetUserRoleGuidFromPracUserType(aUstNameIndex);

  for RoleIndex := 0 to High(Self.Roles) do
  begin
    if (UpperCase(Self.Roles[RoleIndex].Id) = RoleGuid) then
    begin
      Result := Self.Roles[RoleIndex];
      Exit;
    end;
  end;

  raise Exception.Create('Practice User Role does not exist on BankLink Online.');
end;

end.
